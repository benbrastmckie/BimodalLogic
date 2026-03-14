# Research Report: Branch Comparison — claude/duration-group-construction-SFEJg vs main

**Task**: 966
**Date**: 2026-03-14
**Session**: sess_1773525761_remove

---

## Executive Summary

The branch `claude/duration-group-construction-SFEJg` proposes replacing the universal `compositionality` axiom in `TaskFrame` with a decomposition into `forward_comp` (non-negative durations) + `converse` (biconditional time-reversal). Three supporting research reports confirm the mathematical necessity of this change. The branch also adds a paper footnote task (currently task 963 on branch / renum needed) and new research artifacts on shift-closure, sign elimination, and tense algebra.

**Branch divergence**: The branch forked from main before tasks 962 (dense timeline strict intermediate) and 963 (branch comparison) were completed. As a result, the branch's task 962 and 963 have entirely different content from main's. All branch artifacts will need renumbering before merging.

**Recommendation**: The mathematical argument for `forward_comp + converse` is sound and well-evidenced. The 7-phase implementation plan is detailed and plausible. The main question is whether the cost of migration (broad structural change to `TaskFrame`, downstream proof updates) is justified now vs. after task 956 completes.

---

## Branch Contents (New vs Main)

### New Spec Artifacts

| Directory | Content |
|-----------|---------|
| `specs/0_shift_closure_research/` | Research: shift-closure role in completeness, confirms automatic for canonical model |
| `specs/research_sign_elimination/` | Research: algebraic argument for converse + restricted compositionality over sign-case tricks |
| `specs/962_algebraic_structure_sign_free_task_frame/` | Research: Tarski-Lindenbaum tense algebra, algebraic representation, confirms converse formulation |
| `specs/963_duration_group_taskframe_refactor/` | Research + Implementation plan for the TaskFrame refactor |

### New Tasks (on branch, need renumbering)

**Branch task 962** (= "Paper footnote on task relation nondeterminism + truth lemma alignment")
- Status: NOT STARTED
- Adds a paper footnote: task_rel is a relation (nondeterministic), not a function/group action
- Documents alignment gap: `semantic_consequence` requires `ShiftClosed Omega` but canonical Omega is "not necessarily ShiftClosed" — completeness requires fixing

**Branch task 963** (= "Duration group TaskFrame refactor: forward_comp + converse")
- Status: PLANNED
- 7-phase implementation: TaskFrame structure → WorldHistory guard removal → CanonicalConstruction update → DurationTransfer → IRRSoundness → Examples → backward_comp theorem

### No Lean Source Changes
The branch contains **only spec artifacts** — no `.lean` files were modified. This is pure planning/research work.

---

## The Core Architectural Difference

### Main's Approach

```lean
structure TaskFrame (D : Type*) ... where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

The canonical model uses `False` for negative durations:
```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then False           -- makes mixed-sign compositionality vacuously true
  else M = N
```

`WorldHistory.respects_task` carries an `s ≤ t` guard:
```lean
respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
  s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

### Branch's Proposed Approach

```lean
structure TaskFrame (D : Type*) ... where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  forward_comp : ∀ w u v (x y : D), 0 ≤ x → 0 ≤ y →
    task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ (w : WorldState) (d : D) (v : WorldState),
    task_rel w d v ↔ task_rel v (-d) w
```

The canonical model uses actual converse:
```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val   -- converse (not False)
  else M = N
```

`WorldHistory.respects_task` drops the `s ≤ t` guard:
```lean
respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
  F.task_rel (states s hs) (t - s) (states t ht)
```

---

## Mathematical Analysis

### Why Main's Approach Works (but is a "Trick")

Main's `False` at `d < 0` makes the universal `compositionality` axiom vacuously true for mixed-sign premises: if `task_rel w x u` holds for `x < 0`, the premise is `False`, so anything follows. This is logically correct but semantically thin — it says negative-duration tasks are simply impossible, which sidesteps the group-theoretic question entirely.

The `s ≤ t` guard in `respects_task` is then *load-bearing* precisely because the guard ensures we only ever call `task_rel` with non-negative `(t - s)`, keeping us safely in the `d > 0` or `d = 0` branches of `canonical_task_rel`.

### Why Full Mixed-Sign Compositionality is Provably Impossible for Canonical Models

From the branch research (sign_elimination report):

**Theorem**: For any non-trivial `CanonicalR`, full mixed-sign compositionality fails.

