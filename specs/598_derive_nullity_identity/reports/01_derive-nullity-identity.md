# Research Report: Task #598

**Task**: 598 - Derive nullity_identity instead of carrying it as a FrameOver field
**Started**: 2026-09-16T00:00:00Z
**Completed**: 2026-09-16T00:40:00Z
**Effort**: Small-medium (about 2-3 hours; ~20 files, mostly one-line deletions plus prose)
**Dependencies**: None blocking (task 596 semantics nesting already completed; task 599 overlaps on Semantics.lean prose only)
**Sources/Inputs**: - Codebase (grep over FormalSystem/, Tests/, docs/, typst/), lean-lsp MCP (`lean_run_code` probe against the built `FormalSystem.Semantics.TaskFrame`)
**Artifacts**: - specs/598_derive_nullity_identity/reports/01_derive-nullity-identity.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary
- The derivation is verified: a standalone probe importing `FormalSystem.Semantics.TaskFrame` proves
  `nullity`, `eq_of_taskRel_zero`, and `nullity_identity` for an arbitrary `F : FrameOver D` from
  `F.serial` and `F.limit` alone, sorry-free, depending only on `propext`.
- `TaskFrame.nullity_of_serial_limit` lives in `Semantics/FrameAxioms.lean`, which is *downstream*
  of `TaskFrame.lean` (imports `PartialHistory`). It must be moved into `TaskFrame.lean` (namespace
  `TaskFrame`, next to `Serial`, before `structure FrameOver`) or the derivation must be inlined.
  Moving it keeps its fully qualified name `FormalSystem.Semantics.TaskFrame.nullity_of_serial_limit`
  unchanged, so `Extension/Admissible.lean:318` keeps compiling.
- 17 live construction sites supply the field (list below). Every one of them simply deletes the
  `nullity_identity := ...` line. No construction uses an anonymous constructor `⟨...⟩` or
  `FrameOver.mk`, so field-order changes are not an issue.
- The zero-injectivity fact is NOT free for frames whose `limit` is discharged via
  `limit_of_succOrder` / `limit_of_shift`: those helpers consume it as a hypothesis. Frames such as
  `fnFrameOver` (`fn_nullity`) therefore keep a zero-injectivity lemma as input to *Limit*; only the
  field line (and the now-unneeded reflexivity half) goes.
- Recommended: replace the field with three theorems in `namespace FrameOver` directly after the
  structure (`nullity`, `eq_of_taskRel_zero`, `nullity_identity`), keep the bundled
  `TaskFrame.nullity_identity` accessor, and optionally weaken `limit_of_succOrder`'s hypothesis to
  the one-directional `R w 0 u → u = w` (matching `limit_of_shift`), which lets
  `nullity_identity_of_permissive` and the reflexivity halves of `fn_nullity` be removed.

## Context & Scope
Researched: the `FrameOver` structure and its derived API (`FormalSystem/Semantics/TaskFrame.lean`),
the location/imports of `nullity_of_serial_limit`, every consumer and every supplier of
`nullity_identity` in the built library (`FormalSystem` and `BimodalTest` lean_libs), and prose
describing the field (Lean docstrings, `Semantics.lean`, `Semantics/README.md`, `docs/`, `typst/`).
`FormalSystem/Boneyard/**` is not imported by any built root (verified: no `import FormalSystem.Boneyard`
outside Boneyard) and is out of scope.

Constraint: zero-debt; target is the paper's `def:frame` shape (four axioms `comp`, `serial`,
`limit`, `saturation`, plus `converse` and nonempty `W`).

## Findings

### Codebase Patterns

**Import topology (load-bearing).**
- `Semantics/TaskFrame.lean` imports only Mathlib + `Semantics.TemporalOrder`.
- `Semantics/FrameAxioms.lean` imports `Semantics.PartialHistory` (hence `TaskFrame`), and declares
  `TaskFrame.nullity_of_serial_limit` at line 165 inside `namespace FormalSystem.Semantics` /
  `namespace TaskFrame`.
