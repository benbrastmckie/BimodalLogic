# Research Report: Task #569

**Task**: 569 - Retarget semantics to possible world index
**Started**: 2026-09-17T22:19:16Z
**Completed**: 2026-09-17T23:05:00Z
**Effort**: ~45 minutes
**Dependencies**: Task 584 (COMPLETED)
**Sources/Inputs**: - Codebase (`FormalSystem/`, `Tests/`), archived task artifacts (553, 584, 599, 601, 602), `docs/reference/paper-definitions-of-record.md`, the live JPL paper `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, `typst/chapters/02-semantics.typ`, a machine-checked Lean probe
**Artifacts**: - `specs/569_retarget_semantics_to_possible_world_index/reports/01_possible-world-index-retarget.md`
- `specs/569_retarget_semantics_to_possible_world_index/probes/01_possible-world-spike.lean`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task's premise is stale.** Every load-bearing claim in the description was true when it
  was written and is false against `d9d026255`. Tasks 599, 601 and 602 — the last of which
  completed at 2026-09-17T01:30:00Z, roughly 21 hours before this dispatch — already executed
  the description's entire suggested phase decomposition. `TruthAt` is already indexed by a
  total-by-construction type; there is no `IsTotal` side hypothesis at any semantic binder; all
  twelve named bridges are gone; `TaskFrame.HF` no longer exists.
- **The GATE resolves POSITIVE, and empirically rather than by argument.** The Z-transfer
  machinery does survive the narrow index because it is *already stated at it*.
  `validZTime_iff_validInt` and `truthAt_map` are proved over `WorldHistory F`, and
  `#print axioms` returns exactly `[propext, Classical.choice, Quot.sound]` for both — no
  `sorryAx`. `lake build FormalSystem` is green (2659 jobs, exit 0).
- **The description's correctness argument no longer describes the code.** `TruthAt`'s atom clause
  is `M.valuation (τ.state t) p` with no `∃ ht : τ.domain t`, and its box clause quantifies over
  the same type the index ranges over. The `refute_modal_t_at_bounded_index` degeneracy is not
  expressible against the current `TruthAt`, because there is no bounded index to instantiate it at.
- **The residual gap to the stated TARGET is 36 lines, not ~600 touch points** — 28 reach-through
  sites plus 8 layer-crossing `.val` sites. 22 of the 28 are one missing API lemma:
  `WorldHistory.respects_task`, three lines, eliminates every hand-spelled
  `τ.val.respects_task s t (τ.property s) (τ.property t)` in the tree. Machine-checked in the probe.
- **The flat-structure conversion is a genuine net simplification, but it is optional and it is
  not what the description asks for.** It costs a ~6-line bridge module (the Extension Theorem's
  conclusion is stated at the partial layer and cannot move) and repays that by deleting a dead
  `CoeOut` instance, a zero-call-site `WorldHistory.ext`, the `@[simp] states_eq_state` lemma that
  exists only to undo the subtype, and 43 `.property` tokens. It is a separable follow-on, not a
  precondition for anything.
- **Two of the description's hard constraints are now self-contradictory** and only the author can
  resolve them: `ConvexHistory` was deleted outright by task 599 (the description requires it to
  survive), and the paper does *not* support the `PossibleWorld` rename in the way the description
  states. See Decisions and the `user_decision` on `.return-meta.json`.
- **Recommended**: do NOT execute the retarget. Close task 569 as superseded-with-a-residue, or
  revise its description down to the 27-line cleanup. A sorry-free path exists for the cleanup;
  no sorry deferral is involved anywhere in this report.

## Context & Scope

The dispatch asked for research on retargeting the semantics from "a convex index carrying an
`IsTotal` side hypothesis" to a total-by-construction index, gated on a spike resolving whether
`FormalSystem/Semantics/IntTransfer.lean`'s ℤ-transfer survives the narrower index.

The first thing research must establish for a task whose description cites a study written against
an earlier tree state is whether that tree state still obtains. It does not. This report therefore
verifies the premises first, resolves the gate, measures the true residual, and surfaces the two
constraints that have become contradictory — rather than planning a change the repository has
already made.

Scope limits observed: `PartialHistory` and the Extension Theorem were treated as untouchable, as
the description requires; no production file was modified; the probe lives under `specs/`.

## Findings

