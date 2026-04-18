# Teammate B Findings: Quasimodel Infrastructure and Literature-Based Approaches

**Artifact**: 39
**Task**: 93 — Complete BXCanonical Embedding
**Focus**: Quasimodel infrastructure, FiniteDeferral gap, and architecture for sorry-free dd_bfmcs

---

## Key Findings

- The quasimodel infrastructure in `Quasimodel/Construction.lean` is **substantially complete and sorry-free** through Phase 3 (`hintikka_chain_exists`, `hintikka_chain_exists_since`). The well-founded induction on `defect_count` works cleanly.
- The `HintikkaStepOracle` abstraction is the critical bridge: once the oracle is discharged (from BXPoints), temporal coherence is obtained by construction via the chain's last point.
- `FiniteDeferral.lean` has steps 1–4 proved but **step 5 (cycle contradiction) is sorry** and has a genuine circular dependency: deriving G(¬ψ) from "¬ψ forever" requires `temporal_backward_G_with_fwd_F`, which requires forward_F itself.
- The quasimodel architecture in `Construction.lean` does NOT depend on the `dd_chain` / `rr_fwd_chain` incremental approach. It works at the BXPoint / MCS level directly. It is the standard Burgess 1984 / Reynolds 1996 approach.
- **The three sorry sites (lines 1517, 1522, 1527 in `RootScopedChain.lean`) are blocked by `dd_fmcs_forward_F` and `dd_fmcs_backward_P`**, which are themselves blocked by the depth-0 base case of `rr_fwd_chain_forward_F` (line 1413) — the irreducible BX11 perpetual deferral obstruction.
- **A clean architecture exists**: build a NEW `qm_bfmcs` bypassing `dd_fmcs` entirely, using the quasimodel chain to construct a model in which temporal coherence holds by construction. This avoids all perpetual deferral issues.

---

## Quasimodel Infrastructure Assessment

### What Is Proved (Sorry-Free)

**`SubformulaClosure.lean`** (fully proved):
- `subformulas`, `SubformulaClosure`, `ghEnrichment` — finite Sigma-closure with G/H enrichment and negation pairing
- `SubformulaClosure_G_closed`, `SubformulaClosure_H_closed`, `SubformulaClosure_untl_closed` — closure under G/H-unwrapping and Until-component extraction

**`HintikkaPoint.lean`** (fully proved):
- `HintikkaPoint` structure: locally consistent, bot-free Finset subsets of Sigma
- `sigma_signature`, `sigma_signature_consistent`, `sigma_signature_bot_free` — projection of a BXPoint to a valid Hintikka point
- `sigma_signature_mem` — membership iff in both Sigma and BXPoint

**`Construction.lean`** (fully proved):
- `hintikka_step` — G-propagation, H-backward, Until-defect propagation relation
- `UntilDefect`, `SinceDefect` — defect predicates
- `defect_count`, `untilDefectSet`, `sinceDefectSet` — termination measures
- `hintikka_step_target_decrease` — strict decrease on defect count when target witness appears (line 283)
- `hintikka_step_target_decrease_since` — Since dual (line 335)
- `QuasimodelChain`, `HintikkaRawChain`, `WitnessedHintikka` — chain structures with BXPoint backing
- `hintikka_chain_exists` (line 594) — **Phase 3 main theorem**: well-founded induction on `defect_count` gives a witnessed raw chain with `ψ ∈ last.formulas` and `ChainWitnessed`
- `hintikka_chain_exists_since` (line 769) — Since dual
- `chain_step_seed_consistent` (line 676) — any subset of a chain point's formulas is SetConsistent (one-line MCS proof via `ChainWitnessed`)
- `HintikkaStepOracle`, `HintikkaStepOracleSince` — oracle abstractions

**`Realization.lean`** (fully proved):
- `enriched_seed_consistent_until`, `enriched_seed_consistent_since` — seed consistency for ¬(φ U ψ) context
- `chain_step_seed_consistent_enriched`, `chain_step_seed_consistent_enriched_since` — enriched seed consistency via ChainWitnessed
- `SubformulaClosure_G_closed`, `SubformulaClosure_H_closed`, `SubformulaClosure_untl_closed` — closure properties for oracle projection
- `F_of_mem`, `P_of_mem` — F/P membership from direct membership
- `until_eventuality_resolution`, `since_eventuality_resolution` — delegates to Frame.lean

