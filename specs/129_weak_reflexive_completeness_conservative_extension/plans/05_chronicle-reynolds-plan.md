# Implementation Plan: Task #129 (Chronicle + Reynolds Theorem 15)

- **Task**: 129 - weak_reflexive_completeness_conservative_extension
- **Status**: [IMPLEMENTING]
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

### Phase 1: Bug Fixes and Codebase Cleanup [IN PROGRESS]

**Goal**: Fix all identified bugs in the WeakCanonical directory, remove vacuous definitions, and ensure the existing sorry-free proofs still compile.

**Tasks**:
- [ ] Fix `until_backward_mcs` type signature in `TruthLemma.lean:450` -- currently states the forward direction with a negated hypothesis (should state: from `Formula.untl psi1 psi2 not-in x.val`, derive the NEGATION of the semantic condition, i.e., existence of a counter-witness). Since this lemma is not needed for Path A, change it to have the correct type signature and leave the sorry, or mark it as dead code with a comment explaining Path A bypasses it.
- [ ] Fix `since_backward_mcs` type signature in `TruthLemma.lean:492` -- same bug, mirror of until_backward_mcs.
- [ ] Replace vacuous definitions in `IntegerModel.lean`: `good := True`, `very_good := True`, `contemp_equiv := True` with `sorry`-based stubs that have correct types (or delete and rebuild in Phase 5).
- [ ] Replace vacuous definitions in `NEquivalence.lean`: `k_equiv := True` with proper placeholder.
- [ ] Replace vacuous definitions in `OrderedSum.lean`: `doets_lemma_1_4` and `doets_lemma_1_5` prove `True` instead of the real statements; convert to proper sorry-based stubs.
- [ ] Replace vacuous `table` definition in `Table.lean`: currently returns `.atom` for everything; convert to proper sorry-based stub.
- [ ] Prove `tempR_fwd_trans` in `ReflexiveCanonical.lean`: transitivity of tempR_fwd via temp_4 (`G(psi) -> G(G(psi))`). Teammate C confirmed this is provable. (~20 lines)
- [ ] Prove `reflCanR_linear` in `ReflexiveCanonical.lean`: linearity from BX11 temporal linearity axiom. (~30 lines)
- [ ] Prove `tempR_bwd_imp_reflCanR_bwd` backward bridge lemma in `ReflexiveCanonical.lean`: if tempR_bwd y x, then the backward analog of reflCanR holds. (~15 lines)
- [ ] Verify `lake build Bimodal.Metalogic.WeakCanonical` compiles with no new errors (sorries are acceptable, build errors are not).

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

### Phase 2: Extract Chronicle as Prior Structure [NOT STARTED]

**Goal**: Prove that the existing Burgess chronicle satisfies Reynolds Corollary 3 conditions: countable, discrete without endpoints, Prior-UZ/SZ valid everywhere. Create a clean extraction interface from the chronicle to feed into Theorem 15.

**Tasks**:
- [ ] Create `WeakCanonical/ChronicleExtraction.lean` importing the chronicle infrastructure
- [ ] Define `ChronicleAsPriorModel`: a structure wrapping the chronicle's BFMCS output with Corollary 3 conditions as fields
- [ ] Prove `chronicle_countable`: the chronicle domain is countable (it is a subtype of rationals with membership in a countable set of MCS). The chronicle lives on `limitDom` which embeds into `Rat`. (~20 lines)
- [ ] Prove `chronicle_discrete`: every point in the discrete box-class has an immediate successor (from `next_top ∈ MCS` for all MCS in the box-class, which follows from `h_box_discrete`). (~30 lines)
- [ ] Prove `chronicle_no_endpoints`: the chronicle has no maximum or minimum element (from seriality axioms `serial_future` and `serial_past` in every MCS, by `theorem_in_mcs`). (~20 lines)
- [ ] Prove `chronicle_prior_UZ_valid`: Prior-UZ holds at every point (Prior-UZ is an axiom, hence in every MCS; truth lemma gives validity). The chronicle's parametric truth lemma already covers this. (~15 lines)
- [ ] Prove `chronicle_prior_SZ_valid`: Mirror for Prior-SZ. (~15 lines)
- [ ] Define the extraction function: given MCS A with neg(phi) and box(next_top), produce a `ChronicleAsPriorModel` from `cantor_bfmcs_discrete A h_mcs h_box_discrete`. (~30 lines)
- [ ] Verify the extraction compiles and the Corollary 3 conditions type-check.

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

