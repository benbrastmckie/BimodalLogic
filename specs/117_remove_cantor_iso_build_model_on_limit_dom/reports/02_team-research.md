# Research Report: Task #117 (Round 2)

**Task**: Remove Cantor isomorphism — generalize parametric infrastructure
**Date**: 2026-05-08
**Mode**: Team Research (4 teammates)
**Focus**: Can we replace `AddCommGroup D` with `LinearOrder D` in the parametric infrastructure?

## Summary

AddCommGroup D is **structurally load-bearing**, not just parametric. The TaskFrame axioms literally encode group operations (zero, +, −), WorldHistory.respects_task uses `t − s`, and MF/TF soundness requires time_shift + ShiftClosed. However, `truth_at` itself uses **zero group operations** — only LinearOrder D. This clean separation enables a **two-phase strategy**: (1) define a direct truth evaluation on BFMCS requiring only LinearOrder D, then (2) bridge to the existing TaskFrame semantics via a representation theorem.

## Key Findings

### 1. truth_at Uses Zero Group Operations (Teammate A — High Confidence)

The `truth_at` definition (Truth.lean:119-131) evaluates formulas using only `<` from LinearOrder:
- atom: domain membership check
- bot: False
- imp: implication
- box: ∀ σ ∈ Omega (quantifier, no arithmetic)
- all_past/all_future: `s < t` / `t < s` (order only)
- untl/snce: `t < s`, `t < r → r < s` (order only)

**All AddCommGroup usage is in the surrounding infrastructure**: TaskFrame axioms, WorldHistory.respects_task, time_shift, ShiftClosed, and the 330-line `time_shift_preserves_truth` proof.

### 2. Only MF and TF Need Group Structure for Soundness (Teammate C — High Confidence)

| Axiom Category | Count | Uses Group Ops? |
|---------------|-------|-----------------|
| Propositional (K, S, ex_falso, peirce) | 4 | No |
| Modal (T, 4, B, 5, K_dist) | 5 | No |
| Temporal (K_dist, 4, A, L) | 4 | No |
| **Modal-Future (MF)** | **1** | **Yes** — time_shift + ShiftClosed |
| **Temp-Future (TF)** | **1** | **Yes** — time_shift + ShiftClosed |
| BX temporal (A1a-A7a + mirrors) | 14 | No |
| Density/Discreteness variants | 2 | No |

MF (□φ → □Fφ) and TF (□φ → F□φ) use `time_shift σ (s − t)` and `time_shift_preserves_truth`. All other axioms use only order properties.

### 3. TaskFrame Is Unstatable Without Group Structure (Teammates C, D — Unanimous)

The three TaskFrame axioms literally require group operations:
- `nullity_identity`: `task_rel w 0 u ↔ w = u` — **zero**
- `forward_comp`: `task_rel w (x+y) v` — **addition**
- `converse`: `task_rel u (−d) w` — **negation**

WorldHistory.respects_task uses `t − s` for duration extraction. **These are not reformulable without group structure.** The task relation IS a group-theoretic concept.

### 4. The Direct Truth Evaluation Bypass (Teammate D — Key Insight)

The `time_shift`/`ShiftClosed` machinery exists to encode the multi-family BFMCS semantics into the single-history WorldHistory framework. But in BFMCS, the Box modality naturally quantifies over families at the **same time point** — no shifts needed:

```lean
def bfmcs_truth_at (B : BFMCS D) (fam : FMCS D) (t : D) : Formula → Prop
  | Formula.box φ => ∀ fam' ∈ B.families, bfmcs_truth_at B fam' t φ
  | Formula.all_future φ => ∀ s, t < s → bfmcs_truth_at B fam s φ
  | Formula.untl φ ψ => ∃ s, t < s ∧ bfmcs_truth_at B fam s φ ∧
      ∀ r, t < r → r < s → bfmcs_truth_at B fam r ψ
  -- ... (atom, bot, imp, all_past, snce analogous)
```

This needs only `[LinearOrder D]`. The truth lemma `φ ∈ fam.mcs t ↔ bfmcs_truth_at B fam t φ` would use:
- Box case: `B.modal_forward`/`B.modal_backward` (no time_shift)
- G/H: `fam.forward_G`/`fam.backward_H` + restricted temporal coherence
- U/S: `B.forward/backward_until_since_coherent`

**None require addition, subtraction, negation, or shifts.**

### 5. The Bridge Problem (Teammates B, D — Critical Constraint)

`bfmcs_truth_at` can be defined and proven with only LinearOrder D. But `¬valid φ` still requires producing a TaskFrame model with AddCommGroup D, because `valid` quantifies over `∀ D [AddCommGroup D]`.

Three bridge strategies:

**Strategy A — Trivial TaskFrame wrapper**: Prove `¬bfmcs_truth_at` on LimitDomSubtype, then construct a trivial TaskFrame on Rat by embedding LimitDomSubtype into Rat (subtype inclusion) and extending the BFMCS. Show `¬truth_at` on the Rat TaskFrame model.

