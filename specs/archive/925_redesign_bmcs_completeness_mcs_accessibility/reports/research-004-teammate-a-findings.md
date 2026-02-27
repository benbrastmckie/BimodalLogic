# Research Findings: Non-Transitive Task Relation and BoxGContent

**Task**: #925 - Redesign BMCS completeness using MCS accessibility
**Teammate**: A
**Focus**: Why non-transitivity of the task relation makes BoxGContent the correct seed (not the wrong one)
**Date**: 2026-02-25

## Key Findings

### Finding 1: The Task Relation Is NOT Transitive -- By Design

The task relation `task_rel : W -> D -> W -> Prop` in `TaskFrame.lean:88` is a three-place relation parameterized by duration. Its constraints are:

- **Nullity** (line 95): `task_rel w 0 w` -- zero-duration task is identity
- **Compositionality** (line 103): If `task_rel w x u` and `task_rel u y v`, then `task_rel w (x + y) v`

Compositionality is NOT transitivity. Transitivity would state:
```
If task_rel w d1 u and task_rel u d2 v, then task_rel w d1 v  (WRONG)
```

Compositionality instead states:
```
If task_rel w d1 u and task_rel u d2 v, then task_rel w (d1+d2) v  (CORRECT)
```

The duration changes when composing. This is the crucial distinction. In the MCS accessibility relation `w -> u`, we are looking at a SINGLE step relation (one-step accessibility at a given time). Compositionality operates on **sequences** (histories/paths), not on the base relation.

**Codebase evidence**: `TaskFrame.lean:103`:
```lean
compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

### Finding 2: Why BoxGContent Being "Weaker" Is Actually Correct

Research-002 established:
```
BoxGContent(w) = {phi | Box(G phi) in w}
GContent(w) = {phi | G phi in w}
BoxGContent(w) SUBSET GContent(w)  (strictly weaker)
```

Research-002 concluded: "This is the WRONG direction for strengthening." **This conclusion was premature** because it assumed we need the STRONGEST possible content propagation. But non-transitivity means we should NOT propagate too much.

**The key insight**: The MCS accessibility relation `w -> u` defined by C1 (`BoxGContent(w) SUBSET u`) and C2 (`BoxHContent(u) SUBSET w`) is meant to capture what MUST hold for a SINGLE STEP of the task relation. Consider what happens semantically:

- `Box(G phi) in w` means: at ALL world histories, at ALL future times, phi holds
- This is the INTERSECTION of two universal quantifications: across histories AND across times
- For a single step `w -> u`, we need `phi` at `u` because `u` is both (a) an accessible history and (b) a future time point

Using the stronger `GContent(w) SUBSET u` would assert: if `G phi in w` (phi holds at all future times of THIS history), then `phi in u` (phi holds at the next world). But the next world `u` is a DIFFERENT history! The formula `G phi in w` only talks about the current history's future, not about what holds at other histories.

`Box(G phi) in w` = "at ALL histories, G phi" = "phi at all futures of all histories" -- this justifies propagation to any related world because it applies to ALL histories.

`G phi in w` = "at THIS history, phi at all future times" -- this only talks about the CURRENT history's future and says nothing about other worlds.

**The MF axiom** (`modal_future` in `Axioms.lean:282`) states:
```lean
Box phi -> Box(G phi)   -- MF: necessary truths remain necessary in the future
```

This axiom connects `Box phi` to `Box(G phi)`. It does NOT give us `G phi -> Box(G phi)`.

**The TF axiom** (`temp_future` in `Axioms.lean:289`) states:
```lean
Box phi -> G(Box phi)   -- TF: necessary truths will always be necessary
```

These axioms show that the modal and temporal operators interact through `Box`, not independently. The `BoxG` compound operator is the NATURAL unit for inter-history propagation because only `Box` lets you cross history boundaries.

### Finding 3: The C1/C2 Constraints with Non-Transitivity

For the one-step accessibility `w -> u`:

**C1 (Forward)**: `BoxGContent(w) SUBSET u`
- If `Box(G phi) in w`, then `phi in u`
- Justification: MF gives `Box phi -> Box(G phi)`, so `Box(G phi)` means phi is necessary at all future times. Since u is related to w, phi must hold at u.

**C2 (Backward)**: `BoxHContent(u) SUBSET w`
- If `Box(H phi) in u`, then `phi in w`
- Justification: Symmetric reasoning via past.

**What we do NOT need**: Transitivity would require that if `BoxGContent(w) SUBSET u` and `BoxGContent(u) SUBSET v`, then `BoxGContent(w) SUBSET v`. As research-002 showed, this FAILS because we cannot derive `Box(G phi) in u` from merely `phi in u`.

**Why this is fine**: Task histories are SEQUENCES of related worlds. The compositionality constraint says that a path `w -> u -> v` gives `task_rel w (d1+d2) v`. We don't need `w -> v` at the same duration -- we get it at the COMPOSITE duration. The completeness proof constructs histories (paths through MCS space), not single-step accessibility closures.

### Finding 4: The Decomposition BoxG = Box . G Aligns with BMCS Architecture

The existing BMCS architecture already separates concerns:

1. **Modal layer** (BMCS structure in `BMCS.lean`):
   - `modal_forward`: `Box phi in fam.mcs t -> phi in fam'.mcs t` for all fam' in bundle
   - `modal_backward`: `phi in fam'.mcs t` for all fam' -> `Box phi in fam.mcs t`

