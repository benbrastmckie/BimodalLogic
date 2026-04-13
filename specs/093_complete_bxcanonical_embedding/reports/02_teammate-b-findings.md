# Teammate B: Alternative Approaches

## Key Findings

1. **Strategy A (Direct BXPoint TaskModel) is viable and potentially simpler** than bridging to parametric infrastructure, but only when combined with the Int guard-interval simplification.
2. **The Boneyard contains three generations of failed completeness attempts**, all blocked by the same fundamental issue: propagating Until obligations through chain steps. The BXCanonical approach already resolves the hardest part (eventuality resolution) that killed earlier approaches.
3. **Strategy C (minimal/restricted approach) has a concrete existing implementation** in `RestrictedTruthLemma.lean` (Boneyard/StrictSemanticsLegacy) but it proves equivalence at the DRM level, not at the semantic `truth_at` level -- the final bridge to `valid` is still missing.
4. **The Int guard-interval trick is the single most important simplification** for any approach: for `D = Int`, placing Until witnesses at `t + 1` makes the guard interval contain only the single point `t`, which is trivially handled.
5. **A hybrid "Direct BXPoint Frame + Int guard trick" approach may be the shortest path** at approximately 300-400 lines, avoiding the BFMCS machinery entirely.

## Strategy A Re-evaluation

### Direct Construction Sketch

Build a `TaskFrame Int` and `TaskModel` directly from BXPoints:

```
WorldState = BXPoint
task_rel w d v :=
  if d > 0 then bx_le w v
  else if d = 0 then w = v
  else bx_le v w
valuation w p := atom p ∈ w.formulas
```

**TaskFrame axioms verification**:

1. **nullity_identity**: `task_rel w 0 v ↔ w = v` -- by definition (d = 0 case).
2. **forward_comp**: If `0 ≤ x`, `0 ≤ y`, `task_rel w x u`, `task_rel u y v`, then `task_rel w (x+y) v`. Cases:
   - x > 0, y > 0: `bx_le w u` and `bx_le u v`, need `bx_le w v`. This is `bx_le_trans` (proved in Frame.lean:153).
   - x = 0, y ≥ 0: w = u, substitute.
   - x ≥ 0, y = 0: u = v, substitute.
3. **converse**: `task_rel w d v ↔ task_rel v (-d) w`. If d > 0 then -d < 0, so LHS = `bx_le w v`, RHS = `bx_le w v`. If d = 0, both sides give w = v (using v = w ↔ w = v). If d < 0, mirror.

This is structurally identical to `ParametricCanonicalTaskFrame` but with `BXPoint` instead of `ParametricCanonicalWorldState`. The construction is straightforward because `BXPoint` and `ParametricCanonicalWorldState` are isomorphic (both wrap `SetMaximalConsistent`).

### What Strategy A avoids

- **No BFMCS needed**: We build histories directly from BXPoint chains.
- **No FMCS needed**: We don't need the full FMCS structure with forward_G/backward_H fields.
- **No modal saturation**: The `valid` definition quantifies over ALL Omega and ALL histories in Omega. We only need ONE specific history where phi fails.

### What Strategy A still requires

1. **A history function**: `τ : Int → BXPoint` such that `bx_le (τ t) (τ (t+1))` for all t.
2. **Shift-closed Omega**: A set of histories containing τ and all its shifts.
3. **Truth lemma**: `truth_at M Omega τ t ψ ↔ ψ ∈ (τ t).formulas` for all ψ.

The truth lemma is the hard part, but items 1-2 are much simpler than BFMCS construction.

### Critical advantage: the truth lemma is already mostly proved

The BXCanonical TruthLemma.lean already proves the MCS-level truth properties:
- `G_iff_mcs`: G(φ) ∈ w ↔ ∀ v, bx_le w v → φ ∈ v
- `H_iff_mcs`: H(φ) ∈ w ↔ ∀ v, bx_le v w → φ ∈ v
- `box_iff_mcs`: □(φ) ∈ w ↔ ∀ v, bx_modal_equiv w v → φ ∈ v
- `until_forward_mcs`: (φ U ψ) ∈ w → ψ ∈ w ∨ (∃ v, bx_le w v ∧ ψ ∈ v ∧ φ ∈ w)
- `until_backward_refl_mcs`: ψ ∈ w → (φ U ψ) ∈ w

