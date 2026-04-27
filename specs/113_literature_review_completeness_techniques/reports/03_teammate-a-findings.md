# Teammate A: File-by-File Guard Audit — Open vs. Half-Closed Semantics

## Executive Summary

The project currently uses **half-closed guard** semantics for Until/Since:
- Until: `∃ s > t, ψ(s) ∧ ∀ r, t ≤ r → r < s → φ(r)` (guard is `[t, s)`)
- Since: `∃ s < t, ψ(s) ∧ ∀ r, s < r → r ≤ t → φ(r)` (guard is `(s, t]`)

The **correct open guard** semantics (paper, literature) is:
- Until: `∃ s > t, ψ(s) ∧ ∀ r, t < r → r < s → φ(r)` (guard is `(t, s)`)
- Since: `∃ s < t, ψ(s) ∧ ∀ r, s < r → r < t → φ(r)` (guard is `(s, t)`)

The change is `t ≤ r` → `t < r` for Until guard, and `r ≤ t` → `r < t` for Since guard.

**Four axioms become unsound under open guard and must be deleted:**
- `Axiom.until_guard` (φ U ψ → φ): uses `le_rfl` at `r = t`
- `Axiom.since_guard` (φ S ψ → φ): uses `le_rfl` at `r = t`
- `Axiom.until_elim` / BX9 (φ U ψ → φ ∨ ψ): uses `le_refl t` at `r = t`
- `Axiom.since_elim` / BX9' (φ S ψ → φ ∨ ψ): uses `le_refl t` at `r = t`

---

## 1. Truth.lean — Semantics Definition

**File**: `Theories/Bimodal/Semantics/Truth.lean`

**Current definitions (lines 127–130)**:
```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r ≤ t → truth_at M Omega τ r φ
```

**Required change**:
- Line 128: `t ≤ r` → `t < r`
- Line 130: `r ≤ t` → `r < t`

**Downstream effects**: The `time_shift_preserves_truth` proof for the `untl`/`snce` cases (lines 519–625) uses `≤` in the guard quantifier extensively. These proofs restructure with the matching inequality; since the shape of the inductive argument is the same (just exchanging `≤` for `<`), the proofs need line-by-line review but are structurally unchanged. In particular, `h_x_le_r'` becomes `h_x_lt_r'` (strict) throughout the Until/Since shift proofs.

**Classification**: (b) must rewrite — semantics change only.

---

## 2. Axioms.lean — Axiom Constructors

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean`

**Axioms to DELETE** (lines 264–274):
```lean
| until_guard (φ ψ : Formula) :
    Axiom ((Formula.untl φ ψ).imp φ)        -- line 267-268
| since_guard (φ ψ : Formula) :
    Axiom ((Formula.snce φ ψ).imp φ)        -- line 272-274
```

**Axioms to DELETE** (lines 207–214):
```lean
| until_elim (φ ψ : Formula) :
    Axiom ((Formula.untl φ ψ).imp (Formula.or φ ψ))   -- BX9, lines 207-208
| since_elim (φ ψ : Formula) :
    Axiom ((Formula.snce φ ψ).imp (Formula.or φ ψ))   -- BX9', lines 213-214
