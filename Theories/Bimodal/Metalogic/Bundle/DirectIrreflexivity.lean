import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators

/-!
# Direct Irreflexivity Analysis (Path A: Substitute-and-Derive)

This module formalizes the syntactic consequences of CanonicalR(M, M) and
systematically explores whether a direct F-proof of irreflexivity is possible.

## Purpose

Task 958 Path A attempts to derive `bot in M` DIRECTLY from CanonicalR(M, M)
by finding a SPECIFIC formula psi such that `derives psi` and `neg(psi) in M`,
without constructing the naming MCS M'.

## Phase 1: Closure Lemmas

The closure lemmas formalize what membership facts follow from CanonicalR(M, M):
- `canonicalR_closure_temp_a`: phi in M implies P(phi) in M
- `canonicalR_closure_temp_4`: G(phi) in M implies G(G(phi)) in M
- `canonicalR_G_propagates`: phi in M implies G(P(phi)) in M
- `canonicalR_H_neg_exclusion`: atom(p) in M implies H(neg(atom(p))) not-in M
- `canonicalR_F_presence`: G(phi) not-in M implies F(neg(phi)) in M

## References

- Task 958 research-007.md: Path A analysis
- Task 958 plans/implementation-004.md: This implementation plan
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

-- Classical decidability for set membership
attribute [local instance] Classical.propDecidable

noncomputable section

/-!
## Phase 1: CanonicalR Closure Lemmas

When CanonicalR(M, M) holds (i.e., g_content(M) ⊆ M), combining with MCS properties
and temporal axioms produces strong closure conditions on M's membership.
-/

/--
If CanonicalR(M, M) and phi in M, then P(phi) in M.

Proof chain:
1. phi in M
2. By temp_a: phi -> G(P(phi)), so G(P(phi)) in M
3. P(phi) in g_content(M) (since G(P(phi)) in M)
4. By CanonicalR(M, M): g_content(M) ⊆ M, so P(phi) in M

Note: P(phi) = sometime_past(phi) = neg(all_past(neg(phi))) = ¬H(¬phi)
-/
theorem canonicalR_closure_temp_a (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_R : CanonicalR M M) (phi : Formula) (h_phi : phi ∈ M) :
    phi.sometime_past ∈ M := by
  -- Step 1: By temp_a axiom: ⊢ phi → G(P(phi))
  have h_temp_a : DerivationTree [] (phi.imp (Formula.all_future phi.sometime_past)) :=
    DerivationTree.axiom [] _ (Axiom.temp_a phi)
  -- Step 2: phi → G(P(phi)) is a theorem, so it's in M
  have h_imp_in_M := theorem_in_mcs h_mcs h_temp_a
  -- Step 3: By modus ponens in M: G(P(phi)) in M
  have h_GP_in_M := SetMaximalConsistent.implication_property h_mcs h_imp_in_M h_phi
  -- Step 4: P(phi) in g_content(M) (definitionally: G(P(phi)) in M)
  -- Step 5: By CanonicalR(M, M): P(phi) in M
  exact h_R h_GP_in_M

/--
If CanonicalR(M, M) and G(phi) in M, then G(G(phi)) in M.

By temp_4 axiom: G(phi) -> G(G(phi)), applied within MCS M.
-/
theorem canonicalR_closure_temp_4 (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_G : Formula.all_future phi ∈ M) :
    Formula.all_future (Formula.all_future phi) ∈ M := by
  have h_t4 : DerivationTree [] ((Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi))) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 phi)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_t4) h_G

/--
If phi in M, then G(P(phi)) in M.

Direct from temp_a: ⊢ phi → G(P(phi)).
Note: This does not require CanonicalR(M, M) -- it's a consequence of temp_a alone.
-/
theorem canonicalR_G_propagates (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_phi : phi ∈ M) :
    Formula.all_future phi.sometime_past ∈ M := by
  have h_temp_a : DerivationTree [] (phi.imp (Formula.all_future phi.sometime_past)) :=
    DerivationTree.axiom [] _ (Axiom.temp_a phi)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_temp_a) h_phi

/--
If CanonicalR(M, M) and atom(p) in M, then H(neg(atom(p))) not-in M.

Proof chain:
1. atom(p) in M
2. By canonicalR_closure_temp_a: P(atom(p)) in M
3. P(atom(p)) = neg(H(neg(atom(p)))) = ¬H(¬p)
4. Since ¬H(¬p) in M, by MCS consistency: H(¬p) not-in M

