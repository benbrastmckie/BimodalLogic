# Teammate A Findings: Task 35 — Prove Remaining Sorries/Axioms

## Summary of Findings

All 7 items have been located and analyzed. They fall into three distinct difficulty tiers:

- **High confidence / straightforward**: `succ_propagates_P_not` (Item 6), structural contraction (Item 4), Box backward (Item 3)
- **Medium confidence / requires case analysis**: `succ_chain_fam_p_step` (Item 1c), `backward_witness` (Item 5)
- **Hard / requires new infrastructure**: `f_nesting_boundary` (Item 1a), `p_nesting_boundary` (Item 1b)

A critical dependency exists: Items 1a and 1b (nesting boundary axioms) are the hardest items. Items 5 (`backward_witness`) and 1c (`succ_chain_fam_p_step`) depend on infrastructure that partially already exists in the codebase and do NOT depend on each other.

---

## Item-by-Item Analysis

### Item 1a: `f_nesting_boundary`

**Location**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:583`

**Current state**: `axiom` (lines 583–586)

```lean
axiom f_nesting_boundary
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_F d phi ∈ M ∧ iter_F (d + 1) phi ∉ M
```

**What needs to be proven**: Given F(phi) ∈ M (MCS), there exists a finite depth d ≥ 1 such that F^d(phi) ∈ M but F^(d+1)(phi) ∉ M. This is the key "F-nesting must terminate" fact.

**Semantic justification**: If F^n(phi) ∈ M for all n, then M would need infinitely many distinct future formulas. Since M is a maximal consistent set over a countable language where iter_F d phi are distinct formulas of strictly increasing complexity, having all of them in M would imply the set {neg(iter_F d phi) | d ∈ Nat} is entirely outside M, forcing iter_F d phi to be independent of each other — but this leads to a contradiction with consistency.

**Formal proof approach**: By strong induction on `phi.complexity`:
- Define d as the largest k ≥ 1 such that iter_F k phi ∈ M.
- Existence of d: Suppose for contradiction iter_F k phi ∈ M for all k ≥ 1. Then by MCS negation completeness, neg(iter_F k phi) ∉ M for all k. The set {iter_F k phi | k ≥ 1} ⊆ M would be infinite. Each iter_F k phi has complexity `phi.complexity + k`, so they are pairwise distinct formulas. This means M contains infinitely many formulas, which is fine (M is a set over a countable language), but now all iter_F k phi ∈ M means applying MCS implication repeatedly... the issue is that we need the "no infinite F-chain" argument. This requires either: (a) a measure argument showing iter_F (d+1) phi having strictly greater complexity than iter_F d phi, combined with consistency bounding via some "global finite subformula property", or (b) a semantic argument via model theory. Neither is trivial to formalize directly in Lean 4.

**Alternative approach**: The key insight is that in an MCS, if F(phi) ∈ M and FF(phi) ∈ M and FFF(phi) ∈ M... we can build an infinite chain of successor MCS worlds, each containing phi. But this is not a contradiction since the model is infinite. The standard proof in temporal logic actually uses a **Fischer-Ladner closure argument**: the closure of phi is finite, so only finitely many distinct iter_F d phi formulas exist in the closure. Since M ∩ closure(phi) is finite (closure is finite), there can be only finitely many d with iter_F d phi ∈ M.

**Key question**: Does the codebase define a Fischer-Ladner closure or subformula closure? Let me check — there's a `complexity` function on `Formula` that assigns `iter_F d phi` complexity `phi.complexity + d`. Since `phi.complexity` is finite and `iter_F d phi` are all distinct, no finite bound on d is directly derivable from complexity alone without additional finiteness argument.

**Actual approach that works**: The correct approach uses the fact that MCS extends a consistent set of a *countable* language over *finite formulas*. The Fischer-Ladner closure `FL(phi)` of any formula phi is **finite**. In M, only formulas from FL(phi) appear as F-iterations (since iter_F d phi ∉ FL(phi) for large d once d > modal depth of phi). Therefore the sequence must eventually leave M.

**Estimated complexity**: HIGH — requires either defining modal depth / Fischer-Ladner closure or using a finiteness argument. This is not a simple induction; it requires new infrastructure.

**Confidence**: Medium — the approach is clear semantically but formalizing it in Lean requires non-trivial setup.

---

### Item 1b: `p_nesting_boundary`

**Location**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:695`

