# Research Report 003: The Fundamental Problem When Using Standard Validity

**Task**: 930 - Verify correctness of MCS-membership box semantics
**Session**: sess_1772071313_1dd4a0
**Date**: 2026-02-25
**Purpose**: Identify the EXACT problem faced when maintaining standard definitions of validity throughout, and point toward how clever canonical frame construction could solve it.

## 1. The Standard Semantic Stack

### 1.1 What is `TaskFrame D`?

Defined in `Theories/Bimodal/Semantics/TaskFrame.lean` (line 84):

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

A `TaskFrame D` provides:
- A type `WorldState` (the "worlds" of the model)
- A ternary task relation `task_rel w x u` (from state w, a task of duration x leads to state u)
- Nullity (zero-duration task is identity) and compositionality (tasks compose)

### 1.2 What is `WorldHistory F`?

Defined in `Theories/Bimodal/Semantics/WorldHistory.lean` (line 69):

```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D -> Prop
  convex : forall (x z : D), domain x -> domain z -> forall (y : D), x <= y -> y <= z -> domain y
  states : (t : D) -> domain t -> F.WorldState
  respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

A `WorldHistory` is a function from a convex time domain to world states, respecting the task relation. These are the "possible worlds" in the Kripke frame -- each history is a complete trajectory through world states over time.

### 1.3 What is `TaskModel F`?

Defined in `Theories/Bimodal/Semantics/TaskModel.lean` (line 43):

```lean
structure TaskModel (F : TaskFrame D) where
  valuation : F.WorldState -> String -> Prop
```

A `TaskModel` is simply a task frame plus a valuation function that assigns truth values to atoms at each world state.

### 1.4 What is `truth_at`?

Defined in `Theories/Bimodal/Semantics/Truth.lean` (line 112):

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M Omega tau t phi -> truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

Key observations:
- **Box** quantifies over all histories sigma in `Omega` at the SAME time `t`, switching history but not time
- **Temporal operators** quantify over all times in D (not just the history's domain), keeping the SAME history
- **Atoms** are false at times outside the history's domain

### 1.5 What is `valid`?

Defined in `Theories/Bimodal/Semantics/Validity.lean` (line 71):

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

Standard validity quantifies over:
- ALL temporal types D (with ordered abelian group structure)
- ALL task frames F over D
- ALL models M over F
- ALL shift-closed sets Omega of world histories
- ALL histories tau in Omega
- ALL times t in D

The `ShiftClosed Omega` condition ensures time-shift invariance. The condition `tau in Omega` ensures the evaluation history is admissible.

## 2. The BFMCS Semantic Stack

### 2.1 What is `FMCS D`?

Defined in `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` (line 80):

```lean
structure FMCS (D : Type*) [Preorder D] where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t <= t' -> Formula.all_future phi in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' <= t -> Formula.all_past phi in mcs t -> phi in mcs t'
```

An FMCS is a time-indexed family of maximal consistent sets with temporal coherence. It assigns an MCS to each time point, with the G/H propagation properties ensuring temporal formulas behave correctly.

### 2.2 What is `BFMCS D`?

Defined in `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` (line 88):

```lean
structure BFMCS (D : Type*) [Preorder D] where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : forall fam in families, forall phi t,
    Formula.box phi in fam.mcs t -> forall fam' in families, phi in fam'.mcs t
  modal_backward : forall fam in families, forall phi t,
    (forall fam' in families, phi in fam'.mcs t) -> Formula.box phi in fam.mcs t
  eval_family : FMCS D
  eval_family_mem : eval_family in families
