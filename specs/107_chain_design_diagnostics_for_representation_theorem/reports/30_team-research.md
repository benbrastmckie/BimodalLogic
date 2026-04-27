# Research Report: Task #107 — r-Relation Gap and Burgess-Faithful Architecture

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-26
**Mode**: Team Research (4 teammates)
**Session**: sess_1777263459_9b9e00

## Summary

Four teammates confirmed: the codebase's `rRelation` (obligation propagation: A → B) and Burgess's `r(A, B, C)` (content-based: B × C → A) are **genuinely different relations**. R3Maximal does NOT imply Burgess's property. The C4 hard case requires `burgessR3` to derive "gamma ∉ g(x,y)." The codebase already has `burgessR`, `burgessRSet`, `burgessR3`, and `burgessR3_absorption` proved sorry-free — the infrastructure exists. The correct path is to adopt `burgessR3` as the primary chronicle relation, matching Burgess exactly.

## Key Findings

### 1. The r-Relation Gap Is Real (Unanimous: A, B, C, D)

| Property | Burgess r(A, B, C) | Codebase r3Relation(A, B, C) |
|----------|---------------------|-------------------------------|
| Direction | B × C → A (content) | A → B (obligation) |
| Monotonicity in B | Anti-monotone | Monotone |
| R-maximality forces | Genuinely maximal DCS | MCS (via monotonicity collapse) |
| gamma ∈ B + δ ∈ C | Forces untl(γ,δ) ∈ A | No constraint |

The codebase's `rRelation(A, B)` says: "for untl(γ,δ) ∈ A, δ ∈ B or (γ ∈ B and untl(γ,δ) ∈ B)." Burgess's `r(A, β, C)` says: "for all γ ∈ C, untl(β, γ) ∈ A." These are independent properties — neither implies the other in general.

### 2. burgessR3 Infrastructure Already Exists (A confirmed)

The codebase already contains (all sorry-free in RRelation.lean):
- `burgessR(A, beta, C)` — single-formula Burgess relation
- `burgessRSet(A, B, C)` — set-level
- `burgessR3(A, B, C)` — combined Until + Since
- `burgessR3_absorption` — Lemma 2.5 absorption theorem

### 3. The C4 Hard Case Resolution via burgessR3 (A, C confirmed)

Given BurgessR3Maximal(f(x), g(x,y), f(y)):
1. If γ ∈ g(x,y), then by burgessRSet: for δ ∈ f(y), untl(γ,δ) ∈ f(x)
2. But neg(untl(γ,δ)) ∈ f(x) — contradiction with MCS
3. Therefore γ ∉ g(x,y), so γ.neg ∈ g(x,y) (MCS negation completeness)
4. By C3: γ.neg ∈ f(z) for intermediate z — C4 witness found

### 4. Teammate B's limit_forward_G Approach Is CIRCULAR (Resolved Conflict)

**Conflict**: Teammate B proposed closing the C4 hard case at the limit using `limit_forward_G` + `c4_hard_case_G_neg_delta`, claiming no definition changes needed.

**Resolution**: This approach is **circular**. I verified the dependency chain:
- `limit_forward_G` (line 1011) calls `limit_satisfies_c4` (line 1063)
- `limit_satisfies_c4` (line 766) calls `omega_chain_c4_witness` → `eliminate_C4_counterexample`
- `eliminate_C4_counterexample` has the sorry at line 334

`limit_forward_G` is sorry-tainted through this chain. It cannot be used to close the sorry it depends on. Teammate B's claim that `limit_forward_G` is "proved sorry-free" is incorrect.

**However**: Once C4 is properly proved at finite stages (via burgessR3 + populated g-values), `limit_forward_G` becomes clean automatically — it's a correct CONSEQUENCE, just currently blocked by the upstream sorry.

### 5. Cruft Audit (C confirmed)

Items to delete:
- `g_ordered` / `h_ordered` (ChronicleTypes.lean:449-473) — deprecated, unused
- `claim_2_11` — proves `φ ∈ f(x) ↔ φ ∈ f(x)` (tautological stub)
- Stale "Phase 2" comments in PointInsertion.lean and CounterexampleElimination.lean
- `g_content_chain_property` stale comment reference
- The vacuous `g := fun _ _ => ∅` in `singleton_chronicle` must be replaced with actual construction

