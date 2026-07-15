# Research Report: Task #373

- **Task**: 373 - revise_kamp_theorem_formalization_tasks
- **Started**: 2026-07-15T00:00:00Z
- **Completed**: 2026-07-15T15:30:00Z
- **Effort**: ~2 hours (codebase archaeology + literature grounding)
- **Dependencies**: None
- **Sources/Inputs**:
  - Codebase: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` (21 files) and its
    `NfMultiAnchorBridge/` subdirectory (49 files), read directly and via `wc -l`/`grep`
  - Task artifacts: `specs/341_structural_refactor_sharedwitness_carrier_layer/`,
    `specs/358_realization_recursion_nf_nvar_exist_all_depths/` (12 reports, 12 handoffs, 8 plan
    versions), `specs/359` entry (no directory yet — not started), `specs/369_m1_endpoint_kvE_futPos_supply_break_render_cycle/`,
    `specs/370_m2_defolded_interior_carrier_redesign/`
  - `specs/state.json`, `specs/TODO.md`, `specs/ROADMAP.md`, `specs/errors.json`,
    `specs/literature-index.json`
  - Local literature corpus: `rabinovich_2014` ("A Proof of Kamp's Theorem", LMCS), chunks
    quoted verbatim in `358/reports/11_render-cluster-divergence-audit.md`
  - `git log --oneline` over `Theories/Bimodal/Metalogic/WeakCanonical/Kamp`
- **Artifacts**: this report
- **Standards**: report-format.md, status-markers.md, artifact-management.md, this file

## Project Context

- **Upstream Dependencies**: task 349 (recursive endpoint core), task 357 (obligation-ledger
  threading), task 363/364/367/368 (fiber-consistency and deep-anchor guards, all completed)
- **Downstream Dependents**: `completeness_discrete` (`BXCanonical/Completeness.lean:276`), task
  361/162 (strong-completeness capstone, depends on 358 being sorry-free)
- **Alternative Paths**: none — Chronicle/BXCanonical is the sole active completeness path
  (ROADMAP.md:19-21); the Stavi/EF-games route is explicitly parked off the live path
- **Potential Extensions**: none in scope for this decomposition

## Executive Summary

- **The block-spawn-revise cycle has, as of hours before this research task was dispatched,
  actually just been broken** by task 370 (`m2_defolded_interior_carrier_redesign`,
  `[COMPLETED]`), which correctly diagnosed and fixed the root cause: a lossy fold
  (`igFoldBit`, `InteriorGateGeneralK.lean:318-332`) that projected the arity-4 fiber the proof
  needs down to a 1-type, making the σ-realizer structurally unrecoverable from the carrier
  content available at the interior anchor. Three consecutive 358 dispatches (v07/Phase 4,
  v08/render-adjudication, v09/Crux-A) each assumed a different route around this same
  circularity and were each machine-refuted; task 369 adjudicated the underlying "M1" firing
  route as REFUTED (high confidence), and task 370 built the correct fallback — a parallel
  non-folded arity-4 carrier ("M2") — landing it sorry-free without breaking any frozen defeq.
- **This is exactly the wrong-API diagnosis the user suspected, confirmed against Rabinovich
  2014**: the paper never folds — it carries the full ordered bracket sequence
  `[α0,β1,α1,…,βn,αn]` and fires witnesses directly off `Until`/`Since` formulas (Lemma 5.3, Cor
  5.4(1)⇐, quoted verbatim in `358/reports/11`). The pre-370 `igFoldBit` carrier was the
  divergence from the source; M2 removes it. The current (post-370) carrier design is
  Rabinovich-faithful; no further architectural rewrite is indicated.
- **Two live sorries remain, deliberately out of scope for task 370**:
  `KampPrior.lean:519` (the `n=1`, `k≥2` residual arm — the genuine open mathematics, Rabinovich
  Cor 5.4 general-`k` `F_i`-chain converter) and `:522` (the `n≥2` arm, explicitly off the main
  theorem's critical path since it only needs `n∈{0,1}`). Task 358's own state.json
  `blocked_reason` (citing a dependency on task 369) is now **stale**: 369 was adjudicated and
  370 (369's successor) landed and unblocked 358 (`370`'s `completion_summary`: "Unblocks task
  358"), but 358's status was not updated to reflect this before this research task ran.
- **Task 358 as currently planned (8 plan versions, v02-v09, 12 reports, 12 handoffs) should be
  superseded, not further revised.** Its plan chain predates the M2 landing and is written
  against an interface (the folded carrier) that no longer needs to be worked around. Recommend
  closing out 358's history and opening a small, freshly-scoped successor task against the
  landed M2 assets (`kampPrior_hreal_supply`, the `*Fib` sibling chain,
  `kampPrior_site_rungKFib_gate_match`) to retire `:519`, plus a second small task (or a second
  phase of the same task) to resolve `:522`.
- **Refactor-first is the right order only for `SharedWitness.lean` (task 341), not for the
  files still central to the open mathematics.** `SharedWitness.lean` (12,800 lines, confirmed
  live) is file-disjoint from the entire `KampPrior.lean`/`InteriorGateGeneralK.lean` chain that
  carries the actual open proof content; task 341 already has a thorough, current, 41-phase plan
  (v02, dated 2026-07-12, and independently re-verified here — the 12,800-line figure matches a
  fresh `wc -l`) and can be dispatched as-is, in parallel with the math work, with zero
  sequencing risk. Refactoring `InteriorGateGeneralK.lean` (2,342 lines, just grew via the M2
  sibling chain) or `KampPrior.lean` (1,919 lines) now, before `:519`/`:522` are retired, would
  risk re-treading the exact instability that task 370 just settled.
- Task 359 (Boneyard hygiene) remains correctly scoped (2 live non-Boneyard imports into
  `Boneyard/` confirmed present via a fresh grep) but is gated on task 303, which itself has an
  already-designed, cheap 2-phase "subsumption closure" plan (v19) ready to dispatch.

## Context & Scope

This is a meta/decomposition task: no `.lean` files were edited. The investigation covered (1)
the full artifact history of tasks 341, 358, 359 and their spawned dependents (363, 364, 367,
368, 369, 370), (2) a first-hand inventory of the Kamp Lean source (file sizes, sorry sites,
import structure), and (3) literature grounding against Rabinovich 2014's actual proof structure
as already excerpted in the codebase's own H4/H5 audit trail. The goal is a concrete task list,
not new proof content.

## Findings

### F1 — Current sorry inventory (first-hand, `KampPrior.lean`)

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` is 1,919 lines. Exactly two live
  `sorry`s remain in the file (confirmed by direct read, not by stale task-description line
  numbers, which cite the historical `:361`/`:364`):
  - **`:519`** — inside `nf_nvar_exist_all_depths`, case `n = 1`, sub-match `| _k + 2 =>` (i.e.
    the `n=1`, `k≥2` residual). Comment at `:506-518` explicitly assigns this to "task 358
    territory" and forbids discharging it without the general-k machinery
    (`endInterval_correct`, the `kvE2Ext`/`kvExt` gate stack, the Phase-16 `ExistProviders`
    shim). This is the **sole genuinely open mathematical content**: Rabinovich Cor 5.4's
    general-`k` `F_i`-chain converter (ROADMAP.md:77).
  - **`:522`** — case `n + 2` (`n≥2` generally), commented "off the critical path" since
    `completeness_discrete` only invokes `n∈{0,1}`. Provable-or-restatable rather than a genuine
    proof obligation.
