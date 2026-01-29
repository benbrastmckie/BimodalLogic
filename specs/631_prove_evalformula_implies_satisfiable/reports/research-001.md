# Research Report: Task #631

**Task**: 631 - Prove evalFormula_implies_satisfiable bridging lemma
**Started**: 2026-01-29T10:00:00Z
**Completed**: 2026-01-29T10:45:00Z
**Effort**: 45 minutes
**Priority**: Medium
**Dependencies**: Task 630 (completed - BranchTaskModel extraction)
**Related**: Tasks 624, 628, 623
**Sources/Inputs**:
- CountermodelExtraction.lean (evalFormula, branchTruthLemma)
- BranchTaskModel.lean (extractBranchTaskModel, extractBranchWorldHistory)
- Truth.lean (truth_at definition)
- Task 628 research report (upward bridge analysis)
- Lean MCP tools for theorem verification
**Artifacts**:
- specs/631_prove_evalformula_implies_satisfiable/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The task requires proving `evalFormula_implies_satisfiable`: if `evalFormula b phi = false` for a saturated open branch, then phi is not satisfiable in the extracted TaskModel
- **Key insight**: The existing `branchTruthLemma` already provides the core correspondence between signed formulas in the branch and `evalFormula` evaluation
- **Critical discovery**: The current `evalFormula` treats modal/temporal operators as IDENTITY (simplified semantics), while `truth_at` quantifies over ALL histories/times
- **Two approaches identified**:
  1. **Direct approach (BLOCKED)**: Prove evalFormula = false implies truth_at = false. This requires showing that the simplified evaluation matches full semantics, which is problematic for box/temporal cases.
  2. **Contrapositive via branchTruthLemma (VIABLE)**: Use the existing branchTruthLemma to show that F(phi) in branch implies truth_at M tau 0 phi = false
- **Recommendation**: Leverage `branchTruthLemma` + `atom_true_iff_pos_in_branch` from BranchTaskModel.lean for the semantic bridge

## Context & Scope

### Task Purpose

Task 631 is part of the decidability procedure (parent Task 490) and addresses the blocker identified in Task 623 Phase 3. The goal is to connect the tableau-based propositional evaluation (`evalFormula`) to the full task frame semantics (`truth_at`).

### The Bridge Gap

The decidability proof needs to show:
1. Valid formulas have closing tableaux (soundness - already proven)
2. Invalid formulas have open saturated branches that yield countermodels (completeness - blocked)

For (2), we need to show that the extracted TaskModel from a saturated open branch actually falsifies the formula. Currently:
- `evalFormula` provides simplified propositional evaluation (modal/temporal as identity)
- `truth_at` provides full semantics (box quantifies over histories, temporal quantifies over times)

### Current Infrastructure (Task 630)

Task 630 has already built:
- `BranchWorldState`: World state type from branch atoms
- `BranchTaskFrame`: TaskFrame with permissive task relation
- `extractBranchTaskModel`: TaskModel with branch-derived valuation
- `extractBranchWorldHistory`: Constant history at branch world state
- `atom_true_iff_pos_in_branch`: Key lemma connecting valuation to branch membership
- `atom_false_if_neg_in_open_branch`: Atoms false when negatively signed

### The Semantic Mismatch Problem

**evalFormula definition** (CountermodelExtraction.lean:160-166):
```lean
def evalFormula (b : Branch) : Formula -> Bool
  | .atom p => extractValuation b p
  | .bot => false
  | .imp phi psi => !evalFormula b phi || evalFormula b psi
  | .box phi => evalFormula b phi  -- SIMPLIFIED: modal as identity
  | .all_future phi => evalFormula b phi  -- SIMPLIFIED: temporal as identity
  | .all_past phi => evalFormula b phi   -- SIMPLIFIED: temporal as identity
```

**truth_at definition** (Truth.lean:108-114):
```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M tau t phi -> truth_at M tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M tau s phi
```

**The Problem**:
- `evalFormula (.box phi) = evalFormula phi` (identity)
- `truth_at (.box phi)` = `forall sigma, truth_at M sigma t phi` (universal quantification)

These do NOT directly correspond!

## Findings

### Approach 1: Direct evalFormula-to-truth_at Bridge (BLOCKED)

**Attempt**: Prove `evalFormula b phi = false -> ¬truth_at M tau 0 phi` by induction on phi.

**Analysis by case**:

