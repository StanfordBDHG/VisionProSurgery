import os
import sys
import customtkinter as ctk
from flask import Flask, Response, request
import cv2
import threading
import socket
from PIL import Image, ImageTk

app = Flask(__name__)
camera = None

video_port = 0
camera_width = 640
camera_height = 480
camera_fps = 20

## for pyinstaller relative paths
def resource_path(relative_path):
    if hasattr(sys, '_MEIPASS'):
        return os.path.join(sys._MEIPASS, relative_path)
    return os.path.join(os.path.abspath("."), relative_path)

def update_camera_settings(width, height, fps):
    global camera
    camera.set(cv2.CAP_PROP_FRAME_WIDTH, width)
    camera.set(cv2.CAP_PROP_FRAME_HEIGHT, height)
    camera.set(cv2.CAP_PROP_FPS, fps)

## frame generating protocol
def generate_frames():
    global camera
    while True:
        success, frame = camera.read()
        if not success:
            break
        else:
            ret, buffer = cv2.imencode('.jpg', frame)
            frame = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

## streaming using HTTP response
@app.route('/video')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')
    
def run_flask_app():
    app.run(host='0.0.0.0', port=5001, debug=False, use_reloader=False)

def get_ip_address():
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    return ip_address

def launch_server():
    global camera, video_port, camera_width, camera_height, camera_fps
    camera = cv2.VideoCapture(video_port)
    update_camera_settings(camera_width, camera_height, camera_fps)
    flask_thread = threading.Thread(target=run_flask_app)
    flask_thread.daemon = True
    flask_thread.start()
    ip_address = get_ip_address()
    switch_to_info_page(ip_address, 5001)

def switch_to_info_page(ip_address, port):
    for widget in root.winfo_children():
        widget.destroy()
        
    logo_image = Image.open(resource_path("vp_logo.png"))
    logo_image = logo_image.resize((50, 50))
    logo_photo = ImageTk.PhotoImage(logo_image)
    
    label = ctk.CTkLabel(root, text="", image=logo_photo)
    label.image = logo_photo
    label.pack(pady=5)
    
    info_label = ctk.CTkLabel(root, text="Web Server launched", font=bold_font)
    info_label.pack(pady=10)
    
    table_frame = ctk.CTkFrame(root, border_color="white", border_width=2, corner_radius=8)
    table_frame.pack(pady=10, padx=20, fill="x")
    
    ip_label = ctk.CTkLabel(table_frame, text=f"IP Address: {ip_address}", font=("Helvetica", 14))
    ip_label.pack(pady=5, padx=10, anchor="w")
    
    port_label = ctk.CTkLabel(table_frame, text=f"Port: {port}", font=("Helvetica", 14))
    port_label.pack(pady=5, padx=10, anchor="w")
    
    bold_instruction_font = ctk.CTkFont(family="Helvetica", size=12)
    instruction_label = ctk.CTkLabel(root, text="Enter these addresses in the Vision Pro app to connect", font=bold_instruction_font)
    instruction_label.pack(pady=20)

ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("dark-blue")

root = ctk.CTk()
root.title("Web Server")
root.geometry("400x500")

logo_image = Image.open(resource_path("vp_logo.png"))
logo_image = logo_image.resize((50, 50))
logo_photo = ImageTk.PhotoImage(logo_image)
label = ctk.CTkLabel(root, text="", image=logo_photo)
label.image = logo_photo
label.pack(pady=5)

bold_font = ctk.CTkFont(family="Helvetica", size=25, weight="bold")
header_label = ctk.CTkLabel(master=root, text="Spezi Server", font=bold_font, compound="left")
header_label.pack(pady=10)

video_port_var = ctk.IntVar(value=0)
port_label = ctk.CTkLabel(root, text="Video Port ID", font=("Helvetica", 14))
port_label.pack(pady=5)
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

def on_launch():
    global video_port, camera_width, camera_height, camera_fps
    video_port = int(video_port_var.get())
    camera_width = int(width_entry.get())
    camera_height = int(height_entry.get())
    camera_fps = int(fps_entry.get())
    threading.Thread(target=launch_server, daemon=True).start()

launch_button = ctk.CTkButton(root, text="Launch", command=on_launch)
launch_button.pack(pady=20)

root.mainloop()
