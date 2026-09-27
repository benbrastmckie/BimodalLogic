# Research Report: Task #680

**Task**: 680 - Record compression prerequisite satisfiable
**Started**: 2026-09-27T00:00:00Z
**Completed**: 2026-09-27T00:00:00Z
**Effort**: small (documentation/task-metadata only, no new mathematics)
**Dependencies**: None (task 680 has no dependencies of its own; task 623 depends on it)
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean`,
  `FormalSystem/Metalogic/Decidability/BiLasso/README.md`,
  `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`,
  `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean`,
  `FormalSystem/PlusLanguage/PlusDeterminism.lean`,
  `FormalSystem/Semantics/ShiftSet.lean`,
  `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`,
  `BimodalTools/README.md`, `specs/TODO.md` (tasks 623, 682, 685)
- Sibling repository: `~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/`
  (`ADEQUACY.md`, `SEARCH_COVERAGE.md`, `TRUST_PIPELINE.md`)
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Confirmed, by reading the consuming repository (`ModelChecker`) directly, that condition (iii)
  of its `ADEQUACY.md` §7.1 (the reduction condition task 623's compression item depends on being
  satisfiable) is now recorded as **satisfiable in principle** — both of its former prerequisites
  (a certificate export on the documented wire contract, and an independent pure-Python
  re-checker) are landed there — but the condition was **rewritten into five ordered sub-bullets
  (iii-a) through (iii-e)**, of which only (iii-a) is blocking, because the search space is
  **non-monotone** in the `back`/`mid`/`fwd` bounds (exact-modulus folding in
  `WitnessRegistry.wrap()`).
- No changes are needed on the consuming-repository side; task 680's own job is to record this
  correctly, here, so task 623's planning does not re-derive the prerequisite as missing or
  mistake "satisfiable" for "nearly done."
- On this side, two files carry a stale claim that must be corrected: `BiLasso/Assembly.lean`'s
  module docstring (line 23) and `BiLasso/README.md` (lines 23-28) both still call the
  `IntPresentation` small-model hypothesis `fmp` an **open** theorem. It is not open — it is
  **refuted for every candidate list**, machine-checked in
  `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`
  (`Probe476.fmp_false`), and the sibling module `WitnessFamily/README.md` already states this
  correctly. Task 623's item 3 (struck from that task's own description, delegated here) is
  exactly this correction plus a durable scope sentence.
- The durable scope sentence to add: the bi-lasso/witness-family decision procedure decides
  validity for `FormalSystem.Syntax.Formula` — the six-primitive language **without** the
  stability modal `⊡` (that lives only in `PlusLanguage.PlusFormula`) — and its witness models
  (`ShiftSet`-built, via `total_eq_orbit`, `Semantics/ShiftSet.lean:251`) are deterministic, on
  which `⊡` is semantically trivial (`stab_iff_of_deterministic`,
  `FormalSystem/PlusLanguage/PlusDeterminism.lean`). This is why the current device is silent on
  — not merely incomplete for — the stability modal, and it motivates task 685's separate
  branching-witness-structure line rather than an extension of this one.
- Recommend the planner also flag (but not necessarily fix) a pre-existing, unrelated staleness
  in `BiLasso/README.md`: it still uses the retired names `ValidDiscrete` /
  `validDiscrete_iff_check(Family)` / `decidableValidDiscrete(Family)` where `Assembly.lean`'s
  live declarations are named `ValidZTime` / `validZTime_iff_check(Family)` /
  `decidableValidZTime(Family)`. This sits in the same paragraph the fmp correction touches, so a
  planner should decide whether to fix it in the same pass or scope it out explicitly.

## Context & Scope

Task 623 (`Decidable validztime quasimodel shiftset route`) proves the completeness/compression
half of `Decidable (ValidZTime φ)`. It has four dependencies; three are complete, and task 680 —
this task — is its sole remaining blocker. Task 623's own description (`specs/TODO.md`) already
records that its item 3 (correcting `Assembly.lean`'s docstring and the `BiLasso/README.md`, plus
stating the language-without-stability-modal scope durably) has been struck and delegated here.
This task's job, purely documentary, is two-fold:

1. Record on this side that the reduction condition task 623 depends on being satisfiable
   (condition (iii) of the consuming repository's `ADEQUACY.md` §7.1) is now satisfiable in
   principle, carrying forward the non-monotonicity correction that came with that news, so task
   623's planning does not re-derive the prerequisite as missing or mistake "satisfiable" for
   "nearly done."
2. Absorb task 623's struck item 3: correct the `fmp`-is-open claim in `Assembly.lean` and
   `BiLasso/README.md`, and state the without-stability-modal scope sentence durably.

No new mathematics, no changes to `FormalSystem/` semantics, no changes anywhere in the consuming
repository (`ModelChecker`) are in scope.

## Findings

### Codebase Patterns (this repository)

**`Assembly.lean`'s stale claim** (`FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean:23`):

> "`fmp` is the one open theorem between this layer and decidability of `ValidZTime`."

This is false as written. `fmp` — `∀ ψ, ¬ ValidZTime ψ → ∃ P ∈ cands ψ, ∃ w : Fin P.card,
SatAtState P w ψ.neg` for a computable `cands : Formula → List IntPresentation` — is refuted for
**every** candidate list by `Probe476.fmp_false`
(`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`),
compile-checked (measures `[propext, Classical.choice, Quot.sound]`, no `sorryAx`) and guarded by
`scripts/check-evidence-probes.sh`. The witness: `ψ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` — satisfiable
over the ℤ-carrier `ShiftSet` but, by a pigeonhole-and-pump argument on any `IntPresentation`'s
finite state space, satisfiable at no state of any finite presentation. This is a genuine
refutation, not an open question or an engineering gap.

**`BiLasso/README.md`'s parallel stale claim** (lines 23-28, "## What decidability of
`ValidDiscrete` still needs"):

> "Exactly one theorem, and it is worth naming precisely so it is neither overestimated nor
> mistaken for engineering: `fmp` : ..."

Same defect, same fix needed. This section frames `fmp` as the single remaining theorem needed
for decidability, with no mention that it is refuted. The rest of that section (the
box-faithfulness discussion) remains accurate and does not need to change — only the "open theorem
still needed" framing needs the correction that `fmp` in this literal candidate-list-of-finite-
presentations form is closed, negatively.

**The sibling module already states this correctly.** `WitnessFamily/README.md:24-25` and
`WitnessFamily.lean:39` (this repository) both correctly cite `Probe476.fmp_false` as ruling out
a finite `IntPresentation` as the searched object. This is the citation form to mirror in
`Assembly.lean` and `BiLasso/README.md`.

**Pre-existing, unrelated staleness worth flagging (not part of this task's mandate but adjacent
to the exact text being corrected).** `BiLasso/README.md` names the live declarations
`ValidDiscrete`, `validDiscrete_iff_check`, `validDiscrete_iff_checkFamily`,
`decidableValidDiscrete`, `decidableValidDiscreteFamily`. The actual declarations in
`Assembly.lean` today are named `ValidZTime`, `validZTime_iff_check`,
`validZTime_iff_checkFamily`, `decidableValidZTime`, `decidableValidZTimeFamily`
(`Assembly.lean:58,65,84,90,110`). This is a separate rename-drift defect, not the `fmp`-status
defect task 680 was asked to fix, but it sits in the exact paragraph a planner will touch, so it
is recorded here for the planner to explicitly scope in or out rather than silently reproduce.

**The durable scope sentence — grounding for "language without the stability modal, witness
models deterministic, modal trivial."** `Assembly.lean` and `BiLasso/README.md` operate over
`FormalSystem.Syntax.Formula` (imported via `FormalSystem.Semantics.Validity`), the six-primitive
base language. The stability modal `⊡` is defined only in `FormalSystem.PlusLanguage.Formula`
(`PlusFormula`), a strict syntactic extension (`FormalSystem/PlusLanguage/Formula.lean:11-14`) —
`Assembly.lean`'s `ValidZTime` cannot even state a claim about `⊡`. Separately,
`WitnessFamily.std`'s certified histories are exactly the orbits of a `ShiftSet`
(`total_eq_orbit`, `FormalSystem/Semantics/ShiftSet.lean:251-256`: `σ = S.hist (σ.state 0)` for
every history `σ`), which is possible only because a `ShiftSet`'s `sh : Carrier → ↑D → Carrier`
is a plain (single-valued) function — the underlying task frame is deterministic by construction.
`FormalSystem/PlusLanguage/PlusDeterminism.lean` proves the general fact this specializes:
`stab_iff_of_deterministic` (and the singleton-bridge lemma `states_eq_of_deterministic` it rests
on) show `⊡φ ↔ φ` at every point of a deterministic frame — the stability modal is semantically
trivial there. Putting the two together: the decision procedure here decides `ValidZTime` for the
base language, and its witness models are exactly the kind of frame on which `⊡` collapses to the
identity, which is *why* the current device is silent on the stability modal rather than merely
incomplete for it (task 685's own description makes the same point from the opposite direction:
"Determinism is exactly what makes `ShiftSet.total_eq_orbit`... true... Record explicitly that the
stability modal collapses to the identity on deterministic frames..., which is why the current
device is blind to it by construction and cannot be extended by adding a truth clause").

**Task 623's TODO.md text is already current.** `specs/TODO.md`'s task 623 entry already lists
item 3 as "STRUCK -- DELEGATED, DO NOT DO IT HERE," already names task 680 as its sole
outstanding dependency, and already carries the non-monotonicity correction in its own words.
Nothing there needs to change as part of this task; it is cited here as confirmation that "this
development's own notes" for the *task-tracker* layer are already in the state task 680's
description asks for. What remains outstanding is exactly the two Lean-adjacent files identified
above (`Assembly.lean`, `BiLasso/README.md`), which are documentation but live in `FormalSystem/`,
not in `specs/`.

### External Resources (consuming repository: ModelChecker)

Read directly rather than relied on secondhand, at
`~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/`:

**`ADEQUACY.md` §7.1 ("A1 — compression, open, with the route named"), lines 548-641.** Confirms,
verbatim, every claim in task 680's description:

- A1 (the compression bound itself, matching task 623 item 1) is recorded as open; `(SOUND)` does
  not depend on it (line 565).
- The one candidate reduction from an already-landed Lean theorem
  (`exists_annot_of_truth`, `BiLasso/Extraction.lean:354`) is examined and rejected for three
  independent reasons: it is relative to a fixed presentation, its bound is `P.card`-dependent
  rather than `|C|`-only, and the missing premise is exactly what `Probe476.fmp_false` refutes.
- Condition (iii) — "this repository's search *represents* the compressed family at the
  configured `back`/`fwd`/`mid`" — is now **satisfiable in principle**, because "both
  prerequisites §6 supplies — the certificate export and the independent re-checker — are now in
  place" (line 616).
- The exact non-monotonicity measurement (lines 616-621): `WitnessRegistry.wrap()` folds
  `back`/`fwd` positions by exact period, so "one formula is SAT at `(back, mid, fwd) = (3, 1,
  3)` and `(6, 1, 6)` but genuinely UNSAT (`timeout=False`, sub-second) at `(4, 1, 4)` and `(5, 1,
  5)`, exactly as `6 ∤ 4`, `6 ∤ 5` predicts" — matching task 680's description exactly.
- Two candidate fixes, neither built: an `lcm`-based common-multiple bound (rejected as
  impractical, `e^{O(f)}` growth) or an `f^3`-cost grid sweep of `(back, mid, fwd)` up to the
  bound, "individually cheap but not yet built" (this is (iii-a), the sole blocking sub-bullet).
- Condition (iii) was rewritten into five ordered sub-bullets (iii-a) through (iii-e), lines
  619-640, of which only (iii-a) ("Fix the length space") is blocking — "without it, (iii) is
  unprovable rather than merely unproved." (iii-b) (represented-space specification), (iii-c)
  (closure agreement), and (iii-d) (witness-lasso budget cross-reference) are independently
  valuable now and do not wait on A1; (iii-e) (segment-length parity with the bound's shape)
  waits on A1 itself.

**`SEARCH_COVERAGE.md`** ("the divisor-period gap, three routes, and the decision") extends
`ADEQUACY.md` §7.1 (iii-a) specifically. It pins the non-monotonicity fact at two machine-checked
levels — `tests/unit/test_witness_registry.py`'s `TestWrapFoldsByExactPeriod` (the arithmetic
directly) and `tests/integration/test_search_period_coverage.py` (the end-to-end SAT/UNSAT
pattern, shown in both period-3 and period-2 directions) — and recommends the bounded grid sweep
over the `lcm` route, staging it as unbuilt work.

**`TRUST_PIPELINE.md`** classifies pipeline stages 4-5 (Python re-check, Lean re-check via `lake
exe check_certificate`) as "Decided per run" evidence — the strongest evidentiary class after
"Theorem" — confirming both of condition (iii)'s former prerequisites are genuinely landed, not
merely claimed. `ADEQUACY.md` §6.1-6.2 gives the wire contract (`back`, `mid`, `fwd`, `bx`,
`lassos`, `target` field names; `target.time` required with no default; atom identity base-only)
and the four-step dual-verification protocol (extract from Z3 model, decide independently in
Python, fail-fast on any non-`countermodel` verdict, cross-check against Lean's
`check_certificate` where present) — matching `BimodalTools/README.md`'s "Certificate
re-verification protocol" section and the `check_certificate` executable present in this
repository's own build (`.lake/build/bin/check_certificate`).

**Bound-magnitude claim already falsified, independent of (iii-a)'s fix.** Because
representability is a divisibility (period) question rather than a magnitude question, a bound of
the shape "segment lengths at least `f` of the closure size" is insufficient on its own even if
`f` is generous — a family with a period not dividing the configured length is unrepresentable no
matter how large the configured length is, unless it happens to be a multiple of that period.
This is the same fact task 680's description states; the consuming documents supply the exact
mechanism (`WitnessRegistry.wrap()`'s modulus fold) and the machine-checked instance.

## Decisions

- **No corrective work is needed in the consuming repository.** Its adequacy document already
  states condition (iii)'s status correctly, with the sub-bullet structure and the
  non-monotonicity caveat both already recorded there. This task's entire deliverable is on this
  side.
- **The `fmp`-is-open correction and the durable scope sentence are two edits, not a rewrite.**
  `Assembly.lean`'s module docstring (replace the sentence at line 23, citing `Probe476.fmp_false`
  the way `WitnessFamily.lean:39` already does) and `BiLasso/README.md`'s "What decidability of
  `ValidDiscrete`/`ValidZTime` still needs" section (replace the "exactly one theorem... still
  needed" framing at lines 23-28 the same way) each need the refutation stated, plus a short
  added sentence recording the scope: decides `ValidZTime` for the language without `⊡`, over
  deterministic (`ShiftSet`-built) witness models on which `⊡` is trivial.
- **The `ValidDiscrete`/`ValidZTime` naming drift in `BiLasso/README.md` is a separate finding**,
  reported for the planner to decide on rather than folded silently into this task's fix. It sits
  in the same section but is a different defect (a stale rename, not a stale open/refuted claim).
- **Task 623's own TODO.md description needs no edit from this task.** It already reflects the
  struck item 3 and the non-monotonicity correction in its own words; task 680's report (this
  file) is the durable record task 623's dependency chain points at, and task 623's description
  already cites "that task" (680) correctly.

## Risks & Mitigations

- **Risk**: a planner or implementer, seeing `BiLasso/README.md`'s `ValidDiscrete` naming
  alongside the `fmp` fix, either (a) silently renames it (mission creep beyond this
  documentation-only task) or (b) leaves it and a later reader is confused by two different
  defects fixed in one pass with no record of which is which. **Mitigation**: this report names
  the naming drift as a separate, explicitly flagged finding (see Decisions above) so the
  implementation plan can make a deliberate choice and record it, rather than have the two
  defects blur together.
- **Risk**: a future reader of `Assembly.lean`/`BiLasso/README.md` under-corrects — replacing
  "open" with "satisfiable" or "in progress" rather than "refuted" — which would re-introduce a
  version of the exact defect task 680 exists to fix (the compression task's planning would again
  read the small-model hypothesis as live rather than closed-negatively). **Mitigation**: this
  report states the required correction precisely ("refuted for every candidate list," with the
  witness formula and the citation) rather than leaving the wording to be improvised at
  implementation time.
- **Risk**: the durable scope sentence about the stability modal is written in a way that implies
  the decision procedure could be trivially extended to cover `⊡` by adding a truth clause. This
  is false and is exactly what task 685 exists to correct at the mathematical level (a genuinely
  new branching witness structure, not an addition to this one). **Mitigation**: the wording
  recommended above states explicitly that the device is silent on `⊡` "by construction," citing
  task 685's own framing, so it cannot be read as inviting a truth-clause patch.

## Context Extension Recommendations

- **Topic**: cross-repository status tracking for shared reduction conditions.
- **Gap**: there is no single documented convention in this repository's `.claude/context/` for
  how a task like 680 should point back at the exact consuming-repository document/section that
  motivated it (here, `ADEQUACY.md` §7.1, `SEARCH_COVERAGE.md`, `TRUST_PIPELINE.md`), beyond
  free-text task descriptions. Several sibling tasks (679, 677, 685) follow the same pattern
  ("the consuming repository's X document now states Y") independently.
- **Recommendation**: if this pattern recurs (it already has, at least four times among tasks
  623/677/679/680/685), consider a lightweight convention — e.g. a `consuming_repo_refs` field or
  a short "Cross-Repository Anchors" section template — so a future task doesn't have to
  re-discover the sibling repository's document layout from scratch each time. Not urgent enough
  to block this task's implementation.

## Appendix

### Search/read sequence used

1. Read the dispatch file and task 680's `state.json`/`TODO.md` entries.
2. Located task 623 (the consumer of task 680) and confirmed its item 3 is already struck and its
   dependency on 680 is already stated correctly in `specs/TODO.md`.
3. Identified the consuming repository as `~/Projects/ModelChecker` (per this repo's own
   `README.md`/`CLAUDE.md` "Logos dual-verification architecture… paired with a ModelChecker") and
   located `ADEQUACY.md`, `SEARCH_COVERAGE.md`, `TRUST_PIPELINE.md` under
   `code/src/model_checker/theory_lib/bimodal/docs/`.
4. Read `ADEQUACY.md` §6 (wire contract, dual verification) and §7.1 (A1/condition (iii),
   sub-bullets iii-a through iii-e) in full, and skimmed `SEARCH_COVERAGE.md` §1 and
   `TRUST_PIPELINE.md`'s pipeline table for corroboration.
5. Located this repository's `Assembly.lean` and `BiLasso/README.md`, confirmed both call `fmp`
   "open"; located the correct citation form already in `WitnessFamily/README.md` and
   `WitnessFamily.lean`; confirmed the refutation itself in
   `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`.
6. Confirmed the base-language/stability-modal split (`FormalSystem.Syntax.Formula` vs.
   `FormalSystem.PlusLanguage.PlusFormula`) and the determinism/triviality chain
   (`ShiftSet.total_eq_orbit` → `PlusDeterminism.stab_iff_of_deterministic`) grounding the durable
   scope sentence.
7. Cross-checked task 623's, 682's, and 685's TODO.md descriptions for consistency with the above.

### Key citations (line-anchored)

- `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean:23` — the stale "open theorem" claim.
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md:23-28` — the parallel stale claim.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md:24-25`,
  `WitnessFamily.lean:39` — the already-correct citation form to mirror.
- `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean:1-13`
  — the refutation statement and witness formula.
- `FormalSystem/Semantics/ShiftSet.lean:251-256` — `total_eq_orbit`.
- `FormalSystem/PlusLanguage/PlusDeterminism.lean` — `states_eq_of_deterministic`,
  `stab_iff_of_deterministic`.
- `~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md:548-641`
  (§7.1), `:407-465` (§6.1-6.2).
