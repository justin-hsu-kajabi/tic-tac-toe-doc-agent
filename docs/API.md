# Tic Tac Toe API Documentation

## Overview

This API provides endpoints for managing tic-tac-toe games. Players can create new games, make moves, and retrieve game state.

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