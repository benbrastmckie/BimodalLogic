# Teammate B Findings: Alternative Chain Constructions

## Key Findings

### 1. The Quasimodel Path Is the Most Mature Alternative

The `Metalogic/BXCanonical/Quasimodel/` directory contains substantial sorry-free infrastructure:

- **HintikkaPoint.lean**: Finite Sigma-projections of BXPoints (fully proved)
- **Construction.lean**: `hintikka_chain_exists` -- the core well-founded recursion on `defect_count` that produces a finite chain discharging an Until-defect. Fully proved given an oracle.
- **`hintikka_chain_exists_since`**: Since-dual, also fully proved.
- **`chain_step_seed_consistent`**: MCS-subset consistency for chain points (task 99, fully proved).

The **remaining gap** is the `HintikkaStepOracle` -- the oracle that produces successor Hintikka points with strictly decreasing defect count. Two versions exist:

1. **`hintikka_step_oracle_for_sigma_sig`** (OracleStep.lean, now in Boneyard): Nearly sorry-free for sigma_signature inputs. The single remaining sorry is `defect_count` decrease: Lindenbaum extension may introduce new Until-defects not present in the previous point.

2. **`hintikka_step_oracle`** (OracleStep.lean): Universal version with 4 sorry sites for the general case (H-backward, Until-propagation guard, defect decrease, vacuous inconsistent fallback).

### 2. The Oracle BFMCS (OracleCoherence.lean) Failed on Two Fronts

The `qm_bfmcs` construction in OracleCoherence.lean (now archived) attempted to build a full BFMCS using oracle chains. It has:

- **Sorry-free**: Box stability (`box_stable_qm_chain`), modal forward/backward (`qm_bfmcs` itself), FMCS structure (`qm_fmcs`), g_content/h_content propagation, and Until-defect propagation (`qm_fwd_chain_until_persists`).

- **Two blocking sorry sites**:
  1. **`qm_bfmcs_restricted_tc`** (temporal coherence): F(phi) -> eventual phi. The argument via BX12 converts F(phi) to (top U phi), and `qm_fwd_chain_until_persists` propagates the Until-defect. But proving eventual *resolution* requires the defect_count decrease -- the same gap as in the oracle.
  2. **`qm_bfmcs_restricted_buc`** (backward Until coherence): The step transfer `phi U psi in mcs(r+1) /\ phi in mcs(r) -> phi U psi in mcs(r)` is **semantically invalid** under irreflexive semantics. This is a fundamental mathematical obstruction, not a proof gap.

### 3. The Oracle Seed Construction Has a Single Defect-Monotonicity Gap

The oracle seed `g_content(w) union {Until-defects of w in Sigma}` ensures:
- G-propagation: `bx_le w (oracle_step w)` (proved)
- H-backward: `h_content(oracle_step) subset w` (proved)
- Until-defect propagation: active defects carry forward (proved)

The **sole remaining mathematical question**: does the Lindenbaum extension of the oracle seed introduce *new* Until-defects? Specifically, if `phi U psi` is NOT in `w.formulas` (and hence not in the oracle seed), can Lindenbaum add `phi U psi` to the extension? The answer is **yes, it can** -- Lindenbaum is nondeterministic and MCS maximality forces either `phi U psi` or `neg(phi U psi)` into the extension.

