# Research Report 006: Parametric D Strategy for Standard Completeness

**Task**: 930
**Session**: sess_1740493500_r930b
**Date**: 2026-02-25
**Focus**: Parametric D with LinearOrderedAddCommGroup for standard completeness

---

## Executive Summary

This report analyzes the concrete path to achieving standard completeness (using `valid` from `Validity.lean`) through a parametric D strategy. The analysis reveals that **a complete standard completeness chain already exists** in `Representation.lean`, and it uses `D = Int` as required. The chain has exactly **one sorry** (inherited from `fully_saturated_bfmcs_exists_int`). The parametric D question is therefore not about "finding a new D" but about "eliminating the sorry in the existing Int-based chain."

The key finding is that the `ChainBundleBFMCS.lean` construction (which IS sorry-free) and the `Representation.lean` construction (which targets standard `valid` but has a sorry) solve DIFFERENT problems -- and there is a concrete path to merge their strengths.

---

## 1. Current Architecture: Two Completeness Chains

### 1.1 Chain A: Sorry-Free with Custom Validity (ChainBundleBFMCS.lean)

**Domain**: `CanonicalBC BC` (MCSes with fixed BoxContent)
**Truth**: `bmcs_truth_at_mcs` (Box = MCS membership, not recursive)
**Validity**: `bmcs_valid_mcs` (custom, NOT standard `valid`)
**Sorry count**: 0

Key properties:
- `D = CanonicalBC BC` with `Preorder` only (NOT LinearOrderedAddCommGroup)
- Box case: `forall fam' in families, phi in fam'.mcs t` (membership-based)
- Temporal cases: only require coherence of the eval family (which IS coherent)
- The eval family is `canonicalBCBFMCS` where `mcs w = w.world`

**Completeness proven**:
```lean
theorem bmcs_weak_completeness_mcs (phi : Formula) (h_valid : bmcs_valid_mcs phi) :
    Nonempty (DerivationTree [] phi)
```

**Why it works without sorry**: The eval family maps each `CanonicalBC` element to its own MCS, so forward_F/backward_P follow from `canonical_forward_F`/`canonical_backward_P`. Constant witness families need no temporal coherence because Box uses MCS membership, not recursive truth.

### 1.2 Chain B: Standard Validity with Sorry (Representation.lean)

**Domain**: `Int` (a LinearOrderedAddCommGroup)
**Truth**: Standard `truth_at` from `Truth.lean`
**Validity**: Standard `valid` from `Validity.lean`
**Sorry count**: 1 (inherited from `fully_saturated_bfmcs_exists_int`)

Key properties:
- `D = Int` with full `LinearOrderedAddCommGroup` structure
- Box case: `forall sigma in Omega, truth_at M Omega sigma t phi` (standard)
- Temporal cases: standard `forall s, s <= t -> truth_at ...`
- Uses `shiftClosedCanonicalOmega B` for shift-closed Omega

**Completeness proven (modulo sorry)**:
```lean
theorem standard_weak_completeness (phi : Formula) (h_valid : valid phi) :
    Nonempty (DerivationTree [] phi)
```

**Where the sorry lives**: `fully_saturated_bfmcs_exists_int` in `TemporalCoherentConstruction.lean` claims the existence of a BFMCS over Int that is BOTH temporally coherent AND modally saturated. This theorem has a `sorry` because combining these two properties simultaneously is non-trivial.

---

## 2. What Standard Validity Requires of D

From `Validity.lean` line 71-75:

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

D must have:
1. `AddCommGroup D` -- abelian group structure (commutative +, 0, negation)
2. `LinearOrder D` -- total ordering
3. `IsOrderedAddMonoid D` -- order compatible with addition

These are used in:
- `TaskFrame.nullity`: uses `0 : D`
- `TaskFrame.compositionality`: uses `+ : D -> D -> D`
- `WorldHistory.respects_task`: uses `- : D -> D -> D` (subtraction)
- `WorldHistory.time_shift`: uses `+ : D -> D -> D`
- `ShiftClosed`: uses translation by D elements
- Standard `truth_at` temporal cases: uses `<=` (linear order on D)