```

**Semantic argument for deletion**:
- `until_guard`: Under open guard `(t, s)`, the current point `t` is NOT covered by the guard `∀ r, t < r < s → φ(r)`. So `φ U ψ` at `t` does NOT imply `φ(t)`. Unsound.
- `since_guard`: Mirror argument. Unsound.
- `until_elim` (BX9): Under open guard, `φ U ψ` at `t` means the witness `s > t` with `ψ(s)` and `∀ r ∈ (t,s), φ(r)`. The point `t` is NOT in `(t,s)`. Neither `φ(t)` nor `ψ(t)` follows. Unsound.
- `since_elim` (BX9'): Mirror argument. Unsound.

**Classification**: (a) must delete — all four.

**The `frameClass`, `isBase`, etc. functions** (lines 298–334) require no change since they return constant `True`/`Base`. After deletion the match arms simply disappear.

---

## 3. Substitution.lean — Axiom Substitution Lemma

**File**: `Theories/Bimodal/ProofSystem/Substitution.lean`

**Must delete** the four match arms in `axiom_subst` (lines 328–339):
```lean
| refl_intro_until a b => ...   -- line 328-330 (NOTE: stale name not in current Axioms.lean)
| refl_intro_since a b => ...   -- line 331-333
| until_elim a b => ...          -- line 334-336
| since_elim a b => ...          -- line 337-339
```

**NOTE**: The Substitution.lean file contains references to `Axiom.temp_t_future`, `Axiom.temp_t_past`, `Axiom.refl_intro_until`, `Axiom.refl_intro_since` (lines 286–333) that do NOT appear in the current Axioms.lean. This is a pre-existing divergence: Substitution.lean is stale and references old axiom names. The `axiom_subst` match is already **broken** (won't compile). This must be fixed as part of the guard refactor regardless.

**Must also delete**:
```lean
| until_guard a b => ...   -- (if present — search shows not yet added)
| since_guard a b => ...   -- (if present)
```

**Classification**: (a) must delete the four arms for the removed axioms; (c) unaffected for the rest.

---

## 4. SoundnessLemmas.lean — Swap Validity and Local Validity

**File**: `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`

SoundnessLemmas.lean is the heaviest-hit file. There are **four distinct occurrences** of the master match for `axiom_swap_valid` and `axiom_locally_valid`.

### 4a. `axiom_swap_valid` (lines 485–805)

**Must delete** these four match arms (all use `le_refl`/`le_rfl` at the current point):

**`until_elim` arm (lines 714–720)**:
```lean
| until_elim φ ψ =>
    -- swap: (φ' S ψ') → (φ' ∨ ψ')
    ...
    exact absurd (h_guard t hst (le_refl t)) h_not_φ    -- le_refl t used here
```
Classification: (a) must delete.

**`since_elim` arm (lines 721–727)**:
```lean
| since_elim φ ψ =>
    -- swap: (φ' U ψ') → (φ' ∨ ψ')
    ...
    exact absurd (h_guard t (le_refl t) hts) h_not_φ    -- le_refl t used here
```
Classification: (a) must delete.

**`until_guard` arm (lines 792–797)**:
```lean
| until_guard φ ψ =>
    -- Swap of (φ U ψ) → φ is (φ' S ψ') → φ', which is since_guard
    ...
    exact h_guard t hst le_rfl    -- le_rfl (i.e., le_refl t) used here
```
Classification: (a) must delete.

**`since_guard` arm (lines 798–803)**:
```lean
| since_guard φ ψ =>
    -- Swap of (φ S ψ) → φ is (φ' U ψ') → φ', which is until_guard
    ...
    exact h_guard t le_rfl hts    -- le_rfl used here
```
Classification: (a) must delete.

### 4b. `axiom_locally_valid` match (lines 1082–1285)

**Must delete**:
- `until_elim` arm (line ~1250–1254): uses `le_refl t`
- `since_elim` arm (line ~1255–1259): uses `le_refl t`
- `until_guard` arm (lines 1274–1278): uses `le_rfl`
- `since_guard` arm (lines 1279–1283): uses `le_rfl`

Classification: (a) must delete all four.

### 4c. Second `axiom_swap_valid` (lines ~1640–1700, if a second copy exists)

The `grep` output reveals additional occurrences at lines 1659, 1666, 1689–1700. These appear to be a second master match (`axiom_swap_valid` called from `derivable_implies_swap_valid_general`). Same four arms must be deleted.

### 4d. Third/Fourth occurrences (~1877–1906)

Lines 1877, 1882, 1897, 1902 show yet more instances. Must delete same four arms.

**Summary for SoundnessLemmas.lean**: Delete the `until_elim`, `since_elim`, `until_guard`, `since_guard` match arms from ALL master match expressions (at least 4 copies of the master match). All use `le_refl`/`le_rfl` to hit the current point `t`, which is excluded under open guard.

**Additionally**: The `left_mono_until` and `left_mono_since` swap cases (lines 556–575) use `eq_or_lt_of_le htr` / `eq_or_lt_of_le hrt` to split the guard quantifier at the current point. Under open guard these arms still need the equality split (since the guard is now `t < r < s`), but the `h_eq` branch (subst `r = t`) becomes vacuous since `t` is no longer in the guard range. These arms need rewriting but the surrounding logic is correct.

Classification: (b) must rewrite for `left_mono_until`/`left_mono_since` swap cases.

---

## 5. Soundness.lean — Main Soundness Theorem

**File**: `Theories/Bimodal/Metalogic/Soundness.lean`

### 5a. `until_guard_valid` (lines 757–762):
```lean
theorem until_guard_valid (φ ψ : Formula) : ⊨ ((Formula.untl φ ψ).imp φ) := by
  ...
  exact h_guard t le_rfl hts    -- USES le_rfl: t ≤ t, which is false under open guard
