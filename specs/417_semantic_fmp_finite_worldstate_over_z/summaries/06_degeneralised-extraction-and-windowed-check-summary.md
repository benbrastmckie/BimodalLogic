# Implementation Summary — Degeneralised Extraction and Windowed `check`

- **Plan**: `specs/417_semantic_fmp_finite_worldstate_over_z/plans/06_degeneralised-extraction-and-windowed-check.md`
- **Task type**: lean4
- **Session**: sess_1787007762_7d00d6
- **Dispatch**: 11 (resumed after dispatch 10 was lost to an API error mid-Phase 12)
- **Status**: all phases complete; Phase 12 closed `[COMPLETED]`

## What this dispatch did

Dispatch 10 died partway through Phase 12 with `Check.lean` untracked on disk and its state
unknown. The first action was to assess it rather than assume it: **it built clean and was
axiom-clean** (`check_correct`, `check_bot_false`, `check_top_true`, `instDecidableSatAtState` all
report `[propext, Classical.choice, Quot.sound]` and no `sorryAx`). It was committed as-is before
any further work, then finished.

The one thing genuinely missing was the section its own module docstring promised — the file
referred to "the `#eval`s of `checkAt` in the worked section below", and no such section existed.

## Phase 12 deliverables

| Deliverable | File | Status |
|---|---|---|
| `SatAtState`, `checkAt`, `check`, `check_correct`, `Decidable` instance, discrimination theorems | `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean` (249 lines) | Landed, sorry-free |
| Worked evaluations witnessing that the procedure reduces | same | Added this dispatch |
| Subdirectory re-export | `FormalSystem/Metalogic/Decidability/BiLasso.lean` | New |
| C6 manifest entries (6 appended, none removed) | `scripts/module-invariants-manifest.txt` | Appended |
| Evidence-probe regression guard | `scripts/check-evidence-probes.sh` | New; 4/4 green |
| Probe repair (missed guard-first migration) | `evidence/phase12-check-not-compositional.lean` | Repaired |
| Layer README finalised | `FormalSystem/Metalogic/Decidability/BiLasso/README.md` | Updated |
| Module table row | `FormalSystem/Metalogic/Decidability/README.md` | Updated |

## Verification

| Gate | Result |
|---|---|
| `lake build` | **exits 0** |
| Live sorry count | **exactly 1** (`countermodel_discrete`, `WeakCanonical/Transfer.lean`) via C3, not grep |
| `#print axioms check_correct` | no `sorryAx` |
| C6 manifested-module compile check | **all 28 compile in isolation** |
| `scripts/check-evidence-probes.sh` | **4/4 wired probes green** |
| `check` computes | `#guard`s on `checkAt` pass in-module; real `check` measured terminating |
| `Basic.lean` / `Extend.lean` | `git diff --exit-code` **clean** at every phase close |
| No `open Classical` / `Classical.dec` on `check`'s path | confirmed |
| No `BXCanonical` import under `BiLasso/` | confirmed |
| `Extend`/`Successor`/`Orbit`/`Agreement` neither edited nor imported | confirmed |

### Inherited red, unchanged and not re-baselined

These fail identically against HEAD and are **not** this work's:

- `lake build BimodalTest` — fails at exactly `BoxSpreadProbe`, `RegionGateProbe`,
  `TableauConformance` (`#guard_msgs` mismatches) **and no others**, verified by enumerating the
  failing modules.
- C6 — 7 unmanifested unreachable modules, all outside this layer (`Metalogic.Algebraic.*`,
  `Bundle.Construction`, `SoundnessLemmas.CoValidity`, `WeakCanonical.…OuterGateFaithful`). This
  work's 5 new modules plus the re-export were **added** to the manifest, so the count is unchanged
  rather than worsened.
- C9 — 1 task-number citation, in `WeakCanonical/PriorExpressivenessDense.lean`.
- `readme-lint.sh` — 133 pre-existing `NOT LISTED` findings repo-wide; **none** under `BiLasso/` or
  `Decidability/` from this work.

