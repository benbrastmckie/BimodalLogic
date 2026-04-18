# Teammate A Findings: Live Proof Path Trace (Task 93)

**Date**: 2026-04-18
**Investigator**: Teammate A
**Question**: Is `dd_bfmcs` or `qm_bfmcs` (or both, or neither) on the live proof path from `bx_completeness`?

---

## Key Findings

1. **`dd_bfmcs` is definitively on the live proof path.** `dd_countermodel` calls `dd_bfmcs` directly at lines 977, 987-991 of `RootScopedChain.lean`.

2. **`qm_bfmcs` is NOT on the live proof path.** It appears nowhere in `Completeness.lean` and nowhere in `dd_countermodel`. It exists only as dead infrastructure in the lower section of `RootScopedChain.lean` (lines 1746-1961).

3. **The three live sorry sites are `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, and `dd_bfmcs_restricted_fuc`** — all in `RootScopedChain.lean` at lines 949-963 — and all called directly from `dd_countermodel`.

4. **`dd_chain` uses the scheduling chain (`fwd_chain_of_sigma`/`bwd_chain_of_sigma`), NOT the oracle chain.** The oracle chain (`qm_fwd_chain`) is a separate construction defined later in the file.

5. **`qm_bfmcs` has its own sorry sites** (lines 1878, 1883, 1921, 1929, 1957, 1961) that are NOT on the live path. The Boneyard note about "sorry targets" refers to the `dd_bfmcs_restricted_*` theorems, not to wiring in `qm_bfmcs`.

---

## Live Proof Path (Complete Chain)

```
bx_completeness (Completeness.lean:123)
  ↓ calls
dd_countermodel (RootScopedChain.lean:967)
  ↓ constructs
  dd_bfmcs M h_mcs sigma_list (RootScopedChain.lean:977, 987-991)
    ↓ uses
    shifted_dd_fmcs N h_N sigma_list s (RootScopedChain.lean:904-946)
      ↓ uses
      dd_chain M₀ h₀ sigma_list (RootScopedChain.lean:485-488)
        ↓ uses
        fwd_chain_of_sigma  (RootScopedChain.lean:463-471) [forward, t ≥ 0]
        bwd_chain_of_sigma  (RootScopedChain.lean:473-482) [backward, t < 0]
          ↓ these use
          fwd_succ / bwd_pred (canonical MCS step functions)
  ↓ calls three sorry-holding theorems
  dd_bfmcs_restricted_tc    (RootScopedChain.lean:949-953)  ← SORRY
  dd_bfmcs_restricted_buc   (RootScopedChain.lean:955-958)  ← SORRY
  dd_bfmcs_restricted_fuc   (RootScopedChain.lean:960-963)  ← SORRY
  ↓ all fed into
  fully_restricted_parametric_representation_from_neg_membership
    (called at RootScopedChain.lean:986)
```

**Evidence**: `Completeness.lean:141` explicitly calls `dd_countermodel`. `RootScopedChain.lean:967-993` shows `dd_countermodel` using `dd_bfmcs` exclusively.

---

## `dd_bfmcs` vs `qm_bfmcs` Analysis

### `dd_bfmcs` (lines 904-946)

- **Definition**: `BFMCS Int` where families are `shifted_dd_fmcs N h_N sigma_list s` for each modal-equivalent MCS `N` and shift `s`.
- **Underlying chain**: `dd_chain`, which is assembled from `fwd_chain_of_sigma` (forward, iterates `fwd_succ`) and `bwd_chain_of_sigma` (backward, iterates `bwd_pred`). This is the *scheduling chain*, NOT the oracle chain.
- **Status**: Fully defined (no sorry). Three sorry-holding coherence theorems are needed to use it.
- **Called by**: `dd_countermodel` directly.

### `qm_bfmcs` (lines 1746-1789)

- **Definition**: `BFMCS Int` where families are `shifted_qm_fmcs N h_N Sigma s`, using the oracle chain `qm_fwd_chain`.
- **Underlying chain**: `qm_fwd_chain` (lines 1501-1516), which iterates `qm_oracle_step` — the oracle-based construction from `Quasimodel/OracleStep.lean`.
- **Status**: Fully defined, but its three coherence theorems (`qm_bfmcs_restricted_tc`, `qm_bfmcs_restricted_buc`, `qm_bfmcs_restricted_fuc`) each have sorry sites (lines 1863-1961).
- **Called by**: NOTHING. It is dead infrastructure. No theorem outside of the `qm_bfmcs_*` block ever references `qm_bfmcs`.

### What the Boneyard Note Says

The `Boneyard/RoundRobinChain.lean` header (lines 16-19) says:
> "The live sorry targets in RootScopedChain.lean are `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, and `dd_bfmcs_restricted_fuc`, which will be proved via the quasimodel bridge."

