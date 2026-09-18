# Research Report: Close the world-history reach-through residue

- **Task**: 615 - Close world history reach-through residue
- **Started**: 2026-09-17T00:33:56Z
- **Completed**: 2026-09-17T01:12:00Z
- **Effort**: ~40 minutes
- **Dependencies**: None (the three predecessor tasks in this topic are archived and complete)
- **Sources/Inputs**:
  - Codebase: `FormalSystem/Semantics/PartialHistory.lean`, `FormalSystem/Semantics/Extension/{Extension,PeriodicExtension}.lean`, `FormalSystem/Semantics/{IntNormalForm,IntTransfer,ShiftSet}.lean`, `FormalSystem/Semantics/PlusLanguage/{PlusPasting,PlusDeterminism}.lean`, `FormalSystem/Metalogic/Independence/*`, `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`, `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`, `FormalSystem/Metalogic/Decidability/{Verified/Bridge/RegionFrame,BiLasso/Agreement}.lean`
  - Prior report: `specs/archive/569_retarget_semantics_to_possible_world_index/reports/01_possible-world-index-retarget.md`
  - Prior probe: `specs/archive/569_retarget_semantics_to_possible_world_index/probes/01_possible-world-spike.lean`
  - Machine checks: `lake-build-guard.sh` full build; `lake env lean` on a new probe
  - Lean MCP (`lean-lsp`): unavailable this session, see Risks
- **Artifacts**:
  - `specs/615_close_world_history_reach_through_residue/reports/01_close-reach-through-residue.md`
  - `specs/615_close_world_history_reach_through_residue/probes/01_respects-task-residue.lean`
- **Standards**: report-format.md, subagent-return.md

## Project Context

- **Upstream Dependencies**: `FormalSystem/Semantics/PartialHistory.lean` (defines `PartialHistory`, `WorldHistory`, `state`, `states_eq_state`, `ext_state`, `timeShift`) — every site in this task either consumes or extends its API.
- **Downstream Dependents**: the 13 files carrying the 22 hand-spelled `respects_task` reach-throughs, plus `IntNormalForm.lean` and `Extension/Extension.lean`.
- **Alternative Paths**: none. There is exactly one accessor gap and it has exactly one closure.
- **Potential Extensions**: the flat-structure conversion and the `PossibleWorld` rename, both explicitly out of scope for this task.

## Executive Summary

- **The inventory in the task description is exactly right against the current tree, re-measured today.** `\.val\.(states|domain|respects_task|nonempty_domain|timeShift)` over `FormalSystem/` + `Tests/` (Boneyard excluded) returns **28 sites**: 22 hand-spelled `respects_task`, 4 definitional sites inside `PartialHistory.lean` itself, and the 2 named defects. The layer-crossing `.val` inventory is **8 sites**; research found a **9th, `.property`-direction** layer crossing the prior audit missed (`PeriodicExtension.lean:429`).
- **The whole of required work (1) and (2) is machine-checked.** A probe at `specs/615_close_world_history_reach_through_residue/probes/01_respects-task-residue.lean` elaborates with **zero errors**: the `WorldHistory.respects_task` lemma, the `state`-level restatement of `occurrence` with its proof term unchanged, the `state`-level restatement of `WorldHistory.path` shown `rfl`-equal to the current body, and two representative call-site rewrites.
- **The sweep is not purely textual: four `rw [WorldHistory.states_eq_state]` lines must be deleted or trimmed**, because after the rewrite their hypotheses are already in `state` normal form and the rewrite will fail to find its pattern. Exact lines: `ForwardDeterministicFrame.lean:271` (trim to `rw [h] at hτr`), `FlowFrame.lean:377`, `FlowFrame.lean:382`, `RegionFrame.lean:338` (delete). This is the only non-mechanical part of the 22-site sweep.
- **Baseline is green and the gate already passes.** `lake build FormalSystem` exits 0 (2659 jobs). `#print axioms` on `validZTime_iff_validInt` and `truthAt_map` returns exactly `[propext, Classical.choice, Quot.sound]` today, so the VERIFY clause is a no-regression gate, not a new obligation.
- **Triage of the remaining 6 reach-throughs and 9 layer crossings: every one is disposed of as KEEP, except the 2 named defects, which are FIX.** No site in either group is dead, redundant, or deferrable. Two pieces of *adjacent* API are dead (`CoeOut`, `WorldHistory.ext`), and the honest disposition of both is "leave to the flat-structure task", with one narrow exception argued below.
- **No sorry-free risk anywhere.** Every change is a definitional-equality restatement or a drop-in term substitution; nothing in this task can require a `sorry`, an axiom, or a proof search.

