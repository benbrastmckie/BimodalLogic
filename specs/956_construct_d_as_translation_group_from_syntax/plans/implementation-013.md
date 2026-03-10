# Implementation Plan: D Construction from Canonical Timeline (v013)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None
- **Research Inputs**: research-033.md (Path A analysis), research-030 through research-032 (blocker analysis)
- **Artifacts**: plans/implementation-013.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-012.md (v012 hit G-completeness blocker in Phase 2B; research-033 provides Path A resolution)

## Critical Constraint

**IMPORTING Int OR Rat IS STRICTLY FORBIDDEN** (except via Cantor discovery).

Path D (Bulldozing with Q import) is **REJECTED** as circular - we are constructing an isomorphic copy of Q from syntax, not importing Q.

## v013 Strategy: Path A (Enriched Seed) as Primary

**v012 Blocker (Phase 2B)**:
The standard seed `{phi} union GContent(M)` for forward witnesses cannot guarantee `NOT CanonicalR W M` in the quotient. The G-completeness problem: we cannot control what Lindenbaum puts into W beyond the seed, so `GContent(W) subset M` may hold, collapsing W back to M in the quotient.

**v013 Resolution - Path A (Enriched Seed)**:
Use enriched seed `{phi, G(psi)} union GContent(M)` where `psi not in M`. This forces the witness W to contain `G(psi)`, hence `psi in GContent(W)`. Since `psi not in M`, we get `GContent(W) NOT subset M`, breaking backward CanonicalR.

**Key Mathematical Challenge**:
Prove the enriched seed is consistent: `{phi, G(psi)} union GContent(M)` where:
- `F(phi) in M` (standard forward witness prerequisite)
- `psi not in M` (the distinguishing formula)
- The seed must be consistent for Lindenbaum to extend it

**Candidate Formula Selection**:
Research-033 suggests: For `F(phi) in M` but `phi not in M` (intermediate formula from density), use `psi = phi`. Then:
- `{phi, G(phi)} union GContent(M)` is the enriched seed
- Need: consistency of `{phi, G(phi)} union GContent(M)` when `F(phi) in M`

## Pipeline Overview

```
[COMPLETED]    Phase 0-1: Prior setup (from v012)
[COMPLETED]    Phase 2A: NoMaxOrder infrastructure at MCS level
[NOT STARTED]  Phase 2B: Enriched Seed Construction (PATH A - PRIMARY)
[NOT STARTED]  Phase 2C: NoMaxOrder/NoMinOrder from Enriched Seed
[NOT STARTED]  Phase 3: DenselyOrdered from DN Axiom
[NOT STARTED]  Phase 4: Cantor Isomorphism
[NOT STARTED]  Phase 5: D and task_rel from Cantor
[NOT STARTED]  Phase 6: TaskFrame + Completeness
```

## Goals & Non-Goals

**Goals**:
- Resolve NoMaxOrder/NoMinOrder sorries using Path A (enriched seed)
- Prove DenselyOrdered on the ConstructiveQuotient
- Complete D construction from pure syntax via Cantor
- Zero sorries in the completeness chain

**Non-Goals**:
- Using D=Q directly (FORBIDDEN - must be discovered via Cantor)
- Using `task_rel = True` (defeats purpose)
- Path D bulldozing (REJECTED as circular)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Enriched seed inconsistency | HIGH | MEDIUM | Fallback to Path B (Aut+(T)), then Path C (Pruned Fragment) |
| Path A does not break backward CanonicalR | HIGH | LOW | Research-033 analysis suggests it will work |
| All paths blocked | HIGH | LOW | Mark [BLOCKED] with requires_user_review: true |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `ConstructiveFragment.lean` lines 573-585: NoMaxOrder and NoMinOrder instances

### Expected Resolution
- Phase 2C resolves both sorries via enriched seed construction that breaks backward CanonicalR

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in `ConstructiveFragment.lean`
- Cantor isomorphism + completeness theorem ready

## Implementation Phases

### Phase 2B: Enriched Seed Construction (PATH A) [NOT STARTED]

- **Dependencies**: None
- **Goal**: Construct enriched forward/backward seeds that break reverse CanonicalR

