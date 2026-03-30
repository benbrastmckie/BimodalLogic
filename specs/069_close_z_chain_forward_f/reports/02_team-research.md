# Research Report: Overcoming the F-Persistence Gap in Z_chain_forward_F

**Task**: 69 - close_z_chain_forward_f
**Date**: 2026-03-30
**Mode**: Team Research (4 teammates)
**Session**: sess_1774895327_654c91

## Summary

The F-persistence gap is real and fundamental: the Lindenbaum extension seed `{witness} ∪ G_theory ∪ box_theory` does not include F-formulas, allowing G(neg phi) to enter the chain and destroy F(phi) obligations before they can be resolved. However, a principled solution exists: **F-preserving seeds** that include unresolved F-formulas directly in the extension seed. The consistency of this modified seed follows from a clean argument: G(neg phi) derivable from the seed would imply G(neg phi) in the original MCS, contradicting F(phi)'s presence.

## Root Cause Analysis (Teammate A)

### The Seed Gap

The `temporal_theory_witness_exists` theorem (line 1154) constructs chain extensions from the seed:

```
seed = {witness_formula} ∪ G_theory(M) ∪ box_theory(M)
```

| Component | Contents | F-relevant? |
|-----------|----------|-------------|
| `{phi}` | Selected witness formula | Only if phi is the F-target |
| `G_theory(M)` | `{G(a) \| G(a) ∈ M}` | Preserves G-formulas, but NOT F |
| `box_theory(M)` | `{Box(a)} ∪ {neg(Box(a))}` | Modal only |

**Critical**: F-formulas are intentionally excluded. Since F(phi) = neg(G(neg phi)), nothing in the seed prevents G(neg phi) from being added by Lindenbaum. This is the root cause.

### Why G(neg phi) Can Enter

1. F(phi) ∈ chain(n) implies G(neg phi) ∉ chain(n) (MCS negation completeness)
2. But G(neg phi) ∉ G_theory(chain(n)) — it's not a G-formula FROM chain(n)
3. G(neg phi) ∉ box_theory(chain(n)) — it's not a box-formula
4. So G(neg phi) is NOT excluded by the seed
5. If consistent with seed, Lindenbaum CAN add G(neg phi)
6. Once G(neg phi) ∈ chain(n+1), F(phi) ∉ chain(n+1) — obligation destroyed

### G-Theory Preservation Is Insufficient

The `OmegaForwardInvariant` (line 2012) preserves G-formulas FROM M0, but says nothing about:
- G-formulas NOT in M0 (new ones can be added)
- F-formulas (no preservation mechanism at all)

**Confidence**: HIGH — Direct code analysis confirms the gap is structural.

## Strategies Evaluated

### Strategy 1: F-Preserving Seeds (RECOMMENDED)

**Source**: Teammates B and C converge on this approach from different angles.

**Approach**: Modify the extension seed to include unresolved F-formulas:

```
f_preserving_seed(M, phi) = {phi} ∪ G_theory(M) ∪ box_theory(M) ∪ F_unresolved(M)
```

where `F_unresolved(M) = {F(psi) | F(psi) ∈ M ∧ psi ∉ M}`.

**Consistency Proof Sketch**:

The key question: Is `f_preserving_seed(M, phi)` consistent?

1. The original seed `{phi} ∪ G_theory(M) ∪ box_theory(M)` is consistent (proven: `temporal_theory_witness_consistent`)
2. Adding F(psi) = neg(G(neg psi)) is safe IF G(neg psi) is not derivable from the original seed
3. If G(neg psi) were derivable from `G_theory(M) ∪ box_theory(M)`, then by the G-lift argument, G(neg psi) ∈ M
4. But F(psi) ∈ M means neg(G(neg psi)) ∈ M, contradicting step 3 (MCS consistency)
5. Therefore G(neg psi) is NOT derivable from the seed, so adding F(psi) is consistent

**Existing Infrastructure**: The theorem `some_future_excludes_all_future_neg` (lines 1083-1098) already proves F(phi) and G(neg phi) cannot coexist in an MCS. This is the foundation.

**Invariant Gained**: F(psi) ∈ chain(n) ∧ psi ∉ chain(n) → F(psi) ∈ chain(n+1) — F-persistence by construction.

**Implementation Path**:

1. Define `F_unresolved_theory(M)` — set of unresolved F-formulas in M
2. Define `f_preserving_seed(M, phi)` — extended seed with F-unresolved
3. Prove `f_preserving_seed_consistent` — modified seed is consistent
4. Modify `temporal_theory_witness_exists` (or create variant `temporal_theory_witness_F_preserving`) to use f_preserving_seed
5. Prove `F_persistence_invariant` — F(psi) persists until resolved
6. Close `omega_true_dovetailed_forward_F_resolution` — combine persistence with dovetailed scheduling
7. Close `Z_chain_forward_F` — wire resolution to Z_chain

