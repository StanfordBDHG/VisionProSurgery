#
# This source file is part of the StanfordBDHG VisionProSurgery project
#
# SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#

"""
SpeziServer package for Vision Pro Surgery streaming application.
"""

from .spezi_server import on_launch as main

__version__ = "1.0.0"
__all__ = ["main"]
