# Implementation Plan: Task #157 (v8) -- Dedekind + Generalized Case 1 Approach

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Task 155 (completed phases provide infrastructure)
- **Research Inputs**: reports/05_team-research.md (Dedekind breakthrough), reports/05_teammate-d-findings.md (Case 5 formulas), reports/05_teammate-c-findings.md (snce refutation), reports/05_phase7-remainder.md (Phase 7 detailed breakdown), reports/04_team-research.md (Phase 6 blocker resolution), reports/03_team-research.md (expand_temporal breakthrough)
- **Artifacts**: plans/05_dedekind-approach-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## MANDATORY APPROACH

**Phase 6 MUST use the Dedekind formula specialization + generalized Case 1 approach.** The implementation agent MUST NOT deviate to attempt junction-depth WF induction, structural induction on `no_S_nested_in_U`, or any other alternative approach. These alternatives have been tried repeatedly (6+ attempts documented in plan v7 BLOCKER section) and failed. The Dedekind approach is the ONLY path that has Lean-verified intermediate steps (K+/K-=FALSE verified, Q is U-free verified, generalized Case 1 separation verified).

**Prohibited deviations**:
- Do NOT attempt `Nat.strongRecOn` on junction_depth
- Do NOT attempt compound lexicographic measures `(JD, count_U, S_nesting)`
- Do NOT attempt strengthened structural induction hypotheses
- Do NOT attempt `count_U_under_S` composite measures
- Do NOT use `sorry`, `def X := True`, or any vacuous placeholder
- Follow the exact task sequence 6.A through 6.J below

## Overview

Plan v8 replaces the blocked Phase 6 from plan v7 with the Dedekind + generalized-Case-1 approach discovered in Report 05. The key breakthrough is twofold: (1) Teammate D discovered that `is_S_free q` in `elim_case_1` is dead code -- the separation proof only uses `is_U_free q` -- enabling a generalized Case 1 that handles Cases 5-8 directly; (2) the Dedekind formula (GHR94 Lemma 10.3.11) specialized to Z (with K+=K-=FALSE, Gamma+-=bot) produces a 3-disjunct formula for Case 5 whose guard Q = B v NOT S(not q, not A) v A is U-free, making it amenable to generalized Case 1 without `all_separable` or WF recursion.

Teammate C's critical correction (Report 05): `no_S_nested_in_U(snce C F)` RECURSES (does NOT require U-free args). The snce case is the HARD case, not the trivial one as claimed in plans v6-v7. The Dedekind approach sidesteps this entirely by providing explicit Case 5-8 formulas that do not require solving the snce structural induction.

Definition of done: `lake build` passes with zero axioms in SeparationThm.lean and zero sorry in ExpressiveCompleteness.lean.

### Research Integration

Report 05 (team research, 4 teammates + Phase 7 remainder) provided the following findings integrated into this plan:
1. **Teammate D**: Dead hypothesis discovery in `elim_case_1` -- `is_S_free q` is unused, enabling generalized Case 1. Dedekind formula for Case 5 specialized to Z with explicit 3-disjunct formula. K+/K-=FALSE corrected (not TRUE as in Report 04). Case 7 both disjuncts are directly separated for atoms.
2. **Teammate C**: REFUTED snce-trivial claim -- `no_S_nested_in_U(snce C F)` recurses. Confirmed abstract_untl+subst breaks separation. Proposed strengthened IH and count_U_under_S alternatives (NOT adopted -- Dedekind approach is simpler).
3. **Teammate B**: Verified 2-component measure `(JD, count_U)` compiles in nested `Nat.strongRecOn` (relevant only if Dedekind fallback needed).
4. **Teammate A**: Full hierarchy spec with `abstract_snce` requirements (relevant only if Dedekind fallback needed).
5. **Phase 7 remainder report**: Detailed breakdown of Tasks 7.6a-7.8 with exact Lean type signatures, proof strategy per constructor case, and implementation order DAG.

### Prior Plan Reference