| Case | evalFormula | truth_at | Gap |
|------|-------------|----------|-----|
| atom | extractValuation | exists domain, valuation | Bridged by atom_true_iff_pos_in_branch |
| bot | false | False | Trivial |
| imp | material implication | material implication | Requires bidirectional IH |
| box | evalFormula phi | forall histories, truth_at | **MAJOR GAP** |
| all_future | evalFormula phi | forall s >= t, truth_at | **MAJOR GAP** |
| all_past | evalFormula phi | forall s <= t, truth_at | **MAJOR GAP** |

**Box Case Analysis**:
- `evalFormula b (.box phi) = evalFormula b phi` says phi evaluated at current branch
- `truth_at M tau 0 (.box phi)` says phi true at ALL histories at time 0
- To show `evalFormula = false -> ¬truth_at`:
  - Need: `evalFormula b phi = false -> exists sigma, ¬truth_at M sigma 0 phi`
  - The IH gives: `evalFormula b phi = false -> ¬truth_at M tau 0 phi` (specific history)
  - This suffices! `tau` witnesses the existential.

**Wait - this might work after all!**

Re-analyzing more carefully:

For box direction `evalFormula false -> truth_at false`:
- Goal: `evalFormula b (.box phi) = false -> ¬truth_at M tau 0 (.box phi)`
- Expand: `evalFormula b phi = false -> ¬(forall sigma, truth_at M sigma 0 phi)`
- Equivalent: `evalFormula b phi = false -> exists sigma, ¬truth_at M sigma 0 phi`
- By IH: `evalFormula b phi = false -> ¬truth_at M tau 0 phi`
- So `tau` witnesses the exists!

**Key Insight**: The simplified evaluation being FALSE is actually EASIER to lift to full semantics because we only need ONE counterexample history, not ALL histories!

### Approach 2: Leverage branchTruthLemma (VIABLE - RECOMMENDED)

**The branchTruthLemma** (CountermodelExtraction.lean:279-419):
```lean
theorem branchTruthLemma (b : Branch) (hSat : findUnexpanded b = none)
    (hOpen : findClosure b = none) :
    forall sf in b, (sf.sign = .pos -> evalFormula b sf.formula = true) ∧
                    (sf.sign = .neg -> evalFormula b sf.formula = false)
```

This says:
- T(phi) in saturated open branch implies evalFormula b phi = true
- F(phi) in saturated open branch implies evalFormula b phi = false

**Strategy**:
1. The tableau starts with F(phi) in the initial branch
2. For saturated open branch, F(phi) propagates through to the branch
3. By branchTruthLemma: `evalFormula b phi = false`
4. Need to show: `evalFormula b phi = false -> ¬truth_at M tau 0 phi`

This is exactly what Approach 1 attempts, and it DOES work with the insight above!

### Proof Sketch for evalFormula_implies_not_truth_at

**Theorem Statement**:
```lean
theorem evalFormula_implies_not_truth_at (b : Branch)
    (hSat : findUnexpanded b = none) (hOpen : findClosure b = none)
    (M : TaskModel BranchTaskFrame := extractBranchTaskModel b)
    (tau : WorldHistory BranchTaskFrame := extractBranchWorldHistory b) :
    forall phi, evalFormula b phi = false -> ¬truth_at M tau 0 phi
```

**Proof by structural induction on phi**:

**Atom case**:
- `evalFormula b (.atom p) = false` means `extractValuation b p = false`
- `extractValuation b p = false` means `SignedFormula.pos (.atom p) ∉ b`
- By `atom_true_iff_pos_in_branch`: not having T(p) means valuation is false
- `truth_at M tau 0 (.atom p)` requires domain membership + valuation true
- For constant history, domain is True everywhere, so need valuation false
- This follows from the valuation definition

**Bot case**: Vacuous (evalFormula bot = false always, and truth_at bot = False)

**Imp case**:
- `evalFormula b (.imp phi psi) = false` means `evalFormula b phi = true AND evalFormula b psi = false`
- Need bidirectional induction (both directions)
- For the TRUE direction: need `evalFormula b phi = true -> truth_at M tau 0 phi`
- This is the HARDER direction (task 628 already analyzed this)

**PROBLEM IDENTIFIED**: The imp case requires BOTH directions!

**Box case** (false direction - EASIER):
- `evalFormula b (.box phi) = false` means `evalFormula b phi = false`
- Goal: `¬truth_at M tau 0 (.box phi)` means `exists sigma, ¬truth_at M sigma 0 phi`
- By IH: `evalFormula b phi = false -> ¬truth_at M tau 0 phi`
- Witness sigma = tau

**Temporal cases** (false direction - EASIER):
- Similar pattern: one counterexample suffices
- For all_future: witness s = 0 (reflexive semantics)
- For all_past: witness s = 0 (reflexive semantics)

