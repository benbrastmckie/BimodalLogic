# Implementation Plan: Reflexive Completeness (v14)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 35 hours
- **Dependencies**: None
- **Research Inputs**: reports/49_reflexive-completeness-strategy.md
- **Artifacts**: plans/49_reflexive-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 5 remaining sorry sites in `RootScopedChain.lean` to achieve sorry-free `bx_completeness` on the `until` branch under fully reflexive semantics (G: ≤, H: ≤, Until: s ≥ t, Since: s ≤ t). All other files on the critical completeness path are already sorry-free. The plan builds on plan v13's ordered defect-discharge architecture and the sorry-free infrastructure in `OrderedSeedConsistency.lean` and `CanonicalModel.lean`. This supersedes plan v13 with a streamlined approach informed by 60+ rounds of research from the parallel `irr_until` branch investigation.

### Research Integration

Report 49 (49_reflexive-completeness-strategy.md) consolidates findings from task 109 reports 09-12:
- All 5 sorries are in one file; everything else is sorry-free
- Mathematical arguments for all 5 are understood
- The schedule-based chain with `f_carry` enrichment (already sorry-free) provides F-preservation
- BX8 (ψ → φ U ψ) and BX1 (G(φ) → φ) are available axioms

## Goals & Non-Goals

**Goals**:
- Close all 5 sorry sites in `RootScopedChain.lean` (lines 1111, 1138, 1145, 1153, 1160)
- Achieve `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}` (no `sorryAx`)
- Maintain zero new sorry introductions

