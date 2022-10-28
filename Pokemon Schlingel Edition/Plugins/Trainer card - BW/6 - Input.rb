module TCBW
	class Show
		DELAY_MOUSE = 0

		#-------#
		# Mouse #
		#-------#
		# Check delay
		def delayMouse(num=1)
			m = self.posMouse
			if m.nil?
				@oldm = nil
				return true
			end
			@delay += 1
			@delay  = 0 if @oldm != m && @delay > num
			return true if @delay < num
			@oldm = m
			return false
		end

		def value_mouse
			delay = delayMouse(DELAY_MOUSE)
			return :no_mouse if delay || @oldm.nil?
			return check_mouse
		end

		def check_mouse
			return :left_icon if areaMouse?([@sprites["left icon"].x, @sprites["left icon"].y, @sprites["left icon"].src_rect.width, @sprites["left icon"].src_rect.height])
			return :right_icon if areaMouse?([@sprites["right icon"].x, @sprites["right icon"].y, @sprites["right icon"].src_rect.width, @sprites["right icon"].src_rect.height])
			# Scene: badge
			8.times { |i| return i if areaMouse?([@sprites["leader #{i}"].x, @sprites["leader #{i}"].y, @sprites["leader #{i}"].src_rect.width, @sprites["leader #{i}"].src_rect.height]) } if @scene == 2
		end

		def update_mouse
			value = value_mouse
			return unless clickedMouse?
			case value
			when :no_mouse then return
			when :left_icon
				input_use
			when :right_icon
				input_back
			when 0...8
				return unless $Trainer.badges[value + @region * 8]
				return if @numchose == value && @chose
				change_bitmap_leader(value)
			end
		end

		def update_keyboard
			if checkInput(Input::BACK)
				input_back
			elsif checkInput(Input::USE)
				input_use
			elsif checkInput(Input::LEFT)
				return if @scene == 1
				if @numchose == -1
					value = 0
					return unless $Trainer.badges[value + @region * 8]
				else
					value = @numchose
					loop do
						value -= 1
						if !$Trainer.badges[value + @region * 8]
							value -= 1
							break if value < 0
						else
							break
						end
					end
					return if value < 0
				end
				change_bitmap_leader(value)
			elsif checkInput(Input::RIGHT)
				return if @scene == 1
				if @numchose == -1
					value = 7
					return unless $Trainer.badges[value + @region * 8]
				else
					value = @numchose
					loop do
						value += 1
						if !$Trainer.badges[value + @region * 8]
							value += 1
							break if value > 7
							break if $Trainer.badges[value + @region * 8]
						else
							break
						end
					end
					return if value > 7
				end
				change_bitmap_leader(value)
			end
		end

		def change_bitmap_leader(value)
			# Update text
			@framesTxt = 0
			@oriTxt = 0
			@numchose = value
			# Update bitmap
			update_bitmap_anim_leader
			# Set bitmap
			@chose = true
			@sprites["right icon"].src_rect.y = @sprites["right icon"].src_rect.height
			# Draw text
			text_name_leader
			text_speech_leader
		end

		def input_back
			update_icon
			@chose ? (@chose = false) : (@exit = true)
			@sprites["right icon"].src_rect.y = 0 unless @chose
		end

		def input_use
			update_icon(true)
			@scene = @scene == 1 ? 2 : 1
			if @scene == 1
				@chose = false
				@sprites["right icon"].src_rect.y = 0
				@sprites["left icon"].src_rect.y = 0
			else
				@sprites["left icon"].src_rect.y = @sprites["left icon"].src_rect.height
			end
		end
	end
end