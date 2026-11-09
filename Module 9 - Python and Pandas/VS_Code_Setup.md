# Run Module 9 in VS Code

Use this route if you prefer to work on your own computer instead of Google Colab. The lesson, exercises, and dataset are the same. You need internet access for installation and for loading the CSV from GitHub; keeping `hour.csv` beside the notebook lets you load the data offline afterward.

## 1. Install Python and VS Code

Python runs your code. VS Code is the editor. Installing the Python extension in VS Code does not install Python itself.

1. Install the desktop version of [Visual Studio Code](https://code.visualstudio.com/download) for your operating system.
2. Install **Python 3.13** using the instructions for your system below. If you already have Python 3.13, skip the installation and check its version.
3. Close and reopen VS Code after installing Python so its terminals can find the new installation.

### Windows

Go to [Python for Windows](https://www.python.org/downloads/windows/) and install the **Python install manager**. Open PowerShell and run:

```powershell
py install 3.13
py -3.13 --version
```

The first command installs the Python runtime; the second should print `Python 3.13.x`. If you already installed Python 3.13 with the traditional installer, skip `py install 3.13` and use the version check. If that installer offers **Add python.exe to PATH**, select it.

See the [official Windows installation guide](https://docs.python.org/3/using/windows.html) if `py` is not recognized after reopening the terminal.

### macOS

Go to [Python for macOS](https://www.python.org/downloads/macos/), find a Python **3.13** release with a macOS installer, download its `.pkg`, and follow the installation prompts. Open Terminal and check:

```bash
python3.13 --version
```

Expect `Python 3.13.x`. In Finder, open the installed **Applications / Python 3.13** folder and run **Install Certificates.command** to complete certificate setup for HTTPS downloads. See the [official macOS installation guide](https://docs.python.org/3/using/mac.html).

## 2. Add notebook support to VS Code

Open VS Code's **Extensions** view. Search for and install both extensions published by **Microsoft**:

- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python) (`ms-python.python`)
- [Jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter) (`ms-toolsai.jupyter`)

The Jupyter extension opens `.ipynb` files as notebooks with code and text cells. Refer to [Microsoft's notebook guide](https://code.visualstudio.com/docs/datascience/jupyter-notebooks) for the editor controls.

## 3. Open the Module 9 folder

Download the course repository using **Code > Download ZIP** on [GitHub](https://github.com/HeyAvijitRoy/csci-362-databses-data-mining), then extract it. If you already have the course files, use your existing copy.

In VS Code, choose **File > Open Folder** and select **Module 9 - Python and Pandas** inside the extracted repository. Open the extracted folder, rather than the ZIP archive. It should contain `CSCI362_Module09_Student.ipynb`, `requirements.txt`, and `hour.csv`. If VS Code asks about workspace trust, review the source and trust the course folder to enable execution.

Choose **Terminal > New Terminal**. Run the next commands in that terminal, not in a notebook cell. The terminal should be in the Module 9 folder: `dir` on Windows or `ls` on macOS should show `requirements.txt`.

## 4. Create a Python environment and install packages

An environment keeps this module's packages together. Run the block for your system once. The commands call its Python directly, so you do not need to activate the environment or change PowerShell's execution policy.

**Windows (PowerShell):**

```powershell
py -3.13 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

**macOS (Terminal):**

```bash
python3.13 -m venv .venv
./.venv/bin/python -m pip install -r requirements.txt
```

Wait for installation to finish without errors. The supplied requirements include pandas and the notebook packages. Keep the `.venv` folder; you do not need to recreate it each time you work.

## 5. Select the kernel and run the notebook

1. Open `CSCI362_Module09_Student.ipynb` from VS Code's Explorer.
2. Click **Select Kernel** at the top right. Choose **Python Environments** (use **Select Another Kernel** first if shown), then select the environment in this folder's **`.venv`**. The kernel is the Python process that runs the notebook cells. If it is missing, reopen VS Code and check again. See [Microsoft's kernel selection guide](https://code.visualstudio.com/docs/datascience/jupyter-kernel-management).
3. Read the text above each example and **predict the result before running it**. Select a code cell and press **Shift+Enter**, or click its triangular run button. Start at the top; later cells use variables defined earlier.
4. Run the imports and CSV-loading cells unchanged. The loader uses the local `hour.csv` when present and otherwise reads from public GitHub. No Google Drive connection is needed. Leave `UPLOAD_WITH_DIALOG = False`; the optional upload dialog is for Colab.
5. Confirm **17,379 rows and 17 columns**. Then continue through the lesson. Double-click a **My interpretation** text cell to edit your response; press **Shift+Enter** to render it.
6. Save with **Ctrl+S** on Windows or **Cmd+S** on macOS. After Exercise 6, find `top_deviations.csv` in the notebook's working folder; it normally appears in the Module 9 folder in VS Code's Explorer. No Colab download step is needed for a file already saved on your computer.
7. Before submitting, use the notebook toolbar to **Restart** the kernel, then **Run All** to check that your completed work runs in order. Save again to keep the outputs. Follow Brightspace for submission directions.

When returning later, reopen this folder and notebook, select the same `.venv` kernel, and run cells from the top. Restarting clears variables; your saved files remain on disk.

## Troubleshooting

| Problem | What to do |
| --- | --- |
| `py` / `python3.13` is not recognized | Finish the Python installation, then close and reopen VS Code. Use the command for your operating system. |
| `requirements.txt` cannot be found | Open the Module 9 folder and start a new terminal there; check the filename with `dir` or `ls`. |
| Notebook opens as JSON text | Install Microsoft's Jupyter extension, then reopen the `.ipynb` with the Jupyter Notebook editor. |
| No kernel is selected | Choose the local `.venv` through **Select Kernel > Python Environments**. |
| `ModuleNotFoundError: No module named 'pandas'` | Rerun the package-install command above, then ensure the notebook uses that same `.venv` kernel. |
| `NameError` | Run the earlier cell defining the variable, or restart and run cells from the top. |
| CSV download fails | Keep the supplied `hour.csv` beside the notebook and rerun the loading cell. On macOS, complete the certificate setup described above if HTTPS reports a certificate error. |
| Colab upload import fails locally | Leave `UPLOAD_WITH_DIALOG = False`; use the local CSV or GitHub route. |
