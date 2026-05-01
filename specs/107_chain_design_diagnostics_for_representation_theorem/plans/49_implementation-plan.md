# Implementation Plan: Task #107 -- Burgess Chronicle Construction (v35)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/49_burgess-alignment-audit.md]
- **Artifacts**: plans/49_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v35 incorporates the Burgess alignment audit (report 49), the wave-1 partial handoff (phases 8a+8b), and the key architectural insight: the codebase's Lemma 2.6 and 2.7 use a non-Burgess seed (`{beta.neg} union g_content(A) union h_content(C)`) that requires proving `g_content(A) subset B` -- a property Burgess never needs because his seed D0 includes all of B directly. The fix is seed realignment: replace the non-Burgess seed with Burgess's actual D0 seed, eliminating the unprovable `g_content_sub_B` sorry. Additionally, A7a was added as a separate axiom alongside BX7 (not replacing it), and SoundnessLemmas.lean has build errors in the A7a match arms that need mechanical fixes. Definition of done: all Chronicle sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 49** (this version): Burgess-to-codebase mapping table confirms 7 sorry sites across 3 files. g_content_sub_B is UNFIXABLE without density axiom -- Burgess seed bypass is the only path. SoundnessLemmas fix is 2 guard-swap errors (not 6 missing arms). A7a already added alongside BX7.
- **Handoff 48** (wave-1 partial): Phase 8a DCS revert DONE (Zorn sorry eliminated). Phase 8b A7a addition DONE but SoundnessLemmas has 6 missing match arms (report 49 says only 2 type errors remain in functions 3-4; functions 1-2 compile).

### Prior Plan Reference

Plan v34 had phases 1-5b-ii and 7 [COMPLETED], phases 8a and 8b [PARTIAL], phases 6, 9, 10, 11 [NOT STARTED]. Key lessons: (1) Replacing BX7 with A7a caused 32+ cascading failures -- adding A7a alongside BX7 is the correct approach. (2) DCS maximality revert succeeded and eliminated the Zorn sorry. (3) The g_content_sub_B sorry is unfixable without density and must be bypassed via Burgess seed realignment. (4) Phase sequencing validated: seed restructuring (2.6) must precede Lemma 2.7, which must precede C4/C4' and FUC/FSC.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all chronicle sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Fix SoundnessLemmas.lean build errors (A7a match arms)
- Replace non-Burgess seed in Lemma 2.6 with Burgess's D0 seed
- Archive dead code (g_content_sub_B, h_content_sub_B, splitting_seed_consistent) to Boneyard
- Rewrite Lemma 2.7 using Burgess's direct seed with A7a
- Close C4/C4' sorry sites using lemma_2_6_splitting + BurgessR3Maximal for adjacent pairs
- Close FUC/FSC coherence sorry sites
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary
- Update ROADMAP.md to reflect current chronicle status

**Non-Goals**:
- A4a removal (separate task 115)
- BXCanonical sorry closure (task 109)
- Removing BX7 (A7a coexists alongside BX7)
- Formalize Lemma 2.5 as standalone theorem (components exist, not needed)
- Formalize Lemma 2.8 (not needed for our C5 elimination scheme)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Burgess D0 seed consistency proof is complex with BX axioms (A4a/A5a/A7a adaptation) | H | M | Report 49 Section 4 provides the detailed adaptation path. BX5=A5a, A4a=BX14, A7a already added. Burgess's proof structure translates step by step. |
| Lemma 2.7 seed consistency with A7a is non-trivial | H | M | A7a is now in the codebase. Burgess's proof on p. 371 goes through directly: D1/D2 elimination via neg-U(gamma0, beta0 AND eta). D3 survives and gives U(xi, beta AND eta) via A3a. |
| C4 hard case requires c2' (BurgessR3Maximal for adjacent pairs) which was removed | M | L | c2' can be reconstructed at specific call sites from g_content subset relations + burgessR3Maximal_from_g_content_sub (now sorry-free after DCS revert). No need to restore as omega_chain invariant. |
| FUC/FSC coherence blocked by upstream sorry chains | M | L | Phase sequencing ensures all upstream sorries closed before FUC/FSC phase. C5 + C3 properties thread through Cantor isomorphism. |
| SoundnessLemmas fix is more than guard swaps | L | L | Handoff says the template from function 1 works; report 49 confirms only 2 type errors in the 2200+ line range. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4, 5 | 3 |
| 4 | 6, 7 | 3, 5 |
| 5 | 8 | 6, 7 |
| 6 | 9 | 8 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Review and Snapshot ROADMAP.md [COMPLETED]