### 2.1 Why CanonicalBC Cannot Be D for Standard Validity

`CanonicalBC BC` has:
- `Preorder` (via `CanonicalR` -- reflexive, transitive)
- No `AddCommGroup` (no + operation on MCSes)
- No `LinearOrder` (CanonicalR is not total)

These are structural impossibilities, not fixable by adding instances.

### 2.2 Why Int IS the Right Choice

Int satisfies all requirements:
- `AddCommGroup Int` -- standard integer arithmetic
- `LinearOrder Int` -- standard integer ordering
- `IsOrderedAddMonoid Int` -- ordering compatible with addition

The existing `Representation.lean` already uses `D = Int`. The question is not "what D to use" but "how to construct a sorry-free BFMCS over Int."

---

## 3. Analysis of the Sorry in the Int Chain

### 3.1 The Sorry Statement

```lean
theorem fully_saturated_bfmcs_exists_int (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (B : BFMCS Int),
      (forall gamma in Gamma, gamma in B.eval_family.mcs 0) /\
      B.temporally_coherent /\
      is_modally_saturated B
```

This needs to produce a `BFMCS Int` that simultaneously satisfies:
1. **Context preservation**: Gamma is at eval_family.mcs 0
2. **Temporal coherence** for ALL families: forward_F and backward_P
3. **Modal saturation**: for every Diamond(psi) in any family at time t, there exists a witness family

### 3.2 Why It's Hard

The difficulty is in combining (2) and (3):

- **Temporal coherence** of the eval family is achievable via DovetailingChain (has 2 sorries for F/P witnesses)
- **Modal saturation** creates constant witness families (same MCS at all times)
- **Constant families need temporal saturation** (F(psi) in M implies psi in M) for temporal coherence
- **Temporal saturation of a single MCS is impossible** in general ({F(psi), neg(psi)} is consistent but violates F(psi) -> psi)

### 3.3 The DovetailingChain Sorries

`DovetailingChain.lean` has exactly 2 sorries:
- `forward_F`: F(phi) in M_t implies exists s > t with phi in M_s
- `backward_P`: P(phi) in M_t implies exists s < t with phi in M_s

These cannot be resolved in the linear chain because F-formulas do not persist through GContent seeds.

---

## 4. The Concrete Path: Merge Chain A's Strategy into Chain B

### 4.1 Key Insight: Chain A's MCS-Membership Box Works Over Int Too

The `bmcs_truth_at_mcs` definition in `ChainBundleBFMCS.lean` is parameterized by `{D : Type*} [Preorder D]`. It works for ANY D including Int. Similarly, `bmcs_truth_lemma_mcs` works for any D with `[Preorder D] [Zero D]`, which Int satisfies.

The key realization is:

**The sorry-free completeness from Chain A can be re-instantiated with D = Int + CanonicalBC as the Preorder, then bridged to standard validity.**

But this doesn't directly help because `CanonicalBC` is not Int. What CAN work:

### 4.2 Strategy: Rebuild ChainBundle Over Int

Instead of using `CanonicalBC BC` as the domain, construct the same eval-family + constant-witness-family bundle pattern over `Int`:

1. **Start with DovetailingChain** to get a `FMCS Int` (the eval family) extending Gamma
2. **Use the same constant-family pattern** as `ChainBundleBFMCS.lean` for witness families
3. **Use `bmcs_truth_at_mcs`** (Box via MCS membership) instead of `bmcs_truth_at`

The critical question: does `MCSBoxContent` preservation work when the families are indexed by `Int` instead of `CanonicalBC`?

**Answer**: YES, but with a caveat. The `chainBundleBFMCS` construction in `ChainBundleBFMCS.lean` relies on the fact that all families at any time point `t : CanonicalBC BC` have `MCSBoxContent(fam.mcs t) = BC`. When the eval family is `mcs w = w.world`, this holds because `w.bc_eq : MCSBoxContent w.world = BC`.

