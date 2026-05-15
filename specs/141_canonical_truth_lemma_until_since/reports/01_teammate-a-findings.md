# Teammate A Research Findings: Task 141 — Until/Since Truth Lemma and ReflexiveCanonical Infrastructure

**Focus**: Primary Implementation Approach — literature-faithful, zero-sorry

---

## Key Findings

### 1. The Eight Sorries Are Not Equally Hard

The 8 sorries divide into three clearly separated groups based on difficulty and dependency:

**Group A — Two mechanical applications (canS5R_symm, reflCanR_linear)**
- `canS5R_symm`: Follows directly from the modal B axiom. Standard S5 canonicity argument.
- `reflCanR_linear`: Follows from BX11 (`temp_linearity`) via a contrapositive argument. Infrastructure is already partially sketched in the sorry's comment.

**Group B — Two intermediate guard conditions (until_forward_mcs, since_forward_mcs)**
- The witness `y` is already constructed (lines 413-417 in TruthLemma.lean); only the guard condition `∀ z, tempR_fwd x z → tempR_fwd z y → ψ₂ ∈ z.val` remains.
- This is where the chain construction (Burgess §2.4, self-accumulation BX5) is needed.
- The `until_F_expansion` theorem already exists at `Theories/Bimodal/Theorems/TemporalDerived.lean:455`.

**Group C — Two contrapositive closures (until_backward_mcs, since_backward_mcs)**
- These are the backward directions: given semantic truth of U(ψ₁,ψ₂), derive U(ψ₁,ψ₂) ∈ x.val.
- The comment in TruthLemma.lean notes these are NOT needed for the chronicle+Reynolds pipeline.
- However, they are needed to close `truth_lemma` sorries 5-6 (lines 548, 563).
- The forward direction of the truth lemma uses `until_forward_mcs`, so the backward lemmas are what drive the remaining truth_lemma sorries.

**Important note**: Items 5-6 (`truth_lemma` Until/Since cases) close automatically IF items 1-4 are resolved AND the backward direction is correctly handled. The existing structure in `truth_lemma` (lines 537-570) already correctly delegates: the backward case calls `until_backward_mcs` which needs separate treatment.

---

### 2. The Until Forward Guard Condition: Burgess §2.4 Approach

Burgess 1982 §2.4 (Lemma 2.4) is the core technique. Translated to the ReflCanDomain setting:

**Burgess's Lemma 2.4**: If U(γ, β) ∈ A, then there exist B, C such that γ ∈ C, β ∈ B, and R(A,B,C) holds, where:
- R(A,B,C) means B is the maximal DCS such that r(A,B,C) holds
- r(A,β,C) means: for all γ ∈ C, U(γ,β) ∈ A

The key insight: the "interval content" B serves as the guard content. The intermediate points z with tempR_fwd x z and tempR_fwd z y are exactly the MCSes M with g_content(x) ⊆ M ⊆ g_content(y). For any such z: since g_content(x) ⊆ z.val and U(ψ₁,ψ₂) ∈ x.val, we can apply BX5 (self_accum_until) repeatedly to show ψ₂ ∈ z.val.

**The concrete Lean argument** for the guard condition in `until_forward_mcs`:

Given: U(ψ₁, ψ₂) ∈ x.val, tempR_fwd x z, tempR_fwd z y, ψ₁ ∈ y.val.

1. From U(ψ₁,ψ₂) ∈ x.val, by BX5 (self_accum_until): U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val
2. Since G(ψ₂ ∧ U(ψ₁,ψ₂)) is derivable from U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val... **wait, this doesn't directly work** because we need to propagate to z, not derive G.

**Revised approach via the BX axiom system**:

The correct approach uses the fact that `U(ψ₁,ψ₂) ∈ x.val` propagates forward via the canonical order:

1. `U(ψ₁,ψ₂) ∈ x.val`
2. By BX5 applied at MCS level: `U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val`
3. By BX10 applied to the above: `F(ψ₁) ∈ x.val` (already used)
4. By `connect_future` (BX4): φ → G(P(φ)). Applied with φ = ψ₂ ∧ U(ψ₁,ψ₂): this is at the MCS x level, so we'd need ψ₂ ∧ U(ψ₁,ψ₂) ∈ x.val. But that's not given.

