# Strategic Assessment: Task 98 Phase 4 Architectural Gap (Teammate D — HORIZONS, Round 4)

**Task**: 98 — Research filtration/quasimodel pivot for Until/Since truth lemma
**Round**: 4 (post Phase 4 PARTIAL)
**Role**: HORIZONS (long-term trajectory, scope descope, cut-losses analysis)
**Date**: 2026-04-10
**Session**: sess_1775873649_08b347
**Artifact**: 08_teammate-d-findings.md

---

## Context Recap

Three rounds of research and four attempted implementation phases have now
run against the filtration/quasimodel pivot. The current state is:

- **Phases 1-3 [COMPLETED]** — SubformulaClosure, EnrichedClosure, HintikkaPoint,
  Construction, refined QuasimodelChain with `defect_count` termination, all
  in-tree and sorry-free.
- **Phase 4 [PARTIAL]** — Two DerivationTree scaffolding lemmas
  (`bigconj_intro`, `bigconj_mem_iff`) landed; the main theorem
  `chain_step_seed_consistent` is not stated, because the architectural gap
  identified in `07_phase4-summary.md` shows that Teammate A's §3.3 reduction
  has an implicit premise (finite-MCS-consistency of `h_{i+1}`) that the
  current `HintikkaPoint` structure does not discharge.
- **Phases 5-8 [NOT STARTED]** — Blocked behind Phase 4.
- **Task 92** remains BLOCKED pending 98.
- **Tasks 93, 94, 95** remain NOT STARTED.
- **Three remediation options** are on the table in the Phase 4 summary:
  (1) strengthen `HintikkaPoint` with a consistency witness; (2) link
  `h_{i+1}` to an actual BXPoint (yielding a vacuous statement); (3) abandon
  the chain-step seed lemma entirely and build `BXUntilChain` directly at
  the BXPoint level with `bx_forward_witness` doing one-step discharge.

The prior horizons report (`03_teammate-d-findings.md`) already recommended
PARTIAL CLOSE of task 98 plus a spin-off task. That recommendation now has a
second round of evidence (Phase 4 failure) and should be re-evaluated: either
re-affirmed with stronger language, or replaced by a descope plan that leaves
task 98 in a defensible terminal state.

This report takes the latter position.

---

## Strategic Assessment (Continue vs Descope vs Pivot)

### The Accumulating-Cost Signal

Task 98 was originally scoped as an 8-12h research task. It has now absorbed:

1. Round 1 research (single-agent)
2. Round 2 team research (4 teammates)
3. Plan v1, plan v2, plan v3 (three full planning cycles)
4. Four implementation phases across multiple sessions, with Phase 4 the
   second failed gate check (plan v2 also halted at the seed consistency
   obligation)
5. Round 3 team research (3 teammates) that explicitly flagged
   `chain_step_seed_consistent` as one of the "two hard sub-problems"
6. Round 4 team research (now — 4 teammates against a single sub-problem)

The pattern is a textbook exponential-discovery spiral: each round of
research reveals that the previous round's reduction had an implicit premise.
Round 2 discovered the guard non-propagation issue, round 3 the defect-count
termination issue, and round 4 the `locally_consistent` vs
finite-MCS-consistent gap. Each new premise is a smaller technical gap
sitting inside a larger structural gap that the previous round took as an
assumption.

From a horizons perspective, this is the signal that **the canonical-model
Hintikka-chain approach has an inherent mismatch with the BX system's
algebraic structure**. The Hintikka chain is a linear-logic-level construction
(closure under classical consistency over a fixed subformula set); the BX
system's Until/Since semantics live in the reflexive linear order on BXPoints,
which carries much more structure than a Hintikka point can express. Every
reduction from the BXPoint level to the Hintikka level has to discharge that
structural gap somewhere, and every round discovers the gap has not been
discharged at the level of abstraction the current plan is using.

### The Plan v3 Exit Ramp Is Already Open

Plan v3 contains explicit escape hatches that have not yet been triggered:

- **Risk row (line 70)**: "if locus-control proof exceeds 12h, declare
  `locus_control_exhaustive` an axiom and re-scope."
