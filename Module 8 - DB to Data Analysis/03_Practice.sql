-- Save your completed copy. Run setup first. Do not change the source data.
-- Keep Activity_Guide.md open for the case assumptions and written questions.
-- Work pattern: Predict -> Run -> Inspect -> Explain -> Modify.
-- Replace each TODO with your own SELECT query; keep written responses as comments.
-- Select one complete statement at a time, through its final semicolon.
-- When using a CTE, include WITH and its final SELECT in the same execution.

-- ============================================================
-- PART A: QUESTIONS AND EXTRACTION
-- ============================================================

-- A1. Select October events only. Return event_id,title,category,capacity,fee.
-- State what one output row represents before you write the query.
-- Use the fixed event-date window [2026-10-01,2026-11-01), not today's date.
-- TODO

-- A2. Produce one row per October event with registrations,
-- known_outcomes,observed_attendees,unknown_outcomes. Keep event 4.
-- Compare the output with D2 and D3. Does each event ID appear exactly once?
-- Explain which counts ignore NULL and which count both TRUE and FALSE.
-- TODO

-- A3. Add attendance_pct_known using a decimal numerator and NULLIF.
-- Explain what the denominator means. Explain event 4's NULL.
-- If you reuse count aliases, calculate the rate in an outer SELECT as in D3.
-- Do not turn an undefined rate into zero; those values mean different things.
-- TODO

-- ============================================================
-- PART B: QUALITY, DESCRIPTION, AND PREDICTION
-- ============================================================

-- B1. Reuse your event summary as a CTE. Group by category and return
-- event_count,total_observed_attendees,mean_observed_attendees_per_event.
-- Include events with zero signups. In a separate query, calculate the overall
-- mean with AVG(observed_attendees) across all five October event-level rows.
-- For the overall median, sort those five counts and report the third value
-- in your written response. A SQL median calculation is optional.
-- Write one supported finding and one limitation; explain whether a higher
-- category average establishes that category causes better attendance.
-- A CTE from a previous statement is no longer available. Repeat its definition
-- for each new query, and keep the event-level counts distinct from raw joins.
-- TODO

-- B2. Audit this unconstrained import without changing it.
-- Identify the duplicate business key, orphan event, invalid code, and date issue.
-- Allowed status codes: Y = recorded attendance; N = recorded absence.
-- Any other value is undefined; seek clarification before converting it.
-- VALUES creates temporary input rows for this statement; it inserts no table rows.
-- Column names after raw_registration describe the position of each VALUES item.
WITH raw_registration(registration_id,event_id,person_code,registered_on,status) AS (
 VALUES (901,1,'P10',DATE '2026-09-30','Y'),
        (902,1,'P10',DATE '2026-09-30','Y'),
        (903,99,'P11',DATE '2026-10-01','N'),
        (904,2,'P12',DATE '2026-10-01','maybe'),
        (905,3,'P13',DATE '2026-10-10','N')
)
SELECT * FROM raw_registration;
-- TODO: Write checks or annotate specific rows. Propose a documented action.
-- To query these raw rows again, repeat the WITH definition and change its SELECT.
-- Check business-key uniqueness separately from registration_id uniqueness.
-- Record evidence and unresolved questions; keep the raw source unchanged.

-- B3. Extract a prediction table at signup time. Keep known October outcomes.
-- Columns: registration_id,event_id,category,fee,days_notice,target_attended.
-- Use D6 to review the prediction moment, date subtraction, and label handling.
-- Verify the output grain and explain both exclusions using the source records.
-- TODO

-- B4. In your written response, assess these proposed features:
-- fee,category,days_notice,post-event feedback rating,final attendee count,person_code.
-- State a leakage risk, an identifier concern, and an evaluation plan.
-- For each proposed feature, ask: would its value be known immediately at signup?
-- Explain how later-event evaluation would keep an event's registrations together.
-- This is a written planning task; no model fitting is required.