- Both sorries are corroborated by task 370's own scope declaration: its plan
  (`370/plans/01_defolded-carrier-option-b.md`) states "`KampPrior:519/522` out of scope", and its
  `completion_summary` states "Out-of-scope pre-existing `KampPrior:519/522` sorries untouched by
  design."

### F2 — The block-spawn-revise cycle, diagnosed to its root cause

Task 358's artifact trail is the clearest evidence of the cycle the user described:

- **8 plan versions** (`plans/02` through `plans/13`, versions v02-v09 embedded in filenames:
  `realizer-recursion-implementation`, `post-360-gap-closure`, `realizer-recursion-v04/v05`,
  `deep-anchor-rekey-v06/v07`, `render-first-resequence-v08`, `crux-first-interior-realizer-v09`).
- **12 reports** including **5 separate spawn-analyses** (reports 05, 07, 09, 10, 12) — each
  spawn-analysis is itself evidence of a dispatch that hit a wall and needed a new task to clear
  it.
- **12 handoffs** across phases 1-8, several duplicated per phase (`phase-2-handoff`,
  `phase-2-v05-handoff`, `phase-2-v06-handoff`) — the same phase re-attempted under revised
  plans.
- The **H5 divergence audit** (`358/reports/11_render-cluster-divergence-audit.md`) reconstructs
  the shared root cause across the three most recent dispatches in a table (v07/Phase 4,
  v08/render-adjudication, v09/Crux-A): each assumed the σ-realizer (or its firing, or the
  "render") was recoverable from carrier content exposed at the interior anchor `w`, and each was
  machine-refuted by tracing the actual lemma dependency graph:
  - `igFoldBit_realize_iff` (`InteriorGateGeneralK.lean:563`) requires the render as a
    hypothesis.
  - The sole landed producer of `kvE_futPos`, `kvE_futPos_of_realizer`
    (`ExteriorPinnedConverseK.lean:252`), requires the σ-realizer itself as a hypothesis.
  - Both routes are circular: `render → hreal → render`, `firing → realizer → firing`.
