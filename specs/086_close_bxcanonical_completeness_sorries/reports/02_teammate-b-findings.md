# Teammate B Findings: Decidability Audit and Soundness+Decidability=Completeness Composition

**Task**: #86 — Close BXCanonical Completeness Sorries
**Date**: 2026-04-08
**Focus**: Complete decidability audit; assess whether soundness + decidability composes to give completeness

---

## 1. Decidability Directory: Complete Sorry Audit

### Summary: The entire Decidability tree is SORRY-FREE

Every file in `Theories/Bimodal/Metalogic/Decidability/` and its `FMP/` subdirectory was read. Zero sorry sites found.

#### File-by-file inventory

| File | Sorry Count | Content |
|------|-------------|---------|
| `SignedFormula.lean` | 0 | Sign, SignedFormula, Branch types |
| `Tableau.lean` | 0 | Tableau expansion rules |
| `Closure.lean` | 0 | Branch closure detection |
| `Saturation.lean` | 0 | Saturation and fuel-based termination |
| `ProofExtraction.lean` | 0 | Extract DerivationTree from closed tableau (partial: axiom instances only) |
| `CountermodelExtraction.lean` | 0 | Extract countermodel from open branch |
| `DecisionProcedure.lean` | 0 | Main `decide` function |
| `Correctness.lean` | 0 | `validity_decidable`, `fmp_completeness`, `fmp_incompleteness_witness` |
| `FMP/ClosureMCS.lean` | 0 | Closure MCS construction |
| `FMP/DenseFMP.lean` | 0 | Dense FMP variant |
| `FMP/DiscreteFMP.lean` | 0 | Discrete FMP variant |
| `FMP/Filtration.lean` | 0 | Filtration quotient |
| `FMP/FiniteModel.lean` | 0 | Finiteness of filtered model |
| `FMP/FMP.lean` | 0 | Main FMP theorem: `fmp_contrapositive`, `mcs_finite_model_property` |
| `FMP/TruthPreservation.lean` | 0 | MCS truth preservation infrastructure |
| `Decidability.lean` (root) | 0 | Re-export module |

---

## 2. Soundness: Confirmed Sorry-Free

The file `Theories/Bimodal/Metalogic/Soundness.lean` contains three soundness theorems, all sorry-free:

### General Soundness (line 895)

```lean
theorem soundness (Γ : Context) (φ : Formula) :
    DerivationTree Γ φ → (D : Type) → [AddCommGroup D] → [LinearOrder D] → [IsOrderedAddMonoid D] →
    (F : TaskFrame D) → (M : TaskModel F) →
    (Omega : Set (WorldHistory F)) → (h_sc : ShiftClosed Omega) →
    (τ : WorldHistory F) → (h_mem : τ ∈ Omega) → (t : D) →
    (h_ctx : ∀ ψ ∈ Γ, truth_at M Omega τ t ψ) →
    truth_at M Omega τ t φ
```

### Frame-class specific soundness (also sorry-free)

- `soundness_dense_valid` (line 985): `DerivationTree [] phi → isDenseCompatible → valid_dense phi`
- `soundness_dense` (line 1057): Dense-frame semantic consequence
- `soundness_discrete_valid` (line 1145): Discrete-frame validity
- `soundness_discrete` (line 1202): Discrete-frame semantic consequence

---

## 3. What the FMP Actually Proves

The key theorems in `FMP/FMP.lean` are:

### `fmp_contrapositive` (the critical theorem)

```lean
theorem fmp_contrapositive (phi : Formula)
    (h_all_mcs : ∀ (S : ClosureMCSBundle phi), phi ∈ S.carrier) :
    Nonempty (DerivationTree [] phi)
```

This says: **If phi is a member of every closure MCS, then phi is provable.**

### `mcs_finite_model_property`

```lean
theorem mcs_finite_model_property (phi : Formula)
    (h_not_provable : ¬Nonempty (DerivationTree [] phi)) :
    ∃ (S : ClosureMCSBundle phi), phi ∉ S.carrier ∧ Finite (FilteredWorld phi)
```

This says: **If phi is not provable, there exists a closure MCS where phi fails (and the model is finite).**

### Re-exported in `Correctness.lean`

```lean
theorem fmp_completeness (φ : Formula) :
    (∀ (S : FMP.ClosureMCSBundle φ), φ ∈ S.carrier) →
    Nonempty (DerivationTree [] φ) :=
  FMP.fmp_contrapositive φ
```

---

## 4. The Composition Question: Can Soundness + FMP = Completeness?

### What we want

```
valid φ → Nonempty (DerivationTree [] φ)
```

where `valid φ` is defined as:

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