## Context & Scope

Task 615 closes the residue left by an already-executed seven-phase retarget. Scope, verbatim from the dispatch: add `WorldHistory.respects_task` and rewrite its 22 consumers; fix two named defects; triage the remaining 6 reach-throughs and 8 layer crossings. Out of scope by explicit decision: the `PossibleWorld` rename and the subtype-to-flat-structure conversion.

This research re-measured every count against the live tree rather than inheriting it, on the basis that the counts are the whole substance of the task. It also machine-checked the proposed changes in a standalone probe before recommending them, so that the plan does not rest on a claim of definitional equality that was never elaborated.

Constraints observed: no production file was modified; the probe lives under `specs/`; `lean_diagnostic_messages` and `lean_file_outline` were not called (blocked); the `lean-lsp` MCP server was unavailable, so all verification went through `lake` directly.

## Findings

### Codebase Patterns

**Re-measured inventory — the 28 reach-through sites.** Grep pattern `\.val\.(states|domain|respects_task|nonempty_domain|timeShift)`, `FormalSystem/` + `Tests/`, Boneyard excluded:

| Group | Count | Disposition |
|---|---:|---|
| `τ.val.respects_task s t (τ.property s) (τ.property t)` spelled by hand | **22** | REWRITE to `τ.respects_task s t` |
| definitional sites inside `PartialHistory.lean` (`state` body `:423`; `states_eq_state` statement and proof `:428,:429`; `timeShift` body `:471`) | **4** | KEEP — these *are* the accessor API; they are the only places the subtype may legitimately be opened |
| `IntNormalForm.lean:282`, `WorldHistory.path` body | **1** | FIX to `τ.state` |
| `Extension/Extension.lean:219`, `occurrence`'s statement | **1** | FIX to `τ.state x = w` |

The 6 non-22 sites are exactly the 4 definitional plus the 2 defects; required work items (2) and (3) therefore overlap by design, and item (3)'s triage of the 6 resolves as "4 KEEP, 2 FIX-by-(2)".

**The 22, by file** (`.val.respects_task` line numbers as of this commit):