- **Root cause (F1-lossy-fold)**: `igPtW@w` (`InteriorGateGeneralK.lean:243`) and the endpoint
  firings `igEpR@t`/`igEpL@x` (`:209`/`:219`) all read `qnf.2` through `igFoldBit`
  (`:318-332`), which folds the full arity-4 fiber `σ : NF sig k 4` down to a 1-type
  `(zone, nfk_projFresh sub)`. No hypothesis available at the interior anchor carries enough
  information to reconstruct `σ`; the cycle has **no external base** (358/reports/11 §Postmortem).
- **Literature check (Q3 in the audit, corroborated independently here)**: Rabinovich's actual
  induction (Lemma 5.3, chunk_0014) and Cor 5.4(1)⇐ (chunk_0015) never fold — the induction
  carries the full ordered bracket sequence `[α0,β1,α1,…,βn,αn]` and the future witness `y2` is
  extracted directly from the `Until` formula's temporal semantics (quoted: "there is `y2 > y1`
  such that `y2` satisfies `αn+1`"). The paper's route matches the shape of the carrier's
  endpoint firings (`igEpR@t = Until(charK χ, top)`) **only without the fold**. This confirms:
  the pre-370 `igFoldBit` design was the actual divergence from the published proof, and it is
  precisely what made three independent dispatches converge on the same circularity.
- **Resolution (already landed)**: task 369 (`m1_endpoint_kvE_futPos_supply_break_render_cycle`,
  `[COMPLETED]`) ran the bounded feasibility adjudication the audit demanded and REFUTED the "M1"
  fix (upgrading the 1-type firing to an arity-4 witness using only the syntactic EF-closure
  guard) at high confidence — the fold loses information no available hypothesis can restore.
  Task 370 (`[COMPLETED]`, 8 phases, git log `286d4f7e3`…`d8375b30d`) then built the "M2" fallback:
  a **parallel non-folded arity-4 carrier** (`bracketEndChar_kvFib` and its `*Fib` sibling chain)
  re-proving the full correctness chain **without** breaking the frozen `bracketEndChar_kv`
  defeq bridge (`CarrierKv.lean:246-249` / `InteriorGateGeneralK.lean:339-351`), and discharged
  its own two target leaves — `kampPrior_hreal_supply` (`InteriorHrealSupplyK.lean:116`) and
  `kvE_hexclDeep{Fut,Past}_supply` (`ExteriorDeepExclSupplyK.lean:105/133`) — sorry-free. Its own
  Phase 7 hit an apparent block that a hard-mode divergence audit (H5) refuted as mis-scoped
  (the endpoint evals were in scope but simply unpassed to the binder) — a second, smaller
  instance of the same pattern, resolved within the same task rather than spawning further.
