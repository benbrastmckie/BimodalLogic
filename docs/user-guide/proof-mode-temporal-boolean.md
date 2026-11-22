# Temporal congruence

Under `G` or `H`, use a guarantee in the matching strict scope. The same guarantee can
rewrite the guard or event of Until or Since. A Next or Previous path accepts a guarantee in
its adjacent scope or a guarantee in the corresponding strict universal scope.

```lean
example (Γ : Context) (A B C : Formula) (h : Γ ⊢ (A.imp B).allPast)
    (old : Γ ⊢ Formula.snce A C) : Γ ⊢ Formula.snce B C := by
  lrewrite h (path := [sinceGuard]) at old as mapped
  lexact mapped
```

[Checked examples](../../Tests/BimodalTest/Automation/ProofModeTemporalBooleanTest.lean)
include past directions and explicit frame-class premises.

[Derivation proof mode](derivation-proof-mode.md)
