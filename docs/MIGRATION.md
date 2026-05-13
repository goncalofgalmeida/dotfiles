# Pre-switch checklist (old Mac → new Mac)

Things to do **on the current machine** before handing it back, that this repo's setup script can't reproduce.

The Brewfile + dotfiles handle ~80% of a laptop switch. The other 20% is auth, state, and stuff that lives outside `$HOME` or that you genuinely shouldn't commit. This is that list.

Tick each item as you go. Better to over-prepare — once IT wipes the old machine, anything not captured here is gone.

## Phase 1 — Audit and refresh the repo

Make sure the repo on the old machine reflects what you actually use, so the new machine starts from an accurate baseline.

- [ ] `brew bundle dump --file=~/dotfiles/Brewfile --force` to refresh the Brewfile from currently-installed packages
- [ ] Review the diff — remove anything you don't actually use
- [ ] Update `zsh/zshrc` and `zsh/aliases` with any recent tweaks
- [ ] Commit and push everything

## Phase 2 — Secrets and credentials

**Do not commit any of these.** Move them by hand.

### SSH

Decision: generate a **fresh ed25519 key** on the new Mac. GitHub is the only place the key is used, so this is the only service that needs the new public key.

`setup-mac.sh` handles the generation:

1. It runs `ssh-keygen -t ed25519` if no key exists.
2. The public key is copied to the clipboard automatically.
3. Paste it at <https://github.com/settings/ssh/new>.
4. Verify: `ssh -T git@github.com`

Once the new key is working, remove the old key from <https://github.com/settings/keys>.

If you ever need to regenerate the key manually:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
pbcopy < ~/.ssh/id_ed25519.pub
```

### 1Password

- [ ] Confirm you can log in from another device (recovery in case sync fails)
- [ ] Have your Secret Key written down somewhere you'll have access to during migration

### Cloud / API credentials

- [ ] `~/.aws/credentials` and `~/.aws/config` — copy if needed
- [ ] `~/.config/gcloud/` — usually easier to just `gcloud auth login` again on the new machine
- [ ] `~/.kube/config` — copy if you have local clusters; re-fetch from cloud providers otherwise
- [ ] `~/.npmrc` if it contains private registry tokens
- [ ] `~/.netrc` if you use it
- [ ] Any `.env` files outside of repos (some tools store them in `~/.config/<tool>/`)

### Browser-stored passwords

- [ ] Make sure browser sync is on, or export passwords to 1Password

## Phase 3 — App data and config

### VS Code

- [ ] Turn on **Settings Sync** (Cmd+Shift+P → "Settings Sync: Turn On"). Syncs settings, keybindings, snippets, and extensions via your GitHub/Microsoft account
- [ ] Commit any project-level `.vscode/` settings to their repos

### Ghostty

- [ ] Confirm `ghostty/config` in the repo matches your current `~/Library/Application Support/com.mitchellh.ghostty/config`. If you've tweaked Ghostty recently, sync the changes into the repo and commit.

### Claude Code

- [ ] Confirm `claude/settings.json` in the repo matches your current `~/.claude/settings.json` (model + enabled plugins). Sync if needed and commit.
- [ ] Per-project `.claude/settings.local.json` files live in their repos — no action.

### Other apps with config worth preserving

- [ ] Raycast — export settings from app preferences
- [ ] Rectangle / window managers — export config
- [ ] iTerm2 (if used) — `~/Library/Preferences/com.googlecode.iterm2.plist`
- [ ] Any DB GUI tools (TablePlus, DBeaver) — export saved connections (sanitize passwords)

## Phase 4 — Project repos and local state

### Active repos

- [ ] List all repos you have locally that aren't pushed: `cd ~/dev && for d in */; do (cd "$d" && git status --porcelain && git log @{u}.. 2>/dev/null); done`
- [ ] Push all branches that matter, including WIP feature branches
- [ ] Check for stashed changes you care about: `for d in ~/dev/*/; do (cd "$d" && git stash list); done`
- [ ] Note the list of repos you'll re-clone on the new machine (save as `~/dotfiles/repos.txt` or similar)

### Local databases / Docker volumes

- [ ] Any seeded local databases you don't want to recreate: `pg_dump` / `mysqldump` to a file
- [ ] OrbStack volumes — list with `docker volume ls`; export anything important
- [ ] Note: most local DB state can be recreated from fixtures/seeds; only back up what's genuinely hard to reproduce

### Other state

- [ ] `~/Downloads/` — anything you want
- [ ] `~/Desktop/` — same
- [ ] `~/Documents/` — same
- [ ] Anywhere else you stash files outside of cloud sync

## Phase 5 — Know what's there

Run these to take a final inventory:

```bash
# Installed casks and formulas (compare to Brewfile)
brew bundle dump --file=/tmp/installed-brewfile --force
diff ~/dotfiles/Brewfile /tmp/installed-brewfile

# Globally installed npm packages
npm list -g --depth=0

# Globally installed Ruby gems
gem list

# Globally installed Python packages
pip list

# Things in /Applications not installed via Homebrew
ls /Applications
```

Add anything missing to the Brewfile, or note manual reinstalls separately.

## Phase 6 — Final sanity checks

- [ ] `git status` clean in `~/dotfiles`
- [ ] Latest changes pushed to GitHub
- [ ] You can log into your dotfiles repo from a browser (confirms it's actually on the remote)
- [ ] You have your 1Password Secret Key, GitHub recovery codes, and any 2FA backup codes accessible from another device
- [ ] You've signed in to iCloud somewhere else so you don't lock yourself out

## On the new Mac

When you arrive at the new Mac, follow [`README.md`](../README.md) for the setup. The plan is **fresh install, no Migration Assistant**: clone the dotfiles repo, run `setup-mac.sh`, do the manual auth steps, then walk through System Settings side-by-side with the old Mac.