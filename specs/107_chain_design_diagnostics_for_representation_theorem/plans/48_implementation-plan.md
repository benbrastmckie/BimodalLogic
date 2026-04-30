# Implementation Plan: Task #107 -- Burgess Chronicle Construction (v34)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IMPLEMENTING]
- **Effort**: 34 hours (estimated 16 remaining)
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/42_team-research.md], [reports/43_team-research.md], [reports/44_team-research.md], [reports/45_team-research.md], [reports/47_team-research.md], [reports/48_team-research.md]
- **Artifacts**: plans/48_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v34 incorporates critical findings from Report 48 (team research, 4 teammates). Two root-cause discoveries reshape the remaining work: (1) The codebase's BX7 axiom (`Axiom.linear_until`) has different disjuncts from Burgess's A7a -- BX7 has fixed guard (p AND r) with varying events, while A7a has varying guards with fixed event (q AND s). This is the fundamental reason Burgess's Lemma 2.7 proof does not translate. The fix is to replace BX7 with A7a in Axioms.lean, not derive A7a from BX7 as a workaround. (2) The Zorn sorry (RRelation.lean:772) is unfixable proof-theoretically with `ClosedUnderDerivation` maximality (confirmed by Phase 8 handoff), but disappears entirely by reverting to `SetDeductivelyClosed` maximality -- matching Burgess's original definition. The `g_content_sub_B` inconsistent case needs a new proof via G(phi)/F(phi.neg) contradiction without density axioms.

Current sorry count: **5** across 4 files (RRelation:1, CounterexampleElimination:2, PointInsertion:1, ChronicleToCountermodel:2). Definition of done: all Chronicle sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 42**: Root cause -- g-values never constructed. Integrated v26.
- **Report 43**: Density self-pair impossible, C5 n=0 via g_content. Integrated v27.
- **Report 44**: A4a valid but not needed for splitting. Integrated v29.
- **Report 45**: left_mono_until_G + g_content(A) subset B via maximality. Integrated v30.
- **Report 47**: Phase 6 uses wrong strategy (case split vs Burgess's direct seed). Option B (remove c2'). Integrated v33.
- **Report 48** (NEW, this version): BX7 != A7a is the root cause of Lemma 2.7 difficulty. Zorn sorry fixable by reverting to DCS maximality. C4 sorry sites need c2' + lemma_2_6, NOT lemma_2_7.

### Prior Plan Reference

