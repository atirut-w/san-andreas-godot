extends Node

var _packagelist: PoolStringArray = []
var _banklookup := []

func _ready() -> void:
	GameManager.connect("initialized", self, "init")

func init() -> void:
	print("Initializing Audio Manager")
	_load_packagelist()
	_load_bank_lookup()

func _load_packagelist() -> void:
	print("Loading SFX packages")
	var file := File.new()
	var err := file.open(GameManager.game_path + "/audio/CONFIG/PakFiles.dat", File.READ)
	if err != OK:
		print("Error opening PakFiles.dat")
		return

	for i in file.get_len() / 52:
		var namebuffer := file.get_buffer(52) as PoolByteArray
		_packagelist.append(namebuffer.get_string_from_utf8())
	file.close()
	print("Loaded %d SFX package(s)" % _packagelist.size())

func _load_bank_lookup() -> void:
	print("Loading bank lookup")
	var file := File.new()
	var err := file.open(GameManager.game_path + "/audio/CONFIG/BankLkup.dat", File.READ)
	if err != OK:
		print("Error opening BankLkup.dat")
		return

	for i in file.get_len() / 12:
		var meta := BankMeta.new()
		meta.package_index = file.get_8()
		meta.padding.append(file.get_8())
		meta.padding.append(file.get_8())
		meta.padding.append(file.get_8())
		meta.bank_header_offset = file.get_32()
		meta.bank_size = file.get_32()

		_banklookup.append(meta)
	file.close()
	print("Loaded %d bank(s)" % _banklookup.size())

func load_bank(bank_id: int) -> BankHeader:
	var bank_meta := _banklookup[bank_id] as BankMeta
	var file := File.new()

	var err = file.open(GameManager.game_path + "/audio/sfx/" + _packagelist[bank_meta.package_index], File.READ)
	if err != OK:
		print("Error opening SFX package %s" % _packagelist[bank_meta.package_index])
		return null

	file.seek(bank_meta.bank_header_offset)
	var bank_header := BankHeader.new()
	bank_header.numsounds = file.get_16()
	bank_header.padding = file.get_16()

	for i in bank_header.numsounds:
		var sound_meta := SoundMeta.new()
		sound_meta.buffer_offset = file.get_32()
		sound_meta.loop_offset = file.get_32()
		sound_meta.sample_rate = file.get_16()
		sound_meta.headroom = file.get_16()
		bank_header.sounds.append(sound_meta)
	file.close()
	return bank_header

func load_sound(bank_id: int, sound_id: int) -> AudioStreamSample:
	var bank_header := load_bank(bank_id)
	var bank_meta := _banklookup[bank_id] as BankMeta
	if bank_header == null:
		return null
	var sound_meta := bank_header.sounds[sound_id] as SoundMeta

	# We calculate the audio length from the next sound's offset or the bank's
	# size.
	var audio_len := 0
	if sound_id < bank_header.numsounds - 1:
		audio_len = bank_header.sounds[sound_id + 1].buffer_offset - sound_meta.buffer_offset
	else:
		audio_len = bank_meta.bank_size - sound_meta.buffer_offset

	var file := File.new()
	var err := file.open(GameManager.game_path + "/audio/sfx/" + _packagelist[bank_meta.package_index], File.READ)
	if err != OK:
		print("Error opening SFX package %s" % _packagelist[bank_meta.package_index])
		return null
	file.seek(bank_meta.bank_header_offset + 4804 + sound_meta.buffer_offset)
	var buffer := file.get_buffer(audio_len) as PoolByteArray
	file.close()

	var stream := AudioStreamSample.new()
	stream.data = buffer
	stream.format = AudioStreamSample.FORMAT_16_BITS
	stream.mix_rate = sound_meta.sample_rate
	return stream

class BankMeta:
	var package_index: int
	var padding: PoolIntArray
	var bank_header_offset: int
	var bank_size: int

class SoundMeta:
	var buffer_offset: int
	var loop_offset: int
	var sample_rate: int
	var headroom: int

class BankHeader:
	var numsounds: int
	var padding: int
	var sounds: Array
