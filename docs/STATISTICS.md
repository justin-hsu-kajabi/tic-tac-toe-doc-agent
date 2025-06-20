# Game Statistics System

## Overview

The Game Statistics system provides comprehensive analytics and tracking for tic-tac-toe gameplay. It automatically captures game metrics, aggregates daily statistics, and provides insights through a real-time dashboard.

## Features

### 📊 Automatic Data Collection
- **Game Tracking**: Every game automatically records duration, moves, winner, and game type
- **Daily Aggregation**: Statistics are aggregated by date for historical analysis
- **Real-time Updates**: Statistics update immediately when games finish

### 📈 Comprehensive Metrics
- **Win/Loss/Draw Rates**: Track your success across all game types
- **Game Duration**: Average time spent per game
- **Move Efficiency**: Fastest wins and longest games
- **Game Type Distribution**: Solo vs multiplayer game preferences

### 🎯 Performance Analytics
- **Success Rates**: Detailed win percentages and trends
- **Speed Metrics**: Track improvement in game completion time
- **Efficiency Tracking**: Monitor moves-to-win ratios
- **Historical Data**: 30-day rolling statistics with weekly summaries

## Data Models

### GameStatistic Model
Stores daily aggregated statistics:

```ruby
class GameStatistic < ActiveRecord::Base
  # Daily metrics
  - total_games: Integer
  - total_wins: Integer  
  - total_draws: Integer
  - total_losses: Integer
  - multiplayer_games: Integer
  - solo_games: Integer
  
  # Performance metrics
  - average_game_duration: Float (minutes)
  - fastest_win_moves: Integer
  - longest_game_moves: Integer
  
  # Date tracking
  - stat_date: Date (unique per day)
end
```

### Enhanced Game Model
Extended with statistics tracking:

```ruby
class Game < ActiveRecord::Base
  # New statistics fields
  - move_count: Integer
  - started_at: DateTime
  - finished_at: DateTime
  - game_type: String ('solo' or 'multiplayer')
  - winner_player: String
  
  # Automatic callbacks
  - before_create: :set_game_start_time
  - after_update: :update_statistics
end
```

## API Endpoints

### Get Today's Statistics
```http
GET /api/statistics
```

**Response:**
```json
{
  "total_games": 15,
  "total_wins": 8,
  "total_draws": 3,
  "total_losses": 4,
  "multiplayer_games": 10,
  "solo_games": 5,
  "average_game_duration": 2.5,
  "fastest_win_moves": 5,
  "longest_game_moves": 9,
  "stat_date": "2024-06-20"
}
```

### Get Period Summary
```http
GET /api/statistics/summary?period=30
```

**Parameters:**
- `period`: Number of days to include (default: 30)

**Response:**
```json
{
  "total_games": 150,
  "total_wins": 75,
  "total_draws": 30,
  "total_losses": 45,
  "multiplayer_games": 100,
  "solo_games": 50,
  "average_duration": 2.8,
  "fastest_win": 5,
  "longest_game": 12
}
```

### Get Weekly Breakdown
```http
GET /api/statistics/weekly
```

**Response:**
```json
[
  {
    "stat_date": "2024-06-14",
    "total_games": 12,
    "total_wins": 6,
    // ... other daily stats
  },
  // ... 7 days of data
]
```

### Get Recent Games
```http
GET /api/statistics/games?limit=10
```

**Parameters:**
- `limit`: Number of games to return (max: 100, default: 10)

**Response:**
```json
[
  {
    "id": 123,
    "status": "X_wins",
    "winner": "X",
    "game_type": "multiplayer",
    "move_count": 7,
    "duration_minutes": 3.2,
    "finished_at": "2024-06-20T15:30:00Z"
  }
  // ... more games
]
```

## Statistics Dashboard

### Features
- **Real-time Updates**: Refreshes every 30 seconds
- **Visual Progress Bars**: Win/loss ratios and game type distribution  
- **Recent Games List**: Last 10 completed games with details
- **Performance Metrics**: Key statistics at a glance

