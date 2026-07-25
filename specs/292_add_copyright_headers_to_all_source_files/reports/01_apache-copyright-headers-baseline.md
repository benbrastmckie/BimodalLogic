# Research: Apache 2.0 Copyright Headers for Lean Sources

**Session**: sess_1784999032_8d6f8f_292 | **Date**: 2026-07-25 | **Toolchain**: Lean v4.33.0-rc1

Every count and claim below is grounded in a command that was actually run. All exploratory
edits made during this research were reverted; `git diff -- Theories/` is empty.

---

## 0. Executive summary — three findings that change the task

1. **BLOCKER (hard, legal): the repo is GPL-3.0, not Apache-2.0.** `LICENSE` is the GNU GPL v3,
   `Copyright (c) 2025 Benjamin Brast-McKie`, and `README.md:223` states "This project is
   licensed under GPL-3.0." The required header text is literally *"Released under Apache 2.0
   license as described in the file LICENSE."* Adding that line to 428 files while `LICENSE`
   remains GPL-3.0 asserts something false in every one of them. This needs an explicit
   relicensing decision from the copyright holder before the headers are written. See §5.

2. **The task description's header format is wrong in three independent ways** — `--` line
   comments instead of a `/- -/` block, a collective author ("The Bimodal Logic Contributors")
   that contradicts cslib's stated policy, and the year 2024, which predates the repo's first
   commit (2025-12-01). The corrected format is proven-correct against Mathlib's own checker in
   §3.

3. **The real file count is 429, not ~160**, and 151 of those are archived dead code in *two*
   Boneyard trees. Recommendation: header the **279 live files**, skip the 151 Boneyard files.
   See §2 and §7.

---

## 1. Verification strategy: the header linter cannot be used, and cannot be cheaply fixed

The sibling linter task established that `linter.style.header` reports zero hits and that this is
a false negative. This research confirms the mechanism, and — more importantly — establishes that
**fixing it is out of scope**, which was the open question.

`isInLibraryRoot` (`.lake/packages/mathlib/Mathlib/Tactic/Linter/Header.lean:259-264`) does two
things: it resolves `<root>.lean` **relative to the CWD**, and it then asks whether that file
**directly** imports the module being linted (`res.imports.any (·.module == modName)` — direct
imports only, not transitive).

Three experiments, all run with the linter forced on:

| # | Setup | Target module | Header-linter output |
|---|-------|---------------|----------------------|
| T1 | no root file at CWD | `Bimodal.Syntax.Formula` | **silent** |
| T2 | `ln -s Theories/Bimodal.lean ./Bimodal.lean` | `Bimodal.Bimodal` | **4 errors** (fires!) |
| T3 | same symlink | `Bimodal.Syntax.Formula` | **silent** |

```
lake env lean -R Theories -Dlinter.style.header=true Theories/Bimodal/Bimodal.lean
# T2 output:
#   Malformed or missing copyright header: `/-` should be alone on its own line.
#   Copyright line should start with 'Copyright (c) YYYY'
#   Copyright line should end with '. All rights reserved.'
#   Copyright too short!
```

Reading of the three results:

- T1 vs T2 proves the CWD root-path mismatch is the **sole** gate. `srcDir := "Theories"` puts the
  root at `Theories/Bimodal.lean`, so `./Bimodal.lean` does not exist and the linter no-ops.
- T3 proves a symlink is **not** a fix. `Theories/Bimodal.lean` directly imports exactly one
  module (`Bimodal.Bimodal`); everything else is reached through a nested aggregator hierarchy.
  So even with the root path repaired, the linter covers 1 module out of 279.
- Note T1/T3 also required `-R Theories`; without it `getMainModule` does not resolve to a
  `Bimodal.*` name and the test is vacuous. An earlier attempt without `-R` produced a
  false-clean result.

For contrast, cslib's `Cslib.lean` is a flat list of 168 `public import` lines covering the whole
library, and its `lakefile.toml` has no `srcDir` — which is exactly why the linter works there.
Making it work here would mean flattening `Theories/Bimodal.lean` into a 279-line import list
*and* placing a root file at the CWD. That is a real architectural change, not a header task.

