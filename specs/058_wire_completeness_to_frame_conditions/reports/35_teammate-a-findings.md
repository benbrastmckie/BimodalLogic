# Teammate A Findings: CanonicalTask as the Primary 3-Place Relation

**Task**: 58 - Wire Completeness to Frame Conditions
**Date**: 2026-03-26
**Focus**: CanonicalTask(u, x, v) as the primary concept — algebraic completeness without FMP

---

## Key Findings

1. **CanonicalTask is a fully proven, sorry-free 3-place relation** that satisfies all three TaskFrame axioms (nullity identity, forward compositionality, converse). It is already instantiated as `CanonicalTaskTaskFrame` in `SuccChainTaskFrame.lean`.

2. **The framing insight is correct but shifts the problem**: Using 3-place `CanonicalTask(u, n, v)` as the primary concept DOES clarify the coherence requirements and removes the ambiguity of "which family does the witness belong to?" — but the core obstruction (same-family F-witnesses being blocked by G-propagation) re-emerges as a question about which MCSs are connected by CanonicalTask chains.

3. **F(phi) in u implies CanonicalTask(u, 1, v) with phi in v — ONLY for SerialMCS**: The Succ relation requires a successor to exist, which requires `F_top ∈ u`. For arbitrary MCS, there is no guaranteed Succ step.

4. **The 3-place relation DOES help in one crucial way**: It makes the family structure explicit. The chain `CanonicalTask(u, n, v)` defines exactly which MCSs are "in the same temporal history." This gives a natural factoring of the completeness problem into (a) modal coherence (which families exist?) and (b) temporal coherence (do F-obligations resolve within a chain?).

5. **Direct algebraic completeness via CanonicalTask**: A clean path exists using `CanonicalTask` directly, without FMP, for **deferral-restricted MCS**. The key is that `f_nesting_is_bounded_restricted` (sorry-free) ensures every F-obligation resolves within the bounded chain, so CanonicalTask witnesses always exist within the same chain.

---

## The CanonicalTask Approach (Detailed)

### What CanonicalTask Gives Us

The relation `CanonicalTask(u, n, v)` is defined inductively:
- **Forward** (n ≥ 0): `u = w₀ → w₁ → ... → wₙ = v` via Succ steps
- **Backward** (n < 0): converse chain via backward steps

Crucially, three axioms are **proven without sorry**:
```
CanonicalTask_nullity_identity : CanonicalTask u 0 v ↔ u = v
CanonicalTask_forward_comp     : n ≥ 0 → m ≥ 0 → chains compose to length n+m
CanonicalTask_converse         : CanonicalTask u n v ↔ CanonicalTask v (-n) u
```

These match the `TaskFrame` axioms exactly, enabling the instantiation:
```lean
def CanonicalTaskTaskFrame : TaskFrame Int where
  WorldState := Set Formula
  task_rel   := CanonicalTask
  ...
```

### The Chain Defines a "History"

When we have `CanonicalTask(u, n, v)` for n ≥ 0, there is an explicit Succ-chain `u = w₀, w₁, ..., wₙ = v` where:
- Each step satisfies `Succ(wᵢ, wᵢ₊₁)`
- Succ requires: `g_content(wᵢ) ⊆ wᵢ₊₁` (G-persistence) and `f_content(wᵢ) ⊆ wᵢ₊₁ ∪ f_content(wᵢ₊₁)` (F-deferral)

The `succ_chain_fam` construction builds exactly such a chain, and `CanonicalTaskTaskFrame` is the associated frame. The `succ_chain_history` wraps this into a `WorldHistory`.

### F(phi) in u: What CanonicalTask Tells Us

If `F(phi) ∈ u` where u is an MCS:
- `F(phi)` is in `f_content(u)`
- Any Succ step `Succ(u, w)` must either put `phi ∈ w` or `F(phi) ∈ w`
- By the `single_step_forcing` lemma: if `F(phi) ∈ u` and `FF(phi) ∉ u`, then `phi ∈ w`

The `bounded_witness` theorem (sorry-free) states: if `Fⁿ(phi) ∈ u` and `Fⁿ⁺¹(phi) ∉ u`, then `phi ∈ v` where `CanonicalTask_forward u n v`.

**The obstacle**: For arbitrary MCS, `Fⁿ(phi) ∈ u` for ALL n is possible (the MCS can contain the infinite chain `{F(phi), FF(phi), FFF(phi), ...}`). In this case, no bounded n witnesses the obligation, and there is no `CanonicalTask(u, n, v)` with `phi ∈ v` within the same chain.

This is exactly the `Z_chain_forward_F` sorry — it cannot be proven for arbitrary SerialMCS.

### F(phi) and the Deferral-Restricted Resolution