- **State drift**: `specs/state.json`'s `358` entry still carries `"status": "blocked"` with a
  `blocked_reason` naming task 369 as the dependency, `last_updated: 2026-07-15T02:49:55Z` — this
  predates task 370's completion (`last_updated: 2026-07-15T08:41:22Z`, whose own
  `completion_summary` explicitly states "Unblocks task 358"). **This status has not been
  refreshed.** No state.json edit is made by this research task per its read-only mandate; the
  recommendation below addresses it explicitly.

### F3 — Task 341 (SharedWitness structural refactor): file-disjoint, already well-planned, current

- `NfMultiAnchorBridge/SharedWitness.lean` measured at **12,800 lines** (fresh `wc -l`, matching
  the figure task 341's own report 03 measured at HEAD `775b89db7` on 2026-07-12 — the plan is
  not stale).
- Task 341's plan (`341/plans/02_module-split-refresh.md`, synthesized from a 3-teammate team
  research round, `341/reports/03_refactor-strategy-evaluation.md`) is thorough: privatize-346
  leaked-public-symbols first, then a verified-acyclic 10-module + hub split (41 phases, ≤500
  lines/phase, each ending in a green `lake build`), with an explicit Green-Preservation
  Contract (axiom check, scoped-then-full build, LITMUS anchor, import-equivalence and
  downstream-unchanged tripwires, sorry/admit tripwire).
- **Confirmed file-disjoint from the open mathematics**: `grep -c kvE2_sep` = 0 in
  `NavigatedEndChar.lean`/`Lemma32Reduction.lean`/`Base.lean` (341's own report), and
  `SharedWitness.lean` imports only `{SubBracket2V, NavigatedSpine}` — it shares no file with
  `KampPrior.lean`, `InteriorGateGeneralK.lean`, `ExteriorGateAssembleK.lean`, or any of the
  files task 370 just touched. There is **no dependency in either direction** between 341 and
  the remaining `:519`/`:522` work.
- Task 341's dependencies (335, 337, 340, 346) are all `[COMPLETED]` per state.json; it is
  `[PLANNED]` and ready to dispatch via `/implement 341` with no further research or revision
  needed.

### F4 — Task 359 (Boneyard hygiene): correctly scoped, gated on task 303

- Fresh grep confirms exactly **2 live (non-Boneyard) imports into `Kamp/Boneyard/`**:
  `Prop43.lean` and `NfMultiAnchorBridge/NavigatedEndChar.lean` — matching 359's description
  ("~3 remaining live imports... via Prop43 and NavigatedEndChar") closely enough that the
  description's own instruction ("verify the exact set at implementation time") is the right
  call, not a re-scope.
- `Boneyard/` currently holds 18 files, 5,064 lines — a real archive, not empty.
- 359 depends on task 303 (`k_gt_0_depth_induction`), which is `[PLANNED]` (not archived,
  contrary to an initial assumption from its presence in `specs/archive/` naming — that was a
  different, unrelated directory listing artifact; 303's actual entry lives in the active
  `specs/state.json`/`TODO.md`, not `specs/archive/`). Task 303 carries **19 report/plan
  artifacts** of its own churn history, but its most recent plan
  (`303/plans/19_subsumption-closure-plan.md`) already resolved the churn: report 10
  (`blocker-resolution-path.md`) found 303's original blocker (`PriorComposition.lean` sorries)
  is **subsumed** — those sorries are already off the live path, archived to Boneyard by task
  305 Phase 0. Plan v19 is a cheap, 2-phase, **zero-Lean-proof-dispatch** closure: delete three
  retired Boneyard files and confirm green build, then write a closure note. It explicitly
  prohibits any further `nvar_transfer`/cross-structure/zone-3 proof work.
- **Recommendation carried into the decomposition below**: dispatch 303's existing v19 plan
  as-is (no revision needed) to close it out, which then unblocks 359 with no further research.

### F5 — Kamp source inventory (sizes, for the refactor-first question)

| File | Lines | Note |
|---|---|---|
| `NfMultiAnchorBridge/SharedWitness.lean` | 12,800 | task 341 target; file-disjoint from open math |
| `NfMultiAnchorBridge/InteriorGateGeneralK.lean` | 2,342 | central to `:519`; just grew via M2 `*Fib` chain |
| `NfMultiAnchorBridge/CarrierK1V.lean` | 2,216 | carrier trio; naming-smell noted by 341 Angle B, out of scope for 341 |
| `NfMultiAnchorBridge/AggregateHookDischarge.lean` | 2,172 | not on the open-math critical path |
| `NfMultiAnchorBridge/SubBracket2V.lean` | 2,160 | frozen by task 349 |
| `NfMultiAnchorBridge/Base.lean` | 2,076 | carrier trio |
| `Kamp/KampPrior.lean` | 1,919 | the two live sorries |
| `NfMultiAnchorBridge/AggregateOffDiagK1.lean` | 1,540 | — |
| `Kamp/NfDepth0Generalized.lean` | 1,772 | — |
| `Kamp/ExteriorNegation.lean` | 1,735 | — |

`Boneyard/` totals 5,064 lines across 18 files (a permanent archive, per task 359's own
description — never emptied). No file besides `SharedWitness.lean` is large enough, on its own,
to justify a dedicated structural-refactor task ahead of finishing the open mathematics; the
carrier-trio naming smells (`Base.lean`/`CarrierK1V.lean`/`CarrierKv.lean`, opaque `*cex`
abbreviations, `endChar*` vs `bracketEndChar_*` naming inconsistency) were already identified and
explicitly deferred by task 341's own Angle B findings to "a candidate for a new sibling task,"
not urgent.

### F6 — `errors.json` and roadmap cross-check

- `specs/errors.json` contains exactly one entry, unrelated to the Kamp effort (a stale
  `delegation_interrupted` entry for task 98 from 2026-04-11). No recorded error pattern is tied
  to 341/358/359 — the churn evidence lives entirely in the task artifacts themselves (handoffs,
  divergence audits), not in the error log.
- `specs/ROADMAP.md`'s "Current state" section (dated 2026-07-12, i.e. **before** task 370
  landed) already names `:361`/`:364` (the pre-renumbering line numbers for what are now
  `:519`/`:522`) as "the sole live blocker" and states "everything else... is sorry-free" — this
  matches the F1 finding exactly and should be refreshed to reflect task 370's completion.

