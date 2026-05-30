# Dense Completeness Pipeline Analysis

## Overview

This report traces the dense completeness pipeline end-to-end, from "formula is not provable" to "countermodel exists as a TaskFrame." It documents every intermediate construction, its file location, and how it chains into the next step. The goal is to understand how the dense pipeline packages its countermodel so the discrete pipeline can follow the same pattern.

## 1. The TaskFrame Type

**File**: `Theories/Bimodal/Semantics/TaskFrame.lean`

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

**Fields**:
- `WorldState`: an arbitrary type of "world states"
- `task_rel w d u`: world state `u` is reachable from `w` via a task of duration `d`
- `nullity_identity`: zero-duration task relates exactly identical states (`task_rel w 0 u <-> w = u`)
- `forward_comp`: non-negative-duration tasks compose (`task_rel w x u` and `task_rel u y v` give `task_rel w (x+y) v` when `0 <= x`, `0 <= y`)
- `converse`: temporal symmetry (`task_rel w d u <-> task_rel u (-d) w`)

**Critical constraint**: `D` must be a totally ordered abelian group (`AddCommGroup D + LinearOrder D + IsOrderedAddMonoid D`). For the dense case, `D = Rat`. For the discrete case, `D = Int`.

There is also `FiniteTaskFrame D` extending `TaskFrame D` with `finite_world : Finite WorldState` (used for the FMP, not the completeness pipeline).

## 2. Supporting Semantic Types

### WorldHistory

**File**: `Theories/Bimodal/Semantics/WorldHistory.lean`

```lean
structure WorldHistory {D ...} (F : TaskFrame D) where
  domain : D → Prop
  convex : ∀ x z, domain x → domain z → ∀ y, x ≤ y → y ≤ z → domain y
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ s t (hs : domain s) (ht : domain t), s ≤ t →
    F.task_rel (states s hs) (t - s) (states t ht)
```

A function from a convex time domain to world states, respecting the task relation.

### TaskModel

**File**: `Theories/Bimodal/Semantics/TaskModel.lean`

```lean
structure TaskModel {D ...} (F : TaskFrame D) where
  valuation : F.WorldState → Atom → Prop
```

A frame plus a valuation function (which atoms are true at which world states).

### truth_at

**File**: `Theories/Bimodal/Semantics/Truth.lean`

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
```

The six-way recursive truth definition: atoms check domain membership + valuation, bot is False, imp is material conditional, box quantifies over all histories in Omega, until/since use strict witness with open guard.

### ShiftClosed and valid

**File**: `Theories/Bimodal/Semantics/Truth.lean` and `Validity.lean`

```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  ∀ σ ∈ Omega, ∀ (Δ : D), WorldHistory.time_shift σ Δ ∈ Omega

def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

Validity quantifies over ALL duration types D, ALL frames, ALL models, ALL shift-closed Omega sets, ALL histories in Omega, ALL times.

## 3. End-to-End Dense Completeness Pipeline

The completeness theorem `completeness_dense` is in `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`.

### Step 1: Contrapositive Setup

**File**: `BXCanonical/Completeness.lean`, theorem `completeness_dense`

Assume phi is not derivable (`¬Nonempty (DerivationTree FrameClass.Dense [] φ)`). Then `{neg phi}` is consistent (by `neg_consistent_of_not_derivable`). By Lindenbaum's lemma (`set_lindenbaum`), extend to MCS `M` containing `neg phi`.

### Step 2: Case Split on Density

**File**: `BXCanonical/Completeness.lean`, inside `completeness_dense`

Split on whether `Box(F'T)` is in `M` (where `F'T = neg(U(T, bot))` = "not next_top"):

- **Dense case** (`Box(next_top.neg) ∈ M`): all box-accessible MCS's are dense. This is the main path documented below.
- **Non-dense case** (`neg(Box(next_top.neg)) ∈ M`): impossible for Dense-derivability because the `dense_indicator` axiom (`neg(U(T,bot))`) is a Dense theorem, so its box is in every Dense-MCS. Contradiction.

### Step 3: Chronicle Construction (Burgess 1982)

**File**: `BXCanonical/Chronicle/ChronicleConstruction.lean`

