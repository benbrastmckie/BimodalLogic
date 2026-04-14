# Teammate D Findings: Strategic Horizons

**Task**: 93 - Close BXCanonical embedding
**Focus**: Long-term mathematical strategy, literature review, Lean 4 formalization patterns
**Date**: 2026-04-14

## 1. Key Findings

### 1.1 What the Literature Says

The completeness proof for linear temporal logic with Until/Since over the Burgess-Xu axiom system follows a well-known pattern in the literature:

**Burgess (1984) "Basic Tense Logic"**: Introduces the constructive method for building canonical models for tense logics. The canonical model consists of MCS chains connected by g_content/h_content inclusion. For Until eventualities, Burgess uses a **finite stage-by-stage construction** where F-defects are resolved one at a time. The critical insight is that temporal linearity (BX11) orders the witnesses, enabling sequential resolution.

**Xu (1988) "On some U,S-tense logics"**: Simplifies Burgess's completeness proof. The Xu simplification streamlines the Until-defect discharge by leveraging the axiom `phi U psi -> phi v psi` (BX9) and `phi U psi -> F(psi)` (BX10) to reduce Until-defects to F-defects, then discharging F-defects in witness-earliest-first order.

**Goldblatt (1992) "Logics of Time and Computation"**: Provides the standard textbook treatment. For discrete temporal models, builds an omega-chain of MCS where each step resolves one eventuality. The construction is finite (bounded by the number of subformulas). The identity tail technique (constant chain after all defects are resolved) handles the infinite extension.

**Verbrugge, de Jongh, Veltman (mid-1980s, published as "Completeness by construction for tense logics of linear time")**: Develops the Amsterdam "constructive method" for building temporal models stage-by-stage. This approach was widely used for proving completeness of many tense logics, including those with Until.

**Common pattern across all sources**: The standard approach is:
1. Start with an MCS M_0 containing the target formula
2. Enumerate the finite set of F-defects (formulas F(psi) in M_0 with psi not in M_0)
3. Resolve them one at a time, using temporal linearity to order the resolution
4. After finitely many steps, reach a defect-free MCS
5. Extend with an identity tail (or periodic tail for infinite models)

This is EXACTLY the approach described in Report 13 (Section 2.4). The project is not reinventing anything badly -- it has converged on the standard textbook solution. The problem is purely in the Lean formalization details.

### 1.2 The Current Code Has Two Parallel Chain Constructions

The codebase contains TWO chain constructions:

**A. The old `int_chain` / `bx_fmcs` (CanonicalModel.lean)**:
- Simple scheduling chain with `fwd_succ` / `bwd_pred`
- 6 sorry sites (lines 518, 525, 614, 619, 649, 655)
- Documented as DEAD CODE for the unrestricted coherence properties
- The restricted variants (lines 631-655) are on the active path but delegate to the same sorry'd `bx_fmcs_forward_F`

**B. The new `dd_chain` / `dd_fmcs` (RootScopedChain.lean)**:
- Uses `enriched_fwd_step` with BX11 fold protection
- 6 sorry sites (lines 790, 816, 823, 876, 881, 886)
- Designed to replace A, wired into `dd_countermodel` at the bottom of the file
- `Completeness.lean` uses `dd_countermodel`, so this IS the active path

The old construction (A) is no longer on the active completeness path. `Completeness.lean` calls `dd_countermodel` from RootScopedChain.lean, not `bx_countermodel` from CanonicalModel.lean.

### 1.3 The Enriched Chain Does Not Solve forward_F

As documented in handoff 15, the current enriched chain (`enriched_fwd_step` using `enriched_fwd_exists`) cannot prove `rr_fwd_chain_forward_F` because:

- `enriched_fwd_exists` returns `target in M' OR F(target) in M'` (a disjunction)
- BX11 case 3 can always F-wrap the target, so target in M' is not guaranteed
- The set of F-formulas is STABLE (preserved at every step), so no decreasing measure exists
- The defect count does NOT decrease

This is a fundamental limitation of the BX11 fold approach. The fold protects all F-formulas but cannot force resolution of any specific one.

