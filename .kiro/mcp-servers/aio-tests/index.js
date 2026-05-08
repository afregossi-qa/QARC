import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const API_TOKEN = process.env.AIO_API_TOKEN;
const PROJECT_KEY = process.env.AIO_PROJECT_KEY || "QUPOS";
const BASE_URL = "https://tcms.aiojiraapps.com/aio-tcms/api/v1";

const headers = {
  "Authorization": `AioAuth ${API_TOKEN}`,
  "Content-Type": "application/json",
  "Accept": "application/json"
};

async function aioFetch(path, options = {}) {
  const url = `${BASE_URL}${path}`;
  const res = await fetch(url, { headers, ...options });
  const text = await res.text();
  if (!res.ok) {
    return { error: true, status: res.status, statusText: res.statusText, body: text };
  }
  try { return JSON.parse(text); } catch { return { raw: text }; }
}

const server = new McpServer({ name: "aio-tests", version: "1.0.0" });

// --- Tool: get_project_config ---
server.tool(
  "get_project_config",
  "Get AIO Tests project configuration (statuses, priorities, folders, tags, etc.)",
  { projectKey: z.string().optional().describe("Jira project key (defaults to AIO_PROJECT_KEY env var)") },
  async ({ projectKey }) => {
    const key = projectKey || PROJECT_KEY;
    const result = await aioFetch(`/project/${key}/config`);
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  }
);

// --- Tool: get_folders ---
server.tool(
  "get_folders",
  "Get the folder tree for test cases in a project",
  { projectKey: z.string().optional().describe("Jira project key") },
  async ({ projectKey }) => {
    const key = projectKey || PROJECT_KEY;
    const result = await aioFetch(`/project/${key}/testcase/folder`);
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  }
);

// --- Tool: list_cases ---
server.tool(
  "list_cases",
  "Get a paginated list of test cases for the project",
  {
    projectKey: z.string().optional().describe("Jira project key"),
    page: z.number().optional().describe("Page number (0-based, default 0)"),
    pageSize: z.number().optional().describe("Page size (default 20)")
  },
  async ({ projectKey, page, pageSize }) => {
    const key = projectKey || PROJECT_KEY;
    const p = page ?? 0;
    const s = pageSize ?? 20;
    const result = await aioFetch(`/project/${key}/testcase?page=${p}&pageSize=${s}`);
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  }
);

// --- Tool: get_case ---
server.tool(
  "get_case",
  "Get details of a specific test case by its key",
  {
    projectKey: z.string().optional().describe("Jira project key"),
    caseKey: z.string().describe("Test case key (e.g., QUPOS-TC-123)")
  },
  async ({ projectKey, caseKey }) => {
    const key = projectKey || PROJECT_KEY;
    const result = await aioFetch(`/project/${key}/testcase/${caseKey}/detail`);
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  }
);

// --- Tool: search_cases ---
server.tool(
  "search_cases",
  "Search test cases by title, folder, tags, or other criteria",
  {
    projectKey: z.string().optional().describe("Jira project key"),
    title: z.string().optional().describe("Search by title (partial match)"),
    folderID: z.number().optional().describe("Filter by folder ID"),
    page: z.number().optional().describe("Page number (0-based)"),
    pageSize: z.number().optional().describe("Page size (default 20)")
  },
  async ({ projectKey, title, folderID, page, pageSize }) => {
    const key = projectKey || PROJECT_KEY;
    const params = new URLSearchParams();
    if (title) params.set("title", title);
    if (folderID !== undefined) params.set("folderID", String(folderID));
    params.set("page", String(page ?? 0));
    params.set("pageSize", String(pageSize ?? 20));
    const result = await aioFetch(`/project/${key}/testcase/search?${params}`);
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  }
);