**Core Insight** (research-033):
The standard seed cannot control GContent(W). The enriched seed explicitly adds `G(psi)` where `psi not in M`, forcing GContent(W) to contain `psi`, which breaks `CanonicalR W M`.

**Tasks**:
- [ ] Define `EnrichedForwardTemporalWitnessSeed M phi psi := {phi, G(psi)} union GContent(M)`
- [ ] Prove consistency: `enriched_forward_seed_consistent` when:
  - `F(phi) in M`
  - `psi not in M`
  - Need to show `{phi, G(psi)} union GContent(M)` does not prove bot
- [ ] Define `executeEnrichedForwardStep` using the enriched seed
- [ ] Prove `executeEnrichedForwardStep_breaks_backward`:
  ```lean
  theorem executeEnrichedForwardStep_breaks_backward
      (h_psi_not_M : psi not in M) :
      NOT CanonicalR (executeEnrichedForwardStep M h_mcs phi psi h_F h_psi_not_M) M
  ```
- [ ] Similarly for backward direction: `EnrichedPastTemporalWitnessSeed`, `executeEnrichedBackwardStep`

**Consistency Proof Strategy**:
- Assume `{phi, G(psi)} union GContent(M) |- bot`
- Extract finite subset L that derives bot
- L subset {phi, G(psi)} union GContent(M)
- Use `forward_temporal_witness_seed_consistent` style argument:
  - From `L |- bot`, derive `G(conj(L \ {phi, G(psi)})) |- G(neg phi) or G(neg G(psi))`
  - Since `G(psi) -> G(G(psi))` (temp_4), this gives `G(neg phi) or neg(G(psi))` in M
  - But `F(phi) in M` and `G(psi)` status depends on `psi not in M`
  - Key: `psi not in M` does NOT mean `G(psi) not in M` (G-completeness issue again)
  - **Alternative**: Choose `psi` such that `G(psi) not in M` is provable

**Revised Candidate Selection**:
- Pick `psi` with `neg(psi) in M` (so `psi not in M`)
- Then `G(psi)` may or may not be in M
- But: if `G(psi) in M`, then `psi in GContent(M) subset W` anyway, so adding it to seed is redundant
- If `G(psi) not in M`, then `neg(G(psi)) = F(neg(psi)) in M`
- Use psi such that `F(neg(psi)) in M` (exists by seriality + density)
- Then `G(psi) not in M`, so adding `G(psi)` to seed is non-trivial

**Concrete Choice**:
Let `chi` be ANY non-theorem with `neg(chi) in M`. Then:
- `G(chi) in M` or `G(chi) not in M`
- If `G(chi) not in M`, then `F(neg(chi)) in M` (from MCS completeness)
- Use `phi = neg bot` (from seriality `F(neg bot) in M`), `psi = chi`
- Enriched seed: `{neg bot, G(chi)} union GContent(M)` where `chi not in M` and `G(chi) not in M`

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` (add enriched seed definitions)
- `Theories/Bimodal/Metalogic/Canonical/WitnessSeed.lean` (if needed for seed lemmas)

**Verification**:
- `enriched_forward_seed_consistent` proven sorry-free
- `executeEnrichedForwardStep_breaks_backward` proven sorry-free
- `lake build` passes

**Escape Valve**: If Path A fails after 3 hours:
1. Document why enriched seed fails (which step in consistency proof)
2. Attempt Path B (Aut+(T)) - 1 hour
3. Attempt Path C (Pruned Fragment) - 1 hour
4. If all fail: mark [BLOCKED] with requires_user_review: true

---

### Phase 2C: NoMaxOrder/NoMinOrder from Enriched Seed [NOT STARTED]

- **Dependencies**: Phase 2B
- **Goal**: Resolve the two sorries using enriched seed witnesses

**Tasks**:
- [ ] Modify `ConstructiveReachable` to use enriched seeds (or add variant constructors)
- [ ] Prove `NoMaxOrder` instance:
  ```lean
  instance : NoMaxOrder (ConstructiveQuotient M_0 h_mcs_0) where
    exists_gt a := by
      induction a using Quotient.ind with | _ w =>
      -- Choose psi not in w.val with G(psi) not in w.val
      -- Use enriched forward step with this psi
      -- By executeEnrichedForwardStep_breaks_backward, the witness is strictly greater
  ```
- [ ] Prove `NoMinOrder` instance (symmetric argument with enriched backward step)
- [ ] Verify both sorries eliminated

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`

