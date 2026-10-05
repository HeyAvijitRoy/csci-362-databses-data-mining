# CSCI 362 — Module 6 SQL Quick Reference

**PostgreSQL / Supabase**  
**Practice tables:** `public.clubs` and `public.events`

Use this beside the SQL Editor after reading the Module 6 lab guides.

---

## Relationship used throughout Module 6

```text
public.clubs
    club_id  PRIMARY KEY
       ↑
       │
       │ public.events.club_id  FOREIGN KEY
       │
public.events
```

One club can own many event rows.

---

## INNER JOIN

Use when you want only rows that match on both sides.

```sql
SELECT
    e.title,
    c.club_name
FROM public.events AS e
INNER JOIN public.clubs AS c
    ON e.club_id = c.club_id;
```

Mental model:

```text
matched rows only
```

---

## LEFT JOIN

Use when every row from the left table must remain, even when no right-side row matches.

```sql
SELECT
    c.club_name,
    e.title
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id;
```

When no event matches, event-side columns become `NULL`.

### Restrict matches but preserve left rows

```sql
SELECT
    c.club_name,
    e.title
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id
   AND e.category = 'Workshop';
```

### Find left-side rows with no match

```sql
SELECT
    c.club_name
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id
   AND e.category = 'Workshop'
WHERE e.event_id IS NULL;
```

---

## RIGHT JOIN

Preserves the right table.

```sql
SELECT
    c.club_name,
    e.title
FROM public.events AS e
RIGHT JOIN public.clubs AS c
    ON e.club_id = c.club_id;
```

Often easier to rewrite as a `LEFT JOIN` by reversing table order.

---

## FULL OUTER JOIN

Preserves unmatched rows from both sides.

```sql
SELECT
    c.club_name,
    e.title
FROM public.clubs AS c
FULL OUTER JOIN public.events AS e
    ON e.club_id = c.club_id;
```

In the reset dataset, referential integrity prevents orphan events and every club has events, so this normal relationship does not visibly create unmatched rows.

---

## CROSS JOIN

Pairs every row on one side with every row on the other.

```sql
SELECT
    c.club_name,
    e.title
FROM public.clubs AS c
CROSS JOIN public.events AS e;
```

With 6 clubs and 24 events, this would produce:

```text
6 × 24 = 144 rows
```

Use intentionally.

---

## Table aliases

```sql
FROM public.events AS e
JOIN public.clubs AS c
```

Then qualify columns with:

```sql
e.title
c.club_name
```

Aliases make joined queries shorter and prevent ambiguous column references.

---

## Aggregate functions

```sql
SELECT
    COUNT(*) AS event_count,
    SUM(capacity) AS total_capacity,
    AVG(capacity) AS average_capacity,
    MIN(capacity) AS minimum_capacity,
    MAX(capacity) AS maximum_capacity
FROM public.events;
```

| Function | Meaning |
| --- | --- |
| `COUNT(*)` | Count rows |
| `COUNT(column)` | Count non-NULL values in that column |
| `SUM(column)` | Total numeric values |
| `AVG(column)` | Average numeric value |
| `MIN(column)` | Smallest value |
| `MAX(column)` | Largest value |

---

## GROUP BY

Use when you need one summary row per group.

```sql
SELECT
    category,
    COUNT(*) AS event_count
FROM public.events
GROUP BY category
ORDER BY event_count DESC;
```

Mental model:

```text
rows → groups → aggregate each group
```

---

## GROUP BY after JOIN

```sql
SELECT
    c.club_name,
    COUNT(e.event_id) AS event_count
FROM public.clubs AS c
JOIN public.events AS e
    ON e.club_id = c.club_id
GROUP BY c.club_id, c.club_name
ORDER BY event_count DESC;
```

---

## WHERE versus HAVING

### WHERE filters rows before grouping

```sql
WHERE e.is_open = true
```

### HAVING filters completed groups

```sql
HAVING COUNT(e.event_id) >= 4
```

Together:

```sql
SELECT
    c.club_name,
    COUNT(e.event_id) AS open_event_count
FROM public.clubs AS c
JOIN public.events AS e
    ON e.club_id = c.club_id
WHERE e.is_open = true
GROUP BY c.club_id, c.club_name
HAVING COUNT(e.event_id) >= 3;
```

---

## Counting matches after a LEFT JOIN

If you need zero to remain zero, count a right-side key:

```sql
COUNT(e.event_id)
```

not necessarily:

```sql
COUNT(*)
```

Why? A `LEFT JOIN` can preserve one left-side row even when every right-side column is `NULL`.

---

## Scalar subquery

Use when the inner query returns one value.

```sql
SELECT
    title,
    capacity
FROM public.events
WHERE capacity > (
    SELECT AVG(capacity)
    FROM public.events
);
```

Think:

```text
outer question > answer from smaller question
```

---

## IN subquery

Use when the inner query returns a set of values.

```sql
SELECT
    club_id,
    club_name
FROM public.clubs
WHERE club_id IN (
    SELECT DISTINCT club_id
    FROM public.events
    WHERE fee > 0
);
```

---

## EXISTS

Use when you only need to know whether at least one matching row exists.

```sql
SELECT
    c.club_name
FROM public.clubs AS c
WHERE EXISTS (
    SELECT 1
    FROM public.events AS e
    WHERE e.club_id = c.club_id
      AND e.category = 'Workshop'
);
```

---

## NOT EXISTS

Use when you need rows for which no match exists.

```sql
SELECT
    c.club_name
FROM public.clubs AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM public.events AS e
    WHERE e.club_id = c.club_id
      AND e.category = 'Workshop'
);
```

---

## Query-reading order for Module 6

The SQL is written in this order:

```text
SELECT
FROM
JOIN ... ON
WHERE
GROUP BY
HAVING
ORDER BY
```

For reasoning, think approximately:

```text
FROM/JOIN  → build the working rows
WHERE      → filter detail rows
GROUP BY   → form groups
aggregates → calculate group summaries
HAVING     → filter completed groups
SELECT     → choose final output expressions
ORDER BY   → arrange the displayed result
```

You do not need to memorize the DBMS optimizer's physical execution strategy. This is a conceptual query-reading model.

---

## Debugging checklist

When the result looks wrong, ask:

1. What should one result row represent?
2. Which tables contain the required facts?
3. What is the PK/FK relationship?
4. Which rows must survive if no match exists?
5. Is the `ON` condition correct?
6. Did a `WHERE` condition accidentally remove `NULL` rows from a `LEFT JOIN`?
7. Is row multiplication expected from a one-to-many relationship?
8. Are you grouping by the values that define one result group?
9. Should the filter act on rows (`WHERE`) or groups (`HAVING`)?
10. What shape does the subquery return: one value, a set, or existence?
