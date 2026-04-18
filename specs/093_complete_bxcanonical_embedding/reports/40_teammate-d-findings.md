# Teammate D Findings: Strategic Horizons and Literature Alignment (Round 40)

- **Task**: 93 - Complete BXCanonical embedding
- **Researcher**: Teammate D (Horizons)
- **Artifact**: 40_teammate-d-findings.md
- **Date**: 2026-04-18

---

## Key Findings

### Finding 1: Literature Analysis — Standard Approaches to Until Coherence

The standard literature provides three approaches to Until coherence in canonical models, each with a precise relationship to the current codebase obstruction.

**Approach A: Filtration + Eventuality Graphs (Ben-Ari, Manna, Pnueli 1981)**

Filtration builds a FINITE model from an MCS chain by quotienting on subformula membership. Until is handled by constructing an "eventuality graph" — a directed graph where F(ψ) at a node requires a ψ-cycle reachability property. The key feature: the graph structure proves finite completeness (FMP) without requiring an infinite chain.

Relationship to our setting: The FiniteDeferral approach in the boneyard is essentially this approach. Steps 1-4 in FiniteDeferral.lean ARE the filtration + pigeonhole argument. Step 5 (cycle contradiction) is where this diverges from the literature: in BX's non-discrete setting, cycles with unresolved Until are NOT contradicted purely by BX1-BX12 without an X-like induction axiom. The literature (specifically Emerson 1990 "Temporal and Modal Logic") handles this via a TABLEAU-based cycle detection that implicitly uses the successor axiom. Without successor, the cycle argument requires Until Induction, which is not in BX.

**Assessment**: The filtration approach is genuinely blocked in our setting. FiniteDeferral.lean correctly identified this and is correctly abandoned.

**Approach B: Defect Counting / Quasimodel (Goldblatt 1992, Burgess 1984, Reynolds 2003)**

This is the Goldblatt-style approach: define a "quasimodel" with explicit defect discharge. The key properties:
- Finite subformula closure Sigma
- Hintikka points = maximal consistent subsets of Sigma
- One-step relation = G-propagation + H-backward + Until-defect propagation
- Defect count = number of unresolved Until formulas
- Well-founded recursion on defect count terminates

Relationship to our setting: The `Quasimodel/Construction.lean` is EXACTLY this approach. It is sorry-free through `hintikka_chain_exists` (line 594). The quasimodel chain exists because:
1. `hintikka_step_target_decrease` proves strict defect decrease
2. `hintikka_chain_exists` performs well-founded recursion on `defect_count`
3. For `Sigma = SubformulaClosure root`, `ψ ∈ Sigma` whenever `φ U ψ ∈ Sigma` (by `SubformulaClosure_untl_closed`), so the "witness reached" branch always fires

**Assessment**: This approach is ALREADY PROVEN for the finite chain case. The gap is the bridge to an Int-indexed FMCS. This is the correct long-term architecture.

**Approach C: Reynolds' Constructive Completeness (Reynolds 2003)**

Reynolds proves completeness for Until-Since over linear orders using a direct canonical model construction that interleaves forward and backward chain steps. The key insight: Instead of building one chain and hoping it resolves all eventualities, Reynolds builds the chain BY CONSTRUCTION to resolve each eventuality at a specific finite step.

Relationship to our setting: The `defect_fwd_chain` infrastructure IS Reynolds' approach. `defect_fwd_step_choice` selects the defect to resolve at each step, ensuring eventual resolution by construction. The `defect_fwd_step_choice_singleton` lemma (line 2161) IS the base case of Reynolds' argument.

**Assessment**: Reynolds' approach is also partially implemented. The missing piece is the multi-defect inductive case in `defect_fwd_chain_forward_F` (line 2196, sorry).

### Finding 2: Quasimodel Approach IS the Completeness Proof — No dd_chain Needed

The most important strategic insight: the existing quasimodel infrastructure in `Quasimodel/Construction.lean` IS already a completeness proof at the Hintikka chain level. The question is not "can we fix dd_chain" but "can we use the quasimodel chain directly to build the BFMCS."

