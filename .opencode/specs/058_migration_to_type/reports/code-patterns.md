# Code Migration Patterns: Derivable : Prop → DerivationTree : Type

**Project**: #058  
**Date**: 2025-12-19  
**Purpose**: Concrete before/after examples for migration

---

## 1. Core Type Definition

### Pattern 1.1: Inductive Type Declaration

**BEFORE** (Prop-based):
```lean
inductive Derivable : Context → Formula → Prop where
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : Derivable Γ φ
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : Derivable Γ φ
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (h1 : Derivable Γ (φ.imp ψ))
      (h2 : Derivable Γ φ) : Derivable Γ ψ
  | necessitation (φ : Formula)
      (h : Derivable [] φ) : Derivable [] (Formula.box φ)
  | temporal_necessitation (φ : Formula)
      (h : Derivable [] φ) : Derivable [] (Formula.all_future φ)
  | temporal_duality (φ : Formula)
      (h : Derivable [] φ) : Derivable [] φ.swap_past_future
  | weakening (Γ Δ : Context) (φ : Formula)
      (h1 : Derivable Γ φ)
      (h2 : Γ ⊆ Δ) : Derivable Δ φ
```

**AFTER** (Type-based):
```lean
inductive DerivationTree : Context → Formula → Type where
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : DerivationTree Γ φ
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : DerivationTree Γ φ
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (d1 : DerivationTree Γ (φ.imp ψ))
      (d2 : DerivationTree Γ φ) : DerivationTree Γ ψ
  | necessitation (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] (Formula.box φ)
  | temporal_necessitation (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] (Formula.all_future φ)
  | temporal_duality (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] φ.swap_past_future
  | weakening (Γ Δ : Context) (φ : Formula)
      (d : DerivationTree Γ φ)
      (h : Γ ⊆ Δ) : DerivationTree Δ φ
  deriving Repr  -- NEW: Automatic representation
```

**Key Changes**:
1. `Prop` → `Type`
2. Parameter names: `h1`, `h2` → `d1`, `d2` (derivations, not proofs)
3. Add `deriving Repr` for debugging

---

### Pattern 1.2: Height Function (Axiomatized → Computable)

**BEFORE** (Axiomatized):
```lean
axiom Derivable.height {Γ : Context} {φ : Formula} (d : Derivable Γ φ) : Nat

axiom Derivable.weakening_height_succ {Γ' Δ : Context} {φ : Formula}
    (d : Derivable Γ' φ) (h : Γ' ⊆ Δ) :
    (Derivable.weakening Γ' Δ φ d h).height = d.height + 1

axiom Derivable.subderiv_height_lt {Γ' Δ : Context} {φ : Formula}
    (d : Derivable Γ' φ) (h : Γ' ⊆ Δ) :
    d.height < (Derivable.weakening Γ' Δ φ d h).height

axiom Derivable.mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : Derivable Γ (φ.imp ψ)) (d2 : Derivable Γ φ) :
    d1.height < (Derivable.modus_ponens Γ φ ψ d1 d2).height

axiom Derivable.mp_height_gt_right {Γ : Context} {φ ψ : Formula}
    (d1 : Derivable Γ (φ.imp ψ)) (d2 : Derivable Γ φ) :
    d2.height < (Derivable.modus_ponens Γ φ ψ d1 d2).height

axiom Derivable.necessitation_height_succ {φ : Formula}
    (d : Derivable [] φ) :
    (Derivable.necessitation φ d).height = d.height + 1

axiom Derivable.temporal_necessitation_height_succ {φ : Formula}
    (d : Derivable [] φ) :
    (Derivable.temporal_necessitation φ d).height = d.height + 1

axiom Derivable.temporal_duality_height_succ {φ : Formula}
    (d : Derivable [] φ) :
    (Derivable.temporal_duality φ d).height = d.height + 1
```

