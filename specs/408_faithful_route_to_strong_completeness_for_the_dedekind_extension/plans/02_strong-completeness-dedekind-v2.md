# Implementation Plan: Weak + Finite-Context Consequence Completeness for FrameClass.Dedekind (v2)

> **REFRAMING NOTE (carried forward from v1, applies to the whole plan)**: "Strong completeness"
> is reserved, project-wide, for the genuine infinite-premise statement (`Γ : Set Formula` with
> finitary set-derivability), which is **provably unavailable** for the Dedekind class — its
> consequence relation is not compact (Reynolds 1992 Theorem 7 is *weak* completeness, and the
> restriction is genuine). The headline result for this class is **weak completeness**
> `completeness_dedekind`; the arbitrary-finite-`Γ` form, inter-derivable with it through the
> deduction theorem, is `consequence_completeness_dedekind`. No proof obligation, phase
> boundary, or route decision changes under this renaming. See
> `FormalSystem/Metalogic/StrongCompleteness.lean`'s module docstring for the per-class
> programme. **This rename landed concurrently with the v1 → v2 revision**; v2 uses the new
> names throughout, and the Phase 2 signature pinned by commit `bd9ae0ac1` is renamed but not
> restructured.

- **Task**: 408 - faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Status**: [IMPLEMENTING]
- **Effort**: 37 hours
- **Dependencies**: None (coordinates with, but is not blocked by, the strong-completeness
  architecture and finite-context strong-completeness efforts — neither has artifacts on disk)
- **Research Inputs**:
  - reports/01_faithful-route-strong-completeness.md (primary, adversarially verified)
  - reports/02_literature-coverage-audit.md (secondary, literature infrastructure)
  - plans/01_strong-completeness-dedekind.md (superseded predecessor; its Phase 3 dispatch
    supplied the counterexample that triggered this revision)
- **Artifacts**: plans/02_strong-completeness-dedekind-v2.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/rules/plan-compliance.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4

---

## Revision Rationale (v1 → v2)

v1's Phase 3 task 4, `limitSetBelow_of_rat` — "at a rational `q` the limit set agrees with
`m q` on membership" — is **false in both directions**, and the Phase 3 implementation dispatch
produced the counterexample:

> Let `P` be an atom and let `m` be the theory-family of a genuine dense model in which `P`
> holds at every rational `p < 0` and fails at `0`. Every `FMCS` field is satisfied — they are
> semantic consequences — yet `P ∈ limitSetBelow m 0` while `P ∉ m 0`. The mirror construction
> (`P` at `0` only) refutes the other inclusion.

The root cause is structural, not tactical: `FMCS.forward_G` and `FMCS.backward_H`
(`Bundle/FMCSDef.lean:110,118`) are stated with **strict** inequalities, matching TM's strict
temporal operators, so nothing relates membership *at* `q` to membership *strictly below* `q`.
There is no `H φ → φ`, because `allPast` is the strict past operator.

v1's whole Phase 6 rested on that false lemma: it defined `FMCS.toReal` with
`mcs := limitSetBelow f.mcs`, a one-sided limit **at every real point including the rationals**,
and needed rational agreement to make the extension *extend* rather than *replace* the rational
family. What changes in v2:

1. **Phase 3** is rewritten to the four things that actually landed sorry-free (10 declarations,
   `Bundle/LimitMCS.lean`) and marked `[COMPLETED]`. The false task is deleted; the purpose it
   was serving is now discharged structurally in Phase 6, not by a lemma.
2. **Phase 6** adopts *rational selection*: the extension picks `m q` directly at any real that
   is a (shifted) rational, and takes the left limit only elsewhere. Agreement at selected points
   is then definitional. The rational/irrational case split this forces is enumerated explicitly,
   and Phase 6 is split into **Phase 6** (the `FMCS`-level extension) and **Phase 6.1** (the
   `BFMCS`-level bundle plus restricted temporal coherence) to stay inside H8's one-run bound.
3. A **second defect**, found while verifying the unblock path rather than inherited from the
   Phase 3 dispatch: the bundle's `modal_backward` field is **not provable** at an unselected
   real point if the real bundle's family set is `FMCS.toReal '' B.families` as v1 specified.
   Per-family "eventually" thresholds admit no common rational, so the Rat-side `modal_backward`
   can never be applied. v2 therefore closes the real family set under **real** shifts
   (`fam.toRealShift δ`, `δ : ℝ`), which lets the `modal_backward` witness family be positioned
   at the target point exactly as the Rat construction positions it at a rational
   (`ChronicleToCountermodelBasic.lean:576`). This is a Phase 6.1 obligation.
4. **Phase 5's lemma statements were also wrong** — not merely under-specified. The Phase 3
   dispatch asserted Phases 4 and 5 were unaffected and dispatchable; that claim is **verified
   for Phase 4 and refuted for Phase 5**. v1's `limitSet_forward_G` /`limitSet_backward_H`
   express only the limit-to-limit case of a four-case matrix. Phase 5 is restated as six named
   lemmas (each of which was hand-verified during this revision) plus two cases that are
   discharged by the rational family's own fields.
5. Phases 4, 7, 8 ripple is stated explicitly per phase below.
6. **Concurrent terminology reframing absorbed.** While this revision was being written, a
   separate effort reserved the name "strong completeness" for the infinite-premise statement
   and renamed the Phase 2 terminus to `consequence_completeness_dedekind` /
   `consequence_completeness_dedekind_of_engine` (working tree, `StrongCompleteness.lean`). v2
   uses the tree's current names throughout so no phase points at a declaration that does not
   exist. The rename changes no binder, no conclusion, and no phase boundary.

Everything binding in v1 is carried through unchanged: the `consequence_completeness_dedekind_of_engine`
signature pinned by Phase 2 (commit `bd9ae0ac1`), the Postmortem Constraints, the Preserved
Assets accounting, risk-first phase ordering, and the single-permitted-strategic-sorry rule at
`limitMCS_negation_complete`.

---

## Overview

The terminus pair is `consequence_completeness_dedekind : SemanticConsequenceDedekindDense Γ φ →
Derivable FrameClass.Dedekind Γ φ` (finite-context consequence completeness) with
`completeness_dedekind` — the class headline, weak completeness — derived as its `Γ = []`
instance. The two are inter-derivable through the deduction theorem, so they are one theorem in
two shapes; neither is "strong completeness" (see the Reframing Note above). The route is
Route B of the research report: build the countermodel directly on `ℝ`
from a Dedekind-MCS, inside the tree's own parametric canonical architecture, never leaving it.
Reynolds' transfer route (report 390's route) is rejected and no part of it is built.

The single genuinely new mathematical ingredient is a limit-MCS assignment extending a
`BFMCS (fc := fc) Rat` to a `BFMCS (fc := fc) ℝ` along `ℚ ↪ ℝ`. Everything else is either
verbatim reuse of existing frame-class-generic and `D`-generic machinery, or mechanical
transcription. Phases are sequenced risk-first: the `D := ℝ` compile probe is Phase 1, the
terminus statement lands in Phase 2 (fixing the exact engine interface before any engine work
begins), and the crux — negation-completeness of the limit MCS — is reached at Phase 4, before any of the
expensive downstream transport work is paid for.

**Definition of done**: `FormalSystem/Metalogic/StrongCompleteness.lean` contains a sorry-free
`consequence_completeness_dedekind` with `completeness_dedekind` as a corollary; `lake build` is
green; `#print axioms consequence_completeness_dedekind` shows exactly `[propext, Classical.choice,
Quot.sound]`.

### Research Integration

| Report | Integrated | What it fixes in this plan |
|---|---|---|
| reports/01_faithful-route-strong-completeness.md | v1, 2026-07-27 | Route selection (B over A), phase sequencing, preserved-assets list, bridge prohibitions |
| reports/02_literature-coverage-audit.md | v1, 2026-07-27 | Goldblatt provenance caveat, sub-index gaps, citation discipline (PDF page, never `md:NN`) |
| plans/01_strong-completeness-dedekind.md — Phase 3 dispatch BLOCKER block | v2, 2026-07-27 | The rational-agreement counterexample; the rational-selection unblock path; the corrected Phase 3 task list |

No new research report was produced for this revision. The revision trigger is a
counterexample established during implementation, not a new literature finding.

### Preserved Assets

The following work is complete, verified generic, and must not regress. No phase rewrites,
generalizes, or "cleans up" any row in this table.

