from setuptools import setup, find_packages

setup(
    name="spezi-server",
    version="1.0.0",
    packages=find_packages(),
    install_requires=[
        "customtkinter",
        "Pillow",
        "opencv-python",
        "numpy"
    ],
    python_requires=">=3.8",
    entry_points={
        "console_scripts": [
            "spezi-server=spezi_server:main",
        ],
    },
) 