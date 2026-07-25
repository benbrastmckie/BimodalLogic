# Handoff — after Phase 4

- **Task**: 291 — upgrade_lean_toolchain_to_v431_and_mathlib
- **Session**: `sess_1784959849_77d9d9`
- **HEAD at handoff**: `f091cc5f1`
- **Tree state**: clean except pre-existing `specs/TODO.md`, `specs/state.json`, `specs/events.jsonl`
  modifications that were already present before this dispatch and are not mine to stage.

## Immediate next action

Fix `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean:605`.

```
theorem normalForm_card ... := by
  induction k generalizing n with
  | zero =>
    simp only [NormalForm, nfCount]
    rw [Fintype.card_fun, Fintype.card_bool, atomKind_card]   -- :605 FAILS
```

Goal at failure:

```
⊢ Fintype.card (AtomKind sig n → Bool) = 2 ^ atomCount (Fintype.card sig.preds) n
```

`rw` reports `Did not find an occurrence of the pattern Fintype.card (?m → ?m)`, and Lean adds:
*"The target expression is not type-correct under the `implicit` transparency level, which may have
been caused by unfolding of semireducible definitions in prior tactic steps."*

Diagnosis: `simp only [NormalForm, nfCount]` unfolds the **type** `NormalForm sig 0 n` to
`AtomKind sig n → Bool`, but the `Fintype` instance in the goal is still the one derived for
`NormalForm sig 0 n`, not the canonical `Pi`/function-type instance that `Fintype.card_fun`
expects. So the pattern genuinely does not match at `implicit` transparency.

**Already tried and rejected**: replacing `rw` with `simp [Fintype.card_fun, ...]` — reports
`simp made no progress`, strictly worse. This was reverted; the file is back at the original `rw`.

**Suggested directions** (untried): make the instance explicit rather than swapping tactics —
`Fintype.card_congr` across the type equality, `convert` to absorb the instance mismatch, or
`Fintype.subsingleton`-style instance uniqueness. `:608` is the same problem one level up, over
`Fintype.card ((AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool))`.

Then: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean:374` — "Application type
mismatch", revealed only after `VecEAFormula` was fixed. Not yet diagnosed.

## Current state

- Pin: `leanprover/lean4:v4.33.0-rc1`, Mathlib tag `v4.33.0-rc1` (rev `79d0395a1825`), plausible
  `inherited=true`. Mathlib cache present (8279 oleans).
- `lake build`: **3 errors, 2 files**, reached `[1773/1877]`. Was 12 errors at Phase 3.
- `sorry`: 12 (unchanged from baseline). No new axioms. No `backward.*` options added.

## Key decisions already made — do not relitigate

1. **Single-jump, not staged.** D1 trigger 2 fires literally (early abort) but staging does not
   cure an early abort and attribution is at 0% unattributable. Recorded in
   `inventory/01_error-inventory.md`. Reversal remains cheap via the isolated Phase 2 commit.
2. **Executable baselines use the interpreter**, not `lake exe`. Rationale and the native-linking
   cost measurement are in `baseline/exe/REPRODUCIBILITY.md`. Do **not** re-capture the baseline —
   it can only be taken pre-upgrade and is already committed.
3. **`lake clean` wipes the Mathlib cache.** Always follow it with `lake exe cache get`.

## Traps

- The plan's Phase 5 pre-identified defeq sites at `ChronicleToCountermodelBasic.lean:989/:1000`
  are **already green**. They failed only as cascades from a renamed constant. Do not go looking
  for a transparency problem there.
- The plan's Phase 4 categories (`range-syntax`, `noncomputable`, `subgoal-tags`,
  `meta-api-renames`, `dsimp-no-progress`) all produced **zero** errors. The 5 range-syntax sites
  the plan lists still use `[a:b]` and still compile; do not "fix" them.
- `heartbeat-timeout` reading zero is **unmeasured, not clean** — ~100 modules downstream of the
  current blockers have never been elaborated, including `SharedWitness.lean` (12,800 lines).
- `lean_multi_attempt` is unusable for tactic lines nested inside `induction`/`by_cases` blocks
  here: it truncates the file and reports spurious "alternative not provided" errors. Edit the
  file and run a scoped `lake build Module.Name` instead — the affected modules build in seconds.

## Verification commands

```bash
lake build                                                  # full
lake build Bimodal.Metalogic.WeakCanonical.NormalForm       # scoped, fast
bash baseline/compare-exes.sh baseline/exe <new-capture>    # Phase 8 gate
```
