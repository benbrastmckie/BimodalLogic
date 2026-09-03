# Core Metalogic Foundations

**Status**: Self-Contained (No Boneyard Dependencies)

This directory contains the foundational theory for maximal consistent sets (MCS) and the
deduction theorem, which underpin all canonical model constructions in the metalogic.

## Overview

The Core modules provide essential infrastructure shared by both the `Bundle/` (BFMCS) and
`Algebraic/` approaches:
- **Maximal Consistent Sets (MCS)**: Sets that are consistent and cannot be extended
- **Lindenbaum's Lemma**: Extending consistent sets to MCS using Zorn's lemma
- **Deduction Theorem**: Converting `A :: Gamma ⊢ B` to `Gamma ⊢ A → B`
- **MCS Properties**: Lemmas about formula membership and closure

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `../Core.lean` | Re-export module for the Core package. **Sibling aggregator**, at `FormalSystem/Metalogic/Core.lean` (37 lines) — not a file inside this directory | Complete |
| `MaximalConsistent.lean` | Complete MCS theory with Lindenbaum | **Sorry-free** |
| `DeductionTheorem.lean` | Deduction theorem infrastructure | **Sorry-free** |
| `MCSProperties.lean` | Essential MCS lemmas | **Sorry-free** |
| `RestrictedMCS/` | MCS restricted to subformula closure (1 file: `Basic.lean`) | **Sorry-free** |

## Dependency Flowchart

```
                  MaximalConsistent.lean
                         │
           ┌─────────────┼─────────────┐
           │             │             │
           v             v             v
    DeductionTheorem  MCSProperties   (exports to
           │             │             other modules)
           │             │
           v             v
     ../Core.lean (sibling aggregator)
```

The aggregator is `FormalSystem/Metalogic/Core.lean`, a **sibling** of this directory rather than
a file inside it.

## Key Definitions

### Maximal Consistent Sets (`MaximalConsistent.lean`)

```lean
def Consistent (Gamma : Context) : Prop :=
  ¬Nonempty (DerivationTree Gamma Formula.bot)

def SetConsistent (S : Set Formula) : Prop :=
  ∀ (L : List Formula), (∀ φ ∈ L, φ ∈ S) → Consistent L

def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S ∧ ∀ φ, φ ∉ S → ¬SetConsistent (insert φ S)
```

A set is **SetConsistent** if every finite subset is consistent (cannot derive ⊥).
A set is **SetMaximalConsistent** if it is consistent and any extension is inconsistent.

**Key Theorems**:
- `exists_maximal_of_chainClosed`: the directory's **single** Zorn argument — for any predicate
  `P : Set Formula → Prop` closed under unions of chains, every `P`-set extends to a `P`-maximal
  one. Both Lindenbaum variants are thin instantiations of it and neither runs Zorn itself.
- `set_lindenbaum`: Lindenbaum's lemma (extend consistent to MCS), an instantiation of
  `exists_maximal_of_chainClosed` at `SetConsistent`
- `restricted_lindenbaum` (`RestrictedMCS/Basic.lean`): the closure-restricted instantiation,
  carrying a short bridge between `¬RestrictedConsistent phi (insert psi S) fc` and
  `RestrictedMCS`'s `¬SetConsistent (insert psi S)` maximality field
- `mcs_contains_or_neg`: Either φ or ¬φ in MCS (negation completeness)
- `theorem_in_mcs`: All theorems are in every MCS
- `SetMaximalConsistent.modus_ponens`: Modus ponens reflected in membership
- `inconsistent_derives_bot`: Inconsistent contexts derive ⊥

The four hand-rolled superset scaffolds the two Lindenbaum proofs used to carry
(`ConsistentSupersets`, `self_mem_consistent_supersets`, `RestrictedConsistentSupersets`,
`self_mem_restricted_consistent_supersets`) were their only consumers and have been deleted.

### Deduction Theorem (`DeductionTheorem.lean`)

```lean
theorem deduction_theorem {Gamma : Context} {A B : Formula}
    (h : A :: Gamma ⊢ B) : Gamma ⊢ A.imp B
```

The deduction theorem converts a derivation from an extended context into an implication derivation.

**Supporting lemmas**:
- `deduction_axiom`: If φ is an axiom, then `Gamma ⊢ A → φ`
- `deduction_assumption_same`: `Gamma ⊢ A → A` (identity)
- `deduction_assumption_other`: If `B ∈ Gamma`, then `Gamma ⊢ A → B`
- `deduction_mp`: Modus ponens under implication

**Implementation Note**: The proof uses well-founded recursion on derivation height to handle
the recursive structure of derivation trees.

### MCS Properties (`MCSProperties.lean`)

```lean
lemma SetMaximalConsistent.closed_under_derivation {S : Set Formula} {phi : Formula}
    (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (h_sub : ∀ psi ∈ L, psi ∈ S)
    (h_deriv : DerivationTree L phi) : phi ∈ S

lemma SetMaximalConsistent.implication_property {S : Set Formula} {phi psi : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_imp : phi.imp psi ∈ S) (h_phi : phi ∈ S) : psi ∈ S

lemma SetMaximalConsistent.negation_complete {S : Set Formula} {phi : Formula}
    (h_mcs : SetMaximalConsistent S) :
    phi ∈ S ∨ phi.neg ∈ S
```

