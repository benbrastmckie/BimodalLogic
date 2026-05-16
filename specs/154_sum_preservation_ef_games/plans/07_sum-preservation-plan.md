# Implementation Plan: Task #154 - Fix Build Errors in NEquivalence.lean (v13)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Dependencies**: None (all sorries removed; only type elaboration errors remain)
- **Research Inputs**: reports/07_team-research.md, reports/08_teammate-{a,b,c,d}-findings.md, handoffs/phase-1-handoff-v12-20260516.md
- **Artifacts**: plans/07_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

NEquivalence.lean has zero sorries but 24 build errors. The root cause: opaque `DecidableEq I` (from `LinearOrder I`) makes `if j' = j then X else Y` irreducible in TYPE positions. No tactic (`rw`, `simp`, `subst`, `change`) can reduce it.

### The Hybrid Strategy (v13)

After 11 failed implementations, 2 approaches were INDEPENDENTLY VERIFIED to work for different branches of `agree`:

| Branch | Approach | Verified By | Mechanism |
|--------|----------|-------------|-----------|
| Positive (`h : j' = j`) | `exact h ▸ h_ext_agree` | Teammate C (lean_multi_attempt, zero diagnostics) | Cast along `h` — does NOT reduce sz at all. Lean's `Eq.mpr` transports the entire term. |
| Negative (`h : ¬j' = j`) | `have hsz_eq := by simp [Function.update, dif_neg h]; exact hsz_eq ▸ (cd.agree j')` | v12 agent (confirmed working) | Unfold Function.update + reduce dif to get sz equality, then cast. |

