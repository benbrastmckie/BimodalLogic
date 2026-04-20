# Chain Construction Sorries — Task 109 Context

Close the 11 active-path sorry sites that are the sole remaining obstacle to a sorry-free `bx_completeness` theorem. These form a dependency diamond rooted in the irreflexive semantics redesign of the canonical chain construction.

## Sorry Sites

### CanonicalModel.lean (6 sorries) — seed consistency and g/h_content identity

| # | Line | Theorem | Issue |
|---|------|---------|-------|
| 1 | 56 | `enriched_seed_consistent` | `g_content(M) ∪ f_carry(M)` consistent — relied on `g_content(M) ⊆ M` via BX1 (removed) |
| 2 | 101 | `fwd_succ_f_carry` | F-carry preservation at non-resolving steps — **genuinely unprovable** as stated (non-resolving branch seeds with `g_content(M)` only) |
| 3 | 117 | `enriched_past_seed_consistent` | `h_content(M) ∪ p_carry(M)` consistent — mirror of #1, relies on BX1' (removed) |
| 4 | 167 | `bwd_pred_p_carry` | P-carry preservation at non-resolving steps — mirror of #2, **genuinely unprovable** |
| 5 | 207 | `g_content_subset_self` | `g_content(M) ⊆ M` — **genuinely false** under irreflexive semantics (requires G(phi)->phi) |
| 6 | 213 | `h_content_subset_self` | `h_content(M) ⊆ M` — mirror of #5, **genuinely false** |

### RootScopedChain.lean (5 sorries) — chain coherence

| # | Line | Theorem | Issue |
|---|------|---------|-------|
| 7 | 1065 | `fwd_chain_forward_F` | F-resolution: prove F(phi) eventually resolved via well-founded induction on defect count. Blocked by BX11 perpetual deferral — `.choose` can indefinitely defer any specific formula. |
| 8 | 1092 | `dd_bfmcs_restricted_tc` (fwd) | Restricted temporal coherence, backward chain F-case |
| 9 | 1099 | `dd_bfmcs_restricted_tc` (bwd) | Restricted temporal coherence, P-resolution direction |
| 10 | 1107 | `dd_bfmcs_restricted_buc` | Backward Until/Since coherence — requires step transfer property blocked under Lindenbaum chains |
| 11 | 1114 | `dd_bfmcs_restricted_fuc` | Forward Until/Since coherence — depends on restricted_tc + BX10/BX12 Until propagation |

## Dependency Structure

```
CanonicalModel (redesign)
├── g_content_subset_self (#5,#6) ─── genuinely false, need alternative
├── enriched_seed_consistent (#1,#3) ── need seriality-based consistency proof
└── f/p_carry preservation (#2,#4) ─── need chain redesign (enriched seeds)
         │
         ▼
fwd_chain_forward_F (#7) ─── needs F-preservation + termination argument
         │
         ▼
restricted_tc (#8,#9) ─── forward/backward temporal coherence
         │
    ┌────┴────┐
    ▼         ▼
restricted_buc (#10)  restricted_fuc (#11)
```

## Root Cause

Under irreflexive semantics (task 93), BX1 (`G(phi) -> phi`) was removed. This breaks `g_content(M) ⊆ M`, which was the foundation of:
- Seed consistency proofs (g_content ∪ f_carry ⊆ M, hence consistent)
- F-carry preservation (non-resolving step could include f_carry because it was ⊆ M)
- Chain ordering base cases (fwd_chain_g_content_trans at m=n=0)

The chain construction needs a fundamental redesign. Two genuinely unprovable theorems (fwd_succ_f_carry, bwd_pred_p_carry) and two genuinely false theorems (g_content_subset_self, h_content_subset_self) must be replaced, not just proved.

## Known Approaches (from 50+ research rounds)

1. **Defect-driven chain with well-founded induction**: Track active F-defects (`{phi | F(phi) in chain(n), phi not in chain(n)}`). If the chain resolves one defect per step via BX11 fold, the defect set decreases. Blocked by: `.choose` opacity — no proof that a *specific* formula is resolved.

2. **Enriched Lindenbaum seed**: Seed with `g_content(M) ∪ f_carry(M)` instead of bare `g_content(M)`. Requires proving the enriched seed is consistent without `g_content ⊆ M`. Potential via seriality: `T -> F(T)` gives non-emptiness, and `f_carry(M) ⊆ M` (since F(chi) ∈ M implies F(chi) is in M).

3. **Quasimodel BFMCS bridge**: Use the existing quasimodel infrastructure (finite Hintikka chains with defect discharge) to construct a witness, then bridge to the Int-indexed FMCS family. Gap: `HintikkaStepOracle` is never constructed; finite-to-Int bridge is missing.

4. **Deterministic chain construction**: Replace Lindenbaum-based non-deterministic chains with deterministic X/Y-content chains. Requires well-ordering of formulas and explicit enumeration. Substantial rewrite.

## Key Insight for Enriched Seed Path

`f_carry(M) ⊆ M` is trivially true (by definition, `f_carry(M) = {phi ∈ M | ∃ chi, phi = F(chi)}`). So `g_content(M) ∪ f_carry(M)` is consistent iff it doesn't derive `⊥`. The standard proof lifts a contradiction to `G(neg(psi))` for some `psi` in the seed. For `g_content` elements this works (they are `G(chi)`). For `f_carry` elements `F(chi)`, we need `G(neg(F(chi)))` ∈ M, which is equivalent to `H(neg(F(chi)))` via modal equivalence — this may or may not be available.

## Definition of Done

- All 11 sorry sites closed or replaced with sorry-free alternatives
- `bx_completeness` theorem compiles with `#print axioms` showing only `{propext, Classical.choice, Quot.sound}`
- `lake build` passes with no new sorry sites on the active completeness path
- If chain construction is redesigned, existing API surface preserved where possible
