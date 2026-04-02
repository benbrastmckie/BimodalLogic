# Teammate B Findings: Alternative Completeness Architectures

## Key Findings

1. **The existing `succ_chain_fam` provably cannot resolve F-obligations** -- perpetual deferral is consistent in TM, and the Lindenbaum extension has no mechanism to force resolution. This is confirmed by the blocker analysis and verified against the codebase.

2. **The truth lemma uses `forward_F` in exactly ONE place**: the backward direction of the `all_future` (G) case. Specifically, `restricted_temporal_backward_G` needs `forward_F` for `neg(psi)` to derive a contradiction when `G(psi)` should be in the MCS but isn't. The logic is: assume G(psi) not in MCS, derive F(neg(psi)) in MCS, invoke forward_F to get neg(psi) at some future time, contradicting the hypothesis that psi holds at all future times.

3. **The linearity axiom does NOT prevent perpetual deferral** in the existing chain. Linearity constrains how two F-obligations interact at a single time but does not force any individual obligation to eventually resolve.

4. **The targeted chain infrastructure (TargetedChain.lean) is the most viable building block**, but it loses F-obligations at resolution steps because `canonical_forward_F` creates a fresh Lindenbaum extension that may not preserve other F-formulas.

5. **A simultaneous induction approach to the truth lemma is not feasible** -- forward_F is needed as a side condition, not as something that can be coinductively established with the truth lemma.

6. **The most promising path is a modified targeted chain that resolves obligations one-at-a-time while proving persistence of unresolved obligations via G-wrapping.**

## Direction 1: Existing Chain Properties

### Seed Analysis

The `constrained_successor_from_seed` builds successors from the seed:
```
g_content(M) ∪ deferralDisjunctions(M) ∪ p_step_blocking_formulas(M)
```

For each `F(psi) ∈ M`, the seed includes `psi ∨ F(psi)`. The Lindenbaum extension (via `lindenbaumMCS_set`) picks a maximal consistent superset. Nothing forces it to pick `psi` over `F(psi)`.

### Perpetual Deferral Analysis

**Perpetual deferral IS consistent in TM.** Consider the formula F(p) where p is atomic. An MCS containing {F(p), neg(p)} is consistent (it means "p is false now but true at some future time"). The successor seed includes `p ∨ F(p)` and `g_content(M)`. In the successor:

- If `G(neg(p)) ∈ M`, then the seed is inconsistent with `p`, so the extension must include `F(p)` and `neg(p)`. Deferral is forced.
- If `G(neg(p)) ∉ M`, the extension CAN include `p`, but CAN also include `neg(p)` and `F(p)` -- both are consistent with the seed.

The key insight: `G(neg(p)) ∉ M` does not mean `neg(G(neg(p))) ∈ M`. The MCS could contain `neg(G(neg(p)))` (which is `F(p)`), `neg(p)`, and NOT `G(neg(p))`. This is consistent and Lindenbaum may construct this extension.

**Verdict**: The existing chain construction cannot prove forward_F. The F-step property (f_content persistence: `F(psi) ∈ M → psi ∈ M' ∨ F(psi) ∈ M'`) is proven, but eventual resolution is not.

### Linearity Axiom Interaction

The linearity axiom is: `F(a) ∧ F(b) → F(a ∧ b) ∨ F(a ∧ F(b)) ∨ F(F(a) ∧ b)`.

This says that two future obligations must be temporally ordered (one happens first). However, it says nothing about WHEN either resolves. Both `F(a)` and `F(b)` can be perpetually deferred, and linearity is still satisfied -- linearity constrains the structure of the deferral but does not prevent it.

For perpetual deferral of a SINGLE formula `F(psi)`, linearity is irrelevant.

**Omega-regularity**: The chain is an omega-sequence over a finite alphabet (patterns of membership in deferralClosure). However, TM is NOT an omega-regular temporal logic -- it does not have fairness or acceptance conditions built into its axiomatics. There is no Büchi condition that forces visiting a "resolution" state. The fairness must be built into the chain construction, not derived from the logic.

