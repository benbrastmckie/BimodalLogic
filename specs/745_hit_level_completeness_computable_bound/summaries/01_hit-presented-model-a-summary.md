# Implementation Summary: Task #745

- **Task**: 745 - Requirement (C) of the ray-product verdict: Hit-level completeness with a computable bound -- settle HitPresented first
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-08T23:51:39Z
- **Completed**: 2026-10-09T00:51:00Z
- **Effort**: ~1.0 hours (phase 1 ~0.2, phase 2 ~0.25, phase 3 ~0.3, phase 4 ~0.25)
- **Dependencies**: None ((S) is an independent sibling record; (W) is downstream of both)
- **Artifacts**: plans/01_hit-presented-model-a.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Four single-phase dispatches of the eight-phase plan, each confined to one phase per its
dispatch's phase mission. **Phase 1** (dispatch 5) states the Hit-level hypothesis `HitPresented` in the
library beside `Presented` and records that it is strictly weaker, via
`hitPresented_of_presented`; both land sorry-free in
`FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` with the plan's required axiom foot.
**Phase 2** (dispatch 6) creates the evidence probe
`specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` with its full header, the
model-A fixture transcription, and the step-path classification `path_classify`. **Phase 3**
(dispatch 7) turns that classification into a statement about the seam's SPLICES
(`splice_classify`) and lands the explicit `clTrace` read-out over the five-letter closure alphabet
of `Fp` on both splice families, culminating in the two function-level forms `clTrace_stayA_eq` and
`clTrace_jump_eq` that make trace equality a rewrite. **Phase 4** (dispatch 8) lands the
truncation bound `hitCl_eq_truncated`: `HitCl` at the seam is exactly the family triples of
`stayA`'s closure trace together with those of the finitely many `jump w` for `t ≤ w ≤ t + L`,
for an `L` that is never exhibited. Phases 5-8 — the presentation data, the run
characterization, the assembly, and the wiring/pins/docs/bound-verdict — are NOT attempted and
remain `[NOT STARTED]`.

Nothing is claimed about requirement (C) itself by any of the four phases. `HitPresented` is a
*declaration*, not yet a *discharged* hypothesis: no model satisfies it in the tree, and the
fixture-level discharge is phases 3-7's work. Phase 2 lands no statement mentioning `HitCl`,
`hitOf` or `HitPresented` at all — what it lands is the rigidity fact the discharge will rest on,
and phase 3 lands none either: `clTrace` is the closure-alphabet trace of a history, not `HitCl`.
Phase 4 is the first to mention `HitCl`, and what it lands is still not (C): `hitCl_eq_truncated`
re-indexes `HitCl` finitely, saying nothing about any presentation and nothing about `hitOf`.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — +44 lines inside
  `section Presented`, after `hit_eq_hitOf_of_presented`:
  - `HitPresented` — a `def … : Prop`, body `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`:
    (C) at the HIT level, an equality of family-triple sets rather than of trace sets.
  - `hitPresented_of_presented` — `Presented → HitPresented` at every depth `k ≥ 1`, as the term
    `hit_eq_hitOf_of_presented M τ t φ lab step k hk hP`.
