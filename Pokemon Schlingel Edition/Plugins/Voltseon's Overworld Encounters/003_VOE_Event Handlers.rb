def pbGenerateOverworldEncounters
  return if $scene.is_a?(Scene_Intro) || $scene.is_a?(Scene_DebugIntro)
  return if !$PokemonEncounters
  return if $player.able_pokemon_count == 0
  return if $PokemonGlobal.surfing
  $game_map.events.each_value do |event|
    next unless event.name[/OverworldPkmn/i]
    next unless event.variable.nil?
    tile = get_grass_tile
    next if tile == []
    enc_type = $PokemonEncounters.encounter_type
    enc_type = $PokemonEncounters.find_valid_encounter_type_for_time(:Land, pbGetTimeNow) if enc_type.nil?
    next if enc_type.nil?
    next if rand(3) == 1
    pkmn = $PokemonEncounters.choose_wild_pokemon(enc_type)
    echoln "Spawning #{pkmn.name}" if VoltseonsOverworldEncounters::LOG_SPAWNS
    pkmn = Pokemon.new(pkmn[0],pkmn[1])
    pkmn.level = (pkmn.level + rand(-2..2)).clamp(2,GameData::GrowthRate.max_level)
    new_evo_mon = pbCheckEvolveDevolve(pkmn.species, pkmn.level)
    pkmn.species = new_evo_mon[0]
    pkmn.calc_stats
    pkmn.reset_moves
    pkmn.shiny = rand(VoltseonsOverworldEncounters::SHINY_RATE) == 1
    event.moveto(tile[0], tile[1])
    event.setVariable(pkmn)
    spriteset = $scene.spriteset($game_map.map_id)
    dist = (((event.x - $game_player.x).abs + (event.y - $game_player.y).abs) / 4).floor
    if pkmn.shiny?
      pbSEPlay(VoltseonsOverworldEncounters::SHINY_SOUND, [75, 65, 55, 40, 27, 22, 15][dist], 100) if dist <= 6 && dist >= 0
      spriteset&.addUserAnimation(VoltseonsOverworldEncounters::SHINY_ANIMATION, event.x, event.y, true, 1)
    end
    pbChangeEventSprite(event,pkmn)
    event.direction = rand(1..4) * 2
    event.through = false
    spriteset&.addUserAnimation(VoltseonsOverworldEncounters::SPAWN_ANIMATION, event.x, event.y, true, 1)
    GameData::Species.play_cry_from_pokemon(pkmn, [75, 65, 55, 40, 27, 22, 15][dist]*($PokemonSystem.owpkmn_volume/100)) if dist <= 6 && dist >= 0 && rand(20) == 1
    break if rand(2) == 1
  end
end

EventHandlers.add(:on_enter_map, :clear_previous_overworld_encounters,
  proc { |old_map_id|
    next if $game_map.map_id < 2
    next if old_map_id.nil? || old_map_id < 2
    next unless $MapFactory
    map = $MapFactory.getMapNoAdd(old_map_id)
    map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      pbDestroyOverworldEncounter(event, true, false)
    end
    pbGenerateOverworldEncounters
  }
)

EventHandlers.add(:on_new_spriteset_map, :fix_exisitng_overworld_encounters,
  proc {
    next if $game_map.map_id < 2
    next if !$PokemonEncounters
    $game_map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      pkmn = event.variable
      next if pkmn.nil?
      pbChangeEventSprite(event,pkmn)
    end
  }
)

EventHandlers.add(:on_frame_update, :move_overworld_encounters,
  proc {
    next if $game_map.map_id < 2
    next if VoltseonsOverworldEncounters::DISABLE_SETTINGS && $PokemonSystem.owpkmnenabled==1
    next if $game_temp.in_menu
    next if !$PokemonEncounters
    $game_temp.frames_updated += 1
    next if $game_temp.frames_updated < 100
    $game_temp.frames_updated = 0
    $game_map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      next if event.variable.nil?
      pbPokemonIdle(event)
    end
    next unless rand(8) == 1
    pbGenerateOverworldEncounters
  }
)