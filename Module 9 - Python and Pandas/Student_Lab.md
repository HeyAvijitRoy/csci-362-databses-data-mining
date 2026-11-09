# Student lab · Python and pandas
CSCI 362 · Module 9 · Monday November 9; continue Wednesday November 11, 2026

## Prepare
Open `CSCI362_Module09_Student.ipynb` in Colab, save your own copy, and upload `hour.csv`. Read sections 1-4 of `Reading.md` before the first class if possible; review sections 5-7 before the continuation. See `README.md` for the file map. Use a CPU runtime. Work through the lecture cells in order. The original UCI `Readme.txt` and `Data_Provenance.md` explain the dataset.

Use the notebook's **My interpretation** text cells for explanations. The notebook numbers the six exercises; this handout is the matching checklist. Check Brightspace for the current meeting schedule.

## Monday tasks
1. **Selection and filtering:** save 2012 working-day hours 7, 8, 9 as `morning`; select date, hour, count. Show five rows and report number of observed hours. Explain the grain.
2. **Summary and denominator:** compute the overall registered-rental percentage and the mean hourly registered-rental percentage. Explain any difference.
3. **Grouping:** summarize observed hours, mean count, and total rentals by workingday. Identify the higher mean and one reason this does not establish causality.
4. **Transform:** make `day_comparison` with each workingday group's mean as `day_mean`, then compute `deviation = cnt - day_mean`. Show three rows, state the aggregation and transformation row counts, and explain why transformation retains the original rows.

Complete the four-question Monday exit ticket in the notebook. Exercise 4 may continue at the next meeting if needed.

## Wednesday tasks
5. **Two-key reasoning:** inspect mean counts by workingday and hour. For working days only, report the top three hours by mean, including group sizes and a two-sentence conclusion with historical scope and a limitation (Exercise 5).
6. **Contextual baseline:** transform within workingday/hour groups to create `context_mean`, then compute `context_deviation = cnt - context_mean`. Show the five largest positive deviations (deviation descending, then date/hour ascending). Export `top_deviations.csv` with `dteday`, `hr`, `cnt`, `context_mean`, and `context_deviation`, in that order, using `index=False`. Explain why large deviations alone do not prove anomalies or establish a forecast (Exercise 6).

## Evidence to keep
Keep a completed `.ipynb` with your code, outputs, and written interpretations, plus the Wednesday CSV export. Restart and run all cells before downloading. Confirm that files open and contain your work. Follow Brightspace for whether/when to submit; no new deadline or grade is established here. If AI or external help is permitted and used, disclose it according to the syllabus and be ready to explain every line.

## Self-review
- Every count has a unit: rows (observed hours) versus rentals.
- Filtering conditions are parenthesized and use pandas operators.
- Group summaries report sample sizes and meaningful measures.
- Transform retains rows and uses the requested grouping keys.
- Conclusions state the 2011–2012 system-level scope and avoid causal claims.
