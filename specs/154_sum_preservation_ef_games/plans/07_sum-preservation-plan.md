# Implementation Plan: Task #154 - Fix Build Errors in NEquivalence.lean (v11)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None (all sorries removed; only type elaboration errors remain)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/07_team-research.md
- **Artifacts**: plans/07_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

NEquivalence.lean has zero sorries but 17 build errors concentrated in three code regions: (1) h_idx' at lines 550 and 631, (2) the forward/backward oracle cd' constructions at lines 551-587 and 632-668, and (3) the sum_lift_one_var cd0 construction at lines 772-813. After 17+ failed approaches across plans v8-v10 (all blocked by opaque `DecidableEq` instances and `subst` creating irreducible `ite` in type positions), team research round 7 identified three independently verified working patterns. The core breakthrough: term-mode `dite` with `Fin.cast (if_pos h)` / `Fin.cast (if_neg h)` bridges ite type gaps without `subst`, and `simp only [if_pos h]` before `intro nf` reduces ite in goal types for the agree field. This plan applies these verified patterns directly to the existing code as complete block rewrites.

### Research Integration

- **07_team-research.md**: 4-teammate prototyping round. Three verified working patterns converged on the same insight: avoid `subst`, use term-mode `dite` + `Fin.cast`. Teammate B verified the complete dite + Fin.cast + @Fin.cons pattern for eM/eN/bound/consistent. Teammate A verified `simp only [if_pos h]` before `intro nf` for agree, and the h_idx' tactic-mode fix at line 550. Both confirmed `hbound : cd.sz j + 1 < budget` must be passed as explicit parameter.

### Prior Plan Reference

Plans v8, v9, v10 all blocked by the same two fundamental issues: (1) `subst h` with `h : j' = j` creates `ite (j = j)` in TYPE positions which is not definitionally reducible because `DecidableEq` is opaque -- no tactic (`simp`, `rw`, `dsimp`, `change`, `conv`) can reduce it in dependent types; (2) `cd.sz j + 1 < budget` is not derivable from `cd.sz j < budget` alone, requiring an explicit bound parameter. The v10 plan explored `match decEq` and `Function.update` but was never implemented because verified working code arrived from research round 7. Key calibration from prior plans: effort estimates were too optimistic (5 hours for unverified approaches); with verified patterns, 3 hours is realistic. The d=0 edge case for bound was extensively analyzed in v10 and the resolution is clear: pass `hbound` as explicit parameter derived from `hdn` at the call site.

### Roadmap Alignment

This task advances the Reynolds pipeline for discrete completeness:
- 3 sorries in `NEquivalence.lean` (`ktype_finite`, `k_type_of`, `finite_types`) block KEquivalenceFramework (task 139)
- `sum_preservation` is a prerequisite for activating the Reynolds pipeline
- Critical path: Task 129 (COMPLETED) -> 139 (FO satisfaction) -> 140 (truth transfer) -> sorry-free `bx_completeness`

## Goals & Non-Goals

**Goals**:
- Resolve all 17 build errors in NEquivalence.lean
- Achieve `lake build` exit code 0
- Maintain zero sorries
- Apply verified patterns from research round 7 (no speculative approaches)

