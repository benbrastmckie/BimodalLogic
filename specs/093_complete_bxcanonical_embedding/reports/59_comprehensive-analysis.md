# Comprehensive Analysis: Task 93 — BXCanonical Completeness Proof

**Task**: 93 — Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-22
**Rounds**: 58+ research rounds, 175 commits, 22 plan versions
**Status**: BLOCKED — 3 sorry sites remain in RootScopedChain.lean

## Executive Summary

Task 93 aims to achieve sorry-free completeness for the bimodal logic TM system: `#print axioms bx_completeness` should list only `{propext, Classical.choice, Quot.sound}`. After 58+ research rounds and extensive implementation attempts, the proof is blocked by a fundamental tension between **target resolution** (putting φ directly in the chain) and **F-preservation** (keeping F-obligations for other formulas alive). All Lindenbaum-based chain approaches have been exhausted. The theorem IS true (soundness is sorry-free), but the current proof architecture cannot close the gap.

---

## 1. The Mathematical Setting

### 1.1 The Logic TM (Tense + Modality)

TM combines:
- **S5 modal logic** (Box/Diamond) — quantifies over "histories" at the same time
- **Linear temporal logic** (G/H/F/P/Until/Since) — quantifies over times within a single history
- **Interaction axioms**: □φ → □(Gφ) and □φ → G(□φ)

### 1.2 Task Frame Semantics

A TaskFrame `(W, D, task_rel)` where:
- `W` = world states
- `D` = totally ordered abelian group (e.g., Int)
- `task_rel w d u` = timed reachability (duration `d` from `w` yields `u`)

Temporal operators quantify over ALL times in D (not just task-reachable states). A WorldHistory τ maps times to worlds, constrained by task_rel.

### 1.3 The BX Axiom System

12+ axiom schemas including:
- BX1 (G-reflexivity): G(φ) → φ
- BX4 (G-transitivity): G(φ) → G(G(φ))
- BX4' (Connectedness): φ → G(P(φ))
- BX5 (Self-accumulation): (φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)
- BX10 (Until-to-F): (φ U ψ) → F(ψ)
- BX11 (Temporal linearity): F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)
- BX12 (F-to-Until): F(φ) → (⊤ U φ)

**Critically absent**: F(φ) → G(F(φ)) (no F-persistence axiom). This is semantically correct — F(φ) at time t means φ holds at SOME future time, but at t+1 that future time may have passed.

---

## 2. The Completeness Proof Architecture

### 2.1 The Goal

```
bx_completeness : valid φ → Nonempty (DerivationTree [] φ)
```

Equivalently (by contrapositive): if φ is not provable, construct a TaskModel where φ is false.

### 2.2 The Proof Structure

```
bx_completeness
  → dd_countermodel : builds countermodel from ¬φ
    → bx_bfmcs : Bundle of Families of MCS over Int
      → bx_bfmcs_restricted_tc          ← SORRY #1
      → bx_bfmcs_restricted_buc         ← SORRY #2
      → bx_bfmcs_restricted_fuc         ← SORRY #3
    → fully_restricted_parametric_representation_from_neg_membership
      → RestrictedParametricTruthLemma (sorry-free)
```

### 2.3 The Three Sorry Sites

All in `RootScopedChain.lean`:

**Sorry #1** — `bx_bfmcs_restricted_tc` (line 186): Restricted temporal coherence
- Forward: F(φ) ∈ fam.mcs(t) → ∃ u > t, φ ∈ fam.mcs(u)
- Backward: P(φ) ∈ fam.mcs(t) → ∃ u < t, φ ∈ fam.mcs(u)
- Required by truth lemma for G/H backward direction

**Sorry #2** — `bx_bfmcs_restricted_buc` (line 193): Backward Until/Since coherence
- Given ψ at s and φ on [t,s), derive (φ U ψ) ∈ fam.mcs(t)
- Requires "step transfer": (φ U ψ) ∈ mcs(r+1) ∧ φ ∈ mcs(r) → (φ U ψ) ∈ mcs(r)