Plan v7 (04_junction-depth-plan.md): Phases 1-5 completed successfully. Phase 6 was BLOCKED on the core `no_S_nested_in_U_separable` theorem -- junction-depth WF induction failed after 6+ attempts due to circular dependency between `snce_separable` and `all_separable`. Tasks 6.1-6.6 (expand_temporal infrastructure) and Tasks 6.8-6.9 (abstract_untl helpers) completed. Phase 7 is PARTIAL with Tasks 7.1-7.5b completed, Tasks 7.6a-7.8 remaining. Phase 8 was NOT STARTED.

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" in ROADMAP.md
- Advances "Phase 3 -- Expressive extensions" prerequisite (expressive completeness of {S,U})
- This is Reynolds Theorem 5, required as prerequisite for Phase 3B of task 155

## Goals & Non-Goals

**Goals**:
- Prove Cases 5-8 separability via Dedekind formula specialization + generalized Case 1 (no axioms, no WF recursion)
- Wire Cases 5-8 into `single_U_formula_separable`, `multi_U_formula_separable`, and `no_S_nested_in_U_separable`
- Derive all 4 weak temporal closure axioms as theorems from `no_S_nested_in_U_separable`
- Derive all 4 proper temporal closure axioms as theorems
- Replace all 8 axioms in SeparationThm.lean with proved theorems
- Complete `atom_elim_correct` and close all 3 sorries in ExpressiveCompleteness.lean
- Achieve zero-axiom, zero-sorry `lake build` for Separation/ + ExpressiveCompleteness stack

