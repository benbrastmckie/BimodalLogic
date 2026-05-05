# Teammate B Findings: Alternative Approaches & Infrastructure Analysis

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Date**: 2026-05-05
**Angle**: Alternative approaches, existing infrastructure, dependency shortcuts

## Key Findings

### Finding 1: The actual sorry count is 13, not 8

The initial sorry inventory missed 5 `c2'` field sorries in `CounterexampleElimination.lean` that appear inline:

| # | File | Line | Description |
|---|------|------|-------------|
| 1 | PointInsertion.lean | 1977 | Case B pos sub-case (B is MCS) |
| 2 | PointInsertion.lean | 2744 | lemma_2_7_seed_consistent |
| 3 | PointInsertion.lean | 2875 | Lemma 2.7 inconsistent case |
| 4 | CounterexampleElimination.lean | 413 | C4 hard case (Until) |
| 5 | CounterexampleElimination.lean | 511 | C4' hard case (Since) |
| 6 | CounterexampleElimination.lean | 758 | c2' from C5 elimination |
| 7 | CounterexampleElimination.lean | 796 | c2' from C5' elimination |
| 8 | CounterexampleElimination.lean | 836 | c2' from C4 elimination |
| 9 | CounterexampleElimination.lean | 874 | c2' from C4' elimination |
| 10 | CounterexampleElimination.lean | 920 | c2' for density insertion |
| 11 | ChronicleToCountermodel.lean | 621 | Forward Until coherence (FUC) |
| 12 | ChronicleToCountermodel.lean | 625 | Forward Since coherence (FSC) |
| 13 | Completeness.lean | 152 | NoUnivBurgessR3 |

### Finding 2: Mirror symmetry reduces unique proof obligations by half

Sorries #4/#5, #6/#7, #8/#9 are exact mirror pairs (Until/Since). The codebase already has complete mirror infrastructure:
- `burgessR3_gamma_not_in_B` / `burgessR3_gamma_not_in_B_since` (RRelation.lean:882/897)
- `eliminate_C5_counterexample` / `eliminate_C5'_counterexample` (CounterexampleElimination.lean:167/212)
- `limit_satisfies_c5_weak` / `limit_satisfies_c5'_weak` (ChronicleConstruction.lean:590/612)

Once one direction is proved, the mirror should be mechanical. **Effective unique sorries: ~8**.

### Finding 3: NoUnivBurgessR3 (#13) has a clear proof path via existing infrastructure

**Goal**: `∀ A C, SetMaximalConsistent A → SetMaximalConsistent C → ¬burgessR3 A Set.univ C`

**Proof sketch using existing lemmas**:
1. `burgessR3 A Set.univ C` requires `burgessRSet A Set.univ C`, i.e., `∀ β ∈ Set.univ, ∀ γ ∈ C, untl(β, γ) ∈ A`
2. Take `β = Formula.bot`. Then `untl(bot, γ) ∈ A` for all `γ ∈ C`.
3. By `until_implies_F_in_mcs` (RRelation.lean:84): `untl(bot, γ) ∈ A → some_future γ ∈ A`, specifically `F(γ) ∈ A`.
4. But also `untl(bot, γ) ∈ A` means `bot` is the guard. By Burgess 2.2: if `U(γ,δ) ∈ A` then γ is consistent. Here the event is `γ` and the guard is `bot`. Actually `untl(β,γ) = U(γ,β)` in Burgess convention. So `U(γ, bot) ∈ A` means γ is the event and bot is the guard, and the Burgess 2.2 criterion says γ must be consistent — which it is, since γ ∈ C and C is MCS.

