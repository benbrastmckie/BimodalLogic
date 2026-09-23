# Implementation Summary: Task #661

- **Task**: 661 - Settle the Saturation vs Completion question by probe, and judge the outcome against a primitives-level foundation criterion
- **Status**: [COMPLETED]
- **Started**: 2026-09-23T16:50:58Z
- **Completed**: 2026-09-23T18:01:03Z
- **Effort**: ~1.5 hours wall clock (most of it full-library rebuilds)
- **Dependencies**: 660 (completed); 657 (frame-constraint audit, R1/R4 origin)
- **Artifacts**: plans/01_settle-saturation-vs-completion.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The verdict is **R4**, and it now rests on two machine-checked facts rather than on one plus an
open question. *Completion* is a **strict** weakening of *Saturation* — a separating frame is in
the library — and it is the only one of the two candidates statable in `def:frame`'s own
primitives. The Lean-side and ledger-side half of R4 is landed: the condition is declared over a
bare task relation beside the other three constraints, both probes are promoted out of `specs/`
into the library as permanent witnesses, the finitary case is discharged, and no in-tree prose
still records the converse as open. No manuscript file was touched, and
`check-paper-definitions.sh` confirms all 43 pinned definitions are unchanged.

## The verdict, and what carries it

**R4: `def:frame`'s fourth constraint should be the bare *Completion* clause.** Two independent
grounds, each now checked:

1. **Strictness.** `StateTopology.SeparatingFrame.srel` — unit-speed drift on `ℚ` over `ℤ`-time,
   `w ⇒ₓ v` iff `|v − w| ≤ |x|` — satisfies *Seriality*, *Compositionality*, *Limit* and
   *Completion* while failing *Saturation*. So `Completion → Saturation` is **false**,
   unconditionally. *Saturation* is therefore strictly more than `thm:extension` needs.
2. **The primitives criterion.** `TaskFrame.Completion` quantifies over an index set inside `D`
   and a family of states coherent under `⇒`, and mentions nothing else: no `Fib`, no
   fibre/segment classification, no notion of history. *Saturation* fails this test on both
   counts — it needs the fibre and segment classification to pick out eligible members, and its
   directedness side condition is stated in subset inclusion with no reference to the task
   relation at all. The `PartialHistory`-shaped form plus `completion_iff_coherentCompletion`
   reads as a recognition lemma (zero frame constraints, two constructor applications), not as a
   definitional dependency on histories, which is exactly what the criterion asks for.

**The primary probe answered negatively, and that is itself a result.** The rational two-origin
carrier fails *Completion* as well as *Saturation*
(`RationalTwoOrigins.not_rel_completion`), so it is not the separator. The pinching argument
generalises: over a **dense** temporal order a coherent family accumulating at `z` forces the
witness onto a single real number, so **no dense-time drift frame separates the two conditions**.
The separation is a discreteness phenomenon, which is why the separator is over `ℤ`-time.

**The infinitary quantifier is essential.** The finitary form of *Completion* follows from
*Compositionality* and *Seriality* over any temporal order
(`PartialHistory.completion_of_finite_domain`), while the rational carrier satisfies
*Compositionality* and fails *Completion*. Hence no condition implied by *Compositionality* can
be equivalent to *Completion* — in particular no finitary and no two-point form (the two-point
case for `s ≤ z ≤ t` is `TaskFrame.Interpolates`, one half of *Compositionality*).

## What Changed

- `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.Completion`, the bare-relation form of the
  proposed fourth constraint, sited after `TaskFrame.Limit` in the "frame axioms in bare-relation
  form" section; the section docstring extended; the in-source `longFile` baseline raised
  2700 → 2900.
- `FormalSystem/Semantics/Extension/Completion.lean` — `CoherentCompletion` redefined as
  `TaskFrame.Completion F.TaskRel`; `coherentCompletion_iff_rel` (`Iff.rfl`); the pointwise
  `NearestAt` with `HasNearest` redefined over it; `completion_of_nearest_at` carrying the
  argument; `completion_of_hasNearest` re-derived in one line with its statement unchanged;
  `nearestAt_of_finite`; `completion_of_finite_domain`; the verdict section rewritten and a new
  module-docstring subsection on the infinitary quantifier.
