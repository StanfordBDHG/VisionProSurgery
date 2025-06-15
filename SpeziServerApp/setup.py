#
# This source file is part of the StanfordBDHG VisionProSurgery project
#
# SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#

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