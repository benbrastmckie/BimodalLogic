# Follow-Up Scope Specification

Written by this task's implementation round (plan `02_route-probes-and-handoff.md`, Phase 7),
recording what the round's five machine-checked probes actually proved and handing the
consequences to the tasks they belong to. This file is a specification for the orchestrator or
the user to action via `/revise` and `/task`; it files nothing itself and edits no other task's
state.

## Section 1 — Revised deliverables for the ray-layer/seam-gluing follow-up task

Task 719 ("Ray layer seam gluing and stab fibre") carries five deliverables, filed before this
round's probes landed. Four of its deliverables are now informed by proved results, not open
questions:

- **Deliverable 1 (the one-sided ray layer) is ANSWERED, not merely assessed.** Rays are
  definable directly as a `PartialHistory` with a half-line domain: `specs/evidence/seam-gluing-
  ray-product/stab-fibre-is-ray-product.lean`'s `Probe718.PastRay`/`Probe718.FutRay` are built
  exactly this way (a dependent function on `{x : F.Duration // x ≤ t}` / `{x // t ≤ x}`, with
  the all-pairs task constraint), needing no new type beyond the subtype construction. The
  colimit-of-bounded-`Beh F l`-sections route is **not forced** — it is the route that would
  incur *Saturation* (per `app:gluing`'s footnote and its `D = ℚ` counterexample, where the
  restrictions of `τ(t) = 1 - t` to `(0, b]` for `b < 1` form an increasing chain whose union
  admits no value at time `1`). Task 719 should drop that investigation for the ray layer itself
  and leave the directed/colimit case where it already belongs: task 565 ("Totality and Directed
  Gluing"), which owns the *Saturation*-dependent case by charter.
- **Deliverable 3 (the stab-fibre characterisation) is PROVED, not open.** `Probe718.
  seamFibreEquiv` (general task frame, any duration) and `Probe718.seamOmegaEquiv` (ω-sequence
  form over ℤ) are both machine-checked, sorry-free `Equiv`s establishing exactly the fibre-
  product statement Deliverable 3 asks for, using only *Compositionality* and the reflection
  convention — no *Saturation*, no extension theorem, no `Classical.choice` beyond the ambient
  propositional axioms every declaration in this repository already carries. Task 719's job for
  this deliverable becomes **promoting** `seamFibreEquiv`/`plusStab_iff_rays`/`seamOmegaEquiv`/
  `plusStab_iff_omega` into `FormalSystem/` (as a module under the categorical-structure topic,
  connected to task 566's limit presentation `H_F ≅ lim Beh(F)(2x)`), not re-establishing the
  characterisation from scratch.
- **Deliverable 2 (the seam-gluing operator, `⌢_z`) is ALREADY LANDED at the general frame,
  under a different name.** `FormalSystem/PlusLanguage/PlusPasting.lean`'s `paste` (with
  `paste_rel`, `paste_agreeFrom`, `paste_agreeUpTo`) is exactly the paper's `⌢_z`: given two
  total histories agreeing at a seam time, it produces the history following the first up to the
  seam and the second from it, by *Compositionality* alone — choice-free, confirmed directly by
  this round's `specs/evidence/seam-gluing-ray-product/mosaic-germ-amalgamation.lean`, which
  consumes `paste` without needing `Classical.choice` for the binary case (`amalgamate`,
  `amalgamate_unique`). Task 719's remaining content for this deliverable is therefore narrower
  than filed: the **ray-layer-specific** operator (gluing a past ray and a future ray, rather
  than two total histories) plus its uniqueness clause — which `Probe718.glue` in the promoted
  keystone probe already constructs and `seamFibreEquiv`'s `left_inv`/`right_inv` already proves
  unique. Task 719 should connect/promote this rather than re-deriving `paste` or `glue`.
- **Deliverable 4 (the effective extension theorem) is REACHABLE, with its limit stated.** The
  binary seam gluing (`Probe718.glue`) produces a total history from a **pair of rays** — not
  from an arbitrary `PartialHistory`, which is what the general `Semantics/Extension.lean`
  Extension Theorem (Zorn plus `Classical.choice`) handles. This generalises the bi-lasso Tier A
  effective extension theorem's *role* (an effective, choice-free construction replacing a Zorn
  argument) without *subsuming* the general Extension Theorem, whose domain is a wider class of
  partial inputs than a pair of half-line rays. Task 719 should state this limit explicitly
  rather than claiming full subsumption.
