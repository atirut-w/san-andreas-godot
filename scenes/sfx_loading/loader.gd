extends Control

func _ready() -> void:
    var filediag := FileDialog.new()
    filediag.access = FileDialog.ACCESS_FILESYSTEM
    filediag.mode = FileDialog.MODE_OPEN_DIR
    filediag.window_title = "Select GTA:SA directory"

    add_child(filediag)
    filediag.popup_centered(Vector2(500, 500))
    var dir = yield(filediag, "dir_selected") # Wait for the user to select a directory