Starting from MCS `A`, build a countable chain of MCS's on the rationals:
- `limit_dom fc A h_mcs : Set Rat` -- the limit domain (countable subset of Q containing 0)
- `limit_f fc A h_mcs : Rat → Set Formula` -- MCS assignment to each domain point
- `limit_f_zero : limit_f(0) = A` -- origin maps to the root MCS
- `limit_c0 : x ∈ limit_dom → SetMaximalConsistent (limit_f x)` -- each point is an MCS

Key coherence properties:
- `limit_forward_G`: G-formulas at `x` propagate to all strictly future domain points `y > x`
- `limit_backward_H`: H-formulas at `x` propagate to all strictly past domain points `y < x`
- `limit_satisfies_c5_strong`: Until (C5) -- if `U(phi, psi) ∈ limit_f(x)`, there exists `y > x` in limit_dom with `phi ∈ limit_f(y)` and psi in all intermediate MCS's
- `limit_satisfies_c4`: Counterexample elimination (C4) -- if `neg(U(phi, psi)) ∈ limit_f(x)` and `phi ∈ limit_f(y)` for y > x, there exists z with `x < z < y` and `neg(psi) ∈ limit_f(z)`
- `limit_F_resolution`, `limit_P_resolution`: F/P-formula witnesses

### Step 4: Density Proof and Cantor Isomorphism

**File**: `BXCanonical/Chronicle/ChronicleToCountermodel.lean`

From `Box(F'T) ∈ A`:
1. **Derive density at all domain points** (`box_dense_gives_density`): Since `Box(neg(U(T,bot))) ∈ A`, by S5 this propagates to all limit domain points via G and H. Then `neg(U(T,bot)) ∈ limit_f(x)` for all `x ∈ limit_dom`.

2. **Prove LimitDomSubtype is densely ordered** (`limit_dom_dense_from_F'T`): Given `x < y` in limit_dom, apply C4 with `neg(U(T,bot))` at x and `T` at y to get z with `x < z < y`.

3. **Cantor isomorphism** (`cantor_iso_dense`): The subtype `LimitDomSubtype = {q : Rat // q ∈ limit_dom}` is countable, densely ordered, has no min/max, and is nonempty. By Cantor's theorem (`Order.iso_of_countable_dense`): `LimitDomSubtype ≃o Rat`.

### Step 5: FMCS on Rat

**File**: `BXCanonical/Chronicle/ChronicleToCountermodel.lean`

Transport the chronicle MCS assignment through the Cantor isomorphism:

```lean
noncomputable def cantor_fmcs_dense : FMCS Rat where
  mcs q := limit_f(cantor_iso.symm(q).val)
  is_mcs q := limit_c0(cantor_iso.symm(q).property)
  forward_G := -- transported through iso.symm.strictMono
  backward_H := -- transported through iso.symm.strictMono
```

**Key definition**: `FMCS D` (File: `Bundle/FMCSDef.lean`):
```lean
structure FMCS (fc : FrameClass := FrameClass.Base) where
  mcs : D → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  forward_G : ∀ t t' φ, t < t' → Formula.all_future φ ∈ mcs t → φ ∈ mcs t'
  backward_H : ∀ t t' φ, t' < t → Formula.all_past φ ∈ mcs t → φ ∈ mcs t'
```

An FMCS is a single family of MCS's indexed by time D, with G/H coherence. The Cantor iso gives us FMCS Rat because the iso preserves the strict ordering.

Then `rooted_cantor_fmcs_dense fc N h_N h_box_N s` shifts the FMCS so that `mcs(s) = N` (the root MCS).

### Step 6: BFMCS (Bundle) on Rat

**File**: `BXCanonical/Chronicle/ChronicleToCountermodel.lean`, def `cantor_bfmcs_dense`

The BFMCS (File: `Bundle/BFMCS.lean`) bundles multiple FMCS families with modal coherence:

```lean
structure BFMCS (fc : FrameClass := FrameClass.Base) where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : ∀ fam ∈ families, ∀ φ t, Box φ ∈ fam.mcs t → ∀ fam' ∈ families, φ ∈ fam'.mcs t
  modal_backward : ∀ fam ∈ families, ∀ φ t, (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Box φ ∈ fam.mcs t
  eval_family : FMCS D
  eval_family_mem : eval_family ∈ families
```

