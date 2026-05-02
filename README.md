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
    | [`gemini-cli`](https://github.com/google-gemini/gemini-cli) | Google Gemini AI CLI |
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
  * Link `shell/.zshrc` to `~/.zshrc`: `ln ~/.dotfiles/shell/.zshrc ~/.zshrc`
  * Install plugins

    ```bash
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
    ```

- Install [Raycast](https://www.raycast.com/)
  * Disable Spotlight shortcut to enable Raycast one (System Preferences -> Keyboard -> Shortcuts -> Spotlight -> Uncheck `Show Spotlight search`)
  * Configure shortcuts following [keymap.md](docs/keymap.md)
- Install [Iterm2](https://iterm2.com/)
- Install [Docker](https://docs.docker.com/desktop/install/mac-install/)
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

- Enable auto-focus: `defaults write com.apple.Terminal FocusFollowsMouse -bool true`
- Link the rest of configuration files (install Claude Code first so `~/.claude/` exists)

  ```bash
  ln -s ~/.dotfiles/git/.gitignore_global ~/.gitignore_global
  git config --global core.excludesfile ~/.gitignore_global

  ln -s ~/.dotfiles/editors/vim/.vimrc ~/.vimrc

  ln -s ~/.dotfiles/editors/claude/settings.json ~/.claude/settings.json
  ln -s ~/.dotfiles/editors/claude/statusline-command.sh ~/.claude/statusline-command.sh
  ln -s ~/.dotfiles/editors/claude/CLAUDE.md ~/.claude/CLAUDE.md
  ln -s ~/.dotfiles/editors/claude/skills ~/.claude/skills
  ln -s ~/.dotfiles/editors/claude/rules ~/.claude/rules
  ln -s ~/.dotfiles/editors/claude/agents ~/.claude/agents
  ln -s ~/.dotfiles/editors/claude/commands ~/.claude/commands
  ```

## 🧠 Claude Configuration

All Claude Code configuration lives under `editors/claude/` and is symlinked into `~/.claude/`.

### Workflow

See `editors/claude/workflow.md` for detailed documentation of the development workflow using Claude, Superpowers, and the custom skills, agents, rules, and commands defined in this repository.

### Skills

Reusable AI agent skills that Claude invokes autonomously when a task matches their description.

| Skill | Description |
|---|---|
| `create-pull-request` | Create a GitHub PR following project conventions using `gh` CLI |
| `ddd-patterns` | DDD entities, aggregate roots, value objects, repositories, domain services, and specifications |
| `django-patterns` | Django architecture, REST APIs with Pydantic, ORM best practices, caching, and signals |
| `langchain-architecture` | LangChain 1.x and LangGraph for agents, memory, and tool integration |
| `production-code-audit` | Deep-scan a codebase and transform it to production-grade quality |
| `python-code-style` | Python type safety, generics, protocols, and advanced type annotations |
| `writing-clearly` | Clear prose for docs, commits, error messages, and UI text |

#### Evals

Each skill has an `evals/evals.json` file that defines test cases to measure skill effectiveness. To run the evals paste the following command your AI agent prompt.

1. Read the eval definitions in `editors/claude/skills/<skill>/evals/evals.json`
2. Generate outputs - run each eval prompt twice per skill (once with the skill loaded, once without) and save the results to `editors/claude/skills-workspace/iteration-1/<eval-id>/with_skill/outputs/` and `without_skill/outputs/`
3. Create `eval_metadata.json` - record the assertions from each eval's expectations array alongside references to the output files
4. Compare outputs in `with_skill/outputs/` vs `without_skill/outputs/`
5. Verify each assertion from `eval_metadata.json` against the corresponding output

### Agents

Specialized subagents that run in isolated context windows with restricted tools.

| Agent | Description |
|---|---|
| `code-reviewer` | Read-only production code audit with A-F graded report (architecture, security, performance, quality, testing) |
| `security-reviewer` | OWASP Top 10 and Django-specific security vulnerability scanner |
| `evaluator` | Quality gate that scores implementation plans on 7 criteria with GO/NO-GO verdict |

### Rules

Path-scoped rules that load automatically only when working on matching files.

| Rule | Scope |
|---|---|
| `python` | `**/*.py` - Python 3.12+ conventions, ruff, uv, naming, imports |
| `django` | Django files (views, models, urls, admin, etc.) |
| `tests` | Test files - no comments, self-explanatory naming |
| `langchain` | LangChain/LangGraph files |

### Commands

Custom slash commands for common workflows.

| Command | Usage |
|---|---|
| `/review` | Review current branch changes for quality and security |
| `/fix-issue <number>` | Fetch a GitHub issue and implement the fix |
| `/audit` | Run full production audit with both agents |
| `/start-feature` | Start the feature development pipeline from `workflow.md` |

### 🔌 Claude Plugins

Install the following MCP server plugins in Claude:

| Plugin | Description |
|---|---|
| [`superpowers`](https://github.com/obra/superpowers) | Spec driven development (SDD) based on brainstorming, planning, subagent-driven execution, TDD, and code review skills |
| `skill-creator` | Create, modify, and benchmark custom skills, including eval runs and description optimization |
| [`context7`](https://github.com/upstash/context7) | Up-to-date documentation and code examples for any library |
| [`sentry-skills`](https://github.com/getsentry/skills) | Sentry engineering skills: PR writing, code review, Django patterns, security review, and more |
| [`caveman`](https://github.com/JuliusBrussee/caveman) | Caveman-speak mode that cuts ~75% of output tokens while keeping technical accuracy |
| [`notion`](https://github.com/makenotion/notion-mcp-server) | Read and manage Notion pages and databases |
| [`figma`](https://github.com/figma/mcp-server-guide) | Read Figma designs and generate code from them |
| [`claude-seo`](https://github.com/AgriciDaniel/claude-seo) | Comprehensive SEO: technical audit, E-E-A-T, schema, GEO/AEO, local SEO, backlinks, Google APIs, and PDF reporting |
| `datadog-mcp` | Datadog observability: logs, metrics, traces, incidents, monitors, and dashboards |

Install Datadog MCP:

```bash
claude mcp add --transport http datadog-mcp https://mcp.datadoghq.eu/api/unstable/mcp-server/mcp
```

Install Caveman:

```bash
claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman
```

Install [claude-seo](https://github.com/AgriciDaniel/claude-seo):

```bash
claude plugin marketplace add AgriciDaniel/claude-seo
claude plugin install claude-seo@AgriciDaniel-claude-seo
```

Activate [rtk](https://github.com/rtk-ai/rtk):

```bash
rtk init -g
```

<br />
<p align="center">Built with ❤️ from Mallorca</p>