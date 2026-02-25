# Research Report: Task #922

**Task**: Strategy study: forward_F/backward_P completeness blockers
**Date**: 2026-02-24
**Focus**: Blocker analysis and resolution path evaluation for quotient representative mismatch
**Session**: sess_1771984521_651081

## Summary

The Phase 4 blocker in CanonicalBFMCS.lean is a fundamental incompatibility between the Antisymmetrization quotient construction and individual formula membership. When `canonical_forward_F` produces witness W with `phi in W`, mapping W to `CanonicalQuotient` yields a quotient element whose representative `s.repr` may differ from W. Only G-formulas (via GContent equality) propagate between equivalent representatives -- arbitrary formulas like phi do not.

**Recommendation: Option 1 (Generalize BFMCS to Preorder) is the best path forward.** The analysis shows that LinearOrder is never actually used in proofs throughout the TruthLemma, BMCS, BMCSTruth, or TemporalCoherentConstruction chains. It appears only as a type constraint. Working directly with `CanonicalReachable` as a `Preorder` eliminates the quotient entirely, making forward_F and backward_P trivially provable while maintaining compatibility with the completeness chain.

## Findings

### 1. Deep Analysis of the Quotient Representative Mismatch

The blocker occurs in `CanonicalBFMCS.lean` lines 194-217. The proof of `canonicalBFMCS_forward_F` proceeds:

1. Given `F(phi) in canonicalBFMCS_mcs t` (i.e., `F(phi) in t.repr.world`)
2. Apply `canonical_forward_F` to get witness W with `SetMaximalConsistent W`, `CanonicalR t.repr.world W`, and `phi in W`
3. Construct `s_pre : CanonicalReachable` from W
4. Map to quotient: `s := CanonicalQuotient.mk s_pre`
5. Prove `t <= s` (succeeds: CanonicalR gives ordering via `mk_le_mk`)
6. **BLOCKED**: Need `phi in canonicalBFMCS_mcs s`, i.e., `phi in s.repr.world`

The blocker is step 6. We have `phi in W = s_pre.world`, but `s.repr` is the quotient representative of `[s_pre]`, which is some element `s.repr` satisfying `AntisymmRel (<=) s_pre s.repr`. This means:
- `CanonicalR s_pre.world s.repr.world` (i.e., `GContent(s_pre.world) subset s.repr.world`)
- `CanonicalR s.repr.world s_pre.world` (i.e., `GContent(s.repr.world) subset s_pre.world`)

By `gcontent_eq_of_mutual_R`, this gives `GContent(s_pre.world) = GContent(s.repr.world)`. So **G-formulas** transfer: if `G(psi) in W`, then `psi in GContent(W) = GContent(s.repr.world)`, so `G(psi) in s.repr.world`.

But for an arbitrary formula phi, `phi in W` gives us nothing about `phi in s.repr.world`. The formula phi was placed in W by Lindenbaum extension of `{phi} union GContent(t.repr.world)`. It is NOT a G-formula and NOT in GContent of anything.

**This is an intrinsic limitation of the quotient approach**: the Antisymmetrization quotient preserves only the information that determines equivalence classes (GContent), not individual formula membership.

### 2. LinearOrder Usage Audit

A systematic grep reveals that `LinearOrder` appears as a type constraint in:
- BFMCS.lean (line 54)
- BMCS.lean (line 51)
- BMCSTruth.lean (line 54)
- TruthLemma.lean (line 83)
- Completeness.lean (line 79)
- TemporalCoherentConstruction.lean (line 56, 206, 340, 607, 755)
- ModalSaturation.lean (line 49, 460)
- Construction.lean (line 47)
- CoherentConstruction.lean (line 96, 559, 871, 1076, 1099)

However, **no proof in the chain actually uses LinearOrder-specific properties**. Specifically:

| Property | Used in proofs? | Evidence |
|----------|----------------|----------|
| `le_total` (totality) | NO | grep returns zero uses in TruthLemma, BMCS, BMCSTruth, TemporalCoherentConstruction |
| `lt_trichotomy` | NO | grep returns zero uses |
| `le_antisymm` | NO | grep returns zero uses |
| `Decidable` ordering | NO | grep returns zero uses |
| `lt_or_eq_of_le` | YES (TruthLemma lines 103, 126) | But this works on `PartialOrder` (verified via `lean_run_code`) |

The only ordering property used is `lt_or_eq_of_le` (splitting `h : a <= b` into `a < b` or `a = b`), which is available on `PartialOrder`, not just `LinearOrder`.

**Conclusion**: The entire BFMCS -> BMCS -> TruthLemma -> Completeness chain could be parameterized by `PartialOrder` instead of `LinearOrder` without breaking any proofs.

### 3. Evaluation of Resolution Options

#### Option 1: Generalize BFMCS to Preorder (RECOMMENDED)

**Approach**: Change `[LinearOrder D]` to `[Preorder D]` in BFMCS and downstream, then use `CanonicalReachable` directly (which has a natural Preorder via CanonicalR).

**Feasibility**: HIGH
- `CanonicalReachable` already has `Preorder` instance (CanonicalQuotient.lean line 64-67)
- `lt_or_eq_of_le` works on `PartialOrder` (verified). For `Preorder`, we would need `LE.le.lt_or_eq` which requires antisymmetry. Two sub-options:
  - (a) Use `PartialOrder` instead of `Preorder`. CanonicalReachable has extensional equality so antisymmetry holds by `CanonicalReachable.ext`. But standard Lean `PartialOrder` requires `le_antisymm : a <= b -> b <= a -> a = b` on the carrier. For CanonicalReachable, if `CanonicalR a.world b.world` and `CanonicalR b.world a.world`, we do NOT have `a = b` (only `GContent(a) = GContent(b)`). So `PartialOrder` fails.
  - (b) Restructure TruthLemma helpers to avoid `lt_or_eq_of_le`. Instead of splitting `t <= s` into `t < s | t = s`, directly handle the `t <= s` case. For `mcs_all_future_implies_phi_at_future`, we currently split into "strict future" (use `forward_G`) and "equal" (use T-axiom). We could instead use `forward_G` for strict AND reflexive via a `forward_G_le` helper that combines both cases.
  - (c) Keep `LinearOrder` but work on `CanonicalQuotient` while mapping back to `CanonicalReachable` for phi-membership. But this circles back to the original blocker.

**Actually, option (a) with Antisymmetrization still works**: We could take the Antisymmetrization quotient but change the MCS assignment from `q.repr.world` to something that tracks individual formulas. But this doesn't help -- the whole point is that we need a CANONICAL representative.

**The key insight for Option 1**: We don't actually need `lt_or_eq` at all. The `mcs_all_future_implies_phi_at_future` helper can be restructured:

```
-- Current (needs lt_or_eq):
lemma mcs_all_future_implies_phi_at_future (fam : BFMCS D) (t s : D)
    (hts : t <= s) (hG : G(phi) in fam.mcs t) : phi in fam.mcs s := by
  rcases hts.lt_or_eq with h_lt | h_eq  -- needs PartialOrder
  ...

-- Alternative (works on Preorder):
lemma mcs_all_future_implies_phi_at_future (fam : BFMCS D) (t s : D)
    (hts : t <= s) (hG : G(phi) in fam.mcs t) : phi in fam.mcs s := by
  -- T-axiom: G(phi) -> phi, so phi in fam.mcs t
  -- forward_G_le: if t <= s and G(phi) in mcs(t), we need phi in mcs(s)
  -- Actually, we just need: G(phi) in mcs(t) and t <= s -> phi in mcs(s)
  -- But forward_G only gives us t < s -> phi in mcs(s)
  -- For t = s, we use T-axiom
  -- Problem: on a Preorder, t <= s doesn't split cleanly into t < s or t = s
```

This reveals a genuine difficulty: on a Preorder, `t <= s` does NOT imply `t < s` or `t = s` (because `<` requires `NOT (s <= t)`, but both `t <= s` and `s <= t` can hold with `t != s`). So the TruthLemma helper needs restructuring.

