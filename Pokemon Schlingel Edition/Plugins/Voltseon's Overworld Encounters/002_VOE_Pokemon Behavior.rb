def pbInteractOverworldEncounter
  return if $PokemonGlobal.bridge>0
  $game_temp.overworld_encounter = true
  evt = pbMapInterpreter.get_self
  evt.lock
  pkmn = evt.variable
  return pbDestroyOverworldEncounter(evt) if pkmn.nil?
  GameData::Species.play_cry_from_pokemon(pkmn)
  name = pkmn.name
  name_half = (name.length.to_f / 2).ceil
  textcol = (pkmn.genderless?) ? "" : (pkmn.male?) ? "\\b" : "\\r"
  pbMessage(_INTL("{1}{2}!",textcol,name[0,name_half]+name[name_half]+name[name_half]))
  decision = WildBattle.start(pkmn)
  $game_temp.overworld_encounter = false
  pbDestroyOverworldEncounter(evt,decision == 4,decision != 4)
end

def pbTrainersSeePkmn
  result = false
  # If event is running
  return result if $game_system.map_interpreter.running?
  # All event loops
  $game_map.events.each_value do |event|
    next if !event.name[/trainer\((\d+)\)/i] && !event.name[/sight\((\d+)\)/i]
    distance = $~[1].to_i
    next if !pbEventCanReachPlayer?(event, self, distance)
    next if event.jumping? || event.over_trigger?
    result = true
  end
  return result
end

def get_grass_tile
  tile = []
  500.times do
    x = rand([$game_player.x-8,0].max...[$game_player.x+8,$game_map.width].max)
    y = rand([$game_player.y-8,0].max...[$game_player.y+8,$game_map.height].max)
    next if (x-$game_player.x).abs < 1
    next if (y-$game_player.y).abs < 1
    if (VoltseonsOverworldEncounters::GRASS_TILES.include?($game_map.terrain_tag(x, y).id) || $PokemonEncounters.has_cave_encounters?) && $game_map.passable?(x, y, 0) && !$game_map.check_event(x,y)
      tile = [x, y]
      break
    end
  end
  return tile
end

def pbDestroyOverworldEncounter(event,animation=true,play_sound=false)
  return if $scene.is_a?(Scene_Intro) || $scene.is_a?(Scene_DebugIntro)
  echoln "Despawning #{pkmn.name}" if VoltseonsOverworldEncounters::LOG_SPAWNS
  if play_sound
    dist = (((event.x - $game_player.x).abs + (event.y - $game_player.y).abs) / 4).floor
    pbSEPlay(VoltseonsOverworldEncounters::FLEE_SOUND, [75, 65, 55, 40, 27, 22, 15][dist], 150) if dist <= 6 && dist >= 0
  end
  spriteset = $scene.spriteset($game_map.map_id)
  spriteset&.addUserAnimation(VoltseonsOverworldEncounters::SPAWN_ANIMATION, event.x, event.y, true, 1) if animation
  event.through = true
  event.setVariable(nil)
  event.character_name = ""
end

def pbPokemonIdle(evt)
  return if rand(3) == 1
  return if !evt
  return if evt.lock?
  return pbDestroyOverworldEncounter(evt) if evt.variable.nil?
  if rand(50)==1 || pbTrainersSeePkmn || (!VoltseonsOverworldEncounters::GRASS_TILES.include?($game_map.terrain_tag(evt.x, evt.y).id) && !$PokemonEncounters.has_cave_encounters? && !$PokemonGlobal.diving) || ($game_map.terrain_tag(evt.x, evt.y).id != :UnderwaterGrass && $PokemonGlobal.diving)
    unless evt.variable.shiny?
      pbDestroyOverworldEncounter(evt)
      return
    end
  end
  evt.move_random
  dist = (((evt.x - $game_player.x).abs + (evt.y - $game_player.y).abs) / 4).floor
  pbDestroyOverworldEncounter(evt) if dist > 6 && !evt.variable.shiny?
  GameData::Species.play_cry_from_pokemon(evt.variable, [75, 65, 55, 40, 27, 22, 15][dist]*($PokemonSystem.owpkmn_volume/100)) if dist <= 6 && dist >= 0 && rand(20) == 1
end

def pbChangeEventSprite(event,pkmn)
  shiny = pkmn.shiny?
  shiny = pkmn.superVariant if (pkmn.respond_to?(:superVariant) && !pkmn.superVariant.nil? && pkmn.super_shiny?)
  fname = GameData::Species.ow_sprite_filename(pkmn.species, pkmn.form,
    pkmn.gender, shiny, pkmn.shadow, pkmn.super_shiny?)
  fname.gsub!("Graphics/Characters/", "")
  event.character_name = fname
  if event.move_route_forcing
    hue = pkmn.respond_to?(:superHue) && pkmn.super_shiny? ? pkmn.superHue : 0
    event.character_hue  = hue
  end
end

class Game_Temp
  attr_accessor :overworld_encounter
  attr_accessor :frames_updated

  def overworld_encounter
    @overworld_encounter = false if !@overworld_encounter
    return @overworld_encounter
  end

  def overworld_encounter=(val)
    @overworld_encounter = val
  end

  def frames_updated
    @frames_updated = 0 if !@frames_updated
    return @frames_updated
  end

  def frames_updated=(val)
    @frames_updated = val
  end
end