```lean
theorem SetConsistent.bot_not_mem {S : Set Formula}
    (h : SetConsistent S) : Formula.bot ∉ S

theorem SetMaximalConsistent.bot_not_mem {S : Set Formula}
    (h : SetMaximalConsistent S) : Formula.bot ∉ S

theorem SetMaximalConsistent.mp_of_theorem {S : Set Formula} {φ ψ : Formula}
    (h : SetMaximalConsistent S) (d : DerivationTree fc [] (φ.imp ψ))
    (hφ : φ ∈ S) : ψ ∈ S
```

Essential lemmas for canonical model construction:
- Derivable formulas are in MCS
- Modus ponens reflected in membership
- Negation completeness
- `⊥` is never a member. The lemma is stated on `SetConsistent`, not on
  `SetMaximalConsistent`, because one of its consumers reaches consistency through
  `closure_mcs_consistent` on a `ClosureMCSBundle` rather than holding an MCS;
  `SetMaximalConsistent.bot_not_mem` is the one-line specialization. This pair replaced four
  independent copies scattered across `BXCanonical/`, `WeakCanonical/`, `Algebraic/` and
  `Decidability/`, one of which was the sole reason `WeakCanonical/Transfer.lean` reached into
  `BXCanonical` for a one-liner.
- `mp_of_theorem` collapses the composite idiom
  `implication_property h (theorem_in_mcs h d) hφ` — modus ponens through an MCS against a
  *theorem* of the system — into one application. It was swept through 196 call sites in 25
  files, the single largest consolidation in this directory's API. Note that
  `mp_of_theorem`'s own body is that composite: it is the definition, not a missed site.

**Temporal Properties**:
```lean
lemma SetMaximalConsistent.all_future_all_future {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) {phi : Formula}
    (h : Formula.allFuture phi ∈ S) : Formula.allFuture (Formula.allFuture phi) ∈ S

lemma SetMaximalConsistent.all_past_all_past {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) {phi : Formula}
    (h : Formula.allPast phi ∈ S) : Formula.allPast (Formula.allPast phi) ∈ S
```

These use the derived 4-axiom for temporal operators.

## Decision Record

### MCS Aesop rule set (`mcs_auto`) — evaluated and rejected (2026-09-03)

A named `MCS` Aesop rule set (`safe forward`: `implication_property`, `neg_excludes`;
`unsafe 50%`: `negation_complete`; `norm simp`: `Set.mem_insert_iff`, `Set.mem_singleton_iff`,
`List.mem_cons`) was built and measured. It closes synthetic forward chains of implication
memberships in ~45 ms, where plain `aesop` cannot. It closes **no** real proof in this tree.

The blocker is structural. `negation_complete` is the only rule that helps a goal whose
hypotheses are not already implication memberships, and Aesop cannot instantiate its `φ` — the
real sites need it at a formula (e.g. `φ.imp ψ.neg`) that appears in neither the goal nor the
context. `theorem_in_mcs` and `closed_under_derivation` are inert as forward rules because their
`DerivationTree` argument is constructed inline at every real call site rather than being a
hypothesis available to forward reasoning.

Two mechanical notes, should this ever be revisited: a rule set must be *declared in a separate
imported module* from the one that attributes to it, so a single self-contained `MCSAesop.lean`
is not implementable; and a named set does not pollute Aesop's default set.

**The productive consolidation at these sites is `SetMaximalConsistent.mp_of_theorem` (above),
not automation.** No `MCSAesop.lean`, no `declare_aesop_rule_sets`, no `mcs_auto` macro and no
Aesop attributes exist anywhere in the tree, and that is deliberate.

### Retirements

- The four `RestrictedMCS` boundedness lemmas (`restricted_mcs_iter_F_bound`,
  `restricted_mcs_F_bounded`, `restricted_mcs_iter_P_bound`, `restricted_mcs_P_bounded`) have
  been retired to
  [`Boneyard/RestrictedMCSBoundedness/`](../../Boneyard/RestrictedMCSBoundedness/README.md). They
  had zero references outside their own declaration site, and the consumer they were written for
  is itself archived. That directory's README records the validated `Nat.find` rewrite as the
  alternative to a verbatim resurrection.
- `CanonicalTask_backward` and its family were retired by earlier work to
  `FormalSystem/Boneyard/BundleDeadHalf/CanonicalTaskRelation.lean`. They are intentionally out
  of scope for the Core consolidation and should not be re-opened here.

## Design Notes

### Self-Contained MCS Theory

The MCS theory is fully self-contained in this directory. All definitions and proofs are in
`MaximalConsistent.lean`.

### Deduction Theorem Complexity

The deduction theorem for Hilbert systems requires careful handling:
- Must track derivation structure (axiom, assumption, modus ponens, weakening)
- Modal/temporal K rules do not apply with non-empty contexts
- Uses well-founded recursion on derivation height

### Relationship to Other Modules

The Core modules are prerequisites for:
- `Bundle/` - BFMCS completeness uses MCS extension and truth lemma
- `Algebraic/UltrafilterMCS.lean` - Uses MCS definitions for ultrafilter correspondence

## Dependencies

- **ProofSystem**: Derivation trees and axioms
- **Theorems/Propositional**: Propositional combinator infrastructure

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Bundle README](../Bundle/README.md) - BFMCS completeness (uses Core)
- [Algebraic README](../Algebraic/README.md) - Algebraic approach (uses Core)
- [Boneyard/RestrictedMCSBoundedness](../../Boneyard/RestrictedMCSBoundedness/README.md) - the retired boundedness lemmas

## References

- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
- Lindenbaum's Lemma: Standard application of Zorn's lemma
- Hilbert-style deduction theorem: Standard proof technique

---

*Last verified: 2026-09-03*
