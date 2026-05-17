# Implementation Plan: Task #157 (v10) -- Complete Remaining Proofs

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: Task 155 (completed phases provide infrastructure)
- **Research Inputs**: reports/07_build-audit.md, reports/07_elimExtFromSep-proof-strategy.md, reports/07_alternative-decomposition.md, reports/07_phase6-remaining.md, reports/06_team-research.md
- **Artifacts**: plans/07_complete-remaining-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## PLAN COMPLIANCE

**This plan is a CONTRACT. Implementation agents MUST follow it exactly, step by step.**

### Binding Rules

1. This plan specifies the EXACT implementation order, proof strategies, and lemma signatures. Agents must follow each task in sequence within a phase, using the proof approach described. There is no latitude to "find a better way."

2. **Prohibited behaviors**:
   - Inventing alternative proof strategies not described in this plan
   - Assessing whether a lemma is "minimal" or "optimal" -- just implement what is specified
   - Proposing "cleaner approaches" that deviate from the prescribed structure
   - Using Dedekind formulas, bridge lemmas with `applySubsts_past_correct` on M_ext, uniform atom replacement, or any approach previously tried and failed
   - Introducing new `sorry` obligations
   - Using `def X := True` or other vacuous definitions
   - Skipping tasks or reordering within a phase

3. **GHR94 is authoritative**: The file `literature/ghr94-ch10-markdown.md` is the mathematical source of truth. When this plan references a GHR94 lemma number, the implementation must follow that lemma's proof structure. Do not innovate.

4. **ALL previous "novel" approaches have failed**: Dedekind formulas (dense time, not Z), bridge lemmas (`h_match` fails), uniform atom replacement (time-dependent semantics), standalone Case 5-8 equivalents (iterative, not terminal), composite WF measures on `count_U_under_S` (circularity). These are DEAD approaches. Do not resurrect them.

5. **On difficulty**: If a task proves harder than expected or a type error cannot be resolved within 30 minutes, STOP and write a handoff file documenting the exact error, goal state, and what was tried. Do NOT deviate from the plan to work around the issue.

---

## Overview

This plan completes the remaining work for Task 157 across two parallel tracks:

- **Phase 7** (sorry elimination): Close the 3 remaining sorries in `ExpressiveCompleteness.lean` by proving `atom_elim_correct` via structural induction on properly-separated formulas, using `int_truth_depends_on_atoms` (already proved at line 894) as the key transfer tool for temporal cases.

- **Phase 6** (axiom elimination): Prove the junction-depth hierarchy theorem to eliminate all 9 axioms in `SeparationThm.lean`, following GHR94 Lemmas 10.2.7-10.2.8 with single-layer strong induction on `junction_depth` plus a separate `U_depth_under_S` subroutine.

Definition of done: `lake build` passes with zero sorry in ExpressiveCompleteness.lean AND zero axioms in SeparationThm.lean (except DualEliminations.lean which is dead code).

### Research Integration

Round 7 research (2026-05-17) provided:
1. **Build audit**: Confirms clean build (1647 jobs), 3 sorries (lines 958, 1139, 1217), 9 axioms.
2. **elimExtFromSep proof strategy**: Complete case-by-case analysis of all 8 formula constructors with HIGH confidence ratings. Key insight: use `int_truth_depends_on_atoms` to transfer truth after substitution eliminates freshAM atoms.
3. **Alternative decomposition**: Confirmed that the atom containment sorries (lines 1139, 1217) are INDEPENDENT of `atom_elim_correct` and can be closed first. Provides exact lemma signatures.
4. **Phase 6 remaining**: Maps GHR94 hierarchy to Lean infrastructure. Confirms `is_U_free` purity is NOT an issue (handled by `expand_temporal`). Recommends single-layer strong induction on `junction_depth` (not nested `(JD, count_U)`).

### Prior Plan Reference

Plan v9 (06_phase7-first-plan.md): Tasks 7.1-7.3 completed (freshAM base-string differentiation, h_disj via mk_fresh_base_ne, hB_atoms via proper_separation_preserves_atoms axiom). Tasks 7.4-7.5 completed (int_truth_foldl_or, guardFormula_unique proved). Tasks 7.6-7.9 remain (the actual proofs). Phase 6 entirely unstarted.

