import os
import re
import sys

def to_camel_case(s):
    parts = re.split(r'[\s_\-\.]+', s)
    return parts[0].lower() + ''.join(p.capitalize() for p in parts[1:])

def rename_files_in_folder(root_folder):
    for foldername, subfolders, filenames in os.walk(root_folder):
        for filename in filenames:
            name, ext = os.path.splitext(filename)
            camel = to_camel_case(name) + ext

            print(f"Tentando renomear: '{filename}' para '{camel}'")

            if filename != camel:
                old_path = os.path.join(foldername, filename)
                new_path = os.path.join(foldername, camel)

                # Se só difere na caixa das letras, renomeia via temporário
                if old_path.lower() == new_path.lower():
                    temp_path = os.path.join(foldername, "__temp_rename__" + ext)
                    os.rename(old_path, temp_path)
                    os.rename(temp_path, new_path)
                    print(f"✅ Renomeado com passo temporário: '{filename}' -> '{camel}'")
                else:
                    if not os.path.exists(new_path):
                        os.rename(old_path, new_path)
                        print(f"✅ Renomeado: '{filename}' -> '{camel}'")
                    else:
                        print(f"⚠️ Já existe: '{camel}', pulando...")
            else:
                print(f"ℹ️ Nome já está correto: '{filename}'")

if __name__ == "__main__":
    if getattr(sys, 'frozen', False):
        pasta_atual = os.path.dirname(sys.executable)
    else:
        pasta_atual = os.path.dirname(os.path.abspath(__file__))
    
    print(f"📁 Verificando arquivos em: {pasta_atual}")
    rename_files_in_folder(pasta_atual)
    input("\nPressione Enter para sair...")
