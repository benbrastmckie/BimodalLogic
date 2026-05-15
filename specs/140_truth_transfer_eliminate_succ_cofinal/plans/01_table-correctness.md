# Implementation Plan: Task #140 — Standard Translation and Table Correctness

- **Task**: 140 - truth_transfer_eliminate_succ_cofinal
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: 129 (COMPLETED), 139 (IMPLEMENTING)
- **Research Inputs**: specs/140_truth_transfer_eliminate_succ_cofinal/reports/01_team-research.md
- **Artifacts**: plans/01_table-correctness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Implement the Reynolds 1994 Section 6 standard translation (`table`) from temporal formulas to monadic first-order formulas, prove the quantifier depth bound (`table_depth_bound`), and state+prove `table_correctness` (the standard translation preserves truth). This task provides the semantic bridge connecting temporal truth to monadic FO truth. The full Reynolds pipeline activation and `succ_cofinal` elimination are deferred because they are blocked by `sum_preservation` (Doets Lemma 1.4 EF-game formalization, task 143+). The narrowed scope closes 2 existing sorries, adds 1 new theorem, and partially activates the Transfer.lean pipeline.

### Research Integration

Integrated from `reports/01_team-research.md` (4 teammates, all high confidence):
- Reynolds Section 6 translation table: case-by-case mapping from `Formula` constructors to `MonadicFormula` encodings, including the 2-quantifier Until/Since patterns.
- `operator_depth` bug: Until/Since add only 1 but need 2 (two quantifiers in the Reynolds translation). Fix confirmed by all 4 teammates.
- `MonadicFormula.weaken` infrastructure: De Bruijn index shifting function plus `weaken_eval` bridge lemma. Research provided pseudocode implementation and property statement.
- `box` handling: treat as atom via MCS labeling (box-subformulas mapped to predicate symbols). S5 box is not FO-expressible over linear time; the chronicle handles it via MCS membership.
- `mkSigFrom`/`mkAtomMap` placeholders: must be replaced with genuine atom extraction. `Formula.atoms` already exists in the codebase (Formula.lean:528-536).
- Scope narrowing: pipeline wiring and `succ_cofinal` elimination blocked by `chronicle_is_good` dependency chain.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Fix `operator_depth` for Until/Since to add 2 (matching Reynolds 2-quantifier translation)
- Define `MonadicFormula.weaken` (De Bruijn index shift) and prove `weaken_eval`
- Replace `mkSigFrom`/`mkAtomMap` placeholders with genuine atom+box-subformula extraction
- Implement `table` body following Reynolds 1994 Section 6, case by case
- Prove `table_depth_bound` (quantifier depth bounded by operator depth)
- State and prove `table_correctness` (standard translation preserves truth)
- Partially activate Transfer.lean pipeline steps that use `table`

**Non-Goals**:
- Full Reynolds pipeline activation (blocked by `sum_preservation`)
- Eliminating `succ_cofinal` from axiom set (blocked by pipeline activation)
- Proving `chronicle_is_good` or its dependency chain
- Bridging `ZIntervalStructure` to `TaskFrame Int` / `TaskModel` (separate follow-up)
- Proving `k_equiv_monotone` or `sum_preservation`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| De Bruijn index bookkeeping errors in Until/Since (3 variable levels) | H | M | Follow Reynolds exactly; test with `lean_goal` at each quantifier level; start with simpler cases (atom, bot, imp) |
| `weaken_eval` proof more complex than expected due to `Fin.cons` interactions | M | M | Research provided expected proof structure; use `Fin.cons` / `Fin.castSucc` lemmas from Mathlib |
| `table_correctness` statement design: unclear how `truth_at` bridges to `eval` | H | M | Research identified approximate form; design statement carefully in Phase 4 before attempting proof |
| `box` case in `table_correctness` requires MCS membership properties not yet available | M | H | Document as a sorry with clear blocker note; the `box` correctness case depends on chronicle properties |
| `Fin` arithmetic / coercion issues in Lean 4 for variable indices | M | M | Use `lean_goal` extensively; leverage `omega` for index arithmetic |

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

