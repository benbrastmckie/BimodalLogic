# Implementation Plan: Task #761

- **Task**: 761 - Ladder realization theorem: `LadderCons` and `ladderRealized` per ladder cell for all φ including box/stab letters
- **Status**: [IMPLEMENTING] (Phases 1-9 landed; Phases 10-18 open)
- **Effort**: 26.5 hours costable (Phases 1-10, 12-14, 16-18; 13.5 hours landed in Phases 1-9, 13 hours open) + Phase 11 NOT COSTABLE + Phase 15 NOT COSTABLE
- **Dependencies**: 760, 775, 805, 806, 819, 820 — all six discharged (760/775 archived; 805/806 `[COMPLETED]`; 819 the presentation decision; 820 the counter-lift gate table). No open edge remains, and nothing external gates this task.
- **Research Inputs**:
  - specs/761_ladder_realization_theorem/reports/01_ladder-realization-theorem.md
  - specs/761_ladder_realization_theorem/reports/02_spawn-analysis.md
  - specs/761_ladder_realization_theorem/handoffs/phase-11-handoff-20261019T015000Z.md — the four candidate certified sets ruled out, the two compiled obstruction lemmas quoted verbatim, why the depth stratification does not escape the lift, and the two routes
  - specs/761_ladder_realization_theorem/issues.jsonl — the defect records this decomposition answers (`iss_1792373250168_HQM6Je`, `iss_1792371983865_eguQ2e`, `iss_1792372368202_nOhWHn`, `iss_1792372563886_rqlCcV`, `iss_1792373250210_XLCCt8`, `iss_1792365111362_wjBgRA`, `iss_1792365551644_Swi1MU`, `iss_1792362555829_ZKb2Nf`)
  - specs/761_ladder_realization_theorem/.dispatch/8-aux-plan-revision.md — the parameter-hypothesis research, carried verbatim in that dispatch's `## Prompt` block and transcribed under "Research Integration" below
  - specs/761_ladder_realization_theorem/.decisions.json — the two recorded decisions this decomposition implements
  - specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md
  - specs/820_ladder_counter_lift_lemma_gated/summaries/01_counter-lift-gate-table-summary.md
- **Artifacts**: plans/04_ladder-agreement-first-decomposition.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The filed record asks for a library module carrying `LadderCons`, `ladderCons_localRun` and the
per-cell realization `ladderRealized` for ALL `φ`, `box`/`stab` letters included. Statability is
restored by presentation (a), the set-valued per-state datum: the index is `Dmax`, the maximum
`certAdmK`-certified subset of the carrier `Q × ClType φ × CK Tc Tn P B`; `ladderRealized` is the
FIBRE EQUATION; the factorization lemma for `CK` is its COROLLARY, never its hypothesis; and no
tuple is stated as an index at any parameters, `CK` being a carrier coordinate whose parameters are
outputs of the counter-lift lemma.

**The decomposition below proves the agreement of class-equivalent cells FIRST, at the history
level, and derives every certificate-side obligation from it.** That order is the whole content of
this round's revision, and it is what makes the phase graph acyclic. The reason the previous order
could not work is one compiled fact: for any `certStabK`-certified set, the `⊡` bits of two
class-equivalent members coincide (`stab_bit_agree_of_certStabK`), and the `⊡` bit of a realized
type is a datum of the cell at its own world state (`stab_mem_tpOf_iff_cell`), while `certBiInfK`
forbids confining a certified set to one state's cell — so discharging `certStabK` on any set
containing a realized item requires exactly the statement `cellAt_const_of_kappa_eq` makes.
Deriving that statement in turn from soundness and the lift, as a corollary, closes a cycle. The
agreement is therefore proved on its own ground, in a module that mentions no certificate object
at all, and soundness, the lift and the fibre equation all read it as an input.

**The parameter hypothesis is landed and is preserved unchanged.** `cellAt_const_of_kappa_eq` and
`ladderRealized` carry `(hp : ParamsOk step pend lab φ Tc Tn P B)` — the conjunction of the
parameter sources (K1)-(K4), defined in `CounterQuotient.lean` beside `CK`/`kappa` — because the
free universal quantification over `(Tc Tn P B : Nat)` is REFUTED: at `Tc = Tn = P = B = 0` the
quotient `CK 0 0 0 0` is a subsingleton (`ck_zero_subsingleton`, by `decide`; inhabited by
`ckZero`), so `kappa 0 0 0 0` identifies every counter pair whatever `kappa` is, and both
statements then assert the ladder cell is constant in `(c, n)` — which `cell_succ_ne` refutes for
every `c` and `n` at fixed next deadline. That refutation is landed unconditionally as the
fourteenth wired probe,
`specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean`
(`Probe761R`), holding for every `kappa` and every candidate `Dmax`, non-vacuity witnessed on both
sides, using no property of `Dmax`. `paramsOk_params` discharges the hypothesis at the parameters
the periodicity fixpoint defines and `not_paramsOk_allZero` proves it excludes the refuted tuple;
both are landed. `ladderSound`, `ladderLift` and `ladderCons_localRun` carry no parameter
hypothesis: the refutation says nothing about them, and their recorded signatures stand
token-for-token.

Licensed is not proved. This task inherits the obligations: **(S)** soundness, **(C')**
completeness in pumping form, the AGREEMENT of class-equivalent cells, and the `certStab` rebuild
per `(q, κ)` with gate 8 still SIDESTEPPED until Phase 17.

Definition of done: `ladderRealized` proved as the fibre equation for ALL `φ` with the
`box`/`stab` acceptance clause intact and the parameter hypothesis discharged at the defined
outputs, over the admissible-carrier frame `ladderFrameAdm`, with no `sorry`, axiom, vacuous
definition, trace-level `Presented` hypothesis, finite-fibre or finite-width assumption, and no
tuple index stated at any parameters. The contingency is unchanged and binding: if a theorem does
not close, the phase is marked `[BLOCKED]` with the goal state recorded.

### The Two Decisions This Decomposition Implements

Both are recorded in `specs/761_ladder_realization_theorem/.decisions.json`; neither is invented
here.

**Decision 1 — the route out of the mutual circularity of (S), (C') and the agreement: route
(R-b)**, recorded 2026-10-19T02:24:59Z. Prove `cellAt_const_of_kappa_eq` first and directly at the
history level, with the counter-lift lemma in its PUMPING form (the chain-replacement machinery);
then `Real`'s certification by Finding 3; then (S); then (C'); then the fibre equation. The
alternative on the table, (R-a), was one simultaneous induction on `⊡`-nesting depth across the
three obligations, with depth-stratified internal statements and the three pinned Goals as the
`d = max` corollaries.

Why (R-b) is the right route, stated so a reader can check it without re-deriving the obstruction:

- The task's own 2026-10-18 description amendment orders the lift before sufficiency — "the
  realization theorem now waits on the counter-lift lemma (obligations (2) and (3) jointly) …
  gated before any sufficiency attempt" — and task 820 is discharged with BOTH decision gates
  COLLIDING, so the lemma's two halves are licensed in pumping form and no open edge remains.
  The earlier phase order put sufficiency ahead of the lift, inverting the record.
- Every pinned Goal signature survives (R-b) unchanged. (R-a) would have to introduce
  depth-stratified internal statements of all three obligations, and `Dmax` is defined by
  `certAdmK` over the whole closure and is NOT depth-stratified, so (R-a) adds a stratified
  certificate family beside the landed `CounterQuotient.lean` layer, and stratifies `certChain`
  with it.
- The depth stratification (R-a) rests on does not by itself escape the lift: at depth `d` the
  argument needs, for each class-equivalent state and each history through it, a history through
  the given state agreeing on a formula of depth `d - 1`, which is the lift at lower depth. The
  induction is genuinely simultaneous in (S) and (C'). (R-a) is therefore not a cheaper route than
  (R-b); it is the same mathematics with a larger certificate layer in front of it.
- `certChain`'s shape follows the route: under (R-b) it is NOT stratified by `⊡`-nesting depth,
  which is why Phase 10 can own it outright.

**Decision 2 — the form of the repair to the two refuted Challenge statements: the parameter
hypothesis, not existential quantification**, recorded 2026-10-18T23:39:29Z and landed in Phase 9.
Both statements take `(hp : ParamsOk step pend lab φ Tc Tn P B)` and keep their universal shape
over the parameters. Existentially quantifying the parameters instead would turn each statement
into "there exist parameters at which the cell factors", which no consumer can instantiate at the
parameters it actually holds: 763 needs the factorization AT the periodicity fixpoint's own
outputs, and the hypothesis form gives it exactly that through `paramsOk_params`. The predicate is
`ParamsOk step pend lab φ Tc Tn P B` — not a predicate on four naturals — because (K1) quantifies
the certificate graph's cycle lengths on saturated classes, (K2) the cascade bound and the
semantic periodicity threshold, and (K4) the formula's backward exactness depth `d_back`; a
numeric-only predicate would reintroduce the same contract gap one level down. `paramsOk_params`
(the discharge at the defined outputs) and `not_paramsOk_allZero` (the predicate fails at the
refuted tuple, so the repair is load-bearing and not cosmetic) are both landed and proved.

### Why the New Decomposition Is Acyclic

This is the revision's acceptance criterion, and it is checkable mechanically.

The essential edge in the old decomposition ran both ways between the certificate layer and the
agreement: soundness needed the agreement to discharge `certStabK`, and the agreement was planned
as a corollary of soundness and the lift. The revision cuts that cycle at exactly one place, and
only there: **the agreement is no longer derived from any certificate-side statement.** Phase 11
proves it in `LadderAgree.lean`, a module whose only inputs are the ladder model
(`LadderModel.lean`), the cell (`AnchorLayer.lean`), the pin lemma's lift half (`RunLayer.lean`,
Phase 7) and `kappa`/`ParamsOk` from `CounterQuotient.lean`. It mentions no `certAdmK`, no
`certStabK`, no `certBoxK`, no `certBiInfK`, no `Dmax`, no `certChain` and no `ClType` anywhere
outside a docstring — which is a grep, and is a stated verification criterion of that phase.

With that one edge removed, every remaining edge points forward in the numbering, so the graph is
a DAG and the wave table below is a topological order of it. The three places the old
decomposition closed a loop are each answered by a forward edge:

| Old loop | Where it closed | New forward edge |
|----------|-----------------|------------------|
| soundness ↔ the agreement | (S) needed `certStabK` on a set containing a realized item, which forces the agreement; the agreement was a corollary of (S) and (C') | 11 (agreement, certificate-free) → 12 (`Real` certified) → 13 ((S)) |
| the bundle ↔ soundness | `ladderCons_localRun`'s second conjunct `∀ t, xi t ∈ R` needed the projection to lie in `Dmax`, which IS (S), while (S) depended on the bundle's phase | 13 ((S)) → 14 (`ladderCons_localRun`), with `LadderCons`'s own definition pulled back to 10 so the bundle's DEFINITION no longer waits on its THEOREM |
| the lift ↔ `Dmax ⊆ Real` | the reverse inclusion is the lift's own content, and was assumed available to earlier phases | 15 ((C')) owns both `ladderLift` and the pointwise corollary `Dmax ⊆ Real`; nothing before 15 uses that inclusion |

No phase's `Depends on` set names a phase numbered above it, and the one cross-wave edge (Phase 7
→ Phases 11 and 15, the pin lemma) runs from a landed phase. A reader can check acyclicity by
reading the `Depends on` lines alone.

### Research Integration

No new research report is integrated: both reports under `reports/` predate this plan and their
findings are carried below. This round's new input is the phase-11 handoff
(`handoffs/phase-11-handoff-20261019T015000Z.md`) together with the issue records it is cross-cut
by, and the two recorded decisions above. The parameter-hypothesis research is carried in the
bullets of this section and quoted verbatim in the `## Prompt` block of
`specs/761_ladder_realization_theorem/.dispatch/8-aux-plan-revision.md`.

- **The obstruction, as two compiled lemmas and one quoted finding — the reason the agreement comes
  first.** `stab_bit_agree_of_certStabK`: for every `R` with `certStabK φ Tc Tn P B R`, every
  `x y ∈ R` with `y.1 = x.1` and `y.2.2 = x.2.2`, and every `ψ ∈ plusSubformulaClosure φ` with
  `isStab ψ = true`, `ψ ∈ x.2.1.val ↔ ψ ∈ y.2.1.val` — ANY certified set collapses the `⊡` bits
  across a `(q, κ)`-class. `stab_mem_tpOf_iff_cell`: `PlusFormula.stab χ ∈ tpOf M φ σ z ↔ ∀ T ∈
  cellAt M φ (σ.state z) z, χ ∈ T` — the `⊡` bit of a realized type IS a cell-level datum. Both
  compiled standalone through the build guard (exit 0, no errors, no `sorry`) and are quoted in
  full in the phase-11 handoff; Phases 11 and 12 land them. Read with `certBiInfK`, which forbids
  confining a certified set to one state's cell, they say that discharging `certStabK` on a set
  containing a realized item requires the agreement.
- **The four candidate certified sets already ruled out, and why none is re-proposed.** (1) The
  projection of ONE admissible ladder history: `certBoxK`'s `←` direction forces `□ψ ∈ x.2.1.val`
  as soon as every member of `R` carries `ψ`, while `box_mem_tpOf_iff` makes the real bit quantify
  over EVERY history of the model — one chain cannot refute a `□`. (2) The full realizable set
  (`Real`, Finding 3): (1), (2), (4) and (6) are reachable, (5) `certStabK` is not, for the reason
  the two lemmas above state. (3) The cell at one representative state per `(q, κ)`-class: (5)
  holds at the representative but (2) `certBiInfK` fails, because the successor forced at a member
  lies at the NEXT ladder state, whose class has its own representative. (4) Confining `R` to a
  single state's cell: refuted by (2) for the same reason as (3). Candidate (2) is the one the
  revision takes, and it is reached by first proving the agreement — which is exactly the gap
  between (3) and (2).
- **No union argument substitutes for `Dmax`'s own certification.** `certStabK` and `certBoxK` are
  BICONDITIONALS between a letter's bit and a fibre of the candidate set, so enlarging the set
  breaks them; only the four monotone conditions survive a union, and `CounterQuotient.lean` says
  so in source. `Dmax` is the union (the lattice join) and `dmax_maximal` proves every certified
  set lies inside it; `dmax_certLocK`, `dmax_certBiInfK`, `dmax_certFwdK` and `dmax_certBwdK` are
  the four monotone conditions proved OF `Dmax`. The route to `Dmax`'s own certification is
  Finding 3's — `Real` is certified given the agreement, and `Real ⊆ Dmax` then follows from
  `dmax_maximal` — and it is Phase 12's obligation, never a union argument.
- **The parameter hypothesis, and the two requirements that make it more than cosmetic.**
  (i) SIGNATURE: the predicate reads `ParamsOk step pend lab φ Tc Tn P B` and is stated in
  `CounterQuotient.lean` beside `CK`/`kappa`, because (K1) quantifies the certificate graph's
  cycle lengths, (K2) the cascade bound and the semantic periodicity threshold, and (K4) the
  formula's backward exactness depth; only (K3)'s ordering is partly numeric. (ii)
  DISCHARGEABILITY: the four parameters are OUTPUTS of the periodicity fixpoint (`Pof`, `Tcof`,
  `Tnof`, `Bof`), so the predicate had to be proved AT those outputs — `paramsOk_params`. Without
  that lemma both repaired theorems would be safe but vacuous: a hypothesis no one can discharge
  is indistinguishable from an unproved statement for every downstream consumer. Both the
  predicate and its discharge are landed.
- **Why the refutation does not generalise past the repair (researched, not assumed).** The
  natural strengthening — pigeonhole, since `kappa` maps the infinite `ℕ × ℕ` into a finite `CK`,
  so some `c ≠ c'` collide at fixed `n` and the lemma then forces the cells equal — fails against
  the CONSTRAINED statement. On the probe's object the cell determines only the parity of `c`
  (`phiP_mem_iff_of_mem_cell` via `tagAt`), while `kappa`'s second coordinate is `c mod P`. (K1)
  makes `P` a common multiple of the certificate graph's cycle lengths on saturated classes, hence
  a multiple of that object's cycle length 2, so every `kappa`-collision is within a residue class
  mod `P` and preserves parity. `cell_succ_ne` compares only `c` and `c + 1`, which differ mod `P`
  under (K1). The hypothesis removes exactly the tuples the refutation needs.
- **The refutation probe stays wired, unchanged, as the compiled record of why the hypothesis
  exists.** A later reader who removes `hp` from either statement re-breaks both. No phase deletes,
  narrows or rewires it.
- **What is NOT refuted: the PRESENTATION.** The set-valued per-state datum, the fibre equation
  over the maximum certified subset, and the factorization lemma as a COROLLARY all stand. Route A
  stays closed. The refutation is of the statements' FREE quantification over the parameters, not
  of the design. It asserts no bound, names every quantity as a count, and makes no
  device-discrimination claim.
- **Statability.** The fix for the withdrawn statement line is not a substitute index but a
  different statement — the fibre equation over `Dmax`. `hitOf (truncate B …)` is withdrawn from
  the record (Phase 1); `truncate` is defined nowhere; `[Fintype Q]` is no longer reached through
  any clipping of the carrier, and the finiteness that `Dmax` needs is finiteness of
  `Q × ClType φ × CK`, which the module constructs, not of the ladder carrier (which stays
  infinite — `Rlad_slice_infinite`).
- **A per-cell object must carry a SET of types per ladder state, and the `box`/`stab` acceptance
  clause presupposes that store.** `Dmax` is exactly that set-valued datum, which is why a tuple
  index alone was reported as incomplete and never proposed. `certBoxK` is the global bit
  (`box_mem_tpOf_iff`) and `certStabK` is rebuilt per `(q, κ)` (`stab_mem_tpOf_iff` is per cell),
  both landed in Phase 9. The clause is never dropped from any statement.
- **Forward-only structural liveness stands, machine-checked and landed.** `gPast_isPath`,
  `gPast_pending_past`, `gPast_count` are the thirteenth wired probe's theorems: a ladder history
  can be pending at every past time, so `Count` discharges `ulive` forward and never `slive`
  backward. `LadderCons` replaces `ulive` only, and the backward half is retained — see the next
  bullet for the shape it is retained in, which is NOT `Realize.lean`'s `SLive`.
- **`Realize.lean`'s deferral-graph conditions do not transfer, and the landed `K`-indexed
  analogues are what replace them.** `UCoh`, `ULive`, `SCoh`, `SLive`, `deferGraph`,
  `bwdDeferGraph`, `Disch`, `DischBwd`, `persist` and `snce_iff_of_SCoh_SLive` are all indexed by
  `(clSig φ).preds` letters over a labelling `Q → (clSig φ).preds → Bool`, whereas `LadderCons`'s
  pinned signature carries `lab : Q → Atom → Bool` and keeps the closure component in `ClType φ`.
  So "retain `slive` as `Realize.lean`'s `SLive` over `Q`'s `step`" does not type-check, and is
  not what this plan asks for. The deferral graph over the PRODUCT carrier
  `Q × ClType φ × CK Tc Tn P B` under `relK` is already landed as Phase 9's `DischPathK`, with
  `certFwdK` and `certBwdK` its forward and backward instances and the letters read as formula
  membership in the `ClType` component. The retained backward half is `certBwdK`; no new
  translation layer is authored, and `Realize.lean` is not re-proved.
