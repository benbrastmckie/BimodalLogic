# Teammate A Findings: Restricted Forward Until via Deferral Closure

**Task**: #85 - Research Until/Since chain coherence approaches
**Direction**: Restricted forward Until via deferral closure + novel approaches
**Date**: 2026-04-08

---

## Key Findings

### Finding 1: The truth lemma only invokes forward_until_since_coherent on subformulas of root

**Confidence**: HIGH

**Evidence**: In `CanonicalConstruction.lean:981-989`, the restricted shifted truth lemma's Until case:

```lean
| untl phi psi ih_phi ih_psi =>
    have h_phi_sub : phi ∈ subformulaClosure root := closure_untl_left root phi psi h_sub
    have h_psi_sub : psi ∈ subformulaClosure root := closure_untl_right root phi psi h_sub
    simp only [truth_at]
    obtain ⟨h_fwd_U, _⟩ := h_fuc fam hfam
    ...
    · intro h_U
      obtain ⟨s, h_ts, h_psi_s, h_phi_guard⟩ := h_fwd_U t phi psi h_U
```

The phi and psi in the Until case are always subformulas of root (lines 982-983). The forward Until coherence `h_fwd_U` is called as `h_fwd_U t phi psi h_U` where both `phi` and `psi` are in `subformulaClosure root`.

**Implication**: A `restricted_forward_until_since_coherent root` quantifying only over formulas in `subformulaClosure root` (or `deferralClosure root`) would suffice for the truth lemma. The current code uses the FULL `B.forward_until_since_coherent` (TemporalCoherence.lean:518-525), which quantifies over ALL formulas -- this is strictly stronger than needed.

### Finding 2: The restricted chain's forward_F has a sorry at fuel=0 that is mathematically unsound

**Confidence**: HIGH

**Evidence**: `SuccChainFMCS.lean:3029-3042`:

```lean
private theorem restricted_forward_bounded_witness_fueled ...
  match fuel with
  | 0 =>
    match d with
    | 0 => exact absurd h_d_ge (by omega : ¬0 ≥ 1)
    | _ + 1 =>
      -- Semantically unreachable case - fuel exhausted but witness must exist
      exact ⟨k + 1, by omega, by sorry⟩
```

The comment at lines 2887-2893 explicitly states: "The fuel-based termination argument is mathematically unsound because the F-nesting boundary d can grow at each recursive step (from d to up to B + d - 1 where B = closure_F_bound)."

Furthermore, `restricted_forward_chain_forward_F` (line 3128) calls into this sorry. So while the restricted chain has the RIGHT structure for F-resolution, the proof is incomplete.

**Critical distinction**: The restricted chain operates on `DeferralRestrictedMCS` (not full MCS), which means F-nesting is bounded. The sorry is NOT about mathematical impossibility -- it's about the termination argument for the fuel-based recursion not correctly accounting for the growth of d at recursive steps.

### Finding 3: BX10 gives (phi U psi) -> F(psi), enabling a REDUCTION strategy

**Confidence**: HIGH

**Evidence**: BX10 axiom (Axioms.lean:224): `(phi U psi) -> F(psi)`.
Derived theorem (TemporalDerived.lean:224): `until_implies_some_future phi psi`.

This means: if `(phi U psi) in fam.mcs t`, then `F(psi) in fam.mcs t`. If we have restricted forward_F for psi (which is in `subformulaClosure root` hence in `deferralClosure root`), we get `exists s > t, psi in fam.mcs s`.

But forward_until_since_coherent needs MORE than just the witness for psi -- it needs the GUARD: `forall r, t <= r -> r < s -> phi in fam.mcs r`. BX10 gives us the witness but NOT the guard.

**However**: BX5 (self-accumulation) gives `(phi U psi) -> ((phi AND (phi U psi)) U psi)`. This tells us that at every intermediate point in the guard, BOTH phi and (phi U psi) hold. The key insight is that the Until formula itself propagates along the guard.

### Finding 4: The full MCS chain (SuccChainFMCS) has `succ_chain_restricted_forward_F` as a sorry

**Confidence**: HIGH

