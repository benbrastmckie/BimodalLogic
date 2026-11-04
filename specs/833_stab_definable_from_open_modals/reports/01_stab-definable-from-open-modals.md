# Research Report: Task #833

**Task**: 833 - `⊡` is definable from the manuscript's open-future and open-past modals
**Started**: 2026-11-04T00:00:00Z
**Completed**: 2026-11-04T00:00:00Z
**Effort**: Small — transcription of a compiled probe plus three documentation surfaces
**Dependencies**: None declared. Shared-file serialization against 761 (`[implementing]`) and 763 (`[not_started]`) on `docs/theorem-index.md`
**Sources/Inputs**:
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/05_stab-definable-from-open-modals.lean` (recompiled, exit 0)
- `FormalSystem/OpenLanguage/{OpenTruth,OpenValidity,OpenClasses}.lean`, `FormalSystem/OpenLanguage/README.md`
- `FormalSystem/PlusLanguage/PlusPasting.lean`, `FormalSystem/Semantics/{ValidityLayer,TaskFrame}.lean`
- `docs/theorem-index.md`, `scripts/check-module-invariants.sh`, `scripts/check-metalogic-cycles.sh`
- `specs/state.json` (`file_scope` contention)
**Artifacts**:
- `specs/833_stab_definable_from_open_modals/reports/01_stab-definable-from-open-modals.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The probe is still live and the axiom budget is confirmed.** Probe 05 recompiles against the
  current oleans at exit 0 with no warnings; the five printed sets match the dispatch's recorded
  values exactly. The sixth declaration, `openValid_stab_imp_ofut_opast`, which the probe does
  **not** print, measures `[propext]` — so the `→` half is choice- and `Quot.sound`-free at both
  the pointwise and the `OpenValid` level. Nothing in the transcription is a proof-search problem.
- **The one open design choice in the dispatch is closed by layering, not judgment.**
  `OpenReversal.lean` imports `OpenValidity.lean`, which imports `OpenTruth.lean`. Routing
  `stab_iff_opast_ofut` through `openValid_reflectTime` would therefore be an import cycle at both
  modules the dispatch names. The probe's direct proof is the only available route, and the
  docstring must not promise the reversal route.
- **A hard gate requirement is absent from the dispatch's documentation obligations.** C15's
  *second* assertion requires every `docs/theorem-index.md` row's named declaration to carry a
  `Paper:` line in its own `/--` doc comment — `Paper: — (reason)` for a `—` label. The sibling
  ordering theorems carry none (they have no ledger rows). All six new declarations need one, or
  C15 fails with "doc comment carries no `Paper:` line".
- **The ledger's axiom-column vocabulary has no `p` or `pq` token.** The documented convention is
  that `pcq` abbreviates exactly `[propext, Classical.choice, Quot.sound]` and *anything else is
  written out literally*. The correct cells are literal `[propext]` and `[propext, Quot.sound]`,
  with no `pinned:` token (C2/C14 pinning is out of scope per the dispatch; 87 existing rows are
  unpinned precedent).
- **Both verification gates must be read per-check, not by exit code, and one dispatch note is
  stale.** `check-metalogic-cycles.sh` now exits **0** (the task-828 condition is resolved);
  `check-module-invariants.sh` exits **1** at baseline for a *different*, unmentioned pre-existing
  reason (C16 `unusedArguments` in `LadderChain.lean`, 761/836 territory). INV, both C15
  assertions and C2 all PASS at baseline.
- **Recommended approach**: straight transcription, zero new imports, zero new files, house-style
  `OpenValid.of_forall_regular` spelling in `OpenValidity.lean`, and **omit** the optional
  `OpenClasses.lean` corollary. A sorry-free, choice-free path is fully established.

## Context & Scope

Research for a transcription task: port six already-compiled declarations from a live probe into
`FormalSystem/OpenLanguage/`, and land the three documentation obligations (component README,
generated inventory block, repository theorem ledger). The research question is not *how to prove
it* — that is settled — but **what the landing sites, the gates, and the documentation
conventions actually require**, so that the implement phase does not discover a convention at
verification time.

