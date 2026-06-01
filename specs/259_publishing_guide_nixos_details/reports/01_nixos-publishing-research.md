# Research Report: Task #259

**Task**: 259 - Update PUBLISHING_GUIDE.md to include details for NixOS users
**Started**: 2026-06-01T00:00:00Z
**Completed**: 2026-06-01T00:15:00Z
**Effort**: 0.25 days
**Dependencies**: None
**Sources/Inputs**:
- `docs/training/PUBLISHING_GUIDE.md` — existing guide (primary target)
- `data/hf-dataset/PUBLISHING.md` — full operator guide
- `data/hf-dataset/requirements.txt` — Python dependencies
- `data/hf-dataset/upload.py` — upload script
- `.claude/context/project/filetypes/tools/dependency-guide.md` — NixOS pattern reference
- Codebase search for existing Nix/NixOS documentation
**Artifacts**:
- `specs/259_publishing_guide_nixos_details/reports/01_nixos-publishing-research.md`
**Standards**: report-format.md

---

## Executive Summary

- The project has no `flake.nix`, `shell.nix`, or `default.nix` — there is no existing Nix environment for Python tooling
- The publishing workflow uses `pip install -r requirements.txt` (4 packages: `datasets`, `huggingface_hub`, `pyarrow`, `pyyaml`), all of which are available as Nix packages
- The primary NixOS pain points are: (1) `pip install` failing due to the read-only Nix store, (2) `huggingface-cli` not being available as a top-level Nix package, and (3) no keyring on minimal NixOS installs (which affects `huggingface-cli login` but not the `HF_TOKEN` env-var flow)
- The recommended implementation approach is to add a parallel **"NixOS Users"** subsection under "Step 1 — Install Dependencies" in `PUBLISHING_GUIDE.md`, covering both ephemeral (`nix-shell`) and persistent (`home-manager`) options, and noting that the `HF_TOKEN` env-var method sidesteps keyring issues entirely

---

## Context & Scope

`docs/training/PUBLISHING_GUIDE.md` is the user-facing guide for both consumers (downloading the dataset) and maintainers (publishing to HF Hub). The task is to add NixOS-specific notes **in parallel** with the existing Linux/macOS instructions — without disrupting the existing structure.

The full operator guide at `data/hf-dataset/PUBLISHING.md` mirrors the same steps and would also benefit from similar additions, but the primary target per the task description is `PUBLISHING_GUIDE.md`.

There is no existing `flake.nix` or Nix environment in the repository. The project's Lean toolchain is managed via `elan` (installed via `curl | sh`), which also works on NixOS if executed inside `nix-shell -p curl` or if `curl` is already present.

---

## Findings

### Codebase Patterns

**Existing Nix documentation in this project**:
- `.claude/context/project/filetypes/tools/dependency-guide.md` contains a thorough NixOS section with ephemeral (`nix-shell`) and persistent (`home-manager`) patterns — this is the best style reference for how to document NixOS instructions in this codebase
- `.claude/context/project/filetypes/domain/conversion-tables.md` shows a `home.nix` snippet pattern
- The project's git-workflow rules note a portable session ID command that works on NixOS, showing awareness of the platform

**No existing NixOS content** in `docs/` or `data/hf-dataset/PUBLISHING.md`.

**Python dependencies** (`requirements.txt`):
```
datasets>=2.19.0
huggingface_hub>=0.23.0
pyarrow>=14.0.0
pyyaml>=6.0
```

All four are available in nixpkgs as:
- `python3Packages.datasets`
- `python3Packages.huggingface-hub`
- `python3Packages.pyarrow`
- `python3Packages.pyyaml`

**`huggingface-cli`**: This CLI tool is provided by `huggingface_hub` Python package (not a separate Nix package). On NixOS it must be installed via `nix-shell` or `home-manager`, not via a top-level `nix-env -i`.

### NixOS-Specific Pain Points

**1. `pip install` on NixOS**

