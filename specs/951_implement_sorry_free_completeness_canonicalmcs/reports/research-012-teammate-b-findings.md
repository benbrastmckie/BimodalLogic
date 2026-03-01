# Teammate B Findings: Preorder vs AddCommGroup Requirements

## Executive Summary

The claim "TruthLemma and CanonicalConstruction both work with just `Preorder D`" is **partially correct but critically misleading**. The BFMCS-level truth lemma (`bmcs_truth_lemma`) and the BFMCS/FMCS structures genuinely require only `Preorder D`. However, the **completeness theorem as a whole** cannot work with just `Preorder D` because:

1. The completeness statement itself (`valid phi -> Derivable [] phi`) quantifies over `AddCommGroup D`, `LinearOrder D`, and `IsOrderedAddMonoid D` in the definition of `valid`.
2. `TaskFrame D` requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.
3. The canonical construction instantiates `D = Int`, which has all these structures.

The "just Preorder" claim is about the internal proof machinery (BFMCS layer), not the external semantic interface.

## Key Findings: Constraint Requirements by Component

### 1. FMCS (FMCSDef.lean, line 57): `[Preorder D]` only

```lean
variable (D : Type*) [Preorder D]

structure FMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t <= t' -> Formula.all_future phi in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' <= t -> Formula.all_past phi in mcs t -> phi in mcs t'
```

**Evidence**: Line 57 of FMCSDef.lean declares `variable (D : Type*) [Preorder D]`. No group structure, no zero, no addition needed. The FMCS only needs a `<=` relation on the time type.

### 2. BFMCS (BFMCS.lean, line 57): `[Preorder D]` only

```lean
variable (D : Type*) [Preorder D]

structure BFMCS where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : ...
  modal_backward : ...
  eval_family : FMCS D
  eval_family_mem : eval_family in families
```

**Evidence**: Line 57 of BFMCS.lean. No group structure needed.

### 3. BFMCSTruth (BFMCSTruth.lean, line 53): `[Preorder D]` only

```lean
variable {D : Type*} [Preorder D]

def bmcs_truth_at (B : BFMCS D) (fam : FMCS D) (t : D) : Formula -> Prop
```

**Evidence**: Line 53 of BFMCSTruth.lean. The truth definition for the BFMCS layer only needs `<=` for temporal quantification.

### 4. TruthLemma (TruthLemma.lean, line 81): `[Preorder D] [Zero D]`

```lean
variable {D : Type*} [Preorder D] [Zero D]

theorem bmcs_truth_lemma (B : BFMCS D) (h_tc : B.temporally_coherent)
    (fam : FMCS D) (hfam : fam in B.families) (t : D) (phi : Formula) :
    phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

**Evidence**: Line 81 of TruthLemma.lean. The `[Zero D]` instance is required because the `bmcs_eval_truth` corollary (line 410) evaluates at time `0`, and the `TemporalCoherentFamily` structure (used in the temporal backward cases) requires `[Zero D]`.

**IMPORTANT**: `Zero D` is NOT the same as `AddCommGroup D`. It provides only a distinguished element `0 : D`, without any algebraic operations. This is a much weaker requirement than a group structure.

### 5. TemporalCoherentFamily (TemporalCoherentConstruction.lean, line 204): `[Preorder D] [Zero D]`

```lean
structure TemporalCoherentFamily (D : Type*) [Preorder D] [Zero D] extends FMCS D where
  forward_F : forall t : D, forall phi : Formula,
    Formula.some_future phi in mcs t -> exists s : D, t <= s /\ phi in mcs s
  backward_P : forall t : D, forall phi : Formula,
    Formula.some_past phi in mcs t -> exists s : D, s <= t /\ phi in mcs s
```

**Evidence**: Line 54 of TemporalCoherentConstruction.lean: `variable {D : Type*} [Preorder D] [Zero D]`.

### 6. TaskFrame (TaskFrame.lean, line 84): `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

**Evidence**: Line 84 of TaskFrame.lean. The `nullity` axiom requires `0 : D` (from `AddCommGroup`), and the `compositionality` axiom requires `+` on `D` (from `AddCommGroup`). These are fundamental to the frame's definition.

### 7. truth_at (Truth.lean, line 82): `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`

```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {F : TaskFrame D}

def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
```

**Evidence**: Line 82 of Truth.lean. Since `truth_at` depends on `TaskModel F` and `TaskFrame D`, it inherits all of TaskFrame's constraints.

### 8. valid / semantic_consequence (Validity.lean, lines 72, 95): `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

**Evidence**: Lines 72-75 of Validity.lean. Validity universally quantifies over all D with these three typeclasses. This is the *definition* of semantic validity for TM logic.

### 9. CanonicalConstruction (CanonicalConstruction.lean, line 128): Hardcoded `D = Int`

```lean
def CanonicalTaskFrame : TaskFrame Int where ...
def CanonicalTaskModel : TaskModel CanonicalTaskFrame where ...

theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent) ... :
    phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

**Evidence**: Line 128 of CanonicalConstruction.lean. The canonical construction hardcodes `D = Int`, which has all required structures (`AddCommGroup Int`, `LinearOrder Int`, `IsOrderedAddMonoid Int`).

### 10. Linearity Axiom (Axioms.lean, lines 292-321): Forces totality of the temporal order

```lean
| temp_linearity (phi psi : Formula) :
    Axiom (Formula.and (Formula.some_future phi) (Formula.some_future psi) |>.imp ...)
