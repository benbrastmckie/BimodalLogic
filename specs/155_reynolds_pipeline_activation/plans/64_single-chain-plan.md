# Implementation Plan: Task #155 (v66 -- Single-Chain Focus)

- **Task**: 155 - Eliminate all sorries from completeness_discrete by fixing the single sorry chain through chronicle_gap_contradiction via stage induction on the omega-chain construction
- **Status**: [NOT STARTED]
- **Effort**: 6-10 hours
- **Dependencies**: None (Phases 1 and 2 from plan v62 are completed)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/62_blocker-literature-research.md, specs/155_reynolds_pipeline_activation/reports/61_blocker-escalation-research.md, specs/155_reynolds_pipeline_activation/reports/58_proper-fix-research.md
- **Artifacts**: plans/64_single-chain-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan v66 replaces plan v64 based on a critical new finding: there is only ONE sorry chain blocking `completeness_discrete`, not two. The sorry chain is:

```
completeness_discrete (Completeness.lean:309)
  -> countermodel_discrete_reynolds (Transfer.lean:1203)
    -> cantor_bfmcs_discrete_restricted_tc (ChronicleToCountermodel.lean:1992)
    -> cantor_bfmcs_discrete_restricted_fuc (ChronicleToCountermodel.lean:2048)
      -> succ_embed_surjective (ChronicleToCountermodel.lean:1666)
        -> limitDomSubtype_isSuccArchimedean (ChronicleToCountermodel.lean:789)
          -> succ_cofinal (ChronicleToCountermodel.lean:773)
            -> chronicle_gap_contradiction (ChronicleToCountermodel.lean:486) [SORRY]
```

The Chain 1 sorry (`nf_2var_existential_transfer` in StaviCompleteness.lean) does NOT flow into `completeness_discrete`. It only affects `stavi_expressive_completeness`, which is used by the general model surgery pipeline but NOT by `countermodel_discrete_reynolds`. All Chain 1 work (Phase 3 of plan v64) is deferred.

The old proof of `chronicle_gap_contradiction` (lines 488-762, commented out) is fundamentally flawed: it uses single-predicate contemp_equiv which trivially holds in discrete Prior structures at any depth, making the approach unworkable.

**Strategy**: Path D -- fix boundary cases in `succ_reaches_dom_N` via stage induction on the omega-chain construction. The chronicle limit domain is built incrementally from finite models. At each stage, the domain is finite (hence trivially succ-Archimedean). The limit must preserve this because every point enters at some finite stage. The boundary cases (Cases 3a and 3b at lines ~236 and ~392) need analysis using `omega_chain_dom_new_unique` at successive stages. This directly proves `IsSuccArchimedean`, which unblocks `succ_cofinal`, which unblocks `chronicle_gap_contradiction`, which cascades through the entire sorry chain to `completeness_discrete`.

Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes, no `axiom` declarations outside the proof system or frame constraints.

### Research Integration

- **Report 62 (blocker literature)**: Primary input for this revision. Established the single sorry chain, confirmed Chain 1 is not on critical path, identified Path D (stage induction) as recommended resolution with ~150-300 lines.
- **Report 61 (blocker escalation)**: Identified `nf_2var_existential_transfer` as Chain 1 root sorry. Confirmed GoodStructuresModelSurgery is sorry-free.
- **Report 58 (proper fix research)**: Confirmed model surgery cannot prove IsSuccArchimedean (second-order property). Supports stage induction approach.

### Prior Plan Correction

Plan v64 Phase 3 (prove `nf_2var_existential_transfer`) is DEFERRED -- not on critical path for `completeness_discrete`. Plan v64 Phase 4 (restructure coherence via k-equivalence) is REPLACED -- the research shows that k-equivalence cannot give concrete succ-reachability witnesses. Instead, we prove IsSuccArchimedean directly via the omega-chain construction, which makes the existing `succ_embed_surjective`-based coherence proofs sorry-free without restructuring.

### Roadmap Alignment

