# Teammate B Findings: Alternative BFMCS Constructions
## Task 93, Round 40

---

## Key Findings

- The three sorry sites in `RootScopedChain.lean` have distinct natures: `restricted_tc` requires proving `forward_F` for sigma-scoped formulas, while `restricted_buc` and `restricted_fuc` require Until/Since coherence. All three converge on one fundamental obstruction: the depth-0 `forward_F` base case.

- The dd_chain construction has an irreducible conflict: `enriched_fwd_step` preserves F-obligations (proven by `rr_fwd_chain_F_obligation_persists`) but cannot guarantee eventual resolution because the BX11 fold at each resolving step may perpetually discharge a *different* target formula, deferring any given ψ indefinitely. This is the "perpetual deferral" obstruction documented in Report 26.

- The Boneyard deterministic chain (`DeterministicChain.lean`) achieves backward Until coherence trivially because the chain is *constant* (each step applies `x_content`/`y_content` deterministically). However, the boneyard's `YX_round_trip` and `XY_round_trip` lemmas both rely on `x_det`/`y_det`/`yx_identity` axioms marked sorry -- these are not available in the current BX axiom system. The boneyard approach is dead without X/Y determinacy axioms.

- The quasimodel infrastructure is sorry-free through Phase 3: `hintikka_chain_exists` is fully proved (strong induction on `defect_count`), `hintikka_chain_exists_since` mirrors it for Since. The chain is witnessed (every Hintikka point has a backing BXPoint), and `bx_until_eventuality_resolution` / `bx_since_eventuality_resolution` in `Frame.lean` are proved via `bx_forward_witness` and `bx_backward_witness`.

- `restricted_buc` has a provable path that does NOT require `forward_F`: since `ψ ∈ fam.mcs s` is directly given as a hypothesis in the backward direction, BX8 (`ψ → φ U ψ`) gives `φ U ψ ∈ fam.mcs s`. Then BX-chain box stability propagates this backward. However, the full interval guard (`∀ r, t ≤ r → r < s → φ ∈ fam.mcs r`) is non-trivial.

- `restricted_fuc` does require `forward_F` in some form: given `φ U ψ ∈ fam.mcs t`, we must produce `s ≥ t` with `ψ ∈ fam.mcs s`. BX10 gives `F(ψ) ∈ fam.mcs t`, and `forward_F` for `ψ` would yield the witness. This is exactly the depth-0 sorry.

---

## Alternative Approaches

### Approach A: Two-Pass Chain

**Idea**: Build dd_chain for F-resolution first (using a counting/priority argument to prevent perpetual deferral), then extend the chain to satisfy Until coherence by adding witnessing steps between existing chain elements.

**Pros**:
- Reuses existing `rr_fwd_chain` infrastructure.
- F-obligation persistence lemmas are already proved.

**Cons**:
- The "counting argument" to prevent perpetual deferral has been exhaustively analyzed in Sections 1-30 of RootScopedChain (archived to Boneyard). No counting argument survives because Case 4 (when `F(G(¬ψ)) ∈ M`) allows the enriched seed to choose `G(¬ψ)` at any resolving step. This approach is blocked at the same point as the current approach.
- LOC: High (400+), risk: Very high. The same obstruction applies.

### Approach B: Unified BFMCS Addressing All Three Coherence Conditions Simultaneously

**Idea**: Design a new FMCS where the chain is built by interleaving two kinds of steps: (1) defect-discharge steps driven by `bx_until_eventuality_resolution` (for Until/Since witnesses in `Frame.lean`), and (2) forward witness steps driven by `bx_forward_witness` (for F-witnesses). Each step type is idempotent; schedule them together.

**Pros**:
- `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` are already sorry-free in `Frame.lean`.
- `bx_forward_witness` and `bx_backward_witness` are sorry-free.
- All three are built on Lindenbaum extensions from consistent seeds, which is the standard pattern.

