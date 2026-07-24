# My keymap

## System (CMD based)

* Screen brightness down/up `F1` and `F2`
* Mission CTL `F3`
* Dictation `F5`
* Play/Pause, Previous and Next track `F6`, `F7` and `F8`
* Mute, Volume up and Volume down `F9`, `F10` and `F11`
* Close app `CMD + Q`
* Close tab `CMD + W`
* App settings `CMD + ,`
* See hidden files `CMD + Shift + .`
* Open settings `CMD + ,`
* Change keyboard layout `CTL + Space`

## Raycast (Caps Lock based)

* Open Raycast `F4` or `CMD + Space`
* Open Raycast settings `CMD + ,`
* Emojis `Caps Lock + E`
* Browser `Caps Lock + B`
* Youtube Music `Caps Lock + M`
* Visual Studio Code `Caps Lock + C`
* Terminal `Caps Lock + T`
* Notion `Caps Lock + N`
* Calendar `Caps Lock + S`
* WhatsApp `Caps Lock + W`
* Granola `Caps Lock + G`
* Claude `Caps Lock + I`
* Open Downloads `Caps Lock + D`
* Pomodoro `Caps Lock + O`
* DeepL `Caps Lock + L`
* Keep `Caps Lock + K`
* Left half of the screen `Caps Lock + ←`
* Bottom half of the screen `Caps Lock + ↓`
* Top half of the screen `Caps Lock + ↑`
* Right half of the screen `Caps Lock + →`
* Maximize `Caps Lock + Enter`

## Handy

* Keep `OPT + Shift` for transcript

## Other Raycast useful CMDs without shortcut

* Kill process (plugin)
* Translate (plugin)

## Browser (CMD based)

* Open new tab `CMD + T`
* Close tab `CMD + W`
* Reopen last tab `CMD + Shift + T`
* Open new window `CMD + N`
* Close window `CMD + Shift + W`
* Next tab `CMD + →`
* Previous tab `CMD + ←`
* Open link in new tab `CMD + Click`
* Open link in new window `CMD + Shift + Click`
* Move cursor to address bar `CMD + L`

## Readline (CTL based)

* Move cursor to beginning of line `CTL + A`
* Move cursor to end of line `CTL + E`
* Move cursor one word left `CTL + B`
* Move cursor one word right `CTL + F`
* Delete one word left `CTL + W`
* Delete line `CTL + X`
* Duplicate line `CTL + D`

## Terminal (CMD based)

* Vertical split `CTL + Shift + E`
* Horizontal split `CTL + Shift + O`
* Clean screen `CTL + L`
* Close tab `CMD + W`
* Create new tab `CMD + T`
* Open Shortcuts help `CMD + /`
* Activate right pane `CMD + Option + →`
* Activate left pane `CMD + Option + ←`
* Activate upper pane `CMD + Option + ↑`
* Activate lower pane `CMD + Option + ↓`
* Copy `CMD + C`
* Delete line `CMD + Backspace`

## IDE (CMD based)

* Vertical split `CTL + Shift + E`
* Horizontal split `CTL + Shift + O`
* Open actions `CMD + Shift + A`
* Search symbols `CMD + CTL + Shift + N`
* Find in file `CMD + F`
* Replace in file `CMD + R`
* Find in files `CMD + Shift + F`
* Clone caret above `CTL + Shift + ↑`
* Clone caret below `CTL + Shift + ↓`
* Delete file `Shift + Delete`
* Next word occurrence `CMD + N`
* Previous word occurrence `CMD + P`
* Find usages `CMD + Shift + 7`
* Expand method `CTL + +`
* Collapse method `CTL + -`
* Go to declaration `Command + Enter/click`
* Select file in project view `CTL + Shift + S`
* Copy file route `CTL + Shift + C`
* Open project view `CMD + 1`
* Add selection to next occurence `CMD + J`
* Commit `CTL + CMD + C`
* Push `CTL + CMD + U`
* Pull `CTL + CMD + P`
* Close left sidebar: `CMD + B`
* New file `CTL + Shift + N`
* New scratch file `CMD + CTL + N`
* Copilot chat `CMD + I`
* Next tab `CMD + →`
* Previous tab `CMD + ←`
* Fix current line `CMD + .`
* Open project `CMD + O`
* Open user settings file `CMD + Shift + ,`

## Claude

* `/mcp` → List and manage connected MCP servers
* `/model` → Choose between Anthropic models to serve your requests
* `/skills` → See project and local skills available
* `/context` → Visualize context usage in your current chat
* `/compact` → Reduce context usage when the context window fills up
* `/effort` → Toggle effort mode for more thorough responses
* `/goal <condition>` → Set a goal; Claude keeps working across turns until the condition is met. No argument shows the current goal, `/goal clear` removes it
* `/rename` -> Name the current session to resume it later with `claude --resume <session-name>`
* `/usage` -> Show token usage for the current session
* `/clear` -> Clear the current session
* `/btw` -> "By the way" - add a side note to the conversation without interrupting the main flow
* `!` -> Bash mode for executing shell commands directly from the chat
* `claude --resume` -> Resume a previous session
* `claude --dangerously-skip-permissions` → Bypass all safety checks and permissions
* `claude --worktree` → Enable automatic git worktree creation for each new conversation

### Repo skills (invoke with `/skill-name`)

* `/start-feature` → Start the feature development pipeline (brainstorm, plan, grill, evaluate, implement, verify, review, PR)
* `/grill-me` → Get interviewed about a plan or design until reaching shared understanding
* `/fix-until-green` → Loop project checks and pre-commit, fixing each failure until everything passes
* `/review-branch` → Review current branch changes for quality and security
* `/create-pull-request` → Create a GitHub PR following project conventions and the repo template
* `/end-feature` → Finalize a merged PR: switch to main, pull, delete the feature branch locally and remotely
* `/save-session` → Save a high-density summary of the current session to `.claude_sessions.md`
* `/tldr <url>` → Quick bullet summary of an article, blog post, YouTube video, or web page
* `/investigate-sentry <issue>` → Root-cause a Sentry exception and propose a fix
* `/audit` → Run a full production audit on the current project

## Vim 

* `gg` → Go to the beginning of the file
* `dG` → Delete from the current line to the end of the file