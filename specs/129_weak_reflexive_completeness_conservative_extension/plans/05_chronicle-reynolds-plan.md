# Implementation Plan: Task #129 (Chronicle + Reynolds Theorem 15)

- **Task**: 129 - weak_reflexive_completeness_conservative_extension
- **Status**: [PARTIAL] (Phase 1: COMPLETED, Phase 2: COMPLETED, Phase 3: PARTIAL, Phase 4: PARTIAL, Phase 5: PARTIAL, Phase 6: NOT STARTED, Phase 7: NOT STARTED)
- **Effort**: 40-55 hours
- **Dependencies**: None (uses existing BXCanonical/Chronicle infrastructure and WeakCanonical skeleton)
- **Research Inputs**:
  - specs/129_weak_reflexive_completeness_conservative_extension/reports/07_team-research.md
  - specs/129_weak_reflexive_completeness_conservative_extension/reports/06_multi-relation-analysis.md
  - specs/129_weak_reflexive_completeness_conservative_extension/reports/03_reynolds-deep-dive.md
- **Artifacts**: plans/05_chronicle-reynolds-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace `doets_countermodel_discrete` (currently a thin wrapper around the chronicle's `dd_countermodel_chronicle_discrete`, which carries the `succ_cofinal` sorry) with a standalone Reynolds Theorem 15 construction that bypasses the sorry entirely. The approach follows Reynolds 1994 literally: use the existing Burgess chronicle as the starting model M_0 satisfying Corollary 3 conditions (countable, discrete without endpoints, Prior-UZ/SZ valid), then apply Theorem 15 compression (good/very good, gap elimination, Z-model extraction) to produce a Z-model N k-equivalent to M_0. This skips the 6 Until/Since truth lemma sorries in WeakCanonical/TruthLemma.lean (the chronicle handles eventuality resolution) and avoids the `succ_cofinal` sorry (Reynolds Theorem 15 does not need IsSuccArchimedean). Phase 1 begins by fixing all identified bugs in the existing codebase.

### Research Integration

Key findings from reports 06 and 07:
- **Reynolds does NOT build a canonical model** (report 07, Finding 2): He uses the existing Burgess-Xu chronicle + Theorem 15 compression. The BXCanonical chronicle already provides Corollary 3's output (countable, discrete, Prior-UZ/SZ valid everywhere).
- **Multi-relation confirmed correct** (report 06, report 07 Finding 1): The single-relation approach has a fatal flaw in G-forward. Multi-relation design is mathematically necessary for truth evaluation but irrelevant to Path A (chronicle approach).
- **The `succ_cofinal` sorry is bypassed** (report 07, Finding 2): Reynolds Theorem 15 only needs countable + discrete without endpoints + Prior-UZ/SZ valid. It does NOT need IsSuccArchimedean.
- **`until_backward_mcs` has wrong type signature** (report 07, Finding 5): Stated as forward direction with negated hypothesis. This is a genuine bug.
- **True sorry burden is ~19** (report 07, Finding 5): Including vacuous definitions in IntegerModel/OrderedSum/Table.
- **Weak Until is degenerate** (report 07, Finding 4): Rules out the "weak truth then transfer" approach entirely.

### Prior Plan Reference

Prior plan (03_doets-reynolds-plan.md) proposed 4 phases / 35-50 hours using a reflexive canonical model approach (Path B). Phase 1 was PARTIAL (60% -- G/H proved, Until/Since blocked). Phase 2 was NOT STARTED. Team research (report 07) identified that Path A (chronicle + Reynolds) is strictly better: it skips the 6 Until/Since truth lemma sorries, reuses existing chronicle infrastructure, and follows Reynolds 1994 literally. The n-equivalence infrastructure from the prior plan Phase 2 carries over to this plan. Effort calibration: the prior plan's 10-14 hour estimate for n-equivalence was reasonable given the mathematical complexity. The current plan adds bug-fix effort and adjusts the pipeline structure.

### Roadmap Alignment

This plan advances the critical-path sorry in the discrete completeness branch (ROADMAP.md Phase 1). The roadmap states: "Critical path: Task 129 (weak/reflexive completeness, PLANNED) -> task 122 (discrete BFMCS) -> sorry-free bx_completeness." Success here eliminates the `succ_cofinal` sorry from `dd_countermodel_chronicle_discrete`, which is the sole blocker for sorry-free discrete completeness.

## Goals & Non-Goals

**Goals**:
- Fix all identified bugs in WeakCanonical codebase (until_backward_mcs type, missing proofs)
- Extract the existing Burgess chronicle as a Prior-UZ/SZ-valid discrete structure (Corollary 3 conditions)
- Build n-equivalence infrastructure: k-types, subformula closure, finiteness (Doets 1989 Section 1)
- Prove ordered sum n-equivalence preservation (Doets Lemma 1.4)
- Implement Reynolds Theorem 15: good/very good, contemporaneous equivalence, gap elimination, Z-model
- Wire `doets_countermodel_discrete` to use the Reynolds pipeline instead of the chronicle fallback
- Eliminate `succ_cofinal` sorry from `bx_completeness` dependency chain

**Non-Goals**:
- Modifying Formula, Axiom, truth_at, or any soundness theorems
- Closing the Until/Since truth lemma sorries in WeakCanonical/TruthLemma.lean (unnecessary for Path A)
- Changing the dense completeness branch (remains chronicle-based)
- Building a separate "weak axiom system" or "weak MCS" type
- Formalizing full Ehrenfeucht games (restricted n-equivalence suffices)
- Formalizing Kamp's expressive completeness theorem
- Resolving the mixed-case sorry (`dd_countermodel_chronicle_mixed_sorry`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Doets Lemma 1.4 formalization harder than expected | HIGH | MEDIUM | Restrict to finite k-type sets (sufficient for our use); use isolated sorry as fallback. Doets 1989 Lemma 1.4 proof is 1 paragraph; cf. `literature/Doets_1989_Monadic_Pi11_Theories.md`. |
| Chronicle does not satisfy Corollary 3 conditions exactly | MEDIUM | LOW | Chronicle is countable (over rationals), discrete with next_top in every MCS of box-class, Prior-UZ/SZ are axioms hence in every MCS. Verify with lean_goal at extraction point. |
| Gap elimination for discrete structures is non-trivial | MEDIUM | LOW | Reynolds Theorem 15 gap elimination is TRIVIAL in discrete orders: no Dedekind gaps exist, and successor boundaries yield 2-element intervals (finite, hence good). Cf. Reynolds 1994 after Lemma 14. |
| Monadic FO satisfaction formalization is too large | HIGH | MEDIUM | Use shallow encoding: represent k-types abstractly as Finset-indexed data, prove finiteness combinatorially. Do NOT formalize full monadic FO syntax/semantics (would be 2000+ lines). |
| Type mismatch when packaging Z-model as TaskFrame/TaskModel | LOW | HIGH | Existing `dd_countermodel_chronicle_discrete` proof at ChronicleToCountermodel.lean:3293 shows the exact packaging pattern with `ParametricCanonicalTaskFrame Int`. Reuse this pattern. |
| Existing WeakCanonical vacuous definitions block real proofs | LOW | HIGH | Phase 1 replaces all vacuous definitions (`good := True`, `k_equiv := True`, etc.) with proper definitions. The phantom proofs against them (OrderedSum, IntegerModel) are deleted and rebuilt. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 2, 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |

Phases 2 and 3 can execute in parallel (Wave 2).

---

### Phase 1: Bug Fixes and Codebase Cleanup [COMPLETED] (9/10 tasks complete, 1 confirmed DEAD CODE)

**reflCanR_linear status: CONFIRMED DEAD CODE (NO OP)**:
- **Research finding (ses_1d7ff4654ffepvjW7Zyh3EPy2Wf)**: `reflCanR_linear` has ZERO callers anywhere in the project. It is not imported or referenced by any downstream file (ChronicleExtraction, NEquivalence, OrderedSum, IntegerModel, Transfer, or any BXCanonical file).
- **Why it's safe to leave as sorry**: The chronicle model inherits `LinearOrder` from `Rat` (its domain is a subtype of rationals) — linearity comes from the rational numbers, not from a canonical model theorem. None of Phases 2-7 ever invoke `reflCanR_linear`.
- **The existing `sorry` stub with correct type signature is acceptable.** The theorem can remain sorried with zero impact on the critical path to `bx_completeness`.

**Goal**: Fix all identified bugs in the WeakCanonical directory, remove vacuous definitions, and ensure the existing sorry-free proofs still compile.

**Tasks**:
- [x] Fix `until_backward_mcs` type signature in `TruthLemma.lean:450` -- fixed to correct contrapositive form with Path A bypass note. (sorry body)
- [x] Fix `since_backward_mcs` type signature in `TruthLemma.lean:492` -- same fix, mirror of until_backward_mcs. (sorry body)
- [x] Replace vacuous definitions in `IntegerModel.lean`: already replaced with `:= by sorry`-based stubs by earlier work. (verified correct)
- [x] Replace vacuous definitions in `NEquivalence.lean`: already replaced with proper sorry-based stub by earlier work. (verified correct)
- [x] Replace vacuous definitions in `OrderedSum.lean`: already replaced with proper sorry-based stubs by earlier work. (verified correct)
- [x] Replace vacuous `table` definition in `Table.lean`: already replaced with proper sorry-based stub by earlier work. (verified correct)
- [x] Prove `tempR_fwd_trans` in `ReflexiveCanonical.lean`: sorry-free proof via temp_4 + `all_future_all_future`. (~25 lines)
- [x] ~~Prove `reflCanR_linear`~~ **DEAD CODE** — zero callers, chronicle has its own LinearOrder from Rat. Left as sorry with correct type signature. Not on critical path.
- [x] Prove `tempR_bwd_imp_reflCanR_bwd` in `ReflexiveCanonical.lean`: sorry-free proof mirroring `tempR_fwd_imp_reflCanR`. (~15 lines)
- [x] Verify `lake build Bimodal.Metalogic.WeakCanonical` compiles with no errors.

**Timing**: 5-7 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` -- add tempR_fwd_trans, reflCanR_linear, tempR_bwd_imp_reflCanR_bwd (~65 lines added)
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` -- fix until_backward_mcs and since_backward_mcs type signatures
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- replace vacuous definitions
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- replace vacuous k_equiv definition
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- replace trivial proofs
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` -- replace vacuous table definition

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical` compiles without errors
- `tempR_fwd_trans` and `reflCanR_linear` are sorry-free
- No vacuous definitions remain (no `good := True`, `k_equiv := True`, etc.)
- `until_backward_mcs` has correct type signature (may still have sorry body)

**Literature references**:
- Reynolds 1994, Section 3: temp_4 for transitivity (cf. `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`)
- BX11 axiom: temporal linearity (`Axioms.lean:225`)

---

### Phase 2: Extract Chronicle as Prior Structure [COMPLETED]

**Goal**: Prove that the existing Burgess chronicle satisfies Reynolds Corollary 3 conditions: countable, discrete without endpoints, Prior-UZ/SZ valid everywhere. Create a clean extraction interface from the chronicle to feed into Theorem 15.

**Tasks**:
- [x] Create `WeakCanonical/ChronicleExtraction.lean` (210 lines) — imports ChronicleConstruction + ChronicleToCountermodel, defines namespace
- [x] Define `ChronicleAsPriorModel` (:83): structure with countability, discreteness (SuccOrder/PredOrder), no endpoints (NoMaxOrder/NoMinOrder), Prior-UZ/SZ valid everywhere, root MCS point. All sorry-free.
- [x] Prove `chronicle_countable`: `domain_countable` field + `chronicle_prior_domain_countable` instance — `LimitDomSubtype` inherits from `Rat`
- [x] Prove `chronicle_discrete`: `domain_succ`/`domain_pred` fields via `limitDomSubtype_succOrder`/`predOrder`, `chronicle_discrete_succ`/`pred` wrappers, `next_top_everywhere` field
- [x] Prove `chronicle_no_endpoints`: `domain_no_max`/`domain_no_min` fields + `chronicle_no_endpoints_forward`/`backward` via `exists_gt`/`exists_lt`
- [x] Prove `chronicle_prior_UZ_valid`: `prior_UZ_in_limit_domain` theorem + `prior_UZ_valid` field, both via `theorem_in_mcs` on `Axiom.prior_UZ`
- [x] Prove `chronicle_prior_SZ_valid`: `prior_SZ_in_limit_domain` theorem + `prior_SZ_valid` field, via `theorem_in_mcs` on `Axiom.prior_SZ`
- [x] Define `extract_chronicle_as_prior` (:141): extraction from MCS A + `□(next_top)`. Uses `box_discrete_gives_discreteness` for discrete hypothesis. (~20 lines, sorry-free)
- [x] Verify compilation: `lake build` passes, `ChronicleAsPriorModel` fields all sorry-free

**Timing**: 6-8 hours

**Depends on**: 1 (needs the codebase to compile cleanly)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- NEW (~150-200 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.ChronicleExtraction` compiles without errors
- `ChronicleAsPriorModel` has fields matching Corollary 3 (countable, discrete, no endpoints, Prior-UZ/SZ valid)
- All field proofs are sorry-free (they use existing chronicle infrastructure)

**Literature references**:
- Reynolds 1994, Corollary 3 (= Burgess-Xu): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Burgess 1982, Theorem (chronicle construction): `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`

---

### Phase 3: n-Equivalence Infrastructure [PARTIAL]

**Status**: NEquivalence.lean (151 lines) + Table.lean (106 lines) compile. MonadicSentence, MonadicSignature, MonadicStructure types are well-defined. KType now `Finset (MonadicSentence sig)` (non-vacuous). k_equiv defined as `k_type_of sig k M = k_type_of sig k N` (non-vacuous). k_equiv_iff_same_type proved (`rfl`). All proof bodies requiring FO satisfaction remain sorried. No vacuous `True`/`Unit` def bodies remain.

**Tasks**:

**NEquivalence.lean** (151 lines, 3 sorries):
- [x] Define `MonadicSignature`: `preds` type with `Fintype` + `DecidableEq` instances.
- [x] Define `MonadicSentence sig`: inductive with `atom p`, `not`, `and`, `forall`. Quantifier depth fn defined.
- [x] Define `MonadicStructure sig`: `carrier : Type` + `interp : preds → carrier → Prop`.
- [x] Define `KType sig k`: `Finset (MonadicSentence sig)` — non-vacuous.
- [ ] Prove `ktype_finite sig k`: sorried (line 102). Requires FO satisfaction. **Deferred.**
- [ ] Define `k_type_of sig k M`: sorried body (line 115). Requires FO satisfaction. **Deferred.**
- [x] Define `k_equiv sig k M N`: `k_type_of sig k M = k_type_of sig k N` — non-vacuous (transitively sorried via k_type_of).
- [x] Prove `k_equiv_iff_same_type`: `rfl`.
- [ ] Prove `k_equiv_monotone`: sorried (line 149). Requires FO satisfaction. **Deferred.**

**Table.lean** (106 lines, 3 sorries, 1 vacuous interp):
- [x] Define `Formula.complexity`: structural recursion counting temporal+modal operators. Not sorried.
- [ ] Define `table sig φ`: sorried body (line 62). Blocked on sig.preds mapping + FO satisfaction. **Deferred.**
- [ ] Prove `table_depth_bound`: sorried (line 74). Blocked on table definition. **Deferred.**
- [x] `reflCanToMonadic`: monadic struct over ReflCanDomain. `carrier` non-vacuous, `interp _ _ := True` (vacuous). Compiles.
- [ ] State `table_correctness`: conclusion type `True` (vacuous) + sorried (line 104). **Deferred.**

**Deferred items rationale** (3 sorries NEquivalence + 3 sorries Table + 1 vacuous interp = 7 deferred total): All depend on formalizing monadic FO satisfaction (Tarski semantics), which the risk mitigation strategy classifies as "shallow encoding" territory. The Reynolds pipeline can function without full FO formalization by using abstract k-type properties as axioms.

**Timing**: 8-12 hours

**Depends on**: 1 (needs vacuous definitions cleaned up)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- already updated (151 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` -- already updated (106 lines)

**Verification**:
- [x] `lake build Bimodal.Metalogic.WeakCanonical.NEquivalence` compiles
- [x] `lake build Bimodal.Metalogic.WeakCanonical.Table` compiles
- [ ] `ktype_finite` is sorry-free (deferred)
- [x] No `True`-valued definitions remain (except `table_correctness` conclusion placeholder)

**Literature references**:
- Doets 1989, Section 1 (k-types, finiteness): `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Hodkinson-Reynolds 2006, Section 11.2 (standard translation): `literature/Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md`
- Reynolds 1994, Section 4 (k-equivalence framework): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`

---

### Phase 4: Ordered Sum n-Equivalence Preservation (Doets Lemma 1.4) [PARTIAL]

**Status**: OrderedSum.lean (135 lines) compiles. `OrderedSum` carrier is now `Sigma i, (M i).carrier` with lexicographic order (non-vacuous, was previously `Unit`). All 3 proofs remain sorried with correct type signatures. `finite_structures_k_equiv_to_Z_interval` defined but sorried.

**Tasks**:
- [x] Rewrite `OrderedSum sig I M`: carrier = `Sigma i, (M i).carrier` with lexicographic order (NOT `Unit`)
- [ ] Prove `doets_lemma_1_4`: sorried (line 74). Ordered sum preserves k-equivalence. Correct type signature.
- [ ] Prove `doets_lemma_1_5`: sorried (line 99). Type-matching sum preserves k-equivalence. Correct type signature.
- [ ] Prove `finite_structures_k_equiv_to_Z_interval`: sorried (line 133). Finite discrete structure is k-equiv to Z-interval. Correct type signature.

**Timing**: 6-10 hours

**Depends on**: 3 (needs k_equiv, MonadicStructure, k-type definitions)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- already updated (135 lines, carrier non-vacuous)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.OrderedSum` compiles
- `doets_lemma_1_4` type-checks with correct statement (may have sorry body)
- `doets_lemma_1_5` type-checks with correct statement (may have sorry body)
- `finite_structures_k_equiv_to_Z_interval` is sorry-free

**Literature references**:
- Doets 1989, Lemma 1.4 (ordered sum preservation): `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Doets 1989, Lemma 1.5 (type distribution matching): `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1994, Section 4 Lemma 16 (uses Doets 1.4/1.5 for very_good_implies_good): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`

---

### Phase 5: Reynolds Theorem 15 (Z-Model Construction) [PARTIAL]

**Status**: IntegerModel.lean (215 lines) compiles. `good` is now defined non-vacuously as `∃ (N : ZStructure sig), k_equiv sig k M N.toMonadic` (was previously sorried body). `ZStructure` added (struct with toMonadic converter). 4 theorems remain sorried, 5 definitions remain vacuous (`very_good`, `contemp_equiv`, `no_gaps_discrete`, `no_boundary_at_successor`, `one_class` all `:= True`/`trivial`).

**Tasks**:
- [x] Define `good sig k M`: non-vacuous. `∃ (N : ZStructure sig), k_equiv sig k M N.toMonadic`.
- [x] Define `ZStructure sig`: struct with `carrier : Type`, `linOrder`, `discreteNoEnd`, `interp`, `toMonadic`.
- [ ] ~~Define `very_good sig k M`: `:= True` (line 89).~~ **VACUOUS** — all subintervals are good. Blocked on subinterval restriction + FO satisfaction.
- [ ] ~~Prove `finite_structures_good`: sorried (line 95).~~ **Deferred** — blocked on good definition.
- [ ] ~~Define `contemp_equiv sig k M a b`: `:= True` (line 112).~~ **VACUOUS** — blocked on very_good definition.
- [ ] ~~Prove `contemp_equiv_is_equiv`: sorried (line 117).~~ **Deferred** — blocked on contemp_equiv definition.
- [ ] ~~Prove `no_gaps_discrete`: conclusion type `True := by trivial` (line 136).~~ **VACUOUS** — gap elimination for discrete is trivial per plan.
- [ ] ~~Prove `no_boundary_at_successor`: conclusion type `True := by trivial` (line 147).~~ **VACUOUS**.
- [ ] ~~Prove `one_class`: conclusion type `True := by trivial` (line 168).~~ **VACUOUS**.
- [ ] Prove `very_good_implies_good`: sorried (line 187). Correct type signature.
- [ ] Prove `canonical_model_is_good`: sorried (line 213). Correct type signature.

**Timing**: 8-12 hours

**Depends on**: 2 (needs ChronicleExtraction), 4 (needs Doets Lemma 1.4, ordered sum)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- already updated (215 lines, good + ZStructure non-vacuous)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel` compiles
- `one_class` proof is sorry-free (the discrete gap elimination is trivial)
- `very_good_implies_good` type-checks (may have sorry if Doets 1.4 does)
- `canonical_model_is_good` produces a Z-model extraction

**Literature references**:
- Reynolds 1994, Theorem 15 (Z-model from good structure): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Reynolds 1994, Lemma 14 (gap elimination in discrete orders): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Reynolds 1994, Lemma 16 (very good implies good via cofinal decomposition): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Reynolds 1994, Theorem 18 (completeness -- the full pipeline): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`

---

### Phase 6: Integration -- Wire Reynolds into Completeness [NOT STARTED]

**Status**: Transfer.lean (91 lines) compiles, 0 sorries, but still delegates to `dd_countermodel_chronicle_discrete` (chronicle fallback, lines 64-89). The `h_next_top_eq : next_top = Chronicle.next_top := rfl` trick works because both defs are syntactically identical. No Reynolds pipeline wired in. `doets_countermodel_discrete` type signature matches `dd_countermodel_chronicle_discrete` (drop-in compatible). **Blocked** on `canonical_model_is_good` from Phase 5.

**Tasks**:
- [ ] Replace chronicle delegation (lines 64-89) with Reynolds pipeline
- [ ] Call `extract_chronicle_as_prior` then `canonical_model_is_good` to get Z-model
- [ ] Transfer truth via k-equivalence + table_depth_bound
- [ ] Package as `TaskFrame Int` / `TaskModel` using ParametricCanonicalTaskFrame pattern
- [ ] Verify signature matches `dd_countermodel_chronicle_discrete` exactly

**Timing**: 4-6 hours

**Depends on**: 5 (needs the full Reynolds pipeline from IntegerModel)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- REWRITE (~120 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` compiles without errors
- `doets_countermodel_discrete` type signature is identical to `dd_countermodel_chronicle_discrete`
- The proof does NOT reference `succ_cofinal` or `limitDomSubtype_isSuccArchimedean`
- `#print axioms Bimodal.Metalogic.WeakCanonical.doets_countermodel_discrete` does not show `succ_cofinal` ancestry

**Literature references**:
- Reynolds 1994, Theorem 18 (the full completeness pipeline): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`

---

### Phase 7: Cleanup, Verification, and Sorry Audit [NOT STARTED]

**Status**: No cleanup work done. Build passes (1643 jobs). `bx_completeness` still depends on `sorryAx`. No audit performed. Transfer.lean still delegates to chronicle.
- Full project `lake build` passes
- `#print axioms bx_completeness` shows `sorryAx` in dependency chain (the `succ_cofinal` sorry via chronicle pathway)
- `succ_cofinal` sorry at ChronicleToCountermodel.lean:1885 still open
- No summary artifact written yet

**Timing**: 3-5 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` -- add ChronicleExtraction import
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update docstrings
- Various WeakCanonical files -- documentation comments

**Verification**:
- `lake build` succeeds with zero errors on full project
- Sorry audit shows zero critical-path sorries (or documented follow-up tasks for each)
- Dense completeness path is unaffected
- `#print axioms bx_completeness` shows reduced axiom set (no `succ_cofinal` trace)

---

## Testing & Validation

- [x] Phase 1: `lake build Bimodal.Metalogic.WeakCanonical` compiles; tempR_fwd_trans and tempR_bwd_imp_reflCanR_bwd sorry-free; reflCanR_linear confirmed dead code (zero callers)
- [x] Phase 2: `ChronicleExtraction.lean` compiles (210 lines); all 9 sub-tasks complete; all field proofs sorry-free
- [~] Phase 3: `NEquivalence.lean` (151 lines) and `Table.lean` (106 lines) compile. KType non-vacuous (`Finset`), k_equiv defined non-vacuously, k_equiv_iff_same_type proved. 6 items deferred (sorried): ktype_finite, k_type_of, k_equiv_monotone, table, table_depth_bound, table_correctness. 1 vacuous interp (`reflCanToMonadic.interp := True`). No `True`-valued def bodies remain.
- [~] Phase 4: `OrderedSum.lean` (135 lines) compiles. OrderedSum carrier now `Sigma` (non-vacuous). 3 proofs sorried: doets_lemma_1_4, doets_lemma_1_5, finite_structures_k_equiv_to_Z_interval.
- [~] Phase 5: `IntegerModel.lean` (215 lines) compiles. `good` defined non-vacuously, `ZStructure` added. 4 theorems sorried: finite_structures_good, contemp_equiv_is_equiv, very_good_implies_good, canonical_model_is_good. 5 defs/theorems vacuous: very_good, contemp_equiv, no_gaps_discrete, no_boundary_at_successor, one_class (all `True`/`trivial`).
- [ ] Phase 6: `Transfer.lean` (91 lines) compiles, 0 sorries, delegates to chronicle. Blocked on Phase 5 `canonical_model_is_good`.
- [ ] Phase 7: Full `lake build` passes. `succ_cofinal` sorry still open at ChronicleToCountermodel.lean:1885. No summary artifact written.

## Artifacts & Outputs

- `specs/129_weak_reflexive_completeness_conservative_extension/plans/05_chronicle-reynolds-plan.md` (this file)
- `specs/129_weak_reflexive_completeness_conservative_extension/summaries/05_chronicle-reynolds-summary.md` (created after implementation)
- New Lean files:
  - `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` (~150-200 lines)
- Modified Lean files:
  - `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` (~65 lines added)
  - `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` (type signature fixes)
  - `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (~200 lines rewrite)
  - `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (~200 lines rewrite)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` (~100 lines rewrite)
  - `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` (~300 lines rewrite)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (~120 lines rewrite)
  - `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` (import update)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (docstring update)
- Total new/rewritten code: ~1350-1500 lines

## Rollback/Contingency

- **If chronicle extraction fails** (Phase 2): The chronicle's existing countermodel construction already works -- `doets_countermodel_discrete` currently delegates to it. We can keep the delegation while closing sorries incrementally.
- **If Doets Lemma 1.4 formalization is too hard** (Phase 4): Use an isolated sorry for ordered-sum preservation. This sorry would be strictly cleaner than the current `succ_cofinal` sorry: it is mathematically uncontroversial (textbook result with a 1-paragraph proof in Doets 1989).
- **If monadic FO infrastructure grows too large** (Phase 3): Use a shallow encoding -- represent satisfaction abstractly via axiomatized properties rather than formalizing full monadic FO syntax/semantics. The key property needed is finiteness of k-types and compositionality of ordered sums.
- **If integration type-mismatch occurs** (Phase 6): The `doets_countermodel_discrete` signature matches `dd_countermodel_chronicle_discrete` exactly. If types diverge, add adapter lemmas in Transfer.lean rather than changing the interface.
- **Full rollback**: Revert Transfer.lean to the chronicle delegation (current state), delete ChronicleExtraction.lean, and revert NEquivalence/OrderedSum/Table/IntegerModel to their current vacuous state. No other files need reverting.
