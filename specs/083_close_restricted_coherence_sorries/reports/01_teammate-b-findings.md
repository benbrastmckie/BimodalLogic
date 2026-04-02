# Research Report: Teammate B -- Alternative Approaches and Prior Art

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-02
**Focus**: Alternative approaches, prior art survey, Mathlib infrastructure

---

## Key Findings

1. **The 4 sorries decompose into 2 real problems and 2 derivative ones.** The UltrafilterChain.lean sorries (`succ_chain_restricted_forward_F`, `succ_chain_restricted_backward_P`) are the genuine blockers -- they attempt to prove restricted temporal coherence on the FULL MCS chain (`succ_chain_fam`). The RestrictedTruthLemma.lean sorries (`restricted_chain_G_propagates` at line 116, `restricted_chain_H_step` at line 158) are NOT actually needed for the current restricted truth lemma and may be eliminable by restructuring.

2. **The restricted DRM chain already has sorry-free forward_F/backward_P** (`build_restricted_tc_family` at SuccChainFMCS.lean:6313). The fundamental problem is bridging from DRM-level coherence to full-MCS-level coherence needed by `succ_chain_fam`.

3. **The dovetailed chain approach (DovetailedChain.lean) was extensively analyzed and found to be fundamentally blocked** by F-formula non-persistence through Lindenbaum extensions. This is documented at DovetailedChain.lean:587: "THIS APPROACH FUNDAMENTALLY DOESN'T WORK for same-family forward_F with Lindenbaum-based chains."

4. **The most promising approach bypasses the UltrafilterChain.lean sorries entirely** by proving completeness directly from the restricted truth lemma, avoiding the need for full-MCS temporal coherence.

5. **Standard references confirm the structural mismatch**: classical canonical model completeness (Goldblatt, Blackburn/de Rijke/Venema) uses a FLAT set of MCS as worlds with canonical relations, where forward_F is trivial. TM task semantics requires LINEAR families (timelines), creating the single-chain coherence problem that is genuinely harder.

---

## Prior Art

### Standard Canonical Model Approach (Goldblatt 1992, Blackburn/de Rijke/Venema 2001)

In standard Kripke temporal completeness:
- **Worlds** = all MCS of the logic
- **R(Gamma, Delta)** iff g_content(Gamma) subset Delta
- **Forward_F**: Given F(phi) in Gamma, by `temporal_theory_witness_exists`, there exists Delta MCS with phi in Delta and R(Gamma, Delta). ONE-LINE proof.

**Why it doesn't transfer**: TM task semantics requires worlds organized into families (timelines), not a flat set. G(phi) means phi at all future times IN THE SAME HISTORY, not at all R-accessible worlds. The standard approach gives bundle-level witnesses (different families), not same-family witnesses.

### Gabbay/Hodkinson/Reynolds 1994 (Temporal Logic: Mathematical Foundations and Computational Aspects)

The step-by-step construction with fair scheduling is the closest to what's needed. Their approach:
1. Build the chain incrementally, resolving one obligation per step
2. Use fair scheduling to ensure every obligation is eventually addressed
3. **Critical difference from TM**: They work with a single temporal dimension and no modal operators. The interaction between Box and G in TM creates the G-liftability problem that blocks F-persistence.

### Gabbay/Kurucz/Wolter/Zakharyaschev 2003 (Many-Dimensional Modal Logics)

Product logic FMP (finite model property) gives weak completeness. This is already implemented sorry-free via `SemanticCanonicalModel.lean`. The canonical completeness (strong completeness) for product/fusion logics is acknowledged as significantly harder, with the coherence problem being a known difficulty.

### Key Literature Insight

The literature universally handles this by either:
1. Using flat canonical models (avoiding timelines entirely)
2. Using FMP/finite model arguments (avoiding infinite chains)
3. Using step-by-step constructions with fair scheduling in SIMPLER logics where F-persistence holds

None of these directly apply to TM with task semantics, confirming this is a genuinely novel formalization challenge.

---

## Alternative Approaches

### Approach 1: Direct Restricted Completeness (Bypass UltrafilterChain Sorries)

