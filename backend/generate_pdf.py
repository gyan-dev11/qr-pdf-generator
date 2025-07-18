import os
import re
from PIL import Image
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import inch
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

# Font Registration
pdfmetrics.registerFont(TTFont("Flame", "flame-regular.ttf"))
pdfmetrics.registerFont(TTFont("Flame-Bold", "flame-bold.ttf"))
pdfmetrics.registerFont(TTFont("Flame-Sans", "flamesans-regular.ttf"))

# PDF Layout Constants
PAGE_WIDTH, PAGE_HEIGHT = 5 * inch, 2.5 * inch
MARGIN = 10
MIDDLE_PADDING = 10
QR_PADDING = 1

def extract_table_number(filename):
    match = re.search(r'pid(\d+)', filename)
    return 100 + int(match.group(1)) if match else None

def create_pdf(qr_path, table_number, output_path, logo_path):
    c = canvas.Canvas(output_path, pagesize=(PAGE_WIDTH, PAGE_HEIGHT))

    # Outer border
    c.setLineWidth(1)
    c.rect(MARGIN, MARGIN, PAGE_WIDTH - 2 * MARGIN, PAGE_HEIGHT - 2 * MARGIN)

    # Vertical divider
    middle_x = PAGE_WIDTH / 2
    c.line(middle_x, MARGIN + MIDDLE_PADDING, middle_x, PAGE_HEIGHT - MARGIN - MIDDLE_PADDING)

    # Logo
    logo = Image.open(logo_path)
    logo_width = 0.9 * inch
    logo_height = logo.size[1] * (logo_width / logo.size[0])
    logo_x = MARGIN
    logo_y = PAGE_HEIGHT - MARGIN - logo_height
    c.drawImage(logo_path, logo_x, logo_y, logo_width, logo_height, mask='auto')

    # Table label
    c.setFont("Flame", 14)
    c.drawString(logo_x + logo_width - (inch * 0.1), logo_y + logo_height / 2 - (inch * 0.1), "Table No.")

    # Table number
    font_size = 72 * 1.4
    c.setFont("Flame-Sans", font_size)
    c.drawString(logo_x + (inch * 0.2), (PAGE_HEIGHT / 2) - (font_size * 0.5), str(table_number))

    # QR code
    qr_size = 1.7 * inch
    qr_x = middle_x + (PAGE_WIDTH / 2 - qr_size - MARGIN) / 2
    qr_y = PAGE_HEIGHT - 2 * MARGIN - qr_size - 1

    c.setLineWidth(1)
    c.rect(qr_x - QR_PADDING, qr_y - QR_PADDING, qr_size + 2 * QR_PADDING, qr_size + 2 * QR_PADDING)
    c.drawImage(qr_path, qr_x, qr_y, qr_size, qr_size)

    # Instruction text
    c.setFont("Flame-Sans", 9)
    c.drawCentredString(qr_x + qr_size / 2, MARGIN + 16, "Scan QR code* to")
    c.drawCentredString(qr_x + qr_size / 2, MARGIN + 5, "place order")

    # T&C
    c.setFont("Flame-Sans", 4)
    c.drawRightString(PAGE_WIDTH - MARGIN - 1, MARGIN + 2, "*T&C Apply")

    c.showPage()
    c.save()

def process_all(qr_folder, output_folder, logo_path):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for filename in os.listdir(qr_folder):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            table_no = extract_table_number(filename)
            if table_no is not None:
                qr_img_path = os.path.join(qr_folder, filename)
                output_path = os.path.join(output_folder, f"table_{table_no}.pdf")
                create_pdf(qr_img_path, table_no, output_path, logo_path)
