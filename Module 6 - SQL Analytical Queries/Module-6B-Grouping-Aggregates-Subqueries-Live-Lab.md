# CSCI 362 — Lesson 6B SQL Live Lab

## Grouping, Aggregate Functions, HAVING, and Subqueries

**PostgreSQL + Supabase**

**Released after class for review and practice.**

### Class pattern

**Predict → Run → Inspect → Explain → Modify**

Keep the [Module 6 SQL Quick Reference](Module-6-SQL-Quick-Reference.md) open beside the SQL Editor.

---

# Before we begin

We continue using the [Module 5 database](../Module%205%20-%20SQL%20Labs/README.md). Start from the same reset state used in Lesson 6A:

```text
public.clubs  = 6 rows
public.events = 24 rows
```

If your database changed after the previous class and the instructor asks you to reset, run [Module 5 Reset and Seed](../Module%205%20-%20SQL%20Labs/Module-5-Reset-and-Seed.sql) once, then verify with [Module 6 Database Verification](Module-6-Database-Verification.sql).

Today's shift is important:

In Lesson 6A, one result row usually represented one event joined with its club.

Today, one result row may instead represent:

```text
one entire group of events
```

For example:

```text
one row for Data Club
one row for Robotics Club
one row for Arts Collective
```

That change in the meaning of a result row is what `GROUP BY` does.

---

# 1 — From detail rows to questions about many rows

This query returns detail rows:

```sql
SELECT
    event_id,
    title,
    capacity
FROM public.events
ORDER BY event_id;
```

One result row represents:

> one event.

But suppose the question is:

> How many events are stored?

We do not need 24 detail rows.

We need one summary value.

That is what an aggregate function does.

---

# 2 — COUNT: collapse many rows into one answer

Run:

```sql
SELECT COUNT(*) AS event_count
FROM public.events;
```

Expected:

```text
event_count = 24
```

`COUNT(*)` counts rows.

Notice what happened:

```text
24 source rows
      ↓
   COUNT(*)
      ↓
1 result row
```

The rows were not deleted or changed.

The query summarized them.

---

# 3 — Other aggregate functions

Common aggregate functions include:

```text
COUNT  number of rows or non-NULL values
SUM    total
AVG    arithmetic mean
MIN    smallest value
MAX    largest value
```

Run:

```sql
SELECT
    COUNT(*) AS event_count,
    SUM(capacity) AS total_capacity,
    ROUND(AVG(capacity), 2) AS average_capacity,
    MIN(capacity) AS smallest_capacity,
    MAX(capacity) AS largest_capacity
FROM public.events;
```

Expected from the reset data:

```text
event_count       = 24
total_capacity    = 1081
average_capacity  = 45.04
smallest_capacity = 10
largest_capacity  = 120
```

The query reads all 24 event rows but returns one summary row.

---

# 4 — Analogy: a pile of receipts

Imagine 24 receipts spread across a desk.

A detail query lets you inspect the receipts one by one.

An aggregate query asks something about the whole pile:

```text
How many receipts?
What is the total amount?
What is the average?
What is the largest value?
```

Without `GROUP BY`, SQL treats the qualifying rows as one big pile.

With `GROUP BY`, we first sort the receipts into labeled piles and then calculate within each pile.

That is the mental model for the rest of the lesson.

---

# 5 — COUNT(*) versus COUNT(column)

`COUNT(*)` counts rows.

`COUNT(column)` counts rows where that particular column is **not NULL**.

Run:

```sql
SELECT
    COUNT(*) AS all_events,
    COUNT(notes) AS events_with_notes
FROM public.events;
```

Expected:

```text
all_events       = 24
events_with_notes = 12
```

Why?

Half of the seeded events have a non-NULL note; the others have `NULL` in `notes`.

This difference matters later when outer joins produce `NULL` values.

---

# 6 — GROUP BY: create one group per category

Run:

```sql
SELECT
    category,
    COUNT(*) AS event_count
FROM public.events
GROUP BY category
ORDER BY event_count DESC, category;
```

Expected category counts:

```text
Workshop     8
Competition  3
Seminar      3
Showcase     3
Social       3
Temporary    3
Demo         1
```

## Read the query in English

```sql
GROUP BY category
```

means:

> Put rows with the same category value into the same group.

Then:

```sql
COUNT(*)
```

is calculated separately inside each group.

One result row now represents:

> one category group.

---

# 7 — The envelope analogy

Imagine writing each event on an index card.

Then place the cards into envelopes labeled:

```text
Workshop
Seminar
Showcase
Competition
Social
Demo
Temporary
```

`GROUP BY category` creates those envelopes.

`COUNT(*)` asks:

> How many cards are inside each envelope?

`AVG(capacity)` asks:

> What is the average capacity of the cards in this envelope?

Use this mental model to understand `GROUP BY` before memorizing its syntax.

