# Implementation Summary: Phase 4 — Maximality of the limit set

- **Task**: 408 - faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Plan**: plans/02_strong-completeness-dedekind-v2.md (v2)
- **Phase**: 4 of 9 — "Negation-completeness of the limit set via Prior-U / Prior-S" (the crux)
- **Outcome**: `[COMPLETED]`, sorry-free, full `lake build` green
- **Commit**: `9a59ee625`

## Phases executed

Phase 4 only (single-phase dispatch). Phases 1-3 were already `[COMPLETED]`.

## The crux, and why the planned route was not taken

The phase asked for `limitMCS_no_oscillation` — every formula is eventually constant on the
rationals in some interval `(z, r)` — derived from Reynolds' no-definable-gaps lemma. That
derivation is **not available, and the obstruction is in the source, not in the tactics**:

- Reynolds (1992, §5, printed p.176) defines `γ⁺(A)` to hold "exactly when `A` remains true for
  a while after now but only up until a gap after which `A` is arbitrarily soon false", and a
  *definable gap* is one where some `γ⁺(A)` holds. The hypothesis already requires `A` to be
  constantly true on an interval abutting the gap.
- `Axiom.prior_U_gap` (`ProofSystem/Axioms.lean`) encodes the same requirement: its antecedent
  is `U(⊤, φ) ∧ F(¬φ)`, and `U(⊤, φ)` asserts `φ` throughout an initial future segment.
- Negation-completeness of `limitSetBelow m r` asserts eventual constancy for **every** formula.
  A formula whose membership pattern is dense and co-dense in every left neighbourhood of `r`
  refutes it while making every Prior-U instance vacuous. So "no definable gaps" is strictly
  weaker than the property the phase asked to derive from it.
- Independently, Prior-U/Prior-S are `untl`/`snce` statements. Converting a Prior instance in
  `m q` into a fact at other rationals requires Until/Since coherence for the family, which is
  not a hypothesis at this level and which the back-and-forth chronicle supplies only in its
  *Restricted* form.

The plan's mitigation (b) — consistency plus extension — was therefore elected, per the decision
order fixed at plan time. It was **not** silently switched: the election, the refutation, and
the route taken are all recorded in `LimitMCS.lean`'s module docstring, as the phase task
required.

## What landed

All in `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (+259 lines, 15 new declarations,
sorry-free). Phase 3's ten declarations are untouched.

**Mitigation (b), literal form** — the bare `set_lindenbaum` extension, recorded for comparison:
`limitMCSLindenbaum`, `limitSetBelow_subset_limitMCSLindenbaum`, `limitMCSLindenbaum_is_mcs`.

**Mitigation (b), coherence-preserving refinement** — the extension downstream phases should
use. `limitFilterBelow` is the left-neighbourhood filter of `r` on the rationals (a set is large
when it contains every rational in some `(z, r)`); it is proper by `exists_rat_btwn`, and
`limitUltrafilterBelow` is a fixed ultrafilter refining it. `limitMCSBelow m r` is the
ultrafilter limit of the family. Supporting results: `mem_limitFilterBelow`,
`limitFilterBelow_neBot`, `limitFilterBelow_le`, `mem_limitMCSBelow`,
`limitSetBelow_subset_limitMCSBelow`, `limitMCSBelow_finite_subset_mem`, `limitMCSBelow_is_mcs`.

**The descent handle** — `limitMCSBelow_cofinal_below`: every member of `limitMCSBelow m r` lies
in `m q` for rationals `q` arbitrarily close below `r`. This is what an arbitrary Lindenbaum
extension destroys and the ultrafilter limit retains, and it is the reason the refinement was
worth landing. The v2 plan's sharpening of mitigation (b) predicted that electing (b) would
force Phase 5's six lemmas and Phase 6's `forward_G`/`backward_H` to be restated; with this
lemma available that cost is largely avoided (see "Cost report" below).

**The plan's named corollary** — `fc_theorem_true_in_parametric_model`: every `fc`-theorem in
the root's subformula closure is true at every point of the parametric canonical model.

## Plan deviations

1. `limitMCS_no_oscillation` and `limitSetBelow_negation_complete` — **skipped**. The statements
   are false as written (see above).
2. `limitSetBelow_is_mcs` — **altered** to `limitMCSBelow_is_mcs` plus
   `limitSetBelow_subset_limitMCSBelow`: maximality by extension, which is the plan's own
   mitigation (b).
3. Mitigation (b) — **altered**: landed in two forms, the plan's literal `set_lindenbaum` form
   and the ultrafilter refinement. The refinement is an addition beyond the phase task list.
4. `fc_theorem_true_in_parametric_model` — **altered**: composed with
   `fully_restricted_parametric_shifted_truth_lemma`
   (`Algebraic/RestrictedParametricTruthLemma.lean`) rather than
   `parametric_shifted_truth_lemma` (`Algebraic/ParametricTruthLemma.lean`). The latter is
   stated at `BFMCS D`, so its frame-class argument takes its default `FrameClass.Base`; it is
   **not** `fc`-generic and cannot be used at `FrameClass.Dedekind`. It also demands
   unrestricted Until/Since coherence. The corollary consequently carries an extra hypothesis
   `h_sub : φ ∈ subformulaClosure root`.

## Preserved-Assets correction

The v2 plan's Preserved Assets table describes `ParametricCanonical` / `ParametricHistory` /
`ParametricTruthLemma` as "generic in `D` and `fc`". That is inaccurate for
`parametric_shifted_truth_lemma`, which is Base-only (see deviation 4). Neither file was edited;
the correction is recorded so no later phase relies on the wrong binder set.

## Cost report for downstream phases

- Phase 5's six lemma **statements** are unchanged and remain correct, since
  `limitSetBelow m r ⊆ limitMCSBelow m r`. Only the unselected-**source** cases change shape:
  they route through `limitMCSBelow_cofinal_below` instead of unfolding a `limitSetBelow`
  witness directly.
- Phase 6's `realLimitMCS` must take `limitMCSBelow m (x + δ)` — not `limitSetBelow m (x + δ)` —
  at unselected points, so `FMCS.is_mcs` is discharged by `limitMCSBelow_is_mcs`. Rational
  selection at selected points is unaffected.
- Neither phase should use `limitMCSLindenbaum`.
- The `limitSetAbove` dual was confirmed not to be required and no above-side maximality was
  proved.

## Final verification

| Check | Result |
|---|---|
| `lake build` (full project) | green, 1895 jobs |
| Live sorries outside `Boneyard/` | 1 — `WeakCanonical/Transfer.lean:1242`, unchanged |
| Sorries introduced by this phase | 0 |
| Vacuous definitions introduced | 0 |
| New axioms | 0 |
| `#print axioms limitMCSBelow_is_mcs` | `propext, Classical.choice, Quot.sound` |
| `#print axioms limitMCSBelow_cofinal_below` | `propext, Classical.choice, Quot.sound` |
| `#print axioms fc_theorem_true_in_parametric_model` | `propext, Classical.choice, Quot.sound` |

The strategic-sorry contingency in the plan's Risks section was **not** exercised.
