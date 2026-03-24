# Research Report: Task #48 - Constructive/Computational Perspective

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Teammate**: B (math-research-agent)
**Focus**: Constructive/computational perspective on chain building blocker
**Date**: 2026-03-24

## Executive Summary

- The core obstruction is NOT about termination of recursion — it is about **information availability** at the boundary: when F(psi) is at the edge of `deferralClosure`, we cannot apply negation completeness to get `neg(FF(psi))`, and thus cannot construct `GG(neg(psi))` to block propagation via the f-step
- The `bounded_witness` theorem for FULL MCS chains works correctly and is proven; the blocker is specifically in the **restricted chain** version using `DeferralRestrictedMCS`
- Four specific sorries remain; two of them share the same root cause (the "FF-in-dc" case), and two address the "FF-out-of-dc" boundary
- The most promising constructive solution is the **GF-blocking hypothesis approach** — adding `GF(psi) ∉ chain(k)` as an explicit precondition, which blocks the g-content propagation path and makes the remaining case provable
- A secondary approach is to **redefine deferralClosure** to be closed under `F`-application, which eliminates the boundary case entirely by ensuring `F(psi) ∈ dc → FF(psi) ∈ dc`

## Context & Scope

Task 48 aims to eliminate sorries from `SuccChainFMCS.lean` that block temporal coherence for the restricted chain construction. The full unrestricted chain is already constructed (`SuccChainFMCS`, `SuccChainTemporalCoherent`) and depends on `f_nesting_is_bounded` and `p_nesting_is_bounded` which are themselves sorried (marked deprecated as mathematically false for arbitrary MCS). The restricted chain construction was introduced to fix this, but introduces new sorries around the "boundary case."

## Findings

### 1. The Existing Proof Architecture is Mostly Sound

The unrestricted chain (`succ_chain_fam`) is fully constructed with:
- `SuccChainFMCS`: provides `FMCS Int` with `forward_G`, `backward_H`
- `SuccChainTemporalCoherent`: extends with `forward_F`, `backward_P`

The `forward_F` coherence proof (`succ_chain_forward_F`) calls `f_nesting_boundary` which calls `f_nesting_is_bounded`, which is the sorry. The architecture is:

```
succ_chain_forward_F
  -> f_nesting_boundary
    -> f_nesting_is_bounded  [SORRY: false for arbitrary MCS]
    -> f_nesting_boundary_of_bounded
  -> bounded_witness  [PROVEN: correct for full MCS chains]
```

The `bounded_witness` theorem in `CanonicalTaskRelation.lean` is **fully proven** and correct. The issue is feeding it the right inputs.

### 2. The Correct Inputs Require RestrictedMCS

The fix is to use `f_nesting_is_bounded_restricted` (which uses `RestrictedMCS`) instead of `f_nesting_is_bounded`. The restricted version IS proven. The gap is in building a `DeferralRestrictedMCS` chain that can serve as input to `bounded_witness`.

The `restricted_forward_chain` construction exists and works, but its temporal coherence proof contains sorries.

### 3. Exactly Where the Proof Fails

The remaining sorries are:

**Sorry 1** (line ~3070): `restricted_single_step_forcing`, case where `FF(psi) ∉ deferralClosure`

When `F(psi) ∈ chain(k)` but `FF(psi) ∉ deferralClosure`, we cannot:
1. Apply negation completeness to get `neg(FF(psi)) ∈ chain(k)` (because `FF(psi) ∉ subformulaClosure`)
2. Therefore cannot derive `GG(neg(psi)) ∈ chain(k)` (the critical formula)
3. Without `GG(neg(psi))`, the f-step condition `F(psi) ∈ f_content(chain(k))` is uncontrolled

**Sorry 2** (line ~3101-3102): `restricted_succ_propagates_F_not`, case where `FF(psi) ∈ deferralClosure`

Surprisingly this case (where `FF(psi)` IS in `deferralClosure`) is also sorried. The proof sketch exists but the actual `neg_FF_implies_GG_neg_in_mcs` derivation hasn't been connected to the DeferralRestrictedMCS negation completeness. This should be provable once the boundary case is understood.

**Sorry 3** (line ~3115): `restricted_succ_propagates_F_not`, case `F(psi) ∈ dc` but `FF(psi) ∉ dc`

Same as Sorry 1 — the boundary case.

**Sorry 4+** (lines ~3187, ~3765, ~3993, ~4005): `restricted_succ_propagates_F_not'` with GF-hypothesis

