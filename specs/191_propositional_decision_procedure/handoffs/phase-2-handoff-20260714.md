# Phase 2 Handoff — Task 191

**Status**: Phase 1 and Phase 2 COMPLETED, zero sorries, only standard axioms
(propext, Classical.choice, Quot.sound).

## Completed
- `Theories/Bimodal/Metalogic/Decidability/Propositional/PropForm.lean` — deep embedding,
  `eval`, `vars`, `tautoAux`/`isTaut`, `denote`, `isTaut_iff_forall_eval`, 3 decide smoke tests.
- `Theories/Bimodal/Metalogic/Decidability/Propositional/Kalmar.lean` (partial, ~135 lines) —
  `neg_imp_intro` (the one new object-level lemma, via `ni` + `deduction_theorem` head-elimination
  order `[ψ.neg, φ]`), `litDenote`, `litCtx`, simp normal-form lemmas, `litDenote_var_mem`,
  `litCtx_update_not_mem`.

## Next Action (Phase 3)
Add `kalmar_step` to `Kalmar.lean` by induction on `PropForm`:
- `var n`: `DerivationTree.assumption` via `litDenote_var_mem`.
- `fls`: weakened `identity` (`Theorems/Combinators.lean:118`), since `eval v fls = false`
  always so `litDenote env v fls = ⊥.neg = ⊥.imp ⊥` — need `Formula.neg` unfold: `⊥.neg = ⊥.imp ⊥`,
  matches `identity Formula.bot` weakened to the literal context.
- `imp f g`, `g.eval v = true`: IH gives `Γ ⊢ litDenote env v g = g.denote env`; use
  `prop_s (Axioms.lean:84)` instantiated `(g.denote env) (f.denote env)` + mp to get
  `Γ ⊢ (f.denote env).imp (g.denote env)`, matching `litDenote_of_true` on `imp f g`.
- `imp f g`, `f.eval v = false`: IH gives `Γ ⊢ litDenote env v f = (f.denote env).neg`;
  use `raa`/`theorem_flip` (Combinators) or `efq`-style flip to derive
  `Γ ⊢ (f.denote env).imp (g.denote env)` from `¬(f.denote env)`.
- `imp f g`, `f.eval v = true ∧ g.eval v = false`: IHs give `Γ ⊢ f.denote env` and
  `Γ ⊢ (g.denote env).neg`; apply `neg_imp_intro` + two `mp`s to get
  `Γ ⊢ ((f.denote env).imp (g.denote env)).neg`.

Signature target: `kalmar_step (f : PropForm) (env : Nat → Formula) (v : Nat → Bool)
(vars : List Nat) (hsub : f.vars ⊆ vars) : (litCtx env v vars) ⊢ (litDenote env v f)`.

## Deviations
None so far — plan followed exactly.
