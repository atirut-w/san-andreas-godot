extends Node

var _packagelist: PoolStringArray = []

func _ready() -> void:
    GameManager.connect("initialized", self, "init")

func init() -> void:
    print("Initializing Audio Manager")
    _load_packagelist()

func _load_packagelist() -> void:
    print("Loading SFX packages")
    var file := File.new()
    var err = file.open(GameManager.game_path + "/audio/CONFIG/PakFiles.dat", File.READ)
    if err != OK:
        print("Error opening PakFiles.dat")
        return

    for i in file.get_len() / 52:
        var namebuffer := file.get_buffer(52) as PoolByteArray
        _packagelist.append(namebuffer.get_string_from_utf8())
    file.close()
    print("Loaded %d SFX package(s)" % _packagelist.size())