- **Deliverable 5 (the decidable-check connection)** is unaffected by this round's probes beyond
  what this round's R1/R2 probes already demonstrate about it (see Section 3): the existential/
  universal divergence (`path-quantifier-alternation.lean`) confirms that *some* universal
  summary device is needed once the stab fibre is presented as a path space, which is Deliverable
  5's own question, but settles nothing about whether Safra/Piterman determinization specifically
  is the needed device.

**Action required**: this is a revision of task 719's filed scope, to be made via `/revise 719`
by the orchestrator or the user — not applied by editing `specs/state.json` here, per this round's
Decision 8 (no state write while a sibling task is concurrently dispatching on this shared tree).

## Section 2 — New-task specification: promote the two FMP/width refutations into `FormalSystem/`

**Proposed title**: Promote the ℤ-time finite-carrier and finite-width FMP refutations into
`FormalSystem/`

**Proposed `task_type`**: `lean4`

**Proposed dependencies**: Task 706 (`L⁺ finite model property and completeness`, owns
`Probe706.no_finite_carrier_sat`) and Task 710 (`sliced class incompleteness
characterization`, owns `Probe710.not_finite_width_fmp`) — both must be past their own
implementation/archival point before their probe files are moved, since the two are currently
cited by this round's `WIRED_REPO` entries at their task-directory paths, each with that live-
task ownership as the recorded blocker (`scripts/check-evidence-probes.sh`).

**Proposed `file_scope`**: `specs/evidence/seam-gluing-ray-product/` (two new promoted probe
files), `scripts/check-evidence-probes.sh` (convert the two `WIRED_REPO` entries to `WIRED`),
`FormalSystem/Metalogic/Decidability/FMP/README.md` (cite the promoted paths once moved).

**Description** (for the filed task): move `Probe706.no_finite_carrier_sat` (currently at
`specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`) and
`Probe710.not_finite_width_fmp` (currently at `specs/710_sliced_class_incompleteness_
characterization/probes/NoFiniteWidthModel.lean`) into `specs/evidence/seam-gluing-ray-product/`,
following this round's Phase 1 promotion procedure exactly (`git mv`, correct the file's own
`lake env lean` header path, convert the `WIRED_REPO` entry to `WIRED`, confirm no outside
citation breaks). `FormalSystem/Metalogic/Decidability/FMP/README.md`'s "The finite-carrier route
is refuted, not merely open" subsection (added by this round's Phase 6) already cites both
theorems by declaration name and should have its citation re-pointed to the new paths once moved.

**Action required**: file with `/task`, by the orchestrator or the user.

## Section 3 — The determinization-funding decision: settled, with evidence attached

The user's answer, recorded verbatim in this task's `.decisions.json`:

> Revive 711 only after R1's falsification probes 1-3 land, so determinization is funded on
> evidence of necessity rather than expectation

This round executed exactly that sequence: Phase 2 (probe 1, stratification), Phase 3 (probe 2,
finite-graph reachability), and Phase 5 (probe 3, path-quantifier alternation) all landed, in
that order, before any determinization-funding action was taken.

**What Phase 5 actually showed**: on the shared fixture (a total, hence genuinely branching,
step graph on `Bool`), `Probe718PathQuantifier.exists_ne_stab` and `exists_ne_universal` prove
that the existential (nondeterministic) per-path summary is `True` everywhere while the real
`⊡(Fp)` value is `False` everywhere (`decide_will`) — an elementary, finite, non-automata-
theoretic divergence. **Verdict: necessity demonstrated for this fragment.** A universal,
complementation-shaped summary is genuinely required; a nondeterministic one is unsound. This is
evidence *for* the ω-automata determinization route being the right shape of device, not proof
that Safra/Piterman determinization specifically is required, and it commits to no complexity
bound.

