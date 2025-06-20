# Tic Tac Toe API Documentation

## Overview

This API provides endpoints for managing tic-tac-toe games. Players can create new games, make moves, and retrieve game state. The API now also includes a real-time multiplayer system, allowing players to create and join games with other users. Additionally, the API includes a comprehensive game statistics and analytics system to track player performance and game metrics.

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

## Game Statistics and Analytics

The Tic Tac Toe API includes a comprehensive game statistics and analytics system to track player performance and game metrics.

### Automatic Data Collection

The statistics system automatically collects the following data for each game:
- Game duration
- Move count
- Winner
- Game type (solo or multiplayer)

This data is then aggregated daily to provide insights and trends.

### Available Metrics

The following statistics are available through the API:

#### GET /api/statistics

Retrieve the daily game statistics for the current date.

**Response:**
```json
{
  "total_games": 25,
  "total_wins": 14,
  "total_draws": 5,
  "total_losses": 6,
  "multiplayer_games": 12,
  "solo_games": 13,
  "average_game_duration": 3.25,
  "fastest_win_moves": 4,
  "longest_game_moves": 9,
  "stat_date": "2023-04-15"
}
```

#### GET /api/statistics/summary

Retrieve the aggregated game statistics for a given period (default is 30 days).

**Parameters:**
- `period` (optional, integer) - Number of days to include in the summary

**Response:**
```json
{
  "total_games": 1000,
  "total_wins": 600,
  "total_draws": 200,
  "total_losses": 200,
  "multiplayer_games": 400,
  "solo_games": 600,
  "average_game_duration": 4.75,
  "fastest_win_moves": 3,
  "longest_game_moves": 15
}
```

#### GET /api/statistics/weekly

Retrieve the weekly game statistics summary.

**Response:**
```json
[
  {
    "week_start": "2023-04-24",
    "week_end": "2023-04-30",
    "total_games": 150,
    "total_wins": 90,
    "total_draws": 30,
    "total_losses": 30,
    "multiplayer_games": 60,
    "solo_games": 90,
    "average_game_duration": 5.1,
    "fastest_win_moves": 3,
    "longest_game_moves": 12
  },
  {
    "week_start": "2023-04-17",
    "week_end": "2023-04-23",
    "total_games": 180,
    "total_wins": 110,
    "total_draws": 35,
    "total_losses": 35,
    "multiplayer_games": 70,
    "solo_games": 110,
    "average_game_duration": 4.9,
    "fastest_win_moves": 4,
    "longest_game_moves": 14
  },
  // Additional weekly summaries
]
```

#### GET /api/statistics/games

Retrieve a list of the most recent completed games.

**Parameters:**
- `limit` (optional, integer) - Maximum number of games to return (default is 10, maximum is 100)

**Response:**
```json
[
  {
    "id": 123,
    "status": "X_wins",
    "room": {
      "code": "ABC123",
      "players": [
        {
          "name": "Player 1",
          "symbol": "X"
        },
        {
          "name": "Player 2",
          "symbol": "O"
        }
      ]
    }
  },
  {
    "id": 124,
    "status": "draw",
    "room": {
      "code": "DEF456",
      "players": [
        {
          "name": "Player 3",
          "symbol": "X"
        },
        {
          "name": "Player 4",
          "symbol": "O"
        }
      ]
    }
  },
  // Additional recent games
]
```

### Statistics Dashboard

The game statistics and analytics data can be accessed through a web-based dashboard, which provides a user-friendly interface for visualizing and exploring the game metrics.

The dashboard is available at the `/statistics` route and includes the following sections:

- **Daily Statistics**: Displays the current day's game statistics, including total games, wins, losses, draws, game duration, and move efficiency.
- **Summary Analytics**: Shows aggregated statistics for a customizable time period, allowing users to analyze trends and performance over time.
- **Weekly Snapshot**: Provides a weekly summary of game statistics, making it easy to identify patterns and improvements.
- **Recent Games**: Lists the most recent completed games, including the game status, room details, and player information.

The dashboard utilizes various charts and graphs to present the data in an intuitive and visually appealing manner, enabling players and administrators to gain insights into the game's performance and player behavior.

For more information on the game statistics system, please refer to the `docs/STATISTICS.md` file.

## Leaderboard System

The Tic Tac Toe API includes a comprehensive leaderboard system to track player performance and rankings.

### GET /api/leaderboard

Retrieve the leaderboard data.

**Parameters:**
- `type` (optional, string) - The type of leaderboard to retrieve ('wins', 'win_rate', or 'games')
- `limit` (optional, integer) - The maximum number of players to return (default is 10, maximum is 50)

**Response:**
```json
[
  {
    "player_name": "Charlie",
    "wins": 20,
    "losses": 3,
    "draws": 1,
    "total_games": 24,
    "win_rate": 83.33
  },
  {
    "player_name": "Eve",
    "wins": 25,
    "losses": 10,
    "draws": 5,
    "total_games": 40,
    "win_rate": 62.5
  },
  {
    "player_name": "Alice",
    "wins": 15,
    "losses": 5,
    "draws": 2,
    "total_games": 22,
    "win_rate": 68.18
  },
  // Additional leaderboard entries
]
```

The leaderboard data includes the player's name, total wins, losses, draws, total games played, and win rate. The leaderboard can be sorted by different criteria, such as total wins, win rate, or total games played.

### Leaderboard Updates

The leaderboard is automatically updated after each game is completed. The game results are used to update the player's statistics, including their win-loss-draw record and other relevant metrics.

For more information on the leaderboard system implementation, please refer to the `app/models/leaderboard.rb` file.

## Code Changes

The following code changes were made to implement the real-time multiplayer system and the game statistics and analytics features:

1. **Implemented Multiplayer System**:
   - Added WebSocket server implementation in `app/websocket_server.rb`
   - Integrated WebSocket communication with the game API endpoints
   - Handled player connection, disconnection, and game synchronization

2. **Implemented Game Statistics and Analytics**:
   - Added `GameStatistic` model to track game-related metrics
   - Implemented API endpoints for retrieving daily, weekly, and summary statistics
   - Developed the statistics dashboard at the `/statistics` route

3. **Implemented Leaderboard System**:
   - Added `Leaderboard` model to track player performance and rankings
   - Integrated leaderboard updates with the game result updates
   - Implemented API endpoints for retrieving leaderboard data

The code changes are detailed in the commit history and can be reviewed in the respective modified files.