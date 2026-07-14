# Phase R1 Implementation Summary — EANegationFix.lean split (task 350)

## Phase Executed

Phase R1 (plan v3, `plans/03_negfix-refactor-exterior-carriers.md`): MECHANICAL split of the
sorry-free 2,907-line negation kit `Kamp/EANegationFix.lean` into a `Kamp/EANegationFix/`
6-leaf module DAG + re-export shim at the old path. Single-phase dispatch; Phase 11 not started.

## What Moved (verbatim — zero proof rewriting)

| Leaf | Lines | Content (Rabinovich layer) | Imports |
|------|-------|---------------------------|---------|
| `OnBuilder.lean` | 255 | witness combination + `negChainOn(_iff)` (Lemma 5.3) | VecEAConjFull, EANegation, EANegationClosure |
| `BoundedFix.lean` | 858 | Until/Since folds, `chainAllTrue`, list brackets, `negBounded{Right,Left}Fix(_iff)` (Cor 5.4) | OnBuilder |
| `BoundedFixAnchored.lean` | 484 | anchored folds + `negBounded{Right,Left}FixAnchored(_iff)` | BoundedFix |
| `ConcatPin.lean` | 121 | `bracketOf_append_pin_holds_iff`, `(V)BracketFormula.concatPin(_holds_iff)` (Lemma 7.6) | BoundedFix |
| `NegFixOne.lean` | 557 | `negFix1*`, `negFixOne_cover/_iff`, `NegFixGateProbe` (Lemma 5.1 n=1) | BoundedFixAnchored, ConcatPin |
| `NegFix.lean` | 681 | `BracketFormula.negFix(_iff)` general recursion (Lemma 5.1) | NegFixOne, ConcatPin, BoundedFixAnchored, VecEAConjFull |
| `EANegationFix.lean` (shim) | 27 | import-only re-export aggregator | all six leaves |

Cut points against the live file: 1-253 / 254-1102 / 1103-1577 / 1578-1689 / 1690-2236 / 2237-2906.

## Seams (one green commit per leaf move)

R1.1 OnBuilder (f4ab474b6), R1.2 BoundedFix, R1.3 BoundedFixAnchored, R1.4 ConcatPin,
R1.5 NegFixOne, R1.6 NegFix + shim. Full `lake build` green before every commit.

## Final Verification

- Full `lake build`: green, 1745 jobs (1739 pre-split + 6 new modules)
- Verbatim relocation: reconstructed concatenation of the six leaves diffs byte-for-byte clean
  against `git show HEAD~6:...EANegationFix.lean`
- `lean_verify` on a representative export from every leaf = exactly
  `[propext, Classical.choice, Quot.sound]` (`negChainOn_iff`, `negBoundedRightFix_iff`,
  `negBoundedRightFixAnchored_iff`, `bracketOf_append_pin_holds_iff`, `negFixOne_iff`,
  `BracketFormula.negFix_iff`)
- Sorries in scope: 0; vacuous definitions in scope: 0; repo axiom count unchanged from baseline
- Acyclicity: no leaf imports the shim; no leaf imports any NfMultiAnchorBridge module
- `NfMultiAnchorBridge.lean:78` byte-identical; task-358 territory files
  (KampPrior, ExteriorPinnedConverseK, ExteriorPinnedConversePastK) untouched

## Sorry Inventory

Empty.

## Plan Deviations

None. The plan's per-file export/import spec was followed exactly; line ranges were recomputed
against the live 2,907-line file as the plan directs.