- `typst/generated/status.typ` — regenerated line count (347508 → 347552, exactly the +44 above)
  and commit/date stamp. Not a plan-declared file; staged because the blocking pre-commit gate's
  own remedy requires it (see Plan Deviations).
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — new, 276 lines (phase 2):
  - a 65-line header carrying every disclaimer the phase's task list mandates — what is
    established, the fixture, the argument in two sentences, the no-bound / forward-only /
    no-decidability / nothing-about-general-regular-ℤ-models limits, the non-generality of the
    fixture (model A's splices are eventually constant in both directions), the explicit statement
    that `Probe735.not_presented` is neither weakened nor retired, the decision held in place, the
    axiom record, and the compile line;
  - the fixture transcribed from `presented-not-complete.lean` (transcribed, never imported):
    `St`, `a`, `b`, `pa`, `Fp`, `RA`, `RA_fwd`, `RA_bwd`, `RA_aa`, `RA_ab`, `RA_bb`, `FA`,
    `instFARegular`, `ab_ne`, `MA`, `stayA`, `stayA_state`, `jump`, `jump_state`, `p_iff`,
    `Fp_iff`, `jump_p_iff`, `jump_Fp`;
  - the step-path classification: `stepA`, `time_eq` (the time component advances by one, so it is
    pinned by its value at `t`), `bwd_a` (`a` is reachable only from `a`, so the slice is pinned at
    `a` at and before the seam), `fwd_dichotomy`, `fwd_absorb` (`b` absorbs), and `path_classify`
    — every step path through `(t, a)` is the constant `a`-path or an `a`-then-`b` jump path with
    jump time `w ≥ t`;
  - a `#print axioms` foot over `path_classify`, `stayA` and `jump`.
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — +205/−9 lines (phase 3),
  272 → 472 lines. The 9 deletions are header-paragraph rewrites, not removed proof: the opening
  paragraph now says "parts 1-2" and names the splice identification and the read-out; the
  argument paragraph gains the transport sentence and the closure-size figure; the axiom-record
  paragraph names the three new pins. Added:
  - `splice_classify` at its pinned signature — every ray pair through the seam `(t, a)` of
    `stayA` splices to `stayA` itself or to `jump w` for some `w ≥ t`;
  - the alphabet, enumerated: `cl_Fp`, `cl_p`, `cl_top`, `cl_bot` (membership in
    `plusSubformulaClosure Fp`) and `letter_cases`, the five-letter exhaustion that makes the
    read-out's case analysis demonstrably complete;
  - ten pairwise-distinctness lemmas `now_ne_{Fp,p,top,bot}`, `Fp_ne_{p,top,bot}`,
    `p_ne_{top,bot}`, `top_ne_bot` — UNUSED in this phase, landed for phases 5-6;
  - two supporting falsity lemmas `stayA_p_false`, `stayA_Fp_false`;
  - the ten per-letter read-outs `clTrace_stayA_{now,Fp,p,top,bot}` and
    `clTrace_jump_{now,Fp,p,top,bot}`;
  - the two assembled `↔` forms `clTrace_stayA_apply`, `clTrace_jump_apply` and the two
    function-level forms `clTrace_stayA_eq`, `clTrace_jump_eq`;
  - a live `#eval (plusSubformulaClosure Fp).card` at the foot of the alphabet section, and three
    new `#print axioms` pins (`splice_classify`, `clTrace_stayA_eq`, `clTrace_jump_eq`).

- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — +98 lines (phase 4,
  dispatch 8; zero deletions), file now 563 lines. A new `## The truncation bound` section:
  - `jump_seam {w t : ℤ} (hw : t ≤ w) : (jump w).state t = stayA.state t` — every `jump w` with
    `w ≥ t` passes through the seam `(t, a)`, since at `t` itself the jump has not happened.
  - `exists_splice_eq (t) (σ) (h : σ.state t = stayA.state t) : ∃ bf : SeqPair FA (stayA.state t),
    spliced stayA t bf = σ` — the converse of `splice_classify`: every seam-passing history IS a
    splice. `seamOmegaEquiv`'s `symm_apply_apply` and nothing more.
  - `hitCl_covered (t) (k) : ∀ x ∈ HitCl MA stayA t Fp k, ∃ n : ℕ,
    x ∈ familyTriples … stayA ∨ x ∈ familyTriples … (jump (t + n))` — `hitCl_eq_iUnion` followed
    by `splice_classify`, with the jump time re-expressed as a natural offset from `t`.
  - `hitCl_eq_truncated (t) (k) (hk : 1 ≤ k)` — the phase headline, at the pinned signature:
    `∃ L : ℕ, HitCl MA stayA t Fp k = familyTriples … stayA ∪ ⋃ w ∈ Set.Icc t (t + L),
    familyTriples … (jump w)`. Added to the probe's `#print axioms` foot, reporting exactly
    `[propext, Classical.choice, Quot.sound]`.

## Decisions

- `HitPresented` is a `def … : Prop` whose body IS its pinned statement, so
  `hitPresented_of_presented` closes by definitional unfolding to `hit_eq_hitOf_of_presented`'s
  conclusion — a bare term application, no tactic block and no `unfold`/`show` step.
- Both docstrings carry the plan's three disclaimers explicitly: fixture-only, forward-only, and
  non-constructive (`∃ L` out of `Set.Finite.bddAbove`, so no bound). Neither mentions
  decidability, a decision procedure, or `PlusValidZTime` in any form — audited mechanically over
  the new block, whose only `Decidab`-shaped hits are the `[DecidableEq Q]` instance binders the
  pinned signature requires.
- Both docstrings state that `Probe735.not_presented` is NOT weakened or retired: that probe
  refutes a TRACE-set equality, `HitPresented` is a FAMILY-TRIPLE-set equality, the pumped trace's
  forward type is what the refutation turns on, and a type-level demand gives that argument
  nothing to bite on — so both hold of the same fixture at once.
- Phase 2 is a transcription, not a re-derivation. The research dispatch's compiled scratch file
  `rigid745.lean` was still present in the session scratchpad, so every tactic choice the report
  recorded as load-bearing transcribed verbatim and compiled green on the first attempt:
  `Int.induction_on` with case names `zero`/`succ`/`pred`; `push_cast at h ih ⊢` BEFORE the
  `show … by ring` rewrite in `bwd_a`; `simp only [not_exists]` in place of deprecated `push_neg`;
  an explicit `IsStepPath` hypothesis per theorem (this toolchain does not auto-include a
  propositional `variable`). No proof search was run and no alternative route was considered.
- Phase 2's `#print axioms` foot was added now rather than deferred to phase 7's assembly, because
  phase 2's own task list requires the header to carry "the axiom record" and an unverified record
  would have been prose. Phase 7 extends the foot to the headline.
- Phase 3's `splice_classify` needed no transport lemma. `WorldHistory.path` is
  `WorldHistory.state` by definition and `seamOmegaEquiv`'s `.symm` carries the seam condition
  `σ.state t = stayA.state t` as its `.2` field, so `path_classify` applies to
  `(spliced stayA t bf).path` directly and `WorldHistory.ext_state` lifts the pointwise result to a
  history equality. The plan's route was followed; no explicit `pathFibreEquiv` rewrite appears
  because the equivalence's definitional transparency made one unnecessary.
- The read-out's assembled forms deliberately avoid the distinctness lemmas: `clTrace_stayA_apply`
  and `clTrace_jump_apply` case on `letter_cases` in the forward direction and substitute via
  `rintro ... rfl` in the backward direction, so neither needs pairwise distinctness. The ten
  distinctness lemmas are landed anyway for phases 5-6's `labOf` flag-table case split and are
  recorded above as unused in this phase rather than left to look live.
- The read-out is stated at three strengths deliberately: per-letter (`clTrace_jump_p` and the
  nine siblings), assembled pointwise (`clTrace_jump_apply`), and function-level
  (`clTrace_jump_eq`). Phase 6's `runTrace (labOf L) ρ = clTrace MA Fp t …` obligations should
  discharge against the function-level forms, which is what makes "trace equality is a rewrite"
  literal rather than aspirational.
- The only `w`-dependence in a jump trace is the `p` letter's threshold: `now` at `t`, `⊤`
  everywhere, `Fp` everywhere (`b` absorbs, so a later `b` always exists), `⊥` nowhere, `p` exactly
  after `w`. That single threshold is what phase 5's presentation must reproduce and why distinct
  `w` give distinct traces.
- Nothing in phase 3 evaluates a `kTypeOf` or runs `decide` over `KType`, per the plan's Research
  Integration note (report D-2/D-3): the read-outs go through `clTrace_letter`/`clTrace_now` and
  `PlusTruthAt` only. The file's one `KType` occurrence is a docstring sentence saying so.

- **Phase 4: two choice sites named, not one.** The plan's task item asks for a comment naming
  where the non-constructivity enters (`Set.Finite.bddAbove`). The landed proof has TWO such
  sites and the section header names both: `choose!` picks a witnessing ray pair — hence, through
  `splice_classify`, a jump time — for each member of `HitCl`, and `Set.Finite.bddAbove` then
  asserts only that SOME upper bound of those offsets exists. Neither exhibits anything, which is
  why the `∃ L` shape is the recorded result rather than a presentational choice.
- **Phase 4: `Set.Finite.image` + `BddAbove`'s own `upperBounds` witness in place of
  `toFinset`/`Finset.sup`.** `((hitCl_finite …).image off).bddAbove` yields
  `⟨L, hL : L ∈ upperBounds (off '' HitCl)⟩` directly, so the `Set.Finite.toFinset` / `Finset.sup`
  bookkeeping the plan's Scope Hypothesis predicted as the dominant cost never arose. Both names
  were still re-resolved by name as the task item requires. This is not a route substitution: the
  plan's stated route is "`Set.Finite.bddAbove` on the image of the offsets to get `L`", which is
  exactly what was done.
- **Phase 4: one declaration-scoped linter suppression, documented in the docstring.** The pinned
  signature binds `(hk : 1 ≤ k)` and the truncation argument genuinely does not use it (`HitCl` is
  defined at every depth), so `unusedVariables` warned — colliding with the phase's zero-warnings
  bar. Renaming the binder to `_hk` would have altered the signature the phase's own verification
  requires verbatim, so the resolution is `set_option linter.unusedVariables false in` on that one
  declaration plus a docstring paragraph stating why `hk` is carried.
- **Phase 4: `exists_splice_eq` had to be a term proof, not `show`-then-`rw`.** Writing the
  `symm_apply_apply` goal out with `show` forced elaboration at `implicit` transparency and
  produced an application type mismatch between `{σ // σ.state t = stayA.state t}` and
  `Presheaf.StabFibre FA.toTaskFrame.toFibre.toTaskFrame t (stayA.state t)`, after which the `rw`
  found no pattern. `congrArg Subtype.val ((seamOmegaEquiv t (stayA.state t)).symm_apply_apply
  ⟨σ, h⟩)` compiles. Worth carrying into phase 6, which touches `IsRun` and may meet the same
  `toFibre.toTaskFrame` coercion wall.

## Plan Deviations

- **Task 1.3** (the `HitPresented` docstring) altered: the plan directs the docstring to say the
  hypothesis "is discharged in this tree … by the wired probe
  `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`". That file does not exist
  at phase 1 — the plan's own phase 2 creates it and phase 8 wires it — so the reference is
  written as a forward reference ("landed by this record's later phases"). Every other element of
  the item (Hit-vs-trace weakening, `presented_localRun` unavailable, finiteness by
  `kType_finite`, fixture-only, non-constructive, no bound, `Paper: —` anchor) is verbatim.
  Annotated inline on the plan's checklist item.
- **Phase 1 Scope Hypothesis** overrun, not a step deviation: predicted ~15-25 added lines,
  actual 44. The two declarations plus bodies are 12 lines; the remaining 32 are docstring prose
  the phase's own task list mandates in detail. Recorded in `issues.jsonl`.
- **Out-of-scope staged path**: `typst/generated/status.typ`. The pre-commit
  `typst-sync-check.sh` Check 2 gate BLOCKED the phase commit because the committed
  `formalsystem-line-count` lagged live by exactly the 44 lines this phase added. The gate's
  `--no-verify` bypass is explicitly reserved for drift caused by *another* writer, so it did not
  apply; the documented remedy (full `lake build`, then `typst-sync-check.sh --fix`, then stage
  the file) was run instead. Every later phase of this record that adds Lean lines will hit the
  same gate, and this path is not in the plan's `file_scope` — recorded in `issues.jsonl` so
  phases 2-8 expect it.
- **Phase 2 fixture transcription** altered: the plan's transcription list names 19 identifiers;
  `RA_aa`, `RA_ab`, `RA_bb` and `ab_ne` were transcribed as well, because `stayA`, `jump` and
  `bwd_a` do not elaborate without them. Also `a`, `b` and `pa` are landed as `def`, as in
  `presented-not-complete.lean` which the item names as the transcription source, rather than as
  the `abbrev` the plan's `## Lean Challenge Statements` block shows — that block states in its own
  preamble that the `abbrev` form was a plan-time device to make the declared identifier set equal
  the `**Goals**:` set, and none of `St`/`a`/`b`/`pa`/`Fp` is a pinned goal. Every identifier that
  IS pinned landed at its pinned signature with a real body. Annotated inline on the checklist.
- **Phase 2 Scope Hypothesis** overshoot, not a step deviation: predicted ~200-230 lines (header
  ~60, fixture ~50, classification ~110); actual 276 (header 65, fixture ~100, classification
  ~96). Header and classification estimates were accurate; the fixture estimate was low by ~50,
  because `jump`'s well-definedness proof plus the three `RA` step facts it and `stayA` consume do
  not fit in 50 lines. No scope beyond the plan's enumerated items was added. Recorded in
  `issues.jsonl`.
- **The pre-commit gate did NOT fire for phase 2**, refining phase 1's expectation: the
  `typst-sync-check.sh` Check 2 gate tracks `formalsystem-line-count`, and the probe lives under
  `specs/`, outside `FormalSystem/`. Phases 3-7 touch only that probe, so they will not hit the
  gate either; phase 8's `Tests/` edit may.
- **Phase 3: no step deviation.** All four checklist items were executed as written, in order,
  through the plan's named helpers (`clTrace_letter`, `clTrace_now`, `p_iff`, `Fp_iff`,
  `jump_p_iff`, `jump_Fp`), with the `#eval` re-derivation run before the case split as the item
  requires. No step was skipped, altered, deferred, inlined, or routed through a different lemma.
