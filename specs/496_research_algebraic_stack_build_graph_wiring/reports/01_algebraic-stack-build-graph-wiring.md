# Research Report: Algebraic Stack Build-Graph Wiring

- **Task**: 496 - research_algebraic_stack_build_graph_wiring
- **Started**: 2026-08-25T19:30:00Z
- **Completed**: 2026-08-25T20:25:00Z
- **Effort**: ~1 hour (research + four measured builds)
- **Dependencies**: None
- **Sources/Inputs**:
  - Source tree: `FormalSystem/Metalogic/Algebraic/*.lean`, `FormalSystem/Metalogic/Algebraic.lean`,
    `FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/BXCanonical/Completeness.lean`
  - Docs under audit: `FormalSystem/Metalogic/Algebraic/README.md`, `FormalSystem/Metalogic/README.md`
  - Archive record: `FormalSystem/Boneyard/UltrafilterFrame/README.md`
  - Invariants: `scripts/check-module-invariants.sh`, `scripts/module-invariants-manifest.txt`
  - Build config: `lakefile.lean`
  - Git archaeology: commits `1961830e2`, `07c38c6a0`, `ae617193a`
  - Measured builds: `specs/496_research_algebraic_stack_build_graph_wiring/logs/exp1.log`, `exp2.log`
- **Artifacts**:
  - `specs/496_research_algebraic_stack_build_graph_wiring/reports/01_algebraic-stack-build-graph-wiring.md`
  - `specs/496_research_algebraic_stack_build_graph_wiring/logs/exp1.log` (marginal build cost)
  - `specs/496_research_algebraic_stack_build_graph_wiring/logs/exp2.log` (elaboration-conflict test)
  - `specs/496_research_algebraic_stack_build_graph_wiring/logs/exp1.sh`, `exp2.sh` (reproducers)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

- **Recommendation: option (a), re-wire.** Add one import line —
  `import FormalSystem.Metalogic.Algebraic` — to `FormalSystem/Metalogic.lean`, and delete the
  five now-stale lines from `scripts/module-invariants-manifest.txt` in the same commit.
- **The elaboration-conflict risk is empirically refuted for these four modules.** An adversarial
  build that imported the aggregator directly into `BXCanonical/Completeness.lean` — the exact
  position the Boneyard README warns about — recompiled `Completeness.lean`,
  `CompletenessDedekind.lean` and `StrongCompleteness.lean` with the full algebraic stack in
  scope and completed with `rc=0` and **zero errors**.
- **Git archaeology shows the historical conflict was always attributed to `UltrafilterFrame.lean`
  alone.** At commit `1961830e2` the aggregator live-imported `LindenbaumQuotient`,
  `BooleanStructure`, `InteriorOperators` and `UltrafilterMCS` while only the
  `UltrafilterFrame` import was commented out, and the commit message records "Full lake build
  passes." The four modules under discussion were never the suspects.
- **Measured cost is negligible**: 5.3s of elaboration (`LindenbaumQuotient` 1.1s,
  `BooleanStructure` 1.1s, `InteriorOperators` 0.979s, `UltrafilterMCS` 1.3s, aggregator 0.813s),
  948 KB of `.olean` against a 484 MB `FormalSystem` build tree, 5 modules against 419.
- **All three README claims flagged in the task are confirmed wrong**, plus two more found during
  the audit (a stale importer count and a stale directory-role label in `Metalogic/README.md`).
- **A one-line consequence of wiring**: `Metalogic/README.md`'s stated rule "No existing file is
  edited to import an aggregator" is already false today (`Metalogic.lean` imports four
  aggregators), and wiring makes the neighbouring claim that `Algebraic.lean` "has no importer"
  false too. Both need editing alongside the wiring.

## Context & Scope

