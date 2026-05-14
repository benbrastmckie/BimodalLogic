# Teammate B Findings: Alternative Canonical Model Designs

**Task**: 129 — Weak/reflexive completeness and conservative extension
**Date**: 2026-05-14
**Angle**: Alternative approaches to the multi-relation architecture
**Session**: sess_1778772971_e25ab1

---

## Key Findings

### 1. Reynolds Uses Burgess's Chronicle, Not a Canonical Model

The most important finding from reading the literature carefully: **Reynolds 1994 does not build a canonical model at all.** His Theorem 18 proof (the completeness result) proceeds:

1. Given consistent formula A₀, invoke the Burgess-Xu Corollary 3 to get a countable discrete linear model M₀ satisfying A₀ at some point t₀, with Prior-UZ/SZ valid everywhere.
2. Apply Theorem 15 (the "good/very good" compression) to M₀ to get a Z-flowed model satisfying the same monadic sentences up to quantifier depth k.
3. Since the table of A₀ is a monadic formula of bounded quantifier depth, Z ⊨ A₀.

The Burgess-Xu construction (Corollary 3) is what produces the initial model. Burgess's construction IS a chronicle — it builds a model point by point on the rationals, maintaining pairs (f, g) where f maps rational time points to MCS and g maps consecutive pairs to deductively closed "between" sets. The completeness proof in Burgess 1982 (Section 2) uses Lemmas 2.4–2.10 to handle the Until/Since witness conditions, extending the chronicle one point at a time.

**Critical implication**: Reynolds's approach **does not need a Henkin canonical model at all** for the initial step. It uses Burgess's strong completeness for linear time (which handles all the Until/Since complications via the chronicle mechanism) and then compresses the result. The canonical model question (single-relation vs. multi-relation) is about how to bypass Burgess when we want a reflexive structure for the Doets compression argument.

### 2. Three Alternative Approaches Worth Evaluating

#### Alternative A: "Weak Truth Then Transfer" (Purely Weak Semantics)

Define truth in the canonical model using WEAK operators:
- `reflCanTruth_w x (all_future φ) := ∀y, reflCanR x y → reflCanTruth_w y φ`
- The single relation `reflCanR` (via g_w_content) suffices since it IS reflexive.

**Pros**:
- Only one relation needed — `reflCanR`
- G_w-forward is trivial: if ψ∧Gψ ∈ x and g_w_content x ⊆ y.val, then ψ ∈ y.val (direct from the definition)
- G_w-backward: if G_w(ψ) ∉ x, i.e., ψ∧Gψ ∉ x, we need a witness y with reflCanR x y and ψ ∉ y. This requires more care — we extend `g_w_content x ∪ {¬ψ}` to MCS. But wait: we need consistency of `g_w_content x ∪ {¬ψ}`, which needs `G_w(ψ) ∉ x` to fail to derive ψ∧Gψ from g_w_content. This is not directly the standard Henkin argument.

**Fatal flaw**: The weak semantics for Until is problematic. U_w(ψ₁, ψ₂) at x means ∃y ≥ x with ψ₁ at y and ψ₂ at all z with x ≤ z < y. But under weak (reflexive) semantics, "x ≤ z" includes z = x, so U_w(ψ₁, ψ₂) forces ψ₂ at x itself. In strict Until, ψ₂ need not hold at x. This changes the logic — weak Until is NOT just "strict Until plus reflexivity." The truth lemma would prove a DIFFERENT set of valid formulas than what TM actually axiomatizes.

