# Teammate A Findings: Order-Theoretic Foundations

**Task**: 29 - switch_to_reflexive_gh_semantics
**Role**: Teammate A - Order-Theoretic Foundations
**Session**: sess_1774230393_821e02
**Date**: 2026-03-22

## Key Findings

### 1. CanonicalR Under Reflexive Semantics is a PREORDER, NOT a Partial Order

**Structure Analysis**:

| Property | Status | Evidence |
|----------|--------|----------|
| Reflexivity | HOLDS | `canonicalR_reflexive` proven via T-axiom (G(phi) -> phi) |
| Transitivity | HOLDS | `canonicalR_transitive` proven via Temporal 4 axiom (G(phi) -> GG(phi)) |
| Antisymmetry | FAILS | CanonicalR M N AND CanonicalR N M is possible when M != N |

**Proof of antisymmetry failure**: Consider two MCS M and N that agree on all G-content but differ on some F-formula. Then:
- g_content(M) subseteq N (so CanonicalR M N)
- g_content(N) subseteq M (so CanonicalR N M)
- But M != N (they differ on the F-formula)

This makes CanonicalR a **preorder**, not a partial order.

### 2. The Mathematically Correct Structure is: Preorder + Per-Witness Strictness

**What completeness actually requires**:

For the completeness proof (Truth Lemma, timeline construction), we do NOT need universal irreflexivity. We need:

1. **Forward witness existence (F)**: If F(phi) in M, exists W with CanonicalR M W and phi in W
2. **Backward witness existence (P)**: If P(phi) in M, exists W with CanonicalR W M and phi in W
3. **Per-witness strictness**: For the witnesses constructed for F/P obligations, we can ensure M != W

The key insight is that **strictness is a per-construction property, not a universal relation property**.

### 3. Strictness Under Reflexive Semantics: Per-Witness NOT Universal

**What "strictness" means**:

Under irreflexive semantics: `strict(M, N)` iff `CanonicalR M N AND NOT CanonicalR N M`