- **Risk row (line 74)**: "After Phase 4 gate review, if remaining scope
  looks > 40h, split off Since + locus-control exhaustiveness into a
  follow-on task."
- **Rollback plan (line 361)**: "Gate B failure: halt, keep Phases 1-4
  committed (they are independently valuable), and draft plan v4 with a
  different chain-realization approach."
- **Rollback plan (line 363)**: "Total-effort overrun (>98h) after Phase 5:
  split Phase 6 + Phase 7 Since sorries + Phase 8 Since sorries into a
  follow-on task 99 scoped to ~20-30h; complete task 98 with Until direction
  only."

All of these are conditional on Phase 4 or later gates. We are now at the
Phase 4 gate with a partial completion and a second-order architectural
obstruction. The plan's own contingency language says "halt and re-scope."
It does NOT say "spawn round 4 research."

**Continuing round 4 research is in itself an escalation beyond the plan's
written contingencies.** That is a cost-discipline failure signal. The
strategic-horizons view is that this round of research should produce a
descope, not a new reduction attempt.

### Continue / Descope / Pivot — Recommendation

**Recommend: DESCOPE with an embedded PIVOT option.**

Specifically:

1. Accept task 98 Phases 1-3 as the research+infrastructure deliverable and
   declare them permanently valuable (they pass `lake build` at 950/950,
   introduce no sorries, no axioms).
2. Stop attempting `chain_step_seed_consistent` in the Hintikka formulation.
   The architectural gap is real and the cost of closing it (Options 1-3
   in the Phase 4 summary) ranges from "vacuous statement" to "duplicate
   Phase 3 at BXPoint level, 8-15h" to "introduce a new consistency field
   and cascade-rebuild HintikkaPoint, unbounded cost."
3. Mark task 98 as PARTIAL/COMPLETE in its research deliverable, with a
   clear completion note pointing to the next-task spin-off.
4. Redirect the Frame.lean Until/Since closure effort to a new strategy
   — not by continuing the quasimodel chain, but by adopting one of the
   alternative trajectories below.

---

## Alternative Trajectories

### Trajectory A: Split the 10 Target Sorries (recommended primary)

Task 98's full scope is 10 sorries (6 in `Realization.lean` + 4 in
`Frame.lean`). The Phase 4 summary is explicit that the Realization.lean
sorries are downstream of the Hintikka-chain construction — they close via
`chain_step_seed_consistent` + Phase 5 realization. If Phase 4 cannot be
closed, none of the Realization.lean sorries can be closed through the
quasimodel route.

**Observation**: The 6 Realization.lean sorries are internal to the
quasimodel subsystem. They are not blocking `bx_completeness`. The ROAD_MAP
(lines 21-22) explicitly lists the 4 Frame.lean Until/Since sorries + 1
Frame.lean Box sorry + 1 Completeness.lean TaskModel sorry as the 6
active-path sorries blocking `bx_completeness`. The Realization.lean sorries
are not in that list — they are in a new file added by task 98 Phase 2 that
would not exist at all if task 98 hadn't started.

**This means**: if task 98 is terminated without completing Phases 4-7, the
Realization.lean sorries (and the entire Quasimodel/ subdirectory) can be
left in the tree as infrastructure for a future attempt, OR archived to
Boneyard alongside task 94's archival, OR gated behind a `#guard_msgs`-style
sorry scaffold that does not count against the active-path sorry inventory.
The Realization.lean sorries are debt only if we keep them; they are
optional-to-delete.

The REAL debt reduction target is the 4 Frame.lean Until/Since sorries. Those
exist independently of task 98 and will exist regardless of whether task 98
succeeds.

**Trajectory A decision rule**:
- **IF** the goal is "close 10 sorries via task 98," then task 98 is failing
  and should be abandoned.
- **IF** the goal is "close the 4 Frame.lean Until/Since sorries," then
  task 98 was never the right vehicle — the Frame.lean closure is in
  `BXCanonical/Frame.lean`, not `BXCanonical/Quasimodel/Realization.lean`,
  and the quasimodel approach proves lemmas that do not actually touch
  `Frame.lean` without an additional "transfer" step that plan v3 has not
  yet designed (it lives implicitly in Phase 7-8).

