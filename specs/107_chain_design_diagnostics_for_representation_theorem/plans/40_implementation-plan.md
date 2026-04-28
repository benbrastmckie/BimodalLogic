# Implementation Plan: Task #107 -- Burgess Chronicle Construction (A3a-Unblocked)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 40 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/40_team-research.md]
- **Artifacts**: plans/40_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Research report 40 identified that the A3a axiom (p AND U(q,r) -> U(q AND S(p,r), r)) IS semantically valid under our open-guard (t,s) semantics -- the counterexample that led to its exclusion was wrong. Adding A3a/A3b as new BX axioms immediately unblocks Burgess Lemma 2.3, Xu's Lemma 3.2.1, and the entire chronicle construction. This plan begins by fixing stale documentation (half-open guard references), adds A3a/A3b with soundness proofs, then closes all 15 remaining sorry sites: 4 in RRelation.lean, 9 in CounterexampleElimination.lean, and 2 in ChronicleToCountermodel.lean. Definition of done: all Chronicle/ sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 40 (team research, 4 teammates, unanimous)**: Primary input. Breakthrough finding: A3a IS valid under open guard (t,s). The counterexample in TemporalDerived.lean:519-522 evaluated S(p,r) at the current time t instead of at the Until witness s. A3a must be ADDED as a new axiom (not derivable from BX1-BX12). Plan v22's mapping "A3a = BX4" was wrong -- they are completely different axioms. With A3a added, Lemma 2.3 becomes a 3-line proof and the entire construction unblocks.

### Prior Plan Reference

Plan v22 (artifact 39) had 8 phases, 52 hours. Phases 1-2 completed (review + cleanup). Phase 3 blocked on Lemma 2.3 because the P-to-Since gap requires A3a which was missing. Key lessons: (1) BX4 does NOT subsume A3a -- BX4 gives P(p) = S(T, p) with trivial guard, while A3a needs S(p, r) with specific guard r; (2) the Lemma 2.3 forward direction proved P(alpha) in C via BX4+BX10 contradiction (sorry-free), but the final step from P to Since is exactly the gap that A3a fills; (3) effort estimates for phases 4-6 were reasonable but the dependency on A3a was unrecognized.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all 15 chronicle sorry sites achieves the chronicle sorry-free milestone

## Goals & Non-Goals