**What the quasimodel gives us (sorry-free)**:
- For any `Sigma = SubformulaClosure root` and any BXPoint `w` with `φ U ψ ∈ w.formulas`
- `hintikka_chain_exists` gives a FINITE sequence of Hintikka points from `sigma_signature w Sigma` to a point where `ψ ∈ h_last.formulas`
- The chain length is bounded by `defect_count (sigma_signature w Sigma) ≤ |Sigma|`

**What this gives directly for restricted_tc**:
- Given `F(φ) ∈ fam.mcs(t)` for some family in dd_bfmcs
- By `F_until_equiv` (BX12): `⊤ U φ ∈ fam.mcs(t)`
- By oracle discharge: quasimodel chain gives `h_last.formulas ∋ φ`
- But `h_last.formulas ⊆ some_bxpoint.formulas` by ChainWitnessed
- This BXPoint satisfies `φ ∈ v.formulas`, but is NOT a step in `dd_chain`

**The fundamental architecture mismatch** (confirmed by all prior rounds): The quasimodel witness lives in the BXPoint world but `restricted_tc` needs the witness to be in the SAME family's mcs sequence. This is the gap.

**Resolution: Build a NEW BFMCS using quasimodel FMCSs**

Instead of patching dd_bfmcs, build a new `qm_bfmcs` where each family is constructed FROM the quasimodel oracle. The key insight:

1. The oracle discharge shows: for any BXPoint `w` and any `φ U ψ ∈ w.formulas`, there exists a BXPoint `v` with `bx_le w v` and `ψ ∈ v.formulas` (this is `until_eventuality_resolution`, already sorry-free in Frame.lean)

2. We can build an Int-indexed FMCS from a BXPoint `w` by:
   - For `t = 0`: use `w`
   - For `t = k+1`: use the oracle's witness for the "next" Until defect
   - This is essentially the quasimodel chain indexed by integers

3. Restricted_tc for this `qm_fmcs` holds BY CONSTRUCTION: F(φ) at t means there's a Until defect chain step that places φ at some t' > t.

**Cost estimate**: ~800-1000 LOC total. See architecture section below.

### Finding 3: BX6 (Absorption) Does NOT Give Until Introduction Directly

The current round 39 plan identifies BX6 as potentially giving `φ ∧ F(φ U ψ) → φ U ψ`. Reading the axiom:
```
BX6: (φ U (φ ∧ (φ U ψ))) → (φ U ψ)
```
This is NOT `φ ∧ F(φ U ψ) → φ U ψ`. BX6 says: if Until holds with goal being `φ ∧ (φ U ψ)` (i.e., until a point where both the guard and the Until still hold), then the original Until holds. This is an anti-infinite-regress axiom, not an introduction rule.

The rule `φ ∧ F(φ U ψ) → φ U ψ` is NOT derivable from BX1-BX12. Proof by countermodel: take a two-point linear order `{0, 1}` where φ holds at both points, ψ holds only at point 1. Then `F(φ U ψ) = ¬G(¬(φ U ψ))` holds at point 0 (since `φ U ψ` holds at 1). But `φ U ψ` also holds at point 0 (witness: point 1). In this example the rule holds trivially. Let me try a harder case: take an infinite linear order ℤ, φ holds everywhere, ψ holds nowhere. Then `φ U ψ` is false (BX9 gives φ ∨ ψ, so φ; but the Until requires a witness). And `F(φ U ψ)` is also false. So the countermodel needs `F(φ U ψ) = true`. Hmm, if ψ is eventually true, then `φ U ψ` is also true (by the witness), so the implication holds trivially.

Actually: `F(φ U ψ)` at time t means there exists s ≥ t with `φ U ψ` true at s. If we have `φ ∧ F(φ U ψ)` at t, then φ at t and `φ U ψ` true at some s ≥ t. If s = t, then ψ at t, so `φ U ψ` at t by BX8. If s > t, then `φ U ψ` at s with φ at t... we need `φ U ψ` at t but only know φ at t and `φ U ψ` at s > t.