**The correct approach via the guard content `B`**:

In Burgess's construction, B (the interval content) contains exactly the formulas that hold throughout (x, y). In the canonical model, B = g_content(y) (since y is the witness MCS extending {ψ₁} ∪ g_content(x), so g_content(y) is defined by membership).

The intermediate guard condition becomes: for z with tempR_fwd x z and tempR_fwd z y, we have g_content(x) ⊆ z.val and g_content(z) ⊆ y.val. The formula ψ₂ needs to be shown ∈ z.val.

The right tool is **BX5 (self_accum_until)** instantiated at MCS x: `U(ψ₁,ψ₂) → U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂))`. So `U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val`.

Then: `G(ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val`? No — we need G to be able to propagate this. G only gives us `ψ₂ ∧ U(ψ₁,ψ₂)` at all z with `tempR_fwd x z`.

But `tempR_fwd x z` means `g_content(x) ⊆ z.val`, which means `ψ₂ ∧ U(ψ₁,ψ₂) ∈ g_content(x)` would suffice. This requires `G(ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val`.

**Critical insight**: We cannot derive G(ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val from U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val in general. The two are not equivalent.

**The actual correct standard approach** (from Burgess §2.4 and the codebase's TemporalCoherence.lean):

The guard condition proof requires a **contrapositive Lindenbaum argument**:

Suppose z satisfies tempR_fwd x z and tempR_fwd z y, but ψ₂ ∉ z.val. Then ¬ψ₂ ∈ z.val (negation completeness of z as MCS). We need to derive a contradiction.

Since U(ψ₁,ψ₂) ∈ x.val and tempR_fwd x z (g_content(x) ⊆ z.val): is U(ψ₁,ψ₂) preserved to z? Yes, IF we have `G(U(ψ₁,ψ₂)) ∈ x.val`.

That requires an additional lemma: **U(ψ₁,ψ₂) ∈ x.val → G(U(ψ₁,ψ₂)) ∈ x.val**, which would follow from the BX5 + BX6 absorption pattern. Specifically, by `self_accum_until`: U(ψ₁,ψ₂) → U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)), and then by the G-preservation of Until.

Actually, the standard approach uses the **F_expansion** lemma: `U(ψ₁,ψ₂) → ψ₂ ∨ (ψ₁ ∧ F(U(ψ₁,ψ₂)))`.

Combining:
- From `until_F_expansion`: U(ψ₁,ψ₂) ∈ x.val → F(U(ψ₁,ψ₂)) ∈ x.val (since also ψ₁ ∧ ... gives F(U(ψ₁,ψ₂)))

Wait — `until_F_expansion` in TemporalDerived.lean gives `U(ψ₁,ψ₂) → ψ₂ ∨ (ψ₁ ∧ F(U(ψ₁,ψ₂)))`. This says either ψ₂ holds at x (the CURRENT point, not a future point) or ψ₁ holds at x and F(U(ψ₁,ψ₂)) holds.

But the semantics is under the open guard (t,s): the guard interval (t,s) is OPEN, so t ∉ (t,s). Therefore ψ₂ need NOT hold at x itself. The `until_F_expansion` has a different character here — it relates to how U unfolds at a single point.

**After careful study of the semantics and axioms**: Under the OPEN guard semantics (t < r < s), the Until guard interval does not include x (the evaluation point). The `until_F_expansion` theorem at `TemporalDerived.lean:455` gives:
```
⊢ (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))
```
where φ is the event (ψ₁) and ψ is the guard (ψ₂) in our convention. Wait — the Burgess convention in this codebase is `untl(event, guard)`, so `Formula.untl ψ₁ ψ₂` means "event ψ₁ with guard ψ₂".

Looking at `until_F_expansion (φ ψ : Formula)` which gives `⊢ (untl ψ φ) → ψ ∨ (φ ∧ F(untl ψ φ))`: this is `U(event=ψ, guard=φ) → ψ ∨ (φ ∧ F(U(ψ,φ)))`.

So `until_F_expansion ψ₂ ψ₁` gives: `U(ψ₁, ψ₂) → ψ₁ ∨ (ψ₂ ∧ F(U(ψ₁,ψ₂)))`.