**Cons**:
- The resulting chain changes between steps (each step extends to a new MCS). The backward Until coherence requires a *guard interval*: for all `r` between `t` and `s`, `φ ∈ fam.mcs r`. This requires either (a) the chain is dense enough that every such r is a step, or (b) G-stability of φ is proved separately.
- For `restricted_buc`: the hypothesis is a witness exists; we need to construct `φ U ψ` in the current chain state. This is provable via BX8 if `ψ` is already present, but requires identifying the right time step.
- Estimated LOC: 600-900. Risk: Medium-high (interval guard remains non-trivial).

### Approach C: Quasimodel-as-Primary (Recommended)

**Idea**: Use the sorry-free `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` from `Frame.lean` as the *primary* mechanism. Build a new FMCS/BFMCS whose chain is derived from the canonical preorder structure of BXPoints, rather than from Lindenbaum extensions of Lindenbaum extensions.

**Concrete construction**:
- For `restricted_fuc` (forward Until): Given `φ U ψ ∈ fam.mcs t`, call `bx_until_eventuality_resolution` to get `v : BXPoint` with `bx_le fam(t) v` and `ψ ∈ v`. Define `fam.mcs (t+1) := v.formulas`. The interval guard `φ ∈ fam.mcs r` for `t ≤ r < t+1` is vacuously true (no integers strictly between t and t+1). This resolves `restricted_fuc` trivially for integer-indexed chains.
- For `restricted_buc` (backward Until): The hypothesis provides `s` with `ψ ∈ fam.mcs s` and the interval guard. Since the interval guard is satisfied by hypothesis, apply BX8 backward: `ψ ∈ fam.mcs s → φ U ψ ∈ fam.mcs s` by reflexivity. Then propagate backward using G-persistence of `φ U ψ`. Wait -- this is the backward direction (conclude `φ U ψ ∈ fam.mcs t`), which requires Until introduction, not just BX8. BX8 only introduces `φ U ψ` at `s`, not at `t < s`.

Actually for `restricted_buc`: the standard approach uses the BX axiom `(φ ∧ (φ U ψ)) ∨ ψ → φ U ψ` (BX9 backwards). If `ψ ∈ chain(s)` and `φ ∈ chain(r)` for all `t ≤ r < s`, then by backward induction: `ψ ∈ chain(s) → φ U ψ ∈ chain(s)` (BX8), then `φ ∈ chain(s-1)` and `φ U ψ ∈ chain(s)` → BX7 (`φ ∧ G(P(φ U ψ)) → φ U ψ`) or BX6 (absorption). The key issue is that "backward from `s` to `t`" requires an induction that uses `φ U ψ ∈ chain(s)` as base and propagates to `φ U ψ ∈ chain(s-1)` using `φ ∈ chain(s-1)`.

**Analysis of `restricted_buc` via BX axioms**: Axiom BX7 (`(φ U (φ ∧ (φ U ψ))) → φ U ψ`) and BX5 (self-accumulation) provide absorption. If the chain is built step-by-step (integer-indexed), then backward induction on the interval works: base case `φ U ψ ∈ chain(s)` (by BX8 from `ψ ∈ chain(s)`), inductive step uses BX6 (absorb) to get `φ U ψ ∈ chain(r)` from `φ U ψ ∈ chain(r+1)` and `φ ∈ chain(r)`. This requires: **a provable absorption step from BX6**. The key question is whether BX6 gives backward Until introduction. Reading the axioms: BX6 is `φ U (φ ∧ (φ U ψ)) → φ U ψ`. This is forward (gives `φ U ψ` from a stronger Until formula). The backward introduction from `(φ ∈ now) ∧ (φ U ψ ∈ next)` to `φ U ψ ∈ now` requires a different axiom.

