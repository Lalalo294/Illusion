module MGBW
	LIMIT_CODE = 100000
	# Use this when you set USE_PE = false
	# Maximum of length code is 5
	LIMIT_LENGTH = 5
	# If you set true, use method of PE (set gift)
	USE_PE = false
	# If you set true, you use custom method + PE (set gift). Read examples below to use this method.
	USE_CUSTOM = false
	# If ONLINE is true, this custom just creates file, you just update this file and player need to download it to update.
	# If not, this custom creates file to upload to the Internet
	ONLINE = true # false
	# File creates
	FILE_ONLINE  = "Mystery Gift.txt" # Copy and upload this file to Internet
	FILE_OFFLINE = "Mystery Gift"
	
=begin

Use @@list[name] = hash
	'name' defines code of Mystery gift, must be unique (Numeric)
	'hash' defines this gif (Pokemon or item)

	*****
	Value in this hash
		get -> Set if you want player can get this gift (Boolean)
		name -> name of this gift (String)
		type -> use :pkmn if it's pokemon. Use :item if it's item
		define -> If gif is pokemon, you will use Hash.
							If gif is item, you will use 'Array'
							-> [item name, quantity] or [item name] (in this case, quantity is 1)
		description -> description of gift (String)
	*****

	Value in this hash (Hash: define):
		name  -> Name of pokemon (Symbol)
		level -> Level of pokemon (Numeric) - If you don't set, it's 1
		owner -> Owner name of this pokemon (class Owner) - you can set or not (Suggest: set it)
						There are 4 values in Pokemon::Owner.new() -> ID of owner, name, gender, language
							ID -> Integer - set like this.
								We have number = (min: 0, max: 65535) -> ID = number | number << 16
								Ex: 3333 | 3333 << 16
								Or you can make it with random fuction, use this: rand(2 ** 16) | rand(2 ** 16) << 16
							name -> String
							gender -> 0 = male, 1 = female, 2 = unknown
							language -> Numeric (find pbGetLanguage - 2: English)
						If you want to set player is owner, set :trainer
						If you want to id is different Trainer id, set :foreign
		other -> other features of pokemon (use Proc) - Use class Pokemon
	
=end
# Add new gift below this line
	@@list[314] = {
		get: true,
		name: "A dragon",
		type: :pkmn,
		define: {
			name: :CHARIZARD,
			level: 50,
			owner: Pokemon::Owner.new(2234 | 2234 << 16, "Mask", 0, 2),
			other: Proc.new { |pkmn|
				pkmn.shiny = true
				pkmn.item = :EVERSTONE
				pkmn.learn_move(:EMBER)
				pkmn.calc_stats
				next pkmn
			}
		},
		description: "This is Charizard! Dra... Not Dragon!!!"
	}

	@@list[12561] = {
		get: true,
		name: "A little gift",
		type: :item,
		define: [:MAXPOTION, 5],
		description: "Do you like this gift? HAHA!!!"
	}

	@@list["ky781"] = {
		get: true,
		name: "Legend gift",
		type: :pkmn,
		define: {
			name: :KYUREM,
			level: 70,
			owner: :trainer,
			other: Proc.new { |pkmn|
				pkmn.form = 2
				pkmn.item = :MASTERBALL
				pkmn.calc_stats
				next pkmn
			}
		},
		description: "Do you like this gift? A LEGEND!!!"
	}

	@@list["masT7"] = {
		get: true,
		name: "A gift",
		type: :item,
		define: [:MASTERBALL],
		description: "NORMAL BALL!!!"
	}

	@@list["VEFE"] = {
		get: true,
		name: "Big gift",
		type: :pkmn,
		define: {
			name: :VENUSAUR,
			level: 60,
			owner: :foreign,
			other: Proc.new { |pkmn|
				pkmn.gender = 1
				pkmn.calc_stats
				next pkmn
			}
		},
		description: "It's big, right?"
	}

	@@list["egg1"] = {
		get: true,
		name: "Food?!?",
		type: :pkmn,
		define: {
			name: :CHARMANDER,
			level: 60,
			owner: :foreign,
			other: Proc.new { |pkmn|
				pkmn.steps_to_hatch = 1200
				pkmn.calc_stats
				next pkmn
			}
		},
		description: "Egg!"
	}
