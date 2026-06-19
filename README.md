<h3 align="center">
    bertini36/dotfiles 
</h3>
<p align="center">
My personal Mac setup and configurations
</p>

## 🚀 Setup

- Download code:

    ```bash
    git clone https://github.com/bertini36/dotfiles.git ~/.dotfiles/
    ```

- Brew packages installation:

    ```bash
    brew bundle --file=mac/Brewfile
    ```

    | Package | Description |
    |---|---|
    | [`bat`](https://github.com/sharkdp/bat) | `cat` with syntax highlighting |
    | [`eza`](https://github.com/eza-community/eza) | Modern `ls` replacement |
    | [`fzf`](https://github.com/junegunn/fzf) | Fuzzy finder for the terminal |
    | [`gh`](https://github.com/cli/cli) | GitHub CLI |
    | [`pre-commit`](https://github.com/pre-commit/pre-commit) | Git hook manager |
    | [`graphviz`](https://gitlab.com/graphviz/graphviz) | Graph visualization tools |
    | [`jq`](https://github.com/jqlang/jq) | JSON processor |
    | [`libmagic`](https://github.com/file/file) | File type detection library |
    | [`gotop`](https://github.com/xxxserxxx/gotop) | Terminal system monitor |
    | [`copilot-cli`](https://github.com/github/copilot-cli) | GitHub Copilot CLI (cask) |
    | [`mole`](https://github.com/tw93/Mole) | macOS disk space cleaner and system optimizer |
    | [`postgresql@18`](https://github.com/postgres/postgres) | PostgreSQL database |
    | [`pyenv`](https://github.com/pyenv/pyenv) | Python version manager |
    | [`uv`](https://github.com/astral-sh/uv) | Fast Python package manager |
    | [`python@3.14`](https://github.com/python/cpython) | Python interpreter |
    | [`tldr`](https://github.com/tldr-pages/tldr) | Simplified man pages with practical examples |
    | [`karabiner-elements`](https://github.com/pqrs-org/Karabiner-Elements) | Keyboard remapper (cask) |
    | [`fd`](https://github.com/sharkdp/fd) | Fast `find` replacement |
    | [`ripgrep`](https://github.com/BurntSushi/ripgrep) | Fast `grep` replacement |
    | [`semgrep`](https://github.com/semgrep/semgrep) | Static analysis (SAST) scanner |
    | [`gitleaks`](https://github.com/gitleaks/gitleaks) | Secret detection in git commits |
    | [`nvm`](https://github.com/nvm-sh/nvm) | Node version manager |
    | [`pnpm`](https://github.com/pnpm/pnpm) | Fast Node package manager |
    | [`claude`](https://claude.ai) | Anthropic Claude desktop app (cask) |
    | [`claude-code`](https://github.com/anthropics/claude-code) | Anthropic Claude CLI (cask) |
    | [`rtk`](https://github.com/rtk-ai/rtk) | CLI proxy that reduces LLM token consumption by 60-90% |
    | [`handy`](https://github.com/cjpais/Handy) | Speech-to-text utility |

- Extra configuration (not available through Brew):

    ```bash
    bash mac/config_extras.sh
    ```

    | Config | Description |
    |---|---|
    | `gitleaks` hook | Global git pre-commit hook for secret detection |

- Add fonts (`fonts/`) to `Font Book`
- Configure [Karabiner](https://karabiner-elements.pqrs.org/)
  - Change `Caps Lock` to `CMD + CTL + Option + Shift`
  - Map F4 to `CMD + Space` (Raycast)
- Install [Oh My ZSH](https://ohmyz.sh/)
  * Source `shell/.zshrc` from `~/.zshrc` so installer appends and machine-specific aliases stay out of the repo:

  ```bash
  echo 'source ~/.dotfiles/shell/.zshrc' > ~/.zshrc
  ```
  * Install plugins

    ```bash
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
    ```

- Install [Chrome](https://www.google.com/chrome/)
- Install [Youtube Music](https://music.youtube.com/) (as browser pwa)
- Install [WhatsApp](https://www.whatsapp.com/download)
- Install [Telegram](https://desktop.telegram.org/)
- Install [Slack](https://slack.com/intl/en-gb/downloads/mac)
- Install [Gemini](https://gemini.google/mac/)
- Install [Claude](https://claude.ai/)
- Install [Notion](https://www.notion.so/desktop)
- Install [Notion Calendar](https://www.notion.com/product/calendar)
- Install [Obsidian](https://obsidian.md/)
- Install [Jetbrains Toolbox](https://www.jetbrains.com/toolbox-app/) and [Pycharm](https://www.jetbrains.com/pycharm/)
- Install [Visual Studio Code](https://code.visualstudio.com/)
  * Install extensions:
    - [Container tools](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
    - [Dev containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
    - [Django](https://marketplace.visualstudio.com/items?itemName=batisteo.vscode-django)
    - [Github Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat)
    - [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
    - [Lark grammar syntax support](https://marketplace.visualstudio.com/items?itemName=lark-parser.lark)
    - [Markdown Preview Mermaid Support](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)
    - [Tokyo Night](https://marketplace.visualstudio.com/items?itemName=enkia.tokyo-night)
    - [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)
    - [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
    - [Ruff](https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff)
    - [shift shift](https://marketplace.visualstudio.com/items?itemName=ahebrank.shortcut-menu-bar)
    - [Tailwind CSS IntelliSense](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)
    - [Auto-interpreter for PEP723 (uv)](https://marketplace.visualstudio.com/items?itemName=nsarrazin.pep723-uv-interpreter)
- Install [Iterm2](https://iterm2.com/)
- Install [Docker](https://docs.docker.com/desktop/install/mac-install/)
- Install [Raycast](https://www.raycast.com/)
  * Disable Spotlight shortcut to enable Raycast one (System Preferences -> Keyboard -> Shortcuts -> Spotlight -> Uncheck `Show Spotlight search`)
  * Configure shortcuts following [keymap.md](docs/keymap.md)
- Install [Amphetamine](https://apps.apple.com/app/amphetamine/id937984704) and set it to keep the computer awake indefinitely

- Enable auto-focus: `defaults write com.apple.Terminal FocusFollowsMouse -bool true`
- Link the rest of configuration files (install Claude Code first so `~/.claude/` exists)

  ```bash
  ln -s ~/.dotfiles/git/.gitignore_global ~/.gitignore_global
  git config --global core.excludesfile ~/.gitignore_global

  ln -s ~/.dotfiles/editors/vim/.vimrc ~/.vimrc

  ln -s ~/.dotfiles/ai/claude/settings.json ~/.claude/settings.json
  ln -s ~/.dotfiles/ai/claude/statusline-command.sh ~/.claude/statusline-command.sh
  ln -s ~/.dotfiles/ai/claude/CLAUDE.md ~/.claude/CLAUDE.md
  ln -s ~/.dotfiles/ai/claude/RTK.md ~/.claude/RTK.md
  ln -s ~/.dotfiles/ai/claude/skills ~/.claude/skills
  ln -s ~/.dotfiles/ai/claude/rules ~/.claude/rules
  ln -s ~/.dotfiles/ai/claude/agents ~/.claude/agents
  ```

## 🧠 Claude Configuration

All Claude Code configuration lives under `ai/claude/` and is symlinked into `~/.claude/`.

> [!NOTE]
> Remote control is enabled via `remoteControlAtStartup` in the global settings.
> Each session auto-starts the bridge, so it can be driven from
> [claude.ai/code](https://claude.ai/code) or the Claude mobile app.

### Workflow

See `ai/claude/workflow.md` for detailed documentation of the development workflow using Claude, Superpowers, and the custom skills, agents, and rules defined in this repository.

### Skills

Reusable AI agent skills that Claude invokes autonomously when a task matches their description. Any skill can also be invoked explicitly as a slash command (`/skill-name`).

| Skill | Description |
|---|---|
| `audit` | Run a full production audit with the `code-reviewer` and `security-reviewer` agents |
| `create-pull-request` | Create a GitHub PR following project conventions using `gh` CLI |
| `end-feature` | Finalize a merged PR: switch to main, pull, remove the merged feature branch, and update the graphify graph |
| `ddd-patterns` | DDD entities, aggregate roots, value objects, repositories, domain services, and specifications |
| `django-patterns` | Django architecture, REST APIs with Pydantic, ORM best practices, caching, and signals |
| `grill-me` | Stress-test a plan or design by interviewing one question at a time across the decision tree |
| `langchain-architecture` | LangChain 1.x and LangGraph for agents, memory, and tool integration |
| `production-code-audit` | Deep-scan a codebase and transform it to production-grade quality |
| `python-code-style` | Python type safety, generics, protocols, and advanced type annotations |
| `review-branch` | Review current branch changes for quality and security |
| `save-session` | Save a high-density summary of the current session to `.claude_sessions.md` |
| `start-feature` | Start the feature development pipeline from `workflow.md` |
| `visual-plan` | Turn a text plan into an interactive visual plan with diagrams, file maps, annotated code, and open questions ([BuilderIO/skills](https://github.com/BuilderIO/skills), MIT) |
| `visual-recap` | Turn a PR, branch, or diff into a visual recap with file maps, API/schema summaries, and annotated diffs ([BuilderIO/skills](https://github.com/BuilderIO/skills), MIT) |
| `wiki-karpathy` | Initialize, ingest, query, and lint a Karpathy-style personal wiki inside an Obsidian vault |
| `writing-clearly` | Clear prose for docs, commits, error messages, and UI text |

> [!NOTE]
> `visual-plan` and `visual-recap` are Agent-Native Plan clients, not standalone
> skills. They run in **local-files mode** (`AGENT_NATIVE_PLANS_MODE=local-files`
> in the global settings): plans are written as local MDX and served from a
> localhost bridge, with no account or hosted database. They require
> [Node.js](https://nodejs.org) (the `@agent-native/core` CLI is fetched on
> demand via `npx`) and a Chromium-based browser to view rendered plans (Safari
> is blocked from the localhost bridge). To update them, re-pull the two folders
> from `BuilderIO/skills`.

#### Evals

Most skills have an `evals/evals.json` file that defines test cases to measure skill effectiveness. To run the evals, paste the following steps into your AI agent prompt.

1. Read the eval definitions in `ai/claude/skills/<skill>/evals/evals.json`
2. Generate outputs - run each eval prompt twice per skill (once with the skill loaded, once without) and save the results to `ai/claude/skills-workspace/iteration-1/<eval-id>/with_skill/outputs/` and `without_skill/outputs/`
3. Create `eval_metadata.json` - record the assertions from each eval's expectations array alongside references to the output files
4. Compare outputs in `with_skill/outputs/` vs `without_skill/outputs/`
5. Verify each assertion from `eval_metadata.json` against the corresponding output

### Agents

Specialized subagents that run in isolated context windows with restricted tools.

| Agent | Description |
|---|---|
| `code-reviewer` | Read-only production code audit with A-F graded report (architecture, security, performance, quality, testing) |
| `security-reviewer` | OWASP Top 10 and Django-specific security vulnerability scanner |
| `plan-evaluator` | Quality gate that scores implementation plans on 7 criteria with GO/NO-GO verdict |
| `pr-reviewer` | End-to-end PR review: audits diff, fetches open comments, applies fixes, commits, pushes, replies, resolves threads, and verifies CI |

### Rules

Path-scoped rules that load automatically only when working on matching files.

| Rule | Scope |
|---|---|
| `python` | `**/*.py` - Python 3.12+ conventions, ruff, uv, naming, imports |
| `django` | Django files (views, models, urls, admin, etc.) |
| `tests` | Test files - no comments, self-explanatory naming |
| `langchain` | LangChain/LangGraph files |

### 🔌 Claude Plugins

Plugins are split into two tiers to keep session context lean: a small global
set enabled for every session, and domain-specific plugins enabled only in the
projects that need them. All marketplaces are registered globally in
`extraKnownMarketplaces` of `ai/claude/settings.json`.

#### Global plugins

Enabled in `enabledPlugins` of the global settings:

| Plugin | Description |
|---|---|
| [`superpowers`](https://github.com/obra/superpowers) | Spec driven development (SDD) based on brainstorming, planning, subagent-driven execution, TDD, and code review skills |
| `skill-creator` | Create, modify, and benchmark custom skills, including eval runs and description optimization |
| [`context7`](https://github.com/upstash/context7) | Up-to-date documentation and code examples for any library |
| [`caveman`](https://github.com/JuliusBrussee/caveman) | Caveman-speak mode that cuts ~75% of output tokens while keeping technical accuracy |
| [`last30days`](https://github.com/mvanhorn/last30days-skill) | Research any topic across Reddit, X, YouTube, HN, Polymarket, and the web, scored by upvotes, likes, and real money |

#### Per-project plugins

Enable these in the project's `.claude/settings.json`:

| Plugin | Description |
|---|---|
| [`sentry-skills`](https://github.com/getsentry/skills) | Sentry engineering skills: PR writing, code review, Django patterns, security review, and more |
| [`notion`](https://github.com/makenotion/notion-mcp-server) | Read and manage Notion pages and databases |
| [`figma`](https://github.com/figma/mcp-server-guide) | Read Figma designs and generate code from them |
| `atlassian` | Jira and Confluence: issues, backlogs, status reports, and knowledge search |
| `datadog-mcp` | Datadog observability: logs, metrics, traces, incidents, monitors, and dashboards |

```json
{
  "enabledPlugins": {
    "figma@claude-plugins-official": true,
    "sentry-skills@sentry-skills": true
  }
}
```

#### Installing and updating

On a fresh machine, install the third-party plugins (the marketplaces are
already registered through the tracked settings):

```bash
claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman

claude plugin marketplace add mvanhorn/last30days-skill
claude plugin install last30days@last30days-skill
```

`datadog-mcp` is an MCP server rather than a plugin; install it with:

```bash
claude mcp add --transport http datadog-mcp https://mcp.datadoghq.eu/api/unstable/mcp-server/mcp
```

To update everything, ask Claude in a session: `Update installed plugins`.

### 🧰 Companion Tools

CLI tools that complement Claude Code. They are installed outside the plugin
system but configured from this repository.

#### rtk

[rtk](https://github.com/rtk-ai/rtk) proxies common dev commands and strips
their output down to what the model needs (60-90% token savings). A
`PreToolUse` hook in the global settings rewrites Bash commands through it
transparently. Activate with:

```bash
rtk init -g
```

#### graphify

[graphify](https://github.com/safishamsi/graphify) turns any folder of code,
docs, or papers into a queryable knowledge graph, exposed as the `/graphify`
skill:

```bash
uv tool install graphifyy   # PyPI package is graphifyy; the CLI is graphify
graphify install
```

`graphify install` generates the skill in `~/.claude/skills/graphify/` and
registers it in `~/.claude/CLAUDE.md`. The skill directory is tool-managed,
so it is gitignored; only the `CLAUDE.md` registration is tracked.

<br />
<p align="center">Built with ❤️ from Mallorca</p>