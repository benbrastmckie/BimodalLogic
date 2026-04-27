# Handoff: Task 107 Implementation (Session sess_1777267992_06a2c3)

## Session Context
- **Session ID**: sess_1777267992_06a2c3
- **Agent**: lean-implementation-agent
- **Plan**: specs/107_.../plans/30_implementation-plan.md (v17)
- **Phases Completed**: 1, 1.5, 2 (unchanged from prior session)
- **Phase 3**: IN PROGRESS (analysis only, no code changes)
- **Status**: Partial progress -- deep architectural analysis completed, root blocker identified

## Key Discovery: The Root Blocker is Seed Construction for burgessR3

All 4 sorry sites are interconnected through a single dependency chain:

```
C4 sorry (CounterexampleElimination.lean:332,448)
    -> limit_satisfies_c4 (ChronicleConstruction.lean:763)
    -> limit_forward_G (ChronicleConstruction.lean:1008)
    -> cantor_fmcs.forward_G (ChronicleToCountermodel.lean:243)
    -> cantor_bfmcs (everything depends on this)
    -> cantor_bfmcs_restricted_buc (also uses limit_satisfies_c4 at line 525)
    -> cantor_bfmcs_restricted_fuc (sorry sites at 615, 619)
```

### Why C4 Must Be Closed First

The C4 hard case (gamma in f(x), G(gamma) in f(x), gamma in f(y), H(gamma) in f(y)) cannot be bypassed:
1. **Circular via limit_forward_G**: The natural approach (derive G(delta.neg) at f(x), propagate to f(y) via forward_G, contradiction) is CIRCULAR because limit_forward_G depends on limit_satisfies_c4 which depends on the C4 sorry.
2. **BUC is also tainted**: cantor_bfmcs_restricted_buc uses limit_satisfies_c4 at line 525. So a limit_g-via-BUC approach is also circular.
3. **g_prop doesn't help**: g_prop elimination inserts new points but doesn't change f-values at existing points. It cannot prove limit_forward_G.

### Why C4 Requires BurgessR3Maximal g-Values

