# Bimodal Axiom Reference

Complete reference for TM (Tense and Modality) axiom schemas.

## Axiom Categories

TM logic uses **29 axiom constructors**: exactly the paper's primitive axiom schemata
(`def:S5`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:BX-r`; see
`docs/reference/paper-definitions-of-record.md`). Every other schema the tree used to take as
primitive -- the twelve past mirrors of the BX temporal group, the S5 schemata 4 and B, and the
past mirrors of UZ and PU -- is now a **derived theorem** (see
[Derived schemata](#derived-schemata) below). The layer of each constructor is given by
`Axiom.minFrameClass` (`FormalSystem/ProofSystem/Axioms.lean`), which is the authoritative
source -- re-derive from it rather than from this table:

| Layer | Count | Description |
|-------|-------|-------------|
| Base | 23 | Valid on all linear temporal frames |
| Dense | 2 | Valid on densely ordered frames |
| ZTime | 2 | Valid on discrete (SuccArchimedean) frames |
| RTime | 2 | Valid on dense Dedekind-complete frames |
| **Total** | **29** | |

The four classes form a partial order rather than a flat list. `RTime` sits strictly
**above** `Dense` rather than being a fourth incomparable leaf: Reynolds 1992 (printed p.168)
lists density and no-end-points axioms as part of the axiomatization US/R for real flow, so a
RTime derivation must be allowed to use the density axioms. Dense and ZTime are
incomparable, as are ZTime and RTime. The governing invariant is
`ax.minFrameClass ≤ fc`: an axiom may appear in a derivation parameterized by `fc` only when
its minimum frame class is at most `fc`.

```
              RTime
                 ↑
    Dense --------'      ZTime
      ↑                     ↑
       \___________________/
                |
               Base
```

### Base Axiom Categories (23)

| Category | Paper keys | Constructors |
|----------|------------|--------------|
| Propositional | CPL | `prop_k`, `prop_s`, `ex_falso`, `peirce` |
| Modal S5 | MT, M5, MK | `modal_t`, `modal_5_collapse`, `modal_k_dist` |
| Seriality | TS | `serial_future` |
| Until/Since monotonicity | UG, UC | `left_mono_until_G`, `right_mono_until` |
| Connectedness | TC | `connect_future` |
| Enrichment | SU | `enrichment_until` |
| Self-accumulation | UF | `self_accum_until` |
| Absorption | UI | `absorb_until` |
| Linearity | CN, TL | `linear_until`, `temp_linearity` |
| F bridges | UE, UT | `until_F`, `F_until_equiv` |
| Modal-temporal interaction | MF | `modal_future` |
| Uniformity (discrete-shaped, Base-valid) | NP, NF, NA, NB | `discrete_symm_fwd`, `discrete_propagate_fwd`, `discrete_propagate_bwd`, `discrete_box_necessity` |

**The temporal layer is Burgess-Xu until/since**, not a T4/TA/TL/TK basis. `untl` and `snce`
are the primitive binary temporal constructors (`FormalSystem/Syntax/Formula.lean`);
G, H, F, and P are all *derived* forms. Note also that `temp_k_dist` and `temp_4` are **derived
theorems**, not axioms -- they are `temporalKDistDerived` and `temporal4Derived` in
`FormalSystem/Theorems/TemporalDerived.lean` (see `Axioms.lean`).

### Extension Axioms

| Layer | Constructors | Frame condition |
|-------|--------------|-----------------|
| Dense (2) | `density` (DN, GGφ → Gφ), `dense_indicator` (NN, ¬U(⊤,⊥)) | `DenselyOrdered` |
| ZTime (2) | `prior_UZ` (UZ), `z1` (Z1) | `SuccArchimedean` / `PredArchimedean` |
| RTime (2) | `prior_U_gap` (PU), `sep` (SEP) | dense + Dedekind-complete |

The RTime layer is Reynolds's definable-gap axiom set (Reynolds 1992, printed p.168), less the
past form of Prior-U, which is derived. Its soundness target is the *dense* RTime predicate
`ValidRTime`, not the density-free `ValidComplete`, because `density` and `dense_indicator` are
admissible at `.RTime` and both are false on ℤ. See `FormalSystem/ProofSystem/Axioms.lean` for
the full argument.

### Derived schemata

Each of these was an `Axiom` constructor before the primitive system was aligned with the
paper; each is now a sorry-free, axiom-free definition in namespace
`FormalSystem.ProofSystem.DerivedAxioms`, under the lowerCamelCase form of its old name (`since_P` becomes `sinceP`, `modal_4` becomes `modal4`), with a context-lifted form
`XAt Γ …`. A TR mirror has the same least frame class as its primary, so no frame class needs a
surplus axiom.

| Derived | Statement | Derivation | Defined in |
|---|---|---|---|
| `serialPast` | ⊤ → P⊤ | TR of TS, then `prop_s` | `ProofSystem/DerivedAxioms.lean` |
| `leftMonoSinceH` | H(φ→χ) → (φSψ → χSψ) | TR of UG | `ProofSystem/DerivedAxioms.lean` |
| `rightMonoSince` | H(φ→ψ) → (χSφ → χSψ) | TR of UC | `ProofSystem/DerivedAxioms.lean` |
| `connectPast` | φ → HFφ | TR of TC | `ProofSystem/DerivedAxioms.lean` |
| `enrichmentSince` | p ∧ (φSψ) → φS(ψ ∧ φUp) | TR of SU | `ProofSystem/DerivedAxioms.lean` |
| `selfAccumSince` | φSψ → (φ ∧ φSψ)Sψ | TR of UF | `ProofSystem/DerivedAxioms.lean` |
| `absorbSince` | φS(φ ∧ φSψ) → φSψ | TR of UI | `ProofSystem/DerivedAxioms.lean` |
| `sinceP` | φSψ → Pψ | TR of UE | `ProofSystem/DerivedAxioms.lean` |
| `pSinceEquiv` | Pφ → ⊤Sφ | TR of UT | `ProofSystem/DerivedAxioms.lean` |
| `discreteSymmBwd` | Y⊤ → X⊤ | TR of NP (no transport needed) | `ProofSystem/DerivedAxioms.lean` |
| `priorSZ` | Pφ → ¬φSφ, gated `ZTime ≤ fc` | TR of UZ | `ProofSystem/DerivedAxioms.lean` |
| `priorSGap` | ⊤Sφ ∧ P¬φ → (¬φ ∨ K⁻¬φ)Sφ, gated `RTime ≤ fc` | TR of PU | `ProofSystem/DerivedAxioms.lean` |
| `tempLinearityPast` | TL's past form, historical disjunct order | TR of TL, then `orRotate` twice | `Theorems/Combinators.lean` |
| `linearSince` | CN's past form, left-associated | TR of CN, then `orAssocRev` | `Theorems/Combinators.lean` |
| `modalB` | φ → □◇φ | MT and M5 contraposed, double negation | `Theorems/Combinators.lean` |
| `modal4` | □φ → □□φ | B at □φ, then MN of M5 and MK | `Theorems/Combinators.lean` |
| `tempLinearityLegacy` | TL in the historical order F(φ∧ψ) ∨ (F(φ∧Fψ) ∨ F(Fφ∧ψ)) | TL, then `orRotate` twice | `Theorems/Combinators.lean` |
| `linearUntilLegacy` | CN left-associated `(A ∨ B) ∨ C` | CN, then `orAssocRev` | `Theorems/Combinators.lean` |
| `serialFutureImp` | ⊤ → F⊤ (the historical TS) | TS, then `prop_s` | `ProofSystem/DerivedAxioms.lean` |

Proof steps that used a former constructor now serialize (in the dataset and proof-extractor
outputs) as `time_reflection` over a primitive axiom, or as the short propositional derivation
above, never as an axiom name.

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

### M4 (Modal 4) -- derived

**Schema**: `⊢ □φ → □□φ`
**Meaning**: Necessity iterates (transitivity of accessibility). Not primitive: the paper's
`def:S5` is MK, MT and M5; `DerivedAxioms.modal4` derives it.

**Lean**:
```lean
theorem modal_4 (φ : Formula) : ⊢ φ.box.imp φ.box.box
```

### MB (Modal B) -- derived

**Schema**: `⊢ φ → □◇φ`
**Meaning**: What is true is necessarily possible (symmetry). Not primitive:
`DerivedAxioms.modalB` derives it from MT and M5.

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
(since). Each future-directed entry below is a constructor of `inductive Axiom`
(`FormalSystem/ProofSystem/Axioms.lean`); each past-directed mirror is a derived theorem
obtained by the time-reflection rule TR (see [Derived schemata](#derived-schemata)).

### Monotonicity

**`left_mono_until_G`**: `⊢ △(φ → χ) → (U(φ,ψ) → U(χ,ψ))`
**`right_mono_until`**: `⊢ △(φ → ψ) → (U(χ,φ) → U(χ,ψ))`
**`left_mono_since_H`** / **`right_mono_since`**: the mirror-image `snce` forms (derived by TR).

```lean
| left_mono_until_G (φ χ ψ : Formula) :
    Axiom ((φ.imp χ).allFuture.imp ((Formula.untl φ ψ).imp (Formula.untl χ ψ)))
```

### Connectedness

**`connect_future`**: `⊢ φ → △▽φ` -- what is the case will always have been the case.
**`connect_past`**: `⊢ φ → ▽△φ` -- the mirror image (derived by TR).

```lean
| connect_future (φ : Formula) : Axiom (φ.imp (φ.somePast.allFuture))
```

### Enrichment

**`enrichment_until`**: `⊢ (p ∧ U(φ,ψ)) → U(φ, ψ ∧ S(φ,p))` -- an until-claim can be enriched
with a since-claim recording the present. `enrichment_since` is the mirror image (derived by TR).

### Self-accumulation and absorption

**`self_accum_until`**: `⊢ U(φ,ψ) → U(φ ∧ U(φ,ψ), ψ)`
**`absorb_until`**: `⊢ U(φ, φ ∧ U(φ,ψ)) → U(φ,ψ)`
Both have `snce` mirror images (`self_accum_since`, `absorb_since`), derived by TR.

### Linearity

**`linear_until`** (CN): two until-claims from the same point must be ordered; stated as the
paper's CN with the 3-way disjunction right-associated. `linear_since` is its TR mirror
(left-associated, derived) and `linear_until_legacy` the former left-associated form.
**`temp_linearity`** (TL): `⊢ (Fφ ∧ Fψ) → F(Fφ ∧ ψ) ∨ (F(φ ∧ ψ) ∨ F(φ ∧ Fψ))`, the paper's TL
verbatim. `temp_linearity_legacy` is the former order `F(φ ∧ ψ) ∨ (F(φ ∧ Fψ) ∨ F(Fφ ∧ ψ))`, and
`temp_linearity_past` the past mirror in that order; both are derived.

### F/P bridges

**`until_F`**: `⊢ U(φ,ψ) → Fψ`
**`since_P`**: `⊢ S(φ,ψ) → Pψ` (derived by TR)
**`F_until_equiv`**: `⊢ Fφ → U(⊤,φ)`
**`P_since_equiv`**: `⊢ Pφ → S(⊤,φ)` (derived by TR)

The last two are why F and P are *derived* rather than primitive: `someFuture` and `somePast`
are definable from `untl`/`snce` (`FormalSystem/Syntax/Formula.lean`).

### Seriality

**`serial_future`** (TS): `⊢ F⊤` -- no last point; the paper's statement verbatim.
`serial_past` (`⊢ ⊤ → P⊤`, no first point) is derived by TR, and `serial_future_imp`
(`⊢ ⊤ → F⊤`) is the former statement of TS.

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

### ZTime (2)

`prior_SZ` (`Pφ → S(¬φ, φ)`) is the TR mirror of UZ, derived at every `fc ≥ ZTime`.

```lean
| prior_UZ (φ : Formula) : Axiom (φ.someFuture.imp (Formula.untl φ.neg φ))
| z1 (φ : Formula) :
    Axiom ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture))