`FormalSystem/Metalogic/Algebraic/` holds five sorry-free files (verified: zero `sorry` tokens in
all five). Only `FlowFrame.lean` is reachable from the Lake default target. `lakefile.lean:16-20`
declares `lean_lib FormalSystem` with ``roots := #[`FormalSystem]``, so the build closure is
exactly the transitive imports of the repository-root `FormalSystem.lean`, and nothing in that
closure imports the sibling aggregator `FormalSystem/Metalogic/Algebraic.lean`.

Reachability of `FlowFrame.lean` is via six direct importers (the task's count is confirmed):

| Importer | Directory |
|---|---|
| `Metalogic/BXCanonical/Completeness.lean:13` | BXCanonical |
| `Metalogic/BXCanonical/DiscreteCarrierProbe.lean:7` | BXCanonical |
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:10` | BXCanonical |
| `Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:15` | BXCanonical |
| `Metalogic/Bundle/LimitMCS.lean` | Bundle |
| `Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean:8` | WeakCanonical |

The remaining four — `LindenbaumQuotient.lean` (393), `BooleanStructure.lean` (441),
`InteriorOperators.lean` (176), `UltrafilterMCS.lean` (1,071) — total 2,081 lines and are reached
only through the importer-less aggregator.

The question to settle before anything is built on top of this stack (the Jonsson–Tarski / STSA
work) is whether importing it live reintroduces the elaboration conflict recorded in
`FormalSystem/Boneyard/UltrafilterFrame/README.md`.

## Findings

### F1. The four orphaned modules have no consumer anywhere in the live tree

A grep for every public name they export — `LindenbaumAlg`, `ProvEquiv`, `toQuot`, `InteriorOp`,
`boxInterior`, `mcsToUltrafilter`, `ultrafilter_correspondence` — outside
`FormalSystem/Metalogic/Algebraic/` and outside `Boneyard/` returns **zero hits**, including in
`Tests/`. They are self-contained algebraic infrastructure, not a dependency of any live proof.

### F2. The historical elaboration conflict was never attributed to these four modules

Commit `1961830e2` (2026-05-18, "task 163 phase 5: integration and build verification") is where
the warning comment originates. It added, to the then-aggregator `Algebraic/Algebraic.lean`:

```
-- Ultrafilter frame infrastructure (recovered from Boneyard, imported separately to avoid
-- elaboration interference with BXCanonical/Completeness.lean rfl proofs)
-- import Bimodal.Metalogic.Algebraic.UltrafilterFrame
```

At that commit the same aggregator **live-imported** `LindenbaumQuotient`, `BooleanStructure`,
`InteriorOperators`, `UltrafilterMCS`, `AlgebraicCompleteness` and the whole Parametric stack,
and the commit message states "Full lake build passes." Commit `07c38c6a0` (2026-05-20) then
archived `TenseS5Algebra.lean` and `UltrafilterFrame.lean` and carried the same attribution
forward. The scope of the recorded conflict is therefore `UltrafilterFrame.lean` (and its
`noncomputable instance lindenbaumSTSA : STSA LindenbaumAlg`, `TenseS5Algebra.lean:321`), not the
four modules that remain.

Note also that at commit `1961830e2` neither `BXCanonical/Completeness.lean` nor
`Metalogic.lean` imported the aggregator, so the recorded interference could not have been an
import-graph effect at all in the state committed there. Treat the archive README's attribution
as a hazard note of uncertain provenance rather than a measurement — which is precisely why the
task asked for an empirical answer.

### F3. The plausible interference surface, named

If the four modules were going to interfere with unrelated `rfl`/`simp` elaboration, these are the
declarations that would do it — all of them global once imported:

- `LindenbaumQuotient.lean:108` — `instance provEquivSetoid : Setoid Formula`, a `Setoid` instance
  on the project's central `Formula` type.
- `BooleanStructure.lean:43,77,81,93,99,421` — `LE`, `Preorder`, `PartialOrder`, `Top`, `Bot` and
  `BooleanAlgebra` instances on `LindenbaumAlg`.
- `UltrafilterMCS.lean:63` — `instance instMembershipUltrafilter {α : Type*} [BooleanAlgebra α] :
  Membership α (Ultrafilter α)`, a *generic* instance quantified over every Boolean algebra.
- `UltrafilterMCS.lean:537,976` — two `@[simp]` lemmas added to the global simp set.

This is a real surface, not a null one; it is why the empirical test below was run in the
adversarial position rather than only the recommended one.

### F4. Empirical result — no elaboration conflict, in either wiring position [MEASURED]

Reproducer: `specs/496_research_algebraic_stack_build_graph_wiring/logs/exp2.sh`. Every build was
routed through `.claude/scripts/lake-build-guard.sh build --timeout 1800 --no-share` and detached,
per `context/project/lean4/operations/long-builds.md`.

| Variant | Wiring | Result | Wall |
|---|---|---|---|
| **B (adversarial)** | `import FormalSystem.Metalogic.Algebraic` added to `BXCanonical/Completeness.lean` (upstream position, reproducing the historical hazard) | **rc=0, 0 errors** | 15s |
| **A (recommended)** | `import FormalSystem.Metalogic.Algebraic` added to `FormalSystem/Metalogic.lean` (downstream position) | **rc=0, 0 errors** | 15s |
| Reverted baseline | tree restored to HEAD | rc=0, 0 errors | 8s |

Variant B is the decisive one. It placed the whole algebraic stack — the `Setoid Formula`
instance, the `BooleanAlgebra LindenbaumAlg` instances, the generic `Membership` instance and both
`@[simp]` lemmas — *upstream* of the completeness proof, and the log shows the affected modules
genuinely re-elaborated rather than replaying from cache:

```
Built FormalSystem.Metalogic.BXCanonical.Completeness (1.3s)
Built FormalSystem.Metalogic.BXCanonical.CompletenessDedekind (1.8s)
Built FormalSystem.Metalogic.BXCanonical (1.1s)
Built FormalSystem.Metalogic.StrongCompleteness (1.5s)
Built FormalSystem.Metalogic.DiscreteNonCompactness (1.4s)
Built FormalSystem.Metalogic (1.3s)
```

The `rfl` proofs the Boneyard README warns about survived. The working tree was restored to HEAD
and verified clean (`git status --short FormalSystem/` empty).

**Directionality caveat, stated so the result is not over-read**: Lean imports are directional, so
Variant A *cannot* affect elaboration inside `BXCanonical/` under any circumstances —
`Metalogic.lean` sits downstream of it. Variant A alone would therefore have been a
non-experiment. Variant B is what licenses the conclusion, and Variant A is what validates the
recommended change end to end.

### F5. Measured build-time delta [MEASURED]

Reproducer: `logs/exp1.sh`. The five modules' build artifacts were evicted from `.lake/build/` and
rebuilt against an otherwise-warm cache:

```
Built FormalSystem.Metalogic.Algebraic.LindenbaumQuotient (1.1s)
Built FormalSystem.Metalogic.Algebraic.BooleanStructure   (1.1s)
Built FormalSystem.Metalogic.Algebraic.InteriorOperators  (979ms)
Built FormalSystem.Metalogic.Algebraic.UltrafilterMCS     (1.3s)
Built FormalSystem.Metalogic.Algebraic                    (813ms)
```

- **Elaboration added: 5.3s** (10s wall including Lake's replay of the 1,363 already-cached jobs).
- **Artifact size added: 948 KB** of `.olean`, against 484 MB for the whole `FormalSystem` tree.
- **Module count added: 5**, against 419 built `.olean` files (413 live `.lean` sources).

*Not measured*: the cold full-build wall time, so the delta is not expressed as a percentage of a
from-scratch CI build. Doing so would have required discarding the entire `FormalSystem` build
cache; the absolute figures above are the honest denominators available.

### F6. Cycle safety

No cycle is introduced by either variant. The five `Algebraic/` modules import only
`ProofSystem`, `Metalogic/Core`, `Theorems`, `Semantics`, `Bundle/TemporalCoherence`, `Syntax` and
Mathlib — none of them reaches `Metalogic.lean` or `BXCanonical/`. Both variants built clean,
which is the operative proof.

### F7. `Algebraic/README.md` — confirmed overstatements

| Claim | Location | Verdict |
|---|---|---|
| "**Status**: Active -- infrastructure consumed by the live completeness proof" | header | **Overstated.** True of `FlowFrame.lean` only; the other four have zero consumers (F1). |
| "This directory is **not** optional relative to it" | Purpose section | **Overstated**, same reason. |
| "so `Algebraic/` participates in the live proof rather than standing beside it" | Purpose section | **Overstated**, same reason. |
| "G and H are shown to be interior operators using the T and 4 axioms" | Interior Operators section | **False on both counts.** `InteriorOperators.lean` proves `H_monotone` (`:80`) and the box triple `box_le_self` (`:101`), `box_monotone` (`:112`), `box_idempotent` (`:130`), assembled into the single `boxInterior : InteriorOp LindenbaumAlg` (`:142`). There is no `gQuot` anywhere in the codebase — only `boxQuot` (`LindenbaumQuotient.lean:289`), `hQuot` (`:296`) and `negQuot` (`:261`) — so there is no G operator on the quotient to be an interior operator. |
| "`InteriorOperators.lean` \| G/H as interior operators" | Modules table | **False**, same reason. |
| "`BXCanonical` imports `Algebraic.FlowFrame` — from `Completeness.lean`, `ChronicleToCountermodelBasic.lean`, `ChronicleMonadicBridge.lean`, and `DiscreteCarrierProbe.lean`" | Purpose section | **Incomplete.** Accurate for BXCanonical, but omits the two non-BXCanonical importers `Bundle/LimitMCS.lean` and `WeakCanonical/GroupModel/CountermodelBase.lean` (F: table in Context & Scope). Six importers, not four. |
| "*Last updated: 2026-04-06*" | footer | Stale by four months. |

The irony worth recording: `InteriorOperators.lean`'s own module docstring (`:29-43`) already
says, correctly and at length, that "Under strict temporal semantics, G and H are NOT interior
operators" and that the sorried `G_monotone` was archived. The README contradicts the file it
documents.

### F8. `Metalogic/README.md` — two further inaccuracies found during the audit

- `:33` and `:171` label `Algebraic/` as the "Parametric/algebraic completeness route" and
  "Lindenbaum–Tarski quotient algebra and a parametric canonical model". The parametric stack was
  **deleted** in commit `6c3419a4f` ("task 415 phase 4: delete superseded canonical model stack")
  and `Algebraic.lean`'s own docstring says so. Stale by one refactor.
- `:154` states as a rule that "No existing file is edited to import an aggregator — that is how a
  genuine module-level cycle would appear." This is **already false at HEAD**: `Metalogic.lean`
  imports the aggregators `Decidability` (`:11`), `Independence` (`:12`), `BXCanonical` (`:13`) and
  `WeakCanonical` (`:14`). The operative rule is narrower — do not import an aggregator whose own
  contents already reach the importing file — and should be restated that way. The adjacent claim
  at `:154-158` that `Algebraic.lean` "has no importer" becomes false once the recommendation
  lands and must be edited in the same commit.

### F9. Invariant-check consequences of wiring

`scripts/module-invariants-manifest.txt` already documents the required move precisely: "Wiring a
module into the build graph means DELETING its line here", and C6 "FAILS if an entry names a
REACHABLE module". Wiring in the aggregator makes five entries stale and they must be deleted in
the same commit:

```
FormalSystem.Metalogic.Algebraic
FormalSystem.Metalogic.Algebraic.BooleanStructure
FormalSystem.Metalogic.Algebraic.InteriorOperators
FormalSystem.Metalogic.Algebraic.LindenbaumQuotient
FormalSystem.Metalogic.Algebraic.UltrafilterMCS
```

C8 (sibling aggregator) is unaffected — the aggregator file stays exactly where it is; it merely
acquires an importer. `bash scripts/check-module-invariants.sh --no-build` passes at HEAD today
and is the gate to re-run after the change.

## Decisions

- **D1. Recommend option (a), re-wire.** The stated reason for isolation does not survive
  measurement (F2, F4), the cost is 5.3s and 948 KB (F5), and the alternative leaves 2,081 sorry-free
  lines verified only by an out-of-band script rather than by `lake build`.
- **D2. Wire at `FormalSystem/Metalogic.lean`, not at `BXCanonical/Completeness.lean`.** Both are
  green, but the downstream position is the minimal, semantically honest one: it says "this
  directory is part of the library", not "completeness depends on this algebra" — which would be
  false (F1). It also matches how `Metalogic.lean` already treats `BXCanonical`, `WeakCanonical`,
  `Decidability` and `Independence`.
- **D3. Import the aggregator, not the deepest leaf.** Importing `Algebraic.UltrafilterMCS`
  directly would also reach all four modules and would preserve the "aggregators are
  importer-less" convention for `Algebraic` — but it leaves the aggregator itself orphaned and
  clears only four of the five manifest lines. Since that convention is already not observed for
  four other aggregators (F8), preserving it for `Algebraic` alone buys nothing.
- **D4. Do not widen scope to `Core.lean`, `Bundle.lean`, `SoundnessLemmas.lean`.** They sit in the
  same manifest block for the same reason and are plausible follow-on candidates, but each needs
  its own cycle analysis and none was tested here. Out of scope for this task; recorded as an
  observation only.

## Recommendations

Prioritized; all are small and independently verifiable.

1. **[P1] Wire the aggregator in.** Add `import FormalSystem.Metalogic.Algebraic` to
   `FormalSystem/Metalogic.lean` (after the existing `Conservativity` import, line 15). One line.
2. **[P1] Delete the five stale manifest entries** from `scripts/module-invariants-manifest.txt`
   (F9), and update the surrounding comment block — which currently explains at length *why* those
   four modules are unreachable — so it no longer describes a state that no longer holds. The
   contrast-case paragraph naming `FlowFrame.lean` as "the fifth file … correctly absent from this
   file" also stops making sense and should go.
3. **[P1] Verify**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
   (detached) must be `rc=0`, then `bash scripts/check-module-invariants.sh` must pass.
4. **[P1] Fix `FormalSystem/Metalogic/Algebraic/README.md`** — all seven items in F7:
   - Header status: say that `FlowFrame.lean` is consumed by the live completeness proof and that
     the Boolean-algebra/ultrafilter layer is standalone infrastructure with no current consumer.
   - Drop "not optional" and "participates in the live proof" as directory-wide claims; scope them
     to `FlowFrame.lean`.
   - Replace "G and H are shown to be interior operators using the T and 4 axioms" with what is
     actually proved: `boxInterior` is the only `InteriorOp`; `H_monotone` is the only surviving
     G/H-family result; there is no `gQuot` at all. The file's own docstring (`:29-43`) is the
     model to follow.
   - Modules table: `InteriorOperators.lean` → "Box as interior operator; H monotonicity".
   - Correct the importer list from four files to six.
   - Refresh the "Last updated" line.
5. **[P2] Fix `FormalSystem/Metalogic/README.md`** — both items in F8: drop "parametric" from the
   `Algebraic/` role labels at `:33` and `:171`, restate the aggregator rule at `:154` in its true
   narrow form, and correct the `:154-158` claim that `Algebraic.lean` has no importer.
6. **[P2] Record the adjudication where the hazard was raised.** Add a line to
   `FormalSystem/Boneyard/UltrafilterFrame/README.md` noting that the elaboration-conflict concern
   was tested against the four remaining `Algebraic/` modules and did not reproduce (cite this
   report), so the next reader of that archive does not re-inherit an unqualified warning. The
   warning should remain in force for `UltrafilterFrame.lean` and `TenseS5Algebra.lean` themselves,
   which were **not** tested — they carry five sorries and were not built.

## Risks & Mitigations

| Risk | Assessment | Mitigation |
|---|---|---|
| The generic `Membership α (Ultrafilter α)` instance (`UltrafilterMCS.lean:63`) interferes with future Mathlib-heavy elaboration | Not observed today (F4), but it is the one genuinely global declaration in the stack | Recorded here so a future breakage has a named first suspect. Consider scoping it (`scoped instance`) if it ever bites. |
| The two `@[simp]` lemmas enter the global simp set library-wide | Both are `Ultrafilter`-shaped and cannot fire on unrelated goals; no effect observed in Variant B | None needed; noted for the record. |
| Wiring makes future edits to these four modules break the whole build rather than only C6 | This is the *point* of the change, not a side effect | Accept. That is what "verified by `lake build`" means. |
| The `UltrafilterFrame`/`TenseS5Algebra` conflict is real and returns when the STSA port lands | Untested here — those files were not built (five sorries) | Explicitly out of scope. The STSA port should re-run the Variant B experiment with those files included before assuming the same clean result. |
| `Metalogic.lean` gains a dependency edge that slows incremental rebuilds of the top aggregator | 813ms for the aggregator, ~5s for its subtree, and only on first build | Accept (F5). |

## Context Extension Recommendations

- **Topic**: Empirically testing an "elaboration conflict" hazard before honouring it.
- **Gap**: The Boneyard archive convention records *why* something was archived, but there is no
  documented procedure for re-testing such a claim when the surrounding code has moved on. This
  task's Variant A / Variant B design — wire the suspect module into the adversarial upstream
  position, force the downstream re-elaboration, confirm the specific proofs named in the hazard
  actually recompiled rather than replayed — is reusable.
- **Recommendation**: Add `context/project/lean4/patterns/testing-archived-elaboration-hazards.md`
  capturing that two-variant design and the "check for `Built` not `Replayed` in the log" step that
  keeps the test honest.

## Appendix

### Reproducers

- `specs/496_research_algebraic_stack_build_graph_wiring/logs/exp1.sh` — baseline build, evict the
  five modules' artifacts, time the rebuild. Output: `exp1.log`.
- `specs/496_research_algebraic_stack_build_graph_wiring/logs/exp2.sh` — Variant B, Variant A,
  revert-and-restore. Output: `exp2.log`; the mutated import block from Variant B is preserved at
  `logs/variantB-completeness-imports.txt`.

Both scripts restore the working tree themselves and were verified to leave
`git status --short FormalSystem/` empty.

### Commits consulted

| Commit | Date | Relevance |
|---|---|---|
| `1961830e2` | 2026-05-18 | Origin of the "elaboration interference" comment; scoped to `UltrafilterFrame` only |
| `07c38c6a0` | 2026-05-20 | Archived `UltrafilterFrame.lean` + `TenseS5Algebra.lean` to Boneyard |
| `ae617193a` | 2026-07-14 | Deleted the old in-directory `Algebraic/Algebraic.lean` aggregator |
| `6c3419a4f` | — | Deleted the parametric canonical stack (source of the stale README labels in F8) |

### Verified negative results

- Zero `sorry` tokens in all five `Algebraic/*.lean` files.
- Zero occurrences of `gQuot` in the repository.
- Zero references to `LindenbaumAlg`, `ProvEquiv`, `toQuot`, `InteriorOp`, `boxInterior`,
  `mcsToUltrafilter` or `ultrafilter_correspondence` outside `Metalogic/Algebraic/` and `Boneyard/`.
- Zero `error:` lines across all four measured builds.
