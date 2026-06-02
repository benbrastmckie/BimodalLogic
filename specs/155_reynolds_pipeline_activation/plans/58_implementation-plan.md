# Implementation Plan: Task #155 (v59)

- **Task**: 155 - Prove IsSuccArchimedean for the discrete chronicle limit domain via stage induction
- **Status**: [NOT STARTED]
- **Effort**: 6-10 hours
- **Dependencies**: None
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/55_team-research.md, specs/155_reynolds_pipeline_activation/reports/56_phase2-blocker-research.md, specs/155_reynolds_pipeline_activation/reports/58_proper-fix-research.md
- **Artifacts**: plans/58_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Prove `IsSuccArchimedean` for `LimitDomSubtype` in the discrete case by proving that the interval `limit_dom ∩ (p, p')` is finite for any two adjacent points in a finite stage `dom(N)`. This eliminates the sorry chain through `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` -> `chronicle_gap_contradiction` [sorry], making `completeness_discrete` axiom-free without introducing any `axiom` declarations outside the proof system.

Phase 1 (import cycle resolution) is already completed from plan v56. The remaining work is concentrated in `ChronicleToCountermodel.lean`, where the sorry-bearing `limitDomSubtype_isSuccArchimedean` definition (line 789) must be replaced with a genuine proof via the finite interval argument.

Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes, no `axiom` declarations outside the proof system or frame constraints.

### Research Integration

- **Report 55** (team research round 8): Identified import cycle as sole GoodStructures.lean sorry source, cascade through sorry-free model surgery infrastructure.
- **Report 56** (phase 2 blocker research): Identified that `chronicle_gap_contradiction` is dead BX code. Mapped the real sorry chain: `completeness_discrete` -> `countermodel_discrete_reynolds` -> `restricted_tc/fuc` -> `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` -> `chronicle_gap_contradiction` [sorry].
- **Report 58** (proper fix research): Diagnosed that model surgery (chronicle_gap_contradiction) can never prove IsSuccArchimedean (second-order property). Recommends Path A: prove `IsSuccArchimedean` directly via finite interval argument. Key insight: successor stability -- once `succ(q) = s` is established in the limit, no further points appear between them. Estimated 300-500 lines.

### Prior Plan Reference

Plans v56-v58 had 4 phases each. Phase 1 completed (import cycle resolved). Plan v57 targeted omega-chain stage induction for `succ_embed_surjective` directly but hit a boundary case blocker. Plan v58 introduced a named axiom as a stopgap. This v59 plan replaces the axiom approach with the genuine proof recommended by report 58: prove `IsSuccArchimedean` via the finite interval argument, then let `succ_embed_surjective` use it through the existing code path.

### Roadmap Alignment

- Closing the sorry chain achieves sorry-free `completeness_discrete`
- Eliminates all axiom declarations outside the proof system (the deleted axiom was a stopgap)
- Advances the critical path: Task 155 -> sorry-free `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Prove `limitDomSubtype_isSuccArchimedean` without sorry (replacing the sorry-bearing definition at line 789)
- The existing `succ_embed_surjective` (line 1666) already uses `limitDomSubtype_isSuccArchimedean` at line 1673, so proving it closes the chain
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes
- No `axiom` declarations outside the proof system or frame constraints

**Non-Goals**:
- Proving `chronicle_gap_contradiction` (dead BX pipeline code, provably impossible via model surgery)
- Modifying `succ_embed_surjective` proof body (it already uses `limitDomSubtype_isSuccArchimedean` correctly)
- Resolving Stavi completeness sorries (not on this critical path)
- Modifying GoodStructures.lean or NoGapsDiscreteProof.lean (Phase 1 work preserved)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Finite interval proof harder than estimated | H | M | Report 58 identifies two strategies: (a) successor stability argument via `limit_dom_has_succ`, (b) contrapositive via accumulation point contradicting discreteness. Both are analyzed in detail. |
| Missing omega-chain infrastructure lemmas | M | M | Check for `omega_chain_dom_mono`, `dom_new_unique`, `limit_dom_has_succ` before starting proof. These are referenced in report 58 and should exist in ChronicleToCountermodelBasic.lean. |
| `succ_cofinal` or `succ_orbit_convex` dependencies need updating | L | L | The existing `limitDomSubtype_isSuccArchimedean` uses `succ_cofinal` -> `succ_orbit_convex`. The new proof replaces the body entirely, so these dependencies are severed. |
| Large proof size exceeds file limits | L | L | ChronicleToCountermodel.lean is already large. New lemmas can be placed in a dedicated section before the existing dead code block. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Resolve import cycle and close no_gaps_discrete [COMPLETED]

**Goal**: Close the sorry at GoodStructures.lean:855 by extracting `no_gaps_discrete` into `NoGapsDiscreteProof.lean`.

**Tasks**:
- [x] Created `NoGapsDiscreteProof.lean` importing GoodStructuresModelSurgery
- [x] Removed `no_gaps_discrete` and `one_class` from GoodStructures.lean
- [x] `no_gaps_discrete` delegates to `no_gaps_discrete_model_surgery` via `exact`
- [x] `lake build` passes (1681 jobs, zero errors)
- [x] GoodStructures.lean has zero sorries

**Timing**: 2 hours

**Depends on**: none

**Completed**: 2026-06-02

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean` (new)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (removed sorry)

