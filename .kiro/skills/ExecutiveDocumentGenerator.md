# Skill: Executive-Document-Generator
**Objective**: Transform raw ticket data into polished Markdown reports (`QA_DASHBOARD.md` and `SUMMARY.md`) using `@dashboard_standards.md`.

## Transformation Procedure:
1. **Template Application**: Follow the layout defined in `@dashboard_standards.md` for both files.
2. **Dashboard Logic (`QA_DASHBOARD.md`)**:
   - Apply Emojis (✅, ❌, ⚠️) based on the current Verdict/Phase.
   - Build the 'Files Present' section as a file-tree view.
   - Consolidate 'Next Actions' based on the current Phase (e.g., if Phase is Vetted, Next Action is "Execute Tests & Upload Evidence").
3. **Narrative Synthesis (`SUMMARY.md`)**:
   - Write a 1-paragraph "Current Status" summary.
   - List specific "Validated Functionality" using data points found in the evidence analysis (e.g., "API returned 200 OK for payload X").
   - Define "Production Readiness" based on the Stability Verdict.
4. **File Write**: Use `fsWrite` to save both files **INSIDE** the specific ticket folder.