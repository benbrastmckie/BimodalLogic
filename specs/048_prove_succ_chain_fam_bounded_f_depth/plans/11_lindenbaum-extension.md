# Implementation Plan: Task #48 (v11)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Dependencies**: Research report 19 (team research - root cause analysis)
- **Research Inputs**:
  - specs/048_prove_succ_chain_fam_bounded_f_depth/reports/19_team-research.md
- **Previous Plans**:
  - plans/10_chi-in-u-restriction.md (5 sorries remain at boundary cases)
- **Artifacts**: plans/11_lindenbaum-extension.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

After 10 plan versions, team research identified the root cause: **DeferralRestrictedMCS has only LOCAL negation completeness**, making `succ_propagates_F_not` unprovable as stated at the FF-boundary. All 5 remaining sorries (lines 3201, 3360, 4108, 4336, 4348) reduce to this same gap.

The solution is to **lift restricted chain elements to full MCS via Lindenbaum extension**, then apply the existing working `bounded_witness` from CanonicalTaskRelation.lean, and transfer results back. The infrastructure already exists:
- `DeferralRestrictedSerialMCS.extendToMCS` (line 4613)
- `extendToMCS_is_mcs` (line 4621)
- `extendToMCS_extends` (line 4630)
- `bounded_witness` in CanonicalTaskRelation.lean (line 651)

### Research Integration

Key findings from team research report 19:
1. **Root cause confirmed**: The Succ relation imposes only INCLUSION constraints, not EXCLUSION. MCS maximality can freely choose `F(psi)` when consistent with seed.
2. **Stop patching**: `succ_propagates_F_not` cannot be proven for restricted MCS as stated.
3. **Lindenbaum approach**: Lift to full MCS where global negation completeness applies, then transfer back.
4. **Critical gap**: Must prove `psi in dc AND psi in ext(chain(k)) implies psi in chain(k)` for the transfer-back step.

## Goals & Non-Goals

**Goals**:
- Prove `Succ` relation lifts through Lindenbaum extension (ext preserves Succ)
- Prove transfer-back property for formulas in deferralClosure
- Apply existing `bounded_witness` to extension chain
- Remove all 5 boundary case sorries (lines 3201, 3360, 4108, 4336, 4348)
- Net sorry count: 2 (deprecated f_nesting_is_bounded, p_nesting_is_bounded)

**Non-Goals**:
- Proving `succ_propagates_F_not` directly for restricted MCS (impossible)
- Modifying the chain construction
- Lexicographic termination measure (backup approach, not needed if Lindenbaum works)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Succ doesn't lift to extensions | High | Medium | Extension only ADDS formulas; Succ is inclusion-based |
| Transfer-back property fails | High | Low | Formulas in dc are decided by restricted MCS's seed |
| CanonicalTask_forward_MCS mismatch | Medium | Medium | May need adapter for restricted chain to full chain |

## Implementation Phases

### Phase 1: Prove Succ Lifts to Extensions [BLOCKED]

**Goal**: Show that if `Succ(chain(k), chain(k+1))` for restricted MCS, then `Succ(ext(chain(k)), ext(chain(k+1)))` for full MCS extensions.

**Mathematical argument**:
- `Succ` requires: g_persistence, f_step, p_step
- `g_persistence(u, v)` = `g_content(u) ⊆ v`
- Since `chain(k) ⊆ ext(chain(k))`, we have `g_content(chain(k)) ⊆ g_content(ext(chain(k)))`
- Since `chain(k+1) ⊆ ext(chain(k+1))` and g_persistence holds for restricted chain:
  `g_content(chain(k)) ⊆ chain(k+1) ⊆ ext(chain(k+1))`
- Therefore `g_content(ext(chain(k))) ⊇ g_content(chain(k))`, so we need to show the extra formulas also satisfy persistence
- Actually, this is the hard part: `g_content(ext)` may contain formulas not in `g_content(chain)`, and those need to persist into `ext(chain(k+1))`

