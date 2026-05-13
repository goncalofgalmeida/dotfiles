# dotfiles

My personal macOS development environment, fully reproducible from this repo.

Apps, CLI tools, shell, Git, and editor config — installable with a single script.

## What's inside

| Path | Purpose |
|------|---------|
| `Brewfile` | All CLI tools, apps, and VS Code extensions |
| `setup-mac.sh` | One-shot installer for a new Mac |
| `zsh/zshrc` | Zsh config (prompt, history, plugins) |
| `zsh/aliases` | Shell aliases |
| `zsh/zshrc.local.example` | Template for per-machine shell config |
| `git/gitconfig` | Universal Git config (no personal info) |
| `git/gitignore_global` | Global Git ignore patterns |
| `git/gitconfig.local.example` | Template for personal Git identity |
| `ghostty/config` | Ghostty terminal config |
| `claude/settings.json` | Claude Code global settings |
| `repos.txt` | List of repos to clone on a new Mac |
| `docs/MIGRATION.md` | Pre-switch checklist for the **old** machine |

Personal info (name, email) lives in `~/.gitconfig.local`, which is **not** committed.
Machine-specific shell tweaks live in `~/.zshrc.local`, also not committed.

## Setting up a new Mac

### 1. Install Xcode Command Line Tools

```bash
xcode-select --install
```

Wait for the GUI installer to finish before continuing.

### 2. Clone this repo

```bash
git clone https://github.com/goncalofgalmeida/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Run the setup script

```bash
./setup-mac.sh
```

The script will:

- Install Homebrew
- Install everything from the `Brewfile` (CLI tools, casks, VS Code extensions)
- Symlink dotfiles into `$HOME`
- Generate an SSH key (if one doesn't exist) and copy the public key to your clipboard
- Prompt you for name + email to create `~/.gitconfig.local`

It's idempotent — safe to re-run.

### 4. Add your SSH key to GitHub

The setup script copies your public key to the clipboard. Paste it at:
<https://github.com/settings/ssh/new>

Verify:

```bash
ssh -T git@github.com
```

### 5. Install language runtimes

These aren't installed by default — pick what you need:

```bash
# Node (via fnm)
fnm install --lts
fnm default lts-latest

# Ruby (via rbenv)
rbenv install 3.3.0   # or whatever version you need
rbenv global 3.3.0

# Python (via pyenv, if installed)
pyenv install 3.12.0
pyenv global 3.12.0
```

For per-project versions, drop a `.nvmrc` / `.ruby-version` / `.python-version` in the repo root and `fnm`/`rbenv`/`pyenv` will switch automatically when you `cd` in.

### 6. Manual steps the script can't automate

These need to be done by hand. See [`docs/MIGRATION.md`](docs/MIGRATION.md) for the full inventory if migrating from an existing machine.

- **1Password** — sign in to the desktop app and CLI (`op signin`)
- **GitHub CLI** — `gh auth login`
- **gcloud** — `gcloud auth login` and `gcloud auth application-default login`
- **VS Code** — turn on Settings Sync (Cmd+Shift+P → "Settings Sync: Turn On") to pull keybindings/snippets
- **Claude Code** — re-authenticate; copy any global `~/.claude/settings.json` if you version it
- **Slack / browser / email apps** — sign in normally
- **Work VPN, certificates, SSO** — follow your org's onboarding
- **System preferences** — Dock, trackpad, key repeat, Finder hidden files, etc.

### 7. Verify

```bash
brew doctor                  # Homebrew is healthy
which docker                 # should point to OrbStack
echo $SHELL                  # /bin/zsh
git config user.email        # your work email (from ~/.gitconfig.local)
```

## Day-to-day

### Keeping things updated

```bash
brew update && brew upgrade
brew bundle cleanup --file=~/dotfiles/Brewfile --dry-run  # preview what would be removed (installed but not in Brewfile)
```

### Adding a new tool

1. Add the line to `Brewfile`
2. `brew bundle --file=~/dotfiles/Brewfile`
3. Commit and push

### Editing config

Files in `~` are symlinks into this repo — edit either side, they're the same file:

```bash
code ~/.zshrc                    # same as editing ~/dotfiles/zsh/zshrc
```

After editing zsh config, reload:

```bash
source ~/.zshrc
```

## Structure

```
~/dotfiles/
├── README.md
├── Brewfile
├── setup-mac.sh
├── repos.txt
├── .gitignore
├── zsh/
│   ├── zshrc
│   ├── aliases
│   └── zshrc.local.example
├── git/
│   ├── gitconfig
│   ├── gitignore_global
│   └── gitconfig.local.example
├── ghostty/
│   └── config
├── claude/
│   └── settings.json
└── docs/
    └── MIGRATION.md
```

## License

Personal config. Use anything that's useful to you.