For an Int-indexed family from DovetailingChain, the question is: does `MCSBoxContent(fam.mcs t)` stay constant as t varies? If the DovetailingChain family preserves BoxContent along the chain (i.e., `MCSBoxContent(M_t) = MCSBoxContent(M_0)` for all t), then the same construction works.

### 4.3 Does DovetailingChain Preserve BoxContent?

The DovetailingChain seeds each step with `GContent(M_{t-1})` (forward) or `HContent(M_{t+1})` (backward). The key question: does `GContent(M) subset N` imply `MCSBoxContent(M) = MCSBoxContent(N)`?

From `ChainBundleBFMCS.lean`:
- `MCSBoxContent_eq_of_CanonicalR` proves that `CanonicalR M M'` implies `MCSBoxContent M = MCSBoxContent M'`
- `CanonicalR M M'` means `GContent M subset M'`

The DovetailingChain seed for step n (constructing M_t from M_{t-1}) includes `GContent(M_{t-1})` in the seed, and Lindenbaum extends to MCS N with `GContent(M_{t-1}) subset N`. This means `CanonicalR M_{t-1} N`, which by `MCSBoxContent_eq_of_CanonicalR` gives `MCSBoxContent(M_{t-1}) = MCSBoxContent(N)`.

**YES, BoxContent is preserved along the forward direction.** Similarly for the backward direction via `MCSBoxContent_reverse_of_CanonicalR`.

Therefore: `MCSBoxContent(fam.mcs t) = MCSBoxContent(fam.mcs 0)` for ALL t in the DovetailingChain.

### 4.4 The Construction

Define `BC := MCSBoxContent(fam.mcs 0)` where `fam` is the DovetailingChain family. Then:

1. **Eval family**: The DovetailingChain `fam : FMCS Int`
   - Has forward_G and backward_H (proven in DovetailingChain)
   - Has forward_F and backward_P (sorry in DovetailingChain, BUT see below)

2. **Witness families**: For each Diamond(psi) in any family's MCS at time t, create a constant family at the Lindenbaum MCS extending `{psi} union MCSBoxContent(fam.mcs t)`

3. **Modal coherence**: Box(phi) in fam.mcs t implies phi in all families' MCS at t -- follows from BoxContent equality (same argument as `chainBundle_modal_forward`)

4. **Truth definition**: Use `bmcs_truth_at_mcs` (Box via MCS membership)

5. **Truth lemma**: `bmcs_truth_lemma_mcs` requires only temporal coherence of the EVAL family

### 4.5 The F/P Witness Problem Reconsidered

The truth lemma `bmcs_truth_lemma_mcs` requires:
- `h_forward_F`: for the eval family, F(phi) in mcs t implies exists s >= t with phi in mcs s
- `h_backward_P`: for the eval family, P(phi) in mcs t implies exists s <= t with phi in mcs s

These are exactly the 2 remaining sorries in DovetailingChain. However, there is a crucial difference from the old approach:

**We do NOT need temporal coherence for constant witness families.** The `bmcs_truth_at_mcs` definition means Box uses MCS membership directly. The truth lemma only traverses the eval family's temporal structure.

