# Blocker Analysis: Task #321

**Parent Task**: #321 - implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution
**Generated**: 2026-07-07
**Blocker**: The v3 plan's Stage C soundness scaffolding (Phase 8) hit a machine-grounded structural
obstruction: the landed `kvE_subBracket` (task-321 Stage A) cannot supply the per-sub soundness
crux because its single upward `Until` chain from the σ-slot `u` cannot reach σ's `zXU = (x,v,u)`
interior zone (which lies *below* `u`), and the sole landed connector
`kvE_subBracket_implies_subChain` runs in the wrong direction for soundness (bracket-holds →
chain-at-point, not the needed chain-at-point → full arity-4 eval reconstruction). Per the user's
explicit direction, the fix is broken out as an explicit prerequisite task rather than absorbed
into a v4 revision of task 321's own plan.

## Root Cause

**Category**: Missing prerequisite (design defect in a landed asset, discovered only when the
proof-side consumer was attempted) — with elements of technical unknown (the completeness
direction is genuinely unprobed at k≥2).

Phase 8 of plan v3 (`plans/03_corrected-k2-carrier-gate-v3.md:268-326`) recorded the full
machine-grounded blocker. Summary of the chain of reasoning:

1. `bracketEndChar_kvE2`'s soundness direction reduces, via the landed `two_eq` bridge +
   `k1v_bracket_extract` (:2150), to a per-positive-σ obligation
   `∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ`, whose only resource is the outer witness slot
   carrying `kvE_subChain σ` holding at a single point `u`.
2. Machine-driving this obligation through `nf_eval_depth1_fold_iff` (the plan's own Stage-D
   engine, applied in reverse) produces three sub-goals:
   - `refine_1`: σ.1's full atom layer (order + predicate bits over all four positions
     `[u,w,x,t]`) — `kvE_subChain` carries none of this; the sub-bracket reads `σ.2` only.
   - `refine_2.mpr`: the interior-fold `⟸` direction for an *arbitrary* `ZoneSpec 4` — but
     `kvE_subChain` is a strictly upward `Until` chain from `u` (`fChainFrom_base`/`_step`), so
     σ's own `zXU = (x,v,u)` interior zone (below `u`) is structurally unreachable.
   - `refine_3`: off-fiber falsity, which needs the outer `kvE_gate`, absent from the isolated
     crux.
3. The only candidate connector, `kvE_subBracket_implies_subChain`, has hypothesis `bf.holds
   z0 z` (the sub-bracket holding on an interval) — this is the reverse of what soundness needs
   (there one HAS `fChainPred @ u` and NEEDS σ's full eval). `lean_multi_attempt`/`exact?` could
   not close the gap; this is not an effort problem, it is a direction mismatch.
4. The `zXU` gap is a structural property of the *construction* `kvE_subBracket` (a single upward
   chain from the σ-slot), not a proof-side deficiency — fixing it requires changing which zones
   the sub-bracket's chain can reach, i.e. a redesign of the landed Stage-A asset itself, which the
   binding do-not-edit constraint forbids doing in place inside task 321's own Stage C/D phases.
5. Separately, even with a corrected sub-bracket shape, no arity-4 sub-bracket *correctness* pair
   (soundness + completeness, re-deriving the k1v `:2338`/`:2979` templates one arity up with a
   cross-body σ.1 atom-layer channel) exists among the landed Stage-A/B assets — it is genuinely
   unbuilt, not merely unassembled.

The recorded remedy in `.orchestrator-handoff.json` (`continuation_context.remedy`) explicitly
offers two options: fold the redesign + correctness pair into a v4 of task 321's own plan, OR
"spawn the sub-bracket-correctness lemmas as an explicit prerequisite task." The user has directed
the latter.

## Decomposition Rationale: ONE task, not two

The candidate two-way split would be: (1) a Stage-A' redesign task (produce a corrected
sub-bracket construction where all three interior zones, including `zXU`, are reachable — e.g. a
Since+Until pair, or anchoring the chain at `x` instead of `u`) and (2) a separate arity-4
sub-bracket soundness+completeness task consuming (1)'s output.

