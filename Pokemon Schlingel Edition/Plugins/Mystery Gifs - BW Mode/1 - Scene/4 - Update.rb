module MGBW
	class Show

		#--------#
		# Update #
		#--------#
		def update_main
			update_blue_bg
			update_select_menu
			update_gift
			update_album_card
			update_infor_wc
		end

		def update_blue_bg
			@sprites["bg"].y += 1
			@sprites["bg"].y  = -16 if @sprites["bg"].y == 0
		end

		def update_select_menu
			set_visible_sprite("menu")
			set_visible_sprite("select menu")
			return if @bg != :main && @bg != :infor
			set_visible_sprite("menu", true)
			set_visible_sprite("select menu", true)
			h = @select == 3 ? @sprites["select menu"].src_rect.height : 0
			set_src_xy_sprite("select menu", 0, h)
			y = 24 + 56 * @select
			set_xy_sprite("select menu", 64, y)
			# Fade (use: show_wonder_card)
			fade_out
		end

		def update_gift
			if @bg != :gift
				@times = 0
				return
			end
			if @times < 2
				update_wait_msg("Checking for gifts, please wait")
			else
				if @gift.size == 0
					@sprites["messagewindow"].text = "No new gifts are available."
					@wnxt += 1
					if @wnxt > 50
						@wnxt = 0
						@bg = :main
					end
				else
					@sprites["messagewindow"].text = "Press code to get gift!"
					# Entry text
					press_code
					if check_code
						@words = []
						receive_gift_anim
					else
						@words = []
						@sprites["messagewindow"].text = "This gift doesn't exist!"
						@wnxt += 1
						if @wnxt > 50
							@wnxt = 0
							@bg = :main
						end
					end
				end
			end
		end

		def update_album_card
			set_visible_sprite("album")
			4.times { |i|
				set_visible_sprite("album card #{i}")
				set_visible_sprite("icon album card #{i}") if @sprites["icon album card #{i}"]
			}
			set_visible_sprite("arrow")
			set_visible_sprite("cursor album")
			return if @bg != :album
			set_visible_sprite("album", true)
			size = @trainer.wonder_cards.size
			# Arrows (above)
			h = @sprites["arrow"].src_rect.height
			y =
				if size <= 4
					0
				else
					@position < 4 ? 1 : @position.between?(size - 4, size - 1) ? 3 : 2
				end
			set_src_xy_sprite("arrow", 0, y * h)
			set_visible_sprite("arrow", true)
			return if size <= 0
			@realquant = size > 4 ? 4 : size
			set_visible_sprite("cursor album", size > 0)
			@realquant.times { |i|
				set_visible_sprite("album card #{i}", true)
				# Cursor
				next if (@startnum + i) != @position
				x = 12 + 240 * (i / 2)
				y = i.even? ? 58 : 186
				set_xy_sprite("cursor album", x, y)
			}
			# Wonder cards
			arr = []
			n   = @startnum + @realquant
			@trainer.wonder_cards.each { |i| arr << MGBW.hash_array(i)[0] }
			(@startnum...n).each { |i|
				# Icon
				@sprites["icon album card #{i-@startnum}"] = Sprite.new(@viewport) if !@sprites["icon album card #{i-@startnum}"]
				gift = arr[i][1]
				file =
					if gift[1] == 0 # Pokemon
						pkmn = gift[2]
						species = pkmn.species
						species = GameData::Species.get(species).species
						GameData::Species.icon_filename(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, pkmn.egg?)
					else # Item
						GameData::Item.icon_filename(gift[2])
					end
				@sprites["icon album card #{i-@startnum}"].bitmap = Bitmap.new(file)
				w = @sprites["icon album card #{i-@startnum}"].bitmap.width
				h = @sprites["icon album card #{i-@startnum}"].bitmap.height
				div = w > h ? w / h : 1
				set_src_wh_sprite("icon album card #{i-@startnum}", h, h)
				if @frames % 4 == 0
					@animwc[i-@startnum] += 1
					@animwc[i-@startnum]  = 0 if @animwc[i-@startnum] >= div
				end
				set_src_xy_sprite("icon album card #{i-@startnum}", h * @animwc[i-@startnum], 0)
				set_oxoy_sprite("icon album card #{i-@startnum}", h / 2, h / 2)
				x = 12 + 240 * ((i - @startnum) / 2) + 146 + 26
				y = 18 + ((i - @startnum).even? ? 58 : 186) + 23
				y -= 9 if gift[1] == 0
				set_xy_sprite("icon album card #{i-@startnum}", x, y)
				set_visible_sprite("icon album card #{i-@startnum}", true)
			}
			@frames += 1
			# Fade (use: show_wonder_card)
			fade_out
		end

		def update_infor_wc
			return if @bg != :infor_wc
			clearTxt("album text")
			arr = []
			@trainer.wonder_cards.each { |i| arr << MGBW.hash_array(i)[0] }
			gift = arr[@position]
			show_wonder_card(gift[1], gift[0])
			@bg = :album
		end

		#--------------#
		# Wait message #
		#--------------#
		def update_wait_msg(msg)
			@wait += 1
			@sprites["messagewindow"].visible = true
			@sprites["messagewindow"].text = msg if @wait == 1
			@sprites["messagewindow"].text = "#{msg}." if @wait.between?(2, 11)
			@sprites["messagewindow"].text = "#{msg}.." if @wait.between?(12, 21)
			@sprites["messagewindow"].text = "#{msg}..." if @wait.between?(22, 31)
			if @wait == 41
				@wait   = 0
				@times += 1
			end
		end
		
	end
end