### Key Metrics Displayed
1. **Total Games Played**
2. **Win Rate Percentage**
3. **Fastest Win (moves)**
4. **Average Game Duration**
5. **Game Type Distribution**
6. **Win/Loss/Draw Breakdown**
7. **Recent Game History**

### Navigation
Access the statistics dashboard at `/statistics.html` or via the "View Statistics" button on the main page.

## Automatic Statistics Collection

### Game Lifecycle Tracking
1. **Game Start**: Records `started_at` timestamp and determines `game_type`
2. **Each Move**: Increments `move_count`
3. **Game End**: Records `finished_at`, `winner_player`, and triggers statistics update

### Daily Aggregation
- Statistics are automatically aggregated daily using the `GameStatistic.update_for_game` method
- Calculates rolling averages for game duration
- Tracks fastest wins and longest games
- Updates win/loss/draw counts

### Performance Considerations
- Statistics are calculated asynchronously after game completion
- Daily aggregation prevents expensive real-time calculations
- Efficient database queries with proper indexing

## Usage Examples

### View Your Performance
1. Navigate to `/statistics.html`
2. View your win rate, average game time, and recent performance
3. Track improvement over time with historical data

### Compare Game Types
- See how you perform in solo vs multiplayer games
- Analyze different playing patterns and strategies

### Monitor Progress
- Track fastest wins to see strategic improvement
- Monitor average game duration for efficiency gains
- Review recent games to identify patterns

## Technical Implementation

### Database Schema
```sql
-- Game statistics table
CREATE TABLE game_statistics (
  id SERIAL PRIMARY KEY,
  total_games INTEGER DEFAULT 0,
  total_wins INTEGER DEFAULT 0,
  total_draws INTEGER DEFAULT 0,
  total_losses INTEGER DEFAULT 0,
  multiplayer_games INTEGER DEFAULT 0,
  solo_games INTEGER DEFAULT 0,
  average_game_duration FLOAT DEFAULT 0.0,
  fastest_win_moves INTEGER,
  longest_game_moves INTEGER DEFAULT 0,
  stat_date DATE NOT NULL UNIQUE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Enhanced games table
ALTER TABLE games ADD COLUMN move_count INTEGER DEFAULT 0;
ALTER TABLE games ADD COLUMN started_at TIMESTAMP;
ALTER TABLE games ADD COLUMN finished_at TIMESTAMP;
ALTER TABLE games ADD COLUMN game_type VARCHAR(20) DEFAULT 'solo';
ALTER TABLE games ADD COLUMN winner_player VARCHAR(1);
```

### Key Methods

**Statistics Update:**
```ruby
def self.update_for_game(game)
  stat = today
  stat.total_games += 1
  # ... update various metrics
  stat.save!
end
```

**Performance Calculations:**
```ruby
def win_rate
  return 0.0 if total_games == 0
  (total_wins.to_f / total_games * 100).round(2)
end
```

## Future Enhancements

### Planned Features
- **Player Profiles**: Individual statistics tracking
- **Leaderboards**: Competitive rankings
- **Achievement System**: Unlockable badges and milestones
- **Advanced Analytics**: Move pattern analysis
- **Export Options**: CSV/PDF reports

### Performance Optimizations
- **Caching**: Redis cache for frequently accessed statistics
- **Background Jobs**: Async statistics processing
- **Data Archival**: Historical data compression
- **Real-time Updates**: WebSocket integration for live statistics

## Troubleshooting

### Common Issues
1. **Missing Statistics**: Ensure games are completing properly with `finished_at` timestamps
2. **Incorrect Aggregation**: Check that `GameStatistic.update_for_game` is being called
3. **Performance Issues**: Monitor database query performance on statistics endpoints

### Debugging
- Check Rails logs for statistics update errors
- Verify database migrations have been run
- Ensure proper model associations are loaded