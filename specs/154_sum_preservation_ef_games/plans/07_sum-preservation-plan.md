# Implementation Plan: Task #154 - Fix Build Errors in NEquivalence.lean (v12)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [IN PROGRESS]
- **Effort**: 3 hours
- **Dependencies**: None (all sorries removed; only type elaboration errors remain)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/07_team-research.md, specs/154_sum_preservation_ef_games/reports/08_teammate-a-findings.md, specs/154_sum_preservation_ef_games/reports/08_teammate-b-findings.md, specs/154_sum_preservation_ef_games/reports/08_teammate-c-findings.md, specs/154_sum_preservation_ef_games/reports/08_teammate-d-findings.md
- **Artifacts**: plans/07_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

NEquivalence.lean has zero sorries but 24 build errors (originally 17, increased to 24 after a partial Phase 1 attempt that added `sz_le_n` field to CompData). The errors are all caused by the same root cause: `if j' = j then X else Y` appearing in TYPE positions with opaque `DecidableEq` (from `LinearOrder I`). After 10+ failed implementation attempts and 8 research rounds, the solution is clear: **replace raw ite with `Function.update`**.

### Key Breakthrough (Research Round 8)

`Function.update f j v` hides the DecidableEq instance inside its opaque body. This means:
- `rw [Function.update_self]` works in TYPE positions (even after `subst h`) — unlike `rw [if_pos rfl]` which creates a motive error
- `rw [Function.update_of_ne h]` works in DEPENDENT type positions — unlike `rw [if_neg h]` which fails when the ite is inside `Fin`/`NormalForm` type arguments

This is the canonical Mathlib idiom (`@[simp]`-tagged lemmas, no new imports needed). Verified in standalone prototype by Teammate A.

### Research Integration

- **08_teammate-a-findings.md**: Function.update + CompData.extend helper prototype verified compiling. Agree positive uses `convert h_ext_agree nf using 2`. Agree negative: `rw [Function.update_of_ne h]; exact cd.agree j'`.
- **08_teammate-b-findings.md**: Function.update is canonical Mathlib idiom. `Function.update_self` proved via `dif_pos rfl` (bypasses opacity). No imports needed.
- **08_teammate-c-findings.md**: Hands-on verification. Agree positive: `exact h ▸ h_ext_agree`. sz_le_n: `rw [if_pos h]` works. Agree negative BLOCKED with raw ite (the critical blocker Function.update solves).
- **08_teammate-d-findings.md**: Restructuring CompData doesn't help. Fix must be in proof construction patterns. 3 construction sites total.

### Prior Plan Reference

Plans v8-v11 all attempted raw ite approaches. v11's partial implementation confirmed: h_idx', eM, eN, bound work with tactic-mode `by_cases` + `Fin.cast (if_pos h)`. But agree negative branch is fundamentally blocked with raw ite. v12 replaces ite with Function.update to eliminate the root cause.

### Roadmap Alignment

This task advances the Reynolds pipeline for discrete completeness:
- `sum_preservation` is a prerequisite for activating the Reynolds pipeline
- Critical path: Task 129 (COMPLETED) -> 139 (FO satisfaction) -> 140 (truth transfer) -> sorry-free `bx_completeness`

## Goals & Non-Goals

**Goals**:
- Resolve all 24 build errors in NEquivalence.lean
- Achieve `lake build` exit code 0
- Maintain zero sorries
- Use `Function.update` to eliminate ite-in-types at its root

**Non-Goals**:
- Extracting `CompData.extend` helper (deferred — can be done as cleanup after builds pass)
- Resolving the 3 KEquivalenceFramework sorries (task 139 scope)
- Optimizing proof performance beyond successful compilation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `rw [Function.update_self]` might not reduce inside Fin type args in actual context | H | L | Verified in prototype by Teammate A; fall back to `simp only [Function.update_self]` |
| agree positive branch: eM/eN via dite ≠ Fin.cons definitionally | M | M | Use `convert ... using 2` + `funext; simp [dif_pos rfl]` (verified) or `exact h ▸ h_ext_agree` (also verified) |
| consistent field: dif_pos/dif_neg might not reduce eM/eN lambdas | M | M | Use `simp only [dif_pos h_eq, Fin.cast_mk]` (verified by Teammate C) |
| Backward oracle not perfectly symmetric with forward | L | L | Both use same CompData.sz pattern; Function.update is structure-agnostic |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases are sequential because each phase's `lake build` output determines success of the approach.

### Phase 1: Refactor Forward Oracle to Function.update [BLOCKED]

**Goal**: Change the forward oracle cd' construction (lines 556-603) to use `Function.update cd.sz j (cd.sz j + 1)` for sz, and fix all proof fields using `Function.update_self`/`Function.update_of_ne`. This resolves the 7 errors in the forward oracle region.

