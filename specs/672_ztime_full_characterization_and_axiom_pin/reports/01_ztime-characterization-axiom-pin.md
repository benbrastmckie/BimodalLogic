# Research Report: Task #672

**Task**: 672 - Strengthen `.ZTime` sharpness to a full `ValidIn fc φ ↔ fc = .ZTime`
characterization for `Axiom.prior_UZ` and `Axiom.z1`, and pin the headline theorems on
`FormalSystem/MainResults.lean`'s build-time axiom audit
**Started**: 2026-09-25T00:00:00Z
**Completed**: 2026-09-25T00:00:00Z
**Effort**: 3-5 hours (one scoped rebuild + one gate run + one confirming gate run)
**Dependencies**: Task 670's landed `ZTimeSharpness.lean` (present, sorry-free); no open blockers
**Sources/Inputs**:
- Codebase (`FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`,
  `FormalSystem/Semantics/{FrameProperty,FrameClassValidity,Validity}.lean`,
  `FormalSystem/Semantics/Frames/Standard.lean`,
  `FormalSystem/Semantics/Correspondence/{DurationFrames,RigidityReal}.lean`,
  `FormalSystem/Metalogic/{Soundness,DedekindNonCompactness}.lean`,
  `FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/MainResults.lean`,
  `scripts/check-module-invariants.sh`, `scripts/debug-artifact-allowlist.txt`,
  `scripts/lib/lean_debug_artifacts.py`)
- Direct elaboration with `lake env lean` on a byte-for-byte simulation of the edited module
- Prior artifacts: `specs/670_minframeclass_sharpness_prior_uz_z1/` report 01, plan 01
  (Phases 5 and 6 with their Reasoned Exclusions tables), summary 01 (Follow-ups)
**Artifacts**:
- `specs/672_ztime_full_characterization_and_axiom_pin/reports/01_ztime-characterization-axiom-pin.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The entire first half is already verified end-to-end.** A byte-for-byte simulation of the
  edited `ZTimeSharpness.lean` — four new non-validity corollaries plus the two `ValidIn fc φ ↔
  fc = .ZTime` characterizations — elaborates with **zero errors and zero warnings**, and all six
  new declarations measure exactly `[propext, Classical.choice, Quot.sound]`. Verbatim proof
  terms are in the Appendix; the implementer can transcribe rather than re-derive.
- **The `.RTime` half needs one new import, and the dispatch's suggested route for it is a
  trap.** `ℝ` is *not* in `ZTimeSharpness.lean`'s current import closure. Importing
  `FormalSystem.Metalogic.DedekindNonCompactness` for its `realOrder` produces an **`Ambiguous
  term realOrder`** error, because `FormalSystem.Semantics.realOrder`
  (`Semantics/Correspondence/RigidityReal.lean:81`) is a second declaration of the same base
  name. Two clean alternatives are verified working (Option B recommended, Option A fallback).
- **The dispatch's build-cost warning is wrong in the direction that costs budget.**
  `MainResults.lean` is a **leaf**: nothing imports it except the root aggregator
  `FormalSystem.lean`. Editing it rebuilds two modules, not the tree. The genuinely
  invalidating edit is `ZTimeSharpness.lean`, whose reverse-dependency set is exactly
  **12 modules** (enumerated below) — still not a full tree. A full-tree rebuild is forced only
  by editing `ProofSystem/Axioms.lean`, which is optional prose and should be declined or
  deliberately budgeted.
- **The three-file pin is really a FOUR-edit-site pin.** `scripts/check-module-invariants.sh`
  carries **two** coupled heredocs, `C14_BASELINE` (line 1772) and `C14LEAN` (line 1969), which
  the script's own comment at line 1737 says "must list the same declarations in the same order.
  Edit them together." The dispatch and the Phase 6 task list name only `C14_BASELINE`. Editing
  one alone fails C14 with a baseline divergence.
- **Measured, not computed**: `scripts/debug-artifact-allowlist.txt`'s current entry (54) is
  confirmed correct against `scripts/lib/lean_debug_artifacts.py`. Six pinned names add 6
  `#check` + 6 `#print axioms` = **12** live directive lines; the gate's own measurement remains
  the authority and must be read from a gate run, per the dispatch.
