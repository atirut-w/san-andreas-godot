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

class BankMeta:
    var package_index: int
    var padding: PoolIntArray
    var bank_header_offset: int
    var bank_size: int
