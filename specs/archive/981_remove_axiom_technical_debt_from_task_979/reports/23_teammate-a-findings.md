# Research Report: Task #981 (Teammate A - Primary Analysis)

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Domain**: Logic (modal and temporal logic completeness)
**Started**: 2026-03-18
**Completed**: 2026-03-18
**Role**: Primary Analysis - Exact Mathematical Gap Identification

---

## Key Findings

1. **The sorry at line 127 of `TimelineQuotCompleteness.lean` requires instantiating the parametric representation machinery with D = TimelineQuot**, not building a truth lemma from scratch.

2. **All necessary infrastructure already exists**: `ParametricTruthLemma.lean`, `ParametricRepresentation.lean`, and `timelineQuotFMCS` in `TimelineQuotCanonical.lean` provide everything needed.

3. **The missing link is a BFMCS over TimelineQuot**: The `parametric_representation_from_neg_membership` theorem just needs `(B : BFMCS (TimelineQuot M₀ h_M₀_mcs))` with `h_tc : B.temporally_coherent` and a family containing `φ.neg`.

4. **The `valid_over` definition creates a type-theoretic mismatch**: `timelineQuot_not_valid_of_neg_consistent` must produce a countermodel that lives inside `valid_over D φ`'s quantifier scope (a specific TaskFrame, TaskModel, Omega, history). The parametric canonical structures deliver exactly this.

5. **The singleton BFMCS is insufficient**: The backward direction of the box case in the truth lemma requires `modal_backward`, which depends on the BFMCS containing all necessary witness families. A singleton is inadequate.

---

## Mathematical Analysis

### What `timelineQuot_not_valid_of_neg_consistent` must prove

The goal (after unfolding `valid_over`) is:

```
¬(∀ (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ)
```

where `D = TimelineQuot M₀ h_M₀_mcs`. That is, we must exhibit a specific tuple `(F, M, Omega, h_sc, τ, h_mem, t)` where `truth_at M Omega τ t φ` is false.

The parametric canonical infrastructure provides exactly this tuple:
- `F = ParametricCanonicalTaskFrame (TimelineQuot M₀ h_M₀_mcs)`
- `M = ParametricCanonicalTaskModel (TimelineQuot M₀ h_M₀_mcs)`
- `Omega = ShiftClosedParametricCanonicalOmega B` (requires a BFMCS B)
- `τ = parametric_to_history fam` (requires an FMCS fam in B)
- `t` = some time point where `φ.neg ∈ fam.mcs t`

### What infrastructure already exists

**ParametricTruthLemma.lean** proves (sorry-free):
```
parametric_shifted_truth_lemma (B : BFMCS D) (h_tc : B.temporally_coherent)
    (φ : Formula) (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) :
    φ ∈ fam.mcs t ↔ truth_at (ParametricCanonicalTaskModel D)
      (ShiftClosedParametricCanonicalOmega B) (parametric_to_history fam) t φ
```

**ParametricRepresentation.lean** proves (sorry-free):
```
parametric_representation_from_neg_membership
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (φ : Formula) (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (h_neg_in : φ.neg ∈ fam.mcs t) :
    ¬truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ
```

**TimelineQuotCanonical.lean** provides (sorry-free):
```
timelineQuotFMCS root_mcs root_mcs_proof : FMCS (TimelineQuot root_mcs root_mcs_proof)
timelineQuotMCS_root_time_eq : timelineQuotMCS ... (rootTime ...) = root_mcs
```

The root MCS contains `φ.neg` by Lindenbaum construction, and `rootTime` maps to this MCS. So the witness family and time point are established.

**TimelineQuotAlgebra.lean** provides the algebraic instances:
```
timelineQuotAddCommGroup, timelineQuotIsOrderedAddMonoid
```

### The Single Missing Piece: A BFMCS over TimelineQuot

The proof path is:

1. `φ.neg ∈ M₀` (by Lindenbaum)
2. `timelineQuotMCS ... rootTime = M₀` (by `timelineQuotMCS_root_time_eq`)
3. Therefore `φ.neg ∈ (timelineQuotFMCS M₀ h_M₀_mcs).mcs rootTime`
4. **Need**: A BFMCS B over TimelineQuot with `timelineQuotFMCS` as a member
5. **Need**: `B.temporally_coherent`
6. Apply `parametric_representation_from_neg_membership` to get
   `¬truth_at (ParametricCanonicalTaskModel _) (ShiftClosedParametricCanonicalOmega B) τ rootTime φ`
7. This gives `¬valid_over D φ` via the existential witness

### The BFMCS construction challenge

A BFMCS requires:
- `families`: A set of FMCS instances
- `nonempty`: Non-empty
- `modal_forward`: `□φ ∈ fam.mcs t → ∀ fam' ∈ families, φ ∈ fam'.mcs t`
- `modal_backward`: `(∀ fam' ∈ families, φ ∈ fam'.mcs t) → □φ ∈ fam.mcs t`
- `eval_family` + `eval_family_mem`

For `modal_backward` to be provable without a sorry, the bundle must be **modally saturated**: it must contain witness families for every Box formula. The naive singleton `{timelineQuotFMCS}` fails `modal_backward` because the backward direction requires knowing that φ holds in ALL families (and a singleton is the only one, but this gives an equivalence only if the single family is itself the canonical model for all box-accessible worlds).

**However**: For the purposes of the sorry in `timelineQuot_not_valid_of_neg_consistent`, we only need the **forward** direction of the truth lemma (MCS membership → semantic truth), not the biconditional. The proof of `¬valid_over D φ` only needs:

```
φ.neg ∈ fam.mcs t → ¬truth_at M Omega τ t φ
```

This follows from the **forward** direction of `parametric_shifted_truth_lemma` plus consistency, WITHOUT needing `modal_backward`.

### Simpler proof structure avoiding BFMCS entirely

The forward-only argument works as follows:

**Claim**: If `φ.neg ∈ M₀` (our root MCS), then `¬truth_at M Omega τ rootTime φ` for an appropriate canonical model.

The standard proof of `canonical_truth_lemma` uses `modal_backward` only to prove `box` direction backward (semantic box → syntactic box). But for our goal, we just need the **negation** direction: `φ.neg ∈ M₀` entails `¬truth_at ... φ`, which is equivalent to `truth_at ... φ.neg` by the **forward** direction alone.

Concretely: `φ.neg ∈ fam.mcs t` and by the forward direction of `parametric_shifted_truth_lemma`, `truth_at M Omega τ t φ.neg`. Then `truth_at M Omega τ t φ.neg` unfolds to `¬truth_at M Omega τ t φ` (by definition of `φ.neg` as `φ.imp Formula.bot`).

But this argument requires knowing the forward direction holds for `φ.neg`, and `φ.neg` may contain `□`. The forward direction for box in `parametric_canonical_truth_lemma` is:

```
□ψ ∈ fam.mcs t → ∀ σ ∈ ParametricCanonicalOmega B, truth_at M Omega σ t ψ
```

This DOES use `modal_forward` from the BFMCS, which requires knowing which histories are in Omega. For an Omega equal to a singleton `{τ}`, `modal_forward` must be proven separately.

### The Core Mathematical Gap Precisely Stated

The gap is this single fact: **we need `modal_forward` for `timelineQuotFMCS`**. That is:

```
∀ (φ : Formula) (t : TimelineQuot M₀ h_M₀_mcs),
  □φ ∈ (timelineQuotFMCS M₀ h_M₀_mcs).mcs t →
  ∀ fam' ∈ families, φ ∈ fam'.mcs t
```

Here the choice of `families` determines what `modal_forward` requires. Three approaches:

**Approach A (Minimal)**: Take `families = {timelineQuotFMCS}` (singleton). Then `modal_forward` reduces to:

```
□φ ∈ (timelineQuotFMCS).mcs t → φ ∈ (timelineQuotFMCS).mcs t
```