**Evidence**: `UltrafilterChain.lean:3931-3936`:

```lean
theorem succ_chain_restricted_forward_F (S : SerialMCS) (root : Formula)
    (n : Int) (psi : Formula)
    (h_dc : psi ∈ deferralClosure root)
    (h_F : Formula.some_future psi ∈ succ_chain_fam S n) :
    ∃ m : Int, n < m ∧ psi ∈ succ_chain_fam S m := by
  sorry
```

This is the full MCS chain's sorry for restricted forward F. Note it takes `psi in deferralClosure root` as a hypothesis. For the restricted chain path, the DeferralRestrictedMCS approach bounds F-nesting. For the full MCS chain, F-nesting is NOT bounded (comment at line 3922-3924), so a different approach is needed.

### Finding 5: deferralClosure does NOT contain Until/Since deferral sets

**Confidence**: HIGH

**Evidence**: `SubformulaClosure.lean:806-814`:

```lean
def baseDeferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas

def deferralClosure (phi : Formula) : Finset Formula :=
  baseDeferralClosure phi

def extendedDeferralClosure (phi : Formula) : Finset Formula :=
  baseDeferralClosure phi ∪ untilDeferralSet phi ∪ sinceDeferralSet phi
```

The `deferralClosure` is the base version WITHOUT Until/Since deferral sets. The `extendedDeferralClosure` adds them. The `untilDeferralSet` adds `psi ∨ (phi ∧ (phi U psi))` for each Until subformula. The `sinceDeferralSet` adds the analogous Since disjunctions.

**Implication**: The Until/Since deferral disjunctions from BX5 (self-accumulation: `(phi U psi) -> psi ∨ (phi ∧ (phi U psi))` at each step) are NOT in `deferralClosure` but ARE in `extendedDeferralClosure`. This matters for whether a restricted chain approach can track Until obligations.

### Finding 6: The truth semantics uses REFLEXIVE Until (t <= s, not t < s)

**Confidence**: HIGH

**Evidence**: `Truth.lean:128-129`:

```lean
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
```

The witness satisfies `t <= s` (reflexive), with guard `t <= r -> r < s -> phi(r)`. When s = t, the guard is vacuously true and psi(t) suffices.

**Contrast with forward_until_since_coherent** (TemporalCoherence.lean:518-525): same reflexive semantics `t <= s`.

**Implication**: The reflexive semantics means the base case (s = t) is trivially handled by backward_until_reflexive (`psi in M -> (phi U psi) in M`, already sorry-free). The difficulty is exclusively in the STRICT case where s > t.

### Finding 7: Backward Until/Since is parameterized by step transfer and has a clear sorry

**Confidence**: HIGH

**Evidence**: `UntilSinceCoherence.lean:111-114`:

```lean
theorem backward_until_from_step (fam : FMCS Int) (φ ψ : Formula)
    (h_step : ∀ r : Int, Formula.untl φ ψ ∈ fam.mcs (r + 1) →
      φ ∈ fam.mcs r → Formula.untl φ ψ ∈ fam.mcs r)
```

And in `Completeness.lean:386`:
```lean
· exact backward_until_coherent B
    (fun fam _hfam φ ψ r h_U_next _h_phi => sorry) fam hfam
```

The step transfer sorry: given `(phi U psi) in fam.mcs(r+1)` and `phi in fam.mcs(r)`, prove `(phi U psi) in fam.mcs(r)`. This requires pulling Until backwards one step. Under reflexive semantics, this should follow from `or_until_in_mcs` if we can get `psi ∨ (phi ∧ (phi U psi))` into `fam.mcs(r)`. Since `phi in fam.mcs(r)` and `(phi U psi) in fam.mcs(r+1)`, we need to get `(phi U psi)` from position r+1 to position r.

This is the same blocker as the forward direction: the Lindenbaum chain does not propagate Until formulas backwards through the Succ relation.

---

## Analysis: Can forward_until_since_coherent be restricted to deferralClosure?

### Step 1: What the truth lemma actually needs

