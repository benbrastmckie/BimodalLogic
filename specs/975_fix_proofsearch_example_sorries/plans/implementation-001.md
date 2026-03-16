# Implementation Plan: Fix ProofSearch Example Sorries

- **Task**: 975 - fix_proofsearch_example_sorries
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/975_fix_proofsearch_example_sorries/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fix 3 sorry placeholders in `Theories/Bimodal/Automation/ProofSearch.lean` (lines 1348, 1353, 1358). Each sorry is in an `example` block demonstrating proof tree construction patterns. The research report identified exact fixes using existing `DerivationTree` constructors: `axiom` with `modal_t`, `modus_ponens`, and `assumption`.

### Research Integration

Research report `research-001.md` analyzed each example and provided specific constructor calls:
- Example 1: Use `Axiom.modal_t` for `box p -> p` pattern
- Example 2: Use `modus_ponens` with the provided hypotheses (note: h2 h1 order per constructor signature)
- Example 3: Use `assumption` since `p.box` is directly in context `[p.box]`

## Goals & Non-Goals

**Goals**:
- Replace all 3 sorries with valid Lean 4 proof terms
- Maintain the documentation intent of the examples
- Ensure `lake build` passes with no errors

**Non-Goals**:
- Modify the `bounded_search` implementation
- Change the example specifications (only fix the proofs)
- Add new examples

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Intro.mk` syntax incorrect | L | L | Verify with `Exists.intro` if needed |
| Membership proof `by simp` fails | L | L | Try `by decide` or explicit membership |
| Constructor argument order wrong | L | L | Verify with `lean_hover_info` on constructors |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries in `ProofSearch.lean` at lines 1348, 1353, 1358 (example blocks)

### Expected Resolution
- Phase 1 resolves all 3 sorries via direct constructor application

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in the example blocks
- Examples become type-checked documentation

## Implementation Phases

### Phase 1: Fix All Three Example Sorries [COMPLETED]

- **Dependencies:** None
- **Goal:** Replace each sorry with a valid proof term using DerivationTree constructors

**Tasks:**
- [ ] Fix Example 1 (line 1348): Replace `sorry` with axiom-based proof
- [ ] Fix Example 2 (line 1353): Replace `sorry` with modus ponens proof
- [ ] Fix Example 3 (line 1358): Replace `sorry` with assumption proof
- [ ] Verify all fixes compile with `lake build`
- [ ] Verify zero sorries remain in example blocks

**Timing:** 30 minutes

**Files to modify**:
- `Theories/Bimodal/Automation/ProofSearch.lean` - lines 1347-1358

**Exact Fixes**:

**Fix 1 (Line 1347-1348)**:
Replace:
```lean
example : ∃ (proof : DerivationTree [] ((Formula.atom_s "p").box.imp (Formula.atom_s "p"))), True :=
  sorry  -- Would use: let proof := bounded_search [] _ 1
```
With:
```lean
example : ∃ (proof : DerivationTree [] ((Formula.atom_s "p").box.imp (Formula.atom_s "p"))), True :=
  let p := Formula.atom_s "p"
  ⟨DerivationTree.axiom [] (p.box.imp p) (Axiom.modal_t p), trivial⟩
```

**Fix 2 (Line 1351-1353)**:
Replace:
```lean
example (p q : Formula) (h1 : DerivationTree [] p) (h2 : DerivationTree [] (p.imp q)) :
    ∃ (proof : DerivationTree [] q), True :=
  sorry  -- Would use: let proof := bounded_search [] q 2
```
With:
```lean
example (p q : Formula) (h1 : DerivationTree [] p) (h2 : DerivationTree [] (p.imp q)) :
    ∃ (proof : DerivationTree [] q), True :=
  ⟨DerivationTree.modus_ponens [] p q h2 h1, trivial⟩
```

**Fix 3 (Line 1355-1358)**:
Replace:
```lean
example (p : Formula) (h : DerivationTree [p.box] p) :
    ∃ (proof : DerivationTree [p.box] p.box), True :=
  sorry  -- Would use: let proof := bounded_search [p.box] p.box 3
```
With:
```lean
example (p : Formula) (h : DerivationTree [p.box] p) :
    ∃ (proof : DerivationTree [p.box] p.box), True :=
  ⟨DerivationTree.assumption [p.box] p.box (by simp), trivial⟩
```

**Verification**:
- [x] `lake build Bimodal.Automation.ProofSearch` passes
- [x] `grep -n "\bsorry\b" Theories/Bimodal/Automation/ProofSearch.lean` shows no sorries in lines 1340-1360

**Progress:**

**Session: 2026-03-16, sess_1742169600_975impl**
- Fixed: Example 1 (line 1348) - replaced sorry with `DerivationTree.axiom` using `Axiom.modal_t`
- Fixed: Example 2 (line 1353) - replaced sorry with `DerivationTree.modus_ponens`
- Fixed: Example 3 (line 1358) - replaced sorry with `DerivationTree.assumption`
- Sorries: 3 -> 0 (all eliminated in example blocks)

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Automation/ProofSearch.lean` - verify no sorries in example blocks (lines 1340-1360)
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Examples maintain their documentation purpose (comments updated if needed)

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-20260316.md (post-implementation)

## Rollback/Contingency

If any fix fails to compile:
1. Revert to original sorry temporarily
2. Use `lean_hover_info` to verify constructor signatures
3. Adjust arguments based on actual type requirements
4. If all approaches fail, mark [BLOCKED] with requires_user_review
