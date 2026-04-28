# Teammate A Findings: Guard Semantics Analysis and A3a Validity

**Task**: 107 — Burgess chronicle construction
**Date**: 2026-04-28
**Role**: Guard semantics analysis

## Key Findings

### 1. The semantics use OPEN guards (t, s), not half-open [t, s)

The actual truth definition in `Theories/Bimodal/Semantics/Truth.lean:127-130`:

```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r < t → truth_at M Omega τ r φ
```

- **Until guard**: `∀ r, t < r → r < s` — this is the open interval **(t, s)**
- **Since guard**: `∀ r, s < r → r < t` — this is the open interval **(s, t)**
- **Neither endpoint is included in the guard**

The docstring at `Truth.lean:13-14` is WRONG. It claims "half-open guard [t, s)" but the code implements open guard (t, s). The docstring at `Truth.lean:72` repeats this error.

The Boneyard archive at `Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean:4-7` correctly documents that task 113 changed to "open guard semantics (t,s)" to "match Kamp 1968, Burgess 1982, Xu 1988, Reynolds 1992."

### 2. A3a IS semantically valid under open guard

**A3a** (Burgess): `p ∧ U(q, r) → U(q ∧ S(p, r), r)`

In our code convention (guard first): `p ∧ untl(r, q) → untl(r, q ∧ snce(r, p))`

**Proof of validity**: At time t, assume p(t) and ∃ s > t with q(s) and r on (t, s).

Check `untl(r, q ∧ snce(r, p))(t)` with same witness s:
1. `q(s)` ✓ (from hypothesis)
2. `snce(r, p)(s)` = ∃ u < s, p(u) ∧ ∀ z (u < z < s → r(z)). Take u = t:
   - `t < s` ✓
   - `p(t)` ✓
   - `∀ z (t < z < s → r(z))` ✓ — **this is exactly the Until guard from the hypothesis**
3. Guard: `∀ z (t < z < s → r(z))` ✓ (same as hypothesis)

**The crucial semantic point**: The Until guard covers (t, s) and the Since witness at s with witness u = t needs guard on (t, s) — the SAME interval. Under open guards, these match perfectly.

### 3. The counterexample in TemporalDerived.lean is WRONG

`TemporalDerived.lean:519-522` claims:

> Consider times {0, 1, 2} with p true only at 0, q true at 0 and 1, r true at 2. At time 0: p ∧ U(q,r) holds (p at 0; witness s=2, r(2), q on [0,2)). But U(q ∧ S(p,r), r) fails at 0: the guard requires S(p,r) at u=0.

**Errors**:
1. The witness s=2 doesn't work because q(2) is false (q is true at 0 and 1 only). The correct witness is s=1.
2. S(p,r) needs to be evaluated at the future witness s, not at the current time 0. The comment confused where the enriched event is evaluated.
3. With witness s=1: snce(r, p)(1) is TRUE with witness u=0 (p(0) ✓, guard on (0,1) vacuous ✓).

**The counterexample was written for half-open guard [t, s) semantics, where A3a IS invalid. But task 113 changed to open guard (t, s), making A3a valid again. The TemporalDerived.lean comment was not updated after task 113.**

### 4. A4a IS also semantically valid under open guard

**A4a** (Burgess): `U(p, q) ∧ ¬U(p, r) → U(q ∧ ¬r, q)`

**Proof sketch**: From U(p,q) with witness s₁ and ¬U(p,r): since p(s₁) is true, the guard r must fail somewhere in (t, s₁). Take any z₀ ∈ (t, s₁) with ¬r(z₀). Then q(z₀) (from Until guard), ¬r(z₀), and q on (t, z₀) ⊆ (t, s₁). So U(q ∧ ¬r, q) with witness z₀.

### 5. A3a is NOT derivable from BX1-BX12

The existing BX axioms cannot derive A3a because:
- BX4 (connect_future): p → G(P(p)) gives P(p) = snce(⊤, p) at future points, with TRIVIAL guard ⊤
- A3a needs snce(r, p) with guard r at the Until witness
- BX2'/BX3' (Since monotonicity) WEAKEN guards: snce(φ, ψ) → snce(χ, ψ) when φ → χ
- Going from ⊤ (weak) to r (strong) requires STRENGTHENING, which is the wrong direction
- No combination of BX5, BX6, BX7, BX12 bridges this gap

