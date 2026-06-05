# Skill: Lifecycle-State-Scraper
**Objective**: Audit the ticket folder to determine the current maturity phase and extract key metrics.

## Procedural Steps:
1. **Phase Detection**: Check for file markers in the following order (Highest to Lowest):
   - **COMPLETED**: `./Evidence/FINAL_CLOSURE_REPORT_[ID].md` exists.
   - **EXPORTED**: Any `.csv` file exists in the root folder.
   - **VETTED**: `FINAL_TEST_CASES_[ID].md` exists.
   - **DISCOVERY**: `logic_explanation.md` exists.
2. **Metadata Extraction**:
   - If **COMPLETED**: Open the Closure Report; extract the 'Verdict', '% Coverage', and 'Last Audit Date'.
   - If **IN_PROGRESS**: Open `logic_explanation.md`; count the 'Logic Gaps' and extract the 'Risk Assessment'.
3. **Evidence Inventory**: List all filenames inside the `./Evidence/` sub-folder to document proof of testing.
4. **Data Packaging**: Pass a structured summary of these findings to the Document Generator skill.