| Component | File / Anchor | Status | Verified |
|---|---|---|---|
| `deductionTheorem`, `deductionConverse`, `Derivable.deduction` | `Metalogic/Core/DeductionTheorem.lean:325,447,467` | [COMPLETED] `{fc : FrameClass}` implicit, unconstrained | 2026-07-27 |
| `neg_consistent_of_not_derivable` | `Metalogic/BXCanonical/Completeness.lean:72` | [COMPLETED] generic in `fc` | 2026-07-27 |
| `set_lindenbaum`, `SetMaximalConsistent.*`, `theorem_in_mcs` | `Metalogic/Core/MaximalConsistent.lean` (`theorem_in_mcs` at `:491`) | [COMPLETED] generic in `fc` | 2026-07-27 |
| `countermodel_dense_enriched` | `Metalogic/BXCanonical/Completeness.lean:133` | [COMPLETED] `{fc : FrameClass}`; threads `fc` at `:141`,`:157-159`. **Template, not a target** | 2026-07-27 |
| `Chronicle.cantorBfmcsDense` (`:552`), `rootedCantorFmcsDense` (`:500`), `rooted_cantor_fmcs_dense_at_s` (`:511`), `box_stable_in_rooted_cantor_fmcs_dense` (`:528`), `cantor_bfmcs_dense_restricted_tc/_buc/_fuc` (`:629`,`:680`,`:755`) | `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` | [COMPLETED] `(fc : FrameClass)` explicit, carrier `Rat`, all three coherence lemmas fully polymorphic in `root`. `_tc` alone carries an extra closure-containment hypothesis. **Stays at `Rat`** | 2026-07-27 |
| `fully_restricted_parametric_completeness_from_neg_membership` | `Metalogic/Algebraic/RestrictedParametricTruthLemma.lean:417`, vars at `:45` | [COMPLETED] binders `{fc} {D} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` — no `DenselyOrdered`, no `Rat`. **Accepts `D := ℝ` unchanged** | 2026-07-27 |
| `ParametricCanonicalTaskFrame` / `ParametricCanonicalTaskModel` / `parametricToHistory` / `ShiftClosedParametricCanonicalOmega` | `Metalogic/Algebraic/ParametricCanonical.lean`, `ParametricHistory.lean`, `ParametricTruthLemma.lean:240,379` | [COMPLETED] generic in `D` and `fc` | 2026-07-27 |
| `BFMCS` / `FMCS` structures | `Metalogic/Bundle/BFMCS.lean:91`, `Bundle/FMCSDef.lean:103` | [COMPLETED] carrier binder is only `[Preorder D]` | 2026-07-27 |
| The six coherence predicates | `Metalogic/Bundle/TemporalCoherence.lean:277,308,489,526,541,558,589` | [COMPLETED] generic in `D` | 2026-07-27 |
| `temporalFutureDerived` (`□φ → G(□φ)`) | `Theorems/Combinators.lean:654` | [COMPLETED] `{fc : FrameClass}` implicit, derived from `modal_future` + `modal_t` + `modal_4`. **Newly load-bearing in v2 (Phase 6.1)** | 2026-07-27 |
| `soundness_dedekind` | `Metalogic/Soundness.lean:1910` | [COMPLETED] already strong-form: takes `(Γ : Context)` and `h_ctx : ∀ ψ ∈ Γ, TruthAt …` | 2026-07-27 |
| `ValidDedekindDense` | `Semantics/Validity.lean:255` | [COMPLETED] carries the lub property as an explicit `Prop` hypothesis at `:258` | 2026-07-27 |
| `Axiom.prior_U_gap` / `prior_S_gap` / `sep` and their validity | `ProofSystem/Axioms.lean:377,387,398`; `Metalogic/Soundness.lean` | [COMPLETED] | 2026-07-27 |
| `kplusFormula` | `Metalogic/WeakCanonical/Kamp/PriorINF.lean:93` | [COMPLETED] purely syntactic `Formula`-level "holds arbitrarily soon after". **The only reusable item from the Kamp INF files** | 2026-07-27 |
| `dedekind_box_dense_mem`, `real_lub_of_bddAbove`, the `CarrierProbe` examples | `Metalogic/BXCanonical/CompletenessDedekind.lean` | [COMPLETED] landed by Phase 1 of this plan | 2026-07-27 |
| `SemanticConsequenceDedekindDense`, `truthAt_foldr_imp`, `semantic_deduction_dedekind_dense`, `derivable_foldr_imp_iff`, `consequence_completeness_dedekind_of_engine`, `soundness_dedekind_consequence`, `completeness_dedekind_of_engine` | `Metalogic/StrongCompleteness.lean` | [COMPLETED] landed by Phase 2 of this plan, commit `bd9ae0ac1`; renamed (not restructured) by the concurrent terminology reframing. **The `consequence_completeness_dedekind_of_engine` signature is pinned and may not be restated** | 2026-07-27 |
| `limitSetBelow`, `limitSetAbove`, `limitSetBelow/Above_mono_directed`, `limitSetBelow/Above_finite_subset_mem`, `limitSetBelow/Above_consistent`, `limitSetBelow/Above_of_rat` | `Metalogic/Bundle/LimitMCS.lean` (10 declarations) | [COMPLETED] landed by Phase 3 of this plan, sorry-free | 2026-07-27 |

**Explicitly NOT touched by any phase of this plan** (regressing or "generalizing" any of these
is a defect, not progress):

- `Metalogic/WeakCanonical/IntegerModel/**` — the ℤ engine (`good`, `VeryGood`, `ContempEquiv`,
  `subinterval_finite_of_succ_archimedean`, `countermodel_discrete_reynolds_v2`).
- `Metalogic/WeakCanonical/Transfer.lean:1242` — the live discrete-branch sorry. It is on the
  Base/Discrete axis and is not on this route. Do not attempt it.
- `Metalogic/WeakCanonical/EFGames/**`, `Kamp/**`, `MonadicFO.lean` — the monadic-FO / EF-game
  stack. Route B needs none of it.
- `FormalSystem/Boneyard/**`.
- `completeness_dense`, `completeness_discrete` and their proofs. They are read as templates and
  left byte-identical.

### Source-to-Implementation Mapping (H3, Tier 1 — literature-backed)

Cite by **PDF page** in all Lean docstrings. Never cite chunk-relative `md:NN` line numbers.

| Source | Location | Lean identifier | Statement used | Phase |
|---|---|---|---|---|
| Reynolds 1992 | §5, printed p.176 (chunk `reynolds_1992_sec06`, pp.174-179) | `limitMCS_negation_complete` | "Call a linear temporal structure a *Prior structure* if it satisfies all substitution instances of Prior-U and Prior-S. It is easy to see that then there are no definable gaps." | 4 |
| Reynolds 1992 | §5, printed p.176 (same chunk) | `limitMCS_no_oscillation` | "By Prior-U applied to `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction." — the one-line proof of no-definable-gaps | 4 |
| Reynolds 1992 | §5, printed p.176 (same chunk) | `kplusFormula` (reused) | `γ⁺(A)` "holds exactly when `A` remains true for a while after now but only up until a gap after which `A` is arbitrarily soon false" — the oscillation pattern Phase 4 must exclude | 4 |
| Reynolds 1992 | §1, printed p.169 (chunk `reynolds_1992_sec01`, pp.165-172) | docstring of `CompletenessDedekind.lean` | "The Prior axioms enforce a *definably* Dedekind complete model … there may be gaps in the order but … you wouldn't know that just looking at the behaviour of temporal formulas." Scopes what Phase 4 may claim: definable gap-freeness only | 4 |
| Reynolds 1992 | Prior-U / Prior-S / Sep, printed p.168 | `Axiom.prior_U_gap`, `prior_S_gap`, `sep` | PRESENT in the tree at `Axioms.lean:377,387,398` | 4 (consumed) |
| Goldblatt 2023 (arXiv:2310.20069) | Introduction (chunk `goldblatt_2023_strong-completeness-real-time`, `chunk_0002.md`) | docstring of `StrongCompleteness.lean` | "if the flow of time is modelled by the linearly ordered set (R, <) … the resulting temporal logic of valid **propositional** formulas is recursively axiomatisable. This was shown by Robert Bull, using finitely many axioms and inference rules. The situation of first-order temporal logic is quite different." **Resolves the audit's highest-ranked gap in favour of this plan**: Scott's non-axiomatizability obstruction is first-order-specific and does not bear on propositional TM. `[UNVERIFIED — provenance_fidelity: unverified_conversion]`; re-read against the PDF before quoting in a deliverable | 2 |
| Reynolds 1992 | Thm 7, §9, printed p.189 (chunk `reynolds_1992_sec07`) | — | "US/R is sound and **weakly** complete … over structures with real flow." Recorded only to state why it is NOT the terminus | 2 (docstring) |
| Burgess 1984 | §2, pp.108-115 (chunk `burgess_1984_sec05`) | — | Completeness for Dedekind-complete time via a completion construction. **Cross-check only.** Consult if Phase 4 stalls; do not restructure the route around it without a new research dispatch | 4 (contingency) |

---

## Postmortem Constraints

Binding on every implementation dispatch for this task. Derived from the adversarial
verification section of report 01, the literature audit, a direct inventory performed during
planning, and (new in v2) the Phase 3 dispatch's counterexample.

**Do NOT**:

- **Do NOT build any part of the Reynolds transfer route.** No monadic-FO translation layer, no
  Stavi connectives `U'`/`S'`, no expressive-completeness theorem, no EF games, no shuffles, no
  `≡_k`, no order-characterization of `ℝ`. Reynolds' Theorems 4 and 5 invoke expressive
  completeness of `{U,S}` at seven verbatim sites, which reduces to Kamp/Stavi — a result
  Reynolds cites without proof and which is absent from this tree and from Mathlib.
- **Do NOT route the limit-MCS work through `Kamp/PriorINF.lean` or `Kamp/DedekindINF.lean`.**
  Report 01's Limitation 4 flagged these as a *lead*; the lead was checked during planning and
  is **refuted**. Every declaration there is parameterized by `{sig : MonadicSignature}` and
  `(M : OrderedMonadicStructure sig)`: truth at a point is `M.interp (atomMap P) t`, not
  membership in a `Set Formula`. `HasDedekindINF` is a TL-*definability* hypothesis about a
  point that already exists in the carrier — it constructs nothing, and discharging it would
  itself require the limit construction. Neither file mentions `Rat`, `Real`, `sSup`/`sInf`,
  `ConditionallyCompleteLinearOrder`, or `SetMaximalConsistent`. The **one** reusable item is
  `kplusFormula` (`PriorINF.lean:93`), a purely syntactic `Formula`. Note also that no
  `kplus ↔ TemporalTruth (kplusFormula P)` correspondence lemma is proved anywhere — the
  MCS-side analogue must be proved from scratch.
- **Do NOT build the phase-5 gap-freeness bridge** (`IsEmpty (Gap D)` ⟺ conditionally
  complete). `ValidDedekindDense` already carries the lub property as an explicit `Prop`
  hypothesis (`Validity.lean:258`), so there is nothing to bridge *to*. `structure Gap`
  (`EFGames/Defs.lean:248`) belongs to the rejected ℤ/EF route. Route B's notion is *definable*
  gap-freeness, a consequence of Prior-U, not an order-theoretic side condition.
- **Do NOT attempt to lift the Cantor back-and-forth chronicle layer to `ℝ`.** Cantor's theorem
  requires a *countable* dense order without endpoints. `cantorBfmcsDense` stays at `Rat`.
  Only the `D`-generic layer beneath it moves. Any edit to `cantorIsoDense`, `cantorZeroDense`,
  or `CantorFDense` is out of scope and is the wrong seam.