**AFTER** (Computable):
```lean
namespace DerivationTree

/-- Computable height function via pattern matching -/
def height {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | axiom _ _ _ => 0
  | assumption _ _ _ => 0
  | modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | necessitation _ d => 1 + d.height
  | temporal_necessitation _ d => 1 + d.height
  | temporal_duality _ d => 1 + d.height
  | weakening _ _ _ d _ => 1 + d.height

/-- Height properties are now PROVABLE theorems, not axioms -/
theorem weakening_height_succ {Γ Δ : Context} {φ : Formula}
    (d : DerivationTree Γ φ) (h : Γ ⊆ Δ) :
    (weakening Γ Δ φ d h).height = d.height + 1 := by
  simp [height]

theorem subderiv_height_lt {Γ Δ : Context} {φ : Formula}
    (d : DerivationTree Γ φ) (h : Γ ⊆ Δ) :
    d.height < (weakening Γ Δ φ d h).height := by
  simp [height]
  omega

theorem mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

theorem mp_height_gt_right {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d2.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

theorem necessitation_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (necessitation φ d).height = d.height + 1 := by
  simp [height]

theorem temporal_necessitation_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (temporal_necessitation φ d).height = d.height + 1 := by
  simp [height]

theorem temporal_duality_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (temporal_duality φ d).height = d.height + 1 := by
  simp [height]

end DerivationTree
```

**Key Changes**:
1. **Remove 7 axioms** (height + 6 properties)
2. **Add computable `def height`** with pattern matching
3. **Prove height properties** as theorems using `simp [height]` and `omega`
4. **No trust required** - everything is verified

---

## 2. Theorem Signatures

### Pattern 2.1: Simple Theorem

**BEFORE**:
```lean
theorem lem (p : Formula) : ⊢ p.or p.neg := by
  apply Derivable.axiom
  apply Axiom.peirce
```

**AFTER**:
```lean
theorem lem (p : Formula) : ⊢ p.or p.neg := by
  apply DerivationTree.axiom
  apply Axiom.peirce
```

**Key Changes**:
1. `Derivable.axiom` → `DerivationTree.axiom`
2. Notation `⊢` still works (hides Type vs Prop)

---

### Pattern 2.2: Theorem with Derivation Parameter

**BEFORE**:
```lean
theorem my_theorem (Γ : Context) (φ : Formula) (h : Γ ⊢ φ) : ... := by
  -- h is a proof (Prop)
  induction h with
  | axiom Γ' φ' h_ax => ...
  | modus_ponens Γ' φ' ψ' h1 h2 ih1 ih2 => ...
```

**AFTER**:
```lean
theorem my_theorem (Γ : Context) (φ : Formula) (d : Γ ⊢ φ) : ... := by
  -- d is a derivation tree (Type)
  induction d with
  | axiom Γ' φ' h_ax => ...
  | modus_ponens Γ' φ' ψ' d1 d2 ih1 ih2 => ...
```

**Key Changes**:
1. Parameter name: `h` → `d` (convention: derivations are `d`, proofs are `h`)
2. Constructor names: `Derivable.*` → `DerivationTree.*`
3. Subderivation names: `h1`, `h2` → `d1`, `d2`

---

### Pattern 2.3: Theorem with Modus Ponens

**BEFORE**:
```lean
theorem imp_trans (p q r : Formula) : ⊢ (p.imp q).imp ((q.imp r).imp (p.imp r)) := by
  have h1 : ⊢ (p.imp q).imp ((q.imp r).imp (p.imp r)) := 
    Derivable.axiom [] _ (Axiom.prop_k p q r)
  have h2 : ⊢ p.imp q := ...
  exact Derivable.modus_ponens [] (p.imp q) ((q.imp r).imp (p.imp r)) h1 h2
```

**AFTER**:
```lean
theorem imp_trans (p q r : Formula) : ⊢ (p.imp q).imp ((q.imp r).imp (p.imp r)) := by
  have d1 : ⊢ (p.imp q).imp ((q.imp r).imp (p.imp r)) := 
    DerivationTree.axiom [] _ (Axiom.prop_k p q r)
  have d2 : ⊢ p.imp q := ...
  exact DerivationTree.modus_ponens [] (p.imp q) ((q.imp r).imp (p.imp r)) d1 d2
```

**Key Changes**:
1. `h1`, `h2` → `d1`, `d2`
2. `Derivable.axiom` → `DerivationTree.axiom`
3. `Derivable.modus_ponens` → `DerivationTree.modus_ponens`

---

## 3. Metalogic Proofs

### Pattern 3.1: Soundness Theorem

