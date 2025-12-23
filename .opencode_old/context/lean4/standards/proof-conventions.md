# LEAN 4 Proof Conventions - Logos Project

**Source:** Logos proof patterns from `Logos/Core/Metalogic/Soundness.lean`, `Logos/Core/Theorems/Perpetuity.lean`  
**Purpose:** Essential proof patterns and conventions for Logos TM logic proofs

## 1. Proof Structure Standards

### Theorem Statement Format

```lean
/-- Soundness theorem: derivability implies semantic validity.

If `Γ ⊢ φ` (φ is derivable from Γ), then `Γ ⊨ φ` (φ is a semantic consequence of Γ).

**Proof Strategy:** Induction on derivation structure.

**Key Steps:**
1. Base case: Axiom validity (12 axiom lemmas)
2. Inductive cases: Inference rule soundness (8 rules)
-/
theorem soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ := by
  intro h
  induction h with
  | axiom Γ φ hax => ...
  | assumption Γ φ h => ...
  | modus_ponens Γ φ ψ h1 h2 ih1 ih2 => ...
```

**Required Elements:**
1. **Docstring** with mathematical statement
2. **Proof strategy** in docstring
3. **Key steps** outline (for complex proofs)
4. **Tactic vs term mode** decision (prefer tactic mode for readability)

### Proof Sketch in Docstring

```lean
/-- Perpetuity principle P1: necessary implies always (`□φ → △φ`).

**Proof Sketch:**
1. Assume `□φ` (φ is necessary)
2. Show `△φ` = `Hφ ∧ φ ∧ Gφ` (φ at all times)
3. Use MT axiom for present: `□φ → φ`
4. Use MF axiom for future: `□φ → □Fφ`, then `□Fφ → Fφ`
5. Use temporal duality for past: swap future/past operators
-/
theorem perpetuity_1 (φ : Formula) : ⊢ (□φ → △φ) := by
  sorry
```

## 2. Logos-Specific Proof Patterns

### Pattern 1: Soundness Proofs (Axiom Validity)

**Goal:** Prove axiom is valid in all task semantic models

```lean
/-- Modal T axiom is valid: `⊨ □φ → φ` (reflexivity of necessity).

**Proof:** By definition of `□` in task semantics, `□φ` means φ holds in all
world histories at time t. Therefore φ holds in the current history.
-/
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_box
  exact h_box τ
```

**Key Techniques:**
- `intro T _ F M τ t ht` - Introduce semantic model components
- `unfold truth_at` - Expand truth definition
- Direct proof from semantics

### Pattern 2: Derivability Proofs (Inference Rules)

**Goal:** Prove formula is derivable using TM axioms and rules

```lean
/-- Perpetuity principle P1: `⊢ □φ → △φ` -/
theorem perpetuity_1 (φ : Formula) : ⊢ (□φ → △φ) := by
  -- Step 1: Apply axiom or derived theorem
  apply Derivable.axiom
  exact Axiom.modal_t φ
  
  -- OR: Build proof using inference rules
  have h1 : ⊢ □φ → φ := Derivable.axiom (Axiom.modal_t φ)
  have h2 : ⊢ □φ → Fφ := ...
  -- Combine using modus ponens, modal K, etc.
```

**Key Techniques:**
- `apply Derivable.axiom` - Apply axiom schema
- `have` - Intermediate derivation steps
- `exact` - Provide exact proof term
- Inference rules: `modus_ponens`, `modal_k`, `temporal_k`, `necessitation`

### Pattern 3: Semantic Validity Proofs

**Goal:** Prove formula is valid (true in all models)