- **No sorry-free path is in doubt.** Every deliverable is a term-mode or short tactic proof over
  existing lemmas. No `sorry`, no axiom declaration, no plan decomposition needed.

## Context & Scope

Task 670 landed `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` (292 lines, nine named
theorems, sorry-free, axiom-declaration-free), proving `Axiom.prior_UZ` and `Axiom.z1` invalid at
`FrameClass.Base`, hence at every class strictly below `.ZTime` via `eq_base_of_lt_ztime`. Its
Phases 5 and 6 were explicitly optional and were closed `[COMPLETED WITH EXCLUSIONS]`. This task
executes both.

Researched here: (a) whether the `.Dense` and `.RTime` refutations and the two biconditionals
elaborate, and at what axiom cost; (b) exactly which files and gate baselines the
`MainResults.lean` pin touches; (c) the real build-invalidation footprint of each edit.

Out of scope per the dispatch's SCOPE clause and honoured here: the `.Dense` and `.RTime` rows of
`Axiom.minFrameClass` (`density`, `dense_indicator`, `prior_U_gap`, `sep`); anything under
`docs/`; the ModelChecker repository. `README.md` at the repository root is likewise outside
`FormalSystem/ plus the two named scripts/ files`; two stale prose counts found there are recorded
as follow-ups, not as task work.

## Findings

### Codebase Patterns

**F1 — The `Sat` discharge shapes, confirmed by elaboration.**
`FrameClass.Sat` (`Semantics/FrameClassValidity.lean:150-155`) is `@[reducible]` and per-tag:

| Tag | `Sat fc F` | Discharge at `(translationFrame D).toTaskFrame` |
|-----|-----------|--------------------------------------------------|
| `.Base` | `F.IsRegular` | `inferInstance` (via `translationFrame_isRegular`) |
| `.Dense` | `F.IsRegular ∧ F.IsDense` | `⟨inferInstance, inferInstance⟩` at `D = ℚ` |
| `.RTime` | `F.IsRegular ∧ (F.IsDense ∧ F.IsComplete)` | `⟨inferInstance, inferInstance, fun _ hne hbd => Real.exists_isLUB hne hbd⟩` at `D = ℝ` |

The three-component anonymous constructor for `.RTime` is the idiom
`DedekindNonCompactness.lean:437` already uses; it works unchanged on the translation frame.

**F2 — The two generic lemmas carry all four instantiations.** `not_validOn_prior_UZ_dense` and
`not_validOn_z1_dense` are stated at an arbitrary `(D : TemporalOrder) [DenselyOrdered (D : Type)]`.
Both `ℚ` and `ℝ` satisfy that binder, so `.Base`, `.Dense` and `.RTime` are all one-liners off the
same two lemmas. No new countermodel construction is required anywhere in this task.

**F3 — `ℝ` is not in the current import closure.** Compiling the corollaries against only
`import FormalSystem.Metalogic.Independence.ZTimeSharpness` fails with `Unknown identifier ℝ`,
`Unknown identifier Real.exists_isLUB`, and two `synthInstance` failures for
`DenselyOrdered …carrier` / `…IsDense`. Exactly one import must be added.

**F4 — `realOrder` is ambiguous, so the dispatch's named route does not compile.**
Adding `import FormalSystem.Metalogic.DedekindNonCompactness` and writing `realOrder` yields:

```
error: Ambiguous term
  realOrder
Possible interpretations:
  Metalogic.realOrder : TemporalOrder
  Semantics.realOrder : TemporalOrder
```

`Semantics.realOrder` is declared at `FormalSystem/Semantics/Correspondence/RigidityReal.lean:81`
as `noncomputable abbrev realOrder : TemporalOrder := TemporalOrder.of ℝ` — the identical
definition `Metalogic.realOrder` (`DedekindNonCompactness.lean:322`) gives. Two verified
alternatives (both elaborate clean, both measure `[propext, Classical.choice, Quot.sound]`):

