# Implementation Plan: Expressive Completeness of {S,U} over Integer Time

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [IN PROGRESS]
- **Effort**: 36 hours
- **Dependencies**: Task 155
- **Research Inputs**: specs/157_expressive_completeness_su_integer/reports/01_expressive-completeness-proof.md
- **Artifacts**: plans/01_expressive-completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Formalize the expressive completeness theorem for {Since, Until} over integer time (GHR94 Theorem 10.2.9-10.2.10, Reynolds' Theorem 5). The proof proceeds in two stages: (A) prove every {U,S}-formula is equivalent to a syntactically separated formula over Z via a 4-level nested induction (Lemmas 10.2.1-10.2.8), and (B) show separation implies expressive completeness via Theorem 9.3.1. The formalization builds ~1690 lines across 11 Lean files under `Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and `ExpressiveCompleteness.lean`. The planned 17-file structure was consolidated during implementation: Lemmas 10.2.4-10.2.8 share `SeparationThm.lean`; FO infrastructure lives in `ExpressiveCompleteness.lean`. Definition of done: `lake build` passes with zero sorries and all theorems fully proved.

### Research Integration

The research report provides a complete pseudo-Lean proof map covering:
- All type signatures for definitions and theorems (Sections 2-6)
- The 4-level induction structure diagram (Section 7)
- File organization plan with LOC estimates (Section 8)
- Technical challenges and mitigations (Section 9)
- Existing infrastructure reuse inventory (Section 10)
- Connection to Task 155 / Reynolds pipeline (Section 11)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Literature References (MANDATORY)

Implementation agents MUST follow the precise constructions given in the literature below. Do not invent alternative proof strategies, reformulate definitions, or deviate from the published proof structure. The research report (`specs/157_expressive_completeness_su_integer/reports/01_expressive-completeness-proof.md`) maps each step to GHR94 with exact pseudo-Lean signatures — use it as the primary reference during implementation.

**Primary source**:
- Gabbay, D.M., Hodkinson, I., and Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1*. Oxford University Press.
  - **Chapter 10, Section 10.2** (pp. 569–592): Separation theorem for integer time. Contains Lemmas 10.2.1–10.2.8 and Theorem 10.2.9.
  - **Chapter 9, Section 9.3** (pp. 507–520): Theorem 9.3.1 (separation implies expressive completeness).
  - Markdown conversions available in `literature/` directory.

**Secondary sources** (consult if stuck on a specific sub-proof):
- Reynolds, M. (2010). "The Complexity of Temporal Logic over the Reals." *Annals of Pure and Applied Logic* 161(8), 1063–1096. — Reynolds' numbering: Theorem 5 = our 10.2.10; Theorem 14 = gap elimination (task 155).
- Gabbay, D.M. (1981). "Expressive Functional Completeness in Tense Logic." In *Aspects of Philosophical Logic*, ed. U. Mönnich, Reidel, pp. 91–117. — Original statement of separation for Z; less detailed proofs but useful for intuition on the 8 cases.
- Kamp, H. (1968). *Tense Logic and the Theory of Linear Order*. PhD thesis, UCLA. — Historical context; shows why Until/Since suffice (Kamp's theorem for reals, extended to Z by Gabbay).

**How to use**: Each phase references specific GHR94 lemma numbers. When implementing a phase, read the corresponding section of GHR94 (via `literature/` markdown files) alongside the pseudo-Lean in the research report. The research report Section 4–6 gives the exact Lean type signatures to implement; GHR94 gives the semantic arguments to formalize.

## Deviation Policy (MANDATORY)

Implementation agents MUST NOT improvise, skip steps, or invent alternative proof strategies when encountering difficulty. The following protocol is required:

1. **If a phase is harder than expected but the approach is clear**: Continue working within the phase. Use `sorry` for specific sub-lemmas that are taking too long, but preserve the overall proof structure from the literature.

2. **If the GHR94 proof step seems incorrect, incomplete, or unclear**: STOP. Mark the phase as `[BLOCKED]` with a clear description of what is unclear or appears wrong. Do NOT attempt an alternative construction.

3. **If the Lean formalization requires infrastructure not anticipated in the plan**: STOP. Mark the phase as `[BLOCKED]` explaining what infrastructure is missing and why.

4. **If a definition or type signature from the research report doesn't work as written**: STOP. Mark the phase as `[BLOCKED]` explaining the type error or structural issue.

5. **After blocking**: The primary agent will run a `/research` cycle targeting the specific blocker, then `/revise` the plan before resuming `/implement`. This ensures all deviations are documented and reviewed rather than silently accumulating.

**Rationale**: This proof has a precise, well-understood structure from the literature. Ad-hoc modifications compound into unrecoverable divergences from the published proof. It is always cheaper to research a blocker than to debug a creative workaround.

## Goals & Non-Goals

**Goals**:
- Define `IntStructure`, `int_truth`, purity predicates, and syntactic separation predicates
- Prove the 8 elimination cases (Lemma 10.2.3) for pulling U out of S
- Prove the nested induction lemmas (10.2.4-10.2.8) leading to the Separation Theorem (10.2.9)
- Prove Theorem 9.3.1 (separation implies expressive completeness)
- State and prove the final theorem (10.2.10): {U,S} is expressively complete over Z
- Exploit duality (`swap_temporal`) to derive "S out of U" cases from "U out of S" cases

**Non-Goals**:
- Extending completeness to dense or continuous time flows
- Proving decidability of the separation algorithm
- Optimizing proof terms for runtime performance
- Connecting to the full Reynolds gap elimination chain (Task 155 Phase 3B, future work)
- Implementing a decision procedure or tactic for separation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| 8 elimination cases are more complex than estimated | H | M | Start with Cases 1 and 5 (direct semantic); reduce others to these. Allow sorry in hardest cases initially. |
| Termination arguments for nested induction measures | M | M | Define measures as computable Nat functions; use Nat.lt_wfRel for well-founded recursion. |
| DNF/CNF conversion infrastructure is large | M | L | Use abstract correctness theorems; avoid full normalization algorithm -- just state that equivalent normal forms exist. |
| Theorem 9.3.1 requires extending MonadicFO with R-predicates | M | M | Extend MonadicSignature with auxiliary predicates as a signature extension operation. |
| Box treatment may cause semantic mismatches | L | L | Define box as True in int_truth (degenerate); bridge lemma connects to full semantics. |
| Freshness infrastructure may need extension | L | L | Existing Atom.mk_fresh suffices; extend only if needed for multi-atom generation. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 2, 4 |
| 5 | 6 | 4, 5 |
| 6 | 7 | 6 |
| 7 | 8 | 6, 7 |
| 8 | 9 | 7, 8 |
| 9 | 10 | 9 |
| 10 | 11 | 10 |
| 11 | 12 | 10, 11 |
| 12 | 13 | 1 |
| 13 | 14 | 11, 13 |
| 14 | 15 | 14 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Core Definitions and Integer Semantics [COMPLETED]

**Goal**: Create `Separation/Defs.lean` with IntStructure, int_truth, purity predicates, separation predicates, and structural measures.

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/Separation/`
- [ ] Define `IntStructure` (valuation on Z)
- [ ] Define `int_truth` (recursive truth evaluation for formulas over Z)
- [ ] Define `int_equiv` (semantic equivalence over integer time)
- [ ] Define `is_pure_past`, `is_pure_future`, `is_pure_present` (semantic purity)
- [ ] Define `is_U_free`, `is_S_free` (syntactic predicates, decidable)
- [ ] Define `is_syntactically_separated` (recursive syntactic check)
- [ ] Define `is_separable` (existential: equivalent to a separated formula)
- [ ] Define `junction_depth`, `junction_depth_U`, `junction_depth_S`
- [ ] Define `U_depth_under_S`, `count_U_subformulas`
- [ ] Create `Separation.lean` hub file importing `Separation/Defs`
- [ ] Verify `lake build` passes

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` - 274 LOC, 0 sorry
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean` - new hub file

**Verification**:
- `lake build` passes with no errors
- All definitions compile and are well-typed
- `is_U_free`, `is_S_free`, `is_syntactically_separated` are decidable (Bool-valued)

---

### Phase 2: Formula Operations and Integer Helpers [PARTIAL]

**Goal**: Create `Separation/FormulaOps.lean` with substitution, DNF/CNF signatures, and freshness; create `Separation/IntHelpers.lean` with integer-specific lemmas.

**Current state**: IntHelpers.lean fully proved (0 sorry). FormulaOps.lean has 7 sorries: `to_DNF`, `to_CNF`, `dnf_equiv`, `cnf_equiv`, `subst_correctness`, and two related helpers.

**Tasks**:
- [ ] Define `Formula.subst` (substitute formula for atom)
- [ ] State `subst_correctness` (substitution preserves truth under modified valuation)
- [ ] Define `IntStructure.with` (modify valuation at a single atom)
- [ ] State and prove (or sorry) `subst_correctness`
- [ ] Define `to_DNF`, `to_CNF` signatures (list-of-lists representation)
- [ ] State `dnf_equiv`, `cnf_equiv` correctness theorems
- [ ] Define `fresh_atom` and `fresh_atoms` using existing `Atom.mk_fresh`
- [ ] State `fresh_atom_not_in` theorem
- [ ] In `IntHelpers.lean`: prove `Int.Ioo_finite` (bounded intervals in Z are finite)
- [ ] Prove `Int.exists_min_of_bdd_below_finite` (non-empty finite sets have minimum)
- [ ] Prove `until_witness_construction` (direct witness gives U)
- [ ] Prove `since_top_is_past` and `until_top_is_future`
- [ ] Update hub file to import new modules
- [ ] Verify `lake build` passes

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` - new file (~200 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/IntHelpers.lean` - new file (~100 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean` - update imports

**Verification**:
- `lake build` passes
- `subst_correctness` is at least stated (may use sorry)
- Integer helper lemmas about finite intervals are proved (no sorry)

---

### Phase 3: Temporal Duality Infrastructure [COMPLETED]

**Goal**: Establish the `swap_temporal` duality principle for integer semantics, enabling automatic derivation of "S out of U" cases from "U out of S" cases.

**Tasks**:
- [ ] Prove `swap_temporal_int_truth`: `int_truth (M.reverse) t (φ.swap_temporal) ↔ int_truth M (-t) φ` (or appropriate formulation for Z-reversal)
- [ ] Define `IntStructure.reverse` (flip time direction: `val a := {-s | s ∈ M.val a}`)
- [ ] Prove `dual_equiv`: if `int_equiv φ ψ` then `int_equiv φ.swap_temporal ψ.swap_temporal`
- [ ] Prove `dual_U_free_iff_S_free`: `is_U_free (φ.swap_temporal) = is_S_free φ`
- [ ] Prove `dual_separated`: `is_syntactically_separated (φ.swap_temporal) = is_syntactically_separated φ`
- [ ] Verify `lake build` passes

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Duality.lean` - new file (~120 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean` - update imports

**Verification**:
- `lake build` passes
- `dual_equiv` is proved (not sorry)
- Duality lemmas compose correctly with existing `swap_temporal_involution`

---

### Phase 4: Distributivity Laws (Lemma 10.2.1) [COMPLETED]

**Goal**: Prove U and S distribute over boolean connectives (4 theorems).

**Tasks**:
- [ ] Prove `until_distrib_or_left`: U(A v B, C) <-> U(A,C) v U(B,C)
- [ ] Prove `since_distrib_or_left`: S(A v B, C) <-> S(A,C) v S(B,C)
- [ ] Prove `until_distrib_and_right`: U(A, B ^ C) <-> U(A,B) ^ U(A,C)
- [ ] Prove `since_distrib_and_right`: S(A, B ^ C) <-> S(A,B) ^ S(A,C)
- [ ] Note: `_and_right` direction (<-) requires linearity argument (take min/max of witnesses)
- [ ] Verify `lake build` passes

**Timing**: 2 hours

**Depends on**: 2, 4 (IntHelpers for witness arguments)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Distributivity.lean` - new file (~200 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean` - update imports

**Verification**:
- `lake build` passes
- All 4 distributivity theorems proved without sorry
- Since variants may use duality if available, or direct proof

---

### Phase 5: Negation Equivalences (Lemma 10.2.2) [COMPLETED]

**Goal**: Prove the integer-specific negation of U and S. This is the key Z-dependent step.

**Tasks**:
- [ ] Prove `neg_until_equiv`: not U(A,B) <-> G(not A) v U(not A ^ not B, not A) over Z
- [ ] The (→) direction requires: well-ordering in Z to find "first failure" of B
- [ ] The (←) direction: case split on G(not A) vs U-witness
- [ ] Prove `neg_since_equiv` via duality from `neg_until_equiv` + `dual_equiv`
- [ ] Optionally state `neg_until_equiv'` (second form from GHR94)
- [ ] Verify `lake build` passes

**Timing**: 3 hours

**Depends on**: 2, 4 (IntHelpers for Z well-ordering and finite intervals)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NegationEquiv.lean` - new file (~200 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean` - update imports

**Verification**:
- `lake build` passes
- `neg_until_equiv` proved without sorry (this is the hardest part of this phase)
- `neg_since_equiv` derived via duality (no sorry)

---

### Phase 6: Elimination Cases 1 and 5 (Core Direct Cases) [PARTIAL]

**Goal**: Prove the two "direct semantic" elimination cases that form the foundation for all others.

**Current state**: Case 1 PROVED (sorry-free). Case 5 and Cases 2-8 remain sorry. The file was restructured with helper lemmas (int_truth_and_iff, int_truth_or_iff, u_free_s_free_imp_separated) and Case 1 uses explicit GHR94 trichotomy on U-witness position.

**Tasks**:
- [x] State and prove `elim_case_1`: S(a ^ U(A,B), q) equivalence (3 disjuncts based on U-witness location) *(completed — full semantic proof with lt_trichotomy)*
  - (→): case split on u vs t using `lt_trichotomy`
  - (←): verify each disjunct implies the original
- [ ] State and prove `elim_case_5`: S(a ^ U(A,B), q v U(A,B)) equivalence *(deviation: deferred — requires cascading U-witness well-ordering argument)*
  - Split on whether U-witness is past/present/future of t
- [x] Both cases require atoms a, q, A, B to be U-free and S-free
- [x] Verify `lake build` passes

**Timing**: 4 hours

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` - new file (start ~300 LOC, growing)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean` - update imports

**Verification**:
- `lake build` passes
- Cases 1 and 5 proved without sorry
- Each case produces a formula where U(A,B) appears only at top level (not under S)

---

### Phase 7: Elimination Cases 2 and 4 (Negation-Based Cases) [PARTIAL]

**Goal**: Prove Cases 2 and 4 which involve not U(A,B) in the event or guard position.

**Current state**: Merged into Phase 6 — all 8 cases are in `Eliminations.lean`. Cases 2 and 4 have `sorry` proofs.

**Tasks**:
- [ ] Prove `elim_case_2`: S(a ^ not U(A,B), q)
  - Strategy: apply `neg_until_equiv` to rewrite not U(A,B), then reduce to Case 1 and simpler sub-cases
- [ ] Prove `elim_case_4`: S(a, q v not U(A,B))
  - Strategy: direct semantic argument about the "safe zone" where B guards against A
- [ ] Both require composing with Lemma 10.2.2 (NegationEquiv)
- [ ] Verify `lake build` passes

**Timing**: 3 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` - extend (~200 LOC added)

**Verification**:
- `lake build` passes
- Cases 2 and 4 proved without sorry
- RHS formulas have U(A,B) only at top level

---

### Phase 8: Elimination Cases 3, 6, 7, 8 (Reduction Cases) [PARTIAL]

**Goal**: Prove the remaining 4 elimination cases, each reducing to combinations of earlier cases.

**Current state**: Merged into Phase 6 — all 8 cases are in `Eliminations.lean`. Cases 3, 6, 7, 8 have `sorry` proofs.

**Tasks**:
- [ ] Prove `elim_case_3`: S(a, q v U(A,B)) -- negate, use 10.2.2, apply Case 2
- [ ] Prove `elim_case_6`: S(a ^ not U(A,B), q v U(A,B)) -- reduces to Cases 3, 5
- [ ] Prove `elim_case_7`: S(a ^ U(A,B), q v not U(A,B)) -- reduces to Cases 4, 8
- [ ] Prove `elim_case_8`: S(a ^ not U(A,B), q v not U(A,B)) -- negate, reduce to Case 5
- [ ] Note: Cases 6-8 have circular-looking dependencies; resolve by stating each as "equivalent to a formula with U only at top level" (existential form)
- [ ] Verify `lake build` passes

**Timing**: 4 hours

**Depends on**: 6, 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` - extend (~300 LOC added)

**Verification**:
- `lake build` passes
- All 8 cases proved (sorry acceptable in Case 7/8 if circular dependency is complex; flag for followup)
- Total Eliminations.lean around 800 LOC

---

### Phase 9: Dual Elimination Cases (U out of S -> S out of U) [PARTIAL]

**Goal**: Derive the 8 dual cases (pulling S out from under U) automatically via swap_temporal.

**Current state**: All 8 dual cases stated in `DualEliminations.lean` (116 LOC) but all 8 have `sorry` proofs. These are blocked on Phase 6-8: once `Eliminations.lean` proofs are complete, duals follow mechanically via `dual_equiv`.

**Tasks**:
- [ ] State `elim_case_1_dual` through `elim_case_8_dual` for U(a ^ S(A,B), q) patterns
- [ ] Prove each via `dual_equiv` applied to the corresponding elim_case_N
- [ ] Verify that duality correctly transforms hypotheses (U-free <-> S-free under swap)
- [ ] Package as `dual_eliminations` lemma or section
- [ ] Verify `lake build` passes

**Timing**: 1.5 hours

**Depends on**: 7, 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` - new file (~150 LOC)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean` - update imports

**Verification**:
- `lake build` passes
- All 8 dual cases derived without sorry (proofs are just applications of duality)
- No new semantic reasoning required

---

### Phase 10: Lemma 10.2.4 (Single S with Top-Level U) [PARTIAL]

**Goal**: Prove that S(C,F) where U appears only as U(A,B) at top level can be separated into 8 canonical forms.

**Current state**: Consolidated into `SeparationThm.lean` (114 LOC total for Phases 10-12, 14). The lemma is stated but proof is `sorry`. Planned file `SingleSWithU.lean` was not created separately.

**Tasks**:
- [ ] Define `u_appearances_top_level_only` predicate (U(A,B) not under any S in C, F)
- [ ] Define `u_appears_only_as_top_level` predicate (result has U only at top level, not under S)
- [ ] Prove `single_S_with_U`: given hypotheses, reduce S(C,F) to boolean combination of 8 elimination cases
  - Step 1: Put C in DNF (conjunction of atoms/signed-U-literals)
  - Step 2: Put F in CNF (disjunction of atoms/signed-U-literals)
  - Step 3: Use `since_distrib_or_left` and `since_distrib_and_right` to split
  - Step 4: Each resulting S matches one of 8 patterns; apply elimination
- [ ] The proof invokes distributivity (Phase 4) and all 8 elimination cases
- [ ] Verify `lake build` passes

**Timing**: 2.5 hours

**Depends on**: 9

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` - consolidated (Phases 10-12, 14 share this file)

**Verification**:
- `lake build` passes
- `single_S_with_U` theorem stated and proved (sorry acceptable in the DNF/CNF reduction if complex)
- Output formula has U(A,B) only at top level

---

### Phase 11: Lemma 10.2.5 (Single U Formula, Induction on S-Depth) [PARTIAL]

**Goal**: Prove that if the only U in D is U(A,B) with A,B atomic, then D is separable.

**Current state**: Consolidated into `SeparationThm.lean`. Stated but proof is `sorry`. Planned file `SingleU.lean` was not created separately.

**Tasks**:
- [ ] Define `u_appears_only_as` predicate (formula D contains U only as U(A,B))
- [ ] Define `S_nesting_above_U` measure (max S-nesting depth above a U(A,B) occurrence)
- [ ] Prove `single_U_separable` by well-founded induction on `S_nesting_above_U`
  - Base (k=0): U(A,B) at top level, already separated
  - Step (k>0): identify deepest S containing U(A,B), apply `single_S_with_U` (Phase 10), reduce k
- [ ] Verify `lake build` passes

**Timing**: 2 hours

**Depends on**: 10, 11

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` - consolidated (see Phase 10)

**Verification**:
- `lake build` passes
- `single_U_separable` proved by well-founded induction (may use sorry for measure-decrease lemma)
- Termination argument shows `S_nesting_above_U` decreases by exactly 1

---

### Phase 12: Lemma 10.2.6 (Multiple U Formulas, Count Induction) [PARTIAL]

**Goal**: Prove that if all U in D are U(A_i, B_i) with atomic arguments, D is separable.

**Current state**: Consolidated into `SeparationThm.lean`. Stated but proof is `sorry`. Planned file `MultiU.lean` was not created separately.

**Tasks**:
- [ ] Define `all_U_in_D_are_from_Us` predicate (all U subformulas come from a given list)
- [ ] Prove `multi_U_separable` by induction on the list length (number of distinct U-subformulas)
  - Base (n=1): apply `single_U_separable`
  - Step (n>1): focus on U(A_n, B_n), replace other U(A_i, B_i) by fresh atoms q_i
  - Apply `single_U_separable` to the simplified formula
  - Resubstitute U(A_i, B_i) for q_i; pure-past parts now have < n U-formulas
  - Apply induction hypothesis
- [ ] Prove substitution preserves separation (helper lemma)
- [ ] Verify `lake build` passes

**Timing**: 2 hours

**Depends on**: 10, 11

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` - consolidated (see Phase 10)

**Verification**:
- `lake build` passes
- `multi_U_separable` proved by induction (sorry acceptable for measure-decrease and substitution correctness)

---

### Phase 13: FO-to-Temporal Infrastructure (Theorem 9.3.1 Preparation) [PARTIAL]

**Goal**: Build the first-order logic infrastructure needed for Theorem 9.3.1, independent of the separation proof.

**Current state**: Consolidated into `ExpressiveCompleteness.lean` (120 LOC total for Phases 13+15). Planned file `FOToTemporal.lean` was not created separately. Infrastructure is stated but key proofs are `sorry`.

**Tasks**:
- [ ] Define `IntStructureFromSig` (monadic FO structure over Z)
- [ ] Define `eval_Z_sig` (evaluate MonadicFormula on IntStructureFromSig)
- [ ] Define `to_int_struct` (convert sig-based structure to IntStructure given atom map)
- [ ] Define `q_exists` connective: P(A) v A v F(A)
- [ ] Prove `q_exists_correct`: q_exists captures existential quantification over Z
- [ ] State `pure_past_substitution` and `pure_future_substitution` (purity enables independent substitution)
- [ ] Define signature extension with R_=, R_>, R_< predicates
- [ ] Verify `lake build` passes

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` - consolidated (Phases 13+15 share this file)

**Verification**:
- `lake build` passes
- `q_exists_correct` proved without sorry
- All type signatures align with existing MonadicFO.lean infrastructure

---

### Phase 14: Lemmas 10.2.7-10.2.8 and Separation Theorem [PARTIAL]

**Goal**: Prove the top two levels of the nested induction and state the final Separation Theorem 10.2.9.

**Current state**: All in `SeparationThm.lean`. `separation_theorem_int` is stated and chains through 10.2.4-10.2.8 but the individual lemma proofs are `sorry`. Planned files `NoSWithinU.lean` and `JunctionDepth.lean` were not created separately.

**Tasks**:
- [ ] Define `no_S_nested_in_U` predicate
- [ ] Prove `no_S_within_U_separable` (Lemma 10.2.7) by induction on `U_depth_under_S`
  - Base (depth=0 or 1): no U under S, already separated or apply Lemma 10.2.6
  - Step: replace sub-U's by atoms, apply Lemma 10.2.6, resubstitute, apply IH
- [ ] Prove `junction_depth_separable` (Lemma 10.2.8) by induction on `junction_depth`
  - Base (depth <= 1): no alternation, already separated
  - Step: replace S-under-U by atoms, apply Lemma 10.2.7, resubstitute, apply IH
- [ ] State and prove `separation_theorem_int` (Theorem 10.2.9): direct corollary of 10.2.8
- [ ] Create `SeparationThm.lean` as the final theorem file
- [ ] Verify `lake build` passes

**Timing**: 3 hours

**Depends on**: 11, 13

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` - consolidated (see Phase 10)

**Verification**:
- `lake build` passes
- `separation_theorem_int` is proved as a direct application of `junction_depth_separable`
- Stage A of the proof is complete

---

### Phase 15: Theorem 9.3.1 + 10.2.10 (Expressive Completeness) [PARTIAL]

**Goal**: Prove separation implies expressive completeness and combine with the Separation Theorem for the final result.

**Current state**: `ExpressiveCompleteness.lean` (120 LOC). `separation_implies_expressiveness` and `US_expressively_complete_over_Z` are stated and type-check but have 2 `sorry` proofs (the inductive step of 9.3.1, and the final composition).

**Tasks**:
- [ ] State `separation_implies_expressiveness` (Theorem 9.3.1)
  - By induction on quantifier depth m of the FO formula
  - Base (m=0): quantifier-free formulas translate directly to atoms
  - Step (m>0): introduce R predicates, use IH, apply separation, substitute
- [ ] Prove the base case completely
- [ ] Prove the inductive step (may sorry the separation-substitution step initially)
- [ ] State and prove `US_expressively_complete_over_Z` (Theorem 10.2.10)
  - Composition: `separation_implies_expressiveness (fun phi => separation_theorem_int phi)`
- [ ] Optionally state `reynolds_theorem_5` as bridge to Task 155
- [ ] Create `ExpressiveCompleteness.lean` file
- [ ] Update lakefile/imports if needed
- [ ] Verify `lake build` passes

**Timing**: 4 hours

**Depends on**: 14

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` - consolidated (see Phase 13)

**Verification**:
- `lake build` passes
- `US_expressively_complete_over_Z` compiles and type-checks
- The theorem chain 10.2.9 -> 9.3.1 -> 10.2.10 is complete
- Remaining sorries (if any) are isolated to specific sub-lemmas within 9.3.1

---

## Testing & Validation

- [ ] `lake build` passes with no errors after each phase
- [ ] No regressions in existing `Theories/Bimodal/` code
- [ ] `is_U_free`, `is_S_free`, `is_syntactically_separated` compute correctly on test formulas
- [ ] `int_truth` agrees with `temporal_truth` for formulas without box (informal check)
- [ ] Duality: `elim_case_N_dual` types match expected signatures
- [ ] Separation theorem: `separation_theorem_int` has type `(phi : Formula) -> is_separable phi`
- [ ] Final theorem: `US_expressively_complete_over_Z` type-checks against MonadicFormula infrastructure
- [ ] Count sorry occurrences across all files; target: zero by project completion

## Artifacts & Outputs (Actual)

| File | LOC | Sorry | Status |
|------|-----|-------|--------|
| `Separation/Defs.lean` | 274 | 0 | Complete |
| `Separation/FormulaOps.lean` | 170 | 7 | DNF/CNF + subst |
| `Separation/IntHelpers.lean` | 157 | 0 | Complete |
| `Separation/Duality.lean` | 196 | 0 | Complete |
| `Separation/Distributivity.lean` | 188 | 0 | Complete |
| `Separation/NegationEquiv.lean` | 155 | 0 | Complete |
| `Separation/Eliminations.lean` | 168 | 8 | All 8 cases sorry |
| `Separation/DualEliminations.lean` | 116 | 8 | Blocked on Eliminations |
| `Separation/SeparationThm.lean` | 114 | 5 | Lemmas 10.2.4-10.2.8 |
| `Separation.lean` | 32 | 0 | Hub file |
| `ExpressiveCompleteness.lean` | 120 | 2 | Thm 9.3.1 + 10.2.10 |

**Total**: 1690 LOC across 11 files. 30 sorries remain (down from 32 at first pass).

**Consolidation note**: The plan originally specified 17 files. During implementation, Phases 10-12 and 14 (Lemmas 10.2.4-10.2.8) were consolidated into `SeparationThm.lean`, and Phase 13 (FO infrastructure) was merged into `ExpressiveCompleteness.lean`. Files `SingleSWithU.lean`, `SingleU.lean`, `MultiU.lean`, `NoSWithinU.lean`, `JunctionDepth.lean`, and `FOToTemporal.lean` were never created as separate files.

## Rollback/Contingency

- All new files are in a self-contained directory (`Separation/`) plus one top-level file (`ExpressiveCompleteness.lean`). No existing files are modified except potentially the lakefile imports.
- If the approach fails, delete the entire `Separation/` directory and `ExpressiveCompleteness.lean` with no impact on existing code.
- If elimination cases prove intractable, leave them as sorry and mark Phase 8 as [PARTIAL]; the theorem chain still type-checks.
- If Theorem 9.3.1 requires more FO infrastructure than anticipated, create a separate task for MonadicFO extensions and mark Phase 15 as [BLOCKED].
