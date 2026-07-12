# Discrete-Completeness Proximate Restructuring — Synthesis & Recommendation

**Date:** 2026-07-12 · **Session:** sess_1783841542_df767b
**Inputs:** `01_discrete-completeness-finish-map.md` (Angle 1, authority on liveness), `02_proximate-restructuring-needs.md` (Angle 2, restructuring), 349 report 05 (faithful endChar architecture).

> **CORRECTION (2026-07-12, superseded in part by `03_routeA-feasibility-audit.md`):**
> §2's "two competing routes / endChar off the critical path / Route A highest-leverage"
> framing is **WRONG** and is retracted. The Route-A feasibility audit (report 03) proved
> **Route A depends on endChar**: the n=1 arm (`KampPrior.lean:361`) is depth-recursive and its
> arm-`_correct` lemmas are endChar-parametric (`seg endChar`, Base:1128/1152) with zero
> dischargers; the 349/350→309 dependency is REAL; 348's gate is only the k=2 rung. **endChar
> (task 349) is the single shared bottleneck for finishing discrete completeness.** Wave-1
> restructuring (§3) is unaffected and still valid. The corrected finish path is
> **349 (faithful revise, report 05) → 350 → 309 Phases 18–19 → retire n+2 arm → task 95 audit.**

## 1. The reconciled finish line (authoritative)

`completeness_discrete` **still carries `sorryAx`** (verified via `lean_verify`). Its live proof-term spine:

```
completeness_discrete            (BXCanonical/Completeness.lean:336)
 → countermodel_discrete_reynolds_v2   (IntegerModel/ReynoldsBridge.lean:724)
 → limitdom_is_good                     (:346)
 → no_gaps_discrete_model_surgery       (GoodStructuresModelSurgery.lean:2133)
 → US_expressively_complete_over_prior  (PriorExpressiveness.lean:346)
 → kamp_prior_expressive_completeness   (KampPrior.lean:490)
 → nf_characterizable_temporal_prior    (:407)
 → nf_nvar_exist_all_depths             (KampPrior.lean:212)   ← THE SOLE ON-PATH SORRY
```

**Exactly ONE declaration blocks the proof:** `nf_nvar_exist_all_depths` (KampPrior.lean:212), two match arms — `:361` (n=1) and `:364` (n+2). ~40 sorries exist in the tree; **only these 2 arms are on the proof-term path.** All others are off-path, each self-annotated dead/deprecated/dense-only/non-critical.

**Sorry-count correction:** the `NfMultiAnchorBridge/` subtree (Base, CarrierK1V, SharedWitness, NavigatedEndChar) is **sorry-free** — the "23/12/5/2 sorries" some greps report are docstring prose (0 real tactic sorries, verified).

**Finish line:** `completeness_discrete` goes green **iff** (A) the n=1 arm (:361) is discharged, (B) the n+2 arm (:364) is retired (restate the def to restrict domain to n≤1 — it's unreached but taints the axiom audit), (C) re-run `#print axioms` (task 95).

## 2. Two competing routes to the ONE obligation

| | Route A — 348/309 | Route B — 351/349/350 (endChar) |
|---|---|---|
| Status | 348 `[completed]` produced discharge material; 309 `[blocked]` Phase 14 is true owner | 351 `[completed]`; 349 endChar (thrice-refuted, needs report-05 revise); 350 quantEndSeg (not in tree) |
| Wiring | via `ExteriorBracket.lean:1069` | `NavigatedEndChar.lean` has **zero importers** — not wired |
| Difficulty | discharge material already exists; unblock-and-wire | hardest path; hit confirmed non-theorem walls; faithful revise uncertain |
| Angle-1 verdict | **"highest-leverage"** — unblocking 309 | independent *alternative* provider, not on critical path |

**Key fact:** the endChar work we have been driving (349/350) is **NOT on the critical path**. It targets the same theorem but as a second, harder, not-yet-wired provider. ROADMAP's "task 303 / KampBypass.lean" finish is **stale** (that file is Boneyard'd).

## 3. Proximate restructuring — prioritized