**Current state**: `axiom` (lines 695–698)

```lean
axiom p_nesting_boundary
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_P d phi ∈ M ∧ iter_P (d + 1) phi ∉ M
```

**What needs to be proven**: Symmetric to `f_nesting_boundary` for the past direction.

**Proof approach**: Identical approach to `f_nesting_boundary`, mutatis mutandis (F ↔ P, future ↔ past). Once `f_nesting_boundary` is proven, `p_nesting_boundary` follows by the same proof with all F/G replaced by P/H.

**Estimated complexity**: HIGH (same as 1a, but once 1a done, this is copy-paste + dual substitution)

**Confidence**: Medium (depends on 1a being solved first)

**Dependency**: Identical to f_nesting_boundary; proves automatically once that proof strategy is known.

---

### Item 1c: `succ_chain_fam_p_step`

**Location**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:335`

**Current state**: `axiom` (lines 335–337)

```lean
axiom succ_chain_fam_p_step (M0 : SerialMCS) (n : Int) :
    p_content (succ_chain_fam M0 (n + 1)) ⊆
    (succ_chain_fam M0 n) ∪ p_content (succ_chain_fam M0 n)
```

**What needs to be proven**: For any index n, the P-content of position n+1 flows to position n or its P-content (i.e., P-obligations propagate backward through the chain).

**Proof approach**: Case analysis on `n`:

**Case n = Int.ofNat k (i.e., n ≥ 0)**:
- `succ_chain_fam M0 (n+1) = forward_chain M0 (k+1)` and `succ_chain_fam M0 n = forward_chain M0 k`
- `forward_chain M0 (k+1) = successor_from_deferral_seed (forward_chain M0 k) ...`
- This requires showing `p_content(successor(u)) ⊆ u ∪ p_content(u)` for any `u` in the forward chain.
- There is **no** `successor_satisfies_p_step` theorem — only `successor_satisfies_f_step` exists.
- This case requires new infrastructure or another `predecessor_f_step_axiom`-style lemma for the **successor**'s P-step.

**Case n = Int.negSucc 0 (i.e., n = -1)**:
- `succ_chain_fam M0 0 = backward_chain M0 0 = M0.world`
- `succ_chain_fam M0 (-1) = backward_chain M0 1`
- `p_content(backward_chain M0 0) ⊆ backward_chain M0 1 ∪ p_content(backward_chain M0 1)` — this is exactly `backward_chain_p_step M0 0`.

**Case n = Int.negSucc (k+1) (i.e., n ≤ -2)**:
- `succ_chain_fam M0 (n+1) = backward_chain M0 (k+1)` and `succ_chain_fam M0 n = backward_chain M0 (k+2)`
- `p_content(backward_chain M0 (k+1)) ⊆ backward_chain M0 (k+2) ∪ p_content(backward_chain M0 (k+2))` — this is `backward_chain_p_step M0 (k+1)`.

**Key blocker**: The forward chain case (n ≥ 0) requires a "successor's P-step" lemma, which doesn't exist. The successor is built from `successor_from_deferral_seed`, and the deferral seed is for F-obligations, not P. The P-step for the successor would follow from temporal duality — specifically, since the successor includes g_content(u) and satisfies Succ, we can derive P-step through an argument involving the axiom temp_a (φ → G(P(φ))).

**Estimated complexity**: MEDIUM — the backward cases are easy (use `backward_chain_p_step`), but the forward case needs a new lemma `successor_satisfies_p_step` in SuccExistence.lean, which itself requires a semantic argument about the successor construction.

**Confidence**: Medium-high for backward cases; medium for forward case (may need another axiom or careful proof using duality).

---

### Item 3: Box backward direction (SuccChainTruth.lean:254)

**Location**: `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean:254`

**Current state**: `sorry` with comment: `-- Box backward not needed for completeness; requires modal coherence (BFMCS)`

```lean
· -- Backward: forall sigma in Omega, truth sigma t psi -> Box psi in MCS
  intro h_all
  -- For singleton Omega, psi true at unique history -> psi in MCS by IH
  ...
  sorry -- Box backward not needed for completeness; requires modal coherence (BFMCS)
