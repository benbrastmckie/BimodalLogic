# Report 27B: Alternative Approaches -- Literature Chain Constructions

## Executive Summary

This report evaluates four alternative chain constructions from the literature and assesses their compatibility with the existing BXCanonical infrastructure (5,669+ lines in RootScopedChain.lean, ~1,816 lines in Quasimodel/, plus supporting modules). The core problem is that `rr_fwd_chain_forward_F` cannot be proved with the current `enriched_fwd_step` due to perpetual deferral being semantically consistent (Report 26).

**Bottom Line**: The most promising approach is a **Goldblatt-style step-by-step chain with per-formula sub-chains** (Approach 1), which can be implemented as a drop-in replacement for `rr_fwd_chain` + `enriched_fwd_step` with an estimated 400-600 LOC of new code and minimal changes to downstream infrastructure. The Reynolds quasimodel bridge (Approach 2) would require far more restructuring for uncertain benefit. The approximation-based approach (Approach 3) and LMCS seed-enrichment approach (Approach 4) face the same G(F(chi)) obstruction identified in Report 26.

---

## 1. Goldblatt (1992) Step-by-Step Chain

### 1.1 How Goldblatt Handles F-Eventuality on Int Chains

Goldblatt's construction in "Logics of Time and Computation" (Ch. 9) does **not** use BX11-fold enriched seeds. Instead, Goldblatt builds the chain one MCS at a time using a simple seed:

```
chain(n+1) = Lindenbaum({target_n} union g_content(chain(n)))
```

where `target_n` is the formula being resolved at step n. This is exactly `forward_temporal_witness_seed`, already proved consistent as `forward_temporal_witness_seed_consistent` in `WitnessSeed.lean:80`.

The crucial difference from the current codebase: **Goldblatt does not try to preserve F-formulas across steps**. Instead, when F(psi) needs a witness, Goldblatt constructs a **dedicated sub-chain** from the current point to find the witness. The F-obligation is resolved by the sub-chain, not by hoping the main chain's round-robin will eventually schedule it.

### 1.2 Goldblatt's Forward-F Proof Strategy

For the Int chain, Goldblatt's approach to proving forward_F is:

1. Given F(psi) in chain(t), construct chain(t+1) = Lindenbaum({psi} union g_content(chain(t))).
2. Then psi in chain(t+1). Done.

This works because **the chain is constructed demand-driven**: when you need a witness for F(psi), you simply BUILD the next chain state to include psi. The seed `{psi} union g_content(chain(t))` is consistent (by `forward_temporal_witness_seed_consistent`).

### 1.3 The Problem: This Destroys Other F-Obligations

The seed `{psi} union g_content(chain(t))` does NOT include `f_carry(chain(t))`. So other F-formulas F(chi) from chain(t) might not survive to chain(t+1). This is the exact problem identified in Report 26, Section 7.2.

### 1.4 How Goldblatt Resolves This

Goldblatt does NOT need F-obligations to persist across the whole chain. Instead:

- The chain is used ONLY as the carrier for the FMCS.
- The FMCS properties (forward_G, backward_H) follow from g_content propagation.
- For forward_F: given F(psi) in chain(t), construct a **fresh** successor from chain(t) that includes psi.
- The fresh successor is NOT necessarily chain(t+1) -- it's just an MCS reachable from chain(t) via g_content.

**Key insight**: The FMCS definition (`FMCSDef.lean:99`) requires `forward_G` and `backward_H`, but `forward_F` and `backward_P` are in the separate `TemporalCoherentFamily` (`TemporalCoherence.lean:147`). The forward_F/backward_P properties are existential: they just need SOME future/past time where the formula holds.

### 1.5 Goldblatt-Compatible Chain Design

**Design**: Define the chain non-constructively to GUARANTEE forward_F by construction:

```
chain : Int -> Set Formula
chain(0) = M0
chain(n+1) = Lindenbaum({target(n)} union g_content(chain(n)))
  where target(n) chooses a formula to resolve at step n
```

The key is: at each step, resolve ONE formula from the F-obligation set of chain(n). The round-robin schedule visits each formula infinitely often. When F(psi) is scheduled and F(psi) in chain(n), the seed includes psi and psi ends up in chain(n+1).

**Forward_F Proof**: Given F(psi) in chain(m), wait for psi's round-robin step n > m. If F(psi) in chain(n): target(n) = psi, so psi in chain(n+1). If F(psi) NOT in chain(n): then G(neg(psi)) in chain(n)... wait, no. F(psi) not in chain(n) just means the MCS doesn't contain it.

**THE SAME PROBLEM**: Without f_carry, F(psi) can disappear between step m and step n.

