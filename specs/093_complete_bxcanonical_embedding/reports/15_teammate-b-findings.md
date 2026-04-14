# Teammate B Findings: Alternative Approaches (Round 15)

**Task**: 93 - Close BXCanonical embedding
**Date**: 2026-04-14
**Focus**: Fresh assessment of Alternatives 1-4 from the prompt, given the infrastructure present in round 15

## Key Findings

Prior 14 rounds have established: the ordered defect-discharge chain (Report 13) is mathematically correct, and the existing `enriched_fwd_fold` infrastructure is reusable. The primary sorry is `rr_fwd_chain_forward_F` plus 5 dependent sorries. The main obstacle is proving the fold target stays direct when it has the earliest BX11 witness.

This report provides a fresh analysis of alternatives 1-4 from the round 15 prompt, paying close attention to what the codebase currently has vs. what is missing.

---

## Analysis of Each Alternative

### Alternative 1: Dovetailing Construction (Goldblatt 1992)

**Description**: Use an ω²-indexed chain where step `ω·k + j` resolves formula j. Each formula is resolved infinitely often.

**Mathematical correctness**: Correct in principle. If every formula in sigma is targeted infinitely often, forward_F holds: F(ψ) at step n implies ψ is targeted at some step m > n, and if F(ψ) has been continuously preserved up to m (or ψ has been directly witnessed at some intermediate step), we get a witness.

**The preservation problem persists**: At each resolving step for formula χ ≠ ψ, F(ψ) may be lost (if the seed for χ does not include F(ψ)). This is the same fundamental obstacle. The dovetailing schedule does not solve it — it just ensures that ψ is targeted again later, but by then F(ψ) may already be gone.

**Nat pairing encoding**: The ω²-indexing CAN be encoded in Lean 4 as a Nat-indexed chain using Cantor pairing `pair(k, j) = (k + j)*(k + j + 1)/2 + j`. This is a bijection `Nat → Nat × Nat`. The chain `c(pair(k, j))` would resolve formula j at index k. The definition compiles fine in Lean 4 — `Nat.rec` with no termination issues.

**Until coherence**: The dovetailing schedule targets F-formulas but does not explicitly handle Until formulas. Until coherence (restricted_buc, restricted_fuc) would require additional argument. Since F(ψ) ∈ M for every "φ U ψ" by BX10, the F-resolution of ψ is necessary, but the Until formula itself needs to persist through intermediate steps.

**Compatibility with existing infrastructure**: The `FMCS Int` structure requires the chain to be indexed by Int. A Nat-indexed dovetailing chain can be embedded into Int by mapping `n → n` for positive steps (the negative half uses `rr_bwd_chain` unchanged). The forward part would need a different step function. This is NOT directly compatible with `rr_fwd_chain` — it would require new definitions and theorems.

**Assessment**: The dovetailing approach re-encodes the same problem. It shifts from "resolve ψ at step n mod k" to "resolve ψ at step pair(k, j_ψ)" but does NOT solve the F-preservation problem at resolving steps for other formulas. The extra complexity of ω²-indexing adds ~100 LOC with no mathematical gain.

**Verdict**: NOT RECOMMENDED. Adds complexity without solving the core problem.

---

### Alternative 2: Quasimodel-to-Int Bridge

**Description**: The quasimodel construction in `Quasimodel/` (2289 lines, sorry-free) builds BXPoint chains with temporal properties. Could we define the Int-indexed FMCS by embedding the quasimodel BXPoint chain directly?

**What the quasimodel actually does**: The `Quasimodel/Construction.lean` and `Quasimodel/Realization.lean` build BXPoint chains at the MCS level for Until/Since resolution. These chains use `bx_le` ordering and are parameterized by a `Sigma : Finset Formula`. The chains are FINITE (of length at most |Sigma|). They are NOT globally coherent Int-indexed chains — they are local witnesses for individual eventuality formulas.

