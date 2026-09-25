# Implementation Plan: Task #672

- **Task**: 672 - Strengthen the `.ZTime` sharpness results to a full `ValidIn fc φ ↔ fc = .ZTime`
  characterization for `Axiom.prior_UZ` and `Axiom.z1`, and pin the resulting headline theorems on
  `FormalSystem/MainResults.lean`'s build-time axiom audit
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Dependencies**: None open. Builds on task 670's landed
  `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` (292 lines, sorry-free,
  axiom-declaration-free), which is present in the tree.
- **Research Inputs**:
  `specs/672_ztime_full_characterization_and_axiom_pin/reports/01_ztime-characterization-axiom-pin.md`
- **Artifacts**: plans/01_ztime-characterization-axiom-pin.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Six new declarations in `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` — four
non-validity corollaries at `FrameClass.Dense` and `FrameClass.RTime`, and two
`ValidIn fc φ ↔ fc = FrameClass.ZTime` biconditionals — convert four scattered refutations into
one exhaustive characterization of the minimal frame class of each `.ZTime`-tagged axiom. The
six names are then made build-visible on `FormalSystem/MainResults.lean`'s axiom-audit page, which
requires a coupled four-site edit across three files (the page, **both** C14 heredocs in
`scripts/check-module-invariants.sh`, and the C27 count in `scripts/debug-artifact-allowlist.txt`).
Definition of done: all six theorems sorry-free and axiom-declaration-free, the pin complete,
`bash scripts/check-module-invariants.sh` green across every check group, and the measured axiom
set still exactly `[propext, Classical.choice, Quot.sound]`.

### Research Integration

The research report elaborated a byte-for-byte simulation of the edited module with `lake env lean`
and reports **0 errors, 0 warnings**, with all six new declarations measuring
`[propext, Classical.choice, Quot.sound]`. Its Appendix A1 carries verbatim proof terms; this plan
directs the implementer to transcribe rather than re-derive them. Four report findings change the
dispatch's own instructions and are carried into the phases below:

- **F4 / R3 — the dispatch's `realOrder` route does not compile.** Importing
  `FormalSystem.Metalogic.DedekindNonCompactness` produces `Ambiguous term realOrder`, because
  `FormalSystem.Semantics.realOrder` (`Semantics/Correspondence/RigidityReal.lean:81`) is a second
  declaration of the same base name. Option B (import
  `FormalSystem.Semantics.Correspondence.RigidityReal`, use the bare `realOrder`) is verified
  working and is this plan's route; Option A (a local `ztimeSharpRealOrder` abbrev over
  `Mathlib.Algebra.Order.Archimedean.Real.Basic`) is the verified fallback.
- **F6 — the pin is a FOUR-edit-site pin, not three.** `scripts/check-module-invariants.sh` carries
  two coupled heredocs, `C14_BASELINE` (opens line 1772, `<<'C14BASE'`) and the generated `C14LEAN`
  Lean file (opens line 1969), compared by exact string equality. The script's own comment at line
  1737 says they "must list the same declarations in the same order. Edit them together."
  The dispatch and task 670's Phase 6 task list both name only `C14_BASELINE`.
- **F5 — the dispatch's build-cost warning points at the wrong file.** `MainResults.lean` is a
  leaf: editing it invalidates 2 modules. The genuinely invalidating edit is `ZTimeSharpness.lean`,
  whose reverse-dependency set is 12 modules. Neither is a full tree; only
  `ProofSystem/Axioms.lean` would be, which this plan declines (R4).
- **F10 / F11 — ordering constraints.** `--emit-inventory` must run after the last docstring edit,
  and the two biconditionals would be C17-dead if the pin half were not landed with them.

### Prior Plan Reference

No prior plan exists for task 672. Task 670's plan
(`specs/670_minframeclass_sharpness_prior_uz_z1/plans/01_ztime-sharpness-theorems.md`) closed its
Phases 5 and 6 as `[COMPLETED WITH EXCLUSIONS]`; those two Reasoned Exclusions tables specify this
task's work item by item and were used as a scope check, not as a template. Two calibrations
carried over from it: `by decide` fails on `FrameClass` `<` (only `≤` has a `DecidableRel`
instance), and the `atomic-batch` commit mode it declared for its Phase 6 pin is reused verbatim
here for Phase 3.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no roadmap phases are requested, so no
ROADMAP.md consultation or update is in scope.

## Goals & Non-Goals

