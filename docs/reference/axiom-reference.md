# Bimodal Axiom Reference

Complete reference for TM (Tense and Modality) axiom schemas.

## Axiom Categories

TM logic uses **45 axiom constructors** organized into **four layers**. The layer of each
constructor is given by `Axiom.minFrameClass` (`FormalSystem/ProofSystem/Axioms.lean:588`),
which is the authoritative source -- re-derive from it rather than from this table:

| Layer | Count | Description |
|-------|-------|-------------|
| Base | 37 | Valid on all linear temporal frames |
| Dense | 2 | Valid on densely ordered frames |
| Discrete | 3 | Valid on discrete (SuccArchimedean) frames |
| Dedekind | 3 | Valid on dense Dedekind-complete frames |
| **Total** | **45** | |

The four classes form a partial order rather than a flat list. `Dedekind` sits strictly
**above** `Dense` rather than being a fourth incomparable leaf: Reynolds 1992 (printed p.168)
lists density and no-end-points axioms as part of the axiomatization US/R for real flow, so a
Dedekind derivation must be allowed to use the density axioms. Dense and Discrete are
incomparable, as are Discrete and Dedekind. The governing invariant is
`ax.minFrameClass ≤ fc`: an axiom may appear in a derivation parameterized by `fc` only when
its minimum frame class is at most `fc`.

```
              Dedekind
                 ↑
    Dense --------'      Discrete
      ↑                     ↑
       \___________________/
                |
               Base
```

### Base Axiom Categories (37)

| Category | Count | Constructors |
|----------|-------|--------------|
| Propositional | 4 | `prop_k`, `prop_s`, `ex_falso`, `peirce` |
| Modal S5 | 5 | `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist` |
| Seriality | 2 | `serial_future`, `serial_past` |
| Until/Since monotonicity | 4 | `left_mono_until_G`, `left_mono_since_H`, `right_mono_until`, `right_mono_since` |
| Connectedness | 2 | `connect_future`, `connect_past` |
| Enrichment | 2 | `enrichment_until`, `enrichment_since` |
| Self-accumulation | 2 | `self_accum_until`, `self_accum_since` |
| Absorption | 2 | `absorb_until`, `absorb_since` |
| Linearity | 4 | `linear_until`, `linear_since`, `temp_linearity`, `temp_linearity_past` |
| F/P bridges | 4 | `until_F`, `since_P`, `F_until_equiv`, `P_since_equiv` |
| Modal-temporal interaction | 1 | `modal_future` |
| Discrete-shaped, Base-valid | 5 | `discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`, `discrete_propagate_bwd`, `discrete_box_necessity` |

**The temporal layer is Burgess-Xu until/since**, not a T4/TA/TL/TK basis. `untl` and `snce`
are the primitive binary temporal constructors (`FormalSystem/Syntax/Formula.lean:96`, `:106`);
G, H, F, and P are all *derived* forms. Note also that `temp_k_dist` and `temp_4` are **derived
theorems**, not axioms -- they are `temporalKDistDerived` and `temporal4Derived` in
`FormalSystem/Theorems/TemporalDerived.lean` (see `Axioms.lean:96-98`).

### Extension Axioms

| Layer | Constructors | Frame condition |
|-------|--------------|-----------------|
| Dense (2) | `density` (GGφ → Gφ), `dense_indicator` (¬U(⊤,⊥)) | `DenselyOrdered` |
| Discrete (3) | `prior_UZ`, `prior_SZ`, `z1` | `SuccArchimedean` / `PredArchimedean` |
| Dedekind (3) | `prior_U_gap`, `prior_S_gap`, `sep` | dense + Dedekind-complete |

The Dedekind layer is Reynolds's definable-gap axiom set (Reynolds 1992, printed p.168). Its
soundness target is the *dense* Dedekind predicate `ValidDedekindDense`, not the density-free
`ValidDedekind`, because `density` and `dense_indicator` are admissible at `.Dedekind` and both
are false on ℤ. See `FormalSystem/ProofSystem/Axioms.lean:461-517` for the full argument.

## Propositional Axioms

### P1 (K-Axiom for Implication)

**Schema**: `⊢ φ → (ψ → φ)`

**Lean**:
```lean
theorem theorem_1 (A B : Formula) : ⊢ A.imp (B.imp A)
```

**Example**:
```lean
example (p q : Formula) : ⊢ p.imp (q.imp p) := theorem_1 p q
```

