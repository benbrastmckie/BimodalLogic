# Teammate A: Primary Analysis — Burgess-Aligned FUC/FSC Closure

## Key Findings

### The Sorry Sites

Both sorries live in `cantor_bfmcs_restricted_fuc` at:
- `ChronicleToCountermodel.lean:634` — Forward Until Coherence (FUC)
- `ChronicleToCountermodel.lean:638` — Forward Since Coherence (FSC)

The goal for FUC (after unfolding) is:

```
Given: U(φ,ψ) ∈ (rooted_cantor_fmcs N h_N h_nubr3 s).mcs t
Goal:  ∃ s1, t < s1 ∧ ψ ∈ mcs(s1) ∧ ∀ r, t < r → r < s1 → φ ∈ mcs(r)
```

Translating through the Cantor isomorphism (same pattern as the existing `restricted_tc` proof at lines 456-501), this reduces to:

```
Given: untl(φ, ψ) ∈ limit_f(x)    where x = cantor_iso.symm(t - offset)
Goal:  ∃ y ∈ limit_dom, x < y ∧ ψ ∈ limit_f(y) ∧ ξ ∈ limit_g(x, y)
```

where `limit_g(x,y) = {a | ∀ z ∈ limit_dom, x < z → z < y → a ∈ limit_f(z)}`.

**The endpoint** `y` with `ψ ∈ limit_f(y)` is already available via `limit_satisfies_c5_weak`. **The guard** `φ ∈ limit_g(x,y)` (= φ at ALL intermediate limit_dom points) is the missing piece.

### Burgess Paper: How Guard Ends Up in g(x,y)

Burgess 2.10 (C5 counterexample elimination, Case n=0) states:

> Apply 2.4 to A = f(x), obtaining B, C. Set y = x+1, f'(y) = C, g'(x,y) = B.

Burgess 2.4 states:

> Given U(γ,β) ∈ A, there exist B, C with **β ∈ B**, γ ∈ C, and R(A, B, C).

**CRITICAL**: In Burgess's convention, the GUARD is η (2nd arg to U) and the EVENT is ξ (1st arg). So Burgess's 2.4 actually says: **guard η ∈ B** and event ξ ∈ C.

The Truth Lemma (2.11) for U(ξ,η) uses:
- C5a: `ξ ∈ f(y)` and `η ∈ g(x,y)` (not just `ξ ∈ f(y)`)
- C3: `g(x,y) ⊆ f(z)` for intermediate z
- Together: guard η ∈ g(x,y) ⊆ f(z) for all z between x and y

**Our convention mapping**: Our `untl(φ=guard, ψ=event)` = Burgess `U(ξ=event, η=guard)`. So our φ = Burgess η (guard, 2nd argument). Burgess 2.4 concludes `η ∈ B`, meaning **our φ (guard) must be in B**.

### Current `lemma_2_4` Deficiency

`PointInsertion.lean:158`, current `lemma_2_4` produces:
```
∃ B C : Set Formula, SetMaximalConsistent C ∧
  β ∈ C ∧ g_content A ⊆ C ∧
  some_past(untl γ β) ∈ C ∧
  BurgessR3Maximal A B C
```

B is constructed via `burgessR3Maximal_from_g_content_sub` with seed `DC({top})`. This does **NOT** guarantee `γ ∈ B` (our guard φ).

Burgess 2.4's proof: the seed C₀ = `{γ} ∪ {S(α,β) : α ∈ A}`. Crucially, this seed **contains γ** (the guard/event in Burgess's first argument). But wait — in Burgess's notation, γ is the EVENT (1st arg to U), not the guard. Let me re-examine.

**Re-reading Burgess 2.4 carefully**:

Statement: Given `U(γ,β) ∈ A`, there exist B, C such that `β ∈ B`, `γ ∈ C`, R(A, B, C).

In Burgess's semantics: `V(U(α,β)) = {x : ∃y > x, y ∈ V(α) ∧ ∀z(x<z<y → z ∈ V(β))}`.

So `U(γ,β)` means: eventually γ, with β holding throughout until then.
- **γ** = the EVENT (must hold at some future y)
- **β** = the GUARD (must hold at all intermediate points)

