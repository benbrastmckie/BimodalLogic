# Teammate D: Literature-Aligned Long-Term Solution Design

**Task**: 93 - Close BXCanonical completeness proof
**Date**: 2026-04-18
**Focus**: Mathematically correct long-term solution based on standard literature

## Key Findings

### 1. Sorry Inventory (Active Path)

The active completeness path is:
```
bx_completeness (Completeness.lean)
  -> dd_countermodel (RootScopedChain.lean)
    -> dd_bfmcs_restricted_tc    [SORRY - 3 leaf sorries]
    -> dd_bfmcs_restricted_buc   [SORRY - 2 leaf sorries]
    -> dd_bfmcs_restricted_fuc   [SORRY - 2 leaf sorries]
```

These 3 top-level sorry theorems delegate to `qm_bfmcs_restricted_tc/buc/fuc` which have their own sorries. In total there are **7 leaf `exact sorry` sites** on the active path (RootScopedChain.lean lines 878, 883, 921, 929, 957, 961, plus OracleStep.lean line 272 and 452).

### 2. Root Cause Analysis

There are **two fundamentally distinct blocking problems**:

**Problem A: Defect count decrease (OracleStep.lean)**
The oracle step constructs `qm_oracle_step w Sigma` via Lindenbaum extension of `g_content(w) ∪ {Until-defects}`. The Lindenbaum extension is over ALL formulas, not just Sigma. New Until-formulas from outside Sigma can enter the extended MCS, potentially creating new defects within Sigma. The `defect_count` may not decrease.

**Problem B: Backward Until step transfer (RootScopedChain.lean:1897-1901)**
To prove backward Until coherence, we need: if `phi U psi in mcs(r+1)` and `phi in mcs(r)`, then `phi U psi in mcs(r)`. The docstring at line 1897 correctly identifies that `phi /\ F(phi U psi) -> phi U psi` is semantically invalid. No BX axiom closes this gap for the current chain construction.

### 3. Literature Analysis

#### 3.1 Goldblatt's "Logics of Time and Computation" (1987/1992)

Goldblatt's approach to Until completeness for linear temporal logic uses the **filtration-through-quasimodels** technique:

1. **Quasimodel**: A finite pre-model over a Sigma-closure where local consistency holds but temporal witnessing may fail. Formally, a sequence `h_0, h_1, ..., h_k` of Hintikka sets (subsets of SubformulaClosure(root)) satisfying:
   - G-propagation: `G(chi) in h_i -> chi in h_{i+1}`
   - H-backward: `H(chi) in h_{i+1} -> chi in h_i`
   - Until propagation: `phi U psi in h_i, psi not in h_i -> phi in h_i, phi U psi in h_{i+1}`

2. **Defect discharge**: A defect is `phi U psi in h_i` with `psi not in h_i`. The key property: **defects in Sigma can only decrease** along the chain because the Hintikka points are FINITE subsets of Sigma. At each step, either psi enters (resolving the defect) or the defect propagates but no NEW defects in Sigma are created.

3. **Termination**: Since `|Sigma|` is finite, the chain terminates in at most `|Sigma|` steps.

4. **Unravelling**: The quasimodel is then "unravelled" into a proper model by repeating the finite sequence omega times.

**Critical observation**: In Goldblatt's setting, the Hintikka points are finite subsets of Sigma, so defect monotonicity is trivial. The problem in BX is that we build BXPoints (full MCS) and project to Sigma, but the projection can CREATE defects not present in the pre-projection point.

#### 3.2 Burgess (1984) "Basic Tense Logic"

Burgess constructs the canonical model for Until/Since by:

1. Starting with a "defective" MCS w_0 (containing `phi U psi` but not `psi`)
2. Building a FINITE chain w_0, w_1, ..., w_k where each w_i is an MCS
3. At each step, the seed is `g_content(w_i) ∪ {phi U psi}` (the defect is explicitly propagated)
4. The chain terminates when `psi in w_k`

The key insight Burgess uses: the chain is constructed to resolve ONE specific defect at a time. Other defects are ignored and handled by a separate induction.