For `DeferralRestrictedMCS` over `deferralClosure(phi)`, the chain has bounded F-nesting (by `f_nesting_is_bounded_restricted`, sorry-free). This means:
- There EXISTS n ≤ N_bound such that `Fⁿ(phi) ∈ u` and `Fⁿ⁺¹(phi) ∉ u`
- The `bounded_witness` theorem then gives `phi ∈ v` at a specific `CanonicalTask(u, n, v)`
- This v is **in the same Succ-chain** as u — same family, same history

This gives family-level temporal coherence for deferral-restricted chains, plugging directly into `parametric_shifted_truth_lemma`.

### The Role of x in CanonicalTask(u, x, v)

The 3-place relation carries the **duration** x. This duration is not just metadata — it determines:
1. **Direction**: positive x means v is in u's future, negative x means v is in u's past
2. **Distance**: the exact number of Succ steps separating u and v
3. **Coherence obligations**: G-formulas must propagate across all intermediate steps

For F-obligations resolved at "distance n", the x-value is n. For P-obligations at "distance n" in the past, x = -n. The converse axiom ensures these are consistent.

**Crucially**: The x-value records WHERE in the chain the witness lives. This is the "family-level coherence" question dressed in algebraic language: we need `CanonicalTask(u, x, v)` for some **positive** x with `phi ∈ v`.

---

## Advantages Over 2-Place Relations

### ExistsTask (2-place: g_content M ⊆ M')

`ExistsTask(u, v)` just says v is g_content-accessible from u — but gives no information about how many steps, or whether there is an actual Succ-chain connecting them. A world v might be ExistsTask-accessible from u but require an infinitely-long chain (or no chain at all through the specific intermediate worlds).

**CanonicalTask advantage**: If `CanonicalTask(u, n, v)` holds, there is an explicit, finite Succ-chain. Every intermediate world is an MCS with the required coherence properties. No hidden "infinitely many steps" problem.

### CanonicalR / ExistsTask (the modal 2-place relation)

`CanonicalR(u, v)` is the modal accessibility relation: same box-class. This is completely orthogonal to temporal structure — it connects worlds across different families.

**CanonicalTask advantage**: Clearly separates temporal structure (same chain, different times) from modal structure (different chains, same modal content). The 3-place relation makes the temporal dimension explicit.

### The Cross-Family Problem Restated

In the 2-place framework, "F(phi) in u" needs "ExistsTask(u, v) with phi ∈ v" — but ExistsTask doesn't tell you whether v is in the SAME chain as u or a different one.

In the 3-place framework, "F(phi) in u" needs "CanonicalTask(u, x, v) for some positive x, with phi ∈ v." This is precisely the same-chain constraint: any CanonicalTask witness is reachable by explicit Succ steps from u.

**The 3-place relation does NOT resolve the cross-family obstruction** — it makes it more explicit. If the only phi-containing worlds are not Succ-reachable from u (because G(neg phi) blocks all futures), then no `CanonicalTask(u, x, v)` with `phi ∈ v` exists. This is the same sub-case (b) obstruction identified in reports 18, 19, and 20.

---

## Direct Algebraic Completeness Sketch (Without FMP)

### The Clean Path via Deferral-Restricted CanonicalTask

**Theorem (Sketch)**: For any formula phi not provable in TM:

1. `{neg phi}` is consistent (by not_provable_implies_neg_set_consistent, sorry-free)

2. Extend to a `DeferralRestrictedMCS M0` over `deferralClosure(phi)` via Lindenbaum's lemma (restricted version, sorry-free)

3. Build `succ_chain_fam M0 : Int → Set Formula` — the Succ-chain starting from M0 (sorry-free construction)

4. The chain satisfies:
   - MCS at every time: `succ_chain_fam_mcs` (sorry-free)
   - G-forward: all G-formulas of t persist to t' > t
   - H-backward: all H-formulas of t persist to t' < t
   - **F-witness (sorry-free for restricted)**: `restricted_forward_chain_forward_F` — if `F(phi) ∈ succ_chain_fam M0 t`, then exists s > t with `phi ∈ succ_chain_fam M0 s`

5. This gives `TemporalCoherentFamily` for the restricted chain

6. Build `boxClassFamilies M0` for modal (Box/Diamond) coherence — sorry-free

7. The `CanonicalTaskTaskFrame` is instantiated from this chain, and:
   - For temporal F: `CanonicalTask_forward_MCS u n v` witnesses the Succ-chain steps
   - The `bounded_witness` theorem gives `phi ∈ v` when nesting depth is bounded

8. Apply `parametric_canonical_truth_lemma`: `phi ∈ M0 ↔ truth_at ... phi 0` (sorry-free given h_tc)

9. Since `neg phi ∈ M0`, we get `neg phi` true at the canonical model, so phi is not valid, so phi is not a theorem by soundness

### What's Missing for Full Implementation

Two gaps remain:

