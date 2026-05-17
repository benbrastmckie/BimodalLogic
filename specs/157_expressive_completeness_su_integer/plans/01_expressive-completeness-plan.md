# Implementation Plan: Expressive Completeness of {S,U} over Integer Time

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [IN PROGRESS] (Phases 1-5, 7 COMPLETED; Phase 6, 8 PARTIAL; Phases 10-13 SUPERSEDED)
- **Effort**: 36 hours (estimated); ~18 hours spent
- **Dependencies**: Task 155
- **Research Inputs**: specs/157_expressive_completeness_su_integer/reports/01_expressive-completeness-proof.md
- **Artifacts**: plans/01_expressive-completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Formalize the expressive completeness theorem for {Since, Until} over integer time (GHR94 Theorem 10.2.9-10.2.10, Reynolds' Theorem 5). The proof proceeds in two stages: (A) prove every {U,S}-formula is equivalent to a syntactically separated formula over Z via a 4-level nested induction (Lemmas 10.2.1-10.2.8), and (B) show separation implies expressive completeness via Theorem 9.3.1. The formalization builds ~1690 lines across 11 Lean files under `Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and `ExpressiveCompleteness.lean`. Definition of done: `lake build` passes with zero sorries and all theorems fully proved.

### Implementation Deviation: Consolidation

The original plan designed 17 files across 15 phases. During implementation, the proof structure was consolidated:
- **Phases 10-13** (Lemmas 10.2.4-10.2.8, FO-to-Temporal) are trivial corollaries of `all_separable` in `SeparationThm.lean`. No separate files needed.
- **Phase 14** (`SeparationThm.lean`) contains the main inductive proof `all_separable` plus corollary theorem statements. This is where the real remaining work lives (4 sorries in all_past/all_future/untl/snce inductive cases).
- **Phase 15** (`ExpressiveCompleteness.lean`) consolidates FO-to-Temporal infrastructure with the final theorem (1 sorry).
- Total files: 9 in `Separation/` + 1 top-level `ExpressiveCompleteness.lean` = 10 files (vs. 17 planned)

### Current Sorry Inventory (17 total)

| File | Sorries | Notes |
|------|---------|-------|
| Eliminations.lean | 4 | Cases 5-8 (Case 5 is key blocker; 6-8 reduce to it) |
| DualEliminations.lean | 8 | All 8 duals (mechanical from duality once cases proved) |
| SeparationThm.lean | 4 | `all_separable` inductive cases (need all elimination cases) |
| ExpressiveCompleteness.lean | 1 | Final theorem (needs `all_separable`) |

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
| Case 5 (S(a∧U, q∨U)) requires U-chain well-ordering argument | H | H | **ACTIVE BLOCKER**. Correct formula uses S(a, A∨B) not S(a, B) to account for chain-points. Semantic argument with cascading U-witnesses. |
| Substitution bridge between elimination cases and `all_separable` | H | M | This is GHR94's actual Lemmas 10.2.4-10.2.7 content. Must extract maximal U-subterms, substitute fresh atoms, apply eliminations, re-substitute. Non-trivial engineering. |
| `separation_implies_expressiveness` (Thm 9.3.1) is substantial standalone work | M | M | Independent of separation proof. FO induction on quantifier depth. Can be worked in parallel once separation is done. |
| Termination/measure arguments for junction_depth induction | M | L | Direct structural induction on Formula eliminates this risk (already implemented in `all_separable`). |
| Cases 6-8 reduction may be non-trivial in formal detail | M | L | GHR94 confirms they reduce to Cases 1-5 via neg_until_equiv. Cases 2-4 already demonstrate this pattern. |

## Implementation Phases

**Revised Dependency Analysis** (post-consolidation):

| Wave | Work Item | Blocked by | Status |
|------|-----------|------------|--------|
| 1 | Phases 1-5 (definitions, helpers, duality, distributivity, negation equiv) | -- | COMPLETED |
| 2 | Phase 6/7/8: Cases 1-4 (direct + reduction cases) | Wave 1 | COMPLETED |
| 3 | Phase 6: Case 5 (S(a∧U, q∨U) — U-chain well-ordering) | Wave 2 | **NEXT** |
| 4 | Phase 8: Cases 6-8 (reduce to Cases 1-5 via neg_until_equiv) | Wave 3 | blocked |
| 5 | Phase 14: `all_separable` inductive cases (substitution bridge) | Wave 4 | blocked |
| 6 | Phase 15: `separation_implies_expressiveness` (FO induction) | Wave 5 | blocked |

**Critical Path** (9 sorries, ordered):
1. `elim_case_5` → 2. Cases 6-8 → 3. `all_separable` sorry cases → 4. `separation_implies_expressiveness`

**Not on critical path** (can be deferred indefinitely):
- Phase 9 (DualEliminations): 8 sorries, but imported-and-unused by `all_separable`. Dead code for current proof pipeline.

**Key Gap Identified (Research Agent, 2026-05-16)**:
The elimination cases prove existential statements about SPECIFIC patterns: `S(a∧U(A,B), q)` where a, q, A, B are U-free AND S-free. But `all_separable` must handle ARBITRARY formulas. The missing bridge is:
1. Extract maximal U-subterms from under S (replace by fresh atoms)
2. Apply elimination cases to the simplified S-pattern
3. Re-substitute the original U-subterms into the separated result
4. Show the result is still separable (by recursive application / IH)

This "substitution + reduction" step is GHR94's actual proof of Lemmas 10.2.4-10.2.7. It was originally planned as Phases 10-12 with separate files, but since those phases were superseded by consolidation, THIS LOGIC MUST STILL BE IMPLEMENTED inside `all_separable` or as helper lemmas in SeparationThm.lean.

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

### Phase 2: Formula Operations and Integer Helpers [COMPLETED]

**Goal**: Create `Separation/FormulaOps.lean` with substitution, DNF/CNF signatures, and freshness; create `Separation/IntHelpers.lean` with integer-specific lemmas.

**Current state**: Both files fully proved (0 sorry). FormulaOps.lean: 223 LOC. IntHelpers.lean: 157 LOC.

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

**Current state**: `Eliminations.lean` (365 LOC). Cases 1-4 fully proved (sorry-free). Cases 5-8 have 4 remaining `sorry` proofs. Cases 2-4 use the neg_until_equiv/neg_since_equiv reduction approach. Case 5 requires a complex U-chain well-ordering argument with a formula using (A∨B) as the connecting guard.

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

### Phase 7: Elimination Cases 2 and 4 (Negation-Based Cases) [COMPLETED]

**Goal**: Prove Cases 2 and 4 which involve not U(A,B) in the event or guard position.

**Current state**: COMPLETED. Cases 2 and 4 fully proved (sorry-free).

**Tasks**:
- [x] Prove `elim_case_2`: S(a ^ not U(A,B), q) *(completed — reduces via neg_until_equiv to G(¬A) case + Case 1 with ¬A∧¬B, ¬A)*
  - Strategy: apply `neg_until_equiv` to rewrite not U(A,B), then reduce to Case 1 and simpler sub-cases
- [x] Prove `elim_case_4`: S(a, q v not U(A,B)) *(completed — negation via neg_since_equiv, reduces to Case 1 with ¬a∧¬q as event)*
  - Strategy: negate using neg_since_equiv, get S((¬a∧¬q)∧U(A,B), ¬a) which is Case 1
- [x] Both require composing with Lemma 10.2.2 (NegationEquiv)
- [x] Verify `lake build` passes

**Timing**: 3 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` - extend (~200 LOC added)

**Verification**:
- `lake build` passes
- Cases 2 and 4 proved without sorry
- RHS formulas have U(A,B) only at top level

---

### Phase 8: Elimination Cases 3, 6, 7, 8 (Reduction Cases) [PARTIAL: Case 3 proved, Cases 6-8 sorry]

**Goal**: Prove the remaining 4 elimination cases, each reducing to combinations of earlier cases.

**Current state**: Case 3 now PROVED (sorry-free). Cases 5-8 remain (4 sorries in Eliminations.lean). Case 5 requires a U-chain well-ordering argument; Cases 6-8 reduce to Case 5 or earlier cases once Case 5 is available.

**Tasks**:
- [x] Prove `elim_case_3`: S(a, q v U(A,B)) *(completed — negation via neg_since_equiv, reduces to Case 2 with ¬a∧¬q as event)*
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

### Phase 9: Dual Elimination Cases (U out of S -> S out of U) [NOT STARTED — DEAD CODE]

**Goal**: Derive the 8 dual cases (pulling S out from under U) automatically via swap_temporal.

**Current state**: `DualEliminations.lean` (150 LOC). All 8 dual cases have `sorry` proofs. **NOT ON CRITICAL PATH**: Research verification (2026-05-16) confirmed these are imported but never referenced by `all_separable` or any downstream theorem. They can be deferred indefinitely without blocking completion.

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

### Phase 10: Lemma 10.2.4 (Single S with Top-Level U) [SUPERSEDED]

**Goal**: Prove that S(C,F) where U appears only as U(A,B) at top level can be separated into 8 canonical forms.

**Current state**: `SeparationThm.lean` (165 LOC). Defines `all_separable` theorem with base cases proved (atom, bot, imp, box). 4 sorries remain in temporal operator cases (untl, snce, all_past, all_future) — these require substitution-based junction-depth argument. Planned file `SingleSWithU.lean` was not created separately.

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

### Phase 11: Lemma 10.2.5 (Single U Formula, Induction on S-Depth) [SUPERSEDED]

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

### Phase 12: Lemma 10.2.6 (Multiple U Formulas, Count Induction) [SUPERSEDED]

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

### Phase 13: FO-to-Temporal Infrastructure (Theorem 9.3.1 Preparation) [SUPERSEDED]

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

### Phase 14: Separation Theorem via `all_separable` [PARTIAL — KEY BRIDGE NEEDED]

**Goal**: Close the 4 sorry cases in `all_separable` (all_past, all_future, untl, snce). This is the hardest remaining engineering challenge.

**Current state**: `SeparationThm.lean` (165 LOC). Base cases proved (atom, bot, imp, box). 4 sorries in temporal operator cases. The theorem chain `all_separable` → `separation_theorem_int` type-checks.

**THE SUBSTITUTION BRIDGE (critical gap)**:

The elimination cases prove: given specific S-patterns with U-free/S-free arguments, there exists a separated equivalent. But `all_separable` must handle arbitrary formulas like `all_past phi'` where `phi'` is already separated (by IH) but may contain `untl` subterms.

The bridge argument (GHR94 Lemmas 10.2.4-10.2.7 distilled):
1. Given `all_past phi'` where `phi'` is separated (= equivalent to some separated ψ by IH)
2. If ψ is already U-free: `all_past ψ` is separated (done)
3. If ψ contains `untl` at top level: extract maximal U-subterms, replace by fresh atoms
4. Apply elimination cases to each resulting S-pattern
5. Re-substitute original U-subterms
6. Result has smaller junction_depth → apply IH

This requires helper infrastructure:
- [ ] `extract_maximal_U_subterms` (identify U-subformulas not nested under another U/S)
- [ ] `substitute_U_by_atoms` (replace U-subterms by fresh atoms, preserving other structure)
- [ ] `separated_under_subst` (if ψ is separated and we substitute separated formulas for atoms, result is separable)
- [ ] `junction_depth_decreases` (after elimination, junction_depth is strictly smaller)

**Tasks**:
- [ ] Implement the substitution bridge (helpers above)
- [ ] Close `all_past` case: `all_past phi' → ∃ ψ, int_equiv (all_past phi') ψ ∧ separated ψ`
- [ ] Close `all_future` case: symmetric to all_past
- [ ] Close `untl` case: if both args are separated, the Until is separable
- [ ] Close `snce` case: if both args are separated, the Since is separable (uses elimination cases directly)
- [ ] Verify `lake build` passes

**Timing**: 4-6 hours (increased from original 3h estimate due to bridge complexity)

**Depends on**: All 8 elimination cases (Phases 6, 8)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`

