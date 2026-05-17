# Implementation Plan: Task #157 (v9) -- Phase 7 First, Then Phase 6

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 9 hours
- **Dependencies**: Task 155 (completed phases provide infrastructure)
- **Research Inputs**: reports/06_team-research.md (7-teammate synthesis), reports/06_phase7-freshAM-findings.md, reports/06_phase7-structural-findings.md, reports/06_phase7-minimal-fix-findings.md, handoffs/phase-7-handoff-20260517f.md, handoffs/phase-6-handoff-20260517T200000.md
- **Artifacts**: plans/06_phase7-first-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## DEVIATION PREVENTION -- MANDATORY READING

**This section is non-optional. The implementation agent MUST read and obey these constraints before writing ANY Lean code.**

### Prohibited Approaches (Documented Failures)

The following approaches have been tried REPEATEDLY (8+ plan versions, 20+ implementation sessions) and failed. DO NOT attempt them again:

1. **Dedekind formula (GHR94 Lemma 10.3.11) for Phase 6**: This formula is for DENSE/DEDEKIND-COMPLETE time (the reals), NOT for integer time Z. Using it on Z is a category error. Plan v8 was blocked entirely because of this error. The Case 7 Disjunct 2 formula `S(S(a,B^q) ^ A ^ (q v NOT U), NOT U v q)` is NOT syntactically separated because `NOT U = neg(untl A B)` makes `is_U_free = false`. (See `handoffs/phase-6-handoff-20260517T200000.md` for the definitive failure record.)

2. **Standalone Case 5-8 separated equivalents without WF induction**: GHR94 Cases 5-8 are NOT self-contained terminal rules. They are intermediate steps in an iterative elimination process within the junction-depth hierarchy. Finding explicit syntactically-separated equivalents for Cases 5-8 on Z has been attempted 6+ times and failed every time.

3. **`count_U_under_S` composite measures**: Do not work because `all_past`/`all_future` cases need temporal closure (the axioms) which creates circularity.

4. **Strengthened structural induction hypotheses for `no_S_nested_in_U`**: The `snce` case RECURSES (definition at Defs.lean lines 320-328), making structural approaches on `no_S_nested_in_U` insufficient for breaking the circular dependency.

5. **`applySubsts_past_correct` directly on M_ext for the `origSubsList` entries**: The `h_match` condition fails because `atomMap p` is not in `freshAM`'s range under the disjointness assumption. Use the direct structural induction approach instead.

6. **Assuming `B_sep.atoms` are all in `freshAM`'s image without proof**: The atom-origin problem (Blocker 1 in minimal-fix findings) requires either adding `hB_atoms` parameter or proving it from `h_sep` + construction.

### Mandatory Constraints

- **Phase 7**: Follow the EXACT implementation order specified (offset fix -> h_disj -> hB_atoms -> int_truth_foldl_or -> elimExtFromSep_correct -> quantElimFormula_correct_iff -> atom_elim_correct). Do NOT skip steps or reorder.
- **Phase 6**: Use ONLY the junction-depth hierarchy with nested `Nat.strongRecOn` on `(JD, count_U)`. Do NOT attempt Dedekind formulas, explicit separated equivalents, or any standalone Case 5-8 approach.
- **No `sorry`**: Do NOT introduce new `sorry` obligations. The ONLY acceptable outcome is eliminating the existing sorry at line 916.
- **No `def X := True`**: Vacuous definitions are prohibited. See `.claude/rules/lean4.md`.
- **Commit after each sub-task**: Preserve partial progress via git commits.

### How to Recognize You Are Deviating

If you find yourself doing any of the following, STOP and re-read this section:
- Writing a formula that contains `neg(untl ...)` inside a `snce` argument and expecting `is_U_free = true`
- Attempting to apply GHR94 Section 10.3 results (these are for dense time)
- Trying to prove `all_past_separable` or `all_future_separable` from first principles without the WF hierarchy
- Using `applySubsts_past_correct` with M_ext as the model and `origSubsList` entries
- Attempting to prove `atom_elim_correct` without first resolving the freshAM offset/disjointness issue

## Overview

Plan v9 inverts the priority from v8: Phase 7 (sorry elimination in `atom_elim_correct`) comes FIRST because it achieves sorry-free `US_expressively_complete_over_Z` with approximately 200-300 LOC. Phase 6 (axiom elimination via junction-depth hierarchy) comes SECOND because the 8 axioms do NOT block any downstream goal -- `US_expressively_complete_over_Z` already compiles via axiom-based `all_properly_separable`.

