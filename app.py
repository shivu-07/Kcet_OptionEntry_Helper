"""
app.py — KCET Option Entry Helper · Flask Backend
Run:  python app.py
Open: http://localhost:5000          (on this computer)
       http://<your-LAN-IP>:5000      (from any device on the same Wi-Fi/network)
"""

import sqlite3, io, socket
from flask import Flask, jsonify, request, send_file, send_from_directory

app = Flask(__name__, static_folder="static", static_url_path="")
DB  = "kcet.db"

# ── DB helper ─────────────────────────────────────────────────────────────────
def get_db():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn

# ── Serve index.html at root ──────────────────────────────────────────────────
@app.route("/")
def index():
    return send_from_directory("static", "index.html")

# =============================================================================
# GET /api/filters
# Returns all dropdown options for the filter panel
# =============================================================================
@app.route("/api/filters")
def api_filters():
    db = get_db()

    districts = [dict(r) for r in db.execute(
        """SELECT d.id, d.name, COUNT(c.id) as college_count 
           FROM districts d 
           LEFT JOIN colleges c ON c.district_id = d.id 
           GROUP BY d.id 
           ORDER BY d.name"""
    ).fetchall()]
    
    total_colleges = db.execute("SELECT COUNT(*) FROM colleges").fetchone()[0]

    types = [r[0] for r in db.execute(
        "SELECT DISTINCT institution_type FROM colleges ORDER BY institution_type"
    ).fetchall()]

    courses = [r[0] for r in db.execute(
        "SELECT DISTINCT course_name FROM courses ORDER BY course_name"
    ).fetchall()]

    seat_cats = [dict(r) for r in db.execute(
        "SELECT code, description, category_group FROM seat_categories ORDER BY code"
    ).fetchall()]

    db.close()
    return jsonify({
        "districts":      districts,
        "institution_types": types,
        "courses":        courses,
        "seat_categories": seat_cats,
        "total_colleges": total_colleges
    })

