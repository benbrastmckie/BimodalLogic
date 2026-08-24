# Implementation Plan: Task #421

- **Task**: 421 - Correct transfer route guidance and probe non-Archimedean discrete carrier
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: `specs/421_correct_transfer_route_guidance_and_probe_non_archimedean_discrete_carrier/reports/01_transfer-route-and-discrete-carrier.md`
- **Artifacts**: plans/01_transfer-route-and-carrier-probe.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Two small, independent deliverables on the Base weak terminus. (a) Replace the three-line
refuted-route comment inside `WeakCanonical.countermodel_discrete` with the `ℤ ×ₗ ℤ` refutation of
route (i) and a pointer to route (ii). (b) Land a new `DiscreteCarrierProbe.lean` whose anonymous
`example`s confirm at compile time that the four `FrameClass.Base` carrier binders and the
parametric bundle-flow machinery all elaborate at `ℚ ×ₗ ℤ`. Neither deliverable adds or removes a
proof obligation; the live non-Boneyard sorry count stays at 1 by construction.

Research verified the probe text by building it as a real project module (`✔ [1359/1359]`, zero
new warnings) and then removing it, so the implementation lands already-compiled text rather than
discovering elaboration failures. The one finding that changes the shape of the work: the probe
needs an explicit `import Mathlib.Algebra.Order.Monoid.Prod`, because that module is in no
`FormalSystem` module's import closure today and `IsOrderedAddMonoid (ℚ ×ₗ ℤ)` fails to synthesize
without it. The second finding is that a new unaggregated `.lean` file trips invariant C6, so the
aggregator wiring is a required step, not a nicety.

### Research Integration

Key findings carried into phases:

- **Exact anchor text** for deliverable (a): `Transfer.lean:1081-1083`, opening
  `-- Two candidate routes: (i) a Base-MCS`. The four `-- SORRY: open obligation …` lines above
  (`:1077-1080`) and the `sorry` below (`:1084`) are out of bounds.
- **Verified replacement prose** (report §2.3) and **verified probe file text** (report §5.1) are
  reproduced literally by the phases below; they are not to be re-derived.
- **`Prod.Lex.isOrderedAddMonoid`** is the correct full name (namespace `Prod.Lex`, not `Lex` as
  the design doc said), and `AddLeftStrictMono ℚ` — the flagged risk — genuinely fires via
  `IsLeftCancelAdd.addLeftStrictMono_of_addLeftMono ℚ`. The instance is confirmed, not assumed.
- **Import minimality** was drop-one tested: `FormalSystem.Metalogic.Algebraic.FlowFrame` and
  `Mathlib.Algebra.Order.Monoid.Prod` are both required; `Mathlib.Algebra.Order.Group.Int` and
  `Mathlib.Algebra.Order.Ring.Rat` are already in closure and must NOT be added.
- **C6 wiring requirement** (report §5.2): `FormalSystem/Metalogic/BXCanonical.lean` must import
  the new module.
- **Acceptance-criterion note** (report §1): `#print axioms` on a new declaration is *vacuously*
  satisfied, because the mirrored CarrierProbe pattern uses `example` exclusively and creates no
  named constants. Phase 5 records this as vacuous rather than inventing a named theorem.
- **Phrasing constraint** (report §2.3): the replacement must not re-emit the original sentence
  shape, or the acceptance grep may still match.
- **Out of scope** (report §2.5): the repo-wide `U(⊤,⊥)` vs guard-first `untl` prose drift (125
  occurrences). The replacement text names the Lean identifier `nextTop` to sidestep it. Do not
  introduce `U(⊥,⊤)` into this file.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no roadmap consultation performed.

## Goals & Non-Goals

**Goals**:
- The `"Two candidate routes: (i) a Base-MCS … (ii) a Henkin-style …"` block no longer appears in
  `Transfer.lean`, replaced by the refutation of route (i) and a pointer to route (ii).
- `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean` exists, elaborates, and is
  reachable from the module graph.
- `lake build` is green; `scripts/check-module-invariants.sh` reports ALL CHECKS PASSED with C3's
  sole structural sorry still `countermodel_discrete` in `Transfer.lean`.

**Non-Goals**:
- Touching, discharging, or relocating the `sorry` in `WeakCanonical.countermodel_discrete`
  (`Transfer.lean:1084`). Explicitly forbidden by the task description.
- Attempting route (i) — the Base-MCS → Discrete-MCS transfer lemma. It is REFUTED.
- Actually constructing the route-(ii) discrete canonical model over `ℚ ×ₗ ℤ`. This task confirms
  the carrier is admissible; it does not build on it.
