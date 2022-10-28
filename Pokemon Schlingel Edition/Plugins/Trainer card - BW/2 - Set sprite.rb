module TCBW
	class Show

		#------------#
		# Set bitmap #
		#------------#
		# Image
		def create_sprite(spritename,filename,vp,dir="")
			@sprites["#{spritename}"] = Sprite.new(vp)
			folder = "Trainer Card BW"
			file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
			@sprites["#{spritename}"].bitmap = Bitmap.new(file)
		end
		def set_sprite(spritename,filename,dir="")
			folder = "Trainer Card BW"
			file = dir ? "Graphics/Pictures/#{folder}/#{dir}/#{filename}" : "Graphics/Pictures/#{folder}/#{filename}"
			@sprites["#{spritename}"].bitmap = Bitmap.new(file)
		end
		def set_bitmap(spritename, filename, vp)
			@sprites["#{spritename}"] = Sprite.new(vp)
			@sprites["#{spritename}"].bitmap = Bitmap.new(filename)
		end
		# Set ox, oy
		def set_oxoy_sprite(spritename,ox,oy)
			@sprites["#{spritename}"].ox = ox
			@sprites["#{spritename}"].oy = oy
		end
		# Set x, y
		def set_xy_sprite(spritename,x,y)
			@sprites["#{spritename}"].x = x
			@sprites["#{spritename}"].y = y
		end
		# Set zoom
		def set_zoom_sprite(spritename,zoom_x,zoom_y)
			@sprites["#{spritename}"].zoom_x = zoom_x
			@sprites["#{spritename}"].zoom_y = zoom_y
		end
		# Set visible
		def set_visible_sprite(spritename,vsb=false)
			@sprites["#{spritename}"].visible = vsb
		end
		# Set angle
		def set_angle_sprite(spritename,angle)
			@sprites["#{spritename}"].angle = angle
		end
		# Set src
		# width, height
		def set_src_wh_sprite(spritename,w,h)
			@sprites["#{spritename}"].src_rect.width = w
			@sprites["#{spritename}"].src_rect.height = h
		end
		# x, y
		def set_src_xy_sprite(spritename,x,y)
			@sprites["#{spritename}"].src_rect.x = x
			@sprites["#{spritename}"].src_rect.y = y
		end
		#------#
		# Text #
		#------#
		# Draw
		def create_sprite_2(spritename, vp, w=Graphics.width, h=Graphics.height)
			@sprites["#{spritename}"] = Sprite.new(vp)
			@sprites["#{spritename}"].bitmap = Bitmap.new(w, h)
		end
		# Write
		def drawTxt(bitmap,textpos,font=nil,fontsize=nil,width=0,pw=false,height=0,ph=false,clearbm=true)
			# Sprite
			bitmap = @sprites["#{bitmap}"].bitmap
			bitmap.clear if clearbm
			# Set font, size
			(font!=nil)? (bitmap.font.name=font) : pbSetSystemFont(bitmap)
			bitmap.font.size = fontsize if !fontsize.nil?
			textpos.each { |i|
				if pw
					i[1] += width==0 ? 0 : width==1 ? bitmap.text_size(i[0]).width/2 : bitmap.text_size(i[0]).width
				else
					i[1] -= width==0 ? 0 : width==1 ? bitmap.text_size(i[0]).width/2 : bitmap.text_size(i[0]).width
				end
				if ph
					i[2] += height==0 ? 0 : height==1 ? bitmap.text_size(i[0]).height/2 : bitmap.text_size(i[0]).height
				else
					i[2] -= height==0 ? 0 : height==1 ? bitmap.text_size(i[0]).height/2 : bitmap.text_size(i[0]).height
				end
				i[2] += 10
			}
			pbDrawTextPositions(bitmap,textpos)
		end
		# Clear
		def clearTxt(bitmap)
			@sprites["#{bitmap}"].bitmap.clear
		end
		#------------------------------------------------------------------------------#
		# Set SE for input
		#------------------------------------------------------------------------------#
		def checkInput(name, exact = false)
			if exact
				if Input.triggerex?(name)
					name == :X ? pbPlayCloseMenuSE : pbPlayDecisionSE
					return true
				end
			else
				if Input.trigger?(name)
					name == Input::BACK ? pbPlayCloseMenuSE : pbPlayDecisionSE
					return true
				end
			end
			return false
		end
		#-------#
		# Mouse #
		#-------#
		# Position
		# Return value x, y of mouse
		# Return nil if mouse isn't in window
		def posMouse = (Mouse::getMousePos)
		# Click
		def clickedMouse?
			if Input.trigger?(Input::MOUSERIGHT) || Input.trigger?(Input::MOUSELEFT)
				@semouse += 1
				pbPlayDecisionSE if @semouse==1
				return true
			end
			@semouse = 0
			return false
		end
		# Check area
		def areaMouse?(arr)
			if !arr.is_a?(Array) || arr.size!=4
				p "Check area mouse"
				Kernel.exit!
			end
			return false if @oldm.nil?
			x = arr[0]; y = arr[1]; w = arr[2]; h = arr[3]
			rect = [x,w+x,y,h+y]
			m = @oldm
			return true if m[0].between?(rect[0], rect[1]) && m[1].between?(rect[2], rect[3])
			return false
		end
		# Check area (circle)
		def circleMouse?(arr)
			if !arr.is_a?(Array) || arr.size!=3
				p "Check area (circle) mouse"
				Kernel.exit!
			end
			return false if @oldm.nil?
			x = arr[0]; y = arr[1]; r = arr[2]
			rect = [x, 2*r+x, y, 2*r+y]
			m = @oldm.clone
			return false if m[0] < rect[0] || m[0] > rect[1] || m[1] < rect[2] || m[1] > rect[3]
			2.times { |i| m[i] -= arr[i] if m[i] >= arr[i] }
			equation = (m[0] - r)**2 + (m[1] - r)**2
			return equation<=(r**2)
		end
		# Check pixel
		def pixelMouse?(sprite)
			return false if !sprite
			return false if @oldm.nil?
			mousex = @oldm[0]
			mousey = @oldm[1]
			xmax = sprite.x - sprite.ox + sprite.src_rect.width
			xmin = sprite.x - sprite.ox
			ymax = sprite.y - sprite.oy + sprite.src_rect.height
			ymin = sprite.y - sprite.oy
			return false if mousex > xmax || mousex < xmin || mousey > ymax || mousey < ymin
			arr = pixel_bitmap_can_see_ww_h(sprite.bitmap)
			return false if arr.nil?
			return false if !arr.is_a?(Array)
			return !arr[mousey-sprite.y+sprite.oy][mousex-sprite.x+sprite.ox].nil? rescue false
		end
		#------------------------------------------------------------------------------#
    # Dispose
    def dispose(id=nil)
      (id.nil?)? pbDisposeSpriteHash(@sprites) : pbDisposeSprite(@sprites,id)
    end
    # Update (just script)
    def update
      pbUpdateSpriteHash(@sprites)
    end
    # Update
    def update_ingame
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
    end
    # End
    def endScene
      # Dipose sprites
      self.dispose
      # Dispose viewport
      @viewport.dispose
    end

	end
end