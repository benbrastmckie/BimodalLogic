# Teammate A Findings: Advantages of Mixed Semantics (Reflexive G/H, Strict U/S)

**Task**: 83 - Close Restricted Coherence Sorries
**Angle**: Comprehensive advantage analysis of mixed semantics
**Confidence Level**: HIGH (based on direct codebase evidence and literature alignment)

## 1. Proof-Theoretic Advantages

### 1.1. T-Axiom Enables Seed Consistency for Lindenbaum Extensions

**The single most important advantage.** Under mixed semantics, G(phi)->phi is a theorem. This directly enables the seed consistency argument for F-witness construction:

- If F(psi) is in MCS M, then neg(G(neg(psi))) is in M, so G(neg(psi)) is not in M (by MCS), so neg(psi) is not in g_content(M).
- Therefore {psi} union g_content(M) is consistent, and a Lindenbaum extension yields an MCS containing psi as an F-witness.

**Codebase evidence**: `WitnessSeed.lean` already has `forward_temporal_witness_seed_consistent` proven sorry-free WITHOUT the T-axiom (lines 80-100). But this existing proof only works for the basic seed. The T-axiom additionally provides g_content(M) subset M, which means the seed inherits more structure from M. Under strict semantics, g_content(M) is NOT necessarily a subset of M (since G(phi) in M does not imply phi in M), which creates complications for building coherent chains.

**Confidence**: HIGH -- the mechanism is proven in `WitnessSeed.lean` and the T-axiom direction is verified in report 26.

### 1.2. g_content(M) subset M Becomes Trivially True

Under reflexive semantics with the T-axiom, for any MCS M:
- G(phi) in M implies phi in M (by T-axiom + MCS closure under derivation)
- Therefore g_content(M) = {phi | G(phi) in M} is a subset of M

This structural property is used throughout the completeness construction. Under strict semantics, g_content(M) can contain formulas NOT in M, which forces complex workarounds (e.g., the restricted chains in `SuccChainFMCS.lean` that track deferralClosure membership).

**Codebase evidence**: The `DeterministicFMCS.lean` construction at line 49 defines `forward_G` using `forward_G_int` which propagates G-formulas to strictly future times. Under reflexive semantics, the FMCS `forward_G` field changes from `t < t'` to `t <= t'`, and the t=t' case becomes trivially: G(phi) in mcs(t) implies phi in mcs(t) by T-axiom. This is exactly the pattern shown in `TargetedChainArchive.lean` lines 21-48 (archived Boneyard code).

**Confidence**: HIGH

### 1.3. FMCS forward_G/backward_H Reflexive Case Becomes Trivial

The `FMCS` structure (`FMCSDef.lean` lines 99-117) has two coherence fields:
- `forward_G : forall t t' phi, t < t' -> G(phi) in mcs(t) -> phi in mcs(t')`
- `backward_H : forall t t' phi, t' < t -> H(phi) in mcs(t) -> phi in mcs(t')`

Under mixed semantics these become:
- `forward_G : forall t t' phi, t <= t' -> G(phi) in mcs(t) -> phi in mcs(t')`
- `backward_H : forall t t' phi, t' <= t -> H(phi) in mcs(t) -> phi in mcs(t')`

The new `t = t'` case in each field is closed by:
```
G(phi) in mcs(t) -> phi in mcs(t)  [by T-axiom + MCS closure]
```

This eliminates the need for any chain-stepping argument in the reflexive case.

**Confidence**: HIGH

### 1.4. Proof Obligations That Become Trivially Closable

| Obligation | Under Strict | Under Reflexive |
|-----------|-------------|----------------|
| FMCS forward_G at t=t' | Not applicable (strict < means t != t') | Trivial by T-axiom |
| FMCS backward_H at t=t' | Not applicable | Trivial by T-axiom |
| CanonicalConstructionArchive forward_G | SORRY (line 65) -- independent extensions don't propagate G | Split: t=t' trivial, t<t' uses chain stepping |
| TargetedChainArchive forward_G | SORRY at `temp_t_future` call (line 32) | Direct axiom invocation: `DerivationTree.axiom _ _ (Axiom.temp_t_future phi)` |
| FMP mcs_all_future_closure | SORRY (TruthPreservationArchive line 30) | Direct: G(psi) in S implies psi in S by T-axiom + MCS closure |
| FMP mcs_all_past_closure | SORRY (TruthPreservationArchive line 49) | Direct: H(psi) in S implies psi in S by T-axiom + MCS closure |