**Feasibility**: MEDIUM-HIGH

**Key Risk**: The consistency proof at step 3 uses the G-lift argument. Need to verify this argument extends to the augmented seed. Teammate B notes F lacks G's 4-axiom property, but the argument here is about derivability FROM the seed, not about F-formulas themselves. The G-lift argument says: if G(a) is derivable from G_theory(M) ∪ box_theory(M), then G(a) ∈ M. This should still hold regardless of whether F-formulas are also in the seed.

### Strategy 2: Excluding Lindenbaum (variant of Strategy 1)

**Source**: Teammate B

Instead of adding F-formulas to the seed, modify Lindenbaum to EXCLUDE G(neg psi) for all F(psi) in M:

```lean
theorem set_lindenbaum_avoiding (S : Set Formula) (h_cons : SetConsistent S)
    (avoid : Set Formula)
    (h_avoid : ∀ f ∈ avoid, ¬SetConsistent (S ∪ {f})) :
    ∃ W, SetMaximalConsistent W ∧ S ⊆ W ∧ ∀ f ∈ avoid, f ∉ W
```

**Relationship to Strategy 1**: Mathematically equivalent. Adding F(psi) to the seed forces neg(G(neg psi)) = F(psi) into any MCS extension, automatically excluding G(neg psi). The choice is implementation convenience:

| Aspect | F-preserving seed | Excluding Lindenbaum |
|--------|------------------|---------------------|
| Proof complexity | One new consistency proof | New Lindenbaum variant |
| Code changes | Modify seed only | Modify Lindenbaum infrastructure |
| Reusability | Specific to temporal | Generic exclusion tool |
| Integration | Modifies existing theorem | New theorem + wrapper |

**Recommendation**: F-preserving seed (Strategy 1) is simpler because it reuses the existing Lindenbaum unchanged. The exclusion approach requires building new Lindenbaum infrastructure.

### Strategy 3: Bundle-Level Truth Lemma Redesign

**Source**: Teammate D (recommended for investigation)

**Approach**: Since `boxClassFamilies_bundle_forward_F` already proves F-resolution at bundle level, redesign the truth lemma to use bundle-level witnesses.

**Critical Obstacle** (identified by Teammate D): The truth lemma's backward G case requires:
```
1. G(phi) ∉ fam.mcs t
2. F(neg phi) ∈ fam.mcs t             [temporal duality]
3. ∃ s > t, neg(phi) ∈ fam.mcs s     [forward_F — SAME FAMILY required]
4. phi ∈ fam.mcs s                    [by hypothesis h_all]
5. Contradiction
```
Step 3 needs the witness in the SAME family because step 4 uses a hypothesis quantified over that specific family. A bundle-level witness would be in `fam'`, and we cannot apply the family-specific hypothesis there.

**Verdict**: Requires rethinking the entire semantic evaluation structure. Major architectural change with HIGH risk. Not recommended as primary approach.

### Strategy 4: Ultrafilter-Based Construction

**Source**: Teammates C and D mention this as long-term option

**Approach**: Use ultrafilters of the Lindenbaum algebra instead of MCS-based Lindenbaum. Ultrafilters have automatic negation completeness, eliminating the "Lindenbaum can add G(neg phi)" problem entirely.

**Current state**: `R_G` and `R_Box` relations on ultrafilters already exist (UltrafilterChain.lean lines 59-68). However, connecting ultrafilter chains to the MCS-based FMCS requires additional machinery.

**Verdict**: Theoretically cleanest but requires substantial new infrastructure. Better suited as a long-term refactoring.

### Strategy 5: Two-Phase Extension (Temporal then Modal)

**Source**: Teammate B

Pre-saturate with temporal closure before Lindenbaum.

**Fatal Flaw**: Requires F(a) → F(F(a)) axiom, which does NOT exist in TM logic. We have G(a) → G(G(a)) (temp_4) but NOT the dual for F.

**Verdict**: INFEASIBLE — missing required axiom.

## Synthesis

### Conflicts Resolved

1. **B's Strategy A vs C's F-preserving seed**: Teammate B rated "Add F to seed" as LOW feasibility because "the consistency proof relies on the G-lift argument which does NOT extend to F-formulas." Teammate C's consistency argument DOES work because it shows G(neg psi) is NOT derivable from the seed (using G-lift in the contrapositive), not that F-formulas themselves satisfy G-lift. **Resolution**: C's argument is correct. The G-lift is used to show G(neg psi) would have to be in M, contradicting F(psi) ∈ M. F-formulas don't need the 4-axiom property for this.

