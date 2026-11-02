-- Run labeled blocks separately after 01_Setup.sql.
-- Fixed snapshot: 2026-11-01. Historical window: [2026-10-01,2026-11-01).
-- All five October events took place. Registration capture is complete.
-- TRUE = recorded attendance, FALSE = recorded absence, NULL = outcome unknown.
--
-- Work pattern: Predict -> Run -> Inspect -> Explain -> Modify.
-- Each D block is one complete read-only statement ending with a semicolon.
-- For a WITH query, select from WITH through the final SELECT's semicolon.
-- A CTE exists only within its statement; it is not a saved table or view.

-- ============================================================
-- D1: Grain changes after a join. Predict 3 rows for event 1.
-- ============================================================
-- e and r are table aliases; qualified names show which table owns a column.
-- JOIN matches an event to each of its registrations using the shared event_id.
-- The output grain is one registration, so event details repeat across rows.
SELECT e.event_id,e.title,r.registration_id,r.attended
FROM m8.events AS e
JOIN m8.registrations AS r ON r.event_id=e.event_id
WHERE e.event_id=1 ORDER BY r.registration_id;

-- ============================================================
-- D2: Preserve the event with no registrations. Predict 1 versus 0.
-- ============================================================
-- LEFT JOIN keeps event 4 and supplies NULLs for the missing registration.
-- COUNT(*) counts that joined row; COUNT(r.registration_id) ignores its NULL ID.
-- GROUP BY combines the joined rows into one result row for this event.
SELECT e.event_id,COUNT(*) AS joined_rows,
       COUNT(r.registration_id) AS registrations
FROM m8.events AS e
LEFT JOIN m8.registrations AS r ON r.event_id=e.event_id
WHERE e.event_id=4 GROUP BY e.event_id;

-- ============================================================
-- D3: One row per October event. CTE = named query result for this statement.
-- ============================================================
-- First build the event counts; the outer SELECT then uses their aliases.
WITH event_summary AS (
 SELECT e.event_id,e.title,e.category,e.event_date,e.capacity,e.fee,
        COUNT(r.registration_id) AS registrations,
        -- COUNT counts non-null values, including a recorded FALSE.
        COUNT(r.attended) AS known_outcomes,
        -- CASE returns 1 only for TRUE; omitted ELSE returns NULL otherwise.
        -- COUNT therefore counts only recorded attendees.
        COUNT(CASE WHEN r.attended=true THEN 1 END) AS observed_attendees,
        -- Subtract known outcomes from actual signups, not from joined rows.
        COUNT(r.registration_id)-COUNT(r.attended) AS unknown_outcomes
 FROM m8.events AS e
 LEFT JOIN m8.registrations AS r ON r.event_id=e.event_id
 -- Filter event dates: a signup before October may belong to an October event.
 -- The half-open window includes October 1 and excludes November 1.
 WHERE e.event_date >= DATE '2026-10-01'
   AND e.event_date < DATE '2026-11-01'
 GROUP BY e.event_id,e.title,e.category,e.event_date,e.capacity,e.fee
)
-- 100.0 gives decimal division; NULLIF changes a zero denominator to NULL.
-- ROUND(...,1) displays one decimal place. An undefined rate stays NULL.
SELECT *,ROUND(100.0*observed_attendees/NULLIF(known_outcomes,0),1)
          AS attendance_pct_known
FROM event_summary ORDER BY event_id;
-- Event IDs 1..5. registrations 3,2,1,0,1; known 2,2,1,0,1;
-- observed 1,2,0,0,1; unknown 1,0,0,0,0; percent 50,100,0,NULL,100.

-- ============================================================
-- D4: Join multiplication. Event 1 has 3 registrations and 2 feedback rows.
-- ============================================================
-- Deliberately misleading count: each registration matches both feedback rows.
-- Predict the number of joined rows before trusting an aggregate after a join.
SELECT e.event_id,COUNT(r.registration_id) AS inflated_registrations
FROM m8.events AS e
LEFT JOIN m8.registrations AS r ON r.event_id=e.event_id
LEFT JOIN m8.feedback AS f ON f.event_id=e.event_id
WHERE e.event_id=1 GROUP BY e.event_id;
-- Expected 6, but the correct registration count is 3.

-- ============================================================
-- D5: Aggregate each child table to event grain before joining.
-- ============================================================
-- Each CTE returns at most one row per event, preventing child-row multiplication.
WITH registration_counts AS (
 SELECT event_id,COUNT(*) AS registrations
 FROM m8.registrations GROUP BY event_id
), feedback_summary AS (
 SELECT event_id,AVG(rating) AS mean_rating
 FROM m8.feedback GROUP BY event_id
)
-- A missing registration summary means zero signups, so COALESCE supplies 0.
-- A missing rating summary means no ratings; leave that mean NULL, not zero.
SELECT e.event_id,COALESCE(r.registrations,0) AS registrations,f.mean_rating
FROM m8.events AS e
LEFT JOIN registration_counts AS r ON r.event_id=e.event_id
LEFT JOIN feedback_summary AS f ON f.event_id=e.event_id
WHERE e.event_id=1;
-- Expected event 1, registrations 3, mean_rating 4.0.

-- ============================================================
-- D6: Prediction table. One row per registration with a known October outcome.
-- ============================================================
-- Prediction moment: immediately after signup. Event attributes are assumed fixed.
-- registered_on and event_date are dates, so subtraction returns whole days.
-- This historical training table pairs signup-time inputs with a later outcome.
-- target_attended is the outcome to predict, not an input available at signup.
SELECT r.registration_id,e.event_id,e.category,e.fee,
       e.event_date-r.registered_on AS days_notice,
       CASE WHEN r.attended=true THEN 1 ELSE 0 END AS target_attended
FROM m8.registrations AS r
JOIN m8.events AS e ON e.event_id=r.event_id
WHERE e.event_date >= DATE '2026-10-01'
  AND e.event_date < DATE '2026-11-01'
  -- Exclude unknown labels before using ELSE 0; otherwise NULL would become 0.
  AND r.attended IS NOT NULL
ORDER BY r.registration_id;
-- Six rows, four positive targets. Identifiers support audit, not default features.