```
Classification: (a) must delete (unsound).

### 5b. `since_guard_valid` (lines 767–772):
```lean
theorem since_guard_valid (φ ψ : Formula) : ⊨ ((Formula.snce φ ψ).imp φ) := by
  ...
  exact h_guard t hst le_rfl    -- USES le_rfl: t ≤ t, which is false under open guard
```
Classification: (a) must delete (unsound).

### 5c. `until_elim_valid` (lines 777–783):
```lean
exact absurd (h_guard t le_rfl hts) h_not_φ    -- le_rfl: t ≤ t, false under open guard
```
Classification: (a) must delete (unsound).

### 5d. `since_elim_valid` (lines 788–794):
```lean
exact absurd (h_guard t hst le_rfl) h_not_φ    -- le_rfl: t ≤ t, false under open guard
```
Classification: (a) must delete (unsound).

### 5e. Match arms in axiom validity combinators

At lines 868–869, 911–912, 955–956, 1053–1054, 1219–1220:
```
| until_guard φ ψ => exact until_guard_valid φ ψ
| since_guard φ ψ => exact since_guard_valid φ ψ
```
And corresponding `until_elim`/`since_elim` arms. All must be deleted.

### 5f. `left_mono_until_valid` (lines 500–514):
```lean
· subst h_eq; exact h_now (h_guard t le_rfl hrs)    -- line 513
```
This uses `le_rfl` to retrieve `φ` at `r = t` from the guard. Under open guard `t` is no longer in the guard range. The proof must be restructured: the `h_eq` branch (where `r = t`) is impossible since the guard now only covers `t < r < s`. The `h_now` component of `left_mono_until` is still needed (it handles the current point separately), but the guard retrieval at `r = t` disappears.

Classification: (b) must rewrite — `left_mono_until_valid` and `left_mono_since_valid`.

**Note**: The semantics comment at lines 490–496 describes the half-open guard `[t,s)` and `(s,t]`. This documentation must also be updated.

---

## 6. RRelation.lean — Canonical Completeness

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`

### 6a. `until_guard_in_mcs` (lines 86–93):
```lean
theorem until_guard_in_mcs {A : Set Formula} (h_mcs : SetMaximalConsistent A)
    {γ δ : Formula} (h_until : Formula.untl γ δ ∈ A) : γ ∈ A := by
  have h_guard : DerivationTree [] ((Formula.untl γ δ).imp γ) :=
    DerivationTree.axiom [] _ (Axiom.until_guard γ δ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_guard) h_until
```

With `until_guard` deleted, `γ ∈ A` is **no longer derivable** from `γ U δ ∈ A` alone. Under open guard, the current-point `γ` is not guaranteed.

**Call sites**: Lines 673 (PointInsertion.lean) and 1193 (RRelation.lean) — traced below.

Classification: (a) must delete — both `until_guard_in_mcs` and `since_guard_in_mcs` (lines 99–106).

### 6b. `rRelationSince_self_mcs` (line ~494):
Uses `since_disjunction_in_mcs` which calls `Axiom.since_elim`. After deletion of `since_elim`, `rRelationSince_self_mcs` must be rewritten. The proof currently does:
```lean
exact Or.inl (SetMaximalConsistent.implication_property h_mcs
    (until_disjunction_in_mcs h_mcs h_since) h_neg_γ)
```
Without `since_elim`, `γ S δ ∈ A` does not give `γ ∨ δ ∈ A`. The self-reflexivity of `rRelationSince` requires a different argument.

Classification: (b) must rewrite.

### 6c. `untl_absorb_nested` / `snce_absorb_nested` (lines 1232–1269):
Both use `Axiom.until_guard γ δ` and `Axiom.since_guard γ δ` directly. These derivations build:
```lean
have h_guard : DerivationTree [] ((Formula.untl γ δ).imp γ) :=
    DerivationTree.axiom [] _ (Axiom.until_guard γ δ)
```
This key step is invalid under open guard. The entire `untl_absorb_nested` proof breaks.

**What replaces it?** Under open guard semantics, the nested absorption `U(γ, U(γ,δ)) → U(γ,δ)` needs a different proof. One approach: use BX6 (absorb_until) with modified argument. But the derivation via `until_guard` is fundamentally unavailable. This is a significant obstacle for the RRelation machinery.

Classification: (a) must delete/rewrite — both `untl_absorb_nested` and `snce_absorb_nested`.

