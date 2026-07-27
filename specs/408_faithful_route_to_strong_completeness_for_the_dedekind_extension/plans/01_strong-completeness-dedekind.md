# Implementation Plan: Strong Completeness for FrameClass.Dedekind

- **Task**: 408 - faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Status**: [IMPLEMENTING]
- **Effort**: 28 hours
- **Dependencies**: None (coordinates with, but is not blocked by, the strong-completeness
  architecture and finite-context strong-completeness efforts — neither has artifacts on disk)
- **Research Inputs**:
  - reports/01_faithful-route-strong-completeness.md (primary, adversarially verified)
  - reports/02_literature-coverage-audit.md (secondary, literature infrastructure)
- **Artifacts**: plans/01_strong-completeness-dedekind.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/rules/plan-compliance.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4

---

## Overview

The terminus is `strong_completeness_dedekind : SemanticConsequenceDedekindDense Γ φ →
Derivable FrameClass.Dedekind Γ φ`, with `completeness_dedekind` derived as its `Γ = []`
instance. The route is Route B of the research report: build the countermodel directly on `ℝ`
from a Dedekind-MCS, inside the tree's own parametric canonical architecture, never leaving it.
Reynolds' transfer route (report 390's route) is rejected and no part of it is built.

The single genuinely new mathematical ingredient is a limit-MCS assignment extending a
`BFMCS (fc := fc) Rat` to a `BFMCS (fc := fc) ℝ` along `ℚ ↪ ℝ`. Everything else is either
verbatim reuse of existing frame-class-generic and `D`-generic machinery, or mechanical
transcription. Phases are sequenced risk-first: the `D := ℝ` compile probe is Phase 1, the
terminus statement lands in Phase 2 (so the target can never drift toward weak completeness),
and the crux — negation-completeness of the limit MCS — is reached at Phase 4, before any of the
expensive downstream transport work is paid for.

**Definition of done**: `FormalSystem/Metalogic/StrongCompleteness.lean` contains a sorry-free
`strong_completeness_dedekind` with `completeness_dedekind` as a corollary; `lake build` is
green; `#print axioms strong_completeness_dedekind` shows exactly `[propext, Classical.choice,
Quot.sound]`.

### Research Integration

| Report | Integrated | What it fixes in this plan |
|---|---|---|
| reports/01_faithful-route-strong-completeness.md | v1, 2026-07-27 | Route selection (B over A), phase sequencing, preserved-assets list, bridge prohibitions |
| reports/02_literature-coverage-audit.md | v1, 2026-07-27 | Goldblatt provenance caveat, sub-index gaps, citation discipline (PDF page, never `md:NN`) |

### Preserved Assets

The following work is complete, verified generic, and must not regress. No phase rewrites,
generalizes, or "cleans up" any row in this table.

