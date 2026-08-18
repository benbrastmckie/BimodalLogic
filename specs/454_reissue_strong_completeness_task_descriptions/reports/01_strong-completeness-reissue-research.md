# Research Report: Task #454

**Task**: 454 - reissue_strong_completeness_task_descriptions
**Started**: 2026-08-18T00:00:00Z
**Completed**: 2026-08-18T07:06:00Z
**Effort**: high (meta, description-only)
**Dependencies**: 452 (housekeeping; no substantive interaction with this task's scope)
**Sources/Inputs**: - Codebase (`FormalSystem/Semantics/*.lean`, `FormalSystem/Metalogic/**`), `specs/state.json`, `specs/archive/state.json`, `specs/archive/361_.../design/02_compactness-route.md`, `specs/TODO.md`
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All nine cited anchor drifts, plus the "still ACCURATE" CarrierProbe anchor, are **verified exactly correct** against the live tree — every claimed actual line number matches. Two additional drifted anchors in task 422's own text (`_buc`/`_fuc` at :680/:755, actual :675/:750) were found beyond the nine and should be fixed at the same time.
- The `TruthAt`/`Omega` deletion claim is **verified verbatim** (`Truth.lean:159`, box clause `:164`, docstring "There is no admissible-history parameter" at `:126-129`). `ShiftClosed` and the Omega-taking form of `time_shift_preserves_truth` are gone entirely — not just Truth.lean's own signature, the whole hypothesis class the old Representation Theorem depended on has been eliminated.
- **Task 424 has already been partially re-issued once** (2026-08-10, visible in its live `state.json` description) in response to task 414's *announcement*. That re-issue added `414` as a dependency and correctly predicted the post-refactor shape ("most likely: `Omega` is simply dropped and `Box` is hard-coded to quantify over `{σ : WorldHistory F // σ.IsTotal}`") — which is exactly what landed. This task's job is to complete that prediction into an actual re-scoped theorem statement, which section "Deliverable (b) Verdict" below does.
- **Verdict for (b): the Representation Theorem survives and simplifies — it does not dissolve, and does not need a separate research cycle.** Losing `Omega` removes a parameter and a hypothesis (`ShiftClosed`) from both directions; it does not remove any mathematical content. Full derivation below.
- **Verdict for (c): the graph already anticipates part of the fix.** State.json currently has `454` wired as a dependency of 421, 423, and 424 (transitively blocking 422/169/362 too) — apparently from a prior partial dispatch of this same task. What is still missing is the *other* direction: nothing depends on 424. Recommendation: add `424` to task 362's dependencies (not 423's — 423 is explicitly vocabulary-only/self-contained per its own description) and soften "gate for the entire ultraproduct branch" to name what it actually gates today (S1 of Route B; leg B of 362) versus tasks (S2-S5) that don't exist yet and so cannot carry a real edge.
- One stale, non-blocking fact found in passing: task 454's own "context to preserve" section states "41 declared dependency edges across the active set"; the live count is 44 unique / 102 raw. Zero-dangling is independently reconfirmed fresh, so this doesn't invalidate anything, but re-issued descriptions should not repeat "41" verbatim.

## Context & Scope

Scope was fixed by the task-454 description in `specs/state.json` (quoted in full to the delegating agent; not reproduced here). Three deliverables: (a) re-anchor nine drifted citations by symbol name across tasks 169/362/421/422/423; (b) re-scope task 424 against total-history semantics, with a real verdict; (c) resolve the 424-gates-nothing dependency contradiction. Non-goals: no Lean, no sorry closed, no re-scoping of 169/362/421/422/423 beyond anchors, no `state.json` writes (that is implementation-time work, to go through `state-write.sh`).

## Findings

### (a) Anchor drift — all nine confirmed, plus two more