This is the T-axiom: `□φ → φ`. But this is **NOT** derivable in the base system (it holds for reflexive frames, not general temporal logic). This approach fails.

**Approach B (Full BFMCS)**: Take `families` to be the full set of all FMCS over TimelineQuot built via modal saturation. This is the standard Henkin construction. It requires building the universal BFMCS — a substantial undertaking.

**Approach C (Direct semantic argument)**: Bypass BFMCS entirely and use the existing `CanonicalMCS` construction. The key observation is that `□φ` semantically means "φ holds in ALL histories in Omega". If we set `Omega = ShiftClosedSeparatedOmega M₀ h_M₀_mcs` (from `SeparatedHistory.lean`), then Omega contains only shifts of `separatedHistory`. For the box case forward direction, `□φ ∈ mcs rootTime` needs to imply φ holds at ALL those shifts, which requires `modal_forward` for the dovetailed timeline (all shifted copies must have φ).

**Approach D (Existing ParametricRepresentation pattern)**: The `DovetailedCompleteness.lean` already uses the same sorry — it calls `timelineQuot_not_valid_of_neg_consistent` directly. The dovetailed construction provides `has_future` and `has_past` (seriality), which are the key properties for building a modally saturated BFMCS. Specifically, `dovetailedTimeline_has_future` and `dovetailedTimeline_has_past` from `DovetailedCoverage.lean` provide the witness MCSs needed for `modal_forward`.

---

## Recommended Approach

**The minimal path is Approach D, specialized as follows:**

The dovetailed timeline already proves (in `DovetailedCoverage.lean`):
- `dovetailedTimeline_has_future`: every point has a CanonicalR-future in the timeline
- `dovetailedTimeline_has_past`: every point has a CanonicalR-past in the timeline

These are precisely the witness conditions needed for temporal coherence of the BFMCS. The BFMCS families should be ALL shifts of `timelineQuotFMCS` (the shift-closed version), and modal saturation comes from the following argument:

For `□φ ∈ mcs(t)`, by the definition of `CanonicalR` and modal saturation in the MCS construction, `φ` must be in every MCS accessible via the CanonicalR relation from `mcs(t)`. Since the dovetailed timeline is constructed specifically to be closed under modal witnesses, this holds.

**Concrete proof sketch for the sorry**:

```lean
theorem timelineQuot_not_valid_of_neg_consistent (φ : Formula) (h_cons : ContextConsistent [φ.neg]) :
    ¬valid_over D φ := by
  -- 1. Build BFMCS using timelineQuotFMCS + modal saturation
  let fam := timelineQuotFMCS M₀ h_M₀_mcs
  -- 2. Construct B : BFMCS (TimelineQuot M₀ h_M₀_mcs) with families containing fam
  --    using modal saturation (ModalSaturation.lean)
  -- 3. Note: φ.neg ∈ fam.mcs rootTime by timelineQuotMCS_root_time_eq
  have h_neg : φ.neg ∈ fam.mcs (rootTime M₀ h_M₀_mcs) := by
    rw [show (fam.mcs _) = M₀ from timelineQuotMCS_root_time_eq M₀ h_M₀_mcs]
    exact lindenbaumMCS_contains [φ.neg] h_cons (List.mem_cons_self _ _)
  -- 4. Apply parametric_representation_from_neg_membership
  intro h_valid
  exact parametric_representation_from_neg_membership B h_tc φ fam h_fam_mem
    (rootTime M₀ h_M₀_mcs) h_neg (h_valid ...)
```

The key blocker remaining is proving `B.temporally_coherent` and `B.modal_forward`/`B.modal_backward` for the constructed BFMCS. These follow from the modal saturation construction in `ModalSaturation.lean`.

---

## Evidence/Examples from Codebase

### Evidence 1: The parametric machinery is generic in D

`ParametricTruthLemma.lean` line 49:
```
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```
TimelineQuot satisfies these constraints via `timelineQuotAddCommGroup` and `timelineQuotIsOrderedAddMonoid`.

