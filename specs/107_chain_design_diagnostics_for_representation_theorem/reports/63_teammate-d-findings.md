# Teammate D: Horizons — Burgess Paper Deep Alignment and Strategic Path

## Key Findings

### 1. Complete Burgess Paper Map

**Definitions and Relations:**
- `r(A, beta, C)` (Burgess 2.3 single-element): for all γ ∈ C, U(beta, γ) ∈ A. Our: `burgessR A beta C`
- `r(A, B, C)` (Burgess 2.3 set): for all β ∈ B, r(A, β, C). Our: `burgessRSet A B C`
- `R(A, B, C)` (Burgess maximality): B maximal with r(A, B, C). Our: `BurgessR3Maximal A B C`
- `(f, g) ∈ F` (Burgess chronicle): Our: `Chronicle` structure + `ChronicleInvariant`
- C0: f maps Q to MCS. Our: `Chronicle.c0`
- C0': dom f finite. Our: `dom : Finset Rat`
- C1: g maps pairs to DCS. Our: `Chronicle.c1`
- C2: r(f(x), g(x,y), f(y)) for all x < y. Our: `Chronicle.c2`
- C2': R(f(x), g(x,y), f(y)) for adjacent x < y. Our: `Chronicle.c2'` using `BurgessR3Maximal`
- C3: g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z). Our: `Chronicle.c3` — **CORRECTLY** implemented
- C4a: backward counterexample condition for Until. Our: `Chronicle.c4`
- C5a: U(ξ,η) ∈ f(x) → ∃y > x, ξ ∈ f(y), **η ∈ g(x,y)**. Our: `Chronicle.c5` — **DISCREPANCY** (see below)

**Convention mapping (CRITICAL):**
- Burgess U(α, β) = "α until β where β is the EVENTUALITY, α is the GUARD"
- Burgess: `V(U(α,β)) = {x | ∃y > x, y ∈ V(α) ∧ ∀z: x < z < y → z ∈ V(β)}`
- So Burgess U(α=event, β=guard)
- Our `untl(γ, δ)` = guard γ first arg, event δ second arg
- Our `untl(γ, δ)` = Burgess `U(δ=event, γ=guard)` — SWAPPED as stated in team convention

**Lemma map:**
- Burgess 2.1 (Replacement): used implicitly throughout
- Burgess 2.2 (Consistency Criterion): U(γ,δ) ∈ A → γ consistent. Our: `ConsistencyLemma2_2` in PointInsertion
- Burgess 2.3 (r-relation equivalence): Our: `burgessR`, `burgessRSince`, `lemma_2_3`
- Burgess 2.4 (Until witness): Our: `lemma_2_4` in PointInsertion
- Burgess 2.5 (Interval absorption): B = B' ∩ D ∩ B''. Our: `lemma_2_5b`
- Burgess 2.6 (Counterexample insertion — δ ∉ B): Our: `lemma_2_6_splitting` in PointInsertion
- Burgess 2.7 (Enriched insertion — η ∉ B): Our: `lemma_2_7` in PointInsertion — FULLY PROVED (Phase 3 complete)
- Burgess 2.8 (Alternative condition): Our: `lemma_2_8_since` (partial, may not be needed for current sorries)
- Burgess 2.9 (C4 elimination lemma): Our: in `CounterexampleElimination.lean`
- Burgess 2.10 (C5 elimination lemma): Our: `eliminate_potential_counterexample` for C5 cases
- Burgess 2.11 (Truth Lemma): Our: `cantor_bfmcs_restricted_fuc` etc. in ChronicleToCountermodel

### 2. Current Sorry State (Confirmed: Only 2 Remain)

Running `grep -rn "^\s*sorry\b" Chronicle/` shows exactly 2 sorry sites:
- `ChronicleToCountermodel.lean:634` — Forward Until Coherence (FUC)
- `ChronicleToCountermodel.lean:638` — Forward Since Coherence (FSC)

All other Chronicle files are sorry-free. CounterexampleElimination.lean has ZERO sorry lines (contrary to the earlier plan which tracked 7 there — those were all closed).

### 3. C0-C5 Condition Audit: Alignment Status

**C0, C0', C1**: PERFECTLY aligned with Burgess.

**C2**: Our `Chronicle.c2` uses `r3Relation` (the rRelation+rRelationSince obligation-propagation version). Burgess C2 uses content-based `r(f(x), g(x,y), f(y))`. These are DIFFERENT definitions. However, for the completeness proof this is fine: at the limit, C2' (adjacent pairs) collapses to vacuous (dense order has no adjacent pairs), and C2 follows for non-adjacent pairs from C3.

**C2'**: Our implementation uses `BurgessR3Maximal` (content-based, correct Burgess formulation). ALIGNED.

**C3**: `g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)` — PERFECTLY aligned. This three-way intersection (with f(y)) is critical and correctly implemented.

**C4**: ALIGNED. Implemented over ALL pairs x < y (not just adjacent), correctly generalized.

**C5**: **PARTIAL ALIGNMENT** — this is where the 2 sorries live.

Our `Chronicle.c5` states: ∃y > x, η ∈ f(y) ∧ ∀z ∈ dom: x < z < y → (ξ ∈ f(z) ∧ U(ξ,η) ∈ f(z))

Burgess C5a states: ∃y > x, **ξ ∈ f(y)** (event at endpoint) ∧ **η ∈ g(x,y)** (guard in interval set)

CRITICAL DIFFERENCE (with our convention swap applied): Our C5 requires guard ξ at intermediate DOMAIN POINTS. Burgess's C5a requires guard **η ∈ g(x,y)** (the GUARD in the INTERVAL SET). Under Burgess C3, g(x,y) ⊆ f(z) for x < z < y, so Burgess's formulation implies guard at ALL intermediate limit points. Our current `limit_satisfies_c5_weak` only proves the endpoint η ∈ limit_f(y) — it discards the guard.

### 4. Audit of Elimination Lemmas (2.9 and 2.10)

**Burgess 2.9** (C4 counterexample): Correctly implemented. The n=0 case uses Lemma 2.6 splitting. The n=m+1 case reduces by finding the immediate successor and checking whether the Until formula persists. Both cases are now sorry-free.

**Burgess 2.10** (C5 counterexample):

The n=0 case correctly uses Lemma 2.4 (`lemma_2_4`) to get B, C with:
- η ∈ C (event at new point)
- BurgessR3Maximal(f(x), B, C) (g-value B between f(x) and C)

The n=m+1 case checks condition (i): "both η∧U(ξ,η) ∈ f(x') AND η ∈ g(x,x')". If (i) holds, advance to x' and reduce to n=m. If (i) fails, apply Lemma 2.7 or 2.8 splitting.

**CRITICAL FINDING**: The n=0 case in `eliminate_potential_counterexample` correctly calls `lemma_2_4` and gets B from its output. The c2' field of `EliminationResult` is populated with `BurgessR3Maximal(f(x), B, C)`. However, the `c5_forward_witness` field only captures `η ∈ val.f y` — it does NOT capture `ξ ∈ val.g x y` (i.e., guard ∈ B). This is the discarded information.

### 5. Root Cause of the 2 Sorries

The precise gap in `cantor_bfmcs_restricted_fuc` (ChronicleToCountermodel:622-638):

**Goal (FUC, line 634):** Given U(φ,ψ) ∈ cantor_fmcs(t), produce s > t with ψ ∈ cantor_fmcs(s) AND ∀r: t < r < s → φ ∈ cantor_fmcs(r).

**What's available:** `limit_satisfies_c5_weak` gives the endpoint (∃y > x, η ∈ limit_f(y)). The guard φ at intermediate limit_dom points is missing.

**Why `limit_g` is the key:** Our `limit_g(x,y)` is defined as {φ | ∀w ∈ limit_dom, x < w < y → φ ∈ limit_f(w)} — exactly the universal guard condition. If we can prove φ ∈ limit_g(x,y) alongside η ∈ limit_f(y), then `limit_c3_interval_subset_point` gives φ ∈ limit_f(z) for all intermediate z, closing the sorry.

**The guard gap chain:**
1. `lemma_2_4` produces B with `BurgessR3Maximal(f(x), B, C)` but does NOT guarantee φ ∈ B
2. `eliminate_potential_counterexample` stores B as the g-value for (x, y) but discards the fact φ ∈ B (or doesn't have it)
3. `omega_chain_c5_witness` exposes only `η ∈ val.f y`, not `φ ∈ val.g x y`
4. `limit_satisfies_c5_weak` inherits this weakness
5. `cantor_bfmcs_restricted_fuc` cannot construct the required guard at intermediate points

### 6. Audit of the Limit Construction vs. Burgess's Union

**Burgess (p.374):** "let X be the union of dom f_n, and f and g the unions of the f_n and g_n."

**Our implementation:**
- `limit_dom`: union of all `omega_chain_val(n).dom` — ALIGNED
- `limit_f`: f_n(x) for the minimal n with x ∈ dom(n) — ALIGNED (well-defined by `limit_f_eq`)
- `limit_g(x,y)`: defined as {φ | ∀w ∈ limit_dom, x < w < y → φ ∈ limit_f(w)}

**DIVERGENCE**: Burgess's limit_g is the union of g_n values. Our `limit_g` is a semantic intersection over limit_f values at intermediate domain points. At the dense limit these coincide IF g_n values satisfy the C3 invariant (g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y) at each finite stage). However, the equivalence requires that the finite-stage g-values correctly propagate to the limit via omega_chain_g_agrees.

**Important**: The g-function in omega_chain is currently NEVER USED for the limit. The `limit_g` definition bypasses the finite-stage g entirely. This is mathematically defensible at the dense limit (C3 forces limit_g to equal the intersection definition), but it means the finite-stage evidence that "guard φ ∈ g(x,y)" — which IS captured in B from lemma_2_4 — is never extracted.

### 7. Minimal Change to Close Both Sorries

**The surgical fix is a two-step change:**

**Step 1: Strengthen `EliminationResult.c5_forward_witness`**

Add a `c5_forward_witness_with_guard` field to `EliminationResult`:
```lean
c5_forward_witness_with_guard : pc.kind = .c5_forward → pc.x ∈ χ.dom →
  Formula.untl pc.ξ pc.η ∈ χ.f pc.x →
  ∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧ pc.ξ ∈ val.g pc.x y
