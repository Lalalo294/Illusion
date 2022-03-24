#-------------------------------------------------------------------------------
#
# Call the UI with: vModSelect
#
#-------------------------------------------------------------------------------
#
# Example: to provide a choice between pikachu and eevee, provided at level 5,
# with the selection saved to game variable 99
#
#	vModSelect(5, 99, :PIKACHU, :EEVEE)
#
#-------------------------------------------------------------------------------
# Default method requires the following:
# level = the level at which the chosen pokemon will be given
# selectionVariable = the game variable that will store the choice, defaults to Starter Choice
# *pokemon = list the internal names for the pokemon that will be chosen from
#			 Tested with a list of up to 15 Pokemon

def vModSelect(level, selectionVariable=7, *pokemon)
	starterLevel = level
	
	#Here is the array of internal names from which we will create our actual Pokemon
	pkmn_array = *pokemon
	
	#Iterate through the previous array and create a Pokemon for each species.
	@data={}
	for i in 0...pkmn_array.length
		@data["pkmn_#{i}"] = Pokemon.new(pkmn_array[i], starterLevel)
	end
	
	# Currently doesn't support alternate forms, will work on that once functional
	#  #Form Modifications
	#  #=======
	#	#Here we can edit any Pokemon's form
	#	### pkmn_#{i} where i is the index of the pokemon in our original array starting with 0###
	#	@data["pkmn_3"].form = 1
	#
	#	#!!!!!If we change it's form we need to recalculate it's stats and reset its moves based on the new form!!!!!
	#	@data.values.each { |pkmn| 
	#		if pkmn.form != 0
	#			pkmn.calc_stats
	#			pkmn.reset_moves
	#		end
	#	}
	#  #=======
	
	#Scene Creation
  #=======
	# Create the Scene objects
	selection = PokemonSelection.new(@data)

	# Store the player's selection in a game variable
	selection.gameVariable = selectionVariable

	# Set options according to the settings in the config
	selection.bgPath = DEFAULT_BG_PATH
	selection.firstBallX = DEFAULT_BALL_X
	selection.firstBallY = DEFAULT_BALL_Y
	selection.speciesSpriteX = DEFAULT_POKE_X
	selection.speciesSpriteY = DEFAULT_POKE_Y
	selection.ballRowSize = BALL_ROW_SIZE
	selection.selectSpriteOverBall = SELECTION_SPRITE

	#Run the method that actually opens the scene
	selection.openscene
  #=======
  
end

#===============================================================================
# PokemonSelection Class
#===============================================================================
# If attributes are set correctly, no editing should be needed below here
#===============================================================================
class PokemonSelection
 
  attr_accessor :gameVariable
  attr_accessor :bgPath
  attr_accessor :firstBallX 
  attr_accessor :firstBallY
  attr_accessor :speciesSpriteX
  attr_accessor :speciesSpriteY
  attr_accessor :ballRowSize
  attr_accessor :selectSpriteOverBall

# Returns the gameVariable value
  def gameVariable
    return @gameVariable
  end

  # Sets the gameVariable value
  def gameVariable=(value)
    @gameVariable = value.to_i
  end

  # Returns the bgPath value
  def bgPath
    return @bgPath
  end

  # Sets the bgPath value
  def bgPath=(value)
    @bgPath = value.to_s
  end

  # Returns the firstBallX value
  def firstBallX
    return @firstBallX
  end

  # Sets the firstBallX value
  def firstBallX=(value)
    @firstBallX = value.to_i
  end