### 6d. Burgess R3 maximality proof at lines 1184–1211:
The proof `burgessR3Maximal_exists_from_seed` calls `until_guard_in_mcs` at line 1193 to show `η ∈ A`. Under open guard this step fails: `burgessR(A, η, C)` gives `untl(η, γ) ∈ A` for theorems `γ`, but `until_guard_in_mcs` is deleted. A replacement argument is needed.

Classification: (b) must rewrite.

---

## 7. PointInsertion.lean — Point Insertion Machinery

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

### 7a. `BurgessR3Maximal_maximality_combined` (line 673):
```lean
have h_bot : Formula.bot ∈ A := until_guard_in_mcs h_mcs_A h_utl_bot
```
This derives `bot ∈ A` from `untl(bot, top) ∈ A` via `until_guard_in_mcs`. Under open guard, `until_guard_in_mcs` is deleted. The contradiction argument must be reconstructed differently.

**Alternative**: Under open guard, `untl(bot, top)` in an MCS still gives a contradiction because: by BX5 (self_accum_until), `untl(bot ∧ untl(bot, top), top) ∈ A`. By BX10 (until_F), `F(top) ∈ A`. But this does not immediately give `bot ∈ A`. The argument that `until_guard_in_mcs` was used for (deriving `bot`) needs a new route.

Actually: under open guard, `untl(bot, top)` at `t` means `∃ s > t, top(s) ∧ ∀ r ∈ (t,s), bot(r)`. On a dense linear order, there exists such `r` with `t < r < s`, and `bot(r) = False`, contradiction. So on dense orders this is still satisfiable only vacuously. But in the proof system context (inside an MCS), the contradiction argument must use different axioms.

Classification: (b) must rewrite — the `⊥ U ⊥` contradiction argument.

### 7b. `lemma_2_7_guard` (lines 271–279):
```lean
theorem lemma_2_7_guard {A : Set Formula} (h_mcs : SetMaximalConsistent A)
    (ξ η : Formula) (h_until : Formula.untl ξ η ∈ A) (h_η_not : η ∉ A) : ξ ∈ A := by
  rcases until_elim_mcs h_mcs ξ η h_until with h | h
  · exact h
  · exact absurd h h_η_not
```
Calls `until_elim_mcs` (line 167–178) which uses `Axiom.until_elim`. After deletion of `until_elim`, `lemma_2_7_guard` breaks. Under open guard, `ξ U η ∈ A` with `η ∉ A` does NOT imply `ξ ∈ A`.

Classification: (a) must delete — `lemma_2_7_guard` is **false** under open guard.

### 7c. `until_elim_mcs` (lines 167–178, PointInsertion.lean):
```lean
theorem until_elim_mcs (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) : γ ∈ A ∨ β ∈ A := by
  have h_ax : DerivationTree [] ((Formula.untl γ β).imp (Formula.or γ β)) :=
    DerivationTree.axiom [] _ (Axiom.until_elim γ β)
  ...
```
Uses `Axiom.until_elim`. Must be deleted when `until_elim` is removed.

Classification: (a) must delete.

---

## 8. ChronicleTypes.lean — Chronicle Invariants

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`

**No direct dependency on `until_guard` or `since_guard` axioms** in the type definitions themselves (lines 1–350). The `rRelation`, `rRelationSince`, `r3Relation`, `burgessR`, `BurgessR3Maximal`, `Chronicle.c0`–`c5'` are all propositional definitions.

**However**: `dcs_modus_ponens` (line 88–98), `dcs_conj_closed` (line 100–106) are unaffected.

**The `rRelation` definition** (line 134–137) depends on `δ ∈ B ∨ (γ ∈ B ∧ Formula.untl γ δ ∈ B)`. Under open guard, this definition is still coherent and does not need to change. The question is whether the proofs about `rRelation` remain valid after axiom deletion — that is handled in RRelation.lean.

**Classification**: (c) unaffected at the definition level; proofs using guard axioms are in RRelation.lean.

---

## 9. Frame.lean — BX Canonical Frame

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`

### 9a. `bx_le_refl` (line 202–205):
```lean
theorem bx_le_refl (w : BXPoint) : bx_le w w := by
  sorry
```
Already marked `sorry`. The proof requires `G(φ) → φ` (temporal T axiom), which is not sound under irreflexive semantics. This sorry remains.

### 9b. `until_elim_mcs` (Construction.lean line 114–126):
```lean
theorem until_elim_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.untl φ ψ ∈ w.formulas) : φ ∈ w.formulas ∨ ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.until_elim φ ψ)
  ...
