# Application Features

## Player Management

The `Player` model represents a player in the game. It has the following attributes:

- `name`: The name of the player (required and unique)
- `wins`: The number of wins for the player (default 0, must be >= 0)
- `losses`: The number of losses for the player (default 0, must be >= 0)
- `draws`: The number of draws for the player (default 0, must be >= 0)

The `Player` model provides the following methods:

- `total_games`: Returns the total number of games played by the player.
- `win_rate`: Calculates the win rate of the player as a percentage.
- `record_win!`: Increments the player's wins by 1.
- `record_loss!`: Increments the player's losses by 1.
- `record_draw!`: Increments the player's draws by 1.

Example usage:

```ruby
player = Player.create(name: "John Doe")
player.record_win!
player.record_loss!
player.record_draw!

puts player.total_games # Output: 3
puts player.win_rate # Output: 33.33
```

## Real-Time Multiplayer System

The application now includes a real-time multiplayer system, allowing two players to play tic-tac-toe against each other in real-time.

### Multiplayer Architecture

The multiplayer system consists of the following components:

1. **Room Management System**: Handles the creation, joining, and management of game rooms.
2. **WebSocket Server**: Manages the real-time communication between players using WebSocket connections.
3. **Player Session Management**: Tracks player connections and game state for each player.
4. **Game State Synchronization**: Ensures that both players see the same game state during the match.

### Key Features

#### Room Management

- Players can create a new room by providing their player name.
- Each room has a unique room code that can be shared with other players to join the game.
- Rooms have a status of "waiting", "active", or "completed".
- Rooms can accommodate up to 2 players.

#### Player Management

- Players are represented by the `Player` model, which has a `name`, `session_id`, and `symbol` (either "X" or "O").
- Players are associated with a specific room and can have an opponent in the same room.
- Players can check if it's their turn to make a move in the current game.

#### Game State Synchronization

- When a player makes a move, the game state is updated and broadcast to both players in real-time.
- The `Game` model tracks the current state of the game board and the current player.
- Moves are validated to ensure that only the player whose turn it is can make a move.

### Usage Examples

#### Creating a New Room

```javascript
// Create a new room with the player name "John Doe"
fetch('/api/rooms', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ player_name: 'John Doe' })
})
.then(response => response.json())
.then(data => {
  console.log('Room created:', data.room_code);
  console.log('Your session ID:', data.session_id);
  console.log('Your player details:', data.player);
})
.catch(error => console.error('Error creating room:', error));
```

#### Joining an Existing Room

```javascript
// Join an existing room with the room code "ABCD" and player name "Jane Doe"
fetch('/api/rooms/ABCD/join', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ player_name: 'Jane Doe' })
})
.then(response => response.json())
.then(data => {
  console.log('Joined room:', data.room_code);
  console.log('Your session ID:', data.session_id);
  console.log('Your player details:', data.player);
})
.catch(error => console.error('Error joining room:', error));
```

## Game Statistics and Analytics System

The Game Statistics system provides comprehensive analytics and tracking for tic-tac-toe gameplay. It automatically captures game metrics, aggregates daily statistics, and provides insights through a real-time dashboard.

### Automatic Data Collection

- **Game Tracking**: Every game automatically records duration, moves, winner, and game type.
- **Daily Aggregation**: Statistics are aggregated by date for historical analysis.
- **Real-time Updates**: Statistics update immediately when games finish.

### Comprehensive Metrics

- **Win/Loss/Draw Rates**: Track your success across all game types.
- **Game Duration**: Average time spent per game.
- **Move Efficiency**: Fastest wins and longest games.
- **Game Type Distribution**: Solo vs multiplayer game preferences.

### Performance Analytics

- **Success Rates**: Detailed win percentages and trends.
- **Speed Metrics**: Track improvement in game completion speed.

### Usage

#### Accessing the Statistics Dashboard

You can access the game statistics dashboard by navigating to the `/statistics` route in your web browser.

