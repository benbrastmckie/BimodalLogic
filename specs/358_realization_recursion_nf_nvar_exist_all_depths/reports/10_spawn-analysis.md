# Blocker Analysis: Task #358

**Parent Task**: #358 - Realization recursion `nf_nvar_exist_all_depths` — re-keyed to task 367's deep-anchor rows-8-9/12-13 interface, `hsigma` production as the crux
**Generated**: 2026-07-14
**Blocker**: Phase 4's `igPtW`-guarded ledger rows 5/6/10-13 are FALSE AS STATED at m>=1. Two paper countermodels inside the antecedent population (CM-A, CM-B) satisfy every sibling row while defeating the row-13 and row-5 conclusions respectively. This is the ambient-side twin of the fiber-side gap that task 367 closed.

## Root Cause

`kvE_deepOnFiber`/`igFoldBit` (the 367 guard and its downstream `igPtW` consumer) read `qnf.2`
(the ambient's deep marking) ONLY at PROFILE level — i.e. bucketed by `ZoneSpec 3 × NormalForm
sig (m+1) 1`. At m >= 1 the deep content strictly BELOW a profile bucket is unconstrained by
anything the guard or the ambient antecedent checks. This is the **P17 anchor-content gap**
(originally identified in task 309 v9 Phase 17) resurfacing one layer over: 367 closed it on the
FIBER side (the σ being tested against the guard); Phase 4's adjudication discovered the SAME
gap on the AMBIENT side (the qnf supplying the guard's marking in the first place).

Two machine-checkable countermodels populate the antecedent while the ⇒-reconstruction fails:

- **CM-A** (kills row 13): homogeneous ℤ model (the `Probe358TailK` infra, no relations, single
  1-type). A fake ambient `qnf` marks every honest 4-type over `[v,w,x,t]` EXCEPT
  `σ := char[t+2,w,x,t]` — a deep-incomplete marking that omits exactly one honest
  representative per profile bucket (specifically dropping `char[t+2]`'s bucket-mate). Because
  all profile buckets collapse under the homogeneous type, every profile-level check (`igPtW`,
  `epL`/`epR`, `segL`/`segR`, `igOffFiber`, the deep-anchored brackets) is satisfied and rows
  5/5a/6/10/11 all hold — yet σ is admissible, on-row, bit-false, and GUARD-FALSE (its only
  candidate mate differs at an order-only depth-1 discrepancy), so row 13 is violated while the
  fake qnf's full LHS is satisfiable. No discharge of the 13 rows can exist against this qnf,
  because it would prove the false gate biconditional.
- **CM-B** (kills row 5): the `Probe358TailK` tail-doppelgänger re-aimed at the AMBIENT itself —
  a same-bucket (AtW, χ_w), depth-0-indistinguishable, spacing-discrepant fake tail. It is
  on-row, fiber-consistent (via `_of_realized` over the fake tuple), and `igPtW`-invisible (same
  bucket as the honest ambient) — but `[w,x,t]`-UNREALIZABLE, so row 5's conclusion fails.

**Why the plan's existing mitigation cannot be patched in place**: the `igPtW` → ambient bridge
Phase 4/5 relied on (`hcharK` + `P.correct` + `kampPrior_existProviders_of_ih_existF0_char`) is
CIRCULAR here — "ambient realized at `[w,x,t]`" is exactly (atom row) + rows 5+6+10+11+12+13
themselves (the fold biconditional's ⇐ is row 5; its ⇒ splits into row 6 + rows 10-13). No
bridge built from those rows can presuppose their own conclusion.

**Prescription** (367-style, probe-first, per the blocker record and the completed 367
precedent): add a NEW ambient-side deep-saturation/EF-closure guard — m=0-inert — to the
`igPtW`-guarded binder antecedents (rows 5, 6, 10-13) and the matching gate-formula
strengthening, such that: (i) every marked sub's inner fiber content re-appears under
fresh-rotation as a marked sub (kills CM-A — char[t+1]'s inner `[t+2]`-element forces marking
σ); (ii) every marked sub's deep content is anchored to the row (kills CM-B — sub_g's misplaced
inner couplings violate anchoring). Both casts must be machine-probed over the
`Probe358TailK` ℤ infra FIRST, as additive sorry-free probes, before any guard is landed.

## What Is Already Banked (immune, must be preserved)

Per the user's blocker prompt and the plan's own Phase-4 record: Phase 3's landing —
`NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean` (`kvE_hsliceFut_supply`/
`kvE_hslicePast_supply`, general-m, via `kvE_deepMate_collapse`) — is **ambient-realization-
guarded** and is explicitly stated to **survive ambient-side strengthening** (its ambient-
realization antecedent only gains strength from a stronger ambient guard). It is OUT OF SCOPE
for the spawned task and must not be re-derived, weakened, or touched.

## Proposed New Tasks

Following the 367 precedent exactly (a single task closed that interface gap end-to-end: probe
-> guard -> re-probe, in one dispatch), this analysis proposes **ONE new task**. The blocker is a
single, well-bounded interface refinement (one new guard predicate, its API family, its
consumer-binder restatement, and its probe certificates) — splitting probe-adjudication from
guard-landing would only be warranted if the probe were expected to overrun a single agent run
or if adjudication could plausibly falsify the whole approach and require a redesign before
committing to a guard shape. Neither applies here: CM-A/CM-B are already fully characterized
analytically in the Phase-4 blocker record (this is what 367's own Phase 1-3 did in one
dispatch for the fiber side), so probe-casting and guard-landing are two tasks' worth of
*sequenced work inside one task*, exactly as 367 structured its own 6 phases.

### New Task 1: Ambient-side deep-saturation/EF-closure guard against CM-A/CM-B (358 interface refinement, one layer over 367)

- **Effort**: high (structurally mirrors 367's ~6-phase, one-dispatch scope: probe casts, guard
  definition + API family, consumer restatement, probe certificates, terminal re-verification)
- **Task Type**: lean4
- **Rationale**: This is the sole blocker preventing Phase 4 (and downstream Phases 5-8) of task
  358 from proceeding. It closes the ambient-side analogue of the P17 gap that 367 closed on the
  fiber side, using the identical, twice-proven (363, 364, 367) template.
- **Depends on**: None (new task; no other spawned task exists in this decomposition).

**Description** (full — to be used as the created task's description):

Land a 367-style, probe-first, ambient-side deep-saturation/EF-closure guard that closes the
Phase-4 blocker on task 358 (`nf_nvar_exist_all_depths`, `KampPrior.lean:519`/`:522`), one layer
over task 367's fiber-side guard. Follow the PROVEN template used by tasks 363, 364, and 367
(all completed against this same consumer interface) with zero deviation from house style:

1. **Probe-first (BEFORE any kernel/guard change)**: machine-probe CM-A and CM-B — the two
   countermodels recorded in task 358's Phase-4 BLOCKER record
   (`specs/358_realization_recursion_nf_nvar_exist_all_depths/plans/06_deep-anchor-rekey-v06.md`,
   Phase 4 section) — over the `ExteriorPinnedProbe358TailK.lean` ℤ infra
   (`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`). Cast BOTH as additive,
   sorry-free probe certificates BEFORE writing any guard definition. This re-probe is the
   analytical ground truth the guard shape must be designed against, exactly as 367 Phase 1-3
   adjudicated the tail-doppelgänger/depth-2/copy-plant casts before committing to
   `kvE_deepOnFiber`'s final shape.
2. **Land a NEW guard in a NEW leaf file** (recommended:
   `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorK.lean`,
   mirroring `ExteriorFiberDeepAnchorK.lean`'s module shape) implementing the EF-closure
   predicate on the ambient `qnf`: (i) inner-fiber-content re-appearance under fresh-rotation
   (kills CM-A) and (ii) deep-content-to-row anchoring (kills CM-B). The guard MUST carry:
   - an **m=0-inertness lemma** (`_zero`, ideally `rfl`) — mirroring `kvE_deepOnFiber_zero`;
   - a **readback lemma** (`_iff`) — the ONLY sanctioned mate/witness-extraction direction,
     mirroring `kvE_deepOnFiber_iff`;
   - an **honest-preservation crux** (`_of_realized`) proven at a GENERAL model — the
     anti-vacuity guarantee that the new guard does not reject any honestly realized ambient,
     mirroring `kvE_deepOnFiber_of_realized`.
3. **Restate the guarded antecedents** in the consumer binders that the blocker names: rows 5, 6,
   10-13 of `EndIntervalConsumerK.lean`, their mirrors in `ExteriorGateAssembleK.lean` and
   `kampPrior_site_rungK_gate_match` (`KampPrior.lean:964-1030`), and the matching gate-formula
   strengthening so the ⇒-reconstruction can consume the new guard. Add new m=0-vacuous ledger
   rows for guard-false residue if the restatement requires it (367 precedent: rows 12-13 were
   added this way; this task may need an analogous addition on the ambient side — adjudicate
   during the restatement, do not presuppose the row count).
4. **Land NEW probe certificates in a NEW probe leaf** (recommended:
   `ExteriorAmbientDeepAnchorProbe358K.lean`, mirroring `ExteriorFiberDeepAnchorProbe367K.lean`)
   certifying: CM-A and CM-B are EXCLUDED by the new guard; an honest-preservation certificate
   (the general-model realized ambient passes); and any hereditary re-plant variants an
   adversarial pass surfaces (mirror 367's depth-2 hereditary doppelgänger and copy-plant
   checks, re-aimed at the ambient side).
5. **Re-probe as the definition of done**: after landing, re-run CM-A/CM-B probes plus the FULL
   existing certificate inventory (`kvE_probe367_*` x4, `kvE_probe364_*` x4, `kvE_probe363_*` x3,
   `kvE_probe358_*` x3) at floor axioms `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.

**ZERO-DEBT TERMINUS** (binding, no exceptions): no `sorry`, no vacuous definition
(`def X := True` family), no proof forced against a live countermodel. If the guard cannot land
green against both CM-A and CM-B, return the task as `[BLOCKED]` with a structured escalation
record (failing countermodel named, exact goal state, analytical gap) — never a landed sorry or
a weakened probe.

**NEVER UNFOLD THE GUARD DIRECTLY** (binding, matches the task-358 GLOBAL ROUTING CONSTRAINT):
all consumption of the new guard, and of every prior guard it composes with
(`kvE_deepOnFiber`, `kvE_fiberElemConsistent`/`kvE_fiberConsistent`, `kvE_futAdmissible`/
`kvE_pastAdmissible`), MUST route through byte-stable lemmas only (`_of_realized`, `_zero`,
`_iff`, `_row`/analogues). A source scan for `rw`/`unfold`/`simp only` on any of these guard
names outside their home modules must show zero occurrences.

**PRESERVE BYTE-FOR-BYTE** (frozen, do not edit, do not re-derive):
- `ExteriorFiberConsistencyK.lean`, `ExteriorFiberConsistencyProbeK.lean`,
  `ExteriorFiberConsistencyProbe364K.lean` (363/364)
- `ExteriorFiberDeepAnchorK.lean`, `ExteriorFiberDeepAnchorProbe367K.lean` (367)
- The m=0 `_zero` kernel family (`ExteriorPinnedConverseK.lean`/`PastK.lean`)
- The k<=1 rungs (`kampPrior_case1_arm_k0`, `kampPrior_case1_arm_k1`)
- Task 360's m=0 supply
- **Task 358 Phase 3's landing**: `NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean`
  (`kvE_hsliceFut_supply`/`kvE_hslicePast_supply`, `kvE_deepMate_collapse`,
  `kvE_{fut,past}SliceEq_refl`) — this is ambient-realization-guarded and explicitly documented
  to survive ambient-side strengthening; it must NOT be re-derived, weakened, or discarded.
- `ExteriorNegationK.lean`/`PastK.lean`, `ExteriorConverterK.lean`/`PastK.lean` (363/364 guard +
  converter families)
- `ExteriorPinnedProbe358K.lean`, `ExteriorPinnedProbeM1K.lean` (historical regression records)

**SCOPE BOUNDARY** (explicit, binding — this task refines the INTERFACE ONLY, exactly as 367
did): this task MUST NOT perform any of task 358's own Phase 4-8 work:
- MUST NOT build the G2-B1 (rows 12-13 supply), G2-B2 (uniqueness kernel), or G2-B3 (rows 10-11
  supply) theorems themselves — only the guard/antecedent restatement they will consume.
- MUST NOT touch `kampPrior_hreal_supply`/`kampPrior_hexcl_supply` (Phase 5/6, `hsigma`
  production) or the converter-seam discharge.
- MUST NOT retire the `KampPrior.lean:519` or `:522` sorries (Phase 7/8 arm rewrites) — those
  sorries remain live and are task 358's own responsibility after this task unblocks the
  interface.
- The deliverable is: a new guard + its API + the restated binders/gate-formula + probe
  certificates that machine-exclude CM-A/CM-B — nothing beyond the interface.

**After completion**: resume task 358 with `/revise 358` (re-key Phase 4-8 against the new
ambient guard, mirroring how task 367's completion drove `/revise 358` -> plan v06), then
`/implement 358`.

## Dependency Reasoning

This decomposition proposes exactly one new task, so there is no inter-task dependency graph to
reason about. All ordering (probe-cast before guard-definition before consumer-restatement before
probe-certification before re-probe) is INTERNAL phase sequencing within the single task, not a
task-level dependency — matching how 367 sequenced its own 6 phases inside one task rather than
splitting them across multiple spawned tasks.

## After Completion

Once the spawned task is complete, resume the parent task #358 with `/implement 358` (via
`/revise 358` first, to re-key Phases 4-8's targets against the newly landed ambient guard — the
same two-step resumption task 367's completion drove for this same parent task).

The blocker will be resolved because: the new ambient-side EF-closure guard eliminates CM-A and
CM-B from the antecedent population by construction (machine-verified via the new probe
certificates), which restores the truth of ledger rows 5/6/10-13 as the guarded consumer binders
will then state them — closing the ambient-side twin of the P17 gap that 367 closed on the fiber
side, and unblocking Phase 4 (and its downstream Phases 5-8) without disturbing Phase 3's
already-banked, ambient-realization-guarded landing.