**Non-Goals**:
- Irreflexive completeness (handled by task 109 on `irr_until` branch)
- Dense completeness (task 68)
- Closing non-critical-path sorries (Quasimodel/, Boneyard/, ConservativeExtension/)
- Refactoring the chain construction architecture

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F-obligation persistence fails under reflexive semantics (BX1 allows φ→F(φ), creating new F-defects from resolved ones) | H | M | The `f_carry` enrichment in `fwd_succ` explicitly preserves all F-obligations in the seed. Even if new F-obligations arise via BX1, the schedule visits every formula infinitely often. |
| Step transfer for backward Until (sorry #4) not syntactically derivable from BX axioms | H | M | BX8 handles the base case. The inductive step uses `or_until_in_mcs` which takes `ψ ∨ (φ ∧ (φ U ψ)) → φ U ψ`. Under reflexive semantics, this is sorry-free. Fallback: mark [PARTIAL] with 4/5 closed. |
| `lake build` fails on stale `until` branch | M | L | Both branches use Lean v4.27.0-rc1 with Mathlib v4.27.0-rc1. Build verification is Phase 1. |
| Pigeonhole argument for F-resolution is more complex than expected | M | M | Use `schedule_surjective_above` + `f_carry` persistence as the primary argument, avoiding counting. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel. Phase 4 (forward Until) and Phase 5 (backward Until) are independent once Phase 3 completes.

---

### Phase 1: Build Verification and Sorry Audit [NOT STARTED]

**Goal**: Confirm the `until` branch compiles and catalog the exact sorry state.

**Tasks**:
- [ ] Run `lake build` on the `until` branch
- [ ] Confirm 5 sorry sites in `RootScopedChain.lean` at lines 1111, 1138, 1145, 1153, 1160
- [ ] Verify all other BXCanonical files are sorry-free
- [ ] Run `#print axioms bx_completeness` to establish baseline
- [ ] Verify BX8 (`refl_intro_until`) and BX1 (`temp_t_future`) are present in Axioms.lean
- [ ] Verify `OrderedSeedConsistency.lean` is sorry-free
- [ ] Read `fwd_succ` / `f_carry` infrastructure in `CanonicalModel.lean` to understand the chain construction

**Timing**: 2 hours

**Depends on**: none

---

### Phase 2: Close Sorry #1 — F-Resolution (`fwd_chain_forward_F`) [NOT STARTED]

**Goal**: Prove F(φ) ∈ chain(n) → ∃m > n, φ ∈ chain(m). This is the critical-path sorry that unblocks #2, #3, and #5.

**Tasks**:
- [ ] Verify F-obligation persistence: does `f_carry` enrichment in `fwd_succ` ensure F(φ) ∈ chain(n) → F(φ) ∈ chain(n+1) at non-resolving steps?
- [ ] If F-persistence holds: use `schedule_surjective_above` to find m ≥ n with schedule(m) = φ. Since F(φ) persists to chain(m), `fwd_succ_resolves` gives φ ∈ chain(m+1).
- [ ] If F-persistence does NOT hold (BX1 allows F-obligation re-creation, complicating monotonicity): use `Nat.find` on `∃k ≥ n, F(φ) ∈ chain(k) ∧ schedule(k) = φ`. By `schedule_surjective_above`, the schedule hits φ infinitely often. If F(φ) ever holds at a step where schedule = φ, resolution occurs. The argument needs: F(φ) is present at SOME step ≥ n where the schedule targets φ.
- [ ] Prove the lemma and close the sorry at line 1111
- [ ] Prove symmetric `bwd_chain_backward_P` for P-resolution
- [ ] `lake build`

**Timing**: 8 hours

**Depends on**: 1

**Files**: `RootScopedChain.lean` (line 1111), possibly `CanonicalModel.lean` for helper lemmas

---

### Phase 3: Close Sorries #2 and #3 — Restricted Temporal Coherence [NOT STARTED]

**Goal**: Close `dd_bfmcs_restricted_tc` — both the backward-chain F case (sorry #2) and the P-direction (sorry #3).

**Tasks**:
- [ ] Sorry #2 (line 1138): F(φ) in backward chain → propagate to origin via chain connectivity → use `fwd_chain_forward_F` from Phase 2
- [ ] Sorry #3 (line 1145): P(φ) resolution. When in forward chain: propagate P to origin, then use `bwd_chain_backward_P`. When in backward chain: direct resolution via backward schedule.
- [ ] Verify the Int-indexed chain dispatching in `dd_chain` handles both regions correctly
- [ ] `lake build`

**Timing**: 6 hours

**Depends on**: 2

**Files**: `RootScopedChain.lean` (lines 1138, 1145)

---

### Phase 4: Close Sorry #5 — Forward Until/Since Coherence [NOT STARTED]

**Goal**: Given (φ U ψ) ∈ chain(t), find witness s ≥ t with ψ ∈ chain(s) and guard φ on [t, s).

**Tasks**:
- [ ] By BX10 (`until_F`): (φ U ψ) → F(ψ) (sound under reflexive semantics)
- [ ] By Phase 2: F(ψ) ∈ chain(t) → ∃s > t, ψ ∈ chain(s)
- [ ] Guard persistence: BX5 (self-accumulation) + BX9 (until-elimination) give φ at intermediate steps where (φ U ψ) holds but ψ doesn't
- [ ] Prove (φ U ψ) persists at intermediate steps via g_content propagation: BX4 (connect_future) gives φ → G(P(φ)), which combined with backward witnesses, maintains the Until at intermediate points
- [ ] Close sorry at line 1160
- [ ] `lake build`

**Timing**: 6 hours

**Depends on**: 3

**Files**: `RootScopedChain.lean` (line 1160)

---

### Phase 5: Close Sorry #4 — Backward Until/Since Coherence [NOT STARTED]

**Goal**: Prove backward Until coherence — the hardest sorry. Given semantic witnesses (ψ at s, φ on guard), derive (φ U ψ) ∈ chain(t).

**Tasks**:
- [ ] Verify `backward_until_from_step` in `UntilSinceCoherence.lean` — this parameterized theorem reduces backward Until coherence to the step transfer hypothesis
- [ ] Prove step transfer: (φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)
  - Base case (ψ ∈ chain(r)): by BX8, ψ → φ U ψ gives (φ U ψ) ∈ chain(r) directly
  - Inductive case (ψ ∉ chain(r)): need to pull Until backward one step. The witness s for (φ U ψ) at r+1 satisfies s ≥ r+1 > r. Under reflexive Until, s ≥ r as well. Guard: φ on [r, s) = {r} ∪ [r+1, s). φ(r) given, [r+1, s) from the Until at r+1. So semantically (φ U ψ) at r.
  - Syntactically: use `or_until_in_mcs` which takes (ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ). Since ψ ∉ chain(r), the second disjunct must hold: φ ∈ chain(r) (given) ∧ (φ U ψ) from... but we need (φ U ψ) ∈ chain(r) to prove (φ U ψ) ∈ chain(r). This is circular.
  - Alternative: use the chain's g_content structure. G(φ U ψ) ∈ chain(r) would give (φ U ψ) ∈ chain(r+1) via g_content. But we start from (φ U ψ) ∈ chain(r+1), not G(φ U ψ). We need the reverse: from (φ U ψ) at r+1, derive it at r.
  - The key may be BX4 (connect_future): φ → G(P(φ)). Applied to (φ U ψ) at r+1: G(P(φ U ψ)) ∈ chain(r+1). So P(φ U ψ) ∈ g_content(chain(r+1)). But g_content goes forward (r+1 → r+2), not backward.
  - Explore: h_content approach. H(X) ∈ chain(r+1) → X ∈ chain(r) via h_content backward propagation. Need H(φ U ψ) ∈ chain(r+1). From BX4' (connect_past): (φ U ψ) → H(F(φ U ψ)). This gives H(F(φ U ψ)) but not H(φ U ψ).
  - If blocked: investigate whether `backward_until_from_step` can be given a different step hypothesis that IS provable from the chain structure
- [ ] Close sorry at line 1153
- [ ] If blocked: mark [PARTIAL], document precise obstruction, close 4/5 sorries as a milestone
- [ ] `lake build`

**Timing**: 8 hours

**Depends on**: 3

**Files**: `RootScopedChain.lean` (line 1153), `UntilSinceCoherence.lean` (step transfer)

---

### Phase 6: Completeness Audit and Verification [NOT STARTED]

**Goal**: Verify sorry-free completeness. Final audit.

**Tasks**:
- [ ] Run `#print axioms bx_completeness` — target: `{propext, Classical.choice, Quot.sound}`
- [ ] Run `#print axioms dd_countermodel` — verify no `sorryAx`
- [ ] Grep for remaining sorry in BXCanonical: `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/ --include="*.lean" | grep -v "^.*:.*--"`
- [ ] Run full `lake build`
- [ ] Update `RootScopedChain.lean` header documentation
- [ ] If sorry #4 was not closed: document the obstruction, update task status to [PARTIAL]

**Timing**: 2 hours

**Depends on**: 4, 5

**Files**: `Completeness.lean` (audit comments), `RootScopedChain.lean` (documentation)

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on each closed sorry confirms no `sorryAx` leaks
- [ ] `#print axioms bx_completeness` checked at Phase 6
- [ ] Grep for `sorry` in `RootScopedChain.lean` shows monotonic decrease
- [ ] `dd_bfmcs_restricted_tc` sorry-free after Phase 3
- [ ] `dd_bfmcs_restricted_fuc` sorry-free after Phase 4
- [ ] `dd_bfmcs_restricted_buc` sorry-free after Phase 5 (or documented as blocked)

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/49_reflexive-completeness.md` (this file)
- `specs/093_complete_bxcanonical_embedding/reports/49_reflexive-completeness-strategy.md` (research)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — 5 sorries closed
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — helper lemmas (if needed)
- Implementation summary upon completion

## Rollback/Contingency

- Each phase is independently committable
- Phase 2 fallback: if schedule surjectivity + f_carry doesn't work cleanly, try the pigeonhole argument on finite defect sets
- Phase 5 fallback: if step transfer is blocked, mark [PARTIAL] with 4/5 sorries closed — this is still a major milestone and unblocks most of the completeness path
- If `lake build` fails on stale dependencies: `lake clean && lake build`