NixOS uses a read-only, immutable `/nix/store`. A bare `pip install` without a virtual environment will fail with a permission error or "externally managed environment" error on NixOS. Solutions:
- Use `nix-shell -p python3Packages.datasets python3Packages.huggingface-hub python3Packages.pyarrow python3Packages.pyyaml` (no pip needed)
- Or create a venv first: `python3 -m venv .venv && .venv/bin/pip install -r requirements.txt`

**2. `huggingface-cli` availability**

`huggingface-cli` is the `huggingface-hub` package's CLI entrypoint. On NixOS it is accessible via `nix-shell -p python3Packages.huggingface-hub`. There is no standalone `huggingface-cli` Nix package.

**3. Keyring / token management**

`huggingface-cli login` uses the system keyring to cache tokens. Minimal NixOS installs may lack a keyring backend (gnome-keyring, kwallet, etc.), causing `huggingface-cli login` to fail or warn. The workaround is to use the `HF_TOKEN` environment variable directly — which is already the recommended method in the existing guide — so this is a non-issue if users follow the guide's primary recommendation.

**4. Python interpreter availability**

NixOS does not have a global `python3` unless it is declared in the system configuration. `nix-shell -p python3 ...` resolves this.

### Recommended Nix Commands

**Ephemeral (nix-shell) — for the upload script**:
```bash
nix-shell -p python3Packages.datasets python3Packages.huggingface-hub python3Packages.pyarrow python3Packages.pyyaml
# Then inside the shell:
python validate.py
python upload.py --dry-run
export HF_TOKEN=your_token_here
python upload.py
```

**Ephemeral — for huggingface-cli download**:
```bash
nix-shell -p python3Packages.huggingface-hub
huggingface-cli download logos-labs/bmlogic-bench --repo-type dataset --local-dir data/
```

**Persistent (home-manager)**:
```nix
home.packages = with pkgs; [
  python3Packages.datasets
  python3Packages.huggingface-hub
  python3Packages.pyarrow
  python3Packages.pyyaml
];
```

**Venv alternative** (useful when nixpkgs version of a package is too old):
```bash
nix-shell -p python3
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Structure of the Existing Guide

The guide has these main sections:
1. Overview / Dataset Configurations
2. Quick Start for Consumers (Python API, CLI Download, Downstream Consumer Setup)
3. Publishing Workflow for Maintainers (Steps 1-5)
4. Post-Publish Verification
5. NeurIPS Submission Extras
6. Dataset Card and Schema Maintenance
7. Troubleshooting
8. Related Documentation

**Best insertion points**:
- "Step 1 — Install Dependencies": add a NixOS subsection immediately after the existing `pip install` instruction
- "CLI Download" under Quick Start: add a NixOS note for `huggingface-cli`
- "Troubleshooting": optionally add a "pip install fails on NixOS" entry

### Style Reference

The `.claude/context/project/filetypes/tools/dependency-guide.md` pattern uses:
- A table showing NixOS vs Ubuntu/Debian vs macOS at a glance
- An "Ephemeral (nix-shell)" subsection
- A "Persistent (home-manager)" subsection with a `nix` code block

The existing `PUBLISHING_GUIDE.md` does not use platform-comparison tables, so the NixOS additions should fit as clearly-labeled subsections rather than full tables (which would require restructuring the existing content).

---

## Decisions

- Target file is `docs/training/PUBLISHING_GUIDE.md` (the user-facing guide); `data/hf-dataset/PUBLISHING.md` is a secondary candidate but out of scope per task description
- Do not restructure existing sections; add NixOS content as parallel subsections with clear headings
- Recommend `nix-shell` as the primary approach (no system configuration needed); `home-manager` as the persistent option; venv as a fallback
- Recommend `HF_TOKEN` env-var as the NixOS token method (avoids keyring issues)
- Do not add a `flake.nix` or `shell.nix` to the repository — this is a documentation task only

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| nixpkgs package names may change in future NixOS releases | Document the channel-independent pattern (`nix-shell -p`) and note that names are for nixpkgs 24.x/unstable |
| `python3Packages.datasets` may lag behind HF releases on nixpkgs | Note the venv alternative for users who need a newer version |
| Keyring failures mislead users | Explicitly note that `HF_TOKEN` env-var bypasses keyring; no login step needed |
| Guide becomes too long with NixOS additions | Keep NixOS subsections concise; 4-8 lines per block maximum |

---

## Implementation Plan (for planner)

The implementation is a documentation-only edit to `docs/training/PUBLISHING_GUIDE.md`. Suggested edits:

**1. Under "Step 1 — Install Dependencies"**, after the existing `pip install -r requirements.txt` block, add:

```markdown
#### NixOS Users

