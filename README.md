# Tic Tac Toe with AI Documentation Agent

A full-stack tic-tac-toe game built with Ruby/Sinatra and vanilla JavaScript, featuring an integrated AI-powered documentation maintenance system using Anthropic Claude.

## Features

### Game Features
- ✨ Interactive tic-tac-toe gameplay
- 🎮 Clean, responsive web interface
- 🔄 Real-time game state management
- 📊 Game persistence with SQLite
- 📈 Comprehensive game statistics and analytics
- 🏆 Competitive leaderboard system
- 🏅 Achievements unlocking system

### Documentation Agent Features
- 🤖 AI-powered documentation updates
- 📝 Automatic PR analysis and documentation generation
- 🔗 GitHub webhook integration
- 📚 Smart documentation file mapping

## Quick Start

### Prerequisites
- Ruby 3.0+
- Bundler

### Installation

1. Clone and setup:
```bash
cd tic-tac-toe-app
bundle install
```

2. Setup database:
```bash
bundle exec rake db:migrate
```

3. Set environment variables:
```bash
cp .env.example .env
# Edit .env with your API keys
```

4. Start the server:
```bash
bundle exec rackup
```

5. Open http://localhost:9292 in your browser

## API Documentation

See [API.md](docs/API.md) for complete API documentation.

## Documentation Agent

The integrated documentation agent automatically:

1. **Monitors PRs** via GitHub webhooks
2. **Analyzes code changes** using AI
3. **Updates documentation** automatically
4. **Creates PRs** with documentation updates

### Setup Documentation Agent

1. Set environment variables:
```bash
GITHUB_TOKEN=your_github_token
ANTHROPIC_API_KEY=your_anthropic_api_key
GITHUB_REPOSITORY=username/repo-name
```

2. Configure GitHub webhook:
   - URL: `https://yourdomain.com/webhook/github`
   - Events: Pull requests
   - Content type: application/json

## Multiplayer Tic Tac Toe System

The multiplayer system enables real-time tic-tac-toe gameplay between two players using WebSocket connections and room-based matchmaking. Players can create or join rooms using unique room codes and play against each other with live updates.

See [MULTIPLAYER.md](docs/MULTIPLAYER.md) for detailed documentation on the multiplayer system.

## Game Statistics System

The Game Statistics system provides comprehensive analytics and tracking for tic-tac-toe gameplay. It automatically captures game metrics, aggregates daily statistics, and provides insights through a real-time dashboard.

See [STATISTICS.md](docs/STATISTICS.md) for detailed documentation on the game statistics features.

## Competitive Leaderboard System

The Leaderboard system enables players to compete against each other in a ranking-based system. Players' performance is tracked, and their wins, losses, and other metrics are used to calculate their position on the leaderboard. The leaderboard is displayed on a dedicated page, allowing players to see their standings and compare their performance to others.

### Leaderboard Features

- 📊 Displays overall player rankings based on wins, losses, and total games played
- 🔥 Tracks current and best win streaks for each player
- ⚡ Records the fastest win (in number of moves) for each player
- 🗓️ Shows the date of each player's last game

### Leaderboard API

You can access the leaderboard data through the following API endpoint:

```
GET /api/leaderboard?type=wins&limit=10
```

The `type` parameter specifies the leaderboard type (default is 'wins'), and the `limit` parameter sets the maximum number of results to return (default is 10, maximum is 50).

The response will be a JSON object with the following structure:

```json
{
  "leaderboard": [
    {
      "player_name": "Charlie",
      "total_games": 24,
      "wins": 20,
      "losses": 3,
      "draws": 1,
      "current_win_streak": 7,
      "best_win_streak": 12,
      "fastest_win_moves": 3,
      "last_game_at": "2023-04-15T18:30:00Z"
    },
    {
      "player_name": "Eve",
      "total_games": 40,
      "wins": 25,
      "losses": 10,
      "draws": 5,
      "current_win_streak": 3,
      "best_win_streak": 8,
      "fastest_win_moves": 4,
      "last_game_at": "2023-04-14T20:45:00Z"
    },
    // Additional leaderboard entries...
  ]
}
```

## Achievements System

The Achievements system rewards players for accomplishing specific milestones or performing well in the game. When a player meets the criteria for an achievement, it is automatically unlocked and added to their profile.

### Available Achievements

- **First Victory**: Win your first game
- **Streak Master**: Win 5 games in a row
- **Speed Demon**: Win a game in 3 moves
- **Undefeated Champion**: Win 10 games without a loss
- **Comeback King**: Win a game after being down 0-2
- **Game Master**: Win 100 games

### Achievements API

You can retrieve a player's unlocked achievements through the following API endpoint:

```
GET /api/achievements?player_name=Alice
```

The response will be a JSON object with the following structure:

```json
{
  "achievements": [
    {
      "player_name": "Alice",
      "achievement_type": "first_win",
      "title": "First Victory",
      "description": "Win your first game",
      "icon": "🎉",
      "earned_at": "2023-04-01T12:34:56Z"
    },
    {
      "player_name": "Alice",
      "achievement_type": "speed_demon",
      "title": "Speed Demon",
      "description": "Win a game in 3 moves",
      "icon": "⚡",
      "earned_at": "2023-04-10T15:20:00Z"
    },
    // Additional achievements...
  ]
}
```

## Development

### Running Tests
```bash
bundle exec rake test
```

### Game Logic

The `Game` model handles:
- Move validation
- Win condition checking
- Game state transitions
- Board serialization
- Game statistics tracking
- Leaderboard and achievement updates

### Documentation Agent Architecture

1. **WebhookHandler** processes GitHub PR events
2. **PRAnalyzer** identifies significant code changes
3. **DocFinder** maps changes to relevant documentation
4. **DocUpdater** generates updated content using Anthropic Claude AI

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. The documentation agent will automatically update docs when you create a PR!

## License

MIT License