**Concept**: Instead of proving `succ_chain_restricted_forward_F` (which tries to lift restricted coherence to the full MCS chain), prove completeness directly using the restricted truth lemma infrastructure.

**Mathematical Analysis**:
- `restricted_truth_lemma` (RestrictedTruthLemma.lean:291) is SORRY-FREE and establishes: for psi in subformulaClosure(phi), `psi in restricted_chain(n) <-> psi in restricted_chain_ext(n)`
- `restricted_ext_neg_excludes_phi` (RestrictedTruthLemma.lean:381) is SORRY-FREE
- The remaining gap: building a CANONICAL MODEL from `restricted_chain_ext` that satisfies truth for ALL subformulas, not just restricted chain membership

**The key insight**: The restricted truth lemma shows DRM membership iff extended MCS membership for closure formulas. But we need a full truth lemma: `psi in ext(n) <-> truth_at(model, n, psi)` for a task model. This requires:
1. A task frame built from the extended chain
2. forward_G and backward_H for the extended chain (for arbitrary formulas)
3. forward_F and backward_P for the extended chain (for closure formulas only)

Items 1 is constructible. Item 3 follows from restricted coherence + embedding. Item 2 is the blocker -- independent Lindenbaum extensions don't preserve G-propagation for non-closure formulas.

**Viability**: MEDIUM-HIGH. The G-propagation issue for non-closure formulas may be solvable because the truth lemma only recurses on subformulas, and all subformulas ARE in the closure. The forward_G case in the parametric truth lemma uses G-propagation only for the ARGUMENT of G, which is a subformula and hence in the closure.

**Effort**: 8-15 hours

### Approach 2: Ultrafilter Compactness / Topological Argument

**Concept**: Use the compactness of the ultrafilter space (Mathlib: `ultrafilter_compact`) and the topological Konig's lemma (`TopCat.nonempty_limitCone_of_compact_t2_cofiltered_system`) to extract a temporally coherent chain.

**Mathematical Analysis**:
- `ultrafilter_compact : CompactSpace (Ultrafilter alpha)` is in Mathlib
- The space of ultrafilters on `LindenbaumAlg` forms a compact Hausdorff space (Stone space)
- R_G is already defined on ultrafilters (UltrafilterChain.lean:67)
- R_G is reflexive and transitive (proven sorry-free)
- The set of "coherent paths" (infinite R_G-chains satisfying F-resolution) can be formulated as a closed subset of the product space

**Obstacle**: The topological Konig requires a cofiltered diagram of compact Hausdorff spaces with continuous maps. Constructing this diagram from the chain requirement is non-trivial. Moreover, extracting formula-level membership from ultrafilter-level properties requires the representation theorem (ultrafilter membership <-> formula membership), which is itself part of the algebraic machinery.

**Viability**: LOW-MEDIUM. While mathematically elegant, the categorical/topological overhead is substantial and would require significant new Lean infrastructure. The ultrafilter approach trades one complexity (F-persistence) for another (category theory plumbing).

**Effort**: 25-40 hours

### Approach 3: Finite Tree + Konig's Lemma on DRM Space

**Concept**: Work entirely within the DRM (DeferralRestrictedMCS) space, which is FINITE for a given phi. Build a finitely-branching tree of DRM chain prefixes and use Konig's lemma to extract an infinite path.

**Mathematical Analysis**:
- `deferralClosure(phi)` is a `Finset Formula` (finite by construction)
- The number of DeferralRestrictedMCS over phi is bounded by `2^|deferralClosure(phi)|`
- Each DRM has finitely many restricted successors
- Konig's lemma: `exists_seq_forall_proj_of_forall_finite` (Mathlib.Order.KonigLemma)

**Obstacle**: This is exactly what `build_restricted_tc_family` already does! The restricted chain construction IS the finite-tree path extraction, already sorry-free. The problem is not building the restricted chain -- it's lifting it to a full MCS chain. Konig on the DRM space doesn't help with the lifting problem.