### 1.4 The Ordered Defect-Discharge Chain Is the Correct Solution

The Report 13 approach (ordered defect-discharge) is correct and matches the standard literature. The key tool is `enriched_resolving_seed_consistent` from OrderedSeedConsistency.lean (already proved, 0 sorry). This gives:

> If F(psi and alpha) in M, then {psi, alpha} union g_content(M) is consistent.

Combined with `temp_linearity_mcs` (BX11 at MCS level, also proved), this enables:
1. Finding the earliest-witness formula among F-defects
2. Building a seed that GUARANTEES target resolution (not disjunctive)
3. Strict decrease of defect count

### 1.5 Step Transfer for Backward Until Is Genuinely Hard

The backward Until coherence (`restricted_buc`) requires a "step transfer":
```
(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)
```

Report 13 discusses this at length (Section 2.5, Sorry 5) and the analysis in lines 186-301 reveals significant difficulty. The step transfer is semantically valid but syntactically challenging because:

- `neg(phi U psi)` in chain(r) does not propagate forward via g_content
- Until formulas cannot be included in the resolving seed without risking inconsistency (since the defect target psi_j is not in chain(r), neg(psi_j) IS in chain(r))
- The h_content backward propagation gives `H(alpha) in chain(r+1) -> alpha in chain(r)` but Until is not an H-formula

**However**, there is a cleaner path via the FMCS eventuality resolution infrastructure. From `CanonicalChain.lean`, the delegation bridges (`delegation_until_eventuality`, `delegation_since_eventuality`) are already proved. These show that from `(phi U psi) in w` with `psi not in w`, there exists a BXPoint `v` with `bx_le w v` and `psi in v`. The restricted_buc and restricted_fuc might be closeable by leveraging this existing eventuality resolution infrastructure rather than proving step transfer from scratch.

### 1.6 Task 92 Is Completed

Task 92 (truth lemma) is not in TODO.md and not in state.json, indicating it was completed and archived. The truth lemma infrastructure in `TruthLemma.lean` is on the active path and connects to `Completeness.lean`. No blockers from task 92.

### 1.7 Task 95 Needs Only `#print axioms bx_completeness`

Task 95 is a verification audit: run `#print axioms bx_completeness` and verify it shows only `propext`, `Classical.choice`, `Quot.sound`. This is achievable once all sorry sites are closed. The current approach using `dd_countermodel` is compatible with this goal since it uses only standard Lean axioms and classical logic.

## 2. Recommended Approach

### 2.1 Replace `enriched_fwd_step` with an Ordered Defect-Discharge Step

The current `enriched_fwd_step` using `enriched_fwd_exists` (BX11 fold) must be replaced with a step that uses `enriched_resolving_seed_consistent` directly. The replacement:

```
ordered_discharge_step M sigma_list :=
  let defects = [psi in sigma_list | F(psi) in M, psi not in M]
  if defects is empty:
    M  -- identity (defect-free)
  else:
    let j = find_earliest_witness(defects, M)  -- via iterated BX11
    -- Build compound of remaining F-defects
    let alpha = conjunction of {F(psi_k) | k != j, F(psi_k) in M}
    -- Seed: {psi_j, alpha} union g_content(M)
    -- Consistent by enriched_resolving_seed_consistent (since F(psi_j and alpha) in M)
    Lindenbaum({psi_j, alpha} union g_content(M))
```

Key properties:
- `psi_j IN M'` (guaranteed, not disjunctive)
- `F(psi_k) in M'` for k != j (from alpha extraction)
- g_content propagation maintained
- Defect count STRICTLY decreases (psi_j is no longer a defect)

### 2.2 Use `Fin n` or `Nat` with Explicit Bound, Not Well-Founded Recursion

For the Lean formalization of the finite defect-discharge chain:

**Recommended pattern**: Use `Nat.rec` with an explicit step count bound. Define:

```lean
noncomputable def discharge_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma : Finset Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := discharge_chain M₀ h₀ sigma n
    ⟨ordered_discharge_step M hM sigma, ...⟩
```

