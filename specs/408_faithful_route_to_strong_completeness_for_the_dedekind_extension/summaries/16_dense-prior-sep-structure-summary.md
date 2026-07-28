# Phase 16 — The chronicle structure is a dense Prior structure satisfying Sep

## What landed

`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean`, 581 -> 1116 lines.
Zero other Lean files modified; zero pre-existing declarations edited, removed or renamed.

Reynolds §4 Corollary 1 clause 3 — *"all substitution instances of the axioms Prior-U, Prior-S
and Sep are valid in `M`"* — at the structure Phase 15 built.

| Part | Declarations |
|------|--------------|
| 5. Unrestricted coherence | `cantor_bfmcs_dense_fuc`, `cantor_bfmcs_dense_buc` |
| 6. Effective truth correspondence | `chronicleEff` + 11 `rfl` commutation lemmas, `chronicleMonadic_truth_effective` |
| 7. The three axioms | `SemanticSep`, `chronicleMonadic_semanticPriorU`, `chronicleMonadic_semanticPriorS`, `chronicleMonadic_semanticSep` |
| 8. The package | `IsDensePriorSepStructure`, `chronicleIsDensePriorSepStructure`, `chronicleMonadic_expressiveCompleteness` |

## Source grounding

Reynolds' Corollary 1 was located verbatim in the local corpus at
`reynolds_1992/sec02_3-irr.md` and is block-quoted character-for-character in the Part 7 section
docstring, including the preceding justification sentence that *is* the proof route:

> Because it says so in $\Gamma$, all the substitution instances of the other axioms hold
> everywhere so we have...

Executed in Lean as: `minFrameClass = .Dedekind` (`Axioms.lean:524-526`) → `theorem_in_mcs`
(`Core/MaximalConsistent.lean:491`) → Part 6 → `kPlus_formula_correct` / `kMinus_formula_correct`
(`Kamp/KPlusFaithful.lean`). Reynolds gives no argument beyond that sentence, so the Lean
execution is recorded in the docstrings as original glue on a sourced statement. `Formula.kPlus`
is read through the named bridge lemma; `kplusFormula` is not substituted for it.

Reynolds' Lemma 10 (Sep's validity over ℝ) is **not** re-derived — Sep is obtained the way
Corollary 1 obtains it, from the axiom's membership in the MCS.

## The one place the plan's route was under-specified

The plan's Route ends "hence true at every point by Phase 15's truth correspondence". That
correspondence is bounded by `subformulaClosure root`; `SemanticPriorU`/`SemanticPriorS`/`Sep`
quantify over all formulas, so it cannot close the step. Parts 5 and 6 supply what the last move
needed:

- Part 5 obtains unrestricted Until/Since coherence by **self-root instantiation** of the
  existing `cantor_bfmcs_dense_restricted_fuc`/`_buc`, whose proofs open `intro t φ ψ _` and
  discard their closure argument. This is the pattern `cantor_bfmcs_dense_limit_guard_above`
  (`ChronicleLimitGuardAbove.lean:203`) already uses. Twelve lines, no proof duplication.
- Part 6 re-runs the correspondence at `effectiveFormula` (`Transfer.lean:1004`), which rewrites
  atoms and box-subformulas through the signature round trip and leaves the temporal skeleton
  alone, so no closure bound is needed.

Phase 15's closure-bounded correspondence is retained unweakened; the plan's three-move route and
all four of its named declarations are unchanged.

Phases 17-22 need the unrestricted form regardless: the auxiliary formulas they obtain from
expressive completeness are not subformulas of the root.

## Naming reconciliation carried forward

The plan cites `kampDedekindExpressiveCompleteness`. No such declaration exists. The landed names
are `KampFaithfulExpressiveCompleteness` / `kampFaithfulExpressiveCompleteness_open`, composed
into `uSExpressivelyCompleteOverDensePrior` (`PriorExpressivenessDense.lean:302`) — which is what
`chronicleMonadic_expressiveCompleteness` applies.

## Verification

- `#print axioms` on all eight new top-level declarations: `[propext, Classical.choice,
  Quot.sound]`. `sorryAx` absent despite the `Transfer.lean` import.
- Live tree sorry count: 1 (`Transfer.lean:1242`, pre-existing, unrelated, unchanged).
- New vacuous definitions: 0. New axioms: 0.
- `lake build`: green, 1927 jobs.
