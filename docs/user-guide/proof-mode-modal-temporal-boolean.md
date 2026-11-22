# Combining modal and temporal scopes

A nested rewrite uses the scopes of its path in order. A boxed guarantee supplies a
strict future or past guarantee through the proved scope conversion. To rewrite under
both operators, supply the nested scope or a rule that can be lifted there.

```lean
example (Γ : Context) (A B C : Formula)
    (mapping : Γ ⊢ (A.imp B).allFuture.box)
    (provider : Γ ⊢ (A.or C).allFuture.box) : Γ ⊢ (B.or C).allFuture.box := by
  lrewrite mapping at provider as mapped
  lexact mapped
```

[Checked examples](../../Tests/BimodalTest/Automation/ProofModeModalTemporalBooleanTest.lean)
cover the mixed scope, TM⁺ stability, and conditional Next.

[Derivation proof mode](derivation-proof-mode.md)
