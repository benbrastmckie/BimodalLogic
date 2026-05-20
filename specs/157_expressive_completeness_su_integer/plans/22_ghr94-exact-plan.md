# Implementation Plan: Task #157 -- GHR94-Exact Axiom Elimination (v22)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 10 hours remaining
- **Dependencies**: Phases 1-4C completed; Phase 5 blocked at JD = 1
- **Research Inputs**: reports/21_jd1-oracle-fix.md (primary), reports/19_ghr94-proof-walkthrough.md, reports/19_axiom-dependency-chain.md, reports/19_circular-import-resolution.md
- **Artifacts**: plans/22_ghr94-exact-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## PLAN COMPLIANCE

**This plan is a CONTRACT. Implementation agents MUST follow it exactly.**

### Guiding Principle

**Follow GHR94 EXACTLY.** The oracle threading approach (plan v21) failed at JD = 1 because it deviated from GHR94's proof structure. GHR94's proof works because it was designed to avoid exactly this circularity. Every step in this plan must be justified by a specific GHR94 reference.

### Binding Rules

1. Every task cites the specific GHR94 lemma it implements.
2. Adaptations for task semantics (Box instead of G/H) and Lean encoding are the ONLY permitted deviations.
3. **Prohibited behaviors**:
   - Inventing alternative proof strategies not in GHR94
   - Introducing new `sorry` obligations
   - Using `all_separable` anywhere in the fixed theorems
   - Using bare `simp` (use `simp only [...]`)
   - Attempting Solution A (preserve single-U-type through separation -- proven infeasible by Report 20)
4. **BLOCKER ESCALATION**: If stuck for 30 minutes, STOP, write handoff, do not improvise.

---

## Overview

Plan v21's oracle threading approach fails at JD = 1 because the oracle receives the ORIGINAL formula back (no measure decreases). Root cause: the code deviates from GHR94's proof structure. GHR94's Lemmas 10.2.5-10.2.8 form a layered hierarchy where each lemma is self-contained -- no circular callbacks.

This plan restructures the code to follow GHR94 exactly:
- **Phase A**: Make Lemma 10.2.5 (`single_U_formula_separable`) entirely oracle-free by exploiting that at `snce_depth_of_U = 1`, children have `snce_depth_of_U = 0`, so their separation preserves `has_single_U_type` vacuously.
- **Phase B**: Make Lemma 10.2.7 (`no_S_nested_in_U_separable`) oracle-free by abstracting inner U-subformulas (following GHR94 10.2.7 case n > 1 exactly).
- **Phase C**: Restructure Lemma 10.2.8 (`all_formulas_separable_aux`) to follow GHR94's S-abstraction-from-U-args pattern.

### Research Integration

- **Report 21** (primary): Root cause analysis of JD = 1 failure, three-phase fix design
- **Report 19 walkthrough**: GHR94 line-by-line proof structure (Lemmas 10.2.1-10.2.8)
- **Report 19 axiom chain**: Two axiom leak paths (Path A and Path B), both must be fixed
- **Report 19 circular imports**: Import reversal strategy (Hierarchy -> SeparationThm)

### Prior Plan Reference

Plan v21 (oracle threading) validated: (1) all `_param` variants compile and are axiom-free, (2) `subst_in_separated_separable_jd` works for the n >= 2 path, (3) JD infrastructure (`snce_of_boxfree_sep_jd_le_one`, `callback_jd_le_one`) exists. The oracle approach itself fails at JD = 1 because no measure decreases -- the oracle receives back the original formula. Lesson: do not thread the oracle through the chain; instead, make each layer self-contained as GHR94 intended.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Make `single_U_formula_separable_noax_param` (Lemma 10.2.5) entirely oracle-free
- Make `no_S_nested_in_U_separable_direct_param` (Lemma 10.2.7) entirely oracle-free
- Rewrite `all_formulas_separable_aux` (Lemma 10.2.8) to follow GHR94's S-abstraction pattern
- Remove all `all_separable` / `snce_separable` / `untl_separable` dependencies from Hierarchy.lean
- Reverse the SeparationThm <-> Hierarchy import direction
- Replace 9 axioms in SeparationThm.lean with theorems