**Verification**:
- `lake build` passes
- `all_separable` has no sorry
- `separation_theorem_int` follows as direct application

---

### Phase 15: Theorem 9.3.1 + 10.2.10 (Expressive Completeness) [PARTIAL]

**Goal**: Prove separation implies expressive completeness and combine with the Separation Theorem for the final result.

**Current state**: `ExpressiveCompleteness.lean` (206 LOC). `q_exists_correct` forward direction proved. 1 sorry remains: `separation_implies_expressiveness` inductive step (requires FO induction on quantifier depth with predicate-to-atom substitution).

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

## Artifacts & Outputs (Actual, updated 2026-05-16)

| File | LOC | Sorry | Status |
|------|-----|-------|--------|
| `Separation/Defs.lean` | 274 | 0 | Complete |
| `Separation/FormulaOps.lean` | 223 | 0 | Complete |
| `Separation/IntHelpers.lean` | 157 | 0 | Complete |
| `Separation/Duality.lean` | 196 | 0 | Complete |
| `Separation/Distributivity.lean` | 188 | 0 | Complete |
| `Separation/NegationEquiv.lean` | 155 | 0 | Complete |
| `Separation/Eliminations.lean` | 734 | 4 | Cases 1-4 proved; Cases 5-8 sorry |
| `Separation/DualEliminations.lean` | 150 | 8 | Need S-free witness constructions |
| `Separation/SeparationThm.lean` | 165 | 4 | `all_separable` temporal operator cases |
| `Separation.lean` | 32 | 0 | Hub file |
| `ExpressiveCompleteness.lean` | 206 | 1 | Thm 9.3.1 inductive step |