- Repairing the repo-wide `U(⊤,⊥)` prose/code notation drift (report §2.5). Separate task.
- Adding named theorems to the probe purely to give `#print axioms` something to chew on.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| New Mathlib instances (`Prod.Lex.*` ordered-monoid family) enter the main build closure via the aggregator and cause a diamond or elaboration slowdown | M | L | Phase 5 runs the FULL `lake build` and full invariant script, not a single-module build; research's single-module build does not cover this |
| Acceptance grep still matches because the replacement re-emits the original sentence shape | M | L | Phase 1 verification greps the exact opener `Two candidate routes: (i) a Base-MCS` and requires zero hits; the supplied replacement text deliberately avoids that phrasing |
| Missing `Mathlib.Algebra.Order.Monoid.Prod` import → `failed to synthesize IsOrderedAddMonoid (Lex (ℚ × ℤ))` | M | L | The import is written into the Phase 3 file text and drop-one tested by research |
| New module unaggregated → invariant C6/C7 counts shift and the gate fails for a non-mathematical reason | M | M | Phase 4 is a dedicated wiring phase with its own verification |
| Line numbers drifted since research | L | L | Every phase anchors on quoted text, never on a bare line number |
| An edit strays outside the comment region into the `sorry` or the `-- SORRY:` block | H | L | Phase 1 verification includes a `sorry`-count-unchanged check and a diff read-through confirming every hunk is inside a comment |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2, 4 | 1 (for 2), 3 (for 4) |
| 3 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel. Phases 1/2 (Transfer.lean) and Phases 3/4
(new module + aggregator) touch disjoint files, so the two chains are independent up to Phase 5.

---

### Phase 1: Replace the refuted-route comment in Transfer.lean [NOT STARTED]

**Goal**: The three-line route-guidance comment is replaced by the `ℤ ×ₗ ℤ` refutation of route (i)
plus a pointer to route (ii), with nothing else in the file changed.

**Tasks**:
- [ ] Locate the block by its opening text `-- Two candidate routes: (i) a Base-MCS` (research
      found it at `:1081-1083`; treat the number as a hint, the text as the anchor).
- [ ] Replace exactly those three lines with the verified text below. Do NOT touch the four
      `-- SORRY: open obligation …` lines immediately above, and do NOT touch the `sorry`
      immediately below.

```lean
  -- Route (i) is REFUTED and MUST NOT be re-attempted. It proposed a Base-MCS → Discrete-MCS
  -- transfer lemma so that countermodel_discrete_reynolds_v2 could be applied. The witness that
  -- kills it: D := ℤ ×ₗ ℤ (lexicographic, first coordinate dominant — an admissible Base carrier,
  -- since AddCommGroup/LinearOrder/IsOrderedAddMonoid/Nontrivial all resolve there), with `p`
  -- true exactly at the points ≥ (1,0). Every point (a,b) has the immediate successor (a,b+1), so
  -- `nextTop` holds everywhere and `□ nextTop` holds. `Gp` holds exactly at points ≥ (1,0), so
  -- `Gp → p` holds everywhere and `G(Gp → p)` holds at (0,0). `FGp` holds at (0,0), witness
  -- (1,0). But `Gp` FAILS at (0,0), witness (0,1) — which is > (0,0) yet ≱ (1,0). Antecedent
  -- true, consequent false: `Axiom.z1 p` is false at (0,0). Since `Axiom.z1` is Discrete-only
  -- (`Axiom.minFrameClass`, ProofSystem/Axioms.lean), {□ nextTop, G(Gp→p), FGp, ¬Gp} is
  -- Base-consistent and extends by Lindenbaum (`set_lindenbaum`) to a Base-MCS that contains
  -- `□ nextTop` and is Discrete-INCONSISTENT. No such transfer lemma can exist.
  --
  -- The surviving route is (ii): construct the discrete canonical model directly over a
  -- non-Archimedean carrier. `FrameClass.Base` imposes no Archimedean-ness — `valid`
  -- (Semantics/Validity.lean) binds only AddCommGroup/LinearOrder/IsOrderedAddMonoid/Nontrivial,
  -- with no `IsSuccArchimedean` — so ℚ ×ₗ ℤ is admissible: it is discretely ordered with
  -- successor (q,n) ↦ (q,n+1), hence validates `nextTop` everywhere. See
  -- `Metalogic/BXCanonical/DiscreteCarrierProbe.lean` for the compile-time confirmation that the
  -- parametric bundle-flow machinery elaborates at that carrier.
```