- **Option B (recommended)**: `import FormalSystem.Semantics.Correspondence.RigidityReal` and use
  the bare `realOrder`, which resolves uniquely to `Semantics.realOrder` under the module's
  existing `open FormalSystem.Semantics`. Reuses an in-tree definition; adds no third `ℝ`-order
  declaration and no Mathlib import. **Caveat to record in a comment**: this resolution is
  unique only while `DedekindNonCompactness` stays out of the closure; a future import of it
  reintroduces the ambiguity.
- **Option A (fallback)**: `import Mathlib.Algebra.Order.Archimedean.Real.Basic` and declare a
  local `noncomputable abbrev ztimeSharpRealOrder : TemporalOrder := TemporalOrder.of ℝ`,
  mirroring the existing `ztimeSharpOrder`. Fully self-contained, but adds a third declaration of
  the same object. Note `Mathlib.Data.Real.Basic` is **insufficient** (it lacks
  `Real.exists_isLUB`) and `Mathlib.Data.Real.Archimedean` is **deprecated** — the compiler names
  `Mathlib.Algebra.Order.Archimedean.Real.Basic` as its replacement.

**F5 — Build-invalidation footprint, measured from the import graph.**

| Edited file | Modules invalidated | Evidence |
|---|---|---|
| `FormalSystem/MainResults.lean` | 2 (itself + `FormalSystem.lean`) | nothing imports it; `grep -rln` over `FormalSystem Tests BimodalTools` |
| `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` | 12 | `Independence.lean` → `Metalogic.lean` → {`MainResults.lean`, `Examples/Walkthrough.lean`, 6 `Tests/BimodalTest/Integration/*.lean`}, plus root `FormalSystem.lean` |
| `FormalSystem/ProofSystem/Axioms.lean` | full tree | sits at the bottom of the stack |

The dispatch's claim that editing `MainResults.lean` "forces a full-tree rebuild" is incorrect;
the expensive edit is the `ZTimeSharpness.lean` one, and it is not a full tree either. `scripts/`
edits invalidate nothing. Sequence: make **both** Lean edits, then take **one** scoped rebuild.

**F6 — The gate script has two coupled heredocs, not one.**
`scripts/check-module-invariants.sh:1737`: *"The C14BASE and C14LEAN heredocs below are compared
by exact string equality, so they must list the same declarations in the same order. Edit them
together, appending to both."* `C14_BASELINE` opens at line 1772 (`<<'C14BASE'`) and
`C14_SRC`'s generated Lean file opens at line 1969 (`<<'C14LEAN'`, first line
`import FormalSystem`). Each currently carries **192** entries. C21
(`scripts/check-module-invariants.sh:3798-3812`) then asserts every
`^#print axioms <name>` in `MainResults.lean` is in `AXIOM_BASELINE ∪ C14_BASELINE`.

**F7 — The allow-list count, and how the gate computes it.** C27 counts *live* (comment-masked)
directive lines via `scripts/lib/lean_debug_artifacts.py`'s `count_lines`. Running that helper
against the current `MainResults.lean` returns **54**, matching the allow-list entry exactly, and
the file carries 27 `^#check` + 27 `^#print axioms`. Six pinned names therefore add 12. The
dispatch's instruction stands: set the value the **gate reports**, not an arithmetic guess.

**F8 — Axiom sets of the four already-existing headline names, measured.** All four report
`[propext, Classical.choice, Quot.sound]`:
`prior_UZ_minFrameClass_sharp`, `z1_minFrameClass_sharp`, `not_derivable_base_prior_UZ`,
`not_derivable_base_z1`. Note `#print axioms` **wraps long output across lines**; C14 rejoins
continuation lines with `sed -e ':a' -e '$!N' -e 's/\n / /' -e 'ta'` before comparing, so every
baseline line is written single-line.

**F9 — Prose ledgers that must move with the theorems.** Four in-scope sites state the weaker
claim and would become under-stated (not false) after the change:
`ZTimeSharpness.lean`'s module docstring ("Main results" list and the "Why the lower bound is
wanted" paragraph); `FormalSystem/Metalogic/Independence.lean` item 6 (line 55) and its
`## Contents` entry (line 111); `FormalSystem/Metalogic/Independence/README.md` item 9 (line 36)
and its `## Key Results` bullet (line 146); `FormalSystem/ProofSystem/Axioms.lean`'s
`Axiom.minFrameClass` docstring (lines 611-618, "Lower bound, for the ZTime row only").
The last one is the full-tree rebuild — treat it as optional.

