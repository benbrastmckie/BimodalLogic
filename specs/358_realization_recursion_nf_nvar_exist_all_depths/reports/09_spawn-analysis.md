# Blocker Analysis: Task #358

**Parent Task**: #358 - realization_recursion_nf_nvar_exist_all_depths
**Generated**: 2026-07-14
**Blocker**: The general-m G2 kernel (rows 8-9 binders `hsliceFut`/`hslicePast`,
`EndIntervalConsumerK.lean:154-167`) is machine-refuted by an all-honest tail-doppelgänger
countermodel at fiber depth 1 — the m=0 depth-0-losslessness generalization does not survive
one fiber layer down.

## Root Cause

Plan v05 Phase 2 dispatched the general-m G2 gate (G2-1 `kvE_{fut,past}SliceId_of_end` at
general `m`, plus the rows 8-9 supply binders). Per the implementer handoff
(`handoffs/phase-2-v05-handoff-20260714.md`) and summary
(`summaries/05_realizer-recursion-v05-summary.md`):

1. **P2-0 re-probe gate PASSED**: task 364's co-realization strengthening of
   `kvE_fiberElemConsistent` fully dissolved the v04 planted-mate blocker (certificates
   `kvE_probe364_sigma2_inadmissible`, `kvE_probe364_sstar_honest_unrealizable`, both
   sorry-free at floor axioms). This confirmed the 364 re-key HELD.

2. **P2-1 population check PASSED-WITH-ADVERSE-FINDING**: the G2 supply population is
   realizer-derived exactly as designed (report 08 §3) — but the countermodel discovered
   this session is realizer-derived *too*. Carrying a realizer pins nothing about the
   realizer's tail.

3. **Route-R2 machine probe (mandatory before any kernel build) — NO-GO**: a new additive
   leaf `ExteriorPinnedProbe358TailK.lean` produced two sorry-free certificates at floor
   axioms `[propext, Classical.choice, Quot.sound]`, zero guard-unfoldings, zero
   production/frozen edits:
   - `kvE_probe358_tailDG_gapItem_pinned_fails` — the free-env -> pinned upgrade (the
     load-bearing step of the m=0 kernel `kvE_futSliceId_of_end_zero`, and hence of the
     planned general-m generalization) is FALSE at fiber depth 1: an honest
     tail-doppelgänger fiber satisfies every antecedent of the upgrade yet has no pinned
     realizer (its marked inner demands an R-point in the real `(x,w)` window — empty).
   - `kvE_probe358_tailDG_sigma_in_population` — the fake slice passes the
     364-strengthened `kvE_futAdmissible` through the sanctioned byte-stable route
     (`kvE_futRealizer_admissible`), sits on the REAL ambient's fiber
     (`nfk_dropFresh σ = qnf.1`), and marks the un-pinnable fiber on its gap zone list. The
     countermodel lives *inside* the population the 364-strengthened guard admits — task
     364's co-realization check has no purchase here because there is no fake fiber and no
     plant, only a second, deeply-different but honestly realized environment.

**Why this generalizes the blocker pattern from 363/364**: task 363 restated the depth-1
fiber-marking interface; task 364 strengthened the depth-0 atom-row mate check with
co-realization. Both fixes anchor the population at the *depth-0* row
(`nfk_dropFresh σ = qnf.1`). The new countermodel shows this depth-0 anchor is
insufficient once fiber depth ≥ 1 is in play: nothing in the antecedents ties a marked
fiber's realizing tail to the ambient beyond that single depth-0 row, and the clause
family's item content (`kvE_futItemShift` via `P.existF 4`) is intrinsically
env-existential (`kvE_futItemShift_correct : … ↔ ∃ env, …`). This is a genuinely new,
one-layer-deeper interface gap — not a re-litigation of 363 or 364, and not solvable by
strengthening the same depth-0 guard again (route R2 already refutes any m=0-generalization
argument at depth 1).

