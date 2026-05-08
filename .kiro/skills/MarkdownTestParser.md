# Skill: Markdown-Test-Parser
**Objective**: Extract structured test data from Markdown files (FINAL_TEST_CASES) into a clean internal data object.

## Procedural Steps:
1. **Header Identification**: Locate the Ticket ID and Test Title in the Markdown.
2. **Metadata Extraction**: Parse the Preconditions, Priority (map P0/P1/P2), and Tags (ensure PascalCase).
3. **Step-Result Mapping**: Pair each 'Action' with its corresponding 'Expected Result'. 
4. **Data Normalization**: 
   - Clean up any Markdown symbols (e.g., remove `*` or `_`).
   - Standardize newlines in the Precondition section using the `- ` prefix.
5. **Output**: Pass the structured object to the Transformer skill.