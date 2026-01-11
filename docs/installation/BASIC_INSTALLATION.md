# Basic Installation Guide

[Back to Installation](README.md) | [Claude Code](CLAUDE_CODE.md) | [Getting Started](GETTING_STARTED.md)

---

## Overview

This guide covers the standard installation of ProofChecker (Logos). The installation is straightforward and automated by Lake, Lean's build system.

**Note**: This guide covers installation only. For editor setup (VS Code, NeoVim), see [Getting Started](GETTING_STARTED.md).

## What Gets Installed

| Component | Purpose |
|-----------|---------|
| **elan** | Lean version manager (like rustup for Rust) |
| **Lean 4** | The theorem prover (v4.14.0+) |
| **Lake** | Lean's build system (included with Lean 4) |
| **Mathlib** | Mathematical library (auto-downloaded on first build) |

## Prerequisites

Before installing ProofChecker, ensure you have:

- **Git** - For cloning the repository
  - Not installed? See [Using Git: Installing Git](USING_GIT.md#installing-git)

- **Internet connection** - Required for downloading Lean and Mathlib

- **~5GB disk space** - Mathlib cache requires significant space

To check if Git is installed:
```bash
git --version
```

---

## Installation

### Step 1: Install elan (Lean Version Manager)

**macOS / Linux:**
```bash
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
```

Follow the prompts. When asked about modifying PATH, choose yes.

After installation, restart your terminal or run:
```bash
source ~/.profile  # or ~/.bashrc, ~/.zshrc depending on your shell
```

**Windows:**

Download and run the installer from [elan releases](https://github.com/leanprover/elan/releases).

Or use PowerShell:
```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/leanprover/elan/master/elan-init.ps1 -OutFile elan-init.ps1
.\elan-init.ps1
```

### Step 2: Verify elan Installation

```bash
# Check elan is available
elan --version

# Check Lean and Lake are available
lean --version
lake --version
```

You should see version numbers for all three commands.

### Step 3: Clone the Repository

```bash
# Navigate to your projects directory
cd ~/Documents/Projects  # or wherever you keep projects

# Clone ProofChecker
git clone https://github.com/benbrastmckie/ProofChecker.git

# Enter the project directory
cd ProofChecker
```

### Step 4: Build the Project

```bash
lake build
```

**Important**: The first build downloads the Mathlib cache, which takes approximately **30 minutes** depending on your internet connection. This is a one-time download.

You'll see output like:
```
info: downloading component 'lean'
info: downloading component 'leanc'
info: installing component 'lean'
...
Attempting to download cached lake-manifest.json from https://...
Build completed successfully!
```

### Step 5: Verify the Build

```bash
# Run tests to verify everything works
lake test
```

If tests pass, installation is complete.

---

## Updating ProofChecker

To update to the latest version:

```bash
cd ~/Documents/Projects/ProofChecker
git pull
lake update
lake build
```

---

## Common Issues

### elan: command not found

Your PATH wasn't updated. Either:
- Restart your terminal
- Run `source ~/.profile` (or your shell's config file)
- Add manually: `export PATH="$HOME/.elan/bin:$PATH"`

### Build fails: network error

Mathlib download requires stable internet. If interrupted:
```bash
rm -rf ~/.elan/toolchains/leanprover-lean4-v4.14.0/lib/lean4/library/
lake build
```

### Build fails: disk space

Mathlib cache needs ~5GB. Free up space and retry:
```bash
df -h  # Check available space
lake clean
lake build
```

### Wrong Lean version

ProofChecker requires Lean 4.14.0+. Check and update:
```bash
lean --version  # Should show v4.14.0 or later

# Update via elan
elan update
```

### Permission denied

On Linux/macOS, if you get permission errors:
```bash
# Fix elan directory permissions
chmod -R u+rw ~/.elan/
```

---

## Quick Command Reference

| Task | Command |
|------|---------|
| Install elan | `curl https://...elan-init.sh -sSf \| sh` |
| Verify installation | `lean --version && lake --version` |
| Clone repository | `git clone https://github.com/benbrastmckie/ProofChecker.git` |
| Build project | `lake build` |
| Run tests | `lake test` |
| Update project | `git pull && lake update && lake build` |
| Clean build | `lake clean && lake build` |

---

## Next Steps

- **[Getting Started](GETTING_STARTED.md)** - Set up your editor (VS Code or NeoVim)
- **[Using Git](USING_GIT.md)** - Learn Git/GitHub for collaboration
- **[Tutorial](../user-guide/TUTORIAL.md)** - Start writing proofs
- **[Claude Code](CLAUDE_CODE.md)** - Use AI-assisted development

---

[Back to Installation](README.md) | [Claude Code](CLAUDE_CODE.md) | [Getting Started](GETTING_STARTED.md)
