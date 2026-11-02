# Module 8: From Databases to Data Analysis

CSCI 362 · Avijit Roy

## What you should be able to do

Translate a question into a population, time window, unit of analysis, and measure. Extract an analysis table with SQL and verify its grain. Explain missing outcomes and denominators. Distinguish descriptive, predictive, and causal questions. Define features and a target using a stated prediction moment.

## Before class

Review `LEFT JOIN`, `GROUP BY`, `COUNT`, `CASE`, and primary/foreign keys. Open your course PostgreSQL or Supabase SQL environment. Use fictional data only. No Python installation is needed for this module.

Run [01_Setup.sql](01_Setup.sql) once. It creates a separate `m8` schema and three tables without changing earlier lab tables. The SQL role must be allowed to create schemas and tables. The setup can be rerun and retains existing rows. If the counts differ from **6 events, 8 registrations, and 3 feedback rows**, stop and inspect your setup. Do not delete earlier work. If a statement fails inside the setup transaction, run `ROLLBACK;`, inspect the error, and correct the problem before retrying.

Open [02_Demonstrations.sql](02_Demonstrations.sql) beside [03_Practice.sql](03_Practice.sql). Run labeled demonstration blocks separately. Keep your completed practice file under a new name. Submission and any grading directions come from Brightspace.

## The case and its assumptions

A campus office wants to understand recorded attendance at October events and plan a later prediction task. The records are fictional. The snapshot is **November 1, 2026**. The October window is `[2026-10-01, 2026-11-01)`. The lower bound is included and the upper bound is excluded.

All five October events took place. Every signup is captured. Attendance capture has one unknown October outcome. TRUE means a recorded attendee, FALSE means a recorded absence, and NULL means an unknown outcome. An event with no signups must remain in the event-level analysis. Unregistered walk-ins are outside the dataset's scope.

## Concepts before practice

Read Sections 1–4 before Class 8A and Sections 5–8 before Class 8B. The examples in this reading use separate fictional records; they are not additional rows to insert into `m8`. Work through the numbers and check questions before returning to the October case.

### 1. Turn a question into a data task

SQL can return a correct result for the wrong question. Before choosing columns or writing a join, decide what you want the result to describe.

Suppose a library asks: **How many signups did each September workshop receive?** A useful specification is:

| Decision | Meaning | Library example |
| --- | --- | --- |
| Population | The set of cases the analysis is intended to describe | All workshops held by this library in September, including workshops with no signups |
| Time window | The dates that determine whether a case belongs | Workshop dates from September 1 up to, but not including, October 1 |
| Unit of analysis | The kind of thing represented by one analysis row | One workshop |
| Measure | A quantity recorded or calculated for that unit | Number of signups for the workshop |
| Grouping variable | A characteristic used to form comparison groups | Workshop topic, if we later compare topics |
| Limitation | A boundary on what the records can tell us | Signups do not establish how many people attended |

Notice that the window applies to the **workshop date**. Someone who signed up in August for a September workshop still belongs in its signup count. Filtering by signup date would answer a different question.

Write the row definition as a sentence: **One output row represents one September workshop.** If you later summarize by topic, the output unit changes to one topic. State that change explicitly.

**Check yourself:** If the question becomes “How many signups were submitted during September?”, which date should determine inclusion? Would one row still need to represent a workshop?

### 2. Understand grain before counting after a join

The **grain** of a table is the precise meaning of one row. A workshop table has one row per workshop. A signup table has one row per signup. Their primary keys identify rows at different grains.

Imagine workshop W1 has signups S1 and S2, while W2 has none. A `LEFT JOIN` from workshops to signups produces:

| Workshop | Signup | Meaning of this joined row |
| --- | --- | --- |
| W1 | S1 | W1 matched to its first signup |
| W1 | S2 | W1 matched to its second signup |
| W2 | NULL | W2 preserved even though it has no matching signup |

There are three joined rows, two actual signups, and two workshops. Therefore, “count the rows” is incomplete advice: you must specify **which rows at which stage**.