```

**What needs to be proven**: If psi is true at all histories in Omega (the singleton {succ_chain_history M0}), then Box(psi) ∈ MCS at time t.

**Analysis**: The sorry note is explicit that this is **not needed for completeness**. For the singleton Omega model, "for all sigma in Omega" means just `psi` is true at `succ_chain_history M0` at time t. But `psi ∈ MCS` does not imply `Box(psi) ∈ MCS` in general — Box is not just a universal quantifier over a singleton.

The full proof requires BFMCS (Bimodal Frame Canonical Model Semantics) completeness with respect to multiple histories, not a singleton. This is a genuinely hard item requiring the full multi-world canonical model.

**Estimated complexity**: HIGH — requires fundamental extension of the completeness argument to multi-history models (BFMCS), far beyond the current task scope. The comment in the code explicitly marks it as not needed for completeness.

**Recommendation**: Leave this sorry as-is for this task, matching the code comment. It is explicitly out of scope for the current completeness pipeline.

**Confidence**: High that it should be skipped for task 35.

---

### Item 4: Structural contraction (SuccChainCompleteness.lean:109)

**Location**: `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean:109`

**Current state**: `sorry` in `not_provable_implies_neg_set_consistent`

**What needs to be proven**: If `L ⊢ ⊥` where all elements of L are `φ.neg`, then `[φ.neg] ⊢ ⊥`.

The goal is: given `d_bot : L ⊢ Formula.bot` where `h_L_sub : ∀ x ∈ L, x = φ.neg`, derive `[φ.neg] ⊢ Formula.bot`.

**Proof approach**: This is structural contraction on lists. The proof proceeds by induction on the derivation tree `d_bot`:
- If `L = []`, then `[] ⊢ ⊥`, so axiom `[] ⊢ ⊥ → [φ.neg] ⊢ ⊥` by weakening (vacuously).
- If `L ≠ []`, then since all elements are `φ.neg`, L = [φ.neg, φ.neg, ..., φ.neg].
- We need to show that any derivation using [φ.neg, φ.neg, ...] can be replicated using [φ.neg].
- This follows from the fact that context lookup (assumption rule) only needs the formula to appear once.

**Available tools**: The codebase has `Bimodal.ProofSystem.DerivationTree`. Let me verify weakening is available.

**Key lemma needed**: `context_contraction : (∀ x ∈ L, x = φ) → (L ⊢ ψ) → ([φ] ⊢ ψ)` or alternatively `weakening : Γ ⊆ Δ → (Γ ⊢ φ) → (Δ ⊢ φ)` — which direction?

Looking at the code comments: "Weakening says: Γ ⊆ Δ → Γ ⊢ φ → Δ ⊢ φ (bigger is stronger)." We have `L ⊢ ⊥` and need `[φ.neg] ⊢ ⊥`. Since all elements of L are φ.neg, L ⊆_multiset [φ.neg,...] but as a set L ⊆ {φ.neg} = {x | [φ.neg] contains x}. If weakening means Γ ⊆_set Δ → Γ ⊢ → Δ ⊢, we have L ⊆_set {φ.neg} so `[φ.neg]` as context covers L.

Actually the direction needed is: since all elements of L are copies of φ.neg, `{φ.neg}` covers L as a **set**. A derivation using context L only uses φ.neg as assumptions. So it should be expressible with just [φ.neg]. This is **contraction** (the structural rule): from `[φ, φ] ⊢ ψ` derive `[φ] ⊢ ψ`.

**Estimated complexity**: MEDIUM — requires proving contraction for DerivationTree by induction on the tree, or showing that derivation contexts are set-based. Need to check if contraction already exists.

**Confidence**: High — this is a standard structural rule and should be provable.

---

### Item 5: `backward_witness`

**Location**: `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean:721`

**Current state**: `sorry` at line 785

```lean
theorem backward_witness
    (u v : Set Formula) (phi : Formula) (n : Nat)
    (h_Pn : iter_P n phi ∈ v)
    (h_Pn1_not : iter_P (n + 1) phi ∉ v)
    (h_task : CanonicalTask_backward_MCS_P u n v) :
    phi ∈ u := by
  ...
  sorry