### Verdict

Direction 1 is a dead end. The existing chain genuinely cannot resolve F-obligations.

## Direction 2: Alternative Model Constructions

### Henkin-Style

A Henkin-style construction for temporal logic would proceed:
1. Start with a consistent set Gamma containing neg(phi) (for non-provable phi).
2. Enumerate all temporal formulas.
3. For each `F(psi)` in the accumulated set, introduce a witness time variable t_psi where psi holds.
4. Show the resulting set is consistent.

**Analysis**: This is essentially what `canonical_forward_F` already does at one step -- it constructs a witness MCS for each F-obligation. The challenge is stitching these witnesses into a single Z-indexed chain. The Henkin approach would need a "chain construction lemma" that is equivalent to what we're trying to prove.

In first-order logic, Henkin witnesses are individual constants, which fit naturally into a single model. In temporal logic, witnesses are TIME POINTS, which must be consistently ordered. This ordering constraint is the core difficulty.

**Verdict**: Henkin-style does not bypass the problem; it reformulates it. The core difficulty (consistent temporal ordering of witnesses) remains.

### Step-Indexed Model

A step-indexed model defines truth at time t by induction on formula complexity, not by MCS membership:

```
truth(t, p)          := p ∈ chain(t)     (for atoms)
truth(t, F(psi))     := ∃ s > t, truth(s, psi)
truth(t, G(psi))     := ∀ s ≥ t, truth(s, psi)
truth(t, Box(psi))   := ∀ families fam, truth_fam(fam, t, psi)
```

**Analysis**: This is exactly what the existing truth lemma establishes -- the equivalence between MCS membership and semantic truth. The step-indexed model IS the canonical model. The issue is proving the backward direction for G: knowing `truth(s, psi)` for all `s ≥ t` should give `G(psi) ∈ chain(t)`. This requires forward_F by the standard contrapositive argument.

**Verdict**: Step-indexed models don't bypass the problem. They are equivalent to the current approach.

### Quotient Model

Take the set of ALL maximal consistent sets as worlds. Define:
- Modal accessibility: Box-class equivalence (R_Box from UltrafilterChain.lean)
- Temporal accessibility: ExistsTask relation (g_content inclusion from CanonicalFrame.lean)

**Analysis**: This is the "canonical frame" approach already in CanonicalFrame.lean. It trivially satisfies forward_F because each F-obligation gets its own witness (via canonical_forward_F). The problem is that this frame uses ALL MCS as worlds, and the temporal relation is NOT a linear order -- it's a preorder.

For completeness over Int, we need each "history" (sigma in the task semantics) to correspond to a Z-indexed chain. The quotient model has the right local properties (forward_F, backward_P) but the wrong global structure (not linearly ordered time).

**Key insight**: The quotient model approach could work if we could EMBED the canonical frame into a linear temporal structure. Specifically:

1. Build the canonical frame with all MCS as worlds.
2. For the eval_family (containing neg(phi)), find a Z-indexed path through the frame.
3. Show this path satisfies forward_F by the frame's properties.

Step 2 is essentially selecting a Z-indexed chain from the canonical frame's temporal accessibility graph. Since ExistsTask is a preorder with the right properties, this should be possible -- but we need to show that G-coherence and H-coherence are maintained along the chosen path.

This is closely related to the targeted chain approach but works at the frame level rather than the MCS level.

**Verdict**: Potentially viable. Formalizing the "path extraction from canonical frame" would be a significant but well-defined task. See Recommended Approach below.

### Filtration

Standard filtration for temporal logic:
1. Fix a finite set Phi closed under subformulas.
2. Define equivalence: M ~ N iff M ∩ Phi = N ∩ Phi.
3. Build the quotient model.

**Analysis**: Filtration gives the finite model property. For completeness, it's typically used in the other direction (from the infinite canonical model to a finite model for decidability). For proving completeness, we need to go from "phi valid in all models" to "phi provable", which requires building A model where phi fails if phi is not provable. Filtration doesn't help with this direction.