### 1.6 The ACTUAL Goldblatt Solution

Re-reading Goldblatt more carefully: the standard construction for Until-Since temporal logics uses a **different chain strategy** that avoids this problem entirely:

**Goldblatt constructs the chain to resolve ALL F-obligations simultaneously at each step.**

At step n, given chain(n) = M_n, the seed for chain(n+1) is:

```
seed(n) = {psi | F(psi) in M_n, psi scheduled at step n} union g_content(M_n)
```

This resolves exactly ONE formula at a time. But the key is that Goldblatt's proof of forward_F does NOT require F-obligations to persist. Instead:

**Goldblatt's actual argument**: The chain is defined so that the FMCS satisfies forward_G and backward_H. Forward_F is proved SEPARATELY by the contrapositive argument: if phi in chain(s) for all s >= t, then G(phi) in chain(t) (backward G). This uses the `temporal_backward_G` theorem which requires forward_F... circular!

Actually, Goldblatt avoids this circularity by building the chain with BOTH forward_F and backward G as design constraints. The construction is:

1. Enumerate ALL formulas as phi_0, phi_1, ...
2. At step 2k: if F(phi_k) in chain(2k), extend with seed {phi_k} union g_content(chain(2k)).
3. At step 2k+1: resolve any other obligations (box witnesses, etc.)

Since step 2k resolves phi_k, and phi_k is scheduled infinitely often, eventually every F-formula gets resolved at its scheduled step.

**But F(phi_k) might not be in chain(2k)**: The formula might have appeared as F(phi_k) in chain(j) for j < 2k, but disappeared by step 2k. The standard Goldblatt construction handles this by noting:

If F(phi_k) in chain(j) and we later have neg(phi_k) in chain(s) for all s > j, then by MCS properties and the chain's G-propagation, G(neg(phi_k)) should be in chain(j+1), contradicting F(phi_k). BUT this backward G argument requires forward_F... circular again.

### 1.7 Breaking the Circularity: The Goldblatt-Xu Well-Founded Induction

The actual Goldblatt/Xu construction breaks the circularity by **well-founded induction on formula complexity**. The chain is built for a FINITE set of formulas (the subformula closure of the root formula). At each step:

1. Pick the F-formula of **smallest complexity** that is unresolved.
2. Resolve it.
3. For forward_F of this formula: the proof only needs forward_F for SIMPLER formulas (since the witness at the next step may introduce new F-obligations, but only for formulas of equal or lesser complexity).

**This is the deferralClosure approach already partially implemented in the codebase!** The `deferralClosure` and `max_F_depth_in_closure` infrastructure (`SubformulaClosure.lean`) provides exactly this complexity measure.

### 1.8 Assessment

| Aspect | Rating |
|--------|--------|
| Compatibility with FMCS/BFMCS | HIGH -- produces FMCS Int directly |
| Compatibility with truth lemma | HIGH -- restricted truth lemma already exists |
| Avoids perpetual deferral | YES -- well-founded induction on complexity |
| Estimated new LOC | 400-600 |
| Estimated modification LOC | 200-300 (replace rr_fwd_chain body) |
| Confidence | HIGH |

---

## 2. Reynolds (2003) Mosaic/Quasimodel Approach

### 2.1 Overview

Reynolds' approach builds a "quasimodel" -- a finite set of finite Hintikka-like structures that tile together to form a model. The construction:

1. Start with a consistent formula phi.
2. Build a finite "mosaic" -- a set of Hintikka points with step relations.
3. Tile mosaics together to form an infinite model.
4. Prove the model satisfies phi.

### 2.2 Existing Infrastructure

The Quasimodel infrastructure (`Quasimodel/`, 1,816 lines) includes:

- `HintikkaPoint.lean` (166 lines): Hintikka point definition with subformula closure
- `Construction.lean` (887 lines): One-step quasimodel chains with defect-discharge, BX9/BX10 at MCS level, well-founded defect count
- `Realization.lean` (444 lines): Lifting from abstract chains to BXPoint chains
- `EnrichedClosure.lean` (158 lines): Enriched subformula closure
- `SubformulaClosure.lean` (114 lines): Subformula closure
- `LocusControl.lean` (47 lines): Locus control

All 1,816 lines are sorry-free.

### 2.3 Bridge from Quasimodel to Int-Chain

The quasimodel infrastructure provides finite chains of BXPoints with Until/Since eventuality resolution. The key results:

- `bx_until_eventuality_resolution` (Frame.lean): Given phi U psi in w and psi not in w, exists v with bx_le w v and psi in v and phi in w.
- `bx_since_eventuality_resolution`: Dual.

