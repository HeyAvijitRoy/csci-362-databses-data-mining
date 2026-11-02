# Module 8: From Databases to Data Analysis

CSCI 362 · Avijit Roy

This module connects SQL and relational databases to data analysis and introductory data mining. Use the guide to work through the case, activities, and reflection questions.

## Learning goals

By the end of this module, you should be able to:

- Turn a question into a population, time window, unit of analysis, and measure.
- Extract one row per intended unit using SQL.
- Identify missing values, duplicate records, and misleading counts after joins.
- Explain the difference between descriptive and predictive analysis.
- Define features and a target using a stated prediction moment.

## Materials

| File | Purpose |
| --- | --- |
| [Activity guide](Activity_Guide.md) | Theory with worked examples and check questions, activity instructions, and data dictionary |
| [Dataset setup](01_Setup.sql) | Create the fictional event database in the separate `m8` schema |
| [SQL demonstrations](02_Demonstrations.sql) | Worked queries to predict, run, inspect, and explain |
| [SQL practice](03_Practice.sql) | Your working file for the extraction and prediction tasks |

## How to work through the module

1. Read the activity guide's [case assumptions](Activity_Guide.md#the-case-and-its-assumptions) and [Concepts before practice](Activity_Guide.md#concepts-before-practice). Read Sections 1–4 before Class 8A and Sections 5–8 before Class 8B.
2. Run the dataset setup and confirm the expected table counts.
3. Follow the demonstrations while keeping the guide open.
4. Complete the practice tasks and explain your results in words.
5. Draft the data plan described in the guide.

## Readings and references

### Start with the module guide

Read [Concepts before practice](Activity_Guide.md#concepts-before-practice) in the activity guide. It explains question design, row grain and joins, missing values and denominators, descriptive statistics, data quality, descriptive versus predictive and causal questions, features and targets, and evaluation planning. Each topic includes a small example and a check question; the examples use separate fictional records from the SQL practice dataset.

Then work through the guide's Class 8A and Class 8B activities alongside the SQL files. The guide is the main reading for this module; the official documentation below provides supporting detail.

### Supporting documentation

Use the following official references to clarify the ideas used in the activities. Focus on the listed topics; you do not need to read every section or run the Python examples.

| Reading | What to focus on | Connection to the module |
| --- | --- | --- |
| [PostgreSQL: Aggregate functions](https://www.postgresql.org/docs/current/functions-aggregate.html) | `COUNT(*)`, `COUNT(expression)`, `SUM`, and `AVG`; how missing values affect aggregates | Explain signup counts, known outcomes, and category summaries |
| [PostgreSQL: Table expressions](https://www.postgresql.org/docs/current/queries-table-expressions.html) | Joined tables, `LEFT JOIN`, `WHERE`, and `GROUP BY` | Preserve zero-signup events and understand changes in the meaning of one row |
| [PostgreSQL: Conditional expressions](https://www.postgresql.org/docs/current/functions-conditional.html) | `CASE`, `COALESCE`, and `NULLIF` | Count recorded attendees, distinguish missing values from zero, and handle an undefined rate |
| [scikit-learn: Common pitfalls](https://scikit-learn.org/stable/common_pitfalls.html) | The “Data leakage” and “How to avoid data leakage” sections | Identify information unavailable at prediction time and understand why training and evaluation data must be separated |
| [scikit-learn: Evaluation and cross-validation](https://scikit-learn.org/stable/modules/cross_validation.html) | Why training and testing are separate; grouped and time-based evaluation | Plan evaluation on later events while accounting for shared events and repeated people; no implementation is required |

### Ideas to carry into the activities

**The meaning of one row matters.** An event-level table and a registration-level table answer different questions. A join can repeat an event's values across several signup rows, so check the grain before counting or summing.

**Unknown does not mean absent.** In the case data, `FALSE` is a recorded absence and `NULL` is an unknown attendance outcome. Keep that distinction when calculating a percentage and explain its denominator.

**Description and prediction serve different purposes.** A descriptive summary reports what was recorded. A prediction estimates an outcome for an unseen case. Neither a category comparison nor a successful prediction automatically establishes a causal effect.

**Features must match the prediction moment.** For a prediction made immediately after signup, use information available then. Post-event feedback and final attendance totals belong to the future and would leak information into that task.

### Check your understanding

After reading, explain:

1. Why `COUNT(*)` and `COUNT(r.registration_id)` differ for an event with no matching registrations.
2. Why a rate with no known outcomes is undefined rather than zero percent.
3. How joining two child tables can multiply rows.
4. Why post-event feedback is unsuitable for a prediction made at signup.

Brightspace provides official submission directions, deadlines, and grading information.