The "shared interval" property — that the Until guard (t, s) and the Since guard (t, s) at the witness are the same interval — is a fundamentally new piece of information that no existing axiom captures.

### 6. A3a must be ADDED as a new axiom (or proved as a theorem)

Since A3a is:
- Semantically valid under our current open guard semantics ✓
- Not derivable from existing BX axioms ✗
- Required by Burgess Lemma 2.3 and Xu's construction ✓

It must be added to the axiom system. The addition is **conservative** (doesn't change the logic's valid formulas, since it's already valid). It would go in the Axiom inductive type alongside the other BX axioms.

### 7. BX2 has an unnecessary conjunct

BX2: `(φ→χ) ∧ G(φ→χ) → (φ U ψ → χ U ψ)`

The soundness proof (`Soundness.lean:500-508`) only uses the G(φ→χ) component. Under open guard (t, s), the extra (φ→χ) conjunct at the current time is unnecessary because the guard doesn't include the current time. The axiom could be simplified to: `G(φ→χ) → (φ U ψ → χ U ψ)`. (This is a separate cleanup task, not blocking.)

## Evidence

| Finding | File:Line | Evidence |
|---------|-----------|----------|
| Open guard semantics | `Truth.lean:127-130` | `t < r → r < s` (not `t ≤ r`) |
| Wrong docstring | `Truth.lean:13-14,72` | Claims "half-open guard [t, s)" |
| Correct archive note | `ClosedGuardAxioms.lean:4-7` | "open guard semantics (t,s)" |
| BX2 soundness | `Soundness.lean:500-508` | Only uses G component, not point-wise |
| BX4 soundness | `Soundness.lean:542-547` | Proves φ → G(P(φ)) with strict < |
| Wrong A3a counterexample | `TemporalDerived.lean:519-522` | Evaluates S(p,r) at wrong time |
| Open guard adoption | `ClosedGuardAxioms.lean:6-7` | "match Kamp 1968, Burgess 1982, Xu 1988" |

## Recommended Approach

**Add A3a (and its mirror A3b) as new axioms**:

```lean
/-- A3a: Until-Since enrichment: `p ∧ (φ U ψ) → (φ ∧ S(p, φ)) U ψ`.
Enriches the Until event with Since information from the current point.
Valid under open guard (t,s): the Until guard (t,s) provides the Since guard
at the witness, since the Since interval (t,s) = the Until guard interval. -/
| enrichment_until (φ ψ p : Formula) :
    Axiom (Formula.and p (Formula.untl φ ψ) |>.imp
      (Formula.untl φ (Formula.and ψ (Formula.snce φ p))))

/-- A3b: Since-Until enrichment (mirror of A3a):
`p ∧ (φ S ψ) → (φ ∧ U(p, φ)) S ψ`. -/
| enrichment_since (φ ψ p : Formula) :
    Axiom (Formula.and p (Formula.snce φ ψ) |>.imp
      (Formula.snce φ (Formula.and ψ (Formula.untl φ p))))
```

This unblocks Burgess Lemma 2.3, which unblocks Xu's Lemma 3.2.1, which unblocks the entire chronicle construction.

**Also fix**: The incorrect counterexample in `TemporalDerived.lean:513-537` and the wrong docstrings in `Truth.lean:13-14,72`.

## Confidence Level

**HIGH** (95%)

The semantic analysis is definitive:
- The open guard semantics are unambiguously specified in the Lean definition
- The validity proof for A3a is constructive and simple
- The counterexample error is clearly identified (evaluating S(p,r) at wrong time)
- The non-derivability argument is solid (no BX axiom strengthens Since guards)
- The conservative extension property follows from semantic validity

The only uncertainty is whether there are downstream effects of adding A3a that I haven't identified — but since A3a is semantically valid, adding it cannot introduce unsoundness.