**Goals**:

- `not_validIn_dense_prior_UZ`
- `not_validIn_dense_z1`
- `not_validIn_rtime_prior_UZ`
- `not_validIn_rtime_z1`
- `prior_UZ_validIn_iff_ztime`
- `z1_validIn_iff_ztime`
- Make those six names build-visible on the MainResults axiom-audit page, pinned by C14 and
  admitted by C21, with the C27 allow-list count set to the value the gate measures.
- Bring the four in-scope prose ledgers up to the stronger claim, and regenerate the inventory
  blocks last so INV stays green.

**Non-Goals**:

- Sharpness for the `.Dense` and `.RTime` rows of `Axiom.minFrameClass` (`density`,
  `dense_indicator`, `prior_U_gap`, `sep`). Separate work; explicitly excluded by the dispatch's
  SCOPE clause.
- Editing `FormalSystem/ProofSystem/Axioms.lean`'s `Axiom.minFrameClass` docstring. Its current
  text remains true after this change, merely weaker than what is then proved, and the edit costs
  a full-tree rebuild (report R4).
- Any change under `docs/`, to the repository-root `README.md`, or to the ModelChecker repository.
  The stale counts found at `README.md:11`, `README.md:463` and
  `docs/development/CI_CD_PROCESS.md:95` are recorded as follow-ups, not as task work.
- New `docs/theorem-index.md` rows (report D5: would pull in C15's paper-anchor obligation for no
  gate benefit, and `docs/` is out of scope anyway).
- Any schematic `∀ φ` biconditional. `Axiom.prior_UZ ⊥` has an unsatisfiable antecedent and *is*
  `.Base`-valid, so the schematic form would be false; every new statement is at `Formula.atom p`
  (report D2).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Editing `C14_BASELINE` alone and not the `C14LEAN` heredoc, as the dispatch's wording invites | H | H | Phase 3 treats the pin as four edit sites; both heredocs are appended to in the same order, per the script's line-1737 comment |
| `Ambiguous term realOrder` from following the dispatch's `DedekindNonCompactness` route | H | H | Phase 1 uses Option B (`RigidityReal`, bare `realOrder`) with a comment recording the latent ambiguity; Option A is the verified fallback |
| A new import in `ZTimeSharpness.lean` reintroduces the `realOrder` ambiguity in a *downstream* module that sees both namespaces | H | L | Phase 2 exists precisely to catch this: a scoped build over the 12-module reverse-dependency set before any expensive coupled edit |
| `Unknown identifier ℝ` / `Real.exists_isLUB` if no import is added | M | H | Exactly one import is added (report F3); `Mathlib.Data.Real.Basic` is insufficient and `Mathlib.Data.Real.Archimedean` is deprecated |
| Partial pin left in the tree after a failure (fails C21) | H | M | Phase 3 is `Commit Mode: atomic-batch`; on failure all four edit sites revert together |
| INV failing because inventories were regenerated before the last docstring edit | M | M | Phase 4 runs `bash scripts/check-module-invariants.sh --emit-inventory` as its final step; `scripts/readme-inventory.sh` is only a pointer script and is not used |
| Over-budgeting a "full rebuild" the dispatch warns about but that is not needed | L | M | Report F5: one scoped build in Phase 2, one confirming build in Phase 5 |
| The two biconditionals land C17-dead because only the first half ships | M | L | The two halves reference each other; Phases 1-4 are one change and the task is not complete until Phase 5 is green |
| `by decide` attempted on `FrameClass` `<` | L | L | Report D3's route (`cases fc` over four constructors) needs neither the strict order nor `decide` |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase
consumes an artifact the previous one produces, and the ordering of Phases 3 and 4 is itself a
gate constraint (INV regeneration must follow the last content edit).

### Phase 1: Characterization theorems in ZTimeSharpness.lean [NOT STARTED]

**Goal**: Six new sorry-free declarations exist in
`FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` and the file elaborates clean under
`lake env lean`, with every new name measuring `[propext, Classical.choice, Quot.sound]`.

**Tasks**:

- [ ] Add `import FormalSystem.Semantics.Correspondence.RigidityReal` beside the two existing
      imports (`DurationFrames`, `Soundness`) at the top of the file.
- [ ] Add a one-line comment at the import recording that the bare `realOrder` below resolves
      uniquely to `FormalSystem.Semantics.realOrder` only while
      `FormalSystem.Metalogic.DedekindNonCompactness` stays out of this module's import closure;
      a future import of it reintroduces the `Ambiguous term realOrder` error (report F4).