```

**What needs to be proven**: The P-direction analog of `bounded_witness`. Given P^n(phi) ∈ v, P^(n+1)(phi) ∉ v, and a backward MCS chain from u to v of length n, then phi ∈ u.

**Available infrastructure**:
- `single_step_forcing_past` is proved (lines 354–497, though itself has a `sorry` at line 497!)
- `succ_propagates_P_not` (Item 6, also currently sorry — see below)
- `CanonicalTask_backward_MCS_P` is defined with `.step_inv`
- The inductive structure mirrors `bounded_witness` exactly

**Wait — critical finding**: `single_step_forcing_past` has a `sorry` at line 497 of `SuccRelation.lean`. This means Item 5 (`backward_witness`) DEPENDS on Item 6 (`succ_propagates_P_not`).

**Proof structure** (once Item 6 is resolved):
```
| succ k ih =>
  obtain ⟨w, h_mcs_u, h_mcs_w, h_succ, h_p_step, h_chain⟩ := CanonicalTask_backward_MCS_P.step_inv h_task
  -- iter_P k phi ∈ w (by single_step_forcing_past on v with chain structure)
  -- iter_P (k+1) phi ∉ w (by succ_propagates_P_not on h)
  -- Apply IH
```

**The direction confusion in the current sorry**: The existing proof attempt is confused about chain direction. The key is: `CanonicalTask_backward_MCS_P u (k+1) v` means u is k+1 backward steps from v, i.e., u <- w1 <- ... <- w_k <- v (in Succ direction: v -> w_k -> ... -> u). The step_inv gives `Succ u w` and `CanonicalTask_backward_MCS_P w k v`. So w is directly "to the right" of u in Succ order (u is predecessor of w), and w is k steps backward from v.

For the inductive step: we have `iter_P (k+1) phi = P(iter_P k phi) ∈ v` and `iter_P (k+2) phi ∉ v`. We need `iter_P k phi ∈ w`.

The chain from w to v means Succ(w → w₁ → ... → v). So v is "ahead" of w in Succ order. We need to propagate the P-obligation from v backward through the chain to get iter_P k phi ∈ w. But the h_chain is CanonicalTask_backward_MCS_P w k v, so it gives a backward path.

Actually, the right approach: apply the IH on a sub-problem. What we need is that iter_P k phi ∈ w and iter_P (k+1) phi ∉ w. The latter follows from `succ_propagates_P_not`. But iter_P k phi ∈ w requires knowing about how the chain from w to v propagates. The trick is: by `h_p_step`, `p_content(w) ⊆ u ∪ p_content(u)`, but that's the wrong direction — we need content at v to propagate to w.

**Revised approach**: The chain `CanonicalTask_backward_MCS_P w k v` with `h_Pn : iter_P (k+1) phi ∈ v` (note: iter_P k phi ∈ v isn't directly given). Wait — we have `iter_P (k+1) phi = P(iter_P k phi) ∈ v`. We need `iter_P k phi ∈ w`. Since `h_chain : CanonicalTask_backward_MCS_P w k v` means there is a backward chain from w of length k reaching v. But this is not the right induction structure.

Actually, `backward_witness` should be applied to `(w, v, iter_P k phi, k, ...)` by the IH — we need `iter_P k (iter_P k phi) ∈ v` and `iter_P (k+1) (iter_P k phi) ∉ v`... which would be `iter_P (2k) phi` etc. That's not right either.

**Correct understanding**: The existing `bounded_witness` proof (the F-direction analogue) works by having `iter_F (k+1) phi ∈ u` and deriving `iter_F k phi ∈ w` via `single_step_forcing` with u as the "starting" world going to w. By contrast, in `backward_witness`, we have `iter_P (k+1) phi ∈ v` (at the "end" world) and need phi ∈ u (at the "start"). So the induction should be going from the END (v) backward to u.

The correct induction: `backward_witness u v phi (k+1) h_Pn h_Pn1_not h_task` should:
1. Extract u, w from h_task: Succ u w and CanonicalTask_backward_MCS_P w k v
2. Show iter_P k phi ∈ w and iter_P (k+1) phi ∉ w
3. Apply IH: phi ∈ u... wait, IH gives phi ∈ u from iter_P k phi ∈ w, but the IH applies backward_witness with the *chain from u to w*, not w to v.

The **correct** reformulation: `backward_witness u v phi n` requires `CanonicalTask_backward_MCS_P u n v` meaning u is n steps BEFORE v. The step constructor says: u -> w is Succ (u is predecessor of w), w is k steps before v. So u -> w -> ... -> v. We want phi ∈ u.

Using `single_step_forcing_past` on w (which has iter_P k phi ∈ w and iter_P (k+1) phi ∉ w) with Succ u w, we get phi ∈ u.

But to apply this, we first need iter_P k phi ∈ w and iter_P (k+1) phi ∉ w. The former can be obtained by inductive application on (w, v, iter_P 0 phi, k) but iter_P 0 phi = phi, not iter_P k phi...

The correct recursive application should be: `backward_witness w v (iter_P 0 phi) k (showing iter_P k (iter_P 0 phi) = iter_P k phi ∈ v, etc.)` — yes, this works! `iter_P k phi = iter_P k (iter_P 0 phi)`, so by IH on (w, v, phi, k) with chain h_chain: CanonicalTask_backward_MCS_P w k v, premises iter_P k phi ∈ v and iter_P (k+1) phi ∉ v. We get phi ∈ w. Then apply single_step_forcing_past with Succ u w to get... phi ∈ u directly only if iter_P 1 phi = P(phi) ∉ w. But we may not know that.

Actually: `backward_witness w v phi k h_Pk_in_v h_Pk1_not_v h_chain` gives `phi ∈ w` from the IH (where k steps, chain from w to v). Then `single_step_forcing_past u w phi (P(phi) ∈ w? ← need this!) ...`. Wait, we don't know P(phi) ∈ w from this IH.

Actually the IH gives `iter_P 0 phi = phi ∈ w` from iter_P k phi ∈ v. But single_step_forcing_past needs P(phi) ∈ w (= iter_P 1 phi ∈ w) and PP(phi) ∉ w.

I think the correct statement is: `backward_witness` should be more carefully structured. The key insight from `bounded_witness` is that it moves the formula **step by step** from start to end, each time using single_step_forcing to peel one F-layer. For backward_witness, we need to move from end to start, peeling one P-layer each time — and this requires knowing P(iter_P k phi) ∈ intermediate_world, which requires propagating from the end.

**Revised proof strategy**: By induction on n:
- Base: n=0, phi ∈ v = u (base case of CanonicalTask_backward_MCS_P).
- Succ k: We have iter_P (k+1) phi ∈ v, iter_P (k+2) phi ∉ v, and Succ u w plus chain w→v of k steps (h_chain : CanonicalTask_backward_MCS_P w k v).
  - By `succ_propagates_P_not w v h_mcs_w h_mcs_v (CanonicalTask_backward_MCS_P gives Succ w next_w ...) (iter_P k phi) h_PP_not_v` → iter_P (k+1) phi ∉ w. **BUT**: succ_propagates_P_not requires Succ between adjacent chain elements in the w→v chain, not directly w and v. This is the key difficulty.

**Proposed working proof**:
The cleanest approach is a **helper lemma**: for CanonicalTask_backward_MCS_P w k v, if iter_P (k+1) phi ∉ v then iter_P (k+1) phi ∉ w... but this isn't true (w has MORE P-nesting than v).

Actually the correct approach needs `succ_propagates_P_not` propagating THROUGH the chain, not just one step. This means we need a chain-level P-propagation lemma: "if iter_P (n+1) phi ∉ v and CanonicalTask_backward_MCS_P w n v then iter_P 1 phi ∉ w" — which is itself what backward_witness morally says.

**Estimated complexity**: MEDIUM-HIGH — the proof structure is non-obvious. The key insight is that once `succ_propagates_P_not` (Item 6) is proved, the inductive argument for backward_witness can be assembled, but the chain direction requires careful reasoning about which world has which formula.

**Confidence**: Medium — depends strongly on Item 6 being proved, and the inductive structure needs care.

---

### Item 6: `succ_propagates_P_not`

**Location**: `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean:665` (sorry at line 497 of SuccRelation.lean — but this is within `single_step_forcing_past`)

Wait — re-checking: the `sorry` at line 497 is INSIDE `single_step_forcing_past`, not `succ_propagates_P_not` itself. Let me re-read:

`succ_propagates_P_not` is at line 665 of `CanonicalTaskRelation.lean` and is PROVEN (lines 665–689 show a complete proof without sorry). The `sorry` at line 497 of `SuccRelation.lean` is inside `single_step_forcing_past`.

**Corrected location**: `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — `single_step_forcing_past` has the sorry at line 497.

