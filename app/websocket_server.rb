require 'faye/websocket'
require 'eventmachine'
require 'json'
require_relative 'models/room'
require_relative 'models/game'
require_relative 'models/player'

class WebSocketServer
  def initialize
    @clients = {}
    @rooms = {}
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)
      session_id = generate_session_id

      ws.on :open do |event|
        puts "WebSocket connected: #{session_id}"
        @clients[session_id] = ws
        send_message(ws, { type: 'connected', session_id: session_id })
      end

      ws.on :message do |event|
        begin
          data = JSON.parse(event.data)
          handle_message(session_id, data)
        rescue JSON::ParserError
          send_error(ws, "Invalid JSON")
        end
      end

      ws.on :close do |event|
        puts "WebSocket disconnected: #{session_id}"
        handle_disconnect(session_id)
        @clients.delete(session_id)
      end

      ws.rack_response
    else
      [400, {}, ['WebSocket required']]
    end
  end

  private

  def handle_message(session_id, data)
    ws = @clients[session_id]
    
    case data['type']
    when 'create_room'
      create_room(session_id, data)
    when 'join_room'
      join_room(session_id, data)
    when 'make_move'
      make_move(session_id, data)
    when 'start_game'
      start_game(session_id, data)
    else
      send_error(ws, "Unknown message type: #{data['type']}")
    end
  end

  def create_room(session_id, data)
    player_name = data['player_name']
    return send_error(@clients[session_id], "Player name required") unless player_name

    room = Room.create!
    player = room.add_player(player_name, session_id)
    
    if player
      send_message(@clients[session_id], {
        type: 'room_created',
        room_code: room.code,
        player: { name: player.name, symbol: player.symbol }
      })
    else
      send_error(@clients[session_id], "Failed to create room")
    end
  end

  def join_room(session_id, data)
    room_code = data['room_code']
    player_name = data['player_name']
    
    return send_error(@clients[session_id], "Room code and player name required") unless room_code && player_name

    room = Room.find_by(code: room_code)
    return send_error(@clients[session_id], "Room not found") unless room
    return send_error(@clients[session_id], "Room is full") if room.full?

    player = room.add_player(player_name, session_id)
    
    if player
      # Notify all players in the room
      broadcast_to_room(room, {
        type: 'player_joined',
        room_code: room.code,
        players: room.players.map { |p| { name: p.name, symbol: p.symbol } },
        ready_to_start: room.ready_to_start?
      })
    else
      send_error(@clients[session_id], "Failed to join room")
    end
  end

  def start_game(session_id, data)
    player = Player.find_by(session_id: session_id)
    return send_error(@clients[session_id], "Player not found") unless player

    room = player.room
    return send_error(@clients[session_id], "Room not ready") unless room.ready_to_start?

    game = room.start_new_game!
    
    if game
      broadcast_to_room(room, {
        type: 'game_started',
        game: serialize_game(game),
        current_player: game.current_player
      })
    else
      send_error(@clients[session_id], "Failed to start game")
    end
  end

  def make_move(session_id, data)
    position = data['position']
    return send_error(@clients[session_id], "Position required") unless position

    player = Player.find_by(session_id: session_id)
    return send_error(@clients[session_id], "Player not found") unless player

    room = player.room
    game = room.current_game
    return send_error(@clients[session_id], "No active game") unless game

    if game.make_move(position, session_id)
      broadcast_to_room(room, {
        type: 'move_made',
        game: serialize_game(game),
        position: position,
        player: player.symbol,
        current_player: game.current_player,
        winner: game.winner,
        status: game.status
      })
    else
      send_error(@clients[session_id], "Invalid move")
    end
  end

  def handle_disconnect(session_id)
    player = Player.find_by(session_id: session_id)
    if player
      room = player.room
      player.destroy
      
      if room.players.count == 0
        room.destroy
      else
        broadcast_to_room(room, {
          type: 'player_left',
          players: room.players.map { |p| { name: p.name, symbol: p.symbol } }
        })
      end
    end
  end

  def broadcast_to_room(room, message)
    room.players.each do |player|
      ws = @clients[player.session_id]
      send_message(ws, message) if ws
    end
  end

  def send_message(ws, message)
    ws.send(JSON.generate(message)) if ws
  end

  def send_error(ws, error)
    send_message(ws, { type: 'error', message: error })
  end

  def serialize_game(game)
    {
      id: game.id,
      board: game.board,
      status: game.status,
      current_player: game.current_player,
      player_x: game.player_x,
      player_o: game.player_o
    }
  end

  def generate_session_id
    SecureRandom.hex(16)
  end
end