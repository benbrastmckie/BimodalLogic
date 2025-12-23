# Task 75: Automation Migration - Detailed Changes

**Date**: 2025-12-20  
**Migration**: `Derivable : Prop` → `DerivationTree : Type`

---

## File 1: Logos/Core/Automation/Tactics.lean

### Change Summary
- **Total Edits**: 16
- **Pattern**: Update all references from `Derivable` to `DerivationTree`
- **Impact**: Metaprogramming code, macros, documentation

### Detailed Changes

#### 1. Documentation Example (Line 62)
```diff
- example : Derivable [] (Formula.box p |>.imp p) := by
+ example : DerivationTree [] (Formula.box p |>.imp p) := by
```

#### 2. apply_axiom Macro (Line 75)
```diff
  macro "apply_axiom" : tactic =>
-   `(tactic| (apply Derivable.axiom; refine ?_))
+   `(tactic| (apply DerivationTree.axiom; refine ?_))
```

#### 3. modal_t Macro (Line 92)
```diff
  macro "modal_t" : tactic =>
-   `(tactic| (apply Derivable.axiom; refine ?_))
+   `(tactic| (apply DerivationTree.axiom; refine ?_))
```

#### 4. mkOperatorKTactic Pattern Matching (Line 225)
```diff
  match goalType with
-   | .app (.app (.const ``Derivable _) _context) formula =>
+   | .app (.app (.const ``DerivationTree _) _context) formula =>
```

#### 5. modal_k_tactic Example (Line 257)
```diff
- example (p : Formula) : Derivable [p.box] (p.box) := by
+ example (p : Formula) : DerivationTree [p.box] (p.box) := by
```

#### 6. temporal_k_tactic Example (Line 277)
```diff
- example (p : Formula) : Derivable [p.all_future] (p.all_future) := by
+ example (p : Formula) : DerivationTree [p.all_future] (p.all_future) := by
```

#### 7. modal_4_tactic Example (Line 302)
```diff
- example (p : Formula) : Derivable [] ((p.box).imp (p.box.box)) := by
+ example (p : Formula) : DerivationTree [] ((p.box).imp (p.box.box)) := by
```

#### 8. modal_4_tactic Pattern Matching (Line 313)
```diff
  match goalType with
-   | .app (.app (.const ``Derivable _) context) formula =>
+   | .app (.app (.const ``DerivationTree _) context) formula =>
```

#### 9. modal_4_tactic mkAppM Calls (Lines 326-327)
```diff
            let axiomProof ← mkAppM ``Axiom.modal_4 #[innerFormula]
-           let proof ← mkAppM ``Derivable.axiom #[axiomProof]
+           let proof ← mkAppM ``DerivationTree.axiom #[axiomProof]
```

#### 10. modal_b_tactic Example (Line 352)
```diff
- example (p : Formula) : Derivable [] (p.imp (p.diamond.box)) := by
+ example (p : Formula) : DerivationTree [] (p.imp (p.diamond.box)) := by
```

#### 11. modal_b_tactic Pattern Matching (Line 363)
```diff
  match goalType with
-   | .app (.app (.const ``Derivable _) context) formula =>
+   | .app (.app (.const ``DerivationTree _) context) formula =>
```

#### 12. modal_b_tactic mkAppM Calls (Lines 376-377)
```diff
          let axiomProof ← mkAppM ``Axiom.modal_b #[lhs]
-         let proof ← mkAppM ``Derivable.axiom #[axiomProof]
+         let proof ← mkAppM ``DerivationTree.axiom #[axiomProof]
```

#### 13. temp_4_tactic Example (Line 404)
```diff
- example (p : Formula) : Derivable [] ((p.all_future).imp (p.all_future.all_future)) := by
+ example (p : Formula) : DerivationTree [] ((p.all_future).imp (p.all_future.all_future)) := by
```

#### 14. temp_4_tactic Pattern Matching (Line 415)
```diff
  match goalType with
-   | .app (.app (.const ``Derivable _) context) formula =>
+   | .app (.app (.const ``DerivationTree _) context) formula =>
```

#### 15. temp_4_tactic mkAppM Calls (Lines 429-430)
```diff
            let axiomProof ← mkAppM ``Axiom.temp_4 #[innerFormula]
-           let proof ← mkAppM ``Derivable.axiom #[axiomProof]
+           let proof ← mkAppM ``DerivationTree.axiom #[axiomProof]
```

