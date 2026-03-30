# Research Report: Task #67 — Construction-Level Alternatives (Teammate B)

**Task**: prove_bundle_validity_implies_provability
**Date**: 2026-03-29
**Teammate**: B (backward-from-crux, construction alternatives)
**Session**: lean-research-agent investigation

---

## Key Findings: What We Need at the Crux

### Exact Goal States at the Sorry Locations

**At line 3006 (Case 1: resolved branch, k >= B sub-case)**:

```
case neg
phi : Formula
M0 : DeferralRestrictedSerialMCS phi
k : ℕ
theta : Formula
d remaining_steps remaining' n : ℕ
h_d_ge : n + 1 ≥ 1
h_iter_in : (iter_F n theta).some_future ∈ restricted_forward_chain phi M0 k
h_iter_not : iter_F (n + 1 + 1) theta ∉ restricted_forward_chain phi M0 k
h_d_lt : n + 1 < closure_F_bound phi
h_resolved : iter_F n theta ∈ restricted_forward_chain phi M0 (k + 1)
h_d'_in : iter_F (d' + (n - 1)) theta ∈ restricted_forward_chain phi M0 (k + 1)
h_d'_not' : iter_F (d' + (n - 1) + 1) theta ∉ restricted_forward_chain phi M0 (k + 1)
hk : closure_F_bound phi ≤ k
h_inv : remaining' + 1 ≥ 1
⊢ False
```

**At line 3037 (Case 2: deferred branch, k >= B sub-case)**:

```
case neg
phi : Formula
M0 : DeferralRestrictedSerialMCS phi
k : ℕ
theta : Formula
d remaining_steps remaining' n : ℕ
h_d_ge : n + 1 ≥ 1
h_iter_in : (iter_F n theta).some_future ∈ restricted_forward_chain phi M0 k
h_iter_not : iter_F (n + 1 + 1) theta ∉ restricted_forward_chain phi M0 k
h_d_lt : n + 1 < closure_F_bound phi
h_deferred : (iter_F n theta).some_future ∈ restricted_forward_chain phi M0 (k + 1)
h_d'_in : iter_F (d' + n) theta ∈ restricted_forward_chain phi M0 (k + 1)
h_d'_not' : iter_F (d' + n + 1) theta ∉ restricted_forward_chain phi M0 (k + 1)
hk : closure_F_bound phi ≤ k
h_inv : remaining' + 1 ≥ 1
⊢ False
```

### What Would Close These Goals Directly

