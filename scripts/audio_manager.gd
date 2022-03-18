extends Node

var packagelist := []

func _ready() -> void:
    GameManager.connect("initialized", self, "init")

func init() -> void:
    print("Initializing Audio Manager")
    var file := File.new()
    var err := OK

    print("Loading SFX packages")
    err = file.open(GameManager.game_path + "/audio/CONFIG/PakFiles.dat", File.READ)
    if err != OK:
        print("Error opening PakFiles.dat")
        return

    for i in file.get_len() / 52:
        var namebuffer := file.get_buffer(52) as PoolByteArray
        packagelist.append(namebuffer.get_string_from_utf8())
    print("Loaded %d SFX package(s)" % packagelist.size())
