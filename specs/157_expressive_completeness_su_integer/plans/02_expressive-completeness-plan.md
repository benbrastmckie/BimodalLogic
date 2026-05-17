# Implementation Plan: Task #157 (v4) -- Full Axiom Elimination

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 28 hours
- **Dependencies**: Task 155 (completed phases provide infrastructure)
- **Research Inputs**: reports/01_expressive-completeness-proof.md, reports/02_case5-blocker-research.md, reports/03_implementation-audit.md, reports/04_axiom-elimination-strategies.md, reports/05_ghr94-ch10-deep-analysis.md, reports/06_alternative-separation-approaches.md, reports/07_purity-predicate-audit.md
- **Artifacts**: plans/02_expressive-completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is plan v4, a comprehensive revision integrating findings from four team research reports (04-07). The v3 plan identified 8 axioms and 1 sorry as targets but lacked a viable strategy for Case 5 and the purity predicate mismatch. The new research resolves both blockers: (1) Report 05 identifies a Case 3 reduction strategy for Case 5 following GHR94's Dedekind-complete proof (Lemma 10.3.11.5), making Case 5 provable rather than axiomatized; (2) Report 07 identifies a critical purity predicate mismatch where `is_U_free` permits `all_future` (GHR94 treats G as derived from U), which blocks Theorem 9.3.1 and corrupts Cases 2-4 outputs; (3) Reports 04/05 confirm Cases 6-8 reduce to Cases 1-5 via iterated elimination and the multi-U induction of Lemma 10.2.6; (4) Report 06 confirms no alternative approach is cost-effective (all require 2500-6200+ LOC of new infrastructure vs ~500 LOC to fix the current approach).

The plan implements the full GHR94 Lemma hierarchy (Levels 1-5) that v3 was missing: 8 elimination cases, single-U wrapper (10.2.5), multi-U induction (10.2.6), no-S-in-U (10.2.7), and junction-depth induction (10.2.8). The purity fix comes first since everything depends on correct predicate semantics.

Definition of done: `lake build` passes with zero axioms in Eliminations.lean and SeparationThm.lean, zero sorry in ExpressiveCompleteness.lean, and zero sorry in all Separation/ files (excluding DualEliminations.lean which is dead code).

### Research Integration

Seven research reports inform this plan:
- **Report 01** (1165 lines): Complete pseudo-Lean proof map covering all GHR94 lemmas 10.2.1-10.2.8 and Theorem 9.3.1.
- **Report 02** (769 lines): Confirms GHR94 Case 5 formula is wrong for integer time. Counterexample documented.
- **Report 03** (429 lines): Complete implementation audit. Inventories all sorries with exact goal states.
- **Report 04** (660 lines): Analyzes 5 elimination strategies. Confirms iterated single-U elimination is viable for Cases 6-8. Shows Cases 6-8 all ultimately depend on Case 5.
- **Report 05** (503 lines): Deep analysis of GHR94 Ch 10. Identifies Case 3 reduction strategy for Case 5 from the Dedekind-complete proof. Confirms the 5-level lemma hierarchy needed. Documents the purity mismatch.
- **Report 06** (361 lines): Surveys all alternative approaches (EF games, Reynolds, Venema, BAO, automata). All cost 2500-6200+ LOC. Confirms GHR94 Ch 10 syntactic approach is optimal.
- **Report 07** (640 lines): Detailed purity predicate audit. Documents exact mismatch between `is_U_free` and GHR94's definition. Recommends Option D: new `is_future_only`/`is_past_only`/`is_properly_separated` predicates. Shows Cases 2-4 output formulas need adjustment.

### reports_integrated

- 04_axiom-elimination-strategies.md
- 05_ghr94-ch10-deep-analysis.md
- 06_alternative-separation-approaches.md
- 07_purity-predicate-audit.md

### Lessons from v3 and Prior Implementation Attempts

Five critical lessons shape this plan:

1. **Purity predicates are wrong** (Report 07): `is_U_free` permits `all_future`, but GHR94 treats G = neg U(neg phi, top) as containing U. This means our `is_syntactically_separated` is weaker than GHR94's definition. Cases 2-4 produce output formulas with `all_future(neg A)` inside `snce` arguments, which is NOT separated in GHR94's sense. Theorem 9.3.1 REQUIRES semantic purity (pure-past parts must not look at the future), which the weak predicate cannot guarantee.