- [ ] Confirm the indentation matches the surrounding tactic-block comments (two spaces).

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: The block is exactly three `--` lines at `Transfer.lean:1081-1083` and the
file contains exactly one `sorry`. Confirm at implementation time by
`grep -n "Two candidate routes: (i) a Base-MCS" FormalSystem/Metalogic/WeakCanonical/Transfer.lean`
(expect exactly one hit before the edit) and by recording `grep -c "sorry" …` before and after.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` — replace the three route-guidance comment
  lines; no other change.

**Verification**:
- `grep -n "Two candidate routes: (i) a Base-MCS" FormalSystem/Metalogic/WeakCanonical/Transfer.lean`
  → zero hits.
- `grep -c "sorry" FormalSystem/Metalogic/WeakCanonical/Transfer.lean` → unchanged from the
  pre-edit value.
- Diff read-through: every changed hunk lies inside a `--` comment region.
- `grep -n "U(⊥,⊤)" FormalSystem/Metalogic/WeakCanonical/Transfer.lean` → zero hits (the
  replacement must name `nextTop`, not introduce a second prose convention).

---

### Phase 2: Strengthen the section docstring's now-understated claim [NOT STARTED]

**Goal**: The enclosing section docstring no longer says a Base-MCS is merely "not automatically"
Discrete-consistent, when the refutation now recorded in Phase 1 establishes it provably need not
be.

**Discretionary**: This phase is IN SCOPE (the task authorizes docstring/comment-only edits to this
file) but is NOT part of the acceptance criteria. It is broken out as its own phase precisely so
that doing it or skipping it is a recorded decision rather than drift. **Recommendation: do it** —
it is one sentence, it is in the same file, and leaving the weaker claim standing next to the
stronger comment is a live inconsistency for the next reader.

**Tasks**:
- [ ] Locate the sentence in the section docstring (research: `Transfer.lean:1064-1066`, inside the
      docstring at `:1049-1067`) reading "…and a Base-MCS is not automatically Discrete-consistent."
      Anchor on the text `not automatically Discrete-consistent`.
- [ ] Replace "is not automatically Discrete-consistent" with a claim matching the refutation, e.g.
      "provably need not be Discrete-consistent — see the refutation of route (i) in the body of
      `countermodel_discrete` below".
- [ ] Make no other change to the docstring.

**Timing**: 0.25 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` — one sentence in the section docstring.

**Verification**:
- `grep -n "not automatically Discrete-consistent" FormalSystem/Metalogic/WeakCanonical/Transfer.lean`
  → zero hits (if the phase was executed).
- `grep -c "sorry" FormalSystem/Metalogic/WeakCanonical/Transfer.lean` → still unchanged.
- Diff read-through: the change is confined to the `/-! … -/` docstring block.
- If the phase is skipped, record the skip explicitly in the phase status rather than leaving it
  ambiguous.

---

### Phase 3: Create DiscreteCarrierProbe.lean [NOT STARTED]

**Goal**: A new module exists whose anonymous `example`s confirm, at elaboration time, that the
four `FrameClass.Base` binders and the bundle-flow API all resolve at `ℚ ×ₗ ℤ`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean`.
- [ ] Prepend the standard copyright header used by sibling modules (copy the exact block from
      `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean`).
- [ ] Add a module docstring in the voice of the `ℝ` `CarrierProbe` docstring
      (`CompletenessDedekind.lean:69-105`), stating that these `example`s exist to fail loudly if
      the bundle-flow machinery ever acquires a binder `ℚ ×ₗ ℤ` cannot discharge, and that this
      carrier is the route-(ii) recommendation the refuted-route comment in `Transfer.lean` points
      at.
- [ ] Write the verified body below (report §5.1) — this text compiled during research; land it
      as-is rather than re-deriving it.

```lean
import FormalSystem.Metalogic.Algebraic.FlowFrame
import Mathlib.Algebra.Order.Monoid.Prod

namespace FormalSystem.Metalogic.BXCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

section DiscreteCarrierProbe

variable {fc : FrameClass}

