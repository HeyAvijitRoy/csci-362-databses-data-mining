# CSCI 362 — Lesson 5B SQL Live Lab

**Querying and Safely Modifying Data with PostgreSQL + Supabase**

### Class pattern

**Predict → Run → Inspect → Explain → Modify**

Keep the [SQL Vocabulary and Fundamentals Guide](../SQL-Vocabulary-Guide.md) and [SQL Quick Reference](../SQL-Quick-Reference.md) open beside this page.

---

# Before we begin

You must complete:

[Module 5 Database Setup](Module-5-Database-Setup.md)

and run:

[Module 5 Reset and Seed](Module-5-Reset-and-Seed.sql)

before beginning this lab.

Your starting database should contain:

```text
6 clubs
24 events
```

Do not rerun the reset script after beginning Lesson 5B.

Today we will intentionally change the database.

---

# Why are SQL keywords capitalized?

PostgreSQL accepts SQL keywords such as `SELECT`, `FROM`, and `WHERE` in uppercase or lowercase. `SELECT title FROM public.events;` and `select title from public.events;` mean the same thing. We capitalize keywords here to make the commands easy to distinguish from lowercase table and column names. You may type keywords in lowercase if you prefer.

Function names used here also work in either case: `COALESCE` and `coalesce` call the same PostgreSQL function.

This convention does **not** mean every letter in a query is interchangeable. Text inside single quotes is data: `'Workshop'` is the category stored in our rows, and an ordinary `=` text comparison can distinguish it from `'workshop'`. Keep the spelling and capitalization of data values as intended.

---

# Part 1 — Inspect the starting data

`SELECT` asks PostgreSQL to return a result. `*` asks for every column, `FROM public.events` identifies the table, and `ORDER BY event_id` displays rows in ID order. This query only reads data; it does not change the table. Start by recognizing what each row and column represents.

Run:

```sql
SELECT *
FROM public.events
ORDER BY event_id;
```

Before moving on, look at the data.

Identify examples of:

- a free event,
- a paid event,
- an open event,
- a closed event,
- an event with notes,
- an event whose notes are `NULL`,
- two events in the same category.

The goal is not just to run SQL.

You should understand what the rows represent before querying them.

---

# Part 2 — Choose columns instead of always using `*`

Listing `title`, `category`, and `event_date` asks for only those columns in the result. This is called choosing or projecting columns. `ORDER BY event_date` then sorts the result by date, earliest first unless you specify another direction. The other stored columns remain in the table.

Run:

```sql
SELECT
    title,
    category,
    event_date
FROM public.events
ORDER BY event_date;
```

### Explain

What changed compared with:

```sql
SELECT *
FROM public.events;
```

Did the database lose any columns?

No.

`SELECT` determines what appears in the query result. It does not remove columns from the stored table.

---

# Part 3 — Filter rows with `WHERE`

`WHERE` keeps only rows that satisfy a condition. Here `category = 'Workshop'` compares the stored category with one text value. The query does not test whether registration is open, so both open and closed workshops can appear.

Before running the query, predict what type of rows should appear.

```sql
SELECT
    title,
    category,
    event_date
FROM public.events
WHERE category = 'Workshop'
ORDER BY event_date;
```

### Question

Does this return only open workshops?

Look carefully at the result.

The condition says:

```sql
category = 'Workshop'
```

It says nothing about `is_open`.

---

## Add another condition

`AND` requires both conditions to be true for the same row. `is_open` is a boolean column, so `is_open = true` keeps events currently marked open. `DESC` sorts the remaining capacities from largest to smallest.

```sql
SELECT
    title,
    category,
    capacity,
    is_open
FROM public.events
WHERE category = 'Workshop'
  AND is_open = true
ORDER BY capacity DESC;
```

### Explain

Why are fewer rows returned now?

---

# Part 4 — Combine conditions

`>=` means “greater than or equal to,” while `>` means “greater than.” Each condition joined with `AND` narrows the set of matching rows. In the second query, `ORDER BY fee DESC, capacity DESC` sorts by fee first; capacity breaks ties between equal fees.

Run:

```sql
SELECT
    title,
    capacity,
    fee
FROM public.events
WHERE capacity >= 30
  AND is_open = true
ORDER BY capacity DESC;
```

Then modify the condition.

Try:

```sql
SELECT
    title,
    capacity,
    fee
FROM public.events
WHERE capacity >= 30
  AND fee > 0
  AND is_open = true
ORDER BY fee DESC, capacity DESC;
```

