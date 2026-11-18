# Proof-mode tactic coverage: the two remaining gaps

Every tactic declared in `FormalSystem/Automation/ProofMode/` now has at least one case in
`Tests/BimodalTest/Automation/ProofModeTest.lean`, landed with PR #6's review-feedback commit.
Two *variants* remain unexercised:

- `ltemporal_use` on plain TM. The existing case at `ProofModeTest.lean:136-140` is on the TM+
  `PlusDerivationTree` path, not the `⊢` judgment.
- `lhave` without `:=`, the form that leaves the intermediate assertion as its own obligation.
  Only the `lhave h : A := d` form is covered.

Both tactics resolve their constants by appending single-backtick name literals to a namespace
inside `MetaM` rather than through checked `` ``Name `` literals, so a rename of `Formula.box` or
of a `DerivationTree` constructor would leave the implementation compiling and break these paths
only at invocation. Tests are the only backstop.

## The cases

Both were written and verified passing against PR #6's first commit merged onto main, before the
review-feedback commit landed. They need a re-run against current `main` before use.

They go inside `namespace BimodalTest.Automation.ProofModeTest`, which supplies
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