- [ ] Add `not_validIn_dense_prior_UZ` and `not_validIn_dense_z1`, each discharging
      `Sat FrameClass.Dense` as `⟨inferInstance, inferInstance⟩` over the existing
      `ztimeSharpOrder` (line 217) and delegating to the existing generic lemmas
      `not_validOn_prior_UZ_dense` / `not_validOn_z1_dense`.
- [ ] Add `not_validIn_rtime_prior_UZ` and `not_validIn_rtime_z1`, each discharging
      `Sat FrameClass.RTime` as
      `⟨inferInstance, inferInstance, fun _ hne hbd => Real.exists_isLUB hne hbd⟩` over
      `realOrder`, the same three-component idiom `DedekindNonCompactness.lean:437` already uses.
- [ ] Add `prior_UZ_validIn_iff_ztime` and `z1_validIn_iff_ztime`, each at an **explicit**
      `(fc : FrameClass)` binder (report D1), proving the forward direction by `cases fc` over all
      four constructors with `absurd` arms against the four non-validity results plus `rfl` at
      `ZTime`, and the reverse by `rintro rfl; exact prior_UZ_valid (Formula.atom p)` /
      `exact z1_valid (Formula.atom p)`. Do **not** route through `eq_base_of_lt_ztime`: `.Dense`
      and `.RTime` are incomparable to `.ZTime`, not below it (report D3).
- [ ] Write a `/-- … -/` docstring for each of the six declarations. C16's `docBlame` and C19 both
      read them; the research Appendix deliberately elided them, so they must be authored here.
- [ ] Place all six before `end FormalSystem.Metalogic.Independence` (currently line 292), in the
      existing section structure.
- [ ] Verify with `lake env lean FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` — no
      rebuild needed; this was sufficient for every result in the research report.
- [ ] Confirm each new name's axiom set with `lean_verify` (or a scratch `#print axioms` run that
      is **not** left in the file — C27 fails on any new in-file directive outside
      `MainResults.lean`).

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly one import and six new declarations in one file; the four
non-validity corollaries are one-liners off the two existing generic lemmas and no new
countermodel construction is required anywhere (report F2). Confirm at implementation time by a
clean `lake env lean` run on the single edited file with zero errors and zero warnings, and by the
measured axiom set of all six names being `[propext, Classical.choice, Quot.sound]`. If the
`.RTime` pair needs anything beyond the one import, stop and reassess against report Option A
before widening.

**Files to modify**:

- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` - one added import, one comment, six
  new documented theorems appended before the namespace `end`.

**Verification**:

- `lake env lean FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` exits 0 with no `error:`
  and no `warning:` lines (in particular, no deprecation warning — that signals the wrong Mathlib
  import was chosen).
- `grep -n 'sorry' FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` finds no occurrence,
  and no `axiom ` declaration was introduced.
- Each of the six names reports `[propext, Classical.choice, Quot.sound]`.

---

### Phase 2: Scoped reverse-dependency build [NOT STARTED]

**Goal**: The new import in `ZTimeSharpness.lean` is proved not to break any module downstream of
it — specifically, no downstream module now sees `realOrder` ambiguously.

**Tasks**:

- [ ] Re-derive the reverse-dependency set rather than trusting the report's figure:
      `grep -rln '^import FormalSystem.Metalogic.Independence.ZTimeSharpness$' FormalSystem Tests BimodalTools`,
      then iterate the same grep up the aggregator chain
      (`…Independence` → `…Metalogic` → consumers).
- [ ] Run one detached scoped build over that set, via
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence`
      (and the aggregator target the grep chain identifies) under `Bash(run_in_background: true)`.
- [ ] Wait with the bounded waiter idiom from `context/patterns/bounded-build-waiter.md`: a hard
      timeout, writer liveness via `kill -0` on the captured PID. Never `pgrep -f`, never
      `ps | grep`, one waiter per log.
- [ ] Grep the build log specifically for `Ambiguous term` and for `realOrder`; a hit here is the
      Option-B failure mode and is the signal to switch to Option A (report R3) rather than to
      patch call sites.