Per the decision's own terms, this is evidence of necessity, not a funding action. Reviving task
711 (the blocked ω-automata determinization substrate record) remains a filing/status action for
the orchestrator or the user to take in light of this evidence; this round funds nothing and
begins no determinization mechanization anywhere in its own scope.

## Section 4 — Author-facing items verified but not actioned

Two items this round verified against the paper repository (`~/Philosophy/Papers/PossibleWorlds/`)
have cheap, accurate updates available there, but this round wrote nothing inside that
repository, per its own instruction (research round reads the paper repository; it does not
create tasks, write artifacts, or commit anything inside it):

1. **The paper's own FMP subsection** (`JPL/metalogic.tex`) could note that the ℤ-time,
   finite-carrier case of its open FMP question is now refuted in this repository
   (`Probe706.no_finite_carrier_sat`, `Probe710.not_finite_width_fmp`), with the stated scope
   limits (discrete frames; witness formulas as recorded in this round's Phase 6 README
   correction).
2. **The `app:gluing`-not-yet-formalized sentence** (`JPL/possible_worlds.tex`) could note that
   `app:gluing`'s binary seam case is now formalized in this repository (`Probe718.
   seamFibreEquiv`/`glue`, pending promotion per Section 1), even though the general directed
   case remains open pending task 565.

Separately, `docs/reference/paper-definitions-of-record.md`'s pinned record of `def:BX` still
reads `SU` where the paper's live working tree has renamed the axiom to `US` (in both the schema
list and the Burgess A3a attribution footnote). This drift is invisible to CI because the paper
repository is out of tree there; it has its own documented re-quote-and-re-hash procedure. This
round records the drift; it does not re-pin the record.

Nothing inside `~/Philosophy/Papers/PossibleWorlds/` was written by this round.

## Ranking ratification

As amended by what Phases 2–5 actually proved (all positive; no refutation landed):

- **R1 (seam-gluing ray product + ω-automata determinization) stays first.** Stratification
  (Phase 2) and the forward finite-graph reachability characterisation (Phase 3) both landed
  positive — no obstruction was found at either of R1's two cheapest test points. Phase 5 then
  demonstrated that *some* universal-summary device is necessary on the shared fixture, which is
  evidence for R1's remaining content (ω-automata determinization) rather than against it.
- **R2 (mosaics/quasimodels) stays second, as the fallback.** Its amalgamation precondition is
  now confirmed free (Phase 4) via the already-landed `paste`, but the `⊡`-saturation
  decidability question — the actual content a mosaic method would need — is fixed as a
  statement (`StabSaturated`) and left open beyond the one same-state corner this round proved
  for free. The literature evidence gap (Hodkinson–Reynolds Handbook chapter's Mosaics/Monodic-
  fragments sections, table-of-contents only) also still stands, so R2 cannot be promoted above
  R1 on either formal or textual grounds.
- **R3 remains a component of R1**, as the original research found; nothing in Phases 2–5
  reopens that demotion.
- **R4 (task-coherence-preserving filtration) stays closed for ℤ-time**, now with its closure
  recorded in the library itself (Phase 6's `FormalSystem/Metalogic/Decidability/FMP/README.md`
  correction), not only in this task's research report.
- **R5 stays unfunded.** Nothing in this round's probes bears on R5.

No phase's outcome forced a ranking change. Had Phase 3 refuted R1 (the route-killer test this
round flagged as the real risk), this section would instead promote R2 and mark R1's remaining
work out of scope — that contingency did not arise.

## State-write disclosure

No write was made to `specs/state.json` or `specs/TODO.md` by this task's implementation round.
A sibling task (563) is dispatching concurrently on this same shared working tree this cycle;
per this round's Decision 8 and the dispatch's own territory contract, task-filing and task-
revision actions (Sections 1 and 2 above) are left for the orchestrator or the user to action via
`/revise` and `/task`, not applied here.
