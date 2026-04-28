# Teammate A Findings: Primary Analysis of Burgess D₀ Consistency Under Strict Semantics

## Key Findings

### 1. The "Mixed A/C Problem" Is Dissolved by Following Burgess More Carefully (HIGH CONFIDENCE)

The handoff described a "mixed A/C problem" where D₀ elements come from different MCSs (A vs C) and their joint consistency seems hard to establish. **This problem is an artifact of an incorrect proof approach.** Burgess's actual proof does NOT reason about the joint consistency of elements from A and C separately. Instead, he builds a single Until formula in A whose event part CONTAINS all the components of ζ, then invokes the consistency criterion. The "mixing" never occurs.

Burgess's proof structure (Lemma 2.6): show each particular ζ = S(α,β) ∧ β ∧ ¬δ ∧ U(γ,β) is consistent by:
1. Building `U(event_containing_all_parts, β) ∈ A` (a single formula in A)
2. Applying the consistency criterion: since A is MCS and this Until is in A, the event is consistent
3. Since ζ is propositionally weaker than the event, ζ is consistent

The "mixing" of A-elements and C-elements happens INSIDE A, mediated by axioms that transform Until and Since formulas. The proof never needs to reason about consistency across different MCSs.

### 2. Consistency Criterion (Lemma 2.2) Holds Under Strict Semantics (HIGH CONFIDENCE)

Burgess's Lemma 2.2: "If U(γ,δ) ∈ A for MCS A, then γ is consistent."

In our convention: "If untl(guard, event) ∈ A for MCS A, then event is consistent."

**Proof under strict semantics**: From `untl(guard, event) ∈ A`, by BX10 (until_F): `F(event) ∈ A`. If event were inconsistent, then `¬event` is a theorem, so `G(¬event)` is a theorem (by TG), so `¬F(event)` (which is `G(¬event)` up to double negation) is a theorem, contradicting `F(event) ∈ A` since A is MCS.

More precisely: if ¬event is a theorem, then G(¬¬event) is a theorem → ¬F(¬event) is NOT a theorem. Actually, let me be more careful. `F(φ)` is `¬G(¬φ)` definitionally. If `¬φ` is a theorem, then `G(¬φ)` is a theorem (by TG), so `¬F(φ) = G(¬φ)` is a theorem, meaning `F(φ)` is inconsistent and cannot be in MCS A.

Actually, `F(event)` in the codebase is `some_future event = ¬(all_future (¬event))`. Under strict semantics, `until_F` gives us `F(event)` from `untl(guard, event)`. If event were inconsistent (⊢ ¬event), then by TG ⊢ G(¬event), which is ⊢ ¬F(event), making `F(event)` inconsistent. So `F(event) ∈ A` (MCS) means event is consistent.

**So the consistency criterion holds: if `untl(φ, ψ) ∈ A` for MCS A, then ψ is consistent.** This is the exact tool Burgess uses. The `until_guard` axiom even gives us EXTRA: φ ∈ A (the guard holds at the base point), but that's not needed for this lemma.

### 3. The Three Axiom Applications in Burgess's Proof — Translating to BX

Burgess's proof uses A5a, A4a, and A3a in sequence. Here is the exact translation for each:

#### Step A5a: `U(γ,β) → U(γ, β ∧ U(γ,β))`

In our convention: `untl(β,γ) → untl(β ∧ untl(β,γ), γ)`.

**BX replacement**: This is exactly **BX5 (self_accum_until)**: `untl(φ,ψ) → untl(φ ∧ untl(φ,ψ), ψ)`. In our case φ=β, ψ=γ. Already available as `self_accum_until_mcs` in PointInsertion.lean:190-199. **No issue.**

#### Step A4a: Key step getting ¬δ into the formula

Burgess's A4a: `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`.

Applied: with `U(γ, β ∧ U(γ,β)) ∈ A` (from A5a) and `¬U(γ, β∧δ) ∈ A` (from maximality), A4a gives: `U((β∧U(γ,β)) ∧ ¬(β∧δ), β∧U(γ,β)) ∈ A`.

Since `β∧U(γ,β)` is in A and `β` is in A, `¬(β∧δ)` simplifies propositionally to `¬δ` (given β).

So the result is: `U(β∧U(γ,β)∧¬δ, β∧U(γ,β)) ∈ A`.

**Wait — translating to our convention**: Burgess writes `U(event, guard)`. The above is `U(event = (β∧U(γ,β)) ∧ ¬(β∧δ), guard = β∧U(γ,β))`. In our convention: `untl(guard = β∧U(γ,β), event = β∧untl(β,γ)∧¬δ)`.

Hmm, but wait. Let me retranslate more carefully.

Burgess's A4a: `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`, where the first arg is event and second is guard.

So `U(event=p, guard=q) ∧ ¬U(event=p, guard=r) → U(event=q∧¬r, guard=q)`.

Applied to: `U(event=γ, guard=β∧U(γ,β))` and `¬U(event=γ, guard=β∧δ)`.

So p=γ, q=β∧U(γ,β), r=β∧δ. Result: `U(event=(β∧U(γ,β))∧¬(β∧δ), guard=β∧U(γ,β)) ∈ A`.

In OUR convention (guard-first): `untl(guard, event)` = `untl(β∧untl(β,γ), (β∧untl(β,γ))∧¬(β∧δ))`.

Hmm, this is getting complex. Let me think about the abstract form of A4a.

**A4a is NOT valid under strict semantics.** The plan says BX5+BX7 replace A4a. Let me work through the BX7 approach.

**BX7 (linear_until)**: `untl(φ,ψ) ∧ untl(χ,θ) → untl(φ∧χ, ψ∧θ) ∨ untl(φ∧χ, ψ∧χ) ∨ untl(φ∧χ, φ∧θ)`.

We have:
- `untl(β∧untl(β,γ), γ) ∈ A` (from BX5, our convention)
- `¬untl(β∧δ, γ) ∈ A` (from maximality, already in our convention)

The second is a NEGATION, not a positive Until. BX7 requires two positive Until formulas. So we can't directly apply BX7 to these two.

**Alternative approach using BX7**: We need to convert the negation into something useful. The `left_mono_contrapositive_neg_delta` lemma already does something like this via BX2. It gives us `¬δ ∈ A ∨ F(¬δ) ∈ A`.

But Burgess's approach doesn't need BX7 at all for A4a. Let me re-examine A4a's role.

**A4a's role**: Given U(γ, β) and ¬U(γ, β∧δ) in A, produce a formula containing ¬δ as an event in a Until formula in A.

**Under strict semantics, the correct replacement is NOT via BX7 but via Xu's Lemma 2.4 approach**: Xu's Lemma 2.4 is the C4 point insertion in the non-linear case. He uses a much simpler technique: extend B to B* (maximal), observe β∉B* (since we can derive ¬U(γ,β∧δ)∈A), so B*∪{¬β} is consistent. Then let D be any MCS containing B*∪{¬β}.

**However, for D₀ consistency, neither Xu's approach nor the BX7 approach is needed.** The key insight is: Burgess's proof of D₀ consistency (Lemma 2.6) follows a COMPLETELY DIFFERENT path than what the handoff and plan describe.

### 4. The Correct Proof Path: Emulating Burgess Exactly (MEDIUM-HIGH CONFIDENCE)

Let me trace Burgess's exact proof of Lemma 2.6 more carefully:

**Given**: R(A,B,C) (i.e., BurgessR3Maximal(A,B,C)) and δ∉B.