### Phase 1: Infrastructure — weaken, operator_depth fix, signature construction [NOT STARTED]

**Goal**: Build all prerequisite infrastructure needed by the `table` definition: the `weaken` function, `weaken_eval` lemma, corrected `operator_depth`, and genuine `mkSigFrom`/`mkAtomMap`.

**Tasks**:
- [ ] Fix `operator_depth` for Until/Since: change `+ 1` to `+ 2` at Table.lean:47-48
- [ ] Define `MonadicFormula.weaken` in NEquivalence.lean: structural recursion shifting all `Fin n` indices to `Fin (n + 1)` via `Fin.castSucc`
- [ ] Prove `weaken_eval`: `eval M (Fin.cons x env) (alpha.weaken) = eval M env alpha` by structural induction on `alpha`
- [ ] Define a `Formula.subformulas_box` or similar function to collect `box`-subformulas (needed for treating `box` as atom in the signature)
- [ ] Redesign `mkSigFrom` in Transfer.lean: use `Formula.atoms` union box-subformulas as predicate set; replace `Fin 1` placeholder
- [ ] Redesign `mkAtomMap` in Transfer.lean: map each predicate symbol back to the corresponding `Formula` (atom or box-subformula); replace `Formula.bot` placeholder
- [ ] Verify `lake build` passes with infrastructure changes

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` — fix `operator_depth` lines 47-48
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` — add `MonadicFormula.weaken` and `weaken_eval`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — redesign `mkSigFrom` and `mkAtomMap`
- `Theories/Bimodal/Syntax/Formula.lean` — add `subformulas_box` if needed (may use existing `atoms`)

**Verification**:
- `lake build` succeeds with no new errors
- `lean_goal` confirms `weaken` type-checks with correct signature
- `weaken_eval` proof closes without sorry

---

### Phase 2: Implement table body — Reynolds Section 6 translation [NOT STARTED]

**Goal**: Replace the `sorry` in `table` with the full case-by-case translation following Reynolds 1994 Section 6. The `table` function must accept an `atomMap` parameter and translate each `Formula` constructor to the corresponding `MonadicFormula sig 1`.

**Tasks**:
- [ ] Add `atomMap` parameter to `table` signature: `def table (sig : MonadicSignature) (atomMap : Formula -> sig.preds) (phi : Formula) : MonadicFormula sig 1`
- [ ] Implement `atom a` case: `MonadicFormula.atom (atomMap (Formula.atom a)) 0`
- [ ] Implement `bot` case: `MonadicFormula.lt 0 0` (t < t, always false)
- [ ] Implement `imp phi psi` case: `.not (.and (table sig atomMap phi) (.not (table sig atomMap psi)))` (material conditional encoding)
- [ ] Implement `box phi` case: `MonadicFormula.atom (atomMap (Formula.box phi)) 0` (treat as atom via MCS labeling)
- [ ] Implement `all_future phi` case: `.all (.not (.and (.lt (Fin 1) (Fin 0)) (.not (weaken (table sig atomMap phi)))))` (forall s, s > t implies C_phi(s))
- [ ] Implement `all_past phi` case: `.all (.not (.and (.lt (Fin 0) (Fin 1)) (.not (weaken (table sig atomMap phi)))))` (forall s, s < t implies C_phi(s))
- [ ] Implement `untl phi psi` case: 2-quantifier existential-universal pattern with 3 variable levels following Reynolds
- [ ] Implement `snce phi psi` case: symmetric to Until with reversed order direction
- [ ] Update all downstream references to `table` to pass `atomMap` (Table.lean, Transfer.lean)
- [ ] Verify `lake build` passes

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` — replace `table` body, update `table_depth_bound` signature
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — update references to `table` with `atomMap` argument

**Verification**:
- `table` definition compiles without sorry
- `lean_goal` at each case confirms correct `MonadicFormula sig 1` return type
- De Bruijn indices are consistent (variable 0 = current time `t`, variable 1 = quantified `s`, variable 2 = inner quantified `u` for Until/Since)

---

### Phase 3: Prove table_depth_bound [NOT STARTED]

**Goal**: Close the `table_depth_bound` sorry by structural induction on `phi`, using the corrected `operator_depth` (with +2 for Until/Since) and the `table` definition from Phase 2.

**Tasks**:
- [ ] Set up structural induction on `phi` for `table_depth_bound`
- [ ] Prove base cases: `atom` (quantifier_depth = 0, operator_depth = 0) and `bot` (quantifier_depth = 0)
- [ ] Prove `imp` case: max of recursive depths, no new quantifiers
- [ ] Prove `box` case: treated as atom, quantifier_depth = 0
- [ ] Prove `all_future` and `all_past` cases: one `all` quantifier adds 1 to depth; `weaken` does not add quantifiers; induction hypothesis gives bound on recursive `table` call
- [ ] Prove `untl` and `snce` cases: two quantifiers (`ex` + `all`) add 2 to depth; `weaken` applied twice does not add quantifiers; operator_depth adds 2 matching the quantifier count
- [ ] Clean up proof and verify `lake build` passes

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` — prove `table_depth_bound`

