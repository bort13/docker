# fedora-container-docker

A Fedora-based development container with a full set of CLI and cloud/infra tooling pre-installed, running as a non-root user with `zsh` + `oh-my-zsh` by default.

<<<<<<< HEAD
## What's should be inside

**Base:** Fedora 44 (`FEDORA_VERSION` build arg)

=======
## What's inside

**Base:** Fedora 44 (`FEDORA_VERSION` build arg)

**Corporate CA trust:** installs `zscaler-full-chain.pem` into the system trust store via `update-ca-trust`, so `dnf`, `curl`, `git`, etc. work behind the Zscaler proxy.

>>>>>>> rob/rev-dockerfile
**Core packages** (via `dnf`):
`python3`, `python3-pip`, `curl`, `git`, `procps-ng`, `nc`, `nmap`, `ping`, `mtr`, `sudo`, `which`, `nfs-utils`, `cifs-utils`, `coreutils`, `bind-utils`, `fzf`, `jq`, `tcpdump`, `openssl`, `vim`, `tree`, `unzip`, `traceroute`, `whois`, `htop`, `lsof`, `ripgrep`, `yq`, `zsh`, `dnf-plugins-core`

**Session tools:** `byobu`, `tmux`, `screen`

**Cloud / infra CLIs** (installed via arch-aware official binaries or repos, not always available as `dnf` packages):
- `kubectl` — official Kubernetes release binary
- `k9s` — Kubernetes TUI, latest GitHub release
- `gh` — GitHub CLI, via GitHub's official repo
- `awscli` v2 — official AWS installer
- `terraform` — via HashiCorp's official repo
- `skopeo` — container registry/image inspection
- `helm` — via Helm's official install script
- `crane` — via `go-containerregistry`, latest GitHub release
- `openssh-clients`

All arch-sensitive installs detect `x86_64` vs `aarch64` at build time and pull the matching binary.

## User setup

- Runs as a non-root user, configurable via build args:
  - `APP_USER` (default `rob`)
  - `APP_UID` (default `1000`)
- User is added to passwordless `sudo`
- Default shell is `zsh`, with `oh-my-zsh` installed unattended
- Both `.bashrc` and `.zshrc` are copied in (so `bash` still works if you want it)
- A Python virtualenv is created at `~/.venv` and put on `PATH` automatically

## Build

```bash
docker build -t fedora-dev .
```

Override the user or Fedora version if needed:

```bash
docker build --build-arg APP_USER=alice --build-arg APP_UID=1001 --build-arg FEDORA_VERSION=44 -t fedora-dev .
```

## Run

```bash
docker run -it --rm fedora-dev
```

Drops you into `zsh` as `${APP_USER}` in `/home/${APP_USER}`, with the Python venv already active on `PATH`.

## Notes
<<<<<<< HEAD
=======

- Requires `zscaler-full-chain.pem` and `.bashrc` / `.zshrc` to be present in the build context alongside the `Dockerfile`.
>>>>>>> rob/rev-dockerfile
- Several tools (`kubectl`, `k9s`, `crane`) pull the *latest* release at build time — pin versions in the Dockerfile if you need reproducible builds.