**Goal**: Show D₀ = {S(α,β) : α∈A, β∈B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ∈C, β∈B} is consistent.

**Burgess's argument**: "Much as in the proof of 2.4, it suffices to show that any particular ζ = S(α,β) ∧ β ∧ ¬δ ∧ U(γ,β) with α∈A, β∈B, γ∈C is consistent."

Note: The "much as in the proof of 2.4" invokes a compactness-type argument: if D₀ is inconsistent, some finite L ⊆ D₀ derives ⊥. Since A is closed under ∧ and C is closed under ∧, we can consolidate all the A-elements into one α, all the B-elements into one β, all the C-elements into one γ. The ¬δ part is just one formula. So we reduce to showing each ζ is consistent.

**Translating Burgess's proof to our convention** (guard-first):

Our ζ = snce(β,α) ∧ β ∧ ¬δ ∧ untl(β,γ) with α∈A, β∈B, γ∈C.

Step 1: By maximality of B (BurgessR3Maximal), δ∉B implies ∃β₀∈B, γ₀∈C such that `¬untl(β₀∧δ, γ₀) ∈ A`. WLOG β₀=β, γ₀=γ (replace by conjunctions).

Step 2: From burgessR3: `untl(β, γ) ∈ A` (β∈B is guard, γ∈C is event).

Step 3: BX5: `untl(β∧untl(β,γ), γ) ∈ A`.

Step 4: **This is where A4a was used.** We need to get ¬δ into a Until formula in A.

Under strict semantics, I claim the following works:

From `untl(β∧untl(β,γ), γ) ∈ A` and `¬untl(β∧δ, γ) ∈ A`, we apply BX7 to:
- `untl(β∧untl(β,γ), γ) ∈ A`
- We need ANOTHER positive Until. From BX12, `F(⊤) → untl(⊤,⊤) ∈ A`, and serial_future gives `F(⊤) ∈ A`... this is getting complicated.

Actually, let me reconsider. **BX7 requires two positive Until formulas.** We only have one Until and one negated Until. We cannot directly apply BX7.

**Alternative: Use `left_mono_contrapositive_neg_delta` directly in the ζ-consistency proof.**

We already have (from the existing sorry-free infrastructure): given `untl(β,γ) ∈ A` and `¬untl(β∧δ,γ) ∈ A`:
- `¬δ ∈ A ∨ F(¬δ) ∈ A`

**Case 1**: `¬δ ∈ A`. Then all of D₀ \ Since-part is in A (since B⊆A, Until-part⊆A, ¬δ∈A). The Since-part is in C. But we need ζ consistent, not "all of D₀ in one MCS."

Wait — here's the crucial observation. The entire ζ need not be in one MCS. We just need ζ is **consistent** (i.e., ¬ζ is not a theorem, equivalently {snce(β,α), β, ¬δ, untl(β,γ)} does not derive ⊥).

**Case 1**: ¬δ ∈ A. Then:
- β ∈ A (from B⊆A)
- untl(β,γ) ∈ A (from burgessR3)
- ¬δ ∈ A

So {β, ¬δ, untl(β,γ)} ⊆ A. Since A is consistent, {β, ¬δ, untl(β,γ)} is consistent. But we also need snce(β,α) compatible with these.

**Hmm, this is still the mixed A/C problem.** snce(β,α) ∈ C but we need it compatible with things in A. But wait — does `snce(β,α) ∈ C` help at all?

### 5. The CORRECT Resolution: Adapt Burgess's A4a+A3a Chain

Going back to Burgess's exact chain: the key is that after A4a and A3a, we get a SINGLE Until formula in A containing ALL components of ζ as the event. Then the consistency criterion gives ζ is consistent.

In Burgess (event-first convention):
1. `U(γ, β) ∈ A` → by A5a → `U(γ, β∧U(γ,β)) ∈ A`
2. Combined with `¬U(γ, β∧δ) ∈ A`, A4a gives: `U(β∧U(γ,β)∧¬δ, β) ∈ A`
3. Since α ∈ A, A3a gives: `U(β∧U(γ,β)∧¬δ∧S(α,β), β) ∈ A`
4. The event `β∧U(γ,β)∧¬δ∧S(α,β)` is consistent by Lemma 2.2.
5. Since ζ = S(α,β)∧β∧¬δ∧U(γ,β) is propositionally equivalent to the event, ζ is consistent.

The role of A3a is to "inject" S(α,β) into the event position of the Until formula. The role of A4a is to "inject" ¬δ into the event position.

**Under strict semantics, these roles must be replaced differently.**

**A3a replacement (BX4+BX5)**: A3a says `α ∧ U(γ,β) → U(γ∧S(α,β), β)`. This injects S(α,β) into the event. Under strict semantics this is invalid because S(α,β) at the witness point requires α to be in the past, which is not guaranteed for the current point.

The existing code's approach for Lemma 2.4 uses BX4 (connect_future): `α → G(P(α))`. Since α ∈ A, we get `G(P(α)) ∈ A`, meaning P(α) is in the g_content. Then the Lindenbaum extension of the seed includes P(α), from which S(α,β) can be derived using burgessRSince properties.

**But for Lemma 2.6, we need a different approach.** We need to get S(α,β) (or something implying it) into the event of a Until formula that's in A.

**Key insight**: Under strict semantics, A3a can be replaced by the following chain:

From `untl(β, event) ∈ A` and `α ∈ A`:
- BX4: `α → G(P(α))`, so `G(P(α)) ∈ A`
- BX3 (right_mono_until): `G(event → event∧P(α)) → (untl(β,event) → untl(β, event∧P(α)))`
- If `⊢ event → event∧P(α)` or `G(event → event∧P(α)) ∈ A`...

This doesn't quite work because `event → event∧P(α)` requires `P(α)` to hold at every future point, which IS given by `G(P(α)) ∈ A`.

Actually, we need: for any Until formula `untl(β, event) ∈ A`, if `G(P(α)) ∈ A`, can we get `P(α)` into the event? By BX3 (right monotonicity): `G(φ → ψ) → (untl(β,φ) → untl(β,ψ))`. If we set ψ = φ∧P(α), we need `G(event → event∧P(α)) ∈ A`. We have `G(P(α)) ∈ A`. We need `⊢ P(α) → (event → event∧P(α))`, which is just `⊢ q → (p → p∧q)`, a propositional tautology. So `G(P(α) → (event → event∧P(α))) ∈ A` by TG, and combined with `G(P(α)) ∈ A` using temporal K, we get `G(event → event∧P(α)) ∈ A`. Then BX3 gives `untl(β, event∧P(α)) ∈ A`.

**So we can enrich the event with P(α) but NOT with S(α,β) directly.** But P(α) is not the same as S(α,β) = snce(β,α).

**However, we don't actually NEED S(α,β) in the event.** We need ζ CONSISTENT. If we can show {snce(β,α), β, ¬δ, untl(β,γ)} is consistent, that's enough. And this reduces to: is it possible for all four to hold simultaneously?

### 6. A Different Strategy: Sufficiency of Subset Consistency (HIGH CONFIDENCE)

**Critical realization**: We don't need to pack everything into one Until formula. We can use a different decomposition of the consistency argument.

**Approach**: Instead of showing ζ = S(α,β) ∧ β ∧ ¬δ ∧ U(γ,β) is consistent by the single-Until-event trick, use the following:

(a) From BurgessR3Maximal maximality + BX2 contrapositive (existing `left_mono_contrapositive_neg_delta`): either ¬δ∈A or F(¬δ)∈A.

