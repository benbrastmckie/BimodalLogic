# Implementation Plan: Task #155 (v57)

- **Task**: 155 - Close sorry chain to completeness_discrete via omega-chain surjectivity
- **Status**: [NOT STARTED]
- **Effort**: 6-10 hours
- **Dependencies**: None
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/55_team-research.md, specs/155_reynolds_pipeline_activation/reports/56_phase2-blocker-research.md
- **Artifacts**: plans/56_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the sorry chain blocking `completeness_discrete` by proving `succ_embed_surjective` directly via omega-chain induction, bypassing the dead `succ_cofinal`/`chronicle_gap_contradiction` BX pipeline. Phase 1 of plan v56 succeeded: `NoGapsDiscreteProof.lean` was created, resolving the import cycle so `GoodStructures.lean` has zero sorries. Phase 2 of plan v56 was blocked because it targeted `chronicle_gap_contradiction` -- dead BX pipeline code NOT on the critical path. The blocker research (report 56) identified the actual sorry chain and recommends Path A: prove surjectivity from the omega-chain construction's stage-induction structure.

Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes.

### Research Integration

- **Report 55** (team research round 8): Identified import cycle as sole GoodStructures.lean sorry, cascade through sorry-free model surgery infrastructure.
- **Report 56** (phase 2 blocker research): Identified that `chronicle_gap_contradiction` is dead BX code. Mapped the real sorry chain: `completeness_discrete` -> `countermodel_discrete_reynolds` -> `restricted_tc/fuc` -> `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` -> `chronicle_gap_contradiction` [sorry]. Recommends Path A (omega-chain induction for surjectivity, 150-300 lines).

### Prior Plan Reference

Plan v56 (55_implementation-plan.md) had 4 phases. Phase 1 completed successfully (import cycle resolved). Phases 2-4 are replaced by this plan. Phase 2 targeted the wrong sorry (`chronicle_gap_contradiction` in the dead BX pipeline). The v57 plan follows the research recommendation: bypass `succ_cofinal`/`IsSuccArchimedean` entirely and prove `succ_embed_surjective` directly from the omega-chain construction.

### Roadmap Alignment

- Closing the sorry chain through `succ_embed_surjective` achieves the primary goal: sorry-free `completeness_discrete`
- Advances the critical path: Task 155 -> sorry-free `completeness_discrete`
- Makes `succ_cofinal` and `chronicle_gap_contradiction` definitively dead code (they are already marked as such)

## Goals & Non-Goals

**Goals**:
- Prove `succ_embed_surjective` without relying on `IsSuccArchimedean` or `succ_cofinal`
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes

**Non-Goals**:
- Proving `succ_cofinal` or `chronicle_gap_contradiction` (dead BX pipeline, permanently dead)
- Proving `limitDomSubtype_isSuccArchimedean` directly (bypassed by new surjectivity proof)
- Resolving Stavi completeness sorries (not on this critical path)
- Modifying the model surgery chain or WeakCanonical infrastructure
- Any changes to GoodStructures.lean or NoGapsDiscreteProof.lean (Phase 1 work preserved)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Boundary case in omega-chain induction harder than expected | H | M | The research identified the key insight: `succ(max_N)` is the unique new dom(N+1)\dom(N) point when b is above max(dom(N)). The existing `succ_reaches_dom_N` (line 101) already has the inductive structure and detailed proof sketch through line 239. |
| `succ_embed_surjective` type signature changes needed | M | L | The existing theorem (line 1667) already has the correct type. The proof body references `limitDomSubtype_isSuccArchimedean` -- replace with direct omega-chain argument. |
| Omega-chain stage lemmas missing from infrastructure | M | M | Check for `omega_chain_dom_mono`, `omega_chain_dom_new_unique`, `omega_chain_val` -- these are used in the existing `succ_reaches_dom_N` proof sketch and should be available. |
| BUC coherence also needs surjectivity | L | L | Research confirmed: `cantor_bfmcs_discrete_restricted_buc` uses only `succ_embed_squeeze_strict` (sorry-free, no surjectivity needed). Only TC and FUC need surjectivity. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

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

### Phase 2: Prove succ_embed_surjective via omega-chain induction [BLOCKED]

**Goal**: Replace the current `succ_embed_surjective` proof (which goes through `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` -> `chronicle_gap_contradiction` [sorry]) with a direct proof from the omega-chain construction.

**Approach**: The omega chain builds `limit_dom` incrementally: stage 0 is `{0}`, each stage N+1 adds one new C5 witness point. Every point in `limit_dom` enters at some finite stage. Prove by induction on the stage N that all dom(N) points are in the image of `succ_embed`. The key boundary case (new point above max(dom(N))) uses `omega_chain_dom_new_unique`: the unique new point at stage N+1 equals `succ(max_N)` in the limit domain.