**Verdict**: Not applicable to the completeness direction.

## Direction 3: Truth Lemma Restructuring

### Current forward_F Usage

The `restricted_shifted_truth_lemma` (CanonicalConstruction.lean:809) uses forward_F at exactly one point: the backward direction of the `all_future ψ` case (line ~903-908):

```lean
| all_future ψ ih =>
    ...
    · intro h_all      -- hypothesis: ψ true at all s ≥ t
      obtain ⟨h_forward_F, _⟩ := h_tc fam hfam
      ...
      exact restricted_temporal_backward_G fam root h_forward_F t ψ h_neg_ψ_dc h_all_mcs
```

`restricted_temporal_backward_G` (TemporalCoherence.lean:278) proves: if `phi ∈ fam.mcs s` for all `s ≥ t`, then `G(phi) ∈ fam.mcs t`. The proof:

1. Assume `G(phi) ∉ fam.mcs t`.
2. By MCS maximality: `neg(G(phi)) ∈ fam.mcs t`, which gives `F(neg(phi)) ∈ fam.mcs t`.
3. By forward_F (applied to `neg(phi)`): exists `s ≥ t` with `neg(phi) ∈ fam.mcs s`.
4. But `phi ∈ fam.mcs s` by hypothesis. Contradiction.

### Complexity Induction Feasibility

Can we prove the truth lemma by induction on formula complexity WITHOUT forward_F?

The G backward case needs: "if psi is true at all future times in the model, then G(psi) is in the MCS." This is a completeness-like statement -- it says the MCS "knows" everything that is true. Without forward_F, we'd need an alternative path:

**Attempt**: Directly prove `G(psi) ∈ fam.mcs t` from `∀ s ≥ t, psi ∈ fam.mcs s`.
- By the induction hypothesis, `psi ∈ fam.mcs s ↔ truth(s, psi)`.
- We know truth(s, psi) for all s ≥ t.
- We need G(psi) ∈ fam.mcs t.
- The only MCS property that gives us G(psi) from psi-at-all-future-times is... forward_F (via contrapositive).

There is no other axiomatic path. The T-axiom gives `G(psi) → psi`. The 4-axiom gives `G(psi) → G(G(psi))`. Neither gives us `(∀ s ≥ t, psi ∈ MCS(s)) → G(psi) ∈ MCS(t)` without contraposition via F.

**Verdict**: Not feasible. The backward G direction inherently requires forward_F.

### Simultaneous Induction Feasibility

Can we prove forward_F and the truth lemma simultaneously by some joint induction?

The truth lemma is proved by induction on formula complexity. Forward_F is a property of the chain, not of individual formulas. They live at different levels:
- Truth lemma: for each formula phi, for each time t, phi ∈ MCS(t) iff truth(t, phi).
- Forward_F: for each time t, for each formula psi in deferralClosure, F(psi) ∈ MCS(t) → ∃ s ≥ t, psi ∈ MCS(s).

A simultaneous induction would need to prove both by induction on... what? Formula complexity doesn't help because forward_F applies to arbitrary formulas psi in deferralClosure.

**Alternative: induction on temporal nesting depth.** Define depth(phi) as the maximum nesting of F/G operators. Then:
- For depth-0 formulas, forward_F is vacuous (no F-operators).
- For depth-k formulas, forward_F might use the truth lemma for depth < k formulas.

But this doesn't work either. The truth lemma for `G(psi)` (depth k+1) needs forward_F for `neg(psi)` (depth k). Forward_F for `neg(psi)` says: `F(neg(psi)) ∈ MCS(t) → ∃ s ≥ t, neg(psi) ∈ MCS(s)`. This is a CHAIN property, not something derivable from the truth lemma at lower depth.

**Verdict**: Not feasible. Forward_F is a chain construction property, not a logical induction result.

## Recommended Approach

Based on this analysis, the best path forward combines insights from Direction 2 (quotient model / canonical frame) with the targeted chain infrastructure:

### Approach: Targeted Chain with G-Wrapped F-Persistence

The core idea: modify the targeted chain so that when it resolves target `psi` at step k, it **also preserves all surviving F-obligations from step k** by including them in the `canonical_forward_F` seed.

Specifically, replace `canonical_forward_F M h_mcs psi h_F` (which builds seed `{psi} ∪ g_content(M)`) with an enriched version whose seed is:

```
{psi} ∪ g_content(M) ∪ {F(chi) | F(chi) ∈ M, chi compatible with psi relative to M}
```

where "chi compatible with psi relative to M" means `{psi} ∪ g_content(M) ∪ {F(chi)} ⊬ ⊥`.

**Why this works**:
1. `{psi} ∪ g_content(M)` is already proven consistent (existing `forward_temporal_witness_seed_consistent`).
2. Adding compatible F-formulas one at a time preserves consistency (each F(chi) is individually consistent with the base seed).
3. **Joint consistency follows from the finite character of derivability**: if `S ∪ {F(chi_1), ..., F(chi_k)}` is inconsistent, some finite subset derives ⊥, and by deduction theorem analysis, some chi_i is incompatible -- contradicting the selection.
4. Incompatible F-obligations are exactly those that are "blocked" by the target psi (Finding 3 from the blocker analysis). By the **acyclicity of the blocking relation** (blocker analysis Finding 3), each formula can only be blocked finitely many times before it gets its turn as a target.

**Why this avoids the known dead ends**:
- Unlike enriched seed (dead end #1, #5): we don't add raw formulas or deferral disjunctions. We add F(chi) formulas, which are ALREADY in M and hence compatible with the g_content.
- Unlike dovetailed F-resolution (dead end #2): Lindenbaum cannot add G(neg(chi)) for compatible chi because that would make the seed inconsistent.
- Unlike fuel-based (dead end #3): we don't bound depth; we use the acyclicity of blocking for termination.

**Implementation sketch**:
1. Define `compatible_F_set M psi := {F(chi) | F(chi) ∈ M ∧ SetConsistent ({psi} ∪ g_content(M) ∪ {F(chi)})}`.
2. Prove `{psi} ∪ g_content(M) ∪ compatible_F_set M psi` is consistent.
3. Build the targeted chain using this enriched seed.
4. Show F-obligations persist unless blocked. Show blocked obligations get resolved when their blocker is resolved first (topological ordering by the acyclic blocking relation).

**Critical dependency**: The consistency proof for the joint seed (step 2) is the mathematical core. It requires showing that pairwise-compatible F-formulas are jointly compatible with the target seed. This is where the `temp_linearity` axiom may play a role: if two F-obligations are incompatible with each other (given the target seed), linearity may force at least one to be compatible.

### Alternative: Frame Path Extraction

If the enriched seed approach fails on the joint consistency argument, the canonical frame path extraction (from Direction 2, Quotient Model) is the fallback:

1. Build the canonical frame (all MCS, ExistsTask relation).
2. Starting from the eval MCS M, inductively extract a Z-path using canonical_forward_F (forward) and canonical_backward_P (backward).
3. Show this path is an FMCS with all required properties.

The key advantage: forward_F is trivially true in the canonical frame. The challenge: building a Z-indexed chain from the frame that also satisfies G-persistence and H-persistence. The targeted chain infrastructure already handles this (forward_G and backward_H are proven), so the main new work is showing that the targeted chain's round-robin scheduling eventually resolves all F-obligations.

## Confidence Level

**Medium-High**. The mathematical analysis is thorough and the codebase investigation confirms the blockers. The recommended approach (enriched targeted chain with compatible F-preservation) is novel but builds directly on existing sorry-free infrastructure. The main risk is the joint consistency argument for the enriched seed, which requires careful formal work.

The fallback (frame path extraction) is more standard but requires more new infrastructure. Between the two approaches, the enriched targeted chain is estimated at 8-12 hours of implementation, while the frame path extraction is 12-18 hours.
