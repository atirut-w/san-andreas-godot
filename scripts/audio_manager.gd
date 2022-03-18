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

func load_bank(bank_index: int) -> BankHeader:
    print("Loading bank %d" % bank_index)
    var meta := _banklookup[bank_index] as BankMeta
    var file := File.new()

    var err = file.open(GameManager.game_path + "/audio/sfx/" + _packagelist[meta.package_index], File.READ)
    if err != OK:
        print("Error opening %s" % _packagelist[meta.package_index])
        return null

    file.seek(meta.bank_header_offset)
    var header := BankHeader.new()
    header.numsounds = file.get_16()
    header.padding = file.get_16()

    for i in header.numsounds:
        var sound := SoundMeta.new()
        sound.buffer_offset = file.get_32()
        sound.loop_offset = file.get_32()
        sound.sample_rate = file.get_16()
        sound.headroom = file.get_16()
        header.sounds.append(sound)
    file.close()
    print("Loaded %d sound(s)" % header.numsounds)
    return header

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