- Closing the single sorry chain achieves sorry-free `completeness_discrete`
- Eliminates all axiom declarations outside the proof system
- Advances critical path: Task 155 -> sorry-free `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Fix boundary cases in `succ_reaches_dom_N` (Cases 3a and 3b) to prove the full stage-induction argument
- This makes `limitDomSubtype_isSuccArchimedean` sorry-free
- Which makes `succ_cofinal` sorry-free
- Which makes `chronicle_gap_contradiction` sorry-free
- Which cascades to make `succ_embed_surjective`, `cantor_bfmcs_discrete_restricted_tc/fuc`, `countermodel_discrete_reynolds`, and finally `completeness_discrete` sorry-free
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes
- No `axiom` declarations outside the proof system or frame constraints

**Non-Goals**:
- Proving `nf_2var_existential_transfer` (Chain 1, not on critical path for `completeness_discrete` -- deferred)
- Building the EF Game Bridge in NFGameBridge.lean (deferred)
- Restructuring coherence conditions via k-equivalence (unnecessary if IsSuccArchimedean is proved)
- Proving `stavi_expressive_completeness` (separate concern, not blocking `completeness_discrete`)
- Fixing the general `completeness` theorem (uses Base frame class, separate task 129)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `omega_chain_dom_new_unique` does not provide sufficient information about where new points enter relative to existing domain boundaries | H | M | The existing sorry-free lemma gives uniqueness of the new point at each stage. If the ordering relationship (above-max or below-min) is hard to establish, use the chronicle's embedding properties (`chronicle_embedding_preserves_order`) to relate stage N and stage N+1 orderings. |
| succ on the limit domain does not agree with stage-N successor for points at stage N | H | L | The chronicle construction defines limit_succ from the colimit of stage successors. The agreement should follow from `omega_chain_succ_compat` or similar compatibility lemmas. If missing, prove it as a ~20-line lemma. |
| Boundary cases require more than 80 lines each, pushing total beyond 300 lines | M | M | Even at 400 lines total, this is still the most efficient path. The structure is mechanical: case split on where a and b enter, use finite-stage Archimedean property, propagate through embeddings. |
| Path D fails entirely due to unforeseen structural issue in the omega-chain | H | L | Fall back to Path E: restructure `cantor_bfmcs_discrete_restricted_tc/fuc` to use limit-domain indices directly, bypassing `succ_embed_surjective` entirely (~300-500 lines). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases are strictly sequential.

### Phase 1: Fix succ_reaches_dom_N boundary cases (Path D) [BLOCKED]

**Goal**: Complete the stage-induction proof in `succ_reaches_dom_N` by fixing Cases 3a (above-max, line ~236) and 3b (below-min, line ~392). This directly proves `IsSuccArchimedean` for `LimitDomSubtype`.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- The proof `succ_reaches_dom_N` (ChronicleToCountermodel.lean, lines 98-398) is a stage induction showing: for any a, b in the limit domain with a < b, if both a and b are in dom(N) for some stage N, then succ^k(a) >= b for some k.
- The two sorry sites are at Cases 3a (~line 236) and 3b (~line 392), corresponding to boundary cases where either b is above max(dom(N)) or a is below min(dom(N)).
- **Case 3a (above-max)**: b is above max(dom(N)). At stage N+1, exactly one new point enters above max(dom(N)) (by `omega_chain_dom_new_unique`). Show that iterated successor from max(dom(N)) reaches this new point, then apply the inductive hypothesis at stage N+1 where the domain is larger.
- **Case 3b (below-min)**: Symmetric to Case 3a. a is below min(dom(N)). Show that iterated predecessor reaches into dom(N), then apply IH.
- Use `omega_chain_dom_new_unique` (sorry-free) to establish that exactly one new point enters at each stage.
- The key insight: at each stage, the finite domain is trivially succ-Archimedean. The induction shows that as the domain grows, succ-reachability is preserved because new points are "adjacent" to the existing domain boundary.
- Do NOT attempt to prove `chronicle_gap_contradiction` directly. Do NOT use the contemp_equiv / model surgery approach. Do NOT use k-equivalence. Focus exclusively on the omega-chain stage induction.
- Do NOT use `sorry` or `axiom` as fallbacks. If blocked, report what was tried and what goal state was reached.

**BLOCKER** (Phase 1):
- **What failed**: Cases 3a (line 236) and 3b (line 392) of `succ_reaches_dom_N` cannot be completed because the limit domain successor `limitDomSubtype_succ` is defined over the FULL limit domain (union of all stages), not relative to a single stage. Between two adjacent dom(N) points, infinitely many limit_dom points can be inserted by later stages, making succ iterations from one dom(N) point unable to reach the other in finitely many steps.
- **What was tried**:
  1. Stage induction (Path D): For Case 3a, b is above max(dom(N)) and is the unique new point at N+1. succ(max_N) in the limit domain is NOT necessarily b -- it could be a point that entered at a later stage between max_N and b. The code's own comments (lines 226-236) document this gap.
  2. C4 contrapositive propagation: F(phi) can be propagated along the Z-chain via limit_satisfies_c4, but the process may not terminate if the F-witness y is on a different Z-chain than the current chain (restricted_tc is genuinely false in the multi-chain case).
  3. Model surgery via reynolds_model_surgery_core: Proves the entire domain is one contemp_equiv class. But one contemp_equiv class does NOT imply one Z-chain (IsSuccArchimedean). The class is a semantic equivalence, not a structural isomorphism.
  4. Z1 axiom exploitation: Z1 characterizes IsSuccArchimedean frames, and Z1 is in every MCS. But proving Z1 holds semantically requires the truth lemma, which requires restricted_tc, which requires IsSuccArchimedean -- creating a circularity.
- **Why it's stuck**: The fundamental issue is that the omega chain construction can insert infinitely many domain points between any two given points via the counterexample enumeration. Each C4/C5 counterexample can insert one point, and infinitely many counterexamples can target the interval between any two given points. This makes the limit domain potentially multi-Z-chain, even though the model surgery proves it has one contemp_equiv class. The gap between "one contemp_equiv class" and "one Z-chain" (IsSuccArchimedean) is genuine and cannot be bridged by the current approach.
- **What is needed**: Either (a) a proof that the omega chain construction produces a single Z-chain (requiring new structural lemmas about the counterexample enumeration and point placement), or (b) Path E: restructure `cantor_bfmcs_discrete_restricted_tc/fuc` to work over the limit domain directly rather than over Z, bypassing `succ_embed_surjective` entirely (estimated 300-500 lines). See plan Rollback/Contingency section.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Tasks**:
- [x] **Task 1.1**: Read and understand the existing `succ_reaches_dom_N` proof structure (ChronicleToCountermodel.lean, lines 98-398). *(completed -- goal states inspected, boundary case analysis complete)*

- [ ] **Task 1.2**: Fix Case 3a (above-max, ~line 236). *(deviation: blocked — limit_dom succ may not reach b because infinitely many points can be inserted between max_N and b by later stages; succ(max_N) in the limit is not necessarily b)* Strategy:
  - Use `omega_chain_dom_new_unique` to identify the single new point p_{N+1} entering at stage N+1 above max(dom(N))
  - Show succ(max_N) = p_{N+1} or succ(max_N) >= p_{N+1} using the chronicle construction's successor compatibility
  - If b = p_{N+1}, then succ^k(a) reaches max_N (by IH at stage N since both a, max_N are in dom(N)), then one more step reaches p_{N+1} = b
  - If b > p_{N+1}, apply IH at stage N+1 where dom(N+1) includes p_{N+1}
  - Estimated ~50-80 lines

- [ ] **Task 1.3**: Fix Case 3b (below-min, ~line 392). *(deviation: blocked — symmetric to Case 3a; same infinite insertion issue applies)* Symmetric argument:
  - Use `omega_chain_dom_new_unique` for the new point below min(dom(N))
  - Show pred(min_N) or the new point is reachable
  - Apply IH at stage N+1
  - Estimated ~50-80 lines

- [ ] **Task 1.4**: Verify the completed `succ_reaches_dom_N` compiles and prove `limitDomSubtype_isSuccArchimedean` from it: *(deviation: blocked — depends on Tasks 1.2 and 1.3)*
  - `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes
  - `lean_verify succ_reaches_dom_N` shows no `sorryAx`
  - `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
  - No new sorry or axiom introduced

**Timing**: 3-6 hours

**Depends on**: none (Phases 1-2 of plan v62 already completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (fix Cases 3a and 3b in `succ_reaches_dom_N`, estimated 100-160 lines of new proof code)

**Verification**:
- `lean_verify succ_reaches_dom_N` shows no `sorryAx`
- `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes
- No new sorry or axiom introduced