---

# 8 — Several aggregates per group

Run:

```sql
SELECT
    category,
    COUNT(*) AS event_count,
    ROUND(AVG(capacity), 2) AS average_capacity,
    MIN(fee) AS minimum_fee,
    MAX(fee) AS maximum_fee
FROM public.events
GROUP BY category
ORDER BY category;
```

Each result row still represents one category.

The additional expressions simply calculate more information about that same group.

---

# 9 — The GROUP BY rule behind a common error

Consider:

```sql
SELECT
    category,
    title,
    COUNT(*)
FROM public.events
GROUP BY category;
```

PostgreSQL rejects this.

Why?

Inside the `Workshop` group there are eight different event titles.

SQL knows what to do with:

```text
category  → one grouping value
COUNT(*)  → one aggregate result
```

but what single value should it display for:

```text
title
```

There is no one correct title for the entire Workshop group.

## Practical rule

When using `GROUP BY`, each selected expression should normally be either:

1. part of the grouping key; or
2. the result of an aggregate function.

---

# 10 — GROUP BY after JOIN

Now combine both lessons.

Question:

> How many events does each club have?

The readable club name is in `clubs`.

The event rows are in `events`.

So we first join the rows, then group them.

Run:

```sql
SELECT
    c.club_id,
    c.club_name,
    COUNT(e.event_id) AS event_count
FROM public.clubs AS c
INNER JOIN public.events AS e
    ON e.club_id = c.club_id
GROUP BY
    c.club_id,
    c.club_name
ORDER BY event_count DESC, c.club_name;
```

Expected counts:

```text
Data Club          7
Arts Collective    4
Robotics Club      4
Cybersecurity Club 3
Debate Society     3
Photography Club   3
```

The conceptual sequence is:

```text
join related rows
      ↓
group rows by club
      ↓
count rows in each club group
```

---

# 11 — Why group by club_id and club_name?

In PostgreSQL, grouping rules can sometimes use functional dependencies around primary keys, but for this course we will usually make the grouping logic explicit:

```sql
GROUP BY
    c.club_id,
    c.club_name
```

That tells the reader exactly what identifies one club group in the result.

Clear SQL is more important than showing off the shortest legal form.

---

# 12 — WHERE filters rows before grouping

Question:

> How many **open** events does each club currently have in the reset dataset?

Run:

```sql
SELECT
    c.club_name,
    COUNT(e.event_id) AS open_event_count
FROM public.clubs AS c
INNER JOIN public.events AS e
    ON e.club_id = c.club_id
WHERE e.is_open = true
GROUP BY c.club_id, c.club_name
ORDER BY open_event_count DESC, c.club_name;
```

The order of thinking is:

```text
JOIN
 ↓
WHERE removes closed event rows
 ↓
GROUP BY forms club groups from the remaining rows
 ↓
COUNT summarizes each group
```

The filter acts on individual event rows **before** the groups are summarized.

---

# 13 — HAVING filters groups after aggregation

Now ask:

> Which clubs have at least four events?

Run:

```sql
SELECT
    c.club_name,
    COUNT(e.event_id) AS event_count
FROM public.clubs AS c
INNER JOIN public.events AS e
    ON e.club_id = c.club_id
GROUP BY c.club_id, c.club_name
HAVING COUNT(e.event_id) >= 4
ORDER BY event_count DESC, c.club_name;
```

Expected:

```text
Data Club       7
Arts Collective 4
Robotics Club   4
```

`HAVING` is evaluated against groups.

The condition:

```sql
COUNT(e.event_id) >= 4
```

cannot be decided from one event row. It is only meaningful after the club's rows have been grouped and counted.

---

# 14 — WHERE versus HAVING

A useful analogy is a restaurant.

`WHERE` works at the door:

> Which individual people may enter?

`GROUP BY` seats the remaining people at tables.

`HAVING` then looks at complete tables:

> Keep only tables with at least four people.

In SQL:

```text
WHERE  → filters rows
HAVING → filters groups
```

Do not reduce this to “WHERE comes before HAVING.”

The important difference is **what kind of thing is being filtered**.

---

# 15 — Use WHERE and HAVING together

Question:

> Among open events only, which clubs have at least three open events?

Run:

```sql
SELECT
    c.club_name,
    COUNT(e.event_id) AS open_event_count
FROM public.clubs AS c
INNER JOIN public.events AS e
    ON e.club_id = c.club_id
WHERE e.is_open = true
GROUP BY c.club_id, c.club_name
HAVING COUNT(e.event_id) >= 3
ORDER BY open_event_count DESC, c.club_name;
```

Read it in the correct conceptual order:

```text
1. JOIN the related rows.
2. WHERE keeps only open event rows.
3. GROUP BY forms one group per club.
4. COUNT summarizes each group.
5. HAVING removes groups with fewer than three remaining events.
6. ORDER BY displays the final result.
```

