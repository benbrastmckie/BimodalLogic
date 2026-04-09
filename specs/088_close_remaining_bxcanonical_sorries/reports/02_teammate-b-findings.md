# Teammate B Findings: Alternative Approaches (Round 2)

**Task**: 88 — Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Role**: Teammate B (Alternative Approaches)
**Session**: Round 2 independent analysis

---

## Key Findings

### 1. Critical Discovery: BX11 (temp_linearity) and BX12 (F_until_equiv) ARE ALREADY IN THE AXIOM SYSTEM

The team research synthesis (01_team-research.md) identified "re-adding temp_linearity and F_until_equiv" as the primary path forward. However, reading `Axioms.lean` directly reveals these axioms ARE ALREADY PRESENT:

- **BX11** (`temp_linearity`): Lines 240–244 of `Theories/Bimodal/ProofSystem/Axioms.lean`
  - `F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)`
- **BX11'** (`temp_linearity_past`): Lines 249–253
- **BX12** (`F_until_equiv`): Lines 258–259
  - `F(φ) → (⊤ U φ)`
- **BX12'** (`P_since_equiv`): Lines 263–264

All four axioms are in Layer 3b of the Axiom inductive type, with soundness proofs already completed sorry-free in `Soundness.lean` (at lines 840–843, 1025–1028, etc.).

The ConservativeExtension module has stub markers reading `sorry /- temp_linearity removed in BX -/` but these are in the *extension system* (ExtDerivation), not in the base BX axiom set.

**Implication**: The axioms were never actually removed from the BX system. The misleading comments in the ConservativeExtension module propagated confusion. The actual problem is that Frame.lean has NEVER used these axioms.

### 2. Frame.lean Does Not Import or Use BX11/BX12

`Frame.lean` never references `temp_linearity`, `F_until_equiv`, `BX11`, or `BX12`. The sorry-site comments claim "Until-induction removed in BX refactoring" but this conflates:
- *Until-induction* (a different axiom, actually removed)
- `temp_linearity` and `F_until_equiv` (present as BX11/BX12)

The BX7 (`linear_until`) axis constrains relative orderings of Until witness times *within* a formula context. BX11 (`temp_linearity`) constrains the temporal order between arbitrary future witnesses. These serve different roles.

### 3. How BX12 (F_until_equiv) Solves the Forward Until Sorry

The key sorry at Frame.lean line 653 (forward Until eventuality resolution) needs to show that given `φ U ψ ∈ w` and `ψ ∉ w`, there exists `v ≥ w` with `ψ ∈ v` and `φ ∈ u` for all intermediate `u`.

**Proof path using BX12**:
1. From `φ U ψ ∈ w` and BX10 (`until_F`): `F(ψ) ∈ w`.
2. From BX12 (`F_until_equiv`): `⊤ U ψ ∈ w`.
3. By BX5 (`self_accum_until`) applied to `φ U ψ`: `(φ ∧ (φ U ψ)) U ψ ∈ w`.
4. By BX7 (`linear_until`) on `(φ ∧ (φ U ψ)) U ψ` and `⊤ U ψ` in w: witnesses are linearly ordered.
5. The minimal witness for `ψ` (via BX6 absorption) is unique up to bx_le comparison.
6. For any intermediate `u` with `bx_le w u` and `bx_lt u v`, from `(φ ∧ (φ U ψ)) U ψ ∈ w` and BX4 (`G(P(φ U ψ)) ∈ w`): since `bx_le w u`, `P(φ U ψ) ∈ u`. With BX7 linearity, `¬(ψ ∈ u)` forces the Until-witness at `u` to be strictly later, so the guard `φ ∈ u` follows from BX9 (`until_elim`).

This is a concrete, mechanizable proof path. The "guard" condition precisely matches what BX7 provides about Until-witness ordering vs what BX9/BX5 provides about current-point consequences.

### 4. How BX11 (temp_linearity) Solves bx_le Comparison Needed for Backward Until