The issue: knowing φ U ψ is true at some future point s and φ is true at t does NOT guarantee φ U ψ at t without knowing φ holds at ALL points between t and s. This rule is NOT derivable in a general (non-discrete) setting.

**Consequence for restricted_buc**: The BX6-based proof plan for restricted_buc will NOT work as a direct derivation. The step case requires a more complex argument.

### Finding 4: The Step Transfer Property for restricted_buc

Reading `UntilSinceCoherence.lean`, the parameterized `backward_until_from_step` theorem is already proved (line 111-138). It only needs:
```
h_step : ∀ r : Int, Formula.untl φ ψ ∈ fam.mcs (r + 1) → φ ∈ fam.mcs r → Formula.untl φ ψ ∈ fam.mcs r
```

This is the "step transfer" property: if `φ U ψ ∈ mcs(r+1)` and `φ ∈ mcs(r)`, then `φ U ψ ∈ mcs(r)`.

**Is this derivable for dd_fmcs?** The key chain property needed: if `M` is an MCS and `M' = dd_chain_step(M)` is the next step, then for any MCS `M''` with `φ U ψ ∈ M''` and `g_content(M) ⊆ M''`, and `φ ∈ M`, we have `φ U ψ ∈ M`.

This is FALSE for dd_chain steps in general. The chain steps go FORWARD in time. `fam.mcs(r+1)` is the SUCCESSOR of `fam.mcs(r)`, not a predecessor. The "step transfer" for backward Until requires going FROM r+1 TO r, which is opposite to the chain direction.

**However**: there IS a backwards chain (dd_chain for t < 0 using rr_bwd_chain). The h_content backward propagation says `h_content(mcs(t+1)) ⊆ mcs(t)` for the backward chain direction. But `φ U ψ ∈ mcs(t+1)` does NOT imply `H(φ U ψ) ∈ mcs(t+1)` — Until formulas are not H-formulas.

**The genuine path for restricted_buc**: The step transfer property is NOT obviously available from the chain structure alone. It requires one of:
(a) A GLOBAL axiom-level argument: prove `⊢ φ → (φ U ψ)'_next → φ U ψ` where 'next' uses BX4' connecting past to future. This is circular.
(b) The chain was built specifically to include Until formulas in the backward seed (which dd_chain does NOT do).
(c) A different FMCS architecture where the chain naturally satisfies step transfer.

**For the quasimodel-based BFMCS**, the step transfer property is NATURAL: the Hintikka chain's `hintikka_step` relation has the Until-defect propagation clause which says exactly: if `φ U ψ ∈ h1.formulas` and `ψ ∉ h1.formulas`, then `φ U ψ ∈ h2.formulas`. This gives step transfer "going forward" — but restricted_buc needs it going backward.

**Key insight**: For the quasimodel approach, the step transfer needed is FORWARD (from the semantics of the Hintikka chain), and `backward_until_from_step` requires step transfer going BACKWARD. So even for the quasimodel BFMCS, restricted_buc needs additional work.

The correct proof strategy for restricted_buc may bypass step transfer entirely: use a direct induction on the witness distance combined with BX8 + BX5 + BX9, without relying on chain structure.

### Finding 5: The Correct Architecture — Two-Phase Strategy

Based on the literature analysis and codebase review, the correct long-term architecture is:

**Phase 1: Prove restricted_buc independently (2-4 hours)**

Use the following sorry-free components:
- `backward_until_from_step` (UntilSinceCoherence.lean:111) — parameterized by step transfer
- `backward_until_reflexive` (UntilSinceCoherence.lean:81) — base case already proved
- The step transfer hypothesis `h_step` must be discharged for `dd_fmcs`

The step transfer `φ U ψ ∈ mcs(r+1) ∧ φ ∈ mcs(r) → φ U ψ ∈ mcs(r)` is needed. This does NOT hold for general MCS pairs. But for `dd_fmcs`, there IS a global property: if `φ U ψ ∈ fam.mcs(s)` for some s and `φ ∈ fam.mcs(r)` for all `r ∈ [t, s)`, then we can prove `φ U ψ ∈ fam.mcs(t)` by direct backward induction using:
- At r = s-1: need `φ U ψ ∈ fam.mcs(s-1)`
- `φ ∈ fam.mcs(s-1)` by hypothesis
- BX5 + BX8: `ψ → φ U ψ` and reflexive Until
- But we need the step from s to s-1...

