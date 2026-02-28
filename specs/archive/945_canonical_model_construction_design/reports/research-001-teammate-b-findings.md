# Research Report: Task 945 - Teammate B Findings

**Task**: 945 - Design canonical model construction for TruthLemma
**Date**: 2026-02-27
**Focus**: Alternative canonical model constructions, structural analysis of why CanonicalMCS achieves temporal coherence "for free", comparison of Int-indexed vs CanonicalMCS-indexed models, and novel construction patterns
**Model**: Claude Opus 4.6

---

## Key Findings

### 1. WHY CanonicalMCS Achieves Temporal Coherence "For Free"

The structural explanation for why `canonicalMCSBFMCS` achieves sorry-free `forward_F` and `backward_P` while the DovetailingChain does not is deeply illuminating.

**The DovetailingChain (Int domain) failure mode**:

In the Int-indexed construction, building `M_{n+1}` from `GContent(M_n)` creates a fundamental information-loss problem. `GContent(M) = {phi | G(phi) in M}`. The formula `F(psi) = neg(G(neg(psi)))` is NOT captured by GContent. It is a NEGATION of a G-formula, not a G-formula itself. So when Lindenbaum extends `GContent(M_n)` to produce `M_{n+1}`, it is free to include `G(neg(psi))` -- which KILLS the F-obligation from `M_n`.

The key structural property is: **GContent is a monotone filter on G-formulas but destroys F-obligations.**

**The CanonicalMCS (all-MCS domain) solution**:

In `CanonicalMCS`, the domain elements ARE the MCSes themselves. When `F(psi)` is in `w.world`, the witness construction (`canonical_forward_F`) creates a FRESH MCS `W` from `{psi} union GContent(w.world)` via Lindenbaum. The crucial difference:

1. **No sequential construction**: The witness W is built INDEPENDENTLY for each F-obligation. There is no chain where a later step can interfere with an earlier obligation.
2. **Domain membership is automatic**: Since W is an MCS, it is automatically a `CanonicalMCS` element. No reachability or chain-inclusion argument needed.
3. **The Preorder condition `w <= W`**: `CanonicalR w.world W.world` means `GContent(w.world) subset W.world`, which holds by construction since W was built from a seed containing `GContent(w.world)`.

The structural difference is NOT about the domain type (Int vs CanonicalMCS). It is about **sequential vs. parallel witness construction**:
- Int chain: witnesses must be placed IN a single linear sequence, where later constructions can corrupt earlier witnesses
- CanonicalMCS: each witness is an independent Lindenbaum extension, invisible to all other witness constructions

**Verified**: `canonical_forward_F` in `CanonicalFrame.lean` (sorry-free). `forward_temporal_witness_seed_consistent` provides the consistency of `{psi} union GContent(M)`.

### 2. The Int-Indexed vs. CanonicalMCS-Indexed Model Comparison

| Property | Int-Indexed (DovetailingChain) | CanonicalMCS-Indexed |
|----------|-------------------------------|---------------------|
| Domain type | `Int` (linear order) | `CanonicalMCS` (preorder) |
| Domain elements | Construction steps | MCSes themselves |
| `forward_G` | PROVEN (all cases) | PROVEN (trivial by definition) |
| `backward_H` | PROVEN (all cases) | PROVEN (via duality) |
| `forward_F` | **SORRY** (F non-persistence) | **PROVEN** (fresh witness) |
| `backward_P` | **SORRY** (P non-persistence) | **PROVEN** (fresh witness) |
| FMCS instance | `FMCS Int` (sorry-backed) | `FMCS CanonicalMCS` (sorry-free) |
| Single family temporal coherence | Partial (2 sorries) | Complete (0 sorries) |
| BFMCS construction | `fully_saturated_bfmcs_exists_int` (sorry) | **NOT CONSTRUCTED** |
| Modal saturation | sorry-backed | **NOT CONSTRUCTED** |

