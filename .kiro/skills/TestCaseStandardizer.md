# Skill: Test-Case-Standardizer
**Objective**: Transform draft test cases into production-ready scenarios following `@TestCasesDesign.md`.

## Transformation Procedure:
1. **Standardization**: Read `@TestCasesDesign.md` to identify the required naming conventions (e.g., [TicketID]_TC_[Number]).
2. **Structure Enforcement**: Rewrite every test scenario into the exact format requested (e.g., Gherkin Table, Bullet points, or specific CSV-ready columns).
3. **Human-Adjustment**: Add any new test cases explicitly requested in `manual_input.md`.
4. **Quality Check**:
   - Ensure "Expected Results" are objective and measurable.
   - Remove "fluff" or vague steps (e.g., "Check if it works").
   - Ensure the "Requirement" column correctly maps to the Ticket ID.
5. **Output**: Write the standardized cases to `FINAL_TEST_CASES_[Ticket_ID].md`.