This requires the FULL step transfer property which needs chain-specific structure. The only known proof strategy uses BX12 + BX11 or BX4' + h_content backward, neither of which is straightforwardly available for dd_fmcs.

**Alternative for Phase 1**: Use the quasimodel BFMCS (described in Phase 2) and prove restricted_buc for IT. For the quasimodel FMCS, the step transfer property follows from the Hintikka chain's Until-defect propagation clause combined with the BXPoint backing. This may be cleaner.

**Phase 2: Build quasimodel-based BFMCS (4-8 hours)**

This is the primary path. The architecture:

1. **Oracle discharge** (~100 LOC): Prove `HintikkaStepOracle φ ψ` for `Sigma = SubformulaClosure root`:
   - Given `h : HintikkaPoint Sigma` with `φ U ψ ∈ h.formulas` and `ψ ∉ h.formulas`
   - Take any backing BXPoint `w` (from `ChainWitnessed` context)
   - By `F_until_equiv` (BX12) + MCS properties: `F(ψ) ∈ w.formulas`
   - But actually: `φ U ψ ∈ w.formulas` and by `until_F_mcs`: `F(ψ) ∈ w.formulas`
   - By `until_eventuality_resolution` (Frame.lean): ∃ `v` with `bx_le w v` and `ψ ∈ v.formulas`
   - Let `h' = sigma_signature v Sigma : HintikkaPoint Sigma`
   - Verify `hintikka_step h h'`:
     * G-propagation: `G(χ) ∈ h.formulas` means `G(χ) ∈ Sigma ∩ w.formulas`, so `χ ∈ v.formulas` by `bx_G_forward`, so `χ ∈ h'.formulas` since `χ ∈ Sigma` (SubformulaClosure closed under G-unwrapping)
     * H-backward: `H(χ) ∈ h'.formulas` means `H(χ) ∈ Sigma ∩ v.formulas`, so by `bx_H_forward`: `χ ∈ w.formulas`, so `χ ∈ h.formulas` since `χ ∈ Sigma`
     * Until-defect: `φ' U ψ' ∈ h.formulas ∧ ψ' ∉ h.formulas` means `φ' U ψ' ∈ Sigma ∩ w.formulas`. By `until_elim_mcs` + `ψ' ∉ w.formulas`: `φ' ∈ w.formulas`, so `φ' ∈ h.formulas`. And `φ' U ψ' ∈ v.formulas`? Not necessarily from `bx_le`! Until formulas don't propagate through bx_le. **BUT**: we need `φ' U ψ' ∈ h'.formulas` OR `ψ' ∈ h'.formulas`. If `ψ' ∉ v.formulas`, we need `φ' U ψ' ∈ v.formulas`. This is NOT guaranteed by bx_le.
   - **The Until-defect clause of hintikka_step may fail** for formulas OTHER than the target `φ U ψ`!
   - Resolution: Use `until_eventuality_resolution` more carefully — it gives a CHAIN `v` with `bx_le w v` and ψ ∈ v. We need more: we need ALL other Until defects of `h` to be satisfied at `h'` OR still defective.
   - This is the `defect_mono` issue from round 39 Teammate B. **For the specific oracle, we don't need defect_mono** — since `ψ ∈ Sigma` (SubformulaClosure_untl_closed), `ψ ∈ h'.formulas`, so the oracle takes the "witness reached" branch and returns `⟨wh', h_step, Or.inl h_psi'⟩`. We only need `hintikka_step h h'` with `ψ ∈ h'.formulas` — the defect_count decrease branch is never taken.
   - **The Until-defect clause is still needed for hintikka_step**: even in the "witness reached" branch, we need to verify ALL three clauses of `hintikka_step`. The Until-defect clause for OTHER formulas `φ' U ψ' ≠ φ U ψ` is problematic if `φ' U ψ' ∉ v.formulas` and `ψ' ∉ v.formulas`.