Both goals are `False`. The hypotheses give us:
- `h_d_lt : n + 1 < B` (depth bounded — PROVEN, already available)
- `hk : B ≤ k` (the case we're in)
- `h_iter_in : F(iter_F n theta) ∈ chain(k)` (an active F-obligation at position k >= B)

The only way to close `False` is to show that having an active F-boundary at position `k >= B` is impossible. This requires a lemma of the form:

```lean
-- The "stabilization lemma": active boundaries only occur before position B
theorem boundary_implies_k_lt_B (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (h_d_ge : d ≥ 1)
    (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k) :
    k < closure_F_bound phi
```

Alternatively, the goals could be closed if we could derive a direct contradiction from the specific hypotheses without proving the general stabilization lemma — but all available hypotheses lead back to the same gap: the construction does not prevent F-boundaries from persisting past position B.

### Critical Observation: Why the Stabilization Lemma is Hard

The `restricted_forward_chain` is built by iterating `constrained_successor_restricted`, which uses `deferral_restricted_lindenbaum` (Zorn's lemma / Lindenbaum's theorem). At each step:

1. The seed contains `deferralDisjunctions(u) = {psi ∨ F(psi) | F(psi) ∈ u}`
2. The seed contains `boundary_resolution_set(phi, u)` to force resolution at MAXIMUM depth (where `FF(chi) ∉ deferralClosure phi`)
3. The Lindenbaum extension may choose either `psi` (resolve) or `F(psi)` (defer) for each disjunction UNLESS `psi` is in the `boundary_resolution_set`

The `boundary_resolution_set` only triggers when `F(F(chi)) ∉ deferralClosure phi`, which corresponds to the maximum F-nesting depth (depth = B-1 where B = `closure_F_bound phi`). At sub-maximal depths d < B-1, the Lindenbaum extension can freely choose to defer, keeping `F(iter_F d theta)` in chain(k) for ALL k.

This means the current construction does NOT guarantee eventual resolution for sub-maximal F-formulas. The stabilization lemma is **likely false as stated** under the current construction.

---

## Construction Alternatives

### Alternative 1: Depth-Indexed Deferral Counter ("Fairness Counter")

**Concept**: Add a "deferral count" parameter to the seed construction. Track how many times each F-formula has been deferred. When the count reaches B, force resolution by adding the resolving formula to the seed directly (not just as a disjunction).

**Mechanism**:
```
constrained_successor_seed_fair (phi : Formula) (u : Set Formula) (counts : Formula → Nat) : Set Formula :=
  g_content u ∪
  deferralDisjunctions_constrained phi u counts ∪   -- disjunctions only for count < B
  forced_resolutions phi u counts ∪                  -- direct inclusions for count >= B
  p_step_blocking_formulas_restricted phi u ∪
  boundary_resolution_set phi u

where forced_resolutions phi u counts =
  {psi | F(psi) ∈ u ∧ counts(F(psi)) ≥ closure_F_bound phi}
```

**Thread counts through the chain**:
```
RestrictedForwardChainElement (phi : Formula) where
  world : Set Formula
  is_drm : DeferralRestrictedMCS phi world
  has_F_top : F_top ∈ world
  deferral_counts : Formula → Nat   -- NEW: tracks deferrals per formula
```

**Invariant to prove**: After B steps, every formula that has been deferred B times gets forced. Since there are at most B distinct F-depths and each formula can be deferred at most B times per depth, the total deferral count is bounded by B*B.

**Why it works**: The `boundary_implies_k_lt_B` lemma would follow from: "if F(psi) is in chain(k) for k >= B, then it has been deferred at least B times, but forced_resolutions forces it to resolve within B steps, contradicting k >= B."

**Risk**: Existing proofs about `constrained_successor_restricted` must be re-derived for the new construction. The DRM property must be re-established with the new seed. Most critically: forced_resolutions must be shown to be subset of deferralClosure, which requires showing psi ∈ deferralClosure when F(psi) ∈ u ⊆ deferralClosure (this IS true via `F_inner_in_deferralClosure`). Consistency of the augmented seed is the main challenge — forcing both psi and F(psi) might be inconsistent in some pathological case (though this is unlikely given that F(psi) ∈ u implies psi is "possible").

**Effort estimate**: 10-15 hours. Requires rebuilding the chain construction from scratch with the new parameter.

---

### Alternative 2: Strengthen boundary_resolution_set to All Depths

**Concept**: Modify `boundary_resolution_set` to force resolution not just at depth B-1 but at all depths d when "enough steps have passed."

**Current definition**:
```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | F(chi) ∈ u ∧ FF(chi) ∉ deferralClosure phi ∧ F(neg chi) ∉ u}
```

**Proposed definition (v2)**:
```lean
def boundary_resolution_set_v2 (phi : Formula) (u v : Set Formula) : Set Formula :=
  -- Original boundary (max depth):
  {chi | F(chi) ∈ u ∧ FF(chi) ∉ deferralClosure phi ∧ F(neg chi) ∉ u}
  ∪
  -- New: any formula that was deferred at previous step and is STILL deferred
  {chi | F(chi) ∈ u ∧ F(chi) ∈ v}  -- v = previous chain element
```

**Problem**: This requires the seed to know the PREVIOUS chain element, making the construction non-Markovian. The chain would need to be defined with a 2-step lookahead, significantly complicating the construction.

**Verdict**: This direction is technically sound but very invasive. Not recommended.

---

### Alternative 3: Well-Founded Recursion on "Active Obligations" Set (No Fuel, No Construction Change)

**Concept**: Instead of fuel-based termination in `restricted_bounded_witness_wf`, use a strictly decreasing measure that does NOT require the k >= B case to be impossible. The measure would be a finite set of "active F-obligations" that strictly shrinks.

**Proposed measure**: For each recursive call with formula `theta`, depth `d`, position `k`:
```
measure = { (d', k') | iter_F d' theta ∈ chain(k') ∧ k' ≤ k ∧ d' ≥ 1 }
```
This set is finite (bounded by B * |chain elements| but chain elements are determined by deferralClosure which is finite). However, the POSITION k is unbounded, so this set is not finite in general.

**Alternative measure**: Use the F-nesting depth as a primary measure and the number of "unresolved depth-d formulas at position k" as secondary. This is a LEXICOGRAPHIC well-founded order.

**Lean encoding**:
```lean
-- Primary: total F-nesting depth decrease across the recursion tree
-- Secondary: number of chain steps needed to resolve current obligation
-- This needs Acc-based well-founded recursion rather than fuel-matching
```

**Challenge**: Lean's `termination_by` requires a syntactically decreasing measure per recursive call. A set-valued measure requires `measure_wf` and `Acc.rec` style proofs, which are verbose. The `Finset.strongDownwardInductionOn` from Mathlib could be useful here (`Finset.strongDownwardInductionOn : {α} → {p : Finset α → Sort} → (s : Finset α) → (∀ t₁, (∀ t₂, t₂.card ≤ n → t₁ ⊂ t₂ → p t₂) → ...) → p s`).

**Key insight for making this work**: Define a "resolution obligation" for formula theta at position k as the set of depths that remain to be peeled:
```
remaining_obligations(theta, k) =
  Finset.filter (fun d => iter_F d theta ∈ chain(k) ∧ iter_F (d+1) theta ∉ chain(k))
                (Finset.range B)
```
At each recursive call, the argument resolves one depth level from this set, making the set strictly smaller. This could work if we can show the set never "grows back" — but the problem is that at chain(k+1), new depth boundaries may arise for sub-formulas.

**Verdict**: Theoretically sound but requires a sophisticated termination argument that goes against the grain of Lean's automation. Estimated 8-12 hours.

---

### Alternative 4: Direct Proof via chain_k_ge_B_stabilizes Lemma (Structural)

**Concept**: Instead of changing the construction, prove a STRUCTURAL property of the existing construction that gives us what we need.

The specific thing we need is: at position k >= B in the chain, no formula of the form `iter_F d theta` (with d < B) can be at an "active boundary" (in chain(k) but not chain(k) after another step).

Wait — the boundary condition is `iter_F (d+1) theta ∉ chain(k)`, NOT "not in chain(k+1)". The boundary is within a SINGLE chain element, not across steps. So the claim is:

> For k >= B and any theta, d < B, if `iter_F d theta ∈ chain(k)` then `iter_F (d+1) theta ∈ chain(k)`.

In other words: at position k >= B, the chain element has NO F-boundary for theta at depth d < B. This would mean "no active F-obligation at depth d" in the chain at k >= B.

**This is a SINGLE-WORLD property**, not a multi-world stability property. It's asking: can a DeferralRestrictedMCS at position k >= B contain `iter_F d theta` but not `iter_F (d+1) theta` for d < B?

**Analysis**: Each chain element is a DeferralRestrictedMCS, and by `restricted_forward_chain_depth_bounded`, the depth d of any active boundary satisfies d < B. This tells us d < B, NOT k < B. The question is whether k >= B implies we cannot have SUCH a d.

**Counter-observation**: The chain at position k (for any k) is an MCS within deferralClosure. There is NO reason in principle why a formula at depth d < B cannot be "the last active" in that MCS. The position k only affects what was in the PREVIOUS chain elements, not what the current element contains. The Lindenbaum extension is stateless.

**Verdict**: This structural approach collapses back to the same gap. The construction does not give us any position-dependent properties.

---

### Alternative 5: Replace fuel with structural recursion on "unresolved depths" (Hybrid)

**Concept**: The real issue is that `restricted_bounded_witness_wf` recurses with BOTH increasing k AND changing d. If we could establish that d STRICTLY DECREASES across all recursive paths (not just one), fuel would not be needed.

**Observation from goal states**: In Case 1 (resolved), we go from depth `n+1` at position `k` to depth `d' + (n-1)` at position `k+1`. For the outer depth to decrease, we need `d' + (n-1) < n+1`, i.e., `d' < 2`, i.e., `d' = 1`. But `d'` can be up to B-1.

In Case 2 (deferred), we go from depth `n+1` at position `k` to depth `d' + n` at position `k+1`. For depth to decrease, we need `d' + n < n+1`, i.e., `d' < 1`, i.e., `d' = 0`. But d' >= 1.

So in BOTH cases, the depth can INCREASE. This confirms that a simple depth-decreasing recursion is impossible.

**Hybrid approach**: Recurse on LEXICOGRAPHIC order `(total_depth, remaining_deferrals_at_current_depth)` where:
- `total_depth = d + f_nesting_depth(theta)` (total F-nesting above theta)
- `remaining_deferrals = B - k` (steps remaining before stabilization)

But this fails because `total_depth` can increase in Case 2 when `d' > 0` and `f_nesting_depth(iter_F n theta) = n + f_nesting_depth(theta)`, so new `total_depth = (d' + n) + f_nesting_depth(theta) > total_depth` when `d' > 0`.

**Verdict**: No single lexicographic measure works without construction-level guarantees.

---

## Alternative Proof Techniques (Non-Bulldozing)

### Technique 1: Henkin-Style Canonical Model via Full MCS

**What it is**: Instead of the restricted chain (DeferralRestrictedMCS), use the standard Henkin canonical model where all worlds are FULL MaximallyConsistent sets (SetMaximalConsistent), not restricted to deferralClosure. In the full canonical model, the F-step property is provable directly from MCS properties without any chain construction.

**How it avoids the fuel issue**: In the full Henkin model, the bounded witness lemma reduces to: "if F(phi) ∈ u (MCS), then there exists v with Succ(u,v) and phi ∈ v." This follows DIRECTLY from `successor_exists` (already proven in SuccExistence.lean) without any chain-position arguments.

**The gap**: The full Henkin canonical model does NOT have the TEMPORAL structure (linear order from the Task frame). The task frame requires a specific chain structure. The restricted chain was introduced precisely to get the linear order.

**Transfer approach**:
1. Prove completeness for the full Henkin model (semantic completeness — truth in any model implies provability)
2. Then show the full Henkin model is embeddable into a Task frame model
3. Transfer the completeness result

**Status in this codebase**: The `DeferralRestrictedSerialMCS.extendToMCS` function exists at line 3199 of SuccChainFMCS.lean, which converts a DeferralRestrictedSerialMCS to a full MCS. This suggests the infrastructure for transfer exists.

**Risk**: The embedding step (full Henkin model → Task frame) may be harder than the current proof. The Task frame has specific properties (successor relation) that a general Henkin model does not.

**Effort estimate**: 15-20 hours for a complete transfer-based approach.

---

### Technique 2: Filtration Method

**What it is**: The filtration method for modal logic proves completeness by constructing a FINITE model from any consistent formula using equivalence classes of formulas. Given a formula phi with subformula closure cl(phi), the filtration has at most 2^|cl(phi)| worlds.

**How it applies**: For bimodal TM logic, a filtration through the subformulaClosure would give a finite model. Since TM is decidable (this project has a Decidability module), there may be a filtration-based completeness proof.

**Why it might bypass the fuel issue**: The filtration model is finite and explicit — no infinite chain construction needed. The bounded witness lemma becomes trivial in a finite model (just enumerate worlds).

**The gap**: The filtration method works well for S5-like logics but is more complex for TEMPORAL logics. The temporal ordering in TM may not survive filtration intact. Specifically, if the temporal relation is not defined syntactically (via the subformulaClosure), the filtration may not preserve the frame conditions.

**Status in this codebase**: The `deferralClosure` is essentially a syntactic filtration (subformula + deferral closure). The `DeferralRestrictedMCS` IS a kind of filtration-restricted world. The current approach is already implicitly filtration-based, but it's trying to build a sequential chain within the filtration.

**Effort estimate**: 12-18 hours to formalize filtration completeness from scratch.

---

### Technique 3: Tableau-Based Completeness

**What it is**: A tableau-based completeness proof builds a systematic proof search tree. If the formula is unprovable, the tableau succeeds in building a countermodel.

**How it applies**: For bimodal TM, a tableau would systematically expand F-formulas by splitting into "resolve now" vs "defer" branches. The termination of the tableau (and hence the decidability of the tableau) would be proven by showing the number of "fresh" world-formula pairs is bounded.

**Why it might bypass the fuel issue**: The tableau approach handles the F-deferral problem STRUCTURALLY through the tableau rules, not through a chain construction. The termination argument is built into the tableau formalism.

**The gap**: Tableau-based completeness is essentially what the current construction IS doing (the chain IS a path through a tableau). The fuel issue in the current proof IS the termination argument for the implicit tableau. So this doesn't avoid the problem; it reframes it.

**Effort estimate**: 15-20 hours to formalize a tableau system and its completeness.

---

### Technique 4: Model-Theoretic Transfer from Propositional LTL

**What it is**: Since TM combines S5 modal logic with linear temporal logic, a completeness proof could use:
1. Completeness of S5 (well-known, available in Mathlib)
2. Completeness of LTL (well-known in the literature)
3. A combination theorem showing TM is complete as a product logic

**How it applies**: The "product logic" approach combines two complete logics by showing that the product frame satisfies the combined proof system.

**Why it might bypass the fuel issue**: The LTL completeness proof (Gabbay/Pnueli/Manna style) uses a FINITE model construction based on "eventualities" — the F-formulas that must eventually be satisfied. The "eventuality" discharge argument is exactly what our bounded witness is trying to prove, but the LTL-specific proof of it is more direct.

**Key LTL eventuality argument**: In LTL, if F(phi) is in the initial world of the model, the model construction guarantees that phi appears at some FINITE position. This is proven by showing: (1) there are finitely many "obligation types", and (2) a fairness constraint ensures each obligation is eventually discharged.

**The gap**: The "fairness constraint" in LTL is exactly what our construction lacks. The standard LTL canonical model proof explicitly builds a FAIR path (often by a round-robin or dovetailing scheduler over obligations). This IS the "bulldozing" technique that Teammate A is researching.

**Effort estimate**: 10-15 hours for a product logic approach, assuming LTL completeness primitives can be extracted.

---

### Technique 5: Explicit Fair Sequence Construction (Most Promising Non-Bulldozing)

**What it is**: Instead of iterating `constrained_successor_restricted` indefinitely, construct a SPECIFIC finite sequence of chain elements that provably satisfies all F-obligations.

**How it works**:
1. At position 0 (initial), all F-obligations at depth B-1 will be resolved at position 1 (by boundary_resolution_set)
2. At position 1, new obligations of depth ≤ B-1 may appear. Resolve depth B-1 obligations at position 2.
3. Continue for B steps; all depths 1 through B-1 will be resolved by position B.

**The formal claim**:
```lean
-- After B chain steps, all F-obligations in chain(0) have been resolved:
theorem restricted_forward_chain_all_resolved (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (theta : Formula)
    (h_F : F(theta) ∈ chain(0)) :
    ∃ m ≤ closure_F_bound phi, theta ∈ chain(m)
```

**Why this might work**: The `boundary_resolution_set` forces resolution at depth B-1. After that resolution, the depth-B-2 formulas become the new "deepest" and get forced at the NEXT step by the boundary condition. This cascade argument works if the boundary condition triggers for the NEW deepest depth after each resolution.

**Critical question**: Does the boundary_resolution_set trigger for depth B-2 after depth B-1 formulas have been resolved? The condition `FF(chi) ∉ deferralClosure phi` — is this true for iter_F(B-2) theta after iter_F(B-1) theta has been resolved?

- `iter_F (B-2) theta` has `F(iter_F (B-2) theta) = iter_F (B-1) theta ∈ chain(k)` initially
- `FF(iter_F (B-2) theta) = iter_F B theta ∉ deferralClosure` (since B = closure_F_bound phi, iter_F B ∉ deferralClosure by `iter_F_not_mem_deferralClosure`)

**This means the BRS triggers for depth B-2 as well!** Since `iter_F B theta ∉ deferralClosure phi` is ALWAYS true (for any theta and any B = closure_F_bound phi), the condition `FF(iter_F (B-2) theta) ∉ deferralClosure phi` holds whenever `FF(iter_F (B-2) theta) = iter_F B theta` which is true by `iter_F_compose`.

Wait — this is important. Let's be precise:

- For `chi = iter_F (B-2) theta`: `F(chi) = iter_F (B-1) theta` and `FF(chi) = iter_F B theta`
- `iter_F B theta ∉ deferralClosure phi` by `iter_F_not_mem_deferralClosure phi theta B (le_refl B)`
- Therefore `chi = iter_F (B-2) theta` satisfies the BRS condition `FF(chi) ∉ deferralClosure phi`!

**This means the BRS triggers for ALL depths d where d >= B-2** (i.e., where `iter_F (d+2) theta ∉ deferralClosure`). In fact, for any d, `iter_F (d+2) theta ∉ deferralClosure phi` if `d + 2 >= B`, i.e., `d >= B - 2`.

So the BRS forces resolution for ALL `chi = iter_F d theta` where `d >= B - 2`? Let me verify:

`boundary_resolution_set phi u` contains `chi` iff:
1. `F(chi) ∈ u`
2. `FF(chi) ∉ deferralClosure phi`
3. `F(neg chi) ∉ u`

For `chi = iter_F d theta`:
- Condition 2: `iter_F (d+2) theta ∉ deferralClosure phi`. This holds when `d + 2 >= B = closure_F_bound phi`, i.e., `d >= B - 2`.

So the BRS DOES force resolution for depths d >= B - 2, not just d = B - 1. This is stronger than what Teammate A found! The BRS forces ALL formulas at depth >= B-2 to resolve at the next step.

**Revised cascade analysis**:
- Step 0: chain(0) may contain iter_F d theta for d in {1, ..., B-1}
- Step 1: BRS forces all chi with FF(chi) ∉ deferralClosure, i.e., depth d >= B-2. After step 1, chain(1) has no active boundaries at depth >= B-2.
- After each step, the max depth of active F-boundaries decreases by at LEAST... hmm, not necessarily by 1 per step. After resolving depth B-2 formulas, new depth B-3 formulas might not immediately satisfy the BRS condition.

Wait: for `chi = iter_F (B-3) theta`:
- `FF(chi) = iter_F (B-1) theta`. Is `iter_F (B-1) theta ∉ deferralClosure phi`?
- `iter_F (B-1) theta` has f_nesting_depth = (B-1) + f_nesting_depth(theta) = B - 1 (assuming theta has depth 0)
- `max_F_depth_in_closure phi + 1 = closure_F_bound phi = B`
- So `max_F_depth_in_closure phi = B - 1`
- `iter_F (B-1) theta` has depth B-1 which equals `max_F_depth_in_closure phi`
- The depth bound is EXACTLY this maximum, so iter_F (B-1) theta might be IN deferralClosure!

Indeed, the depth bound says formulas in deferralClosure have depth <= max_F_depth_in_closure phi = B-1. So iter_F(B-1) theta MIGHT be in deferralClosure (it depends on whether it's a subformula of phi or derivable from it).

This means the BRS condition for `chi = iter_F (B-3) theta` is `iter_F (B-1) theta ∉ deferralClosure phi` — which may be FALSE if iter_F (B-1) theta IS in the closure. So the BRS does NOT necessarily force depth B-3 formulas.

**Revised conclusion**: The BRS forces depth `d` formulas iff `iter_F (d+2) theta ∉ deferralClosure phi`. This holds when `d + 2 > max_F_depth_in_closure phi = B-1`, i.e., `d >= B-2`. So BRS forces depths B-2 and B-1 only (assuming theta has depth 0). For formulas with positive depth, the range might be smaller.

---

## Comparison Matrix

| Approach | Description | Effort | Risk | Closures Both Sorries | Construction Change |
|----------|-------------|--------|------|----------------------|---------------------|
| A1: Fairness Counter | Add deferral_counts parameter to chain | 10-15h | High | Yes | Yes (major) |
| A2: Strengthen BRS | BRS forces all depths, not just max | 5-8h | Medium | Yes | Moderate |
| A3: Well-Founded on Active Obligations | Finset-based decreasing measure | 8-12h | High | Yes | No |
| A4: Full Henkin + Transfer | Use full MCS model, embed into Task frame | 15-20h | Very High | Yes | No |
| A5: Explicit Fair Sequence | Prove finite resolution within B steps | 4-6h | Medium | Yes | No |
| Bulldozing (Teammate A) | Standard bimodal/LTL technique | 8-15h | Medium | Yes | Yes (major) |

**Most promising**: Alternative A5 (Explicit Fair Sequence). Key insight: the BRS forces resolution for formulas at depth >= B-2. If we can prove this cascade covers ALL depths (which requires understanding which formulas are in deferralClosure), we can prove a finite bound without changing the construction.

**Key prerequisite for A5**: Prove `iter_F d theta ∉ deferralClosure phi` for all d >= 1 when theta is a propositional formula (depth 0). This would mean BRS forces ALL depths >= B-2 and a 3-step cascade argument resolves all depths.

Wait — this doesn't work directly because after forcing depth B-2 formulas, the depth B-3 formulas don't necessarily satisfy the BRS. The cascade depends on whether the NEW chain element's formulas satisfy the BRS condition.

**Most promising REVISED**: Alternative A5 combined with a STRONGER BRS that does NOT require construction changes.

**Strongest near-term path**: Prove that the current construction already forces eventual resolution via the following argument:
1. `iter_F B theta ∉ deferralClosure phi` (proven by `iter_F_not_mem_deferralClosure`)
2. Therefore `boundary_resolution_set` includes `iter_F (B-2) theta` when `F(iter_F (B-2) theta) ∈ chain(k)` and `F(neg(iter_F (B-2) theta)) ∉ chain(k)`
3. This means chain(k+1) contains `iter_F (B-2) theta`
4. But `iter_F (B-2) theta` = a sub-formula that peels back 2 levels...

The problem: after `iter_F (B-2) theta` is in chain(k+1), we need the BRS to then force `iter_F (B-3) theta` into chain(k+2). For that, we need `FF(iter_F (B-3) theta) = iter_F (B-1) theta ∉ deferralClosure phi`. But `iter_F (B-1) theta` has depth B-1 = max_F_depth, which MAY be in deferralClosure.

**Fundamental question**: Is `iter_F (B-1) theta ∈ deferralClosure phi` for arbitrary theta?

If theta has depth 0 (atom or propositional formula), then `f_nesting_depth(iter_F (B-1) theta) = B-1 = max_F_depth_in_closure phi`. Whether this specific formula is in deferralClosure depends on whether it's a subformula of phi. For GENERIC theta, it may not be.

**If we can prove that `iter_F (B-1) theta ∉ deferralClosure phi` for the specific theta values arising in the proof**, then the cascade works completely.

---

## Specific Construction Change Recommendation (If Pursued)

### BRS Strengthening (Cleanest Construction Change)

Change `boundary_resolution_set` from checking `FF(chi) ∉ deferralClosure phi` to checking `F(chi) ∉ deferralClosure phi`:

**Current** (forces at depth d where iter_F(d+2) theta ∉ deferralClosure):
```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | F(chi) ∈ u ∧ FF(chi) ∉ deferralClosure phi ∧ F(neg chi) ∉ u}
```

**Proposed** (forces at depth d where iter_F(d+1) theta ∉ deferralClosure, i.e., F(chi) itself is "at the boundary"):
```lean
def boundary_resolution_set_v2 (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | F(chi) ∈ u ∧ F(chi) ∉ deferralClosure phi ∧ F(neg chi) ∉ u}
```

Wait — if `F(chi) ∉ deferralClosure phi`, then `F(chi) ∉ u` (since u ⊆ deferralClosure), so the condition `F(chi) ∈ u` fails. This definition is vacuous.

**Correct strengthening**: Force at depth d where `iter_F d chi ∉ deferralClosure phi` for some small d. The KEY property is that `iter_F B theta ∉ deferralClosure phi`. So if we add chi to BRS when `F^n chi ∉ deferralClosure phi` for n = 2 (current) OR n = 1 (stronger):

Actually, a simpler and correct strengthening: force chi into the SEED (not just as a disjunction) when `FF(chi) ∉ u` (instead of `∉ deferralClosure`). Since `u ⊆ deferralClosure`, this is a STRONGER condition than the current one. If `FF(chi) ∉ u` and `F(chi) ∈ u`, we add chi to force resolution.

This would not immediately help unless we can link `FF(chi) ∉ u` to k >= B.

**Most principled strengthening**: Instead of a structural condition, use a SEMANTIC condition: add chi to BRS whenever there is NO CONSISTENT extension of the current seed that includes `F(chi)` without leading to chi later. This is implicit in the standard Henkin/Lindenbaum proof but is very hard to formalize.

---

## Summary Assessment

### What We Really Need

The crux requires proving `False` from:
- `F(iter_F n theta) ∈ chain(k)` with `k >= B` and `n + 1 < B`

This is an existence claim about a chain element at position >= B containing a formula that "shouldn't be there" (because all F-obligations should have been resolved by then). The construction doesn't provide this guarantee because:

1. The BRS only forces depths >= B-2 (when `iter_F (d+2) theta ∉ deferralClosure phi`)
2. Depths d < B-2 can be deferred indefinitely (the Lindenbaum extension may always choose F(chi) over chi)
3. No fairness or priority scheme exists for sub-maximal depths

### The Path Forward

1. **No silver bullet exists without construction changes OR a fundamentally different termination argument**
2. **Alternative A5 has the most potential**: If we can prove that the existing BRS cascade covers all depths within B steps (requires showing `iter_F (d) theta ∉ deferralClosure phi` for all relevant d), this closes the gap without changing the construction
3. **If A5 fails**, the cleanest construction change is a fairness counter (Alternative A1), which mirrors standard LTL eventuality discharge
4. **Bulldozing (Teammate A)** is equivalent to A1 in terms of the key idea but packages it differently

### Confidence Level

- **High confidence** in the exact goal states (verified via lean_goal)
- **High confidence** that no simple fix exists (confirmed by 12 prior plans)
- **Medium confidence** that Alternative A5 can work if the BRS cascade covers all depths
- **Low confidence** that any approach closes both sorries in < 5 hours
- **Medium confidence** that a fairness-counter approach (A1) can be implemented correctly in 10-15 hours

---

## Files Analyzed

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — lines 2890-3042, 3044-3160, 2720-2780
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — lines 260-380 (boundary_resolution_set)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — lines 2023-2052 (constrained_successor_restricted)
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` — lines 1060-1160 (iter_F_not_mem_deferralClosure)
- Teammate A findings: `specs/067_prove_bundle_validity_implies_provability/reports/34_teammate-a-findings.md`
- Prior team research: `specs/067_prove_bundle_validity_implies_provability/reports/34_team-research.md`
- Plan v12: `specs/067_prove_bundle_validity_implies_provability/plans/12_chain-resolution.md`
