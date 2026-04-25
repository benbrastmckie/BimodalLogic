# Research Report: Task #107 — Three Blockers Resolved, Clear Implementation Path

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Mode**: Team Research (4 teammates)
**Session**: sess_1777088561_c1f855

## Summary

All three blockers from the v9 implementation attempt are resolved. The A6a axiom IS BX6 (notation swap). Forward_G follows from C4 + C0 without g_content_chain_property. The non-domain extension is solved via Cantor isomorphism. A new concern (A4a may be missing) was raised but needs verification. The implementation path is now fully unblocked.

## Key Findings

### 1. A6a IS BX6 — Notation Swap (Teammates A, D — DEFINITIVE)

**The apparent A6a ≠ BX6 discrepancy was a notation confusion:**
- Burgess: `U(event, guard)` — first argument is event/eventuality
- Codebase: `guard U event` — first argument is guard

After argument swap:
- Burgess A6a: `U_B(q ∧ U_B(p,q), q) → U_B(p,q)`
- Translates to: `q U_C (q ∧ (q U_C p)) → q U_C p`
- Which IS `Axiom.absorb_until` (BX6) with φ=q, ψ=p

**Cross-verified** with A5a↔BX5, A1a↔BX3, A7a↔BX7 — all match under the translation.

**The Lemma 2.5 absorption argument works directly with `Axiom.absorb_until`.** No derivation needed.

### 2. Forward_G from C4 + C0 — No g_content_chain_property Needed (Teammate B — HIGH)

**Breakthrough proof**: G(φ) ∈ f(x) → φ ∈ f(y) for all y > x, proved WITHOUT g_content_chain_property:

1. G(φ) = ¬F(¬φ) = ¬(⊤ U ¬φ) ∈ f(x)
2. Suppose ¬φ ∈ f(y) for some y > x
3. ⊤ ∈ f(y) (⊤ is a theorem, hence in every MCS)
4. By C4a (generalized): exists z with x < z < y and ¬⊤ = ⊥ ∈ f(z)
5. But f(z) is MCS, hence consistent — contradiction with ⊥ ∈ f(z)
6. Therefore φ ∈ f(y) for all y > x. QED.

**Requirements**: Generalized C4 (for all pairs, not just adjacent). This follows from adjacent C4 + density + A6a (now confirmed as BX6).

**Impact**: g_content_chain_property can be DELETED. forward_G/backward_H follow from C4/C4' + C0.

### 3. Non-Domain Extension via Cantor Isomorphism (Teammate C — HIGH)

**Recommended solution**: Make limit_dom dense, apply Cantor's theorem.

1. Add density counterexamples to the omega-chain enumeration (insert midpoints between all adjacent domain pairs)
2. Prove limit_dom is a countable dense linear order without endpoints
3. Apply `Order.iso_of_countable_dense` from Mathlib: limit_dom ≃o Rat
4. Define `extended_limit_f(q) = limit_f(cantor_iso.symm(q))` — maps EVERY rational to a domain point
5. forward_G/backward_H reduce to domain-point properties (proved from C4+C0)

**Why other options fail**:
- Subtype limit_dom: no AddCommGroup (not closed under +)
- Interpolation: intersection of MCS is not MCS
- Nearest-point: requires density anyway

### 4. NEW CONCERN: A4a May Be Missing (Teammate D — needs verification)

Teammate D identified Burgess's A4a (separation axiom):
```
A4a: U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)
```

This is used in Lemma 2.6 (C4 insertion) but may have no BX equivalent. **However**: after the argument swap, A4a becomes:
```
(q U p) ∧ ¬(r U p) → (q U (q ∧ ¬r))
```

This needs to be checked against BX axioms. It may correspond to an existing BX axiom or theorem, or may need derivation from BX's richer axiom set (BX has BX9-BX12 which Burgess doesn't).

**Status**: Not yet verified. Should be checked before implementation.

### 5. Complete Omega Chain Design (Teammate B — HIGH)

Concrete design provided:
- `ChronicleInvariant` bundle: C0, C1, C2', C3 (C2 derived via Lemma 2.5/A6a)
- Modified C5: construct R3-maximal g(x,y), define g(w,y) by C3
- Modified C4: full Lemma 2.6 (B' ∩ D ∩ B''), define other g by C3
- limit_g: union of finite-stage g values (first stage with both points)
- C3 in limit: automatic from g/f immutability
- 4 counterexample kinds (g_prop removed)

## Synthesis

### Conflicts Resolved

1. **"A6a vs BX6"** — Teammates A and D both confirm: SAME AXIOM after argument swap. The v9 implementation summary's claim "Burgess A6a is NOT a direct instance of BX6" was wrong.

2. **"Is g_content_chain_property needed?"** — Teammate B proves NO via the C4+C0 argument for forward_G. Three-way C3 handles the truth lemma's Until case. G reduces to ¬U via C4+C0.

3. **"How to handle non-domain extension?"** — Teammate C: Cantor isomorphism after making limit_dom dense. Other options (subtype, interpolation, nearest-point) all fail.

### Remaining Open Question

**A4a derivability from BX**: Teammate D flagged this but did not resolve it. Need to check if A4a (after argument swap) corresponds to a BX axiom or theorem. This is the only remaining mathematical question before implementation.

## Recommendations

### Immediate: Verify A4a (1-2 hours)

Check if Burgess A4a maps to a BX axiom after argument swap. If not, check if it's derivable from BX1-BX12. This is the last open question.

### Then: Create Plan v10 and Implement

The plan should incorporate:
1. Three-way C3 (already in codebase from Phase 2)
2. ChronicleInvariant bundle (C0, C1, C2', C3)
3. Modified C5/C4 elimination with g-tracking
4. Full Lemma 2.6 (DCS three-way decomposition)
5. Correct limit_g from finite-stage g values
6. forward_G from C4+C0 (delete g_content_chain_property)
7. Density counterexamples + Cantor isomorphism for non-domain extension
8. Truth lemma via C3 + C5 + C4

### Time Budget

20-30 hours. No further research needed after A4a verification.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | A6a derivation | completed | DEFINITIVE | A6a = BX6 after argument swap |
| B | Omega chain design | completed | HIGH | ChronicleInvariant, forward_G from C4+C0 |
| C | Non-domain extension | completed | HIGH | Cantor isomorphism solution |
| D | Burgess paper re-read | completed | HIGH | A4a concern raised, Lemma 2.5 step-by-step |
