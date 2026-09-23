# CSCI 362 — Module 5 SQL Quick Reference

**PostgreSQL / Supabase SQL Editor** · [Vocabulary and explanations](SQL-Vocabulary-Guide.md) · [Project setup](SQL-Lab-Readiness-Guide.md)

Use this beside the SQL Editor after you have read the guide. Replace names and values for your question. Run statements in **your own course project** and keep credentials and real personal data out of scripts.

The **Module 5 SQL Live Lab** provided with the class materials contains the complete sample data and the order in which to run setup statements.

## Define and add data

```sql
CREATE TABLE public.example (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE,
    quantity integer NOT NULL CHECK (quantity >= 0),
    active boolean NOT NULL DEFAULT true
);
```

| Need | Pattern |
| --- | --- |
| Whole number | `integer` |
| Variable text | `text` |
| Exact amount | `numeric(6, 2)` |
| Calendar day | `date` |
| True/false | `boolean` |
| Required value | `NOT NULL` |
| Unique row ID | `PRIMARY KEY` |
| No repeated non-null value | `UNIQUE` |
| Valid range | `CHECK (quantity >= 0)` |
| Fill omitted value | `DEFAULT true` |
| Existing parent row required | `club_id integer REFERENCES public.clubs(club_id)` |

```sql
INSERT INTO public.clubs (club_name, founded_year)
VALUES ('Example Club', 2024);
```

Name target columns explicitly. Omit an identity or default column to let PostgreSQL fill it. Text and date literals use **single quotes**; numbers, `true`, `false`, and `NULL` do not.

## Read data

```sql
SELECT title, event_date
FROM public.events
WHERE category = 'Workshop'
ORDER BY event_date ASC, title ASC;
```

| Need | Pattern / meaning |
| --- | --- |
| All columns for inspection | `SELECT * FROM public.events;` |
| Selected columns | `SELECT title, fee FROM public.events;` |
| Filter | `WHERE fee > 0` |
| Both / either conditions | `WHERE is_open = true AND fee = 0` / use `OR` |
| One of several values | `WHERE category IN ('Workshop', 'Showcase')` |
| Inclusive range | `WHERE fee BETWEEN 0 AND 5` |
| Pattern | `WHERE title LIKE 'SQL%'` (`%`: any length; `_`: one character) |
| Case-insensitive pattern | `WHERE title ILIKE '%data%'` (PostgreSQL) |
| Missing / present value | `WHERE notes IS NULL` / `IS NOT NULL` |
| Ascending / descending | `ORDER BY event_date ASC` / `DESC` |
| Unique output values | `SELECT DISTINCT category FROM public.events;` |
| Rename output | `SELECT title AS event FROM public.events;` |
| Compute output | `SELECT fee * 2 AS cost_for_two FROM public.events;` |
| Basic row functions | `upper(category)`, `length(title)`, `coalesce(notes, 'No note')` |

Comparison operators: `=`, `<>`, `<`, `<=`, `>`, `>=`. Parenthesize mixed `AND`/`OR` conditions. `ORDER BY` is required when the output order matters. `NULL` is tested with `IS NULL`, **never** `= NULL`.

## Change data: preview, then run

```sql
SELECT event_id, title, capacity
FROM public.events
WHERE event_id = 2;

UPDATE public.events
SET capacity = 65
WHERE event_id = 2
RETURNING event_id, title, capacity;
```

```sql
SELECT event_id, title
FROM public.events
WHERE event_id = 6;

DELETE FROM public.events
WHERE event_id = 6
RETURNING event_id, title;
```

**Check the preview and the `WHERE` clause before running either change.** Without `WHERE`, every row in that table is affected. `RETURNING` shows the rows changed by the statement.

## If something fails

Read the error text. Check the active Supabase project, table and column spelling, quotes, commas, and semicolon. A constraint error often means your data broke an intentional table rule. An empty result is different from a syntax error: the query worked but found no matching row.

**Next module:** joins, grouping, aggregate functions, `HAVING`, and subqueries. Those are intentionally outside this reference.