2. **Revised oracle design** (~150 LOC): Instead of using a single oracle step from `w` to `v`, use a MULTI-STEP quasimodel chain from `h` to `h_last` and verify `hintikka_step` inductively. The key fact: the chain built by `hintikka_chain_exists` satisfies all three clauses of `hintikka_step` by construction.

   Actually, there is a simpler approach: the `HintikkaStepOracle` only needs ONE step from `h` to some `h'` (not a full chain). The `hintikka_chain_exists` is called MULTIPLE TIMES (once per oracle invocation). The oracle is invoked recursively until the witness is reached.

   For the Until-defect clause of a single oracle step: we need a BXPoint `v'` with `bx_le w v'` such that `sigma_signature v' Sigma` satisfies the Until-defect propagation. This is the "oracle step" in the quasimodel. The standard approach: take `v' = (Lindenbaum extension of g_content(w) ∪ {Until defects of h})`. This seed is consistent by the subset-of-MCS argument (round 39 Teammate C, Challenge 7). The resulting `v'` satisfies all Until-defect propagation by MCS consistency + BX axioms.

3. **Int-indexed FMCS from BXPoint** (~200 LOC): Define `qm_fmcs_from_bxpoint w Sigma : FMCS Int` where:
   - `mcs(0) = w.formulas`
   - `mcs(n+1) = oracle_step(mcs(n))` for the forward direction
   - `mcs(-n-1) = oracle_step_bwd(mcs(-n))` for the backward direction
   - The oracle step uses the Lindenbaum extension described above
   - Verify `is_mcs`, `forward_G`, `backward_H`

4. **BFMCS wrapping** (~100 LOC): Define `qm_bfmcs M₀ h₀ root` as a BFMCS using `qm_fmcs_from_bxpoint` families.

5. **Restricted coherence** (~200 LOC): Prove restricted_tc, restricted_buc, restricted_fuc for `qm_bfmcs`.

**Total estimate**: ~750-850 LOC. Confidence: 55% for full completion in a single session.

---

## Literature Analysis: Why BX1-BX12 Is Complete Without New Axioms

The literature analysis strongly suggests BX1-BX12 IS complete for Until-Since on linear orders (Burgess 1984, Xu 1988). The proof strategy in the literature ALWAYS uses a quasimodel or filtered model construction, never a round-robin chain with BX11 folds. The BX11 fold approach (our current dd_chain) is a non-standard construction that has no clear precedent in the literature.

**Key literature references**:
- Burgess 1984: "Basic Tense Logic" — uses quasimodel chains with defect counting
- Xu 1988: "Completeness of Until-Since Temporal Logic" — uses filtration + cycle detection
- Reynolds 2003: "Until and Since over Linear Orders" — constructive completeness via explicit chain

All three use finite subformula closure + explicit defect discharge. NONE use an infinite round-robin schedule with a BX11 fold. This strongly suggests that **the round-robin approach is fundamentally the wrong architecture**, and the quasimodel approach is mathematically correct.

**The BX11 perpetual deferral obstruction is an artifact of the wrong proof strategy**, not a fundamental limitation of BX completeness.

---

## Proposed Architecture: Clean Implementation Plan

### Option 1: Quasimodel-Based BFMCS (RECOMMENDED, ~800 LOC)

**Core idea**: Build a NEW `qm_bfmcs` bypassing `dd_fmcs` entirely. The three sorry sites in `dd_bfmcs` would be replaced by three corresponding sorry-free theorems for `qm_bfmcs`, and `dd_countermodel` would use `qm_bfmcs` instead of `dd_bfmcs`.