**Why prior agents failed**: They used the SAME technique for both branches. The v11 agent used `subst h` for positive (creates irreducible `if j = j`). The v12 agent used `subst h; rw [Function.update_self]` for positive (Function.update_self also can't reduce in type positions after subst). Neither agent tried `h ▸ h_ext_agree` (which avoids reduction entirely by casting the whole term).

**The key insight**: Positive and negative branches need DIFFERENT strategies because they exploit different properties:
- Positive: we have the goal's answer (`h_ext_agree`) and just need to cast it to match the type
- Negative: we don't have a pre-built answer; we need the type to REDUCE so `cd.agree j'` type-checks

### Current File State

File is at commit `84b74d17f` (v11 partial). Already has:
- `sz_le_n` field added to CompData (line 310) — KEEP
- h_idx' fixed (line 551) — KEEP
- `match d, hdn` pattern (lines 552-555) — KEEP
- eM/eN working (lines 561-570) — KEEP (Fin.cast proofs need updating for Function.update)
- bound working (lines 576-579) — KEEP (needs updating for Function.update)
- agree/sz_le_n/consistent FAILING — REWRITE

### Roadmap Alignment

sum_preservation → Reynolds pipeline → discrete completeness (tasks 139, 140)

## Goals & Non-Goals

**Goals**: Resolve all 24 build errors, `lake build` exit 0, zero sorries

**Non-Goals**: CompData.extend helper (cleanup later), KEquivalenceFramework sorries (task 139)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `h ▸ h_ext_agree` fails with Function.update sz (only verified with raw ite sz) | H | M | Also try `convert h_ext_agree using 1; congr 1; exact h` or define sz with raw ite and use `(if_neg h) ▸` for neg |
| `hsz_eq ▸ cd.agree j'` leaves eM/eN lambda mismatch after cast | H | M | After hsz_eq ▸, Fin.cast proof may become rfl making new_eM = cd.eM. If not, use `convert cd.agree j'` with `congr`/`funext` to bridge |
| Fin.cast proof adjustment: `if_pos h` → Function.update proof | M | L | Keep `if_pos h` for Fin.cast in eM/eN (raw ite still in scope for Fin type); only change sz to Function.update |
| Backward oracle / cd0 need same treatment | L | L | Copy pattern once forward oracle verified |

## Implementation Phases

### Phase 1: Fix Forward Oracle agree/sz_le_n/consistent [COMPLETED]

**Goal**: Fix the 3 failing fields (agree, sz_le_n, consistent) in the forward oracle cd' block.

**Actual technique used** (different from plan — discovered by v13 agent):
- [x] sz KEPT as raw ite (NOT changed to Function.update — unnecessary)
- [x] eM/eN KEPT unchanged from v11 (tactic-mode `by_cases h` + `h ▸ @Fin.cons` + `Fin.cast (if_pos h)`)
- [x] agree field FIXED via `convert ... using 2` with HEq case closers:
  - Positive: `subst h; simp (config := { decide := true }) only [dite_true]; have hsz := if_pos rfl; have hty := ...; convert h_ext_agree (cast hty nf) using 2` then close 6 HEq cases
  - Negative: `have hsz := if_neg h; have hty := ...; simp only [dif_neg h]; convert cd.agree j' (cast hty nf) using 2` then close 6 HEq cases
- [x] bound FIXED: `rw [if_pos h]; exact hbound` / `rw [if_neg h]; exact cd.bound j'`
- [x] sz_le_n FIXED: `rw [if_pos h]; exact Nat.succ_le_succ (cd.sz_le_n j)` / `rw [if_neg h]; exact Nat.le_succ_of_le (cd.sz_le_n j')`
- [x] consistent FIXED: `subst hj'; simp [dif_pos rfl, Fin.cons_zero/succ]; rfl` (zero case) / `simp [dif_pos rfl, Fin.cons_succ]; exact hqM/hqN` (succ positive) / `simp [dif_neg hjj]; exact hqM/hqN` (succ negative)
- [x] `lake build` confirms zero errors in forward oracle region

**Key discovery**: The solution avoids BOTH Function.update AND `h ▸ h_ext_agree`. Instead it uses `convert` to decompose into HEq subgoals, then closes with:
- `congrArg (budget - ·) hsz` — sz in subtraction position
- `Function.hfunext (congrArg Fin hsz) (fun a1 a2 ha => ...)` — eM/eN lambda HEq
- `(cast_heq hty nf).symm` — nf argument HEq

**Commit**: `9a1bf3723`

**Depends on**: none

---

### Phase 2: Fix Backward Oracle [COMPLETED]

**Goal**: Apply identical technique to backward oracle cd' block (lines 663-738).

**Tasks**:
- [x] Fix h_idx' (lines 663-666): explicit `@Fin.cons n (fun _ => carrier)` motive + `.fst` + `fun p => by induction p using Fin.cases with | zero => rfl | succ k => exact h_idx k`
- [x] Add `match d, hdn` + hbound derivation (lines 667-670)
- [x] sz kept as raw ite (same as forward oracle)
- [x] eM/eN: same tactic-mode `by_cases h` + `h ▸ @Fin.cons` + `Fin.cast` pattern
- [x] agree: identical `convert ... using 2` + HEq case closers (lines 686-709)
- [x] bound/sz_le_n: `rw [if_pos h]`/`rw [if_neg h]` pattern (lines 710-717)
- [x] consistent: `subst`/`simp [dif_pos rfl]`/`rfl` pattern (lines 718-736)
- [x] `lake build` confirms zero errors in both oracle regions

**Commit**: `5727eadbf`

**Depends on**: 1

---

### Phase 3: Fix cd0 in sum_lift_one_var + Final Verification [COMPLETED]

**Goal**: Close 6 remaining sorries in cd0 section (lines 841-891). Lake build already passes with zero errors.

**Structural issue**: `cd0.bound i` requires `1 < k + 1` (i.e., `k ≥ 1`), but `k` can be 0. 

**Fix**: Case-split on `k` at proof start with `obtain _ | k := k`:
- k=0 case: `build_bicompat 0 1 ...` returns `trivial` (BiCompat at depth 0 is True). Close directly without constructing cd0.
- k+1 case (Nat.succ k): budget = k+2, so `bound i : 1 < k+2` closes by `omega`

**Tasks**:
- [x] Add `cases k` before cd0 construction in `sum_lift_one_var` *(deviation: altered -- used `cases k with | zero => ... | succ k =>` instead of `obtain _ | k := k`)*
  - Zero case: prove goal directly via `sum_nf_lift_gen sig 0 1 ... trivial sub_nf` (BiCompat 0 = True)
  - Succ case: adjust remaining proof for `k+1` instead of `k`
- [x] Fix agree eM/eN HEq: replaced `![a]` with constant function `fun _ => h ▸ a`, then `Function.hfunext ... (by fin_cases a2; rfl)` closes the goal
- [x] Fix bound: after k case-split, `omega` closes `1 < k+2`
- [x] Fix consistent: `simp [envM]` / `simp [envN]` closes both conjuncts
- [x] Run `lake build`, confirm exit 0 (Build completed successfully, 1649 jobs)
- [x] `grep -n sorry` confirms zero sorries in NEquivalence.lean

**Timing**: 1.5 hours

**Depends on**: 2

## Testing & Validation

- [ ] `lake build` succeeds with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows zero matches
- [ ] No new errors in downstream files

## Artifacts & Outputs

- `specs/154_sum_preservation_ef_games/plans/07_sum-preservation-plan.md` (this file, v13)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`

## Rollback/Contingency

- Git revert to `84b74d17f` keeps v11 partial (working h_idx'/eM/eN/bound)
- Git revert to `5bf03bb76` restores pre-implementation state
- If hybrid approach conclusively fails (both `h ▸` AND `hsz_eq ▸` blocked for some field), escalate to team research on alternatives: nf_eval_nf_cast lemma, CompData restructure, or direct BiCompat proof
- PROHIBITED: No `sorry`, no vacuous placeholders

## Lessons from 12 Prior Attempts

1. **NEVER `subst h` when opaque branching in types** — `h ▸` casts without eliminating h
2. **Positive and negative branches need DIFFERENT strategies** — positive casts the answer, negative reduces the type
3. **`simp [Function.update, dif_neg h]` can UNFOLD Function.update** — this proves sz equalities that `rw [Function.update_of_ne h]` cannot
4. **`rw [h, Function.update_self]` works for simple (non-dependent) goals** — bound, sz_le_n, Fin witness bounds
5. **`h ▸ h_ext_agree` was verified by lean_multi_attempt** — the v12 agent never tried this; it insisted on subst
