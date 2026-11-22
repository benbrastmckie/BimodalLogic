# Boolean rewriting

A rewrite traverses implication, negation, conjunction, and disjunction. The antecedent of
an implication reverses direction. Use a path when more than one subtree matches.

```lean
example (Γ : Context) (A B C : Formula) (h : Γ ⊢ B.imp A)
    (old : Γ ⊢ A.imp C) : Γ ⊢ B.imp C := by
  lrewrite ← h (path := [impLeft]) at old as mapped
  lexact mapped
```

[Checked examples](../../Tests/BimodalTest/Automation/ProofModeBooleanTest.lean)
include goal and fact directions, no-op detection, and simplifier budgets.

[Derivation proof mode](derivation-proof-mode.md)
