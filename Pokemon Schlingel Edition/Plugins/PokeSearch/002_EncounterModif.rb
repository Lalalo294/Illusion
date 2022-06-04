# All of the berry effects modifying the encounter
EventHandlers.add(:on_wild_pokemon_created, :pokesearch, proc {|pkmn|
  if $PokemonSystem.pokesearch_encounter
    if !$PokemonSystem.last_pokesearch_settings[1].nil?
      case $PokemonSystem.last_pokesearch_settings[1]
      when :LUMBERRY
        if (rand(25)==1)
          pkmn.ability_index=2
        end
      when :CHESTOBERRY, :CHERIBERRY, :PECHABERRY, :RAWSTBERRY, :PERSIMBERRY, :ASPEARBERRY
        if (rand(50)==1)
          pkmn.givePokerus
        end
      when :ORANBERRY
        GameData::Stat.each_main do |s|
          pkmn.iv[s.id] = [pkmn.iv[s.id]+5, Pokemon::IV_STAT_LIMIT].min
        end
      when :SITRUSBERRY
        GameData::Stat.each_main do |s|
          pkmn.iv[s.id] = [pkmn.iv[s.id]+10, Pokemon::IV_STAT_LIMIT].min
        end
      when :ENIGMABERRY
        if (rand(25)==1)
          pkmn.shiny = true
        end
      end
    end
    pkmn.reset_moves
    pkmn.calc_stats
  end
})