The `cantor_bfmcs_dense` construction:

```lean
families := { fam | ∃ N h_N h_box_N s,
  (∀ ψ, Box ψ ∈ A ↔ Box ψ ∈ N) ∧
  fam = rooted_cantor_fmcs_dense fc N h_N h_box_N s }
```

One family per box-equivalent MCS N (with shift s). Each N gets its OWN Burgess chronicle and Cantor iso. The density hypothesis `Box(F'T) ∈ A` transfers to `Box(F'T) ∈ N` by box-equivalence, so N's chronicle is also dense.

**Modal coherence proofs**:
- Forward: `Box φ ∈ fam.mcs(t)` --> box stability --> `Box φ ∈ N` --> box-equiv --> `Box φ ∈ A` --> box-equiv --> `Box φ ∈ N'` --> box stability --> `Box φ ∈ fam'.mcs(t)` --> Modal T --> `φ ∈ fam'.mcs(t)`.
- Backward: contrapositive. If `Box φ ∉ A`, then `neg(Box φ) ∈ A`, then diamond(neg phi) in A, then `bx_modal_witness_fc` gives witness v box-equivalent to A with `neg(phi) ∈ v`, so `rooted_cantor_fmcs_dense v t` has `mcs(t) = v` with both phi (from h_all) and neg(phi), contradiction.

### Step 7: Parametric Canonical TaskFrame

**File**: `Algebraic/ParametricCanonical.lean`

```lean
def ParametricCanonicalWorldState (fc : FrameClass := FrameClass.Base) : Type :=
  { M : Set Formula // SetMaximalConsistent M }

def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D) (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then ExistsTask M.val N.val      -- g_content M ⊆ N
  else if d < 0 then ExistsTask N.val M.val  -- converse
  else M = N                                  -- d = 0

noncomputable def ParametricCanonicalTaskFrame D : TaskFrame D := ...
```

**This is the key**: `WorldState = ParametricCanonicalWorldState` = subtypes of MCS's. The task relation between world states M, N at duration d is defined by:
- d > 0: forward temporal accessibility (G-content of M is subset of N)
- d = 0: identity (M = N)
- d < 0: backward (converse)

The TaskFrame axioms are proved:
- nullity_identity: trivial from d=0 case
- forward_comp: chains via `canonicalR_transitive` (uses temp_4: G(phi) -> G(G(phi)))
- converse: symmetry via sign flip

### Step 8: FMCS to WorldHistory

**File**: `Algebraic/ParametricHistory.lean`

```lean
def parametric_to_history (fam : FMCS D) : WorldHistory (ParametricCanonicalTaskFrame D) where
  domain := fun _ => True              -- full domain
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩
  respects_task := -- forward_G gives ExistsTask when d > 0; d = 0 gives equality
```

**Critical design**: `domain = True` everywhere (full domain). This avoids all domain-related complexity. The `states` function at time t returns the MCS `fam.mcs(t)` wrapped as a `ParametricCanonicalWorldState`. The `respects_task` proof uses `fam.forward_G` for the positive-duration case.

### Step 9: Shift-Closed Omega

**File**: `Algebraic/ParametricHistory.lean`

```lean
def ShiftClosedParametricCanonicalOmega (B : BFMCS D) : Set (WorldHistory ...) :=
  { σ | ∃ fam ∈ B.families, ∃ delta, σ = WorldHistory.time_shift (parametric_to_history fam) delta }
```

Takes all time-shifts of all family histories. Proved shift-closed because time-shifting twice composes (`delta + delta'`).

### Step 10: Parametric Canonical TaskModel

**File**: `Algebraic/ParametricTruthLemma.lean`

```lean
def ParametricCanonicalTaskModel D : TaskModel (ParametricCanonicalTaskFrame D) where
  valuation := fun M p => Formula.atom p ∈ M.val
```

Valuation: atom p is true at MCS M iff `atom p ∈ M.val`.

### Step 11: Truth Lemma (Restricted)

**File**: `Algebraic/RestrictedParametricTruthLemma.lean`

