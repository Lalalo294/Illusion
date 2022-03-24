module TCBW
	class Show

		def update_main
			update_bitmap_anim_bg
			update_anim_bg

			update_bitmap_information_leader
			update_anim_leader
		end

		def update_bitmap_anim_bg
			return if @oldscene == @scene
			file = "Graphics/Pictures/Trainer Card BW/TrainerCard/trainercardbg#{@scene}"
			@sprites["anim bg"].setBitmap(file)
			@oldscene = @scene.clone

			# Update background
			update_show_or_not_leader_scene

			set_visible_sprite("trainer card", @scene == 1)
			set_visible_sprite("trainer", @scene == 1)
		end

		def update_anim_bg
			@sprites["anim bg"].ox -= 0.5
			@sprites["anim bg"].oy -= 0.5
		end

		# Update background
		def update_show_or_not_leader_scene
			show = @scene == 2
			set_visible_sprite("bg leader", show)
			8.times { |i|
				visible = show && $Trainer.badges[i + @region * 8]
				set_visible_sprite("badge #{i}", visible)
				set_visible_sprite("leader #{i}", show)
			}
		end

		# Update leader
		def update_bitmap_anim_leader
			return if @scene == 1
			return if @numchose == -1
			set_sprite("bitmap leader", SET[@numchose + @region * 8][0], "Trainers")
			h = @sprites["bitmap leader"].bitmap.height
			set_src_wh_sprite("bitmap leader", h, h)
			@sprites["bitmap leader"].src_rect.x = 0
			set_oxoy_sprite("bitmap leader", h / 2, h / 2)
		end

		def update_anim_leader
			notbadge = @numchose != -1 && $Trainer.badges[@numchose + @region * 8]
			set_visible_sprite("bitmap leader", @scene == 2 && @chose && notbadge)
			return if @scene == 1
			if !@chose && !notbadge
				@frames = 0
				return
			end
			@frames += 1
			return if @frames % 4 == 0
			bitmap = @sprites["bitmap leader"]
			return if bitmap.src_rect.x + bitmap.bitmap.height == bitmap.bitmap.width
			bitmap.src_rect.x += bitmap.bitmap.height
		end

		# Update icon
		def update_icon(left=false)
			num  = left ? 2 : 3
			wait = 5
			num *= wait
			num.times {
				update_ingame
				update_anim_bg

				@waitanim += 1
				next if @waitanim % wait != 0
				if left
					@sprites["left icon"].src_rect.x += @sprites["left icon"].src_rect.width
				else
					@sprites["right icon"].src_rect.x += @sprites["right icon"].src_rect.width
				end
			}
			@waitanim = 0
			@sprites["left icon"].src_rect.x = 0
			@sprites["right icon"].src_rect.x = 0
		end

		def update_bitmap_information_leader
			show = @chose
			set_visible_sprite("information", show)
			set_visible_sprite("bitmap leader", show)
		end

	end
end