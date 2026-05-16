# Implementation Plan: Task #154 - Fix Build Errors in NEquivalence.lean (v13)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [IN PROGRESS]
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

**Goal**: Starting from the v11 partial state (h_idx', eM, eN, bound working), change sz to Function.update and fix the 3 failing fields using the hybrid approach.

**CRITICAL INSTRUCTION**: For positive branches, NEVER use `subst h`. Use `exact h ▸ X` or `h ▸` cast notation instead. The v12 agent's failure was caused by using `subst h` then trying to reduce `Function.update ... j'` — this is KNOWN to be impossible.

**Step-by-step:**

**Step 1**: Change sz (line 560):
```lean
-- FROM:
sz := fun j' => if j' = j then cd.sz j + 1 else cd.sz j'
-- TO:
sz := Function.update cd.sz j (cd.sz j + 1)
```

**Step 2**: Update Fin.cast proofs in eM/eN. The current eM (lines 561-564) uses `Fin.cast (if_pos h)`. With Function.update, the ite equality `if_pos h` no longer matches the sz type. Options:
- Change to `Fin.cast (by simp [Function.update, dif_pos h])` or `Fin.cast (show Function.update cd.sz j (cd.sz j + 1) j' = cd.sz j + 1 from by rw [h, Function.update_self])`
- Or: inline `have : Function.update cd.sz j (...) j' = cd.sz j + 1 := by rw [h, Function.update_self]` and use `Fin.cast this`
- Keep the `h ▸ @Fin.cons ...` structure; just fix the Fin.cast argument

**Step 3**: Update eN symmetrically.

**Step 4**: Fix agree (THE KEY FIX):
```lean
agree := fun j' => by
  by_cases h : j' = j
  · -- POSITIVE: cast h_ext_agree along h (NO subst, NO reduction needed)
    exact h ▸ h_ext_agree
  · -- NEGATIVE: prove sz equality via Function.update unfolding, then cast
    have hsz_eq : Function.update cd.sz j (cd.sz j + 1) j' = cd.sz j' := by
      simp [Function.update, dif_neg h]
    exact hsz_eq ▸ (cd.agree j')
```

If `exact h ▸ h_ext_agree` doesn't work (because eM/eN definition with Function.update changes the type shape), try:
```lean
  · -- Fallback: convert with congr
    convert h ▸ h_ext_agree using 2
    all_goals { funext x; simp [Function.update, dif_pos (show j = j from rfl)] }
```

If `hsz_eq ▸ (cd.agree j')` doesn't work (eM/eN lambda mismatch), try:
```lean
  · -- Fallback: convert with sz equality
    have hsz_eq : ... := by simp [Function.update, dif_neg h]
    convert cd.agree j' using 1
    · exact hsz_eq  -- or congr for NormalForm args
    · funext x; simp [dif_neg h, Fin.cast_eq_self]
```

**Step 5**: Fix bound:
```lean
bound := fun j' => by
  by_cases h : j' = j
  · -- Use h ▸ (no subst) to cast hbound
    exact h ▸ (by rw [Function.update_self]; exact hbound)
  · rw [show Function.update cd.sz j (cd.sz j + 1) j' = cd.sz j' from
      by simp [Function.update, dif_neg h]]
    exact cd.bound j'
```

Or simpler if `rw` works: `by_cases h; · rw [h, Function.update_self]; exact hbound; · have := ...; rw [this]; exact cd.bound j'`

**Step 6**: Fix sz_le_n:
```lean
sz_le_n := fun j' => by
  by_cases h : j' = j
  · rw [h, Function.update_self]; exact Nat.succ_le_succ (cd.sz_le_n j)
  · rw [show Function.update cd.sz j (cd.sz j + 1) j' = cd.sz j' from
      by simp [Function.update, dif_neg h]]
    exact Nat.le_succ_of_le (cd.sz_le_n j')
```

Note: sz_le_n and bound are simple Nat goals (not dependent types), so `rw` should work for both branches after proving the equalities.

**Step 7**: Fix consistent:
```lean
consistent := fun p j' hj' => by
  cases p using Fin.cases with
  | zero =>
    simp [Fin.cons_zero] at hj'
    have h_eq : j' = j := hj'.symm
    -- Use h_eq ▸ (NOT subst) to avoid ite-in-types
    refine ⟨⟨0, by rw [h_eq, Function.update_self]; omega⟩, ?_, ?_⟩ <;>
      simp only [dif_pos h_eq, Fin.cast_mk] <;> congr 1 <;> exact hj'.symm
  | succ k =>
    simp [Fin.cons_succ] at hj'
    obtain ⟨q, hqM, hqN⟩ := cd.consistent k j' hj'
    by_cases hjj : j' = j
    · refine ⟨⟨q.val + 1, by rw [hjj, Function.update_self]; exact Nat.succ_lt_succ q.isLt⟩, ?_, ?_⟩ <;>
        simp only [dif_pos hjj, Fin.cons_succ, Fin.cast_mk] <;>
        exact hjj ▸ (by assumption)
    · rw [show Function.update cd.sz j (cd.sz j + 1) j' = cd.sz j' from
        by simp [Function.update, dif_neg hjj]] at *
      exact ⟨q, hqM, hqN⟩
```

**Step 8**: Run `lake build` and check forward oracle errors. If errors remain, use `lean_goal` at exact error positions to diagnose.

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` lines 556-603

**Verification**: `lake build` shows zero errors in forward oracle region

---

### Phase 2: Refactor Backward Oracle [IN PROGRESS]

**Goal**: Apply forward oracle patterns to backward oracle (lines 632-683).

**Tasks**:
- [ ] Fix h_idx' with explicit `@Fin.cons` motive (copy forward oracle line 548-551)
- [ ] Add `match d, hdn` + hbound (copy lines 552-555)
- [ ] Change sz to `Function.update cd.sz j (cd.sz j + 1)`
- [ ] Apply same eM/eN/agree/bound/sz_le_n/consistent patterns from Phase 1
- [ ] Run `lake build`

**Timing**: 1 hour

**Depends on**: 1

---

### Phase 3: Fix cd0 in sum_lift_one_var + Final Verification [NOT STARTED]

**Goal**: Apply Function.update to cd0 (lines 787-828) and achieve clean build.

**Tasks**:
- [ ] Change cd0 sz: `Function.update (fun _ => 0) i 1`
- [ ] Add cd0 sz_le_n: `by_cases h : j' = i; · rw [h, Function.update_self]; omega; · rw [show ... from by simp [Function.update, dif_neg h]]; omega`
- [ ] Fix agree/consistent using same hybrid pattern (h ▸ for positive, simp-unfold for negative)
- [ ] Run `lake build`, confirm exit 0
- [ ] Verify zero sorries, no regressions

**Timing**: 1 hour

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