**Timing**: 0.75 hours (mostly build wall-time)

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: the report measures the reverse-dependency set of `ZTimeSharpness.lean` at
**12 modules** (`Independence.lean` → `Metalogic.lean` → `MainResults.lean`,
`Examples/Walkthrough.lean`, six `Tests/BimodalTest/Integration/*.lean`, plus root
`FormalSystem.lean`), and this is NOT a full-tree rebuild. Confirm by re-running the
`grep -rln '^import …$'` chain above before the build and comparing the module list to that
enumeration; if the real set is materially larger, re-budget the build before starting it rather
than discovering the cost mid-wait.

**Files to modify**: none (verification-only phase).

**Verification**:

- The scoped build exits 0.
- `grep -c 'Ambiguous term' <build log>` returns 0.
- No `error:` line anywhere in the build log.

---

### Phase 3: The coupled four-site axiom pin [NOT STARTED]

**Goal**: The six new names plus the four existing headline names are pinned on
`FormalSystem/MainResults.lean` and admitted by C21, with C14 and C27 both green.

**Tasks**:

- [ ] Append a new `/-! ## … -/` section to `FormalSystem/MainResults.lean` (currently 254 lines,
      last section `Decidability`), in the same prose shape the existing sections use: a short
      paragraph stating what the group claims, a `*` bullet per name, and the module that proves
      them.
- [ ] Add six `#check @…` lines and six `#print axioms …` lines for
      `FormalSystem.Metalogic.Independence.prior_UZ_minFrameClass_sharp`,
      `…z1_minFrameClass_sharp`, `…not_derivable_base_prior_UZ`, `…not_derivable_base_z1`,
      `…prior_UZ_validIn_iff_ztime`, `…z1_validIn_iff_ztime`.
- [ ] Append the six matching `'<name>' depends on axioms: [propext, Classical.choice, Quot.sound]`
      lines to `C14_BASELINE` in `scripts/check-module-invariants.sh` (heredoc opens line 1772,
      closes at the `C14BASE` terminator).
