# IMPORTANT!!
# If you are using Roaming Pokémon, it is necessary to add
# next if $game_temp.overworld_encounter
# after each mention of: next if $PokemonGlobal.roamedAlready
# otherwise Overworld Encounters can trigger Roaming Battles

# To define Overworld Encounters all you have to do is add
# empty events to your map with the name "OverworldPkmn"
# Toggle "Stop Animation" and make sure the trigger is set
# to "Action Button". Then add a script line to the event
# commands with: "pbInteractOverworldEncounter".
# Copy this event a few times on your map and done!
# (I recommend to only put 4-6 Overworld Encounters on each map)

class VoltseonsOverworldEncounters
  # The animation that plays when an encounter spawns / flees.
  SPAWN_ANIMATION = 2
  # Sound Effect that plays when an encounter flees.
  FLEE_SOUND = "Door exit"
  # Terrain Tag ids for grass tiles.
  GRASS_TILES = [:Grass, :TallGrass, :DeepSand]
  # Animation that plays for a shiny encounter.
  SHINY_ANIMATION = 7
  # Sound Effect that plays for a shiny encounter.
  SHINY_SOUND = "Mining reveal full"
  # Chance at which the Pokémon is shiny. Use 0 to disable overworld shinies. Set to (SETTINGS::SHINY_POKEMON_CHANCE / 65536) for normal odds.
  SHINY_RATE = 512
  # Whether the game should log when an encounter is being spawned / despawned (this can only be seen in Debug Mode).
  LOG_SPAWNS = true
  # If the option is enabled for the player to disable Overworld Encounters in the game settings.
  DISABLE_SETTINGS = true
end

MenuHandlers.add(:options_menu, :owpkmnenabled, {
  "name"        => _INTL("Overworld Encounters"),
  "order"       => 100,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Enable/disable overworld encounters."),
  "condition" => VoltseonsOverworldEncounters::DISABLE_SETTINGS,
  "get_proc"    => proc { next $PokemonSystem.owpkmnenabled },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.owpkmnenabled = value }
})

class PokemonSystem
  attr_accessor :owpkmnenabled # Whether Overworld Pokémon appear (0=on, 1=off)

  def owpkmnenabled
    @owpkmnenabled = 0 if !@owpkmnenabled
    return @owpkmnenabled
  end
end

class PokemonOption_Scene
  alias owpkmn_pbEndScene pbEndScene unless method_defined?(:owpkmn_pbEndScene)

  def pbEndScene
    owpkmn_pbEndScene
    if $PokemonSystem.owpkmnenabled==1 && $PokemonEncounters && VoltseonsOverworldEncounters::DISABLE_SETTINGS
      $game_map.events.each_value do |event|
        next unless event.name[/OverworldPkmn/i]
        pbDistroyOverworldEncounter(event, true, false)
      end
    end
  end
end