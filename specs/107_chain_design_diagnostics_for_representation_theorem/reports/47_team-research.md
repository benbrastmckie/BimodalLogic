# Research Report: Task #107

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-29
**Session**: sess_1777502965_7c0e6e
**Mode**: Team Research (4 teammates)
**Type**: lean4

## Summary

Team research resolves three implementation blockers by returning to the primary sources (Burgess 1982, Xu 1988). All four teammates converge on two critical findings: (1) Phase 6's Lemma 2.7 proof uses the wrong strategy — Burgess's actual proof is a single seed consistency argument, not a case split on `{eta}∪B` consistency; (2) Phases 8-9's `h_gc` blocker is structural and cannot be patched — the recommended fix is Option B (remove `c2'` from `EliminationResult`), aligning with Burgess's design where c2' is vacuously true at the limit. A plan revision (v33) is needed before the next implementation session.

## Key Findings

### 1. Phase 6: Lemma 2.7 Uses the Wrong Proof Strategy (Unanimous: A, B, C)

**The current formalization's approach** (case split on `{eta}∪B` consistency, then BX7 three-way disjunction with guard `alpha∧eta.neg`) **is not Burgess's proof and should be discarded.**

**Burgess's actual proof** (1982, p. 371) is a single unified seed consistency argument:

1. From `eta ∉ B` and maximality of B: obtain `beta₀ ∈ B`, `gamma₀ ∈ C` with `¬U(gamma₀, beta₀∧eta) ∈ A`
2. Construct seed: `D₀ = {S(alpha, beta∧eta) : alpha ∈ A, beta ∈ B} ∪ B ∪ {xi} ∪ {U(gamma, beta) : gamma ∈ C, beta ∈ B}`
3. Prove each conjunction `zeta = S(alpha, beta∧eta) ∧ beta ∧ xi ∧ U(gamma, beta)` is consistent:
   - A5a (BX5) twice: `U(gamma, beta∧U(gamma,beta)) ∈ A` and `U(xi, eta∧U(xi,eta)) ∈ A`
   - Let `theta = beta∧U(gamma,beta)∧xi∧U(xi,eta)`
   - A7a (BX7) on these two enriched Until formulas → three-way disjunction
   - First two disjuncts ruled out using `¬U(gamma, beta∧eta) ∈ A` + A1a/A2a
   - Third disjunct survives: `U(beta∧U(gamma,beta)∧xi, theta) ∈ A`
   - A3a (BX13) gives `U(xi, beta∧eta) ∈ A` → consistency of `zeta` by Lemma 2.2
4. Lindenbaum → MCS D with `xi ∈ D`, B ⊆ D
5. B' maximal with `r(A, B', D)`, B'' maximal with `r(D, B'', C)`
6. `eta ∈ B'` follows from maximality + `U(xi, beta∧eta) ∈ A` for each `beta ∈ B`

**Key difference from current code**: No case split on consistency. No application of BX7 to `U(eta.neg, top)`. The BX7 application is to `U(gamma, beta∧U(gamma,beta))` and `U(xi, eta∧U(xi,eta))` — two enriched Until formulas from the seed, not involving `eta.neg`.

**Action**: Delete the current Case 1/Case 2 approach in PointInsertion.lean and implement Burgess's direct seed argument.

### 2. Phases 8-9: h_gc Blocker Is Structural — Remove c2' from EliminationResult (3 of 4 recommend)

**The blocker is real and fundamental** (unanimous). For g_prop counterexamples, the counterexample condition (`G(alpha) ∈ f(x)`, `alpha ∉ f(y)`) directly contradicts `g_content(f(x)) ⊆ f(y)`, making `lemma_2_6_splitting` inapplicable. No technical fix can resolve this within the current approach.

**Resolution: Option B** — remove `c2'` from `EliminationResult` and prove it only at the limit:

- At the limit, the domain is dense (no adjacent pairs) → c2' is vacuously true
- Burgess leaves "details of the verification" of C2' maintenance to the reader (C's finding)
- Neither Xu nor Reynolds specify c2' as a finite-stage invariant (B's finding)
- The g_prop/h_prop counterexample cases are NOT in Burgess's construction (C's finding) — they exist only because the codebase uses `forward_G` in FMCS, which is a deviation from Burgess
- **Removing c2' eliminates 4-6 sorry sites in one architectural change**

**Minority view (Teammate A)**: Option A (g_ordered invariant) is also viable — if `g_content(f(a)) ⊆ f(b)` for adjacent pairs is maintained as an invariant, then g_prop/h_prop counterexamples cannot arise (vacuous). C4 cases still work via `lemma_2_6_splitting`. This is architecturally cleaner but requires more invariant threading.

**Conflict resolution**: Option B is recommended because:
- Lower implementation effort (2-3 hours vs "substantial refactoring")
- Directly aligned with Burgess's design intent
- Eliminates more sorry sites at once
- The density-at-limit proof is straightforward (every adjacent pair is eventually resolved by the omega-chain enumeration)

