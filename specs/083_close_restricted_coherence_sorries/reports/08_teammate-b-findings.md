# Teammate B Findings: Alternative Approaches and Risk Assessment

## Reflexive vs Strict Semantics Analysis

### The Core Mismatch

The truth definition for Until (`Truth.lean:126-127`) uses **reflexive** (closed-interval) semantics:

```
φ U ψ at t  :=  ∃ s, t ≤ s ∧ ψ(s) ∧ ∀ r, t ≤ r → r ≤ s → φ(r)
```

The interval `[t, s]` is closed on BOTH ends. This means:
- At `r = t`: we need `φ(t)` (the "holder" must hold at the current time)
- At `r = s`: we need `φ(s)` (the "holder" must hold at the witness time too)
- At `s`: we need BOTH `ψ(s)` AND `φ(s)`

The 6 axioms (`Axioms.lean:459-523`) were written assuming **strict** Until semantics where `ψ` can hold at `t` without requiring `φ(t)`, and the unfolding `G(φ U ψ)` propagates correctly. Under reflexive semantics, they break.

### Specific Unsoundness Analysis

**until_intro** (`ψ ∨ (φ ∧ G(φ U ψ)) → φ U ψ`):
- First disjunct: `ψ(t) → (φ U ψ)(t)`. Take witness `s = t`. Need `ψ(t)` (have it) AND `φ(t)` (DON'T have it). **UNSOUND.**
- Second disjunct: `φ(t) ∧ G(φ U ψ)(t) → (φ U ψ)(t)`. G is reflexive so `(φ U ψ)(t)` follows from `G(φ U ψ)(t)`. The second disjunct is actually TRIVIALLY true (the `φ(t)` conjunct is unused). But the first disjunct is the problem.

**until_unfold** (`(φ U ψ) → ψ ∨ (φ ∧ G(φ U ψ))`):
- Given witness `s` for `(φ U ψ)(t)`, if `s = t` then `ψ(t)` holds (first disjunct OK).
- If `s > t`, then `φ(t)` holds. But `G(φ U ψ)(t)` requires `(φ U ψ)(t')` for ALL `t' ≥ t`. At `t' = s+1`, we need a NEW witness beyond `s`, which may not exist. **UNSOUND.**

**until_induction** (`G(ψ → χ) ∧ G((φ ∧ χ) → G(χ)) → ((φ U ψ) → χ)`):
- This needs `χ(t)` from the Until witness. The premise `G((φ ∧ χ) → G(χ))` gives forward propagation of `χ`, but to get `χ(t)` initially requires backward propagation from the witness `s` back to `t`. The premise structure doesn't support this. **UNSOUND.**

### What the Dovetailed Chain Actually Uses

Critical finding: the dovetailed chain (`DovetailedChain.lean`) uses these "unsound" axioms **only at the proof-theoretic (MCS) level**, not at the semantic level:

1. `until_unfold_in_mcs` (line 515 of SuccRelation.lean): derives `ψ ∈ M ∨ (φ ∈ M ∧ G(φ U ψ) ∈ M)` from `φ U ψ ∈ M`
2. `until_induction` axiom (line 584 of DovetailedChain.lean): used to derive contradiction in `forward_canonical_no_perp_deferral`
3. `since_unfold_in_mcs` and `since_induction`: symmetric backward uses

These are **proof-theoretic consequences**: they follow from the axioms being IN the proof system, regardless of whether those axioms are semantically sound. The MCS contains all derivable formulas, so if `until_unfold` is an axiom, its consequences hold in every MCS. **This is correct and sound as proof theory.**

The problem is ONLY in Soundness.lean where we try to prove these axioms are semantically valid.

## Truth Lemma Case Analysis

### The Sorry at CanonicalConstruction.lean:929-930

```lean
| untl phi psi ih_phi ih_psi => sorry
| snce phi psi ih_phi ih_psi => sorry
```

The goal is: for `φ U ψ ∈ subformulaClosure(root)`,
```
(φ U ψ) ∈ fam.mcs t  ↔  ∃ s, t ≤ s ∧ truth_at ... s ψ ∧ ∀ r, t ≤ r → r ≤ s → truth_at ... r φ
```

### Forward Direction (MCS membership → semantic truth)

**Available**: `(φ U ψ) ∈ fam.mcs(t)`. Need: `∃ s ≥ t` with `ψ` true at `s` and `φ` true on `[t, s]`.

**Infrastructure**: The dovetailed chain provides:
- `forward_F`: If `F(ψ) ∈ fam.mcs(t)`, then `∃ s ≥ t, ψ ∈ fam.mcs(s)`
- `backward_P`: symmetric
- `forward_G`: If `G(ψ) ∈ fam.mcs(t)`, then `∀ s ≥ t, ψ ∈ fam.mcs(s)`

**Strategy**: From `(φ U ψ) ∈ fam.mcs(t)`, by `until_unfold_in_mcs`, either:
- `ψ ∈ fam.mcs(t)`: witness is `s = t`. Need `φ(t)` semantically. But `until_unfold_in_mcs` in the `ψ` case doesn't give us `φ`. However, the REFLEXIVE semantics requires `φ(t)` even when `s = t`. So we need `φ ∈ fam.mcs(t)` too.

  Wait -- from the semantics, `(φ U ψ)(t)` with witness `s = t` requires `∀ r, t ≤ r → r ≤ t → φ(r)`, which is just `φ(t)`. But from `(φ U ψ) ∈ MCS` we get `ψ ∈ MCS ∨ (φ ∈ MCS ∧ ...)`. In the `ψ` case we don't necessarily have `φ`.

  **BLOCKER**: Under reflexive semantics, `(φ U ψ)(t)` implies `φ(t)` (take `r = t`). So `φ U ψ → φ` should be derivable. But is it? From `until_unfold`: `(φ U ψ) → ψ ∨ (φ ∧ G(φ U ψ))`. In the `ψ` case, we don't get `φ`. If `until_unfold` is the only way to decompose Until in the proof system, then `φ U ψ → φ` is NOT derivable, meaning `(φ U ψ) ∈ MCS` does NOT imply `φ ∈ MCS`. But semantically it SHOULD (under reflexive semantics). **This is the fundamental coherence gap.**

- `φ ∈ fam.mcs(t) ∧ G(φ U ψ) ∈ fam.mcs(t)`: By `forward_G`, `(φ U ψ) ∈ fam.mcs(s)` for all `s ≥ t`. By the dovetailed chain's forward_F mechanism (via F_until_equiv), the Until obligation is eventually resolved. But we need an actual witness `s` where `ψ` appears. This requires converting the Until persistence into an F-witness, which the dovetailed chain does via `forward_dovetailed_forward_F`.

**Forward direction feasibility**: Partially feasible. The deferral case (`φ ∧ G(φ U ψ)`) can likely be handled using forward_F + inductive hypothesis. The base case (`ψ`) has a gap: we can't extract `φ(t)` from the proof system.

### Backward Direction (semantic truth → MCS membership)

**Available**: `∃ s ≥ t, ψ true at s, φ true on [t,s]`. Need: `(φ U ψ) ∈ fam.mcs(t)`.

**This requires `until_intro`**: the axiom `ψ ∨ (φ ∧ G(φ U ψ)) → φ U ψ` is the ONLY way to PUT `φ U ψ` into an MCS. But this axiom is unsound.

**Could we bypass until_intro?** No. To establish `(φ U ψ) ∈ MCS` without an introduction axiom, we'd need some other derivation rule that concludes `φ U ψ`. There is no such rule in the current proof system. The backward direction is **fundamentally blocked** by the axiom unsoundness.

## Alternative Approaches

### Approach A: Reformulate Axioms for Reflexive Semantics

**Description**: Modify the 6 unsound axioms to be sound under reflexive Until/Since.

**Reformulated axioms**:
- `until_intro_reflexive`: `(ψ ∧ φ) ∨ (φ ∧ G(φ U ψ)) → φ U ψ`
  (First disjunct now requires BOTH `ψ` and `φ` at `t`, matching the closed-interval requirement)
- `until_unfold_reflexive`: `(φ U ψ) → (ψ ∧ φ) ∨ (φ ∧ G(φ U ψ))`
  (Hmm, but this is still unsound: in the deferral case, `G(φ U ψ)` requires Until at ALL future times, but the original witness only covers `[t, s_w]`)

Actually, even the unfold is tricky. The issue is that `G(φ U ψ)` at `t` means `(φ U ψ)` at EVERY `s ≥ t`, but the original Until only guarantees a witness up to `s_w`. For `s' > s_w`, there's no witness.

A better reformulation for unfold:
- `until_unfold_reflexive`: `(φ U ψ) → (ψ ∧ φ) ∨ (φ ∧ F(φ U ψ))`
  (Use `F` instead of `G`: the Until persists at SOME future time, not all)

But `F(φ U ψ)` is weaker than `G(φ U ψ)`, which means the deferral argument in the dovetailed chain (which relies on `G(φ U ψ)` propagating through g_content) would break.

**Pros**: Mathematically correct approach; fixes the root cause
**Cons**: Cascading changes throughout the codebase; the dovetailed chain's sorry-free proof relies on the current axiom forms; estimated 2000+ lines of changes
**Risk**: HIGH. The dovetailed chain is the crown jewel (sorry-free forward_F/backward_P). Reformulating axioms would invalidate it.
**Effort**: Very high (weeks)

### Approach B: Change Semantics to Strict Until

**Description**: Change `truth_at` for Until from `t ≤ s` to `t < s` (strict future witness).

```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
```

This is the half-open interval `[t, s)`: `φ` holds on `[t, s)` and `ψ` holds at `s`.

**Under this semantics**:
- `until_intro`: `ψ(t)` case: Need witness `s > t`. But `ψ(t)` only tells us about time `t`, not any `s > t`. Still problematic unless we have `F(ψ)`.

Actually, the standard strict Until is: `∃ s > t, ψ(s) ∧ ∀ r ∈ [t, s), φ(r)`. The first disjunct `ψ → φ U ψ` is STILL unsound: `ψ(t)` doesn't give us any `s > t` with `ψ(s)`.

The typical axiomatization for strict Until uses a DIFFERENT unfold:
- `(φ U ψ) ↔ F(ψ) ∧ (ψ ∨ (φ ∧ X(φ U ψ)))` (where X is "next")

This requires a next-time operator, which doesn't exist in the continuous setting.

**Pros**: Would align with some standard references
**Cons**: G/H are currently reflexive (matching T-axioms); mixing reflexive G/H with strict U/S creates asymmetry; doesn't actually fix the axiom unsoundness without major reformulation
**Risk**: HIGH. Breaks existing reflexive infrastructure.
**Effort**: High

### Approach C: Weaker Reflexive Until (Standard Kamp Semantics)

**Description**: Use the Kamp-style Until where the interval is half-open: `φ` holds on `[t, s)` and `ψ` holds at `s`, but the witness CAN be `t` itself.

```lean
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
```

Key difference from current: `r < s` instead of `r ≤ s`. The witness `s` only needs `ψ(s)`, not `φ(s)`.

**Under this semantics**:
- `until_intro`: `ψ(t)` case: witness `s = t`, need `ψ(t)` (have it), need `∀ r, t ≤ r → r < t → φ(r)` (vacuously true since no `r` satisfies `t ≤ r ∧ r < t`). **SOUND!**
- `until_unfold`: `(φ U ψ)(t)` with witness `s`. If `s = t`: `ψ(t)` (first disjunct). If `s > t`: `φ(t)` (from `r = t`, `t ≤ t ∧ t < s`). Need `G(φ U ψ)(t)`: for any `t' ≥ t`, take witness `s` again if `t' ≤ s`. If `t' > s`... **STILL UNSOUND** for the same reason. The original witness doesn't extend.

Hmm, so `until_unfold` with `G` in the deferral is unsound regardless. The problem is fundamental: `G(φ U ψ)` is too strong.

**If we change the unfold to use `F` instead of `G`**: `(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`. This IS sound under half-open semantics. But then the dovetailed chain's g_content propagation breaks.

**Pros**: Fixes until_intro; standard semantics
**Cons**: Doesn't fix until_unfold with G; dovetailed chain relies on G-based deferral
**Risk**: MEDIUM-HIGH
**Effort**: Medium (semantics change is localized, but downstream effects are wide)

### Approach D: Prove Truth Lemma Without Introduction Axiom

**Description**: Find an alternative proof strategy for the backward direction that doesn't use `until_intro`.

For the backward direction, we have `∃ s ≥ t, ψ true at s, φ true on [t, s]`. By IH:
- `ψ ∈ fam.mcs(s)`
- `φ ∈ fam.mcs(r)` for all `r ∈ [t, s]`

We need `(φ U ψ) ∈ fam.mcs(t)`.

**Without until_intro**, the only way is to show `neg(φ U ψ) ∉ fam.mcs(t)` (by MCS completeness).

Suppose `neg(φ U ψ) ∈ fam.mcs(t)`. Can we derive a contradiction?

`neg(φ U ψ)` means `¬(φ U ψ)`. In the semantics, this means there is NO witness. But we HAVE a witness semantically. The question is whether we can translate this into proof-theoretic contradiction.

This would require proving that `neg(φ U ψ)` in the MCS is inconsistent with `ψ ∈ fam.mcs(s)` and `φ ∈ fam.mcs(r)` for `r ∈ [t, s]`. But MCS membership at DIFFERENT time points in the SAME family doesn't directly interact proof-theoretically without temporal axioms connecting them.

The G/H infrastructure connects different time points: if `G(α) ∈ fam.mcs(t)` then `α ∈ fam.mcs(s)` for `s ≥ t`. But going the other direction (from `α ∈ fam.mcs(s)` for all `s ≥ t` to `G(α) ∈ fam.mcs(t)`) uses `temporal_backward_G`, which is available.

Strategy sketch:
1. From `neg(φ U ψ) ∈ fam.mcs(t)`, by G-propagation (if `G(neg(φ U ψ))` is derivable from `neg(φ U ψ)`...) -- but this doesn't follow without specific axioms about negation of Until.

**This approach is unlikely to work** without axioms that decompose `neg(φ U ψ)` into temporal statements about `φ` and `ψ`.

**Pros**: Avoids axiom changes
**Cons**: No clear proof strategy; likely impossible without new axioms
**Risk**: VERY HIGH (likely infeasible)
**Effort**: Unknown/unbounded

### Approach E: Half-Open Semantics + F-Based Unfold (Recommended)

**Description**: Combine Approach C's half-open interval with a reformulated unfold using `F` instead of `G`:

1. Change semantics to half-open: `∃ s, t ≤ s ∧ ψ(s) ∧ ∀ r, t ≤ r → r < s → φ(r)`
2. Reformulate unfold: `(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`
3. Reformulate intro: `ψ ∨ (φ ∧ F(φ U ψ)) → φ U ψ` (weaker than before: F instead of G)
4. Reformulate induction: adjust to work with F-based deferral

**Soundness under half-open semantics**:
- `until_intro`: `ψ(t)` case: witness `s = t`, vacuously true on `[t, t)`. SOUND.
- `until_intro`: `φ(t) ∧ F(φ U ψ)(t)` case: `∃ s > t, (φ U ψ)(s)`, so `∃ s' ≥ s > t, ψ(s') ∧ φ on [s, s')`. Combined with `φ(t)`, we get `φ` on `[t, s') ∪ {t}`. But we need `φ` on `[t, s')` which requires `φ` on `(t, s)` too. By... hmm, `F(φ U ψ)(t)` gives us `(φ U ψ)` at some `s > t`, which gives `φ` on `[s, s')`. We don't have `φ` on `(t, s)`. **STILL PROBLEMATIC.**

This suggests the F-based approach needs an intermediate step operator (like next-time `X`).

**For discrete (Int) domains**: We DO have `X` (successor). The unfold becomes:
- `(φ U ψ) ↔ ψ ∨ (φ ∧ X(φ U ψ))` where `X(α)` means `α` at `t + 1`

This is the standard axiomatization for LTL on integers!

**Pros**: Standard, well-studied, known to be sound and complete
**Cons**: Only works for discrete domains (Int); `X` operator needs to be added or simulated
**Risk**: MEDIUM for Int; not applicable to dense domains
**Effort**: Medium-high

### Approach F: Accept Unsoundness as Proof-Theoretic Artifact

**Description**: The "unsound" axioms are only unsound SEMANTICALLY. Proof-theoretically, they define the logic. If the completeness proof goes through USING these axioms at the MCS level (which it does in the dovetailed chain), and the truth lemma can be proved directly...

Wait. The truth lemma CONNECTS proof theory to semantics. If the axioms are unsound, then the logic proves things that aren't semantically true. Completeness says "valid implies provable", but if the proof system proves invalid things, then soundness fails, which means completeness is vacuously easier (there are more provable things) but the result is meaningless.

**This is NOT a viable approach.** Soundness + Completeness must hold simultaneously for the theorem to be meaningful.

## Existing Infrastructure Inventory

| Component | File | Status | Relevance |
|-----------|------|--------|-----------|
| DovetailedFMCS | DovetailedChain.lean | Sorry-free | Core construction; provides forward_F, backward_P |
| DovetailedFMCS_forward_F | DovetailedChain.lean:1287 | Sorry-free | Forward F resolution at family level |
| DovetailedFMCS_backward_P | DovetailedChain.lean:1293 | Sorry-free | Backward P resolution at family level |
| dovetailed_bfmcs_restricted_temporally_coherent | Completeness.lean:401 | Sorry-free | Restricted temporal coherence |
| restricted_shifted_truth_lemma (atom/bot/imp/box/G/H) | CanonicalConstruction.lean:820-928 | Sorry-free | All cases except Until/Since |
| restricted_shifted_truth_lemma (untl/snce) | CanonicalConstruction.lean:929-930 | SORRY | The blocker |
| until_unfold_in_mcs | SuccRelation.lean:515 | Sorry-free | MCS-level Until decomposition |
| since_unfold_in_mcs | SuccRelation.lean:552 | Sorry-free | MCS-level Since decomposition |
| u_content / s_content | TemporalContent.lean:90-100 | Sorry-free | Until/Since content extraction |
| Succ relation | SuccRelation.lean:59 | Sorry-free | Successor relation with U-step |
| completeness_over_Int | Completeness.lean:472 | Depends on truth lemma | Final theorem |

**Key dependencies from truth lemma to completeness_over_Int**:
```
restricted_shifted_truth_lemma (untl/snce sorry)
  -> dovetailed_bundle_validity_implies_provability
    -> completeness_over_Int
      -> discrete_completeness_fc
```

## Risk Assessment Matrix

| Approach | Probability of Success | Effort | Risk Level | Breaks Existing? |
|----------|----------------------|--------|------------|-----------------|
| A: Reformulate all 6 axioms | 60% | Very High (weeks) | HIGH | Yes - dovetailed chain |
| B: Strict Until semantics | 30% | High | HIGH | Yes - G/H infrastructure |
| C: Half-open interval only | 40% | Medium | MEDIUM-HIGH | Partial |
| D: Prove without intro | 10% | Unknown | VERY HIGH | No |
| E: Half-open + F-unfold | 50% for Int only | Medium-High | MEDIUM | Yes - unfold axiom |
| F: Accept unsoundness | 0% | N/A | N/A | N/A (invalid) |

## Recommended Path Forward

### Short-term (unblock completeness_over_Int):

**The cleanest approach** is to recognize that for **discrete (Int) domains**, the standard axiomatization uses the next-time operator `X`. The current axioms are modeled on continuous-time Until, which doesn't match either strict or reflexive semantics cleanly.

**Recommended**: Change Until/Since semantics to **half-open interval** (Approach C):
```lean
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
```

This makes `until_intro` (first disjunct) sound. The unfold and induction axioms need reformulation to use `F` or next-step instead of `G`, but the dovetailed chain's MCS-level arguments remain valid because they only use proof-theoretic consequences.

**Critical insight**: The dovetailed chain's forward_F proof uses `until_unfold_in_mcs` and `until_induction` axiom **at the MCS level**. These will still be derivable (they're axioms of the proof system). The chain construction is INDEPENDENT of semantic soundness -- it's pure proof theory.

