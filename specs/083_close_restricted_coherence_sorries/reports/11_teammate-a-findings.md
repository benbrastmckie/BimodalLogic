# Teammate A Findings: Half-Open Feasibility and Partial Strict Analysis

**Task**: 83 — Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Role**: Teammate A — Half-open backward blocker analysis + partial strict option

## Key Findings

1. **The half-open backward blocker is a genuine mathematical obstruction, not merely a difficulty** (HIGH confidence)
2. **U-Induction cannot overcome the blocker under the current axiom system** (HIGH confidence)
3. **The dovetailed chain structure does not help the pure backward direction** (HIGH confidence)
4. **Partial strict (strict U/S with reflexive G/H) resolves the backward blocker cleanly** (HIGH confidence)
5. **Partial strict preserves temp_t axioms and most existing infrastructure** (MEDIUM-HIGH confidence)
6. **Partial strict is the literature-standard configuration for discrete temporal logic with Until** (HIGH confidence)

## Analysis of Half-Open Feasibility

### The Precise Blocker

The current Until semantics (Truth.lean:126-127):
```
φ U ψ at t  ⟺  ∃ s ≥ t, ψ(s) ∧ ∀ r ∈ [t, s), φ(r)
```

The current introduction axiom (Axioms.lean:469-471):
```
until_intro: ψ ∨ (φ ∧ G(φ U ψ)) → φ U ψ
```

The backward truth lemma goal: Given semantic witnesses (s ≥ t, ψ true at s, φ true on [t,s)), prove `φ U ψ ∈ mcs(t)`.

**Case s = t**: ψ(t) holds, so ψ ∈ mcs(t) by IH on subformula. Apply until_intro (left disjunct). Done.

**Case s > t**: Need the right disjunct: `φ ∈ mcs(t) ∧ G(φ U ψ) ∈ mcs(t)`. Getting φ ∈ mcs(t) is fine (φ holds at t since t ∈ [t,s)). But G(φ U ψ) ∈ mcs(t) requires (via `temporal_backward_G`, TemporalCoherence.lean:166-179) that `φ U ψ ∈ mcs(j)` for ALL j ≥ t.

