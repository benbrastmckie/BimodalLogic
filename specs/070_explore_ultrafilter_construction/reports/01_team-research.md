# Research Report: Task #70

**Task**: 70 - Explore ultrafilter-based construction for temporal coherence
**Date**: 2026-03-30
**Mode**: Team Research (2 teammates)
**Session**: sess_1774911392_685e3c
**Focus**: Study task semantics to ensure construction aligns with official TaskFrame semantics

---

## Summary

The ultrafilter-based construction is **theoretically sound** for satisfying the official TaskFrame semantics, but **practically blocked** by incomplete ultrafilter↔MCS bijection infrastructure. All three TaskFrame axioms (nullity_identity, forward_comp, converse) can be satisfied by defining `task_rel` via n-step R_G chain reachability over `D = Int`. The key advantage — automatic negation completeness eliminating the F-persistence problem — is real but requires a filter extension argument (Zorn's Lemma) as the crux proof obligation. Meanwhile, bundle-level temporal coherence is already sorry-free; the actual blocker for completeness is the truth lemma requiring family-level witnesses, which could alternatively be solved by modifying `ParametricTruthLemma.lean`.

---

## Key Findings

### 1. TaskFrame Axiom Satisfaction (Teammate A, HIGH confidence)

The official TaskFrame (TaskFrame.lean:93-122) requires three axioms. An ultrafilter construction satisfies all three:

| Axiom | Definition | Ultrafilter Satisfaction |
|-------|-----------|------------------------|
| `nullity_identity` | `task_rel w 0 u ↔ w = u` | 0-step R_G reachability = identity (trivial) |
| `forward_comp` | Sequential tasks compose (non-negative) | n-step + m-step R_G = (n+m)-step (chain concatenation) |
| `converse` | `task_rel w d u ↔ task_rel u (-d) w` | Backward R_H chains = negated forward R_G chains |

**Time domain**: `D = Int` is the correct choice. R_G is a discrete one-step relation; dense time (Rat) would require a fundamentally different construction. This matches the existing CanonicalTask/SuccChainFMCS infrastructure.

**Critical observation**: The `converse` axiom requires defining backward accessibility (R_H). The current codebase has no explicit R_H for ultrafilters, but it can be defined as the R_G converse following the same pattern as SuccChainFMCS.

### 2. Existing Infrastructure Inventory (Teammate B, HIGH confidence)

**Already implemented** (UltrafilterChain.lean):
- `R_G` (line 59): Temporal accessibility `∀ a, G(a) ∈ U → a ∈ V`
- `R_Box` (line 67): Modal accessibility `∀ a, □a ∈ U → a ∈ V`
- `R_G_refl` (line 80): Reflexivity via `temp_t_future`
- `R_G_trans` (line 100): Transitivity via `temp_4`
- `R_Box_refl` (line 125): Reflexivity via `box_deflationary`
- `R_Box_euclidean` (line 144): S5 collapse via `box_s5`
- `R_Box_symm`, `R_Box_trans`: Derived from Euclidean + reflexive

**NOT implemented** (despite module name):
- `UltrafilterChain` structure — never defined as a Lean type
- Int-indexed ultrafilter chain with R_G connectivity
- Connection from ultrafilter chains to FMCS

**Critical blocker**: `UltrafilterMCS.lean` contains sorries in the ultrafilter↔MCS bijection (`ultrafilter_to_mcs`, `mcs_to_ultrafilter`). Without this bijection, ultrafilter chains cannot produce FMCS structures.

### 3. Negation Completeness Advantage (Both teammates, HIGH confidence)

Ultrafilters eliminate the F-persistence problem that killed the chain-level approach:

**MCS approach failure** (from task 69): The seed `{phi} ∪ G_theory(M) ∪ F_unresolved_theory(M)` is inconsistent because Lindenbaum extension can add `G(neg phi)`, creating contradictions with F-formulas.

**Ultrafilter approach**: No seed extension needed. For any formula phi, exactly one of phi or phi^c is in the ultrafilter. Given `F(phi) ∈ U`, the successor ultrafilter V (with R_G(U,V)) automatically satisfies or refutes phi — no consistency gap.

**Remaining proof obligation**: Given `F(phi) ∈ U`, prove there EXISTS an ultrafilter V with `R_G(U,V)` and `phi ∈ V`. This requires a filter extension argument (Zorn's Lemma / ultrafilter existence theorem) and is the crux of the ultrafilter construction.

### 4. The Actual Completeness Gap (Teammate B, HIGH confidence)

The blocker is NOT about ultrafilter chains per se. It's about family-level vs bundle-level temporal coherence:

```
Bundle-level (PROVEN):     F(φ) ∈ fam.mcs(t) → ∃ fam' ∈ bundle, ∃ s > t, φ ∈ fam'.mcs(s)
Family-level (SORRY):      F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s)  [SAME family]
Truth lemma REQUIRES:      Family-level (evaluates within a single family)
```

The sorry chain: `bfmcs_from_mcs_temporally_coherent` → `boxClassFamilies_temporally_coherent` → `Z_chain_forward_F'` (all built on the proven-false `f_preserving_seed_consistent`).

---

## Synthesis

### Conflicts Resolved

**Conflict 1: Is ultrafilter approach needed?**
- Teammate A: "May simplify modal coherence since ultrafilter worlds are automatically modally saturated"
- Teammate B: "Bundle-level is already proven; lower-risk alternative is modifying ParametricTruthLemma"
- **Resolution**: Both paths are valid. The ultrafilter approach offers architectural elegance but requires completing UltrafilterMCS bijection first. The truth lemma modification is lower risk. **Recommendation: pursue both in parallel** — ultrafilter approach as the exploratory task 70 goal, truth lemma modification as the critical-path item (tasks 71/72).

**Conflict 2: Converse axiom feasibility**
- Teammate A: "Achievable by defining backward R_H = R_G converse" (medium confidence)
- Teammate B: Does not address directly
- **Resolution**: The converse axiom needs R_H defined for ultrafilters. Since R_G is defined algebraically via `G(a) ∈ U → a ∈ V`, the backward relation R_H should be `H(a) ∈ U → a ∈ V` where H is the past operator. The STSA already has H (past dual of G). This is straightforward to define but needs proof that R_H = R_G^(-1).

### Gaps Identified

1. **UltrafilterMCS bijection** (blocking): The ultrafilter↔MCS correspondence has sorries. Must be completed before ultrafilter chains can produce FMCS.

2. **R_H relation** (missing): No backward temporal accessibility relation for ultrafilters. Needed for the `converse` TaskFrame axiom.

3. **Filter extension for temporal coherence** (the crux): Given `F(φ) ∈ U`, construct ultrafilter V with R_G(U,V) and φ ∈ V. Requires Zorn's Lemma argument.

4. **UltrafilterChain structure** (missing): The Int-indexed chain type was never implemented.

### Recommendations

**For task 70 scope** (exploration):

1. **Phase 1: Fix UltrafilterMCS bijection** — Close sorries in `ultrafilter_to_mcs` and `mcs_to_ultrafilter`. This is prerequisite for everything else.

2. **Phase 2: Define UltrafilterChain structure** — `chain : Int → Ultrafilter LindenbaumAlg` with `∀ t, R_G (chain t) (chain (t+1))`. Define R_H for backward direction.

3. **Phase 3: Ultrafilter temporal coherence** — Prove: given `F(φ) ∈ U`, exists V with R_G(U,V) and φ ∈ V. This is the filter extension argument.

4. **Phase 4: Convert to FMCS** — Use ultrafilter↔MCS bijection to produce FMCS from ultrafilter chains, wire to ParametricTruthLemma.

**For critical path** (tasks 71/72, parallel):
- Modify ParametricTruthLemma to accept bundle-level witnesses. This is the lower-risk path to sorry-free completeness.

**Effort estimate**: 12-20 hours total (matching task description), with Phase 1 being the key risk factor.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Task semantics alignment | completed | high |
| B | Existing infrastructure analysis | completed | high |

**Points of agreement** (both teammates):
1. TaskFrame axioms satisfiable via ultrafilter R_G chains over Int ✓
2. UltrafilterChain structure not yet implemented ✓
3. UltrafilterMCS bijection sorries are the practical blocker ✓
4. Negation completeness eliminates F-persistence problem ✓
5. Bundle-level approach is the lower-risk alternative ✓

---

## References

### Source Files
- `Theories/Bimodal/Semantics/TaskFrame.lean` — Official task semantics (lines 93-122)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` — R_G, R_Box relations (lines 59-68)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` — Ultrafilter↔MCS bijection (sorries)
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` — BFMCS structure
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — Temporal coherence definitions

### Prior Research
- `specs/069_close_z_chain_forward_f/reports/17_team-research.md` — F-persistence counterexample
- `specs/069_close_z_chain_forward_f/reports/02_team-research.md` — Strategy 4 (ultrafilter)
- `specs/069_close_z_chain_forward_f/reports/18_spawn-analysis.md` — Spawn analysis