The gap is connecting these MCS-level properties to `truth_at` along a specific history.

## Existing Completeness Patterns (Boneyard Analysis)

### Generation 1: SuccChain (Boneyard/ChainCompleteness)

**Approach**: Build a deterministic successor chain from a single MCS.

**Files**: `SuccChainFMCS.lean`, `SuccChainCompleteness.lean`, `SuccChainTruth.lean`, `SimplifiedChain.lean`

**What worked**:
- Forward chain construction via `successor_exists` / `predecessor_exists`
- G-propagation through chains (`forward_G` for FMCS)
- Basic truth lemma structure

**What failed**:
- `forward_F` / `backward_P`: The chain is deterministic -- it picks ONE successor at each step. There is no guarantee that every F-obligation is eventually resolved. The `f_nesting_is_bounded` assumption is mathematically false for arbitrary MCS.
- Box backward: Singleton Omega (one history) cannot satisfy Box backward without modal saturation.

**Lesson**: Deterministic chains cannot resolve all eventuality obligations.

### Generation 2: Dovetailed Chain (Boneyard/StrictSemanticsLegacy/Algebraic)

**Approach**: Fair-scheduling chain using `Nat.unpair` and `Denumerable Formula` to dovetail F/P obligation resolution.

**Files**: `DovetailedChain.lean` (900+ lines)

**What worked**:
- Fair scheduling mechanism via `Nat.unpair`
- Forward/backward chain construction with G/H propagation

**What failed** (6 sorries, all same root cause):
- **X-vs-G mismatch**: Until obligations produce `⊥ U ψ` formulas via `until_unfold`, but chain steps preserve `g_content` (G-level formulas). The `⊥ U` formula is not G-liftable, so it cannot propagate through chain steps. This blocks all Until/Since coherence.

**Lesson**: Under strict semantics, Until and G operate at different formula levels, making chain propagation impossible.

### Generation 3: UltrafilterChain + Bundle (Boneyard/StrictSemanticsLegacy)

**Approach**: Build BFMCS_Bundle with modal saturation, then wire to parametric truth lemma.

**Files**: `UltrafilterChain.lean`, `CanonicalConstruction.lean`, `FrameConditions/Completeness.lean`

**What worked**:
- Bundle-level temporal coherence (F/P witnesses exist in SOME family)
- Modal saturation (Diamond witnesses get their own families)
- Conversion from BFMCS_Bundle to BFMCS

**What failed**:
- **Bundle vs. family coherence gap**: The truth lemma requires F/P witnesses in the SAME family (same history). Bundle-level coherence allows witnesses in DIFFERENT families (different histories). The sorry in `bfmcs_from_mcs_temporally_coherent` exists precisely because of this gap.

**Lesson**: Modal logic (Box/Diamond) needs multiple histories (bundle); temporal logic (G/H/F/P) needs coherence WITHIN a single history (family). These pull in opposite directions.

### Generation 4: Restricted Chain (Boneyard/StrictSemanticsLegacy)

**Approach**: Restrict to subformulas of the target formula phi, where obligation sets are finite and bounded.

**Files**: `RestrictedTruthLemma.lean`, `SuccChainFMCS.lean` (RestrictedTemporallyCoherentFamily), `SimplifiedChain.lean`

**What worked**:
- `restricted_truth_lemma`: DRM membership ↔ Lindenbaum extension membership for subformula closure formulas
- `neg_consistent_gives_mcs_without_phi`: Construction of MCS not containing phi

**What failed**:
- The bridge from "phi not in extended MCS" to "phi false in a semantic model" is never completed. The restricted truth lemma operates at the DRM/MCS level, not at the `truth_at` level.
- The `forward_F` for simplified chains still has a sorry because Lindenbaum extensions can perpetually defer F-obligations.

**Lesson**: Restriction helps with termination but does not fix the fundamental chain propagation issue.

### What BXCanonical already solves