**Proof sketch**: With `x > 0, y = -x` (so `x + y = 0`), compositionality requires:
```
task_rel(M, x, U) ∧ task_rel(U, -x, V) → M = V
```
Under the converse formulation, the second premise becomes `CanonicalR(V, x, U)` (i.e., `CanonicalR V.val U.val`). So compositionality would require:
```
CanonicalR M.val U.val ∧ CanonicalR V.val U.val → M = V
```
This forces `CanonicalR` to have **functional inverse** (injectivity on targets). But `CanonicalR M N = (GContent M ⊆ N)` is wildly non-injective: many distinct MCS can forward-access the same successor. QED.

**Implication**: The only route to universal compositionality in a non-trivial canonical model is to make negative-duration premises vacuously false — exactly what main does.

### Why forward_comp + converse is the Correct Axiomatization

The branch research (sign_elimination) proves that forward_comp + converse is *equivalent* to main's approach for any frame where `task_rel` assigns `False` to `d < 0`. Moreover, for frames with genuine backward accessibility, the converse axiom expresses the correct group-theoretic content:

- **Backward compositionality** (theorem): follows from applying `converse` twice plus `forward_comp` on `(-y, -x)`.
- **Guardless respects_task**: for `s > t`, `task_rel(σ(s), t-s, σ(t))` with `t-s < 0`; by `converse` this is `task_rel(σ(t), s-t, σ(s))` with `s-t > 0`, proved by `forward_G` from FMCS coherence.
- **No more hidden `s ≤ t` guard**: the guard was a workaround for the vacuous treatment of negative durations; it disappears when the converse is explicit.

---

## Pros and Cons

### Pros of Branch Approach (forward_comp + converse)

1. **Mathematically honest**: Makes the group-theoretic structure explicit. The sign-case trick in main is a hack; `converse` is the real axiom the semantics requires.

2. **Semantically richer canonical model**: `canonical_task_rel` at `d < 0` is `CanonicalR N.val M.val` (actual backward accessibility) rather than `False` (impossible). This is the correct semantic content — a backward task *is* a forward task in reverse.

3. **Simpler `respects_task`**: Removing the `s ≤ t` guard makes the type cleaner and removes a load-bearing hack. Future proof authors don't need to understand why the guard is there.

4. **Derived theorems**: `backward_comp` and universal `compositionality` (for frames where `d < 0 → False`) become theorems, not axioms. The axiom set is more minimal.

5. **Paper alignment (deeper)**: The JPL paper discusses task frames with a group `D`; the group-theoretic converse structure is implicit in the notation. Making `converse` an explicit axiom more faithfully represents the intended semantics.

6. **Research infrastructure**: The branch provides 3 detailed research reports validating the approach, including the algebraic (Tarski-Lindenbaum tense algebra) perspective.

7. **Truth lemma alignment fix**: The branch's task 962 identifies and plans to resolve the alignment gap between `semantic_consequence` (requires `ShiftClosed Omega`) and the truth lemma (doesn't require it). This is a real correctness gap.

### Cons of Branch Approach

1. **Breaking structural change**: Every instance of `TaskFrame` must add `converse` proof. Files affected: `TemporalStructures.lean` (all example frames), `DurationTransfer.lean`, `IRRSoundness.lean`, plus any downstream code.

2. **Migration risk**: The 7-phase plan is detailed but estimated at 8-16 hours. `CanonicalConstruction.lean` is marked HIGH complexity. The IRRSoundness update may cascade.

3. **Paper alignment (surface)**: The JPL paper explicitly states `compositionality : ∀ w u v x y, ...` (universal). Changing the axiom breaks literal alignment with the paper's formal definition, even if semantically equivalent.

4. **Task 956 interaction**: Task 956 (construct D as translation group from syntax) is currently implementing. It depends on `TaskFrame`, `WorldHistory`, and `CanonicalConstruction`. The refactor would land mid-stream in a high-complexity implementing task, creating a coordination hazard.

5. **Task number conflicts**: The branch's tasks 962 and 963 conflict with main's 962 and 963 (entirely different tasks, same numbers). Merging the spec artifacts requires renumbering to 966 (paper footnote) and 967 (TaskFrame refactor), plus updating all cross-references.

6. **No Lean changes yet**: The implementation plan is untested — no attempt was made to verify the `converse` proof for existing example frames or `CanonicalConstruction`. The plan may encounter unexpected sorries.