## Decisions

1. **Do not recommend a further architectural rewrite of the interior/exterior carrier.** Task
   370 already performed the literature-grounded fix (de-folded parallel carrier, Rabinovich
   Cor 5.4/Lemma 5.3-faithful) and it landed sorry-free without breaking any frozen defeq. The
   remaining work is finishing two specific proof obligations against the now-correct
   architecture, not another redesign.
2. **Task 358 should be closed out and replaced, not revised again.** Its 8-version plan chain is
   written against the pre-M2 interface and would need a near-total rewrite to reference the
   landed `*Fib` assets; a fresh, narrowly-scoped task is lower-risk than a 9th `/revise`.
3. **Task 341 requires no revision — dispatch as-is.** Its plan is current, thorough, and
   provably disjoint from the remaining mathematics; refactor-first applies cleanly to it and to
   it alone among the three named tasks.
4. **Task 359 requires no revision — its blocker (task 303) has an existing, cheap closure
   plan.** Recommend dispatching 303's plan v19 to unblock it, in preference to any further
   research on 303 or 359.
5. **`InteriorGateGeneralK.lean` and the carrier trio should NOT be refactored before `:519`/
   `:522` land.** They are still actively settling (M2 just added a parallel sibling chain to
   `InteriorGateGeneralK.lean`); a structural split now would fight the same frozen-defeq
   constraints task 370 was careful to respect and risks re-opening exactly the kind of
   instability the last several weeks were spent resolving. Revisit file-splitting for this
   directory only after `completeness_discrete` is fully sorry-free.

## Recommendations

### Verdicts on the three named existing tasks