| Component | File / Anchor | Status | Verified |
|---|---|---|---|
| `deductionTheorem`, `deductionConverse`, `Derivable.deduction` | `Metalogic/Core/DeductionTheorem.lean:325,447,467` | [COMPLETED] `{fc : FrameClass}` implicit, unconstrained | 2026-07-27 |
| `neg_consistent_of_not_derivable` | `Metalogic/BXCanonical/Completeness.lean:72` | [COMPLETED] generic in `fc` | 2026-07-27 |
| `set_lindenbaum`, `SetMaximalConsistent.*`, `theorem_in_mcs` | `Metalogic/Core/MaximalConsistent.lean` (`theorem_in_mcs` at `:491`) | [COMPLETED] generic in `fc` | 2026-07-27 |
| `countermodel_dense_enriched` | `Metalogic/BXCanonical/Completeness.lean:133` | [COMPLETED] `{fc : FrameClass}`; threads `fc` at `:141`,`:157-159`. **Template, not a target** | 2026-07-27 |
| `Chronicle.cantorBfmcsDense` (`:552`), `rootedCantorFmcsDense` (`:500`), `rooted_cantor_fmcs_dense_at_s` (`:511`), `cantor_bfmcs_dense_restricted_tc/_buc/_fuc` (`:629`,`:680`,`:755`) | `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` | [COMPLETED] `(fc : FrameClass)` explicit, carrier `Rat`, all three coherence lemmas fully polymorphic in `root`. `_tc` alone carries an extra closure-containment hypothesis. **Stays at `Rat`** | 2026-07-27 |
| `fully_restricted_parametric_completeness_from_neg_membership` | `Metalogic/Algebraic/RestrictedParametricTruthLemma.lean:417`, vars at `:45` | [COMPLETED] binders `{fc} {D} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` — no `DenselyOrdered`, no `Rat`. **Accepts `D := ℝ` unchanged** | 2026-07-27 |
| `ParametricCanonicalTaskFrame` / `ParametricCanonicalTaskModel` / `parametricToHistory` / `ShiftClosedParametricCanonicalOmega` | `Metalogic/Algebraic/ParametricCanonical.lean`, `ParametricHistory.lean`, `ParametricTruthLemma.lean:240,379` | [COMPLETED] generic in `D` and `fc` | 2026-07-27 |
| `BFMCS` / `FMCS` structures | `Metalogic/Bundle/BFMCS.lean:91`, `Bundle/FMCSDef.lean:103` | [COMPLETED] carrier binder is only `[Preorder D]` | 2026-07-27 |
| The six coherence predicates | `Metalogic/Bundle/TemporalCoherence.lean:277,308,489,526,541,558,589` | [COMPLETED] generic in `D` | 2026-07-27 |
| `soundness_dedekind` | `Metalogic/Soundness.lean:1910` | [COMPLETED] already strong-form: takes `(Γ : Context)` and `h_ctx : ∀ ψ ∈ Γ, TruthAt …` | 2026-07-27 |
| `ValidDedekindDense` | `Semantics/Validity.lean:255` | [COMPLETED] carries the lub property as an explicit `Prop` hypothesis at `:258` | 2026-07-27 |
| `Axiom.prior_U_gap` / `prior_S_gap` / `sep` and their validity | `ProofSystem/Axioms.lean:377,387,398`; `Metalogic/Soundness.lean` | [COMPLETED] | 2026-07-27 |
| `kplusFormula` | `Metalogic/WeakCanonical/Kamp/PriorINF.lean:93` | [COMPLETED] purely syntactic `Formula`-level "holds arbitrarily soon after". **The only reusable item from the Kamp INF files** | 2026-07-27 |

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
verification section of report 01, the literature audit, and a direct inventory performed
during planning.

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
  `completeness_dedekind` is `strong_completeness_dedekind []` after `simp` discharges
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

**MUST preserve**:

- Every row of the Preserved Assets table above, byte-identical unless a phase's Tasks list
  names the file.
- `Metalogic/Soundness.lean` at zero sorries.
- `completeness_dense` and `completeness_discrete` sorryAx-free with axioms exactly
  `[propext, Classical.choice, Quot.sound]`.
- The single live sorry count outside `Boneyard/` must not increase. `Transfer.lean:1242`
  remains the only one at the end of this task unless a strategic sorry is explicitly elected
  under the contingency in Risks below.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

- **Route B, not Reynolds' transfer.** Rejected on two independent grounds: the
  expressive-completeness dependency of D1/D2, and the absence from Mathlib of the
  order-theoretic characterization of `ℝ` (only *field*-theoretic uniqueness exists:
  `LinearOrderedField.uniqueOrderRingIso`, `inducedOrderRingIso`).
- **The terminus is strong, and weak completeness is its `Γ = []` corollary.** `Context` is
  `List Formula` (`Syntax/Context.lean:60`), i.e. finite, so the two are inter-derivable through
  the deduction theorem. Reynolds' "weakly" bites only for infinite `Γ` (his `k` is one greater
  than the quantifier depth of a *single* input formula), which this tree's types cannot
  express. `soundness_dedekind` is already stated in strong arbitrary-`Γ` form, so the strong
  terminus is its exact converse.
- **This is finite-context strong completeness, and the plan says so.** Changing `Context` to
  `Set Formula` would require compactness of the Dedekind-class consequence relation, which is
  a separate open question. Out of scope; do not attempt.
- **Goldblatt's obstruction does not apply.** Goldblatt (arXiv:2310.20069, Introduction) states
  that propositional temporal logic over `(ℝ, <)` *is* recursively — indeed finitely —
  axiomatizable (Bull), and that Scott's non-axiomatizability result is about *first-order*
  temporal logic. The "admissible models" restriction in that paper is a first-order device.
  This does not license reopening the target.
