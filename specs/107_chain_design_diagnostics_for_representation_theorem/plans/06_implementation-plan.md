# Implementation Plan: Task #107

- **Task**: 107 - Chain design diagnostics for representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 22 hours
- **Dependencies**: None (strict semantics already in place on `irr_until` branch)
- **Research Inputs**: [specs/107_.../reports/05_team-research.md], [specs/107_.../reports/06_team-research.md]
- **Artifacts**: plans/06_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Implement the Burgess 1982 chronicle construction for the BX completeness theorem on the `irr_until` branch, which already has strict (irreflexive) semantics for G/H/Until/Since. The current completeness path flows through `dd_countermodel` -> `bx_bfmcs` -> `RootScopedChain.lean`, which has 3 critical sorry sites (restricted temporal coherence, restricted backward Until/Since coherence, restricted forward Until/Since coherence). These sorries arise because the unary `g_content(M)` chain architecture cannot propagate F-obligations or resolve Until/Since witnesses. The Burgess chronicle, with its binary interval function `g(x,y)` and direct point insertion via Lemmas 2.4/2.6/2.7, replaces this architecture entirely. The plan also addresses the ParametricTruthLemma sorry sites (2 sorries from the irreflexive semantics switch) which are needed on the critical path.

### Research Integration

Six rounds of team research identified:
- The root cause: unary `g_content(M)` vs. Burgess's binary `g(x,y)` interval function
- BX11 fold is the wrong tool for F-resolution; Burgess uses direct point insertion (Lemma 2.4)
- A3a/A4a are NOT derivable under reflexive semantics (counterexample found), but are NOT needed under strict semantics with the current axiom system -- the Burgess construction works directly because the BX axioms already include BX4 (connect_future: phi -> G(P(phi))), BX5 (self_accum_until), BX6 (absorb_until), BX7 (linear_until), which provide the algebraic content of A3a-A7a
- The ParametricTruthLemma and shifted truth lemma have 2 sorry sites from the irreflexive switch that must be fixed (they are on the critical path from `dd_countermodel` to `bx_completeness`)

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

- Directly advances: "Close 5 critical-path sorry sites in RootScopedChain.lean"
- Directly advances: "Eliminate sorryAx from bx_completeness"
- Supports: Publication readiness for the BX completeness theorem

## Goals & Non-Goals

**Goals**:
- Fix the 2 ParametricTruthLemma sorry sites (irreflexive semantics adaptation)
- Replace the 3 RootScopedChain sorry sites with Burgess chronicle-based proofs
- Achieve `lake build` with no new sorry sites on the critical path
- Eliminate `sorryAx` from `#print axioms bx_completeness`

**Non-Goals**:
- Changing the TaskFrame definition (explicitly prohibited)
- Fixing sorry sites in Boneyard, Examples, or non-critical-path modules
- Fixing the 14 irreflexive-consequence sorries in Frame.lean, Filtration/, Quasimodel/ (these are in dead-end approaches that the chronicle replaces)
- Proving decidability/FMP results (separate concern)
- Dense order extension (Burgess Section 1.6 variant)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A3a derivability from BX under strict semantics fails | H | L | BX4 (connect_future) + BX5 (self_accum) algebraically subsume A3a's role in Lemma 2.3; verify in Phase 1 |
| A4a derivability from BX under strict semantics fails | H | L | BX7 (linear_until) + BX5 + BX6 (absorb) provide A4a's function in Lemma 2.6; verify in Phase 1 |
| ParametricTruthLemma Until/Since cases more complex than expected under strict semantics | M | M | The commented-out proof skeleton exists; only quantifier direction changes (< vs <=) |
| Chronicle over Q vs existing Int indexing creates type mismatch | M | M | Use existing ParametricRepresentation framework which is parametric in D; instantiate at Rat |
| BX11 fold (Lemma 2.7) still has opacity issues | L | L | Lemma 2.7 is only needed for inserting between existing points; the BX7 axiom is used directly, not through `resolving_enriched_fwd_exists` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: A3a/A4a Derivability and ParametricTruthLemma Fix [COMPLETED]