Constraints honored: no proof system, no axiom, no completeness claim, no new file, no gap-closure
language, no claim that `▷` is L⁺-undefinable, and no weakening of any probe statement.

## Findings

### Codebase Patterns

**Landing site 1 — `FormalSystem/OpenLanguage/OpenTruth.lean` (288 lines).** The ordering block is
the last section, `/-! ## The strength ordering ... -/` at line 270, holding `stab_of_box`,
`ofut_of_stab`, `opast_of_stab`. The file already carries `variable {F : TaskFrame}` and
`open FormalSystem.PlusLanguage` plus `open FormalSystem.OpenLanguage.OpenFormula`, so the
probe's `[F.IsRegular]` binders and its `.stab`/`.ofut`/`.opast` dot-notation spellings transcribe
verbatim. Sibling style uses `(.box φ)` / `(.stab φ)`, which the probe already matches.

**Dependency availability — no new import is needed anywhere.** `paste`, `paste_agreeUpTo` and
`paste_agreeFrom` are declared in `FormalSystem/PlusLanguage/PlusPasting.lean` (lines 136, 271,
259). `OpenClasses.lean` imports `PlusPasting`, and `OpenTruth.lean` imports `OpenClasses`, so all
three resolve under the existing `open FormalSystem.PlusLanguage`. This is confirmed by the
existing `paste_mem_openFutureClass_inter_openPastClass` in `OpenClasses.lean`, which already uses
them.

**Landing site 2 — `FormalSystem/OpenLanguage/OpenValidity.lean` (229 lines).** The ordering block
is the last section (line 213). All three siblings share one spelling:

```lean
theorem openValid_stab_of_box (φ : OpenFormula) : OpenValid (imp (box φ) (stab φ)) :=
  OpenValid.of_forall_regular fun _ _ M τ t h => stab_of_box M τ t φ h
```

`OpenValid.of_forall_regular` delegates to `GenericValid.of_forall_regular`
(`FormalSystem/Semantics/ValidityLayer.lean:240`), whose body is `fun F _ M τ x => h F M τ x`:
the adapter is where `FrameClass.Base.Sat F` is consumed and `[F.IsRegular]` is registered. The
dispatch's raw-`intro` route (with a `_hF` binder) is the probe's spelling and also works, but the
adapter route matches the sibling block exactly and makes the unused-binder question moot.

I compiled both spellings side by side. They are axiom-identical:

| Spelling | `openValid_stab_imp_ofut_opast` | `openValid_ofut_opast_imp_stab` |
|---|---|---|
| probe raw lambda `fun _ _ M τ t => …` | `[propext]` | `[propext, Quot.sound]` |
| `OpenValid.of_forall_regular fun _ _ M τ t h => …` | `[propext]` | `[propext, Quot.sound]` |

**Landing site 3 (optional) — `FormalSystem/OpenLanguage/OpenClasses.lean` (170 lines).** Its final
section already carries the exact heading the dispatch names,
`/-! ## ⟨τ⟩_x is the product of the open pasts and the open futures -/`, holding
`paste_mem_openFutureClass_inter_openPastClass`.

**The mirror route is structurally unavailable.** `OpenReversal.lean` imports
`FormalSystem.OpenLanguage.OpenValidity`, which imports `FormalSystem.OpenLanguage.OpenTruth`.
Routing `stab_iff_opast_ofut` through `openValid_reflectTime` from either named module would be an
import cycle. Independently, `openValid_reflectTime` is a validity-level theorem and
`stab_iff_opast_ofut` is pointwise, so it could not supply the pointwise form in any case. The
probe's direct `constructor` proof is the route, and the docstring must say so without implying
the reversal alternative exists here.

**Name collisions: none.** All six identifiers — `stab_to_ofut_opast`, `ofut_opast_to_stab`,
`stab_iff_ofut_opast`, `stab_iff_opast_ofut`, `openValid_stab_imp_ofut_opast`,
`openValid_ofut_opast_imp_stab` — have zero occurrences across `FormalSystem/`, `Tests/` and
`docs/`.