Then prove:
1. `sigma_defect_count (discharge_chain ... n) sigma` is non-increasing
2. At each non-identity step, defect count strictly decreases
3. After at most `sigma.card` steps, defect count = 0
4. After defect count = 0, all steps are identity (chain is constant)

**Why not well-founded recursion**: Well-founded recursion in Lean 4 is feasible but creates more complex proof obligations. The termination proof requires showing the measure decreases at EACH recursive call, which means inlining the defect-decrease proof. With `Nat.rec` on an explicit bound (sigma.card), the termination is structural, and the defect-decrease is proved as a SEPARATE theorem.

**Mathlib pattern**: `Function.iterate f n a` (notation `f^[n] a`) from `Mathlib.Logic.Function.Iterate` provides simple properties like `f^[0] a = a`, `f^[n+1] a = f (f^[n] a)`, `f^[m+n] a = f^[m] (f^[n] a)`. This could simplify the chain definition.

### 2.3 Handle Backward Until via Forward Eventuality Resolution

Rather than proving the step transfer `(phi U psi) in chain(r+1), phi in chain(r) -> (phi U psi) in chain(r)`, use the forward eventuality resolution infrastructure.

For `restricted_forward_until_since_coherent`: If `(phi U psi) in chain(t)` and `psi not in chain(t)`:
- By BX10: `F(psi) in chain(t)`
- By `forward_F`: `psi in chain(s)` for some `s > t`
- By BX9 (until_elim): at each step r in [t, s), `(phi U psi) in chain(r)` and `psi not in chain(r)` gives `phi in chain(r)`
- So the witness s and guard phi on [t, s) exist. This gives the forward Until witness.

For `restricted_backward_until_since_coherent`: Given the witness pattern (psi at s, phi on [t,s)), derive `(phi U psi) in chain(t)`:
- If s = t: BX8 (refl_intro_until) gives `(phi U psi) in chain(t)` from `psi in chain(t)`
- If s > t: Need backward induction. Instead of step transfer, use the **parametric backward_until_from_step** from `UntilSinceCoherence.lean` (line 111), which requires providing the step hypothesis.

The step transfer IS provable for the ordered defect-discharge chain, but requires careful argument:
- From `(phi U psi) in chain(r+1)`: by BX4 connect_future, `G(P(phi U psi)) in chain(r+1)`
- This gives `P(phi U psi) in chain(r)` via g_content backward propagation... but this requires `H(P(phi U psi)) in chain(r+1)`, not `G(P(phi U psi))`.

Actually, the cleaner path: use `BX4'` (connect_past): `alpha -> H(F(alpha))`. So `(phi U psi) in chain(r+1)` gives `H(F(phi U psi)) in chain(r+1)`. By h_content: `F(phi U psi) in chain(r)`. By forward_F: `(phi U psi) in chain(s)` for some `s > r`. But we need it at `r`, not later.

**The cleanest solution for backward Until**: Prove the step transfer by including `u_carry` (defective Until formulas) in the seed. Since defective Until formulas are in chain(r) and g_content(chain(r)) is in the seed, and Until formulas from chain(r) are consistent with g_content(chain(r)) (both are subsets of chain(r)), the key question is whether they're consistent with the target psi_j.

Actually, the ordered seed consistency theorem can be extended: `{psi_j} union g_content(M) union {Until formulas from M}` is consistent if all the Until formulas are already in M (since they're derivable from M's axioms). The proof: `{psi_j} union subset_of_M` is consistent iff `neg(psi_j) not derivable from subset_of_M`. Since `subset_of_M subset M` and M is consistent, and F(psi_j) in M means G(neg(psi_j)) not in M... but neg(psi_j) might be derivable from a subset of M not including G(neg(psi_j)).

**This requires more careful analysis.** I believe the cleanest path is:

1. Build the discharge chain using ONLY g_content + F-protection in the seed (no Until carry)
2. Prove forward_F using defect discharge
3. Prove forward_until using forward_F + BX9 + BX10
4. Prove backward_until by converting the semantic witness pattern to a syntactic argument using BX5 (self-accumulation) + BX6 (absorption) + the fact that phi holds at each intermediate step