The strengthened version (`h_GF_not` added as hypothesis) has multiple sorry locations, but most appear to be unfinished proof steps within a nearly-complete argument rather than fundamental blockers.

### 4. Why the Existing Approaches Failed

**Fuel-based recursion**: Failed because in the "persistence" case (F(psi) defers to chain(k+1)), the fuel bound weakens. After `closure_F_bound(phi)` persistence steps, fuel reaches 0 but `d` hasn't decreased. The measure `d + fuel` decreases but doesn't prove the obligation is satisfied. Root cause: confusing "termination argument" with "satisfiability argument."

**Lexicographic recursion**: The measure `(closure_F_bound - d, fuel)` would work for termination, but the persistence case with GF-blocking shows we need more than just termination — we need a structural argument about what's in the successor.

**Boundary resolution sets**: Introduced `boundary_resolution_set phi u = {chi | F(chi) ∈ u ∧ FF(chi) ∉ dc ∧ GF(chi) ∉ u}` and tried to add `chi` to the seed. The consistency proof for the augmented seed requires showing `chi.neg` is not DERIVABLE from the seed (not just not a direct member), which depends on showing `GG(chi.neg)` doesn't reach the seed — circular dependency.

### 5. The GF-Blocking Hypothesis Approach (Most Promising)

The file shows the `restricted_succ_propagates_F_not'` theorem which adds `h_GF_not : GF(psi) ∉ chain(k)` as an explicit hypothesis. With this hypothesis:

- **g_content path is blocked**: `F(psi) ∈ g_content(u)` iff `GF(psi) ∈ u`, so this path is explicitly excluded
- **f_content path via FF(psi) ∉ dc**: `FF(psi) ∉ dc → FF(psi) ∉ v`, so `F(psi) ∉ f_content(v)`
- **The only remaining question**: Can `F(psi)` enter `v` by maximality alone?

For the maximality question with `FF(psi) ∉ dc` and `GF(psi) ∉ u`:

The seed of `v` is `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking`. None of these directly inject `F(psi)`:
- `F(psi) ∉ g_content(u)` because `GF(psi) ∉ u` (h_in_g = false)
- `F(psi)` is not a deferral disjunction (wrong syntactic form: those are `chi ∨ F(chi)`)
- `F(psi)` is not a p_step_blocking formula (those are H-formulas)

So `F(psi) ∉ seed`. The DeferralRestrictedMCS is maximal within `deferralClosure`, so either `F(psi) ∈ v` or `G(psi.neg) ∈ v`. To show `F(psi) ∉ v`, we need `G(psi.neg) ∈ v`.

**Key insight**: We can derive `G(psi.neg)` in `v` if `G(psi.neg)` is in the seed or derivable from it. The path is:

If `GF(psi) ∈ deferralClosure` and `GF(psi) ∉ u` (from h_GF_not), then by DRM negation completeness (for formulas in subformulaClosure): `neg(GF(psi)) ∈ u`. Then:
```
neg(GF(psi)) = neg(G(F(psi))) = F(neg(F(psi))) = F(G(psi.neg))
```
So `FG(psi.neg) ∈ u`, meaning `G(psi.neg) ∈ f_content(u)`, meaning by f_step, `G(psi.neg) ∈ v ∪ f_content(v)`. If `G(psi.neg) ∈ v`, done. If `FG(psi.neg) ∈ v`, then we need another step — but this is the F-coherence chain issue again.

If `GF(psi) ∉ deferralClosure`, then the DRM gives no information about `GF(psi)`, but `G(psi.neg)` may still be in the seed if `F(psi)` was in `u` (via deferral disjunction + disjunction resolution).

The codebase shows this analysis at lines 3360-3460 but the proof isn't complete.

### 6. The F-Closed Closure Approach (Eliminates Boundary)

The fundamental difficulty is that `deferralClosure phi` is NOT closed under the F operator. If `F(psi) ∈ deferralClosure phi`, it does NOT follow that `FF(psi) ∈ deferralClosure phi`.

**Proposed fix**: Define a new closure that IS closed under F:

```lean
def fClosedDeferralClosure (phi : Formula) : Set Formula :=
  -- smallest set containing deferralClosure phi, closed under F and P application
```

With this closure, whenever `F(psi) ∈ closure`, we have `FF(psi) ∈ closure`, and the negation completeness argument goes through uniformly. The boundary case disappears.

The tradeoff is that this closure may be larger (potentially infinite for some formulas), but the key property is:

```
F(psi) ∈ fClosedDeferralClosure phi → iter_F n psi ∈ fClosedDeferralClosure phi for all n
```

This would NOT be finite, defeating the purpose. So F-closed closures don't work directly.

**Alternative**: Use `subformulaClosure` directly (which IS finite) and observe that `subformulaClosure phi` already has bounded F-depth. Since `deferralClosure` = `closureWithNeg ∪ deferralDisjunctions(subformulaClosure)`, and `subformulaClosure` has bounded F-depth, we can argue about when `F(psi) ∈ deferralClosure → FF(psi) ∈ deferralClosure`.

### 7. The Disjunction Resolution Path

The file contains (at line ~3370) a key structural insight that's not yet fully exploited:

If `F(psi) ∈ u` and `FF(psi) ∉ dc`, then `psi ∨ F(psi)` is a deferral disjunction in `u`. In `v`:
- The deferral disjunction `psi ∨ F(psi)` is in the seed (and hence in `v`)
- By DRM maximality, either `psi ∈ v` or `F(psi) ∈ v`

But we want to show `F(psi) ∉ v`. So we'd need to show `psi ∈ v`, which would require a separate argument.

The f_step property says `psi ∈ f_content(u) → psi ∈ v ∨ F(psi) ∈ v`. Since `F(psi) ∈ u` means `psi ∈ f_content(u)`, we get `psi ∈ v ∨ F(psi) ∈ v`. If `F(psi) ∉ v` we'd have `psi ∈ v`. But showing `F(psi) ∉ v` is what we're trying to prove — circular!

The resolution: we need to show that when `FF(psi) ∉ dc`, the MCS construction "prefers" `psi ∈ v` over `F(psi) ∈ v`. This requires controlling the Lindenbaum construction.

### 8. Controlling the Lindenbaum Construction

The standard Lindenbaum construction adds formulas one by one in some enumeration order. The construction can be made to "prefer" certain formulas by controlling the order.

**Henkin-ordering idea**: Enumerate formulas such that `psi` comes before `F(psi)` in the Lindenbaum extension when `F(psi) ∈ u` and `FF(psi) ∉ dc`. This would force `psi ∈ v` (satisfying the obligation now) rather than `F(psi) ∈ v` (deferring).

This is essentially a **priority queue** Lindenbaum construction:
1. Higher priority: formulas that resolve F-obligations (witnesses `psi` for `F(psi) ∈ u`)
2. Lower priority: formulas that defer F-obligations (F-formulas)

The challenge: This is a non-standard Lindenbaum construction. We'd need to prove it still produces an MCS (maximal consistent set), and that it respects the deferralClosure bound.

**Assessment**: Feasible in principle but requires significant refactoring of the successor construction.

### 9. Direct Proof via Consistency of the Alternative

There is a simpler direct argument available that hasn't been tried:

**Claim**: In the boundary case (`F(psi) ∈ u`, `FF(psi) ∉ dc`, `GF(psi) ∉ u`), we can show `G(psi.neg) ∈ seed(u)` directly.

**Argument**:
- `FF(psi) ∉ dc` means `FF(psi) ∉ subformulaClosure phi`
- This means `FF(psi) ∉ closureWithNeg phi`
- Now `G(psi.neg) = neg(F(psi))`. Is `G(psi.neg) ∈ subformulaClosure phi`?
- If `F(psi) ∈ subformulaClosure phi`, then `G(psi.neg)` might not be.
- But from `GF(psi) ∉ dc` and the structure of `deferralClosure`:
  `GF(psi) ∉ u`, so negating: if `GF(psi) ∈ subformulaClosure phi` then `FG(psi.neg) ∈ u`.

This is the same circularity as before.

### 10. The Correct Theorem Statement May Be Different

A key realization from the codebase analysis:

The theorems `restricted_succ_propagates_F_not` and `restricted_single_step_forcing` may have **incorrect preconditions** for the restricted chain use case. The correct theorem to prove might be weaker:

```lean
theorem restricted_F_coherence (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
    (n : Int) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_chain phi M0 n) :
    ∃ m > n, psi ∈ restricted_chain phi M0 m
```

Rather than proving the propagation negatives (`F(psi) ∉ chain(k+1)` when `FF(psi) ∉ chain(k)`), we directly prove F-coherence by:
1. Using `restricted_mcs_F_bounded` to find the boundary depth `d`
2. Using an adapted `bounded_witness` for DeferralRestrictedMCS chains