Trajectory A is: **stop trying to prove `chain_step_seed_consistent`.
Archive `Quasimodel/` as partial-infrastructure to Boneyard (or gate it).
Return to a direct BXPoint-level Frame.lean proof in a new task (see
Trajectory B).**

### Trajectory B: Direct BXPoint `BXUntilChain` (Phase 4 Option 3, lifted out)

The Phase 4 summary's Option 3 is: build a `BXUntilChain` type at the
BXPoint level with `bx_forward_witness`. The summary notes this duplicates
Phase 3 at the BXPoint level (8-15h) but is "the cleanest mathematically."

This trajectory does NOT need the quasimodel infrastructure at all. It
works entirely with BXPoints, `bx_le`, `bx_forward_witness`, and BX5
(`self_accum_until`). The key insight in the Phase 4 summary (lines
135-155) is:

> `bx_forward_witness` gives `ψ ∈ v_k` in one step, but nothing about
> intermediate points satisfying `φ`. [...] the real deliverable for
> Phase 4 is not "seed consistency" at all, but a **multi-step BX-chain
> construction preserving the guard φ** at all intermediate points.

This is a cleaner problem statement than `chain_step_seed_consistent`. It
has three ingredients:
1. `bx_forward_witness` on `F(ψ)` (from BX10 via `until_F_mcs`) — exists
2. BX5 self-accumulation — exists
3. Well-founded termination on some decreasing measure — needs design

Trajectory B's cost is bounded because it does not need the abstract
Hintikka-chain machinery. The "duplicate Phase 3" concern in the summary is
overstated: Phase 3's `defect_count` decrease proof used `hintikka_step` as
the chain relation; at the BXPoint level the relation is `bx_le` plus
`untilDefectSet v_{i+1} ⊂ untilDefectSet v_i`, which follows directly from
`bx_forward_witness` discharging `ψ U φ` into `ψ ∈ v_{i+1}`. There is no
new well-founded recursion to design — it reuses the existing
`defect_count` function.

**Trajectory B as a new task**: Spawn task 99 "Direct BXPoint until/since
chain construction." Inherits nothing from task 98 except the
`subformula_closure` and `untilDefectSet` definitions (which are already
standalone lemmas, not tied to HintikkaPoint). Scope: 8-15h. Targets: close
4 Frame.lean sorries directly.

### Trajectory C: Axiomatize `chain_step_seed_consistent` and Move On

**This trajectory is rejected by the zero-debt policy** and is listed here
only to document why.

The Phase 4 summary's Option 1 implicitly suggests this via
"strengthen HintikkaPoint." The minimal version is:

```lean
axiom chain_step_seed_consistent {Sigma : Finset Formula} ...
```

with a documented justification that this follows from any full TaskModel
satisfying Σ. Then Phases 5-8 proceed assuming the axiom, closing the 10
target sorries at the cost of one new axiom.

**Zero-debt policy violation**: The project rule is "NEVER suggest
introducing new axioms as a solution." This trajectory explicitly violates
that rule. It is listed for completeness of the horizons analysis but
**NOT recommended** and should NOT be implemented.

The softer variant — replace `sorry` with `sorry` (i.e., leave the Hintikka
chain-step seed lemma as a sorry under a clear doc-comment) — also violates
the zero-debt policy. Both variants should be rejected.

### Trajectory D: TaskModel Embedding via Task 93 (Bypass Frame-Level Proof)

Prior horizons analysis (round 3) flagged that task 93's TaskModel
embedding could provide a semantic alternative to the frame-level Until/Since
proof. Round 3 rated this 65% confidence. One round later, with Phase 4
having failed on the frame-level side, this alternative gains relative value.

**The idea**: the 4 Frame.lean sorries prove properties of the BXPoint
canonical frame under `bx_le`. The TaskModel embedding (`Completeness.lean:154`)
constructs a full TaskModel from the BXPoint canonical frame, with non-constant
histories. If the TaskModel's truth conditions can be shown to agree with the
BXPoint frame (via a truth-preservation lemma), then `bx_completeness` can
be proved via: `valid φ → true_in_task_model φ → ¬consistent(¬φ)`, without
ever proving the truth lemma on the canonical frame directly.

