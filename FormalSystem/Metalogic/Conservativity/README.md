# Metalogic/Conservativity

The three conservativity questions this development answers, and the one it refuses to attempt.

| Extension | Direction | Status |
|-----------|-----------|--------|
| L⁻ ⊂ L (TM⁻ into TM, via `tr`) | backward | **proved** — `derivable_translate` and the four row corollaries |
| L⁻ ⊂ L | forward | **refuted** at `.Base` and `.ZTime` — both rows machine-checked (`tmMinusCompleteBase_refuted`, `tmMinusCompleteZTime_refuted`); **open** at `.Dense` and `.RTime` |
| L ⊂ L⁺ (TM into TM⁺, via `ofFormula`) | both | **proved** at all four classes — `plusDerivable_ofFormula_iff` |

The **canonical four-row status table** for the forward row above — including what the two open
rows would still need, and the named obstruction at `.RTime` — lives in
[`TMCompletenessReduction.lean`](TMCompletenessReduction.lean)'s module docstring. Read it there
rather than reconstructing the status from the modules; it is the single place kept current.

Per-theorem status — statement, frame class, machine-pinned axiom set — is in
[`docs/theorem-index.md`](../../../docs/theorem-index.md), the single ledger. The standing
prohibition on attempting or `sorry`-ing the forward direction of L⁻ ⊂ L, with the CEB/CEF/CED/CEC
row analysis that grounds it, is in the aggregator
[`../Conservativity.lean`](../Conservativity.lean) and is not repeated here.

**Do not state a forward-conservativity theorem for L⁻ ⊂ L.** It is provably false at
`fc := .Base` and `fc := .ZTime`, so a `sorry` on it would be an unsound placeholder rather
than deferred debt.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Conservativity -->
| File | Lines | Description |
|------|------:|-------------|
| `Backward.lean` | 212 | <!-- TODO: add description --> |
| `ChainBundleTruth.lean` | 240 | The valuation-only truth lemma for the flow frames of `Metalogic/Algebraic/FlowFrame.lean`: `chainSat` (Kripke satisfaction on a disjoint union of `D`-chains, `□` universal) and `chainBundle_truth_lemma`, plus the transfer corollary `not_minusValidIn_of_not_chainSat` and its ℚ/ℝ instantiations |
| `DenseObstructionTransfer.lean` | 283 | Machine-checked evidence that neither closed row's separating witness transfers to the dense classes: `Sp` is a theorem of both `TM⁻_d` and `TM⁻_dc` (`spDerivableDense`, `spDerivableRTime`), and `Z1` is refuted on the flow frame over ℚ (`not_minusValidDense_z1`) |
| `Fragment.lean` | 195 | <!-- TODO: add description --> |
| `FragmentAxiomatization.lean` | 338 | The canonical per-class verdict record for the native H/G axiomatization of `TMFrag`: Σ_Base = (Sp), Σ_ZTime = Z1, Σ_Dense = Σ_RTime = ∅; soundness `TM⁻ + Σ_fc ⊆ TMFrag fc` at all four classes and strictness over TM⁻ at Base/ZTime machine-checked; completeness literature-backed only, present in Lean solely as the explicit hypothesis `ChainComplete` of `minusExt_iff_tmFrag_of_chainComplete` |
| `FragmentCompactness.lean` | 151 | <!-- TODO: add description --> |
| `MinusDeduction.lean` | 319 | Syntax-only L⁻ layer: the deduction theorem for TM⁻ (`minusDeductionTheorem`, computable, by structural recursion over a subset-generalized statement), its converse, five propositional combinators, S5's B and 4, and the four `□`-globality derivations `boxGlobalFuture`/`boxGlobalPast`/`notBoxGlobalFuture`/`notBoxGlobalPast` |
| `MinusExt.lean` | 180 | `MinusExt fc Ax`, the `Prop`-valued theorems-only closure of TM⁻ at `fc` plus a schema-instance set `Ax` under MP/MN/TN/TR, with `minusExt_empty_iff` (it is TM⁻ at `Ax = ∅`) and the soundness engine `minusExt_le_tmFrag` (`Ax ⊆ TMFrag fc → MinusExt fc Ax ⊆ TMFrag fc`) |
| `Plus.lean` | 76 | <!-- TODO: add description --> |
| `SpCountermodel.lean` | 399 | CEB's failing half: native L⁻ soundness for TM⁻ against `MinusLanguage/MinusFrame.lean`'s `TaskFrame`-free semantics (`minusFrameValid_of_axiom`, `minusFrameValid_of_derivation`), the two-fibre countermodel `ℤ ⊕ ℝ`, and the deliverables `not_derivable_sp` and `tmMinusCompleteBase_refuted` |
| `SpWitness.lean` | 136 | <!-- TODO: add description --> |
| `Star.lean` | 60 | Aggregator for the L⋆ metatheory; holds no declarations. |
| `TMCompletenessReduction.lean` | 324 | <!-- TODO: add description --> |
| `Z1Countermodel.lean` | 200 | <!-- TODO: add description --> |
| `Plus/` | — | <!-- TODO: add description --> |
| `Star/` | — | The register extension L⋆ = L⁺ + `↑ⁱ`/`↓ⁱ` and its logic TM⋆: axiom validity, soundness, conservativity over TM (unconditional) and over TM⁺ (a conditional pair, whose hypothesis is refuted at Base by `Metalogic/Independence/PlusIncompleteness.lean` and open elsewhere), and the completeness OPEN record. |
<!-- END GENERATED -->

