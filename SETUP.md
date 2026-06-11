# QARC Setup Guide

How to adapt this framework to your project using Claude Code.

---

## 1. Prerequisites

- [Claude Code](https://claude.ai/code) — CLI, desktop app, or VS Code/JetBrains extension
- [uv](https://docs.astral.sh/uv/getting-started/installation/) — Python package runner (for Atlassian MCP server)
- [Node.js](https://nodejs.org/) — runs the AIO Tests MCP server and Azure DevOps MCP
- [.NET SDK 8.0+](https://dotnet.microsoft.com/download) — required for the LiteDB evidence reader (`Tools/LiteDbReader`)
- A Jira project with tickets to test
- (Optional) AIO Tests for test case management
- (Optional) Azure DevOps for PR review integration

---

## 2. Configure MCP Servers

MCP credentials must go in `.claude/settings.local.json` (this file is gitignored — never commit credentials).

Create `.claude/settings.local.json`:

```json
{
  "mcpServers": {
    "atlassian": {
      "env": {
        "CONFLUENCE_URL": "https://your-org.atlassian.net",
        "CONFLUENCE_USERNAME": "your.email@your-org.com",
        "CONFLUENCE_API_TOKEN": "YOUR_ATLASSIAN_API_TOKEN_HERE",
        "JIRA_URL": "https://your-org.atlassian.net",
        "JIRA_USERNAME": "your.email@your-org.com",
        "JIRA_API_TOKEN": "YOUR_ATLASSIAN_API_TOKEN_HERE"
      }
    },
    "azure-devops": {
      "disabled": false,
      "args": ["-y", "@azure-devops/mcp", "YOUR_ORG_NAME"],
      "env": {
        "AZURE_DEVOPS_ORGANIZATION": "https://your-org.visualstudio.com",
        "AZURE_DEVOPS_PAT": "YOUR_AZURE_DEVOPS_PAT_HERE"
      }
    },
    "aio-tests": {
      "env": {
        "AIO_API_TOKEN": "YOUR_AIO_API_TOKEN_HERE",
        "AIO_PROJECT_KEY": "YOUR_PROJECT_KEY"
      }
    }
  }
}
```

| Server | Credential | Where to get it |
|--------|-----------|-----------------|
| Atlassian | API Token | [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens) |
| Azure DevOps | PAT | Azure DevOps → User Settings → Personal Access Tokens (Code Read scope) |
| AIO Tests | API Token | AIO Tests → Settings → API |

**Disable servers you don't use** by setting `"disabled": true` in `.claude/settings.json`.

**Install the Atlassian MCP server:**
```bash
pip install uv   # or: brew install uv
uvx mcp-atlassian --help  # verify it works
```

**Install the AIO Tests MCP server:**
```bash
cd .kiro/mcp-servers/aio-tests
npm install
```

---

## 3. Customize Steering Files

These files teach the agents about YOUR project. Edit them before running your first ticket:

| File | Purpose | Priority |
|------|---------|----------|
| `.kiro/steering/product.md` | Your product's domain, features, business concepts | **High** |
| `.kiro/steering/tech.md` | Your tech stack, API patterns, test commands | **High** |
| `.kiro/steering/structure.md` | Folder conventions (usually fine as-is) | Low |

---

## 4. Initialize Memory

The Shared Brain uses a structured memory layout. Copy templates to create your working memory:

```bash
# Create the memory folder structure
mkdir -p .kiro/memory/universal
mkdir -p .kiro/memory/products/your-product
mkdir -p .kiro/memory/platform/your-platform

# Copy templates
cp .kiro/memory-templates/universal/*.md .kiro/memory/universal/
cp .kiro/memory-templates/products/pos/*.md .kiro/memory/products/your-product/
```

Then update `.kiro/steering/shared-brain.md` to point to your product folder by replacing `pos` with your product name.

| File | What it does |
|------|-------------|
| `universal/` | Cross-product knowledge — shared across all projects |
| `products/{name}/project_context.md` | Your module map, service relationships, architecture |
| `products/{name}/lessons_learned.md` | Grows automatically as agents discover patterns |
| `products/{name}/pattern_registry.md` | Grows automatically as you diagnose issues |

These files start near-empty. They fill as you use the pipeline — the LEARN phase of each slash command auto-appends after every agent run.

---

## 5. Add .gitignore entries

```bash
cat >> .gitignore << 'EOF'

# QARC — local credentials
.claude/settings.local.json

# QARC — runtime memory (optional: commit if you want shared learning)
# .kiro/memory/
EOF
```

---

## 6. Run Your First Pipeline

1. Open Claude Code in this workspace
2. Type `/qa-expert` and press Enter
3. Provide your Jira ticket ID and sprint version when asked
4. The agent creates the folder structure and generates:
   - `1_Expert/logic_explanation.md`
   - `1_Expert/test_plan_PENDING.md`
   - `1_Expert/manual_input.md`
5. Review the outputs, then rename `test_plan_PENDING.md` → `test_plan_OK.md`
6. Run `/qa-validate` to trigger the Validator

See `ONBOARDING.md` for the full step-by-step walkthrough.

---

## 7. Folder Structure Created at Runtime

```
{year}/Q{quarter}/Version {version}/PROJ-{TICKET} - {description}/
├── 1_Expert/       ← Test plan, logic analysis, manual input
├── 2_Validator/    ← Structured test cases, CSV export
├── 3_Evidence/     ← Screenshots, logs, API captures
├── 4_Reviewer/     ← Execution findings, closure report
└── 5_Snapshots/    ← Auto-backups before overwrites
```

---

## 8. Customization Tips

- **Don't need AIO Tests?** Set `"disabled": true` for `aio-tests` in `.claude/settings.json` and skip `/qa-export-aio`
- **Don't use Azure DevOps?** Leave it `disabled: true` — Expert will rely on Jira only
- **Want to add a custom slash command?** Create a new `.md` in `.claude/commands/`
- **Want to change hook behavior?** Edit scripts in `.claude/hooks/`
- **Want to add domain knowledge?** Edit `.kiro/steering/product.md`

---

## 9. Troubleshooting

| Problem | Solution |
|---------|----------|
| MCP server won't connect | Run `uvx mcp-atlassian` manually to check for errors |
| Slash command not found | Verify the file is in `.claude/commands/` with a `.md` extension |
| Hook not firing | Check that hook scripts are executable: `chmod +x .claude/hooks/*.sh` |
| Wrong folder structure | The `enforce-folder-structure` hook will block bad writes; check the error message |
| Agent hallucinates | Add more context to `product.md` and `project_context.md` |
| Snapshot not created | Verify `5_Snapshots/` exists in the ticket folder (or let the hook create it) |