#### 16. temp_a_tactic Example (Line 455)
```diff
- example (p : Formula) : Derivable [] (p.imp (p.sometime_past.all_future)) := by
+ example (p : Formula) : DerivationTree [] (p.imp (p.sometime_past.all_future)) := by
```

#### 17. temp_a_tactic Pattern Matching (Line 466)
```diff
  match goalType with
-   | .app (.app (.const ``Derivable _) context) formula =>
+   | .app (.app (.const ``DerivationTree _) context) formula =>
```

#### 18. temp_a_tactic mkAppM Calls (Lines 475-476)
```diff
        let axiomProof ← mkAppM ``Axiom.temp_a #[lhs]
-       let proof ← mkAppM ``Derivable.axiom #[axiomProof]
+       let proof ← mkAppM ``DerivationTree.axiom #[axiomProof]
```

#### 19. modal_search Example (Line 506)
```diff
- example (p : Formula) : Derivable [] ((p.box).imp p) := by
+ example (p : Formula) : DerivationTree [] ((p.box).imp p) := by
```

#### 20. temporal_search Example (Line 525)
```diff
- example (p : Formula) : Derivable [] ((p.all_future).imp (p.all_future.all_future)) := by
+ example (p : Formula) : DerivationTree [] ((p.all_future).imp (p.all_future.all_future)) := by
```

---

## File 2: Logos/Core/Automation/AesopRules.lean

### Change Summary
- **Total Edits**: 34
- **Pattern**: Change `theorem` to `def`, update type signatures, update constructor calls
- **Impact**: All Aesop rules (17 rules total)

### Detailed Changes

#### Direct Axiom Rules (7 rules)

##### 1. axiom_modal_t (Lines 56-59)
```diff
- @[aesop safe apply]
- theorem axiom_modal_t (Γ : Context) (φ : Formula) :
-     Derivable Γ ((Formula.box φ).imp φ) :=
-   Derivable.axiom Γ ((Formula.box φ).imp φ) (Axiom.modal_t φ)
+ @[aesop safe apply]
+ def axiom_modal_t (Γ : Context) (φ : Formula) :
+     DerivationTree Γ ((Formula.box φ).imp φ) :=
+   DerivationTree.axiom Γ ((Formula.box φ).imp φ) (Axiom.modal_t φ)
```

##### 2. axiom_prop_k (Lines 62-65)
```diff
- theorem axiom_prop_k (Γ : Context) (φ ψ χ : Formula) :
-     Derivable Γ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) :=
-   Derivable.axiom Γ _ (Axiom.prop_k φ ψ χ)
+ def axiom_prop_k (Γ : Context) (φ ψ χ : Formula) :
+     DerivationTree Γ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) :=
+   DerivationTree.axiom Γ _ (Axiom.prop_k φ ψ χ)
```

##### 3. axiom_prop_s (Lines 68-71)
```diff
- theorem axiom_prop_s (Γ : Context) (φ ψ : Formula) :
-     Derivable Γ (φ.imp (ψ.imp φ)) :=
-   Derivable.axiom Γ _ (Axiom.prop_s φ ψ)
+ def axiom_prop_s (Γ : Context) (φ ψ : Formula) :
+     DerivationTree Γ (φ.imp (ψ.imp φ)) :=
+   DerivationTree.axiom Γ _ (Axiom.prop_s φ ψ)
```

##### 4. axiom_modal_4 (Lines 74-77)
```diff
- theorem axiom_modal_4 (Γ : Context) (φ : Formula) :
-     Derivable Γ ((Formula.box φ).imp (Formula.box (Formula.box φ))) :=
-   Derivable.axiom Γ _ (Axiom.modal_4 φ)
+ def axiom_modal_4 (Γ : Context) (φ : Formula) :
+     DerivationTree Γ ((Formula.box φ).imp (Formula.box (Formula.box φ))) :=
+   DerivationTree.axiom Γ _ (Axiom.modal_4 φ)
```