### Predict first

Which condition removes the most rows?

---

# Part 5 — Search several possible values with `IN`

`IN` tests whether one value is in a list. `category IN ('Workshop', 'Seminar')` keeps either category; it is a compact way to combine those two comparisons with `OR`. The categories in quotes are data values, not SQL keywords.

Instead of writing:

```sql
WHERE category = 'Workshop'
   OR category = 'Seminar'
```

we can write:

```sql
SELECT
    title,
    category,
    event_date
FROM public.events
WHERE category IN ('Workshop', 'Seminar')
ORDER BY category, event_date;
```

### Your turn

Modify the query to return:

```text
Workshop
Showcase
Competition
```

events.

---

# Part 6 — Search a range with `BETWEEN`

`fee BETWEEN 2 AND 5` keeps fees from 2 through 5, including both endpoints. It has the same boundaries as `fee >= 2 AND fee <= 5`. The `WHERE` clause selects the rows; `ORDER BY fee, title` then displays them by fee, using title to break ties.

Run:

```sql
SELECT
    title,
    fee
FROM public.events
WHERE fee BETWEEN 2 AND 5
ORDER BY fee, title;
```

`BETWEEN` includes both endpoints.

Therefore:

```text
2
and
5
```

are part of the range.

---

## Try a date range

The same operator can compare dates. `event_date` is a `date` column, so PostgreSQL can compare actual calendar dates rather than arbitrary text descriptions. The quoted values use the year-month-day format.

```sql
SELECT
    title,
    event_date
FROM public.events
WHERE event_date BETWEEN '2026-10-15' AND '2026-10-23'
ORDER BY event_date;
```

### Question

Why is a date stored as a date more useful than storing something like:

```text
October 15th
```

as arbitrary text?

---

# Part 7 — Search text with `ILIKE`

PostgreSQL provides `ILIKE` for case-insensitive pattern matching. It compares text with a pattern, so `data`, `Data`, and `DATA` can all match. `%` stands for any number of characters, including zero; a `%` on each side finds the word anywhere in the title. This is different from the exact comparison with `=` in Part 3.

Run:

```sql
SELECT
    title,
    category
FROM public.events
WHERE title ILIKE '%data%'
ORDER BY title;
```

Here:

```text
%
```

means:

> zero or more characters

Therefore:

```text
%data%
```

means that `data` may appear anywhere inside the title.

### Expected observation

Several titles contain `data`, even though capitalization may differ.

---

## Try another search

Find every event whose title contains:

```text
photo
```

---

# Part 8 — Work correctly with `NULL`

`NULL` means a value is missing or unknown. It is not the text `'NULL'` or an empty string. `notes IS NULL` finds rows with missing notes; `notes IS NOT NULL` finds rows that have a value. An `= NULL` comparison does not return true, because SQL cannot treat an unknown value as equal to a known one.

Run:

```sql
SELECT
    event_id,
    title,
    notes
FROM public.events
WHERE notes IS NULL
ORDER BY event_id;
```

Do **not** write:

```sql
WHERE notes = NULL;
```

`NULL` represents the absence of a known value.

It is tested using:

```sql
IS NULL
```

or:

```sql
IS NOT NULL
```

---

## Your turn

Find every event that **does have notes**.

---

# Part 9 — Remove duplicates from query output

Several events share the same category. `SELECT category` therefore shows repeated category names, while `SELECT DISTINCT category` shows each different category once in the result. `DISTINCT` changes the displayed result, not the saved events.

Run:

```sql
SELECT category
FROM public.events
ORDER BY category;
```

You will see categories repeated because many events belong to the same category.

Now run:

```sql
SELECT DISTINCT category
FROM public.events
ORDER BY category;
```

### Explain

Did `DISTINCT` delete duplicate values from the table?

No.

It changed only the query result.

---

# Part 10 — Rename output columns with aliases

`AS` gives a column a temporary name in this query result. For example, `fee AS registration_fee` labels the output column `registration_fee`; it does not rename `fee` in the table. An alias can make results clearer to someone reading them.

Run:

```sql
SELECT
    title AS event,
    event_date AS date,
    fee AS registration_fee
FROM public.events
ORDER BY event_date;
```

Aliases make query output easier to read.

They do not rename the stored table columns.

---

# Part 11 — Expressions can calculate new output

An expression calculates a value from existing columns. `fee * 2` multiplies each row's fee by two, and `AS cost_for_two` labels that calculated output. `WHERE fee > 0` limits the result to paid events. These calculations happen while PostgreSQL builds the result; they do not save a new fee.

