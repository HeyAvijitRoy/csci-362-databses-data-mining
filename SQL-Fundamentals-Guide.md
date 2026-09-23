# CSCI 362 — SQL Fundamentals Guide

**Module 5 · PostgreSQL in the Supabase SQL Editor**  
Companion references: [SQL Lab Readiness Guide](SQL-Lab-Readiness-Guide.md) · [SQL Vocabulary Guide](SQL-Vocabulary-Guide.md) · [SQL Quick Reference](SQL-Quick-Reference.md)

## How to use this guide

Before class, read Sections 1–4 and **predict** what the short queries will return. You do not need to memorize every command or run the lab early. In class, keep this guide beside the Supabase SQL Editor while we build tables and test queries together. After class, use the quick reference when writing your own SQL.

The code fragments here explain individual ideas. The **Module 5 SQL Live Lab**, provided with the class materials, is the single step-by-step setup sequence; do not run both sets of `CREATE` or `INSERT` examples into the same tables. Use the Readiness Guide to prepare your project and the Vocabulary Guide when a term is unfamiliar.

Our sequence is **predict → run → inspect → explain → change one thing**. An error is useful evidence: read its message, find the cause, and revise the smallest part of the statement. The examples use fictional campus-club data; do not enter real student or personal information.

### What you should be able to do by the end

- Explain the difference between a table's **structure** and its current **rows**.
- Create a small PostgreSQL table with suitable types and constraints.
- Add, inspect, update, and delete rows safely.
- Retrieve columns and rows with `SELECT`, filters, sorting, expressions, aliases, and a few basic functions.
- Explain why a query returned its particular rows, including how `NULL` affects a filter.

**Scope:** Module 6 will combine tables with joins and introduce grouping, aggregate functions, `HAVING`, and subqueries. A foreign key appears here because it is a table constraint; we will not query across tables yet.

## 1. From a model to SQL

In a relational model, a **relation** has attributes and tuples. In everyday SQL, we usually say **table**, **columns**, and **rows**. The table definition (names, types, constraints) is its *schema*; its rows at a particular moment are its *data*. A primary key identifies a row. A foreign key links a value to a row in another table.

For our lab, one club can have many events:

```text
clubs                         events
club_id (primary key)   ←     club_id (foreign key)
club_name                     event_id (primary key)
founded_year                  title, category, event_date, capacity, fee, is_open, notes
```

Supabase has already created your **project and PostgreSQL database**. In the SQL Editor, create tables *inside that database*. Do not run an inherited example such as `CREATE DATABASE COMPANY;` in your course project. We use the existing `public` schema for the lab tables.

SQL keywords are shown in uppercase for readability; PostgreSQL does not require uppercase. Use lowercase, unquoted names such as `event_date`. Single quotes surround text and date values (`'Workshop'`, `'2026-09-28'`); double quotes identify case-sensitive SQL names and are unnecessary in our examples. End each statement with `;`.

## 2. Create tables: types and rules

Run the complete setup in the **Module 5 SQL Live Lab** when instructed. The first table illustrates the pattern:

```sql
CREATE TABLE public.clubs (
    club_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    club_name text NOT NULL UNIQUE,
    founded_year integer CHECK (founded_year >= 1900)
);
```

Read it as: create a table named `clubs`; let PostgreSQL generate each `club_id`; require every `club_name` to have a value and prevent duplicate names; reject a supplied `founded_year` below 1900. The check allows `NULL` unless the column is also `NOT NULL`. Here, an unknown founding year is acceptable.

The second table demonstrates a link:

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

`REFERENCES` creates a foreign key. An event's `club_id` must already exist in `clubs`. PostgreSQL rejects an event with an unknown club. We let the default referential action reject a club deletion while events still refer to it; we do not use automatic cascading deletes in this first lab.

| Type | Example use | Why choose it |
| --- | --- | --- |
| `integer` | `capacity`, generated IDs | Whole numbers. |
| `text` | `title`, `notes` | Variable-length text without choosing an artificial limit. |
| `numeric(6, 2)` | `fee` | Exact decimal values, with two digits after the decimal point. |
| `date` | `event_date` | Calendar date without a time of day. |
| `boolean` | `is_open` | `true` or `false`. |
| `timestamp` / `timestamptz` | Later date-and-time work | `timestamptz` represents a time-aware instant; use `date` when only the day matters. |

