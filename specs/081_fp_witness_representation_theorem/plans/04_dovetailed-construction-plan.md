# Implementation Plan: Dovetailed Construction with Controlled Seeding

- **Task**: 81 - F/P Witness Representation Theorem
- **Status**: [BLOCKED]
- **Effort**: 12 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Research Inputs**:
  - reports/01_team-research.md (algebraic + category-theoretic perspectives)
  - reports/02_team-research.md (truth lemma F-case analysis, same-family required)
  - reports/03_team-research.md (three approaches compared, dovetailed selected)
  - reports/04_team-research.md (detailed dovetailed vs compactness design)
- **Artifacts**: plans/04_dovetailed-construction-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Implement the dovetailed construction with controlled seeding to produce `TemporalCoherentFamily` instances satisfying same-family `forward_F` and `backward_P`. This fills the last remaining gap between `BFMCS_Bundle` (bundle-level coherence, sorry-free) and `BFMCS.temporally_coherent` (family-level coherence, required by the truth lemma). The construction builds forward and backward omega-chains from an arbitrary MCS M_0, using fair scheduling via `Nat.unpair` and controlled seeding with F-blockers to prevent G(neg psi) from permanently blocking pending F(psi) obligations. Completion of this plan yields the `construct_bfmcs` function required by `parametric_algebraic_representation_conditional`, closing the completeness theorem for TM logic.

### Research Integration

All four research rounds converge on the same conclusion:

1. **Run 1**: Same-family witnesses are potentially required; algebraic infrastructure is complete
2. **Run 2**: Same-family `forward_F` is definitively REQUIRED -- the G backward case in `ParametricTruthLemma` uses contraposition through `to_history fam`, which binds to a specific family
3. **Run 3**: CanonicalMCS as D eliminated (category error); Zorn reduces to dovetailed when correctly formulated; dovetailed construction is the natural and only approach
4. **Run 4**: Controlled seeding is the shared mathematical core; compactness via product topology is isomorphic but adds overhead; full construction design with 4 invariants specified

### Implementation Attempt Findings (2026-04-01)

An implementation agent wrote `DovetailedChain.lean` (335 lines, untracked) before
hitting a fundamental mathematical obstacle. Key findings:

#### What Was Built
- `forward_controlled_seed` definition with G_theory, box_theory, H-blockers, resolution formula
- `h_blockers_subset_M0` and `g_blockers_subset_M0` (sorry-free)
- `h_blocker_excludes` (sorry-free)
- `forward_controlled_seed_consistent` — **BLOCKED with sorry** (the core obstacle)

#### The H-Blocker G-Lift Problem
The standard consistency proof (used by `temporal_theory_witness_consistent`) works by:
1. Assume seed is inconsistent, extract finite L with L ⊢ bot
2. Separate phi from L, get L_rest ⊢ neg(phi)
3. G-lift every element of L_rest: show G(x) ∈ M for each x
4. By G_lift_from_context: G(neg(phi)) ∈ M, contradicting F(phi) ∈ M

**Step 3 fails for H-blockers.** `neg(H(chi)) ∈ M_0` does NOT imply `G(neg(H(chi))) ∈ M_0`.
There is no axiom or theorem that G-lifts arbitrary formulas from an MCS.

#### The Deeper F-Persistence Problem
Even without H-blockers, using only the proven-consistent seed `{phi} ∪ temporal_box_seed(M)`,
the **F-persistence problem** remains: Lindenbaum extension can freely add `G(neg(psi))` to
the chain at any step, permanently killing a pending F(psi) obligation before its scheduled
resolution step. The seed `{phi} ∪ temporal_box_seed(M)` does not prevent this because
`G(neg(psi))` is consistent with the seed when `G(neg(psi)) ∉ G_theory(M)`.