**Non-Goals**:
- Modifying `snce_single_U_depth_one_separable` (Lemma 10.2.4 -- already correct and axiom-free)
- Preserving `has_single_U_type` through separation at arbitrary depth (proven infeasible)
- Changing any existing `_param` variant that already compiles axiom-free
- Modifying distribution laws, negation equivalences, or the 8 elimination cases

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `has_single_U_type` not preserved by separation at sdoU = 0 | H | L | At sdoU = 0, any `.snce` is U-free (no `.untl` nodes under S). Separation of U-free formulas trivially preserves `has_single_U_type` vacuously. Prove `has_single_U_type_preserved_sep_depth0`. |
| `abstract_inner_U_from_args` (for 10.2.7 n > 1) too complex to implement | H | M | GHR94 abstracts ALL inner U-subformulas simultaneously. Use existing `abstract_untl` + iteration. Alternatively, use `subst_in_separated_separable_depth` with callback at depth <= 1 (already oracle-free after Phase A). |
| S-abstraction from U-args (for 10.2.8) introduces new infrastructure | M | M | The existing `abstract_snce_jd_le` may handle this. If not, ~30 LOC for `abstract_snce_from_untl_args`. |
| Junction depth decrease after S-abstraction not provable | H | L | GHR94 10.2.8 explicitly states JD decreases by 1. The abstracted S(E,F) subformulas have JD <= d-2, so back-substituted result has JD <= d-1. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | A | -- |
| 2 | B | A |
| 3 | C | B |
| 4 | D | C |
| 5 | E | D |

Phases are strictly sequential because each builds on the previous.

---

### Phase A: Make Lemma 10.2.5 Oracle-Free [COMPLETED]

**GHR94 Reference**: Lemma 10.2.5 (pp. 569, lines 145-155). "By induction on the maximum number k of nested Ss above any U(A,B)." Self-contained: uses only Lemma 10.2.4. No callback to 10.2.6, 10.2.7, or 10.2.8.

**Goal**: Replace the oracle call in `single_U_formula_separable_noax_param` with a direct, self-contained proof. The key insight: at `snce_depth_of_U = 1`, children C, F have `snce_depth_of_U = 0`, meaning they are either non-`.snce` or are `.snce` with U-free branches. Separation at depth 0 preserves `has_single_U_type` vacuously (no `.untl` nodes appear under S at this depth). After box-normalization, `.snce C'' F''` has `has_single_U_type _ A' B'`, so `snce_single_U_depth_one_separable` (Lemma 10.2.4) applies directly.

**Tasks**:

