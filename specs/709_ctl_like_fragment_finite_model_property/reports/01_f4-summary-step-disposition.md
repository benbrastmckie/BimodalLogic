# Research Report: Task #709

**Task**: 709 - ctl_like_fragment_finite_model_property (F4: finite width implies eventually periodic, as route R1's summary step)
**Started**: 2026-10-17T22:18:38Z
**Completed**: 2026-10-17T22:26:51Z
**Effort**: ~35 minutes (archive reading, kernel verification, no new mathematics)
**Dependencies**: 703, 710, 719 (all archived `completed`); the deciding records are 732 (E3), 736 (E3 re-audit), 711 (substrate), and the `RaySummary/` cluster landed after them
**Sources/Inputs**:
- Task record: `specs/709_ctl_like_fragment_finite_model_property/.dispatch/1.md` (description, fragment, two-outcome contract)
- Deciding probe: `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` (E3, task 732, with the 736 re-audit block in its header)
- Programme records: `specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` (Sections B, D, Ranking ratification); `specs/archive/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md` (R3); `specs/archive/710_sliced_class_incompleteness_characterization/reports/01_sliced-class-incompleteness.md` (F4 as originally argued); `specs/archive/712_lplus_sliced_finite_model_property/summaries/01_sliced-fmp-refutation-record-summary.md`; `specs/archive/711_universal_summary_substrate_stab_fibre/summaries/02_buechi-chain-ktype-substrate-summary.md`; `specs/archive/719_ray_layer_seam_gluing_and_stab_fibre/summaries/01_ray-layer-seam-gluing-stab-fibre-summary.md`; `specs/archive/735_decidable_stab_check_ray_product_assembly/summaries/01_*.md`; `specs/815_certificate_sufficiency_dovetailing_realizability/summaries/01_certificate-sufficiency-dovetailing-summary.md`; `specs/ROADMAP.md` (Stage 0 and Stage 1)
- Library: `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean`, `.../Limits/README.md`, `.../PlusSlicedCertificate/README.md`, `.../PlusSlicedCertificate/FixtureStable.lean`, `.../PlusSlicedCertificate/Live.lean`, `FormalSystem/Metalogic/Decidability/RaySummary/{README.md,Periodic.lean,HitComplete.lean,Seam.lean}`, `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`, `docs/theorem-index.md`
- Literature: `~/Projects/Literature/sources/hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl/chunk_0027.md`, `chunk_0030.md` (Lemmas 17 and 21; corpus entry marked UNVERIFIED-summary); Thomas 1997 via `Periodic.lean`'s own docstring citation
- lean-lsp MCP: `lean_verify` on the three load-bearing theorems; `lean_local_search` (index reported `error`, so its hits are corroborated by direct grep and are not relied on alone); `lean_loogle`; a direct grep of the Mathlib sources at the pin
**Artifacts**: - `specs/709_ctl_like_fragment_finite_model_property/reports/01_f4-summary-step-disposition.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The outcome the task defers to R1 is already decided and recorded.** Probe E3 (task 732,
  `device-selection-probe.lean`, re-audited by 736 with "the selection is UNCHANGED — verdict (i),
  KEEP candidate (d)") selected the **time-axis Ramsey-coloured summary**, candidate (d), framed
  by the MSO-over-`⟨ℤ,<⟩` quasimodel route (c). So the task's outcome (ii) — "R1 selects an
  automaton acceptance condition" — did **not** occur.
- **But outcome (i) as the task wrote it also does not apply, because R1 has already built its
  summary step.** The device R1 needed "must work over the TIME AXIS with a finite alphabet of
  per-time summaries, not over states" (E3's falsifier `not_lasso_sufficient_on_chain`). Its
  periodicity step is landed and kernel-checked: `exists_periodic_fwd` / `exists_periodic_bwd` /
  `exists_periodic_subfamily` (`RaySummary/Periodic.lean`) replace each tail of a colouring of
  `ℤ` by one Ramsey-monochromatic period — the F4 route verbatim, over `(profile, cutProfile)`
  colours of time pairs — and `exists_hitPresented` (`RaySummary/HitComplete.lean`) is the
  completeness row (C) the ROADMAP now calls "a settled theorem". Both verified in this session
  at `[propext, Classical.choice, Quot.sound]`.
- **F4 as this task states it — "every finite-width sliced structure satisfying a target has an
  eventually periodic, hence tail-stable-presentable, model of the SAME width" — is therefore
  consumed by nothing.** R1 carries no width (its only finiteness is `[Fintype Q]` on the
  presentation; `RaySummary/README.md`: "No finite-fibre or finite-width assumption"); the sliced
  class's own route to decidability is closed as a refutation record (712); and the "hence
  tail-stable-presentable" clause is independently undercut by `Fixture.not_tailStable`
  (`FixtureStable.lean`: no member of the re-presentation family is tail-stable), so even a
  proved finite-width periodicity theorem would not reach a certificate without a second,
  unproved step.
- **Recommended disposition: close as a reasoned exclusion**, exactly the honourable close the
  task record pre-authorises, with the trigger corrected: F4 is excluded not because R1 chose an
  acceptance condition, but because R1 chose the Ramsey colour **and landed it in the only form
  it consumes**, retiring the finite-width form. The fallback fragment restriction (safety /
  bounded-step `⊡`) is likewise not needed by any consumer and should not be pursued.
- **A Stage 0 ruling is reserved to the user** (`specs/ROADMAP.md`: "Re-rule on 709's value
  before dispatching it"). This report supplies the evidence and a non-blocking `user_decision`
  recommending the exclusion close; the alternative (pursue the restricted-fragment finite-width
  theorem, 40–80 h, no consumer) is listed for completeness.

## Context & Scope

The task's standing description (second re-scope, 2026-10-03) fixes the question precisely: F4
is a *component* of route R1, sequenced under 719, and resolves one of two ways decided by R1,
not here — (i) R1 selects a Ramsey colour, then F4's theorem is what R1 needs; (ii) R1 selects
an automaton acceptance condition, then F4 is unnecessary and 709 closes as a reasoned
exclusion. The research question is therefore: *what did R1 select, and does the selection
leave this task a theorem to prove?*

Constraints honoured: zero sorries, no new axioms, no vacuous definitions; no width bound
committed; the refuted headline (FMP for the CTL-like fragment against the sliced class) not
attempted; any surviving statement must name its restricted fragment and say why
`not_finite_width_fmp` does not refute it.

Evidence tier: `lean_local_search` reported `index: error` throughout this session, so no
empty result was treated as proof of absence; every declaration cited below was located by
direct file read and the three headline theorems were kernel-checked with `lean_verify`.

## Findings

### Codebase Patterns

**F-1. What R1 selected (High, machine-recorded).** `device-selection-probe.lean` (E3): "the
universal-summary substrate should be built on the TIME-AXIS RAMSEY-COLOURED SUMMARY, candidate
(d) … framed by the MSO-over-`⟨ℤ,<⟩` quasimodel route, candidate (c)". Candidates (a)
Safra/Piterman and (b) Safraless are "not selected". The 736 re-audit falsified two of the
probe's grounds (cslib has McNaughton in the fork and `IsRegular.compl` upstream) and
*raised* the (c)/(d) identification to High — "`IsRegular.compl` is proved THROUGH
`buchiFamily_cover`, which colours a pair of time points by the congruence class of the segment
between them and applies `infinite_graph_ramsey`. That IS candidate (d)'s device" — while
keeping the selection: "verdict (i), KEEP candidate (d)".

**F-2. What R1 then built, and in what shape (High, kernel-verified this session).**

| Declaration | Module | Statement shape | Axioms (measured) |
|---|---|---|---|
| `Nat.exists_strictMono_const_pair_colour` | `ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` | infinite Ramsey for pairs: every `c : ℕ → ℕ → C`, `C` finite, has a strictly monotone `g` with `c (g i) (g j)` constant for `i < j` | `[propext, Classical.choice, Quot.sound]` [CARRIED-UNVERIFIED: 711 summary 01, `lean_verify` row; statement re-read at line 134 of the module this session] |
| `exists_periodic_fwd` / `exists_periodic_bwd` | `RaySummary/Periodic.lean` (lines 970, 1226) | every forward (backward) tail type of a colouring `c` of `ℤ` is realized by a bounded ultimately periodic tail `u · v^ω` (`w^(ω*) · u`) whose tail types are all among `c`'s; lengths `< Nat.card (Profile sig k)^2` | inherits the row below |
| `exists_periodic_subfamily` | `RaySummary/Periodic.lean` (line 1562) | seam assembly: every family triple of `c` (with `now` exactly at `t`) is a triple of a bi-ultimately-periodic `w^(ω*) · m · v^ω` whose triples all lie in `c`'s | `[propext, Classical.choice, Quot.sound]` — verified |
| `exists_hitPresented` | `RaySummary/HitComplete.lean` (line 590, namespace `Decidability.RaySummary`) | for every regular `ℤ`-model, seam, `φ`, depth `1 ≤ k`: a finite presentation with `Fintype.card Q ≤ sizeBound φ k` and `HitPresented M τ t φ lab step k` | `[propext, Classical.choice, Quot.sound]` — verified |

`Periodic.lean`'s docstring describes its proof as "colour pairs of cuts of the forward
factorization by the `(profile, cutProfile)` of the stretch between them, take the monochromatic
strictly monotone subsequence (`Nat.exists_strictMono_const_pair_colour`), replace the prefix and
the first block by bounded representatives … and read every tail type of the periodic word back
into the original tail block by block". That is, step for step, the F4 route the task description
records ("infinite Ramsey for pairs … replace the forward tail by one idempotent-colour period and
mirror for the backward tail"), with the colour taken on **profiles of time-axis stretches**
instead of on `(E, lab, fwdLive, bwdLive)` strong slice states of a finite-width structure. The
backward mirror is literally the forward theorem on the reflected colouring
(`mem_bwdTypes_iff_reflect`, `kTypeOf_listSeg_reverse_congr`).

**F-3. F4's two "forced repairs to HWZ" are already carried, in R1's form.** The task's
description names them as the substance of the work:
- *One-sided live sets must be recorded* — in R1 this is not a repair but the shape of the
  fibre: `plusStab_iff_omega` (`PlusLanguage/PlusRayFibre.lean`, landed by 719) presents the
  `⊡` fibre as the product of a backward and a forward ω-sequence, and 718's R3 verdict already
  said "one-sided live sets are the only kind there are in the right presentation". The
  quasistate-splice hazard (HWZ Lemma 17 creating a realized type the model lacked) is named in
  `RaySummary/Seam.lean`'s docstring, point (d), and carried as the joint-realization obligation
  (`Presents.realized`; at the Hit level, `HitCl` is defined over the seam's actual ray pairs,
  `hitCl_eq_iUnion`).
- *Fulfilment within one period for every live position at once* — this is what the
  `(profile, cutProfile)` colour buys: `profile_flatten_congr` reads every tail type back block by
  block, and the cut profile "is exactly what the cut-pair obstruction of `Profile.lean`'s
  docstring carries across". HWZ Lemma 21's successive splicing is not used; its finite analogue
  is described in HWZ's own text as needing "a somewhat subtler deleting technique" (corpus
  chunk_0038), which is the gap the task description calls risk R3 — closed here by composing
  profiles rather than splicing quasistates.

**F-4. What is NOT in the tree, and is still correctly described as absent.** The finite-width
statement — a finite-width `FrameOver.ofSlicedStep` model of a target has an eventually periodic
model *of the same width* — is formalized nowhere; `Limits/README.md`'s closing paragraph says so
("sufficiency — every finite-width model has an eventually periodic, hence tail-stable-presentable,
finite-width model — is a Ramsey-for-pairs-style periodicity argument not formalized anywhere in
this tree"). That sentence remains literally true after `Periodic.lean`: the landed theorem is
about colourings of `ℤ`, not about sliced structures and their width. The sentence is however
now *misleading* in one respect — the Ramsey-periodicity argument **is** formalized, just not
for finite-width structures — and should be amended (Recommendation 3).

**F-5. Nobody consumes the finite-width form (High).**
- R1 / Stage 1: `RaySummary/README.md`, "What it does not do": "No finite-fibre or finite-width
  assumption. Everything is over the time axis with a finite alphabet of per-time letters under
  `[F.IsRegular]`; the only `[Finite W]` anywhere is the counterexample fixture's licence." The
  ROADMAP's Stage 1 guardrails repeat "no finite-fibre or finite-width assumption". The live
  critical path (761 ladder realization over `cohBi`, then 763 the lift) is over `LadderState`,
  an explicitly *infinite* admissible carrier.
- The sliced class: its decidability route is "closed as a refutation record" (712), and its
  three live tasks (714 full-label evaluation, 781 Phase 5 hoist, 782 Shape D cache) are
  checker-internal performance and design decisions that do not read a width-level model
  property. The relative completeness theorem it does have,
  `exists_plusSlicedCertificate_of_tailStable_countermodel` (`Complete.lean`), takes
  tail-stability as a hypothesis, and `Fixture.not_tailStable` shows re-presentation does not in
  general supply it — so F4's "hence tail-stable-presentable" would need an unproved bridge.
- R2 (mosaics, 734) is `[HOLD]` by ruling and is a *consumer* of R1, not a reader of a width
  theorem.

**F-6. The premise is refuted inside the target fragment (High, kernel-verified this session).**
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`
(the 720 promotion of `Probe710.not_finite_width_fmp`; `[propext, Classical.choice, Quot.sound]`)
with witness `Φ := (A' ∧ C') ∧ D` in the CTL-like fragment. So any finite-width statement must
name a strict sub-fragment, which is the task's fallback restriction (safety / bounded-step
`⊡`). That restriction is *stateable*, but by F-5 it has no consumer either, and no in-tree
fragment predicate exists for it: the only landed fragment predicate is
`PlusFormula.BoxStabFree` (`PlusLanguage/Subformulas.lean:291`), used by `Realize.lean`, which
is a different and smaller fragment.