The C4 hard case resolution (Burgess's argument) is:
1. BurgessR3Maximal(f(x), g(x,y), f(y)) (from ChronicleInvariant c2')
2. burgessR3_gamma_not_in_B: gamma not in g(x,y) (proved sorry-free)
3. dcs_neg_insert_consistent: {gamma.neg} union g(x,y) consistent (proved sorry-free)
4. set_lindenbaum: MCS D with gamma.neg (standard)
5. f(z) = D for new point z

Step 1 requires g-values to be BurgessR3Maximal, which requires Phase 3 (populate g-values in elimination functions).

### The Seed Construction Problem (Phase 3 Blocker)

`burgessR3Maximal_extension_exists` takes a DCS seed S with burgessR3(A, S, C). The technical challenge: constructing such a seed.

**What doesn't work as a seed:**
- Empty set: not a DCS (not closed under derivation)
- Set of theorems (deductiveClosure({})): IS a DCS, but does NOT satisfy burgessR3 (untl(top, gamma) = F(gamma) might not be in A)
- g_content(f(x)) union h_content(f(y)): elements don't satisfy the Until condition of burgessR3 in general (G(beta) in f(x) does NOT give untl(beta, gamma) in f(x))
- f(x) ∩ f(y): consistent but might not be a DCS; intersection of two MCS isn't necessarily closed

**The kernel set**: K = {beta in A ∩ C : for all gamma in C, untl(beta, gamma) in A AND for all gamma in A, snce(beta, gamma) in C}
- Satisfies burgessR3(A, K, C) by definition
- Consistent (subset of A)
- NOT obviously a DCS (closure under derivation might break the burgessR3 condition)
- Can be EMPTY for incompatible MCS pairs

### Proposed Resolution Path

**Option A: Kernel + Zorn (most principled)**
1. Define K as above. If K is empty, it vacuously satisfies burgessR3.
2. Take deductiveClosure(K). Need to prove burgessR3 is preserved by deductive closure.
3. Apply burgessR3Maximal_extension_exists.
- ISSUE: Step 2 fails because deductive closure ADDS elements, and burgessR3 is anti-monotone in the second argument. More elements in B makes burgessRSet HARDER to satisfy.

**Option B: Seedless existence via direct Zorn (most practical)**
1. Apply Zorn to {B : SetDeductivelyClosed B AND burgessR3(A, B, C)}.
2. Need to prove this set is non-empty.
3. The EMPTY SET satisfies burgessR3 vacuously but is not a DCS.
4. Need a custom argument: start from empty, build UP to a DCS while preserving burgessR3.
- This amounts to a constructive Lindenbaum-style extension that adds formulas one at a time, checking burgessR3 at each step.

**Option C: Rethink the construction architecture entirely**
- Instead of maintaining ChronicleInvariant at finite stages, define everything at the LIMIT.
- Define limit_g(x,y) = intersection of all limit_f(w) for w between x and y.
- This satisfies C3 by construction and c3_interval_subset_point trivially.
- burgessR3 at the limit follows from BUC... but BUC is sorry-tainted. BLOCKED.
- UNLESS we can prove BUC independently of C4 (currently it uses limit_satisfies_c4).

**Option D: Prove BUC without C4 dependency**
- The BUC proof (cantor_bfmcs_restricted_buc, lines 495-584) uses limit_satisfies_c4 at line 525.
- If we can prove BUC by a DIFFERENT argument that doesn't use C4, the cycle breaks.
- BUC says: semantic Until pattern implies syntactic Until. The proof by contradiction: if untl(phi,psi) not in f(t), then neg(untl(phi,psi)) in f(t), and C4 gives a counterexample point. But we could prove this by DIRECT argument: from the semantic pattern, derive syntactic Until using temporal axioms.
- KEY INSIGHT: BUC might be provable using just the axioms of BX without C4. This would break the cycle.

## Recommended Next Steps for Successor Session

1. **Try Option D first**: Prove BUC (backward Until coherence) without using limit_satisfies_c4. If successful, this breaks the dependency cycle and enables:
   - Define limit_g as intersection of intermediate f-values
   - Derive burgessR3 from the new BUC
   - Close C4 at the limit using burgessR3
   - Prove FUC using rRelation propagation

2. **If Option D fails, try Option B**: Prove seedless BurgessR3Maximal existence by a custom Lindenbaum-style argument.

3. **If both fail**: The full Phase 3 (populating g-values at every finite stage) is needed. This is a large architectural change affecting all elimination functions.

## Active Sorry Sites (4, unchanged)

| File | Line | Description |
|------|------|-------------|
| CounterexampleElimination.lean | 332 | C4 hard case (Until) |
| CounterexampleElimination.lean | 448 | C4' hard case (Since) |
| ChronicleToCountermodel.lean | 615 | restricted_fuc Until |
| ChronicleToCountermodel.lean | 619 | restricted_fuc Since |

## Files NOT Modified in This Session

No code changes were made. This session was analysis-only.

## Build Status

`lake build` succeeds. No regressions. 4 active sorry sites unchanged.

## Critical Observations for Successor

1. **Do NOT use limit_forward_G to close C4** -- it IS circular (confirmed by dependency trace)
2. **Do NOT use BUC to derive burgessR3 at the limit** -- BUC also depends on C4 (line 525)
3. **The C4 proof in the EASY cases is fine** -- only the hard sub-case (gamma in both endpoints, G(gamma), H(gamma)) has the sorry
4. **Non-adjacent pairs in the hard case**: at finite stages, the hard case CAN arise for non-adjacent pairs. It cannot be resolved by reducing to adjacent sub-pairs because neg(untl(gamma, delta)) is at f(x) but the sub-pair's right endpoint might not have delta.
5. **gamma can be a theorem**: In the hard case, gamma might be a tautology, making {gamma.neg} inconsistent. This is a real scenario (gamma = top) that must be handled.
6. **The BUC-independent proof is the most promising path**: If BUC can be proved without C4, the entire dependency cycle breaks.