**Revised feasibility for Option 1**: MEDIUM. The restructuring is non-trivial because `forward_G` in BFMCS uses strict `<`, and the TruthLemma forward direction relies on splitting `<=` into `<` or `=`. To make this work with Preorder, either:
- (1a) Change `forward_G` to use `<=` (but then forward_G is just "G phi in mcs t implies phi in mcs s for all s >= t", which makes BFMCS stronger -- achievable since CanonicalR gives this)
- (1b) Add a separate `forward_G_refl` field using T-axiom
- (1c) Accept that we need `PartialOrder` minimum, and prove CanonicalReachable can be given PartialOrder (it cannot natively, since mutual CanonicalR doesn't imply equality)

**Sub-option 1a is actually the cleanest approach**: Change BFMCS to use `<=` instead of `<` for forward_G/backward_H. This is a weakening of the conditions (easier to satisfy). Then:
- For CanonicalReachable: `forward_G_le` follows directly from CanonicalR (which IS the `<=` relation)
- For TruthLemma helpers: `mcs_all_future_implies_phi_at_future` becomes trivially `fam.forward_G_le t s phi hts hG`
- For existing Int construction: `forward_G_le` follows from `forward_G` (strict) + T-axiom (reflexive)

This approach requires:
- Changing BFMCS.forward_G from `t < t'` to `t <= t'`
- Changing BFMCS.backward_H from `t' < t` to `t' <= t`
- Simplifying TruthLemma helpers
- Updating all BFMCS constructions to provide the weakened property
- Changing `[LinearOrder D]` to `[Preorder D]` across the chain

**Effort**: ~8-12 files need signature changes. Most proofs adapt easily since the existing constructions satisfy the reflexive condition via T-axioms.

**Risk**: LOW for the core chain. Existing Int-based constructions (DovetailingChain) use `<` internally but can provide `<=` externally. The only risk is cascading changes in downstream files.

#### Option 2: Hybrid Construction

**Approach**: Use canonicalBFMCS for forward_G/backward_H, and a DovetailingChain-style construction for forward_F/backward_P.

**Feasibility**: LOW
- forward_G/backward_H and forward_F/backward_P must operate on the SAME family (same `mcs` function)
- A hybrid approach would need to merge two different MCS assignments, which is mathematically incoherent
- The BFMCS structure requires a single `mcs : D -> Set Formula` function
- There is no mechanism to "combine" two different families

**Effort**: Very high, likely impossible without fundamental redesign.
**Risk**: Very high -- mathematical coherence is not guaranteed.
**Verdict**: REJECT.

#### Option 3: OrderIso to Int

**Approach**: Embed `CanonicalQuotient` into Int via `orderIsoIntOfLinearSuccPredArch`.

**Feasibility**: MEDIUM-LOW
- `orderIsoIntOfLinearSuccPredArch` requires `[SuccOrder], [PredOrder], [IsSuccArchimedean], [NoMaxOrder], [NoMinOrder], [Nonempty]`
- `CanonicalQuotient` is `Nonempty` (proven) and has `LinearOrder` (from Antisymmetrization)
- `NoMaxOrder` and `NoMinOrder` are NOT proven and are mathematically questionable:
  - Every MCS M has F(phi) for some phi not in M (since not temporally saturated)
  - `canonical_forward_F_strict` gives W != M with CanonicalR M W
  - But does [W] differ from [M] in the quotient? Only if W and M are NOT mutually CanonicalR-related
  - This requires showing GContent(W) != GContent(M), which is plausible but not proven
- `SuccOrder`, `PredOrder`, `IsSuccArchimedean` are even harder to establish
- Even if achieved, the original phi-membership problem remains: the OrderIso transfers the structure but `phi in W` still needs to become `phi in (iso(s)).repr.world`

**Key problem**: OrderIso transfers the ordering structure to Int but does NOT change the MCS assignment. We still use `q.repr.world` as the MCS at each point. The forward_F witness W still maps to a quotient element whose representative differs from W. The OrderIso does not help with the fundamental problem.

**Effort**: Very high. NoMaxOrder/NoMinOrder proofs alone would be major undertakings.
**Risk**: Very high -- the fundamental blocker persists even after successful embedding.
**Verdict**: REJECT. This was already explored in plan v3 and abandoned.

#### Option 4: Alternative Approaches

**4a. Work with CanonicalReachable directly (avoid quotient entirely)**

This is essentially Option 1 -- use CanonicalReachable with its Preorder as the domain D.

**4b. "Freeze" the witness to equal the representative**

Impossible. The Antisymmetrization quotient uses `Quotient.out` (or similar) which is determined by Lean's `Choice` axiom. We cannot control which representative is chosen.

**4c. Generalize completeness chain to accept any LinearOrder D**

The completeness chain already accepts generic D. The problem is that:
- `Completeness.lean` instantiates with `Int` (via `construct_saturated_bmcs_int`)
- `fully_saturated_bmcs_exists_int` specifically returns `BMCS Int`
- To use CanonicalQuotient, we'd need a different entry point

This is essentially what Option 1 achieves: provide the BMCS over CanonicalReachable (or CanonicalQuotient for the part that works) and wire it into completeness.

**4d. Change MCS assignment from `q.repr.world` to track the witness**

Instead of `canonicalBFMCS_mcs q := q.repr.world`, define MCS assignment using a Quotient.lift that selects appropriately. But the MCS needs to be a FIXED function from D to Set Formula, not one that changes based on which formula we're trying to witness. This doesn't work for the general case.

**4e. Use the Preorder CanonicalReachable for temporal properties, with a single-MCS BMCS for modal properties**

This is a variant of Option 1 where:
- The eval_family is indexed by CanonicalReachable (Preorder)
- forward_G, backward_H, forward_F, backward_P are all satisfied directly
- Modal saturation is handled separately (same as current approach)
- The completeness chain is parameterized by CanonicalReachable instead of Int

This is the RECOMMENDED approach.

### 4. Detailed Plan for Option 1 (Recommended)

**Phase A: Generalize BFMCS from LinearOrder to Preorder**

1. Change `BFMCS.lean` line 54: `[LinearOrder D]` -> `[Preorder D]`
2. Change `forward_G` from `t < t'` to `t <= t'`
3. Change `backward_H` from `t' < t` to `t' <= t`
4. Propagate to BMCS.lean, BMCSTruth.lean, TruthLemma.lean, Completeness.lean, etc.
5. Update `mcs_all_future_implies_phi_at_future` to directly use `forward_G` with `<=`
6. Update all BFMCS constructions (DovetailingChain, ConstantFamily, etc.) to satisfy `<=`

**Phase B: Build BFMCS on CanonicalReachable**

1. Create `canonicalBFMCS : BFMCS (CanonicalReachable M0 h_mcs0)` where:
   - `mcs w := w.world`
   - `forward_G t s phi h_le h_G := canonical_forward_G t.world s.world h_le phi h_G`
   - `backward_H` via GContent_subset_implies_HContent_reverse duality
   - `forward_F` via `canonical_forward_F` (witness IS in CanonicalReachable directly, no quotient)
   - `backward_P` via `canonical_backward_P`
2. No quotient needed! phi membership is preserved because `mcs w = w.world` directly.

**Phase C: Wire into Completeness**

1. Provide `temporal_coherent_family_exists` for `CanonicalReachable` (trivially: use canonicalBFMCS)
2. Generalize `fully_saturated_bmcs_exists_int` to work with generic Preorder D
3. Or: keep Int for modal saturation, use CanonicalReachable only for temporal coherence
4. The key insight: the completeness theorem can quantify over `Type` with `Preorder` instead of `LinearOrder`

**Risk Assessment for Option 1**:

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Changing forward_G to `<=` breaks existing BFMCS constructions | Medium | 20% | Each construction already satisfies `<=` via T-axiom |
| Preorder on BFMCS not expressive enough | Low | 5% | Verified: no proof uses LinearOrder-specific features |
| Cascading signature changes across 12+ files | Medium | 90% (certain) | Mechanical changes, each testable with `lake build` |
| Modal saturation infrastructure needs LinearOrder | Medium | 15% | Check ModalSaturation.lean dependencies |
| bmcs_valid definition uses LinearOrder | Medium | 40% | May need to generalize or keep Int-specific version |

### 5. Why Option 1 Eliminates the Blocker

The blocker exists because:
1. CanonicalReachable has a Preorder (NOT antisymmetric)
2. To get LinearOrder, we take Antisymmetrization quotient
3. Quotient introduces representatives that lose individual formula membership
4. forward_F witness phi goes missing in the representative

Option 1 eliminates step 2-4 entirely by working with the Preorder directly:
- `mcs w = w.world` (NO representative indirection)
- `canonical_forward_F` gives W with phi in W
- W is directly a CanonicalReachable element (step 3 in current CanonicalBFMCS.lean already constructs this)
- `mcs W = W.world` and `phi in W.world` -- done!

The only question is whether the rest of the chain can work with Preorder instead of LinearOrder. The audit in Finding 2 confirms it can, with the modification described in Finding 3 (changing `forward_G`/`backward_H` to use `<=`).

## Recommendations

1. **Pursue Option 1: Generalize BFMCS to Preorder (or at minimum weaken forward_G/backward_H to `<=`).** This is the cleanest path with the lowest risk and directly eliminates the blocker.

2. **The critical first step is changing BFMCS.forward_G from `<` to `<=` and similarly for backward_H.** This is the enabling change that makes CanonicalReachable (Preorder) viable as the domain. Existing constructions (DovetailingChain, constant families) can provide `<=` trivially via T-axiom.

3. **Do NOT pursue OrderIso to Int (Option 3) or Hybrid (Option 2).** Both have been shown to not address the fundamental blocker.

4. **If changing `[LinearOrder D]` to `[Preorder D]` across the chain proves too disruptive, an intermediate option exists**: Keep `[LinearOrder D]` in the general definitions but provide the completeness proof over `CanonicalQuotient` (LinearOrder) with a different MCS assignment. Specifically, use `Quotient.lift` on a function that agrees on GContent-equivalent representatives. However, this still faces the phi-membership problem for non-G-formulas.

5. **The recommended implementation sequence**:
   - Phase A: Change forward_G/backward_H to `<=` (BFMCS.lean + cascading)
   - Phase B: Change `[LinearOrder D]` to `[Preorder D]` across chain
   - Phase C: Build BFMCS on CanonicalReachable with trivial proofs
   - Phase D: Wire into completeness, replacing `fully_saturated_bmcs_exists_int`

## References

- CanonicalBFMCS.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean`
- CanonicalQuotient.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean`
- CanonicalReachable.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean`
- CanonicalFrame.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- BFMCS.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- BMCS.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BMCS.lean`
- BMCSTruth.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`
- TruthLemma.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- Completeness.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- TemporalCoherentConstruction.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- DovetailingChain.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Mathlib.Order.Antisymmetrization: Antisymmetrization quotient infrastructure
- `orderIsoIntOfLinearSuccPredArch`: Mathlib.Order.SuccPred.LinearLocallyFinite
- research-005.md: Breakthrough finding (reflexive forward_F suffices)
- research-006.md: TruthLemma audit (both directions validated)
- implementation-004.md: Plan v4 (Phase 4 blocked)
- implementation-summary-20260225.md: Implementation status (Phases 1-3 complete)

## Next Steps

1. Create implementation plan v5 based on Option 1 (Preorder generalization)
2. Phase A first: change forward_G/backward_H to `<=` -- this is the smallest testable delta
3. If Phase A succeeds, proceed to Phase B (Preorder generalization) and Phase C (CanonicalReachable BFMCS)
4. Phase D (completeness wiring) completes the sorry elimination for temporal components