- [ ] Append the six matching `#print axioms <name>` lines to the `C14LEAN` heredoc in the same
      script (opens line 1969, closes at the `C14LEAN` terminator), **in the identical order**.
      The two heredocs are compared by exact string equality; editing one alone fails C14 with a
      baseline divergence (report F6, and the script's own line-1737 comment).
- [ ] Write each baseline line on a SINGLE line. C14 rejoins `#print axioms` continuation lines
      with `sed -e ':a' -e '$!N' -e 's/\n / /' -e 'ta'` before comparing (report F8).
- [ ] Run `bash scripts/check-module-invariants.sh` and read C27's reported count for
      `FormalSystem/MainResults.lean` off the failure line
      (`FAIL  C27  … allow-list count(s) disagree with the tree` → `<path>: allow-list W, tree G`).
      Set `scripts/debug-artifact-allowlist.txt:24` to the reported `tree` value. Do **not**
      compute it by arithmetic.
- [ ] Re-run the gate and confirm C14, C21 and C27 are all green together.

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: four edit sites across three files (`MainResults.lean`, two heredocs in
`check-module-invariants.sh`, `debug-artifact-allowlist.txt`), adding 12 live directive lines
(6 `#check` + 6 `#print axioms`) to a file whose allow-list entry currently reads `54`, and 6
entries to each of two heredocs that currently hold 192 each. Confirm at implementation time by:
re-counting each heredoc (`grep -c 'depends on axioms'` inside `C14_BASELINE`,
`grep -c '^#print axioms'` inside `C14LEAN`) and asserting both moved 192 → 198 and remain equal;
and by taking the new allow-list value from the gate's own C27 report, never from `54 + 12`.

**Files to modify**:

- `FormalSystem/MainResults.lean` - new trailing section: prose, 6 `#check`, 6 `#print axioms`.
- `scripts/check-module-invariants.sh` - 6 lines appended to `C14_BASELINE`, 6 corresponding lines
  appended to `C14LEAN`, same order in both.
- `scripts/debug-artifact-allowlist.txt` - line 24's count for `FormalSystem/MainResults.lean`,
  set to the gate-reported value.

**Verification**:

- `bash scripts/check-module-invariants.sh` reports C14 PASS, C21 PASS, C27 PASS in one run.
- Both heredocs carry the same number of entries in the same order.
- Every one of the six new baseline lines reads exactly
  `[propext, Classical.choice, Quot.sound]`.
- If any part of the pin cannot be completed, all four edit sites are reverted together rather
  than leaving a partial pin (which fails C21).

---

### Phase 4: Prose ledgers and inventory regeneration [NOT STARTED]

**Goal**: Every in-scope prose ledger states the stronger claim, and the generated inventory blocks
match the post-edit line counts.

**Tasks**:

- [ ] Extend `ZTimeSharpness.lean`'s module docstring: add the six new names to the `## Main
      results` list (currently lines ~78-88), and upgrade the `## Why the lower bound is wanted`
      paragraph from the `.Base` claim to the full characterization. The module as it stands
      deliberately states the `.Base` claim only and declines to upgrade it, so this edit is valid
      only now that the stronger theorems exist.
- [ ] Update `FormalSystem/Metalogic/Independence.lean` item 6 (line 55) and its `## Contents`
      entry for `Independence/ZTimeSharpness.lean` (line 111).
- [ ] Update `FormalSystem/Metalogic/Independence/README.md` item 9 (line 36) and its
      `## Key Results` bullet (line 146).
- [ ] Fill the pre-existing `<!-- TODO: add description -->` in that README's generated inventory
      row for `ZTimeSharpness.lean` (line 109) while the file is already being edited.
- [ ] Correct `FormalSystem/MainResults.lean`'s "105 in all" prose (line ~49) to the figure
      actually pinned. This site IS in scope; the repository-root `README.md` copies of the same
      stale number are NOT, and are left as follow-ups.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` as the **last** step of this
      phase, after every docstring edit. This is the real command that propagates counts into
      several READMEs; `scripts/readme-inventory.sh` is only a pointer script and must not be used
      here.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: five in-scope prose sites (the `ZTimeSharpness.lean` docstring's two
sections, `Independence.lean` lines 55 and 111, `Independence/README.md` lines 36 and 146, the
README inventory-row description at line 109, and `MainResults.lean`'s "105 in all"), and the
corrected audit figure is 4 names pinned by C2 plus 192 by C14 = 196 today, becoming **202** after
Phase 3. Confirm both at implementation time: re-locate each site by content (`grep -n`), not by
the line numbers above, which shift as earlier edits land; and re-derive the 202 by counting both
baselines after Phase 3 rather than trusting this arithmetic — write what the count shows.

**Files to modify**:

- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` - module docstring only.
- `FormalSystem/Metalogic/Independence.lean` - item 6 and the `## Contents` entry.
- `FormalSystem/Metalogic/Independence/README.md` - item 9, the `## Key Results` bullet, the
  inventory-row description, and whatever `--emit-inventory` rewrites.
- `FormalSystem/MainResults.lean` - the pinned-declaration count in the prose preamble.

**Verification**:

- Every changed hunk lies inside a comment, docstring, or markdown region — read the diff through
  and confirm no edit crosses a `-/` or fence boundary.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 (a rewrite would
  change no byte).
- No ledger still states the weaker `.Base`-only claim as the module's headline result.

---

### Phase 5: Confirming full build and gate [NOT STARTED]

**Goal**: The whole change is green end to end, sorry-free, axiom-declaration-free, with the
measured axiom set unchanged.

**Tasks**:

- [ ] Run one detached guarded full build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` under
      `Bash(run_in_background: true)`, waiting with the bounded `kill -0`-on-captured-PID idiom.
- [ ] Run `bash scripts/check-module-invariants.sh` in full (not `--no-build`) and assert C1, C2,
      C3, C14, C16, C17, C19, C20, C21, C27 and INV are all green.
- [ ] Confirm C3's inventory still reports no `sorryAx` and no new `axiom` declaration anywhere in
      `FormalSystem/`.
- [ ] Re-measure the axiom set of all ten pinned names on the new MainResults section and confirm
      each is exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] Confirm C17 finds no dead declaration among the six new names (each of the four corollaries
      is consumed by a biconditional; each biconditional is named on the audit page and in the
      prose ledgers — report F11).
- [ ] Commit the work per `rules/git-workflow.md`, with Phase 3's four edit sites in one
      atomic-batch commit.

**Timing**: 0.5 hours (mostly build and gate wall-time)

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**: none (verification-only phase).

**Verification**:

- `lake build` exits 0 with no errors and no new warnings.
- `bash scripts/check-module-invariants.sh` exits 0 with every check group green.
- The measured axiom set is `[propext, Classical.choice, Quot.sound]` for every pinned name.

---

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.Correspondence.DurationFrames
import FormalSystem.Metalogic.Soundness
import FormalSystem.Semantics.Correspondence.RigidityReal

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace FormalSystem.Metalogic.Independence

theorem not_validIn_dense_prior_UZ (p : Atom) :
    ¬ ValidIn FrameClass.Dense
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

theorem not_validIn_dense_z1 (p : Atom) :
    ¬ ValidIn FrameClass.Dense
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

theorem not_validIn_rtime_prior_UZ (p : Atom) :
    ¬ ValidIn FrameClass.RTime
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

theorem not_validIn_rtime_z1 (p : Atom) :
    ¬ ValidIn FrameClass.RTime
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

theorem prior_UZ_validIn_iff_ztime (p : Atom) (fc : FrameClass) :
    ValidIn fc ((Formula.atom p).someFuture.imp
      (Formula.untl (Formula.atom p).neg (Formula.atom p)))
      ↔ fc = FrameClass.ZTime := sorry

theorem z1_validIn_iff_ztime (p : Atom) (fc : FrameClass) :
    ValidIn fc (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
      ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture))
      ↔ fc = FrameClass.ZTime := sorry

end FormalSystem.Metalogic.Independence
```

## Testing & Validation

- [ ] `lake env lean FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` — 0 errors,
      0 warnings (Phase 1).
- [ ] Scoped build over the reverse-dependency set — exits 0, no `Ambiguous term` in the log
      (Phase 2).
- [ ] `bash scripts/check-module-invariants.sh` — C14, C21, C27 green together after the pin
      (Phase 3).
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` — exits 0 after the last
      docstring edit (Phase 4).
- [ ] Full `lake build` — exits 0 (Phase 5).
- [ ] Full `bash scripts/check-module-invariants.sh` — every check group green (Phase 5).
- [ ] Axiom-set assertion: all ten names on the new MainResults section measure
      `[propext, Classical.choice, Quot.sound]`.
- [ ] No `sorry`, no `sorryAx`, no new `axiom` declaration anywhere in the diff.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` — one added import, six new documented
  theorems, upgraded module docstring.
- `FormalSystem/MainResults.lean` — new axiom-audit section (prose, 6 `#check`, 6 `#print axioms`),
  corrected pinned-declaration count in the preamble.
- `scripts/check-module-invariants.sh` — 6 new entries in each of the two C14 heredocs.
- `scripts/debug-artifact-allowlist.txt` — updated count for `FormalSystem/MainResults.lean`.
- `FormalSystem/Metalogic/Independence.lean`,
  `FormalSystem/Metalogic/Independence/README.md` — upgraded ledger entries and regenerated
  inventory blocks.
- `specs/672_ztime_full_characterization_and_axiom_pin/plans/01_ztime-characterization-axiom-pin.md`
  — this plan.
- Follow-ups recorded, not executed: the stale "105" counts at `README.md:11` and `README.md:463`,
  and the stale `54` breakdown at `docs/development/CI_CD_PROCESS.md:95`.

## Rollback/Contingency

- **Phase 3 is the only all-or-nothing unit.** A partial pin fails C21, so if any of its four edit
  sites cannot be completed, revert all four together — `MainResults.lean`'s new section, both
  heredocs, and the allow-list count — leaving the tree in its pre-pin state. This is the reason
  the phase declares `Commit Mode: atomic-batch`.
- **Phases 1, 2, 4 and 5 are individually revertible.** Phase 1's edits are purely additive to one
  module; Phase 4's are confined to comments and markdown. Each green sub-step is committed as it
  happens (`rules/git-workflow.md`'s Commit-Per-Green-Substep Mandate), so reverting means dropping
  the last commit, not unwinding a batch.
- **If Option B fails** (a downstream `Ambiguous term realOrder` surfaces in Phase 2), do not patch
  downstream call sites. Switch `ZTimeSharpness.lean` to Option A: replace the `RigidityReal`
  import with `Mathlib.Algebra.Order.Archimedean.Real.Basic`, add
  `noncomputable abbrev ztimeSharpRealOrder : TemporalOrder := TemporalOrder.of ℝ` mirroring the
  existing `ztimeSharpOrder`, and substitute that name in the two `.RTime` proofs. Both forms were
  elaborated clean by the research.
- **If a whole-tree rollback of uncommitted work becomes necessary**, take a snapshot first rather
  than running a bare destructive git command: see `context/contracts/recovery.md`'s rollback rung
  for the exact `git-snapshot.sh` invocation shape, including its `--allow-out-of-scope` override
  for the deliberate whole-tree case.