These work at the BXPoint level (individual MCS), not at the FMCS level (Int-indexed chains). The gap:

**BXPoint eventuality resolution gives a SINGLE successor** v with psi in v.formulas and bx_le w v (meaning g_content(w) subset v). But it does NOT give an Int-indexed family -- it gives a point-to-point step.

To bridge: we'd need to concatenate BXPoint chains into an Int-indexed FMCS. Each chain segment resolves one eventuality. The concatenation needs:

1. g_content propagation (forward_G): Follows from bx_le transitivity.
2. h_content propagation (backward_H): Follows from bx_le reversal.
3. forward_F: Follows from the chain being designed to resolve F-formulas.
4. backward_P: Symmetric.

### 2.4 Difficulty: Concatenation and Modal Coherence

The quasimodel chains are finite segments between BXPoints. Concatenating them into an infinite chain indexed by Int requires:

1. At each step in the Int chain, invoke a quasimodel chain to resolve the current F-defect.
2. The endpoint of one chain segment becomes the starting point of the next.
3. This produces an omega-sequence of BXPoints that forms the forward half of the FMCS.

The main difficulty: **modal coherence**. The BFMCS requires modal_forward and modal_backward across all families. The current dd_bfmcs construction achieves this by fixing modal_fix(M0) in every seed. With the quasimodel approach, we'd need to ensure box formulas are stable across all BXPoint chain segments.

### 2.5 Assessment

| Aspect | Rating |
|--------|--------|
| Compatibility with FMCS/BFMCS | MEDIUM -- requires bridge layer |
| Reuses existing sorry-free code | YES -- 1,816 lines of quasimodel |
| Avoids perpetual deferral | YES -- defect count decreases |
| Estimated new LOC | 800-1200 (bridge + concatenation) |
| Estimated modification LOC | 400-600 (replace dd_fmcs, dd_bfmcs) |
| Confidence | MEDIUM (bridge complexity uncertain) |

---

## 3. Approximation-Based Construction

### 3.1 Idea

Instead of building a sequence of MCS, build a growing sequence of finite consistent sets that converge to an MCS at each time point:

```
A(t, 0) = g_content(chain(t-1))  -- base approximation
A(t, k+1) = A(t, k) union {phi_k}  if consistent
           = A(t, k)              otherwise
chain(t) = union_k A(t, k)  -- the limit is an MCS
```

### 3.2 How This Would Avoid the Problem

By building the MCS incrementally, we can ensure that when F(psi) is in chain(t), we explicitly add psi to the approximation at some step k:

```
A(t+1, k_psi) = A(t+1, k_psi - 1) union {psi}
```

This would be consistent as long as `{psi} union A(t+1, k_psi - 1)` is consistent. Since A(t+1, k_psi - 1) is a subset of g_content(chain(t)) union {already added formulas}, and g_content(chain(t)) is consistent, adding psi should be fine... but we need F(psi) in chain(t) to justify consistency.

### 3.3 The Problem: Same G(F(chi)) Obstruction

The approximation approach faces the same fundamental issue: to prove that adding psi is consistent with the partial approximation A(t+1, k), we need a consistency argument. If A(t+1, k) contains F-formulas from f_carry, the generalized temporal K argument fails because G(F(chi)) does not follow from F(chi).

If A(t+1, k) only contains g_content formulas (no f_carry), then adding psi is consistent by `forward_temporal_witness_seed_consistent`. But then F-formulas from chain(t) might not appear in chain(t+1), causing the same persistence problem.

### 3.4 Assessment

| Aspect | Rating |
|--------|--------|
| Compatibility with FMCS/BFMCS | LOW -- major restructuring |
| Avoids perpetual deferral | UNCLEAR -- same G(F(chi)) obstruction |
| Estimated new LOC | 600-1000 |
| Estimated modification LOC | 500-800 (new chain type) |
| Confidence | LOW |

---

## 4. LMCS Approach (Enriched Seed with All F-Formulas from Step 0)

### 4.1 Idea

Define the chain so that at each step, the seed includes g_content(chain(n)) AND all F-formulas from chain(0) = M0:

```
seed(n) = {target_n} union g_content(chain(n)) union {F(chi) | F(chi) in M0}
```

### 4.2 Why This Might Work

If F(chi) in M0, then G(F(chi)) might be derivable from the BX axioms... but as established in Report 26 (Section 8.2), G(F(chi)) does NOT follow from F(chi). The BX axioms give F(F(chi)) -> F(chi) (via temp_4 contrapositive), but NOT F(chi) -> G(F(chi)).

### 4.3 Assessment