```

A BFMCS is a set of FMCS families with modal coherence conditions:
- `modal_forward`: Box phi in any family implies phi in ALL families
- `modal_backward`: phi in ALL families implies Box phi in any family

### 2.3 What is `bmcs_truth_at`?

Defined in `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` (line 87):

```lean
def bmcs_truth_at (B : BFMCS D) (fam : FMCS D) (t : D) : Formula -> Prop
  | Formula.atom p => Formula.atom p in fam.mcs t
  | Formula.bot => False
  | Formula.imp phi psi => bmcs_truth_at B fam t phi -> bmcs_truth_at B fam t psi
  | Formula.box phi => forall fam' in B.families, bmcs_truth_at B fam' t phi
  | Formula.all_past phi => forall s, s <= t -> bmcs_truth_at B fam s phi
  | Formula.all_future phi => forall s, t <= s -> bmcs_truth_at B fam s phi
```

This mirrors `truth_at` but in the BFMCS setting: atoms check MCS membership, box quantifies over bundle families, temporal operators quantify over all times.

### 2.4 How does BFMCS connect to Model? Is there a `bfmcs_to_model` function?

**There is NO `bfmcs_to_model` function in the codebase.** This is the core gap.

The standard semantics lives in `Bimodal.Semantics` and operates on `TaskFrame`, `TaskModel`, `WorldHistory`, `truth_at`, `valid`.

The BFMCS semantics lives in `Bimodal.Metalogic.Bundle` and operates on `FMCS`, `BFMCS`, `bmcs_truth_at`, `bmcs_valid`.

These are two completely separate semantic stacks with no formal bridge between them.

## 3. The Semantic Gap

### 3.1 Are `truth_at` and `bmcs_truth_at` supposed to be equivalent?

**No -- they are structurally different and operate on different objects.**

`truth_at` evaluates formulas in a `TaskModel F` with a set `Omega` of `WorldHistory F` objects. It requires:
- World states (type `F.WorldState`)
- A valuation function mapping world states to propositional truth
- World histories (functions from convex time domains to world states)
- A shift-closed set Omega of admissible histories
- Domain membership checks for atoms

`bmcs_truth_at` evaluates formulas in a `BFMCS D` with a set of `FMCS D` families. It requires:
- Maximal consistent sets (sets of formulas)
- MCS membership for atoms
- A bundle of families for box quantification
- Preorder structure on D (weaker than AddCommGroup + LinearOrder + IsOrderedAddMonoid)

The key structural differences:

| Aspect | `truth_at` | `bmcs_truth_at` |
|--------|-----------|----------------|
| **Atoms** | Domain check + valuation on world state | MCS membership |
| **Box** | Quantifies over `WorldHistory F` in Omega | Quantifies over `FMCS D` in bundle |
| **Temporal** | Quantifies over times in D | Quantifies over times in D |
| **Domain** | Histories have convex domains; atoms false outside domain | No domain concept; MCS exists at every time |
| **Time type** | `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D` | `Preorder D` (weaker) |

### 3.2 What lemma would connect them?

To connect them, you would need to construct a `TaskFrame`, `TaskModel`, and set `Omega` of `WorldHistory` objects from a `BFMCS`, such that:

```
truth_at M_canonical Omega_canonical tau_fam t phi  <->  bmcs_truth_at B fam t phi
```

This would require:

1. **Canonical TaskFrame**: Define `WorldState := ???`, `task_rel := ???` satisfying nullity and compositionality
2. **Canonical WorldHistories**: For each `FMCS` family `fam`, construct a `WorldHistory` with `domain t = True` (or some appropriate domain), `states t _ = ???`
3. **Canonical Valuation**: Define `valuation w p := ???` such that atom truth matches MCS membership
4. **Canonical Omega**: The set of all canonical histories derived from bundle families

### 3.3 Does this bridge lemma exist?

**No.** There is no such construction anywhere in the codebase. The two semantic stacks are completely disconnected.

### 3.4 Why doesn't it exist?

The fundamental obstruction is that **the BFMCS world is purely syntactic while the standard semantics is world-state-based**. The translation requires:

1. **World states from MCS**: Each MCS is a set of formulas. A natural candidate for `WorldState` is `Set Formula` (or a quotient thereof). This is the "canonical model" approach.

2. **Valuation from MCS membership**: `valuation M p := (Formula.atom p) in M`. This is standard.

3. **Task relation from MCS accessibility**: `task_rel M d N := CanonicalR M N` (or some duration-indexed variant). This is where the difficulty lies -- the task relation is duration-indexed while MCS accessibility is typically binary.

4. **Domain from temporal structure**: Each FMCS family covers all time points, so the domain would be `fun _ => True` (universal domain). This is achievable but requires the canonical task frame to be reflexive.

5. **Omega from bundle families**: Map each `FMCS D` family to a `WorldHistory` by defining `states t _ := fam.mcs t` (treating MCS as world states). The set Omega is the image of this mapping.

The real challenge is item (3): constructing a well-defined duration-indexed task relation that is (a) compatible with the standard `TaskFrame` axioms (nullity, compositionality) and (b) makes the `WorldHistory.respects_task` condition hold for the canonical histories.

## 4. The Exact Point of Failure

### 4.1 The completeness theorem we want

The ideal theorem chain would be:

```
not (Derivable [] phi)
  -> exists model, not (truth_at M Omega tau t phi)   [canonical model construction]
  -> not (valid phi)                                    [instantiation]
