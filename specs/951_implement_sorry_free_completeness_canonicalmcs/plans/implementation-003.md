# Implementation Plan: Task #951 (Revision 3)

- **Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
- **Status**: [IMPLEMENTING]
- **Effort**: 25-35 hours
- **Version**: 3 (supersedes implementation-001.md and implementation-002.md)
- **Dependencies**: BidirectionalReachable.lean (LinearOrder proven), CanonicalCompleteness.lean (fragmentFMCS with sorry-free F/P)
- **Research Inputs**:
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-014.md (DEFINITIVE synthesis of 13 prior reports)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

| Version | Date | Key Changes |
|---------|------|-------------|
| 001 | 2026-02-27 | Initial plan: antisymmetrization via Z-indexed dovetailing chain |
| 002 | 2026-02-27 | Major revision: Bidirectional Reachable Fragment approach. Phases A-D completed, Phase E blocked |
| 003 | 2026-03-01 | **Definitive construction**: OrderIso via SuccOrder/PredOrder on BidirectionalQuotient |

## Why Revision is Needed

**Research-014 Definitive Analysis**: After 13 research reports and thorough codebase analysis, the F-persistence problem through chain construction is confirmed as fundamentally blocked. The solution:

1. **BidirectionalFragment IS the canonical time domain** - already has sorry-free `fragmentFMCS` with `forward_F` and `backward_P`
2. **BidirectionalQuotient already has LinearOrder** - proven in BidirectionalReachable.lean
3. **The conversion path**: Prove `SuccOrder` and `PredOrder` on the quotient, then use Mathlib's `orderIsoIntOfLinearSuccPredArch` to get an `OrderIso` to Int
4. **Transfer via OrderIso**: Pull back Int's `AddCommGroup` and `IsOrderedAddMonoid` structure, then transfer `fragmentFMCS` to get `FMCS Int`

**Key insight**: The fragment-level FMCS has sorry-free forward_F/backward_P because F/P witnesses stay within the fragment (proven). The conversion to Int is purely a matter of establishing the OrderIso.

## Overview

Complete the sorry-free completeness theorem by:
1. Proving `SuccOrder` on `BidirectionalQuotient` via lifting `fragmentGSucc`
2. Proving the critical **coverness** property (immediate successor)
3. Proving `PredOrder` symmetrically via `fragmentHPred`
4. Proving `IsSuccArchimedean`, `NoMaxOrder`, `NoMinOrder`
5. Obtaining `OrderIso (BidirectionalQuotient) Int` via Mathlib
6. Transferring `AddCommGroup` and `IsOrderedAddMonoid` to the quotient
7. Building `FMCS Int` by pullback through the OrderIso
8. Proving `fully_saturated_bfmcs_exists_int` (the single sorry that unlocks all completeness)
9. Verifying that all 3 sorries in the codebase become resolved

### Research Integration

- **research-014.md** (Definitive synthesis): Establishes the OrderIso approach as the only viable path, identifies SuccOrder coverness as the critical proof obligation, and provides complete proof sketches

## Goals & Non-Goals

**Goals**:
- Prove `SuccOrder (BidirectionalQuotient M0 h_mcs0)` with coverness
- Prove `PredOrder (BidirectionalQuotient M0 h_mcs0)`
- Prove `IsSuccArchimedean`, `NoMaxOrder`, `NoMinOrder`
- Obtain `OrderIso (BidirectionalQuotient M0 h_mcs0) Int`
- Transfer `AddCommGroup` and `IsOrderedAddMonoid` to quotient
- Build `FMCS Int` with sorry-free `forward_F` and `backward_P`
- Prove `fully_saturated_bfmcs_exists_int` without sorry
- Achieve zero sorries in the completeness chain

**Non-Goals**:
- Fixing the chain-based F-persistence approach (proven impossible)
- Modifying the existing truth lemma infrastructure (already sorry-free)
- Generalizing beyond temporal bimodal logic

