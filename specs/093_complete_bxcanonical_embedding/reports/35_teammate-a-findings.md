# Teammate A: Quasimodel Infrastructure Audit

## Executive Summary

The Quasimodel/ directory contains a well-developed but **incomplete** chain construction infrastructure. It builds Hintikka point chains with defect-discharge for Until/Since formulas, but the chains operate at the Hintikka abstraction level and are NOT directly connected to the `dd_fmcs` chain family used by `dd_countermodel`. The quasimodel chain does handle eventuality discharge, but only for **Until/Since formulas** (not raw F-formulas). The critical `forward_F` sorry is in `RootScopedChain.lean`, operating on a fundamentally different chain (`defect_fwd_chain` / `rr_fwd_chain`), not on the quasimodel chain.

---

## 1. Structures Defined in Quasimodel/

### SubformulaClosure.lean (114 LOC)
- **`subformulas : Formula -> Finset Formula`** -- recursive subformula extraction
- **`ghEnrichment : Finset Formula -> Finset Formula`** -- adds G(f), H(f) for each f
- **`SubformulaClosure : Formula -> Finset Formula`** -- full closure: ghEnrichment(subformulas(target)) union negation pairing
- All theorems fully proved (zero sorry). Key: `target_mem`, `neg_pairing`, `subformula_mem`, `g_enrichment_mem`, `h_enrichment_mem`.

### HintikkaPoint.lean (166 LOC)
- **`HintikkaPoint (Sigma : Finset Formula)`** -- structure with:
  - `formulas : Finset Formula` (subset of Sigma)
  - `subset_sigma`, `locally_consistent` (no f and neg f), `bot_free`, `locally_maximal` (for each f in Sigma, f or neg f present)
- **`sigma_signature_formulas`** -- projects a BXPoint to its Sigma-component
- **`sigma_signature`** -- constructs HintikkaPoint from BXPoint's Sigma-projection
- **Key theorem**: `sigma_signature_mem`: f in signature iff f in Sigma AND f in BXPoint
- All theorems fully proved. DecidableEq instance for HintikkaPoint.

### EnrichedClosure.lean (158 LOC)
- **`enrichedClosure : Formula -> Finset Formula`** -- Fisher-Ladner style: SubformulaClosure + G(neg(bigconj T)), H(neg(bigconj T)) for every subset T, closed under negation
- **`enrichedCore`** -- the pre-negation layer
- Key property: `enriched_neg_of_core_mem` (negation of core elements lands in closure)
- WARNING: Full negation pairing (`f in closure => neg f in closure`) does NOT hold for double-negated elements. The `sigma_signature_maximal` for enrichedClosure must be discharged directly from MCS negation-completeness.
- All theorems fully proved.

### Construction.lean (887 LOC) -- THE MAIN FILE
- **`hintikka_step`** -- one-step relation between HintikkaPoints:
  1. G-propagation: G(chi) in h1 => chi in h2
  2. H-backward: H(chi) in h2 => chi in h1
  3. Until defect propagation: (phi U psi) in h1, psi not in h1 => phi in h1 AND (phi U psi) in h2
- **`UntilDefect`**, **`SinceDefect`** -- defect predicates
- **`defect_count`**, **`untilDefectSet`**, **`sinceDefectSet`** -- counting
- **`hintikka_step_target_decrease`** -- defect count strictly decreases when witness reached (under monotonicity hypothesis)
- **`QuasimodelChain`** -- list of HintikkaPoints with target Until-defect
- **`WitnessedHintikka`** -- HintikkaPoint backed by a concrete BXPoint
- **`HintikkaStepOracle`** -- oracle that steps to next HintikkaPoint (either reaching witness or strictly decreasing defect count)
- **`HintikkaRawChain`** -- nonempty list with `List.IsChain hintikka_step`
- **`ChainWitnessed`** -- every point in chain is backed by a BXPoint
- **`hintikka_chain_exists`** (PROVED, ~70 LOC) -- given oracle + starting point with backing BXPoint, there exists a chain reaching the witness. Uses strong induction on `defect_count`.
- **`hintikka_chain_exists_since`** (PROVED) -- Since dual, extends chain on the right
- **`chain_step_seed_consistent`** (PROVED) -- any subset of a witnessed chain point's formulas is SetConsistent
- **MCS lemmas at BXPoint level**: `until_elim_mcs`, `self_accum_mcs`, `until_F_mcs`, `connect_future_mcs`, `refl_intro_until_mcs` + Since duals. ALL PROVED.
- **ALL SORRY-FREE**.