The agent explored multiple approaches to F-persistence:
- **F-blockers in seed** (plan's approach): Can't be G-lifted either
- **Resolve all obligations simultaneously**: Fails when obligations conflict (e.g., F(p) and F(neg(p)) both in M)
- **Immediate resolution**: Can only resolve one per step; others may be lost
- **Modified Lindenbaum**: Would require controlling which formulas Lindenbaum adds — major infrastructure change

#### Conclusions
1. **The seed `{phi} ∪ temporal_box_seed(M)` is the only proven-consistent option** — it gives forward_G, box-class agreement, and backward_H (via duality), but NOT F-persistence
2. **F-persistence requires controlling Lindenbaum's choices**, which `set_lindenbaum` (Zorn-based) does not support
3. **The plan's controlled seeding approach is mathematically correct in principle** but requires a consistency proof technique beyond G-lifting
4. **Alternative**: A custom Lindenbaum construction that, when deciding between `G(neg(psi))` and `F(psi)`, always chooses `F(psi)` for pending obligations

#### Possible Paths Forward
1. **Custom Lindenbaum**: Build MCS by formula enumeration with deliberate choices preserving F-obligations
2. **Ultrafilter-level argument**: Work at the quotient algebra level where filter extension may be more tractable
3. **Restricted completeness**: Use existing sorry-free `restricted_forward_chain_forward_F` (UltrafilterChain.lean:2930) for weak completeness only
4. **Rethink the seed**: Prove consistency of F-blocker-extended seed via a non-G-lift argument (e.g., show seed is a subset of the deductive closure of M, which is M itself since M is MCS)

## Goals & Non-Goals

**Goals**:
- Construct `TemporalCoherentFamily Int` from any MCS M_0 with `fam.mcs 0 = M_0`
- Prove same-family `forward_F`: F(phi) in fam.mcs(t) implies phi in fam.mcs(s) for some s >= t
- Prove same-family `backward_P`: P(phi) in fam.mcs(t) implies phi in fam.mcs(s) for some s <= t
- Provide `construct_bfmcs` satisfying the signature in `parametric_algebraic_representation_conditional`
- All proofs sorry-free

**Non-Goals**:
- Compactness/product topology approach (proven isomorphic with more overhead)
- Zorn formulation (proven redundant when correctly handling forward_F)
- Arbitrary duration type D (Int suffices for base completeness)
- Optimizing line count or proof term size

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-zero handling (F at t<0 needing witness at s>=0) | High | Medium | Build separate forward/backward chains from M_0; F-blockers propagate to time 0 in backward chain, then forward chain resolves |
| Controlled seed consistency proof complexity | Medium | Medium | Seed is a subset of M's deductive closure; use existing `temporal_theory_witness_consistent` pattern |
| Finset bookkeeping verbosity in Lean | Medium | High | Use Set-based tracking with decidable membership; avoid Finset if possible |
| Obligation creation outpacing resolution for arbitrary MCS | Medium | Low | At any finite step, only finitely many obligations exist; fair scheduling handles countable set |
| Dependent type issues with growing chain (Fin (n+1)) | Medium | Medium | Use function Nat -> Set Formula instead of Fin-indexed; prove properties by Nat induction |

## Implementation Phases

### Phase 1: Controlled Seed Infrastructure [BLOCKED]

**Goal**: Define the controlled seed construction and prove its consistency. This is the mathematical core that enables the entire construction.

**Mathematical Content**:

The controlled seed for step n+1 given chain tip M_n is:

```
controlled_temporal_seed(M, phi_opt, pending) =
  g_content(M) ∪ box_content(M) ∪ {phi | phi_opt = some phi} ∪ {F(psi) | psi in pending}
```

where:
- `g_content(M) = {a | G(a) in M}` (existing, TemporalContent.lean)
- `box_content(M) = {a | Box(a) in M} ∪ {neg(Box(a)) | Box(a) not in M}` (existing, as `box_theory`)
- `phi_opt`: the formula being witnessed this step (if resolving an obligation)
- `pending`: formulas whose F-obligations are still pending

**Consistency Theorem** (`controlled_seed_consistent`):

If M is an MCS, `phi_opt = some phi` implies `F(phi) in M`, and `F(psi) in M` for all psi in pending, then `controlled_temporal_seed M phi_opt pending` is consistent.

**Proof Strategy**:

The key insight is that the controlled seed is a SUBSET of `{phi} ∪ forward_temporal_witness_seed M phi` extended with additional F-formulas that are already in M. Specifically:

1. `forward_temporal_witness_seed M phi = {phi} ∪ g_content(M)` is already proven consistent when F(phi) in M (`forward_temporal_witness_seed_consistent` in WitnessSeed.lean)
2. We need to extend this with `box_content(M)` and F-blockers
3. For box_content: `temporal_theory_witness_consistent` already proves `{phi} ∪ temporal_box_seed M` consistent (where `temporal_box_seed = G_theory ∪ box_theory`)
4. For F-blockers: each F(psi_i) is in M. The seed plus all F-blockers is a subset of the deductive closure of M. Formally: assume the extended seed is inconsistent. Then some finite subset derives bot. Every element of this finite subset is either in M directly (F-blockers, G_theory elements) or consistently extendable with M's content (phi via temporal_theory_witness_consistent). The contradiction follows from M's consistency.

**Alternative Proof Strategy** (likely simpler in Lean): Show `controlled_temporal_seed M phi pending ⊆ {phi} ∪ temporal_box_seed M` when all pending F-formulas have their G-counterpart excluded from M. Since:
- g_content(M) ⊆ G_theory(M) ⊆ temporal_box_seed(M) [after appropriate reformulation]
- box_content(M) = box_theory(M) ⊆ temporal_box_seed(M)
- Each F(psi_i) = neg(G(neg(psi_i))) is in M, and G_theory(M) ⊆ M, so the F-blockers are consistent with the rest

Actually, the cleanest approach: prove consistency by contradiction using the same technique as `forward_temporal_witness_seed_consistent` (WitnessSeed.lean lines 79-177). That proof handles two cases:
- Case psi in L: extract L_no_psi, lift to G via generalized_temporal_k, derive G(neg psi) in M, contradicting F(psi) in M
- Case psi not in L: all of L in g_content(M), lift to G(bot) in M, derive G(neg psi) in M, contradiction

For the controlled seed, the proof extends this pattern: the F-blockers are F(psi_i) = neg(G(neg(psi_i))) formulas. If the seed is inconsistent, the derivation uses finitely many of them. Each F(psi_i) is in M, so we can separate the derivation into the "standard" part (handled by temporal_theory_witness_consistent) and the F-blocker part (consistent because they're all in M and M is consistent).

**Tasks**:
- [ ] Define `controlled_temporal_seed : Set Formula -> Option Formula -> Set Formula -> Set Formula`
- [ ] Prove `controlled_temporal_seed_consistent`: seed is consistent when F(phi) in M and all F-blockers from M
- [ ] Prove `lindenbaum_of_controlled_seed`: Lindenbaum extension preserves all seed elements (corollary of set_lindenbaum)
- [ ] Prove `controlled_extension_preserves_g_content`: g_content(M) ⊆ g_content(W) when W extends controlled seed
- [ ] Prove `controlled_extension_preserves_box_class`: box_class_agree(M, W) when W extends controlled seed
- [ ] Prove `controlled_extension_preserves_F_blockers`: F(psi) in seed implies F(psi) in W

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add controlled seed infrastructure after line 3711 (or create new file)

**Timing**: 2 hours

**Verification**:
- `lake build` compiles without errors
- All new theorems are sorry-free
- `controlled_temporal_seed_consistent` type-checks with the correct signature

---

### Phase 2: Forward Chain Construction [NOT STARTED]

**Goal**: Build the forward omega-chain from M_0 with fair scheduling and obligation tracking, maintaining four invariants.

**Mathematical Content**:

Define the forward chain as a function `forward_dovetailed_chain : Nat -> Set Formula` by recursion on Nat:

```
forward_dovetailed_chain 0 = M_0
forward_dovetailed_chain (n+1) = lindenbaum_extension(controlled_temporal_seed(chain(n), phi_n, pending_n))
```

where `phi_n` and `pending_n` are determined by the obligation tracking logic.

**Obligation Tracking**:

Rather than using an explicit `ObligationTracker` data structure (which creates complex dependent types), track obligations propositionally:

- An F-obligation `(t, psi)` is *created* at step t if `F(psi) in chain(t)`
- An F-obligation `(t, psi)` is *resolved* by step n if there exists s with t <= s <= n and `psi in chain(s)`
- An F-obligation is *pending at step n* if created but not yet resolved

The scheduling function determines which obligation to resolve at step n+1:
```
let (i, j) = Nat.unpair n
-- Consider the j-th F-formula in chain(i), if it exists and is still pending
```

**Four Invariants** (proven by Nat induction):

1. **G-Coherence**: For all i <= j <= n, if `G(phi) in chain(i)` then `phi in chain(j)`
   - Proof: chain(j) extends g_content(chain(j-1)) which contains phi when G(phi) in chain(j-1). By induction, G(phi) propagates from i to j-1 (using temp_4: G(phi) -> G(G(phi))), hence phi in chain(j).

2. **Box-Class Agreement**: For all i <= n, `box_class_agree(chain(0), chain(i))`
   - Proof: Each step extends `box_theory(chain(i))` which preserves box_class_agree transitively.

3. **F-Persistence**: For all pending obligations (t, psi) at step n, `F(psi) in chain(n)`
   - Proof: The controlled seed includes `F(psi)` for all pending obligations. Lindenbaum extension of consistent seed containing F(psi) gives MCS containing F(psi).

4. **Resolution Tracking**: When step n resolves obligation (t, psi), `psi in chain(n)`
   - Proof: phi_resolve = psi is in the seed. Lindenbaum extension gives MCS containing psi.

**Implementation Approach**:

Rather than defining a single recursive function with complex dependent types, split into:

1. `forward_chain_step`: Given MCS M, a formula to resolve (optional), and pending F-formulas, produce the next MCS via controlled seed + Lindenbaum
2. `forward_dovetailed_chain`: The full Nat-indexed chain, defined by well-founded recursion
3. `forward_chain_is_mcs`: Each chain element is an MCS
4. `forward_chain_g_coherence`: Invariant 1
5. `forward_chain_box_agree`: Invariant 2
6. `forward_chain_f_persist`: Invariant 3

**Design Decision -- Enumeration of F-formulas**:

The scheduling function `Nat.unpair n = (i, j)` pairs step index i with formula index j. For formula enumeration, we need a surjective function `Nat -> Formula`. Since Formula is countable (built from finite constructors over a countable atom type), such an enumeration exists. In practice, we can use the fact that if `F(psi) in chain(i)`, then `psi` appears in the MCS. We enumerate over all formulas and filter for those with F-obligations.

For the implementation, the simplest approach is to prove the forward_F theorem existentially: show that for any (t, psi) with F(psi) in chain(t), there EVENTUALLY exists a step that resolves it. This avoids needing an explicit formula enumeration.

**Simpler Alternative**: Instead of explicit Nat.unpair scheduling over formula indices, prove forward_F by a direct argument:

Given F(psi) in chain(t), by F-persistence, F(psi) persists in chain(t), chain(t+1), ..., chain(n) for all n >= t. At step n = Nat.pair t 0, the scheduler considers time t, formula index 0. If psi happens to be at index 0, it's resolved. If not, Nat.pair t 1 considers index 1, etc. By surjectivity of unpair, every (t, j) pair is eventually hit.

The key question is whether we need an explicit enumeration. For the forward_F theorem, we only need: "for all t and psi, if F(psi) in chain(t), then eventually psi appears." We can prove this by showing the seed at the resolution step includes psi, and Lindenbaum gives psi in the MCS.

**Tasks**:
- [ ] Define `forward_dovetailed_chain : (M_0 : Set Formula) -> SetMaximalConsistent M_0 -> Nat -> Set Formula`
- [ ] Prove `forward_chain_is_mcs : forall n, SetMaximalConsistent (forward_dovetailed_chain M_0 h n)`
- [ ] Prove `forward_chain_base : forward_dovetailed_chain M_0 h 0 = M_0`
- [ ] Prove `forward_chain_g_coherence : forall i j, i <= j -> G(phi) in chain(i) -> phi in chain(j)`
- [ ] Prove `forward_chain_box_agree : forall i, box_class_agree (chain 0) (chain i)`
- [ ] Prove `forward_chain_f_persist`: F(psi) pending at step n implies F(psi) in chain(n)
- [ ] Define the scheduling/resolution mechanism

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Continue after Phase 1

**Timing**: 2.5 hours

**Verification**:
- `lake build` succeeds
- All four invariants stated and proven (sorry-free)
- `forward_chain_g_coherence` matches the signature needed by FMCS.forward_G

---

### Phase 3: Forward F Theorem [NOT STARTED]

**Goal**: Prove that the forward dovetailed chain satisfies `forward_F`: for all t and phi, if F(phi) in chain(t), then there exists s >= t with phi in chain(s).

**Mathematical Content**:

**Theorem** (`forward_dovetailed_chain_forward_F`):

```lean
theorem forward_dovetailed_chain_forward_F
    (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0)
    (t : Nat) (phi : Formula) (h_F : Formula.some_future phi ∈ forward_dovetailed_chain M_0 h_mcs t) :
    ∃ s : Nat, t ≤ s ∧ phi ∈ forward_dovetailed_chain M_0 h_mcs s
```

**Proof Strategy**:

1. F(phi) in chain(t) creates obligation (t, phi)
2. By the scheduling mechanism, there exists step n such that unpair(n) targets (t, k) where k is the index of phi among F-obligations at time t
3. At step n, the controlled seed includes phi as the resolution formula
4. By Lindenbaum: phi in chain(n+1)
5. We need n+1 >= t. Since unpair(n) = (t, k), we have t <= n (by Nat.unpair_left_le), so n+1 > t >= t

**Alternative Proof (more robust)**:

Rather than tracking explicit formula indices, prove forward_F by construction:

1. Given F(phi) in chain(t), pick any n >= t (we can choose n = Nat.pair t 0 or any suitable value)
2. Show that at step n, the seed can be chosen to include phi
3. The key property needed: there exists SOME step n >= t where phi is the resolution target

This requires the scheduling function to eventually target phi. The cleanest approach:

- Define a formula enumeration `enum_F : Nat -> Formula` such that for every formula psi, there exists k with `enum_F k = psi`
- The scheduler at step n+1 with unpair(n) = (i, j) resolves `enum_F j` at time i (if applicable)
- For any (t, phi), choose k with enum_F(k) = phi. Then n = Nat.pair(t, k) has unpair(n) = (t, k), and step n+1 resolves phi at time t

**Formula Enumeration**: The `Formula` type is inductively defined and countable. We can use `Encodable Formula` (if available) or construct an enumeration directly. Alternatively, bypass enumeration entirely by using the existing `temporal_theory_witness_exists` approach:

**Simplest Approach** (avoiding explicit enumeration):

Prove forward_F by showing that the chain construction, at SOME step, resolves any given obligation. The proof is:

1. F(phi) in chain(t) means F(phi) persists to chain(n) for all n >= t (by F-persistence invariant)
2. At step t itself (or any step where unpair targets time t), the resolution mechanism fires for some obligation at time t
3. We need to show that EVERY obligation at time t eventually gets its turn

For this, we need the formula set at time t to be countable and the scheduler to be fair over all formula indices. Since `Nat.unpair` is surjective, for any k, there exists n with unpair(n) = (t, k). This means the k-th formula at time t is eventually targeted.

**The formula index question**: We need a way to enumerate formulas. One approach: fix an arbitrary enumeration of Formula (via `Countable Formula` and `Encodable Formula`). The scheduler at step n with unpair(n) = (i, j) checks: is `Encodable.decode j` a formula psi with F(psi) in chain(i) and psi not yet resolved? If so, resolve it. If not, extend with no resolution (just g_content + box_theory + F-blockers).

This is clean and avoids tracking which formula has which index in the MCS.

**Tasks**:
- [ ] Establish `Encodable Formula` or equivalent enumeration (may already exist or follow from countable constructors)
- [ ] Define the resolution predicate: step n resolves formula psi at time t
- [ ] Prove resolution correctness: when step n resolves (t, psi), psi in chain(n+1)
- [ ] Prove fair coverage: for any t and psi, if F(psi) in chain(t), there exists n with resolution at (t, psi)
- [ ] Prove `forward_dovetailed_chain_forward_F` by combining F-persistence + fair coverage + resolution correctness

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 2 hours

**Verification**:
- `forward_dovetailed_chain_forward_F` compiles sorry-free
- The proof uses only established lemmas (no circular dependencies)

---

### Phase 4: Backward Chain and Backward P [NOT STARTED]

**Goal**: Construct the backward omega-chain using symmetric past infrastructure, proving `backward_P`.

**Mathematical Content**:

The backward chain is constructed symmetrically to the forward chain:

```
backward_dovetailed_chain 0 = M_0
backward_dovetailed_chain (n+1) = lindenbaum_extension(controlled_past_seed(chain(n), phi_n, pending_n))
```

where `controlled_past_seed` uses:
- `h_content(M) = {a | H(a) in M}` (existing, TemporalContent.lean)
- `box_theory(M)` (same as forward)
- P-blockers: `{P(psi) | psi in pending} = {neg(H(neg(psi))) | psi in pending}`

**Symmetry with Forward Construction**:

Every theorem from Phases 1-3 has a past-direction analog:

| Forward | Backward |
|---------|----------|
| g_content | h_content |
| G_theory | H_theory |
| temporal_theory_witness_exists | past_theory_witness_exists |
| forward_temporal_witness_seed_consistent | past_temporal_witness_seed_consistent |
| G_dne_theorem | H_dne_theorem |
| generalized_temporal_k | generalized_past_k |
| temp_4 (G -> GG) | past_temp_4 (H -> HH) |
| temp_t_future (G -> id) | temp_t_past (H -> id) |

The existing codebase already provides all past-direction analogs (WitnessSeed.lean, UltrafilterChain.lean).

**Backward Chain Invariants**:
1. H-Coherence: H(phi) in bwd(i) implies phi in bwd(j) for j >= i (going deeper into the past)
2. Box-Class Agreement: box_class_agree(bwd(0), bwd(i)) for all i
3. P-Persistence: P(psi) pending implies P(psi) in bwd(n) for all n past the creation point
4. Resolution Tracking: resolved P-obligations have psi in bwd(n)

**backward_P Theorem**:

```lean
theorem backward_dovetailed_chain_backward_P
    (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0)
    (t : Nat) (phi : Formula) (h_P : Formula.some_past phi ∈ backward_dovetailed_chain M_0 h_mcs t) :
    ∃ s : Nat, t ≤ s ∧ phi ∈ backward_dovetailed_chain M_0 h_mcs s
```

Note: the backward chain is Nat-indexed going INTO the past. So `backward_dovetailed_chain M_0 h t` represents the MCS at time `-t` in the final Int-indexed family. `s >= t` means `s` is further in the past.

**Tasks**:
- [ ] Define `controlled_past_seed` (symmetric to controlled_temporal_seed)
- [ ] Prove `controlled_past_seed_consistent` (symmetric proof)
- [ ] Define `backward_dovetailed_chain : Nat -> Set Formula`
- [ ] Prove H-coherence, box-class agreement, P-persistence invariants
- [ ] Prove `backward_dovetailed_chain_backward_P`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 1.5 hours (largely symmetric, can reuse proof patterns from Phases 1-3)

**Verification**:
- `backward_dovetailed_chain_backward_P` compiles sorry-free
- All backward invariants stated and proven

---

### Phase 5: Assembly into TemporalCoherentFamily [NOT STARTED]

**Goal**: Join forward and backward chains at time 0 to produce a `TemporalCoherentFamily Int` with all four coherence properties.

**Mathematical Content**:

**The Int-indexed family**:

```lean
def dovetailed_temporal_family (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0) :
    Int → Set Formula := fun t =>
  if 0 ≤ t then forward_dovetailed_chain M_0 h_mcs t.toNat
  else backward_dovetailed_chain M_0 h_mcs (-t).toNat
```

**Agreement at time 0**: Both chains start at M_0:
- `forward_dovetailed_chain M_0 h 0 = M_0`
- `backward_dovetailed_chain M_0 h 0 = M_0`
- For `t = 0`: `0 <= 0` so `fam(0) = forward_chain(0) = M_0`

**Cross-zero properties** (the highest-risk component):

1. **forward_G across zero**: If G(phi) in fam(t) for t < 0, then phi in fam(s) for all s >= t.
   - Case s < 0: H-coherence of backward chain (since G(phi) propagates via H in the backward direction by converse property)
   - Wait -- this needs careful analysis.

   Actually, the correct formulation: `fam(t) = backward_chain(-t)`. G(phi) in backward_chain(-t) means G(phi) is in the MCS at backward position -t. We need phi in fam(s) for ALL s >= t (including s >= 0, which is in the forward chain).

   The key property: G(phi) in backward_chain(k) for k = -t > 0 means G(phi) is in this MCS. By backward chain H-coherence (wait, the backward chain preserves H, not G)...

   **Critical insight**: The backward chain preserves H-content, not G-content. So G(phi) in backward_chain(k) does NOT automatically propagate to backward_chain(k-1). This is the cross-zero problem.

   **Resolution via temp_4 and the converse axiom**:
   - G(phi) in M_0 means G(G(phi)) in M_0 (by temp_4: G -> GG in MCS)
   - G(G(phi)) in M_0 propagates forward via g_content in the forward chain
   - G(phi) in backward_chain(k) and we need phi in forward_chain(j) for j >= 0:
     * G(phi) in backward_chain(k) implies G(phi) in backward_chain(0) = M_0 by... no, the backward chain goes DEEPER into the past, not toward 0.

   Let me reclarify the indexing:
   - backward_chain(0) = M_0 (time 0)
   - backward_chain(1) = MCS at time -1
   - backward_chain(2) = MCS at time -2
   - backward_chain(k) = MCS at time -k

   So G(phi) in backward_chain(k) = fam(-k). We need phi in fam(s) for all s >= -k.

   For s <= 0: fam(s) = backward_chain(-s) where -s <= k. So we need phi in backward_chain(j) for j <= k. The backward chain preserves h_content going from index 0 to k (deeper into past). But G(phi) going from index k back toward 0 would need the REVERSE direction.

   **The correct approach**: The backward chain is constructed by extending h_content (past direction). It does NOT preserve g_content. So G(phi) at a negative time does NOT automatically propagate forward. But that's fine -- we need to show that the FMCS structure field `forward_G` holds for the combined family.

   For `forward_G` of the combined family: "G(phi) in fam(t) implies phi in fam(s) for all s >= t."

   Case t >= 0: forward_chain has G-coherence (Phase 2, invariant 1). Done.

   Case t < 0, s < 0: We need phi in backward_chain(-s) when G(phi) in backward_chain(-t) and -t >= -s (i.e., s >= t). This means -s <= -t, i.e., the target is CLOSER to 0 (less deep in the past). The backward chain extends h_content going AWAY from 0. Between indices -s and -t, the backward chain was built by extending from backward_chain(-s) to backward_chain(-t) (since -t > -s, the later index was built from the earlier one). Wait, no: backward_chain(0) = M_0, backward_chain(1) extends backward_chain(0), etc. So backward_chain(k+1) extends backward_chain(k).

   So backward_chain(-t) was built from backward_chain(-t-1), which was built from ... backward_chain(-s). The backward chain step from k to k+1 extends h_content(chain(k)). This means H-formulas propagate: H(phi) in chain(k) implies phi in chain(k+1). But we need G(phi) in chain(-t) to imply phi in chain(-s) for -s <= -t.

   G(phi) in chain(-t): by temp_a axiom (phi -> G(P(phi))), we can derive cross-operator relationships. But this is getting complicated.

   **Better approach**: Use the converse property and the backward chain's structure.

   Actually, rethinking: the backward chain is built with h_content seeds. This means:
   - H(phi) in backward_chain(k) implies phi in backward_chain(k+1) (by h_content inclusion in seed)
   - By temp_4 for H: H(phi) implies H(H(phi)), so H-formulas propagate indefinitely into the past

   For G-formulas in the backward chain: G(phi) in backward_chain(k) for some k. Since the backward chain does NOT use g_content in its seed, G(phi) may or may not persist. However:
   - The converse axiom: phi -> G(P(phi)). So any phi in backward_chain(k+1) (which arose from H-content propagation) gives G(P(phi)) in backward_chain(k+1).
   - More importantly: backward_chain(k) includes box_theory in its seed, so Box-formulas are preserved.

   **The fundamental issue**: forward_G for the combined family across zero requires that G-formulas at negative times propagate to non-negative times. The backward chain does not inherently preserve G-content.

   **Solution**: G(phi) in fam(t) for t < 0 means G(phi) in backward_chain(-t). Since the backward chain starts at M_0 = backward_chain(0), and backward_chain(-t) was built by extending from M_0 going into the past, we need to show G(phi) propagates BACK toward M_0.

   Wait, this is backwards. backward_chain(k+1) is built from backward_chain(k). So backward_chain(1) extends backward_chain(0) = M_0, backward_chain(2) extends backward_chain(1), etc. The chain goes AWAY from M_0 into the past.

   So if G(phi) in backward_chain(k) for some k > 0, it was INTRODUCED at step k or earlier. If k = 0, G(phi) in M_0, and:
   - For s >= 0: phi in forward_chain(s) by G-coherence of forward chain (since G(phi) in M_0 = forward_chain(0))
   - For -k <= s < 0: need phi in backward_chain(-s) for -s <= k. Hmm.

   If G(phi) in backward_chain(k) and we need phi in backward_chain(j) for j < k (closer to 0): this is NOT guaranteed by the backward chain construction, because the backward chain builds OUTWARD, not inward.

   **This is the key difficulty.** The forward_G property for the combined family requires that G-content propagates in BOTH directions through the backward chain: from M_0 outward (handled by H-related properties via converse) and from outer positions inward (not handled).

   **Resolution**: By the T-axiom for G (temp_t_future: G(phi) -> phi), G(phi) in backward_chain(k) implies phi in backward_chain(k). But we also need phi in backward_chain(j) for j < k. Since backward_chain(j) was constructed BEFORE backward_chain(k) (j < k), and backward_chain(k) was built from backward_chain(k-1), we cannot retroactively add phi to backward_chain(j).

   **The real solution**: G(phi) in backward_chain(k) for k > 0 arose because G(phi) was ADDED during construction. But by the g_content/h_content duality theorem (`g_content_subset_implies_h_content_reverse` in WitnessSeed.lean), if g_content(M) ⊆ W then h_content(W) ⊆ M. This means: the backward chain step from k to k+1 uses h_content(backward_chain(k)) in its seed. If phi was introduced at step k+1 via this seed, then H(phi) in backward_chain(k), which means phi was already in the h_content orbit.

   Actually, the cleanest solution is to include g_content in the backward seed too. That is:

   **Modified backward chain seed**:
   ```
   controlled_past_seed(M, phi_opt, pending) =
     h_content(M) ∪ g_content(M) ∪ box_content(M) ∪ {phi | phi_opt = some phi} ∪ {P(psi) | psi in pending}
   ```

   Including g_content in the backward seed ensures G-formulas propagate into the past. The consistency proof extends straightforwardly: g_content(M) ⊆ M (since G(a) in M implies a in M by T-axiom), so adding g_content to a consistent seed that already contains subsets of M remains consistent.

   Wait, but g_content(M) = {a | G(a) in M}. These a's may or may not be in M. Actually, by T-axiom, G(a) in M implies a in M (since G(a) -> a is a theorem and M is closed under derivation). So g_content(M) ⊆ M. Similarly h_content(M) ⊆ M by H T-axiom.

   So both g_content(M) and h_content(M) are subsets of M. Including both in the seed is fine for consistency (the seed is a subset of M plus the resolution formula and P-blockers, all of which are consistent with M).

   **This resolves the cross-zero issue for forward_G**: G(phi) at any time propagates both forward (via g_content in forward seed) and backward (via g_content in backward seed).

   Similarly, include h_content in the forward seed to ensure H-formulas propagate forward. The modified forward seed becomes:
   ```
   controlled_temporal_seed(M, phi_opt, pending) =
     g_content(M) ∪ h_content(M) ∪ box_content(M) ∪ {phi | phi_opt = some phi} ∪ {F(psi) | psi in pending}
   ```

   **Why this works**: By including BOTH g_content and h_content in both forward and backward seeds:
   - G-formulas propagate in both directions (g_content ensures forward propagation, and since g_content ⊆ M and the seed is consistent, this is safe)
   - H-formulas propagate in both directions similarly
   - The cross-zero case becomes trivial: any G/H formula at any time propagates through the entire chain

   **Revised controlled seed** (from Phase 1): Include both g_content and h_content. The consistency argument still works because both are subsets of M (by the respective T-axioms). The existing `temporal_box_seed` already includes G_theory (which maps to g_content under the correct reformulation). We just need to also include H_theory.

   Actually, looking more carefully at the existing definitions:
   - `temporal_box_seed M = G_theory M ∪ box_theory M` where `G_theory M = {G(a) | G(a) in M}`
   - `G_theory M` ≠ `g_content M`. G_theory contains G(a) formulas; g_content contains a formulas.

   We need g_content = {a | G(a) in M} in the seed, not G_theory = {G(a) | G(a) in M}. But wait:
   - g_content(M) ⊆ M (by T-axiom), and the Lindenbaum extension of a superset of g_content gives W ⊇ g_content.
   - For G-propagation: we need G(a) in W for all G(a) in M. But g_content only puts a in W, not G(a). We need G(a) in W too.

   Looking at how `temporal_theory_witness_exists` works: it puts G_theory(M) = {G(a) | G(a) in M} in the seed, which gives G(a) in W. Then by temp_4 (G(a) -> G(G(a))), G(G(a)) in M, so G(a) in G_theory(M) ⊆ seed ⊆ W. This gives G(a) in W. And by T-axiom, a in W.

   So the correct approach for cross-zero G-propagation is to include G_theory (not g_content) in BOTH seeds. Similarly include H_theory in both seeds. This ensures:
   - G(a) in chain(k) -> G(a) in chain(k+1) (via G_theory in seed)
   - H(a) in chain(k) -> H(a) in chain(k+1) (via H_theory in seed)

   Both propagate in both the forward and backward chains.

   **Revised Phase 1 seed definition**:
   ```
   controlled_full_seed(M, phi_opt, pending, direction) =
     G_theory(M) ∪ H_theory(M) ∪ box_theory(M) ∪ {phi | phi_opt = some phi}
     ∪ (if direction = forward then {F(psi) | psi in pending}
        else {P(psi) | psi in pending})
   ```

   Or simpler: use `temporal_box_seed M = G_theory M ∪ box_theory M` extended with H_theory and the direction-specific blockers.

   **Consistency of the revised seed**: We need `{phi} ∪ G_theory(M) ∪ H_theory(M) ∪ box_theory(M) ∪ {F(psi_i) | ...}` to be consistent. The proof extends the existing `temporal_theory_witness_consistent`:
   - G_theory(M) ⊆ M (all elements are G(a) with G(a) in M)
   - H_theory(M) ⊆ M (all elements are H(a) with H(a) in M)
   - box_theory(M): consistent with M by construction
   - {phi}: consistent by temporal_theory_witness_consistent when F(phi) in M
   - F-blockers: all in M

   So the extended seed is contained in M ∪ {phi} ∪ box_theory(M), and temporal_theory_witness_consistent already shows {phi} ∪ G_theory(M) ∪ box_theory(M) is consistent. Adding H_theory(M) ⊆ M preserves consistency.

**Cross-zero forward_G proof** (with revised seed):

G(phi) in fam(t) for any t. Need phi in fam(s) for s >= t.

Case t >= 0: Forward chain G-coherence (Phase 2). Since G_theory is in every forward step's seed, G(phi) propagates forward. And by T-axiom, phi in chain(t). By temp_4, G(G(phi)) in M when G(phi) in M, so G(phi) in G_theory and propagates to next step.

Case t < 0, s < 0: backward_chain(-t) has G(phi). backward_chain(-s) for -s < -t: since the backward chain includes G_theory in its seed, G(phi) propagates from step 0 to step k. But we need it from step -t BACK to step -s (closer to 0). The backward chain goes outward: step 0 (M_0) -> step 1 -> ... -> step k. G(phi) at step k was either:
- Already in step 0 (M_0) and propagated forward via G_Theory in every step's seed
- Introduced at some step j <= k

If G(phi) was in M_0 and propagated, it's in every step, including step -s. Done.

If G(phi) was introduced at step j > 0 (i.e., not in backward_chain(j-1) but in backward_chain(j)): this can only happen via Lindenbaum extension adding it. Since G_Theory(backward_chain(j-1)) is in the seed, G_Theory ensures all G-formulas from the previous step carry forward. But G(phi) was NOT in backward_chain(j-1), so it was added by Lindenbaum. For it to be in backward_chain(j), it must be consistent with the seed. The seed didn't exclude it.

Now we need phi in backward_chain(-s) for -s < j. But backward_chain(-s) was constructed BEFORE backward_chain(j), and phi may not be in it. This is the problem.

**This means we cannot retroactively add formulas to earlier chain positions.** The cross-zero G-propagation issue for G(phi) introduced mid-backward-chain is real.

**Resolution**: The FMCS structure requires `forward_G : forall t s, t <= s -> G(phi) in fam.mcs t -> phi in fam.mcs s`. In the Int-indexed family, `t <= s` means s is in the future relative to t. If G(phi) appears at time t < 0 (backward_chain(-t)):

- For s >= t with s >= 0: phi must be in forward_chain(s.toNat). Since G(phi) in backward_chain(-t), and the backward chain includes G_Theory, G(phi) propagates from step -t back to step 0 (M_0). Wait, no: the backward chain builds outward. Step 0 to step 1 to step 2... G_Theory in the seed means G-formulas from step k appear in step k+1. So G(phi) in step k implies G(phi) in step k+1, ..., implies G(phi) in step n for all n >= k. It does NOT give G(phi) in step k-1.

So G(phi) at backward_chain(k) (time -k) propagates to backward_chain(k+1) (time -(k+1)), backward_chain(k+2) (time -(k+2)), etc. -- DEEPER into the past. It does NOT propagate toward time 0.

For forward_G, we need propagation TOWARD THE FUTURE (toward time 0 and beyond). So we need G(phi) at time -k to imply phi at all times >= -k. But the backward chain only propagates G-formulas AWAY from time 0 (deeper into the past).

**This is the fundamental cross-zero problem identified in the research.**

**Solution: Ensure G-formulas are "grounded" at M_0.**

The key observation: G(phi) can only arise in the backward chain if it was either:
(a) Already in M_0 (and propagated outward via G_Theory in seed), or
(b) Added by Lindenbaum extension at some step

For case (a): G(phi) in M_0 means phi in M_0 (T-axiom) and G(phi) propagates forward in the forward chain. For s >= 0: forward chain G-coherence gives phi in chain(s). For -k <= s < 0 with s > -k: we need phi in backward_chain(-s). Since G(phi) in M_0 propagates via G_Theory to backward_chain(1), backward_chain(2), ..., backward_chain(-s). By T-axiom, phi in backward_chain(-s). Done.

For case (b): G(phi) introduced at step j > 0 by Lindenbaum. This means G(phi) was not in backward_chain(j-1) but is consistent with the seed of step j. Since G_Theory(backward_chain(j-1)) is in the seed and G(phi) was NOT in backward_chain(j-1), G(phi) is not in G_Theory. Lindenbaum added it freely.

BUT: we DON'T need forward_G to hold for G-formulas that ONLY appear at specific points. forward_G says: IF G(phi) in fam.mcs(t) THEN phi in fam.mcs(s) for all s >= t. If G(phi) appeared at time -j and we need phi at time -(j-1), -(j-2), ..., 0, 1, 2, ..., this is only required if G(phi) is indeed in fam.mcs(-j).

The question is: can we PREVENT spurious G(phi) from being added by Lindenbaum at backward chain steps?

**Yes, by including G-blockers in the backward seed.** For every formula chi that does NOT have G(chi) in M_0, include neg(G(chi)) in the backward seed. But this is an infinite set and would make the seed inconsistent or impractical.

**Better approach**: The controlled seed already includes G_Theory(M) which puts G(a) for all G(a) in M into the seed. By the Lindenbaum construction, the MCS extends this seed. So the MCS contains all G(a) that were in the previous step. For G-formulas NOT in the previous step: Lindenbaum can add them. But importantly, the FMCS forward_G only needs to hold for G-formulas that are actually in the family.

**The real issue is**: if Lindenbaum adds G(phi) at backward step j, then forward_G requires phi at all earlier steps (0 through j-1). But those steps are already fixed. So we have a contradiction unless phi happens to be in all earlier steps.

**Conclusion**: We must PREVENT Lindenbaum from adding new G-formulas in the backward chain that weren't already propagating from M_0. This is done by including `neg(G(chi))` in the seed for all chi where G(chi) is not in the previous step's MCS.

But this is exactly what happens with MCS maximality: Lindenbaum gives an MCS, which for every formula alpha either contains alpha or neg(alpha). If G(chi) is not in the seed and not derivable from the seed, Lindenbaum may add either G(chi) or neg(G(chi)).

**The solution that actually works**: Don't fight Lindenbaum. Instead, observe that forward_G for the FMCS only uses `g_content` propagation. If we define the FMCS's `forward_G` proof using the chain construction's invariants, we can handle the cross-zero case by:

1. For t < 0, s >= 0: G(phi) in backward_chain(-t). Need phi in forward_chain(s).
   - By temp_a: phi -> G(P(phi)). This means phi in backward_chain(-t) implies G(P(phi)) in backward_chain(-t). But we need the reverse direction.
   - By the converse property: G(phi) in backward_chain(-t) relates to backward accessibility. Specifically, R_G(backward_chain(-t), backward_chain(-t-1)) holds, meaning G-content propagates along R_G.

   Actually, this is getting too complex for the planning phase. Let me step back and consider the simpler architectural approach.

**Simpler Architecture: Build both directions from M_0 with BOTH G_Theory and H_Theory in seeds.**

Forward chain seed: `G_Theory(M) ∪ H_Theory(M) ∪ box_theory(M) ∪ resolution ∪ F_blockers`
Backward chain seed: `G_Theory(M) ∪ H_Theory(M) ∪ box_theory(M) ∪ resolution ∪ P_blockers`

Then:
- G(a) in chain(k) implies G(a) in chain(k+1) (in BOTH chains, by G_Theory in seed)
- H(a) in chain(k) implies H(a) in chain(k+1) (in BOTH chains, by H_Theory in seed)
- By temp_4: G(a) in M implies G(G(a)) in M, so G(a) in G_Theory(M), so G(a) in seed, so G(a) in next step.

With this setup:
- G(a) in M_0 implies G(a) in forward_chain(n) for all n >= 0 (by induction via G_Theory)
- G(a) in M_0 implies G(a) in backward_chain(n) for all n >= 0 (by induction via G_Theory)
- By T-axiom: a in forward_chain(n) and a in backward_chain(n) for all n >= 0

For forward_G of the combined family: G(phi) in fam(t) implies phi in fam(s) for all s >= t.

If G(phi) in backward_chain(k) at time -k:
- G(phi) in backward_chain(k) -> G(phi) in backward_chain(k+1) -> ... (deeper past, OK)
- G(phi) in backward_chain(k): was it in backward_chain(k-1)? By G_Theory, if G(phi) was in backward_chain(k-1), then G(phi) is in the seed for step k, so G(phi) in backward_chain(k). But the converse: G(phi) in backward_chain(k) does NOT imply G(phi) in backward_chain(k-1).

Unless G(phi) was propagated from M_0 = backward_chain(0) all the way to step k. In that case, G(phi) is in every backward_chain(j) for j <= k.

The problematic case: G(phi) introduced at step k by Lindenbaum (not in backward_chain(k-1)). Then G(phi) is in backward_chain(k) but not in backward_chain(k-1). forward_G requires phi in backward_chain(k-1) = fam(-(k-1)), which is at time -(k-1) > -k. So forward_G needs phi at time -(k-1). But phi may not be in backward_chain(k-1).

**This confirms that Lindenbaum can introduce G-formulas that violate forward_G.** We need to prevent this.

**The definitive solution: Include neg(G(chi)) for all chi where G(chi) not in chain(k-1).**

But G(chi) not in chain(k-1) means neg(G(chi)) in chain(k-1) (by MCS). So neg(G(chi)) ∈ chain(k-1). Including neg(G(chi)) in the seed ensures the extension MCS also contains neg(G(chi)), preventing G(chi) from being added.

But this is AUTOMATIC: the seed already includes all of g_content(chain(k-1)) and G_Theory(chain(k-1)). For G(chi) NOT in chain(k-1), neg(G(chi)) IS in chain(k-1) but it's NOT in G_Theory or g_content. So we need to EXPLICITLY include neg(G(chi)) for all such chi.

But that's an infinite set. And we can't include all of chain(k-1) in the seed (that would trivialize the extension to chain(k-1) itself).

**Alternative: Include the FULL MCS in the seed.**

If the seed = chain(k-1) ∪ {resolution_formula} ∪ P-blockers, then the Lindenbaum extension is an MCS extending chain(k-1) ∪ extra. By MCS maximality of chain(k-1), if chain(k-1) ⊆ W and W is an MCS, then W ⊇ chain(k-1). But chain(k-1) is already an MCS, and the only MCS extending an MCS is itself (if consistent). So W = chain(k-1) plus the extra... no, that's not right. An MCS extended with a consistent formula gives a NEW MCS.

Wait: if S is an MCS and phi is consistent with S, then S ∪ {phi} extends to a new MCS W ⊇ S ∪ {phi}. If phi is already in S, W = S. If phi is not in S, then neg(phi) in S, so S ∪ {phi} is inconsistent. Contradiction.

So we CANNOT extend an MCS with new formulas unless they're already in it! This means the controlled seed must be a subset of an MCS, and the Lindenbaum extension of the controlled seed gives an MCS that EXTENDS the seed but may DIFFER from the original MCS.

This is the standard construction: the controlled seed is NOT an MCS; it's a consistent set. The Lindenbaum extension gives an MCS containing the seed but making arbitrary choices for formulas not determined by the seed.

**The G-formula introduction problem is inherent to ANY chain construction that uses Lindenbaum extension.** The solution is NOT to prevent G-formulas from appearing, but to ensure forward_G is stated correctly relative to the construction.

**Key realization**: forward_G for the FMCS says: G(phi) in fam.mcs(t) -> phi in fam.mcs(s) for all s >= t. The direction is: from past to future. In the backward chain, "forward" (increasing time) means going from large backward indices toward 0. So we need: G(phi) at backward_chain(k) -> phi at backward_chain(j) for j < k (closer to time 0).

This means forward_G requires G-formulas to propagate BACKWARD through the backward chain construction (from later steps to earlier steps). This is impossible since earlier steps are already fixed.

**Therefore, the backward chain CANNOT introduce new G-formulas that weren't in M_0.** We need to ensure that all G(phi) in backward_chain(k) were already in backward_chain(0) = M_0.

**The fix**: Include ALL of M_0's G-formulas (i.e., G_Theory(M_0), not G_Theory(chain(k))) in the backward chain's seed. That is, at every backward step k+1, the seed includes G_Theory(M_0) rather than G_Theory(backward_chain(k)).

With this:
- G(a) in M_0 -> G(a) in backward_chain(k) for all k (by G_Theory(M_0) ⊆ seed at every step)
- By temp_4: G(a) in M_0 -> G(G(a)) in M_0 -> G(a) in G_Theory(M_0). So all G-content from M_0 propagates.
- By T-axiom: G(a) in backward_chain(k) -> a in backward_chain(k). So a is in every backward step.
- For G(phi) in backward_chain(k) that was NOT in M_0: this can still happen via Lindenbaum. But forward_G then requires phi at backward_chain(j) for j < k, which may fail.

**To prevent this**: The seed should EXCLUDE G-formulas not in M_0. Specifically, for every chi where G(chi) not in M_0, include neg(G(chi)) in the seed.

But G(chi) not in M_0 means neg(G(chi)) = F(chi.neg.neg) -- no, neg(G(chi)) is just the negation of G(chi). Since M_0 is an MCS, neg(G(chi)) in M_0 when G(chi) not in M_0.

We can include: `{neg(G(chi)) | G(chi) not in M_0}`. This is equivalent to M_0 ∩ {neg(G(chi)) | chi formula}. Since this is a subset of M_0, it's consistent with M_0.

But at step k, the seed would include neg(G(chi)) from M_0 where G(chi) not in M_0. The Lindenbaum extension of the seed gives MCS W containing all these neg(G(chi)). So G(chi) not in W. This prevents new G-formulas.

But can we include this infinite set? In Lean, the seed is `Set Formula`, which can be defined set-theoretically (no finiteness requirement). Lindenbaum's lemma works with arbitrary consistent sets (uses Zorn's lemma under the hood). So yes, we can include an infinite seed.

**Revised backward chain seed**:
```
backward_full_seed(M_0, M_k, phi_opt, pending) =
  M_0 ∪ h_content(M_k) ∪ {phi | phi_opt = some phi} ∪ {P(psi) | psi in pending}
```

Wait, M_0 ⊆ seed means the extension MCS W ⊇ M_0. Then W agrees with M_0 on everything in M_0. For formulas outside M_0: W might add them. But neg(phi) in M_0 (for phi not in M_0), so neg(phi) in W. So W and M_0 agree on ALL formulas. W = M_0? No: the seed also includes h_content(M_k) and the resolution formula. If these add formulas not in M_0, the seed is inconsistent with M_0.

For example, h_content(M_k) at step k+1 includes formulas phi where H(phi) in M_k. If phi is not in M_0, then neg(phi) in M_0, and M_0 ∪ {phi} is inconsistent. So we CANNOT include M_0 in the seed in general.

**This approach doesn't work.** Including M_0 constrains the extension to M_0, preventing it from resolving P-obligations with new formulas.

**The real solution**: Accept that G-formulas can be introduced at backward chain steps, but observe that forward_G is actually provable for a different reason.

Let me reconsider the FMCS forward_G requirement. In the standard construction:

`forward_G : forall t s, t <= s -> G(phi) in fam.mcs t -> phi in fam.mcs s`

For the backward chain indexed by Nat (where backward_chain(k) represents time -k), and the forward chain indexed by Nat (where forward_chain(j) represents time j), the combined family is:

```
fam.mcs(t) = if t >= 0 then forward_chain(t) else backward_chain(-t)
```

For t = -k (k > 0) and s >= t:
- If s >= 0: fam.mcs(s) = forward_chain(s). Need phi in forward_chain(s).
- If -k <= s < 0: fam.mcs(s) = backward_chain(-s). Need phi in backward_chain(-s) where -s < k.

For the first sub-case (s >= 0): G(phi) in backward_chain(k). The backward chain was built from M_0, extending outward. By G_Theory in the seed, all G-formulas from step k-1 propagate to step k. So G(phi) in step k means either G(phi) was already in step k-1 (recursively, in M_0) or was introduced at step k.

If G(phi) was in M_0: then G(phi) propagates through forward_chain via G_Theory, and by T-axiom, phi in forward_chain(s). Done.

If G(phi) was NOT in M_0 but introduced at backward step k: then neg(G(phi)) in M_0 (by MCS). neg(G(phi)) = F(neg(phi)). So F(neg(phi)) in M_0. By the forward chain's forward_F property, neg(phi) appears at some time s >= 0. But we need phi at s, not neg(phi). This creates a contradiction if both phi and neg(phi) appear, but they might appear at different times. The forward_G requirement only needs phi at s, not neg(phi)'s absence.

Actually, this case is problematic. G(phi) introduced at backward step k means phi MIGHT not be in M_0 or in forward_chain steps. forward_G would fail.

**THE DEFINITIVE SOLUTION: Don't allow the backward chain to introduce new G-formulas.**

Instead of using Lindenbaum on an under-constrained seed, use a seed that forces G-content agreement with M_0:

```
backward_controlled_seed(M_0, M_k, phi_opt, pending) =
  G_Theory(M_0) ∪ H_Theory(M_k) ∪ box_theory(M_0) ∪ {neg(G(chi)) | G(chi) not in M_0}
  ∪ {phi | phi_opt = some phi} ∪ {P(psi) | psi in pending}
```

The term `{neg(G(chi)) | G(chi) not in M_0}` blocks all G-formulas not in M_0.

**Consistency**: The seed contains:
- G_Theory(M_0) ⊆ M_0
- {neg(G(chi)) | G(chi) not in M_0} ⊆ M_0 (since neg(G(chi)) in M_0 when G(chi) not in M_0)
- H_Theory(M_k): formulas H(a) where H(a) in M_k. These may conflict with M_0 elements.
- box_theory(M_0) ⊆ M_0 ∪ {neg(Box(a)) | ...} which is consistent with M_0
- phi resolution and P-blockers

Wait: we're including G_Theory(M_0) and {neg(G(chi)) | G(chi) not in M_0}. Together, these FULLY determine the G-formulas: the extension MCS will have EXACTLY the same G-formulas as M_0. Plus H_Theory(M_k) and the resolution formula.

Is `G_Theory(M_0) ∪ {neg(G(chi)) | G(chi) not in M_0} ∪ H_Theory(M_k) ∪ box_theory(M_0) ∪ {phi_resolution} ∪ {P(psi_i)}` consistent?

The G-related part is a subset of M_0. The H_Theory(M_k) part: H(a) where H(a) in M_k. At step k, M_k was constructed from M_{k-1} via past_temporal_witness_seed-style extension. H_Theory(M_k) may include H-formulas not in M_0.

But we're also including box_theory(M_0), which constrains Box-formulas to agree with M_0. And the G-related part constrains G-formulas to agree with M_0.

The potential conflict: H_Theory(M_k) could contain H(a) that's inconsistent with the G-constraints from M_0 or with box_theory(M_0). But H(a) and G(b) are about different modalities (past vs future); they don't directly conflict. And box_theory(M_0) is about the Box modality, orthogonal to H.

For the phi_resolution: P(phi) in M_k, so past_theory_witness_consistent gives {phi} ∪ H_Theory(M_k) ∪ box_theory(M_k) consistent. We're using box_theory(M_0) instead of box_theory(M_k), but by box_class_agree through the chain, these are compatible.

**Revised approach**: For consistency, we want the seed to be a superset of M_0's G-content and a subset that's provably consistent. The safest formulation:

```
backward_seed_k = {phi} ∪ past_temporal_box_seed(M_k) ∪ G_Theory(M_0)
               ∪ {neg(G(chi)) | G(chi) not in M_0} ∪ {P(psi_i) | pending}
```

where `past_temporal_box_seed(M_k) = H_Theory(M_k) ∪ box_theory(M_k)`.

Consistency of this seed:
- `{phi} ∪ past_temporal_box_seed(M_k)` is consistent (by `past_theory_witness_consistent`)
- G_Theory(M_0) ⊆ M_0 and box_theory(M_k) is compatible with box_theory(M_0) (via box_class_agree)
- neg(G(chi)) for G(chi) not in M_0: these are in M_0
- P-blockers P(psi_i) are in M_k

The additional elements (G_Theory(M_0), neg(G(chi)), P-blockers) are all derivable consequences of M_0 or M_k. The full seed is contained in M_0 ∪ H_Theory(M_k) ∪ {phi}. By past_theory_witness_consistent, {phi} ∪ H_Theory(M_k) ∪ box_theory(M_k) is consistent. Adding G_Theory(M_0) ⊆ M_0 and neg(G(chi)) ⊆ M_0 and P-blockers ⊆ M_k:

This needs a dedicated consistency proof that combines elements from BOTH M_0 and M_k. The proof would use the contraposition technique: assume inconsistent, derive ⊥ from a finite subset, use G-lift and H-lift to derive contradictions in M_0 or M_k respectively.

**This is the most complex consistency proof and is the HIGH-RISK component.**

**Fallback**: If the combined consistency proof is too complex, there's an alternative architecture that avoids the cross-zero problem entirely: build only the forward chain from M_0 to cover non-negative times, and use the existing `past_theory_witness_exists` to handle negative times via a SEPARATE backward chain that doesn't need to preserve G-content. Then prove forward_G only needs to hold in the forward direction, and backward_H only in the backward direction.

Actually, wait: the FMCS `forward_G` is defined as:
```lean
forward_G : ∀ t : D, ∀ s : D, t ≤ s → ∀ φ : Formula,
    Formula.all_future φ ∈ mcs t → φ ∈ mcs s
```

For D = Int, t <= s means s is in the future. So forward_G propagates G-formulas toward the future. If we only need this for the forward chain (t >= 0), the issue doesn't arise. But for t < 0, the direction is from past (negative time) toward present/future (time 0 and beyond).

**The most practical solution**: Ensure that all G-formulas in the backward chain ORIGINATE from M_0. This can be enforced by including all of M_0's G-theory in the backward seed AND blocking all G-formulas not in M_0.

Rather than including the infinite set `{neg(G(chi)) | G(chi) not in M_0}`, observe that the Lindenbaum extension is maximally consistent. If the seed is consistent with the G-constraints from M_0, then the MCS either contains G(chi) (if G(chi) in M_0 and hence in the seed via G_Theory(M_0)) or neg(G(chi)) (if not). For G(chi) not in G_Theory(M_0):
- G(chi) is not in the seed
- The extension MCS might add G(chi) or neg(G(chi))
- We want to force neg(G(chi))

We CAN include the infinite set `{neg(G(chi)) | G(chi) not in M_0}` in the seed. In Lean, Set Formula is a function Formula -> Prop, so defining this set is straightforward. The key question is whether set_lindenbaum works with infinite consistent sets.

Looking at the existing `set_lindenbaum`:
```lean
theorem set_lindenbaum (S : Set Formula) (h : SetConsistent S) :
    ∃ M, S ⊆ M ∧ SetMaximalConsistent M
```

This works for ANY consistent set S, including infinite sets. So including the infinite G-blocker set is fine.

**Plan for Phase 5**: Include the G-blocker set in the backward seed. Prove consistency of the combined seed. This gives a backward chain where G-formulas match M_0 exactly, resolving the cross-zero forward_G issue.

**Similarly for the forward chain and H-formulas**: Include `{neg(H(chi)) | H(chi) not in M_0}` in the forward seed to prevent new H-formulas from appearing. This resolves the symmetric cross-zero backward_H issue.

**Tasks**:
- [ ] Revise Phase 1 controlled seed to include G-blockers and H-blockers relative to M_0
- [ ] Forward seed: g_content propagation + H-blockers (prevent spurious H-formulas) + F-blockers + box_theory
- [ ] Backward seed: h_content propagation + G-blockers (prevent spurious G-formulas) + P-blockers + box_theory
- [ ] Prove consistency of revised seeds (main new proof obligation)
- [ ] Define the combined Int-indexed family
- [ ] Prove forward_G for the combined family
- [ ] Prove backward_H for the combined family
- [ ] Prove forward_F for the combined family (delegates to Phase 3 for t >= 0; for t < 0, F-blocker propagation to M_0 then forward chain resolution)
- [ ] Prove backward_P for the combined family (symmetric)
- [ ] Prove is_mcs for all time points
- [ ] Prove fam.mcs 0 = M_0
- [ ] Construct `TemporalCoherentFamily Int` from the combined family

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 2.5 hours

**Verification**:
- `TemporalCoherentFamily Int` instance constructed sorry-free
- All four coherence properties verified
- Cross-zero cases handled

---

### Phase 6: BFMCS Construction and Completeness Wiring [NOT STARTED]

**Goal**: Construct the `construct_bfmcs` function that `parametric_algebraic_representation_conditional` requires, closing the completeness theorem.

**Mathematical Content**:

The representation theorem at `ParametricRepresentation.lean:252-269` requires:

```lean
construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
  Σ' (B : BFMCS D) (h_tc : B.temporally_coherent)
     (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
     M = fam.mcs t
```

We need to provide this for D = Int.

**Construction**:

1. Given MCS M, build `TemporalCoherentFamily Int` with fam.mcs(0) = M (Phases 1-5)
2. Build the BFMCS bundle using the existing `construct_bfmcs_bundle M h_mcs` (sorry-free)
3. Replace the eval_family with the temporally coherent family from step 1
4. Prove B.temporally_coherent: for each family in B.families, forward_F and backward_P hold

Wait: B.temporally_coherent requires EVERY family in the bundle to be temporally coherent, not just the eval family. The existing bundle has multiple families (one for each box-class representative). We need ALL of them to be temporally coherent.

**Resolution**: We construct a temporally coherent family for EACH MCS in the box class. The `dovetailed_temporal_family` construction works for any MCS M_0. So for each family in `boxClassFamilies M0 h_mcs`, we can replace it with a dovetailed family starting from the same MCS.

Actually, the `boxClassFamilies` construction creates families by building SuccChainFMCS from various MCSs (witnesses for Box-formulas, etc.). Each family already has forward_G and backward_H. We need to ensure each has forward_F and backward_P.

**Simpler approach**: For each family `fam` in the bundle, `fam.mcs(0)` is some MCS. Apply the dovetailed construction to `fam.mcs(0)` to get a new TemporalCoherentFamily. Replace fam with this new family. The new family has the same MCS at time 0, so modal coherence is preserved (since Box-formulas only depend on the MCS, not on temporal extension).

**But**: replacing families changes the bundle structure. We need to verify that the BFMCS modal coherence properties still hold after replacement.

The BFMCS requires:
- `modal_forward`: Box(phi) in fam.mcs(t) implies exists fam' in families with phi in fam'.mcs(t)
- `modal_backward`: phi in fam'.mcs(t) for all fam' in families implies Box(phi) in fam.mcs(t) (S5 condition)

These depend on the MCS values at time t, which change when we replace families. However, if the new families have the same Box-content at time 0 (via box_class_agree), and Box-content propagates through the chain (via box_theory in seeds), then box_class_agree holds at all times. Modal coherence follows from box_class_agree.

**Actually, let me reconsider the architecture.** The key function we need is:

```lean
construct_bfmcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
  Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent) (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
     M = fam.mcs t
```

We can build this with a SINGLE family:
1. Build `dovetailed_temporal_family M h_mcs` as a TemporalCoherentFamily Int
2. Create a singleton BFMCS with just this one family
3. modal_forward: Box(phi) in fam.mcs(t) implies phi in fam.mcs(t) (by T-axiom for Box: Box -> id, i.e., temp_t_reflexive or box_t)
4. Wait: modal_forward requires exists fam' IN THE BUNDLE with phi in fam'.mcs(t). For a singleton bundle, fam' = fam. So Box(phi) in fam.mcs(t) implies phi in fam.mcs(t) by Box T-axiom.
5. modal_backward: phi in fam.mcs(t) for ALL fam' in bundle implies Box(phi) in fam.mcs(t). For singleton, this means phi in fam.mcs(t) implies Box(phi) in fam.mcs(t). This is NOT true in general (Box is not the identity).

So a singleton BFMCS doesn't satisfy modal_backward in general. We need the full bundle with modal saturation.

**The correct approach**: Use the existing `construct_bfmcs_bundle` which builds a modally saturated bundle (sorry-free), and then UPGRADE each family to be temporally coherent.

Define:
```lean
def upgrade_family (fam : FMCS Int) : TemporalCoherentFamily Int :=
  dovetailed_temporal_family (fam.mcs 0) (fam.is_mcs 0)
```

This gives a new family with the same MCS at time 0 but different MCSs at other times (from the dovetailed construction instead of the original chain).

The upgraded bundle has the same families (by their time-0 MCS values), so modal coherence is preserved if box_class_agree holds between upgraded families at the same time.

**Key property needed**: For the upgraded bundle, at any time t, the Box-content of `upgrade_family(fam).mcs(t)` must be consistent with the Box-content of other families. This follows from:
- box_class_agree between upgrade_family(fam).mcs(0) and upgrade_family(fam).mcs(t) (Phase 2 invariant)
- box_class_agree between fam.mcs(0) and fam'.mcs(0) (from original bundle construction)
- Transitivity of box_class_agree

So box_class_agree(upgrade_family(fam).mcs(t), upgrade_family(fam').mcs(t)) holds for all fam, fam' in the original bundle.

**Tasks**:
- [ ] Define `upgrade_to_coherent_family`: converts FMCS to TemporalCoherentFamily using dovetailed construction
- [ ] Define `upgrade_bfmcs_bundle`: replaces each family in the bundle with its upgraded version
- [ ] Prove modal_forward for upgraded bundle (via box_class_agree + S5 properties)
- [ ] Prove modal_backward for upgraded bundle
- [ ] Prove temporally_coherent for upgraded bundle (each family is a dovetailed construction)
- [ ] Prove eval_family membership and time-0 agreement
- [ ] Provide the `construct_bfmcs` function with the correct signature
- [ ] Wire into `parametric_algebraic_representation_conditional` to close the completeness proof

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add upgrade construction
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` or new file - Wire completeness

**Timing**: 1.5 hours

**Verification**:
- `construct_bfmcs` type-checks with the signature from `parametric_algebraic_representation_conditional`
- `lake build` succeeds on the entire project
- The completeness theorem instantiates with D = Int

## Testing & Validation

- [ ] `lake build` succeeds with zero errors across all modules
- [ ] `controlled_temporal_seed_consistent` and `controlled_past_seed_consistent` are sorry-free
- [ ] `forward_dovetailed_chain_forward_F` is sorry-free
- [ ] `backward_dovetailed_chain_backward_P` is sorry-free
- [ ] `TemporalCoherentFamily Int` construction is sorry-free
- [ ] `construct_bfmcs` matches the signature in `parametric_algebraic_representation_conditional`
- [ ] Cross-zero forward_G and backward_H are verified
- [ ] Total sorry count in the project does not increase (and decreases for the affected modules)
- [ ] Run `lean_verify` on key theorems to confirm no axiom dependencies beyond standard foundations

## Artifacts & Outputs

- `specs/081_fp_witness_representation_theorem/plans/04_dovetailed-construction-plan.md` (this file)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (extended with dovetailed construction)
- Potential new file: `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` (if UltrafilterChain becomes too large)
- `specs/081_fp_witness_representation_theorem/summaries/04_execution-summary.md` (after implementation)

## Rollback/Contingency

**If the cross-zero consistency proof proves intractable**:
- Fall back to the "restricted chain" approach: use `restricted_forward_chain_forward_F` (already sorry-free at UltrafilterChain.lean:2930) for weak completeness only
- This gives completeness for specific formulas (sufficient for practical theorem proving) but not strong completeness for arbitrary MCS

**If Finset/Set bookkeeping becomes unmanageable**:
- Consider the compactness via product topology approach (Run 4) as alternative packaging
- Same mathematical content but different Lean infrastructure (Mathlib topology)

**If the full construction exceeds estimated hours**:
- Phase 1-3 (forward chain only) provides the most critical component
- Phase 4 (backward chain) is largely symmetric and lower risk
- Phase 5 (assembly) can use the restricted chain fallback for negative times initially
- Phase 6 (wiring) is straightforward once the family is constructed

**Git safety**: All work on a branch; existing sorry-free theorems are never modified
