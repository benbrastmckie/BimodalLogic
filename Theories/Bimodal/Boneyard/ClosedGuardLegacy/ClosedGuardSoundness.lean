/-!
# Archived Soundness Proofs (Closed/Half-Closed Guard)

Archived 2026-04-27 (task 113): These validity theorems relied on the guard
inequality including the base point (t ≤ r for Until, r ≤ t for Since).
Under open guard (t,s), the base point t is excluded, breaking the `le_refl`
step that was essential to each proof.

## From Soundness.lean

### until_guard_valid

```lean
theorem until_guard_valid (φ ψ : Formula) :
    ⊨ ((Formula.untl φ ψ).imp φ) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro ⟨s, hts, _h_ψs, h_guard⟩
  exact h_guard t le_rfl hts    -- le_rfl : t ≤ t, which no longer holds (need t < t)
```

### since_guard_valid

```lean
theorem since_guard_valid (φ ψ : Formula) :
    ⊨ ((Formula.snce φ ψ).imp φ) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro ⟨s, hst, _h_ψs, h_guard⟩
  exact h_guard t hst le_rfl    -- le_rfl : t ≤ t, which no longer holds (need t < t)
```

### until_elim_valid

```lean
theorem until_elim_valid (φ ψ : Formula) :
    ⊨ ((Formula.untl φ ψ).imp (Formula.or φ ψ)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.or, Formula.neg]
  intro ⟨s, hts, _h_ψs, h_guard⟩
  intro h_not_φ
  exact absurd (h_guard t le_rfl hts) h_not_φ
```

### since_elim_valid

```lean
theorem since_elim_valid (φ ψ : Formula) :
    ⊨ ((Formula.snce φ ψ).imp (Formula.or φ ψ)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.or, Formula.neg]
  intro ⟨s, hst, _h_ψs, h_guard⟩
  intro h_not_φ
  exact absurd (h_guard t hst le_rfl) h_not_φ
```

## From SoundnessLemmas.lean (4 match blocks)

The same pattern appeared in 4 exhaustive match blocks in SoundnessLemmas.lean:
- `swap_axiom_valid` (~line 714-803)
- `axiom_locally_valid` (~line 1250-1283)
- `swap_axiom_valid_general` (~line 1653-1700)
- `axiom_locally_valid_general` (~line 1873-1906)

Each block had match arms for `until_elim`, `since_elim`, `until_guard`, and
`since_guard` using `le_refl` or `le_rfl` to instantiate the guard at the
base point. All such arms were removed when the constructors were deleted.
-/