##### 5. axiom_modal_b (Lines 80-83)
```diff
- theorem axiom_modal_b (Γ : Context) (φ : Formula) :
-     Derivable Γ (φ.imp (Formula.box φ.diamond)) :=
-   Derivable.axiom Γ _ (Axiom.modal_b φ)
+ def axiom_modal_b (Γ : Context) (φ : Formula) :
+     DerivationTree Γ (φ.imp (Formula.box φ.diamond)) :=
+   DerivationTree.axiom Γ _ (Axiom.modal_b φ)
```

##### 6. axiom_temp_4 (Lines 86-89)
```diff
- theorem axiom_temp_4 (Γ : Context) (φ : Formula) :
-     Derivable Γ ((Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ))) :=
-   Derivable.axiom Γ _ (Axiom.temp_4 φ)
+ def axiom_temp_4 (Γ : Context) (φ : Formula) :
+     DerivationTree Γ ((Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ))) :=
+   DerivationTree.axiom Γ _ (Axiom.temp_4 φ)
```

##### 7. axiom_temp_a (Lines 92-95)
```diff
- theorem axiom_temp_a (Γ : Context) (φ : Formula) :
-     Derivable Γ (φ.imp (Formula.all_future φ.sometime_past)) :=
-   Derivable.axiom Γ _ (Axiom.temp_a φ)
+ def axiom_temp_a (Γ : Context) (φ : Formula) :
+     DerivationTree Γ (φ.imp (Formula.all_future φ.sometime_past)) :=
+   DerivationTree.axiom Γ _ (Axiom.temp_a φ)
```

#### Forward Chaining Rules (7 rules)

##### 8. modal_t_forward (Lines 109-114)
```diff
  @[aesop safe forward]
- theorem modal_t_forward {Γ : Context} {φ : Formula} :
-     Derivable Γ (Formula.box φ) → Derivable Γ φ := by
-   intro h
-   have ax := Derivable.axiom Γ (Formula.box φ |>.imp φ) (Axiom.modal_t φ)
-   exact Derivable.modus_ponens Γ (Formula.box φ) φ ax h
+ def modal_t_forward {Γ : Context} {φ : Formula} :
+     DerivationTree Γ (Formula.box φ) → DerivationTree Γ φ := by
+   intro d
+   have ax := DerivationTree.axiom Γ (Formula.box φ |>.imp φ) (Axiom.modal_t φ)
+   exact DerivationTree.modus_ponens Γ (Formula.box φ) φ ax d
```

##### 9. modal_4_forward (Lines 121-126)
```diff
  @[aesop safe forward]
- theorem modal_4_forward {Γ : Context} {φ : Formula} :
-     Derivable Γ (Formula.box φ) → Derivable Γ (Formula.box (Formula.box φ)) := by
-   intro h
-   have ax := Derivable.axiom Γ ((Formula.box φ).imp (Formula.box (Formula.box φ))) (Axiom.modal_4 φ)
-   exact Derivable.modus_ponens Γ (Formula.box φ) (Formula.box (Formula.box φ)) ax h
+ def modal_4_forward {Γ : Context} {φ : Formula} :
+     DerivationTree Γ (Formula.box φ) → DerivationTree Γ (Formula.box (Formula.box φ)) := by
+   intro d
+   have ax := DerivationTree.axiom Γ ((Formula.box φ).imp (Formula.box (Formula.box φ))) (Axiom.modal_4 φ)
+   exact DerivationTree.modus_ponens Γ (Formula.box φ) (Formula.box (Formula.box φ)) ax d
```

##### 10. modal_b_forward (Lines 133-138)
```diff
  @[aesop safe forward]
- theorem modal_b_forward {Γ : Context} {φ : Formula} :
-     Derivable Γ φ → Derivable Γ (Formula.box φ.diamond) := by
-   intro h
-   have ax := Derivable.axiom Γ (φ.imp (Formula.box φ.diamond)) (Axiom.modal_b φ)
-   exact Derivable.modus_ponens Γ φ (Formula.box φ.diamond) ax h
+ def modal_b_forward {Γ : Context} {φ : Formula} :
+     DerivationTree Γ φ → DerivationTree Γ (Formula.box φ.diamond) := by
+   intro d
+   have ax := DerivationTree.axiom Γ (φ.imp (Formula.box φ.diamond)) (Axiom.modal_b φ)
+   exact DerivationTree.modus_ponens Γ φ (Formula.box φ.diamond) ax d
```