**Strategy B — Representation theorem**: Prove generally that for any BFMCS D with `[LinearOrder D]` where D is countable, there exists an AddCommGroup D' and a TaskFrame D' model that agrees on truth values. This is reusable across variants.

**Strategy C — Dual validity**: Define `lo_valid` (LinearOrder-only validity) alongside `valid`. Prove soundness for `lo_valid`. Change completeness target to `lo_valid`. This requires ~800+ lines of new soundness proofs.

### 6. MF/TF Soundness Works Differently in Direct Semantics (Teammate D)

In the TaskFrame semantics, MF soundness needs time_shift. But in the BFMCS direct semantics, MF follows from **box persistence**: `Box φ ∈ fam.mcs t → Box φ ∈ fam.mcs s` (via forward_G for Box formulas). No group structure needed. The same formula is sound for different reasons in different semantic frameworks.

## Synthesis

### Conflicts Resolved

**No major conflicts.** All teammates independently confirmed:
- AddCommGroup is essential for TaskFrame (cannot be removed)
- truth_at itself doesn't need it (only LinearOrder)
- A bypass via `bfmcs_truth_at` is feasible
- But producing `¬valid φ` still requires AddCommGroup somewhere

The main divergence was on approach: Teammate B favored the two-layer architecture, Teammate D favored the pragmatic keep-D=Rat approach, both acknowledging the other's merits.

### Recommended Strategy: Phased Approach

**Phase 1 — Direct Truth Lemma (task 117, core deliverable)**:
1. Define `bfmcs_truth_at` in a new file (needs only `[LinearOrder D]`)
2. Prove the direct truth lemma: `φ ∈ fam.mcs t ↔ bfmcs_truth_at B fam t φ`
3. Remove density case from CounterexampleElimination (sorry becomes dead code)
4. Remove `cantor_iso`, `DenselyOrdered` instance from ChronicleToCountermodel
5. Rewrite `dd_countermodel_chronicle` to use the direct truth lemma
6. For the `¬valid φ` witness: embed LimitDomSubtype into Rat via subtype inclusion, build trivial TaskFrame Rat wrapper

This eliminates the sorry and establishes the direct truth evaluation as the primary path, with a thin wrapper to satisfy the existing `valid` definition.

**Phase 2 — General Representation Theorem (future task)**:
1. Prove: for any countable linear order D and BFMCS D, there exists a TaskFrame model on an AddCommGroup D' that agrees on truth values
2. This generalizes the Rat wrapper from Phase 1
3. Enables different D for different frame classes (Rat for dense, Int for discrete, LimitDomSubtype for arbitrary)

**Phase 3 — Dual Validity (optional, future)**:
1. Define `lo_valid` with only `[LinearOrder D]`
2. Prove soundness for `lo_valid` (new proofs for MF/TF using box persistence)
3. Prove `lo_valid φ ↔ valid φ` (equivalence theorem)
4. This fully decouples the logic from AddCommGroup

### Gaps Identified

1. **Direct truth lemma proof**: The Box case using `modal_forward`/`modal_backward` instead of `time_shift_preserves_truth` needs to be worked out. Conceptually straightforward but not yet proven.

2. **Rat wrapper construction**: Extending `limit_f` to all of Rat (for the trivial TaskFrame wrapper) requires defining f(q) for non-domain rationals and proving forward_G/backward_H for the extension. Leading candidate: Lindenbaum extension of g_content.

3. **CE refactoring**: The density case removal affects `PotentialCounterexampleKind` enum, `EliminationResult`, and the main elimination loop in CounterexampleElimination.lean (3783 lines).

4. **SetConsistent for adjacent pairs**: Need to verify no code path outside the density case requires `SetConsistent (limit_g x y)` for adjacent pairs where `limit_g = Set.univ`.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | AddCommGroup usage audit | completed | high |
| B | Re-rooting operation design | completed | high |
| C | Soundness impact analysis | completed | high |
| D | Parametric layer generalization | completed | high |

## References

- Truth.lean:119-131 — truth_at definition (zero group ops)
- TaskFrame.lean:93-122 — TaskFrame axioms (essential group ops)
- WorldHistory.lean:238-260 — time_shift definition
- WorldHistory.lean:96-97 — respects_task (t − s)
- Truth.lean:242-243 — ShiftClosed definition
- Truth.lean:369-698 — time_shift_preserves_truth (330 lines)
- Soundness.lean:259-273 — MF/TF soundness (only axioms needing group ops)
- ParametricCanonical.lean:84-88 — parametric_canonical_task_rel
- RestrictedParametricTruthLemma.lean:167-190 — Box case of truth lemma
- BFMCS.lean:53 — BFMCS only needs Preorder D
- FMCSDef.lean:77 — FMCS only needs Preorder D