# =============================================================================
# GET /api/colleges
# Main search with filters, sorting, pagination
# Query params:
#   search, district_id, institution_type, course, has_cutoff,
#   sort (name|rank|district), page, limit
# =============================================================================
@app.route("/api/colleges")
def api_colleges():
    db = get_db()

    search      = request.args.get("search", "").strip()
    district_id = request.args.get("district_id", "")
    inst_type   = request.args.get("institution_type", "")
    autonomous  = request.args.get("autonomous", "")
    course_f    = request.args.get("course", "")
    category_f  = request.args.get("category", "")
    has_cutoff  = request.args.get("has_cutoff", "0")
    rank_min    = request.args.get("rank_min", "")
    rank_max    = request.args.get("rank_max", "")
    sort_by     = request.args.get("sort", "name")
    page        = max(1, int(request.args.get("page", 1)))
    limit       = min(300, max(1, int(request.args.get("limit", 300))))
    offset      = (page - 1) * limit

    wheres = []
    where_params = []

    if search:
        wheres.append("(c.name LIKE ? OR c.college_code LIKE ?)")
        where_params.extend([f"%{search}%", f"%{search}%"])

    if district_id:
        wheres.append("c.district_id = ?")
        where_params.append(district_id)

    if inst_type:
        wheres.append("c.institution_type = ?")
        where_params.append(inst_type)

    if autonomous in ("0", "1"):
        wheres.append("c.is_autonomous = ?")
        where_params.append(int(autonomous))

    if course_f:
        wheres.append("""c.id IN (
            SELECT college_id FROM courses
            WHERE UPPER(course_name) LIKE UPPER(?)
        )""")
        where_params.append(f"%{course_f}%")

    if has_cutoff == "1":
        wheres.append("c.college_code IS NOT NULL")

    where_sql = ("WHERE " + " AND ".join(wheres)) if wheres else ""

    # Handle dynamic rank join and filter
    rank_params = []
    if course_f and category_f:
        rank_join = """
        LEFT JOIN kcet_cutoffs k ON k.college_id = c.id
            AND k.seat_cat_code = ?
            AND k.course_id IN (SELECT id FROM courses WHERE UPPER(course_name) LIKE UPPER(?))
        """
        rank_params.extend([category_f, f"%{course_f}%"])
    elif course_f:
        # Default to GM if course is selected but no category (fallback)
        rank_join = """
        LEFT JOIN kcet_cutoffs k ON k.college_id = c.id
            AND k.seat_cat_code = 'GM'
            AND k.course_id IN (SELECT id FROM courses WHERE UPPER(course_name) LIKE UPPER(?))
        """
        rank_params.append(f"%{course_f}%")
    else:
        rank_join = "LEFT JOIN kcet_cutoffs k ON k.college_id = c.id AND k.seat_cat_code = 'GM'"

    # Rank filters apply via HAVING since we use MIN(cutoff_rank)
    havings = []
    having_params = []
    if rank_min:
        havings.append("best_gm_rank >= ?")
        having_params.append(float(rank_min))
    if rank_max:
        havings.append("best_gm_rank <= ?")
        having_params.append(float(rank_max))

    having_sql = ("HAVING " + " AND ".join(havings)) if havings else ""

    # Final param order MUST match the order placeholders appear in the SQL
    # string below: rank_join params, then where_sql params, then having params.
    params = rank_params + where_params + having_params

    # Sort
    sort_map = {
        "name":      "c.name ASC",
        "name_desc": "c.name DESC",
        "code_asc":  "c.college_code ASC, c.name ASC",
        "code_desc": "c.college_code DESC, c.name ASC",
        "rank_asc":  "best_gm_rank ASC NULLS LAST",
        "rank_desc": "best_gm_rank DESC NULLS LAST",
    }
    order_sql = sort_map.get(sort_by, "c.name ASC")

    # Count total (with the rank joins and havings if needed)
    count_sql = f"""
        SELECT COUNT(*) FROM (
            SELECT c.id, MIN(k.cutoff_rank) AS best_gm_rank
            FROM colleges c
            LEFT JOIN districts d ON d.id = c.district_id
            {rank_join}
            {where_sql}
            GROUP BY c.id
            {having_sql}
        )
    """
    total = db.execute(count_sql, params).fetchone()[0]

    # Main query — include best rank per college
    main_sql = f"""
        SELECT
            c.id, c.name, c.institution_type, c.college_code,
            c.is_autonomous, d.name AS district,
            MIN(k.cutoff_rank) AS best_gm_rank
        FROM colleges c
        LEFT JOIN districts    d ON d.id  = c.district_id
        {rank_join}
        {where_sql}
        GROUP BY c.id
        {having_sql}
        ORDER BY {order_sql}
        LIMIT ? OFFSET ?
    """
    rows = db.execute(main_sql, params + [limit, offset]).fetchall()

    results = []
    for row in rows:
        row = dict(row)
        # Fetch courses for this college
        row["courses"] = [
            {"name": r["course_name"], "gm_cutoff": r["gm_cutoff"]} for r in db.execute(
                """SELECT c.course_name, MIN(k.cutoff_rank) AS gm_cutoff
                   FROM courses c
                   LEFT JOIN kcet_cutoffs k ON k.course_id = c.id AND k.seat_cat_code = 'GM'
                   WHERE c.college_id = ?
                   GROUP BY c.id
                   ORDER BY c.course_name""",
                (row["id"],)
            ).fetchall()
        ]
        results.append(row)

    db.close()
    return jsonify({
        "total":   total,
        "page":    page,
        "limit":   limit,
        "pages":   (total + limit - 1) // limit,
        "results": results
    })

# =============================================================================
# GET /api/college/<id>/cutoffs
# Full cutoff table for one college (all courses × all categories)
# =============================================================================
@app.route("/api/college/<int:college_id>/cutoffs")
def api_college_cutoffs(college_id):
    db = get_db()

    college = db.execute(
        "SELECT id, name, college_code FROM colleges WHERE id = ?",
        (college_id,)
    ).fetchone()

    if not college:
        db.close()
        return jsonify({"error": "College not found"}), 404

    rows = db.execute("""
        SELECT c.course_name, k.seat_cat_code, k.cutoff_rank
        FROM courses c
        LEFT JOIN kcet_cutoffs k ON c.id = k.course_id
        WHERE c.college_id = ?
        ORDER BY c.course_name, k.seat_cat_code
    """, (college_id,)).fetchall()

    # Pivot: course → {category: rank}
    pivot = {}
    for r in rows:
        course = r["course_name"]
        if course not in pivot:
            pivot[course] = {}
        if r["seat_cat_code"] is not None:
            pivot[course][r["seat_cat_code"]] = r["cutoff_rank"]

    cutoffs = [{"course": c, **cats} for c, cats in pivot.items()]

    db.close()
    return jsonify({
        "college_id":   college["id"],
        "college_name": college["name"],
        "college_code": college["college_code"],
        "cutoffs":      cutoffs
    })

# =============================================================================
# GET /api/options
# Returns saved option list ordered by priority
# =============================================================================
@app.route("/api/options", methods=["GET"])
def api_options_get():
    db = get_db()
    rows = db.execute("""
        SELECT
            o.id, o.college_id, o.course_name, o.priority, o.notes,
            c.name        AS college_name,
            c.college_code,
            d.name        AS district,
            c.institution_type,
            MIN(k.cutoff_rank) AS gm_rank
        FROM my_options o
        JOIN colleges      c ON c.id  = o.college_id
        LEFT JOIN districts d ON d.id  = c.district_id
        LEFT JOIN kcet_cutoffs k
            ON k.college_id = o.college_id
           AND UPPER(k.course_name) = UPPER(o.course_name)
           AND k.seat_cat_code = 'GM'
        GROUP BY o.id
        ORDER BY o.priority ASC
    """).fetchall()
    db.close()
    return jsonify([dict(r) for r in rows])

