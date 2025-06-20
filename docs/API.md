# Tic Tac Toe API Documentation

## Overview

This API provides endpoints for managing tic-tac-toe games. Players can create new games, make moves, and retrieve game state. The API now also includes a real-time multiplayer system, allowing players to create and join games with other users.

## Base URL

```
http://localhost:4567/api
```

## Endpoints

### GET /games

Retrieve all games.

**Response:**
```json
[
  {
    "id": 1,
    "board": ["X", null, "O", null, "X", null, null, null, null],
    "current_player": "O",
    "status": "playing",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
]
```

### POST /games

Create a new game.

**Response:**
```json
{
  "id": 1,
  "board": [null, null, null, null, null, null, null, null, null],
  "current_player": "X",
  "status": "playing",
  "created_at": "2024-01-01T00:00:00.000Z",
  "updated_at": "2024-01-01T00:00:00.000Z"
}
```

### GET /games/:id

Retrieve a specific game by ID.

**Parameters:**
- `id` (integer) - Game ID

**Response:**
```json
{
  "id": 1,
  "board": ["X", null, "O", null, "X", null, null, null, null],
  "current_player": "O",
  "status": "playing",
  "created_at": "2024-01-01T00:00:00.000Z",
  "updated_at": "2024-01-01T00:00:00.000Z"
}
```

### PUT /games/:id/move

Make a move in a specific game.

**Parameters:**
- `id` (integer) - Game ID

**Request Body:**
```json
{
  "position": 0
}
```

**Response:**
```json
{
  "id": 1,
  "board": ["X", null, "O", null, "X", null, null, null, null],
  "current_player": "O",
  "status": "playing",
  "created_at": "2024-01-01T00:00:00.000Z",
  "updated_at": "2024-01-01T00:00:00.000Z"
}
```

**Error Response (400):**
```json
{
  "error": "Invalid move"
}
```

## Player Management

The API now includes functionality for managing player information, including their win-loss-draw record.

### GET /players

Retrieve a list of all players.

**Response:**
```json
[
  {
    "id": 1,
    "name": "Player 1",
    "wins": 10,
    "losses": 5,
    "draws": 3,
    "total_games": 18,
    "win_rate": 55.56
  },
  {
    "id": 2,
    "name": "Player 2",
    "wins": 8,
    "losses": 7,
    "draws": 2,
    "total_games": 17,
    "win_rate": 47.06
  }
]
```

### POST /players

Create a new player.

**Request Body:**
```json
{
  "name": "New Player"
}
```

**Response:**
```json
{
  "id": 3,
  "name": "New Player",
  "wins": 0,
  "losses": 0,
  "draws": 0,
  "total_games": 0,
  "win_rate": 0.0
}
```

## Game States

- `playing` - Game is in progress
- `X_wins` - Player X has won
- `O_wins` - Player O has won
- `draw` - Game ended in a draw

## Board Positions

The board is represented as an array of 9 positions (0-8):

```
0 | 1 | 2
---------
3 | 4 | 5
---------
6 | 7 | 8
```

## Multiplayer System

The Tic Tac Toe API now includes a real-time multiplayer system, allowing players to create and join games with other users.

### Creating a Room

Players can create a new room by making a `POST` request to the `/api/rooms` endpoint with their player name:

**Request:**
```json
{
  "player_name": "John Doe"
}
```

**Response:**
```json
{
  "room_code": "ABC123",
  "session_id": "abcd1234",
  "player": {
    "name": "John Doe",
    "symbol": "X"
  }
}
```

The response includes the unique room code, the player's session ID, and the player's assigned symbol (either "X" or "O").

### Joining a Room

To join an existing room, players can make a `POST` request to the `/api/rooms/:code/join` endpoint with their player name:

**Request:**
```json
{
  "player_name": "Jane Smith"
}
```

**Response:**
```json
{
  "room_code": "ABC123",
  "session_id": "efgh5678",
  "player": {
    "name": "Jane Smith",
    "symbol": "O"
  }
}
```

The response includes the room code, the player's session ID, and the player's assigned symbol.

### Game Synchronization

Once two players have joined a room, a new game is automatically started. Both players will receive real-time updates about the game state, including the current board, the current player's turn, and the game status (playing, won, or draw).

Players can make moves by sending a `PUT` request to the `/games/:id/move` endpoint, providing the position they want to play. The game state will be updated and broadcasted to all connected players.

### Disconnection Handling

If a player disconnects during a game, the remaining player will be able to continue playing. The disconnected player's spot will be marked as empty, and the game will continue with the remaining player taking their turns.

### WebSocket Communication

The real-time communication between players is handled using WebSocket connections. When a player connects to the server, a WebSocket connection is established, and the player's session ID is associated with the connection. All game-related updates and actions are then communicated through the WebSocket channel.

For more information on the WebSocket server implementation, please refer to the `app/websocket_server.rb` file.

## Code Changes

The following code changes were made to implement the real-time multiplayer system:

1. **Add Room Management System**: A new `Room` model was introduced to handle room creation, player joining, and game coordination. The `Room` model has a one-to-many relationship with `Game` and `Player` models.

2. **Implement Player Management**: The `Player` model was updated to include the concept of player symbols (either "X" or "O") and session IDs for real-time communication. Players can now be associated with a specific room.

3. **Modify Game Logic**: The `Game` model was updated to handle validation for player turns in multiplayer games. The `make_move` method now checks if the current player is allowed to make a move based on the game state and the player's session ID.

4. **Add WebSocket Server**: A new `WebSocketServer` class was introduced to manage real-time communication between players using WebSocket connections. This server handles player connections, message handling, and game state updates.

5. **Update Database Schema**: New database migrations were added to create the `rooms`, `players`, and the `room_id` column in the `games` table to support the multiplayer functionality.

6. **Create Multiplayer Documentation**: A new documentation file, `docs/MULTIPLAYER.md`, was added to explain the multiplayer system's architecture, data models, and communication flow.

7. **Add Multiplayer HTML/CSS**: A new HTML file, `public/multiplayer.html`, was created to provide a user interface for the multiplayer functionality, including room creation, player joining, and game visualization.

The updated API documentation now covers the new multiplayer system, including room management, player joining, and real-time game state synchronization.