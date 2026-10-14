# Implementation Summary: Task #778

- **Task**: 778 - Record the modulus convention for the residue-carrying ladder index
- **Status**: [COMPLETED]
- **Started**: 2026-10-13T21:00:00Z
- **Completed**: 2026-10-13T21:40:00Z
- **Effort**: ~40 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_residue-index-modulus-convention.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The modulus convention for `ladderIndexRes T P B` is now on record, in both places the task
named plus four further surfaces that carried the gap or the understated modulus clause. The
convention is stated by naming the modulus rather than by choosing between two off-by-one
readings: `P` is a modulus minus one (both residue coordinates are taken modulo `P + 1`), an
instantiation is specified by `m` with `1 ≤ m` and `P := m - 1`, and an exhibited period `p`
from `reachN_eventually_periodic` enters as `m := p`. Alongside it the record states that no
refutation turns on the choice, on compiled ground, and that `2 ≤ m` is forced. No declaration
was added, no theorem statement was touched, and no proof obligation was created.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` — module docstring only
  (219 -> 231 lines, one hunk inside the `/-! ... -/` block): the convention, the
  convention-independence sentence citing `object_only_parameters_refuted` (every `(T, P, B)`)
  and `reach_period_refuted` (every modulus not divisible by `3`, so both readings of the
  exhibited period `1` — moduli `1` and `2` — fall), the forced `2 ≤ m`, and the modulus clause
  sharpened from "must dominate" to "must be a multiple of the period of". Declaration-binder
  count unchanged at 12.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the "unrecorded `P` versus `P + 1`
  convention" clause replaced by the reading-neutral form; the sharpened clause at all three of
  its further sites; the hand-maintained `| LadderModel.lean | 219 |` row refreshed to `231` and
  the prose `LadderModel.lean, 219 lines` with it.
- `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` — docstring only:
  the `## The `P` versus `P + 1` convention` section now states the convention instead of
  declaring it unrecorded, keeps its `Nothing here chooses` clause intact, and carries the
  sharpened modulus wording. Every theorem statement, `#guard` and `#print axioms` line is
  byte-for-byte unchanged (declaration-binder grep `diff`s clean over 140 binder lines).
- `scripts/check-evidence-probes.sh` — the transcribed record comment sharpened, the block's `|`
  column and 120-character width preserved, file total unchanged at 1171 lines.
- `docs/theorem-index.md` — the Statement cell of four rows (`no_fwd`, `no_bwd_of_idle`,
  `ladderFrameAdm_isRegular`, `ladderModel`) sharpened; file total unchanged at 552 lines, and a
  word-level diff shows no change to any Lean-name, File, Frame-class or Axioms cell.
- `README.md`, `FormalSystem/Metalogic/README.md`, `typst/generated/status.typ` — machine-owned
  blocks regenerated, never hand-edited: live comment lines `119,777 -> 119,789`,
  `Decidability/` lines `98,898 -> 98,910`, `formalsystem-line-count 353796 -> 353808`. All three
  deltas are exactly the `+12` of the docstring.
- Lean extension source store (`source_dir` = `/home/benjamin/.config/nvim/agent-system/extensions/lean`),
  **applied and verified in place, uncommitted there by design**:
  `context/project/lean4/domain/ladder-counter-observables.md` (180 -> 194 lines) carries the
  convention as a new parameter-origin bullet, the reading-neutral mechanism (5), the sharpened
  clause at both of its sites and in the gate-5 table row, and the new sentence recording that
  `reachN_eventually_periodic` exhibits no canonical period (period `2` from the pending
  singleton of the two-state fixture, period `1` from `univ`, and any multiple of a period
  satisfies the statement); `index-entries.json` carries that note's `line_count`.

## Decisions

- **The convention is dissolved, not chosen.** Naming the modulus `m` makes `P := m - 1`
  definitional, so no record has to privilege `P := p` over `P := p - 1`; the task's fallback
  ("state explicitly that both readings are refuted") is recorded too, and on the two compiled
  theorems rather than on the parity observable the task description reached for — there is no
  compiled parity instance at countdown offset `3`, and this task barred adding one.
- **The modulus clause is a divisibility condition, not a magnitude one.** `dominate` is true but
  understated: `reach_period_refuted`'s hypothesis is `¬ 3 ∣ (P + 1)`, so a modulus of `100`
  exceeds `3` and is refuted all the same. One wording — "a multiple of the period of every
  letter-definable sub-object" — now holds across every deliverable surface.
- **`2 ≤ m` is forced, and the collapse target is named concretely.** At `m = 1` both residue
  coordinates are constant and the index collapses to the clipped-coordinate shape (`ladderIndex`'s
  four components) already refuted at the countdown coordinate. The plan called this "the
  three-coordinate candidate"; the implemented wording counts the components as they actually
  survive the collapse.
- **No `deploy-headless.sh` run.** The deployed `.claude/` copy of the note stays stale; a
  redeploy regenerates the whole gitignored tree across every extension, which is outside this
  task's blast radius. That is an operator item, recorded below.

## Plan Deviations