In other words: **prove completeness on the TaskModel and project back**
instead of proving the truth lemma on the canonical frame.

This trajectory changes the target from "close 4 Frame.lean sorries" to
"prove the 1 Completeness.lean sorry with a strong enough TaskModel." It
is not obvious that this is easier — it may require a different set of
lemmas — but it is a genuinely different attack surface. And task 93 has
not yet been attempted, so its difficulty is unknown.

**Risk**: task 93's TaskModel construction might itself require Until/Since
witness availability at each BXPoint, in which case it inherits the
Phase 4 obstruction. Round 3 Teammate D's analysis already noted this
depends on the exact form of the embedding.

### Trajectory E: Modal Fragment Completeness (Tractable Publication)

From round 3 (unchanged): define `no_until_since : Formula → Prop` and
prove `bx_modal_fragment_completeness` as a restricted theorem. This
requires only task 93's Box sorry + TaskModel embedding (2 sorries, both
in scope for task 93). The 4 Until/Since sorries become irrelevant to this
sub-theorem.

**Strategic value**: publishable intermediate result that is genuinely
achievable in weeks, not months. Standard practice in tense-logic
literature.

**Trajectory E is orthogonal to the Until/Since closure effort** — it does
not replace it, but it does remove the schedule pressure that is currently
driving round-after-round research spirals. If the modal fragment
completeness is published first as a self-contained theorem, the Until/Since
work can proceed at its natural pace (Trajectory B as a separate task).

---

## Adjacent Opportunities (Tasks 93, 94, 95)

### Task 94 (Archive Legacy): Fully Unblocked, High ROI

Task 94 archives `UltrafilterChain.lean`, `FrameConditions/Completeness.lean`,
`DovetailedChain.lean`, `SuccChainFMCS.lean` to Boneyard. ROAD_MAP notes this
drops ~210 sorries from the total count. Depends only on task 91 (COMPLETED).

**Value signal**: task 94 is a pure-executable-today opportunity that has
been deferred for multiple rounds while task 98 consumes research budget.
Every additional round of task 98 research is an explicit opportunity cost
versus task 94.

**Recommendation**: Execute task 94 immediately. It is fully mechanical and
produces a 210-sorry visible drop that correctly reflects the codebase state.

### Task 93 (Box + TaskModel): Unblocked, Parallel to 98

Task 93's sorries are:
1. `Frame.lean:440` — `bx_modal_witness` (Box direction, S5 argument)
2. `Completeness.lean:154` — TaskModel embedding

Neither depends on the Until/Since sorries. The ROAD_MAP lists task 93 as
depending on task 92, but that is a sequencing convention for the full
`bx_completeness` theorem; the two sorries themselves can be closed in
either order. Task 92 being blocked on 98 does NOT actually block task 93's
lemma-level work.

**Opportunity**: Start task 93 now. It runs in parallel to any task 98 or
task 99 work. Its completion delivers the modal fragment completeness
milestone (Trajectory E) directly.

**Dependency relaxation proposal**: Update the ROAD_MAP's task graph to
mark task 93 as only **partially** depending on task 92 — specifically, the
final `bx_completeness` wiring depends on task 92, but task 93's two sorries
can be closed independently. This is a low-risk dependency reclassification
that unblocks parallel progress.

### Task 95 (Verification Audit): Can Start Opportunistically

Task 95 is `#print axioms` + sorry classification. It does not need all
prior tasks to be complete; it is a continuous-verification activity that
becomes more valuable as sorries decrease. Running it now against the
current state would produce a baseline audit that the Phase 4 work could
have used to verify "no new axioms introduced" (which the Phase 4 summary
already claims).

**Minor recommendation**: Run a partial task 95 audit now to establish the
baseline. Full task 95 can wait for task 93 + 98 closure.

### Task 98 -> Task 99 Spin-off