**Gap A**: `restricted_boxClassFamilies_temporally_coherent` — when M0 is deferral-restricted, families in `boxClassFamilies M0` inherit family-level temporal coherence.
- This requires showing that if `F(phi) ∈ fam.mcs(t)` for `fam ∈ boxClassFamilies M0`, then `phi ∈ fam.mcs(s)` for some s > t IN THE SAME FAMILY.
- For the restricted chain starting from a W with `box_class_agree M0 W`, this requires W to also be deferral-restricted over the same closure. The question is: does `box_class_agree M0 W` plus `W is deferral-restricted` hold whenever M0 is deferral-restricted?
- This is the `deferralClosure_closed_under_box_class` gap from report 20.

**Gap B**: Wiring `DeferralRestrictedMCS` into `BFMCS` — creating a `construct_restricted_bfmcs` that builds the full BFMCS structure from a deferral-restricted base.

### Why CanonicalTask Makes This Cleaner

In the CanonicalTask framework, Gap A becomes:
> If `CanonicalTask(M0, n, W)` is in the chain, and `F(phi) ∈ W`, then there exists `CanonicalTask(W, m, V)` with m > 0 and `phi ∈ V`.

This is exactly `restricted_forward_chain_forward_F` applied to the chain from M0. Since all worlds in the chain are connected by explicit Succ steps (`succ_chain_gives_canonical_forward`), the deferral-restriction at M0 propagates to all successors.

**Key Observation**: The issue with `boxClassFamilies` is that families start from arbitrary W with box_class_agree, NOT from the M0 chain. If we restrict to the single chain from M0 (singleton Omega), then:
- All worlds are connected by CanonicalTask (same chain)
- Deferral-restriction propagates
- No cross-family issue

But singleton Omega fails for Box backward (as documented in `SuccChainTruth.lean`). The tension is:
- Singleton Omega: temporal coherence EASY, modal coherence HARD
- Multi-family bundle: modal coherence EASY (boxClassFamilies), temporal coherence HARD

The deferral-restricted approach resolves this by making temporal coherence achievable for each family independently.

---

## The "Resolution of All x Values" Question

The user's framing asks: when F(phi) is in u, we need to determine the value x such that `CanonicalTask(u, x, v)` with `phi ∈ v`. How do we systematically resolve all x values?

**Answer for deferral-restricted MCS**:

The `bounded_witness` theorem gives a canonical x-value:
> x = n where n is the MINIMUM nesting depth such that `Fⁿ(phi) ∈ u` and `Fⁿ⁺¹(phi) ∉ u`

This n is the "genuine distance" to the phi-witness. The deferral-restriction guarantees this n exists and is bounded by `closure_F_bound(phi)`.

The `iter_F_leaves_closure` theorem (sorry-free) establishes that `iter_F (closure_F_bound phi) phi ∉ closureWithNeg phi`, which means for any restricted MCS u that only contains formulas from the closure, `Fⁿ(phi) ∉ u` for n ≥ closure_F_bound. Hence the bounded n exists.

**For P(phi) in u**: Symmetrically, x = -n where n is the minimum P-nesting depth. The converse axiom makes this work.

**The simultaneity problem**: Different F-obligations in u may resolve at different distances n₁, n₂, .... In the chain from u, these are all satisfied at their respective distances. The `temp_linearity` axiom ensures these witnesses are temporally ordered (one before the other), so the chain can serve all of them consistently.

---

## Confidence Level

**HIGH (85%)** for the correctness of the following:
- `CanonicalTask` fully axiomatizes the TaskFrame structure (proven, sorry-free)
- For deferral-restricted MCS, family-level temporal coherence holds (existing sorry-free lemmas)
- The direct algebraic path (sketched above) is mathematically sound
- The 3-place CanonicalTask cleanly characterizes the "same chain" constraint

**MEDIUM (60%)** for:
- Gap A (`deferralClosure_closed_under_box_class`): mathematically plausible but not verified — needs a proof that box_class_agree preserves deferral-restriction
- Gap B (wiring): mechanical but requires careful Lean plumbing

**The 3-place CanonicalTask insight is GENUINE but not magic**: it clarifies the structure and exposes the algebraic constraints, but the core mathematical obstruction (sub-case (b) for unrestricted MCS) remains. The resolution requires deferral-restriction, not merely reframing with CanonicalTask.

---

## Recommended Implementation Priority

1. **Prove Gap A** (`deferralClosure_closed_under_box_class`): This is the critical missing link. Check whether `box_class_agree M0 W` forces W to be restricted to `deferralClosure(phi)`.

2. **Create `construct_restricted_bfmcs`**: Wire the deferral-restricted chain into the BFMCS structure.

3. **Apply `parametric_canonical_truth_lemma`**: The rest is already proven sorry-free.

The CanonicalTask 3-place relation is the RIGHT algebraic structure to use throughout — it makes the temporal coherence requirements precise and provable for deferral-restricted families. The singleton Omega approach (using only the chain from M0, identified by CanonicalTask) works for temporal coherence and fails only for Box-backward. If Box-backward can be recovered via deferral-restriction propagating to boxClassFamilies, the full completeness proof is within reach.