Looking at `until_intro` / `since_intro` in TemporalDerived (referenced by DeterministicFMCS.lean as "Backward Until and backward Since in `usc` are sorry-free using `until_intro`/`since_intro` from TemporalDerived + backward induction on the deterministic chain"): these likely provide exactly `(φ ∈ now) ∧ (φ U ψ ∈ next_step) → φ U ψ ∈ now`. If these are proved in TemporalDerived, `restricted_buc` is provable by backward induction on the integer interval `[t, s]`.

**Pros of Approach C**:
- `bx_until_eventuality_resolution` is sorry-free and gives exactly the forward Until witness needed for `restricted_fuc`.
- The `restricted_buc` backward induction works over integer intervals (vacuously true for adjacent steps), reducing to `until_intro` from TemporalDerived.
- `restricted_tc` (forward_F for sigma-scoped formulas) is reducible to BX10 (`φ U ψ → F(ψ)`) + `forward_F` for F-witnesses. If the chain is built via `bx_forward_witness`, then `forward_F` holds by construction.

**Cons**:
- Building a new FMCS from scratch requires defining its `mcs` function (which BXPoint to use at each integer), proving it is an MCS at each step, proving G/H coherence, and proving all coherence properties.
- The chain must be simultaneously: (a) forward-G coherent, (b) backward-H coherent, (c) forward-F witnessing, (d) backward-P witnessing. These come from different Lindenbaum constructions and may conflict.
- Estimated LOC: 800-1200. Risk: Medium. The core tools are sorry-free; the challenge is wiring them.

### Approach D: Constant Chain + Separate F-Witnesses

**Idea**: Build the chain as constant (same MCS at every time step) for backward Until coherence, then handle F-witnesses through a separate "co-chain" mechanism. The constant chain satisfies `restricted_buc` trivially (every formula present at every time means Until is trivially satisfied), but violates `restricted_tc` and `restricted_fuc` unless F-witnesses are provided externally.

**Pros**:
- Constant chain makes `restricted_buc` trivial: `φ U ψ ∈ chain(t)` for all `t` if `ψ ∈ chain(0)`, by BX8 reflexivity.
- `restricted_tc` for F-formulas: `F(φ) ∈ chain(t)` for all `t` if `φ ∈ chain(0)`.

**Cons**:
- A truly constant chain (same MCS everywhere) cannot satisfy `restricted_tc` for formulas where `¬φ ∈ chain(0)` and `F(φ) ∈ chain(0)`. These exist and require actual witnesses. So the chain cannot be constant; this approach collapses back to needing forward F-witnesses.
- The boneyard deterministic chain shows this path leads to the same sorry (see `deterministic_forward_F`).
- LOC: N/A. Not viable without X/Y determinacy axioms.

---

## Recommended Approach

**Approach C with tight scoping to BX axioms** is the most promising.

The key insight: for *integer-indexed* chains, the interval `[t, s]` for Until contains finitely many integers. This means:

1. **`restricted_fuc`**: Call `bx_until_eventuality_resolution` → gives `v` with `bx_le chain(t) v` and `ψ ∈ v`. Define `s = t + 1` and use `v` as `chain(t+1)`. The interval guard `∀ r, t ≤ r < t+1 → φ ∈ chain(r)` is vacuously true (the only such `r` is `t`, and `φ ∈ chain(t)` by BX9 from `φ U ψ ∈ chain(t)`). **This resolves `restricted_fuc` without `forward_F`.**

2. **`restricted_buc`**: Given `s, ψ ∈ chain(s), ∀ r ∈ [t,s): φ ∈ chain(r)`, prove `φ U ψ ∈ chain(t)`. By backward induction on `[t,s]`: base `φ U ψ ∈ chain(s)` from BX8; step `φ U ψ ∈ chain(r+1)` and `φ ∈ chain(r)` → `φ U ψ ∈ chain(r)` via `until_intro` from TemporalDerived. **This resolves `restricted_buc` if `until_intro` is available.**