- **Finding 1 of the presentation decision (compiled): the certified chains of record are
  REGION-INTERIOR.** `coh`/`cohBi` require `pend` at BOTH endpoints, and no forward `Rlad` ray is
  pending forever (`exists_idle_of_rlad_ray`, `no_rlad_ray_of_pending_forever`), so no `Realizes`
  chain is the object projection of any `Rlad` history. The label-level sufficiency
  `realizes_of_certAdm_cohBi` is sufficiency for the interior of ONE region; it transfers to the
  region segments of a ladder history and never to the history itself. The relation this task
  states over is therefore the IDLE-EXTENDED `cohBi` (landed as `cohIdle`, the two `pend`
  conjuncts dropped, `RK` on the `CK` component, assembled as `relK`), and composition across idle
  runs is what (S) and (C') buy.
- **Finding 2: the shape of `CK` is forced, and it is a carrier coordinate.**
  `CK = (min c T_c, c mod P, min n T_n, n mod P, clip (n - c) [-B, B])`, each coordinate forced by
  a compiled mechanism. This is NOT the refuted tuple re-proposed: `CK` does not factor `cellAt` on
  its own (that is precisely the refuted claim), `Dmax` does; `CK`'s parameters are OUTPUTS of the
  counter-lift lemma, never inputs exhibited from the object or from the letters.
- **Finding 3: exactness, and Route A is not entered.** `Dmax` must be the ACTUAL realizable set:
  with `R ⊊ Real` the `stab` bits computed against `R` are wrong. `Real` is itself certified given
  constancy of `cellAt` on `CK`-classes — which is why the agreement comes first — and every
  certified set lies inside it, so the MAXIMUM certified set is `Real` and is computable by
  enumeration over `Finset (Q × ClType φ × CK …)`, a count of candidates and no bound of any kind.
  Nothing decides generalized-Büchi nonemptiness.
- **The gate table (820), carried as the licence and as the limit.** SEPARATION at gates 1, 2 and
  9's n-side half; COLLISION at both decision gates; `no_positionwise_lift` refutes the
  positionwise statement shape for EVERY finite `CK`; `short_idle_threshold_refuted` is why `T_c`
  must come from the cascade bound (`iter_doubling`) and not from the formula alone. A gate
  probing one coordinate certifies one coordinate: nothing in the table proves (S), (C') or the
  agreement.
- **The parameter sources (K1)-(K4), carried verbatim as Phase 9's discharged contract.** (K1)
  `P`: a common multiple of the cycle lengths of the certificate graph restricted to saturated
  classes (`prodPre_periodic` is the set-level form). (K2) `T_c`: at least the cascade bound — the
  largest region countdown a rigid (all-exact) past can force, exponential in the number of pinned
  regions by `iter_doubling` — and at least the semantic periodicity threshold. (K3) Ordering:
  `T_n ≥ T_c + 2ℓ₀ - 1` for `ℓ₀` the longest shortest path between saturated states, and
  `T_c ≥ 2 T_short + T_idle + 2`. (K4) `B`: at least `2 d_back + 1` for the formula's backward
  exactness depth, and at least `2` (gate 1). These four are the conjuncts of `ParamsOk`
  (`paramsOkK1`, `paramsOkK2`, `paramsOkK3`, `paramsOkK4`), landed.
- **What is NOT in question and is not re-proved:** the SET of cells of any regular ℤ-model is
  finite and bounded (`anchorCells_finite`, `anchorCells_ncard_le`). Both stay untouched.

### Two Plan-Criterion Corrections

Both were found unmeetable in execution and are carried into the criteria below.

- **The repository-wide vacuous-definition grep is a BASELINE-UNCHANGED criterion, never
  "count 0".** The canonical single-line grep
  (`grep -rn "^\s*\(noncomputable \)\?\(def\|theorem\|lemma\|instance\).*:= \(True\|Unit\|trivial\|Trivial\)\s*$"`,
  `lean-implementation-agent.md`'s Final Verification Stage) returns exactly ONE hit over
  `FormalSystem` and `Tests`: `FormalSystem/Examples/TemporalStructures.lean:495`, where
  `:= trivial` closes a real goal — membership in the universal domain is `True` by definition.
  That hit is simultaneously a FALSE POSITIVE for the pattern, so "count 0" is unmeetable twice
  over: the baseline is non-zero, and the pattern cannot distinguish proof debt from a correct
  one-line proof. Every criterion below therefore reads "unchanged from the dispatch's starting
  commit". A MODULE-SCOPED grep over a file this plan creates is a different and meetable
  criterion, and stays "count 0" where it appears.
- **`lean-challenge-snapshot.sh` is a plan-time obligation and never a task inside the plan.** The
  script admits only statuses up to `planned` (`PRE_IMPLEMENTATION_STATUSES="not_started
  researching researched planning planned"`) and refuses with exit 73 once the task has moved to
  `implementing`. The set of plan steps that can take a snapshot is therefore empty by
  construction. No phase below requests one. Signature fidelity is verified by direct `diff`
  against the `## Lean Challenge Statements` block instead, which is what the token-for-token
  criteria actually ask for; `--check` is named nowhere as a gate.

### Completed-Round Provenance

Phases 1-6 below are reproduced VERBATIM, `[COMPLETED]`, as the record of the round that landed
the thirteenth wired probe and corrected the records; Phases 7-9 likewise record the rounds that
landed `RunLayer.lean`'s pin-lemma lift half, `Certificate.lean` and `CounterQuotient.lean`. Their
internal cross-references to phase numbers are historical statements about those rounds and are
not instructions to this one.

### Roadmap Alignment

`specs/ROADMAP.md` names this task THE critical path, un-gated, over the idle-extended `cohBi` on
`Q × ClType φ × CK`, and 763 (the lift and the `Decidable (PlusValidZTime φ)` corollary) as waiting
on it alone. ROADMAP.md is NOT edited by this plan — the orchestrate conclusion regenerates it.
The task's GUARDRAILS (a)-(e) are carried into every phase's verification: (a) closure-indexed
letters over the time axis, `box`/`stab` bits included; (b) infinite width, no fibre bound; (c) no
upper bound — every quantity named is a count; (d) zero debt — no Büchi/MSO lemma cited in place
of a proof, no cslib require; (e) if the landed form is forward-only, say so, with no
device-discrimination claim.

## Goals & Non-Goals

**Goals**:
(The identifier set equals the six theorem declarations of the Lean Challenge Statements block
below. That block's `abbrev` definitions are context, not goals: they pin by position the objects
Phases 8-10 define. No other identifier is backticked in this block, because the snapshot tool
reads every backticked token here as a Goal.)
- `cellAt_const_of_kappa_eq` — the factorization lemma for the counter quotient, proved FIRST and directly at the history level: under the parameter conditions, cells agree on counter-class-equal states.
- `ladderSound` — obligation (S): every admissible ladder history projects to a member of the maximum certified subset at its own counter class, with its own closure type.
- `ladderCons_localRun` — every ladder run projects to a certificate chain inside a consistent bundle.
- `ladderLift` — obligation (C') in pumping form: every bi-infinite certificate chain through a class lifts to an admissible ladder history through any representative of that class, with the same closure type at the origin.
- `ladderRealized` — the fibre equation: under the parameter conditions, the cell at an admissible ladder state is exactly the fibre of the maximum certified subset at that state's class, for ALL φ, box and stab letters included.
- `paramsOk_params` — the parameter conditions (K1)-(K4) hold at the four parameters the periodicity fixpoint defines, so the hypothesis the two factorization-side statements carry is dischargeable and they are not vacuous. (Landed in Phase 9; carried in the block because it is a recorded Goal of this task.)

**Non-Goals**:
- No tuple index stated as a candidate at any parameters; `CK` stays a carrier coordinate. No
  seventh coordinate. No `truncate`, under any reading.
- The parameter hypothesis is NOT a predicate on four naturals, and is NOT to be weakened to one.
- The parameter hypothesis is NOT added to `ladderSound`, `ladderLift` or `ladderCons_localRun`.
  Those three keep the signatures recorded below token-for-token. If a phase finds one of them
  provable only under the hypothesis, the remedy is an auxiliary under an honest new name plus a
  `[BLOCKED]` raise on the filed statement — never a quiet edit of the filed signature.
- The agreement `cellAt_const_of_kappa_eq` is never a HYPOTHESIS of `ladderRealized`, and is never
  re-derived as a corollary of (S) and (C'). It is proved on its own ground in Phase 11.
- No depth-stratified certificate family is introduced: route (R-a) is not the chosen route, and
  `certChain` is not stratified by `⊡`-nesting depth.
- No `sorry`, axiom, vacuous definition, trace-level `Presented` hypothesis, finite-fibre or
  finite-width assumption, capped ladder, or weakened statement under a filed name
  (`plan-compliance.md`, Statement Fidelity). The `box`/`stab` acceptance clause is never dropped
  to make a structure writable.
- No soundness clause carried as a `LadderCons` hypothesis field: that would make
  `ladderCons_localRun`'s second conjunct near-vacuous under a filed name.
- `Realize.lean`'s `SLive`/`SCoh`/`deferGraph`/`bwdDeferGraph`/`Disch`/`persist` are NOT retained,
  ported or re-indexed; the landed `DischPathK`/`certFwdK`/`certBwdK` over the product carrier are
  what the ladder uses. `Realize.lean`, `Trace.lean` and `presented_modelOf` are not re-proved;
  `ladderFrame` (the instance-free frame beside `ladderFrameAdm`) is untouched.
- Route A (deciding generalized-Büchi nonemptiness) is NOT entered; the decision record is the
  presentation-decision report and its verdict stands.
- No complexity claim and no upper bound: the enumeration over `Finset (Q × ClType φ × CK …)` is a
  count of candidates, and `T_c`, `T_n`, `P`, `B` are counts.
- `anchorCells_finite` and `anchorCells_ncard_le` are not touched, re-proved, or strengthened.
- No edit to `specs/ROADMAP.md`, to 763's description, or to any archived predecessor's records.
- The refutation probe `ladder-unconstrained-parameter-refutation.lean` is not deleted, narrowed,
  unwired or re-proved; it stays as the compiled reason the hypothesis is there.
- Phase 9's landed layer (`CounterQuotient.lean`) is not re-planned, re-proved or reopened; its
  `#### Reasoned Exclusions` record stands.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `ladderSound`'s pinned signature carries no parameter hypothesis, but the only route to it this decomposition has runs through `certAdmK Real`, which consumes the agreement and therefore `hp` — so (S) may be provable only in a constrained form | H | H | Recorded up front rather than discovered mid-proof. Phase 12 lands `Real`'s certification UNDER `hp` (`real_certAdmK_of_paramsOk`). Phase 13 then (i) first probes whether the unconstrained `ladderSound` is REFUTABLE at the all-zero tuple on the refutation probe's own object — a landed separating pair is a complete, reportable outcome — and (ii) if it is not refutable, attempts the pinned statement. If neither closes, Phase 13 lands `ladderSound_of_paramsOk` under that honest auxiliary name, marks the pinned `ladderSound` `[BLOCKED]` with the goal state recorded, and raises the statement-defect: adding `hp` to a recorded Challenge statement is routed to the user by Statement Fidelity, never taken by an implementer |
| The cascade of the row above: `ladderCons_localRun` also carries no `hp` and consumes (S), so if (S) closes only under `hp`, Phase 14 closes `[BLOCKED]` too | H | M | Stated as Phase 14's own contingency so the cascade is expected, not rediscovered. Phase 16's `ladderRealized` DOES carry `hp` and can consume the constrained auxiliary, so the critical path to the fibre equation survives that outcome |
| Phase 11 (the agreement at the history level) does not close — it is the pumping counter-lift mathematics, and it is now the first hard phase rather than the third | H | M | Not costable, and declared so. `no_positionwise_lift` is COMPILED: the positionwise form is false for every finite `CK`, so narrowing to it is not a weaker statement but a wrong one. The contingency is `[BLOCKED]` with the goal state recorded. A refutation found in the attempt — a seventh observable the forced `CK` cannot see — is a COMPLETE outcome if landed as a compiled separating pair with non-vacuity witnessed on both sides |
| Phase 11's chain-replacement machinery is written so tightly around the agreement that Phase 15 cannot reuse it, and (C') re-derives it | H | M | Phase 11's task list requires the machinery to be stated as named, reusable lemmas independent of the agreement's own statement, and Phase 15's verification requires it to CITE them rather than re-prove them. Both phases name `LadderAgree.lean` as the machinery's home |
| An implementer re-introduces the cycle by proving the agreement from (S) and (C') after all | H | L | Phase 11's verification greps `LadderAgree.lean` for every certificate identifier (`certAdmK`, `certStabK`, `certBoxK`, `certBiInfK`, `certChain`, `Dmax`, `ClType`) and requires zero occurrences outside docstrings; the module's import list is the second check |
| Phase 12's `Dmax ⊆ Real` is attempted early, pulling the lift's content forward and re-closing a loop | H | M | The inclusion is explicitly NOT Phase 12's: Phase 12 proves `certAdmK Real` and `Real ⊆ Dmax` only. The reverse inclusion is Phase 15's corollary of `ladderLift` plus the landed `dmax_certBiInfK`, and Phase 12's verification asserts no theorem in it states `Dmax ⊆ Real` |
| Phase 15 ((C'), the pumping completeness) does not close, and an implementer weakens it to the positionwise form to make it provable | H | M | `no_positionwise_lift` is COMPILED; the Challenge block pins the pumping shape; the contingency is `[BLOCKED]` with the goal state recorded, never a narrowed statement |
| An implementer re-proposes one of the four candidate certified sets already ruled out | M | M | All four are recorded in Research Integration with the condition each fails. Phase 12 takes candidate (2) and only candidate (2), and its verification requires the `certStabK` discharge to cite the agreement |
| A later reader removes the parameter hypothesis as redundant, re-breaking both factorization-side statements | M | M | The refutation probe stays wired and its header carries the reason; Phase 16's verification asserts the hypothesis is present in both elaborated signatures and is consumed, not discharged by `trivial` |
| Scope: four new library modules (two landed, two new) plus the landed `RunLayer.lean` edit is more library surface than the filed FILE SCOPE anticipated, and `LadderAgree.lean` is a module the previous decomposition did not have | M | H | Deliberate and recorded: the module split is what makes the DAG checkable, because the agreement's certificate-freedom is a property of its module. `Files to modify` below is the harvest source and the postflight file-scope widening notice will fire — expected, not a defect |
| 763 shares the RaySummary library set and could collide | M | L | 761 and 763 serialize through the edge between them; 763 waits on 761 alone and is not dispatched concurrently |
| Cross-set collisions on the shared records: README and `check-module-invariants.sh` (744), `typst/generated/status.typ` (410) | M | M | All edits are appended rows or single-sentence amendments; collisions left to the admission gate — no edge is added |
| A record edit re-introduces the deleted index or states a cost figure | M | M | Guardrail (c); Phases 1 and 18 grep every touched record for `truncate`, `Fin (B+1)`, `min c B`, `clip (n`, and require each occurrence to sit inside a sentence naming it as deleted, refuted or research-level |
| A full `lake build` with two further new modules exceeds a foreground tool call | M | H | Route every build through `lake-build-guard.sh` with an explicit `--timeout`; detach as a shell-level background job and block with the bounded single-call idiom per `context/patterns/bounded-build-waiter.md` — never `Bash(run_in_background: true)` |
| `typst-status-counts.sh` (pre-commit) regenerates `status.typ` with a diff | L | H | Library declarations DO change here, so a diff is expected; commit it with the phase that caused it and record the fact in the summary |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4, 5 | 2 |
| 3 | 6 | 3, 4, 5 |
| 4 | 7, 8 | 1 |
| 5 | 9 | 8 |
| 6 | 10, 11 | 9 (10); 7, 9 (11) |
| 7 | 12 | 10, 11 |
| 8 | 13 | 12 |
| 9 | 14, 15 | 10, 13 (14); 7, 11, 12 (15) |
| 10 | 16 | 13, 15 |
| 11 | 17 | 16 |
| 12 | 18 | 6, 14, 17 |

Phases within the same wave can execute in parallel. Waves 1-5 are landed (Phases 1-9). Wave 6
onward is the open work. The two phases of wave 6 are genuinely independent — Phase 10 is the
certificate-side definitional layer, Phase 11 is the certificate-free history-level agreement —
and the two phases of wave 9 are independent for the same kind of reason: Phase 14 consumes (S)
and the bundle's definition, Phase 15 consumes the agreement's machinery and `Real`'s
certification. Phase 18 is the final phase: nothing depends on it, and it depends — directly or
transitively — on every other phase, which is what makes its `full` gate meaningful. Its edges to
Phases 6 and 14 are there for that reason: Phase 6 closed the records round that nothing later
consumes, and Phase 14 is the one open phase no proof phase reads, so without those two edges the
final gate would not observe them.

### Phase 1: Retire the Deleted Statement Line and Record the Discharge [COMPLETED]

**Goal**: Make the task's own records say what is now true — the three declarations are statable
in presentation (a)'s fibre form and every declared edge is discharged — so that no later phase
and no future dispatch reads a withdrawn statement line or a dead route as live.

**Tasks**:
- [x] Record the landed route in `specs/state.json`'s amended description (item 2 below), which is this round's durable carrier for it. `.blocker-research.json` is an orchestrator-mediated handoff file that the cycle planner CONSUMES when it builds an aux dispatch, so it is absent from the task directory by design and is not an artifact any phase corrects or looks for; the research it carried is held in this plan's Research Integration bullets and in the `## Prompt` block of `specs/761_ladder_realization_theorem/.dispatch/8-aux-plan-revision.md`.
- [x] Amend the task description in `specs/state.json` *(completed)* (via `update-task-status.sh` /
      `state-write.sh`, scoped by `select(.project_number == 761)`) so the STATEMENT paragraph
      names the fibre equation instead of `hitOf (truncate B …)`, and records that all six edges
      are discharged. Regenerate `specs/TODO.md` with `generate-todo.sh`; never hand-edit it.
- [x] Amend the design of record *(completed — the archived path is writable; one dated `**Amended by**` paragraph added to each of Sections A and C)*
      (`specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`, Sections
      A and C) with one paragraph each: the statement line is the fibre equation over `D`; the
      factorization lemma for `K` is its corollary. If the archived path is read-only by
      convention, record the amendment in `specs/761_ladder_realization_theorem/records/` instead
      and name that choice in the phase handoff.
- [x] Re-compile the `## Lean Challenge Statements` block below standalone through the build
      guard and confirm zero errors with every declaration body a `sorry` *(completed at the time
      — guard exit 0, exactly twelve `declaration uses `sorry`` warnings for that round's block,
      zero errors; the block as it now stands was re-compiled at this plan's authoring time: guard
      exit 0, zero errors, exactly eighteen `declaration uses `sorry`` warnings, twelve `abbrev`
      and six `theorem`)*.
- No snapshot task. `lean-challenge-snapshot.sh` admits only statuses up to `planned` and refuses
  with exit 73 at `implementing`, so a snapshot is a plan-time obligation discharged before the
  first implement dispatch, never a step inside the plan. Signature fidelity is checked by direct
  `diff` against the Challenge block. (Recorded in execution: the invocation `lean-challenge-snapshot.sh
  761 .` returned exit 73, "task 761's status is 'implementing' (past 'planned')", and the tool's
  own `--force` banner states that a Challenge produced after implementation has started
  "certifies nothing about what the implementation agent actually saw".)

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: Every change is a record edit plus one standalone Lean elaboration; the
covering check is the Challenge block's own compile plus `check-task-references.sh`, and no
library module is touched, so nothing dearer applies.

**Scope Hypothesis**: Three files change (`state.json`, `TODO.md`, and one design-of-record or
records file); `.blocker-research.json` is not among them, because it is an orchestrator-mediated
handoff file the cycle planner consumes rather than an artifact of this task's own directory.
If the Challenge block does not re-compile with zero errors and every body a `sorry`, that is a
plan deviation to raise before Phase 9 resumes, not a block to edit around.

**Files to modify**:
- `specs/state.json` - 761's description paragraph; `last_updated`
- `specs/TODO.md` - regenerated, never hand-edited
- `specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - one amendment paragraph in each of Sections A and C (or the records fallback named above)

**Verification**:
- `grep -rn 'truncate' specs/state.json` returns no occurrence outside a sentence naming it as withdrawn.
- The Challenge block compiles standalone: exit 0, zero errors, every declaration body a `sorry`.
- `bash .claude/scripts/check-task-references.sh` reports 0 unexempted occurrences outside `specs/`.
- `jq -S` equality of every `state.json` entry other than 761 against HEAD.

---
### Phase 2: Author the Wired Forward-Only Liveness Probe [COMPLETED]

**Goal**: Create `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` — the
mandated header followed by the prototype's declarations under `namespace Probe761` — compiling
under `lake env lean` with no `sorry`, no axiom, no vacuous definition, and the three Challenge
statements verbatim.

**Tasks**:
- [x] Write the header docstring (`/- … -/`, before the imports, modeled on
      `ladder-cell-refutation.lean`'s), containing in this order:
      - Title line: "Probe 761 (requirement (W)'s run layer, phase 2, the soundness half, over the
        two-state object): the ladder's structural liveness is FORWARD-ONLY — an admissible ladder
        history can be pending at every past time, so `Cons`'s backward liveness field `slive` is
        not replaceable by `Count`, and the realization theorem this probe accompanies is
        `[BLOCKED]` on the open index of which cell a ladder state has."
      - **What was asked**: the three filed declarations (`LadderCons` with the `box`/`stab`
        clause, `ladderCons_localRun`, `ladderRealized` with `hitOf (truncate B …)`), quoted as
        in Phase 1's Goal, on `ladderModel` over `ladderFrameAdm` (`LadderModel.lean`).
      - **Why no statement exists** (three paragraphs, each citing its landed anchor and proving
        nothing here): `truncate` is defined nowhere and its only reading is the index
        `Q × Fin (B+1) × Fin (B+1)` refuted by `ladder-cell-refutation.lean`; every per-cell
        soundness statement presupposes a finite index of ladder states — `cell_ne` (saturation
        fails on every `Q`-indexed candidate), the `Count true true` clause (the `Q`-projection
        of a seam fibre is a proper subset of the `Q`-runs, so `hitOf` over `Q`
        over-approximates `HitCl` even for `box`/`stab`-free `φ`), and the `stab` clause of
        `PlusTruth.lean` (a per-state labelling forces `ψ ↔ ⊡ψ`, the eighth probe's collapse
        with both hypotheses dropped); the `box`/`stab` acceptance clause presupposes the same
        index (`stab_mem_tpOf_iff` is per cell), so a `LadderCons` without it would be a
        same-named weaker statement and is not written.
      - **What this probe establishes (F4)**: the object (`stepB ≡ true`, `pendB = id`), the
        history `gPast B z := if z ≤ 0 then (true, (-z).toNat, B) else (false, 0, B)`, its
        admissibility `gPast_adm`, the path fact `gPast_isPath`, `gPast_pending_past`,
        `gPast_count`; the mechanism — backward, `Count true true` reads `c' + 1 = c`, so the
        countdown GROWS into the past without bound; a `snce`-letter claimed along `gPastA B` is
        never structurally discharged.
      - **Consequence for a successor bundle**: `ulive` is replaceable (forward: a pending state
        `(q, c, n)` at `z` is idle at `z + c + 1`; with a pend-field and `persist` this is
        `untl_iff_of_UCoh_ULive`'s shape); `slive` must stay as `Realize.lean`'s `SLive`
        deferral-graph condition over `Q`'s `step` (sound on ladder paths because `Rlad`'s first
        conjunct makes the `Q`-projection a `step`-chain). Name what transfers from
        `Realize.lean` (`UCoh`, `deferGraph`, `Disch`, `persist`, `SCoh`, `bwdDeferGraph`,
        `SLive`, `snce_iff_of_SCoh_SLive`) and what does not (`frameOf`/`modelOf` — WIDTH;
        `presented_modelOf` — trace level; `anchored_runTrace_of_boxStabFree`;
        `run_seam_state`/`isRun_of_chain_seam`), as description, not as a plan.
      - **What a true statement would need** (one paragraph, no claim): a finite index of ladder
        states per cell (the open sub-problem); a theorem parametric in an abstract index
        `idx : LadderState Q pend → I`, `[Fintype I]`, with a saturation hypothesis, is the
        unsatisfiable-hypothesis form unless some `idx` is exhibited for a `⊡`-bearing `φ` —
        research-level, not claimed. The two Hit-level positives (`hitCl_eq_truncated`,
        `hitCl_eq_truncated_node`) are fixture arguments (seam classification, constant-block
        run, a fixture subset fact) and supply no general truncation lemma: on the ladder the
        seam fibre at a fixed `(q₀, c₀, n₀)` is infinite for any object with a pending cycle.
      - **What this probe does NOT say** (guardrails (a)-(e)): (a) cells are closure-indexed
        SETS over the time axis, `box`/`stab` bits included, never one bit per depth; (b) the
        slice `LadderState Q pend` is infinite (`Rlad_slice_infinite` one level down) and no
        fibre bound is assumed or claimed; (c) no upper bound of any kind, no complexity bound —
        `B` is a count; (d) zero debt — no external lemma, no cslib require, nothing cited in
        place of a proof; (e) the landed form is forward-only in the precise sense that the
        FORWARD liveness is structural and the BACKWARD one is not — the witness is a past-pending
        history of the ladder, not a claim about `⊡(Pp)` or about any backward fixture (nothing
        beyond `Probe719Backward.pastStab_iff_allBwdPathsMeet` is claimed there); no
        device-discrimination claim. Also: nothing about `HitPresented` or `PlusValidZTime`;
        `anchorCells_finite` and `anchorCells_ncard_le` untouched (the SET of cells stays finite
        and bounded); `presented_modelOf` untouched; no `LadderRealize.lean` exists and none is
        created by this probe; the index-free run-layer half is a design option not taken here.
      - Axiom foot sentence ("`gPast_isPath` carries `[propext, Classical.choice, Quot.sound]`;
        `gPast_pending_past` and `gPast_count` carry `[propext, Quot.sound]`") and the compile
        line `lake env lean specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`.
- [x] Import and opens exactly as the prototype: `RaySummary.LadderModel`; `open
      FormalSystem.Syntax FormalSystem.Semantics` and `open
      FormalSystem.Metalogic.Decidability.RaySummary`; `namespace Probe761`.
- [x] Port the prototype's declarations in order, keeping names, statements and docstrings:
      `stepB`, `pendB`, `gPast`, `gPast_adm`, `gPastA`, `gPast_isPath`, `gPast_pending_past`,
      `gPast_count`. Identifiers are already ASCII; no renames. Nothing else changes.
- [x] Close with `end Probe761` and `#print axioms` for `Probe761.gPast_isPath`,
      `Probe761.gPast_pending_past`, `Probe761.gPast_count`.
- [x] Compile through the guard:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`.
- [x] `git add` the new file (the gate's "tracked, not merely present" rule — Phase 3 fails
      otherwise) and commit per the green-substep mandate.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The probe is ~140-180 lines (prototype 47 lines by `wc -l`, re-derived at
plan time, plus a 95-130 line probe header). Confirm with `wc -l` on the written file; a figure
outside 120-220 is a signal to re-check that a header paragraph was not dropped or a declaration
duplicated, not a defect in itself.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`
(through the build guard) exiting 0 is the complete covering check — the file sits outside the
Lake build graph, nothing imports it, and it modifies no library module, so no other compilation
unit can be affected.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` - new probe file (header + ported proofs)

**Verification**:
- The guarded `lake env lean` exits 0 with zero `error` lines and zero `warning` lines; the three
  `#print axioms` lines read `[propext, Classical.choice, Quot.sound]` for `gPast_isPath` and
  `[propext, Quot.sound]` for `gPast_pending_past` and `gPast_count`.
- `grep -nE "sorry|^axiom |:= (True|Unit|trivial|Trivial)\s*$" specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`
  prints nothing.
- The three Goal declarations appear with exactly the signatures in `## Lean Challenge
  Statements` (docstrings may precede them), checked by direct `diff` of the extracted signature
  text against that block.
- Header read-through confirms every item in the first task's checklist is present, including
  the three "why no statement exists" paragraphs, the "`ulive` replaceable, `slive` retained"
  sentence, the forward-only sentence in guardrail (e)'s precise sense, the no-bound sentence,
  and "no `LadderRealize.lean` exists and none is created".
- `grep -c "truncate" specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`
  counts only occurrences inside the header's "defined nowhere" sentences (none in code).
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` exits 0.

---

### Phase 3: Wire the Probe into the Evidence Gate [COMPLETED]

**Goal**: Register the probe in `scripts/check-evidence-probes.sh` so the gate compiles it on
every run, with a table row recording what it holds in place.

**Tasks**:
- [x] Add a table row in the `# --- WIRED ---` comment table, directly after the
      `seam-gluing-ray-product/ladder-cell-refutation` row (the row block ends at the line before
      `WIRED=(`), in the same two-column `# probe | decision` wrapped format, headed
      `FORWARD-ONLY LIVENESS (requirement (W)'s run layer, "(W): what landed and what did not",
      obligation (ii) item 1, the soundness half, over the two-state object)` and stating: the
      realization theorem (`LadderCons` with its `box`/`stab` clause, `ladderCons_localRun`,
      `ladderRealized`) is `[BLOCKED]` on the open index of which cell a ladder state has —
      every per-cell soundness statement presupposes it (`cell_ne`; the `Count` clause makes the
      `Q`-projection of a seam fibre a proper subset of the `Q`-runs; a per-state labelling
      collapses `ψ ↔ ⊡ψ`) and so does the acceptance clause (`stab_mem_tpOf_iff` is per cell);
      what IS settled, machine-checked: an admissible ladder history can be pending at every past
      time (`gPast_isPath`, `gPast_pending_past`, `gPast_count` — backward, `Count true true`
      grows the countdown without bound), so `Cons`'s `ulive` is replaceable by structural
      liveness and `slive` is NOT. What it does NOT say (forward-only in the sense that the
      forward liveness is structural and the backward one is not — not a claim about `⊡(Pp)`;
      no bound of any kind; no finiteness; nothing about `HitPresented` or `PlusValidZTime`; no
      library module created; the successor design — an index, or the index-free run-layer half
      — not chosen; `anchorCells_ncard_le` untouched). Axioms `[propext, Classical.choice,
      Quot.sound]` (`gPast_pending_past`, `gPast_count` `[propext, Quot.sound]`). No task number
      anywhere in the row — durable anchors only.
- [x] Append `"seam-gluing-ray-product/ladder-liveness-forward-only"` to the `WIRED=(` array
      immediately after `"seam-gluing-ray-product/ladder-cell-refutation"`.
- [x] `bash -n scripts/check-evidence-probes.sh` (syntax) and then run the gate detached with a
      bounded waiter (`context/patterns/bounded-build-waiter.md`).
- [x] Commit the script edit.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: At plan time `WIRED` has 29 entries and `WIRED_REPO` 1 (counted with
`awk '/^WIRED=\(/,/^\)/' … | grep -c '^  "'`), so the gate's PASS line should read
`PASS  all 31 wired probe(s) compile` after the edit. Confirm by re-counting both arrays before
and after the edit (exactly +1 on `WIRED`) and matching the PASS line's number to the sum.

**Tier Justification**: `bash -n scripts/check-evidence-probes.sh` plus a full
`bash scripts/check-evidence-probes.sh` run exiting 0 is the complete covering check — the edit is
one comment block and one array element, the script has no other consumer that parses `WIRED`,
and `scripts/check-evidence-probes.sh` is self-excluded from `check-module-invariants.sh`'s C9.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - one WIRED table row and one `WIRED=(` array entry

**Verification**:
- `bash -n scripts/check-evidence-probes.sh` exits 0.
- `bash scripts/check-evidence-probes.sh` exits 0; its output contains
  `seam-gluing-ray-product/ladder-liveness-forward-only … PASS` and the final line
  `PASS  all 31 wired probe(s) compile` (the count per the Scope Hypothesis).
- `bash .claude/scripts/check-task-references.sh --quiet scripts/check-evidence-probes.sh` exits 0.
- `git diff --staged --stat` shows only `scripts/check-evidence-probes.sh` for this phase's commit.

---

### Phase 4: Record the Obstruction in the README and the Theorem Index [COMPLETED]

**Goal**: Add the thirteenth-probe paragraph to the README's Evidence section, amend the three
README sentences that now misdescribe the soundness half, amend one `docs/theorem-index.md` row,
and state the per-state-labelling collapse as a principle so no successor re-derives it.

**Tasks**:
- [x] In `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `## Evidence`, insert ONE
      paragraph directly after the "A twelfth wired probe, …" paragraph (which ends "…and the
      successor design is not chosen here.") and before "The permanent computability witnesses
      are …", of the shape: "A thirteenth wired probe,
      `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`, accompanies the
      run layer's phase-2 soundness half — the realization theorem per ladder cell — which is
      `[BLOCKED]` on the open index of which cell a ladder state has: every per-cell soundness
      statement for `ladderModel` presupposes a finite index of ladder states (the twelfth
      probe's `cell_ne` defeats the saturation of every `Q`-indexed candidate; `Count`'s pending
      clause makes the `Q`-projection of a seam fibre a proper subset of the `Q`-runs, so a
      presentation over `Q` over-approximates `HitCl` even for `box`/`stab`-free `φ`; and a
      labelling that reads closure truth off the world state alone forces `ψ ↔ ⊡ψ` by the `stab`
      clause, the eighth probe's collapse with both of its hypotheses dropped), and the
      `box`/`stab` acceptance clause presupposes that same index (`stab_mem_tpOf_iff` is per
      cell). What the probe settles, machine-checked on the two-state object: an admissible
      ladder history can be pending at every past time (`gPast_isPath`, `gPast_pending_past`,
      `gPast_count` — backward, `Count true true` grows the countdown without bound), so the
      ladder's structural liveness is forward-only: a ladder consistency bundle may replace
      `Cons`'s `ulive` by it and must keep `slive`. `gPast_isPath` at `[propext,
      Classical.choice, Quot.sound]`, the other two at `[propext, Quot.sound]`, citing
      `LadderModel.lean` and re-proving nothing — no bound of any kind, no finiteness, nothing
      about `HitPresented` or `PlusValidZTime`, no library module, `anchorCells_finite` and
      `anchorCells_ncard_le` untouched, the successor design not chosen here." Durable anchors
      only: no task number, no `specs/761_…` path, no record-versioning language.
- [x] Same README, "(W): what landed and what did not", item 1 of "Open: obligation (ii)":
      after the sentence ending "…while the SET of cells stays finite and bounded
      (`anchorCells_finite`, `anchorCells_ncard_le`).", insert: "That sub-problem is the
      hypothesis of the realization theorem itself, not a side question: any per-cell object
      must carry a SET of types per ladder state (saturation, HWZ Def. 12), and a finite object
      can do so only through a finite index of those states; a per-state labelling instead forces
      `ψ ↔ ⊡ψ` by the `stab` clause alone, with no `Presented` or `nowUnique` hypothesis — the
      eighth probe's collapse is the clause's own. The `box`/`stab` acceptance clause presupposes
      the index too (`stab_mem_tpOf_iff` is per cell), so no `LadderCons` is stated. What is
      settled: the ladder's structural liveness is forward-only (thirteenth wired probe,
      `gPast_isPath`), so such a bundle replaces `ulive` and keeps `slive`." Keep the rest of the
      item (the `Presented` prohibition) unchanged.
- [x] Same README, the sentence ending "…the run-layer consistency conditions that would play
      `Cons`'s role for the ladder are likewise named and not built." — amend minimally to add:
      "; whatever form they take replaces `ulive` only (a pending region at `(q, c, n)` ends at
      `z + c + 1`, by `Count`) and keeps `slive`, because an admissible ladder history can be
      pending at every past time (thirteenth wired probe, `gPast_isPath`)."
- [x] Same README, `## The verdict` table, row (W), the parenthesis "(soundness: the stabilization
      lemma in the pair of ladder counters is refuted by the twelfth wired probe
      `ladder-cell-refutation.lean`, and phase 2 is `[BLOCKED]` on the successor design;
      completeness: (C)'s general row, open)": amend to "(soundness: the stabilization lemma in
      the pair of ladder counters is refuted by the twelfth wired probe
      `ladder-cell-refutation.lean`, the realization theorem is `[BLOCKED]` on the open index of
      which cell a ladder state has, and the ladder's structural liveness is forward-only —
      thirteenth wired probe `ladder-liveness-forward-only.lean`; completeness: (C)'s general row,
      open)".
- [x] `docs/theorem-index.md`, the `ladderModel` row only: inside its "**What it is not**"
      clause, after "…which consumes these declarations)", add "; the realization theorem itself
      is `[BLOCKED]` on the open index of which cell a ladder state has, and the ladder's
      structural liveness is forward-only — an admissible history pending at every past time,
      wired probe `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`".
      Do not touch the row's Declaration, File, Frame class, or `pinned:C14` cells, nor the other
      four ladder rows.
- [x] Update the README's trailing `*Last verified: YYYY-MM-DD*` line to the implementation
      date.
- [x] Commit the README and theorem-index edits per the green-substep mandate.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly one new README paragraph, three amended README sentences, the
`Last verified` line, and one amended theorem-index clause; confirm with `git diff --stat`
showing only `FormalSystem/Metalogic/Decidability/RaySummary/README.md` and
`docs/theorem-index.md` and a README hunk count of 5. `grep -c 'thirteenth wired probe'` on the
README should read 3 after the edit (plan-time baseline 0; re-count before editing).

**Tier Justification**: Every changed hunk is markdown prose with no compile surface, and the
covering checks are the repository's own lints read by exit status —
`bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary`,
`bash scripts/check-module-invariants.sh` (C9 task-reference scan and C15 theorem-index anchors),
and `bash .claude/scripts/check-task-references.sh --quiet` — plus the diff read-through the
`prose` row prescribes (`suite_selection_select` returns `__FULL_SWEEP__` for these paths, so no
shell suite is claimed as coverage).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - Evidence paragraph (new); item 1 of "(W): what landed and what did not"; the "named and not built" sentence; the verdict-table (W) row parenthesis; `Last verified` date
- `docs/theorem-index.md` - the `ladderModel` row's "What it is not" clause

**Verification**:
- `bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` exits 0.
- `bash scripts/check-module-invariants.sh` exits 0 (C9: zero task-number or `specs/NNN_`
  citations under `FormalSystem/`, `docs/`, `scripts/`; C15 theorem-index anchors intact; C14
  pins unchanged); run detached with a bounded waiter.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- `grep -nE "no longer|previously|formerly|used to" ` over the diff hunks of both files prints
  nothing (no record-versioning language).
- `git diff -U0 -- docs/theorem-index.md` shows exactly one hunk, inside the `ladderModel` row,
  and `grep -c 'pinned:C14' docs/theorem-index.md` is unchanged from baseline.
- `grep -nE "truncate|Fin \(B\+1\)|min c B|clip \(n" FormalSystem/Metalogic/Decidability/RaySummary/README.md docs/theorem-index.md`
  shows no NEW occurrence outside a sentence naming the device as refuted or research-level.

---

### Phase 5: Amend the Design of Record and the Task's Own Description [COMPLETED]

**Goal**: Remove the two residues of the deleted index from the records this task is stated on —
`hitOf (truncate B …)` and "`ulive`/`slive` replaced" — by dated amendment paragraphs in
`followup-scope-spec.md` (Sections A, C, D, H4, H6), in `successor-records.json` (T4), and in
this task's `state.json` description, so that a future `/revise` or `/spawn` reads the block and
its reasons rather than an inconsistent statement.

**Tasks**:
- [x] Draft the amendment paragraph once, in
      `specs/761_ladder_realization_theorem/records/761-amendment.txt`, of the shape: "AMENDED
      2026-10-12 (realization blocked): the realization theorem is [BLOCKED] on the open index
      sub-problem — `hitOf (truncate B …)` is a residue of the deleted index (`truncate` is
      defined nowhere; its only reading is `Q × Fin (B+1) × Fin (B+1)`) and is withdrawn from the
      statement line; every per-cell soundness statement presupposes a finite index of ladder
      states (`cell_ne`; the `Count` clause; the `stab` clause's collapse of any per-state
      labelling), and the `box`/`stab` acceptance clause presupposes it too; the ladder's
      structural liveness is FORWARD-ONLY (wired probe
      `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`: `gPast_isPath`),
      so a ladder bundle replaces `ulive` only and keeps `slive` — `ulive`/`slive` replaced`
      reads `ulive` replaced, `slive` retained. No library module; the index-free run-layer half
      is a user option (R2) not taken. See
      specs/761_ladder_realization_theorem/plans/01_ladder-realization-blocked-probe.md." (Task
      numbers and `specs/**` paths are permitted here: every target is under `specs/**`.)
- [x] `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md`:
      - Section A: after the existing "**Amendment (2026-10-11).**" paragraph, add
        "**Amendment (2026-10-12).**" carrying the paragraph above, and note that the
        "*Consistency conditions and `Adm`.*" paragraph's "`ulive`/`slive` replaced" reads
        "`ulive` replaced, `slive` retained".
      - Section C: after the "**Scope decision.**" bullets, add an "**Amendment (2026-10-12).**"
        paragraph: the `box`/`stab` acceptance clause cannot be formulated without the index, so
        obligation (3)'s first half stays assigned to (W) and is `[BLOCKED]` with it; Decision D1
        (no standalone (S) record) stands.
      - Section D: after the existing "**Amendment (2026-10-11).**" paragraph, add
        "**Amendment (2026-10-12).**": the (←) soundness half inherits the block on H4; H6 is
        `[BLOCKED]` on H4 by its own honest-outcome clause; `objBound φ` remains a count whose
        shape is open.
      - Section H4: prepend the amendment line to the quoted description block (a second `>
        AMENDED …` line above the existing one), and leave the "**Costability**" line unchanged.
      - Section H6: prepend "> AMENDED 2026-10-12 (realization blocked): T4 is [BLOCKED] on the
        open index sub-problem; this record's (←) half inherits that block — see
        specs/761_ladder_realization_theorem/plans/01_ladder-realization-blocked-probe.md."
- [x] `specs/757_lplus_decidability_successor_task_set/successor-records.json`: prepend the same
      amendment paragraph (plus a blank line) to T4's `description`, as a text-level edit of the
      current file touching only that one field (the twelfth probe's plan recorded that `jq`
      re-serialization re-flows untouched records; follow its precedent); `jq empty` the result.
- [x] `specs/state.json`, this task's description, via the sanctioned writer only (never `!=`,
      per the jq escaping hazard):
      `bash .claude/scripts/state-write.sh '(.active_projects[] | select(.project_number == 761)) |= (.description = ($d + "\n\n" + .description) | .last_updated = $ts)' --session-id "$SESSION_ID" --arg d "$(cat specs/761_ladder_realization_theorem/records/761-amendment.txt)" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --regen-todo`;
      on exit 2 (mutex) retry up to 3 times, 30 s apart.
- [x] Verify nothing else moved: `diff <(git show HEAD:specs/state.json | jq -S 'del(.active_projects[] | select(.project_number == 761))') <(jq -S 'del(.active_projects[] | select(.project_number == 761))' specs/state.json)` is empty.
- [x] Verify the content: `jq -r '.active_projects[] | select(.project_number == 761) | .description' specs/state.json | grep -c 'AMENDED 2026-10-12 (realization blocked)'` is 1 and `| grep -c 'slive. retained'` is 1; `diff <(jq -r '.records[] | select(.label == "T4") | .description' specs/757_lplus_decidability_successor_task_set/successor-records.json) <(jq -r '.active_projects[] | select(.project_number == 761) | .description' specs/state.json)` is empty; `jq empty` on both JSON files exits 0.
- [x] Commit the spec, the records file, `state.json` and the regenerated `TODO.md` as one
      batch.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: atomic-batch (the `state-write.sh` call and the regenerated `TODO.md` are one
pre-declared batch with the two record files: a commit between them would record `TODO.md` ahead
of `state.json`)

**Scope Hypothesis**: Exactly one `active_projects` entry changes (761; `description` and
`last_updated` only) and every other entry is byte-identical to HEAD (confirm with the `jq -S
del(...)` diff above); the spec gains five amendment insertions (A, C, D, H4, H6) and no other
hunk (`git diff -U0 -- specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md`
hunk count 5); `successor-records.json` differs from HEAD in T4's `description` only.

**Tier Justification**: The covering check is `jq empty` on both JSON files, the HEAD-vs-worktree
`jq -S` equality of every `state.json` entry other than 761, and the phrase greps above, each
read by exit status; this is a `specs/**`-only edit that no shell suite maps to
(`__FULL_SWEEP__`) and for which `verify-deploy.sh --only-gate 3,4` attests nothing in a
deploy-consumer tree, so neither is claimed as coverage.

**Files to modify**:
- `specs/761_ladder_realization_theorem/records/761-amendment.txt` - the amendment paragraph (new)
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - amendment paragraphs in Sections A, C, D; amendment lines in H4 and H6
- `specs/757_lplus_decidability_successor_task_set/successor-records.json` - T4 `description` only
- `specs/state.json` - 761 `description` and `last_updated`, via `state-write.sh` only
- `specs/TODO.md` - regenerated by `generate-todo.sh` through `--regen-todo`; never hand-edited

**Verification**:
- `state-write.sh` exits 0; `jq empty specs/state.json` and `jq empty specs/757_lplus_decidability_successor_task_set/successor-records.json` exit 0.
- The `jq -S del(...)` HEAD-vs-worktree diff is empty.
- The three content greps and the T4-vs-761 `diff` above pass.
- `grep -c 'AMENDED 2026-10-12' specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` is at least 2 (H4, H6) and `grep -c 'Amendment (2026-10-12)'` is 3 (A, C, D).
- `git diff --stat` for this phase names exactly the five files above.

---

### Phase 6: Run the Full Gate, Write the Summary, Return Blocked [COMPLETED]

**Goal**: Run the complete repository gate set over the landed probe and the amended records,
write the implementation summary, and return with Phase 1 still `[BLOCKED]`.

**Tasks**:
- [x] Re-run the guarded `lake env lean` on the probe after all commits.
- [x] Run the final gate set (below), detached where the pattern requires, and record each exit
      status in the summary. If the pre-commit hook regenerates `typst/generated/status.typ`,
      commit it with this phase and say so in the summary.
- [x] Write the implementation summary per `summary-format.md`
      (`specs/761_ladder_realization_theorem/summaries/01_ladder-realization-blocked-probe-summary.md`),
      naming Phase 1's obstruction, the forward-only verdict, the user's R1 ruling, and the two
      successor options (R2 via `/revise`; a research-first index record via `/spawn`).
- [x] Return per the Lean agent's Escalation Protocol, because Phase 1 is `[BLOCKED]`: leave the
      plan-level `- **Status**:` field to the postflight (`update-plan-status.sh` via
      `update-task-status.sh`; do NOT hand-edit it); write `.return-meta.json` with
      `status: "partial"`, `requires_user_review: true`, `blocked_phase: 1`, and a
      `review_reason` naming the open index sub-problem and the R2/R3 choice; write the handoff
      with `status: "partial"`, `phases_completed: 5`, `phases_total: 6`, and one `blockers[]`
      entry for Phase 1 carrying the three verbatim goal lines from Phase 1's Goal, with
      `why_it_failed` stating that the statements are unformulable without the open index (not a
      failed proof) and that the remaining choice is the user's. NEVER return `implemented`.

**Timing**: 1.25 hours

**Depends on**: 3, 4, 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `specs/761_ladder_realization_theorem/summaries/01_ladder-realization-blocked-probe-summary.md` - the implementation summary (new)
- `typst/generated/status.typ` - only if regenerated by the pre-commit hook (no diff expected)

**Verification** (the complete gate set — every command's exit status is checked, never only its
output):
- `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`
  exits 0 (three `#print axioms` lines as in Phase 2).
- `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 31 wired probe(s) compile`.
- `bash scripts/check-module-invariants.sh` exits 0 (C9 in particular: zero task-number or
  `specs/NNN_` citations under `FormalSystem/`, `docs/` and `scripts/`; C14 pins unchanged; C15
  theorem-index anchors intact); run detached with a bounded waiter.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- `bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` exits 0.
- `bash scripts/typst-sync-check.sh` exits 0 (or its documented Check-2 regeneration is applied
  and committed).
- Full `lake build` via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
  detached per `context/project/lean4/operations/long-builds.md`, exits 0 — expected a no-op
  success, since no library `.lean` file changes, but mandatory before the return.
- Lean agent Final Verification Stage over the resolved source roots AND the probe file:
  `lean-sorry-census.sh` count 0; the repository-wide vacuous-definition grep UNCHANGED from the
  dispatch's starting commit; `grep -rn "^axiom "` count unchanged from baseline.
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- `git status --short` shows no stray modified files outside this plan's `Files to modify` set.
- The plan file's Phase 1 heading still reads `[BLOCKED]`; the return status is `partial`, not
  `implemented`.

---

### Phase 7: Promote the Pin Lemma's Lift Half into `RunLayer.lean` [COMPLETED]

**Goal**: Make the counter half of the lift available to the library. The gate-table probe proved
`drift_extension_of_pins` and `exists_rlad_hist_of_walk` generically in `Q`, `step`, `pend`, and
its own record names moving them into `RunLayer.lean` as the successor's choice; a library module
cannot import a probe, so the port happens here.

**Tasks**:
- [x] Port `pinCands`, `mem_pinCands`, `walkPin`, `drift_extension_of_pins` and
      `exists_rlad_hist_of_walk` from `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
      into `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean`, verbatim in statement,
      under the module's existing namespace. Port the proofs; do not re-derive them.
      *(deviation: altered — NINE declarations moved, not five. `exists_rlad_hist_of_walk`'s proof
      consumes `count_tt`/`count_tf`/`count_ft`/`count_ff`, probe-local `Count` letter-pair
      unfoldings the library did not carry, so they were ported too under this phase's own Scope
      Hypothesis licence ("port that lemma too and name it in the handoff rather than weakening
      the statement"). Two tactic-level adaptations were forced by library linters the probe is not
      subject to, neither touching a statement or a proof step: the two `show` steps inside
      `drift_extension_of_pins` are written `change` (`linter.style.show` demands `change` when the
      tactic alters the goal), and one ported comment line was rewrapped under the 100-column
      limit. All nine elaborated signatures diff IDENTICAL against the probe's.)*
- [x] Keep the probe's copies in place and unchanged *(completed — `check-evidence-probes.sh` exits 0, all 43 wired probes PASS at that point)* — the evidence gate compiles them and the
      probe is the oracle. Add a one-line comment at the library site naming the probe file as
      the origin.
- [x] Add nothing else to `RunLayer.lean` *(completed — `Count`, `Drift`, `Rlad` and the existing lemmas are untouched; the insert sits between `Rlad_slice_infinite` and the ladder-frame section)*: `Count`, `Drift`, `Rlad` and their existing lemmas are
      untouched.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: The port changes a module every downstream RaySummary module imports, so
the covering check is a guarded scoped build of the dependent modules rather than a local
elaboration of `RunLayer.lean` alone.

**Scope Hypothesis**: Five declarations move; `RunLayer.lean` is the only library file touched in
this phase. If a ported proof needs a lemma the probe had locally and the library does not, port
that lemma too and name it in the handoff rather than weakening the statement. *(Landed: nine
declarations, per the recorded deviation above — the licence this line grants is what was used.)*

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` - the pin lemma's lift half, nine declarations

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.RunLayer` exits 0 with 0 warnings.
- The two headline signatures match the probe's token-for-token (`diff` of the extracted signature text).
- `lean-sorry-census.sh` count 0 over the resolved source roots; the repository-wide
  vacuous-definition grep unchanged from baseline; `grep -rn '^axiom '` unchanged from baseline.
- `bash scripts/check-evidence-probes.sh` still exits 0 (the probe's own copies still compile).

---

### Phase 8: Promote the Certificate Layer into the Library [COMPLETED]

**Goal**: Create `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean` carrying the
`K`-free part of the certificate layer, so that the ladder module has a library-side object to
state over. Everything promoted here exists as a compiled probe declaration; this is a port.

**Tasks**:
- [x] Port `ClType φ` (the closure-type carrier), `locCoh`, `untlLink`, `snceLink`, `coh` and
      `cohBi` from `realizable-type-certificate.lean` and
      `certificate-sufficiency-dovetailing.lean`, keeping statements verbatim and recording every
      rename forced by a namespace collision in the module header. *(completed — ZERO renames
      were forced; the module header records that, and names the two same-spelled declarations
      elsewhere in the library whose different full names make them non-collisions.)*
- [x] Define the IDLE-EXTENDED relation as its own definition beside `cohBi` — `coh`'s two `pend`
      conjuncts dropped — with a docstring citing `exists_idle_of_rlad_ray` /
      `no_rlad_ray_of_pending_forever` for why the all-pending relation cannot be the ladder's:
      the certified chains of record are region-interior. *(completed as `cohIdle`, with
      `cohIdle_eq_cohBi_of_pend` and `cohIdle_of_cohBi` pinning the comparison. Note: dropping
      both `pend` conjuncts removes the relation's dependence on the pending bit entirely, so
      `cohIdle` takes no `pend` parameter — carrying one would be an unused binder, which the
      library's `linter.unusedVariables` rejects and which would misrepresent the relation.)*
- [x] Port the `K`-free certificate predicates `certLoc`, `certBiInf`, `certFwd`, `certBwd`,
      `certBox`, `certStab` and `certAdm` at the `K`-free carrier `ProdState Q φ`, together with
      the existential-fulfilment fixpoint (`euLfp`) and its discharge lemma, `Realizes`, the
      dovetailing theorem `exists_dovetail_chain`, and the label-level sufficiency
      `realizes_of_certAdm_cohBi`. *(Landed design: `certStab` and `certAdm` ARE part of this
      layer, at the `K`-free carrier, because `realizes_of_certAdm_cohBi` — which this task list
      requires — is stated in terms of `certAdm` and its proof destructures `certAdm_iff`'s six
      fields including the `stab` one; the theorem cannot be promoted without both. The
      `K`-indexed versions of the same two conditions live over the different carrier
      `Q × ClType φ × K` and carry the distinct names `certStabK` and `certAdmK`, defined in
      Phase 9. No Challenge-block theorem signature is affected: `certAdm` appears in none of the
      six.)*
- [x] Record in the module header, in one paragraph, the REGION-INTERIOR reading *(completed — the paragraph names both compiled theorems and states that no ladder consequence is drawn here)*: this layer is
      sufficiency for the interior of one region, it transfers to the region segments of a ladder
      history, and it never applies to the history itself. Do not state a ladder consequence here.
- [x] Wire the module: add the import to `FormalSystem/Metalogic/Decidability/RaySummary.lean`,
      to `FormalSystem.lean`, and the C14 heredoc entry in `scripts/check-module-invariants.sh`.
      *(completed — two C14 baseline/`#print axioms` pairs added (`realizes_of_certAdm_cohBi`,
      `exists_dovetail_chain`), plus three wiring steps the plan did not anticipate and the
      invariant gate demanded: a `RaySummary.lean` module-list docstring entry, a
      `scripts/nolints.json` `unusedArguments` exemption for `coh_iff`'s verbatim-ported unused
      instance binders, and a regeneration of the four generated inventory blocks via
      `check-module-invariants.sh --emit-inventory`.)*

**Timing**: 3 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: A new module enters the library's import graph and the invariant script's
C14 list, so the covering check is a guarded scoped build plus `check-module-invariants.sh`, not a
local elaboration.

**Scope Hypothesis**: One new module plus three wiring files, carrying the `K`-free layer at the
carrier `ProdState Q φ`. *(Landed: 1451 lines; a machine diff of every promoted declaration
against its probe source shows 22 hunks, all of them recorded adaptations, and ZERO statement
changes. Five wiring files, not three — `scripts/nolints.json` and the generated inventory blocks
were demanded by the invariant gate.)*

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean` - new module, the K-free certificate layer
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import, one module-list docstring entry
- `FormalSystem.lean` - one import
- `scripts/check-module-invariants.sh` - two C14 heredoc entries, regenerated inventory blocks
- `scripts/nolints.json` - one `unusedArguments` exemption for `coh_iff`'s ported instance binders

**Verification**:
- Guarded scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.Certificate` exits 0, 0 warnings.
- Each promoted definition diffs clean against its probe source modulo the recorded adaptations.
- `bash scripts/check-module-invariants.sh` exits 0; `bash .claude/scripts/verify-deploy.sh` exits 0.
- The header's region-interior paragraph names both compiled theorems by name.
- No `sorry`, no `axiom`, no vacuous-definition pattern in the new module (module-scoped grep count 0).

---

### Phase 9: The Counter Quotient `K`, Its Parameters, the Parameter Conditions, and the Maximum Certified Subset [COMPLETED WITH EXCLUSIONS]

**Refutation of record (why the parameter hypothesis exists)**: the fourteenth wired probe
`specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean`
(`Probe761R`, compiled through the build guard: exit 0, 0 errors, 0 warnings, all six headline
theorems on `[propext, Classical.choice, Quot.sound]`, no `sorryAx`, no custom axiom, no
`native_decide`; wired) proves that an UNCONSTRAINED universal quantification over
`(Tc Tn P B : Nat)` makes `cellAt_const_of_kappa_eq` and `ladderRealized` FALSE: at
`Tc = Tn = P = B = 0` the quotient `CK 0 0 0 0` is a subsingleton (`ck_zero_subsingleton`, by
`decide`; inhabited, `ckZero`), so `kappa 0 0 0 0` identifies every counter pair and both
statements assert the cell is constant in `(c, n)`, which `cell_succ_ne` refutes for every `c` and
`n` with the next deadline held fixed, on the four-state tag object, non-vacuity witnessed on both
sides (`separating_pair_nonvacuous`) and using no property of `Dmax`. The repair this phase
implements is the parameter hypothesis: both statements now carry
`(hp : ParamsOk step pend lab phi Tc Tn P B)`, and this phase defines that predicate and proves it
at the parameters the periodicity fixpoint defines. The probe stays wired and unchanged: it is the
compiled reason the hypothesis is there, and a reader who removes `hp` re-breaks both statements.

**Goal**: Create `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean`: the
finite counter quotient `K` of the forced shape, its parameters as OUTPUTS of the periodicity
fixpoint per (K1)-(K4), the parameter-conditions predicate and its discharge lemma at those
outputs, `certStabK` rebuilt per `(q, κ)`, `certAdmK` over the full carrier, and `Dmax` as the
MAXIMUM certified subset with its maximality proved.

**Tasks**:
- [x] Define `K T_c T_n P B` as `Fin (T_c+1) × Fin (P+1) × Fin (T_n+1) × Fin (P+1) × Fin (2B+1)`
      and `κ` as `(min c T_c, c mod P, min n T_n, n mod P, clip (n - c) [-B, B])`, with a
      docstring stating that `K` is a CARRIER COORDINATE and never an index: `K` does not factor
      `cellAt` on its own, `Dmax` does.
- [x] Define `R_K`, the image of `Count`/`Drift` on classes, and prove it decidable. *(deviation: altered — the two nested bounded existentials exceeded `Decidable` instance resolution, so `R_K` is split into `rkStepB` (inner) and `RKb` (outer), decidable by construction, with `rk_iff` recovering the single bounded existential)*
- [x] Define each parameter as an output, each citing its source: `P` from (K1), a common
      multiple of the cycle lengths of the certificate graph restricted to saturated classes,
      via the set-level periodicity form `prodPreN_eventually_periodic`; `T_c` from (K2), at
      least the cascade bound (`iter_doubling`) and at least the semantic periodicity threshold;
      `T_n` and the ordering from (K3); `B` from (K4). No parameter may be an exhibited constant
      of the object or of the letters — mechanisms (4), (5) and (6) each refuted exactly that.
      The four output functions are what the Challenge block pins as `Tcof`, `Tnof`, `Pof`, `Bof`.
- [x] **Define the parameter-conditions predicate**, beside `CK`/`κ`, as the conjunction of
      (K1)-(K4), with the signature the Challenge block pins:
      `ParamsOk step pend lab phi Tc Tn P B`. It is NOT a predicate on four naturals: (K1)
      quantifies the certificate graph's cycle lengths on saturated classes, (K2) the cascade
      bound and the semantic periodicity threshold, and (K4) the formula's backward exactness
      depth `d_back`, none of which a numeric-only predicate can express; only (K3)'s ordering
      (`T_n ≥ T_c + 2ℓ₀ - 1`, `T_c ≥ 2 T_short + T_idle + 2`) is partly numeric. Each conjunct
      carries a docstring naming its (K1)-(K4) source and its compiled anchor. Each of the four
      conjuncts must be present: a predicate missing one is the same contract gap one level down.
- [x] **Prove the discharge lemma `paramsOk_params`**: the predicate holds at the four defined
      outputs. Without it both repaired theorems are safe but VACUOUS — a hypothesis no one can
      discharge is indistinguishable from an unproved statement for every downstream consumer,
      and Phases 11-13 consume `Dmax`'s maximality through exactly those two Goals. If the
      predicate cannot be discharged at the outputs, STOP and mark the phase `[BLOCKED]` with the
      goal state recorded: that means the parameter sources and the fixpoint's outputs disagree,
      which is a real finding and not a reason to weaken the predicate.
- [x] **Prove the hypothesis is load-bearing, not cosmetic**: on the refutation probe's own
      object (`stepP`, `pendP`, `labP`, `phiP`), the predicate FAILS at `Tc = Tn = P = B = 0` —
      the tuple the refutation turns on. (K1) alone suffices: `P = 0` cannot be a common multiple
      of that object's cycle length 2. If this cannot be proved, the predicate is too weak to
      exclude the refuted tuple: raise it in the handoff, never proceed.
- [x] Rebuild `certStab` per `(q, κ)` as `certStabK` (`stab_mem_tpOf_iff` is per cell, so the
      `K`-free fibre over `q` in `ProdState Q φ` promoted in Phase 8 is the wrong granularity for
      the ladder — F2(a), `cell_ne`), and define `certAdmK` over `Q × ClType φ × K` as the
      conjunction of the promoted predicates with the rebuilt `certStabK` and `certBox`. The
      `K`-free `certStab`/`certAdm` in `Certificate.lean` are untouched.
- [x] Define `Dmax` as the MAXIMUM `certAdmK`-certified subset and prove maximality: the union of
      certified sets is certified, so the maximum exists; `Dmax` is computable by enumeration over
      `Finset (Q × ClType φ × K)` — state this as a count of candidates, never a bound.
      *(deviation: altered — `Dmax` IS the union and `dmax_maximal` proves every certified set
      lies inside it, but the clause "the union of certified sets is certified" is NOT proved and
      is false for this certificate: `certStabK` and `certBoxK` are biconditionals between a
      letter's bit and a fibre of the candidate set, so enlarging the set breaks them. The four
      union-stable conditions ARE proved of `Dmax` (`dmax_certLocK`, `dmax_certBiInfK`,
      `dmax_certFwdK`, `dmax_certBwdK`). See the Reasoned Exclusions record below.)*
- [x] Wire the module (RaySummary.lean and its module-list docstring, FormalSystem.lean, C14
      heredoc, and the generated inventory blocks via `check-module-invariants.sh
      --emit-inventory` if the gate demands it, as it did in Phase 8).

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The `Dmax` task's justifying clause "the union of certified sets is certified, so the maximum exists" | FALSE for this certificate, so proving it would mean proving a false statement. `certStabK` and `certBoxK` are BICONDITIONALS between a letter's bit and a fibre of the candidate set (`ψ ∈ x.2.1.val ↔ ∀ y ∈ R, …`), so a member whose bit is set in a small certified set has that bit falsified as soon as the union adds a member missing the argument; only the four monotone conditions survive a union. The maximum is still well defined and is the union — the lattice join — and its own certification is Finding 3's route (the realizable set is certified GIVEN constancy of `cellAt` on `K`-classes), which the presentation-decision record assigns to the soundness and completeness obligations, never to a union argument. | Landed in `CounterQuotient.lean`: `dmax_maximal` (every `certAdmK`-certified set `⊆ Dmax`) plus `dmax_certLocK`, `dmax_certBiInfK`, `dmax_certFwdK`, `dmax_certBwdK` (the four union-stable conditions proved OF `Dmax`). No theorem claims `certStabK`/`certBoxK` of `Dmax`, and the module's "What this module does NOT hold" section says so in the source. The two definitions whose shape is the reason are `certStabK` and `certBoxK`, both stated with `↔`. Gates at closure: full guarded `lake build` exit 0, 0 errors, 0 warnings, 2890 jobs; `check-module-invariants.sh` ALL CHECKS PASSED; `check-evidence-probes.sh` exit 0, 44 of 44 wired probes PASS; `lean-sorry-census.sh` 0. |

No residual work follows from this exclusion: the clause as written will not be revisited,
because it is false. The certification of `Dmax` itself is Phases 11-13's own obligation along
Finding 3's route, and is already in this plan.

**Timing**: 3.5 hours

**Depends on**: 8

**Verification Tier**: interface

**Tier Justification**: A second new module enters the import graph and the C14 list, and both
`Dmax`'s maximality and the discharge lemma are consumed by Phases 11-13, so a guarded scoped
build plus the invariant script is the covering check.

**Scope Hypothesis**: One new module plus the wiring files Phase 8's landed set names (five, not
three — `scripts/nolints.json` and the generated inventory blocks may be demanded again); five `K`
coordinates, four parameters each with a named source, four predicate conjuncts, and two
parameter-side theorems (the discharge lemma and the all-zero exclusion). If a parameter cannot be
derived as an output and only an exhibited constant closes it, STOP: that is the refuted shape,
and the phase is `[BLOCKED]`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` - new module: K, kappa, R_K, the four parameter outputs, the parameter-conditions predicate and its discharge lemma, certStabK per (q, kappa), certAdmK, Dmax and its maximality
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import, one module-list docstring entry
- `FormalSystem.lean` - one import
- `scripts/check-module-invariants.sh` - C14 heredoc entry, regenerated inventory blocks if demanded
- `scripts/nolints.json` - only if a ported binder forces an exemption, as in Phase 8

**Verification**:
- Guarded scoped build exits 0, 0 warnings; `check-module-invariants.sh` exits 0.
- Each of `P`, `T_c`, `T_n`, `B` has a docstring naming its (K1)-(K4) source and its compiled anchor, and each is a function of `step`/`pend`/`lab`/`phi`, not a numeral.
- The parameter-conditions predicate's ELABORATED signature takes `step`, `pend`, `lab`, `phi` and the four naturals, in the order the Challenge block pins; a predicate on four naturals alone is a failure of this criterion, not a simplification.
- All four of (K1)-(K4) appear as conjuncts of the predicate, each identified in a docstring.
- `paramsOk_params` is a proved theorem in this module; `#print axioms` on it shows no `sorryAx`, no custom axiom, no `native_decide`.
- The all-zero exclusion is a proved theorem on the refutation probe's object; the predicate is therefore not satisfied by the tuple the refutation turns on.
- `Dmax`'s maximality is a proved theorem in the module, not an assumption of a later phase.
- No occurrence of a tuple-index claim of the form `index x = index y → cellAt x = cellAt y` anywhere in the module (grep for `cellAt` in the module returns only docstring mentions).
- No `sorry`, no `axiom`, no vacuous-definition pattern in the new module (module-scoped grep count 0); the repository-wide vacuous-definition grep unchanged from the dispatch's starting commit.
- `bash scripts/check-evidence-probes.sh` exits 0 and the refutation probe still PASSes, unmodified (`git diff` on it is empty).

---

### Phase 10: The Definitional Layer of `LadderRealize.lean` — `typeOfCl`, `certChain`, `LadderCons` [COMPLETED]

**Goal**: Create `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` carrying ONLY
the definitions the later phases' statements quantify over: `typeOfCl`, `certChain` and
`LadderCons`. No theorem in this phase consumes soundness, the lift or the agreement, which is
what lets it run concurrently with Phase 11 and is why it can close before any of the three hard
obligations is touched.

**Three defects of the previous decomposition are answered here.** (i) `certChain` was pinned by
the Challenge block and carried by no phase's task list, so no phase owned defining it; it is
owned here. (ii) `typeOfCl` was pinned the same way and is likewise defined nowhere in the library
(`ClType` IS landed, as an `abbrev` in `Certificate.lean`:
`{T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}`, so `typeOfCl` is its
projection); it is owned here too. (iii) "RETAIN `slive` as `Realize.lean`'s `SLive` deferral-graph
condition over `Q`'s `step`" does not type-check and is not what this phase does — see task 3.

**Tasks**:
- [x] Define `typeOfCl : ClType φ → Finset PlusFormula` as the projection out of `Certificate.lean`'s
      landed `ClType` abbrev, with a docstring recording that `ClType` is landed and only its
      projection was missing. The Challenge block pins this by position.
- [x] **Define `certChain`** at the signature the Challenge block pins:
      `certChain step pend lab φ Tc Tn P B (xi : Int → Q × ClType φ × CK Tc Tn P B) : Prop`. It is
      the bi-infinite chain condition over the product carrier: `relK` between consecutive
      positions, together with the `untl`/`snce` links read as formula membership in the `ClType`
      component. It is NOT stratified by `⊡`-nesting depth — that was route (R-a)'s shape, and
      (R-b) is the recorded route, so the unstratified definition is the one this plan asks for.
      Cite `relK`, `certLocK` and `DischPathK` (all landed in `CounterQuotient.lean`) rather than
      re-deriving their content.
- [x] **State `LadderCons step pend lab φ Tc Tn P B (R : Set (Q × ClType φ × CK …)) : Prop`** as
      `certAdmK … R ∧ Dmax … ⊆ R` — the certificate conditions plus the maximality clause — with
      the `box`/`stab` letters PINNED through `certAdmK`'s own `certBoxK` (one global bit,
      `box_mem_tpOf_iff`) and `certStabK` (per `(q, κ)`, `stab_mem_tpOf_iff`). The acceptance
      clause is part of the structure and is never dropped to make it writable. **No soundness
      field.** A clause asserting that projections of ladder histories lie in `R` would make
      `ladderCons_localRun`'s second conjunct near-vacuous under a filed name, which
      `plan-compliance.md`'s Statement Fidelity forbids; the conjunct is instead discharged in
      Phase 14 from `ladderSound` plus this maximality clause.
- [x] Record, in the module docstring, the ladder's structural liveness and the shape the backward
      half is retained in. `ulive` is replaced by the `Count`-driven decrease of `c` while pending;
      the backward half (`slive`) is RETAINED as `certBwdK`, the backward instance of Phase 9's
      landed `DischPathK` over the product carrier `Q × ClType φ × CK …` under `relK`, with the
      letters read as formula membership in the `ClType` component. State explicitly that
      `Realize.lean`'s `SLive` is NOT retained and cannot be: it is indexed by `(clSig φ).preds`
      letters over a labelling `Q → (clSig φ).preds → Bool`, while `LadderCons` carries
      `lab : Q → Atom → Bool` and keeps the closure component in `ClType φ`, so the term does not
      elaborate here. The same mismatch rules out `UCoh`, `ULive`, `SCoh`, `deferGraph`,
      `bwdDeferGraph`, `Disch`, `DischBwd`, `persist` and `snce_iff_of_SCoh_SLive`; no new
      translation layer is authored, because `DischPathK`/`certFwdK`/`certBwdK` already are it.
      Cite the thirteenth probe (`gPast_isPath`, `gPast_pending_past`, `gPast_count`) for why the
      backward half is not replaceable by `Count`, and say so in the forward-only wording
      guardrail (e) requires — with no device-discrimination claim.
- [x] Wire the module (RaySummary.lean and its module-list docstring, FormalSystem.lean, C14
      heredoc, `KTypeSummaryAxiomTest.lean`, and the generated inventory blocks via
      `check-module-invariants.sh --emit-inventory` if the gate demands them, as it did in
      Phases 8 and 9).
      *(conditional clause resolved: the C14 heredoc took NO entry. C14 pins the axiom profile of
      declarations paired with a `docs/theorem-index.md` row carrying `pinned:C14`, and this phase
      lands three definitions and no theorem, so it adds no such row; `check-module-invariants.sh`
      exits 0 with C14 unchanged. The three definitions are pinned instead in
      `KTypeSummaryAxiomTest.lean`, which the task list names in the same breath, as the
      `[propext, Classical.choice, Quot.sound]` profile each one carries. The generated inventory
      blocks WERE demanded, exactly as in Phases 8 and 9: `--emit-inventory` rewrote four README
      files. `scripts/nolints.json` was not demanded — no ported binder forced an exemption.)*

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: interface

**Tier Justification**: A third new module enters the import graph, the C14 list and the axiom
test, and `certChain`/`LadderCons` are consumed by Phases 14-16 through the module interface, so
the covering check is a guarded scoped build plus `check-module-invariants.sh` and the axiom test.

**Scope Hypothesis**: One new module plus five wiring files (the set Phases 8 and 9 actually
needed, `scripts/nolints.json` and the generated inventory blocks included, not the three the
earlier decomposition assumed); three definitions in this phase (`typeOfCl`, `certChain`,
`LadderCons`) and no theorem. If `certChain` cannot be stated without a depth parameter, that
contradicts the recorded route decision: STOP and raise it rather than stratifying the definition,
because a stratified `certChain` changes `ladderLift`'s pinned signature.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - new module: typeOfCl, certChain, LadderCons
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import, one module-list docstring entry
- `FormalSystem.lean` - one import
- `scripts/check-module-invariants.sh` - one C14 heredoc entry, regenerated inventory blocks if demanded
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the new module's axiom-profile entries
- `scripts/nolints.json` - only if a ported binder forces an exemption, as in Phase 8

**Verification**:
- Guarded scoped build exits 0, 0 warnings; `check-module-invariants.sh` exits 0.
- `certChain`'s and `LadderCons`'s ELABORATED signatures match the Challenge block token-for-token, by direct `diff` of the extracted signature text.
- `LadderCons` carries both the `box` and the `stab` clause (through `certAdmK`) and a maximality clause; it carries NO field whose statement mentions `WorldHistory`, `tpOf`, `ladderModel` or `cellAt` — a grep over the definition for those four identifiers returns nothing, which is the mechanical form of "no soundness field".
- `certChain`'s statement carries no depth or stratification parameter (its argument list is exactly the one the Challenge block pins).
- `SLive`, `SCoh`, `deferGraph`, `bwdDeferGraph`, `Disch`, `DischBwd`, `persist` and `snce_iff_of_SCoh_SLive` appear nowhere in the module outside the docstring sentence that records why they do not transfer (grep).
- No `sorry`, no `axiom`, no vacuous-definition pattern in the new module (module-scoped grep count 0); the repository-wide vacuous-definition grep unchanged from the dispatch's starting commit.

---

### Phase 11: The Agreement `cellAt_const_of_kappa_eq`, Proved at the History Level [BLOCKED]

**Goal**: Create `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` and prove
`cellAt_const_of_kappa_eq`: under the parameter conditions, the cell at `(q, c, n)` equals the cell
at `(q, c', n')` whenever `kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')`. The proof is at the
HISTORY level — given a history through one state realizing a type, the chain-replacement
machinery produces a history through the other realizing the same type — and uses no certificate
object whatsoever. This is the phase that breaks the circularity, and the certificate-freedom of
its module is the mechanical form of that claim.

**BLOCKER** (Phase 11):
- **What failed**: `cellAt_const_of_kappa_eq` is NOT proved and is not stated anywhere in the
  tree. The module `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` carries 46
  compiled declarations — `stab_mem_tpOf_iff_cell`, the rigid-anchor layer, the collision reading
  of the counter quotient, and now the ADMISSIBILITY HALF of the pumping replacement — with no
  `sorry`, no axiom and no vacuous definition. What is missing is the TYPE-PRESERVATION half of
  the chain-replacement machinery (task 3's second clause, "preserving ... the realized type") and
  everything downstream of it (tasks 4's cascade and task 5).
- **What was tried**: the machinery was built from the `Count` clause up, in two rounds. The first
  round landed the rigid anchors (the four readings of `Count` along a path; the rigid pending
  region `cntAt_sub_of_pend`/`not_pend_of_count`/`cntAt_add_of_pend_back`; the rigidity
  `cntAt_eq_of_obj_eq`; the `1`-Lipschitz window `nxtAt_lipschitz`/
  `cntAt_le_nxtAt_succ_of_idle_past` with its dichotomy `pend_past_of_nxtAt_lt`; and the collision
  reading `kappa_eq_components`/`eq_or_both_ge_of_min_eq`/`clipIdx_regime_of_eq`). The second round
  acted on what the rigidity forces — that the WALK has to move — and landed the walk-level
  surgery: the segment (`objCycleLens_of_segment`, `exists_objCycle_of_card_le_cnt`,
  `objCycle_dvd_succ_of_paramsOk`, `exists_pumpSeg_of_card_le_cnt`), the splice
  (`spliceObj`, `spliceCnt`, their four accessors, `spliceSeg`, `spliceObj_step`, the three local
  readings of `Count` — `spliceCnt_idle`, `spliceCnt_pend_pend`, `spliceCnt_pend_idle` — and the
  payoff `spliceCnt_add_of_mem_region`/`spliceObj_eq_of_le`/`spliced_at_region`), the lift
  (`exists_ladderPath_of_walk` over `RunLayer.lean`'s `exists_rlad_hist_of_walk`,
  `exists_spliced_ladderPath`), and the side condition's necessity and its regime-2 discharge
  (`nxtAt_lipschitz_two_sided`, `pinCompat_of_ladderPath`,
  `spliceObj_pend_of_lt_of_pend_past`, `exists_spliced_ladderPath_of_pend_past`). Full guarded
  `lake build` exit 0, 2892 jobs, 0 errors, 0 warnings; `check-module-invariants.sh` ALL CHECKS
  PASSED; `typst-sync-check.sh` PASS; 44 of 44 wired probes PASS.
- **Why it is stuck**: obstruction 1 of the previous record is DISCHARGED and two stand.
  1. **DISCHARGED — the walk can now be pumped.** The previous record's first obstruction was
     that `cntAt_eq_of_obj_eq` forbids keeping the object walk and moving the counters, so the
     argument has to pump the walk itself, and no such surgery existed. It exists now. A pending
     region at least as long as the object count carries an object pending cycle
     (`exists_objCycle_of_card_le_cnt`) whose length divides `P + 1` under `(K1)`
     (`exists_pumpSeg_of_card_le_cnt`); repeating that segment yields a walk satisfying all three
     local readings of `Count`, lifting to a ladder path through the SAME object state with the
     countdown raised by EXACTLY the cycle length (`spliced_at_region`), hence with the residue
     coordinate of `kappa` unmoved. In the pending-forever-into-the-past regime the lift needs no
     side condition at all (`exists_spliced_ladderPath_of_pend_past`).
  2. **STANDING — the type-preservation half is a model-level periodicity statement, and the only
     landed periodicity is on the certificate relation.** Every statement of the replacement layer
     is about admissibility; none mentions `tpOf` or `cellAt`. Changing the walk changes the
     realized type at the position unless the repeated block is type-neutral, which is a
     MODEL-level statement about truth along a ladder path. The only landed periodicity statement
     is `prodPre_periodic` with its outputs `satThreshold`/`satPeriod` — the eventual periodicity
     of `prodPreStep (cohIdle …)` on `Finset (ProdState Q φ)` — and `CounterQuotient.lean` says in
     source that nothing there relates `cohIdle` to `Rlad`, `ladderModel`, `tpOf` or `cellAt`:
     that bridge IS obligations (S) and (C'), Phases 12-15, which READ this agreement. Reusing it
     here closes a THIRD cycle. A model-level pumping lemma has to be authored instead, and no
     phase of this plan costs one.
  3. **STANDING — the `⊡` bit forces an induction on `⊡`-nesting depth even at the history
     level.** By the landed `stab_mem_tpOf_iff_cell`, `⊡χ ∈ tpOf M φ σ z` iff `χ` belongs to every
     type in `cellAt M φ (σ.state z) z` — the very object the agreement compares. Route (R-b)
     relocates that stratification into this phase's proof rather than removing it; the phase's
     task list contains no induction step.
  4. **STANDING, NEW AND PRECISE — the pin side condition is a real obstruction outside the
     pending-forever regime, and the cascade that would discharge it is not landed.** A region
     start's countdown IS the deadline register's value at the idle position before it
     (`cntAt_eq_nxtAt_of_idle_pend`) and the register is `1`-Lipschitz, so the region-start
     countdowns of EVERY ladder path are pairwise compatible — `pinCompat_of_ladderPath`, compiled
     here, so this is forced and not an artefact of the lift lemma's shape. Lengthening one region
     by `l` raises that one pin by `l` and moves no earlier region start, so compatibility has to
     be re-established by lengthening the preceding idle runs with it. That is exactly the cascade
     `(K2)`'s `cascadeBound` sizes (`iter_doubling`, exponential in the number of pinned regions),
     and it is not landed. `exists_spliced_ladderPath` therefore carries the condition as an
     explicit hypothesis, and only `exists_spliced_ladderPath_of_pend_past` discharges it.
- **What is needed**: a plan revision adding, before the Goal, (a) a model-level pumping lemma —
  repeating a pending segment whose length divides `P + 1` at a position at least `Tc` away from
  `z` preserves `tpOf` at `z` — stated and proved on ladder paths with no certificate object, with
  the landed `exists_spliced_ladderPath_of_pend_past` as its admissibility input; (b) an explicit
  `⊡`-nesting-depth induction carrying the agreement, with (a) as its temporal/atomic base case;
  and (c) the cascade discharging the pin side condition in the regime where an idle position lies
  in the past, which is the only part of the admissibility half still open. The compiled
  `clipIdx_regime_of_eq` says the two regimes of `pend_past_of_nxtAt_lt` never collide at a fixed
  next deadline, so (a) may be given separately in each regime and no path has to be carried from
  one into the other — and the regime in which the admissibility half is already unconditional is
  one of the two. None of (a), (b), (c) is costable, for the reason this phase is not.
- **Prohibited workarounds**: do NOT use `sorry`, `def X := True` or any vacuous placeholder; do
  NOT add a finite-fibre or finite-width hypothesis; do NOT state the agreement with a trace-level
  `Presented` hypothesis; do NOT narrow it to the positionwise shape (`no_positionwise_lift` is
  compiled, so the narrowed form is FALSE, not weaker); and do NOT discharge it by citing
  `prodPre_periodic` across the certificate/model boundary, which is obstruction 2.

**Tasks**:
- [x] Create the module importing only `LadderModel`, `AnchorLayer`, `RunLayer` and
      `CounterQuotient` (for `kappa` and `ParamsOk`). Its docstring states, in one paragraph, that
      the agreement is proved on its own ground rather than as a corollary of soundness and the
      lift, and why: `certStabK` on any certified set containing a realized item forces exactly
      this agreement (`stab_bit_agree_of_certStabK` read through `stab_mem_tpOf_iff_cell` and
      `certBiInfK`), so deriving the agreement from the certificate side closes a cycle.
      *(deviation: altered — the import list is the MINIMAL form of the four named modules:
      `AnchorLayer` and `CounterQuotient` only, which transitively carry `LadderModel` and
      `RunLayer`. The acyclicity paragraph is written WITHOUT naming the certificate conditions,
      so the certificate-freedom grep returns nothing at all rather than docstring-only
      occurrences — stricter than the criterion asks.)*
- [x] Land `stab_mem_tpOf_iff_cell` here, verbatim from the phase-11 handoff (it compiled
      standalone through the build guard, exit 0, no `sorry`): the `⊡` bit of a realized type is a
      datum of the cell at the point's own world state. It is a statement about `cellAt` and
      `tpOf` only, which is why it belongs in this module and not in the certificate layer.
- [ ] **State the chain-replacement machinery as named, reusable lemmas, independent of the
      agreement's own statement.** *(deviation: blocked — the RIGID-ANCHOR half is landed as 21
      named, exported declarations and the REPLACEMENT half's ADMISSIBILITY conjunct as 24 more,
      each citable by Phase 15 and none mentioning the agreement: the saturated segment is
      identified (`exists_objCycle_of_card_le_cnt`), its length is shown to divide `P + 1`
      (`exists_pumpSeg_of_card_le_cnt`), the replacement is constructed and shown to be a ladder
      path (`spliceObj`/`spliceCnt`, `spliceObj_step`, the three `Count` readings,
      `exists_spliced_ladderPath`) and to move the countdown by exactly the cycle length
      (`spliced_at_region`). The second conjunct — "preserving ... the realized TYPE" — is not
      landed, for obstructions 2 and 3 of the BLOCKER record, and the admissibility conjunct is
      unconditional only in the pending-forever-into-the-past regime
      (`exists_spliced_ladderPath_of_pend_past`), for obstruction 4.)* Identify the rigid anchors of a ladder history (exact `c`,
      exact `n`, exact gap) and prove that saturated segments between anchors can be replaced by
      segments of other lengths in the same residue class mod `P`, preserving admissibility and
      the realized type. This is the counter-lift lemma in its PUMPING form; the POSITIONWISE form
      is REFUTED for every finite `CK` and every `kappa` (`no_positionwise_lift`, compiled), so
      narrowing to it would be stating a false theorem, not a weaker one. Phase 15 CONSUMES these
      lemmas, so each must be stated without reference to the agreement.
- [ ] Iterate the replacement until the pin lemma's inequalities hold, *(deviation: blocked —
      the replacement now exists and `exists_rlad_hist_of_walk` IS applied to it
      (`exists_ladderPath_of_walk`, `exists_spliced_ladderPath`), and the pin inequalities are
      discharged outright in the pending-forever-into-the-past regime
      (`exists_spliced_ladderPath_of_pend_past`). What is not landed is the ITERATION — the
      cascade that re-establishes pin compatibility in the other regime, obstruction 4 of the
      BLOCKER record, whose necessity is now compiled as `pinCompat_of_ladderPath`.)*  then apply
      `exists_rlad_hist_of_walk` and `drift_extension_of_pins` (Phase 7, landed) to produce the
      replacement history. Compose across idle runs using the compiled arithmetic:
      `forward_window` (`|L - n| ≤ c + j`), `backward_constraint` (`n ∈ [c-1, c+2s+1]`),
      `region_doubling` (`L' ≤ 2L + j + 1`) and `doubling_attained`. These are cited, not
      re-proved.
- [ ] Prove `cellAt_const_of_kappa_eq` at the signature the Challenge block pins, *(deviation:
      blocked — not stated anywhere in the tree, so no `sorry` carries it; the type-preservation
      half it needs is obstruction 2 of the BLOCKER record.)*  with
      `(hp : ParamsOk step pend lab φ Tc Tn P B)` in the recorded position. The hypothesis is
      CONSUMED in the argument — it is what rules out the collapsing parameter tuples, by making
      every `kappa`-collision a collision within a residue class mod `P` — and must appear in the
      proof, not be discarded at the top. If a proof appears to close without using `hp`, that is
      a signal the argument has collapsed into the refuted shape: stop and record it, because the
      fourteenth probe's refutation holds for every `kappa` and every candidate `Dmax`.
- [x] Wire the module (RaySummary.lean and its module-list docstring, FormalSystem.lean, C14
      heredoc, `KTypeSummaryAxiomTest.lean`). *(the C14 heredoc took no entry, for the same
      reason as in Phase 10: C14 pins declarations paired with a `docs/theorem-index.md` row
      carrying `pinned:C14`, and this phase lands no Goal and adds no such row;
      `check-module-invariants.sh` exits 0 with C14 unchanged. All 46 declarations are pinned in
      `KTypeSummaryAxiomTest.lean` instead. The three generated README inventory blocks and
      `typst/generated/status.typ` were resynced, as the pre-commit gate requires whenever a
      `.lean` file changes length.)*

**Timing**: NOT COSTABLE. This is the pumping counter-lift mathematics, moved to the front of the
open work by the recorded route decision. The predecessors that attempted comparable rounds closed
in ~1-1.6 hours against ~9-hour estimates, and both returned refutations rather than positive
lemmas; no estimate is offered here, and none is to be invented by the implementer.

**Depends on**: 7, 9

**Verification Tier**: full

**Tier Justification**: The chain-replacement argument spans the whole `RunLayer.lean` pin-lemma
surface, `AnchorLayer.lean`'s cell and `LadderModel.lean`'s admissible frame at once, and Phase 15
consumes its lemmas across a module boundary, so no cheaper tier covers the cross-module surface
it reaches.

**Scope Hypothesis**: One new module and four wiring files; one Goal declaration plus the
machinery lemmas, all inside `LadderAgree.lean`. If the replacement argument needs a seventh
counter observable — a mechanism not inside the forced `CK` — that is a REFUTATION of the licensed
shape and a complete, reportable outcome, not a failure: record it with the separating pair as a
compiled theorem, with non-vacuity witnessed on both sides, and mark the phase `[BLOCKED]`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - new module: stab_mem_tpOf_iff_cell, the chain-replacement machinery, cellAt_const_of_kappa_eq
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import, one module-list docstring entry
- `FormalSystem.lean` - one import
- `scripts/check-module-invariants.sh` - one C14 heredoc entry
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the new module's axiom-profile entries

**Verification**:
- Guarded scoped build exits 0, 0 warnings; `cellAt_const_of_kappa_eq`'s signature matches the Challenge block token-for-token, by direct `diff` of the extracted signature text — the parameter hypothesis included, in the recorded position.
- **The certificate-freedom grep, which is this phase's acyclicity criterion**: `grep -nE 'certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons' FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` returns occurrences only inside the docstring paragraph that explains why they are absent. The module's `import` list contains no certificate module other than `CounterQuotient` (needed for `kappa` and `ParamsOk`, neither of which is a certificate condition).
- `lean_minimal_hypotheses` (or an equivalent check) confirms `hp` is NOT a redundant binder in the proof.
- `#print axioms cellAt_const_of_kappa_eq` shows no `sorryAx`, no custom axiom, no `native_decide`.
- `stab_mem_tpOf_iff_cell` is a proved theorem in this module, stated as the handoff quotes it.
- The chain-replacement lemmas are named, exported declarations whose statements do not mention `cellAt_const_of_kappa_eq`; Phase 15 is able to cite each by name.
- No positionwise completeness clause is stated anywhere in the module (grep); no finite-fibre or finite-width hypothesis appears in the Goal or in any lemma it uses.
- If the phase closes `[BLOCKED]`: the goal state reached is recorded in the phase body and in the handoff, with no `sorry`, axiom, vacuous definition, trace-level hypothesis, or finite-fibre retreat anywhere in the tree.

---

### Phase 12: `Real`, Its Certification Under the Parameter Conditions, and `Real ⊆ Dmax` [NOT STARTED]

**Goal**: Define `Real`, the actual realizable subset of `Q × ClType φ × CK Tc Tn P B`, prove it
`certAdmK`-certified under the parameter conditions, and conclude `Real ⊆ Dmax` from Phase 9's
landed `dmax_maximal`. This is Finding 3's route to `Dmax`'s own certification, and it is candidate
(2) of the four — the one the agreement makes reachable.

**Tasks**:
- [ ] Define `Real step pend lab φ Tc Tn P B fwd bwd : Set (Q × ClType φ × CK Tc Tn P B)` as the
      set of `(q, T, κ)` for which some admissible ladder history `σ` and some `z` realize `T` at
      a state `⟨(q, c, n), h⟩` with `kappa Tc Tn P B (c, n) = κ`. Docstring: this is the set-valued
      per-state datum of presentation (a), and `Real` is not an index — `Dmax` is.
- [ ] Land `stab_bit_agree_of_certStabK` here, verbatim from the phase-11 handoff (it compiled
      standalone through the build guard, exit 0, no `sorry`): any `certStabK`-certified set
      collapses the `⊡` bits across a `(q, κ)`-class. It is a statement about certified sets, which
      is why it belongs in the certificate-side module and not in `LadderAgree.lean`.
- [ ] Prove the four monotone conditions of `Real` — `certLocK`, `certBiInfK`, `certFwdK`,
      `certBwdK` — from the structure of an admissible ladder history: local coherence and the
      `untl`/`snce` links along an actual history, with the counter classes following `RK` by
      `Count`/`Drift`, and both fulfilment arms EXISTENTIAL (`ULive`/`SLive` are the wrong strength
      per the sufficiency record, and do not type-check here in any case — Phase 10's docstring
      task records why).
- [ ] Prove `certBoxK` of `Real`. This is the condition candidate (1) failed, and it is reachable
      for `Real` exactly because `box_mem_tpOf_iff`'s quantifier is GLOBAL: every member of `Real`
      is some `tpOf M φ σ' z'` and conversely, so the `←` direction's "every member of `Real`
      carries `ψ`" is the same quantifier the real bit uses.
- [ ] **Prove `certStabK` of `Real` from Phase 11's agreement.** Both directions reduce, by
      `stab_mem_tpOf_iff_cell`, to the cells of class-equivalent states agreeing — which is
      `cellAt_const_of_kappa_eq`, available as a theorem rather than as an obligation. Assemble the
      six conditions as `real_certAdmK_of_paramsOk : ParamsOk step pend lab φ Tc Tn P B →
      certAdmK step pend lab φ Tc Tn P B (Real …)`. The parameter hypothesis enters here and only
      here on the certificate side, through the agreement.
- [ ] Conclude `real_subset_dmax : Real … ⊆ Dmax …` by `dmax_maximal` applied to
      `real_certAdmK_of_paramsOk` (so the inclusion is likewise stated under `hp`).
- [ ] **Do not state or prove `Dmax ⊆ Real` in this phase.** The reverse inclusion is the lift's
      own content — every certified item is realized — and it is Phase 15's corollary of
      `ladderLift` plus the landed `dmax_certBiInfK`. Attempting it here pulls (C') forward and
      re-closes a loop the revision opened.

**Timing**: 2.5 hours

**Depends on**: 10, 11

**Verification Tier**: interface

**Tier Justification**: `Real` and its certification are consumed by Phases 13 and 15 across the
module interface and the declarations enter the axiom test, so a guarded scoped build plus
`check-module-invariants.sh` and `#print axioms` is the covering check.

**Scope Hypothesis**: One definition (`Real`), one ported lemma
(`stab_bit_agree_of_certStabK`), six condition lemmas, one assembly
(`real_certAdmK_of_paramsOk`) and one inclusion (`real_subset_dmax`), all inside
`LadderRealize.lean`; no new module and no wiring file beyond the axiom test. If `certStabK` of
`Real` does not close even with the agreement in hand, that is a finding about the agreement's
strength, not a reason to shrink `Real` to one of candidates (1), (3) or (4) — each is already
refuted by a named condition. Mark the phase `[BLOCKED]` and record which direction of the
biconditional failed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - Real, stab_bit_agree_of_certStabK, the six condition lemmas, real_certAdmK_of_paramsOk, real_subset_dmax
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom-profile entries for the new declarations

**Verification**:
- Guarded scoped build exits 0, 0 warnings; `check-module-invariants.sh` exits 0.
- `real_certAdmK_of_paramsOk` is a proved theorem; `#print axioms` on it and on `real_subset_dmax` shows no `sorryAx`, no custom axiom, no `native_decide`.
- The `certStabK` proof CITES `cellAt_const_of_kappa_eq` (grep the proof body); it does not re-derive the agreement, and it does not confine `Real` to one state's cell.
- `stab_bit_agree_of_certStabK` is a proved theorem in this module, stated as the handoff quotes it.
- No theorem in the module states `Dmax … ⊆ Real …` or any equality `Dmax … = Real …` (grep): that inclusion is Phase 15's.
- No union argument appears: no theorem claims `certStabK` or `certBoxK` of a union of certified sets, and none claims `certAdmK … (Dmax …)` (grep).
- No `sorry`, no `axiom`, no vacuous-definition pattern added to the module (module-scoped grep count 0); the repository-wide vacuous-definition grep unchanged from the dispatch's starting commit.

---

### Phase 13: Obligation (S) — `ladderSound` [NOT STARTED]

**Goal**: Prove that every admissible ladder history projects into `Dmax` at its own counter class,
with its own closure type, at the signature the Challenge block pins — token-for-token, with NO
parameter hypothesis.

**The one statement-level risk this phase carries, recorded before it is entered.** The route this
decomposition provides runs through `real_subset_dmax`, which is stated UNDER `hp` because
`Real`'s `certStabK` needs the agreement. The pinned `ladderSound` carries no `hp`. So the pinned
statement is provable by this route only if the `hp` can be removed, and whether it can is open.
The three tasks below are ordered so the cheap, decisive question is asked first and no
implementer adds `hp` to a filed signature on its own authority.

**Tasks**:
- [ ] **First, ask whether the unconstrained statement is REFUTABLE.** On the refutation probe's
      own object (`stepP`, `pendP`, `labP`, `phiP`, all landed in `CounterQuotient.lean` beside
      `not_paramsOk_allZero`), attempt a separating pair at `Tc = Tn = P = B = 0`: an admissible
      ladder history whose projection lies in no `certAdmK`-certified subset of
      `Q × ClType φ × CK 0 0 0 0`. If that closes, it is a COMPLETE and successful outcome, not a
      failure: land it as a wired probe
      (`specs/evidence/seam-gluing-ray-product/ladder-sound-unconstrained-parameter-refutation.lean`)
      with non-vacuity witnessed on both sides, wire it into `scripts/check-evidence-probes.sh`,
      mark this phase `[BLOCKED]`, and RAISE the statement-defect. Adding `hp` to `ladderSound` is
      a change to a recorded Challenge statement, which `plan-compliance.md`'s Statement Fidelity
      routes to the user and to `/revise`, never to a quiet edit by the implementer.
- [ ] If the unconstrained statement is not refutable, prove the pinned `ladderSound`: the
      projection of the given history lies in `Real` by `Real`'s own definition (the history and
      the index `z` are the witnesses), and `Real ⊆ Dmax`; the closure type is `tpOf` by
      `typeOfCl`'s definition. Record in the proof's docstring which step, if any, needed a
      parameter condition.
- [ ] If neither closes within the phase, land `ladderSound_of_paramsOk` — the same conclusion
      under `(hp : ParamsOk step pend lab φ Tc Tn P B)` — under THAT name, never under the filed
      name, mark the pinned `ladderSound` `[BLOCKED]` with the goal state recorded, and raise the
      statement-defect as above. Phase 16's `ladderRealized` carries `hp` already and can consume
      the auxiliary, so the critical path to the fibre equation survives this outcome; Phase 14's
      does not, and Phase 14 records that cascade as its own contingency.
- [ ] Under no outcome add `hp` to `ladderSound`'s own signature, carry a soundness field on
      `LadderCons`, weaken the conclusion from membership in `Dmax` to membership in some named
      smaller set, or introduce a finite-fibre or finite-width hypothesis.

**Timing**: 2 hours

**Depends on**: 12

**Verification Tier**: interface

**Tier Justification**: The theorem is consumed by Phases 14 and 16 through the module interface
and its axiom profile must be read, so a guarded scoped build plus `#print axioms` is the covering
check.

**Scope Hypothesis**: One Goal declaration inside `LadderRealize.lean`, plus — only on the first
task's refuting branch — one new probe file and one evidence-script entry. If that branch fires,
the wired-probe count rises by one from whatever `scripts/check-evidence-probes.sh` reports at the
start of the phase (44 at this plan's authoring, 43 `WIRED` plus 1 `WIRED_REPO`): read the count,
do not assume it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderSound (or ladderSound_of_paramsOk on the constrained branch)
- `specs/evidence/seam-gluing-ray-product/ladder-sound-unconstrained-parameter-refutation.lean` - new wired probe, ONLY on the first task's refuting branch
- `scripts/check-evidence-probes.sh` - one table row, one WIRED entry, only on that branch

**Verification**:
- Guarded scoped build exits 0, 0 warnings.
- On the unconstrained branch: `ladderSound`'s signature matches the Challenge block token-for-token, by direct `diff`, with no parameter hypothesis; `#print axioms ladderSound` shows no `sorryAx`, no custom axiom, no `native_decide`.
- On the constrained branch: the declaration is named `ladderSound_of_paramsOk`, no declaration named `ladderSound` exists in the module, the phase heading reads `[BLOCKED]`, and the raise is recorded in the phase body, in `issues.jsonl` and in the handoff.
- On the refuting branch: `lake env lean` on the new probe through the build guard exits 0 with 0 errors and 0 warnings, `check-evidence-probes.sh` exits 0 with one more wired probe PASS than the count read at the start, and the probe header states the verdict and both non-vacuity witnesses; no `native_decide`.
- The `stab` step cites `stab_mem_tpOf_iff` or `stab_mem_tpOf_iff_cell`; no finite-fibre or finite-width hypothesis appears in the statement or in any lemma it uses.
- `LadderCons` is unchanged from Phase 10 (`git diff` on its definition is empty): no soundness field was added.

---

### Phase 14: `ladderCons_localRun` [NOT STARTED]

**Goal**: Prove `ladderCons_localRun` at the pinned signature: the projection of every admissible
ladder history is a certificate chain, and lies inside any `LadderCons`-consistent bundle `R`.

**How the previous decomposition's 10 ↔ 11 circularity is resolved here, by ORDER and not by a
merge.** The second conjunct `∀ t, xi t ∈ R` needs the projection to lie in `Dmax`, which is
exactly `ladderSound`. In the previous decomposition this phase preceded soundness, so the only
way to close it was a soundness field on `LadderCons` — the weakened-statement move both this plan
and `plan-compliance.md` forbid. Here the bundle's DEFINITION landed in Phase 10 and soundness
landed in Phase 13, so the conjunct is discharged from `ladderSound` plus `LadderCons`'s
maximality clause `Dmax ⊆ R`, with no field added and both signatures pinned. A merge of the two
phases was tried and did not help, because it did not touch the agreement circularity; the fix is
the order, which the agreement-first route makes available.

**Tasks**:
- [ ] Prove the first conjunct: the projection `xi` of an admissible ladder history satisfies
      `certChain step pend lab φ Tc Tn P B xi`. Reuse Phase 12's four monotone condition lemmas
      for `Real` where the argument is the same — local coherence, the `untl`/`snce` links, and the
      counter classes following `RK` by `Count`/`Drift` — rather than re-deriving them. Do not
      re-prove `presented_modelOf`, `run_seam_state` or `isRun_of_chain_seam`, none of which
      transfer.
- [ ] Prove the second conjunct from `ladderSound` plus the maximality clause of
      `LadderCons`: the projected item lies in `Dmax` by (S), and `Dmax ⊆ R` by the bundle's own
      clause. The signature carries NO parameter hypothesis: this theorem is not one of the two the
      refutation touches.
- [ ] **Contingency, stated up front because it is a cascade and not a surprise.** If Phase 13
      closed only `ladderSound_of_paramsOk`, this theorem's second conjunct is unavailable at
      unconstrained parameters and this phase closes `[BLOCKED]` with the goal state recorded. Do
      NOT repair it by adding `hp` to `ladderCons_localRun`, by carrying soundness as a
      `LadderCons` field, or by weakening the conjunct to membership in `Real`: all three are
      weakened statements under a filed name. Record the first conjunct as proved if it is, name
      the second as the remainder, and raise.

**Timing**: 1.5 hours

**Depends on**: 10, 13

**Verification Tier**: interface

**Tier Justification**: The theorem is the module's public surface for 763 and its axiom profile
must be read, so a guarded scoped build plus `#print axioms` is the covering check.

**Scope Hypothesis**: One Goal declaration inside `LadderRealize.lean`; no other file changes in
this phase. If the first conjunct needs a declaration Phase 12 did not land, name it and prove it
here rather than reopening Phase 12.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderCons_localRun and its supporting lemmas

**Verification**:
- Guarded scoped build exits 0, 0 warnings; `ladderCons_localRun`'s signature matches the Challenge block token-for-token, by direct `diff` of the extracted signature text, with no parameter hypothesis.
- `#print axioms ladderCons_localRun` shows no `sorryAx`, no custom axiom, no `native_decide`.
- The second conjunct's proof cites `ladderSound` (or, on the cascade branch, the phase closes `[BLOCKED]` and cites nothing); `LadderCons` is unchanged from Phase 10 (`git diff` on its definition is empty).
- No `sorry`, no `axiom`, no vacuous-definition pattern added to the module (module-scoped grep count 0).

---

### Phase 15: Obligation (C') — `ladderLift`, the Pumping Completeness, and `Dmax ⊆ Real` [NOT STARTED]

**Goal**: Prove the lift in PUMPING form: for every bi-infinite certificate chain `ξ` inside `Dmax`
and every `(c, n)` in `ξ 0`'s class there is an admissible ladder history through `(q, c, n)` whose
closure type at the origin is `ξ 0`'s. Then conclude the pointwise corollary `Dmax ⊆ Real`, which
is what the fibre equation's `⊇` direction needs and which nothing before this phase uses.

**Tasks**:
- [ ] State `ladderLift` in the pumping form of the Challenge block, with NO parameter hypothesis:
      it is not one of the two statements the refutation touches, and its recorded signature
      stands. The POSITIONWISE form is REFUTED for every finite `CK` and every `kappa`
      (`no_positionwise_lift`, compiled): a positionwise `ladderLift` would be a false statement,
      so narrowing to it is not a weaker statement but a wrong one.
- [ ] Prove it by CITING Phase 11's chain-replacement machinery by name — the anchor
      identification, the residue-class segment replacement, and the iteration to the pin lemma's
      inequalities — applied to the chain `ξ` rather than to a history. Do not re-derive that
      machinery here; if a lemma Phase 11 landed is stated too narrowly to apply to a chain,
      generalise it in `LadderAgree.lean` and record the generalisation, rather than writing a
      second copy in this module.
- [ ] Apply `exists_rlad_hist_of_walk` and `drift_extension_of_pins` (Phase 7, landed) to produce
      the history, and the label-level sufficiency (Phase 8, landed) on the resulting walk,
      composing across idle runs with the compiled arithmetic (`forward_window`,
      `backward_constraint`, `region_doubling`, `doubling_attained`). These are cited, not
      re-proved. `realizes_of_certAdm_cohBi` is sufficiency for the interior of ONE region and
      transfers to the region segments of a ladder history, never to the history itself.
- [ ] **Prove the pointwise corollary `dmax_subset_real : Dmax … ⊆ Real …`**: given
      `x ∈ Dmax`, Phase 9's landed `dmax_certBiInfK` extends `x` to a bi-infinite chain inside
      `Dmax`, `certChain` of that chain follows from `Dmax`'s four landed monotone conditions, and
      `ladderLift` lifts it to a history realizing `x`'s closure type at a state of `x`'s class —
      so `x ∈ Real`. Together with Phase 12's `real_subset_dmax` this gives `Dmax … = Real …`
      under `hp`; state that equality here if it is useful to Phase 16, and derive it, never
      assume it.

**Timing**: NOT COSTABLE, for the same reason Phase 11 is not: this is the second half of the open
mathematics of the record. No estimate is offered and none is to be invented by the implementer.

**Depends on**: 7, 11, 12

**Verification Tier**: full

**Tier Justification**: The lift touches the whole RaySummary import chain at once —
`RunLayer.lean`'s pin lemma, `Certificate.lean`'s label-level sufficiency, `CounterQuotient.lean`'s
`Dmax` conditions and `LadderAgree.lean`'s machinery — and no cheaper tier covers that span.

**Scope Hypothesis**: One Goal declaration plus the corollary, inside `LadderRealize.lean`, with
any generalisation of Phase 11's machinery landing in `LadderAgree.lean` instead. If the
chain-replacement argument needs a seventh counter observable — a mechanism not inside the forced
`CK` — that is a REFUTATION of the licensed shape and a complete, reportable outcome, not a
failure: record it with the separating pair as a compiled theorem and mark the phase `[BLOCKED]`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderLift, dmax_subset_real, and their supporting lemmas
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - only if a Phase 11 machinery lemma must be generalised to apply to a chain

**Verification**:
- Guarded scoped build exits 0, 0 warnings; `ladderLift`'s signature matches the Challenge block token-for-token, by direct `diff`, with no parameter hypothesis.
- `#print axioms ladderLift` and `#print axioms dmax_subset_real` show no `sorryAx`, no custom axiom, no `native_decide`.
- The proof CITES at least one named Phase 11 machinery lemma (grep the proof body for the names Phase 11 exported); no chain-replacement lemma is restated in this module.
- `dmax_subset_real`'s proof cites `dmax_certBiInfK` and `ladderLift`; it does not assume the inclusion.
- No positionwise completeness clause is stated anywhere in the module (grep).
- If the phase closes `[BLOCKED]`: the goal state reached is recorded in the phase body and in the handoff, with no `sorry`, axiom, vacuous definition, trace-level hypothesis, or finite-fibre retreat anywhere in the tree.

---

### Phase 16: The Fibre Equation `ladderRealized` [NOT STARTED]

**Goal**: Land the fibre equation for ALL `φ`, `box` and `stab` letters included, under the
parameter hypothesis: the cell at an admissible ladder state is exactly the fibre of `Dmax` at that
state's counter class.

**Tasks**:
- [ ] Prove `ladderRealized` as the fibre equation at the pinned signature, `hp` in the recorded
      position: `⊆` by (S) (Phase 13, or its constrained auxiliary on that branch), `⊇` by (C')
      (Phase 15) through `dmax_subset_real`. The world state is `(t, ⟨(q, c, n), h⟩)` on
      `ℤ × LadderState Q pend`; the `ℤ` component is invisible to `cellAt` (`cellAt_eq_cellAt`) but
      must be written.
- [ ] Verify, and record in the proof's docstring, WHERE `hp` is consumed — through
      `real_certAdmK_of_paramsOk` on the `⊆` side and through `cellAt_const_of_kappa_eq` wherever
      a class-equivalent state's cell is read. If the proof appears to close without using `hp`,
      that is a signal the argument has collapsed into the refuted shape: stop and record it,
      because the fourteenth probe's refutation holds for every `kappa` and every candidate `Dmax`.
- [ ] Do not add the parameter hypothesis to `ladderSound`, `ladderLift` or
      `ladderCons_localRun`, and do not remove it from `ladderRealized` or
      `cellAt_const_of_kappa_eq`.
- [ ] State nothing about `HitPresented`, `PlusValidZTime`, or any bound; the enumeration count
      stays a count.
- [ ] Add a one-line consumer-side corollary (or a `#check`) instantiating `ladderRealized` at the
      four defined parameter outputs and discharging `hp` by `paramsOk_params`, so the statement is
      demonstrably non-vacuous at the parameters 763 will use.

**Timing**: 2 hours

**Depends on**: 13, 15

**Verification Tier**: interface

**Tier Justification**: The theorem is the module's public surface and 763 consumes it, so a
guarded scoped build plus the axiom profile and the consumer-side instantiation is the covering
check.

**Scope Hypothesis**: One Goal declaration plus one consumer-side corollary inside
`LadderRealize.lean`; no other file changes in this phase. If `⊆` is unavailable because Phase 13
closed only the constrained auxiliary, consume the auxiliary — `ladderRealized` carries `hp`
already, so that substitution changes no signature — and record it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderRealized and the consumer-side instantiation

**Verification**:
- Guarded scoped build exits 0, 0 warnings; `ladderRealized`'s signature matches the Challenge block token-for-token, by direct `diff` of the extracted signature text — the parameter hypothesis included, in the recorded position.
- `lean_minimal_hypotheses` (or an equivalent check) confirms `hp` is NOT a redundant binder.
- `#print axioms ladderRealized` shows no `sorryAx`, no custom axiom, no `native_decide`.
- `ladderRealized` quantifies over ALL `φ` with no `box`/`stab`-free side condition anywhere in its statement or hypotheses.
- The consumer-side instantiation at the four defined parameter outputs discharges the hypothesis via `paramsOk_params`, so the theorem is not vacuous.
- `anchorCells_finite` and `anchorCells_ncard_le` are unchanged (`git diff` on `AnchorLayer.lean` is empty).
- `bash scripts/check-evidence-probes.sh` exits 0 and the refutation probe still PASSes, unmodified.

---

### Phase 17: Gate 8 — Exercise the `stab` Clause on a `stab`-Bearing Fixture [NOT STARTED]

**Goal**: Gate 8 has been SIDESTEPPED at every round because no fixture's closure has a `stab`
member. Build one and exercise the rebuilt per-`(q, κ)` `certStabK`, so the acceptance clause is
tested and not merely present.

**Tasks**:
- [ ] Author `specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean`: a small object
      whose closure carries a `⊡` member, with the cell computed on both sides of a `κ`-equal
      pair and the `certStabK` biconditional exercised at `(q, κ)` granularity. The `κ`-equal
      pair must be one the parameter conditions ADMIT: a fixture built at parameters `ParamsOk`
      rejects would exercise nothing the repaired statements claim, and `not_paramsOk_allZero` is
      the landed example of a rejected tuple.
- [ ] Exercise `stab_bit_agree_of_certStabK` and `stab_mem_tpOf_iff_cell` on the fixture as well,
      so the two lemmas the obstruction turned on are tested at the granularity they are stated at.
- [ ] Record the verdict in the header — PASSED or a separating pair — with the same discipline
      the gate table uses: non-vacuity witnessed on both sides before any equality is claimed, and
      "a gate probing one coordinate certifies one coordinate".
- [ ] Wire the probe into `scripts/check-evidence-probes.sh` (one table row, one `WIRED` entry).

**Timing**: 1.5 hours

**Depends on**: 16

**Verification Tier**: local

**Tier Justification**: The probe lives outside every Lake target root and imports only landed
modules, so its own `lake env lean` run through the build guard plus the evidence-gate run is the
covering check; no library module changes.

**Scope Hypothesis**: One new probe file and one evidence-script entry. The wired-probe count
rises by one from whatever the gate reports at the start of this phase (44 at this plan's
authoring — 43 `WIRED` plus 1 `WIRED_REPO`, re-counted from `scripts/check-evidence-probes.sh`),
or by two if Phase 13's refuting branch fired: read the count, do not assume it.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean` - new wired probe exercising gate 8
- `scripts/check-evidence-probes.sh` - one table row, one WIRED entry

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean` through the build guard: exit 0, 0 errors, 0 warnings.
- `bash scripts/check-evidence-probes.sh` exits 0 and reports every wired probe PASS, one more than the count read at the start of the phase.
- The header states the verdict and the non-vacuity witnesses; no `native_decide`.
- The fixture's parameters satisfy `ParamsOk` (a proved line in the probe), so the exercised `κ`-equal pair is one the repaired statements actually speak about.

---

### Phase 18: Records, the Full Gate, and the Summary [NOT STARTED]

**Goal**: Make every record say what landed, run the full gate, and close the task.

**Tasks**:
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: one paragraph for the two new
      modules (`LadderAgree.lean`, `LadderRealize.lean`) and the realization result, in the
      record's own terms, with the `Last verified` date; one sentence recording that the two
      factorization-side statements hold under the parameter conditions (K1)-(K4) and why — citing
      the fourteenth wired probe by path; and one sentence recording that the agreement is proved
      at the history level rather than as a corollary of soundness and the lift, and that
      `LadderAgree.lean` is certificate-free by construction. Cite declaration names and
      `specs/evidence/...` paths only — never a `specs/{NNN}_` path (C9) and never a task number.
- [ ] `docs/theorem-index.md`: rows for `ladderRealized`, `cellAt_const_of_kappa_eq`,
      `ladderSound`, `ladderLift`, `ladderCons_localRun`, `real_certAdmK_of_paramsOk` and
      `dmax_subset_real`, plus the amended `ladderModel` row. The two factorization-side rows name
      the parameter hypothesis in their statement cell. Any statement that closed only in a
      constrained or `[BLOCKED]` form is recorded in that form, with the filed statement named as
      open — never as landed.
- [ ] Regenerate `typst/generated/status.typ` (the pre-commit hook will do it; commit the diff
      with this phase and record it).
- [ ] Run the full gate: guarded full `lake build`; `check-evidence-probes.sh`;
      `check-module-invariants.sh`; `readme-lint.sh`; `typst-sync-check.sh`; `verify-deploy.sh`;
      `check-task-references.sh`; `lean-sorry-census.sh`; the axiom count against baseline;
      `validate-artifact.sh` on this plan.
- [ ] Write `summaries/04_ladder-agreement-first-decomposition-summary.md` naming, for each of the
      agreement, (S), `ladderCons_localRun`, (C'), the fibre equation, (K1)-(K4) with the
      parameter hypothesis and its discharge, and gate 8, what was proved and what remains; state
      the forward-only liveness fact in guardrail (e)'s precise sense; name every quantity as a
      count; and record which of the two `hp`-propagation branches Phases 13 and 14 took.

**Timing**: 1.5 hours

**Depends on**: 6, 14, 17

**Verification Tier**: full

**Scope Hypothesis**: Three record files plus the summary. If `typst-status-counts.sh` produces a
diff beyond `status.typ`, stop and inspect rather than committing it blind.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - one paragraph, the parameter-conditions sentence, the agreement-first sentence, Last verified date
- `docs/theorem-index.md` - seven new rows, one amended row
- `typst/generated/status.typ` - regenerated by the pre-commit hook
- `specs/761_ladder_realization_theorem/summaries/04_ladder-agreement-first-decomposition-summary.md` - new summary

**Verification**:
- Full guarded `lake build` exits 0 with 0 `error:` across both captured streams.
- `check-evidence-probes.sh`, `check-module-invariants.sh`, `readme-lint.sh`, `typst-sync-check.sh`, `verify-deploy.sh` all exit 0.
- `lean-sorry-census.sh` count 0; the repository-wide vacuous-definition grep UNCHANGED from the dispatch's starting commit (1 at this plan's authoring: `FormalSystem/Examples/TemporalStructures.lean:495`, where `:= trivial` closes a real goal and the pattern is a false positive); axiom count unchanged from the dispatch's starting commit.
- `check-task-references.sh` reports 0 unexempted occurrences outside `specs/`.
- No new `truncate` / `Fin (B+1)` / clipped-gap occurrence in any touched file outside a sentence naming it as deleted, refuted or research-level.
- The refutation probe is unmodified (`git diff` on it is empty) and still wired and PASSing.
- `LadderAgree.lean` still passes the certificate-freedom grep of Phase 11 (no certificate identifier outside its docstring), so the acyclicity claim is still true of the landed tree.
- `git status --short` shows no stray modified files outside this plan's `Files to modify` set.

## Lean Challenge Statements

The six `theorem` declarations are the Goals and carry `sorry` bodies; they are listed in the order
the phases prove them. Everything above them is supporting context declared with `abbrev`, which
the snapshot tool (`lean-challenge-snapshot.sh`) neither counts as a Goal nor rewrites — but it
DOES swallow any non-`theorem` text that sits between two `theorem` declarations into the
preceding `:= sorry`, so every `abbrev` must precede the first `theorem`. The `abbrev`s pin BY
POSITION ONLY the objects Phases 8-10 define: `ClType` and `certAdmK`, `kappa`, `ParamsOk`,
`Tcof`, `Tnof`, `Pof`, `Bof` and `Dmax` are landed (Phases 8 and 9), and `typeOfCl`, `certChain`
and `LadderCons` are Phase 10's. `CK` is written out, because its five-coordinate shape is forced
by the compiled mechanisms and is part of the contract; its four parameters are OUTPUTS, which is
why they are universally quantified arguments at every use site and never exhibited constants —
and why the two factorization-side theorems constrain them through `ParamsOk` rather than
quantifying over them freely. `ParamsOk`, `Tcof`, `Tnof`, `Pof` and `Bof` take `[Fintype Q]`,
`step`, `pend`, `lab` and `phi` as well as the naturals, matching their landed signatures in
`CounterQuotient.lean`: (K1) quantifies the certificate graph's cycle lengths, (K2) the cascade
bound and the periodicity threshold, and (K4) the formula's `d_back`, none of which a predicate on
four naturals can express. `paramsOk_params` is what makes that hypothesis dischargeable at the
parameters the periodicity fixpoint defines; without it the two statements would be safe but
vacuous. Identifiers are ASCII for the snapshot tool's regex.

This block was compiled standalone at this plan's authoring time through the build guard
(`bash .claude/scripts/lake-build-guard.sh build --timeout 800 -- env lean <file>`): exit 0, zero
errors, exactly eighteen `declaration uses 'sorry'` warnings (twelve `abbrev`, six `theorem`).

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761A

abbrev ClType (phi : PlusFormula) : Type := sorry

abbrev typeOfCl {phi : PlusFormula} : ClType phi -> Finset PlusFormula := sorry

abbrev CK (Tc Tn P B : Nat) : Type :=
  Fin (Tc + 1) × Fin (P + 1) × Fin (Tn + 1) × Fin (P + 1) × Fin (2 * B + 1)

abbrev kappa (Tc Tn P B : Nat) : Nat × Nat -> CK Tc Tn P B := sorry

abbrev ParamsOk {Q : Type} [Fintype Q] (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) (Tc Tn P B : Nat) : Prop := sorry

abbrev Tcof {Q : Type} [Fintype Q] (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) : Nat := sorry

abbrev Tnof {Q : Type} [Fintype Q] (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) : Nat := sorry

abbrev Pof {Q : Type} [Fintype Q] (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) : Nat := sorry

abbrev Bof {Q : Type} [Fintype Q] (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) : Nat := sorry

abbrev certAdmK {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (R : Set (Q × ClType phi × CK Tc Tn P B)) : Prop := sorry

abbrev certChain {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (xi : Int -> Q × ClType phi × CK Tc Tn P B) : Prop := sorry

abbrev Dmax {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat) : Set (Q × ClType phi × CK Tc Tn P B) := sorry

abbrev LadderCons {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (R : Set (Q × ClType phi × CK Tc Tn P B)) : Prop := sorry

theorem cellAt_const_of_kappa_eq {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (hp : ParamsOk step pend lab phi Tc Tn P B)
    (q : Q) (c n c' n' : Nat) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) (t z : Int) :
    cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
      = cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c', n'), h'⟩) z := sorry

theorem ladderSound {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : Int)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q)
    (hs : (sigma.state z).2 = ⟨(q, c, n), h⟩) :
    exists T : ClType phi,
      typeOfCl T = tpOf (ladderModel step pend fwd bwd lab) phi sigma z ∧
      (q, T, kappa Tc Tn P B (c, n)) ∈ Dmax step pend lab phi Tc Tn P B := sorry

theorem ladderCons_localRun {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (R : Set (Q × ClType phi × CK Tc Tn P B))
    (hR : LadderCons step pend lab phi Tc Tn P B R)
    (sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (xi : Int -> Q × ClType phi × CK Tc Tn P B)
    (hproj : forall t, (xi t).1 = (sigma.state t).2.1.1 ∧
      typeOfCl (xi t).2.1 = tpOf (ladderModel step pend fwd bwd lab) phi sigma t ∧
      (xi t).2.2 = kappa Tc Tn P B ((sigma.state t).2.1.2.1, (sigma.state t).2.1.2.2)) :
    certChain step pend lab phi Tc Tn P B xi ∧ forall t, xi t ∈ R := sorry

theorem ladderLift {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (xi : Int -> Q × ClType phi × CK Tc Tn P B)
    (hxi : certChain step pend lab phi Tc Tn P B xi)
    (hmem : forall t, xi t ∈ Dmax step pend lab phi Tc Tn P B)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q)
    (h0 : (xi 0).1 = q) (hk : (xi 0).2.2 = kappa Tc Tn P B (c, n)) :
    exists sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
      (sigma.state 0).2 = ⟨(q, c, n), h⟩ ∧
      tpOf (ladderModel step pend fwd bwd lab) phi sigma 0 = typeOfCl (xi 0).2.1 := sorry

theorem ladderRealized {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (hp : ParamsOk step pend lab phi Tc Tn P B)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q) (t z : Int) :
    cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
      = {T | exists S : ClType phi, typeOfCl S = T ∧
          (q, S, kappa Tc Tn P B (c, n)) ∈ Dmax step pend lab phi Tc Tn P B} := sorry

theorem paramsOk_params {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) :
    ParamsOk step pend lab phi (Tcof step pend lab phi) (Tnof step pend lab phi)
      (Pof step pend lab phi) (Bof step pend lab phi) := sorry

end Probe761A
```

## Testing & Validation

- [ ] The four new library modules (`Certificate.lean` and `CounterQuotient.lean` landed;
      `LadderAgree.lean` and `LadderRealize.lean` new) and the amended `RunLayer.lean` compile
      through the build guard with 0 errors and 0 warnings, scoped per phase and once in full at
      Phase 18.
- [ ] `lean-sorry-census.sh` count 0 over the resolved source roots; the repository-wide
      vacuous-definition grep UNCHANGED from the dispatch's starting commit (baseline 1 at this
      plan's authoring: `FormalSystem/Examples/TemporalStructures.lean:495`, a false positive
      where `:= trivial` closes a real goal — "count 0" is unmeetable for this pattern and is not
      asked for); a MODULE-SCOPED grep over each file this plan creates is count 0;
      `grep -rn '^axiom '` unchanged from the dispatch's starting commit.
- [ ] Per-theorem `#print axioms` on all six Goals: no `sorryAx`, no custom axiom, no
      `native_decide`.
- [ ] The six Goal signatures match the Lean Challenge Statements block token-for-token, verified
      by direct `diff` of the extracted signature text against that block.
      `lean-challenge-snapshot.sh` is NOT a gate here: it refuses with exit 73 once the task's
      status is past `planned`.
- [ ] The parameter hypothesis appears in `cellAt_const_of_kappa_eq` and `ladderRealized` and in
      none of `ladderSound`, `ladderLift`, `ladderCons_localRun`; it is a used binder in both
      proofs; and `paramsOk_params` discharges it at the four defined parameter outputs.
- [ ] **The acyclicity check, re-run on the landed tree**: `LadderAgree.lean` contains no
      certificate identifier (`certAdmK`, `certStabK`, `certBoxK`, `certBiInfK`, `certLocK`,
      `certFwdK`, `certBwdK`, `certChain`, `Dmax`, `ClType`, `LadderCons`) outside its docstring,
      and imports no certificate module other than `CounterQuotient`. The agreement is therefore
      still proved independently of the certificate layer in the landed tree, not only in the plan.
- [ ] No theorem anywhere claims `certAdmK … (Dmax …)`, `certStabK` or `certBoxK` of a union of
      certified sets: only the four monotone conditions survive a union, and `Dmax`'s own
      certification is reached through `Real` (`real_certAdmK_of_paramsOk`,
      `real_subset_dmax`, `dmax_subset_real`).
- [ ] `Realize.lean`'s `SLive`, `SCoh`, `deferGraph`, `bwdDeferGraph`, `Disch`, `DischBwd`,
      `persist` and `snce_iff_of_SCoh_SLive` appear in neither new module outside the docstring
      sentence recording why they do not transfer; the retained backward-liveness condition is
      `certBwdK` over the product carrier.
- [ ] The refutation probe `ladder-unconstrained-parameter-refutation.lean` is unmodified, still
      wired, and still PASSes.
- [ ] `check-evidence-probes.sh` exits 0 with every wired probe PASS, including the new gate-8
      probe (and the soundness-refutation probe, if Phase 13's refuting branch fired).
- [ ] `check-module-invariants.sh`, `readme-lint.sh`, `typst-sync-check.sh`, `verify-deploy.sh`,
      `check-task-references.sh` all exit 0.
- [ ] Guardrail read-through of every header and record paragraph: closure-indexed letters with
      `box`/`stab` bits included; infinite width and no fibre bound; every quantity a count;
      zero debt; the forward-only liveness fact in its precise sense with no
      device-discrimination claim.
- [ ] No tuple index stated at any parameters anywhere in the library (grep for an
      `index x = index y → cellAt x = cellAt y` shape returns nothing outside a docstring naming
      it as refuted).
- [ ] `anchorCells_finite` and `anchorCells_ncard_le` untouched (`git diff` on `AnchorLayer.lean`
      is empty).
- [ ] Every statement that closed in a constrained or `[BLOCKED]` form is recorded as such in
      `docs/theorem-index.md`, in the README paragraph and in the summary, with the filed
      statement named as open — never as landed.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean` (landed — the CK-free certificate layer, promoted from the probes)
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` (landed — CK, kappa, RK, the four parameter outputs, ParamsOk and paramsOk_params, not_paramsOk_allZero, relK, DischPathK, certStabK per (q, kappa), certAdmK, Dmax and dmax_maximal)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` (new — stab_mem_tpOf_iff_cell, the chain-replacement machinery, cellAt_const_of_kappa_eq; certificate-free by construction)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` (new — typeOfCl, certChain, LadderCons, Real, stab_bit_agree_of_certStabK, real_certAdmK_of_paramsOk, real_subset_dmax, ladderSound, ladderCons_localRun, ladderLift, dmax_subset_real, ladderRealized)
- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` (landed — the pin lemma's lift half, nine declarations)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean`, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `scripts/check-module-invariants.sh`, `scripts/nolints.json` (wiring)
- `specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean` (new, wired — gate 8) and `scripts/check-evidence-probes.sh`
- `specs/evidence/seam-gluing-ray-product/ladder-sound-unconstrained-parameter-refutation.lean` (new, wired — ONLY on Phase 13's refuting branch)
- `specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean` (landed, wired, UNMODIFIED — the compiled reason the parameter hypothesis exists)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `docs/theorem-index.md`, `typst/generated/status.typ`
- `specs/state.json`, `specs/TODO.md`
- `specs/761_ladder_realization_theorem/summaries/04_ladder-agreement-first-decomposition-summary.md`
- This plan

## Rollback/Contingency

- Each phase is one to six files and commits per green substep; reverting a phase is reverting
  its commit(s). The new modules are additive: removing a module's import from `RaySummary.lean`,
  `FormalSystem.lean`, the C14 heredoc and the axiom test, and deleting the file, restores the
  tree.
- If a promoted definition does not compile in the library, compare line by line against the
  probe — it is a compiled oracle. Do not re-derive the proof and do not substitute a different
  decomposition (`plan-compliance.md`). Port the missing helper rather than weakening the
  statement.
- **Phase 11 is the first mathematical contingency point**, and it is now the earliest open phase.
  If `cellAt_const_of_kappa_eq` does not close, mark Phase 11 `[BLOCKED]` with the goal state
  recorded, return `partial` with `requires_user_review: true`, and leave Phases 12-18
  `[NOT STARTED]` — every one of them depends on it, directly or transitively, which is the price
  the agreement-first route pays for being acyclic. Never a `sorry`, an axiom, a vacuous
  definition, a trace-level `Presented` hypothesis, a finite-fibre or finite-width assumption, a
  capped ladder, or a positionwise restatement: the positionwise form is refuted, so it is not a
  weaker statement but a false one. A refutation found in the course of the attempt — a seventh
  observable the forced `CK` cannot see — is a COMPLETE and successful outcome if it is landed as
  a compiled separating pair with non-vacuity witnessed on both sides.
- **Phase 13 is the statement-level contingency point.** Its three-branch task list is the
  contingency: refute the unconstrained `ladderSound` and land it as a wired probe; or prove the
  pinned statement; or land `ladderSound_of_paramsOk` under that honest auxiliary name, mark the
  filed statement `[BLOCKED]`, and raise. Adding `hp` to `ladderSound`'s own signature is never
  an implementer's move — it is a change to a recorded Challenge statement, which Statement
  Fidelity routes to the user and to `/revise`. Phase 14 inherits that branch as its own
  `[BLOCKED]` contingency and must not repair it by a `LadderCons` field.
- **Phase 15 is the second mathematical contingency point**, with the same discipline as Phase 11.
  If `ladderLift` does not close, mark Phase 15 `[BLOCKED]` with the goal state recorded and leave
  Phases 16-18 `[NOT STARTED]`.
- If a phase is `[BLOCKED]` but a strictly weaker, honestly named auxiliary did land, record the
  auxiliary in the phase body, in `docs/theorem-index.md` and in the summary with the filed
  statement named as open. A landed auxiliary never promotes the phase out of `[BLOCKED]`.
- If `state-write.sh` is refused three times on the `specs/.scope-lock` mutex, the record phase
  closes `[PARTIAL]` with the record edits committed and the `state.json` step named as the
  remainder; the description amendment is then applied by the next dispatch, never by hand.
- A rollback that would discard uncommitted work takes a snapshot first: see
  `context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
  out-of-scope override for a deliberate whole-tree case.