**The sigma_le vs g_content gap**: The quasimodel uses `sigma_le` (the sigma-restricted ordering from `Filtration/SigmaOrdering.lean`) which tracks which formulas from Sigma hold at each BXPoint. This is a DIFFERENT ordering from `g_content M ⊆ M'` used by `dd_fmcs`. The `sigma_le` ordering is a quotient (finite Finset-valued) while `g_content M ⊆ M'` uses the full formula set. These orderings are not compatible — `sigma_le w v` does NOT imply `bx_le w v` in general.

**Can we use BXPoint chain as FMCS families?**: The `BFMCS Int` structure needs families indexed by Int, each being a `FMCS Int` (an Int-indexed chain of MCS sets). BXPoints provide `Set Formula` values, but the FMCS requires an Int-indexed family `mcs : Int → Set Formula` satisfying forward_G and backward_H. A BXPoint chain gives a LIST of MCSs, not an Int-indexed one. Embedding a finite list into Int would place the list at positions 0, 1, ..., k and use constant extensions for the tails — but the tail behavior for forward_G (G(φ) in chain(n) → φ in chain(n+1)) requires the identity or a specific extension.

**Identity extension problem**: If the quasimodel chain ends at BXPoint v_k, extending by `chain(n) = v_k.formulas` for all n > k gives an identity tail. But forward_F on the identity tail requires F(ψ) in v_k implies ψ in v_k (defect-free terminal), which is exactly what the quasimodel construction is trying to achieve in the first place.

**What the quasimodel DOES solve**: The quasimodel's `quasimodel_chain_exists`, `quasimodel_chain_guard`, and `quasimodel_chain_witness` give FINITE witnesses for Until formulas at individual BXPoints. These are currently used in `Realization.lean` to fill in `bx_until_eventuality_resolution` (which is already proved in `Frame.lean`). The quasimodel infrastructure is ALREADY INTEGRATED for Until/Since witnesses. It does NOT help with the global forward_F property for the full Int-indexed chain.

**Compatibility**: The BFMCS infrastructure is locked to Int-indexed MCS families (`ParametricCanonicalTaskFrame Int`, `dd_bfmcs`, etc.). Rebuilding around BXPoint chains would require rewriting `RestrictedParametricTruthLemma.lean` and hundreds of lines of proved infrastructure. This was ruled out in prior rounds.

**Estimated LOC**: 500-1000 LOC to build the bridge, likely introducing new sorry sites.

**Assessment**: The quasimodel infrastructure is already used in Frame.lean for its intended purpose (Until/Since witnesses). Attempting to use it as the global FMCS chain is architecturally incompatible with the existing Int-indexed framework.

**Verdict**: NOT RECOMMENDED. Already ruled out correctly in prior rounds. Infrastructure is incompatible.

---

### Alternative 3: Non-Constructive Existence via Zorn/Compactness

**Description**: Prove existence of a temporally coherent FMCS non-constructively using Zorn's lemma or compactness, rather than building one explicitly.

**Mathematical setup**: Define the property P(F) = "F is an Int-indexed chain of MCSs satisfying forward_G, backward_H, forward_F, backward_P, and the coherence properties for sigma_list." Show the set of all such structures is non-empty by proving a suitable Zorn's lemma or compactness argument.

**Zorn's lemma approach**: To use Zorn's lemma, we need a partial order on chains where every chain of chains has an upper bound. The natural order would be: F ≤ G if G is an "extension" of F. But what does extension mean for Int-indexed chains? We cannot simply extend an Int-indexed chain "further" — the domain is already all of Int. We could order by "F is a sub-chain of G" (agreeing on some sub-interval), but the upper bound of a chain would need to be the limit of all these partial chains, which requires a compactness argument to ensure consistency at each point.

