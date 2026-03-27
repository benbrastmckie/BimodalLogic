# Risk Analysis: Seed Consistency Approaches — Task #58

**Date**: 2026-03-27
**Angle**: Risks and edge cases for each proposed approach to `constrained_successor_seed_restricted_consistent`

---

## Key Findings (Risks Identified)

### Risk 1: Approach 1 (Direct Substitution) — Structural Impossibility

**Claim**: Replace BRS elements `psi` in derivation with `psi ∨ F(psi)` (the deferral disjunction known to be in `u`).

**Why it fails**: A derivation `L ⊢ bot` uses `psi` as a *premise* (via `Assumption` rule), not as a meta-level entailment. Substituting `psi ∨ F(psi)` for `psi` is not a valid derivation transformation — the resulting "derivation" would need a disjunction elimination step, but we have no second branch (`F(psi) ⊢ bot`) to close. The disjunction only resolves `psi`'s F-obligation; it says nothing about `psi` itself.

**Edge case**: Even if `F(psi) ∈ u`, this implies `psi ∨ F(psi) ∈ u` (derivable, in deferralDisjunctions). But `psi ∨ F(psi) ⊢ psi` is *not* a theorem — it would require the right disjunct being false. Direct substitution is logically unsound.

**Verdict**: Not viable. There is no mechanism to "unwrap" a disjunction in a Hilbert-style proof without additional premises.

---

### Risk 2: Approach 2 (Deduction Theorem Elimination) — Wrong Goal Type

**Claim**: Use the deduction theorem to eliminate BRS elements one by one. If `{L_rest, psi} ⊢ bot`, then `L_rest ⊢ psi.neg`. Apply `drm_closed_under_derivation` to conclude `psi.neg ∈ u`. Recurse on `L_rest`.

**Why it fails at the inductive step**: The deduction theorem gives `L_rest ⊢ psi.neg`, which is *not* `L_rest ⊢ bot`. To reach a contradiction with `u`'s consistency, we need some subset of `u` to derive `bot`. The deduction step yields an implication, not a falsum.

**The fundamental loop**: After removing all BRS elements from `L` via iterated deduction theorem application, we are left with `L_in_u ⊢ f_k` where `f_k` is some nesting of negations of BRS elements. None of these are `bot`. We have not derived a contradiction; we have only derived that certain negations of BRS elements follow from `u`.

**Edge case — contradictory derivation from `u`**: The strategy works *only* if we can combine `L' ⊢ psi.neg` with something else in `u` to derive `bot`. The code at lines 1700–1714 sketches this: construct `L_in_u ∪ {psi_i.neg}`. Since `psi_i.neg ∈ u` (by DRM negation completeness), this set is still within `u`. But `L_in_u ∪ {psi_i.neg}` still derives some formula, not necessarily `bot`. The information that `L ⊢ bot` (the original derivation) has been "consumed" by deduction theorem steps and does not reappear.

**The induction gap**: At line 1721–1724, the current code documents this precisely: "IH gives `L_in_u ∪ {psi_1.neg, ..., psi_{k-1}.neg} ⊢ psi_k.neg`. Adding `psi_k.neg` to the context doesn't help us get `bot`." This is the genuine mathematical gap.

**Verdict**: Approach 2 gives the wrong intermediate goal. Deduction theorem eliminates the hypothesis but turns `⊢ bot` into `⊢ psi.neg`. To recover `bot`, one needs a contradictory pair, bringing us back to Approach 3.

---

### Risk 3: Approach 3 ("No Contradictory Pairs" Argument) — Needs Semantic Backing for the Critical Implication

**Claim**: The seed contains no pair `{psi, psi.neg}`. Therefore the seed is consistent.

**What is provable**: Using `neg_not_in_seed_when_in_brs` (proven, no sorry) and `u`'s consistency:
- For any `psi ∈ BRS`: `psi.neg ∉ seed` (directly proven).
- For any `psi ∈ non-BRS ⊆ u`: `psi.neg ∉ non-BRS` (since `u` is consistent, no contradictory pair `{psi, psi.neg}` fits in `u`).
- For `psi ∈ non-BRS` and `psi.neg ∈ BRS`: The BRS mutual exclusion condition (`F(psi.neg) ∉ u`) is required to block this case. This *is* provided by Fix A1.