**Non-Goals**:
- Fixing DualEliminations.lean (dead code, 8 sorries, independent)
- Performance optimization of proof terms
- Implementing the full GHR94 10.2.8 junction-depth hierarchy (Dedekind approach replaces this)
- Implementing `abstract_snce` (not needed for Dedekind approach)
- Eliminating axioms outside the Separation/ directory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Dedekind Case 5 D2/D3 separation after substitution is harder than estimated (S(not q^U^phi', Q) term) | H | M | Teammate D estimated 85% confidence; if blocked, try distributing S over disjuncts in alpha before applying generalized Case 1. Explicit fallback: full hierarchy approach (~500 LOC) from Teammate A/B research |
| Generalized Case 2 (neg_until_equiv split) introduces unexpected complications | M | L | Case 2 proof structure parallels existing elim_case_2 exactly; neg_until_equiv is already proved and verified on Z |
| `elimExtFromSep_correct` structural induction (Phase 7 core) has complex `h_match` side conditions | M | M | Phase 7 report provides exact proof strategy per constructor; `applySubsts_past/future_correct` already proved; atom membership simp lemmas (Task 7.6a) must be done first |
| `freshAM_inj` threading breaks at some sorry site | L | L | Report confirms `freshAM_inj` is in scope at all 3 sorry sites; type signature verified |
| Phase 6 and Phase 7 interact unexpectedly when wiring through `all_properly_separable` | L | L | Phase 7 uses `all_properly_separable` which becomes available once Phase 6 eliminates axioms; bulk of Phase 7 work is independent |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 6 | -- (Phases 1-5 completed in v6) |
| 1 | 7 | -- (independent, partially completed) |
| 2 | 8 | 6, 7 |

Phases within the same wave can execute in parallel.

Note: Phases 1-5 from plan v6 are COMPLETED and not repeated here. Phase numbering continues from v6 for consistency.

---

### Phase 6: Prove Cases 5-8 via Dedekind + Generalized Case 1 and Eliminate 8 Axioms [NOT STARTED]

**Goal**: Prove Cases 5-8 separability using Dedekind formula specialization to Z (K+=K-=FALSE, Gamma+-=bot) combined with generalized Case 1 (dropping dead `is_S_free q` hypothesis), then wire through to replace all 8 axioms in SeparationThm.lean.

**MANDATORY**: Follow the exact task sequence below. Do NOT deviate to junction-depth WF induction or any alternative approach.

**Strategy**: The Dedekind approach avoids the circular `all_separable` dependency entirely:
1. Generalize Cases 1 and 2 by removing the dead `is_S_free q` hypothesis (the separation check only uses `is_U_free q`)
2. Prove Case 7 first (easiest -- both disjuncts are directly separated for atoms, Lean-verified)
3. Prove Case 5 using the Dedekind 3-disjunct formula where D1 is a Case 1 instance and D2/D3 use generalized Case 1 with U-free guard Q = B v NOT S(not q, not A) v A
4. Prove Cases 6, 8 via reduction: Case 6 reduces to Cases 2+5, Case 8 reduces via negation to Cases 5+2
5. Wire Cases 5-8 into `single_U_formula_separable` to replace the `all_separable _` shortcuts
6. Wire through `multi_U_formula_separable` and `no_S_nested_in_U_separable`
7. Derive 4 weak + 4 proper temporal closure theorems
8. Replace all 8 axioms in SeparationThm.lean

**CRITICAL CONTEXT from Teammate C**: The snce case of `no_S_nested_in_U` RECURSES (definition at Defs.lean lines 320-328: `.snce phi psi => no_S_nested_in_U phi AND no_S_nested_in_U psi`). It does NOT require U-free args. A formula like `snce (untl p q) r` satisfies `no_S_nested_in_U` but is NOT separated. The Dedekind approach sidesteps this difficulty by providing explicit separated equivalents for Cases 5-8 without needing to solve the snce structural induction.

**Tasks** (EXACT SEQUENCE -- follow in order):

- [ ] Task 6.A: Generalize `elim_case_1` by removing dead `is_S_free q` hypothesis (~50 LOC)
  - Create `elim_case_1_gen` (or similar name) in Eliminations.lean
  - Identical proof to `elim_case_1` but the type signature drops `is_S_free q = true` from hypotheses
  - The separation check `is_syntactically_separated (case1_psi a q A B) = true` holds with only `is_U_free q` (Lean-verified by Teammate D)
  - The existing `elim_case_1` proof does NOT use `is_S_free q` anywhere -- confirmed by code inspection
  - Verification: `lean_verify` on the new lemma shows no axioms

- [ ] Task 6.B: Similarly generalize `elim_case_2` (~80 LOC)
  - Create `elim_case_2_gen` in Eliminations.lean
  - Proof uses generalized Case 1 + `neg_until_equiv` to handle the S(a^NOT U, Q) pattern
  - S(a^NOT U(A,B), Q) with U-free Q splits via neg_until_equiv into:
    - S(a^G(NOT A), Q): U-free event, U-free Q -- `snce_u_free_separable` applies
    - S(a^U(NOT A^NOT B, NOT A), Q): generalized Case 1 with U-free Q
  - Verification: `lean_verify` shows no axioms

- [ ] Task 6.C: Prove Case 7 separability (~50 LOC) -- EASIEST, do first after 6.A/6.B
  - Case 7: S(a ^ U(A,B), q v NOT U(A,B))
  - Dedekind formula on Z produces two disjuncts, both directly separated for atoms:
    - Disjunct 1: S(a, B^q) ^ (A v (B^U(A,B))) -- S(atom, U-free) is separated; conjunction with S-free term is separated
    - Disjunct 2: S(S(a,B^q) ^ A ^ (q v NOT U), NOT U v q) -- U-free event, S-free guard, directly separated
  - Prove semantic equivalence of Case 7 to the 2-disjunct formula
  - Prove each disjunct is syntactically separated
  - Teammate D verified both disjuncts are separated in Lean
  - Verification: the separation proof compiles without axioms

- [ ] Task 6.D: Prove Case 5 separability via Dedekind 3-disjunct formula (~120 LOC) -- HARDEST subtask
  - Case 5: S(a ^ U(A,B), q v U(A,B))
  - Dedekind formula specialized to Z (K+=K-=FALSE, Gamma+-=FALSE):
    ```
    D1 = S(a ^ U(A,B), q)                                         -- Case 1 instance
    D2 = S(alpha, Q) ^ (A v (B ^ U(A,B)))                         -- generalized Case 1
    D3 = S(A ^ (q v U(A,B)) ^ S(alpha, Q), q)                    -- uses separated D2
    where:
      Q     = B v NOT S(not q, not A) v A                          -- U-FREE (verified)
      alpha = (a ^ U(A,B)) v (not q ^ U(A,B) ^ S(a ^ U(A,B), q))
    ```
  - Disjunct 4 from GHR94 VANISHES on Z (Gamma+=FALSE makes S(FALSE^..., q) = bot)
  - Step 1: Prove semantic equivalence of Case 5 LHS to D1 v D2 v D3
  - Step 2: D1 is a Case 1 instance (already proved, ~5 LOC)
  - Step 3: For D2, S(alpha, Q) where Q is U-free. Alpha contains U(A,B) but alpha is the event of S, not the guard. Apply Lemma 10.2.1 to split alpha into sub-cases, each handled by generalized Case 1 with U-free Q
  - Step 4: For D3, event contains the separated form of S(alpha, Q) from D2, combined with A and (q v U). Apply generalized Case 1 to handle the U in the event
  - Key risk: Step 3's S(not q^U^S(a^U,q), Q) after substituting Case 1's separated form for S(a^U,q). The separated form has U at top level, so distributing and re-applying generalized Case 1 should work
  - Verification: `lean_verify` shows no axioms

- [ ] Task 6.E: Prove Cases 6 and 8 separability via reduction (~100 LOC)
  - Case 6: S(a ^ NOT U(A,B), q v U(A,B))
    - Apply neg_until_equiv to NOT U(A,B), then reduce to Cases 2 + 5
    - Specialized to Z: alpha simplifies (second disjunct of alpha vanishes due to not q ^ q = bot)
    - D2 becomes S(a ^ NOT U, Q) with S-free event -- generalized Case 2 applies
  - Case 8: S(a ^ NOT U(A,B), q v NOT U(A,B))
    - Uses negation: NOT(Case 8 formula) reduces via neg_since_equiv to a combination of Cases 5 + 2
    - Book says "use eliminations (2) and (5)" -- Case 5 is now proved (Task 6.D)
  - Verification: `lean_verify` shows no axioms for both cases

- [ ] Task 6.F: Wire Cases 5-8 into `single_U_formula_separable` (~30 LOC)
  - In NormalForm.lean (or wherever case5_separable through case8_separable are defined)
  - Replace the current `all_separable _` shortcuts with the proved Cases 5-8
  - `single_U_formula_separable` dispatches on event/guard U-polarity to Cases 1-8
  - After this task, `single_U_formula_separable` is axiom-free
  - Verification: `grep -n "all_separable" NormalForm.lean` returns empty (excluding comments)

- [ ] Task 6.G: Wire through `multi_U_formula_separable` and `no_S_nested_in_U_separable` (~30 LOC)
  - In Hierarchy.lean, replace `multi_U_formula_separable`'s shortcut to `all_separable` (line ~547) with the actual proof via `single_U_formula_separable`
  - `no_S_nested_in_U_separable` follows from `multi_U_formula_separable` + the existing infrastructure
  - `no_U_nested_in_S_separable` via `swap_temporal` duality (~10 LOC)
  - Verification: `lean_verify` on `no_S_nested_in_U_separable` shows no axioms

- [ ] Task 6.H: Derive 4 weak + 4 proper temporal closure theorems (~80 LOC)
  - In SeparationThm.lean:
    - `snce_separable`: separated args -> box-normalize -> `replace_box_separated_no_S_nested` -> `no_S_nested_in_U_separable`
    - `untl_separable`: via `swap_temporal` duality from `snce_separable`
    - `all_past_separable`: via `expand_temporal` equivalence + `snce_separable`
    - `all_future_separable`: via duality
  - 4 proper variants follow from weak variants + proper separability closure lemmas (already exist in Defs.lean)
  - Verification: all 8 theorems compile cleanly

- [ ] Task 6.I: Replace 8 axioms in SeparationThm.lean (~20 LOC)
  - Change `axiom` to `theorem` for all 8 temporal closure declarations
  - Attach the proofs from Task 6.H
  - Verification: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty

- [ ] Task 6.J: Verify `lake build` with 0 axioms in Separation/
  - Run `lake build` and confirm clean build
  - Run `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and verify only DualEliminations.lean (dead code) if any
  - Run `lean_verify` on key theorems to confirm no axioms in transitive closure

**Timing**: 5 hours

**Depends on**: none (Phases 1-5 completed in v6; Tasks 6.1-6.6 and 6.8-6.9 completed in v7)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- add `elim_case_1_gen`, `elim_case_2_gen`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- replace `all_separable _` in case5-8_separable with direct proofs; add Dedekind formula definitions and semantic equivalence proofs
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- replace `multi_U_formula_separable` shortcut; wire `no_S_nested_in_U_separable`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace 8 axioms with theorems

**Verification**:
- `lake build` passes
- `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns only DualEliminations.lean (if any)
- `lean_verify` on `no_S_nested_in_U_separable` shows no axioms

---

### Phase 7: Complete Theorem 9.3.1 -- Quantifier Cases (atom_elim_correct) [PARTIAL]

**Goal**: Close the 3 remaining sorries in ExpressiveCompleteness.lean by proving `atom_elim_correct` via `elimExtFromSep_correct`, `guardFormula_correct`, and `quantElimFormula_correct_iff`.

**Note**: Independent of Phase 6. Can execute in parallel. Worked on by previous agents (6 sessions total); Tasks 7.1-7.5b completed, reducing from 2 sorry-pairs to 3 focused sorries all requiring the same biconditional.

**Strategy**: The 3 sorries (lines 893, 940, 947) all reduce to a single biconditional `atom_elim_correct`:
```
int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep
  <->
int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep)
```

The proof decomposes into a small DAG:
```
(7.6a) Atom membership lemmas
          |
(7.6c) elimExtFromSep_correct  (+ existing applySubsts_past/future_correct)
          |
(7.6d) quantElimFormula_correct_iff  (+ (7.6b) guardFormula_correct)
          |
(7.6e) atom_elim_correct
          |
(7.7) Close 3 sorries
```

**Completed Tasks**:
- [x] Task 7.1: Restructure `expressiveness_fixed_atomMap` for WF induction on qdepth
- [x] Task 7.2: Build quantifier elimination infrastructure (quantElimFormula, elimExtFromSep, applySubsts, origSubsList, constSubsList, guardFormula)
- [x] Task 7.3: Prove purity lemmas and quantifier-free cases (subst_preserves_past_only, subst_preserves_future_only)
- [x] Task 7.4: Define elimExtAtoms level-aware substitution (implemented as elimExtFromSep)
- [x] Task 7.5: Implement case-split assembly over Fintype (sig.preds -> Bool)
- [x] Task 7.5b: Prove applySubsts_past_correct and applySubsts_future_correct

**Remaining Tasks**:

- [ ] Task 7.6a: Prove atom membership simp lemmas (~30 LOC, easy)
  - 4 simp lemmas for `z in (to_int_struct (extIntStruct M t) freshAM).val (freshAM ep)`:
    - `ep = .orig p`: iff `M.interp p z`
    - `ep = .const_at_ref p`: iff `M.interp p t` (constant in z)
    - `ep = .lt_ref`: iff `z < t`
    - `ep = .gt_ref`: iff `t < z`
  - Requires `freshAM_inj` to separate contributions
  - Each proof: unfold `to_int_struct`, `Set.mem_setOf_eq`, use injectivity to rule out other predicates

- [ ] Task 7.6b: Prove `guardFormula_correct` (~30 LOC, medium)
  - Type: `int_truth (to_int_struct M atomMap) t (guardFormula atomMap sigma) <-> (forall p, sigma p = true <-> M.interp p t)`
  - Unfold the `foldl` over `Finset.univ.toList`, split on each predicate, use Finset membership

- [ ] Task 7.6c: Prove `elimExtFromSep_correct` (~100 LOC, hard -- core structural induction)
  - By structural induction on properly separated `B_sep`
  - Constructor cases:
    - `atom a`: use atom membership lemmas, substitution lookup
    - `bot`: trivial (both sides False)
    - `imp phi psi`: IH on both sides, compose with `Iff.imp`
    - `box phi`: degenerate (both sides True in IntStructure)
    - `all_past phi` (past-only by `hB_sep`): use `applySubsts_past_correct` with past subs `(lt -> neg bot, gt -> bot)`; for s < t, lt_ref is TRUE, gt_ref is FALSE -- matches substitutions
    - `all_future phi` (future-only by `hB_sep`): symmetric, use `applySubsts_future_correct` with `(lt -> bot, gt -> neg bot)`
    - `snce phi psi` (both past-only): same as all_past, use `applySubsts_past_correct` for both args
    - `untl phi psi` (both future-only): same as all_future
  - Key dependencies: atom membership lemmas (Task 7.6a) must be done first
  - Must supply `h_reps_po`/`h_reps_fo` and `h_match` side conditions for `applySubsts_past/future_correct`

- [ ] Task 7.6d: Prove `quantElimFormula_correct_iff` (~40 LOC, medium)
  - Unfolds the `List.foldl Formula.or` disjunction over all assignments `sigma`
  - Finds the unique matching sigma via `guardFormula_correct`
  - Define sigma_star by `sigma_star p = decide (M.interp p t)`, show guard is true for this sigma and false for all others
  - Use classical reasoning (`Classical.choice` or `Finset.exists_unique`) for the existential witness

- [ ] Task 7.6e: Prove `atom_elim_correct` glue (~15 LOC, easy)
  - Combines `quantElimFormula_correct_iff` + `elimExtFromSep_correct` at the witness sigma extracted from the model
  - Bridges from M_ext to M_orig

- [ ] Task 7.7: Close 3 remaining sorries using `atom_elim_correct` (~5 LOC)
  - Line 893: replace `h_chain.trans sorry` with `h_chain.trans (atom_elim_correct ...)`
  - Line 940: replace `sorry` with `(atom_elim_correct ...).mpr h_Aex`
  - Line 947: replace `sorry` with `(atom_elim_correct ...).mp h_bsep`

- [ ] Task 7.8: Verify `lake build` passes with 0 sorry in ExpressiveCompleteness.lean
  - Run `lake build` and confirm clean build
  - Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
  - `lean_verify` on `US_expressively_complete_over_Z`

**Timing**: 4 hours

**Depends on**: none (independent of Phase 6; uses `all_properly_separable` which becomes available once Phase 6 completes, but bulk of work proceeds in parallel)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- add atom membership lemmas, guardFormula_correct, elimExtFromSep_correct, quantElimFormula_correct_iff, atom_elim_correct; close 3 sorries

**Verification**:
- `lake build` passes
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- `separation_implies_expressiveness` and `US_expressively_complete_over_Z` compile cleanly

---

### Phase 8: Final Integration and Verification [NOT STARTED]

**Goal**: Full end-to-end verification that the proof chain is complete and axiom-free.

**Tasks**:
- [ ] Task 8.1: Run `lake build` and verify clean build with no warnings
- [ ] Task 8.2: Run `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and verify empty output (excluding DualEliminations.lean dead code)
- [ ] Task 8.3: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` and verify empty output
- [ ] Task 8.4: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and verify only DualEliminations.lean (dead code)
- [ ] Task 8.5: Verify `US_expressively_complete_over_Z` has no axioms in its transitive closure (use `lean_verify` MCP tool)
- [ ] Task 8.6: Verify `no_S_nested_in_U_separable` has no axioms in its transitive closure (use `lean_verify`)
- [ ] Task 8.7: Update documentation comments in SeparationThm.lean and ExpressiveCompleteness.lean to reflect axiom-free status
- [ ] Task 8.8: Clean up any unused imports or dead code introduced during development

**Timing**: 1 hour

**Depends on**: 6, 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- update doc comments
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- update doc comments
- Possibly remove unused helpers from TemporalClosure.lean or Hierarchy.lean

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

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/05_dedekind-approach-plan.md` (this file, v8)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- `elim_case_1_gen`, `elim_case_2_gen`
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- Cases 5-8 direct proofs replacing `all_separable` shortcuts; Dedekind formula definitions
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- `multi_U_formula_separable` shortcut replaced; `no_S_nested_in_U_separable` wired
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 8 axioms replaced with theorems
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- atom_elim_correct and 3 sorries closed

## Rollback/Contingency

- **Phase 6 fallback (if Dedekind D2/D3 separation fails)**: Implement the full GHR94 10.2.8 junction-depth hierarchy with `abstract_snce` (~120 LOC) + nested `Nat.strongRecOn` on 2-component measure `(JD, count_U)` (~500-720 LOC total). Teammate B verified the `Nat.strongRecOn` pattern compiles. This is higher LOC and risk but mathematically complete.
- **Phase 6 partial fallback**: If only Cases 5 and 7 succeed but Cases 6 and 8 resist, keep 4 axioms (snce/untl weak + proper) and prove 4 (all_past/all_future weak + proper). This is still meaningful progress.
- **Phase 7 fallback**: If `elimExtFromSep_correct` structural induction is intractable for the `all_past`/`all_future` cases, the 3 sorries remain but separation theorem is fully proved (Phase 6 is the critical path).
- **Priority if time-constrained**: Phase 6 (axiom elimination) > Phase 7 (sorry closure) > Phase 8 (cleanup). Phase 6 alone validates the entire separation theorem proof chain.
- **Git safety**: Each task within Phase 6 should be committed individually so that partial progress is preserved if a later task fails.