**Compactness approach (propositional calculus level)**: The standard proof uses propositional compactness: the set of formulas T = {for each ψ ∈ sigma, ¬G(¬ψ) → P(ψ resolves at some step after t) | for all t} ∪ {forward_G conditions} ∪ ... is finitely satisfiable (any finite subset can be satisfied by a finite chain), hence satisfiable by compactness.

However, this is a SECOND-ORDER statement (quantifying over chains of sets). Lean 4's propositional compactness (`Set.Finite.isCompact` or similar) applies to sets of propositions, not chains of set-theoretic structures. The Lean proof would require:
- A suitable encoding of "chain coherence" as a set of propositional constraints
- A finitary consistency argument (any finite subsystem has a model)
- Compactness to get the full model

**Is there a suitable Lean 4 theorem?**: Lean 4's Mathlib has `Set.Finite.isCompact_of_forall_isCompact` and `TopologicalSpace.IsCompact` but not a direct "compactness of first-order structures" theorem. The relevant Mathlib theorem would be something like König's lemma or Tychonoff's theorem (product of compact spaces is compact). For a chain of MCSs indexed by Int, this would need each `Int × Formula → Bool` to live in a compact space.

**The Boolean product topology approach**: Each MCS can be encoded as a function `Formula → Bool` (formula in MCS or not). The space of all such functions is `2^Formula`. With the product topology (Tychonoff: compact), the space of all Int-indexed chains is `(2^Formula)^Int = 2^(Formula × Int)`, which is also compact (product of compact spaces). Any "consistent" property defined by a closed condition (forward_G, backward_H, etc.) would give a compact subspace. If every finite subtype restriction is satisfiable (by the consistent chain construction), the intersection is non-empty.

**Critical gap**: This approach proves EXISTENCE but gives a non-constructive object. Lean 4's Classical logic supports this — using `Classical.choice` is acceptable. The BFMCS structure requires `noncomputable` definitions throughout, and the existing infrastructure already uses `Classical.choice` via `set_lindenbaum`. A non-constructive FMCS would be acceptable.

**BUT**: The coherence conditions (forward_F, backward_P, restricted_tc, restricted_fuc, restricted_buc) are not obviously closed conditions in the product topology. forward_F requires: "for every t and ψ with F(ψ) ∈ mcs(t), there EXISTS s > t with ψ ∈ mcs(s)." This is a Σ₁ condition (existential), not a closed (Π₁) condition. The intersection argument requires CLOSED conditions (each being the complement of an open set). A chain satisfying forward_F is NOT a closed subspace of `2^(Formula × Int)` — the condition "F(ψ) ∈ mcs(t) → ψ ∈ mcs(s) for some s" is existential and hence open when negated.

This is a fundamental obstruction: compactness gives us limits of chains satisfying Π₁ properties, but forward_F is Σ₁. The limit of a sequence of chains might not satisfy forward_F even if each chain does (a counterexample: for each n, build a chain where every F-obligation is resolved by step n; the limit might have F-obligations never resolved).

**Zorn's lemma failure mode**: For Zorn to work, we need every linearly ordered set of coherent chains to have an upper bound. If we order chains by "resolves more obligations," the upper bound at each finite stage would resolve more and more obligations. But the limit needs to resolve ALL obligations, which is what we're trying to prove.

**Assessment**: The compactness/Zorn approach is mathematically sophisticated but encounters a fundamental topological obstruction: forward_F is a Σ₁ condition and is not preserved by topological limits. Standard compactness arguments (Tychonoff, product topology) cannot directly prove it.

The approach COULD work via a different route: encode forward_F as a collection of Π₁ conditions with existential witnesses baked in (like "for formula ψ, position (t, s) is a witness pair") and use a compactness argument on the JOINT structure. But this is essentially reconstructing the explicit chain construction in a different language, adding significant complexity.

**Estimated LOC**: 300-600 LOC for the compactness/topology setup, plus significant Mathlib lemma hunting. Very high risk of needing additional sorry sites.