**The missing lemma**: "A finite set with no contradictory pair is consistent" is **not generally true** in a Hilbert-style modal logic system. A set `{A, A → B, neg B}` has no contradictory pair (no `{C, C.neg}`) yet derives `bot` via modus ponens. This is the core issue stated at lines 1587–1590 of the proof:

> "In propositional/modal logic, a finite set without contradictory pairs is consistent. This metatheorem follows from compactness/satisfiability arguments but is non-trivial to formalize in full generality for our Hilbert-style proof system."

**Specific edge case — indirect inconsistency via modal axioms**: The seed includes `p_step_blocking_formulas_restricted`, which adds formulas of the form `H(neg chi).imp bot` (i.e., `neg H(neg chi)`, which is `P(chi)`). If the BRS also contains some formula `psi` such that `psi ∧ P(chi) ⊢ bot` via a modal axiom chain, the seed would be inconsistent even without a direct contradictory pair. This requires ruling out such chains.

**Verdict**: Approach 3 is sound at the level of "what we need to show" but requires a sub-lemma: "if seed has no contradictory pairs AND every finite sub-list of the seed that derives `bot` can be enlarged to a sub-list of `u` that derives `bot`, then the seed is consistent." That sub-lemma is equivalent to the original problem.

---

### Risk 4: Approach 4 (Cut-Style Transformation) — The Right Approach, But Needs a Key Missing Piece

**Claim**: Show that any `L ⊆ seed` with `L ⊢ bot` can be transformed into `L' ⊆ u` with `L' ⊢ bot`, contradicting `u`'s consistency.

**The transformation strategy** (lines 1601–1614): Strong induction on `|L_not_in_u|` (the number of elements in `L` that are not in `u`).

**Base case** (`L ⊆ u`): Immediate — `u`'s consistency gives the contradiction.

**Inductive step** (pick `psi ∈ L`, `psi ∉ u`): We have `psi ∈ BRS` (proven), so `psi.neg ∈ u` (by DRM negation completeness). The code at lines 1700–1756 reaches the point where we have both `psi ∈ L` and `psi.neg ∈ u`, but cannot proceed further.

**The missing sub-lemma**: What we need is:

> If `L ⊢ bot` and `psi ∈ L` and `psi.neg ∈ u`, then `(L.erase psi ++ [psi.neg]) ⊢ bot`.

This is **a form of the cut rule**: cut `psi` against `psi.neg` to discharge the assumption `psi` and replace it with `psi.neg`. In classical propositional logic, this holds because:
- From `L_rest, psi ⊢ bot`: by deduction theorem, `L_rest ⊢ psi.neg`.
- From `L_rest, psi.neg ⊢ psi.neg`: trivially.
- But we need `L_rest ⊢ bot` (or `L_rest, psi.neg ⊢ bot`), not just `L_rest ⊢ psi.neg`.

**Why cut does not directly apply here**: The `cut` rule (if `Γ ⊢ A` and `Γ, A ⊢ B`, then `Γ ⊢ B`) would require us to first show `L_rest ⊢ psi` (which we cannot — `psi ∉ u` so this would contradict consistency) and `L_rest, psi ⊢ bot`. The deduction theorem gives `L_rest ⊢ psi.neg`, not `L_rest ⊢ psi`.

**The classical logic resolution**: In classical logic, one can prove `(Γ, A ⊢ bot) → (Γ, neg A ⊢ bot) → (Γ ⊢ bot)` via the law of excluded middle applied to A. But here we only have the first half: `L_rest, psi ⊢ bot` (deduced from L ⊢ bot). We need `L_rest, psi.neg ⊢ bot` to apply LEM. If `L_rest, psi.neg ⊆ u` then `u` must contain a contradiction — but we need this from the original `L ⊢ bot` derivation, and we cannot get there without the other half.

