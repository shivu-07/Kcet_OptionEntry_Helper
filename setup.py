"""
setup.py — Run this ONCE to build kcet.db from all SQL files.
Usage:  python setup.py
"""

import sqlite3, os, re, sys

DB_PATH  = "kcet.db"
SQL_DIR  = "sql"

# ── Execution order matters ──────────────────────────────────────────────────
SQL_FILES = [
    "kcet_schema_sqlite.sql",
    "districts.sql",
    "government_engineering_colleges_with_codes.sql",
    "aided_engineering_colleges_with_codes.sql",
    "private_unaided_colleges_with_codes.sql",
    "private_minority_colleges_with_codes.sql",
    "public_universities_with_codes.sql",
    "private_universities_with_codes.sql",
    "deemed_universities_with_codes.sql",
    "government_colleges_with_higher_fees_with_codes.sql",
    "college_district_mapping.sql",
]

# Categories in the same order as the wide kcet_cutoffs INSERT columns
CATEGORY_COLS = [
    "1G","1K","1R","2AG","2AK","2AR","2BG","2BK","2BR",
    "3AG","3AK","3AR","3BG","3BK","3BR",
    "GM","GMK","GMP","GMR","NRI","OPN","OTH",
    "SCG","SCK","SCR","STG","STK","STR"
]

def run():
    # Delete old DB so we start fresh
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
        print(f"🗑  Removed old {DB_PATH}")

    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = OFF")   # off during bulk load
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute("PRAGMA synchronous  = NORMAL")
    cur = conn.cursor()

    # ── Step 1: run each SQL file ────────────────────────────────────────────
    for filename in SQL_FILES:
        path = os.path.join(SQL_DIR, filename)
        if not os.path.exists(path):
            print(f"⚠   MISSING: {path}  — skipping")
            continue
        with open(path, encoding="utf-8") as f:
            sql = f.read()
        # Strip block comments so sqlite3 executescript doesn't choke
        sql = re.sub(r"/\*.*?\*/", "", sql, flags=re.DOTALL)
        try:
            conn.executescript(sql)
            print(f"✅  Loaded  : {filename}")
        except Exception as e:
            print(f"❌  ERROR in {filename}: {e}")
            conn.close()
            sys.exit(1)

    conn.commit()

    # ── Step 2: explode wide kcet_cutoffs into normalised rows ───────────────
    print("\n⏳  Converting wide kcet_cutoffs → normalised rows …")

    cutoffs_path = os.path.join(SQL_DIR, "kcet_cutoffs.sql")
    if not os.path.exists(cutoffs_path):
        print("⚠   kcet_cutoffs.sql not found — skipping cutoff import")
    else:
        # Grab the one round_id we inserted in the schema
        round_id = cur.execute("SELECT id FROM kcet_rounds LIMIT 1").fetchone()
        if not round_id:
            print("❌  No row in kcet_rounds — schema may not have loaded")
            conn.close(); sys.exit(1)
        round_id = round_id[0]

        # Build lookup: college_code → college.id
        code_to_id = {
            row[0]: row[1]
            for row in cur.execute("SELECT college_code, id FROM colleges WHERE college_code IS NOT NULL")
        }

        # Normalize course name to handle typos and formatting differences
        def normalize_course(name):
            name = name.upper()
            name = name.replace("ARTIFICAL", "ARTIFICIAL")
            name = name.replace("MATHAMATICS", "MATHEMATICS")
            name = name.replace("SICENCE", "SCIENCE")
            name = name.replace("VIRUTAL", "VIRTUAL")
            name = name.replace("INTEGTATED", "INTEGRATED")
            
            name = re.sub(r'\bENGG\.?\b', 'ENGINEERING', name)
            name = re.sub(r'\bTECH\.?\b', 'TECHNOLOGY', name)
            
            name = re.sub(r'[^A-Z0-9]', '', name)
            
            if name.startswith("BTECHIN"):
                name = name[len("BTECHIN"):]
            elif name.startswith("BTECHNOLOGYIN"):
                name = name[len("BTECHNOLOGYIN"):]
            elif name.startswith("BEIN"):
                name = name[len("BEIN"):]
                
            return name

        # Build lookup: (college_id, normalized_course) → course.id
        course_lookup = {}
        for row in cur.execute("SELECT id, college_id, course_name FROM courses"):
            course_lookup[(row[1], normalize_course(row[2]))] = row[0]

        with open(cutoffs_path, encoding="utf-8") as f:
            raw = f.read()

        # Match every VALUES (…) block in the wide INSERT statements
        pattern = re.compile(
            r"VALUES\s*\(\s*'[^']*'\s*,\s*'([^']+)'\s*,\s*'[^']*'\s*,\s*'([^']+)'\s*,(.*?)\)\s*;",
            re.DOTALL
        )

        rows_inserted = 0
        rows_skipped  = 0

        batch = []
        for m in pattern.finditer(raw):
            college_code = m.group(1).strip()
            course_raw   = m.group(2).strip()
            values_str   = m.group(3)

            # Parse the 28 numeric values (NULL or float)
            raw_vals = [v.strip() for v in values_str.split(",")]
            if len(raw_vals) != 28:
                rows_skipped += 1
                continue

            parsed = []
            for v in raw_vals:
                if v.upper() == "NULL" or v == "":
                    parsed.append(None)
                else:
                    try:
                        parsed.append(float(v))
                    except ValueError:
                        parsed.append(None)

            college_id = code_to_id.get(college_code)
            course_norm = normalize_course(course_raw)
            course_id  = course_lookup.get((college_id, course_norm)) if college_id else None

            # One normalised row per non-NULL category
            for i, cat_code in enumerate(CATEGORY_COLS):
                rank = parsed[i]
                if rank is None:
                    continue
                batch.append((
                    round_id, college_id, college_code,
                    course_id, course_raw,
                    cat_code, rank
                ))

            if len(batch) >= 5000:
                cur.executemany(
                    """INSERT OR IGNORE INTO kcet_cutoffs
                       (round_id, college_id, college_code, course_id, course_name, seat_cat_code, cutoff_rank)
                       VALUES (?,?,?,?,?,?,?)""",
                    batch
                )
                rows_inserted += len(batch)
                batch = []

        if batch:
            cur.executemany(
                """INSERT OR IGNORE INTO kcet_cutoffs
                   (round_id, college_id, college_code, course_id, course_name, seat_cat_code, cutoff_rank)
                   VALUES (?,?,?,?,?,?,?)""",
                batch
            )
            rows_inserted += len(batch)

        conn.commit()
        print(f"✅  kcet_cutoffs : {rows_inserted:,} normalised rows inserted")

    # ── Step 3: re-enable FK and print summary ───────────────────────────────
    conn.execute("PRAGMA foreign_keys = ON")
    conn.commit()

    print("\n📊  Row counts:")
    for table in ["districts","colleges","courses","seat_categories","kcet_rounds","kcet_cutoffs","my_options"]:
        try:
            n = cur.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
            print(f"    {table:<20} {n:>8,}")
        except Exception:
            print(f"    {table:<20}  (table not found)")

    conn.close()
    print(f"\n🎉  Done! Database saved to: {DB_PATH}")

if __name__ == "__main__":
    run()
