# Research Report: Frame Class Infrastructure and Density Axiom Implementation Path

**Task**: #107 — Chain design diagnostics for representation theorem
**Artifact**: 09_teammate-b-findings.md
**Date**: 2026-04-23
**Focus**: Frame class infrastructure, density axiom implementation path, soundness obligations

---

## Key Findings

### 1. Frame Class Infrastructure: What Exists

The codebase has a **complete, multi-layered frame class infrastructure** that is largely sorry-free.

**Typeclass layer** (`FrameConditions/FrameClass.lean`):
- `LinearTemporalFrame D` — marker class, requires `AddCommGroup D + LinearOrder D + IsOrderedAddMonoid D`
- `SerialFrame D` — extends with `Nontrivial D + NoMaxOrder D + NoMinOrder D`
- `DenseTemporalFrame D` — extends with `DenselyOrdered D`; has `DenseTemporalFrame.mk'` constructor
- `DiscreteTemporalFrame D` — extends with `SuccOrder D + PredOrder D + IsSuccArchimedean D`
- Concrete instances: `Int` is a `DiscreteTemporalFrame`; dense frames use quotient constructions

**Validity layer** (`Semantics/Validity.lean`):
- `valid φ` — quantifies over all `D : Type` with `LinearOrderedAddCommGroup` structure
- `valid_dense φ` — restricts to `DenselyOrdered D` frame types
- `valid_discrete φ` — restricts to `SuccOrder D + PredOrder D + IsSuccArchimedean D`
- `valid_over D φ` — validity restricted to specific domain `D`
- All three predicates are used in the soundness architecture

**ProofSystem/Axioms.lean** frame class tagging:
```lean
inductive FrameClass where
  | Base
  | Dense
  | Discrete
  deriving Repr, DecidableEq, Inhabited

def Axiom.frameClass {φ : Formula} : Axiom φ → FrameClass
  | _ => .Base   -- ALL current BX axioms are Base

def Axiom.isDenseCompatible {φ : Formula} : Axiom φ → Prop
  | _ => True    -- All are True (no density axiom in the system)

def Axiom.isDiscreteCompatible {φ : Formula} : Axiom φ → Prop
  | _ => True    -- All are True (no density axiom to exclude)
```

**Critical observation**: The `FrameClass.Dense` and `FrameClass.Discrete` constructors exist as extension points, but no `Axiom` constructor currently maps to them. The `isDenseCompatible` and `isDiscreteCompatible` functions both return `True` for all constructors because the density axiom DN is NOT in the current `Axiom` inductive type.

### 2. How Density Axioms Would Be Added

**The density axiom formulation in the codebase** is:
- **GGφ → Gφ** (the `all_future` version) — this is what `density_valid` and `axiom_density_valid` prove
- **Fφ → FFφ** (the `some_future` version) — this is what `density_sound_dense` re-exports

Both formulations are semantically equivalent under strict (irreflexive) semantics. The codebase uses the `all_future` version (`φ.all_future.all_future.imp φ.all_future`) in soundness lemmas, and the `some_future` version (`φ.some_future.imp φ.some_future.some_future`) in `DenseSoundness.lean`.

**If a density axiom constructor were added**, the minimum changes would be:

1. **Add constructor to `Axiom` inductive** in `ProofSystem/Axioms.lean`:
   ```lean
   | density (φ : Formula) :
       Axiom (φ.all_future.all_future.imp φ.all_future)
   ```
   (Past version would be `past_density`)

2. **Update `Axiom.frameClass`** to return `.Dense` for the new constructor:
   ```lean
   def Axiom.frameClass {φ : Formula} : Axiom φ → FrameClass
     | density _ => .Dense
     | _ => .Base
   ```

3. **Update `isDenseCompatible`** — keep returning `True` for density (it IS dense-compatible)

4. **Update `isDiscreteCompatible`** — return `False` for the density constructor:
   ```lean
   def Axiom.isDiscreteCompatible {φ : Formula} : Axiom φ → Prop
     | density _ => False
     | _ => True
   ```

5. **Update `DerivationTree.isDiscreteCompatible`** in `ProofSystem/Derivation.lean` — the recursive case already handles this correctly via `h.isDiscreteCompatible`.

6. **Add a new case to `axiom_valid_dense`** in `Metalogic/Soundness.lean`:
   ```lean
   | density φ => exact density_valid φ
   ```
   (This calls the already-complete `density_valid` theorem.)

7. **Update `axiom_base_valid`** — the density axiom should NOT be in the base case (it requires DenselyOrdered).

### 3. Soundness Obligations

