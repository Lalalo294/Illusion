module Settings
  LEVEL_CAP_EXP = 0 # for game switch 63
  LEVEL_CAP_EXP_2 = 50  # for game switch 64
end

#==============================================================================#
#\\\\\\\\\\\\\\\\\\\\\\\\\\CONFIGURATION\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#==============================================================================#
  LEVEL_CAPS = [1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100] #scales according to variable 32 but may change it as you please
#==============================================================================#

class Battle
def pbGainExpOne(idxParty,defeatedBattler,numPartic,expShare,expAll,showMessages=true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
    growth_rate = pkmn.growth_rate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp>=growth_rate.maximum_exp
      pkmn.calc_stats   # To ensure new EVs still have an effect
      return
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    # Main Exp calculation
    exp = 0
    a = level*defeatedBattler.pokemon.base_exp
    if expShare.length>0 && (isPartic || hasExpShare)
      if numPartic==0   # No participants, all Exp goes to Exp Share holders
        exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
      elsif Settings::SPLIT_EXP_BETWEEN_GAINERS   # Gain from participating and/or Exp Share
        exp = a/(2*numPartic) if isPartic
        exp += a/(2*expShare.length) if hasExpShare
      else   # Gain from participating and/or Exp Share (Exp not split)
        exp = (isPartic) ? a : a/2
      end
    elsif isPartic   # Participated in battle, no Exp Shares held by anyone
      exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
    elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
      # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
      #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
      exp = a/2
    end
    return if exp<=0
    # Pokémon gain more Exp from trainer battles
    exp = (exp*1.5).floor if trainerBattle?
    # Scale the gained Exp based on the gainer's level (or not)
    if Settings::SCALED_EXP_FORMULA
      exp /= 5
      levelAdjust = (2*level+10.0)/(pkmn.level+level+10.0)
      levelAdjust = levelAdjust**5
      levelAdjust = Math.sqrt(levelAdjust)
      exp *= levelAdjust
      exp = exp.floor
      exp += 1 if isPartic || hasExpShare
    else
      exp /= 7
    end
#========EXP CHANGING SCRIPT======================================================================#
    if defined?(pkmn) #check if the pkmn variable exist, for v18 and v19 compatibility
        thispoke = pkmn
    end
    if $game_switches[63]
          levelCap=LEVEL_CAPS[$game_variables[32]]
          exp=Settings::LEVEL_CAP_EXP if pkmn.level>=levelCap
    elsif  $game_switches[64]
      levelCap=LEVEL_CAPS[$game_variables[32]]
          exp=Settings::LEVEL_CAP_EXP_2 if pkmn.level>=levelCap

    else
      levelCap=GameData::GrowthRate.max_level
    end
#==================================================================================================#

    # Foreign Pokémon gain more Exp
    isOutsider = (pkmn.owner.id != pbPlayer.id ||
                 (pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language))
    if isOutsider
      if pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language
        exp = (exp*1.7).floor
      else
        exp = (exp*1.5).floor
      end
    end
    # Modify Exp gain based on pkmn's held item
    i = Battle::ItemEffects.triggerExpGainModifier(pkmn.item,pkmn,exp)
    if i<0
      i = Battle::ItemEffects.triggerExpGainModifier(@initialItems[0][idxParty],pkmn,exp)
    end
    exp = i if i>=0
    level_cap=$game_switches[63] ? LEVEL_CAPS[$game_variables[32]] : GameData::GrowthRate.max_level
    # Make sure Exp doesn't exceed the maximum
    exp_level_cap = growth_rate.minimum_exp_for_level(level_cap)
    if pkmn.exp+exp > exp_level_cap
      diff_to_level = exp_level_cap - pkmn.exp
      extra_exp = exp - diff_to_level
      extra_exp = [extra_exp,Settings::LEVEL_CAP_EXP].min
      exp = diff_to_level + extra_exp
    end
    expFinal = growth_rate.add_exp(pkmn.exp, exp)
    expGained = expFinal - pkmn.exp
    return if expGained <= 0
    # "Exp gained" message
    if showMessages
      if isOutsider
        pbDisplayPaused(_INTL("{1} got a boosted {2} Exp. Points!",pkmn.name,expGained))
  	  elsif exp>2
          pbDisplayPaused(_INTL("{1} got {2} Exp. Points!",pkmn.name,expGained))
  	  else
  	    pbDisplayPaused(_INTL("{1} got a meager {2} Exp. Points...",pkmn.name,expGained))
      end
    end
    curLevel = pkmn.level
    newLevel = growth_rate.level_from_exp(expFinal)
    if newLevel<curLevel
      debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
      raise RuntimeError.new(
         _INTL("{1}'s new level is less than its\r\ncurrent level, which shouldn't happen.\r\n[Debug: {2}]",
         pkmn.name,debugInfo))
    end
    # Give Exp
    if pkmn.shadowPokemon?
      pkmn.exp += expGained
      return
    end
    tempExp1 = pkmn.exp
    battler = pbFindBattler(idxParty)
    loop do   # For each level gained in turn...
      # EXP Bar animation
      levelMinExp = growth_rate.minimum_exp_for_level(curLevel)
      levelMaxExp = growth_rate.minimum_exp_for_level(curLevel + 1)
      tempExp2 = (levelMaxExp<expFinal) ? levelMaxExp : expFinal
      pkmn.exp = tempExp2
      @scene.pbEXPBar(battler,levelMinExp,levelMaxExp,tempExp1,tempExp2)
      tempExp1 = tempExp2
      curLevel += 1
      if curLevel>newLevel
        # Gained all the Exp now, end the animation
        pkmn.calc_stats
        battler.pbUpdate(false) if battler
        @scene.pbRefreshOne(battler.index) if battler
        break
      end
      # Levelled up
      pbCommonAnimation("LevelUp",battler) if battler
      oldTotalHP = pkmn.totalhp
      oldAttack  = pkmn.attack
      oldDefense = pkmn.defense
      oldSpAtk   = pkmn.spatk
      oldSpDef   = pkmn.spdef
      oldSpeed   = pkmn.speed
      if battler && battler.pokemon
        battler.pokemon.changeHappiness("levelup")
      end
      pkmn.calc_stats
      battler.pbUpdate(false) if battler
      @scene.pbRefreshOne(battler.index) if battler
      pbDisplayPaused(_INTL("{1} grew to Lv. {2}!",pkmn.name,curLevel))
      @scene.pbLevelUp(pkmn,battler,oldTotalHP,oldAttack,oldDefense,
                                    oldSpAtk,oldSpDef,oldSpeed)
      # Learn all moves learned at this level
      moveList = pkmn.getMoveList
      moveList.each { |m| pbLearnMove(idxParty,m[1]) if m[0]==curLevel }
    end
  end
end

ItemHandlers::UseOnPokemon.add(:RARECANDY,proc { |item,qty,pkmn,scene|

  if $game_switches[63] #<- REPLACE WITH YOUR SETTING $game_variables[id] == X or $game_switches[id]
    levelCap = LEVEL_CAPS[$game_variables[32]]
  else
    levelCap = GameData::GrowthRate.max_level
  end

  if pkmn.level>=GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif pkmn.level>levelCap
    scene.pbMessage(_INTL("{1} refuses to eat the Rare Candy.",pkmn.name))
    next false
  elsif pkmn.level==levelCap
    scene.pbMessage(_INTL("{1} refuses to eat the Rare Candy.",pkmn.name))
    next false
  elsif pkmn.level+qty > levelCap
    scene.pbMessage(_INTL("{1} refuses to eat the Rare Candy.\\n would exceed level cap of {2}.",pkmn.name,levelCap))
    if pbConfirmMessageSerious(_INTL("Bring {1} to level {2}?",pkmn.name,levelCap))
      pbChangeLevel(pkmn,levelCap,scene)
      scene.pbHardRefresh
      next true
    end
    next false
  end
  pbChangeLevel(pkmn,pkmn.level+qty,scene)
  scene.pbHardRefresh
  next true
})

def pbGainExpFromExpCandy(pkmn, base_amt, qty, scene)
  if pkmn.level >= GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  if $game_switches[63] || $game_switches[64]
    levelCap = LEVEL_CAPS[$game_variables[32]]
  else
    levelCap = GameData::GrowthRate.max_level
  end
  if (pkmn.level+1) > levelCap
    scene.pbMessage(_INTL("{1} refuses to eat the Candy.\\n would exceed level cap of {2}.",pkmn.name,levelCap))
    return false
  end
  if (pkmn.growth_rate.level_from_exp(pkmn.exp+(base_amt*qty))) > levelCap
    scene.pbMessage(_INTL("{1} refuses to eat the Candy.\\n would exceed level cap of {2}.",pkmn.name,levelCap))
    if pbConfirmMessageSerious(_INTL("Bring {1} to level {2}, and waste extra exp?",pkmn.name,levelCap))
      pbChangeExp(pkmn,(pkmn.growth_rate.minimum_exp_for_level(levelCap)),scene)
      scene.pbHardRefresh
      return true
    end
    return false
  end
  scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  if qty > 1
    (qty - 1).times { pkmn.changeHappiness("vitamin") }
  end
  pbChangeExp(pkmn, pkmn.exp + (base_amt * qty), scene)
  scene.pbHardRefresh
  return true
end