- **The Dedekind case is a special case of the strong-completeness architecture**, not a
  parallel construction. `StrongCompleteness.lean` is laid out as a four-class family so the
  Base/Dense/Discrete instances drop in later without restructuring.
- **The chronicle layer stays at `Rat`; only the layer beneath moves to `ℝ`.** This is the seam,
  and it is fixed.

---

## Goals & Non-Goals

- **Goals**:
  - `strong_completeness_dedekind (Γ : Context) (φ : Formula) : SemanticConsequenceDedekindDense Γ φ → Derivable FrameClass.Dedekind Γ φ`, sorry-free.
  - `completeness_dedekind (φ : Formula) : ValidDedekindDense φ → Derivable FrameClass.Dedekind [] φ` as the `Γ = []` corollary.
  - A reusable `BFMCS (fc := fc) Rat → BFMCS (fc := fc) ℝ` limit extension with its coherence proofs.
  - `FormalSystem/Metalogic.lean` tracking table updated.
- **Non-Goals**:
  - Infinite-context (`Set Formula`) strong completeness or compactness.
  - `strong_completeness_base` / `_dense` / `_discrete` (owned by the finite-context
    strong-completeness effort; this plan only shapes the file so they drop in).
  - Closing `Transfer.lean:1242`.
  - Any Reynolds-transfer artifact (see Postmortem Constraints).
  - Expanding `specs/literature-index.json` (a separate curation concern; the audit's
    recommendations are recorded, not executed here).

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
  preserves `forward_G`/`backward_H` and restricted U/S coherence — a strictly weaker
  obligation. Phase 4 must state which of (a) or (b) it took and why, in the module docstring.
  (c) If neither closes, mark Phase 4 `[BLOCKED]` — see the contingency below.
- **Risk: the `D := ℝ` instantiation claim is second-hand.** Report 01 relied on report 390's
  compile probe rather than re-running it. Route B's entire feasibility rests on it.
  **Mitigation**: Phase 1 is exactly that probe, costs one build, and gates everything.
- **Risk: `RestrictedForwardUntilSinceCoherent` at an irrational `t` is the hardest transport.**
  Producing `s > t` with the guard `ψ ∈ mcs r` for *all* `r ∈ (t,s)` — including irrational
  `r` — re-invokes the limit-MCS property rather than merely quoting the `Rat` witness.
  **Mitigation**: it is isolated in its own phase (7), after the limit MCS is fully
  characterized, so it cannot silently consume the crux phase's budget.
- **Risk: analysis paralysis on the crux.** **Mitigation**: Phases 2 and 3 land real,
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
| 5 | 7 | 6 |
| 6 | 8 | 2, 7 |

Phases within the same wave can execute in parallel. Territory contracts (H7): each phase owns
the files listed under its **Owns** line and MUST NOT edit any file owned by a concurrent phase.
Phases 1 and 2 own disjoint new files. Phases 4 and 5 own disjoint new files and are the only
declared parallel pair in the engine.

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

### Phase 2: SemanticConsequenceDedekindDense, the semantic deduction lemma, and the terminus statement [COMPLETED]

- **Goal:** Land `strong_completeness_dedekind` — the task's terminus — **with the
  single-formula engine as an explicit hypothesis**, so the target is fixed and sorry-free
  before any engine work begins, and can never drift toward weak completeness.
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
  - [x] Prove `strong_completeness_dedekind_of_engine`: given
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
  - [x] Module docstring: record (i) that the terminus is strong and weak completeness is the
        `Γ = []` instance; (ii) that Reynolds' Theorem 7 (§9, printed p.189) is *weak* and why
        that does not bite at `Context = List Formula`; (iii) the Goldblatt point — propositional
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

### Phase 3: The limit set — definition and consistency [PARTIAL]