---

### Phase 2: Wire IsSuccArchimedean through the sorry chain [NOT STARTED]

**Goal**: Verify that the now sorry-free `limitDomSubtype_isSuccArchimedean` cascades through `succ_cofinal` -> `chronicle_gap_contradiction` -> `succ_embed_surjective` -> `cantor_bfmcs_discrete_restricted_tc/fuc` -> `countermodel_discrete_reynolds` -> `completeness_discrete`. Fix any remaining wiring issues.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- With `limitDomSubtype_isSuccArchimedean` sorry-free (Phase 1), the existing downstream proofs should already be sorry-free because they depend on it transitively.
- The chain is: `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` -> `chronicle_gap_contradiction` -> `succ_embed_surjective` -> `cantor_bfmcs_discrete_restricted_tc` / `cantor_bfmcs_discrete_restricted_fuc` -> `countermodel_discrete_reynolds` -> `completeness_discrete`
- The wiring should be automatic -- no new proof code needed if the existing proofs already use `limitDomSubtype_isSuccArchimedean` as a hypothesis or call it directly.
- If any lemma in the chain still shows `sorryAx`, trace the dependency to find the remaining sorry source and fix it.
- Focus on building and checking, not writing new proofs. This phase is primarily verification with targeted fixes.

**Tasks**:
- [ ] **Task 2.1**: Build the full project with `lake build` and check for errors. If the build passes, proceed to verification.