**No `LANGUAGE_FILE_LAYERS` row is needed**, because no new file is added.

### External Resources

No Mathlib search was required: this is a transcription of an already-compiled proof against
repository-local declarations. `lean_local_search` and the rate-limited search tools were
therefore not used, and no rate limits were hit. Evidence tier for every claim below is a **live
compile against the repository's own oleans** (bare `lean` with `LEAN_PATH` set, no `lake`
process) plus the guarded `lake` build — a strictly stronger tier than LSP index lookup.

The one Mathlib-facing detail is in the optional corollary: `Set.mem_biUnion` and
`Set.mem_iUnion₂` are the right entry points for the `⋃ σ ∈ openFutureClass τ x, openPastClass σ x`
form, and both resolved on first use.

### Recommendations

**R1 — Transcribe the probe verbatim into `OpenTruth.lean`**, appended to the existing ordering
block under its own `/-! ## ... -/` heading: `stab_to_ofut_opast` (no frame axiom),
`ofut_opast_to_stab` (`[F.IsRegular]`, one `paste`), then `stab_iff_ofut_opast` and
`stab_iff_opast_ofut`. Do not re-derive; do not add a hypothesis; do not route the `←` half
through anything other than `paste`, which is what keeps it choice-free.

**R2 — Use the sibling spelling in `OpenValidity.lean`**: `OpenValid.of_forall_regular fun _ _ M τ
t h => …`, with the formula written `imp (stab φ) (ofut (opast φ))` in the file's `open
OpenFormula` style. Axiom-identical to the probe, and it sidesteps the `_hF` unused-binder
question entirely.

**R3 — Give every one of the six declarations a `Paper: — (reason)` line in its `/--` doc
comment.** This is a C15 hard requirement for any declaration with a ledger row, and the dispatch's
documentation obligations omit it. Exemplar, `hnOpen_openValid` in `OpenOckhamist.lean`:

```
Paper: — (formalization-native; the manuscript gives `▷` a truth clause and supplies no logic
for the restricted modals) -/
```

The mechanics (`scripts/check-module-invariants.sh`, C15 second assertion): the checker finds the
declaration, walks back over `@[...]` attribute lines to the preceding `-/`, back to the opening
`/--`, and requires `^\s*Paper: (.+)$` inside that block. For a `—` label the value must *start
with* `— (`. The reason clause here is that the manuscript sets the restricted modals aside and
states no such equation — the same formalization-native framing the sibling rows use.

**R4 — Write the ledger's Axioms cells literally, with no `pinned:` token.** Measured vocabulary
across `docs/theorem-index.md`: 132 `pcq pinned:C14`, 87 bare `pcq`, 41 `pcq pinned:C2`, 18 bare
`propext`, 1 `[propext] pinned:C14`, 2 `[propext, Quot.sound] pinned:C14`. No `p` and no `pq`
token exists anywhere in the file, and the header documents only `pcq` as an abbreviation with
"anything else is written out literally". So: `[propext]` for the two `→`-half rows and
`[propext, Quot.sound]` for the other four. Frame class `Base` for every row with an `OpenValid`
or `[F.IsRegular]` statement; Paper label `—`.

**R5 — Edit only the Description cells of the README's generated inventory block, never the Lines
cells.** The generator's `render_block` carries each existing row's Description cell through
verbatim (`descriptions[key]`, defaulting to `<!-- TODO: add description -->` only for a row it
has never seen) and regenerates the row set and the line counts. The Description cells are
therefore hand-maintained content living inside a generated block; `--emit-inventory` will refresh
counts but will not invent new descriptions. Procedure: hand-edit the `OpenTruth.lean` and
`OpenValidity.lean` Description cells to name the new declarations, then
`bash scripts/check-module-invariants.sh --emit-inventory` to refresh counts, then
`--emit-inventory --check` for byte-stability. Hand-editing a Lines cell is exactly the drift INV
exists to catch.

**R6 — Read "add the new names to the `## Main Results` list" as three surfaces.**
`FormalSystem/OpenLanguage/README.md` has **no** `## Main Results` section; the `## Main Results`
lists live in the module docstrings (`OpenTruth.lean` line 32, `OpenValidity.lean` line 29). The
README's equivalent surface is the per-file Description cells of R5. Recommend updating all three:
both module docstring `## Main Results` lists, and both README Description cells. The README's
paper-label correspondence table gets the new row as the dispatch specifies, extending the
`app:gluing` (two histories) row and labelled **formalization-native** like its siblings. No new
paper anchor is introduced, so C15's first assertion (93 anchors, PASS) is unaffected.

**R7 — Omit the optional `OpenClasses.lean` corollary.** It is cheap and it compiles — I verified
the set-level form end to end:

```lean
theorem stabClass_eq_iUnion [F.IsRegular] (τ : WorldHistory F) (x : F.Duration) :
    stabClass τ x = ⋃ σ ∈ openFutureClass τ x, openPastClass σ x
```

eight lines, axioms `[propext, Quot.sound]`. But it has no consumer, and the dispatch's own rule is
that a theorem with no consumer is not worth an INV row. Recommend omitting and recording that the
statement is known-provable, so a later task that needs it does not re-derive it. **Gotcha if it is
landed anyway**: the `→` direction must use `paste_agreeFrom τ ρ x h` directly. Using
`(paste_mem_openFutureClass_inter_openPastClass τ ρ x h).2` type-mismatches — that component is the
symm'd `paste τ ρ x h ∈ openPastClass ρ x`, whereas `Set.mem_biUnion` wants
`ρ ∈ openPastClass (paste τ ρ x h) x`. I hit this and fixed it; the note saves the rediscovery.

**R8 — There is no sorry-free-path risk here.** The proof exists, compiles, and is choice-free. No
approach in this report requires `sorry`, a new axiom, or a deferral.

## Decisions

- **D1. Transcribe, do not re-derive.** The probe is the source of record; its statements are
  landed unweakened. Confirmed live by recompilation rather than trusted from the dispatch.
- **D2. The mirror is proved directly, not through `openValid_reflectTime`.** Not a style
  preference — the reversal route is an import cycle from both named modules. No docstring sentence
  may imply the reversal route was available and declined.
- **D3. `OpenValidity.lean` uses `OpenValid.of_forall_regular`**, matching all three siblings in the
  block, after verifying axiom-identity with the probe's raw-lambda spelling.
- **D4. Axiom cells are literal (`[propext]`, `[propext, Quot.sound]`) and unpinned.** Pinning in
  `scripts/check-module-invariants.sh` stays out of scope per the dispatch, so no `pinned:` token is
  written; 87 existing unpinned rows are the precedent.
- **D5. The optional `OpenClasses.lean` corollary is omitted**, with its verified statement and
  proof gotcha recorded here instead.
- **D6. Verification is asserted per-check, not by script exit code**, because both gate scripts
  carry pre-existing conditions unrelated to this task (see Risks).

## Risks & Mitigations

**Risk 1 — The dispatch's `check-metalogic-cycles.sh` note is stale, which could mask a real
regression.** The dispatch says the script "currently exits 1" for the task-828 eighth-upward-edge
reason. Re-measured at baseline it exits **0** and prints `PASS upward import set is exactly the
recorded 8 line(s)`; the allowlist and docs now record eight. *Mitigation*: treat exit 0 as the
required baseline. Any nonzero exit after this task is a **new** failure, not the pre-existing one —
inverting the dispatch's guidance, which would otherwise wave through a genuine new edge. (This
task adds no import at all, so an import-graph regression would be surprising.)