- `TaskFrame.lean`'s `namespace TaskFrame` block (lines 238-524) already holds `Serial` (454) and
  `Compositional` (496) with variables `{D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`,
  which is the same binder shape `nullity_of_serial_limit` needs. Move it there (it needs no
  `Nontrivial`; add an `omit` if the unused-instance linter complains). Leave a one-line pointer in
  `FrameAxioms.lean`'s docstring list rather than a duplicate declaration.

**Verified replacement API** (probe compiled; axioms: `[propext]`):
```lean
namespace FrameOver
theorem nullity (F : FrameOver D) (w : F.WorldState) : F.TaskRel w 0 w :=
  TaskFrame.nullity_of_serial_limit F.serial F.limit w

theorem eq_of_taskRel_zero (F : FrameOver D) {w u : F.WorldState} (h : F.TaskRel w 0 u) : w = u :=
  (F.limit w u fun x hx => ⟨0, by simpa using hx, h⟩).symm

theorem nullity_identity (F : FrameOver D) : ∀ w u, F.TaskRel w 0 u ↔ w = u :=
  fun _ _ => ⟨F.eq_of_taskRel_zero, fun h => h ▸ F.nullity _⟩
```
(The probe inlined `nullity_of_serial_limit`'s proof since it is not yet importable from
`TaskFrame.lean`; same term.) `nullity` currently sits at line 770 *after* `forward_comp`/`interpolates`
and is proved from the field; reorder so `nullity` precedes `nullity_identity`.

**Consumers of `F.nullity_identity` (all keep working unchanged with a theorem of identical statement):**
- `Semantics/TaskFrame.lean:771` (`FrameOver.nullity`, to be rewritten as above), `:1884-1885`
  (bundled `TaskFrame.nullity_identity := F.toFibre.nullity_identity`, keep), `:1948` (bundled `nullity`)
- `Semantics/IntNormalForm.lean:197` (`simpa using F.nullity_identity w u`)
- `Semantics/DeterministicBridge.lean:136,151,154` (`rw [F.nullity_identity] at hu hv` - rw with an
  iff theorem behaves the same as with a field projection)