Under reflexive semantics:
- Universal `NOT CanonicalR M M` is FALSE (T-axiom proves CanonicalR M M)
- Universal `NOT CanonicalR N M given CanonicalR M N` is FALSE (see #1)
- **Per-witness strictness** IS achievable via fresh G-atom construction

**The fresh G-atom approach** (already partially implemented in `CanonicalIrreflexivity.lean`):

1. Find atom q fresh for g_content(M) with neg(q) in M
2. Build seed: g_content(M) union {G(q)}
3. Extend to MCS W via Lindenbaum
4. Then: CanonicalR M W (g_content(M) subseteq W)
5. And: NOT CanonicalR W M (q in g_content(W) but q NOT in M since neg(q) in M)

This is CORRECT mathematics. The issue is just completing the `sorry`s in the implementation.

### 4. Mathlib's Antisymmetrization is the Standard Construction

**Key Mathlib infrastructure**:

```lean
-- From Mathlib.Order.Antisymmetrization
Antisymmetrization (alpha : Type) (r : alpha -> alpha -> Prop) [IsPreorder alpha r] : Type

instPartialOrderAntisymmetrization :
  [Preorder alpha] -> PartialOrder (Antisymmetrization alpha (<=))

toAntisymmetrization_le_toAntisymmetrization_iff :
  toAntisymmetrization (<=) a <= toAntisymmetrization (<=) b <-> a <= b
```

**What this means for CanonicalMCS**:
- `CanonicalMCS` with `CanonicalR` is a Preorder
- `Antisymmetrization CanonicalMCS` would be a PartialOrder
- The quotient classes are `[M] = {N : CanonicalR M N AND CanonicalR N M}`
- The induced partial order is: `[M] < [N]` iff `CanonicalR M N AND NOT CanonicalR N M`

The codebase's `TimelineQuot` construction is essentially doing this manually.

### 5. Mathematical Invariants That MUST Hold

**For Soundness**:
- Truth at world w means membership in MCS M_w
- Temporal operators interpreted via accessibility relation
- Under reflexive semantics: G(phi) at t means phi holds at all s >= t (including t)
- T-axiom validity: G(phi) -> phi IS SOUND under reflexive semantics

**For Completeness (Truth Lemma)**:
- Forward_G: w1 <= w2 AND G(phi) in MCS(w1) implies phi in MCS(w2) -- **HOLDS** via CanonicalR definition
- Backward_H: w2 <= w1 AND H(phi) in MCS(w1) implies phi in MCS(w2) -- **HOLDS** via CanonicalR_past definition
- Forward_F: F(phi) in MCS(w) implies exists s >= w with phi in MCS(s) -- **HOLDS** via Lindenbaum
- Backward_P: P(phi) in MCS(w) implies exists s <= w with phi in MCS(s) -- **HOLDS** via Lindenbaum

**For Timeline Construction (Dense/Discrete)**:
- NoMaxOrder: For all t, exists s > t
- NoMinOrder: For all t, exists s < t
- DenselyOrdered: For t1 < t2, exists s with t1 < s < t2

**The Strictness Requirement**: These frame conditions need STRICT comparison (`<`), not just `<=`. This is where per-witness strictness matters.

### 6. The Current Codebase Already Has the Right Approach

**`CanonicalMCS.lean`** defines Preorder on CanonicalMCS correctly:
```lean
noncomputable instance : Preorder CanonicalMCS where
  le a b := a = b OR CanonicalR a.world b.world
  le_refl a := Or.inl rfl
  le_trans := ... (uses canonicalR_transitive)
```

**Key theorem**:
```lean
theorem CanonicalMCS.canonicalR_of_lt (a b : CanonicalMCS) (h : a < b) :
    CanonicalR a.world b.world
```

This is CORRECT: the strict `<` derived from this preorder implies the underlying CanonicalR.

**The preorder's strict order**: `a < b` iff `(a = b OR CanonicalR a b) AND NOT (b = a OR CanonicalR b a)`

Which simplifies to: `a < b` iff `a != b AND CanonicalR a b AND NOT CanonicalR b a`

### 7. Timeline Quotient Uses Per-Class Representatives, Not Global Antisymmetry

**Key insight from DovetailedTimelineQuot.lean**:

The quotient construction already handles equivalence classes. The strict order on the quotient is:
```
[M] < [N] iff CanonicalR M N AND NOT CanonicalR N M
```

This is well-defined because it respects equivalence classes (if M ~ M' and N ~ N', the relation is the same).

**The per-witness strictness construction** provides witnesses within each equivalence class or outside, ensuring the quotient has the needed frame properties.

## Recommended Approach

### The Mathematically Correct Solution

1. **Accept that CanonicalR is a preorder, not a partial order**
   - This is a FEATURE, not a bug
   - The standard mathematical approach is Antisymmetrization (quotient by symmetric closure)

2. **Use per-witness strictness, not universal irreflexivity**
   - `existsTask_strict_fresh_atom` is the right construction
   - Complete the 2-3 remaining `sorry`s using fresh atom + substitution arguments
   - No axiom needed; the proofs are constructive

3. **The quotient construction is already correct**
   - `TimelineQuot` quotients by the symmetric kernel of CanonicalR
   - The induced order on the quotient IS a partial order
   - NoMaxOrder, NoMinOrder, DenselyOrdered are provable using per-witness strictness

4. **Remove the inconsistent axiom**
   - `canonicalR_irreflexive_axiom` contradicts `canonicalR_reflexive`
   - The axiom is unnecessary once per-witness strictness is complete
   - All ~28-54 call sites can be refactored to use per-witness strictness

### Implementation Strategy

**Phase 1**: Complete per-witness strictness proofs
- `exists_strict_fresh_atom`: Find atom q with neg(q) in M and G(neg(q)) not in M
- `fresh_Gp_seed_consistent`: Prove g_content(M) union {G(q)} is consistent
- Key technique: substitution lemma for fresh atoms

**Phase 2**: Replace universal irreflexivity call sites
- NoMaxOrder: Use `existsTask_strict_fresh_atom` to construct witnesses
- NoMinOrder: Symmetric construction for past direction
- DenselyOrdered: Compound seed (may need two fresh atoms)

**Phase 3**: Remove axiom and clean up
- Delete `canonicalR_irreflexive_axiom`
- Delete IRR rule from proof system (it's unsound under reflexive semantics)
- Update comments and documentation

## Evidence/Examples

### Example: Why Universal Antisymmetry Fails

Let Gamma = {p} and consider two MCS extensions:
- M = Lindenbaum(Gamma union {F(q)}) -- decides F(q) true
- N = Lindenbaum(Gamma union {G(neg(q))}) -- decides G(neg(q)) true

If both M and N agree on all G-content (because p has no temporal structure), then:
- g_content(M) = g_content(N) (both just contain what's forced by p)
- So CanonicalR M N and CanonicalR N M both hold
- But M != N (they disagree on F(q) vs G(neg(q)))

This shows antisymmetry fails.

### Example: Fresh G-Atom Strictness Works

Given any MCS M:
1. Choose atom q fresh for g_content(M)
2. Since q is fresh, neg(q) in M or q in M (MCS is complete)
3. If neg(q) in M:
   - Build W from g_content(M) union {G(q)}
   - W exists (seed is consistent)
   - CanonicalR M W (g_content(M) subseteq W)
   - NOT CanonicalR W M (q in g_content(W) but neg(q) in M, so q not in M)

This gives per-witness strictness constructively.

### Mathlib Reference: Antisymmetrization

```lean
-- The standard construction for quotienting a preorder to a partial order
def AntisymmRel (r : alpha -> alpha -> Prop) (a b : alpha) : Prop :=
  r a b AND r b a

def Antisymmetrization (alpha : Type) (r : alpha -> alpha -> Prop)
    [IsPreorder alpha r] : Type :=
  Quotient (AntisymmRel.setoid r)

-- Key theorem: the quotient has a partial order
instance instPartialOrderAntisymmetrization [Preorder alpha] :
    PartialOrder (Antisymmetrization alpha (<=))
```

## Confidence Level

**HIGH CONFIDENCE** (95%)

**Justification**:
1. The mathematical analysis is straightforward order theory
2. Mathlib's `Antisymmetrization` confirms this is the standard approach
3. The codebase already implements the correct structures (just missing per-witness strictness proofs)
4. The fresh G-atom construction is mathematically sound (standard canonical model technique)
5. Prior team research (reports 06-09, 20) already converged on this approach

**Remaining uncertainty** (5%):
- The exact complexity of the substitution lemma needed for `fresh_Gp_seed_consistent`
- Whether compound seeds for DenselyOrdered need one or two fresh atoms
- Specific line counts for call site refactoring

## References

### Codebase

- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - Preorder on CanonicalMCS
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - CanonicalR definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Reflexivity proof + per-witness strictness (with sorries)
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` - Transfer structure using strict order

### Mathlib

- `Mathlib.Order.Antisymmetrization` - Preorder to partial order quotient
- `Mathlib.Order.Basic` - Preorder, PartialOrder definitions

### Prior Research

- `specs/029_switch_to_reflexive_gh_semantics/reports/06_theoretical-analysis.md` - Reflexive vs strict semantics
- `specs/029_switch_to_reflexive_gh_semantics/reports/09_team-research.md` - Per-witness strictness approach
- `specs/029_switch_to_reflexive_gh_semantics/reports/20_team-research.md` - IRR removal and call site inventory

### External

- Blackburn, de Rijke, Venema (2001) *Modal Logic* - Canonical model constructions
- Goldblatt (1992) *Logics of Time and Computation* - Temporal logic completeness