example : AddCommGroup (ℚ ×ₗ ℤ) := inferInstance
example : LinearOrder (ℚ ×ₗ ℤ) := inferInstance
example : IsOrderedAddMonoid (ℚ ×ₗ ℤ) := inferInstance
example : Nontrivial (ℚ ×ₗ ℤ) := inferInstance

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) : TaskFrame (ℚ ×ₗ ℤ) := bundleFlowFrame B

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) : TaskModel (bundleFlowFrame B) :=
  bundleFlowModel B

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) :
    Set (WorldHistory (bundleFlowFrame B)) :=
  {σ | ∀ t, σ.domain t}

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) (root : Formula)
    (h_rtc : B.RestrictedTemporallyCoherent root)
    (h_buc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_fuc : B.RestrictedForwardUntilSinceCoherent root)
    (φ : Formula) (h_sub : φ ∈ subformulaClosure root)
    (fam : FMCS (fc := fc) (ℚ ×ₗ ℤ)) (hfam : fam ∈ B.families)
    (w₀ t : ℚ ×ₗ ℤ) (h_neg_in : φ.neg ∈ fam.mcs (w₀ + t)) :
    ¬TruthAt (bundleFlowModel B) (bundleFlowHistory ⟨fam, hfam⟩ w₀) t φ :=
  bundleFlow_completeness_from_neg_membership B root h_rtc h_buc h_fuc φ h_sub
    ⟨fam, hfam⟩ w₀ t h_neg_in

end DiscreteCarrierProbe

end FormalSystem.Metalogic.BXCanonical
```

- [ ] Do NOT add `Mathlib.Algebra.Order.Group.Int` or `Mathlib.Algebra.Order.Ring.Rat` — both are
      already in `FlowFrame`'s closure and were drop-one tested as unnecessary.
- [ ] Do NOT add `open scoped Prod` — the `×ₗ` notation is already in scope through `FlowFrame`.
- [ ] Use `example` only. Do not introduce named declarations.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly two imports are required (`FlowFrame` and
`Mathlib.Algebra.Order.Monoid.Prod`), and all eight `example`s elaborate with zero errors and zero
new warnings. Confirm by `lake build FormalSystem.Metalogic.BXCanonical.DiscreteCarrierProbe` and
by checking that any warnings emitted originate in `FlowFrame.lean` (pre-existing
`linter.unusedSectionVars` / `linter.overlappingInstances` at `:666,791`), not in the new file.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean` — new file.

**Verification**:
- `lake build FormalSystem.Metalogic.BXCanonical.DiscreteCarrierProbe` → succeeds.
- Zero errors and zero warnings attributable to the new file.
- `grep -c "sorry" FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean` → 0.
- If `Mathlib.Algebra.Order.Monoid.Prod` has never been built in this checkout, a one-off
  `lake build Mathlib.Algebra.Order.Monoid.Prod` may be needed before the module resolves; this is
  expected, not a defect.

---

### Phase 4: Wire the new module into the aggregator [NOT STARTED]

**Goal**: `DiscreteCarrierProbe.lean` is reachable from the module graph, so invariant C6
("all unreachable live modules are manifested") and C8 (one aggregator per subdirectory) continue
to pass.

**Tasks**:
- [ ] Add `import FormalSystem.Metalogic.BXCanonical.DiscreteCarrierProbe` to
      `FormalSystem/Metalogic/BXCanonical.lean`, alongside the existing sibling imports (place it
      adjacent to the `CompletenessDedekind` import, which it conceptually extends).
- [ ] Add a corresponding line to that file's `## Architecture` list describing the module as the
      `ℚ ×ₗ ℤ` compile-time carrier probe. (Note: the existing list does not currently enumerate
      every import — `CompletenessDedekind` itself is absent — so match the list's actual
      granularity rather than forcing a full enumeration.)

**Timing**: 0.25 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: `BXCanonical.lean` is the sole aggregator for this subdirectory and is itself
reached from `FormalSystem/Metalogic/StrongCompleteness.lean`, so this one import suffices to make
the probe reachable. Confirm by `lake build FormalSystem.Metalogic.BXCanonical` and
`lake build FormalSystem.Metalogic.StrongCompleteness` succeeding, and by C6/C7 reporting the
expected counts in Phase 5.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical.lean` — one import line plus one architecture-list line.

**Verification**:
- `lake build FormalSystem.Metalogic.BXCanonical` → succeeds.
- `lake build FormalSystem.Metalogic.StrongCompleteness` → succeeds (this is the one-hop dependent
  that pulls the new Mathlib closure into the main build).
- `grep -n "DiscreteCarrierProbe" FormalSystem/Metalogic/BXCanonical.lean` → exactly one import
  hit plus the architecture-list mention.

---

### Phase 5: Full acceptance gate [NOT STARTED]

**Goal**: Every acceptance criterion in the task description is checked and recorded, including
the whole-tree build that the single-module builds of Phases 3-4 do not cover.

**Tasks**:
- [ ] Run the full `lake build` (not a single-module build) and confirm it is green.
- [ ] Run `bash scripts/check-module-invariants.sh` and confirm ALL CHECKS PASSED, with C3
      reporting the sole structural sorry as `countermodel_discrete` in
      `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`.
- [ ] Compare C7 counts against the research baseline and confirm the expected deltas (see Scope
      Hypothesis below).
- [ ] Confirm C2 axiom sets are unchanged from the research baseline:
      `completeness = [propext, sorryAx, Classical.choice, Quot.sound]`;
      `completeness_dense` / `completeness_discrete` / `countermodel_dense` each
      `[propext, Classical.choice, Quot.sound]`.
- [ ] Re-run the Phase 1 and Phase 2 greps as a final check.
- [ ] Record the `#print axioms` acceptance criterion as **vacuously satisfied**: the probe uses
      `example` exclusively and therefore creates no named constants to inspect. Do NOT add a
      named theorem to make the criterion non-vacuous — that would diverge from the mirrored
      CarrierProbe pattern the task asked for.
