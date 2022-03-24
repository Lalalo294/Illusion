module TCBW

	class Show
		
		def initialize
			@sprites = {}
			# Viewport
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999

			# Check mouse and use
			@oldm = [0, 0]
			@delay = 0
			# Set mouse sounds when move
			@semouse = 0

			# Set scene (0: trainer, 1: badge)
			@scene = 1
			@oldscene = 1

			# Check animation of text
			@framesTxt = 0
			@oriTxt = 0

			# Check chose trainer
			@chose = false
			@numchose = -1

			# Wait when clicking icon
			@waitanim = 0

			# Use animated of trainer
			@frames = 0

			# Get the current region
			@region = pbGetCurrentRegion(0)

			# Finish
			@exit = false
		end

	end

	def self.show
		pbFadeOutIn {
			f = Show.new
			f.show
			f.endScene
		}
	end

end

class PokemonTrainerCardScreen
	def initialize(scene) = TCBW.show

	def pbStartScreen
	end
end