### P2 (S-Axiom)

**Schema**: `⊢ (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`

**Lean**:
```lean
theorem theorem_2 (A B C : Formula) :
    ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C))
```

### P3 (Contraposition)

**Schema**: `⊢ (¬φ → ¬ψ) → (ψ → φ)`

**Lean**:
```lean
-- Available as contraposition theorem
theorem contraposition (A B : Formula) :
    ⊢ (A.neg.imp B.neg).imp (B.imp A)
```

## Modal Axioms

### MT (Modal T)

**Schema**: `⊢ □φ → φ`
**Meaning**: What is necessary is true (reflexivity of accessibility).

**Lean**:
```lean
theorem modal_t (φ : Formula) : ⊢ φ.box.imp φ
```

**Example**:
```lean
example (p : Formula) : ⊢ p.box.imp p := modal_t p
```

### M4 (Modal 4)

**Schema**: `⊢ □φ → □□φ`
**Meaning**: Necessity iterates (transitivity of accessibility).

**Lean**:
```lean
theorem modal_4 (φ : Formula) : ⊢ φ.box.imp φ.box.box
```

### MB (Modal B)

**Schema**: `⊢ φ → □◇φ`
**Meaning**: What is true is necessarily possible (symmetry).

**Lean**:
```lean
theorem modal_b (φ : Formula) : ⊢ φ.imp φ.diamond.box
```

### MK (Modal K, Distribution)

**Schema**: `⊢ □(φ → ψ) → (□φ → □ψ)`
**Meaning**: Necessity distributes over implication.

**Lean**:
```lean
theorem modal_k (φ ψ : Formula) : ⊢ (φ.imp ψ).box.imp (φ.box.imp ψ.box)
```

## Temporal Axioms

The temporal layer is stated over the primitive binary connectives `untl` (until) and `snce`
(since). Each entry below is a constructor of `inductive Axiom`
(`FormalSystem/ProofSystem/Axioms.lean`).

### Monotonicity

**`left_mono_until_G`**: `⊢ △(φ → χ) → (U(φ,ψ) → U(χ,ψ))`
**`right_mono_until`**: `⊢ △(φ → ψ) → (U(χ,φ) → U(χ,ψ))`
**`left_mono_since_H`** / **`right_mono_since`**: the mirror-image `snce` forms.

```lean
| left_mono_until_G (φ χ ψ : Formula) :
    Axiom ((φ.imp χ).allFuture.imp ((Formula.untl φ ψ).imp (Formula.untl χ ψ)))
```

### Connectedness

**`connect_future`**: `⊢ φ → △▽φ` -- what is the case will always have been the case.
**`connect_past`**: `⊢ φ → ▽△φ` -- the mirror image.

```lean
| connect_future (φ : Formula) : Axiom (φ.imp (φ.somePast.allFuture))
| connect_past   (φ : Formula) : Axiom (φ.imp (φ.someFuture.allPast))
```

### Enrichment

**`enrichment_until`**: `⊢ (p ∧ U(φ,ψ)) → U(φ, ψ ∧ S(φ,p))` -- an until-claim can be enriched
with a since-claim recording the present. `enrichment_since` is the mirror image.

### Self-accumulation and absorption

**`self_accum_until`**: `⊢ U(φ,ψ) → U(φ ∧ U(φ,ψ), ψ)`
**`absorb_until`**: `⊢ U(φ, φ ∧ U(φ,ψ)) → U(φ,ψ)`
Both have `snce` mirror images (`self_accum_since`, `absorb_since`).

### Linearity

**`linear_until`** / **`linear_since`**: two until-claims from the same point must be ordered.
**`temp_linearity`**: `⊢ (Fφ ∧ Fψ) → (F(φ ∧ ψ) ∨ F(φ ∧ Fψ) ∨ F(ψ ∧ Fφ))`
**`temp_linearity_past`**: the mirror image.

### F/P bridges

**`until_F`**: `⊢ U(φ,ψ) → Fψ`
**`since_P`**: `⊢ S(φ,ψ) → Pψ`
**`F_until_equiv`**: `⊢ Fφ → U(⊤,φ)`
**`P_since_equiv`**: `⊢ Pφ → S(⊤,φ)`

The last two are why F and P are *derived* rather than primitive: `someFuture` and `somePast`
are definable from `untl`/`snce` (`FormalSystem/Syntax/Formula.lean:147`, `:157`).

