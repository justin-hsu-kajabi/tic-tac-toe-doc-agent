# Setup Instructions

## Database Migrations

To enable all features including statistics, run the database migrations:

```bash
# Install dependencies
bundle install

# Run database migrations
bundle exec rake db:migrate

# Start the server
bundle exec ruby app/application.rb
```

## Available Migrations

1. **001_create_games.rb** - Basic game table
2. **002_create_rooms.rb** - Room management for multiplayer
3. **003_create_players.rb** - Player sessions
4. **004_add_room_to_games.rb** - Link games to rooms
5. **005_create_game_statistics.rb** - Daily statistics aggregation
6. **006_add_statistics_to_games.rb** - Game tracking fields

## Backward Compatibility

The application is designed to work without running migrations:
- Core game functionality works with just the basic games table
- Statistics features gracefully degrade if migrations aren't run
- API endpoints return helpful error messages when features are unavailable

## Features by Migration Status

### Without Migrations (Basic)
- ✅ Solo tic-tac-toe gameplay
- ✅ Basic game creation and moves
- ❌ Multiplayer rooms
- ❌ Statistics tracking
- ❌ Performance analytics

### With All Migrations (Full)
- ✅ Solo tic-tac-toe gameplay
- ✅ Multiplayer with real-time WebSocket
- ✅ Comprehensive statistics tracking
- ✅ Performance analytics dashboard
- ✅ Game history and metrics