**Revised approach**: Show `Succ` is preserved when BOTH sides are extended, using MCS properties:
```lean
theorem extendToMCS_preserves_Succ {phi : Formula}
    (u v : DeferralRestrictedSerialMCS phi)
    (h_succ : Succ u.world v.world) :
    Succ u.extendToMCS v.extendToMCS
```

**Proof sketch**:
1. For g_persistence: `G(psi) in ext(u)` implies either `G(psi) in u` (use existing) or `G(psi) notin u` (use MCS negation completeness to derive psi in ext(v))
2. For f_step: `F(psi) in ext(u)` either comes from u (use existing) or from extension (new F-obligation, MCS must satisfy via v)
3. For p_step: Similar argument

**Alternative simpler approach**: Don't prove Succ lifts. Instead, construct a DIFFERENT chain of full MCS that shadows the restricted chain.

**Tasks**:
- [ ] Analyze whether Succ preservation is provable for extensions
- [ ] If not, define a "shadow chain" construction: `shadow_chain(k) = extendToMCS(restricted_chain(k))`
- [ ] Prove shadow chain satisfies some forward-stepping property sufficient for bounded_witness

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 2: Prove Transfer-Back Property [NOT STARTED]

**Goal**: Show that for formulas in deferralClosure, membership in the extension implies membership in the restricted MCS.

**Statement**:
```lean
theorem extendToMCS_transfer_back {phi : Formula}
    (M : DeferralRestrictedSerialMCS phi)
    (psi : Formula)
    (h_in_dc : psi ∈ deferralClosure phi)
    (h_in_ext : psi ∈ M.extendToMCS) :
    psi ∈ M.world
```

**Mathematical argument**:
- DeferralRestrictedMCS is defined as the intersection of full MCS with deferralClosure
- Wait, that's not the definition. Let me check...
- Actually, DeferralRestrictedMCS is constructed via constrained Lindenbaum on deferralClosure
- The key property: formulas in deferralClosure are decided by the restricted MCS

**Alternative formulation**: The restricted MCS decides all formulas in deferralClosure.
```lean
theorem deferralRestricted_decides_dc {phi : Formula}
    (M : DeferralRestrictedSerialMCS phi)
    (psi : Formula)
    (h_in_dc : psi ∈ deferralClosure phi) :
    psi ∈ M.world ∨ psi.neg ∈ M.world
```

If this holds, then transfer-back follows:
- `psi in ext(M)` means psi is consistent with M
- `psi in dc` means M decides psi
- If M decides `psi.neg in M`, then `psi.neg in ext(M)` (by extension property)
- But ext(M) is MCS, so `psi` and `psi.neg` can't both be in ext(M)
- Contradiction, so `psi in M`

**Tasks**:
- [ ] Verify deferralRestricted_decides_dc is true or find the actual property
- [ ] Prove transfer-back using MCS properties
- [ ] Add appropriate lemmas for the proof

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 3: Apply bounded_witness to Extensions [NOT STARTED]

**Goal**: Use the existing `bounded_witness` from CanonicalTaskRelation.lean on the extended chain.

**Approach**:
1. Given restricted chain `chain(0), chain(1), ..., chain(k+d)`
2. Extend to `ext(chain(0)), ext(chain(1)), ..., ext(chain(k+d))`
3. Show these form a `CanonicalTask_forward_MCS` relationship (or similar)
4. Apply `bounded_witness`: if `F^d(psi) in ext(chain(k))` and `F^(d+1)(psi) notin ext(chain(k))`, then `psi in ext(chain(k+d))`
5. Use transfer-back: `psi in dc` so `psi in chain(k+d)`

**Key lemma needed**:
```lean
theorem restricted_chain_to_canonical_task {phi : Formula}
    (M0 : DeferralRestrictedSerialMCS phi)
    (k n : Nat) :
    CanonicalTask_forward_MCS
      (restricted_forward_chain phi M0 k).element.extendToMCS
      n
      (restricted_forward_chain phi M0 (k + n)).element.extendToMCS
```