**Verdict**: NOT RECOMMENDED. The Σ₁ nature of forward_F defeats standard compactness arguments. The approach is mathematically unsound for this specific problem.

---

### Alternative 4: Backward-First Construction

**Description**: Build the chain backward from M₀, handling P-obligations first. The claim is that backward propagation might make forward_F easier.

**Concrete formulation**:
- `chain(0) = M₀`
- For n < 0: `chain(n-1) = bwd_pred(chain(n), target)` — resolves P(ψ) in chain(n) by adding ψ to chain(n-1)
- For n > 0: use the existing `rr_fwd_chain`

This is EXACTLY what the current `dd_chain` construction does (negative indices use `rr_bwd_chain`, positive use `rr_fwd_chain`). The backward chain already exists in the codebase at `rr_bwd_chain`.

**Does it swap the problem?**: The `dd_fmcs_backward_P` sorry (line 1172-1177 in RootScopedChain.lean) is symmetric to `rr_fwd_chain_forward_F` sorry. The backward chain has:
- `backward_H` (proven via `rr_bwd_chain_h_content_step`)
- `backward_P` (sorry — needs the same ordered defect-discharge argument, but for P-formulas)

The backward chain resolves P-obligations but does NOT help with F-obligations at time t > 0. The forward sorry is in `rr_fwd_chain_forward_F` (positive time steps). The backward chain only handles negative time steps. So yes: building backward-first DOES swap the problem — backward_P becomes easier (trivial by construction) but forward_F remains hard.