- **Phase 3 Scope Hypothesis** REFUTED-WITH-OVERSHOOT, not a step deviation: predicted 80-120
  added lines, actual 205 insertions / 9 deletions (net +196). The hypothesis named the wrong
  driver — it suspected the splice-to-step-path transport, which came in at 29 lines and compiled
  on the first attempt. The driver is the read-out item itself: "for each member of
  `plusSubformulaClosure Fp` plus `clNow`, give `clTrace` on `stayA` and on `jump w` explicitly" is
  10 per-letter lemmas, and with 4 membership facts, `letter_cases`, 2 falsity lemmas, 2 assembled
  forms and 2 function-level forms that is 21 mandated declarations before any supporting material;
  the forward-looking distinctness lemmas add ~22 lines more. Recorded in `issues.jsonl` as
  `class: scope-estimate`, `severity: minor`, per the item's own instruction.
- **Phase 3 process deviation**: the phase heading was not marked `[IN PROGRESS]` before the proof
  work began — it went from `[NOT STARTED]` straight to `[COMPLETED]` in a single plan-file write
  at phase end. The marker exists for crash recovery, so writing it retroactively after the phase
  was already green would have been false rather than useful. Recorded in `issues.jsonl`; no other
  step of the phase-checkpoint protocol was omitted.