This gives us: at x, either ψ₁ ∈ x.val (the event holds at x, but under open guard semantics the guard interval doesn't include x), OR ψ₂ ∈ x.val AND F(U(ψ₁,ψ₂)) ∈ x.val.

**Key realization**: This is not directly what we need. The guard condition asks about intermediate points z, not about x itself.

### 3. The Standard Proof Structure (from Burgess 1982)

Reading Burgess §2.4 carefully with the chronicle construction in mind:

The proof of U(γ,β) ∈ A → ∃B,C with B being the "interval content" works as follows:
1. Start with C₀ = {γ} ∪ {S(α,β) : α ∈ A}
2. Prove C₀ consistent using A3a (enrichment_until in our system)
3. Extend C₀ to MCS C
4. B is maximal with r(A,B,C) (all formulas β' ∈ B satisfy ∀ γ' ∈ C, U(γ',β') ∈ A)

The "interval content" B in Burgess corresponds to the set of formulas ψ₂ such that U(ψ₁,ψ₂) ∈ x.val (for our specific ψ₁). And the guard condition holds by construction: any MCS z intermediate between x and C (the witness) will contain all β ∈ B, because B is defined as maximal r(A,B,C) which exactly means ∀ γ ∈ C, U(γ,β) ∈ A, and by the canonical temporal order, β will be in z.

**But**: This construction finds a different witness C than the one built by `until_forward_mcs`. The two approaches may give different witnesses.

### 4. The Actual Lean Proof Strategy: Using the Existing Witness

The code in `until_forward_mcs` already builds witness y from `{ψ₁} ∪ g_content(x)`. The guard condition needs to show: for z with tempR_fwd x z and tempR_fwd z y, ψ₂ ∈ z.val.

The correct approach: Show that `G(ψ₂) ∈ x.val`, which would immediately give ψ₂ ∈ z.val for all z with tempR_fwd x z (and a fortiori for z with tempR_fwd z y).

Can we show G(ψ₂) ∈ x.val from U(ψ₁,ψ₂) ∈ x.val? **No** — U(ψ₁,ψ₂) only guarantees ψ₂ holds on the GUARD interval (x,y), not universally. G(ψ₂) would mean ψ₂ holds at ALL future points.

**The actual strategy must be**:

Show ψ₂ ∈ g_content(x) — i.e., G(ψ₂) ∈ x.val? No, this is too strong.

**Alternative**: Show that given tempR_fwd x z AND tempR_fwd z y AND U(ψ₁,ψ₂) ∈ x.val, we get ψ₂ ∈ z.val by:
1. U(ψ₁,ψ₂) propagates from x to z via g_content (i.e., G(U(ψ₁,ψ₂)) ∈ x.val would work)
2. At z, U(ψ₁,ψ₂) ∈ z.val with tempR_fwd z y and ψ₁ ∈ y.val means...

This is circular — we'd need to apply the until truth lemma for z, which is what we're trying to prove.

**The Burgess canonical proof works differently**: It uses the absorb_until axiom (BX6) and the enrichment/A3a axiom, not naive G-propagation.

### 5. The Correct Standard Proof: Contrapositive via until_backward Seed

The standard canonical model proof for the Until guard condition uses:

**Lemma**: If U(ψ₁,ψ₂) ∈ x.val and tempR_fwd x z and tempR_fwd z y and ψ₁ ∈ y.val, then ψ₂ ∈ z.val.

**Proof by contrapositive** (the "Burgess §2.9/2.10 Counterexample Lemma" approach):

Assume ψ₂ ∉ z.val. Then ¬ψ₂ ∈ z.val (by MCS completeness).

Consider the "interval content" at z: since U(ψ₁,ψ₂) ∈ x.val and g_content(x) ⊆ z.val (i.e., tempR_fwd x z), we need U(ψ₁,ψ₂) ∈ z.val. This follows IF G(U(ψ₁,ψ₂)) ∈ x.val, but we need to establish that first.

**Key lemma needed**: `G(U(ψ₁,ψ₂)) ∈ x.val` from `U(ψ₁,ψ₂) ∈ x.val`.

This follows from BX5 (self_accum_until): `U(ψ₁,ψ₂) → U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂))`. And then, since ψ₂ ∧ U(ψ₁,ψ₂) ∈ g_content(x) would require G(ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val... still circular.

**The resolution**: There is NO simple proof via G-propagation. The correct approach is the one documented in Burgess §2.9 (Counterexample Lemma), which builds a new intermediate point and uses the A4a/BX14 (separation) axiom.

But A4a (BX14 = `separation_until`) was **removed** from the system (Axioms.lean notes: "REMOVED (Task 115)"). This is a critical obstacle.

### 6. The Xu 1988 Alternative via BX6 (absorb_until)

Xu 1988 (referenced in CanonicalChain.lean) provides a simpler proof using only BX5+BX6. The absorption axiom BX6 prevents infinite deferral. The strategy:

Given U(ψ₁,ψ₂) ∈ x.val, we want to show ψ₂ is in ALL intermediate points.

By **self_accum_until (BX5)**: U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val.

Now, the guard content of U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) is ψ₂ ∧ U(ψ₁,ψ₂). So:

By `g_content_closed_derivation`: if ψ₂ ∧ U(ψ₁,ψ₂) ∈ g_content(x)... but this requires G(ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val, not just U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val.

U and G are DIFFERENT operators. U(ψ₁, guard) says "eventually ψ₁ with guard holding between". G(guard) says "guard holds forever". These are unrelated in general.

### 7. The Actual Working Proof Pattern in the Codebase

After studying `TemporalCoherence.lean` and `BXCanonical/Frame.lean`, the conclusion is clear:

**The BX canonical model (BXCanonical/) also does NOT have a general proof of the guard condition for arbitrary Until/Since formulas in the non-chain setting.** This is precisely why `BFMCS.forward_until_since_coherent` is defined as a separate predicate that is assumed/axiomatized (see TemporalCoherence.lean lines 513-525).

The working proof (`bx_until_eventuality_resolution`) only returns `∃ v, bx_le w v ∧ ψ ∈ v`, NOT the guard condition. The guard condition is handled by a different pathway (the chronicle/quasimodel construction for BX completeness, not the canonical model).

For the **ReflCanDomain** (WeakCanonical) approach, the same issue applies. The `until_forward_mcs` sorry reflects a genuine gap that cannot be closed by a simple G-propagation argument.

---

## Recommended Approach

### For `until_forward_mcs` and `since_forward_mcs` (Sorries 1, 3)

**Approach: The Enriched Witness Seed**

Build a DIFFERENT seed for y that includes the guard constraint in the construction, making the guard condition provable from the Lindenbaum extension.

The enriched seed for y should be: `{ψ₁} ∪ {ψ₂} ∪ g_content(x)`.

Wait — this adds BOTH the event AND the guard. But the event y should contain ψ₁ and the GUARD should be ψ₂, not "ψ₂ should be in y".

The right enriched seed is: `{ψ₁} ∪ g_content(x)` but with the additional constraint that ψ₂ is consistent with the seed (which it is, since U(ψ₁,ψ₂) ∈ x.val implies ψ₂ is consistent with g_content(x)).

**Alternative: Use BX5 to change the Until formula first**

From U(ψ₁,ψ₂) ∈ x.val, apply BX5 to get U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val.

Now build the witness y for U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) using the standard forward_temporal_witness_seed: {ψ₁} ∪ g_content(x).

This y has ψ₁ ∈ y.val (same as before). But now for z with tempR_fwd x z and tempR_fwd z y:
- We need ψ₂ ∧ U(ψ₁,ψ₂) ∈ z.val... same problem arises.

**The most promising approach**: Use the until_witness_seed_consistent from WitnessSeed.lean, which already uses the until induction principle directly:

```lean
theorem until_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_U : Formula.untl ψ φ ∈ M) :
    SetConsistent (until_witness_seed M ψ)
```

This gives a consistent seed `{ψ} ∪ g_content(x)` using BX10 directly. This is exactly the seed already used in `until_forward_mcs`.

**The guard condition requires a separate approach**. The key observation is:

For any z with tempR_fwd x z AND tempR_fwd z y (where y is the witness with ψ₁ ∈ y.val):
- `g_content(x) ⊆ z.val` and `g_content(z) ⊆ y.val`
- We need ψ₂ ∈ z.val.

**The Burgess A5a (BX5/self_accum_until) approach**:

In the Burgess canonical model proof, the "interval content" B between two points A and C consists of all β such that U(γ,β) ∈ A for all γ ∈ C. The key property is that every intermediate point z contains B (this is part of the r(A,B,C) relation).

In the ReflCanDomain, the "interval content" from x to y corresponds to: β ∈ g_content(x) iff G(β) ∈ x.val, and these automatically appear at z via tempR_fwd x z.

For ψ₂ to appear at every intermediate z, we need G(ψ₂) ∈ x.val. But U(ψ₁,ψ₂) does NOT imply G(ψ₂).

**Conclusion**: The guard condition as stated (for ALL z between x and y) is NOT provable from U(ψ₁,ψ₂) ∈ x.val alone in the ReflCanDomain setting without additional axioms or a restructured construction.

**The Resolution: Use a More Restricted Witness Construction**

The Burgess witness construction (§2.4, Lemma 2.4) builds y differently from the current code. Instead of extending `{ψ₁} ∪ g_content(x)`, Burgess builds:

C₀ = {γ=ψ₁} ∪ {S(α, β=ψ₂) : α ∈ x.val}

And B is characterized by: all formulas β' such that ∀γ ∈ C, U(γ,β') ∈ x.val.

