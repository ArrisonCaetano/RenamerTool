@tool
extends EditorPlugin

var toolbar

func _enter_tree() -> void:
	toolbar = preload("res://addons/Rename/RenameUi.tscn").instantiate()
	#add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR,toolbar)
	add_control_to_bottom_panel(toolbar,"Rename Tool")
func _exit_tree() -> void:
	#remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR,toolbar)
	remove_control_from_bottom_panel(toolbar)
	toolbar.free()
