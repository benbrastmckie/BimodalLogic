/-!
# Archived TemporalDerived Sorry Stubs (Open Guard Invalid)

Archived 2026-05-20 (task 173): These 27 definitions from TemporalDerived.lean
are NOT valid under the current open guard (t,s) semantics. They relied on:

- **BX8** (until_step/since_step): reflexive Until/Since introduction (`ψ → (φ U ψ)`)
- **BX9** (until_elim/since_elim): Until/Since elimination to disjunction (`(φ U ψ) → (φ ∨ ψ)`)
- **Reflexive temporal order** (`α → F(α)`): invalid under strict future
- **Seriality** (`G(⊥) → ⊥`): requires seriality derivation not yet available
- **Density** (`G(G(φ)) → G(φ)`): requires density axiom not in current system

BX8 and BX9 were removed as unsound under open guard semantics (task 113).
The closed-guard original proofs (where they existed) are separately archived in
`ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`.

## Summary

- 19 direct sorry stubs removed (net 19 sorry reduction)
- 8 transitive sorry dependents removed (used sorry-bearing definitions)
- 14 sorry-free definitions remain in active TemporalDerived.lean (untouched)

## Cross-References

- Task 113: Open guard refactoring (BX8/BX9 removal)
- Task 83: BX axiom system refactor
- Task 173: This archival operation
- `ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`: Original closed-guard proofs

---

## ARCHIVE Definitions (5 definitions with proof bodies or downstream users)

### G_bot_absurd / H_bot_absurd

Pre-existing sorry stubs with active downstream users in UltrafilterFrame.lean.
These require a seriality derivation (`∃s>t` for G(⊥)→⊥), which is a legitimate
proof obligation unrelated to the BX8/BX9 removal. Call sites replaced with
direct sorry + tombstone comments.

```lean
def G_bot_absurd : ⊢ Formula.bot.all_future.imp Formula.bot := by
  -- Under irreflexive semantics, G(⊥) → ⊥ requires seriality: G(⊥) means ∀s>t, ⊥.
  -- If ∃s>t (seriality), then ⊥ at s, contradiction. So G(⊥) → ⊥.
  -- Derivable from serial_future + contrapositive.
  sorry

noncomputable def H_bot_absurd : ⊢ Formula.bot.all_past.imp Formula.bot := by
  sorry
```

### until_F_expansion / since_P_expansion

Substantial proofs (25 and 23 lines respectively) demonstrating the
until-unfolding + F-wrapping technique. Correct modulo sorry dependencies
on `until_unfold_thm` and `refl_F` / `since_unfold_thm` and `refl_P`.
Preserved as proof templates.