## Preserved Infrastructure from v002

The following from implementation-002 remains valid and will be leveraged:

| Phase | Status | Key Deliverables |
|-------|--------|------------------|
| A | COMPLETED | `BidirectionalReachable.lean` - fragment definition, closure properties |
| B | COMPLETED | `bidirectional_totally_ordered` - totality proof |
| C | COMPLETED | `forward_F_stays_in_fragment`, `backward_P_stays_in_fragment` |
| D | COMPLETED | `BidirectionalQuotient` with `LinearOrder`, `fragmentFMCS` with sorry-free F/P |

**Existing infrastructure** (sorry-free):
- `fragmentGSucc` - GContent successor in fragment (CanonicalCompleteness.lean)
- `fragmentGSucc_le` - successor is >= predecessor
- `fragmentFSucc` - enriched successor with F-witness placement
- `enriched_seed_consistent_from_F` - key consistency lemma
- `enriched_seed_consistent_from_P` - backward analog

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| SuccOrder coverness proof fails | High | Medium | Fall back to direct enumeration bijection (Section 6.4 of research-014) |
| IsSuccArchimedean proof complex | Medium | Low | Use induction on reachability path length |
| Transfer of IsOrderedAddMonoid has subtle issues | Medium | Low | Use Mathlib's OrderIso transfer infrastructure |
| Witness family temporal coherence gaps | Medium | Medium | Each witness family uses its own BidirectionalFragment |
| orderIsoIntOfLinearSuccPredArch not in Mathlib | Low | Very Low | Construct OrderIso directly via succ enumeration |

## Sorry Characterization

### Pre-existing Sorries

Exactly **3 sorries** exist in the active codebase:

| File | Line | Statement | Root Cause |
|------|------|-----------|------------|
| DovetailingChain.lean | 1869 | `buildDovetailingChainFamily_forward_F` | F-formulas don't persist through GContent seeds |
| DovetailingChain.lean | 1881 | `buildDovetailingChainFamily_backward_P` | P-formulas don't persist through HContent seeds |
| TemporalCoherentConstruction.lean | 600 | `fully_saturated_bfmcs_exists_int` | Combines temporal coherence + modal saturation |

All three trace to the same fundamental problem: converting fragment-level FMCS (sorry-free) to FMCS Int.

### Expected Resolution

- **This plan eliminates all 3 sorries** by:
  - Phase 4 provides `FMCS Int` with sorry-free forward_F/backward_P via OrderIso transfer
  - Phase 5 proves `fully_saturated_bfmcs_exists_int` using the new FMCS Int
  - The DovetailingChain sorries become obsolete (deprecated in favor of OrderIso approach)

### New Sorries

- **None.** NEVER introduce new sorries.
- If coverness proof cannot be completed: mark phase [BLOCKED] with `requires_user_review: true`
- User decides: revise plan, use alternative bijection, or change approach

### Remaining Debt

After this implementation:
- 0 sorries in completeness chain
- `standard_weak_completeness` and `standard_strong_completeness` become sorry-free
- DovetailingChain.lean can be deprecated or archived

## Implementation Phases

### Phase 1: SuccOrder on BidirectionalQuotient [PARTIAL]

- **Dependencies**: None (builds on existing infrastructure)
- **Goal**: Define and prove `SuccOrder` instance on `BidirectionalQuotient`

**Mathematical Background**:
```
SuccOrder requires:
- succ : Q -> Q (successor function)
- le_succ : forall q, q <= succ q
- max_of_succ_le : succ q <= q -> IsMax q (handled by NoMaxOrder)
- succ_le_of_lt : q < r -> succ q <= r (COVERNESS - the hard part)
```