**F10 — Inventory and citation gates.** `Independence/README.md` carries a generated inventory
block (lines 83-110) whose `ZTimeSharpness.lean` row records `292` and a pre-existing
`<!-- TODO: add description -->`. INV compares generated blocks to actual line counts, so
`bash scripts/check-module-invariants.sh --emit-inventory` must run **after** the last docstring
edit. Separately verified: **no** `ZTimeSharpness.lean:NNN` or `MainResults.lean:NNN` citation
exists anywhere outside `specs/`, so C20 is not at risk from the line-number shift.

**F11 — C17 (dead-declaration scan) is satisfied by the design, not by accident.** The four new
`not_validIn_{dense,rtime}_*` corollaries are consumed by the two biconditionals, and the two
biconditionals are named in `MainResults.lean` and in the two prose ledgers. Every new name has an
occurrence outside its declaring line. Landing the first half *without* the second would leave the
two biconditionals dead — an argument for keeping the halves in one change.

### External Resources

- `Real.exists_isLUB (hne : s.Nonempty) (hbdd : BddAbove s) : ∃ x, IsLUB s x` — Mathlib, reached
  via `Mathlib.Algebra.Order.Archimedean.Real.Basic`. Already the in-tree idiom at
  `DedekindNonCompactness.lean:437`.
- `isLUB_csSup hne hbdd : IsLUB s (sSup s)` — the conditionally-complete-lattice generic, verified
  working as `fun _ hne hbd => ⟨_, isLUB_csSup hne hbd⟩` when only `RigidityReal` is imported.
  Equivalent; `Real.exists_isLUB` is preferred for consistency with the existing call site.
- Mathlib's `push Not at h` (the generalized `push_neg`) is already in use at
  `ZTimeSharpness.lean:188`; no new tactic is introduced by this work.

### Recommendations

**R1 — A sorry-free path exists for the whole deliverable and is already machine-checked.** The
Appendix carries the verbatim text. No approach in this task risks a `sorry`, and no axiom
declaration is introduced.

**R2 — Suggested phase decomposition (four phases, one rebuild, two gate runs).**

1. *Characterization theorems.* Edit `ZTimeSharpness.lean` only: one import, four corollaries,
   two biconditionals. Verify with `lake env lean` on the file directly (fast, no rebuild) before
   touching anything else.
2. *The coupled pin.* Edit `MainResults.lean` (new section, 6 `#check` + 6 `#print axioms`),
   **both** heredocs in `check-module-invariants.sh`, and `debug-artifact-allowlist.txt`. Run the
   gate, read C27's reported count, set it, re-run.
3. *Prose.* Extend the three in-scope ledgers (F9, excluding `Axioms.lean`), then run
   `bash scripts/check-module-invariants.sh --emit-inventory` **last**.
4. *Confirm.* Detached guarded build + full gate; assert C1, C3, C14, C17, C21, C27, INV green
   and the measured axiom set unchanged.

**R3 — Prefer Option B for the `ℝ` order** (import `RigidityReal`, use `Semantics.realOrder`),
with a one-line comment recording the `Metalogic.realOrder` ambiguity that a future
`DedekindNonCompactness` import would reintroduce. Fall back to Option A if a reviewer objects to
`Semantics/` → `Metalogic/Independence/` coupling.

**R4 — Decline the `Axioms.lean` docstring upgrade** unless a full-tree rebuild is separately
budgeted. Its current text ("Lower bound, for the ZTime row only … not merely an upper bound")
remains *true* after this change, merely weaker than what is then proved.