**Risk 2 — `check-module-invariants.sh` exits 1 at baseline for a reason the dispatch does not
mention.** The failure is C16: the `unusedArguments` linter on
`FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_shift_of_hasForwardSlack`
(`FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`), beyond
`scripts/nolints.json`'s baseline. That is 761/836 territory — 761 declares both
`LadderChain`-adjacent files and `scripts/nolints.json` in its `file_scope` — and is not this
task's to fix. *Mitigation*: assert the per-check lines, which all PASS at baseline:

| Check | Baseline |
|---|---|
| `INV` every generated inventory block is current | PASS |
| `C2` all fifty pinned axiom sets match baseline | PASS |
| `C15` all 93 paper-anchor citations resolve | PASS |
| `C15` all 313 theorem-index rows carry their anchor at the declaration | PASS |
| `C16` env_linter beyond nolints baseline | **FAIL (pre-existing, 761/836)** |

Require the four PASS lines to stay PASS and the C16 finding list to be byte-identical — one
finding, `mem_cellAt_of_shift_of_hasForwardSlack`. Do **not** run `lake exe runLinter --update`.

**Risk 3 — C15's row-anchor assertion fails late.** Landing the ledger rows without the
`Paper: — (reason)` docstring lines produces six C15 failures at the end of the phase, after the
Lean work looks finished. *Mitigation*: write the `Paper:` lines in the same edit as the
declarations (R3), not as a documentation afterthought, and run
`bash scripts/check-module-invariants.sh 2>&1 | grep C15` as soon as the ledger rows land.