```

This is achievable in the n=0 case because:
- Lemma 2.4 produces B with BurgessR3Maximal(f(x), B, C) and **φ ∈ B** (if we enrich lemma_2_4's seed)
- g'(x, y) is set to B in the new chronicle
- So pc.ξ ∈ val.g pc.x y = B

However, for guard ∈ B, we need lemma_2_4 to include the guard in the seed. Currently lemma_2_4's seed is `{η} ∪ g_content(f(x))`. We need the seed to include ξ (the guard) OR prove burgessR(f(x), ξ, C) from the construction, guaranteeing ξ ∈ B via BurgessR3Maximal maximality.

**Step 2: Prove `limit_satisfies_c5_strong`**

Add to ChronicleConstruction.lean:
```lean
theorem limit_satisfies_c5_strong ...
  (h_until : Formula.untl ξ η ∈ limit_f A h_mcs h_nubr3 x) :
  ∃ y ∈ limit_dom, x < y ∧ η ∈ limit_f A h_mcs h_nubr3 y ∧
    ξ ∈ limit_g A h_mcs h_nubr3 x y
```

Proof outline:
1. Get `c5_forward_witness_with_guard`: ∃y in dom(n+1), x < y ∧ η ∈ f_{n+1}(y) ∧ ξ ∈ g_{n+1}(x,y) = B
2. Need to transfer "ξ ∈ g_{n+1}(x,y)" to "ξ ∈ limit_g(x,y)"
3. limit_g(x,y) = {φ | ∀w ∈ limit_dom, x < w < y → φ ∈ limit_f(w)}
4. Need: for all w ∈ limit_dom with x < w < y, ξ ∈ limit_f(w)

This is where the key question is: does g_{n+1}(x,y) = B propagate to later limit_dom points? The `omega_chain_g_agrees` infrastructure (analogous to `omega_chain_f_agrees`) would provide this IF the g-function is maintained through the chain. Currently, the chain only maintains C0 and C2' — g-values are re-constructed at each step without global g-agreement lemmas for non-adjacent pairs.

**The key mathematical insight**: At the limit, the omega chain is dense, so for any x < w < y in limit_dom, there exists n such that x, w, y ∈ dom(n). At that stage, by C3: g_n(x,y) = g_n(x,w) ∩ f_n(w) ∩ g_n(w,y). So g_n(x,y) ⊆ f_n(w), giving ξ ∈ limit_f(w) IF ξ ∈ g_n(x,y).

**But the problem**: g_n(x,y) is set at step n+1 (when y is first inserted). At step n' > n+1 when w is inserted between x and y, the C3 update sets g_{n'}(x,y) = g_{n'}(x,w) ∩ f_{n'}(w) ∩ g_{n'}(w,y). The new g_{n'}(x,y) ⊆ g_{n+1}(x,y) (it can only shrink). So ξ ∈ g_{n+1}(x,y) does NOT guarantee ξ ∈ g_{n'}(x,y) after the split.

**The decisive issue**: The claim that "guard ∈ g propagates" would require g_agrees monotonicity for non-adjacent pairs. Since g-values SHRINK when points are inserted (by C3), guard ∈ g at stage n does not imply guard ∈ g at stage n' > n.

### 8. Why the Direct Guard Propagation Approach Also Fails

The `phase7-fuc-fsc.md` handoff's recommended approach (track Burgess g through omega chain) faces exactly this issue: the g-function is well-tracked for adjacent pairs (via c2' invariant), but non-adjacent g-values SHRINK as new points are inserted, so guard ∈ g_n(x,y) does NOT persist.

### 9. The Correct Burgess Argument (What We Actually Need)

Re-reading Burgess 2.11 carefully: "If U(β,γ) ∈ f(x), by C5a ∃ y > x, γ ∈ f(y), **β ∈ g(x, y)**. By C3, g(x,y) ⊆ f(z) for x < z < y, so β ∈ f(z)."

In Burgess's paper, y is the witness given by C5a for the TOTAL chronicle (not finite stages). The total chronicle satisfies BOTH C5a AND C3. So the chain: C5a gives β ∈ g(x,y) at the limit → C3 gives g(x,y) ⊆ f(z) → β ∈ f(z).

**What we need is C5a at the limit**: ∃y > x, ξ ∈ f(y) ∧ **guard ∈ g(x,y)**. And then C3 (which we HAVE as `limit_c3_interval_subset_point`) does the rest.

The question is: can we prove C5a (not just C5_weak) holds at the limit?

### 10. The Correct Strategic Path Forward

C5a at the limit requires the guard formula to end up in limit_g(x,y). Since limit_g is defined intersectively (all intermediate limit_f values), this is EQUIVALENT to guard ∈ limit_f(w) for ALL intermediate w. So proving C5a at the limit IS proving FUC directly — they are the same thing.

The way out is one of:

**Option A: Strengthen lemma_2_4 to include guard in the ENDPOINT f(y)**

If `ξ ∈ C` (i.e., guard ∈ f(y)), then:
- For any intermediate w with x < w < y, we can use C4 contrapositive (C4 is proved at the limit)
- If guard ∉ f(w), then ¬guard ∈ f(w). With ¬U(ξ,η) ∈ f(x)... wait, U(ξ,η) ∈ f(x), not its negation. C4 doesn't apply directly.

**Option B: Prove ξ ∈ g_n(x,y) at the stage when y is first created, then argue by C3 that ξ ∈ limit_f(w) for intermediate w via a separate induction**

After y is inserted at stage n+1, for any LATER stage m where w is inserted between x and y:
- At stage m, C3 gives g_m(x,y) = g_m(x,w) ∩ f_m(w) ∩ g_m(w,y)
- If ξ ∈ g_m(x,y), then ξ ∈ f_m(w) = limit_f(w) ✓
- But we need ξ ∈ g_m(x,y) at the MOMENT w is inserted

The g-values after C3 splitting are determined by the ADJACENT pair g-values (c2'). At the stage when w enters between x and y, the new g_m(x,w) and g_m(w,y) come from `lemma_2_6_splitting` applied to the adjacent pair (x,y) in the previous finite domain. This lemma produces D = f_m(w) such that:
- B = B' ∩ D ∩ B'' (Burgess 2.5 decomposition)
- B' and B'' come from the splitting of the original g_{n+1}(x,y) = B

So g_m(x,y) = g_m(x,w) ∩ f_m(w) ∩ g_m(w,y) = B' ∩ D ∩ B'' = B (the original g-value from when y was created!). This means ξ ∈ B = g_m(x,y) is PRESERVED through the splitting via Lemma 2.5.

**This is the key insight**: By Burgess Lemma 2.5, g(x,y) = B' ∩ D ∩ B'' where D = f(z) for intermediate z. So g(x,y) ⊆ f(z). But MORE: the g-values are constructed by Lemma 2.6 splitting to MAINTAIN the original g(x,y) value via the absorption formula. Therefore ξ ∈ g_{n+1}(x,y) is preserved as ξ ∈ g_m(x,y) for all m > n+1 (as long as x and y remain in the domain and no point between them has ξ.neg in its f-value).

### 11. Assessment of Required Work

**The gap**: We need `omega_chain_g_agrees` for non-adjacent pairs — specifically, if ξ ∈ omega_chain(n).g x y, then ξ ∈ omega_chain(n+1).g x y (g-values are non-increasing, and Lemma 2.5 tells us they are NON-STRICTLY non-increasing: B' ∩ D ∩ B'' = B when B is R-maximal).

**This requires:**
1. Proving that when a point z is inserted between x and y via Lemma 2.6 splitting, the new g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y) is EQUAL to the old g(x,y) (by Lemma 2.5). This is what Burgess 2.5 is for.
2. Adding `omega_chain_g_agrees` lemmas showing g_n(x,y) ⊆ g_{n+1}(x,y) is actually g_n(x,y) = g_{n+1}(x,y) when both x,y ∈ dom(n).
3. Defining `limit_g_burgess(x,y)` as the stable value g_n(x,y) for any n with both x,y ∈ dom(n).
4. Showing `limit_g_burgess(x,y) ⊆ limit_g(x,y)` (which follows from C3 at the limit).

**However**: The current implementation does NOT maintain g-values via Lemma 2.5 splitting — instead, the `omega_chain` definition only carries `c0` and `c2'`. The g-values are reconstructed independently at each adjacent pair. There is no `omega_chain_g_agrees` lemma. Adding it would require showing that the NEW g-values (from Lemma 2.6 splitting) satisfy B' ∩ f(z) ∩ B'' = B (the original adjacent g-value), which is exactly Burgess Lemma 2.5.

