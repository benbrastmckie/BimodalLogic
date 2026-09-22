# Research Report: Task #651

**Task**: 651 - chain_complete_dense_tm_minus
**Started**: 2026-09-22T16:16:04Z
**Completed**: 2026-09-22T17:05:00Z
**Effort**: one research dispatch (orchestrated, seq 1), one compiled probe
**Dependencies**: None (the task's own dispatch names none; siblings 653/655 are research-only and disjoint)
**Sources/Inputs**:
- Codebase, Conservativity layer: `FormalSystem/Metalogic/Conservativity/{FragmentAxiomatization,MinusExt,ChainBundleTruth,TMCompletenessReduction,MinusDeduction,Fragment}.lean`, the aggregator `Metalogic/Conservativity.lean`, `Conservativity/README.md`
- Codebase, L⁻ layer: `FormalSystem/MinusLanguage/{Formula,Axioms,Derivation,MinusTruth,MinusValidity,Soundness,Translation,AxiomDischarge}.lean`
- Codebase, existing canonical-model machinery (Formula-typed): `Metalogic/Core/{MaximalConsistent,MCSProperties}.lean`, `Core/RestrictedMCS/Basic.lean`, `Metalogic/BXCanonical/{README.md,Completeness,TruthLemma,Frame}.lean`, `BXCanonical/Chronicle/README.md`, `BXCanonical/Quasimodel/README.md`, `Metalogic/WeakCanonical/README.md`, `Metalogic/Algebraic/FlowFrame.lean`, `Semantics/TemporalOrder.lean`
- Task-559 research reports `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/01..04` (all four are about TM⁺/`⊡`; none mentions TM⁻, `MinusFormula` or the H/G fragment)
- Repository gates: `docs/theorem-index.md` (row format, C14 pin), `scripts/check-module-invariants.sh` (C14 baseline pair, `--emit-inventory`)
- lean-lsp MCP: `lean_local_search`; a compiled probe (below) in place of rate-limited web search tools
- Literature (from memory of the standard sources the tree already cites): Burgess 1984 *Basic Tense Logic* §2.5 (the tense logic of ℚ, step-by-step); Goldblatt 1992 *Logics of Time and Computation* (canonical-model density/linearity lemmas). No PDF in `specs/literature/` was consulted; the corpus was not queried.
**Artifacts**:
- `specs/651_chain_complete_dense_tm_minus/reports/01_chain-complete-dense-route.md` (this report)
- `specs/651_chain_complete_dense_tm_minus/probes/01_minus-mcs-lindenbaum-and-assembly.lean` (compiles sorry-free with `lake env lean` against the prebuilt oleans; ~200 lines)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Class choice: keep `.Dense`, `Ax = ∅`.** It is the only row whose classical proof is a single
  step-by-step construction over ℚ with no case split and no Cantor step. `.Base` needs both a dense
  and a discrete engine plus the (Sp) split; `.ZTime` needs a discrete engine with the Z1
  limit-closure argument and is not compact. Nothing existing makes either cheaper.
- **No obstruction found.** Every lemma the route needs is a standard TM⁻_d derivation or a
  standard MCS argument; the DN axiom enters exactly once (canonical density), TL and its TR-mirror
  exactly once each (weak linearity), TS/TC/TK/T4/MF where expected. The paper argument for each
  is checked in §Findings 3 and no step needs an axiom L⁻ cannot express.
- **Nothing can be reused from the tree's canonical models.** Every MCS/Lindenbaum/truth-lemma
  declaration is stated over `Formula`; `TMCompletenessReduction.lean` already records why
  borrowing `BXCanonical/Chronicle/` is *circular*, not merely inconvenient. The L⁻ side must get
  its own MCS layer. The probe confirms it is a near-verbatim mirror of `Core/MaximalConsistent.lean`
  (Zorn/Lindenbaum in ~70 lines, the generic Zorn step stated once for any carrier).
- **The countability requirement is structural, not incidental.** `ChainValidIn` quantifies over
  bundles of copies of *one* ordered group `D`. The full canonical model's `R`-components can be
  uncountable and pairwise non-isomorphic, so "canonical model + generated submodel + bulldozing"
  does not land in a chain bundle. The route must build a **countable** chain directly on ℚ: a
  Burgess-style ω-stage construction of a chronicle `c : ℚ → MCS` from any seed, with finite
  support at every stage, requirements enumerated so each recurs infinitely often.
- **The bundle index is one `□`-class of chronicles.** `FamIdx := {c : Chronicle // ∀ q, Γ₀ ~ c q}`
  with `~` the canonical box relation (an equivalence by T/4/B, closed under `R` and `R⁻¹` by MF
  and its TR-mirror). The `chainSat` box clause quantifies over all of `FamIdx × ℚ`, which is exactly
  what the `◇`-witness case of the truth lemma needs: a chronicle through the witness MCS.
- **Consequence the planner must decide on.** `ChainComplete .Dense ∅` implies
  `TMMinusComplete FrameClass.Dense` and, via `tmMinusCompleteDense_iff_forwardDense`,
  `Forward FrameClass.Dense` — both currently documented as *open, never asserted* in four
  module docstrings and the README. Both corollaries are two-line theorems once
  `chainComplete_dense` lands; the docstrings become false if left as they are.
- **Estimated size**: ~2,400–3,200 lines across four new modules and one edited module; the
  ℚ-step-by-step module is the single hard phase (~800–1,100 lines). Recommended decomposition in
  §Recommendations.

## Context & Scope

`ChainComplete fc Ax := ∀ φ, ChainValidIn fc φ → MinusExt fc Ax φ`
(`FragmentAxiomatization.lean`). At `fc := .Dense`, `Ax := ∅`, the target is: every L⁻ formula
true at every point of every `FamIdx × D` chain bundle with `D` a dense temporal order (and `□`
universal) is a TM⁻_d theorem. `minusExt_empty_iff` turns the conclusion into
`MinusLanguage.Derivable .Dense [] φ`, so the contrapositive is the familiar shape: `¬ ⊢⁻[.Dense] φ`
⟹ a chain-bundle refutation of `φ`.

Constraints honoured: no sorry on any completeness-shaped statement; the other three
`ChainComplete` rows stay hypotheses; no new axioms; no borrowing from Formula-typed canonical
models; new modules go through `lake exe mk_all`, the sibling aggregator, the README inventory and
the header linter; theorem-index rows with C14 pins.

What was checked mechanically (probe, sorry-free, `lake env lean` exit 0):

1. L⁻ MCS layer: `MinusConsistent`, `MinusSetConsistent`, `MinusSetMaximalConsistent`,
   polymorphic `exists_maximal_of_chainClosed`, `finite_list_in_chain_member`,
   `minus_consistent_chain_union`, `minus_set_lindenbaum`, and
   `neg_consistent_of_not_minus_derivable` (via `minusDeductionTheorem` + `minusDne`).
2. `canR`, `canBox`, and a `Chronicle` structure (coherent, F/P-witnessing `ℚ → Set MinusFormula`).
3. `not_chainValidIn_dense_of_rat_refutation`: one refutation on a `TemporalOrder.of ℚ` bundle
   refutes `ChainValidIn .Dense`; the `.Dense` side condition is `inferInstance`.
   `chainComplete_dense_of_engine`: the whole target follows from a refutation engine hypothesised
   as a binder.
4. Mathlib names at the pinned version: `exists_surjective_nat`, `Nat.unpair`,
   `Nat.surjective_unpair`, `Nat.unpair_pair`, `Nat.right_le_pair`, `exists_between`,
   `Finset.max'`, `Finset.min'`, `Order.iso_of_countable_dense` (not needed on the chosen route),
   `DenselyOrdered ℚ`, `NoMaxOrder ℚ`, `NoMinOrder ℚ`, `Countable (ℚ × MinusFormula × Bool)`;
   and `exists_enum_infinitely_often` (every requirement recurs at arbitrarily late stages).

`Set.Finite.exists_between` does **not** exist; use `exists_between` on `Finset.max'`/`min'`
of filtered supports instead.

## Findings

### 1. What exists, and why none of it is reusable as-is

- **MCS layer**: `Core/MaximalConsistent.lean` (509 lines) and `Core/MCSProperties.lean`
  (468 lines) are stated over `Formula` and `ProofSystem.DerivationTree` throughout. The generic
  Zorn step `exists_maximal_of_chainClosed` is generic in everything but its `Set Formula` binder.
  Mirroring costs little (probe: the four Lindenbaum declarations in ~70 lines), and the closure
  properties (`closed_under_derivation`, `implication_property`, `negation_complete`,
  `neg_excludes`, `theorem_in_mcs`, `mp_of_theorem`, `bot_not_mem`) mirror one-for-one on top of
  `minusDeductionTheorem` (`Conservativity/MinusDeduction.lean`).
- **Canonical frame**: `BXCanonical/Frame.lean` has the exact lemma shapes to copy —
  `BxLe` (= `canR`), `BxModalEquiv` (= `canBox`), `g_content_closed_derivation`,
  `g_content_set_consistent`, `bx_le_trans`, `bx_forward_witness`, `bx_modal_witness`,
  `box_preserved_along_bx_le`, `bx_modal_equiv_of_bx_le`; `BXCanonical/TruthLemma.lean` has
  `F_from_witness`/`P_from_witness`. All over `Formula`; none transfers by import.
- **Generalized temporal K** (`Theorems/GeneralizedNecessitation.lean`, `generalizedTemporalK :
  Γ ⊢ φ → map G Γ ⊢ Gφ`) is the one derivation-level helper the existence lemmas need; it has no
  L⁻ counterpart yet. Its proof is an induction through the deduction theorem and TK; mirror it.
- **The chronicle engine** (`BXCanonical/Chronicle/`, ~20k lines) is out of reach twice over: it is
  Formula-typed (circularity recorded in `TMCompletenessReduction.lean`), and its size is driven by
  until/since (mixed cases, guard accumulation, counterexample elimination) that L⁻ does not have.
  For H/G alone the classical construction is the short Burgess §2.5 one.
- **Transfer half is closed**: `not_minusValidIn_of_not_chainSat` and
  `not_minusValidDense_of_not_chainSat` (`ChainBundleTruth.lean`) — but note the target here is
  `ChainValidIn`, which is *weaker* to refute than `MinusValidIn`: the probe shows the refutation
  plugs into `ChainValidIn` directly by instantiating `D := TemporalOrder.of ℚ`, no transfer lemma
  needed. (The transfer lemma is what makes the corollaries in §5 free.)
- **Task-559 reports**: entirely about TM⁺/`⊡` (limit closure, LC⁺, Reynolds automata). Nothing
  about TM⁻. No canonical-model machinery for L⁻ exists anywhere in `specs/` either.
- **Available L⁻ derivations**: `MinusDeduction.lean` gives the deduction theorem (computable),
  `minusImpTrans`, `minusFlip`, `minusNotNotIntro`, `minusContrapos`, `minusDne`,
  `minusToDiamond`, `minusModalB`, `boxImpBoxBox` (S5 4), `notBoxImpBoxNotBox`, and the four
  `□`-globality derivations; `Derivation.lean` gives `temporalNecessitationDerivable`. The
  TR-mirroring idiom (`reflectTime_boxGlobal ▸ time_reflection _ (… χ.reflectTime)`) is exactly how
  every past-side lemma below should be obtained.

### 2. Why the countable ℚ construction is mandatory (and why bulldozing is not the route)

`ChainValidIn fc φ` ranges over `D : TemporalOrder` (a nontrivial totally ordered abelian group),
`FamIdx : Type`, and evaluates `chainSat` on `FamIdx × ↑D`: every chain is a copy of the *same*
group `D`. A refutation therefore needs a countable dense chain (so it can be ℚ) — or at least all
chains of one bundle order-isomorphic to a single ordered group. The full canonical model of TM⁻_d
gives, per `□`-class, a family of `R`-components that are transitive, weakly linear, dense and
serial, but (i) may contain reflexive points and proper clusters (needing bulldozing to become
strict orders), and (ii) may be uncountable and non-isomorphic to one another — and an arbitrary
dense linear order need not carry any ordered-group structure at all. So "generated submodel +
bulldozing" does not land in `ChainValidIn`'s quantifier. A downward Löwenheim–Skolem detour
(Mathlib `FirstOrder.Language.exists_elementarySubstructure_card_eq`) would require encoding
`chainSat` as first-order model theory and is far more work than the direct construction.

The classical fix (Burgess 1984 §2.5) is to build a **single ℚ-indexed chain step by step from the
canonical relations**, never forming the whole canonical model as a frame: reflexive MCSs may
legitimately label many rationals, irreflexive ones label at most one (coherence forbids
`Δ R Δ`), and clusters never need quotienting. This also makes Cantor's theorem unnecessary.

### 3. The route, lemma by lemma (all paper-checked; Lean names proposed)

Throughout `fc := .Dense`; write `MPoint := {S : Set MinusFormula // MinusSetMaximalConsistent .Dense S}`.

**3.1 MCS layer** (`MinusMCS.lean`, mirror of Core): as in the probe plus closure properties, and
`mem_or_neg_mem`, `imp_mem_iff : (φ.imp ψ) ∈ Γ ↔ (φ ∈ Γ → ψ ∈ Γ)`, `and_mem_iff`, `not_mem_iff_neg_mem`.

**3.2 Derived TM⁻ theorems needed** (`MinusTemporalDerived.lean` or inside 3.3):
- `gDistImp` = TK (axiom); `gAnd : ⊢ Gφ ∧ Gψ → G(φ ∧ ψ)`; `minusGeneralizedTemporalK :
  Γ ⊢⁻ φ → map G Γ ⊢⁻ Gφ` (induction via `minusDeductionTheorem`, TN, TK);
  `fMono : ⊢ φ → ψ ⟹ ⊢ Fφ → Fψ`; `gAndF : ⊢ Gχ ∧ Fψ → F(χ ∧ ψ)`; `notFBot : ⊢ F⊥ → ⊥`
  (`G¬⊥` by TN); `fF_of_f : ⊢ Fψ → FFψ` (DN contraposed, the **only** DN use; `Axiom.dn`
  requires `FrameClass.Dense ≤ fc`, which is `le_refl` at `.Dense`); `g4` = T4; `tcFuture` = TC;
  `serialF` = TS.
- Modal: `mkGeneralized : Γ ⊢⁻ φ → map □ Γ ⊢⁻ □φ` (MN + MK); T, 4 (`boxImpBoxBox`), B
  (`minusModalB`) exist; `boxImpBoxG` = MF (axiom); `boxImpBoxH` := TR of MF at `φ.reflectTime`,
  transported by `reflectTime_involution` (same idiom as `boxGlobalPast`).
- Past mirrors, all by TR on the future theorem at `χ.reflectTime` + `reflectTime_involution` and
  the `@[simp] reflectTime_*` lemmas: `hAnd`, `hGeneralizedK`, `pMono`, `hAndP`, `notPBot`,
  `tcPast : ⊢ φ → HFφ`, `serialP : ⊢ P⊤` (`reflectTime` of `temp_serial`'s `F⊤` is `P⊤` by
  `reflectTime_someFuture`, `reflectTime_top`), and `tlPast` (left-linearity, the reflection of
  `temp_linearity`).

**3.3 Canonical relations** (`MinusCanonicalFrame.lean`):
- `canR Γ Δ := ∀ χ, Gχ ∈ Γ → χ ∈ Δ`; `canBox Γ Δ := ∀ χ, □χ ∈ Γ → χ ∈ Δ`.
- `canR_trans` (T4). `canR_iff_past : canR Γ Δ ↔ ∀ χ, Hχ ∈ Δ → χ ∈ Γ` (⇒ by TC:
  `¬χ ∈ Γ ⟹ GP¬χ ∈ Γ ⟹ P¬χ ∈ Δ`, contradicting `Hχ ∈ Δ` through `Hχ → H¬¬χ`; ⇐ by `tcPast`).
- `F_of_canR : canR Γ Δ → ψ ∈ Δ → Fψ ∈ Γ` and its P mirror (as `F_from_witness`).
- `exists_canR_of_F : Fψ ∈ Γ → ∃ Δ, canR Γ Δ ∧ ψ ∈ Δ`: Lindenbaum on `{χ | Gχ ∈ Γ} ∪ {ψ}`;
  inconsistency gives a finite `A ⊆ GContent Γ` with `A ⊢ ¬ψ`, so `G¬ψ ∈ Γ` by
  `minusGeneralizedTemporalK`, contradicting `Fψ = ¬G¬ψ ∈ Γ`. P mirror via `canR_iff_past`.
- `exists_canR_serial : ∃ Δ, canR Γ Δ` (TS gives `F⊤ ∈ Γ`), and the past mirror (`serialP`).
- `exists_canR_between : canR Γ Δ → ∃ Θ, canR Γ Θ ∧ canR Θ Δ` (**density**). Lindenbaum on
  `S := {χ | Gχ ∈ Γ} ∪ {χ | Hχ ∈ Δ}`; `canR Θ Δ` then comes from `canR_iff_past`. Consistency:
  suppose finite `A ⊆ GContent Γ`, `B ⊆ HContent Δ`, `A ++ B ⊢ ⊥`; with `a := ⋀A`, `b := ⋀B`:
  `⊢ a → ¬b`, so `G¬b ∈ Γ` (generalized K + `gAnd`), and `Hb ∈ Δ` (`hAnd`), hence `F(Hb) ∈ Γ`
  (`F_of_canR`), hence `FF(Hb) ∈ Γ` (`fF_of_f`, DN). Then
  `G¬b → G(GP¬b)` (TC under G), `G(GP¬b) ∧ FF(Hb) → F(GP¬b ∧ F(Hb))` (`gAndF`),
  `GP¬b ∧ F(Hb) → F(P¬b ∧ Hb)` (`gAndF`), `P¬b ∧ Hb → ⊥`, so `FF⊥ → F⊥ → ⊥` (`fMono`, `notFBot`).
  Contradiction with consistency of `Γ`. This is where density is used and it is the one place.
- `canR_weakLinear : canR Γ Δ₁ → canR Γ Δ₂ → Δ₁ = Δ₂ ∨ canR Δ₁ Δ₂ ∨ canR Δ₂ Δ₁` (TL). Suppose
  neither `canR`; pick `Gα ∈ Δ₁, ¬α ∈ Δ₂`, `Gβ ∈ Δ₂, ¬β ∈ Δ₁`, and (unless `Δ₁ = Δ₂` by
  extensionality) `γ ∈ Δ₁, ¬γ ∈ Δ₂` (or the symmetric orientation). Put
  `φ₁ := Gα ∧ ¬β ∧ γ ∈ Δ₁`, `φ₂ := Gβ ∧ ¬α ∧ ¬γ ∈ Δ₂`, so `Fφ₁ ∧ Fφ₂ ∈ Γ`. Each TL disjunct is
  provably inconsistent — `Fφ₁ ∧ φ₂` (Gβ with F¬β), `φ₁ ∧ φ₂` (γ with ¬γ), `φ₁ ∧ Fφ₂` (Gα with
  F¬α) — so `⊢ ¬(F(Fφ₁ ∧ φ₂) ∨ F(φ₁ ∧ φ₂) ∨ F(φ₁ ∧ Fφ₂))` by `fMono`, `notFBot`, and TL's
  consequent is refuted in `Γ`. No existence lemma is needed inside this proof. The *left*
  version is the TR-mirror; only the right version is consumed by the chronicle insertion lemma
  (witness placement is always to the future of the requiring point, or to the past for `P`, where
  the past version is consumed). Both are needed.
- Box: `canBox_refl` (T), `canBox_trans` (4), `canBox_symm` (B); `exists_canBox_of_dia :
  ◇ψ ∈ Γ → ∃ Δ, canBox Γ Δ ∧ ψ ∈ Δ` (Lindenbaum on `{χ | □χ ∈ Γ} ∪ {ψ}` with `mkGeneralized`);
  `canBox_of_canR : canBox Γ Δ → canR Δ Δ' → canBox Γ Δ'` (MF: `□χ ∈ Γ ⟹ □Gχ ∈ Γ ⟹ Gχ ∈ Δ ⟹
  χ ∈ Δ'`) and `canBox_of_canR_rev` (with `boxImpBoxH`).

**3.4 ℚ-chronicle existence** (`MinusChronicle.lean`), the hard phase:
- `structure Chronicle` as in the probe (`c : ℚ → Set MinusFormula`, `mcs`, `coh`, `witF`, `witP`).
- Stage representation: `Stage := {s : ℚ → Option MPoint // (support s).Finite ∧ coherent s}` with
  `coherent s := ∀ q q' Γ Δ, q < q' → s q = some Γ → s q' = some Δ → canR Γ Δ`; extension order
  `s ≤ s' := ∀ q Γ, s q = some Γ → s' q = some Γ`.
- `Req := ℚ ⊕ (ℚ × MinusFormula × Bool)` (fill `r`; witness `F`/`P` for `ψ` at `q`). Countable,
  nonempty; `exists_enum_infinitely_often` (probe) yields `e : ℕ → Req` hitting every requirement
  at arbitrarily late stages.
- `insert_future` (the placement lemma): given a stage `s`, `s q = some Γ`, `canR Γ Δ`, either
  `∃ q' > q, s q' = some Δ`, or `∃ r > q, s r = none ∧ coherent (s[r ↦ Δ])`. Proof: let
  `U := {q' ∈ supp | q < q' ∧ ¬ canR (s q') Δ}` (a `Finset` via the finite support). If `U = ∅`,
  take `r > max supp` (`NoMaxOrder ℚ`); coherence below `r` is by `canR_trans` through `Γ` for
  `q'' ≤ q` and by `U = ∅` for `q'' > q`. If `U ≠ ∅`, let `q₁ := U.min'`; `canR Γ (s q₁)` by
  coherence and `canR Γ Δ`, so `canR_weakLinear` gives `Δ = s q₁` (first disjunct of the lemma) or
  `canR Δ (s q₁)` (`canR (s q₁) Δ` is excluded by `q₁ ∈ U`); choose `r` strictly between
  `max {q'' ∈ supp | q'' < q₁}` (which is `≥ q`) and `q₁` by `exists_between`; coherence above `r`
  is `canR Δ (s q₁)` composed with coherence from `q₁`. `insert_past` is the mirror (uses the
  left-linearity lemma and `canR_iff_past`).
- `fill` (interpolation): `r ∉ supp` ⟹ `∃ Θ, coherent (s[r ↦ Θ])`, by cases on whether
  `{q' ∈ supp | q' < r}` and `{q' ∈ supp | r < q'}` are nonempty: both → `exists_canR_between` at
  `(s (max below), s (min above))`; only below → `exists_canR_serial`; only above → its mirror;
  neither cannot occur (support contains the seed at `0` from stage 0 and only grows).
- `step : Stage → Req → Stage` dispatching on the requirement (no-op when the requirement's
  rational is unlabelled or the formula is absent), `stages : ℕ → Stage` by iteration from the
  seed stage `{0 ↦ Γ}`, monotone, finite support, coherent.
- Limit `c q := (stages (n q)) q` for a chosen `n q` with `stages (n q) q ≠ none` (exists by the
  `fill r` requirement); well-defined by monotonicity. Then `mcs`, `coh` (both points defined at
  `max n n'`), `witF`/`witP` (the requirement recurs after the point is labelled), giving
  `exists_chronicle_through : ∀ Γ : MPoint, ∃ c : Chronicle, c.c 0 = Γ`.
- Every value placed is an MCS from Lindenbaum, so `c q ~ Γ` for all `q` follows afterwards from
  `canBox_refl`, `canBox_of_canR`, `canBox_of_canR_rev` and `coh`.

**3.5 Bundle and truth lemma** (`MinusChainCompleteness.lean`):
- Fix `Γ₀ ∋ ¬φ`. `FamIdx := {c : Chronicle // ∀ q, canBox Γ₀ (c.c q)}`; nonempty via
  `exists_chronicle_through Γ₀`. `v (c, q) p := MinusFormula.atom p ∈ c.c q`.
- `truth_lemma : ∀ ψ c q, chainSat v (c, q) ψ ↔ ψ ∈ c.c q` by induction on `ψ` generalizing
  `c q`. `atom`: definitional. `bot`: `bot_not_mem`. `imp`: `imp_mem_iff`. `allFuture`: forward by
  `coh`; backward: `Gψ ∉ c q ⟹ F¬ψ ∈ c q ⟹ witF`. `allPast`: forward by `coh` + `canR_iff_past`;
  backward by `witP`. `box`: forward: `□ψ ∈ c q`, `canBox (c q) Γ₀` (symm) and `canBox Γ₀ (c' q')`
  give `canBox (c q) (c' q')` by transitivity, hence `ψ ∈ c' q'`; backward: `□ψ ∉ c q ⟹ ◇¬ψ ∈ c q`
  (S5 duality in the MCS) ⟹ `exists_canBox_of_dia` gives `Δ ∋ ¬ψ` with `canBox (c q) Δ` ⟹
  `exists_chronicle_through Δ` gives `c'` with `c'.c 0 = Δ` and `c' ∈ FamIdx` (transitivity through
  `Γ₀`, `c q`, `Δ`, then along `c'` by the MF-closure lemmas) ⟹ `¬ chainSat v (c', 0) ψ` by IH.
- `chainComplete_dense : ChainComplete FrameClass.Dense ∅` via the probe's
  `chainComplete_dense_of_engine` shape: `¬ ⊢⁻[.Dense] φ` ⟹ `{¬φ}` consistent
  (`neg_consistent_of_not_minus_derivable`) ⟹ Lindenbaum `Γ₀` ⟹ `¬ chainSat v (c₀, 0) φ` ⟹
  `not_chainValidIn_dense_of_rat_refutation`.
- `minusExt_iff_tmFrag_dense : ∀ φ, MinusExt .Dense ∅ φ ↔ TMFrag .Dense φ :=
  minusExt_empty_iff_tmFrag_dense_of_chainComplete chainComplete_dense`.

### 4. Where the frame-class parameter bites, and the Dense-only discipline

- `Axiom.dn`'s gate is `Dense ≤ fc`; every lemma in 3.2–3.5 other than `fF_of_f` /
  `exists_canR_between` holds at every `fc`. Stating the MCS layer and the relations at a
  variable `fc` and only the density lemma at `.Dense` keeps the reusable part reusable (a future
  `.RTime` attempt would need everything except density replaced by a CO-based Dedekind step).
- The construction must **not** be generalised to a "for all `fc`" chronicle theorem: it is false
  at `.Base`/`.ZTime` (no interpolation lemma there), and any such statement would violate the
  standing prohibition. Keep `exists_chronicle_through` explicitly at `.Dense`.

### 5. Downstream consequences the planner must schedule or explicitly exclude

`chainComplete_dense` immediately yields, each in ≤ 5 lines:
- `minusValidIn_chainValidIn {fc} : MinusValidIn fc φ → ChainValidIn fc φ` (instantiate at
  `multiFamTaskFrameGen D FamIdx`, model `⟨v⟩`, history `multiFamHistoryGen q.1 q.2`, time `0`,
  read through `chainBundle_truth_lemma`; `simpa` as in `not_minusValidIn_of_not_chainSat`).
- `tmMinusComplete_dense : TMMinusComplete FrameClass.Dense` (compose with `minusExt_empty_iff`).
- `forward_dense : Forward FrameClass.Dense` (`tmMinusCompleteDense_iff_forwardDense.mp`).

These are *proofs*, which the prohibition in `Metalogic/Conservativity.lean` explicitly welcomes
("It is not a prohibition on *proving* one"). But the following prose then becomes false and must
be revised in the same task or the tree contradicts itself:
- `FragmentAxiomatization.lean` module docstring ("nothing here concludes `ChainComplete fc Ax` for
  any `fc`, `Ax`"), the `ChainComplete` docstring ("No declaration in this tree concludes it"), the
  `.Dense` verdict bullet, and `minusExt_empty_iff_tmFrag_dense_of_chainComplete`'s docstring
  ("Neither `TMMinusComplete .Dense` nor `ChainComplete .Dense ∅` is asserted").
- `TMCompletenessReduction.lean` four-row status table, `.Dense` row and the "What a positive answer
  still needs" subsection; `Metalogic/Conservativity.lean`'s "open for the other two" phrasing;
  `ChainBundleTruth.lean` ("It is not a completeness proof… the converse is not proved");
  `Conservativity/README.md` status table (forward: "open at `.Dense`"). The `.RTime` row stays
  open and its obstruction paragraph stays as is.
- `docs/theorem-index.md`: add rows for `chainComplete_dense` and `minusExt_iff_tmFrag_dense`
  (and the corollaries if included) with `pcq pinned:C14`, which requires adding the matching
  `#print axioms` line and baseline line to the `C14LEAN`/`C14BASE` heredoc pair in
  `scripts/check-module-invariants.sh` (they are compared by exact string equality).

Recommendation: include `minusValidIn_chainValidIn`, `tmMinusComplete_dense` and `forward_dense`
as a final short phase; the docstring edits are mandatory regardless, and the corollaries are what
make the edits honest rather than merely narrower.

### 6. Repository mechanics the plan must carry

- New modules under `FormalSystem/Metalogic/Conservativity/` (flat, four files) are each imported
  directly by the generated root; regenerate with `lake exe mk_all --lib FormalSystem` and add each
  to `Metalogic/Conservativity.lean` and to the README inventory via
  `bash scripts/check-module-invariants.sh --emit-inventory`. Header linter under `--wfail`: module
  docstring first after imports, no broad imports (import `Mathlib.Order.Zorn`,
  `Mathlib.Data.Countable.Defs`, `Mathlib.Data.Nat.Pairing`, `Mathlib.Data.Finset.Max`
  individually — the probe's import list is a valid starting set).
- The final theorem's module must import `FragmentAxiomatization` (for `ChainComplete`,
  `minusExt_empty_iff_tmFrag_dense_of_chainComplete`) and `ChainBundleTruth` (for `chainSat`);
  neither of those may import the new modules (no cycle; `check-metalogic-cycles.sh`).
- Docstrings: cite Burgess 1984 §2.5 / `def:BL-semantics` by label, no line numbers, no task
  numbers (`validate-no-task-references.sh` is a blocking write-time gate outside `specs/`).
- Build discipline: every `lake build` detached through `lake-build-guard.sh` with `--timeout`;
  the Conservativity modules are cheap to rebuild but the root regeneration touches the whole
  library.

### Codebase Patterns

- Mirror-by-transposition is the established idiom on this side of the tree (`MinusLanguage/
  Derivation.lean` mirrors `ProofSystem/Derivation.lean` constructor-for-constructor;
  `MinusDeduction.lean` mirrors `Theorems/DeductionTheorem.lean`). The MCS layer and canonical
  frame should be presented the same way, with `Core/MaximalConsistent.lean` and
  `BXCanonical/Frame.lean` named as the copy sources in the module docstrings.
- Past-side results are obtained by TR on the future result at `χ.reflectTime`, transported along
  `reflectTime_involution`, never re-derived (`boxGlobalPast`, `notBoxGlobalPast`).
- Frame-class gates are discharged by `FrameClass.base_le fc` for TM⁻ axioms and by
  `show FrameClass.Dense ≤ FrameClass.Dense by decide` / `le_refl` for `Axiom.dn`.

### External Resources

- Mathlib (pinned `v4.33.0-rc1`): `zorn_subset_nonempty`, `exists_surjective_nat`,
  `Nat.unpair`/`Nat.pair`/`Nat.unpair_pair`/`Nat.right_le_pair`, `exists_between`,
  `Finset.max'`/`min'`, `NoMaxOrder ℚ`/`NoMinOrder ℚ`/`DenselyOrdered ℚ`, `Set.Finite`,
  `Order.iso_of_countable_dense` (available, not needed).
- Burgess 1984 §2.5 (tense logic of ℚ): the step-by-step construction; Goldblatt 1992 ch. 6:
  canonical density/linearity lemmas for Kt4.3-style logics. The tree already cites both
  (`BXCanonical/Completeness.lean` references).

### Recommendations

Six implementation phases, each bounded to one agent run, in dependency order:

1. **MinusMCS.lean** — MCS layer over `MinusFormula` (probe §1 as the seed; add closure
   properties, `MPoint`). ~450 lines. Acceptance: mirrors of every `Core` lemma used in 3.3.
2. **MinusTemporalDerived.lean** — the derived TM⁻ theorems of 3.2 including
   `minusGeneralizedTemporalK`, `mkGeneralized`, the DN dual, and all TR mirrors. ~500 lines.
3. **MinusCanonicalFrame.lean** — `canR`/`canBox`, transitivity, converse characterization,
   existence lemmas, seriality, **density**, **weak linearity** (both sides), box equivalence and
   MF-closure. ~600 lines. Acceptance: `exists_canR_between` stated at `.Dense`, everything else
   at variable `fc`.
4. **MinusChronicle.lean** — stages, `insert_future`/`insert_past`, `fill`, `step`, `stages`,
   limit, `exists_chronicle_through`. ~900 lines. This is the risk phase; if it overruns, split
   into 4a (placement and interpolation lemmas on a single stage) and 4b (enumeration, iteration,
   limit).
5. **MinusChainCompleteness.lean** — `FamIdx`, valuation, `truth_lemma`, `chainComplete_dense`,
   `minusExt_iff_tmFrag_dense`, plus `minusValidIn_chainValidIn`, `tmMinusComplete_dense`,
   `forward_dense`. ~300 lines.
6. **Wiring and records** — aggregator, README inventory, `mk_all`, theorem-index rows with C14
   pins (script heredoc pair), docstring revisions listed in §5, `lean_verify` on the two named
   deliverables, `check-module-invariants.sh`.

Class choice justification for the plan: `.Dense`/`∅` is the only row where (a) no schema set has
to be shown consistent with the construction, (b) the classical proof is a single uniform
construction with no dense/discrete split, and (c) all four TM⁻_d-specific ingredients (DN dual,
TL, TS, TC) are already axioms or two-line derivations in the tree. `.Base` would need this whole
route *and* a discrete engine *and* the (Sp) split inside the truth lemma's box case; `.ZTime`
would need a discrete engine whose correctness relies on the Z1 limit-closure argument, where
weak completeness must be proved without compactness.

## Decisions

- Keep `.Dense` with `Ax = ∅` (justified above); do not switch classes.
- Build the chain directly on ℚ by ω-stage insertion (Burgess §2.5); reject
  canonical-model-plus-bulldozing (does not land in a chain bundle, §2) and Löwenheim–Skolem
  (disproportionate).
- Index the bundle by one `canBox`-class of chronicles; the truth lemma's box case is closed by
  chronicle existence through a `◇`-witness.
- The MCS layer, relations and truth lemma are new L⁻-typed modules mirroring `Core` and
  `BXCanonical/Frame.lean`; nothing is imported from the Formula-typed canonical models.
- The probe's `chainComplete_dense_of_engine` shape is the assembly contract; the plan should keep
  the engine (`∃ FamIdx v q, ¬ chainSat v q φ` at `TemporalOrder.of ℚ`) as the interface between
  phases 4/5 and the final theorem.

## Risks & Mitigations

- **Phase 4 size/overrun** — the placement lemma has a four-way case analysis with `Finset`
  extrema. Mitigation: split 4a/4b as above; state `insert_future` with the disjunctive conclusion
  exactly as in §3.4 so that the "already present" case never has to place a duplicate irreflexive
  point.
- **Reflexive MCSs at many rationals** — not a risk on this route (coherence only needs `canR`),
  but the plan must not add an injectivity requirement to `Chronicle`.
- **Derivation verbosity** — L⁻ derivations are explicit `DerivationTree` terms. Mitigation: derive
  everything through `minusDeductionTheorem` in a context (as `MinusDeduction.lean` does) and reuse
  `minusImpTrans`/`minusContrapos`; every past lemma by TR, never by hand.
- **Docstring drift** — the five docstrings/README table listed in §5 assert "never asserted /
  open at `.Dense`"; leaving any of them stale is a correctness defect in prose. Mitigation: phase 6
  checklist; grep for `ChainComplete`, `TMMinusComplete .Dense`, `open` in the Conservativity
  directory before closing.
- **C14 pin mechanics** — the theorem-index row is only honest if the baseline heredoc pair in
  `check-module-invariants.sh` gains the declaration; the script compares by exact string.
  Mitigation: phase 6 runs the full script after the edit.
- **Universe of `FamIdx`** — `ChainValidIn` fixes `FamIdx : Type`; `{c : Chronicle // …}` with
  `Chronicle` built from `ℚ → Set MinusFormula` lives in `Type` (probe compiles the structure).

## Tactic Survey Results

- Not applicable (no tactic survey performed): the research produced no open proof goals to test;
  the probe's proofs are term-level mirrors and `simp`/`rw` on `Nat.unpair_pair`.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `(fun n => f (Nat.unpair n).1) (Nat.pair k m) = r` | `rw [Nat.unpair_pair]; exact hk` | success | after `show` |
| `L ⊆ [φ.neg]` from `∀ ψ ∈ L, ψ ∈ {φ.neg}` | `simp only [Set.mem_singleton_iff]; simp` | success | — |

## Context Extension Recommendations

- **Topic**: L⁻-side canonical-model idioms (TR-mirroring of past lemmas, `Axiom.dn` gate
  discharge at `.Dense`, `Chronicle`/stage representation).
- **Gap**: `context/project/lean4/` has no note on the TM⁻ side's transposition conventions; an
  implementer will rediscover the `reflectTime_involution ▸ time_reflection` idiom.
- **Recommendation**: after implementation, add a short pattern note under
  `context/project/lean4/patterns/` describing the mirror-by-transposition convention and the
  ℚ-step-by-step chronicle shape, pointing at the landed modules.

## Appendix

- Search queries used: `lean_local_search` for `exists_surjective_nat` (found),
  `Nat.surjective_unpair` / `Nat.unpair` / `Finset.max'` / `Order.iso_of_countable_dense` (local
  index returned nothing; all four confirmed by `#check` in the compiled probe), `exists_between`
  (found, with `Finset.exists_between` variants). Rate-limited tools were not needed.
- Probe compile: `lake env lean specs/651_chain_complete_dense_tm_minus/probes/01_minus-mcs-lindenbaum-and-assembly.lean`
  → exit 0, no errors, no `sorry` warnings; `#check` output recorded the exact Mathlib signatures.
- Key file references: `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean`
  (`ChainValidIn`, `ChainComplete`, `minusExt_empty_iff_tmFrag_dense_of_chainComplete`),
  `ChainBundleTruth.lean` (`chainSat`, `chainBundle_truth_lemma`), `MinusExt.lean`
  (`minusExt_empty_iff`), `MinusDeduction.lean` (deduction theorem and combinators),
  `Metalogic/Core/MaximalConsistent.lean` (copy source for phase 1),
  `Metalogic/BXCanonical/Frame.lean` and `TruthLemma.lean` (copy sources for phase 3),
  `Theorems/GeneralizedNecessitation.lean` (`generalizedTemporalK`, copy source for phase 2),
  `docs/theorem-index.md` and `scripts/check-module-invariants.sh` (C14 heredoc pair, phase 6).
