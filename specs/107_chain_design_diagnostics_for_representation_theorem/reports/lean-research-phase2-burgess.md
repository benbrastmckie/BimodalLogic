# Lean Research Phase 2: Burgess 1982 Analysis for Task OC_107

## Task Context
Research for Phase 2 of Task OC_107 (chain design diagnostics for representation theorem), focusing on Burgess 1982 "Axioms for Tense Logic Since and Until" Section 2.6 (Lemma 2.6) to resolve:
- Task 2.1: `d0_a_event_list_mem` (line 1409)
- Task 2.2: `burgess_D0_finite_subset_consistent_incons` (line 1798)
- BX chain pattern adaptation for inconsistent case (β.neg ∈ B)
- MCS conjunction helper verification

---

## 1. Burgess Lemma 2.6 Analysis (Inconsistent Case)

### Lemma 2.6 Statement (Burgess 1982 p.370)
If `R(A, B, C)` and `δ ∉ B`, then there exist `B', D, B''` such that:
- `~δ ∈ D`
- `R(A, B', D)` and `R(D, B'', C)`
- `B = B' ∩ D ∩ B''`

### Inconsistent Case (β.neg ∈ B)
When `~β ∈ B` (i.e., `β.neg ∈ B`), the D₀ seed simplifies because `~β` is already in B. Burgess's consistency proof for D₀ uses:

#### BX Chain Pattern (Consistent Case Baseline)
From PointInsertion.lean lines 1917-1929 (consistent case):
1. **BX5 (self_accum_until_mcs)**: `U(β₀, γ₀) ∈ A → U(β₀∧U(β₀,γ₀), γ₀) ∈ A`
2. **BX14 (separation_until_mcs)**: `U(q, q∧(β₀∧β).neg) ∈ A` where `q = β₀∧U(β₀,γ₀)`
3. **BX10 (until_implies_F_mcs)**: `U(q, q∧(β₀∧β).neg) ∈ A → F(q∧(β₀∧β).neg) ∈ A`

#### Compression Argument
For any finite subset of D₀:
- The BX chain derives `F(β.neg) ∈ A`
- If the subset were inconsistent, it would imply a contradiction in B (an MCS), which is impossible
- Thus D₀ is consistent, and the same logic applies to the inconsistent case where `β.neg ∈ B` (no need for BX14 separation, as `β.neg` is already present)

---

## 2. Task 2.1: `d0_a_event_list_mem` Proof Sketch

### Context
```lean
private theorem d0_a_event_list_mem {A B C : Set Formula}
    {β : Formula} {L : List Formula}
    {hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β}
    {α : Formula} (hα : α ∈ d0_a_event_list β L hL) : α ∈ A :=
  sorry  -- TODO Phase 2.1
```

### `d0_a_event_list` Definition (line 1396)
Filters L (subset of D₀ seed) to extract α from `S(β', α)` formulas:
- Returns `none` for `U(β', γ)` (Until formulas)
- Returns `some α` for `S(β', α)` (Since formulas) where `β' ∈ B` and `α ∈ A`

### Proof Steps
1. By `hα`, α is extracted from an `S(β', α)` formula in L
2. By `hL`, this `S(β', α)` is in `burgess_D0_seed A B C β`
3. D₀ seed definition (line 880) includes `{S(β', α) | β' ∈ B, α ∈ A}`, so `α ∈ A` by construction
4. Formal proof uses `Classical.choose_spec` to extract α from the `S(β', α)` match, then applies D₀ seed membership to confirm `α ∈ A`

---

## 3. Task 2.2: `burgess_D0_finite_subset_consistent_incons` Proof Sketch

### Context
```lean
private theorem burgess_D0_finite_subset_consistent_incons {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (β : Formula)
    (h_β_neg_in_B : β.neg ∈ B) :
    SetConsistent (burgess_D0_seed A B C β) :=
  sorry  -- TODO Phase 2.2
```

### Key Differences from Consistent Case
- `β.neg ∈ B` means `~β` is already in B, so no BX14 separation step is needed
- D₀ seed simplifies to `B ∪ {U(β', γ) | β'∈B, γ∈C} ∪ {S(β', α) | β'∈B, α∈A}` (since `β.neg` is already in B)