## Plan Deviations

1. **`#eval check` at the specified size — altered.** The plan's verification asks for an `#eval`
   of `check` on a two-state presentation with a two-formula closure. That does not terminate:
   `bound flipPresentation (⊥→⊥) = 40` and `boundedAnnots` enumerates every labelling of a window
   that long. The underlying fact the gate exists to establish — that no `noncomputable` dependency
   leaked in from the extraction — **is** established, one size down: `#eval check loopPresentation
   0 Formula.bot` returns `false` and `#eval check loopPresentation 0 (Formula.atom pA)` returns
   `true`, both real `check` at its real `bound` of 6, both terminating in ~2 min (measured). Those
   are not retained in the module (they would add ~4 min to every compile); the retained evidence is
   `#guard`s on `checkAt` at `n = 1` over the same code path (2s) plus the two discrimination
   theorems, of which `check_bot_false` is strictly stronger than the negative `#eval` — it holds
   for every presentation and every state.

2. **A red probe was repaired rather than only reported — altered.**
   `phase12-check-not-compositional.lean` was red at wiring time. The plan says such a probe must be
   reported, not wired in red. It was diagnosed first, and the cause was a **missed mechanical
   migration**, not a semantic gap: the file predates the guard-first `untl`/`snce` order, so
   `someFutureP p = untl (atom p) top` read as guard=`p`/event=`⊤` — not "p at some future time" —
   and its two `untl` obligations arrived in the opposite order from its proofs. Swapping the two
   arguments is exactly what `scripts/swap_untl_snce.py` performs; the file's five facts then
   compile unchanged. Repairing it was preferred to excluding it because `Check.lean`'s docstring
   cites this probe by path as the refutation of a compositional `check`.

3. **The re-export is not itself imported — recorded design point, not a silent choice.**
   `Decidability.lean` does not import `BiLasso.lean`, so the layer remains outside the build graph.
   This is forced, not chosen: reachability runs from the Lake target roots, so importing the
   aggregator makes all thirteen submodules reachable, and C6 **fails** on a manifest entry naming a
   reachable module — which would require deleting the very lines the plan's Testing & Validation
   forbids removing ("no lines removed or reordered"). Wiring is therefore one commit that adds the
   import *and* deletes the manifest block together. The manifest comment, `BiLasso.lean`'s
   docstring, and both READMEs each say so.

   A stale instruction was corrected as part of this: the manifest block read "DELETE these lines
   when that re-export is added", which — followed literally now that the re-export exists — would
   have broken C6. No entry line was removed or reordered.

4. **The re-export includes the landed Phases 2–9 modules, not only the five new ones.** The plan
   enumerates five to include and one (`Extend.lean`) to exclude; a subdirectory aggregator omitting
   `Basic`…`SmallModel` would not aggregate the subdirectory. `Extend`, `Successor`, `Orbit` and
   `Agreement` are excluded as instructed.

## Wiring mechanism chosen

`scripts/check-evidence-probes.sh`, a standalone script. The probes live under `specs/`, so a
lakefile entry or `Tests/` module would mean relocating them away from the evidence directory that
`Check.lean` and both READMEs cite by path. A new check group inside `check-module-invariants.sh`
was rejected: that script is scoped to modules under `FormalSystem/`, and C5/C10 deliberately
exclude `specs/`. A standalone script matches the existing one-script-per-concern pattern and uses
the same mechanism as the C6 rot guard — `lake env lean` on a file outside the build graph. It runs
in ~10s and records, per probe, the design decision that probe holds in place.

## Notes for whoever wires the layer in

One commit, two edits, both required together:

1. Add `import FormalSystem.Metalogic.Decidability.BiLasso` to
   `FormalSystem/Metalogic/Decidability.lean`.
2. Delete the whole bi-lasso block from `scripts/module-invariants-manifest.txt` — including the
   `Extend`/`Successor`/`Orbit`/`Agreement` lines **only if** the effective-periodic-extension work
   has by then wired itself in, since the re-export does not carry those four.

Doing either alone fails C6.
