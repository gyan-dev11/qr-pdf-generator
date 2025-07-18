from flask import Flask, request, jsonify, render_template
from generate_pdf import process_all
import os

app = Flask(__name__)

@app.route('/')
def index():
    return "Backend is Running"

@app.route('/generate', methods=['POST'])
def generate():
    data = request.get_json()

    qr_folder = data.get('qr_folder')
    output_folder = data.get('output_folder')
    logo_path = data.get('logo_path')

    # Basic validation
    if not os.path.isdir(qr_folder):
        return f"QR folder not found: {qr_folder}", 400
    if not os.path.isdir(output_folder):
        return f"Output folder not found: {output_folder}", 400
    if not os.path.isfile(logo_path):
        return f"Logo file not found: {logo_path}", 400

    try:
        process_all(qr_folder, output_folder, logo_path)
        return f"PDFs generated in: {output_folder}", 200
    except Exception as e:
        return f"Error generating PDFs: {str(e)}", 500


if __name__ == '__main__':
    app.run(debug=True, port=5000)