- [ ] Watch the build for any new elaboration slowdown or instance diamond attributable to the
      `Prod` / `Prod.Lex` ordered-monoid instances now entering the main closure. If one appears,
      report it rather than silently working around it.

**Timing**: 0.75 hours

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Research's pre-edit baseline was C7 = 448 live `.lean` files (394
`FormalSystem/` + 53 `Tests/`), 411 reachable, 37 unreachable. Landing the probe with the Phase 4
aggregator import should move these to 449 live / 395 `FormalSystem/` / 412 reachable, with
unreachable unchanged at 37. Confirm by reading the C6/C7 lines of the invariant script output; if
the numbers differ, determine whether the baseline drifted (other work landed since research) or
the wiring is wrong, before treating it as a pass.

**Files to modify**:
- None (verification only).

**Verification**:
- `lake build` → green.
- `bash scripts/check-module-invariants.sh` → ALL CHECKS PASSED; C3 sole sorry unchanged.
- `grep -n "Two candidate routes: (i) a Base-MCS" FormalSystem/Metalogic/WeakCanonical/Transfer.lean`
  → zero hits.
- Live non-Boneyard sorry count = 1.

---

## Testing & Validation

- [ ] `lake build FormalSystem.Metalogic.BXCanonical.DiscreteCarrierProbe` succeeds with no
      file-attributable errors or warnings.
- [ ] Full `lake build` is green.
- [ ] `scripts/check-module-invariants.sh` reports ALL CHECKS PASSED.
- [ ] C3's sole structural sorry remains `countermodel_discrete` in `Transfer.lean`; the live
      non-Boneyard sorry count is 1.
- [ ] C2 axiom sets match the research baseline exactly (no new `sorryAx` anywhere).
- [ ] The `"Two candidate routes: (i) a Base-MCS"` block is absent from `Transfer.lean`.
- [ ] The `sorry` at `Transfer.lean` is byte-identical to its pre-task state.
- [ ] `#print axioms` criterion recorded as vacuously satisfied, with the reason stated.

## Artifacts & Outputs

- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` — refuted-route comment replaced
  (Phase 1); section docstring sentence strengthened (Phase 2, discretionary).
- `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean` — new module (Phase 3).
- `FormalSystem/Metalogic/BXCanonical.lean` — one import plus one architecture-list line
  (Phase 4).
- Recorded gate output from Phase 5 (build result, invariant-script result, C7 deltas).

## Rollback/Contingency

Each phase is independently revertible and committed separately.

- **Phase 1/2 regression**: `git checkout HEAD -- FormalSystem/Metalogic/WeakCanonical/Transfer.lean`.
  Comment-only, so no build impact either way.
- **Phase 3 fails to elaborate**: the file text is research-verified, so a failure most likely
  means a missing `lake build Mathlib.Algebra.Order.Monoid.Prod` or an upstream change since
  research. Build that Mathlib module first; if it still fails, capture the exact synthesis error
  and report rather than weakening the probe.
- **Phase 4/5 reveals a diamond or slowdown from the new Mathlib closure**: revert the aggregator
  import (`git checkout HEAD -- FormalSystem/Metalogic/BXCanonical.lean`) and delete the probe
  file. This restores the pre-task closure exactly while leaving deliverable (a) landed, since
  Phase 1 touches a disjoint file. Report the diamond as a blocker for deliverable (b) rather
  than forcing it through.
- **Full revert**: the three touched files are disjoint from all other work in flight; reverting
  all three returns the tree to its pre-task state with no residue.