Mathlib's text-based linter is not an alternative either: `Mathlib/Tactic/Linter/TextBased.lean`
has no copyright check (its `StyleError` cases are `adaptationNote`, `windowsLineEnding`,
`trailingWhitespace`, `semicolon`, `unwantedUnicode`, `unicodeVariant`). The header check exists
only in the syntax linter.

**Conclusion: verification must be a purpose-written text checker.** One has been written and
tested — see §6.

---

## 2. Empirical baseline

```
find Theories -name '*.lean' -type f | wc -l          # 430  (429 under Theories/Bimodal/ + Theories/Bimodal.lean)
```

The task description's "approximately 160" is wrong by a factor of ~2.7.

### 2a. Header state (via `scripts/check-copyright-headers.sh`, §6)

| Bucket | Count | Action |
|--------|-------|--------|
| Conforming header | **0** | — |
| Non-conforming copyright-like header | **2** | must be **replaced**, never prepended |
| Duplicate header | 0 | — |
| No header at all | **428** | safe to prepend |
| **Total** | **430** | |

The 2 non-conforming files are `Theories/Bimodal/Automation/TraceExporter.lean` and
`Theories/Bimodal/Metalogic/Decidability/TraceExport.lean`, both carrying:

```lean
/-
Copyright (c) 2026 BimodalLogic contributors.
Released under the project's standard license.
-/
```

This fails the checker on three counts: no `. All rights reserved.`, wrong license line, no
`Authors:` line.

### 2b. Breakdown by subtree

| Subtree | Files | In porting scope? |
|---------|------:|-------------------|
| `Metalogic/` (excl. nested Boneyard) | 199 | yes |
| `Automation/` | 35 | yes (see §7) |
| `Theorems/` | 13 | yes |
| `Syntax/` | 8 | yes |
| `Bimodal/` root aggregators | 8 | yes |
| `Semantics/` | 5 | yes |
| `ProofSystem/` | 4 | yes |
| `FrameConditions/` | 4 | yes |
| `Examples/` | 2 | yes |
| `Theories/Bimodal.lean` | 1 | yes |
| **live subtotal** | **279** | |
| `Bimodal/Boneyard/` | 89 | **no** |
| `Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` | 62 | **no** |
| **Boneyard subtotal** | **151** | |
| **TOTAL** | **430** | |

`Tests/` holds a further 42 `.lean` files (3 mention "copyright"). Out of this task's declared
`file_scope`, and cslib itself exempts its test library from the header linter
(`lakefile.toml`: `[[lean_lib]] name = "CslibTests"`, `leanOptions = {weak.linter.style.header = false}`).

### 2c. File-opening shapes (matters for placement)

| First line | Count | Prepend risk |
|-----------|------:|--------------|
| `import ...` | 364 | none |
| bare `/-` | 34 | 2 are the stale headers (replace); 32 are Boneyard banners |
| `--` line comment | 22 | none (all descriptive/ARCHIVED banners) |
| `/-!` module docstring | 10 | none — checked individually, 9 have **no imports at all** and the 10th (`Boneyard/DenseChronicle/CantorIsoCountermodel.lean`) has its first import at line 28, after the docstring |
| blank | 0 | — |

---

## 3. The exact header format — proven, not assumed

cslib is at **`leanprover/cslib`**, license **Apache-2.0** (`gh api repos/leanprover/cslib`).
`Cslib/Init.lean` shows the format verbatim:

```lean
/-
Copyright (c) 2025 Jesse Alama. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jesse Alama
-/
```

Mathlib's `copyrightHeaderChecks` (`Header.lean:182-249`) is the enforcing code. Its requirements:
first and last lines are `/-` and `-/` each alone on its own line; line 2 starts `Copyright (c) 20`
and ends `. All rights reserved.`; line 3 is exactly `Released under Apache 2.0 license as
described in the file LICENSE.`; the remainder starts `Authors: ` and must not end with a period
(continuation lines must end with commas). cslib enables this via
`weak.linter.mathlibStandardSet = true` in its lakefile, so it is CI-enforced on contributions.

### Format proof

Prepending the block below to `Theories/Bimodal/Bimodal.lean` and re-running the T2 experiment
took the linter from **4 errors to silent** — i.e. Mathlib's own checker accepts this text:

```lean
/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/
```

### Three corrections to the task description's format