**R5 — Build discipline.** Every `lake build` goes through
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <target>` under
`Bash(run_in_background: true)`, per `context/project/lean4/operations/long-builds.md`; wait with
the bounded `kill -0`-on-captured-PID idiom from `context/patterns/bounded-build-waiter.md`.
Never `pgrep -f`. Inner-loop verification uses `lake env lean <file>`, which needs no rebuild and
was sufficient for every result in this report.

**R6 — Revert-as-a-unit is a real risk, so stage the pin as one commit.** A partial pin fails C21.
Because the pin now spans four edit sites across three files (F6), the atomic-batch commit mode
the 670 plan declared for Phase 6 should be carried over verbatim.

## Decisions

- **D1**: State the characterizations at an **explicit** `(fc : FrameClass)` with an `↔`, rather
  than reusing the existing `{fc}`-implicit `… < .ZTime →` shape. An `iff` over an explicit binder
  is what a call site consumes; the existing `*_minFrameClass_sharp` theorems are kept unchanged,
  since `Axioms.lean` and both ledgers already cite them by name.
- **D2**: Keep the atomic-instance discipline. `Axiom.prior_UZ ⊥` has an unsatisfiable antecedent
  and *is* `.Base`-valid, so a schematic `∀ φ` biconditional would be false. Every new statement
  is at `Formula.atom p`, exactly as the landed module's are.
- **D3**: Prove the forward direction by `cases fc` over all four constructors rather than by
  routing through `eq_base_of_lt_ztime`. The order fact does not apply — `.Dense` and `.RTime` are
  *incomparable* to `.ZTime`, not below it — so the exhaustive case split is the only available
  route and is also the shorter one.
- **D4**: Name the results `not_validIn_dense_prior_UZ`, `not_validIn_dense_z1`,
  `not_validIn_rtime_prior_UZ`, `not_validIn_rtime_z1`, `prior_UZ_validIn_iff_ztime`,
  `z1_validIn_iff_ztime` — extending the module's existing `not_validIn_base_*` convention.
- **D5**: Do not add `docs/theorem-index.md` rows. No sharpness result currently has one, and
  adding rows would pull in C15's per-row paper-anchor obligation for no gate benefit. `docs/` is
  outside the dispatch's SCOPE in any case.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Editing `C14_BASELINE` alone and not `C14LEAN` (the dispatch names only the former) | **High** — the dispatch and the 670 plan both under-specify it | F6: edit both heredocs, append in the same order to each; the script's own line-1737 comment is the authority |
| `Ambiguous term realOrder` from following the dispatch's `DedekindNonCompactness` route | High | R3: Option B or Option A, both verified |
| `Unknown identifier ℝ` from adding the `.RTime` corollaries with no new import | High | F3: exactly one import must be added |
| Over-budgeting a "full rebuild" that is not needed | Medium | F5: `MainResults.lean` invalidates 2 modules; `ZTimeSharpness.lean` invalidates 12 |
| INV failing because inventories were regenerated before the last docstring edit | Medium | R2 step 3: `--emit-inventory` runs **last**, and it is `check-module-invariants.sh --emit-inventory`, not `readme-inventory.sh` |
| Partial pin left in the tree after a failure | Medium | R6: atomic-batch commit; revert all four edit sites together |
| Landing only the first half, leaving the two biconditionals C17-dead | Low | F11: the two halves reference each other; keep them in one change |
| `by decide` attempted on `FrameClass` `<` | Low | Recorded in the dispatch and confirmed here: only `≤` has a `DecidableRel` instance. D3's route needs neither |

## Tactic Survey Results

Surveyed by direct elaboration (`lake env lean`) on the full simulated module rather than by
`lean_multi_attempt`, since every goal here is a term-mode application and the whole-module
simulation is the stronger evidence.

| Goal | Tactic / term | Result | Premises/Config |
|------|---------------|--------|-----------------|
| `Sat .Dense (translationFrame ℚ).toTaskFrame` | `⟨inferInstance, inferInstance⟩` | **success** | reducible chain `Sat` → `IsDense` → `DenselyOrdered ℚ` |
| `Sat .RTime (translationFrame ℝ).toTaskFrame` | `⟨inferInstance, inferInstance, fun _ hne hbd => Real.exists_isLUB hne hbd⟩` | **success** | `Mathlib.Algebra.Order.Archimedean.Real.Basic` |
| same | `⟨inferInstance, inferInstance, fun _ hne hbd => ⟨_, isLUB_csSup hne hbd⟩⟩` | **success** | works with only `RigidityReal` imported |
| same, with `Mathlib.Data.Real.Basic` only | `Real.exists_isLUB` | **fail** — `Unknown constant` | insufficient import |
| same, with `Mathlib.Data.Real.Archimedean` | `Real.exists_isLUB` | success **with deprecation warning** | use the named replacement instead |
| `ValidIn fc φ ↔ fc = .ZTime`, forward | `cases fc` + four `absurd`/`rfl` arms | **success** | the four non-validity results |
| `ValidIn fc φ ↔ fc = .ZTime`, reverse | `rintro rfl; exact prior_UZ_valid (Formula.atom p)` | **success** | `ValidZTime` is `ValidIn .ZTime` by definition, so `exact` closes it with no `unfold` |
| same, reverse, for `z1` | `rintro rfl; exact z1_valid (Formula.atom p)` | **success** | `SoundnessLemmas`, re-exported into `FormalSystem.Metalogic` |
| `fc < .ZTime` goals | `decide` | **fail** (recorded, not retried) | only `≤` has `DecidableRel`; D3 avoids needing it |

Full simulated module: **0 errors, 0 warnings**; all six new declarations
`[propext, Classical.choice, Quot.sound]`.

## Context Extension Recommendations

- **Topic**: Duplicate-basename ambiguity across sibling namespaces in this tree.
  **Gap**: `realOrder` exists twice (`Semantics.realOrder`, `Metalogic.realOrder`) with identical
  definitions, and nothing warns until an unlucky import pair makes a bare reference ambiguous.
  The 670 report already recorded the analogous `qD` collision that forced the `ztimeSharpOrder`
  name. **Recommendation**: a short note under `context/project/lean4/patterns/` recording the
  collision class, the `Ambiguous term` error shape, and the "check for an existing in-tree
  definition before importing a heavy module for one abbrev" rule.
- **Topic**: Reading build-invalidation footprint before budgeting a rebuild.
  **Gap**: The dispatch inherited an incorrect claim that editing `MainResults.lean` forces a
  full-tree rebuild. **Recommendation**: record the two-line reverse-dependency recipe
  (`grep -rln '^import <Module>$' FormalSystem Tests BimodalTools`, iterated up the aggregator
  chain) as the way to size a rebuild before paying for it.
- **Topic**: The `check-module-invariants.sh` paired-heredoc contract.
  **Gap**: Two prior artifacts (the 670 plan's Phase 6 task list and this task's dispatch) both
  name only `C14_BASELINE`. **Recommendation**: a line in the Lean-extension gate notes stating
  that a C14 pin is always a **two**-heredoc edit.

## Appendix

### A1 — Verified text for `ZTimeSharpness.lean` (Option B)

Add one import beside the existing two:

```lean
import FormalSystem.Semantics.Correspondence.RigidityReal
```

Then, before `end FormalSystem.Metalogic.Independence` (docstrings elided here; the
implementation must supply them — C16's `docBlame` and C19 both read them):

```lean
theorem not_validIn_dense_prior_UZ (p : Atom) :
    ¬ ValidIn FrameClass.Dense
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  fun h => not_validOn_prior_UZ_dense ztimeSharpOrder p (h _ ⟨inferInstance, inferInstance⟩)