- **Goal:** Define the limit-MCS candidate at a real point and prove it consistent.
- **Owns:** `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only).
- **Tasks:**
  - [x] Define `limitSetBelow (m : Rat → Set Formula) (r : ℝ) : Set Formula :=
        {A | ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < (q:ℝ) → (q:ℝ) < r → A ∈ m q}` — "eventually true
        approaching `r` from below". Define the dual `limitSetAbove` for the past side.
        *(Landed verbatim as specified; `limitSetAbove` uses the mirrored witness `r < z`.)*
  - [x] Prove `limitSetBelow_mono_directed`: the defining family is directed, so finite subsets
        of `limitSetBelow m r` share a common witness interval. Use `exists_rat_btwn` /
        `Rat.denselyOrdered` for the non-emptiness of `ℚ ∩ (z, r)`.
        *(Landed with its dual `limitSetAbove_mono_directed`; list induction taking `max`/`min`
        of thresholds. `exists_rat_btwn` is used one step later, in the consistency proof, where
        the non-emptiness of `ℚ ∩ (z, r)` is actually consumed.)*
  - [x] Prove `limitSetBelow_consistent`: given `∀ q, SetMaximalConsistent (fc := fc) (m q)`,
        every finite subset of `limitSetBelow m r` is contained in a single `m q`, hence
        `SetConsistent (fc := fc) (limitSetBelow m r)`.
        *(deviation: altered — the "contained in a single `m q`" step was factored out as its own
        named lemma `limitSetBelow_finite_subset_mem` (plus dual), because Phases 6 and 7 need the
        common-witness rational itself, not merely the consistency conclusion. Both duals landed.)*
  - [ ] Prove `limitSetBelow_of_rat`: for `r = (q : ℝ)` with `q : Rat`, the limit set agrees
        with `m q` on membership. (This is what makes the extension *extend* rather than replace;
        it consumes the `Rat`-family's own `forward_G`/`backward_H` coherence.)
        *(deviation: BLOCKED as written — the agreement claim is false; see the BLOCKER block
        below. A sorry-free `limitSetBelow_of_rat` was landed stating the coherence transfer that
        is actually available, and the falsity of the stronger claim is documented in the module
        docstring.)*
  - [x] `lake build FormalSystem.Metalogic.Bundle.LimitMCS`.
- **Estimated output:** ~200 lines.
- **Done when:** all four declarations are sorry-free and the module builds.
- **Timing:** 4 hours.
- **Depends on:** 1

**BLOCKER** (Phase 3, task 4 only — tasks 1-3 are complete and sorry-free):

- **What failed**: `limitSetBelow_of_rat` as written — "for `r = (q : ℝ)` with `q : Rat`, the
  limit set agrees with `m q` on membership". Neither inclusion is derivable, and neither is
  true.
- **Counterexample**: let `P` be an atom, and let the family `m` be the theory-family of a
  genuine dense model in which `P` holds at every rational `p < 0` and fails at `0`. Every FMCS
  field is satisfied (they are semantic consequences), yet `P ∈ limitSetBelow m 0` while
  `P ∉ m 0`. The mirror construction (`P` at `0` only) refutes the other inclusion.
- **Current behavior**: `FMCS.forward_G` and `FMCS.backward_H` (`Bundle/FMCSDef.lean:110,118`)
  are both stated with **strict** inequalities, matching TM's strict temporal operators. Nothing
  relates membership *at* `q` to membership *strictly below* `q`; there is no `H φ → φ` axiom to
  appeal to, since `allPast` is the strict past operator.
- **Required behavior**: what coherence does transfer is whole-past / whole-future content, and
  that is what landed sorry-free: `limitSetBelow_of_rat` now reads
  `allPast A ∈ m q → A ∈ limitSetBelow m (q : ℝ)` (consumes `backward_H`), with dual
  `limitSetAbove_of_rat` reading `allFuture A ∈ m q → A ∈ limitSetAbove m (q : ℝ)`
  (consumes `forward_G`). The coherence field is taken as an explicit hypothesis so the lemma is
  usable before the real-carrier family is assembled.
- **Isolation**: this is a defect in the plan step, not in the code. It does not touch tasks 1-3,
  does not affect Phase 4 (whose subject is `limitMCS_no_oscillation` on a *fixed* real `r`, with
  no appeal to rational agreement), and does not affect Phase 5.
- **What is needed to unblock**: a Phase 6 design decision, since Phase 6 owns `FMCS.toReal`.
  The extension must select `m q` **directly** at rational arguments rather than taking a
  one-sided limit there — i.e. `mcs r := if h : ∃ q : Rat, (q : ℝ) = r then m h.choose else
  limitSetBelow m r` (or the equivalent via `Rat.cast_injective`) — at which point genuine
  agreement at rational points holds by definition and the "extend rather than replace" property
  the plan step was reaching for is recovered. Phase 6's `forward_G`/`backward_H`/`modal_*`
  obligations then acquire a rational/irrational case split that the plan's Phase 6 task list
  does not currently anticipate.
- **Prohibited**: no `sorry`, no `def X := True`, no vacuous placeholder was introduced; the
  module is sorry-free and the live sorry census is unchanged.

### Phase 4: Negation-completeness of the limit set via Prior-U / Prior-S [NOT STARTED]

**This is the crux and the only legitimate `[BLOCKED]` point in the plan. It is new
mathematics, argued from Reynolds' no-definable-gaps lemma rather than transcribed from it.**

- **Goal:** Turn `limitSetBelow m r` into a genuine maximal consistent set.
- **Owns:** `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (extends Phase 3's file).
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
        was taken and why. Do not silently switch.
  - [ ] Add a named corollary `fc_theorem_true_in_parametric_model` — "every `fc`-theorem is
        true at every point of the parametric canonical model" — as the one-line composition of
        `theorem_in_mcs` with `parametric_shifted_truth_lemma.mp`
        (`ParametricTruthLemma.lean:379`). It does not exist today and is load-bearing: it is how
        Prior-U/Prior-S get from MCS membership to model truth.
  - [ ] `lake build FormalSystem.Metalogic.Bundle.LimitMCS`.
- **Estimated output:** ~250 lines.
- **Done when:** `limitSetBelow_is_mcs` (and its past dual) are proved sorry-free, **or** the
  phase is marked `[BLOCKED]` with the exact goal state, the tactic attempts made, and which of
  mitigations (a)/(b) were tried. Do not report success on a `sorry` unless the contingency in
  Risks was explicitly elected by the orchestrator.
- **Timing:** 6 hours.
- **Depends on:** 3

### Phase 5: forward_G and backward_H for the limit set [NOT STARTED]

- **Goal:** Prove the two temporal-coherence properties of the limit set as standalone lemmas
  that do not presuppose maximality, so this phase runs in parallel with the crux.
- **Owns:** `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only — coordinate with Phase 3's edit).
- **Tasks:**
  - [ ] Prove `limitSet_forward_G`: for `s t : ℝ` with `s < t` and
        `Formula.allFuture φ ∈ limitSetBelow m s`, conclude `φ ∈ limitSetBelow m t`. Four cases
        on rational/irrational `s`, `t`; the rational-rational case reduces to the `Rat` family's
        own `FMCS.forward_G` (`FMCSDef.lean:114`).
  - [ ] Prove `limitSet_backward_H`, the dual (`FMCSDef.lean:121`).
  - [ ] Use `exists_rat_btwn` to interpolate rationals in every mixed case; state each
        interpolation as its own `have` so the case analysis stays reviewable.
  - [ ] `lake build FormalSystem.Metalogic.Bundle.LimitMCSCoherence`.
- **Estimated output:** ~220 lines.
- **Done when:** both lemmas are proved sorry-free and the module builds.
- **Timing:** 4 hours.
- **Depends on:** 3

### Phase 6: The FMCS/BFMCS real extension and restricted temporal coherence [NOT STARTED]

- **Goal:** Assemble `BFMCS (fc := fc) Rat → BFMCS (fc := fc) ℝ` and transport
  `RestrictedTemporallyCoherent`.
- **Owns:** `FormalSystem/Metalogic/Bundle/RealExtension.lean` (new),
  `FormalSystem/Metalogic/Bundle.lean` (import line only).
- **Tasks:**
  - [ ] Define `FMCS.toReal (f : FMCS (fc := fc) Rat) : FMCS (fc := fc) ℝ` with
        `mcs := limitSetBelow f.mcs`, `is_mcs := limitSetBelow_is_mcs`,
        `forward_G := limitSet_forward_G`, `backward_H := limitSet_backward_H`.
  - [ ] Define `BFMCS.toReal (B : BFMCS (fc := fc) Rat) : BFMCS (fc := fc) ℝ` with
        `families := FMCS.toReal '' B.families`, `evalFamily := B.evalFamily.toReal`.
        `nonempty` and `eval_family_mem` are immediate from `Set.image`.
  - [ ] Prove the `modal_forward` and `modal_backward` fields (`BFMCS.lean:104,112`) at every
        real `t`, including irrational `t`. The `Formula.box φ ∈ limitSetBelow` unfolding plus
        the `Rat`-side fields is the intended route; the irrational case needs the eventual-
        containment witness from Phase 3.
  - [ ] Prove `BFMCS.toReal_restricted_temporally_coherent`: transport
        `RestrictedTemporallyCoherent root` (`TemporalCoherence.lean:308`) from `Rat` to `ℝ`.
        The `someFuture`/`somePast` witnesses at an irrational `t` come from the rational
        witnesses via `exists_rat_btwn`.
  - [ ] `lake build FormalSystem.Metalogic.Bundle.RealExtension`.
- **Estimated output:** ~300 lines.
- **Done when:** `BFMCS.toReal` and the restricted-temporal-coherence transport are sorry-free
  and the module builds.
- **Timing:** 5 hours.
- **Depends on:** 4, 5

### Phase 7: Restricted forward and backward Until/Since coherence at ℝ [NOT STARTED]

- **Goal:** Transport the two Until/Since coherence predicates to the real extension. This is
  the hardest transport and is deliberately isolated.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (new),
  `FormalSystem/Metalogic/BXCanonical/Chronicle.lean` (import line only).
- **Tasks:**
  - [ ] Prove `BFMCS.toReal_restricted_backward_until_since`
        (`TemporalCoherence.lean:589`). The witness pattern direction is the easier of the two:
        a real witness `s` restricts to a rational one by interpolation, and the guard on
        `(t, s)` weakens to the rational guard.
  - [ ] Prove `BFMCS.toReal_restricted_forward_until_since`
        (`TemporalCoherence.lean:558`). This is the load-bearing direction: from
        `Formula.untl φ ψ ∈ limitSetBelow (fam.mcs) t` produce `s > t` with `φ` at `s` and
        `ψ ∈ mcs r` for **all** `r ∈ (t, s)` — irrational `r` included. Expect to re-invoke
        `limitMCS_no_oscillation` (Phase 4) here rather than merely quoting the `Rat` witness.
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
- **Estimated output:** ~300 lines.
- **Done when:** all three chronicle-specific real-carrier coherence instances are sorry-free and
  the module builds.
- **Timing:** 5 hours.
- **Depends on:** 6

### Phase 8: The Dedekind countermodel on ℝ and the unconditional terminus [NOT STARTED]

- **Goal:** Discharge the engine hypothesis of Phase 2 and land `strong_completeness_dedekind`
  unconditionally, with `completeness_dedekind` as its `Γ = []` corollary.
- **Owns:** `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` (extends Phase 1),
  `FormalSystem/Metalogic/StrongCompleteness.lean` (extends Phase 2),
  `FormalSystem/Metalogic.lean` (tracking table).
- **Tasks:**
  - [ ] Prove `countermodel_dedekind_dense {fc : FrameClass} (A : Set Formula)
        (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) (h_neg_in : φ.neg ∈ A)
        (h_box_dense : Formula.box Chronicle.nextTop.neg ∈ A) :
        ∃ (F : TaskFrame ℝ) (TM : TaskModel F) (Omega : Set (WorldHistory F))
        (_ : ShiftClosed Omega) (τ : WorldHistory F) (_ : τ ∈ Omega) (t : ℝ),
        ¬TruthAt TM Omega τ t φ`. Follow `countermodel_dense_enriched`
        (`Completeness.lean:133-162`) statement-for-statement, substituting `Rat → ℝ`, the
        `BFMCS.toReal` of `Chronicle.cantorBfmcsDense`, and the three Phase 7 coherence
        instances into `fully_restricted_parametric_completeness_from_neg_membership`.
  - [ ] Prove `completeness_dedekind_engine (ψ : Formula) : ValidDedekindDense ψ →
        Derivable FrameClass.Dedekind [] ψ`: contrapositive,
        `neg_consistent_of_not_derivable (fc := FrameClass.Dedekind)`, `set_lindenbaum`,
        `dedekind_box_dense_mem` (Phase 1) for the box-dense hypothesis, then
        `countermodel_dedekind_dense` applied at `ℝ` with `real_lub_of_bddAbove` discharging the
        lub binder of `ValidDedekindDense`.
  - [ ] Instantiate Phase 2's `strong_completeness_dedekind_of_engine` with this engine to
        obtain the unconditional `strong_completeness_dedekind`.
  - [ ] Derive `completeness_dedekind (φ : Formula) : ValidDedekindDense φ →
        Derivable FrameClass.Dedekind [] φ` as `strong_completeness_dedekind []`, with `simp`
        discharging `∀ ψ ∈ [], _`. **It must be a corollary, not an independent proof.**
  - [ ] `#print axioms strong_completeness_dedekind` and `#print axioms completeness_dedekind`;
        record the results.
  - [ ] Update the tracking table in `FormalSystem/Metalogic.lean` (the file at the
        `FormalSystem/` root, not `FormalSystem/Metalogic/Metalogic.lean`, which does not exist)
        with the Dedekind rows, matching the existing `Completeness (dense)` / `(discrete)` row
        format at `:37`,`:39`.
  - [ ] `lake build` (full project).
- **Estimated output:** ~250 lines.
- **Done when:** `strong_completeness_dedekind` and `completeness_dedekind` are sorry-free; full
  `lake build` is green; `#print axioms` on both shows exactly
  `[propext, Classical.choice, Quot.sound]`; the tracking table is updated.
- **Timing:** 4 hours.
- **Depends on:** 2, 7

---

## Testing & Validation

- [ ] `lake build` green at the end of every phase (scoped module build per phase; full build at
      Phase 8).
- [ ] `#print axioms strong_completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms completeness_dense` and `#print axioms completeness_discrete` unchanged —
      regression check that no preserved asset was disturbed.
- [ ] `grep -rn "sorry" FormalSystem/ --include=*.lean | grep -v Boneyard` returns exactly the
      pre-existing `Transfer.lean:1242` entry (plus any strategic sorry explicitly elected under
      the Risks contingency, which must then appear in `sorry_inventory`).
- [ ] `FormalSystem/Metalogic/Soundness.lean` still at zero sorries.
- [ ] No `.lean` file added or edited by this task contains a task-number citation
      (`.claude/hooks/validate-no-task-references.sh` advisory).
- [ ] No vacuous definitions (`:= True`, `:= trivial`, `:= Unit`) introduced.

## Artifacts & Outputs

- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/01_strong-completeness-dedekind.md` (this file)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/summaries/01_strong-completeness-dedekind-summary.md`
- `FormalSystem/Metalogic/StrongCompleteness.lean` (new — terminus)
- `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` (new — countermodel + engine)
- `FormalSystem/Metalogic/Bundle/LimitMCS.lean` (new — limit set, consistency, maximality)
- `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` (new — forward_G / backward_H)
- `FormalSystem/Metalogic/Bundle/RealExtension.lean` (new — FMCS/BFMCS real extension)
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (new — U/S coherence transport)
- Aggregator import updates: `FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/Bundle.lean`,
  `FormalSystem/Metalogic/BXCanonical.lean`, `FormalSystem/Metalogic/BXCanonical/Chronicle.lean`

## Rollback/Contingency

- Every file created by this plan is **additive**. Rollback of any phase is deletion of its new
  file plus removal of its one-line aggregator import. No existing declaration is modified except
  the `FormalSystem/Metalogic.lean` tracking table (Phase 8, prose only).
- Commit at every green milestone per `wrap-up.md` incremental-commit discipline, using
  `task 408 phase {P}: {description}`. Never accumulate multiple phases into one commit.
- If Phase 1's probe fails, the route is refuted and the task returns to research — do not
  improvise a substitute carrier.
- If Phase 4 blocks, Phases 5-8 still have standing value (the coherence lemmas, the transports,
  and the terminus statement are all independently sorry-free); mark the task `[PARTIAL]` rather
  than discarding them.