- `Semantics/Extension/Extension.lean:235`
- `Semantics/IntTransfer.lean:144` (inside `FrameOver.map`'s own field proof - becomes deletable)
- `Metalogic/Algebraic/FlowFrame.lean:283` and `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:285`:
  standalone `*_limit` theorems that call `limit_of_shift ... (frame.nullity_identity ...)`. With the
  field gone this would still typecheck but becomes circular-looking (deriving limit from a theorem
  derived from limit). Replace each body with the frame's own field: `(multiFamTaskFrameGen D FamIdx).limit`
  and `(regionFrame W ι D).limit`.

**Construction sites supplying the field (delete the line in each):**

| File:line | Current discharge | Notes |
|---|---|---|
| Semantics/TaskFrame.lean:1556 `trivialFrame` | inline | delete |
| Semantics/TaskFrame.lean:1619 `staticFrame` | `Iff.rfl` | delete |
| Semantics/TaskFrame.lean:1690 `natFrame` | `nullity_identity_of_permissive` | delete; fix "All six axiom fields" comment -> five |
| Semantics/Frames/Standard.lean:77 `translationFrame` | inline 4 lines | delete; docstring "seven obligations" -> six, drop *Nullity* |
| Semantics/Frames/Standard.lean:131 `permissiveFrame` | `nullity_identity_of_permissive` | delete; fix comment |
| Semantics/IntNormalForm.lean:449 `ofStep` | 3 lines | delete; update table row line 432 and prose 24,190,212,362,367 |
| Semantics/IntTransfer.lean:142 `FrameOver.map` | 3 lines | delete; table row line 101 |
| Semantics/ShiftSet.lean:166 `fibre` | 1 line | delete; docstring "seven live fields" -> six |
| Examples/TemporalStructures.lean:82,127,229 | inline | delete; prose 121,369,454,460 |
| Metalogic/Independence/ClockFrame.lean:173 `clockFrame` | 4 lines | delete; "All seven" -> six (161) |
| Metalogic/Independence/DriftFrame.lean:228 `fzeroFrame` | `fzero_nullity` | delete line; `fzero_nullity` is then unused (`fzero_limit` does not use it) - delete theorem and its mention at line 36; "six obligations" -> five (29,37,145,222) |
| Metalogic/Independence/ForwardDeterministicFrame.lean:221 `fnFrameOver` | `fn_nullity` | delete line; KEEP `fn_nullity` (consumed by `fn_limit` via `limit_of_succOrder`), or shrink it to the injectivity half if the helper is weakened; "six" -> five (127,216) |
| Metalogic/Algebraic/FlowFrame.lean:153 `multiFamTaskFrameGen` | 6 lines | delete |
| Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:467 `zTaskFrameV2` | omega | delete |
| Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:197 `regionFrame` | 8 lines | delete |
| Metalogic/Decidability/FMP/Filtration.lean:303 `RefinedFilteredTaskFrame` | 9 lines | delete; docstring 281 "with proper nullity_identity" and list item 479 |

Frames built by delegation (`multiFamTaskFrame`, `IntPresentation.toFibre`/`toFiniteFibre`,
`FiniteModel` `toFrameOver :=`, `RealTranslationFrame` via `ShiftSet.fibre`, `flipFrame`, BX canonical
frames via `multiFamTaskFrameGen`) need no edits beyond "seven fields" prose
(`IntPresentation.lean:121`, `RealTranslationFrame.lean:128`, `Metalogic/Independence.lean:69`).

**Helper tidy-up (optional, recommended for minimality).**
`limit_of_succOrder` (TaskFrame.lean:845) takes `hnull : ∀ w u, R w 0 u ↔ w = u` but uses only `.mp`.
Weakening it to `hzero : ∀ w u, R w 0 u → u = w` (the exact shape `limit_of_shift` already uses) lets:
- `limit_of_permissive` (1264) pass a one-directional proof;
- `nullity_identity_of_permissive` (1204) be deleted (its only users are the two field lines);
- `fn_nullity` shrink to its injectivity half.
Callers of `limit_of_succOrder` (verified by grep): exactly three - `fn_limit`
(ForwardDeterministicFrame.lean:189), `limit_of_permissive` (TaskFrame.lean:1267), and `IntNormalForm.ofStep`'s
`limit` field (IntNormalForm.lean:477). Each currently passes an iff and would pass
`fun w u h => ((hnull w u).mp h).symm` or a direct proof. (`Filtration` and `TemporalStructures` go
through `limit_of_permissive`, whose own signature is unchanged.) If the implementer prefers the
smallest diff, leave the helper alone - this is ergonomics, not correctness.

### External Resources
- No Mathlib lemmas are needed; the derivation uses `abs_zero`-level simp (`by simpa using hx`
  turning `0 < x` into `|0| < x`) only.

### Recommendations
1. **Phase 1 (TaskFrame.lean core)**: move `nullity_of_serial_limit` into `TaskFrame.lean`'s
   pre-structure `namespace TaskFrame` block; delete the field and its long docstring; add the three
   theorems at the top of `namespace FrameOver` (before `forward_comp`); delete the three in-file field
   discharges and (optionally) `nullity_identity_of_permissive` + weaken `limit_of_succOrder`.
   Rewrite module docstring bullets (lines ~121-123, ~158-159, structure docstring ~555-558) to state
   that the structure carries exactly the four axioms plus `converse` and nonempty `W`, and that
   `nullity`/`nullity_identity` are derived. Remove `FrameAxioms.lean`'s duplicate declaration and
   update its prose (86, 103, 159-163). Build `FormalSystem.Semantics.TaskFrame` then `FrameAxioms`.
2. **Phase 2 (construction sites)**: delete the field line at the 14 remaining sites in the table,
   replace the two `*_limit` bodies with `frame.limit`, delete `fzero_nullity`, fix obligation counts.
3. **Phase 3 (prose)**: `Semantics.lean:226-229` ("retains it as a `nullity_identity` field for
   construction ergonomics only" -> derived theorem; also the table there names the field
   `compositionality`, actual name `comp`), `Semantics/README.md:66`, `Extension/Admissible.lean:97-111,284-285`
   (the "open design question" is now closed), `Extension/Extension.lean:97,221`,
   `DeterministicBridge.lean:67-70,126`, `IntNormalForm.lean` prose, `Tests/BimodalTest/Property/Generators.lean:32,146`,
   `docs/user-guide/architecture.md:479`, `docs/reference/API_REFERENCE.md:144,160`, and
   `typst/chapters/02-semantics.typ:150-154` + `typst/chapters/06-notes.typ:28` (remove the
   "strictly stronger" design-fact paragraph and the `CONFIRM(lean)` comment; the iff is a derived theorem).
4. **Gate**: full `lake build` (FormalSystem and BimodalTest) detached per long-builds guidance; grep
   `nullity_identity :=` must return only Boneyard hits.

A sorry-free path exists for every step; nothing requires new axioms.

## Decisions
- Keep the public name `nullity_identity` (both `FrameOver.` and bundled `TaskFrame.`) with its
  exact current statement, so no consumer changes.
- Add `FrameOver.eq_of_taskRel_zero` as the named injectivity half (small, reusable).
- Move rather than duplicate `nullity_of_serial_limit`; the name is preserved.
- Boneyard is not touched (not built).

## Risks & Mitigations
- **Unused-instance linter on the moved theorem** (`Nontrivial` unused): add `omit [Nontrivial D] in`
  as the surrounding block already does for other helpers.
- **`rw [F.nullity_identity] at ...` in DeterministicBridge**: rewriting with a theorem whose
  statement starts `∀ w u` behaves identically to the projection; low risk, verify on build.
- **Concurrent task 599** (history unification) may edit `Semantics.lean` prose; keep 598's prose
  edits confined to the frame table paragraph to minimize conflicts. Task 596 (nesting) is already
  completed and did not move `TaskFrame.lean`.
- **`@[reducible]` frames** (`fnFrameOver`, `fzeroFrame`): removing a Prop field does not affect
  reducibility of `WorldState`.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `F.TaskRel w 0 w` from serial+limit | `obtain` + `simpa using hx` + `▸` | success | `F.serial w 0 le_rfl`, `F.limit` |
| `F.TaskRel w 0 u → w = u` | term, `simpa using hx` | success | `F.limit` at witness `y := 0` |
| `F.TaskRel w 0 u ↔ w = u` | term | success | the two above; axioms `[propext]` |

## Context Extension Recommendations
- **Topic**: FrameOver field inventory
- **Gap**: Many docstrings hard-code obligation counts ("six"/"seven" `FrameOver` obligations), which
  drift whenever a field is added or removed.
- **Recommendation**: prefer naming fields over counting them in future docstrings.

## Appendix
- Searches: `grep -rn "nullity_identity\|nullity_of_serial_limit"`, `grep -rn "saturation :="` (to
  enumerate all construction sites), `grep -rn "fn_nullity\|fzero_nullity\|nullity_identity_of_permissive"`,
  import checks for `FrameAxioms.lean` and Boneyard.
- Probe: `lean_run_code` with `import FormalSystem.Semantics.TaskFrame`, theorems
  `Probe.nullity`, `Probe.eq_of_taskRel_zero`, `Probe.nullity_identity` (compiled, `#print axioms` = `[propext]`).