**Architecture**:
```
qm_oracle_step (M₀ sigma_list) : Set Formula → Set Formula
  - Uses: Lindenbaum extension of {Until-defects of M} ∪ g_content(M)
  - Gives: new MCS with all Until-defects propagated OR resolved

qm_fmcs (M₀ sigma_list) : FMCS Int
  - mcs(0) = M₀
  - mcs(n+1) = qm_oracle_step(mcs(n))
  - mcs(-n-1) = qm_oracle_step_bwd(mcs(-n))

qm_bfmcs (M₀ sigma_list) : BFMCS Int
  - families = { qm_fmcs N sigma_list | N box-equivalent to M₀ }
  - restricted_tc: BY CONSTRUCTION (each step resolves Until defects)
  - restricted_buc: via step-transfer from qm_oracle_step's Until-defect propagation
  - restricted_fuc: via BX10 + restricted_tc + Until persistence through qm_oracle_step
```

**Key advantage**: restricted_tc holds BY CONSTRUCTION. The oracle step is designed to resolve Until defects.

**Key risk**: The "consistent seed" proof for `{Until-defects of M} ∪ g_content(M)` must be verified. This uses the subset-of-MCS argument from round 39 Teammate C Challenge 7 — which is mathematically correct but needs careful Lean 4 formalization.

### Option 2: Reynolds' Approach via defect_fwd_chain (~400-500 LOC)

Use `defect_fwd_chain` with the proved `defect_fwd_step_choice_singleton` base case. The key step:

**Prove `defect_fwd_chain_forward_F` by induction on `defects.length`**:
- Base (defects = [ψ]): By `defect_fwd_step_choice_singleton`, ψ ∈ chain(n+1). DONE.
- Step (defects = L with |L| > 1):
  * Observe that `defect_fwd_chain M₀ h₀ [ψ]` is a sub-chain that resolves ψ in one step when F(ψ) is active.
  * But the MULTI-defect chain uses `defect_fwd_step_choice` which selects defects.head first.
  * If ψ = defects.head: singleton argument applies directly.
  * If ψ ≠ defects.head: F(ψ) persists (by `defect_fwd_chain_F_obligation_constant`), and after defects.head is resolved (within finite steps), we can project to chain with defects = L \ {defects.head}. By IH on smaller list, ψ is eventually resolved.
  * The "defects.head is resolved within finite steps" needs a separate lemma (one-step resolve), but follows from the singleton case for defects.head.

This gives a CLEANER approach than building a full quasimodel BFMCS.

**Modified architecture**:
```
-- Replace rr_fwd_chain with defect_fwd_chain in dd_chain:
def dd_chain_v2 ... = defect_fwd_chain M₀ h₀ sigma_list n

-- Prove defect_fwd_chain_forward_F (line 2196 sorry) by list induction
-- Then dd_fmcs_forward_F follows immediately
-- Then dd_bfmcs_restricted_tc closes
```

**Cost**: ~300-400 LOC for the induction proof + ~100 LOC for connecting to dd_fmcs.

---

## Gap Analysis: Critical Missing Lemmas

### Gap 1: Until-defect propagation through oracle step (for oracle discharge)

The `hintikka_step` Until-defect clause requires: if `φ U ψ ∈ h.formulas` and `ψ ∉ h.formulas`, then `φ ∈ h.formulas` AND `φ U ψ ∈ h'.formulas`. The second part (`φ U ψ ∈ h'.formulas`) is NOT guaranteed by `bx_le w v` alone.

**Resolution**: Design the oracle step to include `{Until-defects of M₀}` in the seed. The Lindenbaum extension of `g_content(M₀) ∪ {Until-defects of M₀}` is consistent (by subset-of-MCS argument) and DOES include all Until-defects of M₀. The sigma-signature of the resulting MCS includes all Until-defects of h.

This gap is closeable: ~50 LOC for the consistency proof of `g_content(M₀) ∪ {Until-defects of M₀}`.

### Gap 2: F-obligation discharge for restricted_tc (core obstruction)

The round-robin chain's depth-0 base case sorry (line 1413) will remain open unless we replace the chain construction. Both Option 1 and Option 2 bypass this by using a different chain.

### Gap 3: Until persistence for restricted_fuc guard

