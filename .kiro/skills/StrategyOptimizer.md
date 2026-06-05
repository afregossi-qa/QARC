# Skill: QA-Strategy-Optimizer
**Objective**: Transform raw logic into a high-density, non-redundant test plan focusing on business-critical paths.

## Optimization Rules:
1. **Risk-Based Selection**: Categorize identified logic paths into High, Medium, or Low risk based on financial or security impact.
2. **Deduplication**: If two test cases cover the same code execution path (e.g., both testing the same 'if' branch), merge them into a single high-value scenario.
3. **Boundary Analysis**: Automatically generate test cases for the "edges" of the implementation (e.g., max string lengths, empty arrays, null values).
4. **Path Coverage**: Ensure the test plan includes:
   - **Happy Path**: The standard successful flow.
   - **Negative Path**: Intentional error handling.
   - **Security Path**: Permission and authentication checks.
5. **Format Enforcement**: Output to `test_plan_[Ticket_ID].md` using the Gherkin structure (Given/When/Then) as defined in `@TestCasesDesign.md`.