class Theme < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :style_type, inclusion: { in: %w[classic neon retro space ocean] }

  PREDEFINED_THEMES = {
    'classic' => {
      name: 'Classic',
      description: 'Traditional black and white tic-tac-toe',
      primary_color: '#333333',
      secondary_color: '#ffffff',
      accent_color: '#007bff',
      board_color: '#f8f9fa',
      cell_color: '#ffffff',
      text_color: '#333333',
      hover_color: '#e9ecef'
    },
    'neon' => {
      name: 'Neon Glow',
      description: 'Futuristic neon theme with glowing effects',
      primary_color: '#ff0080',
      secondary_color: '#00ffff',
      accent_color: '#ffff00',
      board_color: '#0a0a0a',
      cell_color: '#1a1a1a',
      text_color: '#ffffff',
      hover_color: '#ff008020'
    },
    'retro' => {
      name: 'Retro Gaming',
      description: 'Nostalgic 8-bit inspired theme',
      primary_color: '#8b4513',
      secondary_color: '#daa520',
      accent_color: '#ff6347',
      board_color: '#f5deb3',
      cell_color: '#fff8dc',
      text_color: '#8b4513',
      hover_color: '#daa52030'
    },
    'space' => {
      name: 'Space Explorer',
      description: 'Deep space theme with cosmic colors',
      primary_color: '#4b0082',
      secondary_color: '#9400d3',
      accent_color: '#ff69b4',
      board_color: '#191970',
      cell_color: '#483d8b',
      text_color: '#ffffff',
      hover_color: '#9400d340'
    },
    'ocean' => {
      name: 'Ocean Depths',
      description: 'Calming underwater theme',
      primary_color: '#006994',
      secondary_color: '#20b2aa',
      accent_color: '#00ced1',
      board_color: '#e0f6ff',
      cell_color: '#f0f8ff',
      text_color: '#006994',
      hover_color: '#20b2aa30'
    }
  }.freeze

  def self.create_default_themes
    PREDEFINED_THEMES.each do |style_type, attributes|
      find_or_create_by(style_type: style_type) do |theme|
        theme.name = attributes[:name]
        theme.description = attributes[:description]
        theme.primary_color = attributes[:primary_color]
        theme.secondary_color = attributes[:secondary_color]
        theme.accent_color = attributes[:accent_color]
        theme.board_color = attributes[:board_color]
        theme.cell_color = attributes[:cell_color]
        theme.text_color = attributes[:text_color]
        theme.hover_color = attributes[:hover_color]
        theme.is_default = (style_type == 'classic')
      end
    end
  end

  def self.default_theme
    find_by(is_default: true) || find_by(style_type: 'classic')
  end

  def to_css_variables
    {
      '--theme-primary': primary_color,
      '--theme-secondary': secondary_color,
      '--theme-accent': accent_color,
      '--theme-board': board_color,
      '--theme-cell': cell_color,
      '--theme-text': text_color,
      '--theme-hover': hover_color
    }
  end

  def css_variable_string
    to_css_variables.map { |var, value| "#{var}: #{value}" }.join('; ')
  end
end