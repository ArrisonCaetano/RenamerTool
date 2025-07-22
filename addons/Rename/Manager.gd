@tool
extends Button  # Este script é um plugin que estende o botão padrão do Godot

@onready var folders_path: LineEdit = %LineEdit  # Referência para um LineEdit (campo de texto) no node para receber o caminho da pasta
@onready var option_type: OptionButton = %OptionType  # Referência para OptionButton que escolhe se vai mexer em pastas ou arquivos
@onready var case_type: OptionButton = %CaseOption  # Referência para OptionButton que escolhe o tipo de case (Pascal ou Camel)
@onready var feeback: Label = %feeback  # Referência para Label que mostra feedback para o usuário
@onready var button_dir: Button = %buttonDir

# Função chamada quando o node está pronto
func _ready() -> void:
	pressed.connect(onbuttonpressed)  # Conecta o sinal de clique do botão para a função onbuttonpressed
	feeback.text =" "  # Limpa o texto do feedback
	
	

	## Conecta o botão ao método que vai abrir o dialog
	#pressed.connect(_on_button_dir_pressed)

# Função chamada quando o botão é pressionado
func onbuttonpressed() -> void:
	feeback.text =" "  # Limpa o feedback

	var path = folders_path.text.strip_edges()  # Pega o texto do LineEdit e remove espaços extras nas bordas

	if path.is_empty():  # Se o campo do caminho estiver vazio
		printerr("Caminho vazio.")  # Imprime erro no console
		return  # Sai da função sem fazer nada

	var type_id = option_type.get_selected_id()  # Pega o ID selecionado no OptionButton para tipo (pasta ou arquivo)
	var case_id = case_type.get_selected_id()  # Pega o ID selecionado no OptionButton para case (Pascal ou Camel)

	if type_id == 0:  # Se selecionou "pastas"
		if case_id == 0:  # Se selecionou Pascal Case
			rename_folders_pascal_case(path)  # Chama função para renomear pastas em Pascal Case
			feeback.text ="Converted to Pascal Case, check FileSystem"  # Feedback para o usuário
		elif case_id == 1:  # Se selecionou Camel Case
			rename_folders_camel_case(path)  # Chama função para renomear pastas em Camel Case
			feeback.text ="Converted to Camel Case, check FileSystem"  # Feedback
		list_all_folders(path)  # Lista todas as pastas (para visualização)

	elif type_id == 1:  # Se selecionou "arquivos"
		if case_id == 0:  # Pascal Case
			rename_files_pascal_case(path)  # Renomeia arquivos em Pascal Case
			feeback.text ="Converted to Pascal Case, check FileSystem"
		elif case_id == 1:  # Camel Case
			rename_files_camel_case(path)  # Renomeia arquivos em Camel Case
			feeback.text ="Converted to Camel Case, check FileSystem"

		var all_files = list_all_files(path)  # Lista todos os arquivos (recursivamente)
		for f in all_files:  # Itera sobre cada arquivo
			print("Arquivo:", f)  # Imprime o caminho completo do arquivo no console
	else:
		print("Tipo inválido:", type_id)  # Caso o tipo seja inválido
		feeback.text =	"invalid Type"  # Feedback ao usuário

	# Parece redundante — repete a checagem de caminho vazia, mas não faz nada
	var paths = folders_path.text.strip_edges()
	if paths.is_empty():
		printerr("Caminho vazio.")
		return

# Função que lista todos os arquivos dentro de uma pasta, recursivamente
func list_all_files(path: String) -> Array:
	var files: Array = []  # Array para armazenar os arquivos encontrados
	var dir = DirAccess.open(path)  # Abre o diretório no caminho passado
	if dir == null:  # Se não conseguir abrir
		print("Não consegui abrir diretório:", path)  # Erro no console
		return files  # Retorna array vazio

	dir.list_dir_begin()  # Inicia listagem do diretório
	var file_name = dir.get_next()  # Pega o próximo item da pasta

	while file_name != "":  # Enquanto houver arquivos ou pastas
		if file_name == "." or file_name == "..":  # Ignora entradas especiais de diretório
			file_name = dir.get_next()
			continue  # Pula para o próximo

		var full_path = path.path_join(file_name)  # Junta o caminho da pasta com o nome do arquivo/pasta

		if dir.current_is_dir():  # Se for uma pasta
			files += list_all_files(full_path)  # Chama a função recursivamente para essa subpasta
		else:
			files.append(full_path)  # Se for arquivo, adiciona à lista

		file_name = dir.get_next()  # Pega próximo arquivo/pasta

	dir.list_dir_end()  # Finaliza listagem

	return files  # Retorna array com todos os arquivos encontrados