```
Uses `Axiom.until_elim`. Must be deleted when `until_elim` is removed.

**Call site in Frame.lean**: The `until_elim_mcs` at Construction.lean line 114 is used in subsequent quasimodel construction. If `until_elim` is deleted, `until_elim_mcs` is deleted, and all downstream uses must be traced.

Classification: (a) must delete in Frame.lean/Construction.lean.

### 9c. The `bx_forward_witness` and `bx_backward_witness` (lines 223–244): Unaffected.

---

## 10. Construction.lean — Quasimodel Construction

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`

### 10a. `until_elim_mcs` (lines 114–126):
```lean
theorem until_elim_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.untl φ ψ ∈ w.formulas) : φ ∈ w.formulas ∨ ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.until_elim φ ψ)
```
Classification: (a) must delete.

**What replaces it?** Under open guard, `φ U ψ ∈ A` only gives `F(ψ) ∈ A` (via BX10) and `(φ ∧ (φ U ψ)) U ψ ∈ A` (via BX5). It does NOT give `φ ∈ A` or `ψ ∈ A` at the current point. The defect-discharge machinery (DefectChain.lean) correctly avoids using `until_elim_mcs` directly — it only uses `Axiom.until_elim` in `defect_step_phi` and `since_defect_step_phi` to extract `φ` when `ψ ∉ A`.

---

## 11. DefectChain.lean — Defect Discharge

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean`

### 11a. `defect_step_phi` (lines 61–73):
```lean
theorem defect_step_phi {w : BXPoint} {φ ψ : Formula}
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) : φ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.until_elim φ ψ)
  have h_or := SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_until
  cases SetMaximalConsistent.negation_complete w.is_mcs φ with
  | inl h => exact h
  | inr h_neg_phi =>
    have h_psi := SetMaximalConsistent.implication_property w.is_mcs h_or h_neg_phi
    exact absurd h_psi h_not_psi
```
Uses `Axiom.until_elim` to derive `φ ∈ w` from `φ U ψ ∈ w ∧ ψ ∉ w`. Under open guard, this is **false**: even if `ψ ∉ w`, the open guard does not guarantee `φ ∈ w`.

Classification: (a) must delete — `defect_step_phi` is false under open guard.

### 11b. `since_defect_step_phi` (lines 107–119):
Same analysis as above but for Since. Classification: (a) must delete.

**What replaces them?** The defect-discharge step cannot extract `φ` from `φ U ψ` unless the point is a guard point (i.e., strictly between `t` and the witness `s`). At the base point `t` itself, `φ(t)` is not asserted under open guard. The entire defect-discharge architecture needs rethinking.

---

## 12. TemporalDerived.lean — Derived Theorems

**File**: `Theories/Bimodal/Theorems/TemporalDerived.lean`

### 12a. Theorems depending on deleted axioms:

**`psi_imp_until` (lines 232–237)**: Already `sorry`'d with comment "under irreflexive semantics, ψ → (φ U ψ) is NOT valid." This sorry predates the open guard change and is a separate issue (BX8 was already removed). Remains sorry.

**`psi_imp_since` (lines 239–244)**: Same, already `sorry`'d.

**`bot_until_bot_absurd` (lines 173–179)**:
```lean
def bot_until_bot_absurd : ⊢ (Formula.untl Formula.bot Formula.bot).imp Formula.bot :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.until_elim Formula.bot Formula.bot))
    (mp (identity Formula.bot) theorem_app1)
```
Uses `Axiom.until_elim`. Under open guard, `⊥ U ⊥` is NOT necessarily absurd in the proof system (no axiom derives `⊥` from it). **Must be deleted or sorry'd**.

**`bot_since_bot_absurd` (lines 183–187)**: Same. Must be deleted or sorry'd.

**`bot_until_id` / `bot_until_elim` (lines 320–324)**:
```lean
noncomputable def bot_until_id (a : Formula) :
    ⊢ (Formula.untl Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.until_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))
```
Uses `Axiom.until_elim`. Must be deleted or sorry'd.

**`bot_since_id` (lines 327–331)**: Same.

**`until_imp_or` (lines 252–254)**:
```lean
def until_imp_or (φ ψ : Formula) : ⊢ (Formula.untl φ ψ).imp (Formula.or φ ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_elim φ ψ)
```
Direct axiom wrapper. Must be deleted.

**`since_imp_or` (lines 259–261)**: Same.

**`or_until_imp` (lines 343–...)**:
```lean
noncomputable def or_until_imp (φ ψ : Formula) :
    ⊢ (Formula.or ψ (Formula.and φ (Formula.untl φ ψ))).imp (Formula.untl φ ψ)
