# Task 311 Phase 5 Handoff (2026-07-06) — FINAL PHASE, TASK COMPLETE

## Immediate Next Action

None within task 311 — all 5 phases [COMPLETED], **R2 = GO** recorded
(NfMultiAnchorBridge.lean:3394-3434). Downstream: task 309 resumes via `/revise 309`
(plan v4): the depth-`k` lift (R3) targets `BracketCarrierCorrectV` with the k=1 instance
`bracketEndChar_k1v_correct` (:3378) as the recursion template over the k=0 base
`bracketEndChar_k0_correct` (:1581).

## Current State

- Phases 1-5 [COMPLETED]. Full `lake build` GREEN (1705 jobs). Phase 5 diff: 768 insertions,
  0 deletions (all additive after :2665).
- Phase 5 commits: 7cb5ca6a5 (extract clones + insertion induction), 0793dc1c6
  (`k1v_bracket_construct`), 6ec075c1c (`bracketEndChar_k1v_complete`), 8c9fde503
  (assembled `↔` + R2 = GO verdict).
- New declarations (NfMultiAnchorBridge.lean; all axioms exactly
  `[propext, Classical.choice, Quot.sound]` via `lean_verify bracketEndChar_k1v_correct`,
  which transitively covers every private helper):
  - `k1v_extract_y_nf` (:2682), `k1v_extract_x_nf3` (:2697), `k1v_extract_t_nf3` (:2716) —
    private VecEADecomp extraction clones (arity-1 projections of the arity-3 atom layer)
  - `k1v_sorted_insert` (:2738) — one insertion step of the R1' arrangement induction
  - `k1v_sorted_realization` (:2784) — the insertion induction: permutation + strictly
    sorted realizing points, distinctness via `nf_eval_unique`
  - `k1v_bracket_construct` (:2825) — reverse of `k1v_bracket_extract`: assembles
    `bracketFromLists.holds` from sorted tagged points + all-of-interval segment exclusions
  - `bracketEndChar_k1v_complete` (:2966) — RHS→LHS direction (takes only `h_xy`/`h_yt`)
  - `bracketEndChar_k1v_correct` (:3378) — the k=1 `BracketCarrierCorrectV` instance,
    k0-mirror conditional form, sorry-free
  - R2 = GO verdict record (:3394-3434)

## Key Decisions / Gotchas (for the task-309 revision)

- **`cases hb : (efold_of_nf1 qnf).2 (zs, χ)` substitutes the scrutinee in the GOAL**: after
  it, if-conditions read `if true = true`/`if false = true` — use `rw [if_pos rfl]` /
  `rw [if_neg (by simp [hb])]`, NOT `if_pos hb` (Phase 4 never hit this because it cased on
  bits inside hypotheses fetched afterwards).
- **Self-referential simp rewrites loop**: `simp only [show a - b = (a - b - 1) + 1 ...]`
  hits maxRecDepth (RHS contains LHS). Obtain a fresh name first:
  `obtain ⟨j, hj⟩ : ∃ j, i.val = lL.length + 1 + j := ⟨i.val - lL.length - 1, by omega⟩`,
  then `simp only [show i.val - lL.length = j + 1 by omega, List.getElem_cons_succ]`.
- **Zone-spec `have`s need type ascriptions**: standalone
  `zoneHolds M (Fin.cons w …) (Fin.cons pw …) u` cannot infer `n`; ascribe
  `(… : Fin 3 → M.carrier)` and `(… : ZoneSpec 3)` exactly as `k1v_zoneHolds_cons_iff` does.
- **List.Perm `~` notation is scoped to `List`** — spell `List.Perm l₁ l₂` in statements.
- **Goal-side carrier entry**: `simp only [bracketEndChar_k1v, VVecEA2.holds]` then `split`
  (isFalse branch closed by `exact absurd hgate hg`), then
  `refine ⟨_, List.mem_flatMap.mpr ⟨lL, List.mem_permutations.mpr hpermL,
  List.mem_map.mpr ⟨lR, …, rfl⟩⟩, ?_⟩` — the `rfl` pins the disjunct metavariable.
- **Completeness needs only 2 of the 6 k0-mirror bits** (`h_xy`, `h_yt`): the rest are forced
  by the witness's atom layer. The assembled `↔` still carries all six (sound needs them).
- **Segment exclusions hold on ALL of `(x,w)`/`(w,t)`** (the Phase-2 NO-GO record insight):
  a `(char χ).neg` conjunct in `segL` has a false fold bit; a realizing point inside the
  interior zone would force it true via the fold biconditional.

## Sorry Inventory

Empty (no task-owned sorries; pre-existing out-of-scope sorries — KampPrior:351/354,
EANegation:1090/1249, Kamp/Boneyard ×2, and repo-wide non-Kamp files — untouched).