#### Retrieving Statistics via API

The application provides the following API endpoints to access game statistics:

```
GET /api/statistics
```
Returns the current day's game statistics.

```
GET /api/statistics/summary
```
Returns a summary of game statistics for the last 30 days.

```
GET /api/statistics/weekly
```
Returns weekly summary statistics.

```
GET /api/statistics/games
```
Returns recent completed games.

Example usage:

```javascript
// Fetch daily statistics
fetch('/api/statistics')
  .then(response => response.json())
  .then(data => {
    console.log('Daily Statistics:', data);
  })
  .catch(error => console.error('Error fetching daily statistics:', error));

// Fetch 30-day summary
fetch('/api/statistics/summary?period=30')
  .then(response => response.json())
  .then(data => {
    console.log('Statistics Summary:', data);
  })
  .catch(error => console.error('Error fetching statistics summary:', error));

// Fetch weekly summary statistics
fetch('/api/statistics/weekly')
  .then(response => response.json())
  .then(data => {
    console.log('Weekly Statistics:', data);
  })
  .catch(error => console.error('Error fetching weekly statistics:', error));

// Fetch the 10 most recent games
fetch('/api/statistics/games?limit=10')
  .then(response => response.json())
  .then(data => {
    console.log('Recent Games:', data);
  })
  .catch(error => console.error('Error fetching recent games:', error));
```

## Comprehensive Leaderboard System for Competitive Gameplay

The application now includes a comprehensive leaderboard system to track player performance and rankings for competitive gameplay.

### Leaderboard Features

- **Player Ranking**: Players are ranked based on their total wins, win rate, and total games played.
- **Streak Tracking**: The system tracks each player's current and best win streaks.
- **Fastest Wins**: The leaderboard includes information on the fastest wins (fewest moves).
- **Last Game Played**: The date of each player's last game is recorded.

### Leaderboard API

The application provides the following API endpoints to access the leaderboard:

```
GET /api/leaderboard
```
Returns the top players based on a specified metric (wins, win rate, or total games).

Example usage:

```javascript
// Fetch the top 10 players by wins
fetch('/api/leaderboard?type=wins&limit=10')
  .then(response => response.json())
  .then(data => {
    console.log('Top Players by Wins:', data);
  })
  .catch(error => console.error('Error fetching leaderboard:', error));

// Fetch the top 10 players by win rate
fetch('/api/leaderboard?type=win_rate&limit=10')
  .then(response => response.json())
  .then(data => {
    console.log('Top Players by Win Rate:', data);
  })
  .catch(error => console.error('Error fetching leaderboard:', error));

// Fetch the top 10 players by total games played
fetch('/api/leaderboard?type=games&limit=10')
  .then(response => response.json())
  .then(data => {
    console.log('Top Players by Total Games:', data);
  })
  .catch(error => console.error('Error fetching leaderboard:', error));
```

### Leaderboard Integration

The leaderboard system is integrated with the game engine, automatically updating player statistics after each completed game. This ensures that the leaderboard reflects the most up-to-date player performance.

## Documentation Updates

The documentation update process is handled by a custom "doc agent" that automatically updates the documentation based on changes in the codebase. The doc agent uses the Anthropic API to generate the updated documentation content.

The doc agent is triggered by pull requests (PRs) to the codebase. When a PR is opened, the doc agent analyzes the changes and generates an updated version of the documentation. The updated documentation is then included in the PR for review and merging.

The doc agent's behavior can be customized using the following environment variables:

- `ANTHROPIC_API_KEY`: The API key for the Anthropic service, used to generate the updated documentation content.
- `GEMINI_API_KEY`: The API key for the Gemini service, used for additional functionality (not currently implemented).

The doc agent skips documentation-only PRs created by the agent itself to avoid an infinite loop of updates. It now generates a single consolidated PR with all documentation updates, instead of creating a separate PR for each documentation file.