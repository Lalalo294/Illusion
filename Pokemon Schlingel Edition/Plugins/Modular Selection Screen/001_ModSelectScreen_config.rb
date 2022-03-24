#-------------------------------------------------------------------------------
# Modular Selection Screen v1.0
#-------------------------------------------------------------------------------
#
# Based on Advanced Flexible Starter Selection by Limnodromus and Shiney570
# Edited and modified by CourteousGrizzly
#
#-------------------------------------------------------------------------------
#
# Provides a callable method to select from multiple pokemon for a starter
# selection screen or other gifted pokemon choice.
# Default method can be reused with a different selection of pokemon using only
# the arguments in the script event, but has limited configurability.
# Advanced method must be hard-coded within the script and copied to another
# method if multiple selections are desired, but offers high configurability.
#
# Version: 1.0.0
#
#-------------------------------------------------------------------------------
# File path for the default background
DEFAULT_BG_PATH = "Graphics/Pictures/Selection Screen/bg"

# Set the X and Y location of the TOP LEFT ball, based on a center origin of the ball sprite
# (all other ball are calculated dynamically from here)
DEFAULT_BALL_X = 140
DEFAULT_BALL_Y = 100

# Set the X and Y location of the selected Pokemon's sprite, based on a center origin of the Battler sprite
# (all stats displayed are calculated dynamically from here)
DEFAULT_POKE_X = 220
DEFAULT_POKE_Y = 175

# Select how many balls are in each row
BALL_ROW_SIZE = 5

# Choose whether to display a 'select' graphic over the pokeball
SELECTION_SPRITE = false