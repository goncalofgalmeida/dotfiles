#!/usr/bin/env bash
#
# One-shot installer for a new Mac.
# Idempotent: safe to re-run.
#
# Steps:
#   1. Ensure Xcode Command Line Tools
#   2. Install Homebrew (Apple Silicon or Intel)
#   3. Run `brew bundle` from ./Brewfile
#   4. Symlink dotfiles into $HOME (backing up anything it replaces)
#   5. Prompt for Git identity, write ~/.gitconfig.local
#   6. Generate an ed25519 SSH key (if absent), copy pubkey to clipboard

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 1. Xcode Command Line Tools
# ---------------------------------------------------------------------------
ensure_xcode_clt() {
  if xcode-select -p &>/dev/null; then
    log "Xcode Command Line Tools already installed."
    return
  fi
  log "Installing Xcode Command Line Tools (a GUI installer will open)..."
  xcode-select --install
  die "Re-run this script once the Xcode CLT installer finishes."
}

# ---------------------------------------------------------------------------
# 2. Homebrew
# ---------------------------------------------------------------------------
ensure_homebrew() {
  if command -v brew &>/dev/null; then
    log "Homebrew already installed."
  else
    log "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    die "Homebrew installed but brew not found at /opt/homebrew/bin/brew."
  fi
}

# ---------------------------------------------------------------------------
# 3. Brewfile
# ---------------------------------------------------------------------------
run_brew_bundle() {
  if [[ ! -f "$DOTFILES/Brewfile" ]]; then
    warn "No Brewfile at $DOTFILES/Brewfile — skipping."
    return
  fi
  log "Installing packages from Brewfile..."
  brew bundle --file="$DOTFILES/Brewfile"
}

# ---------------------------------------------------------------------------
# 4. Symlinks (with backup)
# ---------------------------------------------------------------------------
link() {
  local src=$1 dst=$2

  if [[ ! -e "$src" ]]; then
    warn "Source missing, skipping: $src"
    return
  fi

  # Already linked correctly? Nothing to do.
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    return
  fi

  # Anything else at $dst gets moved to the backup directory.
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/"
    warn "Backed up existing $dst → $BACKUP_DIR/"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  log "Linked $dst → $src"
}

create_symlinks() {
  log "Creating symlinks..."
  link "$DOTFILES/zsh/zshrc"             "$HOME/.zshrc"
  link "$DOTFILES/zsh/aliases"           "$HOME/.aliases"
  link "$DOTFILES/git/gitconfig"         "$HOME/.gitconfig"
  link "$DOTFILES/git/gitignore_global"  "$HOME/.gitignore_global"
  link "$DOTFILES/ghostty/config"        "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  link "$DOTFILES/claude/settings.json"  "$HOME/.claude/settings.json"
}

# ---------------------------------------------------------------------------
# 5. Git identity → ~/.gitconfig.local
# ---------------------------------------------------------------------------
ensure_git_identity() {
  local local_cfg="$HOME/.gitconfig.local"
  if [[ -f "$local_cfg" ]]; then
    log "~/.gitconfig.local already exists — leaving it alone."
    return
  fi

  log "Creating ~/.gitconfig.local (name + email for commits)..."
  local git_name git_email
  read -r -p "  Git user.name:  " git_name
  read -r -p "  Git user.email: " git_email

  cat > "$local_cfg" <<EOF
[user]
    name = $git_name
    email = $git_email
EOF
  log "Wrote $local_cfg"

  # Stash the email so the SSH step can reuse it.
  GIT_EMAIL_FOR_SSH=$git_email
}

# ---------------------------------------------------------------------------
# 6. SSH key
# ---------------------------------------------------------------------------
ensure_ssh_key() {
  local key="$HOME/.ssh/id_ed25519"

  if [[ -f "$key" ]]; then
    log "SSH key already exists at $key."
  else
    log "Generating ed25519 SSH key..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    local ssh_email=${GIT_EMAIL_FOR_SSH:-}
    if [[ -z "$ssh_email" ]]; then
      read -r -p "  Email for SSH key comment: " ssh_email
    fi
    ssh-keygen -t ed25519 -C "$ssh_email" -f "$key" -N ""
  fi

  if command -v pbcopy &>/dev/null; then
    pbcopy < "${key}.pub"
    log "Public key copied to clipboard."
    log "Add it at: https://github.com/settings/ssh/new"
  fi
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
  ensure_xcode_clt
  ensure_homebrew
  run_brew_bundle
  create_symlinks
  ensure_git_identity
  ensure_ssh_key

  log "Done."
  echo
  echo "Next steps (manual):"
  echo "  1. Paste your SSH public key into GitHub (already in clipboard)"
  echo "  2. gh auth login"
  echo "  3. gcloud auth login && gcloud auth application-default login"
  echo "  4. op signin   # 1Password CLI"
  echo "  5. Open Claude Code and re-authenticate"
  echo "  6. exec zsh    # reload shell so new config takes effect"
}

main "$@"