The key observation: **both approaches have the SAME blocker for BFMCS completeness** -- modal saturation with temporally coherent witness families. The CanonicalMCS approach solved the temporal coherence problem for a SINGLE family but has not yet addressed building a BUNDLE.

### 3. Why Modal Saturation Over CanonicalMCS Is Fundamentally Different From Over Int

While Teammate A correctly identifies that modal saturation remains the blocker, there is a subtle structural difference between the CanonicalMCS and Int cases that deserves deeper analysis.

**Over Int**, the domain is linearly ordered and the FMCS maps each `t : Int` to `M_t : Set Formula` where the MCSes at different times are necessarily DIFFERENT (constructed by a sequential chain). Adding witness families means constructing ADDITIONAL chains, each with its own DovetailingChain-like construction. The temporal coherence of each witness chain inherits the same 2 sorries.

**Over CanonicalMCS**, the domain is a tree-like preorder where `w1 <= w2` iff `GContent(w1.world) subset w2.world`. The eval family maps each `w` to `w.world` (identity). For modal diversity, we need families that map some `w` to a DIFFERENT MCS than `w.world`. But any such non-identity mapping must still satisfy `forward_G` and `backward_H`.

The critical constraint for a family `fam` over CanonicalMCS:
- `forward_G`: If `w1 <= w2` and `G(phi)` is in `fam.mcs(w1)`, then `phi` must be in `fam.mcs(w2)`.
- `backward_H`: If `w2 <= w1` and `H(phi)` is in `fam.mcs(w1)`, then `phi` must be in `fam.mcs(w2)`.

For the identity family, these hold because `w1 <= w2` means `GContent(w1.world) subset w2.world`, which is exactly the statement that G-formulas propagate.

For a constant family `fam.mcs(w) = W.world`, `forward_G` holds vacuously (trivially if W is an MCS: `G(phi) in W` implies `phi in W` by the T-axiom). But `forward_F` requires: `F(phi) in W` implies exists `s >= w` with `phi in fam.mcs(s) = W`. Since `fam.mcs(s) = W` for ALL s, this reduces to `F(phi) in W implies phi in W`, which is impossible for consistent sets like `{F(phi), neg(phi)}`.

### 4. A Novel Construction: The "Canonical Bundle" Approach

Here I propose a construction that I believe has NOT been explored in the project history. It addresses the modal saturation + temporal coherence combination problem by leveraging the specific structure of the CanonicalMCS domain.

**Key insight**: Instead of building witness families as constant families or DovetailingChain families, build them as "TRANSLATED identity" families over CanonicalMCS.

**Construction**: For each Diamond obligation `Diamond(psi)` at a family's MCS at point `w`, we need a witness family `fam'` with `psi in fam'.mcs(w)`. Define:

```
fam'_W.mcs(v) = translate(v, W, w₀)
```

where `translate` produces an MCS that is "like v.world but shifted toward W".

But this is too vague. Let me be more precise.

**A concrete proposal: The "selection function" approach**

Define witness families using a selection function `sigma : CanonicalMCS -> CanonicalMCS`:

```
witness_family(sigma).mcs(v) = sigma(v).world
```

For this to be an FMCS, we need:
- `forward_G`: `v1 <= v2` and `G(phi) in sigma(v1).world` implies `phi in sigma(v2).world`
- `backward_H`: `v2 <= v1` and `H(phi) in sigma(v1).world` implies `phi in sigma(v2).world`

The forward_G condition means: `sigma(v1) <= sigma(v2)` whenever `v1 <= v2`. In other words, **sigma must be monotone** with respect to the CanonicalR preorder.

The forward_F condition means: `F(phi) in sigma(v).world` implies there exists `s >= v` with `phi in sigma(s).world`. Since `sigma` is monotone and `sigma(v) <= sigma(s)` for `s >= v`, we need: `F(phi) in sigma(v).world` implies there exists `s >= v` with `phi in sigma(s).world`.

