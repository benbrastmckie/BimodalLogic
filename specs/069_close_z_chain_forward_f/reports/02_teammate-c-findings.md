# Research Report: FMCS-Wide Lindenbaum Extension

## Task Context

Task 69 is blocked on proving `Z_chain_forward_F` - the temporal coherence property that F(phi) at time t implies phi at some s > t. The fundamental gap is that the current per-step Lindenbaum extension can add G(neg phi) even when F(phi) was present in an earlier chain step, causing F(phi) to vanish before resolution.

## Research Focus

Investigating coordinated Lindenbaum extension across the entire FMCS structure, as suggested: "consider a method of Lindenbaum extension which extends to the whole FMCS, working through all of its MCSs systematically so that all are covered."

## Current FMCS Structure Analysis

### Structure Overview

```
FMCS D:
  - mcs : D -> Set Formula       (time-indexed MCS assignment)
  - is_mcs : forall t, SetMaximalConsistent (mcs t)
  - forward_G : G(phi) at t implies phi at all t' >= t
  - backward_H : H(phi) at t implies phi at all t' <= t

BFMCS (Bundle of FMCS):
  - families : Set (FMCS D)      (collection of time-indexed families)
  - nonempty : families.Nonempty
  - modal_forward : Box(phi) in any family implies phi in ALL families at same time
  - modal_backward : phi in ALL families implies Box(phi) in any family
  - eval_family : distinguished evaluation family
```

### Box Class Structure

The `boxClassFamilies` construction groups MCSs by their Box-content:

```lean
def boxClassFamilies (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    Set (FMCS Int) :=
  { shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k |
    W : Set Formula, h_W : SetMaximalConsistent W, k : Int,
    box_class_agree M0 W }
```

Key properties (already proven without sorry):
- `boxClassFamilies_modal_forward` - Box coherence across families
- `boxClassFamilies_modal_backward` - Box coherence reverse direction
- `boxClassFamilies_bundle_forward_F` - Bundle-level F-resolution
- `boxClassFamilies_bundle_backward_P` - Bundle-level P-resolution

### The Bundle-Level vs Family-Level Gap

**Bundle-level temporal coherence** (proven):
- F(phi) at t in family fam implies phi at s > t in SOME family fam'
- Uses `temporal_theory_witness_exists` to get witness MCS W with phi in W
- Builds new shifted chain from W at offset t+1
- New chain is in boxClassFamilies by box_class_agree transitivity

**Family-level temporal coherence** (blocked):
- F(phi) at t in family fam implies phi at s > t in THE SAME family fam
- Requires F(phi) to persist in the chain until resolved
- Blocked because Lindenbaum can add G(neg phi) at step n+1 even when F(phi) was at step n

## Coordinated Extension Approach Analysis

### Proposed Approach

"Extend to the whole FMCS, working through all of its MCSs systematically."

This suggests building all MCSs in the bundle simultaneously, ensuring cross-chain constraints are respected during extension.

### Feasibility Analysis

#### Challenge 1: Cardinality

The `boxClassFamilies` set has uncountable cardinality (one family per MCS in the box class, shifted by any integer). Standard Lindenbaum extension works over countable formula sets via enumeration.

**Assessment**: A coordinated extension would need to handle the infinite structure. This could use:
- Ordinal-indexed transfinite induction (non-constructive)
- Filter/ultrafilter completion methods (algebraic)

#### Challenge 2: Constraint Propagation

If F(phi) is added to MCS M at time t, we want to ensure G(neg phi) is NOT added to any accessible MCS at times s >= t. This requires:

1. **Global F-registry**: Track all F(phi) obligations across all families
2. **G-exclusion constraint**: When extending any MCS M' accessible from M, exclude G(neg phi) from consideration
3. **Consistency preservation**: Ensure the exclusion doesn't create inconsistencies

**Assessment**: This is complex because:
- Accessibility between families is universal in the box class
- Adding a constraint at one family propagates to ALL families at that time point
- The constraint set could become inconsistent if conflicting F-obligations exist

#### Challenge 3: Fixed-Point Existence

A coordinated construction would define:
```
ExtendAll(Families) = { Extend(fam, constraints_from(Families - {fam})) | fam in Families }
```