This B-characterization ensures that z, being an intermediate MCS "between" x and y in the canonical model sense, will contain all β ∈ B including ψ₂.

**To port Burgess §2.4 to ReflCanDomain, we need**:
1. The enrichment_until axiom (BX13, already present as `Axiom.enrichment_until`)
2. The BX13 seed: C₀ = {ψ₁} ∪ {Formula.snce α ψ₂ | α ∈ x.val}
3. Show C₀ is consistent using enrichment_until + MCS properties
4. Extend to MCS y
5. Show that any z with tempR_fwd x z and tempR_fwd z y has ψ₂ ∈ z.val via the S-F duality in BX4/connect_future

**This is the standard literature approach and requires refactoring the witness seed construction.**

### For `until_backward_mcs` and `since_backward_mcs` (Sorries 2, 4)

**Approach: Contrapositive using G(¬U(ψ₁,ψ₂)) ∈ x.val**

If U(ψ₁,ψ₂) ∉ x.val, we want to show ¬(∃ y, tempR_fwd x y ∧ ψ₁ ∈ y.val ∧ ∀ z, tempR_fwd x z → tempR_fwd z y → ψ₂ ∈ z.val).

Standard argument: ¬U(ψ₁,ψ₂) ∈ x.val (by negation completeness). The `until_F_expansion` gives `U(ψ₁,ψ₂) → ψ₁ ∨ (ψ₂ ∧ F(U(ψ₁,ψ₂)))`, so ¬U(ψ₁,ψ₂) ∈ x.val implies G(¬U(ψ₁,ψ₂)) ∈ x.val via... no, ¬U → G(¬U) is not generally valid.