- **Phase 1** altered: three trailing docstring lines were rewrapped beyond the plan's task list,
  because the insertion pushed a pre-existing continuation line past Lean's 100-character style
  limit (the first scoped build exited 0 but emitted a `linter.style.longLine` warning).
- **Phase 1** altered: `typst/generated/status.typ` had to be regenerated and committed with the
  phase. The plan anticipated a generated-inventory collision only for `README.md` in Phase 6; a
  second generated surface, gated at pre-commit by `typst-sync-check.sh --counts-only`, carries
  the same `FormalSystem` line count and blocked the phase commit until regenerated.
- **Phase 2** altered: one occurrence beyond the plan's enumerated four — the prose at line 162
  also read `LadderModel.lean, 219 lines`, which Phase 1's growth made false.
- **Phase 3** closed `[COMPLETED WITH EXCLUSIONS]`: both source-store edits are applied and
  verified, but (a) its gate criterion cannot be met from this repository and (b) the
  source-store commit is deferred. See the plan's Phase 3 Reasoned Exclusions table.
- **Phase 3** corrected: `verify-deploy.sh`'s TARGET must be a deploy-tree root
  (`/home/benjamin/.config/nvim`), not the extension directory the plan named — the extension
  directory has no `.claude/`, so the script refuses with exit 2 before running any gate.
- **Phase 4** closed `[COMPLETED WITH EXCLUSIONS]`: `check-evidence-probes.sh` exits 1 on four
  pre-existing foreign probe compile failures. This task's probe PASSES in that same run.

## Verification

- Build: Success. `check-module-invariants.sh` reports `PASS C1 lake build exits 0` and
  `PASS C1 lake build BimodalTest exits 0` with every edit of this task in place, and the
  guarded scoped builds of the edited module and the edited probe both exit 0 clean.
- Sorry count: 0 (no `sorry` added anywhere; `git diff` over the whole change adds no `sorry`).
- Vacuous count: 0.
- Axiom count: unchanged — no `axiom` line added, and the probe's `#print axioms` output is
  `[propext, Classical.choice, Quot.sound]` throughout.
- No new declaration: `git diff` over the whole change adds no `theorem`, `lemma`, `def`,
  `abbrev`, `instance`, `structure`, `inductive` or `class` line.
- `check-module-invariants.sh --emit-inventory --check` exits 0: regeneration is idempotent, so
  no generated block is left stale.
- Residual-occurrence sweep for the old modulus wording over `*.lean`/`*.md`/`*.sh`, excluding
  `.lake/`, `.claude/`, `specs/ROADMAP.md` and the task-artifact trees: empty.
- Unrecorded-assertion sweep: empty, modulo the two enumerated `ExteriorConverterK.lean` /
  `ExteriorPinnedConverseK.lean` hits (`unrecorded-but-realizable on-fiber sub`, a different
  sense of the word, out of scope) and `specs/**` task artifacts.
- Deliverable wording sweep (`previously`, `formerly`, `no longer`, `now recorded`, `supersedes`)
  over every added line outside `specs/**`: empty.
- `verify-deploy.sh --only-gate 4 .` (task-reference lint) exits 0; the source store's gate 4
  passes too.
- Tests: `lake build BimodalTest` passes (above). No test was added — the change is prose only.
- Files verified: Yes.

## Impacts

- A successor attempting the positive factorization lemma now reads one modulus convention and
  one modulus clause everywhere, including on the surface `docs/theorem-index.md` declares
  authoritative, instead of an off-by-one ambiguity plus two inconsistent necessary conditions.
- The non-canonicity of `reachN_eventually_periodic`'s period is now recorded as a second,
  independent reason the modulus cannot be read off the object, which strengthens the
  parameter-origin rule the two refutations establish.
- No compiled surface changed, so nothing downstream of the library is affected.

## Follow-ups

- **Operator**: commit the two source-store edits in `/home/benjamin/.config/nvim`. A foreign
  uncommitted hunk in `agent-system/extensions/lean/index-entries.json` (`project/lean4/README.md`
  `line_count` 30 -> 31) makes a scoped commit from here impossible without capturing another
  writer's change.
- **Operator**: the deployed `.claude/` copy of `ladder-counter-observables.md` remains stale
  until `deploy-headless.sh` is run. This task deliberately did not run one.
- **Pre-existing, not this task's**: four wired probes in `specs/evidence/seam-gluing-ray-product/`
  do not compile (`finite-graph-stab-summary`, `mosaic-germ-amalgamation`,
  `path-quantifier-alternation`, `backward-dual-asymmetric-fixture`), and the source store's
  doc-lint carries ten findings (deployed-script content drift in `core` and `lean`, two unlisted
  test fixtures, four `index-entries.json` `line_count` mismatches).
- `specs/ROADMAP.md` still carries the understated modulus clause in its Stage 1 batching comment.
  It is operator-owned and was a declared Non-Goal.

## References

- `specs/778_residue_index_modulus_convention_record/plans/01_residue-index-modulus-convention.md`
- `specs/778_residue_index_modulus_convention_record/reports/01_residue-index-modulus-convention.md`
- `specs/778_residue_index_modulus_convention_record/handoffs/phase-{1..6}-handoff-*.md`
- `specs/778_residue_index_modulus_convention_record/issues.jsonl`
- `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`
