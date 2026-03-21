# Research Report: Task #916

**Task**: Implement F/P witness obligation tracking to close DovetailingChain sorries
**Date**: 2026-02-20
**Focus**: Understand the 4 remaining sorries in DovetailingChain.lean, F/P witness obligation tracking requirements, forward_F/backward_P closure conditions, and how to implement Cantor-pairing enumeration for witness scheduling

## Summary

DovetailingChain.lean contains exactly 4 sorries in the `buildDovetailingChainFamily` construction. Two are cross-sign propagation gaps (forward_G when t < 0, backward_H when t >= 0) caused by the split forward/backward half-chain architecture. Two are F/P witness existence obligations (forward_F, backward_P) that require dovetailing enumeration of (time, formula) obligation pairs. Resolving all four requires replacing the split half-chain with a unified interleaved construction and augmenting the seed at each step with scheduled witness formulas.

## Findings

### 1. Precise Sorry Analysis

#### Sorry 1: Cross-sign forward_G (line 606)

**Location**: `buildDovetailingChainFamily.forward_G`, the `else` branch (when `t < 0`)

**Goal state**:
```
h_t : t < 0
h_lt : t < t'
h_G' : phi.all_future in dovetailChainSet base h_base_cons t
--> phi in dovetailChainSet base h_base_cons t'
```

**Root cause**: When `t < 0`, the dovetailChainSet maps to `dovetailBackwardChainMCS`, but `t'` could be non-negative (mapping to `dovetailForwardChainMCS`). The two half-chains are constructed independently via separate Lindenbaum extensions, sharing only M_0. There is no mechanism to propagate G phi from the backward chain across the sign boundary to the forward chain.

**Why it matters**: This sorry blocks the main theorem `temporal_coherent_family_exists_theorem` from being sorry-free.

#### Sorry 2: Cross-sign backward_H (line 617)

**Location**: `buildDovetailingChainFamily.backward_H`, the `else` branch (when `t >= 0`)

**Goal state**:
```
h_t : 0 <= t
h_lt : t' < t
h_H' : phi.all_past in dovetailChainSet base h_base_cons t
--> phi in dovetailChainSet base h_base_cons t'
```

**Root cause**: Symmetric to sorry 1. When `t >= 0`, the dovetailChainSet maps to `dovetailForwardChainMCS`, but `t'` could be negative. H phi cannot propagate backward across the sign boundary.

#### Sorry 3: forward_F (line 633)

**Location**: `buildDovetailingChainFamily_forward_F`

**Goal state**:
```
Gamma : List Formula
h_cons : ContextConsistent Gamma
--> forall t phi, phi.some_future in (buildDovetailingChainFamily Gamma h_cons).mcs t
    -> exists s, t < s and phi in (buildDovetailingChainFamily Gamma h_cons).mcs s
```

**Root cause**: The current construction uses Lindenbaum extension of `GContent(M_{n-1})` seeds, which ensures G-content propagation (forward_G) but does NOT place F-witness formulas. Lindenbaum may add `F(psi)` formulas to an MCS without ever placing the witness `psi` at any future time.

**Why it matters**: This is the core "witness scheduling" problem. F(psi) in M_t semantically requires there exists s > t with psi in M_s. The chain construction must explicitly arrange for this.

#### Sorry 4: backward_P (line 640)

**Location**: `buildDovetailingChainFamily_backward_P`

**Goal state**:
```
Gamma : List Formula
h_cons : ContextConsistent Gamma
--> forall t phi, phi.some_past in (buildDovetailingChainFamily Gamma h_cons).mcs t
    -> exists s < t, phi in (buildDovetailingChainFamily Gamma h_cons).mcs s
```

**Root cause**: Symmetric to sorry 3, for the past direction. P(psi) in M_t requires s < t with psi in M_s.

### 2. Architecture Analysis: The Split Half-Chain Problem

The current `buildDovetailingChainFamily` uses two independent recursive functions:

- `dovetailForwardChainMCS`: Builds M_0, M_1, M_2, ... where each M_{n+1} extends `GContent(M_n)` via Lindenbaum.
- `dovetailBackwardChainMCS`: Builds M_0, M_{-1}, M_{-2}, ... where each M_{n+1} extends `HContent(M_n)` via Lindenbaum.

Both share M_0 (the `sharedBaseMCS`), but their extensions beyond M_0 are completely independent.