**`LocusControl.lean`** (fully proved):
- `bx_until_eventuality_resolution'`, `bx_since_eventuality_resolution'` — thin delegation to Realization.lean

**`EnrichedClosure.lean`** (fully proved):
- `enrichedClosure`, `enrichedCore`, Fisher-Ladner style closure with G(¬bigconj(T)) for all T ⊆ base

### What Is Missing

1. **HintikkaStepOracle discharge**: The oracle `HintikkaStepOracle φ ψ` (Construction.lean:477) is defined but **not discharged**. Discharging it requires: given `h : HintikkaPoint Sigma` with `φ U ψ ∈ h.formulas` and `ψ ∉ h.formulas`, find a backed `WitnessedHintikka Sigma` that is one `hintikka_step` ahead and either reaches ψ or strictly decreases `defect_count`.

   The discharge requires:
   a. Getting a BXPoint backing `h` (from `ChainWitnessed` or from the oracle's context)
   b. Using `until_eventuality_resolution` (Frame.lean:623) to get `v` with `bx_le w v` and `ψ ∈ v.formulas`
   c. Showing `sigma_signature v Sigma` satisfies `hintikka_step h (sigma_signature v Sigma)`
   d. Showing `defect_count (sigma_signature v Sigma) < defect_count h` OR `ψ ∈ (sigma_signature v Sigma).formulas`

   **Step (c)** is the main obligation: verifying that `sigma_signature v Sigma` satisfies all three clauses of `hintikka_step` (G-prop, H-backward, Until-defect). The G-propagation clause follows from `bx_le w v` and BX1. The H-backward clause requires `bx_H_forward`. The Until-defect clause requires BX axioms at MCS level (all already proved: `until_elim_mcs`, `self_accum_mcs`).

   **Step (d)**: if `ψ ∈ v.formulas` and `ψ ∈ Sigma`, then `ψ ∈ (sigma_signature v Sigma).formulas` directly. The defect-decrease case only applies when `ψ ∉ Sigma`, but since `ψ ∈ SubformulaClosure target` (with target = `φ U ψ`), ψ is always in Sigma, so the "witness reached" branch always fires. This means the defect decreases trivially for the target defect, but other defects in `sigma_signature v Sigma` might be larger — which is why `defect_mono` is needed.

2. **Bridge lemma**: A lemma showing `untilDefectSet (sigma_signature v Sigma) ⊆ untilDefectSet (sigma_signature w Sigma)` (or `bx_le w v` implies defect monotonicity for sigma signatures) is not yet proved. This is the `defect_mono` hypothesis in `hintikka_step_target_decrease`.

3. **Chain to FMCS bridge**: No lemma currently connects a realized Hintikka chain to an Int-indexed FMCS. This bridge is the largest missing piece for the new architecture.

---

## FiniteDeferral Gap Analysis

`FiniteDeferral.lean` has 5 steps:
1. F(ψ) → (⊤ U ψ) in chain (proved: `F_to_until_in_chain`)
2. (⊤ U ψ) persists until ψ appears (proved: `until_persists_forward_steps`)
3. Restricted theories take finitely many values (proved: `restrictedTheory`, `pigeonhole_restricted_theories`)
4. Pigeonhole gives two positions with the same restricted theory (proved in `pigeonhole_restricted_theories`)
5. Cycle with unresolved (⊤ U ψ) contradicts Until Induction — **sorry** (line 381)

**The gap in step 5**: `G_neg_kills_until` (line 164) is proved (G(¬ψ) ∈ chain(t) → (⊤ U ψ) ∉ chain(t)). But to use this, we need G(¬ψ) ∈ chain(t) when ψ never appears after t. Deriving G(¬ψ) from "¬ψ ∈ chain(s) for all s ≥ t" requires backward G reasoning via `temporal_backward_G_with_fwd_F`, which depends on forward_F — creating a genuine circularity.

The FiniteDeferral machinery is self-contained for the *deterministic chain* (`DeterministicChain.lean`), not for the `rr_fwd_chain` / `dd_chain` architecture. Bridging to the latter would require additional infrastructure.

**Assessment**: The FiniteDeferral approach for the `dd_chain` architecture has a genuine circularity that cannot be broken without either (a) well-founded induction on formula complexity with strictly decreasing measure (possible but unclear if it actually decreases), or (b) abandoning this approach in favor of the quasimodel.

The file itself (line 372-377) recommends: "Approach (4), the quasimodel construction, is the standard method in the literature for discrete temporal completeness."

---

## Seed Consistency: Why G-Lift Fails for Until Formulas

From `WitnessSeed.lean`:
- `until_witness_seed_consistent` (line 342) proves `{ψ} ∪ g_content(M)` is consistent when `φ U ψ ∈ M`.
- The G-lift method works for the Lindenbaum seed `{ψ} ∪ g_content(M)` by using `until_induction` with χ = ⊥.

**Why G-lift fails for adding Until formulas to Lindenbaum seeds**:

When trying to add `φ U ψ` to a chain step seed (rather than just ψ), we need the seed `{φ U ψ} ∪ g_content(M)` to be consistent. This would follow if `F(φ U ψ) ∈ M`. But `F(φ U ψ)` is not directly derivable from `φ U ψ ∈ M` — we can derive `F(ψ) ∈ M` via BX10, but `F(φ U ψ)` would require a stronger axiom. The BX axiom set gives `F(ψ) ∈ M` (BX10), not `F(φ U ψ) ∈ M`.

Furthermore, the `bx_le` relation is defined as `g_content w ⊆ v.formulas`, which only tracks G-formulas. Until formulas `φ U ψ` are NOT in `g_content` (which only contains χ where `G(χ) ∈ w.formulas`). So Until formulas do not propagate through `bx_le`. This means:
- If `φ U ψ ∈ w.formulas` and `bx_le w v`, we cannot conclude `φ U ψ ∈ v.formulas` (G-lift fails)
- The Lindenbaum extension from seed `{φ U ψ} ∪ g_content(M)` can create `v` where `φ U ψ ∈ v`, but we cannot then extend from `v` using `bx_le v ?` without losing `φ U ψ`

**Alternative consistency arguments**: A compactness-based argument is not available in the Lean 4 setting without additional infrastructure. The quasimodel approach sidesteps this by working with `hintikka_step` (which explicitly propagates Until defects) rather than trying to add Until formulas to Lindenbaum seeds.

---

## Recommended Architecture for a New dd_bfmcs Construction

**The core insight**: The quasimodel infrastructure already gives temporal coherence by construction. The oracle `HintikkaStepOracle φ ψ`, when discharged from BXPoints, produces a chain whose **last point** has ψ. This is exactly what `restricted_temporally_coherent` needs.

### Proposed Architecture: `qm_bfmcs`

A new BFMCS bypassing `dd_fmcs` / `dd_chain` entirely:

**Step 1**: Pick `Sigma = SubformulaClosure root` (or `enrichedClosure root`).

**Step 2**: Discharge `HintikkaStepOracle φ ψ` for all `φ U ψ ∈ Sigma`:
- Given `h : HintikkaPoint Sigma` with `φ U ψ ∈ h.formulas` and `ψ ∉ h.formulas`, take any backing BXPoint `w` (e.g., the starting MCS `M₀`)
- Apply `until_eventuality_resolution` (Frame.lean:623): get `v` with `bx_le w v` and `ψ ∈ v`
- Build `sigma_signature v Sigma : HintikkaPoint Sigma`
- Verify `hintikka_step h (sigma_signature v Sigma)` — requires checking 3 clauses against BX axioms (all available)
- The target witness is reached: `ψ ∈ (sigma_signature v Sigma).formulas` iff `ψ ∈ Sigma` (true by SubformulaClosure_untl_closed) and `ψ ∈ v.formulas` (true by construction)

**Step 3**: Apply `hintikka_chain_exists` — gives a `HintikkaRawChain` from any starting point to a point with `ψ`.

**Step 4**: Build an Int-indexed family `qm_mcs : ℤ → Set Formula` by:
- For each BXPoint `w`, use `sigma_signature w Sigma` as the initial Hintikka point
- Extend forward (toward future) using the oracle to realize Hintikka chains as BXPoint chains
- The FMCS conditions (is_mcs, forward_G, backward_H) are inherited from the realized BXPoints

**Step 5**: Show `restricted_temporally_coherent`: for `F(ψ) ∈ qm_mcs(t)`, apply `hintikka_chain_exists` to get chain ending at point with ψ, then use the chain's length as the witness distance.

### Key Lemmas Still Needed

1. **Oracle discharge** (~150 LOC): Prove `HintikkaStepOracle φ ψ` using `until_eventuality_resolution` + `sigma_signature` projection + `hintikka_step` verification.

2. **Defect monotonicity** (~80 LOC): `bx_le w v → untilDefectSet (sigma_signature v Sigma) ⊆ untilDefectSet (sigma_signature w Sigma)`. Key: if `φ U ψ ∈ sigma_signature v Sigma` (i.e., `φ U ψ ∈ Sigma` and `φ U ψ ∈ v.formulas`) and `ψ ∉ sigma_signature v Sigma`, and `bx_le w v`, we need `φ U ψ ∈ sigma_signature w Sigma` and `ψ ∉ sigma_signature w Sigma`. The first follows from BX axioms applied to `bx_le` (actually this may FAIL — see obstacle below).

3. **FMCS realization from chain** (~200 LOC): Build `dd_fmcs` equivalent using realized chain BXPoints.

4. **Bridge from FMCS to BFMCS** (~100 LOC): Show the realized FMCS has `restricted_temporally_coherent` and other BFMCS properties.

### Critical Obstacle: Defect Monotonicity

The `defect_mono` hypothesis in `hintikka_step_target_decrease` requires `untilDefectSet h2 ⊆ untilDefectSet h1`. In the realization context where `h2 = sigma_signature v Sigma` and `h1 = sigma_signature w Sigma` with `bx_le w v`:

- If `φ U ψ ∈ v.formulas` and `ψ ∉ v.formulas`, we need `φ U ψ ∈ w.formulas` and `ψ ∉ w.formulas`
- The first part (`φ U ψ ∈ w.formulas`) does NOT follow from `bx_le w v` alone — Until formulas don't propagate through `bx_le`
- This means the oracle output (going from `w` to `v`) might INCREASE defect count if `v` contains new Until formulas not in `w`

**Consequence**: The oracle can only reliably discharge the TARGET defect (`φ U ψ`). For other defects, monotonicity is NOT guaranteed from `bx_le` alone. This is why `WitnessedHintikka` carries a BXPoint backing `wh'` — the `defect_mono` hypothesis must be discharged contextually, not from `bx_le`.

**Resolution**: The oracle approach in `hintikka_chain_exists` is designed precisely for this: the oracle only needs to decrease defect count for the **specific target** `φ U ψ`, not all defects. But the `HintikkaStepOracle` definition at line 483 requires:
```
ψ ∈ wh'.point.formulas ∨
  (Formula.untl φ ψ ∈ wh'.point.formulas ∧ defect_count wh'.point < defect_count h)
```

This means either the witness is reached (always true when `ψ ∈ Sigma` and `bx_le w v` produces `v` with `ψ ∈ v`), OR the defect count decreases. Since the "witness reached" branch is always available (SubformulaClosure contains ψ when it contains φ U ψ), the defect_mono obstacle does NOT block the oracle discharge. The oracle always takes the first branch.

**Revised Assessment**: The oracle discharge is simpler than it looks — for `Sigma = SubformulaClosure root`, once `until_eventuality_resolution` gives `v` with `ψ ∈ v.formulas`, and `ψ ∈ Sigma` (by `SubformulaClosure_untl_closed`), we immediately have `ψ ∈ (sigma_signature v Sigma).formulas`, so the oracle always returns the "witness reached" branch. No defect-monotonicity argument is needed.

---

## Gap: Hintikka Chain vs. Int-Indexed FMCS Bridge

The quasimodel chain gives a FINITE path from initial point to witness point. An Int-indexed FMCS requires an INFINITE chain. The gap is:

**Option A**: Use the chain length as the "time step" and replicate the chain periodically. This is the standard quasimodel unwinding:
- Build a finite quasimodel (finite set of Hintikka points with step relation)
- Unwind to an omega-model by running the quasimodel forward
- This requires showing the quasimodel is itself an FMCS analog

**Option B**: Directly realize each chain from a different starting BXPoint into the BFMCS families set. The `dd_bfmcs` uses `families` (a set of FMCS). The quasimodel oracle gives eventuality resolution for each element of each family independently.

**Option B is more natural** given the existing BFMCS architecture. The three sorry sites in `dd_bfmcs` call `restricted_temporally_coherent`, `restricted_backward_until_since_coherent`, and `restricted_forward_until_since_coherent`. These can be discharged if:
- Each family (= each shifted `dd_fmcs`) satisfies temporal coherence
- The oracle discharge above gives the key `∃ s > t` witness for F-formulas

The remaining gap: `dd_fmcs` uses `dd_chain` which is not based on the quasimodel. The direct approach is:
1. Prove `dd_fmcs_forward_F` using the quasimodel oracle (NOT the FiniteDeferral approach)
2. The quasimodel oracle gives: `F(ψ) ∈ dd_fmcs.mcs(t)` → extract BXPoint `w` with `w.formulas = dd_fmcs.mcs(t)` → apply `until_eventuality_resolution` → get `v` with `ψ ∈ v` and `bx_le w v` → but `v` is not in the `dd_chain` sequence

**This is the fundamental architecture mismatch**: `bx_le w v` gives a witness `v` in the BXPoint world, but `dd_fmcs.mcs(t)` is an SPECIFIC sequence of MCSs from `rr_fwd_chain`. The witness `v` from `until_eventuality_resolution` is a DIFFERENT BXPoint, not necessarily in the chain sequence.

**The correct quasimodel approach**: Build a DIFFERENT FMCS (not `dd_fmcs`) from scratch using the quasimodel oracle to handle temporal coherence. The BFMCS `families` set would contain these quasimodel-based FMCSs. The `dd_bfmcs` three sorry sites would then delegate to this new construction rather than trying to prove them for `dd_fmcs`.

**Estimated LOC for new construction**:
- Oracle discharge: ~150 LOC
- Quasimodel-based FMCS definition: ~250 LOC
- FMCS properties verification: ~300 LOC
- BFMCS wrapping and sorry-site proofs: ~200 LOC
- **Total estimate**: ~900 LOC

---

## Confidence Assessment

- **Quasimodel infrastructure soundness**: HIGH. The core machinery (`hintikka_chain_exists`, `hintikka_step_target_decrease`, `ChainWitnessed`) is sorry-free and the mathematical argument is standard Burgess 1984.
- **Oracle discharge feasibility**: HIGH. The "witness reached" branch always fires for `Sigma = SubformulaClosure root`, making the discharge straightforward.
- **FiniteDeferral approach**: LOW. The circularity in step 5 is genuine and the approach is abandoned as dead end by the codebase itself.
- **Architecture mismatch resolution**: MEDIUM. The BFMCS families set can include quasimodel-based FMCSs, but building the full bridge requires ~900 LOC of new infrastructure with no existing sorry-free framework to stand on for the FMCS-from-chain direction.
- **G-lift failure for Until formulas**: CONFIRMED. Until formulas do not propagate through `bx_le`, making extended seed consistency impossible via G-lift. The quasimodel's `hintikka_step` explicitly handles this via the Until-defect propagation clause.

---

## Summary

The quasimodel infrastructure in `Quasimodel/Construction.lean` is the right long-term solution. It avoids the BX11 perpetual deferral obstruction entirely by working at the Hintikka point level with explicit defect discharge. The key components are:
- `hintikka_chain_exists` (sorry-free, line 594)
- `hintikka_step` with Until-defect clause (sorry-free, line 45)
- `defect_count` decrease measure (sorry-free)
- `HintikkaStepOracle` discharge via `until_eventuality_resolution` + `sigma_signature` projection (NOT yet proved, ~150 LOC)

The oracle discharge is the critical missing piece. Once that is proved, `hintikka_chain_exists` gives temporal coherence by construction. The remaining gap is bridging from finite Hintikka chains to an Int-indexed FMCS suitable for the BFMCS architecture, estimated at ~750 additional LOC.

The FiniteDeferral approach (`FiniteDeferral.lean`) should be treated as abandoned infrastructure. The `dd_fmcs` / `dd_chain` approach cannot close the three sorry sites without solving the depth-0 BX11 perpetual deferral problem, which requires the quasimodel approach anyway.