### Required Lemmas Summary

| Lemma | Direction | Difficulty | Notes |
|-------|-----------|------------|-------|
| atom_false | false -> not truth_at | Easy | Uses atom_true_iff_pos_in_branch |
| atom_true | true -> truth_at | Medium | Needs domain membership |
| imp_false | false -> not truth_at | Medium | Requires true direction for antecedent |
| imp_true | true -> truth_at | Hard | Requires false direction for consequent |
| box_false | false -> not truth_at | Easy | One witness suffices |
| box_true | true -> truth_at | **BLOCKED** | Requires global saturation |
| temporal_false | false -> not truth_at | Easy | Reflexive point witnesses |
| temporal_true | true -> truth_at | **BLOCKED** | Requires bounded relevance |

### Approach 3: Restricted Statement (RECOMMENDED)

Given the asymmetry in difficulty, focus on what's needed for completeness:

**The Needed Statement**:
```lean
theorem evalFormula_false_implies_not_truth_at (b : Branch)
    (hSat : findUnexpanded b = none) (hOpen : findClosure b = none) :
    let M := extractBranchTaskModel b
    let tau := extractBranchWorldHistory b
    forall phi, evalFormula b phi = false -> ¬truth_at M tau 0 phi
```

This is STRICTLY WEAKER than the full bidirectional bridge but is EXACTLY what tableau completeness needs:
- F(phi) in branch
- By branchTruthLemma: evalFormula b phi = false
- By this theorem: ¬truth_at M tau 0 phi
- Therefore phi is not satisfiable at (M, tau, 0)

**The IMP case problem**: Still requires the true direction for the antecedent.

### Approach 4: Direct from branchTruthLemma (BEST)

**Key Observation**: The branchTruthLemma already handles the signed formula level. We can prove the bridge directly using signed formula membership rather than going through evalFormula.

**New Strategy**:
```lean
theorem neg_in_branch_implies_not_truth_at (b : Branch)
    (hSat : findUnexpanded b = none) (hOpen : findClosure b = none)
    (phi : Formula) (h_neg : SignedFormula.neg phi ∈ b) :
    let M := extractBranchTaskModel b
    let tau := extractBranchWorldHistory b
    ¬truth_at M tau 0 phi
```

**Proof by cases on formula structure**:

The branchTruthLemma says F(phi) ∈ saturated branch is VACUOUSLY TRUE for non-atomic formulas because:
- F(phi -> psi) would have been expanded (not in saturated branch)
- F(box phi) would have been expanded
- F(G phi) would have been expanded
- F(H phi) would have been expanded

So the only F(_) formulas in a saturated branch are:
- F(atom p) - handled by atom_false_if_neg_in_open_branch
- F(bot) - handled by findClosure = none (bot cannot have F in open branch)

**This is the key insight from branchTruthLemma**: The saturation condition means complex formulas DON'T APPEAR signed!

### Existing Infrastructure Verification

Let me verify what theorems are already proven:

**From BranchTaskModel.lean** (proven):
- `atom_true_iff_pos_in_branch`: Atom truth in extracted model iff T(p) in branch
- `atom_false_if_neg_in_open_branch`: Atom false if F(p) in open branch

**From CountermodelExtraction.lean** (proven):
- `branchTruthLemma`: Complete correspondence for signed formulas
- `saturated_imp_expanded`: T(imp) cannot be in saturated branch (vacuous)
- `isExpanded_pos_*_false`: Various expansion lemmas

**From BranchClosure.lean** (proven):
- `open_branch_consistent`: No atom is both T(p) and F(p)

## Decisions

1. **The bridge lemma IS provable** for the false direction (evalFormula = false -> not truth_at)
2. **The true direction is NOT needed** for completeness - only need to show invalid formulas are falsified
3. **Saturation simplifies everything**: Most cases are vacuous because complex formulas get expanded
4. **The constant history suffices**: extractBranchWorldHistory provides a single witness

## Recommendations

### Primary Recommendation

**Implement a focused bridge lemma** that leverages saturation:

```lean
theorem evalFormula_implies_sat (b : Branch)
    (hSat : findUnexpanded b = none) (hOpen : findClosure b = none)
    (phi : Formula) :
    SignedFormula.neg phi ∈ b →
    let M := extractBranchTaskModel b
    let tau := extractBranchWorldHistory b
    ¬truth_at M tau 0 phi
```

**Proof structure**:
1. Use branchTruthLemma to establish evalFormula b phi = false
2. Case analysis on phi:
   - atom: Use atom_false_if_neg_in_open_branch to show valuation false
   - bot: Contradiction (F(bot) cannot close branch, but bot case is trivial)
   - imp/box/temporal: Use saturation_contradiction to show F(complex) not in saturated branch