Wait — let me reconsider. The convention is `untl(xi, eta) = U(eta, xi)` where xi=guard, eta=event. So `untl(bot, γ)` = U(γ, bot). Burgess 2.2 says if `U(γ, δ) ∈ A` then γ is consistent. Here γ is consistent (it's in C, an MCS). So 2.2 doesn't help directly.

**Better approach**: Take `β = bot` in `burgessRSet`. We need `untl(bot, γ) ∈ A` for all `γ ∈ C`. Our `untl(bot, γ)` = Burgess U(γ, bot). By BX10 (`until_F`): U(γ, bot) → F(bot). So `F(bot) ∈ A`. But F(bot) = ¬G(¬bot) = ¬G(top). Since G(top) is a theorem (TG applied to top), G(top) ∈ A (MCS). So ¬G(top) ∉ A. But F(bot) = ¬G(¬bot), and ¬bot = top, so F(bot) = ¬G(top). Since G(top) ∈ A, F(bot) ∉ A (MCS consistency). Contradiction: `F(bot) ∈ A` and `F(bot) ∉ A`.

**The chain**: `untl(bot, γ) ∈ A → F(γ) ∈ A` via BX10. Wait, BX10 is `untl(xi, eta) → F(eta)` in our convention (guard=xi, event=eta). So `untl(bot, γ) → F(γ)`. That doesn't give F(bot).

Let me reconsider: BX10 gives `untl(xi, eta) → F(eta)`, where eta is the event. But `some_future` is F(phi) = untl(top, phi). Actually looking at the code (RRelation.lean:84-91): `until_implies_F_in_mcs` gives that `untl(γ, δ) ∈ A → some_future δ ∈ A`, i.e., F(δ) where δ is the second argument (event). For `untl(bot, γ)`: bot is the guard (xi), γ is the event (eta). So we get F(γ) ∈ A. That's fine — γ ∈ C is an MCS element, so F(γ) ∈ A is plausible.

**Actually the key is A2a (right_mono_until for guard direction)**: A2a says `G(p → q) → (U(r, p) → U(r, q))`. In our notation: if `⊢ phi → psi` then `untl(phi, gamma) → untl(psi, gamma)`. Take phi=bot, psi=anything: `⊢ bot → anything` is trivially true (ex falso). So `untl(bot, γ) → untl(anything, γ)`. In particular, `untl(bot, γ) → untl(γ.neg, γ)` for any γ ∈ C. But `untl(γ.neg, γ)` says "event γ will occur while guard γ.neg holds." This leads to `F(γ) ∈ A` (event witness exists). That alone isn't contradictory.

**The real approach**: From `burgessRSet(A, Set.univ, C)`, we get `∀ β, ∀ γ ∈ C, untl(β, γ) ∈ A`. Taking `β = γ.neg` and any `γ ∈ C`: `untl(γ.neg, γ) ∈ A`. Then by BX5 (`self_accum_until`): `untl(γ.neg ∧ untl(γ.neg, γ), γ) ∈ A`. Combined with the original `untl(γ, γ)` also in A (from β=γ), BX7 linearity gives a three-way disjunction. After elimination, we can derive that `untl(true, γ ∧ γ) ∈ A` or similar. This chain is complex.

**Simplest approach**: Use `BurgessR3Maximal_not_univ` (PointInsertion.lean:784). This already proves `BurgessR3Maximal(A, B, C) → ¬burgessR3(A, Set.univ, C)`. So NoUnivBurgessR3 follows if we can show for ANY pair (A, C) of MCS, there exists some B with `BurgessR3Maximal(A, B, C)`.

Alternatively, prove `¬burgessR3(A, Set.univ, C)` directly from the definition. The key observation: `burgessRSet(A, Set.univ, C)` requires `untl(bot, γ) ∈ A` for all γ ∈ C. But `untl(bot, γ) = U(γ, bot)` in Burgess notation. By Axiom A2a with `⊢ bot → anything_false`: Wait, `G(bot → bot)` is trivially provable, so A2a gives `U(r, bot) → U(r, bot)` — not helpful.

Actually: from `⊢ ¬bot` (i.e., `⊢ top`), by TG: `⊢ G(top) = G(¬bot)`, so `⊢ ¬F(bot)`. Now if `untl(bot, γ) ∈ A`, by A2a with `⊢ γ → top`: `untl(bot, top) ∈ A`, i.e., `F(bot) ∈ A`. But `¬F(bot)` is a theorem, so `¬F(bot) ∈ A`. Contradiction with MCS consistency.

**Wait — this might actually work!** Let me verify: A2a states `G(p → q) → (U(r, p) → U(r, q))`. Our encoding: Axiom.right_mono_until. In our convention with `untl(guard, event)`: A2a would be about the *event* direction — `G(event1 → event2) → (untl(guard, event1) → untl(guard, event2))`. We need something for the *guard* direction. A1a states `G(p → q) → (U(p, r) → U(q, r))`, which in our notation is about the guard.

Actually let me re-read. Looking at Burgess: A2a says `G(p → q) → (U(r, **p**) → U(r, **q**))`. In Burgess, U(r, p) means "event r, guard p." So A2a modifies the **guard**: `G(guard1 → guard2) → (U(event, guard1) → U(event, guard2))`. In our notation `untl(guard, event)`: we need `G(guard1 → guard2) → (untl(guard1, event) → untl(guard2, event))`. This is `left_mono_until`.

For the NoUnivBurgessR3 proof: take `untl(bot, γ) ∈ A`. Apply `left_mono_until` with `⊢ bot → bot` (which is trivially a theorem, giving `G(bot → bot)` by TG). That gives `untl(bot, γ) → untl(bot, γ)` — trivial.

Instead: Apply A1a, which modifies the *event*: `G(p → q) → (U(**p**, r) → U(**q**, r))`. In our notation: `G(event1 → event2) → untl(guard, event1) → untl(guard, event2)`. From `untl(bot, γ)`: guard=bot, event=γ. We can change event to anything via A1a. Take event2=top: `G(γ → top) → untl(bot, γ) → untl(bot, top)`. Since `⊢ γ → top` is a theorem, `G(γ → top)` is a theorem by TG. So `untl(bot, top) ∈ A`.

But `untl(bot, top) = U(top, bot)` in Burgess = `F(top)`. Wait: `F(α) = U(α, top)` in Burgess = `untl(top, α)` in our notation. So `untl(bot, top) = U(top, bot)` = ???. Actually `U(α, β)` = `untl(β, α)` (swapped). So `F(α) = U(α, top) = untl(top, α)`. And `untl(bot, top)` = `U(top, bot)`, which is "event=top, guard=bot" = "there exists a future time where top holds, with bot holding at all intermediate points." On any order with at least one future point, this requires bot at intermediate points — which is impossible.

Formally: `untl(bot, top) ∈ A` means `F(top) ∈ A`? No. Let me be precise. `untl(xi, eta)` has xi=guard, eta=event. `F(eta)` = `untl(top, eta)`. So `untl(bot, top)` has guard=bot, event=top. By BX10 (`until_F`): `untl(guard, event) → F(event)`, so `untl(bot, top) → F(top)`. And `F(top)` is provable (there is no last element axiom `F(top)` is... actually `F(top) = ¬G(¬top) = ¬G(bot)`. If `G(bot)` is a theorem... it's not. `G(bot)` is "always-bot" which is false on all non-empty orders.

Hmm, we're over $\mathscr{K}_0$ which includes all linear orders including the empty one. Actually Burgess works with general linear orders. For the completeness proof, the countermodel is over ℚ which has no last element, so `F(top)` is valid over ℚ. But we may not have `⊢ F(top)` as a theorem of J₀ (it requires "no last element" axiom).

**Better approach**: By BX10, `untl(bot, γ) → F(γ)` for the event γ. So F(γ) ∈ A for all γ ∈ C. Taking γ = top (which is in C, since C is an MCS): `F(top) ∈ A`. But we need `F(top)` to not be derivable... which it is if we add the "no last element" axiom. Without that axiom, `F(top)` might not be derivable.

Let me reconsider. The simplest approach is surely: `untl(bot, γ) ∈ A` for bot=Formula.bot. Now `⊢ bot.neg` (i.e., `⊢ ¬⊥ = ⊤`). And `⊢ G(¬⊥)` by TG. This means `⊢ ¬F(⊥)`, i.e., `(F ⊥).neg ∈ A`. Now from `untl(bot, γ)` with guard=bot: the guard must hold at intermediate times. But bot never holds. So the Until can only be satisfied vacuously (no intermediate times = adjacent pair). For the Until semantics of J₀ (with strict future), we need a strictly future witness. At that witness, γ (event) holds. Between now and the witness, bot (guard) must hold. If there are no points between now and the witness, the guard holds vacuously. On a dense order, there are always intermediate points, so bot can't hold. But J₀ is complete for ALL linear orders including discrete ones.

So `untl(bot, γ)` is NOT derivably false in J₀. It's satisfiable on discrete orders with adjacent points.

**This means NoUnivBurgessR3 is NOT provable from J₀ axioms alone.** The docstring in ChronicleTypes.lean:344 confirms: "This condition is NOT derivable from J₀ axioms alone."

So NoUnivBurgessR3 must be treated as a structural assumption of the chronicle construction, not proved. The current sorry at Completeness.lean:152 needs to either:
1. Add it as a hypothesis threaded through the construction, OR
2. Prove it from the specific construction's properties (which use dense ℚ)

**Confidence**: HIGH

### Finding 4: The 5 c2' sorries (#6-#10) have a uniform proof pattern

All 5 c2' sorries in `eliminate_potential_counterexample` have the same structure:
- The elimination inserts a new point z into the domain
- g is unchanged: `χ'.g a b = χ.g a b` for all a,b
- f agrees on old points: `χ'.f x = χ.f x` for x ∈ χ.dom
- Only `χ'.f z` is new (set to some MCS D)

For c2': need `BurgessR3Maximal(f'(a), g'(a,b), f'(b))` for all adjacent pairs (a,b) in the new domain. Since g is unchanged and f agrees on old points:
- **Old adjacent pairs that remain adjacent**: c2' from the input `h_c2'`
- **Old adjacent pair (a,b) split by z into (a,z) and (z,b)**: Need `BurgessR3Maximal(f(a), g(a,z), D)` and `BurgessR3Maximal(D, g(z,b), f(b))`. Since `g(a,z) = g(a,b)` (g unchanged), this reduces to showing `BurgessR3Maximal(f(a), g(a,b), D)` and `BurgessR3Maximal(D, g(a,b), f(b))`.
- **New endpoint adjacent pairs**: (for C5 insertion at the extremes)

The key insight: each elimination function (lemma_2_4, lemma_2_6, lemma_2_7) already constructs BurgessR3Maximal as part of their output! The MCS D from the PointInsertion lemmas comes with `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)`. The c2' sorry is just a matter of threading these results through.

The main challenge: the elimination functions currently return `(∀ a b, χ'.g a b = χ.g a b)` — meaning g is NOT updated. But c2' needs `BurgessR3Maximal(f(a), g(a,z), f(z))` and the BurgessR3Maximal from the lemma operates on the *new* B', not the old g(a,b). So either:
1. The elimination functions need to update g to use the B'/B'' from the lemma
2. Or we need to show g(a,b) = B' (which may not hold since g is the old value)

**This is a genuine architectural gap**: the elimination functions preserve g but c2' requires BurgessR3Maximal on the new adjacent pairs, which uses the old g. The fix requires modifying the elimination return type to update g.

**Confidence**: HIGH (that this is the right diagnosis)

### Finding 5: Sorries #4/#5 (C4 hard case) have the proof already outlined in code

Looking at the goal state for sorry #4 (CounterexampleElimination.lean:413):
```
⊢ ∃ D, SetMaximalConsistent D ∧ ce.γ.neg ∈ D
```

The code already has:
1. Found `w` (rightmost domain point with neg-until)
2. Found `w_next` (its successor, adjacent to w)
3. Has `h_adj : Adjacent χ.dom w w_next`

The proof needs: from c2' on (w, w_next), get `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))`. Then either:
- If `w_next = y`: δ ∈ f(y) and neg_until ∈ f(w), use `burgessR3_gamma_not_in_B` to get γ ∉ g(w,y), then construct MCS D with γ.neg from non-membership
- If `w_next < y`: untl(γ,δ) ∈ f(w_next) (since w is rightmost neg-until), so neg_until ∉ f(w_next). Then the adjacent pair (w, w_next) with c2' gives `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))`, and from neg_until ∈ f(w) + untl ∈ f(w_next), `burgessR3_gamma_not_in_B` gives γ ∉ g(w,w_next), hence γ.neg ∈ MCS extending g(w,w_next)

BUT: the sorry needs `h_c2' : χ.c2'` to get the BurgessR3Maximal. And `h_c2'` IS available as a parameter to `eliminate_potential_counterexample`. So this should be provable!

Wait — reading more carefully, the C4 elimination code is inside `eliminate_C4_counterexample` (line 305), NOT inside `eliminate_potential_counterexample`. And `eliminate_C4_counterexample` takes only `h_c0` — it does NOT take `h_c2'`. That's the problem!

Looking at line 305: `eliminate_C4_counterexample (h_c0 : χ.c0) (ce : C4Counterexample χ)` — no c2' parameter. It should be added.

**Confidence**: HIGH

### Finding 6: Sorry #1 (Case B) resolves via existing `BurgessR3Maximal_not_univ`

The goal at PointInsertion.lean:1977:
```
h_mcs_B : SetMaximalConsistent B
h_r3m : BurgessR3Maximal A B C
h_pos : (b.and β).untl γ_hat ∈ A
⊢ False
```

When B is MCS, any δ ∉ B has δ.neg ∈ B (MCS completeness). So {δ} ∪ B is inconsistent for any δ ∉ B. The issue: `BurgessR3Maximal_extension_fails` (line 631) shows `¬burgessR3(A, DC({δ}∪B), C)` for δ ∉ B. But when {δ}∪B is inconsistent, `DC({δ}∪B) = Set.univ`. So we get `¬burgessR3(A, Set.univ, C)`.

Actually, `BurgessR3Maximal_not_univ` (line 784) ALREADY gives `¬burgessR3(A, Set.univ, C)` directly from `BurgessR3Maximal(A, B, C)` — we don't even need to go through DC.

The missing piece: We need to show `(b.and β).untl γ_hat ∈ A` leads to contradiction. Since B is MCS and β ∉ B, we have β.neg ∈ B. Since β.neg is a conjunct of b (it's b_list[0] = β₀ = β.neg), b ∧ β is derivably inconsistent (b → β.neg, so b ∧ β → β.neg ∧ β → ⊥). Therefore `⊢ (b ∧ β) → ⊥`, meaning b ∧ β is derivably equivalent to ⊥.

By `left_mono_until` (A1a): `G((b ∧ β) → ⊥) → untl((b ∧ β), γ_hat) → untl(⊥, γ_hat)`. So `untl(⊥, γ_hat) ∈ A`.

Now: `untl(⊥, γ_hat)` with guard=⊥, event=γ_hat. By BX10: `F(γ_hat) ∈ A`. That's not contradictory.

But from `burgessR3(A, Set.univ, C)` (which is FALSE by `BurgessR3Maximal_not_univ`), we need... Wait, we have `¬burgessR3(A, Set.univ, C)` already. We need to REACH `burgessR3(A, Set.univ, C)` from `h_pos` to get contradiction.

Can we? From `untl(⊥, γ_hat) ∈ A`, using `left_mono_until` with `⊢ ⊥ → ψ` (ex falso): for any ψ, `untl(ψ, γ_hat) ∈ A`. In particular, for all β' and γ' where β' ∈ Set.univ and γ' is a subformula of γ_hat in C... Actually: we need `∀ β ∈ Set.univ, ∀ γ ∈ C, untl(β, γ) ∈ A` — not just for γ_hat.

So we need `untl(ψ, γ) ∈ A` for ALL γ ∈ C, not just γ_hat. From `untl(⊥, γ_hat) ∈ A`, left_mono gives `untl(ψ, γ_hat) ∈ A`. But right_mono (A1a changes event, not guard): `G(γ_hat → γ)` would give `untl(ψ, γ_hat) → untl(ψ, γ)`. But `G(γ_hat → γ)` is NOT a theorem in general.

**Alternative approach**: use `burgessR3_univ_of_inconsistent_ext` (PointInsertion.lean:813). This takes `h_r3 : burgessR3 A B C`, `G(φ) ∈ A`, and `φ.neg ∈ B`, and produces `burgessR3(A, Set.univ, C)`. We have B is MCS, β ∉ B, β.neg ∈ B. If g_content(A) ⊆ B... well, `_h_gc : g_content A ⊆ C` is available, not g_content(A) ⊆ B.

Wait — there's a cleaner path. We have `BurgessR3Maximal(A, B, C)` with B an MCS. Consider any δ ∉ B. Then δ.neg ∈ B (MCS). If G(δ) ∈ A (i.e., δ ∈ g_content(A)), then `burgessR3_univ_of_inconsistent_ext` gives `burgessR3(A, Set.univ, C)`, contradicting `BurgessR3Maximal_not_univ`.

But what if g_content(A) ⊆ B? Then for any δ ∈ g_content(A), δ ∈ B. What if δ ∉ g_content(A)? Then G(δ) ∉ A.

Actually, the correct approach for Case B requires showing that when B is MCS, the BurgessR3Maximal cannot hold (or the pos sub-case is vacuously false). Let me re-examine: with BurgessR3Maximal(A, B, C) where B is MCS:

From `BurgessR3Maximal_extension_fails`: for ANY δ ∉ B, `¬burgessR3(A, DC({δ}∪B), C)`. Since B is MCS and δ ∉ B, we have δ.neg ∈ B, so {δ}∪B is inconsistent, so `DC({δ}∪B) = Set.univ`. Hence `¬burgessR3(A, Set.univ, C)`.

BUT we already have this from `BurgessR3Maximal_not_univ`. The question is: does the pos sub-case itself lead to `burgessR3(A, Set.univ, C)`?

Looking at the handoff cascade-complete-build-fixed.md, line 94-101, there's an analysis: We have `h_pos : untl(b∧β, γ_hat) ∈ A`. Since b∧β is derivably inconsistent (as shown above), `untl(⊥, γ_hat) ∈ A` by left_mono. Then by left_mono with ex_falso: `untl(ψ, γ_hat) ∈ A` for ANY ψ. This gives `burgessR(A, ψ, C)` if γ_hat → γ for all γ ∈ C (which requires γ_hat to imply each γ ∈ C — this is the conjunction of c_list which by construction implies each element).

Wait — γ_hat = list_conj(c_list) and c_list has γ₀ and c_list_raw. By `right_mono_until`: `G(γ_hat → γ) → untl(ψ, γ_hat) → untl(ψ, γ)`. And `γ_hat → γ` for each γ ∈ c_list because γ_hat is their conjunction. So `untl(ψ, γ) ∈ A` for each γ ∈ c_list. BUT c_list only contains a finite subset of C, not ALL of C.

So this approach doesn't give full `burgessR3(A, Set.univ, C)` — it only gives `untl(ψ, γ) ∈ A` for finitely many γ. We need ALL γ ∈ C.

**The fix**: The contradiction must come from `untl(b∧β, γ_hat) ∈ A` combined with `¬burgessR3(A, Set.univ, C)` plus additional structure. Specifically, we need to show that h_pos leads to something contradicting a known fact about A.

From `h_pos` and the fact that b∧β is inconsistent: `untl(⊥, γ_hat) ∈ A`. By BX10: `F(γ_hat) ∈ A`. That's fine. Now, `¬F(⊥) ∈ A` (since ¬F(⊥) = G(⊤) is a theorem). And `untl(⊥, γ_hat) → F(γ_hat)` gives no contradiction.

**Hmm** — I think the actual proof path is: the pos sub-case in the original Burgess proof uses the maximality of B over ALL deductively closed sets (including inconsistent ones). Since BurgessR3Maximal now uses ClosedUnderDerivation (which includes Set.univ), and `BurgessR3Maximal_not_univ` gives `¬burgessR3(A, Set.univ, C)`, the Case B should be handled as follows:

When B is MCS, take any δ ∉ B. Then DC({δ}∪B) = Set.univ (since {δ}∪B is inconsistent). By maximality over ClosedUnderDerivation: `¬burgessR3(A, Set.univ, C)`. Now unfold: there exist β₀, γ₀ with (β₀ ∈ Set.univ and γ₀ ∈ C and untl(β₀, γ₀) ∉ A) OR (β₀ ∈ Set.univ and α₀ ∈ A and snce(β₀, α₀) ∉ C). Actually `¬burgessR3(A, Set.univ, C)` means `¬(burgessRSet(A, Set.univ, C) ∧ burgessRSetSince(C, Set.univ, A))`. 

One of these must fail. If burgessRSet fails: ∃ β ∈ Set.univ, ∃ γ ∈ C, untl(β, γ) ∉ A. I.e., untl(β, γ).neg ∈ A for some β, γ ∈ C.

Actually wait: `¬(P ∧ Q)` only gives `¬P ∨ ¬Q` classically. We can't pick which side fails. But for the proof, either side failing gives useful information.

I think the key insight is that the proof CANNOT proceed as a direct contradiction from h_pos alone. Instead, the seed consistency proof (`burgess_D0_finite_subset_consistent_incons`) should be restructured. When B is MCS, the seed `burgess_D0_seed A B C β` should be consistent because the finite subset argument works differently — the c_list should include a witness from `¬burgessR3(A, Set.univ, C)`.

**Bottom line**: Sorry #1 requires careful restructuring of the c_list construction to include the neg-until witness from `BurgessR3Maximal_not_univ`. This IS doable with existing infrastructure but needs non-trivial proof work.

**Confidence**: MEDIUM (the approach is sound but the implementation is complex)

### Finding 7: Sorry #3 (inconsistent case) may be avoidable by restructuring

The goal at PointInsertion.lean:2875:
```
h_cons : ¬SetConsistent ({xi} ∪ B)
⊢ ∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧ 
    SetMaximalConsistent D ∧ eta ∈ D ∧ xi ∈ B'
```

When {xi}∪B is inconsistent, xi.neg ∈ B (provable from DCS). We need xi ∈ B'. Since B' must be a DCS (from BurgessR3Maximal), and xi might be inconsistent with B' (if xi.neg propagates), this is blocked.

**Alternative 1**: In Burgess's proof of Lemma 2.7, the case {η}∪B inconsistent (in Burgess's notation) doesn't arise separately — it's handled uniformly by the consistency argument in the proof. The case split on consistency is an artifact of our formalization.

**Alternative 2**: When {xi}∪B is inconsistent, xi.neg ∈ B. Then `untl(xi, eta) ∈ A` and `xi.neg ∈ B`. By `burgessR3_univ_of_inconsistent_ext` (line 813) with G(xi) ∈ A... wait, we need G(xi) ∈ A, but we only have xi ∉ B. We do have `g_content(A) ⊆ C` but not g_content(A) ⊆ B.

**Alternative 3**: Use the Lemma 2.8 path. Burgess 2.8 gives the same conclusion as 2.7 under different hypotheses. Looking at the Burgess paper: 2.8 applies when `¬(xi ∨ (eta ∧ untl(xi, eta))) ∈ C`. This might be the "else" case that avoids the seed consistency issue.

**Confidence**: LOW (multiple paths exist but none is clearly mechanical)

### Finding 8: Sorries #11/#12 (FUC/FSC) have all building blocks available

The FUC proof at ChronicleToCountermodel.lean:621 needs:
```
∃ s : D, t < s ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, t < r → r < s → φ ∈ fam.mcs r
```

Available infrastructure:
- `limit_satisfies_c5_weak`: gives `∃ y, x < y ∧ η ∈ f(y)` (event at witness, NO guard)
- `limit_g`: defined as `{φ | ∀ y ∈ dom, x < y → y < z → φ ∈ f(y)}` (intersection over intermediate points)
- `limit_c3_interval_subset_point`: `g(x,z) ⊆ f(y)` for intermediate y
- `limit_c3`: full three-way decomposition

The gap: `limit_satisfies_c5_weak` gives the endpoint but not the guard. For the full C5, we need the guard φ at intermediate points. This requires showing `φ ∈ limit_g(x, y)` where y is the C5 witness.

The guard would come from the finite-stage C5 witnesses. At each omega chain stage, `omega_chain_c5_witness` provides a witness. The issue: the finite-stage C5 witness only gives the event (η ∈ f(y)), not the guard at intermediate points. The `EliminationResult.c5_forward_witness` type (line 704) confirms: it only gives `∃ y, η ∈ f(y)`, NOT the guard.

**Potential fix**: Strengthen `EliminationResult.c5_forward_witness` to include the guard. But this requires modifying the C5 elimination function, which already constructs the guard information (via lemma_2_4/2.7) but discards it from the result type.

Alternatively: the guard at intermediate points follows from the chronicle conditions (C2 + C3) at the limit. Specifically:
1. From `untl(φ, ψ) ∈ f(x)` and `c5_weak` giving `y > x` with `ψ ∈ f(y)`.
2. For any `r` with `x < r < y` in the limit domain, `r` appears at some finite stage.
3. At that finite stage, either (a) `untl(φ, ψ) ∈ f(r)` (the Until persists), or (b) the witness y is already present and `φ ∈ g(x, y) ⊆ f(r)` by C3.

The key challenge: the C5 witness y may be introduced at a LATER stage than r, so at the stage where r exists, y might not yet be in the domain. At that earlier stage, the Until might still be unresolved. Only at stage y's introduction does the resolution happen.

**Alternative approach**: Use the truth lemma directly at the limit. The limit chronicle satisfies C0-C3 (all proved sorry-free). C4 and C5 are the content of the omega chain construction. The full C5 (with guard) at the limit could be proved by:
1. `untl(φ,ψ) ∈ f(x)` at the limit
2. C5_weak gives y with ψ ∈ f(y) 
3. For intermediate r: need φ ∈ f(r)
4. From limit_g definition: φ ∈ limit_g(x,y) iff φ ∈ f(r) for all r between x and y
5. Need: φ ∈ limit_g(x,y). This follows if the omega chain construction ensures g-values contain φ for the Until witness interval.

This is the heart of the Burgess truth lemma (Claim 2.11). It requires the interplay of C2, C3, C4, C5 at the limit. The existing infrastructure has all the pieces; the gap is composing them correctly.

**Confidence**: MEDIUM (all building blocks exist, composition is the challenge)

## Alternative Approaches (Per Sorry)

### Sorry #13 (NoUnivBurgessR3) — Use `burgessR3Maximal_from_g_content_sub`
**Strategy**: For any MCS pair (A, C), `burgessR3Maximal_from_g_content_sub` (RRelation.lean:1554) gives ∃ B, BurgessR3Maximal(A, B, C) when g_content(A) ⊆ C AND NoUnivBurgessR3 holds. This is circular — it needs NoUnivBurgessR3 as input.

**Verdict**: Must be resolved structurally, not proved from axioms. Options:
1. **Best**: Prove directly that `burgessR3(A, Set.univ, C) = false` for MCS A, C. Key: bot ∈ Set.univ, and `burgessRSet(A, Set.univ, C)` requires `untl(bot, γ) ∈ A` for all γ ∈ C. Show this is impossible for some specific γ.
2. **Fallback**: Leave as a structural axiom (properly justified by semantic argument for dense orders).

### Sorries #6-#10 (c2' in EliminationResult) — Refactor elimination return types
**Strategy**: The elimination functions (C4, C5, density) should return updated g-values, not preserve old ones. Specifically, when inserting point z between a and b, the elimination should set g'(a,z) = B' and g'(z,b) = B'' from the PointInsertion lemma, and use C3 to determine g'(w,z) for non-adjacent w.

This is a refactoring task, not a mathematical one.

### Sorries #11/#12 (FUC/FSC) — Strengthen omega_chain_c5_witness
**Strategy**: Modify `EliminationResult.c5_forward_witness` to include guard information, then propagate to `omega_chain_c5_witness`, then to `limit_satisfies_c5_full`.

OR: Prove the guard at the limit directly using C2 + C3 + C4 + the definition of limit_g.

## Evidence/Examples

### Existing lemma graph for sorry resolution:

```
NoUnivBurgessR3 (#13)
  ← burgessRSet defn + untl(bot, γ) consistency argument
  
Case B (#1)  
  ← BurgessR3Maximal_not_univ + restructured c_list with neg-until witness

Seed consistency (#2)
  ← BX5 + BX7 + BX14 + BX13 + BX10 (outlined in code comments)

Inconsistent case (#3)
  ← Restructure at call site OR Lemma 2.8 path

C4 hard cases (#4/#5)
  ← h_c2' + burgessR3_gamma_not_in_B + MCS extension
  (needs: pass h_c2' to eliminate_C4_counterexample)

c2' maintenance (#6-#10)
  ← Refactor elimination to update g-values from PointInsertion

FUC/FSC (#11/#12)
  ← Strengthen c5_forward_witness OR direct limit proof via C2+C3
```

## Confidence Level

| Sorry | Approach | Confidence | Effort |
|-------|----------|------------|--------|
| #1 (Case B) | BurgessR3Maximal_not_univ + c_list restructure | Medium | 4-6h |
| #2 (Seed) | BX axiom chain per Burgess | Medium | 6-10h |
| #3 (Incons) | Restructure / Lemma 2.8 | Low | 3-5h |
| #4-#5 (C4) | Pass h_c2' + burgessR3_gamma_not_in_B | High | 2-3h |
| #6-#10 (c2') | Refactor elimination g-values | High | 8-12h |
| #11-#12 (FUC) | Strengthen c5_witness OR limit proof | Medium | 4-8h |
| #13 (NoUniv) | Direct proof or structural axiom | High | 1-2h |

**Overall estimate**: 28-46 hours
