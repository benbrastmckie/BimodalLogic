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

---

## Phase 3 Archives (2026-04-28, task 113)

The following additional lemmas were archived during Phase 3 cleanup.
All are genuinely INVALID under open guard semantics (t,s).

### until_disjunction_in_mcs (from RRelation.lean)

```lean
theorem until_disjunction_in_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {γ δ : Formula}
    (h_until : Formula.untl γ δ ∈ A) :
    Formula.or γ δ ∈ A
```

**Why invalid**: Was provable from BX9 (until_elim: `(φ U ψ) → (φ ∨ ψ)`).
Under open guard (t,s), the evaluation point t is NOT in the guard interval,
so neither γ nor δ need hold at t.

### since_disjunction_in_mcs (from RRelation.lean)

```lean
theorem since_disjunction_in_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {γ δ : Formula}
    (h_since : Formula.snce γ δ ∈ A) :
    Formula.or γ δ ∈ A
```

**Why invalid**: Mirror of `until_disjunction_in_mcs`. Was provable from BX9'
(since_elim). Under open guard (s,t), neither γ nor δ need hold at t.

### untl_absorb_nested (from RRelation.lean)

```lean
noncomputable def untl_absorb_nested (γ δ : Formula) :
    DerivationTree [] ((Formula.untl γ (Formula.untl γ δ)).imp (Formula.untl γ δ))
```

**Why invalid**: Under open guard, the junction point is not covered.
γ U (γ U δ) at t gives witness s with (γ U δ)(s) and γ on (t,s). Then
(γ U δ)(s) gives s' with δ(s') and γ on (s,s'). But γ(s) is NOT guaranteed
by the open guard (t,s), so γ on (t,s') fails at the junction point s.
Was provable using the until_guard axiom to get γ at the current point.

### snce_absorb_nested (from RRelation.lean)

```lean
noncomputable def snce_absorb_nested (γ δ : Formula) :
    DerivationTree [] ((Formula.snce γ (Formula.snce γ δ)).imp (Formula.snce γ δ))
```

**Why invalid**: Mirror of `untl_absorb_nested`. Junction point not covered
under open guard for Since direction.

### rRelation_of_superset_mcs (from ChronicleTypes.lean)

```lean
theorem rRelation_of_superset_mcs {A B : Set Formula}
    (h_mcs_B : SetMaximalConsistent B)
    (h_sub : A ⊆ B) : rRelation A B
```

**Why invalid**: Required BX9 to extract γ ∨ δ from γ U δ ∈ A ⊆ B,
then case-split on δ ∈ B (left disjunct) vs γ ∈ B with γ U δ ∈ B
(right disjunct). Under open guard, BX9 is removed.

### rRelationSince_of_superset_mcs (from ChronicleTypes.lean)

```lean
theorem rRelationSince_of_superset_mcs {A B : Set Formula}
    (h_mcs_B : SetMaximalConsistent B)
    (h_sub : A ⊆ B) : rRelationSince A B
```

**Why invalid**: Mirror of `rRelation_of_superset_mcs` for Since direction.
Required BX9' (since_elim) which has been removed.
-/