The breakdown by range of j:
- **j ∈ [t+1, s-1]**: By induction on witness distance s-j < s-t, we get semantic Until witnesses for j (same s, guard restricted to [j,s)), so `φ U ψ ∈ mcs(j)` by IH.
- **j = s**: ψ(s) gives `φ U ψ ∈ mcs(s)` via until_intro (left disjunct, witness s=s).
- **j > s**: NO semantic witnesses exist. We would need either (a) `φ U ψ` to be semantically true at j > s, which requires finding a NEW witness s' > s with ψ(s') and φ on [j, s'), or (b) a purely syntactic argument within the MCS.

**This is the fundamental gap**: The semantic Until statement at t provides witnesses only up to s. For j > s, the formula `φ U ψ` may or may not be semantically true, and we have no information.

### Why U-Induction Cannot Help

The until_induction axiom (Axioms.lean:479-483):
```
G(ψ → χ) ∧ G(φ ∧ χ → G(χ)) → (φ U ψ → χ)
```

This axiom works in the FORWARD direction: it deduces properties χ FROM `φ U ψ`. But the backward direction needs the REVERSE: prove `φ U ψ` from semantic facts. U-Induction is the wrong tool.

The handoff document (08_backward-until-handoff.md) lists Approach 3: use the contrapositive of U-Induction. Contrapositive:
```
¬χ ∧ (φ U ψ) → ¬G(ψ → χ) ∨ ¬G(φ ∧ χ → G(χ))
```

This tells us that if we ASSUME `φ U ψ ∈ mcs(t)` AND `¬χ ∈ mcs(t)`, then one of the premises fails. But we're trying to PROVE `φ U ψ ∈ mcs(t)`, not assume it. The contrapositive goes the wrong way.

**Could we use a contradiction approach?** Assume `¬(φ U ψ) ∈ mcs(t)`. We have `φ(t)` semantically. By until_intro contrapositive, `¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ F(¬(φ U ψ)))`. Since `φ(t)` is true, `¬φ ∉ mcs(t)`, so `F(¬(φ U ψ)) ∈ mcs(t)`. By forward_F, there exists w ≥ t with `¬(φ U ψ) ∈ mcs(w)`.

Now:
- If w ∈ (t, s]: `φ U ψ ∈ mcs(w)` by the inductive hypothesis (witness distance s-w < s-t). Contradiction with `¬(φ U ψ) ∈ mcs(w)`.
- If w = t: No progress (circular).
- If w > s: `¬(φ U ψ) ∈ mcs(w)` is consistent with everything we know. No contradiction available.

**The problem with forward_F**: It can return witnesses BEYOND s. On ℤ with reflexive G, `F(¬(φ U ψ)) ∈ mcs(t)` means `∃ w ≥ t, ¬(φ U ψ) ∈ mcs(w)`. There is no bound on w. The dovetailed chain construction does not constrain where forward_F witnesses land — they come from the Lindenbaum extension process, which is non-constructive.

### Why the Dovetailed Chain Does Not Help

The dovetailed chain (DovetailedChain.lean) builds an ω-chain of MCSs with fair scheduling of F-obligations. It guarantees:
- If `F(χ) ∈ mcs(n)`, then `χ ∈ mcs(m)` for some m > n (the deferred obligation is eventually fulfilled).
- The chain is constructed via Lindenbaum extension at each step.

But the backward truth lemma doesn't need to construct the chain — it needs to READ properties FROM the chain. The chain provides forward_G (g_content inclusion) and forward_F (deferral fulfillment). Neither gives us `φ U ψ ∈ mcs(j)` for j > s.

**Key insight**: The chain guarantees that F-obligations are eventually fulfilled, but it does NOT guarantee that `φ U ψ` persists past its witness point. In fact, it would be semantically incorrect for `φ U ψ` to necessarily persist past s — on the model side, `φ U ψ` at j > s requires a new witness s' > j, which might not exist.

### Mathematical Argument for Impossibility

**Claim**: Under half-open semantics with reflexive G and the current axiom system, the backward Until truth lemma CANNOT be proved purely from (a) the axioms and (b) the MCS chain structure.

**Argument**: Consider the model ℤ with:
- φ = ⊤ (always true)
- ψ = "exactly time 5" (true only at t=5)

At t=0: `φ U ψ` holds (witness s=5, φ=⊤ on [0,5)).
At t=7: `φ U ψ` does NOT hold (no future time has ψ).

So `G(φ U ψ)` is FALSE at t=0. But `until_intro` requires `G(φ U ψ) ∈ mcs(0)` for the right disjunct. The only other option is ψ ∈ mcs(0), but ψ is false at 0.

This means `until_intro` as currently stated is UNSOUND under the current semantics. The Soundness.lean file confirms this at line 518-520: `until_unfold` is marked UNSOUND, and `until_intro` is only sound because its proof relies on `G(φ U ψ) → (φ U ψ)` via reflexivity of G (taking s = t). The DIRECTION of unsoundness matters:

- `until_intro` IS sound: ψ(t) obviously gives φ U ψ (witness s=t). And φ(t) ∧ G(φ U ψ)(t) gives φ U ψ(t) because G means "at all s ≥ t", so (φ U ψ)(t) is immediate by reflexivity.
- `until_unfold` is UNSOUND: (φ U ψ)(t) does NOT imply G(φ U ψ)(t) in general.

**This is the root cause**: The unfold axiom `(φ U ψ) → ψ ∨ (φ ∧ G(φ U ψ))` is unsound under half-open + reflexive G. Without a sound unfold axiom, we cannot use until_unfold_in_mcs in the backward direction (it derives from an unsound axiom). The forward truth lemma "works" only because it assumes `φ U ψ ∈ mcs(t)` and extracts semantic content, using the unsound axiom's consequence without needing actual soundness. The backward direction needs the axiom to be sound to ensure the MCS contains the right formulas.

**Verdict**: The backward truth lemma is not provable with the current axiom system because the axioms themselves are partly unsound. This is not a proof difficulty — it is a fundamental mismatch between the semantics and the axiom system.

## Analysis of Partial Strict (Strict U/S + Reflexive G/H)

### The Configuration

- **G/H**: Keep reflexive (∀ s ≥ t / ∀ s ≤ t) — preserves temp_t_future, temp_t_past
- **Until**: Change to strict (∃ s > t, ψ(s) ∧ ∀ r, t < r → r < s → φ(r))
- **Since**: Change to strict (∃ s < t, ψ(s) ∧ ∀ r, s < r → r < t → φ(r))

### Axiom System Changes Required

**Remove**: until_unfold, until_intro, until_induction (G-based versions unsound under strict Until)

**Replace with X-based versions** (where X = ⊥ U = next-step operator):

```
until_unfold_strict: (φ U ψ) → X(ψ ∨ (φ ∧ (φ U ψ)))
until_intro_strict:  X(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)
until_induction_strict: (ψ → χ) ∧ (φ ∧ X(χ) → χ) → (φ U ψ → X(χ))
                        -- or possibly: G(ψ → χ) ∧ G(φ ∧ X(χ) → χ) → (φ U ψ → X(χ))
```

Wait — but X = ⊥ U is defined in terms of Until. If Until is strict, then `X(χ) at t` means `∃ s > t, χ(s) ∧ ∀ r, t < r → r < s → ⊥(r)`. On ℤ, the guard `⊥ on (t,s)` requires (t,s) to contain no integers where ⊥ is evaluated, i.e., s = t+1 (no integers strictly between t and t+1). So `X(χ) at t ⟺ χ(t+1)`. Good.

**Soundness of strict until_unfold_strict**: `(φ U ψ) at t → X(ψ ∨ (φ ∧ (φ U ψ)))` at t.
- φ U ψ at t means ∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r).
- X(ψ ∨ (φ ∧ (φ U ψ))) at t means (ψ ∨ (φ ∧ (φ U ψ))) at t+1.
- If s = t+1: ψ(t+1). Left disjunct.
- If s > t+1: φ(t+1) (from guard, since t+1 ∈ (t,s)), and φ U ψ at t+1 (same witness s, guard (t+1,s) ⊆ (t,s)). Right disjunct.
- SOUND.