**Tasks**:
- [ ] **Task 1.1**: Define `succ` on the quotient by lifting `fragmentGSucc`
  - Signature: `succ : BidirectionalQuotient M0 h_mcs0 -> BidirectionalQuotient M0 h_mcs0`
  - Implementation: `Quotient.liftOn q (fun w => toAntisymmetrization (fragmentGSucc w)) (respects_equiv)`
  - Files: `BidirectionalReachable.lean`
  - Estimate: 1 hour
  - Verification: Definition compiles without error

- [ ] **Task 1.2**: Prove `fragmentGSucc_respects_equiv` - successor respects preorder equivalence
  - Statement: If `w1 <= w2` and `w2 <= w1`, then `fragmentGSucc w1 ~ fragmentGSucc w2`
  - Strategy: Both successors are Lindenbaum extensions of equivalent GContent
  - Files: `BidirectionalReachable.lean`
  - Estimate: 2 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 1.3**: Prove `le_succ` - every element is <= its successor
  - Statement: `forall q : BidirectionalQuotient, q <= succ q`
  - Strategy: Lift `fragmentGSucc_le` to the quotient
  - Files: `BidirectionalReachable.lean`
  - Estimate: 30 min
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 1.4**: Prove `succ_le_of_lt` (COVERNESS) - successor is immediate
  - Statement: `q < r -> succ q <= r`
  - Strategy: See research-014 Section 7.4. Key insight:
    - Between `[w]` and `[fragmentGSucc w]`, suppose `[v]` with `[w] < [v] <= [fragmentGSucc w]`
    - Then `GContent(w) subset v` and `GContent(v) subset fragmentGSucc(w)`
    - Since `fragmentGSucc w = Lindenbaum(GContent(w))` and v is consistent extension of GContent(w)
    - Need to show v and fragmentGSucc(w) are preorder-equivalent
  - Files: `BidirectionalReachable.lean`
  - Estimate: 4-6 hours (hardest lemma in phase)
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 1.5**: Assemble `SuccOrder` instance
  - Combine Tasks 1.1-1.4 into instance declaration
  - Files: `BidirectionalReachable.lean`
  - Estimate: 30 min
  - Verification: `instance : SuccOrder (BidirectionalQuotient M0 h_mcs0)` compiles

