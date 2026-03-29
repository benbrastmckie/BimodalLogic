# Task 67 Teammate A Findings: Z-chain Family-Level Temporal Coherence

**Session**: sess_1774755166_b8a317
**Focus**: Z-chain omega construction and F/P witness availability within same chain

---

## Key Findings

### 1. The Z-chain IS an omega chain, but does NOT track F-obligation witnesses

The `Z_chain` (UltrafilterChain.lean:2208) is built from two halves:
- Forward (t >= 0): `omega_chain_forward` — each step resolves only **F_top** (not arbitrary F(phi))
- Backward (t < 0): `omega_chain_backward` — each step resolves only **P_top** (not arbitrary P(phi))

**Critically**: `omega_chain_forward_with_inv` (line ~2030) calls `omega_step_forward M_n inv_n.is_mcs (Formula.neg Formula.bot) h_F_top` — it only resolves the obligation `F(⊤)`, not any F(psi) that may be in the current MCS. This means `Z_chain_forward_F` (line 2424) is sorry because the chain construction does not guarantee that F(phi) at time t gets resolved to phi at any particular future time in the same chain.

Code reference: `UltrafilterChain.lean:2038` — witness is always for `neg(bot)` (i.e., F_top), not for the arbitrary `phi`.

### 2. The sorry in Z_chain_forward_F is fundamental, not incidental

The sorry at line 2485 is accompanied by a detailed comment (lines 2458-2483) acknowledging that the forward chain always resolves F_top, not arbitrary F-obligations. The same-chain witness requirement cannot be satisfied with the current omega chain construction because:

- The witness MCS `W` produced by `temporal_theory_witness_exists` (line 2441) is **in the box class of M0**, but there is no guarantee `W` appears as any particular position in the Z_chain
- The Z_chain construction does not enumerate F-obligations and resolve them one by one

### 3. The `restricted_succ_chain_fam` IS sorry-free for same-chain F/P witnesses

In contrast to the Z_chain approach, the **restricted chain infrastructure** in `SuccChainFMCS.lean` fully solves the problem within `deferralClosure(phi)`:

| Theorem | Location | Status | What it proves |
|---------|----------|--------|----------------|
| `restricted_forward_chain_forward_F` | SuccChainFMCS.lean:2887 | **SORRY-FREE** | F(psi) at n => psi at m > n (same forward chain) |
| `restricted_backward_chain_backward_P` | SuccChainFMCS.lean:4238 | **SORRY-FREE** | P(psi) at n => psi at m > n (same backward chain, i.e., further back) |
| `restricted_backward_to_combined_F_witness` | SuccChainFMCS.lean:4399 | **SORRY-FREE** | F(psi) in backward chain => psi at some m > n in combined Int-indexed chain |
| `restricted_forward_to_combined_P_witness` | SuccChainFMCS.lean:4594 | **SORRY-FREE** | P(psi) in forward chain => psi at some m < n in combined Int-indexed chain |
| `build_restricted_tc_family` | SuccChainFMCS.lean:4642 | **SORRY-FREE** | Packages seed + coherence into `RestrictedTemporallyCoherentFamily` |

The `RestrictedTemporallyCoherentFamily` structure (line 4623) explicitly provides:
```lean
forward_F : ∀ n : Int, ∀ psi, F(psi) ∈ chain(n) → ∃ m > n, psi ∈ chain(m)
backward_P : ∀ n : Int, ∀ psi, P(psi) ∈ chain(n) → ∃ m < n, psi ∈ chain(m)
```
These are same-chain witnesses over the full Int-indexed `restricted_succ_chain_fam`.

### 4. The termination sorries are isolated and do not affect the main path

There are minor `sorry` instances in the `fuel = 0` base case of:
- `restricted_bounded_witness_fueled` (line 2735): unreachable with sufficient fuel
- `restricted_backward_bounded_witness_fueled` (line 4162): unreachable with sufficient fuel
- `restricted_combined_bounded_witness_fueled` (line 4320): unreachable with sufficient fuel
- `restricted_combined_bounded_witness_P_fueled` (line 4516): unreachable with sufficient fuel

