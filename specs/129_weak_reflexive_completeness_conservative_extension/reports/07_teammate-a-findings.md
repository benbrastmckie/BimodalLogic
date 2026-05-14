# Teammate A Findings: Verification of Multi-Relation Analysis (Report 06)

**Task**: 129 — weak_reflexive_completeness_conservative_extension
**Date**: 2026-05-14
**Angle**: Primary — correctness verification of report 06 claims
**Session**: sess_1778772971_e25ab1

---

## Key Findings

### 1. Report 06's Core Claim Is Correct: Path 2 Has a Fatal Flaw

Report 06 argues that the single-relation approach (Path 2) fails because `Gψ ∈ x` does not imply `ψ ∧ Gψ ∈ x`, which would be needed to get `ψ ∈ g_w_content x` and hence `ψ ∈ y.val` via `reflCanR x y`. I verified this is correct by:

**a) Exhaustive axiom check.** The TM axiom system (Axioms.lean) has no `Gφ → φ` (temporal T) axiom. The temporal axioms involving `all_future` are:
- `temp_k_dist`: `G(φ→ψ) → (Gφ → Gψ)` — distributes G over implication
- `temp_4`: `Gφ → GGφ` — G-propagation (transitivity)  
- `serial_future`: `G(U(⊤,⊥))` — discreteness
- Z1: `G(Gφ→φ) → (FGφ→Gφ)` — backward induction (requires `G(Gφ→φ)` antecedent)
- BX2/BX3: G-distribution over Until

None yield `Gψ → ψ`. There is no derivation chain from `Gψ ∈ x` to `ψ ∈ x` in strict TM.

**b) Semantic counterexample.** Consider the two-point Z-model `{0, 1}` with `0 < 1`. Let `ψ` be false at 0, true at 1. Then `Gψ` holds at 0 (all strict successors satisfy ψ), but `ψ` fails at 0. The MCS corresponding to point 0 would contain `Gψ` but not `ψ`. So `g_content` ⊄ `g_w_content` in general, confirming the impossibility.

**c) Z1 cannot help.** Z1 says `G(Gφ→φ) → (FGφ→Gφ)`. To use Z1 to derive `Gψ→ψ`, you'd need `G(Gψ→ψ)` as a premise. But `Gψ→ψ` is not a theorem (counterexample above), so `G(Gψ→ψ)` is not in every MCS.

**d) No clever reformulation works.** The only way to make a single-relation approach work would be to define R via `g_content` (instead of `g_w_content`), but then R is not reflexive: `g_content x ⊆ x.val` would require `Gψ ∈ x → ψ ∈ x` for all ψ. This fails at our counterexample point. So you'd lose the reflexivity that the Reynolds construction requires.

### 2. The Multi-Relation Approach Works Correctly

**G-forward is trivially correct.** In TruthLemma.lean:244-248, `G_forward_mcs` proves: given `Gψ ∈ x.val`, we have `ψ ∈ g_content x` (by definition: `g_content x = {ψ | Gψ ∈ x.val}`). Then `tempR_fwd x y` (= `g_content x ⊆ y.val`) gives `ψ ∈ y.val` immediately. This is 4 lines of Lean, no sorry.

**G-backward works.** In TruthLemma.lean:256-304, `G_backward_mcs` extends `{¬ψ} ∪ g_content x` to MCS y via Lindenbaum. The key step: `g_content x ⊆ y.val` gives `tempR_fwd x y` directly (no need for `y ≠ x`). This is 48 lines, sorry-free.

**H-forward and H-backward are sorry-free.** Lines 315-377 prove both via the mirror construction using `h_content` and `tempR_bwd`.

**Box (both directions) is sorry-free.** Lines 117-238 prove both using `canS5R` as a separate relation from temporal relations.

**No hidden issue with two relations.** The truth lemma evaluates temporal connectives via `tempR_fwd`/`tempR_bwd` and modal connectives via `canS5R`. These are cleanly separated. The bridge lemma `tempR_fwd_imp_reflCanR` (lines 168-184) ensures that temporal successors are also frame-preorder successors, which is sufficient for the Reynolds construction: any truth-relevant point lies within the `reflCanR` preorder.

### 3. Reynolds Construction Doesn't Break

**Concern**: Does the Reynolds Theorem 15 argument fail if the truth lemma doesn't directly use `reflCanR`?

**Answer**: No. The Reynolds construction needs three things:
1. A reflexive preorder on the domain (for "good/very good" + contemporaneous equivalence)
2. Prior-UZ/SZ validity (for gap elimination)  
3. k-equivalence preservation under ordered sums (Doets Lemma 1.4)

`reflCanR` provides (1): it's proved reflexive (reflCanR_refl) and transitive (reflCanR_trans). The truth lemma is needed to show the model satisfies Prior-UZ/SZ instances — but this depends on formula membership in MCS, not on which relation the truth lemma uses. Prior-UZ says `Fψ → U(ψ, ¬ψ)` — this holds in every MCS because it's an axiom. The truth lemma connects MCS membership to semantic truth via `tempR_fwd`, and `tempR_fwd_imp_reflCanR` connects that to the frame preorder.

The Reynolds argument operates at the monadic first-order level (k-types, ordered sums). It doesn't care about the specific relation used for temporal truth evaluation — it cares about the frame structure (provided by `reflCanR`) and that formulas have the right truth values (provided by the truth lemma + `tempR_fwd`).

### 4. Sorry Inventory: Report 06 Is Correct (9 sorries)

Verified by `grep -c "^  sorry"` across all WeakCanonical files:

| File | Sorries | Locations |
|------|---------|-----------|
| TruthLemma.lean | 6 | Lines 426, 454, 490, 497, 551, 566 |
| ReflexiveCanonical.lean | 1 | Line 337 (canS5R_symm) |
| IntegerModel.lean | 1 | Line 100 (canonical_model_is_good) |
| NEquivalence.lean | 1 | Line 67 (ktype_finite) |
| **Total** | **9** | |

The 6 TruthLemma sorries break down as:
- until_forward_mcs guard (426)
- until_backward_mcs body (454)
- since_forward_mcs guard (490)
- since_backward_mcs body (497)
- truth_lemma untl backward (551)
- truth_lemma snce backward (566)

Note: Report 06's table (Section 3) lists these same 9 but attributes sorry #5 and #6 to the truth_lemma untl/snce backward cases. In the actual code, sorries #1/#3 (guard conditions inside forward proofs) and #5/#6 (truth_lemma wrapper backward) are closely related — #5/#6 exist because the untl/snce backward cases in `truth_lemma` delegate to `until_backward_mcs`/`since_backward_mcs`, which are themselves sorry'd. If those were proved, #5 and #6 would still need separate work (the truth_lemma backward wrapping). Report 06's inventory is accurate.

### 5. Literature Precedent for Multi-Relation Separation

**Reynolds 1994 does not use the multi-relation approach** — Reynolds works with a Burgess-Xu model (not a canonical model) where the accessibility relation is the order `<` of the temporal structure. There is no separate frame preorder.

**However**, the Doets 1989 framework implicitly supports it. Doets's conservation theorems work at the monadic first-order level, where the frame structure (carrier + order) is separate from formula satisfaction. The Doets/Reynolds argument transfers between models preserving monadic k-types — the temporal truth definition is absorbed into the monadic translation (table of a formula). So the separation between "frame structure relation" and "truth-evaluation relation" is implicit in the monadic first-order abstraction layer.

**The canonical model literature** (Blackburn, de Rijke, Venema 2002, Ch. 4) standardly defines the canonical accessibility for modal logic G as `R_G(x,y) ↔ {ψ | Gψ ∈ x} ⊆ y`, which is exactly `g_content`-based (= `tempR_fwd`). The idea of defining a separate reflexive relation via `g_w_content` for frame-theoretic purposes while keeping `g_content` for truth evaluation is a natural extension of the standard approach. It is not "standard" in the sense of appearing explicitly in textbooks, but it is mathematically sound.

### 6. One Subtle Point Report 06 Gets Wrong

Report 06 (Section 4.4) claims `tempR_fwd x y → y ≠ x` is "NOT provable" because "`tempR_fwd x x` can hold for some x." This is actually more nuanced:

`tempR_fwd x x` means `g_content x ⊆ x.val`, i.e., `∀ψ, Gψ ∈ x → ψ ∈ x`. This is *consistent* — there exist MCS where this holds (e.g., an MCS containing only finitely many G-formulas where each `Gψ → ψ` instance is also in the MCS). But it's also *consistent that it fails* — the two-point counterexample gives an MCS where `Gψ ∈ x` but `ψ ∉ x`.

So `tempR_fwd x x` holds for SOME x but not ALL x. Report 06's claim that `tempR_fwd x y → y ≠ x` is not provable is correct, but the reasoning ("tempR_fwd x x can hold for some x") deserves the caveat that it also fails for some x. This doesn't affect any conclusions.

---

## Recommended Approach

**Continue with Path 1 (multi-relation)**. The mathematical argument is airtight:

1. `tempR_fwd`/`tempR_bwd` give trivial truth lemma for G/H (proved, sorry-free)
2. `reflCanR` gives reflexive preorder for Reynolds (proved, sorry-free)
3. Bridge `tempR_fwd_imp_reflCanR` connects them (proved, sorry-free)
4. The remaining 6 TruthLemma sorries (Until/Since) are independent of the relation architecture choice — they require chain construction infrastructure regardless

**Drop the equivalence lemma**: Report 06 correctly argues that proving `tempR_fwd x y ↔ (reflCanR x y ∧ y ≠ x)` is neither needed nor true in general. Don't spend time on it.

**Priority**: Close the Until/Since truth lemma sorries. These are the real blockers, not the relation architecture.

---

## Evidence/Examples

- **ReflexiveCanonical.lean:93-107**: `reflCanR_refl` proof — 14 lines, clean
- **TruthLemma.lean:243-248**: `G_forward_mcs` — 4 lines via `tempR_fwd` definition
- **TruthLemma.lean:256-304**: `G_backward_mcs` — 48 lines, sorry-free, Lindenbaum construction
- **Axioms.lean**: No `Gφ → φ` axiom exists (confirmed by exhaustive grep)
- **Counterexample**: Two-point Z-model with `ψ` false at 0, true at 1 refutes `Gψ → ψ`

---

## Confidence Level

**HIGH** — The core mathematical claim (Path 2 has a fatal flaw, Path 1 is correct) is verified from:
1. Direct code inspection (definitions match report's description exactly)
2. Exhaustive axiom check (no derivation of `Gψ → ψ` is possible)
3. Semantic counterexample (constructs explicit model refuting the needed implication)
4. Proven Lean code (G forward/backward already sorry-free under multi-relation)
5. Sorry count independently verified (9 matches report)

The only area of medium confidence is the literature precedent question — the multi-relation separation is mathematically novel (not found explicitly in the references), but this is a feature, not a concern.
