```markdown
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

## Documentation Updates

The documentation update process is handled by a custom "doc agent" that automatically updates the documentation based on changes in the codebase. The doc agent uses the Anthropic API to generate the updated documentation content.

The doc agent is triggered by pull requests (PRs) to the codebase. When a PR is opened, the doc agent analyzes the changes and generates an updated version of the documentation. The updated documentation is then included in the PR for review and merging.

The doc agent's behavior can be customized using the following environment variables:

- `ANTHROPIC_API_KEY`: The API key for the Anthropic service, used to generate the updated documentation content.
- `GEMINI_API_KEY`: The API key for the Gemini service, used for additional functionality (not currently implemented).

The doc agent skips documentation-only PRs created by the agent itself to avoid an infinite loop of updates.

```