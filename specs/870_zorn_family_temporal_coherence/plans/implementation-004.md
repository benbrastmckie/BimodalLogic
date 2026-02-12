# Implementation Plan: Task #870 (Revised v004)

- **Task**: 870 - Zorn-based family selection for temporal coherence
- **Status**: [NOT STARTED]
- **Effort**: 18-24 hours
- **Dependencies**: None (builds on existing v003 partial implementation)
- **Research Inputs**: reports/research-005.md (sorry elimination analysis)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan eliminates all 11 remaining sorries in ZornFamily.lean by strengthening the `GHCoherentPartialFamily` structure with universal `forward_F` and `backward_P` fields, then using a GH-controlled Lindenbaum extension to preserve these properties during domain extension. The key insight from research-005 is that partial families CAN satisfy universal F/P properties (vacuously for singletons), and that strengthening the structure collapses three distinct sorry clusters into a unified resolution path. Two sorries in dead code (`extendFamily`) are eliminated by deletion.

### Research Integration

Integrated findings from research-005.md:
- **3 sorry clusters identified**: Seed consistency (5 sorries), domain totality (1 sorry), F/P recovery (4 sorries), plus 2 dead-code sorries
- **`non_total_has_boundary` is FALSE** for domains with internal gaps (counterexample: Z \ {0})
- **Strengthened family strategy**: Adding universal forward_F/backward_P fields resolves all clusters
- **Controlled Lindenbaum**: GH-compatible extension prevents arbitrary G/H formulas in new MCS

## Goals & Non-Goals

**Goals**:
- Eliminate all 11 sorry sites in ZornFamily.lean
- Provide `temporal_coherent_family_exists_zorn` with no sorry dependencies
- No new axioms introduced
- Maintain existing boundary extension infrastructure from v003

**Non-Goals**:
- Proving G distributes over disjunction (it does not)
- Preserving the multi_witness proof approach (fundamentally broken per research-004)
- Modifying DovetailingChain.lean (separate task)
- Optimizing proof performance or code style

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Chain upper bound for forward_F/backward_P is harder than expected | H | L | Research-005 outlines clear argument via chain comparability; prototype first |
| GH-controlled Lindenbaum requires significant new infrastructure | H | M | Phase 3 is isolated; can fall back to augmented seed approach if needed |
| Seed consistency argument with strengthened family is still complex | M | M | "Collect into one MCS" argument from research-005 is well-specified; implement incrementally |
| `non_total_has_boundary` replacement (gap case) is complex | H | M | Strengthened family eliminates the gap-case problem entirely; general extension now viable |
| Strengthened structure causes widespread breakage | M | L | Changes are additive (new fields); existing proofs remain valid |

## Sorry Characterization

### Pre-existing Sorries

11 sorry sites in `ZornFamily.lean`:

| Line | Function | Cluster | Description |
|------|----------|---------|-------------|
| 770 | `multi_witness_seed_consistent_future` | Seed consistency | Hard case with F-obligations from L |
| 800 | `multi_witness_seed_consistent_past` | Seed consistency | Symmetric hard case |
| 814 | `extensionSeed_consistent` | Seed consistency | Cross-sign case (past + future) |
| 1046 | `extensionSeed_consistent` | Seed consistency | Pure past, F-obligations from different sources |
| 1186 | `extensionSeed_consistent` | Seed consistency | Pure future, P-obligations from different sources |
| 1598 | `extendFamily.forward_G` | Dead code | In unused `extendFamily` function |
| 1629 | `extendFamily.backward_H` | Dead code | In unused `extendFamily` function |
| 1999 | `non_total_has_boundary` | Domain totality | Gap case is false |
| 2069 | `maximal_implies_total` h_G_from_new | F/P recovery | Forward G from new time to old domain |
| 2076 | `maximal_implies_total` h_H_from_new | F/P recovery | Backward H from new time to old domain |
| 2170 | `total_family_FObligations_satisfied` | F/P recovery | F phi in mcs(s), need phi in mcs(t) |
| 2186 | `total_family_PObligations_satisfied` | F/P recovery | P phi in mcs(s), need phi in mcs(t) |

### Expected Resolution