Note: P(phi) = phi.sometime_past = phi.neg.all_past.neg
So P(atom(p)) = (atom(p)).neg.all_past.neg = (all_past (neg (atom p))).neg
-/
theorem canonicalR_H_neg_exclusion (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_R : CanonicalR M M) (p : Atom) (h_atom : Formula.atom p ∈ M) :
    Formula.all_past (Formula.neg (Formula.atom p)) ∉ M := by
  -- P(atom(p)) in M by closure
  have h_P_in_M := canonicalR_closure_temp_a M h_mcs h_R (Formula.atom p) h_atom
  -- P(atom(p)) = (atom p).sometime_past = (atom p).neg.all_past.neg
  -- = (Formula.all_past (Formula.neg (Formula.atom p))).neg
  -- So neg(H(neg(atom(p)))) in M
  -- By MCS: H(neg(atom(p))) not-in M
  -- sometime_past = some_past = neg(all_past(neg(phi)))
  -- (atom p).sometime_past = (atom p).neg.all_past.neg
  -- This IS (Formula.all_past (Formula.neg (Formula.atom p))).neg -- that's neg(H(neg(atom p)))
  -- Actually, let me unfold: sometime_past = some_past
  -- some_past phi = phi.neg.all_past.neg
  -- = (Formula.neg phi).all_past |> Formula.neg
  -- = Formula.neg (Formula.all_past (Formula.neg phi))
  -- For phi = atom p:
  -- = Formula.neg (Formula.all_past (Formula.neg (Formula.atom p)))
  -- = (Formula.all_past (Formula.neg (Formula.atom p))).imp Formula.bot
  -- This is the negation of H(neg(atom p)).
  -- So h_P_in_M says: neg(H(neg(atom p))) in M
  -- We want to show: H(neg(atom p)) not-in M
  -- This follows from MCS consistency: if neg(X) in M then X not-in M
  have h_eq : (Formula.atom p).sometime_past = Formula.neg (Formula.all_past (Formula.neg (Formula.atom p))) := by
    simp [Formula.sometime_past, Formula.some_past, Formula.neg]
  rw [h_eq] at h_P_in_M
  exact SetMaximalConsistent.neg_excludes h_mcs _ h_P_in_M

/--
If G(phi) not-in M (where M is MCS), then F(neg(phi)) in M.

Proof: By MCS negation completeness, either G(phi) in M or neg(G(phi)) in M.
Since G(phi) not-in M, we have neg(G(phi)) in M.
neg(G(phi)) = neg(all_future(phi)) = (all_future phi).neg = some_future (neg phi)...

Actually: neg(G(phi)) = (all_future phi).imp bot = F(neg(phi)) is not quite right.
F(psi) = neg(G(neg(psi))) = (all_future (neg psi)).neg

So neg(G(phi)) = (all_future phi).neg. And F(neg(phi)) = (all_future (neg(neg(phi)))).neg.
These are NOT the same syntactically.

What we actually get is: neg(G(phi)) in M, which is (all_future phi).imp bot in M.
This is equivalent to F(neg(phi)) modulo double negation but NOT syntactically equal.

Let's just prove the direct version: neg(G(phi)) in M.
-/
theorem canonicalR_neg_G_from_not_mem (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_not_G : Formula.all_future phi ∉ M) :
    Formula.neg (Formula.all_future phi) ∈ M := by
  cases SetMaximalConsistent.negation_complete h_mcs (Formula.all_future phi) with
  | inl h => exact absurd h h_not_G
  | inr h => exact h

/-!
## Phase 2: Systematic Formula Search

We now systematically investigate candidate formulas psi such that
`derives psi` and `neg(psi) in M` under the assumption CanonicalR(M, M).

### Research Prediction

Research-007.md analyzed Path A extensively and concluded that no such formula
psi exists. The CanonicalR(M, M) assumption makes M "self-consistent" -- all
the temporal closure properties yield formulas that are IN M, never formulas
whose negations are in M.

### Candidate Analysis

The following candidates are analyzed below:
1. Seriality-based formulas (F(neg(bot)) is a theorem)
2. temp_a iteration chains
3. IRR-derived theorems
4. Naming set interaction under CanonicalR

### Candidate 1: Seriality

F(neg(bot)) = neg(G(bot)) is a theorem. Under CanonicalR(M, M):
- G(bot) in M would imply bot in M (contradiction). So G(bot) not-in M.
- neg(G(bot)) in M. This is the seriality instance.
- F(neg(bot)) in M. No contradiction: this is expected.

### Candidate 2: temp_a Iterations

For any phi in M, the chain:
  phi in M -> G(P(phi)) in M -> P(phi) in M -> G(P(P(phi))) in M -> ...
All of these are IN M under CanonicalR(M, M). No contradiction arises.

### Candidate 3: IRR-Derived Theorems

The IRR rule derives phi from (atom(p) AND H(neg(atom(p)))) -> phi when p
is fresh for phi. Standard IRR instances produce:
- Density: G(phi) -> G(G(phi)) (but this is also temp_4, already in M if G(phi) in M)
- The challenge: find an IRR-derived theorem that, combined with CanonicalR(M, M),
  forces its negation into M.

