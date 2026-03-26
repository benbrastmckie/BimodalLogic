# Teammate B Findings: Saturation Methods for Family-Level Temporal Coherence

**Task**: 58 - Wire Completeness to Frame Conditions
**Role**: Teammate B - Saturation Methods Research
**Date**: 2026-03-26
**Session**: sess_research_teammate_b

---

## Key Findings

- **Dovetailed enumeration is mathematically feasible** for the forward (positive-time) chain, but runs into a hard mathematical barrier for backward-chain F-witnesses: sub-case (b) is genuinely unsolvable within a single family.
- **The current omega chain construction does NOT dovetail**: it resolves only `F_top` (i.e., `F(¬⊥)`) at every step, not arbitrary F-obligations. This is the core gap.
- **A true dovetailing construction is definable in Lean** using `Nat`-indexed chains with a pairing function, but Lean's termination checker requires a well-founded recursion on `Nat` — this is achievable.
- **Sub-case (b) is a genuine mathematical obstruction**: when `F(phi) ∈ backward_chain(n)` and `G(¬phi) ∈ M0` and `H(¬phi) ∉ M0`, no same-family witness exists at any time `s > t`. The reason is that `G(¬phi) ∈ M0` forces `¬phi` into every MCS of the forward chain at all times `s ≥ 0`, making it impossible for `phi` to appear there.
- **Bundle-level coherence (`BFMCS_Bundle`) is already proven sorry-free** and constitutes the correct solution. The saturation approach for same-family coherence is blocked at the sub-case (b) barrier.

---

## Detailed Analysis

### 1. What the Current Construction Does

The `omega_chain_forward` construction (UltrafilterChain.lean lines 2027-2052) builds a `Nat`-indexed chain starting from `M0`:

```
omega_chain_forward(0) = M0
omega_chain_forward(n+1) = temporal witness of omega_chain_forward(n) for F_top
```

At each step, `omega_step_forward` calls `temporal_theory_witness_exists` to get a new MCS `W` satisfying:
- `phi ∈ W` (where `phi = ¬⊥`, so any MCS works)
- `∀ a, G(a) ∈ M_n → G(a) ∈ W` (G-preservation)
- `box_class_agree M_n W` (modal class agreement)

The key problem: at step `n+1`, the witness resolves `F(¬⊥)` only — **it does NOT resolve any specific F-obligation**. The `F(¬⊥)` is just the trivially true "there is a future" assertion, not a substantive F-obligation. This means the chain has no mechanism to ensure that `F(phi)` ever gets a witness in the same family.

### 2. What True Dovetailing Would Look Like

Henkin's dovetailed enumeration strategy for first-order logic completeness works as follows:
1. Enumerate all existential obligations: `∃x.phi_0(x)`, `∃x.phi_1(x)`, ...
2. At step `2k`, add a witness constant `c_k` for obligation `k` and extend to a new maximal set
3. Fairness: every obligation is addressed at some finite step

For TM logic, the temporal analog would be:

**Dovetailed Forward Chain**:
```
Step 0: M0
Step n+1:
  - Let (i, j) = unpair(n)  (some pairing function Nat -> Nat × Nat)
  - Let f_i = i-th formula in the enumeration of all F-formulas
  - If F(f_i) ∈ current_chain(n):
      current_chain(n+1) = witness resolving F(f_i) from current_chain(n)
    Else:
      current_chain(n+1) = any successor (e.g., witness for F_top)
```

This ensures that for each `F(phi)`:
- At some step `n` where `(i, _) = unpair(n)` and `F(phi_i) = F(phi)` and `F(phi) ∈ chain(n)`, the chain extends to include `phi`.
- Therefore `phi` appears in `chain(n+1)` for that `n`.

**Key property provable**: If `F(phi) ∈ chain(m)`, then since `G(¬phi) ∉ chain(m)` (by MCS consistency), and G-theory propagates forward (so `G(¬phi) ∉ chain(k)` for all `k ≥ m`), we cannot have `phi` blocked from appearing. Eventually the dovetailing reaches step `k ≥ m` where `phi`'s obligation is selected — and since `F(phi)` may or may not still be in `chain(k)`, we need to track persistence.

**Persistence issue**: `F(phi) ∈ chain(m)` does NOT imply `F(phi) ∈ chain(m+1)`. The temporal witness for another obligation at step `m` might not preserve `F(phi)`. Specifically:
- `temporal_theory_witness_exists` preserves G-theory but NOT F-theory
- So `F(phi)` at step `m` might be lost by step `m+1`