```lean
theorem restricted_parametric_shifted_truth_lemma (B : BFMCS D) (root : Formula)
    (h_rtc : B.restricted_temporally_coherent root)
    (h_buc : B.backward_until_since_coherent)
    (h_fuc : B.forward_until_since_coherent) (φ : Formula)
    (h_sub : φ ∈ subformulaClosure root) (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) :
    φ ∈ fam.mcs t ↔ truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ
```

The restricted truth lemma requires only restricted temporal coherence (for formulas in `deferralClosure root`), not full temporal coherence. This is needed because the chronicle construction only guarantees coherence for bounded-depth formulas.

The proof is by structural induction on phi:
- atom: by definition of valuation
- bot: both sides False
- imp: bidirectional (forward uses backward IH, backward uses forward IH and MCS modus ponens)
- box: by modal_forward and modal_backward of BFMCS
- until/since: forward by forward_until_since_coherent (C5); backward by backward_until_since_coherent (C4 contrapositive)

### Step 12: Final Assembly (countermodel_dense)

**File**: `BXCanonical/Chronicle/ChronicleToCountermodel.lean`, theorem `countermodel_dense`

```lean
theorem countermodel_dense (fc : FrameClass) (A : Set Formula) (h_mcs : ...) (φ : Formula)
    (h_neg_in : φ.neg ∈ A) (h_box_dense : Formula.box next_top.neg ∈ A) :
    ∃ (D : Type) (...) (F : TaskFrame D) (TM : TaskModel F) (Omega : Set (WorldHistory F))
      (_ : ShiftClosed Omega) (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ
```

Instantiates:
- `D := Rat`
- `F := ParametricCanonicalTaskFrame Rat`
- `TM := ParametricCanonicalTaskModel Rat`
- `Omega := ShiftClosedParametricCanonicalOmega (cantor_bfmcs_dense ...)`
- `τ := parametric_to_history (rooted_cantor_fmcs_dense fc A h_mcs h_box_dense 0)`
- `t := 0`

Then `neg(phi) ∈ eval_family.mcs(0)` and by the restricted truth lemma, `neg(phi)` is true at the canonical model at time 0, so `phi` is false. Contradiction with validity.

### Step 13: completeness_dense wraps it up

**File**: `BXCanonical/Completeness.lean`

`completeness_dense` uses `countermodel_dense_enriched` which is identical to `countermodel_dense` but with Rat made explicit in the existential output so that `DenselyOrdered` is available. The final step instantiates `valid_dense` at the Rat-based countermodel to get `truth_at ... φ`, contradicting `¬truth_at ... φ`.

## 4. How the Dense Pipeline Packages the Countermodel as a TaskFrame

The critical insight: **the dense pipeline never needs to build a TaskFrame from the chronicle domain directly**. Instead:

1. The `ParametricCanonicalTaskFrame D` has `WorldState = ParametricCanonicalWorldState` (MCS subtypes), NOT the time domain. World states and time indices are completely separate types.

2. The Cantor isomorphism (`LimitDomSubtype ≃o Rat`) serves ONLY to transport the MCS assignment from the chronicle's irregular domain to the standard rationals. The TaskFrame's WorldState type does not change.

3. The `parametric_to_history` function creates a WorldHistory by assigning `states(t) = fam.mcs(t)` wrapped as an MCS subtype. The domain is `True` (all of D = Rat).

4. The task relation `parametric_canonical_task_rel` between MCS world-states is defined purely in terms of `ExistsTask` (= g_content inclusion), which is independent of the time domain.

**In summary**: the countermodel is a `TaskFrame Rat` where:
- WorldState = all MCS's (not dependent on Rat)
- task_rel checks G-content inclusion for forward, converse for backward
- WorldHistory has full domain (all rationals are valid times)
- Omega = shift-closed set of family histories
- Valuation = MCS membership for atoms

## 5. Conservative Extension and Weak Semantics

### Conservative Extension

**Files**: `ConservativeExtension/ExtFormula.lean`, `Lifting.lean`, `Substitution.lean`

The conservative extension introduces a fresh atom `q` (via `ExtAtom = Atom + Unit`, with `freshAtom = Sum.inr ()`). The extended formula type `ExtFormula` mirrors `Formula` but with `ExtAtom` atoms.

The lifting infrastructure (`substDerivation`, `unembedFormula`, `unembed_embed`) provides tools to project derivations in the extended system back to the original system via substitution `sigma[q -> bot]`.