##### 11. temp_4_forward (Lines 145-155)
```diff
  @[aesop safe forward]
- theorem temp_4_forward {Γ : Context} {φ : Formula} :
-     Derivable Γ (Formula.all_future φ) →
-     Derivable Γ (Formula.all_future (Formula.all_future φ)) := by
-   intro h
-   have ax :=
-     Derivable.axiom Γ
-       ((Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)))
-       (Axiom.temp_4 φ)
-   exact Derivable.modus_ponens Γ (Formula.all_future φ)
-     (Formula.all_future (Formula.all_future φ)) ax h
+ def temp_4_forward {Γ : Context} {φ : Formula} :
+     DerivationTree Γ (Formula.all_future φ) →
+     DerivationTree Γ (Formula.all_future (Formula.all_future φ)) := by
+   intro d
+   have ax :=
+     DerivationTree.axiom Γ
+       ((Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)))
+       (Axiom.temp_4 φ)
+   exact DerivationTree.modus_ponens Γ (Formula.all_future φ)
+     (Formula.all_future (Formula.all_future φ)) ax d
```

##### 12. temp_a_forward (Lines 163-168)
```diff
  @[aesop safe forward]
- theorem temp_a_forward {Γ : Context} {φ : Formula} :
-     Derivable Γ φ → Derivable Γ (Formula.all_future φ.sometime_past) := by
-   intro h
-   have ax := Derivable.axiom Γ (φ.imp (Formula.all_future φ.sometime_past)) (Axiom.temp_a φ)
-   exact Derivable.modus_ponens Γ φ (Formula.all_future φ.sometime_past) ax h
+ def temp_a_forward {Γ : Context} {φ : Formula} :
+     DerivationTree Γ φ → DerivationTree Γ (Formula.all_future φ.sometime_past) := by
+   intro d
+   have ax := DerivationTree.axiom Γ (φ.imp (Formula.all_future φ.sometime_past)) (Axiom.temp_a φ)
+   exact DerivationTree.modus_ponens Γ φ (Formula.all_future φ.sometime_past) ax d
```

##### 13. prop_k_forward (Lines 175-184)
```diff
  @[aesop safe forward]
- theorem prop_k_forward {Γ : Context} {φ ψ χ : Formula} :
-     Derivable Γ (φ.imp (ψ.imp χ)) → Derivable Γ ((φ.imp ψ).imp (φ.imp χ)) := by
-   intro h
-   have ax :=
-     Derivable.axiom Γ
-       ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
-       (Axiom.prop_k φ ψ χ)
-   exact Derivable.modus_ponens Γ (φ.imp (ψ.imp χ))
-     ((φ.imp ψ).imp (φ.imp χ)) ax h
+ def prop_k_forward {Γ : Context} {φ ψ χ : Formula} :
+     DerivationTree Γ (φ.imp (ψ.imp χ)) → DerivationTree Γ ((φ.imp ψ).imp (φ.imp χ)) := by
+   intro d
+   have ax :=
+     DerivationTree.axiom Γ
+       ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
+       (Axiom.prop_k φ ψ χ)
+   exact DerivationTree.modus_ponens Γ (φ.imp (ψ.imp χ))
+     ((φ.imp ψ).imp (φ.imp χ)) ax d
```

##### 14. prop_s_forward (Lines 191-196)
```diff
  @[aesop safe forward]
- theorem prop_s_forward {Γ : Context} {φ ψ : Formula} :
-     Derivable Γ φ → Derivable Γ (ψ.imp φ) := by
-   intro h
-   have ax := Derivable.axiom Γ (φ.imp (ψ.imp φ)) (Axiom.prop_s φ ψ)
-   exact Derivable.modus_ponens Γ φ (ψ.imp φ) ax h
+ def prop_s_forward {Γ : Context} {φ ψ : Formula} :
+     DerivationTree Γ φ → DerivationTree Γ (ψ.imp φ) := by
+   intro d
+   have ax := DerivationTree.axiom Γ (φ.imp (ψ.imp φ)) (Axiom.prop_s φ ψ)
+   exact DerivationTree.modus_ponens Γ φ (ψ.imp φ) ax d
```

#### Apply Rules (3 rules)