These are in the `| 0 =>` match arm that the callers guarantee is never reached (they call with fuel `B*B+1 >= 1`). They do NOT affect `restricted_forward_chain_forward_F` or `restricted_backward_chain_backward_P`, which go through entirely sorry-free paths.

### 5. The `construct_bfmcs_bundle` is sorry-free and provides bundle-level coherence

`construct_bfmcs_bundle` (line 2853) is sorry-free and provides `bundle_forward_F` / `bundle_backward_P` — witnesses in potentially **different** families. The gap to same-family witnesses remains, but is bridgeable via the restricted chain approach.

### 6. There are TWO existing sorry-chains in the old approach that should NOT be used

The older approach via `construct_bfmcs` (line ~1822) has `sorry` due to relying on `f_nesting_is_bounded` which is **mathematically false**. This path is blocked and should be abandoned.

---

## Recommended Approach

**Use the `restricted_succ_chain_fam` infrastructure directly**, bypassing the Z_chain approach entirely.

The plan in `plans/02_restricted-coherence-plan.md` is correct. The key insight confirmed by this research: **same-family temporal coherence is available for free via `build_restricted_tc_family`**, as long as the seed MCS is a `DeferralRestrictedSerialMCS`.

The concrete path forward:

1. **Phase 1** (already partially scaffolded): Build a `DeferralRestrictedSerialMCS` from the Lindenbaum extension of `{neg(phi)}`. The seed for `build_restricted_tc_family` should come from `DeferralRestrictedSerialMCS` construction, not from the Z_chain.

2. **The critical connection needed**: Show that when `neg(phi)` is consistent, we can build a `DeferralRestrictedSerialMCS phi` that contains `neg(phi)`. This requires:
   - `deferralClosure phi` contains `neg(phi)` (by definition)
   - A consistent set `{neg(phi)}` extends to a DeferralRestrictedMCS within `deferralClosure(phi)` via a restricted Lindenbaum lemma

3. **Then**: `build_restricted_tc_family` immediately gives same-family F/P witnesses for all formulas in `deferralClosure(phi)`.

4. **The restricted truth lemma** (planned in Phase 2) can then be proved with `forward_F` and `backward_P` from the `RestrictedTemporallyCoherentFamily` structure.

### Why the Z_chain sorry cannot be easily filled

The Z_chain approach would require redesigning `omega_chain_forward` to resolve F-obligations in a fair-scheduling manner (like a Henkin construction for LTL). This is a fundamentally different construction — not incremental. The restricted chain approach sidesteps this entirely by working within the bounded `deferralClosure`.

---

## Evidence from Codebase

- `SuccChainFMCS.lean:2887` — `restricted_forward_chain_forward_F` is sorry-free (uses `restricted_forward_chain_iter_F_witness` which is sorry-free)
- `SuccChainFMCS.lean:4642` — `build_restricted_tc_family` is sorry-free (assembles the Int-indexed family with both coherence properties)
- `UltrafilterChain.lean:2424-2485` — `Z_chain_forward_F` sorry with detailed comment explaining the fundamental gap
- `UltrafilterChain.lean:2038` — omega forward chain only resolves F_top, not arbitrary F(phi)
- `UltrafilterChain.lean:2853` — `construct_bfmcs_bundle` is sorry-free (bundle-level coherence only)

---

## Confidence Level

**HIGH** — The analysis is based on direct code inspection of the relevant theorems and their sorry status. The restricted chain infrastructure is complete and sorry-free for the F/P coherence properties needed. The gap in the Z_chain approach is confirmed by the code comments and the construction details.

The primary open question (not fully verified here) is whether a `DeferralRestrictedSerialMCS phi` containing `neg(phi)` can be constructed from a consistent set — this requires checking if a restricted Lindenbaum lemma exists or needs to be proved.