**What needs to be proven** (in `single_step_forcing_past`):
Steps 1–5 are complete (PP(phi) ∉ v → H(neg phi) ∈ u and P(phi) ∉ u). Step 6 needs:
`p_content(v) ⊆ u ∪ p_content(u)` — the P-step property for abstract Succ.

The existing proof has reached `h_phi_in_p_content_v : phi ∈ p_content v` and `h_P_not_u : Formula.some_past phi ∉ u` and needs to conclude `phi ∈ u`.

**Proof gap**: The issue is that Succ(u, v) gives f-step and g-persistence, but not p-step. The p-step property (`p_content(v) ⊆ u ∪ p_content(u)`) is NOT in the abstract Succ definition — it's only available for predecessor-constructed worlds via `predecessor_satisfies_p_step`.

**Options**:
1. **Add p-step to Succ definition**: Change `def Succ` to include `p_content v ⊆ u ∪ p_content u`. This is a significant API change.
2. **Prove abstractly from existing Succ axioms**: Try to derive p-step from g-persistence + f-step + MCS properties. This may require `temp_a_past` (P(phi) → H(P(phi))?) or similar.
3. **Change single_step_forcing_past to require p-step as extra hypothesis**: Add `h_p_step : p_content v ⊆ u ∪ p_content u` as a parameter.
4. **Use a succ_chain-specific version**: Instead of proving for abstract Succ, prove directly for succ_chain_fam using the concrete construction.