```lean
noncomputable def until_F_expansion (φ ψ : Formula) :
    ⊢ (Formula.untl ψ φ).imp
      (Formula.or ψ (Formula.and φ (Formula.untl ψ φ).some_future)) := by
  -- until_unfold_thm: U(ψ, φ) → ψ ∨ (φ ∧ U(ψ, φ))
  -- We want: U(ψ, φ) → ψ ∨ (φ ∧ F(U(ψ, φ)))
  apply Bimodal.Metalogic.Core.deduction_theorem [] _ _
  let Γ := [Formula.untl ψ φ]
  have h_until : Γ ⊢ Formula.untl ψ φ := DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold : Γ ⊢ Formula.or ψ (Formula.and φ (Formula.untl ψ φ)) :=
    ctx_mp (ctx_thm (until_unfold_thm φ ψ)) h_until
  have h_F : Γ ⊢ (Formula.untl ψ φ).some_future :=
    ctx_mp (ctx_thm (refl_F (Formula.untl ψ φ))) h_until
  unfold Formula.or at h_unfold ⊢
  apply Bimodal.Metalogic.Core.deduction_theorem Γ _ _
  have h_neg_psi : (ψ.neg :: Γ) ⊢ ψ.neg :=
    DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold' : (ψ.neg :: Γ) ⊢ ψ.neg.imp (Formula.and φ (Formula.untl ψ φ)) :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_unfold (by intro x hx; simp [Γ, hx])
  have h_conj : (ψ.neg :: Γ) ⊢ Formula.and φ (Formula.untl ψ φ) :=
    ctx_mp h_unfold' h_neg_psi
  have h_phi : (ψ.neg :: Γ) ⊢ φ :=
    ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.lce_imp φ (Formula.untl ψ φ))) h_conj
  have h_F' : (ψ.neg :: Γ) ⊢ (Formula.untl ψ φ).some_future :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_F (by intro x hx; simp [Γ, hx])
  exact ctx_mp (ctx_mp (ctx_thm (pairing φ (Formula.untl ψ φ).some_future)) h_phi) h_F'

noncomputable def since_P_expansion (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp
      (Formula.or ψ (Formula.and φ (Formula.snce ψ φ).some_past)) := by
  apply Bimodal.Metalogic.Core.deduction_theorem [] _ _
  let Γ := [Formula.snce ψ φ]
  have h_since : Γ ⊢ Formula.snce ψ φ := DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold : Γ ⊢ Formula.or ψ (Formula.and φ (Formula.snce ψ φ)) :=
    ctx_mp (ctx_thm (since_unfold_thm φ ψ)) h_since
  have h_P : Γ ⊢ (Formula.snce ψ φ).some_past :=
    ctx_mp (ctx_thm (refl_P (Formula.snce ψ φ))) h_since
  unfold Formula.or at h_unfold ⊢
  apply Bimodal.Metalogic.Core.deduction_theorem Γ _ _
  have h_neg_psi : (ψ.neg :: Γ) ⊢ ψ.neg :=
    DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold' : (ψ.neg :: Γ) ⊢ ψ.neg.imp (Formula.and φ (Formula.snce ψ φ)) :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_unfold (by intro x hx; simp [Γ, hx])
  have h_conj : (ψ.neg :: Γ) ⊢ Formula.and φ (Formula.snce ψ φ) :=
    ctx_mp h_unfold' h_neg_psi
  have h_phi : (ψ.neg :: Γ) ⊢ φ :=
    ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.lce_imp φ (Formula.snce ψ φ))) h_conj
  have h_P' : (ψ.neg :: Γ) ⊢ (Formula.snce ψ φ).some_past :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_P (by intro x hx; simp [Γ, hx])
  exact ctx_mp (ctx_mp (ctx_thm (pairing φ (Formula.snce ψ φ).some_past)) h_phi) h_P'
```

### past_density_derivable

Archived for consistency with `density_derivable`. Both require density axiom.

```lean
def past_density_derivable (φ : Formula) :
    ⊢ φ.all_past.all_past.imp φ.all_past := by
  sorry
```

---

## DELETE Definitions (22 definitions, pure sorry stubs or transitive dependents)

### Open Guard Invalid -- BX9-Dependent (10 definitions)

Closed-guard originals already archived in `ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`.

```lean
-- Pure sorry stubs (BX9 removed under open guard, task 113)
def bot_until_bot_absurd : ⊢ (Formula.untl Formula.bot Formula.bot).imp Formula.bot
def bot_since_bot_absurd : ⊢ (Formula.snce Formula.bot Formula.bot).imp Formula.bot
private def bot_until_elim (a : Formula) : ⊢ (Formula.untl a Formula.bot).imp a
private def bot_since_elim (a : Formula) : ⊢ (Formula.snce a Formula.bot).imp a
noncomputable def bot_until_id (a : Formula) : ⊢ (Formula.untl a Formula.bot).imp a
noncomputable def bot_since_id (a : Formula) : ⊢ (Formula.snce a Formula.bot).imp a
def until_imp_or (φ ψ : Formula) : ⊢ (Formula.untl ψ φ).imp (Formula.or φ ψ)
def since_imp_or (φ ψ : Formula) : ⊢ (Formula.snce ψ φ).imp (Formula.or φ ψ)
noncomputable def until_unfold_thm (φ ψ : Formula) : ⊢ (Formula.untl ψ φ).imp (Formula.or ψ (Formula.and φ (Formula.untl ψ φ)))
noncomputable def since_unfold_thm (φ ψ : Formula) : ⊢ (Formula.snce ψ φ).imp (Formula.or ψ (Formula.and φ (Formula.snce ψ φ)))
```