- **Phase 3 added declarations beyond the item's literal enumeration**: `letter_cases`, the four
  membership facts, the ten distinctness lemmas, the two `stayA` falsity lemmas, and the two
  function-level `_eq` forms are not named individually in the checklist item. They are supporting
  lemmas the enumerated read-out requires (or, for the distinctness lemmas, that phases 5-6 will),
  not substitutes for any plan step — the plan's own `Goals, stated in prose` entry covers "the
  four-case closure-letter read-out lemma for the closure alphabet of the fixture formula". Flagged
  here rather than left implicit.

- **Phase 4: no step deviation.** All six checklist items were executed as written, in order, and
  the phase heading was marked `[IN PROGRESS]` before the first file write (correcting phase 3's
  process slip). Three named declarations beyond the item's literal enumeration were added
  (`jump_seam`, `exists_splice_eq`, `hitCl_covered`) — a decomposition REFINEMENT in the
  plan-compliance-safe direction (more named lemmas, never an inlining); no plan-named declaration
  was skipped, altered or re-routed, and `hitCl_eq_truncated` matches its pin verbatim.
- **Phase 4 Scope Hypothesis** CONFIRMED — the first confirmed one in this task: predicted 60-100
  added lines, actual 98 insertions by `git diff --stat`. The predicted DRIVER was wrong, as in
  phase 3: no `Finset.sup` bookkeeping arose at all. The cost was the three extra helper
  declarations and the section's prose header instead.

