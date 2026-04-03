# Research Report: Task #83 — Deep Dive: Gaps, Solutions, and Root Causes for Fully Strict Semantics

**Task**: Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Mode**: Team Research (3 teammates)
**Session**: sess_1775228409_4455da
**Builds on**: Report 09 (strict vs weak semantics analysis)

## Summary

Three agents investigated the gaps identified in report 09, with particular focus on: (A) the IRR-rule / irreflexivity problem within the three-place task semantics, (B) the complete axiom system and completeness strategy under fully strict semantics, and (C) critical re-analysis of whether Boneyard failures shift under strict + Since/Until.

**The headline finding**: The three-place task relation `task_rel w d u` (parameterized by duration `d`) **dissolves the irreflexivity problem entirely**. Under strict semantics, temporal operators quantify over `d > 0` (or `d < 0`), never `d = 0`. The `nullity_identity` axiom handles `d = 0` as pure identity. No IRR rule, no bulldozing, and no changes to `canonical_task_rel` are needed. The canonical frame needs no structural changes — only the semantic evaluation clauses and axiom system change.

## Key Findings

### 1. The Three-Place Task Relation Resolves Irreflexivity (Teammate A — HIGH confidence)

From `TaskFrame.lean:93-122`, the task frame uses:
```
task_rel : WorldState → D → WorldState → Prop
nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
```

The duration parameter `d` partitions accessibility into three cases:
- **d > 0**: Forward temporal (ExistsTask) — used by strict G
- **d = 0**: Identity — governed by `nullity_identity`, never queried by strict temporal operators
- **d < 0**: Backward temporal — used by strict H

**Why no IRR rule is needed**: The standard IRR-rule problem arises because irreflexivity (`¬R w w`) is not modally definable for binary relations. But in the three-place structure, "irreflexivity" is built into the semantic clauses (`<` instead of `≤`), not into the frame. The canonical frame can have `ExistsTask M M` (reflexive at the binary level) without semantic consequence, because strict temporal operators never exercise `d = 0`. This is confirmed by Reynolds (1992, 1996) and Venema (1993): for Since/Until over discrete orders, completeness can be proved without IRR because the X/Y operators provide sufficient successor structure.

**Literature support**: Reynolds showed that S/U over ℤ can be axiomatized IRR-free. Venema's "Completeness via Completeness" extends Burgess-Xu to strict discrete orders with `F ⊤ → ⊥ U ⊤` discreteness axioms, without requiring IRR.

### 2. Complete Axiom System for Fully Strict TM (Teammate B — HIGH confidence)

Teammate B analyzed all 34 current axioms under strict semantics:

| Disposition | Count | Details |
|-------------|-------|---------|
| **Keep unchanged** | 20 | All propositional (4), all S5 modal (5), temp_k_dist, temp_4, temp_a, temp_l, temp_linearity, modal_future, temp_future, seriality (2), U/S linearity (2), U/S connectedness (2), F/P-U/S bridges (2) |
| **Remove** | 2 | temp_t_future (`G φ → φ`), temp_t_past (`H φ → φ`) |
| **Replace** | 6 | until_unfold, until_intro, until_induction, since_unfold, since_intro, since_induction |
| **Add new** | 3 | temp_a_dual (`φ → H F φ`), disc_next (`F ⊤ → ⊥ U ⊤`), disc_prev (`P ⊤ → ⊥ S ⊤`) |

**The critical replacement — X-based discrete unfold**:

The current G-based unfold/intro (`φ U ψ → ψ ∨ (φ ∧ G(φ U ψ))`) is unsound under strict semantics. The replacement uses the next-step operator X = ⊥ U:

```
φ U ψ  ↔  X(ψ ∨ (φ ∧ (φ U ψ)))
```

**Semantic verification** (Teammate B, verified by Teammate C):
- Forward: φ U ψ at t with witness s > t. If s = t+1: ψ(t+1), so X(ψ ∨ ...) holds. If s > t+1: φ(t+1) from guard, and φ U ψ at t+1 (same witness), so X(φ ∧ φ U ψ) holds.
- Backward: X(ψ ∨ (φ ∧ φ U ψ)) at t means at t+1, either ψ (take witness s=t+1) or φ ∧ φ U ψ (extend the inner witness with φ at t+1).

**New axiom `temp_a_dual`**: Under reflexive semantics, `φ → H F φ` is derivable from `temp_a` + duality. Under strict semantics, it becomes independent and is needed for past-direction completeness. Valid on ℤ: if φ(t), then for any s < t, take witness r = t for F φ at s.