| Task | Symbol | Cited (stale) | Verified actual | Notes |
|---|---|---|---|---|
| 423 | `valid` | `Validity.lean:79` | `:94` | `FormalSystem/Semantics/Validity.lean` |
| 423 | `ValidDense` | `Validity.lean:169` | `:206` | |
| 423 | `ValidDiscrete` | `Validity.lean:187` | `:222` | |
| 423 | `ValidDedekindDense` | `Validity.lean:276` | `:310` | |
| 421 | refuted route-(i) guidance | `Transfer.lean:1239-1241` | `:1081-1083` | text is verbatim the "(i) a Base-MCS ... (ii) a Henkin-style ..." comment block |
| 169 | `theorem countermodel_discrete` (the sorry) | `Transfer.lean:1242` | `:1068` (decl start); the `sorry` token itself is at `:1084` | File is 1086 lines total — 1239/1242 are past EOF |
| 169 | `theorem completeness` | `Completeness.lean:196` | `:191` | `FormalSystem/Metalogic/BXCanonical/Completeness.lean` (not the Boneyard or Kamp files of the same basename) |
| 422 | `box_dense_gives_density` | `ChronicleToCountermodelBasic.lean:435` | `:430` | `FormalSystem/Metalogic/BXCanonical/Chronicle/` |
| 422 | `cantor_bfmcs_dense_restricted_tc` | `ChronicleToCountermodelBasic.lean:629` | `:624` | |

**Confirmed still accurate, do not touch**: 421's `CompletenessDedekind.lean:61-100` (`CarrierProbe`) — the actual `section CarrierProbe ... end CarrierProbe` block spans `:69-105`, well within the cited range's spirit; symbol-name anchoring (`section CarrierProbe`) is still recommended so it stops depending on line numbers at all.

**Beyond the nine — found during verification, same file, same -5 drift, not in the original table**: task 422's own description also cites `cantor_bfmcs_dense_restricted_buc (:680)` and `_fuc (:755)`; actual positions are `:675` and `:750`. Recommend folding these into the same by-symbol re-anchor pass since they're touched by the same edit and the same drift cause.