```

**Evidence**: Lines 292-321 of Axioms.lean. The `temp_linearity` axiom schema captures the principle that the temporal order is total (linear). Its soundness proof (Soundness.lean, line 236: `temp_linearity_valid`) explicitly uses `LinearOrder D`:

```
intro T _ _ _ F M Omega _h_sc tau _h_mem t
```

The soundness of this axiom requires that for any two times `s1, s2 : D`, either `s1 <= s2` or `s2 <= s1`. This IS the `LinearOrder` condition. The linearity axiom would be unsound over a `Preorder D` that is not linear.

## Where Linearity Axiom Forces LinearOrder

The linearity axiom `temp_linearity` is the explicit mechanism by which the proof system enforces a linear (total) temporal order. The chain of implication is:

1. **Proof system includes `temp_linearity`** (Axioms.lean)
2. **Soundness theorem proves `temp_linearity` valid** (Soundness.lean)
3. **Soundness proof uses `LinearOrder D`** in the validity quantifier
4. **Therefore completeness must construct a model with `LinearOrder D`** for the soundness-completeness round-trip to work

This means: the Preorder-level BFMCS machinery is internally correct, but the canonical model it constructs must ultimately live in a type with `LinearOrder D` to model a sound axiom. The codebase handles this by instantiating `D = Int`, which is `LinearOrder`.

## Where AddCommGroup Becomes Required

AddCommGroup enters the picture through multiple independent pathways:

### Pathway 1: TaskFrame Definition (Primary)

`TaskFrame D` requires `[AddCommGroup D]` for:
- **nullity**: `task_rel w 0 w` (needs `0 : D`)
- **compositionality**: `task_rel w (x + y) v` (needs `+ : D -> D -> D`)

### Pathway 2: WorldHistory / time_shift (Secondary)

The `time_shift` operation on world histories uses `+` and `-`:
```lean
WorldHistory.time_shift sigma Delta  -- shifts domain/states by Delta
```
This requires `AddCommGroup D` for `+`, `-`, `neg`.

### Pathway 3: Soundness of MF and TF Axioms (Secondary)

The `time_shift_preserves_truth` theorem (Truth.lean, line 344) uses:
- `y - x` (subtraction, from AddCommGroup)
- `add_sub_cancel`, `sub_sub_cancel`, etc. (group identities)
- `ShiftClosed Omega` (requires time_shift, hence addition)

This theorem is essential for proving the MF and TF interaction axioms valid.

### Pathway 4: Validity Definition (Structural)

The definition `valid` quantifies `forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. The completeness theorem must produce a model in a type satisfying these constraints.

## The Two-Layer Architecture

The codebase has a **two-layer architecture** with different constraint requirements:

| Layer | Files | Constraints on D | Purpose |
|-------|-------|-------------------|---------|
| **BFMCS Layer** (inner) | FMCSDef, BFMCS, BFMCSTruth, TruthLemma, TemporalCoherentConstruction | `Preorder D` (+ `Zero D` for temporal backward) | Henkin-style MCS manipulation; purely proof-theoretic |
| **Semantic Layer** (outer) | TaskFrame, TaskModel, Truth, Validity, WorldHistory | `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D` | Standard task semantics; connects to paper's definition |

The **CanonicalConstruction** module bridges these two layers by instantiating `D = Int` and building a `TaskFrame Int` from BFMCS data.

## Analysis: Is "Just Preorder" Claim Correct?

**Verdict: Technically correct for the BFMCS layer, but misleading for the completeness proof as a whole.**

- **Correct**: The bmcs_truth_lemma, FMCS, BFMCS, and BFMCSTruth genuinely only need `Preorder D` (plus `Zero D` for temporal backward).
- **Misleading**: The completeness theorem connects to `valid`, which requires `AddCommGroup D` + `LinearOrder D` + `IsOrderedAddMonoid D`. The canonical construction hardcodes `D = Int`. The `temp_linearity` axiom is unsound without `LinearOrder`.
- **The gap**: The BFMCS layer works with Preorder because it never mentions `+`, `-`, or `0` on the time type (except through `Zero D`). It only uses `<=`. The AddCommGroup requirements come from the semantic definitions (TaskFrame, validity, time_shift).

## Detailed Constraint Dependency Chain

```
valid phi                          requires [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  |
  v
truth_at M Omega tau t phi         requires [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  |                                  (inherited from TaskModel <- TaskFrame)
  v
canonical_truth_lemma              uses D = Int (has all structures)
  |                                  bridges bmcs_truth_at <-> truth_at
  v
bmcs_truth_lemma                   requires [Preorder D] [Zero D]
  |                                  (internal BFMCS layer)
  v
FMCS, BFMCS, BFMCSTruth           requires [Preorder D] only
```

## Confidence Level

**High** - This analysis is based on direct examination of type signatures in the actual Lean source code. Every constraint claim is supported by the specific `variable` declarations and structure definitions in the codebase. The two-layer architecture (BFMCS with Preorder vs Semantics with AddCommGroup) is a deliberate and well-documented design choice visible throughout the code.