- `FormalSystem/Semantics/Extension/Step.lean` — the settled strictness recorded beside the
  sole-elimination-site measurement, which is kept verbatim.
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` —
  `RationalTwoOrigins.not_rel_completion` with its Newton-iteration and coherent-family support
  (251 lines), and the new `SeparatingFrame` namespace (`srel`, `srel_iff`, `srel_of_nonneg`,
  `srel_serial`, `srel_compositional`, `srel_limit`, `srel_completion`, `mem_sseg`, `straddle`,
  `lt_of_straddle`, `not_srel_saturation`, `TotalComp`, `not_srel_totalComp`); one new Mathlib
  import and one new intra-library import; the module docstring's independence matrix extended
  with a fifth, separating row and its packaging-asymmetry note widened. 775 → 1,372 lines.
- `docs/theorem-index.md` — five new rows, all four pinned declarations marked `pinned:C14`.
- `FormalSystem/Semantics/StateTopology/README.md`, `FormalSystem/Semantics/Extension/README.md`,
  root `README.md` — new witnesses described, generated inventory blocks regenerated, hand-kept
  line counts updated.
- `scripts/check-module-invariants.sh` — four new C14 axiom pins (the sanctioned C14-block edit).
- `scripts/module-invariants-allowlist.txt` — two C5 entries for the new namespace and
  declaration names, which are module-*shaped* but are not modules.
- `<formal source_dir>/context/project/logic/domain/frame-constraint-landscape.md` (new, 159
  lines) and the matching `index-entries.json` entry, in the resolved source store at
  `/home/benjamin/.config/nvim/agent-system/extensions/formal` — never under `.claude/`.

## Decisions

- **`TaskFrame.Completion` sits in the section variable block**, so it carries the same four
  duration instances `Saturation` does. No `omit` was needed and no ambiguity with
  `PartialHistory.Completion` arose at any site, so nothing was qualified and the predicate was
  not renamed.
- **The `Extension.Completion` import route was taken in Phase 3**, not the pre-authorised inline
  ℤ fallback: `hasNearest_int` is consumed directly, no instance diamond appeared, and
  `check-metalogic-cycles.sh` is clean with the new edge.
- **No `longFile` baseline was added to `ConstraintWitnesses.lean`** — at 1,372 lines it is under
  the 1,500 limit, and the plan requires a baseline if and only if the limit is crossed.
  `TaskFrame.lean` did cross its own 2,700 baseline and was raised to the linter's suggested
  2,900.
- **C14 pinning: yes.** `RationalTwoOrigins.not_rel_saturation` was already pinned, and the new
  results are this task's headline claims, so `not_rel_completion`, `srel_completion`,
  `not_srel_saturation` and `completion_of_finite_domain` were added to the C14 baseline and its
  `#print axioms` list.
- **The probes were left in place unmodified**, as the plan requires, even though promotion makes
  them uncompilable in situ (see Plan Deviations).

## Plan Deviations

- **Phase 1 — added**: `TaskFrame.lean` crossed its in-source `longFile` baseline at 2,701 lines;
  the existing `set_option linter.style.longFile 2700` was raised to the linter's own suggested
  2900 and its comment extended. Sanctioned under invariant C30, in exactly the form Phase 3
  pre-authorises for `ConstraintWitnesses.lean`.
- **Phase 5 — altered**: the plan's sweep command is line-based and misses the one real hit,
  because `Extension/Completion.lean`'s sentence is wrapped across two source lines ("… which is
  left / open"). A wrap-tolerant regex was run instead and found exactly that site. Separately,
  `Extension/Step.lean` carried no claim that the question was open, so the settled verdict was
  **added** there rather than a sentence corrected. No fourth site exists.
- **Phase 6 — altered**: one `check-module-invariants.sh` run was invalidated by my editing that
  script while the run was still reading it (bash reads scripts incrementally and reported a
  spurious syntax error at line 2836). The script is intact — `bash -n` is clean — and the gate
  was re-run from a quiet tree; the recorded result is the re-run.
- **Phase 7 — altered**: the plan's cross-check "re-run both source probes under the linted
  invocation" is **unsatisfiable as written**, and the plan's own goal is why. Both probes import
  `StateTopology/ConstraintWitnesses.lean`, and Phases 2 and 3 put the probes' own declarations
  into that module, so compiling a probe in place now produces 18 and 12 errors respectively —
  **every single one of them `has already been declared`, and not one a mathematical failure.**
  The substantive check was performed by a route that is available: each probe was copied to a
  scratch file with **only its namespace renamed** (`RationalTwoOrigins` → `…Probe`,
  `SeparatingFrame` → `…Probe`) and recompiled against the current library under the same linted
  invocation. Both exit 0, and `#print axioms` on all seven probe theorems reports exactly
  `propext`, `Classical.choice`, `Quot.sound`. The one warning is a `longLine` on the renamed
  `#print axioms` line, which the rename itself pushed from 97 to 102 characters — an artifact of
  the copy, not of the probe. So the probes' own proof scripts still elaborate verbatim against
  the promoted library, which is what the cross-check was for.
- **Phase 7 — added**: a reflow in Phase 1 left a docstring line beginning with the word "axiom",
  which the crude `grep -rn "^axiom "` census counts as a new axiom declaration. The line was
  rewrapped so the census stays honest. No `axiom` declaration was ever added — C2 and C14 both
  pass against their baselines.

## Verification