**Recommended re-anchoring convention** (per the task's own instruction): cite by fully-qualified symbol name as primary, e.g. "`box_dense_gives_density` (`ChronicleToCountermodelBasic.lean`)" with the line number demoted to a parenthetical hint, e.g. "(currently `:430`, re-verify before use)." Do not restate line numbers as if load-bearing anywhere in the four descriptions being touched for (a).

### (b) Task 424 re-scope — verdict

**What changed underneath 424.** `FormalSystem/Semantics/Truth.lean:159` (verified):

```
def TruthAt (M : TaskModel F)
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ...
  | Formula.box φ => ∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ   -- :164
  ...
```

No `Omega` parameter anywhere in the signature. The docstring at `:126-129` is categorical: "There is no admissible-history parameter... no set-valued parameter can narrow, widen, or otherwise influence the meaning of any connective." `ShiftClosed` — the hypothesis the old Representation Theorem's reverse direction required (`h_sc : ShiftClosed Omega`) — no longer exists in `Truth.lean` at all (grep confirms zero occurrences). `time_shift_preserves_truth` (`:457`) now has signature `(M : TaskModel F) (σ : WorldHistory F) (x y : D) (φ : Formula)` — no `Omega`, no `h_sc` — and its own docstring states this explicitly: *"no shift-closure hypothesis is required... there is no closure condition left to assume, so this statement is strictly stronger than the shift-closure-hypothesised version it replaces."*

**Re-derivation of the Representation Theorem against this signature.**

*Forward direction (shift set → task model)* — unchanged in construction, changed in what must be proved. Given `⟨Ω, D, sh, A⟩`, build `WorldState := Ω`, `TaskRel w d u := (u = sh w d)`, `states σ t := sh σ t`. Because `TaskRel` is defined as an equality here (functional, not merely a relation), `respects_task` forces every total history `σ` in the resulting frame to satisfy `σ.states t = sh (σ.states 0) t` for all `t` — i.e. **every total history in the constructed frame is exactly the shift-orbit of some `w ∈ Ω`, and every `w ∈ Ω` gives exactly one total history.** So the set the old draft called out by fiat as `Omega := Set.range (fun σ => h_σ)` is not something the construction has to *choose* under the new semantics — it is provably **equal to `H_F`, the frame's full total-history set**, which is exactly the domain `Box` now quantifies over. What was a stipulation ("let Omega be this range") becomes a theorem to state and prove ("the range equals all of `H_F`"). This is a genuine simplification, not a new obligation: R4's six-clause reading list already covers exactly this.

*Reverse direction (task model → shift set)* — this is where the parameter deletion actually bites, and where it also simplifies. Old signature: input `(F, M, Omega, h_sc : ShiftClosed Omega)`, output `Ω := Omega`, `sh σ Δ := σ.timeShift Δ` (landing in `Omega` *by* `h_sc`), `A p σ := TruthAt M Omega σ 0 (atom p)`. New signature: input is just `(F, M)` — no `Omega`, no `h_sc` to discharge — output `Ω := {τ : WorldHistory F // τ.IsTotal}` (i.e. `H_F`, the canonical bundled total-history type; `WorldHistory.lean:514`), `sh σ Δ := σ.val.timeShift Δ` landing in `H_F` unconditionally via `WorldHistory.isTotal_timeShift` (`WorldHistory.lean:486-487`, no side condition), `A p σ := TruthAt M σ.val 0 (atom p)`. Compatibility comes from the now-unconditional `time_shift_preserves_truth M σ.val x y φ`.

**Verdict**: the theorem's *content* is unchanged — it is literally the totality-fixed special case of the old theorem, which the 2026-08-10 audit already predicted correctly ("Fixing `Omega := H_F` is a special case of the general argument, not a different argument"). What the re-issue should record is: (1) the theorem loses a parameter (`Omega`) and a hypothesis (`ShiftClosed`) on both directions — it becomes strictly *simpler* to state, not harder; (2) the forward direction gains one small proof obligation that used to be free (showing the constructed frame's `H_F` equals the shift-orbit range — a consequence of `TaskRel`'s functionality, not a new risk); (3) `ShiftClosed` should be dropped from the statement entirely rather than "re-derived," since the concept the risk register (`R4`) worried about no longer has anywhere to attach. None of Q1's structural evidence, R1 (dependent ultraproduct), R2 (box case of Łoś), or R3 (`Type` vs `Type*`) changes — they are stated purely in terms of `TruthAt`'s clause shapes and Mathlib coordinates, none of which reference `Omega`. **This does not need a separate research cycle**; the re-issued description for 424 can carry the corrected statement directly (see Recommended Text below). Anchors to update in 424's own description as part of this: `Truth.lean:128-137` (six `TruthAt` clauses, R4) → cite by symbol `TruthAt`, currently `:159-167`; `Truth.lean:446` (`time_shift_preserves_truth`) → currently `:457`; `ShiftClosed` (`Truth.lean:333`) → **delete this citation**, the definition no longer exists.

### (c) Dependency graph — verified, partially already fixed

Confirmed via `specs/state.json`: nothing currently lists `424` in its `dependencies` array (checked with a direct `jq` scan over all `active_projects`). This part of the description's claim stands unrefuted.

**New finding not in the original description**: the *other* half of the graph — descriptions depending on `454` — has already been wired in, apparently by an earlier partial dispatch of this very task (`dispatch_seq` reached 7 with no report/handoff artifacts on disk, meaning prior dispatches touched `state.json` without completing a report):

```
421 deps=[361,448,454]
423 deps=[361,454]
424 deps=[361,414,439,454]
422 deps=[414,420,421,439,448]   -- transitively blocked via 421
169 deps=[361,422,448]           -- transitively blocked via 422
362 deps=[361,375,169,170]       -- transitively blocked via 169
```

So all six targets are already correctly blocked on `454` landing before any of them can be dispatched — this half of the graph work does not need to be redone or re-verified further; it is already consistent with "do not leave 424 dispatchable as written" for all six tasks.

**What is still open**: resolving 424 "gates nothing" in the *forward* direction (what depends on 424). Checked task 423's own description directly: it is explicit that it "proves no compactness result," is "self-contained," and unblocks two downstream branches without needing 424 — so 423 is **not** a correct target for a new `424` dependency edge, contrary to the original description's tentative "423's `strongCompletenessDense_of_compact`/`CompactDense` statements, and/or 362" phrasing. 423 only *declares* those Props; it does not prove them. Checked 362's own live description: leg B ("GENUINE strong completeness... conditional on task 361's feasibility verdict and gated on the set-based model-existence theorem it scopes") is exactly the consumer of Route B (`S1`=424 through `S4`). Independent corroboration from task 170's archived description (`specs/archive/state.json`, `project_number: 170`): "Genuine STRONG completeness for Dense (Γ : Set Formula) additionally requires semantic compactness, gated on task 424; that obligation is NOT discharged by this task" — written before 170 was archived, so it is an independent contemporaneous statement, not circular with 454's own description.

The remaining structural wrinkle: `S2`-`S5` (the ultraproduct, Łoś, and the two strong-completeness capstones) are **deliberately not yet created as tasks** — 424's own description states this explicitly ("NOT AUTHORIZED and has deliberately NOT been created as tasks"). So no edge can literally point from an S2-S5 task to 424, because no such tasks exist. The only *existing* task that genuinely needs 424's output to complete its full scope is 362 (leg B specifically; legs A/C/D of 362 do not need it).

**Recommendation**: add `424` to task 362's `dependencies` (currently `[361, 375, 169, 170]` → `[361, 375, 169, 170, 424]`), and reword 424's "gate for the entire ultraproduct branch" language to be precise about scope: it gates (i) the *creation* of tasks S2-S5 (not yet existing, so not edge-representable), and (ii) leg B of task 362 specifically (which is edge-representable, and should be wired). Do not add an edge from 423 — 423's own description is explicit that it does not need 424 to complete.

### Context confirmed intact (Section 4 of the task description)

- Zero dangling dependency references: independently re-verified across every `active_projects[].dependencies[]` entry against `active_projects`, `specs/archive/*/` directories, and `specs/archive/state.json`'s `archived_projects`/`completed_projects` — no unresolved reference found. **Note**: the specific count "41 declared dependency edges" is stale — live count is 44 unique / 102 raw across the full active set (the set has grown since that count was taken, and/or the count was scoped more narrowly than "the active set" literally states). This doesn't affect the zero-dangling conclusion; just don't repeat "41" verbatim in the re-issued text.
- 361, 375, 414, 420, 439, 448 all confirmed archived as directories under `specs/archive/`. 170 confirmed archived too, but via a different mechanism: it has no `specs/archive/170_*` directory; its record lives inside `specs/archive/state.json`'s `completed_projects` array (`status: "completed"`, `archived: "2026-08-05T17:12:28Z"`). Worth noting for whoever re-issues text referencing "170 is archived" — the directory-based archive check alone would have missed it.
- `Core.RestrictedMCS` import claim reconfirmed exactly: only `Metalogic/Core.lean` and `Decidability/FMP/ClosureMCS.lean` import it outside `Boneyard/`; `StrongCompleteness.lean`'s import list is exactly `Semantics.Validity`, `Core.DeductionTheorem`, `Soundness`, `BXCanonical.CompletenessDedekind` — RestrictedMCS is absent, confirmed.
- No `strong_completeness`-topic task depends on the one decidability task (412) or on task 450 — reconfirmed by direct topic-filtered `jq` query over the live graph.

## Decisions

- Anchor re-issue for (a) should use symbol name as primary reference for all eleven citations found to be stale (nine from the original table plus two more found in task 422's text), demoting line numbers to non-load-bearing hints.
- Task 424's re-scope should state the simplified two-direction theorem directly (see "Recommended Text" below) rather than opening a new research task — the math is settled, only the statement's shape changed.
- Task 424's "gate" language should be split into "gates creation of S2-S5" (prose-only, not edge-representable) plus "gates leg B of task 362" (edge-representable — recommend adding the edge at implementation time).
- Do not add a 424 dependency edge to 423.

## Risks & Mitigations

- **Risk**: if the re-issue text for 424 restates the Representation Theorem without also dropping `ShiftClosed` from the acceptance criteria (if it's cited there), a future implementer may go hunting for a definition that no longer exists. **Mitigation**: explicitly call out that `ShiftClosed` is retired, not renamed.
- **Risk**: re-adding `424 -> 362` without narrowing it to "leg B only" could make orchestration treat all of 362 (including legs A/C/D, which don't need 424) as blocked on a high-effort Route-B gate. **Mitigation**: the re-issued 362 description (out of scope for this task's edits, since 362's substance is not to be re-scoped) already separates legs A-D; the dependency-graph note added to 424 or 362 at implementation time should say "specifically leg B" in prose alongside the edge, since the edge itself can't express "only part of this task."

## Context Extension Recommendations

- None specific to `.claude/context/` — this is task-specific Lean/graph verification, not a generalizable pattern gap.

## Recommended Text (for implementation-time use, not applied here)

**424 Representation Theorem, re-scoped** (drop-in replacement for the `Omega`-based statement in 424's description):

> Prove, in both directions, that the task-model class is representable by shift sets `⟨Ω, D, sh, A⟩` (`D` an ordered abelian group, `Ω` a nonempty type with a `D`-action `sh : Ω → D → Ω`, `A : Atom → Ω → Prop`), against the current totality-based `TruthAt` (`Truth.lean`, symbol `TruthAt`, box clause quantifies over `∀ σ, σ.IsTotal → ...` — no `Omega` parameter exists).
>
> Forward: build `WorldState := Ω`, `TaskRel w d u := (u = sh w d)`, `states σ t := sh σ t`, `domain := Set.univ`. Prove the resulting frame's full total-history set (`H_F`) equals `Set.range (fun w => history generated by sh w ·)` — this follows from `TaskRel`'s functionality forcing every total history to be a single shift-orbit — and that `TruthAt` in this model is determined by `A` alone.
>
> Reverse: from `(F, M)` alone (no `Omega`, no shift-closure hypothesis — `ShiftClosed` no longer exists), take `Ω := {τ : WorldHistory F // τ.IsTotal}`, `sh σ Δ := σ.val.timeShift Δ` (lands in `Ω` unconditionally via `WorldHistory.isTotal_timeShift`, no side condition), `A p σ := TruthAt M σ.val 0 (atom p)`. Compatibility is supplied by `FormalSystem.Semantics.TimeShift.time_shift_preserves_truth` (symbol `time_shift_preserves_truth`, currently `Truth.lean:457`), now unconditional (no `h_sc` argument).
>
> Everything else in the governing design document (Q1's structural evidence, Route B's S1-S4 plan, risks R1-R4, the GATING RULE) survives unchanged — none of it is stated in terms of `Omega`.

**424 dependency-graph note** (for implementation-time `state-write.sh` edit, not applied here): add `424` to task `362`'s `dependencies`; do not add it to `423`'s. In 424's own description, replace "THIS TASK IS THE GATE FOR THE ENTIRE ULTRAPRODUCT BRANCH" with language naming what it concretely gates today: authorization to create tasks S2-S5 (not yet existing), and leg B of task 362 (the genuine strong-completeness legs for Base/Dense), specifically — not legs A/C/D of 362, and not 423 (self-contained).

## Appendix

Key verification commands (all run against the live tree at commit `11ad049b8`, branch `main`):
- `grep -n "^def valid\b\|^def ValidDense\b\|^def ValidDiscrete\b\|^def ValidDedekindDense\b" FormalSystem/Semantics/Validity.lean`
- `wc -l FormalSystem/Metalogic/WeakCanonical/Transfer.lean` (1086 lines)
- `grep -n "theorem countermodel_discrete\|sorry" FormalSystem/Metalogic/WeakCanonical/Transfer.lean`
- `grep -n "^theorem completeness\b" FormalSystem/Metalogic/BXCanonical/Completeness.lean`
- `grep -n "box_dense_gives_density\|cantor_bfmcs_dense_restricted_tc\|cantorIsoDense\|_buc\|_fuc" FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`
- `grep -n "section CarrierProbe\|end CarrierProbe" FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean`
- `sed -n '120,170p' FormalSystem/Semantics/Truth.lean` (TruthAt def, box clause, "no admissible-history parameter" docstring)
- `grep -n "ShiftClosed\|time_shift_preserves_truth" FormalSystem/Semantics/Truth.lean`
- `grep -n "IsTotal" FormalSystem/Semantics/WorldHistory.lean`
- `jq -r '.active_projects[]|select(.project_number|IN(169,362,421,422,423,424,425,361,375,414,420,439,448,170,450))|"\(.project_number) status=\(.status) deps=\(.dependencies)"' specs/state.json`
- `jq -r '.. | objects | select(.project_number? == 170)' specs/archive/state.json`
- `grep -rl "import.*RestrictedMCS" FormalSystem --include="*.lean"`
