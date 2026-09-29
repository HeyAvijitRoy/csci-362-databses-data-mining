/*
    CSCI 362 — Databases and Data Mining
    Module 5 — Reset and Seed Database

    PostgreSQL / Supabase

    PURPOSE
    -------
    This script gives every student the same starting database
    for Lesson 5B.

    It will:
      1. Remove the existing public.events table
      2. Remove the existing public.clubs table
      3. Recreate both tables
      4. Insert 6 clubs
      5. Insert 24 events

    IMPORTANT
    ---------
    Run this only in your CSCI 362 practice Supabase project.

    Running this script removes any existing data stored in
    public.events and public.clubs.
*/


-- ============================================================
-- 1. RESET THE MODULE 5 TABLES
-- ============================================================

-- DROP TABLE removes the table and all its rows. IF EXISTS lets this
-- script also run when the practice tables have not been created yet.
-- Remove events first: its club_id foreign key depends on clubs.
-- public is the schema that contains these two practice tables.

DROP TABLE IF EXISTS public.events;

DROP TABLE IF EXISTS public.clubs;


-- ============================================================
-- 2. CREATE CLUBS
-- ============================================================

-- CREATE TABLE defines the columns and rules for each club row.
CREATE TABLE public.clubs (
    -- IDENTITY generates an ID; PRIMARY KEY makes it the row's unique ID.
    club_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- Every club needs a name, and no two clubs may use the same name.
    club_name text NOT NULL UNIQUE,

    -- A missing year is allowed; a supplied year must pass this check.
    founded_year integer
        CHECK (founded_year >= 1900)
);


-- ============================================================
-- 3. CREATE EVENTS
-- ============================================================

-- Each event row belongs to one club row through club_id.
CREATE TABLE public.events (
    -- PostgreSQL generates a unique ID for each event.
    event_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- NOT NULL requires a club ID; REFERENCES requires that club to exist.
    club_id integer NOT NULL
        REFERENCES public.clubs(club_id),

    -- These details must be supplied for every new event.
    title text NOT NULL,

    category text NOT NULL,

    event_date date NOT NULL,

    -- CHECK rejects zero or negative capacity.
    capacity integer NOT NULL
        CHECK (capacity > 0),

    -- An omitted fee becomes 0; negative fees are rejected.
    fee numeric(6, 2) NOT NULL
        DEFAULT 0
        CHECK (fee >= 0),

    -- An omitted is_open value becomes true; notes may be NULL.
    is_open boolean NOT NULL
        DEFAULT true,

    notes text
);


-- ============================================================
-- 4. SEED CLUBS
-- ============================================================

-- INSERT adds rows. We name the columns so each value has a clear target.
-- club_id is omitted because PostgreSQL generates it automatically.
-- NULL means the founding year is unknown, not the text 'NULL'.
INSERT INTO public.clubs
    (club_name, founded_year)
VALUES
    ('Data Club',          2020),
    ('Robotics Club',      2018),
    ('Arts Collective',    NULL),
    ('Cybersecurity Club', 2021),
    ('Debate Society',     2017),
    ('Photography Club',   2019);


-- ============================================================
-- 5. SEED EVENTS
-- ============================================================

/*
    Because the tables were recreated above, the club IDs are:

    1 = Data Club
    2 = Robotics Club
    3 = Arts Collective
    4 = Cybersecurity Club
    5 = Debate Society
    6 = Photography Club
*/

-- The columns below define the order of values in every event row.
-- For example, (1, 'SQL Starter Lab', ...) uses club_id 1 (Data Club).
-- Dates and text are quoted; numbers, true/false, and NULL are not.
-- Each parenthesized line is one event; commas separate rows, and the
-- semicolon after the final row ends the INSERT statement.
INSERT INTO public.events
    (
        club_id,
        title,
        category,
        event_date,
        capacity,
        fee,
        is_open,
        notes
    )
