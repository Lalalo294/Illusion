#===============================================================================
# Editable Pokemon Attributes
#===============================================================================
#  attr_accessor :name        # Nickname
#  attr_reader   :species     # Species (National Pokedex number)
#  attr_reader   :exp         # Current experience points
#  attr_reader   :hp          # Current HP
#  attr_reader   :totalhp     # Current Total HP
#  attr_reader   :attack      # Current Attack stat
#  attr_reader   :defense     # Current Defense stat
#  attr_reader   :speed       # Current Speed stat
#  attr_reader   :spatk       # Current Special Attack stat
#  attr_reader   :spdef       # Current Special Defense stat
#  attr_accessor :status      # Status problem (PBStatuses)
#  attr_accessor :statusCount # Sleep count/Toxic flag
#  attr_accessor :abilityflag # Forces the first/second/hidden (0/1/2) ability
#  attr_accessor :genderflag  # Forces male (0) or female (1)
#  attr_accessor :natureflag  # Forces a particular nature
#  attr_accessor :natureOverride   # Overrides nature's stat-changing effects
#  attr_accessor :shinyflag   # Forces the shininess (true/false)
#  attr_accessor :moves       # Moves (PBMove)
#  attr_accessor :firstmoves  # The moves known when this Pokémon was obtained
#  attr_accessor :item        # Held item
#  attr_accessor :trmoves     # Technical Records
#  attr_writer   :mail        # Mail
#  attr_accessor :fused       # The Pokémon fused into this one
#  attr_accessor :iv          # Array of 6 Individual Values for HP, Atk, Def,
#                             #    Speed, Sp Atk, and Sp Def
#  attr_writer   :ivMaxed     # Array of booleans that max each IV value
#  attr_accessor :ev          # Effort Values
#  attr_accessor :happiness   # Current happiness
#  attr_accessor :ballused    # Ball used
#  attr_accessor :eggsteps    # Steps to hatch egg, 0 if Pokémon is not an egg
#  attr_writer   :markings    # Markings
#  attr_accessor :ribbons     # Array of ribbons
#  attr_accessor :pokerus     # Pokérus strain and infection time
#  attr_accessor :personalID  # Personal ID
#  attr_accessor :trainerID   # 32-bit Trainer ID (the secret ID is in the upper
#                             #    16 bits)
#  attr_accessor :obtainMode  # Manner obtained:
#                             #    0 - met, 1 - as egg, 2 - traded,
#                             #    4 - fateful encounter
#  attr_accessor :obtainMap   # Map where obtained
#  attr_accessor :obtainText  # Replaces the obtain map's name if not nil
#  attr_writer   :obtainLevel # Level obtained
#  attr_accessor :hatchedMap  # Map where an egg was hatched
#  attr_writer   :language    # Language
#  attr_accessor :ot          # Original Trainer's name
#  attr_writer   :otgender    # Original Trainer's gender:
#                             #    0 - male, 1 - female, 2 - mixed, 3 - unknown
#                             #    For information only, not used to verify
#                             #    ownership of the Pokémon
#  attr_writer   :cool,:beauty,:cute,:smart,:tough,:sheen   # Contest stats
#  attr_accessor :criticalHits # Galarian Farfetch'd Evolution Method
#  attr_accessor :yamaskhp    # Yamask Evolution Method
#
# Also will display any pokeball
# BallTypes
#
#  POKEBALL			GREATBALL		SAFARIBALL		ULTRABALL
#  MASTERBALL		NETBALL			DIVEBALL		NESTBALL
#  REPEATBALL		TIMERBALL		LUXURYBALL		PREMIERBALL
#  DUSKBALL			HEALBALL		QUICKBALL		CHERISHBALL
#  FASTBALL			LEVELBALL		LUREBALL		HEAVYBALL
#  LOVEBALL			FRIENDBALL		MOONBALL		SPORTBALL
#  DREAMBALL		BEASTBALL
#
#===============================================================================
# Below is an example of the advanced method. In this case it will generate a 
# selection screen using a laboratory background and a grid of 4 pokemon to
# choose from; Vulpix, Alolan Vulpix, Zigzagoon, and Galarian Zigzagoon. The 
# Vulpix is forced to be a shiny, and all but the normal Zigzagoon have specific
# pokeballs rather than the default.
#
# Adjust this method to your desired configurations, or copy it to allow for
# multiple instances of different advanced selection events in your game.

