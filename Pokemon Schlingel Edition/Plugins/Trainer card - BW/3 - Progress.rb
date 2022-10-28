module TCBW
	class Show

		def show
			# Create scene
			create_scene
			# Draw trainer
			2.times { text_trainer }
			loop do
				update_ingame
				break if @exit
				# Update
				update_main
				# Draw
				draw_main
				# Input
				update_mouse
				update_keyboard
			end
		end

		def create_scene
			# Animated scene
			@sprites["anim bg"] = AnimatedPlane.new(@viewport)
			file = "Graphics/Pictures/Trainer Card BW/TrainerCard/trainercardbg1"
			@sprites["anim bg"].setBitmap(file)

			# Border
			create_sprite("border screen", "trainercardborder", @viewport, "TrainerCard")

			# Bar icon
			create_sprite("bar icon", "normalbar", @viewport, "TrainerCard")
			yy = Graphics.height - @sprites["bar icon"].bitmap.height
			set_xy_sprite("bar icon", 0, yy)

			# Icon right
			create_sprite("right icon", "globalicons", @viewport, "TrainerCard")
			w = @sprites["right icon"].bitmap.width / 3
			h = @sprites["right icon"].bitmap.height / 2
			set_src_wh_sprite("right icon", w, h)
			x = Graphics.width - w - 5
			y = yy + (@sprites["bar icon"].bitmap.height - h) / 2
			set_xy_sprite("right icon", x, y)

			# Icon left
			create_sprite("left icon", "trainercardicons", @viewport, "TrainerCard")
			w = @sprites["left icon"].bitmap.width / 2
			h = @sprites["left icon"].bitmap.height / 2
			set_src_wh_sprite("left icon", w, h)
			x = 5
			y = yy + (@sprites["bar icon"].bitmap.height - h) / 2
			set_xy_sprite("left icon", x, y)
			
			# Trainer card
			gender = $Trainer.gender
			gender = 0 if gender == 2
			create_sprite("trainer card", "trainercard#{gender}", @viewport, "TrainerCard")
			x = (Graphics.width - @sprites["trainer card"].bitmap.width) / 2
			set_xy_sprite("trainer card", x, 0)

			# Trainer
			@sprites["trainer"] = IconSprite.new(336, 48, @viewport)
			@sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($Trainer.trainer_type))
			@sprites["trainer"].src_rect.width = @sprites["trainer"].bitmap.height
			@sprites["trainer"].x -= (@sprites["trainer"].bitmap.width - 128) / 2

			# Badge (bg)
			create_sprite("bg leader", "trainerbadges #{@region}", @viewport, "TrainerCard")
			set_visible_sprite("bg leader")

			8.times { |i|
				# Badge
				create_sprite("badge #{i}", "badges #{@region}", @viewport, "TrainerCard")
				w = @sprites["badge #{i}"].bitmap.width / 4
				h = @sprites["badge #{i}"].bitmap.height / 4
				set_src_wh_sprite("badge #{i}", w, h)
				set_src_xy_sprite("badge #{i}", w * i, 2)
				x = w * i
				y = 0
				set_xy_sprite("badge #{i}", x, y)
				set_visible_sprite("badge #{i}")

				# Leader
				create_sprite("leader #{i}", "leaderfaces #{@region}", @viewport, "TrainerCard")
				w = @sprites["leader #{i}"].bitmap.width / 8
				h = @sprites["leader #{i}"].bitmap.height / 2
				set_src_wh_sprite("leader #{i}", w, h)
				set_src_xy_sprite("leader #{i}", w * i, ($Trainer.badges[i + @region * 8] ? 0 : h))
				y = 26
				set_xy_sprite("leader #{i}", x, y)
				set_visible_sprite("leader #{i}")
			}

			# Information
			create_sprite("information", "trainercardgyminfo", @viewport, "TrainerCard")
			y = yy - @sprites["information"].bitmap.height
			set_xy_sprite("information", 0, y)
			set_visible_sprite("information")

			# Animation of leader
			file = SET[0 + @region * 8][0]
			create_sprite("bitmap leader", file, @viewport, "Trainers")
			x = Graphics.width - 130 / 2
			y += 88
			set_xy_sprite("bitmap leader", x, y)
			set_visible_sprite("bitmap leader")

			# Text
			create_sprite_2("trainer text", @viewport)
			create_sprite_2("infor leader", @viewport)
			create_sprite_2("infor leader 2", @viewport)
		end

	end
end