**Tasks**:
- [ ] **Task 2.1**: Audit omega-chain infrastructure in ChronicleToCountermodel.lean. Verify availability of: `omega_chain_val`, `omega_chain_dom_mono`, `omega_chain_dom_new_unique` (or similar uniqueness lemma for dom(N+1)\dom(N)), `zero_mem_limit_dom`. Document line numbers and signatures.
- [ ] **Task 2.2**: Prove helper lemma `succ_embed_covers_dom_N`: for every N and every point p in dom(N), there exists n : Z such that `succ_embed n = p`. Structure: induction on N.
  - Base case (N=0): dom(0) = {0}, and `succ_embed 0 = root = 0`.
  - Inductive step: p in dom(N+1). If p in dom(N), apply IH. If p is the unique new point at stage N+1, split on position relative to dom(N):
    - p between adjacent dom(N) points w, w_next: IH gives `succ_embed(n) = w`. Since w < p < w_next and `succ_embed` maps consecutive integers to consecutive limit_dom points, `succ_embed(n+1) = succ(w)`. No limit_dom between w and succ(w). p is the unique new point in (w, w_next). So `succ(w) = p`, giving `succ_embed(n+1) = p`.
    - p above max(dom(N)): IH gives `succ_embed(n) = max_N`. `succ(max_N)` is the next limit_dom point. p is the unique dom(N+1)\dom(N) point. Since p > max_N and succ(max_N) > max_N, and no other dom(N+1)\dom(N) point exists, p = succ(max_N). So `succ_embed(n+1) = p`.
    - p below min(dom(N)): symmetric argument with pred.
- [ ] **Task 2.3**: Prove `succ_embed_surjective` from `succ_embed_covers_dom_N`. Given w in LimitDomSubtype, w.val is in limit_dom, so w.val is in dom(N) for some N. Apply `succ_embed_covers_dom_N` to get n with `succ_embed n = w`.
- [ ] **Task 2.4**: Verify the new proof compiles: `#check @succ_embed_surjective` and `lean_verify succ_embed_surjective` to confirm no sorryAx.

