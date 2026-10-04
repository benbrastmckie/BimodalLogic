# Implementation Summary: Task #724

- **Task**: 724 - Decidability of Z-time provability as a corollary of `Compression.decidableValidZTime`
- **Status**: [COMPLETED]
- **Started**: 2026-10-04T10:39:21Z
- **Completed**: 2026-10-04T10:56:00Z
- **Effort**: ~0.3 hours
- **Dependencies**: None (task 723 completed; its C14 trailing-block rows are the shape this task extends)
- **Artifacts**: plans/01_decidable-ztime-provability-corollary.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`Decidable (Derivable FrameClass.ZTime [] φ)` now exists, compiles, and is machine-pinned.
`FormalSystem/Metalogic/ZTimeProvability.lean` composes three already-landed results —
`soundness_ztime_valid`, `BXCanonical.derivable_of_validZTime` and
`Decidability.Compression.decidableValidZTime` — into a biconditional and then a decision
procedure, closing decidability of provability over ℤ without the verified tableau spine. All
five plan phases are complete; the full `lake build` and the build-backed
`scripts/check-module-invariants.sh` are both green.

## What Changed

- `FormalSystem/Metalogic/ZTimeProvability.lean` — **created**. Two declarations, three imports,
  namespace `FormalSystem.Metalogic`:
  - `theorem derivable_iff_validZTime (φ : Formula) : Derivable FrameClass.ZTime [] φ ↔ ValidZTime φ`
    — the anonymous constructor. The forward leg is `fun h => h.elim (fun d => soundness_ztime_valid d)`:
    the `Nonempty` elimination is required because `Derivable fc Γ p` is literally
    `Nonempty (DerivationTree fc Γ p)`, and the target is a `Prop`, so it introduces no choice.
    Backward leg is `BXCanonical.derivable_of_validZTime φ`.
  - `def decidableDerivableZTime (φ : Formula) : Decidable (Derivable FrameClass.ZTime [] φ)` —
    `letI := Decidability.Compression.decidableValidZTime φ` then
    `decidable_of_iff (ValidZTime φ) (derivable_iff_validZTime φ).symm`. A `def`, not an
    `instance`, matching its two siblings.
  - Docstrings carry all three qualifiers (`FrameClass.ZTime`; `Formula`, which has no stability
    operator; empty premises `[]`), the without-the-spine record, the three verified durable
    anchors (the `Provable.lean` row in `Decidability/Verified/README.md`, the
    "`validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous" section of
    `Decidability/Correctness.lean`, and the Status section of `Decidability.lean`), `Paper: —`
    with a reason, and a pointer to the compression assembly header for cost rather than any
    restated bound. No task number, no unqualified "TM is decidable", no complexity claim, no
    live debug artifact.
- `FormalSystem.lean` — one import line, in code-point-sorted position between
  `Metalogic.WeakCanonical.TruthLemma` and `MinusLanguage`.
- `FormalSystem/Metalogic.lean` — one appended re-export import. No SORRY-FREE docstring bullet
  added (deliberate: its subject would have been unpinned at that point).
- `docs/theorem-index.md` — one `### Decidability` row, six cells, fully qualified Lean name,
  path-only File cell, `pcq pinned:C14`.
- `scripts/check-module-invariants.sh` — the C14 matched pair (one baseline line, one
  `#print axioms` line) appended as the new trailing line of **both** heredocs at the same
  relative position, plus the adjacent descriptive comment reconciled: "final three lines" →
  "final four lines", the fourth name added to the enumeration, and the stale "is expected to
  join this trailing block once it lands" paragraph replaced with a statement that it has landed,
  naming the module.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
  `typst/generated/status.typ` — regenerated, not hand-edited (see Plan Deviations).

## Decisions

- **Placement followed the research measurement, not the dispatch's suggestion.** The module sits
  at `FormalSystem/Metalogic/ZTimeProvability.lean` (+2 net-new transitive imports) rather than
  under `WitnessFamily/Compression/` (+331 / +318). The measurement held: the aggregator rebuild
  was incremental and `FormalSystem.MainResults` built clean in the same pass, with no cycle.
- **The biconditional stayed its own `theorem`**, not inlined, so no `def` body carries a `↔`
  token.
- **The optional `specs/ROADMAP.md` checkbox was not ticked.** The immediately preceding
  checkbox, for the already-completed task 723, is also still unticked, so this repository's
  roadmap checkboxes are evidently not maintained per-task by the implementation dispatch;
  ticking only this one would have made the two adjacent rows inconsistent. Explicitly optional
  and outside acceptance.

## Plan Deviations

- **Phase 1 / Phase 2 commit granularity** altered: the plan specified `per-substep` commits and
  one commit per phase, but Phase 1 alone is not committable. The pre-commit
  `typst-sync-check.sh` Check-2 gate refuses any commit that adds a `.lean` file under
  `FormalSystem/` without the matching `FormalSystem.lean` import line, so Phases 1 and 2 landed
  as one commit (`d89d3ad7f`).