Moreover, U_w(ψ₁, ⊥) at x means ψ₁ at x (since ⊥ at all z with x ≤ z < y, but no z satisfies ⊥ so this is vacuous — actually wait, ⊥ must hold at x since x ≤ x. So U_w(ψ₁, ⊥) is never satisfiable. This means F_w ≡ ⊥ in weak semantics. **This is catastrophic** — the weak Until cannot define "something will happen in the future" at all.

**Verdict: REJECTED.** Weak Until semantics is degenerate. You cannot have a reflexive Until that works.

#### Alternative B: Reflexive Closure of tempR_fwd

Define a single relation `R x y := tempR_fwd x y ∨ x = y` (reflexive closure of g_content-based relation).

**Pros**: Single relation, reflexive by construction.

**Problem**: This is just `tempR_fwd` with reflexivity bolted on. The truth lemma would use `R x y ∧ y ≠ x` for G (recovering tempR_fwd), which is exactly Path 2 from Report 06 — already shown to have the fatal G-forward flaw. The issue is that `R x y ∧ y ≠ x` does NOT imply `g_content x ⊆ y.val` in general. The disjunctive definition means R carries less information than tempR_fwd at non-identity pairs.

Actually wait — at non-identity pairs, `R x y` IS `tempR_fwd x y`, so `R x y ∧ y ≠ x ↔ tempR_fwd x y` (assuming tempR_fwd x y → y ≠ x, which is NOT guaranteed). The real issue is that `R x y ∧ y ≠ x` and `tempR_fwd x y` may not be equivalent since `tempR_fwd x x` can hold for some x.

More fundamentally, this is just dressing up the multi-relation approach as a single relation. The truth lemma would still need to use `tempR_fwd` (via the `R ∧ y≠x` decomposition). It gains nothing over the current multi-relation design and obscures the clean separation.

**Verdict: REJECTED.** No advantage over current design, obscures structure.

#### Alternative C: Follow Reynolds Literally — Use Burgess-Xu First

Instead of building a canonical model ourselves, follow Reynolds's proof exactly:
1. Use the existing Burgess-Xu strong completeness for linear time (Theorem 2/Corollary 3) to get an initial model M₀.
2. M₀ is countable, discrete, without endpoints, Prior-UZ/SZ valid everywhere.
3. Apply the Reynolds Theorem 15 compression to get a Z-model.

**Pros**: 
- Completely avoids the canonical model design question
- The Until/Since truth lemma difficulties disappear — Burgess's chronicle handles them
- Matches the literature exactly
- No multi-relation vs. single-relation debate

**Cons**:
- Requires formalizing Burgess's chronicle construction for linear time (Theorem 2)
- BUT: the existing BXCanonical pipeline ALREADY HAS the Burgess chronicle for linear time. The Burgess-Xu result (strong completeness for all linear frames) is precisely what `BXCanonical/Chronicle/` provides.
- The main blocker: Burgess's chronicle produces a model on the rationals. We need the existing chronicle model to satisfy Prior-UZ/SZ everywhere. The chronicle IS an MCS-labeled structure. Prior-UZ/SZ are axioms, so they ARE in every MCS. Does this guarantee the model validates them?

**Critical check**: In the Burgess chronicle, truth at a point t is determined by f(t) (the MCS at t). The truth lemma (Burgess's Claim 2.11) says formula α is true at t iff α ∈ f(t). So Prior-UZ instances are in every f(t) (since they're axioms and every f(t) is an MCS extending the axioms). By the truth lemma, Prior-UZ holds at every point. Thus, the chronicle model IS a Prior structure. ✓

**Problem**: The BXCanonical chronicle has the sorry at `succ_cofinal` precisely because it tries to prove IsSuccArchimedean, which requires the gap argument. So we can't reuse the existing BXCanonical output directly — it has the sorry we're trying to fix.

**Resolution**: We don't need IsSuccArchimedean from the chronicle. We need the chronicle to produce a countable discrete linear model with Prior-UZ/SZ valid everywhere. Then Reynolds Theorem 15 takes this and produces a Z-model. The sorry at succ_cofinal is in the code path that tries to go directly from chronicle to Z-model via IsSuccArchimedean. The Reynolds path goes chronicle → Theorem 15 → Z-model, bypassing IsSuccArchimedean entirely.

**Verdict: PROMISING but requires careful examination of what the existing chronicle actually proves.**

### 3. The BXCanonical Pipeline Already Gives Corollary 3

Looking at the BXCanonical code:
- The BXCanonical pipeline builds a chronicle model for consistent formulas
- The chronicle IS on a countable discrete linear order without endpoints  
- Prior-UZ/SZ are axioms and hence valid in the chronicle model (by the truth lemma)
- This is precisely Burgess-Xu Corollary 3

The existing `dd_countermodel_chronicle_discrete` tries to extract a Z-model directly from the chronicle, which requires IsSuccArchimedean (the sorry). But if we instead extract a "Prior structure" (chronicle model + Prior-UZ/SZ validity) and then feed it to Reynolds Theorem 15, we bypass the sorry entirely.

**This means the multi-relation canonical model (Phase 1 of the current plan) might be unnecessary.** The chronicle already provides the input for Reynolds's argument. The hard work is in the n-equivalence/compression (Phases 2-3), not in building a new canonical model.

### 4. Literature Consensus: Canonical Model for Strict Temporal Logic IS Multi-Relation

Every source that does build a canonical model for strict temporal logic over specific frames uses one of:
- **Burgess 1982**: Chronicle construction on the rationals with (f, g) pairs, no canonical model per se
- **Reynolds 1992** (over the reals): Same Burgess + Doets compression, no canonical model
- **Reynolds 1994** (over integers): Burgess-Xu + Reynolds compression, no canonical model
- **Hodkinson-Reynolds 2006**: Survey confirms the Burgess/Doets/Reynolds pipeline is the standard approach

None of these sources build a Henkin canonical model with a single reflexive relation and then recover strict semantics. The standard approach for specific frames (ℤ, ℝ, ℚ) is always: strong completeness for linear frames (Burgess) → model → compression to the specific frame. The canonical model question only arises for the linear completeness step, where Burgess's chronicle handles it.

### 5. Doets 1989 Uses n-Equivalence Preservation Under Ordered Sums

Doets's key technique (Lemma 1.4): if m(i) =ₙ m'(i) for all i ∈ I, then Σᵢm(i) =ₙ Σᵢm'(i). This preserves n-equivalence under ordered sum replacement. This is used in the condensation arguments (Theorems 2.4, 4.1) where equivalence classes are replaced by n-equivalent representatives.

**For our setting**: Doets Theorem 4.1 (definably complete ⟹ has complete n-equivalents) is exactly what we need for the frame preorder. The reflexive canonical model IS a preorder, and if it's "definably complete" (every definable set with an upper bound has a sup), then it has a complete (Dedekind-complete, hence embeddable into ℝ) n-equivalent. But we need a ℤ-equivalent, not an ℝ-equivalent. This is where Reynolds Theorem 15 comes in — it specializes the Doets argument to discrete structures.

---

## Recommended Approach

**Keep the multi-relation design for the canonical model, but seriously evaluate bypassing it entirely via the existing chronicle.**

Two viable paths forward, in order of recommendation:

### Path 1 (Recommended): Chronicle + Reynolds Compression

1. Use the existing BXCanonical chronicle to produce a countable discrete Prior structure M₀ (this is already proved, modulo the sorry which is in a DIFFERENT code path)
2. Build Reynolds Theorem 15 infrastructure (n-equivalence, good/very good, gap elimination)
3. Apply to M₀ to get Z-model
4. Wire into completeness

**Advantage**: Skips the reflexive canonical model entirely. The Until/Since truth lemma difficulties (6 sorries in TruthLemma.lean) vanish because Burgess's chronicle already handles them. The only new work is the Reynolds compression.

**Risk**: Need to verify that the existing chronicle output provides exactly Corollary 3 (countable, discrete, Prior-UZ/SZ valid). If the truth lemma for the chronicle is incomplete (there may be sorries), this path inherits those.

### Path 2 (Current): Multi-Relation Canonical Model

Continue with the current approach:
1. Close the 6 truth lemma sorries (Until/Since chain construction)
2. Build Reynolds compression on top of the reflexive canonical model
3. Extract Z-model

**Advantage**: Already partially built, mathematically correct per Report 06.

**Disadvantage**: The Until/Since chain construction is genuinely hard and hasn't been solved yet. The reflexive canonical model adds infrastructure that may be unnecessary.

### Anti-Recommendation: Do NOT Pursue Single-Relation Alternatives

Report 06 is correct that the single-relation approach (reflCanR + y≠x) is mathematically broken. Alternative A (weak semantics) is even worse — weak Until is degenerate. Alternative B (reflexive closure) is just the multi-relation approach in disguise. No single-relation design will work for strict temporal semantics with Until/Since.

---

## Evidence/Examples

### Weak Until Degeneracy (Formal)

Under weak (reflexive) semantics with relation ≤:
```
U_w(ψ₁, ψ₂) at x := ∃y ≥ x. ψ₁(y) ∧ ∀z. (x ≤ z ∧ z < y → ψ₂(z))
```

For F_w(ψ) := U_w(ψ, ⊤), this works: ∃y ≥ x. ψ(y). Fine.

For U_w(ψ₁, ⊥): need ∃y ≥ x. ψ₁(y) ∧ ∀z. (x ≤ z ∧ z < y → ⊥). 
- If y = x: need ∀z. (x ≤ z ∧ z < x → ⊥). Since no z satisfies x ≤ z < x, this is vacuously true. So U_w(ψ₁, ⊥) at x ↔ ψ₁(x).
- So "Next" in weak semantics equals identity. This is mathematically degenerate but not catastrophic.

HOWEVER, for U_w(ψ₁, ψ₂) generally: the guard condition requires ψ₂ at x itself (since x ≤ x < y for any y > x). This means U_w(ψ₁, ψ₂) → ψ₂ is valid. In strict semantics, U(ψ₁, ψ₂) does NOT imply ψ₂ at x (ψ₂ only needs to hold at points strictly between x and y). This is a fundamental semantic difference — the weak truth lemma would validate formulas that are NOT valid under strict semantics.

### Burgess Chronicle Already Handles Until/Since

Burgess Lemma 2.9 (Counterexample Lemma for C4a) and Lemma 2.10 (for C5a) handle the Until witness conditions by extending the chronicle one point at a time. The Lean code in `BXCanonical/Chronicle/PointInsertion.lean` implements these. Since the chronicle construction handles Until/Since, using it as input to Reynolds would bypass the 6 truth lemma sorries in the reflexive canonical model.

---

## Confidence Level

**High** on the rejection of single-relation alternatives (both theoretical argument and literature support).

**Medium-High** on the Chronicle + Reynolds path being viable — needs verification that the existing chronicle provides exactly what Reynolds Theorem 15 needs.

**High** on the multi-relation design being correct (confirming Report 06) — but noting it may be unnecessary overhead if the chronicle path works.
