# Implementation Plan: Hit-level completeness (C) — land `HitPresented` on fixture model A, record the bound as blocked

- **Task**: 745 - Requirement (C) of the ray-product verdict: Hit-level completeness with a computable bound -- settle HitPresented first
- **Status**: [IMPLEMENTING]
- **Effort**: 11 hours
- **Dependencies**: None ((S) is an independent sibling record; (W) depends on both and is not attempted here)
- **Research Inputs**: `specs/745_hit_level_completeness_computable_bound/reports/01_hit-level-completeness-probe.md`
- **Artifacts**: plans/01_hit-presented-model-a.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Phase 1 of the record (settle `HitPresented`) returned a non-refutation: the Hit-level
hypothesis survives on fixture model A, because the realization demand at the Hit level is a
demand on finitely many `k`-type triples rather than on the seam's trace set, so the
pigeonhole/pumping argument that refuted `Presented` (`Probe735.not_presented`) has nothing to
bite on. This plan executes the positive construction the research specified: state
`HitPresented` in the library beside `Presented`, and land a wired evidence probe establishing
`∃ L, HitPresented MA stayA t Fp (labOf L) (stepOf L) k` for every `t` and every `k ≥ 1`, through
a truncation argument off `hitCl_finite` plus an explicit `L + 6`-state presentation whose
anchored runs have exactly the truncated trace set.

The bound half is recorded as BLOCKED, not attempted. The truncation argument extracts `L` from
`Set.Finite.bddAbove`, i.e. from `Classical.choice`, so it yields no bound at all — which the
headline's `∃ L` shape states rather than conceals. Per the user's cycle-1 decision, the
obstruction is recorded as (i) the landed theorem's axiom foot, and (ii) a stated-but-unproved
Challenge signature for the missing effective block-type saturation lemma, in place of a literal
machine-check of non-existence (not a Lean-statable property). Definition of done: `HitPresented`
and `hitPresented_of_presented` in `Trace.lean` with axiom pins and a theorem-index row; the probe
`specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` compiling sorry-free and wired
into `scripts/check-evidence-probes.sh`; the README's verdict updated to record (C)'s fixture-level
status without retiring task 735's verdict or probe; zero sorries; no decidability claim anywhere.

### Research Integration

Findings integrated, each re-resolved BY NAME in the report and confirmed by compiled `#check`:

- **The route**: truncation off `hitCl_finite` + `hitCl_eq_iUnion` + `mem_hitOf_iff` (run-existence
  form). `mem_hitOf_iff_live` and any `pathTypesNow`/`fwdLiveSep`/`bwdLiveSep` reasoning is
  deliberately NOT used (report D-2/D-3); no `kTypeOf` is ever evaluated and no `decide` over
  `KType` is run.
- **The already-compiled part**: the model-A step-path classification (`stepA`, `time_eq`, `bwd_a`,
  `fwd_dichotomy`, `fwd_absorb`, `path_classify`) compiles clean at ~100 lines. Phase 2
  transcribes it from the research dispatch's scratch file
  `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/9b704637-8466-49f5-bdeb-3bd3ef0521bb/scratchpad/rigid745.lean`.
  `HitPresented`'s definition and `hitPresented_of_presented` also already compile
  (`verify745.lean`, same directory), with axioms `[propext, Classical.choice, Quot.sound]`.
- **The presentation**: `Q := Fin 3 ⊕ Fin (L + 3)`, `Fintype.card Q = L + 6`. Gadget 1 realizes
  `stayA`'s trace; gadget 2 realizes `jump w` for `t ≤ w ≤ t + L`. No step crosses the summands.
  `IsRun`'s own `↔` at `z = t` excludes the never-reaches-`now` run, so no acceptance condition is
  needed. `lab` is an explicit flag table (`labOf`), not `decide` of `clTrace` (report D-4).