**F-7. The prior "task 709" commits are a different task.** `git log` shows three 2026-01-28
commits labelled task 709 (`reports/research-001.md`, `plans/implementation-001.md`, an edit to
`Boneyard/.../Soundness.lean`). Those predate the vault renumbering and use the old artifact
naming scheme; the current record has no artifacts (`artifact_number: 1`) and nothing of that work
bears on F4.

### External Resources

- **Mathlib at the pin (`v4.33.0-rc1`)**: a direct grep of `.lake/packages/mathlib/Mathlib` for
  "ramsey" hits five files — an author name (`RingTheory/Bialgebra`, `Coalgebra`, `HopfAlgebra`)
  and the Hales–Jewett / Hindman modules — none of which is infinite Ramsey for pairs; `loogle
  "ramsey"` returned nothing. This re-confirms E3's ground (1) and 711's reason for carrying the
  theorem in `ForMathlib/`.
- **HWZ 2000** (corpus, UNVERIFIED-summary provenance; passages read directly): Lemma 17
  (chunk_0027) is the splice `f^{≤n} ∗ f^{>m}` of a quasimodel at equal quasistates with runs
  `r₁^{≤n} ∗ r₂^{>m}` for `r₁(n) = r₂(m)`; Lemma 21 (chunk_0030) realizes every `U`-formula of a
  quasistate "in `|f₀|` steps" by repeated Lemma 17 splicing, one eventuality at a time. Both are
  the devices the task's "two repairs" paragraph names; see F-3 for how the tree sidesteps them.
