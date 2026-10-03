# Implementation Plan: Task #719 — the ray layer, the seam-gluing operator and the stab fibre

- **Task**: 719 - ray_layer_seam_gluing_and_stab_fibre
- **Status**: [COMPLETED]
- **Effort**: 9 hours
- **Dependencies**: None remaining — 563 `[COMPLETED]`, **564 `[COMPLETED]`** (the dispatch's "still upstream and NOT STARTED" is stale; see Research Integration point 1), 718 `[COMPLETED]`
- **Research Inputs**: `specs/719_ray_layer_seam_gluing_and_stab_fibre/reports/01_ray-layer-seam-gluing-stab-fibre.md`
- **Artifacts**: plans/01_ray-layer-seam-gluing-stab-fibre.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Promote four already-compiled probe results into `FormalSystem/` and add one new probe. The ray
layer (`PastRay`/`FutRay`, their seam projections, `pastOf`/`futOf`, and the bridges to `Beh F l`)
and the ray-layer gluing operator land as a new `FormalSystem/Semantics/Presheaf/Ray.lean`; the
four acceptance-named keystone declarations land across that module and a new
`FormalSystem/PlusLanguage/PlusRayFibre.lean`, hypothesis for hypothesis as the probe states
them; the two recorded verdicts (Deliverable 4's subsumption limit, Deliverable 5's requirement
hand-off) land as library prose; and experiment E1 — the backward-dual finite-graph probe on a
time-asymmetric fixture — lands as one new file under `specs/evidence/seam-gluing-ray-product/`
with one new `WIRED` entry.

Every mathematical obligation in Deliverables 1–4 is **already machine-checked**, so the work is
siting, renaming around a collision, one verified choice-leak repair, axiom measurement and gate
compliance — not discovery. Definition of done: two new library modules and one new probe file,
`lake build` green and `sorry`-free at the end of **every** phase, the four keystone declarations
carrying `[F.IsRegular]` verbatim, their measured axiom sets pinned into the C2 harness, and both
verdicts recorded in the library rather than only in this plan or a summary.

### Research Integration

`reports/01_ray-layer-seam-gluing-stab-fibre.md` is integrated wholesale. It is a compiled
report: seven standalone Lean files were elaborated with `lake env lean` against the live oleans
and every axiom claim below is a `#print axioms` reading, not an inference. Six of its findings
shape this plan structurally.

1. **Task 564 is `[COMPLETED]`, and that changes the correct implementation of three
   deliverables** (Finding 1). `PartialHistory.rel_across_seam`, `TaskFrame.reflection_of_ne`,
   `PlusLanguage.pasteAt` and the whole `Presheaf/Sheaf.lean` cluster are on the tree. This task
   **consumes** all four and re-derives none. The plan's last upstream dependency is discharged.
2. **The dispatch's "choice-free as probed" claim is false as the probe stands, and the repair is
   verified** (Findings 2, 3). Measured: all four keystone declarations are
   `[propext, Classical.choice, Quot.sound]`. `Classical.choice` enters at exactly one line —
   `glue_rel`'s mixed-orientation case, which rewrites with the unguarded `F.reflection`.
   Substituting 564's `F.reflection_of_ne` with a `≠ 0` side condition clears it, and
   `glue_rel`, `glue`, `seamFibreEquiv` and `plusStab_iff_rays` all drop to
   `[propext, Quot.sound]` (probe P2, compiled first try). **Phase 2 applies this reroute, and
   it is not optional**: without it the claim the task is required to record would be false.
3. **The ω-branch cannot be made choice-free here, and the obstruction is upstream** (Finding 4).
   `seamOmegaEquiv`/`plusStab_iff_omega` retain `Classical.choice` through the landed library
   declaration `FrameOver.worldHistoryOfStepPath`, reached via `pathFibreEquiv`. The honest record
   is therefore **split** — ray layer choice-free, ℤ/ω presentation not — and the upstream reroute
   is explicitly out of scope (wide blast radius, several tasks' territory).
4. **The four keystone declarations cannot all live in one module** (Finding 5).
   `plusStab_iff_rays` and `plusStab_iff_omega` mention `PlusTruthAt`, so their module must import
   `FormalSystem.PlusLanguage.PlusTruth`, which imports `Semantics.Truth`. That breaks the
   Presheaf cluster's documented "strictly below `Semantics/Truth.lean`" layering and would
   falsify its README's "no `Classical.choice` on any declaration in the cluster" — though *not*
   its mechanical `assert_not_exists`, which survives (probe P5, exit 0). A **two-module split**
   is forced. Acceptance's "under the categorical-structure topic" is read as the task's
   `state.json` **topic** (`categorical-structure`), which both modules satisfy, not as a
   directory.
5. **Name collision**: `FormalSystem.Semantics.Presheaf` already owns `glue`, `glue_unique`,
   `glue_states_le`, `glue_states_not_le` from 564's `Sheaf.lean` (Finding 6). The ray operator
   goes into a `Presheaf.Ray` sub-namespace, which also makes the parallel with `Sheaf.lean`
   legible rather than accidental.
6. **The paper anchor is stronger than the dispatch states, and was verified against the source**
   (report's Literature Proof Structure). The commented-out `⌢_z` passage defines the operator
   *by applying `app:gluing` to the restrictions of ρ and σ to `(−∞, z]` and `[z, ∞)`* — so the
   ray-layer operator is the paper's **primary** case and `PlusPasting.paste` is its total-history
   instance. Deliverable 2's "narrower" remit is the faithful transcription, not a residue.

The report sets no `user_decision`, and this plan adds none: every fork it names was resolved from
the artifacts plus a compiled probe.

### Prior Plan Reference

No prior plan. This is round 1 for this task (`plans/` is empty, `next_artifact_number` is 2), so
there is no phase structure, effort calibration or risk record to inherit. Calibration is taken
instead from task 564's completed round on the same cluster: four Lean phases at ~1.25 h each, with
the recurring per-phase overhead being the four regenerated files and the typst pre-commit hook
rather than the mathematics. This plan budgets that overhead explicitly in every Lean phase.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap phases are included. The task's
position is recorded by the dispatch instead: it is the keystone of the categorical front's
decidability connection, consuming 563 and 564, handing the *Saturation*-dependent directed case
to 565, pointing at 566's limit presentation by docstring only, and handing a stated requirement
(not a device) to the blocked substrate record 711.

## Goals & Non-Goals

**Goals**:
- Deliverable 1 — `PastRay`, `FutRay`, `PastRay.seam`, `FutRay.seam`, `pastOf`, `futOf`, the
  half-line `PartialHistory` bridges `PastRay.toPH`/`FutRay.toPH`, and the ray-to-`Beh F l`
  bridge `FutRay.toBeh`, all in `FormalSystem/Semantics/Presheaf/Ray.lean`
- Deliverable 2 — the ray-layer gluing operator `Presheaf.Ray.glue` with its two reading
  equations, its two restriction identities, uniqueness and totality, choice-free, with the seam
  step delegated to `PartialHistory.rel_across_seam` and the mixed-orientation case routed
  through `TaskFrame.reflection_of_ne`
- Deliverable 3 — the four acceptance-named declarations landed sorry-free with `[F.IsRegular]`
  verbatim: `seamFibreEquiv` (in `Ray.lean`), and `plusStab_iff_rays`, `seamOmegaEquiv`,
  `plusStab_iff_omega` (in `FormalSystem/PlusLanguage/PlusRayFibre.lean`), with their supporting
  `StabFibre`, `RayPair`, `BwdSeq`, `FwdSeq`, `SeqPair`, `ZPathFibre`, `pathFibreEquiv`, `splice`,
  `splice_isStepPath`, `omegaSplitEquiv`; and all four axiom sets pinned into the C2 harness
- Deliverable 4 — the subsumption-limit verdict recorded **in the library**
- Deliverable 5 — the E1 backward-dual probe on a time-asymmetric fixture, wired; plus the
  requirement hand-off to the substrate record, stated and not built
- Gate compliance: `lake build` green, `check-module-invariants.sh` at or better than the measured
  baseline, regenerated library root / inventories / citation manifest / typst counts

**Non-Goals**:
- Re-deriving `PlusLanguage.paste`, `pasteAt`, `Presheaf.glue`, `sheaf_clause` or
  `PartialHistory.rel_across_seam` (564's, landed)
- The colimit-of-bounded-sections route, the directed/ω-indexed gluing clause, and anything
  resting on *Saturation* (565's, by charter; the dispatch drops it from this task explicitly)
- The Possible Worlds clause `H_F ≅ lim Beh(F)(2x)` (566's) — connected by docstring pointer only,
  since 566 is `not_started` and nothing can be cited as landed
- Clearing `Classical.choice` from `FrameOver.worldHistoryOfStepPath` (out of scope: a core
  `Semantics/IntNormalForm.lean`-area declaration with many consumers across several tasks)
- Any determinization or universal-summary substrate, under any name (711's, and prohibited by
  the dispatch in force)
- Any width, tail-period or complexity bound; `not_finite_width_fmp` stands untouched
- The ℤ-time finite-carrier and finite-width FMP refutation promotions (720's)
- Fixing either pre-existing gate failure (the C15 unanchored `docs/theorem-index.md` row, and
  `check-paper-definitions.sh`'s `def:BX` drift) — both measured as baseline, both another task's
  territory
- The mirror fixture (backward-branching, forward-deterministic) that would be the *hard* backward
  test — filed as a follow-up, not absorbed here
- Pinning `app:gluing` by quoting its text, which would falsify its own `LIVE-UNPINNED` record row

### Shared Touches (deliberately outside `Files to modify`)

Five paths are edited by this task but are **intentionally absent** from every phase's
`Files to modify`, so that `plan-file-scope-harvest.sh` does not widen `file_scope` to cover
them. All five are produced by a command rather than authored, and widening would make the
collision gate defer the whole categorical front every cycle. This subsection is the record that
the omission is a decision, not an oversight.

| Path | How it is touched | Gate that makes it mandatory |
|---|---|---|
| `FormalSystem/Semantics/Presheaf.lean` | one `import FormalSystem.Semantics.Presheaf.Ray` line + one `## Modules` bullet (Phase 1) | C24/C6 root closure |
| `FormalSystem.lean` | regenerated: `lake exe mk_all --lib FormalSystem` (Phases 1, 3) | C33, byte-exact |
| `README.md`, `FormalSystem/README.md` | regenerated: `bash scripts/check-module-invariants.sh --emit-inventory` (every Lean phase) | INV |
| `typst/generated/status.typ` | regenerated: `bash scripts/typst-sync-check.sh --fix` (every Lean phase) | `.githooks/pre-commit` |
| `scripts/lean-citation-manifest.json` | regenerated: `python3 scripts/export-lean-citations.py` (Phase 3) | C35 span check |

Protocol for all five, in every phase: re-read immediately before touching; regenerate rather
than hand-edit; stage only the generated hunks with an explicit pathspec list (never a directory
or glob `git add`); re-run the build after the aggregator edit; **STOP and report** on any foreign
change inside a generated block.

### Declared `file_scope` vs. this plan's file list

`state.json`'s `file_scope` for this task reads `FormalSystem/Semantics/PartialHistory.lean`,
`FormalSystem/Semantics/Rays.lean`, `FormalSystem/Semantics/Gluing.lean` — anticipated at creation
time, before 564 landed and before the layering was measured. This plan diverges deliberately,
and `plan-file-scope-harvest.sh` will re-harvest from the phases below:

- `Semantics/Rays.lean` + `Semantics/Gluing.lean` → **one** module
  `Semantics/Presheaf/Ray.lean`. The ray layer and its gluing operator are one topic, the
  operator's seam argument is already shared library code, and the Presheaf cluster is where the
  behaviour-presheaf connection the task charter demands actually lives.
- `Semantics/PartialHistory.lean` → **not edited**. The one lemma this task would have added
  there, the seam-composition argument, was landed by 564 as
  `PartialHistory.rel_across_seam`. Phase 2 consumes it.
- Added: `FormalSystem/PlusLanguage/PlusRayFibre.lean`, forced by Research Integration point 4.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Acceptance demands `check-module-invariants.sh` "ALL CHECKS PASSED", but the measured pre-edit baseline is exit 1** on one pre-existing C15 row (`PlusSlicedCertificate.NoFiniteWidth.not_plusValidZTime_neg_Φ`, 1 of 240 rows unanchored) | H | H (certain) | **Measure and record the baseline before the first edit** and quote it in the summary, as 564 did and was accepted on. The row is explicitly another task's territory. The task must not be judged red for it, and must not "fix" it by anchoring a row it does not own. Second pre-existing failure to measure the same way: `check-paper-definitions.sh` exits 1 on the `def:BX` drift |
| **C2's exact-string baseline is a HARD STOP**; a half-applied edit bricks the gate for every subsequent task | H | M | Three edits in one commit, in the same order: extend `AXIOM_BASELINE` (line ~1107 heredoc), extend the parallel `AX_SRC` `#print axioms` heredoc (line ~1142) in the **identical order**, and update the `pass C2 "all thirty pinned axiom sets match baseline"` message count (line 1184). Use the **measured** lines, never assumed ones. `AXIOM_BASELINE` is also read by C21 (line ~4112), so re-run the gate **without** `--no-build` before committing |
| **A keystone statement weakened or strengthened**, which acceptance names as a defect | H | M | Transcribe the four statements **hypothesis for hypothesis**: `seamFibreEquiv` carries `[F.IsRegular]` at the declaration; `plusStab_iff_rays` under its section's `variable {F : TaskFrame} [F.IsRegular]`; `seamOmegaEquiv` under `section Omega`'s `variable [F.IsRegular]` over `F : FrameOver intOrder`; `plusStab_iff_omega` under `section StabOmega`'s `variable {F : FrameOver intOrder} [F.IsRegular]`. The probe's single `omit [F.IsRegular] in` covers `splice_isStepPath` **only** and must stay exactly there. In particular: do **not** "fix" a C34 complaint by replacing `[F.IsRegular]` with an explicit `Compositional` hypothesis — 564's own correct choice, a **defect** here |
| **C34b fires on the keystone docstring**: the probe's wording ("Nothing beyond *Compositionality* and the reflection convention is used") carried over verbatim onto a bracketed-binder declaration reads as a constraint claim without a marker line | M | M | Keep **all** constraint discussion inside module-level `/-! … -/` blocks, whose span C34b does not read, and write **no** `Constraints consumed:` marker — 564's verified route on this same cluster. A marker over `[F.IsRegular]` (which also supplies *Saturation*) would fail C34a unless discharged; should a marker ever be wanted, Phase 2's delegation to `rel_across_seam` (explicit `Compositional`, no bundling class) is exactly C34a's DELEGATION discharge. Acceptance constrains **signatures**; C34 constrains **docstrings and markers** — they do not conflict once that distinction is made, and no phase may "resolve" the tension by touching a binder |
| **`Presheaf.glue` name collision** with 564's `Sheaf.lean` | M | H (certain) | `Presheaf.Ray` sub-namespace throughout: `Ray.glue`, `Ray.glue_states_le`, `Ray.glue_states_not_le`, `Ray.glue_unique`. Do not name anything `glue` at `Presheaf` level |
| **`plusStab_iff_omega` landed inside `Semantics/Presheaf/`** would falsify that README's two prose claims (strictly-below-`Truth.lean`, and no `Classical.choice` in the cluster) even though the mechanical `assert_not_exists` survives | H | M | The two-module split (Research Integration point 4). `Ray.lean` imports `Presheaf.Behavior` only — which already supplies `WorldHistory` (defined in `Semantics/PartialHistory.lean`) and `partialHistory_ext` — so the README's "built on `Semantics/PartialHistory.lean` alone" sentence stays true verbatim and needs no amendment. Verify by re-reading both prose claims **after** Phase 3 |
| **C35 fails on any insertion into a span-recorded file** | M | H (certain) | `python3 scripts/export-lean-citations.py` and commit the regenerated manifest; never hand-edit it. 564 hit exactly this |
| **`FormalSystem.lean` hand-edited and C33 fails byte-comparison** | H | M | Always `lake exe mk_all --lib FormalSystem`; confirm with `check-module-invariants.sh --no-build` before committing |
| **A README inventory block or the typst counts left stale**; the root block tracks live `.lean` line counts, so *every* Lean phase makes both stale | M | H (certain) | `check-module-invariants.sh --emit-inventory` then `--emit-inventory --check`, and `bash scripts/typst-sync-check.sh --fix` with `typst/generated/status.typ` staged, at the end of **each** Lean phase. The pre-commit hook refuses otherwise |
| **`scripts/check-evidence-probes.sh` is declared in the `file_scope` of 710 and 720 as well** — a three-way concurrency hazard on a one-line edit | M | M | E1 adds **exactly one line** to the `WIRED` array (collection-relative path, **no** `.lean` extension). Add it in its own commit, re-read the file immediately before editing, never reorder existing entries, and never reach for `WIRED_REPO` |
| **`scripts/check-module-invariants.sh` is the repo's shared gate script**, declared by many tasks; Phase 3 must edit it for C2 | M | M | Declared in Phase 3's `Files to modify` so the collision gate can see it. Re-read immediately before editing, confine the diff to the two heredocs plus the one count, and stage that file alone |
| **The E1 fixture transcription is ~350 lines**, much larger than the dispatch's "one file" phrasing suggests, and `ofSlicedStep_isRegular` is **unavailable** (it needs `[Finite W]`; `Probe710.Node` is infinite) | M | H (certain) | Split across Phases 4 and 5: Phase 4 is the fixture to a green `lake env lean`, Phase 5 the backward summary. *Saturation* must be discharged by `TaskFrame.saturation_of_fib_finite fib_finite` through `FrameOver.ofReflectiveRegular`, transcribed in full — this is the single biggest cost and must not be shortcut |
| **E1 "derived" by `reflectTime`**, which looks available and is a trap | H | M | There is **no** semantic transport theorem for the plus language (`grep -rn 'PlusTruthAt.*reflectTime\|reflectTime.*PlusTruthAt' FormalSystem/` → zero hits), and a time reflection also reverses the **frame**, so any such transport would prove a statement about the mirror fixture — the very thing the time-asymmetry requirement exists to prevent. E1 argues backward reachability directly |
| **E1 over-read as the hard backward test.** Probe710's fixture is backward-**deterministic** (every node has exactly one predecessor) and forward-branching, so on it the backward factor is a singleton | M | H (certain) | The probe header records this limit in its own words, names the mirror fixture as the genuinely hard dual test, and files it as a follow-up. E1 is still exactly what the dispatch specifies and is a real result — it exercises the unique-predecessor/canonicity machinery the forward probe never touched |
| **A bare `decide_will` citation**, which is ambiguous across this probe collection | L | M | Always qualify: `Probe718FiniteGraph.decide_will` or `Probe718PathQuantifier.decide_will`. Applies in docstrings, the probe header and the summary alike |
| **Deliverable 4 or 5's verdict recorded only in the plan or summary**, which acceptance names as insufficient | M | M | Phase 6 lands both in the library: a named-claim README section on the proven model of `FormalSystem/Metalogic/Decidability/FMP/README.md`'s "### The finite-carrier route is refuted, not merely open", plus a `/-! … -/` block in `Ray.lean`. Phase 6 is **not** droppable |
| **A choice-free step silently replaced by a classical one** during transcription | M | M | Re-measure with `#print axioms` at the end of **every** Lean phase and record the rows; the target is `[propext, Quot.sound]` for everything except the three ω declarations, whose `Classical.choice` is upstream and recorded with its named cause |
| **Builds run in the foreground time out or are misread** | M | M | Every build detached through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`, reading the verdict from the guard's own `result` and never a pipe exit code. See `context/patterns/bounded-build-waiter.md` |
| **A concurrent sibling touches a regenerated file** | M | M | On any foreign commit, foreign uncommitted hunk inside a generated block, or a build this task did not start: **STOP and report** after checking `git log`. Do not reconcile |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2, 5 | 1 (for 2), 4 (for 5) |
| 3 | 3 | 2 |
| 4 | 6 | 3, 5 |

Phases within the same wave can execute in parallel. The parallelism here is genuine and is the
dispatch's own instruction: Phases 4–5 (the E1 probe) touch only `specs/evidence/` and
`scripts/check-evidence-probes.sh`, while Phases 1–3 touch only `FormalSystem/` and the
regenerated files, so the two tracks share no path. **Deliverables 1–4 must not wait on E1** —
if Phases 4–5 stall or E1 yields a counterexample, Phases 1–3 and 6's Deliverable-4 half proceed
unchanged, and only Phase 6's Deliverable-5 half absorbs the outcome.

If scope must be cut, the cut order is **Phase 5's decidability instance last, Phase 4–5 before
Phase 6, and Phases 1–3 never**: the four keystone declarations and their pinned axiom sets are
the acceptance core.

---

### Phase 1: The ray layer [COMPLETED]

**Goal**: `FormalSystem/Semantics/Presheaf/Ray.lean` exists, builds green and sorry-free, and
carries Deliverable 1 in full: the two ray types with their task-respect constraints, the seam
projections, the possible-world restrictions `pastOf`/`futOf`, and the two bridges relating the
ray layer to `PartialHistory` and to `Beh F l`.

**Tasks**:
- [x] Measure and record the pre-edit gate baseline **before any edit**:
      `bash scripts/check-module-invariants.sh --no-build` (expect exit 1, exactly one C15 row),
      `bash scripts/check-paper-definitions.sh` (expect exit 1 on the `def:BX` drift), and
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`
- [x] Create `FormalSystem/Semantics/Presheaf/Ray.lean` with the cluster's copyright header,
      `import FormalSystem.Init` and `import FormalSystem.Semantics.Presheaf.Behavior` (which
      already supplies `WorldHistory`, defined in `Semantics/PartialHistory.lean`, and
      `partialHistory_ext`), inside `namespace FormalSystem.Semantics.Presheaf`
- [x] Transcribe `PastRay` and `FutRay` **verbatim** from
      `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` lines 48–55: the
      subtype-of-dependent-function presentation on `{x : F.Duration // x ≤ t}` and
      `{x // t ≤ x}` carrying the all-pairs task constraint. The subtype domain is load-bearing —
      it is what makes ray equality funext, which `seamFibreEquiv`'s `right_inv` depends on — so
      **do not** retype these as `PartialHistory` subtypes and do not introduce any new type
- [x] Transcribe `PastRay.seam` and `FutRay.seam` (lines 58–62) and `pastOf`/`futOf` (lines
      129–137), the restriction maps from a possible world to its two rays
- [x] Add `PastRay.toPH` and `FutRay.toPH`, the half-line `PartialHistory` wrappers (report
      Finding 8, compiled). These are what makes Phase 2's delegation to
      `PartialHistory.rel_across_seam` possible, and they are why **both** ray presentations are
      needed: the dependent-function form gives funext equality, the `PartialHistory` form gives
      access to the landed shared API
- [x] Add `FutRay.toBeh (f : FutRay F 0) (l) (hl : 0 ≤ l) : Beh F l`, the ray-layer-to-`Beh F l`
      restriction Deliverable 1 names (report Finding 9, compiled, `[propext]`). `Beh F l` is
      `{τ : PartialHistory F // ∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l)}`, so the domain is written as
      the literal predicate with `property := fun _ => Iff.rfl` — never as a domain *equality*
- [x] Write the module `/-! … -/` block: what a ray is, why the subtype domain rather than a new
      type, why both presentations exist, and that the colimit-of-bounded-sections route is out of
      scope with *Saturation* as the reason. Cite `app:gluing` as a **pointer only** and never
      quote its text; cite declaration **names**, never `file.lean:NNN` (C20); no task numbers (C9)
- [x] Close the file with
      `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`,
      matching the cluster's other three modules
- [x] Add one `import FormalSystem.Semantics.Presheaf.Ray` line and one `## Modules` bullet to
      `FormalSystem/Semantics/Presheaf.lean` (Shared Touches protocol)
- [x] Regenerate: `lake exe mk_all --lib FormalSystem`,
      `bash scripts/check-module-invariants.sh --emit-inventory` then `--emit-inventory --check`,
      `bash scripts/typst-sync-check.sh --fix`
- [x] Add the new declarations to `FormalSystem/Semantics/Presheaf/README.md`'s hand-maintained
      `## Key Definitions` list

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase is estimated at ~120 lines of new Lean in one new file, with the
ray types and seam projections transcribed from probe lines 48–62 and 129–137 and two bridges
added. Confirm at implementation time by `wc -l FormalSystem/Semantics/Presheaf/Ray.lean` and by
checking that no declaration outside that line range was needed; if a third bridge or a
`PartialHistory` lemma turns out to be missing, that is 564's territory and must be raised via
`/revise` on that task rather than absorbed here.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Ray.lean` - new: the ray layer (Deliverable 1)
- `FormalSystem/Semantics/Presheaf/README.md` - re-emitted inventory block plus Key Definitions
  for the new module

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0,
  detached, verdict read from the guard's `result`
- No `sorry`: `grep -rn 'sorry' FormalSystem/Semantics/Presheaf/` returns nothing
- `#print axioms` on `PastRay`, `FutRay`, `PastRay.seam`, `FutRay.seam`, `pastOf`, `futOf`,
  `PastRay.toPH`, `FutRay.toPH`, `FutRay.toBeh`, each fully qualified — expect `[propext]` on
  the definitions; record every row verbatim
- `bash scripts/check-module-invariants.sh --no-build` — C9, C20, C24, C31, C33, C34a, C34b and
  INV green; no new failure relative to the recorded baseline
- `bash scripts/check-module-invariants.sh --emit-inventory --check` — no byte would change
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` — exit 0
- Commit, scoped to this phase's files plus the regenerated hunks

---

### Phase 2: The ray-layer gluing operator, choice-free [COMPLETED]

**Goal**: `Presheaf.Ray.glue` exists in `Ray.lean` with its two reading equations, both
restriction identities, uniqueness and totality — and the whole ray-layer path measures
`[propext, Quot.sound]`, with `Classical.choice` nowhere on it.

**Tasks**:
- [x] Transcribe `glueFun` (probe lines 65–70) into the `Presheaf.Ray` sub-namespace
- [x] Transcribe `glue_rel_le_lt`, but **as a delegation** to the landed
      `PartialHistory.rel_across_seam` rather than the probe's hand proof (report Finding 8,
      compiled first try, `[propext, Quot.sound]`): pass `F.comp`, `σ := b.toPH`, `τ := f.toPH`,
      `hσm := le_rfl`, `hτm' := le_rfl`, `hmatch := hseam`, and
      `hd := by rw [add_comm]; exact (sub_add_sub_cancel s' t s).symm`. This is the
      de-duplication 564 exists to create, and it reaches a byte-identical conclusion
- [x] Transcribe `glue_rel` (probe lines 86–99) with the **reflection reroute** in the
      mixed-orientation case — this is mandatory, not optional (Research Integration point 2):
      replace `rw [dif_neg hs, dif_pos hs', F.reflection, neg_sub]` with
      `rw [dif_neg hs, dif_pos hs']`, then
      `have hne : s' - s ≠ 0 := sub_ne_zero.mpr (by intro h; exact hs (h ▸ hs'))`, then
      `rw [F.reflection_of_ne hne, neg_sub]`, then
      `exact glue_rel_le_lt b f hseam hs' hs`
- [x] Transcribe `glue` (probe lines 101–104) as `Ray.glue`, and the two reading equations
      `glue_state_of_le`/`glue_state_of_not_le` as `Ray.glue_states_le`/`Ray.glue_states_not_le`
      — the `Presheaf.Ray` sub-namespace is required by the collision with 564's `Sheaf.lean`
      (Research Integration point 5) *(deviation: altered — the sub-namespace is NOT sufficient. Gate C23 forbids outer-shadows-inner BASE-name pairs regardless of namespace, and fired on all four of `glue`, `glue_states_le`, `glue_states_not_le`, `glue_unique` against `Sheaf.lean`. Landed as `Ray.seamGlue`, `Ray.seamGlue_states_le`, `Ray.seamGlue_states_not_le`, `Ray.seamGlue_unique`, with the whole operator family renamed consistently (`seamGlueFun`, `seamGlue_rel`, `seamGlue_rel_le_lt`, `seamGlue_isTotal`, `pastOf_seamGlue`, `futOf_seamGlue`, `seamGlue_clause`). None is an acceptance-named declaration; the plan's own acceptance clause demands the gate green, so the gate is the binding constraint. Rationale recorded in the module docstring.)*
- [x] State the two **restriction identities** — that `pastOf (Ray.glue b f …) t = b` and
      `futOf (Ray.glue b f …) t = f` — and `Ray.glue_unique`, the `∃!` packaging parallel to
      `Sheaf.lean`'s `glue_unique`. These follow from the two reading equations plus funext on the
      ray subtypes; `seamFibreEquiv`'s `left_inv`/`right_inv` (Phase 3) already carry the content,
      so state them here as the named Deliverable-2 obligations rather than re-deriving anything
- [x] State **totality**: the glued object is a `WorldHistory F`, i.e. total on `F.Duration` —
      which is what `glue`'s construction already gives, since the two half-lines cover
      `F.Duration` and meet in exactly one point. Name this explicitly; Phase 6's verdict depends
      on it being a stated library fact
- [x] Extend the module `/-! … -/` block: the operator is the paper's own `⌢_z` at the ray layer
      (Research Integration point 6), `PlusPasting.paste` is its total-history instance and is
      **not** re-derived here, the frame law actually used is `TaskFrame.comp` plus the reflection
      convention and nothing else, and the measured axiom rows. Keep every constraint word inside
      the `/-!` block (C34b); write no `Constraints consumed:` marker
- [x] Apply the **same** reflection reroute to
      `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` so the probe and the
      library stay byte-comparable and the probe's own axiom-record footer reads choice-free
      (report Decision 6); re-run
      `lake env lean specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean`
- [x] Regenerate the inventories and typst counts (Shared Touches protocol)
- [x] *(deviation: altered — gate C28 rejects the `show` tactic (`linter.style.show`, budget entry "use `change` where the goal changes"). The four tactic-position `show`s transcribed from the probe are landed as `change`, which is the convention `Sheaf.lean` already follows. Term-level `rw [show … from …]` is unaffected and kept verbatim.)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Ray.lean` - the gluing operator, its reading equations,
  restriction identities, uniqueness and totality
- `FormalSystem/Semantics/Presheaf/README.md` - Key Results for the new declarations
- `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` - the one-line
  reflection reroute, keeping probe and library byte-comparable

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0,
  detached
- No `sorry` under `FormalSystem/Semantics/Presheaf/`
- `#print axioms` on `Ray.glue`, `Ray.glue_states_le`, `Ray.glue_states_not_le`, the two
  restriction identities and `Ray.glue_unique`, each fully qualified: **all
  `[propext, Quot.sound]`, no `Classical.choice`**. This is a hard gate on the phase — if any row
  shows `Classical.choice`, the reroute was not applied correctly and the phase is not done
- `lake env lean specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` — exit 0,
  and its axiom-record footer now reads `[propext, Quot.sound]` for `glue_rel`, `glue`,
  `seamFibreEquiv` and `plusStab_iff_rays`
- `bash scripts/check-evidence-probes.sh` — no regression (the probe is already `WIRED`)
- `bash scripts/check-module-invariants.sh --no-build` — no new failure vs. the baseline
- Commit, scoped

---

### Phase 3: The keystone promotion, in two modules, with the axiom sets pinned [COMPLETED]

**Goal**: the four acceptance-named declarations are in `FormalSystem/`, sorry-free, carrying
`[F.IsRegular]` verbatim, each at its honest layer, and each with its **measured** axiom set
pinned into the C2 harness.

**Tasks**:
- [x] Transcribe `StabFibre`, `RayPair` (probe lines 121–127) and **`seamFibreEquiv`** (lines
      143–172) into `Ray.lean`. `seamFibreEquiv` carries `[F.IsRegular]` **at the declaration
      itself** — verbatim, neither weakened to a bare `TaskFrame` nor strengthened
- [x] Create `FormalSystem/PlusLanguage/PlusRayFibre.lean` with the copyright header,
      `import FormalSystem.Semantics.Presheaf.Ray`,
      `import FormalSystem.PlusLanguage.PlusTruth` and
      `import FormalSystem.Semantics.IntNormalForm` (which is where
      `FrameOver.worldHistoryOfStepPath` and `IsStepPath` live), inside
      `namespace FormalSystem.PlusLanguage`. This module carries **no** `assert_not_exists` on the
      proof system — it sits above `Semantics/Truth.lean` by construction, and that is the whole
      reason for the split
- [x] Transcribe `section Stab` with `variable {F : TaskFrame} [F.IsRegular]` and
      **`plusStab_iff_rays`** (probe lines 178–211) under it
- [x] Transcribe `section Omega`: `BwdSeq`, `FwdSeq`, `SeqPair`, `ZPathFibre` under
      `variable {F : FrameOver intOrder}`, then `variable [F.IsRegular]`, then `pathFibreEquiv`,
      `splice`, the single `omit [F.IsRegular] in` **immediately before `splice_isStepPath` and
      nowhere else**, `omegaSplitEquiv`, and **`seamOmegaEquiv`** (probe lines 215–348)
      *(deviation: altered — `ring` is unavailable in this module's import closure, the same
      constraint `Sheaf.lean` documents for the Presheaf cluster, so the probe's four
      `by push_cast; ring` side goals are discharged by `by push_cast; omega`. The statements are
      unchanged. Separately, the transcribed tactic-position `show`s are landed as `change` for
      gate C28, and one `change` that the unused-tactic linter reported as a no-op is dropped.)*
- [x] Transcribe `section StabOmega` with `variable {F : FrameOver intOrder} [F.IsRegular]` and
      **`plusStab_iff_omega`** (probe lines 352–378) under it
- [x] Write `PlusRayFibre.lean`'s module `/-! … -/` block: `⊡` is a quantifier over a **product of
      two path spaces**, one factor backward from the seam and one forward; the ray half is
      choice-free while the ω half is not, with `FrameOver.worldHistoryOfStepPath` named as the
      cause and the reroute recorded as out of scope; `not_finite_width_fmp` stands untouched and
      this presentation is the **mechanism behind** that refutation (a product of two path spaces
      cannot be a finite fibre), not an escape from it; and a **docstring pointer only** to the
      Possible Worlds limit presentation `H_F ≅ lim Beh(F)(2x)`, which is not landed and must not
      be cited as a result. Constraint vocabulary stays inside the `/-!` block
- [x] Add the aggregator import for the new `PlusLanguage` module as that cluster's convention
      requires (re-read `FormalSystem/PlusLanguage/README.md` and any `PlusLanguage.lean`
      aggregator first), and regenerate `FormalSystem.lean`
- [x] **Measure** `#print axioms` on all four keystone declarations, fully qualified, and record
      the exact output lines. Expect `[propext, Quot.sound]` for `seamFibreEquiv` and
      `plusStab_iff_rays`, `[propext, Classical.choice, Quot.sound]` for `seamOmegaEquiv` and
      `plusStab_iff_omega` — but **pin what is measured, not what is expected**
- [x] Pin into `scripts/check-module-invariants.sh`, three edits in **one** commit: append the
      four measured `'Name' depends on axioms: [...]` lines to the `AXIOM_BASELINE` heredoc;
      append the four `#print axioms <fully-qualified-name>` lines to the `AX_SRC` heredoc in the
      **identical order**; update the `pass C2 "all thirty pinned axiom sets match baseline"`
      count. Then re-run the gate **without** `--no-build` — `AXIOM_BASELINE` is also consumed by
      C21
- [x] Regenerate `scripts/lean-citation-manifest.json` with
      `python3 scripts/export-lean-citations.py` (C35 spans shift on any insertion), plus the
      inventories and typst counts
- [x] Re-read `FormalSystem/Semantics/Presheaf/README.md`'s two prose claims (strictly below
      `Semantics/Truth.lean`; no `Classical.choice` in the cluster) and confirm both are **still
      true verbatim**. If either is not, the split was done wrong — fix the placement, never the
      claim
- [x] Add the new declarations to both READMEs' Key Definitions / Key Results lists

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts **four** acceptance-named declarations plus ten
supporting ones (`StabFibre`, `RayPair`, `BwdSeq`, `FwdSeq`, `SeqPair`, `ZPathFibre`,
`pathFibreEquiv`, `splice`, `splice_isStepPath`, `omegaSplitEquiv`), transcribed from probe lines
121–378 (~260 lines), and **four** new C2 baseline rows. Confirm at implementation time by
enumerating the declarations actually landed in each module against the probe's own declaration
list, and by diffing the C2 heredoc edit to exactly four added lines in each of the two heredocs.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Ray.lean` - `StabFibre`, `RayPair`, `seamFibreEquiv`
- `FormalSystem/PlusLanguage/PlusRayFibre.lean` - new: `plusStab_iff_rays`, the ω-sequence
  presentation, `seamOmegaEquiv`, `plusStab_iff_omega`
- `FormalSystem/PlusLanguage/README.md` - inventory plus Key Definitions/Results for the new
  module
- `FormalSystem/Semantics/Presheaf/README.md` - Key Results for `seamFibreEquiv`
- `scripts/check-module-invariants.sh` - the C2 `AXIOM_BASELINE` and `AX_SRC` heredocs plus the
  pass-message count, four measured rows each

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0,
  detached
- No `sorry` in either new module
- All four keystone declarations elaborate with `[F.IsRegular]` present: confirm by
  `lake env lean` on a scratch file doing `#check @FormalSystem.…` on each, and by reading the
  `variable`/declaration lines back
- `#print axioms` rows recorded verbatim for all four, and the recorded rows **byte-match** the
  lines added to `AXIOM_BASELINE`
- `bash scripts/check-module-invariants.sh` (**no** `--no-build`) — C2 PASS with the updated
  count, C21 PASS, C33 PASS byte-exact, C35 PASS, INV green; no new failure vs. the baseline
- `bash scripts/check-evidence-probes.sh` — exit 0, no citation broken; the promoted probe stays
  `WIRED` unconverted (report Finding 12)
- Commit, scoped

---

### Phase 4: The E1 fixture, transcribed [COMPLETED]

**Goal**: one new file under `specs/evidence/seam-gluing-ray-product/` compiles green at
`lake env lean` carrying a **time-asymmetric** step fixture — `Node`, `Step`, the predecessor
inverses, finite fibres, the regular `FrameOver` and the model — transcribed, not imported.

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` with
      the collection's header conventions, `import FormalSystem` **only**, and its own namespace
      (e.g. `Probe719Backward`). Every probe in this collection imports only `FormalSystem` and
      never another probe — so the fixture is **transcribed** from
      `specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`,
      never imported from it
- [x] Transcribe the carrier:
      `inductive Node | pre : ℕ → Node | x : ℕ → Node | post : ℕ → ℕ → Node`, `deriving
      DecidableEq`
- [x] Transcribe `Step` with its four constructors — `pre (k+1) → pre k`, `pre k → x k`,
      `x k → post k 0`, `post k j → post k (j+1)` — finitely branching, and with **exactly one
      predecessor** at every node
- [x] Transcribe the three inverse lemmas (`step_inv_pre`, `step_inv_x`, `step_inv_post`), which
      are what give backward determinism
- [x] Transcribe `fwdList`/`bwdList`/`fib_finite` and build the frame as
      `FrameOver.ofReflectiveRegular Node (ofStepRel Step) …`, discharging *Saturation* by
      `TaskFrame.saturation_of_fib_finite fib_finite`. **`ofSlicedStep_isRegular` is unavailable**
      — it requires `[Finite W]` and `Node` is infinite — so this construction must be
      transcribed in full and not substituted
- [x] Transcribe the model `M : TaskModel F.toTaskFrame := ⟨fun w _ => ∃ k, w = Node.x k⟩`, so `p`
      holds exactly at the `x` states
- [x] Transcribe as much of the canonicity argument as the backward summary will need:
      `canon k t s`, `canon_step`, `canon_eq_x_iff`, `path_eq_canon` (every step path is
      canonical), `hist_canon` (every `WorldHistory F` is some `canon k t`), and the
      agreeing-at-a-point lemmas `lt_of_canon_eq_of_lt`, `gt_of_canon_eq_of_gt`,
      `eq_of_canon_eq_of_eq`
- [x] Write the header's scope paragraph: what the fixture is, why a **time-asymmetric** fixture
      is required (the finite-width obstruction lives in the backward factor, and a time-symmetric
      fixture is exactly the one that cannot see it), and the compile-check command line
- [x] Do **not** add the `WIRED` entry yet — Phase 5 does that in its own commit

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the transcription is estimated at ~350 lines, from
`NoFiniteWidthModel.lean` lines ~48–390. Confirm at implementation time by `wc -l` on the new
file and by checking each transcribed declaration against its source; if the canonicity argument
turns out to need materially more than the enumerated lemmas, record the overrun in the phase's
commit message rather than silently widening.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` - new: the
  time-asymmetric fixture

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` —
  exit 0
- No `sorry` and no `axiom` in the new file:
  `grep -nE 'sorry|^axiom ' specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean`
  returns nothing
- The file's only `import` is `import FormalSystem`
- No automata, no determinization, no universal-summary device, under any name
- Commit, scoped to this one file

---

### Phase 5: The E1 backward summary and its wiring [COMPLETED]

**Goal**: the backward stability operator is decided **by backward reachability** at a seam state
on the time-asymmetric fixture, mirroring `Probe718FiniteGraph.will_iff_allPathsMeet` clause for
clause, with the result — proof or counterexample — recorded in the probe header and the probe
wired into the evidence gate.

**Tasks**:
- [x] State `AllBwdPathsMeet`: the backward-reachability predicate dual to
      `Probe718FiniteGraph.AllPathsMeet` — every backward root path from the seam state meets the
      `p`-set
- [x] Prove `pastStab_iff_allBwdPathsMeet`, mirroring `Probe718FiniteGraph.will_iff_allPathsMeet`
      **clause for clause**, for the backward operator
      `PlusFormula.stab (PlusFormula.somePast p)` — where
      `somePast φ := PlusFormula.snce PlusFormula.top φ`, the exact dual of the forward probe's
      `someFuture φ := untl top φ`
- [x] **Do not** attempt to derive this by `PlusFormula.reflectTime`. There is no semantic
      transport theorem for the plus language, and a time reflection also reverses the frame, so
      any such transport would prove a statement about the **mirror** fixture — the very thing the
      time-asymmetry requirement exists to prevent. Argue backward reachability directly
- [x] Establish the three-row decision table (report Finding 10): at `post k j` the unique
      backward chain meets the `p`-set at `x k`, so the operator is **True**; at `x k` and at
      `pre k` the chain never meets it, so **False**. Note that Probe710's own `Φ_true` already
      corroborates the `x k` row *(deviation: altered — the two negative rows are proved from
      NAMED backward chains, `bwdFromX` and `bwdFromPre`, with their step lemmas, rather than
      from inline `if`-expressions. Inline lambdas left the step goals beta-unreduced and
      `rw`-resistant; the named chains make each step proof a bare constructor application. Same
      content, three extra declarations.)*
- [x] Land `decide_past_stab` and a `Decidable` instance on the model of
      `Probe718FiniteGraph.decidable_will` — a **state-dependent** decision here, strictly more
      informative than the forward probe's uniformly-False `Probe718FiniteGraph.decide_will`
- [x] Record in the header, in the probe's own words: (a) the result — and if the two-factor
      presentation turns out to **fail** for the backward direction, record that as the
      deliverable, since an obstruction is a theorem under this programme's discipline;
      (b) the **honest limit** — Probe710's fixture is backward-deterministic, so the backward
      factor is a singleton and E1 tests the backward dual at its easiest instance; the genuinely
      hard dual test is a **mirror** fixture (backward-branching, forward-deterministic), filed as
      a follow-up and not absorbed here; (c) the `reflectTime` trap and why it was not used
- [x] Qualify **every** citation of `decide_will` as `Probe718FiniteGraph.decide_will` or
      `Probe718PathQuantifier.decide_will` — the bare name is ambiguous across this collection
- [x] Add **exactly one** line to `scripts/check-evidence-probes.sh`'s `WIRED` array:
      `"seam-gluing-ray-product/backward-dual-asymmetric-fixture"` — collection-relative, **no**
      `.lean` extension. Re-read the file immediately before editing, reorder nothing, and do not
      use `WIRED_REPO`. This file is declared in two other tasks' `file_scope`; commit it alone

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: interface

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` - the backward
  summary, the decision table, the decidability instance, and the header's result-and-limit record
- `scripts/check-evidence-probes.sh` - one new `WIRED` entry

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` —
  exit 0, no `sorry`
- `bash scripts/check-evidence-probes.sh` — exit 0 with the new entry included, and every
  pre-existing entry still reproducing
- `git diff scripts/check-evidence-probes.sh` shows exactly one added line and no reordering
- No automata and no substrate, under any name
- Two commits: the probe content, then the one-line wiring

---

### Phase 6: The two recorded verdicts [COMPLETED]

**Goal**: Deliverable 4's subsumption limit and Deliverable 5's requirement hand-off exist **in
the library**, as named claims with their limits stated — not only in this plan or a summary.

**Tasks**:
- [x] Add a named-claim section to `FormalSystem/Semantics/Presheaf/README.md` on the proven model
      of `FormalSystem/Metalogic/Decidability/FMP/README.md`'s
      "### The finite-carrier route is refuted, not merely open" — a named claim followed by
      explicitly stated limits
- [x] Deliverable 4, the **positive** half: the ray gluing supplies the effective, choice-free
      total-history construction that `BiLasso/Orbit.lean` built only for the bi-lasso case
      (`extend_periodic`, `extend_periodic_of_icc`, whose "no Zorn" property
      `BiLasso/Agreement.lean` preserves to protect), now for **every** pair of agreeing half-line
      rays at a regular frame — measured `[propext, Quot.sound]` (Phase 2)
- [x] Deliverable 4, the **limit**, stated as a recorded verdict and **not** as full subsumption:
      the general Extension Theorem (`Semantics/Extension/Extension.lean`'s `extension`, routed
      through `PartialHistory.exists_maximal_extension`, measured
      `[propext, Classical.choice, Quot.sound]`) handles a strictly wider class of inputs. Name
      the gap precisely: a pair of half-line rays covers all of `F.Duration` and meets in exactly
      one point, whereas an arbitrary `PartialHistory`'s `domain` is an arbitrary predicate with
      neither property, so `Ray.glue`'s total case split has no analogue there. This closes
      Deliverable 4 **affirmatively with an explicit gap statement**, not by reasoned exclusion
- [x] Record the measured **split** on choice: the ray layer is choice-free; the ℤ/ω presentation
      is not, with `FrameOver.worldHistoryOfStepPath` named as the cause and its reroute recorded
      as out of this task's scope
- [x] Deliverable 5's requirement, **stated and handed over, built and selected by nothing here**:
      from `Probe718PathQuantifier.exists_ne_stab`/`exists_ne_universal` (the existential
      per-path summary is True everywhere while the real value of the stability-of-eventually
      formula is False everywhere, `Probe718PathQuantifier.decide_will`) together with
      `plusStab_iff_rays`/`plusStab_iff_omega` presenting `⊡` as a quantifier over a product of
      two path spaces, the requirement is: a summary device **universal over both factors**, hence
      complementation-shaped, hence **not** supplied by any nondeterministic per-path summary —
      and, by Phase 5's recorded limit, one whose **backward** factor is summarised on its own
      terms rather than by time-reversal of the forward one. Assert **nothing** about which
      candidate device supplies it. Land **no** complexity claim; note only that the CTL\*
      2EXPTIME lower bound is the sanity check on any future bound
- [x] Cite the path-category connection as a **paper anchor only**: `def:path-category`,
      `def:conduche` and `cor:path-fibration` are `DANGLING` rows in
      `docs/reference/paper-definitions-of-record.md` and no free-category presentation exists
      under `FormalSystem/`, so the free-category reading of `Path(F)` must never be cited as
      landed *(deviation: altered — the three anchors are NOT `DANGLING` rows; that record lists
      them among nine appendix anchors deliberately NOT pinned, so citing them failed C15 with "3
      paper-anchor citation(s) resolve to nothing". Satisfying C15 would have meant widening that
      record for a region the tree does not depend on, which its own recorded decision exists to
      prevent. The verdict therefore describes the free-category reading, states that nothing
      under `FormalSystem/` presents it and that it must never be cited as landed, and says
      explicitly that the paper's labels are not named because naming them is what would make them
      load-bearing.)*
- [x] Mirror the Deliverable-4 verdict as a `/-! … -/` block in `Ray.lean` so the claim is
      readable from the module as well as the README, keeping constraint vocabulary inside the
      block (C34b) and citing declaration names rather than `file.lean:NNN` (C20)
- [x] Regenerate the inventories and typst counts; re-run the full gate set

**Timing**: 1 hour

**Depends on**: 3, 5

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/README.md` - the named-claim verdict section (Deliverables 4
  and 5)
- `FormalSystem/Semantics/Presheaf/Ray.lean` - the mirrored verdict as a module `/-!` block

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0
- `bash scripts/readme-lint.sh FormalSystem` — exit 0
- `bash scripts/check-module-invariants.sh` (**no** `--no-build`) — **ALL CHECKS PASSED** apart
  from the one pre-existing C15 row recorded in Phase 1's baseline; C2's four new rows PASS
- `bash scripts/check-paper-definitions.sh` — same exit status as the Phase 1 baseline (no new
  drift introduced; the `def:BX` drift is not fixed here)
- Grep-level self-check: no `file.lean:NNN` citation and no task number in any text this task
  wrote under `FormalSystem/`; every `decide_will` mention qualified
- `lake build BimodalTest` — exit 0
- Commit, scoped

---

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits
      0 at the end of **every** phase, run detached
- [ ] `lake build BimodalTest` exits 0 at the end of the task
- [ ] Zero `sorry` in every file this task touches, checked per phase
- [ ] All four acceptance-named declarations present in `FormalSystem/`, sorry-free, carrying
      `[F.IsRegular]` **verbatim** — `seamFibreEquiv` at the declaration, the other three under
      their sections' `variable` lines — with the single `omit [F.IsRegular] in` still covering
      `splice_isStepPath` and nothing else
- [ ] `#print axioms` measured and recorded for every new declaration; the ray-layer path is
      `[propext, Quot.sound]` with no `Classical.choice`, and the three ω declarations' retained
      `Classical.choice` is recorded with `FrameOver.worldHistoryOfStepPath` named as its cause
- [ ] C2: the four measured rows pinned in both `AXIOM_BASELINE` and `AX_SRC` in the same order,
      with the pass-message count updated; the gate run **without** `--no-build`
- [ ] `bash scripts/check-module-invariants.sh` at or better than the Phase 1 baseline (the single
      pre-existing C15 row is the only tolerated failure, and it is recorded, not fixed)
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with the new E1 entry and every pre-existing
      entry reproducing; no outside citation of the promoted probe broken
- [ ] `bash scripts/readme-lint.sh FormalSystem`,
      `bash scripts/check-copyright-headers.sh --strict FormalSystem`,
      `bash scripts/typst-sync-check.sh --counts-only` all exit 0
- [ ] `FormalSystem.lean` byte-current (C33); `scripts/lean-citation-manifest.json` regenerated
      (C35); both README inventory blocks re-emitted (INV)
- [ ] Both of `FormalSystem/Semantics/Presheaf/README.md`'s prose claims (strictly below
      `Semantics/Truth.lean`; no `Classical.choice` in the cluster) **still true verbatim** after
      the split
- [ ] Deliverables 4 and 5's verdicts present in the library, not only in artifacts under `specs/`
- [ ] No automata, determinization or universal-summary device anywhere in the diff, under any
      name; no width, tail-period or complexity bound committed; `not_finite_width_fmp` untouched

## Artifacts & Outputs

- `FormalSystem/Semantics/Presheaf/Ray.lean` — new: the ray layer, the ray-layer gluing operator,
  `seamFibreEquiv`, and the Deliverable-4 verdict block
- `FormalSystem/PlusLanguage/PlusRayFibre.lean` — new: `plusStab_iff_rays`, the ω-sequence
  presentation, `seamOmegaEquiv`, `plusStab_iff_omega`
- `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` — new: the E1
  backward-dual probe on a time-asymmetric fixture
- `scripts/check-evidence-probes.sh` — one new `WIRED` entry
- `scripts/check-module-invariants.sh` — four new C2 pinned rows
- `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` — the reflection reroute,
  keeping probe and library byte-comparable
- `FormalSystem/Semantics/Presheaf/README.md`, `FormalSystem/PlusLanguage/README.md` — inventories,
  Key Definitions/Results, and the two recorded verdicts
- Shared/regenerated, outside `Files to modify` by design: `FormalSystem/Semantics/Presheaf.lean`,
  `FormalSystem.lean`, `README.md`, `FormalSystem/README.md`, `typst/generated/status.typ`,
  `scripts/lean-citation-manifest.json`
- `specs/719_ray_layer_seam_gluing_and_stab_fibre/summaries/01_*-summary.md` — the implementation
  summary, recording every gate's exit code, the measured pre-edit baseline, and every
  `#print axioms` row verbatim

## Rollback/Contingency

- **Per-phase**: every phase ends at a green `lake build` and a scoped commit, so rollback is
  `git revert` of that phase's commits. Before any intentional rollback that would discard
  uncommitted work, run `bash .claude/scripts/git-snapshot.sh 719` first; for an ordinary
  defensive checkpoint before risky work, use `bash .claude/scripts/git-snapshot.sh 719
  --no-revert`, which is durable without reverting the working tree.
- **C2 half-applied** (the one state that bricks the gate for other tasks): revert
  `scripts/check-module-invariants.sh` to `HEAD` immediately and redo all three edits in a single
  commit. Never leave `AXIOM_BASELINE` and `AX_SRC` out of step.
- **The reflection reroute fails to clear `Classical.choice`** (contradicting the compiled
  measurement): do **not** weaken a keystone statement or add a hypothesis to compensate. Land the
  declarations with their measured axiom sets, pin what is measured, and record the discrepancy
  against the report's probe P2 as a finding for the summary.
- **E1 yields a counterexample**: that is the deliverable, not a failure. Record it in the probe
  header as a falsification of the two-factor presentation for the backward direction, and let
  Phase 6's Deliverable-5 half state the consequence. Phases 1–3 and Deliverable 4 are unaffected.
- **Phase 4's transcription overruns its budget**: the fixture is the only hard prerequisite for
  Phase 5. If it cannot be brought green, mark Phases 4–5 `[PARTIAL]` with the transcription
  committed as far as it compiles, and close Deliverable 5 on the stated requirement alone —
  Deliverables 1–4 must not wait on E1 and must not be marked down for it.
- **A foreign change inside any regenerated file or generated block**: STOP and report after
  checking `git log`. Do not reconcile another writer's work.