### Codebase Patterns

**Premise-by-premise audit against `d9d026255`.**

| Description claim | Measured now | Verdict |
|---|---|---|
| index is "a convex index carrying an `IsTotal` side hypothesis" | `TruthAt : TaskModel F → WorldHistory F → F.Duration.carrier → Formula → Prop`, with `WorldHistory F := {τ : PartialHistory F // τ.IsTotal}` | **FALSE** — the index is total by construction |
| atom clause is domain-relative (`∃ ht : τ.domain t`) | `Formula.atom p => M.valuation (τ.state t) p` (`Truth.lean:234`) | **FALSE** |
| box clause "re-indexes to `H_F`" | `Formula.box φ => ∀ σ : WorldHistory F, …` — the same type as the index | **FALSE** |
| `IsTotal`: 239 in-code occurrences across 55 files | 25 lines total, 20 of them in `PartialHistory.lean` itself; the only three genuine consumers (`Extension.lean:141,174`, `PartialHistoryOrder.lean:200`) are at the partial layer, which the description puts out of scope | **FALSE** (−214) |
| ~280 bridge call sites across 26 files | `of_forall_total` 0, `apply_total` 0, `validOn_iff_total` 0, `genericValidOn_iff_total` 0 | **FALSE** (zero remain) |
| 12 bridge declarations in `Validity.lean` to delete | `TaskFrame.HF` 0, `FrameOver.HF` 0, and every `*_total` adapter 0. The surviving `Valid.of_forall`/`.apply` and `SemanticConsequence.of_forall`/`.apply` are the `.Base` binder-shape adapters task 602 deliberately kept and renamed; they are not totality bridges | **FALSE** |
| `ConvexHistory` SURVIVES as a definition | `ConvexHistory.lean` deleted by task 599; one prose mention remains (`PartialHistory.lean:57`, which records the deletion) | **FALSE, and now contradictory** — see Decisions |
| the paper "having withdrawn `world history` entirely" | the live paper's body still *defines* the tier as a world history (`possible_worlds.tex:1019`) | **FALSE** — see External Resources |

**The suggested phase decomposition was executed, phase for phase, by task 602.** Its plan
(`specs/archive/602_bundle_semantics_over_worldhistory/plans/01_*.md`) maps onto the description's
own numbering: 602 phase 1 = (1) introduce the total index and retire `HF`; phase 2 = (2) retarget
`TruthAt`/`Truth.lean`; phase 3 = (3) `Validity.lean` plus bridge deletion; phases 4–8 = (4–6) the
module-cluster sweep with the Decidability stack last, exactly as the description sequences it;
phase 9 = (7) dead-lemma sweep and full gate. 128 Lean files, +3041/−4207 lines — inside the
description's own −150 to −250 net estimate once 599's and 601's contributions are separated out.

**The residual subtype plumbing, measured exhaustively.** Grepping
`\.val\.(states|domain|respects_task|nonempty_domain|timeShift)` across `FormalSystem/` and
`Tests/` (Boneyard excluded) returns **28 sites**, and they fall into four groups:

| Group | Count | Files |
|---|---:|---|
| `τ.val.respects_task s t (τ.property s) (τ.property t)` spelled by hand | **22** | `Independence/{PastingIndependence,DriftHistories,RealTranslationFrame,LoopingDuration,CoNotPriorU,ForwardDeterministicFrame}.lean`, `Algebraic/FlowFrame.lean`, `WeakCanonical/IntegerModel/ReynoldsBridge.lean`, `Decidability/Verified/Bridge/RegionFrame.lean`, `PlusLanguage/{PlusPasting,PlusDeterminism}.lean`, `IntNormalForm.lean`, `ShiftSet.lean` |
| the definition of `state`/`timeShift`/`states_eq_state` itself | 4 | `Semantics/PartialHistory.lean:423,428,429,471` |
| should be `τ.state t` | 1 | `Semantics/IntNormalForm.lean:282` |
| should be `τ.state x = w` | 1 | `Semantics/Extension/Extension.lean:219` |

There is no `.val.nonempty_domain` anywhere. Against 503 `: WorldHistory` binders in the tree,
28 residual reach-through sites is a 5.6% friction rate concentrated in a single missing accessor.