### Realization.lean (444 LOC)
- **`F_of_mem`** -- psi in w => F(psi) in w (proved)
- **`P_of_mem`** -- psi in w => P(psi) in w (proved)
- **`F_from_above`** -- bx_le w v, psi in v => F(psi) in w (proved)
- **`enriched_seed_consistent_until`** -- consistency of enriched seed {neg(phi U psi)} union g_content(w) union h_content(v) (proved, ~50 LOC)
- **`enriched_seed_consistent_since`** -- Since dual (proved)
- **`chain_step_seed_consistent_enriched`** -- enriched seed h.formulas union g_content(v) is consistent when chain is witnessed and bx_le holds (proved)
- **`chain_step_seed_consistent_enriched_since`** -- Since dual (proved)
- **Phase 5 analysis**: Documents G-persistence obstacle. hintikka_step gives G(chi) in h1 => chi in h2, but NOT G(chi) in h2. G-formulas do NOT persist through the chain.
- **`until_eventuality_resolution`** -- delegates to `bx_until_eventuality_resolution` from Frame.lean
- **`since_eventuality_resolution`** -- delegates to Frame.lean
- **ALL SORRY-FREE** (delegates proven content or documents obstacles in comments)

### LocusControl.lean (47 LOC)
- **`bx_until_eventuality_resolution'`** -- primed variant, delegates to Realization.lean
- **`bx_since_eventuality_resolution'`** -- primed variant
- Very thin delegation layer. ALL PROVED.

---

## 2. How Construction.lean Builds the Quasimodel

**Input**: A `HintikkaStepOracle` for (phi, psi) over a finite Sigma, a starting HintikkaPoint h0, and a backing BXPoint w0 with h0.formulas subset w0.formulas.

**Output**: `HintikkaRawChain` -- a nonempty list of HintikkaPoints where:
- head = h0
- last contains psi (the Until witness)
- consecutive pairs satisfy `hintikka_step`
- every point is `ChainWitnessed` (backed by a BXPoint)

**Construction**: Strong induction on `defect_count h0`.
- Base: psi already in h0 => singleton chain
- Step: Oracle gives next WitnessedHintikka. If psi reached, 2-point chain. Otherwise, recurse with strictly smaller defect count.

The oracle is NOT discharged in Construction.lean. It must be provided externally. **This is the key gap**: no oracle has been constructed.

---

## 3. How Realization.lean Extracts a Model

Realization.lean does NOT extract a chain from the quasimodel. Instead:
- `until_eventuality_resolution` and `since_eventuality_resolution` delegate directly to Frame.lean's `bx_until_eventuality_resolution` / `bx_since_eventuality_resolution`
- These Frame.lean functions are the original sorry targets that were subsequently proved

The quasimodel chain is NOT connected to the dd_fmcs chain. The chain produced by `hintikka_chain_exists` is a list of HintikkaPoints (finite Sigma-projections), not a chain of MCS/BXPoints.

**EXACT type signature of the chain Realization produces**: Realization does NOT produce a chain. It delegates to Frame.lean which produces an existential:
```
exists v : BXPoint, bx_le w v AND psi in v.formulas AND phi in w.formulas
```
This is a ONE-STEP witness, not a chain.

---

## 4. F-Defect Handling

**The quasimodel handles Until/Since defect discharge, NOT F-defects.**

The `hintikka_step` relation propagates G-content forward but does not directly handle F-formulas. F(psi) = neg(G(neg psi)) is NOT an Until formula; it is a derived modality. The quasimodel construction targets Until/Since eventuality discharge specifically.

**DefectChain.lean** (Filtration/) also tracks only Until/Since defects at the BXPoint level:
- `sigma_defect_count`: counts Until-defects in Sigma at a BXPoint
- `defect_step_phi`, `defect_step_F_psi`: properties at Until-defective points
- No F-defect tracking

---

## 5. What is DefectChain.lean?

`Filtration/DefectChain.lean` (137 LOC) defines:
- `is_until_defect`, `sigma_defect_count` -- Until-defect counting at BXPoint level (not HintikkaPoint level)
- `sigma_defect_count_bounded` -- bounded by |Sigma|
- `defect_step_phi` -- If phi U psi in w and psi not in w, then phi in w (from BX9)
- `defect_step_F_psi` -- phi U psi in w => F(psi) in w (from BX10)
- `defect_step_connect` -- phi U psi in w => G(P(phi U psi)) in w (from BX4)
- `defect_step_self_accum` -- BX5 self-accumulation
- Since duals: `since_defect_step_phi`, `since_defect_step_P_psi`, etc.
- ALL PROVED, zero sorry.

It tracks **only Until/Since defects**. No F-defect infrastructure.

---

## 6. What is SigmaOrdering.lean?