// --- Tool: create_case ---
server.tool(
  "create_case",
  "Create a new test case in AIO Tests",
  {
    projectKey: z.string().optional().describe("Jira project key"),
    title: z.string().describe("Test case title"),
    description: z.string().optional().describe("Test case description/objective"),
    precondition: z.string().optional().describe("Preconditions text"),
    priority: z.string().optional().describe("Priority name (e.g., Critical, High, Medium)"),
    automationStatus: z.string().optional().describe("Automation status (e.g., To Be Automated, Manual)"),
    folderID: z.number().optional().describe("Folder ID to place the case in"),
    jiraTicket: z.string().optional().describe("Jira issue key to link (e.g., POS-9970)"),
    tags: z.array(z.string()).optional().describe("Array of tag names"),
    steps: z.array(z.object({
      step: z.string().describe("Step action description"),
      expectedResult: z.string().optional().describe("Expected result for this step")
    })).optional().describe("Array of test steps")
  },
  async ({ projectKey, title, description, precondition, priority, automationStatus, folderID, jiraTicket, tags, steps }) => {
    const key = projectKey || PROJECT_KEY;
    const body = { title, scriptType: { name: "Classic" } };
    if (description) body.description = description;
    if (precondition) body.precondition = precondition;
    if (priority) body.priority = { name: priority };
    if (automationStatus) body.automationStatus = { name: automationStatus };
    if (folderID) body.folder = { ID: folderID };
    if (jiraTicket) body.jiraIssueKey = jiraTicket;
    if (tags && tags.length > 0) body.tags = tags.map(t => ({ name: t }));
    if (steps && steps.length > 0) {
      body.steps = steps.map((s, i) => ({
        step: s.step,
        expectedResult: s.expectedResult || "",
        order: i + 1,
        stepType: "TEXT"
      }));
    }
    const result = await aioFetch(`/project/${key}/testcase`, {
      method: "POST",
      body: JSON.stringify(body)
    });
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  }
);

// --- Tool: update_case ---
server.tool(
  "update_case",
  "Update an existing test case in AIO Tests (title, description, steps, etc.). Note: tags and Jira linking are NOT supported by the AIO REST API — use the UI or CSV import for those.",
  {
    projectKey: z.string().optional().describe("Jira project key"),
    caseKey: z.string().describe("Test case key (e.g., POS-TC-8879)"),
    title: z.string().optional().describe("New title"),
    description: z.string().optional().describe("New description"),
    precondition: z.string().optional().describe("New preconditions"),
    priority: z.string().optional().describe("Priority name (e.g., Critical, High, Medium)"),
    automationStatus: z.string().optional().describe("Automation status"),
    folderID: z.number().optional().describe("Folder ID to move the case to"),
    steps: z.array(z.object({
      step: z.string(),
      expectedResult: z.string().optional()
    })).optional().describe("Array of test steps (replaces existing steps)")
  },
  async ({ projectKey, caseKey, title, description, precondition, priority, automationStatus, folderID, steps }) => {
    const key = projectKey || PROJECT_KEY;

    // GET existing case first (PUT is a full replace, omitted fields get wiped)
    const existing = await aioFetch(`/project/${key}/testcase/${caseKey}/detail`);
    if (existing.error) {
      return { content: [{ type: "text", text: `Failed to fetch existing case: ${JSON.stringify(existing, null, 2)}` }] };
    }

    // Build full payload by merging existing data with caller's changes
    const body = {
      title: title || existing.title,
      scriptType: existing.scriptType || { name: "Classic" }
    };

    // Merge each field: use caller's value if provided, otherwise keep existing
    body.description = description !== undefined ? description : (existing.description || "");
    body.precondition = precondition !== undefined ? precondition : (existing.precondition || "");
    body.priority = priority ? { name: priority } : (existing.priority || undefined);
    body.automationStatus = automationStatus ? { name: automationStatus } : (existing.automationStatus || undefined);
    body.folder = folderID ? { ID: folderID } : (existing.folder || undefined);
    body.status = existing.status || undefined;
    body.caseType = existing.caseType || undefined;

    if (steps) {
      body.steps = steps.map((s, i) => ({
        step: s.step,
        expectedResult: s.expectedResult || "",
        order: i + 1,
        stepType: "TEXT"
      }));
    } else if (existing.steps) {
      body.steps = existing.steps;
    }

    const result = await aioFetch(`/project/${key}/testcase/${caseKey}/detail`, {
      method: "PUT",
      body: JSON.stringify(body)
    });
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  }
);

