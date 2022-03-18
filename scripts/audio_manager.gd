extends Node

var packagelist := []

func init() -> void:
    print("Initializing Audio Manager")
    var file := File.new()
    var err := OK

    err = file.open(GameManager.game_path + "/audio/CONFIG/PakFiles.dat", File.READ)
    if err != OK:
        print("Error opening PakFiles.dat")
        return

    for i in file.get_len() / 52:
        var namebuffer := file.get_buffer(52) as PoolByteArray
        packagelist.append(namebuffer.get_string_from_utf8())
        print("Found SFX package: " + namebuffer.get_string_from_utf8())