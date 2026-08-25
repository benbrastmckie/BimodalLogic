# Implementation Summary: TM/TM+ Conservativity Bridge — Backward Direction

- **Task**: 413
- **Plan**: `specs/413_formalize_tm_conservativity_bridge/plans/01_tm-conservativity-backward-bridge.md`
- **Type**: lean4
- **Status**: all 9 phases COMPLETED
- **Session**: sess_1787618565_717c84 (dispatch 17)

## What landed

**Deliverable A — the bridge (sorry-free).**

A self-contained `FormalSystem/BaseLanguage/` cluster for the tense-primitive base language BL,
plus the backward bridge `TM |- phi ==> TM+ |- tr phi` in
`FormalSystem/Metalogic/Conservativity.lean`.

| File | Contents |
|---|---|
| `FormalSystem/BaseLanguage/Formula.lean` | `BLFormula` (6 primitives, H/G primitive), derived operators, `swapBL`, `swapBL_involution`, `Context` |
| `FormalSystem/BaseLanguage/Axioms.lean` | `BaseLanguage.Axiom` (16 constructors: CPL 4 + MK/MT/M5/MF + TK/T4/TB/TA/TL + DF/DN/CO), `Axiom.minFrameClass` |
| `FormalSystem/BaseLanguage/Derivation.lean` | `BaseLanguage.DerivationTree` (7-rule mirror, TD via `swapBL`), `Derivable`, `|-BL[fc]` notation, `lift`, `temporalNecessitationDerivable` |
| `FormalSystem/BaseLanguage/Translation.lean` | `tr`, `tr_swapBL`, `tr_ne_untl`/`tr_ne_snce`, `tr_injective`, `trCtx`, `mem_trCtx` |
| `FormalSystem/BaseLanguage/AxiomDischarge.lean` | monotone-congruence toolkit, the `F`/`P` bridge, 16 per-axiom discharge lemmas, `dischargeAxiom` |
| `FormalSystem/Theorems/DiscreteUnfolding.lean` (append) | `nextAllFuture`, `prevAllPast`, `dfSchema` — the DF derivation at `Discrete` |
| `FormalSystem/Metalogic/Conservativity.lean` | `translate`, `derivable_translate`, `ceb_backward`, `cef_backward`, `ced_backward`, `cec_backward`, `Z1`, `z1_translate` |

**Deliverable B — the refutation record.** The module docstring of
`FormalSystem/Metalogic/Conservativity.lean` records that the forward direction is REFUTED for
the Base and Discrete rows and OPEN for the other two, naming `Axiom.z1` and
`Axiom.discrete_box_necessity` as the evidence, stating the zero-debt consequence (a `sorry` on
`forward` would sit on a provably false statement), and citing the deleted-theorem provenance as
history rather than as a live `\label`.

## Acceptance gate

| Check | Result |
|---|---|
| `lake build` (full, clean state) | GREEN, 2487 jobs |
| New `sorry` anywhere | NONE — order-independent diff of the repo-wide live-`sorry` inventory against the pre-task baseline is empty; the one pre-existing live `sorry` (`WeakCanonical/Transfer.lean:1102`, `countermodel_discrete`) is untouched |
| New `axiom` declaration | NONE — repo-wide `^axiom ` line count is 7, equal to baseline, and all 7 are prose lines in pre-existing `Semantics/` docstrings, not declarations |
| Vacuous definitions in new files | NONE |
| `#print axioms ceb_backward` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms cef_backward` | `[propext, Classical.choice, Quot.sound]` — no `completeness_*` dependency, so Route B did not creep in |
| `#print axioms ced_backward` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms cec_backward` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms tr_swapBL` | `[propext]` |
| `#print axioms dfSchema` | `[propext, Classical.choice, Quot.sound]` |
| `grep '^import FormalSystem.Semantics' BaseLanguage/ Conservativity.lean` | empty; also empty transitively (checked by import-closure walk) |
| Forward direction stated or `sorry`-ed | NO — the string `theorem forward` occurs exactly once in the tree, inside a fenced code block in the Conservativity module docstring, where Phase 9 required it to be quoted as the thing not to write |
| Docstring names `Axiom.z1` / `Axiom.discrete_box_necessity` / `58c7c0c0^` | 3 / 1 / 1 occurrences |
| `bash scripts/check-paper-definitions.sh` | run; same two drifted (`def:strongest`, `thm:exist`) and six dangling anchors the research report recorded — none consumed by this work |

## Route A vs Route B (Phase 5)

**Route A only. Route B (`completeness_discrete`) was never used and no approval was needed.**
`#print axioms dfSchema` shows no completeness dependency.

Route A as actually executed differs from the research report's three-step sketch. The report
predicted step 3 would be the literal past-dual of `unfoldForward`. It is not: what closes the
gap is `nextAllFuture : |-[Discrete] X(G phi AND phi) -> G phi`, which *consumes* `unfoldForward`
(at guard `top`) together with `nextConj`, rather than being its dual. The step the report did
not name is `Axiom.enrichment_until` at guard `bot`, event `top`, payload `p := H phi AND phi`,
which is what transports the payload to the successor as a `Y`-formula. The past dual really is
free, as predicted, via `DerivationTree.temporal_duality` plus `swap_temporal_involution`.