### Evidence 2: timelineQuotFMCS is already built sorry-free

`TimelineQuotCanonical.lean` lines 312-318: `timelineQuotFMCS` is defined using `timelineQuot_forward_G` and `timelineQuot_backward_H`, both proven without sorry.

### Evidence 3: Root time maps to root MCS

`TimelineQuotCanonical.lean` lines 410-433: `timelineQuotMCS_root_time_eq` is proven without sorry, establishing the connection from `rootTime` back to `M₀`.

### Evidence 4: DovetailedCompleteness already depends on the same sorry

`DovetailedCompleteness.lean` lines 133-137: The dovetailed completeness proof explicitly calls `timelineQuot_not_valid_of_neg_consistent` and acknowledges dependence on the sorry. This confirms the same sorry blocks both proofs.

### Evidence 5: ModalSaturation module exists

`ModalSaturation.lean` (in the Bundle directory) provides infrastructure for modal saturation of BFMCS. This is the key module for building the BFMCS with correct `modal_forward`/`modal_backward`.

### Evidence 6: The parametric approach is validated by the Int case

`IntBFMCS.lean` documents the same BFMCS construction challenge for D = Int. The comment (lines 18-46) explains exactly why a chain construction works: forward_F witnesses are built iteratively, and the dovetailing argument ensures temporal coherence. The same argument applies for D = TimelineQuot.

### Evidence 7: valid_over requires a TaskFrame, not just a truth value

`Validity.lean` lines 54-59: `valid_over D φ` quantifies over ALL TaskFrames F over D. This means the countermodel must use the parametric canonical frame (which is the canonical representative), not an ad-hoc construction.

---

## Confidence Level

**High** (for the mathematical analysis), **Medium** (for the specific Lean proof path).

**High confidence**:
- The mathematical gap is precisely identified: need a BFMCS over TimelineQuot with `timelineQuotFMCS` as a member, satisfying temporal coherence and modal saturation.
- The parametric machinery in `ParametricTruthLemma.lean` and `ParametricRepresentation.lean` is the right tool.
- `timelineQuotFMCS` and `timelineQuotMCS_root_time_eq` are the right entry points.

**Medium confidence**:
- The exact proof term for `modal_forward`/`modal_backward` in the TimelineQuot BFMCS requires detailed investigation of `ModalSaturation.lean` and the dovetailed construction.
- There may be instance mismatches in Lean between the implicit parameters of the parametric framework and the TimelineQuot-specific instances.
- The `valid_over D φ` goal unfolds to a universally quantified statement over TaskFrames, and converting from "there exists a countermodel in the parametric canonical frame" to "valid_over is false" requires showing the witness TaskFrame satisfies the quantifier's typeclass constraints.

---

## Summary of Minimal Proof Path

To fill the sorry in `timelineQuot_not_valid_of_neg_consistent`, the following is needed:

1. **Construct `B : BFMCS (TimelineQuot M₀ h_M₀_mcs)`** with `timelineQuotFMCS M₀ h_M₀_mcs` as a family member. This requires defining `families` to be a modally saturated set and proving `modal_forward` and `modal_backward`.

2. **Prove `B.temporally_coherent`** using the dovetailed timeline's has_future/has_past properties.

3. **Establish `φ.neg ∈ fam.mcs rootTime`** using `timelineQuotMCS_root_time_eq` and the Lindenbaum construction.

4. **Apply `parametric_representation_from_neg_membership`** to get the countermodel.

5. **Convert the countermodel to `¬valid_over D φ`** by showing the parametric canonical frame satisfies `valid_over`'s typeclass constraints.

The hardest step is (1). The dovetailed construction in `DovetailedFMCS.lean` and `DovetailedCoverage.lean` provides the seriality conditions needed. The `ModalSaturation.lean` module provides the modal saturation infrastructure. Connecting these to a BFMCS over TimelineQuot is the core mathematical work.