- **Do NOT build a Base-MCS → Dedekind-MCS transfer lemma.** Route B produces a Dedekind-MCS at
  step 1 via `set_lindenbaum (fc := FrameClass.Dedekind)` and feeds it to an `fc`-generic
  construction. No transfer occurs, so no transfer lemma is needed. The trap documented at
  `Completeness.lean:182-193` does not arise on this route.
- **Do NOT use `countermodel_discrete_reynolds_v2` as a template.** It hard-codes
  `fc := FrameClass.Discrete` and emits `SuccOrder`/`PredOrder`/`IsSuccArchimedean` in its
  existential (`IntegerModel/ReynoldsBridge.lean:739`). The correct template is
  `countermodel_dense_enriched`, which is `fc`-generic.
- **Do NOT build a `Γ`-relative analogue of `neg_consistent_of_not_derivable`, and do NOT build
  a "root covering `Γ ∪ {φ}`".** A planning-time inventory confirmed that
  `neg_consistent_of_not_derivable` (`Completeness.lean:72`) is hard-coded to the singleton
  `{Formula.neg φ}` and that its proof case-splits on `L = []` vs `L = [¬φ]`, so it does not
  generalize mechanically; and that a direct `Γ`-countermodel would additionally need a `root`
  whose `subformulaClosure` covers all of `Γ ∪ {φ}` plus a per-formula `h_sub`. **Both are
  artifacts of a route this plan does not take.** Route B reaches `Γ` through the deduction
  theorem — `Γ ⊨ φ ↔ ⊨ (Γ.foldr imp φ)`, then the *single-formula* engine, then iterated
  `deductionConverse` — so the engine only ever sees one formula and `root := ψ` with
  `self_mem_subformulaClosure ψ` suffices exactly as in `countermodel_dense_enriched`. If an
  implementer finds themselves generalizing Lindenbaum or widening `root`, they have left the
  plan; stop and escalate.
- **Do NOT prove `completeness_dedekind` independently and then strengthen it.**
  `completeness_dedekind` is `consequence_completeness_dedekind []` after `simp` discharges
  `∀ ψ ∈ [], _`. Proving it separately duplicates the engine and re-introduces the weak
  terminus this task exists to eliminate.
- **Do NOT weaken the target to `ValidDedekind`.** `FrameClass.Dedekind` sits above
  `FrameClass.Dense`, so `density` and `dense_indicator` are admissible in a `.Dedekind`
  derivation and both are false on `ℤ`, which is Dedekind-complete. The target is
  `ValidDedekindDense` and the completeness converse must match it.
- **Do NOT emit a vacuous definition** (`def X := True`, `theorem X := trivial`, etc.) at any
  point. See `.claude/rules/lean4.md`. If a phase cannot be completed, mark it `[BLOCKED]`.
- **Do NOT cite task numbers in any `.lean` file.** Cite the sibling module name, the source's
  printed PDF page, or the declaration name instead.
- **(v2) Do NOT reintroduce any claim that the one-sided limit agrees with `m q` at a rational
  `q`.** It is false in both directions; the counterexample is recorded in
  `Bundle/LimitMCS.lean`'s module docstring and in the Revision Rationale above. Agreement at
  rational points is obtained *by construction* in Phase 6 (rational selection), never by a
  lemma about `limitSetBelow`.
- **(v2) Do NOT define the real bundle's family set as the image of the rational bundle's
  families under a single extension.** `modal_backward` is then unprovable at unselected reals.
  The family set must be closed under **real** shifts. See Phase 6.1 and the corresponding Risk.

**MUST preserve**:

- Every row of the Preserved Assets table above, byte-identical unless a phase's Tasks list
  names the file.
- `Metalogic/Soundness.lean` at zero sorries.
- `completeness_dense` and `completeness_discrete` sorryAx-free with axioms exactly
  `[propext, Classical.choice, Quot.sound]`.
- The single live sorry count outside `Boneyard/` must not increase. `Transfer.lean:1242`
  remains the only one at the end of this task unless a strategic sorry is explicitly elected
  under the contingency in Risks below.
- **(v2)** The exact signature of `consequence_completeness_dedekind_of_engine` as landed by
  Phase 2 (commit `bd9ae0ac1`, subsequently **renamed but not restructured** by the concurrent
  terminology reframing: same binders, same conclusion). Phase 8 instantiates it; no phase
  restates, reorders, or re-binds it.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

- **Route B, not Reynolds' transfer.** Rejected on two independent grounds: the
  expressive-completeness dependency of D1/D2, and the absence from Mathlib of the
  order-theoretic characterization of `ℝ` (only *field*-theoretic uniqueness exists:
  `LinearOrderedField.uniqueOrderRingIso`, `inducedOrderRingIso`).
- **The terminus is the finite-context consequence form, and weak completeness is its `Γ = []`
  corollary.** `Context` is `List Formula` (`Syntax/Context.lean:60`), i.e. finite, so the two
  are inter-derivable through the deduction theorem — which is exactly why neither may be called
  "strong completeness". `soundness_dedekind` is already stated in arbitrary-`Γ` form, so the
  consequence terminus is its exact converse.
- **Genuine strong completeness is NOT the target and is provably unavailable here.** Changing
  `Context` to `Set Formula` would require compactness of the Dedekind-class consequence
  relation, and that relation is not compact. Out of scope; do not attempt, and do not rename
  any declaration in this plan back to a "strong" form.
- **Goldblatt's obstruction does not apply.** Goldblatt (arXiv:2310.20069, Introduction) states
  that propositional temporal logic over `(ℝ, <)` *is* recursively — indeed finitely —
  axiomatizable (Bull), and that Scott's non-axiomatizability result is about *first-order*
  temporal logic. The "admissible models" restriction in that paper is a first-order device.
  This does not license reopening the target.
- **The Dedekind case is a special case of the per-class completeness architecture**, not a
  parallel construction. `StrongCompleteness.lean` is laid out as a four-class family so the
  Base/Dense/Discrete instances drop in later without restructuring.
- **The chronicle layer stays at `Rat`; only the layer beneath moves to `ℝ`.** This is the seam,
  and it is fixed.
- **(v2, settled by counterexample) The real extension selects `m q` directly at selected
  points and takes the left limit only elsewhere.** Selected points are the reals of the form
  `(q : ℝ) - δ` for `q : Rat` and the family's real offset `δ`. This is the *only* shape under
  which the extension extends rather than replaces the rational family, because rational
  agreement is unavailable as a lemma.
- **(v2, settled by proof obligation) The real bundle's family set is the real-shift closure**
  `{fam.toRealShift δ | fam ∈ B.families, δ : ℝ}`, not an image. Justification in Phase 6.1.
- **(v2) Only the *below* limit is load-bearing.** `limitSetAbove` and its Phase 3 duals are
  standing sorry-free assets; the extension uses `limitSetBelow` alone, and both `forward_G`
  and `backward_H` go through it (verified case-by-case in Phase 5). No phase is obliged to
  prove maximality of `limitSetAbove`.

---

## Goals & Non-Goals

- **Goals**:
  - `consequence_completeness_dedekind (Γ : Context) (φ : Formula) : SemanticConsequenceDedekindDense Γ φ → Derivable FrameClass.Dedekind Γ φ`, sorry-free.
  - `completeness_dedekind (φ : Formula) : ValidDedekindDense φ → Derivable FrameClass.Dedekind [] φ` as the `Γ = []` corollary.
  - A reusable `BFMCS (fc := fc) Rat → BFMCS (fc := fc) ℝ` limit extension with its coherence proofs.
  - `FormalSystem/Metalogic.lean` tracking table updated.
- **Non-Goals**:
  - Infinite-premise (`Set Formula`) strong completeness or compactness for this class — the
    Dedekind consequence relation is not compact, so it is unavailable, not merely deferred.
  - `consequence_completeness_base` / `_dense` / `_discrete`, and the genuine strong-completeness
    layer for Base/Dense (owned by the per-class completeness effort; this plan only shapes the
    file so they drop in).
  - Closing `Transfer.lean:1242`.
  - Any Reynolds-transfer artifact (see Postmortem Constraints).
  - Expanding `specs/literature-index.json` (a separate curation concern; the audit's
    recommendations are recorded, not executed here).
  - **(v2)** Maximality of `limitSetAbove`. Not on the route.

---

## Risks & Mitigations

- **Risk (HIGHEST): the limit MCS is not negation-complete for *all* formulas.** The chronicle
  bundle satisfies only the *Restricted* coherence predicates — scoped to
  `deferralClosure root` / `subformulaClosure root`. If the no-definable-gaps argument is only
  available for root-subformulas, the "eventually true approaching `r` from below" set is
  consistent but may not be maximal, and `FMCS.is_mcs` cannot be discharged directly.
  **Mitigation (decided at plan time, in this order)**: (a) attempt unrestricted
  negation-completeness first, since Prior-U instances are in *every* Dedekind-MCS by
  `theorem_in_mcs` and the argument is syntactic; (b) if that fails, fall back to
  *consistency + `set_lindenbaum`*: the limit set is consistent (each finite subset is
  eventually contained in a single `mcs y`, hence consistent), so Lindenbaum yields a genuine
  MCS, and the no-definable-gaps content is then needed only to show the *chosen* extension
  preserves `forward_G`/`backward_H` and restricted U/S coherence. Phase 4 must state which of
  (a) or (b) it took and why, in the module docstring. (c) If neither closes, mark Phase 4
  `[BLOCKED]` — see the contingency below.
  **(v2 sharpening of fallback (b))**: v1 called (b) "a strictly weaker obligation". That is
  optimistic and the implementer must not rely on it. Under (b) the family value at an
  unselected point is `Lindenbaum (limitSetBelow m r) ⊋ limitSetBelow m r`, so every Phase 5
  lemma whose *hypothesis* is a membership at an unselected point loses its handle: from
  `allFuture φ ∈ Lindenbaum(limitSetBelow m s)` one cannot descend to `allFuture φ ∈ m q` for
  rationals `q` near `s`. Choosing (b) therefore forces Phase 5's six lemmas and Phase 6's
  `forward_G`/`backward_H` to be restated for the chosen extension, not merely reused. Budget
  for that before electing (b).