Run:

```sql
SELECT
    title,
    fee,
    fee * 2 AS cost_for_two,
    fee * 4 AS cost_for_four
FROM public.events
WHERE fee > 0
ORDER BY fee;
```

### Important

This calculation does **not** update the stored `fee`.

It calculates new values only for the result returned by this query.

---

# Part 12 — Basic functions

Functions take input and return a result. `upper(category)` returns an uppercase version of each category, and `length(title)` returns the number of characters in each title. The parentheses hold the input to the function; `AS` labels the output. Neither function edits the stored text.

Run:

```sql
SELECT
    title,
    upper(category) AS category_label,
    length(title) AS title_characters
FROM public.events
ORDER BY title;
```

Here:

```text
upper()
```

changes how text appears in the result.

```text
length()
```

returns the number of characters.

Neither changes the stored event.

---

# Part 13 — Replace `NULL` for display with `COALESCE`

`COALESCE` returns the first argument that is not `NULL`. In `coalesce(notes, 'No special instructions')`, PostgreSQL shows the stored note when one exists and the fallback text when `notes` is `NULL`. `AS display_note` names this result column. The original `notes` column is included beside it so you can compare the two; no stored value is replaced.

| Stored `notes` | Resulting `display_note` |
| --- | --- |
| `NULL` | `No special instructions` |
| `Bring questions` | `Bring questions` |

Run:

```sql
SELECT
    title,
    notes,
    coalesce(notes, 'No special instructions') AS display_note
FROM public.events
ORDER BY event_id;
```

### Question

Did PostgreSQL replace the stored `NULL` values?

Run this again to check:

```sql
SELECT
    title,
    notes
FROM public.events
WHERE notes IS NULL
ORDER BY event_id;
```

`COALESCE` changed the displayed result, not the stored data.

---

# Part 14 — Insert a new row

We already inserted data in Lesson 5A.

Now we will insert another event while letting PostgreSQL apply defaults. `INSERT INTO public.events` names the target table; the column list names the fields we supply; `VALUES` gives one value for each listed column in the same order. `club_id = 4` refers to the seeded Cybersecurity Club. `RETURNING *` displays the row PostgreSQL actually saved, including its generated ID and any default values.

Run this insert once. Repeating it would add a second event with the same title because this table does not require event titles to be unique.

Run:

```sql
INSERT INTO public.events
    (
        club_id,
        title,
        category,
        event_date,
        capacity
    )
VALUES
    (
        4,
        'Web Security Basics',
        'Workshop',
        '2026-11-06',
        35
    )
RETURNING *;
```

Notice that we did **not** provide:

```text
fee
is_open
notes
```

### Inspect the result

What happened to `fee`?

What happened to `is_open`?

Why is `notes` different?

The table definition provides defaults for:

```text
fee
is_open
```

while `notes` is allowed to remain `NULL`.

---

# Part 15 — Safe UPDATE: preview first

An `UPDATE` changes stored data. `SET capacity = 65` supplies the new value, `WHERE` chooses the target row, and `RETURNING` displays the row after the change. A title is not required to be unique by this table, so first use `SELECT` to confirm that the preview finds exactly one intended event.

Before changing a row, first identify exactly what will be affected.

Suppose we want to increase the capacity of:

```text
Data Poster Night
```

First preview the row:

```sql
SELECT
    event_id,
    title,
    capacity
FROM public.events
WHERE title = 'Data Poster Night';
```

Confirm that you found the intended event.

Now perform the update:

```sql
UPDATE public.events
SET capacity = 65
WHERE title = 'Data Poster Night'
RETURNING
    event_id,
    title,
    capacity;
```

### Checkpoint

Exactly one row should be returned.

---

## Verify independently

```sql
SELECT
    event_id,
    title,
    capacity
FROM public.events
WHERE title = 'Data Poster Night';
```

You should now see:

```text
capacity = 65
```

---

# Part 16 — Update more than one column

One `SET` clause can assign several columns; commas separate the assignments. This example changes both `capacity` and `notes` for the same matching event. Preview first to confirm that `Capture the Flag` identifies exactly one row, then compare the values returned by `UPDATE` with the preview.

Preview:

```sql
SELECT
    event_id,
    title,
    capacity,
    notes
FROM public.events
WHERE title = 'Capture the Flag';
```

Now update two columns:

```sql
UPDATE public.events
SET
    capacity = 60,
    notes = 'Teams of four; arrive 15 minutes early'
WHERE title = 'Capture the Flag'
RETURNING
    event_id,
    title,
    capacity,
    notes;
```

