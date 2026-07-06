# Implementation Summary: Task #305 (plan v38 — Lemma 3.4 m=1 rewire)

- **Plan**: plans/38_lemma34-m1-rewire.md
- **Session**: sess_1783306400_33dd64

## Phase 7: Leftward existential closure — bracketBuildLeft + existClosureLeft + iff [COMPLETED]

**Goal**: Build the Since-mirror of the proven rightward absorption (`bracketBuildLeft` +
`existClosureLeft` + the leftward absorption iff), sorry-free and off the live import path.

### What landed

- **`VecEATranslation.lean`** (canonical, upstream): `chainHoldsLeft`, `bracketBuildLeft`
  (Since-nested via `Formula.snce`, peeling the rightmost witness), the private witness lemmas
  `bracket_append_witness` / `bracket_extract_last_witness`, definitional equation lemmas
  (`chainHoldsLeft_{zero,succ}_eq`, `bracketBuildLeft_{zero,succ}_eq`), `chainHoldsLeft_iff_holds`,
  `bracketBuildLeft_iff_chainHoldsLeft`, and `bracketBuildLeft_correct`:
  `temporal_truth M atomMap t (bracketBuildLeft bf endLeft) ↔ ∃ z0 < t, endLeft.eval_at z0 ∧ bf.holds z0 t`.
- **`VecEA_m.lean`**: `prependEnv` (index-0 prepend) + `prependEnv_zero`/`prependEnv_succ`
  (`@[simp]`), `VecEA_m.existClosureLeft` (absorbs the leftmost free variable `z_0` by folding the
  leftmost interval bracket + endpoint into `z_1`'s endpoint via `bracketBuildLeft`), and the two
  directions `existClosureLeft_correct` / `existClosureLeft_correct_rev`:
  `existClosureLeft.holds env ↔ ∃ z < env 0, vea.holds (prependEnv z env)`.

### Deviation — `bracketBuildLeft` already existed

Report 38 asserted `bracketBuildLeft`/`_correct` were MISSING. In fact a complete, sorry-free copy
existed in `NfToVecEA.lean` (downstream of `VecEATranslation.lean`), under an outdated
"sorries at n > 0" docstring. Because `VecEA_m` (home of `existClosureLeft`) is upstream of
`NfToVecEA`, that copy was unreachable. Resolution: the canonical copy was placed in
`VecEATranslation.lean`; the duplicate block was deleted from `NfToVecEA.lean` and its two
`bracketBuildLeft_correct_zero` usages repointed to the general `bracketBuildLeft_correct`. Single
source of truth, still sorry-free.

### Verification (actual output)

- `lake build` — **Build completed successfully (1700 jobs)**.
- `lean_verify VecEA_m.existClosureLeft_correct` → `axioms: [propext, Classical.choice, Quot.sound]`, no warnings.
- `lean_verify VecEA_m.existClosureLeft_correct_rev` → `axioms: [propext, Classical.choice, Quot.sound]`, no warnings.
- `lean_verify bracketBuildLeft_correct` → `axioms: [propext, Classical.choice, Quot.sound]`, no warnings.
- Live-path sorry baseline **UNCHANGED at 2** (`KampPrior.lean:391`, `:394` — untouched; Phase 7 is off-path).
- New Phase 7 declarations: **0 sorries**. No new top-level `axiom` in `Theories/`.

### Follow-up

- Phase 8 (n=1 witness-position split + live rewire of `KampPrior:391`) can now consume
  `VecEA_m.existClosureLeft` (leftward), the existing `existClosure` (rightward), and `VVecEA_m.disj`.