This is NOT saying that `qm_bfmcs` will be wired in as a replacement for `dd_bfmcs`. It is saying that *the proofs of the `dd_bfmcs_restricted_*` theorems* will be constructed using the quasimodel infrastructure (i.e., `hintikka_chain_exists` from `Quasimodel/Construction.lean`). The two things are structurally separate: `dd_bfmcs` remains the live BFMCS, but the proofs of its coherence properties may borrow from the quasimodel machinery.

### Could `qm_bfmcs` Be Wired In?

Theoretically yes — one could replace the `dd_bfmcs` call in `dd_countermodel` with `qm_bfmcs`. However:
1. `qm_bfmcs_restricted_tc` has 2 sorry sites (lines 1878, 1883) with documented fundamental gap: defect_count decrease under oracle steps is unresolved.
2. `qm_bfmcs_restricted_buc` has 2 sorry sites (lines 1921, 1929) that are documented as SEMANTICALLY INVALID steps — the step transfer `φ U ψ ∈ mcs(r+1) ∧ φ ∈ mcs(r) → φ U ψ ∈ mcs(r)` is not provable in BX.
3. `qm_bfmcs_restricted_fuc` has 2 sorry sites (lines 1957, 1961) that depend on `restricted_tc` being sorry'd.

The `qm_bfmcs` approach has deeper mathematical obstructions than the `dd_bfmcs` approach. The `dd_bfmcs` sorry sites represent proof obligations (temporal coherence, until/since coherence) that are mathematically true but not yet formalized. The `qm_bfmcs_restricted_buc` sorry is documented as a SEMANTICALLY INVALID step.

---

## OracleStep.lean Sorry Sites (Lines 272, 341, 348, 367, 386, 393, 397, 452)

The `OracleStep.lean` sorry sites are in the universal `hintikka_step_oracle` theorem (for arbitrary `HintikkaPoint` inputs). Crucially, the file header (line 40-42) states:
> "In `hintikka_chain_exists`, the oracle is always called on sigma_signatures (the initial point h0 is sigma_signature(w0) and the oracle always returns sigma_signatures), so the sorry never fires on the actual completeness proof path."

This means the `hintikka_step_oracle` sorry sites are vacuously unreachable from any real proof path using `hintikka_chain_exists`. However, this is inside the Quasimodel module which is NOT currently on the live path (since `qm_bfmcs` is dead code and `hintikka_chain_exists` is not called from `dd_countermodel`).

---

## Confidence Level and Evidence

**Confidence: DEFINITIVE (>99%)**

Evidence is direct code traces, not inference:

| Claim | Evidence |
|-------|----------|
| `dd_bfmcs` is on live path | `Completeness.lean:141` calls `dd_countermodel`; `RootScopedChain.lean:977` uses `dd_bfmcs` |
| `qm_bfmcs` is dead code | Grep of entire `BXCanonical/` directory: `qm_bfmcs` appears ONLY in `RootScopedChain.lean:1740-1961`, never referenced by `dd_countermodel` or `Completeness.lean` |
| `dd_chain` uses scheduling chain | `RootScopedChain.lean:485-488`: `dd_chain` calls `fwd_chain_of_sigma` / `bwd_chain_of_sigma` |
| `qm_fwd_chain` is separate | Defined at `RootScopedChain.lean:1501-1516`; only used by `qm_bfmcs` |
| 3 live sorry sites | `RootScopedChain.lean:953, 958, 963` — all inside `dd_bfmcs_restricted_*` |
| `qm_bfmcs` has deeper obstructions | `RootScopedChain.lean:1897-1901`: restricted_buc step is documented as semantically invalid |

**The claim in Report 41 was correct**: `qm_bfmcs` is dead code and `dd_countermodel` uses only `dd_bfmcs`. The three live sorry targets are `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, and `dd_bfmcs_restricted_fuc`.