| Element | Task description says | Correct | Evidence |
|---------|----------------------|---------|----------|
| Comment syntax | `--` line comments | `/- ... -/` block | `Header.lean:176` requires a `("/-", "-/")` pair; the `--` variant was fed to the checker and **rejected** |
| Copyright holder | "The Bimodal Logic Contributors" | **`Benjamin Brast-McKie`** | cslib `AUTHORS.md`: "**Copyright in CSLib is held by the individual authors** … Each file … lists the authors who contributed significantly to that specific file" |
| Year | 2024 | **2025 or 2026** | repo's first commit is 2025-12-01; 2024 predates the project |

### Authors field — grounded in git, not invented

```
git log --format='%an <%ae>' -- Theories/ | sort | uniq -c | sort -rn
   3164 benbrastmckie <benbrastmckie@gmail.com>
     10 Claude <noreply@anthropic.com>
```

A per-file check confirmed that **0 of 430 files lack `benbrastmckie` authorship**. So a uniform
`Authors: Benjamin Brast-McKie` is correct for every file, and matches both `LICENSE:4` and the
`Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.` notice already used in
`Theories/Bimodal/typst/BimodalReference.typ:10`. The 10 `Claude`-authored commits are AI-assisted
edits to files Brast-McKie also authored; under cslib's "significant contribution" standard they
do not warrant a separate copyright holder, and cslib's AI policy addresses tool use in the PR
description rather than the header.

### Year: uniform vs per-file

Mathlib convention is the file's creation year. Computed per file via
`git log --diff-filter=A --follow`:

| Year | All files | Live files (non-Boneyard) |
|------|----------:|--------------------------:|
| 2025 | 31 | 31 |
| 2026 | 399 | 248 |

Both are mechanically derivable, and either passes the linter's `Copyright (c) 20\d\d` pattern.
Recommendation: **per-file creation year** (31 files get 2025, the rest 2026) — faithful to
Mathlib convention at no extra cost. A uniform 2025 (matching `LICENSE`) is an acceptable
simpler alternative; uniform 2024 is not.

---

## 4. Placement is safe — build-tested, not reasoned

The header must precede `import` lines; the module docstring keeps its position after imports.
Two representative files were actually modified and built:

- `Theories/Bimodal/Syntax/Formula.lean` — the ordinary `import`-first shape.
- `Theories/Bimodal/Automation/AxiomNames.lean` — the awkward shape, where the header lands
  directly above a leading `/-!` module docstring.

```
lake build Bimodal.Syntax.Formula Bimodal.Automation.AxiomNames
Build completed successfully (682 jobs).
```

No errors, no new warnings. Both files then classified as `conforming` by the checker. Both edits
were reverted.

The 10 docstring-first files need no special handling: 9 have no imports at all, and the one that
does has its imports after the docstring already, so a prepend cannot reorder anything. The 151
Boneyard files all carry `#exit` guards (verified: 151/151), so even if headered they are never
elaborated past the guard.

---

## 5. BLOCKER: GPL-3.0 vs Apache-2.0

This is the one issue that should gate implementation.

| Source | Says |
|--------|------|
| `LICENSE` (19 lines) | GNU GPL v3, `Copyright (c) 2025 Benjamin Brast-McKie` |
| `README.md:223` | "This project is licensed under GPL-3.0. See LICENSE for details." |
| `leanprover/cslib` `LICENSE` | Apache License 2.0 |
| Required header line 3 | "Released under Apache 2.0 license as described in the file LICENSE." |

Writing the Apache line into 428 files whose `LICENSE` is the GPL makes a false statement in each
one. The direction of the incompatibility also matters: GPL-3.0 is copyleft and Apache-2.0 is
permissive, so this is not a formality — Apache-2.0 code can be absorbed into a GPL work, but not
the reverse. A cslib contribution must be Apache-2.0.

Because the sole copyright holder appears to be the user (0 files lack `benbrastmckie`
authorship; no CLA or third-party contributions found), relicensing is a decision they are
entitled to make unilaterally. But it is **their decision, not the implementer's**, and it has to
happen *before* or *with* the headers, not after. Note also that an archived task on document
licensing chose "all rights reserved" for the reference manual and explicitly recorded that "No
open/reuse license (CC BY, GPL, etc.) was introduced" — so the project has previously treated
licensing as a deliberate, user-owned decision.

Three coherent resolutions, in recommended order:

1. **Relicense to Apache-2.0** (recommended if cslib contribution is the goal). Replace `LICENSE`
   with the Apache-2.0 text, update `README.md:223`, then add the headers. All three land in the
   same change so the tree is never self-contradictory. Whether to dual-license or keep GPL-3.0
   for non-Lean parts (`.claude/`, `scripts/`) is a sub-decision worth asking about.
2. **Dual-license the Lean sources** Apache-2.0 while the repo stays GPL-3.0 elsewhere. Requires
   the header's "as described in the file LICENSE" to actually resolve — e.g. a
   `LICENSE-APACHE` file plus a `LICENSE` that explains the split. More moving parts.
3. **Defer.** Add nothing until relicensing is settled. Costs nothing but blocks the cslib port.

Do **not** proceed by adding the Apache line under a GPL `LICENSE`.

---

## 6. The checker (written and tested): `scripts/check-copyright-headers.sh`

Created as part of this research, since the linter cannot serve. It replicates Mathlib's
`copyrightHeaderChecks` as a text check and sorts every file into exactly one of four buckets:
`conforming`, `nonconforming`, `duplicate`, `missing`. `--strict` exits 1 if anything is not
conforming, which makes it usable as a CI gate.

```
$ bash scripts/check-copyright-headers.sh Theories
conforming   : 0
nonconforming: 2
duplicate    : 0
missing      : 428
total        : 430
```

Validated against a synthetic fixture set:

| Fixture | Expected | Got |
|---------|----------|-----|
| correct block header | conforming | conforming |
| doubled header (naive prepend onto a stale one) | duplicate | duplicate |
| the task description's `--` format | nonconforming | nonconforming |

`--strict` returned exit 1 on that set, as intended.

### The duplicate predicate, and a trap worth naming

The first version of this checker **passed the double-headered file**, because it validated the
leading block and stopped at the first `-/` — the stale second block survived unseen. That is
precisely the failure mode the task asks to guard against, and a checker with that hole would have
reported success on a corrupted tree.

The fix: count occurrences of `^Copyright (c) ` and of the license line across the **whole** file
and flag any file with more than one, *before* validating the leading block. So the safe
detection predicate is two-part:

- **Prepend only if** the file contains no `Copyright` in its first 10 lines **and** no
  `^Copyright (c) ` anywhere.
- **Never prepend** to the 2 known non-conforming files; delete their 4-line stale block and write
  the correct one. A naive prepend produces exactly the doubled output shown above.

---

## 7. Recommendation: skip the 151 Boneyard files

The task wording is "all source files under `Theories/Bimodal/`". Read literally that includes
151 archived files. Evidence that they are inert:

| Check | Result |
|-------|--------|
| files with `#exit` guard | **151 / 151** |
| `.olean` artifacts built | **0** |
| imports of a Boneyard module from outside Boneyard | **0** |
| documented status | both trees have a `README.md` describing archived dead code |

Copyright headers exist to establish provenance and license on distributed source. These files are
not compiled, not imported, and not part of any cslib contribution. Headering them is 151 files of
churn that adds nothing and enlarges the diff by ~755 lines, making the meaningful 279-file change
harder to review.

**Recommendation: header the 279 live files (277 missing + 2 replaced); skip the 151 Boneyard
files.** If the user wants blanket coverage for tidiness, it is a trivial follow-up — but it
should be an explicit choice, and ideally a separate commit.

On `Automation/` (35 files): the delegation notes it as possibly out of the porting scope, but it
is **live code** — it builds, produces 12 `lean_exe` targets in `lakefile.lean`, and is imported by
`Bimodal.Bimodal`. Whether it ships to cslib is a separate question from whether it is licensed
source in this repo. **Include it.** Excluding live, compiled, git-tracked code from licensing
headers is the wrong default.

---

## 8. Recommended implementation approach

Gate on §5 first. Assuming the user authorizes Apache-2.0:

1. **Relicense** — replace `LICENSE` with Apache-2.0 text; update `README.md:223`. Same commit as,
   or immediately before, the headers.
2. **Repair the 2 stale headers** by hand (delete lines 1-4, write the correct block). Only 2
   files; scripting this is not worth the risk.