For this join, `COUNT(*)` counts every joined row. `COUNT(signup_id)` counts only rows with a non-null signup ID. Grouping by workshop gives W1 two signups and W2 zero. A plain inner join would omit W2 entirely. PostgreSQL documents these [join and grouping rules](https://www.postgresql.org/docs/current/queries-table-expressions.html).

Now imagine W1 also has three feedback rows. Joining workshops to both child tables by workshop ID pairs each of its two signups with each of its three feedback rows: **2 × 3 = 6 joined rows**. The database has not created extra source signups; the query has repeated their values. Aggregate each child table to one row per workshop before combining their summaries, as demonstrated in D5.

A **common table expression (CTE)** names an intermediate query result using `WITH`. It can make those stages easier to follow: first build one row per event, then calculate a rate or summarize by category. A CTE belongs to one complete statement and does not become a stored table. Run its `WITH` clause and final `SELECT` together.

**Check yourself:** If W1's capacity appears on both signup rows, would summing that repeated capacity measure its room capacity correctly? What grain should the capacity calculation use?

### 3. Separate missing values, zero, and recorded absence

These values describe different situations:

| Value | Interpretation in an attendance record |
| --- | --- |
| `TRUE` | Attendance was recorded |
| `FALSE` | Absence was recorded; the outcome is known |
| `NULL` | The outcome is unknown |
| A signup count of `0` | No signups exist for that event |

`COUNT(attended)` counts both `TRUE` and `FALSE`, because both are non-null values. It excludes unknown outcomes. `AVG` also ignores null inputs; replacing missing values with zero changes the calculation. Review the [aggregate rules](https://www.postgresql.org/docs/current/functions-aggregate.html) when choosing a denominator.

For a separate seminar with six signups, suppose three people attended, one was absent, and two outcomes are unknown:

- **Attendance among known outcomes:** `3 / 4 × 100 = 75%`. This describes the four signups whose outcomes were recorded.
- **Confirmed attendance among all signups:** `3 / 6 × 100 = 50%`. This describes the share of all signups confirmed as attendees. It does not establish that the remaining half were absent.

The numerator is the quantity counted on top; the denominator defines the reference group. Name both before reporting a percentage. Missing outcomes may make the known-outcome group different from the full signup population.

If an event has no known outcomes, the first rate is undefined. `NULLIF(known_outcomes, 0)` converts a zero denominator to `NULL`, allowing the result to remain unknown rather than causing division by zero. `COALESCE` replaces a null value with a chosen alternative, but that alternative needs a reason: zero is appropriate for a missing signup count after joining an aggregated signup table, while it would misrepresent an undefined attendance rate. These functions are explained in [PostgreSQL's conditional expressions reference](https://www.postgresql.org/docs/current/functions-conditional.html).

**Check yourself:** An event has two known absences and no unknown outcomes. Another has two unknown outcomes and no known outcomes. Why should their known-outcome attendance rates differ?

### 4. Choose a summary that matches the question

A **total** adds quantities. A **mean** divides their total by the number of included values. A **median** is the middle value after sorting; for an even number of values, the usual numerical median is the mean of the two middle values.

Suppose observed attendance at five separate library workshops is `0, 2, 3, 3, 12`. The total is 20, the mean is `20 / 5 = 4`, and the median is 3. The largest workshop pulls the mean upward. Both summaries are correct, but they describe the distribution differently. Including the zero matters when the question concerns all five workshops.

An **overall attendance rate** and a **mean of event attendance rates** also answer different questions. Suppose event X has one attendee among two known outcomes, while event Y has eight among eight:

| Summary | Calculation | Interpretation |
| --- | --- | --- |
| Overall rate | `(1 + 8) / (2 + 8) × 100 = 90%` | Each known signup outcome contributes equally |
| Mean event rate | `(50% + 100%) / 2 = 75%` | Each event contributes equally, regardless of signup count |

Neither calculation is a substitute for naming the question. When averaging event rates, identify any events excluded because their rate is undefined. Similarly, averaging category means gives categories equal weight; it does not generally give the overall mean across events.

**Check yourself:** For the library workshop counts above, what changes if the zero-attendance workshop is removed? Would the new mean still describe all five workshops?

### 5. Treat data quality as a question about meaning

A database constraint can enforce a rule such as a unique signup business key or an existing parent event. An imported file may not have those protections. Even a table that passes every declared constraint can contain an incorrect date or a misleading code.

A **business key** identifies the real-world record according to the task's rules. If one person may sign up only once per workshop, the pair `(workshop_id, person_code)` is a signup business key. Two different row IDs can still refer to the same signup. Conversely, the same person signing up for two different workshops is not a duplicate under that rule.

Check at least four kinds of issue: repeated business keys, missing parent references, values outside a documented code set, and inconsistent dates. A signup recorded after a workshop might be a mistake, a late import, or a legitimate retrospective entry. The date alone does not establish which explanation is correct.

For each suspected issue, preserve the raw record and document the evidence, proposed action, and unresolved question. For example, “verify whether this field records signup time or import time” is more useful than silently deleting a surprising date. Keep corrections traceable to their source.

**Check yourself:** Two imported rows have different row IDs but the same person and workshop. What additional evidence would help you decide whether they are duplicate records or legitimate changes to one signup?

### 6. Distinguish description, prediction, and causation

These question types require different claims:

| Type | Example | What an answer would establish |
| --- | --- | --- |
| Descriptive | How many reserved library books were collected last month? | A summary of recorded past outcomes |
| Predictive | At reservation time, which books are likely to remain uncollected? | An estimate for a case whose outcome is not yet known |
| Causal | Would changing the reminder policy increase collection? | The effect of an intervention, requiring a suitable study design and assumptions |

A category with higher recorded attendance may also differ in capacity, timing, audience, or record completeness. A descriptive comparison does not separate those explanations. A model might predict collection well using branch location, yet that would not establish that moving a reservation to another branch would change its outcome.

Data mining examines patterns in data. **Supervised learning** uses examples with known outcomes to learn a prediction rule. Other tasks, such as clustering similar cases, may have no labeled target. This module prepares the analysis table and prediction plan; fitting models comes later.

**Check yourself:** “Evening workshops have more recorded attendees, so moving every workshop to the evening will increase attendance.” Which part summarizes an association, and which part needs causal evidence?

### 7. Define features and a target at a prediction moment

A **feature** is an input used to make a prediction. A **target** is the outcome to predict. A **label** is the known target value attached to a historical example. The **prediction moment** fixes the point in time when the inputs must be available.

For a library pickup task, let one row represent one reservation and make the prediction immediately after the reservation is placed. Candidate features could include the pickup branch and loan category as recorded then. The target might be whether the item was collected within seven days after it became ready. That outcome definition also tells us when a historical example has had enough time to receive a label.

A historical training row combines the inputs available at reservation time with the outcome learned later. A new reservation has those inputs but does not yet have a known target. Keeping the historical target in a training table is necessary; using it as an input would defeat the task.

**Data leakage** occurs when model building uses information that would not be available for a real prediction. The eventual collection timestamp would leak the outcome into the library task. A branch description edited after the reservation could also be inappropriate if it was not the description available at prediction time. Ask when a value became available, rather than assuming that every column currently in the database was available then.

An identifier supports joins and auditing. Its numerical appearance does not make it a useful quantitative feature: reservation 800 is not meaningfully “twice” reservation 400. Decide whether to include an identifier based on the intended use and evaluation, not its data type alone.

**Check yourself:** Why can a historical prediction table contain a later outcome as its target while still excluding that outcome from its features?

### 8. Plan evaluation and explain exclusions

**Training data** supplies examples from which a model learns. **Evaluation data** supplies separate examples used to check its predictions. Good results on the training cases alone may reflect **overfitting**: learning details of those cases that do not generalize to new ones.

Choose the separation to match the intended use. If a future library system will predict new reservations, a possible plan is to train on earlier reservations with fully observed outcome windows, keep a later period for development, and reserve a still-later period for final testing. Use only labels that would have been known when the model was trained. Do not repeatedly change the model based on final test results; that makes the test part of development.

For the event task, keep all registrations for one event in the same partition and use later events for evaluation. Registrations at the same event share conditions, so randomly splitting signup rows can make evaluation less representative of performance on new events. If the intended use involves new people, also plan how repeated people will be kept from appearing on both sides. With overlapping people and events, this may require selecting or excluding groups; a simple random split cannot guarantee both conditions.

Any learned preparation, such as choosing replacement values from a dataset average, must use training data only and then be applied to evaluation data. The [scikit-learn leakage guide](https://scikit-learn.org/stable/common_pitfalls.html#data-leakage) and [evaluation guide](https://scikit-learn.org/stable/modules/cross_validation.html) explain why separation matters. No Python implementation is required here.

Excluding unknown targets can be necessary for supervised learning, but it can also introduce **selection bias**: the retained examples may systematically differ from the cases where the model will be used. Suppose uncollected library reservations are less consistently recorded than collected ones. The labeled subset could make collection look more common than it is. Report exclusions, investigate why outcomes are missing, and limit claims accordingly. An outcome that has not happened yet is also different from a missing record after its observation window has ended.

An evaluation plan should state which cases are held out, how time and shared groups are handled, and what counts as useful performance. For attendance, consider errors on both attendees and absentees and compare against a simple baseline, such as always predicting the most common training outcome. A tiny illustrative dataset cannot support a reliable performance claim, even if every prediction is correct.

**Check yourself:** Why might a model appear successful on randomly held-out registrations but perform worse at an entirely new event? What would you need to know before treating an unknown outcome as an absence?

## Class 8A: Questions and extraction

### A0. Specify the task

Question: How did recorded attendance vary across October event categories?

Write your population, time window, unit of analysis, measures, grouping variable, and one limitation. Finish this sentence before coding: **One output row represents ______.**

### A1. Select the population

Select October events. Return event_id, title, category, capacity, and fee. Explain why event 6 is excluded. Use the date window stated above, rather than the computer's current date.

### A2. Build the analysis table

Use a LEFT JOIN to preserve events without signups. Produce one row per October event with registrations, known_outcomes, observed_attendees, and unknown_outcomes. Explain why COUNT(*) and COUNT(r.registration_id) differ for event 4. Explain why COUNT(r.attended) includes both TRUE and FALSE.

### A3. Define a rate

Calculate the attendance percentage among known outcomes:

```sql
ROUND(
    100.0 * observed_attendees / NULLIF(known_outcomes, 0),
    1
) AS attendance_pct_known
```

State the numerator, denominator, and unit. Explain what a `NULL` result means. For event 1, compare this rate with confirmed attendees divided by all registrations. Which question does each measure answer?

**Check your output:** Five rows with unique event IDs 1–5. Seven signups in total. Event 4 has zero signups. Investigate discrepancies before interpreting results.

### Class 8A exit ticket

1. What does one output row represent?
2. Why does event 4 remain?
3. Why is unknown attendance different from absence?

## Class 8B: Quality, description, and prediction

### B1. Describe the result

Reuse the event summary as a CTE. Group by category and return event_count, total_observed_attendees, and mean_observed_attendees_per_event. Include events with zero signups. Calculate the mean and median observed attendance across all five October events. Write one supported finding and one limitation. Does a higher observed average establish that an event category causes better attendance? Explain.

For the overall mean, use `AVG(observed_attendees)` on the five event-level rows, including zeros. For the median, sort those five observed-attendance counts from smallest to largest and report the middle (third) value in your written response. A SQL median calculation is optional. Calculate these overall summaries from the event-level rows before grouping by category.

### B2. Audit an import

Run the supplied raw_registration CTE in the practice file. These unconstrained import rows are separate from the validated database tables. Identify a duplicate signup business key, an unmatched event, an undefined status, and a signup date after its event. For each issue, record: row ID, evidence, proposed action, and unresolved question. Preserve raw rows. Do not replace an ambiguous status with absence or discard an unusual date without verification.

The import specification allows only `Y` (recorded attendance) and `N` (recorded absence) in `status`. Any other value is undefined and requires clarification before conversion to the database's `attended` field.

### B3. Prepare a prediction table

Question: Immediately after a person signs up, can we predict whether they will attend?

Use one row per registration. Keep October events with known attendance outcomes. Extract registration_id, event_id, category, fee, days_notice, and target_attended. Define `days_notice = event_date - registered_on`. Encode TRUE as 1 and FALSE as 0 only after excluding unknown outcomes. Event category, fee, and date are assumed fixed and known at signup in this exercise. Verify six labeled rows. Explain the two excluded registrations and why that exclusion might matter in a real study.

### B4. Review proposed inputs

For fee, category, days_notice, post-event feedback rating, final attendee count, and person_code, state whether the value is available at signup and whether you would use it as a feature. Identify leakage and an identifier concern. Explain how you would test on later events while keeping each event's registrations together. Consider repeated people if the intended system must handle new people. No model fitting is required, and this tiny dataset cannot establish predictive performance.

### One-page data plan

Use a possible approved project dataset, or continue with fictional event data. Include:

1. A descriptive question.
2. A predictive question.
3. The population and time window.
4. The meaning of one row.
5. The target and prediction moment.
6. Candidate features and when each is available.
7. Two quality checks with proposed actions.
8. An evaluation plan and one limitation.
 
This is preparation for the data mining project. Official project requirements and dates are on Brightspace.

### Class 8B exit ticket

1. Give one descriptive and one predictive question.
2. Identify a feature that leaks future information.
3. State one limitation of the October comparison.

## Optional extension

Predict the result of D4, then compare with D5. Explain why joining two child tables can multiply rows. Compare the overall rate among known outcomes with the mean of event-level rates. Finally export D3 to CSV, retain its query and definitions, and reopen it to verify five rows, unique event IDs, missing values, and types.

## Data dictionary

| Field | Meaning |
| --- | --- |
| event_id | Event identifier, retained for joins and audit |
| registration_id | Signup identifier, retained for audit |
| person_code | Fictional person identifier; a person can attend multiple events |
| category | Workshop, Demo, or Showcase |
| capacity | Positive room capacity in people |
| fee | Nonnegative event fee in dollars |
| registered_on | Signup date |
| attended | TRUE, FALSE, or unknown (NULL) |
| registrations | Number of signups for the event |
| known_outcomes | Signups whose attended value is TRUE or FALSE |
| observed_attendees | Signups whose attended value is TRUE |
| unknown_outcomes | Signups minus known outcomes |
| attendance_pct_known | Percentage attending among known signup outcomes |
| days_notice | Whole days between signup and event |
| target_attended | Known attendance encoded 1 or 0 |

An analysis table keeps one row per chosen unit and one variable per column, with documented definitions, types, and missing-value meanings. It can deliberately combine source tables for a task while the underlying database retains its normalized design. An identifier is not automatically a numerical feature. Not every analytical task needs a target; descriptive summaries and clustering may have no labeled outcome.

## References

- [PostgreSQL: Aggregate functions](https://www.postgresql.org/docs/current/functions-aggregate.html)
- [PostgreSQL: Table expressions and joins](https://www.postgresql.org/docs/current/queries-table-expressions.html)
- [PostgreSQL: Conditional expressions](https://www.postgresql.org/docs/current/functions-conditional.html)
- [scikit-learn: Common pitfalls and data leakage](https://scikit-learn.org/stable/common_pitfalls.html)
- [scikit-learn: Evaluation, grouped data, and time-based splits](https://scikit-learn.org/stable/modules/cross_validation.html)