**Verification**:
- `table_depth_bound` proof closes without sorry
- `lake build` succeeds
- The bound is tight: Until/Since cases use the +2 from corrected `operator_depth`

---

### Phase 4: State and prove table_correctness [NOT STARTED]

**Goal**: Design the `table_correctness` theorem statement bridging `truth_at` (temporal semantics) to `eval` (monadic FO semantics), and prove it by structural induction on `phi` using `weaken_eval` from Phase 1.

**Tasks**:
- [ ] Design the theorem statement: relate `truth_at` (from `Theories/Bimodal/Semantics/Truth.lean`) to `eval` (from NEquivalence.lean) on a chronicle-as-monadic-structure. The statement needs: (a) a chronicle/model providing both temporal and monadic semantics, (b) an `atomMap` connecting predicates to formulas, (c) a coherence condition on the atom map (the interpretation of `atomMap p` at time `t` equals `truth_at ... t (atomMap p)`)
- [ ] Define the coherence condition as a structure or hypothesis: `atomMap_correct : forall p t, M_monadic.interp p t <-> truth_at M_temporal Omega tau t (atomMap_inv p)`
- [ ] Prove base cases: `atom` (directly from coherence condition) and `bot` (both sides are `False`)
- [ ] Prove `imp` case: unfold both sides, apply induction hypotheses
- [ ] Prove `box` case: from coherence condition on box-subformulas (may require sorry if MCS properties unavailable)
- [ ] Prove `all_future` and `all_past` cases: unfold `eval` with `.all` and `truth_at` with strict `<`; use `weaken_eval` to handle the shifted variable; match universal quantification on both sides
- [ ] Prove `untl` case: unfold both `eval` (with `.ex`, `.all`, 3 variable levels) and `truth_at` (with `exists s > t` and `forall r in (t,s)`); use `weaken_eval` at each quantifier level; the two-quantifier pattern should match Reynolds exactly
- [ ] Prove `snce` case: symmetric to `untl` with reversed order
- [ ] Mark `box` case with a sorry if the MCS coherence property is not yet available, with a clear blocker comment
- [ ] Verify `lake build` passes

**Timing**: 2.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` — add `table_correctness` theorem (or a new file if Table.lean grows too large)
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` — may need additional `eval` lemmas (e.g., `eval_not`, `eval_and` simplification lemmas)