Items to keep:
- `g_agrees` on EliminationResult — correct approach for tracking g preservation
- `burgessR3` infrastructure — this is the right foundation

### 6. Lemma 2.7/2.8 Risk Under Strict Semantics (D identified)

Burgess's Lemmas 2.7 and 2.8 (guard propagation for C5, case n>0) use A3a, which is INVALID under strict/irreflexive semantics. This blocks the inductive case of C5 elimination for inserting between existing points.

**Mitigation**: The C5 case n=0 (adding after all points) works with `until_guard`. The omega chain can be restructured to only add points after existing ones. This is how the current code works — it always extends at the ends. The C5 n>0 case is needed only if we insert BETWEEN existing points, which the current construction avoids.

### 7. Burgess's Complete Lemma Map (D produced)

| Burgess | Codebase Status | Needed for C4/fuc closure |
|---------|-----------------|---------------------------|
| Def 2.1 (DCS) | COMPLETE | Yes |
| Lemma 2.3 (r-relation) | PARTIAL (burgessR3 exists, not primary) | Yes |
| Lemma 2.4 (endpoint) | PRESENT (adapted) | Yes (C5) |
| Def 2.5 (R-maximality) | NEEDS REDO (wrong relation) | Yes |
| Lemma 2.5 (absorption) | PRESENT (burgessR3_absorption) | Yes (C3) |
| Lemma 2.6 (splitting) | NEEDS REDO (use burgessR3 maximality) | Yes (C4) |
| Lemma 2.9 (C4 elim) | SORRY (hard case) | Yes |
| Lemma 2.10 (C5 elim, n=0) | PRESENT | Yes |
| Claim 2.11 (truth) | STUB | Yes (final goal) |

## Synthesis

### Recommended Architecture: Adopt burgessR3 as Primary

1. **Define BurgessR3Maximal**: `SetDeductivelyClosed B ∧ burgessR3(A, B, C) ∧ ∀ D, SDC D → B ⊂ D → ¬burgessR3(A, D, C)`
   - Note: burgessR3 is ANTI-monotone, so maximality does NOT collapse to MCS. This is correct — Burgess's R-maximal sets need not be MCS (they are proved to be MCS by a separate argument using the maximality failure witness).

2. **Prove BurgessR3Maximal existence**: Seed with `deductiveClosure(g_content(f(x)) ∪ h_content(f(y)))`. Chain union preserves burgessR3 (straightforward). Seed satisfies burgessR3 because g_content elements serve as valid guards by construction.

3. **Replace R3Maximal with BurgessR3Maximal in ChronicleInvariant c2'**

4. **Reprove lemma_2_6 using BurgessR3Maximal**: The maximality failure witness gives the C4 contradiction.

5. **Populate g-values**: Each elimination step constructs BurgessR3Maximal interval sets.

6. **Delete cruft**: g_ordered, claim_2_11, stale comments, vacuous g-function.

7. **Keep rRelation as derived property**: Derive `r3Relation(A, B, C)` from `burgessR3(A, B, C)` when needed for existing lemmas. Do NOT delete rRelation — some existing sorry-free code uses it.

### What NOT to Do

- Do NOT use `limit_forward_G` to close C4 (circular)
- Do NOT add density axioms (wrong for BX)
- Do NOT try to prove R3Maximal implies burgessR3 (false in general)
- Do NOT restructure `limit_satisfies_c4` to bypass finite-stage C4 (the finite-stage proof is the correct architecture per Burgess)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary: r-relation correspondence | completed | high | Definitive proof that relations differ, mapped existing burgessR3 infrastructure |
| B | Alternatives: refactoring options | completed | medium | Thorough option analysis; limit_forward_G approach is CIRCULAR (resolved) |
| C | Critic: validate gap + cruft audit | completed | high | Confirmed gap, identified seed strategy, comprehensive cruft list |
| D | Horizons: Burgess-faithful architecture | completed | high | Complete Burgess lemma map, A3a/strict semantics risk, target architecture |

## References

- Burgess, J.P., 1982, "Axioms for tense logic. I. 'Since' and 'Until'", Notre Dame J. Formal Logic 23(4): 367-374.
- Burgess, J.P., 1984, "Basic Tense Logic", Handbook of Philosophical Logic Vol. II.