The backward Until sorry at Frame.lean line 675 needs: given `bx_le w v` and `ψ ∈ v`, to show `φ U ψ ∈ w` from the guard condition. The proof by contradiction requires: if `¬(φ U ψ) ∈ w`, then by BX4, `G(P(¬(φ U ψ))) ∈ w`, so `P(¬(φ U ψ)) ∈ v`, so there exists `u ≤ v` with `¬(φ U ψ) ∈ u`. The gap is showing `bx_le w u` (so the guard can derive a contradiction).

**Proof path using BX11 (temp_linearity)**:
- From `F(ψ) ∈ w` (via BX10 applied to `φ U ψ ∈ w`) and `F(¬(φ U ψ)) ∈ v` (from `P(¬(φ U ψ)) ∈ v`): BX11 provides that `F(ψ ∧ ¬(φ U ψ))` or `F(ψ ∧ F(¬(φ U ψ)))` or `F(F(ψ) ∧ ¬(φ U ψ))` holds at `w`.

However, there is a subtlety: `bx_le` is defined via g_content (G-formulas), not F-formulas. BX11 gives F-formula linearity but does not directly give bx_le comparability.

**Alternative backward proof using G/H directly**:
If `¬(φ U ψ) ∈ w`, the guard hypothesis `h_guard` already provides that `φ ∈ u` for all `u` with `bx_le w u` and `bx_lt u v`. The contradiction at `v` uses `ψ ∈ v` with `¬(φ U ψ) ∈ v` (derived from `G(P(¬(φ U ψ))) ∈ w` and `bx_le w v`). Then BX8 (`ψ → φ U ψ`) gives `φ U ψ ∈ v`, contradicting `¬(φ U ψ) ∈ v`.

Wait — this is actually complete WITHOUT needing bx_le between w and u for the backward direction! The backward sorry signature already takes the guard as a hypothesis; the backward proof just needs to derive contradiction when `¬(φ U ψ) ∈ w`.

**Backward proof sketch (no extra axioms needed)**:
1. Assume `¬(φ U ψ) ∈ w` (by contradiction).
2. From BX4 (`until_G_past` or connectedness axiom): `G(P(φ U ψ) ∨ ψ) ∈ w`? No — BX4 is not in the current axiom list.
3. Actually checking: BX4 would be `φ U ψ → G(P(φ U ψ))`. This is `Axiom.temp_a` or similar.

Checking `Axioms.lean` for the connectedness axiom is needed to verify this path.

### 5. The CanonicalEmbedding Sorry (line 418) Is Truly Orthogonal

The sorry in `CanonicalEmbedding.lean:418` (imp Case B in `usf_completeness`) concerns `G/H` formulas inside implications on constant histories. The proof comment is:

> On constant_history w: truth_at G(α) collapses to truth_at α, so the backward bridge gives flatten(χ) ∈ w rather than χ ∈ w. The gap is: flatten(χ) ∈ w does not imply χ ∈ w when χ contains G or H.

This sorry is genuinely independent of the Frame.lean sorries. The fix requires either:
- **(a) Two-point construction**: Build a non-constant history τ where τ(t) = w and τ(t+1) = v with `bx_le w v`. Truth at time t requires truth at future times for G-formulas.
- **(b) Proof-theoretic reduction**: Show that if `χ` (containing G/H) is valid and `χ ∈ w.formulas` cannot be derived, then derive a contradiction proof-theoretically without needing semantic truth in the canonical model.

Approach (a) requires having a chain with at least 2 points, which requires knowing that `bx_forward_witness` gives a point `v ≥ w`. Since `bx_forward_witness` is already proved sorry-free, this construction is available.

**Concrete proposal for CanonicalEmbedding sorry (approach a)**:
Given the imp Case B sorry state:
- `w : BXPoint`, `ψ ∈ w.formulas`, `χ ∉ w.formulas`
- Need to show `valid (ψ.imp χ) → ⊥` (already have this from `h_not_deriv`)
- Build a two-point history: at time 0 use `w`, at time 1 use any `v ≥ w` via `bx_forward_witness` (with some arbitrary `F`-formula, or just take the same point `w` again)