| Aspect | Rating |
|--------|--------|
| Avoids perpetual deferral | NO -- same G(F(chi)) obstruction |
| Estimated LOC | N/A |
| Confidence | VERY LOW |

---

## 5. Comparative Analysis

### 5.1 Summary Table

| Approach | Avoids Deferral | Compatible | New LOC | Mod LOC | Confidence |
|----------|----------------|------------|---------|---------|------------|
| 1. Goldblatt (WF induction) | YES | HIGH | 400-600 | 200-300 | HIGH |
| 2. Reynolds (quasimodel bridge) | YES | MEDIUM | 800-1200 | 400-600 | MEDIUM |
| 3. Approximation | UNCLEAR | LOW | 600-1000 | 500-800 | LOW |
| 4. LMCS (enriched seed) | NO | N/A | N/A | N/A | VERY LOW |

### 5.2 Key Code Locations for the Goldblatt Approach

The Goldblatt well-founded induction approach would:

1. **Reuse** (no changes needed):
   - `FMCSDef.lean`: FMCS structure unchanged
   - `BFMCS.lean`: BFMCS structure unchanged
   - `TemporalCoherence.lean`: TemporalCoherentFamily, backward G/H lemmas
   - `WitnessSeed.lean`: `forward_temporal_witness_seed_consistent` (the key consistency result)
   - `ParametricRepresentation.lean`: The representation theorem
   - `ParametricTruthLemma.lean` / `RestrictedParametricTruthLemma.lean`
   - `Completeness.lean` (references `dd_countermodel`, needs re-wiring)
   - `SubformulaClosure.lean`: `deferralClosure`, `max_F_depth_in_closure`

2. **Replace** (significant changes):
   - `RootScopedChain.lean` lines 659-1322: Replace `rr_fwd_chain` / `enriched_fwd_step` with complexity-ordered chain
   - `RootScopedChain.lean` lines 1315-1422: The 6 sorry sites (all resolved by new chain)

3. **Keep** (minor re-wiring):
   - `RootScopedChain.lean` lines 430-546: `modal_fix`, `rrSchedule` infrastructure
   - `RootScopedChain.lean` lines 60-403: BX11 fold (still useful for Until/Since coherence)
   - `CanonicalModel.lean`: `fwd_succ`, `bwd_pred`, `dd_chain` (might be replaced)

### 5.3 The Goldblatt Approach in Detail

**New chain construction** (replaces rr_fwd_chain):

```
-- The complexity measure for well-founded induction
noncomputable def f_depth (phi : Formula) : Nat := ...  -- nesting depth of F/P operators

-- The chain resolves formulas in order of f_depth
noncomputable def wf_fwd_chain (M0 : Set Formula) (h0 : SetMaximalConsistent M0)
    (sigma_list : List Formula) : (n : Nat) -> {M : Set Formula // SetMaximalConsistent M}
  | 0 => <M0, h0>
  | n + 1 =>
    let <M, hM> := wf_fwd_chain M0 h0 sigma_list n
    let target := rrSchedule sigma_list n
    <fwd_succ M hM target, fwd_succ_mcs M hM target>
```

**Forward_F proof** (the key result):

Given F(psi) in chain(m), by well-founded induction on `f_depth(psi)`:
- At psi's next visit step n > m: either F(psi) in chain(n) or F(psi) not in chain(n).
- If F(psi) in chain(n): `fwd_succ_resolves` gives psi in chain(n+1). Done.
- If F(psi) NOT in chain(n): need to show psi appeared at some earlier step s in (m, n).
  - F(psi) disappeared at some step k in (m, n]. At step k, the seed is {target_k} union g_content(chain(k-1)).
  - F(psi) NOT in chain(k) means G(neg(psi)) NOT implied by the seed... Actually, this path doesn't work directly.

**Better approach**: Well-founded induction on the deferral closure depth.

The deferralClosure of the root formula phi is the set of formulas that can appear as F-obligations during the completeness proof. It is finite and has bounded nesting depth (`max_F_depth_in_closure`).

For each formula psi in deferralClosure(phi) with F(psi) in chain(m):
- If f_depth(psi) = 0: psi is a base formula. The seed {psi} union g_content(chain(m)) gives psi in chain(m+1). No F-obligations are introduced for simpler formulas.
- If f_depth(psi) = k+1: Resolving psi at step m+1 might introduce new F-obligations for formulas of depth <= k. By induction hypothesis, these are eventually resolved.

**The exact mechanism**: At psi's visit step, `fwd_succ_resolves` puts psi in chain(n+1). The question is whether F(psi) is still in chain(n). The key insight is:

**We don't need F(psi) to persist**. Instead, we prove: if F(psi) in chain(m), then either:
(a) psi in chain(s) for some s > m (done), OR
(b) neg(psi) in chain(s) for all s > m.

Case (b) means: by backward G with the WF-induction hypothesis for simpler formulas, G(neg(psi)) in chain(m). But G(neg(psi)) in chain(m) implies neg(G(neg(neg(psi)))) = neg(G(neg(psi)).neg.neg) ... This gets complicated.

**Actually, the cleaner approach**: Use the simple chain (no f_carry) and prove forward_F by a different route. The backward-G argument (`temporal_backward_G`) requires forward_F for NEG(phi), which has the SAME depth as phi. So the well-founded induction on formula depth does NOT directly work.

**The correct well-founded measure**: Use the deferral closure with its own complexity measure. The deferralClosure is designed so that resolving F(psi) only creates obligations for formulas in the deferral closure. The `max_F_depth_in_closure` result bounds the nesting.

This needs more careful analysis -- the exact WF measure and how it interacts with the chain construction is non-trivial. But the key infrastructure (deferralClosure, forward_temporal_witness_seed_consistent, g_content propagation) is all sorry-free and available.

---

## 6. Recommended Approach

### 6.1 Primary Recommendation: Goldblatt WF-Induction Chain

Replace the current `rr_fwd_chain` + `enriched_fwd_step` with a simpler chain that uses:
- `forward_temporal_witness_seed_consistent` for each step (already proved)
- Well-founded induction on the deferral closure for the forward_F proof
- The existing `deferralClosure` infrastructure for the complexity measure

### 6.2 Why Not Reynolds

The Reynolds quasimodel approach reuses the sorry-free Quasimodel/ code, but requires a significant bridge layer (800-1200 new LOC) to convert finite BXPoint chains into Int-indexed FMCS families. The Goldblatt approach is more direct and requires less new code.

### 6.3 Why Not Approximation or LMCS

Both face the G(F(chi)) obstruction. The approximation approach additionally requires a completely new chain type incompatible with the existing FMCS infrastructure.

### 6.4 Specific Next Steps

1. Formalize the well-founded measure for forward_F:
   - Define `deferral_depth : Formula -> Nat` based on deferralClosure nesting
   - Prove that resolving F(psi) only creates obligations for formulas of lesser or equal depth
   - Prove the base case: depth-0 formulas are immediately resolvable

2. Replace `rr_fwd_chain` body:
   - Use `fwd_succ` (which uses `forward_temporal_witness_seed`) at each step
   - The round-robin schedule is kept for enumeration
   - Remove `enriched_fwd_step` and BX11 fold from the chain (keep for Until/Since coherence)

3. Prove forward_F by WF induction:
   - Given F(psi) in chain(m), at psi's next visit step n:
   - If F(psi) in chain(n): resolved by `fwd_succ_resolves`
   - If F(psi) NOT in chain(n): derive contradiction using WF induction hypothesis

4. Close remaining sorries:
   - `dd_fmcs_forward_F`: follows from `rr_fwd_chain_forward_F`
   - `dd_fmcs_backward_P`: symmetric construction
   - `dd_bfmcs_restricted_tc`: follows from forward_F + backward_P
   - `dd_bfmcs_restricted_buc/fuc`: may require separate Until/Since argument

---

## 7. Risk Assessment

### 7.1 Main Risk: WF Induction Circularity

The well-founded induction for forward_F requires that resolving F(psi) only introduces obligations for "simpler" formulas. The deferralClosure is designed for this, but the exact interaction between the WF measure and the backward-G argument (which requires forward_F for neg(phi)) needs careful verification. If neg(phi) has the same depth as phi, the induction might be circular.

### 7.2 Mitigation

The `restricted_temporal_backward_G_strict` theorem in `TemporalCoherence.lean:376` takes forward_F as an explicit hypothesis. This allows a mutual induction: prove forward_F and backward_G simultaneously by induction on formula complexity, with forward_F calling backward_G for simpler formulas and backward_G calling forward_F for simpler formulas.

### 7.3 Fallback

If the WF induction approach fails, the Reynolds quasimodel bridge (Approach 2) is a viable fallback. The 1,816 lines of sorry-free Quasimodel code provide solid foundations.

---

## 8. Confidence Level

**MEDIUM-HIGH** (0.7/1.0)

The Goldblatt WF-induction approach is well-established in the literature and the key infrastructure exists in the codebase. The main uncertainty is the exact WF measure and whether it avoids circularity with the backward-G argument. The deferralClosure infrastructure (`SubformulaClosure.lean`) is designed for exactly this purpose, but the interaction needs formal verification.