**Goals**:
- Fix stale documentation: replace all "half-open guard [t,s)" references with correct "open guard (t,s)"
- Remove the wrong A3a counterexample from TemporalDerived.lean
- Add A3a (enrichment_until) and A3b (enrichment_since) as new BX axioms with soundness proofs
- Close the 4 sorry sites in RRelation.lean (Lemma 2.3 forward/backward, Xu 3.2.1 Until/Since)
- Close the 9 sorry sites in CounterexampleElimination.lean (c2' construction for all elimination cases)
- Close the 2 sorry sites in ChronicleToCountermodel.lean (restricted_fuc Until/Since coherence)
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- BXCanonical sorry closure (task 109)
- BX2 redundant conjunct cleanup (separate task per report 40)
- BX4 redundancy investigation (separate task per report 40)
- Adding A4a (not needed if following Xu's construction -- A4a is for Burgess Lemma 2.6 which Xu bypasses)
- Algebraic path sorries (InteriorOperators.lean, TenseS5Algebra.lean)
- ROADMAP.md updates (separate per roadmap_flag=false)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A3a Lean encoding has wrong argument order (our untl convention is guard-first, event-second) | H | M | Carefully verify encoding against Truth.lean:127-130 semantics before writing soundness proof |
| Soundness proof for A3a is harder than expected in Lean | M | L | The semantic proof is straightforward (take same witness, reuse guard interval); Lean encoding is the only challenge |
| Lemma 2.3 uses A3a in a way that requires additional infrastructure | M | L | Burgess's 1-line proof directly applies A3a; no extra infrastructure needed beyond the axiom |
| c2' construction requires BurgessR3Maximal upgrade that cascades wider than expected | M | M | Plan v22 Phase 3 already prepared the upgrade path; existing `burgessR3Maximal_exists_from_seed` is sorry-free |
| CounterexampleElimination c2' sorry sites involve complex Lean term construction | H | M | Follow existing patterns in sorry-free cases; use `lean_goal` to inspect each sorry site before attacking |
| ChronicleToCountermodel restricted_fuc may need infrastructure beyond C5 + C3 | M | L | Report 40 confirms: with corrected C5 (guard in g(x,y)), fuc proof is C5 + C3 composition |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |

Phases 4 and 5 can execute in parallel (independent files: RRelation.lean vs CounterexampleElimination.lean).

---

### Phase 1: Documentation Cleanup -- Fix Stale Half-Open Guard References [NOT STARTED]

**Goal**: Fix all stale documentation claiming "half-open guard [t,s)" to correctly state "open guard (t,s)", and remove the wrong A3a counterexample from TemporalDerived.lean. This establishes a clean documentation baseline before adding new axioms.

**Tasks**:
- [ ] Fix Truth.lean:13-14 docstring: change "half-open guard [t, s)" to "open guard (t, s)" and "half-open guard (s, t]" to "open guard (s, t)"
- [ ] Fix Truth.lean:72 implementation note: change "half-open guards [t,s) / (s,t]" to "open guards (t,s) / (s,t)"
- [ ] Fix Axioms.lean:28 comment: change "half-open guard" to "open guard"
- [ ] Fix Axioms.lean:126 BX2 comment: change "half-open guard [t,s)" to "open guard (t,s)" and update the interval coverage explanation
- [ ] Fix Axioms.lean:132 BX2' comment: mirror fix for Since direction
- [ ] Fix Axioms.lean:149 BX4 comment: change "half-open guard semantics" to "open guard semantics"
- [ ] Fix Axioms.lean:202 BX8 note: change "half-open guard" to "open guard"
- [ ] Fix Soundness.lean:384 comment: change "[t, s)" to "(t, s)"
- [ ] Fix Soundness.lean:485-486 comment: update the explanation (A3a IS valid under open guard)
- [ ] Fix Soundness.lean:561-563 comment: change "[t, s)" and "[r, s)" to "(t, s)" and "(r, s)"
- [ ] Remove TemporalDerived.lean:512-537 section: delete the entire "A3a/A4a: Not Valid Under Strict Semantics" block with the wrong counterexample and the incorrect claim that BX4+BX5 subsume A3a
- [ ] Run `lake build` to verify no regressions

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` -- fix docstring and implementation notes (lines 13-14, 72)
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- fix 5 stale comments (lines 28, 126, 132, 149, 202)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- fix 3 stale comments (lines 384, 485-486, 561-563)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- delete wrong A3a section (lines 512-537)

**Verification**:
- `grep -rn "half-open\|half_open\|\[t, s)\|\[t,s)" Theories/Bimodal/Semantics/Truth.lean Theories/Bimodal/ProofSystem/Axioms.lean Theories/Bimodal/Metalogic/Soundness.lean` returns empty
- `grep -n "A3a.*Not Valid\|Not Valid.*A3a" Theories/Bimodal/Theorems/TemporalDerived.lean` returns empty
- `lake build` succeeds

---

### Phase 2: Add A3a/A3b Axioms with Soundness Proofs [NOT STARTED]

**Goal**: Add enrichment_until (A3a) and enrichment_since (A3b) as new BX axiom constructors in Axioms.lean, then prove their soundness in Soundness.lean. This is the prerequisite that unblocks all downstream phases.

**Tasks**:
- [ ] Add `enrichment_until` constructor to the `Axiom` inductive in Axioms.lean, after the BX4' entry:
  ```lean
  /-- BX13: Until-Since enrichment (Burgess A3a, Xu axiom (3)):
  p ∧ (φ U ψ) → (φ ∧ S(φ, p)) U ψ.
  Enriches the Until event with Since information from the current point.
  Valid under open guard (t,s): the Until guard (t,s) provides the Since guard
  at the witness since the intervals are identical. -/
  | enrichment_until (φ ψ p : Formula) :
      Axiom (Formula.and p (Formula.untl φ ψ) |>.imp
        (Formula.untl φ (Formula.and ψ (Formula.snce φ p))))
  ```
  NOTE: Verify argument order matches our convention (untl guard event = untl phi psi means phi is guard, psi is event). Research report uses Burgess convention (U(event, guard)); our code uses (guard, event).
- [ ] Add `enrichment_since` constructor (A3b, mirror):
  ```lean
  /-- BX13': Since-Until enrichment (Burgess A3b, Xu axiom (4)):
  p ∧ (φ S ψ) → (φ ∧ U(φ, p)) S ψ.
  Mirror of enrichment_until. -/
  | enrichment_since (φ ψ p : Formula) :
      Axiom (Formula.and p (Formula.snce φ ψ) |>.imp
        (Formula.snce φ (Formula.and ψ (Formula.untl φ p))))
  ```
- [ ] Prove soundness of `enrichment_until` in Soundness.lean: Given truth of p at t and U(phi, psi) at t (witness s > t, psi(s), phi on (t,s)), show U(phi, psi AND S(phi, p)) at t. Take same witness s. Need psi(s) (have it) AND S(phi, p)(s) at witness s: take u=t as Since witness, p(t) holds, phi on (t,s) is the Until guard. Guard for outer Until: phi on (t,s), same as before.
- [ ] Prove soundness of `enrichment_since` in Soundness.lean (mirror proof)
- [ ] Update ROADMAP-relevant comments in Axioms.lean to note the new BX13/BX13' axioms
- [ ] Run `lake build` to verify

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- add 2 new constructors (~20 lines)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- add 2 soundness proofs (~40 lines)

**Verification**:
- Both `enrichment_until` and `enrichment_since` soundness proofs compile sorry-free
- `lake build` succeeds
- `grep -n "sorry" Theories/Bimodal/Metalogic/Soundness.lean` returns empty

---

### Phase 3: Close Lemma 2.3 and Xu 3.2.1 Sorry Sites in RRelation.lean [NOT STARTED]

**Goal**: Using the new A3a/A3b axioms, close all 4 sorry sites in RRelation.lean: Lemma 2.3 forward (line 1210), Lemma 2.3 backward (line 1243), Xu 3.2.1 Until (line 1415), and Xu 3.2.1 Since (line 1428).

**Tasks**:
- [ ] Close `burgessR_implies_burgessRSince` sorry (line 1210): The proof already has P(alpha) in C. The gap is from P(alpha) to snce(beta, alpha). Apply enrichment_until (A3a): from alpha in A and untl(beta, gamma) in A (for any gamma in C via burgessR), get untl(beta, gamma AND snce(beta, alpha)) in A. Extract snce(beta, alpha) from the conjunction.
  Actually, the Burgess proof is simpler: from P(alpha) in C, use BX12' to get (T S alpha) in C. From beta in B and the Since (T S alpha), apply enrichment_since (A3b) to get (T AND U(T, beta)) S alpha in C. Since U(T, beta) follows from BX12+F(beta), simplify. Or most directly: apply the derived Lemma from A3a that P(alpha) AND burgessR => snce(beta, alpha) in C.
  The exact proof strategy: use A3a at the MCS level. Inspect each sorry site with `lean_goal`, apply the A3a axiom via `DerivationTree.axiom` and `SetMaximalConsistent.implication_property`.
- [ ] Close `burgessRSince_implies_burgessR` sorry (line 1243): Mirror of forward direction using A3b (enrichment_since)
- [ ] Close `burgessR3Maximal_untl_mem_B` sorry (line 1415): This is Xu's Lemma 3.2.1(i). Uses BX5 (self_accum_until) + maximality of B + the now-provable Lemma 2.3 equivalence. The proof by contradiction: assume untl(beta, gamma) not in B, then B union {untl(beta, gamma)} extends B while preserving burgessR3(A, -, C), contradicting maximality.
- [ ] Close `burgessR3Maximal_snce_mem_B` sorry (line 1428): Mirror of 3.2.1(i) using BX5' and Since direction
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- close 4 sorry sites (~80 lines of proof)

**Verification**:
- `grep -cn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` returns 0
- `lake build` succeeds
- `burgessRSet_iff_burgessRSetSince` compiles sorry-free (depends on Lemma 2.3)

---

### Phase 4: Close CounterexampleElimination Sorry Sites [NOT STARTED]

**Goal**: Close all 9 sorry sites in CounterexampleElimination.lean. These are all c2' construction sites that need BurgessR3Maximal g-values for newly created adjacent pairs during counterexample elimination.

**Tasks**:
- [ ] Inspect each of the 9 sorry sites using `lean_goal` to understand the exact proof state at each location (lines 425, 543, 792, 830, 870, 908, 944, 976, 1092)
- [ ] Close the 2 "base" sorry sites (lines 425, 543): These appear to be the C4/C4' hard case core logic. With Xu's Lemma 3.2.1 now available (from Phase 3), B closure gives the needed Until/Since formulas in B for constructing new g-values.
- [ ] Close the 6 "c2' construction" sorry sites (lines 792, 830, 870, 908, 944, 976): These need BurgessR3Maximal for newly created adjacent pairs. Use `burgessR3Maximal_exists_from_seed` (sorry-free, RRelation.lean:1131) to construct maximal DCS from appropriate seeds. The seed for each case comes from the existing g-value of the pair being split, combined with the new constraint from the elimination step.
- [ ] Close the density sorry site (line 1092): This appears to be a case where f(z) = f(x) does not follow in general. With the corrected construction using proper Lemma 2.7/2.8 point insertion (guard in g(x,y)), this should become provable or require restructuring the density case to use proper insertion.
- [ ] Run `lake build`

**Timing**: 12 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 9 sorry sites (~200 lines of proof)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- may need helper lemmas for insertion (~30 lines)

**Verification**:
- `grep -cn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` returns 0
- `lake build` succeeds

---

### Phase 5: Close ChronicleToCountermodel Sorry Sites [NOT STARTED]

**Goal**: Close the 2 remaining sorry sites in ChronicleToCountermodel.lean (restricted_fuc for Until and Since, lines 615 and 619). These are the forward Until/Since coherence proofs that connect the chronicle construction to the countermodel.

**Tasks**:
- [ ] Inspect the 2 sorry sites with `lean_goal` to understand exact proof state
- [ ] Close forward Until sorry (line 615): For U(phi, psi) in mcs(t), C5 gives a witness y with psi in f(y) and phi in g(t, y). For any intermediate r between t and y, C3 gives g(t, y) subset f(r), so phi in f(r). The guard holds at all intermediate points. This requires the limit chronicle's C5 and C3 properties to be wired through the Cantor isomorphism to the Rat-indexed countermodel.
- [ ] Close forward Since sorry (line 619): Mirror of Until case using C5' and C3
- [ ] Verify that g-immutability across omega-chain stages (old pairs preserve g-values) follows from the elimination function's g_agrees fields
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~60 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- may need g-immutability helper (~20 lines)

**Verification**:
- `grep -cn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` returns 0
- `dd_countermodel_chronicle` compiles sorry-free
- `lake build` succeeds

---

### Phase 6: Integration, Validation, and Cleanup [NOT STARTED]

**Goal**: Verify the full sorry-free chronicle path, run axiom audits, clean up scaffolding, and confirm the representation theorem chain is complete.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify no `sorryAx`
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` to confirm zero sorry sites across all 6 files
- [ ] Verify `lake build` succeeds with no warnings related to chronicle files
- [ ] Update Completeness.lean documentation to reflect the sorry-free chronicle path
- [ ] Clean up any temporary scaffolding, commented-out code, or outdated TODOs from the implementation phases
- [ ] Update sorry counts in any file-level documentation headers that reference sorry counts
- [ ] Update the Soundness.lean:485-486 block to note that A3a IS now in the axiom system and its soundness is proved (if not already fixed in Phase 1)

**Timing**: 2 hours

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- all files (cleanup)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update documentation

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns empty
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `lake build` succeeds

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns empty after Phase 6
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] Both A3a/A3b soundness proofs are sorry-free
- [ ] Lemma 2.3 (burgessR <=> burgessRSince) compiles sorry-free
- [ ] Xu's Lemma 3.2.1 (B closure under Until/Since formation) compiles sorry-free
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] No stale "half-open guard" documentation remains in Truth.lean, Axioms.lean, Soundness.lean

## Artifacts & Outputs

- `plans/40_implementation-plan.md` (this file)
- Modified files in `Theories/Bimodal/ProofSystem/Axioms.lean` (2 new axiom constructors)
- Modified `Theories/Bimodal/Metalogic/Soundness.lean` (2 new soundness proofs)
- Modified Chronicle files (4 files in `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/`)
- Modified `Theories/Bimodal/Theorems/TemporalDerived.lean` (wrong counterexample removed)
- Modified `Theories/Bimodal/Semantics/Truth.lean` (documentation fix)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- All changes are additive (new axioms, new proofs, documentation fixes) -- no destructive removals
- Git history preserves all prior states; `git log --oneline Theories/Bimodal/` traces changes
- If A3a encoding turns out wrong, only Phase 2 needs revision; Phases 1 is independent
- If Lemma 2.3 or Xu 3.2.1 proves harder than expected with A3a, the Phase 3 sorry sites can be left with partial progress and a handoff documenting the remaining gap
- If CounterexampleElimination c2' construction requires restructuring beyond A3a, Phase 4 can be paused and a `/revise` run to adjust the approach
- The BXCanonical path (task 109) remains as an independent backup completeness route
