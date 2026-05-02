# Teammate A Findings: Burgess D₀ Seed Consistency — Sorry Site Analysis

**Task**: 107 — Burgess Chronicle Construction
**Teammate**: A (Primary Angle)
**Session**: sess_1777758350_184c2f
**Date**: 2026-05-02
**File analyzed**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

---

## Key Findings

- There are exactly **5 sorry sites** in PointInsertion.lean (lines 1573, 1581, 1584, 1614, 2050). The plan's "3 remaining sorries" count refers to 3 theorem-level sorries; sites 1573/1581/1584 are all sub-goals inside a single `have` block within `burgess_D0_finite_subset_consistent`.
- The primary obstruction is **three missing helper theorems** for connecting elements of `L` to the compressed event: (1) `collect_guards_mem_of_untl`, (2) `d0_c_event_list_of_untl`, and (3) `d0_a_event_list_of_snce`. These connect the classification of φ∈L to the guard/event lists already constructed.
- The `burgess_zeta_consistent` helper (lines 1243–1337) is **fully implemented** and produces the event with all required implications. The sorry sites are in the **caller's use** of that event to discharge L-membership obligations.
- The inconsistent case (sorry 1614) is independently solvable with a simpler BX5+BX13+BX10 chain (no BX14 needed). However it currently has no implementation at all — just `sorry`.
- The `lemma_2_7_seed_consistent` sorry (2050) requires a fundamentally different event construction due to the 5th seed component `{snce(β∧eta, α)}`.
- The Burgess paper (§2.6, p.370-371) confirms the architecture in the plan is correct: collapse L via DCS conjunction closure, use BX5+BX4a+BX3a chain, derive F(event)∈A.

---

## Sorry Site Analysis

### Site 1: Line 1573 — φ∈B case in `burgess_D0_finite_subset_consistent`

**Theorem**: `burgess_D0_finite_subset_consistent` (private, consistent case)
**Context**: Inside `have h_event_implies_L : ∀ φ ∈ L, DerivationTree [event] φ`, case branch for `φ∈B`.

**Goal state** (from lean_goal):
```
⊢ False
```
Wait — the overall goal is `False` (proving inconsistency of L). The `h_event_implies_L` have block's obligation at this branch is actually `DerivationTree [event] φ` (before the rcases). The branch is inside the proof of `h_event_implies_L`. The sorry here proves `[event] ⊢ φ` for `φ∈B`.

**Available hypotheses relevant to this branch**:
- `h_ev_b : DerivationTree [] (event.imp b)` — event implies b
- `b = list_conj (β₀ :: b_list_raw)` — b is conjunction of β₀ plus all guards from L
- `collect_guards_mem_of_B h_B_dcs β L hL : ∀ φ ∈ L, φ ∈ B → φ ∈ (collect_guards ...).val`
- So if `h_B : φ ∈ B`, then `φ ∈ b_list_raw`, hence `φ ∈ b_list`
- `list_conj_implies_elem b_list φ (List.mem_cons.mpr (Or.inr h_φ_in_raw)) : ⊢ b.imp φ`

**Proof approach**:
1. Use `collect_guards_mem_of_B h_B_dcs β L hL φ hφ h_B` to get `h_φ_in_raw : φ ∈ b_list_raw`
2. Conclude `h_φ_in_b_list : φ ∈ b_list` via `List.mem_cons.mpr (Or.inr h_φ_in_raw)`
3. Use `list_conj_implies_elem b_list φ h_φ_in_b_list` to get `⊢ b.imp φ`
4. Chain: `[event] ⊢ event` → `[event] ⊢ b` (via h_ev_b) → `[event] ⊢ φ` (via the above)

**Missing infrastructure**: None — all required helpers exist. This sorry can be closed with a straightforward chain of `DerivationTree.modus_ponens` calls. The comment in the file is correct about the strategy but overcautious about `d0_guard` classicality — `collect_guards_mem_of_B` already handles this.

**Difficulty**: LOW — all pieces exist.

---

### Site 2: Line 1581 — φ=untl(β',γ') case in `burgess_D0_finite_subset_consistent`

**Theorem**: `burgess_D0_finite_subset_consistent` (private, consistent case)
**Context**: Same `have h_event_implies_L` block, case branch for `φ = Formula.untl β' γ'` with `β'∈B`, `γ'∈C` from `hL`.

