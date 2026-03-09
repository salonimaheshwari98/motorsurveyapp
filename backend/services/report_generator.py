from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.pdfgen import canvas
from backend.models.claim import Claim
from backend.models.part import Part
from backend.models.photo import Photo
from backend.models.assessment import Assessment
from typing import Optional, List

import io


def generate_report_pdf(
    claim: Claim,
    parts: List[Part],
    photos: List[Photo],
    assessment: Optional[Assessment],
) -> bytes:
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer, pagesize=letter)
    width, height = letter

    y = height - 50
    c.setFont("Helvetica-Bold", 18)
    c.drawString(50, y, "Motor Insurance Survey Report")
    y -= 10
    c.setLineWidth(2)
    c.setStrokeColor(colors.blue)
    c.line(50, y, width - 50, y)
    y -= 30

    # ── Claim Details ────────────────────────────────────────────
    c.setFont("Helvetica-Bold", 13)
    c.setFillColor(colors.darkblue)
    c.drawString(50, y, "Claim Details")
    c.setFillColor(colors.black)
    y -= 20

    c.setFont("Helvetica", 10)
    details = [
        ("Claim Number", claim.claim_number),
        ("Policy Number", claim.policy_number),
        ("Insurer", claim.insurer),
        ("Insured Name", claim.insured_name),
        ("Phone", claim.phone),
        ("Vehicle Number", claim.vehicle_number),
        ("Vehicle Model", claim.vehicle_model),
        ("Manufacture Year", str(claim.manufacture_year)),
        ("Accident Date", str(claim.accident_date)),
        ("Accident Location", claim.accident_location),
        ("Status", claim.status),
    ]
    for label, value in details:
        c.setFont("Helvetica-Bold", 10)
        c.drawString(60, y, f"{label}:")
        c.setFont("Helvetica", 10)
        c.drawString(200, y, str(value))
        y -= 16
        if y < 80:
            c.showPage()
            y = height - 50

    # ── Parts Estimate Table ─────────────────────────────────────
    y -= 20
    c.setFont("Helvetica-Bold", 13)
    c.setFillColor(colors.darkblue)
    c.drawString(50, y, "Parts Estimate")
    c.setFillColor(colors.black)
    y -= 20

    if parts:
        # Table header
        c.setFont("Helvetica-Bold", 9)
        cols = [60, 180, 220, 270, 340, 400, 470, 530]
        headers = ["#", "Part Name", "Qty", "Rate", "Material", "Depr%", "Approved", "Accept"]
        for i, h in enumerate(headers):
            c.drawString(cols[i], y, h)
        y -= 4
        c.setLineWidth(0.5)
        c.line(50, y, width - 50, y)
        y -= 14

        c.setFont("Helvetica", 9)
        total_amount = 0.0
        total_approved = 0.0
        for idx, part in enumerate(parts, 1):
            c.drawString(cols[0], y, str(idx))
            c.drawString(cols[1], y, part.part_name[:20])
            c.drawString(cols[2], y, str(part.quantity))
            c.drawString(cols[3], y, f"{part.rate:.0f}")
            c.drawString(cols[4], y, part.material_type or "-")
            c.drawString(cols[5], y, f"{part.depreciation_percent:.0f}%")
            c.drawString(cols[6], y, f"{part.approved_amount:.0f}")
            c.drawString(cols[7], y, "Yes" if part.accepted else "No")
            total_amount += part.amount
            total_approved += part.approved_amount
            y -= 14
            if y < 80:
                c.showPage()
                y = height - 50

        y -= 6
        c.setLineWidth(0.5)
        c.line(50, y, width - 50, y)
        y -= 16
        c.setFont("Helvetica-Bold", 10)
        c.drawString(60, y, f"Total Claimed: Rs. {total_amount:,.0f}")
        y -= 16
        c.drawString(60, y, f"Total Approved: Rs. {total_approved:,.0f}")
        y -= 16
        c.drawString(60, y, f"Savings (Depreciation): Rs. {total_amount - total_approved:,.0f}")
        y -= 16
    else:
        c.setFont("Helvetica", 10)
        c.drawString(60, y, "No parts data available.")
        y -= 20

    # ── Photos ───────────────────────────────────────────────────
    if y < 120:
        c.showPage()
        y = height - 50

    y -= 20
    c.setFont("Helvetica-Bold", 13)
    c.setFillColor(colors.darkblue)
    c.drawString(50, y, "Inspection Photos")
    c.setFillColor(colors.black)
    y -= 20

    if photos:
        c.setFont("Helvetica", 10)
        for photo in photos:
            c.drawString(60, y, f"- {photo.photo_type}: {photo.gps_location or 'Location N/A'} ({photo.timestamp or 'N/A'})")
            y -= 16
            if y < 80:
                c.showPage()
                y = height - 50
    else:
        c.setFont("Helvetica", 10)
        c.drawString(60, y, "No photos captured.")
        y -= 20

    # ── Assessment & Recommendations ─────────────────────────────
    if y < 160:
        c.showPage()
        y = height - 50

    y -= 20
    c.setFont("Helvetica-Bold", 13)
    c.setFillColor(colors.darkblue)
    c.drawString(50, y, "Assessment & Recommendations")
    c.setFillColor(colors.black)
    y -= 20

    if assessment:
        c.setFont("Helvetica", 10)
        c.drawString(60, y, f"Liability: {assessment.liability:.0f}%")
        y -= 16
        c.drawString(60, y, f"Final Amount: Rs. {assessment.final_amount:,.0f}")
        y -= 20

        c.setFont("Helvetica-Bold", 10)
        c.drawString(60, y, "Inspection Notes:")
        y -= 14
        c.setFont("Helvetica", 9)
        for line in (assessment.inspection_notes or "").split("\n"):
            c.drawString(70, y, line[:90])
            y -= 12
            if y < 80:
                c.showPage()
                y = height - 50

        y -= 10
        c.setFont("Helvetica-Bold", 10)
        c.drawString(60, y, "Recommendation:")
        y -= 14
        c.setFont("Helvetica", 9)
        for line in (assessment.recommendation or "").split("\n"):
            c.drawString(70, y, line[:90])
            y -= 12
            if y < 80:
                c.showPage()
                y = height - 50
    else:
        c.setFont("Helvetica", 10)
        c.drawString(60, y, "No assessment data available.")
        y -= 20

    # ── Footer ───────────────────────────────────────────────────
    c.setFont("Helvetica", 8)
    c.setFillColor(colors.grey)
    c.drawString(50, 30, "Generated by Motor Insurance Survey App")
    c.drawRightString(width - 50, 30, f"Claim: {claim.claim_number}")

    c.showPage()
    c.save()
    pdf = buffer.getvalue()
    buffer.close()
    return pdf
