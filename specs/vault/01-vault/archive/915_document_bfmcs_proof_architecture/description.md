# Task 915: Document BFMCS proof architecture and remaining lacunae

## Objective

Write comprehensive documentation explaining how the completeness proof works, the two-level bundling architecture, the propagation requirements as construction constraints, and precisely where the remaining gaps (sorries) are and what mathematical arguments close them.

## Key Insights to Document

### 1. Two-Level Bundling Ontology

The completeness proof has two levels of bundling:

- **BFMCS** (Bundled Family of MCS): A single world history — one MCS per time point `t ∈ ℤ`, with temporal coherence constraints. This is what `IndexedMCSFamily` currently represents.
- **BMCS** (Bundle of MCS): A collection of BFMCSes with modal coherence — □φ at time t in one BFMCS implies φ at time t in ALL BFMCSes in the bundle.

The propagation requirements (forward_G, backward_H, forward_F, backward_P) are **BFMCS-internal** constraints. The modal coherence (modal_forward, modal_backward) is a **BMCS-level** constraint between families.

### 2. Propagation Requirements as Construction Constraints

The coherence conditions on a BFMCS are NOT properties we verify after construction — they are **constraints that must be baked into the construction** of each successive MCS in the temporal chain:

- **G φ ∈ MCS_t** → φ must be in the **seed** of every MCS_s for s > t. By 4_G (G φ → G(G φ)), this propagates inductively: G φ enters GContent(MCS_t), which seeds MCS_{t+1}, and G(G φ) ∈ MCS_t ensures G φ ∈ GContent(MCS_t) as well, so G φ persists into MCS_{t+1} and propagates further.

- **¬G φ ∈ MCS_t** (equivalently F(¬φ) ∈ MCS_t) → some future MCS_s must contain ¬φ. This is a **witness obligation**. Unlike G-propagation, F-obligations do NOT propagate automatically through GContent seeds. The formula F(ψ) → G(F(ψ)) is NOT derivable (semantically invalid: ψ could hold at exactly one future time, after which F(ψ) fails). So F-obligations must be **explicitly tracked and scheduled**.

- **H φ ∈ MCS_t** → analogous to G but backward. HContent seeding handles this.

- **¬H φ ∈ MCS_t** (equivalently P(¬φ)) → analogous witness obligation going backward.

### 3. The Consistency Argument

The key enabling lemma is `temporal_witness_seed_consistent` (proven in TemporalCoherentConstruction.lean):

> If F(ψ) ∈ M where M is an MCS, then GContent(M) ∪ {ψ} is consistent.

**Proof sketch**: If GContent(M) ∪ {ψ} were inconsistent, then GContent(M) ⊢ ¬ψ. By generalized temporal K-distribution, {G(χ) | G(χ) ∈ M} ⊢ G(¬ψ). Since each G(χ) ∈ M and M is closed under derivation, G(¬ψ) ∈ M. But F(ψ) = ¬G(¬ψ) ∈ M, contradicting consistency.

The past analog `past_temporal_witness_seed_consistent` is also proven: if P(ψ) ∈ M, then HContent(M) ∪ {ψ} is consistent.

**Critical subtlety**: This lemma requires F(ψ) ∈ M for the SAME M whose GContent is being extended. For the dovetailing chain, when resolving an F-obligation from time s at time t > s, we need F(ψ) ∈ MCS_{t-1} (not just F(ψ) ∈ MCS_s). Since F(ψ) does not automatically persist (F(ψ) → G(F(ψ)) is not derivable), the construction must either:
- (a) Include F(ψ) in the seed at each intermediate step to keep it alive, OR
- (b) Resolve F(ψ) at the very next time step s+1 (avoiding the persistence issue)

Option (b) is simpler but may create consistency issues when multiple F-obligations compete for the same time slot (GContent(MCS_s) ∪ {ψ₁, ψ₂} may be inconsistent even if each GContent(MCS_s) ∪ {ψᵢ} is individually consistent).

Option (a) works because: GContent(MCS_t) ∪ {F(ψ)} is consistent when F(ψ) ∈ MCS_t (since G(¬ψ) ∉ MCS_t, and GContent ⊬ G(¬ψ) by the same argument). But adding BOTH F-obligations AND a witness ψ_j to the seed requires careful analysis.

### 4. Where the 4 Remaining Sorries Are

All 4 sorries are in `DovetailingChain.lean`:

| Line | Sorry | What's needed |
|------|-------|---------------|
| 606 | `forward_G` when t < 0 | Cross-sign propagation: G φ at negative time must reach positive times. Requires showing G φ propagates from backward chain through shared base to forward chain. |
| 617 | `backward_H` when t ≥ 0 | Cross-sign propagation: H φ at positive time must reach negative times. Symmetric to above. |
| 633 | `forward_F` | Witness construction: F(ψ) ∈ MCS_t → ∃ s > t, ψ ∈ MCS_s. Requires dovetailing enumeration of F-obligations with witness placement. |
| 640 | `backward_P` | Witness construction: P(ψ) ∈ MCS_t → ∃ s < t, ψ ∈ MCS_s. Symmetric to forward_F. |

### 5. Cross-Sign Propagation (Sorries 606, 617)

The current DovetailingChain builds two independent half-chains:
- Forward chain: MCS_0, MCS_1, MCS_2, ... (each seeded by GContent of predecessor)
- Backward chain: MCS_0, MCS_{-1}, MCS_{-2}, ... (each seeded by HContent of predecessor)

They share MCS_0 (the base). For G φ ∈ MCS_{-1} to propagate to MCS_1, the argument is:
1. G φ ∈ MCS_{-1} (backward chain step 1)
2. By backward_H structure and axiom A (φ → G(P φ)): G φ should enter the shared base MCS_0
3. From MCS_0, forward_G propagates to MCS_1

The gap: step 2 requires showing that G φ from the backward chain appears in the shared base. This requires either unifying the chains (building one interleaved chain with a single shared Lindenbaum) or proving that G φ ∈ MCS_{-1} implies G φ ∈ MCS_0 via the HContent seeding relationship.

### 6. Witness Construction (Sorries 633, 640)

The dovetailing enumeration approach:
1. Enumerate all (time, formula) pairs: (t, ψ) where F(ψ) ∈ MCS_t
2. Schedule each pair to be resolved at a specific future time
3. At each construction step, the seed includes GContent(MCS_{t-1}) plus the scheduled witness ψ
4. `temporal_witness_seed_consistent` ensures the seed is consistent (provided F(ψ) is still live in MCS_{t-1})

The key challenge is ensuring ONE witness per time step (to use the consistency lemma) while eventually resolving ALL obligations (infinitely many, from all times). The dovetailing enumeration over ℕ × Formula handles this via a bijection ℕ ↔ ℕ × ℕ (Cantor pairing).

## Deliverables

1. Architecture overview document in `docs/` or `Theories/Bimodal/Metalogic/Bundle/README.md`
2. Detailed doc comments in `DovetailingChain.lean` explaining the proof strategy
3. Doc comments in `TemporalCoherentConstruction.lean` explaining the consistency argument
4. Update `BMCS.lean` and `IndexedMCSFamily.lean` (or `BFMCS.lean` post-rename) with ontology explanation

## Dependencies
- Task 914 (rename should happen first to use correct terminology)

## Language
meta
