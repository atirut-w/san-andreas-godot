extends Node
# You know what this script does.

var game_path := ""

func _ready() -> void:
    var filediag := FileDialog.new()
    filediag.access = FileDialog.ACCESS_FILESYSTEM
    filediag.mode = FileDialog.MODE_OPEN_DIR
    filediag.window_title = "Select game directory"

    add_child(filediag)
    filediag.popup_centered_minsize(Vector2(800, 300))
    game_path = yield(filediag, "dir_selected")
    print("Game path:" + game_path)
