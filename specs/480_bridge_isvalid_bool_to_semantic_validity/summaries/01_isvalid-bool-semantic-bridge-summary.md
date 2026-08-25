# Implementation Summary: Bridge `isValid`'s `Bool` to Semantic Validity

- **Task**: 480 - bridge_isvalid_bool_to_semantic_validity
- **Type**: lean4
- **Plan**: `specs/480_bridge_isvalid_bool_to_semantic_validity/plans/01_isvalid-bool-semantic-bridge.md`
- **Report**: `specs/480_bridge_isvalid_bool_to_semantic_validity/reports/01_isvalid-bool-semantic-bridge.md`
- **Session**: `sess_1787662855_e59fd5`
- **Baseline commit**: `ba9309d2f`
- **Status**: COMPLETED — all three phases closed

## What Landed

Eleven sorry-free theorems in `FormalSystem/Metalogic/Decidability/Correctness.lean`, inserted
immediately after `decide_sound'` inside the existing namespace and `open` block, with **no new
imports**:

| Theorem | Statement |
|---------|-----------|
| `sound_of_isValid` | `(r : DecisionResult φ) → r.isValid = true → ⊨ φ` |
| `isValid_sound` | `isValid φ fc = true → ⊨ φ` |
| `decide_isValid_sound` | `(decide φ searchDepth tableauFuel fc).isValid = true → ⊨ φ` |
| `isTautology_sound` | `isTautology φ fc = true → ⊨ φ` |
| `isContradiction_sound` | `isContradiction φ fc = true → ⊨ φ.neg` |
| `not_isSatisfiable_sound` | `isSatisfiable φ fc = false → ⊨ φ.neg` |
| `isValid_validDense` | `isValid φ fc = true → ValidDense φ` |
| `isValid_validDiscrete` | `isValid φ fc = true → ValidDiscrete φ` |
| `isValid_validDedekindDense` | `isValid φ fc = true → ValidDedekindDense φ` |
| `decideBlocking_isValid_sound` | `(decideBlocking …).isValid = true → ⊨ φ` |
| `decideAuto_isValid_sound` | `(decideAuto φ fc).isValid = true → ⊨ φ` |

`sound_of_isValid` is the core lemma and is stated at the `DecisionResult` level rather than
against `isValid`'s unfolding, so it covers `decide`, `decideBlocking`, `decideAuto`, and
`decideAutoAdaptive` at once; everything below it is a corollary. Its conclusion is the
*unrelativized* `⊨ φ`, which is forced by the types rather than chosen: `DecisionResult.valid`
carries `⊢ φ` = `DerivationTree FrameClass.Base [] φ` regardless of the `fc` argument, so a `true`
from any frame class yields validity over all task frames. The three frame-class-relative forms
are therefore weakenings, obtained through the pre-existing `Validity.valid_implies_*`
monotonicity lemmas.

`not_isSatisfiable_sound` uses the targeted `simp only [isSatisfiable, decide_eq_false_iff_not,
not_not] at h`. An unrestricted `simp at h` exceeds `maxRecDepth` because `simp` attempts to
evaluate the enclosed decision-procedure call; `maxRecDepth` was deliberately **not** raised.

## Docstring Amendments

1. **`Correctness.lean` "Main Theorems" list** — `sound_of_isValid` and `isValid_sound` added as
   the `Bool`-API bridge; the pointer to the retirement section rephrased to say which *half* of
   an `isValid`-shaped statement is still owed.
2. **`Correctness.lean` retirement section** — the single "What is still owed" paragraph split
   into a new "What has since landed" paragraph recording the sound direction, plus a narrowed
   obligation paragraph naming the **completeness** direction (`⊨ φ → isValid φ fc = true`), the
   biconditional, and the four `Decidable` instances as what remains open. The `validity_decidable`
   / `validity_has_decision_procedure` retirement narrative is untouched in substance — it
   documents a different defect.
3. **`Decidability.lean` open-obligations bullet** — split the same way: sound direction landed,
   completeness direction open.
4. **Negative-finding guard** — `sound_of_isValid`'s docstring records that
   `DecisionResult.isKnownValid` is **not** a usable sound-direction hypothesis, because it is
   also `true` on `extractionFailed`, which carries no `⊢ φ` witness.

## Scope Extension (recorded as required)

`FormalSystem/Metalogic/Decidability.lean` is **outside the delegation's declared `file_scope`**
(`Correctness.lean`, `DecisionProcedure.lean`). It was edited anyway, as both the report and the
plan treat the amendment as blocking rather than optional: its docstring asserted that no
`isValid`-shaped statement is written, which landing the sound direction would have turned into a
self-contradicting tree. The edit is prose-only, 8 insertions / 3 deletions, entirely inside the
`/-!` module docstring opened at line 42.

Conversely, `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean` — in the declared scope —
required **no edit**: all eleven theorems land in `Correctness.lean`.

## Verification Evidence

- **Full `lake build`**: exit 0, 2493 jobs, `Build completed successfully`.
- **Scoped builds**: `lake build FormalSystem.Metalogic.Decidability.Correctness` (1391 jobs) and
  `lake build FormalSystem.Metalogic.Decidability` (1454 jobs, the enumerated direct dependent)
  both green.
- **`#print axioms`** on all eleven theorems: each exactly `[propext, Classical.choice,
  Quot.sound]`. No `sorryAx`.
- **New `sorry`**: zero. `git diff ba9309d2f..HEAD -- FormalSystem/` has exactly two added lines
  containing the string `sorry`, both the prose phrase "sorry-free" inside the new docstrings.
  `lean-sorry-census.sh` reports 160 sorries tree-wide, all of them in
  `FormalSystem/Boneyard/` (pre-existing legacy quarantine); the live tree has none.
- **New `axiom`**: zero. Tree-wide `^axiom ` count is 7, unchanged from baseline.
- **Vacuous definitions**: one grep hit tree-wide,
  `FormalSystem/Examples/TemporalStructures.lean:538`, byte-identical at baseline `ba9309d2f` and
  untouched here — and not a placeholder in any case, since `intTimeHistory.domain` is genuinely
  universally true on `Int`.
- **Non-goals check**: the added declaration set is exactly the eleven theorems above — no
  biconditional, no `isKnownValid` variant, no `Decidable` instance. The three grep hits for `↔`,
  `isKnownValid`, and `Decidable (` in the diff are all prose inside docstrings.
- **Residual-contradiction check**: neither amended file still asserts that no `isValid`-shaped
  sound statement is written.

## Carry-Forward for Task 430

Because `isValid φ .Dense = true` yields *unrelativized* `⊨ φ`, the eventual biconditional at
`fc = .Dense` **cannot** take the naive form `isValid φ .Dense = true ↔ ⊨ φ`: its right-to-left
direction would be false in general if the Dense engine can close tableaux for formulas valid only
on dense orders. This is a constraint on task 430's statement, discovered during research and
confirmed by the types here.

## Plan Deviations

- *(count clarification, not a scope change)* The plan's prose says "ten theorems" while its own
  **Goals** section enumerates eleven declaration names. All eleven were landed and verified. The
  discrepancy is an off-by-one in the plan's prose, not in the delivered declaration set.
- No other deviations — implementation followed the plan.