The question is whether `bounded_witness` can be adapted. The current `bounded_witness` uses `single_step_forcing` and `succ_propagates_F_not`, both of which require full MCS negation completeness. A restricted version would need:
- `restricted_single_step_forcing`: F(psi) ∈ u, FF(psi) ∉ u, Succ u v → psi ∈ v
- This requires full MCS or that both F(psi) and FF(psi) are in subformulaClosure

## Analysis of Why Each Approach Fails

| Approach | Root Cause of Failure |
|----------|----------------------|
| Direct negation completeness for FF(psi) | `FF(psi) ∉ subformulaClosure` at boundary → negation completeness inapplicable |
| Fuel-based recursion | Fuel bound weakens in persistence case; no connection between fuel=0 and satisfaction |
| Lexicographic recursion | Terminates but doesn't prove formula-in-chain property |
| Boundary resolution set | Consistency requires `chi.neg not derivable from seed` — requires knowing GG(chi.neg) ∉ u, which depends on same boundary argument |
| F-closed closure | Would be infinite; defeats finiteness purpose of restricted construction |
| Priority Lindenbaum | Non-standard; needs proof that priority extension still produces MCS |

## Potential New Approaches

### Approach A: Full MCS Extension + RestrictedMCS Projection (HIGH CONFIDENCE)

**Key insight**: `bounded_witness` works for full `SetMaximalConsistent` chains. Instead of building a restricted chain directly, build a full chain and project.

**Construction**:
1. Start with `DeferralRestrictedMCS M0`
2. Use `restricted_lindenbaum` to extend `M0.world` to a full `SetMaximalConsistent M'`
3. Apply `succ_chain_forward_F` (which is ALREADY PROVEN) to get `phi ∈ succ_chain_fam(M')` at some time `m`
4. Project back: since `psi ∈ succ_chain_fam M' m` and `psi ∈ subformulaClosure phi`, show `psi ∈ restricted_forward_chain phi M0 m'` for some `m'`

**Challenge**: The projection step requires showing that if `psi ∈ succ_chain_fam M' m` and `psi ∈ subformulaClosure phi`, then some element of the restricted chain also contains `psi`. This is non-trivial because the two chains diverge.

**Alternative projection**: Instead of projecting forward, use the fact that both chains start from the same `M0.world` and share a common prefix, show they agree on subformula-bounded formulas.

### Approach B: Restrict the Proof, Not the Chain (MEDIUM CONFIDENCE)

Instead of building a restricted chain, the completeness proof for `construct_bfmcs` can use the full `succ_chain_fam` but only needs `M = fam.mcs t` for the START POINT, not that the whole chain is restricted.

The two SORRIED theorems (`f_nesting_is_bounded`, `p_nesting_is_bounded`) are used in:
- `succ_chain_forward_F` (calls `f_nesting_boundary` which calls `f_nesting_is_bounded`)
- `succ_chain_backward_P` (calls `p_nesting_boundary` which calls `p_nesting_is_bounded`)

These theorems are provable if we start from a `RestrictedMCS` rather than arbitrary `SetMaximalConsistent`. So the fix is:

1. In `construct_bfmcs`, start from the given `SetMaximalConsistent M`
2. Build a `RestrictedMCS M_r` that contains `M` (using `restricted_lindenbaum`)
3. Construct `succ_chain_fam M_r_serial` where `M_r_serial` is the serial version
4. Use `succ_chain_forward_F` and `succ_chain_backward_P` on this restricted-start chain