**This analysis rejects the two-task split and proposes ONE task instead**, for a reason specific
to this codebase's own failure history: the ORIGINAL `kvE_subBracket` (task-321 Stage A) was
itself a construction that type-checked, passed its own probes, and was landed as `[COMPLETED]`
*before* anyone attempted to prove the correctness pair against it — and the zXU gap discovered in
Phase 8 is precisely a design defect that a construction-only phase could not see, because it only
becomes visible when the soundness direction is actually driven through
`nf_eval_depth1_fold_iff`. Splitting the redesign from the correctness proof into two different
task dispatches (and, worse, two different task NUMBERS with a hand-off artifact in between)
reproduces exactly the bug pattern that caused this blocker: a design accepted on
type-correctness/probe grounds alone, validated as "correct" only later, too late to cheaply
revise. The redesign choice (Since+Until pair vs. anchor-at-`x`) also directly *dictates* the
shape of the correctness proof (which direction chain is available at which zone, what the
atom-layer recovery argument looks like) — this is not a loose "B needs A to exist" dependency but
a tight co-design where the right redesign is discoverable only by attempting the proof. One task,
one continuous dispatch with proof-driven iteration on the construction, is the only way to
guarantee the delivered sub-bracket is actually correct rather than merely plausible.

The task's effort estimate (10-14 hours) reflects this being the single hardest, most novel
remaining unit of task 321's total scope (the k1v analog templates for this direction pair span
~800 lines at k=1; the k=2 sub-bracket case adds the never-before-attempted cross-body σ.1
atom-layer channel).

## Proposed New Tasks

### New Task 1: Redesign k=2 sub-bracket and prove its arity-4 soundness+completeness correctness pair
- **Effort**: 10-14 hours
- **Task Type**: lean4
- **Rationale**: Unblocks task 321 Phase 8 by supplying (a) a corrected `kvE_subBracket`-shaped
  construction whose chain(s) can reach all three interior zones (`zXU`, `zUW`, `zWT`), and (b) the
  arity-4 soundness+completeness correctness pair for that construction — the two things task 321's
  own Phase 8 discovered were missing and undeliverable from inside the existing Stage C/D
  decomposition without editing a do-not-edit landed asset.
- **Depends on**: None.

## Dependency Reasoning

Only one new task is proposed, so there is no internal dependency graph to reason about beyond the
task's own relationship to the parent. Task 321 (parent) depends on this new task's output: task
321's Phases 9-15 (the remaining non-joint channel closers, completeness assembly, and final
verdict) currently assume the *existing* `kvE_subBracket`/`kvE_subChain` are sufficient soundness
resources; they are not. After this new task lands, task 321 will need a `/revise` to a v4 that
re-points its Phase 9+ obligations at the new task's delivered construction and correctness lemmas
(rather than attempting to re-derive Stage C/D directly against the original, now-superseded,
sub-bracket shape).

## What The New Task Must Carry Forward (binding constraints, self-contained)

The new task's description embeds the following constraints verbatim so it can be researched,
planned, and implemented without re-reading task 321's full plan history:

- **Guards G1-G6 + Corrected Anchor-Cap** (from task 309/311 lineage, restated in
  `specs/309_offdiag_two_anchor_fi_chain/plans/07_offdiag-fi-chain-plan.md:230-260`): no arity-1
  collapse (G1); no projection-based third-free-anchor tower (G2); no trivial-top segment on
  carrier interval types (G3); `w`/interior witnesses stay bracket witnesses, anchor set fixed at
  `{x,t}` (G4); Cor 5.4/Prop 3.5 `F_i` chains step-by-step with Rabinovich citations at every chain
  step, no `simp`/`omega`/`aesop` shortcut (G5); the carrier stays the two-anchor bracket
  characteristic with fixed endpoints, codomain may be witness-growing `VVecEA2` but anchor count
  never exceeds 2 (G6 + amendment).
- **Amendment F3**: no provider-side pinning — the provider disappears from the joint path rather
  than being pinned; no `w = e 1`/`x = e 2` residual equation on the joint path.
