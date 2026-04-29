# Teammate D Findings: Strategic Assessment and Alternative Paths

**Task 107**: Burgess chronicle construction -- A4a blocker strategic assessment
**Date**: 2026-04-28
**Focus**: Full impact mapping of A4a (BX axiom A4a), alternative paths, Lemma 2.6 decomposition analysis

---

## 1. Key Findings

### 1.1 Full Impact Mapping of Lemma 2.6

Lemma 2.6 is the three-way splitting lemma: given R(A, B, C) and delta not in B, produce B', D, B'' with neg delta in D, R(A, B', D), R(D, B'', C), B = B' inter D inter B''.

**Sorry sites that depend on Lemma 2.6 (or its role)**:

The codebase does NOT currently use a formalized Lemma 2.6 -- the sorry sites are in c2' fields of `EliminationResult` where g-values for new adjacent pairs are never constructed. However, Lemma 2.6 splitting is the PLANNED mechanism to close them (plan v27, phases 6-12). The dependency is:

**C4 cases (4 sorry sites, lines 908, 946, 982, 1014 in CounterexampleElimination.lean)**:
- C4 forward (line 908): inserting z between x and y to negate guard. New adjacent pairs (x,z) and (z,y) need g-values. Lemma 2.6 applied to the existing R(f(x), g(x,y), f(y)) with delta = xi.neg (since xi.neg in f(z)) would produce the needed B', D, B''.
- C4 backward (line 946): mirror of above for Since.
- g_prop forward (line 982): G-propagation counterexample insertion. New adjacent pair needs g-value.
- g_prop backward (line 1014): mirror for H-propagation.

**Density case (1 sorry site, line 1130 in CounterexampleElimination.lean)**:
- The density case inserts z = (x+y)/2 with f(z) = f(x). Plan v27 identifies that this creates a self-pair BurgessR3Maximal(A, B, A) which is provably impossible under irreflexive semantics. The fix: use Lemma 2.6 splitting instead of f-value copying. This is a qualitatively different use of Lemma 2.6 -- the splitting produces a fresh MCS D (not a copy of f(x)).

**C5 cases (2 sorry sites, lines 830, 868 in CounterexampleElimination.lean)**:
- C5 forward (line 830): After inserting Until witness y via `eliminate_C5_counterexample`, new adjacent pairs need g-values. For n=0 (x is domain maximum), `burgessR3Maximal_from_g_content_sub` (sorry-free, RRelation.lean:1472) works directly. For n>0, Burgess's Lemma 2.10 case analysis requires Lemma 2.7 (a specialization of Lemma 2.6 for Until formulas).
- C5 backward (line 868): mirror for Since.

**FUC/FSC (2 sorry sites, lines 615, 619 in ChronicleToCountermodel.lean)**:
- These need the guard at intermediate points: U(phi,psi) in f(t) requires phi in f(r) for t < r < s_wit. The blocker is that `limit_satisfies_c5_weak` provides only the endpoint witness, not the guard. Full C5 with guard (`limit_satisfies_c5_full`) would give the guard, but proving it requires that the omega-chain carries correct g-values (which requires closing the 7 CE sorries first).

**Summary**: 7 of 9 sorry sites depend on Lemma 2.6 or its relatives (2.7). The 2 FUC/FSC sites depend on those 7 transitively.

### 1.2 Sorry Sites NOT Depending on Lemma 2.6

**None of the 9 chronicle sorry sites are independent of the g-construction problem.** All trace back to the single root cause: point insertion functions produce endpoints (MCS) but not interval values (DCS).

However, the FUC/FSC sorry sites (ChronicleToCountermodel.lean:615,619) could POTENTIALLY be closed by an alternative route that bypasses g-values entirely -- see Section 2.3 below.

### 1.3 Could Non-Lemma-2.6 Sites Be Closed First?

The FUC/FSC sites (2 sorries) could theoretically be closed without Lemma 2.6 IF a direct proof of the guard property at intermediate points could be constructed from C4 alone. The current `cantor_bfmcs_restricted_buc` (backward Until/Since coherence) IS sorry-free and works by contradiction via C4: if neg(U) at t and psi at s_wit, C4 gives z between them with neg(phi) at z, contradicting the guard hypothesis.

The FUC direction is harder: given U(phi,psi) in f(t), we need to PRODUCE s_wit with psi in f(s_wit) AND phi in f(r) for all intermediate r. The endpoint s_wit comes from `limit_satisfies_c5_weak`. The guard comes from either:
- (a) Full C5 with g-values (the standard path, requires closing 7 CE sorries), or
- (b) A semantic argument using C4 as a contrapositive filter (see Section 2.3).

**Verdict**: Option (b) is worth investigating as a potential partial win, but it requires a non-trivial semantic argument that may not work.