### Phase 3: n-Equivalence Infrastructure [NOT STARTED]

**Goal**: Define monadic first-order k-equivalence, k-types, and prove finiteness. This is pure combinatorics/order theory with no dependency on the canonical model or chronicle. Replaces the vacuous definitions currently in NEquivalence.lean, OrderedSum.lean, and Table.lean.

**Tasks**:
- [ ] Rewrite `WeakCanonical/NEquivalence.lean` with proper definitions:
  - Define `MonadicSignature` properly: a finite set of unary predicate symbols (representing subformula-closure atoms) plus a binary order relation. Keep current structure but ensure `Fintype` and `DecidableEq` instances. (~20 lines)
  - Define `MonadicStructure sig` properly: carrier type with `LinearOrder`, `Fintype` or `Countable` constraint, and predicate interpretations `sig.preds -> Set carrier`. (~30 lines)
  - Define `KType sig k`: a k-type as an equivalence class of structures under depth-k agreement. Represent as `Finset (MonadicSentence sig)` -- the set of depth-leq-k sentences true in any structure of that type. (~20 lines)
  - Prove `ktype_finite sig k`: There are finitely many k-types for a finite signature. By induction on k: depth-0 types are determined by which atoms hold (finitely many subsets of a finite set); depth k+1 types add finitely many quantified sentences over depth-k types. Cf. Doets 1989, Section 1. (~60 lines)
  - Define `k_equiv sig k M N` properly: M and N satisfy the same monadic sentences of depth leq k. Use `forall (s : MonadicSentence sig), s.quantifier_depth <= k -> (M satisfies s <-> N satisfies s)`. (~15 lines)
  - Define `k_type_of sig k M`: the k-type realized by M. (~10 lines)
  - Prove `k_equiv_iff_same_type`: k-equivalence iff same k-type. (~15 lines)

- [ ] Rewrite `WeakCanonical/Table.lean` with proper standard translation:
  - Define `table sig phi : MonadicSentence sig` by structural recursion on Formula. The translation maps each TM formula to its standard first-order translation (cf. Hodkinson-Reynolds 2006 Section 11.2). (~40 lines)
  - Prove `table_depth_bound sig phi`: quantifier depth of table(phi) is bounded by formula complexity. (~20 lines)
  - State `table_correctness` (may use sorry -- full proof requires monadic FO satisfaction which is optional): for all structures M, all t, truth_at M t phi iff M satisfies table(phi) at t. (~10 lines)

**Timing**: 8-12 hours