- **Risk: the `D := ℝ` instantiation claim is second-hand.** Report 01 relied on report 390's
  compile probe rather than re-running it. Route B's entire feasibility rests on it.
  **Mitigation**: Phase 1 is exactly that probe, costs one build, and gates everything.
  **RETIRED** — Phase 1 ran the probe and it passed on the first attempt; the probes are
  landed as permanent `noncomputable example`s in `CompletenessDedekind.lean`'s `CarrierProbe`
  section, so a binder regression fails the build.
- **Risk (v2, NEW — HIGH): `modal_backward` at an unselected real point.** `BFMCS.modal_backward`
  (`BFMCS.lean:112`) demands: if `φ` is in *every* family's MCS at `t`, then `box φ` is in each
  family's MCS at `t`. At an unselected `t` the hypothesis gives, per family, only an
  *eventually* statement with a **family-dependent** threshold `z_fam < t`. An arbitrary bundle
  has no common rational below `t`, so the `Rat`-side `modal_backward` can never be applied and
  the field is unprovable for the image family set that v1 specified.
  **Mitigation (adopted, Phase 6.1)**: close the real family set under real shifts. Then the
  contrapositive runs exactly as at `Rat`: pick any rational `q`; `Rat` `modal_backward`
  contrapositive yields `fam'` with `φ ∉ fam'.mcs q`; the family `fam'.toRealShift ((q:ℝ) - t)`
  is in the real bundle and takes the value `fam'.mcs q` **at `t`** by rational selection,
  contradicting the hypothesis. This mirrors `ChronicleToCountermodelBasic.lean:576`, which
  positions its witness family by choosing the chronicle's rational shift.
- **Risk (v2, NEW — MEDIUM): time-stability of `box` membership is required and is not yet a
  named lemma.** Both `modal_forward` and `modal_backward` for the real bundle need
  `box φ ∈ f.mcs s ↔ box φ ∈ f.mcs t` for a `Rat` family `f`. The future direction is available
  from `temporalFutureDerived` (`Combinators.lean:654`, `fc`-generic: `□φ → G(□φ)`) plus
  `theorem_in_mcs` and `FMCS.forward_G`. The past direction has **no** `□φ → H(□φ)` theorem in
  the tree — `Axioms.lean:540` mentions "modal_past (derived)" in prose only, and
  `Automation/FormulaEnumerator.lean:1239` names it only as an enumerated shape.
  **Mitigation**: obtain the past direction *without* a past-modal axiom, by pushing the
  negation forward instead: from `¬□φ` derive `□¬□φ` (S5 negative introspection, from
  `Axiom.modal_5_collapse` / `Theorems/ModalS5.lean`), then `Axiom.modal_future` gives
  `□¬□φ → □(G ¬□φ)` and `Axiom.modal_t` gives `G ¬□φ`; `forward_G` then propagates `¬□φ`
  forward, and MCS negation-completeness converts this into the backward direction. **Do NOT
  add a `modal_past` axiom** — that would change the proof system. If negative introspection is
  not already a named theorem, land it as an `fc`-generic derived theorem in Phase 6.1's module.
- **Risk: `RestrictedForwardUntilSinceCoherent` at an unselected `t` is the hardest transport.**
  Producing `s > t` with the guard `ψ ∈ mcs r` for *all* `r ∈ (t,s)` — including unselected
  `r` — re-invokes the limit-MCS property rather than merely quoting the `Rat` witness.
  **Mitigation**: it is isolated in its own phase (7), after the limit MCS is fully
  characterized, so it cannot silently consume the crux phase's budget.
  **(v2 refinement)**: the difficulty is now located precisely. The *guard* side is easy in both
  cases — a `Rat` guard covering all rationals in `(t+δ, s+δ)` automatically covers unselected
  `r`, because `limitSetBelow m (r+δ)` is witnessed by the threshold `t+δ`. The *selected-`t`*
  case is fully mechanical. Only obtaining the real witness `s` from a membership at an
  **unselected** `t` is hard, because the `Rat` witnesses `s_p` for rationals `p ↗ t+δ` may
  shrink to `t+δ`. That is the single sub-obligation that may re-invoke Phase 4.
- **Risk: analysis paralysis on the crux.** **Mitigation**: Phases 2 and 3 landed real,
  sorry-free Lean before the crux is attempted, so the H2 formal-proof-line bar is already met
  when Phase 4 starts; and Phase 4's done-criterion is a single named lemma, not a survey.
- **Risk: literature over-reach on unverified chunks.** `goldblatt_2023_strong-completeness-real-time`
  is `unverified_conversion`; `venema_1993_since_sec01/02` have absent or null
  `provenance_fidelity`. **Mitigation**: neither may be load-bearing. The Goldblatt claim is
  used only to *close* a question in the plan's favour, never to license a proof step; any
  quotation in a Lean docstring must first be re-read against the PDF at
  `~/Projects/Literature/sources/goldblatt_2023_strong-completeness-real-time/`.
- **Risk: confusable literature ids.** `gabbay_1994_ch10` (integers chapter, `no_source_pdf`)
  ranks high in raw FTS for "Dedekind complete" alongside the correct `verified_conversion`
  `gabbay_1994_ch10_sec02`/`sec05`. **Mitigation**: check `provenance_fidelity` before citing
  any `gabbay_1994*` chunk.

### Contingency: what a documented strategic-sorry skeleton would look like (Phase 4 only)

The research report is explicit that the limit-MCS construction "should not be papered over with
a `sorry`" and that `[BLOCKED]` is the correct outcome if it resists. **This plan therefore
declares no planned strategic sorries and `plan_metadata.skeleton` is `false`.** The following
is stated so that, if the orchestrator nonetheless elects a skeleton rather than a block, the
shape is fixed in advance and an implementer never has to invent it:

- **Permitted division point**: exactly one — `limitMCS_negation_complete` (or, under fallback
  (b), `limitMCS_lindenbaum_preserves_coherence`). No other sorry is permitted anywhere.
- **Required form**: the sorry is the body of that single named lemma, tightly scoped, and
  carries the comment `-- sorry: assumes no formula oscillates arbitrarily close to r from
  below (Reynolds 1992 §5, printed p.176, no-definable-gaps); deferred because the unrestricted
  form is not available from the chronicle bundle's restricted coherence; follow-up: the
  limit-MCS negation-completeness follow-up task`.
- **Required tracking**: `sorry_inventory` entry with `strategic: true`, non-null
  `follow_up_task`, `assumption` and `why_deferred` populated per `wrap-up.md`; the dispatch
  reports `status: "implemented"` with `skeleton: true`, and `lake build` must still be green.
- **Follow-up task boundary**: the follow-up owns *only* the unrestricted no-definable-gaps
  argument for the limit set — i.e. "for every formula `A` and every `r : ℝ`, exactly one of
  `A`, `A.neg` is eventually constant on `ℚ ∩ (z, r)` for some `z < r`, given Prior-U/Prior-S in
  every Dedekind-MCS." It does **not** own the FMCS/BFMCS assembly, the coherence transport, or
  the countermodel, all of which remain in this task's Phases 5-8 and proceed against the
  sorried lemma.
- **A sorry placed anywhere other than that one lemma is a plan-unanticipated deviation** and
  must be flagged as such in the implementation summary, not silently accepted.

---

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4, 5 | 3 |
| 4 | 6 | 4, 5 |
| 5 | 6.1 | 6 |
| 6 | 7 | 6.1 |
| 7 | 8 | 2, 7 |

Phases within the same wave can execute in parallel. Territory contracts (H7): each phase owns
the files listed under its **Owns** line and MUST NOT edit any file owned by a concurrent phase.
Phases 1 and 2 own disjoint new files. Phases 4 and 5 own disjoint new files and are the only
declared parallel pair in the engine — **verified in v2**: Phase 5's six lemmas are statements
about `limitSetBelow` membership and the `Rat` family's own `forward_G`/`backward_H` fields, and
none of them mentions or requires maximality, so Phase 5 does not depend on Phase 4's crux.

---

### Phase 1: D := ℝ instantiation probe and the Dedekind box-dense branch lemma [COMPLETED]

- **Goal:** De-risk the entire route with one build, and land the mechanical half of the
  Dedekind completeness branch structure.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` (new),
  `FormalSystem/Metalogic/BXCanonical.lean` (import line only).
- **Tasks:**
  - [x] Re-run report 390's probe as a scratch `example`: confirm
        `ParametricCanonicalTaskFrame (fc := fc) ℝ` and
        `ParametricCanonicalTaskModel (fc := fc) ℝ` elaborate with zero errors.
        *(deviation: altered — the probes were landed as permanent `noncomputable example`s in
        the module's `CarrierProbe` section rather than discarded scratch, so a future binder
        regression fails the build. `noncomputable` is required because `Real.linearOrder` is
        noncomputable; this is a codegen annotation, not an elaboration weakening.)*
  - [x] Extend the probe: confirm
        `fully_restricted_parametric_completeness_from_neg_membership` typechecks at `D := ℝ`
        against a hypothesised `(B : BFMCS (fc := fc) ℝ)`. Record the exact goal state if it
        does not. *(PASSED — elaborated on the first attempt with no binder failure.)*
  - [x] Confirm `ℝ` discharges every binder of `ValidDedekindDense` (`Validity.lean:255-262`):
        `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `DenselyOrdered`, `Nontrivial`,
        and the lub hypothesis via `Real.instConditionallyCompleteLinearOrder`. Land this as a
        named sorry-free lemma `real_lub_of_bddAbove`, not as a comment.
  - [x] Create `CompletenessDedekind.lean` and land `dedekind_box_dense_mem`: for any
        `A` with `SetMaximalConsistent (fc := FrameClass.Dedekind) A`,
        `Chronicle.nextTop.neg.box ∈ A`. Transcribe the non-dense branch of `completeness_dense`
        (`Completeness.lean:268-276`) with `.Dense` replaced by `.Dedekind`; admissibility holds
        because `Axiom.dense_indicator.minFrameClass = .Dense` and
        `FrameClass.Dense ≤ FrameClass.Dedekind`.
  - [x] Module docstring cites Reynolds 1992 §1, printed p.169 (definably-Dedekind-complete
        scoping) by PDF page.
  - [x] `lake build FormalSystem.Metalogic.BXCanonical.CompletenessDedekind`.
