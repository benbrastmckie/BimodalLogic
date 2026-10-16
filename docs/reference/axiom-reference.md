# Bimodal Axiom Reference

Complete reference for TM (Tense and Modality) axiom schemas.

## Axiom Categories

TM logic uses **20 axiom constructors**: exactly the paper's primitive axiom schemata
(`def:S5`, `def:BX`, `def:TMplus`, `def:BX-z`, `def:BX-d`, `def:BX-r`; see
`docs/reference/paper-definitions-of-record.md`). The correspondence is an identity, key for key:
the paper names sixteen primitive schemata -- MK, MT, M5; TS, UI, UC, UF, UG, US, CN; MF, NB; UZ;
NN; PU, SEP -- which with the four CPL constructors give exactly these twenty. Every other schema
the tree used to take as primitive -- the twelve past mirrors of the BX temporal group, the S5
schemata 4 and B, the past mirrors of UZ and PU, and now TC, UE, UT, TL, NP, NF, NA, DN and Z1 --
is a **derived theorem** (see
[Derived schemata](#derived-schemata) below). The layer of each constructor is given by
`Axiom.minFrameClass` (`FormalSystem/ProofSystem/Axioms.lean`), which is the authoritative
source -- re-derive from it rather than from this table:

| Layer | Count | Description |
|-------|-------|-------------|
| Base | 16 | Valid on all linear temporal frames |
| Dense | 1 | Valid on densely ordered frames (NN; DN is derived) |
| ZTime | 1 | Valid on discrete (SuccArchimedean) frames (UZ; Z1 is derived) |
| RTime | 2 | Valid on dense Dedekind-complete frames |
| **Total** | **20** | |

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

## Two axiom counts

Two different, both-legitimate conventions coexist across this repository's documentation, and
any count that does not say which one it means is a defect. Both are anchored in
`FormalSystem/ProofSystem/Axioms.lean`:

- **(a) Primitive constructors** — the headline figure used throughout the rest of this
  document. `inductive Axiom` declares exactly 20 constructors, partitioned by
  `Axiom.minFrameClass` into 16 Base / 1 Dense / 1 ZTime / 2 RTime (the table above).
- **(b) Total names, including derived schemata** — 20 primitives plus the 16 mirror theorems in
  `FormalSystem.ProofSystem.DerivedAxioms`, `FormalSystem.Theorems.ConnectDerived`,
  `FormalSystem.Theorems.LinearityDerived` and `FormalSystem.Theorems.Combinators` that mirror a
  schema at that schema's own least frame class (14 mirrors sit at Base; one, `priorSZ`,
  sits at ZTime; one, `priorSGap`, sits at RTime), plus the nine derived schemata TC, UE, UT, TL,
  NP, NF, NA (Base), DN (Dense) and Z1 (ZTime), for 45 names in all (see
  [Derived schemata](#derived-schemata) below for the full list; three further definitions there
  — `serialFutureImp`, `tempLinearityLegacy`, `linearUntilLegacy` — are legacy aliases for an
  already-counted name and are not separately counted in the 16).

  Because a derived mirror inherits its primitive's tier, and because `Dense ≤ RTime` in the
  frame-class order above, the per-class totals under convention (b) are:

  | Layer | Primitives (a) | Derived mirrors | Total names (b) |
  |-------|------|------|------|
  | Base | 16 | 21 | 37 |
  | Dense | 17 | 22 | 39 |
  | ZTime | 17 | 23 | 40 |
  | RTime | 19 | 23 | 42 |

  (The Primitives column is cumulative down the order Base ≤ {Dense, ZTime}, Dense ≤ RTime. The
  eight non-Base *names* under convention (b) are `prior_UZ`, `prior_SZ`, `z1`, `density`,
  `dense_indicator`, `prior_U_gap`, `prior_S_gap`, `sep` — four primitives, the two derived
  schemata `z1` and `density`, and the two derived mirrors `prior_SZ` and `prior_S_gap`, of
  `prior_UZ` and `prior_U_gap` respectively.)

Convention (b)'s 45-names figure and its 37/39/40/42 partition are legitimate, on purpose,
wherever prose is explicitly about the named-schema inventory rather than the `Axiom` type's own
constructors: `BimodalTools/BenchmarkAnchorsMain.lean`'s header docstring,
`FormalSystem/PlusLanguage/README.md`'s `PlusAxiom` re-declaration total, and this
repository's root `README.md`, which keeps an explicitly-labelled secondary column for it. A
future editor should not "correct" those three sites to the convention-(a) figures — they mean
convention (b) deliberately.

### Base Axiom Categories (16 constructors; derived Base schemata marked)

| Category | Paper keys | Constructors / derived theorems |
|----------|------------|--------------|
| Propositional | CPL | `prop_k`, `prop_s`, `ex_falso`, `peirce` |
| Modal S5 | MT, M5, MK | `modal_t`, `modal_5_collapse`, `modal_k_dist` |
| Seriality | TS | `serial_future` |
| Until/Since monotonicity | UG, UC | `left_mono_until_G`, `right_mono_until` |
| Connectedness | TC | derived: `ConnectDerived.connectFuture` |
| Enrichment | US | `enrichment_until` |
| Self-accumulation | UF | `self_accum_until` |
| Absorption | UI | `absorb_until` |
| Linearity | CN, TL | `linear_until`; TL derived: `LinearityDerived.tempLinearity` |
| F bridges | -- (UE, UT are not paper keys) | derived: `DerivedAxioms.untilF`, `DerivedAxioms.fUntilEquiv` |
| Modal-temporal interaction | MF (`def:TMplus`, alongside NB) | `modal_future` |
| Uniformity (discrete-shaped, Base-valid) | NB (`def:TMplus`); NP, NF, NA are TM-derived, not BX keys | `discrete_box_necessity`; NP, NF, NA derived: `ConnectDerived.discreteSymmFwd`, `DerivedAxioms.discretePropagateFwd`, `ConnectDerived.discretePropagateBwd` |

**The temporal layer is Burgess-Xu until/since**, not a T4/TA/TL/TK basis. `untl` and `snce`
are the primitive binary temporal constructors (`FormalSystem/Syntax/Formula.lean`);
G, H, F, and P are all *derived* forms. Note also that `temp_k_dist` and `temp_4` are **derived
theorems**, not axioms -- they are `temporalKDistDerived` and `temporal4Derived` in
`FormalSystem/Theorems/TemporalDerived.lean` (see `Axioms.lean`).

### Extension Axioms

| Layer | Constructors | Frame condition |
|-------|--------------|-----------------|
| Dense (1) | `dense_indicator` (NN, ¬U(⊤,⊥)); DN (GGφ → Gφ) is derived from it: `LinearityDerived.density` | `DenselyOrdered` |
| ZTime (1) | `prior_UZ` (UZ); Z1 is derived from it with US: `DiscreteUnfolding.z1Schema` | `SuccArchimedean` / `PredArchimedean` |
| RTime (2) | `prior_U_gap` (PU), `sep` (SEP) | dense + Dedekind-complete |

The RTime layer is Reynolds's definable-gap axiom set (Reynolds 1992, printed p.168), less the
past form of Prior-U, which is derived. Its soundness target is the *dense* RTime predicate
`ValidRTime`, not the density-free `ValidComplete`, because `dense_indicator` (and so the derived
DN) is admissible at `.RTime` and both are false on ℤ. See `FormalSystem/ProofSystem/Axioms.lean` for
the full argument.

### Derived schemata

Each of these was an `Axiom` constructor at some point; each is now a sorry-free, axiom-free
definition under the lowerCamelCase form of its old name (`since_P` becomes `sinceP`, `modal_4`
becomes `modal4`), with a context-lifted form `XAt Γ …` where consumers need one. A TR mirror
has the same least frame class as its primary, so no frame class needs a surplus axiom. The nine
rows marked **paper schema** are schemata `def:BX`/`def:BX-z`/`def:BX-d` list as axioms and the
tree derives; their derivations are computable (except Z1) because the runtime proof search and
the dataset tooling traverse them.

| Derived | Statement | Derivation | Defined in |
|---|---|---|---|
| `serialPast` | ⊤ → P⊤ | TR of TS, then `prop_s` | `ProofSystem/DerivedAxioms.lean` |
| `leftMonoSinceH` | H(φ→χ) → (φSψ → χSψ) | TR of UG | `ProofSystem/DerivedAxioms.lean` |
| `rightMonoSince` | H(φ→ψ) → (χSφ → χSψ) | TR of UC | `ProofSystem/DerivedAxioms.lean` |
| `connectFuture` | φ → GPφ (**paper schema** TC) | US, then UC and TN collapse the enriched event; curried | `Theorems/ConnectDerived.lean` |
| `connectPast` | φ → HFφ | TR of TC | `Theorems/ConnectDerived.lean` |
| `enrichmentSince` | p ∧ (φSψ) → φS(ψ ∧ φUp) | TR of US | `ProofSystem/DerivedAxioms.lean` |
| `selfAccumSince` | φSψ → (φ ∧ φSψ)Sψ | TR of UF | `ProofSystem/DerivedAxioms.lean` |
| `absorbSince` | φS(φ ∧ φSψ) → φSψ | TR of UI | `ProofSystem/DerivedAxioms.lean` |
| `untilF` | φUψ → Fψ (**paper schema** UE) | UG with guard ⊤, plus TN | `ProofSystem/DerivedAxioms.lean` |
| `sinceP` | φSψ → Pψ | TR of UE | `ProofSystem/DerivedAxioms.lean` |
| `fUntilEquiv` | Fφ → ⊤Uφ (**paper schema** UT) | the identity: `Fφ` is `⊤Uφ` by definition | `ProofSystem/DerivedAxioms.lean` |
| `pSinceEquiv` | Pφ → ⊤Sφ | TR of UT | `ProofSystem/DerivedAxioms.lean` |
| `discreteSymmFwd` | X⊤ → Y⊤ (**paper schema** NP) | US at (⊥, ⊤, ⊤), TR of NF, UE, then `F H ψ → ψ` from TC | `Theorems/ConnectDerived.lean` |
| `discreteSymmBwd` | Y⊤ → X⊤ | TR of NP (no transport needed) | `Theorems/ConnectDerived.lean` |
| `discretePropagateFwd` | X⊤ → GX⊤ (**paper schema** NF) | NB ; MF ; MT | `ProofSystem/DerivedAxioms.lean` |
| `discretePropagateFwdMirror` | Y⊤ → HY⊤ | TR of NF | `ProofSystem/DerivedAxioms.lean` |
| `discretePropagateBwd` | X⊤ → HX⊤ (**paper schema** NA) | NP, TR of NF, then H-monotonicity on NP | `Theorems/ConnectDerived.lean` |
| `priorSZ` | Pφ → ¬φSφ, gated `ZTime ≤ fc` | TR of UZ | `ProofSystem/DerivedAxioms.lean` |
| `priorSGap` | ⊤Sφ ∧ P¬φ → (¬φ ∨ K⁻¬φ)Sφ, gated `RTime ≤ fc` | TR of PU | `ProofSystem/DerivedAxioms.lean` |
| `tempLinearity` | Fφ ∧ Fψ → F(Fφ ∧ ψ) ∨ (F(φ ∧ ψ) ∨ F(φ ∧ Fψ)) (**paper schema** TL) | CN with UF, then UE on each disjunct | `Theorems/LinearityDerived.lean` |
| `tempLinearityPast` | TL's past form, historical disjunct order | TR of TL, then `orRotate` twice | `Theorems/LinearityDerived.lean` |
| `density` | GGφ → Gφ, gated `Dense ≤ fc` (**paper schema** DN) | NN with UG, UF, UE, UC and TN | `Theorems/LinearityDerived.lean` |
| `z1Schema` | G(Gφ→φ) → (FGφ → Gφ) at `ZTime` (**paper schema** Z1) | a direct derivation tree from UZ and US (gated form: `z1SchemaAt`) | `Theorems/DiscreteUnfolding.lean` |
| `linearSince` | CN's past form, left-associated | TR of CN, then `orAssocRev` | `Theorems/Combinators.lean` |
| `modalB` | φ → □◇φ | MT and M5 contraposed, double negation | `Theorems/Combinators.lean` |
| `modal4` | □φ → □□φ | B at □φ, then MN of M5 and MK | `Theorems/Combinators.lean` |
| `tempLinearityLegacy` | TL in the historical order F(φ∧ψ) ∨ (F(φ∧Fψ) ∨ F(Fφ∧ψ)) | TL, then `orRotate` twice | `Theorems/LinearityDerived.lean` |
| `linearUntilLegacy` | CN left-associated `(A ∨ B) ∨ C` | CN, then `orAssocRev` | `Theorems/Combinators.lean` |
| `serialFutureImp` | ⊤ → F⊤ (the historical TS) | TS, then `prop_s` | `ProofSystem/DerivedAxioms.lean` |

Proof steps that used a former constructor now serialize (in the dataset and proof-extractor
outputs) as `time_reflection` over a primitive axiom, or as the derivation above, never as an
axiom name. The runtime matcher (`Automation/ProofSearch/Core.lean`, `mirrorCandidate`) and the
`modal_search` tactic (`@[tmLemma]`, `tryGatedDerivedMatch`) still close every one of these shapes.

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
(`FormalSystem/ProofSystem/Axioms.lean`) unless marked derived; each past-directed mirror is a
derived theorem obtained by the time-reflection rule TR (see
[Derived schemata](#derived-schemata)).

### Monotonicity

**`left_mono_until_G`**: `⊢ △(φ → χ) → (U(φ,ψ) → U(χ,ψ))`
**`right_mono_until`**: `⊢ △(φ → ψ) → (U(χ,φ) → U(χ,ψ))`
**`left_mono_since_H`** / **`right_mono_since`**: the mirror-image `snce` forms (derived by TR).

```lean
| left_mono_until_G (φ χ ψ : Formula) :
    Axiom ((φ.imp χ).allFuture.imp ((Formula.untl φ ψ).imp (Formula.untl χ ψ)))
```

### Connectedness

**`connectFuture`** (TC, derived): `⊢ φ → △▽φ` -- what is the case will always have been the
case. **`connectPast`**: `⊢ φ → ▽△φ` -- the mirror image (derived by TR). Both live in
`FormalSystem/Theorems/ConnectDerived.lean`; TC follows from US (`enrichment_until`) with UC and
TN.

```lean
def connectFuture {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.imp φ.somePast.allFuture
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
**`tempLinearity`** (TL, derived): `⊢ (Fφ ∧ Fψ) → F(Fφ ∧ ψ) ∨ (F(φ ∧ ψ) ∨ F(φ ∧ Fψ))`, the
paper's TL verbatim, derived from CN with UF and UE in `FormalSystem/Theorems/LinearityDerived.lean`
(Xu 1988 §4 Theorem 4.3: the G/H-level (13) is strictly weaker than the Until-level (10)).
`tempLinearityLegacy` is the former order `F(φ ∧ ψ) ∨ (F(φ ∧ Fψ) ∨ F(Fφ ∧ ψ))`, and
`tempLinearityPast` the past mirror in that order.

### F/P bridges

**`untilF`** (UE, derived): `⊢ U(φ,ψ) → Fψ` -- UG with the new guard `⊤`, plus TN
**`sinceP`**: `⊢ S(φ,ψ) → Pψ` (derived by TR)
**`fUntilEquiv`** (UT, derived): `⊢ Fφ → U(⊤,φ)` -- an identity
**`pSinceEquiv`**: `⊢ Pφ → S(⊤,φ)` (derived by TR)

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

### Dense (1)

```lean
| dense_indicator : Axiom (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg  -- ¬U(⊥,⊤)
```

DN (`△△φ → △φ`) is the derived `LinearityDerived.density (h : Dense ≤ fc) φ`
(`FormalSystem/Theorems/LinearityDerived.lean`), from NN with the Base schemata UG, UF, UE, UC
and TN.

### ZTime (1)

`prior_SZ` (`Pφ → S(¬φ, φ)`) is the TR mirror of UZ, derived at every `fc ≥ ZTime`.

```lean
| prior_UZ (φ : Formula) : Axiom (φ.someFuture.imp (Formula.untl φ.neg φ))
```

Z1 (`G(Gφ→φ) → (FGφ → Gφ)`) is the derived `DiscreteUnfolding.z1Schema φ`
(`FormalSystem/Theorems/DiscreteUnfolding.lean`): a direct derivation tree whose only
frame-class-sensitive axiom is UZ, which hands back the *nearest* future `Gφ`-point and so makes
the argument finite. The ZTime extension is therefore UZ alone.

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

## Paper Key Correspondence (the BX temporal group and TM's interaction axioms)

The correspondence spans two paper definitions, not one. `def:BX` names its base tense logic by
the two metarules TN and TR together with seven axiom-schema keys -- TS, UI, UC, UF, UG, US, CN
-- and states in its own text that TC and TL are **derived theorems of BX** rather than further
axioms. `def:TMplus` adds the two bimodal interaction axioms MF and NB, and states that the
uniformity schemata NP, NF and NA are **derived theorems of TM** -- not of BX -- their
derivations using NB together with MF and MT. UE and UT appear in neither: the paper carries no
key of any kind for them, and they survive here as theorems of this tree alone.

`FormalSystem/ProofSystem/Axioms.lean` takes exactly the paper's primitive keys as its
constructors, under descriptive names, derives the rest (marked **derived** below), and obtains
every past mirror the way the paper does, by the time-reflection rule TR
(`DerivationTree.time_reflection`, `Formula.reflectTime`). "Mirror" below names the derived
theorem. The "Paper key" column gives the displayed key; the "In the paper" column says what the
live paper makes of it.

| Paper key | Paper schema | In the paper | Lean primitive constructor / derived theorem | Derived mirror (by TR) | Burgess / Xu source |
|---|---|---|---|---|---|
| TN | if ⊢φ then ⊢Gφ | `def:BX` metarule | `DerivationTree.temporal_necessitation` (rule) | none | Burgess 1982 rule TG (G half) |
| TR | if ⊢φ then ⊢φ⟨S\|U⟩ | `def:BX` metarule | `DerivationTree.time_reflection` (rule, `reflectTime`) | none | — |
| TS | F⊤ | `def:BX` axiom | `serial_future` (verbatim) | `serial_past` (⊤ → P⊤) | Burgess 1982 §1.6, No Last Element |
| TC | φ → GPφ | `def:BX`, marked derived | **derived** `ConnectDerived.connectFuture` (US, UC, TN) | `connectPast` | original |
| TL | Fφ∧Fψ → F(Fφ∧ψ) ∨ F(φ∧ψ) ∨ F(φ∧Fψ) | `def:BX`, marked derived | **derived** `LinearityDerived.tempLinearity` (from CN with UF and UE; verbatim, right-associated) | `tempLinearityPast` | Burgess 1984 §0.3 A2a/A2b (verbatim); Xu (13), strictly weaker than (10) by Xu §4 Thm 4.3 |
| UE | (φUψ) → Fψ | **not a paper key** | **derived** `DerivedAxioms.untilF` | `sinceP` | not in Burgess 1982; follows from UG with new guard ⊤, plus TN |
| UT | Fφ → (⊤Uφ) | **not a paper key** | **derived** `DerivedAxioms.fUntilEquiv` (an identity) | `pSinceEquiv` | original |
| UI | φU(φ∧(φUψ)) → φUψ | `def:BX` axiom | `absorb_until` | `absorb_since` | Burgess 1982 A6a/A6b; Xu (9) |
| UC | G(φ→ψ) → (χUφ → χUψ) | `def:BX` axiom | `right_mono_until` | `right_mono_since` | Burgess 1982 A1a/A1b; Xu (1)/(2) |
| UF | (φUψ) → (φ∧(φUψ))Uψ | `def:BX` axiom | `self_accum_until` | `self_accum_since` | Burgess 1982 A5a/A5b; Xu (7)/(8) |
| UG | G(φ→χ) → (φUψ → χUψ) | `def:BX` axiom | `left_mono_until_G` | `left_mono_since_H` | Burgess 1982 A2a/A2b; Xu (1)/(2) |
| US | θ∧(φUψ) → φU(ψ∧(φSθ)) | `def:BX` axiom | `enrichment_until` | `enrichment_since` | Burgess 1982 A3a/A3b; Xu (3)/(4) |
| CN | (φUψ ∧ χUθ) → three-way disjunction | `def:BX` axiom | `linear_until` (paper's order, right-associated `A∨(B∨C)`) | `linear_since` | Burgess 1982 A7a/A7b; Xu (10)/(11) |
| NP | X⊤ → Y⊤ | `def:TMplus`, marked derived (TM, not BX) | **derived** `ConnectDerived.discreteSymmFwd` (US, TR of NF, UE, TC) | `discreteSymmBwd` | original |
| NF | X⊤ → GX⊤ | `def:TMplus`, marked derived (TM, not BX) | **derived** `DerivedAxioms.discretePropagateFwd` (NB ; MF ; MT) | `discretePropagateFwdMirror` (Y⊤ → HY⊤) | original |
| NA | X⊤ → HX⊤ | `def:TMplus`, marked derived (TM, not BX) | **derived** `ConnectDerived.discretePropagateBwd` (NP, TR of NF, H-monotonicity; despite the name this **is** NA, not the mirror of NF) | none | original |
| MF | □φ → □Gφ (modal-temporal interaction) | `def:TMplus` axiom | `modal_future` | none | original |
| NB | X⊤ → □X⊤ | `def:TMplus` axiom | `discrete_box_necessity` | none | original |

The counts reconcile exactly, and now as an identity rather than a containment. Re-derived from
`Axioms.lean`'s own layer list: CPL (4) + S5 MK/MT/M5 (3) + BX temporal TS/UI/UC/UF/UG/US/CN (7)
+ interaction MF (1) + uniformity NB (1) = 16 Base, plus UZ (1, ZTime), NN (1, Dense) and PU/SEP
(2, RTime) = **20**, which is `inductive Axiom`'s constructor count and what
`scripts/typst-status-counts.sh` reports as `base_count` 16, `ztime_only_count` 1,
`dense_only_count` 1, `rtime_only_count` 2. On the paper's side the same twenty are its sixteen
named primitive schemata plus the four CPL constructors, so there is no surplus constructor on
either side to reconcile: `def:BX` names seven axiom keys and two metarules, `def:TMplus` adds
MF and NB, `def:BX-z` adds UZ, `def:BX-d` adds NN and `def:BX-r` adds PU and SEP. The nine
derived schemata -- TC, TL (BX-derived), NP, NF, NA (TM-derived), Z1 (TM_z-derived), DN
(BX_d-derived), UE and UT (tree-only, no paper key) -- are machine-checked (see
[Derived schemata](#derived-schemata)).

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
