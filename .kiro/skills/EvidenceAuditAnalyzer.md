# Skill: Evidence-Audit-Analyzer
**Objective**: Perform a multi-modal audit of screenshots, logs, and JSON data against a defined test plan.

## Procedural Steps:
1. **Media Scan**: Use `image_analysis` to identify UI elements in screenshots that match "Expected Results" in the test plan.
2. **Log/JSON Parsing**: Scan `.log` or `.json` files for status codes (e.g., 200 OK, 400 Bad Request) or specific success/error strings.
3. **Traceability Mapping**: Link every evidence filename to its corresponding Test Case ID.
4. **Status Determination**: 
   - **PASS**: Evidence explicitly proves the expected result.
   - **FAIL**: Evidence shows a discrepancy or error.
   - **MISSING_EVIDENCE**: A test case exists in the plan but no matching file is found in `./Evidence/`.
5. **Observation Capture**: Note specific details (e.g., "Latent response time in logs," "Button alignment issue in screenshot").