---

### Phase 2: Prove IsSuccArchimedean for LimitDomSubtype via stage induction [NOT STARTED]

**Goal**: Replace the sorry-bearing `limitDomSubtype_isSuccArchimedean` definition (line 789) with a genuine proof that the limit domain's successor structure is Archimedean. The key mathematical claim: for adjacent points `p, p'` in any finite stage `dom(N)`, the set `limit_dom ∩ (p, p')` is finite, so `succ`-iterates from `p` reach `p'`.

**Approach (from report 58, Path A)**:

The proof has three layers:

1. **Successor stability**: `limit_dom_has_succ` (ChronicleToCountermodelBasic.lean) proves that every point `w` has an immediate successor `s` with no limit_dom points between them. By definition of limit_dom as the union of all stages, once `succ(w) = s` is established, no stage can insert a point between `w` and `s` (any such point would be in limit_dom, contradicting "no limit_dom points between").

2. **Finite interval**: For adjacent `p, p'` in `dom(N)`, prove `Set.Finite (limit_dom ∩ Set.Ioo p p')`. Strategy: each point `q` in `limit_dom ∩ (p, p')` entered at some finite stage via `dom_new_unique`. The successor pairs established by successor stability partition the interval. Because the construction adds at most one point per stage (`dom_new_unique`), and successor stability prevents unbounded accumulation, the interval is finite. Alternative: contrapositive -- an infinite discrete bounded subset of Q has an accumulation point, which contradicts discreteness of limit_dom.

3. **IsSuccArchimedean from finite interval**: Given `a ≤ b` in LimitDomSubtype, both are in `dom(N)` for some `N`. The dom(N)-points between them form a finite chain. Between adjacent dom(N) pairs, limit_dom intersections are finite (layer 2). So the total succ-chain from `a` to `b` has finite length.

**Tasks**:
- [ ] **Task 2.1**: Audit omega-chain infrastructure. Verify availability of key lemmas in ChronicleToCountermodel.lean and ChronicleToCountermodelBasic.lean:
  - `limit_dom_has_succ` (immediate successor existence with no interleaving points)
  - `omega_chain_dom_mono` or monotonicity of domain stages
  - `dom_new_unique` (at most one new point per stage)
  - `zero_mem_limit_dom` (root is in limit_dom)
  - `counterexample_enum_surjective_above` (enumeration coverage)
  - Document line numbers, exact signatures, and any gaps.
- [ ] **Task 2.2**: Prove successor stability lemma -- once `succ(q) = s` in limit_dom, no limit_dom point exists strictly between `q` and `s`:
  ```
  theorem limit_dom_succ_stable : ∀ q s, (q in limit_dom) → (s in limit_dom) →
    (s = succ(q)) → ¬∃ r ∈ limit_dom, q < r ∧ r < s
  ```
  This should follow directly from the definition of limit_dom_has_succ.
- [ ] **Task 2.3**: Prove finite interval lemma -- between adjacent dom(N) points, only finitely many limit_dom points exist:
  ```
  theorem limit_dom_interval_finite (p p' : Q) (hp : p ∈ limit_dom) (hp' : p' ∈ limit_dom)
    (hpp' : p < p') (h_adj : ∀ w ∈ dom(N), w ≤ p ∨ p' ≤ w) :
    Set.Finite (limit_dom ∩ Set.Ioo p p')
  ```
  Proof strategy: each point in the interval has a unique entry stage. The successor pairs partition the interval into finitely many segments. Use induction on the omega chain or the contrapositive accumulation argument.
- [ ] **Task 2.4**: Prove `succ_cofinal` without sorry -- given `a < b` in LimitDomSubtype, show `∃ n, b ≤ succ^[n](a)`:
  - Both `a` and `b` are in `dom(N)` for some `N`
  - The dom(N)-points between them form a finite chain
  - Between adjacent pairs, the succ-chain has finite length (from Task 2.3)
  - Sum the chain lengths
- [ ] **Task 2.5**: Replace the body of `limitDomSubtype_isSuccArchimedean` (line 789-806) with the genuine proof:
  - The existing definition structure (line 796-806) uses `succ_cofinal` + `succ_orbit_convex`
  - Replace the `succ_cofinal` call with the new sorry-free version from Task 2.4
  - Alternatively, rewrite the entire body to use the new finite interval lemma directly
- [ ] **Task 2.6**: Verify the new proof compiles:
  - `lean_verify limitDomSubtype_isSuccArchimedean` -- confirm no `sorryAx`
  - `lean_verify succ_embed_surjective` -- confirm no `sorryAx` (it uses `limitDomSubtype_isSuccArchimedean` at line 1673)
  - `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes

**Timing**: 4-6 hours (300-500 lines, concentrated in ChronicleToCountermodel.lean)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
  - Add new lemmas (successor stability, finite interval, succ_cofinal replacement) in a new section before the dead BX pipeline code block (before line 472)
  - Replace body of `limitDomSubtype_isSuccArchimedean` (lines 789-806) with genuine proof

**Verification**:
- `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
- `lean_verify succ_embed_surjective` shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes

---

### Phase 3: Verify completeness_discrete is sorry-free [NOT STARTED]

**Goal**: Confirm the full chain from `completeness_discrete` down through `succ_embed_surjective` is now sorry-free.

**Tasks**:
- [ ] `lean_verify completeness_discrete` -- confirm no `sorryAx`
- [ ] `lean_verify countermodel_discrete_reynolds` -- confirm no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_tc` -- confirm no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_fuc` -- confirm no `sorryAx`
- [ ] `lean_verify succ_embed_surjective` -- confirm no `sorryAx`
- [ ] `lake build` passes with zero errors (full project)
- [ ] Run `grep -rn "^\s*sorry" Theories/` and verify no new sorry statements introduced
- [ ] Verify no `axiom` declarations outside proof system/frame constraints: `grep -rn "^axiom " Theories/` should show only proof-system axioms

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- None expected (verification only), unless sorry traces are found

**Verification**:
- `#print axioms completeness_discrete` -- NO `sorryAx`
- `lake build` -- zero errors
- No new sorry statements
- No extraneous axiom declarations

---

### Phase 4: Clean up dead code and update documentation [NOT STARTED]

**Goal**: Update docstrings referencing the deleted axiom and the old sorry chain. Optionally mark dead BX pipeline code for archival.

**Tasks**:
- [ ] Update the file-level docstring at ChronicleToCountermodel.lean lines 57-91 to reflect that `limitDomSubtype_isSuccArchimedean` is now proved directly (no axiom, no sorry)
- [ ] Update the docstring at lines 782-787 (above `limitDomSubtype_isSuccArchimedean`) to note it is now sorry-free via the finite interval proof
- [ ] Update the docstring at lines 808-817 (Collapse-Based Discrete Pipeline section) to note the axiom has been replaced by a genuine proof
- [ ] Update the `succ_embed_surjective` docstring (lines 1658-1664) to note the full chain is sorry-free
- [ ] Update the audit section in Completeness.lean to reflect sorry-free status for `completeness_discrete`
- [ ] Mark dead BX pipeline code (lines 472-780: `chronicle_gap_contradiction`, `succ_cofinal` old version) with clear "DEAD CODE" annotations for future archival by task 255
- [ ] Write execution summary at `specs/155_reynolds_pipeline_activation/summaries/58_execution-summary.md`

**Timing**: 1 hour

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update audit comments

**Verification**:
- `lake build` still passes
- All docstrings accurately reflect the current sorry status

## Testing & Validation

- [ ] `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
- [ ] `lean_verify succ_embed_surjective` shows no `sorryAx`
- [ ] `lean_verify completeness_discrete` shows no `sorryAx`
- [ ] `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_tc` shows no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_fuc` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry statements introduced (`grep -rn "^\s*sorry" Theories/`)
- [ ] No `axiom` declarations outside proof system (`grep -rn "^axiom " Theories/`)
- [ ] Dead code in ChronicleToCountermodel.lean (`succ_cofinal` old, `chronicle_gap_contradiction`) not accidentally activated

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/58_implementation-plan.md` (this file, v59)
- Modified `ChronicleToCountermodel.lean` (new IsSuccArchimedean proof, ~300-500 lines)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/58_execution-summary.md`

## Rollback/Contingency

If the finite interval proof (Phase 2) hits a wall:

1. **Fallback A**: Contrapositive argument. If `limit_dom ∩ (p, p')` were infinite, extract a strictly increasing omega-sequence. Its accumulation point in R either (a) is in limit_dom, contradicting `limit_dom_has_succ` (no immediate predecessor from the convergent side), or (b) is not in limit_dom, creating a gap that the succ-chain cannot cross. Case (b) is the Z+Z scenario, which must be ruled out by the omega-chain construction's connectivity.

2. **Fallback B**: Restructure `restricted_tc` and `restricted_fuc` to avoid surjectivity entirely (Path C from report 58). Work directly with LimitDomSubtype instead of converting to Z. Higher effort (~500+ lines) but avoids the finite interval difficulty.

3. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to restore the file. Phase 1 changes (NoGapsDiscreteProof.lean, GoodStructures.lean) are unaffected.