#### 3.3 Xu (1988) "Completeness for Until-Since"

Xu extends Burgess to handle both Until and Since on linear orders, using:
- BX4/BX4' (temporal connectedness) to ensure the chain is "well-connected"
- BX11/BX11' (temporal linearity) to order witness resolution

### 4. The Correct Approach: Sigma-Restricted Oracle Step

**Confidence: HIGH**

The fundamental fix is to **restrict the oracle step to Sigma** instead of using full Lindenbaum extension. This matches the literature exactly.

#### 4.1 Construction

Given BXPoint `w` and `Sigma = SubformulaClosure(root)`:

**Current (broken)**: `qm_oracle_step w Sigma` = Lindenbaum extension of `g_content(w) ∪ {Until-defects-in-Sigma}` over ALL formulas. Result is a full MCS. Projection to Sigma may have new defects.

**Proposed (correct)**: Work entirely at the Hintikka point level (finite subsets of Sigma). The oracle step constructs a NEW Hintikka point `h'` from `h = sigma_signature(w, Sigma)` by:
1. Include `{chi | G(chi) in h}` (G-propagation within Sigma)
2. Include `{phi U psi | phi U psi in h, psi not in h}` (defect propagation)
3. Extend to a locally maximal subset of Sigma (NOT a full MCS)

With this construction, defect monotonicity is AUTOMATIC because the Hintikka point h' is a subset of Sigma, and the only Until-formulas in h' are those propagated from h or derivable within Sigma.

#### 4.2 Why This Fixes Problem A

