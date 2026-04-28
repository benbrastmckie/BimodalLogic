/-!
# Archived TemporalDerived Theorems (Closed/Half-Closed Guard)

Archived 2026-04-27 (task 113): These derived theorems depended on BX9
(until_elim / since_elim) and/or the until_guard / since_guard axiom
constructors, which are unsound under open guard (t,s).

## BX9-Dependent Theorems

### bot_until_bot_absurd / bot_since_bot_absurd

```lean
def bot_until_bot_absurd : ⊢ (Formula.untl Formula.bot Formula.bot).imp Formula.bot :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.until_elim Formula.bot Formula.bot))
    (mp (identity Formula.bot) theorem_app1)

def bot_since_bot_absurd : ⊢ (Formula.snce Formula.bot Formula.bot).imp Formula.bot :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.since_elim Formula.bot Formula.bot))
    (mp (identity Formula.bot) theorem_app1)
```

### bot_until_elim / bot_since_elim (private)

```lean
private def bot_until_elim (a : Formula) :
    ⊢ (Formula.untl Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.until_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))

private def bot_since_elim (a : Formula) :
    ⊢ (Formula.snce Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.since_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))
```

### until_imp_or / since_imp_or

```lean
def until_imp_or (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp (Formula.or φ ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_elim φ ψ)

def since_imp_or (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp (Formula.or φ ψ) :=
  DerivationTree.axiom [] _ (Axiom.since_elim φ ψ)
```

### bot_until_id / bot_since_id

```lean
noncomputable def bot_until_id (a : Formula) :
    ⊢ (Formula.untl Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.until_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))

noncomputable def bot_since_id (a : Formula) :
    ⊢ (Formula.snce Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.since_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))
```

### until_unfold_thm / since_unfold_thm

```lean
noncomputable def until_unfold_thm (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp (Formula.or ψ (Formula.and φ (Formula.untl φ ψ))) :=
  imp_trans
    (imp_trans (DerivationTree.axiom [] _ (Axiom.self_accum_until φ ψ))
              (DerivationTree.axiom [] _ (Axiom.until_elim (Formula.and φ (Formula.untl φ ψ)) ψ)))
    (formula_or_comm _ _)

noncomputable def since_unfold_thm (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp (Formula.or ψ (Formula.and φ (Formula.snce φ ψ))) :=
  imp_trans
    (imp_trans (DerivationTree.axiom [] _ (Axiom.self_accum_since φ ψ))
              (DerivationTree.axiom [] _ (Axiom.since_elim (Formula.and φ (Formula.snce φ ψ)) ψ)))
    (formula_or_comm _ _)
```

## Downstream Impact

These theorems form a chain: bot_until_id -> or_until_imp -> until_intro ->
until_unfold_wrapped. The entire chain is invalidated by the removal of BX9.
Under open guard semantics, replacement strategies must either:
1. Derive the theorems using BX10 + BX5 instead of BX9, or
2. Accept that some of these theorems are genuinely unprovable and revise
   the canonical completeness construction accordingly.
-/
