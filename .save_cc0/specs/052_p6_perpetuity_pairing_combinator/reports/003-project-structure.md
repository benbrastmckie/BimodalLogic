# Project Structure Research Report

## Executive Summary

This report analyzes the Logos project structure to identify exact implementation locations for P5/P6 derivations and pairing combinator work. The analysis covers current axiom systems, derivation infrastructure, perpetuity theorem organization, and testing architecture. Key findings: S5 axiom addition requires updates to 3 core files (Axioms.lean, Soundness.lean, AxiomsTest.lean), P5 derivation modifies 2 files (Perpetuity.lean, PerpetuityTest.lean), and P6 derivation requires new duality lemmas in Perpetuity.lean.

---

## Findings

### 1. Current Axiom System Architecture

**Location**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean`

**Current Status** (12 axioms total):

```lean
inductive Axiom : Formula → Prop where
  -- Propositional (3 axioms)
  | prop_k (φ ψ χ : Formula)          -- K: (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
  | prop_s (φ ψ : Formula)            -- S: φ → (ψ → φ)
  | double_negation (φ : Formula)      -- DNE: ¬¬φ → φ

  -- S5 Modal (4 axioms - MISSING AXIOM 5)
  | modal_t (φ : Formula)              -- T: □φ → φ
  | modal_4 (φ : Formula)              -- 4: □φ → □□φ
  | modal_b (φ : Formula)              -- B: φ → □◇φ
  | modal_k_dist (φ ψ : Formula)       -- K: □(φ → ψ) → (□φ → □ψ)

  -- Temporal (3 axioms)
  | temp_4 (φ : Formula)               -- T4: Fφ → FFφ
  | temp_a (φ : Formula)               -- TA: φ → F(sometime_past φ)
  | temp_l (φ : Formula)               -- TL: △φ → F(Pφ)

  -- Modal-Temporal Interaction (2 axioms)
  | modal_future (φ : Formula)         -- MF: □φ → □Fφ
  | temp_future (φ : Formula)          -- TF: □φ → F□φ
```

**Gap Analysis**:

The S5 modal axioms include T, 4, B, K (4 axioms) but are **missing Axiom 5**:
- **Axiom 5**: `◇φ → □◇φ` (possibility is necessarily possible)

This is the **symmetric** axiom in S5 modal logic. The current system has:
- **Reflexivity** (T): □φ → φ
- **Transitivity** (4): □φ → □□φ
- **Symmetry** (B): φ → □◇φ (partial - only for truths, not possibilities)

**Missing**: Full symmetry for **possibilities**: `◇φ → □◇φ`

**Required Change**:

Add to Axioms.lean after `modal_b`:
```lean
/--
Modal 5 axiom: `◇φ → □◇φ` (S5 characteristic - possibility is necessarily possible).

If something is possible, then it is necessarily possible. This is the S5
characteristic axiom that distinguishes S5 from S4 modal logic.

Semantically: the accessibility relation is symmetric. If world w' is accessible
from w (making φ possible at w), then w is accessible from w', so the existence
of w' (where φ holds) is known from all accessible worlds, making ◇φ necessary.

This axiom is required for deriving the persistence lemma (◇φ → △◇φ) and
consequently perpetuity principle P5 (◇▽φ → △◇φ).

Semantic justification: Valid in task semantics due to S5 modal structure
(Theorem 2.9, Corollary 2.11 in JPL paper).
-/
| modal_5 (φ : Formula) :
    Axiom (Formula.diamond φ |>.imp (Formula.box (Formula.diamond φ)))
```

**Documentation Updates**:
- Line 13 comment: Change "12 axiom schemata" to "13 axiom schemata"
- Line 26 comment: Add `modal_5` to S5 modal axioms list
- Lines 22-26: Update S5 section to list all 5 axioms (T, 4, B, K, 5)

**Impact**:
- Axioms.lean: ~10 lines added (axiom + docstring)
- Documentation comments: ~5 lines updated
- Total LOC change: +15 lines

### 2. Soundness Proof Architecture

**Location**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/Soundness.lean`

**Current Status** (from CLAUDE.md Section 6):
- **12/12 axioms proven sound**: MT, M4, MB, T4, TA, TL, MF, TF, modal_k_dist, double_negation, prop_k, prop_s
- **8/8 inference rules proven sound**: axiom, assumption, modus_ponens, weakening, modal_k, temporal_k, temporal_duality, necessitation

**Required Addition**:

Add soundness proof for modal_5 axiom. Pattern to follow (from existing axioms):

```lean
/--
Soundness of Modal 5 axiom: `◇φ → □◇φ` is valid.

Semantic proof:
- Assume M,τ,t ⊨ ◇φ (φ is possible at world τ, time t)
- By definition: ∃ρ ∈ histories(M). M,ρ,t ⊨ φ
- Goal: Show M,τ,t ⊨ □◇φ, i.e., ∀ρ' ∈ histories(M). M,ρ',t ⊨ ◇φ
- For any ρ', we need ∃ρ'' ∈ histories(M). M,ρ'',t ⊨ φ
- We already have such a ρ (from assumption), so take ρ'' = ρ
- Thus M,ρ',t ⊨ ◇φ holds for all ρ'
- Therefore M,τ,t ⊨ □◇φ

Key insight: The quantification ∀ρ' in □◇φ doesn't affect the existential ∃ρ''
in ◇φ. The witness ρ (where φ holds) is fixed and works for all ρ'.
-/
theorem modal_5_valid (M : TaskModel) (τ : WorldHistory M.frame) (t : M.frame.Time) (φ : Formula) :
    truth_at M τ t φ.diamond → truth_at M τ t (φ.diamond.box) := by
  intro h_poss
  -- Unfold diamond: φ.diamond = φ.neg.box.neg
  -- h_poss : M,τ,t ⊨ ¬□¬φ
  -- Goal: M,τ,t ⊨ □◇φ = □(¬□¬φ)

  sorry  -- 15-25 lines of semantic reasoning
```

**Integration Point**:

Update main `soundness` theorem to include modal_5 case:
```lean
theorem soundness (Γ : Context) (φ : Formula) (h : Γ ⊢ φ) : Γ ⊨ φ := by
  induction h with
  | axiom Γ φ h_ax =>
      cases h_ax with
      | prop_k φ ψ χ => exact prop_k_valid M τ t φ ψ χ
      | prop_s φ ψ => exact prop_s_valid M τ t φ ψ
      | modal_t φ => exact modal_t_valid M τ t φ
      | modal_4 φ => exact modal_4_valid M τ t φ
      | modal_b φ => exact modal_b_valid M τ t φ
      | modal_5 φ => exact modal_5_valid M τ t φ  -- NEW CASE
      | ...
```

**Effort Estimate**:
- Validity lemma: 15-25 lines (2-3 hours)
- Soundness theorem update: 1 line (10 minutes)
- Documentation: 10 lines (30 minutes)
- **Total: 3-4 hours**

### 3. Perpetuity Theorem Organization

**Location**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`

**File Structure** (1036 lines total):

```
Lines 1-60:    Module header and documentation
Lines 62-175:  Helper Lemmas: Propositional Reasoning
               - imp_trans (line 85)
               - mp (line 98)
               - identity (line 109)
               - b_combinator (line 128)
Lines 169-174: Pairing axiom (AXIOMATIZED)
Lines 176-238: Helper Lemmas: Conjunction Introduction
               - combine_imp_conj (line 216)
               - combine_imp_conj_3 (line 233)
Lines 240-283: Helper Lemmas: Temporal Components
               - box_to_future (line 255)
               - box_to_past (line 271)
               - box_to_present (line 281)
Lines 285-309: P1: Necessary Implies Always (PROVEN)
Lines 311-476: P2: Sometimes Implies Possible (PROVEN)
               - contraposition (line 341)
               - perpetuity_2 (line 463)
Lines 478-610: P3: Necessity of Perpetuity (PROVEN)
               - box_to_box_past (line 490)
               - box_conj_intro (line 512)
               - box_conj_intro_imp (line 546)
               - box_conj_intro_imp_3 (line 578)
               - perpetuity_3 (line 598)
Lines 612-717: P4: Possibility of Occurrence (PROVEN)
               - box_dne (line 630)
               - perpetuity_4 (line 671)
Lines 719-859: P5: Persistent Possibility (AXIOMATIZED - BLOCKED)
               - mb_diamond (line 732)
               - box_diamond_to_future_box_diamond (line 740)
               - box_diamond_to_past_box_diamond (line 749)
               - persistence (line 799) ← SORRY AT LINE 827
               - perpetuity_5 (line 859) ← AXIOM
Lines 861-926: P6: Occurrent Necessity (AXIOMATIZED - BLOCKED)
               - perpetuity_6 (line 926) ← AXIOM
Lines 928-1012: Summary documentation
Lines 1014-1036: Example usages with triangle notation
```

**Key Implementation Locations**:

**P5 Implementation** (persistence lemma fix):

```lean
-- Current (line 799-828):
theorem persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always := by
  -- ... existing code ...

  -- BLOCKING: Need ◇φ → □◇φ to connect the pieces
  -- This is NOT derivable from current axioms
  sorry  -- LINE 827

-- After modal_5 addition:
theorem persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always := by
  -- Step 1: Modal 5 gives us ◇φ → □◇φ
  have modal5 : ⊢ φ.diamond.imp φ.diamond.box :=
    Derivable.axiom [] _ (Axiom.modal_5 φ)

  -- Step 2: From TF and TD, we have □◇φ → H□◇φ ∧ □◇φ ∧ F□◇φ
  have tf : ⊢ φ.diamond.box.imp φ.diamond.box.all_future :=
    box_diamond_to_future_box_diamond φ
  have td : ⊢ φ.diamond.box.imp φ.diamond.box.all_past :=
    box_diamond_to_past_box_diamond φ
  have id : ⊢ φ.diamond.box.imp φ.diamond.box :=
    identity φ.diamond.box
  have combined : ⊢ φ.diamond.box.imp
      (φ.diamond.box.all_past.and (φ.diamond.box.and φ.diamond.box.all_future)) :=
    combine_imp_conj_3 td id tf

  -- Step 3: Apply MT to unbox: □◇φ → ◇φ (for each temporal component)
  have mt_past : ⊢ φ.diamond.box.all_past.imp φ.diamond :=
    sorry  -- Apply MT via temporal operator (5-10 lines)
  have mt_pres : ⊢ φ.diamond.box.imp φ.diamond :=
    Derivable.axiom [] _ (Axiom.modal_t φ.diamond)
  have mt_fut : ⊢ φ.diamond.box.all_future.imp φ.diamond :=
    sorry  -- Apply MT via temporal operator (5-10 lines)

  -- Step 4: Combine to get □◇φ → H◇φ ∧ ◇φ ∧ G◇φ = △◇φ
  sorry  -- Chain together (10-15 lines)

  -- Step 5: Compose modal5 with combined result
  exact imp_trans modal5 (result_from_step4)
```

**Estimated Changes**:
- Remove sorry at line 827
- Add ~30-40 lines of proof steps
- Net: +30-40 lines

**P5 Derivation** (replace axiom):

```lean
-- Current (line 859):
axiom perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always

-- After persistence proof:
/--
P5: `◇▽φ → △◇φ` (persistent possibility)

Derivation: Compose P4 with persistence lemma.
- P4: `◇▽φ → ◇φ` (perpetuity_4)
- Persistence: `◇φ → △◇φ` (persistence)
- Transitivity: `◇▽φ → △◇φ`
-/
theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  exact imp_trans (perpetuity_4 φ) (persistence φ)
```

**Estimated Changes**:
- Replace `axiom` with `theorem` (1 line)
- Change proof from empty to 1-line composition (net: +1 line)

**P6 Derivation** (requires duality lemmas):

**New Lemmas to Add** (before perpetuity_6):

```lean
/--
Modal duality lemma (forward): `◇(¬φ) → ¬□φ`.

From "not necessarily not-φ" derives "not necessarily φ".
-/
theorem modal_duality_neg (φ : Formula) :
  ⊢ φ.neg.diamond.imp φ.box.neg := by
  sorry  -- 15-20 lines using DNE + contraposition

/--
Modal duality lemma (backward): `¬□φ → ◇(¬φ)`.

From "not necessarily φ" derives "not necessarily not-φ".
-/
theorem modal_duality_neg_rev (φ : Formula) :
  ⊢ φ.box.neg.imp φ.neg.diamond := by
  sorry  -- 15-20 lines using DNI + contraposition

/--
Temporal duality lemma (forward): `▽(¬φ) → ¬△φ`.

From "sometimes not-φ" derives "not always φ".
-/
theorem temporal_duality_neg (φ : Formula) :
  ⊢ φ.neg.sometimes.imp φ.always.neg := by
  sorry  -- 20-30 lines using temporal K + DNE

/--
Temporal duality lemma (backward): `¬△φ → ▽(¬φ)`.

From "not always φ" derives "sometimes not-φ".
-/
theorem temporal_duality_neg_rev (φ : Formula) :
  ⊢ φ.always.neg.imp φ.neg.sometimes := by
  sorry  -- 20-30 lines using temporal K + DNI
```

**Estimated Additions**: +100-140 lines (4 lemmas × 25-35 lines each)

**P6 Theorem Replacement**:

```lean
-- Current (line 926):
axiom perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box

-- After duality lemmas:
/--
P6: `▽□φ → □△φ` (occurrent necessity is perpetual)

Derivation via P5 applied to ¬φ with operator duality:
1. P5 for ¬φ: `◇▽(¬φ) → △◇(¬φ)`
2. Apply modal duality: `◇(¬φ) ↔ ¬□φ`
3. Apply temporal duality: `▽(¬φ) ↔ ¬△φ`
4. Substitute into P5(¬φ) and simplify
5. Result: `▽□φ → □△φ`
-/
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  sorry  -- 30-40 lines threading through duality substitutions
```

**Estimated Changes**:
- Replace `axiom` with `theorem` (1 line)
- Add proof body (~35 lines)
- Net: +35 lines

**Total Perpetuity.lean Changes**:
- Persistence proof: +30-40 lines
- P5 derivation: +1 line
- Duality lemmas: +100-140 lines
- P6 derivation: +35 lines
- **Net: +166-216 lines** (1036 → 1202-1252 lines)

### 4. Derivation Infrastructure

**Location**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Derivation.lean`

**Current Inference Rules** (8 rules):

```lean
inductive Derivable : Context → Formula → Prop where
  | axiom          -- Line 72
  | assumption     -- Line 79
  | modus_ponens   -- Line 86
  | modal_k        -- Line 100
  | temporal_k     -- Line 113
  | necessitation  -- Line 142
  | temporal_duality  -- Line 152
  | weakening      -- Line 162
```

**Required Changes**: None

The modal_5 axiom integrates seamlessly into existing infrastructure:
- Uses `Derivable.axiom` rule (line 72)
- No new inference rules needed
- Existing helper theorems (`imp_trans`, `identity`, etc.) are sufficient

**Existing Helpers Available** (lines 287-338):
- `identity` (line 288): `⊢ φ → φ`
- `imp_trans` (line 317): Transitivity of implication
- `deduction_theorem` (line 423): Propositional fragment (with sorry cases for modal/temporal)

**Note**: Deduction theorem has sorry at line 469 (weakening case) and lines 471-492 (modal/temporal cases). These don't block perpetuity work, which uses direct derivations.

### 5. Testing Architecture

**Current Test Files**:

1. **AxiomsTest.lean**: Unit tests for axiom instantiation
2. **DerivationTest.lean**: Unit tests for inference rules
3. **PerpetuityTest.lean**: Unit tests for perpetuity theorems
4. **SoundnessTest.lean**: Integration tests for soundness proofs

**Required Test Additions**:

**AxiomsTest.lean** (`LogosTest/Core/ProofSystem/AxiomsTest.lean`):

Add after modal_b tests:
```lean
/-- Test: Modal 5 axiom instantiation -/
def test_modal_5_axiom : TestCase :=
  let p := Formula.atom "p"
  let axiom := (p.diamond.imp (p.diamond.box))
  {
    name := "modal_5_axiom_diamond_p_implies_box_diamond_p",
    assertion := Axiom.modal_5 p,
    expected := true
  }
```

**Estimated Addition**: +10-15 lines

**PerpetuityTest.lean** (`LogosTest/Core/Theorems/PerpetuityTest.lean`):

```lean
/-- Test: Persistence lemma with concrete formula -/
def test_persistence_atom : TestCase :=
  let p := Formula.atom "p"
  {
    name := "persistence_diamond_p_implies_always_diamond_p",
    assertion := ⊢ p.diamond.imp p.diamond.always,
    expected := true
  }

/-- Test: P5 with concrete formula -/
def test_perpetuity_5_atom : TestCase :=
  let p := Formula.atom "p"
  {
    name := "p5_diamond_sometimes_p_implies_always_diamond_p",
    assertion := ⊢ p.sometimes.diamond.imp p.diamond.always,
    expected := true
  }

/-- Test: Modal duality lemmas -/
def test_modal_duality_neg : TestCase :=
  let p := Formula.atom "p"
  {
    name := "modal_duality_diamond_neg_p_implies_neg_box_p",
    assertion := ⊢ p.neg.diamond.imp p.box.neg,
    expected := true
  }

def test_modal_duality_neg_rev : TestCase :=
  let p := Formula.atom "p"
  {
    name := "modal_duality_neg_box_p_implies_diamond_neg_p",
    assertion := ⊢ p.box.neg.imp p.neg.diamond,
    expected := true
  }

/-- Test: Temporal duality lemmas -/
def test_temporal_duality_neg : TestCase :=
  let p := Formula.atom "p"
  {
    name := "temporal_duality_sometimes_neg_p_implies_neg_always_p",
    assertion := ⊢ p.neg.sometimes.imp p.always.neg,
    expected := true
  }

def test_temporal_duality_neg_rev : TestCase :=
  let p := Formula.atom "p"
  {
    name := "temporal_duality_neg_always_p_implies_sometimes_neg_p",
    assertion := ⊢ p.always.neg.imp p.neg.sometimes,
    expected := true
  }

/-- Test: P6 with concrete formula -/
def test_perpetuity_6_atom : TestCase :=
  let p := Formula.atom "p"
  {
    name := "p6_sometimes_box_p_implies_box_always_p",
    assertion := ⊢ p.box.sometimes.imp p.always.box,
    expected := true
  }
```

**Estimated Addition**: +70-90 lines

**SoundnessTest.lean** (`LogosTest/Core/Metalogic/SoundnessTest.lean`):

```lean
/-- Test: Modal 5 axiom is valid in concrete model -/
def test_modal_5_valid : TestCase :=
  -- Create concrete task model
  let M := ...
  let τ := ...
  let t := ...
  let p := Formula.atom "p"
  {
    name := "modal_5_valid_diamond_p_implies_box_diamond_p",
    assertion := (truth_at M τ t p.diamond) → (truth_at M τ t (p.diamond.box)),
    expected := true
  }

/-- Test: P5 is valid in concrete model -/
def test_perpetuity_5_valid : TestCase :=
  -- Similar structure to modal_5
  sorry

/-- Test: P6 is valid in concrete model -/
def test_perpetuity_6_valid : TestCase :=
  -- Similar structure to modal_5
  sorry
```

**Estimated Addition**: +40-60 lines

**Total Testing Changes**: +120-165 lines across 3 test files

### 6. Documentation Updates

**Files Requiring Updates**:

1. **CLAUDE.md**:
   - Section 1 (Project Overview): Update axiom count 12 → 13
   - Section 6 (ProofSystem Package): Update axiom list to include modal_5
   - Section 6 (Theorems Package): Update P5/P6 status from "Axiomatized" to "Fully proven"
   - Section 6 (Theorems Package): Update sorry count from 1 → 0 when persistence complete

2. **TODO.md**:
   - Task 18: Update Phase 3 status from "BLOCKED" to "COMPLETE"
   - Task 18: Update Phase 4 status from "BLOCKED" to "COMPLETE" (if P6 derived)
   - Task 19: Change status from "BLOCKED" to "COMPLETE"
   - Task 20: Change status from "BLOCKED" to "COMPLETE" (if P6 derived)
   - Task 20: Update blocking dependencies to show completion chain

3. **IMPLEMENTATION_STATUS.md**:
   - Theorems/Perpetuity.lean: Update sorry count 1 → 0
   - Theorems/Perpetuity.lean: Update completion percentage
   - Metalogic/Soundness.lean: Update axiom soundness count 12/12 → 13/13

4. **SORRY_REGISTRY.md**:
   - Remove persistence lemma entry (line 827 sorry)
   - Update summary counts

**Estimated Documentation Changes**: ~30-50 lines across 4 files

### 7. Pairing Combinator Analysis

**Current Status**: Axiomatized at Perpetuity.lean:169-174

```lean
/--
Pairing combinator: `⊢ A → B → A ∧ B`.
...
**Future Work**: Derive fully from S and K axioms using combinator calculus.
-/
axiom pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))
```

**Derivation Strategy** (if pursued):

Location: Add after `b_combinator` theorem (line 139)

```lean
/--
I combinator (identity): Derived as S K K.
-/
theorem i_combinator (φ : Formula) : ⊢ φ.imp φ := identity φ

/--
Application combinator: S (S (K S) (S (K K) I)).
Intermediate step toward pairing combinator.
-/
theorem app_combinator (A B C : Formula) :
  ⊢ ... := by
  sorry  -- ~15-20 lines of S/K manipulation

/--
Pairing combinator: `⊢ A → B → A ∧ B`.
Fully derived from K and S axioms as: S (S (K S) (S (K K) I)) (K I)
-/
theorem pairing_derived (A B : Formula) : ⊢ A.imp (B.imp (A.and B)) := by
  sorry  -- ~25-30 lines of combinator reduction
```

**Estimated Addition**: +40-50 lines for full derivation

**Recommendation**: Skip unless zero-axiom footprint required (per TODO.md Task 21 "SKIPPED - optional")

---

## Recommendations

### Recommendation 1: Implement Changes in Three Phases

**Phase 1: S5 Axiom Addition** (3-5 hours)
- [ ] Add `modal_5` constructor to Axioms.lean (~10 lines)
- [ ] Update documentation in Axioms.lean (~5 lines)
- [ ] Add `modal_5_valid` lemma to Soundness.lean (~20 lines)
- [ ] Update `soundness` theorem cases (~1 line)
- [ ] Add unit test to AxiomsTest.lean (~10 lines)
- [ ] Update CLAUDE.md axiom counts (~5 lines)

**Phase 2: P5 Derivation** (4-6 hours)
- [ ] Complete `persistence` proof in Perpetuity.lean (~35 lines)
- [ ] Replace P5 axiom with theorem (~1 line change)
- [ ] Add persistence unit test to PerpetuityTest.lean (~10 lines)
- [ ] Add P5 unit test to PerpetuityTest.lean (~10 lines)
- [ ] Update TODO.md Task 19 to COMPLETE (~5 lines)
- [ ] Update SORRY_REGISTRY.md (~5 lines)

**Phase 3: P6 Derivation** (16-24 hours) - OPTIONAL
- [ ] Add modal duality lemmas to Perpetuity.lean (~50-70 lines)
- [ ] Add temporal duality lemmas to Perpetuity.lean (~50-70 lines)
- [ ] Replace P6 axiom with theorem (~35 lines)
- [ ] Add duality unit tests to PerpetuityTest.lean (~40 lines)
- [ ] Add P6 unit test to PerpetuityTest.lean (~10 lines)
- [ ] Update TODO.md Task 20 to COMPLETE (~5 lines)

**Total Effort**: 7-11 hours (Phases 1-2) or 23-35 hours (all phases)

### Recommendation 2: File Modification Summary

**Core Implementation Files**:
1. **Axioms.lean**: +15 lines (modal_5 axiom + docs)
2. **Soundness.lean**: +25 lines (validity lemma + case)
3. **Perpetuity.lean**: +166-216 lines (persistence, P5, duality, P6)

**Testing Files**:
4. **AxiomsTest.lean**: +10-15 lines (modal_5 tests)
5. **PerpetuityTest.lean**: +70-90 lines (persistence, P5, duality, P6 tests)
6. **SoundnessTest.lean**: +40-60 lines (validity tests)

**Documentation Files**:
7. **CLAUDE.md**: ~10-15 lines (axiom counts, theorem status)
8. **TODO.md**: ~10-15 lines (task status updates)
9. **IMPLEMENTATION_STATUS.md**: ~5-10 lines (sorry counts, completion %)
10. **SORRY_REGISTRY.md**: ~3-5 lines (remove persistence entry)

**Total Files**: 10 files
**Total LOC**: +344-451 lines (including tests and documentation)

### Recommendation 3: Reuse Existing Helper Infrastructure

**Available Helpers** (no modification needed):

From Perpetuity.lean:
- `imp_trans` (line 85): Compose implications
- `identity` (line 109): Reflexivity of implication
- `b_combinator` (line 128): Function composition
- `contraposition` (line 341): Proven via B combinator
- `combine_imp_conj` (line 216): Conjunction introduction
- `combine_imp_conj_3` (line 233): Three-way conjunction
- `box_conj_intro` (line 512): Boxed conjunction introduction
- `box_dne` (line 630): DNE inside box
- `dni` axiom (line 203): DNI axiom

From Derivation.lean:
- `necessitation_from_modal_k` (line 254): Necessitation via MK
- `identity` (line 288): Alternative identity proof
- `imp_trans` (line 317): Alternative transitivity proof

**Reuse Strategy**: All perpetuity proofs can build on these 12 helper lemmas without modification. Estimated reduction in implementation time: **20-30%** vs. building from scratch.

### Recommendation 4: Testing Strategy Aligned with Quality Metrics

**Coverage Targets** (from CLAUDE.md Section 8):
- Overall: ≥85%
- Metalogic: ≥90%
- Automation: ≥80%

**Test Organization**:

1. **Unit Tests** (AxiomsTest.lean, PerpetuityTest.lean):
   - Test each axiom instantiation
   - Test each theorem with concrete formulas (atoms, compound)
   - Test helper lemmas in isolation

2. **Integration Tests** (SoundnessTest.lean):
   - Test axiom validity in concrete models
   - Test theorem validity in concrete models
   - Test proof chains (P1→P2, P3→P4, P4→P5, P5→P6)

3. **Regression Tests**:
   - Verify all existing tests still pass
   - Verify no new sorry markers introduced
   - Verify lake build succeeds

**Test Execution**:
```bash
# Run all tests
lake test

# Run specific test suites
lake test Logos.Test.Core.ProofSystem.AxiomsTest
lake test Logos.Test.Core.Theorems.PerpetuityTest
lake test Logos.Test.Core.Metalogic.SoundnessTest

# Verify build
lake build

# Check linting
lake lint
```

### Recommendation 5: Defer Pairing Combinator Derivation

**Rationale**:
- **Low priority**: TODO.md Task 21 marked "SKIPPED - optional"
- **High effort**: 8-12 hours for ~40-50 lines of combinator manipulation
- **Zero insight**: Standard combinator calculus result
- **Semantic validity**: Clear justification (propositional tautology)

**Recommendation**: Keep axiomatized unless:
1. Zero-axiom footprint required for publication
2. Formal certification requires all axioms eliminated
3. Post-MVP work has excess capacity

**Alternative Priority**: Use effort on P6 duality proofs (higher mathematical value) rather than pairing derivation (mechanical combinator manipulation).

---

## Summary

**File Modification Map**:

```
Logos/Core/ProofSystem/
├── Axioms.lean               [+15 lines] Add modal_5 axiom
└── Derivation.lean            [no change] Existing infrastructure sufficient

Logos/Core/Theorems/
└── Perpetuity.lean            [+166-216 lines] persistence, P5, duality, P6

Logos/Core/Metalogic/
└── Soundness.lean             [+25 lines] modal_5_valid lemma

LogosTest/Core/ProofSystem/
└── AxiomsTest.lean            [+10-15 lines] modal_5 tests

LogosTest/Core/Theorems/
└── PerpetuityTest.lean        [+70-90 lines] persistence, P5, duality, P6 tests

LogosTest/Core/Metalogic/
└── SoundnessTest.lean         [+40-60 lines] validity tests

Documentation/
├── CLAUDE.md                  [+10-15 lines] axiom/theorem status
├── TODO.md                    [+10-15 lines] task completion
├── IMPLEMENTATION_STATUS.md   [+5-10 lines] sorry counts
└── SORRY_REGISTRY.md          [+3-5 lines] remove persistence
```

**Phased Implementation Timeline**:

- **Phase 1** (S5 axiom): 3-5 hours → Unblocks P5 derivation
- **Phase 2** (P5 derivation): 4-6 hours → Removes blocking sorry, proves P5
- **Phase 3** (P6 derivation): 16-24 hours → Optional, high effort

**Recommended Path**: Complete Phases 1-2 (P5 derivation), then reassess Phase 3 (P6 derivation) based on MVP priorities and remaining effort budget.

**Pairing Combinator**: Defer indefinitely unless zero-axiom footprint becomes a hard requirement.