## Verification

- Build: Success. Scoped `FormalSystem.Metalogic.Decidability.RaySummary.Trace` (guard exit 0,
  1929 jobs); the two plan-enumerated direct dependents
  `FormalSystem.Metalogic.Decidability.RaySummary` (guard exit 0, 1931 jobs) and
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest` (guard exit 0, 2178 jobs); and the full project
  (guard exit 0, 2836 jobs, `Build completed successfully`). Zero `error:` lines across every
  captured stream. `Trace.olean` is newer than `Trace.lean`.
- Sorry count: 0, repo-wide, via `lean-sorry-census.sh --cross-check` over all eight resolved
  source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`.
- Sorry inventory: empty. None introduced, none inherited.
- Vacuous count: 1, unchanged from `HEAD~1` and pre-existing —
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`, where
  `intTimeHistory.domain t` genuinely reduces to `True`, so `trivial` is the honest proof. Zero
  introduced by this phase; the baseline is reported rather than rounded to 0.
- Axiom count: 14, unchanged from `HEAD~1` (verified by `git grep` at both revisions). No `axiom`
  added.
- Axiom foot: `#print axioms …hitPresented_of_presented` reports exactly
  `[propext, Classical.choice, Quot.sound]` — the list the plan's Phase 1 verification requires.
- Statement fidelity: both signatures confirmed against the plan's
  `## Lean Challenge Statements` entries by `#check @…` against the live build — same binders,
  same instance binders, same order, same conclusion.