```

By contraposition: `valid phi -> Derivable [] phi`

### 4.2 Where the standard completeness chain currently stands

The CURRENT completeness chain in `Completeness.lean` proves:

```
bmcs_valid phi -> Nonempty (DerivationTree [] phi)
```

This uses `bmcs_valid` (not standard `valid`). There is a separate soundness chain:

```
Derivable [] phi -> valid phi
```

So the current state gives: `Derivable [] phi <-> bmcs_valid phi -> valid phi`

But this does NOT give: `valid phi -> Derivable [] phi`

The missing implication would require: `valid phi -> bmcs_valid phi`, which would need a proof that every standard model can be faithfully represented as a BFMCS. This is the "converse soundness" direction, and it is non-trivial.

### 4.3 What ACTUALLY blocks the standard proof

The standard approach to `valid phi -> Derivable [] phi` works by contraposition:

1. Assume `not (Derivable [] phi)`
2. Then `[neg phi]` is consistent
3. Construct a canonical model (TaskFrame, TaskModel, Omega) from the consistent set
4. Show `truth_at M_canonical Omega_canonical tau_canonical t_canonical (neg phi)`
5. Therefore `not (valid phi)`

Step 3 is where the difficulty lies. To build a standard `TaskModel`:

**Step 3a**: Define `WorldState`. Natural choice: world states are MCS (or elements of `CanonicalBC`).

**Step 3b**: Define `task_rel`. Natural choice: `task_rel M d N := CanonicalR M N` ignoring duration (or some duration-sensitive variant). For nullity, we need `CanonicalR M M`, which holds (proven: `canonicalR_reflexive`). For compositionality, we need transitivity of `CanonicalR`, which also holds (proven: `canonicalR_transitive`).

However, duration `d` is ignored, making task_rel independent of duration. This is potentially fine -- many frames have permissive task relations (like `trivial_frame` where `task_rel _ _ _ = True`).

**Step 3c**: Define `WorldHistory` for each FMCS family. For a family `fam : FMCS D`, define:
```
tau_fam.domain := fun _ => True    -- universal domain
tau_fam.states t _ := fam.mcs t    -- MCS at time t IS the world state
```

For this to be a valid `WorldHistory`, we need:
- Convexity: trivial (domain is universal)
- `respects_task`: for all s <= t, `task_rel (fam.mcs s) (t - s) (fam.mcs t)`

If `task_rel` is defined as `fun M d N => CanonicalR M N` (ignoring d), then we need `CanonicalR (fam.mcs s) (fam.mcs t)` whenever `s <= t`. This is exactly the `forward_G` coherence: if `G phi in fam.mcs s`, then `phi in fam.mcs t`. The GContent of `fam.mcs s` is a subset of `fam.mcs t`, which IS the definition of `CanonicalR`.

So: **the canonical history construction works for the eval family** (which has non-trivial `forward_G`).

**Step 3d**: Define `Omega`. The set of all `WorldHistory` objects corresponding to bundle families.

**Step 3e**: Show `ShiftClosed Omega`. This requires: for any `tau_fam in Omega` and any shift `Delta`, the shifted history `time_shift tau_fam Delta` is also in `Omega`.

**THIS IS THE CRITICAL FAILURE POINT.**

A time-shifted history `time_shift tau_fam Delta` has `states t _ = fam.mcs (t + Delta)`. This corresponds to a "shifted" FMCS family `fam_shifted` where `fam_shifted.mcs t = fam.mcs (t + Delta)`. For this shifted family to be in Omega, it would need to correspond to some family in the BFMCS bundle.

But the bundle has a FIXED set of families. Shifting a family temporally produces a NEW family that is NOT necessarily in the bundle. The bundle is NOT closed under temporal shift.

### 4.4 Summary of the failure

The proof breaks at **ShiftClosed Omega**. The standard definition of validity requires that the set Omega of admissible histories is closed under time shifts. But:

1. Each BFMCS family gives rise to ONE world history
2. Time-shifting that history produces a history from a DIFFERENT (shifted) family
3. The shifted family is not necessarily in the BFMCS bundle
4. Therefore Omega (the set of canonical histories) is NOT shift-closed

This is a fundamental mismatch between:
- **Standard validity**: requires shift-closed Omega (time-translation invariance)
- **BFMCS construction**: produces a bundle of families that is NOT closed under time shifts

## 5. What the Canonical Frame Needs

### 5.1 The core property needed

To make the standard proof work, the canonical construction needs to produce a set Omega of WorldHistories that is **ShiftClosed**. This means:

**For every family `fam` in the bundle and every time shift `Delta`, the shifted family (where `mcs t = fam.mcs (t + Delta)`) must also be in the bundle.**

### 5.2 Can this be achieved?

**Yes, if the bundle is constructed to be shift-closed from the start.**

The key insight is that shift-closure is a property of the BUNDLE, not of individual families. If we define the bundle as:

```
families := { fam_shifted | fam in base_families, Delta in D,
              fam_shifted.mcs t = fam.mcs (t + Delta) }