| File | Lines | Extra edit needed |
|---|---|---|
| `Metalogic/Independence/PastingIndependence.lean` | 156 | — |
| `Metalogic/Independence/ForwardDeterministicFrame.lean` | 269, 270 | **:271** `rw [WorldHistory.states_eq_state, h] at hτr` → `rw [h] at hτr` |
| `Metalogic/Independence/DriftHistories.lean` | 137 | — |
| `Metalogic/Independence/LoopingDuration.lean` | 83 | — |
| `Metalogic/Independence/RealTranslationFrame.lean` | 156, 163 | — |
| `Metalogic/Independence/CoNotPriorU.lean` | 371–372 | continuation line 372 folds away |
| `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 648, 838 | — |
| `Metalogic/Algebraic/FlowFrame.lean` | 376, 381 | **delete :377 and :382** (`rw [states_eq_state, states_eq_state] at h₁ h₂`) |
| `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` | 336 | **delete :338** (`rw [states_eq_state, states_eq_state] at h₂`) |
| `Semantics/PlusLanguage/PlusPasting.lean` | 85, 86, 101, 104 | the `_ _` placeholder form; the two `_`s simply disappear |
| `Semantics/PlusLanguage/PlusDeterminism.lean` | 108, 110 | — |
| `Semantics/IntNormalForm.lean` | 328 | — |
| `Semantics/ShiftSet.lean` | 244, 335 | — |

Every one of the 22 is a term-position drop-in: the replacement has type `F.TaskRel (τ.state s) (t - s) (τ.state t)`, the original has type `F.TaskRel (τ.val.states s (τ.property s)) (t - s) (τ.val.states t (τ.property t))`, and these are definitionally equal because `WorldHistory.state` (`PartialHistory.lean:422-423`) is literally `τ.val.states t (τ.property t)`. Several sites (`ReynoldsBridge.lean:836-838`, `PlusDeterminism.lean:107-110`, `ShiftSet.lean:334-335`) already carry an explicit `state`-level type ascription on the enclosing `have`, which is direct evidence that the defeq holds today.

**After the sweep, `WorldHistory.states_eq_state` drops to zero explicit call sites.** Its four current non-definitional uses are the four `rw` lines tabulated above, all of which the sweep removes. It stays a `@[simp]` rfl-lemma and may still fire implicitly inside `simp` calls, so it must not be deleted on the strength of the explicit count alone.

**Re-measured layer crossings — 8 `.val` sites, plus a 9th in the `.property` direction.** These hand a world history to a `PartialHistory`-layer definition, and are where the subtype relationship does real work:

| Site | Crossing | Disposition |
|---|---|---|
| `Semantics/Extension/Extension.lean:172` | `Extends σ.val τ` — the Extension Theorem's conclusion | KEEP |
| `Semantics/Extension/PeriodicExtension.lean:159` | `PartialHistory.Extends σ.val τ` | KEEP |
| `Semantics/Extension/PeriodicExtension.lean:403` | `PartialHistory.Extends σ.val τ` | KEEP |
| `Metalogic/Decidability/BiLasso/Agreement.lean:114` | `PartialHistory.Extends L.toWorldHistory.val τ` | KEEP |
| `Metalogic/Decidability/BiLasso/Agreement.lean:137` | `PartialHistory.Extends L.toWorldHistory.val τ` | KEEP |
| `Semantics/IntTransfer.lean:205` | `PartialHistory.map τ.val e`, producer direction (`⟨…, fun n => τ.property _⟩`) | KEEP |
| `Semantics/IntTransfer.lean:235` | `PartialHistory.comap e σ'.val`, producer direction | KEEP |
| `Semantics/PartialHistory.lean:433` | `τ.val = σ.val`, the body of `WorldHistory.ext` | KEEP (see dead-API finding) |
| **`Semantics/Extension/PeriodicExtension.lean:429`** *(new — not in the prior audit)* | `fun t _ => σ.property t`, the domain-inclusion half of an `Extends` record, built straight from totality | KEEP |

`Extension.lean:174` (`exact ⟨⟨μ, htot⟩, le_def.mp hle⟩`) is the producer-direction counterpart the prior report noted; it contains no `.val` token and is unaffected.

All nine are load-bearing. `PartialHistory.Extends` is a `PartialHistory`-layer relation, and the Extension Theorem is untouchable by this task's scope; there is no `WorldHistory`-level restatement available that does not amount to the flat-structure refactor. Item (3)'s triage of the layer crossings therefore resolves uniformly as KEEP, with one substantive observation attached (next finding).

**Two pieces of adjacent API are dead, re-confirmed today.**
- `CoeOut (WorldHistory F) (PartialHistory F)` (`PartialHistory.lean:413`) has **zero firing sites**: every one of the nine crossings above is written with an explicit `.val` or `.property`, and there is no `↑τ` or `(τ : PartialHistory F)` ascription of a world history anywhere in the tree. The instance that exists to make the crossings invisible never makes one invisible.
- `WorldHistory.ext` (`:433`, `@[ext]`) has **zero call sites**. The extensionality principle actually used is `ext_state`, now at **21** sites (up from 19 at the prior audit).

**Naming is unobstructed.** `namespace WorldHistory` is opened in exactly one file (`PartialHistory.lean:408`), and nothing in the tree does `open … WorldHistory`. A new `WorldHistory.respects_task` therefore cannot collide with the `PartialHistory.respects_task` structure field at any call site, and dot-notation on `τ : WorldHistory F` resolves to it directly (`WorldHistory` is a `def`, so `WorldHistory.respects_task` is found before any unfolding to `Subtype`).

