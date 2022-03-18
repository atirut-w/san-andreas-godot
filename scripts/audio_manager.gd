extends Node

func _ready() -> void:
    while GameManager.game_path == "":
        yield(get_tree(), "idle_frame")
    print("Initializing Audio Manager")
