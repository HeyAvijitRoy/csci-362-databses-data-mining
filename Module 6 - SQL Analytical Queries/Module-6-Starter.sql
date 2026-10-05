/*
    CSCI 362 — Module 6 Student Starter SQL
    PostgreSQL / Supabase

    Database:
      public.clubs
      public.events

    Before starting:
      1. Run Module-5-Reset-and-Seed.sql once if instructed.
      2. Confirm 6 clubs and 24 events.

    Work pattern:
      Predict -> Run -> Inspect -> Explain -> Modify

    IMPORTANT:
      These tasks are read-only. Do not INSERT, UPDATE, or DELETE unless
      the instructor explicitly asks you to do so.
*/


-- ============================================================
-- PART A — RELATIONSHIP WARM-UP
-- ============================================================

-- A1. Inspect the club table.
SELECT
    club_id,
    club_name,
    founded_year
FROM public.clubs
ORDER BY club_id;


-- A2. Inspect the event table.
SELECT
    event_id,
    club_id,
    title,
    category,
    event_date
FROM public.events
ORDER BY event_id;


-- A3. Before writing a JOIN, answer in a comment:
--     Which two columns connect EVENTS to CLUBS?
-- ANSWER:
--


-- ============================================================
-- PART B — JOINS
-- ============================================================

-- B1. INNER JOIN
-- Goal: show every event with its readable club name.
-- Return: event_id, title, club_name
-- Sort by event_id.

-- TODO: write your query below.



-- B2. Filter after the JOIN
-- Goal: show only open events for Cybersecurity Club.
-- Return: event_id, title, event_date, club_name
-- Do not hard-code club_id = 4.

-- TODO:



-- B3. Join information from both tables in one filter.
-- Goal: show paid events from clubs founded in or after 2019.
-- Return: club_name, founded_year, title, fee
-- Sort by fee DESC, then title.

-- TODO:



-- B4. LEFT JOIN
-- Goal: show every club and any Workshop events it has.
-- Clubs with no Workshop must remain visible.
-- Return: club_name, workshop_title
-- Hint: the Workshop restriction belongs in ON if you want to preserve
--       clubs that have no matching Workshop.

-- TODO:



-- B5. Find missing matches.
-- Goal: return only clubs that have no Workshop event.
-- Hint: LEFT JOIN + right-side key IS NULL.

-- TODO:



-- B6. Compare ON versus WHERE.
-- First write a LEFT JOIN that preserves all clubs while matching only
-- Seminar events in ON.
-- Then write a second version that moves e.category = 'Seminar' to WHERE.
-- In comments, explain why the result counts differ.

-- Version 1:



-- Version 2:



-- Explanation:
--


-- ============================================================
-- PART C — JOIN REASONING
-- ============================================================

-- C1. Predict before running:
-- How many rows should this return from the reset dataset?
-- Why?
SELECT
    e.event_id,
    e.title,
    c.club_name
FROM public.events AS e
INNER JOIN public.clubs AS c
    ON e.club_id = c.club_id;

-- Prediction:
--
-- Explanation:
--


-- C2. Find every club founded in or after 2019 and any Competition
-- events it has. The qualifying club must still appear even if it has
-- no Competition event.
-- Return: club_name, founded_year, competition_title
-- Sort by club_name.

-- TODO:



-- ============================================================
-- PART D — AGGREGATES AND GROUP BY
-- ============================================================

-- D1. One aggregate result row.
-- Return:
--   event_count
--   total_capacity
--   average_capacity rounded to 2 decimals
--   minimum_capacity
--   maximum_capacity

-- TODO:



-- D2. Count all events versus events with notes.
-- Return both counts in one row.

-- TODO:



-- D3. One row per category.
-- Return: category, event_count, average_capacity
-- Round average_capacity to 2 decimals.
-- Sort by event_count DESC, then category.

-- TODO:



-- D4. One row per club.
-- Return: club_name, event_count
-- Join CLUBS to EVENTS, group by club, and sort from most events to least.

-- TODO:



-- D5. Count open events per club.
-- WHERE should remove closed event rows before grouping.
-- Return: club_name, open_event_count

-- TODO:



-- ============================================================
-- PART E — HAVING AND OUTER-JOIN AGGREGATION
-- ============================================================

-- E1. Which clubs have at least 4 total events?
-- Return: club_name, event_count
-- Use HAVING.

-- TODO:



-- E2. Among open events only, which clubs have at least 3 open events?
-- Return: club_name, open_event_count
-- This requires both WHERE and HAVING.

-- TODO:



-- E3. Workshop count for every club, including zero.
-- Return: club_name, workshop_count
-- Use LEFT JOIN.
-- Important: count e.event_id, not COUNT(*).

-- TODO:



-- E4. Compare COUNT(*) with COUNT(e.event_id) after a LEFT JOIN.
-- Use the Workshop-only LEFT JOIN and return:
-- club_name, joined_rows, workshop_matches
-- Explain Debate Society's two different counts in a comment.

-- TODO:


-- Explanation:
--


-- ============================================================
-- PART F — SUBQUERIES
-- ============================================================

-- F1. Scalar subquery.
-- Goal: show events whose capacity is above the average event capacity.
-- Return: title, capacity
-- Sort capacity DESC.

-- TODO:



-- F2. IN subquery.
-- Goal: list clubs that have at least one paid event.
-- Do not use JOIN for this version.
-- Return: club_id, club_name

-- TODO:



-- F3. EXISTS.
-- Goal: list clubs that have at least one Workshop event.
-- Return: club_name

-- TODO:



-- F4. NOT EXISTS.
-- Goal: list clubs that have no Workshop event.
-- Return: club_name

-- TODO:



-- F5. Above-average fee.
-- Goal: show events whose fee is greater than the average event fee.
-- Return: title, fee
-- Do not manually type the average.

-- TODO:



-- ============================================================
-- PART G — INTEGRATED CHALLENGES
-- ============================================================

-- G1. Among open events, show clubs with at least 3 open events.
-- Return:
--   club_name
--   open_event_count
--   average_open_capacity rounded to 2 decimals
-- Sort by open_event_count DESC, then club_name.

-- TODO:



-- G2. Use NOT EXISTS to find clubs with no Social events.
-- Return: club_name

-- TODO:



-- G3. Write one question of your own that requires BOTH:
--     - a JOIN
--     - an aggregate function
-- Then write the SQL below.
--
-- Your question:
--
-- SQL:


