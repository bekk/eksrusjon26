#!/usr/bin/env bash
# setup.sh — Bekk Beach Club, per-Mac setup.
#
# Run:   bash setup.sh
# Rerun: safe. Every step is idempotent.
#
# Non-interactive (macs 02-10):
#   BC_API_KEY='sk-ant-...' BC_GH_TOKEN='github_pat_...' bash setup.sh
#
# Does NOT commit or push anything.

# deliberately NOT set -e: we want every step to run and report,
# so one failure doesn't hide the state of everything after it.
set -uo pipefail

REPO_URL="https://github.com/bekk/bekk-beach-club-26.git"
DEMO_DIR="$HOME/demo"
ENV_FILE="$HOME/.config/beach-club/env"
LOG="$HOME/beach-club-setup.log"

R=$'\e[31m'; G=$'\e[32m'; Y=$'\e[33m'; D=$'\e[2m'; B=$'\e[1m'; X=$'\e[0m'

RESULTS=()
step() { printf "\n${B}▸ %s${X}\n" "$1"; CURRENT="$1"; }
ok()   { RESULTS+=("${G}ok  ${X} $CURRENT"); printf "  ${G}ok${X}\n"; }
warn() { RESULTS+=("${Y}warn${X} $CURRENT — $1"); printf "  ${Y}warn: %s${X}\n" "$1"; }
fail() { RESULTS+=("${R}FAIL${X} $CURRENT — $1"); printf "  ${R}FAIL: %s${X}\n" "$1"; }

exec > >(tee -a "$LOG") 2>&1
echo "=== $(date) — $(hostname) ==="

# ── team number from hostname ────────────────────────────────
HOST=$(scutil --get LocalHostName 2>/dev/null || hostname -s)
NUM=$(echo "$HOST" | grep -oE '[0-9]{1,2}$' | xargs printf '%02d' 2>/dev/null)

if [[ -z "$NUM" ]]; then
  printf "${Y}Hostname '%s' has no number.${X}\n" "$HOST"
  read -r -p "Team number (01-10): " NUM
  NUM=$(printf '%02d' "$NUM")
fi
BRANCH="team-$NUM"
printf "${B}Setting up as %s (branch %s)${X}\n" "$HOST" "$BRANCH"

# ── secrets ──────────────────────────────────────────────────
if [[ -z "${BC_API_KEY:-}" ]]; then
  if [[ -f "$ENV_FILE" ]] && grep -q ANTHROPIC_API_KEY "$ENV_FILE"; then
    printf "${D}Using API key already on disk.${X}\n"
    BC_API_KEY=$(grep ANTHROPIC_API_KEY "$ENV_FILE" | cut -d"'" -f2)
  else
    read -r -s -p "Anthropic API key: " BC_API_KEY; echo
  fi
fi
if [[ -z "${BC_GH_TOKEN:-}" ]]; then
  if gh auth status >/dev/null 2>&1; then
    printf "${D}gh already authenticated.${X}\n"
    BC_GH_TOKEN=""
  else
    read -r -s -p "GitHub PAT: " BC_GH_TOKEN; echo
  fi
fi

[[ -z "$BC_API_KEY" ]] && { printf "${R}No API key. Aborting.${X}\n"; exit 1; }

# ── power ────────────────────────────────────────────────────
step "Disable sleep"
if sudo -n true 2>/dev/null; then
  sudo pmset -a sleep 0 displaysleep 0 disablesleep 1 && ok || fail "pmset rejected"
else
  printf "  ${D}(sudo password needed)${X}\n"
  if sudo pmset -a sleep 0 displaysleep 0 disablesleep 1; then ok
  else warn "skipped — run manually or MDM blocks it"; fi
fi

step "Disable screensaver"
defaults -currentHost write com.apple.screensaver idleTime 0 && ok || warn "could not set"

# ── homebrew ─────────────────────────────────────────────────
step "Homebrew"
BREW=""
for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x "$p" ]] && BREW="$p" && break
done
if [[ -n "$BREW" ]]; then
  printf "  ${D}already installed${X}\n"; ok
else
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$p" ]] && BREW="$p" && break
  done
  [[ -n "$BREW" ]] && ok || fail "install failed — check network/proxy"
fi

if [[ -n "$BREW" ]]; then
  eval "$("$BREW" shellenv)"
  grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null || \
    echo "eval \"\$($BREW shellenv)\"" >> "$HOME/.zprofile"
fi