**Critical limitation**: `dovetailForwardChainMCS 1` (which becomes M_1) is built from `GContent(M_0)`. But `dovetailBackwardChainMCS 1` (which becomes M_{-1}) is also built from `HContent(M_0)` independently. If `G phi in M_{-1}`, there is no mechanism to ensure `phi in M_0` because M_0 was built BEFORE M_{-1} -- its extension does not include GContent(M_{-1}).

The dovetailing index functions (`dovetailIndex`, `dovetailRank`) and the `dovetail_neighbor_constructed` theorem are already proven and establish the correct construction ORDER. The problem is that the actual chain construction does not USE this order. Instead, it builds two linear chains independently.

### 3. F/P Witness Obligation Tracking

#### The F-obligation problem

When `F(psi) in M_t`, we need some future M_s (s > t) to contain psi. The difficulty:

- **G formulas propagate automatically**: `G phi in M_t` implies `G(G phi) in M_t` (by the 4_G axiom), so `G phi` stays in GContent and propagates to all successors.
- **F formulas do NOT propagate**: `F(psi) in M_t` does NOT imply `G(F(psi)) in M_t`. Semantically, if psi holds at exactly one future time s, then at time s+1 the obligation may no longer apply.

Therefore, F-obligations must be tracked explicitly and resolved at specific construction steps.

#### Cantor-pairing approach

The description.md proposes using `Nat.unpair` to enumerate all (time, formula_index) pairs:

1. At construction step n, decode `n` to `(step_idx, formula_idx)` via `Nat.unpair n`
2. Look up the `formula_idx`-th formula psi such that `F(psi) in M_{step_idx}`
3. If `step_idx` corresponds to a time earlier than the current time being built, include psi in the seed

**Key consistency lemma**: `temporal_witness_seed_consistent` (proven in TemporalCoherentConstruction.lean) shows that `{psi} union GContent(M)` is consistent whenever `F(psi) in M`. Similarly, `past_temporal_witness_seed_consistent` (proven in DovetailingChain.lean) shows `{psi} union HContent(M)` is consistent whenever `P(psi) in M`.

#### Approach A: Direct resolution (recommended by description.md)

Resolve each F-obligation exactly one step after it arises:
- When F(psi) in M_s, resolve by placing psi in the seed for M_{s+1} (or the next time > s)
- Consistency guaranteed by `temporal_witness_seed_consistent`
- Subtlety: Lindenbaum can add new F-formulas not in the original seed. Must enumerate ALL (time, formula) pairs.

#### Mathlib infrastructure available

- `Nat.pair` / `Nat.unpair` from `Mathlib.Data.Nat.Pairing` - bijection between Nat and Nat x Nat
- `Nat.pair_unpair`, `Nat.unpair_pair` - roundtrip properties
- `Nat.surjective_unpair` - surjectivity
- `Encodable.ofCountable` - constructs Encodable from Countable
- Formula derives `Countable` - so formulas can be encoded as natural numbers

### 4. Key Design Decision: Unified Interleaved Chain

To close all 4 sorries, the construction must be fundamentally redesigned:

**Current**: Two independent half-chains sharing only M_0.
**Needed**: A single interleaved chain that builds MCSes in dovetailing order (M_0, M_1, M_{-1}, M_2, M_{-2}, ...) where each step's seed includes content from the already-built neighbor.

The interleaved chain construction would be:
```
interleavedChain : Nat -> { M : Set Formula // SetMaximalConsistent M }
interleavedChain 0 = sharedBaseMCS
interleavedChain (n+1) =
  let t = dovetailIndex (n+1)
  let seed = if (t-1 already built) then GContent(M_{t-1})
             else if (t+1 already built) then HContent(M_{t+1})
             else impossible (by dovetail_neighbor_constructed)
  -- Optionally augment seed with F/P witness formula
  Lindenbaum(seed ++ witness_formula)
```

The key challenge is that this is a single recursive function indexed by step number n, where each step needs to look up previously constructed MCSes by their TIME index (not step index). This requires a lookup table mapping time indices to their MCS values, which grows with each step.

### 5. Supporting Lemmas Inventory