### Wave 1 — route-independent, high-value, low-risk (do regardless of route choice)
1. **Archive the off-path dead/probe island** (~2,350 lines) → `Kamp/Boneyard/`: NfZoneDepthK1Probe, NfZoneNavProbe, Prop43, NegationIndep, RabinovichTranslation, + the closed VecEA dead-island (VecEA_m, VecEAArityFirewall, EAVecNegationClosure). All confirmed off the default build graph; moving them drops them from `lake build`. Declutters the workspace and removes ~most of the ~40 off-path sorries from the working set.
2. **Fix 3 stale references** that misdirect toward the old finish line: `Completeness.lean:355-367` (audit note naming Boneyard'd KampBypass), `ROADMAP.md:1431-1432` (task-303 "sole sorry"), `Metalogic.lean:32`. Cheap, stops recurring confusion.
3. **Retire the n+2 arm** of `nf_nvar_exist_all_depths` (restrict domain to n≤1). Correctness + clarity; part of finishing regardless of route.

### Wave 2 — proximate but route-dependent (navigability, not sorry-debt)
4. **SharedWitness split (task 341)** — 12,800 lines → 10 modules + hub (strategy already synthesized, ~41 phases). On the import closure; used by ExteriorBracket (Route A's site) and OuterGate. Proximate under either route, but not a finish-blocker.
5. **Base.lean split** — extract the sorry-free Deliverable-1&2 foundation (lines 35–707), wall off the endChar rebuild region (708–1982). Only urgent if Route B stays active.
6. **CarrierK1V 3-way split** — navigability + parallel 349/350 ownership. Only if Route B stays active.

### Deferred / proposal-only
- Frozen files (SubBracket2V 2160, ExteriorNegation 1735) — post-thaw split candidates, no edits now.
- Naming/Mathlib conventions — task 175 (post-thaw).

## 4. Flags to resolve
- `Lemma32Reduction.lean` is on task-349's freeze list yet is **off-path/unreachable from KampPrior** — either a missing live import (bug) or a stale freeze entry. Investigate before relying on it.
- `NavigatedEndChar.lean` (off-path, zero importers) — archivable, but it's the endChar staging ground; hold pending the route decision.

## 4b. BREAKTHROUGH (2026-07-12, `349/reports/07_rabinovich-faithfulness-deep-check.md`)

The v5 Phase-3 feasibility gate BLOCKED, and a primary-source faithfulness audit found the root
cause: **the `endChar` carrier type is UNFAITHFUL to Rabinovich.**
- `EndCharCarrier := NormalForm sig k 3 → TemporalPred` (single-point read at `w`) applies
  Rabinovich Prop 3.5 (precondition: exactly ONE free var, md:137) at TWO free vars `{x,t}`.
- Rabinovich's actual §5 carrier is the **Prop-valued two-endpoint interval formula**
  `[…](z0,z1)` (md:219/225), both endpoints explicit, never read at one point.
- All four strikes (navBrickForm→navMultiAnchorForm→navPieceForm→v5 navPieceForm_correct) are
  the SAME non-theorem re-patched; `h_res` is a Lean artifact with no paper analogue.
- **The faithful carrier already exists green at k=0**: `BracketEndCharCarrier := NormalForm sig
  k 3 → VecEA2 1` (CarrierK1V.lean:52), `{x,t}` explicit endpoints, collapse to `TemporalPred`
  only at the ≤1-free base.
- **Impact**: task 349 must retire the frozen `EndCharCarrier → TemporalPred` / `navPieceForm`
  line (a task-SCOPE change — the frozen-carrier constraint pointed at the wrong primitive) and
  re-base onto `BracketEndCharCarrier`. Preserved: `nfEval_le2_reduction`,
  `nf_zone_flatten_navigable(_correct)`, `seg`, `bracketBuild*`, `endChar0`. Task 350 consumes
  VecEA2 and collapses to `TemporalPred` only at the top-level 1-free extraction; task 309
  collapses once at Theorem 4.4, not per step. Adjudication audit (cycle 8) pending as cross-check.

## 5. Recommendation

1. **Execute Wave 1 now** — it's pure upside, route-independent, and directly answers "systematically restructure/archive the appropriate elements": a ~2,350-line dead-island archival + 3 reference fixes + the n+2 retirement.
2. **Decide the finish route (A vs B)** before committing Wave 2. Angle 1's evidence favors **Route A (unblock task 309, wire the 348 discharge material)** as the highest-leverage finish, with 349/350 endChar demoted to a deferred alternative. This also de-risks: Route B is the thrice-refuted path.
3. Task 341 (SharedWitness) stays valuable under either route but is a navigability win, not a finish-blocker — sequence it after Wave 1 and the route decision.