**Sorry #3** — `bx_bfmcs_restricted_fuc` (line 198): Forward Until/Since coherence
- (φ U ψ) ∈ fam.mcs(t) → ∃ s ≥ t, ψ ∈ fam.mcs(s) ∧ ∀ r ∈ [t,s), φ ∈ fam.mcs(r)
- Depends on Sorry #1 (temporal coherence) plus Until-persistence

### 2.4 The Key Definitions

- **BXPoint**: A maximally consistent set (MCS) of formulas, packaged with its MCS proof
- **bx_le w v**: The canonical temporal ordering, defined as `g_content(w) ⊆ v.formulas` where `g_content(M) = {φ | G(φ) ∈ M}`
- **FMCS Int**: An Int-indexed family of MCS satisfying forward_G and backward_H
- **BFMCS Int**: A bundle of FMCS families (one per modal equivalence class)
- **deferralClosure root**: The finite set of formulas that need temporal coherence (subformula closure of root with F/P deferral witnesses)

---

## 3. The Core Obstruction: Lindenbaum Non-Determinism

### 3.1 How the Chain Is Built

The current approach builds an Int-indexed chain of MCS step by step:
1. Start with M₀ (an MCS containing ¬φ)
2. At each step n, use `preserving_fwd_step` to build chain(n+1):
   - Uses `defect_step_choice_early` → `resolving_enriched_fwd_exists` → BX11 enriched fold
   - Resolves ONE defect w directly (w ∈ chain(n+1))
   - Preserves ALL F-obligations (F(χ) ∈ chain(n+1) for all χ ∈ sigma_list with F(χ) ∈ chain(n))

### 3.2 What Works (Sorry-Free)

- **F-preservation**: `preserving_fwd_step_F_preserved` — F(χ) persists at every step
- **One-defect resolution**: At each step, some defect is directly placed in the successor
- **bx_le transitivity**: g_content propagation is transitive
- **forward_G / backward_H**: The FMCS ordering properties
- **bx_forward_witness / bx_backward_witness**: 1-step witnesses for F/P obligations
- **bx_until_eventuality_resolution**: 1-step Until resolution
- **FF_imp_F**: F(F(φ)) → F(φ) (nested F collapse)
- **bx11_earlier_total**: Total ordering on any pair of F-defects at a given MCS

### 3.3 The Gap

We need: **F(φ) ∈ chain(n) → ∃ m > n, φ ∈ chain(m)**

The problem: `defect_step_choice_early` uses `Exists.choose` on the BX11 fold existential. The choice is deterministic but **opaque** — we cannot predict or control which defect gets resolved. The resolved defect might never be φ.

### 3.4 Why Defects Don't Decrease

When w is resolved (w ∈ chain(n+1)), the axiom-derived theorem `φ → F(φ)` (from BX1 contrapositive) gives F(w) ∈ chain(n+1). So w immediately re-enters the active defect set. The set of active defects is **monotonically non-decreasing** — it never shrinks.

### 3.5 The Lindenbaum Freedom Problem