- [ ] **Task 2.2**: Verify the sorry chain is eliminated:
  - `lean_verify succ_cofinal` -- no `sorryAx`
  - `lean_verify chronicle_gap_contradiction` -- no `sorryAx`
  - `lean_verify succ_embed_surjective` -- no `sorryAx`
  - `lean_verify cantor_bfmcs_discrete_restricted_tc` -- no `sorryAx`
  - `lean_verify cantor_bfmcs_discrete_restricted_fuc` -- no `sorryAx`
  - `lean_verify countermodel_discrete_reynolds` -- no `sorryAx`
  - `lean_verify completeness_discrete` -- no `sorryAx`

- [ ] **Task 2.3**: If any verification fails, identify the remaining sorry source. Common issues:
  - A lemma calls another sorry'd lemma not in the chain (check `#print axioms`)
  - A type mismatch requires adapting the IsSuccArchimedean result to the expected form
  - Fix the wiring issue (estimated 0-50 lines per issue)

- [ ] **Task 2.4**: Verify no extraneous axioms:
  - `grep -rn "^axiom " Theories/` -- only proof system and frame constraint axioms
  - `grep -rn "^\s*sorry" Theories/` -- check for remaining sorry statements (some may exist in Chain 1 / Stavi path, which is expected and acceptable)

**Timing**: 1-2 hours

**Depends on**: 1

**Files to modify**:
- None expected (verification only), unless wiring issues are found
- If wiring needed: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (minor adaptations)

**Verification**:
- `lean_verify completeness_discrete` shows no `sorryAx`
- `lake build` passes with zero errors
- No new sorry or axiom introduced

---

### Phase 3: Full build verification and documentation cleanup [NOT STARTED]

**Goal**: Final verification that `completeness_discrete` is sorry-free. Clean up documentation to reflect the new sorry status.

**Tasks**:
- [ ] **Task 3.1**: Final completeness verification:
  - `#print axioms completeness_discrete` -- NO `sorryAx`
  - `lake build` -- zero errors (full project)
  - `grep -rn "^\s*sorry" Theories/` -- document which sorry statements remain (expected: only Chain 1 / Stavi path)
  - `grep -rn "^axiom " Theories/` -- verify no axiom declarations outside proof system/frame constraints

- [ ] **Task 3.2**: Update docstrings in ChronicleToCountermodel.lean:
  - Update file-level docstring (lines 57-91) to note that `succ_reaches_dom_N` is now sorry-free and proves IsSuccArchimedean via stage induction
  - Update docstring at lines 782-787 (above `limitDomSubtype_isSuccArchimedean`) to note it is now proved via `succ_reaches_dom_N`
  - Mark the old commented-out proof of `chronicle_gap_contradiction` (lines 488-762) as "DEAD CODE -- superseded by stage induction approach via succ_reaches_dom_N"

- [ ] **Task 3.3**: Update audit section in Completeness.lean (lines 376-388) to reflect sorry-free status for `completeness_discrete`.

- [ ] **Task 3.4**: Write execution summary at `specs/155_reynolds_pipeline_activation/summaries/64_execution-summary.md`.

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update audit comments

**Verification**:
- `lake build` still passes
- All docstrings accurately reflect the current sorry status

## Testing & Validation

- [ ] `lean_verify succ_reaches_dom_N` shows no `sorryAx`
- [ ] `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
- [ ] `lean_verify succ_cofinal` shows no `sorryAx`
- [ ] `lean_verify chronicle_gap_contradiction` shows no `sorryAx`
- [ ] `lean_verify succ_embed_surjective` shows no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_tc` shows no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_fuc` shows no `sorryAx`
- [ ] `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `lean_verify completeness_discrete` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry statements introduced (`grep -rn "^\s*sorry" Theories/`)
- [ ] No `axiom` declarations outside proof system (`grep -rn "^axiom " Theories/`)

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/64_single-chain-plan.md` (this file, v66)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (fix Cases 3a/3b in `succ_reaches_dom_N`: ~100-160 lines; docstring updates)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (docstring updates)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/64_execution-summary.md`

## Rollback/Contingency

If Path D (stage induction in `succ_reaches_dom_N`) fails:

1. **Fallback -- Path E (restructure restricted coherence)**: Instead of proving IsSuccArchimedean, restructure `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc` to use limit-domain indices directly, bypassing `succ_embed_surjective` entirely. This requires restructuring the parametric canonical model to be parametric over the index set rather than Z. Estimated 300-500 lines, high confidence but more invasive.

2. **Fallback -- Plan v64 Phase 4 (k-equivalence restructuring)**: Restructure `countermodel_discrete_reynolds` to use `chronicle_is_good_direct` to get k-equivalence to Z, then transfer the countermodel directly. The research (report 62) warns that k-equivalence does not give concrete succ-reachability, but it may suffice if the coherence conditions can be formulated in terms of first-order sentences rather than explicit witness positions.

3. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to restore files. Phase 1 and Phase 2 changes from plan v62 are preserved on separate commits.