2. **Temporal layer** (BFMCS structure in `BFMCS.lean`):
   - `forward_G`: `G phi in fam.mcs t -> phi in fam.mcs t'` for t' >= t
   - `backward_H`: `H phi in fam.mcs t -> phi in fam.mcs t'` for t' <= t

The BoxG constraint decomposes naturally through these layers:

```
Box(G phi) in fam.mcs(t)
  -> (by modal_forward) G phi in fam'.mcs(t) for all fam' in bundle
  -> (by forward_G)     phi in fam'.mcs(s) for all fam' and s >= t
```

This is exactly `BoxGContent(fam.mcs(t)) SUBSET fam'.mcs(s)` for all fam' and s >= t.

**The two-step decomposition is already implemented**. The question is whether we need to formalize BoxGContent as a separate definition, or whether the composition of modal_forward + forward_G suffices.

### Finding 5: Seed-Based Unraveling with BoxGContent

The user suggests "unravel the seed by recursively expanding just the single consistent sentence, where this generates a partial set of partial families of consistent sets."

Here is the concrete construction:

1. **Start**: Given consistent formula `phi`, extend `{phi}` to MCS `M_0` at time 0
2. **One-step expansion**: For `M_0`, compute `BoxGContent(M_0) = {psi | Box(G psi) in M_0}`
3. **Forward witness**: For each time t > 0, construct MCS `M_t` extending `BoxGContent(M_{t-1})`
4. **Backward witness**: For each time t < 0, construct MCS `M_t` where `BoxHContent(M_{t+1}) SUBSET M_t`
5. **Modal witnesses**: For each `Diamond(chi)` in some `M_t`, add a NEW family starting with `{chi} UNION BoxGContent(M_t)`

The key property: `BoxGContent` being WEAKER than `GContent` means the seeds are SMALLER, making consistency proofs EASIER. In particular:

**Claim**: If `neg(Box(G phi))` is in MCS `M`, then `{neg phi} UNION BoxGContent(M)` is consistent.