- Phase 1 eliminates 2 sorries (lines 1598, 1629) by deleting dead code
- Phase 2 eliminates 2 sorries (lines 2170, 2186) by making forward_F/backward_P structural fields
- Phase 3 eliminates 2 sorries (lines 2069, 2076) via GH-controlled Lindenbaum
- Phase 4 eliminates 5 sorries (lines 770, 800, 814, 1046, 1186) via collect-into-one-MCS argument
- Phase 5 eliminates 1 sorry (line 1999) by replacing boundary-only with general extension

### New Sorries

None expected. If any phase proves intractable, the sorry will be documented with remediation timeline rather than left silently.

### Remaining Debt

After this implementation:
- 0 sorries expected in ZornFamily.lean
- `temporal_coherent_family_exists_zorn` becomes sorry-free
- Downstream theorems no longer inherit sorry status
- Publication no longer blocked by these specific sorries

## Implementation Phases

### Phase 1: Delete Dead Code [NOT STARTED]

- **Dependencies:** None
- **Goal:** Remove unused `extendFamily` and `extendFamily_strictly_extends` functions, eliminating 2 sorries immediately.
- **Tasks:**
  - [ ] Verify `extendFamily` and `extendFamily_strictly_extends` are not referenced by any code in the dependency chain of `temporal_coherent_family_exists_zorn`
  - [ ] Delete `extendFamily` (lines ~1561-1646) and `extendFamily_strictly_extends` (lines ~1651-1670+)
  - [ ] Run `lake build` to confirm no breakage
- **Timing:** 0.5 hours
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - delete ~110 lines of dead code
- **Verification:**
  - `lake build` succeeds
  - `grep -c "sorry" ZornFamily.lean` shows 9 (down from 11)

---

### Phase 2: Strengthen GHCoherentPartialFamily with forward_F/backward_P [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Add universal `forward_F` and `backward_P` fields to the structure, update base family, chain upper bound, and boundary extension to satisfy them.
- **Tasks:**
  - [ ] Add two new fields to `GHCoherentPartialFamily`:
    ```
    forward_F : forall s t, s in domain -> t in domain -> s < t ->
        forall phi, Formula.some_future phi in mcs s -> phi in mcs t
    backward_P : forall s t, s in domain -> t in domain -> t < s ->
        forall phi, Formula.some_past phi in mcs s -> phi in mcs t
    ```
  - [ ] Update `singleMCSFamily` (base family): forward_F and backward_P are vacuously true for singleton domain {0} (no pairs s < t)
  - [ ] Update `coherent_chain_has_upper_bound`: Prove chain union preserves forward_F and backward_P. Argument: given F phi in mcs(s) at s in the union, some chain element F_i contains s; given t in the union, some F_j contains t; by chain comparability, both s and t are in the larger of F_i, F_j, which satisfies forward_F.
  - [ ] Update `extendFamilyAtBoundary`: Prove forward_F and backward_P for the extended family (old-to-old inherited; old-to-new from seed FObligations/PObligations; new-to-old is the hard case, addressed in Phase 3)
  - [ ] Update all downstream uses that construct `GHCoherentPartialFamily` values
  - [ ] Replace `total_family_FObligations_satisfied` and `total_family_PObligations_satisfied` with direct applications of the structural fields (eliminates 2 sorries at lines 2170, 2186)
  - [ ] Simplify `maximal_family_forward_F`, `maximal_family_backward_P`, `total_family_forward_F`, `total_family_backward_P` to use structural fields directly
  - [ ] Run `lake build` to verify; sorries may appear in `extendFamilyAtBoundary` for new-to-old case (expected, resolved in Phase 3)
- **Timing:** 4-6 hours
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - modify structure, base family, chain upper bound, boundary extension, F/P recovery theorems
- **Verification:**
  - Structure compiles with new fields
  - Base family (singleton) compiles without sorry
  - Chain upper bound compiles without sorry for all 4 properties (forward_G, backward_H, forward_F, backward_P)
  - Lines 2170, 2186 sorries eliminated
  - Remaining sorries: at most 7 (5 seed consistency + 2 new-to-old in boundary extension, minus 2 from Phase 1 deletion)

---