**Viability**: LOW (already done at the DRM level; doesn't address the actual gap)

**Effort**: N/A (redundant with existing infrastructure)

### Approach 4: Constrained Lindenbaum Extension

**Concept**: Instead of independent Lindenbaum extensions at each time point, use a CONSTRAINED extension that preserves G-theory compatibility between adjacent time points.

**Mathematical Analysis**:
- Standard Lindenbaum: extend consistent set S to MCS by enumerating formulas and adding each if consistent
- Constrained Lindenbaum: at time n+1, extend `restricted_chain(n+1)` to MCS while ensuring `g_content(ext(n)) subset ext(n+1)` and `h_content(ext(n+1)) subset ext(n)`
- The constraint `g_content(ext(n)) subset ext(n+1)` means: for each G(a) in ext(n), ensure a is in ext(n+1)
- Since ext(n) is built first (inductively), g_content(ext(n)) is known
- The seed for ext(n+1) is `restricted_chain(n+1) union g_content(ext(n))`

**Key question**: Is `restricted_chain(n+1) union g_content(ext(n))` consistent?
- restricted_chain(n+1) is consistent (it's a DRM)
- g_content(ext(n)): for each G(a) in ext(n), a is in the g_content
- By the Succ relation between chain(n) and chain(n+1), g_content(chain(n)) subset chain(n+1) (g_persistence, sorry-free)
- But g_content(EXT(n)) is larger than g_content(chain(n)) -- the extension adds arbitrary G-formulas

**Sub-question**: Can we show `g_content(ext(n)) union restricted_chain(n+1)` is consistent?
- The G-lift argument: if ext(n) is MCS and G(a) in ext(n), then G(G(a)) in ext(n) by temp_4. So G(a) is G-liftable. Thus g_content(ext(n)) subset temporal_box_seed(ext(n)).
- temporal_theory_witness_consistent shows {target} union temporal_box_seed(M) is consistent when F(target) in M
- But we need g_content(ext(n)) union chain(n+1) consistent, not {target} union temporal_box_seed
- Different seed structure; the existing consistency argument doesn't directly apply

**Alternative**: Build ext(n+1) as the Lindenbaum extension of `chain(n+1) union {a | G(a) in ext(n)}`. Consistency: by `g_content_subset_implies_h_content_reverse`, if g_content(M) subset N for MCS M, N, then h_content(N) subset M. This is a DUALITY theorem, not a consistency theorem for the seed.

**Viability**: MEDIUM. The constrained Lindenbaum approach is mathematically correct but requires a new consistency argument for the augmented seed. This is doable if we can show that `chain(n+1) union g_content(ext(n))` is consistent by leveraging the Succ relation and the fact that g_content(chain(n)) subset chain(n+1).

**Effort**: 12-20 hours

### Approach 5: Quotient by Closure-Irrelevant Differences

**Concept**: Since the truth lemma only needs equivalence for formulas in `subformulaClosure(phi)`, define an equivalence relation on MCS where M ~ N iff M intersect deferralClosure(phi) = N intersect deferralClosure(phi). Work in the quotient.

**Mathematical Analysis**:
- Two MCS are equivalent iff they agree on all closure formulas
- The DRM IS the equivalence class representative (it's exactly M intersect deferralClosure)
- The restricted chain already works at this quotient level
- The truth lemma for closure formulas depends only on the equivalence class

**This is exactly what the restricted truth lemma already does!** The restricted_truth_lemma shows `psi in chain(n) <-> psi in ext(n)` for closure formulas, which means the DRM and its Lindenbaum extension are in the same equivalence class for closure-relevant purposes.

**Viability**: LOW (already captured by existing infrastructure)

---

## Mathlib Infrastructure

### Directly Relevant Lemmas

| Lemma | Module | Relevance |
|-------|--------|-----------|
| `ultrafilter_compact` | `Mathlib.Topology.Algebra.Order.Compact` | Compactness of ultrafilter space |
| `exists_seq_forall_proj_of_forall_finite` | `Mathlib.Order.KonigLemma` | Projective system Konig |
| `TopCat.nonempty_limitCone_of_compact_t2_cofiltered_system` | `Mathlib.Topology.Category.TopCat.Limits.Konig` | Topological Konig |
| `Finset.strongInduction` | `Mathlib.Data.Finset.Card` | Strong induction on finite sets |
| `Function.minimalPeriod_le_card` | `Mathlib.Dynamics.PeriodicPts.Lemmas` | Periodicity bound by cardinality |
| `Set.exists_ne_map_eq_of_ncard_lt_of_maps_to` | `Mathlib.Data.Set.Card` | Pigeonhole for sets |

### Existing Project Infrastructure (Sorry-Free)

| Component | Location | What It Provides |
|-----------|----------|-----------------|
| `build_restricted_tc_family` | SuccChainFMCS.lean:6313 | Sorry-free RestrictedTemporallyCoherentFamily |
| `restricted_truth_lemma` | RestrictedTruthLemma.lean:291 | DRM <-> ext equivalence for closure formulas |
| `restricted_chain_subset_extended` | RestrictedTruthLemma.lean:218 | DRM embeds in Lindenbaum extension |
| `extended_chain_closure_subset` | RestrictedTruthLemma.lean:235 | Extension projects back to DRM for closure formulas |
| `restricted_ext_neg_excludes_phi` | RestrictedTruthLemma.lean:381 | Completeness bridge |
| `restricted_forward_chain_F_resolves` | SuccChainFMCS.lean:3230 | F resolves in ONE step in DRM chain |
| `restricted_forward_chain_f_content_persistence` | SuccChainFMCS.lean:3216 | f_content(chain(n)) subset chain(n+1) |
| `g_content_subset_implies_h_content_reverse` | (TemporalContent) | G/H duality |

---

## Recommended Approach

**Approach 1 (Direct Restricted Completeness)** is the most promising, with Approach 4 (Constrained Lindenbaum) as fallback.

### Rationale

1. **Approach 1 avoids the 4 sorries entirely** by proving completeness via a different path that doesn't need `succ_chain_restricted_forward_F`. The existing sorry-free infrastructure (`build_restricted_tc_family` + `restricted_truth_lemma` + `restricted_ext_neg_excludes_phi`) provides 90% of what's needed.

2. **The remaining 10% is the parametric truth lemma adaptation.** The current `ParametricTruthLemma` requires a full FMCS with forward_G/backward_H for ALL formulas. The restricted version only has these for closure formulas. The truth lemma needs to be shown to only USE forward_G/backward_H on subformulas (which are in the closure).

3. **This is exactly what Report 20 (team synthesis) identified**: "A's alternative fix is correct. The truth lemma's forward G case applies g_persistence one step at a time, never requiring G(G(chi))."

4. **If Approach 1 fails**, Approach 4 (Constrained Lindenbaum) provides a fallback by constructing extensions that DO preserve G-theory between adjacent time points. This requires a new consistency argument but is mathematically sound.

### Concrete Next Steps for Approach 1

1. **Verify that `restricted_chain_G_step` (line 71-78) is genuinely sorry-free.** It is -- it uses `h_succ.g_persistence` directly. The sorry is in `restricted_chain_G_propagates` (multi-step propagation), which is NOT needed if the truth lemma only uses single-step G.

2. **Analyze the parametric truth lemma's actual use of forward_G.** The forward_G case (G(psi) in M_t -> psi in M_s for all s >= t) is used in the truth lemma. But by structural induction, psi is a strict subformula of G(psi). So `psi in subformulaClosure(phi)` whenever `G(psi) in subformulaClosure(phi)`. The single-step G (G(psi) in chain(n) -> psi in chain(n+1)) combined with induction gives multi-step propagation for subformulas -- but this induction is on the chain steps (Int), not on formula structure, and IS what `restricted_chain_G_propagates` attempts.

3. **The actual fix**: The sorry in `restricted_chain_G_propagates` is at the `n < m` case. The proof needs G(psi) in chain(n) -> psi in chain(m). With single-step G, we get psi in chain(n+1). But to get psi in chain(n+2), we need G(psi) in chain(n+1), which requires G(G(psi)) in chain(n). This is the iterated G problem.

4. **Resolution**: The truth lemma doesn't need G-propagation through the DRM chain. It needs G-propagation through the EXTENDED chain. If G(psi) in ext(n), then G(psi) in ext(n+1) (by forward_G of the full MCS -- BUT we don't have forward_G for the extended chain since extensions are independent). This circles back to the original problem.

5. **The real resolution** (from Report 20, A's fix): The truth lemma for G(chi) at time t only needs chi in chain(s) for all s >= t. By structural induction, we have the IH for chi. At each s, either chi in chain(s) (done) or neg(chi) in chain(s). If neg(chi) in chain(s) for some s >= t, then by the IH, neg(chi) is true at s. But G(chi) true at t means chi true at all s >= t, contradiction. So chi must be in chain(s) for all s >= t. This argument uses the SEMANTIC truth of G, not syntactic G-propagation.

**Bottom line**: The G-propagation sorry may be avoidable by restructuring the truth lemma to use semantic reasoning (IH + frame properties) rather than syntactic G-propagation through the chain.

---

## Evidence/Examples

### Sorry-Free F-Resolution Mechanism

The key algebraic mechanism in the restricted chain:

```lean
-- SuccChainFMCS.lean:3216-3234
-- f_content(chain(n)) subset chain(n+1)  [SORRY-FREE]
-- Therefore: F(psi) in chain(n) -> psi in chain(n+1)  [ONE STEP]
```

This works because `constrained_successor_restricted` includes `f_content` in the seed, and `deferralClosure` bounds F-nesting depth. The unrestricted chain uses `constrained_successor_from_seed` which only gives weak f-step (f_content subset M' union f_content(M')), allowing perpetual deferral.

### G(G(chi)) Problem (RestrictedTruthLemma.lean:104-106)

```
-- The issue: G(psi) in chain(n) -> G(psi) in chain(n+1) requires G(G(psi)) in chain(n),
-- which in turn requires G(G(psi)) in deferralClosure. But deferralClosure is bounded
-- by the formula structure of phi, and G(G(psi)) may exceed that bound.
```

### Why Dovetailed Fair Scheduling Fails (DovetailedChain.lean:587-589)

```
-- THIS APPROACH FUNDAMENTALLY DOESN'T WORK for same-family forward_F with
-- Lindenbaum-based chains, because Lindenbaum can introduce G(neg(phi)) before
-- the scheduler gets to phi.
```

### Approaches Already Eliminated by Task 81

| Approach | Why It Fails | Report |
|----------|-------------|--------|
| Arbitrary Lindenbaum + fair scheduling | F-persistence fails; Lindenbaum can kill F-obligations | DovetailedChain.lean, Report 13 |
| Include all F-obligations in seed | Seed inconsistent when F(A) and F(neg(A)) coexist | Report 13 Q1 |
| G-lift F-formulas | F = neg(G(neg(...))); G(F(psi)) = G(neg(G(neg(psi)))) not in M | Report 13 Q5 |
| f_nesting_is_bounded for arbitrary MCS | Proven FALSE | SuccChainFMCS.lean (cleanup notes) |
| Bundle-level coherence suffices | Truth lemma is inherently bidirectional; backward G requires forward_F | RestrictedTruthLemma.lean:400-407 |
| Forward-only truth lemma | imp case requires backward direction for antecedent | UltrafilterChain.lean:3570-3581 |

---

## Confidence Level

**MEDIUM (55-65%)**

**Justification**: The recommended approach (direct restricted completeness) requires showing that the parametric truth lemma can be adapted to use only restricted temporal coherence. The mathematical argument is sound (subformula closure containment guarantees all recursive truth lemma calls stay within the closure), but the Lean formalization requires careful restructuring of the truth lemma infrastructure. The 35-45% risk comes from:

1. The truth lemma may have hidden dependencies on full G-propagation that aren't visible from the type signatures alone
2. The constrained Lindenbaum fallback (Approach 4) requires a new consistency argument that hasn't been attempted
3. Independent Lindenbaum extensions fundamentally break G-coherence for non-closure formulas, and it's not yet verified that the truth lemma truly never needs this

The highest-confidence sub-finding is that **the 2 RestrictedTruthLemma sorries are NOT needed for the current infrastructure** (confidence: HIGH, 85%). They were marked pending Phase 4, and the restricted truth lemma is sorry-free without them.
