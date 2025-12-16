# Phase 2 Work Specification: Temporal K Infrastructure

## Objective
Derive `always_dni` and `always_dne` theorems to replace axioms in Bridge.lean, reducing axiom count by 2.

## Target File
`/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity/Bridge.lean`

## Context

### Definition
From `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Syntax/Formula.lean:127`:
```lean
def always (φ : Formula) : Formula := φ.all_past.and (φ.and φ.all_future)
```

Therefore: `always φ = Hφ ∧ (φ ∧ Gφ)`

### Available Infrastructure

#### Conjunction Elimination (from Propositional module)
- `lce_imp (A B : Formula) : ⊢ (A.and B).imp A` - Left conjunction elimination
- `rce_imp (A B : Formula) : ⊢ (A.and B).imp B` - Right conjunction elimination

#### Conjunction Introduction (from Helpers module)
- `pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))` - Create conjunction
- `combine_imp_conj {A B C : Formula} (h1 : ⊢ A.imp B) (h2 : ⊢ A.imp C) : ⊢ A.imp (B.and C)`

#### Temporal K Distribution
- `future_k_dist (A B : Formula) : ⊢ (A.imp B).all_future.imp (A.all_future.imp B.all_future)` (AXIOM in Principles.lean:667)
- `past_k_dist (A B : Formula) : ⊢ (A.imp B).all_past.imp (A.all_past.imp B.all_past)` (THEOREM in Principles.lean:680, derived via temporal duality)

#### Double Negation
- `dni (φ : Formula) : ⊢ φ.imp φ.neg.neg` - Double negation introduction (from Helpers)
- `dne (A : Formula) : ⊢ A.neg.neg.imp A` - Double negation elimination wrapper (from Bridge:311)
- `Axiom.double_negation (φ : Formula)` - DNE axiom

## Implementation Tasks

### Task 1: Decomposition Lemmas (3 theorems)

**Insert location**: After line 304 (before `always_mono` axiom), in Bridge.lean

#### Theorem 1: `always_to_past`
```lean
/--
Decomposition: `⊢ △φ → Hφ` (always implies past component).

Extract the past component from the always operator.
-/
theorem always_to_past (φ : Formula) : ⊢ φ.always.imp φ.all_past := by
  -- always φ = Hφ ∧ (φ ∧ Gφ)
  -- Use lce_imp to extract first conjunct
  exact lce_imp φ.all_past (φ.and φ.all_future)
```

#### Theorem 2: `always_to_present`
```lean
/--
Decomposition: `⊢ △φ → φ` (always implies present component).

Extract the present component from the always operator.
-/
theorem always_to_present (φ : Formula) : ⊢ φ.always.imp φ := by
  -- always φ = Hφ ∧ (φ ∧ Gφ)
  -- Step 1: Extract (φ ∧ Gφ) using rce_imp
  have step1 : ⊢ φ.always.imp (φ.and φ.all_future) :=
    rce_imp φ.all_past (φ.and φ.all_future)
  -- Step 2: Extract φ from (φ ∧ Gφ) using lce_imp
  have step2 : ⊢ (φ.and φ.all_future).imp φ :=
    lce_imp φ φ.all_future
  -- Step 3: Compose
  exact imp_trans step1 step2
```

#### Theorem 3: `always_to_future`
```lean
/--
Decomposition: `⊢ △φ → Gφ` (always implies future component).

Extract the future component from the always operator.
-/
theorem always_to_future (φ : Formula) : ⊢ φ.always.imp φ.all_future := by
  -- always φ = Hφ ∧ (φ ∧ Gφ)
  -- Step 1: Extract (φ ∧ Gφ) using rce_imp
  have step1 : ⊢ φ.always.imp (φ.and φ.all_future) :=
    rce_imp φ.all_past (φ.and φ.all_future)
  -- Step 2: Extract Gφ from (φ ∧ Gφ) using rce_imp
  have step2 : ⊢ (φ.and φ.all_future).imp φ.all_future :=
    rce_imp φ φ.all_future
  -- Step 3: Compose
  exact imp_trans step1 step2
```