`Filtration/SigmaOrdering.lean` (179 LOC) defines Sigma-restricted ordering:
- **`sigma_le Sigma w v`**: for every G-formula G(f) in Sigma with G(f) in w, f in v. This is bx_le restricted to Sigma-formulas.
- **`sigma_strict Sigma w v`**: sigma_le w v AND exists distinguishing G-formula in Sigma present at v whose content is absent from w
- **`sigma_equiv Sigma w v`**: agreement on all Sigma-formulas
- Key theorems: `bx_le_implies_sigma_le`, `sigma_strict_irrefl`, `not_bx_le_of_sigma_strict`
- ALL PROVED. Relates to the finite graph structure by restricting the infinite bx_le to a finite formula set.

---

## 7. Connection to dd_fmcs

**There is NO direct connection between the quasimodel chain and dd_fmcs.**

The dd_fmcs chain family (RootScopedChain.lean) constructs:
- `rr_fwd_chain`: round-robin forward chain using `enriched_fwd_step` with BX11 fold
- `rr_bwd_chain`: backward chain using `bwd_pred`
- `dd_chain`: combines forward/backward indexed by Int
- `dd_fmcs`: wraps as FMCS (family of MCS indexed by Int)

The quasimodel chain operates at the HintikkaPoint level over a finite Sigma. The dd_fmcs chain operates at the MCS level over the full formula language.

**Key gap**: No bridge lemma connects HintikkaRawChain to dd_fmcs.

---

## 8. Key Bridge Lemmas Needed

To connect quasimodel output to RootScopedChain sorry sites, the following would be needed:

### For forward_F (the primary blocker):
1. **Oracle construction**: Build a `HintikkaStepOracle` for F-formulas (not Until). This is fundamentally different because F(psi) is not an Until-formula; `hintikka_step` does not have an F-defect propagation clause.
2. **Chain lifting**: Given a HintikkaRawChain, lift it to a chain of BXPoints with bx_le between consecutive points. This faces the **G-persistence obstacle** documented in Realization.lean:370-395: G-formulas propagate one step (chi in h2) but do NOT persist (G(chi) in h2 not guaranteed).
3. **Chain embedding**: Embed the lifted chain into the dd_fmcs schedule. The dd_fmcs uses a specific round-robin schedule; the quasimodel chain has its own structure.

### Why this is hard:
- The quasimodel's `hintikka_step` tracks Until/Since defects, not F-defects
- F(psi) = neg(G(neg(psi))) requires different defect-discharge logic
- The G-persistence obstacle blocks multi-step chain lifting even for Until
- The dd_fmcs schedule (enriched_fwd_step with BX11 fold) is different from the quasimodel step oracle

---

## 9. Sorry-Free Status

**ALL files in Quasimodel/ are completely sorry-free:**
- SubformulaClosure.lean: 0 sorry
- HintikkaPoint.lean: 0 sorry
- EnrichedClosure.lean: 0 sorry
- Construction.lean: 0 sorry (including hintikka_chain_exists, the main theorem)
- Realization.lean: 0 sorry (delegates to Frame.lean which is also sorry-free for these lemmas)
- LocusControl.lean: 0 sorry

**All files in Filtration/ are sorry-free:**
- DefectChain.lean: 0 sorry
- SigmaOrdering.lean: 0 sorry

**The sorry sites are all in RootScopedChain.lean:**
- `rr_fwd_chain_forward_F` line 1413: depth-0 base case of forward_F (THE primary blocker)
- `dd_fmcs_forward_F` line 1457: t < 0 case (depends on above)
- `dd_fmcs_backward_P` line 1464: backward P dual
- `dd_bfmcs_restricted_tc` line 1517: restricted temporal coherence
- `dd_bfmcs_restricted_buc` line 1522: restricted backward Until/Since coherence
- `dd_bfmcs_restricted_fuc` line 1527: restricted forward Until/Since coherence
- `defect_fwd_chain_forward_F` line 2196: alternative chain forward_F
- `defect_bwd_chain_backward_P` line 2289: alternative chain backward_P

---

## 10. Exact Type Signature of Chain Output

The quasimodel chain produces:
```lean
exists c : HintikkaRawChain Sigma,
  c.head = h0 AND psi in c.last.formulas AND ChainWitnessed c
```

Where:
- `HintikkaRawChain Sigma` has `points : List (HintikkaPoint Sigma)`, `nonempty`, `is_chain : points.IsChain hintikka_step`
- `ChainWitnessed c` means `forall h in c.points, exists w : BXPoint, forall f in h.formulas, f in w.formulas`

This does NOT produce:
- A chain of BXPoints with bx_le relations
- An Int-indexed FMCS
- Anything directly usable by dd_countermodel

---

## Recommended Approach

### Assessment: Quasimodel bridge is NOT the right path for forward_F