3. For the atomic case, connect valuation false to ¬truth_at:
   - `branchWorldStateValuation w p = false` (from atom_false)
   - `truth_at` for atom requires: `exists ht, M.valuation (tau.states 0 ht) p`
   - With constant history: `tau.states 0 _ = extractBranchWorldState b`
   - So `M.valuation` uses `branchWorldStateValuation` on `extractBranchWorldState b`
   - By atom_false_if_neg_in_open_branch: this is false

### Implementation Order

1. **Phase 1**: Prove `neg_atom_in_branch_implies_not_truth_at` for atoms only
2. **Phase 2**: Use saturation lemmas to show F(complex) is vacuous
3. **Phase 3**: Combine into full `evalFormula_implies_sat` theorem

### Estimated Effort

| Phase | Effort | Confidence |
|-------|--------|------------|
| Phase 1 (atom case) | 1-2 hours | High |
| Phase 2 (saturation vacuity) | 1-2 hours | High |
| Phase 3 (integration) | 1 hour | High |
| **Total** | 3-5 hours | High |

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Domain membership for constant history | Low | Domain is True everywhere by design |
| Proof irrelevance issues | Low | Use standard WorldHistory.states idioms |
| Saturation lemmas incomplete | Medium | All needed isExpanded_*_false already proven |
| Universe level issues | Low | Already resolved in BranchTaskModel |

## Appendix

### Key Theorems and Locations

| Theorem | File | Line | Status |
|---------|------|------|--------|
| branchTruthLemma | CountermodelExtraction.lean | 279 | PROVEN |
| atom_true_iff_pos_in_branch | BranchTaskModel.lean | 332 | PROVEN |
| atom_false_if_neg_in_open_branch | BranchTaskModel.lean | 344 | PROVEN |
| open_branch_consistent | BranchClosure.lean | ~100 | PROVEN |
| saturation_contradiction | CountermodelExtraction.lean | 232 | PROVEN |
| isExpanded_pos_imp_false | CountermodelExtraction.lean | 176 | PROVEN |
| isExpanded_neg_imp_false | CountermodelExtraction.lean | 204 | PROVEN |

### Domain and Valuation for Constant History

The `constantBranchHistory` (BranchTaskModel.lean:242-246):
```lean
def constantBranchHistory (w : BranchWorldState) : WorldHistory BranchTaskFrame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => w
  respects_task := fun _ _ _ _ _ => trivial
```

This means:
- `tau.domain 0 = True` (always in domain)
- `tau.states 0 _ = extractBranchWorldState b` (constant everywhere)

### The Complete Proof Outline

```lean
theorem evalFormula_implies_sat (b : Branch)
    (hSat : findUnexpanded b = none) (hOpen : findClosure b = none)
    (phi : Formula) (h_neg : SignedFormula.neg phi ∈ b) :
    let M := extractBranchTaskModel b
    let tau := extractBranchWorldHistory b
    ¬truth_at M tau 0 phi := by
  cases phi with
  | atom p =>
    -- F(p) ∈ b, so valuation at p is false
    -- truth_at requires valuation to be true
    simp only [truth_at]
    intro ⟨_, h_val⟩
    have h_false := atom_false_if_neg_in_open_branch b hOpen p h_neg
    exact h_false h_val
  | bot =>
    -- F(⊥) cannot be in an open branch? Actually F(⊥) is fine.
    -- truth_at bot = False, so ¬False is trivial
    simp only [truth_at, not_false_eq_true]
  | imp phi psi =>
    -- F(φ → ψ) cannot be in a saturated branch (would be expanded)
    exfalso
    exact saturation_contradiction b hSat _ h_neg (isExpanded_neg_imp_false phi psi)
  | box phi =>
    -- F(□φ) cannot be in a saturated branch
    exfalso
    exact saturation_contradiction b hSat _ h_neg (isExpanded_neg_box_false phi)
  | all_future phi =>
    -- F(Gφ) cannot be in a saturated branch
    exfalso
    exact saturation_contradiction b hSat _ h_neg (isExpanded_neg_all_future_false phi)
  | all_past phi =>
    -- F(Hφ) cannot be in a saturated branch
    exfalso
    exact saturation_contradiction b hSat _ h_neg (isExpanded_neg_all_past_false phi)
```

### References

- Task 628 research report (upward bridge analysis - same domain)
- Task 630 completion (BranchTaskModel infrastructure)
- Task 623 plan (FMP-tableau connection blocked on this)
- Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