The BXCanonical approach (current, non-Boneyard) resolves the hardest problem that killed all four Boneyard generations:

- **Eventuality resolution is proved**: `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` in Frame.lean are sorry-free. These use BX9 (until_elim) + BX10 (until_F) + bx_forward_witness to resolve Until eventualities.
- **No X-vs-G mismatch**: BXCanonical uses reflexive semantics (BX1: G(φ) → φ), so G-content propagation suffices.
- **No chain propagation needed**: The witnesses are produced independently via Lindenbaum, not propagated through chains.

The remaining gap is purely structural: packaging BXPoint witnesses into a TaskModel and proving the truth lemma at the `truth_at` level.

## Minimal/Restricted Approach Assessment

### What `restricted_forward_until_since_coherent` provides

Defined in `TemporalCoherence.lean:535`:

```lean
def BFMCS.restricted_forward_until_since_coherent (B : BFMCS D) (root : Formula) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.untl φ ψ ∈ subformulaClosure root →
      Formula.untl φ ψ ∈ fam.mcs t →
      ∃ s : D, t ≤ s ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, t ≤ r → r < s → φ ∈ fam.mcs r)
```

This restricts forward coherence to Until/Since formulas in `subformulaClosure(root)`. The theorem `forward_implies_restricted_forward` shows full coherence implies restricted coherence.

### Could a restricted truth lemma suffice?

The parametric truth lemma (`parametric_canonical_truth_lemma`) requires THREE coherence hypotheses:
- `h_tc : B.temporally_coherent` (forward_F / backward_P for ALL formulas)
- `h_buc : B.backward_until_since_coherent` (backward Until/Since for ALL formulas)
- `h_fuc : B.forward_until_since_coherent` (forward Until/Since for ALL formulas)

A restricted version would weaken `h_fuc` to `restricted_forward_until_since_coherent root`. However, `h_tc` (forward_F / backward_P) is used in the backward G/H cases and is NOT restricted -- it requires coherence for ALL formulas, not just subformulas.

