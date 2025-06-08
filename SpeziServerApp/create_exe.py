"""
Script to build a standalone executable of the Spezi Server application.
"""

import argparse
import subprocess
import sys
import os
from pathlib import Path

parser = argparse.ArgumentParser(description="Build a local executable of Spezi Server")
parser.add_argument("script", help="Path to spezi_server.py")
parser.add_argument("--location", help="Directory to save the compiled executable")
args = parser.parse_args()

script_path = Path(args.script).resolve()
if not script_path.exists():
    print(f"Error: The script '{script_path}' does not exist.")
    sys.exit(1)

if not args.script.endswith(".py"):
    print("Error: The script must be a .py file.")
    sys.exit(1)

vp_logo_path = script_path.parent / "vp_logo.png"
if not vp_logo_path.exists():
    print("'vp_logo.png' not found in directory")
    data_option = []
else:
    data_option = [f"--add-data={vp_logo_path}{os.pathsep}."]

output_dir = Path(args.location).resolve() if args.location else Path.cwd()

cmd = [
    "pyinstaller",
    "--onefile",
    f"--distpath={output_dir}",
    *data_option,
    str(script_path)
]

print("\nBuilding the executable...")
try:
    subprocess.run(cmd, check=True)
    print("\nExecutable built successfully!")
    print(f"You can find it here: {output_dir}")
except subprocess.CalledProcessError:
    print("\nError while building the executable.")
    sys.exit(1)

print("\nDone.")