The truth lemma's Until case (line 985-989) uses:
```
h_fwd_U t phi psi h_U
```
where `(phi U psi)` is in `subformulaClosure root`, hence `phi, psi in subformulaClosure root`.

A weakened definition would be:
```lean
def BFMCS.restricted_forward_until_since_coherent (B : BFMCS D) (root : Formula) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.untl φ ψ ∈ subformulaClosure root →
      Formula.untl φ ψ ∈ fam.mcs t →
      ∃ s : D, t ≤ s ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, t ≤ r → r < s → φ ∈ fam.mcs r) ∧
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.snce φ ψ ∈ subformulaClosure root →
      Formula.snce φ ψ ∈ fam.mcs t →
      ∃ s : D, s ≤ t ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, s < r → r ≤ t → φ ∈ fam.mcs r)
```

This would be sufficient for the restricted truth lemma. **However, this restriction does NOT help with the proof.** The difficulty is not that we're trying to handle too many formulas -- it's that we can't handle EVEN ONE Until formula through the chain.

### Step 2: Why the restricted chain's forward_F doesn't directly give forward Until

Even if we had sorry-free `restricted_forward_chain_forward_F` for the restricted chain, it gives:

```
F(psi) in chain(n) → exists m > n, psi in chain(m)
```

From `(phi U psi) in chain(n)`, by BX10, we get `F(psi) in chain(n)`, which gives us a witness `m > n` with `psi in chain(m)`. But we ALSO need the guard: `phi in chain(r)` for all `r in [n, m)`.

BX5 (self-accumulation) gives `(phi U psi) → ((phi ∧ (phi U psi)) U psi)`, so at each intermediate r, both phi(r) and (phi U psi)(r) hold. But this is the semantically true statement we're trying to PROVE -- we can't use it circularly.

### Step 3: The fundamental gap remains

The core issue is unchanged: the Lindenbaum extension step (going from one MCS to the next in the chain) does NOT preserve Until formulas. Specifically:

1. In the SuccChain: `g_content(M_n) ⊆ M_{n+1}` propagates G-formulas forward, but there's no mechanism to propagate Until formulas.
2. In the DovetailedChain: `until_unfold_in_mcs` gives `(phi U psi) → X(psi ∨ (phi ∧ (phi U psi)))`, meaning the Until obligation becomes an X-obligation (next step). Under reflexive semantics, X(alpha) = (bot U alpha), so `X(psi ∨ ...)` is `(bot U (psi ∨ ...))`, which by BX8 + BX9 is equivalent to `psi ∨ (phi ∧ (phi U psi))`. This is the reflexive collapse: `X = id` under BX8+BX9, so `until_unfold` becomes trivially `(phi U psi) → psi ∨ (phi ∧ (phi U psi))`, which is just BX5+BX9.

**The reflexive X = id collapse means the "unfolding" step gives us NO propagation mechanism.** In a non-reflexive system, `X(alpha)` would be in the seed for the next step, but in the reflexive system, X(alpha) = alpha, so we're back where we started.

---

## Novel Approach Analysis

### Approach A: Exploit the DovetailedChain's forward_F being sorry-free

**Observation**: The DovetailedFMCS has sorry-free forward_F (Completeness.lean:453 uses `DovetailedFMCS_forward_F` which is sorry-free). The dovetailed chain resolves F-obligations through fair scheduling.

**Idea**: Since `(phi U psi) → F(psi)` (BX10), and the dovetailed chain resolves F(psi) to get `psi at some s > t`, can we combine this with syntactic reasoning about Until to recover the guard?

**Sketch**:
1. From `(phi U psi) in fam.mcs(t)`, by BX10: `F(psi) in fam.mcs(t)`
2. By dovetailed forward_F: `psi in fam.mcs(s)` for some `s > t`
3. Need: `phi in fam.mcs(r)` for all `r in [t, s)`

For step 3: by BX5 (self-accumulation), `(phi U psi) → ((phi ∧ (phi U psi)) U psi)`. This means at t, we have `((phi ∧ (phi U psi)) U psi)`. Semantically, this means phi(t) holds. And (phi U psi)(t) holds, which by BX9 gives phi(t) ∨ psi(t).

