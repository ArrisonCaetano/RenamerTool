@tool
extends Button

# UI references
@onready var folders_path: LineEdit = %LineEdit
@onready var option_type: OptionButton = %OptionType
@onready var case_type: OptionButton = %CaseOption
@onready var feedback: Label = %feeback

func _ready() -> void:
	pressed.connect(on_button_pressed)

func on_button_pressed() -> void:
	feedback.text = ""

	var path = folders_path.text.strip_edges()
	if path.is_empty():
		feedback.text = "Path is empty"
		printerr("Empty path.")
		return

	var type_id = option_type.get_selected_id()
	var case_id = case_type.get_selected_id()

	if type_id == 0:
		# Rename folders
		if case_id == 0:
			rename_folders_pascal_case(path)
			feedback.text = "Folders renamed to PascalCase. Check FileSystem."
		elif case_id == 1:
			rename_folders_camel_case(path)
			feedback.text = "Folders renamed to camelCase. Check FileSystem."
		list_all_folders(path)

	elif type_id == 1:
		# Rename files
		if case_id == 0:
			rename_files_pascal_case(path)
			feedback.text = "Files renamed to PascalCase. Check FileSystem."
		elif case_id == 1:
			rename_files_camel_case(path)
			feedback.text = "Files renamed to camelCase. Check FileSystem."

		var all_files = list_all_files(path)
		for f in all_files:
			print("File:", f)
	else:
		print("Invalid type:", type_id)
		feedback.text = "Invalid type selected"

# List all files recursively
func list_all_files(path: String) -> Array:
	var files: Array = []
	var dir = DirAccess.open(path)
	if dir == null:
		print("Failed to open directory:", path)
		return files

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var full_path = path.path_join(file_name)

		if dir.current_is_dir():
			files += list_all_files(full_path)
		else:
			files.append(full_path)

		file_name = dir.get_next()

	dir.list_dir_end()
	return files

# List all folders recursively
func list_all_folders(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		print("Failed to open directory:", path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		if dir.current_is_dir():
			var folder_path = path + "/" + file_name
			print("Folder:", folder_path)
			list_all_folders(folder_path)

		file_name = dir.get_next()

	dir.list_dir_end()

# Rename folders to PascalCase
func rename_folders_pascal_case(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		print("Failed to open directory:", path)
		return

	dir.list_dir_begin()
	var folder_names = []
	var file_name = dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		if dir.current_is_dir():
			folder_names.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	for folder_name in folder_names:
		var old_path = path + "/" + folder_name
		var new_name = to_pascal_case(folder_name)
		var new_path = path + "/" + new_name
		if old_path != new_path:
			var error = dir.rename(old_path, new_path)
			if error == OK:
				print("Renamed:", old_path, "->", new_path)
			else:
				print("Rename error:", old_path, "Error:", error)

# Rename folders to camelCase
func rename_folders_camel_case(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		print("Failed to open directory:", path)
		return

	dir.list_dir_begin()
	var folder_names = []
	var file_name = dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		if dir.current_is_dir():
			folder_names.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	for folder_name in folder_names:
		var old_path = path + "/" + folder_name
		var new_name = to_custom_camel_case(folder_name)
		var new_path = path + "/" + new_name

		if old_path != new_path:
			var rename_dir = DirAccess.open(path)
			var error = rename_dir.rename(old_path, new_path)
			if error == OK:
				print("Renamed:", old_path, "->", new_path)
				rename_folders_camel_case(new_path)
			else:
				print("Rename error:", old_path, "Error:", error)
		else:
			rename_folders_camel_case(old_path)

# Convert text to PascalCase
func to_pascal_case(text: String) -> String:
	var cleaned = text.replace("_", " ").replace("-", " ").strip_edges()
	var words = cleaned.split(" ", false)
	for i in range(words.size()):
		if words[i].length() > 0:
			words[i] = words[i][0].to_upper() + words[i].substr(1).to_lower()
	return "".join(words)

# Convert text to camelCase
func to_custom_camel_case(text: String) -> String:
	var cleaned = text.replace("-", " ").replace("_", " ")
	var parts = cleaned.split(" ")
	if parts.size() == 0:
		return ""
	var result = parts[0].strip_edges().to_lower()
	for i in range(1, parts.size()):
		var part = parts[i].strip_edges()
		if part.length() > 0:
			part = part[0].to_upper() + part.substr(1).to_lower()
			result += part
	return result

# Rename files to camelCase
func rename_files_camel_case(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		print("Failed to open directory:", path)
		feedback.text = "Can't open directory"
		return

	dir.list_dir_begin()
	while true:
		var name: String = dir.get_next()
		if name == "":
			break
		if name == "." or name == "..":
			continue

		var full_path: String = path + "/" + name
		if dir.current_is_dir():
			rename_files_camel_case(full_path)
		else:
			var base_name: String = name.get_basename()
			var extension: String = name.get_extension()
			var new_name: String = to_custom_camel_case(base_name)
			if extension != "":
				new_name += "." + extension

			var new_path: String = resolve_conflict(path, new_name.get_basename(), extension)

			if full_path != new_path:
				var rename_dir := DirAccess.open(path)
				var error: int = rename_dir.rename(full_path, new_path)
				if error == OK:
					print("File renamed:", full_path, "->", new_path)
				else:
					print("Rename error:", full_path, "Error:", error)
	dir.list_dir_end()

# Rename files to PascalCase
func rename_files_pascal_case(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		print("Failed to open directory:", path)
		return

	dir.list_dir_begin()
	var names: Array[String] = []
	while true:
		var name: String = dir.get_next()
		if name == "":
			break
		if name == "." or name == "..":
			continue
		names.append(name)
	dir.list_dir_end()

	for name in names:
		var full_path := path.path_join(name)
		var maybe_dir := DirAccess.open(full_path)
		if maybe_dir != null:
			rename_files_pascal_case(full_path)
			continue

		if FileAccess.file_exists(full_path):
			var base_name: String = name.get_basename()
			var extension: String = name.get_extension()
			var new_name: String = to_pascal_case(base_name)
			if extension != "":
				new_name += "." + extension

			var new_path: String = resolve_conflict(path, new_name.get_basename(), extension)

			if full_path != new_path:
				var rename_dir := DirAccess.open(path)
				var error := rename_dir.rename(full_path, new_path)
				if error != OK and full_path.to_lower() == new_path.to_lower():
					# Rename via temp file if only case is different
					var temp_path := new_path + "_temp"
					var temp_error := rename_dir.rename(full_path, temp_path)
					if temp_error == OK:
						var final_error := rename_dir.rename(temp_path, new_path)
						if final_error == OK:
							print("Renamed (forced):", full_path, "->", new_path)
						else:
							print("Rename TEMP->FINAL error:", final_error)
					else:
						print("Rename to TEMP error:", temp_error)
				elif error == OK:
					print("File renamed:", full_path, "->", new_path)
				else:
					print("Rename error:", full_path, "Error:", error)

# Handle file name conflicts
func resolve_conflict(path: String, base_name: String, ext: String) -> String:
	var i = 1
	var candidate = path.path_join(base_name + ("." + ext if ext != "" else ""))
	while FileAccess.file_exists(candidate):
		candidate = path.path_join(base_name + "_" + str(i) + ("." + ext if ext != "" else ""))
		i += 1
	return candidate