Actually the problem is showing the constant_history truth lemma FAILS for G/H inside imp. The fix is: for Case B, construct a model using the truth lemma already proved for the G and H cases separately (in `TruthLemma.lean`: `G_iff_mcs`, `H_iff_mcs`). The canonical model construction in `Completeness.lean` (which is sorry'd at line 160) already knows how to handle G and H. The CanonicalEmbedding sorry at line 418 is about `usf_completeness` which claims to work WITHOUT the full canonical model — but the proof structure needs reworking.

**Key insight**: `usf_completeness` proves validity → derivability for the USF fragment by induction. The G and H cases use proof-theoretic necessitation (lines 423–430) — this works. Only imp Case B uses the canonical model, and it needs a smarter countermodel construction. The natural fix: extend the countermodel for Case B to use a two-point sequence using `bx_forward_witness` plus `G_iff_mcs` / `H_iff_mcs` from TruthLemma.lean.

### 6. No FMP Bridge Exists

No FMP bridge from Decidability to Completeness is viable. The FMP infrastructure (`Decidability/FMP/`) proves that if a formula is not valid, it is falsifiable in a finite model. But:
- `fmp_contrapositive` takes "valid in all finite models → valid" — the wrong direction for completeness
- FMP completeness would require "falsifiable in finite model → not derivable" — but derivability is syntactic; FMP does not preclude the proof system being incomplete
- The FMP approach proves finite model SATISFIABILITY but not completeness (derivable ↔ valid)

### 7. Quasimodel/Filtration Infrastructure

The filtration infrastructure in `Decidability/FMP/` is entirely sorry-free. However, it provides:
- `FilteredWorld`: Quotient of closure MCSes
- `mcsTruth`: Membership-as-truth definition
- **NOT** a truth lemma for Until/Since in the filtered model

The filtration approach for completeness would require proving the filtration lemma for Until/Since, which faces the same until-satisfaction problem as the canonical model approach — filtration is helpful for decidability/FMP but does not shortcut the completeness proof for Until/Since.

---

## Recommended Approach

### Primary: Use BX12 (F_until_equiv) Already Available in the System

The most direct path to closing the 4 Frame.lean sorries uses BX12 (`F_until_equiv`): `F(φ) → ⊤ U φ`, which is already available as `Axiom.F_until_equiv` in the proof system.

**Phase 1: Prove bx_le interval linearity from BX7 + BX12**

Given `φ U ψ ∈ w`:
1. From BX10: `F(ψ) ∈ w`
2. From BX12: `⊤ U ψ ∈ w`
3. By BX7 on `φ U ψ` and `⊤ U ψ`: the until-witnesses are ordered, giving three disjuncts
4. The minimal ψ-witness (by BX6 absorption argument) is the canonical `v`
5. For intermediate u: use BX4 (connectedness: `G(P(φ U ψ))`) to propagate `P(φ U ψ) ∈ u`, then use BX7-derived ordering and BX9 to get `φ ∈ u`

**Note on BX4 (connectedness)**: The proof requires verifying BX4 is in the axiom system. Checking `Axioms.lean` for an axiom of the form `φ U ψ → G(P(φ U ψ))` or equivalent.

**Phase 2: Close backward Until sorry directly**

The backward sorry (line 675) with the guard as hypothesis may be closable by direct contradiction without needing bx_le linearity between `w` and the backward witness `u`. The key: if `¬(φ U ψ) ∈ w` and `bx_le w v` and `ψ ∈ v`, the contradiction arises at `v` itself via BX8 and the propagation of `¬(φ U ψ)` forward from `w` to `v`.

**Phase 3: Handle CanonicalEmbedding:418 with two-point model**

Build a two-point history using `bx_forward_witness` for the imp Case B proof, exploiting the already-proved G/H truth lemma from `TruthLemma.lean`.

**Phase 4: Close Completeness.lean sorry**

Once phases 1–3 close the upstream sorries, `bx_completeness` closes trivially by using the canonical model embedding that depends on `until_iff_mcs` and `since_iff_mcs` from `TruthLemma.lean`.

---

## Evidence/Examples

### BX12 is Available (Axioms.lean lines 255–259):
```lean
/-- BX12: F-Until equivalence: `F(φ) → (⊤ U φ)`.
Every future eventuality can be witnessed by an Until formula with vacuous guard.
Here ⊤ = ¬⊥ = ⊥ → ⊥. Bridges F-formulas to Until-formulas. -/
| F_until_equiv (φ : Formula) :
    Axiom ((Formula.some_future φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ))
```

### BX11 is Available (Axioms.lean lines 236–244):
```lean
/-- BX11: Temporal linearity:
`F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`. -/
| temp_linearity (φ ψ : Formula) :
    Axiom (Formula.and (Formula.some_future φ) (Formula.some_future ψ) |>.imp ...)
```

### Soundness Already Proved (Soundness.lean):
- `temp_linearity_valid` at line 285 — sorry-free
- `F_until_equiv_valid` at line 378 — sorry-free

### The Sorries Make Wrong Claims About Axiom Availability:
Frame.lean line 599: "Approach (A): Until-induction was removed in BX refactoring. Not available."
But Frame.lean NEVER TRIED to use BX12 (`F_until_equiv`) which provides the Until-bridge.

### MCSProperties Infrastructure Already Supports This:
`bx_forward_witness` (Frame.lean line 164–171) is sorry-free and gives `∃ v, bx_le w v ∧ ψ ∈ v.formulas` from `F(ψ) ∈ w`. Combined with BX10 + BX12, this gives the Until witness.

---

## Confidence Level

**HIGH (80%)** that BX12 + BX7 + existing infrastructure is sufficient to close the 4 Frame.lean sorries, pending:
1. Verification that BX4 (connectedness/G(P) axiom) is available for the guard argument
2. Lean proof of the intermediate guard formula (`φ ∈ u` for strictly intermediate `u`)

**MEDIUM (65%)** for the CanonicalEmbedding:418 sorry via two-point construction, as it requires careful handling of the `truth_at` semantics for a two-point non-constant history.

**HIGH (90%)** that Completeness.lean closes automatically once the upstream sorries are resolved.

---

## Estimated Effort

| Sorry Site | Approach | Estimated Effort |
|-----------|----------|-----------------|
| Frame.lean:653 (forward Until) | BX12 + BX7 + BX9/BX10 | 4–8 hours |
| Frame.lean:675 (backward Until) | Direct contradiction + BX8 | 2–4 hours |
| Frame.lean:690 (forward Since) | Mirror of forward Until | 2–4 hours |
| Frame.lean:704 (backward Since) | Mirror of backward Until | 1–2 hours |
| CanonicalEmbedding:418 (imp Case B) | Two-point history construction | 4–8 hours |
| Completeness:160 (full bx_completeness) | Follows from above | 1–2 hours |
| **Total** | | **14–28 hours** |

---

## Critical Action Items Before Implementation

1. **Verify BX4 in axiom system**: Check `Axioms.lean` for `φ U ψ → G(P(φ U ψ))` (the connectedness/propagation axiom). This is needed for the forward Until guard proof. If absent, the alternative uses only BX7 for witness ordering.

2. **Check if `temp_4_until` exists**: Search for a derived lemma connecting `φ U ψ ∈ w` to `G(something) ∈ w` — this would avoid needing BX4.

3. **Prototype the guard proof**: The forward Until sorry requires showing `φ ∈ u` for strictly intermediate `u`. The precise argument using BX7's three-disjunct output needs mechanization.

4. **Assess ConservativeExtension impact**: The ConservativeExtension module has `sorry /- temp_linearity removed in BX -/` stubs in `Lifting.lean`. If BX12 is used in the BXCanonical proofs, these stubs need attention. But they may be irrelevant to the main proofs.