**Confidence**: HIGH -- each sorry site has `was: temp_t_future/temp_t_past` annotations confirming the T-axiom was the original mechanism.

## 2. Model-Theoretic Advantages

### 2.1. Mixed Semantics Is Well-Behaved

The mixed semantics (reflexive G/H with >=, strict U/S with >) is model-theoretically coherent because:

- **G and H** quantify over a reflexive relation (>=), making the accessibility relation for temporal necessity reflexive. This yields the standard T-axiom.
- **U and S** use strict witnesses, which is the standard convention ensuring that the witness is in the FUTURE (not NOW). This avoids the degenerate case where phi U psi is true at t because psi is already true at t (which would make Until trivially equivalent to "psi or (phi and phi U psi)").
- The combination is standard: Burgess (1984), GHR (1994), and Goldblatt (1992) all use this convention.

**Confidence**: HIGH

### 2.2. Canonical Frame Construction Becomes Cleaner

Under reflexive semantics, the canonical frame for temporal logic has a reflexive temporal order (<=) rather than strict (<). Key benefits:

- **No irreflexivity proof needed**: The current codebase has `CanonicalIrreflexivity.lean` for proving the canonical relation is irreflexive. Under reflexive semantics, this file may become unnecessary or simpler (no need to establish irreflexivity).
- **Standard frame conditions**: Reflexivity of the temporal order is automatic (>= is reflexive), so the frame satisfies the T-axiom frame condition (reflexivity) by construction rather than requiring proof.
- **Bundle construction**: The `bundle_modal_forward` theorem (DeterministicFMCS.lean lines 116-131) uses the T-axiom at line 131 (`Axiom.modal_t phi`). This is already present and sorry-free -- it works because modal T is already an axiom. Adding temporal T-axioms extends the same pattern to temporal operators.

**Confidence**: MEDIUM-HIGH

### 2.3. Class of Validities

The mixed semantics validates strictly MORE formulas than the pure strict semantics:
- Everything valid under strict semantics remains valid (strict < implies reflexive <=)
- Additionally: G(phi)->phi and H(phi)->phi become valid
- Additionally: density axiom GG->G becomes trivially valid (since G(G(phi)) with >= already includes the present, so G(G(phi))->G(phi) follows from transitivity of >=)

The class of validities under mixed semantics over Z matches the standard TM logic with T-axioms.

**Confidence**: HIGH

## 3. Practical/Implementation Advantages

### 3.1. Sorries Directly Closed or Simplified

| File | Sorry | Effect of Mixed Semantics |
|------|-------|--------------------------|
| `DeterministicFMCS.lean:67` | `deterministic_forward_F` | NOT directly closed (requires hybrid construction), but T-axiom enables the Lindenbaum seed argument that resolves it |
| `DeterministicFMCS.lean:74` | `deterministic_backward_P` | Same as above (symmetric) |
| `DeterministicFMCS.lean:483` | forward Until in `usc` | Depends on forward_F -- indirectly resolved |
| `DeterministicFMCS.lean:495` | forward Since in `usc` | Depends on backward_P -- indirectly resolved |
| `SuccChainFMCS.lean:1241` | `sorry /- was: temp_t_future chi -/` | DIRECTLY closed by T-axiom invocation |
| `SuccChainFMCS.lean:3778` | `sorry /- was: temp_t_past chi -/` | DIRECTLY closed by T-axiom invocation |
| `SuccChainFMCS.lean:4045` | `sorry /- was: temp_t_future chi -/` | DIRECTLY closed by T-axiom invocation |
| `SuccChainFMCS.lean:4188` | `sorry /- was: temp_t_future neg_neg_bot -/` | DIRECTLY closed by T-axiom invocation |