**Goal**: Record current ROADMAP.md state before implementation changes, identify which items this task will advance.

**Tasks**:
- [ ] Read current ROADMAP.md and note chronicle sorry count (currently listed as 4)
- [ ] Identify roadmap items this task advances: chronicle sorry closure, representation theorem
- [ ] Record before-state: 4 chronicle sorry sites across 3 files, PointInsertion sorry-free

**Timing**: 0.25 hours

**Depends on**: none

**Files to modify**: None (read-only snapshot)

**Verification**:
- Before-state recorded for comparison in final phase

---

### Phase 2: Fix SoundnessLemmas.lean Build Errors [COMPLETED]

**Goal**: Fix the build-breaking A7a match arm issues in SoundnessLemmas.lean so that `lake build` succeeds. The handoff identifies 6 missing match arms across functions 2-4; report 49 identifies 2 type errors (guard swap) in functions 3-4.

**Tasks**:
- [ ] Check which functions are actually missing A7a cases vs which have type errors
- [ ] For missing cases: copy A7a template from `axiom_swap_valid` (function 1, line 766) into functions 2-4
- [ ] For type error cases: swap guard arguments in D3 case (`h_guard2 r ... h_guard1 r ...` instead of `h_guard1 r ... h_guard2 r ...`)
- [ ] Adjust proof style per function: direct-validity (functions 2, 4) vs swap style (function 3)
- [ ] Run `lake build` to confirm clean compilation

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- add/fix A7a match arms (~80 lines)

**Verification**:
- `lake build` succeeds
- No new sorry sites in SoundnessLemmas.lean

---

### Phase 3: Restructure Lemma 2.6 with Burgess D0 Seed [PARTIAL]

**Goal**: Replace the non-Burgess seed in `splitting_seed_consistent` and `lemma_2_6_splitting` with Burgess's actual D0 seed. This eliminates the need for `g_content_sub_B_of_BurgessR3Maximal` and `h_content_sub_B_of_BurgessR3Maximal` entirely, closing 2 sorry sites.

**Burgess D0 seed (Lemma 2.6, p. 371)**:
```
D0 = {S(alpha, beta) : alpha in A, beta in B}
     union B
     union {neg-delta}
     union {U(gamma, beta) : gamma in C, beta in B}
```

**D0 consistency proof (adapted from Burgess pp. 370-371)**:
1. Reduce to showing each zeta = S(alpha, beta) AND beta AND neg-delta AND U(gamma, beta) is consistent
2. From R(A,B,C) with delta not in B: obtain beta0 in B, gamma0 in C with neg-U(gamma0, beta0 AND delta) in A
3. WLOG beta0=beta, gamma0=gamma (replace with conjunctions)
4. From U(gamma,beta) in A and neg-U(gamma, beta AND delta) in A: A5a (BX5) gives U(gamma, beta AND U(gamma,beta)) in A
5. A4a (BX14) gives U(beta AND U(gamma,beta) AND neg-delta, beta) in A
6. A3a (BX13) gives U(beta AND U(gamma,beta) AND neg-delta AND S(alpha,beta), beta) in A
7. Lemma 2.2 (consistency criterion): zeta is consistent

**Tasks**:
- [ ] Define `burgess_D0_splitting` as a function computing D0 from A, B, C, delta
- [ ] Prove `burgess_D0_splitting_consistent` following the 7-step chain above
- [ ] Rewrite `lemma_2_6_splitting` to use burgess_D0_splitting as seed:
  - Lindenbaum to MCS D
  - Extract neg-delta in D (from seed)
  - Extract B subset D (from seed includes B)
  - Derive burgessR3(A, -, D) from S-formulas in seed
  - Derive burgessR3(D, -, C) from U-formulas in seed
  - Obtain B', B'' via burgessR3Maximal from the above
  - Show g_content(A) subset D and g_content(D) subset C
