# Research Report: Clean Linter Warnings in Closure.lean

- **Task**: 894 - clean_linter_warnings_closure_lean
- **Started**: 2026-02-17T12:00:00Z
- **Completed**: 2026-02-17T12:15:00Z
- **Effort**: 15 minutes
- **Dependencies**: None
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/Decidability/Closure.lean`
  - `lake build` output
  - Lean 4 MCP tools (lean_goal)
- **Artifacts**: This report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Project Context

- **Upstream Dependencies**: `checkBotPos`, `checkContradiction`, `checkAxiomNeg`, `Tableau` definitions
- **Downstream Dependents**: Decidability procedure for bimodal logic
- **Alternative Paths**: None
- **Potential Extensions**: None (linter cleanup only)

## Executive Summary

- The task description mentioned lines 316, 322, and 327, but actual warnings are at lines 99, 304, and 316
- Line 99: unused variable `h` in `checkAxiomNeg` definition
- Line 304: unused simp argument `hbot'` in `closed_extend_closed` theorem
- Line 316: two unused simp arguments `hbot'` and `hcontra'` in `closed_extend_closed` theorem
- All warnings are straightforward to fix by removing unused arguments
- The fixes are semantic-preserving: the simp arguments are provably redundant

## Context & Scope

This task addresses linter warnings about unused simp arguments in `Closure.lean`. The warnings are:

```
warning: Theories/Bimodal/Metalogic/Decidability/Closure.lean:99:13: unused variable `h`
warning: Theories/Bimodal/Metalogic/Decidability/Closure.lean:304:28: This simp argument is unused: hbot'
warning: Theories/Bimodal/Metalogic/Decidability/Closure.lean:316:30: This simp argument is unused: hbot'
warning: Theories/Bimodal/Metalogic/Decidability/Closure.lean:316:37: This simp argument is unused: hcontra'
```

## Findings

### Warning 1: Line 99 - Unused Variable `h`

**Location**: `checkAxiomNeg` definition (lines 94-105)

```lean
def checkAxiomNeg (b : Branch) : Option ClosureReason :=
  b.findSome? fun sf =>
    if sf.isNeg then
      match matchAxiom sf.formula with
      | some ⟨φ, witness⟩ =>
          if h : sf.formula = φ then  -- `h` is unused
            some (.axiomNeg φ witness)
          else
            none
      | none => none
    else
      none
```

**Analysis**: The decidable if-then-else `if h : sf.formula = φ then` binds a proof of equality to `h`, but this proof is never used in the `then` branch. The code constructs `some (.axiomNeg φ witness)` without referencing `h`.

**Fix**: Replace `if h : sf.formula = φ then` with `if sf.formula = φ then` (remove the pattern binding).

### Warning 2: Line 304 - Unused Simp Argument `hbot'`

**Location**: `closed_extend_closed` theorem, contradiction case

```lean
cases hbot' : checkBotPos (sf :: b) with
| some _ => rfl
| none =>
  simp only [Option.isSome_iff_exists] at hsome
  obtain ⟨r', hr''⟩ := hsome
  rw [Option.isSome_iff_exists]
  exact ⟨r', by simp [hbot', hr'']⟩  -- hbot' is unused
```

**Analysis**: The goal at line 304 is:
```
⊢ ∃ a, (none <|> checkContradiction (sf :: b) <|> checkAxiomNeg (sf :: b)) = some a
```

The goal already contains `none <|> ...` (not `checkBotPos (sf :: b) <|> ...`). The `simp` tactic uses `hr''` which says `checkContradiction (sf :: b) = some r'`, and `none <|> some r' <|> _ = some r'` simplifies to `some r'` without needing `hbot'`.

**Fix**: Change `simp [hbot', hr'']` to `simp [hr'']`.

### Warning 3: Line 316 - Unused Simp Arguments `hbot'` and `hcontra'`

**Location**: `closed_extend_closed` theorem, axiom negation case

