# Implementation Plan: Task #368

- **Task**: 368 - Ambient deep-saturation/EF-closure guard against CM-A/CM-B (358 interface refinement, one layer over 367)
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (parent task 358 is [BLOCKED] on this; it resumes via `/revise 358` then `/implement 358` after this lands)
- **Research Inputs**:
  - specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/10_spawn-analysis.md
  - specs/358_realization_recursion_nf_nvar_exist_all_depths/plans/06_deep-anchor-rekey-v06.md (Phase 4 BLOCKER record — the verbatim CM-A/CM-B countermodel definitions)
- **Artifacts**: plans/01_ambient-deep-anchor-guard.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Task 358's Phase 4 is [BLOCKED]: the `igPtW`-guarded ledger rows 5, 6, 10-13 of the
349/357/360/363/367 consumer interface are FALSE AS STATED at m >= 1. Two paper countermodels
sit INSIDE the current antecedent population while defeating the row-13 (CM-A) and row-5 (CM-B)
conclusions. Root cause: `igPtW`/`igFoldBit` and every current antecedent read the ambient's
deep marking `qnf.2` ONLY at profile level (`ZoneSpec 3 x NormalForm sig (m+1) 1` buckets) —
the P17 anchor-content gap, resurfacing one layer over the fiber-side gap task 367 closed.
Task 367 guarded the sigma being TESTED (`kvE_deepOnFiber qnf sigma`); this task guards the
qnf SUPPLYING the marking: an ambient-side deep-saturation/EF-closure guard on `qnf` itself,
m=0-inert, added to the rows-5/6/10-13 binder antecedents and the matching gate-formula
strengthening.

The task follows the PROVEN template of tasks 363, 364, and 367 (all completed against this
same consumer interface) with zero deviation from house style: probe-first (CM-A and CM-B cast
as sorry-free machine certificates over the `ExteriorPinnedProbe358TailK.lean` Z infra BEFORE
any guard definition), guard in a NEW leaf with the `_zero` / `_iff` / `_of_realized` API
family, consumer-binder restatement, exclusion probe certificates, then a full re-probe of the
complete existing certificate inventory at floor axioms `[propext, Classical.choice,
Quot.sound]`. Scope is the INTERFACE ONLY — the G2-B1/B2/B3 supply theorems, `hsigma`
production, and the `KampPrior.lean:519`/`:522` sorry retirements remain task 358's own work.

**Definition of done is the re-probe, not the restated signature**: every phase ends at a
machine-checkable green/refute gate. Zero-debt terminus: no sorry, no vacuous def
(`def X := True` family), no proof forced against a live countermodel. If the guard cannot
land green against BOTH CM-A and CM-B after the one permitted redesign loop, exit `[BLOCKED]`
with a structured escalation record (failing countermodel named, exact goal state, analytical
gap) — never a landed sorry or a weakened probe.

### Research Integration

From the spawn analysis (report 10) and the plan-v06 Phase-4 blocker record:

- **CM-A (kills row 13)**: homogeneous Z model (the `Probe358TailK` infra shape with R = empty,
  single 1-type chi_z), anchors x, w = x+1, t = x+2. Fake ambient: `qnf.1` := the honest
  depth-0 row of `[w,x,t]`; `qnf.2` marks EXACTLY {char[x-1], char[x], char[w], char[t],
  char[t+1]} (each the honest (m+1)-depth 4-type over `[v,w,x,t]`), OMITTING
  sigma := char[t+2,w,x,t] — a deep-incomplete marking dropping char[t+2]'s bucket-mate.
  Profile buckets collapse under the homogeneous type, so `igPtW`, epL/epR, segL/segR
  (vacuous), igOffFiber, and the deep-anchored brackets are ALL satisfied; rows 5, 5a, 6, 10,
  11 hold. But sigma is admissible (realized at x1 = t+2), on-row, bit-false, and
  guard-false (`kvE_deepOnFiber`: its only `.2`-candidate mate char[t+1] differs at an
  order-only depth-1 discrepancy) — **row 13 violated**; the fake qnf's full gate LHS is
  satisfiable while the ambient is never realized.
- **CM-B (kills row 5)**: the `Probe358TailK` tail-doppelganger re-aimed at the AMBIENT: mark
  `sub_g` := the AtW-zoned honest char over a depth-0-indistinguishable, spacing-discrepant
  fake tail sharing the honest `sub_w`'s (AtW, chi_w) bucket. `sub_g` is on-row,
  fiber-consistent (`_of_realized` over the fake tuple), `igPtW`-invisible (same bucket) —
  but `[w,x,t]`-UNREALIZABLE (AtW pins fresh = w; deep content differs from
  char[w,w,x,t].2) — **row 5's conclusion fails**.
- **Circularity finding**: the `igPtW` -> ambient bridge (`hcharK` + `P.correct` +
  `kampPrior_existProviders_of_ih_existF0_char`) CANNOT patch this — "ambient realized at
  `[w,x,t]`" IS (atom row) + rows 5+6+10+11+12+13 themselves. No bridge built from those rows
  can presuppose its own conclusion. The fix must be a syntactic guard on `qnf`.
