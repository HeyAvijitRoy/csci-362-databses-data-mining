# CSCI 362 — Lesson 5A SQL Live Lab

**Predict → run → inspect → explain → modify**

Keep the [SQL Vocabulary and Fundamentals Guide](../SQL-Vocabulary-Guide.md) and [SQL Quick Reference](../SQL-Quick-Reference.md) open beside this file.

## Before we begin

Complete the course's **SQL Lab Readiness Guide** and confirm your Supabase project opens. Do **not** create these tables before the instructor starts the live lab. In class, open your own project, then its **SQL Editor**. Supabase interface labels can change; select the SQL Editor for the project you intend to use. The SQL Editor can change your database, so inspect each statement before running it.

Use fictional data only. Do not paste passwords, API keys, connection strings, or real student information into SQL, screenshots, or submissions. Brightspace provides the current activity and submission directions.

**Fresh-run rule:** The setup below is for a project that does not already have `public.clubs` or `public.events`. Run the two table definitions and seed inserts **once**, in order. If you see “relation already exists” or duplicate rows, stop and inspect your current tables; do not drop tables or repeatedly run the whole setup. We do not use `DROP TABLE` in this lab.

## Why are SQL keywords capitalized?

PostgreSQL treats SQL keywords such as `CREATE TABLE`, `INSERT INTO`, `SELECT`, and `WHERE` the same whether you type them in uppercase or lowercase. For example, `SELECT title FROM public.events;` and `select title from public.events;` mean the same thing. We capitalize keywords to make the commands easier to see beside lowercase table and column names; it is a style choice, not a requirement. Text inside single quotes is data, though, so keep values such as `'Workshop'` spelled and capitalized as intended.

## Lesson 5A — Build a small database and read its rows

### A. Predict the structure

We will model three campus clubs and their events. Each event belongs to one existing club. Before running the statements, identify each table's primary key, the foreign key, two required values, and one default.

A table stores rows of one kind of thing: one row per club in `clubs`, and one row per event in `events`. A **primary key** uniquely identifies a row. A **foreign key** connects an event to a club that already exists. `NOT NULL` requires a value, `DEFAULT` supplies one when omitted, and `CHECK` rejects values outside a rule. Look for these words in the definitions below before running them.

### B. Create the tables

`CREATE TABLE` defines a table's columns and rules. `public` is the schema containing our practice tables. Inside the parentheses, commas separate column definitions, and the semicolon ends the statement.

In `clubs`, `club_id` is generated automatically and acts as the primary key. `club_name` is required and cannot repeat. `founded_year` may be missing (`NULL`), but a supplied year must be at least 1900.

Run **each statement once**, beginning with `clubs` because `events` refers to it:

```sql
CREATE TABLE public.clubs (
    club_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    club_name text NOT NULL UNIQUE,
    founded_year integer CHECK (founded_year >= 1900)
);
```

In `events`, `event_id` is the generated primary key. `club_id` is required and `REFERENCES public.clubs(club_id)` makes it a foreign key. `title`, `category`, `event_date`, and `capacity` are required; capacity must be positive. `fee` defaults to 0 and cannot be negative. `is_open` is a true/false value that defaults to `true`, while `notes` is optional. Create `clubs` first so the referenced table exists when PostgreSQL creates `events`.

The data types describe allowed values: `integer` for whole numbers, `text` for words, `date` for calendar dates, `numeric(6, 2)` for exact numbers with two decimal places, and `boolean` for `true` or `false`.

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

`INSERT INTO` adds stored rows. The names after the table identify the columns being filled; each parenthesized group after `VALUES` supplies one row in that same order. We omit `club_id` because `GENERATED ALWAYS AS IDENTITY` supplies it. Text uses single quotes, numbers do not, and unquoted `NULL` means the year is unknown.

Run the club insert once. On a fresh setup, generated IDs will be 1, 2, and 3 in this order:

```sql
INSERT INTO public.clubs (club_name, founded_year)
VALUES
    ('Data Club', 2020),
    ('Robotics Club', 2018),
    ('Arts Collective', NULL);
```

`SELECT` reads data without changing it. `ORDER BY club_id` displays the clubs by generated ID so you can check which ID belongs to each name before inserting events.

Check before continuing:

```sql
SELECT club_id, club_name, founded_year
FROM public.clubs
ORDER BY club_id;
```

Confirm that you see exactly three clubs with IDs 1, 2, and 3 in the order above. If the count or IDs differ, stop and inspect your project before running the event insert; do not guess which club an ID represents.

The event insert names its target columns in order. Each line after `VALUES` is one event. The first number is a `club_id` from the table you just checked; dates and text are quoted, `true` and `false` are boolean values, and `NULL` means no note was supplied. The sixth row is disposable example data. Lesson 5B will replace this small dataset with a new one.

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

Read the saved rows before querying them. `SELECT` shows the listed columns, and `ORDER BY event_id` puts the six generated event IDs in order. This inspection checks that the foreign key values, fees, open/closed values, and missing notes match what you intended to insert.

Inspect what was stored:

```sql
SELECT event_id, club_id, title, category, event_date,
       capacity, fee, is_open, notes
FROM public.events
ORDER BY event_id;
```

**Expected checkpoint on a fresh run:** 3 club rows and 6 event rows. The last event has ID 6. `fee` displays two decimal places, and `notes` can show `NULL`. If the count or IDs differ, stop and investigate before relying on the checkpoints below.

### D. First questions

The first query uses `WHERE category = 'Workshop'` to keep only workshop rows and `ORDER BY event_date` to show them from earliest to latest. It does **not** check `is_open`, so a closed workshop can still appear. In the second query, `>=` means “at least,” `AND` requires both conditions, and `DESC` sorts capacities from largest to smallest. If capacities tie, `title` sorts those rows alphabetically.

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

Each prompt uses a different reading skill: `WHERE fee > 0` finds paid events; `ORDER BY fee` sorts them; `DISTINCT` removes repeated categories from the **result**; PostgreSQL's `ILIKE '%data%'` finds titles containing `data` without requiring the same capitalization; and `IS NULL` finds missing notes. `%` means any number of characters. `NULL` is not a normal text value, so `notes = NULL` will not identify missing notes. These are all `SELECT` tasks and should not change stored rows.

Write a query for each prompt. Say what you expect **before** pressing Run.

1. Show `title` and `fee` for all events that cost more than zero, sorted from lowest fee to highest fee.
2. Show the distinct categories in alphabetical order.
3. Show event titles containing `data`, regardless of capitalization.
4. Show titles whose `notes` are missing. Why would `notes = NULL` fail?

**Self-check:** Prompt 1 returns three events; Prompt 2 returns four categories; Prompt 3 returns one event; Prompt 4 returns three events. Compare your result with those counts, then explain any mismatch. A count is a check here, not a new SQL topic.

## After Lesson 5A

For Lesson 5B, follow [Module 5 Database Setup](Module-5-Database-Setup.md) and run [Module 5 Reset and Seed](Module-5-Reset-and-Seed.sql) in your CSCI 362 practice project. The reset removes the 5A practice rows and creates the shared 5B starting data. Then open [Lesson 5B SQL Live Lab](Module-5B-SQL-Live-Lab.md). Follow Brightspace for release timing and any submission instructions.
