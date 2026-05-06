# Teammate B: Alternative Approaches — Guard Propagation Strategies

## Key Findings

### Problem Restatement

The 2 remaining sorries at `ChronicleToCountermodel.lean:634,638` require proving:
given `untl(φ,ψ) ∈ limit_f(x)`, produce `s > x` with `ψ ∈ limit_f(s)` AND `φ ∈ limit_f(r)` for ALL `r` in `(x,s)` intersected with `limit_dom`.

Convention: our `untl(guard=φ, event=ψ)` = Burgess `U(event=ξ, guard=η)`.

`limit_satisfies_c5_weak` gives the endpoint `s`. The guard `φ ∈ limit_g(x,s)` is missing.

`limit_g(x,s) = {a | ∀ r ∈ limit_dom, x < r → r < s → a ∈ limit_f(r)}`

---

### Alternative Approach A: Omega-Chain G-Value Tracking (Moderate Risk)

**Core Idea**: Track the Burgess g-function through the omega chain stages and propagate to the limit.

**The observation**: When `eliminate_potential_counterexample` handles a C5_forward counterexample in "Walk Case A" (n=0, `lemma_2_4` called), it creates:
- `g'(max_old, y) = B_l24` where `B_l24` is from `lemma_2_4`
- The guard formula φ is NOT guaranteed to be in `B_l24`