- Build: **Success** — `lake build` via the guarded, detached invocation: 2,725 jobs, guard exit
  0, **zero** `error:` lines and **zero** `warning:` lines. Green at every phase boundary
  (Phases 1, 2, 3, 4, 5 and final).
- Sorry count: **0** (`lean-sorry-census.sh` over the four resolved source roots:
  `sorry_count: 0`, empty inventory). `check-module-invariants.sh`'s C3 independently reports a
  zero structural sorry inventory across `FormalSystem/` and `BimodalTools/`.
- Vacuous count: **0 attributable to this task.** The single-line grep reports one hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`
  (`int_domain_universal … := trivial`), which is byte-identical at the pre-task baseline
  commit `bf707543f`, is not in this task's file scope, and is not vacuous in substance:
  `intTimeHistory.domain` **is** the universally true predicate, so `trivial` is the honest
  proof of it.
- Axiom count: **14, unchanged** from the pre-task baseline on identical roots. The transient
  reading of 15 was the docstring false positive recorded under Plan Deviations, now removed.
  At declaration level, C2's four flagship sets and C14's full pinned set — now including the
  four new declarations — match their baselines exactly.
- `#print axioms`: every one of the eleven pinned declarations reports exactly `propext`,
  `Classical.choice`, `Quot.sound`. (`completion_iff_coherentCompletion` and
  `coherentCompletion_iff_rel` report `[propext]` alone.)
- Gates: `check-module-invariants.sh` **ALL CHECKS PASSED** (C15: 61 anchors resolve, 191
  theorem-index rows anchored; C5: 14 allowlisted; INV: inventory blocks current);
  `check-paper-definitions.sh` exit 0 — **all 43 recorded definitions unchanged**;
  `check-evidence-probes.sh` exit 0 — all 5 wired probes compile (task 660's repair did not
  regress); `check-metalogic-cycles.sh` exit 0; `check-copyright-headers.sh` exit 0 (0 missing of
  559); `readme-lint.sh` exit 0.
- No manuscript edit: `docs/reference/paper-definitions-of-record.md` is byte-identical
  (sha256 `89fad0c30066722948c8235516d12a9e43a68f280a13a67af39a9f2f8ffdc4a7`), and
  `git status --short` on it is empty.
- Files verified: Yes.

## Impacts

- `def:frame`'s candidate fourth constraint is now **statable** in the library at the primitives
  level, so the manuscript pass has an in-tree anchor to cite rather than a draft to re-derive.
- The independence matrix in `ConstraintWitnesses.lean` gains a fifth, *separating* row, and the
  packaging-asymmetry note now covers it honestly: both `ℚ`-carrier rows are bare-relation
  certificates with no `FrameOver` wrapper.
- A dead search is closed with a recorded reason: no dense-time drift frame can separate the two
  conditions, so the next reader does not re-run the primary probe.
- `ConstraintWitnesses.lean` now imports `Extension/Completion.lean`. It remains a leaf — nothing
  under `FormalSystem/` imports it — so the edge adds weight to nothing else.

## Follow-ups

- **The manuscript pass implementing R4**: restate `def:frame`'s fourth clause `Fib`-free, delete
  its opening directed-family clause, and demote *Saturation* to a remark that keeps the
  ball-space footnote. Deliberately not done here; `def:frame` is a pinned anchor.
- **The `FrameOver.IsRegular` field swap**: turn the `saturation` field into a `completion` field
  and supply *Completion* analogues at the five transport sites (`FrameOver.rev_isRegular`,
  `FrameOver.map`, `FrameOver.translationProduct`, `regionFrame_saturation`,
  `zTaskFrameV2_saturation`).
- **Redeploy `.claude/`** is the user's call. The deployed tree was already flagged stale for
  `core` at dispatch, and Phase 8's file was written to the source store, not the deploy.
- **The probes can no longer be compiled in place** now that their contents are in the library.
  If the reproduction record should stay mechanically checkable, the probes need their namespaces
  suffixed (the scratch copies used in Phase 7 show the one-line change that suffices), or they
  should be retired in favour of the promoted declarations.

## References

- `specs/661_settle_saturation_vs_completion_foundation/plans/01_settle-saturation-vs-completion.md`
- `specs/661_settle_saturation_vs_completion_foundation/reports/01_saturation-vs-completion-verdict.md`
- `specs/661_settle_saturation_vs_completion_foundation/probes/CompletionRationalTwoOrigins.lean`
- `specs/661_settle_saturation_vs_completion_foundation/probes/SeparatingFrame.lean`
- `specs/661_settle_saturation_vs_completion_foundation/.decisions.json` (the cycle-4 R4 answer)
- `specs/661_settle_saturation_vs_completion_foundation/handoffs/` (per-phase records)
- `docs/reference/paper-definitions-of-record.md` (read, unchanged)