**BLOCKER** (Phase 1):
- **What failed**: `Function.update` does NOT solve the ite-in-types problem. After changing `sz` to `Function.update cd.sz j (cd.sz j + 1)`, the term `Function.update cd.sz j (cd.sz j + 1) j'` appears in dependent type positions (NormalForm type parameters and nf_eval_nf arguments) and CANNOT be reduced by any tactic.
- **What was tried**:
  1. `rw [Function.update_self]` — fails with "motive is not type correct" (same as raw ite)
  2. `simp only [Function.update_self]` — reduces the `dif` in eM/eN lambdas to `True` but does NOT reduce the Function.update in NormalForm type parameters
  3. `rw [Function.update_of_ne h]` / `simp only [Function.update_of_ne h]` — fails (motive not type correct / no progress)
  4. `have heq := Function.update_of_ne h; simp only [heq]` — "simp made no progress" even with the equality in context
  5. `have heq := ...; exact heq ▸ cd.agree j'` — "invalid ▸, failed to compute motive"
  6. `have heq := ...; subst heq` — "invalid equality proof, not of form (x = t)"
  7. `simp [Function.update, dif_neg h]` as a HELPER to prove the equality works, and `hsz_eq ▸ (cd.agree j')` — works for negative branch agree (via the helper equality reducing to rfl after unfolding). But positive branch still fails because after subst, `Function.update cd.sz j' ... j'` remains opaque.
  8. `convert h_ext_agree nf using 2` — creates HEq subgoals that are difficult to close