```lean
/-- Propositional K axiom is valid: `⊨ (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` -/
theorem prop_k_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h1 h2 h_phi
  exact h1 h_phi (h2 h_phi)
```

**Key Techniques:**
- `intro T _ F M τ t ht` - Universal quantification over models
- `unfold truth_at` - Expand semantic truth
- Classical propositional reasoning

### Pattern 4: Induction on Derivability

**Goal:** Prove property holds for all derivable formulas

```lean
theorem soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ := by
  intro h
  induction h with
  | axiom Γ φ hax =>
    -- Base case: axiom validity
    cases hax with
    | modal_t φ => exact modal_t_valid φ F M τ t
    | modal_4 φ => exact modal_4_valid φ F M τ t
    -- ... (12 axiom cases)
  
  | modus_ponens Γ φ ψ h1 h2 ih1 ih2 =>
    -- Inductive case: modus ponens
    intro F M τ t hΓ
    exact ih1 F M τ t hΓ (ih2 F M τ t hΓ)
  
  -- ... (8 inference rule cases)
```

**Key Techniques:**
- `induction h with` - Induction on derivation
- `cases hax with` - Case analysis on axioms
- `ih1`, `ih2` - Induction hypotheses
- Recursive application of IH

### Pattern 5: Case Analysis on Formulas

**Goal:** Prove property by analyzing formula structure

```lean
def complexity : Formula → Nat
  | Formula.atom _ => 1
  | Formula.bot => 1
  | Formula.imp φ ψ => φ.complexity + ψ.complexity + 1
  | Formula.box φ => φ.complexity + 1
  | Formula.all_past φ => φ.complexity + 1
  | Formula.all_future φ => φ.complexity + 1
```

**Key Techniques:**
- Pattern matching on formula constructors
- Recursive calls on subformulas
- Exhaustive case coverage

### Pattern 6: Contraposition and Duality

**Goal:** Prove theorem using contrapositive or temporal/modal duality

```lean
/-- Perpetuity principle P2: `⊢ ▽φ → ◇φ` (sometimes implies possible)

**Proof:** By contraposition of P1.
- P1: `□φ → △φ`
- Contrapose: `¬△φ → ¬□φ`
- Rewrite: `▽φ → ◇φ` (using `▽ = ¬△¬` and `◇ = ¬□¬`)
-/
theorem perpetuity_2 (φ : Formula) : ⊢ (▽φ → ◇φ) := by
  -- Apply contraposition helper
  apply contrapose_imp
  -- Use P1 with ¬φ
  exact perpetuity_1 (¬φ)
```

**Key Techniques:**
- `contrapose_imp` - Contraposition helper
- Temporal duality: `swap_temporal` swaps past/future
- Modal duality: `◇φ = ¬□¬φ`

## 3. Sorry Policy

### When Sorry is Acceptable

❌ **NEVER in main branch** - All merged code must be fully proven

✓ **Acceptable in development branches:**
- Proof sketches during planning
- Placeholder for complex lemmas (with TODO comment)
- Infrastructure setup (type definitions, no proofs yet)

### Documentation Requirements for Sorry

```lean
/-- Perpetuity principle P6: `⊢ ▽□φ → □△φ`

**Status:** TODO - Requires bridge lemmas (see SORRY_REGISTRY.md #42)

**Proof Strategy:**
1. Apply P5 with ¬φ: `◇▽¬φ → △◇¬φ`
2. Contrapose: `¬△◇¬φ → ¬◇▽¬φ`
3. Rewrite using double negation and modal/temporal duality
4. Derive `▽□φ → □△φ`

**Dependencies:**
- `bridge1`: `¬□△φ → ◇▽¬φ` (modal/temporal duality)
- `bridge2`: `△◇¬φ → ¬▽□φ` (modal duality + DNI)
- `double_contrapose`: From `¬A → ¬B`, derive `B → A`
-/
theorem perpetuity_6 (φ : Formula) : ⊢ (▽□φ → □△φ) := by
  sorry  -- TODO: Implement using bridge lemmas
```

**Required Elements:**
1. **Status** - TODO with reference to SORRY_REGISTRY.md
2. **Proof strategy** - Detailed steps
3. **Dependencies** - Required lemmas
4. **TODO comment** - Inline reminder

### SORRY_REGISTRY.md Workflow

When adding sorry:
1. Add entry to `Documentation/ProjectInfo/SORRY_REGISTRY.md`
2. Include proof strategy and dependencies
3. Reference registry entry in theorem docstring
4. Update when resolved

## 4. Common Proof Techniques

### Technique 1: Time-Shift Invariance

**Use case:** Proving MF/TF axioms valid

```lean
/-- Modal-Future axiom is valid: `⊨ □φ → □Fφ`

Uses time-shift invariance: truth is preserved under time shifts.
-/
theorem modal_future_valid (φ : Formula) : ⊨ (φ.box.imp (φ.all_future.box)) := by
  intro T _ F M τ t ht
  unfold truth_at
  intro h_box σ
  intro s hs
  -- Use time-shift invariance
  have h_shift := TimeShift.time_shift_preserves_truth M τ σ t s φ
  exact h_shift (h_box τ)
```

### Technique 2: Classical Logic Helpers

**Use case:** Extracting conjunction from negated implication

```lean
/-- Helper for extracting conjunction from `¬(φ → ¬ψ)` encoding -/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩
```

### Technique 3: Intermediate Steps with `have`

**Use case:** Breaking complex proofs into manageable steps

```lean
theorem complex_theorem (φ ψ : Formula) : ⊢ (φ → ψ) := by
  -- Step 1: Derive intermediate result
  have h1 : ⊢ φ → (φ ∧ φ) := by
    apply pairing
  
  -- Step 2: Use h1 to derive next step
  have h2 : ⊢ (φ ∧ φ) → ψ := by
    sorry  -- Complex derivation
  
  -- Step 3: Combine using modus ponens
  exact Derivable.modus_ponens [] φ (φ ∧ φ) ψ h1 h2
```

### Technique 4: Definitional Equality

**Use case:** Proving syntactic equality of formulas

```lean
example (p : Formula) : △p = p.always := rfl
example (p : Formula) : ▽p = (¬△¬p) := rfl
```

## 5. Proof Quality Checklist

Before committing a proof:

- [ ] **Docstring** with mathematical statement
- [ ] **Proof strategy** documented (for non-trivial proofs)
- [ ] **No sorry** in main branch
- [ ] **Intermediate steps** use `have` with descriptive names
- [ ] **Error messages** are clear (if using custom tactics)
- [ ] **Tests** cover the theorem (in `LogosTest/`)
- [ ] **Line length** ≤ 100 characters
- [ ] **Indentation** is 2 spaces
- [ ] **Naming** follows snake_case convention

## 6. Anti-Patterns (Avoid)

❌ **Incomplete pattern matches**
```lean
def incomplete : Formula → Nat
  | Formula.atom _ => 1
  -- Missing cases - will cause errors
```

❌ **Magic numbers without explanation**
```lean
def mystery (n : Nat) : Nat := n + 42  -- What is 42?
```

❌ **Overly complex single expressions**
```lean
def complex := (fun x => (fun y => x + y + (if x > 0 then 1 else 0)) 3) 2
-- Hard to read, hard to debug
```

❌ **Missing docstrings**
```lean
theorem important_result (φ : Formula) : ⊢ φ := by  -- No docstring!
  sorry
```

❌ **Sorry without documentation**
```lean
theorem perpetuity_6 (φ : Formula) : ⊢ (▽□φ → □△φ) := by
  sorry  -- No explanation, no TODO, no registry entry
```

## 7. Logos-Specific Conventions

### Perpetuity Principles (P1-P6)

**Status:** ALL 6 FULLY PROVEN (100% completion)

**Proof Patterns:**
- P1-P4: Direct derivation from TM axioms
- P5: Uses persistence lemma (modal_5 + temporal K)
- P6: Uses P5(¬φ) + bridge lemmas + double_contrapose

**Key Lemmas:**
- `modal_5`: `◇φ → □◇φ` (S5 characteristic)
- `swap_temporal_diamond`: Temporal swap distributes over diamond
- `contrapose_imp`: `(A → B) → (¬B → ¬A)`

### Soundness Proof Structure

**12 Axiom Validity Lemmas:**
- Propositional: `prop_k_valid`, `prop_s_valid`, `double_negation_valid`
- Modal: `modal_t_valid`, `modal_4_valid`, `modal_b_valid`, `modal_k_dist_valid`
- Temporal: `temp_4_valid`, `temp_a_valid`, `temp_l_valid`
- Bimodal: `modal_future_valid`, `temp_future_valid`

**8 Inference Rule Cases:**
- `axiom`, `assumption`, `modus_ponens`, `necessitation`
- `modal_k`, `temporal_k`, `temporal_duality`, `weakening`

### Notation Consistency

Use Unicode operators consistently:
- `□φ` (box) not `Formula.box φ` in comments
- `△φ` (always) not `always φ` in theorem statements
- `▽φ` (sometimes) not `sometimes φ` in theorem statements
- Wrap in backticks in docstrings: `` `□φ → φ` ``

## References

- Full soundness proofs: `Logos/Core/Metalogic/Soundness.lean`
- Perpetuity proofs: `Logos/Core/Theorems/Perpetuity.lean`
- Sorry registry: `Documentation/ProjectInfo/SORRY_REGISTRY.md`
- Implementation status: `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- LEAN style guide: `Documentation/Development/LEAN_STYLE_GUIDE.md`