However, in "Walk Case B" (n≥1, condition (i) fails, `lemma_2_7` called), `lemma_2_7` returns:
- `BurgessR3Maximal(f(u_max), B', D)` and `BurgessR3Maximal(D, B'', f(u_next))`
- with `η ∈ B'` (event in B', not guard!)

**Critical observation from lemma_2_7's output type**: `lemma_2_7` at `PointInsertion.lean:3616` (per fuc-analysis.md) produces `xi ∈ D` where xi is the first argument to Until, and eta ∈ B'. Under our convention where `untl(guard, event)`, and Burgess `U(event=xi, guard=eta)`:
- In Burgess: xi = event, eta = guard
- In our code: `pc.ξ = guard`, `pc.η = event`

So in Walk Case B, `lemma_2_7 h_mcs_u_max h_mcs_u_next h_r3m_u h_B_sdc_u h_gc_u pc.ξ pc.η h_untl_u_max h_xi_g_u h_nubr3` produces `D` with... wait, let me re-read.

The output of `lemma_2_7` states "guard xi ∈ D and event eta ∈ B'". In our code at `CounterexampleElimination.lean:986-989`:
```
(fun ⟨B', D, B'', hB', hB'', hD, hη, _⟩ => ⟨B', D, B'', hB', hB'', hD, hη⟩)
  (lemma_2_7 h_mcs_x h_mcs_x' h_r3m_adj h_B_sdc h_gc_adj
    pc.ξ pc.η h_until h_xi_g h_nubr3)
```

The `hη` extracted here is `pc.η ∈ D` — the event is in D. The `_` discarded is presumably `pc.ξ ∈ B'`. So in Walk Case B, the guard `pc.ξ` is discarded from `B'`.

**The Real Opportunity (Absorption Lemma 2.5)**:

Burgess Lemma 2.5 states: if `R(A, B, C)` and we insert D with `R(A, B', D)` and `R(D, B'', C)` and `B ⊆ B' ∩ D ∩ B''`, then `B = B' ∩ D ∩ B''`.

This means when a new point is inserted with absorption: `g(x,s) ⊆ g(x,z)` and `g(x,s) ⊆ f(z)` and `g(x,s) ⊆ g(z,s)`.

**If guard ∈ g(x,s) at some finite stage n₀**, then for all future stages n > n₀:
- When a point z is inserted between x and s, Lemma 2.5 gives `g_n(x,s) ⊆ f_{n+1}(z)` 
- So guard ∈ `f_{n+1}(z)` for all such z inserted later
- This propagates to ALL limit_dom points between x and s

**The gap**: Guard is NOT in `g(x,s)` at the finite stage of C5 elimination (this is the root cause). But there's a cleaner path using `limit_satisfies_c5_weak` + Absorption.

**Proposal (A)**: Instead of trying to get guard into the finite g-values, use the *limit_dom density* + Absorption structure:
1. `limit_satisfies_c5_weak` gives witness endpoint `s` with `ψ ∈ limit_f(s)`
2. For any `r ∈ limit_dom` with `x < r < s`, we need `φ ∈ limit_f(r)`
3. `untl(φ, ψ) ∈ limit_f(x)` is our assumption
4. By Burgess 2.11: the dense order property + C4 means any r with `x < r < s` must have `φ ∈ f(r)` OR `¬φ ∈ f(r)` with a C4 counterexample between x and r

**Why this approach is blocked**: If `¬φ ∈ limit_f(r)` for some intermediate r, we need a C4 witness. But C4 (limit_satisfies_c4) requires `(untl(ξ,η)).neg ∈ limit_f(x)`, which we DON'T have — we have `untl(φ,ψ) ∈ limit_f(x)` (positive). C4 applies only when the Until formula is NEGATED at x.

**Assessment**: Blocked for the same reason as Approach 3 in fuc-analysis.md.

---

### Alternative Approach B: Strengthening EliminationResult with Guard-Carrying g-Values

**Core Idea**: Add a new field to `EliminationResult`:

```lean
c5_forward_witness_with_g : pc.kind = .c5_forward → pc.x ∈ χ.dom →
  Formula.untl pc.ξ pc.η ∈ χ.f pc.x →
  ∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧ pc.ξ ∈ val.g pc.x y
```

**Why this requires modifying lemma_2_4**: In Walk Case A (n=0), the interval `g'(max_old, y) = B_l24` where `B_l24` comes from `lemma_2_4`. Currently `B_l24` contains `g_content(f(x))` but NOT necessarily `pc.ξ` (the guard). To get `pc.ξ ∈ B_l24`, we need `lemma_2_4` to include guard in its output B.

**The enriched seed approach** (detailed in guard-in-B.md handoff):
- Enrich `lemma_2_4`'s seed to include `{snce(γ, α) : α ∈ A}` 
- This ensures `burgessRSince(C, γ, A)`, hence `burgessR(A, γ, C)` (by Lemma 2.3)
- Then `burgessR3Maximal_with_guard` produces B with `γ ∈ B`
- **Seed consistency** requires proving `{ψ} ∪ g_content(A) ∪ {snce(γ, α) : α ∈ A}` consistent

**Seed consistency analysis**:
We have `untl(γ, ψ) ∈ A`. By BX13 (enrichment_until): for any `α ∈ A`,
`untl(γ, ψ ∧ snce(γ, α)) ∈ A`. So `F(ψ ∧ snce(γ, α)) ∈ A` (by BX10).

For a finite subset `L ⊆ {ψ} ∪ g_content(A) ∪ {snce(γ, α_i) : α_i ∈ A}`:
- Pick `α_big = α_1 ∧ ... ∧ α_k` (finite conjunction of the α_i)
- `untl(γ, ψ ∧ snce(γ, α_big)) ∈ A` by iterated BX13 enrichment (infrastructure at `iterated_enrichment`)
- For each `G(φ_j) ∈ A`: `untl(γ, ψ ∧ snce(γ, α_big) ∧ φ_j) ∈ A` by BX3 right-monotonicity
- So `F(big_conjunction) ∈ A`, proving L consistent via `forward_temporal_witness_seed_consistent`

**This IS the path described in guard-in-B.md**. It requires:
1. Modifying `lemma_2_4` signature: add `γ ∈ B` to output
2. Updating callers in `CounterexampleElimination.lean`
3. Proving guard propagation through Walk Cases B (n≥1)

**Walk Case B guard propagation**: In Walk Case B, the elimination finds u_max and u_next with `untl(pc.ξ, pc.η) ∈ f(u_max)`. It then calls `lemma_2_7` (or splitting variants) which insert D with `pc.η ∈ D`. For the guard:
- Walk Case B calls `lemma_2_7` with `pc.ξ ∉ g(u_max, u_next)` 
- `lemma_2_7` output (from Burgess): `η ∈ B'` and `ξ ∈ D` (guard in the NEW intermediate point)
- But we need guard at ALL points between x and the final witness y

**Crucial insight**: In Walk Case B, `g'(u_max, z) = B'` and `g'(z, u_next) = B''`. The witness y is z = midpoint of u_max and u_next. `pc.η ∈ D = f'(z)`. The guard path: we need `pc.ξ ∈ g'(x, z)` for z = the new witness.

But the C5_forward_witness only provides `pc.η ∈ val.f y` — there's NO guarantee that `pc.ξ ∈ val.g pc.x y` at the finite stage, because in Walk Case B the interval `g'(x, z)` depends on the original `g(x, ...)` values which don't automatically contain the guard.

**Assessment (Approach B)**: Requires modifying `lemma_2_4` AND also handling Walk Case B guard propagation. Walk Case B is the harder part and may not work without a deeper construction change. Medium-high risk. This is the primary approach from guard-in-B.md.

---

### Alternative Approach C: MCS Axiomatic Derivation at Limit Level (No Construction Change)

**Core Idea**: Prove guard directly from axioms at the limit level, without any construction-level changes.

**Observation**: `untl(φ, ψ) ∈ limit_f(x)` with `x < r < s` and `ψ ∈ limit_f(s)`. Can we prove `φ ∈ limit_f(r)` from MCS properties alone?

**Attempt**: Suppose `φ ∉ limit_f(r)`. Then `φ.neg ∈ limit_f(r)`. By `connect_future_mcs` (BX4): `G(P(φ.neg)) ∈ limit_f(r)`. By `limit_forward_G`: `P(φ.neg) ∈ limit_f(s)`. But `ψ ∈ limit_f(s)` and `untl(φ, ψ) ∈ limit_f(x)`. Can we derive contradiction?

`P(φ.neg) ∈ limit_f(s)` means "φ was false in the past of s", which is consistent with `untl(φ, ψ)` being true at x if the witness y satisfying the interval guard is NOT s itself but some other point. No immediate contradiction.

**Attempt via C4**: We cannot use C4 to derive guard failure since C4 requires `(untl(φ,ψ)).neg ∈ f(x)`.

**Attempt via BX axioms at r**: We have `untl(φ, ψ) ∈ limit_f(x)` but NOT at r. No BX axiom propagates `untl` forward to intermediate points under open guard semantics.

**Attempt via BX4 + G propagation**: If `G(φ) ∈ limit_f(x)`, then `limit_forward_G` gives `φ ∈ limit_f(r)`. But `G(φ) ∈ limit_f(x)` is much stronger than `untl(φ, ψ) ∈ limit_f(x)` and is NOT deducible from it.

**Assessment (Approach C)**: BLOCKED. Under open guard semantics, `untl(φ,ψ) ∈ f(x)` does NOT force φ at x or at points between x and the witness. No pure axiomatic path exists without construction changes. Confirmed by fuc-analysis.md Approach 2.

---

### Alternative Approach D: BX13 Enrichment to Self-Embedding Guard

**Core Idea**: Use BX13 to enrich the Until formula so the guard appears in the event.

**BX13** (enrichment_until): `p ∈ A ∧ untl(φ,ψ) ∈ A → untl(φ, ψ ∧ snce(φ,p)) ∈ A`

From `untl(φ,ψ) ∈ limit_f(x)`, by BX5 (self-accumulation): `untl(φ ∧ untl(φ,ψ), ψ) ∈ limit_f(x)`.

By `limit_satisfies_c5_weak` for the enriched formula: get `s` with `ψ ∈ limit_f(s)`.

For any intermediate `r`, we need `φ ∧ untl(φ,ψ) ∈ limit_f(r)`. This is the ENRICHED guard. But this still requires the guard (including `untl(φ,ψ)`) to be in `limit_g(x,s)`, which is the same problem.

**BX13 applied differently**: If we use BX13 with `p = α` for arbitrary `α ∈ limit_f(x)`, we get `untl(φ, ψ ∧ snce(φ,α)) ∈ limit_f(x)`. The witness gives some `s` with `ψ ∧ snce(φ,α) ∈ limit_f(s)`. Now `snce(φ,α) ∈ limit_f(s)` means "φ was true since some past time with α". This constrains the interval to the PAST of s, not the future from x.

**Assessment (Approach D)**: BX13 enrichment cannot extract the guard from the Until formula's obligation at intermediate points. This was already tried (fuc-analysis.md Approach 3 variant). BLOCKED.

---

### Alternative Approach E: Density + Infimum Argument

**Core Idea**: Among witnesses `{y > x : ψ ∈ limit_f(y)}`, find an infimum and argue that the interval (x, inf) has the guard everywhere.

**Issues**:
1. `limit_dom` is countable, and the infimum of a subset of `limit_dom` need not be in `limit_dom`
2. Even if infimum exists in `limit_dom`, we would need ψ ∈ limit_f(inf), which requires a density argument around the infimum
3. Between x and the infimum-witness, we'd still need to show guard holds

This was analyzed in fuc-analysis.md as Approach 4. The fundamental problem: no guarantee the set of witnesses has an infimum in `limit_dom`.

**Assessment (Approach E)**: BLOCKED.

---

### Alternative Approach F: Thread Burgess g-Values Through the Chain (Structural)

**Core Idea** (from phase7-fuc-fsc.md "Recommended Approach"):

1. Add `omega_chain_g_agrees` lemmas (analogous to existing `omega_chain_f_agrees`)
2. Define `limit_g_burgess(x,y)` as the limit of the finite g-values from the chain
3. Prove `limit_g_burgess(x,y) ⊆ limit_g(x,y)` using C3 + density
4. Prove that when C5 counterexample `(x,ξ,η)` is eliminated at step n, `η ∈ g_n(x,y_n)` for the newly inserted `y_n`
5. Show this persists: for all stages m > n, `η ∈ g_m(x,y_n)` (g-values don't decrease)
6. Conclude `η ∈ limit_g_burgess(x,y_n) ⊆ limit_g(x,y_n)`

**Sub-problem**: Step 4 requires guard (our φ = Burgess η) in the finite g-value. This is exactly what guard-in-B.md's Phase 2 modifies `lemma_2_4` to provide. So this approach ALSO requires modifying `lemma_2_4`.

**But there's a new insight**: The g-values at the finite stages INHERIT the C3 property. Specifically:

When we insert z between u_max and u_next in Walk Case B:
- `g_new(u_max, z) = B'` and `g_new(z, u_next) = B''`
- By Lemma 2.5 (absorption): `g_old(u_max, u_next) = B' ∩ D ∩ B''`
- So `g_old(u_max, u_next) ⊆ B' = g_new(u_max, z)`
- So `g_old(u_max, u_next) ⊆ f_new(z)` (since `g_old ⊆ D = f_new(z)`)

This means: **any formula in the OLD g-value propagates to the new intermediate point**. If guard φ were in `g(x, s)` at some stage, it would propagate to all future intermediate insertions.

**The bootstrap problem**: Guard is NEVER in the initial g-value because `lemma_2_4` seeds B with `g_content(A)` only.

**Assessment (Approach F)**: Still requires modifying `lemma_2_4` as the root fix. The g-value tracking is then straightforward (C3 absorption handles propagation). This is the same as Teammate A's primary approach, just framed differently.

---

### Alternative Approach G: Use lemma_2_7's Guard Output Directly

**Core Idea**: lemma_2_7 produces `pc.ξ ∈ B'` (guard in the left interval). Can we exploit this?

From the elimination code, `lemma_2_7` is called in Walk Case B when `pc.ξ ∉ g(u_max, u_next)`. The output is:
- `BurgessR3Maximal(f(u_max), B', D)`  
- `BurgessR3Maximal(D, B'', f(u_next))`
- `pc.η ∈ D` (event in new point) and `pc.ξ ∈ B'` (guard in left interval)

The guard is in `B' = g'(u_max, z)` where z is the new midpoint. This IS available but currently discarded with `_` in the code!

**Approach**: Strengthen `c5_forward_witness_with_g` to track this. For the Walk Case B subcase where `lemma_2_7` is used:
- `pc.ξ ∈ g'(u_max, z)` = `pc.ξ ∈ val.g u_max z`
- But we need `pc.ξ ∈ val.g pc.x z` for the ORIGINAL source x, not u_max

These differ when `pc.x < u_max` (condition (i) forward-walk extended x further right).

**Assessment (Approach G)**: This provides guard ∈ g(u_max, z) but NOT g(x, z) when x < u_max. The forward walk introduces a gap. Not directly usable.

---

### Alternative Approach H: Separate C5_strong Counterexample Kind

**Core Idea**: Add a new `PotentialCounterexampleKind`: `c5_forward_strong`, that tracks not just endpoint satisfaction but full guard propagation. Process `c5_forward_strong` counterexamples separately with a strengthened elimination that produces `ξ ∈ val.g pc.x y`.

**Analysis**: This is essentially restructuring approach B. The elimination for `c5_forward_strong` would need a modified `lemma_2_4` producing guard in B. The omega-chain would process these separately.

**Risk**: Adds complexity to the omega-chain structure. Requires separate surjectivity proofs for the new kind.

**Assessment (Approach H)**: More complex than modifying `lemma_2_4` directly. High risk.

---

## Burgess 2.11 Direct Path (Cleanest Alternative)

**The cleanest path**, looking at Burgess 2.11 directly:

Burgess says: "If `U(ξ,η) ∈ f(x)`, then by C5a there exists `y` with `ξ ∈ f(y)` [our: η ∈ f(y)] and `η ∈ g(x,y)` [our: φ ∈ g(x,y)]. If z ∈ X with x < z < y, then by C3 we have `g(x,y) ⊆ f(z)`, whence `η ∈ f(z)` [our: φ ∈ f(z)]."

Burgess's argument REQUIRES C5a to produce both the endpoint AND guard in g(x,y) simultaneously. Our current construction only gives the endpoint (C5_weak). The guard-in-g is the missing piece.

**The only valid path**: Strengthen C5 to C5_full, which requires the finite-stage g to carry the guard. This requires modifying `lemma_2_4` (for the n=0 case) and verifying Walk Case B works (guard propagates via lemma_2_7's `ξ ∈ B'` output, but only for the IMMEDIATE insertion interval, not for x..u_max).

**Walk Case A (n=0)**: Direct fix via modified `lemma_2_4` — guard in B_l24 = g(max_old, y). Then `ξ ∈ g(x, y)` if x = max_old. But x is the ORIGINAL counterexample point, not necessarily max_old. When x = u_max in Walk Case A, we have `ξ ∈ B_l24 = g(u_max, y)`. And `g(x, y)` for x ≤ u_max... if x < u_max, the path goes through the existing g-values.

**Walk Case B is the harder case**: x < u_max < z < y_eventual. Even with guard in g(u_max, z) from lemma_2_7, getting guard in g(x, z) requires g(x, u_max) ⊆ g(x, z) (C3 monotonicity), which holds IF g is properly threaded. But the current construction at finite stages doesn't thread g transitively — each elimination is local.

---

## Recommended Approach

**Approach B (modified lemma_2_4) with careful Walk Case B analysis** is the primary path, as identified in guard-in-B.md. The specific contributions of this analysis:

1. **The enriched seed IS consistent**: BX13 provides the needed chain. The guard-in-B.md Phase 2 seed enrichment strategy is mathematically correct.

2. **Walk Case B guard propagation via absorption**: When Walk Case B splits at (u_max, u_next) and inserts z:
   - `lemma_2_7` gives `pc.ξ ∈ B' = g'(u_max, z)`
   - By C3 absorption: `g_old(x, u_max) ⊆ g'(x, z)` (automatic from BurgessR3Maximal splitting)
   - But we need `g_old(x, u_max)` to already contain `pc.ξ`
   - This is recursive: we need the PREVIOUS stage's g to already have the guard
   
3. **The bootstrapping issue is real**: In Walk Case B, the forward walk advances from x to u_max (via condition (i) propagation), at which point `untl(pc.ξ, pc.η) ∈ f(u_max)`. The guard at u_max comes from the WALK itself — at each intermediate step where condition (i) holds, the guard is inherited through the f-values (xi∧untl(xi,eta) ∈ f, so xi ∈ f). But this is at the POINT level, not the g-VALUE level.

4. **A simpler guard-at-limit argument using the forward walk**:

   In Walk Case B, condition (i) ensures `ξ ∧ untl(ξ,η) ∈ f(x')` for x' = immediate successor of x. By the forward walk, we find u_max = the LAST point with `untl(ξ,η) ∈ f(u_max)`, and `untl(ξ,η) ∉ f(u_next)`. The key: at u_max, `pc.ξ ∈ f(u_max)` via... actually NOT guaranteed. `untl(ξ,η) ∈ f(u_max)` but `ξ ∈ f(u_max)` requires the Until formula to give us the guard at the current point — invalid under open guard semantics.

5. **Conclusion**: The root fix must be in `lemma_2_4`. For Walk Case B, the guard in `B' = g'(u_max, z)` from `lemma_2_7` is the right mechanism, but threading this back to the ORIGINAL counterexample source x requires:
   - Finite-stage g-value monotonicity: if guard ∈ g_n(x, y) for some stage n, then guard ∈ g_m(x, z) for all z < y inserted later (by C3 absorption)
   - This is Approach F (limit_g_burgess)
   - Combined with modified `lemma_2_4` providing guard ∈ B for the n=0 case

## Evidence/Examples

**Concrete trace in Walk Case A (n=0)**: 
- x = max_old, `untl(φ, ψ) ∈ f(x)`
- Modified `lemma_2_4` produces B with `φ ∈ B` and `ψ ∈ C`
- Set `g(x, y) = B` — so `φ ∈ g(x, y)`
- At limit: `φ ∈ limit_g(x, y)` iff φ ∈ f(r) for all r ∈ (x,y) ∩ limit_dom
- Points inserted between x and y: none initially (y > max_old = domain max)
- Points inserted later: by C3 absorption, `g(x, y) ⊆ g(x, r)` and `g(x, y) ⊆ f(r)` for inserted r
- So `φ ∈ B ⊆ f(r)` for all r inserted between x and y

This shows Walk Case A is straightforwardly handled by modifying `lemma_2_4`.

**Walk Case B challenge**: Not yet fully resolved. Requires the g-value threading.

## Confidence Level

**high** that modifying `lemma_2_4` to produce `guard ∈ B` is the correct root fix.  
**medium** that Walk Case B guard propagation follows from the existing lemma_2_7 output + C3 absorption threading.  
**low** that any alternative approach (C, D, E, G, H) avoids modifying `lemma_2_4`.

## Files Relevant to Implementation

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`: `lemma_2_4` at line 158, `lemma_2_7` at ~line 975
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`: Walk Case A at line 664, Walk Case B at line 749, `EliminationResult` at line 602
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`: `limit_g` at line 845, `limit_satisfies_c5_weak` at line 590

## Summary of Novel Findings

1. **Approach G is partially viable but incomplete**: `lemma_2_7` already produces `pc.ξ ∈ B'` but this is currently discarded. Exposing it gives guard in the IMMEDIATE left interval but not the full (x, y_final) interval.

2. **C3 absorption propagation (Lemma 2.5) IS the mechanism for Walk Case B**: Once guard is in g(u_max, z), the absorption property B = B' ∩ D ∩ B'' ensures it propagates to all future insertions between u_max and u_next. This is the "free propagation" path mentioned in the assignment.

3. **The bootstrapping gap**: Getting guard into g(x, u_max) for x < u_max when the forward walk was used — this requires either (a) guard in g(x, u_max) from previous stages, or (b) the Walk Case A fix at the deepest level. Since the walk eventually reaches max_old (Case A), the modified `lemma_2_4` DOES provide guard in g(max_old, y). The question is whether this propagates back to g(x, y) for x < max_old.

4. **The propagation is back-to-front**: g-values are computed from right to left (from max_old backwards via C3). Guard ∈ g(max_old, y) gives guard ∈ g(x, y) for all x ≤ max_old only IF the C3 identity is maintained correctly. In a dense domain, this follows from the definition of limit_g.
