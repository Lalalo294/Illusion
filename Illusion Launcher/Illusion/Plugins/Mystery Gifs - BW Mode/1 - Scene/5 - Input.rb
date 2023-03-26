module MGBW
	class Show

		#-------#
		# Input #
		#-------#
		def set_input
			set_input_menu
			set_input_album
		end

		def set_input_menu
			return if @bg != :main && @bg != :infor
			@bg == :infor ? (@bg = :main) : (@exit = true) if checkInput(Input::BACK)
			if checkInput(Input::USE)
				if @bg == :main
					case @select
					when 0
						@press = true
						@bg = :gift
					when 1
						set_visible_sprite("messagewindow")
						@bg = :album
					when 2
						@select = 0
						@bg = :infor
					when 3 then @exit = true
					end
				else
					if @select.between?(0, 2)
						pbMessage(_INTL(message_infor)) { update_blue_bg }
					else
						@bg = :main
					end
				end
			elsif checkInput(Input::UP)
				@select -= 1
				@select  = 3 if @select < 0
			elsif checkInput(Input::DOWN)
				@select += 1
				@select  = 0 if @select > 3
			end
		end

		def set_input_gift
			if Input.triggerex?(:BACKSPACE) || Input.repeatex?(:BACKSPACE)
				if @words[@cursor].nil? || @words[@cursor] == ""
					@cursor -= 1
					@cursor  = 0 if @cursor < 0
					@words[@cursor] = ""
				else
					@words[@cursor] = ""
				end
				return
			elsif Input.press?(Input::CTRL) && Input.triggerex?(:V)
				return if Input.clipboard.nil?
				words = Input.clipboard.split(//)
				words.delete(" ")
				num = 0
				words.each { |w|
					@words[@cursor] = w
					@cursor += 1
					if @cursor >= LIMIT_LENGTH
						@cursor -= 1
						break
					end
				}
				return
			end
			write = Input.gets.chomp
			if write.length > 1
				Input.gets.chomp.clear
				write = ""
			end
			return if write == "" || write == " "
			@words[@cursor] = write
			@cursor += 1
			@cursor -= 1 if @cursor >= LIMIT_LENGTH
		end

		def set_input_album
			return if @bg != :album
			if checkInput(Input::BACK)
				set_visible_sprite("messagewindow", true)
				@position = 0
				@startnum = 0
				@animwc   = [0, 0, 0, 0]
				@bg = :main
			end
			size = @trainer.wonder_cards.size
			return if size <= 0
			if checkInput(Input::ACTION)
				fade_in
				@bg = :infor_wc
			end
			return if size == 1
			if checkInput(Input::UP)
				@position -= 1
				if @position < @startnum
					if (@startnum - 1) >= 0
						@startnum -= 1
						@position  = @startnum
					elsif (@startnum - 1) < 0
						@startnum = size - @realquant
						@position = @startnum + @realquant - 1
					end
				end
			elsif checkInput(Input::DOWN)
				@position += 1
				limit = @startnum + @realquant - 1
				if @position > limit
					if (limit + 1 + 1) <= size
						@startnum += 1
						@position  = @startnum + @realquant - 1
					elsif (limit + 1 + 1) > size
						@startnum = 0
						@position = 0
					end
				end
			elsif checkInput(Input::LEFT)
				@position -= 2
				if @position < @startnum
					if (@startnum - 2) >= -1
						@startnum -= 2
						if @startnum < 0
							@startnum = 0 
							@position = @startnum
						end
					elsif (@startnum - 2) < -1
						@startnum = size - @realquant
						@position = @startnum + @realquant - 1
					end
				end
			elsif checkInput(Input::RIGHT)
				@position += 2
				limit = @startnum + @realquant - 1
				if @position > limit
					if (limit + 1 + 2) <= size + 1
						@startnum += 2
						@startnum  = size - @realquant if @startnum + @realquant > size
						@position  = @startnum + @realquant - 1 if @position >= size
					elsif (limit + 1 + 2) > size + 1
						@startnum = 0
						@position = 0
					end
				end
			end
		end

	end
end