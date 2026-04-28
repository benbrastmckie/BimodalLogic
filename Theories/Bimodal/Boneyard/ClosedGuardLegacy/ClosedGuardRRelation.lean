/-!
# Archived RRelation Lemmas (Closed/Half-Closed Guard)

Archived 2026-04-27 (task 113): These MCS lemmas used the until_guard and
since_guard axiom constructors, which are unsound under open guard (t,s).

## until_guard_in_mcs

```lean
/--
`gamma U delta in A` implies `gamma in A` (by until_guard axiom).
Under half-open guard [t,s), the guard holds at the base point t.
-/
theorem until_guard_in_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {γ δ : Formula}
    (h_until : Formula.untl γ δ ∈ A) :
    γ ∈ A := by
  have h_guard : DerivationTree [] ((Formula.untl γ δ).imp γ) :=
    DerivationTree.axiom [] _ (Axiom.until_guard γ δ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_guard) h_until
```

**Why invalid**: The until_guard axiom `(φ U ψ) → φ` is unsound under open
guard. Under open guard (t,s), having φ U ψ at t does NOT guarantee φ(t)
because the guard only covers points strictly between t and s.

## since_guard_in_mcs

```lean
/--
`gamma S delta in A` implies `gamma in A` (by since_guard axiom).
Under half-open guard (s,t], the guard holds at the base point t.
-/
theorem since_guard_in_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {γ δ : Formula}
    (h_since : Formula.snce γ δ ∈ A) :
    γ ∈ A := by
  have h_guard : DerivationTree [] ((Formula.snce γ δ).imp γ) :=
    DerivationTree.axiom [] _ (Axiom.since_guard γ δ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_guard) h_since
```

**Why invalid**: Same reasoning. The since_guard axiom `(φ S ψ) → φ` is
unsound under open guard. The guard covers points strictly between s and t,
not t itself.

## Downstream callers

The following sites called these lemmas and need replacement strategies:
- PointInsertion.lean line 673: `until_guard_in_mcs h_mcs_A h_utl_bot`
- PointInsertion.lean line 786: `until_guard_in_mcs h_mcs_A h_untl`
- PointInsertion.lean line 797: `since_guard_in_mcs h_mcs_C h_snce`
- RRelation.lean line 1193: `until_guard_in_mcs h_mcs_A (h_burgessR _ h_top_C)`
- RRelation.lean line 1236: `DerivationTree.axiom [] _ (Axiom.until_guard γ δ)`
- RRelation.lean line 1260: `DerivationTree.axiom [] _ (Axiom.since_guard γ δ)`
-/