3. **Batch-prepend to the 277** remaining live files, driven by
   `scripts/check-copyright-headers.sh`'s `missing.txt` bucket filtered with `grep -v Boneyard`.
   Requirements on the script: a `--dry-run` that prints the file list and one sample diff and
   writes nothing; per-file year from `git log --diff-filter=A --follow`; the two-part
   safety predicate from §6; and a blank line between the header and whatever follows.
4. **Verify**, in this order:
   - `bash scripts/check-copyright-headers.sh --strict Theories` restricted to the live set —
     expect `conforming: 279, nonconforming: 0, duplicate: 0, missing: 0`.
   - `grep -c '^Copyright (c) '` is exactly 1 in every touched file.
   - `git diff --stat` shows exactly **279 files changed**. Insertions should equal
     `277 × H + 2 × 5` where `H` is the per-file header size the script emits (5 if no trailing
     blank line, 6 with one), and **deletions must be exactly 8** — the 4 stale lines removed
     from each of the 2 replaced files. Any file outside those 2 showing a deletion is a bug.
   - `lake build` — must stay at **0 errors** and exactly **12** `declaration uses 'sorry'`
     warnings (7 in `Metalogic/Bundle/SuccRelation.lean`, 3 in `Bundle/SuccExistence.lean`, 1 in
     `BXCanonical/Chronicle/ChronicleToCountermodel.lean`, 1 in `WeakCanonical/Transfer.lean`).
5. **Do not** report "linter clean" as evidence. `linter.style.header` is silent here whether the
   headers are right, wrong, or absent.

Phase sizing note: step 3 is a single mechanical pass but touches 277 files. Splitting it by
subtree (Syntax/Semantics/ProofSystem/Theorems/FrameConditions/Examples = 36 files; Automation =
34; Metalogic = 198; root aggregators = 9) gives reviewable commits and a natural checkpoint after
the small tier.

### Deferred, related but out of scope

- The `srcDir`/`isInLibraryRoot` mismatch (§1) leaves the header linter permanently blind. Worth
  its own task if cslib compliance is to be machine-checked rather than checked by this script.
- `Tests/` (42 files, 3 with copyright mentions) — out of `file_scope`, and cslib exempts its own
  test library.
- Mathlib's header linter also requires the first non-import command to be a module docstring.
  Not measured here; it belongs to the sibling linter-compliance work.
- The top-level `CLAUDE.md` claims Lean v4.27.0-rc1; `lean-toolchain` says v4.33.0-rc1.

---

## 9. Commands run (reproducibility)

```bash
# baseline counts
find Theories -name '*.lean' -type f | wc -l                                  # 430
find Theories -name '*.lean' -type f -path '*Boneyard*' | wc -l               # 151
grep -rli 'copyright' --include='*.lean' Theories                             # 2 files
grep -rli 'apache' --include='*.lean' Theories | wc -l                        # 0

# linter mechanism (T1/T2/T3)
lake env lean -R Theories -Dlinter.style.header=true Theories/Bimodal/Syntax/Formula.lean
ln -s Theories/Bimodal.lean ./Bimodal.lean
lake env lean -R Theories -Dlinter.style.header=true Theories/Bimodal/Bimodal.lean
rm -f ./Bimodal.lean

# license / upstream
cat LICENSE; grep -n -A4 -i '^## License' README.md
gh api repos/leanprover/cslib --jq '.license.spdx_id'                         # Apache-2.0
gh api repos/leanprover/cslib/contents/Cslib/Init.lean --jq '.content' | base64 -d | head -5
gh api repos/leanprover/cslib/contents/AUTHORS.md -H 'Accept: application/vnd.github.raw'

# authorship + years
git log --format='%an <%ae>' -- Theories/ | sort | uniq -c | sort -rn
git log --diff-filter=A --follow --format='%ad' --date=format:'%Y' -- <file> | tail -1

# boneyard inertness
grep -rl '^#exit' --include='*.lean' Theories | grep -c Boneyard              # 151
find .lake/build -path '*Boneyard*' -name '*.olean' | wc -l                   # 0
grep -rn '^import .*Boneyard' --include='*.lean' Theories | grep -v 'Boneyard/' | wc -l  # 0

# placement build test (reverted afterwards)
lake build Bimodal.Syntax.Formula Bimodal.Automation.AxiomNames               # success, 682 jobs

# the checker
bash scripts/check-copyright-headers.sh Theories
bash scripts/check-copyright-headers.sh --strict <fixture-dir>
```