- Comparator gate: not run. `compare_flag` is absent from the delegation context, so the gate's
  precondition is unmet and no `comparator` block is recorded.

### Phase 2 verification (dispatch 6)

- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
  through `lake-build-guard.sh`, detached, guard exit 0. Captured output is exactly the three
  `#print axioms` info lines — zero errors, zero warnings.
- Full project build re-run after the phase: guard exit 0, `Build completed successfully
  (2836 jobs)`, zero `error:` lines over both captured streams, `Trace.olean` newer than
  `Trace.lean`. Phase 2 touched no file in the Lake build graph (the probe is under `specs/`,
  which no Lake target root reaches), so this re-run confirms no regression rather than new
  coverage.
- Sorry count: 0, repo-wide, re-run via `lean-sorry-census.sh --cross-check` over all eight
  resolved source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`,
  `cross_check: MATCH`. `grep -c sorry` on the probe is 0.
- Vacuous count: 1 — unchanged, still the same pre-existing `int_domain_universal`. Zero in the
  probe.
- Axiom count: 14 — unchanged. No `axiom` added.
- Axiom foot, observed not predicted: `Probe745.path_classify`, `Probe745.stayA` and
  `Probe745.jump` each report exactly `[propext, Classical.choice, Quot.sound]`.
- Statement fidelity: `path_classify`'s landed signature was extracted from the probe and from the
  plan's `## Lean Challenge Statements` block and diffed mechanically — byte-identical, no added
  hypothesis, no specialized quantifier, no weakened conclusion.
- `lean-challenge-snapshot.sh --check`: UNAVAILABLE, not green. No snapshot manifest exists at
  `specs/745_hit_level_completeness_computable_bound/challenge/manifest.json` (none was taken at
  plan time), so the script refuses. The plan lists this check as ADVISORY; the mechanical diff
  above stands in its place for the one signature this phase lands.
- `Probe735.not_presented` untouched: `presented-not-complete.lean`'s last commit is still task
  735's own wiring commit, and nothing in the new probe imports, weakens or contradicts it.

### Phase 3 verification (dispatch 7)

- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
  exit 0. Captured output is exactly the `#eval` line (`4`) and the six `#print axioms` info lines
  — zero lines matching `error` or `warning`.
- Full project build re-run after the phase, detached through `lake-build-guard.sh`: guard exit 0,
  `Build completed successfully (2836 jobs)`, zero `error:` lines over the captured stream,
  `Trace.olean` (mtime 1791503825) newer than `Trace.lean` (1791503801). Phase 3 touched no file in
  the Lake build graph — the probe is under `specs/`, which no Lake target root reaches — so this
  re-run confirms non-regression rather than new coverage.
- Sorry count: 0, repo-wide, via `lean-sorry-census.sh --cross-check` over all eight resolved
  source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`.
  `grep -c sorry` on the probe is 0.
- Vacuous count: 1 — unchanged, still the same pre-existing `int_domain_universal`. Zero in the
  probe.
- Axiom count: 14 — unchanged. No `axiom` added.
- Axiom foot, observed not predicted: `Probe745.splice_classify`, `Probe745.clTrace_stayA_eq` and
  `Probe745.clTrace_jump_eq` each report exactly `[propext, Classical.choice, Quot.sound]`, as do
  the three phase-2 pins re-run in the same compile.
- Statement fidelity: `splice_classify`'s landed signature was extracted from the probe and from
  the plan's `## Lean Challenge Statements` block and compared by whitespace-normalized mechanical
  diff — identical, no added hypothesis, no specialized quantifier, no weakened conclusion.
- Closure-size figure: the plan's CARRIED-UNVERIFIED entry is now RE-DERIVED.
  `#eval (plusSubformulaClosure Fp).card` = 4, and `PlusFormula.subformulas Fp` printed as
  `[Fp, atom p, ⊤, ⊥, ⊥]`, so the four closure members are exactly those the plan names. The
  `#eval` is left live in the probe beside the case split, as the phase's verification requires.
- No `kTypeOf` evaluation and no `decide` over `KType` anywhere in the added proof: the file's only
  `KType` occurrence is a docstring sentence stating that fact.
- `lean-challenge-snapshot.sh --check`: UNAVAILABLE, not green — still no manifest at
  `specs/745_hit_level_completeness_computable_bound/challenge/manifest.json`. The mechanical diff
  above stands in its place for the one signature this phase lands.
- Comparator gate: not run. `compare_flag` is absent from the delegation context, so the gate's
  precondition is unmet and no `comparator` block is recorded.

