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
				update_icon(true)
				@scene = @scene == 1 ? 2 : 1
				if @scene == 1
					@chose = false
					@sprites["right icon"].src_rect.y = 0
					@sprites["left icon"].src_rect.y = 0
				else
					@sprites["left icon"].src_rect.y = @sprites["left icon"].src_rect.height
				end
			when :right_icon
				update_icon
				@chose ? (@chose = false) : (@exit = true)
				@sprites["right icon"].src_rect.y = 0 unless @chose
			when 0...8
				return unless $Trainer.badges[value + @region * 8]
				return if @numchose == value && @chose
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
		end

	end
end