`varchar(n)` also stores text, but use it when a real rule limits the length. Avoid floating-point types for exact fees. A type limits the *kind* of value; a constraint adds a *business rule*.

| Constraint | Meaning in this lab |
| --- | --- |
| `PRIMARY KEY` | Unique row identifier; cannot be `NULL`. |
| `NOT NULL` | A value is required. |
| `UNIQUE` | No two non-null club names may be equal. |
| `CHECK` | A supplied value must satisfy a condition, such as `capacity > 0`. |
| `DEFAULT` | Fill in a value when an `INSERT` omits the column. |
| `REFERENCES` | Require a matching key in another table. |

> **Think first:** What would happen if you inserted an event with `capacity = 0`? Which rule would reject it? What about an event with `club_id = 99` when no club 99 exists?

### Supabase note: SQL Editor access is powerful

Use the **SQL Editor** in your own course project. It runs with database privileges suitable for creating these lab objects; its success does **not** prove that a browser client or Data API can access the same rows. Supabase's API grants and Row Level Security are separate topics. Keep the project configuration from the course's SQL Lab Readiness Guide. Never paste passwords, API keys, connection strings, or real student data into a shared SQL script or screenshot.

## 3. Insert and inspect rows

List the target columns. It makes the mapping between values and columns visible and allows defaults to work:

```sql
INSERT INTO public.clubs (club_name, founded_year)
VALUES ('Data Club', 2020);
```

PostgreSQL generates `club_id`. If the table is empty, this will normally be ID 1; **do not rely on generated IDs always being gap-free or starting at 1**. The lab setup includes a complete, repeatable sample dataset and its expected IDs for a fresh run.

One `INSERT` may add multiple rows:

```sql
INSERT INTO public.events
    (club_id, title, category, event_date, capacity, fee, notes)
VALUES
    (1, 'SQL Starter Lab', 'Workshop', '2026-10-02', 30, 0, NULL),
    (1, 'Data Poster Night', 'Showcase', '2026-10-09', 60, 5.00,
     'Bring a draft poster');
```

Because `is_open` is omitted, it receives its default `true`. `NULL` means the note is unknown or absent; it is **not** the text `'NULL'` or an empty string `''`.

To inspect all rows while exploring:

```sql
SELECT *
FROM public.events
ORDER BY event_id;
```

`*` is convenient for inspection. For a result you will share or reuse, name the columns you need; doing so makes the output clearer and less sensitive to table changes.

## 4. Ask questions with `SELECT`

The basic reading order is:

```sql
SELECT title, event_date
FROM public.events
WHERE category = 'Workshop'
ORDER BY event_date, title;
```

`FROM` identifies the table. `WHERE` keeps rows that meet a condition. `SELECT` chooses output columns. `ORDER BY` sets the display order. Think through those jobs even though the written SQL begins with `SELECT`. Without `ORDER BY`, do **not** assume rows will appear in insertion or ID order.

### Filter deliberately

```sql
SELECT title, capacity
FROM public.events
WHERE capacity >= 30 AND is_open = true
ORDER BY capacity DESC, title ASC;
```

Comparisons use `=`, `<>` (not equal), `<`, `<=`, `>`, and `>=`. `AND` requires both conditions; `OR` requires either. Use parentheses when mixing them:

```sql
WHERE (category = 'Workshop' OR category = 'Showcase')
  AND is_open = true
```

Other useful filters:

```sql
WHERE fee BETWEEN 0 AND 5          -- includes both endpoints
WHERE category IN ('Workshop', 'Showcase')
WHERE title ILIKE '%data%'         -- PostgreSQL case-insensitive pattern
WHERE title LIKE 'SQL%'            -- case-sensitive; starts with SQL
```

With `LIKE`, `%` matches zero or more characters and `_` matches exactly one. `ILIKE` is PostgreSQL-specific and ignores letter case. `IN` is shorthand for several equality alternatives.

### `NULL` needs its own test

An unknown value is not equal to anything, including another `NULL`. This will **not** find the missing notes:

```sql
-- Incorrect for missing values:
WHERE notes = NULL
```

Use:

```sql
SELECT title, notes
FROM public.events
WHERE notes IS NULL
ORDER BY title;
```