### Pros of Main's Approach (universal compositionality)

1. **Currently working**: All existing proofs are built on this axiomatization. Zero migration cost.

2. **Simpler axiom set**: One axiom (`compositionality`) instead of two (`forward_comp` + `converse`).

3. **Surface paper alignment**: Matches the paper's stated compositionality axiom word-for-word.

4. **No coordination risk with task 956**: Task 956 can continue without disruption.

5. **The `False` approach is provably correct**: For the canonical model, `d < 0 → False` is not a semantic error — there genuinely are no backward task transitions in the current formulation.

### Cons of Main's Approach

1. **Hidden hack**: The `s ≤ t` guard in `respects_task` and `False` at `d < 0` in `canonical_task_rel` are interdependent load-bearing hacks. Removing either without the other would break things, and neither is documented as intentional.

2. **Backward accessibility is semantically missing**: The canonical model has no backward task transitions. This may be intentional (one-directional semantics) but it means the frame doesn't fully realize the group structure — the inverse elements of D are "dead".

3. **Truth lemma alignment gap**: `semantic_consequence` in `Validity.lean` requires `ShiftClosed Omega`, but the truth lemma's canonical `Omega` is not proven shift-closed. This is a real completeness gap documented by the branch, independent of the compositionality question.

4. **Obscures the mathematical structure**: Future proof authors or paper reviewers will find the `False` hack surprising. The converse relationship between forward and backward accessibility is the natural group-theoretic content.

---

## Key Open Questions

1. **Is the truth lemma alignment gap (ShiftClosed Omega) a real blocker for completeness?** The branch documents this; it is independent of the compositionality refactor. If yes, it needs fixing regardless.

2. **Does `canonical_task_rel` with `d < 0 → CanonicalR N.val M.val` actually satisfy `forward_comp` + `converse`?** The branch provides a pen-and-paper verification. The forward_comp cases need checking carefully (the existing vacuous proofs no longer work).

3. **Does task 956 require backward task accessibility?** If D emerges from translations of the MCS timeline, the canonical task_rel needs to handle `d < 0` properly. The branch approach may be a *prerequisite* for task 956 correctness.

4. **Can the branch be cherry-picked as spec-only?** Since no `.lean` files were changed, the research reports and task numbering changes can be cherry-picked or re-applied independently of any architectural decision.

---

## Recommendation

**Short term (before task 956 completes):**
- Adopt the branch's spec artifacts as research input, renumbered to avoid conflicts:
  - `0_shift_closure_research` → keep as-is (no number)
  - `research_sign_elimination` → keep as-is (no number)
  - `962_algebraic_structure_sign_free_task_frame` → rename to `968_algebraic_structure_sign_free_task_frame`
  - `963_duration_group_taskframe_refactor` → rename to `967_duration_group_taskframe_refactor`
  - Branch task 962 (paper footnote) → task 966 (paper footnote)
  - Branch task 963 (TaskFrame refactor) → task 967 (to be planned)
- Do **not** begin implementing the TaskFrame refactor until task 956 reaches a stable phase boundary.
- Fix the `ShiftClosed Omega` truth lemma alignment gap (task 966 paper footnote) as a priority.

**Medium term (after task 956 phase 7 completes):**
- Implement the TaskFrame refactor (7-phase plan) as task 967.
- The converse axiom is mathematically correct and will make the codebase cleaner.

**Do not merge the branch as-is** due to task number conflicts with main.

---

## Files Needing Review Before Implementation

| File | Concern |
|------|---------|
| `Theories/Bimodal/Semantics/TaskFrame.lean` | Replace `compositionality` with `forward_comp + converse`; update example frames |
| `Theories/Bimodal/Semantics/WorldHistory.lean` | Drop `s ≤ t` guard from `respects_task`; verify `time_shift` proof still works |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` | New `canonical_task_rel` definition; new proofs for `forward_comp` and `converse` |
| `Theories/Bimodal/Metalogic/Bundle/DurationTransfer.lean` | Add `converse` proof to `canonicalTaskFrame` |
| `Theories/Bimodal/Metalogic/Bundle/IRRSoundness.lean` | Update `prod_frame` and `lift_history` for new axiom set |
| `Theories/Bimodal/Semantics/TemporalStructures.lean` | All example frames need `converse` proof added |
| `Theories/Bimodal/Semantics/Validity.lean` | ShiftClosed alignment gap — `semantic_consequence` vs truth lemma |