**Total**: ~33 axioms (net reduction of 1 from current).

### 3. The Backward Truth Lemma Resolves Via Discrete Induction (All teammates — HIGH confidence)

This is the central payoff. Under strict semantics with X-based axioms, the backward truth lemma for Until uses **induction on witness distance k = s − t** (a natural number):

**Base case** (k = 1): ψ true at t+1. By IH on subformula ψ, ψ ∈ mcs(t+1). So mcs(t+1) contains ψ ∨ (φ ∧ φ U ψ). By the X-successor property, X(ψ ∨ ...) ∈ mcs(t), giving φ U ψ ∈ mcs(t).

**Inductive step** (k > 1): φ true at t+1 and φ U ψ true at t+1 (with witness distance k−1). By IH on distance, φ U ψ ∈ mcs(t+1). By IH on subformula φ, φ ∈ mcs(t+1). So φ ∧ (φ U ψ) ∈ mcs(t+1), hence ψ ∨ (φ ∧ φ U ψ) ∈ mcs(t+1). By X-successor, φ U ψ ∈ mcs(t).

**This is precisely the proof that was blocked under reflexive semantics** (plan v7 Phase 4). The G-based axiom required φ U ψ at ALL future times, which could not be established from a single witness. The X-based axiom requires φ U ψ only at t+1, enabling clean backward induction.

### 4. Boneyard Failures Do Not Shift (Teammate C — HIGH confidence)

Teammate C re-analyzed all six Boneyard failures under strict + Since/Until:

| Failure | Root Cause | Shift? | Verdict |
|---------|-----------|--------|---------|
| CoherentZChain | Cross-direction Lindenbaum kills | UNCHANGED | Not fixed |
| F-Preserving Seed | Multi-step Lindenbaum non-constructive | UNCHANGED | Not fixed (already dead) |
| Bidirectional Seed | H(a)→G(H(a)) not derivable | UNCHANGED | Not fixed |
| Bundle Coherence | Single-history vs multi-history | UNCHANGED | Not fixed |
| Omega F-Persistence | Lindenbaum adds negations | UNCHANGED | Solved by dovetailed chain |
| True Dovetailed | Unfair scheduling | UNCHANGED | Solved by fair scheduling |

**The previous critic was right**: all root causes are in canonical model construction techniques (Lindenbaum properties, cross-direction coherence, single-history semantics), orthogonal to the strict/reflexive choice and Since/Until availability.

**However, the previous critic was wrong about one thing**: the claim that strict semantics "solves a problem that doesn't exist." Teammate C now acknowledges that strict + X **genuinely resolves the specific backward truth lemma blocker** in plan v7 Phase 4, which has produced 15 pages of failed attempts.

### 5. The Canonical Frame Needs No Structural Changes (Teammate A — HIGH confidence)

The canonical task relation (`CanonicalConstruction.lean:157-160`):
```lean
def canonical_task_rel M d N :=
  if d > 0 then ExistsTask M.val N.val
  else if d < 0 then ExistsTask N.val M.val
  else M = N
```

This definition is **already correct for strict semantics**. The d=0 case (identity) is never exercised by strict temporal operators. The d>0 and d<0 cases use ExistsTask, which is the g_content inclusion relation. No changes needed.

### 6. The Existing Succ Relation Is the Canonical X (Teammate A — HIGH confidence)

`SuccRelation.lean` defines:
```
Succ u v = g_content u ⊆ v ∧ (f_content u ⊆ v ∨ f_content v)
```

This is exactly the canonical interpretation of X on the discrete chain. Under strict semantics, `X(χ) true at mcs(t) ↔ χ ∈ mcs(t+1)`, which is captured by the Succ chain construction.

## Synthesis

### Conflicts Resolved

**Conflict 1: Does the irreflexivity problem return?**

Teammate A claims the three-place task relation resolves it completely (no frame changes needed). Teammate C warns that the canonical frame must be proved to generate a discrete linear order, which requires proving no MCS is its own successor — the historically abandoned problem.

**Resolution**: Both are partially right. Teammate A is correct that the three-place structure means we don't need to prove `¬ExistsTask M M` (frame-level irreflexivity). The semantic definitions simply skip d=0. But Teammate C raises a valid technical point: the **truth lemma for X** requires that the canonical successor relation is functional (each MCS has exactly one successor and one predecessor). This is the X truth lemma: `X(χ) ∈ mcs(t) ↔ χ ∈ mcs(t+1)`. The forward direction (X(χ) → χ at next step) follows from g_content propagation. The backward direction (χ at next step → X(χ)) requires that the chain is a genuine successor structure, not just a g_content inclusion chain.