# Returns the firstBallY value
  def firstBallY
    return @firstBallY
  end

  # Sets the firstBallY value
  def firstBallY=(value)
    @firstBallY = value.to_i
  end

  # Returns the speciesSpriteX value
  def speciesSpriteX
    return @speciesSpriteX
  end

  # Sets the speciesSpriteX value
  def speciesSpriteX=(value)
    @speciesSpriteX = value.to_i
  end

  # Returns the speciesSpriteY value
  def speciesSpriteY
    return @speciesSpriteY
  end

  # Sets the speciesSpriteY value
  def speciesSpriteY=(value)
    @speciesSpriteY = value.to_i
  end

  # Returns the ballRowSize value
  def ballRowSize
    return @ballRowSize
  end

  # Sets the ballRowSize value
  def ballRowSize=(value)
    @ballRowSize = value.to_i
  end

  # Returns the selectSpriteOverBall value
  def selectSpriteOverBall
    return @selectSpriteOverBall
  end

  # Sets the selectSpriteOverBall value
  def selectSpriteOverBall=(value)
    if value == true
    	@selectSpriteOverBall = true
    else
    	@selectSpriteOverBall = false
    end
  end

 def initialize(pkmn_array,gameVariable=nil,bgPath=nil,firstBallX=nil,firstBallY=nil,speciesSpriteX=nil,speciesSpriteY=nil,ballRowSize=nil,selectSpriteOverBall=nil)
  @data=pkmn_array
  
  @select=0
  @doneSelecting = false

  @firstBallX 			= firstBallX
  @firstBallY 			= firstBallY
  @speciesSpriteX 		= speciesSpriteX
  @speciesSpriteY 		= speciesSpriteX
  @ballRowSize 			= ballRowSize
  @selectSpriteOverBall = selectSpriteOverBall
  @gameVariable 		= gameVariable
  @bgPath 				= bgPath

  @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  @viewport.z=99999
  
  @pokemon=@data["pkmn_#{@select}"]
  
  @sprites={}
 end
 
 def openscene  
  @sprites["bg"]=IconSprite.new(0,0,@viewport)    
  @sprites["bg"].setBitmap(@bgPath )
  @sprites["bg"].opacity=0

  @sprites["select"]=IconSprite.new(0,0,@viewport)
  @sprites["select"].setBitmap("Graphics/Pictures/Selection Screen/select")
  @sprites["select"].opacity=0
  @sprites["select"].x=5000
  @sprites["select"].ox = @sprites["select"].bitmap.width/2	
  @sprites["select"].oy = @sprites["select"].bitmap.height if @selectSpriteOverBall

  for i in 0...@data.length
	@sprites["ball_#{i}"]=IconSprite.new(0,0,@viewport)
	ballstr = @data["pkmn_#{i}"].poke_ball
  	ballmap = Bitmap.new("Graphics/Battle animations/ball_#{ballstr}")
    rect=Rect.new(0,16,32,48)
    @sprites["ball_#{i}"].bitmap = Bitmap.new(32,32)
    @sprites["ball_#{i}"].bitmap.blt(0,0,ballmap,rect)
    @sprites["ball_#{i}"].x= @firstBallX + (@sprites["ball_#{i}"].bitmap.width  * 2) * (i% @ballRowSize) 
    @sprites["ball_#{i}"].y= @firstBallY + (@sprites["ball_#{i}"].bitmap.height * 2) * (i/ @ballRowSize).floor + (@sprites["ball_#{i}"].bitmap.height/3) * ((i% @ballRowSize)%2)
    @sprites["ball_#{i}"].ox = @sprites["ball_#{i}"].bitmap.width/2
	@sprites["ball_#{i}"].oy = @sprites["ball_#{i}"].bitmap.height/2
    @sprites["ball_#{i}"].opacity=0
	@sprites["ball_#{i}"].zoom_x=1.5
	@sprites["ball_#{i}"].zoom_y=1.5

	@sprites["pkmn_#{i}"]=PokemonSprite.new(@viewport)
	species = @data["pkmn_#{i}"].species
	gender = @data["pkmn_#{i}"].gender
	form = @data["pkmn_#{i}"].form
	shiny = @data["pkmn_#{i}"].shiny?
	@sprites["pkmn_#{i}"].setSpeciesBitmap(species,(gender==1),form,shiny)
	@sprites["pkmn_#{i}"].x=@speciesSpriteX
	@sprites["pkmn_#{i}"].y=@speciesSpriteY
	@sprites["pkmn_#{i}"].z=5000
	@sprites["pkmn_#{i}"].opacity=0
	@sprites["pkmn_#{i}"].ox = @sprites["pkmn_#{i}"].bitmap.width/2
	@sprites["pkmn_#{i}"].oy = @sprites["pkmn_#{i}"].bitmap.height/2
	@sprites["pkmn_#{i}"].zoom_x=2
	@sprites["pkmn_#{i}"].zoom_y=2
  end
  
  @sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
  @sprites["overlay"].opacity=0

  25.times do
    @sprites["bg"].opacity+=10.2
	for i in 0...@data.length
		@sprites["ball_#{i}"].opacity+=10.2
	end
	@sprites["select"].opacity+=10.2
    pbWait(1)
  end
  self.gettinginput
  self.input_action
 end
 
 def closescene
  25.times do
    @sprites["bg"].opacity-=10.2
    for i in 0...@data.length
		@sprites["ball_#{i}"].opacity-=10.2
		@sprites["pkmn_#{i}"].opacity-=10.2
	end
    @sprites["select"].opacity-=10.2
    @sprite.opacity-=10.2
    @sprites["pkmn_#{@select}"].opacity-=10.2
    @sprites["overlay"].opacity-=10.2
    pbWait(1)
    end      
  end
 
 def gettinginput
  if Input.trigger?(Input::RIGHT)  && @select < @data.length - 1
    @select+=1
  end
  if Input.trigger?(Input::LEFT) && @select > 0
    @select-=1
  end
  if Input.trigger?(Input::UP)  && @select >= @ballRowSize
    @select-=@ballRowSize
  end
  if Input.trigger?(Input::DOWN) && @select < @data.length - @ballRowSize
    @select+=@ballRowSize
  end
  if defined?($mouse)
    for i in 0...@data.length
      if $mouse.over?(@sprites["ball_#{i}"]) && !$mouse.isStatic?
        @select=i
      end
    end
    if $mouse.leftClick?(@sprites["ball_#{@select}"])
      pressBall
    end
  end
  if Input.trigger?(Input::C) 
    pressBall
  end
 end
 
 def pressBall
  @sprites["select"].visible=false
  @sprites["pkmn_#{@select}"].visible=true
  ballstr = @data["pkmn_#{@select}"].poke_ball
  20.times do
    @sprites["pkmn_#{@select}"].opacity+=255/20
    @sprite.opacity+=255/20; 
	@sprites["overlay"].opacity+=255/20
    @sprites["ball_#{@select}"].bitmap = Bitmap.new("Graphics/Battle animations/ball_#{ballstr}_open")
    @sprites["ball_#{@select}"].y-=2
    @sprites["ball_#{@select}"].zoom_x+=0.02
    @sprites["ball_#{@select}"].zoom_y+=0.02
    for j in 0...@data.length
      @sprites["ball_#{j}"].opacity-=10 if !(j==@select)
  	end      
	pbWait(1)
  end
  @sprite.visible=true
  @pokemon.play_cry
  pbWait(20)
  if Kernel.pbConfirmMessage("Do you want #{@pokemon.name}?")
    @pokemon.owner.name     = $Trainer.name
    @pokemon.owner.id 		= $Trainer.id
    pbAddPokemon(@pokemon,@pokemon.level)
    
    $game_variables[@gameVariable]=@select+1

    @doneSelecting = true
    self.closescene
  else	
	ballmap = Bitmap.new("Graphics/Battle animations/ball_#{ballstr}")
	rect=Rect.new(0,16,32,48)
	@sprites["ball_#{@select}"].bitmap = Bitmap.new(32,32)
	@sprites["ball_#{@select}"].bitmap.blt(0,0,ballmap,rect)
    20.times do
      @sprites["pkmn_#{@select}"].opacity-=255/20
      @sprite.opacity-=255/20;
	  @sprites["overlay"].opacity-=255/20
      @sprites["ball_#{@select}"].y+=2
      @sprites["ball_#{@select}"].zoom_x-=0.02; @sprites["ball_#{@select}"].zoom_y-=0.02
      for j in 0... @data.length
        @sprites["ball_#{j}"].opacity+=10 if !(j==@select)
      end  
      pbWait(1)
    end
      @sprites["pkmn_#{@select}"].visible=false
      @sprite.visible=false
      @sprites["select"].visible=true
	end
  end
    
 def input_action
  while @doneSelecting == false
    Graphics.update
    Input.update
    @pokemon=@data["pkmn_#{@select}"]
    self.gettinginput

    for i in 0... @data.length
   	  @sprites["ball_#{i}"].y= @firstBallY + (@sprites["ball_#{i}"].bitmap.height * 1.5) * (i/@ballRowSize).floor + (@sprites["ball_#{i}"].bitmap.height/3)  * ((i% @ballRowSize)%2)
      @sprites["ball_#{i}"].y -=10 if i==@select
    end 

    @sprites["select"].x= @sprites["ball_#{@select}"].x
    @sprites["select"].y= @sprites["ball_#{@select}"].y
    self.text; self.typebitmap
  end
 end

 def text
  overlay= @sprites["overlay"].bitmap
  overlay.clear
  baseColor=Color.new(255, 255, 255)
  shadowColor=Color.new(0,0,0)
  pbSetSystemFont(@sprites["overlay"].bitmap)
  name = @pokemon.name
  
  textpos=[]
  textpos.push([_INTL("{1}", name),@speciesSpriteX + (@sprites["pkmn_#{@select}"].bitmap.width/2) + 40,@speciesSpriteY - 60,false,baseColor,shadowColor])
  # Draw gender symbol
  if @pokemon.male?
    textpos.push([_INTL("♂"),@speciesSpriteX + (@sprites["pkmn_#{@select}"].bitmap.width/2 + 20),@speciesSpriteY - 60,0,Color.new(0,112,248),Color.new(120,184,232)])
  elsif @pokemon.female?
    textpos.push([_INTL("♀"),@speciesSpriteX + (@sprites["pkmn_#{@select}"].bitmap.width/2 + 20),@speciesSpriteY - 60,0,Color.new(232,32,16),Color.new(248,168,184)])
  end
  pbDrawTextPositions(overlay,textpos)
 end

 def typebitmap  
  @sprite=Sprite.new(@viewport)
  @sprite.bitmap=Bitmap.new(194,28)
  
  @sprite.opacity=0
  @bitmap=Bitmap.new("Graphics/Pictures/types")
  
  @type1rect=Rect.new(0,typeIndex(@pokemon.type1)*28,64,28)
  @type2rect=Rect.new(0,typeIndex(@pokemon.type2)*28,64,28)
  
  if @pokemon.type1==@pokemon.type2
    @sprite.x=@speciesSpriteX + (@sprites["pkmn_#{@select}"].bitmap.width/2 + 20)
    @sprite.y=@speciesSpriteY - 20;
    @sprite.bitmap.blt(0,0,@bitmap,@type1rect)
  else
    @sprite.x=@speciesSpriteX + (@sprites["pkmn_#{@select}"].bitmap.width/2 + 20)
    @sprite.y=@speciesSpriteY - 20;
    @sprite.bitmap.blt(0,0,@bitmap,@type1rect)
    @sprite.bitmap.blt(66,0,@bitmap,@type2rect)
  end
 end
end

# Create a method to get a numerical index for a pokemon type
# allowing us to decipher the types.png

def typeIndex(type_attribute)

	case type_attribute
	when :NORMAL
	return 0
	when :FIGHTING
	return 1
	when :FLYING
	return 2
	when :POISON
	return 3
	when :GROUND
	return 4
	when :ROCK
	return 5
	when :BUG
	return 6
	when :GHOST
	return 7
	when :STEEL
	return 8
	when :FIRE
	return 10
	when :WATER
	return 11
	when :GRASS
	return 12
	when :ELECTRIC
	return 13
	when :PSYCHIC
	return 14
	when :ICE
	return 15
	when :DRAGON
	return 16
	when :DARK
	return 17
	when :FAIRY
	return 18
	end
end