**Available hypotheses**:
- `h_ev_untl : DerivationTree [] (event.imp (Formula.untl b γ_hat))` — event implies untl(b, γ̂)
- `b = list_conj b_list` where `b_list = β₀ :: b_list_raw`
- `γ_hat = list_conj c_list` where `c_list = γ₀ :: c_list_raw`
- `c_list_raw = d0_c_event_list β L hL`
- `untl_left_mono_deriv` exists (line 1164): `⊢ (φ→χ) → untl(φ,ψ) → untl(χ,ψ)` (type-level)
- `untl_right_mono_deriv` exists (line 1196): `⊢ (φ→ψ) → untl(χ,φ) → untl(χ,ψ)` (type-level)

**Proof approach**:
1. Extract: `β'` is the guard for `untl(β',γ')` in `d0_guard` — need `β' ∈ b_list_raw`
2. Use `list_conj_implies_elem b_list β' h_β'_in_b : ⊢ b.imp β'`
3. `untl_left_mono_deriv b γ_hat β' (above)` gives `⊢ untl(b,γ_hat).imp untl(β',γ_hat)`
4. Separately: need `γ' ∈ c_list_raw` (so γ̂ → γ' via list_conj_implies_elem)
5. `untl_right_mono_deriv β' γ_hat γ' (above)` gives `⊢ untl(β',γ_hat).imp untl(β',γ')`
6. Chain everything together via `imp_trans`

**Missing infrastructure (CRITICAL)**:
- `collect_guards_mem_of_untl`: theorem that if `φ = Formula.untl β' γ'` and `φ ∈ L` (not already in B), then `β' ∈ (collect_guards ...).val`. Currently only `collect_guards_mem_of_B` exists (for φ∈B case).
- `d0_c_event_list_of_untl`: theorem that if `Formula.untl β' γ' ∈ L`, then `γ' ∈ d0_c_event_list β L hL`. Currently only `d0_c_event_list_mem` exists (saying elements ARE in C, but not tracing which γ' corresponds to which untl(β',γ')).

**Exact signatures needed**:
```lean
private theorem collect_guards_mem_of_untl {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B) (β : Formula) :
    (L : List Formula) →
    (hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β) →
    ∀ β' ∈ B, ∀ γ' : Formula, Formula.untl β' γ' ∈ L →
    β' ∈ (collect_guards h_dcs β L hL).val

private theorem d0_c_event_list_of_untl {A B C : Set Formula}
    {β : Formula} {L : List Formula}
    {hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β}
    {β' γ' : Formula} (h_β' : β' ∈ B) (h_mem : Formula.untl β' γ' ∈ L) :
    (Classical.choose (Classical.choose_spec (show ∃ β'' ∈ B, ∃ γ'' ∈ C,
      Formula.untl β' γ' = Formula.untl β'' γ'' from ⟨β', h_β', γ', ...⟩)).2)
    ∈ d0_c_event_list β L hL
```

Actually the simpler formulation is just: if `h : ∃ β'' ∈ B, ∃ γ'' ∈ C, φ = Formula.untl β'' γ''`, then `Classical.choose (Classical.choose_spec h).2 ∈ d0_c_event_list β L hL`.

**Difficulty**: MEDIUM — requires proving properties of `List.filterMap` combined with Classical.choose.

---

### Site 3: Line 1584 — φ=snce(β',α') case in `burgess_D0_finite_subset_consistent`

**Theorem**: `burgess_D0_finite_subset_consistent` (private, consistent case)
**Context**: Same `have h_event_implies_L` block, case branch for `φ = Formula.snce β' α'` with `β'∈B`, `α'∈A`.

**Available hypotheses**:
- `h_ev_snce : ∀ α ∈ a_list, DerivationTree [] (event.imp (Formula.snce b α))` — event implies snce(b,α) for each α in a_list
- `a_list = d0_a_event_list β L hL`
- `snce_left_mono_deriv` exists (line 1183): `⊢ (φ→χ) → snce(φ,ψ) → snce(χ,ψ)` (type-level)

**Proof approach**:
1. Need `α' ∈ a_list` to use `h_ev_snce`
2. Then `h_ev_snce α' h_α'_in_a : ⊢ event.imp snce(b, α')`
3. Need `⊢ b.imp β'`: extract guard β' from b_list (same as sites 1/2)
4. `snce_left_mono_deriv b α' β' (above)` gives `⊢ snce(b,α').imp snce(β',α')`
5. Chain: `[event] ⊢ snce(β',α')`

**Missing infrastructure (CRITICAL)**:
- `d0_a_event_list_of_snce`: theorem that if `Formula.snce β' α' ∈ L`, then `α' ∈ d0_a_event_list β L hL`. Currently only `d0_a_event_list_mem` exists (saying elements are in A, but not tracing α' back to its snce-formula).
- Also needs `collect_guards_mem_of_untl` or a variant for snce formulas: if `φ = snce(β',α')` then `β' ∈ collect_guards output`.

**Exact signature needed**:
```lean
private theorem d0_a_event_list_of_snce {A B C : Set Formula}
    {β : Formula} {L : List Formula}
    {hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β}
    {β' α' : Formula} (h_β' : β' ∈ B) (h_α' : α' ∈ A)
    (h_mem : Formula.snce β' α' ∈ L) :
    α' ∈ d0_a_event_list β L hL
```

(Or rather: the specific α produced by Classical.choose from the snce-membership witness equals α'. This requires showing the choice is canonical when β' and α' are given directly as the witnesses.)

**Difficulty**: MEDIUM — same as site 2, requires reasoning about `List.filterMap` and Classical.choose.

**Note**: There is a subtlety with `Classical.choose` here. `d0_a_event_list` uses `Classical.choose` to extract the α from `∃ β' ∈ B, ∃ α ∈ A, φ = snce β' α`. When φ = snce β' α' literally and β'∈B and α'∈A, the chosen α might not be α' (it could be any valid witness). This means the theorem as stated above may not hold without additional assumptions. The correct approach may be to prove that for any α in the choice range, `snce(b, α) → snce(β', α)` holds (since b→β' is the only thing needed), regardless of which α was chosen.

Actually the correct formulation: we need `h_ev_snce` applied to the CHOSEN α, then use `snce_left_mono_deriv`. But what we need to CONCLUDE is `[event] ⊢ snce(β', α')`, where α' is the α from the rcases decomposition. We need to show the chosen α equals α'.

This is a genuine complication. The `d0_a_event_list` extracts the first α found by Classical.choose — if `snce β' α' ∈ L` with β'∈B, α'∈A, the chosen α may equal α'. To prove this, we'd need to unfold the filterMap and show the choice is deterministic.

**Alternative approach**: Instead of tracking α' through a_list, prove directly that `∀ α∈A, [event] ⊢ snce(b, α)` is not quite right. The snce-formulas in L have specific α values. The event's snce-implications are for the α values in `a_list` only.

The resolution: `a_list` contains exactly the Classical.choose outputs for each snce-formula in L. For `snce β' α'` in L where β'∈B, α'∈A, since `snce β' α'` is NOT in the untl-branch (checked by d0_a_event_list's first `if`), it WILL appear in a_list with its α = Classical.choose of the snce-existential. We need to show this chosen α satisfies `snce(b, chosen_α) → snce(β', α')` via right-mono — but we only have left-mono. The chosen α might NOT equal α'.

**Revised resolution**: The `h_ev_snce` gives us `event → snce(b, chosen_α_for_φ)`. But we need `event → snce(β', α')`. If chosen_α ≠ α', left_mono alone won't give us the right α. This is a deeper complication.

**Possible fix**: Redefine `d0_a_event_list` to return pairs (guard, α) instead of just α, or use a different data structure. Or: prove `chosen_α = α'` directly from the definition of Classical.choose when α' is the unique α in A for that formula.

In practice, `Classical.choose` is not injective, so this is not provable in general. The correct fix is to use an injective representation: for `snce β' α' ∈ L`, the guard β' identifies which snce-formula it is, and α' is uniquely recoverable if we know β'.

**Difficulty**: MEDIUM-HIGH — the current `d0_a_event_list` design uses Classical.choose which may not recover the exact α'. May require redesigning the helper or adding a pairing structure.

---

### Site 4: Line 1614 — `burgess_D0_finite_subset_consistent_incons`

**Theorem**: `burgess_D0_finite_subset_consistent_incons` (private, inconsistent case: β.neg∈B)

**Goal state** (from lean_goal):
```
A B C : Set Formula
h_mcs_A : SetMaximalConsistent A
_h_mcs_C : SetMaximalConsistent C
h_r3m : BurgessR3Maximal A B C
_h_gc : g_content A ⊆ C
β : Formula
_h_beta_neg_in_B : β.neg ∈ B
_h_r3 : burgessR3 A B C
⊢ SetConsistent (burgess_D0_seed A B C β)
```

**Proof approach** (per plan v52, §"For the inconsistent case"):
This is simpler than the consistent case because BX14 (separation) is not needed:
1. β.neg∈B, so β.neg is a B-element handled by the normal B-element case
2. Form b = list_conj(b_list) ∈ B, γ̂ = list_conj(c_list) ∈ C (same as consistent case)
3. BX5: untl(b∧untl(b,γ̂), γ̂) ∈ A (no need for ¬untl(b∧β,γ̂))
4. BX13 iterated enrichment for a_list
5. BX10: F(event) ∈ A
6. Event → each L element (same chain as sites 1-3)

**Key difference from consistent case**: no maximality witness (β₀, γ₀, h_neg_until₀) is available as a hypothesis here. However, we still need β₀∈B to seed the guard conjunction. Since β.neg∈B, we can use β.neg as β₀. The guard b will include β.neg.

**Alternative simpler approach**: Since β.neg∈B, untl(β.neg, γ₀)∈A for any γ₀∈C (from burgessR3). Apply BX5+BX13+BX10 directly without BX14. The event = q∧snce(q,α₁)∧...∧snce(q,αₘ) where q = (β.neg)∧untl(β.neg,γ₀). The event implies β.neg (direct conjunction elimination) without needing the (b∧β).neg route.

**Missing infrastructure**: Same set of missing helpers as sites 1-3. Plus: this theorem needs to be re-implemented from scratch (currently just `sorry` with no structure). It can reuse `burgess_D0_finite_subset_consistent` by passing β.neg as the maximality witness.

Actually: the cleanest path is to call `burgess_D0_finite_subset_consistent` with:
- β₀ := any element of B (use any b₀∈B via BurgessR3 non-emptiness, or β.neg itself)
- γ₀ := any element of C
- The `h_neg_until₀` is the tricky part: need `¬untl(β₀∧β, γ₀)∈A`. Since β.neg∈B, untl(β.neg, γ₀)∈A by burgessR3. But BX5 gives untl(β.neg∧untl(β.neg,γ₀), γ₀)∈A, NOT ¬untl(β₀∧β, γ₀)∈A.

So the reduction to the consistent case doesn't directly work. Need an independent proof.

**Difficulty**: MEDIUM — complete rewrite needed but follows same pattern, just simpler BX chain.

---

### Site 5: Line 2050 — `lemma_2_7_seed_consistent`

**Theorem**: `lemma_2_7_seed_consistent` (private)

**Goal state** (from lean_goal):
```
A B C : Set Formula
h_mcs_A : SetMaximalConsistent A
h_mcs_C : SetMaximalConsistent C
h_r3m : BurgessR3Maximal A B C
h_gc : g_content A ⊆ C
xi eta : Formula
h_until : xi.untl eta ∈ A
h_eta_not_B : eta ∉ B
⊢ SetConsistent (lemma_2_7_seed A B C xi eta)
```

**Seed structure**:
```
lemma_2_7_seed A B C xi eta =
  B ∪ {xi} ∪ {untl(β,γ) : β∈B, γ∈C} ∪ {snce(β,α) : β∈B, α∈A} ∪ {snce(β∧eta, α) : β∈B, α∈A}
```

**Proof approach** (Burgess §2.7):
The Burgess proof (p.182) reduces to showing any particular ζ = S(α,β∧η) ∧ β ∧ ξ ∧ U(γ,β) is consistent. The key steps:
1. From `h_eta_not_B` and `BurgessR3Maximal_extension_fails`, extract β₀∈B, γ₀∈C with `¬untl(γ₀, β₀∧eta)∈A` (NOTE: order is reversed compared to Burgess's A notation — in BX notation this is `¬untl(β₀∧eta, γ₀)∈A`).
2. BX5 on untl(β₀, γ₀)∈A: untl(β₀∧untl(β₀,γ₀), γ₀)∈A
3. BX14 (separation_until_mcs) with ¬untl(β₀∧eta, γ₀)∈A: produces untl(q, q∧(β₀∧eta).neg)∈A where q=β₀∧untl(β₀,γ₀)
4. BX13 iterated enrichment with A-events
5. BX10: F(event)∈A

**Fifth component challenge**: For snce(β∧eta, α)∈L, need event→snce(β∧eta, α). The event from the above chain has the form `q∧(β₀∧eta).neg∧snce(q,α₁)∧...`. 
- `snce(q, αⱼ) → snce(β∧eta, αⱼ)` via left_mono requires `⊢ q→(β∧eta)`. 
- But q = β₀∧untl(β₀,γ₀) does NOT contain eta.

This is the fundamental difficulty. The event does NOT imply eta (it implies its negation via the (β₀∧eta).neg component).

**Alternative approach for the 5th component**: Use a DIFFERENT BX chain specifically for the 5th component:
- From `untl(xi, eta)∈A` (hypothesis `h_until`), BX5 gives `untl(xi∧untl(xi,eta), eta)∈A`
- For any γ₀∈C, BX3 (right_mono) on `untl(xi,eta)` and `G(eta→β∧eta)` (with β∈B: need G(β)∈A, which requires β∈g_content(A))... this doesn't work easily.

**Plan's suggestion** (§"For lemma_2_7_seed_consistent"):
Build a second BX13 chain from `untl(xi∧b∧eta_stuff, ...)` that produces snce with guard containing β∧eta. But xi may not be in B, so the guard combination is complex.

**More direct approach**: For the 5th component `snce(β∧eta, α)`:
- The Burgess paper (Lemma 2.7 proof, p.182) notes `U(γ∧γ', β∧U(γ∧γ', β))∈A` and `U(ξ, η∧U(ξ,η))∈A` are fed to A7a (BX7 = linear_until). The surviving disjunct from BX7 is `U(β∧U(γ∧γ', β)∧ξ, θ)∈A`. Then A3a (BX13 enrichment_until) with S(α, β∧η) gives the snce content.

The key: Burgess uses the S-formula's guard being β∧η, which requires η to be in the event via the BX7 disjunction step, not from the seed's untl formulas.

**Missing infrastructure for site 5**:
- A `lemma_2_7_neg_untl_exists` theorem: extract β₀∈B, γ₀∈C with `¬untl(β₀∧eta, γ₀)∈A` from `h_eta_not_B` (this already exists conceptually from `BurgessR3Maximal_extension_fails`)
- A version of the BX5+BX7+BX14 chain that incorporates xi to get eta into the event
- Possibly a variant `lemma_2_7_zeta_consistent` analogous to `burgess_zeta_consistent` but for the 5th component

**Difficulty**: HARD — the 5th component requires the BX7 (linear_until) application that produces eta in the event. This is a genuinely new BX chain not needed for site 4.

---

## Required Helper Lemma Inventory

### Tier 1: Missing, blocking sites 1-3

#### 1. `collect_guards_mem_of_untl`
```lean
private theorem collect_guards_mem_of_untl {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B) (β : Formula) :
    (L : List Formula) →
    (hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β) →
    ∀ β' ∈ B, ∀ γ' : Formula, Formula.untl β' γ' ∈ L →
    β' ∈ (collect_guards h_dcs β L hL).val
```
**Proof**: Induction on L. For the recursive case when head = `untl(β', γ')`, d0_guard returns β' (by definition, second branch). In `collect_guards`, the guard for this element is β', so β'∈ the output list.

#### 2. `collect_guards_mem_of_snce`
```lean
private theorem collect_guards_mem_of_snce {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B) (β : Formula) :
    (L : List Formula) →
    (hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β) →
    ∀ β' ∈ B, ∀ α' : Formula, Formula.snce β' α' ∈ L →
    β' ∈ (collect_guards h_dcs β L hL).val
```
**Proof**: Same as above but for snce branch of d0_guard.

Note: lemmas 1 and 2 can be combined into a single lemma `collect_guards_mem_of_guard` that handles both untl and snce via the `d0_guard` spec.

#### 3. `d0_c_event_list_γ_mem`
```lean
private theorem d0_c_event_list_γ_mem {A B C : Set Formula}
    {β : Formula} {L : List Formula}
    {hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β}
    {β' γ' : Formula} (h_mem : Formula.untl β' γ' ∈ L)
    (h_β' : β' ∈ B) (h_γ' : γ' ∈ C) :
    γ' ∈ d0_c_event_list β L hL
```
**Difficulty**: Medium. Requires unfolding List.filterMap and showing the Classical.choose selects γ'. The issue: the existential `∃ β'' ∈ B, ∃ γ'' ∈ C, untl(β',γ') = untl(β'',γ'')` has a unique solution (β''=β', γ''=γ'), so Classical.choose gives exactly γ'. Need `Formula.untl.inj` to extract this.

**Alternative**: Instead of proving Classical.choose exactness, refactor `d0_c_event_list` to directly return `γ'` when the formula is `untl(β',γ')`.

#### 4. `d0_a_event_list_α_mem`
```lean
private theorem d0_a_event_list_α_mem {A B C : Set Formula}
    {β : Formula} {L : List Formula}
    {hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β}
    {β' α' : Formula} (h_mem : Formula.snce β' α' ∈ L)
    (h_β' : β' ∈ B) (h_α' : α' ∈ A) :
    α' ∈ d0_a_event_list β L hL
```
**Difficulty**: Same as lemma 3. Requires `Formula.snce.inj` to extract the exact α'.

**IMPORTANT CAVEAT**: This lemma requires that `Formula.snce` is injective (its constructor is injective), which should hold since Formula constructors are injective in Lean 4. Check that `Formula.snce.injEq` exists or is derivable.

---

### Tier 2: Needed for inconsistent case (site 4)

#### 5. `list_conj_mem_dcs_empty` (already exists as part of `list_conj_mem_dcs`, but need empty-list case)
Looking at the implementation (line 1121), `list_conj_mem_dcs` has cases `[]`, `[φ]`, `φ₁::φ₂::rest`. For the empty list case, `list_conj [] = bot.imp bot` which needs to be in B (since B is DCS and ⊢ bot→bot). This is covered by `dcs_contains_theorems`.

#### 6. A restructured proof for `burgess_D0_finite_subset_consistent_incons`

The inconsistent case needs its own complete proof from scratch. The cleanest approach:
- Since β.neg∈B, introduce it as a B-element (like any other B-element)
- Use BX5 on untl(β.neg, γ₀)∈A (from burgessR3 with β.neg∈B and any γ₀∈C)
- NO BX14 needed — the event q = β.neg∧untl(β.neg,γ₀) already has β.neg in it
- Apply BX13 for A-events
- BX10 extracts F(event)∈A
- The contradiction argument is: [event]⊢⊥ but event is consistent (from F(event)∈A)

But: do we need to guarantee C is nonempty? C is an MCS, so it contains top, and by seriality-plus, g_content(A)⊆C means some formulas are in C. Actually, since A is MCS and C is MCS with g_content(A)⊆C, C is automatically nonempty (contains ⊤). The `h_mcs_C.1.1` should give non-emptiness. Actually for Lindenbaum, SetConsistent implies nonempty by the seriality axiom if formulas include bot.imp bot.

This is fine — any γ₀ can be extracted from `h_mcs_C`.

---

### Tier 3: Needed for lemma_2_7_seed_consistent (site 5)

#### 7. `lemma_2_7_neg_untl_exists`
```lean
private theorem lemma_2_7_neg_untl_exists {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (eta : Formula) (h_eta_not_B : eta ∉ B) :
    ∃ β₀ ∈ B, ∃ γ₀ ∈ C, (Formula.untl (Formula.and β₀ eta) γ₀).neg ∈ A
```
**Proof**: From `BurgessR3Maximal_extension_fails` with `{eta}∪B` consistent (or inconsistent giving eta.neg∈B — handle both cases). This follows the pattern in `burgess_D0_seed_consistent` but extracts just the neg-until witness.

#### 8. `lemma_2_7_zeta_consistent` — BX7+BX5+BX13+BX10 chain
A new version of `burgess_zeta_consistent` that incorporates `untl(xi, eta)∈A` (the Until formula from lemma_2_7's hypothesis) to produce an event that implies snce(b∧eta, α) for each α∈a_list.

The Burgess proof (§2.7) uses BX7 (linear_until: `U(p,q)∧U(r,s)→U(p∧r,q∧s)∨U(p∧s,q∧s)∨U(q∧r,q∧s)`) to combine `untl(b∧untl(b,γ̂), γ̂)∈A` and `untl(xi∧untl(xi,eta), eta)∈A`, then eliminate two disjuncts to get `untl(b∧untl(b,γ̂)∧xi, θ)∈A` where θ = b∧untl(b,γ̂)∧xi∧eta. From this, BX13 enrichment adds snce(guard, α). The guard includes eta, so snce(guard, α) → snce(b∧eta, α) via left_mono.

**Difficulty**: HARD — requires the BX7 application and careful disjunct elimination.

---

## Existing Infrastructure Audit

### Available (no implementation needed)

- `list_conj` (line 1097): List conjunction. Already defined and used.
- `list_conj_implies_elem` (line 1103): ⊢ list_conj(L).imp(φ) for φ∈L. Already implemented.
- `list_conj_mem_dcs` (line 1121): DCS closed under list conjunction. Already implemented.
- `list_conj_mem_mcs` (line 1134): MCS closed under list conjunction. Already implemented.
- `consistent_of_F_mem` (line 1147): F(φ)∈A → {φ} consistent. Already implemented.
- `inconsistent_singleton_false` (line 1156): {φ} consistent ∧ DerivationTree [φ] ⊥ → False. Already implemented.
- `derivation_from_implied` (line 1061): Bridge between event→each-L-element and L⊢⊥. Already implemented.
- `burgess_zeta_consistent` (lines 1243-1337): Full BX5+BX14+BX13+BX10 chain, returns event with F(event)∈A and proofs event→b, event→β.neg, event→untl(b,γ̂), event→snce(b,α) for each α∈a_list. **FULLY IMPLEMENTED**.
- `untl_left_mono_deriv` (line 1164): Derivation-level left_mono for Until. Available.
- `untl_right_mono_deriv` (line 1196): Derivation-level right_mono for Until. Available.
- `snce_left_mono_deriv` (line 1183): Derivation-level left_mono for Since. Available.
- `collect_guards` (line 1414): Extracts B-guards from L. Available.
- `collect_guards_mem_of_B` (line 1432): If φ∈L and φ∈B, then φ∈collect_guards output. Available.
- `d0_guard` (line 1347): Returns B-guard for each D₀ element. Available.
- `d0_c_event_list` (line 1362): Extracts C-events from Until formulas in L. Available.
- `d0_c_event_list_mem` (line 1372): Elements of d0_c_event_list are in C. Available.
- `d0_a_event_list` (line 1386): Extracts A-events from Since formulas in L. Available.
- `d0_a_event_list_mem` (line 1397): Elements of d0_a_event_list are in A. Available.
- `iterated_enrichment` (line 1214): BX13 applied iteratively to produce snce(guard,α) in event. Available.
- `right_mono_until_mcs` (line 918): U(φ,ψ)∈A ∧ ⊢ψ→χ → U(φ,χ)∈A. Available.
- `separation_until_mcs` (line ?): BX14 at MCS level. Available (used in burgess_zeta_consistent).
- `self_accum_until_mcs` (line 188): BX5 at MCS level. Available.
- `until_implies_F_mcs` (line ?): BX10 at MCS level. Available.
- `untl_left_mono_thm` (RRelation.lean): BX2 at MCS level. Available.
- `snce_left_mono_thm` (RRelation.lean): BX2' at MCS level. Available.

### Gaps (need implementation)

| Lemma | Needed for | Difficulty |
|-------|-----------|-----------|
| `collect_guards_mem_of_untl` | Sites 2, 3 | Low |
| `collect_guards_mem_of_snce` | Site 3 | Low |
| `d0_c_event_list_γ_mem` | Site 2 | Medium |
| `d0_a_event_list_α_mem` | Site 3 | Medium |
| Independent proof of `burgess_D0_finite_subset_consistent_incons` | Site 4 | Medium |
| `lemma_2_7_neg_untl_exists` | Site 5 | Low |
| `lemma_2_7_zeta_consistent` (BX7 chain) | Site 5 | Hard |

---

## Recommended Approach

### Phase A: Close sites 1, 2, 3 (h_event_implies_L branches)

**Order**: Implement missing helpers first, then fill sorry sites.

1. Add `collect_guards_mem_of_untl` and `collect_guards_mem_of_snce` (or a combined version). These are inductions on L and follow the same pattern as `collect_guards_mem_of_B` but for the untl/snce branches of `d0_guard`.

2. For `d0_c_event_list_γ_mem` and `d0_a_event_list_α_mem`: the proofs require `Formula.untl.injEq` and `Formula.snce.injEq`. Verify these exist:
   ```
   lean_local_search "Formula.untl.injEq"
   lean_local_search "Formula.snce.injEq"
   ```
   If they exist, the proofs unfold the filterMap, simp the if-condition, and use injectivity to extract γ' (resp. α').

3. **Site 1** (φ∈B): Use `collect_guards_mem_of_B` (already exists) → get φ∈b_list_raw → φ∈b_list → `list_conj_implies_elem` → event→b→φ.

4. **Site 2** (φ=untl(β',γ')): Use `collect_guards_mem_of_untl` → β'∈b_list → b→β' → `untl_left_mono_deriv` → untl(b,γ̂)→untl(β',γ̂). Use `d0_c_event_list_γ_mem` → γ'∈c_list → γ̂→γ' → `untl_right_mono_deriv` → untl(β',γ̂)→untl(β',γ'). Chain event→untl(β',γ').

5. **Site 3** (φ=snce(β',α')): Use `collect_guards_mem_of_snce` → β'∈b_list → b→β'. Use `d0_a_event_list_α_mem` → α'∈a_list → event→snce(b,α'). Use `snce_left_mono_deriv` → snce(b,α')→snce(β',α'). Chain.

### Phase B: Close site 4 (inconsistent case)

Implement `burgess_D0_finite_subset_consistent_incons` as a self-contained proof:
- Pick any γ₀∈C (use `h_mcs_C` + seriality to extract, or just require an arbitrary γ₀)
- Actually: since h_mcs_C is available and C is MCS, use `SetMaximalConsistent.mem_top h_mcs_C` or equivalent to get ⊤∈C
- Set up the BX5+BX13+BX10 chain WITHOUT BX14
- Use the same `h_event_implies_L` structure but with β.neg playing the role of a B-element (not requiring the (b∧β).neg route)

### Phase C: Close site 5 (lemma_2_7_seed_consistent)

This requires the BX7 chain. Implement:
1. `lemma_2_7_neg_untl_exists` 
2. `linear_until_mcs` wrapper around BX7 (check if already exists via `lean_local_search "linear_until_mcs"`)
3. The three-way disjunction elimination (BX7 + ¬U(γ₀, β₀∧eta)∈A rules out two disjuncts)
4. The BX13 enrichment chain with eta in the guard

---

## Confidence Level

- **Site 1 (φ∈B)**: HIGH confidence that the sorry closes directly once the correct helper chain is constructed. No new lemmas needed.
- **Site 2 (φ=untl)**: HIGH confidence with `collect_guards_mem_of_untl` + `d0_c_event_list_γ_mem`. The injectivity of Formula constructors is almost certainly available.
- **Site 3 (φ=snce)**: MEDIUM-HIGH confidence. The α' tracking requires Formula constructor injectivity and careful filterMap reasoning. May need refactoring of d0_a_event_list.
- **Site 4 (inconsistent case)**: HIGH confidence. The inconsistent case is simpler and can be implemented cleanly once the event construction is understood.
- **Site 5 (lemma_2_7)**: MEDIUM confidence. The BX7 application is the most complex step. Burgess's proof is clear in the paper but the Lean formalization requires careful setup of the three-way disjunction and the guard that contains eta.

**Overall assessment**: Sites 1-4 are closable by a focused implementation session following the plan's AGENT INSTRUCTIONS exactly. Site 5 requires additional research into the BX7 chain and may need a plan revision to clarify the exact Lean formulation of the three-way disjunction elimination.