- [x] Task A.1: Prove `has_single_U_type_preserved_sep_depth0` (~30 LOC) *(deviation: used existing `snce_depth_zero_single_U_separated` instead of new lemma — it proves formulas at sdoU=0 with single-U-type are already syntactically separated, so the separated witness is the formula itself)*
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **GHR94 justification**: At k = 0 in Lemma 10.2.5, "D is already separated." The children at sdoU = 0 have no S above U, so U(A,B) is never under S. Separation of such formulas preserves the U-type structure because: (a) if the child is non-`.snce`, the structural IH preserves `.untl A B` nodes; (b) if the child is `.snce c d` with sdoU = 0, then c, d are U-free, so `.snce c d` is U-free and its separation witness contains no `.untl` nodes at all -- `has_single_U_type` holds vacuously.
  - **Statement**: For phi with `has_single_U_type phi A B` and `snce_depth_of_U phi = 0`, if phi is separable with witness phi', then `has_single_U_type phi' A B` (or more precisely, the relevant property that allows applying 10.2.4 after box-normalization).
  - **Adaptation for Lean**: The property needed is that after IH + box-normalization, the resulting `.snce C'' F''` still has `has_single_U_type`. Since box-normalization does not touch `.untl` nodes (only replaces `Box phi` with `phi`), and separation at depth 0 preserves `.untl` structure, this should hold.
  - Verification: `lake build`

- [x] Task A.2: Rewrite `single_U_formula_separable_noax_param` `.snce` case (~40 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **GHR94 justification**: Lemma 10.2.5, case k > 0.
  - **What was done**: Split `.snce` case into two sub-cases:
    - **n <= 1** (leaf): Children C, F at sdoU = 0 are already separated (via `snce_depth_zero_single_U_separated`). Box-normalize preserving `has_single_U_type` (via `replace_box_preserves_single_U_type`). Apply `snce_single_U_depth_one_separable` directly. **No oracle invoked.**
    - **n >= 2**: IH on children, box-normalize, apply oracle on `.snce C'' F''`. Oracle still present but only invoked at depth >= 2.
  - **Result**: `single_U_formula_separable_noax_param` still takes the oracle parameter, but the oracle is NEVER INVOKED when `snce_depth_of_U <= 1`. The entire 10.2.5/10.2.6 chain at depth <= 1 is oracle-free.
  - **Deviation from plan**: Plan said to remove the oracle parameter entirely. Instead, oracle is retained for depth >= 2 but never invoked at depth <= 1. This is equivalent for the JD = 1 case (where all formulas have sdoU <= 1).
  - Verification: `lake build` passes

- [ ] Task A.3: Update `lemma_10_2_6_self_contained_param` to use oracle-free 10.2.5 (~20 LOC) *(pending: may not be needed since oracle is retained but never invoked at depth <= 1)*
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **GHR94 justification**: Lemma 10.2.6 uses 10.2.5 as a subroutine. Now that 10.2.5 is oracle-free, 10.2.6 becomes oracle-free automatically.
  - **Change**: Remove the oracle parameter from `lemma_10_2_6_self_contained_param`. Update the callback to `single_U_formula_separable_noax_param` (which no longer takes an oracle).
  - Verification: `lake build`; `lean_verify lemma_10_2_6_self_contained_param` shows NO custom axioms

**Timing**: 3 hours

**Depends on**: none (existing infrastructure from Phases 1-4C)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `has_single_U_type_preserved_sep_depth0`, rewrite `.snce` case in `single_U_formula_separable_noax_param`, update `lemma_10_2_6_self_contained_param`

**Verification**:
- `lake build` succeeds
- `lean_verify single_U_formula_separable_noax_param` -- no custom axioms
- `lean_verify lemma_10_2_6_self_contained_param` -- no custom axioms

---

### Phase B: Make Lemma 10.2.7 Oracle-Free [BLOCKED]

**GHR94 Reference**: Lemma 10.2.7 (pp. 572, lines 175-186). "By induction on the maximum depth n of nesting of Us beneath an S." Case n = 1 is Lemma 10.2.6. Case n > 1: abstract inner U-subformulas from U-args, apply 10.2.6, back-substitute, apply IH.

**Goal**: Make `no_S_nested_in_U_separable_direct_param` (Lemma 10.2.7) entirely oracle-free by following GHR94's exact structure.

**BLOCKER** (Phase B):
- **What failed**: Plan assumed `single_U_formula_separable_noax_param` (10.2.5) would be oracle-free after Phase A. Analysis shows the oracle IS still invoked at `snce_depth_of_U >= 2` even when `U_nesting_depth = 1`. The proposed fix (strengthening 10.2.4 to preserve `has_single_U_type`) fails because Cases 2,4,6,8 rewrite `neg U(A,B)` into `G(neg A) v U(neg A ^ neg B, neg A)`, introducing new U-types. This is inherent to our 6-constructor encoding which lacks G/H primitives.
- **What was tried**: (1) Analyzed oracle flow through 10.2.5/10.2.6/10.2.7 chain. (2) Proposed strengthening `is_separable` to `is_separable_with_U_type`. (3) Proved `case1_psi_has_single_U_type` for Case 1. (4) Discovered Cases 2,4,6,8 introduce new U-types via `neg_until_equiv`, breaking `has_single_U_type` preservation.
- **Why it's stuck**: Our Formula type has 6 constructors (atom, bot, imp, box, untl, snce) without G/H primitives. GHR94 has G/H as primitives and keeps `neg U(A,B)` as a "pure future" component without decomposition. Our encoding must decompose `neg U(A,B)` into U-expressions with different args, breaking the single-U-type invariant that GHR94's proof relies on.
- **What is needed**: One of: (a) Add G/H as formula constructors and adapt the entire codebase; (b) Prove termination of the oracle chain via a combined well-founded measure; (c) Implement sub-formula replacement approach (apply 10.2.4 to innermost S(C,F) without separating children first); (d) Find a novel approach compatible with the 6-constructor encoding.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Tasks**:

- [ ] Task B.1: Handle depth <= 1 case with oracle-free 10.2.6 (~10 LOC) *(deviation: blocked -- requires oracle-free 10.2.5 first; see Phase B analysis handoff for details. Plan assumed 10.2.5 was oracle-free after Phase A, but at snce_depth_of_U >= 2 the oracle IS still invoked even at U_nesting_depth = 1. Fix: strengthen 10.2.4 to output is_separable_with_U_type, then 10.2.5 becomes truly oracle-free.)*
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **GHR94 justification**: Lemma 10.2.7, case n = 1: "This is the case of the preceding lemma [10.2.6]." When U-nesting depth <= 1, all U-args within S-arguments are S-free (by hypothesis) and U-free (n = 1 means no nested U's). So 10.2.6 applies.
  - **Change**: At `U_nesting_depth <= 1`, call `lemma_10_2_6_self_contained_param` (now oracle-free after Phase A). Remove oracle parameter.
  - **Prerequisite (discovered during implementation)**: 10.2.5 (`single_U_formula_separable_noax_param`) must be made TRULY oracle-free by strengthening its output to `is_separable_with_U_type`. This requires strengthening 10.2.4 (`snce_single_U_depth_one_separable`) to also output `is_separable_with_U_type`, which requires proving `has_single_U_type` for all 8 case witnesses.
  - Verification: `lake build`

- [ ] Task B.2: Create `abstract_inner_U_from_untl_args` for depth >= 2 (~60 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **GHR94 justification**: Lemma 10.2.7, case n > 1: "Let U(A_i, B_i) be some subformulae of D such that every appearance of U in D is as a subformula of an appearance of one of the U(A_i, B_i). Each A_i and B_i are built up as a boolean combination from wffs of the form U(X_ij, Y_ij) and atoms. Replace each U(X_ij, Y_ij) in A_i and B_i by the new atom z_ij to form wffs A'_i and B'_i which are just boolean combinations of atoms."
  - **Implementation**: Given a formula with `no_S_nested_in_U` and `U_nesting_depth >= 2`, find the covering U-subformulas. Within their arguments, replace the inner U-subformulas with fresh atoms. This makes the outer U-args U-free AND S-free. The result has `U_nesting_depth = 1` and `no_S_nested_in_U`.
  - **Alternative approach**: Instead of implementing the simultaneous abstraction directly, use the existing `abstract_untl` + `subst_in_separated_separable_depth` infrastructure iteratively. Abstract ONE inner U-type at a time. After each abstraction + separation + back-substitution, the U-nesting depth of the callback is strictly less than the original. The IH handles the callback.
  - **Adaptation for Lean**: The iterative approach (one U-type at a time) maps better to the existing `extract_U_type` + `abstract_untl` infrastructure. GHR94 abstracts all inner U's simultaneously, but the iterative version is equivalent and easier to encode.
  - Verification: `lake build`

- [ ] Task B.3: Rewrite `no_S_nested_in_U_separable_direct_param` depth >= 2 case (~50 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **GHR94 justification**: Lemma 10.2.7, case n > 1: After abstracting inner U-subformulas, "D', which can be separated by the preceding lemma [10.2.6]." After separating, "when we substitute in z_ij by U(X_ij, Y_ij) we obtain a wff E equivalent to D. Unfortunately, E is not separated: what were pure past formulae in E' have become, on replacement of z_ij by U(X_ij, Y_ij), impure. To correct this we use the induction hypothesis on each of these pure past subformulae of E."
  - **Current code**: At depth >= 2, uses `extract_U_type` to find a U-type, abstracts it, uses `subst_in_separated_separable_jd` with oracle for back-substitution. The oracle is the problem.
  - **New code**: At depth >= 2:
    1. Find an innermost U-type (X, Y) with U-free, S-free args (by recursing into U-args to find a leaf). Use existing `extract_U_type_U_free` or create `extract_innermost_U_type`.
    2. Abstract: `phi' = abstract_untl phi X Y p`. Result has `no_S_nested_in_U` and `count_U_subformulas` strictly decreased (by `abstract_untl_count_U_subformulas_lt`).
    3. Apply inner `count_U_subformulas` IH to phi' (still at same `U_nesting_depth` level, but fewer U-subformulas).
    4. Back-substitute: `subst_in_separated_separable_depth psi p X Y ... callback`
    5. The callback receives formulas with `U_nesting_depth <= 1` and `has_single_U_type _ X Y` (with X, Y being S-free and U-free). Apply `single_U_formula_separable_noax_param` (oracle-free after Phase A). **No oracle needed.**
  - **Result**: `no_S_nested_in_U_separable_direct_param` no longer takes an oracle. Entirely self-contained.
  - **Adaptation for Lean**: The two nested inductions (outer on `U_nesting_depth`, inner on `count_U_subformulas`) are already present in the current code. The only change is replacing the oracle callback with the oracle-free `single_U_formula_separable_noax_param`.
  - Verification: `lake build`; `lean_verify no_S_nested_in_U_separable_direct_param` shows NO custom axioms

