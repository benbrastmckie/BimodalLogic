# Phase 1 Handoff: SuccOrder on BidirectionalQuotient

## Session: sess_1772394758_e9c6eb, Iteration 2
## Date: 2026-03-01

## Immediate Next Action

The SuccOrder approach (Phase 1) faces a fundamental mathematical blocker: the **coverness proof**
(`succ_le_of_lt`) and **NoMaxOrder** are both mathematically problematic. A plan revision is needed.

## Current State

### Files Modified

1. **BidirectionalReachable.lean**: Reverted broken code from iteration 1. Removed all additions
   that referenced `CanonicalCompleteness.lean` definitions (circular dependency).

2. **CanonicalCompleteness.lean**: Added all the SuccOrder infrastructure that was previously
   (incorrectly) in BidirectionalReachable.lean:
   - `GContent_idempotent_in_mcs`: G(phi) in M implies G(G(phi)) in M (4-axiom)
   - `HContent_idempotent_in_mcs`: H(phi) in M implies H(H(phi)) in M
   - `GContent_eq_of_preorder_equiv`: Preorder-equivalent fragments have equal GContent
   - `HContent_eq_of_preorder_equiv`: Preorder-equivalent fragments have equal HContent
   - `fragmentGSucc_eq_of_preorder_equiv`: GSucc respects preorder equivalence
   - `fragmentHPred`: HContent predecessor in the fragment (was undefined)
   - `fragmentHPred_le`: Predecessor is <= in the preorder
   - `fragmentHPred_eq_of_preorder_equiv`: HPred respects preorder equivalence
   - `quotientSucc`, `quotientSucc_le`: Successor on quotient, well-defined and monotone
   - `quotientPred`, `quotientPred_le`: Predecessor on quotient, well-defined and monotone
   - `mcs_has_F_top`: F(neg bot) in every MCS
   - `mcs_has_P_top`: P(neg bot) in every MCS

### Build Status

- `lake build` passes with zero errors on the full project
- No new sorries introduced
- All new lemmas verified with `lean_goal`

## Mathematical Blocker Analysis

### Problem 1: SuccOrder Coverness (`succ_le_of_lt`)

The coverness property states: if `[w] < [r]` in the quotient, then `quotientSucc [w] <= [r]`.

**Why it's hard**: `quotientSucc [w] = [fragmentGSucc w]` where `fragmentGSucc w` is a Lindenbaum
extension of `GContent(w.world)`. The Lindenbaum extension is obtained via Zorn's lemma and is
non-constructive. Between `w` and `fragmentGSucc w`, there could potentially exist fragment elements
`v` with `w < v < fragmentGSucc w` if the Lindenbaum extension adds G-formulas that are not in `v`.

The proof would require showing `GContent(fragmentGSucc(w).world) = GContent(w.world)`, but this
is FALSE in general. The Lindenbaum extension can add `G(phi)` formulas not in `GContent(w.world)`.

### Problem 2: NoMaxOrder

`NoMaxOrder` requires showing `quotientSucc [w] > [w]` for all `[w]`. This means showing
`NOT (fragmentGSucc(w) <= w)`, i.e., `GContent(fragmentGSucc(w).world) NOT SUBSET w.world`.

**Why it's hard**: `fragmentGSucc(w).world = lindenbaumMCS_set(GContent(w.world))`. Since
`GContent(w.world) SUBSET w.world` (by T-axiom), `w.world` is a consistent extension of
`GContent(w.world)`. Zorn's lemma could return `w.world` itself as the maximal extension,
making `fragmentGSucc(w).world = w.world`.

In fact, a single-point model satisfies all the axioms of the logic (since G, H, F, P are
reflexive). So the quotient CAN be a single point.

### Problem 3: Conversion to Int

Even if SuccOrder were proven, converting `BidirectionalQuotient` to `Int` requires:
- `SuccOrder` (blocked by coverness)
- `PredOrder` (same issue)
- `IsSuccArchimedean` (needs proof)
- `NoMaxOrder` (blocked)
- `NoMinOrder` (blocked)

## Recommended Next Steps

### Option A: Revise Completeness Architecture (Recommended)

Generalize `TaskFrame` and downstream infrastructure to work with `D` satisfying only
`[Preorder D]` (or `[LinearOrder D]`), removing the `[AddCommGroup D] [IsOrderedAddMonoid D]`
requirements. Then use `BidirectionalFragment M0 h_mcs0` directly as the time domain with
the already sorry-free `fragmentFMCS`.

**Estimated effort**: 15-25 hours (refactoring TaskFrame, Representation, Completeness)
**Risk**: Requires non-trivial refactoring of existing infrastructure

### Option B: Direct Chain Construction with Dovetailing

Build `FMCS Int` using a dovetailing construction that processes ALL F/P obligations
using `fragmentFSucc`/`fragmentPPred` (enriched successors). Each step both advances the
chain AND witnesses a specific obligation.

**Key insight**: Use `fragmentFSucc` (which includes the witness formula in the new MCS)
rather than `fragmentGSucc` (which only extends with GContent). The F-persistence problem
doesn't arise because the formula is PLACED in the successor, not expected to persist.

**Challenge**: Still need to show that at each step, previously-witnessed formulas that need
to be in GContent are actually there.

**Estimated effort**: 20-30 hours
**Risk**: May face the same persistence issue in a different form

### Option C: Constant Family Fallback

For the trivial case (single-point quotient), use a constant family `mcs(n) = M0` for all n.
For the non-trivial case, build the chain. The proof would need to handle both cases.

**Estimated effort**: 10-15 hours for the constant case, plus 20-30 for the non-trivial case

## What NOT to Try

1. **Proving GContent(fragmentGSucc(w).world) = GContent(w.world)** -- This is false in general.
   The Lindenbaum extension can add G-formulas not in the original GContent.

2. **Proving NoMaxOrder from mcs_has_F_top alone** -- F(neg bot) is satisfied at the current
   time (reflexive semantics), so it does NOT give a strict successor.

3. **Using `DerivationTree.contrapositive` or `DerivationTree.ex_falso`** -- These don't exist.
   Use `Bimodal.Theorems.Propositional.contraposition` and `Axiom.ex_falso` instead.

## Critical Context

- The fragment-level FMCS (`fragmentFMCS`) has sorry-free forward_F and backward_P
- The quotient has LinearOrder (proven)
- The conversion from fragment-level FMCS to FMCS Int is the ONLY remaining obstacle
- The 3 sorries in DovetailingChain.lean and TemporalCoherentConstruction.lean all trace to this

## References

- Plan: specs/951_implement_sorry_free_completeness_canonicalmcs/plans/implementation-003.md
- Research: specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-014.md
- CanonicalCompleteness.lean: lines 426-665 (new infrastructure)
- BidirectionalReachable.lean: reverted to pre-iteration-1 state (lines 813+)