The truth lemma, however, needs semantic soundness. Specifically:
- Forward direction needs: `(φ U ψ) ∈ MCS(t) → ∃ semantic witness`
- Backward direction needs: `∃ semantic witness → (φ U ψ) ∈ MCS(t)`

With half-open semantics and the introduction axiom `ψ ∨ (φ ∧ G(φ U ψ)) → φ U ψ`:
- The first disjunct of intro BECOMES sound (ψ at t, vacuous φ condition)
- The unfold `G(φ U ψ)` in the deferral case is STILL unsound
- BUT: for the backward direction, we only need intro, not unfold
- For the forward direction, we need to decompose `(φ U ψ) ∈ MCS(t)` into a semantic witness, which uses `forward_F` from the dovetailed chain (not the unfold axiom's soundness)

**Therefore**: Changing to half-open semantics may suffice to close the truth lemma WITHOUT reformulating unfold/induction, because:
1. Forward direction: uses dovetailed chain's forward_F (sorry-free, pure proof theory)
2. Backward direction: uses until_intro which becomes sound under half-open semantics

### Long-term:

Address the 6 unsound axioms in Soundness.lean (either reformulate or prove they're sound under the corrected semantics). This is a separate task from closing the completeness sorry.

### Estimated effort for recommended approach:

1. Change `truth_at` for `untl`/`snce` to half-open interval: ~20 lines
2. Fix downstream lemmas in Truth.lean affected by the change: ~50-100 lines
3. Prove `until_intro` sound in Soundness.lean: ~30 lines
4. Close truth lemma forward direction using dovetailed chain forward_F + IH: ~100 lines
5. Close truth lemma backward direction using until_intro + IH: ~80 lines
6. Fix any broken Soundness.lean proofs (linearity, connectedness): ~50 lines

**Total**: ~300-400 lines, estimated 2-3 days of focused work.