Actually, we need the contrapositive of the forward direction. The standard argument is:
- Assume the semantic condition holds: ∃ y such that tempR_fwd x y, ψ₁ ∈ y.val, and ∀ z between x,y: ψ₂ ∈ z.val.
- We need to show U(ψ₁,ψ₂) ∈ x.val.
- This follows from BX6 (absorb_until) + induction along the chain from x to y.

For the backward direction in the CANONICAL MODEL setting, the standard approach uses the fact that any semantic witness for U(ψ₁,ψ₂) can be "read back" into an axiomatic proof:
- ψ₁ ∈ y.val, g_content(x) ⊆ y.val → G(ψ₁) ∈ x.val? No, that's too strong.

The backward direction requires the `backward_until_since_coherent` property from TemporalCoherence.lean. In the BX setting, this was blocked as documented there. For the ReflCanDomain setting, the same fundamental obstruction applies.

**Recommended action for backward sorries**: The truth_lemma backward cases (sorries 5-6) only need `until_backward_mcs` and `since_backward_mcs` in the form used on lines 548 and 563. Looking at those lines:

```lean
-- DOCUMENTED SORRY: Requires until_backward_mcs variant / induction principle.
sorry
```

These are called from: given `h_φ_y : φ ∈ y.val`, `h_fwd : tempR_fwd x y`, `h_guard` (which IS `h_guard : ∀ z, tempR_fwd x z → tempR_fwd z y → ψ ∈ z.val`), derive `untl φ ψ ∈ x.val`.