Therefore Burgess 2.4: `β ∈ B` (guard in B) and `γ ∈ C` (event at endpoint C).

**Our `untl(φ, ψ)`**: Our semantics (from TemporalCoherence.lean): given `U(φ,ψ) ∈ fam.mcs(t)`, need `∃ s > t, ψ ∈ mcs(s) ∧ ∀ r ∈ (t,s), φ ∈ mcs(r)`. So:
- **φ** = guard (holds at intermediate points)  
- **ψ** = event (holds at endpoint s)

Comparing: Burgess's β = guard = our φ (1st arg to untl), Burgess's γ = event = our ψ (2nd arg to untl).

**Burgess 2.4 says: guard β ∈ B (= our φ ∈ B).**

**Current `lemma_2_4` gives: β (= our ψ = event) ∈ C, NOT φ (= our γ/guard) ∈ B.**

Wait — let me re-read the `lemma_2_4` signature again. It takes `γ β : Formula` and `h_until : untl γ β ∈ A`, concluding `β ∈ C`. Here `γ` = our 1st arg = guard, `β` = our 2nd arg = event. So:
- Current output: `β ∈ C` ✓ (event at endpoint C — correct)
- Missing output: `γ ∈ B` (guard in interval B — this is what Burgess gives)

**CONFIRMED: `lemma_2_4` needs to additionally produce `γ ∈ B`.**

### Feasibility: Can We Produce `γ ∈ B`?

Burgess's proof of 2.4: C₀ = `{γ} ∪ {S(α,β) : α ∈ A}`.

In our notation: C₀ = `{ψ=event} ∪ {snce(α,ψ) : α ∈ A}` ... wait, no. Let me re-read: Burgess builds the ENDPOINT MCS from seed `{γ} ∪ {S(α,β) : α ∈ A}` where γ=event, β=guard.

In our notation: the endpoint C₀ seed should be `{ψ=event} ∪ {snce(α,ψ) : α ∈ A}`.

That's `{β} ∪ {snce(α, β) : α ∈ A}`.

Our current `lemma_2_4` seed is `{β} ∪ g_content(A)` (via `forward_temporal_witness_seed_consistent`). The g_content contains `{G(a) : a ∈ A}` entries, not `{snce(α,β) : α ∈ A}`.

Then B is defined to be maximal with `β ∈ B` and `r(A, B, C)`. In our terms: B maximal with `r(A, ψ, C)` ... no, with `burgessR3(A, B, C)` and `ψ ∈ B` (the guard!).

**KEY INSIGHT**: In Burgess 2.4, B is "maximal with respect to the property β ∈ B and r(A, B, C)". Our β = our φ (guard). So **B is explicitly constructed to contain the guard β = our φ**.

The current Lean `lemma_2_4` constructs B via `burgessR3Maximal_from_g_content_sub` with seed `DC({top})` — it does NOT seed B with `{β=φ}` and does NOT guarantee `φ ∈ B`.

### The Fix: Use `burgessR3Maximal_with_guard`

The lemma `burgessR3Maximal_with_guard` (RRelation.lean:1593) does exactly what's needed:

```lean
theorem burgessR3Maximal_with_guard (A C : Set Formula) (η : Formula)
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_burgessR : burgessR A η C)
    (h_burgessRSince : burgessRSince C η A)
    (h_nubr3 : NoUnivBurgessR3) :
    ∃ B : Set Formula, η ∈ B ∧ BurgessR3Maximal A B C
```

This produces `η ∈ B` (guard in B). The preconditions are:
1. `burgessR A η C` — for all δ ∈ C, `untl(η, δ) ∈ A`
2. `burgessRSince C η A` — for all α ∈ A, `snce(η, α) ∈ C`

### How to Establish the Preconditions

**For `burgessRSince C η A`** (= `∀ α ∈ A, snce(φ, α) ∈ C` where φ = our guard):

Burgess's C₀ = `{γ=event} ∪ {S(α, β=guard) : α ∈ A}`.

In our notation: C₀ = `{ψ} ∪ {snce(α, φ) : α ∈ A}`.

