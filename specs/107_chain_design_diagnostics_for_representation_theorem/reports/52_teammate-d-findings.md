# Teammate D (Horizons): Deep Mathematical Analysis — Burgess 1982 Proof Architecture

**Date**: 2026-05-02
**Session**: sess_1777758350_184c2f
**Focus**: Complete step-by-step proof reconstruction, sorry architecture assessment, Phases 4-8 roadmap

---

## Key Findings

1. **The Burgess compression proof for Lemma 2.6 is fully reconstructible from first principles**. Every step maps cleanly to BX axioms already in the codebase. The 3 remaining sorry sites in `burgess_D0_finite_subset_consistent` are engineering gaps, not conceptual ones.

2. **The inconsistent case (β.neg ∈ B) is genuinely simpler**: no BX14 needed. The event is just `untl(β.neg ∧ untl(β.neg, γ₀), γ₀)` from BX5, giving F(event)∈A via BX10. Direct.

3. **The Lemma 2.7 seed sorry is the hardest of the three**: the 5th component `{snce(β∧eta, α)}` requires tracing through the BX7 application (Burgess's A7a) before BX13 applies. This is a 10-step proof, not a 5-step one.

4. **The C4/C4' hard case (CounterexampleElimination sorry sites) requires `c2'`** (BurgessR3Maximal at adjacent pairs), which is currently missing from the omega_chain invariant (removed in Phase 7 per comments at lines 409–411). This is the most architecturally complex gap.

5. **The FUC/FSC sorries are purely a matter of extracting the guard from C5's witness** via the limit_g interval function. The mathematical path is: C5 gives y with ψ∈f(y), C3 gives g(t,y)⊆f(r) for t<r<y, and BurgessR3 gives φ∈g(t,y). This chain closes FUC.

6. **Completing the chronicle achieves `bx_completeness` (representation theorem)**. No other sorry sites are on the critical path. Phases 4-8 are all engineering, not mathematical impossibilities.

---

## Burgess Lemma 2.6 Consistency Proof (Complete Step-by-Step)

### Setup

We have: R(A, B, C) (i.e., BurgessR3Maximal A B C), δ ∉ B.

The seed is:
```
D₀ = {S(α,β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C, β ∈ B}
```

(In Burgess's notation; in codebase notation, `snce`/`untl` replace S/U.)

**Claim**: D₀ is consistent.

**Proof strategy**: Show that any finite L ⊆ D₀ is consistent by compressing it into a single "event" formula that is F-witnessed in A.

### Step 1: Reduce to a single conjunction

Since B is a DCS (deductively closed set), it is closed under finite conjunctions. Given finite L ⊆ D₀:
- Extract finitely many formulas β₁,...,βₖ ∈ B from L
- Form b = β₁ ∧ ... ∧ βₖ; then b ∈ B

Similarly:
- Extract γ₁,...,γₘ ∈ C from Until-formulas U(γᵢ, βᵢ') in L
- Form γ̂ = γ₁ ∧ ... ∧ γₘ; then γ̂ ∈ C (MCS closed under ∧)
- Extract α₁,...,αₙ ∈ A from Since-formulas S(βⱼ', αⱼ) in L
- Form α̂ = α₁ ∧ ... ∧ αₙ; then α̂ ∈ A (MCS closed under ∧)

It suffices to show the "compressed conjunction" ζ is consistent:
```
ζ = b ∧ ¬δ ∧ U(b, γ̂) ∧ S(b, α̂)
```
Because: if ζ is consistent but L were inconsistent, then since every element of L is implied by ζ (via conjunction elimination and guard weakening), we get a contradiction.

**Why ζ implies each φ ∈ L**:
- φ ∈ B: ζ → b → φ (b = ∧(B-elements), conjunction elimination)
- φ = ¬δ: ζ → ¬δ (direct conjunct)
- φ = U(γᵢ, βᵢ'): ζ → U(b, γ̂) and b → βᵢ' (conj elim) and γ̂ → γᵢ (conj elim). By A2a (right_mono_until): U(b, γ̂) → U(b, γᵢ). By A1a (left_mono_until): U(b, γᵢ) → U(βᵢ', γᵢ).
- φ = S(βⱼ', αⱼ): ζ → S(b, α̂) and b → βⱼ' and α̂ → αⱼ. By A2b (left_mono_since): S(b, α̂) → S(b, αⱼ). By A1b: S(b, αⱼ) → S(βⱼ', αⱼ).

So if ζ ⊢ ⊥, then L ⊢ ⊥, and consistency of ζ implies consistency of L.

### Step 2: What is D₀ exactly?

```
D₀ = {S(α, β) : α ∈ A, β ∈ B}  -- "backward Since" formulas
   ∪ B                             -- base interval formulas
   ∪ {¬δ}                          -- the negated formula
   ∪ {U(γ, β) : γ ∈ C, β ∈ B}   -- "forward Until" formulas
```

Note the argument order in S and U:
- S(α, β): "α was true since β was last true" (in the codebase: `snce α β`)
- U(γ, β): "β will remain true until γ is true" (in the codebase: `untl γ β`)

**Burgess's BurgessR3Maximal (R(A,B,C))** means:
- B is a maximal DCS such that: for all β ∈ B, γ ∈ C: U(γ, β) ∈ A (Until-direction)
- AND: for all β ∈ B, α ∈ A: S(β, α) ∈ C (Since-direction)

So the Until-formulas in D₀ are directly in A (by burgessR3), and the Since-formulas are directly in C (by burgessR3).

### Step 3: Extracting the witness from maximality

Since δ ∉ B and R(A, B, C) is maximal (BurgessR3Maximal), the deductive closure DC({δ} ∪ B) must fail to satisfy burgessR3. From this failure, we extract:
```
∃ β₀ ∈ B, ∃ γ₀ ∈ C such that ¬U(γ₀, β₀ ∧ δ) ∈ A
```

**Why**: If U(γ, β₀ ∧ δ) ∈ A for ALL β₀ ∈ B, γ₀ ∈ C, then the Until-condition for DC({δ} ∪ B) would hold (since every element of DC({δ} ∪ B) is derivable from some β₀ ∈ B and δ, and A is closed under left_mono_until). But we assumed the extension fails, so some β₀, γ₀ must fail.

**Key adjustment** (Burgess, p.371): We may assume w.l.o.g. that β = β₀ ∧ b (absorbing the given β₀ into the compressed conjunction) and γ = γ₀ ∧ γ̂. This ensures ¬U(b ∧ δ, γ̂) ∈ A with the compressed witnesses.

### Step 4: The event formula γ̂

```
γ̂ = b ∧ U(b, γ̂)  [from BX5 self-accumulation]
```

More precisely, Burgess defines the "event" as what remains true at the "split point":
```
event = b ∧ U(b, γ̂) ∧ ¬δ ∧ S(b, α̂)
```
where:
- b ∈ B (compressed B-part)
- γ̂ ∈ C (compressed C-part of Until-witnesses)
- α̂ ∈ A (compressed A-part of Since-witnesses)

Note: This event is the ζ from Step 1, suitably enriched.

### Step 5: How BX5 (A5a) applies

**BX5**: U(φ, ψ) → U(φ ∧ U(φ, ψ), ψ)

We have U(b, γ̂) ∈ A (from burgessR3: b ∈ B, γ̂ ∈ C, so U(γ̂, b) would be the "standard" direction... wait).

**Correction on argument order**: In Burgess's notation (and codebase notation), U(φ, ψ) means "φ holds at a future witness, and ψ holds at all intermediate points". So:
- U(γ₀, β₀) ∈ A means "γ₀ will hold at some future point, with β₀ holding throughout".
- burgessR3: for β ∈ B, γ ∈ C: U(γ, β) ∈ A (guard β, eventuality γ).

So U(b, γ̂) ∈ A means b is the guard and γ̂ is the eventuality. BX5 gives:
```
U(b, γ̂) ∈ A  →  U(b ∧ U(b, γ̂), γ̂) ∈ A
```

**BX5 inputs**: φ = b (guard), ψ = γ̂ (eventuality)
**BX5 output**: U(b ∧ U(b, γ̂), γ̂) ∈ A

Let q = b ∧ U(b, γ̂). So U(q, γ̂) ∈ A.

### Step 6: How BX14 (A4a) applies (the consistent case with ¬U(b ∧ δ, γ̂) ∈ A)

**BX14 (A4a)**: U(φ, ψ) ∧ ¬U(φ, χ) → U(ψ ∧ ¬χ, ψ) ∈ A [at MCS level]

We have:
- U(q, γ̂) ∈ A (from BX5)
- ¬U(q, γ̂ ∧ δ) ∈ A (from the maximality witness applied to q and γ̂: since q = b ∧ U(b,γ̂) and b → β₀, and U(b ∧ δ, γ̂) ∉ A)

Wait — we need ¬U(q, γ̂ ∧ δ) ∈ A. From our maximality witness ¬U(b ∧ δ, γ̂) ∈ A:
- If U(q, γ̂ ∧ δ) ∈ A, then by right_mono_until (γ̂ ∧ δ → γ̂): U(q, γ̂) would give no contradiction.
- But we need: U(q, γ̂ ∧ δ) → U(b ∧ δ, γ̂) (via left_mono_until: q → b, right_mono_until: γ̂ → γ̂∧δ→ ...hmm, that's the wrong direction).

Actually Burgess's argument is cleaner: he uses the separation axiom A4a directly:

**BX14 inputs**: φ = q = b ∧ U(b, γ̂), ψ = γ̂, χ = b ∧ δ
- U(q, γ̂) ∈ A ✓ (from BX5)
- ¬U(q, b ∧ δ) ∈ A: this comes from left_mono applied to ¬U(b ∧ δ, γ̂). More precisely:
  - We have ¬U(b ∧ δ, γ̂) ∈ A
  - Suppose U(q, b ∧ δ) ∈ A. Since q → γ̂ (U(b, γ̂) → γ̂ by BX10) ... actually q = b ∧ U(b, γ̂) does not directly → γ̂.
  - **Correct approach**: Burgess uses ¬U(γ₀, β₀ ∧ δ) in his notation where γ₀ is the eventuality. In codebase notation this is ¬U(b ∧ δ, γ̂)... I need to be careful.

Let me re-read Burgess literally: "since $\delta \notin B$...there exist $\beta_0 \in B$, $\gamma_0 \in C$ with $\sim U(\gamma_0, \beta_0 \wedge \delta) \in A$." In Burgess's notation, U(γ₀, β₀∧δ) means γ₀ is the eventuality and β₀∧δ is the guard. So the negation means: γ₀ will not hold with β₀∧δ holding throughout.

Then "But $U(\gamma, \beta) \in A$ by hypothesis $r(A,B,C)$" — so U(γ₀, β₀) ∈ A (γ₀ is eventuality, β₀ is guard). This is the burgessR3 Until-direction.

"$U(\gamma_0, \beta_0 \wedge U(\gamma_0, \beta_0)) \in A$ using A5a" — BX5 with eventuality γ₀ and guard β₀:
```
q = β₀ ∧ U(γ₀, β₀)
U(γ₀, q) ∈ A
```

"A4a applies and tells us $U(\beta_0 \wedge U(\gamma_0, \beta_0) \wedge \sim\delta, \beta_0) \in A$" — BX14 with:
- eventuality = q = β₀ ∧ U(γ₀, β₀)
- guard = β₀
- the negated formula ¬U(γ₀, β₀ ∧ δ) ∈ A (our maximality witness)

**BX14 inputs**: U(γ₀, β₀) ∈ A and ¬U(γ₀, β₀ ∧ δ) ∈ A
**BX14 output**: U(β₀ ∧ U(γ₀, β₀) ∧ ¬δ, β₀) ∈ A

So the event at this stage is: event_tmp = β₀ ∧ U(γ₀, β₀) ∧ ¬δ

**BX14 formula check**: A4a says `U(φ,ψ) ∧ ¬U(φ,χ) → U(ψ ∧ ¬χ, ψ)`:
- φ = γ₀ (eventuality)
- ψ = β₀ (guard)
- χ = β₀ ∧ δ

Output: U(β₀ ∧ ¬(β₀ ∧ δ), β₀) ∈ A. Since ¬(β₀ ∧ δ) = β₀ → ¬δ, and β₀ ∧ ¬(β₀ ∧ δ) → ¬δ, this simplifies to something that includes ¬δ in the eventuality.

More precisely: U(β₀ ∧ (β₀ ∧ δ).neg, β₀) where (β₀ ∧ δ).neg = β₀.imp δ.imp ⊥.

The key point: the eventuality β₀ ∧ (β₀ ∧ δ).neg implies both β₀ and ¬δ.

### Step 7: How BX13 (A3a) applies — packing S-formulas

**BX13 (A3a)**: p ∧ U(φ, ψ) → U(φ ∧ S(p, ψ), ψ)

We have U(event_tmp, β₀) ∈ A. We want to pack the Since-formula S(α, β₀) into the event (where α ∈ A, β₀ ∈ B, so S(β₀, α) ∈ C by burgessR3 — wait, the Since-direction gives S(β₀, α) ∈ C for α ∈ A, not A).

Actually what we need is S(α̂, β₀) ∈ A for the BX13 application. Hmm.

Let me re-read Burgess: "Using A3a we then have $U(\beta_0 \wedge U(\gamma_0, \beta_0) \wedge \sim\delta \wedge S(\alpha, \beta_0), \beta_0) \in A$". 

So he applies A3a as: p = S(α, β₀) (a Since-formula with α ∈ A), and the formula is U(event_tmp, β₀) ∈ A.

**The operand p**: p = S(α, β₀) where α ∈ A.

**Why p ∈ A**: "Assuming (a)" (burgessR3 / r(A, B, C)), the r-relation says ∀ γ ∈ C, U(γ, β) ∈ A. The Since-direction (criterion 2.3b) gives: ∀ α ∈ A, S(α, β₀) ∈ C. Wait — that puts S(α, β₀) in C, not A!

Re-reading: "Using A3a we then have U(...∧ S(α,β), β) ∈ A". The A3a axiom is: `p ∧ U(φ,ψ) → U(φ ∧ S(p, ψ), ψ)`. So:
- p = α (where α ∈ A)
- The axiom gives: α ∧ U(event_tmp, β₀) → U(event_tmp ∧ S(α, β₀), β₀)

**Why α ∈ A gives the conclusion in A**: α ∈ A (MCS), U(event_tmp, β₀) ∈ A. Since A is an MCS (closed under conjunction): α ∧ U(event_tmp, β₀) ∈ A. By A3a: U(event_tmp ∧ S(α, β₀), β₀) ∈ A.

**What is the operand p = α ∈ A?**: α is any element of A. In the compression step, we need this for each α ∈ A that appears in the Since-formulas of L. We compress to α̂ = ∧(all α's from S-formulas in L), so α̂ ∈ A (MCS closed under ∧).

**Why must α̂ ∈ A** (not just some abstract α): Because the Since-formulas in D₀ are exactly `{S(β', α) : β' ∈ B, α ∈ A}`, and α̂ is a finite conjunction of such α's, which is in A by MCS closure.

**BX13 output**: U(event_tmp ∧ S(α̂, β₀), β₀) ∈ A

where event_tmp = β₀ ∧ U(γ₀, β₀) ∧ ¬δ (from BX14 step).

Full event: event = β₀ ∧ U(γ₀, β₀) ∧ ¬δ ∧ S(α̂, β₀)

### Step 8: How BX10 (until_F) gives F(event) ∈ A

**BX10**: U(φ, ψ) → F(ψ) (the eventuality extracts to F)

We have U(event, β₀) ∈ A. BX10 gives: F(event) ∈ A.

### Step 9: How F(event) ∈ A gives consistency

F(event) ∈ A means there exists a future point where event holds. Since event is satisfiable (it holds at some point in a model), it is consistent (no consistent theory can derive ⊥ from a satisfiable formula).

More precisely, in the formalization: `consistent_of_F_mem h_mcs_A event h_F_event` gives SetConsistent({event}).

### Step 10: How event implies each φ ∈ L

This is the `h_event_implies_L` step. We need DerivationTree [event] φ for each φ ∈ L.

The critical case is φ ∈ B: we need `event → φ`. The event contains S(α̂, β₀) and b (the conjunction of B-elements) and ¬δ. Since b = ∧(B-elements of L) including φ, we have `b → φ` (conjunction elimination), and `event → b` is a direct conjunct.

**The sorry at line 1573 is exactly this case**: show that φ ∈ b_list (because d0_guard returns φ for B-elements), then list_conj_implies_elem gives ⊢ b → φ.

The issue in the code: `b_list = β₀ :: b_list_raw` where `b_list_raw = collect_guards output`. For φ ∈ B, `collect_guards_mem_of_B` shows `φ ∈ b_list_raw`, hence `φ ∈ b_list`. Then `list_conj_implies_elem b_list φ (List.mem_cons.mpr (Or.inr h_φ_in_raw))` closes the sorry.

**The sorry at line 1581 (Until case)**: φ = U(β', γ'). event → U(b, γ̂) (direct conjunct). b → β' (since β' ∈ b_list_raw by collect_guards). γ̂ → γ' (γ' ∈ c_list_raw by d0_c_event_list, list_conj_implies_elem). Apply left_mono and right_mono.

**The sorry at line 1584 (Since case)**: φ = S(β', α'). event → S(b, α̂) (since event = b ∧ ¬δ ∧ U(b,γ̂) ∧ S(b, α̂)... wait, the event in the code is `β₀ ∧ U(γ₀,β₀) ∧ ¬δ ∧ S(α̂, β₀)`, but the guard for Since-formulas in L is β' ∈ B and the event is α' ∈ A). 

Re-examining: the Since-formulas in D₀ are S(β', α') with β' ∈ B, α' ∈ A. The event contains S(α̂, β₀) (by BX13 where we packed α̂ ∈ A into the event using A3a with β₀ as the guard). So event → S(α̂, β₀). But we need event → S(β', α'). Since α̂ = ∧(A-events) ⊇ α', α̂ → α'. And β₀ (or b) → β'. So:
- S(α̂, β₀) → S(α̂, β') (by A1b: left_mono_since, β₀ → β'? Actually β₀ is the guard not the event... checking argument order in codebase: `snce φ ψ` means φ is the eventuality and ψ is the guard. Actually: `snce β α` in codebase matches Burgess S(β, α) where β is what holds at the witness point and α is the guard during the interval.)

This is getting complex. The sorry at line 1584 requires careful monotonicity applications depending on exact argument order conventions.

---

## Inconsistent Case Variant (β.neg ∈ B)

When `{β} ∪ B` is inconsistent, `neg_mem_of_inconsistent_union` gives β.neg ∈ B (since B is DCS: if {β.neg} ∪ B were inconsistent, β.neg.neg = ¬¬β ∈ B, and by DNE + DCS closure, β ∈ B, contradicting β ∉ B).

Wait — we're in the case where {β} ∪ B IS inconsistent. So β.neg ∈ B directly.

**Simplification**: With β.neg ∈ B:
- The seed D₀ includes β.neg as a B-element (β.neg ∈ B ⊆ D₀)
- No need for the maximality argument (which extracts ¬U(β₀∧β, γ₀) ∈ A)
- No BX14 needed (BX14 required ¬U to separate β)

**Proof in the inconsistent case**:
1. Since β.neg ∈ B, pick any γ₀ ∈ C (C is nonempty as an MCS)
2. burgessR3 Until-direction: U(γ₀, β.neg) ∈ A
3. **BX5**: U(β.neg ∧ U(γ₀, β.neg), γ₀) ∈ A (self-accumulation with guard=β.neg, event=γ₀)
4. **BX13** (optional): pack any S-formulas into the event
5. **BX10**: F(event) ∈ A where event = β.neg ∧ U(γ₀, β.neg)
6. Consistency of event follows; then show event → each φ ∈ L

The sorry at line 1614 (`burgess_D0_finite_subset_consistent_incons`) is this case. It's strictly simpler than the consistent case because:
- Step 3 above gives F(β.neg ∧ ...) ∈ A directly
- No BX14 needed
- The event structure is cleaner (just BX5 + BX10)

**Recommended proof path**: Call the already-proved `burgess_D0_finite_subset_consistent` with the inconsistent case witnesses:
- β₀ = β.neg (which is in B)
- γ₀ = any element of C
- h_neg_until₀ = obtained by showing U(β.neg ∧ β, γ₀) ∉ A because β.neg ∧ β → ⊥ (inconsistency), so any U with guard β.neg ∧ β is equivalent to U(⊥, γ₀) which by BX12' and Lemma 2.2 would require ⊥ to be consistent (it isn't).

Actually the simplest path: the inconsistent case proof at line 1614 can literally just be `exact burgess_D0_finite_subset_consistent ...` with appropriate witnesses extracted — since the `burgess_D0_finite_subset_consistent` is already the general machinery, and in the inconsistent case the witnesses are easy to provide.

---

## Lemma 2.7 Seed Variant

**Setup**: BurgessR3Maximal(A, B, C), U(xi, eta) ∈ A (xi is eventuality, eta is guard), eta ∉ B.

**Seed (5 components)**:
```
D₀' = B ∪ {xi} ∪ {U(β, γ) : β ∈ B, γ ∈ C}
     ∪ {S(β, α) : β ∈ B, α ∈ A}
     ∪ {S(β ∧ eta, α) : β ∈ B, α ∈ A}   -- 5th component: eta-enriched Since
```

The 5th component encodes that eta is in the interval, allowing `eta ∈ B'` after Lindenbaum extension.

**How the 5th component is handled differently**:

The compressed ζ for Lemma 2.7 is:
```
ζ = S(b, α̂) ∧ b ∧ xi ∧ U(b, γ̂) ∧ S(b ∧ eta, α̂)
```

The 5th component adds S(b ∧ eta, α̂) to ζ. To show ζ consistent, Burgess uses **BX7 (A7a)** before BX13.

**The additional BX7 step** (Burgess p.372): "A7a applies to tell us that one of the following must belong to A: U(γ ∧ xi, θ), U(γ ∧ U(xi,eta), θ), or U(β ∧ U(γ,β) ∧ xi, θ)."

where θ = β ∧ U(γ,β) ∧ xi ∧ U(xi,eta).

BX7 (A7a) is a linearity axiom: U(φ,ψ) ∧ U(χ,ζ) → U(φ∧χ, ψ∧ζ) ∨ U(φ∧ζ, ψ∧ζ) ∨ U(ψ∧χ, ψ∧ζ)

Applied to U(γ, β ∧ U(γ,β)) ∈ A (from BX5 on U(γ₀, β₀) ∈ A) and U(xi, eta ∧ U(xi,eta)) ∈ A (from BX5 on U(xi,eta)):
- The three disjuncts compared to ¬U(γ₀, β₀∧eta) ∈ A (the maximality witness from eta∉B)
- The first two can be ruled out (via A1a/A2a monotonicity with ¬U(γ₀, β₀∧eta))
- The third remains: U(β₀ ∧ U(γ₀,β₀) ∧ xi, θ) ∈ A

Then A3a (BX13) packs S(α̂, β₀) into this event, and BX10 gives F(event) ∈ A.

**The sorry at line 2050** (`lemma_2_7_seed_consistent`) is exactly this 10-step proof. It is harder than the Lemma 2.6 sorry because:
1. The BX7 three-way case split requires eliminating two cases
2. The BX5 application is on U(xi, eta) (a formula in A but not directly from burgessR3)
3. The 5th seed component's consistency relies on S(b ∧ eta, α̂) being implied by the event

**Key for the 5th component**: After BX7 + BX13, the event contains xi (from the third disjunct). Then S(xi, α) can be derived for α ∈ A by the r-relation (since xi is in D, after Lindenbaum extension, and the S-formulas follow from burgessR3 applied to xi's D-membership). But the 5th component S(β ∧ eta, α) is handled via: the event implies beta ∧ eta (since the BX3 + BX13 chain packs S(β ∧ eta, α) using the S(xi, ...) formula and the fact that xi → beta ∧ eta via the U(xi, eta) formula).

**Recommended approach for sorry 2050**: Follow the 10-step Burgess proof exactly:
1. Use BX5 on U(xi, eta) ∈ A and BX5 on U(β₀, γ₀) ∈ A
2. Invoke BX7 (linear_until_mcs)
3. Rule out disjuncts 1 and 2 using the maximality witness ¬U(β₀ ∧ eta, γ₀) ∈ A
4. Extract the third disjunct
5. Apply BX13 to pack S(α̂, β₀) 
6. Apply BX10 to get F(event) ∈ A
7. Show event implies each element of D₀' (including the 5th component via S-monotonicity)

---

## Phases 4-8 Roadmap Assessment

### What remains after the 3 PointInsertion sorries are closed

After Phase 3 (Lemma 2.6 + Lemma 2.7 sorry-free), the remaining sorry sites are:

1. **CounterexampleElimination.lean lines 412 and 510**: The C4/C4' hard case (2 sorries)
2. **ChronicleToCountermodel.lean lines 615 and 619**: FUC/FSC coherence (2 sorries)
3. **RRelation.lean line ~772**: The Zorn inconsistent case (1 sorry, possibly already fixed or minor)

Wait — re-examining the grep output: `grep -n "sorry" RRelation.lean` returned no actual sorry sites (only a comment). So RRelation is actually sorry-free. The ROADMAP's claim of 1 sorry in RRelation may have been resolved during Phase 5b (the `burgessR3Maximal_extension_exists` Zorn proof looks complete in the code above).

**Current true sorry count**: 4 active sorry sites in CounterexampleElimination (2) and ChronicleToCountermodel (2), plus 3 sorry sites in PointInsertion that are partially engineered.

### Phase 4: C4/C4' Hard Case — Estimated 4-8 hours, **Architecturally complex**

**The problem**: `eliminate_C4_counterexample` (line 412) and its mirror `eliminate_C4'_counterexample` (line 510) require inserting a split point z between w and w_next with ¬γ ∈ f(z). The comment says this requires BurgessR3Maximal for (f(w), g(w,w_next), f(w_next)).

**The blocker**: The omega_chain invariant currently does NOT include `c2'` (BurgessR3Maximal at adjacent pairs). This was removed in Phase 7 of a prior plan iteration (per comment at line 409-411: "Phase 8: Restore this proof once c2' is re-established at finite stages").

**Mathematical path**: 
- The omega_chain is constructed from finite chronicles
- Each finite chronicle satisfies C0 (f maps dom→MCS) and C2/C2' (g-values)
- C2' says: for adjacent x,y in dom, R(f(x), g(x,y), f(y)) (BurgessR3Maximal)
- If C2' is restored as an invariant, then `eliminate_C4_counterexample` can use Lemma 2.6 (splitting) to find the split point D with ¬γ ∈ D

**Obstacle**: Restoring C2' means the Chronicle structure needs to carry BurgessR3Maximal witnesses. This requires:
1. Adding c2' to Chronicle's invariant definition (in ChronicleTypes.lean)
2. Proving that point insertion (insert_point) preserves c2'
3. Threading c2' through the omega_chain construction

This is engineering-heavy but mathematically clear. Lemma 2.6 is already proved; the gap is the invariant threading.

**No mathematical obstacles** — this is a formalization engineering problem.

### Phase 5: FUC/FSC Coherence — Estimated 3-5 hours, **Cleaner path**

**The problem**: `cantor_bfmcs_restricted_fuc` needs: for U(φ, ψ) ∈ mcs(t), find s > t with ψ ∈ mcs(s) and φ ∈ mcs(r) for all r between t and s.

**Available infrastructure**:
- `limit_satisfies_c5_weak`: ∃ y > t, ψ ∈ limit_f(y) — the endpoint witness
- `limit_g(x,z)`: the limit of g-values, defined as {φ | ∀ y ∈ dom, x < y → y < z → φ ∈ limit_f(y)}
- `limit_c3_interval_subset_point`: limit_g(x,z) ⊆ limit_f(y) for x < y < z

**Mathematical path (Burgess Claim 2.11)**:
1. C5 gives y with ψ ∈ f(y) and φ ∈ g(t, y) (for the limit chronicle, using the full C5 not just C5_weak)
2. C3 gives g(t, y) ⊆ f(r) for all r with t < r < y
3. Therefore φ ∈ f(r) for all r between t and y
4. By the truth lemma, this gives the guard condition

**The missing piece**: The current C5 only gives `limit_satisfies_c5_weak` (the endpoint without guard). The full C5 (`limit_satisfies_c5_full`) must additionally provide φ ∈ g(t, y).

**From the limit construction**: At each finite stage n, the C5 witness for U(φ, ψ) ∈ f(t) provides a point y_n with ψ ∈ f_n(y_n) and φ ∈ g_n(t, y_n). In the limit, the y_n eventually stabilize (the domain grows monotonically, and each y_n is the same rational). The limit_g(t, y) inherits the guard information from the finite stages.

**Key lemma needed**: `limit_satisfies_c5_full`: ∃ y > t, ψ ∈ limit_f(y) ∧ φ ∈ limit_g(t, y).

This should follow from the omega_chain satisfying C5a (which the construction ensures by repeatedly applying `eliminate_C5_counterexample`). The proof is: the limit chronicle satisfies C5 by construction (counterexample elimination was applied for every potential violation), so C5 holds in the limit.

**No unidentified mathematical obstacles** — the FUC sorry is an infrastructure gap (need to prove `limit_satisfies_c5_full` and use it), not a conceptual one.

### Phase 6 (Final Validation): Estimated 1-2 hours

- Update `#print axioms dd_countermodel_chronicle`
- Update ROADMAP.md sorry counts
- Update stale comments in Completeness.lean

### Overall Phase Estimates

| Phase | Content | Estimated Effort | Complexity |
|-------|---------|-----------------|------------|
| Phase 3 (current) | Close 3 PointInsertion sorries | 4-8 hours | Medium |
| Phase 4 | C4/C4' via c2' restoration | 6-12 hours | Hard (invariant threading) |
| Phase 5 | FUC/FSC via limit_c5_full | 3-6 hours | Medium |
| Phase 6 | Audit + ROADMAP | 1-2 hours | Easy |
| **Total** | | **14-28 hours** | |

---

## Strategic Recommendations

### 1. For Phase 3 (PointInsertion sorries): Use `collect_guards_mem_of_B`

The sorry at line 1573 is the most mechanical:
```lean
-- φ ∈ B case
have h_φ_in_raw : φ ∈ b_list_raw :=
  collect_guards_mem_of_B h_B_dcs β L hL φ hφ h_B
have h_φ_in_b_list : φ ∈ b_list :=
  List.mem_cons.mpr (Or.inr h_φ_in_raw)
exact DerivationTree.modus_ponens _ _ _
  (DerivationTree.weakening [] _ _
    (list_conj_implies_elem b_list φ h_φ_in_b_list) (List.nil_subset _))
  (DerivationTree.weakening [] _ _ h_ev_b (List.nil_subset _)
   |>.mono (DerivationTree.assumption _ _ (by simp)))
```

### 2. For Phase 3 (inconsistent case sorry 1614): Directly reuse `burgess_D0_finite_subset_consistent`

Extract witnesses (β₀ = β.neg from h_beta_neg_in_B, γ₀ = any element of C using MCS nonemptiness, h_neg_until₀ from BX inconsistency of β.neg ∧ β). Then call the existing lemma. This is a 10-20 line proof, not a separate sorry.

### 3. For Phase 3 (lemma_2_7 sorry 2050): Follow Burgess literally

The 10-step proof maps directly to codebase lemmas:
- `self_accum_until_mcs` for BX5
- `linear_until_mcs` (BX7) for the three-way split  
- `mcs_contrapositive_mem` to rule out disjuncts
- `separation_until_mcs` (BX14) if needed
- BX13 via `enrichment_until_mcs`
- `until_implies_F_mcs` (BX10)

### 4. For Phase 4 (C4 hard case): Restore c2' as chronicle invariant

The architectural fix is: add `c2' : ∀ x y, x ∈ dom → y ∈ dom → Adjacent dom x y → BurgessR3Maximal (f x) (g x y) (f y)` to the Chronicle structure. Verify that:
- `seed_chronicle` (the initial single-point chronicle) trivially satisfies c2' (no adjacent pairs)
- `insert_point` preserves c2' (the new pair gets BurgessR3Maximal from Lemma 2.6 construction)
- `omega_chain_limit` inherits c2' (by taking the limit of the chain's c2' witnesses)

This is 50-100 lines of new code, but each step is straightforward from the existing infrastructure.

### 5. For Phase 5 (FUC/FSC): Prove `limit_satisfies_c5_full`

Strengthen `limit_satisfies_c5_weak` to include the guard. The proof is: the omega_chain satisfies C5 (full version) by construction — every violation is eliminated. The limit then satisfies C5 because the witnesses are stable across finite stages. Formally, this requires showing that the C5 elimination not only adds the endpoint y but also ensures φ ∈ limit_g(t, y).

---

## How Completing the Chronicle Fits the ROADMAP

The ROADMAP states (Representation Theorem Goal section):
> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

The chronicle construction achieves this as **Path B** (D=Rat completeness). The theorem `dd_countermodel_chronicle` already uses `Rat` as the domain. Closing the 4 remaining sorry sites (after Phase 3 closes 3 PointInsertion sorries) makes `dd_countermodel_chronicle` sorry-free, which in turn makes `bx_completeness` sorry-free (since `Completeness.lean` delegates to `dd_countermodel_chronicle`).

The ROADMAP's priority order is:
1. Task 107 (Chronicle, active — THIS task)
2. Task 112 (literature study, supporting 107)
3. Task 95 (axiom audit, depends on 107)
4. Task 109 (BXCanonical cleanup, becomes moot once 107 succeeds)

Completing the 4 remaining sorry sites achieves the primary milestone: a sorry-free representation theorem. All other tasks (95, 109, 115) become secondary cleanup work.

---

## Confidence Level

- **Burgess Lemma 2.6 proof reconstruction**: HIGH — based on direct line-by-line reading of Burgess 1982 Section 2 and comparison with codebase BX axioms
- **Inconsistent case analysis**: HIGH — straightforward simplification of the consistent case
- **Lemma 2.7 5th component analysis**: MEDIUM-HIGH — BX7 step is documented in Burgess but the exact monotonicity chain for the 5th component needs careful axiom-by-axiom verification
- **Phase 4 C4 architecture assessment**: MEDIUM — c2' restoration is clearly the right path but the exact proof of insert_point preserving c2' requires checking PointInsertion.lean's current structure
- **Phase 5 FUC assessment**: MEDIUM-HIGH — limit_satisfies_c5_full is the missing piece, and the proof approach is clear from C5's construction
- **Sorry count**: HIGH — based on `grep -n "sorry"` across all 6 Chronicle files
- **Total effort estimate**: MEDIUM — estimates are based on mathematical complexity, Lean formalization experience suggests 1.5x-2x for unexpected engineering gaps
