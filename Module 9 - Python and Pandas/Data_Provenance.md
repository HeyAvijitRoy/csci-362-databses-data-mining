# Data provenance and dictionary

The included `hour.csv` is the unchanged hourly CSV from the public UCI Bike Sharing archive, retrieved November 8, 2026. It has 17,379 data rows and 17 columns. No rows were generated, sampled, cleaned, or renamed. The actual packaged file count is used rather than a dataset-card instance count.

- Citation: Fanaee-T, H. (2013). Bike Sharing [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5W894
- Landing page: https://archive.ics.uci.edu/dataset/275/bike+sharing+dataset
- Archive: https://archive.ics.uci.edu/static/public/275/bike+sharing+dataset.zip
- License listed by current UCI page: CC BY 4.0, https://creativecommons.org/licenses/by/4.0/
- Associated paper: Fanaee-T & Gama (2013), Event labeling combining ensemble detectors and background knowledge. https://doi.org/10.1007/s13748-013-0040-3
- Origin: aggregated Capital Bikeshare system rental records, Washington, D.C., 2011–2012, with calendar and weather variables. No individual rider or station identifiers.
- CSV SHA-256: `e03de4ee4ef4dc376ac6e04bf829673c6269e8eba5c60fa121640fa2f829504f`

The original `Readme.txt` accompanies the CSV unchanged and provides the full source dictionary. The notebook has a classroom dictionary. `instant` is a record ID; `dteday`/`hr` identify an observed hour; `yr` is 0/1 for 2011/2012; `mnth` is 1–12; `weekday` is Sunday=0 through Saturday=6. `workingday` excludes weekends and holidays. `season` and `weathersit` are categorical source codes. `temp`, `atemp`, `hum`, and `windspeed` are normalized. `casual` + `registered` = `cnt`.

Current UCI metadata and the original readme differ in season labels and temperature normalization wording. Use the current UCI season labels: 1 = winter, 2 = spring, 3 = summer, 4 = fall; the original readme labels them differently. This lesson preserves the source fields, treats temperature as normalized, and performs no physical-unit conversion. Humidity is multiplied by 100 only to express its documented fractional scale as a percentage.

Observed hours are not a complete hourly grid. Absence of a row is not proof of zero demand. Counts are rental events, not unique people. Data describe historical system-wide activity, not today's demand or station availability. Group comparisons are descriptive associations.
