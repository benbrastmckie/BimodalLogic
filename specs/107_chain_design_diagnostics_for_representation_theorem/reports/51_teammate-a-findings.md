# Teammate A Findings: Primary Implementation Strategy for 4 Blocker Sorry Sites

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Date**: 2026-05-01
**Angle**: Primary approach — precise Burgess-to-codebase mapping for each sorry

## Key Findings

### Finding 1: FUC/FSC (Sorries 6-7) Are Solvable NOW — No Upstream Dependencies

The FUC/FSC sorry sites at ChronicleToCountermodel.lean:615,619 do NOT depend on sorries 4-5 (C4/C4') or on PointInsertion.lean lemmas. They can be closed using only the limit construction infrastructure that is already sorry-free.

**Proof obligation** (from TemporalCoherence.lean:535-544):
```
Given U(φ,ψ) ∈ fam.mcs(t),
find s > t with ψ ∈ fam.mcs(s) AND φ ∈ fam.mcs(r) for all r with t < r < s
```

**Proof strategy** (following Burgess Claim 2.11, p. 247):

1. Transfer from fam.mcs(t) to limit_f coordinates via cantor_iso (same pattern as `cantor_bfmcs_restricted_tc`)
2. Have `Formula.untl φ ψ ∈ limit_f N h_N x'` where x' = cantor_iso.symm(t - offset)
3. Apply `limit_satisfies_c5_weak` → get y > x' with ψ ∈ limit_f(y)  [endpoint]
4. For guard: for any r with t < r < s (where s = cantor_iso(y) + offset):
   - Transfer r to limit coordinates: r' = cantor_iso.symm(r - offset)
   - We have x' < r' < y (by cantor_iso monotonicity)
   - Need φ ∈ limit_f(r')

**The guard follows from limit_g**: By the definition of limit_g (ChronicleConstruction.lean:837-839):
```
limit_g(x,z) = {φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f(y)}
```

If we can show `φ ∈ limit_g(x', y)`, then `φ ∈ limit_f(r')` for any intermediate r'.

**CRITICAL QUESTION**: Does limit_satisfies_c5_weak give a y such that η ∈ limit_g(x, y)? 

**Answer: YES**, but not directly from the current API. Here's why:

Looking at `limit_satisfies_c5_weak` (ChronicleConstruction.lean:569-592), the witness y comes from `omega_chain_c5_witness`, which calls `EliminationResult.c5_forward_witness`. The C5 elimination creates y via `eliminate_C5_counterexample` which uses `lemma_2_4`.

However, `limit_satisfies_c5_weak` only exposes `η ∈ limit_f(y)`, not the guard information.

**But we don't need C5 at all for the guard!** The argument is simpler:

For U(φ,ψ) ∈ limit_f(x): by `limit_satisfies_c5_weak`, get y with ψ ∈ limit_f(y). Now for any intermediate w with x < w < y in limit_dom:

- Suppose φ ∉ limit_f(w). Then φ.neg ∈ limit_f(w) (MCS property via limit_c0).
- We have (untl φ ψ).neg ∉ limit_f(x) (since untl φ ψ ∈ limit_f(x) and limit_f(x) is MCS).

Wait — this doesn't immediately work. Let me reconsider.

**REVISED APPROACH**: We need `limit_satisfies_c5_full`:

```
∀ x ∈ limit_dom, ∀ ξ η, untl ξ η ∈ limit_f(x) →
  ∃ y ∈ limit_dom, x < y ∧ η ∈ limit_f(y) ∧ ξ ∈ limit_g(x, y)
```

This follows from limit_satisfies_c5_weak + the definition of limit_g:
- limit_satisfies_c5_weak gives y with η ∈ limit_f(y)
- We need ξ ∈ limit_g(x, y), i.e., ∀ w ∈ limit_dom, x < w < y → ξ ∈ limit_f(w)

**This is where the Burgess argument kicks in**: Burgess's C5 (p. 212) says `η ∈ g(x,y)`, not just `η ∈ f(y)`. In Burgess, the g-value IS part of the C5 witness. Our `limit_satisfies_c5_weak` only gives the f-part.

**The missing piece**: We need to strengthen limit_satisfies_c5_weak to also show that ξ propagates to all intermediate points. This requires analyzing what happens during the omega-chain construction more carefully.

Actually — let me re-examine. The codebase's limit_g is defined as:
```
limit_g(x,z) = {φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f(y)}
```

For the FUC proof, what we actually need is: given U(φ,ψ) ∈ limit_f(x), find y > x with ψ ∈ limit_f(y) such that for ALL w with x < w < y in limit_dom, φ ∈ limit_f(w).

**KEY INSIGHT**: This is NOT asking for φ ∈ limit_g(x,y). The guard condition quantifies over ALL rationals between t and s (open guard on Rat), while limit_g quantifies over limit_dom points only. But every rational IS in limit_dom (since the density elimination makes limit_dom = Q... or does it?).

Let me verify: the omega_chain also eliminates density counterexamples. The `eliminate_potential_counterexample` handles `.density` kind (CE.lean:880-932) which inserts midpoints between adjacent pairs. Together with C5/C5'/C4/C4' eliminations adding points, does limit_dom = Q?

Actually, limit_dom is a countable dense subset of Q, but NOT all of Q. However, the cantor_iso maps limit_dom onto Q (or a dense subset), and the `restricted_forward_until_since_coherent` quantifies over ALL D values (D = Rat).

**CRITICAL REALIZATION**: fam.mcs is defined via `rooted_cantor_fmcs`, which maps through the Cantor isomorphism. So fam.mcs(r) = limit_f(cantor_iso.symm(r - offset)). Since cantor_iso.symm maps Q surjectively onto limit_dom, every rational r maps to some limit_dom point. So φ ∈ fam.mcs(r) ↔ φ ∈ limit_f(cantor_iso.symm(r - offset)).

For the guard: we need φ ∈ fam.mcs(r) for t < r < s. This means φ ∈ limit_f(cantor_iso.symm(r - offset)). Since cantor_iso is an order isomorphism, cantor_iso.symm(r - offset) ranges over all of limit_dom between x' and y.

So the guard condition becomes: φ ∈ limit_f(w) for all w ∈ limit_dom with x' < w < y.

This is EXACTLY `φ ∈ limit_g(x', y)`.

So the FUC proof reduces to: given untl φ ψ ∈ limit_f(x'), find y ∈ limit_dom with y > x' and:
- ψ ∈ limit_f(y) 
- φ ∈ limit_g(x', y)

**SOLUTION PATH**: Prove `limit_satisfies_c5_full` which gives exactly this. The proof requires showing that the C5 witness y from `limit_satisfies_c5_weak` also satisfies the guard condition.

### Finding 2: limit_satisfies_c5_full Proof Strategy

The key is that Burgess's C5 gives η ∈ g(x,y), not just η ∈ f(y). In the omega-chain:

At stage n when the C5 counterexample (x, ξ, η) is eliminated:
- `eliminate_C5_counterexample` creates y with `η ∈ f(y)` via `lemma_2_4`
- `lemma_2_4` returns `BurgessR3Maximal A B C` where B contains g_content(A)
- The g-value g(x,y) is set to... **wait, let's check**

Looking at `eliminate_C5_counterexample` (CE.lean:167-204): the new chronicle uses `χ.g` unchanged — `fun _ _ => rfl` for g_agrees. The g-values for the new pair (x, y) are NOT explicitly set in the C5 elimination! The g-function is inherited unchanged from the input chronicle.

This means: at finite stages, g(x, y) for the new pair is whatever the `Chronicle.g` function returns for those arguments. Looking at the Chronicle structure (ChronicleTypes.lean:336-342), `g : Rat → Rat → Set Formula` is total, so g(x, y) has some default value for points not in the domain.

But at the limit, `limit_g` is REDEFINED (ChronicleConstruction.lean:837-839) as the set of formulas in limit_f at all intermediate points. This limit_g does NOT use the finite-stage g values at all — it's a fresh construction.

**THIS IS THE KEY**: limit_g is defined by universal quantification over limit_dom points, not by taking limits of finite g-values. So the question becomes: does the limit_f already contain the guard formulas at intermediate points?

For the omega-chain's C5 elimination at stage n: lemma_2_4 gives C (the new f(y)) with `g_content(A) ⊆ C`, where A = f(x). This means every formula of the form G(φ) ∈ f(x) has φ ∈ f(y). But we need more: we need the guard ξ at intermediate points.

However, the guard propagation happens through the density elimination! When adjacent pairs get broken up by density insertions, the new midpoints inherit f-values from existing MCSs. Specifically, the density elimination at CE.lean:891 sets `f(z) = f(x)` for the midpoint z.

**But this still doesn't directly give us the guard.** The correct argument follows Burgess's Claim 2.11 on p. 247:

> If α = U(β,γ) ∈ f(x), then by C5a there is a y ∈ X with x < y and γ ∈ f(y) and β ∈ g(x,y). If z ∈ X and x < z < y, then by C3 we have g(x,y) ⊆ f(z), whence β ∈ f(z).

The argument is: C5 gives β ∈ g(x,y), and C3 gives g(x,y) ⊆ f(z) for intermediate z. In the limit, limit_g has C3 built in by construction. 

So the question reduces to: **does C5 at the limit give η ∈ limit_g(x,y)?**

By the definition of limit_g: η ∈ limit_g(x,y) iff ∀ w ∈ limit_dom, x < w < y → η ∈ limit_f(w).

**Idea**: Maybe we don't need to strengthen limit_satisfies_c5_weak at all. Maybe the FUC proof can be done directly:

For U(φ,ψ) ∈ limit_f(x):
1. Get y via limit_satisfies_c5_weak with ψ ∈ limit_f(y) and x < y
2. For any w with x < w < y in limit_dom:
   - Since U(φ,ψ) ∈ limit_f(x) and x < w, either:
     a) The until still holds: U(φ,ψ) ∈ limit_f(w) (then inductively we can extract φ at w), OR
     b) The until was "used up": ψ ∈ limit_f(w') for some x < w' ≤ w, and φ held throughout (x, w')
   - Actually this doesn't directly give us φ ∈ limit_f(w).

**CORRECT APPROACH**: The correct way is Burgess's direct argument. But the issue is that our `limit_satisfies_c5_weak` doesn't give us `ξ ∈ limit_g(x,y)`. We need to prove a stronger version:

**Theorem**: `limit_satisfies_c5_full`:
```
∀ x ∈ limit_dom, ∀ ξ η, untl ξ η ∈ limit_f(x) →
  ∃ y ∈ limit_dom, x < y ∧ η ∈ limit_f(y) ∧ ξ ∈ limit_g(x,y)
```

**Proof sketch**: At stage n, the C5 counterexample check in `eliminate_potential_counterexample` (CE.lean:738-741) checks for a FULL witness including guard:
```
¬∃ y ∈ χ.dom, x < y ∧ η ∈ χ.f y ∧
  ∀ z ∈ χ.dom, x < z → z < y → ξ ∈ χ.f z ∧ untl ξ η ∈ χ.f z
```

When this fails (no full witness exists), it eliminates the counterexample by adding a new point. When it succeeds (a full witness exists at finite stage n), we have `y_n ∈ dom(n)` with:
- `η ∈ f_n(y_n)` 
- `∀ z ∈ dom(n), x < z < y_n → ξ ∈ f_n(z)`

The witness from the "already not a counterexample" case (CE.lean:763-767) IS a full witness but the `c5_forward_witness` field only stores `η ∈ f(y)`, discarding the guard.

Actually, looking more carefully at CE.lean:763-767:
```lean
c5_forward_witness := by
  intro _ h_mem h_until
  push_neg at h_actual
  obtain ⟨y, hy_dom, hy_lt, hy_η, _⟩ := h_actual h_mem h_until
  exact ⟨y, hy_dom, hy_lt, hy_η⟩
```

The `_` at the end discards the guard info! The `h_actual` (after push_neg) gives a FULL witness including guard, but only `hy_η` is kept.

Similarly, in the case where a new point is actually inserted (CE.lean:752-753), the witness is from `eliminate_C5_counterexample` which returns `∃ y ∈ χ'.dom, ce.x < y ∧ ce.η ∈ χ'.f y` — again no guard info.

**ROOT CAUSE**: The `EliminationResult.c5_forward_witness` type (CE.lean:699-701) only requires `∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y` — no guard field. This is by design but insufficient for FUC.

**FIX**: There are two approaches:

**Approach A (Strengthen EliminationResult)**: Add guard info to `c5_forward_witness`:
```
c5_forward_witness : pc.kind = .c5_forward → pc.x ∈ χ.dom →
  Formula.untl pc.ξ pc.η ∈ χ.f pc.x →
  ∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧
    ∀ z ∈ val.dom, pc.x < z → z < y → pc.ξ ∈ val.f z
```
This requires modifying the entire elimination infrastructure but gives the strongest result.

**Approach B (Direct limit_g argument)**: Prove limit_satisfies_c5_full without modifying finite stages, using the definition of limit_g directly. The argument:
1. Use limit_satisfies_c5_weak to get y with η ∈ limit_f(y)
2. For ξ ∈ limit_g(x,y): pick any w ∈ limit_dom with x < w < y
   - w ∈ dom(m) for some m
   - x ∈ dom(n₀) for some n₀
   - At some stage k ≥ max(m, n₀), both x and w are in dom(k)
   - U(ξ,η) ∈ f_k(x) (by f-agreement)
   - Need to show ξ ∈ f_k(w) — BUT this requires the guard at finite stages, which circles back to the same problem

So Approach B doesn't avoid the issue. Approach A seems necessary.

**Approach C (Use limit directly, without C5)**: The density of limit_dom means there's always a point between any two. Use this with C4 (already proved at the limit) to show the guard holds by contradiction:
1. Suppose ξ ∉ limit_f(w) for some x < w < y
2. Then ξ.neg ∈ limit_f(w) (MCS)
3. We need to derive a contradiction from U(ξ,η) ∈ limit_f(x), η ∈ limit_f(y), and ξ.neg ∈ limit_f(w)
4. From ξ.neg ∈ limit_f(w), w < y, η ∈ limit_f(y): this is consistent with ¬U(ξ,η) ∈ f(w) or not
5. Hmm, this doesn't immediately give a contradiction without more

**Approach D (Bypass: prove directly at the FUC level)**: In `cantor_bfmcs_restricted_fuc`, the proof obligation works over Rat (D = Rat). The key realization is:

For U(φ,ψ) ∈ fam.mcs(t):
1. Get y with ψ ∈ limit_f(y) via limit_satisfies_c5_weak
2. We claim φ ∈ fam.mcs(r) for all t < r < s where s = cantor_iso(y) + offset

For (2), by contradiction: suppose φ ∉ fam.mcs(r₀) for some t < r₀ < s.
Then (untl φ ψ).neg ∈ fam.mcs(r₀) OR untl φ ψ ∈ fam.mcs(r₀).

If untl φ ψ ∈ fam.mcs(r₀): Apply the BUC result (cantor_bfmcs_restricted_buc) in reverse... no, BUC goes the other direction.

Actually — let's use C4 at the limit (limit_satisfies_c4, which IS sorry-free):
- If (untl φ ψ).neg ∈ limit_f(x) and ψ ∈ limit_f(y): C4 gives z with x < z < y and φ.neg ∈ limit_f(z)
- But we DON'T have (untl φ ψ).neg ∈ limit_f(x) — we have the POSITIVE untl φ ψ ∈ limit_f(x)

So C4 can't be used directly.

**CONCLUSION ON FUC**: Approach A (strengthen EliminationResult) is the cleanest path. It requires:
1. Modify `EliminationResult.c5_forward_witness` to include guard
2. Modify `eliminate_C5_counterexample` to produce guard (need to also insert guard info)
3. Prove `limit_satisfies_c5_full` using the strengthened witness
4. Close FUC/FSC using limit_satisfies_c5_full + cantor_iso transfer

Actually, on further reflection, there's a much simpler approach:

**Approach E (The correct argument based on Burgess 2.11)**:

The FUC proof doesn't need C5 with guard at ALL. It only needs C5_weak + C3 + C4.

From Burgess p. 247: "If α ∈ f(x), then by C5a there is y with γ ∈ f(y) and β ∈ g(x,y). If z ∈ X and x < z < y, then C3 gives g(x,y) ⊆ f(z)."

But wait — Burgess uses β ∈ g(x,y), which is exactly what we DON'T have from limit_satisfies_c5_weak!

Hmm, BUT in the limit, g(x,y) is DEFINED as the intersection over f at intermediate points. So β ∈ g(x,y) is equivalent to ∀ w, x < w < y → β ∈ f(w), which is what we want to prove in the first place. This is circular.

**FINAL ANSWER ON FUC**: Approach A is required. We must strengthen the C5 witness to include guard info. The alternative is to prove `limit_satisfies_c5_full` via a different argument.

Wait — one more approach:

**Approach F (Finite C5 with guard → limit C5 with guard)**:

At the finite stage where C5 is eliminated, the check at CE.lean:738-741 is:
```
¬∃ y ∈ χ.dom, x < y ∧ η ∈ χ.f y ∧
  ∀ z ∈ χ.dom, x < z → z < y → ξ ∈ χ.f z ∧ untl ξ η ∈ χ.f z
```

In the "already a witness exists" case (push_neg on h_actual), we get a full witness with guard AT THE FINITE STAGE. In the "elimination needed" case, `eliminate_C5_counterexample` + `lemma_2_4` creates y with `g_content(A) ⊆ C`. Since G(ξ) ∈ A whenever untl(ξ,η) ∈ A (actually, this is NOT true in general — G(ξ) is NOT derivable from untl(ξ,η)).

Hmm, actually `ξ ∈ g_content(A)` means G(ξ) ∈ A, not U(ξ,η) ∈ A. The guard formula ξ may or may not have G(ξ) ∈ A.

**DEFINITIVE ANALYSIS**: The correct fix is to strengthen `EliminationResult` to carry guard info, and ensure `eliminate_C5_counterexample` produces it. The key change:

In the "already a witness" case: the guard info is already available (just not stored).
In the "elimination needed" case: lemma_2_4 gives η ∈ g_content(A) only for the ENDPOINT formula, not the guard. Need to also ensure the guard ξ propagates.

Burgess's construction (Lemma 2.10, p. 230-234) handles this through the inductive case. In Case n=0, lemma 2.4 gives B with β ∈ B (the guard formula). In Case n=m+1, the induction either reduces or inserts using 2.7/2.8. Our `eliminate_C5_counterexample` only uses the n=0 case (adds y after all domain elements).

For n=0: lemma_2_4 gives B, C with η ∈ B and ξ ∈ C. The y created has f(y) = C with ξ ∈ C. The g-value g(x,y) = B with η ∈ B. Since there are no intermediate points (y is after all domain), the guard is vacuously true at the finite stage.

But then at the LIMIT, intermediate points w with x < w < y DO exist (from later density insertions). The guard at these intermediate points is NOT guaranteed by the C5 elimination alone.

**THIS IS THE FUNDAMENTAL ISSUE**: The C5 elimination at finite stages creates y beyond all existing points, with guard vacuously true. Later density insertions add intermediate points, but these points' f-values are set to f(x) for the nearest existing point (density elimination at CE.lean:891). So we'd need to show that U(ξ,η) ∈ f(x) implies ξ ∈ f(x)... which is NOT true.

**REVISED FINAL ANSWER**: The FUC/FSC sorry closure requires a fundamentally different approach than just strengthening EliminationResult. The correct approach is:

1. Prove a `limit_satisfies_c5_full` theorem that accounts for the entire omega-chain construction, not just individual elimination steps.
2. The argument: given U(ξ,η) ∈ limit_f(x), for any w ∈ limit_dom with x < w: either ξ∧U(ξ,η) ∈ limit_f(w), or the until was satisfied before w. By BX5, U(ξ,η) → U(ξ∧U(ξ,η), η) ∈ f(x). So the enriched until ξ∧U(ξ,η) propagates. This is Burgess's Lemma 2.10 inductive case.

Actually, this is getting complicated. Let me step back and look at this from a higher level.

### Finding 3: C4/C4' Hard Case (Sorries 4-5) — Needs lemma_2_6_splitting

The C4 hard case at CE.lean:412 has this proof context:
- γ ∈ f(x) and γ ∈ f(y) where x < y
- neg(untl(γ,δ)) ∈ f(x) and δ ∈ f(y)
- Adjacent pair (w, w_next) identified where w is the rightmost domain point < y with neg(untl(γ,δ)) ∈ f(w)
- Need: ∃ D : MCS, γ.neg ∈ D

This is Burgess's Lemma 2.9, Case n=0. The proof applies Lemma 2.6 to R(f(w), g(w,w_next), f(w_next)) with δ = γ:
- Since neg(untl(γ,δ)) ∈ f(w) and w is rightmost, w_next has untl(γ,δ) ∈ f(w_next) (or w_next = y with δ)
- By BX6 (from the comment: "δ ∈ f(y), use burgessR3_gamma_not_in_B"): γ.neg should be obtainable

Wait — actually the existing code has `burgessR3_gamma_not_in_B` (RRelation.lean:836) which proves γ ∉ B given burgessR3(A,B,C) and neg(untl(γ,δ)) ∈ A and δ ∈ C. 

So for the C4 hard case:
- Have neg(untl(γ,δ)) ∈ f(w)
- Have δ ∈ f(w_next) (or w_next = y with δ ∈ f(y))
- Need burgessR3(f(w), g(w,w_next), f(w_next)) — i.e., c2' for the adjacent pair

Then `burgessR3_gamma_not_in_B` gives γ ∉ g(w, w_next).

But we need γ.neg ∈ D for some MCS D. Having γ ∉ B (where B = g(w,w_next) is a DCS) gives us: `{γ.neg} ∪ B` is consistent (by `dcs_neg_insert_consistent`). Then Lindenbaum gives D ⊇ {γ.neg} ∪ B.

**WAIT** — this gives us an MCS D with γ.neg ∈ D, which is exactly what the sorry needs. We DON'T need lemma_2_6_splitting at all for this! The proof is:

1. Get BurgessR3Maximal(f(w), g(w,w_next), f(w_next)) — this is c2' for the adjacent pair
2. Apply burgessR3_gamma_not_in_B → γ ∉ g(w,w_next) 
3. Apply dcs_neg_insert_consistent → {γ.neg} ∪ g(w,w_next) is consistent
4. Lindenbaum → MCS D with γ.neg ∈ D ✓

**c2' REQUIREMENT**: Step 1 needs `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))`. This requires c2' to be available at the current finite stage. Currently c2' is NOT maintained through the omega_chain (comment at ChronicleConstruction.lean:246-248).

**OPTIONS FOR c2'**:
a) **Re-add c2' to omega_chain invariant**: Change `omega_chain` to maintain `{χ : Chronicle // χ.c0 ∧ χ.c2'}`. This requires proving that each elimination step preserves c2'. The density elimination DOESN'T preserve c2' (inserting a midpoint creates new adjacent pairs without BurgessR3Maximal).
b) **Construct BurgessR3Maximal locally**: At the sorry site, we have adjacent (w, w_next). We need `g_content(f(w)) ⊆ f(w_next)` to apply `burgessR3Maximal_from_g_content_sub`. Is this available?
c) **Use a different proof strategy** that doesn't need c2'

For option (b): `g_content(f(w)) ⊆ f(w_next)` means G(φ) ∈ f(w) → φ ∈ f(w_next). This is related to G-propagation but is NOT guaranteed at finite stages — the density elimination copies f-values from existing points, which could violate this.

**ACTUALLY** — the `eliminate_potential_counterexample` handles `.density` cases (CE.lean:880-932) by setting `f(z) = f(x)` for the midpoint. After density elimination, adjacent pairs have f-values inherited from nearby points. G-propagation counterexamples are NOT directly eliminated.

Let me re-examine. The counterexample enumeration handles C4_forward, C4_backward, C5_forward, C5_backward, and density cases. G-propagation is handled via... let me check.

<Looking at ChronicleConstruction.lean:245-260>: The omega_chain only carries c0. There's no G-propagation elimination step.

**REVISED**: G-propagation isn't directly maintained. However, at the LIMIT, density + C5 make G-propagation follow from the structure. At finite stages, g_content(f(w)) ⊆ f(w_next) is NOT guaranteed.

**So option (b) fails.** We need option (a) or (c).

For option (c): The C4 hard case proof can use `lemma_2_6_splitting` directly (if it were sorry-free). lemma_2_6_splitting gives B', D, B'' with BurgessR3Maximal(A, B', D) and BurgessR3Maximal(D, B'', C) and δ.neg ∈ D. Taking δ = γ gives γ.neg ∈ D. But lemma_2_6_splitting requires BurgessR3Maximal(A, B, C) — i.e., c2' for the adjacent pair. **Same dependency.**

**FUNDAMENTAL**: The C4 hard case inescapably needs c2' (BurgessR3Maximal for adjacent pairs). This is because Burgess's Lemma 2.9 Case n=0 applies Lemma 2.6 which requires R(A,B,C) — maximality.

### Finding 4: Dead Code in PointInsertion.lean

Sorries 1-3 (PointInsertion.lean:857, 879, 1052) are in:
- `g_content_sub_B` (line 857) — called only by `splitting_seed_consistent` 
- `h_content_sub_B` (line 879) — called only by `splitting_seed_consistent`
- `lemma_2_7` (line 1052) — sorry stub

`splitting_seed_consistent` is called by `lemma_2_6_splitting` which has NO callers anywhere in the codebase. `lemma_2_7` also has NO callers.

However, as shown in Finding 3, the C4/C4' hard case COULD use `lemma_2_6_splitting` if it were sorry-free and if c2' were available. The current code doesn't call it because the entire c2' path was abandoned.

`lemma_2_6_splitting` currently has a sorry in `splitting_seed_consistent` via `g_content_sub_B`. The approach of using `{β.neg} ∪ g_content(A) ∪ h_content(C)` as the seed requires showing g_content(A) ⊆ B, which is the density gap sorry.

But `lemma_2_6_splitting` WORKS despite this sorry — it uses a DIFFERENT seed path. Looking at lines 919-933: it uses `set_lindenbaum` on the seed `{β.neg} ∪ g_content(A) ∪ h_content(C)` where consistency comes from `splitting_seed_consistent` which HAS a sorry.

Actually, wait — `splitting_seed_consistent` reduces to `dcs_neg_union_consistent` (line 905-906) after establishing g_content_sub_B and h_content_sub_B. The sorry IS in g_content_sub_B's inconsistent case.

**The plan v35 approach** was to replace the non-Burgess seed with Burgess's actual D0 seed. This IS the correct fix for lemma_2_6_splitting.

### Finding 5: Correct Dependency Order

```
PointInsertion sorries → C4/C4' sorries → FUC/FSC sorries

Specifically:
1. Fix lemma_2_6_splitting (close sorry in splitting_seed_consistent)
   OR replace with Burgess D0 seed (plan v35 Phase 3)
2. Fix lemma_2_7 (plan v35 Phase 5) — needed if FUC uses C5+2.7 path
3. C4/C4' hard case: needs c2' + lemma_2_6_splitting or burgessR3_gamma_not_in_B
4. FUC/FSC: needs limit_satisfies_c5_full
```

Actually — wait. The FUC/FSC does NOT depend on C4/C4'. Let me re-examine.

The FUC proof needs: for U(φ,ψ) ∈ limit_f(x), find y with ψ ∈ limit_f(y) and guard.

limit_satisfies_c5_weak gives y with ψ ∈ limit_f(y). The guard is the hard part. The guard does NOT use C4 or C4' directly (C4 is used in the BUC proof, not FUC).

The FUC guard requires understanding how the omega-chain propagates until formulas. This is related to C5 elimination + density + the inductive structure of Burgess 2.10.

**REVISED DEPENDENCY**: 
- FUC/FSC can potentially be solved independently of C4/C4'
- C4/C4' requires c2' (which requires solving PointInsertion sorries or finding alternative path)

## Recommended Approach

### Sorry 4-5 (C4/C4' hard case): Need c2' infrastructure

**Strategy**: Restore c2' at finite stages, or construct BurgessR3Maximal locally per the specific sorry site needs.

**Preferred path**: Add BurgessR3Maximal to the adjacent pair (w, w_next) at the sorry site by:
1. Showing g_content(f(w)) ⊆ f(w_next) for this specific adjacent pair
2. Applying `burgessR3Maximal_from_g_content_sub`
3. Then using `burgessR3_gamma_not_in_B` + `dcs_neg_insert_consistent` + Lindenbaum

**Challenge**: g_content(f(w)) ⊆ f(w_next) is NOT guaranteed at finite stages.

**Alternative**: Use Burgess D0 seed approach from plan v35 Phase 3 to make lemma_2_6_splitting sorry-free, then call it from the C4 hard case. This requires c2' anyway.

**Recommendation**: This is the hardest blocker. The plan v35 Phase 3 approach (Burgess D0 seed) is correct but requires significant work (5 hours per plan). The existing `splitting_seed_consistent` approach with g_content_sub_B is WRONG (density gap). The Burgess D0 seed avoids the density gap entirely.

### Sorry 6-7 (FUC/FSC): Strengthen C5 witness

**Strategy**: Prove `limit_satisfies_c5_full` that includes guard information.

**Preferred path**: 
1. Strengthen `EliminationResult.c5_forward_witness` to include guard (add field)
2. Update `eliminate_potential_counterexample` to carry guard info
3. Prove `omega_chain_c5_witness_full` with guard
4. Prove `limit_satisfies_c5_full` 
5. Use in `cantor_bfmcs_restricted_fuc` with cantor_iso transfer (mirroring the BUC/TC proofs)

**Challenge**: The "elimination needed" case of C5 creates y beyond all domain points. At creation time, the guard is vacuously true. But later insertions add intermediate points. The guard at those points requires showing that the omega-chain preserves the guard property across steps.

**Alternative simpler path**: Don't strengthen EliminationResult. Instead, prove limit_satisfies_c5_full directly using the structure of the limit:

For U(ξ,η) ∈ limit_f(x), BX5 gives U(ξ∧U(ξ,η), η) ∈ limit_f(x). Now ξ∧U(ξ,η) is a "guard-enriched" formula. If we can show this enriched guard holds at intermediate points, we're done.

**Confidence**: Medium — the FUC/FSC proof requires careful analysis of how Until formulas propagate through the omega-chain. The strengthened EliminationResult approach is more mechanical but touches more code.

## Evidence/Examples

### Evidence for C4 needing c2'

Burgess Lemma 2.9, Case n=0 (p. 222):
> "By C2' we have R(f(x), g(x,y), f(y)) and so we can apply 2.6"

This explicitly uses C2' (= BurgessR3Maximal for adjacent pairs). The codebase removed c2' from the omega_chain invariant (Phase 7 change, ChronicleConstruction.lean:246-248).

### Evidence for FUC using C5+C3

Burgess Claim 2.11 (p. 247):
> "If α ∈ f(x), then by C5a there is y with γ ∈ f(y) and β ∈ g(x,y). If z ∈ X and x < z < y, then C3 gives g(x,y) ⊆ f(z), whence β ∈ f(z)."

The limit_g satisfies C3 by construction (limit_c3, sorry-free). The missing piece is β ∈ limit_g(x,y) — i.e., the guard formula in the limit interval function.

## Confidence Levels

| Sorry | Strategy | Confidence | Risk |
|-------|----------|------------|------|
| 4 (C4) | c2' + burgessR3_gamma_not_in_B | Medium | c2' reconstruction at finite stages is non-trivial |
| 5 (C4') | Mirror of sorry 4 | Medium | Same risks |
| 6 (FUC) | Strengthen C5 witness OR direct limit argument | Medium-Low | Multiple approaches, unclear which is simplest |
| 7 (FSC) | Mirror of sorry 6 | Medium-Low | Same risks |

## Dependencies Between Sorry Closures

```
lemma_2_6_splitting (sorry-free) ←── C4/C4' (sorries 4-5)
                                        ↑ requires c2'

limit_satisfies_c5_full ←── FUC/FSC (sorries 6-7)
   ↑ requires strengthened EliminationResult
   ↑ OR direct limit argument

C4/C4' and FUC/FSC are INDEPENDENT of each other.
```

The C4/C4' path requires resolving the c2' question (restore to omega_chain or construct locally).
The FUC/FSC path requires resolving the C5 guard question (strengthen EliminationResult or prove limit argument).

Neither depends on the other. Both can proceed in parallel.