**Risk 4 — `docs/theorem-index.md` contention with the Stage 1 critical path.** 761
(`[implementing]`) and 763 (`[not_started]`) both declare it. *Mitigation*: as the dispatch
instructs, run this task in a cycle of its own or after 761/763's current cycle — never
concurrently, and never by working around the overlap gate. The ledger edit here is six appended
rows in the `### L^▷` section (line 504), which is far from 761/763's `RaySummary` rows, so a
textual conflict is unlikely but the gate ordering still governs.

**Risk 5 — Unguarded `lake` collision.** The build guard is opt-in and does not intercept a bare
`lake`. *Mitigation*: route every build through
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- …`; baseline scoped build
`-- build FormalSystem.OpenLanguage` is green (`GUARD_EXIT=0`, 1210 jobs). Treat an unexplained
failure during concurrent work as possible guard bypass before assuming a regression here.

**Risk 6 — Scope creep into gap-closure language.** The probe's own module docstring is explicit
that the result closes nothing. *Mitigation*: the landed docstrings state the product structure of
`⟨τ⟩_x` and nothing more. No sentence may suggest `plus_incomplete_base` is affected, that `blc`
becomes a theorem, that an `LC_n`-style schema is no longer required, or that `▷` is L⁺-undefinable.

## Tactic Survey Results

A tactic survey is only marginally applicable — the proofs are given and compiled — but two
candidate spellings and one optional statement were compiled to settle open questions rather than
argued. Measurements are from a bare-`lean` compile against the repository's oleans, exit 0, no
warnings.

| Goal | Tactic / route | Result | Premises/Config |
|------|------|--------|-----------------|
| `⊡φ → ▷◁φ` pointwise | `intro σ hup ρ hfrom; exact h ρ ((hup t le_rfl).trans (hfrom t le_rfl))` | success | no frame axiom; `[propext]` |
| `▷◁φ → ⊡φ` pointwise | `intro ρ hs; exact h (paste …) … ρ (paste_agreeFrom …)` | success | `[F.IsRegular]`, `paste_agreeUpTo`, `paste_agreeFrom`; `[propext, Quot.sound]` |
| `⊡φ ↔ ▷◁φ` | `⟨stab_to_ofut_opast …, ofut_opast_to_stab …⟩` | success | `[propext, Quot.sound]` |
| `⊡φ ↔ ◁▷φ` | `constructor` + direct paste with the two histories exchanged | success | `[propext, Quot.sound]` |
| `⊡φ ↔ ◁▷φ` | route via `openValid_reflectTime` | **unavailable** | import cycle: `OpenReversal → OpenValidity → OpenTruth` |
| `OpenValid (⊡φ → ▷◁φ)` | probe raw lambda `fun _ _ M τ t => …` | success | `[propext]` |
| `OpenValid (⊡φ → ▷◁φ)` | `OpenValid.of_forall_regular fun _ _ M τ t h => …` | success | `[propext]` — house style, axiom-identical |
| `OpenValid (▷◁φ → ⊡φ)` | `OpenValid.of_forall_regular fun _ _ M τ t h => …` | success | `[propext, Quot.sound]` — house style, axiom-identical |
| `stabClass τ x = ⋃ σ ∈ openFutureClass τ x, openPastClass σ x` | `ext` + `Set.mem_biUnion` / `Set.mem_iUnion₂` | success | `[propext, Quot.sound]`; `paste_agreeFrom` directly, **not** the inter lemma's `.2` |

No `simp`/`aesop`/`omega` was used or needed; `lean_hammer_premise` was not invoked, since no goal
was open.

## Context Extension Recommendations

- **Topic**: The C15 round-trip obligation that a `docs/theorem-index.md` row imposes on the
  declaration site.
  **Gap**: No context file states that adding a ledger row requires a `Paper:` line in the
  declaration's own doc comment. The requirement lives only in a comment block inside
  `scripts/check-module-invariants.sh`, and the dispatch's documentation obligations — otherwise
  thorough — omit it. Any future task that adds a ledger row will rediscover this at gate time.
  **Recommendation**: add a short section to the Lean context (e.g. a
  `context/project/lean4/operations/theorem-index-rows.md`) stating the three coupled surfaces of a
  ledger row — the row itself, the `Paper:` line at the declaration, and the Axioms-cell vocabulary
  (`pcq` abbreviation versus a literal set, and when a `pinned:` token is warranted).

- **Topic**: The generated-inventory block's hand-maintained Description column.
  **Gap**: "Do not hand-edit the generated block" is the right instinct but is imprecise: the
  generator preserves Description cells verbatim and regenerates only row membership and line
  counts. An agent following the blanket prohibition literally cannot add a declaration name to a
  README inventory at all.
  **Recommendation**: record the split — Lines cells are generated, Description cells are
  hand-maintained *inside* the generated block — wherever `check-module-invariants.sh
  --emit-inventory` is documented.

## Appendix

### Commands run

```bash
# probe recompile against the repository's own oleans (no lake process)
LP=.lake/build/lib/lean; for d in .lake/packages/*/.lake/build/lib/lean; do LP="$LP:$d"; done
LEAN_PATH="$LP" ~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/bin/lean \
  specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/05_stab-definable-from-open-modals.lean
# -> exit 0, no warnings; five axiom lines as recorded in the dispatch

# variant compile: the sixth declaration's axioms, both OpenValid spellings, the optional corollary
# -> exit 0, no warnings; measurements in Tactic Survey Results

bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage
# -> GUARD_EXIT=0, "Build completed successfully (1210 jobs)"

bash scripts/check-metalogic-cycles.sh   # -> exit 0 (all PASS)
bash scripts/check-module-invariants.sh  # -> exit 1, C16 only (pre-existing, LadderChain.lean)
```

### Reference points consulted

- `FormalSystem/OpenLanguage/OpenTruth.lean` — ordering block at `/-! ## The strength ordering`;
  `## Main Results` list in the module docstring
- `FormalSystem/OpenLanguage/OpenValidity.lean` — ordering block; `OpenValid`,
  `OpenValid.of_forall_regular`
- `FormalSystem/Semantics/ValidityLayer.lean` — `GenericValid.of_forall_regular`, where
  `FrameClass.Base.Sat` is consumed and `[F.IsRegular]` registered
- `FormalSystem/PlusLanguage/PlusPasting.lean` — `paste`, `paste_agreeFrom`, `paste_agreeUpTo`
- `FormalSystem/OpenLanguage/OpenClasses.lean` — the product-structure heading and
  `paste_mem_openFutureClass_inter_openPastClass`
- `FormalSystem/OpenLanguage/OpenOckhamist.lean` — the `Paper: — (…)` docstring exemplars
- `docs/theorem-index.md` — "How to read a row"; the `### L^▷` section
- `scripts/check-module-invariants.sh` — `render_block` / `audit_hand_maintained`; the C15 second
  assertion; the check catalogue