| Task | Verdict | Rationale |
|---|---|---|
| **341** (SharedWitness refactor) | **Leave as-is; dispatch via `/implement 341`** | Plan v02 current, thorough, 41 phases already H8-sized (≤500 lines/phase); file-disjoint from all open mathematics; all dependencies COMPLETED |
| **358** (realization recursion) | **Supersede — mark `[ABANDONED]` or close via a short revision that hands off to two successor tasks (below), rather than a further `/revise`** | Blocked status is stale (369's successor 370 already unblocked it); its plan chain predates the landed M2 assets; continuing to revise the same plan chain repeats the churn pattern the user asked to break |
| **359** (Boneyard hygiene) | **Leave as-is; unblock by dispatching task 303's existing plan v19 first** | Scope independently re-confirmed accurate (2 live imports found); its only blocker has a ready, cheap closure plan |

### Proposed new/successor tasks under `kamp_theorem_formalization`

**Task A — "Retire KampPrior.lean:519 (n=1, k≥2 residual) via the M2 Fib-carrier assets"**
- **Scope**: Discharge the sole remaining genuine proof obligation — the general-`k` Rabinovich
  Cor 5.4 `F_i`-chain converter — using the now-landed `kampPrior_hreal_supply`
  (`InteriorHrealSupplyK.lean`), the `*Fib` sibling carrier chain, and
  `kampPrior_site_rungKFib_gate_match` (all from task 370). This supersedes task 358; do not
  resume 358's plan v09 (`crux-first-interior-realizer`) — it targets an interface task 370 has
  since replaced.
- **task_type**: `lean4`
- **Dependencies**: 370 (`[COMPLETED]`) — no other open dependency
- **Size**: medium (previously "high" under the folded carrier; the hard part — the carrier
  redesign — is already done; this is consuming already-built infrastructure to close one
  induction arm)
- **Dispatch flags**: `--hard --lit` — hard mode for the anti-analysis/wrap-up discipline given
  this lineage's history of analysis-heavy dispatches; `--lit` to keep citations pinned to
  Rabinovich PDF pages (per the codebase's own `md:NN`-citation-hazard convention, task 341's
  description) rather than reintroducing stale line-based citations.

**Task B — "Resolve KampPrior.lean:522 (n≥2 arm)"**
- **Scope**: Either (a) prove the general `n≥2` case using Task A's landed assets (likely a short
  corollary once the general-`k` converter exists), or (b) restate `nf_nvar_exist_all_depths` so
  the recursion signature only requires `n∈{0,1}` at the call sites `completeness_discrete`
  actually uses, formally removing the need for an `n≥2` branch. Adjudicate (a) vs (b) as a first
  bounded step before committing to either.
- **task_type**: `lean4`
- **Dependencies**: Task A (needs its assets for route (a); independent of it for route (b), but
  sequencing after A avoids duplicated adjudication work)
- **Size**: small — explicitly off the critical path; low effort either way
- **Dispatch flags**: `--lit` optional; `--hard` not needed (small, well-bounded)
- **Sequencing note**: if Task A's dispatch has spare phase budget, fold Task B in as a second
  phase of the same plan rather than a separate task — do not over-fragment a small residual
  arm. Split into a separate task only if Task A's own scope already fills one agent run.

**Task C — "Kamp completeness_discrete final assembly and axiom audit"**
- **Scope**: Once Tasks A and B land, confirm `completeness_discrete`
  (`BXCanonical/Completeness.lean:276`) is fully sorry-free; run `lean_verify` across the full
  dependency chain (`nf_nvar_exist_all_depths` → `nf_characterizable_temporal_prior` →
  `kamp_prior_expressive_completeness` → `US_expressively_complete_over_prior`) confirming axioms
  are exactly `{propext, Classical.choice, Quot.sound}`; refresh `ROADMAP.md`'s "Current state"
  section (currently dated 2026-07-12, pre-370) to reflect the landed state.
- **task_type**: `lean4`
- **Dependencies**: Task A, Task B
- **Size**: small (verification + documentation, not new proof content)
- **Dispatch flags**: standard (no `--hard`/`--lit` needed — this is a verification pass)

**Task D — "Dispatch task 303's subsumption-closure plan (v19)"**
- **Scope**: Run the existing 2-phase plan v19 as written: delete the three retired
  Boneyard-superseded files (`PriorComposition.lean`, `PriorComposition_old.lean`,
  `KampBypassK1.lean`), confirm green build, write the closure note. No proof work.