Key lessons from v9 execution:
- The freshAM/atomMap disjointness was solved via base-string differentiation (`"p"` vs `"e"`) rather than index offset -- simpler and more robust.
- `proper_separation_preserves_atoms` was added as an axiom (sound, load-bearing) to satisfy `hB_atoms` at call sites.
- `applySubsts_past_correct` with M_ext as model does NOT work (h_match fails). The direct structural approach via `int_truth_depends_on_atoms` is correct.

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" (via axiom elimination)
- Advances "Phase 3 -- Expressive extensions" prerequisite (expressive completeness of {S,U})
- Completes Reynolds Theorem 5 (required for task 155 Phase 3B)

## Goals & Non-Goals

**Goals**:
- Close all 3 sorries in ExpressiveCompleteness.lean (atom_elim_correct + 2 atom containment)
- Eliminate all 9 axioms in SeparationThm.lean via the junction-depth hierarchy
- Achieve zero-sorry, zero-axiom `lake build` for the Separation/ + ExpressiveCompleteness stack
- Commit after each task to preserve partial progress

**Non-Goals**:
- Fixing DualEliminations.lean (dead code, 8 sorries, independent)
- Performance optimization of proof terms
- Implementing GHR94 Section 10.3 (dense/Dedekind-complete time -- irrelevant for Z)
- Eliminating sorries outside of ExpressiveCompleteness.lean (IntegerModel, Transfer, etc.)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `applySubsts` sequential behavior harder to prove than atom-by-atom analysis suggests | H | M | Use `int_truth_depends_on_atoms` to bypass applySubsts reasoning entirely for temporal cases. Only the atom case needs applySubsts reasoning. |
| `quantElimFormula` match statement creates shape issues for foldl_or | M | L | The build audit confirms `sig.preds` is always inhabited, so the `b :: bs` branch applies. Handle the empty/singleton cases with `simp` or `cases`. |
| Phase 6 junction-depth hierarchy exceeds 2-hour sub-phase budgets | M | H | Phase 6 is split into 3 sub-phases (6A, 6B, 6C). Phase 7 alone achieves sorry-free expressiveness theorem -- axioms are secondary. |
| `abstract_snce` preservation lemmas harder than expected due to mutual recursion in junction_depth | M | M | Follow the exact pattern of the existing `abstract_untl` lemmas which already handle this. Copy-with-swap approach. |
| Proper separation bridge (is_separable to is_properly_separable) requires nontrivial work | M | M | Research report notes this may need the hierarchy to target `is_properly_separated` directly. Fallback: eliminate only the 4 `is_separable` axioms first. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 7A, 6A | -- |
| 2 | 7B | 7A |
| 3 | 6B | 6A |
| 4 | 6C | 6B |
| 5 | 8 | 7B, 6C |

Phases within the same wave can execute in parallel.

---

### Phase 7A: Atom Containment and Helper Lemmas [NOT STARTED]

**Goal**: Close the 2 atom containment sorries (lines 1139, 1217) and add helper infrastructure needed by Phase 7B. These are INDEPENDENT of `atom_elim_correct`.

**Tasks**:

- [ ] Task 7A.1: Prove `formula_atoms_subst_formula` (~20 LOC)
  - Location: `ExpressiveCompleteness.lean`, placed before `atom_elim_correct`
  - Type:
    ```lean
    private theorem formula_atoms_subst_formula (φ : Formula) (target : Atom) (r : Formula) :
        Separation.formula_atoms (Separation.subst_formula φ target r) ⊆
        (Separation.formula_atoms φ \ {target}) ∪ Separation.formula_atoms r
    ```
  - Proof: Structural induction on φ. Cases: `.atom a` (split on `a = target`), `.bot` (trivial), `.imp`/`.and` (union of IH), `.box`/`.all_past`/`.all_future`/`.snce`/`.untl` (IH on sub-formulas).
  - Verification: `lake build` passes