### Proof Steps
1. **BX5 Chain**: For any `U(β', γ) ∈ D₀` (from `burgessR3` we have `U(β', γ) ∈ A`), apply `self_accum_until_mcs` to get `U(β'∧U(β',γ), γ) ∈ A`
2. **Direct Implication**: Since `β.neg ∈ B` and `β' ∈ B`, `β'∧β.neg ∈ B`. The event `q = β'∧U(β',γ)` implies `β.neg` (because `β' ∈ B` and `β.neg ∈ B`)
3. **BX10**: `U(q, γ) ∈ A → F(q) ∈ A`, and since `q → β.neg`, we get `F(β.neg) ∈ A`
4. **Compression**: Any finite subset of D₀ is consistent because:
   - B is consistent (MCS)
   - `F(β.neg) ∈ A` and `β.neg ∈ B` cannot lead to contradiction
   - Follows Burgess's original compression argument for D₀ consistency

---

## 4. BX Chain Pattern Adaptation for Inconsistent Case

### Consistent Case Pattern (Lines 1917-1929)
| Step | Tactic | Axiom | Result |
|------|--------|-------|--------|
| 1 | `self_accum_until_mcs` | BX5 | `U(β₀∧U(β₀,γ₀), γ₀) ∈ A` |
| 2 | `separation_until_mcs` | BX14 | `U(q, q∧(β₀∧β).neg) ∈ A` (q = β₀∧U(β₀,γ₀)) |
| 3 | `until_implies_F_mcs` | BX10 | `F(q∧(β₀∧β).neg) ∈ A` |

### Inconsistent Case Adaptation (β.neg ∈ B)
| Step | Tactic | Axiom | Result |
|------|--------|-------|--------|
| 1 | `self_accum_until_mcs` | BX5 | `U(β'∧U(β',γ), γ) ∈ A` (from `burgessR3`) |
| 2 | Skip BX14 | - | `β.neg ∈ B` already, no separation needed |
| 3 | `until_implies_F_mcs` | BX10 | `F(β'∧U(β',γ)) ∈ A` |
| 4 | Implication | - | `β'∧U(β',γ) → β.neg` (since `β' ∈ B` and `β.neg ∈ B`) |
| 5 | `SetMaximalConsistent.implication_property` | - | `F(β.neg) ∈ A` |

---

## 5. MCS Conjunction Helper

### Existing Helper
The project already provides `list_conj_mem_mcs` (line 1138):
```lean
private theorem list_conj_mem_mcs {A : Set Formula} (h_mcs : SetMaximalConsistent A) :
    (L : List Formula) → (h : ∀ φ ∈ L, φ ∈ A) → list_conj L ∈ A
```

### For Two Formulas P, Q ∈ A
- `list_conj [P, Q] = P ∧ Q`
- Apply `list_conj_mem_mcs h_mcs [P, Q]` with `h : ∀ φ ∈ [P,Q], φ ∈ A` (trivial from `P∈A` and `Q∈A`)
- Alternatively, use `conj_mcs` (referenced in line 1148): `SetMaximalConsistent` implies closure under conjunction

### Proof Sketch for P∧Q ∈ A
1. `P ∈ A` and `Q ∈ A` (given)
2. Suppose `P∧Q ∉ A`. By maximality of A, `~(P∧Q) ∈ A`
3. `~(P∧Q) = ~P ∨ ~Q`. By MCS disjunction property, `~P ∈ A` or `~Q ∈ A`
4. Contradiction with `P ∈ A` or `Q ∈ A` (MCS consistency: no φ and `~φ` in A)
5. Thus `P∧Q ∈ A`

---

## 6. Recommendations
1. **Task 2.1**: Use `Classical.choose_spec` to extract α from `d0_a_event_list`'s `S(β', α)` match, then apply D₀ seed definition to confirm `α ∈ A`
2. **Task 2.2**: Adapt consistent case BX chain, skip BX14, use `β.neg ∈ B` for direct implication
3. **BX Chain**: Use existing `self_accum_until_mcs`, `until_implies_F_mcs` tactics; skip `separation_until_mcs` for inconsistent case
4. **MCS Conjunction**: Use existing `list_conj_mem_mcs` or `conj_mcs` for P∧Q ∈ A proofs

---

## Sources
- Burgess 1982: "Axioms for Tense Logic Since and Until" Section 2.6 (Lemma 2.6)
- Project file: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (lines 1409, 1798, 1917-1929)