But we cannot conclude phi(r) for r > t without knowing (phi U psi) persists to r. This is circular.

**Verdict**: Does not escape the circularity. We need (phi U psi) at intermediate points to conclude phi at those points, but we need phi at those points to conclude (phi U psi) propagates.

### Approach B: Two-phase truth lemma (prove restricted, then extend)

**Idea**: First prove the truth lemma for formulas WITHOUT Until/Since (modal + temporal G/H only), then extend to Until/Since using the restricted result.

**Problem**: The truth lemma is proved by structural induction on formulas. The Until case needs the IH for phi and psi (which are simpler formulas), but it also needs the forward_until_since_coherent hypothesis. The phase separation doesn't help because the Until case itself needs the witness and guard, regardless of what we've proven for simpler formulas.

**Verdict**: Does not help.

### Approach C: Use backward Until to bootstrap forward

**Observation**: Backward Until is parameterized by step transfer (UntilSinceCoherence.lean). If we could prove step transfer, we'd have both backward Until and (via some argument) forward Until.

**Key insight about step transfer**: The step transfer needs: `(phi U psi) in M_{r+1} ∧ phi in M_r → (phi U psi) in M_r`. Under reflexive semantics, by BX8, `psi → (phi U psi)`. So if psi(r) holds, we're done. If psi(r) doesn't hold, by BX9, since (phi U psi)(r+1) holds and assuming (phi U psi) somehow reaches M_r... this is circular again.

The step transfer for backward Until is EQUIVALENT in difficulty to the forward direction. Both require Until to propagate through Lindenbaum extension, which it doesn't.

**Verdict**: Does not help.

### Approach D: Quasimodel / filtration approach

**Idea**: Instead of building a single Lindenbaum chain where each step is a full MCS, build a "quasimodel" where each world is a finite restriction of an MCS to `subformulaClosure(root)`. In a quasimodel, Until coherence can be enforced by construction (adding worlds to satisfy eventualities).

**This is the classical approach** in the temporal logic completeness literature (Gabbay et al., "Temporal Logics"; Reynolds 2003; Wolter/Zakharyaschev). The quasimodel approach works as follows:

1. Start with a consistent formula root.
2. Build a quasimodel: a set of "states" (subsets of subformulaClosure(root)) satisfying local consistency conditions.
3. Use a defect elimination process: for each Until/Since obligation not yet satisfied, add a witness state.
4. Show termination (finitely many states in subformulaClosure(root) means finitely many distinct states).
5. Extract a genuine model from the quasimodel.

**Assessment**: This is a ~2000 LOC rewrite (as noted in the task description) but is the STANDARD approach that avoids the Lindenbaum chain blocker entirely. The existing code would need:
- A Quasimodel structure (finite set of local states)
- Local consistency conditions (propositional + modal + temporal)
- Defect elimination loop
- Extraction of BFMCS from quasimodel
- New truth lemma variant

**Verdict**: Viable but large effort. This is Direction 3 in the task description.

### Approach E: Restricted Until coherence via extended deferral closure + pigeonhole

**This is the most promising novel approach.**

**Key insight**: In the restricted chain, each position is a `DeferralRestrictedMCS phi` -- a maximal consistent subset of `deferralClosure(phi)`. There are finitely many such subsets (deferralClosure is finite). By pigeonhole, the chain MUST cycle.

If we extend to `extendedDeferralClosure(phi)` (which includes Until/Since deferral disjunctions), the chain can track Until obligations. Specifically:

1. From `(phi U psi) in chain(n)` in the extended restricted chain
2. By BX5+BX9: `psi ∨ (phi ∧ (phi U psi)) in chain(n)` -- and this disjunction IS in `extendedDeferralClosure`
3. If psi(n) holds: done (reflexive witness)
4. If not psi(n): `phi(n)` and `(phi U psi)(n)` hold. The Until obligation persists.
5. By pigeonhole on `extendedDeferralClosure(root)` (finite): within at most `2^|extendedDeferralClosure(root)|` steps, either psi appears or we get a cycle.
6. A cycle where `(phi U psi)` persists but psi never appears contradicts BX10: `(phi U psi) → F(psi)` combined with `F(psi)` eventually resolving (since the chain has forward_F for formulas in deferralClosure, and psi is in subformulaClosure ⊆ closureWithNeg ⊆ deferralClosure).