2. **Case 5 IS solvable** (Report 05): The Dedekind-complete proof (Lemma 10.3.11.5) shows: apply Case 3 treating `a ^ U(A,B)` as the event parameter, producing a result with U in structurally simpler positions. After expanding `neg U(A,B)` via `neg_until_equiv` and distributing, each disjunct has at most one U under S, handleable by Cases 1-4. This generalizes to Z.

3. **Cases 6-8 reduce to Cases 1-5** (Reports 04, 05): GHR94's Lemma 10.2.6 handles multiple U-formulas by induction on the count of distinct U-subformulas. The two-U problem from `neg_until_equiv` is handled naturally: treat one U as an atom, eliminate the other, substitute back, re-separate. All three cases ultimately depend on Case 5.

4. **The full lemma hierarchy is needed** (Report 05): The correct architecture is 5 levels: (1) 8 elimination cases (Lemma 10.2.3), (2) single-U-under-S wrapper (Lemma 10.2.5), (3) multi-U induction (Lemma 10.2.6), (4) no-S-in-U (Lemma 10.2.7), (5) junction-depth induction (Lemma 10.2.8). The v3 plan jumped from level 1 to level 5.

5. **Phase 1 (Theorem 9.3.1) is blocked by the purity issue** (Report 07): The substitution step requires that "past" parts of a separated formula evaluate ONLY at times <= t, and "future" parts ONLY at times >= t. With `all_future` permitted inside `snce` arguments, this semantic guarantee fails. The purity fix unblocks Phase 1.

### Codebase State at Time of Revision

- `lake build` passes with 0 errors
- 4 axioms in `Eliminations.lean`: `elim_case_5_axiom`, `elim_case_6_axiom`, `elim_case_7_axiom`, `elim_case_8_axiom`
- 4 axioms in `SeparationThm.lean`: `all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`
- 1 sorry in `ExpressiveCompleteness.lean`: `separation_implies_expressiveness`
- 8 sorries in `DualEliminations.lean` (dead code, not on critical path)
- Cases 1-4 proved but Cases 2-4 output formulas use `all_future`/`all_past` inside S/U arguments (incorrect under strict purity)
- Phase 1 infrastructure built but uncommitted: ExtPred, extSignature, reduce, reduce_correct, extStructure, inst, helper lemmas

## Goals & Non-Goals

**Goals**:
- Fix purity predicates to correctly model GHR94's semantic separation (no future operators under S, no past operators under U)
- Adjust Cases 2-4 output formulas to satisfy the corrected purity predicates
- Prove Case 5 via the Case 3 reduction strategy from GHR94's Dedekind-complete proof
- Prove Cases 6-8 via iterated single-U elimination reducing to Cases 1-5
- Implement Lemmas 10.2.5-10.2.7 (single-U wrapper, multi-U induction, no-S-in-U)
- Prove `all_separable` via junction-depth induction (Lemma 10.2.8), replacing 4 temporal closure axioms
- Complete Theorem 9.3.1 (`separation_implies_expressiveness`) using proper semantic purity
- Achieve zero-axiom, zero-sorry `lake build` for all Separation/ files + ExpressiveCompleteness.lean

**Non-Goals**:
- Proving DualEliminations.lean (8 sorries -- dead code, not on critical path)
- Implementing alternative proof approaches (Reynolds, EF games, BAO)
- Extending to dense or continuous time flows
- Optimizing proof terms for performance

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Purity predicate change cascades through many proofs beyond Cases 2-4 | H | M | Use Option D from Report 07: define NEW predicates (`is_future_only`, `is_past_only`, `is_properly_separated`) alongside existing ones. Migrate incrementally. Old predicates remain for any intermediate steps that need them. |
| Cases 2-4 output formula rewrite is more complex than estimated | M | M | Report 07 identifies the exact formulas. GHR94 Case 2 formula avoids G inside S entirely. If rewrite proves difficult, use the bridge lemma approach (Report 07 alternative): prove `is_syntactically_separated -> exists properly_separated equiv`. Estimated ~200 LOC. |
| Case 5 reduction via Case 3 fails because Case 3 preconditions require `is_U_free a = true` but `a ^ U(A,B)` is not U-free | H | M | Report 05 Section 7.2 addresses this: either generalize Case 3 to allow U in the event parameter (the semantic proof is identical), or apply Case 3's semantic equivalence directly without going through the typed theorem. The semantic argument only requires the event's non-U part to be U-free. |
| Junction-depth induction measure does not strictly decrease through the elimination process | M | L | Report 04 Section 8.3 provides a fallback: prove the 4 temporal closure axioms individually using the substitution bridge. Each step is straightforward once the elimination cases are available. |
| Theorem 9.3.1 quantifier case requires more infrastructure than budgeted | M | M | The infrastructure (ExtPred, reduce, reduce_correct) is already built. With proper purity predicates, the substitution step becomes feasible. If still blocked, prove for n=1 with the general case as a documented extension point. |
| Re-separation after atom substitution in Cases 6-8 requires the full `all_separable` (circular dependency) | H | L | The re-separation only needs single-U elimination (Cases 1-5), not the full hierarchy. Structure the proof to invoke Cases 1-5 directly, avoiding circular dependency with `all_separable`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 1, 5 |
| 7 | 7 | 5, 6 |

