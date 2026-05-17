# Implementation Plan: Task #157 (v3) -- Axiom Elimination

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [IN PROGRESS]
- **Effort**: 20 hours
- **Dependencies**: Task 155 (completed phases provide infrastructure)
- **Research Inputs**: reports/01_expressive-completeness-proof.md, reports/02_case5-blocker-research.md, reports/03_implementation-audit.md
- **Artifacts**: plans/02_expressive-completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is plan v3 (revision of v2). The v2 plan's 4 phases were attempted by implementation agents. Phase 1 (Theorem 9.3.1) is still in progress with a separate agent. Phases 2-4 encountered fundamental mathematical blockers and fell back to axiom-based closures. The build passes with 0 errors, but 8 axioms in Eliminations.lean and SeparationThm.lean replace what should be proofs, plus 1 sorry remains in ExpressiveCompleteness.lean.

This plan targets **axiom elimination**: replacing the 8 axioms and 1 sorry with genuine proofs. The primary blockers are (1) GHR94's Case 5 formula is incorrect on integer time and no published correction exists, (2) Cases 6-8 reductions via neg_until_equiv introduce two distinct U-formulas that GHR94's single-U framework cannot handle, (3) the temporal closure axioms in SeparationThm.lean depend on the elimination axioms, and (4) Theorem 9.3.1 requires n-variable FO generalization. Each phase addresses a specific blocker with a new strategy informed by the failure analysis.

Definition of done: `lake build` passes with zero axioms in Eliminations.lean and SeparationThm.lean, zero sorry in ExpressiveCompleteness.lean, and zero sorry in all Separation/ files (excluding DualEliminations.lean which is dead code).

### Research Integration

Three research reports from v2 inform this plan:
- **Report 01** (1165 lines): Complete pseudo-Lean proof map covering all GHR94 lemmas 10.2.1-10.2.8 and Theorem 9.3.1.
- **Report 02** (769 lines): Confirms GHR94 Case 5 formula is wrong for integer time. Counterexample documented. No published correction found.
- **Report 03** (429 lines): Complete implementation audit. Inventories all sorries with exact goal states.

### Lessons from v2 Implementation Attempt

Four critical lessons shape this plan:

1. **Case 5 -- no explicit Formula witness on Z**: The well-founded cascade argument terminates logically but cannot produce a concrete `Formula` value. On integers, open intervals `(n, n+1)_Z` are empty, so B-intervals from different U-witnesses do not chain into contiguous coverage. The cascade depth depends on the model, making a fixed-size formula impossible. Five candidate formulas were tried; all failed.

2. **Cases 6-8 -- two-U-formula problem**: Applying `neg_until_equiv` to rewrite `neg U(A,B)` produces `G(neg A) v U(neg A ^ neg B, neg A)`, introducing a NEW U-formula alongside the existing `U(A,B)`. GHR94's 8-case framework handles S-expressions with a SINGLE U-subformula. With two distinct U-formulas, the single-U reduction does not apply. This is a structural limitation of the lemma-by-lemma approach.

3. **SeparationThm closure axioms**: The 4 temporal closure axioms (`all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`) encapsulate the GHR94 Lemmas 10.2.4-10.2.8 substitution bridge. They were axiomatized because the bridge depends on the elimination cases (which were themselves axiomatized). Once elimination cases are proved, these can be proved too.

4. **Theorem 9.3.1 -- n-variable generalization**: The statement is specialized to `MonadicFormula sig 1` but the quantifier case `ex alpha` has `alpha : MonadicFormula sig 2`, requiring ~200-400 LOC of infrastructure for arbitrary variable count.

### Codebase State at Time of Revision

- `lake build` passes with 0 errors
- 4 axioms in `Eliminations.lean`: `elim_case_5_axiom`, `elim_case_6_axiom`, `elim_case_7_axiom`, `elim_case_8_axiom`
- 4 axioms in `SeparationThm.lean`: `all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`
- 1 sorry in `ExpressiveCompleteness.lean`: `separation_implies_expressiveness`
- 8 sorries in `DualEliminations.lean` (dead code, not on critical path)