**BEFORE**:
```lean
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ) := by
  intro h_deriv
  induction h_deriv with
  | axiom Γ' φ' h_ax =>
      intro T _ F M τ t ht _
      exact axiom_valid h_ax T F M τ t ht
  | assumption Γ' φ' h_mem =>
      intro T _ F M τ t ht h_all
      exact h_all φ' h_mem
  | modus_ponens Γ' φ' ψ' _ _ ih_imp ih_phi =>
      intro T _ F M τ t ht h_all
      have h_imp := ih_imp T F M τ t ht h_all
      have h_phi := ih_phi T F M τ t ht h_all
      unfold truth_at at h_imp
      exact h_imp h_phi
  | necessitation φ' h_deriv ih =>
      intro T _ F M τ t ht _
      unfold truth_at
      intro σ hs
      exact ih T F M σ t hs (fun _ h => False.elim (List.not_mem_nil _ h))
  | temporal_necessitation φ' h_deriv ih =>
      intro T _ F M τ t ht _
      unfold truth_at
      intro s hs hts
      exact ih T F M τ s hs (fun _ h => False.elim (List.not_mem_nil _ h))
  | temporal_duality φ' h_deriv_phi _ =>
      intro T _ F M τ t ht _
      have h_swap_valid := @Semantics.TemporalDuality.derivable_implies_swap_valid T _ _ h_deriv_phi
      exact h_swap_valid F M τ t ht
  | weakening Γ' Δ' φ' _ h_sub ih =>
      intro T _ F M τ t ht h_all
      apply ih T F M τ t ht
      intro ψ h_mem
      exact h_all ψ (h_sub h_mem)
```

**AFTER**:
```lean
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ) := by
  intro d  -- Changed from h_deriv
  induction d with
  | axiom Γ' φ' h_ax =>
      intro T _ F M τ t ht _
      exact axiom_valid h_ax T F M τ t ht
  | assumption Γ' φ' h_mem =>
      intro T _ F M τ t ht h_all
      exact h_all φ' h_mem
  | modus_ponens Γ' φ' ψ' d1 d2 ih_imp ih_phi =>  -- Changed from _ _
      intro T _ F M τ t ht h_all
      have h_imp := ih_imp T F M τ t ht h_all
      have h_phi := ih_phi T F M τ t ht h_all
      unfold truth_at at h_imp
      exact h_imp h_phi
  | necessitation φ' d ih =>  -- Changed from h_deriv
      intro T _ F M τ t ht _
      unfold truth_at
      intro σ hs
      exact ih T F M σ t hs (fun _ h => False.elim (List.not_mem_nil _ h))
  | temporal_necessitation φ' d ih =>  -- Changed from h_deriv
      intro T _ F M τ t ht _
      unfold truth_at
      intro s hs hts
      exact ih T F M τ s hs (fun _ h => False.elim (List.not_mem_nil _ h))
  | temporal_duality φ' d _ =>  -- Changed from h_deriv_phi
      intro T _ F M τ t ht _
      have h_swap_valid := @Semantics.TemporalDuality.derivable_implies_swap_valid T _ _ d
      exact h_swap_valid F M τ t ht
  | weakening Γ' Δ' φ' d h_sub ih =>  -- Changed from _
      intro T _ F M τ t ht h_all
      apply ih T F M τ t ht
      intro ψ h_mem
      exact h_all ψ (h_sub h_mem)
```

**Key Changes**:
1. `intro h_deriv` → `intro d`
2. `induction h_deriv` → `induction d`
3. Subderivation names: `_` → `d`, `d1`, `d2` (make explicit)
4. Logic unchanged (induction on Type works same as Prop)

---

### Pattern 3.2: Deduction Theorem (Well-Founded Recursion)

**BEFORE**:
```lean
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B := by
  match h with
  | Derivable.axiom _ φ h_ax =>
      exact deduction_axiom Γ A φ h_ax
  | Derivable.assumption _ φ h_mem =>
      cases h_mem with
      | head => exact deduction_assumption_same Γ A
      | tail _ h_tail => exact deduction_assumption_other Γ A φ h_tail
  | Derivable.modus_ponens _ φ ψ h1 h2 =>
      have ih1 : Γ ⊢ A.imp (φ.imp ψ) := deduction_theorem Γ A (φ.imp ψ) h1
      have ih2 : Γ ⊢ A.imp φ := deduction_theorem Γ A φ h2
      exact deduction_mp Γ A φ ψ ih1 ih2
  | Derivable.weakening Γ' _ φ h1 h2 =>
      -- ... complex weakening case
      by_cases h_eq : Γ' = A :: Γ
      · subst h_eq
        exact deduction_theorem Γ A φ h1
      · by_cases hA : A ∈ Γ'
        · have ih : removeAll Γ' A ⊢ A.imp φ :=
            deduction_with_mem Γ' A φ h1 hA
          have h_sub : removeAll Γ' A ⊆ Γ := removeAll_subset hA h2
          exact Derivable.weakening (removeAll Γ' A) Γ (A.imp φ) ih h_sub
        · -- ... A ∉ Γ' case
          have h_sub : Γ' ⊆ Γ := ...
          have h_weak : Γ ⊢ φ := Derivable.weakening Γ' Γ φ h1 h_sub
          have s_ax : ⊢ φ.imp (A.imp φ) := Derivable.axiom [] _ (Axiom.prop_s φ A)
          have s_weak : Γ ⊢ φ.imp (A.imp φ) := Derivable.weakening [] Γ _ s_ax (List.nil_subset Γ)
          exact Derivable.modus_ponens Γ φ (A.imp φ) s_weak h_weak
termination_by h.height
decreasing_by
  simp_wf
  exact Derivable.mp_height_gt_left h1 h2
  exact Derivable.mp_height_gt_right h1 h2
  exact Derivable.subderiv_height_lt h1 h2
```