theorem not_validIn_dense_z1 (p : Atom) :
    ¬ ValidIn FrameClass.Dense
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  fun h => not_validOn_z1_dense ztimeSharpOrder p (h _ ⟨inferInstance, inferInstance⟩)

theorem not_validIn_rtime_prior_UZ (p : Atom) :
    ¬ ValidIn FrameClass.RTime
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  fun h => not_validOn_prior_UZ_dense realOrder p
    (h _ ⟨inferInstance, inferInstance, fun _ hne hbd => Real.exists_isLUB hne hbd⟩)

theorem not_validIn_rtime_z1 (p : Atom) :
    ¬ ValidIn FrameClass.RTime
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  fun h => not_validOn_z1_dense realOrder p
    (h _ ⟨inferInstance, inferInstance, fun _ hne hbd => Real.exists_isLUB hne hbd⟩)

theorem prior_UZ_validIn_iff_ztime (p : Atom) (fc : FrameClass) :
    ValidIn fc ((Formula.atom p).someFuture.imp
      (Formula.untl (Formula.atom p).neg (Formula.atom p)))
      ↔ fc = FrameClass.ZTime := by
  refine ⟨fun h => ?_, ?_⟩
  · cases fc with
    | Base => exact absurd h (not_validIn_base_prior_UZ p)
    | Dense => exact absurd h (not_validIn_dense_prior_UZ p)
    | ZTime => rfl
    | RTime => exact absurd h (not_validIn_rtime_prior_UZ p)
  · rintro rfl
    exact prior_UZ_valid (Formula.atom p)