- [ ] Task 7A.2: Prove `formula_atoms_applySubsts` (~35 LOC)
  - Location: After `formula_atoms_subst_formula`
  - Type:
    ```lean
    private theorem formula_atoms_applySubsts (φ : Formula) (subs : List (Atom × Formula)) :
        Separation.formula_atoms (applySubsts φ subs) ⊆
        (Separation.formula_atoms φ \ {a | ∃ r, (a, r) ∈ subs}) ∪
        ⋃ (pair : Atom × Formula) (_ : pair ∈ subs), Separation.formula_atoms pair.2
    ```
  - Proof: Induction on `subs` list, applying `formula_atoms_subst_formula` at each step.
  - Alternative simpler type if the above is unwieldy:
    ```lean
    private theorem formula_atoms_applySubsts_subset (φ : Formula) (subs : List (Atom × Formula))
        (S : Set Atom)
        (h_covered : Separation.formula_atoms φ ⊆ {a | ∃ r, (a, r) ∈ subs} ∪ S)
        (h_replacements : ∀ a r, (a, r) ∈ subs → Separation.formula_atoms r ⊆ S) :
        Separation.formula_atoms (applySubsts φ subs) ⊆ S
    ```
  - Verification: `lake build` passes

- [ ] Task 7A.3: Prove `formula_atoms_elimExtFromSep_subset` (~25 LOC)
  - Location: After `formula_atoms_applySubsts`
  - Type:
    ```lean
    private theorem formula_atoms_elimExtFromSep_subset {sig : MonadicSignature}
        (atomMap : sig.preds → Atom) (freshAM : (extSignature sig).preds → Atom)
        (freshAM_inj : Function.Injective freshAM)
        (h_disj : ∀ p ep, atomMap p ≠ freshAM ep)
        (σ : sig.preds → Bool)
        (B_sep : Formula)
        (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
        Separation.formula_atoms
          (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                          (freshAM .lt_ref) (freshAM .gt_ref) B_sep) ⊆
        Set.range atomMap
    ```
  - Proof: Structural induction on B_sep. For each case of `elimExtFromSep`, the output formula is built from `applySubsts` calls. Use `formula_atoms_applySubsts_subset` with `S = Set.range atomMap`. The substitution list maps:
    - `freshAM (.orig p)` -> `Formula.atom (atomMap p)` (atoms in range atomMap)
    - `freshAM (.const_at_ref p)` -> `neg bot` or `bot` (no atoms)
    - `freshAM .lt_ref` -> `bot` or `neg bot` (no atoms)
    - `freshAM .gt_ref` -> `bot` or `neg bot` (no atoms)
  - Combined with `hB_atoms` (all source atoms in range freshAM) and `h_disj` (no overlap), this shows all output atoms are in `Set.range atomMap`.
  - Verification: `lake build` passes

- [ ] Task 7A.4: Prove `formula_atoms_quantElimFormula_subset` (~15 LOC)
  - Location: After `formula_atoms_elimExtFromSep_subset`
  - Type:
    ```lean
    private theorem formula_atoms_quantElimFormula_subset {sig : MonadicSignature}
        (atomMap : sig.preds → Atom) (freshAM : (extSignature sig).preds → Atom)
        (freshAM_inj : Function.Injective freshAM)
        (h_disj : ∀ p ep, atomMap p ≠ freshAM ep)
        (B_sep : Formula)
        (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
        Separation.formula_atoms (quantElimFormula atomMap freshAM B_sep) ⊆ Set.range atomMap
    ```
  - Proof: Unfold `quantElimFormula`. The formula is `foldl or` over branches. Each branch is `and (guardFormula atomMap σ) (elimExtFromSep ... B_sep)`. Guard formula atoms are all `atomMap p` (in range). ElimExtFromSep atoms are in range by Task 7A.3. Union of subsets is subset. Handle foldl or by showing `formula_atoms (foldl or init rest) ⊆ formula_atoms init ∪ ⋃ (formula_atoms rest[i])`.
  - Verification: `lake build` passes

- [ ] Task 7A.5: Close atom containment sorries at lines 1139 and 1217 (~10 LOC total)
  - At line 1139 (`.ex alpha` case): Replace `sorry` with application of `formula_atoms_quantElimFormula_subset` to show `a ∈ formula_atoms (quantElimFormula ...) → a ∈ Set.range atomMap`.
  - At line 1217 (`.all alpha` case): Same, but through `Formula.neg`. Since `formula_atoms (neg φ) = formula_atoms φ`, this reduces to the same lemma.
  - Verification: `lake build` passes, `grep -n "sorry" ExpressiveCompleteness.lean` shows only line 958

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- add lemmas before `atom_elim_correct`, close 2 sorries

**Verification**:
- `lake build` passes
- Only 1 sorry remains (line 958, `atom_elim_correct`)

---

### Phase 7B: Prove atom_elim_correct (Sorry-Free ExpressiveCompleteness) [NOT STARTED]

