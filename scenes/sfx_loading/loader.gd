extends Control

var packages := []

func _ready() -> void:
    var filediag := FileDialog.new()
    filediag.access = FileDialog.ACCESS_FILESYSTEM
    filediag.mode = FileDialog.MODE_OPEN_DIR
    filediag.window_title = "Select GTA:SA directory"

    add_child(filediag)
    filediag.popup_centered(Vector2(500, 500))
    var dir = yield(filediag, "dir_selected") # Wait for the user to select a directory
    
    _load_pakfiles(dir + "/audio/CONFIG/PakFiles.dat")

func _load_pakfiles(path: String) -> void:
    print("Loading pakfiles from " + path)

    var file := File.new()
    var err := file.open(path, File.READ)
    if err != OK:
        print("Error opening file: " + String(err))
        return

    for pi in file.get_len() / 52: # Each package name takes up 52 bytes
        var namebuffer := file.get_buffer(52) as PoolByteArray
        packages.append(namebuffer.get_string_from_utf8())

    print("Done")