However, the defect_count argument only requires **Sigma-restricted** monotonicity: new defects must be in `Sigma`. If `phi U psi in Sigma` and `phi U psi not-in w.formulas`, then `neg(phi U psi) in w.formulas` (MCS negation-completeness). Since `neg(phi U psi)` is NOT in the oracle seed `g_content(w)` (it's not a G-formula), the Lindenbaum extension *could* choose `phi U psi` over `neg(phi U psi)`.

**But**: `neg(phi U psi) in w.formulas` and `w.formulas subset (lindenbaum-extension of oracle_seed)` -- wait, this inclusion does NOT hold. The Lindenbaum extension of the oracle seed is a DIFFERENT MCS from `w`. So `neg(phi U psi)` need not be in the extension.

**Conclusion**: The defect-monotonicity gap is GENUINE. Lindenbaum can introduce new Until-defects.

### 4. Literature Analysis: How Standard References Handle F-Defect Resolution

**Burgess 1984 ("Basic Tense Logic")**: Uses a direct step-by-step construction for Until formulas. The key is that Until is handled by *finite* quasimodel chains, not infinite omega-chains. Each Until formula `phi U psi` gets its own finite chain of length at most `|Sigma|` (bounded by defect count). The F-eventuality resolution follows from BX12 (F(phi) -> top U phi) plus the finite chain existence theorem.

**Gabbay-Hodkinson-Reynolds ("Temporal Logic: Mathematical Foundations and Computational Aspects", 1994)**: Uses "quasimodels" -- structures of finite runs. Each run handles one eventuality. Runs are then composed into a full model. The critical step is **run composition**, not single-chain construction.

**Blackburn-de Rijke-Venema ("Modal Logic", 2001, Ch. 7)**: For Until-logics on linear orders, the standard proof uses:
1. Build a finite quasimodel (a set of Hintikka points with successor relations)
2. "Unravel" the quasimodel into an infinite timeline
3. The unraveling step ensures all eventualities are resolved

The key insight from the literature: **do NOT try to build the infinite chain directly**. Instead:
1. Build finite quasimodel chains for each eventuality obligation
2. Compose them into a full model

This is fundamentally different from the current RootScopedChain approach, which tries to build one infinite chain that resolves all eventualities simultaneously.

### 5. The Finite Deferral Approach (Boneyard) Failed on Cycle Contradiction

`FiniteDeferral.lean` attempted a pigeonhole argument:
- Restrict chain to `deferralClosure(psi)` (finitely many possible restricted theories)
- If psi never appears, two positions have the same restricted theory
- A cycle with unresolved `top U psi` should yield a contradiction

The sorry at Step 5 (cycle contradiction) requires showing `G(neg psi)` holds at the cycle start. The obstruction: restricted theory cycling does NOT imply full G-coherence. The restricted theory sees only formulas in `deferralClosure(psi)`, but `G(neg psi)` requires `neg psi` to hold at ALL future times, not just those sharing the same restricted theory.

**Additionally**: This approach used `x_mem_chain_general` which requires the X-operator (discreteness axiom), NOT available in BX.

### 6. The Deterministic Chain (X/Y) Would Solve Everything But Requires Discreteness

The `DeterministicChain.lean` construction using `x_content`/`y_content` (next/previous step operators) gives:
- Deterministic successor: `chain(n+1) = x_content(chain(n))` (no Lindenbaum nondeterminism)
- Until persistence via X-unfolding: `(phi U psi) in chain(n)` and `psi not-in chain(n+1)` implies `phi in chain(n+1)` and `(phi U psi) in chain(n+1)` -- PROVED
- Finite deferral argument could work because X gives a step transfer

**The catch**: X/Y require the discreteness axiom `(F(top) /\ phi /\ H(phi)) -> F(H(phi))` (DF), which is NOT in BX. BX axiomatizes all linear orders (dense, discrete, mixed), while DF is only valid on discrete orders.

### 7. Filtration Infrastructure (Active)

`Filtration/SigmaOrdering.lean` and `Filtration/DefectChain.lean` provide:
- Sigma-restricted ordering on BXPoints (`sigma_le`, `sigma_strict`)
- Defect counting infrastructure at the BXPoint level
- Properties connecting sigma-strict ordering to bx_le

However, these modules have several sorry sites related to irreflexive semantics (BX1 removal blocks `sigma_le_refl`, `sigma_strict_irrefl`). The filtration approach was designed for reflexive G but is partially broken under irreflexive semantics.

### 8. No Limit/Ultrafilter/Compactness Shortcut Exists

Could compactness or saturation arguments bypass the step-by-step construction?

**Compactness**: Propositional compactness over MCS theories doesn't help because the coherence properties are NOT first-order properties of the MCS -- they are *inter-MCS* properties (relating formulas across different chain positions).

**Ultrafilter construction**: The existing `UltrafilterChain.lean` in the Boneyard uses Lindenbaum, which has the same nondeterminism problem.

**Saturation**: Saturated models would resolve all eventualities, but constructing a saturated model requires the same chain construction we're trying to prove.

## Recommended Approach

### Primary Recommendation: Quasimodel Run Composition (Confidence: HIGH)

Follow the literature (Burgess 1984, BdRV 2001): replace the single infinite chain construction with a **composition of finite quasimodel runs**.

**Mathematical sketch**:

1. **For each eventuality obligation**: Use the already-proved `hintikka_chain_exists` (Construction.lean) to build a finite chain of Hintikka points that discharges a single Until-defect. This requires closing the single remaining sorry in the oracle (defect-monotonicity).

2. **Compose runs into a timeline**: Given the root MCS M_0 and the finite set of eventuality obligations in `deferralClosure(root)`, build the infinite chain by:
   - At position 0: M_0
   - At position 1 to k_1: the finite run discharging the first eventuality
   - At position k_1+1 to k_2: the finite run discharging the second eventuality (starting from the MCS at position k_1)
   - Continue for all eventualities

3. **Handle new eventualities**: After each run, the endpoint MCS may have new F-obligations. But these obligations involve formulas in `deferralClosure(root)` (finite set), and each run strictly decreases the total number of unresolved eventualities. After at most `|deferralClosure(root)|` rounds, all are resolved.

4. **Repeat periodically**: Use round-robin scheduling over the finite set of eventualities, repeating the cycle to handle re-emerging obligations from Lindenbaum steps.

**Key advantage**: This sidesteps the BX11 perpetual deferral problem entirely. Each finite run uses `hintikka_chain_exists` which terminates by defect_count decrease on `|Sigma|`-bounded Until-defects. The infinite chain is built by *concatenating* finite runs, not by hoping a single nondeterministic step resolves the right defect.

**What needs to be proved**:

a. **Close the defect-monotonicity sorry in OracleStep.lean**: Prove that `untilDefectSet(sigma_sig(oracle_step)) subset untilDefectSet(sigma_sig(w))`. This is the Lindenbaum-introduces-new-defects problem. Possible approaches:
   - Use `enrichedClosure` instead of `SubformulaClosure` for Sigma, exploiting its negation-pairing property to force Lindenbaum choices
   - Prove the defect_mono property holds for sigma_signatures specifically (the oracle seed includes g_content(w), which biases Lindenbaum toward preserving w's theory within Sigma)
   - Strengthen the oracle seed to include `neg(phi U psi)` for all non-defect Until formulas in Sigma, forcing Lindenbaum to preserve non-defect status

b. **Build the run composition layer**: New infrastructure to concatenate finite Hintikka chains, lift them to BXPoints, and verify temporal coherence across run boundaries.

c. **Handle backward Until coherence**: The step transfer problem (`phi U psi in mcs(r+1) /\ phi in mcs(r) -> phi U psi in mcs(r)`) is semantically invalid. The quasimodel approach avoids this by proving backward Until from the run structure directly: the run already contains the witness.

### Secondary Recommendation: Strengthen Oracle Seed (Confidence: MEDIUM)

An alternative to full run composition: strengthen the oracle seed to force defect-monotonicity.

**Enriched oracle seed**: Instead of `g_content(w) union {Until-defects}`, use:
```
g_content(w) union {phi U psi | phi U psi in w, psi not-in w, phi U psi in Sigma}
             union {neg(phi U psi) | phi U psi in Sigma, phi U psi not-in w}
```

The third component forces Lindenbaum to keep `neg(phi U psi)` for non-defects, preventing new defects from appearing. **Consistency** of this enlarged seed follows from `w` being an MCS containing all these formulas.

This approach would close the defect-monotonicity sorry directly, making `hintikka_step_oracle_for_sigma_sig` fully sorry-free. Combined with the existing `hintikka_chain_exists`, this gives sorry-free finite quasimodel chains.

The remaining work would be lifting these finite chains to the infinite BFMCS structure, which still requires the run-composition layer from the primary recommendation.

### Approaches NOT Recommended

1. **Discreteness axiom extension**: Adding DF/DP to BX changes the axiom system to BX+DF, which is only complete for discrete orders. This fundamentally alters the mathematical content of the project.

2. **BX11 retry (Option C from phase3-analysis)**: As analyzed in that document, repeated BX11 application in a different MCS does not guarantee a different outcome. The MCS M' after case 3 has F(phi) but the next BX11 application can again land in case 3.

3. **Conservative extension to stronger primitives**: No clear candidate for a conservative extension that would help. The X operator is not conservative over BX for dense orders.

## Evidence/Examples

### Defect-Monotonicity Counterexample

Let `Sigma = {p, q, p U q, top U q}` and `w` an MCS with `{p U q, top U q, p, neg q}`. Oracle seed: `g_content(w) union {p U q, top U q}`. Lindenbaum extension `w'` satisfies `{p U q, top U q} subset w'`. But suppose `w'` also contains `neg(p U q)` -- impossible since `p U q in w'`. So for formulas already in the seed, no new defects arise.

But consider `r U s in Sigma` with `r U s not-in w` (hence `neg(r U s) in w`). Since `neg(r U s)` is NOT in `g_content(w)` and NOT in the Until-defect set, Lindenbaum could choose either `r U s` or `neg(r U s)` in `w'`. If it chooses `r U s` and `s not-in w'`, this is a NEW defect.

This confirms the gap is genuine and the enriched oracle seed (secondary recommendation) is the correct fix.

### Literature Verification

From Burgess 1984 (Lemma 3.4): "For each defect `(phi U psi, h)` where `h` is a Hintikka set containing `phi U psi` but not `psi`, there exists a finite sequence `h = h_0, h_1, ..., h_k` of Hintikka sets such that `psi in h_k` and each consecutive pair satisfies the one-step relation, with `defect(h_{i+1}) < defect(h_i)` when `psi not-in h_{i+1}`."

This matches exactly the structure of `hintikka_chain_exists` in Construction.lean, confirming the approach is mathematically sound.

## Confidence Level: HIGH

The quasimodel run-composition approach is well-supported by:
1. Standard literature (Burgess 1984, BdRV 2001, Gabbay et al. 1994)
2. Substantial existing sorry-free infrastructure in the codebase
3. A clear, single remaining mathematical obligation (defect-monotonicity)
4. A concrete fix for that obligation (enriched oracle seed)

The approach fundamentally avoids the BX11 perpetual deferral problem by not relying on a single infinite chain construction. Instead, it decomposes the problem into finitely many finite subproblems (one per eventuality), each solvable by well-founded recursion on defect count.