### Explain

One SQL statement can modify more than one attribute of the same row.

---

# Part 17 — One UPDATE can affect many rows

`WHERE` can match several rows. Here every event that is both a `Workshop` and currently open receives the change, including the new workshop from Part 14 if you inserted it. `SET fee = fee + 1` uses each row's current fee and adds one; running this `UPDATE` again would add another dollar.

The preview `SELECT` shows which rows qualify before anything changes. Afterward, `RETURNING` lets you check each affected row and its new fee.

This is important.

`UPDATE` does not automatically mean:

> change one row

The `WHERE` condition determines how many rows qualify.

First preview:

```sql
SELECT
    event_id,
    title,
    fee
FROM public.events
WHERE category = 'Workshop'
  AND is_open = true
ORDER BY event_id;
```

Inspect the result carefully.

Now suppose every currently open workshop receives a $1 materials fee.

Run:

```sql
UPDATE public.events
SET fee = fee + 1
WHERE category = 'Workshop'
  AND is_open = true
RETURNING
    event_id,
    title,
    fee;
```

### Question

Why did multiple rows change?

Because multiple rows satisfied the same `WHERE` condition.

---

# Part 18 — Why UPDATE without WHERE is dangerous

An `UPDATE` without `WHERE` applies to every row in the table. The statement below would replace every event fee with zero, including paid events. Read and predict its effect, but do not execute it.

Consider:

```sql
UPDATE public.events
SET fee = 0;
```

Do **not** run it.

### Predict

Which rows would be updated?

Answer:

> Every row in the table.

There is no `WHERE` condition limiting the operation.

This is why we use the habit:

```text
Preview → Verify → Modify → Verify again
```

---

# Part 19 — Safe DELETE: preview first

A `DELETE` removes stored rows. `DELETE FROM public.events` names the table, while `WHERE` limits which rows are removed. Preview with `SELECT` first; then `RETURNING` shows the row actually deleted. Without the preview, a mistaken condition could remove the wrong event.

Our seed data includes rows intentionally created for deletion practice.

Preview:

```sql
SELECT
    event_id,
    title,
    category
FROM public.events
WHERE title = 'Temporary SQL Test Event';
```

Confirm that this is a disposable practice row.

Then:

```sql
DELETE FROM public.events
WHERE title = 'Temporary SQL Test Event'
RETURNING
    event_id,
    title;
```

Exactly one row should be removed.

---

# Part 20 — DELETE can also affect several rows

The same `DELETE` statement can remove multiple matching rows. After Part 19, two seeded events still have `category = 'Temporary'`. Preview that category first, then compare the returned rows with the preview. The category condition selects both rows; it does not mean “delete only one.”

Preview the remaining temporary rows:

```sql
SELECT
    event_id,
    title,
    category
FROM public.events
WHERE category = 'Temporary'
ORDER BY event_id;
```

After deleting the first temporary event, two rows should remain.

Now remove them:

```sql
DELETE FROM public.events
WHERE category = 'Temporary'
RETURNING
    event_id,
    title;
```

### Explain

Why were multiple rows removed?

The `WHERE` condition matched multiple rows.

---

# Part 21 — Why DELETE without WHERE is dangerous

`DELETE FROM public.events` without a `WHERE` condition would remove **all** event rows. The table and its columns would remain, but it would contain no events. Predict the effect of this example without running it.

Consider:

```sql
DELETE FROM public.events;
```

Do **not** run it.

### Predict

What would remain?

The table would still exist.

Its rows would not.

Every event row would be deleted.

---

# Part 22 — Let the database reject invalid data

Constraints are rules defined when a table is created. PostgreSQL checks them when we try to insert, update, or delete data. A rejected statement returns an error and does not save the invalid row. In the next examples, the error is the expected learning result.

Predict what should happen **before** running each statement. Run one experiment at a time so you can connect its error to the rule it violated. Do not remove constraints to make these examples succeed.

---

## Experiment 1 — Invalid capacity

The `events` table has `CHECK (capacity > 0)`. A capacity of `0` does not pass that rule, even though the other supplied values are valid. The insert should fail and add no event.

```sql
INSERT INTO public.events
    (
        club_id,
        title,
        category,
        event_date,
        capacity
    )
VALUES
    (
        1,
        'Invalid Capacity Test',
        'Practice',
        '2026-11-20',
        0
    );
```

### Expected

The statement should fail.