For step 4, the inductive argument from chain(s) back to chain(t):
- Base: s = t, use BX8
- Step: Assume `(phi U psi) in chain(r+1)`. We have `phi in chain(r)`. By inductive hypothesis, `(phi U psi) in chain(r+1)`.

  To get `(phi U psi) in chain(r)`:
  - `psi in chain(r)` => done by BX8
  - `psi not in chain(r)` => We need to show `(phi U psi) in chain(r)`. Since `phi in chain(r)` and `(phi U psi) in chain(r+1)`, and the chain has g_content(chain(r)) subset chain(r+1), we can use: from `(phi U psi) in chain(r+1)`, extract `F(psi) in chain(r+1)` (by BX10). Since g_content propagates, `G(phi) in chain(r)` implies `phi in chain(r+1)`. But we need the REVERSE direction.

  **I believe the step transfer requires a separate helper lemma that is NOT obvious.** This is a genuine open problem in the formalization that may require additional chain structure.

### 2.4 Scrapping vs. Preserving Existing Code

**Preserve**:
- `OrderedSeedConsistency.lean` (0 sorry, essential)
- `FF_imp_F`, `F_mono`, `F_conj_left_mcs`, `F_conj_right_mcs` in RootScopedChain.lean (proved, essential for any approach)
- `enriched_fwd_fold` + `enriched_fwd_exists` (proved, useful even if not directly used for forward_F -- they demonstrate the BX11 fold technique)
- `modal_fix` and box stability infrastructure (proved, needed for any chain)
- `dd_chain`, `dd_fmcs`, `dd_bfmcs` structure (correct overall architecture)
- All chain propagation lemmas (g_content, h_content, box stability)

**Replace**:
- `enriched_fwd_step` -- replace with `ordered_discharge_step` that guarantees target resolution
- `rr_fwd_chain` -- replace with `discharge_fwd_chain` using the new step
- The round-robin scheduling logic (`rrSchedule`) -- replace with earliest-witness ordering

**Keep as dead code / documentation**:
- The extensive comments in RootScopedChain.lean explaining why various approaches fail (lines 325-391, 700-783) -- these document the mathematical reasoning and prevent future re-exploration of dead ends

### 2.5 Definition of Done and Verification

The plan says `#print axioms bx_completeness` should show only `propext`, `Classical.choice`, `Quot.sound`. This is achievable because:

- The current proof uses `Classical` (from `open Classical`), which resolves to `Classical.choice`
- `propext` and `Quot.sound` are standard Lean kernel axioms
- No custom axioms are used (the codebase has 0 custom axioms per TODO.md)
- `sorry` would show as an additional axiom, so closing all 6 sorry sites eliminates it

**Lean 4 gotcha**: `sorry` in Lean 4 introduces the axiom `sorryAx` which propagates through all definitions that depend on the sorry'd theorem. Even indirect dependencies (e.g., a theorem that calls another theorem that uses sorry) will show `sorryAx` in `#print axioms`. So ALL 6 sorry sites must be closed for the verification to pass.

**No hidden sorry leakage**: `lean_verify` (from the MCP server) can check this. Run `lean_verify bx_completeness` to verify the axioms.

## 3. Evidence and Examples

### 3.1 The Standard Textbook Construction (Goldblatt-Style)

The standard construction from Goldblatt 1992, adapted to our setting:

```
Given: MCS M_0, finite Sigma = extendedDeferralClosure(root)
Goal: Build chain M_0, M_1, ..., M_N, M_N, M_N, ... (identity tail)

Step: Given M_i with F-defects D_i = {psi in Sigma | F(psi) in M_i, psi not in M_i}
  1. If D_i = empty: STOP, set N = i
  2. Use BX11 iteratively on pairs in D_i to find psi_j with earliest witness
  3. Build compound alpha = conjunction of {F(psi_k) | k in D_i, k != j}
  4. BX11 gives: F(psi_j and alpha) in M_i
  5. By enriched_resolving_seed_consistent: {psi_j, alpha} union g_content(M_i) consistent
  6. Lindenbaum extend to M_{i+1}
  7. psi_j in M_{i+1} (from seed). F(psi_k) in M_{i+1} for k != j (from alpha).
  8. |D_{i+1}| < |D_i| (psi_j resolved, no new defects by no_new_f_defects)
  9. After at most |Sigma| steps, D_N = empty
```