**Soundness of strict until_intro_strict**: `X(ψ ∨ (φ ∧ (φ U ψ))) at t → (φ U ψ) at t`.
- X(ψ ∨ (φ ∧ (φ U ψ))) at t means at t+1: ψ(t+1) or (φ(t+1) ∧ (φ U ψ)(t+1)).
- Case ψ(t+1): Take witness s = t+1 > t. Guard (t, t+1) = ∅. Done.
- Case φ(t+1) ∧ (φ U ψ)(t+1): The inner Until gives s' > t+1, ψ(s'), φ on (t+1, s'). Extend: witness s', guard (t, s') has φ at t+1 and φ on (t+1, s'). Done.
- SOUND.

### Does the Backward Truth Lemma Resolve?

YES. Under strict Until with X-based axioms, the backward direction uses induction on witness distance k = s - t (a positive integer, since s > t on ℤ).

**Goal**: Given s > t, ψ true at s, φ true on (t, s), prove `φ U ψ ∈ mcs(t)`.

**Base case (k = 1, s = t+1)**:
- ψ true at t+1 → ψ ∈ mcs(t+1) by IH on subformula ψ.
- So `ψ ∨ (φ ∧ (φ U ψ)) ∈ mcs(t+1)`.
- Need `X(ψ ∨ (φ ∧ (φ U ψ))) ∈ mcs(t)`, i.e., the X-content backward direction: `χ ∈ mcs(t+1) → X(χ) ∈ mcs(t)`.
- This follows from the chain's Succ relation: mcs(t) is the predecessor of mcs(t+1), and the X truth lemma backward direction.
- Apply until_intro_strict: `φ U ψ ∈ mcs(t)`.

**Inductive step (k > 1, s = t + k)**:
- φ true at t+1 (from guard) → φ ∈ mcs(t+1) by IH on subformula.
- φ U ψ semantically true at t+1 (same witness s, distance k-1) → `φ U ψ ∈ mcs(t+1)` by IH on distance.
- So `φ ∧ (φ U ψ) ∈ mcs(t+1)`, hence `ψ ∨ (φ ∧ (φ U ψ)) ∈ mcs(t+1)`.
- By X backward: `X(ψ ∨ ...) ∈ mcs(t)`.
- By until_intro_strict: `φ U ψ ∈ mcs(t)`.

**The key difference from the G-based approach**: The X-based axiom only requires information about time t+1 (the immediate successor), not ALL future times j ≥ t. This makes the induction well-founded and each step requires only the IH at distance k-1.

### What About the X Truth Lemma Backward Direction?

The one remaining technical challenge: proving `χ ∈ mcs(t+1) → X(χ) ∈ mcs(t)`, where X = ⊥ U.

Under strict Until, `X(χ) = ⊥ U χ` at t means ∃ s > t, χ(s) ∧ ⊥ on (t,s), i.e., χ(t+1).

For the backward X truth lemma: `χ ∈ mcs(t+1) → (⊥ U χ) ∈ mcs(t)`.

The dovetailed chain has mcs(t) and mcs(t+1) related by the Succ relation. The Succ relation (SuccRelation.lean) gives `g_content(mcs(t)) ⊆ mcs(t+1)`. For backward X propagation, we need the reverse: something in mcs(t+1) induces X-content in mcs(t).

**Approach via contradiction**: Assume `¬(⊥ U χ) ∈ mcs(t)`. On ℤ, ¬(⊥ U χ) at t means ¬χ(t+1) (since X(χ) ↔ χ(t+1) on ℤ). So `¬χ ∈ mcs(t+1)` should follow. But we have χ ∈ mcs(t+1). Contradiction.

The gap: getting from `¬(⊥ U χ) ∈ mcs(t)` to `¬χ ∈ mcs(t+1)` requires the FORWARD direction of the X truth lemma: `X(¬χ) ∈ mcs(t) → ¬χ ∈ mcs(t+1)`. But we don't have `X(¬χ)` — we have `¬X(χ)`. We need `¬X(χ) ↔ Y(¬χ)` (where Y is the previous-step operator, defined via Since).

On ℤ: `¬(⊥ U χ)` at t ↔ ¬χ(t+1) ↔ Y-dual... Actually, the negation of `∃ s > t, χ(s) ∧ ⊥ on (t,s)` is `∀ s > t, ¬χ(s) ∨ ∃ r ∈ (t,s), ¬⊥(r)`. On ℤ, s = t+1 gives `¬χ(t+1) ∨ ∃ r ∈ (t, t+1), True`. But (t, t+1) on ℤ is empty, so: `¬χ(t+1)`. For s > t+1, the guard (t,s) is non-empty so ¬⊥ holds trivially at some r. So the only constraint is from s = t+1: `¬χ(t+1)`.

So semantically, `¬X(χ)` at t ↔ `¬χ(t+1)`. We can use the discreteness axiom `disc_next: F(⊤) → ⊥ U ⊤` to relate X to F. Actually, the key axiom needed is:

```
¬(⊥ U χ) → G(¬χ)    (WRONG — too strong)
```

No. We need: `¬(⊥ U χ) ↔ ¬χ at t+1`. This is captured by: on ℤ, `⊥ U χ ↔ X(χ)`, and the dual `¬X(χ) ↔ ¬χ(t+1)`.

The actual mechanism: the Succ relation in the chain construction guarantees that `g_content(mcs(t)) ⊆ mcs(t+1)`. For the backward direction, we can use the chain's specific construction: `f_content(mcs(t)) ⊆ mcs(t+1)` or the Lindenbaum extension includes all deferred obligations.

**Report 10's analysis** (Finding 2 in the team research, Gap 2) identifies this as the key technical challenge. Their assessment: MEDIUM-HIGH difficulty, but solvable via strengthening the Succ relation to include backward X-content propagation, or using the discrete axiom derivation.

**My assessment**: Under the partial strict configuration, this is solvable. The forward X truth lemma (`X(χ) ∈ mcs(t) → χ ∈ mcs(t+1)`) follows directly from the Succ/g_content structure. The backward direction (`χ ∈ mcs(t+1) → X(χ) ∈ mcs(t)`) can be proved by contradiction using forward_F: assume ¬X(χ) ∈ mcs(t), derive that χ is never achieved at the next step, contradicting χ ∈ mcs(t+1). The details depend on the precise Succ construction, but the discrete axioms (disc_next, disc_prev) ensure the chain has genuine successor structure.

### temp_t Preservation

Under partial strict (reflexive G/H, strict U/S):
- `temp_t_future: G φ → φ` remains VALID (G quantifies over s ≥ t, so s = t gives φ(t)).
- `temp_t_past: H φ → φ` remains VALID.
- All 67+ call sites using temp_t are PRESERVED.
- The `forward_G` mechanism (g_content inclusion for s ≥ t) remains unchanged.
- The `backward_H` mechanism similarly unchanged.

**This is the central advantage of partial strict over fully strict**: the massive T-axiom removal cascade identified in Report 10 (Finding 3, rank 3: "HIGH effort") is entirely avoided.

### What Changes vs What Stays

| Component | Changes? | Details |
|-----------|----------|---------|
| Truth.lean G/H clauses | NO | Still ≤ |
| Truth.lean U/S clauses | YES | Change ≤ to < for witness bound |
| Axioms.lean temp_t | NO | Preserved |
| Axioms.lean until/since unfold/intro/induction | YES | Replace with X-based versions |
| Soundness.lean temp_t validity | NO | Still valid |
| Soundness.lean U/S axiom validity | YES | Reprove for new axioms |
| CanonicalConstruction forward_G/backward_H | NO | Still uses ≤ |
| CanonicalConstruction until/since truth lemma | YES | Rewrite using distance induction |
| DovetailedChain.lean | MINOR | until_unfold_in_mcs references change |
| SuccRelation.lean | MINOR | Add X-successor property |
| 67+ temp_t call sites | NO | All preserved |
| Perpetuity module | NO | always = H ∧ G still works with reflexive G/H |

### Literature Support

The partial strict configuration (reflexive G/H with strict U/S) is the standard configuration in:

1. **Burgess (1982)**: Original Since/Until axiomatization uses reflexive G/H (called "always") with Until that has a strict future witness requirement. Burgess's system explicitly includes both G φ → φ and the Until axioms.

2. **Xu (1988)**: Simplification of Burgess. Uses the same reflexive/strict split.

3. **Gabbay, Hodkinson, Reynolds (1994)**: Temporal Logic: Mathematical Foundations. Chapter on discrete temporal logic uses reflexive G with strict Until as the default configuration.

The fully strict configuration (strict everything) is studied by Reynolds (1992, 1996) and Venema (1993), but it is specifically motivated by dense orders (ℝ, ℚ) where the T-axiom creates complications with irreflexivity rules. For ℤ, the partial strict configuration is simpler and equally complete.

### Mathematical Costs

**Loss**: The equivalence `F(ψ) ↔ ⊤ U ψ` changes. Under reflexive Until, `⊤ U ψ` at t means `∃ s ≥ t, ψ(s)`, which equals `F(ψ) ∨ ψ(t)` (since F is reflexive). Under strict Until, `⊤ U ψ` at t means `∃ s > t, ψ(s)`, which equals `F(ψ) \ {t}` ... wait, F is reflexive, so `F(ψ)` at t means `∃ s ≥ t, ¬¬ψ(s)`. Hmm, let me reconsider.

Under reflexive G: `F(ψ) = ¬G(¬ψ)` at t ⟺ `∃ s ≥ t, ψ(s)` (since G is ∀ s ≥ t).

Under strict Until: `⊤ U ψ` at t ⟺ `∃ s > t, ψ(s)` (strict witness).

So `F(ψ) ⟺ ψ ∨ (⊤ U ψ)` — F includes the present, strict Until excludes it. The bridge axiom `F(ψ) → ⊤ U ψ` becomes UNSOUND (F(ψ) could hold because ψ(t), but ⊤ U ψ requires a strict future witness).

**This means**: The F_until_equiv and P_since_equiv axioms must be MODIFIED:
```
F(ψ) → ψ ∨ (⊤ U ψ)    -- new bridge
(⊤ U ψ) → F(ψ)          -- still sound (strict witness is a fortiori a weak witness)
```

Or equivalently, just define X = ⊥ U and use `F(ψ) ↔ ψ ∨ X(F(ψ))` as a derived fact.

**Other costs**: The `until_connectedness` and `since_connectedness` axioms need reverification under strict semantics. The linearity axioms should remain sound (strict witnesses are ordered the same way as non-strict ones).

## Recommended Approach

**Partial strict (strict U/S with reflexive G/H)** is strongly recommended over:

1. **Continuing with half-open**: The backward blocker is a genuine mathematical impossibility given the unsoundness of until_unfold. No amount of clever proof strategy will overcome an unsound axiom.

2. **Fully strict**: Resolves the blocker but at enormous cost (67+ temp_t call sites, Perpetuity module rewrite, fundamental change to G/H semantics). The team research (Report 10) estimates 60-90 hours.

**Partial strict estimated effort**:
- Phase 1: Change Until/Since semantics (Truth.lean: 4 lines) — 0.5 hours
- Phase 2: Replace Until/Since axioms with X-based versions — 4-6 hours
- Phase 3: Prove soundness for new axioms — 4-6 hours
- Phase 4: Add X-successor properties to chain construction — 6-10 hours
- Phase 5: Rewrite Until/Since truth lemma backward direction — 8-12 hours
- Phase 6: Update bridge axioms (F_until, P_since) — 2-3 hours
- Phase 7: Fix downstream references to until_unfold_in_mcs — 4-6 hours
- **Total: 30-45 hours** (roughly half the fully strict estimate)

The key advantage: everything outside the Until/Since system (G, H, Box, temp_t, temp_a, temp_4, temp_l, forward_G, backward_H, Perpetuity, LinearityDerivedFacts) remains UNTOUCHED.

## Confidence Levels

| Finding | Confidence | Basis |
|---------|------------|-------|
| Half-open backward blocker is genuine obstruction | HIGH | Mathematical argument + soundness analysis of until_unfold |
| U-Induction cannot help backward direction | HIGH | Direction analysis (forward-only tool) |
| Dovetailed chain doesn't help | HIGH | Chain provides forward_G/forward_F only |
| Partial strict resolves backward blocker | HIGH | Constructive proof sketch via distance induction |
| Partial strict preserves temp_t | HIGH | Semantic definition unchanged for G/H |
| Effort estimate 30-45 hours | MEDIUM | Depends on X truth lemma backward difficulty |
| X truth lemma backward is solvable | MEDIUM-HIGH | Contradiction approach via forward_F, but details need verification |