Concrete proposal: spawn **task 99** via `/spawn 98` with the blocker
description: "BXPoint-level direct Until/Since chain construction bypassing
quasimodel chain-step seed consistency. Target: close Frame.lean:653, 675,
690, 704 via BXUntilChain type + bx_forward_witness + BX5 guard propagation."

Task 99 inherits:
- `defect_count` definition (already standalone)
- `untilDefectSet` definition (already standalone)
- `bx_forward_witness` (pre-existing in Frame.lean, from BX10)
- `self_accum_until` (pre-existing in Theorems/Combinators)

Task 99 does NOT inherit:
- HintikkaPoint chain machinery
- `chain_step_seed_consistent` obligation
- Realization.lean sorries (those are local debt of the quasimodel attempt)

Estimated effort: 8-15h (per Phase 4 summary's Option 3 estimate, confirmed
here as reasonable because it reuses existing infrastructure).

---

## Creative / Unconventional Suggestions

### Suggestion 1: Reformulate by Strengthening the Precondition (not the Postcondition)

Round 4 premise reframing: instead of strengthening `HintikkaPoint` to carry
derivation-consistency (Option 1, high cost), **restrict the chain-step
lemma to HintikkaPoints that are already `sigma_signature` projections of
BXPoints**. This is a weaker restriction than "tie `h_{i+1}` to a BXPoint"
(Option 2): it says the chain only needs to work for Hintikka points that
came from BXPoints, not that it needs to produce BXPoints.

The resulting lemma statement:

```lean
theorem chain_step_seed_consistent_of_bxpoint_origin
    {Sigma : Finset Formula} (v_i : BXPoint)
    (h_{i+1} : HintikkaPoint Sigma)
    (h_from_bx : ∃ w : BXPoint, sigma_signature w Sigma = h_{i+1})
    (step : hintikka_step (sigma_signature v_i Sigma) h_{i+1}) :
    Derivation.Consistent (↑h_{i+1}.formulas ∪ g_content v_i.formulas)
```

This is NOT vacuous because `h_from_bx` gives a BXPoint witness `w` whose
MCS status provides finite-derivation-consistency, and the combined seed is
shown consistent via `g_content v_i ⊆ w.formulas` (since `bx_le v_i w`
follows from the chain step — this is the non-trivial part). Whether
`bx_le v_i w` actually holds is the remaining question; it depends on
whether the Hintikka chain step implies a `bx_le` relation between the
witnessing BXPoints.

This reformulation might not work — it is not clear whether `hintikka_step`
is strong enough to derive `bx_le` between the backing BXPoints — but it
is a strictly different angle than any of the Phase 4 summary's three
options and should be evaluated.

**Risk**: if this reformulation works, it makes the chain step a trivial
consequence of `bx_le` monotonicity, which suggests the entire Hintikka
chain is doing no work. That would validate Trajectory B (direct BXPoint
chain) as the correct approach all along.

### Suggestion 2: "Ship the Quasimodel as a Library, Not as a Proof Component"

The Phases 1-3 infrastructure (SubformulaClosure, EnrichedClosure,
HintikkaPoint, Construction, defect_count) is genuinely useful as
**decidability infrastructure** for bimodal logic. Even if the realization
lifting never closes, the Quasimodel subfolder could be marketed as:

- A finite model-checking certificate: given a formula and a Hintikka set,
  check satisfiability combinatorially.
- A decidability backend for the `Metalogic/Decidability.lean` module.
- A reusable formalization artifact for future BAO-style completeness work.

This is the **"ship what you have, not what you planned"** move. The
deliverable becomes "a Lean 4 quasimodel construction for bimodal logic,"
which is a publishable micro-result even if the completeness bridge is
not closed. Task 98's summary would read: "researched filtration/quasimodel
pivot; delivered quasimodel infrastructure; realized that realization
lifting requires a structural obstruction that is best addressed via
direct BXPoint construction (follow-on task 99)."

### Suggestion 3: Senior Proof Engineer Move — The "Stabilize and Split" Play

What would a senior proof engineer do? Based on the exponential-discovery
spiral pattern:

1. **Freeze task 98 at current state**. Commit the Phase 4 PARTIAL and
   the Round 4 research. Do NOT attempt a fifth reduction.
2. **Mark task 98 PARTIAL/COMPLETE** with explicit completion note:
   "Delivered research findings and Quasimodel infrastructure. Realization
   lifting deferred pending task 99."
3. **Spawn task 99** for Trajectory B (direct BXPoint chain).
4. **Start task 93 in parallel** — it does not depend on 98 or 99.
5. **Start task 94 in parallel** — completely unblocked.
6. **Plan a task 100 retrospective** to audit the task 98 spiral and
   encode a "max 3 rounds of research before forced descope" rule into
   `.claude/rules/`.

The tell that this is the right call: the Phase 4 failure mode is not
"we tried X and it didn't work," it is "we tried X and discovered the
statement itself is wrong." Round 3 corrected the statement of chain step
to use EnrichedClosure. Round 4 will presumably correct it again. Round 5
will correct round 4. This is a signal that the **problem formulation is
wrong**, not that the proofs are wrong. Engineers should stop producing
proofs and start producing a new formulation — which is exactly what
Trajectory B offers.

---

## Recommendation (with Explicit Decision Rules)

### Primary Recommendation

**DESCOPE task 98 immediately. Spin off task 99 for direct BXPoint chain
(Trajectory B). Start tasks 93 and 94 in parallel now.**

### Decision Rules

**Rule 1: Research budget exhausted**
- **IF** task 98 has completed >= 3 rounds of research and >= 2 failed
  phase gates, **THEN** descope via the plan's written rollback procedure,
  do not attempt a 4th reduction.
- **Current state**: 4 rounds, 2 failed gates (plan v2 seed consistency,
  plan v3 Phase 4). Decision rule triggered. Execute rollback.

**Rule 2: Trajectory selection**
- **IF** the quasimodel infrastructure (Phases 1-3) builds cleanly and
  introduces zero sorries, **THEN** keep it in-tree as infrastructure
  (not Boneyard).
- **IF** the Realization.lean sorries (6) exist only because of the
  quasimodel attempt (not pre-existing), **THEN** accept them as
  contained-debt OR delete the file and archive its contents.
- **Current state**: Phases 1-3 clean; Realization.lean sorries are
  task-98-introduced. Recommend: keep Quasimodel/ subfolder, mark
  Realization.lean with a file-level doc comment stating it is partial
  infrastructure pending task 99.

**Rule 3: Task 99 vs direct task 92 resumption**
- **IF** Trajectory B's BXUntilChain approach reuses existing BXPoint
  infrastructure (bx_forward_witness, BX5, defect_count) and does NOT
  require Quasimodel machinery, **THEN** it can be scoped as a resumption
  of task 92 rather than a new task 99.
- **IF** it requires new types / well-founded recursion / design work,
  **THEN** spawn task 99 for the design phase and resume task 92 for the
  proof phase.
- **Recommendation**: Spawn task 99 because Trajectory B requires a new
  `BXUntilChain` type design, and task 92's plan v1 was based on pure
  Burgess-Xu induction without a chain type — it would need re-planning
  anyway.

**Rule 4: Parallelization**
- **IF** tasks 93 and 94 are fully unblocked (no dependency on 98/99),
  **THEN** they should start NOW in parallel.
- **Current state**: both are unblocked per ROAD_MAP dependency graph
  when dependency reclassification is applied (task 93 box+taskmodel
  sorries are logically independent of task 92's Until/Since sorries).
- **Action**: start both tasks in parallel with task 99.

**Rule 5: Zero-debt policy**
- **IF** any proposed approach requires adding a sorry or an axiom,
  **THEN** it is rejected by policy, regardless of scheduling benefit.
- **Consequence**: Trajectory C (axiomatize) is permanently off the
  table. Trajectories A, B, D, E remain viable.

**Rule 6: Modal fragment fallback**
- **IF** task 99 (BXUntilChain) fails to close the 4 Frame.lean sorries
  within 3 attempts / 2 failed phase gates, **THEN** pivot to Trajectory E
  (modal fragment completeness) as the publication milestone and treat
  the full Until/Since completeness as a long-range research project.

### "When to Cut Losses" — Explicit Answer

The question in the prompt: "Given the research trajectory (3 rounds of
research, 4 failed phases), when is the right moment to cut losses and
choose a pragmatic scope descope?"

