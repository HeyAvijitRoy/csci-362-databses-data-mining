# CSCI 362 — Lesson 5A SQL Live Lab

**Predict → run → inspect → explain → modify**

Keep the [SQL Vocabulary and Fundamentals Guide](../SQL-Vocabulary-Guide.md) and [SQL Quick Reference](../SQL-Quick-Reference.md) open beside this file.

## Before we begin

Complete the course's **SQL Lab Readiness Guide** and confirm your Supabase project opens. Do **not** create these tables before the instructor starts the live lab. In class, open your own project, then its **SQL Editor**. Supabase interface labels can change; select the SQL Editor for the project you intend to use. The SQL Editor can change your database, so inspect each statement before running it.

Use fictional data only. Do not paste passwords, API keys, connection strings, or real student information into SQL, screenshots, or submissions. Brightspace provides the current activity and submission directions.

**Fresh-run rule:** The setup below is for a project that does not already have `public.clubs` or `public.events`. Run the two table definitions and seed inserts **once**, in order. If you see “relation already exists” or duplicate rows, stop and inspect your current tables; do not drop tables or repeatedly run the whole setup. We do not use `DROP TABLE` in this lab.

## Lesson 5A — Build a small database and read its rows

### A. Predict the structure

We will model three campus clubs and their events. Each event belongs to one existing club. Before running the statements, identify each table's primary key, the foreign key, two required values, and one default.

### B. Create the tables

Run **each statement once**, beginning with `clubs` because `events` refers to it:

```sql
CREATE TABLE public.clubs (
    club_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    club_name text NOT NULL UNIQUE,
    founded_year integer CHECK (founded_year >= 1900)
);
```

```sql
CREATE TABLE public.events (
    event_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    club_id integer NOT NULL REFERENCES public.clubs(club_id),
    title text NOT NULL,
    category text NOT NULL,
    event_date date NOT NULL,
    capacity integer NOT NULL CHECK (capacity > 0),
    fee numeric(6, 2) NOT NULL DEFAULT 0 CHECK (fee >= 0),
    is_open boolean NOT NULL DEFAULT true,
    notes text
);
```

**Explain:** Why must `clubs` exist before `events`? What would `CHECK (capacity > 0)` prevent?

### C. Insert small, known data

Run the club insert once. On a fresh setup, generated IDs will be 1, 2, and 3 in this order:

```sql
INSERT INTO public.clubs (club_name, founded_year)
VALUES
    ('Data Club', 2020),
    ('Robotics Club', 2018),
    ('Arts Collective', NULL);
```

Check before continuing:

```sql
SELECT club_id, club_name, founded_year
FROM public.clubs
ORDER BY club_id;
```

If your IDs are different, use the IDs you **actually see** for the matching clubs in the next insert. The numbers below assume a fresh run. Row 6 is a disposable practice row for later DELETE practice. Lesson 5B starts from a new seed dataset.

```sql
INSERT INTO public.events
    (club_id, title, category, event_date, capacity, fee, is_open, notes)
VALUES
    (1, 'SQL Starter Lab',       'Workshop', '2026-10-02', 30, 0.00, true,  NULL),
    (2, 'Robot Demo',            'Demo',     '2026-10-05', 40, 0.00, true,  'Bring questions'),
    (1, 'Data Poster Night',     'Showcase', '2026-10-09', 60, 5.00, true,  'Bring a draft poster'),
    (3, 'Open Studio',           'Workshop', '2026-10-12', 20, 2.50, false, NULL),
    (2, 'Build a Sensor',        'Workshop', '2026-10-15', 25, 4.00, true,  'Materials provided'),
    (3, 'Practice Row to Delete','Practice', '2026-10-20', 10, 0.00, true,  NULL);
```

Inspect what was stored:

```sql
SELECT event_id, club_id, title, category, event_date,
       capacity, fee, is_open, notes
FROM public.events
ORDER BY event_id;
```

**Expected checkpoint on a fresh run:** 3 club rows and 6 event rows. The last event has ID 6. `fee` displays two decimal places, and `notes` can show `NULL`. If your IDs differ because the table already contained data, use the actual IDs throughout this lab.

### D. First questions

Predict the rows before running each query:

```sql
SELECT title, event_date
FROM public.events
WHERE category = 'Workshop'
ORDER BY event_date;
```

```sql
SELECT title, capacity
FROM public.events
WHERE capacity >= 30 AND is_open = true
ORDER BY capacity DESC, title;
```

**Check your reasoning:** The first query returns three workshops, including one that is closed; it filters by category only. The second returns three open events with at least 30 seats, ordered from the largest capacity downward. Try adding `AND is_open = true` to the first query. What disappears, and why?

### E. Your turn, without changing data

Write a query for each prompt. Say what you expect **before** pressing Run.

1. Show `title` and `fee` for all events that cost more than zero, sorted from lowest fee to highest fee.
2. Show the distinct categories in alphabetical order.
3. Show event titles containing `data`, regardless of capitalization.
4. Show titles whose `notes` are missing. Why would `notes = NULL` fail?

**Self-check:** Prompt 1 returns three events; Prompt 2 returns four categories; Prompt 3 returns one event; Prompt 4 returns three events. Compare your result with those counts, then explain any mismatch. A count is a check here, not a new SQL topic.

## After Lesson 5A

For Lesson 5B, follow [Module 5 Database Setup](Module-5-Database-Setup.md) and run [Module 5 Reset and Seed](Module-5-Reset-and-Seed.sql) in your CSCI 362 practice project. The reset removes the 5A practice rows and creates the shared 5B starting data. Then open [Lesson 5B SQL Live Lab](Module-5B-SQL-Live-Lab.md). Follow Brightspace for release timing and any submission instructions.