**Root cause category**: Technical unknown / design ambiguity at the interface layer — the
population predicate (`kvE_fiberElemConsistent` + `kvE_futAdmissible`) needs a
depth-recursive (hereditary) anchoring condition that does not yet exist, and multiple
candidate shapes are named in the handoff without a committed design (candidate (a):
recursive on-fiber guard tying σ's marked fibers' one-slot-dropped DEEP forms to
qnf's deep marking one level down; candidate (b): restate rows 8-9 with a deep on-fiber
condition replacing `nfk_dropFresh σ = qnf.1` directly).

## Proposed New Tasks

### New Task 1: Deep-anchor exterior fiber population against tail-doppelgänger (interface refinement)

- **Effort**: high (multi-session; Lean 4 formal proof interface redesign + re-probe)
- **Task Type**: lean4
- **Rationale**: This is the sole blocker preventing Phase 2 (and therefore Phases 3-6) of
  task 358 from proceeding. It is scoped exactly to the interface repair the implementer
  handoff names as the escalation target — no broader scope is needed, matching how task
  364 was a single isolated interface-strengthening task.
- **Depends on**: None

**Full description for the implementer** (to be placed verbatim, or near-verbatim, into the
task's `description` field):

> Design and land a depth-recursive (hereditary) on-fiber/content guard that anchors the
> exterior fiber population to the ambient one layer deeper than the current depth-0 row
> check (`nfk_dropFresh σ = qnf.1`), replacing that antecedent in the rows-8-9 binders
> (`hsliceFut`/`hslicePast`, `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean:154-167`).
> Candidate shapes (from the handoff, not prescriptive — the implementer selects and
> justifies one): (a) a recursive on-fiber guard requiring σ's marked fibers'
> one-slot-dropped DEEP forms to be qnf-marked one level down (hereditary fiber anchoring);
> (b) restate the rows-8-9 antecedents with a deep on-fiber condition replacing
> `nfk_dropFresh σ = qnf.1` directly, following the `ExteriorFiberConsistencyK.lean`
> guard-and-`_of_realized`-lemma template task 364 landed, one layer down.
>
> **Methodology — re-probe is the definition of done** (per tasks 363/364): before any
> kernel/guard change, and again after landing it, machine-probe the candidate guard against:
> (1) the NEW countermodel family this task exists to defeat —
> `kvE_probe358_tailDG_gapItem_pinned_fails` and `kvE_probe358_tailDG_sigma_in_population`
> in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358TailK.lean`
> — the tail-doppelgänger must be provably EXCLUDED from the refined population (or provably
> pinned) after the change; and (2) ALL prior 358/363/364 fakes/probes (the frozen reference
> layer: `ExteriorFiberConsistencyProbeK.lean`, `ExteriorFiberConsistencyProbe364K.lean`, and
> the historical `kvE_probe358_eP_atomMate_present` record) to confirm the refined guard does
> not reopen any previously-closed hole. Do not treat a build-green kernel as sufficient —
> the task is done only when the tail-doppelgänger probe is machine-certified excluded
> (sorry-free, floor axioms `[propext, Classical.choice, Quot.sound]`, zero guard-unfoldings)
> AND the 363/364 probes remain green.
>
> **Preserve byte-for-byte**: m=0 kernels (`_zero` suffix family,
> e.g. `kvE_futSliceId_of_end_zero`), the k≤1 rungs (`kampPrior_case1_arm_k0`), task 360's
> m=0 supply, and ALL of task 363/364's guard/lemmas/probes
> (`ExteriorFiberConsistencyK.lean`, `ExteriorFiberConsistencyProbeK.lean`,
> `ExteriorFiberConsistencyProbe364K.lean`) — zero edits to any of these files. Preserve the
> never-unfold-the-guard routing rule: discharge only via the byte-stable `_of_realized` /
> `_admissible` lemmas, never by unfolding `kvE_fiberElemConsistent` directly.
>
> **Zero-debt terminus**: no `sorry`, no vacuous definition, no forcing a proof against a
> live countermodel. If the refined guard cannot be landed sorry-free and green against both
> probe families, return the task as `[BLOCKED]` with a structured escalation record
> (matching the format of this session's own handoff) rather than papering over the gap.
>
> **Scope boundary — MUST NOT**: attempt the general-m G1/G2 supply build-out itself (the
> four G2 supply theorems, G1 interior supply, or the `:519`/`:522` sorry retirements in
> `KampPrior.lean`). That work remains task 358 Phase 2/3 and resumes via `/revise 358` once
> this interface-refinement task lands and the rows-8-9 interface is re-keyed.
>
> **References**:
> - `specs/358_realization_recursion_nf_nvar_exist_all_depths/handoffs/phase-2-v05-handoff-20260714.md`
>   (full root-cause analysis and binder-level closure argument)
> - `specs/358_realization_recursion_nf_nvar_exist_all_depths/summaries/05_realizer-recursion-v05-summary.md`
>   (verification transcript, plan deviations)
> - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358TailK.lean`
>   (the two machine certificates this task must defeat)
> - Task 364's landed pattern in `ExteriorFiberConsistencyK.lean` (guard definition +
>   `_of_realized` lemmas) as the structural template to follow one layer down
> - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean:154-167`
>   (the rows-8-9 binders `_hsliceFut`/`_hslicePast` to be restated)

**Anticipated `file_scope`**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyK.lean` (read-only reference template — MUST NOT edit)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean` (rows 8-9 restatement, lines 154-167)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/` (new additive guard/lemma file(s), e.g. a `ExteriorFiberDeepConsistencyK.lean`-style module, plus a new probe leaf following the `ExteriorPinnedProbe358TailK.lean` / `ExteriorFiberConsistencyProbe364K.lean` naming pattern)
- `specs/358_realization_recursion_nf_nvar_exist_all_depths/` (its own task artifacts: reports, plans, handoffs, summaries — since this is expected to be created and tracked as a subtask under the same lineage; exact directory assigned at task creation)