- **Estimated output:** ~120 lines.
- **Done when:** the module builds sorry-free; `dedekind_box_dense_mem` and
  `real_lub_of_bddAbove` are proved; the probe outcome (pass or exact failure) is recorded in the
  handoff. **If the probe fails, stop and mark this phase `[BLOCKED]` — do not proceed to any
  later phase.**
- **Timing:** 2 hours.
- **Depends on:** none
- **v2 ripple:** unaffected. Nothing in this phase mentions the limit set or the extension shape.

### Phase 2: SemanticConsequenceDedekindDense, the semantic deduction lemma, and the terminus statement [COMPLETED]

- **Goal:** Land `consequence_completeness_dedekind` — the task's terminus — **with the
  single-formula engine as an explicit hypothesis**, so the target is fixed and sorry-free
  before any engine work begins.
- **Owns:** `FormalSystem/Metalogic/StrongCompleteness.lean` (new),
  `FormalSystem/Metalogic.lean` (import line only).
- **Tasks:**
  - [x] Define `SemanticConsequenceDedekindDense (Γ : Context) (φ : Formula) : Prop` by taking
        the binder list of `ValidDedekindDense` (`Validity.lean:255-262`) verbatim and adding
        the hypothesis `(∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) →` before the conclusion. This is
        exactly the hypothesis-and-conclusion shape of `soundness_dedekind`
        (`Soundness.lean:1910`) packaged as a definition. Do not reuse `SemanticConsequence`
        (`Validity.lean:103`) — it quantifies over all `D` and cannot express Dedekind-class
        consequence.
  - [x] Prove `semantic_deduction_dedekind_dense (Γ : Context) (φ : Formula) :
        SemanticConsequenceDedekindDense Γ φ ↔ ValidDedekindDense (Γ.foldr Formula.imp φ)`.
        Induction on the list against `Truth.lean:132`
        (`TruthAt … (φ.imp ψ) = (TruthAt … φ → TruthAt … ψ)`). No frame-condition reasoning
        enters. *(deviation: altered — the list induction was factored out into a reusable
        pointwise lemma `truthAt_foldr_imp`, stated at the bare `TaskModel` binder set with no
        Dedekind hypotheses, so the Base/Dense/Discrete sections can reuse it verbatim; the
        named iff is then two transports of it. No frame-condition reasoning enters, as
        specified.)*
  - [x] Prove `consequence_completeness_dedekind_of_engine`: given
        `(engine : ∀ ψ, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ)`, conclude
        `SemanticConsequenceDedekindDense Γ φ → Derivable FrameClass.Dedekind Γ φ`, via the
        deduction lemma plus iterated `Derivable.deduction` / `deductionConverse`
        (`DeductionTheorem.lean:447,467`), both already generic in `fc`.
        *(deviation: altered — the iteration was factored into the `fc`-generic pair
        `derivable_of_derivable_foldr_imp` / `derivable_foldr_imp_of_derivable` and packaged as
        `derivable_foldr_imp_iff`, so the terminus is a two-line composition. Each
        `deductionConverse` step needs a membership-based `Derivable.weaken` to permute the
        accumulated heads back into order, since the converse pushes formulas onto the front in
        reverse.)*
  - [x] Two additions beyond the phase task list, both anti-drift guards, both sorry-free:
        `soundness_dedekind_consequence` (`Derivable .Dedekind Γ φ → SemanticConsequenceDedekindDense Γ φ`,
        proving the new relation is exactly the conclusion block of `soundness_dedekind`, hence
        that the terminus is non-vacuous) and `completeness_dedekind_of_engine` (weak
        completeness exhibited as the `Γ = []` instance, so the weak form has exactly one proof
        in the tree and it is a corollary — consistent with the Postmortem Constraint against
        proving `completeness_dedekind` independently). These require importing
        `FormalSystem.Metalogic.Soundness` into the new module; no import cycle, since
        `Soundness.lean` does not import `StrongCompleteness`.
  - [x] Structure the file with named sections so the Base / Dense / Discrete instances of the
        same shape drop in later without restructuring. Header comments only — **no `sorry`,
        no vacuous definitions, no placeholder declarations** for those three classes.
  - [x] Module docstring: record (i) that the terminus is the finite-context consequence form
        and weak completeness is its `Γ = []` instance — and, per the concurrent terminology
        reframing, that neither is "strong completeness", which is reserved for infinite premise
        sets and is unavailable for this class; (ii) that Reynolds' Theorem 7 (§9, printed
        p.189) is *weak* and that the restriction is genuine; (iii) the Goldblatt point — propositional
        temporal logic over `(ℝ,<)` is finitely axiomatizable (Bull), and Scott's
        non-axiomatizability result is first-order — marked `[UNVERIFIED - unverified_conversion]`
        and re-read against the PDF before the quotation is committed. *(deviation: altered —
        no quotation was committed. `literature-search.sh` returned `degraded: true` with zero
        results for the Bull/Scott query and an empty TOC for `goldblatt_2023`, so the source
        could not be re-read. The docstring states the point as paraphrase, records that the
        corpus search found nothing to corroborate it, and notes explicitly that no declaration
        in the file depends on it.)*
  - [x] `lake build FormalSystem.Metalogic.StrongCompleteness`.
- **Estimated output:** ~200 lines.
- **Done when:** all three declarations are sorry-free and the module builds. The terminus
  statement exists in the tree from this point on.
- **Timing:** 3 hours.
- **Depends on:** none
- **v2 ripple:** unaffected. `consequence_completeness_dedekind_of_engine` takes the engine as an
  opaque hypothesis and knows nothing about the carrier, the limit set, or the extension shape.
  Its signature is **pinned** (commit `bd9ae0ac1`); Phase 8 instantiates it unchanged.

### Phase 3: The limit set — definition and consistency [COMPLETED]