### Phase 3: GH-Controlled Lindenbaum Extension [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Build a modified Lindenbaum extension that preserves GH-compatibility with the existing family, resolving the new-to-old propagation problem (sorries at lines 2069, 2076).
- **Tasks:**
  - [ ] Define GH-compatibility predicate:
    ```
    def GHCompatible (S : Set Formula) (F : GHCoherentPartialFamily) (t : Int) : Prop :=
      (forall phi, Formula.all_future phi in S -> forall s, s in F.domain -> t < s -> phi in F.mcs s) /\
      (forall phi, Formula.all_past phi in S -> forall s, s in F.domain -> s < t -> phi in F.mcs s)
    ```
  - [ ] Prove extension seed is GH-compatible: GContent from past propagates via forward_G; HContent from future propagates via backward_H; FObligations/PObligations do not introduce G/H formulas directly
  - [ ] Define selective Lindenbaum extension that only adds G psi (resp. H psi) if psi is in all relevant domain MCSs; otherwise adds neg(G psi)
  - [ ] Prove selective Lindenbaum result is MCS: for rejected G psi, neg(G psi) = F(neg(psi)) can be added consistently because psi not in F.mcs(s') implies neg(psi) in F.mcs(s') (MCS property)
  - [ ] Prove selective Lindenbaum result is GH-compatible: by construction, only G/H formulas consistent with the family are included
  - [ ] Update `extendFamilyAtBoundary` (or replace with general `extendFamilyControlled`) to use GH-compatible Lindenbaum extension
  - [ ] Prove forward_F for new-to-old: if F phi in mcs_t, then phi is in FObligations (in seed), hence in mcs_t. For propagation to old domain: this follows from the seed structure, not from Lindenbaum additions
  - [ ] Prove backward_P for new-to-old: symmetric argument
  - [ ] Resolve sorries at lines 2069, 2076
