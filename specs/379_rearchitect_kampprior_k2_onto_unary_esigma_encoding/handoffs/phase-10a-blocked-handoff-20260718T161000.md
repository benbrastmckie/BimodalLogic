# Phase 10a Handoff — BLOCKED (E[Σ] collapse crux) + 10a-ii assembly landed

- **Task**: 379 — rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Plan**: `plans/10_negation-collapse-bridge.md` (active/revised)
- **Session**: sess_1784408397_6a5f80
- **Dispatch outcome**: Phase 10a `[BLOCKED]` (verified); 10a-ii assembly half landed green.

## Immediate Next Action

Run a `/research 379 --hard --lit` dispatch scoped to the **Phase 10a E[Σ]-capture hypothesis**
(see Blocker below). Do NOT re-attempt Phase 10a implementation until the capture hypothesis is
determined — the residual is a genuine Def 4.1 obstruction, not a tactic gap. Do NOT force with
`sorry`.

## Current State

- Phases 0–9: COMPLETED, sorry-free, landed (unchanged).
- `VVecEA2Collapse.lean`: NEW, green, sorry-free, off the live import path.
  `vvecea2_collapse_of_perClause` — `#print axioms = [propext, Classical.choice, Quot.sound]`.
- Full `lake build`: EXIT 0 (1770 jobs).
- `#print axioms completeness_discrete`:
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
  — **byte-identical to baseline** (the `sorryAx` is the pre-existing `KampPrior.lean:562`, Phase 13).
- No new `sorry`; no vacuous placeholder; no new axiom.

## Key Decision

Delivered the **10a-ii disjunctive-assembly half** (`vvecea2_collapse_of_perClause`) as a green,
sorry-free reduction lemma taking the per-clause reverse translation `trans`/`htrans` as explicit
inputs. This isolates the blocker precisely and gives the follow-up dispatch a composable landing
point (discharge 10a-i, compose through this lemma → full bridge). This is faithful to the plan's
declared H8 split (10a-i single-clause collapse → 10a-ii disjunctive assembly); only 10a-i is blocked.

## Blocker (verified, source-grounded)

`vvecea2_collapse_bridge` cannot be discharged under `(N, atomMap, h_surj, HasAttainedINF,
HasAttainedSUP)`. The per-clause reverse translation (a `VecEA2` clause → an `ExistsForallFormula
sig F 2` with `efSat ↔ vea.holds`) is the Def 4.1 atom-collapse and has no discharge under these
hypotheses:

1. `prop42_efSat_negation_general` emits
   `v' = (negLeftClauseTL).disj ((middleBracket).negFix) |>.disj (negRightClauseTL)`
   (`Prop42NegationGeneral.lean:997-1004`). Every non-trivial disjunct carries an **arbitrary
   `TL(Until,Since)` `Formula`** at its endpoint — `⟨Formula.neg (belowFormula …)⟩` (`:919`),
   `⟨Formula.neg (aboveFormula …)⟩` (`:950`), and the `negFix` INF/`K⁺` engine. None is a
   `unaryToFormula`-image of a `UnaryType`.
2. A `VeeExistsForall`'s atomic content is `UnaryType`/`IntervalType` — a truth assignment to the
   **unary E[Σ] predicates at a single point** (`unaryHolds_iff`, `ExistsForallFormula.lean:67`),
   expressing only conjunctions of E[Σ] atomic literals. Capturing an arbitrary `TL` formula requires
   the E[Σ] atom-collapse of a **processed** formula — `ESigmaExpansion.atom_eval_new` (`:122`), which
   holds **on `canonExpand …`**: a *definability/capture* property the general `N` does not carry.
3. The added hypotheses do not supply it: `HasAttainedINF`/`HasAttainedSUP` are first-occurrence
   **attainment** facts (`PriorINF.lean:202,254`), not definability; `h_surj` names each `pred` with
   an `Atom`, not each `TL` formula with a `pred`. Exhaustive grep: **no** reverse translation
   (`TL → ∃∀`, `Formula → UnaryType`, `translateProp35`-inverse) exists under `Theories/`; every
   `ExistsForallFormula` producer builds from existing `UnaryType`s.

**Root cause**: same class as the original Phase-10 Axis-2 gap (insufficient hypotheses). The
revision added `atomMap/h_surj/h_INF/h_SUP`, but the reverse E[Σ] collapse actually needs an
**E[Σ]-definability/capture hypothesis** on `N` (a `TL` formula over the processed alphabet is
realized by a `UnaryType` in `N`, the `canonExpand` property). Building `TL → ∃∀` from scratch is
Kamp's hard expressiveness direction — out of scope for a bridge dispatch.

## What Is Needed (concrete)

1. Determine the exact E[Σ]-capture hypothesis — likely `N` is a `canonExpand`, or
   `∀ A, ∃ τ : UnaryType, ∀ y, unaryHolds N τ y ↔ temporal_truth N atomMap y A` over the relevant
   finite formula set.
2. Verify it is available where β is consumed (Phases 11 γ, 12 δ, 13 ζ) — β threads
   `N/atomMap/h_surj/h_INF/h_SUP`; adding a capture hypothesis must be consumable downstream.
3. Re-scope Phase 10a with the capture hypothesis threaded; discharge 10a-i (per-clause collapse),
   then compose it through the landed `vvecea2_collapse_of_perClause`.

## Sorry Inventory (unchanged from baseline gate)

| File | Line | On-path? | Owner |
|------|------|----------|-------|
| `KampPrior.lean` | 562 | YES (sole `sorryAx`) | Phase 13 (ζ) |
| `EANegation.lean` | 1090 | no (off proof term) | amended sorry gate |
| `EANegation.lean` | 1249 | no (off proof term) | amended sorry gate |

## References

- `plans/10_negation-collapse-bridge.md` — Phase 10 BLOCKER block (full detail).
- `reports/07_faithful-esigma-negation-path.md` — R4 "true crux" (the collapse this dispatch hit).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VVecEA2Collapse.lean` — landed 10a-ii assembly.