2. **D's "Add F to seed: 40%" vs C's "MEDIUM confidence"**: D's lower confidence comes from concern about invariant breakage. C's consistency sketch is more detailed and convincing. **Resolution**: The approach is sound but requires careful invariant verification. Estimate: 60-70% success probability.

3. **Fix family-level vs accept bundle-level**: D recommends investigating bundle-level first. A/B/C focus on fixing family-level. **Resolution**: Family-level fix via F-preserving seeds is the correct first attempt because (a) it's lower-effort than truth lemma redesign, and (b) it maintains the existing architecture. Bundle-level is the fallback if F-preserving seeds fail.

### Gaps Identified

1. **G-lift argument extension**: Need to formally verify that the G-lift argument works with the augmented seed (including F-unresolved formulas). This is the key proof obligation.

2. **Nested F-formulas**: If F(F(psi)) is in M, the seed includes F(F(psi)). After extension, the new MCS might have F(psi) but not psi. The process must handle multi-level F-nesting. The dovetailed enumeration handles this naturally (each F-formula gets its own resolution step).

3. **Backward direction**: The backward chain (P-formulas) has the symmetric issue. The same F-preserving seed approach applies symmetrically with P and H replacing F and G.

4. **Downstream invariant changes**: The modified `temporal_theory_witness_exists` (or its variant) needs to be wired into the chain construction. Existing theorems that reference the old construction need updating.

## Recommendations

### Primary Path: F-Preserving Seeds

**Implementation order**:

1. **Prove consistency of F-preserving seed** — this is the critical lemma
   - Key: Show G(neg psi) is not derivable from `{phi} ∪ G_theory(M) ∪ box_theory(M)` when F(psi) ∈ M
   - Use: `some_future_excludes_all_future_neg` + G-lift argument

2. **Create `temporal_theory_witness_F_preserving`** — variant that preserves F-obligations
   - Extends seed with F_unresolved(M)
   - Returns MCS W with F-persistence guarantee

3. **Prove F-persistence lemma** — structural invariant
   - F(psi) ∈ chain(n) ∧ psi ∉ chain(n) → F(psi) ∈ chain(n+1)
   - Follows directly from seed inclusion

4. **Prove F-resolution theorem** — combine persistence + dovetailing
   - F(psi) ∈ chain(t) → ∃ s > t, psi ∈ chain(s)
   - At step n0 = Nat.pair t (encode psi), F(psi) still present (persistence)
   - At step n0, psi selected for resolution → psi ∈ chain(n0+1)

5. **Wire to Z_chain_forward_F** — close the gap

### Fallback: Bundle-Level Coherence

If F-preserving seeds fail (consistency proof doesn't work), fall back to:
- Accept bundle-level temporal coherence as sufficient
- Modify truth lemma to use bundle witnesses (major refactor)
- Document the family-level limitation

### Investigation Priority

Before implementation, verify one key claim:

> Can we show that `{phi} ∪ G_theory(M) ∪ box_theory(M) ∪ {F(psi) | F(psi) ∈ M, psi ∉ M}` is consistent?

If YES → proceed with F-preserving seeds
If NO → fall back to bundle-level or investigate ultrafilter approach

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Root cause | completed | HIGH | Gap is structural: F excluded from seed |
| B | Saturation strategies | completed | MEDIUM-HIGH | Recommends excluding Lindenbaum (Strategy B) |
| C | FMCS-wide extension | completed | MEDIUM | F-preserving seeds with consistency proof sketch |
| D | Devil's advocate | completed | MEDIUM-HIGH | Family-level may not be needed; bundle-level works |

## References

### Codebase
- `UltrafilterChain.lean:1154` — `temporal_theory_witness_exists` (extension seed)
- `UltrafilterChain.lean:1083` — `some_future_excludes_all_future_neg` (F/G exclusion)
- `UltrafilterChain.lean:2012` — `OmegaForwardInvariant` (chain invariant)
- `UltrafilterChain.lean:2651` — `boxClassFamilies_bundle_forward_F` (bundle-level)
- `MaximalConsistent.lean:291` — `set_lindenbaum` (Lindenbaum extension)

### Literature
- Completeness by construction for tense logics of linear time (Verbrugge)
- Canonical models for normal logics (Imperial College notes)
- Temporal Logic overview (Stanford Encyclopedia of Philosophy)
- Lindenbaum's Lemma (Open Logic Project)
