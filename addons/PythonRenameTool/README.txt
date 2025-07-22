🧼 Auto Rename Tool (CamelCase)

A lightweight Python tool that automatically renames files in a folder to camelCase format.

📦 Features

- Renames files like "my image_FINAL-01.tres" → "myImageFinal01.tres".
- Works with any file type: .png, .txt, .tres, etc.
- Handles case-only renaming on Windows (e.g., OLA.txt → ola.txt).
- Can be run with Python or as a standalone .exe.
- No third-party libraries required.

🚀 How to Use

Option 1: Run with Python
--------------------------
1. Place auto_rename.py in the folder with the files you want to rename.
2. Open a terminal and run:

	python auto_rename.py

Option 2: Run as .exe
---------------------
1. Build the executable with PyInstaller:

	pyinstaller --onefile auto_rename.py

2. Go to the dist/ folder and copy auto_rename.exe to any directory.
3. Double-click the .exe — it will rename files in the same folder automatically.

💡 The script always renames files in the same folder it's located in, including subfolders.

🛠 Example

Before:
	My FINAL_image 01.TXT

After:
	myFinalImage01.txt

⚠ Notes

- If the final filename already exists, the script skips the file to avoid overwriting.
- The tool only changes filenames — file contents are not touched.
- Cross-platform support (Windows/macOS/Linux). Temporary rename step helps bypass Windows limitations.

📁 Folder Structure

	auto_rename.py
	README.txt
	renametocamelcase.exe