**Verdict**: Approach 4 is the most structurally sound but requires a sub-lemma about "replacing BRS hypotheses with their negations" in a derivation. This sub-lemma is a form of the deduction theorem combined with the excluded middle, but the combination is non-trivial to formalize in the Hilbert-style system used here.

---

## Risk Assessment

| Approach | Likelihood of Working | Impact if Blocked | Root Cause |
|----------|----------------------|-------------------|------------|
| Direct substitution | Very low (structural impossibility) | High (approach dead) | Derivation substitution not valid |
| Deduction theorem elimination | Low (wrong goal type) | High | Gives `⊢ psi.neg`, not `⊢ bot` |
| No contradictory pairs | Medium (missing sub-lemma) | Medium | Modal logic ≠ propositional; indirect inconsistency possible |
| Cut-style transformation | Medium-High (right structure, missing piece) | High if piece missing | Need "hypothesis replacement" sub-lemma |

**The core risk across all approaches**: Each approach requires either (a) a semantic satisfiability argument (the seed has a model, hence is consistent) or (b) a proof-theoretic sub-lemma about exchanging hypotheses in a derivation. Neither is available "off the shelf" in the current codebase.

---

## Edge Cases in the BRS Construction

### Edge Case 1: Empty BRS

If `boundary_resolution_set phi u = ∅`, then `constrained_successor_seed_restricted phi u = g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u ⊆ u`. Consistency follows immediately from `u`'s consistency.

**Risk level**: None — this case is handled by the `by_cases h_all_in_u` at line 1632.

### Edge Case 2: Large BRS (Many F-Obligations at Boundary)

If many formulas `psi_1, ..., psi_k` are in BRS, the cut-style transformation must be applied `k` times. Each application requires the missing "hypothesis replacement" sub-lemma. The risk scales with BRS size, but the mathematical difficulty is the same for any `k ≥ 1`.

**Risk level**: The `k = 1` case is already beyond current formalization. Induction on `k` requires the `k = 1` base.

### Edge Case 3: BRS Element That is a Negation of Another BRS Element

**Is this possible?** No. Fix A1 (the mutual exclusion condition `F(psi.neg) ∉ u`) guarantees that `psi ∈ BRS` implies `psi.neg ∉ BRS`. The theorem `brs_mutual_exclusion` (proven, line 1379) formally establishes this.

**Risk level**: None — Fix A1 directly prevents this.

### Edge Case 4: BRS Element That is Derivable From Non-BRS Seed Elements

If `{g_content u ∪ deferralDisjunctions u ∪ p_step_blocking} ⊢ psi` for some `psi ∈ BRS`, then the seed derives both `psi` and `psi.neg` (since `psi.neg ∈ u`... wait, is it?).

Actually: `psi.neg ∉ seed` (by `neg_not_in_seed_when_in_brs`). But `psi.neg ∈ u` (by DRM negation completeness, since `psi ∉ u`). The seed does NOT contain `psi.neg`. So even if the non-BRS part derives `psi`, and `psi ∈ seed`, there is no contradiction within the seed from having `psi` derivable.

**Risk level**: Low — but this edge case shows why the "no contradictory pairs" argument is incomplete. The seed can *derive* a formula whose negation is in `u`, even if that negation is not in the seed. A derivation `L ⊢ bot` need not contain a contradictory pair `{f, f.neg}` — it suffices to contain formulas from which `bot` follows logically.

### Edge Case 5: The Deferral Disjunction `psi ∨ F(psi)` — Can This Always Be Used?

For each `psi ∈ BRS`, we have `F(psi) ∈ u`, hence `psi ∨ F(psi) ∈ deferralDisjunctions u ⊆ u`. The concern is whether this disjunction can substitute for `psi` in a proof of consistency.

**The question**: Can `psi ∨ F(psi)` replace `psi` in a derivation? No — `psi ∨ F(psi) ⊬ psi` without an additional premise (`neg F(psi)` or a case split). This is exactly why Approach 1 fails.

