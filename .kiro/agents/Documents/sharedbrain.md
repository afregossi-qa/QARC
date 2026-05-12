# 🧠 System Blueprint: The Qu POS "Shared Brain"

This document outlines the architecture and workflow of the Qu POS "Relational Intelligence" System. It explains how agents bridge the gap between Test Design (Automation) and Field Bug Triage (Production) using a shared memory vault.

---

## 1. The Core Concept: Breaking the Silo

Traditionally, Automation teams and Triage teams work in separate worlds. Bugs found in the field aren't immediately used to improve tests, and "flaky" tests in automation are often ignored until they hit production.

This system fixes that by creating a **single, shared consciousness**.

### 🛠️ The Infrastructure

- **Shared Memory Vault**: An in-repo folder (`.kiro/memory/`) that stores the squad's history and travels with the workspace.
- **Auto-Include Steering**: The `.kiro/steering/shared-brain.md` file (inclusion: auto) ensures every agent reads memory before starting.
- **Learn Hook**: The `shared-brain-learn` hook automatically extracts lessons from Reviewer reports and appends them to memory.
- **Forensic Triangulation**: The ability of the QA Field Triage Agent to correlate Vision (Screenshots) + Logs (Timestamped events) + Data (SQLite states).

---

## 2. How the Agents "Think"

All agents follow the **Cognitive Memory Protocol**. This ensures they don't just perform tasks — they learn.

| Phase | Action | Purpose |
|-------|--------|---------|
| 0. RECALL | Reads `lessons_learned.md` before starting | To avoid repeating past mistakes |
| 1. RELATE | Connects current logs to historical automation results | To identify if a "new" bug is actually an old "flaky" test |
| 2. LEARN | Writes new findings back to the shared memory | To update the "Collective Brain" for the rest of the squad |

---

## 3. The "Pro Detective" Workflow (Field Bug to Hotfix)

When a critical bug is reported from a production store, the system follows this forensic loop:

### Step 1: The Summons

A Hotfix Triage Request is dropped into the shared folder. It contains the Jira ID, the store environment, and a path to the evidence (Logs + Screenshots).

### Step 2: Forensic Triangulation

The QA Field Triage Agent (powered by Gemini 3 Pro) performs a three-point check:

- **Vision**: It "sees" the time on the POS screenshot (e.g., 12:04 PM).
- **Logs**: It jumps to 12:04 PM in the production logs to find the exact exception.
- **Database**: It queries the local DB to see if the order data matches what the user saw on the screen.

### Step 3: Relational Reporting

The agent identifies the **Automation Gap**. It doesn't just say "It's broken" — it tells the Automation squad:

> "We missed this because our current tests don't simulate 3-second network delays. Create a new test case for this immediately."

---

## 4. Real-World Example: "The Ghost in the Mesh"

**The Scenario**: Store #402 reports that orders are disappearing between the Terminal and the Kitchen (KDS).

### 🔴 The Investigation

1. **Recall**: The agent reads the Shared Brain and sees that 2 weeks ago, an Automation Test failed with a "KDS Timeout" but was ignored as "flaky environment noise."
2. **Investigation**: The agent analyzes the production screenshot from Store #402. It sees a "Low WiFi" icon.
3. **The Discovery**: In the production logs, it finds a `TcpTimeout` at 3005ms. The system limit is 3000ms.
4. **The "Relational" Connection**: The agent realizes the "flaky" automation test was actually a warning that the timeout was too short for real-world production networks.

### 🟢 The Resolution

- **Immediate Hotfix**: Increase the TCP Timeout to 5000ms in the production config.
- **Learning Loop**: The agent updates `lessons_learned.md`: *"NEVER ignore 3000ms timeouts as flaky. These are production blockers."*
- **Automation Update**: The Automation Architect sees this note and automatically adds a "Latency Injection" test to the regression suite so this bug can never return.

---

## 5. Summary of Files Created

| File Name | Location | Role |
|-----------|----------|------|
| `lessons_learned.md` | `.kiro/memory/` | The log of every mistake and fix ever found |
| `pattern_registry.md` | `.kiro/memory/` | Known error signatures, diagnostic queries, resolution patterns |
| `project_context.md` | `.kiro/memory/` | The map of how POS modules relate to each other |
| `shared-brain.md` | `.kiro/steering/` | Auto-include steering that enforces RECALL/LEARN on all agents |
| `CognitiveMemoryProtocol.md` | `.kiro/skills/` | Detailed protocol definition (RECALL → RELATE → LEARN) |
| `shared-brain-learn.hook` | `.kiro/hooks/` | Hook that auto-extracts lessons from Reviewer reports |
| `investigation_report.md` | Ticket Folder | The final forensic result linking field bugs to automation gaps |
