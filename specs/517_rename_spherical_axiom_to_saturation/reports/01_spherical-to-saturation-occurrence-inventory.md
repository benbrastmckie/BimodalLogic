# Spherical → Saturation: verified occurrence inventory and rename contract

**Task**: 517 — rename the fourth task-frame axiom from *Spherical* to *Saturation*
**Baseline commit**: `9cd17f308` (`task 518: complete implementation`) — task 518's Wave 0 hotfix
is included; this report was measured against that HEAD, not a stale view.
**Date measured**: 2026-09-01

---

## 1. Verdict

The rename is **mechanically executable with two exceptions**, both of which this report
enumerates exhaustively and by exact location. The central research question posed by the task
brief — *at every occurrence, does "spherical" name the axiom or the weaker standard ball-space
condition?* — has a measured answer:

| Partition | Occurrences | Where |
|---|---:|---|
| **RENAME** (names the axiom) | **441** | 40 files (see §3) |
| **KEEP** (names the weaker standard condition `S₁`) | **3** | `TaskFrame.lean:393`, `TaskFrame.lean:394`, `README.md:80` |
| **Total** (excluding `specs/**`) | **444** | |

The KEEP set is exactly the three occurrences of the substring `spherical` that sit inside the
literal English phrase **"spherically complete"**. There is no other surviving sense of the word
anywhere in the live tree. This makes the semantic partition expressible as a single, checkable
mechanical rule (§6), rather than as 444 individual judgment calls.

A **second semantic axis** that the task brief does not name, but which the implementation must
decide, is the pair of *paper anchor identifiers* `def:frame#Spherical` and `cor:spherical-finite`
(49 occurrences combined). These are external identifiers whose correct value is set by the paper,
not by us. §4 settles them against the paper source and supplies the exact replacement rows,
including pre-computed checksums.

---

## 2. Ground truth from the paper

Source of record: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
(read-only input, 438 KB).

Measured facts:

- The axiom item is now `\item[\it Saturation:]` (paper lines 976 and 2837). "Spherical" no
  longer appears as the axiom's name anywhere in the paper.
- **The paper's only surviving use of the word** is the ball-space footnote, paper line 2840:

  > `\textit{Saturation}` is the downward-directed-intersection condition `$\mathbf{S}_1^d$` of
  > the ball-space hierarchy--- the nest condition `$\mathbf{S}_1$` with a `$\supseteq$`-directed
  > system of balls in place of a nest--- and so is strictly stronger than the standard
  > `\textit{spherically complete}` condition, which is `$\mathbf{S}_1$` itself.

  This confirms the task brief's constraint exactly: the substantive ball-space claim survives
  intact, and "spherically complete" survives with it.
- The corollary label was renamed paper-side as well: `\label{cor:saturation-finite}`
  (paper line 3143), formerly `cor:spherical-finite`.
- Every paper cross-reference now reads `\textit{Saturation}` / `\ref{cor:saturation-finite}`
  (paper lines 1584, 3135, 3136, 3158, 3368, 3837, 3916, 4009, 4137, 4378).

So the rename target is `Saturation` / `saturation`, and the two anchor identifiers change too.

---

## 3. Measured occurrence census

Command used (reproducible):

```bash
git grep -io "spherical" -- . | grep -v "^specs/" | wc -l          # 444
git grep -io "spherically" -- . | grep -v "^specs/" | wc -l        # 3  (the KEEP set)
```