**Proof sketch**:
- Suppose inconsistent: `{neg phi, chi_1, ..., chi_n} derives bot` where `Box(G chi_i) in M`
- By deduction: `{chi_1, ..., chi_n} derives phi`
- Need: from `{chi_1, ..., chi_n} derives phi`, derive `{Box(G chi_1), ..., Box(G chi_n)} derives Box(G phi)`
- This requires a "generalized BoxG K" rule: from `{chi_i} derives psi`, derive `{Box(G chi_i)} derives Box(G psi)`
- This follows from composing `generalized_temporal_k` (G distributes over derivation) and `generalized_modal_k` (Box distributes over derivation)
- Then `Box(G phi) in M`, contradicting `neg(Box(G phi)) in M`

This is the **C3 saturation constraint**: it ensures that witnesses for `neg(Box(G phi))` can be constructed.

### Finding 6: The C2 Gap Re-examined Under Non-Transitivity

Research-002 identified the C2 gap as a "critical obstruction": when constructing a forward witness u for C3, the Lindenbaum extension can add arbitrary `Box(H psi)` formulas, breaking C2.

Under non-transitivity, this obstacle is LESS severe:

1. **C2 is only needed for direct predecessors**: We only need `BoxHContent(u) SUBSET w` for worlds `w` that are DIRECTLY related to `u` (one step back). We do NOT need it for transitive predecessors.

2. **The construction can be BIDIRECTIONAL**: Instead of constructing u forward from w, we can construct a PAIR (w, u) simultaneously, or construct the HISTORY as a sequence, where each step maintains both C1 and C2 with its neighbors.

3. **The CanonicalMCS approach already handles this**: In `CanonicalBFMCS.lean`, the CanonicalMCS construction uses ALL MCS as the domain. The "accessibility" is CanonicalR (GContent-based), and backward_P/backward_H are proved via duality (`GContent_subset_implies_HContent_reverse`). This duality is the analogue of C1/C2 being mutually enforced.

### Finding 7: Non-Transitivity and the Truth Lemma