### What we have

1. **Soundness** (sorry-free): `DerivationTree [] φ → valid φ` (specializing Γ = [])
2. **FMP contrapositive** (sorry-free): `(∀ S : ClosureMCSBundle φ, φ ∈ S.carrier) → Nonempty (DerivationTree [] φ)`
3. **FMP witness** (sorry-free): `¬Nonempty (DerivationTree [] φ) → ∃ S : ClosureMCSBundle φ, φ ∉ S.carrier`

### The gap: MCS membership vs semantic truth

The composition DOES NOT directly work because:

- **`valid φ`** quantifies over all TaskModels, TaskFrames, WorldHistories, etc.
- **`fmp_contrapositive`** requires `φ ∈ S.carrier` for all closure MCS `S`.

The missing link is a **truth lemma** connecting MCS membership to semantic truth in some actual TaskModel. Specifically, we need either:

**(A)** `valid φ → ∀ S : ClosureMCSBundle φ, φ ∈ S.carrier` (valid implies MCS membership)

**(B)** An actual TaskModel built from closure MCS where truth = membership

Option (A) would give us completeness immediately:
```
valid φ → (∀ S, φ ∈ S.carrier) → Nonempty (DerivationTree [] φ)
```

But (A) itself IS the completeness theorem in disguise. To prove `valid φ → φ ∈ S` for an arbitrary MCS S, you need to build a model where S is a world and show that `valid φ` implies truth at that world, which implies membership by the truth lemma. This is exactly what the BXCanonical approach does (and where it's stuck).

### The contrapositive composition DOES work (but is circular)

```
¬Nonempty (DerivationTree [] φ)    -- assume not provable
→ ∃ S, φ ∉ S.carrier               -- by FMP witness
→ ???                                -- need: ∃ model M, ¬(M ⊨ φ)
→ ¬valid φ                          -- would give completeness by contrapositive
```

The `???` step is exactly the truth lemma for the filtered/canonical model. The FMP gives us an MCS where φ fails, but to conclude ¬valid φ, we need an ACTUAL semantic model (TaskModel) where φ is false. Converting MCS membership to semantic truth requires the truth lemma, which is what BXCanonical is trying to prove.

### Critical insight: The FMP theorems prove PROOF-THEORETIC facts only

`fmp_contrapositive` and `mcs_finite_model_property` are purely proof-theoretic results:
- They reason about derivability and MCS membership
- They never construct a semantic model
- They never bridge MCS membership ↔ semantic truth

The "completeness" they provide is: `(∀ MCS, φ ∈ MCS) → provable φ`, which is a syntactic completeness result relative to MCS. This is NOT `valid φ → provable φ` because there is no proven connection between `valid` and MCS membership.

---

## 5. What About Classical Excluded Middle?

The `Correctness.lean` file has:

```lean
theorem validity_decidable (φ : Formula) :
    (⊨ φ) ∨ ¬(⊨ φ) := by
  exact Classical.em (⊨ φ)
```

This is just classical logic (`Classical.em`). It tells us nothing computational. There is no `Decidable` instance for `Nonempty (DerivationTree [] φ)`.

Similarly:
```lean
theorem validity_has_decision_procedure (φ : Formula) :
    ∃ (decision : Bool), (decision = true ↔ ⊨ φ) := by
  by_cases h : (⊨ φ)
  · exact ⟨true, by simp [h]⟩
  · exact ⟨false, by simp [h]⟩
```

This is also just classical logic. The `DecisionProcedure.lean` provides a computational `decide` function that returns `DecisionResult φ`, but this is a **Lean program** (def, not theorem). There is no proof that it is correct (i.e., no theorem stating `decide φ = valid ↔ ⊨ φ`).

---

## 6. Syntactic Completeness / Post-Completeness

**Question**: Does the codebase have `¬⊢ φ → ⊢ ¬φ`?

**Answer**: No. This property (Post-completeness / syntactic completeness for individual formulas) does not appear anywhere in the codebase. This is expected because TM bimodal logic is NOT Post-complete (it has contingent formulas).

The alternative composition sketch:
```
valid φ, suppose ¬⊢ φ
By syntactic completeness: ⊢ ¬φ
By soundness: valid ¬φ
Contradiction with valid φ
```

This approach is INVALID for this logic because `¬⊢ φ` does not imply `⊢ ¬φ`. Example: `p` (atomic proposition) is not provable, and `¬p` is also not provable.

---

## 7. Conservative Extension Directory

The `ConservativeExtension/` directory contains:
- `ExtFormula.lean`: Extended formula type with fresh atom
- `ExtDerivation.lean`: Derivation in extended system
- `Substitution.lean`: Substitution infrastructure
- `Lifting.lean`: Lifting infrastructure for projecting back

This is about the conservative extension used for the IRR rule soundness. It does NOT relate decidability to completeness. It proves that adding a fresh atom to the language is conservative (derivability is preserved under the embedding/projection).

---

## 8. BXCanonical Sorry Inventory

For completeness of this audit, the BXCanonical sorry sites are:

| File | Line | What | Classification |
|------|------|------|----------------|
| `Completeness.lean` | 144 | `bx_completeness` | Canonical model construction gap |
| `Frame.lean` | 562 | `bx_until_eventuality_resolution` | Until eventuality resolution |
| `Frame.lean` | 584 | `bx_until_backward` | Until backward direction |
| `Frame.lean` | 599 | `bx_since_eventuality_resolution` | Since eventuality resolution |
| `Frame.lean` | 613 | `bx_since_backward` | Since backward direction |

**Total: 5 sorry sites**

The 4 Frame.lean sorries are all blocked on the same root cause: proving that the BX axioms (BX5 self-accumulation, BX6 absorption, BX7 linearity) can substitute for the removed Until-induction axiom in eventuality resolution. The `bx_completeness` sorry in Completeness.lean depends on these Frame.lean sorries (it needs the truth lemma, which needs eventuality resolution).

---

## 9. Answer to the Core Question

**Can soundness + decidability compose to give completeness in ~100 lines?**

**NO.** The Round 1 assessment was overly optimistic. Here is why:

1. **There is no formal "decidability of provability"** in the codebase. The `validity_decidable` theorem is just `Classical.em`. The `decide` function is a computational procedure with no correctness proof.

2. **The FMP gives proof-theoretic completeness relative to MCS**, not semantic completeness. `fmp_contrapositive` says "true in all MCS implies provable", not "valid implies provable".

3. **The gap between MCS membership and semantic validity is exactly the truth lemma**, which is what BXCanonical is trying to prove and where the sorry sites are.

4. **The composition `valid → MCS-truth → provable` requires building a semantic model from MCS**, which requires the truth lemma. This is not a ~100 line composition; it IS the completeness proof.

### What WOULD give completeness in ~100 lines

If the 4 Frame.lean sorries were resolved (eventuality resolution for Until/Since), then `bx_completeness` would follow because:
- `neg_consistent_of_not_derivable` is already proved
- Lindenbaum extension is already proved
- The truth lemma for atom/bot/imp/box/G/H is already proved
- The truth lemma for Until/Since delegates to the sorry'd eventuality resolution helpers
- The only remaining step is embedding BXPoints into a TaskModel (the final sorry in Completeness.lean)

So the actual path to completeness is: **resolve the 4 eventuality resolution sorries in Frame.lean**, then close the 1 sorry in Completeness.lean. This is NOT a composition exercise; it is a proof-theoretic argument about the BX axiom system's ability to derive eventuality witnesses.

---

## 10. Recommended Path Forward

### Option A: Fix the BXCanonical approach directly (~hard, unknown feasibility)

Resolve `bx_until_eventuality_resolution` and the 3 symmetric helpers. This requires either:
- Proving linearity of `bx_le` on intervals from BX7 (blocked by G-content vs Until-witness mismatch, as documented in Frame.lean)
- Redefining `bx_le` using Until-based witness ordering
- Adopting a quasimodel/filtration approach

### Option B: Use FMP + separate truth lemma (~medium)

Build a TaskModel from the filtered MCS model and prove a truth lemma for it. This would let us compose:
```
valid φ → truth in filtered model → membership in all closure MCS → provable
```
This avoids the BXCanonical ordering issues but requires building the filtered model as an actual TaskModel (with WorldHistories, time domain, etc.), which is non-trivial.

### Option C: Use the Bundle/Algebraic completeness path

The `BaseCompleteness.lean` already has infrastructure for Int-indexed canonical models with truth lemmas. If this path can be completed (it has its own sorries in the Bundle infrastructure), it would give `valid φ → provable φ` without touching BXCanonical at all.

---

## Appendix: Key Type Signatures

```lean
-- Validity
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (h_sc : ShiftClosed Omega) (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ

-- Soundness (sorry-free)
theorem soundness (Γ : Context) (φ : Formula) :
    DerivationTree Γ φ → ... → truth_at M Omega τ t φ

-- FMP contrapositive (sorry-free)
theorem fmp_contrapositive (phi : Formula) :
    (∀ (S : ClosureMCSBundle phi), phi ∈ S.carrier) →
    Nonempty (DerivationTree [] phi)

-- BXCanonical completeness (1 sorry)
theorem bx_completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```