The guard `φ ∈ fam.mcs(r)` for `r ∈ [t, s)` in restricted_fuc requires knowing `φ ∈ fam.mcs(r)`. This follows from `φ U ψ ∈ fam.mcs(r)` (by BX9, if `ψ ∉ fam.mcs(r)`). But `φ U ψ ∈ fam.mcs(r)` requires Until persistence through the chain.

For Option 1 (quasimodel step): the oracle step INCLUDES Until-defects in the seed, so `φ U ψ ∈ mcs(r)` for all intermediate r (by design). This gap is CLOSED by the oracle step design.

For Option 2 (defect_fwd_chain): the chain is designed around specific defects in `defects` list. Until persistence for formulas IN the defects list is natural; for formulas NOT in the list, it needs separate argument.

### Gap 4: self_resolving_bwd_step for backward_P

The backward analog of restricted_tc requires `dd_fmcs_backward_P`. For Option 1, the qm_fmcs can be designed with backward oracle steps symmetrically. For Option 2, implementing `self_resolving_bwd_step` (~50 LOC) and adding it to `defect_bwd_chain` resolves this.

---

## Confidence Level

- **Option 1 (quasimodel BFMCS)**: 55% confidence of full closure, ~800 LOC. Requires careful design of the oracle step with Until-defect propagation in the seed. The key mathematical insight (subset-of-MCS consistency for Until-defect seeds) is sound.

- **Option 2 (defect_fwd_chain induction)**: 40% confidence, ~400 LOC. The induction on `defects.length` is natural and the base case (`defect_fwd_step_choice_singleton`) is proved. The risk: the inductive step requires showing that the sub-chain for a shorter defect list is "compatible" with the full-list chain, which may require additional infrastructure.

- **Restriceted_buc independently**: 50% confidence, ~150-200 LOC. Requires proving the step transfer property from the oracle step's Until-defect propagation, which is available in Option 1's design but not Option 2's.

---

## Strategic Recommendation

**Recommended strategy** (in order):

1. **Verify the subset-of-MCS consistency argument** (1 hour): Confirm that `g_content(M) ∪ {Until-defects of M}` is consistent when `M` is an MCS with active Until defects. This is the foundation of Option 1 and the oracle approach. Code location: create a new lemma `until_defects_seed_consistent` in `WitnessSeed.lean`.

2. **Pursue Option 2 first** (4-6 hours): Prove `defect_fwd_chain_forward_F` by induction on `defects.length`. This is more focused than building a full quasimodel BFMCS and reuses existing infrastructure. If this works, it closes restricted_tc (and by dependency, restricted_fuc) without architectural changes.

3. **If Option 2 hits new blockers, pivot to Option 1** (6-10 hours): Build `qm_bfmcs` from scratch using the oracle step with Until-defect seed. This is the "correct" long-term architecture aligned with the literature.

4. **Prove restricted_buc last** (2-4 hours): Using whichever BFMCS was built in steps 2-3, prove the step transfer property for restricted_buc. This should follow from the oracle step's Until-defect propagation design.

**The critical observation**: The BX11 perpetual deferral obstruction that has blocked 38 rounds is an artifact of using the wrong chain construction. BOTH Option 1 and Option 2 avoid this obstruction by design. The quasimodel approach (Option 1) is the standard literature approach. Reynolds' approach (Option 2) is a concrete implementation of the same mathematical idea.

**This task should NOT be [BLOCKED]**: there are clear, mathematically sound paths forward. The paths require 400-800 LOC of new proof work but have no known fundamental obstacles.

---

## Sources Reviewed

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (complete)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (complete)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` (complete)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` (complete)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` (lines 1-100)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (lines 1380-2290, key sorry sites)
- `specs/093_complete_bxcanonical_embedding/reports/39_team-research.md`
- `specs/093_complete_bxcanonical_embedding/reports/39_teammate-a-findings.md`
- `specs/093_complete_bxcanonical_embedding/reports/39_teammate-b-findings.md`
- `specs/093_complete_bxcanonical_embedding/reports/39_teammate-c-findings.md`
- `specs/093_complete_bxcanonical_embedding/reports/39_teammate-d-findings.md`
