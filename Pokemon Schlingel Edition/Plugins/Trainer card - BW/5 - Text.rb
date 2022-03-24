module TCBW
	class Show

		# Split text
		def split_text(text1, width)
			i = 0
			str = ""
			text2 = []
			length = text1.length
			real = length * 12
			# Use to define 'Space'
			space = 0
			first = true
			strfake = ""
			loop do
				break if i == text1.length
				if first
					if text1[i] == " "
						i += 1
						next
					end
					first = false
				end
				space += 1 if text1[i] == " "
				str << text1[i] if space < 1
				if space > 0
					if text1[i] == "\n"
						text2 << (str + strfake)
						strfake = ""
						str = ""
						space = 0
					else
						strfake << text1[i]
						if space == 2 && i+1 != text1.length
							if (str.length + strfake.length) * 12 > width
								text2 << str
								str = strfake
							else
								str << strfake
							end
							strfake = ""
							space = 1
						elsif i+1 == text1.length
							text2 << (str + strfake)
						end
					end
				else

					if text1[i] == "\n"
						text2 << str
						str = ""

					else
						text2 << str if i+1 == text1.length
					end
				end
				i += 1
			end
			return text2
		end

		# Draw text
		def draw_main
			text_trainer
			text_name_leader
			text_speech_leader
		end

		def text_trainer
			clearTxt("trainer text")
			return if @scene == 2

			baseColor   = Color.new(72,72,72)
			shadowColor = Color.new(160,160,160)

			totalsec = Graphics.frame_count / Graphics.frame_rate
			hour = totalsec / 60 / 60
			min = totalsec / 60 % 60
			time = (hour>0) ? _INTL("{1}h {2}m",hour,min) : _INTL("{1}m",min)
			$PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime

			starttime = _INTL("{1} {2}, {3}", pbGetAbbrevMonthName($PokemonGlobal.startTime.mon), $PokemonGlobal.startTime.day, $PokemonGlobal.startTime.year)
			text = [
				[_INTL("Name"), 51, 58, 0, baseColor, shadowColor],
				[_INTL("Money"), 51, 122, 0, baseColor, shadowColor],
				[_INTL("Pokédex"),51, 202, 0, baseColor, shadowColor],
				[_INTL("Time"), 51, 237, 0, baseColor, shadowColor],
				[_INTL("Started"), 51, 264, 0, baseColor, shadowColor]
			]

			bitmap = @sprites["trainer text"].bitmap

			# Name
			string = $Trainer.name
			x = 302 - bitmap.text_size(string).width
			y = 58
			text << [string, x, y, 0, baseColor, shadowColor]
			# ID
			string = "ID No."
			x = 51
			y = 90
			text << [string, x, y, 0, baseColor, shadowColor]
			string = sprintf("%05d",$Trainer.public_ID)
			x = 302 - bitmap.text_size(string).width
			y = 90
			text << [string, x, y, 0, baseColor, shadowColor]
			# Money
			string = _INTL("${1}",$Trainer.money.to_s_formatted)
			x = 302 - bitmap.text_size(string).width
			y = 122
			text << [string, x, y, 0, baseColor, shadowColor]
			# Pokedex
			string = sprintf("%d/%d",$Trainer.pokedex.owned_count,$Trainer.pokedex.seen_count)
			x = 463 - bitmap.text_size(string).width
			y = 202
			text << [string, x, y, 0, baseColor, shadowColor]
			# Time
			string = time
			x = 463 - bitmap.text_size(string).width
			y = 237
			text << [string, x, y, 0, baseColor, shadowColor]
			# Started
			string = starttime
			x = 463 - bitmap.text_size(string).width
			y = 264
			text << [string, x, y, 0, baseColor, shadowColor]

			drawTxt("trainer text", text)
		end

		def text_name_leader
			clearTxt("infor leader")
			return if @scene == 1
			return unless @chose
			text = []

			baseColor = Color.new(255,255,255)
			shadowColor = Color.new(181,189,206)

			string = "#{SET[@numchose][1]} Gym Leader"
			x = 16
			y = 178
			text << [string, x, y, 0, baseColor, shadowColor]
			string = SET[@numchose][2]
			y += 20 + 5
			text << [string, x, y, 0, baseColor, shadowColor]

			bitmap = @sprites["infor leader"].bitmap
			string = SET[@numchose][4]
			x = (Graphics.width - bitmap.text_size(string).width) / 2
			h = @sprites["bar icon"].bitmap.height
			y = Graphics.height - h + 2
			text << [string, x, y, 0, baseColor, shadowColor]

			drawTxt("infor leader", text)
		end

		def text_speech_leader
			clearTxt("infor leader 2")
			return if @scene == 1
			unless @chose
				@framesTxt = 0
				@oriTxt = 0
				return
			end
			text = []

			baseColor = Color.new(255,255,255)
			shadowColor = Color.new(181,189,206)
			
			maxshow = 2

			arr = split_text(SET[@numchose][3], 336)

			if arr.size > maxshow
				@framesTxt += 1
				if @framesTxt > 2 ** 6
					@framesTxt = 0
					@oriTxt += 1
					@oriTxt  = 0 if @oriTxt >= arr.size
				end
				rest = @oriTxt + maxshow - arr.size if @oriTxt + maxshow > arr.size
				arrfake = arr[@oriTxt...(@oriTxt + maxshow)]
				rest.times { |i| arrfake << arr[i] } if rest
				arr = arrfake
			end

			arr.each_with_index { |str, i|
				x = 16
				y = 252 + 30 * i
				text << [str.to_s, x, y, 0, baseColor, shadowColor]
			}

			drawTxt("infor leader 2", text)
		end

	end
end