require 'sinatra/base'
require 'sinatra/json'
require 'active_record'
require 'json'

# Load models
require_relative 'models/game'
require_relative 'models/room'
require_relative 'models/player'
require_relative 'models/game_statistic'

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

  # Statistics API Routes
  get '/api/statistics' do
    json GameStatistic.today
  end
  
  get '/api/statistics/summary' do
    period = params[:period] || '30'
    start_date = period.to_i.days.ago.to_date
    
    json GameStatistic.aggregate_stats(start_date)
  end
  
  get '/api/statistics/weekly' do
    json GameStatistic.weekly_summary
  end
  
  get '/api/statistics/games' do
    limit = [params[:limit]&.to_i || 10, 100].min
    games = Game.where.not(status: 'playing')
                .order(finished_at: :desc)
                .limit(limit)
                .includes(:room)
    
    json games.map { |game|
      {
        id: game.id,
        status: game.status,
        winner: game.winner_player,
        game_type: game.game_type,
        move_count: game.move_count,
        duration_minutes: game.duration_in_minutes,
        finished_at: game.finished_at
      }
    }
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