- [ ] Remove `h_gc` (g_content A subset C) hypothesis from lemma_2_6_splitting if no longer needed (D0 seed does not require it)
- [ ] Verify lemma_2_6_splitting compiles sorry-free
- [ ] Run `lake build`

**Timing**: 5 hours

**Depends on**: 2 (build must compile first)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- new D0 seed and consistency proof (~200 lines net), rewrite lemma_2_6_splitting (~50 lines)

**Verification**:
- `lemma_2_6_splitting` sorry-free
- No calls to `g_content_sub_B_of_BurgessR3Maximal` or `h_content_sub_B_of_BurgessR3Maximal`
- `lake build` succeeds

---

### Phase 4: Archive Dead Code to Boneyard [NOT STARTED]

**Goal**: Move code that is dead after Burgess seed restructuring to Boneyard/ for traceability. This includes g_content_sub_B, h_content_sub_B, the old splitting_seed_consistent, and supporting helpers.

**Tasks**:
- [ ] Create `Boneyard/NonBurgessSeed/` directory
- [ ] Move to boneyard (as commented-out code or separate file):
  - `g_content_sub_B_of_BurgessR3Maximal` (lines 824-850)
  - `h_content_sub_B_of_BurgessR3Maximal` (lines 853-875)
  - Old `splitting_seed_consistent` (lines 890-907)
  - `g_content_consistent_case` (line 785)
  - `G_conj_strengthen` (line 772)
  - `H_conj_strengthen` (line 803)
- [ ] Update stale docstrings (lines 877-886) to document Burgess seed
- [ ] Remove stale comments (lines 1055-1067) referencing removed code
- [ ] Run `lake build`

**Timing**: 1 hour

**Depends on**: 3 (dead code identified only after seed restructuring)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- remove dead code (~100 lines)
- `Boneyard/NonBurgessSeed/PointInsertionLegacy.lean` -- archive (~100 lines)

**Verification**:
- No references to archived functions in active code
- `lake build` succeeds
- PointInsertion.lean line count reduced

---

### Phase 5: Rewrite Lemma 2.7 with Burgess D0 Seed and A7a [NOT STARTED]

**Goal**: Implement Burgess's actual Lemma 2.7 proof (p. 371) using the A7a axiom. The current `lemma_2_7` is a sorry stub. With A7a in the codebase and Lemma 2.6's D0 seed pattern established in Phase 3, this phase follows the same pattern.

**Burgess D0 seed for Lemma 2.7 (p. 371)**:
```
D0 = {S(alpha, beta AND eta) : alpha in A, beta in B}
     union B
     union {xi}
     union {U(gamma, beta) : gamma in C, beta in B}
```

**Consistency proof (adapted from Burgess p. 371)**:
1. From eta not in B and maximality: obtain beta0 in B, gamma0 in C with neg-U(gamma0, beta0 AND eta) in A
2. WLOG beta0=beta, gamma0=gamma
3. BX5 on U(xi, eta): get U(xi AND U(xi,eta), eta) in A
4. BX5 on U(gamma, beta): get U(gamma AND U(gamma,beta), beta) in A
5. Apply A7a to these two enriched Until formulas (letting theta = beta AND U(gamma,beta) AND xi AND U(xi,eta)):
   - D1: U(gamma AND xi, theta) -- has event including beta AND eta components, eliminated by neg-U(gamma0, beta0 AND eta)
   - D2: U(gamma AND U(xi,eta), theta) -- same elimination
   - D3: U(beta AND U(gamma,beta) AND xi, theta) -- survives
6. A3a (BX13) on D3: get U(xi, beta AND eta) in A
7. Consistency of zeta = S(alpha, beta AND eta) AND beta AND xi AND U(gamma, beta) follows from Lemma 2.2