**Goal**: Close the final sorry at line 958 (`atom_elim_correct`) by proving `elimExtFromSep_correct` via structural induction on the properly-separated formula, then composing with `quantElimFormula_correct_iff`.

**CRITICAL APPROACH**: The proof uses `int_truth_depends_on_atoms` (already proved at line 894) as the key transfer tool. After `applySubsts` runs on a temporal subformula, the output contains ONLY `atomMap` atoms (by Task 7A.3's result). Both `M_ext` and `M_orig` agree on `atomMap` atoms (both give `M.interp p s` via `to_int_struct_mem_atomMap`). Therefore `int_truth_depends_on_atoms` transfers truth between the two models on the substituted formula. Do NOT use `applySubsts_past_correct` on M_ext (h_match fails).

**Tasks**:

- [ ] Task 7B.1: Prove `elimExtFromSep_correct` (~90 LOC, CORE THEOREM)
  - Location: Before `atom_elim_correct` in ExpressiveCompleteness.lean
  - Type:
    ```lean
    private theorem elimExtFromSep_correct {sig : MonadicSignature}
        (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
        (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
        (h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep)
        (M : IntStructureFromSig sig) (t : ℤ)
        (σ : sig.preds → Bool) (hσ : ∀ p, σ p = true ↔ M.interp p t)
        (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true)
        (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
        Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
        Separation.int_truth (to_int_struct M atomMap) t
          (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                          (freshAM .lt_ref) (freshAM .gt_ref) B_sep)
    ```
  - Proof by structural induction on `B_sep`, case-by-case:
    - **`.bot`**: Both sides False. `simp [Separation.int_truth, elimExtFromSep]`.
    - **`.box φ`**: Both sides True. `simp [Separation.int_truth, elimExtFromSep]`.
    - **`.imp φ ψ`**: IH on both. `is_properly_separated` decomposes. Atom containment decomposes via set union. `simp [elimExtFromSep, Separation.int_truth]; exact Iff.imp (ih_φ ...) (ih_ψ ...)`.
    - **`.atom a`**: Case split on which `ep : ExtPred sig` satisfies `freshAM ep = a` (from `hB_atoms`). Four subcases (`.orig p`, `.const_at_ref p`, `.lt_ref`, `.gt_ref`) each verified by `to_int_struct_mem_freshAM` + the specific substitution target. See research report Section 5 for exact reasoning per subcase.
    - **`.all_past φ`** (φ is past-only by `hB_sep`): LHS = `∀ s < t, int_truth M_ext s φ`. RHS = `∀ s < t, int_truth M_orig s (applySubsts φ pastSubs)`. For each `s < t`:
      1. Show `formula_atoms (applySubsts φ pastSubs) ⊆ Set.range atomMap` (by `formula_atoms_applySubsts_subset`).
      2. Show that `M_ext` and `M_orig` agree on all atoms in `Set.range atomMap`: for any `atomMap p`, `to_int_struct_mem_freshAM` gives `s ∈ M_ext.val (atomMap p)` iff... wait, `atomMap p` is NOT in range of freshAM (by h_disj), so `M_ext.val (atomMap p) = ∅`. Instead use `to_int_struct_mem_atomMap` on M_orig.
      3. KEY: After substitution, the formula only mentions `atomMap` atoms. Construct a model `M_agree` that agrees with BOTH M_ext (on freshAM atoms) and M_orig (on atomMap atoms). Since substitution replaces ALL freshAM atoms with expressions over atomMap atoms, the substituted formula's truth in M_orig equals the original formula's truth in M_ext.
      4. IMPLEMENTATION: Use `int_truth_depends_on_atoms` to show `int_truth M_ext s φ ↔ int_truth M_orig s (applySubsts φ pastSubs)` by establishing that for each atom `a` in `φ` (which is some `freshAM ep`), `s ∈ M_ext.val (freshAM ep) ↔ int_truth M_orig s (replacement for ep)`. The 4 ep cases at past time s < t: `.orig p` -> M.interp p s (both agree), `.const_at_ref p` -> M.interp p t = σ p (both agree), `.lt_ref` -> True (s < t, replacement is neg bot), `.gt_ref` -> False (not t < s, replacement is bot).
    - **`.all_future φ`**: Symmetric to `.all_past` with lt/gt swapped and `s > t`.
    - **`.snce φ ψ`**: Same as `.all_past` applied at each witness time `s < t` and intermediate times.
    - **`.untl φ ψ`**: Same as `.all_future` applied at each witness time `s > t`.
  - **DEVIATION GUARD**: If the atom case requires more than 30 LOC, the `applySubsts` sequential behavior can be handled via a helper `applySubsts_atom_result` that computes the output of `applySubsts (.atom a) subs` given injectivity of the atom targets.
  - Verification: `lake build` passes, theorem has no sorry

- [ ] Task 7B.2: Prove `quantElimFormula_correct_iff` (~35 LOC)
  - Location: After `elimExtFromSep_correct`
  - Type:
    ```lean
    private theorem quantElimFormula_correct_iff {sig : MonadicSignature}
        (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
        (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
        (h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep)
        (M : IntStructureFromSig sig) (t : ℤ)
        (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true)
        (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
        Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep) ↔
        Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep
    ```
  - Proof outline:
    1. Define `σ₀ : sig.preds → Bool := fun p => decide (M.interp p t)`
    2. Show `hσ₀ : ∀ p, σ₀ p = true ↔ M.interp p t` (by `decide_eq_true_iff`)
    3. Unfold `quantElimFormula` to the `match branches` / `foldl or` structure
    4. Use `int_truth_foldl_or` to reduce the disjunction to existence of a true branch
    5. Show the σ₀ branch is true (forward): guard true by `guardFormula_correct`, body true by `elimExtFromSep_correct`
    6. Show uniqueness (backward): any true branch must be σ₀ by `guardFormula_correct` + `funext`
    7. Compose into biconditional
  - Verification: `lake build` passes

- [ ] Task 7B.3: Close `atom_elim_correct` sorry at line 958 (~10 LOC)
  - Replace the `sorry` at line 958 with:
    ```lean
    exact (quantElimFormula_correct_iff atomMap hinj freshAM freshAM_inj h_disj M t B_sep hB_sep hB_atoms).symm
    ```
  - Or if the types don't align exactly, compose `elimExtFromSep_correct` + `quantElimFormula_correct_iff` with appropriate `Iff.trans`.
  - Verification: `lake build` passes, `grep -n "sorry" ExpressiveCompleteness.lean` returns empty

- [ ] Task 7B.4: Verify sorry-free ExpressiveCompleteness
  - Run `lake build` and confirm clean build
  - Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- must return empty
  - Use `lean_verify` on `US_expressively_complete_over_Z` to confirm it compiles without sorry (axioms from SeparationThm.lean are acceptable at this stage)

**Timing**: 3 hours

**Depends on**: Phase 7A (needs `formula_atoms_applySubsts_subset` for the temporal case argument)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- add `elimExtFromSep_correct`, `quantElimFormula_correct_iff`, close `atom_elim_correct` sorry

**Verification**:
- `lake build` passes
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- `lean_verify` on `US_expressively_complete_over_Z` shows no sorry

---

### Phase 6A: Build Junction-Depth Hierarchy Infrastructure [NOT STARTED]

**Goal**: Implement `abstract_snce` (dual of `abstract_untl`) and junction-depth monotonicity lemmas needed for the main hierarchy theorem.

**MANDATORY APPROACH**: Follow the existing `abstract_untl` implementation pattern EXACTLY, swapping U for S. Do NOT innovate on the structure.

**Tasks**:

- [ ] Task 6A.1: Implement `abstract_snce` definition (~15 LOC)
  - Location: `Hierarchy.lean`, after `abstract_untl` (around line 290)
  - Type: `abstract_snce (φ : Formula) (A B : Formula) (p : Atom) : Formula`
  - Replaces `.snce A B` with `.atom p` throughout φ (same structural recursion pattern as `abstract_untl`)
  - Cases: `.atom` (pass through), `.bot` (pass through), `.imp` (recurse both), `.box` (recurse), `.all_past`/`.all_future` (recurse), `.snce φ₁ φ₂` (if φ₁ = A and φ₂ = B then `.atom p` else recurse both), `.untl` (recurse both)
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

- [ ] Task 6A.2: Prove `abstract_snce_correct` (semantic roundtrip, ~30 LOC)
  - Location: After `abstract_snce` definition
  - Type: Same pattern as `abstract_untl_correct` (line 334):
    ```lean
    theorem abstract_snce_correct (φ A B : Formula) (p : Atom) (M : Separation.IntStructure) (t : ℤ)
        (h_eq : M.val p = {s | Separation.int_truth M s (.snce A B)}) :
        Separation.int_truth M t (abstract_snce φ A B p) ↔ Separation.int_truth M t φ
    ```
  - Proof: Structural induction on φ. The `.snce A B` case uses `h_eq`. All other cases use IH.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

- [ ] Task 6A.3: Prove `abstract_snce` preservation lemmas (~60 LOC total)
  - `abstract_snce_preserves_U_free`: If φ is U-free, `abstract_snce φ A B p` is U-free
  - `abstract_snce_makes_S_free`: `abstract_snce φ A B p` is S-free at the abstracted location
  - `abstract_snce_preserves_no_U_nested`: If `no_U_nested_in_S φ`, then same for abstracted
  - Each follows the exact pattern of the corresponding `abstract_untl` lemma (U/S swapped)
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

- [ ] Task 6A.4: Prove junction-depth monotonicity lemmas (~20 LOC)
  - Per-constructor lemmas:
    ```lean
    theorem jd_imp_le_left (φ ψ : Formula) : junction_depth φ ≤ junction_depth (.imp φ ψ)
    theorem jd_snce_le_left (φ ψ : Formula) : junction_depth φ ≤ junction_depth (.snce φ ψ)
    theorem jd_untl_le_left (φ ψ : Formula) : junction_depth φ ≤ junction_depth (.untl φ ψ)
    -- etc. for all constructors
    ```
  - Proof: Each is immediate from `Nat.le_max_left`, `Nat.le_max_right`, `Nat.le_succ_of_le`.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

- [ ] Task 6A.5: Prove `abstract_snce_jd_decrease` (~50 LOC)
  - The key well-foundedness lemma: abstracting an S-node inside a U-argument decreases `junction_depth`:
    ```lean
    theorem abstract_snce_inside_untl_jd_lt (φ A B : Formula) (p : Atom)
        (h_occurs : snce_occurs_in φ A B)
        (h_inside_untl : snce_inside_untl φ A B) :
        junction_depth (abstract_snce φ A B p) < junction_depth φ
    ```
  - Alternative formulation (if the "occurs inside untl" predicate is hard to state): Show that after abstracting ALL S-nodes from inside U-arguments, `junction_depth` strictly decreases when it was >= 2.
  - The proof uses: `junction_depth` counts S-U alternations. An S inside a U contributes to `junction_depth_U`. Replacing it with an atom (which has junction_depth 0) removes that alternation.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

**Timing**: 2 hours

**Depends on**: none (independent of Phase 7)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- all new definitions and lemmas

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes
- All new lemmas have no sorry
- `lean_verify` on `abstract_snce_correct` shows no axioms from SeparationThm.lean

---

### Phase 6B: Prove Main Hierarchy Theorem [NOT STARTED]

**Goal**: Prove `junction_depth_separable` -- the main theorem that every formula is separable -- via strong induction on `junction_depth (expand_temporal φ)`, with a separate `U_depth_under_S` subroutine (GHR94 Lemma 10.2.7).

**MANDATORY APPROACH**: Single-layer `Nat.strongRecOn` on `junction_depth (expand_temporal φ)`. NOT nested `(JD, count_U)`. A separate lemma handles the `no_S_nested_in_U` case by induction on `U_depth_under_S`.

**Mathematical Structure (GHR94)**:
- Subroutine (Lemma 10.2.7): `no_S_nested_in_U φ → is_separable φ` by induction on `U_depth_under_S φ`
- Main theorem (Lemma 10.2.8): `∀ φ, is_separable φ` by strong induction on `junction_depth (expand_temporal φ)`, calling the subroutine when S-nodes inside U-args are abstracted away

**Tasks**:

- [ ] Task 6B.1: Prove `no_S_nested_in_U_separable` subroutine (~200 LOC)
  - Location: `Hierarchy.lean`
  - Type:
    ```lean
    theorem no_S_nested_in_U_separable (φ : Formula) (h : no_S_nested_in_U φ = true) :
        is_separable φ
    ```
  - Proof by `Nat.strongRecOn` on `U_depth_under_S φ` (already defined in Defs.lean):
    - **Base (U_depth = 0)**: No U under S means formula is syntactically separated after `expand_temporal`. Use `expanded_jd_zero_imp_separated`.
    - **Inductive step (U_depth > 0)**: Find the deepest U-subformulas (those with U_depth = 1 in their S-arguments). Use `abstract_untl` to replace each such U with an atom. The abstracted formula has lower `U_depth_under_S`. Apply IH. Resubstitute using `abstract_untl_equiv`.
  - Uses existing infrastructure: `abstract_untl`, `abstract_untl_equiv`, `abstract_untl_preserves_no_S_nested`, `abstract_untl_count_le`, `count_U_zero_iff_U_free`
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

- [ ] Task 6B.2: Prove `junction_depth_separable` main theorem (~200 LOC)
  - Location: `Hierarchy.lean`, after `no_S_nested_in_U_separable`
  - Type:
    ```lean
    theorem junction_depth_separable (φ : Formula) : is_separable φ
    ```
  - Proof structure:
    1. Apply `expand_temporal_equiv` to reduce to the expanded formula (no `all_past`/`all_future`)
    2. Strong induction on `junction_depth (expand_temporal φ)`:
       - **jd = 0**: Use `expanded_jd_zero_imp_separated` (already proved in TemporalClosure.lean)
       - **jd = 1**: The formula has U/S at top level but no S-inside-U or U-inside-S at depth. It satisfies `no_S_nested_in_U` (or its dual). Apply `no_S_nested_in_U_separable`.
       - **jd >= 2**: There exists an S-node inside a U-argument (or vice versa). Apply `abstract_snce` to replace that S with an atom. By `abstract_snce_inside_untl_jd_lt`, junction_depth decreases. Apply IH at lower jd. Resubstitute using `abstract_snce_correct` + `abstract_untl_equiv` pattern.
    3. The symmetric case (U inside S): Apply `abstract_untl` to replace U with atom. Similar decrease argument.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes, no sorry

- [ ] Task 6B.3: Wire `multi_U_formula_separable` to proved theorem (~5 LOC)
  - At Hierarchy.lean line 594-596, change:
    ```lean
    -- FROM:
    theorem multi_U_formula_separable (phi : Formula) (h : no_S_nested_in_U phi) :
        is_separable phi :=
      all_separable phi
    -- TO:
    theorem multi_U_formula_separable (phi : Formula) (h : no_S_nested_in_U phi) :
        is_separable phi :=
      junction_depth_separable phi
    ```
  - Also wire `single_U_formula_separable` if it still uses axioms
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

**Timing**: 3 hours

**Depends on**: Phase 6A (needs `abstract_snce` and junction-depth lemmas)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- main theorems + wiring

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes
- `lean_verify` on `junction_depth_separable` shows no axioms from SeparationThm.lean
- All new theorems have no sorry

---

### Phase 6C: Derive Axioms as Theorems [NOT STARTED]

**Goal**: Replace all 9 `axiom` declarations in SeparationThm.lean with `theorem` proofs using the hierarchy.

**Tasks**:

- [ ] Task 6C.1: Derive the 4 `is_separable` temporal closure theorems (~40 LOC)
  - Replace each of these with a proof:
    - `all_past_separable`: `theorem all_past_separable (φ : Formula) (h : is_separable φ) : is_separable (.all_past φ) := junction_depth_separable (.all_past φ)`
    - `all_future_separable`: Same pattern
    - `untl_separable`: Same pattern
    - `snce_separable`: Same pattern
  - Note: Since `junction_depth_separable` proves ALL formulas separable unconditionally, the hypothesis `h : is_separable φ` is not even needed. Each axiom becomes a trivial corollary.
  - Verification: `lake build` passes

- [ ] Task 6C.2: Derive the 4 `is_properly_separable` temporal closure theorems (~60 LOC)
  - These are: `all_past_properly_separable`, `all_future_properly_separable`, `untl_properly_separable`, `snce_properly_separable`
  - Two approaches:
    - **Direct**: If `junction_depth_separable` can be strengthened to prove `is_properly_separable` directly (by targeting proper separation in the hierarchy), these become trivial corollaries.
    - **Bridge**: Prove `separable_implies_properly_separable` and compose. This bridge exists because the GHR94 separation procedure produces syntactically separated formulas whose temporal arguments are genuinely past-only/future-only.
  - If the bridge is needed, its proof uses: `is_syntactically_separated` ensures U-args are S-free and S-args are U-free. Combined with `expand_temporal` pre-processing (no `all_past`/`all_future` remain), S-free = future-only and U-free = past-only.
  - Verification: `lake build` passes

- [ ] Task 6C.3: Derive `proper_separation_preserves_atoms` theorem (~30 LOC)
  - Type:
    ```lean
    theorem proper_separation_preserves_atoms (φ : Formula) :
        ∃ ψ : Formula, is_properly_separated ψ = true ∧ int_equiv φ ψ ∧
        formula_atoms ψ ⊆ formula_atoms φ
    ```
  - Proof: The hierarchy procedure (`abstract_untl`/`abstract_snce` + resubstitution) only uses atoms already present in φ plus temporary fresh atoms that are resubstituted away. After full processing, the output contains only original atoms.
  - This requires threading an atom-tracking invariant through the hierarchy. If complex, it can be proved by showing `junction_depth_separable` produces a witness with `formula_atoms ψ ⊆ formula_atoms φ` (modify the theorem to return a Sigma type with this property).
  - Verification: `lake build` passes

- [ ] Task 6C.4: Update SeparationThm.lean to use theorems (~20 LOC)
  - Change all 9 `axiom` declarations to `theorem` declarations with proofs routing through the hierarchy
  - Remove any `axiom` keyword from the file
  - Verification: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty

- [ ] Task 6C.5: Verify axiom-free Separation stack
  - `lake build` passes
  - `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns only DualEliminations.lean (dead code)
  - `lean_verify` on `all_separable` shows no axioms
  - `lean_verify` on `US_expressively_complete_over_Z` shows no axioms

**Timing**: 2 hours

**Depends on**: Phase 6B (needs `junction_depth_separable`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace 9 axioms with theorems
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add atom-tracking variant if needed

**Verification**:
- `lake build` passes
- `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- `lean_verify` on `all_separable` and `US_expressively_complete_over_Z` show no axioms

---

### Phase 8: Final Integration and Verification [NOT STARTED]

**Goal**: End-to-end verification that the entire proof chain is sorry-free and axiom-free.

**Tasks**:

- [ ] Task 8.1: Run `lake build` and verify clean build (no errors, no sorry warnings except in DualEliminations and other non-critical files)
- [ ] Task 8.2: Verify sorry-free ExpressiveCompleteness:
  - `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- [ ] Task 8.3: Verify axiom-free Separation:
  - `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- [ ] Task 8.4: Verify `US_expressively_complete_over_Z` with `lean_verify`:
  - No sorry in transitive closure
  - No axioms from SeparationThm.lean in transitive closure
- [ ] Task 8.5: Update documentation comments in SeparationThm.lean and ExpressiveCompleteness.lean to reflect axiom-free/sorry-free status
- [ ] Task 8.6: Clean up any unused imports or dead helper lemmas introduced during development

**Timing**: 1 hour

**Depends on**: 7B, 6C

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- doc comments
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- doc comments, cleanup

**Verification**:
- All checks from Tasks 8.1-8.4 pass
- `lake build` clean

---

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- [ ] `lean_verify` on `US_expressively_complete_over_Z` shows no sorry AND no SeparationThm axioms
- [ ] `lean_verify` on `junction_depth_separable` shows no axioms
- [ ] `lean_verify` on `no_S_nested_in_U_separable` shows no axioms

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/07_complete-remaining-plan.md` (this file, v10)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- atom containment lemmas, elimExtFromSep_correct, quantElimFormula_correct_iff, atom_elim_correct proof
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- abstract_snce, junction-depth lemmas, no_S_nested_in_U_separable, junction_depth_separable
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 9 axioms replaced with theorems

## Rollback/Contingency

- **Phase 7 sufficient alone**: Phase 7 (sorry-free ExpressiveCompleteness) is independently valuable. If Phase 6 proves too costly, the axioms remain as sound placeholders. The expressiveness theorem holds.
- **Phase 6 partial**: If only the 4 `is_separable` axioms can be eliminated (proper separation bridge is hard), that is still meaningful progress. Document remaining axioms as known debt.
- **Git safety**: Commit after EACH completed task. If a later task fails, earlier progress is preserved.
- **Priority order**: Phase 7A -> Phase 7B (sorry-free, highest value) -> Phase 6A -> Phase 6B -> Phase 6C (axiom-free, secondary) -> Phase 8 (cleanup).
- **Time constraint fallback**: If only 4 hours available, do Phase 7A + 7B only. If 8 hours, add Phase 6A + 6B. Phase 6C + 8 are final polish.