This is EXACTLY `until_backward_mcs` (the backward direction from semantic witness to formula membership). This IS harder and requires the Burgess §2.6-§2.7 approach.

### For `reflCanR_linear` (Sorry 7)

**Standard BX11 argument**. The sorry's comment already outlines the proof:

1. Assume `¬tempR_fwd y z` and `¬tempR_fwd z y`
2. Get ψ with Gψ ∈ y.val, ψ ∉ z.val and χ with Gχ ∈ z.val, χ ∉ y.val
3. By negation completeness: ¬ψ ∈ z.val, ¬χ ∈ y.val
4. Need F(¬ψ) ∈ x.val and F(¬χ) ∈ x.val
5. Apply BX11 to conclude contradiction

For step 4: From Gψ ∈ y.val and tempR_fwd x y: ψ ∈ y.val (but we need ¬ψ ∈ some future of x, not ψ itself). We need a different direction.

Actually: from tempR_fwd x z (g_content(x) ⊆ z.val) and ¬ψ ∈ z.val: if Gψ ∈ x.val then ψ ∈ z.val (contradiction). So Gψ ∉ x.val. Then ¬Gψ ∈ x.val = F(¬ψ) ∈ x.val (since ¬Gψ = F(¬ψ)).

Wait, but Gψ ∈ y.val does NOT imply Gψ ∈ x.val via tempR_fwd x y (that direction only flows forward: g_content(x) ⊆ y.val). We need the REVERSE: from tempR_fwd x y and ψ ∉ z.val, get F(¬ψ) ∈ x.val.

Since ¬ψ ∈ z.val, and tempR_fwd x z (g_content(x) ⊆ z.val): if G(¬¬ψ) ∈ x.val, then ¬¬ψ ∈ z.val, but that's not ψ directly. Instead:

F(¬ψ) = ¬G(ψ). Since ψ ∉ z.val (by hypothesis, from the incomparability assumption), and if G(ψ) ∈ x.val would force ψ ∈ z.val: so G(ψ) ∉ x.val, hence F(¬ψ) = ¬G(ψ) ∈ x.val.

Similarly, F(¬χ) ∈ x.val.

So now BX11 at x: F(¬ψ) ∧ F(¬χ) → F(¬ψ ∧ ¬χ) ∨ F(¬ψ ∧ F(¬χ)) ∨ F(F(¬ψ) ∧ ¬χ).

All three disjuncts need to lead to contradictions with the conditions on y and z. The key is that y and z are BOTH reachable from x (tempR_fwd x y and tempR_fwd x z), and they're incomparable. The BX11 disjunction case analysis should work but is non-trivial.

**Concrete Lean proof for `reflCanR_linear`**:

```lean
by_contra h_neither
push_neg at h_neither
obtain ⟨h_not_yz, h_not_zy⟩ := h_neither
-- Get witness ψ with Gψ ∈ y, ψ ∉ z
simp [tempR_fwd, g_content, Bundle.g_content] at h_not_yz
obtain ⟨ψ, hGψ_y, hψ_not_z⟩ := h_not_yz
-- Get witness χ with Gχ ∈ z, χ ∉ y
simp [tempR_fwd, g_content, Bundle.g_content] at h_not_zy
obtain ⟨χ, hGχ_z, hχ_not_y⟩ := h_not_zy
-- Negation completeness: ¬ψ ∈ z.val
have h_neg_ψ_z : ψ.neg ∈ z.val := ...
-- Negation completeness: ¬χ ∈ y.val
have h_neg_χ_y : χ.neg ∈ y.val := ...
-- F(¬ψ) ∈ x.val: G(ψ) ∉ x.val since ψ ∉ z.val but tempR_fwd x z
have h_Gψ_not_x : Formula.all_future ψ ∉ x.val := ...
have h_Fψ_neg_x : Formula.some_future ψ.neg ∈ x.val := ...
-- F(¬χ) ∈ x.val: similarly
have h_Fχ_neg_x : Formula.some_future χ.neg ∈ x.val := ...
-- BX11 at x
have h_bx11 := ... -- temp_linearity
-- Case analysis on BX11 disjunction → contradiction in each case
...
```