### 3. lemma_2_6_splitting Return Type Extension Is Correct and Necessary (Unanimous)

The Phase 6 agent already extended `lemma_2_6_splitting` to return `g_content A ⊆ D ∧ g_content D ⊆ C`. All four teammates confirm this is correct — the proofs already exist internally (`h_gc_AD`, `h_gc_DC` at lines 923-933 of PointInsertion.lean). This extension is already committed and sorry-free.

### 4. g_prop/h_prop Cases Are Not in Burgess's Construction (A, C)

Teammates A and C independently confirm that Burgess does NOT have "g_prop counterexample elimination." Burgess only eliminates C4 (adjacent pair splitting) and C5 (Until witness insertion) counterexamples. The g_prop/h_prop cases in the codebase exist because the truth lemma uses `forward_G` as an explicit FMCS requirement, which is a deviation from Burgess's architecture (where the truth lemma uses C4 for all pairs).

Under Option B, these cases become moot — the EliminationResult no longer requires c2', so the g_prop/h_prop sorry sites disappear.

### 5. Strategic Assessment: Chronicle Path Is Correct, Plan Revision Needed (D)

- Chronicle path is the only viable path to completeness (3 independent BXCanonical paths are documented-dead)
- 0-sorry target is correct (no partial result serves the representation theorem)
- Task should NOT be split (phases are coupled through EliminationResult architecture)
- Plan revision (v33) is essential before the next implementation session
- Estimated remaining effort: 14-20 hours (vs 22 in current plan)

### 6. Zorn Sorry (RRelation.lean:772) May Be Easy (D)

The Zorn sorry requires `¬burgessR3(A, Set.univ, C)`. Since `burgessR3` requires the middle argument to be a DCS (which includes `SetConsistent`), and `Set.univ` is NOT consistent (it contains `⊥`), this may be a straightforward proof. Needs verification against the exact `burgessR3` definition.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution | Reasoning |
|----------|------------|-----------|
| Option A vs Option B for c2' | **Option B** (remove c2') | 3 of 4 recommend; lower effort; Burgess-aligned; eliminates more sorries |
| Does Burgess maintain c2' at finite stages? | **Conceptually yes, but "details left to reader"** | A says yes by construction; C says Burgess leaves details; B/D say limit-only. Resolution: Burgess intends c2' at each stage but the explicit proofs are not in the paper, and the codebase's approach of threading c2' through EliminationResult is over-specified vs what Burgess actually proves. |

### Gaps Identified

1. **Density-at-limit proof**: Under Option B, a new proof obligation arises: show the limit domain is dense (no adjacent pairs). Strategy: for any adjacent pair (x,y) in chronicle n, the density counterexample (x,y) appears at some enumeration index m, and is resolved by inserting (x+y)/2. After step m, (x,y) is no longer adjacent.

2. **Lemma 2.7 eta ∈ B' mechanism**: Burgess's argument that `eta ∈ B'` relies on `U(xi, beta∧eta) ∈ A` for each `beta ∈ B` plus maximality of B'. The formalization needs to show that `r(A, eta, D)` holds from these U-formulas + `xi ∈ D`, then maximality of B' includes eta. This is the most subtle part of the Lemma 2.7 proof.

3. **Convention check for Lemma 2.7**: Teammate C flags potential notation confusion between D (endpoint MCS) and B' (interval set) in the Phase 6 handoff. Needs careful verification during implementation.

4. **FUC/FSC coherence (Phase 11)**: Not addressed by any teammate. This phase depends on the C5 construction threading through the Cantor isomorphism. Effort estimate uncertain.

### Recommendations

1. **Run `/revise 107`** to create plan v33 incorporating Option B
2. **Phase 6 (Lemma 2.7)**: Rewrite using Burgess's direct seed argument — delete Case 1/Case 2 approach
3. **Phase 8-9 consolidated**: Remove c2' from EliminationResult, prove density at limit
4. **Phase 8 density sorry**: Use extended `lemma_2_6_splitting` (already done) + h_gc_adj invariant on omega_chain
5. **Verify Zorn sorry**: Check if `burgessR3(A, Set.univ, C)` fails trivially from Set.univ inconsistency

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary | completed | High | Extracted Burgess's actual Lemma 2.7 proof; identified g_ordered as viable |
| B | Alternatives | completed | High | Option B analysis; Xu Lemma 2.4 correspondence; Lemma 2.7 avoidable under Option B |
| C | Critic | completed | High | Phase 6 wrong strategy; g_prop not in Burgess; Phase 5a gate incomplete |
| D | Horizons | completed | High | Chronicle path confirmed; plan revision essential; 14-20h estimate |

## References

- Burgess 1982: "Axioms for tense logic I: Since and Until" — Lemma 2.6, 2.7, Section 2 construction
- Xu 1988: "On some US-tense logics" — Lemma 2.4 (simplified splitting), Definition 2.5 (chronicle)
- Venema 1993: "Since and Until" — Confirms Burgess-Xu as canonical
- Reynolds 1992: "Axiomatization of full computation tree logic" — References Xu simplification