**Baseline.** `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` → exit 0, "Build completed successfully (2659 jobs)". No live `sorry` in non-Boneyard `FormalSystem/`.

### External Resources

No literature source is referenced by this task, and none is needed: the two out-of-scope items are the only ones with a paper-vocabulary dependency, and the dispatch already records the relevant citations (`possible_worlds.tex:1046`, `:1050`). The Literature Extraction Protocol does not apply — no proof is being transcribed here, only an accessor being named.

Mathlib was not searched. The lemma is a projection of a project-local structure field through a project-local subtype; there is no Mathlib declaration that could supply it, and `leansearch`/`loogle` were not consulted because the target is not a general mathematical statement.

### Recommendations

Priority order; each reaches its endpoint with zero sorries and no new axioms.

- **R1 (required work 1a). Add `WorldHistory.respects_task` to `FormalSystem/Semantics/PartialHistory.lean`, immediately after `states_eq_state` (~`:430`).** Machine-checked verbatim in the probe:
  ```lean
  theorem respects_task (τ : WorldHistory F) (s t : F.Duration) :
      F.TaskRel (τ.state s) (t - s) (τ.state t) :=
    τ.val.respects_task s t (τ.property s) (τ.property t)
  ```
  No `@[simp]` — it proves a relation, not an equation. Give it a docstring naming it as the `respects_task` obligation read at the bundled `state` accessor, and recording that it is the sole sanctioned replacement for hand-spelling the dependent projection.

- **R2 (required work 1b). Sweep the 22 call sites** per the per-file table above, `τ.val.respects_task a b (τ.property a) (τ.property b)` → `τ.respects_task a b`, **and apply the four `states_eq_state` adjustments in the same edit** (trim `ForwardDeterministicFrame.lean:271`; delete `FlowFrame.lean:377`, `FlowFrame.lean:382`, `RegionFrame.lean:338`). Sizing: 15 files, ~30 edited lines, one agent run. Rebuild once at the end rather than per file — the sweep touches leaf proofs almost exclusively, and only `PartialHistory.lean` invalidates the tree.

- **R3 (required work 2). Fix the two defects.**
  - `IntNormalForm.lean:280-282`: `def WorldHistory.path … := fun t => τ.val.states t (τ.property t)` → `:= τ.state`. Probe-verified `rfl`-equal to the current body, and the three `rfl`/`@[simp]` lemmas that ride on `path` (`IntNormalForm.lean:322`, `BiLasso/Extend.lean:89`, `BiLasso/Basic.lean:276`) were re-checked against the new body and still close by `rfl`.
  - `Extension/Extension.lean:218-220`: statement `∃ τ : WorldHistory F, τ.val.states x (τ.property x) = w` → `∃ τ : WorldHistory F, τ.state x = w`. Probe-verified: the existing proof term `exact ⟨τ, hext.agree x rfl⟩` is unchanged. Both consumers (`Extension.lean:235`, `Validity.lean:273`) destructure as `⟨τ, _⟩` and discard the witness, so no caller adjusts.

- **R4 (required work 3). Record the triage in the implementation summary, per the two tables above** — 4 definitional reach-throughs KEEP, 2 FIX under R3, 9 layer crossings KEEP. The triage is a deliverable of this task, not a side note; the summary should carry both tables so the next reader does not re-derive them.

- **R5 (optional, decide in planning). Delete the never-firing `CoeOut` instance (`PartialHistory.lean:413`), one line.** It is measurably dead, and this task is precisely the audit of the crossings it was meant to serve, so leaving it is leaving a false signal that crossings are implicit. Against: deleting an instance is the one change here whose blast radius is not syntactically bounded — instance resolution could in principle be relied on somewhere a grep cannot see. Recommendation: **include it, as its own commit, with a full rebuild between it and R1–R3**, so a revert is a one-line revert. If planning prefers a smaller diff, defer it to the flat-structure task, which deletes it anyway.

