---
inclusion: manual
---

# Regression & Automation Selection Criteria

**Source:** Confluence (TE Space) — consolidated from department standards.
- [QA Best Practices – Selecting Test Cases for Automation](https://qubeyond.atlassian.net/wiki/spaces/TE/pages/2405400590)
- [QA Regression Testing Process – Department Standard](https://qubeyond.atlassian.net/wiki/spaces/TE/pages/2330427421)
- [QA Best Practices – Test Case Standards & Linking Rules](https://qubeyond.atlassian.net/wiki/spaces/TE/pages/2403663873)

---

## 1. When to Tag a Test Case as `Regression`

A test case MUST be tagged `Regression` in AIO when **any** of the following apply:

| Condition | Rationale |
|-----------|-----------|
| Covers a core business flow (ordering, payments, login, sync) | Failures in these paths cause major customer impact |
| Linked to a bug that escaped to production or UAT | Prevents the same defect from recurring |
| Tests a cross-module integration point | Integration seams are high-risk regression areas |
| Priority is Critical or High | Aligns with exit criteria (100% Critical+High executed) |
| Feature is used daily by cashiers/managers | High usage = high regression risk |

**Do NOT tag as Regression:**
- One-time migration/setup validations
- Exploratory or ad-hoc test notes
- Tests for features not yet released to production

---

## 2. Automation Candidate Selection Criteria

Automate tests that meet **3+ of these criteria**:

| # | Criterion | Weight |
|---|-----------|--------|
| 1 | **Critical or High Priority** — core business flows, high-risk features | High |
| 2 | **Run Frequently** — regression, smoke, or repeated every sprint | High |
| 3 | **Time-Consuming/Tedious** — long manual execution or error-prone steps | Medium |
| 4 | **Stable Requirements** — feature and test data not changing frequently | Medium |
| 5 | **High ROI** — automation benefit outweighs build + maintenance effort | Medium |
| 6 | **High Defect Yield** — historically caught many bugs | Medium |
| 7 | **Repetitive Across Configurations** — same flow across datasets, brands, or environments | High |

### Disqualifiers (do NOT automate yet)

- Requirements still in flux (wait until stable)
- One-time execution tests with no repeat value
- Tests that require complex physical device interaction with no programmatic workaround
- Cases blocked by unresolved environment or data dependencies

---

## 3. Workflow for Selecting Automation Candidates

1. Open the **latest manual regression cycle** in AIO
2. Filter: `Automation Status = To Be Automated` + `Priority = High or Critical`
3. Review results with **manual QAs / QA Team Lead** — confirm priorities, remove blocked cases
4. Create **Jira QA Automation tasks** for agreed cases:
   - Include test case ID & title in description
   - Link AIO test case to the Jira task
   - Link to the squad's quarterly Automation Epic
   - Plan tasks for **next sprint** (present during sprint planning)
5. Work from the agreed list — **no cherry picking**
6. Communicate regularly with manual QAs/QA Lead to reprioritize

---

## 4. Mapping to Test Case Template Fields

When writing test cases (per `TestCasesDesign.md`), set these fields:

| Field | Value | When |
|-------|-------|------|
| `Regression Potential` | High / Medium / Low | Always assess |
| `Regression Candidate` | Yes / No | Yes if criteria from §1 met |
| `Automation Status` | To Be Automated | If criteria from §2 met (3+ criteria) |
| `Automation Status` | Manual | If disqualified or low ROI |
| `Tags` | Include `Regression` | If `Regression Candidate = Yes` |

---

## 5. Regression Cycle Rules (Department Standard)

| Rule | Detail |
|------|--------|
| Separate cycles | Create **Automation Regression** + **Manual Regression** per squad per release |
| Scope lock | No ad-hoc test case additions after 24h post code-freeze |
| Exit criteria | 100% Critical & High tests executed, no open Highest-priority blockers |
| Map up-front | All test cases assigned to cycles before regression starts |
| Communication | One Slack thread per squad in #tech-qa-chapter |

---

**Last Updated:** June 3, 2026
**Version:** 1.0