- **Do-not-edit landed assets, byte-identical**: `BracketCarrierCorrectVPrior`, `ExistProviders`,
  all task-310/311 material, the task-320 probes, `bracketEndChar_k1v`/`_sound`/`_complete` and the
  full k1v proof kit (:2028-2825), `EANegation`'s `bracket_implies_fChainPred` (:660), and — with
  the ONE explicit exception below — task-321's own Stage A/B code (`kvE_subFoldBits`,
  `kvE_subInteriorZones`, `kvE_subBracket`, `kvE_subChain`, `kvE_subBracket_implies_subChain`,
  `kvE2_body` + gate-fail, `bracketEndChar_kvE2` + `two_eq`, the Stage-B discrimination lemmas).
  **Explicit exception (authorized by this blocker record, not a general license)**: this task MAY
  add new, separately-named definitions (e.g. `kvE_subBracket2`/`kvE_subChain2`, exact names left
  to the implementer) rather than editing the existing `kvE_subBracket`/`kvE_subChain` in place —
  those original definitions stay byte-identical and unreferenced by the new work. This task does
  NOT need to, and MUST NOT, edit `kvE2_body`/`bracketEndChar_kvE2` to re-point at the new
  construction — that re-pointing is task 321's own resumption work (a `/revise 321` v4 phase),
  strictly out of scope here. This task's sole deliverable is the new, additively-defined,
  correctness-proven sub-bracket construction and its soundness+completeness lemma pair, stated
  and proved standalone (against `nf_eval_nf M 1 4`), not yet wired into the outer gate.
- **Consume-do-not-rebuild list** (task 321 lineage, `specs/309.../plans/07_...md:142-196`):
  `nf_eval_depth1_fold_iff` (:5187), `nf0_assemble` (`NfEFold.lean:180`), the general fold engine
  `nf_quant_layer_fold_iff` (`NfEFold:391`), zone semantics kit (`zoneHolds`/`EAtomDom`), `k1v`
  helper kit (`k1v_zoneHolds_cons_iff`/`k1v_zone_consistent`/`k1v_bracket_extract`/
  `k1v_reconstruct_nf3`/`k1v_sorted_insert`/`k1v_sorted_realization`/`k1v_bracket_construct`,
  :2028-2825), `bracketEndChar_k1v_sound`/`_complete` direction templates (:2325/:2966 in the k1v
  lineage; :2338/:2979 as cited in task 321's Phase 8/13 record), `BracketFormula.
  bracket_implies_fChainPred` (`EANegation:660`), `existsBounded_right` (`VecEAClosure:265`).
- **No `EANegation :1090/:1249`** (the uniform-backward variants) may be consumed.
- **No `simp`/`omega`/`aesop` on chain-construction steps**; `by omega` permitted only for
  `Fin`-index typing obligations in signatures. Cite Rabinovich at every chain step per G5.
- **No `sorry` on any live path** at any point, including intermediate WIP — a `sorry`-free
  skeleton committed mid-proof is not permitted; keep unfinished work uncommitted until green.
- **Literature grounding** (`~/Projects/Literature/sources/rabinovich_2014/
  Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`): Def 3.1 (md:61-74, point-pinning discipline),
  Lemma 3.2(2) (md:76-79, anchor cap), Prop 3.5 (md:87-94, ∃x → bracket witness mechanism), Def 4.1
  (md p.5-6, E[Σ] monadic fold), Prop 4.2 (md:100-101, negation-closure per-round content),
  Lemma 5.1 (md:134-135, bracket negation), Lemma 5.3 (md:137-152, INF splitting / order-theoretic
  `IntervalPattern.holds` construction), Cor 5.4 (md:154-157, `F_i` chain construction / TL
  formulas). Report `01_blocker-research-successor-k.md` §2 (Q1-Q3) is the binding amended design
  spec for the successor-parameterized `σ.2` read this task's construction must remain compatible
  with.

## After Completion

Once the new task (spawned as its own task number by the skill postflight) completes, resume the
parent task #321 with `/revise 321` first (to fold in a v4 phase decomposition that re-points
Phase 8's soundness scaffolding, and Phases 9-15, at the newly-delivered sub-bracket construction
and its correctness pair), then `/implement 321`.

The blocker will be resolved because: task 321's Phase 8 was blocked specifically by the absence of
(a) a sub-bracket construction whose chain(s) reach all interior zones including `zXU`, and (b) a
correctness pair proving that construction sound and complete against `nf_eval_nf M 1 4`. The new
task delivers exactly those two things as a standalone, machine-verified unit; task 321's remaining
work becomes wiring (re-pointing `kvE2_body`'s joint-slot reference) and per-channel/assembly work
that the original v3 phase decomposition already correctly scoped for everything OTHER than the
per-sub crux.
