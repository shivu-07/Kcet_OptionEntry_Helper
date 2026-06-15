-- =============================================================================
--  KCET Karnataka Engineering Admissions Database
--  SQLite 3.35+ compatible schema
--  (No extensions, no enums, no SMALLSERIAL — all SQLite-native)
-- =============================================================================

PRAGMA foreign_keys    = ON;
PRAGMA journal_mode    = WAL;
PRAGMA synchronous     = NORMAL;
PRAGMA temp_store      = MEMORY;
PRAGMA cache_size      = -64000;   -- 64 MB page cache


-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: districts
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS districts (
    id      INTEGER PRIMARY KEY,          -- 1–31
    name    TEXT    NOT NULL UNIQUE
);

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: colleges
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS colleges (
    id                INTEGER PRIMARY KEY,
    name              TEXT    NOT NULL,
    institution_type  TEXT    NOT NULL CHECK (institution_type IN (
                          'Government Engineering Colleges / VTU Constituent Colleges',
                          'Aided Engineering Colleges',
                          'Private Unaided Engineering Colleges',
                          'Private Unaided Minority Colleges',
                          'Government Courses in Public Universities',
                          'Private Universities',
                          'Deemed Universities',
                          'Government Colleges with Higher Fees'
                      )),
    college_code      TEXT    CHECK (college_code GLOB 'E[0-9][0-9][0-9]'),
    district_id       INTEGER REFERENCES districts(id) ON DELETE SET NULL,
    is_autonomous     INTEGER NOT NULL DEFAULT 0 CHECK (is_autonomous IN (0,1)),
    created_at        TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
    updated_at        TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE INDEX IF NOT EXISTS idx_colleges_code      ON colleges (college_code);
CREATE INDEX IF NOT EXISTS idx_colleges_district  ON colleges (district_id);
CREATE INDEX IF NOT EXISTS idx_colleges_type      ON colleges (institution_type);

-- Auto-update updated_at on every UPDATE
CREATE TRIGGER IF NOT EXISTS trg_colleges_updated_at
    AFTER UPDATE ON colleges
    FOR EACH ROW
BEGIN
    UPDATE colleges SET updated_at = strftime('%Y-%m-%dT%H:%M:%SZ','now')
    WHERE id = NEW.id;
END;


-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: courses
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS courses (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    college_id  INTEGER NOT NULL REFERENCES colleges(id) ON DELETE CASCADE,
    course_name TEXT    NOT NULL,
    created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
    UNIQUE (college_id, course_name)
);

CREATE INDEX IF NOT EXISTS idx_courses_college ON courses (college_id);
CREATE INDEX IF NOT EXISTS idx_courses_name    ON courses (course_name);


-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: seat_categories
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS seat_categories (
    code               TEXT    PRIMARY KEY,   -- '1G', 'GM', 'SCG' …
    description        TEXT    NOT NULL,
    category_group     TEXT    NOT NULL,      -- 'OBC-1', 'General', 'SC', 'ST', 'NRI', 'Open', 'Other'
    is_kannada_medium  INTEGER NOT NULL DEFAULT 0 CHECK (is_kannada_medium IN (0,1))
);

INSERT OR IGNORE INTO seat_categories (code, description, category_group, is_kannada_medium) VALUES
('1G',  'Category 1 – General',                   'OBC-1',  0),
('1K',  'Category 1 – Kannada Medium',             'OBC-1',  1),
('1R',  'Category 1 – Rural',                      'OBC-1',  0),
('2AG', 'Category 2A – General',                   'OBC-2A', 0),
('2AK', 'Category 2A – Kannada Medium',            'OBC-2A', 1),
('2AR', 'Category 2A – Rural',                     'OBC-2A', 0),
('2BG', 'Category 2B – General',                   'OBC-2B', 0),
('2BK', 'Category 2B – Kannada Medium',            'OBC-2B', 1),
('2BR', 'Category 2B – Rural',                     'OBC-2B', 0),
('3AG', 'Category 3A – General',                   'OBC-3A', 0),
('3AK', 'Category 3A – Kannada Medium',            'OBC-3A', 1),
('3AR', 'Category 3A – Rural',                     'OBC-3A', 0),
('3BG', 'Category 3B – General',                   'OBC-3B', 0),
('3BK', 'Category 3B – Kannada Medium',            'OBC-3B', 1),
('3BR', 'Category 3B – Rural',                     'OBC-3B', 0),
('GM',  'General Merit',                           'General',0),
('GMK', 'General Merit – Kannada Medium',          'General',1),
('GMP', 'General Merit – Physically Handicapped',  'General',0),
('GMR', 'General Merit – Rural',                   'General',0),
('NRI', 'Non-Resident Indian',                     'NRI',    0),
('OPN', 'Open (All Category)',                     'Open',   0),
('OTH', 'Other',                                   'Other',  0),
('SCG', 'Scheduled Caste – General',               'SC',     0),
('SCK', 'Scheduled Caste – Kannada Medium',        'SC',     1),
('SCR', 'Scheduled Caste – Rural',                 'SC',     0),
('STG', 'Scheduled Tribe – General',               'ST',     0),
('STK', 'Scheduled Tribe – Kannada Medium',        'ST',     1),
('STR', 'Scheduled Tribe – Rural',                 'ST',     0);


-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: kcet_rounds
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS kcet_rounds (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    year          INTEGER NOT NULL,
    round_number  INTEGER NOT NULL,
    seat_type     TEXT    NOT NULL DEFAULT 'Rest Of Karnataka Cut-Off Ranks'
                          CHECK (seat_type IN (
                              'Rest Of Karnataka Cut-Off Ranks',
                              'Hyderabad Karnataka Cut-Off Ranks'
                          )),
    description   TEXT,
    UNIQUE (year, round_number, seat_type)
);

INSERT OR IGNORE INTO kcet_rounds (year, round_number, seat_type, description) VALUES
(2025, 3, 'Rest Of Karnataka Cut-Off Ranks', 'UGCET 2025 Third Round – Rest of Karnataka');


-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: kcet_cutoffs  (tall/normalised — one row per category)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS kcet_cutoffs (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    round_id      INTEGER NOT NULL REFERENCES kcet_rounds(id)      ON DELETE CASCADE,
    college_id    INTEGER          REFERENCES colleges(id)          ON DELETE SET NULL,
    college_code  TEXT    NOT NULL,
    course_id     INTEGER          REFERENCES courses(id)           ON DELETE SET NULL,
    course_name   TEXT    NOT NULL,
    seat_cat_code TEXT    NOT NULL REFERENCES seat_categories(code) ON DELETE RESTRICT,
    cutoff_rank   REAL,            -- NULL = no seat filled in this category/round
    UNIQUE (round_id, college_code, course_name, seat_cat_code)
);

CREATE INDEX IF NOT EXISTS idx_cutoffs_round        ON kcet_cutoffs (round_id);
CREATE INDEX IF NOT EXISTS idx_cutoffs_college      ON kcet_cutoffs (college_id);
CREATE INDEX IF NOT EXISTS idx_cutoffs_college_code ON kcet_cutoffs (college_code);
CREATE INDEX IF NOT EXISTS idx_cutoffs_course       ON kcet_cutoffs (course_id);
CREATE INDEX IF NOT EXISTS idx_cutoffs_cat          ON kcet_cutoffs (seat_cat_code);
CREATE INDEX IF NOT EXISTS idx_cutoffs_rank         ON kcet_cutoffs (cutoff_rank)
    WHERE cutoff_rank IS NOT NULL;
-- Composite index for the most common query: rank lookup by college+course+category
CREATE INDEX IF NOT EXISTS idx_cutoffs_main
    ON kcet_cutoffs (college_code, course_name, seat_cat_code);


-- =============================================================================
-- VIEWS
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW: v_college_summary
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW IF NOT EXISTS v_college_summary AS
SELECT
    c.id,
    c.college_code,
    c.name                          AS college_name,
    c.institution_type,
    CASE c.is_autonomous WHEN 1 THEN 'Yes' ELSE 'No' END  AS autonomous,
    d.name                          AS district,
    COUNT(cr.id)                    AS course_count
FROM       colleges c
LEFT JOIN  districts d  ON d.id  = c.district_id
LEFT JOIN  courses   cr ON cr.college_id = c.id
GROUP BY   c.id, c.college_code, c.name, c.institution_type,
           c.is_autonomous, d.name;


-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW: v_cutoff_wide  (pivot GM / OPN / SCG / STG / NRI as columns)
--  SQLite has no FILTER clause before 3.44, so we use CASE+MAX instead.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW IF NOT EXISTS v_cutoff_wide AS
SELECT
    kr.year,
    kr.round_number,
    kc.college_code,
    c.name                                                              AS college_name,
    d.name                                                              AS district,
    c.institution_type,
    kc.course_name,
    MAX(CASE kc.seat_cat_code WHEN 'GM'  THEN kc.cutoff_rank END)      AS gm_rank,
    MAX(CASE kc.seat_cat_code WHEN 'OPN' THEN kc.cutoff_rank END)      AS opn_rank,
    MAX(CASE kc.seat_cat_code WHEN 'SCG' THEN kc.cutoff_rank END)      AS sc_rank,
    MAX(CASE kc.seat_cat_code WHEN 'STG' THEN kc.cutoff_rank END)      AS st_rank,
    MAX(CASE kc.seat_cat_code WHEN 'NRI' THEN kc.cutoff_rank END)      AS nri_rank,
    MAX(CASE kc.seat_cat_code WHEN '1G'  THEN kc.cutoff_rank END)      AS cat1_rank,
    MAX(CASE kc.seat_cat_code WHEN '2AG' THEN kc.cutoff_rank END)      AS cat2a_rank,
    MAX(CASE kc.seat_cat_code WHEN '2BG' THEN kc.cutoff_rank END)      AS cat2b_rank,
    MAX(CASE kc.seat_cat_code WHEN '3AG' THEN kc.cutoff_rank END)      AS cat3a_rank,
    MAX(CASE kc.seat_cat_code WHEN '3BG' THEN kc.cutoff_rank END)      AS cat3b_rank
FROM       kcet_cutoffs   kc
JOIN       kcet_rounds    kr ON kr.id = kc.round_id
LEFT JOIN  colleges       c  ON c.id  = kc.college_id
LEFT JOIN  districts      d  ON d.id  = c.district_id
GROUP BY   kr.year, kr.round_number, kc.college_code,
           c.name, d.name, c.institution_type, kc.course_name;


-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW: v_district_stats
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW IF NOT EXISTS v_district_stats AS
SELECT
    d.id                                AS district_id,
    d.name                              AS district,
    COUNT(DISTINCT c.id)                AS college_count,
    COUNT(DISTINCT cr.id)               AS total_courses,
    COUNT(DISTINCT c.institution_type)  AS institution_types_present
FROM       districts d
LEFT JOIN  colleges  c  ON c.district_id = d.id
LEFT JOIN  courses   cr ON cr.college_id  = c.id
GROUP BY   d.id, d.name
ORDER BY   college_count DESC;


-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW: v_top_cutoffs
--  Easiest starting point for rank-based college search (GM rank only)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE VIEW IF NOT EXISTS v_top_cutoffs AS
SELECT
    kc.college_code,
    c.name          AS college_name,
    d.name          AS district,
    c.institution_type,
    kc.course_name,
    kc.cutoff_rank  AS gm_rank
FROM       kcet_cutoffs  kc
JOIN       kcet_rounds   kr ON kr.id = kc.round_id
LEFT JOIN  colleges      c  ON c.id  = kc.college_id
LEFT JOIN  districts     d  ON d.id  = c.district_id
WHERE      kc.seat_cat_code = 'GM'
  AND      kc.cutoff_rank   IS NOT NULL
ORDER BY   kc.cutoff_rank ASC;


-- =============================================================================
-- SAMPLE QUERIES (developer reference)
-- =============================================================================

/*
-- 1. Find colleges with GM CSE rank below 5000
SELECT college_name, district, gm_rank
FROM   v_top_cutoffs
WHERE  course_name LIKE '%Computer Science and Engineering%'
  AND  gm_rank < 5000
ORDER  BY gm_rank;

-- 2. All courses at RV College of Engineering
SELECT cr.course_name
FROM   courses  cr
JOIN   colleges c ON c.id = cr.college_id
WHERE  c.college_code = 'E005';

-- 3. All cutoff categories for a specific college + course
SELECT sc.description, kc.cutoff_rank
FROM   kcet_cutoffs    kc
JOIN   seat_categories sc ON sc.code = kc.seat_cat_code
WHERE  kc.college_code = 'E005'
  AND  kc.course_name  LIKE '%Computer Science%'
ORDER  BY kc.cutoff_rank NULLS LAST;

-- 4. Colleges in Mysuru offering AI/ML
SELECT c.name, c.college_code, cr.course_name
FROM   colleges c
JOIN   districts d  ON d.id  = c.district_id
JOIN   courses   cr ON cr.college_id = c.id
WHERE  d.name = 'Mysuru'
  AND  cr.course_name LIKE '%Artificial Intelligence%';

-- 5. Colleges with no KCET code (not in counselling)
SELECT id, name, institution_type
FROM   colleges
WHERE  college_code IS NULL;

-- 6. District-wise college count
SELECT district, college_count, total_courses
FROM   v_district_stats;

-- 7. Compare GM vs SC vs ST rank for all CSE courses
SELECT college_name, course_name, gm_rank, sc_rank, st_rank
FROM   v_cutoff_wide
WHERE  course_name LIKE '%Computer Science and Engineering%'
  AND  gm_rank IS NOT NULL
ORDER  BY gm_rank;
*/

-- =============================================================================
-- END OF SCHEMA
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: my_options
--  Stores the student's personalised ranked college-course option list.
--  Persists across sessions in kcet.db.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS my_options (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    college_id  INTEGER NOT NULL REFERENCES colleges(id) ON DELETE CASCADE,
    course_name TEXT    NOT NULL,
    priority    INTEGER NOT NULL DEFAULT 0,
    notes       TEXT,
    added_at    TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
    UNIQUE (college_id, course_name)
);

CREATE INDEX IF NOT EXISTS idx_options_priority ON my_options (priority);