**Estimated complexity**: MEDIUM-HIGH — requires either extending the Succ definition or finding a way to derive p-step from existing properties. The most surgical approach is option 3 (add p_step hypothesis), which matches how `CanonicalTask_backward_MCS_P` already carries `h_p_step` in its step constructor.

**Confidence**: Medium — the approach is clear (option 3 is cleanest), but needs API changes that may cascade.

---

## Recommended Proof Order

Given dependencies, the following order minimizes blockers:

1. **First**: Item 4 (structural contraction in SuccChainCompleteness.lean:109) — independent, medium complexity.
2. **Second**: Item 6 (single_step_forcing_past sorry in SuccRelation.lean:497) — add p_step hypothesis or modify Succ definition.
3. **Third**: Item 5 (backward_witness in CanonicalTaskRelation.lean:785) — depends on Item 6.
4. **Fourth**: Item 1c (succ_chain_fam_p_step) — the backward cases use existing infrastructure; forward case needs new lemma.
5. **Fifth**: Item 1a (f_nesting_boundary) — hardest, requires Fischer-Ladner closure or modal depth argument.
6. **Sixth**: Item 1b (p_nesting_boundary) — follows from Item 1a by symmetry.
7. **Skip**: Item 3 (Box backward in SuccChainTruth.lean:254) — explicitly noted as not needed for completeness.