**One insight**: For `dd_fmcs_forward_F` with t < 0 (the second sorry in that theorem), the comment at line 1163-1170 notes: "if F(ψ) ∈ dd_chain(t) [with t < 0], then we need G(F(ψ)) ∈ dd_chain(t) to propagate F(ψ) to M₀." The backward-first insight: if F(ψ) ∈ chain(t) for t < 0 (backward chain), then by `dd_chain_g_content` (which IS proved), G(F(ψ)) ∈ chain(t) implies F(ψ) ∈ chain(t') for all t' > t. So if we also have G(F(ψ)) ∈ chain(t), we get F(ψ) ∈ M₀ and then forward_F in the positive half.

But G(F(ψ)) ∈ chain(t) is NOT guaranteed just from F(ψ) ∈ chain(t). So the backward case of `dd_fmcs_forward_F` requires a separate argument.

**The actual gap for t < 0**: Given F(ψ) ∈ chain(t) with t < 0, since t is in the backward chain, F(ψ) is in `rr_bwd_chain((-t).toNat).val`. The backward chain is built using `bwd_pred` which extends `h_content` (not `g_content`). F(ψ) is a future formula, not a past formula, so h_content does NOT propagate it forward. There is no guarantee that F(ψ) ∈ chain(t) for t < 0 implies F(ψ) ∈ chain(0) = M₀.

This is a genuinely hard case. The cleanest resolution would be to ALSO build the forward chain from M₀ and show that if F(ψ) ∈ chain(t) for t < 0, we can independently show ψ will be resolved at some positive time. This requires:
1. F(ψ) ∈ chain(t) with t < 0
2. ψ ∈ sigma_list
3. Therefore F(ψ) ∈ M₀ would suffice (to trigger the positive chain resolution)
4. But F(ψ) ∈ chain(t < 0) does NOT imply F(ψ) ∈ M₀

**One viable path for the t < 0 case**: Change the FMCS construction to ensure F(ψ) ∈ chain(t < 0) → F(ψ) ∈ chain(0). This would require modifying `rr_bwd_chain` to preserve F-formulas "forward" (in addition to h_content backward propagation). But F-formula preservation in the backward chain requires the same BX11 fold argument — which is the same problem.

**Alternatively**: The t < 0 case can be handled by noting that if sigma_list contains ψ and M₀ is chosen to contain F(ψ) (which is the case — sigma_list contains the deferral closure of the root formula, and M₀ is the starting MCS), then F(ψ) ∈ M₀ already. Therefore F(ψ) ∈ chain(t < 0) can be seen as "redundant" since F(ψ) was already in M₀. But this reasoning requires: F(ψ) ∈ chain(t < 0) → F(ψ) ∈ M₀, which is not proved.

Wait — actually this reasoning has a gap. F(ψ) ∈ chain(t) for t < 0 does NOT require F(ψ) ∈ M₀. The backward chain can independently acquire F(ψ) at negative steps (if some backward extension introduces it). This does happen: `bwd_pred` uses seed `{ψ'} ∪ h_content(M)` for some target ψ', and the resulting MCS M' might satisfy F(ψ) ∈ M' even if F(ψ) ∉ M.

**Practical resolution for t < 0 sorry**: The simplest correct argument is:
- If F(ψ) ∈ chain(t < 0) and ψ ∈ sigma_list, then ψ is also in sigma_list.
- The sigma_list includes the deferral closure of the root formula being falsified.
- M₀ was chosen precisely to contain ¬root, and sigma_list was chosen to contain all F-obligations that can arise from root.
- Regardless of whether F(ψ) ∈ chain(t < 0), the forward chain (t ≥ 0) runs for all positive time and resolves F-obligations from M₀.
- The key question: does F(ψ) ∈ chain(t < 0) give us any obligation to resolve ψ in the FORWARD chain?

For the `dd_fmcs` to satisfy `forward_F`, we need: for every t and ψ with F(ψ) ∈ dd_chain(t), there exists s > t with ψ ∈ dd_chain(s). If t < 0 and F(ψ) ∈ chain(t), we need s > t (which can be any positive integer). So we need ψ ∈ chain(s) for SOME s > t > 0.

If we can show ψ ∈ M₀ or F(ψ) ∈ M₀ (from F(ψ) ∈ chain(t < 0)), we're done: the forward chain will resolve ψ. But we can't show this in general.

**Assessment**: The backward-first construction is already implemented in `dd_chain` (negative indices). It doesn't help with forward_F because the t < 0 case of `dd_fmcs_forward_F` is a SEPARATE sorry that depends on bridging between negative and positive halves of the chain. This sorry is a CONSEQUENCE of `rr_fwd_chain_forward_F` (as stated in the code comment at line 1169: "This sorry depends on rr_fwd_chain_forward_F being proved first").

**Verdict**: Backward-first is ALREADY implemented. The backward chain sorry (`dd_fmcs_backward_P`) is symmetric to the forward sorry and requires the same solution. Not a new alternative.

---

## Recommended Approach

Based on the analysis above, none of the four alternatives provide a simpler path than the ordered defect-discharge chain from Report 13. The alternatives are either:

1. **Dovetailing**: Same problem, more complexity
2. **Quasimodel bridge**: Architecturally incompatible, already ruled out
3. **Zorn/Compactness**: Topologically obstructed by Σ₁ nature of forward_F
4. **Backward-first**: Already implemented; doesn't help

The **only viable approach** remains the ordered defect-discharge chain. The specific formulation recommended by Round 14 synthesis is correct:

1. Prove `target_stays_direct_in_fold`: when the fold target has the earliest BX11 witness (cases 1 or 2 against all others), the target is guaranteed direct (not F-wrapped) in the fold compound.

2. Define `ordered_discharge_step` that uses this to produce M' with: psi_j ∈ M' (guaranteed, not disjunctive) and g_content(M) ⊆ M'.

3. Run for exactly |sigma_list| steps (fixed-length, no well-founded recursion needed). After k := |sigma_list| steps, claim the terminal is defect-free or there exists a witness within the k steps.

4. Prove `rr_fwd_chain_forward_F` via: F(ψ) ∈ chain(n) with ψ ∈ sigma_list → ψ is resolved at step n + something ≤ n + |sigma_list| (within the next full cycle).

The key new insight from this analysis: for the **t < 0 case** of `dd_fmcs_forward_F`, the sorry comment is correct that it "depends on rr_fwd_chain_forward_F being proved first." Once `rr_fwd_chain_forward_F` is proved, the t < 0 case can be handled by:
- The g_content propagation carries G(F(ψ)) from chain(t < 0) to M₀ IF G(F(ψ)) ∈ chain(t)
- If G(F(ψ)) ∉ chain(t), then F(ψ) ∈ chain(t) is not "persistent" and there exists t' > t where F(ψ) ∉ chain(t')
- At that t' (where F(ψ) leaves the backward chain), G(¬ψ) ∈ chain(t'), contradicting F(ψ) ∈ chain(t) by the g_content link... this argument has gaps