**Assessment**: A restricted approach could weaken the Until/Since obligation but cannot weaken the temporal (F/P) obligation. The F/P coherence is the harder part (it's what killed the SuccChain approach).

### The "only need to falsify phi" angle

For completeness, we only need to show: given MCS M with ¬φ ∈ M, construct a model where φ is false.

The `valid` definition quantifies over ALL D, ALL frames, ALL models, ALL Omega, ALL histories, ALL times. So to show φ is not valid, we need to exhibit ONE specific (D, Frame, Model, Omega, τ, t) where φ is false.

This means we can choose D = Int, build a simple frame, and only need the truth lemma to work at ONE point for ONE formula. But the truth lemma proof is by structural induction, so it necessarily proves the result for ALL subformulas simultaneously.

**Verdict**: The "minimal proof" angle provides no significant simplification over Strategy B, because the truth lemma's structural induction forces us to handle all cases anyway.

## Dense-Time Prior Art

### Goldblatt's approach (1992)

Goldblatt's completeness proof for tense logic over dense time uses:
1. Build an omega-chain of MCS with dovetailed obligation resolution
2. The chain is indexed by rationals (or a countable dense order)
3. Until obligations are resolved by inserting witnesses between existing chain points

The key difference from the current codebase: Goldblatt works with STRICT semantics (G quantifies over strict future), while BXCanonical uses REFLEXIVE semantics. Under reflexive semantics, the guard interval for Until is `[t, s)` which allows `s = t` (reflexive witness), making the base case trivial via BX8.

### Reynolds' approach (2003)

Reynolds' completeness for Until over dense linear time uses:
1. A filtration-like construction restricted to subformulas
2. Defect-discharge chains (same idea as Quasimodel/Construction.lean)
3. A key "continuity" argument: if φ U ψ holds at t, there is a LEAST s ≥ t with ψ at s

The codebase already implements Reynolds' defect-discharge in the Quasimodel/Construction.lean and Filtration/DefectChain.lean modules. The `defect_count` termination measure and `hintikka_step` relation are direct implementations.

### Applicability to the current sorry

The dense-time approaches are **not needed** for the BXCanonical completeness proof. The BXCanonical proof uses `valid` which quantifies over ALL D, so we can instantiate with D = Int. Dense time would be needed for `valid_dense` which restricts to dense D.

For the current sorry, the Int instantiation is strictly easier because:
- Guard intervals for Until are finite (or empty) for adjacent integer times
- No density axiom is needed
- The chain construction is simpler (no interleaving between rational points)

## Hybrid Possibilities

### Hybrid A: Direct BXPoint Frame + Parametric Truth Lemma

**Idea**: Build the TaskFrame directly from BXPoints (Strategy A), but reuse the parametric truth lemma by showing the BXPoint frame IS the parametric frame under a trivial isomorphism.

**Viability**: High. `BXPoint` and `ParametricCanonicalWorldState` are structurally identical:
```
BXPoint = { formulas : Set Formula, is_mcs : SetMaximalConsistent formulas }
ParametricCanonicalWorldState = { M : Set Formula // SetMaximalConsistent M }
```

A simple coercion `bxpoint_to_pcws w = ⟨w.formulas, w.is_mcs⟩` bridges them. The task relations are also identical: both use `g_content` inclusion for positive durations.

**Remaining work**: Build a BFMCS from the starting MCS M, which is exactly what Strategy B requires. This hybrid collapses to Strategy B.

### Hybrid B: Direct Frame + Direct Truth Lemma (NO BFMCS)

**Idea**: Skip the BFMCS/FMCS machinery entirely. Build a TaskFrame directly from BXPoints, construct histories as BXPoint chains, and prove the truth lemma directly using the MCS-level properties in TruthLemma.lean.

**Viability**: This is the most promising hybrid. The key insight:

For `D = Int`, we need:
1. A history `τ : Int → BXPoint` with `bx_le (τ t) (τ (t+1))` for all t
2. Omega containing τ and all shifts, shift-closed
3. Truth lemma: `truth_at M Omega τ t ψ ↔ ψ ∈ (τ t).formulas`

The truth lemma proof by induction on ψ:
- **atom**: By valuation definition
- **bot**: Both sides False
- **imp**: MCS closure + both IH directions
- **box**: Need ∀ τ' ∈ Omega, bx_modal_equiv (τ t) (τ' t) → ... This requires Omega to contain enough histories for all modal witnesses. This is the Box case that killed the SuccChain approach.
- **G**: Forward by bx_le chain + forward_G. Backward needs forward_F in the chain.
- **H**: Mirror of G.
- **Until**: Forward by eventuality resolution. Backward needs guard interval.
- **Since**: Mirror of Until.

