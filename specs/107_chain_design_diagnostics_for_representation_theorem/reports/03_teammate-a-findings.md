# Teammate A Findings: Primary Approaches for Chain Design Diagnostics

## Key Findings

### 1. Definitive Dead Ends (Airtight)

Nine approaches have been ruled out with airtight structural arguments. I verified each against the codebase and confirm they are genuinely blocked.

| # | Approach | Structural Reason | Confidence |
|---|----------|-------------------|------------|
| 1 | Omega-squared (discharge + preserve) | F-obligations lost at discharge step because `F(phi) -> G(F(phi))` not derivable; g_content is the sole propagation mechanism | HIGH |
| 2 | Defect-count induction | Lindenbaum extension (Zorn's lemma) creates exogenous defects -- the defect set is not monotonically shrinking | HIGH |
| 3 | bx11_earlier global minimum for N > 2 | bx11_earlier admits 3-cycles (verified: BX11 case 3 composition gives reverse direction); non-transitive | HIGH |
| 4 | Simple seed {phi} + g_content(M) | Resolves target but permanently loses other F-obligations | HIGH |
| 5 | Combined seed {target} + g_content(M) + f_carry(M) | Proven INCONSISTENT (Dead End #13): concrete counterexample with `G(F(alpha) -> NOT target)` in M | HIGH |
| 6 | Backward G contradiction | CIRCULAR: `restricted_temporal_backward_G` at TemporalCoherence.lean:324 requires `h_forward_F` as explicit hypothesis, which IS the statement being proved | HIGH |
| 7 | Until accumulation via BX5/BX6 | Same propagation problem as F -- Until formulas don't propagate through g_content because `(alpha U beta) -> G(alpha U beta)` not derivable | HIGH |
| 8 | Alternative index sets (Q, ordinals, omega^2) | F-propagation obstacle is independent of index structure | HIGH |
| 9 | Round-robin single-target with fwd_succ | F-obligations lost at resolving step (permanently killed by G-formulas entering g_content) | HIGH |

All 9 dead ends are airtight. None have hidden loopholes that were missed.

### 2. NEW Verified Result: Derived Until Guard Theorem

**VERIFIED IN LEAN** (sorry-free): The following MCS-level theorem compiles:

```
theorem F_and_G_to_until {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi psi : Formula)
    (h_F : Formula.some_future phi in M)
    (h_G : Formula.all_future psi in M) :
    Formula.untl psi phi in M
```

**Derivation path** (all steps verified):
1. BX12: `F(phi) -> (T U phi)` gives `(T U phi) in M`
2. prop_s: `psi -> (T -> psi)` (tautology)
3. future_mono: `G(psi) -> G(T -> psi)`
4. BX2 (left_mono_until): `G(T -> psi) -> ((T U phi) -> (psi U phi))`
5. Compose steps 3-4 and apply to get `(psi U phi) in M`

**Significance**: This allows converting `F(phi) + G(psi)` into the Until formula `(psi U phi)`, enriching F-eventualities with G-guards. However, this does NOT solve the propagation problem because the resulting Until formula `(psi U phi)` itself does not propagate through g_content.

### 3. Self-Resolving Step Mechanism

The `self_resolving_fwd_step` (RootScopedChain.lean:1626) provides a critical building block:

Given `F(psi) in M`, it produces `M'` with:
- `psi in M'` (target resolved)
- `F(psi) in M'` (F-obligation preserved)
- `g_content(M) subset M'` (G-propagation maintained)

This works because `F(psi AND F(psi))` is derivable from `F(psi)` (via `F_and_self_F` at line 1610), and `enriched_resolving_seed_consistent` gives `{psi, F(psi)} + g_content(M)` consistent.

**For Until formulas**: If `(alpha U beta) in M`, then `F(alpha U beta) in M` (via phi_imp_F_phi). So we can build `M'` with `(alpha U beta) in M'` AND `F(alpha U beta) in M'` AND `g_content(M) subset M'`. This makes Until formulas self-propagating through the chain -- not via g_content, but via explicit seed inclusion.

### 4. The Core Tension: Resolution vs. Preservation

The fundamental obstruction for `fwd_chain_forward_F` (line 1143) and the 4 associated sorries is:

**Resolution**: To resolve `F(phi)`, we need `phi in M'`. Using `fwd_succ` or `defect_step_from_earliest`, we CAN get `phi in M'`, but this uses a seed that does NOT include other F-obligations.

**Preservation**: To preserve `F(chi)`, we need either `F(chi) in M'` (via enriched seed) or `chi in M'` (directly resolved). The preserving_fwd_step (line 551) preserves ALL F-obligations but gives only DISJUNCTIVE resolution (some w resolved, but we don't control which).

**The BX11 fold** (enriched_fwd_fold, line 162) mediates between these via a three-case disjunction. The `resolving_enriched_fwd_exists` (line 368) guarantees at least one resolution per step while preserving all F-obligations. But the resolution is non-deterministic (controlled by which BX11 case fires), and the SAME formula can be resolved at every step (perpetual deferral of others).

### 5. Assessment of Viable Paths

#### Path 1: BX11 Fold with Fairness Enforcement

**Status**: INCONCLUSIVE -- no progress mechanism found

The enriched_fwd_fold resolves some witness `w` at each step, but `w` can be the same formula at every step. To prove fairness (w must change within bounded steps), we would need:

- **Test needed**: Show that if `w` is the same formula at k consecutive steps, the g_content accumulates formulas that force a DIFFERENT BX11 case at step k+1.
- **Obstacle**: The BX11 cases depend on the full MCS (opaque Lindenbaum extension), not just the sigma-restricted information. The g_content accumulation does constrain future MCSes, but the constraints may not force a case change.
- **Specific diagnostic**: At the sorry site (line 1143), try `lean_multi_attempt` with tactics that exploit g_content monotonicity: if `G(NOT phi)` enters g_content at some step, it persists forever and prevents `phi` from appearing at any future step. This would eliminate `phi` as a possible resolution target, forcing a different target.

**Concrete test**: Can we prove that if `w = phi` at step n and `G(NOT phi') enters g_content(chain(n))` for some other defect `phi'`, then the number of possible resolution targets strictly decreases? This would give well-founded induction on the set of "still-possible targets".

**Confidence**: LOW that this path leads to a complete proof.

#### Path 2: Restructured Chain with Until Tracking + Finite Closure Bound

**Status**: MOST PROMISING -- concrete architecture identified

The key insight chain:

1. Convert all F-defects in sigma to Until defects via BX12: `F(phi) -> (T U phi)`
2. The derived guard theorem (newly verified) enriches guards: `F(phi) + G(psi) -> (psi U phi)`
3. The oracle seed approach (from `qm_oracle_seed` in OracleInstantiation.lean:68) preserves ALL Until defects by including them in the Lindenbaum seed alongside g_content
4. The sigma-signature space is finite (at most `2^|sigma|` distinct signatures)
5. After `2^|sigma|` steps, some sigma-signature must repeat (pigeonhole)
6. A repeating sigma-signature with an unresolved Until defect contradicts BX6 (absorption)

**The critical gap**: Step 6 -- showing that a sigma-signature cycle with unresolved Until defects leads to a BX6 contradiction. The argument sketch:

- If `(alpha U beta)` persists (beta absent) at both occurrences of the repeated signature, then the chain from the first occurrence to the second forms a "cycle" where the guard alpha holds at all intermediate points
- BX5 enriches: `(alpha U beta) -> ((alpha AND (alpha U beta)) U beta)`
- At the second occurrence, the enriched Until `((alpha AND (alpha U beta)) U beta)` holds
- If this Until is in Sigma, it was already present at the first occurrence (same signature)
- This gives `(alpha U (alpha AND (alpha U beta)))` which by BX6 collapses to `(alpha U beta)` -- but this is NOT a contradiction, it's just idempotence

**Problem with the cycle argument**: BX6 collapses `(phi U (phi AND (phi U psi))) -> (phi U psi)`, which is the REVERSE direction. To get a contradiction from a cycle, we need the enriched guard to be DISTINCT from the original, creating a new formula outside Sigma. But if Sigma is closed under BX5 (self-accumulation), the enriched formula IS in Sigma, and the cycle is consistent.

**Revised approach**: Instead of using BX6 for contradiction, use the oracle step's resolution property. At each step, `resolving_enriched_fwd_exists` guarantees some defect is directly resolved. After the resolution, the defect count for THAT formula drops (beta is now present). The Lindenbaum extension might re-introduce the defect, but the sigma-signature constrains which formulas can be present. If the same sigma-signature repeats with one fewer defect, we have progress.

**Concrete diagnostic tests needed**:
1. Verify that `qm_oracle_step` preserves Until defects within Sigma (check `qm_oracle_step_until_in_next` at OracleInstantiation.lean)
2. Test whether sigma-signature equality implies defect count equality (or at least non-increase)
3. Formalize the finite state space argument using `Finset.card_le_card` on sigma-signatures

**Confidence**: MEDIUM-HIGH that this path can work, but the cycle-contradiction step needs careful formalization.

#### Path 3: Derived Until Guard Theorem `(T U phi) AND G(psi) -> (psi U phi)`

**Status**: VERIFIED DERIVABLE -- but insufficient alone

The theorem IS derivable (proven in Lean, zero sorries). However, it only converts F + G combinations into Until formulas. It does not solve the propagation problem because:

- The resulting Until formula `(psi U phi)` needs its own propagation mechanism
- G(psi) in M does propagate to M' (via g_content, since G(G(psi)) = G(psi) by temp_4)
- But the Until formula itself does not propagate unless included in the seed

This result is a **building block** for Path 2, not a standalone solution. It enables enriching Until guards with G-formulas from g_content, which makes the oracle seed approach more powerful.

**Confidence**: HIGH that it's derivable (verified), LOW that it alone solves the problem.

### 6. Quasimodel Approach Assessment

The Quasimodel directory (`Quasimodel/`) is marked OFF-PATH with 2 sorry sites in `OracleInstantiation.lean`:

- **Sorry 1** (line 286): `hintikka_step_bwd_for_sigma_sig` -- Until propagation clause for backward oracle. The backward oracle preserves Since-defects but not Until formulas.
- **Sorry 2** (line 422): `bx_oracle_until` -- defect_count decrease in `BackedStepOracle`. When Lindenbaum doesn't include the goal `psi`, the defect count may not decrease because Lindenbaum can introduce new Until-defects.

**Relationship to main chain**: Both quasimodel sorries face the SAME Lindenbaum non-determinism problem as the main chain's `fwd_chain_forward_F` sorry. The quasimodel approach does NOT bypass the fundamental obstacle -- it encounters it in a different form.

**However**, the quasimodel provides useful infrastructure:
- `bx_until_step` and `bx_F_step` (sorry-free): one-step resolution lemmas at BXPoint level
- `sigma_signature` and `HintikkaPoint`: finite state space infrastructure
- `hintikka_step_for_sigma_sig` (sorry-free): step relation between sigma-signatures

The quasimodel infrastructure could be COMBINED with the main chain's enriched_fwd_fold to provide the finite state space argument needed for Path 2.

**Relationship to Filtration**: The `Filtration/DefectChain.lean` and `SigmaOrdering.lean` provide:
- `sigma_defect_count` bounded by `Sigma.card`
- `sigma_le`, `sigma_strict`, `sigma_equiv` orderings on BXPoints
- Until defect tracking (`is_until_defect`, `defect_step_phi`, `defect_step_F_psi`)

These are the RIGHT tools for the finite state space argument. They are currently unused by the main chain but could be integrated.

## Recommended Approach

**Primary recommendation**: Pursue Path 2 (restructured chain with Until tracking + finite closure bound) using infrastructure from both the main chain and the quasimodel/filtration directories.

### Specific Diagnostic Tests to Plan

#### Test 1: Oracle Seed Until Persistence (HIGH PRIORITY)
**File**: New diagnostic in a scratch file
**Statement**: Given M with `(alpha U beta) in M` and `beta not in M` and `(alpha U beta) in Sigma`, show that `(alpha U beta) in qm_oracle_step(M, Sigma)`.
**Expected result**: Already proven as `qm_oracle_step_until_in_next` (OracleInstantiation.lean). Verify it compiles.
**Purpose**: Confirms the oracle seed preserves Until defects, enabling finite state space argument.

#### Test 2: Sigma-Signature Defect Monotonicity (HIGH PRIORITY)
**Statement**: If `sigma_signature(w, Sigma) = sigma_signature(v, Sigma)` and `v = qm_oracle_step(w, Sigma)`, does `defect_count(sigma_signature(v, Sigma)) <= defect_count(sigma_signature(w, Sigma))`?
**Expected result**: YES if the oracle step resolves at least one defect and doesn't introduce new ones WITHIN Sigma. But Lindenbaum non-determinism may introduce new defects from OUTSIDE Sigma.
**Purpose**: If defect count is non-increasing within a sigma-signature, the cycle argument gives termination.

#### Test 3: Finite State Space Cycling (MEDIUM PRIORITY)
**Statement**: For a chain of BXPoints w0, w1, ..., wN where N > 2^|Sigma|, there exist i < j with `sigma_signature(wi, Sigma) = sigma_signature(wj, Sigma)`.
**Expected result**: Immediate from pigeonhole (Finset.card of HintikkaPoint space).
**Purpose**: Establishes that the chain must cycle in sigma-signature space.

#### Test 4: BX6 Cycle Contradiction (CRITICAL -- MEDIUM PRIORITY)
**Statement**: If the chain visits sigma-signatures s0, s1, ..., sk = s0 (cycle) with an Until defect `(alpha U beta)` unresolved throughout, derive a contradiction from BX5 + BX6.
**Expected result**: UNCLEAR. The BX5 self-accumulation enriches the guard at each step, but BX6 only collapses `(phi U (phi AND (phi U psi))) -> (phi U psi)`, which is the wrong direction for a contradiction. Need to check if the enriched guard at step k MUST differ from the original guard at step 0, and whether this contradicts sigma-signature equality.
**Purpose**: This is the KEY missing piece. If it works, Path 2 is complete.

#### Test 5: Resolution Target Exhaustion (MEDIUM PRIORITY)
**Statement**: In the `resolving_enriched_fwd_exists` construction, if the same witness `w` is resolved at N consecutive steps, do the G-formulas entering g_content eventually exclude ALL other targets?
**Expected result**: UNCLEAR. Each resolution of `w` puts `w in M'`, then `F(w) in M'`, then at the next step the seed again includes `F(w)`, and BX11 may again select `w`.
**Purpose**: If target exhaustion holds, it gives Path 1 (BX11 fairness).

#### Test 6: Backward Chain P-Preservation (LOW PRIORITY)
**Statement**: Build a symmetric `preserving_bwd_step` that preserves P-obligations, analogous to `preserving_fwd_step` for F-obligations.
**Expected result**: Straightforward construction using `past_defect_resolving_seed`.
**Purpose**: Needed for sorries #2 and #3 (backward temporal coherence).

#### Test 7: Until Forward Coherence (LOW PRIORITY -- depends on Test 4)
**Statement**: If `(alpha U beta) in chain(t)`, there exists `s >= t` with `beta in chain(s)` and `alpha in chain(r)` for all `t <= r < s`.
**Expected result**: Depends on resolving the forward_F sorry first, since Until coherence uses F-resolution as a subroutine.
**Purpose**: Addresses sorries #4 and #5.

## Evidence/Examples

### Evidence for Path 2 viability

1. **Oracle seed consistency is proven** (`qm_oracle_seed_consistent`, OracleInstantiation.lean:80-83): The seed `g_content(w) + Until-defects-from-Sigma` is a subset of w.formulas, hence consistent.

2. **Until persistence through oracle step is proven** (`qm_oracle_step_until_in_next`): Until formulas from Sigma persist in the oracle step.

3. **Finite sigma-signature space**: `HintikkaPoint Sigma` has decidable equality (HintikkaPoint.lean:58-64) and lives in `Finset.powerset Sigma`, which has cardinality `2^|Sigma|`.

4. **Defect count bounded** (`sigma_defect_count_bounded`, DefectChain.lean:53-56): At most `Sigma.card` defects at any point.

5. **One-step resolution is sorry-free**: `bx_until_step`, `bx_F_step`, `bx_P_step` (OracleInstantiation.lean:436-457) all compile without sorry.

### Evidence against Path 2 completeness

1. **BX6 cycle contradiction is UNPROVEN**: The critical step of showing that a sigma-signature cycle with unresolved Until defects leads to contradiction has not been formalized.

2. **Lindenbaum non-determinism**: Even within a fixed sigma closure, Lindenbaum can choose different extensions that have the same sigma-signature but different full MCS content, potentially re-introducing defects.

3. **Guard enrichment via BX5 stays within Sigma**: If Sigma is closed under BX5, the enriched guard `(alpha AND (alpha U beta))` is already in Sigma, so BX5 enrichment does not create formulas outside Sigma. This means BX6 absorption may be compatible with the cycle (not a contradiction).

## Confidence Levels

| Finding | Confidence |
|---------|------------|
| All 9 dead ends are truly dead | HIGH |
| Derived Until guard theorem is correct | HIGH (verified in Lean) |
| Self-resolving step mechanism works | HIGH (existing infrastructure, sorry-free) |
| Path 1 (BX11 fairness) can work | LOW |
| Path 2 (Until tracking + finite closure) can work | MEDIUM |
| Path 3 alone is sufficient | LOW |
| Quasimodel bypasses the fundamental obstacle | LOW (faces same obstacle) |
| Quasimodel infrastructure is useful for Path 2 | HIGH |
| BX6 cycle contradiction is achievable | LOW-MEDIUM (key unknown) |
| Forward_F is provable with current axiom system | MEDIUM (no structural impossibility found, but no proof found either) |

## Summary

The 5 sorry sites in RootScopedChain.lean all trace to a single root cause: the inability to propagate F-obligations (and equivalently, Until obligations) through the g_content mechanism. All 9 previously identified approaches that attempted to work around this limitation are confirmed dead.

The most promising path forward is Path 2: restructuring the chain to use the oracle seed approach (g_content + Until defects from Sigma), combined with a finite state space argument using sigma-signatures. The derived Until guard theorem (newly verified) provides an additional tool for this approach.

The CRITICAL unknown is whether a sigma-signature cycle with unresolved Until defects can be shown to be contradictory. This is Test 4 above and should be the primary focus of any implementation phase. If it fails, the project may need to consider whether the BX axiom system is strong enough for the completeness proof, or whether an additional derived principle is needed.