This is why "select the obligation and resolve it in the next step" doesn't work naively. We need to either:
(a) Resolve the obligation the moment it appears (reactive), or
(b) Track that an obligation was EVER present (cumulative witness tracking)

### 3. The Sub-case (b) Barrier — Why Saturation Fails

Even if we design a perfect dovetailing construction that resolves every F-obligation from `M0` in the forward chain, the backward chain (`omega_chain_backward`) has F-obligations that cannot be resolved in the same family.

**The sub-case (b) scenario** (from report 11_team-research.md):

Suppose:
- `F(phi) ∈ backward_chain(n)` for some `n > 0` (so `F(phi)` is at time `-n`)
- `G(¬phi) ∈ M0` (at time `0`)
- `H(¬phi) ∉ M0` (so it's "non-eternal" — phi does hold at some time in the distant past)

The G-propagation invariant (`omega_chain_forward_G_theory`) ensures:
- `G(¬phi) ∈ forward_chain(k)` for all `k ≥ 0`
- By G axiom (temp_T): `¬phi ∈ forward_chain(k)` for all `k ≥ 0`

So `phi ∉ forward_chain(k)` for all `k ≥ 0`. The forward chain cannot witness `phi` at any positive time.

For the backward chain at time `-n`, the F-witness for `F(phi)` must be at some `s > -n`, which could be negative (between `-n` and `0`) or at time `0` (which is `M0`).

But `M0 = backward_chain(0)` and by MCS maximality: `G(¬phi) ∈ M0` implies `¬phi ∈ M0` (by temp_T), so `phi ∉ M0`.

For times between `-n` and `0`, the backward chain construction only goes backwards: `backward_chain(0) = M0`, `backward_chain(1) = M_{-1}`, etc. There's no mechanism to create an MCS at time `-k` for `0 < k < n` that contains `phi` unless we dovetail differently.

**Could we modify the backward chain to also resolve F-obligations?**

A modified backward chain step would alternate:
- Odd steps: resolve P-obligation (standard backward step, preserves H-theory)
- Even steps: resolve F-obligation at current boundary

But this causes the G/H oscillation problem:
- H-theory is preserved through P-witnesses
- G-theory is NOT preserved through P-witnesses (backward witnesses don't preserve G)
- So if we insert an F-step (preserving G), the H-theory accumulated so far may be lost at the next step

The oscillation means neither G-theory nor H-theory fully accumulates, and the invariants for coherence break down.

**Conclusion**: There is no single-chain construction that simultaneously resolves all F/P obligations in the same family while preserving both G-theory (for forward coherence) and H-theory (for backward coherence). This is a genuine mathematical barrier, not an engineering limitation.

### 4. Interaction with Lean's Termination Checker

A dovetailed forward chain indexed by `Nat` is **fully compatible** with Lean 4's termination checker:

```lean
noncomputable def dovetailed_chain_forward
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (enum : Nat -> Formula) :  -- enumeration of all formulas
    Nat -> Set Formula
  | 0 => M0
  | n + 1 =>
    let phi_n := enum n
    let M_n := dovetailed_chain_forward M0 h_mcs0 enum n
    let h_mcs_n := ...  -- need invariant proof by IH
    if h_F : Formula.some_future phi_n ∈ M_n then
      (temporal_theory_witness_exists M_n h_mcs_n phi_n h_F).choose
    else
      -- Fall back: take any successor
      (temporal_theory_witness_exists M_n h_mcs_n (Formula.neg Formula.bot)
        (SetMaximalConsistent.contains_F_top h_mcs_n)).choose
```

This is a structurally recursive definition on `Nat`, so Lean's termination checker accepts it immediately. The invariants (MCS property, G-propagation, box-class agreement) carry through by induction.

However, the key proof obligation is:

```
If F(phi) ∈ dovetailed_chain(m) AND phi_n = phi AND n >= m, then
phi ∈ dovetailed_chain(n+1)
```

This requires showing that `F(phi) ∈ dovetailed_chain(m)` persists until step `n`. Since `F(phi)` may not be preserved by intermediate steps (the intermediate witnesses resolve OTHER obligations), we'd need to prove that if `F(phi)` appears at step `m` and `G(¬phi) ∉ chain(m)`, then `F(phi)` OR `phi` appears at every later step.

By G-monotonicity: if `G(¬phi) ∉ M0`, then `G(¬phi) ∉ chain(k)` for all `k` (since G-theory only monotonically grows). So `F(phi) = ¬G(¬phi)` remains consistent with the chain at every step. However, consistency doesn't mean `F(phi)` is actively in the chain — the chain may move to a future where `phi` already holds and thus `F(phi)` is "satisfied" but not literally `∈ chain(k)`.

This is the technical gap: the dovetailing argument needs a persistence lemma that's currently missing and appears hard to prove without additional structural assumptions on the chain.

### 5. Alternative: Multiple Forward Chains Per F-Obligation

Rather than a single dovetailed chain, an alternative is to maintain a **family** of chains:

```
For each formula phi, if F(phi) ∈ M0:
  Chain_phi : forward chain from M0 specifically resolving F(phi) at step 1
```

This gives a FAMILY of chains (indexed by formulas phi with F(phi) ∈ M0), each with `phi ∈ Chain_phi(1)`. Family-level F-coherence for M0's family would require finding `phi ∈ Chain_phi(t)` for some `t > 0`, which is trivially satisfied at `t = 1`.

But this doesn't give a single family — it gives many families. The family for M0 would still not have F-witnesses in itself. The witnesses would be in the `Chain_phi` families, which is exactly bundle-level coherence.

This is the insight behind `boxClassFamilies_bundle_forward_F`: the proof at line 2651 does exactly this — it builds `witness_fam` from a new MCS W (with `phi ∈ W`) and shows `witness_fam ∈ boxClassFamilies`, giving the bundle-level witness.

### 6. Why Bundle-Level Coherence is the Correct Solution

The semantic definition of `truth_at` for temporal operators (Truth.lean lines 118-126):
- `truth_at M Omega tau t (F phi)` = `∃ s > t, truth_at M Omega tau s phi`

The history `tau` is fixed — it's the SAME history throughout. The bundle (`Omega`) is a set of histories, and `truth_at` for Box ranges over all histories in Omega, but for F/G/P/H it ranges over TIME POINTS on the same history.

However, in the canonical model construction:
- `Omega = { parametric_to_history fam | fam ∈ B.families }`
- `parametric_to_history fam` maps time `t` to the "world" `fam.mcs(t)`
- Two families `fam` and `fam'` give DIFFERENT histories

So when bundle-level coherence says "the F-witness is in a different family `fam'`," this means the witness is at time `s > t` in history `tau' = parametric_to_history fam'`. This is NOT what `truth_at` for F evaluates — it evaluates along the ORIGINAL history `tau = parametric_to_history fam`.

**This is the semantic mismatch documented in report 19_bundle-truth-lemma-analysis.md.** Bundle-level coherence is insufficient for the standard parametric truth lemma.

---

## Proposed Saturation Algorithm (for Reference)

The following algorithm would theoretically work IF we could solve sub-case (b), but it is blocked:

```
Algorithm: Omega-Dovetailed Z-Chain

Input: MCS M0
Output: Int-indexed chain of MCSes satisfying family-level F/P coherence

Enumeration: Let enum : Nat -> Formula be a surjection (using formula encodability)

Forward phase (positive times):
  chain(0) = M0
  chain(n+1):
    Let phi = enum(n)
    If F(phi) ∈ chain(n):
      chain(n+1) = temporal_theory_witness_for(chain(n), phi)
      -- this MCS contains phi and preserves G-theory
    Else:
      chain(n+1) = temporal_theory_witness_for(chain(n), ¬⊥)
      -- fallback: just a successor

Backward phase (negative times):
  chain(-n-1):
    Let phi = enum(n)
    If P(phi) ∈ chain(-n):
      chain(-n-1) = past_theory_witness_for(chain(-n), phi)
      -- this MCS contains phi and preserves H-theory
    Else:
      chain(-n-1) = past_theory_witness_for(chain(-n), ¬⊥)
      -- fallback: just a predecessor

Key property to prove (BLOCKED):
  If F(phi) ∈ chain(t):
    (Case A) t ≥ 0: chain(n+1) contains phi where n is the step that selected phi
             REQUIRES persistence of F(phi) until that step
    (Case B) t < 0: F(phi) needs a witness at some s > t
             If s ≥ 0: needs phi ∈ forward chain (blocked by G(¬phi) ∈ M0)
             If -|t| < s < 0: needs phi in backward chain between t and 0
                              (backward chain only goes "more negative")
             REQUIRES constructing a specific intermediate backward chain element
             -- NOT POSSIBLE with a single backward chain pass
```

**Why this algorithm fails for sub-case (b)**:
- In the backward phase, when F(phi) ∈ chain(-n) with G(¬phi) ∈ M0:
  - The forward chain has ¬phi at all t ≥ 0 (by G-propagation)
  - M0 = chain(0) has ¬phi (by G axiom from G(¬phi) ∈ M0)
  - The backward chain at step 0 is M0, which has ¬phi
  - To resolve F(phi) at time -n, we need phi at some s with -n < s
  - But all s ≥ 0 have ¬phi, and the backward chain only constructs points going more negative
  - A single-pass backward chain cannot create an intermediate point at time -(n-k) with phi

---

## Implementation Complexity Assessment

| Approach | Complexity | Feasibility | Notes |
|----------|------------|-------------|-------|
| Dovetailed forward chain (t ≥ 0 only) | MEDIUM | HIGH | Provable but doesn't fix backward case |
| Dovetailed combined Z-chain | HIGH | LOW | Sub-case (b) barrier |
| Multiple families per obligation | LOW | HIGH | Already proven as bundle-level coherence |
| Modified truth lemma for bundle | MEDIUM | MEDIUM | Requires new semantics framework |
| New backward lemma without forward_F | LOW | KNOWN-IMPOSSIBLE | Exhaustively analyzed in report 18 |

---

## Confidence Level: HIGH

The analysis is based on:
1. Direct examination of the existing code at UltrafilterChain.lean lines 2027-2495
2. Understanding of `temporal_theory_witness_exists` and its G-preservation guarantee
3. Analysis of why G-propagation blocks phi from appearing in the forward chain
4. Confirmation from 3 prior research waves (reports 11, 15, 18) reaching the same conclusion
5. Standard completeness proof theory (Henkin methods, canonical model construction)

---

## Why the Current Approach Fails (Specific)

1. **Immediate cause**: `omega_chain_forward` at step `n+1` always resolves `F(¬⊥)` (line 2036: `h_F_top : F_top ∈ M_n := SetMaximalConsistent.contains_F_top`). This is always satisfiable and says nothing about specific F-obligations. The chain structure provides no guarantee that `F(phi)` for a specific `phi` ever gets resolved.

2. **Sub-case (b) mathematical barrier**: When `F(phi) ∈ backward_chain(n)` and `G(¬phi) ∈ M0`:
   - `omega_chain_forward_G_theory` gives `G(¬phi) ∈ forward_chain(k)` for all `k`
   - temp_T axiom gives `¬phi ∈ forward_chain(k)` for all `k`
   - Therefore `phi ∉ forward_chain(k)` for any `k ≥ 0`
   - The backward chain only constructs points at times `≤ 0`
   - There is no witness at any time `s` with `-n < s ≤ 0` and `phi ∈ chain(s)` (since chain(0) = M0 has ¬phi and backward steps only go more negative)
   - Result: `Z_chain_forward_F` CANNOT be proven for this case

3. **Technical proof gap**: Even if we modified the construction to dovetail, the proof that "F(phi) at step m remains resolvable by step n" requires a persistence lemma for F-formulas across temporal witness steps. `temporal_theory_witness_exists` guarantees G-preservation but NOT F-preservation. This gap is irreparable because F-persistence would be equivalent to temporal coherence itself (circular).

4. **Bundle-level is the ceiling**: The `boxClassFamilies_bundle_forward_F` theorem (line 2643) achieves exactly what CAN be achieved: given `F(phi) ∈ fam.mcs(t)`, it produces a NEW family `fam'` (built from a fresh MCS W with `phi ∈ W`) with `phi ∈ fam'.mcs(t+1)`. This is the maximal achievable result — further insisting that `fam' = fam` is mathematically impossible in general.

---

## Recommendations

1. **Do not pursue same-family saturation further.** The sub-case (b) barrier is fundamental and has been confirmed by multiple independent research waves.

2. **The solution lies in modifying the truth lemma**, not the chain construction. Either:
   a. Define a bundle-truth-lemma that treats bundle-level coherence as sufficient (requires semantic restructuring)
   b. Use the forward direction of the truth lemma only (if completeness can be achieved with one-way direction — report 18 suggests this is blocked by the `imp` backward case)
   c. Find a completely new canonical model construction not based on successor chains

3. **Reference literature on bundle completeness**: Goranko & Reynolds (1998) "bundled tree semantics" uses exactly the cross-family witness approach. The semantic framework may need to be aligned with that literature.

4. **The practical path**: The `BFMCS_Bundle` structure is already built and proven correct at the bundle level. The remaining work is to determine whether a modified `truth_at` definition (one that allows F-witnesses from other histories in Omega) is logically valid for TM, or alternatively whether a new completeness strategy can exploit bundle coherence directly.
