@tool
extends Button

@onready var folders_path: LineEdit = %LineEdit
@onready var option_type: OptionButton = %OptionType
@onready var case_type: OptionButton = %CaseOption
@onready var feeback: Label = %feeback


func _ready() -> void:
	pressed.connect(onbuttonpressed)
	feeback.text =" "
	
func onbuttonpressed() -> void:
	
	feeback.text =" "
	var path = folders_path.text.strip_edges()
	if path.is_empty():
		printerr("Caminho vazio.")
		return

	var type_id = option_type.get_selected_id()
	var case_id = case_type.get_selected_id()

	if type_id == 0:  # folders
		if case_id == 0:
			rename_folders_pascal_case(path)
			feeback.text ="Converted to Pascal Case, check FileSystem" 
		elif case_id == 1:
			rename_folders_camel_case(path)
			feeback.text ="Converted to Camel Case, check FileSystem"
		list_all_folders(path)

	elif type_id == 1:  # files
		if case_id == 0:
			rename_files_pascal_case(path)
			feeback.text ="Converted to Pascal Case, check FileSystem" 
		elif case_id == 1:
			rename_files_camel_case(path)
			feeback.text ="Converted to Camel Case, check FileSystem"

		var all_files = list_all_files(path)
		for f in all_files:
			print("Arquivo:", f)
	else:
		print("Tipo inválido:", type_id)
		feeback.text =	"invalid Type"
	
	var paths = folders_path.text.strip_edges()
	if paths.is_empty():
		printerr("Caminho vazio.")
		return


	

func list_all_files(path: String) -> Array:
	var files: Array = []
	var dir = DirAccess.open(path)
	if dir == null:
		print("Não consegui abrir diretório:", path)
		return files

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var full_path = path.path_join(file_name)

		if dir.current_is_dir():
			files += list_all_files(full_path)  # recursivamente
		else:
			files.append(full_path)

		file_name = dir.get_next()

	dir.list_dir_end()
	return files		
		