**When is the disjunction useful?** Only to establish the F-step condition (`psi ∨ F(psi) ∈ successor` ensures the F-obligation is handled by the Lindenbaum extension). For consistency of the *seed itself*, the disjunction does not directly help.

**Risk level**: Medium — the deferral disjunction plays no direct role in the consistency proof of the seed; it is only useful for the F-step property of the successor.

### Edge Case 6: Interaction Between Modal Axioms and BRS Elements

**Concern**: The seed contains `p_step_blocking_formulas_restricted`, which includes formulas like `H(neg chi) → bot` (i.e., `¬H(¬chi) = P(chi)`). Could a BRS element `psi` interact with a `P(chi)` formula to derive `bot`?

For this to happen, we would need `{psi, P(chi)} ⊢ bot` via some modal axiom. The only way `psi` and `P(chi)` interact is if `psi` is of the form `¬P(chi)` or `H(¬chi)`. But `psi ∈ BRS` means `F(psi) ∈ u`, so `psi` is in the subformula closure of `phi`. The formula `H(¬chi)` could in principle be in BRS if `F(H(¬chi)) ∈ u`.

**Verdict**: This interaction is not ruled out syntactically but is constrained by `u`'s consistency — since `P(chi) ∈ seed ⊆ u` (p_step_blocking is a subset of `u`), and `u` is consistent, having `P(chi)` and `H(¬chi)` together would require `{P(chi), H(¬chi)} ⊢ bot`, which contradicts `u`'s consistency if both are in `u`. If one is in BRS (not in `u`), the argument fails.

**Risk level**: Low but non-zero. A full consistency proof must address this.

---

## Mitigations

### Mitigation 1: Semantic Consistency Argument

**Strategy**: Prove the seed is satisfiable by constructing a canonical model in which all seed formulas are true. Consistency then follows from soundness.

**What is required**: A truth lemma for the subset of the seed. The non-BRS part (`g_content u ∪ deferralDisjunctions u ∪ p_step_blocking`) is true at world `u` in the canonical model. For BRS elements `psi`, truth at a successor of `u` must be established.

**Obstacle**: This is circular — we need the successor to construct the semantic model, and we need the semantic model to show the seed is consistent so we *can* construct the successor.

**Partial resolution**: The semantic argument can be made non-circular if we treat it as a "local satisfiability" argument within an already-constructed model. But the completeness proof is trying to build the canonical model, so this would require a different model (e.g., the original frame satisfying `phi`).

**Risk**: High. Semantic arguments require building or assuming a model, which is complex to formalize.

### Mitigation 2: Proof-Theoretic "Hypothesis Replacement" Lemma

**Strategy**: Prove directly: if `L ⊢ bot`, `psi ∈ L`, `psi ∉ u`, and `psi.neg ∈ u`, then there exists `L'` with `|L'_not_in_u| < |L_not_in_u|` and `L' ⊢ bot`.

**What is required**: In classical Hilbert-style logic, this reduces to: from `L_rest, psi ⊢ bot`, deduce `L_rest, psi.neg ⊢ bot` (or `L_rest ⊢ bot` directly). The key tool is LEM: `psi ∨ psi.neg` is an axiom, giving case split. In one case `psi ⊢ bot` (combine with `L_rest, psi ⊢ bot`). In the other case `psi.neg ⊢ psi.neg` trivially, but we need `L_rest, psi.neg ⊢ bot`. The second case is not available.

**The actual classical proof**: Consider `L_rest ⊢ psi.neg` (from deduction theorem). In classical logic, `psi.neg, psi ⊢ bot` (by `psi.neg = psi → bot` and modus ponens). So `psi.neg :: L_rest, psi ⊢ bot`. This doesn't close the gap.

**Alternative**: Use `Classical.em psi` to case split. In the `psi` branch, `L_rest ⊢ psi.neg` and `psi` gives `bot`. In the `psi.neg` branch, we need `L_rest, psi.neg ⊢ bot`. This second branch is not derivable from what we have.