# =============================================================================
# POST /api/options
# Add a college-course to the option list
# Body: { college_id, course_name }
# =============================================================================
@app.route("/api/options", methods=["POST"])
def api_options_post():
    data = request.get_json()
    college_id  = data.get("college_id")
    course_name = data.get("course_name", "").strip()

    if not college_id or not course_name:
        return jsonify({"error": "college_id and course_name required"}), 400

    db = get_db()

    # Check duplicate
    existing = db.execute(
        "SELECT id FROM my_options WHERE college_id = ? AND UPPER(course_name) = UPPER(?)",
        (college_id, course_name)
    ).fetchone()
    if existing:
        db.close()
        return jsonify({"error": "Already in your list"}), 409

    # Next priority
    max_p = db.execute("SELECT COALESCE(MAX(priority), 0) FROM my_options").fetchone()[0]
    db.execute(
        "INSERT INTO my_options (college_id, course_name, priority) VALUES (?, ?, ?)",
        (college_id, course_name, max_p + 1)
    )
    db.commit()
    new_id = db.execute("SELECT last_insert_rowid()").fetchone()[0]
    db.close()
    return jsonify({"id": new_id, "priority": max_p + 1}), 201

# =============================================================================
# DELETE /api/options/<id>
# Remove one option and re-sequence priorities
# =============================================================================
@app.route("/api/options/<int:option_id>", methods=["DELETE"])
def api_options_delete(option_id):
    db = get_db()
    db.execute("DELETE FROM my_options WHERE id = ?", (option_id,))
    db.commit()

    # Re-sequence
    rows = db.execute("SELECT id FROM my_options ORDER BY priority ASC").fetchall()
    for i, row in enumerate(rows, start=1):
        db.execute("UPDATE my_options SET priority = ? WHERE id = ?", (i, row["id"]))
    db.commit()
    db.close()
    return jsonify({"ok": True})

# =============================================================================
# PUT /api/options/reorder
# Body: { order: [id, id, id, ...] }  — new priority sequence
# =============================================================================
@app.route("/api/options/reorder", methods=["PUT"])
def api_options_reorder():
    data  = request.get_json()
    order = data.get("order", [])
    if not order:
        return jsonify({"error": "order array required"}), 400

    db = get_db()
    for i, opt_id in enumerate(order, start=1):
        db.execute("UPDATE my_options SET priority = ? WHERE id = ?", (i, opt_id))
    db.commit()
    db.close()
    return jsonify({"ok": True})

# =============================================================================
# PATCH /api/options/<id>/notes
# Save notes for one option
# Body: { notes: "..." }
# =============================================================================
@app.route("/api/options/<int:option_id>/notes", methods=["PATCH"])
def api_options_notes(option_id):
    data  = request.get_json()
    notes = data.get("notes", "")
    db = get_db()
    db.execute("UPDATE my_options SET notes = ? WHERE id = ?", (notes, option_id))
    db.commit()
    db.close()
    return jsonify({"ok": True})