---

# 16 — LEFT JOIN + GROUP BY: preserve zero-count groups

This pattern is extremely important.

Suppose we ask:

> How many Workshop events does each club have, including clubs with zero Workshops?

Run:

```sql
SELECT
    c.club_name,
    COUNT(e.event_id) AS workshop_count
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id
   AND e.category = 'Workshop'
GROUP BY c.club_id, c.club_name
ORDER BY workshop_count DESC, c.club_name;
```

Expected:

```text
Data Club          4
Arts Collective    1
Cybersecurity Club 1
Photography Club   1
Robotics Club      1
Debate Society     0
```

This is why we used:

```sql
COUNT(e.event_id)
```

rather than:

```sql
COUNT(*)
```

For Debate Society, the `LEFT JOIN` still creates one preserved output row with `NULL` event columns.

`COUNT(*)` would count that preserved row as 1.

`COUNT(e.event_id)` ignores the `NULL` event ID and correctly reports 0 matching Workshop events.

---

# 17 — COUNT(*) versus COUNT(right_table.key) after a LEFT JOIN

Run:

```sql
SELECT
    c.club_name,
    COUNT(*) AS joined_rows,
    COUNT(e.event_id) AS workshop_matches
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id
   AND e.category = 'Workshop'
GROUP BY c.club_id, c.club_name
ORDER BY c.club_name;
```

Look at Debate Society.

You should see:

```text
joined_rows      = 1
workshop_matches = 0
```

Both numbers are correct.

They are counting different things.

This is a classic example of why an aggregate query must be interpreted, not merely executed.

---

# 18 — Aggregates can answer analytical questions directly

Question:

> What is the average capacity of all events?

```sql
SELECT ROUND(AVG(capacity), 2) AS average_capacity
FROM public.events;
```

Expected:

```text
45.04
```

Now ask:

> Which events have capacity above that average?

We could run the first query, remember `45.04`, and manually paste the number into another query.

But that would hard-code today's answer.

A subquery lets SQL calculate the answer and use it immediately.

---

# 19 — Scalar subquery: one smaller question returns one value

Run:

```sql
SELECT
    event_id,
    title,
    capacity
FROM public.events
WHERE capacity > (
    SELECT AVG(capacity)
    FROM public.events
)
ORDER BY capacity DESC, title;
```

Expected result count:

```text
9 rows
```

Read the inner query first:

```sql
SELECT AVG(capacity)
FROM public.events
```

It returns one value.

Then the outer query becomes conceptually:

```text
Show events whose capacity is greater than that value.
```

## Analogy

A subquery is a smaller question whose answer is handed to a larger question.

---

# 20 — How to debug a subquery

When a subquery is confusing, run it by itself first.

Start with:

```sql
SELECT AVG(capacity)
FROM public.events;
```

Confirm the result.

Then put it back inside:

```sql
WHERE capacity > (...)
```

This follows the same habit we have used throughout the course:

> inspect smaller pieces before combining them.

---

# 21 — IN subquery: one smaller question returns a set of values

Question:

> Which clubs have at least one paid event?

The inner question is:

> Which `club_id` values appear on paid events?

Run the inner query first:

```sql
SELECT DISTINCT club_id
FROM public.events
WHERE fee > 0
ORDER BY club_id;
```

Expected IDs:

```text
1, 2, 3, 4, 6
```

Now let that set feed another query:

```sql
SELECT
    club_id,
    club_name
FROM public.clubs
WHERE club_id IN (
    SELECT DISTINCT club_id
    FROM public.events
    WHERE fee > 0
)
ORDER BY club_id;
```

Expected result count:

```text
5 clubs
```

`Debate Society` is not included because all of its seeded events have a fee of 0.

---

# 22 — EXISTS: ask whether at least one matching row exists

Question:

> Which clubs have at least one Workshop?

Run:

```sql
SELECT
    c.club_id,
    c.club_name
FROM public.clubs AS c
WHERE EXISTS (
    SELECT 1
    FROM public.events AS e
    WHERE e.club_id = c.club_id
      AND e.category = 'Workshop'
)
ORDER BY c.club_id;
```

The inner query is **correlated** with the current club row through:

```sql
e.club_id = c.club_id
```

Conceptually, SQL asks for each club:

> Does at least one matching Workshop event exist?

The exact value in:

```sql
SELECT 1
```

is not important here. `EXISTS` cares whether a qualifying row exists.

Expected:

```text
5 clubs
```

Debate Society has no Workshop.

---

# 23 — NOT EXISTS: ask whether no matching row exists

Now invert the previous question:

> Which clubs have no Workshop?

```sql
SELECT
    c.club_id,
    c.club_name
FROM public.clubs AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM public.events AS e
    WHERE e.club_id = c.club_id
      AND e.category = 'Workshop'
)
ORDER BY c.club_id;
```

