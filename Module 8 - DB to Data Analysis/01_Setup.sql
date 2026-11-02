-- CSCI 362 Module 8. Fictional teaching data. PostgreSQL / Supabase SQL Editor.
-- Run once before the demonstrations. Separate m8 schema preserves earlier labs.
-- Re-running keeps existing rows. If checkpoints differ, inspect rather than delete.
--
-- HOW TO RUN
-- Select the complete setup from BEGIN through COMMIT and execute it together.
-- Then run the final row-count query to verify your starting state.
-- Do not depend on separate SQL Editor runs sharing an open transaction.
-- If an error leaves your connection in an aborted transaction, run ROLLBACK;
-- on that connection, inspect the error, and retry the complete setup.
-- This script adds missing seed rows; it does not restore edited values.

-- ============================================================
-- 1. CREATE THE SCHEMA AND RELATED TABLES
-- ============================================================

-- BEGIN groups the table creation and seed inserts into one transaction.
BEGIN;
-- A schema is a namespace. m8.events is separate from public.events.
CREATE SCHEMA IF NOT EXISTS m8;
-- IF NOT EXISTS keeps an existing table; it does not check or repair its design.
-- One events row represents one event, including an event with no signups.
CREATE TABLE IF NOT EXISTS m8.events (
 -- IDs are supplied in the seed data; PRIMARY KEY requires unique, non-null IDs.
 event_id integer PRIMARY KEY,
 title text NOT NULL,
 category text NOT NULL,
 event_date date NOT NULL,
 -- NOT NULL requires values; CHECK rejects invalid supplied values.
 capacity integer NOT NULL CHECK (capacity > 0),
 -- numeric(6,2) stores an exact amount with two digits after the decimal point.
 fee numeric(6,2) NOT NULL CHECK (fee >= 0)
);
-- One registrations row represents one person's signup for one event.
CREATE TABLE IF NOT EXISTS m8.registrations (
 registration_id integer PRIMARY KEY,
 -- The foreign key requires a matching event, so events must be created first.
 event_id integer NOT NULL REFERENCES m8.events(event_id),
 person_code text NOT NULL,
 registered_on date NOT NULL,
 -- NULL is allowed: an unknown outcome must remain distinct from FALSE.
 attended boolean,
 -- A person may sign up for several events, but only once for the same event.
 UNIQUE(event_id, person_code)
);
-- Feedback is another child table of events, separate from registrations.
-- It records event-level ratings without identifying individual respondents.
CREATE TABLE IF NOT EXISTS m8.feedback (
 feedback_id integer PRIMARY KEY,
 event_id integer NOT NULL REFERENCES m8.events(event_id),
 rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5)
);

-- ============================================================
-- 2. INSERT THE FICTIONAL STARTING DATA
-- ============================================================

-- Without a column list, VALUES must follow the table's declared column order:
-- event_id, title, category, event_date, capacity, fee.
-- Text and dates are quoted; numbers, booleans, and NULL are not.
-- Event 4 has no registrations; event 6 is outside the October analysis window.
INSERT INTO m8.events VALUES
 (1,'SQL Lab','Workshop','2026-10-02',10,0),
 (2,'Robot Demo','Demo','2026-10-05',20,0),
 (3,'Poster Skills','Workshop','2026-10-09',10,5),
 (4,'Art Showcase','Showcase','2026-10-12',30,0),
 (5,'Sensor Lab','Workshop','2026-10-15',20,4),
 (6,'Future SQL Lab','Workshop','2026-11-20',15,0)
-- Skip an existing event ID rather than overwrite that event's values.
ON CONFLICT (event_id) DO NOTHING;
-- Column order: registration_id, event_id, person_code, registered_on, attended.
-- Insert parent events first so these event_id foreign keys can be satisfied.
-- The NULL outcomes illustrate missing historical data and a future event.
INSERT INTO m8.registrations VALUES
 (101,1,'P01','2026-09-28',true),
 (102,1,'P02','2026-09-30',false),
 (103,1,'P03','2026-10-01',NULL),
 (104,2,'P01','2026-10-01',true),
 (105,2,'P04','2026-10-04',true),
 (106,3,'P02','2026-10-05',false),
 (107,5,'P05','2026-10-10',true),
 (108,6,'P06','2026-10-20',NULL)
-- This handles duplicate registration IDs, not every possible constraint error.
ON CONFLICT (registration_id) DO NOTHING;
-- Column order: feedback_id, event_id, rating. An event may have several ratings.
INSERT INTO m8.feedback VALUES (201,1,5),(202,1,3),(203,2,4)
ON CONFLICT (feedback_id) DO NOTHING;
-- COMMIT makes the successful setup changes permanent.
COMMIT;

-- ============================================================
-- 3. VERIFY THE STARTING COUNTS
-- ============================================================

-- Each SELECT counts one table. UNION ALL stacks the three result rows.
-- These counts are checkpoints, not proof that every stored value is correct.
SELECT 'events' AS table_name, COUNT(*) AS rows FROM m8.events
UNION ALL SELECT 'registrations',COUNT(*) FROM m8.registrations
UNION ALL SELECT 'feedback',COUNT(*) FROM m8.feedback;
-- Expected: events 6, registrations 8, feedback 3.