**Verification**:
- `table_correctness` compiles with at most 1 sorry (the `box` case, if MCS properties unavailable)
- All temporal cases (`all_future`, `all_past`, `untl`, `snce`) close without sorry
- The theorem statement is usable by the Reynolds pipeline in Transfer.lean

---

### Phase 5: Partial pipeline activation and cleanup [NOT STARTED]

**Goal**: Wire the completed `table` and `table_correctness` into Transfer.lean's pipeline, filling in steps that now have implementations. Leave `chronicle_is_good` and downstream steps as sorry with explicit blocker annotations. Ensure the full codebase builds clean.

**Tasks**:
- [ ] Uncomment and fill Transfer.lean pipeline steps 1-2 (chronicle extraction, signature/atomMap construction) using the new `mkSigFrom`/`mkAtomMap`
- [ ] Uncomment and fill step 3 (chronicle is good) leaving as sorry with blocker comment: `-- BLOCKED: requires sum_preservation (Doets Lemma 1.4, task 143+)`
- [ ] Add `table_correctness` usage annotation in step 5 (truth transfer), showing how it would close the gap once `chronicle_is_good` is available
- [ ] Update docstrings in Table.lean to remove TODO markers for `table` and `table_depth_bound`; mark `table_correctness` as proved
- [ ] Update docstrings in Transfer.lean to reflect current pipeline status
- [ ] Run `lake build` on full project and fix any downstream breakage from signature changes (adding `atomMap` parameter may affect other files importing Table.lean)
- [ ] Verify no regressions in existing proofs

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — partial pipeline activation, docstring updates
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` — docstring cleanup
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` — may need `atomMap` parameter propagation

**Verification**:
- `lake build` succeeds with no new errors
- Sorry count: net reduction of 2 (table, table_depth_bound closed) plus 1 new theorem (table_correctness) proved; box case of table_correctness may have 1 sorry
- Transfer.lean pipeline comments accurately reflect what is proved vs. sorry'd

## Testing & Validation

- [ ] `lake build` succeeds on the full project after all phases
- [ ] `table` definition compiles and covers all 8 `Formula` constructors
- [ ] `table_depth_bound` proof closes without sorry
- [ ] `table_correctness` proof closes for all temporal cases (atom, bot, imp, all_future, all_past, untl, snce); box case documented if sorry'd
- [ ] `weaken_eval` proof closes without sorry
- [ ] No regressions in existing proofs (verify `lake build` on full project)
- [ ] `operator_depth` returns correct values: `untl (atom a) (atom b)` has depth 2, not 1
- [ ] De Bruijn index consistency: `table` produces well-typed `MonadicFormula sig 1` for all cases

## Artifacts & Outputs

- `specs/140_truth_transfer_eliminate_succ_cofinal/plans/01_table-correctness.md` (this plan)
- `specs/140_truth_transfer_eliminate_succ_cofinal/summaries/01_table-correctness-summary.md` (upon completion)
- Modified files: Table.lean, NEquivalence.lean, Transfer.lean, possibly Formula.lean and IntegerModel.lean

## Rollback/Contingency

All changes are in the `Theories/Bimodal/Metalogic/WeakCanonical/` directory. If the implementation fails:
- Revert Table.lean changes: restore original `operator_depth` (+1 for Until/Since) and sorry'd `table`/`table_depth_bound`
- Revert NEquivalence.lean changes: remove `weaken` and `weaken_eval` additions
- Revert Transfer.lean changes: restore placeholder `mkSigFrom`/`mkAtomMap`
- Git revert to the commit before implementation began

If only later phases fail:
- Phase 2 failure: keep Phase 1 infrastructure (weaken, operator_depth fix, signature) as independently valuable
- Phase 3 failure: keep `table` definition; re-sorry `table_depth_bound` with updated comment
- Phase 4 failure: keep `table` + `table_depth_bound` as the main deliverables; defer `table_correctness` to follow-up
- Phase 5 failure: keep all proofs; defer pipeline wiring to follow-up