On NixOS, `pip install` requires an active virtual environment or a Nix shell.
The required packages are available in nixpkgs:

```bash
# Ephemeral shell (no system changes):
nix-shell -p python3Packages.datasets python3Packages.huggingface-hub \
              python3Packages.pyarrow python3Packages.pyyaml

# Then run the publish steps inside the shell.
```

For a persistent install, add to `home.packages` in `home.nix`:

```nix
python3Packages.datasets
python3Packages.huggingface-hub
python3Packages.pyarrow
python3Packages.pyyaml
```

Alternatively, use a virtual environment:
```bash
nix-shell -p python3
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```
```

**2. Under "CLI Download"** in Quick Start, after the existing `pip install huggingface_hub` line, add:

```markdown
**NixOS**: `nix-shell -p python3Packages.huggingface-hub` provides `huggingface-cli`
without modifying your system.
```

**3. Under "Step 4 — Upload"**, reinforce the `HF_TOKEN` approach with a NixOS note:

```markdown
> **NixOS note**: Use the `HF_TOKEN` environment variable rather than
> `huggingface-cli login` to avoid keyring dependency issues.
```

**4. Optionally add to "Troubleshooting"**:

```markdown
### pip install fails on NixOS

On NixOS, the system Python environment is read-only. Use `nix-shell`:

```bash
nix-shell -p python3Packages.datasets python3Packages.huggingface-hub \
              python3Packages.pyarrow python3Packages.pyyaml
```

Or create a virtual environment first:
```bash
nix-shell -p python3
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```
```

---

## Context Extension Recommendations

- **Topic**: NixOS Python packaging for HF Hub tools
- **Gap**: No project context file documents how to install HuggingFace Python tools on NixOS
- **Recommendation**: If NixOS documentation becomes a recurring need across multiple guides, consider adding a `.context/nix/python-packages.md` with the canonical package names and patterns. For now, the inline documentation in `PUBLISHING_GUIDE.md` is sufficient.

---

## Appendix

### Files Examined
- `/home/benjamin/Projects/BimodalLogic/docs/training/PUBLISHING_GUIDE.md`
- `/home/benjamin/Projects/BimodalLogic/data/hf-dataset/PUBLISHING.md`
- `/home/benjamin/Projects/BimodalLogic/data/hf-dataset/requirements.txt`
- `/home/benjamin/Projects/BimodalLogic/data/hf-dataset/upload.py`
- `/home/benjamin/Projects/BimodalLogic/.claude/context/project/filetypes/tools/dependency-guide.md`
- `/home/benjamin/Projects/BimodalLogic/docs/development/CONTRIBUTING.md`
- `/home/benjamin/Projects/BimodalLogic/docs/installation/BASIC_INSTALLATION.md`

### Search Queries
- `find` for `flake.nix`, `shell.nix`, `default.nix`, `*.nix` — no results
- `grep -r "nix\|nixos"` across `docs/` — no results
- `grep -r "nix\|nixos"` across all `*.md` — found only `.claude/` system files

### nixpkgs Package Names (verified against nixpkgs 24.x/unstable naming conventions)
- `python3Packages.datasets` — HuggingFace Datasets library
- `python3Packages.huggingface-hub` — HF Hub client + `huggingface-cli` entrypoint
- `python3Packages.pyarrow` — Apache Arrow
- `python3Packages.pyyaml` — YAML parsing
