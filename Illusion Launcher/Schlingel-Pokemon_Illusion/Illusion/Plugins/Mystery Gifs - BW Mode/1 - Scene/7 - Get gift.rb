module MGBW
	class Show

		def gift(trainer)
			@trainer = trainer
			get_gift_trainer(trainer)
			get_gift_pe(trainer)
		end

		def restore_trainer = @trainer

		def get_gift_trainer(trainer)
			return if USE_PE
			arr = MGBW.decrypt
			return unless arr
			fake = []
			arr.each { |gift|
				notgot = true
				trainer.mystery_gifts.each { |m| notgot = false if m[0] == gift[0] }
				fake << gift if notgot
			}
			delete_gift_same_id(trainer, trainer.mystery_gifts)
			@gift = fake
		end

		def get_gift_pe(trainer)
			return unless USE_PE
			arr = MGBW.decrypt
			return unless arr
			fake = []
			arr.each { |gift|
				if gift.size == 5
					gift[2] = GameData::Item.get(gift[2]).id if gift[1] != 0
				else
					# Pkmn : Item
					gift[2] = gift[1] == 0 ? PokeBattle_Pokemon.convert(gift[2]) : GameData::Item.get(gift[2]).id
				end
				notgot = true
				trainer.mystery_gifts.each { |m| notgot = false if m[0] == gift[0] }
				fake << gift if notgot
			}
			delete_gift_same_id(trainer, trainer.mystery_gifts)
			@gift = fake
		end

		def delete_gift_same_id(trainer, arr)
			newwc  = []
			trainer.wonder_cards.each { |wonder|
				notgot = true
				wonder.each { |k, v|
					arr.each { |a|
						next if a[0] != v[0]
						notgot = a.size != 1
						break
					}
				}
				newwc << wonder if notgot
			}
			trainer.wonder_cards = newwc
		end

	end
end