- **Goal:** Define the limit-MCS candidate at a real point and prove it consistent.
- **Owns:** `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only).
- **Status note (v2):** the phase's genuine role in the route — *a defined candidate set at an
  arbitrary real point, plus its consistency* — is fully discharged by what landed. Ten
  declarations are sorry-free and the module builds. v1's fourth task was a **false** step, not
  a missing one: rational agreement is unobtainable as a lemma (see Revision Rationale), and the
  property it was reaching for is now obtained by construction in Phase 6. Nothing real remains
  outstanding in this phase, so it is `[COMPLETED]` rather than `[PARTIAL]`, and v1's inline
  BLOCKER block is retired into the Revision Rationale and the module docstring.
- **Tasks:**
  - [x] Define `limitSetBelow (m : Rat → Set Formula) (r : ℝ) : Set Formula :=
        {A | ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < (q:ℝ) → (q:ℝ) < r → A ∈ m q}` — "eventually true
        approaching `r` from below". Define the dual `limitSetAbove` for the past side.
        *(Landed verbatim as specified; `limitSetAbove` uses the mirrored witness `r < z`.)*
  - [x] Prove `limitSetBelow_mono_directed` and its dual `limitSetAbove_mono_directed`: the
        defining family of witness intervals is directed, so any finite list of members shares a
        single threshold. List induction taking `max` (resp. `min`) of thresholds at each cons
        step; the empty list is witnessed by `r - 1` (resp. `r + 1`).
  - [x] Prove `limitSetBelow_finite_subset_mem` and its dual `limitSetAbove_finite_subset_mem`:
        every finite list drawn from the limit set is contained in a **single** `m q`.
        Directedness supplies the common threshold and `exists_rat_btwn` supplies the rational.
        *(This was factored out of v1's consistency task as its own named lemma because Phases 6
        and 7 need the common-witness rational itself, not merely the consistency conclusion.)*
  - [x] Prove `limitSetBelow_consistent` and its dual `limitSetAbove_consistent`: given
        `∀ q, SetMaximalConsistent (fc := fc) (m q)`, conclude
        `SetConsistent (fc := fc) (limitSetBelow m r)`. `SetConsistent`
        (`Core/MaximalConsistent.lean`) is a property of finite subsets, so this is one line
        from the previous task.
  - [x] Prove `limitSetBelow_of_rat` and its dual `limitSetAbove_of_rat` — the coherence
        transfer that is actually available at a rational point:
        `allPast A ∈ m q → A ∈ limitSetBelow m (q:ℝ)` (consumes `backward_H`) and
        `allFuture A ∈ m q → A ∈ limitSetAbove m (q:ℝ)` (consumes `forward_G`). The coherence
        field is taken as an **explicit hypothesis**, so the lemma is usable before the
        real-carrier family is assembled.
        *(This replaces v1's false "the limit set agrees with `m q` on membership".
        `limitSetBelow_of_rat` as landed is the `t = (q:ℝ)` special case of Phase 5's
        `limitSetBelow_backward_H_rat_source`; Phase 5 should **generalize** it in place rather
        than duplicate it, and must not delete it.)*
  - [x] Record the counterexample in the module docstring: both inclusions of the agreement
        claim fail, `forward_G`/`backward_H` are strict, and `allPast` is the strict past
        operator, so there is no `H φ → φ` to appeal to. State that consumers needing genuine
        agreement at rational points must select `m q` directly.
  - [x] `lake build FormalSystem.Metalogic.Bundle.LimitMCS`.
- **Estimated output:** ~200 lines. *(Actual: 223 lines, 10 declarations, sorry-free.)*
- **Done when:** the definitions, directedness, finite-subset containment, consistency, and the
  available coherence transfers are all sorry-free and the module builds.
- **Timing:** 4 hours.
- **Depends on:** 1

### Phase 4: Negation-completeness of the limit set via Prior-U / Prior-S [NOT STARTED]

**This is the crux and the only legitimate `[BLOCKED]` point in the plan. It is new
mathematics, argued from Reynolds' no-definable-gaps lemma rather than transcribed from it.**

- **Goal:** Turn `limitSetBelow m r` into a genuine maximal consistent set.
- **Owns:** `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (extends Phase 3's file).
- **v2 ripple: statements unaffected; one scope reduction.** The crux is a statement about
  `limitSetBelow m r` at a fixed real `r`, with no appeal to rational agreement and no
  dependence on the extension's shape, so rational selection changes nothing here. It does
  **not** narrow the range of `r`: because each family carries its own real offset `δ`, the set
  of unselected points varies with `δ` and their union is all of `ℝ`, so maximality must be
  proved at an arbitrary real. The one genuine reduction is that **the past dual is no longer
  load-bearing** — the extension uses `limitSetBelow` for both `forward_G` and `backward_H`
  (verified case-by-case in Phase 5), so `limitSetAbove_is_mcs` is not required by the route.
- **Tasks:**
  - [ ] Re-read Reynolds 1992 §5, printed p.176 (chunk `reynolds_1992_sec06`) verbatim before
        writing anything: the `γ⁺` definition, the Prior-structure definition, and the one-line
        Prior-U contradiction. Cite by PDF page in the docstring.
  - [ ] State `limitMCS_no_oscillation`: for every `A : Formula` and `r : ℝ`, there is `z < r`
        such that either `A ∈ m q` for all rational `q ∈ (z, r)`, or `A.neg ∈ m q` for all
        rational `q ∈ (z, r)`. This is the MCS-membership analogue of "no definable gaps".
  - [ ] Prove it. The intended argument: `Axiom.prior_U_gap` instances are theorems of
        `FrameClass.Dedekind`, hence in every Dedekind-MCS by `theorem_in_mcs`
        (`MaximalConsistent.lean:491`); reuse the syntactic `kplusFormula`
        (`Kamp/PriorINF.lean:93`) for `K⁺`; derive a contradiction from an oscillating `A`
        exactly as Reynolds does. **Attempt the unrestricted form first** (see Risks).
  - [ ] Prove `limitSetBelow_negation_complete`, then
        `limitSetBelow_is_mcs : SetMaximalConsistent (fc := fc) (limitSetBelow m r)`.
  - [ ] **Fallback, if and only if the unrestricted form fails**: switch to consistency +
        `set_lindenbaum` (Risks, mitigation (b)) and state in the module docstring which route
        was taken and why. Do not silently switch. **(v2)** Before electing (b), read the v2
        sharpening in Risks: it forces Phase 5's six lemmas and Phase 6's `forward_G`/
        `backward_H` to be restated for the chosen extension. Report that cost in the handoff.
  - [ ] Add a named corollary `fc_theorem_true_in_parametric_model` — "every `fc`-theorem is
        true at every point of the parametric canonical model" — as the one-line composition of
        `theorem_in_mcs` with `parametric_shifted_truth_lemma.mp`
        (`ParametricTruthLemma.lean:379`). It does not exist today and is load-bearing: it is how
        Prior-U/Prior-S get from MCS membership to model truth.
  - [ ] `lake build FormalSystem.Metalogic.Bundle.LimitMCS`.
- **Estimated output:** ~250 lines.
- **Done when:** `limitSetBelow_is_mcs` is proved sorry-free at an arbitrary real `r`, **or** the
  phase is marked `[BLOCKED]` with the exact goal state, the tactic attempts made, and which of
  mitigations (a)/(b) were tried. The `limitSetAbove` dual is **not** required; prove it only if
  it falls out for free. Do not report success on a `sorry` unless the contingency in Risks was
  explicitly elected by the orchestrator.
- **Timing:** 6 hours.
- **Depends on:** 3

### Phase 5: forward_G and backward_H across the rational/limit case matrix [NOT STARTED]

- **Goal:** Prove the two temporal-coherence properties as standalone lemmas that do not
  presuppose maximality, so this phase runs in parallel with the crux.
- **Owns:** `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only — coordinate with Phase 3's edit).
- **v2 ripple: AFFECTED — statements restated.** The Phase 3 dispatch asserted this phase was
  unaffected; that is **refuted**. v1's `limitSet_forward_G` / `limitSet_backward_H` state only
  the limit-to-limit case. Under rational selection the extension's value at a point is `m q`
  (selected) or `limitSetBelow m x` (unselected), so `forward_G` and `backward_H` each face a
  2×2 matrix of source/target kinds. v1's prose said "four cases" but its *lemma statements*
  covered one. Below, each of the six non-trivial cases is a separately named lemma. The
  parallelism with Phase 4 is preserved and **verified**: none of the six mentions maximality.
- **Note on the offset `δ`.** Phase 6's families carry a real offset. The offset is absorbed by
  `add_lt_add_right`, so every lemma here is stated **without** `δ`, at bare real arguments.
- **Tasks:**
  - [ ] `limitSetBelow_forward_G_rat_source` (case G1, selected → unselected): for `q : Rat`
        and `t : ℝ` with `(q:ℝ) < t`, `Formula.allFuture φ ∈ m q → φ ∈ limitSetBelow m t`.
        Witness threshold `z := (q:ℝ)`; every rational `p ∈ (q, t)` satisfies `q < p`, so the
        rational family's own `forward_G` (`FMCSDef.lean:114`) delivers `φ ∈ m p`.
  - [ ] `limitSetBelow_forward_G_rat_target` (case G2, unselected → selected): for `s : ℝ` and
        `p : Rat` with `s < (p:ℝ)`, `Formula.allFuture φ ∈ limitSetBelow m s → φ ∈ m p`.
        Take the membership's threshold `z < s`, pick `q ∈ (z, s)` rational by
        `exists_rat_btwn`, then `q < s < p` and `forward_G` applies.
  - [ ] Case G3 (selected → selected) needs **no new lemma**: it is the rational family's
        `forward_G` field verbatim, modulo `Rat.cast_lt`. Record this in the module docstring so
        Phase 6 does not go looking for a lemma that deliberately does not exist.
  - [ ] `limitSetBelow_forward_G_limit` (case G4, unselected → unselected): for `s < t` in `ℝ`,
        `Formula.allFuture φ ∈ limitSetBelow m s → φ ∈ limitSetBelow m t`. Pick a rational
        `q₀ ∈ (z, s)`; then `q₀` itself is a valid threshold for `t`, since every rational
        `p ∈ (q₀, t)` satisfies `q₀ < p`. *(This is v1's `limitSet_forward_G`.)*
  - [ ] `limitSetBelow_backward_H_rat_source` (case H1, selected → unselected): for `q : Rat`
        and `t : ℝ` with `t < (q:ℝ)`, `Formula.allPast φ ∈ m q → φ ∈ limitSetBelow m t`.
        Threshold `z := t - 1`; every rational `p < t < q` satisfies `p < q`, so `backward_H`
        (`FMCSDef.lean:121`) applies. **Generalize Phase 3's `limitSetBelow_of_rat` into this
        lemma in place** — it is exactly the `t = (q:ℝ)` instance. Do not delete it; re-derive
        it as a one-line corollary if it has other consumers.
  - [ ] `limitSetBelow_backward_H_rat_target` (case H2, unselected → selected): for `s : ℝ` and
        `p : Rat` with `(p:ℝ) < s`, `Formula.allPast φ ∈ limitSetBelow m s → φ ∈ m p`. The
        rational must be picked above **both** thresholds: `max z (p:ℝ) < s` because `z < s` and
        `p < s`, so `exists_rat_btwn` on `(max z p, s)` yields `q` with `allPast φ ∈ m q` and
        `p < q`.
  - [ ] `limitSetBelow_backward_H_limit` (case H4, unselected → unselected): for `t < s` in `ℝ`,
        `Formula.allPast φ ∈ limitSetBelow m s → φ ∈ limitSetBelow m t`. Pick a rational
        `q₀ ∈ (max z t, s)`; then `t < q₀`, and `t - 1` is a valid threshold for `t` since every
        rational `p < t` satisfies `p < q₀`. *(This is v1's `limitSet_backward_H`.)*
  - [ ] Case H3 (selected → selected) needs no new lemma; same note as G3.
  - [ ] State every `exists_rat_btwn` interpolation as its own `have` so the case analysis stays
        reviewable, and state each `max`-based bound as its own `have` for the same reason.
  - [ ] `limitSetAbove` plays **no role** in this phase. Do not prove above-side duals; the
        extension uses the below-limit for both temporal directions, and the Phase 3 above-side
        lemmas remain standing but unused assets.
  - [ ] `lake build FormalSystem.Metalogic.Bundle.LimitMCSCoherence`.
- **Estimated output:** ~260 lines.
- **Done when:** all six lemmas are proved sorry-free, the two no-lemma cases are documented,
  and the module builds.
- **Timing:** 5 hours.
- **Depends on:** 3

### Phase 6: The FMCS real extension by rational selection [NOT STARTED]

- **Goal:** Assemble `FMCS (fc := fc) Rat → FMCS (fc := fc) ℝ` under rational selection, with
  its three fields discharged across the case matrix.
- **Owns:** `FormalSystem/Metalogic/Bundle/RealExtension.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only).
- **v2 ripple: REWRITTEN.** v1 defined `mcs := limitSetBelow f.mcs`, a one-sided limit at every
  real point including the rationals, and depended on the false agreement lemma to make the
  extension *extend* rather than *replace*. v2 selects `m q` directly at selected points, which
  makes agreement definitional, and carries a real offset `δ` from the start because Phase 6.1's
  `modal_backward` needs the family set closed under real shifts.
