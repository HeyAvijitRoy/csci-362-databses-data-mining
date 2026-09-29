# CSCI 362 — Module 5 Database Setup

**PostgreSQL + Supabase**

This setup prepares the database that we will use for the remaining Module 5 SQL exercises.

During Lesson 5A, we created tables and experimented with SQL together. Because everyone may have completed slightly different parts of the live exercise, we now need the class to begin Lesson 5B with the **same tables and the same sample data**.

You will use the provided:

[Module 5 Reset and Seed](Module-5-Reset-and-Seed.sql)

---

## What this setup will do

The script will:

1. Remove the existing `events` table, if it exists.
2. Remove the existing `clubs` table, if it exists.
3. Recreate both tables with the required columns and constraints.
4. Create the relationship between `events` and `clubs`.
5. Insert 6 fictional campus clubs.
6. Insert 24 fictional events.
7. Provide a consistent dataset for filtering, sorting, updating, deleting, and other SQL practice.

After the setup is complete, everyone should have the same starting database.

---

## Important: this resets your Module 5 practice data

The setup intentionally deletes the current:

- `public.events`
- `public.clubs`

tables and recreates them.

Any data currently stored in those two tables will be removed.

This is expected for this classroom exercise.

### Run this only in your CSCI 362 Supabase practice project.

Do not use this script in another database or in a project containing data you need to preserve.

---

## Why are we resetting the database?

During Lesson 5A, the goal was to learn how SQL statements work.

You may have:

- created the tables at different times,
- inserted only some of the example rows,
- changed values during practice,
- deleted rows,
- or received different generated IDs.

That was fine during the live lesson.

For Lesson 5B, however, we will run queries together and compare results.

A common starting dataset means:

> same SQL + same starting data = comparable results

---

# How to run the setup

## Step 1 — Open your Supabase project

1. Sign in to Supabase.
2. Open the project you are using for CSCI 362.
3. Open **SQL Editor**.

Make sure you are working in the correct project before continuing.

---

## Step 2 — Open the setup SQL file

Open:

[Module 5 Reset and Seed](Module-5-Reset-and-Seed.sql)

from the CSCI 362 course repository.

Copy the **entire SQL script**.

Do not copy only the INSERT statements or only the CREATE TABLE statements.

---

## Step 3 — Create a new SQL query

In Supabase:

1. Select **New Query**.
2. Paste the complete setup script.
3. Read the first few statements before running it.
4. Confirm that the script refers only to:

```text
public.events
public.clubs
```

---

## Step 4 — Run the complete script once

Select **Run**.

The script is designed to reset and rebuild the two Module 5 tables.

Do not repeatedly run individual sections of the script.

If the complete script succeeds, continue to the verification section below.

If an unexpected error appears, stop and read the error message before changing anything.

---

# What tables will be created?

## `clubs`

Each row represents one campus club.

Important columns include:

| Column | Purpose |
|---|---|
| `club_id` | Automatically generated primary key |
| `club_name` | Required and unique club name |
| `founded_year` | Optional founding year |

---

## `events`

Each row represents one event.

Important columns include:

| Column | Purpose |
|---|---|
| `event_id` | Automatically generated primary key |
| `club_id` | Foreign key identifying the club |
| `title` | Event title |
| `category` | Event category |
| `event_date` | Event date |
| `capacity` | Maximum capacity |
| `fee` | Event fee |
| `is_open` | Whether registration is open |
| `notes` | Optional notes |

The relationship is:

```text
CLUBS
  club_id
     ↑
     │
     │ foreign key
     │
EVENTS
  club_id
```

One club can therefore appear in many event rows.

---

# Verify your setup

After running the script, run:

```sql
SELECT club_id, club_name, founded_year
FROM public.clubs
ORDER BY club_id;
```

You should see **6 clubs**.

The generated IDs should begin at `1`.

Then run:

```sql
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
```

You should see **24 events**.

The generated event IDs should run from `1` through `24`.

---

## Optional row-count check

You may also run:

```sql
SELECT COUNT(*) AS club_count
FROM public.clubs;

SELECT COUNT(*) AS event_count
FROM public.events;
```

Expected results:

```text
club_count  = 6
event_count = 24
```

`COUNT()` will be studied more formally later. Here we are only using it as a setup check.

---

# Before Lesson 5B

Your database is ready when:

- `clubs` contains 6 rows,
- `events` contains 24 rows,
- the event IDs begin at 1,
- and the verification queries run without errors.

Once your setup is correct, **do not run the reset script again during Lesson 5B**.

Lesson 5B intentionally changes the database through `INSERT`, `UPDATE`, and `DELETE`.

Running the reset script again would erase those changes and return the database to its original seeded state.

---

# If something goes wrong

Do not repeatedly rerun random sections of the setup script.

Instead:

1. Read the PostgreSQL error message.
2. Identify which statement failed.
3. Compare your project and query with the setup instructions.
4. Ask for help if the reason is unclear.

SQL error messages are part of working with a database. The goal is to understand what the DBMS is reporting rather than immediately removing constraints or changing data at random.

---

## Data used in this lab

All clubs, events, names, dates, and values in this dataset are fictional and are provided only for classroom practice.

Do not place real student information, passwords, API keys, connection strings, or other sensitive information into the course database.
