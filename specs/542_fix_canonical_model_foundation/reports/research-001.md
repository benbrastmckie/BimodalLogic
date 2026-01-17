# Research Report: Task #542

**Task**: 542 - Fix CanonicalModel Foundation (Phase 1 of 540)
**Date**: 2026-01-17
**Session ID**: sess_1768661519_937d9a
**Language**: lean
**Effort**: 2 hours
**Priority**: High
**Dependencies**: None
**Parent**: 540
**Sources/Inputs**: Completeness.lean, CanonicalModel.lean, Bimodal/Syntax/Formula.lean
**Artifacts**: This research report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The broken `Representation/CanonicalModel.lean` has 21 compilation errors from outdated Mathlib APIs and incorrect Formula constructors
- Working patterns exist in `Completeness.lean`: `SetConsistent`, `SetMaximalConsistent`, `set_lindenbaum`, and `CanonicalWorldState`
- The fix requires: (1) copying working definitions from Completeness.lean, (2) replacing `past`/`future` with `all_past`/`all_future`, (3) fixing Zorn's lemma usage with `zorn_subset_nonempty`

## Context & Scope

Task 542 is Phase 1 of the larger Task 540 (Finish Metalogic Refactor). The goal is to fix `Representation/CanonicalModel.lean` to compile using the proven patterns from `Completeness.lean`. This file provides the foundation for the representation theorem chain.

### Current State of CanonicalModel.lean

The file has **21 compilation errors** across these categories:

| Error Type | Count | Root Cause |
|------------|-------|------------|
| Invalid `.toList` on Set | 4 | `Set Formula` doesn't have `.toList` method |
| Invalid `.subformula_closure` | 1 | Formula doesn't have this field |
| Invalid `.chain` on Set | 1 | Wrong Zorn API (`C.chain` should be `IsChain`) |
| Unknown identifiers | 3 | `exists_mem_of_mem_union`, `subset_union`, `zorn_nonempty_partial_order` |
| Type mismatches | 3 | `φ` (Formula) vs `Prop` for negation |
| Wrong Formula constructors | 4 | `past`/`future` should be `all_past`/`all_future` |
| Unsolved goals | 1 | Lindenbaum lemma incomplete |
| Missing alternatives | 4 | Match on `all_past`/`all_future` missing |

## Findings

### 1. Working Definitions in Completeness.lean

The following definitions from `Completeness.lean` should be directly reused:

#### SetConsistent (line 129)
```lean
def SetConsistent (S : Set Formula) : Prop :=
  ∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → Consistent L
```

This avoids the invalid `.toList` approach. Instead of `S.toList`, it checks consistency of any list whose elements are all in S.

#### SetMaximalConsistent (line 136)
```lean
def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S ∧ ∀ φ : Formula, φ ∉ S → ¬SetConsistent (insert φ S)
```

#### ConsistentExtensions (line 142)
```lean
def ConsistentExtensions (base : Set Formula) : Set (Set Formula) :=
  {S | base ⊆ S ∧ SetConsistent S}
```

#### CanonicalWorldState (line 1413)
```lean
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}
```

### 2. Working Lindenbaum's Lemma (set_lindenbaum)

The working `set_lindenbaum` theorem at line 360-409 uses:
- `zorn_subset_nonempty` from Mathlib (not `zorn_nonempty_partial_order`)
- `IsChain (· ⊆ ·) C` pattern (not `C.chain`)
- `Set.subset_sUnion_of_mem` (not `subset_union`)
- `consistent_chain_union` for chain consistency

Key pattern (lines 385-386):
```lean
have hSmem : S ∈ CS := self_mem_consistent_supersets hS
obtain ⟨M, hSM, hmax⟩ := zorn_subset_nonempty CS hchain S hSmem
```

### 3. Formula Constructor Names

The Bimodal Formula inductive (lines 85-98 of Formula.lean) uses:
- `all_past` (not `past`) for universal past operator H
- `all_future` (not `future`) for universal future operator G

The match statements must use these exact names:
```lean
| .all_past φ ih => ...
| .all_future φ ih => ...
```

### 4. Negation Type Issue

In the current broken code:
```lean
theorem contains_or_neg {M : MaximalConsistentSet} {φ : Formula} :
    φ ∈ M.carrier ∨ (¬φ) ∈ M.carrier := by
```

The `¬φ` uses Prop negation, but we need `Formula.neg φ`. The working pattern in Completeness.lean (line 681):
```lean
theorem set_mcs_negation_complete {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) (φ : Formula) :
    φ ∈ S ∨ (Formula.neg φ) ∈ S := by
```

### 5. Box Operator Notation

The Unicode `□` doesn't work directly in pattern matches. Use `Formula.box`:
```lean
-- Wrong:
| □φ ∈ M.carrier → ...

-- Correct:
| (Formula.box φ) ∈ M.carrier → ...
-- Or use notation after opening the namespace
```

### 6. MCS Properties Available in Completeness.lean

These theorems exist and can be referenced:

| Theorem | Line | Purpose |
|---------|------|---------|
| `set_mcs_closed_under_derivation` | 578 | MCS is closed under derivation |
| `set_mcs_modus_ponens` | 656 | MP: if (φ → ψ) ∈ S and φ ∈ S then ψ ∈ S |
| `set_mcs_negation_complete` | 679 | Either φ ∈ S or ¬φ ∈ S |
| `set_mcs_pos_neg_intro` | 741 | Positive/negative case analysis |
| `set_mcs_imp_intro` | 824 | If ψ ∈ S then (φ → ψ) ∈ S |
| `set_mcs_box_reflexive` | 994 | If □φ ∈ S then φ ∈ S |
| `set_mcs_box_transitive` | 1025 | If □φ ∈ S then □□φ ∈ S |
| `set_mcs_G_transitive` | 1056 | If Gφ ∈ S then GGφ ∈ S |
| `set_mcs_H_transitive` | 1116 | If Hφ ∈ S then HHφ ∈ S |

### 7. Subformula Closure

The `.subformula_closure` field doesn't exist on Formula. The working approach in `Completeness.lean` doesn't use subformula closure in the MCS definition. The maximal consistency definition itself ensures deductive closure.

If subformula closure is needed later, it should be defined as a separate function, not a field.

## Decisions

1. **Reuse definitions from Completeness.lean** rather than writing new versions
   - Import or copy `SetConsistent`, `SetMaximalConsistent`, `set_lindenbaum`
   - Rationale: These are proven to work

2. **Remove subformula_closure requirement** from MaximalConsistentSet
   - Rationale: Not needed for core MCS properties; can be added separately if required

3. **Use CanonicalWorldState pattern** for world representation
   - `{S : Set Formula // SetMaximalConsistent S}` subtype
   - Rationale: Clean interface, proven pattern

4. **Keep TruthLemma in separate file** as originally intended
   - Rationale: Modularity; CanonicalModel.lean provides foundation

## Recommendations

### Phase 1 Implementation Steps

1. **Replace broken structure with imports**
   - Import existing definitions from `Completeness.lean` OR
   - Copy the working definitions into `CanonicalModel.lean`

2. **Fix MaximalConsistentSet structure**
   ```lean
   -- Remove invalid subformula_closure field
   -- Change from Set-with-toList to SetMaximalConsistent pattern
   structure MaximalConsistentSet where
     carrier : Set Formula
     is_maximal : SetMaximalConsistent carrier
   ```
   Or simply use `CanonicalWorldState` directly.

3. **Fix CanonicalFrame accessibility definitions**
   - Change `Past`/`Future` to `all_past`/`all_future`
   - Use proper Formula.box syntax

4. **Fix canonicalTruthAt function**
   - Update match to use `all_past`/`all_future` constructors
   - Ensure all Formula constructors are covered

5. **Fix or remove Lindenbaum's lemma**
   - Either import from Completeness.lean
   - Or copy the working `set_lindenbaum` implementation

### Implementation Priority

| Step | Effort | Blocks |
|------|--------|--------|
| Fix imports and namespace opens | 15 min | Everything |
| Replace MCS definition | 30 min | Frame, Model, lemmas |
| Fix Frame definition | 20 min | Model, truthAt |
| Fix canonicalTruthAt | 30 min | TruthLemma |
| Fix/remove Lindenbaum | 30 min | None (can reuse) |

### Verification Commands

After implementation:
```bash
lake build Bimodal.Metalogic.Representation.CanonicalModel
```

Use lean_diagnostic_messages to verify zero errors.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Import cycles between Completeness.lean and CanonicalModel.lean | Copy definitions instead of importing; refactor to shared module later |
| Frame properties harder to prove | Use existing proven theorems from Completeness.lean |
| TruthLemma may need different approach | Task 543 handles TruthLemma specifically |

## Appendix

### A. Full Error List from lean_diagnostic_messages

1. `carrier.toList` - line 24: Set has no toList
2. `Δ.toList` - line 25: Set has no toList
3. `φ.subformula_closure` - line 26: No such field
4. `Γ.toList` - line 66: Set has no toList
5. `Δ.toList` - line 68: Set has no toList
6. Type mismatch `¬φ` - line 108: Formula vs Prop
7. `C.chain` - line 73: No chain field on Set
8. `exists_mem_of_mem_union` - line 78: Unknown identifier
9. `subset_union₀` - line 81: Unknown identifier
10. `zorn_nonempty_partial_order` - line 84: Unknown identifier
11. Unsolved goals - line 67: Lindenbaum incomplete
12. `□φ` notation - line 126: Parse error
13. `□φ` notation - line 142: Parse error
14. `Formula.past` - line 179: Unknown constructor
15. `past` alternative - line 216: Should be all_past
16. `future` alternative - line 223: Should be all_future
17. Valuation type mismatch - line 196: String vs Formula
18. Missing `all_past` alternative - line 193
19. Missing `all_future` alternative - line 193

### B. Search Queries Used

- Local search: `zorn_subset_nonempty` - found in Mathlib.Order.Zorn
- Grep: `SetMaximalConsistent|SetConsistent|set_lindenbaum` in Completeness.lean
- Grep: `all_past|all_future` in Bimodal/Syntax

### C. References

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean` - Working patterns
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean` - Formula definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/Basic.lean` - Core definitions
- `/home/benjamin/Projects/ProofChecker/specs/540_finish_metalogic_refactor_cleanup/reports/research-001.md` - Parent task research

## Next Steps

Run `/plan 542` to create an implementation plan with detailed code changes.