**Verification**:
- Lines 573-585 sorries eliminated
- `grep -n "\bsorry\b" ConstructiveFragment.lean` returns empty
- `lake build` passes

---

### Phase 3: DenselyOrdered from DN Axiom [NOT STARTED]

- **Dependencies**: Phase 2C
- **Goal**: Prove DenselyOrdered on the ConstructiveQuotient

**Strategy** (from research-030):
Given `[a] < [b]` in the quotient:
1. Extract distinguishing formula `chi in GContent(b) \ GContent(a)` (or `chi in b.val \ a.val`)
2. From `NOT CanonicalR b a`: exists `psi` with `G(psi) in b` and `psi not in a`
3. Use density axiom: `F(chi) in a` for some formula `chi` related to `psi`
4. Apply `density_of_canonicalR`: intermediate MCS W exists with `CanonicalR a W` and `F(chi) in W`
5. Use enriched seed technique to ensure `[a] < [W] < [b]`

**Tasks**:
- [ ] Formalize the extraction of distinguishing formula from `[a] < [b]`
- [ ] Apply density of CanonicalR to get intermediate MCS
- [ ] Prove intermediate is in ConstructiveFragment
- [ ] Prove strict inequalities `[a] < [W]` and `[W] < [b]`
- [ ] Define `DenselyOrdered` instance

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`

**Verification**:
- `DenselyOrdered (ConstructiveQuotient M_0 h_mcs_0)` proven sorry-free
- `lake build` passes

**Escape Valve**: If blocked:
1. Document the specific obstacle
2. Mark [BLOCKED] with requires_user_review: true
3. Do NOT proceed with sorry placeholder

---

### Phase 4: Cantor Isomorphism [NOT STARTED]

- **Dependencies**: Phase 2C (NoMax/NoMin), Phase 3 (DenselyOrdered)
- **Goal**: Apply Cantor's theorem to get T isomorphic to Q

**Tasks**:
- [ ] Apply `Order.iso_of_countable_dense`:
  ```lean
  noncomputable def canonicalTimeline_iso_rat :
      ConstructiveQuotient M_0 h_mcs_0 ≃o Q :=
    (Order.iso_of_countable_dense (ConstructiveQuotient M_0 h_mcs_0) Q).some
  ```
- [ ] Verify all prerequisites: Countable, DenselyOrdered, NoMinOrder, NoMaxOrder, Nonempty
- [ ] Document that Q is DISCOVERED via Cantor, not imported

**Timing**: 0.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Canonical/CantorIsomorphism.lean`

**Verification**:
- `canonicalTimeline_iso_rat` defined
- `lake build` passes

---

### Phase 5: D and task_rel from Cantor [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Define D as (Q, +) discovered via Cantor; define task_rel as displacement

**Tasks**:
- [ ] Define `D := Q` with documentation explaining discovery via Cantor
- [ ] Define `canonical_task_rel`:
  ```lean
  def canonical_task_rel (e : ConstructiveQuotient M_0 h_mcs_0 ≃o Q)
      (w : ConstructiveQuotient M_0 h_mcs_0) (d : Q) (u : ConstructiveQuotient M_0 h_mcs_0) : Prop :=
    e u - e w = d
  ```
- [ ] Prove nullity: `canonical_task_rel e w 0 w`
- [ ] Prove compositionality: `canonical_task_rel e w d1 u -> canonical_task_rel e u d2 v -> canonical_task_rel e w (d1 + d2) v`
- [ ] Prove order-respecting: `d > 0 -> e.symm (e w + d) > w`

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Canonical/DFromSyntax.lean`

**Verification**:
- task_rel is non-trivial
- All properties proven sorry-free
- `lake build` passes

---

### Phase 6: TaskFrame and Completeness [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Build TaskFrame and prove completeness

**Tasks**:
- [ ] Define `SyntacticTaskFrame` using D and task_rel
- [ ] Define canonical valuation
- [ ] Build canonical histories from ConstructiveFragment
- [ ] Adapt truth lemma for ConstructiveFragment
- [ ] Prove `syntactic_weak_completeness : valid phi -> |- phi`
- [ ] Verify zero sorries in completeness chain
- [ ] Create implementation summary

**Timing**: 4 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Canonical/SyntacticTaskFrame.lean`
- `Theories/Bimodal/Metalogic/Canonical/SyntacticCompleteness.lean`

