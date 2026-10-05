/*
    CSCI 362 — Module 6 Database Verification
    PostgreSQL / Supabase

    PURPOSE
    -------
    Run these read-only statements after running the existing
    Module-5-Reset-and-Seed.sql file.

    Expected starting state:
      public.clubs  = 6 rows
      public.events = 24 rows

    This file does not insert, update, delete, or reset data.
*/

-- ------------------------------------------------------------
-- 1. Confirm row counts
-- ------------------------------------------------------------
SELECT COUNT(*) AS club_count
FROM public.clubs;

SELECT COUNT(*) AS event_count
FROM public.events;

-- Expected:
-- club_count  = 6
-- event_count = 24


-- ------------------------------------------------------------
-- 2. Confirm club IDs and names
-- ------------------------------------------------------------
SELECT
    club_id,
    club_name,
    founded_year
FROM public.clubs
ORDER BY club_id;

-- Expected IDs:
-- 1 Data Club
-- 2 Robotics Club
-- 3 Arts Collective
-- 4 Cybersecurity Club
-- 5 Debate Society
-- 6 Photography Club


-- ------------------------------------------------------------
-- 3. Confirm event IDs and club references
-- ------------------------------------------------------------
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

-- Expected: event_id 1 through 24.


-- ------------------------------------------------------------
-- 4. Confirm that every event references an existing club
-- ------------------------------------------------------------
SELECT
    e.event_id,
    e.club_id,
    e.title
FROM public.events AS e
LEFT JOIN public.clubs AS c
    ON c.club_id = e.club_id
WHERE c.club_id IS NULL;

-- Expected: 0 rows.
-- The foreign key should prevent an event from referencing a club
-- that does not exist.


-- ------------------------------------------------------------
-- 5. Confirm how many events belong to each club
-- ------------------------------------------------------------
SELECT
    c.club_id,
    c.club_name,
    COUNT(e.event_id) AS event_count
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id
GROUP BY
    c.club_id,
    c.club_name
ORDER BY c.club_id;

-- Expected event counts from the reset dataset:
-- Data Club          7
-- Robotics Club      4
-- Arts Collective    4
-- Cybersecurity Club 3
-- Debate Society     3
-- Photography Club   3