Now here is the key: if `sigma` is monotone AND the image of sigma includes enough MCSes, then by `canonical_forward_F`, `F(phi) in sigma(v).world` implies there exists an MCS `W` with `CanonicalR sigma(v).world W.world` and `phi in W.world`. We need `W = sigma(s)` for some `s >= v`.

**Problem**: There is no reason why the Lindenbaum witness W should be in the image of sigma.

**Revised approach**: Instead of requiring W to be in the image, we could define sigma as: `sigma(v) = canonical_forward_F_witness(sigma(v), phi)` for the relevant phi. But this is circular.

**Assessment**: The selection function approach does not obviously resolve the combination problem. The fundamental issue persists: the Lindenbaum witness is an ARBITRARY MCS extending the seed, and we cannot control which MCS it produces. There is no way to force it into the image of any particular monotone function.

### 5. A Deeper Structural Analysis: Why BFMCS + Temporal Coherence Is Genuinely Hard

I want to challenge the assumption that there EXISTS a sorry-free BFMCS construction satisfying both temporal coherence and modal saturation. Let me analyze this from a logical perspective.

**Claim**: The combination of `bmcs_truth_at` (recursive truth definition with Box quantifying over bundle families) and temporal coherence (forward_F/backward_P for all families) creates an inherent tension that may be a genuine IMPOSSIBILITY for tense logics with both Box and temporal modalities.

**Argument sketch**:

1. Consider a formula `Box(F(p))` where p is an atom.
2. `bmcs_truth_at B fam t (Box(F(p)))` means: for ALL families `fam'` in the bundle, `bmcs_truth_at B fam' t (F(p))`.
3. `bmcs_truth_at B fam' t (F(p))` is NOT directly defined by `bmcs_truth_at` (since F is derived as neg(G(neg(p)))). Unfolding: `not (bmcs_truth_at B fam' t (G(neg(p))))` = `not (forall s >= t, not bmcs_truth_at B fam' s p)` = `exists s >= t, bmcs_truth_at B fam' s p` = `exists s >= t, p in fam'.mcs(s)`.
4. So `bmcs_truth_at B fam t (Box(F(p)))` means: for ALL families fam', there EXISTS s >= t with p in fam'.mcs(s).
5. By the truth lemma (forward direction), this should correspond to `Box(F(p)) in fam.mcs(t)`.
6. By modal_forward: `F(p) in fam'.mcs(t)` for all fam'.
7. By temporal coherence (forward_F) of fam': exists s >= t with p in fam'.mcs(s). This MATCHES step 4.

So the truth lemma's forward direction for `Box(F(p))` works: it uses modal_forward on fam, then forward_F on each fam'.

Now the backward direction:
8. Assume `bmcs_truth_at B fam t (Box(F(p)))` -- i.e., for all fam', exists s >= t with p in fam'.mcs(s).
9. We need `Box(F(p)) in fam.mcs(t)`.
10. By the truth lemma IH backward for F(p): for each fam', `bmcs_truth_at B fam' t (F(p))` (i.e., exists s >= t with p in fam'.mcs(s)) should imply `F(p) in fam'.mcs(t)`.
11. But the IH for F(p) at fam' goes through: `not (G(neg(p)))` at fam', which requires the backward for G(neg(p)) at fam', which uses temporal_backward_G for fam', which requires forward_F for fam'.

This chain works IF fam' is temporally coherent. The issue is that establishing temporal coherence for ALL families requires forward_F for ALL families, which means the construction must produce witness families that satisfy forward_F.

**The tension**: Modal_backward says: if phi is in ALL families at time t, then Box(phi) is in fam.mcs(t). The construction of witness families for Diamond(psi) requires psi to be in SOME family at time t, but this witness family must have forward_F, which means it must produce FURTHER witnesses for ITS F-obligations, and so on ad infinitum.