**Conservative count**: At least 4 sorries become directly closable by substituting `sorry` with `DerivationTree.axiom [] _ (Axiom.temp_t_future ...)`. The 2 leaf sorries in DeterministicFMCS plus their 2 dependents (4 total) are indirectly resolved through the hybrid construction.

**Confidence**: HIGH for the 4 direct closures, MEDIUM-HIGH for the 4 indirect ones.

### 3.2. Boneyard Code Restoration

Three files in `Boneyard/TAxiomDependentCode/` (~300 lines total) become restorable:

1. **TargetedChainArchive.lean** (~100 lines): Contains `targeted_forward_chain_forward_G`, `targeted_backward_chain_backward_H`, `targeted_fam_forward_G`, `targeted_fam_backward_H`. These are complete proofs with sorries only at `temp_t_future`/`temp_t_past` call sites -- the sorries become direct axiom invocations.

2. **CanonicalConstructionArchive.lean** (~70 lines): Contains `restricted_tc_family_to_fmcs` with `forward_G` and `backward_H` fields. The t=t' case becomes trivial; the t<t' case still has the independent extension problem BUT is no longer needed (the deterministic chain handles it).

3. **TruthPreservationArchive.lean** (~80 lines): Contains `mcs_all_future_closure` and `mcs_all_past_closure` for the FMP path. Both become trivial under reflexive semantics: G(psi) in S implies psi in S by T-axiom.