**AFTER**:
```lean
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (d : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B := by
  match d with
  | DerivationTree.axiom _ φ h_ax =>
      exact deduction_axiom Γ A φ h_ax
  | DerivationTree.assumption _ φ h_mem =>
      cases h_mem with
      | head => exact deduction_assumption_same Γ A
      | tail _ h_tail => exact deduction_assumption_other Γ A φ h_tail
  | DerivationTree.modus_ponens _ φ ψ d1 d2 =>
      have ih1 : Γ ⊢ A.imp (φ.imp ψ) := deduction_theorem Γ A (φ.imp ψ) d1
      have ih2 : Γ ⊢ A.imp φ := deduction_theorem Γ A φ d2
      exact deduction_mp Γ A φ ψ ih1 ih2
  | DerivationTree.weakening Γ' _ φ d1 h2 =>
      -- ... complex weakening case
      by_cases h_eq : Γ' = A :: Γ
      · subst h_eq
        exact deduction_theorem Γ A φ d1
      · by_cases hA : A ∈ Γ'
        · have ih : removeAll Γ' A ⊢ A.imp φ :=
            deduction_with_mem Γ' A φ d1 hA
          have h_sub : removeAll Γ' A ⊆ Γ := removeAll_subset hA h2
          exact DerivationTree.weakening (removeAll Γ' A) Γ (A.imp φ) ih h_sub
        · -- ... A ∉ Γ' case
          have h_sub : Γ' ⊆ Γ := ...
          have d_weak : Γ ⊢ φ := DerivationTree.weakening Γ' Γ φ d1 h_sub
          have s_ax : ⊢ φ.imp (A.imp φ) := DerivationTree.axiom [] _ (Axiom.prop_s φ A)
          have s_weak : Γ ⊢ φ.imp (A.imp φ) := DerivationTree.weakening [] Γ _ s_ax (List.nil_subset Γ)
          exact DerivationTree.modus_ponens Γ φ (A.imp φ) s_weak d_weak
termination_by d.height
decreasing_by
  simp_wf
  exact DerivationTree.mp_height_gt_left d1 d2
  exact DerivationTree.mp_height_gt_right d1 d2
  exact DerivationTree.subderiv_height_lt d1 h2
```

**Key Changes**:
1. `(h : ...)` → `(d : ...)`
2. `match h` → `match d`
3. `Derivable.*` → `DerivationTree.*`
4. `h1`, `h2` → `d1`, `d2` (for derivations)
5. `termination_by h.height` → `termination_by d.height`
6. Height lemmas: `Derivable.*` → `DerivationTree.*`

---

## 4. Automation (Metaprogramming)

### Pattern 4.1: Tactic with Constructor Application

**BEFORE**:
```lean
def apply_axiom (axiomName : Name) : TacticM Unit := do
  let goal ← getMainGoal
  let goalType ← goal.getType
  
  -- Apply Derivable.axiom constructor
  let axiomConst := ``Derivable.axiom
  let axiomTerm ← mkAppM axiomConst #[gamma, phi, axiomProof]
  
  goal.assign axiomTerm
```

**AFTER**:
```lean
def apply_axiom (axiomName : Name) : TacticM Unit := do
  let goal ← getMainGoal
  let goalType ← goal.getType
  
  -- Apply DerivationTree.axiom constructor
  let axiomConst := ``DerivationTree.axiom
  let axiomTerm ← mkAppM axiomConst #[gamma, phi, axiomProof]
  
  goal.assign axiomTerm
```