| Lemma | File | Status | Relevance |
|-------|------|--------|-----------|
| `temporal_witness_seed_consistent` | TemporalCoherentConstruction.lean | PROVEN | F-witness seed consistency |
| `past_temporal_witness_seed_consistent` | DovetailingChain.lean | PROVEN | P-witness seed consistency |
| `dovetail_GContent_consistent` | DovetailingChain.lean | PROVEN | GContent seed consistency |
| `dovetail_HContent_consistent` | DovetailingChain.lean | PROVEN | HContent seed consistency |
| `dovetailRank_dovetailIndex` | DovetailingChain.lean | PROVEN | Left inverse |
| `dovetailIndex_dovetailRank` | DovetailingChain.lean | PROVEN | Right inverse (bijective) |
| `dovetail_neighbor_constructed` | DovetailingChain.lean | PROVEN | Neighbor availability |
| `dovetailForwardChain_forward_G` | DovetailingChain.lean | PROVEN | Same-sign G propagation (Nat-indexed) |
| `dovetailBackwardChain_backward_H` | DovetailingChain.lean | PROVEN | Same-sign H propagation (Nat-indexed) |
| `set_mcs_all_future_all_future` | MCSProperties.lean | PROVEN | G phi -> G(G phi) in MCS |
| `set_mcs_all_past_all_past` | MCSProperties.lean | PROVEN | H phi -> H(H phi) in MCS |
| `set_lindenbaum` | MaximalConsistent.lean (re-exported) | PROVEN | Extend consistent set to MCS |
| `Nat.pair` / `Nat.unpair` | Mathlib.Data.Nat.Pairing | PROVEN | Cantor pairing |
| `Nat.surjective_unpair` | Mathlib.Data.Nat.Pairing | PROVEN | All pairs eventually enumerated |
| `Encodable.ofCountable` | Mathlib.Logic.Encodable.Basic | PROVEN | Formula is encodable |

### 6. Non-Derivabilities (Critical for Understanding)

These explain WHY automatic propagation fails for F/P obligations:

- `F(psi) -> G(F(psi))`: **NOT DERIVABLE**. A formula might hold at exactly one future time. After that time, the F-obligation is discharged and need not persist.
- `F(psi) -> F(F(psi))`: **NOT DERIVABLE** in the forward direction. The converse `F(F(psi)) -> F(psi)` IS derivable (from 4_G contrapositive).
- `G phi -> G(G phi)`: **DERIVABLE** (4_G axiom). This is why GContent propagation works automatically.
- `phi -> G(P phi)`: **DERIVABLE** (axiom A). Could help relate forward and backward temporal properties.

## Recommendations

### Phase 1: Unified Interleaved Chain (closes sorries 1-2)

1. **Define a step-indexed construction** using a partial function `Fin (n+1) -> (Int x MCS)` that maps step indices to time/MCS pairs.
2. **Alternative**: Use `Nat -> Option (Set Formula)` as a lookup table, building it incrementally. At step n, the table has entries for all times built in steps 0..n-1.
3. **Prove forward_G and backward_H for the unified chain**. The proof structure for same-sign cases carries over. Cross-sign cases become provable because the neighbor is always already in the table.

**Key design pattern**: Rather than two separate recursive definitions, use a single function:
```lean
noncomputable def unifiedChain (base : Set Formula) (h_cons : SetConsistent base) :
    Nat -> (Int x { M : Set Formula // SetMaximalConsistent M })
```
where the time at step n is `dovetailIndex n`, and the MCS is built from GContent or HContent of the neighbor.

The lookup of previously built MCSes by time index can use `dovetailRank`: to find M_t, compute step `dovetailRank t` and look up that step's result.

### Phase 2: F/P Witness Scheduling (closes sorries 3-4)

1. **Define the obligation enumeration**: At each step n, use `Nat.unpair n` to get `(time_enc, formula_enc)`. Decode `time_enc` to a time index and `formula_enc` to a formula using `Encodable.decode`.
2. **Augment the seed**: If the decoded (time, formula) pair represents an F-obligation `F(psi) in M_time` where `time < t` (current time being built), add psi to the GContent seed.
3. **Prove consistency**: Use `temporal_witness_seed_consistent` for F-obligations and `past_temporal_witness_seed_consistent` for P-obligations.
4. **Prove coverage**: Every (time, formula) pair is eventually enumerated by surjectivity of Nat.unpair. This guarantees every F/P obligation eventually gets a witness.

**Approach A (direct resolution)** is recommended: resolve F(psi) obligations one step after they arise. This avoids the complexity of tracking multi-step obligation persistence.

### Important Implementation Considerations