`specs/**` is deliberately out of scope: it holds historical task artifacts, and
`scripts/check-module-invariants.sh`'s own C15 scope comment states the same exclusion
("task artifacts routinely quote anchors that were live when they were written, and rewriting
history is not the goal"). See §7 for the two `specs/` files that are *live* rather than
historical.

| File | Total | Rename | Keep |
|---|---:|---:|---:|
| `FormalSystem/Semantics/TaskFrame.lean` | 112 | 110 | **2** |
| `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` | 48 | 48 | 0 |
| `FormalSystem/Examples/TemporalStructures.lean` | 39 | 39 | 0 |
| `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` | 28 | 28 | 0 |
| `FormalSystem/Semantics/Extension/Step.lean` | 24 | 24 | 0 |
| `FormalSystem/Semantics/Extension/Extension.lean` | 24 | 24 | 0 |
| `FormalSystem/Semantics/FrameAxioms.lean` | 17 | 17 | 0 |
| `typst/FormalFoundations.typ` | 16 | 16 | 0 |
| `typst/chapters/02-semantics.typ` | 16 | 16 | 0 |
| `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 12 | 12 | 0 |
| `FormalSystem/Semantics/IntNormalForm.lean` | 8 | 8 | 0 |
| `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean` | 8 | 8 | 0 |
| `FormalSystem/Semantics/Correspondence/DurationFrames.lean` | 7 | 7 | 0 |
| `FormalSystem/Metalogic/Independence/ClockFrame.lean` | 7 | 7 | 0 |
| `FormalSystem/Semantics/IntTransfer.lean` | 6 | 6 | 0 |
| `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` | 6 | 6 | 0 |
| `Tests/BimodalTest/Semantics/TaskFrameTest.lean` | 5 | 5 | 0 |
| `latex/subfiles/02-Semantics.tex` | 5 | 5 | 0 |
| `FormalSystem/Metalogic/Decidability/FMP/FiniteModel.lean` | 5 | 5 | 0 |
| `README.md` | 4 | 3 | **1** |
| `FormalSystem/Semantics.lean` | 4 | 4 | 0 |
| `docs/reference/API_REFERENCE.md` | 4 | 4 | 0 |
| `typst/sync-check-whitelist.txt` | 3 | 3 | 0 |
| `FormalSystem/Semantics/ShiftSet.lean` | 3 | 3 | 0 |
| `FormalSystem/Semantics/Extension/README.md` | 3 | 3 | 0 |
| `FormalSystem/Semantics/Extension/Admissible.lean` | 3 | 3 | 0 |
| `FormalSystem/Metalogic/Decidability/FMP/README.md` | 3 | 3 | 0 |
| `FormalSystem/Metalogic/Decidability/BiLasso/README.md` | 3 | 3 | 0 |
| `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean` | 3 | 3 | 0 |
| `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean` | 3 | 3 | 0 |
| `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` | 3 | 3 | 0 |
| `typst/SYNC-MAP.md` | 2 | 2 | 0 |
| `typst/notation/bimodal-notation.typ` | 2 | 2 | 0 |
| `FormalSystem/Metalogic/Decidability/IntPresentation.lean` | 2 | 2 | 0 |
| `typst/chapters/p3-ltl-to-tm.typ` | 1 | 1 | 0 |
| `Tests/BimodalTest.lean` | 1 | 1 | 0 |
| `scripts/check-module-invariants.sh` | 1 | 1 | 0 |
| `FormalSystem/Semantics/Validity.lean` | 1 | 1 | 0 |
| `FormalSystem/Semantics/Extension/Constraint.lean` | 1 | 1 | 0 |
| `docs/user-guide/architecture.md` | 1 | 1 | 0 |
| **TOTAL (40 files)** | **444** | **441** | **3** |

Note two files the task brief did not list but which are in scope:
`scripts/check-module-invariants.sh` (a code comment) and
`FormalSystem/Semantics/FrameAxioms.lean` (17 occurrences — the *largest* undeclared site,
carrying the four-axiom alignment docstring).

### 3.1 The three KEEP occurrences, verbatim

```
FormalSystem/Semantics/TaskFrame.lean:393:
  than the standard *spherically complete* condition, which is $\mathbf{S}_1$ itself. The name

FormalSystem/Semantics/TaskFrame.lean:394:
  "Spherical" is not a synonym for "spherically complete"; reading it as one understates the axiom.

README.md:80:
  ... which is *strictly stronger* than "spherically complete" (`S₁`). ...
```

Line 394 is the only line in the tree that contains **both** partitions: its `"Spherical"`
renames to `"Saturation"`, its `"spherically complete"` stays. After the edit it must read:

```
"Saturation" is not a synonym for "spherically complete"; reading it as one understates the axiom.
```

`README.md:80` also contains 3 RENAME-class occurrences, but all three live inside the interim
note the task brief requires deleted. After deleting the sentence
*"The Lean sources still carry this axiom under its former name Spherical (`TaskFrame.Spherical`,
the `spherical` field of `FrameOver`); renaming them to match is pending."*, README.md drops from
4 occurrences to 1, which is the KEEP occurrence.

---

## 4. The paper-anchor axis (second semantic decision)

Two anchor identifiers are cited across the tree. They are **not** free naming choices — the
correct value is whatever the paper's `\label{}` says.

### 4.1 `def:frame#Spherical` → `def:frame#Saturation` (31 occurrences, 13 files)

Files: `Examples/TemporalStructures.lean`, `Metalogic/Algebraic/FlowFrame.lean`,
`Metalogic/Decidability/FMP/{Filtration,FiniteModel}.lean`,
`Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`,
`Metalogic/Independence/ClockFrame.lean`,
`Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`,
`Semantics/Extension/Step.lean`, `Semantics/FrameAxioms.lean`, `Semantics/TaskFrame.lean`,
`Tests/BimodalTest/Semantics/TaskFrameTest.lean`, `latex/subfiles/02-Semantics.tex`,
`scripts/check-module-invariants.sh`.

**C15 impact: none.** `check-module-invariants.sh`'s C15 collects citations with the regex
`\b(def|thm|lem|cor|app|rmk):[A-Za-z0-9][A-Za-z0-9_-]*`, which stops before `#`. The sub-anchor
suffix is invisible to it; both spellings register only as the parent `def:frame`. This rename is
therefore C15-neutral and can be done freely.

### 4.2 `cor:spherical-finite` → `cor:saturation-finite` (18 occurrences, 6 files)

| File | Lines |
|---|---|
| `FormalSystem/Semantics/Extension/Extension.lean` | 35, 38, 64, 198 |
| `FormalSystem/Semantics/TaskFrame.lean` | 1003, 1014, 1042 |
| `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` | 16, 172, 222, 288, 293 |
| `typst/FormalFoundations.typ` | 899 |
| `typst/SYNC-MAP.md` | 418 |
| `typst/chapters/02-semantics.typ` | 252 |
| `typst/sync-check-whitelist.txt` | 59, 61 (functional entry), 80 |

**C15 impact: this one is gated.** C15 resolves every cited anchor against
`specs/paper-definitions-of-record.md`. `cor:spherical-finite` currently resolves via MANIFEST row
46. If the citations are renamed to `cor:saturation-finite` without updating that row, **C15
fails** (`N paper-anchor citation(s) resolve to nothing`). The rename and the record row must
therefore land in the **same commit**.

**Pre-computed replacement rows** (obtained from
`bash scripts/check-paper-definitions.sh --resolve "<spec>"` against the live paper):

```
# specs/paper-definitions-of-record.md, MANIFEST block

# row 11: was  def:frame#Spherical|item|def:frame|Spherical|92b407bc45ab62ce5bac22982c67e2555efb4a990ddf8e61fd7f1b45840bcf60
def:frame#Saturation|item|def:frame|Saturation|c293e9f830a2e1f0154d1ee7be2c7a121a7aa0ec4476266637e4fffaff345c60

# row 46: was  cor:spherical-finite|env|-|-|26ed8ff4c8b01f1dde980e075bc2e0bd45571951be82160bb184d59227b9f7b3
cor:saturation-finite|env|-|-|6456eb11cb2adf8b06c929c3f6b5d19dc581f9ba7a33af8a28e61ec675567d74
```

Resolved paper text behind those checksums:

```latex
\item[\it Saturation:] $\bigcap \mathcal{S} \neq \emptyset$ for any $\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments.%

\begin{Cthm} \label{cor:saturation-finite}
	Every task frame $\F = \tuple{W, \D, \Rightarrow}$ with finite $W$ satisfies \textit{Saturation}, choice-free.
\end{Cthm}
```

**Recommendation: do the rename and update both rows.** Justification: `check-paper-definitions.sh`
already reports both anchors as *unresolvable* at HEAD (see §5.3) — they are dangling right now.
Renaming them strictly improves the record rather than churning a healthy pin. The prose rows at
`specs/paper-definitions-of-record.md` lines 41, 108, 114, 130, 274–301, 433, 495, 1078–1081 also
mention the old names; updating the two MANIFEST rows is the only *functionally required* change,
and the prose can follow as a coherence pass.

**Fallback if the plan wants zero record churn**: leave `cor:spherical-finite` citations untouched
(all 18) while renaming everything else. C15 stays green, at the cost of the tree citing a paper
label that no longer exists. This is the strictly-smaller-blast-radius option and is defensible,
but it leaves a known-stale citation. The report recommends against it.

---

## 5. Coupling and gates

### 5.1 Measured baselines at `9cd17f308`

| Gate | Baseline | Notes |
|---|---|---|
| `lake build` (guarded, detached) | **exit 0** (13 s, fully cached) | green |
| `scripts/check-module-invariants.sh` | **exit 0**, ALL CHECKS PASSED | the task's stated gate; C15 passes with 47 anchors |
| `scripts/check-copyright-headers.sh` | exit 0 | |
| `scripts/typst-sync-check.sh` | **exit 1 — PRE-EXISTING RED** | 2 Check-1 violations, both from task 518: `` `@[aesop norm unfold]` `` and `` `@[aesop safe forward]` `` in `typst/chapters/p4-proof-automation.typ`. Unrelated to this rename. Do not attribute to 517; do not fix under 517 unless separately scoped. |
| `scripts/check-paper-definitions.sh` | **exit 1 — PRE-EXISTING RED** | 10 drifted anchors + 2 unresolvable. See §5.3. |
| `scripts/readme-lint.sh` | **exit 1 — PRE-EXISTING RED** | 1 missing README, 6 missing dates. Unrelated. |
| `scripts/check-evidence-probes.sh` | **exit 1 — PRE-EXISTING RED** | 4 probe `.lean` files missing under `specs/417_.../evidence/`. Unrelated. |

**Acceptance for 517 must be stated as: `lake build` exit 0 and `check-module-invariants.sh`
exit 0, with `typst-sync-check.sh` showing no *new* violations beyond the two pre-existing aesop
entries.** Anything stronger would fail for reasons that predate this task.

### 5.2 Build cost — plan this as one atomic edit, one build

`FormalSystem/Semantics/TaskFrame.lean` is the root of the semantics layer and is transitively
imported by essentially the whole tree (592 `FormalSystem` modules + 54 `Tests` modules). Lean
invalidates on whole-file hash, so **any** touch to `TaskFrame.lean` — docstring-only included —
forces a full re-elaboration. Consequences for the plan:

- Do **not** structure this as N phases each ending in a verification build. Every one of those
  builds is a full rebuild.
- Apply the complete rename across all 40 files, *then* run one build.
- The build must be detached and guarded, per
  `.claude/context/project/lean4/operations/long-builds.md`:
  ```bash
  bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --
  ```
  run under `Bash(run_in_background: true)`.

### 5.3 `check-paper-definitions.sh` is already red for unrelated reasons

At HEAD it reports **10 drifted definitions** — `def:task-relation`, `def:directed`, `def:frame`,
`def:frame#Compositionality`, `def:frame#Seriality`, `def:frame#Limit`, `def:world-history`,
`thm:extension`, `def:BLplus-defined`, `def:time-shift-histories` — plus the 2 unresolvable
spherical anchors. Most of the 10 are cosmetic (`\bf` → `\it` in item labels), but at least two
are substantive: `def:time-shift-histories` dropped its explicit translation function
(`\tau \approx_x^y \sigma` is now defined directly as `\tau(z) = \sigma(z + y - x)`), and
`def:BLplus-defined` changed item emphasis.

**This is a separate paper-drift-absorption concern and is explicitly out of scope for 517.**
Fixing the two spherical anchors will not make this script green, and the plan should not claim it
will. Recommend flagging it for a follow-up task.

### 5.4 `#guard_msgs` expected-output strings — hard failures if missed

`Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` pins `#print axioms` output as
docstrings. These are compile-checked; a stale fully-qualified name is a build error, not a
warning.

| Line | Current expected string | Must become |
|---|---|---|
| 245 | `'FormalSystem.Semantics.TaskFrame.spherical_of_finite' depends on axioms: [propext, Classical.choice, Quot.sound]` | `…TaskFrame.saturation_of_finite…` |
| 247 | `#print axioms FormalSystem.Semantics.TaskFrame.spherical_of_finite` | `…saturation_of_finite` |
| 268 | `'FormalSystem.Semantics.TaskFrame.spherical_of_subsingleton' depends on axioms: [propext]` | `…saturation_of_subsingleton` |
| 270 | `#print axioms FormalSystem.Semantics.TaskFrame.spherical_of_subsingleton` | `…saturation_of_subsingleton` |
| 282 | `'BimodalTest.Semantics.wlem_of_spherical' depends on axioms: [propext, Quot.sound]` | `'BimodalTest.Semantics.wlem_of_saturation'` |

Lines 229/231 pin `sInter_nonempty_of_directed_of_minimal`, which is **not** renamed — leave them
alone. (See §7 on why the `sInter_nonempty_of_*` helper family keeps its name.)

### 5.5 `scripts/typst-sync-check.sh` Check 1 — backtick resolution

Check 1 greps every backticked span in `typst/**/*.typ` against the Lean sources under
`FormalSystem/` (excluding `Boneyard/`), with `typst/sync-check-whitelist.txt` as the escape
hatch. Renamed spans that must continue to resolve after the edit:

| Backticked span (typst) | Resolves against (Lean) | Status after rename |
|---|---|---|
| `` `spherical` `` — emitted by `#let leanSpherical = raw("spherical")` (`notation/bimodal-notation.typ:122`) | `FrameOver` field `spherical` | must become `raw("saturation")`, resolving against the renamed field |
| `` `TaskFrame.Spherical TaskRel` `` (`chapters/02-semantics.typ:147`) | `TaskFrame.lean:691` `spherical : TaskFrame.Spherical TaskRel` | becomes `TaskFrame.Saturation TaskRel`, resolving against `saturation : TaskFrame.Saturation TaskRel` — **exact-span match, both halves must be renamed together** |
| `` `multiFamGen_spherical` `` (`FormalFoundations.typ:899`) | `FlowFrame.lean:308` | becomes `multiFamGen_saturation` |
| `` `cor:spherical-finite` `` (`FormalFoundations.typ:899`) | whitelisted (line 61) | whitelist entry must be renamed in lockstep |

Also rename the typst macro identifier `leanSpherical` → `leanSaturation` at its definition
(`notation/bimodal-notation.typ:122`) and its single use site (`chapters/02-semantics.typ:147`).

### 5.6 Test file rename

`Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` →
`Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean` (use `git mv`).

`lakefile.lean` uses `roots := #[\`BimodalTest]`, so no lakefile edit is needed, but five
citations must move with it:

| Site | Kind |
|---|---|
| `Tests/BimodalTest.lean:15` | `import BimodalTest.Semantics.SphericalFiniteAxiomTest` — **build-breaking if missed** |
| `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean:49` | path citation in docstring |
| `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean:67` | path citation in docstring |
| `FormalSystem/Metalogic/Decidability/BiLasso/README.md:56` | path citation — **C12-gated** (`all slash-shaped source paths in markdown resolve`) |
| `FormalSystem/Semantics/Extension/Extension.lean:75` | path citation in docstring |

---

## 6. The mechanical rename rule

Because the KEEP set is exactly the three occurrences of `spherically`, the whole rename reduces
to a global substitution with **two** carve-outs:

1. **`spherically` → unchanged** (3 sites: `TaskFrame.lean:393`, `TaskFrame.lean:394`,
   `README.md:80`). This is the KEEP set.
2. **`sphericality` → `saturation`** (1 site: `TaskFrame.lean:513`, in the `FrameOver` field
   summary "seriality, limit and sphericality"). A naive substitution would produce
   `saturationity`; handle this token explicitly *before* the global pass.

Everything else is a straight `Spherical → Saturation` / `spherical → saturation`. Verified: the
complete set of distinct tokens containing the stem, and what each becomes, is —

| Token | Count | Becomes |
|---|---:|---|
| `Spherical` (bare, prose + type name) | 396 | `Saturation` |
| `spherical` (bare, field + prose) | 125 | `saturation` |
| `TaskFrame.Spherical` | 41 | `TaskFrame.Saturation` |
| `spherical_of_finite` | 34 | `saturation_of_finite` |
| `F.spherical` | 24 | `F.saturation` |
| `wlem_of_spherical` | 19 | `wlem_of_saturation` |
| `spherical_of_subsingleton` | 13 | `saturation_of_subsingleton` |
| `spherical_of_permissive` | 13 | `saturation_of_permissive` |
| `multiFamGen_spherical` | 11 | `multiFamGen_saturation` |
| `spherically` | 9 (3 non-specs) | **unchanged** |
| `SphericalFiniteAxiomTest` | 9 | `SaturationFiniteAxiomTest` |
| `spherical_of_eq` | 8 | `saturation_of_eq` |
| `staticFrame_spherical` | 7 | `staticFrame_saturation` |
| `clockRel_spherical` | 5 | `clockRel_saturation` |
| `bundleFlow_spherical` | 5 | `bundleFlow_saturation` |
| `FrameOver.spherical` | 4 | `FrameOver.saturation` |
| `regionFrame_spherical` | 3 | `regionFrame_saturation` |
| `RefinedFilteredTaskFrame_spherical` | 2 | `RefinedFilteredTaskFrame_saturation` |
| `multiFamTaskFrameGen_spherical` | 2 | `multiFamTaskFrameGen_saturation` |
| `leanSpherical` | 2 | `leanSaturation` |
| `Sphericality` / `sphericality` | 1 | **`saturation`** (special-cased) |
| `trivialFrame_spherical`, `natFrame_spherical`, `intTimeFrame_spherical`, `intNatFrame_spherical`, `intBoolFrame_spherical`, `genericTimeFrame_spherical`, `genericNatFrame_spherical`, `multiFamTaskFrame_spherical`, `customFrame_spherical`, `FiniteFilteredTaskFrame_spherical`, `zTaskFrameV2_spherical`, `translationFrame.spherical`, `F.toFibre.spherical` | 1 each | `…_saturation` |

Suggested three-pass shape (sentinel-guarded so the carve-outs cannot be clobbered):

```bash
# pass 1: the one irregular derivation
sed -i 's/[Ss]phericality/saturation/g' FormalSystem/Semantics/TaskFrame.lean

# pass 2: protect "spherically" behind a sentinel
sed -i 's/spherically/\x01\x01SPHLY\x01\x01/g' <files>

# pass 3: the global rename, then restore
sed -i -e 's/Spherical/Saturation/g' -e 's/spherical/saturation/g' <files>
sed -i 's/\x01\x01SPHLY\x01\x01/spherically/g' <files>
```

**Post-condition assertion the plan should encode as its own acceptance check:**

```bash
# must print exactly 3 (the KEEP set), all inside "spherically complete"
git grep -io "spherical" -- . | grep -v "^specs/" | wc -l
```

Then handle by hand the two edits substitution cannot make:

- **`README.md:80`** — delete the interim sentence entirely (see §3.1).
- **`git mv`** the test file (§5.6).

---

## 7. Renamed Lean identifiers — the complete list (26)

**1 definition + 1 structure field + 24 theorems.** No `@[simp]`, `@[aesop]`, or other attribute
is attached to any of them (verified), and `FrameOver` is never built with a positional anonymous
constructor (verified — the only `⟨…⟩` is `TaskFrame`'s two-field `⟨D, F⟩` at
`TaskFrame.lean:1633`, which is unaffected). `spherical` is also the **last** field of
`FrameOver`, so field ordering cannot shift.

| # | Current | New | Site |
|---:|---|---|---|
| 1 | `TaskFrame.Spherical` (`def`) | `TaskFrame.Saturation` | `Semantics/TaskFrame.lean:412` |
| 2 | `FrameOver.spherical` (field) | `FrameOver.saturation` | `Semantics/TaskFrame.lean:691` |
| 3 | `TaskFrame.spherical` (flat-surface projection) | `TaskFrame.saturation` | `Semantics/TaskFrame.lean:1710` |
| 4 | `spherical_of_finite` | `saturation_of_finite` | `Semantics/TaskFrame.lean:1073` |
| 5 | `spherical_of_subsingleton` | `saturation_of_subsingleton` | `Semantics/TaskFrame.lean:1118` |
| 6 | `spherical_of_permissive` | `saturation_of_permissive` | `Semantics/TaskFrame.lean:1231` |
| 7 | `spherical_of_eq` | `saturation_of_eq` | `Semantics/TaskFrame.lean:1280` |
| 8 | `trivialFrame_spherical` | `trivialFrame_saturation` | `Semantics/TaskFrame.lean:1353` |
| 9 | `staticFrame_spherical` | `staticFrame_saturation` | `Semantics/TaskFrame.lean:1432` |
| 10 | `natFrame_spherical` | `natFrame_saturation` | `Semantics/TaskFrame.lean:1546` |
| 11 | `intTimeFrame_spherical` | `intTimeFrame_saturation` | `Examples/TemporalStructures.lean:113` |
| 12 | `intNatFrame_spherical` | `intNatFrame_saturation` | `Examples/TemporalStructures.lean:199` |
| 13 | `intBoolFrame_spherical` | `intBoolFrame_saturation` | `Examples/TemporalStructures.lean:304` |
| 14 | `genericTimeFrame_spherical` | `genericTimeFrame_saturation` | `Examples/TemporalStructures.lean:367` |
| 15 | `genericNatFrame_spherical` | `genericNatFrame_saturation` | `Examples/TemporalStructures.lean:467` |
| 16 | `multiFamGen_spherical` | `multiFamGen_saturation` | `Metalogic/Algebraic/FlowFrame.lean:308` |
| 17 | `multiFamTaskFrameGen_spherical` | `multiFamTaskFrameGen_saturation` | `Metalogic/Algebraic/FlowFrame.lean:357` |
| 18 | `bundleFlow_spherical` | `bundleFlow_saturation` | `Metalogic/Algebraic/FlowFrame.lean:521` |
| 19 | `RefinedFilteredTaskFrame_spherical` | `RefinedFilteredTaskFrame_saturation` | `Metalogic/Decidability/FMP/Filtration.lean:405` |
| 20 | `FiniteFilteredTaskFrame_spherical` | `FiniteFilteredTaskFrame_saturation` | `Metalogic/Decidability/FMP/FiniteModel.lean:215` |
| 21 | `regionFrame_spherical` | `regionFrame_saturation` | `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:295` |
| 22 | `clockRel_spherical` | `clockRel_saturation` | `Metalogic/Independence/ClockFrame.lean:156` |
| 23 | `zTaskFrameV2_spherical` | `zTaskFrameV2_saturation` | `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:522` |
| 24 | `multiFamTaskFrame_spherical` | `multiFamTaskFrame_saturation` | `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:834` |
| 25 | `wlem_of_spherical` | `wlem_of_saturation` | `Tests/…/SphericalFiniteAxiomTest.lean:195` |
| 26 | `customFrame_spherical` | `customFrame_saturation` | `Tests/…/TaskFrameTest.lean:98` |

(The task brief estimated "roughly 30"; the measured figure is 26.)

**Explicitly NOT renamed** — the shared helper family, whose names carry no axiom name:
`sInter_nonempty_of_directed_of_univ_or_singleton`, `sInter_nonempty_of_directed_of_minimal`
(`Semantics/TaskFrame.lean:977, 1023`), and `Algebraic.sInter_nonempty_of_directed_subsingleton`
(`Metalogic/Algebraic/FlowFrame.lean:116`).

Field-assignment sites that follow field #2 mechanically (21 `spherical := …` occurrences):
`TaskFrame.lean:1327, 1390, 1492`; `TemporalStructures.lean:88, 159, 259, 341, 418`;
`ClockFrame.lean:209`; `FlowFrame.lean:179`; `ReynoldsBridge.lean:464, 784`;
`Filtration.lean:344`; `RegionFrame.lean:208`; `ShiftSet.lean:186`; `IntTransfer.lean:159`;
`IntNormalForm.lean:480`; `DurationFrames.lean:155, 251`.

---

## 8. Homonym check — `Saturation` already exists (namespaced apart, no conflict)

`FormalSystem/Metalogic/Decidability/Saturation.lean` exists and is imported by six modules. It is
**tableau saturation**, an unrelated notion. Verified:

- The file declares **no** `namespace Saturation` — `Saturation` is only a *module path*
  component (`FormalSystem.Metalogic.Decidability.Saturation`), never an identifier in scope.
- The new axiom lands at `FormalSystem.Semantics.TaskFrame.Saturation`.
- No Lean-level ambiguity results, including inside `Metalogic/Decidability/FMP/*.lean`, which
  reference both trees.

`FrameClass.Sat` (a satisfaction predicate) is likewise unrelated and unaffected.

**Action for the plan**: none required, but the new `Saturation` docstring should say in one line
that it is unrelated to `Decidability/Saturation.lean`, so a future reader does not conflate them.

---

## 9. Out of scope, flagged for follow-up

1. **Paper drift beyond the rename** (§5.3) — 10 drifted anchors in
   `specs/paper-definitions-of-record.md`, two of them substantive
   (`def:time-shift-histories`, `def:BLplus-defined`). Warrants its own task.
2. **`latex/subfiles/02-Semantics.tex` fidelity gap (pre-existing)** — its transcription at lines
   77–78 and 85 says "for any **directed** family", while the paper says
   "for any **$\supseteq$-directed** family". Renaming `Spherical` → `Saturation` there does not
   fix the missing `\supseteq` qualifier. The Lean docstrings already carry the qualifier
   correctly (`TaskFrame.lean:386`). Recommend fixing it in the same pass (one-line change,
   improves fidelity, no gate depends on it) but call it out explicitly so it is not mistaken for
   a rename artifact.
3. **`Tests/BimodalTest/Semantics/README.md` (pre-existing)** — its file table lists only 4 of the
   6 `.lean` files in the directory; `SphericalFiniteAxiomTest.lean` and
   `DependentUltraproductProbe.lean` are absent. The file rename is a natural moment to add the
   row, but nothing gates it.
4. **`specs/**` occurrences (227)** — historical task artifacts; do not rewrite. Two `specs/`
   files are *live* rather than historical and are addressed above:
   `specs/paper-definitions-of-record.md` (§4.2, two MANIFEST rows required) and
   `specs/TODO.md` / `specs/state.json` (task descriptions; no action needed — task 519's
   description already reads "Spherical/Saturation").

---

## 10. Sequencing

`specs/TODO.md:200` (the Wave 2 core-utilities task) records the dependency explicitly:

> SEQUENCING: after task 517 (Spherical → Saturation) — Helper D collapses the seven proofs 517
> renames, so 517 must land first or it renames copies about to become one.

That task plans to introduce `spherical_of_fib_subsingleton` and collapse seven duplicated
"deterministic frame ⇒ Spherical" proofs into one helper. **517 must land before it**, and when it
does, the planned helper should be named `saturation_of_fib_subsingleton`. Neither
`spherical_of_fib_subsingleton` nor `finite_frame_discharge_of_spherical_and_limit` exists in the
live tree today (both are `specs/`-only: a planned name and an archived task slug respectively).

---

## 11. Suggested phase shape

Given §5.2 (every build is a full rebuild), a single-phase edit with one verification build is the
right shape. If the plan wants checkpoints, split by *commit*, not by *build*:

1. **Edit** — apply §6's mechanical rule across the 40 files; `git mv` the test file; hand-edit
   `README.md:80`; update the two MANIFEST rows in `specs/paper-definitions-of-record.md`; update
   `typst/sync-check-whitelist.txt`; rename `leanSpherical` → `leanSaturation`.
2. **Assert** — `git grep -io "spherical" -- . | grep -v "^specs/" | wc -l` returns exactly `3`,
   and all 3 are inside "spherically complete".
3. **Verify** — one detached, guarded `lake build`; then
   `scripts/check-module-invariants.sh` (must stay exit 0, C15 must still report all anchors
   resolving); then `scripts/typst-sync-check.sh` (must show the same 2 pre-existing aesop
   violations and no new ones).
4. **Commit**.

---

## Appendix: reproduction commands

```bash
# census
git grep -io "spherical"   -- . | grep -v "^specs/" | wc -l   # 444
git grep -io "spherically" -- . | grep -v "^specs/" | wc -l   # 3
git grep -o  "def:frame#Spherical"  -- . | grep -v "^specs/" | wc -l   # 31
git grep -o  "cor:spherical-finite" -- . | grep -v "^specs/" | wc -l   # 18

# declarations
git grep -h -oE "^(theorem|def) [A-Za-z_'0-9]*[Ss]pherical[A-Za-z_'0-9]*" -- '*.lean' | sort   # 25 (+1 field)

# paper ground truth
grep -n "Saturation\|spherical" /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex

# new anchor checksums
bash scripts/check-paper-definitions.sh --resolve "cor:saturation-finite|env|-|-"
bash scripts/check-paper-definitions.sh --resolve "def:frame#Saturation|item|def:frame|Saturation"

# baselines
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --   # exit 0
bash scripts/check-module-invariants.sh                            # exit 0
bash scripts/typst-sync-check.sh                                   # exit 1 (pre-existing)
bash scripts/check-paper-definitions.sh                            # exit 1 (pre-existing)
```