**Layer-crossing `.val` — the sites that are not reach-throughs.** Eight sites hand a world
history to a `PartialHistory`-layer definition, and these are the only places where the subtype
relationship does real work:

| Site | What it crosses into |
|---|---|
| `Semantics/Extension/Extension.lean:172` | `Extends σ.val τ` — the Extension Theorem's conclusion |
| `Semantics/Extension/PeriodicExtension.lean:159, 403` | `PartialHistory.Extends σ.val τ` |
| `Metalogic/Decidability/BiLasso/Agreement.lean:114, 137` | `PartialHistory.Extends L.toWorldHistory.val τ` |
| `Semantics/IntTransfer.lean:205, 235` | `PartialHistory.map τ.val e` / `PartialHistory.comap e σ'.val` |
| `Semantics/PartialHistory.lean:433` | `τ.val = σ.val`, the body of `WorldHistory.ext` |

Plus one producer-direction site, `Extension/Extension.lean:174` (`⟨⟨μ, htot⟩, le_def.mp hle⟩`),
where Zorn hands back a `PartialHistory` and a totality proof.

**Two pieces of the current API are dead.** The `CoeOut (WorldHistory F) (PartialHistory F)`
instance (`PartialHistory.lean:413`) has **zero firing sites** — every layer crossing in the tree
is written with an explicit `.val`, and there is no `↑τ` or `(τ : PartialHistory F)` ascription of
a world history anywhere. `WorldHistory.ext` (`:433`, `@[ext]`-tagged) has **zero call sites**; the
extensionality principle the codebase actually uses is `ext_state`, at 19 sites across 6 files.
`Metalogic/Decidability/Propositional/Decidable.lean:161, 198, 205` additionally carry three
verbatim copies of a hand-rolled subtype pair that `ofTotal` would replace.

Three areas that might have been expected to depend on the subtype do not: `PartialHistoryOrder.lean`
and everything under `Semantics/Ultraproduct/` contain **no occurrence of `WorldHistory` at all**,
and the ~600 remaining `WorldHistory` mentions across `Metalogic/` use only `τ.state`,
`τ.timeShift` and `∀ σ : WorldHistory F` — completely indifferent to the representation.

**Build and sorry state.** `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem` completed successfully, 2659 jobs, exit 0. Every `sorry` match in live (non-Boneyard)
`FormalSystem/` is prose in a docstring asserting `sorryAx`-freedom; there are no live sorries.

### External Resources

**The paper, read directly — this refutes the description's naming premise and complicates the
rename.** `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` uses the term
in three incompatible-looking places, which resolve as follows:

1. **`:1019` (body, sec:Construction)** — *"A `\textit{world history}` is any partial history
   $\tau : X \to W$ whose domain is `\textit{total}`, so that $X = D$."* The term "world history"
   is the paper's own **definitional** term for the top tier and is very much still current.
   `:1020–1022, :1039–1047` use it throughout.
2. **`:1044–1046` (body)** — *Possible World:* `$[\tau]_{\F} := \{\sigma \in H_\F \mid \tau
   \approx_x^y \sigma …\}$`, and `$\W_\F := \{[\tau]_\F \mid \tau \in H_\F\}$`. Here a possible
   world is a **time-shift equivalence class**, a *different object* from a world history.
3. **`:1050` (body, the resolving sentence)** — *"Since the classes in $\W_\F$ will play no further
   role below, I will also refer to $H_\F$ as the set of `\textit{possible worlds}`."*
4. **`:2910` (appendix, `def:world-history`)** — *"A `\textit{possible world}` is any convex
   history whose domain is total."* Pinned verbatim in
   `docs/reference/paper-definitions-of-record.md:899–907`, sha256 `550661d3…`.

So the paper licenses **both** names for $H_\F$ and prefers "world history" in its definition.
`WorldHistory F` is therefore already the paper's own primary term, not drift. The
`paper-definitions-of-record.md:394–399` body/appendix wording note records exactly this and was
re-pinned by task 584 at `a166fcbf` — 584 being this task's own dependency, and the task whose job
was paper-vocabulary reconciliation. It renamed 1,466 occurrences across 81 files and deliberately
did **not** rename `WorldHistory`.

Two further consequences for the TARGET as literally stated:

- *"so that `PossibleWorld F` and `F.HF` coincide definitionally"* — `F.HF` does not exist; task
  602 deleted `TaskFrame.HF` and `FrameOver.HF`. There is now exactly one type, so the coincidence
  is trivially already achieved, and the sentence has no referent to compare against.
- *"named for the paper's own term, the paper having withdrawn `world history` entirely"* — the
  factual clause is false, and under reading (2) the rename would newly conflate $H_\F$ with
  $\W_\F$, introducing a vocabulary error the current name does not have.

`typst/chapters/02-semantics.typ:259` already documents the current Lean encoding accurately and
in the paper's three-tier vocabulary, so the repository's own prose is not the thing out of sync.

### Recommendations

The build is green, the tree is sorry-free, and every recommendation below reaches its endpoint
with zero sorries and no new axioms. Nothing in this report defers an obligation.

**R1 (primary). Do not execute the retarget.** It has been executed. Re-running the description's
seven phases against the current tree would be a no-op at best and churn at worst, since phases
(1)–(3) target declarations that no longer exist and phases (4)–(6) target call sites that are
already zero.

**R2. The one change actually worth making — add `WorldHistory.respects_task`.** Machine-checked
in the probe as `respects_task'`:

```lean
theorem WorldHistory.respects_task (τ : WorldHistory F) (s t : F.Duration) :
    F.TaskRel (τ.state s) (t - s) (τ.state t) :=
  τ.val.respects_task s t (τ.property s) (τ.property t)
```

This is the `respects_task` field of the TARGET structure, stated at the existing type. It
collapses 22 of the 27 residual plumbing sites, requires no representation change, no rename, and
no bridge. With it, the flat structure becomes a one-liner in each direction and the two types are
provably equivalent — the probe builds `WorldHistory F ≃ PossibleWorld F` with `left_inv` by
`ext_state` and `right_inv` by `rfl`. Sized at one agent run including the 22 call-site rewrites
and the two `IntNormalForm.lean:282` / `Extension.lean:219` cleanups.

**R3. The flat-structure conversion is viable and net-negative in lines, but it cannot be sold as
"no bridging apparatus", and it should be decided on its own merits rather than inherited from
this description.** Two findings, pulling in opposite directions, and both are measured:

*Against.* The description's stated reason for the change — eliminating bridging apparatus — does
not survive contact with the Extension Theorem. `PartialHistory.extension`'s conclusion is
`∃ σ : WorldHistory F, Extends σ.val τ`, `Extends` is a `PartialHistory`-layer relation, and the
description's own hard constraint forbids touching it. A flat structure must therefore introduce
`PossibleWorld.toPartialHistory` and push that conclusion across it, at the 8 layer-crossing sites
tabulated above. The probe shows the bridge is not even transparent to `simp`: the `Extends`
example needed an explicit `show σ.state t = τ.states t ht` where the subtype form is `rfl`. So
the conversion **adds** a bridge in order to satisfy a requirement to remove one. Stated as the
description states it, the change is self-defeating.

*For.* The bridge is small — roughly six lines, two definitions — and the subtype is carrying more
dead weight than expected. The conversion would delete the never-firing `CoeOut` instance, the
zero-call-site `WorldHistory.ext`, the `@[simp] states_eq_state` lemma whose entire purpose is to
undo the subtype, and the destructuring `funext`/`propext` proof of `ext_state` (which collapses to
roughly one line once `states` is a non-dependent field). It converts 22 `respects_task` calls and
43 `.property` tokens into nothing, and folds `Decidable.lean`'s three hand-rolled pairs into a
named term. Net line change is clearly negative.

*Disposition.* The honest reading is that this is a worthwhile but **optional** refactor whose
actual justification (dead API, simpler extensionality) is different from the description's stated
one (removing bridges), and which is independent of both the rename and the 22-site cleanup. It
should be its own task with its own rationale, sequenced after R2, and it must not be undertaken
on the belief that it eliminates bridging — it relocates it.

**R4. If the rename is nevertheless wanted, scope it as a rename and nothing else.** It is
mechanical: 503 binders plus the `WorldHistory.*` namespace, in one atomic batch on the pattern
task 584 used for `TD → TR` (1,466 occurrences, 81 files, one commit, no deprecated aliases). It
must not be bundled with a representation change, and it needs the author's answer on the
$H_\F$ / $\W_\F$ ambiguity first.

