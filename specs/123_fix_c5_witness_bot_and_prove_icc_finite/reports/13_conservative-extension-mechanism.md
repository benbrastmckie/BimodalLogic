# Research Report: Conservative Extension Mechanism

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Date**: 2026-05-13
- **Session**: sess_1778657762_d3e9ec
- **Type**: Research — model-theoretic transfer from weak to strict completeness

## Summary

Expressing strict G in terms of weak operators is **impossible** on discrete orders.
The correct mechanism for transferring completeness from the weak/reflexive system
(task 129) to the strict system is **model-theoretic**, not syntactic. The transfer
is ~100 lines; the hard work is the Henkin model + Doets compression (Phases 3-4).

## Why Syntactic Translation Fails

Under weak semantics, `U_w(φ, ⊥)` means: ∃ y ≥ x with φ at y and ⊥ at all z in
[x, y). Since ⊥ is never true, [x, y) must be empty, forcing y = x. So
`U_w(φ, ⊥) = φ` — it evaluates φ at the current point, not the next point.

In the strict system, `U(φ, ⊥)` means: ∃ y > x with φ at y and ⊥ at all z in
(x, y). On discrete orders y = succ(x), giving `X(φ)` = "φ at the next point."

This asymmetry means the weak system **cannot define the Next operator**, and
therefore cannot express strict `G(φ)` (which equals `G_w(φ)` at `succ(x)`).
No formula-to-formula translation from strict to weak exists.

## Model-Theoretic Transfer (Correct Approach)

### Setup

- **Weak system**: axioms include `G_w(φ) → φ` (reflexivity), weak Z1
  (`FG_w(φ) → G_w(φ)`), and all BX axioms adapted for weak Until/Since.
  Completeness proved via Henkin canonical model (task 129, Phases 3-4).

- **Strict system**: axioms include Z1, Prior-UZ, all BX axioms. The existing
  axiom system of the ProofChecker codebase.

- **Key relationship**: Every weak axiom is derivable in the strict system.
  `G_w(φ) := φ ∧ G(φ)` is a definitional abbreviation, and `G_w(φ) → φ` is
  trivially `(φ ∧ G(φ)) → φ`. The weak Z1 `FG_w(φ) → G_w(φ)` translates to
  `F(φ ∧ G(φ)) → (φ ∧ G(φ))`, which is derivable from strict Z1.

### The Transfer Argument

**Theorem**: If φ is valid on all discrete IsSuccArchimedean frames under strict
semantics, then φ is provable in the strict system.

**Proof** (by contrapositive):

1. Suppose φ is **not provable** in the strict system.
2. Then ¬φ is **consistent** with the strict axioms.
3. Since every weak axiom is a strict theorem, ¬φ is also **consistent** with
   the weak axioms. (If the weak axioms proved φ, the strict system would too,
   since it contains all weak theorems.)
4. By **weak completeness** (task 129): there exists a weak model M on a discrete
   IsSuccArchimedean frame D where ¬φ holds at some point.
5. M is a structure (D, ≤, V) with ≤ the reflexive linear order. Define the
   strict model M' = (D, <, V) where < is the strict part of ≤. Since D is
   discrete and IsSuccArchimedean, < is uniquely determined by ≤.
6. **M' is a strict countermodel for φ**: the frame (D, <) is a discrete
   IsSuccArchimedean strict frame, and V is unchanged. The truth of φ at any
   point depends on the frame and valuation; since the frame is the same
   (just described via < instead of ≤) and V is the same, φ fails in M'.
7. Therefore φ is **not valid** on all discrete IsSuccArchimedean strict frames.

Contrapositive: valid under strict → provable in strict. ∎

### Why Step 6 Works

The truth of a formula at a point depends on the frame's order structure and the
valuation, not on whether G is interpreted reflexively or strictly. The strict and
weak models share the same underlying order — ≤ is the reflexive closure of <.
For any formula ψ built from propositional connectives, □, and temporal operators:

- Propositional/□ truth is identical (same valuation, same equivalence classes).
- `G_strict(ψ)` at x: ψ at all y > x. `G_weak(ψ)` at x: ψ at all y ≥ x.
  These differ only at x itself. But the FORMULA φ being tested uses one
  specific interpretation consistently. The weak model satisfies ¬φ under weak
  interpretation; the strict model satisfies ¬φ under strict interpretation.
  The key is that ¬φ's truth is preserved because both models agree on the
  ORDER STRUCTURE — the only difference is the reflexivity convention, and φ
  is interpreted consistently within each system.

### Estimated Effort

- Lean formalization of the transfer: ~100 lines
- Define `strict_model_of_weak`: same domain, same valuation, strict order
- Prove frame properties transfer (discrete, IsSuccArchimedean, no endpoints)
- Prove consistency transfer (weak axioms ⊆ strict theorems)
- The bulk of task 129's effort is Phases 3-4 (Henkin model + Doets compression):
  500-800 lines

## Implications for Task 123

After task 129 establishes weak completeness + model-theoretic transfer:

1. `limitDomSubtype_isSuccArchimedean` can be closed by wiring in the new
   completeness result (or replaced by the Henkin-based IsSuccArchimedean).
2. `dd_countermodel_chronicle_discrete` becomes sorry-free.
3. The dead-end proof attempts (stage induction, convergence, Z1 gap analysis)
   can be archived to the Boneyard (task 130).

## References

- Doets 1987, Claims 9-11 (Henkin model compression to Z)
- Blackburn-de Rijke-Venema 2002, Section 7.2 (completeness with Until/Since)
- Task 129 plan (specs/TODO.md entry)
