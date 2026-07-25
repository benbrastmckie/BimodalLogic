# Handoff — Phase 5 partial (second implementation dispatch)

- **Task**: 291 — upgrade_lean_toolchain_to_v431_and_mathlib
- **Session**: `sess_1784959849_77d9d9`
- **HEAD at handoff**: `38ef28ad3`
- **Tree state**: clean except `specs/TODO.md`, `specs/state.json`, `specs/events.jsonl`, which
  were already modified before this dispatch and are not mine to stage.

## Where things stand

| Measure | Start of dispatch | End of dispatch |
|---|---|---|
| Modules elaborated | 1773 / 1877 | **1856 / 1877** |
| `lake build` errors | 3, in 2 files | **39, in 7 files** |
| New `sorry` | 0 | **0** |
| New axioms | 0 | **0** (`grep -c '^axiom ' Theories/` = 2, unchanged) |
| `backward.*` options | 0 | **0** |
| Source files repaired | — | 22 |

**Read the error count correctly.** It rose because each cleared blocker exposes modules the
build had never reached. `lake build` aborts a module's dependents on failure, so the only
monotone progress signal in this phase is *modules elaborated*, which rose by 83. Do not read
3 -> 39 as a regression.

## Immediate next action

`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorK.lean`
(12 errors, the largest cluster). Its errors are `failed to synthesize instance` — the same
family already solved once in the sibling file `ExteriorFiberConsistencyK.lean:80`, where the
fix was to pin the implicit index (`mergeNF (m := n + 1)`), give the `Fin` bound as a term
rather than `by omega`, and supply `(Classical.dec _)` explicitly to `decide` /
`@decide_eq_true`. Read that repair first; it is very likely to transfer.

## Remaining errors by file

| File | Errors | Character |
|---|---|---|
| `Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorK.lean` | 12 | `Decidable` synthesis on NF equalities |
| `IntegerModel/GoodStructures.lean` | 10 | `Equiv` `left_inv`/`right_inv` `rfl`s; `split_ifs` name drift |
| `Kamp/LiftPair.lean` | 6 | `rw` pattern misses + application type mismatch (3 repeated blocks) |
| `Kamp/NfMultiAnchorBridge/Base.lean` | 5 | `rw` pattern misses + unsolved goals |
| `EFGames/CustomGame.lean` | 3 | unsolved goals at `:534`, `:606`, `:613` |
| `Kamp/VVecEA2Collapse.lean` | 2 | unsolved goals |
| `Kamp/Prop42NegationGeneral.lean` | 1 | `simpa` type mismatch after simplification |

`LiftPair.lean`'s six errors are three identical two-error blocks at `:472/:523`, `:765/:812`,
`:1025/:1072` — fix one, apply thrice.

`GoodStructures.lean:448/:451` report `Unknown identifier hyb`: the enclosing
`split_ifs with hxb hyb hyb` now produces a different number of cases, so the names do not bind.
That is the `subgoal-tags` category, not a defeq problem — fix the `split_ifs` name list first,
since `:450`-`:453` are cascades from it.

## Repair patterns that worked (reuse these)

1. **`rw` fails but the pattern is visibly present** -> the mismatch is an instance path or a
   type synonym, and `rw` matches only at reducible/instances transparency. Replace with a
   term-level `refine Iff.trans lemma (Iff.trans ?_ lemma.symm)` or an `exact`/`have`. Term
   elaboration unifies at default transparency and still sees through. Used at
   `NEquivalence.lean:368/432` (`Sigma.Lex.lt_def`) and `NfDepth0Generalized.lean:79`
   (`nfPred_correct`).
2. **"target expression is not type-correct under the `implicit` transparency level"** -> a
   semireducible *type* definition is being unfolded implicitly. Introduce a named helper whose
   declared result type is the semireducible one, so its *inferred* type is syntactically right
   (`orderedSumPt` in `NEquivalence.lean`). Add a `@[simp]` projection lemma if `.1`/`.2` are
   taken of it.
3. **`simp only [X]` reports "no progress"** where `X` unfolds a `Fin.cons`/`Fin.cases` chain ->
   delete the step and use `exact`, which is still definitionally fine. Used in
   `NEquivalence.lean`, `VecEADecomp.lean`, `NfZoneDepthK.lean`.
4. **`convert … using n` leaves a small index/arith goal** -> append `simp` (or `all_goals simp`
   when `convert` left more than one). Conversely a trailing `omega` after `ext` may now report
   "No goals to be solved" -> guard it with `try`.
5. **Mathlib order-lemma renames** have no deprecation aliases. Sweep repo-wide, not per failing
   file, or you pay a full rebuild per discovery. Full table in `inventory/01_error-inventory.md`
   row N3. All five are pure identifier substitutions with identical statements.

## Do not relitigate

Everything in `handoffs/phase-4-handoff-1784965800.md` still stands, plus:

- **`@[reducible]` on `orderedSum` is rejected.** It fixes the elaboration failures in
  `NEquivalence.lean` but lets typeclass search see through `.carrier` to the raw `Sigma`, at
  which point Mathlib's non-lexicographic `Sigma.preorder` beats the locally registered
  `carrier_order` — a silently *different order*. Observed at `GoodStructures.lean:448-461`.
  Reverted; a comment on the definition records why. Use the `orderedSumPt` helper instead.
- `@[reducible]` **is** applied to `k_equiv` and should stay: it is Prop-valued and unfolds to an
  equation, so no instance can be selected on it.
- `normalForm_card` (`NormalForm.lean:599`) is fixed via `Fintype.card_congr'`, moving to the
  canonical function-space `Fintype` instance before applying `Fintype.card_fun`. Do not go back
  to `rw [Fintype.card_fun]` on the `normalForm_fintype` instance.
- Marking `NormalForm` itself `@[reducible]` is **untried** and is the one remaining lever that
  would address `GoodStructures.lean:333` and the `ExteriorFiber*` `Decidable` failures in one
  move. It is lower-risk than the `orderedSum` case (its instances — `Fintype`, `DecidableEq` —
  are subsingletons, so a substituted instance cannot change meaning), but it touches ~100
  modules and would need a full rebuild to evaluate. Evaluate it deliberately, not casually.

## Phase status

- Phases 1-4: `[COMPLETED]`.
- Phase 5: `[PARTIAL]` — all 39 remaining errors are in its category.
- Phases 6-10: `[NOT STARTED]`. Note Phase 6 (`heartbeat-timeout`) still reads **zero**, and
  that reading is still *unmeasured* rather than clean: `SharedWitness.lean` (12,800 lines) sits
  behind `NfMultiAnchorBridge/Base.lean`, which is still failing.

## Verification commands

```bash
lake build                                                  # full; ~10 min
lake build Bimodal.Metalogic.WeakCanonical.NEquivalence     # scoped, seconds
bash baseline/compare-exes.sh baseline/exe <new-capture>    # Phase 8 gate
```
