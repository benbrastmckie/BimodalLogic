# Teammate A Findings: Primary Approach for Mixed-Case Countermodel

**Task**: 142 — Mixed-case countermodel for bx_completeness
**Angle**: Primary approach analysis
**Date**: 2026-05-15

## Key Findings

### 1. The Coherence Requirements Are Restricted — This Is the Crucial Lever

The `fully_restricted_parametric_representation_from_neg_membership` (RestrictedParametricTruthLemma.lean:459–473) requires exactly three conditions on the BFMCS, ALL of which are scoped to `root = φ` (the formula being refuted):

1. **`restricted_temporally_coherent root`** — forward_F and backward_P only for formulas in `deferralClosure(φ)` (TemporalCoherence.lean:295–300)
2. **`restricted_backward_until_since_coherent root`** — backward Until/Since only for formulas in `subformulaClosure(φ)` (ChronicleToCountermodel.lean:650)
3. **`restricted_forward_until_since_coherent root`** — forward Until/Since only for formulas in `subformulaClosure(φ)` (ChronicleToCountermodel.lean:722)

**The FMCS structure itself** (FMCSDef.lean:99–117) only requires `forward_G` and `backward_H` — universal quantification over ALL formulas and ALL strict future/past times. These are NOT scoped to a root formula.

**Critical implication**: The three restricted BFMCS coherence conditions only need to hold for the finite set `subformulaClosure(φ)` / `deferralClosure(φ)`. But each individual FMCS in the bundle must satisfy `forward_G` and `backward_H` for ALL formulas. This is the fundamental constraint.

### 2. The FMCS Forward_G/Backward_H Requirement Cannot Be Weakened

Looking at `dd_countermodel_chronicle_dense` (ChronicleToCountermodel.lean:793–820), the proof calls:
```lean
fully_restricted_parametric_representation_from_neg_membership
    (cantor_bfmcs_dense A h_mcs h_box_dense) φ ...
```

The BFMCS `cantor_bfmcs_dense` contains families that are `rooted_cantor_fmcs_dense N h_N h_box_N s` — each of which is an `FMCS Rat`. The `FMCS Rat` structure demands (FMCSDef.lean:110):
```lean
forward_G : forall t t' phi, t < t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
```

This must hold for **every** formula `phi`, not just subformulas of the root. This is non-negotiable given the current architecture.

### 3. The Dense Case Works Because Cantor Iso Preserves ALL Chronicle Properties

