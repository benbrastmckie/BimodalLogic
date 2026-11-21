# Contributing to BimodalLogic

This repository is a Lean 4 formalization of TM, the bimodal logic of tense and modality, with
its extensions, metalogic and automation. Contributions to the library, its automation, its
tests and its documentation are welcome.

For where things are in the tree, read [ORGANISATION.md](ORGANISATION.md) first.

## 1. Setup

You need Git and [elan](https://github.com/leanprover/elan). The Lean version is pinned in
[`lean-toolchain`](lean-toolchain) and elan installs it on first use.

```bash
git clone https://github.com/YOUR-USERNAME/BimodalLogic.git
cd BimodalLogic
lake exe cache get                    # Mathlib's prebuilt cache
lake build
lake test
bash scripts/install-git-hooks.sh     # once per clone
```

Do not run `lake update`: it moves the dependency pins.

Before pushing:

```bash
lake build && lake test && lake lint
bash scripts/verify-all.sh            # CI's repository checks; over ten minutes
```

`.github/workflows/ci.yml` is the source of record for what CI checks.

## 2. What a Contribution Must Satisfy

- **No `sorry`, no new `axiom`, no `native_decide`.** `scripts/check-module-invariants.sh` pins
  the axiom set of each headline result, and a change to one fails the check. A statement that
  is not yet proved is not committed as a theorem.
- **Tests.** New definitions, theorems and tactics come with tests under `Tests/BimodalTest/`,
  mirroring the library path. A tactic's error messages are tested too. See
  [Testing Standards](docs/development/TESTING_STANDARDS.md).
- **Style.** Follow the [Lean Style Guide](docs/development/LEAN_STYLE_GUIDE.md). Every public
  declaration has a docstring; every file has a module docstring and a copyright header.
- **Placement.** Imports run downward through the layers in
  [ORGANISATION.md](ORGANISATION.md). A capability covered by a record under `records/` sits
  where that record says.
- **Generated files are regenerated, not edited.** After adding, moving or deleting a module,
  run `lake exe mk_all --lib FormalSystem`. After changing a directory's files, run
  `bash scripts/check-module-invariants.sh --emit-inventory` to rewrite the README inventories.

## 3. Where Documents Live

- **`records/` holds shared designs for collaboration, and only for what is not yet fully
  implemented.** See [records/README.md](records/README.md). A contribution that adds a
  capability says where it sits in the relevant record, and updates the record if it changes
  the design.
- **`docs/` holds how to use what exists.** A contribution that implements part of a design
  revises `docs/` to describe what now exists and cuts that part from the record.
- **`specs/` is the development record**: reports, plans and drafts written while work is under
  way. It is not maintained afterwards, so no `README.md` links into it.
- **Source files, tests, `docs/` and `records/` state what is there now.** They do not cite
  plan labels, task numbers or draft history.

## 4. Pull Requests

Branch from `main`, make the change with its tests and documentation, and open a pull request
against `main`. Say what it changes and how it was tested. For a large change, open an issue or
propose a record first, so that the design is agreed before the work is done.

```markdown
- [ ] `lake build`, `lake test` and `lake lint` pass
- [ ] `bash scripts/verify-all.sh` passes
- [ ] No `sorry`, no new `axiom`, no `native_decide`
- [ ] New declarations have docstrings and tests
- [ ] Generated files regenerated
- [ ] `docs/` describes what now exists; the record is updated or cut back
- [ ] No `README.md` links into `specs/`
```

A toolchain or Mathlib upgrade is one pull request of its own: it moves `lean-toolchain`, the
Mathlib `rev` in `lakefile.toml` and `lake-manifest.json` together, and updates the version
stated in `README.md` and `CLAUDE.md`.

Commits beginning `task N:` come from the maintainer's agent system, configured under the
gitignored `.claude/`. Contributors do not need it, and work done with AI assistance meets the
same standards as any other.

## 5. Bugs and Questions

A bug report gives the commit, the output of `lake env lean --version`, and a minimal Lean
example. Questions go to GitHub Discussions or the Lean Zulip.