- **Tasks:**
  - [ ] Define `realLimitMCS (m : Rat → Set Formula) (δ : ℝ) : ℝ → Set Formula := fun x =>
        if h : ∃ q : Rat, (q:ℝ) = x + δ then m h.choose else limitSetBelow m (x + δ)`.
        This is `noncomputable` and needs `open Classical` (or `by classical`) for the
        `Decidable` instance on the existential. **Do not** attempt a computable variant.
  - [ ] Prove the selection lemma `realLimitMCS_of_rat (h : (q:ℝ) = x + δ) :
        realLimitMCS m δ x = m q`. `dif_pos` gives `m h'.choose`; `h'.choose_spec` and the
        hypothesis both cast to `x + δ`, so `Rat.cast_injective` identifies `h'.choose = q`.
        **This lemma is the entire point of the revision** — it is the definitional replacement
        for the false `limitSetBelow_of_rat` agreement claim.
  - [ ] Prove `realLimitMCS_of_not_rat (h : ¬ ∃ q : Rat, (q:ℝ) = x + δ) :
        realLimitMCS m δ x = limitSetBelow m (x + δ)` (`dif_neg`).
  - [ ] Prove `realLimitMCS_is_mcs`: case split on the selection condition. Selected points use
        the rational family's `is_mcs`; unselected points use Phase 4's `limitSetBelow_is_mcs`.
  - [ ] Prove `realLimitMCS_forward_G`: for `x < y` in `ℝ`, `allFuture φ ∈ realLimitMCS m δ x →
        φ ∈ realLimitMCS m δ y`. **Four cases**, on whether `x + δ` and `y + δ` are selected:
        - selected/selected → the rational family's `forward_G` field (Phase 5, case G3);
        - selected/unselected → `limitSetBelow_forward_G_rat_source` (G1);
        - unselected/selected → `limitSetBelow_forward_G_rat_target` (G2);
        - unselected/unselected → `limitSetBelow_forward_G_limit` (G4).
        In every case the order hypothesis transports by `add_lt_add_right … δ`; state that
        transport once as a `have` and reuse it.
  - [ ] Prove `realLimitMCS_backward_H` by the mirrored four-case split, consuming
        `limitSetBelow_backward_H_rat_source` (H1), `_rat_target` (H2), `_limit` (H4), and the
        rational family's `backward_H` field (H3).
  - [ ] Bundle these into `FMCS.toRealShift (f : FMCS (fc := fc) Rat) (δ : ℝ) :
        FMCS (fc := fc) ℝ` with `mcs := realLimitMCS f.mcs δ` and the three fields above.
  - [ ] Define `FMCS.toReal (f : FMCS (fc := fc) Rat) : FMCS (fc := fc) ℝ := f.toRealShift 0`
        and prove `FMCS.toReal_at_rat (q : Rat) : (f.toReal).mcs (q:ℝ) = f.mcs q` — the
        "extends rather than replaces" property, now a one-line corollary of
        `realLimitMCS_of_rat` with `add_zero`.
  - [ ] Module docstring: state that rational selection is forced, cite the counterexample by
        naming `Bundle/LimitMCS.lean`'s docstring (**not** a task number), and record that
        `limitSetAbove` is deliberately unused on this route.
  - [ ] `lake build FormalSystem.Metalogic.Bundle.RealExtension`.
- **Estimated output:** ~220 lines.
- **Done when:** `FMCS.toRealShift`, `FMCS.toReal`, and `FMCS.toReal_at_rat` are sorry-free and
  the module builds. No `sorry`, no vacuous definition; if a case cannot be closed, mark the
  phase `[BLOCKED]` with the exact goal state for that case.
- **Timing:** 4 hours.
- **Depends on:** 4, 5

### Phase 6.1: The BFMCS real bundle, box time-stability, and restricted temporal coherence [NOT STARTED]

- **Goal:** Assemble `BFMCS (fc := fc) Rat → BFMCS (fc := fc) ℝ` with a family set closed under
  real shifts, and transport `RestrictedTemporallyCoherent`.
- **Owns:** `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only — coordinate with Phases 3 and 5).
- **Why this is a separate phase (H8):** the modal fields require a new syntactic ingredient
  (box time-stability, itself resting on an S5 negative-introspection derivation) that Phase 6
  does not need at all, and the combined output exceeds one agent run.
- **Tasks:**
  - [ ] Prove `box_stable_in_fmcs {D} [LinearOrder D] (f : FMCS (fc := fc) D) (s t : D)
        (φ : Formula) : Formula.box φ ∈ f.mcs s ↔ Formula.box φ ∈ f.mcs t`.
        Forward-in-time direction: `temporalFutureDerived` (`Combinators.lean:654`, `fc`-generic,
        `□φ → G(□φ)`) + `theorem_in_mcs` + `SetMaximalConsistent.implication_property` +
        `f.forward_G`. Backward-in-time direction: **do not** look for `□φ → H(□φ)` — it is not
        in the tree and adding a `modal_past` axiom is forbidden. Instead push the negation
        forward: derive the `fc`-generic `¬□φ → G(¬□φ)` from S5 negative introspection
        (`¬□φ → □¬□φ`, from `Axiom.modal_5_collapse` / `Theorems/ModalS5.lean`), then
        `Axiom.modal_future` (`Axioms.lean:268`) and `Axiom.modal_t` (`Axioms.lean:98`); apply
        `f.forward_G` and convert with MCS negation-completeness. If negative introspection is
        not already a named theorem, land it here as an `fc`-generic derived theorem.
        Trichotomy on `s` vs `t` needs `LinearOrder`, which both `Rat` and `ℝ` supply.
  - [ ] Prove `box_mem_realLimitMCS_iff (hstab : ∀ s t φ, box φ ∈ m s ↔ box φ ∈ m t) :
        Formula.box φ ∈ realLimitMCS m δ x ↔ ∀ q : Rat, Formula.box φ ∈ m q`. Selected points
        are immediate from `realLimitMCS_of_rat`; at unselected points, membership in the limit
        set yields the property at *some* rational, and time-stability spreads it to all.
        This is the lemma that makes both modal fields case-free.
  - [ ] Define `BFMCS.toRealBundle (B : BFMCS (fc := fc) Rat) : BFMCS (fc := fc) ℝ` with
        `families := {G | ∃ fam ∈ B.families, ∃ δ : ℝ, G = fam.toRealShift δ}`,
        `evalFamily := B.evalFamily.toRealShift 0`. `nonempty` and `eval_family_mem` are
        immediate (`δ := 0`).
  - [ ] Prove `modal_forward`. Via `box_mem_realLimitMCS_iff`, reduce to `box φ ∈ fam.mcs q` for
        every rational `q`; the `Rat` bundle's `modal_forward` then gives `φ ∈ fam'.mcs q` for
        every `q` and every `fam'`, which lands in the target family's value whether that value
        is a selected `m q` or a limit set (the latter with any threshold).
  - [ ] Prove `modal_backward`. **This is the field that forces the real-shift closure.**
        Contrapositive: if `box φ` is absent from the target family's value at `t`, then by
        `box_mem_realLimitMCS_iff` it is absent from `fam.mcs q` for every rational `q`; fix any
        rational `q`; the `Rat` bundle's `modal_backward` contrapositive yields `fam' ∈
        B.families` with `φ ∉ fam'.mcs q`; then `fam'.toRealShift ((q:ℝ) - t)` is a member of
        the real bundle whose value **at `t`** is exactly `fam'.mcs q` by `realLimitMCS_of_rat`,
        contradicting the hypothesis. Record in the docstring **why** the image family set fails
        here: per-family "eventually" thresholds below an unselected `t` admit no common
        rational, so the `Rat`-side field can never be applied. Note that this mirrors the
        `Rat` construction at `ChronicleToCountermodelBasic.lean:576`, which positions its
        witness family by choosing the chronicle's rational shift.
  - [ ] Prove `BFMCS.toRealBundle_restricted_temporally_coherent`: transport
        `RestrictedTemporallyCoherent root` (`TemporalCoherence.lean:308`) from `Rat` to `ℝ`.
        For `someFuture φ ∈ G.mcs t` with `G = fam.toRealShift δ`: at a selected `t` quote the
        rational witness directly and map it back through `realLimitMCS_of_rat`; at an
        unselected `t` obtain the membership at a rational `p` near `t + δ` from the limit set,
        take the rational witness `s' > p`, and return `s' - δ`, checking `t < s' - δ` from
        `p < s'` and `p < t + δ`. `somePast` is the mirror.
  - [ ] `lake build FormalSystem.Metalogic.Bundle.RealExtensionBundle`.
- **Estimated output:** ~280 lines.
- **Done when:** `BFMCS.toRealBundle` and the restricted-temporal-coherence transport are
  sorry-free and the module builds.
- **Timing:** 4 hours.
- **Depends on:** 6

### Phase 7: Restricted forward and backward Until/Since coherence at ℝ [NOT STARTED]

- **Goal:** Transport the two Until/Since coherence predicates to the real bundle. This is
  the hardest transport and is deliberately isolated.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (new),
  `FormalSystem/Metalogic/BXCanonical/Chronicle.lean` (import line only).
- **v2 ripple: statements unaffected, proof obligations refined.** The two predicates
  (`TemporalCoherence.lean:558,589`) are quantified over `B.families` and real times, so their
  *statements* are unchanged by rational selection. What changes: the family set is now the
  real-shift closure, so every proof is `∀ δ : ℝ`; and the guard/witness reasoning splits on
  selected vs unselected times. The split is **not** symmetric in difficulty — see the tasks.
