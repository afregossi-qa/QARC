# Skill: Human-Context-Integrator
**Objective**: Synchronize initial AI findings with human manual input to create a single source of truth.

## Procedural Steps:
1. **Conflict Detection**: Compare the 'Logic Gaps' in `logic_explanation.md` against the notes in `manual_input.md`.
2. **Override Logic**: If a human note contradicts the AI finding, the human note **MUST** be adopted as the truth. 
3. **Draft Enrichment**: Take the "Tribal Knowledge" from `manual_input.md` (e.g., legacy dependencies) and inject them into the corresponding sections of `logic_explanation.md`.
4. **Audit Trace**: Add a small footnote to updated sections: *"Refined with Human Input."*