**Correct classical resolution**: The key insight is that we DON'T need to transform the derivation — we need only derive `False` in the meta-language. We have `psi.neg ∈ u` and `u` is consistent. If we could show `u ⊢ psi` (directly), then `{psi, psi.neg} ⊆ u ⊢ bot`, contradicting consistency. But `u ⊢ psi` would require `psi ∈ u`, and `psi ∉ u` by assumption.

**The predecessor proof as a template**: The predecessor consistency proof (`constrained_predecessor_seed_restricted_consistent`, lines 3184–3304) avoids this entire problem because `constrained_predecessor_seed_restricted ⊆ u` — the predecessor seed is a subset of `u`. This is possible because predecessor BRS does not exist; the predecessor seed is just `h_content ∪ pastDeferralDisjunctions ∪ f_step_blocking`. The successor seed is fundamentally different because it contains BRS elements *outside* `u`.

**Risk**: High to formalize. The correct proof likely requires either (a) a version of cut for the Hilbert system or (b) an invocation of `Classical.em` within a `have` combined with a case analysis at the meta-level.

### Mitigation 3: Restrict to BRS ⊆ u (Fix A3)

**Strategy**: Add `chi ∈ u` back to the BRS definition, making BRS ⊆ u trivially.

**Why rejected**: This defeats the purpose of BRS — if BRS only contains elements already in `u`, it forces nothing into the successor that isn't there already. The termination argument for `restricted_bounded_witness` requires BRS elements to force resolution of F-obligations at the boundary (not defer further). Without BRS elements outside `u`, we cannot prove the bounded chain terminates.

**Risk**: High — would require re-doing the entire termination analysis.

---

## Confidence Level

**Overall**: Medium-Low

**Specific assessments**:

- The four approaches as stated are correctly diagnosed as failing (confidence: **high**).
- Fix A1 (mutual exclusion condition) is sound and prevents the `{psi, psi.neg}` ⊆ BRS case (confidence: **high**).
- The "no contradictory pairs" argument is *insufficient* on its own in modal logic (confidence: **high**).
- The cut-style transformation is the right proof strategy, but the key "hypothesis replacement" sub-lemma is non-trivial (confidence: **high**).
- There exists a valid Lean proof using `Classical.em` + careful case analysis (confidence: **medium** — plausible but requires finding the right formulation).
- A semantic argument could work but risks circularity in the canonical model construction (confidence: **low**).

**Most likely path**: The cut-style transformation (Approach 4) with the following realization: instead of trying to produce `L' ⊢ bot` by transforming the derivation, we directly apply `Classical.em psi` in the meta-language, then in the `psi ∈ u` branch, `u` is inconsistent (contradiction), and in the `psi ∉ u` branch we have `psi.neg ∈ u` by DRM maximality — but we still cannot close the goal without `L_rest ⊢ bot`.

**True path forward**: The missing ingredient is likely a Lean formalization of the classical metatheorem "if `Gamma, A ⊢ bot` and `Gamma ⊢ ¬A`, then `Gamma ⊢ bot`" — which is immediate by modus ponens (apply `¬A` to get `A → bot`, then apply to... we need `A`). Actually this requires `Gamma ⊢ A`, not `Gamma, A ⊢ bot`. The correct version is `(Gamma, A ⊢ bot) ∧ (Gamma ⊢ ¬A) → (Gamma ⊢ bot via ¬A and... no, ¬A means A → bot, to apply MP we need A)`. This is the fundamental logical gap.

The actual classical resolution in this setting is: use `h_mcs.1.2` (u's consistency) directly. We have `L ⊢ bot` with `L ⊆ seed`. We want `False`. The contradiction must come from `u`'s consistency. The ONLY way to get a list from `u` that derives `bot` is via the `drm_closed_under_derivation` mechanism — but that requires a derivation of some formula within `deferralClosure`, and `bot ∉ deferralClosure` in general.

**Bottom line**: All four approaches hit the same mathematical wall, just from different angles. The proof requires either a semantic argument or a formalized version of the classical "Lindenbaum-style" consistency argument that is currently not available as a lemma in this codebase.