### For `canS5R_symm` (Sorry 8)

**Standard S5 symmetry argument via modal B axiom**:

Given `h : canS5R x y`, prove `canS5R y x`, i.e., for all φ, □φ ∈ y.val → φ ∈ x.val.

Standard proof using modal B (`φ → □◇φ`):

Suppose □φ ∈ y.val. We want φ ∈ x.val.

By `h : canS5R x y` definition: □χ ∈ x.val → χ ∈ y.val.

Step 1: Get ◇φ ∈ x.val? No, we need to go the other direction.

Actually the standard S5 symmetric argument:
1. From φ ∈ x.val? We don't know φ ∈ x.val; that's what we're proving.
2. Use contrapositive: assume φ ∉ x.val. Then ¬φ ∈ x.val.
3. By modal B: ¬φ → □◇(¬φ). So □◇(¬φ) ∈ x.val.
4. By h (canS5R x y): ◇(¬φ) ∈ y.val. [since □(◇(¬φ)) ∈ x.val]
5. But □φ ∈ y.val → φ ∈ y.val (by reflexivity canS5R_refl).
   And ◇(¬φ) = ¬□(¬¬φ). We have □φ ∈ y.val.
   ◇(¬φ) ∈ y.val means ¬□(¬¬φ) ∈ y.val.
   We need ¬□(¬¬φ) ∈ y.val vs □φ ∈ y.val.
   By modal equivalence: □φ → □(¬¬φ) (via DNI + K). So □(¬¬φ) ∈ y.val.
   But ◇(¬φ) = ¬□(¬¬φ) ∈ y.val... contradiction.

**Concrete Lean proof sketch**:

```lean
intro φ h_box_φ_y
-- By contrapositive + B axiom
by_contra h_not_φ_x
have h_neg_φ_x : φ.neg ∈ x.val := ...
-- modal_b: φ.neg → □(◇φ.neg)
have h_modal_b := DerivationTree.axiom [] _ (Axiom.modal_b φ.neg)
have h_box_dia_neg : (φ.neg.diamond).box ∈ x.val := ... -- via MCS closure
-- canS5R x y: □(◇¬φ) ∈ x.val → ◇¬φ ∈ y.val
have h_dia_neg_y : φ.neg.diamond ∈ y.val := h (φ.neg.diamond) h_box_dia_neg
-- But □φ ∈ y.val and ◇¬φ ∈ y.val leads to contradiction
-- □φ → φ (modal_t): φ ∈ y.val
-- ◇¬φ = ¬□(¬¬φ), □φ → □(¬¬φ) (via K + DNI), contradiction
...
```

---

## Evidence and Examples

### Literature Support for the Guard Condition Approach

From Burgess 1982 §2.4 (Lemma 2.4): The "interval content" B between A and C is the maximal DCS with r(A,B,C), where r(A,β,C) means "for all γ ∈ C, U(γ,β) ∈ A". This characterization ensures β ∈ B iff all A-to-C transitions have β as guard content.

In the ReflCanDomain context, the analog of "β ∈ B" is "β ∈ g_content(x)" (= G(β) ∈ x.val). But U(ψ₁,ψ₂) ∈ x.val does NOT imply G(ψ₂) ∈ x.val — this is the core difficulty.

**Burgess's actual construction** circumvents this by building the witness C differently (using the enrichment axiom A3a = BX13 enrichment_until), so that the guard property is "baked in" to the Lindenbaum witness.

From Reynolds 1992 §4 (Burgess–Xu Result): The completeness proof requires "carefully choosing a single maximal consistent set to right the counter-example and satisfy some other stringent conditions." This is exactly what Burgess §2.4's seed construction (using S(α,β) : α ∈ A) achieves.

### Support for the reflCanR_linear Proof

Axiom BX11 (`temp_linearity`):
```
F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)
```

This is present in the axiom system and is what the sorry comment explicitly calls out. The infrastructure for F(¬ψ) ∈ x.val and F(¬χ) ∈ x.val is straightforward via negation completeness + g_content definitions.

### Support for canS5R_symm