**The Box problem**: The Box backward case requires that for any formula ◇ψ ∈ (τ t).formulas, there exists τ' ∈ Omega with bx_modal_equiv (τ t) (τ' t) and ψ ∈ (τ' t).formulas. This requires modal saturation of Omega, which is essentially what BFMCS provides.

**Workaround for Box**: Use the ParametricCanonicalTaskFrame with its full Omega (containing ALL BFMCS families). We only need to construct ONE BFMCS.

**Conclusion**: Hybrid B collapses to Strategy B for the Box case. There is no way to avoid BFMCS without avoiding Box.

### Hybrid C: BXPoint chain for temporal + BFMCS for modal (recommended)

**Idea**:
1. Build ONE dovetailed BXPoint chain (an FMCS) that resolves all F/P/Until/Since obligations
2. Package this chain plus modal witness chains into a BFMCS
3. Use the parametric truth lemma

**Key simplification for Int**: For Until coherence, when `φ U ψ ∈ fam.mcs t`:
- Forward: `bx_until_eventuality_resolution` gives `∃ v, bx_le (fam.mcs t) v, ψ ∈ v`. Place v at time `t + 1` in the chain (or at time t if ψ ∈ fam.mcs t already by BX8).
- Guard: The guard interval `{r : t ≤ r < t+1}` for Int contains only `{t}`. So we need `φ ∈ fam.mcs t`, which `bx_until_eventuality_resolution` already provides (when ψ ∉ fam.mcs t).
- Backward: BX8 gives `ψ ∈ fam.mcs t → (φ U ψ) ∈ fam.mcs t` for the reflexive case.

**This means Until/Since coherence for D = Int is almost free**: the BXCanonical eventuality resolution already provides both the witness and the guard formula at time t, and the Int guard interval trick makes the guard between t and t+1 trivial.

## Confidence Level

**Strategy B (Bridge to Parametric) remains the strongest approach**, as identified in the prior report. The BFMCS construction is the core challenge, and it cannot be avoided due to the Box case in the truth lemma.

However, this analysis reveals a significant simplification opportunity:

**The Int guard-interval trick for Until/Since coherence** (section 5.4 of the prior report) is not merely a nice observation -- it is the KEY that makes the BFMCS Until/Since coherence construction tractable. With D = Int:
- Forward Until coherence: place witness at t+1, guard is trivially {t}
- Backward Until coherence: BX8 handles reflexive case, step transfer from t+1 to t uses `Int.lt_add_one_iff`

**Estimated complexity with the Int simplification**:
- FMCS chain construction (dovetailed): ~150-200 lines
- BFMCS packaging (modal saturation): ~100-150 lines
- Until/Since coherence proofs: ~50-100 lines (dramatically simplified by Int guard trick)
- Bridge proof (instantiate valid, derive contradiction): ~50-100 lines
- **Total: ~350-550 lines**

**Confidence**: 7/10 that this approach can close the sorry with zero additional sorries, contingent on:
1. The dovetailed chain construction correctly resolving ALL obligations (not just one)
2. The modal saturation step correctly generating witness families
3. The Int guard trick actually working for the step transfer in backward Until

**Risk factors**:
1. The step transfer for backward Until (`(φ U ψ) ∈ fam.mcs (t+1) ∧ φ ∈ fam.mcs t → (φ U ψ) ∈ fam.mcs t`) is noted as problematic in UntilSinceCoherence.lean. This needs careful analysis.
2. Modal saturation requires constructing infinitely many witness families, which may interact badly with temporal coherence obligations.

## References

### Codebase files analyzed
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (the sorry at line 154)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` (MCS-level truth properties)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (BXPoint, bx_le, eventuality resolution)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` (BX axiom MCS lemmas)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (defect-discharge)
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` (sigma defect count)
- `Theories/Bimodal/Semantics/TaskFrame.lean` (TaskFrame definition)
- `Theories/Bimodal/Semantics/TaskModel.lean` (TaskModel definition)
- `Theories/Bimodal/Semantics/Truth.lean` (truth_at definition, Until guard interval)
- `Theories/Bimodal/Semantics/Validity.lean` (valid definition)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` (parametric frame)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` (parametric truth lemma)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` (representation theorem)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (coherence definitions)
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` (backward Until/Since)
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` (FMCS definition)
- `Theories/Bimodal/Metalogic/Completeness.lean` (MCS properties)

### Boneyard files analyzed
- `Boneyard/StrictSemanticsLegacy/BaseCompleteness.lean` (base completeness structure)
- `Boneyard/StrictSemanticsLegacy/DenseCompleteness.lean` (dense completeness structure)
- `Boneyard/StrictSemanticsLegacy/DiscreteCompleteness.lean` (discrete completeness)
- `Boneyard/StrictSemanticsLegacy/Algebraic/DovetailedChain.lean` (dovetailed chain, 6 sorries)
- `Boneyard/StrictSemanticsLegacy/Algebraic/RestrictedTruthLemma.lean` (restricted approach)
- `Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean` (canonical construction)
- `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean` (succ chain FMCS)
- `Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean` (completeness wiring)
- `Boneyard/ChainCompleteness/Completeness/SuccChainCompleteness.lean` (succ chain completeness)
- `Boneyard/ChainCompleteness/Bundle/SimplifiedChain.lean` (simplified restricted chain)

### Literature
- Burgess 1984: "Basic Tense Logic" (canonical model, defect-discharge)
- Goldblatt 1992: "Logics of Time and Computation" (completeness for tense logics)
- Reynolds 2003: "An axiomatization of Until" (Until over dense time)
- Xu 1988: "Completeness for Until-Since on linear orders"