def vAdvSelect

	# What level do the Pokemon start at?
	starterLevel = 10
	
	#Here is the array of internal names from which we will create our actual Pokemon
	#If you aren't editing Forms/Attributes for any Pokemon all you need to set is this array
	pkmn_array = [:VULPIX, :VULPIX, :ZIGZAGOON, :ZIGZAGOON]
	
	#Iterate through the previous array and create a pokemon for each species.
	@data={}
	for i in 0...pkmn_array.length
		@data["pkmn_#{i}"] = Pokemon.new(pkmn_array[i], starterLevel)
	end
	
	  #Form Modifications
	  #=======
		#Here we can edit any Pokemon's form
		### pkmn_#{i} where i is the index of the pokemon in our original array starting with 0###
		@data["pkmn_1"].form = 1
		@data["pkmn_3"].form = 1
	
		#!!!!!If we change it's form we need to recalculate it's stats and reset its moves based on the new form!!!!!
		@data.values.each { |pkmn| 
			if pkmn.form != 0
				pkmn.calc_stats
				pkmn.reset_moves
			end
		}
	  #=======

		#Attribute Modifications
		#=======
		#Here we can edit any of the created Pokemon's attributes before sending it to the PokemonStarterSelection scene
			### pkmn_#{i} where i is the index of the pokemon in our original array starting with 0###
		#Editable attributes listed above this method
		@data["pkmn_0"].makeFemale
		@data["pkmn_0"].shiny = true
		@data["pkmn_0"].poke_ball = :QUICKBALL
		@data["pkmn_1"].poke_ball = :HEALBALL
		@data["pkmn_3"].poke_ball = :LUXURYBALL
	#=======
	
	#Scene Creation
  #=======
	# Create the Scene objects
	selection = PokemonSelection.new(@data)

	# If you would like to store the players selection with index base 1 
	selection.gameVariable = 7

	# Set the scene background
	selection.bgPath = "Graphics/Pictures/Selection Screen/bg"

	# Set the X and Y location of the TOP LEFT ball, based on a center origin of the ball sprite (all other ball are calculated dynamically from here)
	selection.firstBallX = 60
	selection.firstBallY = 150
	
	# Set the X and Y location of the selected Pokemon's sprite, based on a center origin of the Battler sprite (all stats displayed are calculated dynamically from here)
	selection.speciesSpriteX = 220
	selection.speciesSpriteY = 175

	# Select how many balls are in each row
	selection.ballRowSize = 2

	#If you want your "select" sprite to appear over the ball, set to true (like Shiney570's original script) 
	selection.selectSpriteOverBall = true

	#Run the method that actually opens the scene
	selection.openscene
  #=======
  
end

# Here is another example of what you can do with the selection screen.
# This method selects a random set of 5 Pokemon from a set of arrays dependent on a game variable.

def vRandSelect(level)

	# What level do the Pokemon start at?
	starterLevel = level
	
	# Build arrays to select a set of 5 Pokemon from.
	env1 = [:SLOWPOKE, :AXEW, :SKORUPI, :CACNEA, :YAMASK, :BUNEARY, :CLEFAIRY, :ROGGENROLA, :KLINK, :LITWICK, :SWABLU, :DRILBUR, :IMPIDIMP, :TOXEL, :SHROOMISH]
	env2 = [:IGGLYBUFF, :PAWNIARD, :BERGMITE, :GASTLY, :BLIPBUG, :BUIZEL, :PANCHAM, :GIBLE, :BINACLE, :MAREEP, :VULPIX, :HOPPIP, :CLOBBOPUS, :ROOKIDEE, :NOIBAT]
	env3 = [:CHINCHOU, :RUFFLET, :ARON, :SINISTEA, :SCRAGGY, :CUTIEFLY, :NUMEL, :TRAPINCH, :EXEGGCUTE, :VANILLITE, :SKRELP, :MINCCINO, :INKAY, :DUSKULL, :FLETCHLING]
	env4 = [:TIMBURR, :CARVANHA, :FERROSEED, :SOLOSIS, :GOOMY, :PIKACHU, :SPHEAL, :GOLETT, :TOGEPI, :CROAGUNK, :HAPPINY, :COMBEE, :LARVITAR, :ROLYCOLY, :BOUNSWEET]
	env5 = [:SEEDOT, :HONEDGE, :RHYHORN, :SALANDIT, :DEWPIDER, :TAILLOW, :SWIRLIX, :BAGON, :MAGNEMITE, :HATENNA, :MAREANIE, :MANKEY, :DREEPY, :SNOM, :SANDILE]
	env6 = [:CUFANT, :CORPHISH, :PINECO, :SANDYGAST, :MORELULL, :ABRA, :SNOVER, :STUFFUL, :HORSEA, :HELIOPTILE, :MANTYKE, :STUNKY, :SIZZLIPEDE, :DEINO, :BELDUM]
	envList = [env1, env2, env3, env4, env5, env6]
	
	#Generate a sample of 5 pokemon from one of the lists above, depending on the number of pokemon selections that have occurred (game variable 28)
	#To make sure this module is plug-n-play, I commented out the section that references a game variable and hard-coded it instead. This pulls from the env3 array.
	#pkmn_array = envList[$game_variables[28]].sample(5)
	pkmn_array = envList[2].sample(5)
	
	#Iterate through the previous array and create a pokemon for each species.
	@data={}
	for i in 0...pkmn_array.length
		@data["pkmn_#{i}"] = Pokemon.new(pkmn_array[i], starterLevel)
	end
	
	#Scene Creation
  #=======
	# Create the Scene objects
	selection = PokemonSelection.new(@data)

	# If you would like to store the players selection with index base 1 
	selection.gameVariable = 7

	# Set the scene background
	selection.bgPath = "Graphics/Pictures/Selection Screen/birchCase"

	# Set the X and Y location of the TOP LEFT ball, based on a center origin of the ball sprite (all other ball are calculated dynamically from here)
	selection.firstBallX = 110
	selection.firstBallY = 240
	
	# Set the X and Y location of the selected Pokemon's sprite, based on a center origin of the Battler sprite (all stats displayed are calculated dynamically from here)
	selection.speciesSpriteX = 190
	selection.speciesSpriteY = 175

	# Select how many balls are in each row
	selection.ballRowSize = 5

	#If you want your "select" sprite to appear over the ball, set to true (like Shiney570's original script) 
	selection.selectSpriteOverBall = false

	#Run the method that actually opens the scene
	selection.openscene
  #=======
  
end