## Dependency Reasoning

Only one task is proposed, so there is no intra-batch dependency graph to reason about. This
follows the Task Minimization Principle directly: the blocker has a single, well-scoped root
cause (a missing depth-recursive anchoring condition in one interface), and task 364 already
established the precedent that this class of interface-refinement blocker is resolved by
exactly one isolated task (guard design + re-probe + landing), not by splitting design from
implementation from verification. Splitting this into "design the guard" / "implement the
guard" / "re-probe the guard" sub-tasks would be counter-productive: the guard's specific
shape (candidate (a) vs (b) in the handoff) cannot be committed to until the implementer has
attempted the re-probe against `kvE_probe358_tailDG_*`, so design and implementation are not
separable without forcing premature commitment. The re-probe is not verification-after-the-fact,
it is the actual specification of correctness — this is intrinsic to the "re-probe is the
definition of done" methodology and cannot be pulled into a separate task without breaking the
feedback loop that makes the design tractable.

**Component 4a (file footprint overlap check)**: Not applicable — a pairwise overlap check
requires 2+ tasks in `new_tasks[]`. With exactly one proposed task, there is no auto-dependency
to add.

## After Completion

Once the spawned task is complete, resume the parent task #358 with `/revise 358` (per the
implementer handoff's explicit next-step direction: `/revise 358` to re-key Phase 2 against
the refined interface), then `/implement 358`.

The blocker will be resolved because: once the rows-8-9 binders (`hsliceFut`/`hslicePast`)
are restated against a depth-recursive population guard that is machine-certified to exclude
the tail-doppelgänger family (and all prior 363/364 fakes), the general-m G2-1 slice-identification
kernel has a population it can actually be proved against — the current blocker is precisely
that no such population exists yet. G2-2, G1, and rows 10-11 (all named in the handoff as
"downstream of the same restatement") become buildable once this lands, and the two live
`KampPrior.lean` sorries (`:519`, `:522`) — currently upstream-blocked — become reachable
again through Phase 2/3 of the resumed parent task.
