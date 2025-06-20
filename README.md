# Tic Tac Toe with AI Documentation Agent

A full-stack tic-tac-toe game built with Ruby/Sinatra and vanilla JavaScript, featuring an integrated AI-powered documentation maintenance system using Anthropic Claude.

## Features

### Game Features
- ✨ Interactive tic-tac-toe gameplay
- 🎮 Clean, responsive web interface
- 🔄 Real-time game state management
- 📊 Game persistence with SQLite
- 📈 Comprehensive game statistics and analytics
- 🎨 Comprehensive theme system for visual customization

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

## Comprehensive Theme System

The theme system allows users to customize the visual appearance of the tic-tac-toe game. It provides a set of predefined themes, as well as the ability to create and manage custom themes.

### Accessing Themes

The available themes can be accessed through the `/api/themes` endpoint. This will return a list of all the themes, including their name, description, and color scheme.

Example response:
```json
[
  {
    "id": 1,
    "name": "Classic",
    "style_type": "classic",
    "description": "Traditional black and white tic-tac-toe",
    "primary_color": "#333333",
    "secondary_color": "#ffffff",
    "accent_color": "#007bff",
    "board_color": "#f8f9fa",
    "cell_color": "#ffffff",
    "text_color": "#333333",
    "hover_color": "#e9ecef",
    "is_default": true
  },
  {
    "id": 2,
    "name": "Neon Glow",
    "style_type": "neon",
    "description": "Futuristic neon theme with glowing effects",
    "primary_color": "#ff0080",
    "secondary_color": "#00ffff",
    "accent_color": "#ffff00",
    "board_color": "#0a0a0a",
    "cell_color": "#1a1a1a",
    "text_color": "#ffffff",
    "hover_color": "#ff008020",
    "is_default": false
  },
  // More themes...
]
```

### Applying Themes

To apply a theme, you can update the CSS variables in your HTML/CSS to match the theme's color scheme. For example:

```css
:root {
  --theme-primary: #333333;
  --theme-secondary: #ffffff;
  --theme-accent: #007bff;
  --theme-board: #f8f9fa;
  --theme-cell: #ffffff;
  --theme-text: #333333;
  --theme-hover: #e9ecef;
}
```

The CSS variables can then be used throughout your application to style the various elements based on the selected theme.

### Creating Custom Themes

Administrators can create custom themes by adding new entries in the `themes` table. The `Theme` model provides validation and default theme management functionality.

Example of creating a new theme:

```ruby
theme = Theme.new(
  name: "Space Odyssey",
  style_type: "space",
  description: "Cosmic-themed tic-tac-toe experience",
  primary_color: "#0f0f4b",
  secondary_color: "#a9a9b3",
  accent_color: "#ffca3a",
  board_color: "#191923",
  cell_color: "#222232",
  text_color: "#a9a9b3",
  hover_color: "#2b2b3f"
)

if theme.save
  puts "Theme created successfully!"
else
  puts "Error creating theme: #{theme.errors.full_messages.join(", ")}"
end
```

## Multiplayer Tic Tac Toe System

The multiplayer system enables real-time tic-tac-toe gameplay between two players using WebSocket connections and room-based matchmaking. Players can create or join rooms using unique room codes and play against each other with live updates.

See [MULTIPLAYER.md](docs/MULTIPLAYER.md) for detailed documentation on the multiplayer system.

## Game Statistics System

The Game Statistics system provides comprehensive analytics and tracking for tic-tac-toe gameplay. It automatically captures game metrics, aggregates daily statistics, and provides insights through a real-time dashboard.

See [STATISTICS.md](docs/STATISTICS.md) for detailed documentation on the game statistics features.

## Project Structure

```
tic-tac-toe-app/
├── app/
│   ├── models/
│   │   └── game.rb          # Game logic and state
│   │   └── room.rb          # Room management
│   │   └── player.rb        # Player management
│   │   └── game_statistic.rb # Game statistics
│   │   └── theme.rb         # Theme management
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
│   └── THEMES.md           # Theme system documentation
├── public/
│   └── index.html          # Frontend interface
│   └── multiplayer.html    # Multiplayer frontend
│   └── statistics.html     # Statistics dashboard
│   └── themes.html         # Theme selection interface
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

### Theme System

The `Theme` model provides the following functionality:
- Storing and managing theme data, including color schemes and descriptions
- Validating theme attributes
- Handling default theme creation and management

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