### Task 2: Composition Lemma (1 theorem)

**Insert location**: After decomposition lemmas

```lean
/--
Composition: `⊢ (Hφ ∧ (φ ∧ Gφ)) → △φ` (components imply always).

This is trivial by definitional equality since `always φ = Hφ ∧ (φ ∧ Gφ)`.
-/
theorem past_present_future_to_always (φ : Formula) :
    ⊢ (φ.all_past.and (φ.and φ.all_future)).imp φ.always := by
  -- Definitional equality: always φ = Hφ ∧ (φ ∧ Gφ)
  exact identity (φ.all_past.and (φ.and φ.all_future))
```

### Task 3: Replace `always_dni` Axiom (1 theorem replacement)

**Current location**: Line 138 in Bridge.lean
```lean
axiom always_dni (φ : Formula) : ⊢ φ.always.imp φ.neg.neg.always
```

**Replace with theorem**:
```lean
/--
Derived theorem: DNI distributes over always.

From `always φ → always (¬¬φ)`, we can derive the temporal analog of double negation introduction.

**Derivation Strategy**:
1. Decompose `△φ` into `Hφ ∧ φ ∧ Gφ`
2. Apply `dni` to `φ`: `φ → ¬¬φ`
3. Apply `past_k_dist` and `future_k_dist` to get `Hφ → H(¬¬φ)` and `Gφ → G(¬¬φ)`
4. Recombine: `H(¬¬φ) ∧ ¬¬φ ∧ G(¬¬φ) = △(¬¬φ)`
-/
theorem always_dni (φ : Formula) : ⊢ φ.always.imp φ.neg.neg.always := by
  -- Step 1: Get DNI for φ
  have dni_phi : ⊢ φ.imp φ.neg.neg := dni φ

  -- Step 2: Lift through past operator
  have past_lift : ⊢ φ.all_past.imp φ.neg.neg.all_past := by
    have pk : ⊢ (φ.imp φ.neg.neg).all_past.imp (φ.all_past.imp φ.neg.neg.all_past) :=
      past_k_dist φ φ.neg.neg
    have past_dni : ⊢ (φ.imp φ.neg.neg).all_past :=
      Derivable.temporal_k [] _ (Derivable.temporal_duality _ dni_phi)
    exact Derivable.modus_ponens [] _ _ pk past_dni

  -- Step 3: Present is just dni_phi

  -- Step 4: Lift through future operator
  have future_lift : ⊢ φ.all_future.imp φ.neg.neg.all_future := by
    have fk : ⊢ (φ.imp φ.neg.neg).all_future.imp (φ.all_future.imp φ.neg.neg.all_future) :=
      future_k_dist φ φ.neg.neg
    have future_dni : ⊢ (φ.imp φ.neg.neg).all_future :=
      Derivable.temporal_k [] _ dni_phi
    exact Derivable.modus_ponens [] _ _ fk future_dni

  -- Step 5: Decompose always φ and apply lifts
  have to_past : ⊢ φ.always.imp φ.all_past := always_to_past φ
  have to_present : ⊢ φ.always.imp φ := always_to_present φ
  have to_future : ⊢ φ.always.imp φ.all_future := always_to_future φ

  have past_comp : ⊢ φ.always.imp φ.neg.neg.all_past := imp_trans to_past past_lift
  have present_comp : ⊢ φ.always.imp φ.neg.neg := imp_trans to_present dni_phi
  have future_comp : ⊢ φ.always.imp φ.neg.neg.all_future := imp_trans to_future future_lift

  -- Step 6: Combine into nested conjunction
  have present_future : ⊢ φ.always.imp (φ.neg.neg.and φ.neg.neg.all_future) :=
    combine_imp_conj present_comp future_comp
  have all_three : ⊢ φ.always.imp (φ.neg.neg.all_past.and (φ.neg.neg.and φ.neg.neg.all_future)) :=
    combine_imp_conj past_comp present_future

  -- Step 7: Result is definitionally equal to always (¬¬φ)
  exact all_three
```

### Task 4: Replace `always_dne` Axiom (1 theorem replacement)