# =============================================================================
# GET /api/export-pdf
# Download option list as a formatted PDF
# =============================================================================
@app.route("/api/export-pdf")
def api_export_pdf():
    from reportlab.lib.pagesizes import A4, landscape
    from reportlab.lib import colors
    from reportlab.lib.units import mm
    from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from datetime import datetime

    db = get_db()
    rows = db.execute("""
        SELECT
            o.priority,
            c.college_code,
            c.name        AS college_name,
            o.course_name,
            o.notes
        FROM my_options o
        JOIN colleges c ON c.id = o.college_id
        ORDER BY o.priority ASC
    """).fetchall()
    db.close()

    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=landscape(A4),
        leftMargin=12*mm, rightMargin=12*mm,
        topMargin=15*mm, bottomMargin=15*mm,
        title="KCET Option Entry List"
    )

    styles = getSampleStyleSheet()

    # Custom styles for cells
    cell_style = ParagraphStyle(
        'CellStyle', parent=styles['Normal'],
        fontSize=8, leading=10
    )
    header_cell_style = ParagraphStyle(
        'HeaderCell', parent=styles['Normal'],
        fontSize=9, leading=11, textColor=colors.white,
        fontName='Helvetica-Bold'
    )
    title_style = ParagraphStyle(
        'PDFTitle', parent=styles['Title'],
        fontSize=16, spaceAfter=2*mm,
        textColor=colors.HexColor('#1a1a2e')
    )
    subtitle_style = ParagraphStyle(
        'PDFSubtitle', parent=styles['Normal'],
        fontSize=9, textColor=colors.HexColor('#666666'),
        spaceAfter=5*mm
    )

    elements = []
    elements.append(Paragraph("\U0001f393 KCET Option Entry List", title_style))
    elements.append(Paragraph(
        f"UGCET 2025 \u00b7 Round 3 \u00b7 Generated on {datetime.now().strftime('%d %b %Y, %I:%M %p')} \u00b7 {len(rows)} option{'s' if len(rows) != 1 else ''}",
        subtitle_style
    ))

    # Build table data
    headers = ["#", "Code", "College Name", "Course", "Notes"]
    table_data = [[Paragraph(h, header_cell_style) for h in headers]]

    for r in rows:
        table_data.append([
            Paragraph(str(r["priority"]), cell_style),
            Paragraph(str(r["college_code"] or "\u2014"), cell_style),
            Paragraph(str(r["college_name"]), cell_style),
            Paragraph(str(r["course_name"]), cell_style),
            Paragraph(str(r["notes"] or ""), cell_style),
        ])

    # Column widths (landscape A4 \u2248 277mm usable)
    col_widths = [10*mm, 18*mm, 100*mm, 70*mm, 69*mm]

    table = Table(table_data, colWidths=col_widths, repeatRows=1)

    # Styling
    header_bg = colors.HexColor('#1a1a2e')
    row_alt    = colors.HexColor('#f8f9fa')
    border_clr = colors.HexColor('#dee2e6')

    style_cmds = [
        ('BACKGROUND',  (0, 0), (-1, 0), header_bg),
        ('TEXTCOLOR',   (0, 0), (-1, 0), colors.white),
        ('FONTNAME',    (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE',    (0, 0), (-1, 0), 9),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 5),
        ('TOPPADDING',    (0, 0), (-1, 0), 5),
        ('FONTNAME',    (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE',    (0, 1), (-1, -1), 8),
        ('TOPPADDING',  (0, 1), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 1), (-1, -1), 4),
        ('LEFTPADDING',   (0, 0), (-1, -1), 4),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 4),
        ('GRID',        (0, 0), (-1, -1), 0.5, border_clr),
        ('VALIGN',      (0, 0), (-1, -1), 'TOP'),
        ('ALIGN',       (0, 0), (0, -1), 'CENTER'),   # priority centered
    ]

    # Alternate row colors
    for i in range(1, len(table_data)):
        if i % 2 == 0:
            style_cmds.append(('BACKGROUND', (0, i), (-1, i), row_alt))

    table.setStyle(TableStyle(style_cmds))
    elements.append(table)

    doc.build(elements)
    buffer.seek(0)

    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=True,
        download_name="kcet_options.pdf"
    )

# =============================================================================
# GET /api/stats
# Quick dashboard numbers
# =============================================================================
@app.route("/api/stats")
def api_stats():
    db = get_db()
    stats = {
        "colleges":     db.execute("SELECT COUNT(*) FROM colleges").fetchone()[0],
        "courses":      db.execute("SELECT COUNT(DISTINCT course_name) FROM courses").fetchone()[0],
        "with_cutoffs": db.execute("SELECT COUNT(DISTINCT college_id) FROM kcet_cutoffs").fetchone()[0],
        "my_options":   db.execute("SELECT COUNT(*) FROM my_options").fetchone()[0],
    }
    db.close()
    return jsonify(stats)

# =============================================================================
# GET /api/server-info
# Returns this machine's LAN URL so the UI can show a "shareable" link
# =============================================================================
@app.route("/api/server-info")
def api_server_info():
    ip = get_lan_ip()
    return jsonify({
        "lan_url": f"http://{ip}:5000",
        "local_url": "http://localhost:5000"
    })

# =============================================================================
def get_lan_ip():
    """Best-effort detection of this machine's LAN IP address."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Doesn't actually send anything; just used to pick the right interface
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip

if __name__ == "__main__":
    import os
    if not os.path.exists("kcet.db"):
        print("❌  kcet.db not found. Run:  python setup.py")
    else:
        lan_ip = get_lan_ip()
        port = 5000
        print("🚀  KCET Option Entry Helper is starting…")
        print(f"    • On this computer : http://localhost:{port}")
        print(f"    • On your Wi-Fi/LAN: http://{lan_ip}:{port}")
        print("      (open that 2nd link on any phone/laptop on the same network)")
        print()
        # host="0.0.0.0" makes the server reachable from other devices on the LAN
        app.run(host="0.0.0.0", port=port, debug=True)