If we **enrich** the current seed by including `{snce(α, φ) : α ∈ A}`, then after Lindenbaum extension C ⊇ C₀, we have `snce(α, φ) ∈ C` for all α ∈ A, i.e., `burgessRSince C φ A`.

**Seed consistency for the enriched C₀**:

Current seed: `{ψ} ∪ g_content(A)` — consistent by `forward_temporal_witness_seed_consistent`.

Enriched seed: `{ψ} ∪ g_content(A) ∪ {snce(α, φ) : α ∈ A}`.

The enriched seed consistency proof strategy (following Burgess 2.4): For any finite conjunct `ψ ∧ (∧ G(a_i)) ∧ (∧ snce(α_j, φ))`, show consistency. Use BX13 iteratively on `untl(φ, ψ) ∈ A`:
- BX13: `p ∈ A ∧ untl(φ, ψ) ∈ A → untl(φ, ψ ∧ snce(φ, p)) ∈ A`
- Iterate: `untl(φ, ψ ∧ snce(φ, α₁) ∧ ... ∧ snce(φ, αₙ)) ∈ A`
- Use right-monotonicity (BX3) to fold in `G(a_i)` terms
- Extract `F(event') ∈ A` via BX10
- Deduce consistency via `forward_temporal_witness_seed_consistent`

This pattern mirrors the existing `lemma_2_7_seed_consistent` proof. The `iterated_enrichment` function at PointInsertion.lean:1388 provides the BX13 chain.

**For `burgessR A φ C`** (= `∀ δ ∈ C, untl(φ, δ) ∈ A`):

From `burgessRSince C φ A` (established above), apply `burgessRSince_implies_burgessR`:

```lean
burgessRSince_implies_burgessR : burgessRSince C η A → burgessR A η C
```

This is `Lemma 2.3` (bidirectionality of the r-relation).

### Complete Modified `lemma_2_4` Output Type

The enriched `lemma_2_4` should produce:

```lean
∃ B C : Set Formula, SetMaximalConsistent C ∧
  ψ ∈ C ∧ g_content A ⊆ C ∧
  some_past(untl φ ψ) ∈ C ∧
  φ ∈ B ∧
  BurgessR3Maximal A B C
```

### Phase 4: Closing FUC via `limit_satisfies_c5_strong`

Once `lemma_2_4` produces `φ ∈ B` and B is used as `g(x,y)` in `CounterexampleElimination.lean`:

Define `limit_satisfies_c5_strong`:

```lean
theorem limit_satisfies_c5_strong (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_nubr3 : NoUnivBurgessR3)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs h_nubr3)
    (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ limit_f A h_mcs h_nubr3 x) :
    ∃ y ∈ limit_dom A h_mcs h_nubr3, x < y ∧ ψ ∈ limit_f A h_mcs h_nubr3 y ∧
      φ ∈ limit_g A h_mcs h_nubr3 x y
```

The proof uses:
1. From `limit_satisfies_c5_weak`: get `y ∈ limit_dom` with `ψ ∈ limit_f(y)`.
2. Need `φ ∈ limit_g(x,y)`, i.e., `∀ z ∈ limit_dom, x < z → z < y → φ ∈ limit_f(z)`.
3. **Key**: By definition of `limit_g`, this holds iff the guard is in EVERY finite-stage g-value that "contains" the interval (x,y).

The propagation argument: When the C5 counterexample at x is eliminated at step n (producing new point y_n with `ψ ∈ f_n(y_n)`), we have `φ ∈ g_n(x, y_n)` (because `lemma_2_4` now produces `φ ∈ B = g_n(x, y_n)`). For any subsequent z inserted between x and y_n at step m > n: the C3 condition in `EliminationResult` means `g_m(x, y_n) = g_m(x, z) ∩ f_m(z) ∩ g_m(z, y_n)`, so `φ ∈ g_m(x, y_n) ⊆ f_m(z)`. Hence `φ ∈ limit_f(z)` for all intermediate z.

**This is exactly Burgess's C3 argument from 2.11**.

### CallerUpdate Requirements (CounterexampleElimination.lean)

`lemma_2_4` is called at:
1. `CounterexampleElimination.lean:670` — Case n=0 (x = max_old)
2. `CounterexampleElimination.lean:824` — Walk Case A (u_max = max_old)