- **task_type**: `lean4`
- **Dependencies**: none additional (305, its actual dependency per plan v19's entry gate, is
  already complete per the roadmap's Boneyard note)
- **Size**: trivial
- **Dispatch flags**: standard `/implement 303` (plan already exists — no `/plan` or `/research`
  needed)
- **Note**: this is not a new task — it is a recommendation to finally dispatch 303's existing,
  fully-designed plan rather than continue treating it as blocked/pending.

**Task 359** (existing, unchanged): dispatch after Task D closes 303.

**Task 341** (existing, unchanged): dispatch any time; fully independent of A/B/C/D.

### Ordering summary

```
Task A (retire :519) ─┬─▶ Task B (:522) ─▶ Task C (assembly + axiom audit)
                       │
Task D (303 v19 closure) ─▶ Task 359 (Boneyard hygiene)

Task 341 (SharedWitness split) ── fully parallel to all of the above
```

Each of A, B, C, D is sized to complete within roughly one agent run (H8-style phase sizing);
341 is already internally phased at ≤500 lines/phase across its own 41-phase plan.

## Risks & Mitigations

- **Risk**: Task A's "medium" size estimate could be optimistic if the general-`k` `F_i`-chain
  converter turns out to need more than the landed M2 assets (e.g. if `kampPrior_hreal_supply`'s
  case split does not generalize past the specific zones task 370 handled).
  **Mitigation**: scope Task A's first phase as a bounded feasibility check (mirroring task 369's
  own adjudication discipline) before committing to full proof construction; if refuted, spawn a
  narrowly-scoped follow-up rather than re-opening the carrier design.
- **Risk**: Marking 358 `[ABANDONED]` could look like discarding its real findings (the H5
  divergence audit, the root-cause diagnosis) which are genuinely valuable.
  **Mitigation**: Task A's description should explicitly cite `358/reports/11` and the
  `phase-5-crux-a-handoff` as grounding — the findings are preserved by reference, only the
  now-obsolete plan chain is superseded.
- **Risk**: `specs/state.json`'s 358 entry still says `blocked_reason: "Depends on task 369"`,
  which is stale (369 → 370 chain already resolved). If left uncorrected, a future `/research
  358` or `/orchestrate 358` could re-derive the same stale blocker.
  **Mitigation**: whoever performs the actual task revision (this research task does not edit
  state.json) should update 358's status/blocked_reason or supersede it with Tasks A-C
  immediately, before any further dispatch against 358 itself.
- **Risk**: Refactoring `InteriorGateGeneralK.lean` is tempting given its size (2,342 lines,
  larger than `KampPrior.lean` itself) but doing so before A/B land could re-destabilize a
  carrier design that only just settled.
  **Mitigation**: explicit Decision 5 above defers any split of this file until after Task C.

## Appendix

- Rabinovich, A. (2014). *A Proof of Kamp's Theorem*. Logical Methods in Computer Science, vol.
  10. Local corpus `doc_id: rabinovich_2014` (`specs/literature-index.json`); Lemma 5.3 and Cor
  5.4(1)⇐ quoted verbatim in `358/reports/11_render-cluster-divergence-audit.md`.
- Key file paths cited throughout: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
  (:505-522), `.../NfMultiAnchorBridge/InteriorGateGeneralK.lean` (:209/219/243/318-332/563),
  `.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean` (:337-338/395-427),
  `.../NfMultiAnchorBridge/ExteriorPinnedConverseK.lean` (:252),
  `.../NfMultiAnchorBridge/InteriorHrealSupplyK.lean` (:116),
  `.../NfMultiAnchorBridge/ExteriorDeepExclSupplyK.lean` (:105/133),
  `.../NfMultiAnchorBridge/PriorInterface.lean` (:38-46),
  `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (:276).
- git history reviewed: `286d4f7e3`..`d8375b30d` (task 370's 8 phases),
  `bd1e92bd7`/`a46791a8f` (task 358 Phase 5 / task 369 Phase 0, predecessors).
- Task artifact directories consulted in full:
  `specs/341_structural_refactor_sharedwitness_carrier_layer/`,
  `specs/358_realization_recursion_nf_nvar_exist_all_depths/`,
  `specs/369_m1_endpoint_kvE_futPos_supply_break_render_cycle/`,
  `specs/370_m2_defolded_interior_carrier_redesign/`, plus state.json entries for 341/358/359/303.