Plan v33 had phases 1-5b-ii [COMPLETED], phase 6 [PARTIAL], phase 7 [COMPLETED], phase 8 [IN PROGRESS], phases 9-10 [NOT STARTED]. Key lessons: (1) Phase 6 (Lemma 2.7) was blocked because BX7's disjunct structure does not match Burgess's A7a -- the D2 elimination step fails with BX7's event form. (2) Phase 8 confirmed the Zorn sorry cannot be closed proof-theoretically with ClosedUnderDerivation maximality (handoff 10 documents this thoroughly). (3) Phase 7 (c2' removal) succeeded and simplified the architecture. (4) The C4 sorry sites (lines 412, 510) were misclassified as Phase 8 density issues -- they are actually C4 hard cases needing BurgessR3Maximal for adjacent pairs.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all chronicle sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Replace BX7 with Burgess's A7a form in Axioms.lean (axiom-level refactoring)
- Revert BurgessR3Maximal maximality from ClosedUnderDerivation to SetDeductivelyClosed
- Prove g_content_sub_B inconsistent case via G(phi)/F(phi.neg) contradiction
- Rewrite Lemma 2.7 using Burgess's direct seed argument (now possible with A7a)
- Close C4 sorry sites (lines 412, 510) using c2' + lemma_2_6_splitting
- Close FUC/FSC coherence sorry sites (ChronicleToCountermodel.lean:615, 619)
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- A4a removal (separate task 115)
- BXCanonical sorry closure (task 109)
- Xu Lemma 2.3/2.4 full formalization (fallback, not primary path)
- ROADMAP.md updates
- Deriving A7a from BX7 as a workaround (design principle: use the correct axiom form)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Replacing BX7 with A7a breaks existing callers | H | M | Grep all `linear_until` usage (currently ~15 sites across 4 files). The BX7-to-A7a change preserves semantic validity -- both are sound for strict linear orders. Callers mostly use BX7 with identical events (D1=D2=D3 collapse) or can be adapted. Two-step BX7 derivation serves as fallback insurance per Report 48. |
| Soundness reproof for A7a is harder than expected | M | L | Both BX7 and A7a express the same trichotomy (witnesses coincide, first precedes, second precedes). The existing `linear_until_valid` proof structure applies with swapped guard/event roles. |
| g_content_sub_B inconsistent case proof fails without density | H | M | Report 48 Teammate C identifies the approach: phi.neg in B + G(phi) in A -> F(phi.neg) in A via burgessR3, but also U(top, phi.neg) in A -> F(phi.neg) in A, contradicting neg F(phi.neg) = G(phi) in A. If this specific path fails, investigate BX4+BX10 case split. |
| Lemma 2.7 seed consistency with A7a is still complex | H | M | With A7a, Burgess's proof goes through directly: D1/D2 have event beta AND eta, ruled out by neg U(gamma_0, beta_0 AND eta) in A. D3 gives U(xi, beta AND eta) via A3a. The seed is well-understood from Report 48. |
| C4 sorry sites require restoring c2' to omega_chain | M | M | The C4 sites need BurgessR3Maximal for adjacent pairs. After fixing Zorn sorry (Phase 8a), burgessR3Maximal_from_g_content_sub becomes sorry-free. Then lemma_2_6_splitting can provide the splitting. No c2' restoration needed. |
| FUC/FSC coherence blocked by upstream sorry chains | M | L | FUC/FSC depends on all construction sorry sites being closed. Phase sequencing ensures this. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| -- | 1, 2, 3, 4, 5a, 5b-i, 5b-ii, 7 | (already completed) |
| 1 | 8a, 8b | -- (no dependencies beyond completed phases) |
| 2 | 6, 9 | 8a, 8b |
| 3 | 10 | 6, 9 |
| 4 | 11 | 10 |

Phases within the same wave can execute in parallel. Phases 8a and 8b are independent. Phases 6 and 9 are independent but both require 8a+8b.

---

### Phase 1: Documentation Cleanup -- Fix Stale Half-Open Guard References [COMPLETED]

**Goal**: Fix all stale documentation claiming "half-open guard [t,s)" to correctly state "open guard (t,s)".

**Timing**: 1.5 hours

**Depends on**: none

**Completed**: Phase 1 of plan v23

---

### Phase 2: Add A3a/A3b Axioms with Soundness Proofs [COMPLETED]