- **Phase 2 scope hypothesis** altered: it asserted exactly two import-line insertions in two
  files. Adding a `.lean` file under `FormalSystem/` additionally invalidates three
  machine-generated README inventory blocks and `typst/generated/status.typ`. Both were
  regenerated by their own scripts (`check-module-invariants.sh --emit-inventory` and
  `typst-sync-check.sh --fix`), never hand-edited. The +2 net-new-import part of the hypothesis
  itself held.
- **Phase 3's optional roadmap checkbox** skipped — see Decisions above. Non-blocking, outside
  acceptance.
- One `linter.style.longLine` warning on a docstring line was reflowed inside Phase 1 before the
  phase closed; recorded here only so the clean-build claim is not mistaken for a first-try one.

Both deviations are recorded in `specs/724_.../issues.jsonl`. Neither touches the Lean
mathematics, the plan's decomposition, or any declaration signature, so neither crossed the
`plan-compliance.md` escalation threshold for `.lean` files.

## Verification

- Build: **Success**. Full `lake build`, detached and guarded
  (`lake-build-guard.sh build --timeout 1800 -- build`): guard exit 0, "Build completed
  successfully (2819 jobs)", 0 `error:` and 0 `warning:` lines over both captured streams, and
  `.olean` newer than source for `FormalSystem/Metalogic/ZTimeProvability`,
  `FormalSystem/Metalogic` and `FormalSystem`.
- Gate: `bash scripts/check-module-invariants.sh` (build-backed, no `--no-build`) = **ALL CHECKS
  PASSED**. In particular PASS C1, C2 (fifty pinned axiom sets), **C14 (every pinned declaration
  matches its axiom baseline — this is what asserts the new matched pair)**, C8, C9, C9D, C15
  (253 theorem-index rows carry their anchor, up from 252), C16, C21 (33 MainResults declarations
  pinned), C23, C24, C26, C33 (`FormalSystem.lean` byte-for-byte the generated root, 653 import
  lines / 653 `.lean` files), C36b, C37.
- Sorry count: **0** (`lean-sorry-census.sh` over all four resolved source roots).
- Vacuous count: **0 introduced**. The repo-wide grep returns one pre-existing hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, untouched by this change set; the
  diff-scoped grep over `HEAD~4..HEAD` returns nothing.
- Axiom count: **not increased**. The 14 repo-wide `^axiom ` grep hits are prose lines in
  docstrings and READMEs that happen to begin with the word "axiom", all pre-existing; the
  diff-scoped grep adds none. `lean_verify` on
  `FormalSystem.Metalogic.decidableDerivableZTime` independently reports
  `["propext","Classical.choice","Quot.sound"]`, `trust: standard`, zero non-standard axioms —
  the same value the C14 baseline line now pins.
- Acceptance greps: `grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/` returns
  exactly one **declaration** hit (`ZTimeProvability.lean:106`, the `def` signature); the other
  four hits in that file are docstring prose. `grep -rn 'TM is decidable' .` surfaces no new
  occurrence outside `specs/` (where it appears only inside the plan's own prohibition text).
- Tests: `lake build BimodalTest` exits 0 (reported as PASS C1 by the gate).
- Files verified: Yes.

## Impacts

- Decidability of provability over ℤ is now a landed, kernel-checked result, no longer gated on
  the verified tableau spine. One of the four frame-class deliverables the spine was to supply is
  closed by a route the spine has nothing to do with.
- `docs/theorem-index.md`'s standing assertion that every listed declaration is machine-pinned
  stays true: the new row's `pinned:C14` claim is backed by a baseline line in the same change
  set, not prose-only.
- The gate script's descriptive comment no longer carries a forward-looking "expected to join"
  sentence beside the line that satisfies it — the same class of descriptive drift the preceding
  task in this series reconciled.

## Follow-ups

- `Base`, `Dense` and `RTime` provability decidability remain owed by the tableau spine's
  completeness direction, as does the `fc`-parameterized `Decidable (Derivable fc [] φ)` that the
  `Provable.lean` row in `FormalSystem/Metalogic/Decidability/Verified/README.md` names. That row
  was deliberately left unedited: its "not built" verdict is about the spine-route shape and
  remains accurate.
- Non-empty premise sets are untouched; a deduction theorem is what the reduction route would
  need, and the tree has none.
- The `specs/ROADMAP.md` checkbox for this deliverable is still unticked, consistent with its
  already-completed predecessor.
- Repository-wide, `FormalSystem/Examples/TemporalStructures.lean:495`'s
  `:= trivial` body is a pre-existing hit on the vacuous-definition scan. It is a true statement
  about a definitionally-trivial domain predicate rather than a placeholder, but it is the one
  thing that keeps that scan from reading zero.

## References

- `specs/724_decidable_ztime_provability_witness_family_corollary/plans/01_decidable-ztime-provability-corollary.md`
- `specs/724_decidable_ztime_provability_witness_family_corollary/reports/01_decidable-ztime-provability-corollary.md`
- `specs/724_decidable_ztime_provability_witness_family_corollary/handoffs/` — per-phase handoffs 1–5
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` — the cost
  statement and its literature source ([GKWZ] 2003 §6.5)
- `scripts/check-module-invariants.sh` — the C14 matched pair that pins the new declaration