**Current location**: Line 204 in Bridge.lean
```lean
axiom always_dne (φ : Formula) : ⊢ φ.neg.neg.always.imp φ.always
```

**Replace with theorem**:
```lean
/--
Derived theorem: DNE distributes over always.

From `always (¬¬φ) → always φ`, we can derive the temporal analog of double negation elimination.

**Derivation Strategy**: Mirror of always_dni but using `dne` instead of `dni`.
-/
theorem always_dne (φ : Formula) : ⊢ φ.neg.neg.always.imp φ.always := by
  -- Step 1: Get DNE for φ
  have dne_phi : ⊢ φ.neg.neg.imp φ := dne φ

  -- Step 2: Lift through past operator
  have past_lift : ⊢ φ.neg.neg.all_past.imp φ.all_past := by
    have pk : ⊢ (φ.neg.neg.imp φ).all_past.imp (φ.neg.neg.all_past.imp φ.all_past) :=
      past_k_dist φ.neg.neg φ
    have past_dne : ⊢ (φ.neg.neg.imp φ).all_past :=
      Derivable.temporal_k [] _ (Derivable.temporal_duality _ dne_phi)
    exact Derivable.modus_ponens [] _ _ pk past_dne

  -- Step 3: Present is just dne_phi

  -- Step 4: Lift through future operator
  have future_lift : ⊢ φ.neg.neg.all_future.imp φ.all_future := by
    have fk : ⊢ (φ.neg.neg.imp φ).all_future.imp (φ.neg.neg.all_future.imp φ.all_future) :=
      future_k_dist φ.neg.neg φ
    have future_dne : ⊢ (φ.neg.neg.imp φ).all_future :=
      Derivable.temporal_k [] _ dne_phi
    exact Derivable.modus_ponens [] _ _ fk future_dne

  -- Step 5: Decompose always (¬¬φ) and apply lifts
  have to_past : ⊢ φ.neg.neg.always.imp φ.neg.neg.all_past := always_to_past φ.neg.neg
  have to_present : ⊢ φ.neg.neg.always.imp φ.neg.neg := always_to_present φ.neg.neg
  have to_future : ⊢ φ.neg.neg.always.imp φ.neg.neg.all_future := always_to_future φ.neg.neg

  have past_comp : ⊢ φ.neg.neg.always.imp φ.all_past := imp_trans to_past past_lift
  have present_comp : ⊢ φ.neg.neg.always.imp φ := imp_trans to_present dne_phi
  have future_comp : ⊢ φ.neg.neg.always.imp φ.all_future := imp_trans to_future future_lift

  -- Step 6: Combine into nested conjunction
  have present_future : ⊢ φ.neg.neg.always.imp (φ.and φ.all_future) :=
    combine_imp_conj present_comp future_comp
  have all_three : ⊢ φ.neg.neg.always.imp (φ.all_past.and (φ.and φ.all_future)) :=
    combine_imp_conj past_comp present_future

  -- Step 7: Result is definitionally equal to always φ
  exact all_three
```

## Required Imports

Ensure these are imported at the top of Bridge.lean:
```lean
import Logos.Core.Theorems.Propositional  -- For lce_imp, rce_imp
```

Check if this import already exists. If not, add it after the existing imports.

## Verification Steps

After each task:
1. Run `lake build Logos.Core.Theorems.Perpetuity.Bridge`
2. Check for compilation errors
3. Verify no `sorry` markers remain
4. Run `lake test` to ensure no regressions

## Success Criteria

- [ ] 4 new theorems added (3 decomposition + 1 composition)
- [ ] 2 axioms replaced with theorems (`always_dni`, `always_dne`)
- [ ] Zero `sorry` markers in modified code
- [ ] `lake build` succeeds
- [ ] `lake test` passes
- [ ] Axiom count in Bridge.lean reduced by 2

## Notes

- The decomposition lemmas are straightforward applications of existing conjunction elimination
- The DNI/DNE derivations follow a clear pattern: decompose → lift → compose
- The `temporal_k` rule is used to lift theorems into temporal operators
- The `temporal_duality` rule is used for the past operator (mirror of future)