**Tasks**:
- [ ] Define `burgess_D0_until` computing D0 for Lemma 2.7
- [ ] Prove maximality extraction: from eta not in B, obtain beta0, gamma0, neg-U(gamma0, beta0 AND eta) in A
- [ ] Prove seed consistency using BX5 + A7a + BX13 chain (steps 3-7)
- [ ] Implement lemma_2_7 body:
  - Lindenbaum to MCS D with xi in D and B subset D
  - Derive burgessR3(A, -, D) from S(alpha, beta AND eta) formulas
  - Derive burgessR3(D, -, C) from U(gamma, beta) formulas
  - Obtain B', B'' via burgessR3Maximal
  - Show eta in B' from U(xi, beta AND eta) in A for all beta in B, plus maximality
- [ ] Verify lemma_2_7 compiles sorry-free
- [ ] Run `lake build`

**Timing**: 5 hours

**Depends on**: 3 (D0 seed pattern from Phase 3 serves as template)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- implement Lemma 2.7 (~200 lines)

**Verification**:
- `lemma_2_7` sorry-free
- PointInsertion.lean sorry count: 0
- `lake build` succeeds

---

### Phase 6: Close C4/C4' Sorry Sites [NOT STARTED]

**Goal**: Close the 2 sorry sites in CounterexampleElimination.lean (lines 412, 510) for the C4/C4' hard cases. These require BurgessR3Maximal for adjacent pairs + lemma_2_6_splitting.

**Approach**: For adjacent pair (w, w_next) in the chronicle domain:
1. From chronicle invariants: g_content(f(w)) subset g(w, w_next) subset f(w_next) via C2
2. `burgessR3Maximal_from_g_content_sub` gives BurgessR3Maximal(f(w), g(w, w_next), f(w_next)) -- this reconstructs c2' at specific call sites
3. Apply `lemma_2_6_splitting` with delta = gamma to get MCS D with neg-gamma in D

**Tasks**:
- [ ] Inspect C4 sorry at line 412 with `lean_goal` to understand exact proof obligation
- [ ] Construct BurgessR3Maximal for (f(w), g(w, w_next), f(w_next)) from chronicle invariants
- [ ] Apply lemma_2_6_splitting to get D with neg-gamma in D
- [ ] Close sorry at line 412
- [ ] Inspect C4' sorry at line 510 with `lean_goal`
- [ ] Close sorry at line 510 (Since direction mirror)
- [ ] Run `lake build`

**Timing**: 2 hours

**Depends on**: 3 (lemma_2_6_splitting sorry-free)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 2 sorry sites (~60 lines each)

**Verification**:
- CounterexampleElimination.lean sorry count: 0
- `lake build` succeeds

---

### Phase 7: Close FUC/FSC Coherence Sorry Sites [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for forward Until and forward Since coherence.

**Coherence argument**: With all upstream sorry sites closed and C5 + C3 available in the limit chronicle:
- For U(phi, psi) in f(t): C5 gives witness y > t with psi in f(y) and eta in g(t,y)
- For intermediate r with t < r < y: C3 gives g(t,y) subset g(t,r) inter f(r) inter g(r,y), so phi in f(r)
- The Cantor isomorphism maps chronicle witnesses to countermodel witnesses
- The limit_g function provides the interval values needed for guard membership

**Tasks**:
- [ ] Inspect FUC sorry at line 615 with `lean_goal`
- [ ] Trace how C5 is available in the limit chronicle (limit_satisfies_c5_weak + guard strengthening)
- [ ] Determine how Cantor isomorphism maps chronicle indices to Rat countermodel indices
- [ ] Close FUC sorry site (forward Until coherence)
- [ ] Close FSC sorry site (forward Since coherence, line 619)
- [ ] Run `lake build`

**Timing**: 3 hours

**Depends on**: 3 (Lemma 2.6 sorry-free for C3 decomposition), 5 (Lemma 2.7 sorry-free for C5 witnesses)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~80 lines each)

**Verification**:
- ChronicleToCountermodel.lean sorry count: 0
- `lake build` succeeds

---