However, **the conservative extension is NOT on the critical path of the dense completeness pipeline**. The dense pipeline goes directly through the chronicle construction and parametric algebraic completeness without using the conservative extension. The conservative extension appears to be part of the WeakCanonical (Reynolds/Doets) machinery for the discrete case.

### WeakCanonical / "Weak Semantics"

**Files**: `WeakCanonical/` directory

The WeakCanonical module provides the Reynolds/Doets discrete completeness proof. The key components:

1. **ChronicleExtraction** (`ChronicleExtraction.lean`): Extracts a `ChronicleAsPriorModel` from an MCS with `Box(next_top) ∈ A`. The chronicle is a countable, discrete linear order without endpoints satisfying Prior-UZ/SZ (Reynolds Corollary 3).

2. **Monadic FO Framework** (`MonadicFO.lean`, `NEquivalence.lean`): Defines monadic first-order logic, ordered monadic structures, k-types, and k-equivalence. This is the Doets/Reynolds framework for transferring truth between structures.

3. **Table Translation** (`Table.lean`): Translates temporal formulas to monadic FO sentences via the `table` function, with `table_correctness` ensuring temporal truth corresponds to FO satisfaction.

4. **Good/Very Good Structures** (`IntegerModel/GoodStructures.lean`): A structure is "good at depth k" if it is k-equivalent to some Z-interval structure. The `chronicle_is_good_direct` theorem proves the chronicle is good (with sorry at `no_gaps_discrete`).

5. **Truth Transfer** (`Transfer.lean`): The `truth_transfer` theorem shows that k-equivalent structures agree on all temporal formulas of operator depth at most k-1. The `chronicle_temporal_truth` lemma connects temporal truth on the chronicle-as-monadic-structure to MCS membership.

6. **Z-Interval to TaskFrame** (`Transfer.lean`): The `zIntervalTaskFrame` is a `TaskFrame Int` with `WorldState = Unit` and `task_rel = fun _ _ _ => True`. This is the simplest possible frame -- it has no structure beyond the integers as the time domain.

The **"weak" operators / weak semantics** are NOT explicit operators in the formula syntax. Rather, the "weakness" refers to the fact that the monadic FO translation treats temporal formulas as monadic predicates on a linear order, effectively working with the "predicate" semantics (temporal truth as monadic satisfaction) rather than the full task-frame semantics. The bridge between these two semantic layers is the `truth_transfer` theorem and the `z_interval_countermodel` packaging.

## 6. Intermediate Structures: Chronicle to TaskFrame

### For the Dense Case (D = Rat)

```
MCS A with neg(phi), Box(F'T)
    |
    v
[ChronicleConstruction.lean]
limit_dom, limit_f  (chronicle on countable subset of Q)
    |
    v
[ChronicleToCountermodel.lean]
LimitDomSubtype ≃o Rat  (Cantor isomorphism)
cantor_fmcs_dense : FMCS Rat  (transported through iso)
rooted_cantor_fmcs_dense : FMCS Rat  (shifted to place A at origin)
cantor_bfmcs_dense : BFMCS Rat  (bundle over box-equivalent MCS's)
    |
    v
[ParametricCanonical.lean]
ParametricCanonicalTaskFrame Rat  (WorldState = MCS subtype)
ParametricCanonicalTaskModel Rat  (valuation = MCS membership)
    |
    v
[ParametricHistory.lean]
parametric_to_history : FMCS Rat → WorldHistory (PCTaskFrame Rat)
ShiftClosedParametricCanonicalOmega : Set (WorldHistory ...)
    |
    v
[RestrictedParametricTruthLemma.lean]
phi ∈ fam.mcs(t) ↔ truth_at PCTaskModel Omega (to_history fam) t phi
    |
    v
neg(phi) ∈ A = fam.mcs(0) → ¬truth_at ... phi → countermodel exists
```

### For the Discrete Case (D = Int, current implementation)

The discrete case (`dd_countermodel_chronicle_discrete`) follows the EXACT SAME pattern as the dense case, just with:
- `cantor_bfmcs_discrete` instead of `cantor_bfmcs_dense`
- `rooted_succ_discrete_fmcs` instead of `rooted_cantor_fmcs_dense`
- `D = Int` instead of `D = Rat`
- The iso is `LimitDomSubtype ≃o Int` via `orderIsoIntOfLinearSuccPredArch` (requires `IsSuccArchimedean`, which has the `succ_cofinal` sorry)