Each chain step uses `set_lindenbaum` (Lindenbaum's lemma via `Classical.choice`) to extend a consistent seed to an MCS. The seed is typically `{target} ∪ g_content(M)`. The extension can freely add ANY formula consistent with the seed — including `G(¬χ)` for formulas χ not in the seed. Once `G(¬χ)` enters the chain:
- `G(G(¬χ)) ∈ chain(n)` by temp_4 (G-transitivity)
- `G(¬χ) ∈ g_content(chain(n)) ⊆ chain(n+1)` (propagates forever)
- `F(χ) = ¬G(¬χ) ∉ chain(n+k)` for all k ≥ 0 (χ can never be resolved)

This is **permanent and irrecoverable**.

---

## 4. Dead Ends (45 Documented)

### 4.1 Seed-Based Approaches

| # | Approach | Why It Fails |
|---|----------|-------------|
| 1-5 | Various early chain designs | F-obligations lost at each step |
| 13 | Combined seed `{target} ∪ g_content(M) ∪ f_carry(M)` | Seed INCONSISTENT when `G(F(α) → ¬target) ∈ M` (counterexample: target, F(α), and F(α)→¬target in seed derive ⊥) |
| 36 | True-defect redefinition (filter on χ ∉ M) | Defects re-emerge: once χ ∈ chain(n+1), F(χ) ∈ chain(n+1) by φ→F(φ), then χ may leave chain(n+2) |
| 40 | Combined seed inconsistency (enriched resolving seed) | Same as #13 — F-formulas conflict with G-implications |
| 41 | φ-last fold (BX11 fold with φ processed last) | Case 2 still blocks at final step |

### 4.2 BX11 Fold Approaches

| # | Approach | Why It Fails |
|---|----------|-------------|
| 37 | F(φ)→G(F(φ)) axiom | No such axiom in BX; semantically invalid on linear orders |
| 42 | "Permanent Case 3" (mischaracterized) | Actually Lindenbaum freedom, not Case 3 per se |
| 45+ | bx11_earlier well-founded induction | Ordering is MCS-dependent and non-transitive; no stable measure |

### 4.3 Alternative Chain Constructions

| # | Approach | Why It Fails |
|---|----------|-------------|
| 38 | Direct BXPoint chains (qm_fwd_chain) | Same F-persistence wall — bx_forward_witness uses set_lindenbaum internally |
| 39 | Round-robin fwd_succ | F-obligations lost at resolving steps for non-target formulas |
| 43 | Zorn's maximal chain through (BXPoint, bx_le) | Frame is branching: two witnesses for incompatible formulas are incomparable |
| 44 | AC-based iterator (Classical.choice on bx_forward_witness) | Isomorphic to existing construction — same F-loss |

### 4.4 Miscellaneous

| # | Approach | Why It Fails |
|---|----------|-------------|
| "Controlled Lindenbaum" | Iteratively add F-obligations to seed | Reduces to Dead End #13 when multiple F-obligations interact |
| "Omega-saturation" | Restrict to MCS where F-obligations are satisfied | Circular: proving MCS extends to saturated one requires the completeness theorem |
| "Parallel families per F-obligation" | Different BFMCS families for different obligations | Single-family-per-modal-class requirement blocks this |

---

## 5. What Has Been Accomplished

### 5.1 Sorry Reductions

- **3 algebraic sorries closed**: InteriorOperators.lean (`G_monotone`) and LindenbaumQuotient.lean (`provEquiv_all_future_congr` x2) — one-liner fixes using `DerivationTree.axiom [] _ (Axiom.temp_k_dist φ ψ)`
- **Frame.lean sorry closed**: `bx_modal_equiv` proof is complete (stale sorry comment remains)
- **Dead code annotated**: QuasimodelBridge.lean, Quasimodel/Construction.lean, Quasimodel/OracleInstantiation.lean, Bundle/SuccRelation.lean

### 5.2 Infrastructure Built (Sorry-Free)

- `QuasimodelBridge.lean`: ~200 lines of QM chain infrastructure (qm_fwd_chain, qm_bwd_chain, qm_chain, qm_fmcs, shifted_qm_fmcs)
- Extensive BX11 fold analysis and documentation
- `bx11_earlier_total`, `target_stays_direct_in_fold` — key lemmas for the ordering approach
- `fwd_chain_F_persistent` — F-preservation along the preserving chain
- ROADMAP.md updated with full strategy and dead-end inventory

### 5.3 Key Findings

1. **F-preservation IS proved** (sorry-free) for the preserving chain
2. **The canonical model architecture is correct** — bx_le via g_content is the right definition
3. **restricted_tc is mathematically necessary** — cannot be weakened
4. **The theorem IS true** — bx_soundness is sorry-free, semantics align with axioms
5. **The obstruction is Lindenbaum non-determinism**, not any specific BX11 case

---

## 6. Remaining Viable Paths

### 6.1 Two-Phase Chain (Not Yet Attempted)

**Idea**: Alternate between:
- **Phase A** (enriched fold): Preserves ALL F-obligations, resolves some defect
- **Phase B** (self-resolving): Specifically targets φ, may lose other F-obligations

Phase A restores what Phase B loses. The chain cycles: A-B-A-B-...

**Challenge**: Proving that Phase A actually restores the F-obligations lost by Phase B. Phase B loses F(χ) by allowing G(¬χ) to enter. Phase A uses the enriched fold which preserves F-obligations — but only those still alive. Once G(¬χ) enters, it propagates forever.

**Assessment**: Likely blocked by the same permanence issue. Once Phase B kills an F-obligation, Phase A cannot resurrect it.

### 6.2 Two-Formula BX11 Analysis (Partially Explored)

**Idea**: When only TWO formulas are involved in the BX11 fold (φ and χ), all 3 BX11 cases preserve F(φ):
- Case 1: F(φ ∧ χ) — both resolved
- Case 2: F(φ ∧ F(χ)) — φ resolved, F(χ) protected
- Case 3: F(F(φ) ∧ χ) — χ resolved, F(φ) protected

So for a 2-defect scenario, the fold guarantees BOTH defects' F-obligations persist. The question: can this be extended to N defects?

**Challenge**: With N defects, the fold processes them sequentially. Each fold step may wrap the target in an additional F-layer. After N-1 fold steps, the target may be F^{N-1}(φ), not φ itself. `FF_imp_F` collapses F(F(φ)) → F(φ), but the fold's compound structure is more complex.

**Assessment**: Most promising unexplored direction. Needs careful analysis of the fold's compound structure for N > 2 defects.

### 6.3 Semantic/Goldblatt Approach (Not Attempted in Lean)

**Idea**: Instead of building the chain step-by-step via Lindenbaum, use the standard Burgess-Xu approach:
1. The canonical model is ALL BXPoints with bx_le
2. Completeness is proved by showing every consistent formula is satisfiable in this model
3. F-eventualities hold by the BX axioms (BX5+BX6 prevent infinite deferral)

**Challenge**: The current architecture requires Int-indexed families (FMCS), not the full canonical frame. Converting from the Burgess-Xu canonical model to the BFMCS structure requires establishing temporal coherence — which IS the problem.

**Assessment**: Would require significant architectural restructuring. The representation theorem would need to be reproved for a different model construction.

### 6.4 Restructure the Completeness Proof

**Idea**: Instead of building a BFMCS with explicit coherence properties, prove completeness by a different route:
- Direct semantic argument using the canonical frame
- Henkin-style construction with built-in eventualities
- Algebraic/duality-theoretic approach

**Challenge**: Large-scale refactoring of the completeness infrastructure. The current representation theorem machinery (RestrictedParametricTruthLemma, ParametricRepresentation) would need replacement.

**Assessment**: Highest potential payoff but highest cost. Months of work.

---

## 7. Analysis of the Mathematical Core Problem

### 7.1 The Fundamental Tension

The completeness proof needs to build a model (an Int-indexed chain) where:
1. Every G-formula at step n propagates to all future steps (forward_G)
2. Every F-formula at step n is eventually witnessed (forward_F)

These requirements conflict because:
- forward_G is enforced by g_content propagation (structural, automatic)
- forward_F requires a specific formula to appear in the chain (existential, requires control over Lindenbaum)

The Lindenbaum extension `set_lindenbaum` is a black-box classical choice. It extends a consistent seed to an MCS, but we cannot control WHICH MCS. The seed `{target} ∪ g_content(M)` guarantees target ∈ M' and g_content(M) ⊆ M', but says nothing about F-obligations for OTHER formulas.

### 7.2 Why the Literature Approach Works

In the standard Burgess-Xu proof, the canonical model is the set of ALL MCSes simultaneously. The temporal ordering is bx_le. F-eventuality holds because:
- If F(φ) ∈ M, then `bx_forward_witness` gives v with φ ∈ v and bx_le(M, v)
- This v EXISTS as a BXPoint — it's part of the canonical model
- The truth lemma maps MCS membership to semantic truth in the canonical model
- F(φ) ∈ M maps to "φ is true at some future world v in the canonical model"

The proof works because the canonical model is NOT a single chain — it's the ENTIRE set of BXPoints. F-eventuality is immediate from the existence of witnesses (bx_forward_witness).

### 7.3 Why Our Architecture Creates the Problem

Our architecture requires MORE than the standard canonical model. It requires:
1. An Int-indexed CHAIN (not just the full canonical frame)
2. Each chain family in the BFMCS must satisfy temporal coherence individually
3. The BFMCS structure bundles families by modal equivalence class

The Int-indexing forces us to select a LINEAR path through the canonical frame. The witness v from bx_forward_witness may not be on this path. Selecting v and placing it on the path may break the linear ordering or lose F-obligations for other formulas.

### 7.4 The Architectural Mismatch

The representation theorem (`fully_restricted_parametric_representation_from_neg_membership`) converts a BFMCS with coherence properties into a TaskModel. This theorem is sorry-free. But it REQUIRES the three coherence properties as hypotheses.

An alternative representation theorem that works with the full canonical frame (not Int-indexed chains) would bypass the problem. This would require:
- Defining TaskModel directly from the canonical frame
- Proving the truth lemma for the canonical frame (not for a specific chain)
- Showing the canonical frame satisfies the TaskFrame axioms

This is essentially the Burgess-Xu approach formalized in Lean. It would require replacing the BFMCS-based representation with a direct canonical model representation.

---

## 8. Recommendation

### 8.1 Short-Term (Immediate)

Mark task 93 as **[BLOCKED]** with a clear description of the irreducible obstruction. The current dd_chain/BFMCS architecture cannot close the forward_F gap without either:
- A new mathematical insight about the BX11 fold's behavior over multiple steps
- An architectural change to the representation theorem

### 8.2 Medium-Term (Next Steps)

1. **Investigate the two-formula BX11 analysis** for N > 2 defects — this is the most promising unexplored angle
2. **Study whether `defect_step_choice_early` has a hidden monotone property** — the G-formulas that accumulate in the chain via the fold may create a decreasing measure we haven't found
3. **Prototype a direct canonical model representation** — define TaskModel directly from BXPoints without Int-indexing, and check if the truth lemma still works

### 8.3 Long-Term (Architectural)

Replace the BFMCS-based representation theorem with a Burgess-Xu style direct canonical model construction. This would:
- Eliminate the need for Int-indexed chains
- Make F-eventuality immediate from bx_forward_witness existence
- Require significant refactoring but would definitively close the gap

---

## 9. Timeline and Effort Summary

| Period | Activity | Outcome |
|--------|----------|---------|
| Initial | Research + early plans (v1-v6) | Chain construction approaches tried, forward_F identified as blocker |
| Middle | Plans v7-v14, quasimodel approaches | Quasimodel oracle approach tried, same Lindenbaum non-determinism |
| Late | Plans v15-v18, direct BXPoint chains | QM chain infrastructure built (sorry-free), but coherence still blocked |
| Recent | Plans v19-v22, enriched seeds, Reynolds induction | Dead End #13 confirmed, bx11_earlier non-transitive, Exists.choose opaque |
| Current | Round 58+ synthesis | Comprehensive dead-end inventory, architectural analysis |

**Total effort**: ~175 commits, 58+ research rounds (with 4 teammates each), 22 plan versions, 45+ documented dead ends.

**Completed work**: 3 algebraic sorries fixed, dead code annotated, ROADMAP updated, extensive sorry-free infrastructure built.

**Remaining**: 3 sorry sites, all dependent on the forward_F gap.