theorem z1_validIn_iff_ztime (p : Atom) (fc : FrameClass) :
    ValidIn fc (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
      ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture))
      ↔ fc = FrameClass.ZTime := by
  refine ⟨fun h => ?_, ?_⟩
  · cases fc with
    | Base => exact absurd h (not_validIn_base_z1 p)
    | Dense => exact absurd h (not_validIn_dense_z1 p)
    | ZTime => rfl
    | RTime => exact absurd h (not_validIn_rtime_z1 p)
  · rintro rfl
    exact z1_valid (Formula.atom p)
```

For **Option A**, replace the import with `import Mathlib.Algebra.Order.Archimedean.Real.Basic`,
add `noncomputable abbrev ztimeSharpRealOrder : TemporalOrder := TemporalOrder.of ℝ`, and
substitute that name for `realOrder` in the two `.RTime` proofs. Both forms were elaborated.

### A2 — The six C14 baseline lines

Append, in this order, to **both** `C14_BASELINE` (line 1772) as the `'…' depends on axioms: …`
form and `C14LEAN` (line 1969) as the `#print axioms …` form:

```
FormalSystem.Metalogic.Independence.prior_UZ_minFrameClass_sharp
FormalSystem.Metalogic.Independence.z1_minFrameClass_sharp
FormalSystem.Metalogic.Independence.not_derivable_base_prior_UZ
FormalSystem.Metalogic.Independence.not_derivable_base_z1
FormalSystem.Metalogic.Independence.prior_UZ_validIn_iff_ztime
FormalSystem.Metalogic.Independence.z1_validIn_iff_ztime
```

Every one measures `[propext, Classical.choice, Quot.sound]` (F8 for the first four; the
simulation for the last two), so each baseline line reads:

```
'<name>' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### A3 — Commands used

```bash
# reverse-dependency sizing
grep -rln '^import FormalSystem.Metalogic$' FormalSystem Tests BimodalTools
grep -rln '^import FormalSystem.Metalogic.Independence$' FormalSystem Tests BimodalTools
grep -rln 'Independence.ZTimeSharpness' FormalSystem Tests BimodalTools

# the gate's own C27 measurement, run directly
python3 -c "import sys; sys.path.insert(0,'scripts/lib'); \
  from lean_debug_artifacts import count_lines; \
  print(count_lines(open('FormalSystem/MainResults.lean').read())[0])"   # -> 54

# baseline entry counts (both heredocs)
awk 'NR>1772 && /^C14BASE$/{exit} NR>1772' scripts/check-module-invariants.sh \
  | grep -c 'depends on axioms'                                          # -> 192
awk 'NR>1969 && /^C14LEAN$/{exit} NR>1969' scripts/check-module-invariants.sh \
  | grep -c '^#print axioms'                                             # -> 192

# elaboration of the simulated edited module (no rebuild required)
lake env lean <simulated ZTimeSharpness.lean>
```

### A4 — Out-of-scope staleness observed (follow-ups, not task work)

- `README.md:11` and `README.md:463` both state the harness "checks the axiom sets of **105**
  declarations". The measured figure today is **196** (4 pinned by C2 + 192 by C14), becoming 202
  after this task. `FormalSystem/MainResults.lean:49` repeats the same "105 in all" and *is* in
  scope, so it can be corrected here.
- `docs/development/CI_CD_PROCESS.md:95` states `MainResults.lean` "emits 54 deliberate `info:`
  messages (25 `#check` plus 29 `#print axioms`)". The total 54 is right but the breakdown is
  already wrong — the file has 27 of each — and the total becomes 66 after this task. `docs/` is
  outside the dispatch's SCOPE clause.
- `Independence/README.md`'s generated inventory row for `ZTimeSharpness.lean` carries a
  pre-existing `<!-- TODO: add description -->`, which the docstring pass could fill while it is
  already editing that file.