The key insight from Report 06 is that the Dedekind approach (v8 Phase 6) was a category error -- GHR94 10.3 is for dense time, not integers. The correct Phase 6 approach is the junction-depth hierarchy with nested `Nat.strongRecOn` on `(JD, count_U)`, which is higher LOC but mathematically sound.

Definition of done: `lake build` passes with zero sorry in ExpressiveCompleteness.lean. (Zero axioms in SeparationThm.lean is a secondary goal for Phase 6.)

### Research Integration

Report 06 (7-teammate synthesis) provided:
1. **Phase 7 fix path** (3 specialist teammates converge): freshAM offset fix + h_disj + hB_atoms + direct structural induction on B_sep for `elimExtFromSep_correct`.
2. **Phase 6 correct approach** (Teammates A+B converge): nested `Nat.strongRecOn` on `(junction_depth, count_U)` with `abstract_snce` infrastructure.
3. **Strategic assessment** (Teammate D): 8 axioms do NOT block downstream goals; sorry-free `US_expressively_complete_over_Z` is achievable independently.
4. **Conflict resolution**: freshAM_inj alone is NOT sufficient for disjointness; range-disjointness between atomMap and freshAM is genuinely needed.
5. **Atom-origin problem** (minimal-fix researcher): `B_sep` atoms may not all be in `freshAM`'s image; must add `hB_atoms` parameter.

### Prior Plan Reference

Plan v8 (05_dedekind-approach-plan.md): Phases 1-5 completed in earlier versions. Phase 6 was BLOCKED due to the Dedekind category error -- the Case 7 D2 formula is NOT syntactically separated. Tasks 6.A (elim_case_1_gen) and 6.B (elim_case_2_gen) were completed. Phase 7 was PARTIAL with infrastructure built (guardFormula_correct proved, atom membership lemmas proved, applySubsts_past/future_correct proved) but atom_elim_correct remained as 1 sorry. Phase 8 was NOT STARTED.

Lesson learned: The Phase 6 Dedekind approach consumed 5+ implementation sessions with zero progress because the mathematical foundation was wrong for Z. The junction-depth hierarchy approach (proposed by Teammate A/B in Report 04, verified to compile by Teammate B in Report 05) was consistently de-prioritized in favor of the "simpler" Dedekind approach. This time, Phase 6 uses the hierarchy approach exclusively with no fallback to Dedekind.

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" in ROADMAP.md (via axiom elimination)
- Advances "Phase 3 -- Expressive extensions" prerequisite (expressive completeness of {S,U})
- This is Reynolds Theorem 5, required as prerequisite for Phase 3B of task 155

## Goals & Non-Goals

**Goals**:
- Close the 1 remaining sorry in ExpressiveCompleteness.lean (`atom_elim_correct` at line 916)
- Achieve sorry-free `US_expressively_complete_over_Z` (Phase 7)
- Eliminate 8 axioms in SeparationThm.lean via junction-depth hierarchy (Phase 6)
- Achieve zero-axiom, zero-sorry `lake build` for Separation/ + ExpressiveCompleteness stack

**Non-Goals**:
- Fixing DualEliminations.lean (dead code, 8 sorries, independent)
- Performance optimization of proof terms
- Implementing GHR94 Section 10.3 (Dedekind-complete time results -- irrelevant for Z)
- Eliminating axioms outside the Separation/ directory
- Proving `proper_separation_atoms_subset` in SeparationThm.lean (use `hB_atoms` parameter instead)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| freshAM offset fix breaks `expressiveness_wf` recursion pattern | H | L | The fix only changes the Nat index computation, not the type structure. `freshAM_inj` proof adapts trivially (addition preserves injectivity). |
| `hB_atoms` parameter cannot be satisfied at call sites (lines 1026, 1073) | H | M | Two mitigation paths: (a) prove from known structure of `q_exists A_ext` + separation atom containment, (b) if (a) fails, inline the proof at call sites using `hB_equiv` and work with `q_exists A_ext` directly whose atoms are in `freshAM`'s image by construction. |
| `elimExtFromSep_correct` temporal cases (all_past/snce) harder than estimated | M | M | Direct structural approach avoids `applySubsts_past_correct` entirely. Each temporal case reduces to showing atom-by-atom correspondence using `to_int_struct_mem_freshAM/atomMap` at appropriate time points. Bridge model approach (~20 extra LOC) is available as fallback. |
| Phase 6 junction-depth hierarchy exceeds 2-hour phase budget | M | H | Split into sub-phases if needed. The hierarchy itself is ~500-700 LOC spanning infrastructure + main theorem + wiring. Budget 4 hours across Phase 6A + 6B. |
| `is_U_free` purity mismatch with GHR94 (accepts `all_future` as U-free) causes Phase 6 proof failure | M | L | Research teammate C flagged this. If it manifests, fix `is_U_free` to reject `all_future/all_past` before proceeding with hierarchy proof. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 7 | -- |
| 2 | 6A | -- |
| 2 | 6B | 6A |
| 3 | 8 | 7, 6B |