### Phase 4 verification (dispatch 8)

- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
  exit 0. Captured output is exactly the `#eval` line (`4`) and the seven `#print axioms` info
  lines — zero lines matching `error` or `warning`.
- Full project build re-run after the phase, detached through `lake-build-guard.sh`: guard exit 0
  (Tier 1), `Build completed successfully (2836 jobs)` with zero `error:` lines over the captured
  stream (Tier 2), `Trace.olean` newer than `Trace.lean` (Tier 3). Phase 4 touched no file in the
  Lake build graph — the probe is under `specs/`, which no Lake target root reaches — so this
  re-run confirms non-regression rather than new coverage.
- Sorry count: 0, repo-wide, via `lean-sorry-census.sh --cross-check` over all eight resolved
  source roots — `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`. The
  probe's two `grep -n sorr` hits are both prose (the header's "zero sorries" and the new
  section's "cited or `sorry`-ed here").
- Vacuous count: 1 — unchanged, still the same pre-existing `int_domain_universal`. Zero in the
  probe.
- Axiom count: 14 — unchanged. No `axiom` added.
- Axiom foot, observed not predicted: `Probe745.hitCl_eq_truncated` reports exactly
  `[propext, Classical.choice, Quot.sound]`, as do the six earlier pins re-run in the same compile.
- Statement fidelity: `hitCl_eq_truncated`'s landed signature was extracted from the probe and from
  the plan's `## Lean Challenge Statements` block and compared by whitespace-normalized mechanical
  string comparison — identical, including the `∃ L : ℕ` prefix and the `hk` binder name. No
  supplied or computed `L`, no added hypothesis, no weakened conclusion.
- No `kTypeOf` evaluation and no `decide` over `KType` anywhere in the added region: grep over
  lines 462+ returns only the two prose occurrences, which name them as what is NOT done.
- `lean-challenge-snapshot.sh --check`: UNAVAILABLE, not green — still no manifest at
  `specs/745_hit_level_completeness_computable_bound/challenge/manifest.json`. The mechanical
  comparison above stands in its place for the one signature this phase lands.
- Comparator gate: not run. `compare_flag` is absent from the delegation context, so the gate's
  precondition is unmet and no `comparator` block is recorded.

## Impacts

- `path_classify` is the rigidity fact the whole positive construction rests on: it says the
  seam's step paths form a one-parameter family indexed by `w ≥ t` plus the constant path, and
  nothing else. Phase 3 has now turned it into a statement about the seam's SPLICES
  (`splice_classify`) through `seamOmegaEquiv` and `WorldHistory.ext_state`.
- `splice_classify` is what gives phase 4's classically-chosen per-member witnesses their natural
  offsets (`0` for `stayA`, `w - t` otherwise), which is the input `Set.Finite.bddAbove` is applied
  to in order to extract `L`. Without it the truncation argument has no index to bound.
- `clTrace_stayA_eq` and `clTrace_jump_eq` give both splice families' closure traces as explicit
  lambdas, so phase 6's `runTrace (labOf L) ρ = clTrace MA Fp t …` obligations are rewrites against
  a closed form rather than semantic arguments. `clTrace_jump_apply` additionally isolates the only
  `w`-dependence in a jump trace — the `p` letter's threshold — which is the single feature phase
  5's presentation has to reproduce.
- `hitCl_eq_truncated` is what phases 5-7 consume: it fixes the FINITE index (`stayA` plus
  `jump w` for `t ≤ w ≤ t + L`) that phase 5's `L + 6`-state presentation is built to realize and
  that phase 6's run characterization must match exactly. It also fixes, once and for all, the
  shape of this record's headline: because `L` arrives unexhibited, `hitPresented_modelA` can only
  ever be an `∃ L` statement, and any later phase that appeared to supply an `L` would be proving
  a different, stronger theorem than this plan authorizes.
- The bound verdict is now machine-visible rather than argued, in the only sense available: the
  landed theorem's `∃ L` prefix states the non-exhibition in the statement, and its axiom foot
  carries `Classical.choice`. Non-existence of a computable bound remains not a Lean-statable
  property, so this is the substitute the user approved in cycle 1, not a discharge of acceptance
  branch 3's literal wording.
- The probe is NOT yet in any gate: it lives under `specs/`, which no Lake target root reaches, so
  `lake build` never compiles it and it can rot silently until phase 8 wires it into
  `scripts/check-evidence-probes.sh`. Until then its only check is the explicit `lake env lean`
  compile line in its own header.