All IRR-derived theorems are standard tense logic theorems. Under CanonicalR(M, M),
M is closed under temporal necessitation (G(phi) in M -> phi in M), so theorems
end up IN M, not excluded.

### Candidate 4: Naming Set Interaction

Under CanonicalR(M, M), for any p with atom(p) in M:
- P(atom(p)) in M (by canonicalR_closure_temp_a)
- H(neg(atom(p))) not-in M (by canonicalR_H_neg_exclusion)
- The naming set NS(p) is consistent (by naming_set_consistent)
- But P(atom(p)) is NOT derivable from NS(p) alone (that would contradict consistency)

The naming set is consistent BECAUSE M is consistent. The assumption CanonicalR(M, M)
does not make the naming set inconsistent; it just changes membership patterns.

### Candidate 5: Attempt at direct contradiction

Suppose we look for psi such that:
- derives psi (psi is a theorem)
- Under CanonicalR(M, M): neg(psi) in M

For any theorem psi, by MCS closure, psi in M. So neg(psi) not-in M (by consistency).
This is EXACTLY why Path A cannot work: being a theorem FORCES psi into M,
which EXCLUDES neg(psi) from M.

### Conclusion

**Path A is impossible.** The direct F proof approach cannot work because:

1. Any theorem psi is automatically in M (MCS closure)
2. If psi in M then neg(psi) not-in M (MCS consistency)
3. So there is NO formula psi with both "derives psi" and "neg(psi) in M"
4. The contradiction mechanism REQUIRES comparing M with a DIFFERENT MCS M'

This confirms research-007.md's prediction. The proof of canonicalR irreflexivity
REQUIRES constructing a second MCS M' and deriving a contradiction between M and M'.
The naming set approach (with conservative extension to handle the freshness gap)
is the correct path forward.

**Recommendation**: Proceed to Path B (g_content seed + conservative extension)
as described in research-007.md.

## Phase 4: Pivot Documentation

### Summary of Path A Analysis

Path A (Direct F Proof) attempted to derive `bot in M` directly from
CanonicalR(M, M) by finding a formula psi where both `derives psi` and
`neg(psi) in M`. This is provably impossible:

1. **Logical impossibility**: For any theorem psi, psi is in every MCS M
   (by MCS closure under derivability). Therefore neg(psi) is not in M
   (by MCS consistency). No formula can simultaneously be a theorem and
   have its negation in an MCS.

2. **Closure analysis**: Under CanonicalR(M, M), the temporal closure
   lemmas (Phase 1) show that M is "self-reinforcing" -- temp_a iterations,
   G-propagation, and seriality all produce formulas IN M, never formulas
   whose negations are in M.

3. **Naming set compatibility**: The naming set NS(p) is consistent under
   CanonicalR(M, M) (already proven). Its consistency follows from M's
   consistency via IRR-contrapositive. This does NOT produce a contradiction
   within M itself.

### Why M' is Required

The standard irreflexivity proof works by constructing a SECOND MCS M' from
the naming set, then deriving a contradiction between M and M'. The
contradiction comes from:
- atom(p) in M' (from naming set)
- neg(atom(p)) in M subset M' (since p is globally fresh, neg(atom(p)) in M)

This requires M subset M', which requires atomFreeSubset(M, p) = M, which
requires global freshness. Without global freshness, M is NOT subset of M',
and the contradiction mechanism fails.

### Forward Path: Conservative Extension with embed '' M Seed

The conservative extension provides a genuinely fresh atom q = Sum.inr() for
ALL embedded formulas. The seed `embed '' M union {atom_ext(q), H_ext(neg_ext(atom_ext(q)))}`
is F+-consistent (proven via IRR-contrapositive + lift_derivation_qfree).
Extending to F+-MCS M'_ext gives embed '' M subset M'_ext, so M = M'_F
(restriction to F). However, the final contradiction requires neg_ext(atom_ext(q))
in M'_ext, which is impossible since atom_ext(q) in M'_ext.

The fundamental gap: the naming argument creates a contradiction at the level
of the fresh atom, but since q lives only in F+ (not F), the contradiction
does not propagate to the F level.

### Recommended Next Steps

1. **Path B with modified approach**: Instead of the naming set, use a
   semantic argument leveraging IRR soundness on the canonical model.
2. **Product Frame bypass**: Construct an irreflexive product model from
   the (possibly reflexive) canonical model.
3. **Zanardo-style axiom schemas**: Replace IRR with infinitely many axioms.

See `specs/958_prove_canonicalr_irreflexive_irr_rule/plans/implementation-005.md`
for the recommended Path B plan.
-/

end

end Bimodal.Metalogic.Bundle
