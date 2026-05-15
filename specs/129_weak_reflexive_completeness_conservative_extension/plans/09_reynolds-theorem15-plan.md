# Implementation Plan: Task #129 (Reynolds Theorem 15, v3)

- **Task**: 129 - weak_reflexive_completeness_conservative_extension
- **Status**: [NOT STARTED]
- **Effort**: 20-28 hours
- **Dependencies**: None (uses existing ChronicleExtraction, NEquivalence, and WeakCanonical infrastructure)
- **Research Inputs**: specs/129_weak_reflexive_completeness_conservative_extension/reports/09_team-research.md
- **Artifacts**: plans/09_reynolds-theorem15-plan.md (this file)
- **Standards**: .claude/context/formats/plan-format.md, .claude/rules/artifact-formats.md, .claude/rules/state-management.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is plan version 3, replacing the prior plan (v2 at plans/05_chronicle-reynolds-plan.md) which overstated completion and contains structural errors identified by a 4-teammate audit. The codebase has a broken build (duplicate `ZStructure`), a circular axiomatization (`z_model_exists` axiomatizes Theorem 15's conclusion), a wrong definition of `good` (forces full Z instead of Z-intervals), and 17 substantive sorries. This plan fixes structural errors first, then implements the discrete case of Reynolds Theorem 15 following the paper literally. Definition of done: `lake build` passes, `chronicle_is_good` is sorry-free, and `doets_countermodel_discrete` uses the Reynolds pipeline instead of the chronicle fallback.

### Research Integration

Key findings from report 09 (team research, 4 teammates):
1. **Build broken**: Duplicate `ZStructure` in NEquivalence.lean and IntegerModel.lean (Finding 1)
2. **Circular axiomatization**: `KEquivalenceFramework.z_model_exists` axiomatizes the very conclusion Theorem 15 must prove (Finding 2)
3. **`good` definition wrong**: `ZStructure` forces carrier = Z, making `finite_structures_good` mathematically false (Finding 3)
4. **MonadicSentence lacks `<`**: Order relation missing from monadic language (Finding 5)
5. **OrderedSum returns unordered**: Returns `MonadicStructure` not `OrderedMonadicStructure` (Finding 6)
6. **Doets Lemma 1.5 incorrectly stated**: Unconditional falsehood (Finding 7)
7. **Table translation vacuous**: `table_correctness` proves `True`, `Formula.complexity` wrong for Until/Since (Finding 8)
8. **Dead code**: `canonical_model_is_good`, `reflCanR_linear`, `reflCanToMonadic`, vacuous `table_correctness` (Finding 9)

### Prior Plan Reference

Prior plan v2 (plans/05_chronicle-reynolds-plan.md) completed Phases 1-2 (bug fixes, chronicle extraction) with sorry-free proofs. Phases 3-7 were marked COMPLETED but the audit found 17 sorries and structural errors. Key lessons: (a) the `KEquivalenceFramework` shallow-encoding approach is sound but the `z_model_exists` field defeats its purpose, (b) `ChronicleExtraction.lean` and `ChronicleAsPriorModel` are valid and should be preserved, (c) `OrderedMonadicStructure` with `subinterval` is a good design, (d) effort estimates for proof-closing work were far too optimistic.

### Roadmap Alignment

This plan advances the critical-path sorry in the discrete completeness branch (ROADMAP.md Phase 1). Success eliminates the `succ_cofinal` sorry from `dd_countermodel_chronicle_discrete` by replacing the chronicle fallback with a Reynolds Theorem 15 construction.

## Goals & Non-Goals

**Goals**:
- Fix build: remove duplicate `ZStructure` from IntegerModel.lean
- Remove circular `z_model_exists` from `KEquivalenceFramework`
- Fix `good` to allow Z-intervals (finite subsets of Z), not just full Z
- Add `<` to `MonadicSentence` (or encode order structurally)
- Define FO satisfaction relation for finite monadic structures
- Prove `finite_structures_good` (finite structure is k-equiv to Z-interval)
- Prove `no_boundary_at_successor` (2-element subinterval is finite hence good)
- Prove `contemp_equiv_is_equiv` (transitivity via Lemma 1.4 for 2-component sums)
- Prove `no_gaps_discrete` (trivial: discrete orders have no Dedekind gaps)
- Prove `one_class` (Reynolds's 4-line contradiction argument)
- Prove `chronicle_is_good` (one_class + cofinal sequence + pairwise Lemma 1.4)
- Wire `doets_countermodel_discrete` to use Reynolds pipeline instead of chronicle fallback
- Eliminate `succ_cofinal` sorry from `bx_completeness` dependency chain

**Non-Goals**:
- Formalizing full Ehrenfeucht-Fraisse games (syntactic k-type approach suffices)
- Modifying Formula, Axiom, truth_at, or soundness theorems
- Closing the Until/Since truth lemma sorries in WeakCanonical/TruthLemma.lean
- Changing the dense completeness branch
- Building a separate "weak axiom system" or "weak MCS" type
- Proving Doets Lemma 1.5 (not needed for discrete case)
- Resolving `dd_countermodel_chronicle_mixed_sorry`
- Formalizing Kamp's expressive completeness theorem

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| FO satisfaction for finite structures requires more than ~100 lines | MEDIUM | MEDIUM | Use decidable satisfaction (finite carrier, finite signature). Lean's `Decidable` instance derivation handles most cases. Target: evaluation function, not full Tarski semantics. |
| `ZIntervalStructure` design is complex (finite intervals of Z) | MEDIUM | LOW | Use `{n : Z // lo <= n /\ n <= hi}` carrier with inherited order. Alternatively, use `Fin n` carrier with shift. Reynolds only needs "flow is an interval of the integers." |
| Transitivity of `contemp_equiv` requires ordered sum composition | MEDIUM | LOW | Follow Reynolds literally: M|[t,b] good, M|[b+1,u] good, so Z1 + Z2 has Z-interval flow, hence M|[t,u] good. Use existing `OrderedSum` + `doets_lemma_1_4`. |
| Table translation is on the critical path for Transfer.lean | HIGH | MEDIUM | For the discrete case, table correctness can be axiomatized as a single lemma (the standard translation is a known result). Full table formalization is deferred. |
| Cofinal sequence construction for countable no-endpoint order | MEDIUM | LOW | Use `exists_lt`/`exists_gt` from `NoMaxOrder`/`NoMinOrder` iteratively via `Nat.rec`. Standard construction. |
| Transfer.lean type compatibility | LOW | HIGH | External signatures are identical; only internal proof changes. The `h_next_top_eq : next_top = Chronicle.next_top := rfl` trick is preserved. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Fully sequential: each phase builds on the prior phase's changes.

---

### Phase 1: Fix Build and Remove Structural Errors [NOT STARTED]

**Goal**: Restore a passing `lake build`, remove circularity, fix wrong definitions, and clean dead code. This phase touches definitions only -- no proof closing.

**Tasks**:
- [ ] **1.1 Remove duplicate `ZStructure` from IntegerModel.lean** (lines 49-69): Delete the `ZStructure`, `ZStructure.toOrderedMonadic`, and `ZStructure.toMonadic` definitions. They already exist in NEquivalence.lean (lines 185-195). IntegerModel.lean already imports NEquivalence transitively via OrderedSum.
- [ ] **1.2 Remove `z_model_exists` from `KEquivalenceFramework`** (NEquivalence.lean lines 308-321): Delete the `z_model_exists` field from the typeclass. This field axiomatizes Theorem 15's conclusion as a premise, creating a circularity. The framework should provide ONLY Doets 1989 properties (equiv_at, equiv_is_equiv, equiv_monotone, finite_types, sum_preservation).
- [ ] **1.3 Fix `good` definition to allow Z-intervals**: Currently `good` requires a `ZStructure` (carrier = full Z). Reynolds defines "good" as k-equivalent to a structure whose flow is "an interval of the integers." Define a new `ZIntervalStructure` type with carrier `{n : Z // lo <= n /\ n <= hi}` (or parameterized by optional bounds), and update `good` to use it. Alternatively, redefine `good` as `exists (N : MonadicStructure sig), k_equiv sig k M.toMonadic N /\ IsZInterval N.carrier` where `IsZInterval` means order-isomorphic to an interval of Z.
- [ ] **1.4 Add order relation `<` to `MonadicSentence`**: Add a constructor `| lt : MonadicSentence sig` representing the order relation x < y (or add it to the signature). Without this, k-equivalence cannot distinguish ordered structures. Update `quantifier_depth` for the new constructor.
- [ ] **1.5 Fix `OrderedSum` to return `OrderedMonadicStructure`**: Currently `OrderedSum` (NEquivalence.lean lines 172-175) returns `MonadicStructure`. Change it to return `OrderedMonadicStructure` with lexicographic order on `Sigma i, (M i).carrier`. This requires `LinearOrder I` and `LinearOrder (M i).carrier` for each i.
- [ ] **1.6 Fix `doets_lemma_1_5` type signature**: Add the matching-type-distribution hypothesis. Current statement (OrderedSum.lean line 112) is unconditionally false. Update to require that for all k-types tau, the number of indices i with k-type(m i) = tau equals the number of indices j with k-type(m' j) = tau.
- [ ] **1.7 Fix `Formula.complexity` for Until/Since**: Currently `untl _ _` and `snce _ _` return 0 (Table.lean lines 41-42). Change to `max phi.complexity psi.complexity + 1` (Until/Since have FO tables with one quantifier).
- [ ] **1.8 Fix `table_correctness` type signature**: Change conclusion from `True` to a proper equivalence relating temporal truth and monadic satisfaction. At minimum, change to `sorry`-based stub with correct type.
- [ ] **1.9 Fix `reflCanToMonadic`**: Replace vacuous `interp _ _ := True` body with `sorry`-based stub, or delete (it has 0 callers).
- [ ] **1.10 Delete dead code**: Remove deprecated `canonical_model_is_good` (IntegerModel.lean lines 283-292, 0 callers). Remove vacuous `table_correctness` with `True` conclusion. Keep `reflCanR_linear` as-is (already documented dead code from Phase 1 v2).
- [ ] **1.11 Verify build**: Run `lake build` and confirm zero errors.

**Timing**: 2-3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- remove `z_model_exists` from KEquivalenceFramework, add `lt` to MonadicSentence, fix OrderedSum return type
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- remove duplicate ZStructure, update `good` definition, delete `canonical_model_is_good`
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- update types to use OrderedMonadicStructure, fix `doets_lemma_1_5` signature
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` -- fix `Formula.complexity` for Until/Since, fix `table_correctness`, fix/delete `reflCanToMonadic`

**Verification**:
- `lake build` passes with zero errors
- `KEquivalenceFramework` has exactly 5 fields (no `z_model_exists`)
- `good` definition allows Z-intervals, not just full Z
- `MonadicSentence` has an `lt` constructor
- `OrderedSum` returns `OrderedMonadicStructure`
- No duplicate `ZStructure` definitions exist
- `grep -r "canonical_model_is_good" Theories/` returns only import/comment references

---

### Phase 2: FO Satisfaction for Finite Monadic Structures [NOT STARTED]

**Goal**: Define a decidable FO satisfaction relation for monadic structures over finite carriers and finite signatures. This is the single biggest gap identified by the research (Finding 1 in Sorry Census Tier 1). All downstream proofs (k_type_of, ktype_finite, k_equiv) depend on this.

**Tasks**:
- [ ] **2.1 Define `MonadicSentence.eval`**: A decidable evaluation function for monadic sentences in a structure with a concrete carrier assignment. For finite structures, this is just recursive evaluation:
  ```
  eval : MonadicStructure sig -> (sig.carrier -> Bool) -> MonadicSentence sig -> Bool
  | M, env, .atom p => M.interp p (env ...)
  | M, env, .not s => !eval M env s
  | M, env, .and s t => eval M env s && eval M env t
  | M, env, .forall s => Fintype.decide_forall (fun x => eval M (update env x) s)
  | M, env, .lt => ...  -- order comparison on assigned variables
  ```
  The exact encoding depends on how variable binding works in `MonadicSentence`. For the monadic case (1 free variable), quantification is over elements of the carrier.
- [ ] **2.2 Define `MonadicSentence.satisfies`**: The propositional version `M |= s` meaning the sentence s is true in M (no free variables). For sentences (closed formulas), this is `eval M defaultEnv s = true`.
- [ ] **2.3 Close `k_type_of`**: Define as `{s : MonadicSentence sig | s.quantifier_depth <= k /\ M.satisfies s}` converted to a Finset. This requires decidability of `satisfies` and finiteness of the set of sentences of bounded depth over a finite signature.
- [ ] **2.4 Close `ktype_finite`**: Prove there are finitely many k-types. Each k-type is a subset of the finite set of sentences of depth <= k, so there are at most 2^|S_k| types.
- [ ] **2.5 Close `k_equiv_monotone`**: With `k_type_of` defined, monotonicity follows from the fact that depth-m sentences are a subset of depth-k sentences when m <= k.
- [ ] **2.6 Verify build**: Run `lake build` and confirm compilation.

**Timing**: 4-6 hours (this is the core new mathematical content, ~100-150 lines)

**Depends on**: 1 (needs fixed MonadicSentence with `lt`, fixed KEquivalenceFramework)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- add `eval`, `satisfies`, close `k_type_of`, `ktype_finite`, `k_equiv_monotone` (~100-150 lines)

**Verification**:
- `lake build` passes
- `k_type_of` is sorry-free
- `ktype_finite` is sorry-free
- `k_equiv_monotone` is sorry-free
- `#check @MonadicSentence.satisfies` shows correct type

---

### Phase 3: Ordered Sum Preservation and Finite Structures Good [NOT STARTED]

**Goal**: Close `doets_lemma_1_4` (ordered sum preserves k-equivalence) and `finite_structures_good` (every finite structure is good, i.e., k-equivalent to a Z-interval). These are the foundations for the gap-elimination chain.

**Tasks**:
- [ ] **3.1 Close `doets_lemma_1_4`**: With FO satisfaction defined, prove that if component structures are k-equivalent, their ordered sums are k-equivalent. Proof by induction on k using the Ehrenfeucht-Fraisse game characterization (or by showing that the ordered sum's k-type is determined by the sequence of component k-types). This is Doets 1989 Lemma 1.4.
- [ ] **3.2 Instantiate `KEquivalenceFramework`**: Create a concrete instance of the typeclass using the FO satisfaction relation from Phase 2. Each field (`equiv_at`, `equiv_is_equiv`, `equiv_monotone`, `finite_types`, `sum_preservation`) gets a proof from the FO semantics.
- [ ] **3.3 Close `finite_structures_k_equiv_to_Z_interval`**: Prove every finite monadic structure is k-equivalent to some Z-interval structure. Proof by induction on cardinality: singleton is trivially equivalent to a Z-singleton; inductive step decomposes into ordered sum of (n-1) structure and singleton, applies IH, then uses Lemma 1.4 for 2-component sum.
- [ ] **3.4 Close `finite_structures_good`**: With `finite_structures_k_equiv_to_Z_interval` proved, `finite_structures_good` follows directly from the definition of `good`.
- [ ] **3.5 Verify build**: Run `lake build`.

**Timing**: 4-6 hours

**Depends on**: 2 (needs FO satisfaction, closed `k_type_of`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- add KEquivalenceFramework instance (~30 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- close `doets_lemma_1_4`, `finite_structures_k_equiv_to_Z_interval` (~60 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- close `finite_structures_good` (~10 lines)

**Verification**:
- `lake build` passes
- `doets_lemma_1_4` is sorry-free
- `finite_structures_k_equiv_to_Z_interval` is sorry-free
- `finite_structures_good` is sorry-free
- `#check @KEquivalenceFramework.mk` shows 5 fields

---

### Phase 4: Gap Elimination and One-Class Theorem [NOT STARTED]

**Goal**: Prove the discrete case of Reynolds Theorem 15: `contemp_equiv_is_equiv`, `no_boundary_at_successor`, `no_gaps_discrete`, and `one_class`. This is the heart of the theorem and follows Reynolds literally in 4 steps.

**Tasks**:
- [ ] **4.1 Prove `no_boundary_at_successor`**: For any point c, the subinterval [c, succ(c)] has exactly 2 elements (`subinterval_two_element_finite`), hence is finite, hence good (`finite_structures_good`). Every subinterval of a 2-element structure is also finite hence good, so [c, succ(c)] is very good. Therefore c ~M succ(c) by definition of `contemp_equiv`.
- [ ] **4.2 Prove `contemp_equiv_is_equiv`** (transitivity is the hard part): Follow Reynolds's proof literally (paper lines 936-953):
  - **Reflexivity**: M|[a,a] is singleton, finite, hence good, hence very good. So a ~M a.
  - **Symmetry**: min/max are symmetric. Trivial.
  - **Transitivity**: Suppose a < b < c with a ~M b and b ~M c. Show M|[a,c] is very good by showing that for any t,u with a <= t < u <= c, M|[t,u] is good.
    - If t,u on same side of b: clear from a ~M b or b ~M c.
    - If b = t or b = u: use ordered sum of two good structures.
    - If t < b < u: M|[t,b] is good and M|[b+1,u] is good (since b ~M c implies M|[b,c] very good, and b+1 <= u <= c). Choose Z1 ~k M|[t,b] and Z2 ~k M|[b+1,u] with Z-interval flows. Then Z1 + Z2 has Z-interval flow, so M|[t,u] ~k Z1 + Z2 is good.
- [ ] **4.3 Prove `no_gaps_discrete`**: In a discrete order, if a and b are in different ~M classes, then the boundary between classes must fall at some adjacent pair (c, succ(c)). Proof: the set {x : a ~M x, x <= b} is nonempty (contains a) and bounded above (by b). In a discrete order, this set has a supremum c (as a maximum of a bounded set in a discrete order, using well-foundedness of the reverse order on [a,b]). Then c ~M a and succ(c) is not ~M a. Note: in discrete orders there are no Dedekind gaps, so class boundaries can ONLY occur at successor pairs.
- [ ] **4.4 Prove `one_class`**: Reynolds's 4-line argument by contradiction:
  - Suppose there exist a, b with a not ~M b.
  - By `no_gaps_discrete`: there exists c with c ~M a and succ(c) not ~M a.
  - But `no_boundary_at_successor` says c ~M succ(c).
  - By transitivity (`contemp_equiv_is_equiv`): succ(c) ~M a. Contradiction.
  - Therefore for all a, b: a ~M b.
- [ ] **4.5 Verify build**: Run `lake build`.

**Timing**: 4-6 hours

**Depends on**: 3 (needs `finite_structures_good`, `doets_lemma_1_4`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- close `no_boundary_at_successor` (~15 lines), `contemp_equiv_is_equiv` (~40 lines), `no_gaps_discrete` (~25 lines), `one_class` (~15 lines)

**Verification**:
- `lake build` passes
- `no_boundary_at_successor` is sorry-free
- `contemp_equiv_is_equiv` is sorry-free
- `no_gaps_discrete` is sorry-free
- `one_class` is sorry-free

---

### Phase 5: Chronicle Is Good and Very-Good-Implies-Good [NOT STARTED]

**Goal**: Prove `chronicle_is_good` (the main theorem of the Reynolds pipeline) and `very_good_implies_good` (Reynolds Lemma 16). With `one_class` proved, the chronicle is very good, and Lemma 16 compresses it to a Z-model.

**Tasks**:
- [ ] **5.1 Prove `very_good_implies_good`** (Reynolds Lemma 16): If N is countable and very good, then N is good. Proof for the no-endpoints case (our case):
  - Choose a0 in N. Build cofinal sequences a_(-n) decreasing and a_n increasing using NoMinOrder/NoMaxOrder + Countable.
  - Each finite subinterval N|[a_i, a_{i+1}-1] is good (it is finite, hence good by `finite_structures_good`).
  - For each i, choose Z_i ~k N|[a_i, a_{i+1}-1] with Z-interval flow.
  - By Doets Lemma 1.4 (sum preservation): N ~k sum_i(Z_i).
  - The ordered sum of Z-intervals is itself a Z-interval (concatenation of integer intervals). So N is good.
- [ ] **5.2 Prove `chronicle_is_good`**: The chronicle CM = chronicleAsMonadicStructure M sig atomMap is:
  - Discrete, countable, no endpoints (from ChronicleAsPriorModel).
  - By `one_class`: all points are ~M equivalent.
  - Therefore CM is very good (for any a <= b, M|[a,b] is very good because all subintervals have endpoints in the same ~M class).
  - By `very_good_implies_good`: CM is good.
- [ ] **5.3 Verify build**: Run `lake build`.

**Timing**: 3-4 hours

**Depends on**: 4 (needs `one_class`, `contemp_equiv_is_equiv`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- close `very_good_implies_good` (~40 lines), `chronicle_is_good` (~20 lines)

**Verification**:
- `lake build` passes
- `very_good_implies_good` is sorry-free
- `chronicle_is_good` is sorry-free
- `#print axioms chronicle_is_good` shows no `succ_cofinal`

---

### Phase 6: Wire Reynolds Pipeline into Transfer.lean [NOT STARTED]

**Goal**: Replace the chronicle fallback in `doets_countermodel_discrete` with the Reynolds pipeline using `chronicle_is_good`. Verify that `succ_cofinal` is eliminated from the axiom set.

**Tasks**:
- [ ] **6.1 Define `mkSigFrom`**: Build a `MonadicSignature` from the subformulas of a formula phi. The predicate set is the set of atoms appearing in phi (finite by definition).
- [ ] **6.2 Define `mkAtomMap`**: Map each predicate symbol in the signature to the corresponding temporal formula (the atom it represents in the chronicle's MCS labeling).
- [ ] **6.3 Define or axiomatize table correctness for discrete case**: The standard translation theorem: for any temporal formula phi and point t in M, `M |= phi at t` iff `monadic(M) |= table(phi) at t`. For the discrete case, this can be stated as a lemma with sorry body (the result is known from Hodkinson-Reynolds 2006) or proved from the FO satisfaction relation. At minimum, provide a sorry-based bridge lemma that types correctly.
- [ ] **6.4 Replace chronicle fallback in `doets_countermodel_discrete`**: Replace lines 94-111 of Transfer.lean with:
  1. Extract chronicle: `let M := extract_chronicle_as_prior A h_mcs h_box_discrete`
  2. Build signature: `let sig := mkSigFrom phi`
  3. Build atomMap: `let atomMap := mkAtomMap sig phi`
  4. Prove chronicle is good: `have h_good := chronicle_is_good M sig atomMap (phi.complexity + 1)`
  5. Extract Z-model: `obtain <N, h_equiv> := h_good`
  6. Transfer truth via k-equivalence + table translation
  7. Package as `TaskFrame Int` / `TaskModel`
- [ ] **6.5 Verify axiom elimination**: Run `#print axioms doets_countermodel_discrete` and verify `succ_cofinal` does not appear. Run `#print axioms bx_completeness` (may still show `succ_cofinal` via other paths -- document any remaining paths).
- [ ] **6.6 Cleanup and documentation**: Add docstrings to new definitions. Update Transfer.lean module docstring. Run `lake build` on full project.

**Timing**: 3-5 hours

**Depends on**: 5 (needs `chronicle_is_good`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- rewrite proof of `doets_countermodel_discrete` (~80 lines), add `mkSigFrom`, `mkAtomMap` (~30 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` -- update `table` definition if needed for truth transfer

**Verification**:
- `lake build` passes with zero errors on full project
- `doets_countermodel_discrete` does not reference `succ_cofinal`
- `#print axioms doets_countermodel_discrete` shows clean axiom set
- Dense completeness path is unaffected
- External type signature of `doets_countermodel_discrete` unchanged

---

## Testing & Validation

- [ ] Phase 1: `lake build` passes; no duplicate ZStructure; KEquivalenceFramework has 5 fields; `good` allows Z-intervals
- [ ] Phase 2: `k_type_of`, `ktype_finite`, `k_equiv_monotone` all sorry-free
- [ ] Phase 3: `doets_lemma_1_4`, `finite_structures_k_equiv_to_Z_interval`, `finite_structures_good` all sorry-free
- [ ] Phase 4: `no_boundary_at_successor`, `contemp_equiv_is_equiv`, `no_gaps_discrete`, `one_class` all sorry-free
- [ ] Phase 5: `very_good_implies_good`, `chronicle_is_good` sorry-free; `#print axioms chronicle_is_good` shows no `succ_cofinal`
- [ ] Phase 6: `doets_countermodel_discrete` uses Reynolds pipeline; `#print axioms` clean; `lake build` passes on full project

## Artifacts & Outputs

- `specs/129_weak_reflexive_completeness_conservative_extension/plans/09_reynolds-theorem15-plan.md` (this file)
- `specs/129_weak_reflexive_completeness_conservative_extension/summaries/09_reynolds-theorem15-summary.md` (after Phase 6)
- Modified Lean files:
  - `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- FO satisfaction, KEquivalenceFramework fixes, MonadicSentence.lt, OrderedSum fix
  - `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- doets_lemma_1_4, finite_structures_k_equiv_to_Z_interval
  - `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- good fix, gap elimination chain, one_class, chronicle_is_good
  - `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- Reynolds pipeline wiring
  - `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` -- Formula.complexity fix, table_correctness fix

## Rollback/Contingency

- **If FO satisfaction is too complex for finite structures**: Fall back to the shallow-encoding approach but without `z_model_exists`. Keep `k_type_of` sorried but with correct type. The gap-elimination chain can still be proved assuming the `KEquivalenceFramework` properties (they are sound). The only cost is that sorries remain in `k_type_of` and `ktype_finite`.
- **If `doets_lemma_1_4` proof is too long**: Use the `KEquivalenceFramework.sum_preservation` axiom directly (it is a correct axiomatization of a known result). Close the instance later.
- **If Transfer.lean truth transfer is too complex**: Keep the chronicle fallback as an interim measure. The gap-elimination + one_class proofs are independently valuable and reduce the sorry count regardless.
- **Full rollback**: Revert all WeakCanonical files to their current git state. ChronicleExtraction.lean is unmodified by this plan.