So the sorry count would be: 2 sorries (same as DovetailingChain's forward_F/backward_P).

### 4.6 Can We Avoid Even These 2 Sorries?

The CanonicalBC approach avoids these sorries because:
- The eval family maps `w : CanonicalBC BC` to `w.world`
- forward_F comes from `canonical_forward_F` which constructs a new `CanonicalBC` element
- backward_P comes from `canonical_backward_P` similarly

The question is: can we embed the CanonicalBC structure into Int?

**This is the fundamental obstacle**: `CanonicalBC BC` is an uncountable type (there are uncountably many MCSes over countably many formulas). We cannot embed it into Int.

However, we don't actually need ALL of `CanonicalBC BC`. We only need:
- The eval family needs enough domain elements to provide F/P witnesses
- The constant witness families need no temporal structure

For the eval family, we need a chain of MCSes indexed by Int with forward_F and backward_P. This is EXACTLY what `temporal_coherent_family_exists_Int` provides (modulo the 2 sorries from DovetailingChain).

---

## 5. The Standard Completeness Bridge

### 5.1 From bmcs_truth_at_mcs to truth_at

Even if we build a sorry-free BFMCS over Int with `bmcs_truth_at_mcs` semantics, we need to connect to standard `truth_at`. The gap:

- `bmcs_truth_at_mcs` Box case: `forall fam' in families, phi in fam'.mcs t`
- `truth_at` Box case: `forall sigma in Omega, truth_at M Omega sigma t phi`

These are structurally different. However, `Representation.lean` already bridges this gap for `bmcs_truth_at` (where Box = recursive truth over bundle). The key theorem is `canonical_truth_lemma_all` and `shifted_truth_lemma`.

For `bmcs_truth_at_mcs`, we would need an analogous bridge. The structure is:

```
phi in fam.mcs t  <--(bmcs_truth_lemma_mcs)-->  bmcs_truth_at_mcs B fam t phi
                                                     |
                                                 (need bridge)
                                                     |
phi in fam.mcs t  <--(canonical_truth_lemma_all)--> truth_at M Omega tau t phi
```

The bottom row already exists in `Representation.lean`. So if we have `phi in fam.mcs t` from the Chain A truth lemma, we can directly apply the `Representation.lean` truth lemma to get `truth_at`.

**In other words**: the bridge is already built. The `shifted_truth_lemma` in `Representation.lean` already proves `phi in fam.mcs t <-> truth_at M (shiftClosedCanonicalOmega B) tau t phi` for any BFMCS B over Int that is temporally coherent.

### 5.2 The Complete Path

1. Use `temporal_coherent_family_exists_Int` to get an eval FMCS over Int (2 sorries)
2. Build the chainBundle pattern (eval + constant witness families) over Int
3. Apply `bmcs_truth_lemma_mcs` for the intermediate completeness (`bmcs_valid_mcs -> derivable`) -- sorry-free
4. OR apply `shifted_truth_lemma` from `Representation.lean` for the standard completeness (`valid -> derivable`) -- same 2 sorries

Wait -- step 2 and 3 together give us a new sorry-free intermediate chain over Int. But step 4 requires the B from step 2 to be temporally coherent for ALL families, not just the eval family. The constant families are NOT temporally coherent (unless their MCS is temporally saturated).

**This is the same obstruction**: `shifted_truth_lemma` requires `B.temporally_coherent` which means ALL families (including constant witness families) need forward_F and backward_P.

### 5.3 A New Shifted Truth Lemma with Per-Family Coherence

The resolution: write a variant of `shifted_truth_lemma` that, like `bmcs_truth_lemma_mcs`, only requires temporal coherence of the eval family. This would be:

```lean
theorem shifted_truth_lemma_eval (B : BFMCS Int)
    (h_forward_F : forall t phi, F(phi) in B.eval_family.mcs t -> exists s >= t, phi in B.eval_family.mcs s)
    (h_backward_P : forall t phi, P(phi) in B.eval_family.mcs t -> exists s <= t, phi in B.eval_family.mcs s)
    (phi : Formula) (t : Int) :
    phi in B.eval_family.mcs t <->
    truth_at (canonicalModel B) (shiftClosedCanonicalOmega B) (canonicalHistory B B.eval_family ...) t phi
```

**But this CANNOT work for Box**: The box case of `shifted_truth_lemma` handles shifted histories `time_shift (canonicalHistory fam') delta`. The IH needs `phi in fam'.mcs (t + delta)` iff `truth_at ... (canonicalHistory fam') (t + delta) phi`. This requires the truth lemma to hold for ALL families, not just the eval family. And for non-eval families (constant families), the temporal backward direction (`truth at all future times -> G(phi) in mcs`) requires forward_F of that constant family.

### 5.4 Using bmcs_truth_at_mcs Semantics for the Canonical Model

An alternative approach: instead of connecting to the standard `truth_at`, define a NEW standard-semantics truth predicate that uses MCS-membership for Box (analogous to `bmcs_truth_at_mcs`):

```lean
def truth_at_mcs (M : TaskModel F) (Omega : ...) (B_families : ...) (tau : ...) (t : D) : Formula -> Prop
  | atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | bot => False
  | imp phi psi => truth_at_mcs ... phi -> truth_at_mcs ... psi
  | box phi => forall fam' in B_families, phi in fam'.mcs t  -- MCS membership!
  | all_past phi => forall s <= t, truth_at_mcs ... s phi
  | all_future phi => forall s >= t, truth_at_mcs ... s phi
```

But this mixes the semantic world (truth_at with TaskModel) with the syntactic world (MCS membership), which is non-standard and defeats the purpose.

### 5.5 The Real Resolution: Box Persistence Makes the Bridge Work

Looking more carefully at `shifted_truth_lemma` in `Representation.lean`, the box case uses `box_persistent`:

```lean
theorem box_persistent (fam : FMCS Int) (phi : Formula) (t s : Int)
    (h_box : Box phi in fam.mcs t) : Box phi in fam.mcs s
```

This theorem says Box(phi) membership is TIME-INDEPENDENT in any FMCS. The proof uses the TF axiom (`Box phi -> G(Box phi)`) and its past analog.

This means: for the box case of the shifted truth lemma, we don't actually need temporal coherence of the witness families. We only need:
1. `Box(phi) in fam.mcs t` (given)
2. By `box_persistent`: `Box(phi) in fam.mcs (t + delta)` for any delta
3. By `modal_forward`: `phi in fam'.mcs (t + delta)` for all fam' in families
4. The IH then needs `phi in fam'.mcs (t + delta) <-> truth_at ... fam' (t + delta) phi`

Step 4 requires the IH for ALL families. For constant families, the atom/bot/imp cases work without temporal coherence. The temporal cases (G, H) of the IH for constant families DO need forward_F/backward_P of those constant families.

**But wait**: for constant families, G(phi) in mcs implies phi in mcs (by T-axiom, since the MCS is the same at all times). And the backward direction: if phi is true at all future times, then phi is in the MCS (since the MCS is the same at all times, and phi is true at time t, which means phi is in mcs by IH). Actually, for a constant family where `mcs s = M` for all s:
- Forward G: `G(phi) in M -> phi in M` (T-axiom)
- Backward G: `(forall s >= t, truth_at ... s phi) -> G(phi) in M`
  - By IH at s = t: `truth_at ... t phi -> phi in M`
  - Need: `phi in M -> G(phi) in M`. This requires: if phi in M then G(phi) in M.
  - But this is NOT generally true! G(phi) means phi at ALL future times. Just because phi is in a single MCS doesn't mean G(phi) is in that MCS.

Actually, wait. For a constant family with `mcs s = M` for all s, the forward direction `G(phi) in M` implies `phi in M` (T-axiom), which means `phi in mcs(s)` for all s. The backward direction: if `phi in mcs(s)` for all s >= t, then `phi in M` (since mcs(s) = M). So we need `phi in M -> G(phi) in M`. This is exactly the T-axiom direction: G(phi) -> phi is derivable, but phi -> G(phi) is NOT derivable in general.

So the backward temporal case for constant families STILL needs forward_F. For constant families, forward_F says: `F(psi) in M -> exists s >= t, psi in M`. Since mcs is constant, this is just `F(psi) in M -> psi in M`, which is temporal saturation of M. And temporal saturation of a single MCS is not generally achievable.

### 5.6 Resolution via Weakened Truth Lemma

The truth lemma for constant families over Int can be weakened to NOT require the G/H backward directions. Specifically:

For the REPRESENTATION theorem, we only need the FORWARD direction of the truth lemma for the eval family:
```
phi in eval_family.mcs 0 -> truth_at M Omega tau 0 phi
```

For the COMPLETENESS theorem (contrapositive), we need:
```
valid phi -> derivable phi
```

By contraposition: `not derivable phi -> not valid phi`. We need to find a model where phi is FALSE. We construct the BFMCS and show phi.neg is TRUE. For this, we only need the forward direction of the truth lemma at the eval family.

**The forward direction does NOT require forward_F or backward_P.** Let's verify case by case:

- `phi in fam.mcs t -> truth_at ...`:
  - atom: trivial
  - bot: contradiction with MCS consistency
  - imp: `(psi -> chi) in M, psi true -> chi true`. Uses BOTH directions of IH on psi (need backward psi). **PROBLEM**: the imp case forward uses backward on the antecedent.

This is the well-known cross-dependency in truth lemmas. The imp forward case needs: if `truth_at ... psi` then `psi in mcs`. This is the backward direction. So we cannot separate forward and backward.

---

## 6. Concrete Recommendation

### 6.1 The Existing Chain B IS the Right Path

The existing `Representation.lean` chain is the correct architecture for standard completeness. It:
1. Uses `D = Int` (correct LinearOrderedAddCommGroup)
2. Constructs canonical TaskFrame/TaskModel/WorldHistory over Int
3. Proves `shifted_truth_lemma` connecting MCS membership to standard `truth_at`
4. Proves `standard_weak_completeness` and `standard_strong_completeness`
5. Has exactly 1 sorry (from `fully_saturated_bfmcs_exists_int`)

### 6.2 What the Sorry Actually Requires

The sorry in `fully_saturated_bfmcs_exists_int` needs:
- A BFMCS over Int with temporally coherent eval family (forward_F, backward_P)
- Plus modally saturated (constant witness families)
- Plus constant witness families that are temporally coherent

The constant-family temporal coherence IS the hard part. From the analysis in Section 5.5, constant families need temporal saturation (F(psi) in M -> psi in M), which is impossible for a generic MCS.

### 6.3 The Parametric D Strategy: Not a New Path, But a Sorry Elimination

The "parametric D strategy" is NOT about finding a new D type. It IS about eliminating the sorry in the existing Int-based chain. The approaches are:

**Approach 1: Modify the truth lemma to only require eval-family temporal coherence**

This is what `bmcs_truth_lemma_mcs` does, but for BFMCS truth, not standard truth. For standard `truth_at`, we'd need a variant of `shifted_truth_lemma` that relaxes temporal coherence. As analyzed in 5.5-5.6, this is blocked by the imp-case cross-dependency.

**Approach 2: Make constant witness families temporally coherent**

This requires temporally saturated MCSes, which is impossible in general. BLOCKED.

**Approach 3: Use non-constant witness families that ARE temporally coherent**

Instead of constant witness families, for each Diamond(psi) in fam.mcs t, construct a NON-CONSTANT witness family (a separate DovetailingChain starting from the witness MCS). This makes every family a genuine DovetailingChain, which can (in principle) satisfy forward_F and backward_P.

The challenge: this multiplies the number of DovetailingChains, and each chain's forward_F/backward_P is still sorry'd.

**Approach 4: Remove bmcs_valid_mcs entirely and prove valid -> derivable directly**

Use the `bmcs_truth_lemma_mcs` approach (Box = MCS membership) combined with a NEW truth lemma that connects `bmcs_truth_at_mcs` directly to `truth_at` WITHOUT requiring temporal coherence of non-eval families.

This would require proving: for a specific BFMCS B and its canonical model,
```
bmcs_truth_at_mcs B eval_family t phi <-> truth_at (canonicalModel B) (shiftClosedCanonicalOmega B) tau t phi
```

The box cases differ:
- LHS: `forall fam' in B.families, phi in fam'.mcs t`
- RHS: `forall sigma in shiftClosedCanonicalOmega B, truth_at ... sigma t phi`

Forward (LHS -> RHS): Given phi in fam'.mcs t for all fam', and sigma in shiftClosedCanonicalOmega (= time_shift of canonicalHistory fam' for some fam'), we need truth_at ... sigma t phi. This requires the truth lemma for shifted histories of individual families, which needs temporal coherence of each family. BLOCKED for constant families.

**Approach 5: Accept the sorry and document it as the standard approach**

The 1 sorry in `fully_saturated_bfmcs_exists_int` is a well-known open problem in the implementation. The standard completeness chain (`valid -> derivable`) is structurally correct and would become sorry-free once this theorem is proven.

### 6.4 The Most Promising Path: Approach 4 with a Restricted Omega

Define a restricted Omega that only contains canonical histories of the eval family (not witness families). Then box quantifies only over the eval family's history at different time-shifts, which DOES have temporal coherence.

```lean
def evalOnlyOmega (B : BFMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
  { sigma | exists (delta : Int), sigma = time_shift (canonicalHistory B B.eval_family ...) delta }
```

But this breaks modal saturation: Box(phi) in the standard semantics would mean "phi at all time-shifts of the eval history," which is a TEMPORAL property, not a modal one. This conflates modal and temporal operators.

### 6.5 Concrete Recommendation

**Short-term (no new sorry)**: Use Chain A's `bmcs_weak_completeness_mcs` as the primary completeness result. It IS a genuine completeness theorem (valid wrt bmcs_valid_mcs -> derivable), sorry-free, and axiom-free. Combined with soundness (`derivable -> valid`), this gives:

```
derivable phi -> valid phi -> bmcs_valid_mcs phi -> derivable phi
```

The first implication is soundness (proven). The third is completeness (proven). The second needs to be proven: every standard-valid formula is bmcs_valid_mcs.

**Is `valid phi -> bmcs_valid_mcs phi` true?** This asks: if phi is true in ALL standard models (with LinearOrderedAddCommGroup D, TaskFrame, etc.), is it true in all BFMCS models with bmcs_truth_at_mcs?

Actually NO -- the direction is wrong. What we need for completeness is: `valid phi -> derivable phi`. We have `bmcs_valid_mcs phi -> derivable phi`. So we need `valid phi -> bmcs_valid_mcs phi`. But bmcs_valid_mcs quantifies over BFMCS models, which are NOT standard models, so there's no direct implication.

The correct approach is contrapositive: `not derivable phi -> not valid phi`. This requires constructing a standard model where phi fails. The existing `Representation.lean` does exactly this, but with the sorry.

**Long-term**: Eliminate the sorry in `fully_saturated_bfmcs_exists_int` by proving that the DovetailingChain construction can be extended to satisfy forward_F and backward_P.

---

## 7. Summary of Findings

| Question | Answer |
|----------|--------|
| Current D parameterization | BFMCS/FMCS parameterized by `{D : Type*} [Preorder D]`; standard validity requires `LinearOrderedAddCommGroup D` |
| Standard validity requirements | `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D` + `ShiftClosed Omega` |
| What blocks direct use of Int | The 1 sorry in `fully_saturated_bfmcs_exists_int` (temporal coherence + modal saturation simultaneously) |
| The eval family problem | NOT actually a problem: the Representation.lean chain already handles `D = Int` correctly |
| DovetailingChain status | 2 sorries (forward_F, backward_P); these propagate to the only sorry in the standard completeness chain |
| Can we weaken requirements | The truth lemma's imp case creates cross-dependencies that prevent separating forward/backward |
| Alternative D choices | Int is the correct and only necessary choice; the architecture already uses it |
| Concrete path | The architecture IS the concrete path. The blocker is the 2 DovetailingChain sorries (forward_F/backward_P) |

### Key Insight

The "parametric D strategy" is a red herring. The correct architecture (Representation.lean with D = Int) ALREADY EXISTS and ALREADY PROVES standard completeness modulo one sorry. The sorry is not about choosing D -- it's about constructing temporally coherent families over Int that also support modal saturation. Chain A (ChainBundleBFMCS) avoids this by using a non-standard truth predicate, but this cannot directly bridge to standard `valid` because the imp-case cross-dependency prevents separating the truth lemma into a forward-only version.

The remaining work is to either:
1. Prove `fully_saturated_bfmcs_exists_int` by resolving the 2 DovetailingChain sorries, OR
2. Find a fundamentally new construction (e.g., omega-squared chain) that achieves temporal coherence with F/P witnesses

Both paths require significant technical work but are NOT blocked by the choice of D.