This is NOT a circular dependency -- it is a WELL-FOUNDED construction because the formula structure decreases in the truth lemma induction. But the construction of witness families must be done SIMULTANEOUSLY for all Diamond obligations across all formula depths, not one at a time.

**Key observation**: The standard Henkin completeness proof for S5 modal logic (without temporal operators) does NOT have this problem because S5 has no temporal coherence requirement. Witness families for Diamond can be constant, and constant families trivially satisfy all conditions. The TEMPORAL operators introduce the combination difficulty.

### 6. Comparison with the FMP Approach

The FMP approach (`SemanticCanonicalModel.lean`) achieves sorry-free weak completeness by a fundamentally different architecture:

1. **No bundle**: Uses a SINGLE finite model, not a bundle of families
2. **No temporal coherence requirement**: Works with `FiniteWorldState` and `SemanticWorldState` quotients
3. **No modal saturation**: The Box semantics is standard (quantify over all worlds in the model), not restricted to a bundle
4. **Finite closure**: Works within the subformula closure of a single formula phi

The FMP approach succeeds because it avoids the bundle architecture entirely. The truth lemma for FMP (`semantic_truth_lemma` at line 274) connects `psi in S` to `w.models psi h_mem` using closure-MCS properties, not FMCS temporal coherence.

**Why FMP cannot directly handle strong completeness**: The FMP constructs a model from the CLOSURE of a single formula phi. For strong completeness with a context Gamma, we would need a model that satisfies ALL of Gamma simultaneously. If Gamma is finite (List Formula in this codebase), we can use `bigAnd(Gamma)` to reduce to the single-formula case. This is the approach recommended by research-009 of task 922.

**Verified**: `fmp_weak_completeness` in `SemanticCanonicalModel.lean` depends only on `propext`, `Classical.choice`, `Quot.sound` (no `sorryAx`).

### 7. Can the CanonicalMCS Approach Be Adapted for Standard Validity?

The question is whether a BFMCS over CanonicalMCS can provide standard-validity completeness (not just BFMCS-validity completeness).

**Current standard validity bridge**: `Representation.lean` converts BFMCS satisfiability to standard `TaskFrame`-based satisfiability. The bridge constructs a `TaskFrame D` (with `D = Int`) and maps BFMCS families to world histories.

**For CanonicalMCS domain**: We would need a `TaskFrame CanonicalMCS` and a shift-closed set of world histories over CanonicalMCS. The CanonicalMCS preorder `w1 <= w2` iff `GContent(w1.world) subset w2.world` defines a temporal accessibility relation. This is NOT linearly ordered (not all MCSes are comparable), so the resulting temporal structure is tree-like, not chain-like.

**Standard TM semantics uses linear time (Int)**. The temporal operators G/H quantify over ALL future/past times in a LINEAR order. A tree-like preorder would give a BRANCHING time semantics, which is different from TM's intended linear-time semantics.

**However**: For BFMCS-validity completeness over CanonicalMCS, the domain does not need to be linearly ordered. The truth definition `bmcs_truth_at` uses `Preorder D`, not `LinearOrder D`. The completeness theorem `bmcs_weak_completeness` is parameterized over `D : Type*` with `[Preorder D]`. So BFMCS completeness over CanonicalMCS IS meaningful, even if it does not directly yield standard-validity completeness.

**For standard-validity completeness**: One would need either:
1. Show that BFMCS-validity over CanonicalMCS implies standard-validity (requires a representation bridge for non-linear domains)
2. Embed CanonicalMCS-indexed models into Int-indexed standard models (unclear how)
3. Bypass the BFMCS entirely and prove standard-validity completeness via FMP