**Timing**: 3-4 hours (150-300 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
  - Add `succ_embed_covers_dom_N` helper (near line 101, replacing or alongside `succ_reaches_dom_N`)
  - Replace proof body of `succ_embed_surjective` (line 1667-1689) to use `succ_embed_covers_dom_N` instead of `limitDomSubtype_isSuccArchimedean`

**Verification**:
- `lean_verify succ_embed_surjective` shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes

**BLOCKER** (Phase 2):
- **What failed**: The omega-chain stage induction approach (Task 2.2) has an irreducible gap at the boundary case (new point `p` above `max(dom(N))`). The plan assumes `p = succ(max_N)` in limit_dom, but `succ(max_N)` is the next point in the FULL limit_dom, which may have been inserted at stage M >> N+1. Thus `succ(max_N)` may not be in `dom(N+1)`, and `omega_chain_dom_new_unique` does not apply.
- **What was tried**:
  1. **Stage induction** (plan's approach): The boundary case `p > max(dom(N))` fails because `succ(max_N_sub)` in limit_dom may come from an arbitrarily later stage M > N+1. The uniqueness lemma `omega_chain_dom_new_unique` only identifies elements of `dom(N+1) \ dom(N)`, not limit_dom elements that entered at stages > N+1.
  2. **Supremum/infimum contradiction**: Assuming the orbit `succ^[n](root)` is bounded above by `b`, the supremum L of the orbit in R satisfies either (a) L in limit_dom -> contradiction via pred(L)/succ_pred showing the orbit extends past L, or (b) L not in limit_dom -> the pred-chain from b stays above L forever, creating a gap at L. Case (a) works cleanly. Case (b) represents a genuine gap scenario (two connected components of the succ-structure on LimitDomSubtype separated by a non-limit_dom point L).
  3. **chronicle_gap_contradiction via model surgery**: The existing dead code at lines 475-764 attempts this but is blocked by the constant-MCS case (when `limit_f(a.val) = limit_f(b.val)`). In this case, no formula distinguishes the two sides of the gap, and the EF-game argument (contemp_equiv) cannot detect the boundary because a single-predicate monadic structure is trivially very_good at all depths.
  4. **Z1 axiom semantics**: Z1 = `G(Gφ→φ) → (FGφ→Gφ)` is satisfied trivially when the MCS is G-closed (constant-MCS case), providing no information about the order structure.
  5. **Prior-UZ exploitation**: `F(ψ) → U(ψ, ¬ψ)` can find a nearest witness for any formula, but in the constant-MCS case, every C5 requirement is satisfied within each connected component, so no cross-component witness is forced.
- **Why it's stuck**: The core issue is that `LimitDomSubtype` being a countable discrete linear order with no endpoints does NOT imply `IsSuccArchimedean` (one connected component). The counterexample is Z + Z (two copies of integers with a gap). The omega-chain construction builds limit_dom from dom(0) = {0} by inserting C5 witnesses, and in the constant-MCS case, witnesses can be inserted on either side of a gap without closing it. The existing axioms (Z1, Prior-UZ/SZ, discrete symmetry/propagation) are all satisfied in a disconnected order with constant MCS.
- **What is needed**: One of the following approaches could resolve this:
  - **(A) Multi-predicate model surgery**: Use a signature with ALL atomic formulas (not just one ψ) to build the OrderedMonadicStructure. At sufficient depth k, the EF-game may distinguish the two sides of the gap even in the constant-MCS case, because the full MCS contains formulas about temporal structure (U/S/G/H) that carry order-theoretic information. This requires extending the `chronicle_gap_contradiction` proof with a richer signature construction.
  - **(B) Omega-chain connectivity proof**: Show directly that the omega-chain construction produces a connected limit_dom by proving that every C5 witness insertion preserves connectivity (i.e., the new point is succ-reachable from root). This requires analyzing the `EliminationResult` structure to show that the witness rational is always placed in a position reachable from root.
  - **(C) Bypass surjectivity entirely** (Path B from research): Restructure `restricted_tc` and `restricted_fuc` to work without the ℤ ↔ LimitDomSubtype bijection. Instead of converting limit_dom witnesses to integers via surjectivity, prove the coherence conditions directly on the Z-indexed family. Estimated 400-800 lines.
  - **(D) Prove from frame semantics**: Show that Z1 soundness on the limit structure (via a truth lemma) directly gives IsSuccArchimedean as a frame condition. This requires establishing that the limit_dom with limit_f constitutes a valid Kripke frame satisfying Z1 semantically, not just syntactically.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

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
- [ ] If any sorry remains in the chain, trace the dependency and fix it

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- None expected (verification only), unless sorry traces are found

**Verification**:
- `#print axioms completeness_discrete` -- NO `sorryAx`
- `lake build` -- zero errors
- No new sorry statements

---

### Phase 4: Documentation cleanup and summary [NOT STARTED]

**Goal**: Update docstrings referencing the old sorry chain, write execution summary.

**Tasks**:
- [ ] Update the deprecated BX pipeline docstring at ChronicleToCountermodel.lean lines 55-95 to note that `succ_embed_surjective` is now proved directly (no longer depends on `succ_cofinal`)
- [ ] Update the `succ_embed_surjective` docstring (lines 1660-1666) to describe the new omega-chain proof
- [ ] Update the `limitDomSubtype_isSuccArchimedean` docstring (lines 785-788) to note it still has sorry via `succ_cofinal` but is no longer on the critical path
- [ ] Update the audit section in Completeness.lean to reflect sorry-free status for `completeness_discrete`
- [ ] Update ROADMAP.md critical path section to reflect completion
- [ ] Write execution summary at `specs/155_reynolds_pipeline_activation/summaries/56_execution-summary.md`

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update audit comments
- `specs/ROADMAP.md` -- update critical path

**Verification**:
- `lake build` still passes
- All docstrings accurately reflect the current sorry status

## Testing & Validation

- [ ] `lean_verify succ_embed_surjective` shows no `sorryAx`
- [ ] `lean_verify completeness_discrete` shows no `sorryAx`
- [ ] `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_tc` shows no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_fuc` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry statements introduced (`grep -rn "^\s*sorry" Theories/`)
- [ ] Dead code in ChronicleToCountermodel.lean (`succ_cofinal`, `chronicle_gap_contradiction`) not accidentally activated

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/56_implementation-plan.md` (this file, v57)
- Modified `ChronicleToCountermodel.lean` (new surjectivity proof)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/56_execution-summary.md`

## Rollback/Contingency

If the omega-chain induction (Phase 2) hits a wall at the boundary case:

1. **Fallback A**: Path B from the research -- rewrite `restricted_tc` and `restricted_fuc` to avoid surjectivity entirely. Higher effort (~400-800 lines) but avoids the boundary-case difficulty. The MCS families are indexed by Z via `limit_f . succ_embed`, so temporal properties might be provable directly on the Z-indexed family.

2. **Fallback B**: Path C -- prove `IsSuccArchimedean` from countability + discreteness + no endpoints. Countable discrete linear order without endpoints and with one connected component is isomorphic to Z. Effort ~300-600 lines, same core difficulty as `succ_cofinal`.

3. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to restore the file. Phase 1 changes (NoGapsDiscreteProof.lean, GoodStructures.lean) are unaffected.