**Goal**: Add enrichment_until (A3a/BX13) and enrichment_since (A3b/BX13') as new BX axiom constructors with soundness proofs.

**Timing**: 2 hours

**Depends on**: 1

**Completed**: Phase 2 of plan v23

---

### Phase 3: Close Lemma 2.3 Sorry Sites in RRelation.lean [COMPLETED]

**Goal**: Close Lemma 2.3 (burgessR <=> burgessRSince) using A3a/A3b.

**Timing**: 3 hours

**Depends on**: 2

**Completed**: Phase 3 of plan v23

---

### Phase 4: C4 Nested Case Fix via BX6 [COMPLETED]

**Goal**: Close the 2 C4 nested case sorry sites using BX6 (absorb_until).

**Timing**: 5 hours

**Depends on**: none (phases 1-3 already completed)

**Completed**: Phase 4 of plan v24

---

### Phase 5a: GATE -- Verify Lemma 2.7 Validity Under Strict Semantics [COMPLETED]

**Goal**: Determine whether Lemma 2.7 (Until-formula splitting) holds under strict/open-guard semantics.

**Result**: GATE PASSED. Lemma 2.7 is valid under strict semantics.

**Timing**: 4 hours

**Depends on**: none (phases 1-4 already completed)

**Completed**: Phase 5 of plan v27

---

### Phase 5b-i: Split DCS Definition + Update BurgessR3Maximal [COMPLETED]

**Goal**: Introduce `ClosedUnderDerivation` predicate, refactor `SetDeductivelyClosed`, update `BurgessR3Maximal` maximality clause.

**Timing**: 2-3 hours

**Depends on**: none (phases 1-5a already completed)

**Completed**: Phase 5b-i of plan v32

---

### Phase 5b-ii: Close Inconsistent Case + splitting_seed_consistent [COMPLETED]

**Goal**: Close inconsistent case of g_content_sub_B, h_content_sub_B, and splitting_seed_consistent.

**Timing**: 1-2 hours

**Depends on**: 5b-i

**Completed**: Phase 5b-ii of plan v32

---

### Phase 7: Remove c2' from EliminationResult (Option B) [COMPLETED]

**Goal**: Remove c2' from the finite-stage EliminationResult structure, remove g_prop/h_prop counterexample cases.

**Timing**: 3 hours

**Depends on**: none (phases 1-5b-ii already completed)

**Completed**: Phase 7 of plan v33

---

### Phase 8a: Revert BurgessR3Maximal to DCS Maximality [PARTIAL]

**Goal**: Revert the maximality clause in `BurgessR3Maximal` from `ClosedUnderDerivation` back to `SetDeductivelyClosed`, matching Burgess's original definition. This eliminates the Zorn sorry (RRelation.lean:772) because the inconsistent case (`neg SetConsistent D`) never arises -- `SetDeductivelyClosed D` requires `SetConsistent D`. Then re-prove the `g_content_sub_B_of_BurgessR3Maximal` inconsistent case using a G(phi)/F(phi.neg) contradiction instead of the Set.univ witness.

**Rationale**: Phase 8 handoff (handoff 10) conclusively demonstrates the Zorn sorry cannot be closed proof-theoretically with `ClosedUnderDerivation` maximality. The `ClosedUnderDerivation` form was introduced in Phase 5b-i as a workaround; reverting aligns with Burgess's definition. Report 48 confirms this approach (3 of 4 teammates agree).

**Tasks**:
- [ ] Change `BurgessR3Maximal` definition: replace `ClosedUnderDerivation D` with `SetDeductivelyClosed D` in the maximality clause
- [ ] Verify the Zorn sorry at RRelation.lean:772 disappears (inconsistent D is not SetDeductivelyClosed)
- [ ] Fix `burgessR3Maximal_extension_exists`: the Zorn chain join must produce a SetDeductivelyClosed set. Verify this follows from chain of DCS sets having DCS join.
- [ ] Fix `g_content_sub_B_of_BurgessR3Maximal`: the inconsistent case (phi.neg in B, G(phi) in A) previously used Set.univ as CUD witness. New proof: from `burgessR3(A, B, C)` with `phi.neg in B` and `phi in C` (since phi in g_content(A) subset C), derive `U(top, phi.neg) in A` (using burgessR3 with guard=top, beta=phi.neg in B, gamma=phi in C... or more precisely with guard from burgessRSet). Then `F(phi.neg) in A` by BX10. But `G(phi) in A` means `neg F(phi.neg) in A`. Contradiction with MCS A.
- [ ] Fix `h_content_sub_B_of_BurgessR3Maximal`: dual of the above
- [ ] Fix all downstream compilation errors from the definition change
- [ ] Run `lake build`

**Timing**: 3 hours

**Depends on**: none (phases 1-7 already completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- change BurgessR3Maximal definition, fix extension_exists (~30 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- fix g_content_sub_B, h_content_sub_B inconsistent cases (~40 lines)

**Verification**:
- RRelation.lean sorry count: 0
- `burgessR3Maximal_extension_exists` sorry-free
- `g_content_sub_B_of_BurgessR3Maximal` sorry-free
- `lake build` succeeds

---

### Phase 8b: Replace BX7 with Burgess A7a [PARTIAL]

**Goal**: Replace the codebase's `Axiom.linear_until` (BX7) with Burgess's A7a form. BX7 has fixed guard (phi AND chi) with varying events; A7a has varying guards with fixed event (psi AND theta). This is a one-time axiom-level refactoring that permanently aligns the proof system with Burgess's architecture.

**BX7 (current)**:
```
U(phi,psi) AND U(chi,theta) -> U(phi AND chi, psi AND theta) OR U(phi AND chi, psi AND chi) OR U(phi AND chi, phi AND theta)
```

**A7a (Burgess, target)**:
```
U(phi,psi) AND U(chi,theta) -> U(phi AND chi, psi AND theta) OR U(phi AND theta, psi AND theta) OR U(chi AND psi, psi AND theta)
```

D1 is identical. D2 and D3 differ: A7a has fixed event (psi AND theta) with varying guards, BX7 has fixed guard (phi AND chi) with varying events.

**Why this matters**: Burgess's Lemma 2.7 proof rules out D1 and D2 using `neg U(gamma_0, beta_0 AND eta) in A`. In A7a, both D1 and D2 have event `beta_0 AND eta`, so the ruling-out works. In BX7, D2 has event `beta_0 AND chi` which does not match.

**Tasks**:
- [ ] Change `Axiom.linear_until` in Axioms.lean to A7a form: swap D2 from `U(phi AND chi, psi AND chi)` to `U(phi AND theta, psi AND theta)`, swap D3 from `U(phi AND chi, phi AND theta)` to `U(chi AND psi, psi AND theta)`
- [ ] Change `Axiom.linear_since` dually
- [ ] Re-prove `linear_until_valid` in Soundness.lean: the semantic argument is the same trichotomy (witnesses coincide, first precedes, second precedes) but with different guard/event assignments in each case
- [ ] Update Substitution.lean if the constructor signature changes
- [ ] Grep all callers of `linear_until` and fix:
  - `RRelation.lean:945`: `burgessR_implies_burgessRSince` uses BX7 with identical events (gamma=gamma). With A7a, D1=D2=D3 all collapse to the same formula when events are identical, so this should simplify.
  - `PointInsertion.lean`: seed consistency uses BX7. With A7a, the Burgess proof structure aligns directly.
- [ ] Run `lake build`

**Timing**: 4 hours

**Depends on**: none (phases 1-7 already completed)

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- change linear_until/linear_since constructors (~10 lines)
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- update substitution case (~5 lines)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- re-prove linear_until_valid (~80 lines)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- update 4 lemma cases (~40 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- update burgessR_implies_burgessRSince (~20 lines)

**Verification**:
- `Axiom.linear_until` has A7a form
- All soundness lemmas sorry-free
- `lake build` succeeds
- No regressions in existing sorry-free lemmas

---

### Phase 6: Rewrite Lemma 2.7 Using Burgess's Direct Seed Argument [PARTIAL]

**Goal**: With A7a in place, implement Burgess's actual proof from 1982 p. 371. The proof now goes through directly because D1 and D2 both have event beta_0 AND eta, both ruled out by neg U(gamma_0, beta_0 AND eta) in A.

**Burgess's proof structure (with A7a)**:
1. From `eta not in B` and maximality of B: obtain `beta_0 in B`, `gamma_0 in C` with `neg U(gamma_0, beta_0 AND eta) in A`
2. Construct seed D_0 = {S(alpha, beta AND eta) : alpha in A, beta in B} union B union {xi} union {U(gamma, beta) : gamma in C, beta in B}
3. Prove seed consistency: for any beta in B and gamma in C, apply BX5 twice to enrich U(xi, eta) and U(gamma, beta), then apply A7a to get three-way disjunction:
   - D1: U(xi AND gamma, beta AND eta) -- has event beta AND eta, eliminated by neg U(gamma_0, beta_0 AND eta)
   - D2: U(xi AND beta, beta AND eta) -- has event beta AND eta, eliminated by neg U(gamma_0, beta_0 AND eta)
   - D3: U(gamma AND xi, beta AND eta) -- survives... but wait, D3 ALSO has event beta AND eta with A7a. All three disjuncts are eliminated. Need to re-examine.

   Actually with A7a applied to U(xi AND U(xi,eta), eta) and U(gamma, beta): D3 = U(gamma AND eta, beta AND eta). Apply A3a (enrichment_until) to get U(xi, beta AND eta) in A. This proves consistency with Lemma 2.2.
4. Lindenbaum gives MCS D with xi in D, B subset D
5. B' maximal with r(A, B', D), B'' maximal with r(D, B'', C)
6. eta in B' follows from U(xi, beta AND eta) in A for each beta in B plus maximality of B'

**Tasks**:
- [ ] Delete the current sorry stub in PointInsertion.lean lemma_2_7
- [ ] Implement maximality extraction: from `eta not in B` and `BurgessR3Maximal(A, B, C)`, obtain beta_0 in B, gamma_0 in C, neg U(gamma_0, beta_0 AND eta) in A
- [ ] Define seed D_0 as described above
- [ ] Prove seed consistency using BX5 + A7a + A3a chain
- [ ] Eliminate D1 and D2 using neg U(gamma_0, beta_0 AND eta) in A (both have event beta AND eta with A7a)
- [ ] Apply A3a to surviving disjunct to get U(xi, beta AND eta) in A
- [ ] Construct D via Lindenbaum, then B' and B'' via burgessR3Maximal
- [ ] Prove xi in D and eta in B' from the constructed seed
- [ ] Verify theorem compiles sorry-free
- [ ] Run `lake build`

**Timing**: 5 hours

**Depends on**: 8a (DCS maximality for BurgessR3Maximal), 8b (A7a axiom form for D1/D2 elimination)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- implement Burgess's direct seed (~150 lines net)

**Verification**:
- Lemma 2.7 splitting theorem compiles sorry-free
- PointInsertion.lean sorry count: 0
- `lake build` succeeds

---

### Phase 9: Close C4 Sorry Sites via lemma_2_6_splitting [NOT STARTED]

**Goal**: Close the 2 remaining sorry sites in CounterexampleElimination.lean (lines 412, 510). These are C4/C4' hard cases needing BurgessR3Maximal for adjacent pairs + splitting. They need `c2'` (BurgessR3Maximal for g(w, w_next)) + `lemma_2_6_splitting`, NOT Lemma 2.7. With Phase 8a fixing the Zorn sorry, `burgessR3Maximal_from_g_content_sub` becomes sorry-free, making the BurgessR3Maximal construction available.

**Approach**: For adjacent pair (w, w_next) in the chronicle:
1. `g_content(f(w)) subset g(w, w_next)` and `g_content(g(w, w_next)) subset f(w_next)` -- from chronicle invariants
2. `burgessR3Maximal_from_g_content_sub` gives `BurgessR3Maximal(f(w), g(w, w_next), f(w_next))` -- this IS c2'
3. Apply `lemma_2_6_splitting` to get the splitting point D that eliminates the C4 counterexample

**Tasks**:
- [ ] Inspect C4 sorry at line 412 with `lean_goal` to understand exact constraint
- [ ] Prove BurgessR3Maximal for adjacent pairs using g_content subset relations from chronicle invariants
- [ ] Apply lemma_2_6_splitting to get splitting point
- [ ] Close sorry at line 412
- [ ] Inspect C4' sorry at line 510 with `lean_goal`
- [ ] Close sorry at line 510 (dual of line 412)
- [ ] Run `lake build`

**Timing**: 3 hours

**Depends on**: 8a (Zorn sorry closed, making burgessR3Maximal_from_g_content_sub sorry-free)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 2 sorry sites (~60 lines each)

**Verification**:
- CounterexampleElimination.lean sorry count: 0
- `lake build` succeeds

---

### Phase 10: FUC/FSC Coherence and Final Validation [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for `cantor_bfmcs_restricted_fuc` and `cantor_bfmcs_restricted_fsc`, then verify the full sorry-free chronicle path.

**Coherence argument**: With g-values properly constructed and all upstream sorry sites closed, the chronicle has well-defined g-values everywhere. C5 + C3 properties thread through the Cantor isomorphism to prove Until/Since coherence. For U(phi, psi) in f(t), C5 gives a witness y > t with psi in f(y). The limit g(t, y) provides BurgessR3Maximal(f(t), g(t,y), f(y)). For intermediate r, C3 gives g(t,y) subset g(t,r) inter f(r) inter g(r,y), so phi in g(t,y) implies phi in f(r).

**Tasks**:
- [ ] Inspect sorry sites at FUC/FSC with `lean_goal`
- [ ] Trace how C5 is available in the limit chronicle
- [ ] Determine how the Cantor isomorphism maps chronicle witnesses to countermodel witnesses
- [ ] Close FUC sorry site (line 615, forward Until coherence)
- [ ] Close FSC sorry site (line 619, forward Since coherence)
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify no `sorryAx`
- [ ] Run grep for sorry in Chronicle/ to confirm zero sorry sites
- [ ] Verify `lake build` succeeds with no warnings
- [ ] Clean up temporary scaffolding and outdated TODOs in Chronicle/ files

**Timing**: 4 hours

**Depends on**: 6 (Lemma 2.7 sorry-free), 9 (C4 sorry sites closed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~60 lines each)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- all files (cleanup)

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments/docstrings
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 11: Final Audit [NOT STARTED]

**Goal**: Comprehensive audit of the sorry-free chronicle construction. Verify all axiom references are correct, no regressions in other modules, and documentation is accurate.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` -- verify no `sorryAx`
- [ ] Run `lake build` on full project -- verify no regressions
- [ ] Grep for sorry in all BXCanonical/ files -- verify no new sorry sites introduced
- [ ] Verify A7a axiom documentation is accurate
- [ ] Verify BurgessR3Maximal documentation reflects DCS maximality
- [ ] Update module docstrings in Chronicle/ files to reflect final proof structure

**Timing**: 1 hour

**Depends on**: 10

**Files to modify**:
- Documentation updates across Chronicle/ files

**Verification**:
- Full `lake build` clean
- Zero sorry sites in Chronicle/
- `#print axioms dd_countermodel_chronicle` clean

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] BX7 replaced with A7a after Phase 8b -- all soundness lemmas sorry-free
- [ ] BurgessR3Maximal uses SetDeductivelyClosed maximality after Phase 8a
- [ ] Zorn sorry (RRelation.lean:772) closed after Phase 8a
- [ ] g_content_sub_B inconsistent case sorry-free after Phase 8a
- [ ] Lemma 2.7 (Burgess direct seed with A7a) compiles sorry-free after Phase 6
- [ ] C4/C4' sorry sites (lines 412, 510) closed after Phase 9
- [ ] FUC/FSC sorry sites closed after Phase 10
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns no actual sorry usages after Phase 11
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)

## Artifacts & Outputs

- `plans/48_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/ProofSystem/Axioms.lean` (A7a replacement)
- Modified `Theories/Bimodal/Metalogic/Soundness.lean` (A7a soundness)
- Modified `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` (A7a cases)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (DCS maximality, Zorn fix)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (Lemma 2.7 with A7a, g_content_sub_B fix)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (C4 sorry closure)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (FUC/FSC closure)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **A7a replacement has cascading effects**: Report 48 confirms a two-step BX7 derivation chain (BX7 -> BX1 -> BX2 -> second BX7) can derive U(xi, beta AND eta) from the old BX7 form. This serves as fallback insurance if A7a replacement is too disruptive, but is NOT the recommended approach (workarounds obscure mathematical structure).
- **DCS maximality revert breaks g_content_sub_B**: The Set.univ witness path is gone, but the G(phi)/F(phi.neg) contradiction proof provides a cleaner alternative. If this specific contradiction path fails, investigate whether `top in B` (vacuously true for DCS) can serve as the intermediate formula.
- **Lemma 2.7 seed consistency still complex with A7a**: If the full Burgess seed is too complex, Xu's Lemma 2.4 (Report 48, Finding 3) avoids BX7/A7a entirely and works with existing infrastructure. This is a viable fallback but produces weaker output (no eta in B').
- **C4 sorry sites need c2' restored**: If burgessR3Maximal_from_g_content_sub does not directly provide what C4 needs, c2' can be re-derived at specific call sites rather than as an omega_chain invariant.
- Git history preserves all prior states; each phase is independently committable.
- The BXCanonical path (task 109) remains as an independent backup completeness route.
