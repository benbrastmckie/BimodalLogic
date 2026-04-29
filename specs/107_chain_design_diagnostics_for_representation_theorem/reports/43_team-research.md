# Research Report: Task #107 -- g_content Ordering Blocker Resolution

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-28
**Mode**: Team Research (4 teammates)
**Session**: sess_1777433619_e48da8

## Summary

The g_content ordering blocker has two root causes: (1) C5 elimination places new points at the domain boundary instead of adjacent to the counterexample point x (Burgess's actual approach), and (2) the density case creates a self-pair f(z) = f(x) for which `BurgessR3Maximal(A, B, A)` is provably impossible under irreflexive semantics. The teammates identify two viable resolution strategies with a critical unresolved conflict between them.

**Strategy 1 (Full Burgess alignment)**: Restructure `lemma_2_4` to return (B, C) and formalize `lemma_2_6` to return (B', D, B''). Maintain c2' at finite stages. Risk: Lemma 2.8 (needed for C5 n>0 sub-case 3) may be false under strict semantics.

**Strategy 2 (Remove c2' from finite stages)**: Remove c2' from `EliminationResult`. Construct g-values at the limit only. Aligns with how Burgess's c2' is vacuously true at the limit. Risk: Limit g-construction needs redesign; `restricted_fuc` guard proof becomes harder.

## Key Findings

### 1. Burgess Places Points Adjacent to x, Not at Domain Boundary (Teammate A, unanimous)

Burgess's Lemma 2.10 (C5 elimination) has a case analysis on n (points after x in domain):
- **n = 0** (x is max): Place y after x. Use Lemma 2.4. Current code handles this correctly.
- **n > 0** (x is not max): Let x' = immediate successor of x. Three sub-cases:
  1. If U(xi,eta) and eta propagate to x': reduce to n-1 (recurse forward)
  2. If xi in f(x') and eta in g(x,x'): x' is already a witness (impossible for counterexample)
  3. Otherwise: insert z = (x+x')/2 between x and x' using **Lemma 2.7 or 2.8** splitting

The current code implements ONLY n=0 (`exists_rat_gt_finset` places y after ALL points). This is the root cause of the g_content ordering failure: the new pair is (x_max, y) but g_content inclusion holds for x, not x_max.

### 2. Density Self-Pair Is Provably Impossible (Teammates B, C, unanimous)

`BurgessR3Maximal(A, B, A)` requires `burgessR(A, eta, A)` for some seed eta, which requires `F(gamma) in A` for ALL gamma in A. Under irreflexive semantics, if `G(phi) in A` but `phi not in A` (valid since T-axiom fails), then gamma = neg(phi) in A but `F(neg(phi)) in A` iff `G(phi) not in A` — contradiction. Therefore:

**No DCS B can satisfy `burgessR3(A, B, A)` when A contains `G(phi)` with `phi not in A`**, which is the generic case under irreflexive semantics.

The current density elimination sets `f(z) = f(x)` (line 1046), creating this impossible self-pair. Burgess never duplicates f-values — his construction always produces distinct MCS.

### 3. The C5 n>0 Case Requires Lemma 2.7/2.8 (Teammate A)

Sub-case 3 of C5 n>0 splits the existing `R(f(x), g(x,x'), f(x'))` via Lemma 2.7 or 2.8 to insert z between x and x'. This produces B', D, B'' with `R(f(x), B', D)` and `R(D, B'', f(x'))` — c2' follows automatically.

**Critical risk flagged by Teammate C**: Lemma 2.8 may be marked FALSE under strict/open-guard semantics in the codebase. If true, sub-case 3 might be partially blocked. However, the BX6 absorption argument (Phase 4, already completed) may substitute for Lemma 2.8's role in the nested case.

### 4. `burgessR3Maximal_from_g_content_sub` Works for C5 n=0 (Teammate B)

For the n=0 case (x is max): `lemma_2_4` produces C with `g_content(f(x)) <= C`. Chain this into `burgessR3Maximal_from_g_content_sub` to get B. No new infrastructure needed for this case.

### 5. All 9 Sorry Sites Trace to Single Root Cause (Teammate D)

The codebase's point insertion functions (Lemma 2.4, 2.6) produce only the endpoint MCS, not the interval DCS. Burgess co-constructs (f, g) pairs together. The codebase separates them, producing MCS first and attempting to reconstruct DCS afterward (which requires sorry). A unified fix restructuring the insertion functions resolves all 9 sorry sites.

## Synthesis

### Critical Conflict: Strategy 1 vs Strategy 2

**Strategy 1 (Teammates A, D)**: Full Burgess alignment — restructure `lemma_2_4` to return (B, C), formalize `lemma_2_6` splitting, maintain c2' at finite stages.

**Strategy 2 (Teammate C)**: Remove c2' from `EliminationResult` — Burgess's c2' is vacuously true at the limit (dense domain), so maintaining it at finite stages is over-specification.

**Resolution**: These strategies are NOT mutually exclusive. The key question is: **can c2' be maintained at finite stages under strict/open-guard semantics?**

- If Lemma 2.7 is available (not false under strict semantics), Strategy 1 works for the n>0 sub-case 3. The BX6 argument may handle the Lemma 2.8 sub-case.
- If Lemma 2.7 is ALSO problematic under strict semantics, Strategy 2 becomes necessary.

**Recommendation**: Investigate whether Lemma 2.7 is valid under strict semantics before committing. Lemma 2.7 uses A7a (BX7 linearity) and A5a (BX5 self-accumulation), which ARE in the axiom system. Lemma 2.8 uses a different argument that may require A3a (invalid under strict semantics). If 2.7 works but 2.8 doesn't, the BX6 absorption (already proved) can handle the sub-case that would use 2.8.

### Density Resolution (Unanimous)

The density case must be restructured to NOT create self-pairs. Three options:

1. **Construct fresh MCS** for density midpoints instead of copying f(x). Use `lemma_2_4` with an appropriate Until formula from f(x) to produce a distinct D with `g_content(f(x)) <= D`.
2. **Use Lemma 2.6 splitting** on the existing R(f(x), g(x,y), f(y)) to produce an intermediate D with proper g-values (Teammate A's finding).
3. **Remove c2' requirement for density** from `EliminationResult` (if adopting Strategy 2).

Option 2 is most aligned with Burgess and most robust. The density case is just a C4-like insertion (splitting an adjacent pair), not a novel operation.

### Recommended Path Forward

1. **Verify Lemma 2.7 validity** under strict semantics (check if the BX axioms suffice)
2. **If valid**: Adopt Strategy 1 (full Burgess alignment) with density handled via Lemma 2.6 splitting
3. **If invalid**: Adopt Strategy 2 (remove c2' from finite stages) with limit g-construction redesign
4. **Either way**: Restructure density to use splitting (not self-pair)
5. **Either way**: Restructure `lemma_2_4` to return (B, C) pair

### Remaining Work

| Strategy | Lines Changed | Effort | Risk |
|----------|--------------|--------|------|
| Strategy 1 (full alignment) | 360-500 | 3-5 days | Medium (Lemma 2.7 validity) |
| Strategy 2 (remove c2') | 200-400 | 3-5 days | Medium (limit g-construction) |

Both strategies require similar effort. Strategy 1 is more correct (follows Burgess exactly) but has the Lemma 2.7/2.8 risk. Strategy 2 is structurally simpler but requires proving the guard at the limit without finite-stage g-values.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Burgess point placement | completed | high | Traced exact n>0 case structure; density is splitting not self-pair |
| B | Alternative g-value approaches | completed | high (C5), low (density) | Confirmed g_content works for C5 n=0; density self-pair impossible |
| C | Critic | completed | high | Options B,D impossible; flagged Lemma 2.8 risk; advocated Strategy 2 |
| D | Strategic horizons | completed | high (90%) | Full dependency chain; unified fix architecture; 360-500 lines estimate |

## References

- Burgess 1982, Lemma 2.10 (C5 elimination case analysis)
- Xu 1988, Lemma 2.6 (C5 elimination with splitting)
- `burgessR3Maximal_from_g_content_sub` (RRelation.lean:1472-1499) — sorry-free
- Handoff: `specs/107_.../handoffs/01_phase5-g-content-ordering.md`
- CounterexampleElimination.lean: 7 c2' sorries + 1 density sorry
- ChronicleToCountermodel.lean: 2 FUC/FSC sorries