Phases are sequential because each builds on the prior phase's infrastructure.

---

### Phase 1: Fix Purity Predicates and Adjust Cases 2-4 [NOT STARTED]

**Goal**: Define correct purity predicates matching GHR94's semantic separation, update `is_syntactically_separated` to use them, and adjust the output formulas of Cases 2-4 so they satisfy the strengthened predicate. This phase is the prerequisite for all subsequent work.

**Strategy (Option D from Report 07)**:

1. Define new predicates in Defs.lean:
   - `is_future_only`: no `all_past`, no `snce` (permits `all_future`, `untl`, atoms, boolean)
   - `is_past_only`: no `all_future`, no `untl` (permits `all_past`, `snce`, atoms, boolean)
   - `is_properly_separated`: uses `is_future_only`/`is_past_only` instead of `is_U_free`/`is_S_free`
   - `is_properly_separable`: exists properly_separated equivalent

2. Prove basic properties:
   - `is_future_only` and `is_past_only` are closed under boolean connectives
   - Duality: `is_future_only(swap phi) = is_past_only(phi)` and vice versa
   - `is_properly_separated(swap phi) = is_properly_separated(phi)` (via duality)

3. Adjust Cases 2-4 output formulas:
   - **Case 2**: Currently produces `snce(and a (all_future(neg A))) q`. GHR94's actual Case 2 formula (from the literature) avoids G inside S: `[S(a, q ^ not A) ^ not A ^ not U(A,B)] v [not A ^ not B ^ S(a, not A ^ q)] v S(not A ^ not B ^ q ^ S(a, not A ^ q), q)`. Rewrite the proof to produce this formula (or the bridge lemma approach).
   - **Case 3**: Symmetric adjustment for `all_past(neg a)` inside `untl` arguments.
   - **Case 4**: Symmetric adjustment.
   - **Case 1**: No change needed (output contains no `all_future`/`all_past`).

4. Alternatively (if Case 2-4 rewrite is too complex): Prove a bridge lemma showing that every weakly-separated formula can be converted to a properly-separated equivalent by replacing `all_future(phi)` with the semantically equivalent `neg(untl(neg phi)(bot)).neg` encoding in problematic positions. This avoids touching the Case 2-4 proofs. Estimated ~200 LOC.

5. Update `is_separable` references throughout:
   - If using new predicates directly: update all_separable's conclusion to use `is_properly_separable`
   - If using bridge lemma: keep `is_separable` and add a separate `all_properly_separable` that composes `all_separable` with the bridge

