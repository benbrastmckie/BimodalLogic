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
| `Backward.lean` | 211 | <!-- TODO: add description --> |
| `ChainBundleTruth.lean` | 241 | The valuation-only truth lemma for the flow frames of `Metalogic/Algebraic/FlowFrame.lean`: `chainSat` (Kripke satisfaction on a disjoint union of `D`-chains, `□` universal) and `chainBundle_truth_lemma`, plus the transfer corollary `not_minusValidIn_of_not_chainSat` and its ℚ/ℝ instantiations |
| `DenseObstructionTransfer.lean` | 279 | Machine-checked evidence that neither closed row's separating witness transfers to the dense classes: `Sp` is a theorem of both `TM⁻_d` and `TM⁻_dc` (`spDerivableDense`, `spDerivableRTime`), and `Z1` is refuted on the flow frame over ℚ (`not_minusValidDense_z1`) |
| `Fragment.lean` | 190 | <!-- TODO: add description --> |
| `FragmentCompactness.lean` | 150 | <!-- TODO: add description --> |
| `MinusLanguageSoundness.lean` | 605 | <!-- TODO: add description --> |
| `Plus.lean` | 66 | <!-- TODO: add description --> |
| `SpCountermodel.lean` | 390 | CEB's failing half: native L⁻ soundness for TM⁻ against `Semantics/MinusLanguage/MinusFrame.lean`'s `TaskFrame`-free semantics (`minusFrameValid_of_axiom`, `minusFrameValid_of_derivation`), the two-fibre countermodel `ℤ ⊕ ℝ`, and the deliverables `not_derivable_sp` and `tmMinusCompleteBase_refuted` |
| `SpWitness.lean` | 138 | <!-- TODO: add description --> |
| `Star.lean` | 50 | Aggregator for the L⋆ metatheory; holds no declarations. |
| `TMCompletenessReduction.lean` | 309 | <!-- TODO: add description --> |
| `Z1Countermodel.lean` | 198 | <!-- TODO: add description --> |
| `Plus/` | — | <!-- TODO: add description --> |
| `Star/` | — | The register extension L⋆ = L⁺ + `↑ⁱ`/`↓ⁱ` and its logic TM⋆: axiom validity, soundness, conservativity over TM (unconditional) and over TM⁺ (a conditional pair), and the completeness OPEN record. |
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

*Last verified: 2026-09-08*