### 3.2 Lean 4 Pattern for Finite Iteration with Bound

```lean
-- Define the step function
noncomputable def step (M : Set Formula) (h : SetMaximalConsistent M) (sigma : Finset Formula) :
    { M' : Set Formula // SetMaximalConsistent M' } := ...

-- Define the chain by iterating the step
noncomputable def chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma : Finset Formula) : (n : Nat) -> { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 => let ⟨M, hM⟩ := chain M₀ h₀ sigma n; step M hM sigma

-- Prove defect count decreases
theorem defect_decreases (M₀ : ...) (sigma : ...) (n : Nat) :
    sigma_defect_count (chain M₀ h₀ sigma (n+1)).val sigma ≤
    sigma_defect_count (chain M₀ h₀ sigma n).val sigma := ...

-- Prove defect count reaches zero within sigma.card steps
theorem defects_exhausted (M₀ : ...) (sigma : ...) :
    sigma_defect_count (chain M₀ h₀ sigma sigma.card).val sigma = 0 := ...

-- Forward_F: F(psi) in chain(n) -> exists s > n, psi in chain(s)
-- Proof: psi is a defect. Within sigma.card steps, it must be resolved.
-- After sigma.card steps, chain is identity (defect-free). F(psi) -> psi.
```

## 4. Confidence Level

**Overall confidence: HIGH** (90%) that the ordered defect-discharge approach is correct and formalizable.

**Specific confidence levels**:

| Component | Confidence | Notes |
|-----------|------------|-------|
| forward_F via defect discharge | 95% | Standard textbook construction, OrderedSeedConsistency already proved |
| backward_P (symmetric) | 95% | Mirror of forward_F |
| restricted_tc (temporal coherence) | 90% | Depends on forward_F + backward_P |
| restricted_fuc (forward Until) | 85% | Depends on forward_F + BX9 + BX10 |
| restricted_buc (backward Until) | 60% | Step transfer is genuinely hard; may need chain modification |
| restricted_buc (backward Since) | 60% | Symmetric to Until case |
| Lean 4 formalization | 80% | Nat.rec pattern is clean, but proof details may be tricky |

**The backward Until/Since coherence is the highest risk.** The step transfer problem is a known hard point in the literature and in this formalization. If the step transfer cannot be proved for the ordered discharge chain, the chain construction may need to be modified to include Until-carry in the seed, which requires additional consistency arguments.

**Estimated effort**: 8-16 hours for a skilled Lean developer, with the step transfer being the main risk factor. If the step transfer proves tractable, closer to 8 hours. If it requires chain modification, closer to 16.

## 5. Specific Recommendations for Next Implementation Attempt

1. **Do NOT modify `enriched_fwd_exists` or `enriched_fwd_fold`**. They are correct and proved. Leave them as-is.

2. **Create a NEW step function** `ordered_discharge_step` that uses `enriched_resolving_seed_consistent` + `find_earliest_witness`. This is a separate function, not a modification of the existing one.

3. **Build `discharge_fwd_chain`** using `Nat.rec` with `ordered_discharge_step`. Prove defect-decrease and defect-exhaustion as separate lemmas.

4. **Wire `discharge_fwd_chain` into `dd_chain`** by replacing `rr_fwd_chain` in the definition.

5. **Prove forward_F** for the new chain. This should follow directly from defect-exhaustion + identity-tail properties.

6. **Tackle backward Until LAST**. It's the hardest piece and may require additional chain infrastructure. Attack it only after forward_F and forward_until are closed.

7. **Consider H(F(phi U psi)) propagation** for backward Until: `(phi U psi) in chain(r+1)` gives `H(F(phi U psi)) in chain(r+1)` by BX4'. By h_content: `F(phi U psi) in chain(r)`. By forward_F: `(phi U psi) in chain(s)` for some `s > r`. But this gives a LATER witness, not `(phi U psi) in chain(r)`. The step transfer remains the critical gap.