VALUES

    -- Data Club
    (1, 'SQL Starter Lab', 'Workshop', '2026-10-02', 30, 0.00, true, NULL),

    -- Robotics Club
    (2, 'Robot Demo', 'Demo', '2026-10-05', 40, 0.00, true, 'Bring questions'),

    -- Data Club
    (1, 'Data Poster Night', 'Showcase', '2026-10-09', 60, 5.00, true, 'Bring a draft poster'),

    -- Arts Collective
    (3, 'Open Studio', 'Workshop', '2026-10-12', 20, 2.50, false, NULL),

    -- Robotics Club
    (2, 'Build a Sensor', 'Workshop', '2026-10-15', 25, 4.00, true, 'Materials provided'),

    -- Data Club
    (1, 'Python for Data', 'Workshop', '2026-10-16', 35, 0.00, true, 'Laptop required'),

    -- Cybersecurity Club
    (4, 'Cyber Defense Workshop', 'Workshop', '2026-10-17', 45, 5.00, true, NULL),

    -- Cybersecurity Club
    (4, 'Capture the Flag', 'Competition', '2026-10-18', 50, 0.00, true, 'Teams of four'),

    -- Photography Club
    (6, 'Portrait Walk', 'Social', '2026-10-19', 18, 0.00, true, 'Meet in lobby'),

    -- Debate Society
    (5, 'Campus Debate', 'Competition', '2026-10-20', 80, 0.00, true, NULL),

    -- Debate Society
    (5, 'AI Ethics Panel', 'Seminar', '2026-10-21', 70, 0.00, true, 'Guest speakers'),

    -- Data Club
    (1, 'Database Design Clinic', 'Workshop', '2026-10-22', 28, 0.00, true, NULL),

    -- Robotics Club
    (2, 'Robotics Competition', 'Competition', '2026-10-23', 100, 10.00, true, 'Registration required'),

    -- Photography Club
    (6, 'Photography Basics', 'Workshop', '2026-10-24', 22, 3.00, false, 'Bring any camera'),

    -- Data Club
    (1, 'Data Visualization Night', 'Showcase', '2026-10-26', 55, 5.00, true, NULL),

    -- Cybersecurity Club
    (4, 'Security Careers Talk', 'Seminar', '2026-10-27', 90, 0.00, true, 'Alumni panel'),

    -- Arts Collective
    (3, 'Open Mic Showcase', 'Showcase', '2026-10-28', 75, 2.00, false, NULL),

    -- Data Club
    (1, 'SQL Practice Session', 'Workshop', '2026-10-29', 32, 0.00, true, 'Bring laptop'),

    -- Debate Society
    (5, 'Research Poster Review', 'Seminar', '2026-10-30', 40, 0.00, true, NULL),

    -- Arts Collective
    (3, 'End-of-Semester Social', 'Social', '2026-11-02', 120, 8.00, true, 'Food included'),

    -- Photography Club
    (6, 'Night Photography Walk', 'Social', '2026-11-04', 16, 0.00, true, NULL),

    -- --------------------------------------------------------
    -- Disposable rows for DELETE practice in Lesson 5B
    -- --------------------------------------------------------

    (1, 'Temporary SQL Test Event', 'Temporary', '2026-11-10', 10, 0.00, true, NULL),

    (2, 'Temporary Demo Row', 'Temporary', '2026-11-11', 10, 0.00, true, NULL),

    (3, 'Temporary Practice Row', 'Temporary', '2026-11-12', 10, 0.00, true, NULL);


-- ============================================================
-- 6. VERIFY CLUB DATA
-- ============================================================

-- SELECT reads the saved rows; it does not change them.
-- ORDER BY club_id makes the generated IDs easy to check from 1 to 6.
SELECT
    club_id,
    club_name,
    founded_year
FROM public.clubs
ORDER BY club_id;


-- ============================================================
-- 7. VERIFY EVENT DATA
-- ============================================================

-- Check that all 24 event rows were inserted, in ID order from 1 to 24.
-- This is a second read-only query; it does not reseed or reset anything.
SELECT
    event_id,
    club_id,
    title,
    category,
    event_date,
    capacity,
    fee,
    is_open,
    notes
FROM public.events
ORDER BY event_id;


-- ============================================================
-- EXPECTED STARTING STATE
-- ============================================================
--
-- CLUBS  : 6 rows
-- EVENTS : 24 rows
--
-- Event IDs should run from 1 through 24.
--
-- Do not run this reset again after beginning Lesson 5B.