**The resolution is that the dovetailed chain construction already produces a Z-indexed family where mcs(t) and mcs(t+1) are related by the Succ relation**. The Succ relation is stronger than bare g_content (it includes f_content constraints). Under strict semantics with the discrete axioms, the Succ relation becomes the canonical interpretation of X, and the Z-indexing inherently provides irreflexivity (t ≠ t+1 on ℤ).

**Adopted position**: The irreflexivity problem is genuinely dissolved by the three-place task relation + Z-indexed chain construction. No IRR rule needed.

**Conflict 2: Structural induction circularity for X(φ U ψ)**

Teammate C identified that `X(φ U ψ) = ⊥ U (φ U ψ)` is structurally LARGER than `φ U ψ`, so the truth lemma cannot use structural induction on formula complexity alone.

**Resolution**: The backward truth lemma uses **double induction** — structural induction on formula complexity (for the IH on subformulas φ and ψ) combined with induction on witness distance k = s − t (for the backward propagation). The key insight: at each step of the k-induction, we only invoke the truth lemma for φ and ψ (proper subformulas of φ U ψ), never for φ U ψ itself at the same time point. The X-successor property (`X(χ) ∈ mcs(t) ↔ χ ∈ mcs(t+1)`) is used as a chain property, not as a truth lemma for the formula `X(χ)`.

**Conflict 3: Should we exhaust U-Induction under reflexive semantics first?**

Teammate C recommends trying U-Induction with the right χ instantiation before committing to strict semantics. Teammates A and B favor the clean break.

**Resolution**: This is a strategic choice for the user. The U-Induction approach under reflexive semantics is theoretically possible (the Burgess-Xu system was designed for reflexive operators) but has proven extremely difficult in practice (15 pages of failed attempts in plan v7 Phase 4). The strict + X approach is theoretically cleaner and directly resolves the blocker. Given the user's stated preference for "the ideal logic with the most expressive power" and "a clean-break refactor," the strict semantics path is recommended.

### Gaps Remaining

1. **Exact formulation of strict until_induction axiom** (MEDIUM confidence): Teammate B proposes several candidates but the exact statement needs verification against the Venema (1993) paper. The most promising:
   ```
   (ψ → χ) ∧ (φ ∧ X(χ) → χ) → (φ U ψ → χ)
   ```
   But under fully strict Until, φ U ψ provides information about strictly future times only, so the conclusion may need to be `φ U ψ → X(χ)` rather than `φ U ψ → χ`. This needs careful verification.

2. **The X truth lemma backward direction**: Getting `χ ∈ mcs(t+1) → X(χ) ∈ mcs(t)` requires the chain to have a "backward X-content" property. The current Succ relation provides the forward direction. The backward direction needs: if χ ∈ mcs(t+1), then ⊥ U χ ∈ mcs(t). This follows from: χ ∈ mcs(t+1) → F(χ) ∈ mcs(t) (by h_content) → ⊤ U χ ∈ mcs(t) (by F_until_equiv). But we need ⊥ U χ, not ⊤ U χ. On ℤ, ⊥ U χ at t means χ(t+1) with ⊥ on (t, t+1) = ∅. So ⊥ U χ at t ↔ χ(t+1). Getting ⊥ U χ ∈ mcs(t) from χ ∈ mcs(t+1) requires the chain to propagate X-content backward. **This is the key technical detail that needs careful construction.**

3. **Dense completeness under strict semantics**: The density axiom `GGφ → Gφ` becomes genuinely frame-dependent. For the ℚ (or ℝ) case, the axiom system and completeness proof would differ. This is a separate concern from the ℤ case but noted for completeness.

### The Real Hardest Problems (Ranked)

Based on synthesis across all three teammates:

| Rank | Problem | Root Cause | Solution Path | Difficulty |
|------|---------|-----------|--------------|------------|
| 1 | **X truth lemma backward direction** | Chain must propagate X-content backward: χ ∈ mcs(t+1) → X(χ) ∈ mcs(t) | Strengthen Succ relation to include backward X-content, or use discrete axiom derivation | MEDIUM-HIGH |
| 2 | **Exact induction axiom formulation** | Burgess-Xu induction designed for reflexive; strict version needs precise statement | Literature verification (Venema 1993, Reynolds 1996) | MEDIUM |
| 3 | **T-axiom removal cascade** | 67+ call sites across 18 files | Systematic file-by-file refactoring with alternative derivations | HIGH effort, LOW conceptual risk |
| 4 | **FMCS forward_G/backward_H redefinition** | Currently uses ≤, needs < | Change type signatures, remove reflexive base cases | MEDIUM effort |
| 5 | **Always operator three-part structure** | H φ ∧ G φ no longer implies φ | Update proofs that extracted present from always via T-axiom | LOW-MEDIUM |
| 6 | **Soundness proofs for new axioms** | density/seriality become genuine frame conditions | Standard semantic arguments with frame condition hypotheses | MEDIUM effort, LOW risk |

