# Skill: Requirement-Code-Gap-Analyzer
**Objective**: Perform a line-by-line audit comparing Confluence/Jira requirements against Azure DevOps PR code diffs.

## Analytical Procedure:
1. **Extraction**: Identify all functional "Acceptance Criteria" (AC) from the Confluence document.
2. **PR Correlation**: Scan the provided PR Diffs for the specific logic, classes, or functions that satisfy each AC.
3. **Gap Detection**: 
   - Flag any AC that has **NO** corresponding code changes.
   - Flag any code changes that have **NO** corresponding AC (Unintended Side-Effects).
4. **Bug Hunting**: Analyze the diff for common implementation errors (e.g., missing null checks, incorrect status codes, or off-by-one errors).
5. **Output Structure**: Format the findings into `logic_explanation.md` with:
   - **Matched Requirements**: ACs implemented correctly.
   - **Logic Gaps**: ACs missing from the code.
   - **PR Risks**: Potential bugs found in the code diff.