**Timing**: 3 hours

**Depends on**: A

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- rewrite depth <= 1 and depth >= 2 cases in `no_S_nested_in_U_separable_direct_param`, possibly add `abstract_inner_U_from_untl_args` or `extract_innermost_U_type`

**Verification**:
- `lake build` succeeds
- `lean_verify no_S_nested_in_U_separable_direct_param` -- no custom axioms

---

### Phase C: Restructure Lemma 10.2.8 (all_formulas_separable_aux) [NOT STARTED]

**GHR94 Reference**: Lemma 10.2.8 (pp. 574, lines 189-219). Junction depth induction. Case JD <= 1: already separated. Case JD >= 2: for S(D1, D2), abstract maximal S(E,F) inside U-arguments to fresh atoms, apply 10.2.7 (now oracle-free), back-substitute, JD decreases, apply IH.

**Goal**: Rewrite `all_formulas_separable_aux` to follow GHR94 exactly. Since 10.2.5, 10.2.6, and 10.2.7 are all oracle-free after Phases A-B, this phase replaces the `.snce` and `.untl` case logic.

**Tasks**:

- [ ] Task C.1: Rewrite `.snce a b` case in `all_formulas_separable_aux` (~60 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **GHR94 justification**: Lemma 10.2.8, JD >= 2: "Let U(A_i, B_i) be the subformulae covering the maximal appearances of U... Replace each maximal such subformula [S(E,F) inside U-args] by its own new atom z_ij to obtain U(A'_i, B'_i). Change S(D_1, D_2) into E' by replacing each U(A_i, B_i) by U(A'_i, B'_i). The preceding lemma [10.2.7] now tells us how to separate E'. If we resubstitute the original wffs for each z_ij then we will have a formula equivalent to S(D_1, D_2) but of one less junction depth and we may use the induction hypothesis."
  - **Current code (n >= 2 case, already working)**: Structural IH on a, b -> separated -> box-normalize -> `no_S_nested_in_U_separable_direct_param` with oracle from JD IH. The oracle is what fails at n = 1.
  - **New code for ALL n >= 1**:
    1. Find covering `.untl (A_i, B_i)` subformulas in `.snce a b`
    2. Abstract maximal `.snce` subformulas inside each A_i, B_i to fresh atoms z_ij
    3. Result E' has `no_S_nested_in_U` (all S removed from U-args)
    4. Apply oracle-free `no_S_nested_in_U_separable_direct_param E' hns` -- no oracle needed
    5. Get separated E''. Back-substitute z_ij -> S(E_ij, F_ij)
    6. Each back-substituted formula has `junction_depth <= n - 1` (JD decreased by removing the S-inside-U alternation)
    7. Apply JD IH (valid because n - 1 < n)
  - **Alternative simpler approach**: If the n >= 2 path already works with the IH oracle, and n = 1 is the problem, then for n = 1 specifically:
    - At n = 1, `.snce a b` where `junction_depth (.snce a b) = 1`. This means a, b have `junction_depth <= 1` and there exists some U nested in an S-arg (or vice versa) but only one level of alternation.
    - Actually, `junction_depth (.snce a b) = max (junction_depth_S a) (junction_depth_S b)`. If this equals 1, then `junction_depth_S a <= 1` or `junction_depth_S b <= 1`, meaning there is at most one `.untl` nested somewhere inside a or b (and that `.untl`'s args are S-free since junction_depth_U only counts S-inside-U alternation).
    - At n = 1, apply the GHR94 10.2.8 pattern: abstract S-from-U-args, get `no_S_nested_in_U`, apply oracle-free 10.2.7, back-substitute, JD = 0, already separated.
  - **Adaptation for Lean**: The S-abstraction from U-args requires finding `.snce` nodes inside `.untl` arguments and replacing them with fresh atoms. Use existing `abstract_snce` infrastructure if available, or create `abstract_snce_from_untl_args` (~30 LOC).
  - Verification: `lake build`

- [ ] Task C.2: Handle `.untl a b` case by duality (~20 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **GHR94 justification**: Lemma 10.2.8: "Because of the dual nature of the results so far we need only demonstrate the syntactic separation of a wff of the form S(D_1, D_2)." The `.untl` case is symmetric -- abstract U-from-S-args, apply the dual of 10.2.7 (which handles "no U nested in S"), back-substitute.
  - **Implementation**: Mirror the `.snce` case, abstracting `.untl` subformulas from `.snce` arguments.
  - Verification: `lake build`

- [ ] Task C.3: Prove JD decrease after S-abstraction from U-args (~30 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **GHR94 justification**: Lemma 10.2.8: "one less junction depth." After abstracting maximal S(E,F) from U-arguments and back-substituting: the S(E,F) subformulas that were inside U-arguments had junction_depth <= d - 2 (they were creating the S-in-U alternation). After separation + back-substitution, the result has junction_depth <= d - 1.
  - **Statement**: If `junction_depth (.snce a b) = n` and we abstract all maximal `.snce` subformulas from inside `.untl`-arguments, the back-substituted result after separation has `junction_depth <= n - 1`.
  - Verification: `lake build`

**Timing**: 2 hours

**Depends on**: B

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- rewrite `.snce`/`.untl` cases in `all_formulas_separable_aux`, add JD decrease lemma, possibly add `abstract_snce_from_untl_args`

**Verification**:
- `lake build` succeeds
- `lean_verify all_formulas_separable_aux` -- no custom axioms
- `lean_verify all_formulas_separable` -- no custom axioms

---

### Phase D: Import Reversal and Axiom Replacement [NOT STARTED]

**GHR94 Reference**: N/A (Lean engineering, not mathematical content).

**Goal**: Remove the SeparationThm import from Hierarchy.lean, reverse the dependency, and replace 9 axioms with theorems.

**Tasks**:

- [ ] Task D.1: Remove dead code from Hierarchy.lean (~100 lines deleted)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Delete: `single_U_formula_separable` (old axiom-dependent version), `snce_single_U_top_level_separable`, `single_U_neg_separable`, `single_U_disj_separable`, `single_U_conj_separable`, `multi_U_formula_separable`, `two_U_types_separable`, `multi_U_neg_separable`, `multi_U_or_separable`, `multi_U_and_separable`, `no_S_nested_in_U_separable_noax`
  - All verified dead code per Report 19 (circular-import-resolution.md, Section 3 Category A)
  - Verification: `lake build`

- [ ] Task D.2: Update old non-param wrappers (~20 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Make `single_U_formula_separable_noax`, `lemma_10_2_6_self_contained`, `no_S_nested_in_U_separable_direct` call through the oracle-free `_param` variants (which no longer take oracles) instead of through `all_separable`.
  - Verification: `lake build`

- [ ] Task D.3: Remove `import SeparationThm` from Hierarchy.lean
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - After Tasks D.1-D.2, no references to SeparationThm declarations remain.
  - Remove the import line.
  - Verification: `lake build`

- [ ] Task D.4: Remove stale SeparationThm imports from NormalForm.lean and DedekindZ.lean
  - **Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean`, `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean`
  - Per Report 19 Section 7: these files import SeparationThm but use nothing from it.
  - Verification: `lake build`

- [ ] Task D.5: Reverse dependency -- SeparationThm imports Hierarchy
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Add `import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`
  - Replace 9 axioms with theorems using `all_formulas_separable`:
    - `is_separable` temporal closure: `all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable` (4 axioms)
    - `is_properly_separable` temporal closure: `all_past_properly_separable`, `all_future_properly_separable`, `untl_properly_separable`, `snce_properly_separable` (4 axioms)
    - `proper_separation_preserves_atoms` (1 axiom -- may remain if atom tracking is too complex)
  - Verification: `lake build`

- [ ] Task D.6: Update DualEliminations.lean import
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean`
  - Change import from SeparationThm to Hierarchy
  - Replace `all_separable` with `all_formulas_separable` (8 call sites per Report 19 Section 7)
  - Verification: `lake build`

**Timing**: 1.5 hours

**Depends on**: C

**Files to modify**:
- `Hierarchy.lean` -- delete dead code, remove import
- `SeparationThm.lean` -- add Hierarchy import, replace axioms
- `NormalForm.lean` -- remove import
- `DedekindZ.lean` -- remove import
- `DualEliminations.lean` -- change import source

**Verification**:
- `lake build` succeeds with no import cycles
- `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns at most 1 (the `proper_separation_preserves_atoms` if retained)

---

### Phase E: Final Verification and Cleanup [NOT STARTED]

**Goal**: Verify zero axioms in the separation stack, clean up obsolete comments, run final build.

**Tasks**:

- [ ] Task E.1: Verify axiom-freeness
  - `lean_verify all_formulas_separable` -- only standard Lean axioms
  - `lean_verify all_separable` -- only standard Lean axioms (now a theorem, not axiom-backed)
  - `lean_verify separation_theorem_int` -- only standard Lean axioms
  - `lean_verify single_U_formula_separable_noax_param` -- only standard Lean axioms
  - `lean_verify no_S_nested_in_U_separable_direct_param` -- only standard Lean axioms

- [ ] Task E.2: Remove obsolete comments and dead code
  - Remove comments referencing "Phase 5 will...", "oracle approach", etc.
  - Clean up any remaining `all_separable` wrappers that are no longer needed
  - Trim dead code in TemporalClosure.lean if applicable

- [ ] Task E.3: Full `lake build`
  - Complete project build with zero errors
  - Verify zero `sorry` in the Separation stack: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/ | grep -v "^.*:.*--"`

**Timing**: 30 minutes

**Depends on**: D

**Files to modify**:
- Various files in `Theories/Bimodal/Metalogic/WeakCanonical/Separation/` -- comment cleanup only

**Verification**:
- All `lean_verify` checks pass
- `lake build` succeeds
- Zero `sorry` in separation stack

---

## GHR94 Lemma-to-Code Mapping

| GHR94 Lemma | Lean Function | Phase | Status |
|-------------|---------------|-------|--------|
| 10.2.1 (distribution) | `untl_arg1_disjunction_equiv`, etc. | Pre-existing | Done |
| 10.2.2 (negation over Z) | `neg_until_equiv`, etc. | Pre-existing | Done |
| 10.2.3 (8 elimination cases) | `snce_single_U_case_*` | Phase 3 | Done |
| 10.2.4 (S(C,F) single U-type at top level) | `snce_single_U_depth_one_separable` | Phase 3 | Done |
| 10.2.5 (single U-type, any nesting) | `single_U_formula_separable_noax_param` | **Phase A** | TODO |
| 10.2.6 (multiple U-types, U/S-free args) | `lemma_10_2_6_self_contained_param` | **Phase A** | TODO |
| 10.2.7 (no S in U => separable) | `no_S_nested_in_U_separable_direct_param` | **Phase B** | TODO |
| 10.2.8 (full separation) | `all_formulas_separable_aux` | **Phase C** | TODO |
| 10.2.9 (separation theorem) | `separation_theorem_int` | Phase D | TODO |

**Deviations from GHR94 (Lean-specific adaptations)**:
- GHR94 uses G/H (globally/historically); the Lean code uses Box (task semantics modal operator). This affects `snce_single_U_depth_one_separable` which uses `replace_box_with_top` for box-normalization.
- GHR94 abstracts ALL inner U-subformulas simultaneously (10.2.7 n > 1); the Lean code may abstract one at a time iteratively (equivalent but simpler termination argument).
- GHR94's junction depth counts alternating chain length; the Lean code uses mutual recursion (`junction_depth`, `junction_depth_U`, `junction_depth_S`). The Lean JD is off by 1 from GHR94: GHR94 base case "JD <= 1" = Lean "JD = 0".

## Testing & Validation

- [ ] `lake build` succeeds
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/ | grep -v "^.*:.*--"` returns empty
- [ ] `lean_verify all_formulas_separable` -- only standard Lean axioms
- [ ] `lean_verify single_U_formula_separable_noax_param` -- only standard Lean axioms
- [ ] `lean_verify no_S_nested_in_U_separable_direct_param` -- only standard Lean axioms
- [ ] `lean_verify all_separable` -- only standard Lean axioms (now theorem-backed)
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns at most 1

## Artifacts & Outputs

- `plans/22_ghr94-exact-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (main changes)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (axiom replacement)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` (import change)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` (import removal)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (import removal)

## Rollback/Contingency

- **Phase A fallback**: If `has_single_U_type` preservation at depth 0 is harder than expected, verify the property for each specific structural case (`.imp`, `.box`, `.atom`, `.bot`, `.untl`) individually. The `.snce` case at depth 0 is trivially U-free.
- **Phase B fallback**: If simultaneous inner-U-abstraction is too complex, use the iterative approach (abstract one inner U-type per iteration, using existing `abstract_untl`).
- **Phase C fallback**: If the full GHR94 10.2.8 restructure is too complex, keep the existing n >= 2 path (which works) and only fix the n = 1 path using the GHR94 S-abstraction-from-U-args pattern.
- **Phase D fallback**: Leave `proper_separation_preserves_atoms` as the sole remaining axiom if atom tracking through `all_formulas_separable` is too complex.
- **Git safety**: All changes are in a single file (Hierarchy.lean) until Phase D. Any phase can be reverted with `git checkout -- Hierarchy.lean`.