### For the Discrete Case (Reynolds pipeline, alternative)

The Reynolds pipeline (`countermodel_discrete_reynolds`, sorry at `no_gaps_discrete`) takes a different path:

```
MCS A with neg(phi), Box(next_top)
    |
    v
[ChronicleExtraction.lean]
ChronicleAsPriorModel  (countable discrete without endpoints)
    |
    v
[Transfer.lean, IntegerModel/]
chronicleAsMonadicStructure  (monadic FO structure on chronicle domain)
chronicle_is_good_direct  (k-equivalent to Z-interval)
    |
    v
[Transfer.lean]
truth_transfer  (neg(phi) truth transfers via k-equiv)
    |
    v
[Transfer.lean]
z_interval_countermodel  (package as TaskFrame Int with WorldState = Unit)
```

This pipeline has a sorry at `no_gaps_discrete` in `chronicle_is_good_direct`. Once that is resolved, it would bypass the `succ_cofinal` sorry entirely.

## 7. Why the Dense Pipeline Avoids the Packaging Problem

The discrete pipeline's "packaging problem" is about building a `LimitDomSubtype ≃o Int` isomorphism, which requires `IsSuccArchimedean` (the `succ_cofinal` sorry). The dense pipeline avoids this entirely because:

1. **Cantor's theorem is unconditional** for countable dense linear orders without endpoints. The dense pipeline only needs: countable + densely ordered + no min + no max + nonempty. All of these are proved directly from the chronicle construction and the density hypothesis. No archimedean property is needed.

2. **The parametric canonical construction is agnostic to the iso mechanism**. Both dense and discrete use `ParametricCanonicalTaskFrame D` and `parametric_to_history`. The difference is only in HOW the FMCS is transported to the target D:
   - Dense: Cantor iso (`Order.iso_of_countable_dense`)
   - Discrete: Z-characterization (`orderIsoIntOfLinearSuccPredArch`)

3. **The task frame itself never depends on the isomorphism**. `ParametricCanonicalTaskFrame D` is defined uniformly for any D. The WorldState type is always MCS subtypes. The iso only enters when defining `cantor_f_dense q = limit_f(iso.symm(q).val)` -- transporting the MCS assignment through the iso.

## 8. Key Takeaway for Building the Discrete Analog

The dense pipeline works because:
1. Build chronicle (FMCS on limit_dom subset of Rat) -- SHARED with discrete
2. Prove limit_dom has the right order-theoretic properties (density for dense, discreteness for discrete)
3. Apply characterization theorem (Cantor for dense, Z-char for discrete) to get iso to target D
4. Transport FMCS through iso to get FMCS D
5. Build BFMCS D with modal coherence
6. Use parametric canonical infrastructure (TaskFrame D, to_history, truth lemma)
7. Package as countermodel

Step 3 is where the discrete pipeline has trouble: the Z-characterization requires `IsSuccArchimedean`, which has the `succ_cofinal` sorry. The Reynolds pipeline alternative avoids this by going through k-equivalence and monadic FO transfer instead of building an explicit iso to Int.

## 9. Sorry Status Summary

### Dense Pipeline
- 1 sorry: `CounterexampleElimination.lean:3570` -- density g-value consistency in the Cantor iso requiring `DenselyOrdered` on the limit domain. Task 117 targets this.

### Discrete Pipeline (current, via `dd_countermodel_chronicle_discrete`)
- 1 sorry chain: `succ_cofinal` in `limitDomSubtype_isSuccArchimedean` -- the well-founded termination argument for the succ chain reaching any target element. Task 202 targets this.

### Discrete Pipeline (alternative, via `countermodel_discrete_reynolds`)
- 1 sorry: `no_gaps_discrete` in `chronicle_is_good_direct` -- proving the chronicle has no Dedekind gaps when discreteness holds. This is INDEPENDENT of `succ_cofinal`.

### Mixed Case
- Eliminated by `mcs_mixed_case_absurd` (task 142) using `discrete_box_necessity` axiom.