##### 15. apply_modus_ponens (Lines 209-212)
```diff
  @[aesop safe apply]
- theorem apply_modus_ponens {Γ : Context} {φ ψ : Formula} :
-     Derivable Γ (φ.imp ψ) → Derivable Γ φ → Derivable Γ ψ :=
-   Derivable.modus_ponens Γ φ ψ
+ def apply_modus_ponens {Γ : Context} {φ ψ : Formula} :
+     DerivationTree Γ (φ.imp ψ) → DerivationTree Γ φ → DerivationTree Γ ψ :=
+   DerivationTree.modus_ponens Γ φ ψ
```

##### 16. apply_modal_k (Lines 219-222)
```diff
  @[aesop safe apply]
- theorem apply_modal_k {Γ : Context} {φ : Formula} :
-     Derivable Γ φ → Derivable (Context.map Formula.box Γ) (Formula.box φ) :=
-   generalized_modal_k Γ φ
+ def apply_modal_k {Γ : Context} {φ : Formula} :
+     DerivationTree Γ φ → DerivationTree (Context.map Formula.box Γ) (Formula.box φ) :=
+   generalized_modal_k Γ φ
```

##### 17. apply_temporal_k (Lines 229-232)
```diff
  @[aesop safe apply]
- theorem apply_temporal_k {Γ : Context} {φ : Formula} :
-     Derivable Γ φ → Derivable (Context.map Formula.all_future Γ) (Formula.all_future φ) :=
-   generalized_temporal_k Γ φ
+ def apply_temporal_k {Γ : Context} {φ : Formula} :
+     DerivationTree Γ φ → DerivationTree (Context.map Formula.all_future Γ) (Formula.all_future φ) :=
+   generalized_temporal_k Γ φ
```

---

## File 3: Logos/Core/Automation/ProofSearch.lean

### Change Summary
- **Total Edits**: 1 (multi-line change)
- **Pattern**: Update example type signatures
- **Impact**: Documentation examples only

### Detailed Changes

#### Example Type Signatures (Lines 471-482)
```diff
  /-- Example: Trivial search finds axiom immediately -/
- example : ∃ (proof : Derivable [] ((Formula.atom "p").box.imp (Formula.atom "p"))), True :=
+ example : ∃ (proof : DerivationTree [] ((Formula.atom "p").box.imp (Formula.atom "p"))), True :=
    sorry  -- Would use: let proof := bounded_search [] _ 1
  
  /-- Example: Search with depth 2 for modus ponens application -/
- example (p q : Formula) (h1 : Derivable [] p) (h2 : Derivable [] (p.imp q)) :
-     ∃ (proof : Derivable [] q), True :=
+ example (p q : Formula) (h1 : DerivationTree [] p) (h2 : DerivationTree [] (p.imp q)) :
+     ∃ (proof : DerivationTree [] q), True :=
    sorry  -- Would use: let proof := bounded_search [] q 2
  
  /-- Example: Modal K search requires context transformation -/
- example (p : Formula) (h : Derivable [p.box] p) :
-     ∃ (proof : Derivable [p.box] p.box), True :=
+ example (p : Formula) (h : DerivationTree [p.box] p) :
+     ∃ (proof : DerivationTree [p.box] p.box), True :=
    sorry  -- Would use: let proof := bounded_search [p.box] p.box 3
```

---

## Summary Statistics

### Total Changes
- **Files Modified**: 3
- **Total Edits**: 51
- **Lines Changed**: ~100

### Change Breakdown by Type
- **Type Signatures**: 17 (all Aesop rules)
- **Constructor Calls**: 17 (all Aesop rules)
- **Metaprogramming**: 8 (mkAppM calls, pattern matching)
- **Macros**: 2 (apply_axiom, modal_t)
- **Documentation**: 10 (examples in docstrings)

### Change Breakdown by File
- **Tactics.lean**: 16 edits (32% of total)
- **AesopRules.lean**: 34 edits (67% of total)
- **ProofSearch.lean**: 1 edit (1% of total)

---

## Migration Pattern

### Consistent Pattern Applied

1. **Type Signatures**: `Derivable` → `DerivationTree`
2. **Constructors**: `Derivable.*` → `DerivationTree.*`
3. **Parameters**: `h` → `d` (for derivation trees)
4. **Declarations**: `theorem` → `def` (for Type-valued functions)

### No Exceptions

All changes followed the same pattern with no special cases or exceptions needed.

---

**Change Log Complete**: 2025-12-20