**How many new lemmas**: The `density_valid` theorem already exists and is **sorry-free**:
```lean
theorem density_valid (φ : Formula) :
    valid_dense ((φ.all_future.all_future).imp φ.all_future) := by
  intro T _ _ _ h_dense _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_GG s hts
  obtain ⟨r, htr, hrs⟩ := exists_between hts
  exact h_GG r htr s hrs
```

The proof uses `exists_between` from Mathlib (the `DenselyOrdered` instance provides this). It is already complete and correct.

**What would need updating for soundness**:
- `axiom_valid_dense` in `Soundness.lean`: Add one case for `| density φ => exact density_valid φ`
- `axiom_locally_valid` in `SoundnessLemmas.lean`: Add one case for the density axiom
- The `isDiscreteCompatible` theorems would need updating: `Axiom.isDiscreteCompatible_iff_frameClass` and `Axiom.discreteness_forward_not_dense_compatible`

**No new semantic validity lemmas are needed** — the `density_valid` proof already exists in `Soundness.lean` (around line 411-423).

**Soundness architecture impact**: The existing `soundness_dense` theorem in `Metalogic/Soundness.lean` is already structured to handle derivations using `isDenseCompatible`. Adding a density axiom with `isDenseCompatible = True` would flow through naturally. The `soundness_discrete` theorem would exclude density via `isDiscreteCompatible = False`.

### 4. Existing `density_derivable` and `refl_F` Lemmas

In `Theorems/TemporalDerived.lean`, these sorry'd theorems exist:

```lean
-- density_derivable (line 133): GGφ → Gφ — sorry'd
def density_derivable (φ : Formula) :
    ⊢ φ.all_future.all_future.imp φ.all_future := by
  sorry

-- past_density_derivable (line 142): HHφ → Hφ — sorry'd
def past_density_derivable (φ : Formula) :
    ⊢ φ.all_past.all_past.imp φ.all_past := by
  sorry

-- refl_F (line 431): α → Fα — sorry'd
noncomputable def refl_F (α : Formula) :
    ⊢ α.imp α.some_future := by
  sorry

-- refl_P (line 440): α → Pα — sorry'd
noncomputable def refl_P (α : Formula) :
    ⊢ α.imp α.some_past := by
  sorry

-- G_bot_absurd (line 63): G(⊥) → ⊥ — sorry'd
-- H_bot_absurd (line 72): H(⊥) → ⊥ — sorry'd
-- G_implies_topUntil (line 164): G(a) → ⊤ U a — sorry'd
-- psi_imp_until (line 232): ψ → (φ U ψ) — sorry'd
-- psi_imp_since (line 242): ψ → (φ S ψ) — sorry'd
```

**Important**: The comments in the source file explain WHY these are sorry'd — they are NOT derivable from the BX axiom system under irreflexive semantics. The key issue:

- `density_derivable` is sorry'd because under irreflexive semantics, GGφ → Gφ requires DenselyOrdered and cannot be derived from the BX axioms alone (which are sound on all linear orders including non-dense ones).
- `refl_F` is sorry'd because under irreflexive semantics, α → F(α) is NOT valid — the current time does not witness F(α) since F requires strict future.
- `psi_imp_until` is sorry'd because ψ → (φ U ψ) requires reflexive Until.

**These sorry'd theorems would become provable if**: (a) a density axiom constructor were added to the proof system (for `density_derivable`), and (b) seriality axioms properly allowed derivation (for `G_bot_absurd`). However, `refl_F` and `psi_imp_until` require the semantics to be reflexive or require additional axioms beyond density.

**Downstream cascade**: `refl_F` is used in `until_F_expansion` and `since_P_expansion`, which are used in the canonical completeness construction. These sorry chains propagate up through the Chronicle construction.

### 5. Parametric Representation Infrastructure

**What exists** in `Metalogic/Algebraic/ParametricRepresentation.lean`:
The parametric representation theorem is designed to support different frame classes:

| Extension | D | Constraint |
|-----------|---|------------|
| Base | Int | `AddCommGroup + LinearOrder + IsOrderedAddMonoid` |
| Dense | Rat | `+ DenselyOrdered` |
| Discrete | Int | `+ SuccOrder` |

The parametric infrastructure already anticipates dense and discrete instantiations. The representation theorem is "conditional on having a temporally coherent BFMCS over D" — for dense completeness, the BFMCS would need to use a dense domain D (like Rat) with `DenselyOrdered` instances.

The chronicle construction in `BXCanonical/Chronicle/` uses `Rat` as its domain (from `ChronicleToCountermodel.lean`), which is already dense-compatible. The BX axiom system's density axiom would need to be reflected in the MCS properties used during the chronicle construction.

### 6. How `bx_completeness` Relates to Frame Classes

