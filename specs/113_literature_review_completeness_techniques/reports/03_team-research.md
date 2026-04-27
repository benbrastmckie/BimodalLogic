# Research Report: Task #113 (Round 3)

**Task**: Systematic open guard refactoring plan for Until/Since semantics
**Date**: 2026-04-27
**Mode**: Team Research (4 teammates)
**Session**: sess_1777316607_f01b30

## Summary

The refactor from half-closed guard `[t, s)` to open guard `(t, s)` for Until/Since is well-scoped and achievable. Four axioms must be removed (`until_guard`, `since_guard`, `until_elim`/BX9, `since_elim`/BX9'). The remaining 33 axioms are sound under open guard. Dead code archives to `Boneyard/ClosedGuardLegacy/`. The recommended sequencing is **Option A: complete task 107 Phase 1 first, then do the refactor, then resume task 107 Phases 2-5** — this writes all remaining chronicle code under the correct semantics from the start.

## Key Findings

### 1. Axioms to Remove (4) — All Confirmed Unsound

All four teammates agree. Under open guard `(t, s)`, the evaluation point t is not in the guard interval, so:

| Axiom | Statement | Failure mechanism |
|-------|-----------|------------------|
| `until_guard` | (φ U ψ) → φ | `le_refl t` extracts φ(t); under open guard t ∉ (t,s) |
| `since_guard` | (φ S ψ) → φ | Mirror |
| `until_elim` (BX9) | (φ U ψ) → (φ ∨ ψ) | Same — derives φ(t) from guard, then φ ∨ ψ |
| `since_elim` (BX9') | (φ S ψ) → (φ ∨ ψ) | Mirror |

**Literature confirmation** (Teammate B): Xu 1988's Σ4 does NOT include any of these 4 axioms. Reynolds 1992 explicitly notes that Xu's system removed the extra axiom (A4a, which corresponds to BX9). The minimal complete set for all linear orders is the 6 Burgess-Xu axioms (BX2-BX7 and duals) plus distribution, seriality, linearity, eventuality, and bridges. No replacement axioms are needed.

### 2. Axioms That Remain Sound (33)

All propositional (4), S5 modal (5), and the following temporal axioms are confirmed sound under open guard:

- BX2/BX2' (left_mono_until/since) — G distributes over open guard
- BX3/BX3' (right_mono_until/since) — ditto
- BX4/BX4' (connect_future/past) — no guard dependency
- **BX5/BX5' (self_accum_until/since)** — `le_trans` → `lt_trans` (mechanical fix, confirmed by Teammate B)
- BX6/BX6' (absorb_until/since) — sound; guard gap at junction point handled by MCS
- BX7/BX7' (linear_until/since) — no guard dependency
- BX10/BX10' (until_F/since_P) — eventuality extraction, no guard
- BX11/BX11' (temp_linearity) — F-level, no guard
- BX12/BX12' (F_until_equiv/P_since_equiv) — bridge, no guard
- temp_k_dist, temp_4 — G distribution/transitivity
- serial_future/past — seriality
- modal_future, temp_future — modal-temporal interaction

### 3. File-by-File Impact (Teammate A audit)

| File | Action | Refs | Effort |
|------|--------|------|--------|
| **Truth.lean** | Change `t ≤ r` → `t < r`, `r ≤ t` → `r < t` | 2 lines | 0.5 hr |
| **Axioms.lean** | Remove 4 constructors | 6 refs | 1 hr |
| **SoundnessLemmas.lean** | Delete 8 match arms, rewrite ~12 U/S proofs (≤→<) | 20 refs | 8 hrs |
| **Soundness.lean** | Delete 8 match arms, update routing | 24 refs | 4 hrs |
| **RRelation.lean** | Archive 2 lemmas, rebuild 3 proofs via Xu 2.3(i) | 17 refs | 6 hrs |
| **PointInsertion.lean** | Replace 2 call sites | 6 refs | 3 hrs |
| **ChronicleTypes.lean** | Remove BX9 refs in burgessRSet properties | 5 refs | 1 hr |
| **Frame.lean** | Remove 2 until_elim calls | 2 refs | 1 hr |
| **Construction.lean** | Remove until_elim_mcs, replace with r-relation | 4 refs | 2 hrs |
| **DefectChain.lean** | Remove until_elim_mcs_or, replace | 3 refs | 1 hr |
| **TemporalDerived.lean** | Archive dead BX8 theorem chain (already sorry'd) | 15 refs | 1 hr |
| **Substitution.lean** | Full rebuild (already broken, stale axiom refs) | 4 refs | 3 hrs |
| **Total** | | ~116 refs | ~31.5 hrs |

### 4. Xu Lemma 2.3(i) Replacement for `until_guard_in_mcs`

The critical infrastructure lemma `until_guard_in_mcs` (γ U δ ∈ A → γ ∈ A) is used 10+ times. Under open guard it is FALSE.

**Replacement** (Teammate B): Xu Lemma 2.3(i) gives `S(α, ⊤) ∈ B for every α ∈ A` when R(A, B, C). This encodes guard information through the r-relation DCS rather than extracting it at the current point.

For `burgessR3Maximal_exists_from_seed` (RRelation.lean:1193): instead of extracting η ∈ A directly via guard, use the r-relation structure — η appears as the "beta" parameter in R(A, η, C), so the seed construction can use η directly without requiring η ∈ A.

For `PointInsertion.lean:673` (⊥ U γ ∈ A → ⊥ ∈ A): under open guard, ⊥ U γ is equivalent to F(γ) (the open guard (t,s) with ⊥ on it is vacuously true). The contradiction must be reworked: use BX10 to extract F(γ), then derive the contradiction through the specific proof context rather than via ⊥ ∈ A.

### 5. Sequencing: Option A Recommended

Teammate C's analysis shows Options A and B are essentially equal in total effort (~75-78 hrs). Option A is slightly preferred:

**Option A: Complete Phase 1 of plan v21, then refactor, then resume Phases 2-5**

| Factor | Option A (refactor after Ph.1) | Option B (finish 107 first) |
|--------|-------------------------------|----------------------------|
| Total effort | ~75-77 hrs | ~77-78 hrs |
| Wasted work | ~1-2 hrs (lemma_2_7_guard rework) | ~2-3 hrs (Phase 4.1 BX9 step) |
| Phase 4.1 | Written correctly from the start | Needs BX9 step replacement later |
| Risk | Low | Low |
| Paper alignment | Phases 2-5 under correct semantics | BX9 used under wrong semantics |

**Key findings supporting Option A:**
- Phase 1 is the natural stopping point (additive, self-contained)
- Phases 2-5 are entirely guard-independent (confirmed: zero guard axiom calls in CounterexampleElimination.lean, ChronicleConstruction.lean, ChronicleToCountermodel.lean)
- The Phase 4.1 BX9 step is the ONLY interaction — doing the refactor first eliminates it
- Option C (parallel branches) is not recommended for a solo developer

**Best stopping point**: After Phase 1 is fully sorry-free and `lake build` passes.

### 6. Boneyard Strategy

**Directory**: `Theories/Bimodal/Boneyard/ClosedGuardLegacy/`

| Archive file | Contents |
|-------------|----------|
| `ClosedGuardAxioms.lean` | `until_guard` + `since_guard` constructors with docstrings |
| `ClosedGuardSoundness.lean` | `until_guard_valid` + `since_guard_valid` theorems |
| `ClosedGuardRRelation.lean` | `until_guard_in_mcs` + `since_guard_in_mcs` lemmas |
| `ClosedGuardTemporalDerived.lean` | Dead BX8/BX8' theorem chain (psi_imp_until, refl_F, etc.) |

**Delete without archiving**: 16 trivial match arms in SoundnessLemmas/Soundness that disappear when constructors are removed. 6 stale arms in Substitution.lean.

### 7. Phased Implementation Plan

Each phase ends with `lake build` passing.

**Phase 0: Prerequisite audit** (0.5 hrs)
- Verify `lake build` baseline, record sorry count

**Phase 1: Foundation** (2 hrs)
- Truth.lean: change `≤` to `<` (2 characters)
- Axioms.lean: remove 4 constructors
- Introduce sorry stubs in downstream files for missing match arms
- Archive to `Boneyard/ClosedGuardLegacy/`

**Phase 2: Soundness** (12 hrs)
- SoundnessLemmas.lean: delete 8 guard arms, rewrite ~12 U/S proofs (≤→<)
- Soundness.lean: delete 8 guard arms, update routing
- Verify all soundness theorems sorry-free

**Phase 3: Chronicle infrastructure** (9 hrs)
- RRelation.lean: rebuild `burgessR3Maximal_exists_from_seed` and `untl_absorb_nested` using Xu 2.3(i)
- PointInsertion.lean: replace `until_guard_in_mcs` call sites
- ChronicleTypes.lean: remove BX9 refs

**Phase 4: Quasimodel/Filtration** (4 hrs)
- Frame.lean: replace until_elim calls
- Construction.lean: replace until_elim_mcs
- DefectChain.lean: replace until_elim_mcs_or

**Phase 5: Derived theorems and cleanup** (4 hrs)
- TemporalDerived.lean: archive dead BX8 chain
- Substitution.lean: full clean rebuild
- Verify zero sorry increase from baseline
- Final `lake build` clean

**Total estimated effort**: ~31.5 hrs

## Synthesis

### Conflicts Resolved

**BX9 soundness**: Teammates A and B confirmed BX9 is unsound under open guard. Teammate D initially flagged this as "requiring Teammate B's input" but the answer is clear — BX9 cannot hold when the guard excludes the evaluation point. All four agree on removal.

**Substitution.lean**: Teammate A discovered this file is already broken (references stale axiom names from a prior refactor). The guard refactor should include a full rebuild of this file, not just patching the 4 removed axioms. All teammates agree.

**PointInsertion.lean:673 contradiction**: Teammate B proposed using BX10 (F(γ) extraction) as the replacement path. Teammate D suggested BX2 monotonicity. Both are viable; the specific proof will depend on the local context. Flag for implementation-time decision.

### Gaps Identified

1. **BX5 soundness proof adjustment**: Confirmed mechanical (`le_trans` → `lt_trans`) but needs line-by-line verification during implementation.

2. **BX6 (absorb_until) gap at junction**: Under open guard, `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)` has a junction point s₁ where neither (t, s₁) nor (s₁, s₂) covers s₁. The MCS argument handles this but needs careful proof. Teammate B verified this is sound but flagged for careful implementation.

3. **Frame.lean eventuality resolution**: Uses `until_elim` (BX9) at line 690. Since BX9 is removed, this derivation must be replaced. The Quasimodel infrastructure may provide an alternative path through defect-discharge.

## Recommendations

1. **Complete task 107 Phase 1** (close 4 remaining sorry sites in Lemma 2.6).
2. **Pause task 107**. Create a new task for the open guard refactor.
3. **Execute the 5-phase refactor** (~31.5 hrs), archiving to `Boneyard/ClosedGuardLegacy/`.
4. **Resume task 107 Phases 2-5** under the correct open guard semantics. All remaining phases are guard-independent except Phase 4.1, which will be written correctly from the start.
5. Update ROADMAP.md to reflect the corrected semantics.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A (auditor) | File-by-file code audit | completed | high |
| B (axiom-expert) | Literature-guided axiom set | completed | high |
| C (sequencer) | Sequencing analysis | completed | high |
| D (architect) | Boneyard strategy and rebuild | completed | high |

## References

- Xu, M. (1988). "On some U,S-tense logics." JPL 17(2), 181-202. Section 2 (open guard), Lemma 2.3(i).
- Burgess, J. P. (1982). "Axioms for tense logic. I." NDJFL 23(4), 367-374. Open guard convention.
- Reynolds, M. (1992). "An axiomatization for until and since over the reals without the IRR rule." Studia Logica 51, 165-193.
- Kamp, H. (1968). "Tense Logic and the Theory of Linear Order." PhD thesis, UCLA.