Axiom `modal_b` (B axiom): `φ → □◇φ`, present at `Axiom.modal_b` in `Axioms.lean:96`. The modal B axiom is exactly the tool needed for S5 symmetry in canonical models. The standard Blackburn-de Rijke-Venema treatment (BdRV Modal Logic, §4.2) shows that the canonical model for S5 (= KT4B) is an equivalence relation, with symmetry following directly from the B axiom.

---

## Recommended Implementation Order

1. **canS5R_symm** (easiest, fully axiomatized): Prove via contrapositive + modal_b.
   - Estimated effort: 1-2 hours.
   - Risk: Low. Standard S5 argument.

2. **reflCanR_linear** (medium difficulty): Use BX11 with the F(¬ψ) argument sketched above.
   - Estimated effort: 2-4 hours.
   - Risk: Medium. The BX11 case analysis is non-trivial but follows a clear path.

3. **Redesign until_forward_mcs witness construction**: Port Burgess §2.4 enrichment seed.
   - Core change: Replace the witness seed `{ψ₁} ∪ g_content(x)` with the Burgess enriched seed `{ψ₁} ∪ {snce α ψ₂ | α ∈ x.val} ∪ g_content(x)` (using BX13/enrichment_until to prove consistency).
   - Then show that any z with tempR_fwd x z and tempR_fwd z y contains ψ₂ via the S-F duality.
   - Estimated effort: 4-8 hours.
   - Risk: Medium-High. Requires new seed consistency proof using BX13.

4. **until_backward_mcs** (hardest): Derive U(ψ₁,ψ₂) ∈ x.val from semantic witness.
   - Standard approach: Use BX6 (absorb_until) + induction on chain structure.
   - For the ReflCanDomain setting without a deterministic chain, this may require the "backward coherence" approach from TemporalCoherence.lean.
   - Alternative: Check whether this is genuinely needed or whether truth_lemma can be restructured to avoid it.
   - Estimated effort: 8-12 hours.
   - Risk: High.

5. **since variants** (items 3-4, 7-8): Mirrors of until variants. Once until is done, since follows by symmetry of construction.

---

## Confidence Level

**High confidence**:
- `canS5R_symm` proof strategy (via modal_b axiom): direct and well-supported by literature.
- `reflCanR_linear` proof strategy (via BX11): clearly indicated by the existing code comments.
- The diagnosis that `until_forward_mcs`'s existing witness is INSUFFICIENT for the guard condition.

**Medium confidence**:
- The Burgess §2.4 enriched seed approach for `until_forward_mcs`: the enrichment_until axiom (BX13) is present, and the construction is standard in the literature, but the Lean formalization details require careful verification.
- The exact formulation of the guard condition proof after the seed redesign.

**Low confidence**:
- `until_backward_mcs` proof strategy: this corresponds to one of the known hard cases in temporal logic completeness theory. The BXCanonical approach (TemporalCoherence.lean) left this as a documented hard sorry with good reason. Whether the ReflCanDomain setting provides enough additional structure to close it is unclear without a more detailed construction.

---

## Critical Issue: Mismatch Between Witness Construction and Guard Condition

The current `until_forward_mcs` builds y from `{ψ₁} ∪ g_content(x)`, which is the FORWARD WITNESS seed (standard for G/F truth lemma). This seed is appropriate for showing `ψ₁ ∈ y.val` but provides NO information about `ψ₂` at intermediate points.

The Burgess §2.4 seed `C₀ = {ψ₁} ∪ {S(α, ψ₂) : α ∈ x.val}` is DIFFERENT from the current seed. This seed uses the SINCE operator to encode the guard condition: "at y, for any α that was true at x, S(α,ψ₂) holds at y" means "ψ₂ was true between x and y (and α was true at x)".

The intermediate guard `ψ₂ ∈ z.val` for z between x and y then follows from: `S(α,ψ₂) ∈ y.val` for all α ∈ x.val, and tempR_fwd z y (g_content(z) ⊆ y.val), plus some Since-content argument.

**This seed redesign is the key change needed for sorries 1 and 3.**

Note: The current `until_forward_mcs` already uses `forward_temporal_witness_seed_consistent` which gives the `{ψ₁} ∪ g_content(x)` seed. This will need to be replaced with a Burgess-style seed based on `{ψ₁} ∪ {snce α ψ₂ | α ∈ x.val}`. A new consistency lemma will be needed using BX13 (enrichment_until).
