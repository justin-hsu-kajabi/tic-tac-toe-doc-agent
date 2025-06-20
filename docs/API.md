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