```

i.e., the closure of some base set of families under time shifts, then Omega would be shift-closed by construction.

### 5.3 What would that construction look like?

**Option 1: Shift-closed bundle directly**

Start with the eval family `fam_0` (extending the consistent context). For each time shift `Delta`, define `fam_Delta` where `fam_Delta.mcs t = fam_0.mcs (t + Delta)`. The bundle is `{ fam_Delta | Delta in D }`.

Properties to verify:
- **Each `fam_Delta.mcs t` is an MCS**: Yes, because `fam_0.mcs (t + Delta)` is an MCS.
- **`forward_G` for `fam_Delta`**: If `G phi in fam_Delta.mcs t = fam_0.mcs (t + Delta)` and `t <= t'`, then `phi in fam_0.mcs (t' + Delta)` by `fam_0.forward_G` (since `t + Delta <= t' + Delta`). So `phi in fam_Delta.mcs t'`. This works.
- **`backward_H` for `fam_Delta`**: Similarly works.
- **Modal forward**: If `Box phi in fam_Delta.mcs t`, does `phi in fam_{Delta'}.mcs t` for all `Delta'`? This means: `Box phi in fam_0.mcs (t + Delta)` implies `phi in fam_0.mcs (t + Delta')` for all `Delta'`. This is NOT automatically true -- it would require that the eval family's MCS at one time controls what's in its MCS at ARBITRARY other times, which is far too strong.

**This fails for the same reason the original approach fails**: modal coherence across different time-shifted families is not guaranteed.

**Option 2: Use a permissive Omega that is NOT derived from the bundle**

Instead of deriving Omega from the BFMCS bundle, construct a MUCH LARGER Omega that is shift-closed by design.

Define:
- WorldState = Set Formula (all MCS)
- task_rel M d N = True (completely permissive)
- WorldHistory: domain = fun _ => True, states can be ANY function D -> Set Formula where each value is an MCS and adjacent values are connected by CanonicalR
- Omega = the set of ALL such well-formed world histories

This Omega is trivially shift-closed (shifting any such history produces another such history). The valuation is `valuation M p = (Formula.atom p in M)`.

The issue: with Omega containing ALL well-formed histories, the box quantifier in `truth_at` would quantify over ALL of them, making `Box phi` true only if `phi` is true in ALL MCS at time `t`. This is actually correct for S5-like semantics.

But for the truth lemma, we need: `Box phi in MCS <-> forall histories in Omega, phi true at t`. The forward direction (Box phi in MCS -> phi true everywhere) requires showing that any MCS in Omega at time t satisfies phi -- this needs the S5 property that Box phi propagates to ALL accessible worlds. The backward direction needs: if phi is true at all accessible worlds, then Box phi is in the original MCS.

The backward direction is where modal saturation comes in: if `neg(Box phi)` is in the MCS, then `Diamond(neg phi)` is in the MCS, so there should exist a history in Omega where `neg phi` holds. This requires that EVERY diamond witness is REALIZED in Omega -- i.e., Omega is modally saturated.

With the completely permissive Omega (all well-formed histories), this follows from the existence of Lindenbaum extensions for any consistent set.

### 5.4 The promising path

The most promising path is:

1. **Define the canonical frame with `WorldState = CanonicalBC`** (MCS with fixed BoxContent), `task_rel M d N = True` (permissive).

2. **Define world histories** where each history has universal domain and assigns `states t _ = some_MCS_at_t` respecting CanonicalR.

3. **Define Omega = Set.univ** (all such world histories). Since `Set.univ` is trivially shift-closed, the ShiftClosed condition is satisfied immediately.

4. **Define valuation**: `valuation M p = (Formula.atom p in M.world)` (where M is a CanonicalBC element).

5. **Prove the truth lemma**: For the eval family's canonical history `tau_eval`:
   ```
   truth_at M_canonical Set.univ tau_eval t phi  <->  phi in fam_eval.mcs t
   ```

   This truth lemma would need to handle:
   - **Atom**: `exists (ht : tau_eval.domain t), M_canonical.valuation (tau_eval.states t ht) p <-> Formula.atom p in fam_eval.mcs t`. With universal domain, ht is trivially True. With valuation = MCS membership, this becomes `Formula.atom p in (fam_eval.mcs t).world <-> Formula.atom p in fam_eval.mcs t`. These are the same thing.
   - **Bot, Imp**: Standard recursive cases.
   - **Box**: `(forall sigma in Set.univ, truth_at M sigma t phi) <-> Box phi in fam_eval.mcs t`. The key case.
   - **Temporal**: Similar to existing proofs.

   The box case requires:
   - **Forward**: `Box phi in fam_eval.mcs t -> forall sigma (any world history), truth_at M sigma t phi`. This needs: for ANY world history sigma, `phi` is true at time `t`. Since sigma can be ANY history, `sigma.states t _` can be ANY MCS (with the right BoxContent). So we need: `Box phi in fam_eval.mcs t -> phi in N` for every MCS N with the same BoxContent. This is exactly what `chainBundle_modal_forward` proves via BoxContent.

   - **Backward**: `(forall sigma, truth_at M sigma t phi) -> Box phi in fam_eval.mcs t`. By IH, this becomes: `(forall N : MCS with same BoxContent, phi in N) -> Box phi in fam_eval.mcs t`. This is exactly `chainBundle_modal_backward`.

### 5.5 The remaining difficulty

The box backward case above works perfectly -- it matches the existing `chainBundleBFMCS` construction. The real difficulty is in the **temporal box interaction**.

When we use `Set.univ` as Omega, the box case quantifies over ALL world histories, not just the ones from the bundle. The IH for the box case says: for each world history sigma, `phi in (sigma's MCS at t) <-> truth_at M sigma t phi`. But this IH requires the truth lemma to hold for ALL histories, not just the eval family's history.

For histories corresponding to **constant** families (same MCS at all times), the temporal cases of the truth lemma require temporal coherence of that constant family. A constant family has `forward_G: G phi in M -> phi in M` (true by T-axiom), but the backward temporal case requires: `(forall s >= t, phi in M) -> G phi in M`. Since M is constant, this reduces to `phi in M -> G phi in M`, which would require `forward_F: F psi in M -> psi in M` (temporal saturation). This is exactly the obstruction that created the sorry.

**The fundamental problem restated**: Using standard validity with `Set.univ` as Omega forces the truth lemma to hold for ALL world histories. Histories from constant (non-temporally-coherent) families break the temporal backward case.

### 5.6 The resolution via clever frame construction

The solution is to NOT use `Set.univ` as Omega, but instead to use a carefully constructed Omega that:

1. **Contains enough histories for the box backward case** (modal saturation -- for every diamond formula, there's a witness history)
2. **Contains enough histories for shift-closure** (every shifted history is in Omega)
3. **Only contains histories for which the truth lemma holds** (all histories are temporally coherent)

This means: **every history in Omega must correspond to a temporally coherent FMCS family.**

Concretely, the canonical construction would:

1. Start with the eval family (non-constant, temporally coherent by construction)
2. For modal saturation: when Diamond(psi) is encountered, construct a witness family that is ALSO temporally coherent (not just a constant family). This is the key innovation -- witness families should be non-constant temporally coherent families, not constant families.
3. For shift-closure: include all time-shifted versions of all families in the bundle. Since time-shifting a temporally coherent family produces another temporally coherent family (the coherence properties transform naturally), this preserves the needed property.

**The core insight**: The obstruction arose because the `chainBundleBFMCS` construction uses CONSTANT witness families (which are not temporally coherent). If witness families were constructed as NON-CONSTANT temporally coherent families, the standard truth lemma would apply to all families, and the standard completeness proof would go through.

This is exactly the challenge that `fully_saturated_bfmcs_exists_int` faces (and currently has a sorry for): combining temporal coherence with modal saturation. But framed this way, the problem is NOT about alternative notions of validity. It is about constructing the canonical model carefully enough that ALL its components are temporally coherent.

## 6. Precise Statement of the Mathematical Obstruction

### 6.1 The sorry in `fully_saturated_bfmcs_exists_int`

Located in `TemporalCoherentConstruction.lean` (line 797-817):

```lean
theorem fully_saturated_bfmcs_exists_int (...) :
    exists (B : BFMCS Int),
      (forall gamma in Gamma, gamma in B.eval_family.mcs 0) /\
      B.temporally_coherent /\
      is_modally_saturated B := by
  sorry
```

This theorem needs to construct a BFMCS that is SIMULTANEOUSLY:
- **Temporally coherent**: Every family has forward_F and backward_P
- **Modally saturated**: Every Diamond formula has a witness family

### 6.2 Why these conflict

The `chainBundleBFMCS` achieves modal saturation by adding CONSTANT witness families. When Diamond(psi) is encountered at family fam time t, a new MCS N is created containing psi and BoxContent(fam.mcs t), and a constant family mapping every time to N is added.

A constant family maps every time to the SAME MCS. For temporal coherence of a constant family at MCS N, we need:
- `forward_F`: F(phi) in N implies exists s >= t, phi in N. Since N is constant, this becomes: F(phi) in N implies phi in N (temporal saturation).
- `backward_P`: P(phi) in N implies exists s <= t, phi in N. Similarly: P(phi) in N implies phi in N.

But F(phi) in N does NOT imply phi in N in general. The formula F(phi) says "phi at some future time" -- it does NOT say "phi at the current time." An MCS can contain `F(psi)` and `neg psi` consistently (meaning: psi is not true now but will be true in the future).

### 6.3 The path forward

The resolution requires one of:

**Path A**: Construct witness families that are NON-CONSTANT and temporally coherent. When Diamond(psi) is encountered at time t, instead of creating a constant family at a fresh MCS, create a dovetailing chain (like the eval family) that passes through the witness MCS at time t and extends temporally in both directions. Each witness family would be its own temporally coherent FMCS, constructed via a mini-dovetailing-chain.

This is mathematically sound but requires significant construction infrastructure: each Diamond witness triggers a mini-chain construction.

**Path B**: Prove that the standard truth lemma holds even for constant families, by weakening the temporal backward requirement. This would require showing that the truth lemma for the box case does NOT need the temporal backward property of witness families.

Looking at the truth lemma's box case more carefully:

```
Box phi in fam.mcs t
  <-> (by modal coherence) phi in fam'.mcs t for all fam'
  <-> (by IH) bmcs_truth_at B fam' t phi for all fam'
```

The IH step `phi in fam'.mcs t <-> bmcs_truth_at B fam' t phi` must hold for ALL fam' in the bundle, including constant witness families. For the IH to work on a constant witness family fam', we need the truth lemma to hold at fam'. If phi is a temporal formula (e.g., `G psi`), the backward direction of the truth lemma at fam' requires temporal coherence of fam'. This is where it breaks.

**Path C (the CanonicalBC approach)**: As already implemented in `chainBundleBFMCS.lean`, use `CanonicalBC` as the time domain (MCS with fixed BoxContent form their own preorder). The eval family maps each CanonicalBC element to its OWN MCS, making it inherently temporally coherent. This approach works for BFMCS completeness (`bmcs_valid`), but connecting to standard validity (`valid`) still requires the frame construction described in Section 5.

## 7. Summary and Recommendations

### 7.1 The Fundamental Problem

The fundamental problem when maintaining standard validity throughout is:

**The standard `truth_at` definition requires the truth lemma to hold for ALL world histories in Omega. Constant witness families (used for modal saturation) are NOT temporally coherent, so the truth lemma fails for their corresponding histories. This prevents the canonical model from being well-defined under standard semantics.**

### 7.2 The Resolution

The resolution must come from clever canonical frame construction, NOT from alternative validity notions:

1. **Make ALL witness families temporally coherent** (Path A): construct non-constant witness families via mini-dovetailing-chains
2. **Use CanonicalBC as the time domain** (Path C): already implemented, inherently avoids the problem because the eval family is the only family that needs temporal coherence for the truth lemma
3. **Bridge from CanonicalBC completeness to standard validity**: construct a TaskFrame from CanonicalBC and show the equivalence

### 7.3 The key insight

The `bmcs_truth_at_mcs` approach (Task 925) sidesteps the problem by changing the BOX case to NOT recurse into the truth predicate. This means the truth lemma's box case does not need the IH to hold for all families -- it only needs modal coherence (phi in all MCSes <-> Box phi in MCS).

To achieve the same result with standard `truth_at`, we need to ensure the IH holds for all families. This means making all families temporally coherent. The eval family IS temporally coherent (it is a non-constant dovetailing chain). The witness families are NOT (they are constant). The fix is to make witness families non-constant and temporally coherent.

### 7.4 Relationship to existing sorry

The sorry in `fully_saturated_bfmcs_exists_int` is EXACTLY the sorry that encapsulates this fundamental problem. Resolving it by constructing temporally coherent witness families would simultaneously:
- Eliminate the sorry
- Enable the standard truth lemma to work for all families
- Make the standard completeness proof go through
- Remove the need for `bmcs_truth_at_mcs`

This is a single, well-defined mathematical challenge: **construct a BFMCS where every family (including modal witnesses) is temporally coherent**.