```lean
cases hbot' : checkBotPos (sf :: b) with
| some _ => rfl
| none =>
  cases hcontra' : checkContradiction (sf :: b) with
  | some _ => rfl
  | none =>
    simp only [Option.isSome_iff_exists] at hsome
    obtain ⟨r', hr''⟩ := hsome
    rw [Option.isSome_iff_exists]
    exact ⟨r', by simp [hbot', hcontra', hr'']⟩  -- hbot' and hcontra' are unused
```

**Analysis**: The goal at line 316 is:
```
⊢ ∃ a, (none <|> none <|> checkAxiomNeg (sf :: b)) = some a
```

The goal already contains `none <|> none <|> ...`. The `simp` tactic uses `hr''` which says `checkAxiomNeg (sf :: b) = some r'`, and `none <|> none <|> some r' = some r'` simplifies without needing `hbot'` or `hcontra'`.

**Fix**: Change `simp [hbot', hcontra', hr'']` to `simp [hr'']`.

## Decisions

1. Fix all three warnings by removing unused arguments
2. Prioritize semantic-preserving changes (no logic modification)

## Recommendations

### Implementation Steps

1. **Line 99**: Change `if h : sf.formula = φ then` to `if sf.formula = φ then`

2. **Line 304**: Change:
   ```lean
   exact ⟨r', by simp [hbot', hr'']⟩
   ```
   to:
   ```lean
   exact ⟨r', by simp [hr'']⟩
   ```

3. **Line 316**: Change:
   ```lean
   exact ⟨r', by simp [hbot', hcontra', hr'']⟩
   ```
   to:
   ```lean
   exact ⟨r', by simp [hr'']⟩
   ```

4. **Verify**: Run `lake build Bimodal` and confirm no warnings appear for Closure.lean

### Effort Estimate

- Implementation: 5 minutes
- Verification: 2 minutes
- Total: Under 10 minutes

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Simp fails without removed args | Very Low | Low | Goal analysis confirms args are provably unused |
| Line numbers shift | None | None | Direct edits to specific lines |

## Appendix

### Full Warning Output from `lake build`

```
warning: Theories/Bimodal/Metalogic/Decidability/Closure.lean:99:13: unused variable `h`

Note: This linter can be disabled with `set_option linter.unusedVariables false`
warning: Theories/Bimodal/Metalogic/Decidability/Closure.lean:304:28: This simp argument is unused:
  hbot'

Hint: Omit it from the simp argument list.
  simp [hb̵o̵t̵'̵,̵ ̵h̵r'']

warning: Theories/Bimodal/Metalogic/Decidability/Closure.lean:316:30: This simp argument is unused:
  hbot'

Hint: Omit it from the simp argument list.
  simp [hb̵o̵t̵'̵,̵ ̵h̵contra', hr'']

warning: Theories/Bimodal/Metalogic/Decidability/Closure.lean:316:37: This simp argument is unused:
  hcontra'

Hint: Omit it from the simp argument list.
  simp [hbot', h̵c̵o̵n̵t̵r̵a̵'̵,̵ ̵hr'']
```

### Goal States

**Line 304 goal**:
```
case inr.inl.none
b : Branch
sf : SignedFormula
r : ClosureReason
left✝ : checkBotPos b = none
hcontra : checkContradiction b = some r
hbot' : checkBotPos (sf :: b) = none
r' : ClosureReason
hr'' : checkContradiction (sf :: b) = some r'
⊢ ∃ a, (none <|> checkContradiction (sf :: b) <|> checkAxiomNeg (sf :: b)) = some a
```

**Line 316 goal**:
```
case inr.inr.none.none
b : Branch
sf : SignedFormula
r : ClosureReason
left✝¹ : checkBotPos b = none
left✝ : checkContradiction b = none
hax : checkAxiomNeg b = some r
hbot' : checkBotPos (sf :: b) = none
hcontra' : checkContradiction (sf :: b) = none
r' : ClosureReason
hr'' : checkAxiomNeg (sf :: b) = some r'
⊢ ∃ a, (none <|> none <|> checkAxiomNeg (sf :: b)) = some a
```