The chains built from `M_r` will still be full MCS at each time point, but the START POINT has bounded F-depth. Then `f_nesting_is_bounded` holds at the start point (since it's a RestrictedMCS), and the bounded_witness argument goes through.

**Critical check needed**: Does the proof of `succ_chain_forward_F` use `f_nesting_boundary` at every time point, or only at the starting world? If it's called at every time point, then we need all chain elements to be RestrictedMCS, not just the first.

Looking at the code:
```lean
theorem succ_chain_forward_F (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m
```

This uses `f_nesting_boundary (succ_chain_fam M0 n) (succ_chain_fam_mcs M0 n) phi h_F`. So it calls `f_nesting_boundary` at the world `n` where `F(phi)` holds. That world is `forward_chain M0 k` for some `k`, which is a FULL MCS (not a RestrictedMCS).

**Resolution**: The fix is to use `f_nesting_boundary_of_bounded` instead of `f_nesting_boundary`, by separately providing the bound from a DIFFERENT argument (rather than from `f_nesting_is_bounded`).

The bound exists because `f(phi)` must have finite F-nesting in the succ_chain. Specifically: in the canonical model, all F-formulas satisfy the frame semantics of discrete linear time. The seriality axiom ensures this. But this requires a semantic argument.

### Approach C: Directly Close the Sorry via Temporal Axiom T4 (MEDIUM CONFIDENCE)

The sorry in `restricted_succ_propagates_F_not'` at the `FF(psi) ∈ deferralClosure` case (line ~3186) looks provable. The proof sketch mentions "derivable via the proof system" and the code at lines 3440-3460 shows a nearly-complete proof using `deferral_restricted_mcs_negation_complete`.

This specific sorry should be resolvable by:
1. Applying DRM negation completeness to `GF(psi)` (which is in subformulaClosure when `GF(psi) ∈ dc`)
2. Getting `neg(GF(psi)) = FG(psi.neg) ∈ u`
3. Using f_step to get `G(psi.neg) ∈ v` (resolving) or `FG(psi.neg) ∈ v` (deferring)
4. In the resolving case: `G(psi.neg) ∈ v → F(psi) ∉ v` by consistency
5. In the deferring case: need F-coherence again, but now for `G(psi.neg)` which has LOWER F-depth

The deferring case terminates because each deferral of `G(psi.neg)` requires `FG(psi.neg) ∈ v`, which has higher F-depth, and eventually leaves the closure.

**This approach requires a nested induction or well-founded recursion on F-depth.**

### Approach D: Semantic Filtration (LOW CONFIDENCE)

Use the finite model property (FMP) infrastructure that already exists in the codebase (`Theories/Bimodal/Metalogic/Decidability/FMP/`). The FMP for TM logic gives finite models. Build the chain from a finite filtration model instead of directly via Lindenbaum.

This would sidestep the chain building problem entirely but requires connecting the FMP infrastructure to the completeness proof structure.

## Confidence Assessment

| Approach | Confidence | Effort | Notes |
|----------|-----------|--------|-------|
| A: Full MCS extension + projection | Medium | High | Projection step unclear |
| B: Restrict-start chain | High | Medium | Requires identifying where f_nesting_boundary is called |
| C: Close FF-in-dc sorry directly | High | Low-Medium | Mostly written, needs termination argument |
| D: Semantic filtration | Low | Very High | Major architectural change |
| GF-blocking hypothesis | High | Low | Already mostly proven at lines 3420-3460 |

## Recommended Path Forward

**Immediate (to close specific sorries)**:

1. Close the `FF(psi) ∈ deferralClosure` sorry in `restricted_succ_propagates_F_not'` (Approach C). The code exists at lines 3420-3460 but needs the induction on F-depth to handle the deferring sub-case. Estimated 1-2 hours of proof work.

2. For `restricted_succ_propagates_F_not'` with the `GF(psi) ∉ deferralClosure` case: the structural argument in lines 3270-3310 shows F(psi) cannot enter v via the seed. But we still need to show G(psi.neg) is either in the seed or derivable. This is the hard case — use Approach B (see below).

**Strategic (to bypass the boundary case)**:

3. Implement Approach B: modify `succ_chain_forward_F` to accept a `RestrictedMCS` starting point and use `f_nesting_boundary_restricted` instead of `f_nesting_boundary`. This avoids calling `f_nesting_is_bounded` (the false sorry) and uses the correct restricted version.

The signature change would be:
```lean
theorem succ_chain_forward_F_from_restricted (M0 : SerialMCS) (n : Int) (phi chi : Formula)
    (h_mcs_restricted : RestrictedMCS chi (succ_chain_fam M0 n))
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m
```

The `construct_bfmcs` function would need to ensure the starting MCS is restricted, which it can do by using `restricted_lindenbaum` on the given `SetMaximalConsistent M`.

## Appendix: Key Files and Locations

| File | Key Content |
|------|-------------|
| `SuccChainFMCS.lean` lines 3070-3460 | Remaining sorries and partial proofs |
| `CanonicalTaskRelation.lean` lines 600-680 | `bounded_witness` proof (complete) |
| `SuccRelation.lean` lines 200-260 | `single_step_forcing` (complete for full MCS) |
| `RestrictedMCS.lean` lines 132-150 | `restricted_mcs_negation_complete` (complete) |
| `SuccChainFMCS.lean` lines 693-760 | `f_nesting_is_bounded_restricted` (complete, correct version) |
| `SuccChainCompleteness.lean` | Entry point showing what `construct_bfmcs` needs |
