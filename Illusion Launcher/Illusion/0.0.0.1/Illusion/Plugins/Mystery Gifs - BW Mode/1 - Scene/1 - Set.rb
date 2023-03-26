module MGBW

	class Show

		def initialize
			@sprites = {}
			# Viewport
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
			@blackvp = Viewport.new(0,0,Graphics.width,Graphics.height)
      @blackvp.z = 99999
			# Values
			@bg = :main
			@press = false
			@fade = false
			# Wait
			@wait  = 0 # Wait text (msg)
			@times = 0 # Gift
			@wnxt  = 0 # Wait text
			# Select
			# Select (menu)
			@select = 0
			# Select wonder in album
			@position  = 0
			@startnum  = 0
			@realquant = 0
			@frames    = 0
			@animwc    = [0, 0, 0, 0]
			# Store gif
			@gift = []
			@got  = nil
			# Words (code)
			@words  = []
			@cursor = 0 # Cursor to define position (press entry)
			@date   = nil # Show when player gets wonder cards
			@exit = false
		end

	end

	def self.show(trainer)
		ret = trainer
		pbFadeOutIn {
			f = Show.new
			f.gift(trainer)
			f.show
			ret = f.restore_trainer
			f.endScene
		}
		return ret
	end

	#------------------------#
	# Change hash into array #
	#------------------------#
	def self.hash_array(hash)
		return unless hash.is_a?(Hash)
		arr = []
		hash.each { |k, v| arr << [k, v] }
		return arr
	end

end
#--------------------------------------------------#
# Create value to store information of wonder card #
#--------------------------------------------------#
class Player < Trainer
	attr_accessor :wonder_cards

	alias wonder_card_init initialize
	def initialize(name, trainer_type)
		wonder_card_init(name, trainer_type)
		@wonder_cards = []
	end
end

#--------------#
# Main (scene) #
#--------------#
def pbDownloadMysteryGift(trainer)
	trainer = MGBW.show(trainer)
end

#--------#
# Get MG #
#--------#
def pbNextMysteryGiftID(id=false)
	$Trainer.mystery_gifts.each { |gift|
		next if gift.size <= 1
		return gift[0] if id
		return 1
	}
  return 0
end

def pbReceiveMysteryGift(id)
  index = -1
	$Trainer.mystery_gifts.each_with_index { |gift, i|
		if gift[0] == id && gift.size > 1
			index = i
			break
		end
	}
	if index == -1
    pbMessage(_INTL("Couldn't find an unclaimed Mystery Gift with ID {1}.",id))
    return false
  end
  gift = $Trainer.mystery_gifts[index]
	if gift[1]==0   # Pokémon
		gift[2].personalID = rand(2**16) | rand(2**16) << 16
		gift[2].calc_stats

		# Time
		arr = []
		$Trainer.wonder_cards.each { |i| arr << MGBW.hash_array(i)[0] }
		timeindex = -1
		arr.each_with_index { |a, i|
			next if a[1][0] != gift[0]
			timeindex = i
			break
		}
		if timeindex == -1
			time = pbGetTimeNow
			gift[2].timeReceived = time.getgm.to_i
		else
			gift[2].timeReceived = arr[timeindex][0]
		end

		gift[2].obtain_method = 4   # Fateful encounter
		gift[2].record_first_moves
		if $game_map
			gift[2].obtain_map = $game_map.map_id
			gift[2].obtain_level = gift[2].level
		else
			gift[2].obtain_map = 0
			gift[2].obtain_level=gift[2].level
		end
		if pbAddPokemonSilent(gift[2])
			pbMessage(_INTL("\\me[Pkmn get]{1} received {2}!",$Trainer.name,gift[2].name))
			$Trainer.mystery_gifts[index] = [id]
			return true
		end
	elsif gift[1]>0   # Item
		item=gift[2]
		qty=gift[1]
		if $PokemonBag.pbCanStore?(item,qty)
			$PokemonBag.pbStoreItem(item,qty)
			itm = GameData::Item.get(item)
			itemname=(qty>1) ? itm.name_plural : itm.name
			if item == :LEFTOVERS
				pbMessage(_INTL("\\me[Item get]You obtained some \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
			elsif itm.is_machine?   # TM or HM
				pbMessage(_INTL("\\me[Item get]You obtained \\c[1]{1} {2}\\c[0]!\\wtnp[30]",itemname,
					GameData::Move.get(itm.move).name))
			elsif qty>1
				pbMessage(_INTL("\\me[Item get]You obtained {1} \\c[1]{2}\\c[0]!\\wtnp[30]",qty,itemname))
			elsif itemname.starts_with_vowel?
				pbMessage(_INTL("\\me[Item get]You obtained an \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
			else
				pbMessage(_INTL("\\me[Item get]You obtained a \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
			end
			$Trainer.mystery_gifts[index] = [id]
			return true
		end
	end
  return false
end