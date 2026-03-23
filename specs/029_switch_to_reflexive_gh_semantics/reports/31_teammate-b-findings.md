# Teammate B Findings: Per-Construction Strictness Analysis

**Task**: 29 - switch_to_reflexive_gh_semantics
**Phase**: 5A-bis blocker resolution
**Date**: 2026-03-22
**Session**: sess_1774430280_c4d5e6
**Run Number**: 31

## Summary

**Per-construction strictness does NOT work for NoMaxOrder/NoMinOrder instances.**

The fundamental issue: seriality uses formula `F(neg bot)` where `neg bot` is a theorem present in ALL MCS. Therefore, the Lindenbaum witness cannot be distinguished from the source MCS using the seed formula.

However, Option C (scope restriction) shows promise: completeness constructions always start from a specific formula's failure, which may provide the distinguishing witness.

## Call Site Inventory

| File | Line | Site | Construction Type | Witness Available? |
|------|------|------|-------------------|-------------------|
| `Canonical/CanonicalSerialFrameInstance.lean` | 54/77 | NoMaxOrder.exists_gt | Seriality (F(neg bot)) | **NO** |
| `Canonical/CanonicalSerialFrameInstance.lean` | 100/123 | NoMinOrder.exists_lt | Seriality (P(neg bot)) | **NO** |
| `Bundle/FMCSTransfer.lean` | 234/239 | CanonicalMCS.lt_of_canonicalR | Forward/backward transfer | Depends on caller |
| `Algebraic/SaturatedChain.lean` | 370/373/401/404 | canonicalMCS_has_future/past | Seriality | **NO** |
| `Algebraic/SaturatedChain.lean` | 446/449/459/462 | chain construction | Transfer from CanonicalMCS | Depends on source |
| `StagedConstruction/TimelineQuotCanonical.lean` | 96 | antisymmetry | Transitivity closure | Depends on path |
| `StagedConstruction/ClosureSaturation.lean` | 391/395 | closure saturation | Saturation step | Depends on step type |
| `StagedConstruction/IncrementalTimeline.lean` | 156 | antisymmetry | Transitivity closure | Depends on path |
| `StagedConstruction/DovetailedTimelineQuot.lean` | 403/1392+ | multiple sites | Dovetailing construction | Depends on construction |
| `Domain/DiscreteTimeline.lean` | 127/135 | discrete ordering | Seriality | **NO** |
| `Domain/CanonicalDomain.lean` | 136/180/217/250 | domain ordering | Seriality | **NO** |

**Critical Finding**: 6 of the primary call sites use seriality (F(neg bot) or P(neg bot)) which cannot provide a distinguishing witness.

## Per-Construction Analysis

### Category 1: Seriality-Based Sites (FAILS)

**Sites**: NoMaxOrder, NoMinOrder, canonicalMCS_has_future/past, domain ordering

**Seed Used**: `{neg bot} U g_content(M)` for forward, `{neg bot} U h_content(M)` for backward

**Why Strictness Fails**:
- Formula `neg bot` is a theorem (derivable from `[] |- bot -> bot`)
- Therefore `neg bot in M` for ALL MCS M
- The witness N contains `neg bot` but so does M
- No formula in the seed distinguishes N from M

**Proof**:
```lean
-- neg bot = bot -> bot is an axiom (K combinator / identity)
have h_neg_bot_deriv : [] |- Formula.neg Formula.bot :=
  Bimodal.Theorems.Combinators.identity Formula.bot
-- Every MCS contains all theorems
have h_neg_bot_in_M : Formula.neg Formula.bot in M :=
  theorem_in_mcs h_mcs h_neg_bot_deriv
```

### Category 2: Transfer Sites (CONDITIONAL)

**Sites**: FMCSTransfer.CanonicalMCS.lt_of_canonicalR, chain construction

**Seed Used**: Inherited from source witness construction

**Strictness Depends On**: Whether the original witness construction provides a distinguishing formula.

**Key Observation**: These sites use `canonicalR_irreflexive` to prove `a < b` from `CanonicalR a.world b.world`. The call pattern is:
```lean
-- h : CanonicalR a.world b.world
-- need: a < b (strict)
-- uses: canonicalR_irreflexive a.world a.is_mcs h
```

If the caller can provide a distinguishing formula `phi` where:
- `G(phi) in b.world` (so `phi in g_content(b.world)`)
- `phi notin a.world`

Then we can use `strict_of_formula_in_g_content_not_in_source` from CanonicalIrreflexivity.lean.

### Category 3: Transitivity Closure Sites (CONDITIONAL)

**Sites**: TimelineQuotCanonical, IncrementalTimeline antisymmetry

**Pattern**: Proving `a /= b` when `a <= b` and `b <= a` would imply `CanonicalR a a` via transitivity.

**Current Proof**:
```lean
have h_trans := canonicalR_transitive p.1.mcs p.1.mcs p.1.mcs h_R h_R'
exact absurd h_trans (canonicalR_irreflexive p.1.mcs p.1.is_mcs)
```

**Per-Construction Alternative**: These sites could potentially be refactored if the construction path provides distinguishing formulas, but this requires tracing through the entire construction.

## Case Study: NoMaxOrder in CanonicalSerialFrameInstance.lean

### Current Implementation (Lines 43-78)