- **Tasks:**
  - [ ] Prove `BFMCS.toRealBundle_restricted_backward_until_since`
        (`TemporalCoherence.lean:589`). The witness-pattern direction is the easier of the two:
        a real witness `s` restricts to a rational one by interpolation, and the guard on
        `(t, s)` weakens to the rational guard.
  - [ ] **Guard lemma, shared by both directions**: a rational guard covering *all rationals* in
        `(t + δ, s + δ)` automatically covers every real `r ∈ (t, s)`. At a selected `r` this is
        `realLimitMCS_of_rat`; at an unselected `r`, `ψ ∈ limitSetBelow m (r + δ)` is witnessed
        by the threshold `t + δ`. Land this as its own named lemma before either forward case —
        it removes the unselected-`r` difficulty that v1 anticipated in the guard.
  - [ ] **Forward case A — selected `t` (mechanical).** From `untl φ ψ ∈ m q` with
        `(q:ℝ) = t + δ`, the `Rat` coherence gives `s' > q` with `φ ∈ m s'` and the rational
        guard on `(q, s')`. Return `s := s' - δ`; `φ ∈ realLimitMCS m δ s` by
        `realLimitMCS_of_rat`, and the guard follows from the shared guard lemma. No appeal to
        Phase 4.
  - [ ] **Forward case B — unselected `t` (the load-bearing case).** From
        `untl φ ψ ∈ limitSetBelow m (t + δ)`, the membership holds at rationals `p ↗ t + δ`, and
        each gives a rational witness `s'_p`. The obstruction is that `s'_p` may shrink to
        `t + δ`, leaving no real `s > t`. **This is where `limitMCS_no_oscillation` (Phase 4) is
        expected to be re-invoked**: if the witnesses shrink to `t + δ`, then `φ` holds
        arbitrarily soon after `t + δ` while `ψ` holds throughout, which is exactly the
        oscillation pattern Prior-U excludes (Reynolds 1992 §5, printed p.176). Prove it, or
        mark **this task only** as the blocked one and report the exact goal state — do not mark
        the whole phase blocked if cases A and the backward direction have landed.
  - [ ] Mirror both forward cases for `snce` (`Formula.snce`).
  - [ ] Land the chronicle-specific instances:
        `cantor_bfmcs_dense_real_restricted_tc` / `_buc` / `_fuc`, obtained by composing the
        three transports with the existing `Rat` instances
        (`ChronicleToCountermodelBasic.lean:629,680,755`). Do not modify those three. Note that
        `_tc` alone carries an extra unnamed closure-containment hypothesis
        `∀ ψ, ψ ∈ deferralClosure root → ψ ∈ (extendedDeferralClosure root).toList`, discharged
        at the call site by
        `fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)`;
        thread it through unchanged rather than reproving it. All three are polymorphic in
        `root`, so no coherence proof needs to change.
  - [ ] `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleRealExtension`.
- **Estimated output:** ~380 lines.
- **Done when:** all three chronicle-specific real-carrier coherence instances are sorry-free and
  the module builds.
- **Timing:** 5 hours.
- **Depends on:** 6.1

### Phase 8: The Dedekind countermodel on ℝ and the unconditional terminus [NOT STARTED]

- **Goal:** Discharge the engine hypothesis of Phase 2 and land `consequence_completeness_dedekind`
  unconditionally, with `completeness_dedekind` as its `Γ = []` corollary.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` (extends Phase 1),
  `FormalSystem/Metalogic/StrongCompleteness.lean` (extends Phase 2),
  `FormalSystem/Metalogic.lean` (tracking table).
- **v2 ripple: statements unaffected; one added verification task.** `countermodel_dedekind_dense`
  quantifies over an abstract `TaskFrame ℝ` and never mentions the extension's internals, and
  `consequence_completeness_dedekind_of_engine`'s pinned signature is untouched. The one thing
  rational selection changes is the *evaluation point*: the root MCS must still sit at the
  evaluation time, and that now needs an explicit check rather than being assumed.
- **Tasks:**
  - [ ] **(v2, new)** Verify the root placement: `B.evalFamily.toRealShift 0` takes the value
        `B.evalFamily.mcs 0` at `t = 0`, because `0 + 0 = ((0 : Rat) : ℝ)` is selected. Compose
        with `rooted_cantor_fmcs_dense_at_s` (`ChronicleToCountermodelBasic.lean:511`) to get
        the root MCS `A` at real time `0`. Land this as a named lemma before the countermodel,
        not as an inline `have`.
  - [ ] Prove `countermodel_dedekind_dense {fc : FrameClass} (A : Set Formula)
        (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) (h_neg_in : φ.neg ∈ A)
        (h_box_dense : Formula.box Chronicle.nextTop.neg ∈ A) :
        ∃ (F : TaskFrame ℝ) (TM : TaskModel F) (Omega : Set (WorldHistory F))
        (_ : ShiftClosed Omega) (τ : WorldHistory F) (_ : τ ∈ Omega) (t : ℝ),
        ¬TruthAt TM Omega τ t φ`. Follow `countermodel_dense_enriched`
        (`Completeness.lean:133-162`) statement-for-statement, substituting `Rat → ℝ`, the
        `BFMCS.toRealBundle` of `Chronicle.cantorBfmcsDense`, and the three Phase 7 coherence
        instances into `fully_restricted_parametric_completeness_from_neg_membership`.
  - [ ] Prove `completeness_dedekind_engine (ψ : Formula) : ValidDedekindDense ψ →
        Derivable FrameClass.Dedekind [] ψ`: contrapositive,
        `neg_consistent_of_not_derivable (fc := FrameClass.Dedekind)`, `set_lindenbaum`,
        `dedekind_box_dense_mem` (Phase 1) for the box-dense hypothesis, then
        `countermodel_dedekind_dense` applied at `ℝ` with `real_lub_of_bddAbove` discharging the
        lub binder of `ValidDedekindDense`.
  - [ ] Instantiate Phase 2's `consequence_completeness_dedekind_of_engine` with this engine to
        obtain the unconditional `consequence_completeness_dedekind`. **Do not restate or re-bind
        that signature** — it is pinned by commit `bd9ae0ac1`.
  - [ ] Derive `completeness_dedekind (φ : Formula) : ValidDedekindDense φ →
        Derivable FrameClass.Dedekind [] φ` as `consequence_completeness_dedekind []`, with `simp`
        discharging `∀ ψ ∈ [], _`. **It must be a corollary, not an independent proof.**
  - [ ] `#print axioms consequence_completeness_dedekind` and `#print axioms completeness_dedekind`;
        record the results.
  - [ ] Update the tracking table in `FormalSystem/Metalogic.lean` (the file at the
        `FormalSystem/` root, not `FormalSystem/Metalogic/Metalogic.lean`, which does not exist)
        with the Dedekind rows, matching the existing `Completeness (dense)` / `(discrete)` row
        format at `:37`,`:39`.
  - [ ] `lake build` (full project).
- **Estimated output:** ~260 lines.
- **Done when:** `consequence_completeness_dedekind` and `completeness_dedekind` are sorry-free; full
  `lake build` is green; `#print axioms` on both shows exactly
  `[propext, Classical.choice, Quot.sound]`; the tracking table is updated.
- **Timing:** 4 hours.
- **Depends on:** 2, 7

---

## Testing & Validation

- [ ] `lake build` green at the end of every phase (scoped module build per phase; full build at
      Phase 8).
- [ ] `#print axioms consequence_completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms completeness_dense` and `#print axioms completeness_discrete` unchanged —
      regression check that no preserved asset was disturbed.
- [ ] `grep -rn "sorry" FormalSystem/ --include=*.lean | grep -v Boneyard` returns exactly the
      pre-existing `Transfer.lean:1242` entry (plus any strategic sorry explicitly elected under
      the Risks contingency, which must then appear in `sorry_inventory`).
- [ ] `FormalSystem/Metalogic/Soundness.lean` still at zero sorries.
- [ ] **(v2)** No declaration anywhere asserts agreement between `limitSetBelow m (q:ℝ)` and
      `m q`. Agreement is available only through `realLimitMCS_of_rat` / `FMCS.toReal_at_rat`.
- [ ] **(v2)** `Bundle/LimitMCS.lean`'s ten Phase 3 declarations are unchanged except for the
      sanctioned in-place generalization of `limitSetBelow_of_rat` in Phase 5.
- [ ] **(v2)** No `modal_past` axiom was added to `ProofSystem/Axioms.lean`.
- [ ] No `.lean` file added or edited by this task contains a task-number citation
      (`.claude/hooks/validate-no-task-references.sh` advisory).
- [ ] No vacuous definitions (`:= True`, `:= trivial`, `:= Unit`) introduced.

## Artifacts & Outputs

- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/02_strong-completeness-dedekind-v2.md` (this file)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/01_strong-completeness-dedekind.md` (superseded predecessor, retained)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/summaries/01_strong-completeness-dedekind-summary.md`
- `FormalSystem/Metalogic/StrongCompleteness.lean` (Phase 2, landed — terminus)
- `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` (Phase 1, landed; Phase 8 extends — countermodel + engine)
- `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (Phase 3, landed; Phase 4 extends — limit set, consistency, maximality)
- `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` (new — the six forward_G / backward_H case lemmas)
- `FormalSystem/Metalogic/Bundle/RealExtension.lean` (new — `realLimitMCS`, `FMCS.toRealShift`, `FMCS.toReal`)
- `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (new — box time-stability, `BFMCS.toRealBundle`, restricted temporal coherence)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (new — U/S coherence transport)
- Aggregator import updates: `FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/Bundle.lean`,
  `FormalSystem/Metalogic/BXCanonical.lean`, `FormalSystem/Metalogic/BXCanonical/Chronicle.lean`

## Rollback/Contingency

- Every file created by this plan is **additive**. Rollback of any phase is deletion of its new
  file plus removal of its one-line aggregator import. No existing declaration is modified except
  the `FormalSystem/Metalogic.lean` tracking table (Phase 8, prose only) and the sanctioned
  in-place generalization of `limitSetBelow_of_rat` (Phase 5).
- Commit at every green milestone per `wrap-up.md` incremental-commit discipline, using
  `task 408 phase {P}: {description}`. Never accumulate multiple phases into one commit.
- Phase 1's probe has passed; the carrier question is closed and does not need re-litigating.
- If Phase 4 blocks, Phases 5-8 still have standing value (the coherence case lemmas, the
  transports, and the terminus statement are all independently sorry-free); mark the task
  `[PARTIAL]` rather than discarding them. Note that Phase 5 is genuinely independent of Phase 4
  and should be dispatched even if Phase 4 blocks.
- If Phase 6.1's `modal_backward` resists even under the real-shift closure, that is a
  **route-level** finding, not a tactical one: it would mean the bundle abstraction cannot be
  transported to a non-selected carrier point at all. Escalate to a new research dispatch rather
  than improvising a fourth extension shape.