func list_all_folders(path:String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		print("Não consegui abrir diretório: ", path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		if dir.current_is_dir():
			var folder_path = path + "/" + file_name
			print("Pasta: ", folder_path)
			# chama recursivamente para listar subpastas
			list_all_folders(folder_path)

		file_name = dir.get_next()

	dir.list_dir_end()

func rename_folders_pascal_case(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		print("Não consegui abrir diretório: ", path)
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
		var old_folder_path = path + "/" + folder_name
		var new_folder_name = to_pascal_case(folder_name)
		var new_folder_path = path + "/" + new_folder_name

		if old_folder_path != new_folder_path:
			var error = dir.rename(old_folder_path, new_folder_path)
			if error == OK:
				print("Renomeado: ", old_folder_path, " -> ", new_folder_path)
			else:
				print("Erro ao renomear: ", old_folder_path, " Erro: ", error)
				
func to_pascal_case(text: String) -> String:
	# Substitui espaços, hífens e underlines por um separador único (espaço)
	var cleaned_text = text.replace("_", " ").replace("-", " ").strip_edges()
	var words = cleaned_text.split(" ", false)  # ignora strings vazias

	for i in range(words.size()):
		if words[i].length() > 0:
			words[i] = words[i][0].to_upper() + words[i].substr(1).to_lower()

	return "".join(words)
	
func rename_folders_camel_case(path:String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		print("Não consegui abrir diretório: ", path)
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

	# Renomeia os diretórios
	for folder_name in folder_names:
		var old_folder_path = path + "/" + folder_name
		var new_folder_name = to_custom_camel_case(folder_name)
		var new_folder_path = path + "/" + new_folder_name

		if old_folder_path != new_folder_path:
			var rename_dir = DirAccess.open(path)
			var error = rename_dir.rename(old_folder_path, new_folder_path)
			if error == OK:
				print("Renomeado: ", old_folder_path, " -> ", new_folder_path)
				# Após renomear, usa o novo nome para chamar recursivamente
				rename_folders_camel_case(new_folder_path)
			else:
				print("Erro ao renomear: ", old_folder_path, " Erro: ", error)
		else:
			# Se não renomeou, ainda pode descer na estrutura
			rename_folders_camel_case(old_folder_path)
			
func to_camel_case(text: String) -> String:
	var words = text.split("_")
	for i in range(words.size()):
		if words[i].length() == 0:
			continue
		if i == 0:
			words[i] = words[i].to_lower()
		else:
			words[i] = words[i][0].to_upper() + words[i].substr(1)
	return "".join(words)
	
func to_custom_camel_case(text: String) -> String:
	# Substitui hífens e underscores por espaços
	var cleaned_text = text.replace("-", " ").replace("_", " ")
	
	# Divide por espaços
	var parts = cleaned_text.split(" ")

	if parts.size() == 0:
		return ""

	# primeira palavra toda minúscula
	var result = parts[0].strip_edges().to_lower()

	# as outras palavras, capitalizadas (inicial maiúscula + resto minúsculo)
	for i in range(1, parts.size()):
		var part = parts[i].strip_edges()
		if part.length() > 0:
			part = part[0].to_upper() + part.substr(1).to_lower()
			result += part

	return result
		
func rename_files_camel_case(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		print("Não consegui abrir diretório: ", path)
		feeback.text =	"Can't open dir"
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
			# Recursivamente entra na subpasta
			rename_files_camel_case(full_path)
		else:
			var base_name: String = name.get_basename()
			var extension: String = name.get_extension()
			var new_name: String = to_custom_camel_case(base_name)
			if extension != "":
				new_name += "." + extension

			var new_path: String = path + "/" + new_name
			if full_path != new_path:
				var rename_dir := DirAccess.open(path)
				var error: int = rename_dir.rename(full_path, new_path)
				if error == OK:
					print("Arquivo renomeado: ", full_path, " -> ", new_path)
				else:
					print("Erro ao renomear arquivo: ", full_path, " Erro: ", error)
	dir.list_dir_end()

func rename_files_pascal_case(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		print("Não consegui abrir diretório: ", path)
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

		# Verifica se é diretório (instanciando DirAccess)
		var maybe_dir := DirAccess.open(full_path)
		if maybe_dir != null:
			rename_files_pascal_case(full_path)
			continue

		# Se não é diretório, verifica se é arquivo
		if FileAccess.file_exists(full_path):
			var base_name: String = name.get_basename()
			var extension: String = name.get_extension()
			var new_file_name: String = to_pascal_case(base_name)
			if extension != "":
				new_file_name += "." + extension

			var new_file_path: String = path.path_join(new_file_name)

			if full_path != new_file_path:
				var rename_dir := DirAccess.open(path)
				var error := rename_dir.rename(full_path, new_file_path)

				# Workaround para sistemas que não diferenciam "SceneOverview" de "sceneoverview"
				if error != OK and full_path.to_lower() == new_file_path.to_lower():
					var temp_path := new_file_path + "_temp"
					var temp_error := rename_dir.rename(full_path, temp_path)
					if temp_error == OK:
						var final_error := rename_dir.rename(temp_path, new_file_path)
						if final_error == OK:
							print("Renomeado (forçado): ", full_path, " -> ", new_file_path)
						else:
							print("Erro ao renomear TEMP -> final: ", final_error)
					else:
						print("Erro ao renomear para TEMP: ", temp_error)
				elif error == OK:
					print("Arquivo renomeado: ", full_path, " -> ", new_file_path)
				else:
					print("Erro ao renomear arquivo: ", full_path, " Erro: ", error)

func count_files_and_folders(path: String) -> Dictionary:
	var result = {
		"files": 0,
		"folders": 0
	}
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Não consegui abrir o diretório: " + path)
		return result

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var full_path = path.path_join(file_name)

		if dir.current_is_dir():
			result["folders"] += 1
			var sub_result = count_files_and_folders(full_path)
			result["files"] += sub_result["files"]
			result["folders"] += sub_result["folders"]
		else:
			result["files"] += 1

		file_name = dir.get_next()

	dir.list_dir_end()
	return result