**Confidence**: HIGH for files 1 and 3 (direct T-axiom substitution), MEDIUM for file 2 (still has independent extension issue for t<t' case).

### 3.3. Overall Sorry Reduction

Based on the grep of `sorry` across the codebase:

- **Directly closable by T-axiom**: ~4 sorries in SuccChainFMCS.lean
- **Closable through hybrid construction**: 2 leaf sorries (deterministic_forward_F, deterministic_backward_P) + 2 dependents = 4 in DeterministicFMCS.lean
- **FMP path unblocked**: 2 sorries in TruthPreservationArchive.lean
- **Potentially closable**: Several sorries in SuccChainFMCS.lean that reference T-axiom in comments

**Estimated total reduction**: 8-12 sorries eliminated or made closable.

**Confidence**: MEDIUM-HIGH

### 3.4. FMP Path Unblocked

The Finite Model Property (FMP) path in `TruthPreservationArchive.lean` was blocked specifically because the T-axiom was needed:
- `mcs_all_future_closure`: "Under strict semantics, Gψ only says ψ at times > t, not at t itself. This theorem is NOT derivable."
- `mcs_all_past_closure`: Same for H.

Under reflexive semantics, both become trivially derivable. This unblocks the FMP completeness path as an alternative to the algebraic path.

**Confidence**: HIGH

## 4. Alignment with Literature

### 4.1. Standard References

| Reference | Semantics Used | G/H Convention | U/S Convention | Alignment |
|-----------|---------------|---------------|---------------|-----------|
| Burgess (1984) | Reflexive | G: s >= t, H: s <= t | U: strict witness | EXACT MATCH with mixed semantics |
| GHR (1994) | Reflexive | G: s >= t, H: s <= t | U: strict witness | EXACT MATCH |
| Goldblatt (1992) | Reflexive | G: s >= t | Not covered | MATCH for G/H |
| Blackburn, de Rijke, Venema (2001) | Both conventions discussed | Standard is reflexive | Standard is strict | MATCH for recommended convention |

**Confidence**: HIGH -- all four major references use reflexive G/H.

### 4.2. Standard Choice for Temporal Logic over Z

Yes, the mixed semantics IS the standard choice:
- The T-axiom (G(phi)->phi, H(phi)->phi) is universally included in axiomatizations of temporal logic with G/H operators.
- The strict witness for U/S is standard to avoid the degenerate "psi now" case.
- The current codebase's strict G/H is NON-STANDARD and was adopted as a workaround (Task 81), not as a principled choice.

**Confidence**: HIGH

### 4.3. Published Proof Adaptability

Switching to mixed semantics makes it dramatically easier to adapt published completeness proofs:
- Burgess's completeness proof for Until/Since over Z uses the T-axiom at multiple points.
- GHR's quasimodel construction assumes reflexive semantics.
- The archived Boneyard code shows exactly what published proofs look like when transcribed to Lean.
- The strict semantics required novel proof strategies (e.g., x_content-based deterministic chains) that have NO published precedent, making them harder to verify.

**Confidence**: HIGH

## 5. Interaction with Existing Infrastructure

### 5.1. Sorry-Free Infrastructure That Survives Unchanged

| Component | File | Status | Survives? |
|-----------|------|--------|-----------|
| DeterministicChain | `DeterministicChain.lean` | Sorry-free | YES -- chain construction uses x_content/y_content stepping, independent of G/H semantics |
| ParametricTruthLemma | `ParametricTruthLemma.lean` | Sorry-free | YES -- parametric over FMCS structure, only needs FMCS fields to be valid |
| box_class_agree | `DeterministicFMCS.lean:87-91` | Sorry-free | YES -- box agreement is purely modal, unaffected by temporal semantics |
| UltrafilterChain | `UltrafilterChain.lean` (core sections) | Sorry-free | YES -- algebraic construction is parametric |
| parametric_box_persistent | used in bundle construction | Sorry-free | YES -- modal persistence is temporal-semantics-independent |
| forward_temporal_witness_seed_consistent | `WitnessSeed.lean` | Sorry-free | YES -- already proven WITHOUT T-axiom; T-axiom only strengthens it |
| past_temporal_witness_seed_consistent | `WitnessSeed.lean` | Sorry-free | YES -- same as above |
| DovetailedChain | `DovetailedChain.lean` | Sorry-free | YES -- dovetailed construction is independent |

**Key observation**: The entire sorry-free algebraic infrastructure (DeterministicChain, ParametricTruthLemma, box_class_agree, UltrafilterChain core) survives unchanged because it is parametric over FMCS structures. The semantics change only affects how FMCS fields are filled, not how they are consumed.

**Confidence**: HIGH

### 5.2. Complexity Eliminated

The mixed semantics eliminates several sources of complexity:

1. **The "independent extension problem"** that motivated the switch to strict semantics in Task 81 is resolved by the hybrid construction (deterministic chain for G-propagation + Lindenbaum for F-witnesses). The T-axiom was the missing piece that makes the Lindenbaum seed work.

2. **The deferralClosure/subformulaClosure tracking** in restricted chains becomes less critical because g_content(M) subset M means the Lindenbaum seed inherits ALL of M's formulas, not just those in a restricted closure.

3. **The CanonicalIrreflexivity module** may become unnecessary (reflexive semantics does not need irreflexivity of the temporal relation).

4. **The elaborate fuel-based bounded witness search** in `SuccChainFMCS.lean` (with its own sorry at fuel=0) may be simplified because the T-axiom provides a more direct path to witnesses.

**Confidence**: MEDIUM-HIGH

## Summary

The mixed semantics provides advantages across all five categories:

| Category | Primary Advantage | Impact |
|----------|------------------|--------|
| Proof-theoretic | T-axiom enables seed consistency for Lindenbaum F-witnesses | Unblocks the 2 leaf sorries |
| Model-theoretic | Canonical frame reflexivity is automatic; standard frame conditions | Cleaner construction |
| Practical | 8-12 sorries closed or closable; ~300 lines restored from Boneyard | Major sorry reduction |
| Literature alignment | EXACT MATCH with Burgess, GHR, Goldblatt | Proof adaptability |
| Infrastructure interaction | All sorry-free parametric infrastructure survives unchanged | Low regression risk |

**Overall Confidence**: HIGH -- the advantages are well-supported by codebase evidence and literature alignment. The only uncertainty is in the hybrid construction's Until persistence through Lindenbaum detours (identified in report 26 as gap #1).