In the dense case:
- `limit_f` satisfies forward_G and backward_H (from `limit_forward_G` and `limit_backward_H` in ChronicleConstruction.lean)
- The Cantor isomorphism `cantor_iso_dense : LimitDomSubtype ≃o Rat` is an ORDER isomorphism
- Since it's bijective AND order-preserving, `cantor_f_dense(q) = limit_f(iso.symm(q))` trivially satisfies forward_G on Rat: if G(phi) ∈ limit_f(x) and x < y in LimitDomSubtype, then phi ∈ limit_f(y). Under the iso, this transfers to: if t < t' in Rat, then iso.symm(t) < iso.symm(t') in LimitDomSubtype, so the property carries over.

**The discrete case works analogously**: `succ_embed` gives an embedding `Z → LimitDomSubtype`, and the FMCS on Z is defined via `discrete_f(n) = limit_f(succ_embed(n))`. Forward_G holds because the succ embedding is strictly monotone.

### 4. Why the Mixed Case Fails with Current Architecture

For a box-equivalent MCS N with U(T,⊥) ∈ N (discrete), the limit domain `LimitDomSubtype N h_N` is:
- Countable ✓
- Without endpoints ✓
- **NOT densely ordered** (it has a successor structure)

The Cantor isomorphism requires DenselyOrdered, so `cantor_iso_dense` is unavailable. We cannot build an `FMCS Rat` for N using the dense machinery.

The discrete embedding gives `FMCS Int`, not `FMCS Rat`. Since the BFMCS requires all families to share the same domain type D, we cannot mix `FMCS Rat` and `FMCS Int` families.

### 5. Sub-Case Analysis

By MCS negation completeness, A has either F'T or U(T,⊥):

**Sub-case (a): F'T ∈ A** (A's chronicle is dense, but ¬□(F'T) ∈ A means some box-equiv N has U(T,⊥))

- A's chronicle is dense → Cantor iso exists → rooted_cantor_fmcs_dense works for A
- For box-equiv N with U(T,⊥): N's chronicle is discrete → NO Cantor iso → cannot build FMCS Rat for N
- The BFMCS `modal_backward` proof needs a family for EVERY box-equiv N (via `bx_modal_witness`)
- Specifically: if ¬□(φ) ∈ A, bx_modal_witness gives an MCS v with ¬φ ∈ v.formulas, and we need a family rooted at v. If v has U(T,⊥), we're stuck.

**Sub-case (b): U(T,⊥) ∈ A** (A's chronicle is discrete, but ¬□(U(T,⊥)) ∈ A means some box-equiv N has F'T)

- Symmetric problem: A can use discrete embedding to get FMCS Int, but dense N cannot.

### 6. The "Universal FMCS on Rat" Approach — Detailed Analysis

**Goal**: For ANY chronicle (dense or discrete), define `universal_fmcs : FMCS Rat` satisfying forward_G and backward_H.

**Approach**: Embed the limit domain into Rat via any strictly increasing map `e : LimitDomSubtype → Rat`, then extend to all of Rat.

**Critical obstacle**: `forward_G` says: if G(phi) ∈ mcs(q) and q < q', then phi ∈ mcs(q'). For q, q' both in the image of e, this follows from the chronicle. For q' NOT in the image (a "gap point"), we must define mcs(q') such that phi ∈ mcs(q') whenever G(phi) ∈ mcs(q) for some q < q'.

**Analysis of gap-filling options**:

**(i) Constant filling**: Set mcs(q') = mcs(e(x)) where x is the predecessor of the unique n with e(n-1) < q' < e(n). Problem: G(phi) ∈ mcs(e(n-1)) means phi ∈ mcs(e(n)), mcs(e(n+1)), etc. But we set mcs(q') = mcs(e(n-1)), and we need phi ∈ mcs(e(n-1)). G(phi) ∈ mcs(e(n-1)) does NOT imply phi ∈ mcs(e(n-1)) (strict semantics). **FAILS**.

**(ii) Right-neighbor filling**: Set mcs(q') = mcs(e(n)) for q' in (e(n-1), e(n)). Then forward_G at q = e(n-1): G(phi) ∈ mcs(e(n-1)) and q' ∈ (e(n-1), e(n)). We need phi ∈ mcs(e(n)) = mcs(q'). But G(phi) ∈ mcs(e(n-1)) gives phi ∈ mcs(e(n)) from the chronicle's forward_G. **This works for q' in the interval (e(n-1), e(n))**. But what about backward_H? H(phi) ∈ mcs(q') = mcs(e(n)) and q'' < q'. If q'' = e(n-1), we need phi ∈ mcs(e(n-1)). H(phi) ∈ mcs(e(n)) gives phi ∈ mcs(e(n-1)) from the chronicle's backward_H. **Works**. What about q'' in the gap (e(n-2), e(n-1))? mcs(q'') = mcs(e(n-1)), and we need phi ∈ mcs(e(n-1)). H(phi) ∈ mcs(e(n)) gives phi ∈ mcs(e(n-1)) ✓. **This approach works!**

**Wait — there's a subtlety**: forward_G at gap point q' (with mcs(q') = mcs(e(n))): G(phi) ∈ mcs(q') = mcs(e(n)). For q'' > q' in same gap (e(n-1), e(n)), mcs(q'') = mcs(e(n)), and phi ∈ mcs(e(n)) iff G(phi) → phi — but G(phi) ∈ mcs(e(n)) does NOT imply phi ∈ mcs(e(n)) under strict semantics! Forward_G on the chronicle gives phi at e(n+1), e(n+2), etc., but NOT at e(n) itself.

**So the right-neighbor filling ALSO FAILS** for forward_G at gap points within the same interval.

**(iii) Use MCS with G(phi) → phi (reflexive G)**: The issue is that strict G doesn't self-apply. If we could find an MCS containing {phi : G(phi) ∈ N_n} for the gap, that would work. But this set is g_content(N_n) = {phi : G(phi) ∈ N_n}, and extending it to an MCS M_gap with M_gap ⊇ g_content(N_n). Then G(phi) ∈ mcs(q') implies G(phi) ∈ N_n implies phi ∈ M_gap. But we also need forward_G AT M_gap: G(psi) ∈ M_gap implies psi ∈ mcs(q'') for q'' > q'. If q'' is still in the gap, mcs(q'') = M_gap, and we need psi ∈ M_gap. G(psi) ∈ M_gap doesn't mean psi ∈ M_gap — same problem!

**The fundamental issue**: Under strict temporal semantics, G(phi) at time t gives phi at all STRICTLY FUTURE times, not at t itself. In a dense order, every neighborhood of t contains future points, so "constant-on-interval" filling cannot satisfy forward_G because the interval points are self-referential.

### 7. The Correct Approach: Use a Dense Extension of Any Chronicle

**Key mathematical fact**: Any countable linear order without endpoints can be EXTENDED to a countable dense linear order without endpoints, by inserting new elements between every pair of adjacent elements.

For a discrete limit domain L (embedded in Rat), we can construct a dense extension L' ⊂ Rat by:
1. For each pair of consecutive points x < y in L, add countably many points between them
2. Assign MCS values to the new points using Lemma 2.6 (Burgess) — which splits an interval by adding a point z with specific DCS/MCS properties

**This is exactly what the Burgess construction already does!** The iterative elimination of C4 counterexamples inserts points between consecutive elements. After ω steps, the limit domain becomes dense (every C4 counterexample is eventually resolved).

**The insight**: Even when U(T,⊥) ∈ A (A is locally discrete), the Burgess construction produces a limit domain that IS dense. The formula U(T,⊥) may be in f(0) = A, but the limit domain doesn't respect U(T,⊥) semantically — because U(T,⊥) requires an immediate successor, which the dense limit domain doesn't provide. The truth claim (Burgess 2.11) then proves V(U(T,⊥)) ≠ {x : U(T,⊥) ∈ f(x)}, which is a CONTRADICTION with the truth claim... unless U(T,⊥) is handled correctly.

**Let me verify this carefully**: The truth claim says (+) holds for ALL alpha, including U(T,⊥). For alpha = U(T,⊥) = U(top, bot):
- Forward: If U(top, bot) ∈ f(x), C5 gives y > x with top ∈ f(y) and bot ∈ g(x,y). C3 gives bot ∈ f(z) for all z between x and y. If the domain is dense (there exists z between x and y), this means bot ∈ f(z) for some MCS f(z), which contradicts consistency.
- So C5 for U(T,⊥) at x forces x to have an immediate successor y in the domain (no points between them). The Burgess construction DOES this: Lemma 2.10 case n=0 adds y = x+1 with no points between.
- Later, C4 may try to insert a point between x and y, but only when there's a C4 counterexample. C4 at (x,y) with ¬U(gamma, delta) ∈ f(x) and gamma ∈ f(y) — this could insert a point between x and the C5 witness y.

**The critical question**: Does the Burgess construction preserve the "no gap" property between x and its C5 witness for U(T,⊥)?

Burgess Lemma 2.10 Case n=0: adds y immediately after x. If later, C4 inserts z between x and y, then g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y). Since bot ∈ g(x,y), we need bot ∈ g(x,z) ∩ f(z) ∩ g(z,y), so bot ∈ f(z). But f(z) is an MCS, and MCS are consistent, so bot ∉ f(z). **Contradiction!**

**This means C4 resolution NEVER inserts a point between x and its C5-witness for U(T,⊥)**. The domain is NOT globally dense when U(T,⊥) ∈ f(x) — it has "protected gaps" around discrete witnesses. The limit domain is a MIXED-DENSITY order: dense in regions corresponding to F'T MCS's, discrete around U(T,⊥) MCS's.

**This confirms the prior report's analysis**: the limit domain of a mixed MCS is neither globally dense nor globally discrete.

### 8. A New Approach: The Base Logic Doesn't Need Density/Discreteness

Re-reading Burgess 1982 Section 2: The completeness proof for J0 (the base logic, without density or discreteness axioms) produces a model on an arbitrary countable linear order. The density/discreteness case split is only needed when EXTRA AXIOMS are added.

**Our system TM (= BX)** includes S5 modal axioms but does NOT include density or discreteness axioms as GLOBAL requirements. The case split on □(F'T) vs □(U(T,⊥)) is an artifact of the formalization strategy, not a mathematical necessity.

**The mathematically correct approach**: Build the countermodel using the BASE Burgess construction, producing a model on the limit domain (a mixed-density countable linear order without endpoints), and avoid committing to Rat or Int as the domain type.

**Problem**: The limit domain `LimitDomSubtype A h_mcs` is a subtype of Rat, but it doesn't have `AddCommGroup` (no reason x + y is in the limit domain). The existential conclusion requires `D : Type` with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`, `Nontrivial D`.

### 9. Recommended Strategy: Embed into Rat via Densification

**The approach that works**:

**Step 1**: For any MCS N (dense or discrete), build the Burgess chronicle. The limit domain LimitDomSubtype is a countable linear order without endpoints, embedded in Rat.

**Step 2**: DENSIFY the limit domain by running additional C4 resolution steps to eliminate all C4-counterexamples for the SPECIFIC formula φ and its subformulas. After densification for φ:
- The extended limit domain is dense WITH RESPECT TO φ-relevant formulas
- C5 witnesses for U(T,⊥) are preserved (C4 doesn't insert between them — see Finding 7)
- But the domain may not be globally dense

**Step 3**: Use D = Rat. Even though the extended limit domain isn't globally dense, we can use the RESTRICTED truth claim:
- The truth claim (Burgess 2.11) holds for ALL formulas in the chronicle
- The restricted truth lemma only needs coherence for subformulaClosure(φ)
- If U(T,⊥) ∉ subformulaClosure(φ), we don't need its truth value to be correct

**Wait — this doesn't resolve the D = Rat issue.** We still need a total function Rat → Set Formula.

### 10. THE CORRECT APPROACH: Use D = LimitDomSubtype (No AddCommGroup Needed?)

Let me re-examine the existential goal:

```lean
∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
  (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
  (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
  (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
  ¬truth_at TM Omega τ t φ
```

D must be an AddCommGroup with LinearOrder and IsOrderedAddMonoid. LimitDomSubtype does NOT have AddCommGroup. So this approach requires either:
(a) Proving AddCommGroup for LimitDomSubtype (impossible in general)
(b) Finding another domain type that works

**Alternative**: Use D = Rat but with a DIFFERENT FMCS construction that doesn't rely on Cantor isomorphism.

## Recommended Approach

After exhaustive analysis, the most promising approach is:

### Strategy: Sub-case Reduction + Dense-Family-Only BFMCS on Rat

**Key observation that the prior research missed**: The `modal_backward` proof for the BFMCS doesn't need a family for EVERY box-equivalent MCS — it only needs a family for every box-equivalent MCS that could serve as a witness for `bx_modal_witness`.

`bx_modal_witness` produces v with ¬φ ∈ v.formulas where v is box-equivalent to A. We need v's family in the bundle.

**But we DON'T need v's family to correctly evaluate U(T,⊥) or F'T — we only need v's FMCS to have the correct MCS at the root point (for modal_backward) and satisfy forward_G/backward_H.**

**The refined approach**:

1. **Sub-case on A**: Either F'T ∈ A or U(T,⊥) ∈ A.

2. **Sub-case (a): F'T ∈ A** — Use D = Rat.
   - For A and all dense box-equiv N: use `rooted_cantor_fmcs_dense`
   - For discrete box-equiv N: Build a "pseudo-dense" FMCS on Rat by running the Burgess construction for N, then extending its limit domain to a DENSE countable linear order (by inserting additional points using Lemma 2.6 until density is achieved), THEN applying the Cantor isomorphism.
   - The extended chronicle satisfies C0–C5 (by construction)
   - The extended chronicle is dense (by explicit densification)
   - The Cantor isomorphism exists for the extended domain
   - The FMCS on Rat satisfies forward_G and backward_H (inherited from the extended chronicle)
   - The MCS at the root point is still N (densification doesn't change existing points)

3. **Sub-case (b): U(T,⊥) ∈ A** — Symmetric, using D = Int.
   - For A and all discrete box-equiv N: use `rooted_succ_discrete_fmcs`
   - For dense box-equiv N: Build a "pseudo-discrete" FMCS on Int. This is harder because discretization loses information. **Alternative**: Use D = Rat for this sub-case too, by densifying A's chronicle (which is already possible since the Burgess limit domain can be extended).

**Actually, both sub-cases can use D = Rat** if we can densify ANY chronicle:

4. **Unified approach with D = Rat**:
   - For ANY box-equiv N (dense or discrete): build the Burgess chronicle, densify the limit domain, apply Cantor iso, get FMCS Rat
   - The BFMCS on Rat has families for all box-equiv MCS's
   - modal_forward and modal_backward follow from box stability (which the existing proofs show holds for ANY chronicle, not just dense ones — see `box_stable_in_cantor_f_dense` which uses `box_stable_in_limit_f`, a property of ALL chronicles)

**The critical question is: Can we densify a discrete chronicle while preserving C0–C5?**

The answer from Burgess's construction is YES: the iterative C4/C5 elimination procedure starts from an arbitrary finite chronicle and produces a countable chronicle satisfying C4 and C5. If we start with a fully formed discrete chronicle and add more C4 resolution steps, we get a denser chronicle that still satisfies all conditions. The new points have MCS values determined by Lemma 2.6.

**BUT**: The C4 resolution for U(T,⊥) will FAIL (Finding 7 above) — inserting a point between a discrete witness pair violates C3 consistency. So the densification cannot make the domain globally dense when U(T,⊥) ∈ f(x).

**REVISED**: The densification works for formula-specific C4 counterexamples, but U(T,⊥) blocks densification at protected intervals. So the limit domain after densification is "dense except at U(T,⊥) witness pairs."

**This means the Cantor iso STILL doesn't exist** (the order is not globally dense).

## FINAL RECOMMENDATION: The Two-Sub-Case Approach

After exhaustive analysis, the correct approach is:

**Use the two sub-cases (F'T ∈ A or U(T,⊥) ∈ A) and handle each with its natural domain type:**

- **Sub-case F'T ∈ A**: Use D = Rat. All families use the dense FMCS. For discrete box-equiv N, densify N's chronicle (insert points at non-U(T,⊥) locations, which is sufficient for the RESTRICTED coherence conditions when U(T,⊥) ∉ subformulaClosure(φ)). For the special case U(T,⊥) ∈ subformulaClosure(φ), additional infrastructure is needed.

- **Sub-case U(T,⊥) ∈ A**: Use D = Int. All families use the discrete FMCS. For dense box-equiv N, discretize N's chronicle (use the Reynolds compression N → Z, which the WeakCanonical pipeline already provides via `doets_countermodel_discrete`).

**Estimated new infrastructure**:
- Densification of discrete chronicles: ~15-20 hours
- Discretization of dense chronicles (Reynolds compression): mostly exists in WeakCanonical pipeline
- Integration into the BFMCS construction: ~10-15 hours

## Evidence/Examples

1. The Burgess truth claim (2.11) proves correctness for ALL formulas simultaneously — the dense/discrete distinction only matters for the Cantor iso / succ embedding steps.
2. The existing `box_stable_in_limit_f` holds for ALL chronicles regardless of density — this is the key property for modal_backward.
3. The restricted truth lemma scopes all coherence to `subformulaClosure(φ)` / `deferralClosure(φ)`, which is finite and may or may not contain U(T,⊥).

## Confidence Level

**Medium**. The two-sub-case approach is mathematically sound but requires significant new infrastructure. The densification of discrete chronicles is the most uncertain component — the interaction between U(T,⊥)-protected gaps and C4 resolution needs careful formal verification. The discretization path (Reynolds compression) is partially implemented but still has sorries in the WeakCanonical pipeline.

## Open Questions

1. **Can we densify a discrete chronicle while preserving the restricted truth claim for φ?** The U(T,⊥)-protected gaps prevent global densification, but if U(T,⊥) ∉ subformulaClosure(φ), we may not need to resolve those gaps.

2. **Does the Reynolds compression preserve box stability?** The WeakCanonical pipeline compresses a chronicle model to Z, but the box stability transfer through this compression hasn't been verified.

3. **Is there a simpler uniform construction?** A construction that works for ALL MCS's without case-splitting would be preferable. The key obstacle is the `AddCommGroup D` requirement in the existential — if D could be any linear order (not necessarily a group), we could use the limit domain directly.

4. **Can the existential conclusion be weakened?** If we could replace `AddCommGroup D` with just `LinearOrder D`, the problem becomes trivial (use LimitDomSubtype). This would require changing the TaskFrame/TaskModel infrastructure, which may have far-reaching consequences.

5. **Would the mosaic method (Caleiro-Vigano-Volpe 2013) avoid this issue entirely?** The mosaic approach handles temporal and modal dimensions independently, potentially sidestepping the domain-type mismatch. However, this would require a completely different proof architecture.