**Key Changes**:
1. `` ``Derivable.axiom`` → `` ``DerivationTree.axiom``
2. All other metaprogramming logic unchanged

---

### Pattern 4.2: Tactic with Modus Ponens

**BEFORE**:
```lean
def apply_mp : TacticM Unit := do
  let goal ← getMainGoal
  
  -- Construct Derivable.modus_ponens term
  let mpConst := ``Derivable.modus_ponens
  let mpTerm ← mkAppM mpConst #[gamma, phi, psi, h1, h2]
  
  goal.assign mpTerm
```

**AFTER**:
```lean
def apply_mp : TacticM Unit := do
  let goal ← getMainGoal
  
  -- Construct DerivationTree.modus_ponens term
  let mpConst := ``DerivationTree.modus_ponens
  let mpTerm ← mkAppM mpConst #[gamma, phi, psi, d1, d2]
  
  goal.assign mpTerm
```

**Key Changes**:
1. `` ``Derivable.modus_ponens`` → `` ``DerivationTree.modus_ponens``
2. Variable names: `h1`, `h2` → `d1`, `d2` (if constructing manually)

---

## 5. Test Patterns

### Pattern 5.1: Simple Test

**BEFORE**:
```lean
example : ⊢ p.imp p := by
  apply Derivable.axiom
  apply Axiom.impl_refl
```

**AFTER**:
```lean
example : ⊢ p.imp p := by
  apply DerivationTree.axiom
  apply Axiom.impl_refl
```

---

### Pattern 5.2: Test with Explicit Derivation

**BEFORE**:
```lean
def test_derivation : ⊢ p.imp p :=
  Derivable.axiom [] (p.imp p) (Axiom.impl_refl p)
```

**AFTER**:
```lean
def test_derivation : ⊢ p.imp p :=
  DerivationTree.axiom [] (p.imp p) (Axiom.impl_refl p)
```

---

### Pattern 5.3: Test with Soundness

**BEFORE**:
```lean
example : ⊨ p.imp p := by
  have h : ⊢ p.imp p := test_derivation
  exact soundness [] (p.imp p) h
```

**AFTER**:
```lean
example : ⊨ p.imp p := by
  have d : ⊢ p.imp p := test_derivation
  exact soundness [] (p.imp p) d
```

---

## 6. New Capabilities (Type-Only)

### Pattern 6.1: Computable Height

**NEW** (only possible with Type):
```lean
-- Compute height of a derivation
#eval (DerivationTree.axiom [] φ h).height
-- Output: 0

#eval (DerivationTree.modus_ponens [] φ ψ d1 d2).height
-- Output: 1 + max d1.height d2.height
```

---

### Pattern 6.2: Pattern Matching to Extract Data

**NEW** (only possible with Type):
```lean
-- Count axiom uses in a derivation
def countAxioms {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | .axiom _ _ _ => 1
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => countAxioms d1 + countAxioms d2
  | .necessitation _ d => countAxioms d
  | .temporal_necessitation _ d => countAxioms d
  | .temporal_duality _ d => countAxioms d
  | .weakening _ _ _ d _ => countAxioms d

-- Extract all subformulas used in derivation
def collectFormulas {Γ : Context} {φ : Formula} : DerivationTree Γ φ → List Formula
  | .axiom _ φ' _ => [φ']
  | .assumption _ φ' _ => [φ']
  | .modus_ponens _ φ' ψ' d1 d2 => 
      [φ', ψ'] ++ collectFormulas d1 ++ collectFormulas d2
  | .necessitation φ' d => [φ'] ++ collectFormulas d
  | .temporal_necessitation φ' d => [φ'] ++ collectFormulas d
  | .temporal_duality φ' d => [φ'] ++ collectFormulas d
  | .weakening _ _ φ' d _ => [φ'] ++ collectFormulas d
```

---

### Pattern 6.3: Decidable Equality

**NEW** (only possible with Type):
```lean
-- Add to deriving clause
inductive DerivationTree : Context → Formula → Type where
  -- ... constructors
  deriving Repr, DecidableEq

-- Now can compare derivations
#eval (d1 == d2)  -- true or false
```

---

### Pattern 6.4: Repr Instance

