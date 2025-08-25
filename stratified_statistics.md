## Stratified statistics of biomarker labs, methodology and workflow

Clinical lab tests for biomarker measurement
can be enhanced and targeted for precision
diagnostic and prognostic applications
by EHR-data driven stratification. Whereas there
is general understanding that values indicating
normal-physiological, and abnormal-pathological, depend
on patient strata, such as by sex and age,
there is an unmet need for data-driven guidance on
these statistics. This is the need we attempt to
begin to address in this approach, initially focusing on
molecular biomarkers, mostly plasma proteins, and
normal-physiological (healthy) distribution statistics.

For each molecular biomarker, the following steps
comprise our algorithm.

 1. Select a year which will be considered representative. There are
several reasons for not using the entire HealthFacts database.
One is practical, since a subset allows for faster analysis and
methods development. Another reason relates to data quality, and
uncertainties regarding sampling bias and other issues with some
older data. We are using the year 2018, the last full year that
HealthFacts was maintained as such, before the acquisition of
Cerner by Oracle.

 2. Determine the lab procedure IDs and LOINC codes for lab tests for the
biomarker of interest. There are generally multiple tests for important
biomarkers such as Troponin and PSA.

 3. Query the db for all test results for the given LOINC codes. We expect
ample data quantity, so focus on quality, and filter any rows with NULL
(or non-numeric) values, or NULL or uninterpretable units. This query
also retrieves encounter IDs, which can be linked to patient IDs.

 4. If a predominant or most-frequent unit (e.g. ng/mL) allows for sufficient
data quantity, filter all others.

 5. Mindful that EHR data includes noise and errors, and given that we
are focusing on normal-physiological statistics, filter values exceeding
some percentile from the median. Possibly keeping only 10-90pct-ile. Generate
basic statistics for this full dataset: N, mean, median, min, max, stddev.

 6. Query for all patient IDs from encounter IDs in the dataset. This is the
initial patient cohort. It may be advantageous to build a temporary db
table with this mapping, and the patient stratification variables of
interest.

 7. Generate descriptive statistics on the patient cohort for the stratification
variables of primary and initial interest: age, sex, race.

    * Note that while DOB is a persistent patient variable, age depends on the date of the encounter and test. This is another reason to use a single year of data, since to some precision this allows for a single age per patient (e.g. age at mid-year).

    * Similarly, patient-type (Emergency, Inpatient, Outpatient, etc.) depends on the encounter and can vary for a given patient. We may wish to filter by patient-type to favor normal-physiological lab results.

 8. Develop set of diagnostic ICD codes to be exclusion criteria, defining a
normal patient criteria.

 9. Generate descriptive statistics on the patient cohort. Filter the
initial patient cohort using the exclusion criteria, to generate the normal
patient cohort. Re-generate descriptive statistics for the stratification
variables of interest.

 10. Define stratification ranges. Probably age ranges by decade [0-9],
[10-19], [20-29], ... [80-89], 90+. Generate patient ID sets for each
sub-cohort.

 11. For each patient sub-cohort, each strata, generate statistics:
N, mean, median, min, max, stddev.

This workflow should result in data files (and tables) which allow for
revision of: exclusion criteria, stratification ranges, and value filtering.