- **Thomas 1997, §5.1** — cited by `Periodic.lean` as the Ramsey route to ultimately periodic
  witnesses, "re-proved here for the finitely many conditions `L_α L_σ^ω` through the profile,
  with no automaton" [CARRIED-UNVERIFIED: `RaySummary/Periodic.lean` module docstring; the
  corpus chunks I located for "ultimately periodic" (chunk_0024/0025) are the Cobham passage,
  not §5.1].
- **cslib** (per the 736 re-audit recorded in E3's header): `Cslib.ωLanguage.IsRegular.compl`
  upstream, proved through `buchiFamily_cover` + `infinite_graph_ramsey`; McNaughton
  (`IsRegular.iff_da_muller`) term-proved in the fork only; zero MSO. Not a dependency of this
  repository (`grep Cslib lakefile.toml lake-manifest.json` empty per 711's summary) and not
  needed by the recommendation.

### Recommendations

1. **Close 709 as a reasoned exclusion** (the task record's pre-authorised shape): a plan with a
   single phase marked `[COMPLETED WITH EXCLUSIONS]` whose `#### Reasoned Exclusions` table
   records, at minimum:

   | Item | Reason | Evidence |
   |------|--------|----------|
   | F4, finite-width form: "every finite-width sliced structure satisfying a target has an eventually periodic, tail-stable-presentable model of the same width" | R1 selected the Ramsey colour (not an acceptance condition) and landed its summary step over the time axis with no width; the finite-width form is consumed by no route, and its premise is refuted for the fragment at large | E3 selection + 736 re-audit (`device-selection-probe.lean` header); `exists_periodic_subfamily`, `exists_hitPresented` at `[propext, Classical.choice, Quot.sound]`; `RaySummary/README.md` "no finite-width assumption"; `not_finite_width_fmp`; `Fixture.not_tailStable` |
   | Fallback fragment restriction (safety / bounded-step `⊡`) | The restriction was the alternative *under outcome (ii)*, which did not occur; under the actual outcome it has no consumer either | F-5; ROADMAP Stage 1 "proceeds on R1 alone; there is no fallback" |
   | The refuted headline (FMP for the CTL-like fragment against the sliced class) | Refuted as a theorem; must not be attempted | `not_finite_width_fmp`, `not_sliced_complete` (`Limits/NoFiniteWidth.lean`) |

   This satisfies the five-condition admission test in `status-markers.md`: it is a decision,
   tightly enumerated, reasoned, evidenced by kernel-checked declarations, and leaves no residual
   work. Task-level status is then `[COMPLETED]` (the exclusions marker is phase-heading only).
2. **Do not pursue the restricted-fragment finite-width theorem** (the task's 40–80 h estimate).
   Reasons: no consumer (F-5); the conclusion as phrased needs the unproved periodic→tail-stable
   bridge that `FixtureStable.lean` warns against; and the mathematics it would exercise
   (Ramsey over a composing colour, one period per tail) is already in the tree in the form the
   programme reads. If a future consumer appears, the right statement is a *corollary* of
   `exists_periodic_subfamily` over the label colouring of a sliced structure's run, not a new
   Ramsey argument — file it then, research-first, against that consumer.
3. **One durable library edit is warranted and small**: amend the closing paragraph of
   `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` ("a
   Ramsey-for-pairs-style periodicity argument not formalized anywhere in this tree") to say that
   the periodicity argument *is* formalized over time-axis colourings (`exists_periodic_subfamily`,
   `RaySummary/Periodic.lean`) and that only its transfer to finite-width sliced structures of the
   same width is not — and that nothing consumes that transfer. This keeps the README's
   "argued, not proved" characterisation honest without over-claiming. No `.lean` file changes.
4. **ROADMAP hygiene for the planner, not this task to decide**: the Stage 0 bullet "Re-rule on
   709's value" can be resolved by the user on this report; the Phase 2 framing the task
   description quotes as stale was already corrected conditionally. The plan should propose the
   two-line ROADMAP edit and leave the ruling checkbox to the user.

## Literature Proof Structure

**Source**: Hodkinson–Wolter–Zakharyaschev, *Decidable fragments of first-order temporal
logics*, APAL 106 (2000), Lemmas 17 and 21 (corpus chunks 0027, 0030; UNVERIFIED-summary
provenance); Thomas 1997 §5.1 as cited by `Periodic.lean`.
**Strategy**: Ramsey-for-pairs extraction of an ultimately periodic witness from an infinite
run, with splicing at equal summaries.

### Step Map (F4 route as filed → what the tree does)
1. Summarise each time (or each stretch) by a finite colour — [HWZ] quasistate; [F4] strong
   slice state `(E, lab, fwdLive, bwdLive)` plus `R_{s,t}`; [tree] `(profile, cutProfile)` of the
   stretch, `Profile.lean`.
2. Colours compose along concatenation — [F4] `R_{s,u} = R_{s,t} ; R_{t,u}`; [tree]
   `profile_append_congr`, `profile_flatten_congr`.
3. Infinite Ramsey for pairs yields a monochromatic strictly monotone time sequence — [tree]
   `Nat.exists_strictMono_const_pair_colour`, applied in `exists_blocks_fwd`.
4. Replace the forward tail by one period — [HWZ] Lemmas 17 + 21 (splice, then successive
   splicing per eventuality); [tree] `exists_periodic_fwd`, with bounded representatives
   (`exists_rep_of_length_lt`) and block-by-block read-back.
5. Mirror for the backward tail — [tree] `exists_periodic_bwd` via `reflectColouring`.
6. Assemble at the seam — [tree] `exists_periodic_subfamily`; present as a finite gadget —
   `exists_hitPresented`.

### Dependencies
- Step 4 depends on 1–3; step 5 on 4 by reflection; step 6 on 4 and 5.

### Potential Formalization Challenges
- Already resolved in the tree: the subset direction (task risk R3, "period segments must
  compose into a fulfilling path") is the cut-profile transport; the one-sided live-set repair is
  the product fibre (`plusStab_iff_omega`). The *unresolved* item — transferring the periodic
  colouring back to a sliced structure of the same width — is exactly the statement no consumer
  reads.

## Decisions

- **D-1.** The task's two-outcome contract is read as the task intends — "which way is R1's
  decision" — and R1's decision is taken from E3 and the landed substrate, not re-litigated.
- **D-2.** The disposition is reported as a reasoned exclusion with a corrected trigger rather
  than forced into outcome (i) or (ii) verbatim; the task record itself says a result that
  "retires this component is as much a result as proving it".
- **D-3.** No Lean was written. The report's claims about the library rest on `lean_verify`
  results obtained this session and on direct file reads; nothing is carried from a summary
  without a mark.
- **D-4.** A non-blocking `user_decision` is raised because `specs/ROADMAP.md` reserves the
  value ruling on 709 to Stage 0 (user-only). Proceeding on the recommendation (a record-only
  plan) is reversible, so the loop need not stop.
- **D-5.** The tactic survey protocol was not invoked: there is no proof goal.
- **D-6.** No `.orchestrator-handoff.json` is written; the outcome returns through
  `.return-meta.json` only.

## Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| R-1 | A future consumer of a width-level periodicity statement appears (e.g. a sliced-class fragment completeness theorem for 714's full-label variant) | Low | Recommendation 2 names the right shape (a corollary of `exists_periodic_subfamily`), and the Limits README amendment (Rec. 3) leaves a pointer where that reader would look |
| R-2 | The exclusion is read as abandoning the CTL-like fragment question | Low | The table's third row records the refuted headline explicitly, with its theorem; the fragment's decidability lives in Stage 1 (R1), not here |
| R-3 | E3's selection is later reopened (736 already reopened and re-closed it) | Low | The exclusion's evidence is the *landed* substrate, not the selection alone; a reopening would have to retire `Periodic.lean`, which nothing proposes |
| R-4 | `lean_local_search` index was in `error` state during this session | None for the findings | Every cited declaration was read from its source file and the three headlines were kernel-verified |

## Tactic Survey Results

- Not applicable (no tactic survey performed — the task resolves without a proof goal).

## Context Extension Recommendations

- **Topic**: The reasoned-exclusion close for a *component* task whose parent route delivered
  the component in a different form.
- **Gap**: `status-markers.md` and `plan-format.md` document exclusions for items "not
  applicable"; the case "delivered elsewhere, in the consumed form" is the same mechanism but is
  not named, so a future agent may hesitate between `[COMPLETED WITH EXCLUSIONS]` and `[ABANDONED]`.
- **Recommendation**: one sentence in `context/standards/status-markers.md`'s
  `[COMPLETED WITH EXCLUSIONS]` subsection naming "superseded by a landed declaration" as an
  admissible Reason with the declaration as Evidence.

## Appendix

- Kernel checks run this session (`lean_verify`, `scan_source: true`, no warnings):
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`;
  `FormalSystem.Metalogic.WeakCanonical.exists_periodic_subfamily`;
  `FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented` — each
  `[propext, Classical.choice, Quot.sound]`, trust `standard`.
- Searches: `lean_local_search` for `Nat.exists_strictMono_const_pair_colour` and
  `exists_plusSlicedCertificate_of_tailStable_countermodel` (index `error`; both corroborated by
  grep); `lean_loogle "ramsey"` (empty); `grep -ril ramsey .lake/packages/mathlib/Mathlib` (5
  files, none Ramsey-for-pairs); `literature-search.sh` returned `degraded: true` with no results,
  so corpus passages were located by direct grep of the chunk files.
- Retained machinery references from the task description, re-read this session:
  `exists_plusLabelledLasso_of_history_realized` (`PlusWitnessFamily/Compression/Extract.lean`,
  statement begins immediately after the docstring closing near line 261
  [CARRIED-UNVERIFIED: task description's `:261`]); `AUFix.lfp`
  (`WitnessFamily/Sharing/Fulfil.lean`, near line 242 [CARRIED-UNVERIFIED: task description's
  `:242`]). Neither is consumed by the recommendation.
- Issue log: one `win` entry recorded during this dispatch (the disposition was fully determined
  by archived records; no new mathematics was required).