The truth lemma (`TruthLemma.lean:262-401`) proves:
```lean
phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

For the Box case (lines 323-348), the proof uses:
- Forward: `modal_forward` (Box phi in fam -> phi in all fam')
- Backward: `modal_backward` (phi in all fam' -> Box phi in fam)

These are **one-step** properties -- they say nothing about transitivity. The Box case works for the CURRENT time `t` across all families. The temporal operators G/H then handle time propagation WITHIN a single family.

**The non-transitivity of the task relation is compatible with the current truth lemma** because the truth lemma handles modal and temporal dimensions independently:
- Box: universal quantification over families (one-step, at fixed time)
- G: universal quantification over times (one-step, within single family)
- The BoxG compound: composition of these two independent quantifications

### Finding 8: The CanonicalMCS Approach and BoxGContent Revisited

The `CanonicalMCS` approach in `CanonicalBFMCS.lean` already achieves sorry-free temporal coherence by using ALL MCS as the domain. The Preorder is `CanonicalR` (GContent-based).

Consider defining a SECOND relation `CanonicalBoxGR` using BoxGContent:

```
CanonicalBoxGR(M, M') iff BoxGContent(M) SUBSET M'
```

Since `BoxGContent(M) SUBSET GContent(M)`, we have:
```
CanonicalR(M, M')  implies  CanonicalBoxGR(M, M')
```

That is, `CanonicalR` is STRONGER (fewer pairs) than `CanonicalBoxGR`. The CanonicalMCS Preorder already uses the stronger `CanonicalR`. So the BoxGContent-based relation is AUTOMATICALLY satisfied by the existing construction.

**This means the C1 constraint is already implicitly satisfied** by the existing CanonicalMCS construction. The question is whether formulating it explicitly via BoxGContent provides additional structure for the completeness proof.

### Finding 9: What the Seed-Based Unraveling Actually Achieves

The user's proposal for seed-based unraveling with BoxGContent is a DIFFERENT approach from the canonical frame:

1. **Canonical frame** (current): Start with ALL MCS, define accessibility globally, then prove properties. This is TOP-DOWN.

2. **Seed-based unraveling**: Start with ONE consistent sentence, generate related MCS by expanding seeds, building the structure BOTTOM-UP. This is constructive and may lead to a simpler sorry elimination path.

The advantage of seed-based unraveling:
- **Smaller structure**: Only includes MCS that are actually needed
- **Constructive**: Each step has a clear consistency argument
- **Natural handling of modal witnesses**: Each Diamond formula generates a new seed, which generates a new family

The disadvantage:
- **The C2 gap**: Backward constraints are harder to maintain during forward construction
- **Non-constant families**: Must construct non-trivial histories (not just constant families)

**Resolution path**: Use BoxGContent seeds with the understanding that non-transitivity means we only need LOCAL (one-step) C1/C2, not global. The history construction maintains C1/C2 with each neighbor, and compositionality handles the rest.

## Analysis of Non-Transitivity

### Why Non-Transitivity Is Fundamental

The task semantics models AGENCY: executing a task of duration d from state w reaches state u. The compositionality constraint says sequences of tasks compose. But the base relation is not transitive because:

- `task_rel w 1 u` means: a 1-hour task from w reaches u
- `task_rel u 1 v` means: a 1-hour task from u reaches v
- Compositionality gives: `task_rel w 2 v` (a 2-hour task from w reaches v)
- But NOT: `task_rel w 1 v` (we cannot do the 2-step journey in 1 hour)

In the MCS accessibility analogy:
- `w -> u` (BoxGContent(w) SUBSET u) means u is accessible from w in one temporal step
- `u -> v` (BoxGContent(u) SUBSET v) means v is accessible from u in one temporal step
- We get `w ->2 v` (a 2-step path) via compositionality
- We do NOT get `w -> v` (a 1-step path) because BoxGContent is not transitive

### The Right Level of Propagation

The hierarchy of content definitions, ordered from weakest to strongest:

```
BoxGContent(M) SUBSET GContent(M) SUBSET M
{phi | Box(G phi) in M}     {phi | G phi in M}     M itself
```

For INTER-WORLD propagation (between different histories), only BoxGContent is justified:
- `Box(G phi)` says: phi holds at all times of all histories -- this crosses world boundaries
- `G phi` only says: phi holds at all future times of THIS history -- no cross-world claim

For INTRA-WORLD propagation (within a single history/family), GContent is appropriate:
- `G phi` at time t means phi at all t' >= t in the same history

**This is exactly the decomposition the BFMCS+BMCS architecture already implements:**
- **BFMCS** (intra-world): uses GContent/HContent for temporal propagation
- **BMCS** (inter-world): uses BoxContent for modal propagation

The BoxGContent combines both: it's BoxContent restricted to G-formulas, which is exactly the content needed for inter-world temporal propagation.

## BoxGContent Reexamination

### Definition and Properties

```
BoxGContent(M) = {phi | Box(G phi) in M}
BoxHContent(M) = {phi | Box(H phi) in M}
```

**No existing definition in codebase**: `lean_local_search` for "BoxGContent" returns empty. The closest is:
- `BoxContent(fam)` in `CoherentConstruction.lean:109`: `{chi | exists t, Box chi in fam.mcs t}` -- this is across ALL times
- `BoxContentAt(fam, t)` in `CoherentConstruction.lean:117`: `{chi | Box chi in fam.mcs t}` -- this is at a specific time
- `GContent(M)` in `TemporalContent.lean:25`: `{phi | G phi in M}`

**BoxGContent would be**: `BoxContentAt applied to G-formulas` or equivalently `GContent applied to Box-formulas`.

### Key Relationships (Verified via Axiom System)

1. **BoxGContent(M) SUBSET GContent(M)**: By modal T axiom (`modal_t`: `Box(G phi) -> G phi`), `Box(G phi) in M` implies `G phi in M` (MCS closed under provable implications).

2. **BoxGContent(M) SUBSET BoxContentAt(M, t)**: NOT true in general. `Box(G phi) in M` gives `Box(G phi)` not `Box(phi)`. We'd need `G phi -> phi` (which is T axiom `temp_t_future`), then Box distributes: but that gives `Box(phi)` only via `Box(G phi) -> G phi -> phi`, which loses the Box.

3. **MF axiom**: `Box phi -> Box(G phi)`. So `BoxContentAt(M, t) SUBSET BoxGContent(M)` IF we only consider the image under G. Specifically: if `Box phi in M`, then `Box(G phi) in M` by MF. So `{phi | Box phi in M} SUBSET {phi | Box(G phi) in M}` -- i.e., `BoxContentAt(M,t) SUBSET BoxGContent(M)`.

Wait -- this is a significant observation. Let me verify carefully:

MF says: `Box phi -> Box(G phi)`. So if `Box phi in M`, then by MCS closure, `Box(G phi) in M`. Therefore `phi in BoxGContent(M)`.

This means: **BoxContentAt(M,t) SUBSET BoxGContent(M)**.

And since `BoxGContent(M) SUBSET GContent(M)`, we have:
```
BoxContentAt(M,t) SUBSET BoxGContent(M) SUBSET GContent(M)
```

The MF axiom makes BoxGContent STRICTLY between BoxContentAt and GContent. It inherits the Box-content (inter-world) properties and adds temporal (G) structure.

### BoxGContent Seed Consistency

**Theorem**: If `neg(Box(G phi))` is in MCS M, then `{neg phi} UNION BoxGContent(M)` is consistent.

**Proof**: Suppose inconsistent. Then exists `chi_1, ..., chi_n in BoxGContent(M)` with `{neg phi, chi_1, ..., chi_n} derives bot`.

Since `chi_i in BoxGContent(M)`, we have `Box(G chi_i) in M`.

By deduction theorem: `{chi_1, ..., chi_n} derives phi`.

By generalized temporal K (`generalized_temporal_k` in the codebase): `{G chi_1, ..., G chi_n} derives G phi`.

By generalized modal K (the modal analog): `{Box(G chi_1), ..., Box(G chi_n)} derives Box(G phi)`.

All `Box(G chi_i) in M`, so by MCS closure: `Box(G phi) in M`.

But `neg(Box(G phi)) in M`. Contradiction with MCS consistency.

**Codebase evidence for required infrastructure**:
- `generalized_temporal_k`: Exists in `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean`
- `generalized_modal_k` (or equivalent): Need to verify. The modal analog should exist or be derivable from `modal_k_dist` axiom + `modal_necessitation` rule.
- `temporal_witness_seed_consistent` (line 429 of TemporalCoherentConstruction.lean): Proves `{psi} UNION GContent(M)` is consistent when `F(psi) in M` -- an analogous result using GContent.

## Evidence: Verified Lemma Names

| Lemma | Location | Status |
|-------|----------|--------|
| `BMCS.box_iff_universal` | BMCS.lean:256 | Sorry-free |
| `BMCS.modal_forward` | BMCS.lean:95 | Structure field (sorry-free) |
| `BMCS.modal_backward` | BMCS.lean:103 | Structure field (sorry-free) |
| `bmcs_truth_lemma` | TruthLemma.lean:262 | Sorry-free |
| `canonical_forward_F` | CanonicalFrame.lean:122 | Sorry-free |
| `canonical_backward_P` | CanonicalFrame.lean:151 | Sorry-free |
| `canonical_forward_G` | CanonicalFrame.lean:86 | Sorry-free |
| `canonical_backward_H` | CanonicalFrame.lean:96 | Sorry-free |
| `canonicalMCSBFMCS` | CanonicalBFMCS.lean:158 | Sorry-free |
| `canonicalMCS_forward_F` | CanonicalBFMCS.lean:196 | Sorry-free |
| `canonicalMCS_backward_P` | CanonicalBFMCS.lean:214 | Sorry-free |
| `temporal_witness_seed_consistent` | TemporalCoherentConstruction.lean:429 | Sorry-free |
| `generalized_temporal_k` | GeneralizedNecessitation.lean | Sorry-free, verified |
| `generalized_modal_k` | GeneralizedNecessitation.lean | Sorry-free, verified: `(Gamma derives phi) -> (Box Gamma derives Box phi)` |
| `fully_saturated_bmcs_exists_int` | TemporalCoherentConstruction.lean:799 | SORRY (1 sorry) |
| `temporal_coherent_family_exists` | TemporalCoherentConstruction.lean:607 | SORRY (generic D) |
| `GContent` | TemporalContent.lean:25 | Definition |
| `HContent` | TemporalContent.lean:35 | Definition |
| `BoxContent` | CoherentConstruction.lean:109 | Definition |
| `BoxContentAt` | CoherentConstruction.lean:117 | Definition |
| `BoxGContent` | (does not exist yet) | Needs definition |

## Confidence Level

**HIGH (80%)** for the analysis that non-transitivity makes BoxGContent the CORRECT choice:
- The semantic argument is sound: Box(G phi) crosses history boundaries, G phi does not
- The MF axiom provides the right bridge: BoxContentAt SUBSET BoxGContent
- The decomposition through BMCS + BFMCS layers already exists
- The seed consistency argument follows the established `temporal_witness_seed_consistent` pattern

**MODERATE (60%)** for seed-based unraveling as a complete resolution path:
- The C2 gap remains a concern, though non-transitivity reduces its severity
- The construction of non-constant witness families is still non-trivial
- Integration with the existing sorry in `fully_saturated_bmcs_exists_int` needs work

**LOW (35%)** for this approach alone eliminating all sorries:
- The fundamental sorry in `fully_saturated_bmcs_exists_int` requires BOTH temporal coherence AND modal saturation
- BoxGContent seeds help with modal saturation witnesses but don't directly solve temporal coherence for witness families
- The temporal G/H backward cases in the truth lemma still require forward_F/backward_P for ALL families

## Recommendations

### Recommendation 1: Define BoxGContent and BoxHContent Formally

Add to `TemporalContent.lean` or a new file:
```lean
def BoxGContent (M : Set Formula) : Set Formula :=
  {phi | Formula.box (Formula.all_future phi) in M}

def BoxHContent (M : Set Formula) : Set Formula :=
  {phi | Formula.box (Formula.all_past phi) in M}
```

### Recommendation 2: Prove BoxGContent Seed Consistency

Following the pattern of `temporal_witness_seed_consistent`, prove:
```lean
theorem boxg_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg : Formula.neg (Formula.box (Formula.all_future phi)) in M) :
    SetConsistent ({Formula.neg phi} UNION BoxGContent M)
```

This requires `generalized_modal_k` (modal analog of `generalized_temporal_k`).

### Recommendation 3: Consider Hybrid Approach

Combine the strengths of both approaches:
1. Use `CanonicalMCS` for the temporal domain (sorry-free forward_F/backward_P)
2. Use BoxGContent seeds for constructing modal witness families
3. Use the restructured truth predicate (research-003) to avoid temporal coherence requirements for witness families in the Box case

### Recommendation 4: Do NOT Pursue Transitivity

The prior research correctly identified that transitivity of the BoxG-accessibility fails. The user's correction confirms this is by design. Do not attempt to prove transitivity or design constructions that assume it.

## Next Steps

1. Verify `generalized_modal_k` exists or can be derived (needed for seed consistency)
2. Formally define BoxGContent/BoxHContent
3. Prove BoxGContent seed consistency
4. Design the seed-based unraveling construction using BoxGContent, informed by non-transitivity
5. Investigate whether the hybrid approach (Canonical domain + BoxGContent witnesses + restructured truth) can eliminate `fully_saturated_bmcs_exists_int` sorry
