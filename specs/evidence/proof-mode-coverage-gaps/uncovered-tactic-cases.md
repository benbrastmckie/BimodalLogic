# Proof-mode tactic coverage: the two remaining gaps

Every tactic declared in `FormalSystem/Automation/ProofMode/` has at least one case in
`Tests/BimodalTest/Automation/ProofModeTest.lean`. Two *variants* remain unexercised, and both
cases below compile green against the current test suite (`lake build
BimodalTest.Automation.ProofModeTest`, 721/721).

## `ltemporal_use` on a future goal in TM

The only `ltemporal_use` case in the suite (`ProofModeTest.lean:135-141`) is a TM⁺
`PlusDerivationTree` on an `allPast` goal. Two independent branches of the elaborator are
therefore never taken by any test:

- **The scope match.** `Temporal.lean`'s `temporalUse` matches `allFuture` first and falls back to
  `allPast`. Only the `allPast` arm is reached, so the `Scope.future` arm — and with it the
  `gDistribution` selection, as against `hDistribution` — is untested in *either* language.
- **The language dispatch.** `Language.ruleName language tm plus = if language == .tm then tm
  else plus` (`Meta.lean:50-51`). Only the `plus` arm is reached.

The two constants that arm selects are not interchangeable in shape:
`Theorems.TemporalDerived.gDistribution {fc : FrameClass} (φ ψ : Formula)` against
`PlusLanguage.ProofMode.gDistribution` (`Theorems/ProofMode/PlusRules.lean:215`). Both are applied
through one `mkAppOptM name #[some judgment.frame, some _, some _]`, so the argument array is
built dynamically and nothing in a library compile checks that it still fits the TM constant. A
signature change that the static call site in
`Metalogic/Conservativity/Plus/Corollaries.lean:151` still satisfies could leave this arm broken
with the suite green.

## `lhave` without `:=`

Only the `lhave h : A := d` form is covered. `haveProof` (`Basic.lean:100-124`) shares all of its
setup between the two forms and diverges in one line: the `none` arm leaves two goals,
`[proofGoal, continuationGoal]`, where the `some` arm checks `isDefEq` and leaves one. The
untested behaviour is the goal count and their order, which is user-facing — the bullet structure
of any proof using the bare form depends on it. Thinner than the gap above, but it is the only
test that would pin it.

## The cases

Both go inside `namespace BimodalTest.Automation.ProofModeTest`, which supplies
`open FormalSystem.Syntax FormalSystem.ProofSystem` and `variable (A B C : Formula)`.

```lean
-- A G-scoped implication applied in TM, leaving its G premise.
example : [(A.imp B).allFuture, A.allFuture] ⊢ B.allFuture := by
  lstart hMap hA
  ltemporal_use hMap
  lexact hA

-- `lhave` without `:=` leaves the intermediate assertion as its own obligation.
example : [A, A.imp B] ⊢ B.and A := by
  lstart hA hAB
  lhave hB : B
  · lapply hAB
    lexact hA
  · lsplit
    · lexact hB
    · lexact hA
```