### Seriality

**`serial_future`** / **`serial_past`**: `⊢ F⊤` and `⊢ P⊤` -- no end points.

### Derived, not axiomatic

`temp_k_dist` (temporal K-distribution) and `temp_4` are **not** axioms. They are derived
theorems `temporalKDistDerived` and `temporal4Derived` in
`FormalSystem/Theorems/TemporalDerived.lean`.

## Interaction Axioms

### `modal_future` (the sole interaction axiom)

**Schema**: `⊢ □φ → □△φ`
**Meaning**: What is necessary is necessarily always the case.

**Lean**:
```lean
| modal_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.allFuture φ)))
```

This is the **only** modal-temporal interaction axiom. The perpetuity principles P1-P6
(`FormalSystem/Theorems/Perpetuity/`) are derived from it, not postulated. Temporal duality
(`△φ ↔ ¬▽¬φ`) is likewise definitional rather than axiomatic: `allFuture` is defined in terms
of `untl` in `FormalSystem/Syntax/Formula.lean`.

## Extension Layer Axioms

### Dense (2)

```lean
| density (φ : Formula) : Axiom (φ.allFuture.allFuture.imp φ.allFuture)   -- △△φ → △φ
| dense_indicator : Axiom (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg  -- ¬U(⊥,⊤)
```

### Discrete (3)

```lean
| prior_UZ (φ : Formula) : Axiom (φ.someFuture.imp (Formula.untl φ.neg φ))
| prior_SZ (φ : Formula) : Axiom (φ.somePast.imp (Formula.snce φ.neg φ))
| z1 (φ : Formula) :
    Axiom ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture))
```

### Dedekind (3)

Reynolds's definable-gap axioms (Reynolds 1992, printed p.168):

```lean
| prior_U_gap (φ : Formula) :
    Axiom ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
           (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg))))
| prior_S_gap (φ : Formula) : -- the mirror image, with snce and kMinus
| sep (φ : Formula) :         -- the separation axiom
```

These are the axioms that make `completeness_dedekind`
(`FormalSystem/Metalogic/StrongCompleteness.lean:469`) available for the real flow.

## Inference Rules

### Modus Ponens (MP)

**Rule**: From `⊢ φ → ψ` and `⊢ φ`, derive `⊢ ψ`

**Lean**:
```lean
DerivationTree.modusPonens : DerivationTree Γ (φ.imp ψ) →
    DerivationTree Γ φ → DerivationTree Γ ψ
```

### Necessitation (N)

**Rule**: From `⊢ φ`, derive `⊢ □φ`

**Lean**:
```lean
DerivationTree.necessitation : DerivationTree [] φ → DerivationTree [] φ.box
```

**Note**: Only applies when `φ` is a theorem (derived from empty context).

### Temporal Necessitation (TN)

**Rule**: From `⊢ φ`, derive `⊢ △φ`

**Lean**:
```lean
DerivationTree.temporalNecessitation : DerivationTree [] φ →
    DerivationTree [] φ.allFuture
```

### The full rule set

`DerivationTree` (`FormalSystem/ProofSystem/Derivation.lean`) has **7** constructors:
`axiom`, `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`,
`temporal_duality`, and `weakening`.

## Axiom Application Examples

### Example 1: Derive `□p → ◇p`

```lean
-- Strategy: □p → p (MT), p → ◇p (from B contraposed)
example (p : Formula) : ⊢ p.box.imp p.diamond := by
  have h1 := modal_t p         -- □p → p
  have h2 := dia_intro p       -- p → ◇p (derived)
  exact impTrans h1 h2
```

### Example 2: Derive `□(p → q) → □p → □q`

```lean
-- Direct application of Modal K
example (p q : Formula) : ⊢ (p.imp q).box.imp (p.box.imp q.box) :=
  modal_k p q
```

### Example 3: Use Necessitation

```lean
-- From theorem (p → p), derive □(p → p)
example (p : Formula) : ⊢ (p.imp p).box := by
  have h := imp_refl p           -- ⊢ p → p
  exact DerivationTree.necessitation h
```

## See Also

- [Bimodal Syntax](../../FormalSystem/Syntax/Formula.lean) - Formula constructors
- [Bimodal ProofSystem](../../FormalSystem/ProofSystem/Axioms.lean) - Axiom definitions
- [Proof Patterns](../user-guide/proof-patterns.md) - How to use axioms
