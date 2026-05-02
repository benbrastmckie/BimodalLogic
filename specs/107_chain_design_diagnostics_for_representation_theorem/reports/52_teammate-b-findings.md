# Teammate B Findings: BX Axiom Infrastructure and Derivation-Level Tools

**Task**: 107 — Burgess Chronicle Construction
**Session**: sess_1777758350_184c2f
**Date**: 2026-05-02

---

## Key Findings

- All BX axioms relevant to the seed consistency proof (BX5, BX7, BX10, BX13, BX14) are fully
  defined in `Axioms.lean` and have MCS-level wrappers already present in `PointInsertion.lean`.
- The derivation-level infrastructure is more complete than expected: `untl_left_mono_deriv`,
  `snce_left_mono_deriv`, `untl_right_mono_deriv`, `list_conj_implies_elem`, `derivation_from_implied`,
  and `iterated_enrichment` all exist and are fully proved.
- Four sorry sites remain in `PointInsertion.lean`: three in `burgess_D0_finite_subset_consistent`
  (lines 1573, 1581, 1584) and one in `lemma_2_7_seed_consistent` (line 2050).
- The three sorries in `burgess_D0_finite_subset_consistent` are all in the "Step 5: event implies
  each element of L" block. The supporting infrastructure (`collect_guards_mem_of_B`,
  `list_conj_implies_elem`, `untl_left_mono_deriv`, `snce_left_mono_deriv`, `untl_right_mono_deriv`)
  needed to close them is already present in the same file.
- The `lemma_2_7_seed_consistent` sorry (line 2050) requires the BX5+BX14+BX13+BX10 chain applied
  to the Lemma 2.7 seed structure. The chain itself is fully proved for the 2.6 seed — it needs
  adaptation for the 2.7 seed's different beta/eta split.
- The `Formula` type has `untl` and `snce` as primitive constructors, plus derived `and`, `neg`,
  `or`, `some_future`, `some_past`, `all_future`, `all_past`. No `Formula.top` — it is `bot.neg`.

---

## BX Axiom Inventory

All in `Theories/Bimodal/ProofSystem/Axioms.lean`, namespace `Bimodal.ProofSystem`.

| BX Name | Lean Axiom Constructor | Type Signature | Level |
|---------|------------------------|----------------|-------|
| BX5 | `self_accum_until` | `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` | Axiom schema |
| BX5' | `self_accum_since` | `(φ S ψ) → ((φ ∧ (φ S ψ)) S ψ)` | Axiom schema |
| BX6 | `absorb_until` | `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)` | Axiom schema |
| BX6' | `absorb_since` | `(φ S (φ ∧ (φ S ψ))) → (φ S ψ)` | Axiom schema |
| BX7 | `linear_until` | `(φ U ψ) ∧ (χ U θ) → ((φ∧χ) U (ψ∧θ)) ∨ ((φ∧χ) U (ψ∧χ)) ∨ ((φ∧χ) U (φ∧θ))` | Axiom schema |
| BX7' | `linear_since` | Mirror of BX7 | Axiom schema |
| BX10 | `until_F` | `(φ U ψ) → F(ψ)` | Axiom schema |
| BX10' | `since_P` | `(φ S ψ) → P(ψ)` | Axiom schema |
| BX13 | `enrichment_until` | `p ∧ untl(φ,ψ) → untl(φ, ψ ∧ snce(φ,p))` | Axiom schema |
| BX13' | `enrichment_since` | `p ∧ snce(φ,ψ) → snce(φ, ψ ∧ untl(φ,p))` | Axiom schema |
| BX14 | `separation_until` | `untl(q,p) → ¬untl(r,p) → untl(q, q∧¬r)` | Axiom schema |
| BX14' | `separation_since` | Mirror of BX14 | Axiom schema |
| BX2 | `left_mono_until` | `(φ→χ) ∧ G(φ→χ) → (φ U ψ) → (χ U ψ)` | Axiom schema |
| BX2G | `left_mono_until_G` | `G(φ→χ) → (φ U ψ) → (χ U ψ)` | Axiom schema |
| BX2' | `left_mono_since` | Mirror of BX2 | Axiom schema |
| BX2H | `left_mono_since_H` | `H(φ→χ) → (φ S ψ) → (χ S ψ)` | Axiom schema |
| BX3 | `right_mono_until` | `G(φ→ψ) → (χ U φ) → (χ U ψ)` | Axiom schema |
| BX3' | `right_mono_since` | Mirror of BX3 | Axiom schema |
| BX4 | `connect_future` | `φ → G(P(φ))` | Axiom schema |
| BX4' | `connect_past` | `φ → H(F(φ))` | Axiom schema |
| BX12 | `F_until_equiv` | `F(φ) → (⊤ U φ)` | Axiom schema |
| BX12' | `P_since_equiv` | `P(φ) → (⊤ S φ)` | Axiom schema |
| BX1 | `serial_future` | `⊤ → F(⊤)` | Axiom schema |
| BX1' | `serial_past` | `⊤ → P(⊤)` | Axiom schema |
| BX11 | `temp_linearity` | `F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)` | Axiom schema |
| BX11' | `temp_linearity_past` | Mirror of BX11 | Axiom schema |

