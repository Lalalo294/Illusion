module MGBW
	class Show

		def show
			create_scene
			# Draw text
			draw_text
			loop do
				break if @exit
				update_ingame
				# Update
				update_main
				# Draw text
				draw_text
				# Set input
				set_input
			end
		end

		def create_scene
			# Background
			create_sprite("bg", "bg", @viewport)
			set_xy_sprite("bg", 0, -16)
			create_sprite("bg receive", "bgReceiving", @viewport)
			set_xy_sprite("bg receive", 0, -16)
			@sprites["bg receive"].opacity = 0
			# Menu
			create_sprite("menu", "menu", @viewport)
			create_sprite("select menu", "menuarrow", @viewport)
			w = @sprites["select menu"].bitmap.width
			h = @sprites["select menu"].bitmap.height / 2
			set_src_wh_sprite("select menu", w, h)
			set_xy_sprite("select menu", 64, 24)
			# Album
			create_scene_album
			# Gift
			create_scene_get
			# Message window
			@sprites["messagewindow"] = Window_AdvancedTextPokemon.newWithSize("Welcome to Mystery Gift!", 4, 288, Graphics.width - 8, 96, @viewport)
			@sprites["messagewindow"].letterbyletter = false
			@sprites["messagewindow"].width = @sprites["messagewindow"].width  
			pbSetSystemFont(@sprites["messagewindow"].contents)
			# Text
			create_sprite_2("menu text", @viewport)
			create_sprite_2("album text", @viewport)
			create_sprite_2("entry text", @viewport)
		end

		#-------#
		# Album #
		#-------#
		def create_scene_album
			create_sprite("album", "album_bg", @viewport)
			set_visible_sprite("album")
			4.times { |i|
				create_sprite("album card #{i}", "album_cards", @viewport)
				x = 52 + 240 * (i / 2)
				y = i.even? ? 68 : 196
				set_xy_sprite("album card #{i}", x, y)
				set_visible_sprite("album card #{i}")
			}
			create_sprite("arrow", "album_arrows", @viewport)
			w = @sprites["arrow"].bitmap.width
			h = @sprites["arrow"].bitmap.height / 4
			set_src_wh_sprite("arrow", w, h)
			size = @trainer.wonder_cards.size
			y = size < 4 ? 0 : h
			set_src_xy_sprite("arrow", 0, y)
			set_visible_sprite("arrow")
			create_sprite("cursor album", "album_cursor", @viewport)
			x = 12
			y = 58
			set_xy_sprite("cursor album", x, y)
			set_visible_sprite("cursor album")
		end

		#----------#
		# Get gift #
		#----------#
		def create_scene_get
			create_sprite("entry", "entrybg", @viewport)
			set_visible_sprite("entry")
			# Base
			create_sprite("base", "base", @viewport)
			x = (Graphics.width - @sprites["base"].bitmap.width) / 2
			y = Graphics.height - 110
			set_xy_sprite("base", x, y)
			set_visible_sprite("base")
			create_sprite("base receive", "baseReceiving", @viewport)
			set_xy_sprite("base receive", x, y)
			set_visible_sprite("base receive")
		end

		#---------#
		# Message #
		#---------#
		def message_infor
			ret =
				case @select
				when 0 then "Mystery Gift allows you to receive great gifts through internet.\nOnce you received a gift, please go to any Pokémon Center and pick it up from the deliveryman."
				when 1 then "When you've received your Mystery Gift, your Wonder Card will be displayed in the Card Album.\nYou can check the card to see if you've picked up the gift from a deliveryman.\nMake sure to pick up gifs waiting for you."
				when 2 then "You must press code to get Mystery Gift."
				else ""
				end
			return ret
		end

		#-------------------#
		# Text entry (code) #
		#-------------------#
		def press_code
			return unless @press
			set_visible_sprite("entry", true)
			Input.text_input = true
			Input.gets.chomp.clear
			loop do
				break if Input.triggerex?(:RETURN) || Input.repeatex?(:RETURN)
				update_ingame
				# Input
				set_input_gift
				# Text
				text_entry
			end
			# Reset
			Input.text_input = false
			@cursor = 0
			clearTxt("entry text")
			set_visible_sprite("entry")
			@press = false
		end

		def check_code
			ret = false
			@gift.each { |g|
				if "#{g[0]}" == @words.join
					@got = g
					ret = true
				end
			}
			return ret
		end

		def receive_gift_anim
			set_visible_sprite("messagewindow")
			# Gift
			@sprites["gift"] = Sprite.new(@viewport) if !@sprites["gift"]
			file =
				if @got[1] == 0 # Pokemon
					pkmn = @got[2]
					species = pkmn.species
      		species = GameData::Species.get(species).species
					GameData::Species.sprite_filename(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, false, pkmn.egg?)
				else # Item
					GameData::Item.icon_filename(@got[2])
				end
			@sprites["gift"].bitmap = Bitmap.new(file)
			w = @sprites["gift"].bitmap.width
			h = @sprites["gift"].bitmap.height
			div = w > h ? w / h : 1
			set_src_wh_sprite("gift", h, h)
			ox = h / 2
			oy = h / 2
			set_oxoy_sprite("gift", ox, oy)
			x = Graphics.width  / 2
			y = -oy
			set_xy_sprite("gift", x, y)
			set_visible_sprite("gift", true)
			# Set visible
			set_visible_sprite("bg receive", true)
			set_visible_sprite("base receive", true)
			@sprites["bg receive"].opacity   = 0
			@sprites["base receive"].opacity = 0
			# Anim
			count  = 0
			wait   = 0
			anim   = 0
			me     = false
			cbreak = 0
			loop do
				update_ingame

				update_blue_bg
				@sprites["bg receive"].y = @sprites["bg"].y

				if count < 50
					@sprites["bg receive"].opacity += 255 / 80 if @sprites["bg receive"].opacity < 255
					if @sprites["base receive"].opacity < 255
						@sprites["base receive"].opacity += 255 / 120 if @sprites["bg receive"].opacity >= 255
					else
						set_visible_sprite("base", true)
						y = @sprites["base receive"].y + @sprites["base receive"].src_rect.height / 2 - oy
						if @sprites["gift"].y < y
							@sprites["gift"].y += 2
						else
							if !me
								pbMEPlay("Battle capture success")
								me = true
							end
							@sprites["gift"].y = y
							if div > 1
								wait += 1
								anim += 1 if wait % 4 == 0
								if anim >= div
									div = 1
									set_src_xy_sprite("gift", 0, 0)
								else
									set_src_xy_sprite("gift", h * anim, 0)
								end
							else
								count += 1
							end
						end
					end
				else
					if @sprites["bg receive"].opacity > 0
						@sprites["base receive"].opacity -= 255 / 80
						@sprites["bg receive"].opacity -= 255 / 80 
					else
						set_visible_sprite("messagewindow", true)
						if cbreak == 0
							@sprites["messagewindow"].text = "The gift has been received!"
							@wnxt += 1
							if @wnxt > 50
								@wnxt = 0
								cbreak += 1
							end
						else
							@sprites["messagewindow"].text = "Please, pick up your gift from the deliveryman in any Pokémon Center!"
							@wnxt += 1
							if @wnxt > 80
								@wnxt = 0
								break
							end
						end
					end

				end

			end
			# Set visible
			set_visible_sprite("messagewindow")
			set_visible_sprite("bg receive")
			set_visible_sprite("base")
			set_visible_sprite("base receive")
			set_visible_sprite("gift")
			# Store wonder card
			@date = pbGetTimeNow.getgm.to_i
			hash  = { @date => @got }
			@trainer.wonder_cards  << hash
			@trainer.mystery_gifts << @got
			@gift.delete(@got)
			# Show wonder card
			show_wonder_card(@got, @date)
			# Reset variable
			@got  = nil
			@date = nil
			# Return main page
			@bg = :main
			set_visible_sprite("messagewindow", true)
		end

		def show_wonder_card(got, date)
			fade_in
			# Wonder card
			create_sprite("wonder card", "wondercard", @viewport) if !@sprites["wonder card"]
			set_visible_sprite("wonder card", true)
			# Text
			create_sprite_2("wonder card text", @viewport) if !@sprites["wonder card text"]
			# Icon
			@sprites["icon wonder card"] = Sprite.new(@viewport) if !@sprites["icon wonder card"]
			file =
				if got[1] == 0 # Pokemon
					pkmn = got[2]
					species = pkmn.species
      		species = GameData::Species.get(species).species
					GameData::Species.icon_filename(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, pkmn.egg?)
				else
					GameData::Item.icon_filename(got[2])
				end
			@sprites["icon wonder card"].bitmap = Bitmap.new(file)
			w = @sprites["icon wonder card"].bitmap.width
			h = @sprites["icon wonder card"].bitmap.height
			div = w > h ? w / h : 1
			set_src_wh_sprite("icon wonder card", h, h)
			set_oxoy_sprite("icon wonder card", h / 2, h / 2)
			x = 406 + 25
			y = 28 + 22
			y -= 6 if got[1] == 0
			set_xy_sprite("icon wonder card", x, y)
			set_visible_sprite("icon wonder card")
			# Draw
			description = got.size == 5 ? (split_text(got[4], 436)) : nil
			# Text
			text_wonder_card(description, got, date)
			set_visible_sprite("icon wonder card", true)
			fade_out
			# Anim
			count = 0
			anim  = 0
			loop do
				update_ingame
				break if checkInput(Input::USE) || checkInput(Input::BACK)
				# Text
				text_wonder_card(description, got, date)
				# Icon
				x = div > 1 ? (h * anim) : 0
				set_src_xy_sprite("icon wonder card", x, 0)
				count += 1
				anim  += 1 if count % 4 == 0
				anim   = 0 if anim >= div
			end
			fade_in
			# Set visible
			clearTxt("wonder card text")		
			set_visible_sprite("wonder card")
			set_visible_sprite("icon wonder card")
		end

		#------#
		# Fade #
		#------#
		def fade_in
			return if @fade
			numFrames = (Graphics.frame_rate*0.4).floor
  		alphaDiff = (255.0/numFrames).ceil
			(0..numFrames).each { |i|
				@blackvp.color = Color.new(0, 0, 0, i * alphaDiff)
				pbWait(1)
			}
			@fade = true
		end

		def fade_out
			return unless @fade
			numFrames = (Graphics.frame_rate*0.4).floor
  		alphaDiff = (255.0/numFrames).ceil
			(0..numFrames).each { |i|
				@blackvp.color = Color.new(0, 0, 0, (numFrames - i) * alphaDiff)
				pbWait(1)
			}
			@fade = false
		end

	end
end