- **Prescription (binding)**: EF-closure of `qnf.2` — (i) every marked sub's inner fiber
  content re-appears under fresh-rotation as a marked sub (kills CM-A: char[t+1]'s inner
  `[t+2]`-element forces marking sigma); (ii) every marked sub's deep content is anchored to
  the row (kills CM-B: sub_g's misplaced inner couplings violate anchoring). Both casts
  machine-probed FIRST.
- **Literature context** (`--lit`, per-repo sub-index): Rabinovich 2014 "A Proof of Kamp's
  Theorem" and Kamp 1968 are available on demand (`literature-search.sh`); this task is a
  template-driven interface refinement, not a literature transcription — first-principles
  mode applies except where the 358 plan's Rabinovich citations are consulted for context.

### Prior Plan Reference

No prior plan for task 368. The structural template is task 367's completed plan
(`specs/367_deepanchor_exterior_fiber_population_against_taildoppelganger/plans/01_deep-anchor-fiber-guard.md`,
[COMPLETED], 10h, zero redesign loops). Calibration lessons carried over: (i) plan candidate
guard shapes NON-prescriptively and let the probes adjudicate — 367's landed guard was a
synthesis, not the primary paper candidate; (ii) the consumption-site map (Phase 1) is the
authoritative edit boundary and 367's map grew by one file (`ExteriorBracketAssembleK.lean`)
during adjudication — expect the same possibility here and adjudicate the gate-formula
strengthening site list during restatement; (iii) rows 12-13 were ADDED as m=0-vacuous
residue rows during 367's restatement — this task must likewise adjudicate (not presuppose)
whether new guard-false residue rows are needed; (iv) `_of_realized` proven at probe level
at a GENERAL model BEFORE promotion is the load-bearing anti-vacuity move; (v) front-load
the exclusion mechanics; expect elaboration blow-ups over `Finset.univ.toList` at concrete
signatures (`maxRecDepth 8000` / `maxHeartbeats` precedents exist).

### Roadmap Alignment

No roadmap consultation requested (roadmap_flag not set). This task is the sole blocker on
the task-358 critical path (KampPrior live sorries `:519`/`:522` are upstream-blocked on the
rows-5/6/10-13 ambient interface).

## Goals & Non-Goals

**Goals**:
- **Probe-first**: cast CM-A and CM-B as additive, sorry-free machine certificates over the
  `ExteriorPinnedProbe358TailK.lean` Z infra in a NEW probe leaf BEFORE any guard definition —
  certifying both countermodels are LIVE against the current interface (antecedent population
  membership + row-13/row-5 conclusion failure).
- Design (non-prescriptively; probes adjudicate) and land an ambient-side deep-saturation/
  EF-closure guard on `qnf` (working name `kvE_ambientDeepAnchor qnf : Bool`; final name
  adjudicated in-task) in a NEW leaf
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorK.lean`,
  mirroring `ExteriorFiberDeepAnchorK.lean`'s module shape, implementing: (i)
  inner-fiber-content re-appearance under fresh-rotation (kills CM-A) and (ii)
  deep-content-to-row anchoring (kills CM-B).
- Ship the guard with the mandated API family, mirroring `kvE_deepOnFiber`'s:
  an **m=0-inertness lemma** (`_zero`, ideally `rfl`), a **readback lemma** (`_iff`, the ONLY
  sanctioned mate/witness-extraction direction), and an **honest-preservation crux**
  (`_of_realized`) proven at a GENERAL model (anti-vacuity guarantee).
- Restate the guarded antecedents in the consumer binders the blocker names: rows 5, 6, 10-13
  of `EndIntervalConsumerK.lean`, their mirrors in `ExteriorGateAssembleK.lean` and
  `kampPrior_site_rungK_gate_match` (`KampPrior.lean:964-1030`), and the matching gate-formula
  strengthening so the =>-reconstruction can consume the new guard. Adjudicate during
  restatement whether new m=0-vacuous ledger rows for guard-false residue are required (367
  precedent: rows 12-13 were added this way) — do NOT presuppose the row count.
- Land NEW probe certificates in a NEW probe leaf
  (`ExteriorAmbientDeepAnchorProbe358K.lean`, mirroring `ExteriorFiberDeepAnchorProbe367K.lean`)
  certifying: CM-A and CM-B are EXCLUDED by the new guard; honest preservation (a
  general-model realized ambient passes, derived FROM `_of_realized`); and hereditary
  re-plant variants surfaced by an adversarial pass (mirror 367's depth-2 hereditary
  doppelganger and copy-plant checks, re-aimed at the ambient side).
- **Re-probe as the definition of done**: after landing, re-run the CM-A/CM-B probes plus the
  FULL existing certificate inventory (`kvE_probe367_*` x4, `kvE_probe364_*` x4,
  `kvE_probe363_*` x3, `kvE_probe358_*` x3 as the description's named minimum, PLUS the full
  prior-GO sweep 367 Phase 5 executed: 363's 9, 364's 11, the M1 residuals) at floor axioms
  `[propext, Classical.choice, Quot.sound]`, no sorryAx.
- Write `.orchestrator-handoff.json` recording the final guard shape (it dictates the
  discharge terms task 358's re-keyed Phases 4-8 must construct) and the explicit next action
  `/revise 358` then `/implement 358`.

**Non-Goals** (scope boundary — explicit, binding; this task refines the INTERFACE ONLY,
exactly as 367 did):
- MUST NOT build the G2-B1 (rows 12-13 supply), G2-B2 (uniqueness kernel), or G2-B3
  (rows 10-11 supply) theorems themselves — only the guard/antecedent restatement they will
  consume.
- MUST NOT touch `kampPrior_hreal_supply`/`kampPrior_hexcl_supply` (task 358 Phase 5/6,
  `hsigma` production) or the converter-seam discharge.
- MUST NOT retire the `KampPrior.lean:519` or `:522` sorries (task 358 Phase 7/8 arm
  rewrites) — those remain live and are task 358's responsibility after this task unblocks
  the interface.
- **PRESERVE BYTE-FOR-BYTE** (frozen, do not edit, do not re-derive):
  - `ExteriorFiberConsistencyK.lean`, `ExteriorFiberConsistencyProbeK.lean`,
    `ExteriorFiberConsistencyProbe364K.lean` (tasks 363/364)
  - `ExteriorFiberDeepAnchorK.lean`, `ExteriorFiberDeepAnchorProbe367K.lean` (task 367)
  - the m=0 `_zero` kernel family (`ExteriorPinnedConverseK.lean`/`ExteriorPinnedConversePastK.lean`)
  - the k<=1 rungs (`kampPrior_case1_arm_k0`, `kampPrior_case1_arm_k1`)
  - task 360's m=0 supply
  - task 358 Phase 3's landing `NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean`
    (`kvE_hsliceFut_supply`/`kvE_hslicePast_supply`, `kvE_deepMate_collapse`,
    `kvE_{fut,past}SliceEq_refl`) — ambient-realization-guarded, explicitly documented to
    survive ambient-side strengthening; must NOT be re-derived, weakened, or discarded
  - `ExteriorNegationK.lean`/`ExteriorNegationPastK.lean`,
    `ExteriorConverterK.lean`/`ExteriorConverterPastK.lean` (363/364 guard + converter families)
  - `ExteriorPinnedProbe358K.lean`, `ExteriorPinnedProbeM1K.lean` (historical regression
    records). `ExteriorPinnedProbe358TailK.lean` statements stay byte-stable; a
    docstring-only supersession note is permitted (367 precedent).
- **NEVER UNFOLD THE GUARD DIRECTLY** (binding; matches task-358's GLOBAL ROUTING
  CONSTRAINT): all consumption of the new guard, and of every prior guard it composes with
  (`kvE_deepOnFiber`, `kvE_fiberElemConsistent`/`kvE_fiberConsistent`,
  `kvE_futAdmissible`/`kvE_pastAdmissible`), MUST route through byte-stable lemmas only
  (`_of_realized`, `_zero`, `_iff`, `_row`/analogues). A source scan for
  `rw`/`unfold`/`simp only` on any of these guard names outside their home modules must show
  zero occurrences (machine gate, Phase 6).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CM-A's live-countermodel cast requires certifying semantic sibling rows (5/5a/6/10/11) for the fake qnf over the concrete Z model — potentially heavy `igPtW`/bracket evaluations at a concrete signature | H | M | Cast the MINIMAL machine core (367/358TailK precedent): certify (a) sigma's population membership (admissible + on-row + bit-false + `kvE_deepOnFiber`-false) and (b) sigma's realization at x1 = t+2 — i.e. the row-13 statement instantiated at the fake qnf is refuted by explicit witnesses; record the sibling-rows-hold argument (profile-bucket collapse under the homogeneous type) in the leaf docstring as the analytical closure, mechanizing finite proxies where feasible (the exact 358TailK division of labor) |
| The two EF-closure conjuncts ((i) fresh-rotation re-appearance, (ii) deep-content-to-row anchoring) cross depth/arity offsets — a naive formulation does not typecheck (367 Risk-2 one layer up: `qnf : NormalForm sig (m+2) 3` marks `sigma : NormalForm sig (m+1) 4` whose `.2` marks fibers at arity 5) | H | M | Phase 2 designs the comparison form explicitly and non-prescriptively; 367's lesson: full-`.2`-equality-style mate conditions at the type `qnf.2` already marks avoid slot-drop operations entirely and are hereditary by construction. Candidate forms recorded in the leaf docstring; probes adjudicate |
| Honest-preservation crux (`_of_realized`) fails for the chosen shape — the guard demands marked-set completeness/anchoring that a realized ambient cannot discharge | H | M | Phase 3 proves `_of_realized` at PROBE level (general M, general env) BEFORE any production edit, mirroring `kvE_deepOnFiber_of_realized` (mate = the item itself under realization; `qnf`'s own quant layer supplies membership). If the primary shape fails, ONE redesign loop (churn cap), then [BLOCKED] |
| Guard shape kills CM-A/CM-B but is defeated one MORE layer down (hereditary re-plant; the 363 -> 364 -> 367 -> 368 escalation pattern) | H | H | The guard MUST be hereditary (full depth, not one extra level); Phase 4 includes the mandatory depth-2 hereditary doppelganger and content-copying plant re-aimed at the ambient, machine-adjudicated BEFORE promotion; a defeat forces the one redesign loop, never a "good enough" landing |
| Binder restatement propagates beyond the mapped sites — rows 5/6/10-13 binder types are verbatim copies threaded through `ExteriorGateAssembleK.lean`, `kampPrior_site_rungK_gate_match`, and possibly the gate/bracket FORMULA (367's map grew by `ExteriorBracketAssembleK.lean` mid-flight) | H | H | Phase 1 builds the authoritative consumption-site map (bounded read budget; recorded in the probe-leaf docstring), classifying statement-touching vs proof-script-only. Phase 5 confines statement edits to mapped sites; any statement edit needed in a FROZEN file is a scope alarm: stop, restore snapshot, escalate |
| m=0 discharge breakage: frozen task-360 m=0 supply and k<=1 rungs must discharge the restated binders unchanged | H | M | The guard ships with `_zero` (`rfl`-cheap m=0 inertness, mirroring `kvE_deepOnFiber_zero`); m=0 sites repaired proof-script-level through the `_zero` adapter only; any new guard-false residue rows must be m=0-VACUOUS by the same adapter |
| Phase-3 banked supply (`ExteriorDeepSliceSupplyK.lean`) breaks under the restatement | H | L | It is ambient-realization-guarded and documented to survive ambient-side strengthening (its antecedent only gains strength). It is in the frozen set; Phase 6's diff audit verifies byte-identity; a needed edit there is a scope alarm (stop, restore, escalate) |
| Elaboration blow-up: `Finset.univ.toList` over `NormalForm` instances at concrete signature, plus a homogeneous model with LARGER marked sets (CM-A marks 5 subs) | M | M | Reuse landed mitigations: symbolic-membership routing (`kvE_nf_mem_univ_toList`), `set_option maxRecDepth 8000`, `maxHeartbeats` bumps where precedented, scoped `lake build` per module, `lean_multi_attempt` before edits |
| Frozen-layer drift | H | L | `git-snapshot.sh` before the production phase; per-phase green commits; Phase 6 runs an explicit `git diff --name-only` audit against the frozen list |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel (Phases 3 and 4 both consume Phase 2's
adjudicated candidate and touch disjoint probe-leaf sections).

---

### Phase 1: Baseline freeze, consumption-site map, CM-A/CM-B live-countermodel probe casts [COMPLETED]

**Goal**: PROBE-FIRST, per the binding task order: before any kernel/guard change, cast CM-A
and CM-B as additive, sorry-free machine certificates over the `ExteriorPinnedProbe358TailK.lean`
Z infra, certifying both are LIVE countermodels against the CURRENT interface. No guard
definition in this phase.

**Tasks**:
- [x] Baseline: scoped `lake build` of
      `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedProbe358TailK`,
      `...ExteriorFiberDeepAnchorProbe367K`, and `...EndIntervalConsumerK` confirming green
      start; `lean_verify` spot-checks on `kvE_probe367_tailDG_deep_rejected`,
      `kvE_probe367_real_slice_deep_anchored`, `kvE_probe358_tailDG_gapItem_pinned_fails`,
      and `kvE_probe363_tau_admissible` (floor axioms, no sorryAx). Record the baseline
      commit SHA. *(done: baseline SHA 9f4f6302b78ae3b62d8c1a322df8d3d192496fb7; scoped
      build green, 1035 jobs; all 4 spot-checks at `[propext, Classical.choice,
      Quot.sound]`, no sorryAx)*
- [x] Consumption-site map (bounded read budget; record in the new leaf's module docstring):
      classify every rows-5/6/10-13 binder site — `EndIntervalConsumerK.lean` (binder
      definitions `_hreal`/`_hexcl`/`_hexclSlice*`/`_hexclDeep*` + `hfiberCons` +
      `endInterval_step_correct` threading), `ExteriorGateAssembleK.lean` (verbatim binder
      copies / `bracketEndChar_kvExt_correct_prior`), `KampPrior.lean:964-1030`
      (`kampPrior_site_rungK_gate_match` mirror), and the gate/bracket FORMULA sites
      (`ExteriorBracketAssembleK.lean` range filters, `igPtW`/`igFoldBit` consumers) — as
      statement-touching vs proof-script-only. This map is Phase 5's authoritative edit
      boundary. Explicitly locate where the "matching gate-formula strengthening" must live
      so the =>-reconstruction can consume the new guard.
- [x] Create NEW additive probe leaf
      `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean`
      (imports mirror `ExteriorFiberDeepAnchorProbe367K.lean`; private-cast replication
      precedent applies). *(done; added `ExteriorFiberConsistencyK` import for
      `kvE_fiberConsistent_of_realized` — deviation: altered, import list extends the 367
      mirror by one frozen module, read-only consumption)*
- [x] **CM-A cast** (kills row 13): homogeneous Z model (R = empty), anchors x, w = x+1,
      t = x+2 per the blocker record; build the fake ambient `qnfA` (`qnfA.1` := honest
      depth-0 row of `[w,x,t]`; `qnfA.2` marking exactly the five honest chars
      {char[x-1], char[x], char[w], char[t], char[t+1]}, omitting
      sigmaA := char[t+2,w,x,t]).
      **Gate 1a (CM-A live)**: sorry-free certificates that (i) sigmaA is admissible
      (sanctioned byte-stable route), on-row, bit-false (`qnfA.2 sigmaA = false`), and
      `kvE_deepOnFiber qnfA sigmaA = false` (guard-false), and (ii) sigmaA is realized at
      the exterior x1 = t+2 — i.e. the row-13 (`hexclDeepFut`-shaped) statement instantiated
      at `qnfA` is REFUTED by explicit witnesses. Record the sibling-rows-hold
      (profile-bucket collapse) argument as the docstring analytical closure, with finite
      mechanized proxies where feasible.
- [x] **CM-B cast** (kills row 5): replicate the 358TailK tail-doppelganger configuration
      re-aimed at the ambient: fake ambient `qnfB` marking `sub_g` (the AtW-zoned honest
      char over the depth-0-indistinguishable, spacing-discrepant fake tail, same (AtW,
      chi_w) bucket as honest `sub_w`).
      **Gate 1b (CM-B live)**: sorry-free certificates that (i) `sub_g` is qnfB-marked,
      on-row, fiber-consistent (via `_of_realized` over the fake tuple), and (ii) `sub_g` is
      `[w,x,t]`-UNREALIZABLE (no x1 realizes it over the real tail; AtW pins fresh = w and
      the deep content differs from char[w,w,x,t].2) — i.e. the row-5 conclusion fails for
      `qnfB` while its antecedent population contains `sub_g`. Record the
      `igPtW`-invisibility (same-bucket) argument in the docstring.
- [x] Scoped `lake build` of the new leaf; `lean_verify` gates 1a/1b (floor axioms);
      `git status` audit: the only tree change is the new leaf. Green commit
      (`task 368 phase 1: ...`). *(done: `kvE_probe368_cmA_row13_refuted` and
      `kvE_probe368_cmB_row5_refuted` both at `[propext, Classical.choice, Quot.sound]`,
      no sorryAx; `git diff --stat -- Theories/` empty — purely additive; sorry/vacuous/
      axiom/guard-unfold scans on the leaf all zero)*

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean` — NEW additive probe leaf (CM-A/CM-B casts + gates 1a/1b + consumption-site map docstring)

**Verification**:
- Gates 1a/1b compile sorry-free at floor axioms `[propext, Classical.choice, Quot.sound]`;
  no production file touched; consumption-site map recorded; scoped `lake build` green.

---

### Phase 2: Candidate ambient EF-closure guard design + exclusion gates (probe-only) [COMPLETED]

**Goal**: Design and machine-validate the ambient guard CANDIDATE in the probe leaf, without
touching any production file. The candidate must exclude BOTH CM-A's and CM-B's fake ambients
while remaining m=0-inert.

**Tasks**:
- [x] Define candidate `kvE_ambientDeepAnchorV0 (qnf : NormalForm sig (k+2) n) : Bool`
      (working name; pure decidable syntax over the NF fintype, no model parameter, mirroring
      `kvE_deepOnFiber`'s shape) implementing EF-closure of `qnf.2`:
      (i) **fresh-rotation re-appearance** — every marked sub's inner fiber content
      re-appears under fresh-rotation as a marked sub (the clause CM-A's deep-incomplete
      marking violates: char[t+1]'s inner `[t+2]`-element forces marking sigmaA);
      (ii) **deep-content-to-row anchoring** — every marked sub's deep content is anchored
      to the row (the clause CM-B's `sub_g` violates: its misplaced inner couplings
      contradict anchoring). Resolve the depth/arity bookkeeping explicitly (Risk 2; 367
      lesson: prefer mate/membership conditions at types `qnf.2` already marks over
      slot-drop operations). Keep the fiber-depth <= 1 arm literally the trivial/old check so
      inertness stays `rfl`-cheap. Document rejected candidate forms and trade-offs in the
      leaf docstring (367 house style). *(done: both plan clauses unified as one
      fresh-rotation EF-closure clause on the `k+1` arm; the `k=0` arm is literally `true`
      (rfl-inert). Bookkeeping resolved via `swapNF01 := renameNF (Equiv.swap 0 1) (Equiv.swap
      0 1)` — a DEPTH/ARITY-preserving reindex (sanctioned `NfDepth0Generalized.renameNF`),
      expressed as a membership/mate condition `∃ marked σ', σ'.2 (swapNF01 ρ) = true` at the
      type `qnf.2` marks; the F2-DEAD depth-raising `nfk_projFresh` is never built. Four
      rejected forms documented in the leaf docstring.)*
- [x] **Gate 2a (CM-A excluded)**: sorry-free certificate
      `kvE_probe368_cmA_ambient_rejected : kvE_ambientDeepAnchorV0 qnfA = false` — the
      deep-incomplete marking fails clause (i). *(done: `cA 3` marks `fibA34 = char[4;3,1,0,2]`,
      whose swap is Phase-1 `gapA`; no marked `cA v (v≤3)` covers it — reuses `cA_gap_false`.
      Axioms `[propext, Classical.choice, Quot.sound]`, no sorryAx.)*
- [x] **Gate 2b (CM-B excluded)**: sorry-free certificate
      `kvE_probe368_cmB_ambient_rejected : kvE_ambientDeepAnchorV0 qnfB = false` — the
      doppelganger marking fails clause (ii). *(done: `subG` marks `sG10`, whose swap `swG =
      char[12;10,12,8,25]` forces `R` at slot 1 with slot1<slot2 — unrealizable over the real
      tail `[·,5,2,30]` (forces `10<5`) and over `subG`'s fake tail (slot 1 = 12 ≠ R). Axioms
      `[propext, Classical.choice, Quot.sound]`, no sorryAx.)*
- [x] **Gate 2c (m=0 inertness)**: `_zero` lemma at the m=0 binder instance, ideally `rfl`
      (mirroring `kvE_deepOnFiber_zero`) — the guard rail that keeps the frozen m=0 supply
      layer, the k<=1 rungs, and any m=0 residue rows untouched/vacuous in Phase 5.
      *(done: `kvE_ambientDeepAnchorV0_zero : kvE_ambientDeepAnchorV0 (qnf : NormalForm sig 2
      n) = true := rfl`. Floor axioms, no sorryAx.)*
- [x] Scoped `lake build` of the leaf; `lean_verify` gates 2a/2b/2c (floor axioms);
      `git status` audit (probe leaf only). Green commit. *(done: scoped build green (1025
      jobs); all three gates verified at `[propext, Classical.choice, Quot.sound]` no sorryAx;
      sorry/vacuous/axiom scans all 0; guard-unfold scan clean; `git diff --stat -- Theories/`
      = only the probe leaf, production untouched.)*

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean` — candidate definition + gates 2a/2b/2c

**Verification**:
- Gates 2a/2b/2c compile sorry-free at floor axioms; no production file touched; zero
  unfoldings of prior guards (source-scan discipline).

---

### Phase 3: Honest-preservation crux + readback at probe level [COMPLETED]

**Goal**: Prove, at probe level and in full generality (any model, any env), that honestly
REALIZED ambients pass the guard (`_of_realized`, the anti-vacuity guarantee) and that the
guard's content is extractable ONLY through a readback lemma (`_iff`). Without `_of_realized`
at a general model, task 358's re-keyed supply has no discharge route and the restated rows
would be vacuously unservable.

**Tasks**:
- [x] Prove `kvE_ambientDeepAnchorV0_of_realized` (the `kvE_deepOnFiber_of_realized:141`
      template one layer up): if `qnf` is realized at `env` (a GENERAL
      `OrderedMonadicStructure`), then `kvE_ambientDeepAnchorV0 qnf = true`. Expected
      witness pattern: for clause (i), the realized ambient's quant layer marks the
      characteristic of every witness point (the fresh-rotation mate is supplied by
      realization); for clause (ii), anchoring follows from the depth-0 factorization
      (`nf_eval_nf0_cons_factor`) + uniqueness (`nf_eval_unique`) exactly as the row conjunct
      of `kvE_deepOnFiber_of_realized`. *(done: `match` on the grading index — `k = 0` arm
      `rfl`; `k + 1` arm routes through `_iff`. Realization supplies `x1` (τ realized at
      `cons x1 env`) and `x2` (ρ realized at `cons x2 (cons x1 env)`); by `nf_eval_unique`
      ρ = `char (cons x2 (cons x1 env))`, so `swapNF01 ρ = char (cons x1 (cons x2 env))`
      (`swapNF01_char` + the general env-swap identity `cons2_comp_swap01`); mate
      `σ' := char (cons x2 env)` is qnf-marked at fresh `x2` (clause i) and covers
      `swapNF01 ρ` at fresh `x1` (clause ii). Fully general — no `nf_eval_nf0_cons_factor`
      needed since the `char`/uniqueness route subsumes the depth-0 factorization one layer
      up. Floor axioms.)*
- [x] Prove `kvE_ambientDeepAnchorV0_iff` — the unpack/repack readback, the ONLY sanctioned
      mate/witness-extraction direction (mirroring `kvE_deepOnFiber_iff`); every downstream
      consumer and certificate routes through it, never through unfolding. *(done: deep-arm
      `k ≥ 1` readback `all/all/any = true ↔ ∀τ∀ρ∃σ'` closure; sanctioned home-module `show`
      + `List.all_eq_true`/`List.any_eq_true`. Floor axioms.)*
- [x] **Gate 3a (honest cast preservation)**: sorry-free concrete certificate
      `kvE_probe368_real_ambient_anchored` — the REAL ambient (`qnf367`-style
      `nf_characteristic` over the real anchors) passes the guard, derived FROM
      `_of_realized` (not by concrete computation). *(done: `kvE_ambientDeepAnchorV0
      (nf_characteristic MB 3 3 mBreal3) = true` via `_of_realized` +
      `nf_characteristic_satisfies` — one line, no computation. Floor axioms.)*
- [x] **Gate 3b (supply-feasibility shape)**: certify the discharge route task 358's re-keyed
      supply will use: guard-trueness for realized ambients dischargeable through
      `_of_realized` alone; witness extraction through `_iff` alone (zero guard unfoldings
      anywhere in the leaf — source-scan discipline). *(done:
      `kvE_probe368_ambient_supply_route` = `(_iff qnf).mp (_of_realized M env qnf hqnf)` —
      trueness from `_of_realized`, extraction from `_iff`, zero unfoldings. Source scan:
      only the Phase-2 gates 2a/2b use the sanctioned home-module `show … from rfl`; Phase-3
      additions unfold nothing. Floor axioms.)*
- [x] **Adjudication checkpoint**: if `_of_realized` is NOT dischargeable for the candidate
      shape, redesign ONCE (loop Phase 2's gates on the revised candidate). *(NOT triggered:
      `_of_realized` discharged for the Phase-2 candidate as-is at a general model; zero
      redesign loops consumed.)*
- [x] Scoped `lake build`; `lean_verify` gates (floor axioms). Green commit. *(done: scoped
      build green (1025 jobs); `_of_realized`, `_iff`, gate 3a, gate 3b all verify at
      `[propext, Classical.choice, Quot.sound]` no sorryAx; sorry/vacuous/guard-unfold scans
      clean; `git diff --stat -- Theories/` = probe leaf only.)*

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean` — `_of_realized` + `_iff` + gates 3a/3b

**Verification**:
- `_of_realized` compiles sorry-free at general model/signature; `_iff` lands; gates 3a/3b
  green at floor axioms; zero guard-unfoldings (source scan).

---

### Phase 4: Adversarial re-plant probes, ambient side (churn cap: ONE redesign loop) [COMPLETED]

**Goal**: Attempt to defeat the candidate the way 358's Phase-4 adjudication defeated the 367
interface — BEFORE promotion. Mirror 367's depth-2 hereditary doppelganger and copy-plant
checks, re-aimed at the ambient side.

**Tasks**:
- [x] **Hereditary re-plant (depth-2 ambient doppelganger)**: construct a fake ambient whose
      EF-closure violation is visible only two fiber layers down (depth-0 AND depth-1
      indistinguishable marking pattern; 367's `[40,9,8,11]` discrete-gap technique
      re-aimed at the ambient marking). Machine-adjudicate:
      **Gate 4a (candidate survives)**: sorry-free certificate that the depth-2 fake ambient
      fails the guard; OR **Gate 4b (candidate defeated)**: a refutation certificate in the
      `kvE_probe358_tailDG_*` style — then loop back to Phase 2 design ONCE (churn guard);
      a SECOND defeat exits `[BLOCKED]` with the refutation certificate as escalation payload.
      *(done — Gate 4a FIRED, candidate survives: `kvE_probe368_depth2_ambient_rejected`
      certifies `kvE_ambientDeepAnchorV0 q2A = false` for the m=2 depth-lifted deep-incomplete
      homogeneous ambient `q2A : NormalForm mAsig 4 3` (marks `{c2A(-1..3)}`, omits `c2A 4`).
      The `[40,9,8,11]` discrete gap is ℤ-instantiated as `2 < r < v ≤ 3` (empty over ℤ), now
      surfacing one fiber layer deeper: marked `c2A 3` carries depth-2 `fib2A`, whose swap
      `gap2A` is covered by no marked `c2A v` (v≤3, `c2A_gap_false`). Homogeneous bucket
      collapse gives depth-0 AND depth-1 indistinguishability (strictly stronger than 367's
      matched zone-presence). ZERO redesign loops consumed.)*
- [x] **Copy-plant, ambient side**: the strongest adapted attack — a fake ambient whose
      marking is manufactured to satisfy both EF-closure clauses syntactically (copying an
      honest ambient's marking payload) while remaining unrealizable. Machine-adjudicate
      self-defeat: the copy must survive the row/anchoring clauses and the composition with
      the sigma-side guards (`kvE_deepOnFiber`, admissibility) — certificate either excludes
      the adapted ambient or shows the construction collapses to the honest ambient
      (mirroring `kvE_probe367_copyPlant_collapses`). *(done — self-defeat mechanized in two
      parts. Part 1 `kvE_probe368_ambient_copyPlant_passes_guard`: since the guard reads ONLY
      `qnf.2`, the marking-copy PASSES it (reduces to gate 3a) — the guard alone cannot exclude
      it. Part 2 `kvE_probe368_ambient_copyPlant_collapses`: the on-row anchoring clause
      (`nfk_dropFresh subAnchor = qs.1`, read through `nf_eval_nf0_cons_factor`/`nf_eval_unique`)
      pins `qs.1 = qnfBreal.1`, so `qs = nf_characteristic MB 3 3 mBreal3` — the construction
      COLLAPSES to the honest ambient. Ambient analog of `kvE_probe367_copyPlant_collapses`.)*
- [x] **Prior-family cross-check**: confirm the candidate does not reopen any
      previously-closed hole — the guard is a NEW antecedent conjunct: it strictly SHRINKS
      the obligation population, so 363/364/367/358 exclusions cannot weaken; record the
      argument explicitly in the docstring (certificates where cheap). *(done — recorded in the
      leaf docstring "Deliverable 3": `kvE_ambientDeepAnchorV0` syntactically references neither
      admissibility (363/364 engine) nor `kvE_deepOnFiber` (367), so as a new conjunct it strictly
      shrinks the population and reopens nothing. Cheap witnesses: gate 3a (honest ACCEPTED,
      non-vacuous) + gates 2a/2b (fakes REMOVED) = strict non-vacuous shrink leaving every prior
      exclusion intact.)*
- [x] **Analytical-family closure record**: write the homogeneous/(Q,<)-family dissolution
      argument into the leaf docstring (why every deep-incomplete or doppelganger-marked
      ambient violates a clause at the discrepancy layer), noting the Z casts are finite
      proxies. *(done — leaf docstring "Deliverable 4": deep-incomplete family (homogeneous/(ℚ,<):
      omitted completer ⟹ uncovered swap in a discrete/bounded gap) and doppelgänger family
      (spacing-discrepant plant ⟹ swap realizable only over the fake tail) both reduce to the
      one fresh-rotation closure; `_of_realized` guarantees no honest ambient is dissolved; the
      ℤ casts are finite proxies of the family argument.)*
- [x] Scoped `lake build`; `lean_verify` all gate-4 certificates (floor axioms). Green commit.
      *(done: scoped build green (1025 jobs); `kvE_probe368_depth2_ambient_rejected`,
      `kvE_probe368_ambient_copyPlant_passes_guard`, `kvE_probe368_ambient_copyPlant_collapses`
      all verify at `[propext, Classical.choice, Quot.sound]` no sorryAx; sorry/vacuous/
      prior-guard-unfold scans clean; `git diff --stat -- Theories/` = probe leaf only.)*

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean` — adversarial section + gate-4 certificates + closure docstrings

**Verification**:
- Gate 4a certificates compile sorry-free at floor axioms (or the documented single redesign
  loop has completed with gates 2a/2b/2c/3a/3b/4a all green on the revised candidate);
  prior-family cross-check recorded.

---

### Phase 5: Production landing — new guard module + rows-5/6/10-13 restatement + gate-formula strengthening (snapshot first) [COMPLETED]

**Goal**: The single production-touching phase. Promote the adjudicated guard into a NEW
additive production module and restate the consumer binders in place, keeping every frozen
name/signature byte-stable and repairing mapped threading sites at proof-script level only.

**Tasks**:
- [x] Snapshot first: `bash .claude/scripts/git-snapshot.sh` before any production edit.
- [x] Create NEW production module
      `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorK.lean`
      (mirroring `ExteriorFiberDeepAnchorK.lean`'s module shape): promote the adjudicated
      guard verbatim from the probe leaf (final name adjudicated; `_zero` + `_iff` +
      `_of_realized` + any `_row`-style adapters), with a module docstring recording the
      consumption map, the CM-A/CM-B countermodels it defeats, and the never-unfold routing
      rule.
- [x] Restate the guarded antecedents per the Phase-1 map: rows 5, 6, 10-13 of
      `EndIntervalConsumerK.lean` (`_hreal`, `_hexcl`, `_hexclSlicePast/Fut`,
      `_hexclDeepPast/Fut`) gain the ambient guard antecedent; update the
      `endInterval_step_correct` threading in the same file. Mirror the restatement in
      `ExteriorGateAssembleK.lean` (`bracketEndChar_kvExt_correct_prior` binders) and
      `kampPrior_site_rungK_gate_match` (`KampPrior.lean:964-1030`). Land the matching
      gate-formula strengthening (per the Phase-1 map — expected in the gate/bracket formula
      layer so the =>-reconstruction can consume the guard). **Adjudicate during
      restatement** whether new m=0-vacuous ledger rows for guard-false residue are required
      (367 precedent: rows 12-13); if added, they must be m=0-vacuous through `_zero` and
      recorded in the obligation-disposition ledger.
- [x] **Scope alarm**: any statement edit needed in a frozen file (see Non-Goals list) or in
      any file outside the Phase-1 map — STOP, restore the snapshot, escalate; that indicates
      the candidate is not signature-stable and needs redesign, not forcing.
- [x] Repair mapped m=0 discharge sites at proof-script level ONLY, through the `_zero`
      adapter (frozen task-360 supply and k<=1 rungs byte-unchanged).
- [x] Rewire `ExteriorAmbientDeepAnchorProbe358K.lean` to certify against the PRODUCTION
      definition (drop or alias the V0 duplicate so exactly one live definition exists; the
      leaf remains the permanent regression record).
- [x] Scoped `lake build` across the full consumer chain: `ExteriorAmbientDeepAnchorK`,
      `ExteriorAmbientDeepAnchorProbe358K`, `EndIntervalConsumerK`, `ExteriorGateAssembleK`,
      `ExteriorBracketAssembleK` (if mapped), `ExteriorFiberDeepAnchorK`,
      `ExteriorFiberDeepAnchorProbe367K`, `ExteriorDeepSliceSupplyK`,
      `ExteriorPinnedConverseK`, `ExteriorPinnedConversePastK`,
      `ExteriorFiberConsistencyProbeK`, `ExteriorFiberConsistencyProbe364K`,
      `ExteriorPinnedProbe358K`, `ExteriorPinnedProbe358TailK`, `ExteriorPinnedProbeM1K`,
      `KampPrior`. Green commit.

**Timing**: 2.5 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorK.lean` — NEW production guard module
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean` — rows-5/6/10-13 binder restatement + threading (+ adjudicated residue rows)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorGateAssembleK.lean` — binder mirror propagation + gate-formula strengthening (per Phase-1 map)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` — `kampPrior_site_rungK_gate_match` mirror + threading, proof-script level elsewhere (`:519`/`:522` sorries UNTOUCHED)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracketAssembleK.lean` — ONLY if the Phase-1 map places the gate-formula strengthening here (367 precedent; not frozen)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean` — rewire to production definition

**Verification**:
- Scoped `lake build` green across the whole chain; `git diff --stat` over `Theories/` shows
  exactly the files listed above (minus any adjudicated-out); zero statement changes outside
  the mapped sites; zero guard-unfoldings introduced; `KampPrior.lean:519`/`:522` sorries
  still present and untouched.

---

### Phase 6: Full re-probe gate + wrap-up — the definition of done [COMPLETED]

**Goal**: Machine-adjudicate the task's definition of done against the landed production
interface, then land the documentation and orchestrator handoff so task 358 can be re-keyed.

**Tasks**:
- [x] **CM-A/CM-B re-probe (production definitions)**: `kvE_probe368_cmA_ambient_rejected`,
      `kvE_probe368_cmB_ambient_rejected`, `kvE_probe368_real_ambient_anchored`, the
      hereditary/copy-plant gate-4 certificates, and the Phase-1 live-countermodel records
      (which remain TRUE statements about the OLD interface — permanent regression record) —
      all sorry-free at floor axioms `[propext, Classical.choice, Quot.sound]`, no sorryAx.
- [x] **Full prior certificate inventory re-verification**: `lean_verify` sweep at floor
      axioms, no sorryAx, over the description's named minimum — `kvE_probe367_*` x4
      (`tailDG_deep_rejected`, `real_slice_deep_anchored`, `depth2DG_deep_rejected`,
      `copyPlant_collapses`), `kvE_probe364_*` x4, `kvE_probe363_*` x3, `kvE_probe358_*` x3
      (`tailDG_gapItem_pinned_fails`, `tailDG_sigma_in_population`, `eP_atomMate_present`) —
      PLUS the full prior-GO sweep 367 Phase 5 executed (363: 9 certs, 364: 11 certs, M1
      residuals `kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical`).
- [x] **Guard-unfold source scan (machine gate, zero occurrences)**: scan for
      `rw`/`unfold`/`simp only` on the new guard name, `kvE_deepOnFiber`,
      `kvE_fiberElemConsistent`, `kvE_fiberConsistent`, `kvE_futAdmissible`,
      `kvE_pastAdmissible` outside their home modules, e.g.
      `grep -rnE '(rw|unfold|simp only)([^-]|$)' Theories/ --include='*.lean' | grep -E '(kvE_ambientDeepAnchor|kvE_deepOnFiber|kvE_fiberElemConsistent|kvE_fiberConsistent|kvE_futAdmissible|kvE_pastAdmissible)'`
      filtered to exclude each guard's home module — result count MUST be 0.
- [x] **Frozen-layer diff audit**: `git diff --name-only <baseline SHA>` confirms
      byte-unchanged: all files in the Non-Goals frozen list (363/364 files, 367 files, m=0
      kernels, k<=1 rungs, task-360 supply, `ExteriorDeepSliceSupplyK.lean`,
      negation/converter families, historical probe records). Change set is exactly Phase 5's
      file list plus the probe leaf (and an optional docstring-only supersession note).
- [x] **Zero-debt audit**: full `lake build` green; repo-wide Kamp-path proof-sorry inventory
      is exactly `KampPrior.lean:519`/`:522` (line numbers may shift; count and identity must
      not); vacuous-def scan (`def _ := True`-class) clean over the change set; `lean_verify`
      on every new/changed certificate.
- [x] Write implementation summary
      `specs/368_ambient_deepsaturation_efclosure_guard_against_cma_cmb/summaries/01_ambient-deep-anchor-guard-summary.md`:
      the final guard shape (both EF-closure clauses as landed), full certificate inventory
      with `lean_verify` axiom results, adversarial outcomes, consumption-site repair record,
      adjudicated residue-row decision, any plan deviations.
- [x] Update `.orchestrator-handoff.json`: final guard signature (it dictates the discharge
      terms task 358's re-keyed Phases 4-8 must construct), certificate list, files touched,
      frozen-audit result, and the explicit next action `/revise 358` then `/implement 358`.
- [x] Update plan phase statuses and `.return-meta.json`; per-green-milestone commits should
      have landed at each phase; final `task 368: complete implementation`.

**Timing**: 1.5 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358TailK.lean` — docstring-only supersession note IF warranted (statements byte-stable; 367 precedent)
- `specs/368_ambient_deepsaturation_efclosure_guard_against_cma_cmb/summaries/01_ambient-deep-anchor-guard-summary.md` — NEW
- `specs/368_ambient_deepsaturation_efclosure_guard_against_cma_cmb/.orchestrator-handoff.json` — update
- this plan file — status markers

**Verification**:
- Every listed certificate green at floor axioms; full `lake build` passes; guard-unfold scan
  = 0; frozen-file diff empty; sorry inventory = 2 (KampPrior `:519`/`:522` only);
  vacuous-def scan clean; summary and handoff exist, are non-empty, and the handoff JSON
  parses.

## Testing & Validation

- [ ] Gate 1a/1b: CM-A and CM-B certified LIVE against the current interface (sorry-free,
      floor axioms) BEFORE any guard definition — the binding probe-first order
- [ ] Gate 2a/2b: the candidate ambient guard machine-excludes BOTH fake ambients
- [ ] Gate 2c: m=0 inertness (`_zero`, ideally `rfl`) — frozen m=0 layer guard rail
- [ ] Gate 3a/3b: `_of_realized` at a GENERAL model (anti-vacuity) + `_iff` readback;
      discharge route uses `_of_realized`/`_iff` only (zero guard-unfoldings)
- [ ] Gate 4: hereditary depth-2 ambient doppelganger rejected; ambient copy-plant
      self-defeating; prior 363/364/367/358 families not reopened; analytical closure
      recorded; at most ONE redesign loop consumed
- [ ] Phase 5: scoped `lake build` green across the full consumer chain; statement changes
      confined to the Phase-1 map; snapshot taken before edits; residue-row decision
      adjudicated and recorded; `KampPrior.lean:519`/`:522` untouched
- [x] Phase 6: CM-A/CM-B re-probe + FULL certificate inventory (`kvE_probe367_*` x4,
      `kvE_probe364_*` x4, `kvE_probe363_*` x3, `kvE_probe358_*` x3, plus the full prior-GO
      sweep) at floor axioms, no sorryAx; guard-unfold source scan = 0 occurrences;
      frozen-layer diff empty; sorry count = 2; vacuous-def scan clean
- [ ] Blocked-exit contract honored if any gate cannot close after the one redesign loop:
      `[BLOCKED]` + structured escalation record (failing countermodel named, exact goal
      state, analytical gap) — never sorry/vacuous-def/forced proof

## Artifacts & Outputs

- `plans/01_ambient-deep-anchor-guard.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean` (NEW probe leaf: CM-A/CM-B live casts, candidate adjudication, preservation crux, adversarial re-plant, permanent regression record)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorK.lean` (NEW production guard module: ambient EF-closure guard + `_zero` + `_iff` + `_of_realized`)
- Restated rows-5/6/10-13 binders in `EndIntervalConsumerK.lean` (+ adjudicated residue rows)
- Mirrored restatement + gate-formula strengthening in `ExteriorGateAssembleK.lean` /
  `KampPrior.lean` (gate-match) / `ExteriorBracketAssembleK.lean` (if mapped)
- `summaries/01_ambient-deep-anchor-guard-summary.md`
- `.orchestrator-handoff.json` (task-358 re-key handoff: final guard shape + `/revise 358` then `/implement 358` next action)

## Rollback/Contingency

- Phases 1-4 are purely additive (one new probe leaf, no production file touched): rollback =
  delete the leaf. A NO-GO adjudication at Phase 3/4 (after the one permitted redesign loop)
  converts the leaf into a quarantined NO-GO record and the task exits `[BLOCKED]` with a
  structured escalation naming the failing countermodel (CM-A or CM-B or the adversarial
  re-plant), the exact goal state, and the analytical gap — never a landed sorry or a
  weakened probe.
- Phase 5 is the only production-touching phase. Snapshot first via
  `bash .claude/scripts/git-snapshot.sh`. If repair exceeds the Phase-1 consumption map (any
  statement edit in a frozen file, or any file outside the map), stop, restore the snapshot,
  and escalate — the candidate is not signature-stable and needs redesign, not forcing.
- Per-phase green commits (`task 368 phase {P}: ...`) ensure any failure resumes from the
  last green milestone; incomplete phase work is never committed.
- If Phase 6 uncovers a regression on any prior GO certificate that cannot be repaired at
  proof-script level, revert the Phase-5 commit(s) (production returns to the current
  interface — machine-refuted at m >= 1 but self-consistent and green) and exit `[BLOCKED]` —
  the frozen reference layer is never left broken.