**Note**: BX7a (Burgess's original A7a with fixed event in all disjuncts) is REMOVED as unsound
under open guard semantics. The current BX7 is the correct version where witnesses are linearly
ordered but the events differ per disjunct.

**Note**: BX8 (until_step), BX9 (until_elim) are REMOVED as unsound under open guard (t,s).

---

## Derivation-Level Tool Inventory

All the following are present and proved (no sorry) in `PointInsertion.lean`:

| Tool Name | Location | Type | Purpose |
|-----------|----------|------|---------|
| `untl_left_mono_deriv` | PointInsertion.lean:1164 | `⊢ φ→χ` → `⊢ untl(φ,ψ) → untl(χ,ψ)` | Derivation-level BX2 |
| `snce_left_mono_deriv` | PointInsertion.lean:1183 | `⊢ φ→χ` → `⊢ snce(φ,ψ) → snce(χ,ψ)` | Derivation-level BX2' |
| `untl_right_mono_deriv` | PointInsertion.lean:1196 | `⊢ φ→ψ` → `⊢ untl(χ,φ) → untl(χ,ψ)` | Derivation-level BX3 |
| `list_conj_implies_elem` | PointInsertion.lean:1103 | `φ ∈ L` → `⊢ list_conj(L) → φ` | Conjunction elimination |
| `list_conj_mem_dcs` | PointInsertion.lean:1121 | all φ∈L in B (DCS) → `list_conj(L) ∈ B` | DCS conjunction |
| `list_conj_mem_mcs` | PointInsertion.lean:1134 | all φ∈L in A (MCS) → `list_conj(L) ∈ A` | MCS conjunction |
| `derivation_from_implied` | PointInsertion.lean:1061 | If Γ⊢φ for each φ∈L, and L⊢ψ, then Γ⊢ψ | List-level cut |
| `iterated_enrichment` | PointInsertion.lean:1214 | Applies BX13 repeatedly for a list of A-elements | BX13 chain |
| `self_accum_until_mcs` | PointInsertion.lean:188 | `untl(γ,β) ∈ A` → `untl(γ∧untl(γ,β), β) ∈ A` | BX5 at MCS level |
| `separation_until_mcs` | PointInsertion.lean:976 | BX14 at MCS level | BX14 at MCS level |
| `enrichment_until_mcs` | PointInsertion.lean:988 | BX13 at MCS level | BX13 at MCS level |
| `until_implies_F_mcs` | PointInsertion.lean:1000 | `untl(φ,ψ) ∈ A` → `F(ψ) ∈ A` | BX10 at MCS level |
| `until_F_mcs` | PointInsertion.lean:179 | Same as above (public alias) | BX10 at MCS level |
| `right_mono_until_mcs` | PointInsertion.lean:918 | `⊢ ψ→χ` and `untl(φ,ψ)∈A` → `untl(φ,χ)∈A` | BX3 at MCS level |
| `untl_left_mono_thm` | RRelation.lean:1019 | `⊢ β₁→β₂` and `untl(β₁,γ)∈A` → `untl(β₂,γ)∈A` | BX2 at MCS level |
| `snce_left_mono_thm` | RRelation.lean:1037 | Mirror of above | BX2' at MCS level |
| `untl_left_mono_G` | RRelation.lean:1056 | `G(β₁→β₂)∈A` and `untl(β₁,γ)∈A` → `untl(β₂,γ)∈A` | BX2G at MCS level |
| `conj_mcs` | PointInsertion.lean:210 | `φ∈A, ψ∈A` → `φ∧ψ∈A` | Conj intro at MCS |
| `conj_left_mcs` | PointInsertion.lean:289 | `φ∧ψ∈A` → `φ∈A` | Conj elim left at MCS |
| `conj_right_mcs` | PointInsertion.lean:298 | `φ∧ψ∈A` → `ψ∈A` | Conj elim right at MCS |
| `collect_guards` | PointInsertion.lean:1414 | Extract B-guard for each element of L | Infrastructure |
| `collect_guards_mem_of_B` | PointInsertion.lean:1432 | If φ∈L and φ∈B, then φ∈collect_guards output | Key property |
| `burgess_zeta_consistent` | PointInsertion.lean:1243 | Full BX5+BX14+BX13+BX10 compression chain | Core compression |
| `lce_imp` | Propositional.lean:737 | `⊢ (φ∧ψ) → φ` | Standard |
| `rce_imp` | Propositional.lean:755 | `⊢ (φ∧ψ) → ψ` | Standard |
| `pairing` | Combinators.lean | `⊢ φ → (ψ → φ∧ψ)` | Standard |
| `imp_trans` | Combinators.lean | `⊢ φ→ψ` and `⊢ ψ→χ` → `⊢ φ→χ` | Standard |
| `identity` | Combinators.lean | `⊢ φ → φ` | Standard |
| `deduction_theorem` | Core | `Γ,φ⊢ψ` ↔ `Γ⊢φ→ψ` | Standard |

**In `RRelation.lean` (verified):
- `untl_conj_guard`: Given `untl(β₁,γ)∈A` and `untl(β₂,γ)∈A`, produces `untl(β₁∧β₂,γ)∈A` via BX7+BX2+BX3.
- `snce_conj_guard`: Mirror of the above for Since.
- `burgessR_implies_burgessRSince`: Burgess's Lemma 2.3 forward.
- `burgessRSince_implies_burgessR`: Burgess's Lemma 2.3 backward.

---

## Formula Type Structure

**File**: `Theories/Bimodal/Syntax/Formula.lean`

```lean
inductive Formula : Type where
  | atom : Atom → Formula         -- propositional variable
  | bot : Formula                 -- ⊥ (falsum)
  | imp : Formula → Formula → Formula   -- φ → ψ
  | box : Formula → Formula       -- □φ (modal necessity)
  | all_past : Formula → Formula  -- Hφ (always in past)
  | all_future : Formula → Formula -- Gφ (always in future)
  | untl : Formula → Formula → Formula  -- φ U ψ (until) - guard first!
  | snce : Formula → Formula → Formula  -- φ S ψ (since) - guard first!
```

**Derived operators** (all defined as `def` in `Formula` namespace):
- `neg φ = φ.imp bot`
- `and φ ψ = (φ.imp ψ.neg).neg`
- `or φ ψ = φ.neg.imp ψ`
- `diamond φ = φ.neg.box.neg`
- `some_past φ = φ.neg.all_past.neg` (Pφ)
- `some_future φ = φ.neg.all_future.neg` (Fφ)
- `always φ = φ.all_past.and (φ.and φ.all_future)` (△φ)

**IMPORTANT**: There is NO `Formula.top`. Top is always encoded as `Formula.bot.imp Formula.bot`
or `Formula.bot.neg`. There is also no `Formula.conj` — conjunction is entirely derived.

**Argument order for `untl`/`snce`**: The FIRST argument is the GUARD, the SECOND is the EVENT.
So `untl(φ, ψ)` means "φ holds until ψ" = "U(φ,ψ)" in Burgess notation (guard=φ, event=ψ).
But in Burgess's axiom notation, `U(p,q)` has p=event, q=guard (p holds UNTIL q).
See the BX13 signature: `p ∧ untl(φ,ψ) → untl(φ, ψ ∧ snce(φ,p))` where φ=guard, ψ=event, p=current.

---

## Burgess-to-Lean Axiom Mapping

Burgess 1982 uses the formula convention `U(p,q)` where q is the guard (holds during interval)
and p is the event (holds at the witness). The codebase uses `untl(guard, event)`.

| Burgess Name | Burgess Statement | Lean Name | Location | Status |
|--------------|-------------------|-----------|----------|--------|
| A3a | `p ∧ U(q,r) → U(q ∧ S(q,p), r)` | `enrichment_until` | Axioms.lean:175 | PRESENT |
| A3b | Mirror | `enrichment_since` | Axioms.lean:183 | PRESENT |
| A4a | `U(p,q) ∧ ¬U(p,r) → U(q∧¬r, q)` | `separation_until` | Axioms.lean:193 | PRESENT |
| A4b | Mirror | `separation_since` | Axioms.lean:199 | PRESENT |
| A5a | `U(p,q) → U(p, q∧U(p,q))` | `self_accum_until` | Axioms.lean:207 | PRESENT |
| A5b | Mirror | `self_accum_since` | Axioms.lean:212 | PRESENT |
| A6a | `U(q∧U(p,q), q) → U(p,q)` | `absorb_until` | Axioms.lean:219 | PRESENT |
| A7a | `U(p,q) ∧ U(r,s) → U(p∧r,q∧s) ∨ U(p∧s,q∧s) ∨ U(q∧r,q∧s)` | REMOVED | — | REMOVED (unsound) |
| (our BX7) | `U(φ,ψ) ∧ U(χ,θ) → U(φ∧χ,ψ∧θ) ∨ U(φ∧χ,ψ∧χ) ∨ U(φ∧χ,φ∧θ)` | `linear_until` | Axioms.lean:230 | PRESENT |
| A1a | `G(p→q) → U(p,r) → U(q,r)` | subsumed by `left_mono_until_G` | Axioms.lean:140 | PRESENT |
| A2a | `G(p→q) → U(r,p) → U(r,q)` | `right_mono_until` | Axioms.lean:151 | PRESENT |
| Lemma 2.2 | `U(γ,β) → F(β)` | `until_F` (BX10) | Axioms.lean:265 | PRESENT |

**CRITICAL DIFFERENCE**: Burgess's A7a has `q∧s` as the event in ALL THREE disjuncts. Our BX7
(`linear_until`) uses three DIFFERENT events (ψ∧θ, ψ∧χ, φ∧θ). Burgess's A7a is provably unsound
under open guard semantics; BX7 is the valid replacement. This matters for Lemma 2.7: Burgess's
original proof uses A7a. The implementation must use BX7 instead and adapt the proof.

---

## Sorry Sites

### Sorry 1 (line 1573): B-elements case in `burgess_D0_finite_subset_consistent`

**Context**: Step 5 of the proof — showing `event` implies each element of `L`.
For `φ ∈ B` (the first rcases branch), need `DerivationTree [event] φ`.

**Available infrastructure**:
- `collect_guards_mem_of_B`: If `φ ∈ L` and `φ ∈ B`, then `φ ∈ b_list_raw`.
- `b_list = β₀ :: b_list_raw`, so `φ ∈ b_list`.
- `list_conj_implies_elem b_list φ h_mem : ⊢ b → φ` (b = list_conj b_list).
- `h_ev_b : DerivationTree [] (event.imp b)`.
- Compose: `event → b → φ` gives `event → φ`.

**What is needed**: Apply `collect_guards_mem_of_B` to get `φ ∈ b_list_raw`, promote to `b_list`,
then `list_conj_implies_elem` to get `⊢ b → φ`, then `imp_trans h_ev_b` to get `⊢ event → φ`,
then modus ponens.

**Gap Assessment**: This sorry is CLOSEABLE. The tools exist. The challenge is connecting
`collect_guards_mem_of_B` (which gives membership in the *raw list*) to `b_list` (which prepends
`β₀`). The proof requires `List.mem_cons.mpr (Or.inr h_raw)` to promote the membership.

### Sorry 2 (line 1581): Until-formula case in `burgess_D0_finite_subset_consistent`

**Context**: For `φ = untl(β', γ')` with `β' ∈ B`, `γ' ∈ C`, need `DerivationTree [event] φ`.

**Available infrastructure**:
- `h_ev_untl : DerivationTree [] (event.imp (Formula.untl b γ_hat))`.
- `b` = list_conj of B-guards, `γ_hat` = list_conj of C-events.
- Need `⊢ untl(b, γ_hat) → untl(β', γ')`.
- `b → β'`: `β'` is a B-element, so its guard is `β'` itself (from `collect_guards_mem_of_B`).
  Thus `β' ∈ b_list_raw`, so `β' ∈ b_list`, and `⊢ b → β'` via `list_conj_implies_elem`.
- `γ_hat → γ'`: `γ'` is a C-event extracted into `c_list_raw`, so `γ' ∈ c_list_raw ⊆ c_list`,
  and `⊢ γ_hat → γ'` via `list_conj_implies_elem c_list γ'`.
- `untl_left_mono_deriv` applied to `⊢ b → β'` gives `⊢ untl(b,γ_hat) → untl(β',γ_hat)`.
- `untl_right_mono_deriv` applied to `⊢ γ_hat → γ'` gives `⊢ untl(β',γ_hat) → untl(β',γ')`.
- Compose with `imp_trans h_ev_untl`.

**Gap Assessment**: CLOSEABLE. But need to show `γ' ∈ d0_c_event_list` and `β' ∈ b_list`.
The `d0_c_event_list` extracts the event part of Until formulas, but the matching of `γ'` to
its extracted version requires careful case analysis on `Classical.choose_spec`. The B-guard
for `φ = untl(β', γ')` when `φ ∉ B`: `d0_guard` returns `Classical.choose h3` where
`h3 : ∃ β'' ∈ B, ∃ γ'' ∈ C, φ = untl(β'', γ'')`. This gives `Classical.choose h3 ∈ B` but
NOT necessarily `Classical.choose h3 = β'`. This is the key difficulty:
**the guard for `untl(β', γ')` is classically chosen, possibly different from `β'`**.

The implication still works: we need `⊢ b → β'_chosen`, not `⊢ b → β'`. Since the chosen
guard is in `b_list`, and `untl_left_mono_deriv (⊢ b → β'_chosen)` gives
`untl(b, γ_hat) → untl(β'_chosen, γ_hat)`, and then `untl_left_mono_deriv (⊢ β'_chosen → β')`...
but `⊢ β'_chosen → β'` is NOT available unless we know `β'_chosen = β'`.

**This may be the actual hard gap.** The classical choice in `d0_guard` picks a B-element `g`
such that `untl(g, ?) = untl(β', γ')`, so `g = β'`. Therefore `β'_chosen = β'` definitionally.
But Lean's `Classical.choose` may not reduce this without the appropriate `Classical.choose_spec`.
The fix is to use `Classical.choose_spec h3` to get `Classical.choose h3 = β'` (from the equation
`φ = untl(Classical.choose h3, Classical.choose(Classical.choose_spec h3).2.choose) = untl(β', γ')`).

### Sorry 3 (line 1584): Since-formula case in `burgess_D0_finite_subset_consistent`

**Context**: For `φ = snce(β', α')` with `β' ∈ B`, `α' ∈ A`, need `DerivationTree [event] φ`.

**Available infrastructure**:
- `h_ev_snce : ∀ α ∈ a_list, DerivationTree [] (event.imp (Formula.snce b α))`.
- `α'` is the A-event for this Since formula. It appears in `d0_a_event_list`.
- Need to show `α' ∈ a_list` (i.e., `α' ∈ d0_a_event_list β L hL`).
- Then `h_ev_snce α' hα'_in_list : ⊢ event → snce(b, α')`.
- Then `snce_left_mono_deriv (⊢ b → β')` gives `⊢ snce(b, α') → snce(β', α')`.
- Compose: `event → snce(b, α') → snce(β', α')`.

**Gap Assessment**: Similar classical choice issue as Sorry 2. The guard for `snce(β', α')` in
`d0_a_event_list` extracts the A-event `α'_chosen`. We have `event → snce(b, α'_chosen)`.
Need `snce_left_mono_deriv (⊢ b → β') : ⊢ snce(b, α'_chosen) → snce(β', α'_chosen)`.
Then need `snce_right_mono_deriv (⊢ α'_chosen → α')` for the A-event component — but this
would be `⊢ snce(β', α'_chosen) → snce(β', α')` via... actually snce's second argument is
the EVENT (the past witness), not the guard. BX3' (right_mono_since) would give
`H(α'_chosen → α') → snce(β', α'_chosen) → snce(β', α')`. If `α'_chosen = α'` (from
Classical.choose_spec), this simplifies. This sorry is also CLOSEABLE with classical choice
spec reasoning.

### Sorry 4 (line 2050): `lemma_2_7_seed_consistent`

**Context**: Proving the Lemma 2.7 seed consistent. The seed is:
```
B ∪ {xi} ∪ {untl(β, γ) : β∈B, γ∈C}
  ∪ {snce(β, α) : β∈B, α∈A}
  ∪ {snce(β∧eta, α) : β∈B, α∈A}
```

**Available infrastructure**:
- `burgess_zeta_consistent` handles the 2.6 seed consistency via BX5+BX14+BX13+BX10.
- For 2.7, the key change is: need `{xi} ∪ snce(β∧eta, α)` components. The proof sketch
  (lines 903-912) says:
  1. BX5 on `U(xi,eta)` → `U(xi∧U(xi,eta), eta) ∈ A`
  2. BX5 on some `U(beta₀, gamma₀)` from burgessR3 → `U(beta₀∧U(beta₀,gamma₀), gamma₀) ∈ A`
  3. BX7 (linear_until) on the two enriched Until formulas → three-way disjunction D1∨D2∨D3
  4. Eliminate D1 and D2 using `¬U(beta₀∧eta, gamma₀) ∈ A` + left_mono_until
  5. D3 survives: `U(phi₁∧phi₂, phi₁∧gamma₀) ∈ A`
  6. BX10 gives `F(phi₁∧gamma₀) ∈ A`
  7. Lindenbaum → MCS D with `xi ∈ D`

**Key gap**: The current `burgess_zeta_consistent` works for the 2.6 seed where `beta0∈B` is
the guard and the `snce`-formulas use guard `b` (from B). For 2.7, the `snce(β∧eta, α)` formulas
have guard `β∧eta` where `eta` is NOT in B (by hypothesis). This requires a variant of
`burgess_zeta_consistent` where:
- The guard is `beta₀∧U(xi,eta)` (phi₁ component from step 5), not just `b`.
- The snce-formulas pack `β∧eta` guards, requiring `eta` to appear in the guard.

**The core question**: Can the BX7 disjunction step work without Burgess's original A7a?
Our BX7 (`linear_until`) gives `U(phi₁∧phi₂, ψ∧θ) ∨ U(phi₁∧phi₂, ψ∧phi₂) ∨ U(phi₁∧phi₂, phi₁∧θ)`
where phi₁=xi∧U(xi,eta) and phi₂=beta₀∧U(beta₀,gamma₀). The three disjuncts have events
`(eta∧gamma₀)`, `(eta∧phi₂)`, and `(phi₁∧gamma₀)`. Burgess's original proof relies on
A7a which puts `eta∧gamma₀` in ALL disjuncts — we can't use that.

The key is which disjunct we end up using. Step 4 eliminates D1 and D2 using
`¬U(beta₀∧eta, gamma₀) ∈ A`. Let's check D1: event is `eta∧gamma₀`. Left_mono gives
`U(phi₁∧phi₂, eta∧gamma₀) → U(beta₀∧eta, gamma₀)` if `⊢ phi₁∧phi₂ → beta₀∧eta`
(phi₁∧phi₂ implies eta from phi₁=xi∧U(xi,eta), and implies beta₀ from phi₂=beta₀∧U(beta₀,gamma₀)).
So D1 can be eliminated. D2: event is `eta∧phi₂`. Similarly requires `⊢ phi₁∧phi₂ → beta₀∧eta`.
D3: event is `phi₁∧gamma₀`. This is the survivor — with `xi∈phi₁` and `gamma₀∈C`.

**The plan view** (PointInsertion.lean lines 903-912) is confirmed: D3 survives with event
`phi₁∧gamma₀`. F(phi₁∧gamma₀) ∈ A. But for the 2.7 seed we need `xi ∈ D` (got via phi₁)
AND we need `snce(β∧eta, α)` to hold in D. The BX13 enrichment can pack
`snce(phi₁∧phi₂, alpha_i)` into the event (using `iterated_enrichment`), but that gives
`snce` with guard `phi₁∧phi₂`, not `β∧eta`. Weakening the guard via `snce_left_mono_deriv`
with `⊢ phi₁∧phi₂ → beta∧eta` would require `⊢ phi₁ → eta` (yes, phi₁ = xi∧U(xi,eta))
and `⊢ phi₂ → beta` (yes, phi₂ = beta₀∧U(beta₀,gamma₀), so need `⊢ phi₂ → beta` for
general `beta ∈ B`... but phi₂ uses only `beta₀`). So this requires `beta = beta₀` or
a modified seed where `beta₀` absorbs all B-elements via DCS closure.

---

## Gap Analysis: What Is Missing

### Confirmed gaps (sorries to fill):

1. **Sorry 1 (B-elements)**: Use `collect_guards_mem_of_B` to get `φ ∈ b_list_raw`, then
   `List.mem_cons.mpr (Or.inr h)` for `b_list`, then `list_conj_implies_elem`. CLOSEABLE
   but requires careful classical choice unfolding.

2. **Sorry 2 (Until-formulas)**: Need `⊢ b → β'_guard` where `β'_guard` is what `d0_guard`
   returns for `φ=untl(β', γ')`. Since `d0_guard` checks `φ ∉ B` first, then takes
   `Classical.choose h3` where h3 witnesses `∃ β''∈B, ∃ γ''∈C, φ=untl(β'',γ'')`. The
   `Classical.choose_spec` gives the witness is SOME B-element matched to β', but not
   necessarily β' itself as a value. Lean's injection principle for `untl` means the first
   argument of `untl(β'', γ'') = untl(β', γ')` is `β'' = β'`. So `Classical.choose h3 = β'`
   follows from `Formula.untl.injEq`. CLOSEABLE with this injection lemma.

3. **Sorry 3 (Since-formulas)**: Same classical choice issue for Since. CLOSEABLE with
   `Formula.snce.injEq`.

4. **Sorry 4 (lemma_2_7_seed_consistent)**: Requires adapting the BX5+BX7+BX13+BX10 chain
   for the 2.7 seed where `beta₀` must absorb all B-elements. **Solution**: Use DCS closure
   to take `b_list = (β₀ :: B-guards-from-L)` and `b = list_conj(b_list) ∈ B`. Then
   `⊢ b → beta₀` and `⊢ b → beta_i` for each guard. The guard for snce is `b∧eta` (since
   `phi₁ = xi∧U(xi,eta)` and `phi₁ → eta`; `phi₂ = b∧U(b,gamma₀)` and `phi₂ → b`).
   This sorry is **harder** than the others but also closeable using the same architectural
   approach as the 2.6 case with a 2.7-specific variant.

### No missing infrastructure:

All derivation-level tools needed to close the sorries exist:
- `untl_left_mono_deriv` (BX2 at derivation level)
- `snce_left_mono_deriv` (BX2' at derivation level)
- `untl_right_mono_deriv` (BX3 at derivation level)
- `list_conj_implies_elem` (conjunction elimination from list conjunction)
- `iterated_enrichment` (BX13 chain)
- `collect_guards_mem_of_B` (B-membership tracking)

### What is NOT needed:

- No new axioms are needed.
- The `right_mono_since` (BX3') direction for the Since event case would use a right-monotone
  variant, but since `α'_chosen = α'` from injection, it simplifies to identity.
- No `Formula.top` is needed; use `Formula.bot.imp Formula.bot` as in existing code.

---

## Recommended Approach

### For Sorries 1-3 (in `burgess_D0_finite_subset_consistent`)

The three sorries share the same structural approach: connect the compressed guard/event
back to the original formula via `Classical.choose_spec` + `Formula.untl.injEq`/`Formula.snce.injEq`.

**Suggested proof pattern for Sorry 2 (Until-formula case)**:
```lean
-- φ = untl(β', γ')
-- h3 : ∃ β'' ∈ B, ∃ γ'' ∈ C, φ = untl(β'', γ'')
-- d0_guard returns Classical.choose h3 = β'_chosen where
--   (Classical.choose_spec h3).1 : β'_chosen ∈ B
-- From φ = untl(β'_chosen, γ'_chosen) = untl(β', γ') → β'_chosen = β' by injection
-- Similarly γ'_chosen = γ' by injection
-- So β' ∈ b_list_raw (collect_guards_mem_of_B applied to hφ ∈ L, h_B for β')
--   Wait: d0_guard for untl(β',γ') when φ ∉ B returns β'_chosen=β'
--   collect_guards builds b_list_raw by applying d0_guard to each φ ∈ L
--   For φ=untl(β',γ'), the guard IS β', so β' ∈ b_list_raw
-- Then β' ∈ b_list = β₀ :: b_list_raw (List.mem_cons.mpr (Or.inr h))
-- ⊢ b → β' from list_conj_implies_elem b_list β'
-- untl_left_mono_deriv (⊢ b → β') : ⊢ untl(b, γ_hat) → untl(β', γ_hat)
-- Similarly γ' ∈ c_list (γ' appears in d0_c_event_list via inject spec)
-- untl_right_mono_deriv (⊢ γ_hat → γ') : ⊢ untl(β', γ_hat) → untl(β', γ')
-- Compose: event → untl(b, γ_hat) → untl(β', γ_hat) → untl(β', γ')
```

The key injection facts needed (currently absent as lemmas but provable):
- `Formula.untl.injEq : untl a b = untl c d ↔ a = c ∧ b = d`
  (likely derivable from `deriving DecidableEq` on Formula, or via injection tactic)

### For Sorry 4 (lemma_2_7_seed_consistent)

Build a `burgess_2_7_zeta_consistent` helper analogous to `burgess_zeta_consistent` but for
the Lemma 2.7 seed. The main structural differences:

1. Use `b = list_conj(beta₀ :: collect_guards output)` as in the 2.6 case.
2. Apply BX5 on `U(b, gamma₀) ∈ A` (from burgessR3 for `b ∈ B`).
3. Apply BX5 on `U(xi, eta) ∈ A` (given hypothesis).
4. Apply BX7 to the two enriched Until formulas.
5. Eliminate D1 and D2 using `¬U(b∧eta, gamma₀) ∈ A`
   (from BurgessR3Maximal: since `{xi}∪B` is consistent? or from the 2.7 hypothesis itself).
6. D3 = `U(xi∧U(xi,eta) ∧ b∧U(b,gamma₀), xi∧U(xi,eta)∧gamma₀) ∈ A`.
7. BX10: `F(phi₁∧gamma₀) ∈ A` where `phi₁ = xi∧U(xi,eta)`.
8. `iterated_enrichment` for the snce-formulas.
9. The event implies `xi` (from phi₁∧... → xi), `snce(b∧eta, α_i)` (from snce with guard
   phi₁∧phi₂ weakened via `snce_left_mono_deriv` using `⊢ phi₁∧phi₂ → b∧eta`).

The critical question is **how to get `¬U(b∧eta, gamma₀) ∈ A`** for the BX7 disjunction
elimination. This requires the 2.7 maximality hypothesis: `h_eta_not_B : eta ∉ B`. From
BurgessR3Maximal maximality with `eta ∉ B`, if `DC({eta}∪B)` satisfies burgessR3,
contradiction. So there must exist `beta₀, gamma₀` with `¬U(beta₀∧eta, gamma₀) ∈ A`.
This is exactly the pattern needed.

---

## Confidence Level

**High confidence** (verified by direct code reading):
- All BX axiom constructors exist with correct types in `Axioms.lean`.
- All derivation-level tools listed exist and are proved (no sorry) in `PointInsertion.lean`.
- The Formula type structure is exactly as documented.
- The four sorry sites are correctly identified and their context is fully understood.
- Sorries 1-3 are closeable with the existing tools + classical choice injection lemmas.

**Medium confidence** (requires implementation to verify):
- Sorry 4 is closeable using an adapted `burgess_2_7_zeta_consistent` helper following
  the same structural approach as `burgess_zeta_consistent`.
- The BX7 disjunction elimination for 2.7 correctly eliminates D1 and D2 leaving D3.

**Low confidence**:
- The exact classical choice unfolding in `d0_guard`/`d0_c_event_list`/`d0_a_event_list`
  may require additional simp lemmas or `native_decide` to discharge injection goals.

---

## Report Metadata

- **Files read**: `Axioms.lean`, `Derivation.lean`, `Formula.lean`, `BigConj.lean`,
  `PointInsertion.lean` (full), `CanonicalChain.lean`, `RRelation.lean` (partial),
  `Burgess_1982.md`
- **Session**: sess_1777758350_184c2f
- **Status**: Research complete, ready for implementation