The `F top` conjunct of DF's antecedent is not consumed: at `Discrete` the stronger `X top` is
already a theorem via `succIndicator`. It is retained because the schema, not the derivation, is
what `tr` of the BL-side `Axiom.df` must match.

## Plan Deviations

1. **Phase 2 — `Axiom` is `Type`-valued, not `Prop`-valued** (plan said `Prop`). `Prop` is
   impossible on two counts the plan's own task list presupposes: `Axiom.minFrameClass` is a
   function into data, and `translate` pattern-matches an `Axiom` node while producing a
   `DerivationTree` (a `Type`). `ProofSystem.Axiom` is likewise `Type`-valued, so this is the
   mirror the plan asked for.

2. **Phase 4 — the `somePast`/`someFuture` push-through lemmas are FALSE and were replaced.**
   The plan asked for `tr (someFuture phi) = Formula.someFuture (tr phi)`. That is not a
   theorem. `tr (BL.someFuture phi) = ¬G¬(tr phi)`, whereas `Formula.someFuture` is a top-level
   `untl` — and by `tr_ne_untl` nothing in the range of `tr` is a top-level `untl`, so no choice
   of BL-side abbreviation could have made it exact. Landed instead: `tr_someFuture` /
   `tr_somePast` (the shapes `tr` really produces) and `tr_someFuture_ne` / `tr_somePast_ne`
   (machine-checked non-equalities). `neg`/`and`/`or`/`top`/`diamond`/`always` push through by
   `rfl` as planned.

3. **Phase 6 — the report's "exact syntactic match" claims for TA and TB are REFUTED**, as a
   direct consequence of deviation 2. MF's exact-match claim is the only one that survives
   (CONFIRMED). DN's "literally the same formula" claim also holds (CONFIRMED). Every axiom
   mentioning `F` or `P` — TB, TA, TL, DF, CO — needs the derivable equivalence `¬G¬psi <-> F psi`
   (`notGNot_imp_F` / `F_imp_notGNot` and their past duals) plus monotone congruence to apply it
   under `AND`, `->`, `G`, `H`, `F` and the temporal triangle. That machinery is the first
   section of `AxiomDischarge.lean` and was not anticipated by the plan; it is why that file is
   larger than the plan's estimate.

4. **Phases 6 and 7 executed in one file write.** The plan already has Phase 7 appending to the
   file Phase 6 creates and marks them sequential; this changes no ordering and only avoids a
   throwaway intermediate build.

5. **`decide` is not usable for the `minFrameClass <= fc` side conditions** (plan specified it
   in Phases 7 and 8): the goals carry a free `fc` or a free `phi`, and `decide` rejects goals
   with free variables. It also turned out to be unnecessary — on every extension row the
   BL-side `h_fc` reduces to exactly the hypothesis the BL+ asset already wants (`Dense <= fc`,
   `Dedekind <= fc`, `Discrete <= fc`), so it is threaded through unchanged; Base rows use
   `FrameClass.base_le fc`. Where a closed-frame-class regression `example` did want `decide`,
   it is routed through `show` at the reduced frame class first.

6. **Phase 3 — `Context` lives in `BaseLanguage/Formula.lean`, not `Derivation.lean`.**
   `Translation.lean` also needs it and neither file imports the other; defining it in both
   would collide in the aggregator.

7. **Phase 9 — the deleted-theorem provenance in the plan is off by two commits and two days,
   and the docstring records the corrected version.** The plan and the research report both say
   `\label{thm:ConservativeExtension}` was deleted at paper commit `c0116d04` (2026-08-14). It
   was actually removed at `b07ceb31` (2026-08-12); `c0116d04` is where the last *prose*
   assertion of conservativity was rewritten, and its only remaining occurrence of the string is
   a source comment describing the label as already deleted. Verified by walking
   `git log -- JPL/possible_worlds.tex` and counting the label per revision. The instructed
   citation `58c7c0c0^` is retained and is accurate — `58c7c0c0^` = `330bb25d` (2026-08-12) is
   the last revision carrying the theorem together with its full seven-site cross-reference set.

8. **Phase 9 — one addition beyond "docstring only": `Z1` and `z1_translate`.** The plan asked
   the docstring to assert `z1 phi = tr (Z1 phi')` as a syntactic identity. By deviation 2 that
   is false. Rather than write a false claim into the tree, the corrected claim is *proved*:
   `z1_translate : |-![Discrete] tr (Z1 phi)`, two lines (the axiom plus the standing `F`-bridge).
   This strengthens Deliverable B — the TM+ half of the CEF witness is now machine-checked
   rather than asserted — and states nothing about the forward direction. `impMono` was made
   public in `AxiomDischarge.lean` to support it.

## Not done, and why

- The forward direction, in any form. Prohibited, and provably false for two of the four rows.
- A machine-checked (rather than documented) refutation. It needs a BL-side semantics, a BL-side
  soundness theorem, and the two-fibre and `Z x_lex Z` countermodels. All three are out of scope
  per the plan's Non-Goals and are separate task material.