Why?

The table contains:

```sql
CHECK (capacity > 0)
```

---

# Part 23 — Invalid foreign key

`events.club_id` is a foreign key referencing `clubs.club_id`. It must name a club that exists. The seed contains club IDs 1 through 6, so `999` has no matching parent row; PostgreSQL should reject this event rather than store a broken relationship.

Try:

```sql
INSERT INTO public.events
    (
        club_id,
        title,
        category,
        event_date,
        capacity
    )
VALUES
    (
        999,
        'Ghost Club Event',
        'Practice',
        '2026-11-20',
        20
    );
```

### Expected

The statement should fail.

There is no:

```text
club_id = 999
```

in `clubs`.

The foreign key protects referential integrity.

---

# Part 24 — Duplicate unique value

`clubs.club_name` has a `UNIQUE` constraint. A second row named `Data Club` would repeat a value already stored in that column, so PostgreSQL should reject the insert. A different `founded_year` does not make the duplicate club name acceptable.

Try:

```sql
INSERT INTO public.clubs
    (
        club_name,
        founded_year
    )
VALUES
    (
        'Data Club',
        2026
    );
```

### Expected

The statement should fail.

Why?

`club_name` was defined as:

```sql
UNIQUE
```

---

# Part 25 — Defaults are different from errors

Omitting a column is allowed when its definition supplies a default or permits `NULL`. This insert provides all required event details, leaves `fee` and `is_open` to their defaults, and leaves optional `notes` as `NULL`. `RETURNING *` shows the complete saved row so you can check the result.

This statement is valid:

```sql
INSERT INTO public.events
    (
        club_id,
        title,
        category,
        event_date,
        capacity
    )
VALUES
    (
        5,
        'Defaults Demonstration',
        'Seminar',
        '2026-11-21',
        30
    )
RETURNING *;
```

We omitted:

```text
fee
is_open
notes
```

The database can still create the row because:

```text
fee     → default 0
is_open → default true
notes   → NULL is allowed
```

---

# Part 26 — Referential integrity also protects DELETE

The foreign key works in both directions: an event cannot refer to a missing club, and a referenced club cannot be removed while those events remain. The seeded Data Club still has events. Its `DELETE` should fail, leaving both the club and its events in place; this relationship has no cascading delete rule.

First inspect Data Club:

```sql
SELECT *
FROM public.clubs
WHERE club_name = 'Data Club';
```

Now consider:

```sql
DELETE FROM public.clubs
WHERE club_name = 'Data Club';
```

### Predict before running

Should PostgreSQL allow it?

Data Club is still referenced by rows in `events`.

Run it and inspect the error.

The foreign key prevents us from accidentally creating event rows whose club no longer exists.

---

# Part 27 — Independent challenge

Now combine the skills from earlier parts without copying a complete solution. Use `INSERT` with an explicit column list, use `RETURNING` to learn the new event's generated ID, and use a filtered, sorted `SELECT` to inspect the club's open events. Before `UPDATE`, preview the new event by its ID so you change exactly that row; verify again afterward.

Now work through the data below.

The Cybersecurity Club announces another event:

```text
Title: Secure Coding Clinic
Category: Workshop
Date: November 8, 2026
Capacity: 30
Fee: $5.00
Registration: Open
Notes: Bring your laptop
```

You know from our seeded data that:

```text
Cybersecurity Club → club_id 4
```

Complete the following tasks.

1. Insert the new event.
2. Use `RETURNING` to inspect it.
3. Write a `SELECT` that retrieves all open events for `club_id = 4`.
4. Sort those events by date.
5. Increase the new event's capacity from 30 to 40.
6. Verify the change with a new `SELECT`.

Do not modify any other event.

---

# Final question

Our last query requires us to remember:

```text
club_id 4 = Cybersecurity Club
```

That works, but it is not ideal.

We currently have:

```text
CLUBS
club_id | club_name
```

and:

```text
EVENTS
event_id | club_id | title | ...
```

What if we want one result containing:

```text
Cybersecurity Club | Secure Coding Clinic
Data Club          | SQL Starter Lab
Robotics Club      | Robot Demo
```

The information exists.

It is simply stored in two different tables.

---

# Coming next — Module 6

In Module 6, we will learn how SQL combines related tables using:

```text
JOIN
```

Instead of manually remembering that:

```text
4 = Cybersecurity Club
```

the database will connect:

```text
events.club_id
```

to:

```text
clubs.club_id
```

and retrieve information from both relations in one query.

That is the next step.