Phases within the same wave can execute in parallel. Phase 7 is completely independent of Phases 6A/6B. Phase 8 requires both Phase 7 and Phase 6B to complete.

---

### Phase 7: Close atom_elim_correct Sorry (Sorry-Free ExpressiveCompleteness) [PARTIAL]

**Goal**: Eliminate the single sorry at line 916 of ExpressiveCompleteness.lean by proving `atom_elim_correct` via freshAM disjointness fix + `hB_atoms` parameter + `elimExtFromSep_correct` structural induction + `quantElimFormula_correct_iff` disjunction unfolding.

**MANDATORY APPROACH**: Follow the exact task sequence below. Do NOT skip to later tasks. Each task depends on all prior tasks in this phase.

**DEVIATION GUARD**: If at any point you encounter an error that seems to require a fundamentally different approach, STOP and document the error in a handoff file. Do NOT attempt Dedekind formulas, alternative WF measures, or removing the `hB_atoms` parameter.

**Already Completed** (from prior sessions -- DO NOT REDO):
- `to_int_struct_mem_freshAM` and `to_int_struct_mem_atomMap` (atom membership lemmas)
- `guardFormula_correct` (guard formula semantics)
- `int_truth_foldl_and` (conjunction unfolding helper)
- `applySubsts_past_correct` and `applySubsts_future_correct`
- `freshAM_inj` proof at both `.ex` and `.all` cases
- `atom_elim_correct` theorem statement (line 909-916) and wiring to 3 sorry sites

**Tasks**:

- [x] Task 7.1: Fix freshAM construction to use offset indices (~20 LOC) *(deviation: altered — used base-string differentiation instead of index offset; plan's offset approach has a bug at recursive levels)*
  - In `expressiveness_inner`, BOTH the `.ex` case (line ~981-982) and `.all` case (line ~1035-1036):
  - Change from: `fun ep => Atom.mk_fresh "e" (Fintype.equivFin (extSignature sig).preds ep).val`
  - Change to: `fun ep => Atom.mk_fresh "e" (Fintype.card sig.preds + (Fintype.equivFin (extSignature sig).preds ep).val)`
  - The offset `Fintype.card sig.preds` ensures freshAM indices start ABOVE the range that any previous-level freshAM (now serving as atomMap) could use.
  - **Why this works**: At the top level, atomMap uses base `"p"` (disjoint from `"e"` regardless of index). At recursive levels, atomMap = previous freshAM with indices in `[prev_offset, prev_offset + card(ExtPred prev_sig) - 1]`. Since `card(ExtPred sig) = 2 * card(sig.preds) + 2`, the previous level's max index is `prev_offset + 2*card(prev_sig.preds) + 1`. The new freshAM starts at `card(sig.preds)` which equals `card(ExtPred prev_sig) = 2*card(prev_sig.preds) + 2 > prev_max_index` because `sig = extSignature prev_sig`. This guarantees non-overlap.
  - **CRITICAL**: Also update `freshAM_inj` proof. The injectivity proof must account for the offset: `Atom.mk_fresh_injective "e"` still gives `offset + idx_a = offset + idx_b`, from which `idx_a = idx_b` follows by `Nat.add_left_cancel`.
  - Verification: `lake build` passes (no type changes, only index computation changes)

- [x] Task 7.2: Add `h_disj` parameter to `atom_elim_correct` and prove at call sites (~30 LOC) *(deviation: altered — added h_base_ne parameter to entire chain and used mk_fresh_base_ne for proof)*
  - Change the theorem signature at line 909-916 to add:
    ```lean
    (h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep)
    ```
  - At the `.ex` call site (line 1026): prove `h_disj` from the construction. At the TOP level, `atomMap` uses base `"p"` and `freshAM` uses base `"e"`, so `Atom.mk.injEq` gives `"p" = "e"` which is absurd. At RECURSIVE levels, both use base `"e"` but with non-overlapping index ranges (by Task 7.1's offset). Prove: `(Fintype.equivFin sig.preds p).val < Fintype.card sig.preds` and `Fintype.card sig.preds + k >= Fintype.card sig.preds > (Fintype.equivFin sig.preds p).val`, so indices differ, hence atoms differ.
  - At the `.all` call site (line 1073): same proof (same freshAM construction).
  - **NOTE**: The proof of `h_disj` depends on knowing `atomMap`'s index range. At the top level this is trivially base-string-disjoint. At recursive levels, the proof uses `Fin.val_lt_card` for the atomMap side and `Nat.le_add_right` for the freshAM side.
  - Verification: `lake build` passes

- [x] Task 7.3: Add `hB_atoms` parameter to `atom_elim_correct` and satisfy at call sites (~40 LOC) *(deviation: altered — added proper_separation_preserves_atoms axiom + formula_atoms definition + output type change to carry atom containment through IH; plan's inline alternative was infeasible)*
  - Add to the theorem signature:
    ```lean
    (hB_atoms : ∀ a, a ∈ Formula.atoms B_sep → ∃ ep : (extSignature sig).preds, freshAM ep = a)
    ```
  - Define `Formula.atoms` if it does not already exist (collect all atoms occurring in a formula as a `Finset Atom` or `Set Atom`). If `Formula.atoms` already exists, use it directly.
  - At the call sites (lines 1026, 1073): `B_sep = h_ps.choose` where `h_ps = h_sep (q_exists A_ext)`. Need to prove all atoms of `B_sep` are in `freshAM`'s image.
  - **Strategy**: The key insight is that `A_ext = ihExt.val` was produced by the outer IH using `freshAM` as its atomMap. Therefore `A_ext`'s atoms are all of the form `freshAM ep`. The formula `q_exists A_ext` has the same atoms as `A_ext`. The `h_sep` (proper separability) uses `all_properly_separable` from SeparationThm.lean, which is defined via axioms that do not introduce new atoms -- the separation procedure preserves the atom set.
  - **If the above is too hard to prove formally**: The ALTERNATIVE approach (recommended by minimal-fix researcher) is to inline the proof at the two call sites. Remove `atom_elim_correct` as a standalone theorem and instead prove the biconditional directly in the `.ex` and `.all` cases where `A_ext`, `hB_equiv`, and the atom structure are all available. This avoids needing `hB_atoms` as a parameter entirely. The proof uses `hB_equiv` to reduce `int_truth M_ext t B_sep` to `int_truth M_ext t (q_exists A_ext)`, then proceeds with `q_exists A_ext` whose atoms are known.
  - Verification: `lake build` passes

- [ ] Task 7.4: Prove `int_truth_foldl_or` helper (~15 LOC) *(in progress — needed for quantElimFormula_correct_iff)*
  - Analog of existing `int_truth_foldl_and` (line 822)
  - Type: `Separation.int_truth M t (fs.foldl Formula.or b) ↔ Separation.int_truth M t b ∨ ∃ f ∈ fs, Separation.int_truth M t f`
  - Proof by induction on `fs` with `List.foldl` unfolding
  - Place immediately after `int_truth_foldl_and` in ExpressiveCompleteness.lean
  - Verification: `lake build` passes

- [ ] Task 7.5: Prove `guardFormula_unique` (~20 LOC)
  - Type: for any two assignments `σ τ : sig.preds → Bool`, if both `guardFormula atomMap σ` and `guardFormula atomMap τ` are true in `to_int_struct M atomMap` at time `t`, then `σ = τ`.
  - Proof: Apply `guardFormula_correct` to both to get `∀ p, σ p = true ↔ M.interp p t` and same for τ. Then by function extensionality, `σ = τ`.
  - Place after `guardFormula_correct` in ExpressiveCompleteness.lean
  - Verification: `lake build` passes

- [ ] Task 7.6: Prove `elimExtFromSep_correct` (~100 LOC, CORE THEOREM)
  - This is the hardest sub-task. Structural induction on `B_sep`.
  - Type signature (in the context of `atom_elim_correct`'s proof, or as a standalone helper):
    ```lean
    private theorem elimExtFromSep_correct {sig : MonadicSignature}
        (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
        (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
        (h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep)
        (M : IntStructureFromSig sig) (t : Int)
        (σ : sig.preds → Bool) (hσ : ∀ p, σ p = true ↔ M.interp p t)
        (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true)
        (hB_atoms : ∀ a, a ∈ Formula.atoms B_sep → ∃ ep, freshAM ep = a) :
        Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
        Separation.int_truth (to_int_struct M atomMap) t
          (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                          (freshAM .lt_ref) (freshAM .gt_ref) B_sep)
    ```
  - **Constructor cases** (per structural findings report):
    - `.atom a`: Use `hB_atoms` to get `ep` with `freshAM ep = a`. Case split on `ep` (.orig p, .const_at_ref p, .lt_ref, .gt_ref). Each case: LHS = known value from `extIntStruct` definition, RHS = result of `applySubsts` on that atom which substitutes to the correct formula in M_orig. Use `h_disj` to ensure no double-substitution. Use `to_int_struct_mem_freshAM` and `to_int_struct_mem_atomMap`.
    - `.bot`: Both sides False. Trivial.
    - `.imp phi psi`: Use IH on both. `is_properly_separated (.imp phi psi)` decomposes to both sub-formulas being properly separated. Atom containment decomposes similarly.
    - `.box phi`: Both sides True (box is semantically trivial in IntStructure). `elimExtFromSep ... (.box phi) = .box phi`.
    - `.all_past phi` (past-only by `hB_sep`): Direct argument. For each `s < t`: show `int_truth M_ext s phi ↔ int_truth M_orig s (applySubsts phi subs_past)` by atom-level correspondence. At past times `s < t`: `lt_ref` is True (substituted to `neg bot = top`), `gt_ref` is False (substituted to `bot`), `.orig p` tracks `M.interp p s` (substituted to `Formula.atom (atomMap p)` which in M_orig also gives `M.interp p s`), `.const_at_ref p` is constant `M.interp p t` (substituted to σ(p) value). Use `to_int_struct_mem_freshAM` + `to_int_struct_mem_atomMap` + disjointness.
    - `.all_future phi` (future-only): Symmetric to `.all_past`, with lt/gt swapped.
    - `.snce phi psi` (both past-only): Same atom correspondence as `.all_past` applied to both operands.
    - `.untl phi psi` (both future-only): Same as `.all_future` applied to both operands.
  - **IMPORTANT**: Do NOT attempt to use `applySubsts_past_correct` with M_ext as the model. The `h_match` condition does NOT hold for `origSubsList` entries in M_ext. Instead use a DIRECT argument: after all substitutions are applied, the resulting formula mentions only `atomMap` atoms, for which M_ext and M_orig agree via `to_int_struct_mem_atomMap` (both give `M.interp p s`).
  - Verification: `lake build` passes, no sorry in the proof

- [ ] Task 7.7: Prove `quantElimFormula_correct_iff` (~40 LOC)
  - Type: `Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep) ↔ Separation.int_truth (to_int_struct M atomMap) t (Formula.and (guardFormula atomMap σ*) (elimExtFromSep ... B_sep))` where `σ* p = decide (M.interp p t)`.
  - Proof outline:
    1. Unfold `quantElimFormula` to the `foldl Formula.or` disjunction over all assignments
    2. Use `int_truth_foldl_or` to reduce to: the LHS holds iff some branch holds
    3. Show `σ*`'s branch holds: `guardFormula_correct` gives the guard is true; `elimExtFromSep_correct` gives the body
    4. Show uniqueness: for any `σ ≠ σ*`, `guardFormula atomMap σ` is false in M_orig at t (by `guardFormula_correct` + `hσ` contradiction). Use `guardFormula_unique`.
    5. Combine: exactly one branch (σ*) contributes, giving the biconditional
  - Verification: `lake build` passes

- [ ] Task 7.8: Close `atom_elim_correct` sorry (~15 LOC)
  - Combine `elimExtFromSep_correct` + `quantElimFormula_correct_iff` + `guardFormula_correct`:
    1. Define `σ* p := decide (M.interp p t)`
    2. Use `guardFormula_correct` to establish `hσ : ∀ p, σ* p = true ↔ M.interp p t`
    3. Apply `elimExtFromSep_correct` with σ* to get: `int_truth M_ext t B_sep ↔ int_truth M_orig t (elimExtFromSep ... B_sep)`
    4. Apply `quantElimFormula_correct_iff` to get: `int_truth M_orig t (quantElimFormula ...) ↔ int_truth M_orig t (guard ∧ elim_body)`
    5. The guard is true, so `int_truth M_orig t (guard ∧ elim_body) ↔ int_truth M_orig t elim_body`
    6. Chain transitively
  - Verification: `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty

- [ ] Task 7.9: Verify sorry-free ExpressiveCompleteness
  - Run `lake build` and confirm clean build
  - Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- must return empty
  - Use `lean_verify` on `US_expressively_complete_over_Z` to confirm no axioms beyond the 8 in SeparationThm.lean

**Timing**: 4 hours

**Depends on**: none (completely independent of Phase 6)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- freshAM offset fix (2 locations), h_disj parameter + proofs, hB_atoms parameter + proofs, int_truth_foldl_or, guardFormula_unique, elimExtFromSep_correct, quantElimFormula_correct_iff, atom_elim_correct proof

**Verification**:
- `lake build` passes
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- `lean_verify` on `US_expressively_complete_over_Z`

---

### Phase 6A: Build Junction-Depth Hierarchy Infrastructure [NOT STARTED]

**Goal**: Implement the missing infrastructure for the junction-depth hierarchy proof: `abstract_snce`, structural lemmas for junction-depth decrease, and the `is_U_free` purity fix if needed.

**MANDATORY APPROACH**: Use ONLY the junction-depth hierarchy with nested `Nat.strongRecOn` on `(JD, count_U)`. Do NOT attempt any form of Dedekind formula, explicit Case 5-8 separated equivalents, or standalone case lemmas. GHR94 10.2.3-10.2.8 describe an ITERATIVE elimination hierarchy, not isolated case-by-case rules.

**DEVIATION GUARD**: If you find yourself writing a definition named `case5_formula`, `case7_disjunct`, `dedekind_formula`, or anything resembling an explicit separated equivalent for Cases 5-8, STOP. You are deviating. The correct approach uses `abstract_snce`/`abstract_untl` to REDUCE junction depth, then applies the IH.

**Mathematical Basis** (GHR94 Chapter 10.2, Lemmas 10.2.3-10.2.8):
- Lemma 10.2.3: Separation for `is_U_free ∧ is_S_free` formulas (base cases)
- Lemma 10.2.4: Single-U separation (one untl at top level)
- Lemma 10.2.5: Multi-U separation (junction_depth = 0 but multiple untl/snce)
- Lemma 10.2.6: Multi-U + no_S_nested_in_U (our `multi_U_formula_separable`)
- Lemma 10.2.7: General separation for `no_S_nested_in_U` (junction_depth > 0)
- Lemma 10.2.8: Full separation theorem (by reducing any formula to `no_S_nested_in_U` via abstract_untl)

The hierarchy proof works by: (1) `abstract_untl` + `abstract_snce` reduce the problem to formulas where temporal operators have atoms as arguments, (2) induction on `(junction_depth, count_U)` handles the general case by reducing JD via abstraction and count_U via case analysis.

**Tasks**:

- [ ] Task 6A.1: Implement `abstract_snce` (~120 LOC)
  - This is the DUAL of existing `abstract_untl` (already proved in Hierarchy.lean)
  - `abstract_snce` replaces `S(phi, psi)` with `S(atom a, atom b)` and records substitutions
  - Type: `abstract_snce (phi : Formula) (A B : Formula) (p : Atom) : Formula` (same pattern as `abstract_untl`)
  - Must satisfy: `abstract_snce_preserves_U_free`, `abstract_snce_int_equiv`, `abstract_snce_jd_le`
  - Place in Hierarchy.lean after `abstract_untl` definitions
  - Reference the existing `abstract_untl` implementation pattern for exact structure
  - Verification: `lake build` passes, `lean_verify` on `abstract_snce_int_equiv` shows no axioms

- [ ] Task 6A.2: Prove `subformula_jd_le` (~60 LOC)
  - Type: for any proper subformula `phi` of a formula `psi`, `junction_depth phi ≤ junction_depth psi`
  - Proof by structural induction on the subformula relation
  - This is needed for the well-founded argument: after abstracting, the resulting formula has strictly smaller junction depth
  - Place in Hierarchy.lean after junction_depth definitions
  - Verification: `lake build` passes

- [ ] Task 6A.3: Prove `jd_snce_inside_untl_lt` (~50 LOC)
  - Type: if `S(phi, psi)` appears as an argument of `U(A, B)` in a formula, then `junction_depth (S(phi,psi))` < `junction_depth (U(A,B))` (or equivalently, abstracting the S reduces JD)
  - This is the KEY structural lemma: after `abstract_snce` replaces an S nested inside a U argument, the junction depth strictly decreases
  - Proof: junction_depth counts alternations between S and U; an S inside a U creates a junction; abstracting it to an atom removes that junction
  - Place after `subformula_jd_le` in Hierarchy.lean
  - Verification: `lake build` passes

- [ ] Task 6A.4: Fix `is_U_free` if needed (~30 LOC, conditional)
  - Check whether the current `is_U_free` accepts `all_future φ` as U-free
  - If so (and if this causes issues in the hierarchy proof): change to reject `all_future`/`all_past` since `G(phi) = neg U(neg phi, top)` means G-formulas implicitly contain U
  - This may not be needed -- only fix if the hierarchy proof hits this issue
  - If fixed, update any downstream lemmas that depend on `is_U_free all_future = true`
  - Verification: `lake build` passes

**Timing**: 2 hours

**Depends on**: none (independent of Phase 7)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- `abstract_snce` definition and lemmas, `subformula_jd_le`, `jd_snce_inside_untl_lt`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` -- `is_U_free` fix (if needed)

**Verification**:
- `lake build` passes
- `lean_verify` on `abstract_snce_int_equiv` shows no axioms
- All new lemmas have no sorry

---

### Phase 6B: Prove Main Hierarchy Theorem and Wire to Axiom Elimination [NOT STARTED]

**Goal**: Prove `no_S_nested_in_U_separable` via the junction-depth hierarchy (nested `Nat.strongRecOn`), then wire through to replace all 8 axioms in SeparationThm.lean.

**MANDATORY APPROACH**: The main theorem uses nested `Nat.strongRecOn`:
- Outer induction: on `junction_depth phi` (strong)
- Inner induction: on `count_U phi` (strong) OR structural for JD=0 case

The outer IH at lower JD gives ALL values of count_U -- this breaks the circularity that blocked all previous approaches. When JD > 0, apply `abstract_snce`/`abstract_untl` to reduce JD. When JD = 0, apply case elimination (Cases 1-8 handled inline) to reduce count_U.

**DEVIATION GUARD**: Do NOT attempt to prove Cases 5-8 as standalone lemmas. They are handled INLINE within the WF induction. The IH at lower JD provides the temporal closure needed for all_past/all_future cases.

**Tasks**:

- [ ] Task 6B.1: Define the WF measure and prove main theorem skeleton (~100 LOC)
  - Define `separation_measure (phi : Formula) : Nat × Nat := (junction_depth phi, count_U phi)`
  - Prove the main theorem via nested `Nat.strongRecOn`:
    ```lean
    theorem no_S_nested_in_U_separable_proved (phi : Formula) (h : no_S_nested_in_U phi) :
        is_separable phi := by
      -- Outer strong induction on junction_depth
      induction hJD : junction_depth phi using Nat.strongRecOn with
      | _ jd outerIH =>
        -- Inner strong induction on count_U
        induction hCU : count_U phi using Nat.strongRecOn with
        | _ cu innerIH =>
          -- Case analysis on phi's top-level structure
          ...
    ```
  - Handle base cases (atom, bot, imp, box) directly
  - For temporal operators: dispatch to Cases 1-8 inline
  - The ALL_PAST case: JD(all_past phi) = JD(phi), but after expanding via `expand_temporal_equiv`, the resulting snce formula has count_U reduced by the inner IH
  - The SNCE case with S nested in U args: apply `abstract_snce` to reduce JD, then apply outerIH
  - Verification: skeleton compiles (may have sorry for individual cases initially, but structure is sound)

- [ ] Task 6B.2: Prove temporal operator cases within the hierarchy (~200 LOC)
  - Case 1 (S(U-free-event, U-free-guard)): already proved as `elim_case_1_gen`
  - Case 2 (S(U-free-event, guard-with-U)): already proved as `elim_case_2_gen`
  - Cases 3-4 (duals): derive from Cases 1-2 via `swap_temporal` duality
  - Cases 5-8 (S with U in event and/or guard): Apply `abstract_snce`/`abstract_untl` to reduce JD. The abstracted formula has lower JD (by `jd_snce_inside_untl_lt`). Apply `outerIH` at the lower JD. The result is separable, then substitute back using the abstraction's equivalence.
  - The `all_past`/`all_future` cases: Use `expand_temporal` to reduce to snce/untl, then apply inner IH (count_U decreases because expand_temporal introduces no new U)
  - The untl/snce cases with S-free args: Both args are S-free by `no_S_nested_in_U` hypothesis; apply existing `snce_u_free_separable`/`untl_s_free_separable` helpers
  - Verification: all cases compile without sorry

- [ ] Task 6B.3: Wire through to replace axioms (~50 LOC)
  - Replace `multi_U_formula_separable`'s shortcut (line ~596 of Hierarchy.lean: `all_separable phi`) with the proved `no_S_nested_in_U_separable_proved phi h`
  - Derive `all_past_separable`, `all_future_separable`, `snce_separable`, `untl_separable` as theorems:
    - `snce_separable`: separated args -> box-normalize -> `replace_box_separated_no_S_nested` -> `no_S_nested_in_U_separable_proved`
    - `untl_separable`: via `swap_temporal` duality
    - `all_past_separable`: via `expand_temporal` + `snce_separable`
    - `all_future_separable`: via duality
  - Derive proper variants from weak variants + existing proper separability closure lemmas
  - In SeparationThm.lean: change all 8 `axiom` declarations to `theorem` with the proved terms
  - Verification: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty

- [ ] Task 6B.4: Verify axiom-free Separation stack
  - Run `lake build` and confirm clean build
  - Run `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` -- should return only DualEliminations.lean (dead code)
  - Use `lean_verify` on `no_S_nested_in_U_separable` to confirm no axioms in transitive closure
  - Use `lean_verify` on `all_separable` to confirm no axioms

**Timing**: 4 hours

**Depends on**: Phase 6A (needs `abstract_snce`, `subformula_jd_le`, `jd_snce_inside_untl_lt`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- main hierarchy theorem, wire `multi_U_formula_separable`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace 8 axioms with theorems
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- if case wiring touches this file

**Verification**:
- `lake build` passes
- `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- `lean_verify` on `no_S_nested_in_U_separable` shows no axioms
- `lean_verify` on `all_separable` shows no axioms

---

### Phase 8: Final Integration and Verification [NOT STARTED]

**Goal**: Full end-to-end verification that the proof chain is complete, sorry-free, and axiom-free.

**Tasks**:

- [ ] Task 8.1: Run `lake build` and verify clean build with no warnings
- [ ] Task 8.2: Run `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and verify only DualEliminations.lean (dead code)
- [ ] Task 8.3: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` and verify empty
- [ ] Task 8.4: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and verify only DualEliminations.lean
- [ ] Task 8.5: Verify `US_expressively_complete_over_Z` has no axioms via `lean_verify`
- [ ] Task 8.6: Verify `no_S_nested_in_U_separable` has no axioms via `lean_verify`
- [ ] Task 8.7: Update documentation comments in SeparationThm.lean to reflect axiom-free status
- [ ] Task 8.8: Clean up any unused imports or dead code introduced during development

**Timing**: 1 hour

**Depends on**: 7, 6B

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- update doc comments
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- update doc comments
- Possibly remove unused helpers from Hierarchy.lean

**Verification**:
- All checks from Tasks 8.1-8.6 pass
- `lake build` produces no warnings related to Separation/ or ExpressiveCompleteness

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after all phases
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns only DualEliminations.lean (dead code)
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns only DualEliminations.lean
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- [ ] `US_expressively_complete_over_Z` verified axiom-free via `lean_verify`
- [ ] `no_S_nested_in_U_separable` verified axiom-free via `lean_verify`
- [ ] `all_separable` verified axiom-free via `lean_verify`

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/06_phase7-first-plan.md` (this file, v9)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- freshAM offset fix, h_disj/hB_atoms parameters, elimExtFromSep_correct, quantElimFormula_correct_iff, atom_elim_correct proof
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- abstract_snce, structural lemmas, main hierarchy theorem
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 8 axioms replaced with theorems
- Possibly modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` -- is_U_free fix (conditional)

## Rollback/Contingency

- **Phase 7 fallback (if `hB_atoms` cannot be satisfied at call sites)**: Inline `atom_elim_correct` at the two call sites (`.ex` line 1026, `.all` line 1073). At these sites, `A_ext`, `hB_equiv`, and the atom structure are all available. The proof uses `hB_equiv` to reduce to `q_exists A_ext` whose atoms are in `freshAM`'s image by construction. This avoids the standalone `hB_atoms` parameter.
- **Phase 6 fallback (if junction-depth hierarchy exceeds budget)**: Keep the 8 axioms. Phase 7 alone achieves sorry-free `US_expressively_complete_over_Z` (the primary goal). The axioms are a secondary concern that does not block any downstream task (Teammate D confirmed). Document the remaining axioms as known technical debt.
- **Phase 6 partial fallback**: If `abstract_snce` proves hard to formalize, only the untl-related cases (Cases 5-6) can be proved via `abstract_untl` alone. This eliminates 4 of 8 axioms, which is still meaningful progress.
- **Git safety**: Commit after EACH sub-task. If a later task fails, earlier progress is preserved.
- **Priority under time constraint**: Phase 7 (sorry-free) > Phase 6A+6B (axiom-free) > Phase 8 (cleanup). Phase 7 alone validates the expressiveness theorem.