**NOT a hard problem**: The irreflexivity of the canonical frame (historically the reason for abandoning strict semantics). The three-place task relation + Z-indexed chain construction resolve this completely.

## Recommendations

### For the Clean-Break Refactor

The user wants the ideal logic, not the path of least resistance. Based on this research:

**Phase 1: Axiom System** (~8-12 hours)
- Remove temp_t_future and temp_t_past
- Add temp_a_dual, disc_next, disc_prev
- Replace until/since unfold/intro/induction with X/Y-based versions
- Update Substitution.lean for new axiom constructors

**Phase 2: Semantic Definitions** (~2-3 hours)
- Change Truth.lean: G/H from ≤ to <, Until/Since from half-open to fully strict
- canonical_task_rel: NO CHANGES needed

**Phase 3: Soundness** (~8-12 hours)
- Remove temp_t_future_valid, temp_t_past_valid
- Rewrite density_valid, seriality_valid with genuine frame conditions
- Prove soundness for new X-based Until/Since axioms
- Prove soundness for temp_a_dual, disc_next, disc_prev

**Phase 4: FMCS and Chain Construction** (~15-20 hours)
- Redefine forward_G/backward_H with strict < instead of ≤
- Add forward_X/backward_Y for the next-step operator
- Update DovetailedChain.lean (9 T-axiom sites → alternative derivations)
- Strengthen Succ relation for backward X-content propagation

**Phase 5: Truth Lemma** (~15-20 hours)
- G/H cases: simpler (no reflexive base case)
- Until/Since cases: backward induction on witness distance k (the key payoff)
- X truth lemma: forward from Succ relation, backward from strengthened chain

**Phase 6: Completeness Wiring** (~5-8 hours)
- Update CanonicalIrreflexivity.lean (ExistsTask reflexivity becomes irrelevant)
- Wire new truth lemma into completeness theorem
- Update FMP/Decidability for strict semantics

**Phase 7: Derived Theorems and Cleanup** (~8-12 hours)
- Update Perpetuity module (always = H ∧ id ∧ G)
- Update LinearityDerivedFacts
- Remove dead code
- Update documentation (typst, latex)

**Total estimated effort**: 60-90 hours (somewhat lower than previous estimates because the irreflexivity problem is dissolved and the truth lemma is simpler)

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|------------------|
| A | IRR-rules + task semantics | completed | Three-place relation dissolves irreflexivity; no IRR/bulldozing needed; Succ = canonical X |
| B | Axiom system + completeness | completed | Per-axiom validity table (33 axioms); X-based unfold verified; backward truth lemma strategy; S5+strict is complete |
| C | Critic + root cause analysis | completed | Boneyard failures unchanged; X truth lemma backward direction is the real hard problem; structural induction circularity identified and resolved |

## References

### Literature
- Burgess (1982). "Axioms for tense logic I: Since and Until." NDJFL 23(4)
- Xu (1988). Simplification of Burgess's axiomatization
- Venema (1993). "Completeness via Completeness." Diamonds and Defaults, Synthese Library 229
- Reynolds (1992). "An axiomatization for Until and Since over the reals without the IRR rule." Studia Logica 51:165-193
- Reynolds (1996). "Axiomatizing U and S over integer time." Advances in Modal Logic vol. 1
- Gabbay, Hodkinson, Reynolds (1994). Temporal Logic: Mathematical Foundations. OUP
- Blackburn, de Rijke, Venema (2001). Modal Logic. CUP, Ch. 4.4 (irreflexivity), Ch. 7 (derivation rules)
- SEP, "Temporal Logic" — Burgess-Xu supplement

### Codebase
- `TaskFrame.lean:93-122` — three-place task relation (the key structural insight)
- `CanonicalConstruction.lean:157-160` — canonical_task_rel (no changes needed)
- `SuccRelation.lean:59-60` — Succ relation (canonical X)
- `Truth.lean:118-129` — semantic definitions (change site)
- `Axioms.lean:279-512` — axiom system (change site)
- `WitnessSeed.lean:31` — already strict-compatible