3. **`restricted_tc`**: `F(φ) ∈ chain(t)` → need `s > t, φ ∈ chain(s)`. By BX12, `F(φ) ∈ chain(t) → ⊤ U φ ∈ chain(t)`. By `restricted_fuc` (proved in step 1), there is `s ≥ t` with `φ ∈ chain(s)`. **This resolves `restricted_tc` by reduction to `restricted_fuc`.**

**Critical dependency**: This works only if the FMCS used for dd_bfmcs supports calling `bx_until_eventuality_resolution` with appropriate hypotheses. The current `dd_fmcs` is built on `rr_fwd_chain` (Lindenbaum extensions). The question is whether we can replace `dd_fmcs` with one built on `bx_forward_witness` / `bx_until_eventuality_resolution`.

**Alternative**: Keep the existing `dd_bfmcs` structure but prove the three sorries by leveraging the existing `bx_until_eventuality_resolution` bridge through a `shifted_dd_fmcs`-compatible argument. Since `shifted_dd_fmcs` families contain `BXPoint`-derived MCS values (via `rr_fwd_chain` seeds that include `g_content`), there exists a bx_le path from any chain element to a witnessing BXPoint. The gap is proving the connection between chain elements and bx_le.

---

## Confidence Level

- Approach C (quasimodel-as-primary / bx_until_eventuality_resolution-based) resolving `restricted_fuc`: **High confidence** (70%). The vacuous interval guard for adjacent integers is genuine.
- Approach C resolving `restricted_buc` via `until_intro` backward induction: **Medium confidence** (50%). Depends on `until_intro` from TemporalDerived being available and having the right signature.
- Approach C resolving `restricted_tc` by reduction to `restricted_fuc`: **High confidence** (75%). The BX12 bridge is proved (`F_imp_top_until_mcs`).
- Any approach resolving the depth-0 `forward_F` base case for the current `rr_fwd_chain`: **Very low confidence** (10%). The obstruction is fundamental and documented in 30 archived sections.

---

## Evidence

**Supporting Approach C:**

- `bx_until_eventuality_resolution` in `Frame.lean` is sorry-free (proved via `bx_forward_witness` + BX9 + BX10).
- `bx_since_eventuality_resolution` is similarly sorry-free.
- `F_imp_top_until_mcs` in `CanonicalChain.lean` provides the BX12 bridge (`F(ψ) → ⊤ U ψ`).
- `defect_step_phi` in `DefectChain.lean` gives `φ ∈ w` from `φ U ψ ∈ w` and `ψ ∉ w` (BX9), needed for the interval guard at `t`.
- `hintikka_chain_exists` in `Construction.lean` is fully sorry-free, providing infrastructure for defect-free chain existence (though this applies to HintikkaPoints, not FMCS chains directly).

**Against dd_chain-based approaches:**

- `rr_fwd_chain_forward_F` (lines 1386-1424) has the depth-0 base case as `sorry`, with 30 archived sections confirming no fix exists within the current construction.
- `dd_fmcs_forward_F` (line 1426) has an additional `sorry` for the t < 0 case.
- `dd_fmcs_backward_P` (line 1459) also `sorry`.
- Both `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` (lines 1519, 1524) are `sorry`.

**Key infrastructure to verify before committing:**

1. Whether `until_intro` / `since_intro` from `TemporalDerived` have the signature: `φ ∈ chain(r) → φ U ψ ∈ chain(r+1) → φ U ψ ∈ chain(r)`.
2. Whether a new FMCS built on BXPoints satisfies the FMCS G/H coherence axioms (these require `∀ t t', t < t' → G(φ) ∈ mcs t → φ ∈ mcs t'`), which follows from `bx_G_forward` if the chain respects `bx_le`.
3. Whether the three coherence sorries can be proved for `dd_bfmcs` directly by exploiting the `bx_le`-compatible structure of chain elements (each `rr_fwd_chain` element contains `g_content(M₀)`, implying `bx_le M₀ chain(n)` for all n ≥ 0).

**Files consulted:**
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (lines 1400-1600, 1160-1425, 1-80)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean`