### Phase 8: Final Audit and Validation [NOT STARTED]

**Goal**: Comprehensive verification that the chronicle construction is sorry-free and all axiom references are correct.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` -- verify no `sorryAx`
- [ ] Run `lake build` on full project -- verify no regressions
- [ ] Grep for sorry in all Chronicle/ files -- verify no sorry sites remain
- [ ] Grep for sorry in all BXCanonical/ files -- verify no new sorry sites introduced
- [ ] Verify A7a axiom documentation is accurate
- [ ] Verify BurgessR3Maximal documentation reflects DCS maximality
- [ ] Update module docstrings in Chronicle/ files to reflect final proof structure

**Timing**: 0.5 hours

**Depends on**: 6, 7

**Files to modify**:
- Documentation updates across Chronicle/ files

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments/docstrings
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- Full `lake build` clean

---

### Phase 9: Update ROADMAP.md [NOT STARTED]

**Goal**: Update ROADMAP.md to reflect completed chronicle sorry closure, marking completed items and updating sorry counts.

**Tasks**:
- [ ] Mark chronicle sorry sites as closed (update from "4 sorry sites" to "0 sorry sites")
- [ ] Update "Current state" in Chronicle Construction section
- [ ] Update sorry census tables (Chronicle: 0 sorries)
- [ ] Update PointInsertion.lean status (already sorry-free, confirm)
- [ ] Add completion annotation: `*(Completed: Task 107, 2026-04-30)*` to relevant items
- [ ] Update "Last updated" timestamp
- [ ] Note A7a axiom addition (coexisting with BX7)
- [ ] Run `lake build` (no code changes, just documentation)

**Timing**: 0.25 hours

**Depends on**: 8

**Files to modify**:
- `specs/ROADMAP.md` -- update chronicle status, sorry counts, completion annotations

**Verification**:
- ROADMAP.md reflects 0 chronicle sorry sites
- Sorry census table updated
- Completion annotation present

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] SoundnessLemmas.lean compiles clean after Phase 2
- [ ] `lemma_2_6_splitting` sorry-free after Phase 3 (Burgess D0 seed)
- [ ] No references to g_content_sub_B in active code after Phase 4
- [ ] `lemma_2_7` sorry-free after Phase 5 (A7a + Burgess seed)
- [ ] C4/C4' sorry sites (lines 412, 510) closed after Phase 6
- [ ] FUC/FSC sorry sites closed after Phase 7
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns no actual sorry usages after Phase 8
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] ROADMAP.md updated with completion annotations after Phase 9

## Artifacts & Outputs

- `plans/49_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` (A7a match arm fixes)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (Burgess D0 seed for 2.6 and 2.7)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (C4/C4' sorry closure)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (FUC/FSC closure)
- Created `Boneyard/NonBurgessSeed/PointInsertionLegacy.lean` (archived dead code)
- Updated `specs/ROADMAP.md` (chronicle completion)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **Burgess D0 seed consistency proof too complex**: If the BX5+BX14+BX13 chain does not translate from Burgess pp. 370-371, Xu's alternative construction (Report 48, Finding 3) avoids the full seed and works with weaker output. This is a viable fallback but defers the full Lemma 2.6.
- **Lemma 2.7 A7a chain fails**: If D1/D2 elimination via neg-U(gamma0, beta0 AND eta) does not work with our Until convention, the two-step BX7 derivation chain (handoff 48) serves as insurance: derive A7a-like output from two applications of BX7. This is a workaround, not the recommended approach.
- **C4 hard case cannot reconstruct c2'**: If `burgessR3Maximal_from_g_content_sub` does not provide BurgessR3Maximal for adjacent pairs, c2' can be re-added as a local lemma in CounterexampleElimination.lean rather than an omega_chain invariant.
- **FUC/FSC blocked by C5 guard weakness**: If the current C5 guard (domain points only) is insufficient for the full truth lemma, Phase 7 may need strengthening of C5's guard to cover all intermediate points. This is noted in report 49 Section 1 (C5 row).
- Git history preserves all prior states; each phase is independently committable.