**Verification**:
- Completeness theorem proven sorry-free
- `lake build` passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/ --include="*.lean"` returns empty

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/ --include="*.lean"` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/*.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] D emerges from Cantor isomorphism applied to constructive fragment
- [ ] task_rel is displacement via Cantor, not trivial
- [ ] No Int/Rat imports outside Cantor discovery
- [ ] Completeness theorem sorry-free with pure syntax foundations

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` - enriched seed + NoMax/NoMin + Density
- `Theories/Bimodal/Metalogic/Canonical/CantorIsomorphism.lean` - T isomorphic to Q
- `Theories/Bimodal/Metalogic/Canonical/DFromSyntax.lean` - D and task_rel
- `Theories/Bimodal/Metalogic/Canonical/SyntacticTaskFrame.lean` - TaskFrame from D
- `Theories/Bimodal/Metalogic/Canonical/SyntacticCompleteness.lean` - completeness
- Implementation summary

## Estimated Total

| Phase | Hours | Status |
|-------|-------|--------|
| Phase 0-1 (Prior setup) | 0 | COMPLETED |
| Phase 2A (MCS-level NoMax/NoMin) | 0 | COMPLETED |
| Phase 2B (Enriched Seed - Path A) | 3 | NOT STARTED |
| Phase 2C (NoMaxOrder/NoMinOrder) | 2 | NOT STARTED |
| Phase 3 (DenselyOrdered) | 3 | NOT STARTED |
| Phase 4 (Cantor) | 0.5 | NOT STARTED |
| Phase 5 (D + task_rel) | 1.5 | NOT STARTED |
| Phase 6 (TaskFrame + Completeness) | 4 | NOT STARTED |
| **Total** | **14** | |

## Rollback/Contingency

**If Phase 2B (Path A Enriched Seed) fails**:
1. Document which step fails and why
2. Attempt Path B (Aut+(T) as automorphism group) - 1 hour
   - Research-033 notes: Aut+(T) is uncountable, but explore countable subgroups
3. Attempt Path C (Pruned Fragment) - 1 hour
   - Restrict to MCSs provably NOT G-complete
4. If all paths blocked: mark [BLOCKED] with:
   - `requires_user_review: true`
   - `review_reason: "All pure-syntax approaches (A/B/C) blocked. User must decide: accept Path D bulldozing or abandon pure-syntax constraint."`

**If Cantor application fails**:
1. Verify Mathlib version has `Order.iso_of_countable_dense`
2. Check all prerequisites (Countable, DenselyOrdered, NoMin, NoMax, Nonempty)

## Appendix: What Changed from v012

**v012**: Hit G-completeness blocker in Phase 2B. Standard seed cannot guarantee strict separation in quotient.

**v013 Corrections**:
1. **Path A as Primary**: Use enriched seed `{phi, G(psi)} union GContent(M)` to force non-trivial GContent in witness
2. **Explicit Fallback Chain**: Path A -> Path B -> Path C -> [BLOCKED]
3. **Path D Rejection**: Per user direction, bulldozing with Q import is REJECTED as circular
4. **Phase Split**: Phase 2B = Enriched Seed infrastructure, Phase 2C = Apply to resolve sorries
5. **Concrete Formula Selection**: Use `psi` where `G(psi) not in M` (from `F(neg(psi)) in M`)

## Appendix: Path Definitions Summary

| Path | Approach | Status per User Direction |
|------|----------|---------------------------|
| **Path A (Enriched Seed)** | Force `G(psi)` into seed where `psi not in M` | PRIMARY |
| **Path B (Aut+(T))** | Define D as automorphism group of T | FALLBACK |
| **Path C (Pruned Fragment)** | Restrict to non-G-complete MCSs | LAST RESORT |
| **Path D (Bulldozing)** | `D = ConstructiveQuotient x Q` | REJECTED (circular) |
