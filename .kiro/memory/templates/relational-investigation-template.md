# 🔍 Relational Investigation: POS-{ID}

## 🚩 Executive Summary
- **Root Cause**: [1-sentence technical finding]
- **Shared Memory Hit**: [Link to entry in lessons_learned.md or "None"]
- **Severity**: [Critical/High/Med]

## 🧪 Forensic Triangulation
| Source | Evidence Point |
| :--- | :--- |
| **Vision (Screenshot)** | Time [HH:MM:SS] showing [UI State/Error Modal]. |
| **Logs (POS/KDS)** | [Timestamped Log Entry] matching the visual error. |
| **Database (SQLite)** | [Query Result] confirming data mismatch. |

## 🧠 Automation Intelligence [FOR_AUTOMATION]
> **Instruction for the Automation Architect Agent:**
- **The Gap**: Why did our current automation miss this? (e.g., "We don't test network lag on the Split Check screen").
- **Proposed Test Case**: [Steps to reproduce the failure in the Java framework].
- **Suggested Locators**: [IDs or AccessibilityNames identified from the log/screenshot].

## 📝 Learning Loop Contribution
- [ ] Added to `lessons_learned.md`
- [ ] New SQL query/Log pattern added to `pattern_registry.md`