# Função que lista todas as pastas dentro de uma pasta (recursivamente)
func list_all_folders(path:String) -> void:
	var dir = DirAccess.open(path)  # Abre o diretório
	if dir == null:
		print("Não consegui abrir diretório: ", path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		if dir.current_is_dir():  # Se for pasta
			var folder_path = path + "/" + file_name  # Cria caminho completo da pasta
			print("Pasta: ", folder_path)  # Imprime no console
			list_all_folders(folder_path)  # Chama recursivamente para subpastas

		file_name = dir.get_next()

	dir.list_dir_end()

# Renomeia as pastas no caminho para Pascal Case
func rename_folders_pascal_case(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		print("Não consegui abrir diretório: ", path)
		return

	dir.list_dir_begin()
	var folder_names = []  # Lista para armazenar nomes das pastas
	var file_name = dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		if dir.current_is_dir():
			folder_names.append(file_name)  # Guarda nomes das pastas para renomear depois

		file_name = dir.get_next()

	dir.list_dir_end()

	for folder_name in folder_names:  # Para cada pasta encontrada
		var old_folder_path = path + "/" + folder_name  # Caminho antigo
		var new_folder_name = to_pascal_case(folder_name)  # Novo nome convertido para Pascal Case
		var new_folder_path = path + "/" + new_folder_name  # Novo caminho

		if old_folder_path != new_folder_path:  # Se o nome mudou
			var error = dir.rename(old_folder_path, new_folder_path)  # Tenta renomear
			if error == OK:
				print("Renomeado: ", old_folder_path, " -> ", new_folder_path)
			else:
				print("Erro ao renomear: ", old_folder_path, " Erro: ", error)

# Converte texto para Pascal Case (ex: "minha pasta" -> "MinhaPasta")
func to_pascal_case(text: String) -> String:
	# Substitui _, - e espaços por espaço único e remove espaços extras nas bordas
	var cleaned_text = text.replace("_", " ").replace("-", " ").strip_edges()
	var words = cleaned_text.split(" ", false)  # Divide em palavras ignorando strings vazias

	for i in range(words.size()):
		if words[i].length() > 0:
			words[i] = words[i][0].to_upper() + words[i].substr(1).to_lower()  # Maiúscula na 1ª letra, minúscula no resto

	return "".join(words)  # Junta todas as palavras sem espaço (pascal case)

# Renomeia pastas para Camel Case
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

	# Para cada pasta encontrada
	for folder_name in folder_names:
		var old_folder_path = path + "/" + folder_name
		var new_folder_name = to_custom_camel_case(folder_name)  # Converte nome para camel case
		var new_folder_path = path + "/" + new_folder_name

		if old_folder_path != new_folder_path:
			var rename_dir = DirAccess.open(path)
			var error = rename_dir.rename(old_folder_path, new_folder_path)
			if error == OK:
				print("Renomeado: ", old_folder_path, " -> ", new_folder_path)
				# Depois de renomear, chama recursivamente para renomear subpastas no novo caminho
				rename_folders_camel_case(new_folder_path)
			else:
				print("Erro ao renomear: ", old_folder_path, " Erro: ", error)
		else:
			# Se não renomeou, mesmo assim tenta descer na estrutura para renomear subpastas
			rename_folders_camel_case(old_folder_path)

# Converte texto para camel_case básico (ex: "minha_pasta" -> "minhaPasta")
func to_camel_case(text: String) -> String:
	var words = text.split("_")
	for i in range(words.size()):
		if words[i].length() == 0:
			continue
		if i == 0:
			words[i] = words[i].to_lower()  # primeira palavra toda minúscula
		else:
			words[i] = words[i][0].to_upper() + words[i].substr(1)  # inicial maiúscula para outras palavras
	return "".join(words)

# Converte texto para camelCase personalizado (ex: "minha-pasta_test" -> "minhaPastaTest")
func to_custom_camel_case(text: String) -> String:
	# Substitui hífens e underscores por espaços
	var cleaned_text = text.replace("-", " ").replace("_", " ")
	
	# Divide texto por espaços
	var parts = cleaned_text.split(" ")

	if parts.size() == 0:
		return ""

	# Primeira palavra toda minúscula
	var result = parts[0].strip_edges().to_lower()

	# As outras palavras com primeira letra maiúscula e o resto minúsculo
	for i in range(1, parts.size()):
		var part = parts[i].strip_edges()
		if part.length() > 0:
			part = part[0].to_upper() + part.substr(1).to_lower()
			result += part

	return result

# Renomeia arquivos para camelCase
func rename_files_camel_case(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		print("Não consegui abrir diretório: ", path)
		feeback.text =	"Can't open dir"  # Feedback de erro
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
			# Se for diretório, chama recursivamente para renomear arquivos dentro dele
			rename_files_camel_case(full_path)
		else:
			var base_name: String = name.get_basename()  # Nome sem extensão
			var extension: String = name.get_extension()  # Extensão do arquivo
			var new_name: String = to_custom_camel_case(base_name)  # Converte base para camelCase
			if extension != "":
				new_name += "." + extension  # Reconstrói o nome com extensão

			var new_path: String = path + "/" + new_name
			if full_path != new_path:
				var rename_dir := DirAccess.open(path)
				var error: int = rename_dir.rename(full_path, new_path)
				if error == OK:
					print("Arquivo renomeado: ", full_path, " -> ", new_path)
				else:
					print("Erro ao renomear arquivo: ", full_path, " Erro: ", error)
	dir.list_dir_end()

# Renomeia arquivos para Pascal Case
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
		names.append(name)  # Guarda todos os nomes encontrados
	dir.list_dir_end()

	for name in names:
		var full_path := path.path_join(name)

		# Tenta abrir como diretório
		var maybe_dir := DirAccess.open(full_path)
		if maybe_dir != null:
			rename_files_pascal_case(full_path)  # Se for pasta, chama recursivamente
			continue

		# Se for arquivo
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

				# Workaround para sistemas que não diferenciam maiúsculas/minúsculas no nome de arquivo
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

# Função para contar arquivos e pastas dentro de um diretório, recursivamente
func count_files_and_folders(path: String) -> Dictionary:
	var result = {
		"files": 0,
		"folders": 0
	}
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Não consegui abrir o diretório: " + path)  # Erro interno
		return result

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var full_path = path.path_join(file_name)

		if dir.current_is_dir():
			result["folders"] += 1  # Conta pasta
			var sub_result = count_files_and_folders(full_path)  # Conta recursivamente dentro da pasta
			result["files"] += sub_result["files"]
			result["folders"] += sub_result["folders"]
		else:
			result["files"] += 1  # Conta arquivo

		file_name = dir.get_next()

	dir.list_dir_end()
	return result  # Retorna dicionário com contagem de arquivos e pastas


#func _on_button_dir_pressed() -> void:
	#%FileDialog.popup()
	#