```

### RTime (2)

Reynolds's definable-gap axioms (Reynolds 1992, printed p.168); `prior_S_gap` is the TR mirror
of PU, derived at every `fc ≥ RTime`:

```lean
| prior_U_gap (φ : Formula) :
    Axiom ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
           (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg))))
| sep (φ : Formula) :         -- the separation axiom
```

These are the axioms that make `completeness_rtime`
(`FormalSystem/Metalogic/StrongCompleteness.lean`) available for the real flow.

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
`time_reflection`, and `weakening`.

## Paper Key Correspondence (BX temporal group)

The paper's `def:BX` names its base tense logic by `\aitem` keys (TN, TR, TS, TC, TL, UE, UT, UI,
UC, UF, UG, SU, CN, NP, NF, NA, NB). `FormalSystem/ProofSystem/Axioms.lean` states exactly these
schemata as its primitive axioms, under descriptive constructor names, and obtains every past
mirror the way the paper does, by the time-reflection rule TR (`DerivationTree.time_reflection`,
`Formula.reflectTime`). "Mirror" below names the derived `DerivedAxioms` theorem.

| Paper key | Paper schema | Lean primitive constructor | Derived mirror (by TR) | Burgess / Xu source |
|---|---|---|---|---|
| TN | if ⊢φ then ⊢Gφ | `DerivationTree.temporal_necessitation` (rule) | none | Burgess 1982 rule TG (G half) |
| TR | if ⊢φ then ⊢φ⟨S\|U⟩ | `DerivationTree.time_reflection` (rule, `reflectTime`) | none | — |
| TS | F⊤ | `serial_future` (verbatim) | `serial_past` (⊤ → P⊤) | Burgess 1982 §1.6, No Last Element |
| TC | φ → GPφ | `connect_future` | `connect_past` | original |
| TL | Fφ∧Fψ → F(Fφ∧ψ) ∨ F(φ∧ψ) ∨ F(φ∧Fψ) | `temp_linearity` (verbatim, right-associated) | `temp_linearity_past` | Burgess 1984 §0.3 A2a/A2b (verbatim); nearest Xu (13) |
| UE | (φUψ) → Fψ | `until_F` | `since_P` | not in Burgess 1982; follows from UG with new guard ⊤, plus TN |
| UT | Fφ → (⊤Uφ) | `F_until_equiv` | `P_since_equiv` | original |
| UI | φU(φ∧(φUψ)) → φUψ | `absorb_until` | `absorb_since` | Burgess 1982 A6a/A6b; Xu (9) |
| UC | G(φ→ψ) → (χUφ → χUψ) | `right_mono_until` | `right_mono_since` | Burgess 1982 A1a/A1b; Xu (1)/(2) |
| UF | (φUψ) → (φ∧(φUψ))Uψ | `self_accum_until` | `self_accum_since` | Burgess 1982 A5a/A5b; Xu (7)/(8) |
| UG | G(φ→χ) → (φUψ → χUψ) | `left_mono_until_G` | `left_mono_since_H` | Burgess 1982 A2a/A2b; Xu (1)/(2) |
| SU | θ∧(φUψ) → φU(ψ∧(φSθ)) | `enrichment_until` | `enrichment_since` | Burgess 1982 A3a/A3b; Xu (3)/(4) |
| CN | (φUψ ∧ χUθ) → three-way disjunction | `linear_until` (paper's order, right-associated `A∨(B∨C)`) | `linear_since` | Burgess 1982 A7a/A7b; Xu (10)/(11) |
| NP | X⊤ → Y⊤ | `discrete_symm_fwd` | `discrete_symm_bwd` | original |
| NF | X⊤ → GX⊤ | `discrete_propagate_fwd` | none | original |
| NA | X⊤ → HX⊤ | `discrete_propagate_bwd` (despite the name, this **is** NA, a primitive axiom; TR of NF would be Y⊤ → HY⊤) | none | original |
| NB | X⊤ → □X⊤ | `discrete_box_necessity` | none | original |

The counts reconcile exactly: the paper's 11 non-uniformity temporal axioms are 11 primitive
constructors and its 4 uniformity axioms are 4, giving the tree's 15 BX temporal/uniformity
primitives; with CPL (4), MT/M5/MK (3), MF (1), DN/NN (2), UZ/Z1 (2) and PU/SEP (2) that is 29.
Every former surplus constructor is now a derived theorem, and the derivations are machine-checked
(see [Derived schemata](#derived-schemata)); the primitive presentation *is* the paper's.

The "Burgess / Xu source" column cites Burgess 1982 ("Axioms for tense logic I: Since and
Until", §1.3 unless noted), Burgess 1984 ("Basic Tense Logic") and Xu 1988 formula numbers. The
two Burgess papers number their axioms independently: Burgess 1982 A7a is CN, while Burgess 1984
A7a is an unrelated Dedekind-completeness axiom. Burgess 1982 A4a/A4b is the one pair of his
that BX omits. The same map, with the reasoning behind the CN (A7a) attribution, is in
`FormalSystem/ProofSystem/Axioms.lean`'s module docstring, § Axiom Sources.

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