**Depends on**: 1 (needs vacuous definitions cleaned up)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- REWRITE (~200 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` -- REWRITE (~100 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.NEquivalence` compiles
- `lake build Bimodal.Metalogic.WeakCanonical.Table` compiles
- `ktype_finite` is sorry-free (or has at most one isolated sorry for the induction base, flagged)
- No `True`-valued definitions remain

**Literature references**:
- Doets 1989, Section 1 (k-types, finiteness): `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Hodkinson-Reynolds 2006, Section 11.2 (standard translation): `literature/Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md`
- Reynolds 1994, Section 4 (k-equivalence framework): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`

---

### Phase 4: Ordered Sum n-Equivalence Preservation (Doets Lemma 1.4) [NOT STARTED]

**Goal**: Prove that k-equivalence is preserved by ordered sums. This is the core combinatorial result needed for Reynolds Theorem 15 gap elimination.

**Tasks**:
- [ ] Rewrite `WeakCanonical/OrderedSum.lean`:
  - Define `OrderedSum sig I M : MonadicStructure sig` properly: carrier = disjoint union `Sigma i, (M i).carrier`, order = lexicographic (i < j implies all of M(i) before M(j); within M(i), use its own order). (~40 lines)
  - Prove Doets Lemma 1.4: `forall i, k_equiv sig k (m i) (m' i) -> k_equiv sig k (OrderedSum sig I m) (OrderedSum sig I m')`. Proof by induction on k. Base case (k=0): both sums agree on quantifier-free sentences since each component does. Inductive step: an existential witness in m(i) transfers to m'(i) since they are (k-1)-equivalent; the ordering between different summands is preserved since I is the same. (~80 lines)
  - Prove Doets Lemma 1.5 (Reynolds variant for type-matching sums): If the distribution of k-types in I and J matches (same number of each type, same order-theoretic adjacency), then the sums are k-equivalent. This is the key lemma for the very_good_implies_good step. (~60 lines)
  - Prove `finite_structures_k_equiv_to_Z_interval`: A finite discrete linear structure of size n is k-equivalent to the Z-interval [0, n-1]. Trivially true since they are isomorphic. (~15 lines)

**Timing**: 6-10 hours

**Depends on**: 3 (needs k_equiv, MonadicStructure, k-type definitions)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- REWRITE (~200 lines)

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

### Phase 5: Reynolds Theorem 15 (Z-Model Construction) [NOT STARTED]

**Goal**: Implement Reynolds Theorem 15: define good/very good, contemporaneous equivalence, prove the one-class theorem for discrete structures, and extract the Z-model. The input is the chronicle from Phase 2; the output is a Z-model k-equivalent to the chronicle.

**Tasks**:
- [ ] Rewrite `WeakCanonical/IntegerModel.lean` with proper definitions:
  - Define `good sig k M : Prop` properly: there exists a Z-interval structure N such that `k_equiv sig k M N`. (~10 lines)
  - Define `very_good sig k M : Prop` properly: for all subintervals [a,b] of M, `good sig k (M.restrict [a,b])`. (~15 lines)
  - Prove `finite_structures_good`: every finite discrete structure is good (finite = isomorphic to Z-interval of same size, hence k-equivalent). (~20 lines)
  - Define `contemp_equiv sig k M a b : Prop`: a = b, or a < b and very_good(M|[a,b]), or b < a and very_good(M|[b,a]). (~15 lines)
  - Prove `contemp_equiv_is_equiv`: ~M is an equivalence relation with convex classes. Reflexivity: trivial (a = a case). Symmetry: by case analysis. Transitivity: uses ordered-sum preservation (Doets 1.4 from Phase 4) -- if [a,b] and [b,c] are both very good, then any subinterval of [a,c] decomposes into subintervals of [a,b] and [b,c], each good. (~80 lines)
  - Prove `no_gaps_discrete`: in a discrete linear order with immediate successors, ~M classes cannot end at Dedekind gaps (there are no gaps -- every cut is a successor/predecessor pair). This is TRIVIAL for discrete orders. (~15 lines)
  - Prove `no_boundary_at_successor`: if c and c+1 are in different ~M classes, then M|[c,c+1] is a 2-element structure (finite, hence good by `finite_structures_good`), so c ~ c+1 by transitivity. Contradiction. (~25 lines)
  - Prove `one_class`: combining `no_gaps_discrete` and `no_boundary_at_successor`: M has exactly one ~M class. (~20 lines)
  - Prove `very_good_implies_good` (Reynolds Lemma 16): If M is countable and very good, then M is good. Choose cofinal sequence a_0 < a_1 < ..., each M|[a_i, a_{i+1}] is good, choose k-equivalent Z-intervals, form ordered sum via Doets 1.4/1.5. (~60 lines)
  - Prove `canonical_model_is_good`: the chronicle (restricted to box-class), being countable and very good (by `one_class`), is good. Extract the Z-model N with k_equiv k M N. (~30 lines)

**Timing**: 8-12 hours

**Depends on**: 2 (needs ChronicleExtraction), 4 (needs Doets Lemma 1.4, ordered sum)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- REWRITE (~300 lines)

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

**Goal**: Replace the chronicle fallback in `doets_countermodel_discrete` with the Reynolds pipeline. Wire the full chain: consistent neg(phi) -> Lindenbaum -> chronicle -> Theorem 15 -> Z-model -> TaskFrame/TaskModel counterexample.

**Tasks**:
- [ ] Rewrite `WeakCanonical/Transfer.lean`:
  - Remove the interim chronicle delegation (lines 64-89)
  - Implement the full Reynolds pipeline:
    1. Build chronicle from MCS A via `ChronicleExtraction` (Phase 2)
    2. Apply `canonical_model_is_good` to get Z-model N with k_equiv k M N
    3. Transfer: neg(phi) true in chronicle (by chronicle truth lemma) implies neg(phi) holds in N (by k-equivalence and table_depth_bound)
    4. Package N as `TaskFrame Int` / `TaskModel` / `WorldHistory` using the `ParametricCanonicalTaskFrame Int` pattern from ChronicleToCountermodel.lean:3293
  - Ensure `doets_countermodel_discrete` type signature remains IDENTICAL to current (~40 lines body)
- [ ] Update imports in Transfer.lean to include ChronicleExtraction
- [ ] Verify `lake build Bimodal.Metalogic.WeakCanonical.Transfer` compiles
- [ ] Verify the type signature of `doets_countermodel_discrete` still matches `dd_countermodel_chronicle_discrete`

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

**Goal**: Full project build, sorry audit, documentation update, and cleanup of dead code.

**Tasks**:
- [ ] Run `lake build` on full project -- verify no regressions
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/` to audit sorry count
- [ ] For each remaining sorry, document:
  - Which Reynolds/Doets result it corresponds to
  - Whether it is on the critical path for `bx_completeness`
  - Whether it represents known mathematics (textbook result) or a genuine gap
- [ ] Verify `#print axioms bx_completeness` -- check if `succ_cofinal` sorry no longer appears in the dependency chain
- [ ] Update docstring in `Completeness.lean` to reference the Reynolds construction
- [ ] Update `WeakCanonical/WeakCanonical.lean` root import to include `ChronicleExtraction`
- [ ] Mark dead code in TruthLemma.lean (Until/Since lemmas that Path A bypasses) with clear comments
- [ ] If any sorry on the critical path remains, create a follow-up task with specific scope
- [ ] Verify dense completeness path (`dd_countermodel_chronicle_dense`) is unaffected
- [ ] All existing tests pass

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

- [ ] Phase 1: `lake build Bimodal.Metalogic.WeakCanonical` compiles; tempR_fwd_trans and reflCanR_linear sorry-free
- [ ] Phase 2: `ChronicleExtraction.lean` compiles; Corollary 3 conditions are sorry-free
- [ ] Phase 3: `NEquivalence.lean` and `Table.lean` compile; ktype_finite has correct statement
- [ ] Phase 4: `OrderedSum.lean` compiles; Doets Lemma 1.4 has correct type signature
- [ ] Phase 5: `IntegerModel.lean` compiles; one_class is sorry-free; very_good_implies_good type-checks
- [ ] Phase 6: `Transfer.lean` compiles; doets_countermodel_discrete matches dd_countermodel_chronicle_discrete signature
- [ ] Phase 7: Full `lake build` with zero errors; `#print axioms bx_completeness` shows no `succ_cofinal`
- [ ] Sorry audit: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/` with documented classification of each

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