- **R6. Do NOT touch `WorldHistory.ext`.** Zero call sites, but it carries `@[ext]`, so removing it silently changes what the `ext` tactic does on a `WorldHistory` goal. It is a genuine deletion candidate, and it belongs to the flat-structure task, where `ext_state` collapses to one line and the whole extensionality story is revisited at once.

## Decisions

- **The counts in the task description are adopted, not merely inherited** — 28 reach-throughs and 8 `.val` layer crossings were independently re-measured against the live tree and confirmed. The one correction is upward: a **9th** layer crossing exists in the `.property` direction at `PeriodicExtension.lean:429`, which the prior audit's `.val`-only grep could not see.
- **All nine layer crossings are kept.** Eliminating them requires either touching `PartialHistory.Extends` (forbidden by the predecessor task's constraint and out of scope here) or converting `WorldHistory` to a flat structure (explicitly out of scope). There is no third option, and inventing a `WorldHistory`-level `Extends` wrapper would be exactly the "relocated bridging" the predecessor research warned against.
- **The 4 definitional reach-throughs in `PartialHistory.lean` are kept without qualification.** They are the accessor definitions themselves; a subtype must be opened somewhere, and `state`/`states_eq_state`/`timeShift` are the sanctioned somewhere.
- **`states_eq_state` is kept despite dropping to zero explicit call sites.** It is `@[simp]` and may fire implicitly; the explicit-call-site count is not evidence of deadness for a simp lemma.
- **Verification runs through `lake` directly, not through `lean-lsp`.** The MCP server failed to connect this session (`CONNECT_TIMEOUT` after 30s). This is a connection failure, not an absent capability; `lake env lean` on a probe file gave equivalent per-declaration evidence, so no finding in this report is weakened by it.
- **No `user_decision` is set.** R5 is the only genuine choice in the task, and it is a routine engineering trade-off between diff size and removing a dead instance — resolvable from the artifacts, with a stated recommendation, and reversible in one line. It does not require the user's judgment.

## Risks & Mitigations

- **Risk: a `simp` somewhere silently depended on `states_eq_state` firing against a hypothesis that the sweep moves into `state` form.** Mitigation: the full `lake build FormalSystem` at the end of R2 is a complete detector — there is no way for this to fail silently. Baseline is 2659 jobs at exit 0, so any regression is attributable.
- **Risk: the four `states_eq_state` `rw` lines are easy to miss during a mechanical find-and-replace**, and each produces a confusing "motive is not type correct" or "did not find instance of pattern" error rather than an obvious one. Mitigation: they are enumerated by exact file and line in R2, and `grep -rn "states_eq_state"` over `FormalSystem/` returns exactly six hits, two of which are the definition and its docstring — so the check is a three-second grep.
- **Risk: deleting the `CoeOut` instance (R5) changes elaboration at a site no grep can find.** Mitigation: separate commit, full rebuild between it and the rest, one-line revert. This is why R5 is sequenced last and marked optional.
- **Risk: `lean-lsp` unavailability hid a goal-state subtlety a hover would have caught.** Mitigation: the probe elaborates the actual lemma, the actual restated statements, and two actual rewrites under `lake env lean` — stronger evidence than a hover, since it is full elaboration. Residual exposure is limited to the 20 call sites not individually probed, all of which are the same shape as the two that were.
- **Risk: scope creep toward the rename or the flat-structure conversion.** Mitigation: both are named out of scope in the dispatch with their own justifications, and R6 explicitly parks the one deletion (`WorldHistory.ext`) that would pull this task toward the second of them.

## Tactic Survey Results

Tactic search played no role here: every obligation in this task is closed by a term, and the one new lemma is a projection. The survey below records what was actually elaborated in `specs/615_close_world_history_reach_through_residue/probes/01_respects-task-residue.lean` under `lake env lean` (exit 0, zero errors). `lean_multi_attempt` and `lean_hammer_premise` were unavailable (`lean-lsp` down); full elaboration substitutes for them here.

| Goal | Tactic / term | Result | Premises/Config |
|---|---|---|---|
| `F.TaskRel (τ.state s) (t - s) (τ.state t)` | term: `τ.val.respects_task s t (τ.property s) (τ.property t)` | success | none — direct projection |
| `∃ τ : WorldHistory F, τ.state x = w` (restated `occurrence`) | `obtain … := PartialHistory.extension …; exact ⟨τ, hext.agree x rfl⟩` | success | proof term identical to the current `:219` proof |
| `path' τ = τ.path` (the `IntNormalForm:282` fix is defeq) | `rfl` | success | relies on `WorldHistory.state` being a plain `def` |
| `path' (worldHistoryOfStepPath F f h) = f` | `rfl` | success | confirms `:322`'s `@[simp] rfl` survives the fix |
| `IsStepPath F (path' τ)` (the `:328` site, rewritten) | `intro n; have := τ.respects_task n (n+1); rwa [show n + 1 - n = (1:ℤ) by omega] at this` | success | new lemma only |
| `τ.state y = σ.state y` under forward determinism (the `:269-271` site, rewritten) | `have … := τ.respects_task x y; … rw [h] at hτr; exact hD …` | success | **confirms `rw [states_eq_state]` must be dropped** — the trimmed form is the one that elaborates |
| axiom gate: `validZTime_iff_validInt` | `#print axioms` | `[propext, Classical.choice, Quot.sound]` | no `sorryAx` |
| axiom gate: `truthAt_map` | `#print axioms` | `[propext, Classical.choice, Quot.sound]` | no `sorryAx` |

## Context Extension Recommendations

- **Topic**: verifying Lean claims when the `lean-lsp` MCP server is unreachable.
  **Gap**: `context/project/lean4/patterns/mcp-fallback-table.md` gives per-tool fallbacks between search tools, but there is no documented fallback for the *whole server* being down — the case where `lean_goal`, `lean_hover_info` and `lean_multi_attempt` are all unavailable at once. The working substitute used here (a throwaway probe file under `specs/{task}/probes/`, elaborated with `lake env lean`, carrying `#print axioms` and `example` blocks in place of hovers and multi-attempts) is a repeatable pattern that is currently folk knowledge.
  **Recommendation**: add a short "server-down fallback" section to `mcp-fallback-table.md`, or a sibling `context/project/lean4/patterns/probe-file-verification.md`, documenting the probe-file idiom, its placement convention under `specs/`, and the fact that full elaboration is *stronger* evidence than a hover rather than a degraded substitute.

## Appendix

- **Search queries used** (all `grep -rn`, `FormalSystem/` + `Tests/`, Boneyard excluded):
  - `\.val\.(states|domain|respects_task|nonempty_domain|timeShift)` — the 28-site reach-through inventory
  - `Extends [\w.']*\.val` / `PartialHistory\.(map|comap)` / `\.val = [\w.']*\.val` — the `.val` layer crossings
  - `\.property` restricted to files containing `WorldHistory` — surfaced the 9th crossing at `PeriodicExtension.lean:429`
  - `states_eq_state`, `ext_state`, `WorldHistory\.ext\b`, `\.path\b`, `occurrence`, `open.*WorldHistory|namespace WorldHistory`
- **Build invocation**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`, detached, exit 0, 2659 jobs.
- **Probe invocation**: `lake env lean specs/615_close_world_history_reach_through_residue/probes/01_respects-task-residue.lean`, exit 0, output limited to the two `#print axioms` lines.
- **Predecessor material**: `specs/archive/569_retarget_semantics_to_possible_world_index/reports/01_possible-world-index-retarget.md` (the R2/R3/R4 recommendations this task implements the first of); `specs/archive/569_retarget_semantics_to_possible_world_index/probes/01_possible-world-spike.lean` (`respects_task'` at `:76-78`, the lemma promoted here).
- **Toolchain**: Lean `v4.33.0-rc1`, Mathlib tag `v4.33.0-rc1` (`lake-manifest.json` commit `79d0395a`).
