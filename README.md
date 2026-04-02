# Claude Skills Kit

**Skill framework that teaches Claude Code your team's rules — not the other way around.**

Claude Code is powerful, but out of the box it doesn't know your coding standards, architecture patterns, review checklists, or deployment workflows. Claude Skills Kit bridges that gap.

> Your conventions. Your workflow. Claude just follows.

[![한국어](https://img.shields.io/badge/lang-한국어-blue)](README.ko.md)

---

## Why Claude Skills Kit?

### Convention-first

Same `code-reviewer` agent behaves differently per project:
- In a Spring Boot project → checks jOOQ usage, hexagonal boundaries, REST Docs
- In a React project → checks hooks rules, component structure, CSS modules

How? Agents read **your** `CLAUDE.md` and `docs/standards/` — not hardcoded rules.

### Built for existing codebases

Most AI coding tools assume you're starting from scratch. Real teams aren't.

Claude Skills Kit is designed for projects that already have:
- Established coding standards and architecture patterns
- Existing CI/CD pipelines and build systems
- Team conventions that must be followed, not reinvented
- Issue trackers (Jira, GitHub Issues) with ongoing work

### Full development lifecycle

```
/task analyze   → Convert specs to structured markdown (PPT, Google Docs, Confluence)
/task plan      → Generate planning doc (plan-analyst agent)
/task design    → Generate design doc (design-architect agent)
/task impl      → Implement code
/task review    → Parallel review (3 agents: code / architecture / test)
/task done      → Build verification + completion summary
/task e2e       → End-to-end API tests
```

### Issue tracker integration

```
/jira-task start     → Create branch, transition Jira issue
/jira-task plan~done → Same phases + Jira status sync & comments
/jira-task report    → Sprint status report
```

GitHub Issues and Linear integrations are planned.

### Standalone skills

Works inside or outside the workflow:

| Skill | Description |
|-------|-------------|
| `/analyze-spec` | Convert planning docs to structured MD (PPT, Google Slides/Docs/Sheets, Confluence) |
| `/db` | Local infrastructure management (Docker, DB, cache) |
| `/server` | Service start/stop/build/status |
| `/e2e-test` | E2E API testing (curl + Playwright) |
| `/cleanup-worktree` | Git worktree cleanup |

---

## How it works

### Agents = Role + Your Standards

```
Agent  =  Role (what to do)        ← shared (agents/)
        + Standards (how to judge)  ← your project (see below)
```

Agents read your project standards in this order:

```
1. CLAUDE.md                      ← Project overview, core patterns (~50 lines)
2. .claude/task-conventions.md    ← Per-phase conventions (~50 lines)
3. docs/standards/*.md            ← Detailed standards (if any)
4. Existing code (Glob/Grep)      ← Reference patterns
5. (nothing found) → General principles + ask the user
```

### Convention layering

CLAUDE.md stays under 200 lines by splitting into 3 layers:

| File | Role | Lines |
|------|------|-------|
| `CLAUDE.md` | Project overview + pointers | ~50 |
| `.claude/task-conventions.md` | Per-phase conventions (plan/design/impl/test/review) | ~50 |
| `docs/standards/*.md` | Detailed standards (coding, API, error handling, etc.) | as needed |

**New project?** Just write ~30 lines in CLAUDE.md. Conventions can be added later.

---

## Quick start

```bash
# One-liner — run from your project root
bash <(curl -sL https://raw.githubusercontent.com/AnSungWook/ClaudeSkillSet/main/setup.sh)
```

Or clone manually:

```bash
git clone https://github.com/AnSungWook/ClaudeSkillSet.git /tmp/claude-skills-kit
cd /path/to/your/project
bash /tmp/claude-skills-kit/setup.sh
```

The installer will:
1. Copy shared skills (analyze-spec, db, server, e2e-test)
2. Choose a workflow (task or jira-task) + copy agents
3. Generate `config.yaml` with your project root
4. Create artifact directories (docs/specs, plan, design, review, test, reports)
5. Generate `CLAUDE.md` + `task-conventions.md` templates

---

## Configuration

Edit `.claude/skills/config.yaml` for your project:

```yaml
project:
  name: "My Project"
  root: "/path/to/project"

workflow:
  type: task            # task | jira-task

server:
  modules:
    - name: api
      port: 8080
      start: "./gradlew bootRun"
      health: "http://localhost:8080/actuator/health"

infra:
  type: docker          # docker | none
  commands:
    up: "docker-compose up -d"
```

See [config.yaml](config.yaml) for full options.

---

## Project structure

```
claude-skills-kit/
├── config.yaml                       # Project settings (server, infra, paths)
├── setup.sh                          # Installer script
│
├── agents/                           # Shared agents (role only, standards come from your project)
│   ├── plan-analyst.md               #   Planning analysis (opus)
│   ├── design-architect.md           #   Design (opus)
│   ├── code-reviewer.md              #   Coding standards review (opus)
│   ├── architecture-reviewer.md      #   Architecture review (opus)
│   └── test-reviewer.md              #   Test conventions (sonnet)
│
├── skills/
│   ├── task/                         # Standalone task workflow (no issue tracker needed)
│   ├── analyze-spec/                 # Spec analysis
│   ├── server/                       # Server management
│   ├── db/                           # Infrastructure management
│   ├── e2e-test/                     # E2E testing
│   └── workflows/
│       └── jira-task/                # Jira integration (13 sub-skills)
│
├── commands/
│   └── cleanup-worktree.md           # Worktree cleanup
├── hooks/
│   └── guard-merge.sh                # Merge guard hook
│
├── templates/                        # Templates for CLAUDE.md, conventions, settings
└── docs/                             # Design docs and usage guides
```

---

## Workflows

### task (standalone — no issue tracker needed)

```
/task analyze → plan → design → impl → review → done → e2e
```

Each phase uses specialized agents (Opus for planning/review, Sonnet for implementation). Review runs 3 agents in parallel: code, architecture, and test.

### jira-task (plugin — requires Atlassian MCP)

```
/jira-task start → plan → design → impl → test → review → done
```

Same workflow as `task`, plus automatic Jira status transitions, issue comments, branch/PR management, and sprint reporting. Requires one of:

| MCP Server | Install |
|------------|---------|
| [sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian) (community, 4.8k stars) | `claude mcp add atlassian -- uvx mcp-atlassian --jira-url URL ...` |
| [atlassian/atlassian-mcp-server](https://github.com/atlassian/atlassian-mcp-server) (official) | `npx @anthropic-ai/create-mcp` |

13 sub-skills in [`skills/workflows/jira-task/`](skills/workflows/jira-task/) — see [Task Workflow Guide](docs/GUIDE-task-workflow.md) for details.

---

## Prerequisites

| Requirement | Used by | Install |
|-------------|---------|---------|
| python-pptx | analyze-spec | `pip install python-pptx` |
| LibreOffice | analyze-spec | `brew install --cask libreoffice` |
| Docker | db | Docker Desktop |
| Playwright MCP | e2e-test | Add `@playwright/mcp` to `.mcp.json` |
| Jira MCP | jira-task | `claude mcp add atlassian ...` |
| Google MCP | analyze-spec | Add to `.mcp.json` |

---

## Docs

- [Task Workflow Guide](docs/GUIDE-task-workflow.md) — Usage, convention paths, new project setup
- [Task Workflow Design](docs/DESIGN-task-workflow.md) — Architecture, detailed specs

---

## License

MIT