**Answer: now, at the end of round 4, before any round 5.**

The cost signal is unambiguous: the Phase 4 PARTIAL summary itself
recommends Option 3 (Trajectory B here), noting it "is the cleanest
mathematically." The architectural gap is not a local proof obstacle — it
is a signal that the Hintikka chain formulation itself is mismatched with
what BX Until/Since semantics require. Continuing to patch the Hintikka
formulation is building technical debt faster than closing sorries.

The "right moment" was arguably at the end of round 3 when Teammate C
flagged that `chain_step_seed_consistent` was one of "two hard sub-problems"
and plan v3 went ahead anyway. The second-best moment is now. The third-
best moment is never.

---

## Confidence Level

**High confidence (90%)** on the following:

1. Task 98 should be descoped immediately per plan v3's own rollback procedure.
2. Tasks 93 and 94 are currently unblocked and their deferral is opportunity
   cost loss.
3. Trajectory B (direct BXPoint chain via `bx_forward_witness`) is cleaner
   than Trajectory A (continuing the quasimodel chain) for closing the 4
   Frame.lean sorries, per the Phase 4 summary's own analysis.
4. The exponential-discovery pattern (rounds 2, 3, 4 each finding a deeper
   premise) is a signal that the problem formulation is wrong, not that
   the proofs are wrong.
5. Trajectory C (axiomatize) is rejected by zero-debt policy and should
   not be pursued.

**Medium confidence (60-70%)** on the following:

1. Trajectory B's cost estimate of 8-15h — this is the Phase 4 summary's
   own estimate and is the most accurate available, but BXUntilChain has
   not been attempted, so the estimate could be low.
2. Trajectory D (task 93 TaskModel embedding as a semantic bypass) — this
   depends on the exact form of the TaskModel construction, which has
   not yet been designed.
3. Suggestion 1 (reformulate by strengthening precondition to "BXPoint
   origin") — this is novel and has not been evaluated; it could unlock
   the Hintikka formulation or it could reveal that `bx_le` does not
   follow from `hintikka_step`, which would validate Trajectory B.

**Low confidence (40%)** on the following:

1. Whether task 99 should be a new task or a resumption of task 92 — this
   is a scheduling question dependent on how much design work Trajectory B
   requires, and that is unknown.
2. Whether the Quasimodel/ infrastructure is worth keeping in-tree (as
   partial infrastructure) vs. archiving to Boneyard. The call depends on
   whether future decidability work will use it, which is speculative.

---

## Artifacts Consulted

- `specs/098_research_filtration_quasimodel_pivot/summaries/07_phase4-summary.md`
  (Phase 4 PARTIAL summary with architectural gap analysis)
- `specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-d-findings.md`
  (prior horizons analysis, round 3)
- `specs/098_research_filtration_quasimodel_pivot/plans/03_quasimodel-pivot-plan.md`
  (plan v3 with Phase 4 obligations and rollback procedures)
- `specs/ROAD_MAP.md` (sorry inventory, task graph, critical path)
- `specs/TODO.md` (task 92-98 status and dependencies)

**Not modified (read-only mode honored).** No file edits were made. No
Lean MCP tools were invoked (strategic-horizons analysis does not require
lemma verification).

---

## Summary Line for Synthesis

**Cut losses now.** Descope task 98 per plan v3's own rollback procedure.
Spawn task 99 for direct BXPoint `BXUntilChain` construction (the Phase 4
summary's Option 3, lifted out of the quasimodel context). Start tasks 93
and 94 in parallel today. The Hintikka-chain formulation is exhibiting
exponential-discovery spiral — each round finds a deeper implicit premise
— which is the signal that the problem formulation, not the proofs, is
wrong. Trajectory B (direct BXPoint) + Trajectory E (modal fragment
completeness as fallback publication milestone) is the horizons-correct
play.