**R5. Unblock task 588.** Task 588 (`triage_zero_occurrence_declarations`) lists 569 among its
dependencies. Whatever disposition 569 receives, it should be recorded promptly so 588 is not held
behind a task whose work is already in `main`.

## Decisions

- **Research scope was redirected from "plan the retarget" to "verify the premises".** Justified
  by the finding that the description's cited study (`553`) predates three completed tasks. This
  is reported as a finding, not treated as a licence to plan around a stale description.
- **The gate was resolved by direct axiom inspection rather than by reasoning about transportability.**
  `#print axioms` on `validZTime_iff_validInt` and `truthAt_map` is stronger evidence than any
  argument about whether the transport *would* go through, because the transport is the thing
  actually in the tree.
- **`ConvexHistory`'s deletion is recorded as a contradiction in the description, not silently
  worked around.** The description states it "SURVIVES as a definition" and that removing it
  "would foreclose" the presheaf front (tasks 563/565/566/567) and the C3/C4 front (568/570).
  Research finding: convexity survives as the **predicate** `PartialHistory.IsConvex`
  (`PartialHistory.lean:268–274`, with `IsTotal.isConvex`), so those fronts are not foreclosed —
  they must define their own index (`{τ : PartialHistory F // τ.IsConvex}` or a bounded-interval
  refinement) rather than reuse a named structure. That is additional work for them, not a
  blocker. Whether to reinstate a named `ConvexHistory` is the author's call and is raised as a
  user decision, not resolved here.
- **No production file was modified.** All evidence is from reads, greps, one guarded background
  build, and a probe under `specs/`.

## Risks & Mitigations

- **Risk: a planner reads the description rather than this report and dispatches the seven
  phases.** Mitigation: the Executive Summary leads with the staleness finding, and
  `.return-meta.json` carries a blocking `user_decision`.
- **Risk: the `PossibleWorld` rename is done on the description's stated rationale, which is
  factually wrong.** Mitigation: the paper lines are quoted with file:line in External Resources
  so the author can check them directly. Under reading (2) the rename actively introduces an error.
- **Risk: a flat-structure conversion is attempted on the description's stated rationale and the
  Extension Theorem's partial-layer conclusion is discovered mid-phase.** Mitigation: R3 records
  the obstruction with a compiling probe and prices the bridge at ~6 lines, so the surprise is
  absorbed before the phase rather than during it.
- **Risk: the `ext_state` simplification is claimed as a win for R3 without checking its 19 call
  sites.** Mitigation: the call sites are enumerated (`ShiftSet` 4, `ReynoldsBridge` 4, `FlowFrame`
  2, `CoNotPriorU` 2, `RegionFrame` 2, `RealTranslationFrame` 1, plus 4 docstring mentions); the
  lemma's *statement* is unchanged by the conversion, only its proof, so the call sites are
  unaffected.
- **Risk: R2's 22 rewrites touch `Decidability/Verified/Bridge/RegionFrame.lean` and
  `WeakCanonical/IntegerModel/ReynoldsBridge.lean`, both heavy modules.** Mitigation: the rewrite
  is a term-for-term substitution of a definitionally equal proof term; `lake build FormalSystem`
  via the guard, detached, gates it.
- **Risk of sorry introduction: none identified.** R2 is a definitional unfolding, R4 is a rename,
  R3 is a recommendation against acting. No approach in this report has a step that would require
  a placeholder.

## Tactic Survey Results

The tactic-discovery survey was run only where a proof obligation actually arose — the probe's
four goals. `lean-lsp` was unavailable this session (the MCP server timed out at connect), so
`lean_multi_attempt` and `lean_hammer_premise` could not be used; candidates were tested by
compiling the probe with `lake env lean` instead, which is a stronger check than a tactic trial.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `WorldHistory.respects_task'` | direct proof term | success | `τ.val.respects_task s t (τ.property s) (τ.property t)` — no tactic needed |
| `PossibleWorld.ofWorldHistory`'s `respects_task` field | `simpa` | success | default simp set; `states_eq_state` is the `@[simp]` lemma that fires |
| `round_trip_states` | `rfl` | success | definitional both ways |
| `round_trip'` / `equivPossibleWorld.left_inv` | `WorldHistory.ext_state (fun _ => rfl)` | success | the `ext_state` lemma task 602 added |
| `equivPossibleWorld.right_inv` | `rfl` | success | flat structure is eta-definitional |
| `Extends` example across the flat bridge | `simpa using hst t ht` | **fail** | simp cannot see through `toPartialHistory`; this is R3's evidence |
| same goal | `show σ.state t = τ.states t ht; exact hst t ht` | success | explicit type ascription required — the friction a flat structure adds |

