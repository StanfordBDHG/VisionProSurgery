"""
Spezi Server module for Vision Pro Surgery streaming application.
Provides video streaming capabilities through a Flask web server.
"""

import os
import sys
import socket
import threading
from typing import Generator, Tuple

import customtkinter as ctk
import cv2
from flask import Flask, Response
from PIL import Image, ImageTk

app = Flask(__name__)

# Global state
CAMERA = None
VIDEO_PORT = 0
CAMERA_WIDTH = 640
CAMERA_HEIGHT = 480
CAMERA_FPS = 20

def resource_path(relative_path: str) -> str:
    """Get absolute path to resource for PyInstaller."""
    base_path = getattr(sys, '_MEIPASS', os.path.abspath("."))
    return os.path.join(base_path, relative_path)

def update_camera_settings(width: int, height: int, fps: int) -> None:
    """Update camera resolution and FPS settings."""
    if CAMERA is not None:
        CAMERA.set(cv2.CAP_PROP_FRAME_WIDTH, width)
        CAMERA.set(cv2.CAP_PROP_FRAME_HEIGHT, height)
        CAMERA.set(cv2.CAP_PROP_FPS, fps)

def generate_frames() -> Generator[bytes, None, None]:
    """Generate video frames for streaming."""
    if CAMERA is None:
        return

    while True:
        success, frame = CAMERA.read()
        if not success:
            break
        _, buffer = cv2.imencode('.jpg', frame)
        frame_bytes = buffer.tobytes()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

@app.route('/video')
def video_feed() -> Response:
    """Stream video feed endpoint."""
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

def run_flask_app() -> None:
    """Run the Flask application server."""
    app.run(host='0.0.0.0', port=5001, debug=False, use_reloader=False)

def get_ip_address() -> str:
    """Get the local machine's IP address."""
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    return ip_address

def launch_server() -> None:
    """Initialize camera and launch the streaming server."""
    global CAMERA
    CAMERA = cv2.VideoCapture(VIDEO_PORT)
    update_camera_settings(CAMERA_WIDTH, CAMERA_HEIGHT, CAMERA_FPS)
    flask_thread = threading.Thread(target=run_flask_app)
    flask_thread.daemon = True
    flask_thread.start()
    ip_address = get_ip_address()
    switch_to_info_page(ip_address, 5001)

def create_info_ui(root_window: ctk.CTk, ip_address: str, port: int, logo_path: str) -> None:
    """Create the server information UI elements."""
    logo = Image.open(resource_path(logo_path))
    logo = logo.resize((50, 50))
    photo = ImageTk.PhotoImage(logo)
    
    logo_label = ctk.CTkLabel(root_window, text="", image=photo)
    logo_label.image = photo
    logo_label.pack(pady=5)
    
    info_label = ctk.CTkLabel(root_window, text="Web Server launched", font=bold_font)
    info_label.pack(pady=10)
    
    table_frame = ctk.CTkFrame(root_window, border_color="white", border_width=2, corner_radius=8)
    table_frame.pack(pady=10, padx=20, fill="x")
    
    ip_info_label = ctk.CTkLabel(table_frame, text=f"IP Address: {ip_address}", font=("Helvetica", 14))
    ip_info_label.pack(pady=5, padx=10, anchor="w")
    
    port_info_label = ctk.CTkLabel(table_frame, text=f"Port: {port}", font=("Helvetica", 14))
    port_info_label.pack(pady=5, padx=10, anchor="w")
    
    instruction_font = ctk.CTkFont(family="Helvetica", size=12)
    instruction_label = ctk.CTkLabel(
        root_window,
        text="Enter these addresses in the Vision Pro app to connect",
        font=instruction_font
    )
    instruction_label.pack(pady=20)

def switch_to_info_page(ip_address: str, port: int) -> None:
    """Switch the UI to display server information."""
    for widget in root.winfo_children():
        widget.destroy()
    create_info_ui(root, ip_address, port, "vp_logo.png")

def on_launch() -> None:
    """Handle launch button click event."""
    global VIDEO_PORT, CAMERA_WIDTH, CAMERA_HEIGHT, CAMERA_FPS
    VIDEO_PORT = int(video_port_var.get())
    CAMERA_WIDTH = int(width_entry.get())
    CAMERA_HEIGHT = int(height_entry.get())
    CAMERA_FPS = int(fps_entry.get())
    threading.Thread(target=launch_server, daemon=True).start()

# Initialize UI
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("dark-blue")

root = ctk.CTk()
root.title("Web Server")
root.geometry("400x500")

# Create main UI elements
logo_image = Image.open(resource_path("vp_logo.png"))
logo_image = logo_image.resize((50, 50))
logo_photo = ImageTk.PhotoImage(logo_image)
main_logo_label = ctk.CTkLabel(root, text="", image=logo_photo)
main_logo_label.image = logo_photo
main_logo_label.pack(pady=5)

bold_font = ctk.CTkFont(family="Helvetica", size=25, weight="bold")
header_label = ctk.CTkLabel(master=root, text="Spezi Server", font=bold_font, compound="left")
header_label.pack(pady=10)

video_port_var = ctk.IntVar(value=0)
video_port_label = ctk.CTkLabel(root, text="Video Port ID", font=("Helvetica", 14))
video_port_label.pack(pady=5)
port_menu = ctk.CTkComboBox(root, variable=video_port_var, values=["0", "1", "2"], state='readonly')
port_menu.pack(pady=5)

width_label = ctk.CTkLabel(root, text="Width", font=("Helvetica", 14))
width_label.pack(pady=5)
width_entry = ctk.CTkEntry(root)
width_entry.insert(0, "640")
width_entry.pack(pady=5)

height_label = ctk.CTkLabel(root, text="Height", font=("Helvetica", 14))
height_label.pack(pady=5)
height_entry = ctk.CTkEntry(root)
height_entry.insert(0, "480")
height_entry.pack(pady=5)

fps_label = ctk.CTkLabel(root, text="FPS", font=("Helvetica", 14))
fps_label.pack(pady=5)
fps_entry = ctk.CTkEntry(root)
fps_entry.insert(0, "20")
fps_entry.pack(pady=5)

launch_button = ctk.CTkButton(root, text="Launch", command=on_launch)
launch_button.pack(pady=20)

if __name__ == '__main__':
    root.mainloop()