---

## 2. Strategic Assessment

### 2.1 Burgess 1982 Lemma 2.6: Full Consistency Argument Analysis

**Statement**: Given R(A, B, C) and delta not in B, produce B', D, B'' with neg delta in D, R(A, B', D), R(D, B'', C), B = B' inter D inter B''.

**The Proof**: Burgess constructs the seed:
```
D0 = {S(alpha, beta) : alpha in A, beta in B}
     union B
     union {neg delta}
     union {U(gamma, beta) : gamma in C, beta in B}
```

Then proves D0 is consistent by showing each conjunction
```
zeta = S(alpha, beta) AND beta AND neg(delta) AND U(gamma, beta)
```
is consistent (for alpha in A, beta in B, gamma in C).

**A4a is used EXACTLY ONCE**: In the consistency argument for zeta. The key chain is:

1. By R-maximality of B: since delta not in B, there exist beta0 in B, gamma0 in C with neg U(gamma0, beta0 AND delta) in A.
2. WLOG beta = beta0, gamma = gamma0 (by replacement).
3. U(gamma, beta) in A (from r(A, B, C)) gives U(gamma, beta AND U(gamma, beta)) in A via A5a (BX5).
4. **A4a applied**: From U(gamma, beta) and neg U(gamma, beta AND delta), both in A, A4a gives U(beta AND U(gamma, beta) AND neg(delta), beta) in A.
5. A3a then adds S(alpha, beta) into the first argument of Until.
6. Consistency criterion (Lemma 2.2) gives consistency of zeta.

**Could a WEAKER version of A4a suffice?**

A4a states: `U(p, q) AND neg U(p, r) -> U(q AND neg r, q)`.

The proof uses A4a with p = gamma, q = beta, r = beta AND delta. The conclusion is U(beta AND neg(beta AND delta), beta) in A, which (since beta AND neg(beta AND delta) = beta AND neg(delta) by DCS closure) gives U(beta AND neg delta, beta) in A.

The key algebraic content of A4a is: if U(p,q) holds but U(p,r) fails, then the guard q continues holding, and the failure of r can be witnessed at intermediate points where q AND neg r holds. This is specific to the interaction between Until and its refinements.

**Under the codebase's axiom system**: A4a itself is NOT an axiom (it is Burgess's axiom, not a BX axiom). However, plan v27 notes that BX5 (self_accum_until) + BX7 (linear_until) + BX6 (absorb_until) provide equivalent algebraic content. Specifically:

- BX5: `(p U q) -> ((p AND (p U q)) U q)` -- enriches the guard with the Until formula itself
- BX7: `(p U q) AND (r U s) -> (p AND r) U (q AND s) OR (p AND s) U (q AND s) OR (q AND r) U (q AND s)` -- linearity disjunction
- BX6: `(p U (p AND (p U q))) -> (p U q)` -- absorption

The combination of BX5+BX7 provides the disjunctive case analysis that A4a provides monolithically. BX6 prevents infinite self-accumulation. This is exactly the approach used in the codebase for the BX4 nested case resolution (Phase 4 of plan v24, completed).

### 2.2 The "g_content Bridge" Approach

**Proposed approach**: For Lemma 2.6 splitting, start with R(A, B, C) and delta not in B. Instead of Burgess's D0 seed, use:
1. `lemma_2_4` on A with some Until formula to get an intermediate D'
2. `burgessR3Maximal_from_g_content_sub` on (A, D') and (D', C) to get B' and B''

**Analysis**: This approach DOES NOT WORK in general. The problem:

- `lemma_2_4` requires an Until formula U(gamma, beta) in A. It produces C (MCS) with beta in C and g_content(A) subset C.
- For the splitting to work, we need neg(delta) in D'. `lemma_2_4` gives no control over whether neg(delta) is in the produced MCS -- the Lindenbaum extension is via `Classical.choose` and is opaque.
- `burgessR3Maximal_from_g_content_sub` requires g_content(A) subset D'. `lemma_2_4` provides this. BUT it also requires g_content(D') subset C (for the (D', B'', C) pair). This requires g_content chain transitivity, which `lemma_2_5b` (sorry-free) provides only if we also have g_content(D') subset C -- which is NOT guaranteed by `lemma_2_4`.

**The g_content chain A -> D' -> C is NOT achievable in general** without controlling D' precisely. The whole point of Lemma 2.6 is that D0 is constructed with BOTH directional r-relations (Until from A and Since from C) baked into the seed. The g_content bridge approach loses the Since direction.

**Verdict**: The g_content bridge approach is a dead end for the general case. It may work for special cases (e.g., C4 insertion where the existing R-maximality provides structure), but it cannot replace Lemma 2.6 in general.

### 2.3 FUC/FSC Alternative: C4 Contrapositive Guard

**Observation**: The backward Until/Since coherence (`cantor_bfmcs_restricted_buc`) is proved sorry-free using C4's contrapositive. Could a similar approach work for the FORWARD direction?

**Forward Until coherence needs**: Given U(phi, psi) in f(t), produce s_wit > t with psi in f(s_wit) and phi in f(r) for all t < r < s_wit.

**Attempt**: `limit_satisfies_c5_weak` gives y in limit_dom with t < y and eta in f(y) (the endpoint). For the guard, consider: if phi is NOT in f(r) for some t < r < y, then phi.neg in f(r) (by MCS negation completeness). But also U(phi, psi) in f(t), so by BX5, (phi AND U(phi,psi)) U psi in f(t). By forward_G propagation, we get U(phi, psi) in f(r') for some r' between t and r... but this does NOT directly give phi in f(r).

**The core problem**: The forward direction requires CONSTRUCTING the witness and guard, while the backward direction only requires VERIFYING (by contradiction) that a given witness/guard pattern implies the formula membership. Construction is strictly harder than verification.

**However**: There IS a potential path. If we can show that for U(phi, psi) in f(t):
1. `limit_satisfies_c5_weak` gives y with psi in f(y) and t < y
2. For any r with t < r < y: by BX5, f(t) contains U(phi AND U(phi,psi), psi)
3. By forward_G from f(t) to f(r): G(P(U(phi,psi))) in f(t) (BX4), so P(U(phi,psi)) in f(r)
4. This does NOT give phi in f(r) directly

**Dead end**: The forward guard requires phi in f(r), which is a specific atomic-level claim about the MCS at r. No BX axiom lets us extract phi from U(phi,psi) at an intermediate point under open guard semantics (BX9 removed). The guard information lives in the g-values (C3: g(t,y) subset f(r)), which is exactly what the 7 CE sorries provide.

**Verdict**: FUC/FSC cannot be closed independently of the 7 CE sorries. All 9 sorry sites must be addressed together.

### 2.4 Can Lemma 2.6 Be Decomposed?

**Proposed decomposition**: Instead of producing (B', D, B'') simultaneously, produce D first (using simpler methods), then construct B' and B'' separately using `burgessR3Maximal_from_g_content_sub`.

**Requirements for D**:
- SetMaximalConsistent D
- neg(delta) in D
- g_content(A) subset D (for B' via `burgessR3Maximal_from_g_content_sub(A, D)`)
- g_content(D) subset C (for B'' via `burgessR3Maximal_from_g_content_sub(D, C)` -- but this needs h_content(C) subset D direction too)

**Problem**: `burgessR3Maximal_from_g_content_sub` requires g_content(A) subset C. For (A, B', D), we need g_content(A) subset D. This is achievable -- `lemma_2_6` (the existing codebase version, PointInsertion.lean:244) already produces D with neg(delta) in D and g_content(A) subset D. So step 1 (produce D) is ALREADY DONE.

For (D, B'', C), we need g_content(D) subset C. This is NOT guaranteed by the existing `lemma_2_6`. The question is whether it can be made so.

**Chain feasibility**: g_content(A) subset D (from `lemma_2_6`) plus g_content(D) subset C would give the g_content chain. But g_content(D) subset C requires that for all phi, G(phi) in D implies phi in C. Since D is an opaque Lindenbaum extension of {neg delta} union g_content(A), we have no control over which G-formulas end up in D beyond those from g_content(A).

**Existing infrastructure check**: The codebase's `lemma_2_6` (PointInsertion.lean:244-259) produces D with:
- SetMaximalConsistent D
- neg(delta) in D
- g_content(A) subset D

It does NOT produce g_content(D) subset C. And `lemma_2_6_strong` (the version that would give g_content(D) subset C) is marked FALSE under strict semantics (PointInsertion.lean:263).

**Conclusion**: Lemma 2.6 CANNOT be fully decomposed in the proposed way. The Burgess construction intrinsically requires the D0 seed to include BOTH:
- {S(alpha, beta) : alpha in A, beta in B} (linking to A)
- {U(gamma, beta) : gamma in C, beta in B} (linking to C)

This bidirectional seed is what ensures D has the right properties for BOTH B' and B''. Separating the construction loses the Since direction.

**The correct approach is to formalize Burgess's full D0 seed construction using BX5+BX7+BX6 in place of A4a.** This is exactly what plan v27 proposes in phases 6-8.

---

## 3. ROADMAP Criticality

From `specs/ROADMAP.md`:

- Lemma 2.6 (and its relatives 2.7, 2.8) is THE critical path for the chronicle completeness.
- The chronicle is THE primary completeness path (BXCanonical is secondary, blocked by Lindenbaum opacity).
- Closing all 9 chronicle sorry sites achieves the representation theorem goal: "TM is complete with respect to TaskFrames over totally ordered abelian groups."
- The representation theorem is the STATED ROADMAP goal.
- Once chronicle sorries are closed, task 95 (#print axioms audit) can verify sorryAx elimination.

**Lemma 2.6 is on the sole critical path from the current state to the representation theorem.**

---

## 4. Recommended Approach

### 4.1 Primary Strategy: Full Burgess Alignment (Plan v27, Strategy 1)

Implement Lemma 2.6 using BX5+BX7+BX6 in place of A4a. This requires:

1. **Phase 5 (GATE)**: Verify Lemma 2.7 validity under strict/open-guard semantics.
   - Lemma 2.7 uses BX5 (self_accum), BX7 (linear_until), and BX13 (enrichment_until/A3a).
   - All three are in the axiom system and valid under irreflexive semantics.
   - The Phase 5 gate should take 2-4 hours (proof sketch + consistency check).

2. **Phase 6**: Formalize Lemma 2.6 full splitting with BurgessR3Maximal output.
   - Adapt the Burgess D0 seed to use BX5+BX7+BX6 instead of A4a.
   - The key proof obligation: consistency of the Burgess conjunction zeta.
   - Estimated 6-10 hours (most complex phase).

3. **Phases 7-12**: Close sorry sites case by case using the splitting infrastructure.
   - Each sorry site is a specific application of Lemma 2.6 or 2.7.
   - Density: Lemma 2.6 splitting instead of self-pair.
   - C4: Lemma 2.6 splitting on the existing R-maximal pair.
   - C5 n=0: `burgessR3Maximal_from_g_content_sub` (already available).
   - C5 n>0: Lemma 2.7 + recursive reduction.
   - FUC/FSC: thread g-values through Cantor isomorphism.

### 4.2 Fallback: Strategy 2 (Remove c2' from Finite Stages)

If Lemma 2.7 fails the Phase 5 gate:
- Remove c2' from `EliminationResult` (CounterexampleElimination.lean).
- Construct g-values at the limit only (limit domain is dense, no adjacent pairs).
- This simplifies the 7 CE sorry sites to vacuous truth.
- The 2 FUC/FSC sites would need a different proof of the guard property.
- Risk: the guard proof at the limit is non-trivial and may require novel infrastructure.

---

## 5. Remaining Work Estimates

| Component | Effort | Confidence |
|-----------|--------|------------|
| Phase 5 gate (Lemma 2.7 verification) | 2-4 hours | 80% will pass |
| Lemma 2.6 formalization (BX5+BX7+BX6 for A4a) | 6-10 hours | 75% |
| Lemma 2.7 formalization | 4-6 hours | 75% (if gate passes) |
| C4/g_prop/h_prop sorry closure | 4-6 hours | 85% (mechanical) |
| C5 n=0 sorry closure | 2-3 hours | 90% (infrastructure exists) |
| C5 n>0 sorry closure | 4-8 hours | 70% (recursive case analysis) |
| Density sorry closure | 2-4 hours | 80% |
| FUC/FSC sorry closure | 4-8 hours | 65% (Cantor threading) |
| **Total** | **28-49 hours** | **70% overall** |

---

## 6. Confidence Level

**Overall confidence**: 70% that Strategy 1 (full Burgess alignment) succeeds.

**Breakdown**:
- 80% that Lemma 2.7 is valid under strict/open-guard semantics (BX5+BX7+BX13 are all available)
- 75% that BX5+BX7+BX6 can fully substitute for A4a in Lemma 2.6
- 85% that once the splitting infrastructure is in place, the sorry sites close mechanically
- 65% that FUC/FSC can be threaded through the Cantor isomorphism without new blockers

**Key risk**: The BX5+BX7+BX6 substitution for A4a in Lemma 2.6 is the most uncertain step. If the algebraic content of A4a cannot be fully recovered from these three axioms, the consistency proof for the Burgess conjunction zeta may fail, and Strategy 2 becomes necessary.

---

## References

- Burgess 1982, Section 2, Lemmas 2.4-2.8 (`literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`)
- `PointInsertion.lean`: `lemma_2_4` (sorry-free), `lemma_2_6` (weak version, sorry-free), `lemma_2_6_strong` (FALSE)
- `RRelation.lean:1472-1499`: `burgessR3Maximal_from_g_content_sub` (sorry-free)
- `CounterexampleElimination.lean`: 7 c2' sorry sites (lines 830, 868, 908, 946, 982, 1014, 1130)
- `ChronicleToCountermodel.lean`: 2 FUC/FSC sorry sites (lines 615, 619)
- Plan v27 (`plans/43_implementation-plan.md`)
- Report 43 (`reports/43_team-research.md`)
