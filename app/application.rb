require 'sinatra/base'
require 'sinatra/json'
require 'active_record'
require 'json'

# Load models
require_relative 'models/game'
require_relative 'models/room'
require_relative 'models/player'

# Load GameStatistic model if it exists (for backward compatibility)
begin
  require_relative 'models/game_statistic'
rescue LoadError
  # GameStatistic not available, statistics features will be disabled
end

# Load Leaderboard model if it exists (for backward compatibility)
begin
  require_relative 'models/leaderboard'
rescue LoadError
  # Leaderboard not available, leaderboard features will be disabled
end

# Load Achievement model if it exists (for backward compatibility)
begin
  require_relative 'models/achievement'
rescue LoadError
  # Achievement not available, achievement features will be disabled
end

class Application < Sinatra::Base
  configure do
    db_config = {
      adapter: 'sqlite3',
      database: File.join(File.dirname(__FILE__), '..', 'db', 'development.sqlite3')
    }
    ActiveRecord::Base.establish_connection(db_config)
    
    # Create tables if they don't exist
    unless ActiveRecord::Base.connection.table_exists?('games')
      ActiveRecord::Base.connection.create_table :games do |t|
        t.text :board
        t.string :current_player, default: 'X'
        t.string :status, default: 'playing'
        t.timestamps
      end
    end
  end

  # Enable CORS for frontend
  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
  end

  options '*' do
    200
  end

  # Serve static files
  set :public_folder, File.join(File.dirname(__FILE__), '..', 'public')

  # Routes
  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end

  # API Routes
  get '/api/games' do
    json Game.all
  end

  post '/api/games' do
    game = Game.create(board: Array.new(9, nil), current_player: 'X', status: 'playing')
    json game
  end

  get '/api/games/:id' do
    game = Game.find(params[:id])
    json game
  end

  put '/api/games/:id/move' do
    request_body = JSON.parse(request.body.read)
    position = request_body['position']
    
    game = Game.find(params[:id])
    
    if game.make_move(position)
      json game
    else
      status 400
      json({ error: 'Invalid move' })
    end
  end

  # Multiplayer API Routes
  post '/api/rooms' do
    player_name = JSON.parse(request.body.read)['player_name']
    return json({ error: 'Player name required' }) unless player_name
    
    room = Room.create!
    session_id = SecureRandom.hex(16)
    player = room.add_player(player_name, session_id)
    
    if player
      json({
        room_code: room.code,
        session_id: session_id,
        player: { name: player.name, symbol: player.symbol }
      })
    else
      status 400
      json({ error: 'Failed to create room' })
    end
  end
  
  post '/api/rooms/:code/join' do
    data = JSON.parse(request.body.read)
    player_name = data['player_name']
    return json({ error: 'Player name required' }) unless player_name
    
    room = Room.find_by(code: params[:code])
    return json({ error: 'Room not found' }) unless room
    return json({ error: 'Room is full' }) if room.full?
    
    session_id = SecureRandom.hex(16)
    player = room.add_player(player_name, session_id)
    
    if player
      json({
        room_code: room.code,
        session_id: session_id,
        player: { name: player.name, symbol: player.symbol },
        players: room.players.map { |p| { name: p.name, symbol: p.symbol } },
        ready_to_start: room.ready_to_start?
      })
    else
      status 400
      json({ error: 'Failed to join room' })
    end
  end
  
  get '/api/rooms/:code' do
    room = Room.find_by(code: params[:code])
    return json({ error: 'Room not found' }) unless room
    
    json({
      code: room.code,
      status: room.status,
      players: room.players.map { |p| { name: p.name, symbol: p.symbol } },
      current_game: room.current_game&.id
    })
  end

  # Statistics API Routes (only if GameStatistic is available)
  get '/api/statistics' do
    if defined?(GameStatistic)
      json GameStatistic.today
    else
      json({ error: 'Statistics not available - please run database migrations' })
    end
  end
  
  get '/api/statistics/summary' do
    if defined?(GameStatistic)
      period = params[:period] || '30'
      start_date = period.to_i.days.ago.to_date
      
      json GameStatistic.aggregate_stats(start_date)
    else
      json({ error: 'Statistics not available - please run database migrations' })
    end
  end
  
  get '/api/statistics/weekly' do
    if defined?(GameStatistic)
      json GameStatistic.weekly_summary
    else
      json({ error: 'Statistics not available - please run database migrations' })
    end
  end
  
  get '/api/statistics/games' do
    limit = [params[:limit]&.to_i || 10, 100].min
    
    # Build query conditionally based on available columns
    games_query = Game.where.not(status: 'playing').limit(limit)
    
    # Only order by finished_at if the column exists
    if Game.column_names.include?('finished_at')
      games_query = games_query.order(finished_at: :desc)
    else
      games_query = games_query.order(updated_at: :desc)
    end
    
    games = games_query.includes(:room)
    
    json games.map { |game|
      result = {
        id: game.id,
        status: game.status
      }
      
      # Add optional fields if they exist
      result[:winner] = game.winner_player if game.respond_to?(:winner_player)
      result[:game_type] = game.game_type if game.respond_to?(:game_type)
      result[:move_count] = game.move_count if game.respond_to?(:move_count)
      result[:duration_minutes] = game.duration_in_minutes
      result[:finished_at] = game.finished_at if game.respond_to?(:finished_at)
      
      result
    }
  end

  # Leaderboard API Routes (only if Leaderboard is available)
  get '/api/leaderboard' do
    if defined?(Leaderboard)
      leaderboard_type = params[:type] || 'wins'
      limit = [params[:limit]&.to_i || 10, 50].min
      
      leaderboard = case leaderboard_type
                   when 'wins'
                     Leaderboard.top_players(limit)
                   when 'win_rate'
                     Leaderboard.by_win_rate(limit)
                   when 'games'
                     Leaderboard.by_total_games(limit)
                   else
                     Leaderboard.top_players(limit)
                   end
      
      json leaderboard.map { |entry|
        {
          player_name: entry.player_name,
          total_games: entry.total_games,
          wins: entry.wins,
          losses: entry.losses,
          draws: entry.draws,
          win_rate: entry.win_rate,
          current_win_streak: entry.current_win_streak,
          best_win_streak: entry.best_win_streak,
          fastest_win_moves: entry.fastest_win_moves,
          rank_by_wins: entry.rank_by_wins,
          rank_by_win_rate: entry.rank_by_win_rate
        }
      }
    else
      json({ error: 'Leaderboard not available - please run database migrations' })
    end
  end
  
  get '/api/leaderboard/:player_name' do
    if defined?(Leaderboard)
      player = Leaderboard.find_by(player_name: params[:player_name])
      
      if player
        json({
          player_name: player.player_name,
          total_games: player.total_games,
          wins: player.wins,
          losses: player.losses,
          draws: player.draws,
          win_rate: player.win_rate,
          current_win_streak: player.current_win_streak,
          best_win_streak: player.best_win_streak,
          fastest_win_moves: player.fastest_win_moves,
          rank_by_wins: player.rank_by_wins,
          rank_by_win_rate: player.rank_by_win_rate,
          last_game_at: player.last_game_at
        })
      else
        status 404
        json({ error: 'Player not found in leaderboard' })
      end
    else
      json({ error: 'Leaderboard not available - please run database migrations' })
    end
  end
  
  get '/api/leaderboard/stats/summary' do
    if defined?(Leaderboard)
      total_players = Leaderboard.count
      active_players = Leaderboard.where('total_games > 0').count
      top_player = Leaderboard.order(wins: :desc).first
      most_games = Leaderboard.order(total_games: :desc).first
      
      json({
        total_players: total_players,
        active_players: active_players,
        top_player: top_player ? {
          name: top_player.player_name,
          wins: top_player.wins,
          win_rate: top_player.win_rate
        } : nil,
        most_active: most_games ? {
          name: most_games.player_name,
          total_games: most_games.total_games,
          win_rate: most_games.win_rate
        } : nil
      })
    else
      json({ error: 'Leaderboard not available - please run database migrations' })
    end
  end

  # Achievement API Routes (only if Achievement is available)
  get '/api/achievements' do
    if defined?(Achievement)
      limit = [params[:limit]&.to_i || 20, 100].min
      
      if params[:player_name]
        achievements = Achievement.for_player(params[:player_name])
      else
        achievements = Achievement.recent_achievements(limit)
      end
      
      json achievements.map { |achievement|
        {
          id: achievement.id,
          player_name: achievement.player_name,
          achievement_type: achievement.achievement_type,
          title: achievement.title,
          description: achievement.description,
          icon: achievement.icon,
          earned_at: achievement.earned_at
        }
      }
    else
      json({ error: 'Achievements not available - please run database migrations' })
    end
  end
  
  get '/api/achievements/:player_name' do
    if defined?(Achievement)
      achievements = Achievement.for_player(params[:player_name])
      
      json({
        player_name: params[:player_name],
        total_achievements: achievements.count,
        achievements: achievements.map { |achievement|
          {
            achievement_type: achievement.achievement_type,
            title: achievement.title,
            description: achievement.description,
            icon: achievement.icon,
            earned_at: achievement.earned_at
          }
        }
      })
    else
      json({ error: 'Achievements not available - please run database migrations' })
    end
  end
  
  get '/api/achievements/definitions/all' do
    if defined?(Achievement)
      json Achievement::ACHIEVEMENT_DEFINITIONS.map { |type, definition|
        {
          achievement_type: type,
          title: definition[:title],
          description: definition[:description],
          icon: definition[:icon]
        }
      }
    else
      json({ error: 'Achievements not available - please run database migrations' })
    end
  end

  # Doc agent webhook endpoint
  post '/webhook/github' do
    payload = JSON.parse(request.body.read)
    
    if payload['action'] == 'opened' || payload['action'] == 'synchronize'
      # Process PR for documentation updates
      require_relative '../doc-agent/src/webhook_handler'
      WebhookHandler.process_pr(payload)
    end
    
    status 200
  end

  run! if app_file == $0
end