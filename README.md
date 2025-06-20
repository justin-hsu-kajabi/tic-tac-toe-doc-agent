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

## Leaderboard System

The Leaderboard system allows players to compete against each other and track their performance. The leaderboard displays the top players based on various metrics, such as total wins, win rate, and total games played.

### Leaderboard API

- `GET /api/leaderboard?type=wins&limit=10`: Retrieve the top 10 players by total wins.
- `GET /api/leaderboard?type=win_rate&limit=10`: Retrieve the top 10 players by win rate.
- `GET /api/leaderboard?type=games&limit=10`: Retrieve the top 10 players by total games played.

The `type` parameter can be one of `wins`, `win_rate`, or `games`, and the `limit` parameter specifies the maximum number of results to return (up to 50).

### Leaderboard UI

The leaderboard is also accessible through the `/leaderboard.html` page, which provides a user-friendly interface to view and interact with the leaderboard data.

## Project Structure

```
tic-tac-toe-app/
├── app/
│   ├── models/
│   │   └── game.rb          # Game logic and state
│   │   └── room.rb          # Room management
│   │   └── player.rb        # Player management
│   │   └── game_statistic.rb # Game statistics
│   │   └── leaderboard.rb   # Leaderboard management
│   └── application.rb       # Main Sinatra application
│   └── websocket_server.rb  # WebSocket server
├── doc-agent/
│   └── src/
│       ├── webhook_handler.rb  # GitHub webhook processing
│       ├── pr_analyzer.rb      # PR analysis logic
│       ├── doc_finder.rb       # Documentation file discovery
│       └── doc_updater.rb      # AI documentation generation
├── docs/
│   └── API.md              # API documentation
│   └── MULTIPLAYER.md      # Multiplayer system documentation
│   └── STATISTICS.md       # Game statistics documentation
│   └── LEADERBOARD.md      # Leaderboard system documentation
├── public/
│   └── index.html          # Frontend interface
│   └── multiplayer.html    # Multiplayer frontend
│   └── statistics.html     # Statistics dashboard
│   └── leaderboard.html    # Leaderboard frontend
└── db/
    └── migrate/            # Database migrations
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
- Leaderboard updates

### Leaderboard System

The `Leaderboard` model provides the following functionality:
- Tracking player performance metrics (wins, losses, draws, total games)
- Maintaining win streaks and fastest win records
- Efficient retrieval of leaderboard data by various criteria (wins, win rate, total games)
- Automatic updates when new games are completed

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