Actually, the cleanest route: **prove the t < 0 sorry independently**, by showing F(ψ) ∈ chain(t < 0) implies F(ψ) ∈ M₀ (using the `rr_bwd_chain_h_content_trans` for h-formulas and the connectivity axiom BX4/BX4'). If F(ψ) ∈ chain(-k) where chain(-k) is built from M₀ by k backward steps, then since g_content(M₀) ⊆ chain(-k) is false (backward direction goes the other way), we cannot propagate F(ψ) to M₀ directly. The backward chain has h_content(chain(-1)) ⊆ chain(-2) ⊆ ... which propagates P-formulas backward, not F-formulas forward.

**New insight**: The t < 0 sorry might be provable by contradiction: if F(ψ) ∈ chain(t < 0) and ψ ∉ chain(s) for all s > t, then G(¬ψ) ∈ chain(t) (since ¬ψ holds everywhere in the future). But G(¬ψ) ∈ chain(t < 0) and F(ψ) ∈ chain(t < 0) contradicts M consistency. This is exactly the `no_new_f_defects` argument applied in reverse. But the issue is that "ψ ∉ chain(s) for all s > t" is not the same as G(¬ψ) ∈ chain(t).

**Final recommendation on t < 0**: Defer the t < 0 sorry and close `rr_fwd_chain_forward_F` first (the positive chain). Once that is proved, revisit the t < 0 case with the full proof infrastructure.

---

## Evidence and Examples

### Infrastructure Table (Updated)

| Component | File | Lines | Status |
|-----------|------|-------|--------|
| `enriched_fwd_fold_with_witness` | RootScopedChain.lean | ~280 | Proved |
| `resolving_enriched_fwd_exists` | RootScopedChain.lean | ~370 | Proved |
| `enriched_fwd_step_preserves` | RootScopedChain.lean | ~604 | Proved |
| `enriched_fwd_step_resolves_one` | RootScopedChain.lean | ~620 | Proved |
| `rr_fwd_chain_F_preserved` | RootScopedChain.lean | ~1060 | Proved |
| `rr_fwd_chain_F_propagate` | RootScopedChain.lean | ~1071 | Proved |
| `rr_fwd_chain_forward_F` | RootScopedChain.lean | 1133 | **SORRY** |
| `bx11_earlier_total` | RootScopedChain.lean | ~912 | Proved |
| `discharge_single_step` | RootScopedChain.lean | ~942 | Proved |
| `discharge_two_step` | RootScopedChain.lean | ~951 | Proved |
| `discharge_multi_step` | RootScopedChain.lean | ~985 | Proved |
| `activeDefects` | RootScopedChain.lean | ~994 | Proved |
| `discharge_fwd_chain_g_content_step` | RootScopedChain.lean | ~1027 | Proved |

### Key Observations from Code Reading

1. **`rr_fwd_chain_F_propagate`** (lines 1071-1096) is a complete proof: if F(ψ) ∈ chain(n), then for all m ≥ n, either ψ ∈ chain(s) for some n < s ≤ m+1, OR F(ψ) ∈ chain(m+1). This is the key induction lemma. It says: F(ψ) can only be eliminated by ψ being directly resolved.

2. **The sorry at line 1139** is `rr_fwd_chain_forward_F`. The `rr_fwd_chain_F_propagate` lemma reduces this sorry to: "it cannot be the case that F(ψ) ∈ chain(m+1) for ALL m ≥ n." In other words: the case where F(ψ) persists forever (is never resolved) must be shown to be impossible.

3. **What would complete the sorry**: We need to show: if F(ψ) ∈ chain(n) and ψ never appears in chain(s) for s > n, then we get a contradiction. The contradiction would come from showing G(¬ψ) ∈ chain(n) (from the chain properties), which contradicts F(ψ) ∈ chain(n).

4. **The "G(¬ψ) impossibility" path**: If ψ is always the target without being resolved, and the chain uses `enriched_fwd_step` with BX11 fold protection, then ψ is always either resolved (Case A) or F-wrapped (Case B). In Case B forever: F(ψ) ∈ chain(m) for all m. But from `rr_fwd_chain_F_propagate`, this means ψ ∉ chain(m) for all m > n.

   The question Teammate A is investigating: can we derive G(¬ψ) ∈ chain(n) from "ψ ∉ chain(m) for all m > n"? NOT DIRECTLY. The forward_G property says G(φ) ∈ chain(t) implies φ ∈ chain(t') for t' > t. The BACKWARD direction (φ ∈ chain(t') for all t' > t implies G(φ) ∈ chain(t)) is NOT proved and is generally false (it would require the temporal backward logic to give G from universal future).

5. **The correct path**: The proof of `rr_fwd_chain_forward_F` must use the fact that `enriched_fwd_step` with the BX11 fold RESOLVES ψ directly (psi ∈ M') at its scheduled step — not via the disjunctive `enriched_fwd_step_preserves` but via the DIRECT property from `enriched_fwd_step_resolves_one`. Specifically:
   - At the step where ψ is the target (step n_target with n_target % |sigma| = j_ψ), `enriched_fwd_step_resolves_one` gives: ∃ w ∈ sigma_list with F(w) ∈ chain(n_target) and w ∈ chain(n_target + 1).
   - The witness w might NOT be ψ — it could be some other formula that "beats" ψ in the BX11 fold (BX11 case 3).
   - This is the obstacle: `enriched_fwd_step_resolves_one` gives SOME formula is resolved, but not necessarily the target ψ.

6. **What `enriched_fwd_step_resolves_one` actually says** (lines 621-633): Given target ∈ sigma_list and F(target) ∈ M, there exists w ∈ sigma_list with F(w) ∈ M AND w ∈ M'. The witness w is either target itself or some other element. So the DIRECT resolution is not guaranteed to be the scheduled target.

---

## Confidence Level

**Low-Medium (35%)** on finding a fundamentally new approach in round 15. All alternatives have been analyzed and rejected. The ordered defect-discharge chain remains the only path.

**High (90%)** that the G(¬ψ) impossibility approach (which Teammate A is investigating) is the RIGHT way to close `rr_fwd_chain_forward_F`. The specific proof structure should be:
1. Assume F(ψ) ∈ chain(n) and ψ ∉ chain(s) for all s > n (for contradiction)
2. From `rr_fwd_chain_F_propagate`: F(ψ) ∈ chain(m) for all m ≥ n
3. ψ is targeted at step n_k := n + k*|sigma_list| + j_ψ for each k ≥ 0 (round-robin)
4. At each n_k: F(ψ) ∈ chain(n_k) (from step 2). `enriched_fwd_step_resolves_one` gives SOME w ∈ sigma_list with w ∈ chain(n_k + 1)
5. This w is NOT ψ (by assumption: ψ never appears). So a DIFFERENT formula w ≠ ψ is resolved
6. Since sigma_list is finite, w must repeat: eventually some w_0 is resolved infinitely often
7. When w_0 is resolved: w_0 ∈ chain(n_k + 1) for infinitely many k. But since w_0 ∈ chain(n_k + 1) → F(w_0) ∈ chain(n_k + 1) and F(w_0) ∈ chain(m) for all m ≥ n_k + 1 (by step 2 applied to w_0)... this is circular

Actually the argument collapses. Let me think differently.

**Critical insight**: The `rr_fwd_chain_F_propagate` applies to ALL formulas in sigma_list, not just ψ. If F(w) ∈ chain(n_k) for ANY w, then either w ∈ chain(s) for some s ≤ n_k + 1 OR F(w) ∈ chain(n_k + 1). Since we're assuming ψ is never resolved, we need other formulas w to also never be resolved (or be resolved and then re-acquire F-obligations). With a finite sigma_list, at least one formula must be an F-defect forever. This leads to a contradiction only if we can show that perpetual F-defects are impossible.

**Perpetual F-defect impossibility**: A formula ψ is a perpetual F-defect if F(ψ) ∈ chain(m) for all m ≥ n but ψ ∉ chain(m) for all m > n. For this to happen: at each step m ≥ n, `enriched_fwd_step_preserves` gives ψ ∈ chain(m+1) OR F(ψ) ∈ chain(m+1). In the "forever F-protected" case, F(ψ) ∈ chain(m) for all m. This is consistent with the chain properties — nothing in the chain REQUIRES ψ to actually appear. The BX11 fold consistently puts ψ in the F-protected branch (case 2 or 3 of BX11).

This is the fundamental reason why `enriched_fwd_step` (using BX11 fold disjunction) CANNOT prove forward_F. As long as BX11 case 3 can fire for ψ even when ψ is the target, ψ is never guaranteed to be direct.

**Conclusion**: The ordered discharge step (which PREVENTS case 3 from firing for the earliest-witness formula) is THE necessary modification. Without it, `rr_fwd_chain_forward_F` is unprovable. With it, the proof follows from the direct resolution guarantee.

The current `rr_fwd_chain` uses `enriched_fwd_step` (which allows case 3 for any formula). It CANNOT prove forward_F. A new step function is needed that uses the ordered target selection.

---

## Summary of What Must Be Done

The four alternatives are all dead ends. The path forward is:

1. **Add `ordered_discharge_step`**: A new step function that:
   - Finds the BX11-earliest F-defect (psi_j) using `bx11_earlier_total`
   - Runs the BX11 fold with psi_j as the target
   - Proves psi_j stays direct throughout the fold (key new lemma: `target_stays_direct_in_fold`)
   - Builds seed `{psi_j, compound} ∪ g_content(M)` using `enriched_resolving_seed_consistent`
   - Lindenbaum extends, giving psi_j ∈ M' (GUARANTEED, not disjunctive)

2. **Replace `rr_fwd_chain` with a new chain using `ordered_discharge_step`**

3. **Prove `rr_fwd_chain_forward_F` for the new chain**: F(ψ) ∈ chain(n) → ψ resolved within |sigma_list| steps of n, because ψ will eventually be the BX11-earliest defect, at which point it's guaranteed direct.

The key new Lean theorem to prove (estimated ~50 LOC):
```
theorem target_stays_direct_in_fold {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (psi_j : Formula) (others : List Formula)
    (h_F_target : F(psi_j) ∈ M)
    (h_earliest : ∀ χ ∈ others, F(χ) ∈ M → bx11_earlier M psi_j χ) :
    ∃ compound : Formula, F(psi_j ∧ compound) ∈ M ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' → (psi_j ∧ compound) ∈ M' → psi_j ∈ M') ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' → (psi_j ∧ compound) ∈ M' →
        ∀ χ ∈ others, χ ∈ M' ∨ F(χ) ∈ M')
```

This is provable from `enriched_fwd_fold_with_witness` + the BX11 order property: if psi_j is earlier than all others, BX11 case 3 never fires for psi_j (it would put psi_j in F position, but that would mean some other formula is "earlier" — contradicting h_earliest).