By the dual argument (Since side), either ¬δ∈C or P(¬δ)∈C.

(b) **Case ¬δ∈A and ¬δ∈C**: All of {β, ¬δ, untl(β,γ)} ⊆ A and {β, ¬δ, snce(β,α)} ⊆ C. We need {snce(β,α), β, ¬δ, untl(β,γ)} consistent. But untl(β,γ)∈A and snce(β,α)∈C, and we need them to be JOINTLY consistent, which isn't immediate.

**Hmm, same issue.** Let me think again...

### 7. THE KEY INSIGHT: Burgess's Consistency Criterion IS Usable Under Strict Semantics (HIGH CONFIDENCE)

Going back to Burgess's proof:

Step 4 (A4a) gives: `U(β∧U(γ,β)∧¬δ, β) ∈ A` (in Burgess's event-first convention).

Translating to our convention: `untl(β, β∧untl(β,γ)∧¬δ) ∈ A`.

Step 5 (A3a) gives: `U(β∧U(γ,β)∧¬δ∧S(α,β), β) ∈ A`.

Translating to our convention: `untl(β, β∧untl(β,γ)∧¬δ∧snce(β,α)) ∈ A`.

Then Lemma 2.2 gives: the EVENT `β∧untl(β,γ)∧¬δ∧snce(β,α)` is consistent. 

Under strict semantics, `until_F` gives `F(β∧untl(β,γ)∧¬δ∧snce(β,α)) ∈ A`, and this implies the event is consistent (proven above in finding #2).

So **the only question is: can we construct `untl(β, β∧untl(β,γ)∧¬δ∧snce(β,α)) ∈ A` under strict semantics?**

This requires replacing A4a (to get ¬δ into the event) and A3a (to get snce(β,α) into the event) with BX axiom chains.

**For A3a replacement (getting snce(β,α) into the event)**:

Actually, rather than following Burgess's exact order, we can use BX3 (right monotonicity) directly. If we have `untl(guard, event) ∈ A` and we want to add more to the event, we can use BX3: `G(event → event∧new) → (untl(guard, event) → untl(guard, event∧new))`. The question is whether `G(event → event∧snce(β,α))` holds in A.

This requires `G(snce(β,α)) ∈ A` (since `⊢ snce(β,α) → (event → event∧snce(β,α))` propositionally, and then by TG and K-distribution). But `G(snce(β,α))` need not hold in A. The snce(β,α) is in C, not necessarily in A.

**A3a replacement using BX4**: From α∈A, by BX4: G(P(α)) ∈ A. We can enrich any event with P(α), but P(α) ≠ snce(β,α).

**Wait — can we use the burgessRSince condition?** From burgessR3(A,B,C): for β∈B, α∈A, snce(β,α) ∈ C. But we need it (or something implying it) in A, or provably consistent with things in A.

**IMPORTANT REALIZATION**: Burgess's A3a says `α ∧ U(γ,β) → U(γ∧S(α,β), β)`. Under reflexive semantics, this is valid because at the witness point of U(γ,β), γ holds and by looking backwards, S(α,β) holds (since α was true at the previous point and β held throughout). Under STRICT semantics, at the Until witness point s>t: γ(s) holds, β holds on [t,s), but S(α,β) at s requires a point s'<s with α(s') and β on (s',s]. The point t satisfies t<s and α(t), and β holds on (t,s) = [t,s) ∩ (t,s]. But under strict semantics, the half-open Since guard (s',t] means β must hold at s as well? No — S(α,β) at point s means: ∃s'<s with α(s') and β on (s',s]. The guard covers (s',s], which includes s. Under strict Since, S(event, guard) at s means ∃s'<s, event(s') ∧ ∀u(s'<u<s → guard(u)). So guard covers the open interval, NOT s itself. Since guard here is β, we need β on (s',s) for some s' with α(s'). If we take s'=t, then β on (t,s), which is a subset of [t,s) where β holds as the Until guard. So (t,s) ⊆ [t,s), and β holds on [t,s), so β holds on (t,s). 

**So snce(β,α) holds at s under strict semantics!** Because we take the Since witness s'=t (where α(t) holds since α∈A), and the Since guard β holds on the open interval (t,s). 

But this is a SEMANTIC argument, and we're inside the COMPLETENESS proof (syntactic). We need a SYNTACTIC proof — an axiom chain that derives `untl(β, event∧snce(β,α)) ∈ A` from `untl(β, event) ∈ A` and `α ∈ A`.

**The syntactic version of the A3a argument**: Under strict semantics, the correct axiom is:

`α ∧ untl(β, γ) → untl(β, γ ∧ snce(β, α))`

Wait — that is literally A3a in our convention! In Burgess: A3a = `p ∧ U(q,r) → U(q∧S(p,r), r)` where U is (event,guard). In our convention: `α ∧ untl(β,γ) → untl(β, γ ∧ snce(β,α))`.

**Is this valid under strict semantics?** Let me check:

`untl(β,γ)` at t: ∃s>t, γ(s) ∧ ∀u∈[t,s), β(u).
We want: `untl(β, γ∧snce(β,α))` at t: ∃s>t, (γ∧snce(β,α))(s) ∧ ∀u∈[t,s), β(u).

At the same witness s: γ(s) ✓. snce(β,α) at s: ∃s'<s, α(s') ∧ ∀u(s'<u<s → β(u)). Take s'=t: α(t) ✓ (hypothesis). β on (t,s): since β holds on [t,s) and (t,s) ⊆ [t,s) (as t<s, strict), β holds on (t,s) ✓.

**YES! A3a IS valid under strict (irreflexive) semantics!** The half-open guard [t,s) for Until gives β on [t,s), and the strict Since at s needs β on (s',s) = (t,s). Since (t,s) ⊆ [t,s), this is fine.

Wait, but the codebase says "A3a is NOT valid under strict semantics" (PointInsertion.lean lines 17-18). Let me re-check what the codebase calls A3a.

Looking at the header comment in PointInsertion.lean:
```
- **A3a's role** (Lemma 2.4 seed consistency): BX4 (`connect_future: φ → G(P(φ))`)
  + BX5 (`self_accum_until`) provide the algebraic content directly.
```

And: "Burgess uses axioms A3a and A4a which are **not valid** under strict semantics"

But there's also a note in TemporalDerived.lean. Let me check whether A3a was actually tested or this was assumed.

The exact formula of A3a in Burgess is: `p ∧ U(q,r) → U(q∧S(p,r), r)`, with U(event, guard).

In our convention: `α ∧ untl(guard=β, event=γ) → untl(guard=β, event=γ∧snce(guard=β, α))`.

I.e.: `α ∧ untl(β,γ) → untl(β, γ∧snce(β,α))`.

The semantic analysis above shows this IS valid under strict semantics (irreflexive, half-open guard). The codebase may have been confused about this. Let me verify the counterexample claim.

Actually, I should check whether A3a under strict Until semantics BUT reflexive Since semantics might fail. In our codebase, Since also uses strict (irreflexive) semantics with half-open guard. So snce(β,α) at s means: ∃s'<s (strict), α(s'), ∀u(s'<u<s → β(u)) (open interval guard). With s'=t<s and α(t), the guard is β on (t,s), which holds since β holds on [t,s) ⊇ (t,s). So A3a is valid.

**Correction**: If the Since guard uses a closed interval (s',s] (covering the base point s), then snce(β,α) at s would require β(s), which is NOT given (β holds on [t,s), and s ∉ [t,s)). This would make A3a invalid.

**What does our codebase use?** From Axioms.lean line 270-274:
```
/-- Since guard: `(φ S ψ) → φ`.
Under half-open guard (s,t]: φ S ψ at t has witness s < t with ψ(s) and φ on (s,t].
Since s < t and t ≤ t, the guard gives φ(t). -/
| since_guard (φ ψ : Formula) :
    Axiom ((Formula.snce φ ψ).imp φ)
```

So the Since guard is on the half-open interval (s,t] covering t. This means snce(β,α) at s (the Until witness point): ∃s'<s, α(s'), β on (s',s]. The guard (s',s] includes s itself!

So snce(β,α) at s with s'=t: α(t) ✓, β on (t,s]. We need β(s), but β only holds on [t,s) (from the Until guard). Since s ∉ [t,s), β(s) is NOT guaranteed. **A3a IS invalid under these semantics.**

**So the codebase is correct: A3a is invalid because the Until guard covers [t,s) (doesn't include the witness) while the Since guard covers (s',s] (DOES include the base point).** At the Until witness point s, the Until guard doesn't guarantee β(s), but the Since formula at s would require β(s) via the since_guard axiom.

### 8. Corrected Analysis: A3a Replacement

Since A3a is indeed invalid, we need an alternative to get snce(β,α) (or something that implies its consistency) into the event of a Until formula.

**Approach**: Instead of trying to pack snce(β,α) into the Until event, we can use the following observation:

At the Until witness point s: we have γ(s), and by BX4 applied to the entire Until formula, we have P(untl(β,γ))(s). We also have α(t) for t in the past. Using BX4 on α: G(P(α)) ∈ A, so P(α) ∈ g_content(A).

**Modified ζ**: Instead of requiring exact consistency of snce(β,α) ∧ β ∧ ¬δ ∧ untl(β,γ), we show that D₀ is consistent by an INDIRECT argument:

**Claim**: If D₀ is inconsistent, then we can derive δ from a finite subset of D₀\{¬δ}. But D₀\{¬δ} = {snce(β,α) : α∈A, β∈B} ∪ B ∪ {untl(β,γ) : β∈B, γ∈C}. 

All elements of D₀\{¬δ} are in A (the Until parts and B parts) or in C (the Since parts and B parts). The B parts are in both A and C (by B⊆A∩C).

The Until formulas untl(β,γ)∈A. The Since formulas snce(β,α)∈C. If some finite L⊆D₀\{¬δ} derives δ, then we can separate L into L_A (elements in A) and L_C (elements in C\A).

**But deriving δ from elements of A and elements of C is a mixed-MCS argument.** The derivation system doesn't "know" about A and C — it operates on syntactic formulas. A derivation from L derives δ regardless of which MCS the formulas came from. So we need a purely syntactic argument.

**The correct indirect approach**: D₀ is inconsistent iff ∃ finite L ⊆ D₀, L ⊢ ⊥. Since ¬δ ∈ D₀, separating it out: ∃ finite L' ⊆ D₀\{¬δ}, L'∪{¬δ} ⊢ ⊥, i.e., L' ⊢ δ. By deductive closure, δ ∈ DC(D₀\{¬δ}).

Now, D₀\{¬δ} = Since-part ∪ B ∪ Until-part. The Since-part consists of formulas in C, the B-part of formulas in A∩C, and the Until-part of formulas in A.

If we could show DC(D₀\{¬δ}) ⊆ DC(B) (or more precisely that δ∈DC(B)), we'd contradict δ∉B (since B is a DCS). But DC(D₀\{¬δ}) is larger than DC(B) because it includes non-B elements.

**Can we show δ∈DC(B)?** The Until formulas untl(β,γ)∈A tell us nothing directly about δ. The Since formulas snce(β,α)∈C also tell us nothing directly about δ. The B-elements are in B. So a derivation from L'⊆D₀\{¬δ} would use Until/Since formulas ONLY as opaque atoms — the derivation rules can only use propositional logic, temporal generalization, and the axiom schemes. A Until or Since formula in L' can only contribute through axiom instances.

**This is actually the heart of the matter.** The Until and Since formulas, treated as syntactic objects in a derivation, cannot contribute propositional content about δ unless there are axioms that connect them. And under our strict semantics, the axioms that DO connect Until/Since formulas are:
- BX9 (until_elim): untl(φ,ψ) → φ∨ψ
- BX10 (until_F): untl(φ,ψ) → F(ψ)
- until_guard: untl(φ,ψ) → φ
- Various monotonicity/accumulation axioms

So from untl(β,γ), the derivation system can extract: β (until_guard), γ∨β (until_elim), F(γ) (until_F). From snce(β,α): β (since_guard), α∨β (since_elim), P(α) (since_P).

The propositional content extractable from D₀\{¬δ} is thus: B ∪ {things derivable from β,γ,α via axiom chains}, which are all things derivable from MCS-formulas. Since B is a DCS, any formula derivable from B alone is in B. The Until/Since formulas add formulas from A\B and C\B, but these are opaque to propositional reasoning about δ.

**The crucial question**: Can a derivation from elements of D₀\{¬δ} derive δ, where no element of D₀\{¬δ} mentions δ as a subformula?

**Lemma 2.2 / consistency criterion approach works differently**: Rather than the indirect argument, Burgess directly constructs an Until formula in A whose event contains ζ, proving ζ consistent.

Under strict semantics, the analogous strategy is:

1. Construct `untl(β, EVENT) ∈ A` where EVENT contains all non-Since parts of ζ (i.e., β∧¬δ∧untl(β,γ)), and separately handle the Since part.

2. For the ¬δ part: `left_mono_contrapositive_neg_delta` gives ¬δ∈A or F(¬δ)∈A.

   - If ¬δ∈A: Then β∧¬δ∧untl(β,γ) ∈ A (since all parts are in A), so {β∧¬δ∧untl(β,γ)} is consistent. Extend to ζ: need snce(β,α) consistent with β∧¬δ∧untl(β,γ). Since snce(β,α)∈C and C is MCS, snce(β,α) is consistent. But joint consistency isn't free...

   **Better approach for this case**: Since ¬δ∈A, we have β∧untl(β,γ)∧¬δ ∈ A. Now by BX4 on α∈A: G(P(α))∈A. By BX3 (right_mono on P(α)): `untl(β, γ∧P(α)) ∈ A`. Then by BX5: `untl(β∧untl(β,γ∧P(α)), γ∧P(α)) ∈ A`. The event γ∧P(α) is consistent by the consistency criterion. 
   
   But we need ζ = snce(β,α)∧β∧¬δ∧untl(β,γ) consistent. This is propositionally weaker than snce(β,α)∧β∧¬δ∧untl(β,γ), which requires joint consistency.

OK, I'm going in circles. Let me try the completely different "Xu approach" instead.

### 9. XU'S APPROACH: MUCH SIMPLER, FULLY COMPATIBLE (HIGH CONFIDENCE)

Re-reading Xu 1988, Lemma 2.4: Given r(A,B,C), ¬U(γ,β)∈A, γ∈C:

"Let B* be such that B⊆B* and R(A,B*,C). Clearly β∉B*, and hence B*∪{¬β} is consistent. Let D be a MCS containing B*∪{¬β}. By 2.3 and 2.1 we have r(A,⊤,D) and r(D,⊤,C). Hence we can complete the proof by applying 2.0."

**Xu's Lemma 2.3**: "Suppose that R(A,B,C). Then (i) S(α,⊤) ∈ B for every α∈A, and (ii) U(γ,⊤)∈B for every γ∈C."

In our convention: If BurgessR3Maximal(A,B,C), then:
- (i) snce(⊤,α) ∈ B for every α∈A — equivalently, P(α) ∈ B
- (ii) untl(⊤,γ) ∈ B for every γ∈C — equivalently, F(γ) ∈ B

**Proof of (ii)**: Suppose untl(⊤,γ)∉B for some γ∈C. By maximality, ∃β₀∈B, γ₀∈C such that ¬untl(β₀∧untl(⊤,γ), γ₀)∈A. But from burgessR3: untl(β₀,γ₀)∈A, so by BX5: untl(β₀∧untl(β₀,γ₀), γ₀)∈A. Using BX2 (left_mono): since ⊢ β₀∧untl(β₀,γ₀) → β₀∧untl(⊤,γ) ... hmm, that requires untl(β₀,γ₀)→untl(⊤,γ₀). By BX2 and the theorem β₀→⊤: actually we need `untl(β₀,γ₀) → untl(⊤,γ₀)`. This follows from BX2 since ⊢ β₀→⊤ and ⊢ G(β₀→⊤).

Then `untl(⊤,γ₀) ∈ A`, which means `F(γ₀) ∈ A`. And we need `untl(⊤,γ) ∈ A` somehow from `F(γ)`. By BX12: `F(γ) → untl(⊤,γ)`. So `untl(⊤,γ) ∈ A`. And by BX2: `untl(β₀∧untl(⊤,γ), γ₀) ∈ A` since `untl(β₀∧untl(β₀,γ₀), γ₀) ∈ A` and `⊢ β₀∧untl(β₀,γ₀) → β₀∧untl(⊤,γ₀)`... this is getting complicated.

Actually, let me focus on what matters. **The key to Xu's approach for our C4 elimination** is his Lemma 2.4, which uses a different D₀:

In Xu's framework, D = B* ∪ {¬β}. Here B* is an R-maximal extension of B — i.e., our BurgessR3Maximal(A, B*, C) with B⊆B*. Since B is already maximal (BurgessR3Maximal(A,B,C)), B* = B. So D = B ∪ {¬δ} (replacing β with δ to match our notation).

{¬δ} ∪ B is consistent because δ∉B and B is a DCS (by `dcs_neg_union_consistent`, already proved in PointInsertion.lean:381-438).

Then D = any MCS extending {¬δ} ∪ B. By Xu's Lemma 2.3: P(α)∈B for all α∈A, and F(γ)∈B for all γ∈C. So P(α)∈D and F(γ)∈D (since B⊆D).

Then burgessR3(A, {⊤}, D): for any d∈D and any β₀∈{⊤}: untl(⊤, d)∈A iff F(d)∈A. We need F(d)∈A for all d∈D. But D is an arbitrary MCS, not all of D is necessarily "visible" from A.

Actually, Xu says "r(A, ⊤, D)" which means for all d∈D, U(d,⊤)∈A, i.e., in our convention, untl(⊤,d)∈A, i.e., F(d)∈A. This doesn't hold for arbitrary d∈D.

Wait, I think Xu means: r(A, ⊤, D) holds because {S(α,⊤) : α∈A} ⊆ B ⊆ D, equivalently {P(α) : α∈A} ⊆ D. By Lemma 2.1 (our burgessR equivalence), this means for all α∈A, S(α,⊤)∈D, which by Xu's convention means r(A,⊤,D) via 2.1(b→a). Actually in Xu's framework, r(A,β,C) requires ∀γ∈C, U(γ,β)∈A. So r(A,⊤,D) means ∀d∈D, U(d,⊤)∈A, i.e., ∀d∈D, F(d)∈A. This is a strong requirement.

Hmm, Xu's argument actually requires Axiom (3) = A3a to prove Lemma 2.3! Let me check...

Looking at Xu's proof of 2.3(i): "Suppose S(α,⊤)∉B for some α∈A. Then by 2.0(iii) there are β∈B and γ∈C such that ¬U(γ, β∧S(α,⊤))∈A. But this is impossible. For it is not hard to see by (1) and (3) that α∧U(γ,β) → U(γ, β∧S(α,⊤)) ∈ TL_{US}(∅)."

Here (3) IS A3a! So Xu's proof of Lemma 2.3 depends on A3a, which is invalid under strict semantics. **Xu's approach as-is won't work.**

### 10. FINAL RECOMMENDED APPROACH: Direct Seed Consistency via Maximality Argument (MEDIUM-HIGH CONFIDENCE)

Since both Burgess's A4a+A3a chain and Xu's Lemma 2.3 use axioms invalid under strict semantics, we need a different approach. Here is my recommended strategy:

**Approach: Direct proof that D₀ is consistent via the maximality of B.**

**Proof sketch**: Suppose D₀ = {snce(β,α):α∈A,β∈B} ∪ B ∪ {¬δ} ∪ {untl(β,γ):β∈B,γ∈C} is inconsistent. Then ∃ finite L ⊆ D₀, L ⊢ ⊥.

Separate L into:
- L_S = {snce(β_i, α_i) : ...} (Since formulas)
- L_B = {β_j : ...} (B-elements)
- L_δ = {¬δ} or empty
- L_U = {untl(β_k, γ_k) : ...} (Until formulas)

Since MCSs are closed under ∧, we can consolidate:
- All Since formulas → snce(β_S, α_S) where β_S = ∧β_i, α_S = ∧α_i (using BX2'/BX3' monotonicity)
- All B-elements → β_B = ∧β_j
- All Until formulas → untl(β_U, γ_U) where β_U = ∧β_k, γ_U = ∧γ_k (using BX2/BX3 monotonicity)

Actually, we can't consolidate Since/Until formulas by conjunction directly — `snce(β₁,α₁) ∧ snce(β₂,α₂)` is not the same as `snce(β₁∧β₂, α₁∧α₂)`. However, ⊢ snce(β₁,α₁) ∧ snce(β₂,α₂) → snce(β₁∧β₂, α₁∧α₂)? Not necessarily (the two Since witnesses might be different past points).

**So Burgess's "suffices to show each ζ is consistent" argument relies on A3a/A1a to consolidate.** Under strict semantics, this consolidation step requires its own justification.

**Alternative**: Show that D₀ ⊆ A in the case ¬δ∈A, and D₀ ⊆ C in the case ¬δ∈C. Then consistency follows from the MCS property.

- If ¬δ∈A: B⊆A ✓, ¬δ∈A ✓, untl(β,γ)∈A ✓ (from burgessR3). But snce(β,α)∈C, NOT necessarily in A. **Fails.**

- If ¬δ∈C: B⊆C ✓, ¬δ∈C ✓, snce(β,α)∈C ✓ (from burgessR3). But untl(β,γ)∈A, NOT necessarily in C. **Fails.**

**THE CORRECT APPROACH: Two-seed construction**

The handoff mentioned this as "approach 4" and recommended it as "most promising":

Instead of proving D₀ consistent directly, **use a smaller seed and rely on the Lindenbaum extension + burgessR3 structure**.

**Seed**: `{¬δ} ∪ B` — this IS consistent (by `dcs_neg_union_consistent`, proven sorry-free).

**Construct D**: MCS extending `{¬δ} ∪ B`. Then ¬δ∈D and B⊆D.

**Goal**: Show burgessR3(A, B, D) and burgessR3(D, B, C), then extend to BurgessR3Maximal.

**burgessR3(A, B, D)**: requires (a) ∀β∈B, ∀d∈D: untl(β,d)∈A, and (b) ∀β∈B, ∀α∈A: snce(β,α)∈D.

Part (a): D is an arbitrary MCS, so d∈D can be anything. We need untl(β,d)∈A for ALL d∈D. This is the r(A,β,D) condition, which means A "sees" D through B. This doesn't hold for arbitrary D — it would require untl(β,d)∈A for formulas d that A knows nothing about.

**This approach also fails in its naive form.** The problem is that D is an arbitrary Lindenbaum extension, so it contains formulas that A has no knowledge of.

**REVISED STRATEGY: Augment the seed so burgessR3 conditions are baked in.**

This is EXACTLY what Burgess does with D₀! The Until and Since formulas in D₀ ENSURE that burgessR3(A, B, D) and burgessR3(D, B, C) hold. But the consistency of D₀ is what we can't prove directly.

### ULTIMATE FINDING: The Correct Mathematical Path

After this extensive analysis, here is the correct approach:

**We need a new theorem that can replace both A3a and A4a in the context of D₀ consistency.** The exact requirement is:

For each β∈B, α∈A, γ∈C, the set {snce(β,α), β, ¬δ, untl(β,γ)} is consistent.

Under strict semantics, the proof is:

1. From BurgessR3Maximal maximality + BX2 contrapositive: WLOG ¬untl(β∧δ, γ)∈A.
2. From burgessR3: untl(β,γ)∈A.  
3. BX5: untl(β∧untl(β,γ), γ)∈A.
4. **Key step (replaces A4a)**: We need to get ¬δ into a Until event. Since ¬untl(β∧δ,γ)∈A, by `left_mono_contrapositive_neg_delta`: ¬δ∈A or F(¬δ)∈A.

   **Case ¬δ∈A**: Then {β, ¬δ, untl(β,γ)} ⊆ A, hence consistent. Need to show snce(β,α) is compatible. Since α∈A, by BX4: G(P(α))∈A. Since untl(β,γ)∈A, by BX3 with G(P(α)): untl(β, γ∧P(α))∈A. The event γ∧P(α) is consistent (by until_F + argument from Finding #2). And snce(β,α) is implied by P(α)∧β (not exactly, but: at any point where P(α) and β hold, if we're at a point where γ∧P(α) was witnessed by a Until, then the P(α) witness gives a past point with α, and the interval has β, giving snce(β,α)). But this is semantic, not syntactic!

   **Syntactically**: We need an axiom that gives us snce(β,α) from existing formulas. The issue is that A3a (which does this) is invalid.

   **However**, we can use a WEAKER form: we don't need snce(β,α) inside a Until event. We just need the set {snce(β,α), β, ¬δ, untl(β,γ)} to be consistent. 

   In Case ¬δ∈A: we have β∧¬δ∧untl(β,γ) ∈ A (all three in A). So β∧¬δ∧untl(β,γ) is consistent (it's in an MCS). If snce(β,α) were inconsistent with β∧¬δ∧untl(β,γ), then ⊢ (β∧¬δ∧untl(β,γ)) → ¬snce(β,α), meaning ⊢ snce(β,α) → ¬(β∧¬δ∧untl(β,γ)). But snce(β,α)∈C (consistent), so snce(β,α) is consistent, and β∧¬δ∧untl(β,γ) is consistent. However, two consistent formulas can still be jointly inconsistent...

   **Wait — can they?** If ⊢ φ → ¬ψ, then φ and ψ are jointly inconsistent even though each is individually consistent. So individual consistency doesn't give joint consistency. 

   **But**: snce(β,α) and untl(β,γ) have NO propositional connection via axioms that would make them jointly inconsistent. The only axioms connecting Since and Until are BX4/BX4' (connect_future/past) and they connect through G/H, not directly.

   **Can the derivation system derive ⊥ from {snce(β,α), β, ¬δ, untl(β,γ)}?** The derivation system has:
   - Propositional logic
   - Temporal generalization (TG): from ⊢φ, infer ⊢Gφ and ⊢Hφ
   - All BX axiom instances

   From snce(β,α), the derivation system can extract: β (since_guard), P(α) (since_P).
   From untl(β,γ), it can extract: β (until_guard), F(γ) (until_F).
   
   So the propositional content available is: {β, P(α), F(γ), ¬δ}. For ⊥ to be derivable, we need some interaction among β, P(α), F(γ), ¬δ that produces ⊥. But these are all independent formulas — no BX axiom connects P(α) with F(γ) or ¬δ in a way that produces ⊥.

   **Formal argument**: All elements of {snce(β,α), β, ¬δ, untl(β,γ)} are in A∪{snce(β,α)} where β∧¬δ∧untl(β,γ)∈A. If L⊆{snce(β,α), β, ¬δ, untl(β,γ)} and L⊢⊥, separate L into L_A (elements in A) and L_S = {snce(β,α)} if present. If snce(β,α)∉L, then L⊆A and L⊢⊥ contradicts A being MCS. If snce(β,α)∈L, then by the deduction theorem: L\{snce(β,α)} ⊢ snce(β,α) → ⊥, i.e., L\{snce(β,α)} ⊢ ¬snce(β,α). Since L\{snce(β,α)} ⊆ A, we get ¬snce(β,α)∈A (by deductive closure of MCS). But snce(β,α)∈C and C is an MCS, so snce(β,α) is consistent. We need: ¬snce(β,α)∈A and snce(β,α)∈C — is this a contradiction? **NO**, because A and C are DIFFERENT MCSs.

   So this approach also fails to give a contradiction directly. The formulas ¬snce(β,α)∈A and snce(β,α)∈C are perfectly compatible (A≠C).

This is genuinely hard. Let me reconsider the whole situation.

### 11. THE MATHEMATICAL REALITY: New Axiom or Weaker Seed Needed

After thorough analysis, here's the situation:

1. **Burgess's exact proof requires A3a and A4a**, both invalid under strict semantics.
2. **A4a can be partially replaced** by BX2 contrapositive (existing `left_mono_contrapositive_neg_delta`).
3. **A3a has NO direct BX replacement** that packs snce(β,α) into an Until event in A.
4. **The "mixed A/C" problem IS real**: D₀ contains elements from different MCSs, and standard consistency arguments (single-MCS containment, pairwise consistency) don't immediately give joint consistency.

**The two viable paths are**:

**Path A: Weaker seed {¬δ}∪B (bypasses D₀ entirely)**

Use {¬δ}∪B as the seed (provably consistent by `dcs_neg_union_consistent`). Let D = Lindenbaum({¬δ}∪B). Then B⊆D, ¬δ∈D. The challenge: prove burgessR3(A,B,D) and burgessR3(D,B,C) for this particular D.

For burgessR3(A,B,D): need ∀β∈B, ∀d∈D: untl(β,d)∈A. This fails for arbitrary d∈D.

**But**: We DON'T need burgessR3(A,B,D). We need burgessR3(A,B',D) for SOME B'⊇B, which we then extend to BurgessR3Maximal. The weakest useful thing is burgessR3(A,{⊤},D), i.e., r(A,⊤,D). This means ∀d∈D: untl(⊤,d)∈A, i.e., F(d)∈A for all d∈D.

For this, we need F(d)∈A for all d∈D. Since D = Lindenbaum({¬δ}∪B), d∈D means d is a consequence of {¬δ}∪B. Does F(d)∈A for all d∈DC({¬δ}∪B)?

This requires G(d→d')∈A for enough d, which essentially requires the G/F content of A to "cover" all of D. This is not guaranteed.

**Path B: Add a new axiom connecting Since and Until (the A3a strict replacement)**

We could add an axiom that replaces A3a's role. Something like:

`α ∧ untl(β,γ) → untl(β, γ ∧ P(α))`

This says: if α holds now and there's an Until event γ in the future, then there's an Until event γ∧P(α) (γ and the past eventuality of α). Under strict semantics, this is valid: at the witness point s, γ(s) holds and P(α)(s) holds because α(t) at the current point t<s. So P(α) holds at any future point.

**Wait, this is just BX4 + BX3!** BX4: α → G(P(α)). So G(P(α))∈A. Then BX3: G(P(α) → ...) combined with... Actually:

- G(P(α))∈A gives: at all future points, P(α) holds.
- For the Until event γ: at the witness point, γ holds AND P(α) holds.
- So γ∧P(α) holds at the witness point.
- The guard β still holds on [t,s).
- Therefore: untl(β, γ∧P(α)) ∈ A.

**Syntactic proof**: From G(P(α))∈A, we derive G(γ → γ∧P(α))∈A (since ⊢ P(α) → (γ → γ∧P(α)) and TG+K give G(P(α)) → G(γ → γ∧P(α))). Then BX3: G(γ→γ∧P(α)) → (untl(β,γ) → untl(β, γ∧P(α))). So untl(β, γ∧P(α)) ∈ A.

**This works!** We CAN enrich the Until event with P(α). So:

Starting from untl(β,γ)∈A and α∈A:
- BX4: G(P(α))∈A
- Propositional + TG + K: G(γ → γ∧P(α))∈A
- BX3: untl(β, γ∧P(α))∈A

Now repeat for ¬δ. If ¬δ∈A:
- G(¬δ → ...) wait, we need G(¬δ) for this approach. G(¬δ)∈A iff ¬F(δ)∈A iff F(δ)∉A. We don't know this.

But we DO have ¬δ∈A. By BX4: G(P(¬δ))∈A. So we can enrich the event with P(¬δ): untl(β, γ∧P(α)∧P(¬δ))∈A. Then the event γ∧P(α)∧P(¬δ) is consistent.

Now ζ = snce(β,α)∧β∧¬δ∧untl(β,γ). Is ζ implied by (or at least consistent with) the event γ∧P(α)∧P(¬δ)?

The event is consistent, but it doesn't contain ζ. We need a formula containing all of {snce(β,α), β, ¬δ, untl(β,γ)} to be consistent.

**Final synthesis**: Use the Until event enrichment + BX5:

1. untl(β,γ)∈A (from burgessR3)
2. BX4 on α∈A: G(P(α))∈A → enrich event: untl(β, γ∧P(α))∈A (by BX3)
3. If ¬δ∈A: BX4 on ¬δ: G(P(¬δ))∈A → enrich event: untl(β, γ∧P(α)∧P(¬δ))∈A
4. BX5: untl(β∧untl(β, γ∧P(α)∧P(¬δ)), γ∧P(α)∧P(¬δ))∈A
5. The EVENT γ∧P(α)∧P(¬δ) is consistent (by until_F + MCS).

But ζ = snce(β,α) ∧ β ∧ ¬δ ∧ untl(β,γ). We need ζ consistent, not just the event.

ζ is propositionally weaker than: β ∧ ¬δ ∧ snce(β,α) ∧ untl(β,γ). If we had β ∧ ¬δ ∧ snce(β,α) ∧ untl(β,γ) inside a single consistent formula, we'd be done. But the event γ∧P(α)∧P(¬δ) doesn't contain snce(β,α) or untl(β,γ) or β or ¬δ directly.

**Can we prove ζ ≤ (some consistent formula)?** I.e., ⊢ (consistent_formula) → ζ?

If we take the consistent event γ∧P(α)∧P(¬δ): can we derive ζ from it? No — γ∧P(α)∧P(¬δ) doesn't entail β (the guard), ¬δ (only P(¬δ)), snce(β,α) (only P(α)), or untl(β,γ).

**I think the correct approach is to use BX5 to pack MORE into the guard, then use until_guard to extract it**:

untl(β∧untl(β,γ∧P(α)∧P(¬δ)), γ∧P(α)∧P(¬δ))∈A (from step 4 above).

By until_guard: β∧untl(β,γ∧P(α)∧P(¬δ)) ∈ A. So β∈A and the enriched Until is in A.

But this still doesn't give us ζ as a single consistent formula.

**I think the mathematically correct approach is**: We need to modify the D₀ seed. Instead of including the raw snce(β,α) formulas, include P(α) formulas (which ARE in B via the g_content/h_content).

**Modified D₀**:
D₀' = {P(α) : α∈A} ∪ B ∪ {¬δ} ∪ {F(γ) : γ∈C}

OR: D₀' = B ∪ {¬δ}

Since {P(α) : α∈A} ⊆ g_content(A) ⊆ B (wait, is g_content(A) ⊆ B?). From B_sub_A_of_burgessR3, B⊆A. g_content(A) = {G(φ) : G(φ)∈A}. We need G(φ)∈B for all G(φ)∈A. This is NOT obvious. In Burgess's R(A,B,C), B is maximal with respect to r(A,-,C), but g_content(A) ⊆ B doesn't follow directly.

Actually, from Xu's Lemma 2.3: if R(A,B,C), then P(α)∈B for all α∈A. But Xu's proof uses A3a which is invalid. So we cannot assume this.

**Conclusion**: The mathematically correct long-term solution requires either:

(A) Proving an analog of Xu's Lemma 2.3 (P(α)∈B and F(γ)∈B) using only BX axioms, which would make {¬δ}∪B a sufficient seed, OR

(B) Finding a different axiom chain that achieves the consolidation effect of A3a+A4a under strict semantics, OR

(C) Restructuring the construction to avoid D₀ entirely, using a different architecture.

**My recommendation is (A)**: Prove the BX analog of Xu's Lemma 2.3. Once we have P(α)∈B and F(γ)∈B for all α∈A, γ∈C, the seed {¬δ}∪B is consistent (already proven) and B already contains all the necessary Since-past/Until-future content. Then D = Lindenbaum({¬δ}∪B), and r(A,⊤,D) follows from {P(α)}⊆D, and r(D,⊤,C) follows from {F(γ)}⊆D + appropriate Zorn extension.

## Recommended Approach

### Step 1: Prove BX analog of Xu's Lemma 2.3

**Theorem**: If BurgessR3Maximal(A,B,C), then:
- (a) P(α) ∈ B for every α∈A [i.e., some_past(α)∈B or equivalently snce(⊤,α)∈B]
- (b) F(γ) ∈ B for every γ∈C [i.e., some_future(γ)∈B or equivalently untl(⊤,γ)∈B]

**Proof sketch for (b)**: Suppose F(γ)∉B for some γ∈C. By maximality: ∃β₀∈B, γ₀∈C such that ¬untl(β₀∧F(γ), γ₀)∈A. From burgessR3: untl(β₀,γ₀)∈A. By BX5: untl(β₀∧untl(β₀,γ₀), γ₀)∈A.

We need: ⊢ β₀∧untl(β₀,γ₀) → β₀∧F(γ). This requires ⊢ untl(β₀,γ₀) → F(γ). By BX10: untl(β₀,γ₀)→F(γ₀). If γ₀=γ this works. But γ₀ is chosen from the maximality witness, not necessarily equal to γ.

**Fix**: The maximality witness ∃β₀∈B, γ₀∈C is for the formula β₀∧F(γ) failing to extend B while maintaining burgessR3. Use γ₀ = γ: if untl(β₀∧F(γ), γ)∉A for some β₀∈B... Actually the maximality gives ∃β₀, γ₀ such that r(A, β₀∧F(γ), C) fails, meaning ∃γ₀∈C: untl(β₀∧F(γ), γ₀)∉A.

So we have untl(β₀, γ₀)∈A (from burgessR3 with β₀∈B, γ₀∈C) and ¬untl(β₀∧F(γ), γ₀)∈A.

By BX2 contrapositive (similar to left_mono_contrapositive): if ⊢ β₀→β₀∧F(γ) then ⊢ untl(β₀,γ₀)→untl(β₀∧F(γ),γ₀). But ⊢ β₀→β₀∧F(γ) requires ⊢ β₀→F(γ), which doesn't hold in general.

So left_mono doesn't immediately apply. We need: ¬(β₀→β₀∧F(γ))∈A or ¬G(β₀→β₀∧F(γ))∈A. By `left_mono_contrapositive_neg_delta` with delta=F(γ): ¬F(γ)∈A or F(¬F(γ))∈A, i.e., G(¬γ)∈A or F(G(¬γ))∈A. But γ∈C and C is consistent, so γ is consistent, meaning ¬γ is not a theorem. But G(¬γ)∈A doesn't mean ¬γ is a theorem — it means γ is always false in the future (from A's perspective). This could hold.

**But**: We have untl(β₀,γ₀)∈A. By BX10: F(γ₀)∈A. If γ₀=γ, then F(γ)∈A, contradicting G(¬γ)∈A. If γ₀≠γ but γ∈C and γ₀∈C: from burgessR3, untl(β₀,γ)∈A (take any β₀∈B). So F(γ)∈A. And from the left_mono contrapositive with untl(β₀,γ₀) and ¬untl(β₀∧F(γ),γ₀): ¬F(γ)∈A or F(¬F(γ))∈A.

Case ¬F(γ)∈A = G(¬γ)∈A: contradicts F(γ)∈A since A is MCS. **Contradiction!**

Case F(¬F(γ)) = F(G(¬γ))∈A: we also have F(γ)∈A. So F(G(¬γ))∈A and F(γ)∈A simultaneously. By BX11 (temporal linearity): F(G(¬γ)∧γ) ∨ F(G(¬γ)∧F(γ)) ∨ F(F(G(¬γ))∧γ). 

The first disjunct: G(¬γ)∧γ is inconsistent (G(¬γ)→¬F(γ)→... wait, G(¬γ) at a point says all future points have ¬γ. But γ holds at the same point? G(¬γ) is about the future, γ is about the current point. Under strict semantics, G(φ) means ∀s>t, φ(s). So G(¬γ) at s means ¬γ at all points after s. γ at s is fine. So G(¬γ)∧γ is consistent at a point. This doesn't lead to contradiction.

This is getting very complicated. Let me try a cleaner approach.

**Cleaner proof of F(γ)∈B**:

From burgessR3(A,B,C) and γ∈C: untl(β,γ)∈A for all β∈B (by definition). In particular, untl(⊤,γ)∈A where ⊤∈B (since B is DCS, ⊤=⊥→⊥ is a theorem in B). Wait, is ⊤∈B? B is a DCS, and ⊤ is a theorem, so yes, ⊤∈B.

So untl(⊤,γ)∈A. By BX12 equivalence (inverse): untl(⊤,γ) → F(γ) (by BX10). So F(γ)∈A.

Now: suppose F(γ)∉B. B is a DCS with ⊤∈B. By maximality of B: ∃β₀∈B, γ₀∈C such that ¬untl(β₀∧F(γ), γ₀)∈A (Since-side similar).

From burgessR3: untl(β₀,γ₀)∈A. 

By left_mono_contrapositive_neg_delta with β=β₀, γ=γ₀, delta=F(γ): since untl(β₀,γ₀)∈A and ¬untl(β₀∧F(γ),γ₀)∈A, we get: ¬F(γ)∈A or F(¬F(γ))∈A.

But we proved F(γ)∈A above. So ¬F(γ)∈A is impossible (A is MCS: can't have both F(γ) and ¬F(γ)).

So F(¬F(γ))∈A. I.e., F(G(¬γ))∈A. Combined with F(γ)∈A...

Actually, we also need the Since-side. The Since-side witness: ∃β₁∈B, α₁∈A such that ¬snce(β₁∧F(γ), α₁)∈C. Similarly, from burgessR3: snce(β₁,α₁)∈C. By left_mono_contrapositive for Since: ¬F(γ)∈C or P(¬F(γ))∈C.

If ¬F(γ)∈C: then G(¬γ)∈C. But γ∈C and C is MCS, so γ∈C. G(¬γ)∈C and γ∈C is perfectly consistent (G is about the future, γ about now). Hmm.

Actually wait: G(¬γ)∈C means ¬F(γ)∈C (since F(γ) = ¬G(¬γ)). If F(γ)∈C, then G(¬γ)∉C. If G(¬γ)∈C, then F(γ)∉C. Is F(γ) necessarily in C? From C being an MCS and γ∈C: does γ∈C imply F(γ)∈C? Only with the axiom `γ → F(γ)` (reflexivity of future), but under strict semantics, F(γ) means ∃s>t, γ(s), which doesn't follow from γ(t).

So G(¬γ)∈C is compatible with γ∈C under strict semantics! γ holds now but never again.

**This means the proof of F(γ)∈B FAILS for this approach.** The maximality argument doesn't lead to contradiction because the Since-side can have G(¬γ)∈C consistently.

### CONCLUSION

After extremely thorough analysis, the D₀ consistency proof is genuinely difficult under strict semantics because:

1. A3a and A4a are invalid and have no direct BX replacements
2. Xu's Lemma 2.3 (P/F content in B) depends on A3a
3. The "mixed A/C problem" is real under strict semantics
4. BX axiom chains can enrich Until events with P(α) but not with snce(β,α) directly

**The mathematically correct long-term solution should consider**:

**Option 1**: Add a specialized BX axiom that replaces A3a for the specific use case of D₀ consistency. For example: `α ∧ untl(β,γ) → F(γ ∧ P(α))` (valid under strict semantics, gives F(γ∧P(α))∈A which enriches the "observable content" of the interval). This doesn't directly give ζ consistency but changes the proof structure.

**Option 2**: Restructure the chronicle construction to avoid the D₀ seed entirely, using a Xu-like approach with the simpler seed {¬δ}∪B and different lemmas for the burgessR3 conditions.

**Option 3**: Adopt a different completeness proof technique (e.g., mosaic method, step-by-step construction from Verbrugge 2004, or Reynolds 1992's IRR-free axiomatization).

## Evidence/Examples

- Burgess 1982 Lemma 2.6: Full proof traced and translated to our convention
- A3a invalidity: Until guard covers [t,s) but Since guard covers (s',s], so β(s) not guaranteed
- BX event enrichment: untl(β,γ) + G(P(α)) → untl(β, γ∧P(α)) via BX3+BX4 — proven syntactically
- Xu Lemma 2.3: Proof depends on A3a (axiom (3) in Xu's paper), invalid under strict semantics
- left_mono_contrapositive_neg_delta: Correctly derives ¬δ∈A∨F(¬δ)∈A but insufficient alone

## Confidence Level

**HIGH** confidence in the analysis of why existing approaches fail.
**MEDIUM** confidence in the recommended paths forward — Options 1-3 each have open questions that require further investigation.