`bx_completeness` in `BXCanonical/Completeness.lean` is stated for **`valid φ`** (the universal notion), not `valid_dense` or `valid_discrete`:

```lean
theorem bx_completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```

This means `bx_completeness` is about the base logic — the BX axiom system without density or discreteness extensions. It uses the chronicle construction over `Rat`, which happens to be dense, but the completeness statement does not require or assume density.

**If density were added to the proof system**, a separate `bx_completeness_dense` theorem would be needed, stated as:
```lean
theorem bx_completeness_dense (φ : Formula) :
    valid_dense φ → Nonempty (DerivationTree [] φ)
```

This would require the BXCanonical construction to use density-aware MCS properties (MCS closed under the density axiom `density`).

---

## Recommended Approach: Concrete Code Changes

### Option 1: Add Density Axiom Constructor (Clean Extension)

This is the correct approach if the goal is to axiomatize dense linear order semantics.

**Step 1**: Add constructor to `Axiom` in `ProofSystem/Axioms.lean`:
```lean
| density (φ : Formula) :
    Axiom (φ.all_future.all_future.imp φ.all_future)
| past_density (φ : Formula) :
    Axiom (φ.all_past.all_past.imp φ.all_past)
```

**Step 2**: Update `Axiom.frameClass` (same file):
```lean
def Axiom.frameClass {φ : Formula} : Axiom φ → FrameClass
  | density _ => .Dense
  | past_density _ => .Dense
  | _ => .Base
```

**Step 3**: Update `Axiom.isDiscreteCompatible`:
```lean
def Axiom.isDiscreteCompatible {φ : Formula} : Axiom φ → Prop
  | density _ => False
  | past_density _ => False
  | _ => True
```

**Step 4**: Add cases to `axiom_valid_dense` in `Metalogic/Soundness.lean`:
```lean
| density φ => exact density_valid φ
| past_density φ =>
    intro T _ _ _ h_dense _ F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro h_HH s hst
    obtain ⟨r, hsr, hrt⟩ := exists_between hst
    exact h_HH r hrt s hsr
```

(The past version uses `exists_between hst` symmetrically.)

**Step 5**: Update the related theorems in `Axioms.lean` that have become false:
- `Axiom.isDiscreteCompatible_iff_frameClass` needs updating since now density → frameClass = Dense → isDiscreteCompatible = False

**Step 6**: Prove `density_derivable` in `TemporalDerived.lean` using the new axiom:
```lean
def density_derivable (φ : Formula) :
    ⊢ φ.all_future.all_future.imp φ.all_future :=
  DerivationTree.axiom [] _ (Axiom.density φ)
```

### Note on Blocked Downstream Sorry's

Adding the density axiom does **not** directly unblock `refl_F`, `psi_imp_until`, or `G_bot_absurd` because those require the semantics to be reflexive. These lemmas are simply **not provable** in the current irreflexive BX system. Their sorry annotations correctly document this mathematical fact.

---

## Evidence

1. `Axiom.isDenseCompatible` in `ProofSystem/Axioms.lean` (lines 289-292): Returns `True` for all constructors — confirms no density axiom exists yet.

2. `density_valid` in `Metalogic/Soundness.lean` (lines 411-423): Complete sorry-free proof — soundness obligation is already met.

3. `axiom_density_valid` in `Metalogic/SoundnessLemmas.lean` (lines 1058-1067): Second complete sorry-free proof — both semantic validity routes are covered.

4. `density_derivable` in `Theorems/TemporalDerived.lean` (line 133): Sorry'd with comment explaining it requires density, not just BX1.

5. `valid_dense` in `Semantics/Validity.lean` (lines 162-168): Definition exists and is used throughout.

6. `DenseSoundness.lean` re-exports `density_valid` as `density_sound_dense` (line 38-40): Infrastructure is ready.

7. `bx_completeness` in `BXCanonical/Completeness.lean` (line 128): States `valid φ`, not `valid_dense φ` — confirms it's for base logic.

8. `FrameClass.Dense` constructor in `ProofSystem/Axioms.lean` (lines 275-279): Exists as an extension point but unused.

---

## Confidence Level

**High confidence** on all findings. The codebase is well-structured with clear separation of concerns between base/dense/discrete frame classes. The density axiom infrastructure (validity proofs, typeclass hierarchy, frame class tagging) is complete and ready — the only missing piece is the `Axiom` constructor itself.

**Key architectural insight**: The density axiom is intentionally NOT in the BX system because BX axioms are designed to be sound on ALL linear orders (including non-dense ones). Adding density as an optional extension is the architecturally correct approach, and the codebase is already designed to accommodate this extension cleanly.