- `HitPresented` is now a declaration in `FormalSystem.Metalogic.Decidability.RaySummary`, so
  phases 2-7's probe can discharge a library name rather than a local one, and the ray-product
  verdict's requirement (C) has a formal statement to be measured against.
- `hitPresented_of_presented` fixes the hypothesis ordering formally: anything proved under
  `Presented` transfers to `HitPresented` at `k ≥ 1` for free, so the two hypotheses need not be
  carried separately downstream.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` now contains a FALSE claim in three
  places — the `(C)` requirements-table row and two prose occurrences say `HitPresented` "is not
  a declaration in this tree". Phase 8 owns that README update; flagged in the phase handoff.

## Follow-ups

- Phases 5-8 of `plans/01_hit-presented-model-a.md`, all `[NOT STARTED]`. Phase 5 (the
  presentation data) is next and touches only the probe file: `QA L := Fin 3 ⊕ Fin (L + 3)` with
  `Fintype`/`DecidableEq` from the `Sum`/`Fin` instances, `stepOf` with its no-cross-step lemma
  (phase 6 cites it), and `labOf` as an explicit flag table rather than `decide` of `clTrace`.
  Both must be `def`, never `noncomputable def`. The plan's "re-derive
  `(plusSubformulaClosure Fp).card` before finalizing the table" item is ALREADY discharged — the
  `#eval` printing `4` is live in the probe from phase 3 — so phase 5 should cite it rather than
  re-run it.
- The `∃ L` shape is now load-bearing for phase 7: `hitPresented_modelA` must keep its own `∃ L`
  prefix, because `hitCl_eq_truncated` supplies no `L` to pass down. A phase 7 that appeared to
  exhibit an `L` would be landing a theorem this plan does not authorize.
- Phase 6's run characterization remains the plan's single Medium-confidence, uncompiled link. If
  it cannot be carried out as written, the plan requires marking it `[BLOCKED]` rather than
  substituting the rejected `mem_hitOf_iff_live` route or weakening the pinned statement.
- Phase 8 owes: the README verdict update, `docs/theorem-index.md` rows for both new
  declarations, axiom pins in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` in the
  same commit as the index rows, and the recorded bound verdict. Both docstrings already end with
  a `Paper: —` anchor line so the index rows are admissible when they land.
- The `typst-sync-check.sh` Check 2 gate blocks a commit only when `FormalSystem/` line counts
  drift; phases 2 and 3 both confirmed it does not fire for the `specs/`-resident probe, so phases
  4-7 need not budget for it. Phase 8's `Tests/` axiom-pin edit may still trip it.
- The ten distinctness lemmas phase 3 landed (`now_ne_*`, `Fp_ne_*`, `p_ne_*`, `top_ne_bot`) are
  currently unused. If phases 5-6 turn out not to need them either, they should be removed rather
  than left as dead weight in a wired evidence probe.
- No Challenge snapshot manifest exists for this record, so the advisory
  `lean-challenge-snapshot.sh --check` drift gate is unavailable for all 17 pinned identifiers.
  Each phase has been diffing its own landed signature against the plan's pin by hand instead.

## References

- `specs/745_hit_level_completeness_computable_bound/plans/01_hit-presented-model-a.md` — the plan,
  Phase 1 and the `## Lean Challenge Statements` pins.
- `specs/745_hit_level_completeness_computable_bound/reports/01_hit-level-completeness-probe.md` —
  the research the plan executes.
- `specs/745_hit_level_completeness_computable_bound/handoffs/phase-1-handoff-20261008T235902Z.md`,
  `handoffs/phase-2-handoff-20261009T001229Z.md`,
  `handoffs/phase-3-handoff-20261009T003531Z.md` and
  `handoffs/phase-4-handoff-20261009T005104Z.md` — the four phase-end handoffs, each with its next
  action and carried constraints.
- `specs/745_hit_level_completeness_computable_bound/issues.jsonl` — the three scope-hypothesis
  overruns, the pre-commit gate collision, phase 3's first-try-compile win, and phase 3's
  `[IN PROGRESS]`-marker process deviation.
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — the two new declarations.
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` — the probe: header,
  fixture, `path_classify`, `splice_classify`, and the closure-letter read-out.
- `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` — `Probe735.not_presented`,
  the trace-level refutation these docstrings and the new probe's header are careful not to
  weaken, and the transcription source for the fixture.