## Goals & Non-Goals

**Goals**:
- Replace all 4 axioms in `Eliminations.lean` with proofs (Cases 5-8)
- Replace all 4 axioms in `SeparationThm.lean` with proofs (temporal closure)
- Close the 1 sorry in `ExpressiveCompleteness.lean` (Theorem 9.3.1)
- Achieve zero-axiom, zero-sorry `lake build` for all Separation/ files + ExpressiveCompleteness.lean
- Document the mathematical strategy deviations from GHR94 in code comments

**Non-Goals**:
- Proving DualEliminations.lean (8 sorries -- dead code, not on critical path)
- Finding GHR94's intended explicit formula for Case 5 (we use an alternative proof strategy)
- Extending to dense or continuous time flows
- Optimizing proof terms for performance
- Publishing the alternative proof strategy

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Research Phase 2 finds no viable strategy for Case 5 on Z | H | M | Fall back to FO-translation approach: translate S(a^U(A,B), q v U(A,B)) to FO, apply known FO-to-temporal back-translation. This is indirect but mathematically sound. If that also fails, Case 5 axiom remains documented as an open problem. |
| Iterated elimination for Cases 6-8 does not reduce to single-U cases | H | M | Alternative: prove Cases 6-8 directly via semantic argument on Z (bypass the neg_until_equiv expansion entirely). Each case has a finite number of temporal patterns that can be case-split. |
| Junction-depth induction for SeparationThm requires infrastructure not yet built | M | M | The substitution bridge (extract maximal U-subterms, replace by atoms, re-substitute) needs ~200 LOC. If stuck, the structural induction approach with temporal closure lemmas works once elimination is proved. |
| Theorem 9.3.1 n-variable generalization requires more than 400 LOC | M | L | The generalization is straightforward but tedious. If effort exceeds budget, prove for n=1 with an axiom for the general case, documented as a known extension. |
| Research blocker: no viable proof strategy exists for the integer case | H | L | The separation theorem for Z IS true (Kamp 1968, Reynolds 1994). If no constructive proof path is found through GHR94's framework, consider Reynolds' alternative axiomatization approach. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 1, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Complete separation_implies_expressiveness (Theorem 9.3.1) [BLOCKED]

**Goal**: Close the 1 sorry in `ExpressiveCompleteness.lean` by proving that separation implies expressive completeness via induction on FO formulas generalized to n free variables.