**NEW** (only possible with Type):
```lean
-- Automatic representation for debugging
#eval DerivationTree.axiom [] φ h
-- Output: DerivationTree.axiom [] (Formula.atom "p") (Axiom.impl_refl ...)

-- Pretty-print derivation trees
def prettyPrint {Γ : Context} {φ : Formula} : DerivationTree Γ φ → String
  | .axiom _ φ' _ => s!"Axiom: {φ'}"
  | .assumption _ φ' _ => s!"Assumption: {φ'}"
  | .modus_ponens _ φ' ψ' d1 d2 => 
      s!"MP:\n  {prettyPrint d1}\n  {prettyPrint d2}"
  | .necessitation φ' d => s!"Nec: {prettyPrint d}"
  | .temporal_necessitation φ' d => s!"TempNec: {prettyPrint d}"
  | .temporal_duality φ' d => s!"TempDual: {prettyPrint d}"
  | .weakening _ _ φ' d _ => s!"Weak: {prettyPrint d}"
```

---

## 7. Find-Replace Automation

### Regex Patterns for Bulk Migration

**Pattern 1: Constructor Names**
```regex
Find:    Derivable\.(axiom|assumption|modus_ponens|necessitation|temporal_necessitation|temporal_duality|weakening)
Replace: DerivationTree.$1
```

**Pattern 2: Parameter Names (Careful!)**
```regex
Find:    \b(h1|h2)\b
Replace: d1, d2
Context: Only in derivation contexts, not all h1/h2!
```

**Pattern 3: Induction Parameter**
```regex
Find:    intro h_deriv\n  induction h_deriv
Replace: intro d\n  induction d
```

**Pattern 4: Termination Clause**
```regex
Find:    termination_by h\.height
Replace: termination_by d.height
```

**Pattern 5: Height Lemmas**
```regex
Find:    Derivable\.(mp_height_gt_left|mp_height_gt_right|subderiv_height_lt)
Replace: DerivationTree.$1
```

---

## 8. Common Pitfalls

### Pitfall 1: Forgetting to Update Subderivation Names

**WRONG**:
```lean
| DerivationTree.modus_ponens _ φ ψ _ _ ih1 ih2 =>  -- Using _ _ instead of d1 d2
    have ih1 : ... := deduction_theorem Γ A (φ.imp ψ) ???  -- Can't reference _!
```

**CORRECT**:
```lean
| DerivationTree.modus_ponens _ φ ψ d1 d2 ih1 ih2 =>
    have ih1 : ... := deduction_theorem Γ A (φ.imp ψ) d1
```

---

### Pitfall 2: Mixing h and d for Derivations

**INCONSISTENT**:
```lean
theorem my_theorem (h : Γ ⊢ φ) : ... := by
  match h with
  | DerivationTree.modus_ponens _ _ _ d1 d2 => ...  -- Mixing h and d
```

**CONSISTENT**:
```lean
theorem my_theorem (d : Γ ⊢ φ) : ... := by
  match d with
  | DerivationTree.modus_ponens _ _ _ d1 d2 => ...
```

---

### Pitfall 3: Forgetting deriving Repr

**MISSING**:
```lean
inductive DerivationTree : Context → Formula → Type where
  -- ... constructors
-- No deriving clause - can't #eval or debug easily
```

**CORRECT**:
```lean
inductive DerivationTree : Context → Formula → Type where
  -- ... constructors
  deriving Repr
```

---

### Pitfall 4: Using Old Height Axioms

**WRONG**:
```lean
axiom DerivationTree.height : DerivationTree Γ φ → Nat  -- Still axiomatized!
```

**CORRECT**:
```lean
def DerivationTree.height : DerivationTree Γ φ → Nat
  | axiom _ _ _ => 0
  | ...  -- Pattern matching
```

---

## Summary

**Total Pattern Categories**: 8
1. Core Type Definition (2 patterns)
2. Theorem Signatures (3 patterns)
3. Metalogic Proofs (2 patterns)
4. Automation (2 patterns)
5. Test Patterns (3 patterns)
6. New Capabilities (4 patterns)
7. Find-Replace Automation (5 patterns)
8. Common Pitfalls (4 patterns)

**Key Takeaways**:
- Constructor renaming is mechanical (`Derivable.*` → `DerivationTree.*`)
- Parameter naming convention: `h` for proofs, `d` for derivations
- Height function becomes computable (remove 7 axioms, add 1 def + 6 theorems)
- New capabilities: pattern matching, decidable equality, Repr
- Use find-replace carefully (test incrementally)

---

**Document Complete**: 2025-12-19