The quasimodel infrastructure is well-built but fundamentally targets **Until/Since defect discharge**, not **F-formula resolution**. Trying to bridge it to forward_F would require:

1. A new defect type for F-formulas in `hintikka_step` (major redesign of Construction.lean)
2. Solving the G-persistence obstacle for chain lifting (documented as unsolved in Realization.lean)
3. Embedding the lifted chain into the dd_fmcs schedule (non-trivial new infrastructure)

**Estimated cost**: 1200-1800 new LOC with significant mathematical risk.

### Alternative: Fix forward_F directly in the dd_fmcs chain

The `defect_fwd_chain` approach (RootScopedChain.lean:2056-2196) is closer to viable:
- It already has F-obligation persistence (`defect_fwd_chain_F_obligation_persists`)
- It already has defect step choice with witness resolution (`defect_fwd_step_choice_singleton`)
- The sorry at line 2196 is the only gap

The key insight for `defect_fwd_chain_forward_F`:
- When defects = [psi] (single element), `h_all` trivially holds at step n (since F(psi) in chain(n) is the hypothesis)
- `defect_fwd_step_choice_singleton` gives psi in chain(n+1)
- For multi-defect case: project to single-defect chain [psi]

However, the projection approach has a subtle problem: `defect_fwd_chain M0 h0 [psi]` is a DIFFERENT chain than `defect_fwd_chain M0 h0 defects`. The two chains diverge at step 1 because different Lindenbaum extensions are chosen.

### Most Promising Path

The `self_resolving_fwd_step` infrastructure (RootScopedChain.lean:1961-1996) provides the clearest single-defect resolution:
- Given F(psi) in M, builds M' with psi in M', F(psi) in M', g_content(M) subset M'
- This is a one-step F-resolution that immediately places psi in the next MCS

**For `defect_fwd_chain_forward_F` with singleton defects = [psi]**:
1. F(psi) in chain(n) by hypothesis
2. h_all holds trivially (only defect is psi, and F(psi) in chain(n))
3. `defect_fwd_step_choice_singleton` gives psi in chain(n+1)
4. Witness: s = n+1

**For the general multi-defect case**: The challenge is that defect_fwd_step_choice may resolve a different defect w != psi. But F(psi) persists to chain(n+1). Repeat. Eventually psi must be resolved because defect_step_from_earliest cycles through defects (it always picks defects.head as target). Since sigma_list is finite and fixed, after at most |sigma_list| + 1 steps, defects.head = psi must be targeted and resolved.

**This counting argument is the key missing piece. It requires showing that `defect_fwd_step_choice` eventually targets psi.** The current `pick_bx11_earliest` always picks `defects.head`, which is fixed across all steps. If psi = defects.head, resolution happens at step n+1. If psi != defects.head, the head gets resolved first, but then the chain still has F(psi) active. The issue: the defect list is FIXED (not shrinking), so the head is always the same. The BX11 fold may always resolve the head, never psi.

### Root Cause of the Obstruction

The **perpetual deferral** problem: With a fixed defect list, `defect_fwd_step_choice` at each step resolves `defects.head` (via `pick_bx11_earliest`) and preserves F-obligations for all others. But it never targets psi (if psi != defects.head). The BX11 fold resolves the target it's given, not an arbitrary defect.

**The fix**: Either (a) make the defect list shrink after each resolution (track which defects have been resolved and exclude them), or (b) rotate the target selection so every defect eventually gets targeted, or (c) use a completely different construction that doesn't suffer from perpetual deferral.

## Evidence/Examples

- G-persistence obstacle: `Realization.lean:370-395`
- forward_F sorry: `RootScopedChain.lean:2196`
- Depth-0 sorry: `RootScopedChain.lean:1413`
- Perpetual deferral documentation: `RootScopedChain.lean:1280-1285`
- Self-resolving step: `RootScopedChain.lean:1961-1996`
- Quasimodel chain existence: `Construction.lean:594-660`
- defect_fwd_chain: `RootScopedChain.lean:2056-2069`
- defect_fwd_step_choice_singleton: `RootScopedChain.lean:2161-2170`

## Confidence Level

**HIGH** confidence in the infrastructure audit (every file read completely, all definitions and theorems cataloged).

**MEDIUM** confidence in the recommended approach assessment. The quasimodel bridge path is clearly not the right fit (it targets Until/Since, not F). The defect_fwd_chain path with rotating target selection is promising but requires careful analysis of whether `resolving_enriched_fwd_exists` can be parameterized to target a specific formula from the defect list rather than always defaulting to the head.

**LOW** confidence that any approach avoids the perpetual deferral obstruction without a fundamental redesign of the chain step selection mechanism. The existing `pick_bx11_earliest` always returns `defects.head`, which is the root cause of the problem for non-head defects.