**Goal**: Verify A3a and A4a are derivable from BX axioms under strict semantics, and fix the 2 ParametricTruthLemma sorry sites that block the critical path.

**Tasks**:
- [ ] Derive A3a (`p /\ U(q,r) -> U(q /\ S(p,r), r)`) from BX4 + BX5 + BX2/BX3 in `TemporalDerived.lean`
- [ ] Derive A4a (`U(p,q) /\ ~U(p,r) -> U(q /\ ~r, q)`) from BX5 + BX6 + BX7 in `TemporalDerived.lean`
- [ ] Fix `parametric_canonical_truth_lemma` sorry in `ParametricTruthLemma.lean:228` -- adapt the commented-out proof to use strict quantifiers (`<` instead of `<=`)
- [ ] Fix `parametric_shifted_truth_lemma` sorry in `ParametricTruthLemma.lean:427` -- same adaptation with ShiftClosed Omega
- [ ] Run `lake build` and verify no regressions

**Timing**: 6 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- add A3a/A4a derived theorems
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- fix 2 sorry sites

**Verification**:
- `lake build` succeeds
- `#check` confirms A3a and A4a derivation types
- ParametricTruthLemma sorry sites replaced with proofs

---

### Phase 2: Burgess Chronicle Type and r-Relation (Lemmas 2.2-2.3) [NOT STARTED]

