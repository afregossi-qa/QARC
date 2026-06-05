# Skill: Multi-Row-CSV-Transformer
**Objective**: Mechanically convert structured test objects into the specific multi-row CSV format required by TCMS.

## Transformation Procedure:
1. **Row 1 (Metadata Row)**: 
   - Populate ALL 14 headers (Folder, Requirements, Summary, ..., AI-Automated, AI-Generated).
   - Include the FIRST step and FIRST expected result.
   - Ensure specific formatting for Tags: `{TicketNumber},Tag1,Tag2`.
   - Set AI-Automated to "Yes" or "No" based on whether automation scripts exist for this TC.
   - Set AI-Generated to "Yes" or "No" based on whether the TC was authored by AI agents.
2. **Subsequent Rows (Step Rows)**: 
   - Repeat only: Folder, Requirements, Existing Case ID, and Summary.
   - Map the next Step/Expected Result.
   - LEAVE EMPTY: Description, Precondition, Priority, Tags, Automation Status, AI-Automated, and AI-Generated.
3. **CSV Escaping Rules**:
   - Wrap every field containing commas or newlines in double quotes `"`.
   - Escape any existing internal quotes using the `""` double-quote method.
4. **Header Enforcement**: Ensure the first line of the file matches the 14-column header defined in `@csv-export-format.md`.