- **The one uncompiled link**: the run characterization (research phase 5, this plan's phases 5-6)
  is the single Medium-confidence step. It is split across two phases so the presentation data
  lands green and committed before the run characterization is attempted.
- **What does NOT generalize** (report finding 6, D-6): model A's splices are eventually constant
  in both directions, which is exactly what lets a finite presentation realize finitely many of
  them exactly. The general route needs one lasso per triple and its `⊆` direction is open. The
  probe header states this.
- **Where the bound dies** (report finding 5): `L` comes from `Set.Finite.bddAbove` over `HitCl`.
  The entry point for an effective bound that IS in the tree is `kTypeOf_listSeg_append_congr`;
  the eventual-periodicity/threshold consequence is NOT (`KTypeSummary/Saturation.lean` holds only
  `kTypeColouring_eq_of_matching_segments`, `kEquiv_zFiber_of_matching_segments`,
  `kTypeOf_zFiber_eq_of_sameTriple`, `kTypeOf_zFiber_eq_of_inFamily`, all about ℤ-fibres of a
  given factorization). Medium confidence (grep-tier negative claim).

Plan-time addition, not carried from the report: all 17 identifiers under
`## Lean Challenge Statements` below were compile-checked as a single module against the live
build (`lake env lean`, 16 `sorry` warnings, zero elaboration errors), so every pinned signature
is type-correct before the first implementation dispatch.

### Prior Plan Reference

No prior plan. This is round 1.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and `roadmap_flag` is absent, so no roadmap
phases are added and `specs/ROADMAP.md` is not read or written by this plan. The record's own
framing places it as requirement (C) of the ray-product verdict, with (S) an independent sibling
and (W) downstream of both.

### Carried-Figure Discipline

Figures repeated from the research report are marked where they are not re-derived at plan time:

| Figure | Source | Status |
|---|---|---|
| `presented-not-complete.lean` is 292 lines (the record cites 246) | report, Appendix | RE-DERIVED at plan time: `wc -l` = 292 |
| `Probe745.path_classify` and friends compile at ~100 lines | report, Appendix | RE-DERIVED at plan time: the scratch file exists and is 5493 bytes / ~140 lines including header |
| `(plusSubformulaClosure Fp).card = 4`, so `(clSig Fp).preds` has 5 letters | report finding, `#eval` | CARRIED-UNVERIFIED (report's `#eval`); Phase 5 re-derives it before writing `labOf` |
| `Saturation.lean` holds no block-length threshold lemma | report finding 5, grep sweep | CARRIED-UNVERIFIED, Medium confidence; Phase 8 re-greps before writing the bound verdict |
| Research effort estimate 550-800 Lean lines | report, Recommendations | CARRIED; this plan's per-phase Scope Hypothesis lines restate it as confirmable hypotheses |

## Goals & Non-Goals

**Goals**:
- `HitPresented`
- `hitPresented_of_presented`
- `RA`
- `RA_fwd`
- `RA_bwd`
- `instFARegular`
- `MA`
- `stayA`
- `jump`
- `path_classify`
- `splice_classify`
- `hitCl_eq_truncated`
- `labOf`
- `stepOf`
- `runTrace_mem_of_isRun`
- `exists_isRun_runTrace`
- `hitPresented_modelA`

**Goals, stated in prose (not Challenge-pinned)**: the probe's supporting classification lemmas
(time pinning, backward rigidity, forward dichotomy, absorption), the four-case closure-letter
read-out lemma for the closure alphabet of the fixture formula, the probe's `#print axioms` foot, the probe's
wiring into `scripts/check-evidence-probes.sh`, axiom pins for the two library declarations in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, a `docs/theorem-index.md` row stating
what the result does and does not deliver, the README verdict update, and the recorded bound
verdict naming the missing effective-saturation obligation.

**Non-Goals**:
- `Decidable (PlusValidZTime φ)` in ANY form, conditional or otherwise, and any statement that
  L⁺ is decidable, qualified or not. (C) alone does not deliver it; (C)+(S) still speak of one
  seam, and lifting to validity is (W).
- Requirement (S) (Hit-level soundness, the B2b construction) and requirement (W) (a closure-wide
  quasimodel). Independent and downstream records respectively.
- The computable bound itself. It is recorded as blocked with a named obligation; the missing
  lemma is NOT proved here and NOT landed as a sorry anywhere in the tree.
- General (C) for arbitrary regular ℤ-models. The result is fixture-only, forward-only, and says
  so in its own header; the lasso route's `⊆` direction stays open.
- Any complexity bound, upper or lower. The argued CTL⋆ 2EXPTIME ceiling is never a source for one.
- Any finite-fibre or finite-width assumption. Model A's slice is `Fin 3` while its carrier
  `ℤ × Fin 3` is infinite — the shape `not_finite_width_fmp` leaves standing.
- Anything about the backward `⊡(P p)` side. `Probe719Backward.pastStab_iff_allBwdPathsMeet`
  remains the only backward fixture result and there is still no backward Bool-fixture bridge.
- Retiring, weakening or re-proving task 735's verdict or its wired probe
  `presented-not-complete.lean`, and rebuilding anything task 742 landed (`hitOf`,
  `mem_hitOf_iff`, `HitCl`, `hitCl_finite`, `hitCl_eq_iUnion`, `Presented`,
  `hit_eq_hitOf_of_presented`, `kTypeOf_listSeg_append_congr` — all cited, none re-proved).
- `Present.lean`'s `fwdLive`/`bwdLive` (the shared-endpoint graph under which `mem_hitOf_iff` is
  false by the `#eval`-witnessed two-state counterexample in `KTypeFinEvalTest.lean`). Not used
  anywhere; `hitOf` reads `fwdLiveSep`/`bwdLiveSep`.
- Any cslib `require` edge or copied declaration. `~/Projects/cslib/` is read-only and this route
  needs nothing from it.
- Any external Büchi/MSO lemma cited in place of a proof (ZERO DEBT).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 6's run characterization (`IsRun` pins `ρ` in both directions) is the one uncompiled link; the hand proof is Medium confidence | H | M | Split from the presentation data (Phase 5) so the gadget definitions land green and committed first. If the pinning genuinely cannot be carried out as written, mark Phase 6 `[BLOCKED]` and escalate per `rules/plan-compliance.md` — do NOT substitute the rejected `mem_hitOf_iff_live` route or weaken the statement |
| Phase 4's choice/`Finset.sup` bookkeeping (per-member witness extraction, offset image, `Set.Finite.bddAbove`) | M | M | `Set.Finite.bddAbove` is `#check`-verified over ℤ (its `[IsDirectedOrder α] [Nonempty α]` binders are satisfied). Keep the witness extraction classical and explicit; do not try to make `L` computable — the non-constructivity is the recorded result, not a defect to repair |
| Drift into a decidability claim as the positive outcome lands | H | M | Headline is `∃ L, HitPresented …` and nothing else; `Non-Goals` bars the claim; Phase 8 runs an explicit prose audit over every touched file for "decidable"/"decision procedure"/`PlusValidZTime` |
| A same-named but weaker restatement of the headline ("true-looking name over a proof that does not reach it", the defect task 737 was filed to find) | H | M | All 17 signatures are pinned in `## Lean Challenge Statements` and were compile-checked at plan time; `lean-challenge-snapshot.sh --check` is available as an advisory drift check |
| Line/anchor drift in inherited records | M | H | Confirmed already (the record cites 246 lines for a 292-line probe). Re-resolve every declaration BY NAME, never by a cited line; this plan cites no line numbers |
| Concurrent writers on shared territory: tasks 733, 734, 739 write `RaySummary/` and `specs/evidence/seam-gluing-ray-product/` plus `scripts/check-evidence-probes.sh`; sibling 746 is dispatched this same cycle with undeclared scope | M | M | Re-read every file immediately before editing; stage only this task's own hunks with an explicit file list (never a directory or glob `git add`); never run `git-snapshot.sh` in reverting default mode; treat a build failure outside this plan's `file_scope` as possibly a sibling's in-flight edit and check `git log` before assuming a regression; STOP and report a foreign commit or uncommitted foreign modification |
| Adding a `docs/theorem-index.md` row breaks C15's second assertion (every row anchored at its declaration) or C14's pin requirement | M | M | Phase 1 writes a `Paper: —` anchor line into both new docstrings (matching `hit_eq_hitOf_of_presented`); Phase 8 adds the axiom pins in `KTypeSummaryAxiomTest.lean` in the SAME commit as the index row, then runs `scripts/check-module-invariants.sh` |
| The probe is outside the Lake build graph, so `lake build` never compiles it and it can rot silently | M | H | Phase 8 wires it into `scripts/check-evidence-probes.sh`'s `WIRED` list with its own table comment, exactly as `presented-not-complete` is wired; Phase 8's gate run includes `bash scripts/check-evidence-probes.sh` |
| Acceptance branch 3's "obstruction machine-checked rather than argued" is not literally satisfiable for a bound non-existence claim | M | H (certain) | Settled by the user's cycle-1 decision: record the axiom foot plus a stated Challenge signature for the missing effective-saturation lemma. Phase 8 states the substitution explicitly in the probe header and the summary rather than smoothing it over |
| `lab` noncomputability forces awkward encodings | L | L | `hitOf` is a `Finset` but `HitPresented` is a proposition about it, so nothing requires `lab` computable. The explicit `labOf` flag table (report D-4) keeps the axiom foot minimal and makes the run-trace lemma a rewrite |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 1, 4, 6 |
| 7 | 8 | 7 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files
(`Trace.lean` vs. the new probe) and are genuinely parallel; phases 3-7 are serialized because
they all write the same probe file.

### Phase 1: `HitPresented` and `hitPresented_of_presented` in the library [COMPLETED]

**Goal**: State the Hit-level hypothesis in `Trace.lean` beside `Presented`, and record that it
is strictly weaker, so the probe has a library name to discharge rather than a local one.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` immediately before
      editing (concurrent writers), and locate the `section Presented` block BY NAME.
- [x] Add `HitPresented` after `hit_eq_hitOf_of_presented`, with the signature pinned under
      `## Lean Challenge Statements` below and the body
      `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`.
- [x] Docstring for `HitPresented`: it is the HIT-level hypothesis named in
      `Probe735.not_presented`'s header and is strictly weaker than `Presented` — it demands
      equality of family-triple sets, not of trace sets, so `presented_localRun` is unavailable
      under it and the realization demand is finite by `kType_finite`. State that it is
      discharged in this tree for fixture model A only, non-constructively, by the wired probe
      `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`, and that no bound is
      delivered. End the docstring with a `Paper: —` anchor line (C15's second assertion requires
      every theorem-index row to be anchored at its declaration). *(deviation: altered — the
      probe reference is written as a forward reference, "landed by this record's later phases",
      because phase 2 creates the probe and phase 8 wires it; every other element of this item
      is verbatim.)*
- [x] Add `hitPresented_of_presented` as the three-line term proof
      `hit_eq_hitOf_of_presented M τ t φ lab step k hk hP`, with its own docstring and
      `Paper: —` line.
- [x] Scoped guarded detached build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.Trace`,
      then the two direct dependents
      `FormalSystem.Metalogic.Decidability.RaySummary` and
      `BimodalTest.Metalogic.KTypeSummaryAxiomTest`.
- [x] `grep -c sorry` = 0 on `Trace.lean`; no `def X := True`-shaped placeholder.
- [x] Commit (one green sub-step).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: ~15-25 lines added to one file, and the identifier `HitPresented` collides
with nothing in `FormalSystem/**` (the report's repo-wide grep found occurrences only in
`specs/**` prose, Medium confidence). Confirm at implementation time by
`git diff --stat -- FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` and by
`grep -rn 'HitPresented' FormalSystem/ Tests/` returning nothing before the edit.

**Tier Justification**: The edit introduces two new names into the `RaySummary` namespace that
downstream modules open, so the cheapest covering check is a scoped build of
`FormalSystem.Metalogic.Decidability.RaySummary.Trace` plus its two enumerated direct dependents
(`...RaySummary` and `BimodalTest.Metalogic.KTypeSummaryAxiomTest`), where a name-ambiguity break
would surface.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` - add `HitPresented` and `hitPresented_of_presented` in `section Presented`

**Verification**:
- Scoped build of `Trace` green; scoped builds of the two direct dependents green.
- `#print axioms FormalSystem.Metalogic.Decidability.RaySummary.hitPresented_of_presented` reports
  exactly `[propext, Classical.choice, Quot.sound]`.
- Zero sorries in the touched file.

---

### Phase 2: Probe scaffold, fixture transcription, and the step-path classification [COMPLETED]

**Goal**: Create the probe file with its full header and the model-A fixture, and land the
step-path classification: every step path through the seam `(t, a)` is the constant `a`-path or an
`a`-then-`b` jump path with jump time `w ≥ t`.

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` with a header
      in the collection's established shape (model it on `presented-not-complete.lean`'s header,
      which is the sibling record this one sits beside): what the probe establishes; the fixture;
      the argument in two sentences; what is NOT established (no bound, forward-only, nothing
      about `⊡(P p)`, no decidability of anything, `Decidable (PlusValidZTime φ)` not stated in
      any form, nothing about general regular ℤ-models); the decision held in place; the axiom
      record; the compile line.
- [x] Header must state, per report D-6, that the result does NOT generalize: model A's splices
      are eventually constant in both directions, which is what lets a finite presentation realize
      finitely many of them exactly; for a general regular ℤ-model the general route needs one
      lasso per triple and its `⊆` direction is open.
- [x] Header must state that this probe does NOT weaken or retire `Probe735.not_presented`: that
      probe refutes an equality of TRACE sets, this one establishes an equality of FAMILY-TRIPLE
      sets, the presentation here is deliberately NOT `Presented` (it realizes only finitely many
      of the seam's traces), and both hold simultaneously.
- [x] Transcribe the fixture from `presented-not-complete.lean` (transcribed, never imported, as
      the collection's convention requires): `St`, `a`, `b`, `pa`, `Fp`, `RA`, `RA_fwd`, `RA_bwd`,
      `FA`, `instFARegular`, `MA`, `stayA`, `jump`, `stayA_state`, `jump_state`, `p_iff`, `Fp_iff`,
      `jump_p_iff`, `jump_Fp`. *(deviation: altered — also transcribed `RA_aa`, `RA_ab`, `RA_bb` and `ab_ne`, which the item does not list but which `stayA`, `jump` and `bwd_a` require; and `a`/`b`/`pa` are landed as `def` as in `presented-not-complete.lean`, not as the `abbrev` the plan's `## Lean Challenge Statements` block shows, since that block states the `abbrev` form was a plan-time device to keep the pinned identifier set equal to the `**Goals**:` set and none of `St`/`a`/`b`/`pa`/`Fp` is a pinned goal.)*
- [x] Transcribe the classification from the research dispatch's compiled scratch file
      `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/9b704637-8466-49f5-bdeb-3bd3ef0521bb/scratchpad/rigid745.lean`:
      `stepA`, `time_eq`, `bwd_a`, `fwd_dichotomy`, `fwd_absorb`, `path_classify`. Keep the
      tactic choices the research recorded as load-bearing: `Int.induction_on` with case names
      `zero`/`succ`/`pred`; `push_cast at h ih ⊢` BEFORE the `show … by ring` rewrite in `bwd_a`;
      `simp only [not_exists]` in place of deprecated `push_neg`; explicit `IsStepPath` hypotheses
      per theorem (this toolchain does not auto-include a propositional `variable`).
- [x] Compile: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
      — zero errors, zero warnings, zero sorries.
- [x] Commit (one green sub-step).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~200-230 lines in one new file (header ~60, fixture ~50, classification
~110). *(CONFIRMED-WITH-OVERSHOOT at implementation time: 276 lines — header 65 and classification
~96 as hypothesized, fixture ~100 against the hypothesized ~50. The miss is entirely the fixture:
the item above enumerates 19 identifiers, and `jump`'s well-definedness proof plus the
`RA_aa`/`RA_ab`/`RA_bb` step facts it and `stayA` consume do not fit in 50 lines. No scope beyond
the plan's enumerated items was added. The scratch file was still present and transcribed as
written, so no reconstruction from the report was needed.)* Confirm by `wc -l` on the new probe and by the scratch file still being present and
compiling as transcribed; if the scratch file has been cleaned from `/tmp`, reconstruct from the
report's recorded tactic survey rather than inventing a different route.

**Tier Justification**: The probe lives under `specs/`, which no Lake target root reaches, so it
has no importers and no library surface at all; `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
is the complete covering check for this single-file edit.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` - new probe: header, fixture transcription, step-path classification

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` exits 0 with
  no errors and no warnings.
- `grep -c sorry` = 0 on the probe.
- `path_classify`'s statement matches the pinned signature under `## Lean Challenge Statements`
  verbatim.

---

### Phase 3: Splice-to-history identification and the closure-letter read-out [COMPLETED]

**Goal**: Turn the step-path classification into a statement about the seam's SPLICES —
`spliced stayA t bf` is `stayA` or `jump w` for some `w ≥ t` — and establish the four-case
`clTrace` read-out that makes trace equality a rewrite.

**Tasks**:
- [x] Re-resolve `seamOmegaEquiv`, `SeqPair`, `ZPathFibre`, `pathFibreEquiv`, `spliced` and
      `WorldHistory.ext_state` BY NAME (never by a cited line) before use. *(all six resolved by
      name via grep over `FormalSystem/`; `spliced` is an `abbrev` in `RaySummary/SeamMulti.lean`,
      the other five are in `PlusLanguage/PlusRayFibre.lean` and `Semantics/PartialHistory.lean`.
      `WorldHistory.path` was additionally resolved and found to be `WorldHistory.state` by
      definition, which is what made the transport a `rfl`.)*
- [x] Prove `splice_classify` at the pinned signature: for every `t` and every
      `bf : SeqPair FA (stayA.state t)`, `spliced stayA t bf = stayA ∨ ∃ w, t ≤ w ∧ spliced stayA t bf = jump w`.
      Route: `pathFibreEquiv`/`seamOmegaEquiv` to view the splice as a step path through `(t, a)`,
      `path_classify` to classify it, then `WorldHistory.ext_state` to lift the state-wise equality
      to a history equality. *(route followed as written; no explicit `pathFibreEquiv` rewrite was
      needed because `seamOmegaEquiv`'s `.symm` already carries the seam condition
      `σ.state t = stayA.state t` as its `.2` field and `WorldHistory.path = WorldHistory.state`
      definitionally, so `path_classify` applies to `(spliced stayA t bf).path` directly.
      Signature confirmed byte-identical to the pinned Challenge by mechanical whitespace-normalized
      diff, not by eye.)*
- [x] Land the four-case closure-letter read-out: for each member of `plusSubformulaClosure Fp`
      (`untl ⊤ p`, `atom p`, `⊤`, `bot`) plus `clNow`, give `clTrace MA Fp t σ` on `stayA` and on
      `jump w` explicitly, via `clTrace_letter`, `clTrace_now`, `p_iff`, `Fp_iff`, `jump_p_iff`,
      `jump_Fp`. Re-derive `(plusSubformulaClosure Fp).card` by `#eval` before writing the case
      split (the figure is CARRIED-UNVERIFIED from the report). *(`#eval` run BEFORE the case split
      was written: `(plusSubformulaClosure Fp).card` = 4, the report's figure CONFIRMED, and
      `PlusFormula.subformulas Fp` printed as `[Fp, atom p, ⊤, ⊥, ⊥]` so the four members are
      exactly those named. Landed: `cl_Fp`/`cl_p`/`cl_top`/`cl_bot` membership, `letter_cases`
      (the five-letter exhaustion that makes the case analysis demonstrably complete), the ten
      per-letter read-outs `clTrace_{stayA,jump}_{now,Fp,p,top,bot}`, the two supporting falsity
      lemmas `stayA_p_false`/`stayA_Fp_false`, the two assembled `↔` forms
      `clTrace_{stayA,jump}_apply`, and the two function-level forms
      `clTrace_{stayA,jump}_eq` that make trace equality a rewrite. The ten pairwise-distinctness
      lemmas (`now_ne_*`, `Fp_ne_*`, `p_ne_*`, `top_ne_bot`) are additionally landed; they are
      UNUSED in this phase (the assembled forms were restructured to case-split on `letter_cases`
      in the forward direction and to substitute via `rintro ... rfl` in the backward direction,
      which needs no distinctness) and exist for phases 5-6's `labOf` flag-table case split. No
      plan step was skipped, altered or routed through different helpers.)*
- [x] Compile the probe; zero errors, zero warnings, zero sorries. *(`lake env lean` exit 0;
      zero lines matching `error` or `warning` over the captured stream; `grep -c sorry` = 0.)*
- [x] Commit (one green sub-step).

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 80-120 added lines (research estimate, CARRIED). Confirm by
`git diff --stat` on the probe; if the splice-to-step-path transport through
`pathFibreEquiv`/`seamOmegaEquiv` costs materially more than that, record it in the issue log
rather than silently absorbing it. *(REFUTED-WITH-OVERSHOOT at implementation time:
`git diff --stat` = 205 insertions / 9 deletions, net +196 against the hypothesized 80-120. The
hypothesis named the wrong driver: the transport is 29 lines and compiled on the first attempt,
while the read-out item is 21 mandated declarations before any supporting material (10 per-letter
lemmas × 2 families is already 10, plus 4 membership facts, `letter_cases`, 2 falsity lemmas, 2
assembled `↔` forms and 2 function-level forms), and the forward-looking distinctness lemmas add
~22 more. Recorded in the issue log as `class: scope-estimate`, `severity: minor`, per this item's
own instruction; the 9 deletions are header-paragraph rewrites, not removed proof.)*

**Tier Justification**: Still a single file outside the Lake build graph with no importers, so
`lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` covers the
whole blast radius of this edit.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` - `splice_classify` and the four-case `clTrace` read-out

**Verification**:
- `lake env lean` on the probe exits 0, no errors, no warnings.
- `splice_classify`'s statement matches its pinned signature verbatim.
- The `#eval` of `(plusSubformulaClosure Fp).card` is recorded in the probe as a comment beside
  the case split, so the case analysis's completeness is checkable by a reader.

---

### Phase 4: The truncation bound [COMPLETED]

**Goal**: Replace the infinite index of `hitCl_eq_iUnion` by a finite one: there EXISTS an `L`
with `HitCl MA stayA t Fp k` equal to the family triples of `stayA`'s trace together with those
of `jump w` for `w ∈ [t, t + L]`.

**Tasks**:
- [x] Re-resolve `hitCl_finite`, `hitCl_eq_iUnion`, `familyTriples`, `finite_family_triples`,
      `kType_finite`, `Set.Finite.bddAbove`, `Set.Finite.toFinset`, `Finset.sup` BY NAME.
      *(all eight resolved by name, no line citation trusted: `hitCl_finite` /
      `hitCl_eq_iUnion` / `familyTriples` in `RaySummary/Trace.lean`, `finite_family_triples`
      in `KTypeSummary/Universal.lean`, `kType_finite` in `KTypeSummary/Basic.lean`,
      `Set.Finite.bddAbove` in `Mathlib/Data/Set/Finite/Lattice.lean`, `Set.Finite.toFinset`
      and `Finset.sup` in Mathlib as cited; the last two turned out UNUSED — see the Scope
      Hypothesis outcome below.)*
- [x] Prove `hitCl_eq_truncated` at the pinned signature. Route, as the research specified:
      `hitCl_eq_iUnion` to express `HitCl` as a union over ray pairs; `hitCl_finite` to get
      finiteness; classically pick one witnessing `bf` per member; `splice_classify` to give each
      witness a natural offset (`0` for `stayA`, `w - t` otherwise); `Set.Finite.bddAbove` on the
      image of the offsets to get `L`. The `⊇` direction is immediate because every trace in the
      truncated family is a genuine splice's trace.
- [x] Do NOT evaluate any `kTypeOf`, do NOT run `decide` over `KType`, and do NOT attempt to make
      `L` computable. The `∃ L` shape is the recorded result. *(grep over the added region: the
      only occurrences of `kTypeOf`, `decide` and `KType` are in the prose naming them as what
      is NOT done.)*
- [x] Add a comment at the proof site naming exactly where the non-constructivity enters
      (`Set.Finite.bddAbove`, hence `Classical.choice`) and that this is why no bound is
      delivered. *(section header plus two inline comments; TWO choice sites named, not one —
      `choose!` picking a witnessing ray pair per member, and `Set.Finite.bddAbove` asserting
      only that some upper bound exists.)*
- [x] Compile the probe; zero errors, zero warnings, zero sorries. *(`lake env lean` exit 0;
      one declaration-scoped `set_option linter.unusedVariables false` was needed to keep the
      pinned `hk` binder — see the record below.)*
- [x] Commit (one green sub-step).

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 60-100 added lines (research estimate, CARRIED), with the choice/`Finset.sup`
bookkeeping the dominant cost. Confirm by `git diff --stat` on the probe.

**Scope Hypothesis outcome**: CONFIRMED on the line count — `git diff --stat` reports 98
insertions, inside the predicted 60-100. The predicted DRIVER was wrong: no `Finset.sup`
bookkeeping arose at all, because `Set.Finite.image` plus `BddAbove`'s own `upperBounds`
witness replaced the `toFinset`/`sup` route outright, so neither `Set.Finite.toFinset` nor
`Finset.sup` appears in the proof. The cost was instead the two helper lemmas the pinned
statement does not name (`jump_seam`, `exists_splice_eq`) and one further named lemma
(`hitCl_covered`) factoring the `hitCl_eq_iUnion`-then-`splice_classify` step out of the main
proof — a decomposition REFINEMENT (more named lemmas), never an inlining, and no plan-named
declaration was skipped, altered or re-routed.

**Record — the one contract tension**: the pinned signature binds `(hk : 1 ≤ k)` but the
truncation argument genuinely does not use it (`HitCl` is defined at every depth), so Lean's
`unusedVariables` linter warned, colliding with this phase's zero-warnings bar. Resolved by a
declaration-scoped `set_option linter.unusedVariables false in` plus a docstring paragraph
stating why `hk` is carried — NOT by renaming the binder to `_hk`, which would have altered
the pinned signature this phase's verification requires verbatim.

**Tier Justification**: Single-file edit outside the Lake build graph with no importers;
`lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` is the complete
covering check.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` - `hitCl_eq_truncated` and the non-constructivity comment

**Verification**:
- `lake env lean` on the probe exits 0, no errors, no warnings. **MET**: exit 0, zero errors,
  zero warnings; the `#eval (plusSubformulaClosure Fp).card` foot still prints `4` and all
  seven `#print axioms` lines (including the new `hitCl_eq_truncated`) report exactly
  `[propext, Classical.choice, Quot.sound]`.
- `hitCl_eq_truncated`'s statement matches its pinned signature verbatim, in particular the
  `∃ L : ℕ` prefix — a version with a supplied or computed `L` is a DIFFERENT (stronger) theorem
  and is not what this phase may land. **MET**: confirmed by mechanical whitespace-normalized
  string comparison of the pinned block against the landed declaration, not by eye — exact
  match including the `∃ L : ℕ` prefix and the `hk` binder name.
- No `kTypeOf`/`decide`/`KType` evaluation appears anywhere in the added proof. **MET** by grep
  over the added region: only prose occurrences, naming them as what is not done.

---

### Phase 5: The presentation data — `QA`, `labOf`, `stepOf`, and the labelling bridge [COMPLETED]

**Goal**: Define the `L + 6`-state presentation and its labelling, and tie `labOf`'s flags to
`clTrace` so the run-trace comparison in Phase 6 is a rewrite rather than a re-derivation.

**Tasks**:
- [x] Define `QA L := Fin 3 ⊕ Fin (L + 3)` (so `Fintype.card (QA L) = L + 6`), with its `Fintype`
      and `DecidableEq` instances coming from the `Sum`/`Fin` instances rather than hand-rolled.
      *(deviation: altered — the card claim is landed as the named theorem `card_QA` plus
      `#guard Fintype.card (QA 2) = 8`, rather than left as a parenthetical.)*
- [x] Define `stepOf` at the pinned signature. Gadget 1 (`Fin 3`, `0 = s_pre`, `1 = s_now`,
      `2 = s_post`): `0→0, 0→1, 1→2, 2→2`. Gadget 2 (`Fin (L + 3)`, `0 = j_pre`, `1 = j_now`,
      `2 … L+1 = j_mid_1 … j_mid_L`, `L+2 = j_post`): `0→0`, `0→1`, `i→i+1` for `1 ≤ i ≤ L+1`,
      `i→L+2` for `1 ≤ i ≤ L+1`, `L+2→L+2`. NO step crosses the two summands — state this as its
      own lemma, since Phase 6's cross-gadget exclusion depends on it.
      *(deviation: altered — `stepOf_no_cross` landed as asked, plus two `@[simp]` crossing-edge
      lemmas `stepOf_inl_inr`/`stepOf_inr_inl` it is proved from and the two index-level step
      tables `stepOf_inl_inl_iff`/`stepOf_inr_inr_iff` Phase 6 reads the edges off.)*
- [x] Define `labOf` at the pinned signature as an explicit flag table (report D-4), NOT as
      `decide` of `clTrace`: `now` true only at `inl 1` and `inr 1`; `atom p` false throughout
      gadget 1 and true exactly at `inr (L+2)`; `Fp` false throughout gadget 1 and true
      everywhere in gadget 2; `⊤` true and `bot` false everywhere.
      *(deviation: altered — the three state-side flags are factored into named `def`s
      `isNowState`/`isJumpState`/`isPostState` so the five letter-branch evaluation lemmas
      `labOf_now`/`labOf_top`/`labOf_Fp`/`labOf_p`/`labOf_bot` are `@[simp]`-usable in Phase 6.)*
- [x] Prove the labelling bridge: `labOf L q ℓ` agrees with the Phase 3 read-out of
      `clTrace MA Fp t stayA` / `clTrace MA Fp t (jump w)` at the corresponding position, as a
      four-case lemma over the closure members plus `clNow`.
      *(deviation: altered — landed as four declarations, not one: the per-gadget assembled
      flag lemmas `labOf_inl`/`labOf_inr` (the four-case split over `letter_cases`), the
      position-indexed bridges `labOf_inl_iff_clTrace_stayA`/`labOf_inr_iff_clTrace_jump`, and
      the function-level forms `runTrace_inl_eq`/`runTrace_inr_eq` that make Phase 6 a rewrite.)*
- [x] Re-derive `(plusSubformulaClosure Fp).card` by `#eval` before finalizing the table, and
      record it as a `#guard` or a comment so the table's completeness is checkable.
      *(re-derived live as 4 via `lean_run_code` against the built oleans BEFORE the table was
      written; recorded as `#guard (plusSubformulaClosure Fp).card = 4`, and the pre-existing
      `#eval` at the foot is left in place.)*
- [x] Compile the probe; zero errors, zero warnings, zero sorries. `labOf` and `stepOf` must be
      `def`, never `noncomputable def`.
      *(deviation: altered — the probe's `#print axioms` foot was also extended with `labOf`,
      `stepOf` and the two bridges, matching the foot convention the file already carries;
      observed: `stepOf` is choice-free `[propext]`, `labOf` and both bridges carry
      `[propext, Classical.choice, Quot.sound]`.)*
- [ ] Commit (one green sub-step).

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 100-150 added lines, and `Fintype.card (QA L) = L + 6`. Confirm the card
claim by `#eval`/`decide` at a small `L` in the probe itself, and the line count by
`git diff --stat`.

**Tier Justification**: Single-file edit outside the Lake build graph with no importers;
`lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` covers it, and
the `#eval`/`#guard` card and alphabet witnesses run inside that same compile.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` - `QA`, `stepOf`, `labOf`, the no-cross-step lemma, the labelling bridge, the alphabet witness

**Verification**:
- `lake env lean` on the probe exits 0, no errors, no warnings.
- `labOf` and `stepOf` statements match their pinned signatures verbatim; both are `def`.
- The no-cross-step lemma is present as a named declaration (Phase 6 cites it).

---

### Phase 6: The run characterization [COMPLETED]

**Goal**: Show the presentation's anchored run traces are EXACTLY the truncated trace set — the
one link the research left uncompiled, and the step on which the whole result turns.

**Tasks**:
- [x] Prove `runTrace_mem_of_isRun` at the pinned signature (the `⊆` direction). Route:
      `IsRun`'s own `↔` forces `labOf L (ρ z) (clNow Fp) = true ↔ z = t`, hence
      `ρ t ∈ {inl 1, inr 1}`; the only predecessor of `inl 1` is `inl 0` and of `inr 1` is
      `inr 0`, and each is its own only predecessor, so `ρ` is constant-`pre` on `(-∞, t)`;
      forward, gadget 1 admits one continuation and gadget 2 admits exactly `L + 1`; `post`
      absorbs. Cite the Phase 5 no-cross-step lemma to exclude a run crossing gadgets.
      *(deviation: altered — landed as the route describes but decomposed into named steps:
      `isLeft_const_of_isRun` (cites `stepOf_no_cross`), `exists_left_index`/`exists_right_index`,
      `inl_bwd_pre`/`inl_fwd_post`/`inl_run_pinned`, `inr_bwd_pre`, `inr_fwd_index`,
      `inr_absorb`/`inr_absorb_add`, `inr_post_threshold`. Signature verbatim, verified by
      whitespace-normalized string comparison against the pinned statement. One honest reading
      recorded in the probe's own section header: because Phase 5 made `labOf` read only
      `isNowState` in gadget 1, the gadget-1 trace equality consumes ONLY `IsRun`'s own `↔`, so
      `inl_bwd_pre`/`inl_fwd_post`/`inl_run_pinned` are landed as the route and as the record
      that no unclassified gadget-1 run exists, not as premises of the trace comparison.
      `inr_bwd_pre` IS consumed, by `inr_post_threshold`'s `z ≤ t` case. Nothing was dropped,
      weakened or substituted.)*
- [x] Prove `exists_isRun_runTrace` at the pinned signature (the `⊇` direction): exhibit the
      anchored run realizing `stayA`'s trace, and for each `w ∈ [t, t + L]` the run leaving the
      mid chain after `w - t` steps.
      *(deviation: altered — the two runs are landed as named `def`s `stayRun` and `jumpRun` with
      their own evaluation lemmas (`stayRun_val`/`stayRun_now`/`stayRun_isRun`,
      `jumpRun_val`/`jumpRun_now`/`jumpRun_post`/`jumpRun_isRun`) rather than inline terms, so the
      `IsRun` clauses and the two position correspondences are separately checkable. `jumpRun`'s
      index is `min … (L + 2)` so the `Fin (L + 3)` bound needs no side condition; `jumpRun_val`
      proves the `min` is the identity on the intended range, so it is bookkeeping and not a
      truncation. Signature verbatim, verified by the same string comparison.)*
- [x] Explicitly discharge the three counterexamples the research challenged this step with, each
      as its own named step or comment: a run stuck at `pre` forever (excluded by `IsRun`'s `↔` at
      `z = t`); a run crossing gadgets (no cross steps); a run looping in the mid chain
      (`Fin (L + 3)` has no back edges, `post` absorbs).
      *(landed as three named theorems, in order: `no_run_const_pre` (no run is constant at any
      non-`now` state, in either gadget), `isLeft_const_of_isRun` (`Sum.isLeft ∘ ρ` is constant
      along a `step`-chain, by `stepOf_no_cross` and nothing else), `inr_no_back_edge` (from a mid
      state the index strictly increases, `j_post` being the only reachable self-loop).)*
- [ ] If the `IsRun` pinning genuinely cannot be carried out as written: mark this phase
      `[BLOCKED]` in the plan with what was tried and the goal state reached, and escalate. Do
      NOT substitute the `mem_hitOf_iff_live` / `pathTypesNow` / `fwdLiveSep` route (explicitly
      rejected at report D-2/D-3), do NOT weaken either pinned statement, and do NOT land a
      vacuous placeholder.
      *(not triggered — the pinning was carried out as written; the rejected route was not used,
      neither pinned statement was weakened, and no placeholder was landed. Left unchecked
      because its condition never arose.)*
- [x] Compile the probe; zero errors, zero warnings, zero sorries.
      *(`lake env lean` through the build guard: guard exit 0, zero `error:`, zero `warning:`,
      zero sorries. Both `#guard`s pass. `#print axioms` foot extended with
      `runTrace_mem_of_isRun` and `exists_isRun_runTrace`; both observed as
      `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.)*
- [x] Commit (one green sub-step).

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 100-150 added lines, and the forward branching of gadget 2 is exactly
`L + 1` continuations. Confirm the branching claim inside the proof (it is what makes
`exists_isRun_runTrace` surject onto `[t, t + L]`) rather than asserting it in prose, and the line
count by `git diff --stat`.

**Tier Justification**: Single-file edit outside the Lake build graph with no importers;
`lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` is the complete
covering check.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` - `runTrace_mem_of_isRun`, `exists_isRun_runTrace`, and the three excluded-run arguments

**Verification**:
- `lake env lean` on the probe exits 0, no errors, no warnings.
- Both statements match their pinned signatures verbatim; neither has gained a hypothesis nor
  specialized a quantifier relative to the pin.
- `grep -c sorry` = 0 on the probe.

---

### Phase 7: Assembly — `hitPresented_modelA` and the probe's axiom foot [COMPLETED]

**Goal**: Compose the truncation bound with the run characterization through `mem_hitOf_iff` to
land the headline, and pin its axiom profile in the probe itself.

**Tasks**:
- [x] Prove `hitPresented_modelA` at the pinned signature:
      `∀ (t : ℤ) (k : ℕ), 1 ≤ k → ∃ L : ℕ, HitPresented MA stayA t Fp (labOf L) (stepOf L) k`.
      *(landed in the binder form the `## Lean Challenge Statements` block pins —
      `(t : ℤ) (k : ℕ) (hk : 1 ≤ k)` — which is that block's rendering of this item's `∀`
      prose; confirmed verbatim by whitespace-normalized string comparison, MATCH.)*
      Route: take `L` from `hitCl_eq_truncated`; unfold `HitPresented` to
      `HitCl MA stayA t Fp k = ↑(hitOf (labOf L) (stepOf L) (clNow Fp) k)`; rewrite the left side
      by `hitCl_eq_truncated` and the right side by `mem_hitOf_iff` (run-existence form, which
      needs `1 ≤ k`); close by `runTrace_mem_of_isRun` and `exists_isRun_runTrace`.
- [x] Add the `#print axioms` foot for `hitPresented_modelA` in the probe, in the collection's
      established shape, and update the header's axiom record to the profile actually observed.
      *(deviation: altered — the header update also corrected two statements that THIS phase's
      own edit falsified: the opening paragraph's "parts 1-2 of the record … Nothing in this file
      yet mentions `HitCl`, `hitOf` or `HitPresented`", and the "What is NOT established"
      paragraph's "the later phases' headline". Both were stale the moment the headline landed.
      Purely corrective and additive; no claim weakened, no qualifier dropped.)*
- [x] Add a short note at the headline naming what it does NOT say: no `L` is exhibited, so no
      bound is delivered; `Fintype.card (QA L) = L + 6` is a function of an unexhibited `L`; the
      presentation is deliberately not `Presented`.
      *(deviation: altered — landed as a five-bullet `### What `hitPresented_modelA` does NOT
      say` section rather than a short note. It carries all three items this step names, plus
      two the dispatch's own constraints require of any statement of this result: FORWARD-ONLY
      (nothing about `⊡(P p)`, no symmetry implied) and the one-fixture/one-seam/one-`φ`
      qualifier. An expansion, never a substitution.)*
- [x] Compile the probe; zero errors, zero warnings, zero sorries. *(`lake env lean` through
      the build guard, un-piped, guard exit 0; zero `error:`, zero `warning:`, no `sorryAx`; the
      `#eval` foot still prints `4` and both `#guard`s pass. Green on the FIRST round, with no
      tactic iteration.)*
- [x] Commit (one green sub-step). *(two, per `Commit Mode: per-substep`: `phase 7.1` for the
      headline and its axiom pin, `phase 7.2` for the header's axiom record and framing.)*

**Timing**: 1 hour

**Depends on**: 1, 4, 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 40-70 added lines in the probe, and the axiom profile is
`[propext, Classical.choice, Quot.sound]` and nothing more. Confirm the profile from the
`#print axioms` output itself, never from this plan's prediction; if a fourth axiom appears,
record it and do not edit the pin to match a prediction.

**Scope Hypothesis outcome**: CONFIRMED on both counts, and it is the first phase of this record
whose line estimate held. The headline sub-step is `+69 / -0` by `git diff --stat`, inside the
predicted 40-70 window once the mandated five-bullet "does NOT say" section is counted with it;
the header-correction sub-step adds a further `+32 / -17`, for `+101 / -17` across the phase.
The axiom profile was read off the `#print axioms` output, not predicted: `hitPresented_modelA`
reports exactly `[propext, Classical.choice, Quot.sound]`. No fourth axiom appeared, so no pin
was edited to match anything. (Observed incidentally and recorded rather than smoothed over:
`stepOf` reports `[propext]` ALONE, not the three-axiom profile — it is a decidable
`Bool`-valued table — so the header's axiom record now states the exception instead of claiming
a uniform profile.)

**Tier Justification**: The assembly consumes Phase 1's library declarations but adds nothing to
the library; the edit is confined to the single out-of-graph probe file, so
`lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` covers it.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` - `hitPresented_modelA`, the `#print axioms` foot, the header's axiom record

**Verification**:
- `lake env lean` on the probe exits 0, no errors, no warnings, zero sorries.
- `hitPresented_modelA`'s statement matches its pinned signature verbatim — in particular the
  `∃ L : ℕ` prefix and the absence of any `Decidable`, `PlusValidZTime` or cardinality bound.
- The `#print axioms` foot's recorded profile equals the observed one.

---

### Phase 8: Wiring, pins, index, README, and the recorded bound verdict [COMPLETED]

**Goal**: Make the probe non-rotting and the result discoverable; record the bound as blocked with
the named obligation; run the full gate set.

**Tasks**:
- [x] Re-read `scripts/check-evidence-probes.sh` immediately before editing (tasks 733, 734 and
      739 are other writers), then add `"seam-gluing-ray-product/hit-presented-model-a"` to the
      `WIRED` array and its own entry to the preceding table comment, stating the decision it
      holds in place: `HitPresented` is satisfiable on fixture model A for every `k ≥ 1`, so the
      `Presented` refutation does not transfer to the Hit level and the route is NOT closed; the
      construction is non-constructive and delivers no bound; forward-only; nothing about
      `⊡(P p)`; `Decidable (PlusValidZTime φ)` not stated in any form. *(deviation: altered — additionally
      amended the preceding `presented-not-complete` entry's trailing line, which read
      ``HitPresented` left OPEN``, with a cross-reference to the new probe; leaving it would
      have left the guard's own table asserting as open what the entry beside it settles. No
      claim weakened: the general-(C)-with-a-bound status is still recorded as open.)*
- [x] Add axiom pins for the two library declarations to
      `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` in the file's established
      `/-- info: … -/ #guard_msgs in #print axioms …` shape, with a short `/-! … -/` note
      explaining that `HitPresented` is the Hit-level weakening of `Presented`, that
      `hitPresented_of_presented` makes the weakening explicit, and that the fixture-level
      discharge lives in the wired probe (which this module cannot import, since probes are
      outside the Lake graph).
- [x] Add a `docs/theorem-index.md` row for `hitPresented_of_presented` whose prose states
      exactly what the result does and does not deliver: `HitPresented` is strictly weaker than
      `Presented`; it is discharged on fixture model A at every `k ≥ 1` by the wired probe,
      non-constructively, with NO computable bound; `Presented` remains refuted there by
      `presented-not-complete.lean` and the two hold side by side; nothing is stated about
      `PlusValidZTime` or about general regular ℤ-models; forward-only. Add the row in the SAME
      commit as the axiom pins (C14), and keep the row anchored at its declaration (C15).
- [x] Update `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: in "The verdict", change
      (C)'s status from "`HitPresented` left OPEN" to the fixture-level finding, WITHOUT retiring
      or weakening the verdict itself or `Probe735.not_presented` — the ray-product presentation
      as landed still cannot deliver `Decidable (PlusValidZTime φ)`, (S) and (W) are still missing,
      and general (C) with a computable bound is still open. Add the new probe to the file's probe
      inventory. *(deviation: altered — additionally updated the `Trace.lean` row of the "What it
      holds" table, whose line count still read 371 against a live 415 and whose description
      did not mention `HitPresented`/`hitPresented_of_presented` at all; and added the two new
      pins to "The consumer relation"'s pinned-profile list. Both are the same file and the
      same edit round, not new scope.)*
- [x] Record the bound verdict, in the probe header and in the README: the computable bound is
      BLOCKED, the obstruction is that the truncation proof's `L` comes from
      `Set.Finite.bddAbove` (hence `Classical.choice`) and is never exhibited, the in-tree entry
      point for an effective bound is `kTypeOf_listSeg_append_congr`, and the missing obligation
      is the finite-semigroup eventual-periodicity lemma stated under
      `## Bound Verdict: The Named Obligation` below. State plainly that a claim of NON-EXISTENCE
      of a computable bound is not a Lean-statable property of this development, so acceptance
      branch 3's "machine-checked rather than argued" is discharged by the axiom foot plus this
      named, stated-not-proved obligation — the substitution the user approved in cycle 1 — and
      NOT by a theorem asserting impossibility. Do NOT land the obligation as a `sorry` anywhere. *(deviation: altered — while writing the verdict into the probe header, corrected a stale
      forward-reference in that header's own "The decision held in place" paragraph, which
      said the companion no-bound decision was "recorded by the later phases rather than
      here" and which this very edit falsified. Purely additive; the same defect class the
      preceding phase found and corrected.)*
- [x] Re-grep `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Saturation.lean` before writing
      the verdict, to re-derive the CARRIED-UNVERIFIED claim that it holds no block-length
      threshold lemma; if one has since landed, say so and revise the verdict accordingly.
- [x] Prose audit over every file this plan touched: no occurrence of "decidable", "decision
      procedure", "L⁺ is decidable" or `PlusValidZTime` in a way that attributes a decidability
      result to this work; every new header names the forward-only limit and the absent backward
      Bool-fixture bridge; no task-number citation outside `specs/**` (C9).
- [x] Run the full gate set (see Verification below) and commit. *(deviation: altered — the
      phase's **Scope Hypothesis** predicted five touched files and said a sixth means a
      sibling task's edit must be unstaged. Eight were touched, and the three extra are all
      MACHINE-GENERATED artifacts this phase's own line additions obliged, not foreign edits:
      `typst/generated/status.typ` (the pre-commit `typst-sync-check.sh` Check 2 gate refused
      the first commit over `tests-line-count` 22943 vs a live 22982 — a delta of exactly the
      39 lines added to the axiom-test module), and `README.md` plus
      `FormalSystem/Metalogic/README.md` (both carried stale `GENERATED` inventory blocks;
      the `Decidability/` figure was off by exactly the 44 lines Phase 1 added to
      `Trace.lean` and never regenerated, so this is this record's own inherited debt
      surfacing at its first gate-running phase). Each was repaired with the repository's own
      sanctioned generator — `typst-sync-check.sh --fix` and
      `check-module-invariants.sh --emit-inventory` — never hand-edited, and each diff was
      inspected to confirm it carried no foreign content. The hypothesis's "a sixth file means
      a sibling's edit" reading was simply the wrong diagnosis for this phase.)*

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: five files touched (the probe header, the probe-guard script, the axiom-test
module, the theorem index, the RaySummary README) and exactly one new theorem-index row. Confirm
by `git status --short` and `git diff --staged` before the commit; a sixth touched file means a
sibling task's edit has been picked up and must be unstaged.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - wire the new probe into `WIRED` plus its table comment
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom pins for `HitPresented` and `hitPresented_of_presented`
- `docs/theorem-index.md` - one new row for `hitPresented_of_presented`
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - (C)'s fixture-level status, probe inventory entry, bound verdict
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` - header: bound verdict and the named obligation

**Verification**:
- Full project build, guarded and detached:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` green.
- `bash scripts/check-evidence-probes.sh` exits 0 with the new probe wired.
- `bash scripts/check-module-invariants.sh` green (C9 task-number citations, C14 axiom/sorry
  documentation pins, C15 theorem-index row anchoring).
- `bash .claude/scripts/verify-deploy.sh` green (the complete gate set it aggregates, not a
  hand-picked subset, and not under `--skip-slow` or `--only-gate`).
- `grep -rn 'sorry' ` over every touched `.lean` file returns only the word inside prose, if at
  all; zero actual sorries. No `def X := True`-shaped vacuous placeholder.
- `#print axioms` on both library declarations reports exactly
  `[propext, Classical.choice, Quot.sound]`, matching the pins written in the axiom-test module.

---

## Lean Challenge Statements

These statements were compile-checked as a single module against the live build at plan-authoring
time (`lake env lean`): 16 `sorry` warnings, zero elaboration errors. Every theorem body is
`sorry`, as this section's contract requires; `HitPresented` carries its real body because the
body IS the statement being pinned. Fixture aliases are `abbrev` so the declared identifier set is
exactly the `**Goals**:` set.

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness

namespace FormalSystem.Metalogic.Decidability.RaySummary

variable {F : FrameOver intOrder} [F.IsRegular] {Q : Type}

/-- (C) at the HIT level: the seam's realized family triples are exactly the presentation's.
Strictly weaker than `Presented`, which demands equality of TRACE sets. -/
def HitPresented [Fintype Q] [DecidableEq Q] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool) (k : ℕ) : Prop :=
  HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)

/-- The weakening is real: `Presented` implies `HitPresented` at every depth `k ≥ 1`. -/
theorem hitPresented_of_presented [Fintype Q] [DecidableEq Q] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool) (k : ℕ) (hk : 1 ≤ k)
    (hP : Presented M τ t φ lab step) : HitPresented M τ t φ lab step k := sorry

end FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe745

-- Fixture aliases: `abbrev`, so the pinned identifier set is exactly the **Goals**: set.
abbrev St := Fin 3
abbrev a : St := 0
abbrev b : St := 1
abbrev pa : Atom := ⟨"p", none⟩
abbrev Fp : PlusFormula := someFuture (.atom pa)

/-- Fixture model A's sliced step relation: stay, or jump to `b`. -/
def RA : ℤ → St → St → Prop := sorry
theorem RA_fwd : ∀ (t : ℤ) (w : St), ∃ u, RA t w u := sorry
theorem RA_bwd : ∀ (t : ℤ) (w : St), ∃ v, RA (t - 1) v w := sorry
abbrev FA : FrameOver intOrder := FrameOver.ofSlicedStep RA RA_fwd RA_bwd
instance instFARegular : FA.IsRegular := sorry

/-- `p` at `b` only. -/
def MA : TaskModel FA.toTaskFrame := sorry
/-- The constant `a`-history through the seam. -/
noncomputable def stayA : WorldHistory FA.toTaskFrame := sorry
/-- The history that stays at `a` through `w` and is at `b` afterwards. -/
noncomputable def jump (w : ℤ) : WorldHistory FA.toTaskFrame := sorry

/-- **The seam's step paths, classified.** -/
theorem path_classify {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (t : ℤ)
    (ht1 : (g t).1 = t) (ht2 : (g t).2 = a) :
    (∀ z, g z = (z, a)) ∨ ∃ w : ℤ, t ≤ w ∧ ∀ z, g z = (z, if w < z then b else a) := sorry

/-- **The seam's splices, identified as histories.** -/
theorem splice_classify (t : ℤ) (bf : SeqPair FA (stayA.state t)) :
    spliced stayA t bf = stayA ∨ ∃ w : ℤ, t ≤ w ∧ spliced stayA t bf = jump w := sorry

/-- **The truncation bound.** `HitCl` is already the family triples of finitely many splice
traces. The `∃ L` is essential: `L` comes from `Set.Finite.bddAbove`, so it is never exhibited
and NO computable bound follows. -/
theorem hitCl_eq_truncated (t : ℤ) (k : ℕ) (hk : 1 ≤ k) :
    ∃ L : ℕ, HitCl MA stayA t Fp k
      = familyTriples (clSig Fp) k (clTrace MA Fp t stayA)
        ∪ ⋃ w ∈ Set.Icc t (t + (L : ℤ)),
            familyTriples (clSig Fp) k (clTrace MA Fp t (jump w)) := sorry

abbrev QA (L : ℕ) := Fin 3 ⊕ Fin (L + 3)

/-- The explicit flag table over the closure alphabet of `Fp`; not `decide` of `clTrace`. -/
def labOf (L : ℕ) : QA L → (clSig Fp).preds → Bool := sorry
/-- Two gadgets, no step crossing the summands. -/
def stepOf (L : ℕ) : QA L → QA L → Bool := sorry

/-- **Run characterization, `⊆`.** -/
theorem runTrace_mem_of_isRun (t : ℤ) (L : ℕ) (ρ : ℤ → QA L)
    (hρ : IsRun (labOf L) (stepOf L) (clNow Fp) t ρ) :
    runTrace (labOf L) ρ = clTrace MA Fp t stayA
      ∨ ∃ w : ℤ, t ≤ w ∧ w ≤ t + (L : ℤ)
          ∧ runTrace (labOf L) ρ = clTrace MA Fp t (jump w) := sorry

/-- **Run characterization, `⊇`.** -/
theorem exists_isRun_runTrace (t : ℤ) (L : ℕ) :
    (∃ ρ : ℤ → QA L, IsRun (labOf L) (stepOf L) (clNow Fp) t ρ
        ∧ runTrace (labOf L) ρ = clTrace MA Fp t stayA)
      ∧ ∀ w : ℤ, t ≤ w → w ≤ t + (L : ℤ) →
          ∃ ρ : ℤ → QA L, IsRun (labOf L) (stepOf L) (clNow Fp) t ρ
            ∧ runTrace (labOf L) ρ = clTrace MA Fp t (jump w) := sorry

/-- **The headline.** `HitPresented` holds on fixture model A at the seam `(t, a)` of `stayA`
with `φ := Fp`, at every depth `k ≥ 1`, for an UNEXHIBITED `L` — so the Hit-level hypothesis is
satisfiable where `Presented` is refuted (`Probe735.not_presented`), and no computable bound is
delivered. Nothing about `PlusValidZTime`, nothing about `⊡(P p)`, nothing about general regular
ℤ-models. -/
theorem hitPresented_modelA (t : ℤ) (k : ℕ) (hk : 1 ≤ k) :
    ∃ L : ℕ, HitPresented MA stayA t Fp (labOf L) (stepOf L) k := sorry

end Probe745
```

## Bound Verdict: The Named Obligation

This section is NOT part of `## Lean Challenge Statements` and nothing here is a goal of this
plan. It is the record of what blocks the computable bound, to be transcribed into the probe
header and the README by Phase 8 and filed as a successor record.

The truncation proof's `L` comes from `Set.Finite.bddAbove` applied to `HitCl`, whose finiteness
comes from `finite_family_triples`. The argument never exhibits `L`, so it yields no bound at
all — not a bad one, not a non-elementary one, and not even on the fixture. The in-tree entry
point for an effective bound is `kTypeOf_listSeg_append_congr`, which makes
`m ↦ kTypeOf sig k (listSeg (replicate m ℓ))` a morphism into a finite semigroup; the threshold
consequence is not in the tree. The single lemma that would convert this route from
non-constructive to effective:

```
theorem kTypeOf_listSeg_replicate_eventually_periodic (sig : MonadicSignature)
    [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) (ℓ : sig.preds → Bool) :
    ∃ m₀ p, 0 < p ∧ ∀ m, m₀ ≤ m →
      kTypeOf sig k (listSeg (List.replicate (m + p) ℓ))
        = kTypeOf sig k (listSeg (List.replicate m ℓ))
```

provable from `kTypeOf_listSeg_append_congr` plus `kType_finite` by finite-semigroup idempotence.
It is STATED, NOT PROVED, and MUST NOT be landed as a `sorry` in this tree by this plan.

**The honest scope note, stated rather than smoothed over.** The record's acceptance branch 3 asks
for the bound obstruction to be "machine-checked rather than argued". A claim that NO computable
bound exists is not a Lean-statable property of this development, so it cannot be machine-checked
in the sense the other two branches use. What IS machine-checked, and what the user approved in
cycle 1 as the substitute, is (i) the landed theorem's axiom foot, which carries
`Classical.choice` and exhibits no bound, and (ii) the `∃ L` shape of the headline itself, which
states the non-exhibition in the theorem rather than in prose. The obligation above is the named
unit of successor work, not a discharged one.

## Testing & Validation

- [x] Phase 1's library edit builds under the guarded, detached, scoped invocation, together with
      its two enumerated direct dependents; the full project builds at Phase 8.
- [x] `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` exits 0
      with zero errors and zero warnings at the end of every phase from 2 onward.
- [x] Every one of the 17 pinned identifiers exists in the tree at its pinned signature, with no
      added hypothesis, specialized quantifier or weakened conclusion;
      `bash .claude/scripts/lean-challenge-snapshot.sh --check` reports no drift (ADVISORY — a
      drift finding is a signal to investigate, never an automatic verdict).
      *(Closed at Phase 8 by mechanical whitespace-normalized comparison of the Challenge
      block against the live tree, the snapshot gate being UNAVAILABLE for this record
      (exit 71, no manifest, never taken at plan time). All 24 declared identifiers exist.
      19 match byte-for-byte. `MA` and `stepOf` match on their full signature prefix — the
      only difference is that the comparison script swallowed their `where`/pattern-match
      bodies. `a`, `b` and `pa` are `def` where the block wrote `abbrev`: identical type and
      identical value, the `abbrev` form having been a plan-time device, already recorded and
      reasoned in the Phase 2 handoff against `presented-not-complete.lean`'s own `def`s. No
      added hypothesis, no specialized quantifier, no weakened conclusion anywhere.)*
- [x] Zero sorries and no vacuous `def X := True`-shaped placeholder in any touched `.lean` file.
      `labOf` and `stepOf` are `def`, not `noncomputable def`.
- [x] `#print axioms` on `hitPresented_of_presented` and on `hitPresented_modelA` reports exactly
      the profile recorded in the axiom-test pins and the probe foot — observed, not predicted.
- [x] `bash scripts/check-evidence-probes.sh` exits 0 with the new probe wired.
- [x] `bash scripts/check-module-invariants.sh` green, with the theorem-index row and the axiom
      pins landing in the same commit (C14) and the row anchored at its declaration (C15).
- [x] `bash .claude/scripts/verify-deploy.sh` green — the complete gate set, not a subset, not
      under `--skip-slow`.
- [x] Prose audit: no file under `FormalSystem/`, `docs/`, `Tests/`, `scripts/` or
      `specs/evidence/` attributes a decidability result, a decision procedure, or any statement
      about `PlusValidZTime` to this work; every new header carries the forward-only limit, the
      absent backward Bool-fixture bridge, the no-bound limit, and the non-generality of the
      fixture; no task-number citation outside `specs/**` (C9).
- [x] `Probe735.not_presented` still compiles and is still wired; nothing in this plan's output
      weakens, retires or contradicts it, and the README still records that the ray-product
      presentation as landed cannot deliver `Decidable (PlusValidZTime φ)`.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — `HitPresented`,
  `hitPresented_of_presented`, both with `Paper: —` anchors.
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — new wired probe: header,
  fixture, classification, splice identification, truncation bound, presentation, run
  characterization, `hitPresented_modelA`, `#print axioms` foot, bound verdict.
- `scripts/check-evidence-probes.sh` — the probe wired into `WIRED` with its table entry.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — axiom pins for the two library
  declarations.
- `docs/theorem-index.md` — one new row stating what the result does and does not deliver.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — (C)'s fixture-level status, probe
  inventory entry, recorded bound verdict.
- `specs/745_hit_level_completeness_computable_bound/summaries/01_*-summary.md` — the execution
  summary, including the successor-record description for the named bound obligation.

**file_scope** (set at plan time, as the record requires; harvested from the per-phase
`Files to modify` lists):
`FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean`;
`FormalSystem/Metalogic/Decidability/RaySummary/README.md`;
`specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`;
`scripts/check-evidence-probes.sh`;
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`;
`docs/theorem-index.md`.
Expected overlap with tasks 733, 734 and 739 on `RaySummary/` and
`specs/evidence/seam-gluing-ray-product/` plus `scripts/check-evidence-probes.sh`.

## Rollback/Contingency

- Every phase ends green and committed, so the ordinary contingency is to stop at the last green
  commit; no phase depends on an uncommitted predecessor.
- If Phase 6's run characterization cannot be carried out as written, that is the designed stopping
  point: mark Phase 6 `[BLOCKED]`, escalate per `rules/plan-compliance.md`, and leave Phases 7-8
  `[NOT STARTED]`. Phases 1-5 are independently valuable and stay landed — `HitPresented` in the
  library with its weakening lemma, the classification, the splice identification, the truncation
  bound and the presentation data are all true and useful without the headline. Do NOT substitute
  the rejected `mem_hitOf_iff_live` route and do NOT weaken a pinned statement to close the gap.
- If a phase must be reverted outright, do NOT emit a bare `git-snapshot.sh 745`: a genuine
  rollback that would discard uncommitted work follows `context/contracts/recovery.md`'s rollback
  rung for the exact invocation shape (including its out-of-scope override flag). For an ordinary
  defensive checkpoint before the Phase 6 attempt, use
  `bash .claude/scripts/git-snapshot.sh 745 --no-revert`, which is durable without reverting the
  working tree.
- The probe is a new file outside the Lake build graph, so reverting it cannot break the library
  build; the only cross-file couplings to undo together are the Phase 8 trio of probe wiring,
  axiom pins and theorem-index row (C14 requires the pins and the row in one commit).