**Goal**: Define the chronicle data structure and establish the r-relation infrastructure from Burgess Section 2.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`:
  - Define `Chronicle` structure: `f : Rat -> Set Formula` (MCS-valued), `g : Rat -> Rat -> Set Formula` (DCS-valued), `dom : Finset Rat`
  - Define conditions C0-C3 as structure fields (C0: f maps to MCS, C1: g maps to DCS, C2: r-relation holds, C2': R-maximality for adjacent pairs, C3: interval decomposition)
  - Define `r(A, beta, C)` predicate per Lemma 2.3: forall gamma in C, U(gamma, beta) in A (equivalently, forall alpha in A, S(alpha, beta) in C)
  - Define `R(A, B, C)`: B is maximal DCS with r(A, B, C)
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`:
  - Prove Lemma 2.2: if U(gamma, delta) in MCS A, then gamma is consistent
  - Prove Lemma 2.3: equivalence of the two r-relation characterizations using A3a (derived in Phase 1)
  - Prove that r(A, B, C) is preserved under deductive closure of B
  - Prove existence of R-maximal extensions (Zorn's lemma or explicit construction)
- [ ] Run `lake build` and verify

**Timing**: 5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- new file
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- new file

**Verification**:
- `lake build` succeeds
- Chronicle type and r-relation definitions compile
- Lemmas 2.2-2.3 are sorry-free

---

### Phase 3: Point Insertion Lemmas (2.4-2.8) [NOT STARTED]

**Goal**: Implement the core point insertion machinery that enables chronicle extension.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`:
  - Prove Lemma 2.4: given MCS A with U(gamma, beta) in A, construct B, C with beta in B, gamma in C, R(A, B, C). Uses A3a (derived in Phase 1) for seed consistency.
  - Prove Lemma 2.5: composition/intersection property of R-maximal relations
  - Prove Lemma 2.6: given R(A, B, C) with delta not in B, insert D with ~delta in D. Uses A4a (derived in Phase 1).
  - Prove Lemma 2.7: given R(A, B, C) with U(xi, eta) in A and eta not in B, insert D with xi in D. Uses A7a (BX7/linear_until).
  - Prove Lemma 2.8: variant of 2.7 for the case ~(xi \/ (eta /\ U(xi,eta))) in C
- [ ] Run `lake build` and verify

**Timing**: 5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- new file

**Verification**:
- `lake build` succeeds
- All 5 lemmas (2.4-2.8) are sorry-free
- Seed consistency arguments use `forward_temporal_witness_seed_consistent` from existing `OrderedSeedConsistency.lean`

---

### Phase 4: Counterexample Elimination and Omega-Union (Lemmas 2.9-2.10, 2.11) [NOT STARTED]

**Goal**: Build the iterative chronicle construction that eliminates all C4a/C5a counterexamples, and prove the truth claim.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`:
  - Prove Lemma 2.9: given a C4a counterexample (x, y, gamma, delta), extend the chronicle to eliminate it by inserting a point z with ~delta in f'(z)
  - Prove Lemma 2.10: given a C5a counterexample (x, xi, eta), extend the chronicle to add witness y with xi in f'(y), eta in g'(x,y)
  - Prove mirror images (C4b, C5b) for Since
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`:
  - Define the omega-chain: start from singleton chronicle {0 -> A0}, enumerate all potential counterexamples, apply 2.9/2.10 iteratively
  - Prove the limit (f, g) satisfies C0-C5 (all conditions including C4a, C4b, C5a, C5b)
  - Prove Claim 2.11: the valuation V(alpha) = {x : alpha in f(x)} satisfies (+) for all formulas (by induction on formula complexity, using C4a for the negative Until case and C5a for the positive Until case)
- [ ] Run `lake build` and verify

**Timing**: 4 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- new file
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- new file

**Verification**:
- `lake build` succeeds
- Claim 2.11 (truth claim) is sorry-free
- The construction produces a model over Q satisfying all chronicle conditions

---

### Phase 5: Integration -- Replace RootScopedChain Sorry Sites [NOT STARTED]

**Goal**: Wire the Burgess chronicle into the existing `dd_countermodel` pathway, replacing the 3 sorry sites in `RootScopedChain.lean`.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`:
  - Convert a Burgess chronicle (f, g) over Q into a BFMCS Rat (or adapt `dd_countermodel` to use the chronicle directly)
  - Prove the BFMCS satisfies temporal coherence (from C4a/C4b + C5a/C5b)
  - Prove backward and forward Until/Since coherence (from C5a/C5b directly)
- [ ] Modify `RootScopedChain.lean`:
  - Replace `bx_bfmcs_restricted_tc` sorry with proof via chronicle temporal coherence
  - Replace `bx_bfmcs_restricted_buc` sorry with proof via chronicle Until/Since coherence
  - Replace `bx_bfmcs_restricted_fuc` sorry with proof via chronicle Until/Since coherence
  - Alternatively: create a new `dd_countermodel_chronicle` that uses the chronicle directly, and rewire `Completeness.lean` to use it
- [ ] Verify `#print axioms bx_completeness` no longer shows `sorryAx`
- [ ] Run full `lake build` and confirm success

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- new file
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace 3 sorry sites (or rewire)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- possibly rewire `dd_countermodel`

**Verification**:
- `lake build` succeeds with no regressions
- `#print axioms bx_completeness` shows `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` -- NO `sorryAx`
- The 3 RootScopedChain sorry sites are replaced with proofs (or the module is no longer on the critical path)

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `#print axioms bx_completeness` shows no `sorryAx` after Phase 5
- [ ] `#print axioms dd_countermodel` shows no `sorryAx` after Phase 5
- [ ] A3a and A4a derived theorems type-check via `#check`
- [ ] ParametricTruthLemma: both truth lemma variants are sorry-free
- [ ] Chronicle construction: all Burgess lemmas (2.2-2.10, 2.11) are sorry-free
- [ ] No regression in existing sorry-free modules (Soundness, Decidability/FMP)

## Artifacts & Outputs

- `specs/107_.../plans/06_implementation-plan.md` (this file)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (new)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (new)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (new)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (new)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (new)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (new)
- Modified: `ParametricTruthLemma.lean`, `TemporalDerived.lean`, `RootScopedChain.lean`, possibly `Completeness.lean`

## Rollback/Contingency

- All new files are in a new `Chronicle/` subdirectory; removing it restores the status quo
- Existing `RootScopedChain.lean` sorry sites remain functional (they compile with sorry) if the chronicle integration is not ready
- If A3a/A4a derivability fails, fall back to adding them as axioms to `Axioms.lean` (adds 2 constructors, requires soundness re-proof for the 2 new axioms)
- If the ParametricTruthLemma fix proves harder than expected, it can be addressed independently since the commented-out proof skeleton shows the structure
- Git branch `irr_until` provides full rollback to pre-implementation state
