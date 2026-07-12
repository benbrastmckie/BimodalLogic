# Blocker Analysis: Task #349

**Parent Task**: #349 - build_recursive_endchar_navigated_arity3_endpoint_primitive
**Generated**: 2026-07-11
**Blocker**: The v3 multi-anchor recursion's Phase-5 base case (`endCharN0_correct`) is proven
machine-checked UNPROVABLE — no `TemporalPred`/`Formula`, single-world-evaluated, can be
biconditional to the full arity-`n` atom layer `nf_eval_nf` for arbitrary externally-supplied
anchors `env j` (`j >= 1`), and navigation (`Until`/`Since`) can never reach those anchors because
they are not model-order-determined. There is no in-tree Lean analogue of the escape hatch the
plan and audit both point to (Rabinovich Lemma 3.2(2)'s ≤2-free-variable reduction).

## Root Cause

**Category**: Missing prerequisite (a required structural lemma does not exist in-tree) combined
with a proven design infeasibility in the current plan's main line.

The `.orchestrator-handoff.json` blocker `blk-349-p5-world-local-infeasible` (Phase 5 of
`plans/03_multi-anchor-navigating-characteristic.md`) is definitive, not speculative: two
sorry-free, green theorems in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean`
close the case machine-checked, with axioms exactly `[propext, Classical.choice, Quot.sound]`:

- `endCharN0_correct_world_local_obstruction` — any base `H` satisfying the frozen target
  `(endCharN0 ...).eval_at M atomMap (env 0) <-> nf_eval_nf M 0 n env qnf` forces
  `nf_eval_nf M 0 n env qnf <-> nf_eval_nf M 0 n env' qnf` whenever `env 0 = env' 0`, i.e. the
  characterization can never depend on `env` at positions `>= 1`.
- `endCharN0_correct_infeasible` — a concrete 2-point Bool counter-model (`Mcex`, one predicate,
  interpreted as `(· = true)`) at `n = 2` derives `False` from that forced independence, i.e. no
  base exists at all, not even a complicated one.

The obstruction is structural, not a proof-engineering gap: `TemporalPred.eval_at tp t` (via
`temporal_truth M atomMap t tp.formula`, `ExistsForallNF.lean:53`) is a function of the single
world `t` only, but the frozen RHS `nf_eval_nf M 0 n env qnf` (`NormalForm.lean:198`) reads
`M.interp p (env j)` for every position `j` including `j >= 1`, and `env` is an arbitrary
function supplied by the caller — not a sequence of navigation witnesses. Varying `env` at
position `1` changes the RHS while leaving the (single-world) LHS fixed, so the biconditional is
a non-theorem for every candidate base. Phase 6 (`nf_endpoint_tl_gen`'s multi-anchor converter)
inherits the identical wall one arity up (handoff `continuation_context`), so proceeding as
planned would only relocate, not resolve, the failure.

`reports/02_rabinovich-faithfulness-audit.md` (§Q4, target 4, citing Rabinovich md:119) and
`plans/03_multi-anchor-navigating-characteristic.md` (§Rollback/Contingency, "Escape hatch")
converge independently on the same fix, both flagged uncertain only because the Lean asset is
missing:

> "If the multi-anchor navigating characteristic proves not to exist within `TL(Until,Since)` at
> the climbing arity, the correct conclusion is that the Lean encoding must apply Rabinovich's
> Lemma 3.2(2) ≤2-free-variable REDUCTION (md:119) before navigating — keeping the recursion at
> arity ≤ 3 (two anchors + witness) as the green arity-3 `nf_zone_flatten_navigable` line does.
> This is the alternative faithful architecture; it requires a Lean analogue of Lemma 3.2(2)
> (does not currently exist in-tree — mark uncertain)." (report 02, §Q4 target 4)

The paper source confirms the target precisely (Rabinovich 2014, §3, md:119, **Lemma 3.2**):

> "(2) Every →∃∀-formula is equivalent to a conjunction of →∃∀-formulas with at most two free
> variables."

This is exactly the reduction the green arity-3 `nf_zone_flatten_navigable` line already exploits
implicitly (two anchors + one witness, never climbing), but no general-arity Lean lemma
establishing the reduction exists — the plan's own `nf_char3_deeper_split` collapse and the
single-anchor `navBrickForm` reshape are both explicitly FORBIDDEN alternatives (H4-refuted in
report 02). The user has decided (per dispatch instructions) to unblock via SPAWN rather than
REVISE-in-place or ACCEPT-BLOCKED.

## Proposed New Tasks

### New Task 1: Formalize the Rabinovich Lemma 3.2(2) ≤2-free-variable reduction for `NormalForm`/`nf_eval_nf`

- **Effort**: high
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Rationale**: This is the single missing structural asset both the audit (report 02, §Q4
  target 4) and the plan (v3, §Rollback/Contingency) name as the only faithful way out of the
  proven infeasibility `blk-349-p5-world-local-infeasible`. Task 349's recursion cannot be
  re-planned onto a viable line until this lemma exists in-tree; every other avenue (single-anchor
  reshape, `nf_char3_deeper_split` arity collapse, residual reintroduction) is independently
  H4-refuted or explicitly forbidden by the plan. Delivering this as a standalone, reusable,
  sorry-free Lean asset lets `/revise 349` (v4) assemble the recursion strictly on top of it
  without re-deriving the reduction inline and without climbing arity past 3.
- **Depends on**: None (foundational; task 349 depends on this task by skill postflight
  convention, not the reverse)

**Description for implementer**:

Build a reusable, green, sorry-free Lean structural lemma (or minimal cohesive family of lemmas)
in a new file
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Lemma32Reduction.lean` that is
the Lean analogue of Rabinovich (2014) **Lemma 3.2(2)** (`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`,
around md:119): *"Every →∃∀-formula is equivalent to a conjunction of →∃∀-formulas with at most
two free variables."*

Concretely, over this project's `NormalForm`/`nf_eval_nf` types
(`Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean`, `nf_eval_nf` at line 198;
`AtomKind` at line 113) and the `ExistsForallNF`/`TemporalPred` types
(`Theories/Bimodal/Metalogic/WeakCanonical/ExistsForallNF.lean`, `TemporalPred.eval_at` at
line 53), the lemma must show that for arbitrary arity `n`, evaluating `nf_eval_nf M k n env qnf`
against an arbitrary `env : Fin n -> M.carrier` is equivalent to a finite conjunction of
`nf_eval_nf`-style facts each restricted to **at most two free anchor positions** (i.e. `Fin` n'
with `n' <= 2`, or an arity-`<=3` shape once the existential witness position from `nf_eval_nf`'s
own recursive unfolding is included — matching the "two anchors + one witness" shape the *green*
`nf_zone_flatten_navigable`/`_correct` two-anchor lemma already uses,
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean:667-697`). The
reduction must happen BEFORE any navigation step, i.e. it decomposes the arity-`n` obligation into
arity-`<=3` pieces at the `NormalForm`/`nf_eval_nf` level, so that when task 349's recursion later
navigates each piece with `Until`/`Since`, it never needs to climb past arity 3.

**Motivation to cite verbatim in the module docstring**: the two in-tree refutation theorems
`endCharN0_correct_world_local_obstruction` and `endCharN0_correct_infeasible`
(`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean`) prove that the
climbing-arity single-world base is impossible, and `reports/02_rabinovich-faithfulness-audit.md`
(§Q4 target 4, H3 lemma-mapping table) is the faithfulness ground truth establishing that this
Lemma 3.2(2) reduction is the paper's own prescribed alternative, not an ad hoc invention.

**Reusable assets to build on (do not re-derive)**: `nf_endpoint_tl_gen`/`_correct`
(arity-generic atom-layer + quant-clause assembly, Base.lean:1879/1893), `atomPartN`
(Base.lean:1866), `seg`/`seg_holds_coupled` (Base.lean:1127/1150), and the green two-anchor
`nf_zone_flatten_navigable`/`_correct` full-eval hook shape (Base.lean:667-697) as the template
for what a faithful ≤2/≤3-anchor decomposition must look like structurally.

**Explicitly forbidden** (H4-refuted or plan-forbidden; do not reintroduce): the single-anchor
`navBrickForm` reshape (Option A of report 02, refuted — a provably-true LHS against a
provably-false RHS for disagreeing `sub`), `nf_char3_deeper_split` arity collapse (grows anchors,
the very failure mode), and reintroducing a free-standing `NavResidual`/`h_nav` predicate-layer
residual at the inner witnesses (the refuted v2 route).

**Deliverable / acceptance criterion**: a green, sorry-free, 0-new-axiom (beyond
`[propext, Classical.choice, Quot.sound]`) Lean theorem (or minimal family) stating the ≤2/≤3
free-variable equivalence for `nf_eval_nf`, committed under
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`, verified by `lake build`.
This does NOT include re-architecting task 349's recursion itself — that is out of scope for this
task and is deferred to `/revise 349` (v4) once this lemma lands.

**file_scope**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`

## Dependency Reasoning

Only one task is proposed, so there is no intra-batch dependency graph to reason about. Per
the dispatch instructions, task 349 will be made to depend on this new task by skill postflight
(not the reverse): task 349's re-plan (v4) needs the concrete signature and proof shape of the
Lemma 3.2(2) reduction lemma before it can decide how the recursion assembles arity-`<=3` pieces
on top of it — that is an implementation-detail dependency (the exact statement shape, whether
the decomposition is conjunctive or existential-of-conjunctions, and which arity-`<=3` shape it
bottoms out at) that only exists once this task's deliverable is committed. No second task is
needed: the re-planning/assembly step is a `/revise 349` operation on the existing task, not a
new spawned task, per the task's own instructions ("once it lands, task 349 can be re-planned
(v4) to assemble the recursion on top of it").

## After Completion

Once the new task is complete, resume the parent task with `/implement 349` is NOT the correct
next step — the plan itself is invalidated by the proven infeasibility. Instead, run
`/revise 349` to produce plan v4, re-architecting the recursion onto the ≤2/≤3-free-variable line
established by the new task's lemma (arity capped at ≤3, never climbing to `n+1` distinct free
anchors), then `/implement 349` against the new plan.

The blocker will be resolved because: the Lemma 3.2(2) reduction eliminates the need for any base
case to certify an arbitrary-arity `env` in one shot — each arity-`<=3` piece is exactly the shape
the *already-green* `nf_zone_flatten_navigable`/`_correct` two-anchor template certifies, so the
world-locality obstruction (a single-world `TemporalPred` cannot reach externally-supplied
`env j`, `j >= 1`) never arises: navigation only ever needs to reach the ≤2 anchors + 1 witness
that are already within the arity-3 shape's reach.