## Key Results

- `translate` / `derivable_translate` — the backward bridge, by structural recursion over TM⁻
  derivations, parameterized by `FrameClass` so the paper's four rows are four instantiations
- `ceb_backward`, `cef_backward`, `ced_backward`, `cec_backward` — the four row corollaries
- `minus_soundness{,_dense,_ztime,_rtime}` — soundness of L⁻ against the **native** `MinusTruthAt`
  semantics, obtained by composing `translate` with the TM soundness theorems across the
  truth-transfer bridge `Semantics.truthAt_tr`
- `TMFrag` and its metatheory — the H/G-fragment of TM is the complete logic of base-language
  validity, which TM⁻ itself is not
- `tmMinusCompleteBase_iff_forwardBase` and its `.ZTime` mirror — equivalences between two unasserted
  `Prop`s, proving neither side
- `not_derivable_sp` / `tmMinusCompleteBase_refuted` — the CEB row's failing half: the schema `(Sp)`
  is not a TM⁻-theorem, refuted on the disjoint sum `ℤ ⊕ ℝ` over the native, `TaskFrame`-free
  `MinusFrame` semantics, with `minusFrameValid_of_derivation` supplying the soundness
  step the composition route could not
- `not_minus_derivable_z1` / `tmMinusCompleteZTime_refuted` — the same for the CEF row over ℤ-time
- `chainSat` / `chainBundle_truth_lemma` / `not_minusValidIn_of_not_chainSat` — the transfer half
  of the standard completeness route over the dense classes, done once and generically: a
  chain-model refutation is a task-frame refutation. The frame construction the route also needs
  was already generic in `Metalogic/Algebraic/FlowFrame.lean`, and the canonical-model half is
  **not** here
- `spDerivableDense` / `spDerivableRTime` / `not_minusValidDense_z1` — the two closed rows'
  separating witnesses provably fail to transfer to `.Dense` and `.RTime`: `Sp` is a *theorem* of
  both open systems, and `Z1` is not a validity of the dense class. Evidence about the two open
  rows, and **not** a completeness result; the four-row status is in
  `TMCompletenessReduction.lean`'s module docstring
- `MinusExt` / `minusExt_le_tmFrag` — TM⁻ plus a schema set as a theorems-only closure, and the
  soundness engine: anything `TM⁻ + Ax` proves is in the fragment whenever `Ax` is
- `sigmaBase` / `sigmaZTime` with the four soundness rows `minusExt_*_le_tmFrag` and the two
  strictness rows `tmMinus_lt_minusExt_sigmaBase` / `tmMinus_lt_minusExt_sigmaZTime` — the native
  axiomatization verdict per class, Σ_Base = (Sp), Σ_ZTime = Z1, Σ_Dense = Σ_RTime = ∅; the
  canonical record is `FragmentAxiomatization.lean`'s module docstring
- `minusExt_iff_tmFrag_of_chainComplete` — conditional completeness: `TM⁻ + Ax = TMFrag fc` given
  `ChainComplete fc Ax` (completeness over `chainSat` bundles), a hypothesis the classical H/G
  completeness theorems supply on paper and **no declaration in the tree concludes**
- `minusDeductionTheorem` and `boxGlobalFuture` / `boxGlobalPast` / `notBoxGlobalFuture` /
  `notBoxGlobalPast` — the L⁻ deduction theorem and the proof-theoretic side of "`□` is
  universal on a task model", at every frame class
- `plusDerivable_ofFormula_iff` — conservativity of TM⁺ over TM in both directions
- `starDerivable_ofFormula_iff` — conservativity of **TM⋆** over TM in both directions, at all
  four classes and unconditionally; with `starConservative_of_plusComplete` and its unconditional
  contrapositive `plusIncomplete_of_starNonconservative`, which place the L⁺ ⊂ L⋆ question inside
  the tree's own open TM⁺-completeness problem rather than asserting or denying it

## Related Documentation

- [Metalogic README](../README.md)
- [`Plus/`](Plus/README.md) — the L⁺ half
- [`Star/`](Star/README.md) — the L⋆ half: TM⋆'s soundness, the two conservativity rows, and the completeness OPEN record
- [`../Conservativity.lean`](../Conservativity.lean) — the aggregator and the standing prohibition
- [`docs/theorem-index.md`](../../../docs/theorem-index.md) — per-theorem status

---

*Last verified: 2026-09-22*