# Add new gift above this line

	#-------------------------#
	# Don't touch these lines #
	#-------------------------#
	# Call: MGBW.get_gift_custom
	def self.get_gift_custom(exact=nil)
		return if USE_PE && !USE_CUSTOM
		# [id, type, item, giftname, description]
		# type: 0 - pkmn, > 0 - item quantity
		# item: pkmn: class Pokemon, item: Symbol (name)
		arr  = []
		arr1 = []
		return if self.caution
		@@list.each { |k, v|
			next if !v[:get]
			arr1[0] = USE_PE ? k : k.to_s
			arr1[1] = 
				case v[:type]
				when :item then v[:define].size > 1 ? v[:define][1] : 1
				when :pkmn then 0
				end
			arr1[2] = 
				case v[:type]
				when :item then v[:define][0]
				when :pkmn
					define = v[:define]
					owner = define[:owner]
					pkmn = 
						if owner == :trainer
							Pokemon.new(define[:name], define[:level])
						elsif owner == :foreign
							owner = Pokemon::Owner.new_foreign
							Pokemon.new(define[:name], define[:level], owner)
						elsif owner.nil?
							Pokemon.new(define[:name], define[:level], nil)
						else
							Pokemon.new(define[:name], define[:level], owner)
						end
					pkmn = define[:other].call(pkmn) if define[:other]
				end
			arr1[3] = v[:name] ? v[:name] : ""
			arr1[4] = v[:description] ? v[:description] : ""
			arr << arr1
			arr1 = []
		}
		if exact
			index = -1
			arr.each_with_index { |gift, i|
				next if gift[0] != exact
				index = i
				break
			}
			return [] if index == -1
			return arr[index]
		end
		return arr
	end

	#-----------------------#
	# Create file (Offline) #
	#-----------------------#
	# Call to use:
	# MGBW.encrypt
	# MGBW.decrypt
	def self.encrypt(name=nil)
		file = !name.nil? ? name : ONLINE ? FILE_ONLINE : FILE_OFFLINE
		return if self.caution
		arr = self.get_gift_custom
		return unless arr.is_a?(Array)
		return if arr.size < 1
		code = [Zlib::Deflate.deflate(Marshal.dump(arr))].pack("m")
		File.open(file, 'wb') { |f| f.write(code) }
	end

	def self.decrypt(name=nil, read=false)
		file = !name.nil? ? name : ONLINE ? pbDownloadToString(MysteryGift::URL) : FILE_OFFLINE
		return nil if nil_or_empty?(file)
		file = IO.read(file) if read || !ONLINE
		ret  = Marshal.restore(Zlib::Inflate.inflate(file.unpack("m")[0]))
		return ret
	end

	# Push new gift (custom) when you use PE
	def self.push_gift(id, name=nil)
		file = !name.nil? ? name : ONLINE ? FILE_ONLINE : FILE_OFFLINE
		arr  = self.decrypt(name)
		return unless arr.is_a?(Array)
		add = self.get_gift_custom(id)
		return if add.size == 0
		arr << add
		code = [Zlib::Deflate.deflate(Marshal.dump(arr))].pack("m")
		File.open(file, 'wb') { |f| f.write(code) }
		pbMessage(_INTL("Added gifts!"))
	end

end