## Context Extension Recommendations

- **Topic**: premise re-verification for tasks whose description cites a study report.
- **Gap**: nothing in `context/project/lean4/` or `context/standards/` directs a research agent to
  re-verify a description's measured claims against the current tree before planning from them.
  This task's description carried seven quantitative claims (239 occurrences, 280 call sites, 12
  bridges, 133 `.states` sites, 55 files, ~600 touch points, −150 to −250 lines); all seven were
  stale, and the staleness was detectable in under ten minutes by re-running the description's own
  grep commands. A task whose description quotes numbers hands research a cheap, decisive
  falsification test.
- **Recommendation**: add a short "Re-run the description's own measurements first" subsection to
  `.claude/context/project/lean4/` research guidance (source store:
  `agent-system/extensions/lean/context/`), stating that when a task description cites counts or
  cites a report under `specs/archive/`, the first research action is to re-execute those counts
  and report the delta before any other work. Cheap, mechanical, and it would have short-circuited
  this dispatch at minute five.

## Appendix

### Commands run (all reproducible)

```bash
# premise audit
grep -rn "IsTotal" FormalSystem/ --include=*.lean | grep -v Boneyard | wc -l            # 25 (was 239)
grep -rn "of_forall_total\|apply_total\|validOn_iff_total" FormalSystem/ --include=*.lean \
  | grep -v Boneyard | wc -l                                                            # 0 (was ~280)
grep -rn "ConvexHistory" FormalSystem/ --include=*.lean | grep -v Boneyard              # 1, a prose note
grep -rn "TaskFrame.HF\|FrameOver.HF" FormalSystem/ --include=*.lean | grep -v Boneyard # 0

# residual plumbing, exhaustive
grep -rnE "\.val\.(states|domain|respects_task|nonempty_domain|timeShift)" \
  FormalSystem/ Tests/ --include=*.lean | grep -v Boneyard                              # 28
grep -rnE "↑τ|↑σ|WorldHistory\.ext\b" FormalSystem/ Tests/ --include=*.lean | grep -v Boneyard  # 0: CoeOut and ext are dead
grep -rnoE ": WorldHistory " FormalSystem/ Tests/ --include=*.lean | grep -v Boneyard | wc -l  # 503

# gate + green
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem     # 2659 jobs, exit 0
lake env lean specs/569_retarget_semantics_to_possible_world_index/probes/01_possible-world-spike.lean
```

### Probe output (verbatim)

```
'FormalSystem.Semantics.validZTime_iff_validInt' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.truthAt_map' depends on axioms: [propext, Classical.choice, Quot.sound]
@TruthAt : {F : TaskFrame} → TaskModel F → WorldHistory F → F.Duration.carrier → Formula → Prop
```

No errors, no warnings, no `sorryAx`.

### References

- `specs/archive/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` §6.1 — the costing the description quotes; accurate when written
- `specs/archive/599_unify_total_histories_partial/summaries/01_*.md` — `ConvexHistory` deleted
- `specs/archive/601_align_task_frame_reflection_convention/` — reflection-convention alignment
- `specs/archive/602_bundle_semantics_over_worldhistory/{plans,summaries}/01_*.md` — the retarget, executed
- `specs/archive/584_reconcile_lean_tree_with_paper_vocabulary/summaries/01_*.md` — the vocabulary reconciliation that deliberately left `WorldHistory` alone
- `docs/reference/paper-definitions-of-record.md:385, 394–399, 723–740, 899–925`
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex:453, 946, 1019–1022, 1039–1050, 2910`
- `FormalSystem/Semantics/PartialHistory.lean:209, 268–274, 391–475`
- `FormalSystem/Semantics/Truth.lean:232–241`
- `FormalSystem/Semantics/IntTransfer.lean:203–339`
- `FormalSystem/Semantics/Extension/Extension.lean:171–172, 219`

### Literature Proof Structure

Not applicable — no literature source is referenced by this task, and `--lit` was not active.