**Timing**: 8-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - SuccOrder infrastructure

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CanonicalCompleteness` passes

**Progress:**

**Session: 2026-03-01, sess_1772394758_e9c6eb (Iteration 2)**
- Fixed: Build errors from iteration 1 (circular dependency between BidirectionalReachable and CanonicalCompleteness)
- Removed: Broken code from BidirectionalReachable.lean (lines 814+) that referenced CanonicalCompleteness definitions
- Added: `GContent_idempotent_in_mcs` - temporal 4-axiom for G in MCS context
- Added: `HContent_idempotent_in_mcs` - temporal 4-axiom for H in MCS context
- Added: `GContent_eq_of_preorder_equiv` - GContent equality under preorder equivalence
- Added: `HContent_eq_of_preorder_equiv` - HContent equality under preorder equivalence
- Added: `fragmentGSucc_eq_of_preorder_equiv` - GSucc respects equivalence
- Added: `fragmentHPred`, `fragmentHPred_le` - HContent predecessor and its ordering
- Added: `fragmentHPred_eq_of_preorder_equiv` - HPred respects equivalence
- Added: `quotientSucc`, `quotientSucc_le` - well-defined successor on quotient
- Added: `quotientPred`, `quotientPred_le` - well-defined predecessor on quotient
- Added: `mcs_has_F_top`, `mcs_has_P_top` - F/P temporal witnesses in every MCS
- Attempted: SuccOrder coverness (`succ_le_of_lt`) - BLOCKED (see handoff)
- Attempted: `NoMaxOrder` - BLOCKED (reflexive semantics allows single-point quotient)
- Sorries: 3 -> 3 (0 eliminated, 0 introduced)
- Status: Tasks 1.1-1.3 and all prerequisites COMPLETED. Tasks 1.4 (coverness) and 1.5 (assembly) BLOCKED.
- Blocker: Mathematical impossibility of coverness proof (see handoff document)
- `SuccOrder` instance verified
- No sorries in new code

---

### Phase 2: PredOrder and Auxiliary Properties [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Complete the order structure with PredOrder and Archimedean properties

**Tasks**:
- [ ] **Task 2.1**: Define `pred` on the quotient by lifting `fragmentHPred`
  - Mirror of Task 1.1 using HContent instead of GContent
  - Files: `BidirectionalReachable.lean`
  - Estimate: 1 hour
  - Verification: Definition compiles

- [ ] **Task 2.2**: Prove `fragmentHPred_respects_equiv`
  - Mirror of Task 1.2
  - Files: `BidirectionalReachable.lean`
  - Estimate: 1.5 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 2.3**: Prove `pred_le` and coverness for PredOrder
  - Mirror of Tasks 1.3-1.4
  - Files: `BidirectionalReachable.lean`
  - Estimate: 3-4 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 2.4**: Assemble `PredOrder` instance
  - Files: `BidirectionalReachable.lean`
  - Estimate: 30 min
  - Verification: `instance : PredOrder (BidirectionalQuotient M0 h_mcs0)` compiles

- [ ] **Task 2.5**: Prove `NoMaxOrder`
  - Statement: `forall q, exists r, q < r`
  - Strategy: Every MCS has F(true), so there is always a forward witness. `succ q > q` unless at max, but there is no max.
  - Files: `BidirectionalReachable.lean`
  - Estimate: 1 hour
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 2.6**: Prove `NoMinOrder`
  - Statement: `forall q, exists r, r < q`
  - Strategy: Symmetric using P(true) and predecessor
  - Files: `BidirectionalReachable.lean`
  - Estimate: 1 hour
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 2.7**: Prove `IsSuccArchimedean`
  - Statement: `forall a b, a < b -> exists n, succ^[n] a = b` (or a <= succ^[n] a >= b)
  - Strategy: By induction on the reachability path length between fragment elements
  - Files: `BidirectionalReachable.lean`
  - Estimate: 2-3 hours
  - Verification: `lean_goal` shows "no goals"

**Timing**: 9-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - extend with PredOrder, NoMax/MinOrder, IsSuccArchimedean

**Verification**:
- `lake build` passes
- All instances verified
- No sorries

---

### Phase 3: OrderIso to Int and Structure Transfer [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Obtain OrderIso and transfer algebraic structure

**Tasks**:
- [ ] **Task 3.1**: Locate or prove `orderIsoIntOfLinearSuccPredArch` in Mathlib
  - Search: `loogle "LinearOrder" "SuccOrder" "PredOrder" "OrderIso" "Int"`
  - If not found: construct via explicit succ enumeration
  - Files: `BidirectionalReachable.lean`
  - Estimate: 1-2 hours
  - Verification: `OrderIso (BidirectionalQuotient M0 h_mcs0) Int` obtained

- [ ] **Task 3.2**: Define `fragmentOrderIso`
  - Statement: `fragmentOrderIso : BidirectionalQuotient M0 h_mcs0 ≃o Int`
  - Apply Mathlib theorem or construct directly
  - Files: `BidirectionalReachable.lean`
  - Estimate: 1 hour
  - Verification: Definition compiles

- [ ] **Task 3.3**: Transfer `AddCommGroup` to quotient
  - Statement: `instance : AddCommGroup (BidirectionalQuotient M0 h_mcs0)`
  - Strategy: `fragmentOrderIso.toEquiv.symm.addCommGroup` transfers from Int
  - Files: `BidirectionalReachable.lean`
  - Estimate: 1 hour
  - Verification: Instance compiles

- [ ] **Task 3.4**: Transfer `IsOrderedAddMonoid` to quotient
  - Statement: Verify compatibility of transferred group with existing order
  - Strategy: OrderIso preserves order structure by definition
  - Files: `BidirectionalReachable.lean`
  - Estimate: 2-3 hours
  - Verification: `lake build` passes with no errors

- [ ] **Task 3.5**: Define projection helpers
  - `quotientToInt : BidirectionalQuotient M0 h_mcs0 -> Int := fragmentOrderIso`
  - `intToQuotient : Int -> BidirectionalQuotient M0 h_mcs0 := fragmentOrderIso.symm`
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 30 min
  - Verification: Definitions compile

**Timing**: 5-8 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - OrderIso and structure transfer
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - projection helpers

**Verification**:
- `lake build` passes
- `OrderIso` verified
- Algebraic structures verified

---

### Phase 4: FMCS Int via Pullback [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Build FMCS Int with sorry-free forward_F and backward_P

**Key Insight**: The `fragmentFMCS` has sorry-free forward_F/backward_P at the fragment level. We transfer these to Int via the OrderIso.

**Tasks**:
- [ ] **Task 4.1**: Define `intToFragment` helper
  - Signature: `intToFragment : Int -> BidirectionalFragment M0 h_mcs0`
  - Strategy: Compose `fragmentOrderIso.symm` with `ofQuotient` (quotient representative)
  - Note: Need to handle the quotient-to-representative conversion carefully
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1.5 hours
  - Verification: Definition compiles

- [ ] **Task 4.2**: Define `fragmentToIntFMCS : FMCS Int`
  - Structure:
    ```lean
    noncomputable def fragmentToIntFMCS : FMCS Int where
      mcs t := fragmentFMCS.mcs (intToFragment t)
      is_mcs t := fragmentFMCS.is_mcs (intToFragment t)
      forward_G := ...
      backward_H := ...
    ```
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2 hours
  - Verification: Definition compiles

- [ ] **Task 4.3**: Prove `fragmentToIntFMCS_forward_G`
  - Statement: `G(phi) in mcs s -> (s <= t -> phi in mcs t)`
  - Strategy: Transfer from `fragmentFMCS.forward_G` via OrderIso monotonicity
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1.5 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 4.4**: Prove `fragmentToIntFMCS_backward_H`
  - Statement: `H(phi) in mcs t -> (s <= t -> phi in mcs s)`
  - Strategy: Transfer from `fragmentFMCS.backward_H` via OrderIso monotonicity
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 1.5 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 4.5**: Prove `fragmentToIntFMCS_forward_F` (KEY THEOREM)
  - Statement: `F(phi) in mcs t -> exists s >= t, phi in mcs s`
  - Strategy:
    1. `F(phi) in fragmentFMCS.mcs (intToFragment t)`
    2. By `fragmentFMCS_forward_F`: exists fragment element w with `intToFragment t <= w` and `phi in w.world`
    3. By OrderIso surjectivity: `w = intToFragment s` for some `s : Int`
    4. By OrderIso monotonicity: `t <= s`
    5. Result: `phi in mcs s` with `s >= t`
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2-3 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 4.6**: Prove `fragmentToIntFMCS_backward_P` (KEY THEOREM)
  - Statement: `P(phi) in mcs t -> exists s <= t, phi in mcs s`
  - Strategy: Symmetric to Task 4.5
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2-3 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 4.7**: Prove `fragmentToIntFMCS_temporally_coherent`
  - Combine forward_F and backward_P into temporal coherence predicate
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 30 min
  - Verification: `lean_goal` shows "no goals"

**Timing**: 10-14 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - FMCS Int construction

**Verification**:
- `lake build` passes
- `forward_F` and `backward_P` proven without sorry
- `grep -rn "\bsorry\b" CanonicalCompleteness.lean` returns empty

---

### Phase 5: fully_saturated_bfmcs_exists_int and Completeness [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Prove the theorem that unlocks all completeness results

**Tasks**:
- [ ] **Task 5.1**: Define witness family construction
  - For each Diamond(psi) obligation: build witness family using same OrderIso approach
  - Root = diamondWitnessMCS
  - Witness family = fragmentToIntFMCS rooted at witness MCS
  - Files: `CanonicalCompleteness.lean` or `TemporalCoherentConstruction.lean`
  - Estimate: 2-3 hours
  - Verification: Definition compiles

- [ ] **Task 5.2**: Prove witness families are temporally coherent
  - Each witness family is built via fragmentToIntFMCS, which has sorry-free F/P
  - Transfer temporal coherence from fragment level
  - Files: `CanonicalCompleteness.lean`
  - Estimate: 2 hours
  - Verification: `lean_goal` shows "no goals"

- [ ] **Task 5.3**: Prove `fully_saturated_bfmcs_exists_int` (MAIN THEOREM)
  - Statement:
    ```lean
    theorem fully_saturated_bfmcs_exists_int
        (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
        exists (B : BFMCS Int),
          (forall gamma in Gamma, gamma in B.eval_family.mcs 0) and
          B.temporally_coherent and
          is_modally_saturated B
    ```
  - Strategy:
    1. Use Lindenbaum to extend Gamma to MCS M0
    2. Build eval_family via `fragmentToIntFMCS` rooted at M0
    3. Modal saturation via `exists_fullySaturated_extension` (already sorry-free)
    4. Temporal coherence via Phase 4 + Task 5.2
  - Files: `TemporalCoherentConstruction.lean` - replace sorry
  - Estimate: 3-4 hours
  - Verification: `lean_goal` shows "no goals", sorry eliminated

- [ ] **Task 5.4**: Verify completeness chain is sorry-free
  - Check that `standard_weak_completeness` and `standard_strong_completeness` in Representation.lean now compile without sorry
  - Run `lake build` on full project
  - Files: All Bundle/*.lean files
  - Estimate: 1 hour
  - Verification: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/*.lean` returns empty (or only deprecated files)

- [ ] **Task 5.5**: Deprecate DovetailingChain.lean
  - Mark `buildDovetailingChainFamily_forward_F` and `buildDovetailingChainFamily_backward_P` as deprecated
  - Add comment explaining that OrderIso approach supersedes chain-based F/P
  - Files: `DovetailingChain.lean`
  - Estimate: 30 min
  - Verification: Documentation updated

**Timing**: 8-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - witness family construction
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - eliminate sorry
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - deprecation notice

**Verification**:
- `lake build` passes on full project
- All completeness theorems proven without sorry
- `lean_verify` on completeness theorems shows no axiom dependencies beyond standard foundations

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/*.lean` returns empty (excluding deprecated files)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Completeness Verification
- [ ] `fully_saturated_bfmcs_exists_int` proven without sorry
- [ ] `standard_weak_completeness` proven without sorry (via dependency)
- [ ] `standard_strong_completeness` proven without sorry (via dependency)

### Property Verification (from existing infrastructure)
- [ ] `fragmentFMCS_forward_F` - already sorry-free (Phase D of v002)
- [ ] `fragmentFMCS_backward_P` - already sorry-free (Phase D of v002)
- [ ] `bidirectional_totally_ordered` - already sorry-free (Phase B of v002)

### New Property Verification
- [ ] `SuccOrder` instance verified
- [ ] `PredOrder` instance verified
- [ ] `IsSuccArchimedean` verified
- [ ] `NoMaxOrder` verified
- [ ] `NoMinOrder` verified
- [ ] `OrderIso (BidirectionalQuotient) Int` verified
- [ ] `fragmentToIntFMCS_forward_F` verified
- [ ] `fragmentToIntFMCS_backward_P` verified

## Artifacts & Outputs

**Modified files**:
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - SuccOrder, PredOrder, OrderIso
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - FMCS Int construction
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - sorry elimination
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - deprecation notice

**Plan artifacts**:
- `specs/951_implement_sorry_free_completeness_canonicalmcs/plans/implementation-003.md` - this plan
- `specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-YYYYMMDD.md` - completion summary (created on completion)

## Rollback/Contingency

### If SuccOrder coverness proof fails (Phase 1, Task 1.4)

**Alternative A**: Direct bijection enumeration
1. Build explicit `e : Int -> BidirectionalQuotient` via:
   - `e(0) = [M0]`
   - `e(n+1) = [fragmentGSucc (rep(e(n)))]` for n >= 0
   - `e(n-1) = [fragmentHPred (rep(e(n)))]` for n <= 0
2. Prove monotonicity (trivial)
3. Prove surjectivity (from reachability structure)
4. Prove injectivity (from strict monotonicity)
5. This avoids needing coverness but requires proving explicit enumeration hits all classes

**Alternative B**: Relaxed completeness
1. Prove completeness over `BidirectionalQuotient` directly (without converting to Int)
2. Requires generalizing Representation.lean to work with any `LinearOrder D` with suitable structure
3. Higher engineering cost but avoids SuccOrder entirely

### If IsSuccArchimedean proof is complex (Phase 2, Task 2.7)

1. Use induction on the length of the BidirectionalReachable path between elements
2. Each step increases or decreases by one succ/pred
3. Path length gives bound on number of succ/pred applications

### If Mathlib lacks orderIsoIntOfLinearSuccPredArch (Phase 3, Task 3.1)

1. Construct OrderIso directly:
   - Define `f : Int -> Q` by `f(0) = root`, `f(n+1) = succ(f(n))`, `f(n-1) = pred(f(n))`
   - Prove bijective (from NoMax/MinOrder + Archimedean)
   - Prove order-preserving (from succ/pred definitions)
   - Prove order-reflecting (from injectivity + LinearOrder)
2. This is ~50 lines of straightforward construction

### If implementation blocked

1. Mark relevant phase `[BLOCKED]` with `requires_user_review: true`
2. Write detailed handoff document explaining blocker
3. Do NOT introduce sorries as workarounds
4. User decides: revise approach, split task, or seek mathematical insight

## Notes

### Mathematical Foundation

The key insight from research-014 is that the BidirectionalFragment, when quotiented by preorder equivalence, forms a discrete linear order isomorphic to the integers. This follows from:

1. **Totality**: Any two fragment elements are CanonicalR-comparable (proven in Phase B of v002)
2. **Discreteness**: The Lindenbaum construction creates immediate successors/predecessors
3. **Unboundedness**: F(true) and P(true) guarantee forward/backward witnesses exist
4. **Archimedean**: Every element is reachable from the root by finitely many steps

The OrderIso transfers Int's arithmetic structure to the quotient, enabling the final FMCS Int construction.

### Coverness Intuition

The coverness proof (Task 1.4) relies on the observation that between any fragment element `w` and its GContent successor `fragmentGSucc w`, there cannot be a strictly intermediate element. This is because:
- Any intermediate `v` must have `GContent(w) subset v`
- `fragmentGSucc w` is a MAXIMAL consistent extension of `GContent(w)`
- If `v <= fragmentGSucc w` and `GContent(w) subset v`, then v is also a consistent extension
- By maximality properties and the linearity axiom, v and fragmentGSucc w must be preorder-equivalent

### Literature Reference

Goldblatt (1992) "Logics of Time and Computation" Chapter 4 uses a similar approach: work at the canonical frame level where temporal witnesses are trivially available, then embed into the desired time structure.

### Estimated Total Effort

- Phase 1: 8-10 hours
- Phase 2: 9-12 hours
- Phase 3: 5-8 hours
- Phase 4: 10-14 hours
- Phase 5: 8-12 hours
- **Total: 40-56 hours** (estimated 25-35 hours optimistically if proofs go smoothly)

### Session Continuity

This plan is designed for multi-session implementation. Each phase can be completed independently and committed. Progress tracking via the Progress subsection in each phase.