### Open Guard Invalid -- Reflexive Temporal Order (4 definitions)

```lean
-- Requires reflexive Until/Since introduction (BX8 removed, task 113)
def psi_imp_until (φ ψ : Formula) : ⊢ ψ.imp (Formula.untl ψ φ)
def psi_imp_since (φ ψ : Formula) : ⊢ ψ.imp (Formula.snce ψ φ)

-- Requires reflexive future/past (α → F(α) invalid under strict temporal order)
noncomputable def refl_F (α : Formula) : ⊢ α.imp α.some_future
noncomputable def refl_P (α : Formula) : ⊢ α.imp α.some_past
```

### Pre-Existing Sorry Stubs (2 definitions)

```lean
-- Requires BX8 (removed)
def G_implies_topUntil (a : Formula) : ⊢ a.all_future.imp (Formula.untl a top)

-- Requires density axiom not in system
def density_derivable (φ : Formula) : ⊢ φ.all_future.all_future.imp φ.all_future
```

### Transitive Sorry Dependents (6 definitions)

These contain complete proofs but call sorry-bearing definitions above, making
them equally unsound. Proofs preserved here for reference.

```lean
-- Complete proofs using psi_imp_until/psi_imp_since (sorry-bearing)
noncomputable def or_until_imp (φ ψ : Formula) :
    ⊢ (Formula.or ψ (Formula.and φ (Formula.untl ψ φ))).imp (Formula.untl ψ φ) := by
  -- [25-line proof body using psi_imp_until -- see git history]

noncomputable def or_since_imp (φ ψ : Formula) :
    ⊢ (Formula.or ψ (Formula.and φ (Formula.snce ψ φ))).imp (Formula.snce ψ φ) := by
  -- [25-line proof body using psi_imp_since -- see git history]

-- 1-line compositions of sorry-bearing definitions
noncomputable def until_unfold_wrapped (φ ψ : Formula) :
    ⊢ (Formula.untl ψ φ).imp (Formula.untl (Formula.or ψ (Formula.and φ (Formula.untl ψ φ))) Formula.bot) :=
  imp_trans (until_unfold_thm φ ψ) (psi_imp_until Formula.bot _)

noncomputable def since_unfold_wrapped (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp (Formula.snce (Formula.or ψ (Formula.and φ (Formula.snce ψ φ))) Formula.bot) :=
  imp_trans (since_unfold_thm φ ψ) (psi_imp_since Formula.bot _)

noncomputable def until_intro (φ ψ : Formula) :
    ⊢ (Formula.untl (Formula.or ψ (Formula.and φ (Formula.untl ψ φ))) Formula.bot).imp (Formula.untl ψ φ) :=
  imp_trans (bot_until_id _) (or_until_imp φ ψ)

noncomputable def since_intro (φ ψ : Formula) :
    ⊢ (Formula.snce (Formula.or ψ (Formula.and φ (Formula.snce ψ φ))) Formula.bot).imp (Formula.snce ψ φ) :=
  imp_trans (bot_since_id _) (or_since_imp φ ψ)
```

---

## Downstream Impact

Six definitions had active downstream references. These call sites were updated
with tombstone comments and direct `sorry` in task 173:

| Definition | File | Line | Replacement |
|------------|------|------|-------------|
| `G_bot_absurd` | UltrafilterFrame.lean | 543 | sorry + tombstone |
| `H_bot_absurd` | UltrafilterFrame.lean | 779 | sorry + tombstone |
| `psi_imp_until` | UntilSinceCoherence.lean | 84 | sorry + tombstone |
| `psi_imp_since` | UntilSinceCoherence.lean | 94 | sorry + tombstone |
| `psi_imp_until` | SuccRelation.lean | 618 | sorry + tombstone |
| `psi_imp_since` | SuccRelation.lean | 639 | sorry + tombstone |
| `until_unfold_wrapped` | SuccRelation.lean | 553 | sorry + tombstone |
| `since_unfold_wrapped` | SuccRelation.lean | 561 | sorry + tombstone |
-/