```lean
instance : NoMaxOrder (ConstructiveQuotient M0 h_mcs0) where
  exists_gt a := by
    induction a using Quotient.ind with | _ w =>
    -- Get seriality witness: F(neg bot) in w.val
    have h_F := SetMaximalConsistent.contains_seriality_future w.val w.is_mcs
    -- Execute forward step to get successor MCS
    let N := executeForwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_F
    have h_N_mcs := executeForwardStep_mcs (h_mcs := w.is_mcs) (h_F := h_F)
    have h_R := executeForwardStep_canonicalR (h_mcs := w.is_mcs) (h_F := h_F)
    -- Strictness: CanonicalR w.val N but not CanonicalR N w.val
    have h_strict : not CanonicalR N w.val :=
      canonicalR_strict w.val N w.is_mcs h_N_mcs h_R  -- AXIOM-BASED
    ...
```

### Seed Used

The forward seed is `{neg bot} U g_content(w.val)`.

### Why Strictness Cannot Be Proven

For per-construction strictness, we need `phi in g_content(N)` with `phi notin w.val`.

The witness N contains:
- `neg bot` (from seed)
- Everything in `g_content(w.val)` (from seed)
- Additional formulas from Lindenbaum completion

**Problem**: All seed formulas are already in `w.val`:
- `neg bot in w.val` (theorem)
- `g_content(w.val) subset w.val` (by canonicalR_reflexive, T-axiom)

**Lindenbaum completion** adds formulas, but:
- It's non-constructive (Zorn's lemma)
- We cannot identify a specific formula added
- Any formula added comes from a consistent extension decision

### Attempted Fix: Use MCS-Decided Atom

Plan v7 proposed using a decided atom instead of `neg bot`:
```lean
-- For any atom p, either p in M or neg p in M
-- If p in M: use seed g_content(M) U {G(neg p)}
-- If neg p in M: use seed g_content(M) U {G(p)}
```

**Why This Fails (Report 30)**: Pathological MCS exist where `G(neg q) in M` for ALL atoms q. For such MCS:
- Every atom has `neg q in M` (by T-axiom)
- Every seed `g_content(M) U {G(q)}` is inconsistent
- No atom provides a valid seed

## Option C: Scope Restriction

### Non-Pathological Predicate

An MCS M is **non-pathological** if there exists an atom p such that `G(neg p) notin M`.

**Equivalently**: `exists p, F(p) in M` (there's a future where some atom is true)

### Preservation Under Lindenbaum

**Claim**: If the starting seed for Lindenbaum extension is non-pathological, all MCS in the reachability closure are non-pathological.

**Sketch**:
1. Completeness starts from formula `phi` with `not ([] |- phi)`
2. The seed `{neg phi}` is consistent (by non-derivability)
3. The starting MCS M0 is the Lindenbaum extension of `{neg phi}`
4. If `phi` contains any atom p, then decisions about p propagate

**Key Question**: Does the reachability construction (forward/backward steps) preserve non-pathological?

**Forward Step**: From MCS M with `F(psi) in M`, construct witness N.
- If M is non-pathological: `exists p, F(p) in M`
- Does this imply N is non-pathological?

**Analysis**:
The seed for N is `{psi} U g_content(M)`. For N to be pathological:
- `G(neg q) in N` for all atoms q
- This requires the Lindenbaum extension to add `G(neg q)` for all q
- Since `g_content(M)` is countable and doesn't determine all of N's decisions about G-formulas, this is possible in principle

**Verdict**: Non-pathological is NOT clearly preserved.

### Alternative: Reachability Never Creates Pathological

Consider the constructive fragment `ConstructiveFragment M0 h_mcs0`:
- Root: M0 (the starting MCS)
- Forward witness: N from `F(psi) in M`
- Backward witness: N from `P(psi) in M`

**Key Observation**: If M0 is non-pathological, is every reachable MCS non-pathological?

The answer is **unclear**. Lindenbaum completion is non-constructive and could create pathological MCS from non-pathological seeds.

### Feasibility Assessment

**LOW confidence** that scope restriction works directly.

However, there's a subtler approach:

**Completeness Only Needs Strictness for Specific Witnesses**

The completeness proof creates witnesses for specific formulas (not just `neg bot`):
- When `F(psi) in M`, witness N has `psi in N`
- If `psi notin M`, we have our distinguishing formula!

The seriality witnesses (`F(neg bot)`) are used only to establish NoMaxOrder/NoMinOrder for frame conditions. These frame conditions may not be needed for completeness itself.

## Confidence Level

**MEDIUM** - Per-construction strictness works for some sites but NOT for seriality-based sites.

**Key Insight**: The problem isn't per-construction strictness in general; it's that seriality provides a useless witness formula (`neg bot`).

## Recommendations

### Immediate Path Forward

1. **Accept that NoMaxOrder/NoMinOrder cannot be proven without axiom** for the full canonical frame
2. **Restrict scope**: The completeness proof may not need NoMaxOrder/NoMinOrder for the specific domain used
3. **Verify completeness structure**: Does completeness actually require strict successors, or just accessibility?

### Alternative Architectures

1. **Quotient by CanonicalR**: Factor out antisymmetric closure rather than assuming it
2. **Preorder completeness**: Reformulate completeness for preorders rather than partial orders
3. **Bounded frame conditions**: Prove frame conditions hold "locally" within a reachability closure

## References

| File | Lines | Description |
|------|-------|-------------|
| `Canonical/CanonicalSerialFrameInstance.lean` | 1-126 | NoMaxOrder/NoMinOrder instances |
| `Canonical/CanonicalTimeline.lean` | 93-128 | Seriality witnesses |
| `Bundle/CanonicalIrreflexivity.lean` | 458-516 | Per-construction strictness infrastructure |
| `Bundle/WitnessSeed.lean` | 47-79 | Forward temporal witness seed |
| `Canonical/ConstructiveFragment.lean` | 63-106 | executeForwardStep definition |
| Report 30 | full | MCS-decided atom blocker analysis |
