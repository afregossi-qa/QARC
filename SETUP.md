# QARC Setup Guide

How to adapt this framework to your project.

---

## 1. Prerequisites

- [Kiro IDE](https://kiro.dev) installed
- [uv](https://docs.astral.sh/uv/getting-started/installation/) — Python package runner (for Atlassian MCP server)
- [Node.js](https://nodejs.org/) — runs the AIO Tests MCP server and Azure DevOps MCP
- A Jira project with tickets to test
- (Optional) AIO Tests for test case management
- (Optional) Azure DevOps for PR review integration

---

## 2. Configure MCP Servers

```bash
cp .kiro/settings/mcp.example.json .kiro/settings/mcp.json
```

Edit `.kiro/settings/mcp.json` and fill in:

| Server | Credential | Where to get it |
|--------|-----------|-----------------|
| Atlassian | API Token | [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens) |
| Azure DevOps | PAT | Azure DevOps → User Settings → Personal Access Tokens (Code Read scope) |
| AIO Tests | API Token | AIO Tests → Settings → API |

**Disable servers you don't use** by setting `"disabled": true` in the config.

---

## 3. Customize Steering Files

These files teach the agents about YOUR project. Edit them:

| File | Purpose | Priority |
|------|---------|----------|
| `.kiro/steering/product.md` | Your product's domain, features, business concepts | **High** — agents use this to understand context |
| `.kiro/steering/tech.md` | Your tech stack, API patterns, test commands | **High** — agents use this for technical decisions |
| `.kiro/steering/structure.md` | Folder conventions (usually fine as-is) | Low |
| `.kiro/steering/lifecycle-states.md` | Pipeline state machine (usually fine as-is) | Low |

---

## 4. Populate Memory

The `.kiro/memory/` folder is the framework's learning system. Copy the templates to get started:

```bash
cp .kiro/memory-templates/lessons_learned.md .kiro/memory/lessons_learned.md
cp .kiro/memory-templates/pattern_registry.md .kiro/memory/pattern_registry.md
cp .kiro/memory-templates/project_context.md .kiro/memory/project_context.md
```

| File | What it does |
|------|-------------|
| `project_context.md` | Your module map, service relationships, environment architecture |
| `lessons_learned.md` | Grows automatically as agents discover patterns |
| `pattern_registry.md` | Grows automatically as you diagnose issues |
| `cognitive-memory-protocol.md` | **Don't edit** — this is the protocol definition (already in `.kiro/memory/`) |

These files start empty. They fill up as you use the pipeline — the Shared Brain hook auto-appends after every Reviewer report.

---

## 5. Run Your First Pipeline

1. Open Kiro IDE with this workspace
2. In chat, invoke the Expert agent with a Jira ticket:
   ```
   @QA-Expert-Agent Analyze ticket PROJ-123
   ```
3. The agent creates the folder structure and generates:
   - `1_Expert/logic_explanation.md`
   - `1_Expert/test_plan_PROJ-123.md`
   - `1_Expert/manual_input.md`
4. Review the outputs, then rename `test_plan_PROJ-123.md` → `test_plan_PROJ-123_OK.md`
5. The Validator hook triggers automatically

---

## 6. Folder Structure Created at Runtime

When you trigger the Expert agent, it creates:
```
{year}/Q{quarter}/Version {version}/PROJ-{TICKET} - {description}/
├── 1_Expert/       ← Test plan, logic analysis, manual input
├── 2_Validator/    ← Structured test cases, CSV export
├── 3_Evidence/     ← Screenshots, logs, API captures
├── 4_Reviewer/     ← Execution findings, closure report
└── 5_Snapshots/    ← Auto-backups before overwrites
```

---

## 7. Pipeline Flow

```
Expert → [Human Review] → Validator → [Human Review] → Export → Execute → Reviewer → Closure
                                                                              ↓
                                                                    (UNSTABLE → Remediation loop)
```

Every `→ [Human Review] →` gate uses the file-rename convention:
- `_PENDING.md` = agent draft, awaiting your review
- `_OK.md` = approved, triggers next stage
- `_UPDATED.md` = rejected with feedback, triggers revision

---

## 8. Customization Tips

- **Don't need AIO Tests?** Disable the server and skip the Exporter agent
- **Don't use Azure DevOps?** Disable the server — Expert will rely on Jira only
- **Want to add a custom agent?** Create a new `.json` in `.kiro/agents/`
- **Want to change hook behavior?** Edit files in `.kiro/hooks/`
- **Want to add domain knowledge?** Edit `.kiro/steering/product.md`

---

## 9. Troubleshooting

| Problem | Solution |
|---------|----------|
| MCP server won't connect | Run `uvx mcp-atlassian` manually to check for errors |
| Agent doesn't trigger | Check hook file patterns match your folder structure |
| Wrong folder structure | Verify `.kiro/steering/structure.md` matches your convention |
| Agent hallucinates | Add more context to `product.md` and `project_context.md` |