**This is achievable but requires significant new work:**
- Add `BurgessR3Maximal_absorption` (Burgess 2.5): if R(A, B', D) and R(D, B'', C) with B ⊆ B' ∩ D ∩ B'', then B = B' ∩ D ∩ B''
- This is already partially present as `burgessR3_absorption` in RRelation.lean (check)
- Add `omega_chain_g_stable` showing g(x,y) doesn't change when intermediate points are inserted
- Add `limit_g_equals_limit_g_burgess` showing the two g definitions coincide

### 12. Alternative: Enriched lemma_2_4 (guard-in-B approach from guard-in-B.md handoff)

The previous session added `burgessR3Maximal_with_guard` to RRelation.lean (builds, no sorry). The remaining work to enrich lemma_2_4:

1. Enrich the seed in lemma_2_4 to include `{snce(ξ, α) : α ∈ A}` (the Since-obligations from A)
2. Show this enriched seed is consistent (using iterated BX13 enrichment + BX10)
3. Get C from Lindenbaum on enriched seed, establishing burgessRSince(C, ξ, A)
4. From Lemma 2.3: burgessR(A, ξ, C) follows
5. Apply burgessR3Maximal_with_guard to get B with ξ ∈ B

**Mathematical validity check**: Is {η, {snce(ξ,α) : α ∈ A}} ∪ g_content(A) consistent when U(ξ,η) ∈ A?

This is the enriched seed consistency. Using BX13 (enrichment) from U(ξ,η): for any finite list α₁,...,αₙ ∈ A, U(ξ, η ∧ S(ξ,α₁) ∧ ... ∧ S(ξ,αₙ)) ∈ A. Then BX10 gives F(η ∧ S(ξ,α₁) ∧ ...) ∈ A, which (using g_content(A) ⊆ C) ensures consistency. This mirrors the forward_temporal_witness_seed_consistent approach but with BX13 enrichment folded in.

**This approach appears mathematically valid** and is what Burgess's Lemma 2.7 essentially proves (consistency of the enriched seed zeta = S(α,β∧η) ∧ β ∧ ξ ∧ U(γ,β)).

### 13. Quality Assessment and Final Product Vision

**Current state:**
- ChronicleToCountermodel.lean: 2 sorry sites at lines 634, 638
- All other Chronicle files: sorry-free
- CounterexampleElimination.lean: 0 sorries (CONFIRMED)

**What the final sorry-free theorem looks like:**
```lean
theorem bx_completeness (φ : Formula) :
    (∀ ..., truth_at ... φ) → DerivationTree [] φ
```

with `#print axioms bx_completeness` showing only `Classical.choice`, `propext`, `Quot.sound` — no `sorryAx`.

**Dead code to remove (after closing sorries):**
- The comment at ChronicleToCountermodel.lean:611-620 explaining the sorry blocker
- The `limit_satisfies_c5_weak` docs that say "full guard handled in integration phase"
- Possibly the `restrict_temporally_coherent` comments about "sorry sites pending"

**Cleanup opportunities:**
- The `c5_forward_witness` and `c5_forward_witness_with_guard` fields in EliminationResult can be merged if the stronger version is proved
- The `omega_chain` definition could simplify if g-agreement proofs are added

## Recommended Approach

**Recommended: Hybrid of Option B (enriched seed) + omega_chain_g_stable**

The two sorries require proving `limit_satisfies_c5_strong` (full C5 with guard at limit level). The cleanest path:

**Phase 1** (already done): `burgessR3Maximal_with_guard` in RRelation.lean. ✓

**Phase 2**: Enrich `lemma_2_4` in PointInsertion.lean:
- Add Since-obligation seed `{snce(ξ, α) : α ∈ A}` to the consistency proof
- Prove enriched seed consistency via iterated BX13 enrichment
- Add `ξ ∈ B` to the output type of `lemma_2_4`

**Phase 3**: Update `EliminationResult.c5_forward_witness_with_guard`:
- In the n=0 case: ξ ∈ B is now available from enriched lemma_2_4
- g'(x, y) := B, so ξ ∈ val.g x y

**Phase 4**: Add `omega_chain_g_stable` for the limit argument:
- Prove that when a point w is inserted between x and y (via Lemma 2.6 splitting), the new g(x,y) = original g(x,y) (Burgess 2.5 absorption)
- Conclude: for all m ≥ n+1, ξ ∈ omega_chain(m).g x y

**Phase 5**: Prove `limit_satisfies_c5_strong`:
- From phase 3: at stage n+1, ξ ∈ g_{n+1}(x,y)
- From phase 4: ξ persists in g_m(x,y) for all m ≥ n+1
- For any w ∈ limit_dom with x < w < y: w enters at some stage m ≥ n+1, so ξ ∈ g_m(x,y) ⊆ f_m(w) = limit_f(w)
- Therefore ξ ∈ limit_g(x,y)
- Combined with η ∈ limit_f(y) from c5_weak: done

**Phase 6**: Transfer through Cantor isomorphism in ChronicleToCountermodel.lean (same pattern as `cantor_bfmcs_restricted_tc`).

**Estimated effort**: 6-10 hours total.

The key mathematical facts are all in Burgess and all present in the codebase in related forms. The new work is:
1. Enriched lemma_2_4 seed consistency proof (~100-150 lines, mirrors existing infrastructure)
2. omega_chain_g_stable proof (~50-80 lines, uses Burgess 2.5 via lemma_2_5b)
3. limit_satisfies_c5_strong proof (~60-80 lines, assembles the pieces)
4. Cantor transfer (~20-30 lines, mirror of existing restricted_tc proof)

## Evidence and Examples

### Evidence that C3 provides guard propagation:
From `limit_c3_interval_subset_point` (ChronicleConstruction.lean:888-897):
```lean
theorem limit_c3_interval_subset_point ...
    (hxy : x < y) (hyz : y < z) :
    limit_g A h_mcs h_nubr3 x z ⊆ limit_f A h_mcs h_nubr3 y
```
This is PROVED. So if ξ ∈ limit_g(x,y), then ξ ∈ limit_f(w) for all w between x and y. The only missing piece is getting ξ into limit_g(x,y).

### Evidence that enriched lemma_2_4 is sound:
Burgess 2.7 (p.372) proves that the set {S(α,β∧η) ∧ β ∧ ξ ∧ U(γ,β)} is consistent using BX5+BX7+BX13. The enriched seed for lemma_2_4 is a subset of what Burgess proves consistent in 2.7. Our existing `lemma_2_7` in PointInsertion.lean already proved this consistency (it was sorry #2, now closed in Phase 3).

### Evidence that Burgess 2.5 absorption holds:
`burgessR3_absorption` exists in RRelation.lean (need to verify). If R(A, B', D), R(D, B'', C), B ⊆ B' ∩ D ∩ B'', then B = B' ∩ D ∩ B'' (Burgess 2.5). This is exactly what ensures g-values don't shrink under splitting.

## Confidence Level

high

The mathematical path is clear and each step is grounded in:
1. The Burgess paper (fully read and mapped)
2. Existing sorry-free code in the codebase
3. Prior sorry-free proofs of related lemmas (lemma_2_7 = sorry #2, closed in Phase 3)

The main uncertainty is implementation complexity: the enriched seed consistency proof requires careful BX13 iterated enrichment, but the infrastructure (`iterated_enrichment` in PointInsertion.lean ~line 1388) already exists.