The defect count is `|{phi U psi in Sigma | phi U psi in h.formulas, psi not in h.formulas}|`. Since both h and h' are subsets of Sigma:
- Propagated defects: `phi U psi in h' because phi U psi was a defect at h`. This is at most the same defect set.
- New defects: Cannot arise from outside Sigma because h' is a SUBSET of Sigma.
- The target defect either resolves (psi enters h') or persists. If ALL defects persist and none resolve, the defect count stays the same. But by the oracle construction (via BX10: F(psi) in w, and forward witness existence), the target defect MUST eventually resolve.

Actually, this is the WRONG analysis. The issue is more subtle. Let me reconsider.

#### 4.3 Revised Analysis: The REAL Fix for Problem A

The `hintikka_step_for_sigma_sig` theorem (OracleStep.lean:188-222) is already **sorry-free** for sigma_signature inputs. The sorry is only in `hintikka_step_or_condition_sigma_sig` at line 272 (the defect count decrease).

The defect count decrease sorry at OracleStep.lean:272 is in the branch where `psi not in oracle_step`. The issue (line 260-272): a defect at `sigma_sig(oracle)` was already at `sigma_sig(w)` if it came from the oracle seed, but Lindenbaum may have added Until-formulas to `oracle_step` that are also in Sigma.

**Key insight**: The oracle seed is `g_content(w) ∪ {Until-defects-in-Sigma}`. Any Until-formula `f U g in oracle_step` with `f U g in Sigma` either:
- (a) Was in the oracle seed (was a defect at w): then f U g was a defect at sigma_sig(w)
- (b) Was added by Lindenbaum: f U g in Sigma but f U g NOT in seed

Case (b) is the problem. But notice: if `f U g in oracle_step` (via Lindenbaum) and `g not in oracle_step`, this is a new defect. However, `f U g in Sigma` means `f U g` is a subformula of root. The question: can Lindenbaum introduce `f U g` when it was NOT in `g_content(w)` and NOT a defect at w?

If `f U g not in w.formulas`: Then `neg(f U g) in w.formulas` (MCS completeness). By g_content: `G(neg(f U g)) in w`? No, g_content is `{chi | G(chi) in w}`, not `{chi | chi in w}`.

The answer: **yes, Lindenbaum can introduce any formula consistent with the seed**. There is no guarantee that `f U g` enters oracle_step only from the seed. This is the genuine gap.

#### 4.4 The Two-Level Solution

**Level 1: Sigma-level Hintikka chain (already exists)**

The `hintikka_chain_exists` theorem (Construction.lean:594-659) already constructs the chain at the Hintikka point level, using `defect_count` for termination. It takes a `HintikkaStepOracle` as input.

**Level 2: Oracle construction**

The oracle `hintikka_step_oracle_for_sigma_sig` (OracleStep.lean:420-452) is sorry-free EXCEPT for the defect count decrease (line 452). This is the SINGLE remaining mathematical gap for the entire Until-direction chain construction.

### 5. Proposed Chain Construction for the Complete Proof

**Confidence: HIGH for architecture, MEDIUM for defect decrease**

#### 5.1 Forward Until Coherence (restricted_fuc)

Given `phi U psi in mcs(t)`:
1. By BX10: `F(psi) in mcs(t)`
2. By BX12: `top U psi in mcs(t)` (convert F-obligation to Until-defect)
3. Build Hintikka chain from `sigma_signature(BXPoint(mcs(t)), Sigma)` via `hintikka_chain_exists`
4. The chain gives a sequence of Hintikka points `h_0, ..., h_k` with `psi in h_k`
5. Each h_i is backed by a BXPoint w_i (via ChainWitnessed)
6. The BXPoints w_0, ..., w_k form a bx_le chain
7. Guard: at each step i < k where `psi not in h_i`, by hintikka_step Until-propagation: `phi in h_i`, hence `phi in w_i`

**The gap**: Step 3 requires the oracle to have defect_count decrease. The existing `hintikka_step_oracle_for_sigma_sig` has this sorry.

#### 5.2 Backward Until Coherence (restricted_buc)

Given witness at s >= t with guard on [t, s):
- At s: `psi in mcs(s)`, so `phi U psi in mcs(s)` by BX8
- At each r in [t, s): need `phi U psi in mcs(r)` from `phi in mcs(r)` and `phi U psi in mcs(r+1)`

**This is Problem B.** The step transfer `phi U psi in mcs(r+1), phi in mcs(r) -> phi U psi in mcs(r)` is NOT derivable for the current chain.

**Literature solution**: In Goldblatt/Burgess, backward Until coherence follows from the construction: the chain is built SPECIFICALLY to satisfy Until. The quasimodel chain has `phi U psi` at every interior point BY CONSTRUCTION (it's in the oracle seed).

**Adaptation to BX**: Use the oracle chain `qm_fwd_chain` for forward Until, but ALSO include `phi U psi` in the seed at each step. The oracle seed already does this: `g_content(w) ∪ {Until-defects-in-Sigma}`. If `phi U psi in w_i` and `psi not in w_i`, then `phi U psi` is in the seed for `w_{i+1}`. So `phi U psi in w_{i+1}`.

But this gives FORWARD propagation of `phi U psi`, not backward. For backward: if `phi U psi in w_{i+1}` (from oracle seed), we need `phi U psi in w_i`. Well, it's already there by hypothesis (it was a defect at w_i).

Wait -- the backward Until coherence question is different. It asks: given that `psi in mcs(s)` and `phi in mcs(r)` for all r in [t, s), derive `phi U psi in mcs(t)`.

This is NOT about propagating an existing `phi U psi` forward. It's about DERIVING `phi U psi in mcs(t)` from the witness pattern.

**The correct approach for backward Until**: Don't use the scheduling chain for this. Instead, build a SEPARATE quasimodel chain that directly verifies the witness pattern. Alternatively, use BX axioms to derive `phi U psi in mcs(t)` algebraically.

#### 5.3 Algebraic Approach to Backward Until

From `psi in mcs(s)` we get `phi U psi in mcs(s)` by BX8. Now induct backward:

**Inductive step**: Given `phi U psi in mcs(r+1)` and `phi in mcs(r)`, derive `phi U psi in mcs(r)`.

By BX4': `H(F(phi U psi)) in mcs(r+1)` (connectedness). By h_content backward: `F(phi U psi) in mcs(r)`. So we have `phi in mcs(r)` and `F(phi U psi) in mcs(r)`.

By BX12: `F(phi U psi) -> top U (phi U psi)`. So `top U (phi U psi) in mcs(r)`.

Now we need: from `phi in mcs(r)` and `top U (phi U psi) in mcs(r)`, derive `phi U psi in mcs(r)`.

By BX7 (linearity of Until): `(alpha U beta) /\ (gamma U delta) -> (alpha U (beta /\ (gamma U delta))) \/ (gamma U (delta /\ (alpha U beta))) \/ ((alpha /\ gamma) U (beta /\ delta))`.

With alpha = phi, beta = psi, gamma = top, delta = (phi U psi):
`(phi U psi) /\ (top U (phi U psi)) -> ... ` -- but we don't have `phi U psi in mcs(r)`, that's what we're trying to prove.

Alternative: can we use `phi /\ (top U (phi U psi)) -> phi U psi`?

Let me think about this semantically. If `phi` holds now and `top U (phi U psi)` holds (meaning `phi U psi` holds at some future point, with top guarding until then), does `phi U psi` hold now?

Semantically: `phi U psi` means "psi at some s >= r, phi on [r, s)". We have phi at r. We have "phi U psi at some s' > r" (from top U (phi U psi)). Unpacking: at s', there exists s'' >= s' with psi at s'' and phi on [s', s''). So psi at s'' and phi on [r, r] union [s', s''). But phi may NOT hold on (r, s'). So `phi U psi at r` is NOT guaranteed.

This confirms the docstring at RootScopedChain.lean:1897: `phi /\ F(phi U psi) -> phi U psi` is semantically invalid.

#### 5.4 The Enriched Backward Seed Approach

**Confidence: MEDIUM-HIGH**

The literature approach is to build the chain KNOWING the backward Until requirement from the start. Specifically, modify the oracle seed for the backward direction:

For each step building `mcs(r)` as predecessor of `mcs(r+1)`:
- Seed: `h_content(mcs(r+1)) ∪ {phi | phi U psi in mcs(r+1) for some relevant Until}`
- Specifically: if `phi U psi in mcs(r+1)` and `phi U psi in Sigma`, include `phi U psi` in the backward seed

This modifies `qm_oracle_seed_bwd` to also include Until-formulas from the successor. The resulting `mcs(r)` then has `phi U psi in mcs(r)` by construction.

**Wait**: This changes the construction order. The backward chain is built from `mcs(0)` backward. At step n+1, `mcs(-(n+1))` is built from `mcs(-n)`. To include Until-formulas from the successor (which is `mcs(-n)`), we need to know `mcs(-n)` first -- which we do, since we're iterating backward!

So the enriched backward seed is:
```
qm_oracle_seed_bwd_enriched(w, Sigma) =
  h_content(w) ∪ {Since-defects-in-Sigma} ∪ {phi U psi | phi U psi in w, phi U psi in Sigma}
```

The last component includes Until-formulas from the successor (w = current point, building its predecessor). This ensures that if `phi U psi in w` and the predecessor has `phi`, then `phi U psi` is in the predecessor's seed, hence in the predecessor.

**Consistency**: The enriched seed is a subset of `w.formulas` (Since-defects are in w; h_content subset of w by temp_t_past; Until-formulas are in w). So the seed is consistent.

**Key property**: With this construction, backward Until coherence follows by construction:
- `phi U psi in mcs(r+1)` ensures `phi U psi` is in the enriched seed for `mcs(r)`
- After Lindenbaum extension, `phi U psi in mcs(r)`

### 6. Concrete Implementation Architecture

#### Phase 1: Fix the defect count decrease (closes Problem A)

**Target**: OracleStep.lean, line 452 (in `hintikka_step_oracle_for_sigma_sig`)

**Approach**: Prove `defect_count(sigma_sig(oracle_step)) < defect_count(sigma_sig(w))` when `psi not in oracle_step`.

The key lemma needed: `untilDefectSet(sigma_sig(oracle_step)) ⊆ untilDefectSet(sigma_sig(w))` (defect monotonicity for sigma_sig).

**Proof strategy**:
- A defect at sigma_sig(oracle_step) is: `f U g in Sigma, f U g in oracle_step, g not in oracle_step`
- Need: `f U g in w.formulas` and `g not in w.formulas`
- `f U g in oracle_step`: either from seed or from Lindenbaum
  - From seed (g_content or defect): `f U g in g_content(w)` implies `G(f U g) in w`, which implies `f U g in w` by temp_t. Or `f U g` was a defect at w (f U g in w, g not in w).
  - From Lindenbaum: `f U g in oracle_step` but `f U g not in seed`. Need `g not in w`.
- For the Lindenbaum case: since `g not in oracle_step`, and `g_content(w) ⊆ oracle_step`, we have `G(g) not in w` (otherwise `g in g_content(w) ⊆ oracle_step`). But `G(g) not in w` does NOT imply `g not in w`.

**This analysis confirms the gap is genuine**: Lindenbaum can introduce `f U g` into oracle_step even when `f U g not in w`. And `g not in oracle_step` doesn't imply `g not in w`.

**Alternative**: Abandon defect_count decrease for the general oracle and instead prove restricted_fuc DIRECTLY via BX axiom reasoning, bypassing the Hintikka chain machinery entirely.

#### Phase 2: Direct proof of restricted_fuc (Forward Until Coherence)

**Approach**: Given `phi U psi in mcs(t)`:
1. By BX5 (self-accumulation): `(phi /\ (phi U psi)) U psi in mcs(t)`
2. By BX10: `F(psi) in mcs(t)`
3. The oracle chain propagates `phi U psi` forward (it's in the oracle seed as a defect)
4. By oracle step construction: at each step n where `psi not in mcs(t+n)`, `phi U psi in mcs(t+n+1)` (from seed)
5. Also `phi in mcs(t+n)` by BX9 (Until elimination: `phi U psi -> phi \/ psi`, and `psi not in mcs(t+n)` gives `phi`)
6. The oracle resolves `F(psi)` eventually (by the schedule: `psi` is targeted infinitely often, and each time F(psi) in M, the step resolves it)

Wait, step 6 is the problem. The oracle chain (`qm_fwd_chain`) iterates `qm_oracle_step` which propagates ALL defects, but does NOT specifically resolve F-obligations. The scheduling resolution is in `fwd_chain_of_sigma`/`dd_fmcs`, not in `qm_fwd_chain`.

**The oracle chain's purpose is different**: it propagates Until-defects forward and backward. But it does NOT resolve them. Resolution happens via the Hintikka chain `hintikka_chain_exists`, which needs the defect count decrease.

**Revised approach**: Use a HYBRID construction. The main chain uses the scheduling approach (dd_fmcs) for F/P resolution. For Until/Since coherence, use a SEPARATE argument:
- Forward Until: Use the fact that `F(psi) in mcs(t)` is eventually resolved by the scheduling chain, giving `psi in mcs(s)` for some `s > t`. Then the guard follows from BX axiom reasoning.
- Backward Until: Use the enriched backward seed (Section 5.4).

But this is circular: restricted_tc (F resolution) is ALSO sorry'd, and restricted_fuc DEPENDS on restricted_tc.

#### Phase 3: Direct proof of restricted_tc (Temporal Coherence)

**Approach**: The `dd_fmcs` (scheduling chain) already has the machinery for F-resolution via `fwd_succ_resolves`. The problem is that `dd_bfmcs_restricted_tc` is sorry'd.

Looking at `dd_bfmcs_restricted_tc` (RootScopedChain.lean:949-953): it delegates to `dd_bfmcs` which uses `shifted_dd_fmcs`. The `dd_fmcs` uses `fwd_chain_of_sigma` (the BX11-ordered scheduling chain from the earlier sections).

The `fwd_chain_of_sigma` resolves F-obligations using the ordered defect discharge (Section 2 of report 13). Each step resolves the "earliest witness" F-obligation. The proof that F(psi) is eventually resolved requires showing that:
1. F(psi) in mcs(t) implies F(psi) persists until resolved (F-persistence)
2. psi is scheduled infinitely often (schedule_surjective_above)
3. At the scheduled step, if F(psi) still holds, psi enters the chain

**F-persistence**: This is where f_carry enrichment is needed. The `fwd_chain_of_sigma` uses `defect_fwd_step_choice` which resolves the earliest F-defect and carries the remaining F-defects forward (via the `F(chi) in defect_fwd_step_choice` property at line 1481).

Let me check if `defect_fwd_step_choice` provides F-persistence.

From `defect_fwd_step_choice_spec` (line 1472-1482): it provides `F(chi) in M'` for all `chi in defects`. This means ALL F-obligations in the defect list are preserved as F-obligations (not just as formulas).

This is exactly F-persistence! If `F(psi) in mcs(t)` and `psi in defects`, then `F(psi) in mcs(t+1)`. Since defects come from `deferralClosure(root)`, which is finite, and `psi` is scheduled infinitely often, eventually psi is resolved.

So `restricted_tc` for `dd_bfmcs` (the scheduling chain) should be provable using the existing infrastructure. The sorry may be a "haven't gotten to it yet" rather than a fundamental gap.

#### Phase 4: Enriched backward oracle for backward Until

**Target**: New definition `qm_oracle_seed_bwd_enriched` that includes Until-formulas from the successor.

**Implementation**:
```lean
def qm_oracle_seed_bwd_enriched (w : BXPoint) (Sigma : Finset Formula) : Set Formula :=
  h_content w.formulas ∪
  {f | ∃ φ ψ, f = Formula.snce φ ψ ∧ f ∈ w.formulas ∧ ψ ∉ w.formulas ∧ f ∈ Sigma} ∪
  {f | ∃ φ ψ, f = Formula.untl φ ψ ∧ f ∈ w.formulas ∧ f ∈ Sigma}
```

The third component is the key addition: Until-formulas from w (the successor) are included in the backward seed.

**Consistency**: All three components are subsets of `w.formulas`:
- `h_content(w) ⊆ w` by temp_t_past
- Since-defects are in w by definition
- Until-formulas are in w by definition
So the enriched seed is a subset of w, hence consistent.

**Backward Until step transfer**: If `phi U psi in mcs(r+1)` and `phi U psi in Sigma`, then `phi U psi` is in the enriched backward seed for `mcs(r)`. After Lindenbaum extension, `phi U psi in mcs(r)`.

### 7. Priority-Ordered Implementation Plan

1. **[HIGHEST] Prove restricted_tc for dd_bfmcs** using F-persistence from `defect_fwd_step_choice_spec`. This is likely the most tractable sorry to close, as the infrastructure already exists.

2. **[HIGH] Implement enriched backward oracle** (`qm_oracle_seed_bwd_enriched`) and prove backward Until step transfer. This closes restricted_buc.

3. **[HIGH] Prove restricted_fuc** using restricted_tc (from step 1) to find the witness, then the oracle chain Until-propagation for the guard.

4. **[MEDIUM] Close defect_count decrease** in OracleStep.lean. This is needed for the Hintikka chain machinery but may be bypassed if restricted_fuc is proved directly.

### 8. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| F-persistence in dd_fmcs not fully proved | MEDIUM | Infrastructure exists; mainly proof engineering |
| Enriched backward seed changes chain properties | LOW | Consistency trivial; only adds formulas from w |
| restricted_fuc depends on restricted_tc | HIGH | Must close restricted_tc first |
| Defect count decrease genuinely unprovable | HIGH | Bypass via direct algebraic proof of restricted_fuc |
| New defects from enriched backward seed | LOW | Seed is subset of w, so no new inconsistency |

### 9. References

- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes No. 7. Chapters 9-10.
- Burgess, J.P. (1984). Basic tense logic. In *Handbook of Philosophical Logic*, Vol. II. D. Reidel.
- Xu, M. (1988). On some U,S-tense logics. *Journal of Philosophical Logic*, 17, 181-202.
- Reynolds, M. (2010). The complexity of temporal logic over the reals. *Annals of Pure and Applied Logic*, 161(8), 1063-1096.