**BLOCKER** (Phase 1):
- **What failed**: The substitution step (Task 1.4) in the quantifier case requires that "past" parts of a separated formula evaluate ONLY at times <= the current point, and "future" parts ONLY at times >= the current point. This is needed so that R-atoms (encoding z's position relative to t) can be replaced by True/False constants in the correct temporal region.
- **What was tried**:
  1. **reduce + q_exists + context-dependent substitution**: Defined `reduce` (MonadicFormula sig (n+1) -> MonadicFormula extSig n) replacing the parameter variable with auxiliary predicates. Proved `reduce_correct` and `reduce_preserves_depth`. Applied IH to get temporal formula B. Formed q_exists(B). Attempted to substitute R-atoms by True/False in each temporal region (past/present/future) of the separated formula. FAILED because the substitution is incorrect when U-free subformulas contain `all_future` (which looks at future times).
  2. **inst (direct instantiation)**: Defined `inst` that replaces the parameter variable with concrete True/False values based on region and truth assignment. Works for quantifier-free formulas but FAILS for nested quantifiers because inner quantified variables' comparisons to t can't be resolved by region alone.
  3. **eliminate_HG conversion**: Attempted to convert all_past/all_future to S/U equivalents before separation. FAILED because the conversion introduces `untl` inside previously U-free arguments, breaking syntactic separation.
  4. **Conditional split for frozen predicates**: For predicates p(t) (constant in z), split formula into cases based on p(t) = True/False at the top level. This step IS correct and works. But it doesn't resolve the R-atom substitution issue.
- **Why it's stuck**: The `is_syntactically_separated` predicate in Defs.lean defines "U-free" as "no untl" and "S-free" as "no snce". This allows `all_future` inside S-arguments and `all_past` inside U-arguments. In GHR94, "pure past" means no U AND no G(=all_future); "pure future" means no S AND no H(=all_past). Our weaker definition means a "U-free" formula like `snce(all_future(atom a), bot)` is syntactically separated but NOT semantically pure-past -- it evaluates `all_future(atom a)` at z < t, which looks at ALL future times including times > t where R-atoms have different values. This makes the R-atom substitution incorrect.
- **What is needed**: One of:
  1. **Strengthen `is_syntactically_separated`**: Redefine "U-free" to also exclude `all_future`, and "S-free" to also exclude `all_past`. This matches GHR94's definition. Then re-verify that the separation theorem (currently axiomatized) still holds with the stronger definition, and use the stronger purity property in the substitution proof.
  2. **Prove separation produces strongly-separated formulas**: Show that `all_separable` (via the temporal closure axioms) actually produces formulas where S-arguments contain no `all_future` and U-arguments contain no `all_past`, even though `is_syntactically_separated` doesn't require this. Then use this additional property in the substitution proof.
  3. **Alternative proof of Theorem 9.3.1**: Use a proof strategy that doesn't rely on the purity of separated formula parts. E.g., a model-theoretic argument or a direct inductive construction that avoids the reduce+substitute pattern.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Infrastructure built during investigation** (available for future use):
- `ExtPred`, `extSignature`: Extended signature with auxiliary predicates (orig, frozen, r_eq, r_gt, r_lt)
- `reduce`: MonadicFormula sig (n+1) -> MonadicFormula extSig n (replaces last variable with aux predicates)
- `extStructure`: Extended IntStructureFromSig with correct aux predicate interpretations
- `reduce_correct`: Semantic correctness of reduce (fully proved)
- `reduce_preserves_depth`: Depth preservation of reduce (fully proved)
- `inst`: Direct instantiation with region and truth assignment (works for quantifier-free case)
- `separated_R_subst`: Context-aware R-atom substitution on separated formulas (syntactically defined but semantically incorrect with current separation definition)
- `subst_R_present/past/future`: Region-specific R-atom substitutions via subst_formula
- Helper lemmas: `int_truth_neg`, `int_truth_and`, `int_truth_atom_inj`, `injAtomMap`, `injAtomMap_injective`
- All helper lemmas and proofs tested via lean_run_code; not yet committed to the file

**Status Note**: A separate implementation agent was working on this phase. Preserve its progress.

**Strategy**: Generalize `separation_implies_expressiveness` to work with `MonadicFormula sig n` for arbitrary `n`. The base cases (atom, lt, not, and) translate directly to temporal atoms and Boolean connectives. The quantifier case `ex alpha` (where `alpha : MonadicFormula sig (n+1)`) requires:
1. A generalized translation lemma for n-variable formulas
2. An environment-to-temporal encoding scheme (map variable assignments to temporal positions using order comparisons)
3. Quantifier elimination via `q_exists` + separation decomposition + substitution

**Tasks**:
- [x] **Task 1.1**: Generalize the theorem statement to `MonadicFormula sig n` for arbitrary `n` *(completed -- reduce function handles n+1 -> n variable reduction)*
- [x] **Task 1.2**: Implement environment encoding: translate variable assignments `{0..n-1} -> Z` into temporal formulas using atoms `r_=`, `r_<`, `r_>` for position comparisons *(completed -- ExtPred, extSignature, reduce, extStructure, reduce_correct all proved)*
- [x] **Task 1.3**: Prove base cases: atom, lt, not, and (translate FO connectives to temporal connectives) *(completed -- all base cases proved with fixed injective atomMap)*
- [ ] **Task 1.4**: Prove the quantifier case: given IH for `MonadicFormula sig (n+1)`, construct the temporal equivalent for `exists x, phi(x, x_1, ..., x_n)` using `q_exists`, separation, and substitution *(deviation: blocked -- the substitution step requires stronger separation purity than is_syntactically_separated provides; see BLOCKER above)*
- [ ] **Task 1.5**: Specialize back to `n = 1` and prove the original `separation_implies_expressiveness` *(deviation: deferred -- blocked by Task 1.4)*
- [ ] **Task 1.6**: Verify `lake build` passes with no sorry in ExpressiveCompleteness.lean *(deviation: deferred -- blocked by Task 1.4)*

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- generalize and prove (~200-400 LOC)
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` -- extend with n-variable infrastructure if needed

---

### Phase 2: Research alternative proof strategies for Cases 5-8 [NOT STARTED]

**Goal**: Identify a viable proof strategy for the elimination cases that avoids the two known blockers (no explicit formula for Case 5 on Z; two-U-formula problem for Cases 6-8). This phase produces a research report, not code.

**Motivation**: The v2 implementation attempt exhaustively demonstrated that GHR94's approach to Cases 5-8 does not work on integer time as written. Before attempting new code, we need a mathematically sound alternative strategy. This requires targeted research.

**Research Questions** (in priority order):
1. **FO-translation approach for Case 5**: Can we translate `S(a ^ U(A,B), q v U(A,B))` to a monadic FO sentence over Z, then apply the Theorem 9.3.1 back-translation to obtain a separated temporal formula? This avoids needing an explicit formula by leveraging the FO-to-temporal correspondence. What are the obstacles to making this circular-free (since Theorem 9.3.1 uses separation)?
2. **Direct Finset construction for Case 5**: Since Z is discrete, any U-witness chain is finite. Can we enumerate witness configurations as a finite disjunction, then show each disjunct is separated? The key question is whether the disjunction can be expressed as a fixed-size Formula.
3. **Iterated single-U elimination for Cases 6-8**: After neg_until_equiv expansion produces two U-formulas U1 and U2, can we treat U1 as a "macro atom" and apply the 8-case framework to eliminate U2 first, then eliminate U1 in a second pass? What are the well-foundedness conditions for this iteration?
4. **Reynolds' alternative axiomatization**: Reynolds (1994) proved the separation theorem for Z using a different approach than GHR94. Does Reynolds' proof avoid the Case 5 formula entirely? Can we adapt Reynolds' strategy?
5. **Multi-U generalization of Lemma 10.2.3**: Can the 8-case framework be extended to handle S-expressions with k distinct U-subformulas (k >= 2)? What changes to the case analysis?

**Tasks**:
- [ ] **Task 2.1**: Research the FO-translation approach: check whether `int_equiv` between temporal and FO formulas gives a non-circular path to Case 5
- [ ] **Task 2.2**: Research iterated elimination: formalize the conditions under which eliminating one U at a time terminates and preserves separation
- [ ] **Task 2.3**: Research Reynolds 1994 and other alternative proofs of the Z separation theorem
- [ ] **Task 2.4**: Research direct semantic proofs: for each case, can we construct the separated formula by analyzing the finite set of temporal patterns on Z intervals?
- [ ] **Task 2.5**: Write research report with recommended strategy, proof sketches, and effort estimates

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `specs/157_expressive_completeness_su_integer/reports/04_axiom-elimination-strategies.md` -- new research report

---

### Phase 3: Prove Cases 5-8 in Eliminations.lean [NOT STARTED]

**Goal**: Replace the 4 axioms (`elim_case_5_axiom`, `elim_case_6_axiom`, `elim_case_7_axiom`, `elim_case_8_axiom`) in `Eliminations.lean` with genuine proofs using the strategy identified in Phase 2.

**Strategy** (to be refined by Phase 2 research; candidate approaches listed):

**Candidate A -- Iterated Elimination**:
- For Case 5: Prove existence by induction on the number of temporal alternations in the formula. At each step, use Cases 1-4 to handle the base and the well-ordering of temporal complexity to ensure termination. The key insight is that even though we cannot give an explicit formula, we can show `exists psi` by constructing it via the induction.
- For Cases 6-8: After neg_until_equiv expansion, treat the resulting two-U expression as having strictly smaller temporal complexity than the original. Apply the full elimination framework recursively: first eliminate U2 (treating U1 as an atom), then eliminate U1. Each step reduces the number of non-eliminated U-subformulas.

**Candidate B -- Direct Semantic Argument**:
- For each case, prove `exists psi : Formula, int_equiv original psi ^ is_syntactically_separated psi` by a direct semantic argument. Construct the separated formula by case-splitting on the positions of U-witnesses relative to t, using `Finset`-based reasoning on Z intervals. The result is a finite disjunction of pure-past/pure-future/present formulas.

**Candidate C -- FO Translation Round-Trip**:
- Translate the Since-expression to FO over Z. Apply the known FO-to-temporal back-translation. Show the result is separated. This approach is indirect but avoids the need for an explicit Case 5 formula.

**Tasks**:
- [ ] **Task 3.1**: Implement the chosen strategy for Case 5 (`elim_case_5_axiom` -> theorem)
- [ ] **Task 3.2**: Implement the chosen strategy for Case 6 (`elim_case_6_axiom` -> theorem)
- [ ] **Task 3.3**: Implement the chosen strategy for Case 7 (`elim_case_7_axiom` -> theorem)
- [ ] **Task 3.4**: Implement the chosen strategy for Case 8 (`elim_case_8_axiom` -> theorem)
- [ ] **Task 3.5**: Remove all 4 axiom declarations from Eliminations.lean
- [ ] **Task 3.6**: Verify `lake build` passes with no axioms and no sorry in Eliminations.lean

**Timing**: 6 hours

**Depends on**: 2 (research must identify viable strategy before implementation)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- replace axioms with proofs (~300-500 LOC)
- Possibly new helper file if infrastructure is substantial

**Verification**:
- `lake build` passes
- `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` returns empty
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` returns empty

---

### Phase 4: Prove temporal closure in SeparationThm.lean [NOT STARTED]

**Goal**: Replace the 4 axioms (`all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`) in `SeparationThm.lean` with genuine proofs implementing the GHR94 Lemmas 10.2.4-10.2.8 substitution bridge.

**Strategy**: With elimination Cases 1-8 now proved (Phase 3), the substitution bridge becomes tractable. The approach is junction-depth induction:

1. Define `junction_depth : Formula -> Nat` measuring the maximum nesting of U-within-S or S-within-U alternation.
2. For `all_past phi` where `phi` is separable with separated equivalent `phi'`:
   - If `phi'` is U-free: `all_past phi'` is directly separated (pure past).
   - If `phi'` has U-subterms: extract maximal U-subterms `U(A_i, B_i)` (where `A_i, B_i` are S-free because `phi'` is separated). Replace each by a fresh atom `p_i`. The resulting `all_past phi''` is separated (U-free). Now substitute back: this is exactly Lemma 10.2.4 (single S with top-level U). Apply the proved elimination cases to obtain a separated result.
3. Symmetric arguments for `all_future`, `untl`, `snce`.
4. The junction_depth decreases at each substitution step because the elimination removes one level of S-U alternation.

**Tasks**:
- [ ] **Task 4.1**: Define `junction_depth` as a computable function on Formula
- [ ] **Task 4.2**: Implement `extract_maximal_U_subterms`: given a separated formula, identify the maximal U-subformulas whose arguments are S-free
- [ ] **Task 4.3**: Implement `subst_U_by_atoms`: replace maximal U-subterms by fresh atoms, returning the substituted formula and a mapping
- [ ] **Task 4.4**: Prove `subst_U_by_atoms_equiv`: the substitution preserves equivalence when atoms are interpreted as the U-subterms they replace
- [ ] **Task 4.5**: Prove `elimination_reduces_junction_depth`: applying elimination cases to a substituted formula yields a result with strictly lower junction_depth
- [ ] **Task 4.6**: Prove `all_past_separable` using junction_depth induction + substitution bridge
- [ ] **Task 4.7**: Prove `all_future_separable` (symmetric to 4.6)
- [ ] **Task 4.8**: Prove `untl_separable` using the proved elimination cases directly (untl arguments already separated, so the snce-to-separated reduction from elimination applies after `swap_temporal`)
- [ ] **Task 4.9**: Prove `snce_separable` using elimination cases 1-8 on the maximal U-subformula
- [ ] **Task 4.10**: Remove all 4 axiom declarations from SeparationThm.lean
- [ ] **Task 4.11**: Verify `lake build` passes with no axioms and no sorry in SeparationThm.lean

**Timing**: 4 hours

**Depends on**: 3 (all 8 elimination cases must be proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace axioms with proofs (~200-400 LOC)
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Helpers.lean` -- add junction_depth, extraction helpers

**Verification**:
- `lake build` passes
- `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- `all_separable` follows from structural induction + temporal closure lemmas (no axioms in dependency chain)

---

### Phase 5: Integration and final verification [NOT STARTED]

**Goal**: Verify the complete proof chain from elimination cases through separation theorem to expressive completeness, with zero axioms and zero sorry in the critical path.

**Tasks**:
- [ ] **Task 5.1**: Run `lake build` and verify 0 errors
- [ ] **Task 5.2**: Run `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- must return empty
- [ ] **Task 5.3**: Run `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- must return empty
- [ ] **Task 5.4**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- must return empty
- [ ] **Task 5.5**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` -- only DualEliminations.lean acceptable
- [ ] **Task 5.6**: Verify the proof chain: `US_expressively_complete_over_Z` -> `separation_implies_expressiveness` -> `separation_theorem_int` -> `all_separable` -> elimination cases 1-8 (all proved)
- [ ] **Task 5.7**: Document the complete proof structure in module docstrings

**Timing**: 2 hours

**Depends on**: 1 (Theorem 9.3.1), 4 (temporal closure)

**Files to modify**:
- Various files -- docstring updates only
- No logic changes expected

**Verification**:
- All checks from Tasks 5.1-5.6 pass
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

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/02_expressive-completeness-plan.md` (this file, v3)
- `specs/157_expressive_completeness_su_integer/reports/04_axiom-elimination-strategies.md` (Phase 2 output)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (axioms replaced with proofs)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (axioms replaced with proofs)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` (sorry replaced with proof)

## Rollback/Contingency

- All axioms remain in the codebase until their replacement proofs are verified. The replacement is done by changing `axiom` to `theorem` and providing a proof body. If a phase fails, the axiom version is preserved in git history.
- If Phase 2 research finds no viable strategy for Case 5: the axiom remains with full documentation. The task would be marked [PARTIAL] with a note that Case 5 on integers is an open problem requiring novel mathematical work beyond GHR94.
- If Cases 6-8 iterated elimination fails: each case can remain axiomatized independently. The axioms are mathematically sound (the separation theorem for Z is established by multiple independent proofs).
- If Phase 4 (temporal closure) proves intractable: the 4 temporal closure axioms are a clean abstraction boundary. They can remain as axioms documented as depending on the (proved or axiomatized) elimination cases.
- If Phase 1 agent completes before Phase 5: incorporate its results. If it blocks: Phase 5 can verify everything except the ExpressiveCompleteness.lean sorry.
- Priority ordering if time-constrained: Phase 2 (research) > Phase 3 (elimination proofs) > Phase 4 (closure proofs) > Phase 1 (Theorem 9.3.1) > Phase 5 (integration).
