# dotfiles

Personal shell and git configuration, shared between my Mac (zsh) and any Linux
dev environment (bash) I work in.

## Contents

| File                | Linked as              | How it's wired up                                              |
|---------------------|-------------------------|------------------------------------------------------------------|
| `zshrc`             | `~/.zshrc`              | Symlinked directly.                                              |
| `bash_aliases`      | `~/.bash_aliases`       | Symlinked directly.                                               |
| `gitconfig-personal`| `~/.gitconfig-personal` | Symlinked directly. Only read via the `includeIf` below.         |
| `bashrc_extra`      | *(not linked)*          | Sourced from a line appended to the real `~/.bashrc`.             |
| `gitconfig`         | *(not linked)*          | Pulled in via `git config --global include.path` in the real `~/.gitconfig`. |
| `install.sh`        | —                       | Sets all of the above up. Safe to re-run.                         |

`~/.bashrc` and `~/.gitconfig` are deliberately **never symlinked**: other
tooling writes into those files directly (e.g. session provisioning scripts
append banners to `.bashrc`, and `git config --global user.name/email` writes
straight into `.gitconfig`). Symlinking them would redirect those writes into
this repo. Instead, `bashrc_extra` is sourced from the real `.bashrc`, and
`gitconfig`'s settings are pulled in via git's own `include.path` mechanism.

**Important:** `gitconfig` in this repo must never set `[user]` unconditionally
— identity (`name`/`email`) is intentionally left to be set elsewhere
(locally, or via session env vars like `GIT_USER_NAME`/`GIT_USER_EMAIL` on
remote dev environments). A bare `[user]` block here would be read *after*
the real config's, and take precedence over the identity that
machine/session is actually supposed to use.

The one exception is `gitconfig-personal`, which sets `husz.beata@gmail.com`
for repos under `~/Documents/pet-projects/` — that's fine because it's
scoped via `includeIf "gitdir:~/Documents/pet-projects/"` in `gitconfig`, so
it only overrides identity for that specific directory tree rather than
globally.

## Setup

```bash
git clone <this-repo-url> ~/Documents/pet-projects/dotfiles
cd ~/Documents/pet-projects/dotfiles
./install.sh
```

Re-run `./install.sh` any time after pulling changes — it's idempotent and
backs up any pre-existing real file (`<file>.backup.<timestamp>`) before
linking over it.

### First-time machine setup: git identity

`install.sh` deliberately does **not** set `user.name`/`user.email` — see
"Important" above. On a remote dev environment, that identity comes from the
`GIT_USER_NAME`/`GIT_USER_EMAIL` session inputs automatically. On a **new
Mac**, nothing sets it for you, so run this once, manually, before `gitconfig`
aliases will be much use:

```bash
git config --global user.name "beahuszar"
git config --global user.email "beata.huszar@bitrise.io"
```

This writes directly into the real `~/.gitconfig`, separate from anything in
this repo.

### Prerequisites (zsh/macOS only)

`zshrc` assumes [oh-my-zsh](https://ohmyz.sh/) is already installed
(`~/.oh-my-zsh`) — install that first, or the shell will fail to start after
linking. `nvm` sourcing is optional and guarded, so it's skipped silently if
not installed.

## Pulling in updates

Since `zshrc`/`bash_aliases` are symlinks and `bashrc_extra`/`gitconfig` are
sourced/included by path, a `git pull` in this repo is picked up immediately
on the next new shell/git command — no need to re-run `install.sh` unless a
*new* file was added to the repo.
