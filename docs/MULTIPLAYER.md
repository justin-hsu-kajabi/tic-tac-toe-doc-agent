# Multiplayer Tic Tac Toe System

## Overview

The multiplayer system enables real-time tic-tac-toe gameplay between two players using WebSocket connections and room-based matchmaking. Players can create or join rooms using unique room codes and play against each other with live updates.

## Architecture

### Components

1. **Room Management System** - Handles room creation, player joining, and game coordination
2. **WebSocket Server** - Manages real-time communication between players
3. **Player Session Management** - Tracks player connections and game state
4. **Game State Synchronization** - Ensures both players see the same game state

### Data Models

#### Room Model
```ruby
class Room < ActiveRecord::Base
  has_many :games, dependent: :destroy
  has_many :players, dependent: :destroy
  
  validates :code, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[waiting active completed] }
end
```

- **Attributes**: code (unique 6-character), status, max_players
- **Methods**: `full?`, `ready_to_start?`, `start_new_game!`, `add_player`

#### Player Model
```ruby
class Player < ActiveRecord::Base
  belongs_to :room
  
  validates :name, presence: true
  validates :session_id, presence: true, uniqueness: true
  validates :symbol, inclusion: { in: %w[X O] }
end
```

- **Attributes**: name, session_id, symbol (X or O)
- **Methods**: `opponent`, `is_turn?`

#### Enhanced Game Model
```ruby
class Game < ActiveRecord::Base
  belongs_to :room, optional: true
  
  def make_move(position, player_session_id = nil)
    # Validates turn for multiplayer games
    # Updates board and switches players
  end
end
```

- **New attributes**: room_id, player_x, player_o
- **Enhanced validation**: Turn-based move validation for multiplayer

## API Endpoints

### Room Management

#### Create Room
```http
POST /api/rooms
Content-Type: application/json

{
  "player_name": "Alice"
}
```

**Response:**
```json
{
  "room_code": "ABC123",
  "session_id": "unique-session-id",
  "player": {
    "name": "Alice",
    "symbol": "X"
  }
}
```

#### Join Room
```http
POST /api/rooms/:code/join
Content-Type: application/json

{
  "player_name": "Bob"
}
```

**Response:**
```json
{
  "room_code": "ABC123",
  "session_id": "unique-session-id",
  "player": {
    "name": "Bob", 
    "symbol": "O"
  },
  "players": [
    {"name": "Alice", "symbol": "X"},
    {"name": "Bob", "symbol": "O"}
  ],
  "ready_to_start": true
}
```

#### Get Room Status
```http
GET /api/rooms/:code
```

**Response:**
```json
{
  "code": "ABC123",
  "status": "active",
  "players": [
    {"name": "Alice", "symbol": "X"},
    {"name": "Bob", "symbol": "O"}
  ],
  "current_game": 42
}
```

## WebSocket Protocol

### Connection
```javascript
const ws = new WebSocket('ws://localhost:4567/websocket');
```

### Message Types

#### Client → Server Messages

**Create Room**
```json
{
  "type": "create_room",
  "player_name": "Alice"
}
```

**Join Room**
```json
{
  "type": "join_room",
  "room_code": "ABC123",
  "player_name": "Bob"
}
```

**Start Game**
```json
{
  "type": "start_game"
}
```

**Make Move**
```json
{
  "type": "make_move",
  "position": 4
}
```

#### Server → Client Messages

**Connection Established**
```json
{
  "type": "connected",
  "session_id": "unique-session-id"
}
```

**Room Created**
```json
{
  "type": "room_created",
  "room_code": "ABC123",
  "player": {"name": "Alice", "symbol": "X"}
}
```

**Player Joined**
```json
{
  "type": "player_joined",
  "room_code": "ABC123",
  "players": [
    {"name": "Alice", "symbol": "X"},
    {"name": "Bob", "symbol": "O"}
  ],
  "ready_to_start": true
}
```

**Game Started**
```json
{
  "type": "game_started",
  "game": {
    "id": 42,
    "board": [null, null, null, null, null, null, null, null, null],
    "status": "playing",
    "current_player": "X",
    "player_x": "Alice",
    "player_o": "Bob"
  },
  "current_player": "X"
}
```

**Move Made**
```json
{
  "type": "move_made",
  "game": {
    "id": 42,
    "board": ["X", null, null, null, null, null, null, null, null],
    "status": "playing",
    "current_player": "O"
  },
  "position": 0,
  "player": "X",
  "current_player": "O",
  "winner": null,
  "status": "playing"
}
```

**Error**
```json
{
  "type": "error",
  "message": "Invalid move"
}
```

## Frontend Implementation

### Multiplayer Interface (`/multiplayer.html`)

The multiplayer interface provides:

1. **Room Creation/Joining Form**
   - Player name input
   - Create room or join with room code options

2. **Room Waiting Area**
   - Display room code for sharing
   - Show connected players
   - Start game button (appears when 2 players joined)

3. **Game Board**
   - Real-time synchronized game board
   - Turn indicators
   - Move validation

4. **Connection Management**
   - WebSocket connection handling
   - Automatic reconnection on disconnect
   - Error message display

### Key Frontend Features

- **Real-time Updates**: All game state changes broadcast immediately
- **Turn Validation**: Only current player can make moves
- **Session Management**: Each player has unique session ID
- **Responsive Design**: Works on desktop and mobile devices

## Game Flow

1. **Room Creation**
   - Player 1 creates room with their name
   - Receives unique room code
   - Waits in room for second player

2. **Player Joining**
   - Player 2 enters room code and name
   - Joins room, both players notified
   - Start game button becomes available

3. **Game Start**
   - Either player can start the game
   - New game instance created
   - Game board initialized and synced

4. **Gameplay**
   - Players take turns making moves
   - Each move validated and broadcast
   - Game state synchronized in real-time

5. **Game End**
   - Winner determined or draw declared
   - Players can start new game or leave room

## Security Considerations

- **Session Validation**: All moves validated against player session
- **Turn Validation**: Only current player can make moves
- **Room Access**: Players can only interact with their joined room
- **Input Sanitization**: All user input validated server-side

## Performance Features

- **Connection Pooling**: Efficient WebSocket connection management
- **State Synchronization**: Minimal data transfer for state updates
- **Resource Cleanup**: Automatic cleanup of disconnected players and empty rooms

## Error Handling

- **Connection Errors**: Graceful handling of WebSocket disconnections
- **Invalid Moves**: Server-side validation with error feedback
- **Room Full**: Clear messaging when attempting to join full room
- **Game State Errors**: Validation of game state before move processing

## Dependencies

- **faye-websocket**: WebSocket server implementation
- **eventmachine**: Asynchronous event processing
- **securerandom**: Secure session ID and room code generation

## Configuration

No additional configuration required. The multiplayer system uses the existing database and web server infrastructure.

## Testing

To test the multiplayer functionality:

1. Start the application server
2. Open two browser windows/tabs
3. Navigate to `/multiplayer.html` in both
4. Create room in first window
5. Join room with code in second window
6. Start game and test real-time gameplay