---

## Key Dependencies/Blockers

| Item | Depends On | Blocks |
|------|-----------|--------|
| 1a (f_nesting_boundary) | New infrastructure (modal depth / Fischer-Ladner closure) | 1b |
| 1b (p_nesting_boundary) | 1a | (indirectly: backward P coherence) |
| 1c (succ_chain_fam_p_step) | `successor_satisfies_p_step` (new lemma needed in SuccExistence.lean) | `backward_witness` (via CanonicalTask_backward_MCS_P) |
| 3 (Box backward) | BFMCS completeness (out of scope) | Nothing in current pipeline |
| 4 (contraction) | None (need contraction lemma on DerivationTree) | not_provable_implies_neg_set_consistent |
| 5 (backward_witness) | Item 6 (single_step_forcing_past) | P-direction coherence in SuccChainFMCS |
| 6 (single_step_forcing_past) | Either new Succ def or p_step hypothesis | 5 (backward_witness) |

---

## Confidence Assessment

| Item | Location | Confidence | Notes |
|------|----------|-----------|-------|
| 1a f_nesting_boundary | SuccChainFMCS.lean:583 | Low-Medium | Needs new infrastructure (modal depth / Fischer-Ladner) |
| 1b p_nesting_boundary | SuccChainFMCS.lean:695 | Low-Medium | Copy of 1a; depends on 1a |
| 1c succ_chain_fam_p_step | SuccChainFMCS.lean:335 | Medium | Backward cases easy; forward case needs new lemma |
| 3 Box backward | SuccChainTruth.lean:254 | High (skip) | Not needed for completeness; explicitly flagged |
| 4 Contraction | SuccChainCompleteness.lean:109 | High | Standard structural rule, should be provable |
| 5 backward_witness | CanonicalTaskRelation.lean:785 | Medium | Depends on Item 6; inductive structure needs care |
| 6 single_step_forcing_past | SuccRelation.lean:497 | Medium-High | Add p_step hypothesis or modify Succ def |

---

## Template Proofs Available

- `bounded_witness` (CanonicalTaskRelation.lean:541) — exact template for `backward_witness`, mutatis mutandis
- `single_step_forcing` (SuccRelation.lean:233) — template for `single_step_forcing_past`
- `succ_propagates_F_not` (CanonicalTaskRelation.lean:496) — template for `succ_propagates_P_not` (which is actually already PROVED in CanonicalTaskRelation.lean:665)
- `backward_chain_p_step` (SuccChainFMCS.lean:264) — directly applicable for negative-index case of `succ_chain_fam_p_step`
- `predecessor_satisfies_p_step` (SuccExistence.lean:573) — model for proving `successor_satisfies_p_step` (needed for positive-index case of succ_chain_fam_p_step)
- `neg_FF_implies_GG_neg_in_mcs` (SuccRelation.lean:142) — dual: `neg_PP_implies_HH_neg_in_mcs` already exists
- `succ_propagates_F_not` proof pattern: neg_FF → GG_neg → G_neg in g_content → G_neg in w → F_not_w

## Important Correction

`succ_propagates_P_not` (CanonicalTaskRelation.lean:665) is **already proved** (no sorry there). The sorry for Item 6 is inside `single_step_forcing_past` at SuccRelation.lean:497.