// --- Tool: link_jira_issue ---
// NOTE: The AIO Tests REST API does NOT expose an endpoint for linking Jira issues to test cases.
// This tool is kept for future compatibility if AIO adds the endpoint.
// For now, Jira linking must be done via the AIO Tests UI or CSV import.
server.tool(
  "link_jira_issue",
  "Link a Jira issue/requirement to an existing test case. WARNING: This endpoint is not currently supported by the AIO REST API — use the AIO Tests UI or CSV import instead.",
  {
    projectKey: z.string().optional().describe("Jira project key"),
    caseKey: z.string().describe("Test case key (e.g., POS-TC-8879)"),
    jiraIssueKey: z.string().describe("Jira issue key to link (e.g., POS-9970)")
  },
  async ({ projectKey, caseKey, jiraIssueKey }) => {
    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          error: true,
          message: "The AIO Tests REST API does not currently support linking Jira issues to test cases. This must be done via the AIO Tests UI in Jira or through CSV import with the Requirements column. See: https://aiosupport.atlassian.net/wiki/spaces/AioTests/pages/2025619567/Rest+APIs"
        }, null, 2)
      }]
    };
  }
);

// --- Tool: probe_api ---
server.tool(
  "probe_api",
  "Debug tool: probe an arbitrary AIO API endpoint to discover available endpoints",
  {
    path: z.string().describe("API path after base URL (e.g., /project/POS/testcase/POS-TC-8879/tag)"),
    method: z.string().optional().describe("HTTP method (GET, POST, PUT, DELETE). Default: GET"),
    body: z.string().optional().describe("JSON body string for POST/PUT requests")
  },
  async ({ path, method, body }) => {
    const opts = { method: method || "GET" };
    if (body) opts.body = body;
    const result = await aioFetch(path, opts);
    return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
  }
);

// --- Tool: create_cases_bulk ---
server.tool(
  "create_cases_bulk",
  "Create multiple test cases at once from a structured array",
  {
    projectKey: z.string().optional().describe("Jira project key"),
    cases: z.array(z.object({
      title: z.string(),
      description: z.string().optional(),
      precondition: z.string().optional(),
      priority: z.string().optional(),
      automationStatus: z.string().optional(),
      folderID: z.number().optional(),
      jiraTicket: z.string().optional(),
      tags: z.array(z.string()).optional(),
      steps: z.array(z.object({
        step: z.string(),
        expectedResult: z.string().optional()
      })).optional()
    })).describe("Array of test case objects to create")
  },
  async ({ projectKey, cases }) => {
    const key = projectKey || PROJECT_KEY;
    const results = [];
    for (const tc of cases) {
      const body = { title: tc.title, scriptType: { name: "Classic" } };
      if (tc.description) body.description = tc.description;
      if (tc.precondition) body.precondition = tc.precondition;
      if (tc.priority) body.priority = { name: tc.priority };
      if (tc.automationStatus) body.automationStatus = { name: tc.automationStatus };
      if (tc.folderID) body.folder = { ID: tc.folderID };
      if (tc.jiraTicket) body.jiraIssueKey = tc.jiraTicket;
      if (tc.tags && tc.tags.length > 0) body.tags = tc.tags.map(t => ({ name: t }));
      if (tc.steps && tc.steps.length > 0) {
        body.steps = tc.steps.map((s, i) => ({
          step: s.step,
          expectedResult: s.expectedResult || "",
          order: i + 1,
          stepType: "TEXT"
        }));
      }
      const result = await aioFetch(`/project/${key}/testcase`, {
        method: "POST",
        body: JSON.stringify(body)
      });
      results.push({ title: tc.title, result });
    }
    return { content: [{ type: "text", text: JSON.stringify(results, null, 2) }] };
  }
);

// Start the server
const transport = new StdioServerTransport();
await server.connect(transport);
