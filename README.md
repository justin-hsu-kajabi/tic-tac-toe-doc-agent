# Tic Tac Toe with AI Documentation Agent

A full-stack tic-tac-toe game built with Ruby/Sinatra and vanilla JavaScript, featuring an integrated AI-powered documentation maintenance system using Anthropic Claude.

## Features

### Game Features
- ✨ Interactive tic-tac-toe gameplay
- 🎮 Clean, responsive web interface
- 🔄 Real-time game state management
- 📊 Game persistence with SQLite
- 📈 Comprehensive game statistics and analytics

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

### Architecture

#### Components

1. **Room Management System** - Handles room creation, player joining, and game coordination
2. **WebSocket Server** - Manages real-time communication between players
3. **Player Session Management** - Tracks player connections and game state
4. **Game State Synchronization** - Ensures both players see the same game state

#### Data Models

##### Room Model

```ruby
class Room < ActiveRecord::Base
  has_many :games, dependent: :destroy
  has_many :players, dependent: :destroy
  
  validates :code, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[waiting active completed] }
end
```

- **Attributes**:
  - `code`: Unique room code
  - `status`: Room status (waiting, active, completed)
  - `max_players`: Maximum number of players per room (default: 2)

##### Player Model

```ruby
class Player < ActiveRecord::Base
  belongs_to :room, optional: true
  
  validates :name, presence: true
  validates :session_id, presence: true, uniqueness: true, allow_nil: true
  validates :symbol, inclusion: { in: %w[X O] }, allow_nil: true
end
```

- **Attributes**:
  - `name`: Player's name
  - `session_id`: Unique session ID for the player
  - `symbol`: Player's symbol in the game (X or O)
  - `wins`, `losses`, `draws`: Player's game statistics

##### Game Model

```ruby
class Game < ActiveRecord::Base
  belongs_to :room, optional: true
  serialize :board, type: Array
  
  before_create :set_game_start_time
  after_update :update_statistics, if: :game_finished?

  def make_move(position, player_session_id = nil)
    # Validate move and update game state
  end
end
```

- **Attributes**:
  - `board`: Serialized game board
  - `current_player`: Current player's symbol (X or O)
  - `status`: Game status (playing, won, drawn)
  - `player_x`, `player_o`: Names of the players
  - `move_count`: Number of moves made in the game
  - `started_at`: Timestamp when the game started
  - `finished_at`: Timestamp when the game ended
  - `game_type`: Type of game (solo or multiplayer)
  - `winner_player`: Symbol of the winning player

### Usage

#### Creating a Room

To create a new multiplayer room, send a POST request to the `/api/rooms` endpoint with the player's name:

```json
{
  "player_name": "Alice"
}
```

The server will respond with the room code, the player's session ID, and the player's symbol:

```json
{
  "room_code": "ABC123",
  "session_id": "abcd1234",
  "player": {
    "name": "Alice",
    "symbol": "X"
  }
}
```

#### Joining a Room

To join an existing room, send a POST request to the `/api/rooms/{code}/join` endpoint with the player's name:

```json
{
  "player_name": "Bob"
}
```

The server will respond with the player's session ID and symbol:

```json
{
  "session_id": "efgh5678",
  "player": {
    "name": "Bob",
    "symbol": "O"
  }
}
```

#### Making a Move

To make a move in the game, send a WebSocket message with the following format:

```json
{
  "type": "move",
  "position": 4,
  "session_id": "abcd1234"
}
```

The server will validate the move and update the game state, then broadcast the updated state to both players.

## Game Statistics System

The Game Statistics system provides comprehensive analytics and tracking for tic-tac-toe gameplay. It automatically captures game metrics, aggregates daily statistics, and provides insights through a real-time dashboard.

### Features

#### 📊 Automatic Data Collection
- **Game Tracking**: Every game automatically records duration, moves, winner, and game type
- **Daily Aggregation**: Statistics are aggregated by date for historical analysis
- **Real-time Updates**: Statistics update immediately when games finish

#### 📈 Comprehensive Metrics
- **Win/Loss/Draw Rates**: Track your success across all game types
- **Game Duration**: Average time spent per game
- **Move Efficiency**: Fastest wins and longest games
- **Game Type Distribution**: Solo vs multiplayer game preferences

#### 🎯 Performance Analytics
- **Success Rates**: Detailed win percentages and trends
- **Speed Metrics**: Track improvement in game completion speed
- **Game Type Preferences**: Understand your preferred game mode

### Usage

#### Accessing Game Statistics
You can access the game statistics through the following API endpoints:

- `GET /api/statistics`: Retrieve the statistics for the current day
- `GET /api/statistics/summary?period=30`: Get a summary of the statistics for the last 30 days
- `GET /api/statistics/weekly`: Retrieve the weekly summary of game statistics
- `GET /api/statistics/games?limit=10`: Get a list of the most recent completed games

The responses from these endpoints will provide you with the relevant statistics and game data to power your analytics dashboard.

### Integration with Game Models
The game statistics are automatically updated when games are created and finished. The `GameStatistic` model handles the aggregation and calculation of the various metrics.

```ruby
class Game < ActiveRecord::Base
  before_create :set_game_start_time
  after_update :update_statistics, if: :game_finished?

  def update_statistics
    GameStatistic.update_for_game(self)
  end
end

class GameStatistic < ActiveRecord::Base
  def self.update_for_game(game)
    # Update various game statistics based on the game data
  end
}
```

## Project Structure

```
tic-tac-toe-app/
├── app/
│   ├── models/
│   │   └── game.rb          # Game logic and state
│   │   └── room.rb          # Room management
│   │   └── player.rb        # Player management
│   │   └── game_statistic.rb # Game statistics management
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
├── public/
│   └── index.html          # Frontend interface
│   └── multiplayer.html    # Multiplayer frontend
│   └── statistics.html     # Game statistics dashboard
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
- Game statistics updates

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