**The critical sub-question**: Does the restricted chain's forward_F for psi eventually resolve? The sorry in `restricted_forward_bounded_witness_fueled` at fuel=0 is the EXACT same blocker.

**BUT**: In the DOVETAILED chain, forward_F is sorry-free (DovetailedFMCS_forward_F). The dovetailed chain uses full MCS at each position, but it DOES have F-resolution through fair scheduling. So if we use the dovetailed chain AND the pigeonhole argument on the subformula closure:

1. `(phi U psi) in fam.mcs(t)` in the dovetailed chain
2. By BX10: `F(psi) in fam.mcs(t)`
3. By DovetailedFMCS_forward_F: `exists s > t, psi in fam.mcs(s)` -- sorry-free
4. Need: `phi in fam.mcs(r)` for all `r in [t, s)`
5. By BX5+BX9 at each r where `(phi U psi) in fam.mcs(r)`: either `psi(r)` or `phi(r) ∧ (phi U psi)(r)`
6. If psi(r) holds for some r < s: take the EARLIEST such r as the new witness. The guard [t, r) has phi at every point (since Until persists up to r and doesn't produce psi before r).

**Wait -- step 6 requires knowing that (phi U psi) persists from t to r.** This is exactly the propagation problem.

**Refined approach using BX10 + DovetailedFMCS_forward_F + proof by contradiction**:

Assume `(phi U psi) in fam.mcs(t)`. We want witness and guard.

1. By BX10: `F(psi) in fam.mcs(t)`.
2. By DovetailedFMCS_forward_F (sorry-free): exists `s > t` with `psi in fam.mcs(s)`.
3. Take the MINIMAL such s (dovetailed chain over Int, so there might not be a minimum... actually, integers have well-ordering on naturals, and s > t with s integer means s >= t+1).

Actually, we cannot take a minimal s because we don't have well-foundedness over the chain positions for this predicate. The dovetailed chain gives us SOME s, not a minimal one.

**Alternative**: Prove by strong induction. Suppose `(phi U psi) in fam.mcs(t)` and psi is NOT in fam.mcs(t). Then by BX9: phi(t) holds. Also (phi U psi) is in fam.mcs(t). We need to show (phi U psi) is in fam.mcs(t+1). This would require the STEP TRANSFER in the FORWARD direction: showing Until persists one step forward unless resolved.

This is the `until_step_with_G` sorry at SuccRelation.lean:527-548, and it's blocked because under reflexive X=id semantics, there's no propagation mechanism.

**Verdict**: Approach E reduces to the same fundamental blocker. The dovetailed chain's sorry-free forward_F for F-formulas does NOT extend to forward Until without step propagation.

---

## Concrete Assessment of Direction 1

### Can `forward_until_since_coherent` be weakened to quantify over deferralClosure?

**YES**, it can be weakened. The truth lemma only needs it for formulas in `subformulaClosure(root) ⊆ deferralClosure(root)`. A `restricted_forward_until_since_coherent root` would suffice.

### Would this weakened version be easier to prove?

**NO**. The restriction does not help because the difficulty is in proving the property for EVEN ONE Until formula, not in proving it for many formulas. The blocker is the chain construction's inability to propagate Until obligations forward, and restricting the quantification domain does not address this.

### Is the restricted chain's `restricted_forward_chain_forward_F` sorry-free?

**NO**. It has a hidden sorry in `restricted_forward_bounded_witness_fueled` at fuel=0 (line 3042). The comment explicitly says this is "NOT merely a technical gap" -- the fuel-based termination argument is mathematically unsound because the F-nesting boundary can grow at each step.

---

## Assessment of F_until_equiv Impact

The `F_until_equiv` (equivalence `F(psi) <-> (top U psi)`) was removed with the discrete axioms (Soundness.lean:722). It exists only in the Boneyard (deprecated code) with a sorry (FiniteDeferral.lean:48). Under the BX axiom system:

- `(phi U psi) → F(psi)` IS derivable (BX10, sorry-free)
- `F(psi) → (top U psi)` is NOT directly available as an axiom

The unavailability of `F(psi) → (top U psi)` means the classical approach of converting F-obligations to Until-obligations (and then using Until-persistence/pigeonhole) is blocked. This does affect Direction 1 because the Boneyard's FiniteDeferral approach relied on this equivalence.

However, Direction 1 doesn't fundamentally depend on F_until_equiv. The restricted chain has its own F-resolution mechanism via deferral disjunctions, independent of the F-to-Until conversion. The blocker is the fuel termination argument, not F_until_equiv.

---

## Gaps and Risks

1. **Gap**: No restricted version of `forward_until_since_coherent` has been defined or wired into the truth lemma. Creating one is straightforward but requires modifying TemporalCoherence.lean and CanonicalConstruction.lean.

2. **Risk**: The fundamental blocker (Until non-propagation through Lindenbaum extension) is PROVABLY difficult, not merely a missing lemma. 43 prior rounds have confirmed this with 95% confidence.

3. **Gap**: The restricted chain's F-resolution (`restricted_forward_bounded_witness_fueled`) has a mathematically unsound termination argument. Even fixing this would not give forward Until coherence directly.

4. **Risk**: The reflexive X = id collapse eliminates the primary propagation mechanism for Until formulas (X-content in seeds). This is a fundamental semantic obstacle, not a proof engineering issue.

---

## Confidence Levels

| Finding | Confidence |
|---------|------------|
| Truth lemma only needs restricted forward_until_since_coherent | HIGH |
| Restricted chain forward_F has hidden sorry (unsound fuel argument) | HIGH |
| BX10 gives (phi U psi) -> F(psi) but not the guard | HIGH |
| deferralClosure excludes Until/Since deferrals | HIGH |
| Reflexive semantics causes X = id collapse, blocking propagation | HIGH |
| Restricting quantification does NOT reduce proof difficulty | HIGH |
| Dovetailed chain has sorry-free forward_F but not forward_Until | HIGH |
| F_until_equiv unavailability is NOT the primary blocker | MEDIUM |

---

## Recommendation

**Direction 1 (restricted forward Until via deferral closure) does NOT resolve the fundamental blocker.** While the truth lemma CAN be weakened to use a restricted version, and this is a valid refactoring, the proof of even the restricted version faces the same obstacle: Until formulas cannot propagate through Lindenbaum extension steps under reflexive semantics.

**The most promising path forward is the dovetailed chain COMBINED with an argument that avoids needing Until propagation.** Specifically:

1. The dovetailed chain has sorry-free `forward_F` and `backward_P`.
2. From `(phi U psi) in fam.mcs(t)`, BX10 gives `F(psi)`, and dovetailed forward_F gives `psi at some s > t`.
3. The ONLY missing piece is the guard: `phi in fam.mcs(r)` for `r in [t, s)`.
4. The guard follows if we can show `(phi U psi)` persists from t to each r < s, because BX5+BX9 gives phi(r) from (phi U psi)(r) when psi(r) doesn't hold.
5. Showing `(phi U psi)` persists from t to r requires BACKWARD Until from r to s: given psi(s) and phi on (r, s), derive (phi U psi)(r). But this is the backward direction, which needs step transfer -- another sorry.

**The two sorries (forward Until propagation and backward Until step transfer) are in fact the SAME problem viewed from different directions.** Neither can be solved without a chain construction that explicitly tracks Until obligations.

**Long-term recommendation**: Pursue Direction 3 (quasimodel approach) as the only approach that has not been invalidated by the 43 prior rounds. The ~2000 LOC estimate is significant but the approach is mathematically sound and well-documented in the literature.

**Short-term recommendation**: Define `restricted_forward_until_since_coherent root` and wire it into the restricted truth lemma as a clean refactoring. This does not solve the sorry but properly scopes the problem and may enable future approaches that exploit the restriction.