Use `IS NOT NULL` to keep rows with notes. In a `WHERE` clause, a condition that evaluates to unknown does not keep the row. For example, `notes <> 'Bring a draft poster'` also excludes rows whose `notes` are `NULL`. This is a frequent source of surprising results.

### Choose, rename, compute, and sort

```sql
SELECT title AS event,
       capacity AS seats,
       capacity - 5 AS seats_after_five_signups,
       fee * 2 AS cost_for_two
FROM public.events
WHERE is_open = true
ORDER BY event_date, title;
```

An expression computes an output value; it does not change stored data. `AS` labels an output column. The alias is a name for the result, not a new table column. Arithmetic includes `+`, `-`, `*`, and `/`; use parentheses to show intended order. Integer division can differ from decimal division, so use an explicit decimal when a fractional result matters (`capacity / 2.0`).

```sql
SELECT DISTINCT category
FROM public.events
ORDER BY category;
```

`DISTINCT` removes duplicate *result rows*. It does not make values unique in the stored table; a `UNIQUE` constraint handles that rule.

### A few functions worth knowing now

Functions transform values in each row:

```sql
SELECT title,
       upper(category) AS category_label,
       length(title) AS title_characters,
       coalesce(notes, 'No note') AS display_note
FROM public.events
ORDER BY event_id;
```

`upper` changes case in the result, `length` counts characters, and `coalesce` displays a substitute when `notes` is `NULL`. These expressions do not update the table. The `date` type already supports comparisons such as `event_date >= '2026-10-01'`.

## 5. Change rows safely

An `UPDATE` changes existing rows. A `DELETE` removes them. Before either command, run a `SELECT` with the **same `WHERE` condition** and verify the target IDs.

```sql
-- Step 1: preview the exact target.
SELECT event_id, title, capacity
FROM public.events
WHERE event_id = 2;

-- Step 2: only if the preview is correct, change it.
UPDATE public.events
SET capacity = 65
WHERE event_id = 2
RETURNING event_id, title, capacity;
```

`RETURNING` displays the affected row in PostgreSQL. The condition `event_id = 2` selects one row only because `event_id` is the primary key. Without `WHERE`, **every row** would be updated.

```sql
-- Preview first.
SELECT event_id, title
FROM public.events
WHERE event_id = 6;

-- Delete only the checked row.
DELETE FROM public.events
WHERE event_id = 6
RETURNING event_id, title;
```

The lab uses a practice row specifically for deletion. Do not delete one of the supplied core rows unless the instructor asks you to. A successful `DELETE` cannot be assumed reversible from the SQL Editor; rerunning a setup script can also erase work if it drops tables. Work in your own course project and read the exact statement before selecting **Run**.

## 6. Read errors as clues

| Message or result | Likely cause | First check |
| --- | --- | --- |
| `relation ... does not exist` | Table was not created or its name is misspelled. | Did the setup run in the correct project? Is it `public.events`? |
| `duplicate key value violates unique constraint` | A primary key or `UNIQUE` value repeats. | Did you run an `INSERT` twice? Is the club name already present? |
| `violates foreign key constraint` | The referenced club ID is absent. | Inspect `public.clubs` and use an existing ID. |
| `violates check constraint` | A value breaks a stated rule. | Check capacity, fee, or founding year. |
| `null value ... violates not-null constraint` | A required value was omitted or set to `NULL`. | Look at the table definition. |
| Empty result | The query ran, but no row met the filter. | Check exact spelling, case, dates, and `NULL` tests. |

**Quick self-check:** Can you explain why `WHERE fee = 0` finds free events, while `WHERE notes = NULL` does not find missing notes? Can you point to the clause that controls row order? Can you preview exactly which rows an `UPDATE` would affect?

## 7. What comes next

Module 5 gives us reliable tables and one-table questions. Module 6 will ask questions that require information from multiple tables (joins), summaries over groups (aggregates with `GROUP BY`), filters on those summaries (`HAVING`), and nested questions (subqueries). You only need to recognize those names for now.

For changing assignment instructions, submission rules, and due dates, follow **Brightspace**. For syntax while practicing, use the [SQL Quick Reference](SQL-Quick-Reference.md); for the class sequence and complete sample data, use the **Module 5 SQL Live Lab** provided with the class materials.