**Tasks**:
- [ ] Prove the chain-to-CanonicalTask lemma (or verify existing infrastructure)
- [ ] Connect restricted_forward_chain to CanonicalTask_forward_MCS via extensions
- [ ] Apply bounded_witness and transfer back

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 4: Remove Boundary Case Sorries [NOT STARTED]

**Goal**: Replace the 5 sorries with proofs using the Lindenbaum extension approach.

**Sorries to remove**:
1. Line 3201: `restricted_single_step_forcing` boundary case
2. Line 3360: `restricted_succ_propagates_F_not` boundary case
3. Line 4108: `restricted_single_step_forcing'` boundary case
4. Line 4336: `restricted_succ_propagates_F_not'` boundary case
5. Line 4348: additional boundary case

**Strategy for each**:
- Don't try to prove the restricted versions directly
- Instead, use `restricted_bounded_witness_via_extension`:
  ```lean
  theorem restricted_bounded_witness_via_extension {phi : Formula}
      (M0 : DeferralRestrictedSerialMCS phi)
      (k : Nat) (psi : Formula) (d : Nat)
      (h_Fd : iter_F d psi ∈ (restricted_forward_chain phi M0 k).element.world)
      (h_Fd1_not : iter_F (d + 1) psi ∉ (restricted_forward_chain phi M0 k).element.world)
      (h_psi_in_dc : psi ∈ deferralClosure phi) :
      psi ∈ (restricted_forward_chain phi M0 (k + d)).element.world
  ```

**Tasks**:
- [ ] Prove `restricted_bounded_witness_via_extension` using Phase 1-3 results
- [ ] Update `restricted_single_step_forcing` to use new approach (or deprecate)
- [ ] Update `restricted_succ_propagates_F_not` to use new approach (or deprecate)
- [ ] Remove all 5 sorries, replacing with calls to new lemma
- [ ] Verify build succeeds

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 5: Verify and Clean Up [NOT STARTED]

**Goal**: Final verification and cleanup.

**Tasks**:
- [ ] Run `lake build` - must succeed
- [ ] Run `grep -c "sorry" SuccChainFMCS.lean` - expect 2 (deprecated only)
- [ ] Verify the 2 deprecated sorries are at lines 736 and 971
- [ ] Remove or mark as deprecated any obsolete intermediate lemmas
- [ ] Update file header comments to reflect completed status
- [ ] Clean up debug comments

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

## Testing & Validation

- [ ] `lake build` succeeds
- [ ] `grep -c "sorry" SuccChainFMCS.lean` returns 2 (deprecated only)
- [ ] Sorries at lines 3201, 3360, 4108, 4336, 4348 are all removed
- [ ] `restricted_bounded_witness_via_extension` compiles and type-checks
- [ ] `extendToMCS_preserves_Succ` or equivalent is proven
- [ ] `extendToMCS_transfer_back` is proven
- [ ] No new imports needed (uses existing infrastructure)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Completed proofs
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/11_lindenbaum-extension-summary.md` - Summary

## Rollback/Contingency

If Lindenbaum extension approach fails:

1. **Phase 1 fails (Succ doesn't lift)**:
   - Fall back to lexicographic bounded witness (backup from research)
   - Track `(g_depth, f_depth)` instead of just `d`
   - More restructuring required but mathematically sound

2. **Phase 2 fails (transfer-back doesn't hold)**:
   - Investigate whether restricted MCS actually decides all of deferralClosure
   - May need to strengthen DeferralRestrictedMCS definition
   - Alternative: prove witness is in deferralClosure directly

3. **Phase 3 fails (CanonicalTask mismatch)**:
   - Define a specialized "ExtendedCanonicalTask" relation
   - Prove bounded_witness-like theorem for it

## Key Insight

The theorem IS true (semantic argument from research). The proof strategy changes from:
- **OLD**: Try to prove `F(psi) notin chain(k+1)` for restricted MCS (FALSE in general)
- **NEW**: Lift to full MCS where global negation completeness applies, prove there, transfer back

Stop fighting the restricted negation completeness limitation. Use Lindenbaum extension to access full MCS machinery.