**Total**: 2480 LOC across 11 files. **17 sorries remain**.

**Proved theorems**: Cases 1-4 (Eliminations), all distributivity, all duality, negation equivalences, DNF/CNF, freshness, integer well-ordering, `q_exists_correct`.

**Consolidation note**: The plan originally specified 17 files. During implementation, Phases 10-12 and 14 (Lemmas 10.2.4-10.2.8) were consolidated into `SeparationThm.lean`, and Phase 13 (FO infrastructure) was merged into `ExpressiveCompleteness.lean`. Files `SingleSWithU.lean`, `SingleU.lean`, `MultiU.lean`, `NoSWithinU.lean`, `JunctionDepth.lean`, and `FOToTemporal.lean` were never created as separate files.

## Rollback/Contingency

- All new files are in a self-contained directory (`Separation/`) plus one top-level file (`ExpressiveCompleteness.lean`). No existing files are modified except potentially the lakefile imports.
- If the approach fails, delete the entire `Separation/` directory and `ExpressiveCompleteness.lean` with no impact on existing code.
- If elimination cases prove intractable, leave them as sorry and mark Phase 8 as [PARTIAL]; the theorem chain still type-checks.
- If Theorem 9.3.1 requires more FO infrastructure than anticipated, create a separate task for MonadicFO extensions and mark Phase 15 as [BLOCKED].