- **Why it's stuck**: The root cause is NOT the choice between ite and Function.update. The root cause is that `DecidableEq I` (from `LinearOrder I`) is OPAQUE. Any decision-based branching (`if`, `dif`, `Function.update`) that depends on `j' = j` is permanently irreducible in TYPE positions. This is a fundamental Lean 4 kernel limitation — no tactic can force reduction of an opaque DecidableEq instance in a dependent type.
- **What is needed**: A fundamentally different approach that avoids putting any decision-based branching in the `sz` field of CompData. Possible approaches:
  1. **Refactor CompData** to separate the "current index" case from all others (e.g., a field `sz_j : Nat` for the j-component and `sz_other : (j' : I) -> j' != j -> Nat` for others) — eliminates ite in types
  2. **Use a helper lemma** like `nf_agreement_monotone` that bridges between the stated type and the needed type without requiring reduction
  3. **Define sz as a transparent function** using a custom Decidable instance (e.g., `@instDecidableEqOfBEq I ...` that is definitionally transparent)
  4. **Restructure the proof** to avoid CompData entirely — prove BiCompat directly by well-founded recursion on budget
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Tasks**:
- [ ] Change `sz` definition (line 560): `fun j' => if j' = j then cd.sz j + 1 else cd.sz j'` → `Function.update cd.sz j (cd.sz j + 1)`
- [ ] Fix `eM` field: keep tactic-mode `by_cases h : j' = j`, but change `Fin.cast (if_pos h)` to `Fin.cast (by rw [h, Function.update_self])` in positive branch and `Fin.cast (by rw [Function.update_of_ne h])` in negative branch (or keep existing `Fin.cast (if_pos h)` if it still type-checks — may need adjusting since sz type changed)
- [ ] Fix `eN` field: symmetric to eM
- [ ] Fix `agree` positive branch: `exact h ▸ h_ext_agree` (verified by Teammate C, no subst needed) OR `subst h; rw [Function.update_self]; convert h_ext_agree nf using 2; ...` (verified by Teammate A)
- [ ] Fix `agree` negative branch: `rw [Function.update_of_ne h]; exact cd.agree j'` (this is the KEY fix — Function.update makes this work where raw ite was blocked)
- [ ] Fix `bound`: `subst h; rw [Function.update_self]; exact hbound` / `rw [Function.update_of_ne h]; exact cd.bound j'`
- [ ] Fix `sz_le_n`: `subst h; rw [Function.update_self]; exact Nat.succ_le_succ (cd.sz_le_n j)` / `rw [Function.update_of_ne h]; exact Nat.le_succ_of_le (cd.sz_le_n j')`
- [ ] Fix `consistent` zero case: `have h_eq : j' = j := hj'.symm; subst h_eq; rw [Function.update_self]; exact ⟨0, by simp [dif_pos rfl, Fin.cons_zero], by simp [dif_pos rfl, Fin.cons_zero]⟩`
- [ ] Fix `consistent` succ case: `by_cases hjj : j' = j; · subst hjj; rw [Function.update_self]; <witness q.val+1>; · rw [Function.update_of_ne hjj]; exact ⟨q, hqM, hqN⟩`
- [ ] Run `lake build` and verify forward oracle region error-free

**Key Pattern** (applies to ALL fields):
```lean
-- Positive branch (j' = j):
subst h; rw [Function.update_self]
-- Now goal type has clean `cd.sz j + 1` instead of ite expression

-- Negative branch (j' ≠ j):
rw [Function.update_of_ne h]
-- Now goal type has clean `cd.sz j'` — works in dependent types!
```

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 556-603 (forward oracle cd')

**Verification**:
- `lake build` shows zero errors in the forward oracle region
- All existing working patterns (h_idx', match d) preserved

---

### Phase 2: Refactor Backward Oracle to Function.update [NOT STARTED]

**Goal**: Apply identical Function.update pattern to backward oracle cd' (lines 647-683). Also fix h_idx' (lines 643-646) with explicit `@Fin.cons` motive.

**Tasks**:
- [ ] Fix h_idx' (lines 643-646): copy forward oracle pattern — explicit `@Fin.cons n (fun _ => carrier)` motive + `.fst` + `fun p => by induction p using Fin.cases with | zero => rfl | succ k => exact h_idx k`
- [ ] Add `match d, hdn` + `hbound` derivation (same as forward oracle)
- [ ] Change `sz` to `Function.update cd.sz j (cd.sz j + 1)`
- [ ] Rewrite `eM`/`eN`/`agree`/`bound`/`sz_le_n`/`consistent` using exact same patterns as Phase 1
- [ ] Run `lake build` and verify both oracle regions error-free

**Timing**: 1 hour (direct copy of Phase 1 patterns)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 632-683 (backward oracle)

**Verification**:
- `lake build` shows zero errors in both oracle regions
- Recursive `build_bicompat` call type-checks

---

### Phase 3: Refactor cd0 in sum_lift_one_var + Final Verification [NOT STARTED]

**Goal**: Apply Function.update to cd0 construction (lines 787-828) and verify full project builds cleanly.

**Tasks**:
- [ ] Change cd0 `sz` (line 788): `fun j' => if j' = i then 1 else 0` → `Function.update (fun _ => 0) i 1`
- [ ] Fix cd0 `eM`: change `Fin.cast` proofs from `if_pos h`/`if_neg h` to `Function.update_self`/`Function.update_of_ne h` (or `by rw [h, Function.update_self]`)
- [ ] Fix cd0 `eN`: symmetric
- [ ] Fix cd0 `agree` positive: `subst h; rw [Function.update_self]; ...` (uses `show k + 1 - 1 = k`)
- [ ] Fix cd0 `agree` negative: `rw [Function.update_of_ne h]; ...` (now type-checks!)
- [ ] Add cd0 `sz_le_n`: `subst h; rw [Function.update_self]; omega` / `rw [Function.update_of_ne h]; omega` (sz is 0 or 1, n=1)
- [ ] Fix cd0 `consistent`: `subst hj'; rw [Function.update_self]; exact ⟨⟨0, rfl⟩, rfl, rfl⟩`
- [ ] Run `lake build` and confirm exit code 0
- [ ] Verify zero sorries: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
- [ ] Verify no downstream regressions

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 787-828 (sum_lift_one_var cd0)

**Verification**:
- `lake build` exits with code 0
- Zero sorries in NEquivalence.lean
- `doets_lemma_1_4` in OrderedSum.lean is transitively sorry-free
- No downstream regressions

## Testing & Validation

- [ ] `lake build` succeeds with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows zero matches
- [ ] No new errors in files importing NEquivalence.lean or OrderedSum.lean
- [ ] `sum_preservation_proof` transitively sorry-free

## Artifacts & Outputs

- `specs/154_sum_preservation_ef_games/plans/07_sum-preservation-plan.md` (this file, v12)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`

## Rollback/Contingency

- Git revert to `5bf03bb76` restores zero-sorries-17-errors state (before any v11 implementation)
- If `rw [Function.update_self]` has unexpected interactions with the existing `h ▸ @Fin.cons` in eM/eN, try `simp only [Function.update_self]` or `conv in Function.update _ _ _ _ => rw [Function.update_self]`
- If agree positive with `exact h ▸ h_ext_agree` fails (type universe mismatch), use Teammate A's `convert` approach: `subst h; rw [Function.update_self]; convert h_ext_agree nf using 2; all_goals funext x; simp [dif_pos rfl, Fin.cast]`
- If consistent field's `simp [dif_pos rfl]` fails to reduce the eM/eN lambdas, use `show` or explicit witness construction
- If Function.update approach fails entirely (very unlikely given prototype verification), revert to raw ite + the field-by-field `rw [if_pos h]` approach from Teammate C (agree neg still blocked — would need `(if_neg h).symm ▸` + funext workaround)
- PROHIBITED: No `sorry`, no `def X := True`, no vacuous placeholders

## Key Rules (from 8 research rounds + 11 implementation attempts)

1. **NEVER `subst h` before reducing Function.update** — always `subst h; rw [Function.update_self]` (subst first is OK because Function.update_self handles `rfl`)
2. **For negative branches: `rw [Function.update_of_ne h]`** — this works in dependent types where `rw [if_neg h]` fails
3. **eM/eN fields stay tactic-mode**: `by_cases h : j' = j; · exact h ▸ @Fin.cons ...` — confirmed working
4. **Fin.cast proofs**: Change from `Fin.cast (if_pos h)` to `Fin.cast (by rw [h, Function.update_self])` or `Fin.cast (by rw [Function.update_of_ne h])`
5. **No new imports needed**: `Function.update`, `Function.update_self`, `Function.update_of_ne` all available from existing transitive imports