#---------#
# Rewrite #
#---------#
def pbManageMysteryGifts
	filemaster = "MysteryGiftMaster.txt"
	unless MGBW::USE_PE && !MGBW::USE_CUSTOM
		MGBW.encrypt(filemaster) if !safeExists?(filemaster)
	end
	if !safeExists?(filemaster)
		pbMessage(_INTL("There are no Mystery Gifts defined."))
		return
	end
	# Load all gifts from the Master file.
	master = MGBW.decrypt(filemaster, true)
  if !master || !master.is_a?(Array) || master.length==0
    pbMessage(_INTL("There are no Mystery Gifts defined."))
    return
  end
  # Download all gifts from online
  msgwindow = pbCreateMessageWindow
	if MGBW::ONLINE
  	pbMessageDisplay(msgwindow,_INTL("Searching for online gifts...\\wtnp[0]"))
	else
		pbMessageDisplay(msgwindow,_INTL("Searching...\\wtnp[0]"))
	end
	# Decrypt
	if MGBW::USE_PE && !MGBW::USE_CUSTOM
		online = pbDownloadToString(MysteryGift::URL)
		online = pbMysteryGiftDecrypt(online)
	else
		online = MGBW.decrypt
	end
  pbDisposeMessageWindow(msgwindow)
	# Check
	message = MGBW::ONLINE ? "online" : ""
	if online.nil?
		pbMessage(_INTL("No #{message} Mystery Gifts found.\\wtnp[20]"))
    online = []
	else
		pbMessage(_INTL("#{message.capitalize} Mystery Gifts found.\\wtnp[20]"))
    t = []
    online.each { |gift| t.push(gift[0]) }
    online = t
	end
	# Show list of all gifts.
  command = 0
  loop do
    commands = pbRefreshMGCommands(master, online)
    command  = pbMessage(_INTL("\\ts[]Manage Mystery Gifts (X=online)."), commands, -1, nil, command)
    # Gift chosen
    if command == -1 || command == commands.length - 1   # Cancel
      break
    elsif command == commands.length - 2   # Export selected to file
      begin
        newfile = []
				master.each { |gift| newfile.push(gift) if online.include?(gift[0]) }
        string = pbMysteryGiftEncrypt(newfile)
				file = MGBW::ONLINE ? MGBW::FILE_ONLINE : MGBW::FILE_OFFLINE
        File.open(file, "wb") { |f| f.write(string) }
				pbMessage(_INTL("The gifts were saved to #{file}."))
				if MGBW::ONLINE
					pbMessage(_INTL("Upload #{file} to the Internet."))
				else
					pbMessage(_INTL("Put #{file} in your root game."))
				end
      rescue
        pbMessage(_INTL("Couldn't save the gifts to #{file}."))
      end
    elsif command.between?(0, commands.length - 1)   # A gift
      cmd = 0
			loop do
        commands = pbRefreshMGCommands(master,online)
        gift = master[command]
        cmds = [_INTL("Toggle on/offline"),
               _INTL("Edit"),
               _INTL("Receive"),
               _INTL("Delete"),
               _INTL("Cancel")]
        cmd = pbMessage("\\ts[]" + commands[command], cmds, -1, nil, cmd)
        if cmd == -1 || cmd == cmds.length - 1
          break
        elsif cmd == 0   # Toggle on/offline
          if online.include?(gift[0])
						(0...online.length).each { |i| online[i] = nil if online[i] == gift[0] }
            online.compact!
          else
            online.push(gift[0])
          end
        elsif cmd == 1   # Edit
					if MGBW::USE_CUSTOM
						if gift.size == 5
							pbMessage("You can't edit this gift, this is custom gift! Edit in file '0 - 2 - Set value.rb'!")
							next
						end
					end
					newgift = pbEditMysteryGift(gift[1], gift[2], gift[0], gift[3])
					master[command] = newgift if newgift
        elsif cmd == 2   # Receive
          if !$Trainer
            pbMessage(_INTL("There is no save file loaded. Cannot receive any gifts."))
            next
          end
          replaced = false
					(0...$Trainer.mystery_gifts.length).each { |i|
						next if $Trainer.mystery_gifts[i][0] != gift[0]
						$Trainer.mystery_gifts[i] = gift
						replaced = true
					}
					$Trainer.mystery_gifts.push(gift) if !replaced
          pbReceiveMysteryGift(gift[0])
        elsif cmd==3   # Delete
					if MGBW::USE_CUSTOM
						if gift.size == 5
							pbMessage("You can't delete this gift, this is custom gift! Delete in file '0 - 2 - Set value.rb'!")
							next
						end
					end
          if pbConfirmMessage(_INTL("Are you sure you want to delete this gift?"))
            master[command] = nil
            master.compact!
          end
          break
        end
			end
		end
	end
end

def pbMysteryGiftDecrypt(file)
  return [] if nil_or_empty?(file)
  ret = Marshal.restore(Zlib::Inflate.inflate(file.unpack("m")[0]))
	ret.each { |gift|
		if gift.size == 5
			gift[2] = GameData::Item.get(gift[2]).id if gift[1] != 0
		else
			# Pkmn : Item
			gift[2] = gift[1] == 0 ? PokeBattle_Pokemon.convert(gift[2]) : GameData::Item.get(gift[2]).id
		end
	}
	return ret
end