Expected:

```text
Debate Society
```

This answers the same information requirement we solved in Lesson 6A with:

```text
LEFT JOIN + IS NULL
```

Different SQL patterns can sometimes answer the same question.

The goal is not to collect syntax tricks. The goal is to recognize the information problem.

---

# 24 — JOIN or subquery?

You may wonder:

> Should I use a JOIN or a subquery?

There is not one universal answer.

A useful starting guideline is:

### Use a JOIN when:

- you need columns from multiple related tables in the final result;
- the relationship itself is central to the output;
- you are combining detail rows before grouping.

### Consider a subquery when:

- one query needs a value or set produced by another query;
- the question naturally sounds like “greater than the average,” “in the set of,” or “exists/does not exist.”

Many problems can be written more than one way.

Readable, correct SQL is the priority.

---

# 25 — Your turn: aggregate queries

For each task, first state what one result row should represent.

## Task A — Category summary

For each category, return:

```text
category
number of events
average capacity
```

Sort from the largest event count to the smallest.

---

## Task B — Paid-event summary by club

Return one row per club that has at least one paid event.

Show:

```text
club_name
paid_event_count
average_paid_fee
```

Only event rows with `fee > 0` should enter the groups.

---

## Task C — Clubs with at least three open events

Return:

```text
club_name
open_event_count
```

This should require both `WHERE` and `HAVING`.

Explain what each clause filters.

---

## Task D — Every club and its Seminar count

Show all six clubs, including clubs with zero Seminars.

Return:

```text
club_name
seminar_count
```

Hint: preserve the club side and count a right-table key.

---

# 26 — Your turn: subqueries

## Task E — Above-average fee

Find every event whose fee is greater than the average event fee.

Do not manually type the average into the outer query.

---

## Task F — Clubs with Showcase events

Use `IN` or `EXISTS` to list clubs that have at least one Showcase event.

Do not use a join for this version.

---

## Task G — Clubs with no Social events

Use `NOT EXISTS` to return clubs that have no Social event.

---

# 27 — Integrated analytical challenge

Answer:

> Among events that are currently open, which clubs have at least three events, and what is the average capacity of those open events?

Return:

```text
club_name
open_event_count
average_open_capacity
```

Round the average capacity to two decimal places.

Sort by event count descending, then club name.

Before running the query, label each part of your planned SQL:

```text
JOIN      → connect club names to event rows
WHERE     → decide which event rows enter the analysis
GROUP BY  → decide what one result row represents
COUNT/AVG → summarize each group
HAVING    → decide which completed groups remain
ORDER BY  → present the final result
```

---

# 28 — Common mistakes to diagnose

## Mistake 1 — Using WHERE with an aggregate

Incorrect idea:

```sql
WHERE COUNT(*) >= 4
```

`WHERE` is filtering individual source rows before grouping. A count does not exist yet at that stage.

Use:

```sql
HAVING COUNT(*) >= 4
```

for a condition on completed groups.

---

## Mistake 2 — Selecting a detail column from a grouped query

If you group by club, asking for one arbitrary event title usually makes no sense.

Ask:

> What should one result row represent?

If the answer is “one club,” every selected non-aggregate value should describe that club group.

---

## Mistake 3 — Counting the preserved row instead of matches

After a `LEFT JOIN`, this:

```sql
COUNT(*)
```

can count the preserved left-side row even when no right-side match exists.

When you mean:

> How many matching events?

prefer:

```sql
COUNT(e.event_id)
```

because `COUNT(column)` ignores `NULL`.

---

## Mistake 4 — Treating GROUP BY as sorting

`GROUP BY` creates groups for aggregation.

`ORDER BY` controls result ordering.

Those are different jobs.

---

## Mistake 5 — Writing a subquery before understanding its result shape

Before embedding a subquery, ask:

```text
Does it return one value?
Several values?
Rows that only need to exist?
```

That determines whether the outer query needs a scalar comparison, `IN`, or `EXISTS`.

---

# 29 — End-of-module checkpoint

You should now be able to explain the following pipeline:

```text
normalized tables
      ↓
JOIN related rows
      ↓
WHERE filters detail rows
      ↓
GROUP BY forms analytical groups
      ↓
aggregate functions summarize groups
      ↓
HAVING filters completed groups
      ↓
subqueries allow one query result to guide another
```

That pipeline is the foundation for much of the analytical SQL you will use later.

---

# Final reflection

In Module 5, most questions could be answered from one table.

Module 6 changes the scale of the questions.

We are now asking things such as:

> Which club owns this event?

> Which clubs are missing a type of event?

> How many events does each club have?

> Which groups exceed a threshold?

> Which rows are above an average calculated from the same database?

This is where SQL stops feeling like a table viewer and starts becoming an analytical language.
