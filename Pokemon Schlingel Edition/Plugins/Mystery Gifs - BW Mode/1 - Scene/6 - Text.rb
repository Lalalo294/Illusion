module MGBW
	class Show

		#-------#
		# Split #
		#-------#
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
					strfake << text1[i]
					if space == 2 && i+1 != text1.length
						if (str.length + strfake.length) * 12 > width
							text2 << str
							str = strfake
						elsif (str.length + strfake.length) * 12 <= width
							str << strfake
						end
						strfake = ""
						space = 1
					elsif i+1 == text1.length
						text2 << (str + strfake)
					end
				else
					text2 << str if i+1 == text1.length
				end
				i += 1
			end
			return text2
		end

		#------#
		# Text #
		#------#
		def draw_text
			text_menu
			text_album_card
		end

		def text_menu
			clearTxt("menu text")
			return if @bg != :main && @bg != :infor
			arr = @bg == :main ? ["RECEIVE GIFT", "CHECK THE CARD ALBUM", "INFOR"] : ["ABOUT MYSTERY GIFT", "ABOUT THE CARD ALBUM", "ABOUT CODE"]
			arr << "QUIT"
			@sprites["messagewindow"].text = @bg == :infor ? "What would you like to know about?" : "Welcome to Mystery Gift!"
			# Text
			text = []
			arr.each_with_index { |str, i|
				x = 80
				y = 26 + 56 * i
				text << [str, x, y, 0, Color.new(255,255,255), Color.new(165,165,173)]
			}
			drawTxt("menu text", text)
		end

		def text_entry
			clearTxt("entry text")
			text = []
			string = @words.join
			x = 135
			y = 179
			text << [string, x, y, 0, Color.new(255,255,255), Color.new(0,0,0)]
			drawTxt("entry text", text)
		end

		def text_album_card
			clearTxt("album text")
			return if @bg != :album
			size = @trainer.wonder_cards.size
			return if size <= 0
			text = []
			arr  = []
			n    = @startnum + @realquant
			@trainer.wonder_cards.each { |i| arr << MGBW.hash_array(i)[0] }
			(@startnum...n).each { |i|
				# Date
				date = arr[i][0]
				date = Time.at(date)
				string = "#{date.day}/#{date.mon}/#{date.year}"
				x = 12 + 240 * ((i - @startnum) / 2) + 70
				y = 67 + ((i - @startnum).even? ? 58 : 186)
				text << [string, x, y, 0, Color.new(0,0,0), Color.new(255,255,255)]
				# Order
				string = "#{i+1}"
				x = 12 + 240 * ((i - @startnum) / 2) + 10
				y = 3 + ((i - @startnum).even? ? 58 : 186)
				text << [string, x, y, 0, Color.new(255,255,255), Color.new(0,0,0)]
				# Press Action
				string = "Press Action: Informations"
				x = 20
				y = 343
				text << [string, x, y, 0, Color.new(255,255,255), Color.new(0,0,0)]
			}
			drawTxt("album text", text)
		end

		#--------------#
		# Wonder cards #
		#--------------#
		def text_wonder_card(description=nil, got=nil, date=nil)
			clearTxt("wonder card text")
			text = []
			# Title
			string = got[3]
			x = 37
			y = 91
			text << [string, x, y, 0, Color.new(0,0,0), Color.new(255,255,255)]
			# Description
			if description
				description.each_with_index { |str, i|
					x = 37
					y = 135 + (20 + 10) * i
					text << [str, x, y, 0, Color.new(0,0,0), Color.new(255,255,255)]
				}
			end
			# Date
			date = Time.at(date)
			string = "Date received: #{date.day}/#{date.mon}/#{date.year}"
			x = 72
			y = 315
			text << [string, x, y, 0, Color.new(255,255,255), Color.new(0,0,0)]
			drawTxt("wonder card text", text)
		end

	end
end