- **Timing:** 6-8 hours
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - new definitions and lemmas (~200-300 lines)
  - Possibly `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - if GH-controlled Lindenbaum is factored out
- **Verification:**
  - `extendFamilyAtBoundary` (or replacement) compiles without sorry for all 6 properties (forward_G, backward_H, forward_F, backward_P, domain_nonempty, is_mcs)
  - Lines 2069, 2076 sorries eliminated
  - `lake build` succeeds
- **Fallback:** If selective Lindenbaum proves too complex, use augmented seed approach instead: include negative GH constraints (neg(G psi) for psi not in all future MCSs) in the seed, and prove this augmented seed is consistent.

---

### Phase 4: Seed Consistency via Collect-into-One-MCS [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove `extensionSeed_consistent` and `multi_witness_seed_consistent_*` using the strengthened family's forward_F/backward_P to collect all seed elements into a single reference MCS.
- **Tasks:**
  - [ ] Prove helper lemma: for finitely many source times in domain, all GContent and FObligations elements from past sources can be collected into mcs(s_max) where s_max is the maximum past source time
    - GContent propagates: G phi in mcs(s1), s1 < s_max, by forward_G phi in mcs(s_max), hence G phi in mcs(s_max) by 4-axiom (G phi -> GG phi gives G phi in all future MCSs)
    - FObligations propagate: F phi in mcs(s1), s1 < s_max, by forward_F phi in mcs(s_max)
  - [ ] Prove symmetric helper for future sources collecting into mcs(s_min)
  - [ ] Prove cross-sign collection: past elements in mcs(s_max), future elements in mcs(s_min); since s_max < t < s_min, by forward_G elements from s_max propagate to s_min; by forward_F, F-obligation elements from s_max propagate to s_min; all elements end up in mcs(s_min)
  - [ ] Rewrite `multi_witness_seed_consistent_future` (line 770 sorry) using the collect argument
  - [ ] Rewrite `multi_witness_seed_consistent_past` (line 800 sorry) using the collect argument
  - [ ] Rewrite `extensionSeed_consistent` cross-sign case (line 814 sorry) using cross-sign collection
  - [ ] Rewrite `extensionSeed_consistent` pure past case (line 1046 sorry) using past-only collection
  - [ ] Rewrite `extensionSeed_consistent` pure future case (line 1186 sorry) using future-only collection
  - [ ] Run `lake build` to verify all 5 seed consistency sorries eliminated
- **Timing:** 4-6 hours
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - rewrite seed consistency proofs (~150-200 lines changed)
- **Verification:**
  - `extensionSeed_consistent` compiles without sorry
  - `multi_witness_seed_consistent_future` compiles without sorry
  - `multi_witness_seed_consistent_past` compiles without sorry
  - All 5 sorry sites eliminated
- **Note:** `multi_witness_seed_consistent_future/past` may become unnecessary if `extensionSeed_consistent` is rewritten to not depend on them. In that case, delete or simplify them.

---

### Phase 5: Replace non_total_has_boundary with General Extension [NOT STARTED]

- **Dependencies:** Phase 3, Phase 4
- **Goal:** Eliminate the sorry at line 1999 by restructuring `maximal_implies_total` to handle internal gaps using the strengthened family and GH-controlled extension.
- **Tasks:**
  - [ ] Delete or weaken `non_total_has_boundary`: it is false for domains with internal gaps (research-005 counterexample: Z \ {0})
  - [ ] Replace with `non_total_can_extend`: for any non-total domain, there exists a time t not in domain such that the family can be extended to include t
    - If domain has an upper boundary time: use boundary extension (existing infrastructure)
    - If domain has a lower boundary time: use boundary extension (existing infrastructure)
    - If domain has only internal gaps (unbounded both above and below): pick any gap time t. The strengthened family (with forward_F/backward_P) ensures seed consistency at gap times. Use GH-controlled Lindenbaum from Phase 3 for the extension.
  - [ ] Update `maximal_implies_total` to use `non_total_can_extend` instead of `non_total_has_boundary`
  - [ ] Handle the gap case: at gap time t (s_below < t < s_above, both in domain), the extension seed contains both GContent from past and HContent from future; cross-sign consistency follows from Phase 4's collect-into-one-MCS argument; GH-controlled Lindenbaum from Phase 3 ensures new-to-old propagation
  - [ ] Run `lake build` to verify
- **Timing:** 3-4 hours
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - restructure maximal_implies_total (~100-150 lines changed)
- **Verification:**
  - `maximal_implies_total` compiles without sorry
  - Line 1999 sorry eliminated
  - `lake build` succeeds with 0 sorry warnings in ZornFamily.lean

---

### Phase 6: Final Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4, Phase 5
- **Goal:** Verify zero sorries remain, clean up code, update documentation.
- **Tasks:**
  - [ ] Run `lake build` and verify 0 sorry warnings in ZornFamily.lean
  - [ ] Verify `temporal_coherent_family_exists_zorn` has no sorry in its dependency chain
  - [ ] Delete or simplify `multi_witness_seed_consistent_future/past` if no longer needed
  - [ ] Update module docstring to reflect v004 approach (strengthened family strategy)
  - [ ] Update references to plans and research reports in docstring
  - [ ] Remove obsolete comments about "technical debt" and "Phase 3 refinements"
  - [ ] Run full `lake build` to confirm no regressions
- **Timing:** 1-2 hours
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - documentation and cleanup

## Testing & Validation

- [ ] `lake build` produces 0 errors
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` returns 0
- [ ] `temporal_coherent_family_exists_zorn` is sorry-free (verify via `#check @temporal_coherent_family_exists_zorn` with no sorry warnings)
- [ ] No new `axiom` declarations introduced
- [ ] All existing theorems that depend on `temporal_coherent_family_exists_zorn` still compile

## Artifacts & Outputs

- `specs/870_zorn_family_temporal_coherence/plans/implementation-004.md` (this plan)
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` (modified, sorry-free)
- `specs/870_zorn_family_temporal_coherence/summaries/implementation-summary-20260212.md` (on completion)

## Rollback/Contingency

- Git branch preserves v003 partial implementation state
- Each phase can be reverted independently via `git revert` on the phase commit
- If Phase 3 (GH-controlled Lindenbaum) proves intractable:
  - Fallback A: Use augmented seed with negative GH constraints
  - Fallback B: Accept sorries at lines 2069, 2076 as documented technical debt (remediation priority: high) and proceed with remaining phases
- If Phase 4 (seed consistency) proves harder than expected:
  - The collect-into-one-MCS argument requires forward_F/backward_P from Phase 2
  - If Phase 2 is not yet complete, seed consistency cannot be resolved
  - Fallback: Accept seed consistency sorries as documented technical debt