```
This uses `psi_imp_until` (already sorry'd). Unaffected by guard change per se, but relies on removed infrastructure.

### 12b. Unaffected derived theorems:

- `G_bot_absurd`, `H_bot_absurd`: Already sorry'd (need seriality argument).
- `G_distribution`, `G_transitivity`, `connect_future_thm`, `connect_past_thm`: Unaffected (BX1, BX4, temp_4).
- `density_derivable`, `past_density_derivable`: Already sorry'd.
- `until_implies_some_future`, `since_implies_some_past`: Use BX10/BX10' — unaffected.
- `G_implies_topUntil`: Already sorry'd.
- `until_imp_F`, `since_imp_P`: Use BX10/BX10' — unaffected.

**Classification summary for TemporalDerived.lean**:
- Delete: `bot_until_bot_absurd`, `bot_since_bot_absurd`, `bot_until_id`, `bot_since_id`, `until_imp_or`, `since_imp_or`
- Keep (already sorry'd or BX10-based): everything else

---

## Summary Table

| File | Action Required | Items |
|------|----------------|-------|
| Truth.lean:128,130 | (b) rewrite | Change `t ≤ r` → `t < r` (Until) and `r ≤ t` → `r < t` (Since) |
| Axioms.lean | (a) delete | `until_guard`, `since_guard`, `until_elim`, `since_elim` (4 constructors) |
| Substitution.lean | (a) delete | 4 match arms + fix stale refs to `temp_t_future`, `refl_intro_until`, etc. |
| SoundnessLemmas.lean | (a) delete | `until_elim`, `since_elim`, `until_guard`, `since_guard` arms in all 4 master matches |
| SoundnessLemmas.lean | (b) rewrite | `left_mono_until`/`left_mono_since` swap cases (remove `le_rfl` branch) |
| Soundness.lean | (a) delete | `until_guard_valid`, `since_guard_valid`, `until_elim_valid`, `since_elim_valid` + 10 match arm refs |
| Soundness.lean | (b) rewrite | `left_mono_until_valid`, `left_mono_since_valid` (remove `le_rfl` branch at `r = t`) |
| RRelation.lean | (a) delete | `until_guard_in_mcs`, `since_guard_in_mcs`, `untl_absorb_nested`, `snce_absorb_nested` |
| RRelation.lean | (b) rewrite | `rRelationSince_self_mcs`, `burgessR3Maximal_exists_from_seed` |
| PointInsertion.lean | (a) delete | `until_elim_mcs`, `lemma_2_7_guard` |
| PointInsertion.lean | (b) rewrite | `BurgessR3Maximal_maximality_combined` line 673 contradiction |
| ChronicleTypes.lean | (c) unaffected | Definitions only; no guard axiom usage |
| Frame.lean | (c) unaffected | `bx_le_refl` already sorry'd; no new guard usage |
| Construction.lean | (a) delete | `until_elim_mcs` (quasimodel version) |
| DefectChain.lean | (a) delete | `defect_step_phi`, `since_defect_step_phi` (false under open guard) |
| TemporalDerived.lean | (a) delete | `bot_until_bot_absurd`, `bot_since_bot_absurd`, `bot_until_id`, `bot_since_id`, `until_imp_or`, `since_imp_or` |

---

## Key Structural Insight

The most serious impact of switching to open guard is **not just axiom deletion** but the loss of the guard extraction principle: under half-closed guard, `φ U ψ` at `t` gives `φ(t)` for free. Under open guard, the current point is excluded. This breaks:

1. **Defect discharge**: `defect_step_phi` (DefectChain.lean) cannot extract `φ` from `φ U ψ` when `ψ` is absent.
2. **Absorption proofs**: `untl_absorb_nested` (RRelation.lean) used `until_guard` as a key lemma.
3. **R3 Maximal seed**: `burgessR3Maximal_exists_from_seed` depended on `until_guard_in_mcs` to show the seed element is in `A`.
4. **BX9 elimination**: `until_elim` / `since_elim` are deleted, breaking several canonical model helper theorems.

The completeness construction machinery (Burgess chronicle construction, PointInsertion, RRelation) must be partially rebuilt for open guard semantics, likely using BX5 (self_accum_until) + BX10 (until_F) + BX4 (connect_future) as replacements for the guard extraction pattern.