**Tasks**:
- [ ] **Task 1.1**: Define `is_future_only`, `is_past_only`, `is_properly_separated`, `is_properly_separable` in Defs.lean (~30 LOC)
- [ ] **Task 1.2**: Prove closure and duality properties for new predicates (~80 LOC)
- [ ] **Task 1.3**: Decide between Case 2-4 rewrite vs bridge lemma approach (investigate GHR94's exact formulas, estimate effort)
- [ ] **Task 1.4**: Implement the chosen approach for Cases 2-4 purity compliance (~200-500 LOC depending on approach)
- [ ] **Task 1.5**: Update separation predicate usage in SeparationThm.lean and ExpressiveCompleteness.lean to reference the proper purity notion
- [ ] **Task 1.6**: Verify `lake build` passes with updated predicates, all existing proofs compile

**Timing**: 5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` -- add new predicates (~30 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Duality.lean` -- add duality lemmas for new predicates (~50 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- adjust Cases 2-4 output formulas or add bridge lemma (~200-500 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- update axiom types
- Possibly new helper file for the bridge lemma

**Verification**:
- `lake build` passes with 0 errors
- New predicates correctly reject `snce(all_future(p))(q)` as not properly separated
- New predicates correctly accept `all_future(neg A)` as future-only at top level of separated formula
- Cases 1-4 all produce `is_properly_separated` outputs (either directly or via bridge)

---

### Phase 2: Prove Case 5 via Case 3 Reduction [NOT STARTED]

**Goal**: Replace `elim_case_5_axiom` with a genuine proof using the reduction strategy from GHR94's Dedekind-complete proof (Lemma 10.3.11.5), as identified by Report 05.

**Strategy**: Apply Case 3's semantic equivalence to `S(a ^ U(A,B), q v U(A,B))` by treating `a' = a ^ U(A,B)` as the event parameter. The result still contains U(A,B) in positions derived from `neg a'`, but after expanding via `neg_until_equiv` and distributing, each disjunct has at most one U under S, handleable by Cases 1-4.

**Detailed Steps**:

1. **Generalize Case 3 or use direct semantic argument**: Case 3's theorem requires `is_U_free a = true`, but `a ^ U(A,B)` is not U-free. Two options:
   - (a) Prove a generalized Case 3 that relaxes the U-free precondition on the event to allow the specific `U(A,B)` that also appears in the guard. The semantic proof is identical.
   - (b) Re-derive Case 3's semantic equivalence directly for the specific `a' = a ^ U(A,B)` case, without going through the typed theorem.

2. **Apply the Case 3 equivalence**: `S(a ^ U(A,B), q v U(A,B))` is equivalent to the Case 3 formula with `a' = a ^ U(A,B)`.

3. **Simplify the result**: The Case 3 output contains `neg(a ^ U(A,B))` = `neg a v neg U(A,B)` in various positions under S. Expand `neg U(A,B)` via `neg_until_equiv` to get `G(neg A) v U(neg A ^ neg B, neg A)`.

4. **Distribute and case-split**: After distributing disjunctions, each resulting S-formula has at most one U-formula (either U(A,B) from the original, or U(neg A ^ neg B, neg A) from the negation), but NOT both simultaneously under the same S. These are all Cases 1-4 patterns.

5. **Apply Cases 1-4**: Each disjunct falls into one of the proved Cases 1-4, producing a properly separated result.

6. **Combine via `or_separable`**: The final result is a disjunction of separated formulas.

**Tasks**:
- [ ] **Task 2.1**: Establish the generalized Case 3 equivalence (or direct semantic argument) for `a' = a ^ U(A,B)` (~150-250 LOC)
- [ ] **Task 2.2**: Prove the `neg(a ^ U(A,B))` expansion and distribution lemmas (~80 LOC)
- [ ] **Task 2.3**: Show each resulting disjunct matches a Case 1-4 pattern and apply the corresponding theorem (~150-200 LOC)
- [ ] **Task 2.4**: Assemble the full Case 5 proof combining all disjuncts (~50 LOC)
- [ ] **Task 2.5**: Replace `elim_case_5_axiom` with the proved `elim_case_5` theorem
- [ ] **Task 2.6**: Verify `lake build` passes with Case 5 axiom replaced by proof

**Timing**: 4 hours

**Depends on**: 1 (purity predicates must be correct for the output formula to satisfy the separation check)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- replace axiom with proof (~400-600 LOC net)
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/Separation/IntHelpers.lean` -- additional semantic lemmas

**Verification**:
- `lake build` passes
- `grep -rn "axiom elim_case_5" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` returns empty
- Case 5 theorem compiles with the same type signature as the former axiom

---

### Phase 3: Prove Cases 6-8 via Iterated Elimination [NOT STARTED]

**Goal**: Replace the 3 axioms (`elim_case_6_axiom`, `elim_case_7_axiom`, `elim_case_8_axiom`) with genuine proofs using iterated single-U elimination reducing to Cases 1-5, as confirmed by Reports 04 and 05.

**Strategy**: Each case applies `neg_until_equiv` to expand `neg U(A,B)`, distributes via `since_distrib_or_left`, then handles each disjunct by applying the appropriate earlier case. The two-U disjuncts are resolved by treating one U as a fresh atom, applying a Case 1-4 to eliminate the other, substituting back, and re-separating via Cases 1-5.

**Concrete reductions** (from Report 04 Section 1.7 and Report 05 Section 4):

**Case 8** (simplest, do first):
- `S(a ^ neg U(A,B), q v neg U(A,B))`
- Use GHR94's explicit negation reduction (Lemma 10.2.3.8): negate the formula, apply `neg_since_equiv` with `y = z = neg U(A,B)`, yielding `H(neg a v U(A,B)) v S(neg q ^ U(A,B) ^ neg a, neg a v U(A,B))`.
- The second S-formula has U(A,B) in both event and guard: this is Case 5 (with primed parameters).
- The H-term has U under H (= under S in the hierarchy): handle by Case 1 or the hierarchy.
- Result: `D <-> neg [Case_5_result v Case_1_result]`, which is separated.
- **Depends on**: Cases 3, 5.

**Case 6**:
- `S(a ^ neg U(A,B), q v U(A,B))`
- Expand `neg U(A,B)` in event: `a ^ [G(neg A) v U(A', B')]` where `A' = neg A ^ neg B`, `B' = neg A`
- Distribute: `S(a ^ G(neg A), q v U(A,B))` v `S(a ^ U(A',B'), q v U(A,B))`
- Disjunct 1: Case 3 (event U-free, guard has single U). Directly apply `elim_case_3`.
- Disjunct 2: Two U-formulas. Substitute `p := U(A,B)` to get `S(a ^ U(A',B'), q v p)`. This is Case 1 with atom p. Apply Case 1, substitute back, re-separate via Cases 1-5.
- **Depends on**: Cases 1, 3, 5.

**Case 7**:
- `S(a ^ U(A,B), q v neg U(A,B))`
- Expand `neg U(A,B)` in guard: `q v G(neg A) v U(A',B')`
- Substitute `p := U(A,B)` in event: `S(a ^ p, (q v G(neg A)) v U(A',B'))`. Event `a ^ p` is U-free. Guard has single U(A',B'). This is Case 3 with atom p.
- Apply Case 3, substitute back, re-separate via Cases 1-5.
- **Depends on**: Cases 1-5.

**Tasks**:
- [ ] **Task 3.1**: Implement Case 8 proof via negation reduction to Cases 3 + 5 (~100-200 LOC)
- [ ] **Task 3.2**: Implement Case 6 proof via event expansion, distribution, Case 3 + iterated Case 1 + re-separation (~200-300 LOC)
- [ ] **Task 3.3**: Implement Case 7 proof via guard expansion, fresh-atom substitution, Case 3 + re-separation (~200-300 LOC)
- [ ] **Task 3.4**: Make necessary private helpers public in Eliminations.lean (or_separable, is_separable_of_equiv, etc.)
- [ ] **Task 3.5**: Add missing infrastructure lemmas: `neg_U_free`, `and_U_free`, `or_U_free`, `all_future_U_free`, `since_distrib_event_or`, `or_equiv_congr` (~50-80 LOC)
- [ ] **Task 3.6**: Remove all 3 axiom declarations, verify `lake build` passes with 0 axioms in Eliminations.lean

**Timing**: 5 hours

**Depends on**: 2 (Case 5 must be proved since Cases 6-8 all depend on it)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- replace 3 axioms with proofs (~500-800 LOC net)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` -- possibly add substitution helpers

**Verification**:
- `lake build` passes
- `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` returns empty
- All 8 elimination cases are theorems with proofs

---

### Phase 4: Implement Lemmas 10.2.5-10.2.7 (Hierarchy Levels 2-4) [NOT STARTED]

**Goal**: Build the intermediate hierarchy levels between the 8 elimination cases (Level 1) and the full junction-depth induction (Level 5). These are:
- **Lemma 10.2.5** (single-U-under-S): Given a formula with a single U(A,B) subformula where A, B are S-free, produce a separated equivalent. Uses normal form reduction to the 8 cases.
- **Lemma 10.2.6** (multi-U induction): Given a formula with n distinct U-subformulas (all with S-free arguments) under S, produce a separated equivalent by induction on n. Replace n-1 U-subformulas by fresh atoms, apply Lemma 10.2.5 for the remaining one, substitute back, re-separate.
- **Lemma 10.2.7** (no-S-in-U): Given a formula where no S appears inside U-arguments (but U may appear inside S-arguments), produce a separated equivalent. Identify maximal U-subformulas, apply Lemma 10.2.6, compose results.

**Strategy**:

For **Lemma 10.2.5**: The formula has the form `S(C, F)` with a single U(A,B) in C or F (or both). Use Lemma 10.2.1 (distribution) to reduce to normal form: `S(c_j ^ U(A,B)^ej, q_k v U(A,B)^fk)` where `e_j, f_k in {0, 1}`. Each such S-formula falls into one of the 8 cases. The result is a boolean combination of separated formulas.

For **Lemma 10.2.6**: Induction on the number n of distinct U-subformula types.
- Base case n=0: formula is already U-free under S (hence separated).
- Base case n=1: apply Lemma 10.2.5.
- Inductive step: pick any U_i, replace all other U_j (j != i) by fresh atoms p_j. Apply Lemma 10.2.5 for U_i. The result is separated but contains atoms p_j. Substitute p_j := U_j back. The result has fewer distinct U-types under each S (because U_i has been eliminated). Apply the induction hypothesis.

For **Lemma 10.2.7**: The formula has no S inside U-arguments. Identify the set of maximal U-subformulas `{U(A_1,B_1), ..., U(A_n,B_n)}` whose arguments are S-free (guaranteed by the "no S in U" precondition). Replace each by a fresh atom. The resulting formula has no U at all, so it's U-free. If it also has no problematic S-nesting, it's separated. If it has S, apply the temporal closure argument. After substitution back, apply Lemma 10.2.6.

**Tasks**:
- [ ] **Task 4.1**: Define `count_U_subformulas_under_S` as a computable measure for Lemma 10.2.6 induction (~30 LOC)
- [ ] **Task 4.2**: Define `has_S_in_U` predicate for Lemma 10.2.7's precondition (~20 LOC)
- [ ] **Task 4.3**: Implement the normal form reduction for Lemma 10.2.5: distribute S over boolean combinations to extract U(A,B) position (~150-200 LOC)
- [ ] **Task 4.4**: Prove Lemma 10.2.5 (single-U-under-S) using normal form + 8 cases (~100-150 LOC)
- [ ] **Task 4.5**: Prove Lemma 10.2.6 (multi-U induction on n) using fresh-atom substitution + Lemma 10.2.5 + induction (~200-300 LOC)
- [ ] **Task 4.6**: Prove Lemma 10.2.7 (no-S-in-U) using maximal U-subformula extraction + Lemma 10.2.6 (~150-200 LOC)
- [ ] **Task 4.7**: Verify `lake build` passes, all new lemmas compile

**Timing**: 5 hours

**Depends on**: 3 (all 8 elimination cases must be proved theorems)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Helpers.lean` -- new file for hierarchy infrastructure (~200 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- add Lemmas 10.2.5-10.2.7 (~400-600 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` -- multi-substitution, U-subformula extraction

**Verification**:
- `lake build` passes
- `Lemma_10_2_5`, `Lemma_10_2_6`, `Lemma_10_2_7` (or equivalent named theorems) compile without sorry

---

### Phase 5: Prove all_separable via Junction-Depth Induction (Lemma 10.2.8) [NOT STARTED]

**Goal**: Replace the 4 temporal closure axioms (`all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`) with a single well-founded induction proof on junction depth, implementing GHR94's Lemma 10.2.8.

**Strategy**:

1. **Define `junction_depth`**: A computable function measuring the maximum nesting depth of U-within-S or S-within-U alternation. Junction depth 0 means no U/S alternation (already separated or trivially separable). Junction depth k+1 means at least one U-under-S or S-under-U at depth k+1.

2. **Prove `all_separable` by well-founded induction on `junction_depth`**:
   - Base case (junction_depth = 0): The formula has no U/S alternation. It is either a boolean combination of atoms, or contains only U (S-free) or only S (U-free), or has `all_future`/`all_past` of appropriately pure arguments. Show it is properly separated.
   - Inductive step (junction_depth = k+1): The formula has some U under S (or S under U).
     - For `snce phi psi` where phi or psi contains U: Extract maximal U-subformulas (whose arguments are S-free by the structure). Replace by fresh atoms. Apply Lemma 10.2.7 to the simplified formula (which has no S in U). Substitute back. The result has strictly lower junction depth (the extracted U-under-S has been eliminated). Apply IH.
     - For `untl phi psi` where phi or psi contains S: Dual of above.
     - For `all_past phi` where phi contains U: Similar extraction and re-separation.
     - For `all_future phi` where phi contains S: Dual.
   - Boolean cases propagate separation through `imp`.

3. **Remove the 4 temporal closure axioms**: The `all_separable` proof by junction-depth induction subsumes them entirely.

**Tasks**:
- [ ] **Task 5.1**: Define `junction_depth : Formula -> Nat` as a computable function (~40-60 LOC)
- [ ] **Task 5.2**: Prove `junction_depth` strictly decreases through the extraction-substitution-re-separation process (~100-150 LOC)
- [ ] **Task 5.3**: Prove the base case: junction_depth 0 implies properly separable (~50-80 LOC)
- [ ] **Task 5.4**: Prove the inductive step for S-cases (`snce`, `all_past`): extract maximal U, apply Lemma 10.2.7, substitute, invoke IH (~150-200 LOC)
- [ ] **Task 5.5**: Prove the inductive step for U-cases (`untl`, `all_future`): dual of S-cases (~100-150 LOC)
- [ ] **Task 5.6**: Assemble `all_separable` using Nat.strongRecOn on junction_depth (~50 LOC)
- [ ] **Task 5.7**: Remove the 4 temporal closure axioms from SeparationThm.lean
- [ ] **Task 5.8**: Verify `lake build` passes with 0 axioms in SeparationThm.lean

**Timing**: 4 hours

**Depends on**: 4 (Lemmas 10.2.5-10.2.7 must be proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace axioms + structural induction with junction-depth induction (~400-600 LOC net change)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` -- add `junction_depth` definition

**Verification**:
- `lake build` passes
- `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` returns empty
- `all_separable` compiles with no sorry and no axioms in its transitive dependency chain (except Lean/Mathlib axioms)

---

### Phase 6: Complete Theorem 9.3.1 (separation_implies_expressiveness) [NOT STARTED]

**Goal**: Close the 1 sorry in `ExpressiveCompleteness.lean` by proving that separation implies expressive completeness, using the properly-separated formulas that guarantee semantic purity.

**Strategy**: With the purity predicates fixed (Phase 1), the blocked Task 1.4 from v3 becomes unblocked. The substitution step now works because `is_properly_separated` guarantees that S-arguments are `is_past_only` (no future operators), so the R-atom substitution is correct in each temporal region.

**Infrastructure already built** (from v3 Phase 1 investigation):
- `ExtPred`, `extSignature`: Extended signature with auxiliary predicates (orig, frozen, r_eq, r_gt, r_lt)
- `reduce`: MonadicFormula sig (n+1) -> MonadicFormula extSig n
- `extStructure`: Extended IntStructureFromSig with correct aux predicate interpretations
- `reduce_correct`: Semantic correctness of reduce (fully proved)
- `reduce_preserves_depth`: Depth preservation of reduce (fully proved)
- Helper lemmas: `int_truth_neg`, `int_truth_and`, `int_truth_atom_inj`, etc.

**Remaining work**:
1. Commit the infrastructure built during v3 Phase 1 investigation (currently tested via lean_run_code but not in files)
2. With proper purity (`is_properly_separated`), prove the R-atom substitution correctness:
   - In `is_past_only` subformulas: r_> can be set to False (past doesn't look at future)
   - In `is_future_only` subformulas: r_< can be set to False (future doesn't look at past)
   - In present subformulas: r_= can be set based on the current point
3. Prove the quantifier case: `ex alpha` where `alpha : MonadicFormula sig (n+1)`. Apply reduce, get MonadicFormula extSig n, apply IH to get temporal formula B, form q_exists(B), separate it, substitute R-atoms.
4. Specialize back to n=1 and prove `separation_implies_expressiveness`.

**Tasks**:
- [ ] **Task 6.1**: Commit and integrate the v3 Phase 1 infrastructure (ExtPred, reduce, reduce_correct, etc.) into ExpressiveCompleteness.lean (~100-200 LOC of file integration)
- [ ] **Task 6.2**: Prove `is_past_only_pure_past`: if `is_past_only phi = true`, then `int_truth M t phi` depends only on the structure at times <= t (~80-120 LOC)
- [ ] **Task 6.3**: Prove `is_future_only_pure_future`: dual property (~80-120 LOC)
- [ ] **Task 6.4**: Prove R-atom substitution correctness using the purity lemmas (~150-200 LOC)
- [ ] **Task 6.5**: Prove the quantifier case using reduce + IH + q_exists + separation + R-atom substitution (~200-300 LOC)
- [ ] **Task 6.6**: Specialize to n=1 and close `separation_implies_expressiveness` (~30-50 LOC)
- [ ] **Task 6.7**: Verify `lake build` passes with 0 sorry in ExpressiveCompleteness.lean

**Timing**: 3 hours

**Depends on**: 1 (purity predicates), 5 (all_separable with proper predicates)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- complete the proof (~500-800 LOC)
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` -- extend with n-variable infrastructure if needed

**Verification**:
- `lake build` passes
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- `US_expressively_complete_over_Z` compiles with no sorry in dependency chain

---

### Phase 7: Integration and Final Verification [NOT STARTED]

**Goal**: Verify the complete proof chain from elimination cases through separation theorem to expressive completeness, with zero axioms and zero sorry in the critical path. Clean up documentation and dead code.

**Tasks**:
- [ ] **Task 7.1**: Run `lake build` and verify 0 errors
- [ ] **Task 7.2**: Run `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- must return empty
- [ ] **Task 7.3**: Run `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- must return empty
- [ ] **Task 7.4**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- must return empty
- [ ] **Task 7.5**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` -- only DualEliminations.lean acceptable
- [ ] **Task 7.6**: Verify the proof chain: `US_expressively_complete_over_Z` -> `separation_implies_expressiveness` -> `separation_theorem_int` -> `all_separable` -> elimination cases 1-8 (all proved)
- [ ] **Task 7.7**: Update module docstrings documenting the complete proof structure and the deviation from GHR94 (purity predicate adaptation, Case 5 reduction strategy)
- [ ] **Task 7.8**: Document the GHR94 lemma hierarchy mapping in code comments: which Lean theorem corresponds to which GHR94 lemma

**Timing**: 2 hours

**Depends on**: 5 (all_separable proved), 6 (Theorem 9.3.1 proved)

**Files to modify**:
- Various files -- docstring updates only
- No logic changes expected

**Verification**:
- All checks from Tasks 7.1-7.6 pass
- `US_expressively_complete_over_Z` compiles with no sorry, no axiom in its transitive dependencies (except Lean/Mathlib axioms)

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after all phases
- [ ] `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` returns empty
- [ ] `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns only DualEliminations.lean entries
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- [ ] No regressions in existing `Theories/Bimodal/` code
- [ ] `separation_theorem_int` has type `(phi : Formula) -> is_separable phi` with no axioms in dependency chain
- [ ] `US_expressively_complete_over_Z` type-checks as composition of Theorem 9.3.1 + separation theorem
- [ ] New `is_properly_separated` predicate correctly rejects G-under-S and H-under-U patterns
- [ ] New `is_future_only` / `is_past_only` predicates match GHR94's semantic purity requirements

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/02_expressive-completeness-plan.md` (this file, v4)
- `specs/157_expressive_completeness_su_integer/reports/04_axiom-elimination-strategies.md` (integrated)
- `specs/157_expressive_completeness_su_integer/reports/05_ghr94-ch10-deep-analysis.md` (integrated)
- `specs/157_expressive_completeness_su_integer/reports/06_alternative-separation-approaches.md` (integrated)
- `specs/157_expressive_completeness_su_integer/reports/07_purity-predicate-audit.md` (integrated)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` (new predicates + junction_depth)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Duality.lean` (new duality lemmas)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (8 axioms -> 8 theorems)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (4 axioms -> junction-depth induction + hierarchy)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` (sorry -> proof)
- New: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Helpers.lean` (hierarchy infrastructure)

## Rollback/Contingency

- **Phase 1 fallback (bridge lemma)**: If rewriting Cases 2-4 output formulas is too costly, use the bridge lemma approach (~200 LOC) that converts weakly-separated to properly-separated post-hoc. This avoids touching the existing Case 2-4 proofs.

- **Phase 2 fallback (Case 5 axiom)**: If the Case 3 reduction strategy fails for Case 5 on Z (e.g., the generalized Case 3 preconditions cannot be satisfied), retain the Case 5 axiom. The axiom is mathematically sound. Cases 6-8 can still be proved via iterated elimination with the axiom. Final axiom count: 1 instead of 0.

- **Phase 3 fallback (individual axioms)**: If any of Cases 6-8 proves intractable, its axiom can remain independently. Each axiom is mathematically sound and does not affect the others.

- **Phase 4-5 fallback (temporal closure axioms)**: If the full hierarchy (Lemmas 10.2.5-10.2.7) or junction-depth induction proves too complex, retain the 4 temporal closure axioms. They are a clean abstraction boundary. The build still passes. Final axiom count: 4 (temporal closure) + 0-1 (Case 5) = 4-5 instead of 0.

- **Phase 6 fallback (Theorem 9.3.1 sorry)**: If the quantifier case remains intractable even with proper purity, the sorry in ExpressiveCompleteness.lean can remain with full documentation. The separation theorem itself (the harder part) would still be fully proved.

- **Priority ordering if time-constrained**: Phase 1 (purity fix) > Phase 2 (Case 5) > Phase 3 (Cases 6-8) > Phase 4 (hierarchy) > Phase 5 (junction-depth) > Phase 6 (Theorem 9.3.1) > Phase 7 (integration). Each phase delivers incremental value.

- **Git safety**: All axioms remain in the codebase until their replacement proofs compile. The replacement is done by changing `axiom` to `theorem` and providing a proof body. If a phase fails, the axiom version is preserved in git history.