**Assessment**: Adapting CanonicalMCS for STANDARD validity is non-trivial because of the linear vs. branching time mismatch. The FMP route (Path 3 in Teammate A's analysis) is more natural for standard-validity completeness.

### 8. Construction Patterns from the Modal Logic Literature

Several well-known construction patterns from the modal logic literature are relevant:

**8a. The Bulldozer Construction** (unraveling a preorder into a linear order):
Take the CanonicalMCS preorder and "unravel" it into a linear chain by choosing a maximal chain through the tree. This would give a linear FMCS (like the Int case) but built from CanonicalMCS elements rather than from scratch. The advantage: forward_F/backward_P might be inherited from the CanonicalMCS structure. The disadvantage: selecting a maximal chain is highly non-constructive and may not preserve all temporal obligations.

**8b. The Mosaic Method** (building models from local tiles):
Decompose the truth conditions into local constraints ("mosaics" or "tiles") and glue them together. Each mosaic is a small fragment that satisfies local coherence. The global model is assembled from mosaics. This approach is used in decidability proofs for temporal logics but might offer a path to constructing BFMCS families as well.

**8c. The Step-by-Step Method** (Goldblatt, "Logics of Time and Computation"):
The standard completeness proof for tense logics (which this project cites) uses a canonical model where worlds are MCSes and the temporal relation is defined by GContent/HContent. This is EXACTLY the CanonicalMCS approach. Goldblatt does NOT use bundles for the modal modality. In pure tense logic (G/H only, no Box), the canonical model construction works because there is no Box to create the bundle requirement.

**Key insight from Goldblatt**: The difficulty in this project is NOT with the tense logic part (G/H), which is solved by CanonicalMCS. It is with the COMBINATION of tense and modal operators (G/H + Box). Pure S5 modal completeness works with bundles but no temporal coherence. Pure tense completeness works with CanonicalMCS but no bundles. The combination requires both.

**8d. The Product Frame Construction**:
For logics that are products of two uni-modal logics (like Box + G), the canonical frame is the PRODUCT of the two canonical frames. For TM logic, this would be:
- Modal part: worlds = MCSes, accessibility = universal (S5-like)
- Temporal part: worlds = MCSes, accessibility = GContent ordering (tense-like)
- Product: worlds = pairs (w_modal, w_temporal), with both relations

However, TM logic is NOT simply a product of S5 and tense logic. The Box and G/H operators INTERACT (e.g., `Box(G(phi))` involves both modalities). The product construction does not directly apply.

**Assessment**: None of the standard constructions from the literature directly solve the BFMCS combination problem as stated. The difficulty is specific to the BFMCS architecture (bundle of temporal families) and does not arise in standard one-world-at-a-time canonical model constructions.

---

## Alternative Approaches

### Alternative A: Eliminate the BFMCS Architecture (Recommended)

**Approach**: Prove strong completeness via FMP without BFMCS.

**Detailed plan**:
1. Define `bigAnd : List Formula -> Formula` (conjunction of a finite list)
2. Prove: `ContextConsistent Gamma` implies `ContextConsistent [bigAnd(Gamma)]`
3. Prove: `semantic_consequence Gamma phi` implies `valid (bigAnd(Gamma).imp phi)`
4. Apply `fmp_weak_completeness` to get `derives [] (bigAnd(Gamma).imp phi)`
5. Prove: `derives Gamma (bigAnd(Gamma))` (conjunction introduction)
6. Combine: `derives Gamma phi`

**Infrastructure needed**: `bigAnd` (likely a fold), conjunction intro/elim lemmas for lists, and bridging the FMP's `semantic_truth_at_v2` with the standard `semantic_consequence`. The deduction theorem already exists.

**Estimated effort**: 2-4 hours (aligns with research-009 estimate)
**Success probability**: 90%+
**Sorry impact**: Would make ALL completeness results sorry-free without touching BFMCS

### Alternative B: Depth-Stratified Temporal Coherence

**Approach**: Reformulate the truth lemma to require temporal coherence only for formulas up to depth `d`, where `d` decreases at each induction step.

**Sketch**:
- Define `temporally_coherent_upto (fam : FMCS D) (d : Nat)`: forward_F and backward_P only for formulas of temporal depth < d
- The truth lemma at depth d would require witness families to be `temporally_coherent_upto (d-1)`
- At depth 0, temporal coherence is vacuous, so constant witness families work
- At depth d+1, witness families need coherence up to d, which was established at the previous step

**Challenge**: The truth lemma uses structural induction on formulas (which is well-founded by the Formula datatype), not induction on a natural number depth. Reformulating to use depth explicitly would require:
1. Defining formula depth
2. Proving the truth lemma by well-founded induction on depth
3. Defining `temporally_coherent_upto d` and showing it suffices for the IH at depth d
4. Constructing witness families that are `temporally_coherent_upto d` for any d

This is **speculative** but represents the only unexplored avenue I can identify for making the BFMCS approach work.

**Estimated effort**: 8-20 hours (highly uncertain)
**Success probability**: 40-60% (the depth stratification might not compose correctly)

### Alternative C: Single-Family "Extended" BFMCS (Avoid Bundles)

**Approach**: Replace the BFMCS architecture with a single extended MCS that handles Box internally.

The standard canonical model for S5 uses a SINGLE set of MCSes as worlds with an equivalence relation for Box. The BFMCS architecture was introduced to make the Box case of the truth lemma go through. But what if we define Box semantics differently?

**Idea**: Define a "universal canonical model" where:
- Worlds = `CanonicalMCS` (all MCSes)
- Box(phi) is true at w iff phi is in w.world (using the T-axiom `Box(phi) -> phi` and S5 properties)

Wait -- `Box(phi)` true at w iff phi is true at ALL worlds accessible from w. In S5, accessibility is an equivalence relation. In TM with S5 box:
- `Box(phi) -> phi` (T axiom)
- `phi -> Box(Diamond(phi))` (B axiom? depends on the exact modal axioms)

**Assessment**: This approach would require understanding the exact modal axioms of TM logic and whether S5 is the intended modal logic. The current project uses Box with `modal_forward` and `modal_backward` in the BFMCS, which is essentially S5 within the bundle. If S5 is the intended semantics, a single canonical model with an equivalence relation might work. But the BFMCS was introduced precisely because the single-model approach failed (documented in research-007 of task 812). The failure was with making `modal_backward` work without the bundle restriction.

**Estimated effort**: Unknown (requires revisiting the original motivation for BFMCS)
**Success probability**: LOW (the original failure is likely a genuine obstacle)

---

## Evidence (Verified via lean_local_search)

| Lemma / Definition | Exists? | File | Sorry-Free? |
|--------------------|---------|------|-------------|
| `canonical_forward_F` | Yes | CanonicalFrame.lean | YES |
| `canonical_backward_P` | Yes | CanonicalFrame.lean | YES |
| `canonicalMCSBFMCS` | Yes (via `canonicalMCSBFMCS_root_contains`) | CanonicalFMCS.lean | YES |
| `canonicalMCS_mcs` | Yes | CanonicalFMCS.lean | YES |
| `canonicalMCS_is_mcs` | Yes | CanonicalFMCS.lean | YES |
| `canonicalR_reflexive` | Yes | CanonicalFrame.lean | YES |
| `canonicalR_transitive` | Yes | CanonicalFrame.lean | YES |
| `GContent_subset_implies_HContent_reverse` | Yes | DovetailingChain.lean | YES |
| `HContent_subset_implies_GContent_reverse` | Yes | DovetailingChain.lean | YES |
| `forward_temporal_witness_seed_consistent` | Yes (as `ForwardTemporalWitnessSeed`) | DovetailingChain.lean | YES |
| `fully_saturated_bfmcs_exists_int` | Yes | TemporalCoherentConstruction.lean | NO (sorry) |
| `fmp_weak_completeness` | Yes | SemanticCanonicalModel.lean | YES |
| `bmcs_truth_lemma` | Yes | TruthLemma.lean | YES |

---

## Confidence Level

**HIGH confidence** in the structural analysis of why CanonicalMCS achieves temporal coherence (Finding 1). The analysis is based on direct code reading and the mathematical structure is clear.

**HIGH confidence** that the modal saturation + temporal coherence combination problem is a genuine mathematical difficulty (Finding 5). The argument traces through the truth lemma's inductive structure and shows why all families need temporal coherence.

**HIGH confidence** in Alternative A (FMP strong completeness). The mathematical argument is standard, the infrastructure likely exists, and the effort is bounded.

**MEDIUM confidence** in the claim that no BFMCS construction can resolve the combination problem. The depth-stratification idea (Alternative B) is unexplored and might work, but the formalization complexity is unclear.

**LOW confidence** in Alternative C (single-family extended BFMCS). This revisits ground that was already explored and abandoned early in the project.

---

## Recommendations for Task 945

### Primary Recommendation: Path 3 (FMP Strong Completeness) via Alternative A

The canonical model construction satisfying the TruthLemma **already exists and is sorry-free** (`canonicalMCSBFMCS` in `CanonicalFMCS.lean`). The TruthLemma itself is sorry-free. The remaining problem is NOT the canonical model or the TruthLemma -- it is the BFMCS construction that feeds the completeness chain.

Rather than finding a new BFMCS construction (which faces the genuine mathematical difficulty of combining temporal coherence with modal saturation for ALL families), the project should bypass BFMCS entirely and achieve sorry-free strong completeness via the FMP `bigAnd(Gamma)` trick.

### Secondary Recommendation: If BFMCS Must Be Pursued, Explore Depth-Stratified Coherence

The depth-stratification approach (Alternative B) is the only genuinely novel idea I can identify that has not been tried. It might allow constant witness families at the base case (depth 0) and build up coherence at higher depths. But the formalization effort is uncertain and the approach is speculative.

### What NOT to Pursue

1. **Int-indexed DovetailingChain forward_F/backward_P**: Dead end (12+ approaches tried, fundamental F-formula non-persistence through GContent)
2. **Constant witness families over any domain**: Provably impossible for temporally coherent families (counterexample: `{F(psi), neg(psi)}`)
3. **Identity-mapping witness families over CanonicalMCS**: All families agree at every point, no modal diversity, modal_backward fails
4. **Selection function approach**: The Lindenbaum witness cannot be controlled to land in the image of a monotone function

---

## File References

| File | Path | Role in Analysis |
|------|------|-----------------|
| CanonicalFrame.lean | `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` | Sorry-free forward_F/backward_P for canonical frame |
| CanonicalFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` | Sorry-free FMCS over CanonicalMCS, temporal_coherent_family_exists_CanonicalMCS |
| DovetailingChain.lean | `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` | Int-indexed chain, 2 sorries, GContent/HContent duality proofs |
| TemporalCoherentConstruction.lean | `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` | temporal_backward_G/H, fully_saturated_bfmcs_exists_int (1 sorry) |
| TruthLemma.lean | `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` | Sorry-free truth lemma (all 6 cases) |
| BFMCSTruth.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` | bmcs_truth_at definition (Box = quantify over bundle) |
| BFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` | BFMCS structure (modal_forward, modal_backward) |
| ModalSaturation.lean | `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` | is_modally_saturated, saturated_modal_backward |
| Completeness.lean | `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` | BFMCS completeness chain (sorry-free given construction) |
| Representation.lean | `Theories/Bimodal/Metalogic/Representation.lean` | Standard validity bridge |
| SemanticCanonicalModel.lean | `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` | Sorry-free FMP weak completeness |
| FMCSDef.lean | `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` | FMCS structure definition |
| TemporalContent.lean | `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` | GContent/HContent definitions |