**Non-Goals**:
- Modifying CompData structure (no new fields)
- Creating helper functions (patterns work inline)
- Resolving the 3 KEquivalenceFramework sorries (task 139 scope)
- Optimizing proof performance beyond successful compilation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Integration gap: verified patterns worked in standalone `lean_run_code` but may interact differently with `build_bicompat`'s 1133-line context | H | M | Complete block rewrites (not incremental patches); `lake build` after each phase; patterns were tested against actual file structure |
| `agree` field proof: real agree involves `nf_eval_nf` with complex arguments, not simplified test version | H | M | Use Teammate A's `simp only [if_pos h]` before `intro nf` pattern combined with `nf_agreement_monotone` bridge; fall back to Teammate B's pure term-mode `Fin.cast` approach if tactic version fails |
| `hbound` derivation at call site: need `cd.sz j + 1 < budget` from `hdn : d + 1 + n <= budget` | M | L | Verified derivable: in the `d+1` case, `d >= 0` so `d+1+n >= 1+n`, and `cd.bound j` gives `cd.sz j < budget`; combined with `omega` this closes. If tight edge case arises, the recursive call at `d=0` returns `trivial` without inspecting cd' |
| Backward oracle (lines 632-668) has untested interactions despite structural symmetry with forward oracle | M | L | Apply identical pattern; if it diverges, inspect with `lean_goal` at the exact error site |
| `sum_lift_one_var` cd0 (lines 772-813) uses different structure (initial CompData, not extension) | M | L | Same dite + Fin.cast pattern applies; cd0 is simpler (sz is 0 or 1, not incremented) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases are fully sequential because each phase's `lake build` output determines the exact error set for the next phase.

### Phase 1: Fix h_idx' and Rewrite Forward Oracle cd' [PARTIAL]

**Goal**: Fix the h_idx' proof at line 550, then rewrite the forward oracle cd' block (lines 551-587) using verified dite + Fin.cast + @Fin.cons pattern. This resolves approximately 10 of the 17 build errors.

**Tasks**:
- [ ] Fix h_idx' at line 550: replace `Fin.cases rfl (fun k => h_idx k)` with `fun p => by induction p using Fin.cases with | zero => rfl | succ k => rfl` (verified by Teammate A with zero diagnostics)
- [ ] Rewrite cd' `eM` field (line 556) using Teammate B's pattern: `fun j' x => if h : j' = j then @Fin.cons (cd.sz j) (fun _ => (ms j).carrier) c (cd.eM j) (Fin.cast (if_pos h) x) else cd.eM j' (Fin.cast (if_neg h) x)`
- [ ] Rewrite cd' `eN` field (line 557) with symmetric pattern for `ms'`, `c'`, `cd.eN`
- [ ] Rewrite cd' `agree` field (lines 558-565) using Teammate A's pattern: `fun j' => by by_cases h : j' = j; . simp only [if_pos h]; intro nf; <close with h_ext_agree + nf_agreement_monotone bridge>; . simp only [if_neg h]; exact cd.agree j'`
- [ ] Rewrite cd' `bound` field (lines 566-569): `fun j' => if h : j' = j then by rw [if_pos h]; exact <hbound derived from hdn via omega> else by rw [if_neg h]; exact cd.bound j'`
- [ ] Rewrite cd' `consistent` field (lines 570-586): use `Fin.cast (if_pos h).symm` for witness casts instead of `subst` + `dif_pos rfl`; for zero case provide `Fin.cast (if_pos rfl).symm (0 : Fin (cd.sz j + 1))`; for succ case use `Fin.cast (if_pos hjj).symm (Fin.succ q)` or `Fin.cast (if_neg hjj) q`
- [ ] Run `lake build` and record remaining error count

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 550-587 (h_idx' + forward oracle cd')

**Verification**:
- `lake build` shows zero errors in the forward oracle region (lines 546-588)
- h_idx' compiles without diagnostics
- No new errors introduced by the rewrite

---

### Phase 2: Rewrite Backward Oracle cd' [NOT STARTED]

**Goal**: Apply the identical dite + Fin.cast pattern to the backward oracle cd' block (lines 632-668). This is structurally symmetric with the forward oracle.

**Tasks**:
- [ ] Fix h_idx' at line 631: same tactic-mode proof as Phase 1
- [ ] Rewrite cd' `eM` field (line 637) with dite + Fin.cast + @Fin.cons pattern (identical to Phase 1 forward oracle)
- [ ] Rewrite cd' `eN` field (line 638) with symmetric pattern
- [ ] Rewrite cd' `agree` field (lines 639-646): by_cases + simp only [if_pos h] before intro nf
- [ ] Rewrite cd' `bound` field (lines 647-650): dite with rw [if_pos h] / rw [if_neg h]
- [ ] Rewrite cd' `consistent` field (lines 651-667): Fin.cast witness pattern
- [ ] Run `lake build` and confirm zero errors in both oracle regions

**Timing**: 0.5 hours (copy Phase 1 pattern with minor adjustments for backward direction)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 631-668 (h_idx' + backward oracle cd')

**Verification**:
- `lake build` shows zero errors in backward oracle region (lines 627-669)
- Forward oracle from Phase 1 still compiles
- Recursive `build_bicompat` call at line 669 type-checks

---

### Phase 3: Rewrite sum_lift_one_var cd0 and Final Verification [NOT STARTED]

**Goal**: Apply the dite + Fin.cast pattern to the cd0 construction in `sum_lift_one_var` (lines 772-813), then verify the full project builds cleanly.

**Tasks**:
- [ ] Rewrite cd0 `eM` field (lines 774-778): `fun j' x => if h : j' = i then (h ▸ fun q => (![a]) q) (Fin.cast (if_pos h) x) else Fin.elim0 (Fin.cast (if_neg h) x)` -- or use @Fin.cons pattern if matrix notation causes issues
- [ ] Rewrite cd0 `eN` field (lines 779-783): symmetric pattern with `b`, `ms'`
- [ ] Rewrite cd0 `agree` field (lines 784-802): `by_cases h : j' = i; . simp only [if_pos h]; intro nf; <close with h_agree_comp>; . simp only [if_neg h]; intro nf; <close with h_comp>`
- [ ] Rewrite cd0 `consistent` field (lines 807-812) if needed: replace `subst hj'; simp only [dif_pos rfl]` with `Fin.cast (if_pos rfl).symm` witness pattern
- [ ] Run `lake build` and confirm exit code 0
- [ ] Verify zero sorries: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
- [ ] Verify no downstream regressions in files importing NEquivalence.lean

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 772-813 (sum_lift_one_var cd0)