# ── tools ────────────────────────────────────────────────────
step "node, git, gh"
if [[ -n "$BREW" ]]; then
  "$BREW" install node git gh 2>&1 | tail -2
  MISSING=""
  for t in node git gh; do command -v "$t" >/dev/null || MISSING="$MISSING $t"; done
  [[ -z "$MISSING" ]] && ok || fail "missing:$MISSING"
else
  fail "no homebrew"
fi

step "Claude Code"
if command -v claude >/dev/null; then
  printf "  ${D}already installed${X}\n"; ok
else
  npm install -g @anthropic-ai/claude-code 2>&1 | tail -2
  command -v claude >/dev/null && ok || fail "npm install failed"
fi

# ── env ──────────────────────────────────────────────────────
step "Environment"
mkdir -p "$(dirname "$ENV_FILE")"
cat > "$ENV_FILE" <<EOF
export ANTHROPIC_API_KEY='$BC_API_KEY'
export PATH="\$HOME/demo/bin:\$PATH"
export BC_TEAM='$BRANCH'
EOF
chmod 600 "$ENV_FILE"
grep -q 'beach-club/env' "$HOME/.zshrc" 2>/dev/null || \
  echo "[ -f $ENV_FILE ] && source $ENV_FILE" >> "$HOME/.zshrc"
source "$ENV_FILE"
ok

# ── github auth ──────────────────────────────────────────────
step "GitHub auth"
if gh auth status >/dev/null 2>&1; then
  printf "  ${D}already authenticated${X}\n"; ok
elif [[ -n "$BC_GH_TOKEN" ]]; then
  echo "$BC_GH_TOKEN" | gh auth login --with-token && gh auth setup-git && ok \
    || fail "token rejected — check scopes (Contents: read+write)"
else
  fail "no token supplied"
fi

git config --global user.name  "Team $NUM"
git config --global user.email "beach-club-$NUM@bekk.no"
git config --global push.default current
git config --global advice.detachedHead false

# ── repo ─────────────────────────────────────────────────────
step "Clone repo"
if [[ -d "$DEMO_DIR/.git" ]]; then
  printf "  ${D}already cloned${X}\n"
  git -C "$DEMO_DIR" remote set-url origin "$REPO_URL"
  ok
else
  git clone "$REPO_URL" "$DEMO_DIR" && ok || fail "clone failed — auth or network"
fi

step "Checkout $BRANCH"
if [[ -d "$DEMO_DIR/.git" ]]; then
  cd "$DEMO_DIR" || exit 1
  git fetch origin 2>&1 | tail -1
  if git rev-parse --verify "origin/$BRANCH" >/dev/null 2>&1; then
    git checkout -B "$BRANCH" "origin/$BRANCH" && ok || fail "checkout failed"
  else
    fail "origin/$BRANCH does not exist — create it on GitHub first"
  fi
else
  fail "no repo"
fi

step "npm ci"
if [[ -f "$DEMO_DIR/package.json" ]]; then
  ( cd "$DEMO_DIR" && npm ci 2>&1 | tail -3 )
  [[ -d "$DEMO_DIR/node_modules" ]] && ok || fail "install failed"
else
  fail "no package.json on this branch"
fi

step "Make scripts executable"
if [[ -d "$DEMO_DIR/bin" ]]; then
  chmod +x "$DEMO_DIR"/bin/* && ok
else
  warn "no bin/ directory yet"
fi

# ── verify ───────────────────────────────────────────────────
step "Verify Claude Code"
if command -v claude >/dev/null; then
  OUT=$(cd "$DEMO_DIR" 2>/dev/null; timeout 90 claude -p "Reply with exactly: PONG" 2>&1)
  if echo "$OUT" | grep -qi pong; then ok
  else fail "no valid response — $(echo "$OUT" | head -1)"; fi
else
  fail "claude not installed"
fi

# ── summary ──────────────────────────────────────────────────
printf "\n${B}────────────── %s ──────────────${X}\n" "$HOST"
for r in "${RESULTS[@]}"; do printf "  %s\n" "$r"; done
printf "\n${D}Log: %s${X}\n" "$LOG"

if printf '%s\n' "${RESULTS[@]}" | grep -q FAIL; then
  printf "\n${R}Some steps failed. Fix, then rerun this script.${X}\n\n"
  exit 1
fi

cat <<EOF

${G}${B}Setup complete.${X}

Still to do by hand on this Mac:
  1. Open a NEW terminal, run: claude
     Clear the theme picker and the trust-folder prompt.
  2. cd ~/demo && npm run dev
  3. Open http://localhost:5173 on the second display
  4. Reboot and confirm everything comes back

EOF