1. **Noncomputable**: The entire construction will be noncomputable (uses Classical.choose via Lindenbaum). This is acceptable for existence proofs.

2. **Well-founded recursion**: The unified chain is indexed by Nat, so standard structural recursion works. No well-founded recursion needed.

3. **Lookup by time**: The function `dovetailRank` converts time index to step number. To look up M_t at step n, verify `dovetailRank t < n` (which means M_t was built in an earlier step), then look up step `dovetailRank t`.

4. **Encoding subtlety**: The F/P obligation tracking needs to enumerate formulas within a specific MCS. Since MCSes are sets of formulas (not finite lists), the enumeration goes over ALL formulas and checks membership. The surjectivity of the enumeration guarantees that for any F(psi) in M_t, the pair (t, psi) will eventually be enumerated.

5. **Seed union consistency**: When augmenting `GContent(M_{t-1})` with a witness psi, the consistency proof uses `temporal_witness_seed_consistent` which requires `F(psi) in M_{t-1}`. This works when psi is being witnessed from M_{t-1}'s own F-obligations. For obligations originating from times further back, the F-formula must somehow be present in M_{t-1}. This is where Approach A (resolve at the VERY next step) simplifies things: we only place witness psi in M_{t+1} when F(psi) originates at M_t, and we know F(psi) in M_t directly.

6. **Interaction between G-propagation and F-witnessing**: When building M_t's seed as `GContent(M_{t-1}) union {psi}`, we need to prove this is consistent. `temporal_witness_seed_consistent` gives exactly this, provided `F(psi) in M_{t-1}`. But what if the F-obligation comes from M_s where s < t-1? We need F(psi) to still be in M_{t-1}. F does NOT propagate via GContent (since F(psi) -> G(F(psi)) is not derivable). This is the central difficulty.

**Resolution**: The dovetailing enumeration at step n processes the obligation `(time_enc, formula_enc)` where `time_enc = (Nat.unpair n).1`. The witness psi is placed at time `dovetailIndex (n+1)` (or a designated future time). The key is that at the step where we BUILD M_t, we check: does any previous time s < t have F(psi) in M_s where psi should be placed at t? We use Nat.unpair to select WHICH obligation to resolve at this step.

Actually, the cleaner approach is:
- At step n, we build M_t where t = dovetailIndex n
- The seed is GContent(M_{t-1}) or HContent(M_{t+1}) [whichever neighbor exists]
- Additionally, decode `n` via Nat.unpair to get an obligation index `(s_enc, psi_enc)`
- If `s_enc` decodes to a time s with `s < t` and `F(psi) in M_s`, then we also add psi to the seed
- Consistency: `GContent(M_{t-1}) union {psi}` is consistent if `F(psi) in M_{t-1}`, which we need to ensure

The challenge remains: we need F(psi) in the IMMEDIATE predecessor M_{t-1}, not just in some earlier M_s. One way to handle this: instead of resolving arbitrary (s, psi) pairs, resolve only obligations at the immediate predecessor. That is, at step n building M_t, enumerate F-formulas in M_{t-1} using the formula index from Nat.unpair.

## References

- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - The 4 sorries (lines 606, 617, 633, 640)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - `temporal_witness_seed_consistent`, temporal coherent family structure
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - BFMCS structure definition
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Construction primitives
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - GContent/HContent definitions
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS property lemmas
- `Theories/Bimodal/Syntax/Formula.lean` - Formula type (derives Countable)
- `specs/916_implement_fp_witness_obligation_tracking/description.md` - Full proof strategy
- `Mathlib.Data.Nat.Pairing` - Cantor pairing (`Nat.pair`, `Nat.unpair`)
- `Mathlib.Logic.Encodable.Basic` - Encodable infrastructure

## Next Steps

1. **Design the unified chain data structure** - Decide between function-based lookup (using dovetailRank) vs accumulator-based construction
2. **Create implementation plan** with concrete Phase 1 and Phase 2 milestones
3. **Prototype the unified chain** to verify the construction compiles before tackling F/P witnesses
4. **Address the F-obligation persistence question** - Determine whether Approach A (resolve at immediate next step) is sufficient or whether more complex persistence tracking is needed
5. **Consider whether sorries 1-2 (cross-sign) and 3-4 (F/P) should be addressed simultaneously** in a single unified construction, or whether the cross-sign fix can be done first as a simpler intermediate step