Both cases set `g'(x, y) = B_l24`. Since the new `lemma_2_4` returns `γ ∈ B`, these callers gain `φ ∈ g'(x, y)`.

The `EliminationResult` type needs a new field:
```lean
c5_forward_guard : pc.kind = .c5_forward → pc.x ∈ χ.dom →
  Formula.untl pc.ξ pc.η ∈ χ.f pc.x →
  ∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧
    pc.ξ ∈ val.g pc.x y
```

This propagates up through the omega chain to the limit.

## Recommended Approach

The recommended approach follows Burgess 2.4 faithfully, in 4 phases:

### Phase 1 (DONE): `burgessR3Maximal_with_guard` — RRelation.lean:1593

### Phase 2: Modify `lemma_2_4` (PointInsertion.lean)

**Enrich the C seed** by adding `{snce(α, γ) : α ∈ A}` to the seed. This requires:

1. A new lemma `until_witness_enriched_seed_consistent` proving consistency of `{β} ∪ g_content(A) ∪ {snce(α, γ) : α ∈ A}` given `untl(γ, β) ∈ A`. Proof uses `iterated_enrichment` (already in PointInsertion.lean:1388) to produce `untl(γ, β ∧ snce(γ,α₁) ∧ ... ∧ snce(γ,αₙ)) ∈ A` for any finite set of α_j ∈ A.

2. After Lindenbaum extension `C ⊇ {β} ∪ g_content(A) ∪ {snce(α, γ) : α ∈ A}`:
   - `burgessRSince C γ A` holds (∀ α ∈ A, snce(γ, α) ∈ C from seed)
   - `burgessR A γ C` holds (via `burgessRSince_implies_burgessR`)
   - Apply `burgessR3Maximal_with_guard A C γ` to get `B` with `γ ∈ B` and `BurgessR3Maximal A B C`

3. New output signature adds `γ ∈ B` to the existential.

### Phase 3: Update `EliminationResult` + callers

Add `c5_forward_guard` field to `EliminationResult`. Update:
- Case n=0 (line 670): destructure new `h_γ_B` from `lemma_2_4`; prove `pc.ξ ∈ g'(pc.x, y)`
- Walk Case A (line 824): same pattern
- Walk Case B and non-condition-i: these don't use `lemma_2_4` directly but use `lemma_2_7` which ALREADY produces `xi ∈ B'` (line 3631). The guard is therefore already in B' from `lemma_2_7`'s output.

### Phase 4: Prove `limit_satisfies_c5_strong`

Using `omega_chain_g_agrees` (needs to be added, similar to existing `omega_chain_f_agrees`) and the guard information from `c5_forward_guard`, prove:

```
φ ∈ limit_g A h_mcs h_nubr3 x y
```

by showing: the omega chain stage n₀ that eliminates the (x, φ, ψ) counterexample produces a chronicle where `φ ∈ g_{n₀+1}(x, y)`, and by C3 propagation through subsequent insertions, `φ ∈ f_m(z)` for all z ∈ dom_m with x < z < y. Taking the limit gives `φ ∈ limit_g(x,y)`.

### Phase 5: Close the sorries in ChronicleToCountermodel.lean

With `limit_satisfies_c5_strong` available, the FUC sorry becomes:

```lean
intro t φ ψ _h_sub h_until
-- Transfer to limit coordinates (same pattern as restricted_tc at lines 466-484)
have h_until' : Formula.untl φ ψ ∈ limit_f N h_N h_nubr3
    ((cantor_iso N h_N h_nubr3).symm (t - offset)).val := h_until
have h_dom := ((cantor_iso N h_N h_nubr3).symm (t - offset)).property
obtain ⟨y, hy_dom, hy_gt, hy_ψ, hy_guard⟩ :=
    limit_satisfies_c5_strong N h_N h_nubr3 _ h_dom φ ψ h_until'
refine ⟨(cantor_iso N h_N h_nubr3) ⟨y, hy_dom⟩ + offset, ?_, ?_, fun r hr_lo hr_hi => ?_⟩
-- Endpoint > t: same as restricted_tc
-- ψ ∈ mcs(endpoint): same as restricted_tc
-- Guard: r ↦ limit_f point via cantor_iso; use limit_c3_interval_subset_point
--   hy_guard : φ ∈ limit_g N h_N h_nubr3 x y
--   x < r' < y (after iso transfer) → φ ∈ limit_f(r') by limit_g definition
```

FSC is the exact mirror, using `limit_satisfies_c5'_strong`.