**Verification**:
- `lake build` exits with code 0
- Zero sorries in NEquivalence.lean
- `doets_lemma_1_4` in OrderedSum.lean is transitively sorry-free
- No downstream regressions

## Testing & Validation

- [ ] `lake build` succeeds with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows zero matches
- [ ] No new errors in files importing NEquivalence.lean or OrderedSum.lean
- [ ] `sum_preservation_proof` transitively sorry-free (verify with `lean_verify` or grep)

## Artifacts & Outputs

- `specs/154_sum_preservation_ef_games/plans/07_sum-preservation-plan.md` (this file, v11)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (rewrite h_idx' proofs, forward cd' block, backward cd' block, sum_lift_one_var cd0 block)

## Rollback/Contingency

- Git revert to current HEAD restores the zero-sorries-17-errors state
- If the dite + Fin.cast pattern fails on integration (despite standalone verification), try Teammate D's `Function.update` + named `extendFn` helper as alternative
- If the `agree` field with `simp only [if_pos h]` before `intro nf` fails in the actual context, fall back to Teammate B's pure term-mode agree: `fun j' x y => if h : j' = j then ext_agree (Fin.cast (...) x) (Fin.cast (if_pos h) y) else cd.agree j' (Fin.cast (...) x) (Fin.cast (if_neg h) y)`
- If `hbound` derivation fails at the call site, add an explicit `have hbound : cd.sz j + 1 < budget := by omega` with all available hypotheses (`hdn`, `cd.bound j`) in scope
- If cd0 in `sum_lift_one_var` resists the pattern (it is structurally simpler), keep the existing `show ... from by rw [if_pos h, h]; exact ...` approach for eM/eN and only rewrite `agree`/`consistent` fields that use `subst`
- PROHIBITED: No `sorry`, no `def X := True`, no vacuous placeholders
