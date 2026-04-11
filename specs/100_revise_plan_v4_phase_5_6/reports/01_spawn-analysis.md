# Blocker Analysis: Task #98

**Parent Task**: #98 - research_filtration_quasimodel_pivot
**Generated**: 2026-04-10
**Blocker**: Plan v3 Phase 4 cannot prove `chain_step_seed_consistent` against the current `HintikkaPoint` abstraction because `locally_consistent` is a pairwise property that does not yield the derivation-level consistency required by Teammate A's §3.3 reduction. Round 4 research additionally identified that Phases 5-6 have independent blockers and that plan v3's Phase 6 axiom-fallback clause violates the zero-debt policy.

## Root Cause

Two intertwined causes, one structural and one planning-level:

### Cause 1 (structural): HintikkaStepOracle output type is too weak

`HintikkaStepOracle` (Construction.lean:452) is currently existential over an arbitrary `HintikkaPoint Sigma` with **no MCS backing**. The Phase 3 chain construction therefore produces Hintikka points whose only consistency guarantee is the pairwise `locally_consistent` field: `∀ f ∈ formulas, ¬f ∉ formulas`. Round 3 Teammate A's §3.3 reduction, however, needs the final step

```
¬(bigconj L_h) ∈ h_{i+1}.formulas ⟹ ⊥
```

which requires `h_{i+1}` to be derivation-consistent against arbitrary finite subsets of its own formula set — a strictly stronger property. Phase 4 summary (`07_phase4-summary.md:77-94`) documents the gap precisely: `bigconj L_h` is not even in general in `Sigma`, let alone in `h_{i+1}.formulas`, so the final "contradiction with local consistency" step has no proof path through the current abstraction.

Teammate B observed that `SetConsistent` is defined in Core as "every finite subset is consistent", so any subset of an MCS is trivially consistent. The one-line fix is therefore to make the chain carry a concrete `BXPoint` witness at construction time, so that each `h_i` is `sigma_signature w_i` for a witnessed MCS `w_i`, and `chain_step_seed_consistent` collapses to a subset witness into `w.is_mcs.1` — **exactly the pattern already used by `enriched_seed_consistent_until` (Realization.lean:226-276) in its `h_neg_in = false` branch**. `bx_forward_witness` (Frame.lean:164) already produces both the next `BXPoint` and its `bx_le` witness, so threading it through `hintikka_chain_exists` is structurally simple.

Teammate C (Critic) independently arrived at the same architectural verdict (C.6): "Fuse Phase 3 and Phase 5 so the chain is realized-as-it-is-built. Carry an MCS-backing witness inside `QuasimodelChain`."

### Cause 2 (planning-level): Plan v3 has latent Phase 5/6 blockers and a zero-debt violation

Round 4 Teammate C identified three independent problems in plan v3 that any Phase 4 resolution would not address:

- **C.4**: Phase 5's `realize_chain_step` requires a stricter unstated consistency obligation on the seed `h_{i+1}.formulas ∪ g_content(v_i) ∪ {¬f | f ∈ Sigma \ h_{i+1}}`, not addressed anywhere in plan v3.
- **C.5**: Phase 6's locus-control exhaustiveness is independently hard, and plan v3's "fall back to axiom" escape hatch violates the zero-debt policy.
- **C.7**: Plan v3's 52-98h estimate is optimistic by ~30%; realistic bound is 70-135h.

These three items are planning concerns, not coding concerns, and must be resolved in a plan revision before any Phase 5/6 implementation session begins. They do not interact with the technical fix for Phase 4 beyond sharing the parent task.

## Proposed New Tasks

### New Task 1: Implement BXPoint-backed HintikkaStepOracle for Phase 4 chain-step seed consistency
- **Effort**: 10-15 hours
- **Language**: lean4
- **Rationale**: Unblocks Phase 4's `chain_step_seed_consistent` lemma by changing the structural shape of `HintikkaStepOracle` so that every `h_i` in the chain carries a concrete `BXPoint` witness. With the witness available, `chain_step_seed_consistent` reduces to a one-line subset fact into `w.is_mcs.1`, mirroring `enriched_seed_consistent_until` (Realization.lean:226-276). Scope is narrow: modify `HintikkaStepOracle` (Construction.lean:452) to carry a `BXPoint` witness, thread `bx_forward_witness` (Frame.lean:164) through `hintikka_chain_exists`, prove `chain_step_seed_consistent` via the MCS subset route, and leave Phases 5-8 of plan v3 untouched. Zero-debt compliant. Estimate includes buffer for Teammate C's C.2 scope fix to `enriched_g_neg_bigconj_mem` if needed.
- **Depends on**: None

### New Task 2: Revise task 98 plan v3 to plan v4 addressing Phase 5/6 blockers and zero-debt violation
- **Effort**: 2-4 hours
- **Language**: logic
- **Rationale**: Before any Phase 5/6 implementation session can begin, plan v3 must be updated to reflect: (a) the new `HintikkaStepOracle` shape delivered by Task 1 (this changes the type signatures Phase 5 can rely on); (b) removal of Phase 6's axiom-fallback clause (zero-debt violation per Teammate C §C.5); (c) an explicit Phase 5 consistency-obligation plan addressing the stricter `realize_chain_step` seed obligation (Teammate C §C.4); (d) adjusted effort estimates to 70-135h for Phases 4-8 (Teammate C §C.7). This is a planning task, not a coding task.
- **Depends on**: New Task 1, because the plan v4 revision must describe the new post-Task-1 type signatures (`HintikkaStepOracle` carrying a `BXPoint` witness) and the Phase 5 consistency obligation must be stated relative to the actually-landed structure, not relative to the speculative shape. Without Task 1 landed, the revised plan would be writing against a moving target and would likely need immediate re-revision.

## Dependency Reasoning

- **Task 2 depends on Task 1**: Task 1 changes the structural shape of `HintikkaStepOracle` and the output type of `hintikka_chain_exists`. Plan v4's Phase 5 consistency obligation plan (addressing C.4) and its Phase 6 restructuring (addressing C.5) must be written against the actual post-Task-1 type signatures. If Task 2 runs before Task 1 lands, the revision would commit to abstractions that the implementation then contradicts, requiring a re-revision — the exact trap that led to plan v1 → v2 → v3. The dependency is about implementation details (what the new types look like after Task 1), not merely completion ordering.

- **No third task needed**: Teammate D's recommendation that tasks 93 and 94 be unblocked for parallel work is a state-management action on *existing* sibling tasks (adjusting their `parent_task`/dependency metadata), not a new spawnable task. The spawn command itself does not create those tasks. The orchestrator can lift their blocked status as a postflight side effect without requiring a dedicated task.

## After Completion

Once Task 1 (BXPoint-backed oracle) and Task 2 (plan v4 revision) are complete, resume the parent task #98 with `/implement 98`.

The blocker will be resolved because:

1. Task 1 eliminates the structural gap — `chain_step_seed_consistent` becomes provable via a one-line MCS subset witness, closing Phase 4.
2. Task 2 eliminates the latent Phase 5/6 risks that would otherwise surface mid-implementation — Phase 5's stricter consistency obligation is explicitly planned, Phase 6's axiom fallback is removed, and effort expectations match reality.

Tasks 93 (Box sorry + TaskModel embedding) and 94 (archive legacy sorries) can proceed in parallel with both of the new tasks since they are logically independent of the Until/Since chain-construction work (see Teammate D, 08_team-research.md lines 99-110).