## Evidence and Examples

### Evidence for Phase 2 Feasibility

The `iterated_enrichment` function (PointInsertion.lean:1388) already handles the BX13 chain. The `lemma_2_7_seed_consistent` proof (line 3204) uses a similar enrichment pattern — it seeds D₀ with `{untl(β,γ) : β ∈ B, γ ∈ C} ∪ B ∪ {eta} ∪ {snce(β,α) : β ∈ B, α ∈ A} ∪ {snce(β∧xi, α) : ...}`. The new enrichment is simpler.

### Evidence for Phase 3 Guard Propagation

`lemma_2_7` at line 3616 ALREADY produces `xi ∈ B'`. This covers all splitting cases (non-condition-i in both Walk Case B and the primary n≥1 case). Only the `lemma_2_4` cases (n=0 and Walk Case A) need updating.

### The Critical C3 Propagation Argument

At stage n₀ when (x, φ, ψ) C5 is eliminated: new point y added with `φ ∈ g_{n₀+1}(x,y)`. At stage n₁ > n₀ when z is inserted between x and y: C3 gives `g_{n₁+1}(x,y) = g_{n₁+1}(x,z) ∩ f_{n₁+1}(z) ∩ g_{n₁+1}(z,y)`. Since `g_{n₁+1}(x,y) ⊇ g_{n₀+1}(x,y) ∋ φ` (g-values can only shrink or stabilize as new points are inserted), `φ ∈ f_{n₁+1}(z)`. The limit follows.

**Caveat**: The "g-values can only shrink" claim needs to be formalized as `omega_chain_g_agrees` (analogous to the existing `omega_chain_f_agrees`). The key is: when a new point is inserted OUTSIDE (x,y), the g-value at (x,y) is unchanged (from `g_agrees` in `EliminationResult`). When a new point z is inserted INSIDE (x,y), C3 forces `g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y) ⊆ f(z)`, so the guard propagates to z.

## Summary of Required Changes

| File | Change | Lines |
|------|--------|-------|
| `PointInsertion.lean` | Add enriched seed consistency lemma | new ~line 145 |
| `PointInsertion.lean` | Modify `lemma_2_4` output type + proof | ~158-180 |
| `CounterexampleElimination.lean` | Add `c5_forward_guard` field to `EliminationResult` | ~602-630 |
| `CounterexampleElimination.lean` | Update Case n=0 to extract `φ ∈ B` | ~670-744 |
| `CounterexampleElimination.lean` | Update Walk Case A to extract `φ ∈ B` | ~824-904 |
| `ChronicleConstruction.lean` | Add `omega_chain_g_agrees` lemma | new |
| `ChronicleConstruction.lean` | Add `limit_satisfies_c5_strong` | new ~line 610 |
| `ChronicleConstruction.lean` | Add `limit_satisfies_c5'_strong` | new mirror |
| `ChronicleToCountermodel.lean` | Fill FUC sorry (line 634) | 633-634 |
| `ChronicleToCountermodel.lean` | Fill FSC sorry (line 638) | 637-638 |

## Confidence Level

**high**

The mathematical argument is directly from Burgess 2.4 + 2.11. The key lemma `burgessR3Maximal_with_guard` is already proven. The `iterated_enrichment` infrastructure already handles the BX13 chain needed for seed consistency. The `lemma_2_7` structure (which already handles the guard-in-B problem for splitting cases) confirms the pattern works. The `limit_c3_interval_subset_point` lemma (ChronicleConstruction.lean:888) is already proven and provides the exact C3 propagation step needed.

The main new technical work is:
1. Proving enriched seed consistency (straightforward via `iterated_enrichment`)
2. Adding `omega_chain_g_agrees` (analogous to existing `omega_chain_f_agrees`)
3. The limit C5 strong proof using C3 propagation

No novel mathematical ideas are needed — this is a faithful formalization of Burgess's own proof.