This is a fixed-point equation. Existence requires:
- Monotonicity (extending one family doesn't break others)
- Boundedness (the process terminates)

**Assessment**: Standard fixed-point theorems (Knaster-Tarski, Kleene) could apply, but:
- The domain (sets of MCSs) is a complete lattice
- Monotonicity is not obvious - adding a formula to one MCS could require adding contradictory formulas to another

### Alternative: Ultrafilter-Based Approach

The Jonsson-Tarski approach uses ultrafilters instead of MCS enumeration:

```lean
def R_G (U V : Ultrafilter LindenbaumAlg) : Prop :=
  forall a, STSA.G a in U -> a in V
```

Ultrafilters have automatic negation completeness (for any a, either a or a^c is in the ultrafilter). This eliminates the "Lindenbaum can add G(neg phi)" problem because:
- Ultrafilters are maximal by construction
- No extension step is needed
- The filter structure determines membership globally

**Feasibility**: The codebase already has `R_G` and `R_Box` relations on ultrafilters (UltrafilterChain.lean lines 59-68). However, connecting ultrafilter chains to the MCS-based FMCS requires additional machinery not yet implemented.

## Coordinated Extension Proposal

### Approach: Simultaneous Extension with F-Constraints

**Idea**: Instead of extending each chain step independently, extend all MCSs at a given time point simultaneously, respecting F-obligations.

**Construction**:

1. **Base layer**: Start with seed MCSs (M0 at time 0 for each family)

2. **Forward extension** (time t -> t+1):
   - Collect all F(phi) obligations from all families at time t
   - For each family, compute the extension seed:
     ```
     seed(fam) = {psi | psi selected for resolution}
               ∪ G_theory(fam.mcs(t))
               ∪ box_theory(fam.mcs(t))
               ∪ {neg(G(neg phi)) | F(phi) in fam.mcs(t)}  -- F-preservation
     ```
   - The key addition: include neg(G(neg phi)) = F(phi) in the seed when F(phi) is present
   - Extend all seeds to MCSs simultaneously

3. **F-preservation invariant**:
   - If F(phi) in fam.mcs(t) and phi not in fam.mcs(t), then F(phi) in fam.mcs(t+1)
   - This holds because F(phi) = neg(G(neg phi)) is in the seed

4. **Resolution**: Eventually, the dovetailed scheduling ensures phi is selected and placed in the extension seed, resolving F(phi)

**Critical Question**: Is the modified seed consistent?

**Proof Sketch**:
- The original seed `{psi} ∪ G_theory ∪ box_theory` is consistent (proven in `temporal_theory_witness_consistent`)
- Adding F(phi) = neg(G(neg phi)) when F(phi) was already present is consistent IF G(neg phi) is not derivable from the seed
- G(neg phi) derivable from seed would mean: G_theory ∪ box_theory ⊢ G(neg phi)
- By G-lifting: this would mean G(neg phi) in the original MCS
- But F(phi) = neg(G(neg phi)) in original MCS contradicts this

**Conclusion**: The modified seed IS consistent when F(phi) is in the original MCS.

### Implementation Sketch

```lean
/-- Extended seed that preserves F-formulas -/
def f_preserving_seed (M : Set Formula) (selected_phi : Formula) : Set Formula :=
  {selected_phi} ∪ G_theory M ∪ box_theory M ∪
  { Formula.some_future psi | F(psi) ∈ M ∧ psi ∉ M }

/-- Build forward chain step preserving F-formulas -/
noncomputable def omega_chain_f_preserving (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat -> Set Formula
  | 0 => M0
  | n + 1 =>
    let M_n := omega_chain_f_preserving M0 h_mcs0 n
    let selected := selectFormulaToResolve M_n n
    set_lindenbaum (f_preserving_seed M_n selected) (f_preserving_seed_consistent ...)
```

## Trade-offs vs Current Approach

| Aspect | Current (per-step) | Proposed (F-preserving) |
|--------|-------------------|------------------------|
| Complexity | Simpler seed | Larger seed with F-formulas |
| F-persistence | NOT guaranteed | Guaranteed by construction |
| Consistency proof | Already proven | Needs new proof |
| G-theory propagation | Proven | Same structure applies |
| Box-class agreement | Proven | Same structure applies |

### Key Advantage

The F-preserving approach provides a **structural invariant**: once F(phi) enters the chain, it persists until phi enters. This is exactly what the current approach lacks.

### Key Risk

The F-preserving seed is larger (potentially infinite if many F-formulas accumulate). However:
- Only unresolved F-formulas are added
- Dovetailing ensures each F-formula is eventually resolved
- The seed remains a subset of the formula language

## Recommendations

### Short-term (Task 69 completion):

**Option A: Use bundle-level coherence**
- Already proven: `boxClassFamilies_bundle_forward_F`
- Requires modifying truth lemma to use bundle witnesses
- Lower risk, but changes semantics slightly

**Option B: Implement F-preserving seeds**
- Modify `temporal_theory_witness_consistent` to include F-preservation
- Prove the modified seed is consistent
- Update chain construction to use F-preserving seeds
- Higher effort, but maintains family-level semantics

### Long-term (Algebraic Completeness):

Consider the ultrafilter approach more fully:
- Build FMCS from ultrafilter chains
- Use existing R_G/R_Box relations
- Automatic negation completeness eliminates extension gaps
- Aligns with Jonsson-Tarski literature

## Confidence Assessment

| Finding | Confidence |
|---------|------------|
| Bundle-level coherence works | HIGH (proven in codebase) |
| F-preserving seed is consistent | MEDIUM (sketch proof, not formalized) |
| Coordinated extension is feasible | MEDIUM (theoretically sound, implementation complex) |
| Ultrafilter approach is cleaner | HIGH (standard in literature) |

## Summary

The FMCS-wide coordinated extension is feasible via F-preserving seeds that maintain the invariant "F(phi) persists until resolved." The key insight is adding neg(G(neg phi)) = F(phi) to extension seeds when F(phi) is present and unresolved. This is consistent because G(neg phi) cannot be derived from an MCS containing F(phi).

For immediate progress on Task 69, Option A (bundle-level coherence) is lower risk. For principled resolution, Option B (F-preserving seeds) or the ultrafilter approach provides structural guarantees.

## Sources

- [Completeness by construction for tense logics of linear time](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Canonical models for normal logics](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf)
- [Open Logic Project: Completeness and Canonical Models](https://builds.openlogicproject.org/content/normal-modal-logic/completeness/completeness.pdf)
- [Temporal Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/)
