# Research Report: ROADMAP Synthesis and Path Forward for Task 48

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Type**: Synthesis of ROADMAP analysis, blocker findings, and algebraic perspective
**Sources**: ROADMAP.md (merge commit 3406618f2), task 52 CanonicalR audit, 13 prior plan versions, team research reports

---

## 1. Current Sorry Landscape

After plan v13 partial implementation, SuccChainFMCS.lean contains **9 active sorries** (excluding 2 deprecated backward-compat stubs at lines 735, 970):

| Line | Theorem | Classification |
|------|---------|---------------|
| 3069 | `restricted_single_step_forcing` | Class B: FF(psi) not in dc |
| 3101 | `restricted_succ_propagates_F_not` | Class B: neg(FF) -> GG(neg) derivation |
| 3115 | `restricted_succ_propagates_F_not` | Class B: F(psi) in dc, FF(psi) not in dc |
| 3186 | `restricted_succ_propagates_F_not'` | Class B: same as 3101 |
| 3764 | `restricted_succ_propagates_F_not'` | Class B: double negation boundary |
| 3992 | `restricted_succ_propagates_F_not'` | **FALSE** (code explicitly notes this) |
| 4004 | `restricted_succ_propagates_F_not'` | **FALSE** (code explicitly notes this) |

### Class A Resolution (COMPLETED)

The ROADMAP identified "Class A" sorries (modal duality via DNE) at original lines 2359 and 3011. Plan v13 successfully proved this case (97-line proof at lines 2354-2449) using:
- Modal duality: `FF(psi) in closureWithNeg` -> `G(F(psi).neg) in subformulaClosure`
- DNE via `drm_closed_under_derivation`
- g_persistence + f_step resolution

**Class A is resolved.** All remaining sorries are Class B.

### Class B: Fundamental Obstacle Identified

After 13 plan versions, the core finding is definitive:

> **`restricted_single_step_forcing` is FALSE for the `FF(psi) not in deferralClosure` case.**

The MCS extension uses `Classical.choose` which is nondeterministic at the closure boundary. When `FF(psi) not in dc`, negation completeness is unavailable, and f_step only gives a disjunction `psi in v OR F(psi) in v`. The maximality extension can include `F(psi)` without any forcing mechanism preventing it.

The code itself reaches this conclusion at line 3985-3986:
> "The theorem `restricted_succ_propagates_F_not'` with hypotheses `h_FF_not` and `h_GF_not` is NOT provable in general."

---

## 2. The ROADMAP's Two Resolution Strategies

ROADMAP.md identifies two approaches for Class B:

### Strategy 1: Weaken the theorem
Prove `exists d, psi in chain(k+d)` instead of `psi in chain(k+1)`.

**Assessment**: This is the correct direction. The theorem `restricted_bounded_witness` may still be TRUE even though its intermediate lemmas are false — it just needs a proof that doesn't decompose into single-step forcing.

### Strategy 2: Enlarge the closure
Include all F-iterations in deferralClosure so FF(psi) is always in scope.

**Assessment**: Risks cascading changes to the closure definition. More invasive but would make single-step forcing true.

---

## 3. Recommended Approach: Direct Bounded Witness

The blocker analysis recommends a fundamentally restructured proof of `restricted_bounded_witness`:

**Key Insight**: Instead of proving "each step resolves psi immediately" (single_step_forcing), prove "across d steps, psi must eventually appear" using a termination argument.

**Proof Strategy**:
1. f_step gives: `psi in chain(k+1) OR F(psi) in chain(k+1)` at each step
2. Don't try to eliminate the disjunction at each step — track it
3. If `F(psi)` persists, at the next step we get the same disjunction
4. The F-depth cannot INCREASE because there's no `FF(psi)` in dc to push higher
5. Since deferralClosure is finite, F-deferral cannot continue forever
6. Well-founded measure: lexicographic on `(F-nesting depth, steps remaining in dc)`

**Concrete restructuring**:
- Delete `restricted_single_step_forcing` and `restricted_succ_propagates_F_not` (and primed variants)
- Prove `restricted_bounded_witness` directly by induction on `d`
- Preserve the Class A proof (lines 2354-2449) as the base case handling
- The `FF not in dc` case becomes: "F(psi) may persist but will eventually resolve"

**Why this works**: The unrestricted `bounded_witness` (CanonicalTaskRelation.lean:651-680) uses full MCS negation completeness to force single-step resolution. The restricted version cannot do this, but doesn't need to — it only needs eventual resolution, which follows from dc finiteness.

---

## 4. Algebraic Alternative (ROADMAP Perspective)

The ROADMAP identifies a sorry-free algebraic path:

```
LindenbaumQuotient -> BooleanStructure -> InteriorOperators
    -> UltrafilterMCS -> ParametricCanonical -> ParametricTruthLemma
    -> ParametricRepresentation (SORRY-FREE, conditional on construct_bfmcs)
```

The gap is `construct_bfmcs`: given MCS M0, produce a temporally coherent BFMCS.

**Algebraic bypass**: Instead of explicit F-obligation chain enumeration (which hits the closure boundary), use the **temporal shift automorphism** on the Lindenbaum algebra. This works at the algebraic level without needing deferralClosure at all.

**Key question**: Can the temporal shift automorphism be defined on the Lindenbaum algebra? If G determines a topology on L whose open sets are G-closed, then temporal accessibility is a preorder on ultrafilters, and the FMCS construction is the Stone-space unraveling.

**Assessment**: This is a promising alternative that could bypass the entire SuccChain construction, but it requires significant new infrastructure (STSA formalization, ~4-6 hours). Task 992 tracks this.

---

## 5. Recommended Path Forward

### Immediate (within task 48):
1. **Create plan v14**: Direct bounded_witness via f_step disjunction tracking
   - Delete false intermediate lemmas
   - Prove bounded_witness by induction with lexicographic termination
   - Preserve Class A proof as optimized base case
   - Estimated: 4-6 hours if the approach works

### If v14 fails:
2. **Activate Task 49**: FMP-based fallback using filtration
   - Uses existing FMP infrastructure (ClosureMCS, FiniteModel, Filtration)
   - Avoids deferralClosure boundary entirely
   - Estimated: 6-8 hours

### Parallel investigation:
3. **Elevate Task 992 (STSA)**: Algebraic alternative
   - Could bypass SuccChain construction entirely
   - ~4-6 hours for formalization, independent of critical path
   - Medium priority per ROADMAP's algebraic gap analysis

---

## 6. Impact on Critical Path

Current: `48 -> 36 -> 37 -> verify` (~15-25 hours)

If direct bounded_witness works (v14), this pipeline completes the axiom elimination.

If it fails, alternatives:
- Task 49 (FMP fallback): adds 6-8 hours but stays on same path
- Task 992 (algebraic): parallel investigation, potentially replaces entire SuccChain approach

**Downstream cascade**: Eliminating the 2 axioms (`f_nesting_boundary`, `p_nesting_boundary`) removes ~24 sorries in SuccChainFMCS and unblocks ~30 more through completeness wiring.
