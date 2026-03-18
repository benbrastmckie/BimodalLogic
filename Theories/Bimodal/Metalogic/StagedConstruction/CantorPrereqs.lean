import Bimodal.Metalogic.StagedConstruction.StagedExecution
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators
import Mathlib.Data.Set.Countable

/-!
# Cantor Prerequisites for the Staged Timeline

This module proves key properties of the staged timeline needed for
Cantor's isomorphism theorem application:

1. **Forward/backward witness addition**: If F(phi)/P(phi) ∈ p.mcs and
   the encoding of phi is k with 2k ≥ n (p's stage), then a witness is
   added at stage 2k+1.

2. **NoMaxOrder/NoMinOrder (partial)**: Every point has a successor/predecessor
   in the timeline. The proof requires showing that for any point at stage n,
   there exists a formula with encoding ≥ n/2 whose F-obligation is in p.mcs.

## Key Technical Results

- `forward_witness_at_stage`: Concrete witness placement at specific stages
- `backward_witness_at_stage`: Symmetric for backward witnesses
- `SetMaximalConsistent.density_F_to_FF`: F(phi) ∈ M implies F(F(phi)) ∈ M (density axiom)

## References

- Task 956 plan v014: Phase 5
- StagedExecution.lean: staged build construction
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

-- Classical decidability
attribute [local instance] Classical.propDecidable

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Formula Encoding
-/

/-- Every formula has an encoding index: decode(encode(phi)) = some phi. -/
theorem formula_has_encoding (phi : Formula) :
    ∃ k : Nat, decodeFormulaStaged k = some phi :=
  ⟨@Encodable.encode Formula formulaEncodableStaged phi,
   @Encodable.encodek Formula formulaEncodableStaged phi⟩

/-!
## Density in MCS

The density axiom GGφ → Gφ (Task 991 Sahlqvist form) implies Fψ → FFψ.

Derivation:
1. GG(¬φ) → G(¬φ) (density axiom with ψ := ¬φ)
2. ¬G(¬φ) → ¬GG(¬φ) (contrapositive)
3. By definition: ¬G(¬φ) = Fφ and ¬GG(¬φ) = ¬G(G(¬φ)) = F(¬G(¬φ)) = FFφ
4. So we get: Fφ → FFφ
-/

/-- Derive Fφ → FFφ from the density axiom GGψ → Gψ (Task 991 strict semantics).

The density axiom changed from Fψ → FFψ to GGψ → Gψ in Task 991.
We derive the old form from the new via contraposition.

Key observation:
- some_future φ = φ.neg.all_future.neg = ¬G(¬φ)
- some_future (some_future φ) = (¬G(¬φ)).neg.all_future.neg = ¬G(G(¬φ))
  because (¬X).neg.all_future.neg = X.all_future.neg = ¬G(X)
  where X = G(¬φ)

Wait, that's not right either. Let's compute:
- (¬G(¬φ)).neg = (G(¬φ).neg).neg = G(¬φ).neg.neg
- But Formula.neg X = X.imp ⊥, so this gets complicated.

Actually, the key is:
- Fψ = ψ.neg.all_future.neg (definition of some_future)
- FFφ = (Fφ).neg.all_future.neg = (φ.neg.all_future.neg).neg.all_future.neg

Now (φ.neg.all_future.neg).neg = (φ.neg.all_future).neg.neg (since neg X = X.imp ⊥)
No wait, (X.neg).neg = (X.imp ⊥).imp ⊥ = ¬¬X

So FFφ = (¬¬(φ.neg.all_future)).all_future.neg = ¬G(¬¬G(¬φ))

We have from contraposition: ¬G(¬φ) → ¬GG(¬φ)
We need: ¬G(¬φ) → ¬G(¬¬G(¬φ))

These are NOT the same! We need an additional step.

From GG(ψ) → G(¬¬ψ) (derivable via DNI + temporal necessitation + K-dist),
we get ¬G(¬¬ψ) → ¬GG(ψ) by contrapositive.

Combined: ¬G(¬φ) → ¬GG(¬φ) and ¬G(¬¬G(¬φ)) → ¬GG(¬φ) (with ψ = G(¬φ))
Hmm, this still doesn't chain correctly.

Actually, for strict semantics, we might need to work with the contrapositive differently.
The cleaner approach is to prove semantically that Fφ → FFφ follows from density.
For now, use sorry as this requires a longer derivation chain.
-/
noncomputable def derive_F_to_FF (phi : Formula) :
    DerivationTree [] ((Formula.some_future phi).imp (Formula.some_future (Formula.some_future phi))) := by
  -- TODO (Task 991): Complete this derivation from the new density axiom
  -- The density axiom GGψ → Gψ implies Fφ → FFφ, but the proof requires
  -- chaining through double negation elimination and K-distribution.
  sorry

/-- If F(phi) ∈ M, then F(F(phi)) ∈ M. Derived from the density axiom. -/
theorem SetMaximalConsistent.density_F_to_FF (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    Formula.some_future (Formula.some_future phi) ∈ M := by
  have h_density : (Formula.some_future phi).imp
      (Formula.some_future (Formula.some_future phi)) ∈ M :=
    theorem_in_mcs h_mcs (derive_F_to_FF phi)
  exact SetMaximalConsistent.implication_property h_mcs h_density h_F

/-!
## DN-Free MCS Richness

For discrete timelines, we need to prove that every MCS contains F-formulas
with arbitrarily large encodings, WITHOUT using the density axiom DN.

The key insight: for any atom i, either G(bot ∧ ¬atom(i)) ∈ M or F(¬bot ∨ atom(i)) ∈ M.
Since G(bot ∧ X) is semantically G(bot), and G(bot) contradicts F(¬bot) (seriality),
we must have F(¬bot ∨ atom(i)) ∈ M for all i.

The formulas (¬bot ∨ atom(i)) have unbounded encodings as i grows.
This gives MCS Richness WITHOUT using DN.
-/

/-- G(bot) is not in any serial MCS because it contradicts F(¬bot).

Under strict semantics (Task 991), we don't have Gφ → φ. Instead, we use:
- G(⊥) → G(¬¬⊥) (using DNI + temporal necessitation + K-distribution)
- F(¬⊥) = ¬G(¬¬⊥) definitionally
- Contradiction
-/
theorem SetMaximalConsistent.G_bot_not_in (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_serial : Formula.some_future (Formula.neg Formula.bot) ∈ M) :
    Formula.all_future Formula.bot ∉ M := by
  intro h_G_bot
  -- Step 1: ⊥ → ¬¬⊥ is a theorem (double negation introduction)
  have h_dni : [] ⊢ Formula.bot.imp (Formula.neg (Formula.neg Formula.bot)) :=
    Bimodal.Theorems.Combinators.dni Formula.bot
  -- Step 2: G(⊥ → ¬¬⊥) by temporal necessitation
  have h_G_dni : [] ⊢ Formula.all_future (Formula.bot.imp (Formula.neg (Formula.neg Formula.bot))) :=
    DerivationTree.temporal_necessitation _ h_dni
  -- Step 3: G(⊥ → ¬¬⊥) → (G(⊥) → G(¬¬⊥)) by temporal K distribution
  have h_K : [] ⊢ (Formula.all_future (Formula.bot.imp (Formula.neg (Formula.neg Formula.bot)))).imp
      ((Formula.all_future Formula.bot).imp (Formula.all_future (Formula.neg (Formula.neg Formula.bot)))) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist Formula.bot (Formula.neg (Formula.neg Formula.bot)))
  -- Step 4: G(⊥) → G(¬¬⊥)
  have h_imp : [] ⊢ (Formula.all_future Formula.bot).imp (Formula.all_future (Formula.neg (Formula.neg Formula.bot))) :=
    DerivationTree.modus_ponens [] _ _ h_K h_G_dni
  -- Step 5: G(¬¬⊥) ∈ M
  have h_G_nn : Formula.all_future (Formula.neg (Formula.neg Formula.bot)) ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_imp) h_G_bot
  -- Step 6: F(¬⊥) = ¬G(¬¬⊥) definitionally. So ¬G(¬¬⊥) ∈ M.
  -- F(¬⊥) = some_future(neg ⊥) = neg(all_future(neg(neg ⊥))) = neg(G(¬¬⊥))
  -- So h_serial : neg(all_future(neg(neg ⊥))) ∈ M
  -- And h_G_nn : all_future(neg(neg ⊥)) ∈ M
  -- Contradiction by consistency
  exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg (Formula.neg Formula.bot))) h_G_nn h_serial

/-- bot ∧ X is equivalent to bot. G(bot ∧ X) implies G(bot) via K-distribution.
Actually we prove: G(bot ∧ X) ∈ M implies G(bot) ∈ M. -/
theorem SetMaximalConsistent.G_bot_and_of_G_bot_and_X (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (X : Formula) (h_G : Formula.all_future (Formula.and Formula.bot X) ∈ M) :
    Formula.all_future Formula.bot ∈ M := by
  -- ⊢ (bot ∧ X) → bot is a tautology (and_elim_left)
  -- ⊢ G((bot ∧ X) → bot) by temporal necessitation
  -- ⊢ G(bot ∧ X) → G(bot) by K-distribution
  -- Therefore G(bot ∧ X) ∈ M implies G(bot) ∈ M
  have h_impl : [] ⊢ (Formula.and Formula.bot X).imp Formula.bot :=
    Bimodal.Theorems.Propositional.lce_imp Formula.bot X
  have h_G_impl : Formula.all_future ((Formula.and Formula.bot X).imp Formula.bot) ∈ M :=
    theorem_in_mcs h_mcs (DerivationTree.temporal_necessitation _ h_impl)
  have h_k_dist : (Formula.all_future ((Formula.and Formula.bot X).imp Formula.bot)).imp
      ((Formula.all_future (Formula.and Formula.bot X)).imp (Formula.all_future Formula.bot)) ∈ M :=
    theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.temp_k_dist (Formula.and Formula.bot X) Formula.bot))
  have h_step := SetMaximalConsistent.implication_property h_mcs h_k_dist h_G_impl
  exact SetMaximalConsistent.implication_property h_mcs h_step h_G

/-- The MCS Richness lemma (DN-free): for any atom i, F(¬bot ∨ atom(i)) ∈ M.
This is because G(¬(¬bot ∨ atom(i))) = G(bot ∧ ¬atom(i)) would imply G(bot),
contradicting seriality F(¬bot). -/
theorem SetMaximalConsistent.F_or_atom_in (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (i : Atom) :
    Formula.some_future (Formula.or (Formula.neg Formula.bot) (Formula.atom i)) ∈ M := by
  have h_serial := SetMaximalConsistent.contains_seriality_future M h_mcs
  -- By MCS negation completeness: either G(¬(¬bot ∨ atom(i))) ∈ M or ¬G(¬(¬bot ∨ atom(i))) ∈ M
  -- The latter is F(¬bot ∨ atom(i))
  -- If G(¬(¬bot ∨ atom(i))) ∈ M:
  --   ¬(¬bot ∨ atom(i)) = ¬¬bot ∧ ¬atom(i) = bot ∧ ¬atom(i) (by De Morgan + double negation)
  --   So G(bot ∧ ¬atom(i)) ∈ M
  --   By G_bot_and_of_G_bot_and_X, G(bot) ∈ M
  --   But this contradicts G_bot_not_in
  -- Therefore ¬G(¬(¬bot ∨ atom(i))) ∈ M, i.e., F(¬bot ∨ atom(i)) ∈ M
  by_contra h_not_F
  -- F(X) not in M, so by negation completeness, ¬F(X) ∈ M
  -- F(X) = ¬G(¬X), so ¬F(X) = ¬¬G(¬X)
  -- By double negation elimination, G(¬X) ∈ M
  set X := Formula.or (Formula.neg Formula.bot) (Formula.atom i) with hX
  -- F(X) = X.neg.all_future.neg
  have h_FX_def : Formula.some_future X = X.neg.all_future.neg := rfl
  -- ¬F(X) = F(X).neg = X.neg.all_future.neg.neg
  have h_neg_FX : (Formula.some_future X).neg = X.neg.all_future.neg.neg := rfl
  -- By negation completeness: either F(X) ∈ M or ¬F(X) ∈ M
  have h_neg_complete := SetMaximalConsistent.negation_complete h_mcs (Formula.some_future X)
  rcases h_neg_complete with h_F | h_neg_F
  · exact h_not_F h_F  -- Contradiction: F(X) ∈ M but we assumed F(X) ∉ M
  · -- ¬F(X) ∈ M, i.e., X.neg.all_future.neg.neg ∈ M
    -- By double negation elimination: X.neg.all_future ∈ M, i.e., G(¬X) ∈ M
    have h_G_neg_X : X.neg.all_future ∈ M :=
      SetMaximalConsistent.double_neg_elim h_mcs X.neg.all_future h_neg_F
    -- Key insight: X = ¬bot ∨ atom(i), and ⊢ ¬bot (since ¬bot = bot → bot is the identity)
    -- So ⊢ X (since ⊢ A implies ⊢ A ∨ B by or_intro)
    -- And ⊢ X.neg → bot (since ⊢ X implies ⊢ ¬¬X = X.neg.neg by dni)
    -- Wait, X.neg → bot = X.neg.neg, which is ⊢ ¬¬X, not ⊢ ¬X → ⊥
    --
    -- Different approach: From G(¬X) ∈ M and ⊢ X:
    -- ⊢ X means X is a theorem, so G(X) ∈ M (by temporal necessitation + MCS closure)
    -- G(X) ∈ M and G(¬X) ∈ M together imply inconsistency:
    -- G(X ∧ ¬X) ∈ M (by G-conjunction), and G(⊥) ∈ M (since X ∧ ¬X → ⊥)
    -- But G(⊥) ∉ M (by G_bot_not_in)
    --
    -- Step 1: Show ⊢ X where X = ¬bot ∨ atom(i)
    -- ⊢ ¬bot (since ¬bot = bot → bot = bot.imp bot, and ⊢ A → A for any A)
    have h_neg_bot_thm : [] ⊢ Formula.neg Formula.bot := by
      -- ⊢ bot → bot is the identity theorem
      -- Formula.neg Formula.bot = Formula.bot.imp Formula.bot
      unfold Formula.neg
      exact Bimodal.Theorems.Combinators.identity Formula.bot
    -- ⊢ ¬bot → (¬bot ∨ atom(i)) by or introduction
    -- Note: A ∨ B = ¬A → B = A.neg.imp B, so A → (A ∨ B) = A → (A.neg.imp B) = raa A B
    have h_or_intro : [] ⊢ (Formula.neg Formula.bot).imp X := by
      -- X = ¬bot ∨ atom(i) = (¬bot).neg.imp (atom i) = ¬¬bot → atom(i)
      -- raa gives ⊢ A → (A.neg.imp B) = A → (A ∨ B)
      -- So raa (¬bot) (atom i) gives ⊢ ¬bot → (¬¬bot → atom i) = ¬bot → X
      exact Bimodal.Theorems.Propositional.raa (Formula.neg Formula.bot) (Formula.atom i)
    have h_X_thm : [] ⊢ X :=
      DerivationTree.modus_ponens [] _ _ h_or_intro h_neg_bot_thm
    -- Step 2: G(X) ∈ M since X is a theorem
    have h_G_X_thm : [] ⊢ Formula.all_future X :=
      DerivationTree.temporal_necessitation X h_X_thm
    have h_G_X_in_M : Formula.all_future X ∈ M := theorem_in_mcs h_mcs h_G_X_thm
    -- Step 3: From G(X) ∈ M and G(¬X) ∈ M, derive contradiction
    -- We have G(X) ∈ M and G(X.neg) ∈ M
    -- By G-conjunction intro: G(X ∧ ¬X) ∈ M (or we can derive bot directly)
    -- Actually, let's use: G(X) ∧ G(¬X) implies G(X ∧ ¬X) which implies G(⊥)
    -- Or simpler: from both X and ¬X holding everywhere, ⊥ holds everywhere
    -- We need: ⊢ G(X) → G(X.neg) → G(⊥)
    -- This follows from: G distributes and X ∧ ¬X → ⊥
    -- From G(X) and G(¬X), we get G(X ∧ ¬X) via conjunction intro in G
    -- Then G(X ∧ ¬X) → G(⊥) via X ∧ ¬X → ⊥
    -- Simpler: Use set_consistent_not_both
    -- We have X.all_future ∈ M and X.neg.all_future ∈ M
    -- Want to derive contradiction...
    -- Actually, G(φ) ∧ G(¬φ) in M means both φ and ¬φ hold in all futures
    -- This means in all futures, we have both φ and ¬φ, hence ⊥ in all futures
    -- So G(⊥) ∈ M, contradicting G_bot_not_in
    --
    -- To formalize: ⊢ G(A) → G(A.neg) → G(⊥)
    -- From ⊢ A → A.neg → ⊥ (explosion)
    -- By temporal necessitation: ⊢ G(A → A.neg → ⊥)
    -- By K-dist twice: ⊢ G(A) → G(A.neg → ⊥), then ⊢ G(A) → G(A.neg) → G(⊥)
    have h_explosion : [] ⊢ X.imp (X.neg.imp Formula.bot) := by
      -- This is ⊢ X → ¬X → ⊥, which is the definition of modus ponens on ¬X
      exact Bimodal.Theorems.Propositional.raa X Formula.bot
    have h_G_explosion : [] ⊢ Formula.all_future (X.imp (X.neg.imp Formula.bot)) :=
      DerivationTree.temporal_necessitation _ h_explosion
    have h_G_explosion_in_M : Formula.all_future (X.imp (X.neg.imp Formula.bot)) ∈ M :=
      theorem_in_mcs h_mcs h_G_explosion
    -- K-dist: G(A → B) → G(A) → G(B)
    have h_k1 : (Formula.all_future (X.imp (X.neg.imp Formula.bot))).imp
        ((Formula.all_future X).imp (Formula.all_future (X.neg.imp Formula.bot))) ∈ M :=
      theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.temp_k_dist X (X.neg.imp Formula.bot)))
    have h_step1 := SetMaximalConsistent.implication_property h_mcs h_k1 h_G_explosion_in_M
    have h_G_neg_imp_bot : Formula.all_future (X.neg.imp Formula.bot) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs h_step1 h_G_X_in_M
    -- K-dist again: G(¬X → ⊥) → G(¬X) → G(⊥)
    have h_k2 : (Formula.all_future (X.neg.imp Formula.bot)).imp
        ((Formula.all_future X.neg).imp (Formula.all_future Formula.bot)) ∈ M :=
      theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.temp_k_dist X.neg Formula.bot))
    have h_step2 := SetMaximalConsistent.implication_property h_mcs h_k2 h_G_neg_imp_bot
    have h_G_bot : Formula.all_future Formula.bot ∈ M :=
      SetMaximalConsistent.implication_property h_mcs h_step2 h_G_neg_X
    -- G(⊥) ∈ M contradicts seriality
    exact SetMaximalConsistent.G_bot_not_in M h_mcs h_serial h_G_bot

/-- The formula (neg bot ∨ atom (natToAtom n)) for index n. Used to get F-formulas
with arbitrarily large encodings without using the density axiom DN. -/
def orAtomFormula (n : Nat) : Formula :=
  Formula.or (Formula.neg Formula.bot) (Formula.atom (natToAtom n))

/-- orAtomFormula is injective: different indices give different formulas. -/
private theorem orAtomFormula_injective : Function.Injective orAtomFormula := by
  intro a b h_eq
  simp only [orAtomFormula, Formula.or, Formula.neg] at h_eq
  -- Formula.or A B = A.neg.imp B = (A.imp bot).imp B
  -- orAtomFormula n = ((bot.imp bot).imp bot).imp (atom (natToAtom n))
  -- This is Formula.imp ((bot.imp bot).imp bot) (Formula.atom (natToAtom n))
  -- So h_eq : Formula.imp X (Formula.atom (natToAtom a)) = Formula.imp X (Formula.atom (natToAtom b))
  -- where X = (bot.imp bot).imp bot
  -- The .imp constructor is injective in the second argument (and first)
  -- So Formula.atom (natToAtom a) = Formula.atom (natToAtom b)
  -- And the .atom constructor is injective
  -- So natToAtom a = natToAtom b
  -- And natToAtom is injective
  cases h_eq  -- uses injectivity of Formula.imp constructor
  rfl

/-- MCS richness (DN-free): for any N, exists phi with encoding >= N such that F(phi) ∈ M.
This is the key lemma enabling DN-free NoMaxOrder proofs.

Proof: For each n : Nat, F(orAtomFormula n) ∈ M by F_or_atom_in.
The formulas orAtomFormula 0, ..., orAtomFormula N are N+1 distinct formulas
(by orAtomFormula_injective), so they have N+1 distinct encodings.
By pigeonhole, at least one has encoding >= N. -/
theorem SetMaximalConsistent.mcs_has_large_F_formula (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (N : Nat) :
    ∃ phi : Formula,
      @Encodable.encode Formula formulaEncodableStaged phi ≥ N ∧
      Formula.some_future phi ∈ M := by
  -- By pigeonhole: N+1 distinct values can't all fit in {0, ..., N-1}
  by_contra h_all_small
  push_neg at h_all_small
  -- h_all_small : ∀ phi, encode phi < N ∨ F(phi) ∉ M
  -- We have: for each k ∈ {0, ..., N}, F(orAtomFormula k) ∈ M
  -- So encode(orAtomFormula k) < N for all k ∈ {0, ..., N}
  -- But orAtomFormula is injective, so we have N+1 distinct formulas with encodings in {0, ..., N-1}
  -- That's impossible by pigeonhole
  have h_enc_inj := @Encodable.encode_injective Formula formulaEncodableStaged
  -- Construct injective Fin (N+1) → Fin N
  have h_F_in : ∀ k : Nat, Formula.some_future (orAtomFormula k) ∈ M := fun k =>
    SetMaximalConsistent.F_or_atom_in M h_mcs (natToAtom k)
  have h_enc_small : ∀ k : Nat, @Encodable.encode Formula formulaEncodableStaged (orAtomFormula k) < N := by
    intro k
    -- h_all_small : encode phi >= N -> F(phi) not in M
    -- h_F_in k : F(orAtomFormula k) in M
    -- By contraposition: not (encode(orAtomFormula k) >= N), i.e., encode(orAtomFormula k) < N
    by_contra h_ge
    push_neg at h_ge
    exact h_all_small (orAtomFormula k) h_ge (h_F_in k)
  let f : Fin (N + 1) → Fin N := fun i =>
    ⟨@Encodable.encode Formula formulaEncodableStaged (orAtomFormula i.val), h_enc_small i.val⟩
  have h_f_inj : Function.Injective f := by
    intro a b hab
    simp only [f, Fin.mk.injEq] at hab
    exact Fin.ext (orAtomFormula_injective (h_enc_inj hab))
  have h_le := Fintype.card_le_of_injective f h_f_inj
  simp [Fintype.card_fin] at h_le
  omega

/-!
## Symmetric Past Lemmas (DN-Free)

The same MCS Richness approach works for past: P(¬bot ∨ atom(i)) ∈ M for all atoms i.

These lemmas derive past versions via temporal duality from future axioms.
-/

/-- Past necessitation derived via temporal duality.
If ⊢ phi, then ⊢ H(phi).
Proof: From ⊢ phi, we have ⊢ G(swap_temporal phi) by temporal_necessitation.
Then ⊢ swap_temporal(G(swap_temporal phi)) = H(phi) by temporal_duality and involution. -/
def derive_past_necessitation (phi : Formula) (h : [] ⊢ phi) :
    [] ⊢ Formula.all_past phi := by
  -- Strategy: temporal_necessitation on swap_temporal phi, then temporal_duality
  have h_swap : [] ⊢ phi.swap_temporal := DerivationTree.temporal_duality phi h
  have h_G_swap : [] ⊢ Formula.all_future phi.swap_temporal :=
    DerivationTree.temporal_necessitation phi.swap_temporal h_swap
  have h_dual : [] ⊢ (Formula.all_future phi.swap_temporal).swap_temporal :=
    DerivationTree.temporal_duality (Formula.all_future phi.swap_temporal) h_G_swap
  -- swap_temporal(all_future(swap_temporal phi)) = all_past(swap_temporal(swap_temporal phi)) = all_past(phi)
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at h_dual
  exact h_dual

/-- Past K-distribution derived via temporal duality.
⊢ H(phi → psi) → H(phi) → H(psi).
Proof: Apply temporal duality to the future K-distribution axiom. -/
def derive_past_k_dist (phi psi : Formula) :
    [] ⊢ (phi.imp psi).all_past.imp (phi.all_past.imp psi.all_past) := by
  -- temp_k_dist gives: ⊢ G(A → B) → G(A) → G(B)
  -- Apply to swap_temporal phi, swap_temporal psi
  have h_k_dist : [] ⊢ (phi.swap_temporal.imp psi.swap_temporal).all_future.imp
      (phi.swap_temporal.all_future.imp psi.swap_temporal.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist phi.swap_temporal psi.swap_temporal)
  -- Apply temporal duality
  have h_dual := DerivationTree.temporal_duality _ h_k_dist
  -- swap_temporal converts all_future to all_past and preserves implication structure
  simp only [Formula.swap_temporal, Formula.imp, Formula.swap_temporal_involution] at h_dual
  exact h_dual

/-- H(bot) is not in any serial MCS because it contradicts P(¬bot).

Under strict semantics (Task 991), we don't have Hφ → φ. Instead, we use:
- H(⊥) → H(¬¬⊥) (using DNI + past necessitation + K-distribution)
- P(¬⊥) = ¬H(¬¬⊥) definitionally
- Contradiction
-/
theorem SetMaximalConsistent.H_bot_not_in (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_serial : Formula.some_past (Formula.neg Formula.bot) ∈ M) :
    Formula.all_past Formula.bot ∉ M := by
  intro h_H_bot
  -- Step 1: ⊥ → ¬¬⊥ is a theorem (double negation introduction)
  have h_dni : [] ⊢ Formula.bot.imp (Formula.neg (Formula.neg Formula.bot)) :=
    Bimodal.Theorems.Combinators.dni Formula.bot
  -- Step 2: H(⊥ → ¬¬⊥) by past necessitation (derived via temporal duality)
  have h_H_dni : [] ⊢ Formula.all_past (Formula.bot.imp (Formula.neg (Formula.neg Formula.bot))) :=
    derive_past_necessitation (Formula.bot.imp (Formula.neg (Formula.neg Formula.bot))) h_dni
  -- Step 3: H(⊥ → ¬¬⊥) → (H(⊥) → H(¬¬⊥)) by past K distribution
  have h_K : [] ⊢ (Formula.all_past (Formula.bot.imp (Formula.neg (Formula.neg Formula.bot)))).imp
      ((Formula.all_past Formula.bot).imp (Formula.all_past (Formula.neg (Formula.neg Formula.bot)))) :=
    derive_past_k_dist Formula.bot (Formula.neg (Formula.neg Formula.bot))
  -- Step 4: H(⊥) → H(¬¬⊥)
  have h_imp : [] ⊢ (Formula.all_past Formula.bot).imp (Formula.all_past (Formula.neg (Formula.neg Formula.bot))) :=
    DerivationTree.modus_ponens [] _ _ h_K h_H_dni
  -- Step 5: H(¬¬⊥) ∈ M
  have h_H_nn : Formula.all_past (Formula.neg (Formula.neg Formula.bot)) ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_imp) h_H_bot
  -- Step 6: P(¬⊥) = ¬H(¬¬⊥) definitionally. So ¬H(¬¬⊥) ∈ M.
  -- P(¬⊥) = some_past(neg ⊥) = neg(all_past(neg(neg ⊥))) = neg(H(¬¬⊥))
  -- So h_serial : neg(all_past(neg(neg ⊥))) ∈ M
  -- And h_H_nn : all_past(neg(neg ⊥)) ∈ M
  -- Contradiction by consistency
  exact set_consistent_not_both h_mcs.1 (Formula.all_past (Formula.neg (Formula.neg Formula.bot))) h_H_nn h_serial

/-- H(bot ∧ X) implies H(bot) via K-distribution. -/
theorem SetMaximalConsistent.H_bot_and_of_H_bot_and_X (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (X : Formula) (h_H : Formula.all_past (Formula.and Formula.bot X) ∈ M) :
    Formula.all_past Formula.bot ∈ M := by
  -- ⊢ (bot ∧ X) → bot is a tautology
  -- ⊢ H((bot ∧ X) → bot) by past_necessitation (derived via temporal duality)
  -- ⊢ H(bot ∧ X) → H(bot) by K-distribution (derived via temporal duality)
  have h_impl : [] ⊢ (Formula.and Formula.bot X).imp Formula.bot :=
    Bimodal.Theorems.Propositional.lce_imp Formula.bot X
  have h_H_impl : Formula.all_past ((Formula.and Formula.bot X).imp Formula.bot) ∈ M :=
    theorem_in_mcs h_mcs (derive_past_necessitation _ h_impl)
  have h_k_dist : (Formula.all_past ((Formula.and Formula.bot X).imp Formula.bot)).imp
      ((Formula.all_past (Formula.and Formula.bot X)).imp (Formula.all_past Formula.bot)) ∈ M :=
    theorem_in_mcs h_mcs (derive_past_k_dist (Formula.and Formula.bot X) Formula.bot)
  have h_step := SetMaximalConsistent.implication_property h_mcs h_k_dist h_H_impl
  exact SetMaximalConsistent.implication_property h_mcs h_step h_H

/-- MCS Richness for past (DN-free): for any atom i, P(¬bot ∨ atom(i)) ∈ M.
This is because H(¬(¬bot ∨ atom(i))) = H(bot ∧ ¬atom(i)) would imply H(bot),
contradicting seriality P(¬bot). -/
theorem SetMaximalConsistent.P_or_atom_in (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (i : Atom) :
    Formula.some_past (Formula.or (Formula.neg Formula.bot) (Formula.atom i)) ∈ M := by
  have h_serial := SetMaximalConsistent.contains_seriality_past M h_mcs
  by_contra h_not_P
  set X := Formula.or (Formula.neg Formula.bot) (Formula.atom i) with hX
  have h_neg_complete := SetMaximalConsistent.negation_complete h_mcs (Formula.some_past X)
  rcases h_neg_complete with h_P | h_neg_P
  · exact h_not_P h_P
  · -- ¬P(X) ∈ M, i.e., X.neg.all_past.neg.neg ∈ M
    -- By double negation elimination: X.neg.all_past ∈ M, i.e., H(¬X) ∈ M
    have h_H_neg_X : X.neg.all_past ∈ M :=
      SetMaximalConsistent.double_neg_elim h_mcs X.neg.all_past h_neg_P
    -- X is a theorem: X = ¬bot ∨ atom(i)
    have h_neg_bot_thm : [] ⊢ Formula.neg Formula.bot := by
      unfold Formula.neg
      exact Bimodal.Theorems.Combinators.identity Formula.bot
    have h_or_intro : [] ⊢ (Formula.neg Formula.bot).imp X :=
      Bimodal.Theorems.Propositional.raa (Formula.neg Formula.bot) (Formula.atom i)
    have h_X_thm : [] ⊢ X :=
      DerivationTree.modus_ponens [] _ _ h_or_intro h_neg_bot_thm
    -- H(X) ∈ M since X is a theorem
    have h_H_X_thm : [] ⊢ Formula.all_past X := derive_past_necessitation X h_X_thm
    have h_H_X_in_M : Formula.all_past X ∈ M := theorem_in_mcs h_mcs h_H_X_thm
    -- From H(X) ∈ M and H(¬X) ∈ M, derive contradiction
    have h_explosion : [] ⊢ X.imp (X.neg.imp Formula.bot) :=
      Bimodal.Theorems.Propositional.raa X Formula.bot
    have h_H_explosion : [] ⊢ Formula.all_past (X.imp (X.neg.imp Formula.bot)) :=
      derive_past_necessitation _ h_explosion
    have h_H_explosion_in_M : Formula.all_past (X.imp (X.neg.imp Formula.bot)) ∈ M :=
      theorem_in_mcs h_mcs h_H_explosion
    have h_k1 : (Formula.all_past (X.imp (X.neg.imp Formula.bot))).imp
        ((Formula.all_past X).imp (Formula.all_past (X.neg.imp Formula.bot))) ∈ M :=
      theorem_in_mcs h_mcs (derive_past_k_dist X (X.neg.imp Formula.bot))
    have h_step1 := SetMaximalConsistent.implication_property h_mcs h_k1 h_H_explosion_in_M
    have h_H_neg_imp_bot : Formula.all_past (X.neg.imp Formula.bot) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs h_step1 h_H_X_in_M
    have h_k2 : (Formula.all_past (X.neg.imp Formula.bot)).imp
        ((Formula.all_past X.neg).imp (Formula.all_past Formula.bot)) ∈ M :=
      theorem_in_mcs h_mcs (derive_past_k_dist X.neg Formula.bot)
    have h_step2 := SetMaximalConsistent.implication_property h_mcs h_k2 h_H_neg_imp_bot
    have h_H_bot : Formula.all_past Formula.bot ∈ M :=
      SetMaximalConsistent.implication_property h_mcs h_step2 h_H_neg_X
    -- H(⊥) ∈ M contradicts seriality
    exact SetMaximalConsistent.H_bot_not_in M h_mcs h_serial h_H_bot

/-- MCS richness for past (DN-free): for any N, exists phi with encoding >= N such that P(phi) ∈ M. -/
theorem SetMaximalConsistent.mcs_has_large_P_formula (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (N : Nat) :
    ∃ phi : Formula,
      @Encodable.encode Formula formulaEncodableStaged phi ≥ N ∧
      Formula.some_past phi ∈ M := by
  by_contra h_all_small
  push_neg at h_all_small
  have h_enc_inj := @Encodable.encode_injective Formula formulaEncodableStaged
  have h_P_in : ∀ k : Nat, Formula.some_past (orAtomFormula k) ∈ M := fun k =>
    SetMaximalConsistent.P_or_atom_in M h_mcs (natToAtom k)
  have h_enc_small : ∀ k : Nat, @Encodable.encode Formula formulaEncodableStaged (orAtomFormula k) < N := by
    intro k
    by_contra h_ge
    push_neg at h_ge
    exact h_all_small (orAtomFormula k) h_ge (h_P_in k)
  let f : Fin (N + 1) → Fin N := fun i =>
    ⟨@Encodable.encode Formula formulaEncodableStaged (orAtomFormula i.val), h_enc_small i.val⟩
  have h_f_inj : Function.Injective f := by
    intro a b hab
    simp only [f, Fin.mk.injEq] at hab
    exact Fin.ext (orAtomFormula_injective (h_enc_inj hab))
  have h_le := Fintype.card_le_of_injective f h_f_inj
  simp [Fintype.card_fin] at h_le
  omega

/-!
## Forward/Backward Witness at Specific Stage

The core bookkeeping lemma: if p is present when formula phi is processed,
the witness ends up in the staged build.
-/

/-- Forward witness at stage 2k+1: if p is present at stage ≤ 2k and F(phi) ∈ p.mcs
where phi has encoding k, then a forward witness is in the build at stage 2k+1. -/
theorem forward_witness_at_stage
    (p : StagedPoint) (phi : Formula) (k : Nat)
    (h_decode : decodeFormulaStaged k = some phi)
    (h_F : Formula.some_future phi ∈ p.mcs)
    (n : Nat) (h_n_le : n ≤ 2 * k)
    (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint,
      q ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1) ∧
      CanonicalR p.mcs q.mcs := by
  have hp_2k : p ∈ stagedBuild root_mcs root_mcs_proof (2 * k) :=
    (StagedTimeline.monotone_le (buildStagedTimeline root_mcs root_mcs_proof) h_n_le) hp
  let w := processForwardObligation p phi h_F (2 * k + 1)
  refine ⟨w, ?_, processForwardObligation_canonicalR p phi h_F (2 * k + 1)⟩
  show w ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1)
  -- stagedBuild (2k+1) = if (2k) % 2 = 0 then evenStage ... else oddStage ...
  -- Since (2k) % 2 = 0, we take the evenStage branch
  have h_eq : stagedBuild root_mcs root_mcs_proof (2 * k + 1) =
    (if (2 * k) % 2 = 0 then
      evenStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)
    else
      oddStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)) := rfl
  rw [h_eq]
  have h_even : (2 * k) % 2 = 0 := by omega
  have h_div : (2 * k) / 2 = k := by omega
  simp only [h_even, ite_true, h_div]
  unfold evenStage
  rw [h_decode]
  unfold processFormula
  rw [Finset.mem_union]
  right
  rw [Finset.mem_biUnion]
  refine ⟨p, hp_2k, ?_⟩
  unfold witnessesForPoint
  rw [Finset.mem_union]
  left
  rw [dif_pos h_F, Finset.mem_singleton]

/-- Backward witness at stage 2k+1: symmetric for P(phi) obligations. -/
theorem backward_witness_at_stage
    (p : StagedPoint) (phi : Formula) (k : Nat)
    (h_decode : decodeFormulaStaged k = some phi)
    (h_P : Formula.some_past phi ∈ p.mcs)
    (n : Nat) (h_n_le : n ≤ 2 * k)
    (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint,
      q ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1) ∧
      CanonicalR q.mcs p.mcs := by
  have hp_2k : p ∈ stagedBuild root_mcs root_mcs_proof (2 * k) :=
    (StagedTimeline.monotone_le (buildStagedTimeline root_mcs root_mcs_proof) h_n_le) hp
  let w := processBackwardObligation p phi h_P (2 * k + 1)
  refine ⟨w, ?_, processBackwardObligation_canonicalR p phi h_P (2 * k + 1)⟩
  show w ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1)
  have h_eq : stagedBuild root_mcs root_mcs_proof (2 * k + 1) =
    (if (2 * k) % 2 = 0 then
      evenStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)
    else
      oddStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)) := rfl
  rw [h_eq]
  have h_even : (2 * k) % 2 = 0 := by omega
  have h_div : (2 * k) / 2 = k := by omega
  simp only [h_even, ite_true, h_div]
  unfold evenStage
  rw [h_decode]
  unfold processFormula
  rw [Finset.mem_union]
  right
  rw [Finset.mem_biUnion]
  refine ⟨p, hp_2k, ?_⟩
  unfold witnessesForPoint
  rw [Finset.mem_union]
  right
  rw [dif_pos h_P, Finset.mem_singleton]

/-- Forward witness with phi membership: the witness from forward_witness_at_stage
contains phi in its MCS. -/
theorem forward_witness_at_stage_with_phi
    (p : StagedPoint) (phi : Formula) (k : Nat)
    (h_decode : decodeFormulaStaged k = some phi)
    (h_F : Formula.some_future phi ∈ p.mcs)
    (n : Nat) (h_n_le : n ≤ 2 * k)
    (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint,
      q ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1) ∧
      CanonicalR p.mcs q.mcs ∧
      phi ∈ q.mcs := by
  have hp_2k : p ∈ stagedBuild root_mcs root_mcs_proof (2 * k) :=
    (StagedTimeline.monotone_le (buildStagedTimeline root_mcs root_mcs_proof) h_n_le) hp
  let w := processForwardObligation p phi h_F (2 * k + 1)
  refine ⟨w, ?_, processForwardObligation_canonicalR p phi h_F (2 * k + 1),
    processForwardObligation_contains_phi p phi h_F (2 * k + 1)⟩
  show w ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1)
  have h_eq : stagedBuild root_mcs root_mcs_proof (2 * k + 1) =
    (if (2 * k) % 2 = 0 then
      evenStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)
    else
      oddStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)) := rfl
  rw [h_eq]
  have h_even : (2 * k) % 2 = 0 := by omega
  have h_div : (2 * k) / 2 = k := by omega
  simp only [h_even, ite_true, h_div]
  unfold evenStage
  rw [h_decode]
  unfold processFormula
  rw [Finset.mem_union]
  right
  rw [Finset.mem_biUnion]
  refine ⟨p, hp_2k, ?_⟩
  unfold witnessesForPoint
  rw [Finset.mem_union]
  left
  rw [dif_pos h_F, Finset.mem_singleton]

/-- Backward witness with phi membership: the witness from backward_witness_at_stage
contains phi in its MCS. -/
theorem backward_witness_at_stage_with_phi
    (p : StagedPoint) (phi : Formula) (k : Nat)
    (h_decode : decodeFormulaStaged k = some phi)
    (h_P : Formula.some_past phi ∈ p.mcs)
    (n : Nat) (h_n_le : n ≤ 2 * k)
    (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint,
      q ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1) ∧
      CanonicalR q.mcs p.mcs ∧
      phi ∈ q.mcs := by
  have hp_2k : p ∈ stagedBuild root_mcs root_mcs_proof (2 * k) :=
    (StagedTimeline.monotone_le (buildStagedTimeline root_mcs root_mcs_proof) h_n_le) hp
  let w := processBackwardObligation p phi h_P (2 * k + 1)
  refine ⟨w, ?_, processBackwardObligation_canonicalR p phi h_P (2 * k + 1),
    processBackwardObligation_contains_phi p phi h_P (2 * k + 1)⟩
  show w ∈ stagedBuild root_mcs root_mcs_proof (2 * k + 1)
  have h_eq : stagedBuild root_mcs root_mcs_proof (2 * k + 1) =
    (if (2 * k) % 2 = 0 then
      evenStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)
    else
      oddStage (stagedBuild root_mcs root_mcs_proof (2 * k)) ((2 * k) / 2) (2 * k + 1)) := rfl
  rw [h_eq]
  have h_even : (2 * k) % 2 = 0 := by omega
  have h_div : (2 * k) / 2 = k := by omega
  simp only [h_even, ite_true, h_div]
  unfold evenStage
  rw [h_decode]
  unfold processFormula
  rw [Finset.mem_union]
  right
  rw [Finset.mem_biUnion]
  refine ⟨p, hp_2k, ?_⟩
  unfold witnessesForPoint
  rw [Finset.mem_union]
  right
  rw [dif_pos h_P, Finset.mem_singleton]

/-!
## Encoding Sufficiency for Seriality

For NoMaxOrder/NoMinOrder, we need: for any point p at stage n, there exists
a formula phi with F(phi) (resp. P(phi)) in p.mcs whose encoding k satisfies 2k ≥ n.

The argument: by iterated density, F^m(¬⊥) ∈ p.mcs for all m ≥ 1, giving
infinitely many formulas with F-obligation. Their encodings are distinct (since
the formulas are distinct and Encodable is injective) and therefore unbounded.

For any n, we can find m such that encode(F^{m-1}(¬⊥)) ≥ n/2.
-/

/-- Iterated future: apply some_future n times to a formula. -/
noncomputable def iteratedFuture : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.some_future (iteratedFuture n phi)

/-- Iterated futures from an F-formula are all in any MCS containing the F-formula. -/
theorem iterated_future_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) (n : Nat) :
    iteratedFuture n (Formula.some_future phi) ∈ M := by
  induction n with
  | zero => exact h_F
  | succ n ih =>
    show Formula.some_future (iteratedFuture n (Formula.some_future phi)) ∈ M
    cases n with
    | zero => exact SetMaximalConsistent.density_F_to_FF M h_mcs phi h_F
    | succ n' =>
      exact SetMaximalConsistent.density_F_to_FF M h_mcs
        (iteratedFuture n' (Formula.some_future phi)) ih

/-- The encoding of F(iteratedFuture m (F ¬⊥)) grows: for any N, there exists m
such that encode(iteratedFuture m (F ¬⊥)) ≥ N.

Proof sketch: The formulas iteratedFuture 0 (F ¬⊥), iteratedFuture 1 (F ¬⊥), ...
are pairwise distinct (each wraps one more some_future). Since Encodable.encode is
injective, the encodings are pairwise distinct naturals. Among the first N+1 distinct
naturals, the maximum is at least N.

The formal proof uses the fact that N+1 injectively-mapped values cannot all fit
in {0, ..., N-1}. -/
private theorem iteratedFuture_sizeOf_lt (phi : Formula) (n : Nat) :
    sizeOf (iteratedFuture n phi) < sizeOf (iteratedFuture (n + 1) phi) := by
  simp only [iteratedFuture, Formula.some_future, Formula.neg]
  simp only [sizeOf, Formula._sizeOf_1]
  omega

private theorem iteratedFuture_sizeOf_lt_of_lt (phi : Formula) (a b : Nat) (h : a < b) :
    sizeOf (iteratedFuture a phi) < sizeOf (iteratedFuture b phi) := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_lt h
  induction d with
  | zero => exact iteratedFuture_sizeOf_lt phi a
  | succ d ih =>
    calc sizeOf (iteratedFuture a phi)
        < sizeOf (iteratedFuture (a + d + 1) phi) := ih (by omega)
      _ < sizeOf (iteratedFuture (a + (d + 1) + 1) phi) :=
          iteratedFuture_sizeOf_lt phi (a + d + 1)

private theorem iteratedFuture_injective_on (phi : Formula) :
    Function.Injective (fun n => iteratedFuture n phi) := by
  intro a b h_eq
  by_contra h_neq
  rcases Nat.lt_or_gt_of_ne h_neq with h_lt | h_gt
  · have := iteratedFuture_sizeOf_lt_of_lt phi a b h_lt
    simp [h_eq] at this
  · have := iteratedFuture_sizeOf_lt_of_lt phi b a h_gt
    simp [h_eq] at this

/--
For any N, there exists an iterated future formula with encoding ≥ N.

This is used to show that the staged timeline has no maximum:
given any point at stage n, we can find a later obligation stage m > n
that produces a new forward witness.

**Proof**: By pigeonhole. N+1 distinct formulas `F^k(F(neg bot))` for k = 0..N
have N+1 distinct encodings (by formula injectivity + encoder injectivity).
Since encodings are natural numbers and we have N+1 of them, at least one
must have value ≥ N (otherwise they'd all fit in {0, ..., N-1}).
-/
theorem encoding_sufficiency (N : Nat) :
    ∃ m : Nat,
      @Encodable.encode Formula formulaEncodableStaged
        (iteratedFuture m (Formula.some_future (Formula.neg Formula.bot))) ≥ N := by
  by_contra h_all_small
  push_neg at h_all_small
  have h_enc_inj := @Encodable.encode_injective Formula formulaEncodableStaged
  have h_iter_inj := iteratedFuture_injective_on (Formula.some_future (Formula.neg Formula.bot))
  -- Construct injective Fin (N+1) → Fin N
  let f : Fin (N + 1) → Fin N := fun i =>
    ⟨@Encodable.encode Formula formulaEncodableStaged
      (iteratedFuture i.val (Formula.some_future (Formula.neg Formula.bot))),
     h_all_small i.val⟩
  have h_f_inj : Function.Injective f := by
    intro a b hab
    simp only [f, Fin.mk.injEq] at hab
    exact Fin.ext (h_iter_inj (h_enc_inj hab))
  -- Fin (N+1) → Fin N can't be injective when N+1 > N
  have h_le := Fintype.card_le_of_injective f h_f_inj
  simp [Fintype.card_fin] at h_le
  omega

/-!
## NoMaxOrder and NoMinOrder
-/

/-- Every point in the staged timeline has a CanonicalR-successor in the timeline. -/
theorem staged_has_future
    (p : StagedPoint) (n : Nat)
    (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint, q ∈ (buildStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR p.mcs q.mcs := by
  have h_serial := stagedPoint_has_seriality_future p
  obtain ⟨m, hm⟩ := encoding_sufficiency ((n + 1) / 2)
  set phi_m := iteratedFuture m (Formula.some_future (Formula.neg Formula.bot)) with phi_m_def
  set k := @Encodable.encode Formula formulaEncodableStaged phi_m with k_def
  have h_2k_ge_n : n ≤ 2 * k := by
    have : 2 * ((n + 1) / 2) ≥ n := by omega
    omega
  have h_F_phi_m : Formula.some_future phi_m ∈ p.mcs :=
    iterated_future_in_mcs p.mcs p.is_mcs (Formula.neg Formula.bot) h_serial (m + 1)
  have h_decode : decodeFormulaStaged k = some phi_m :=
    @Encodable.encodek Formula formulaEncodableStaged phi_m
  obtain ⟨q, hq_mem, hq_R⟩ := forward_witness_at_stage root_mcs root_mcs_proof
    p phi_m k h_decode h_F_phi_m n h_2k_ge_n hp
  exact ⟨q, ⟨2 * k + 1, hq_mem⟩, hq_R⟩

/-- Past density: P(phi) -> P(P(phi)) in any MCS. Derived from future density via temporal duality. -/
theorem SetMaximalConsistent.density_P_to_PP (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    Formula.some_past (Formula.some_past phi) ∈ M := by
  -- Use derive_F_to_FF for the future density: ⊢ F(phi^t) → F(F(phi^t))
  -- where phi^t = swap_temporal(phi)
  -- Temporal duality converts to: ⊢ P(phi) → P(P(phi))
  -- because swap_temporal(F(psi)) = P(swap_temporal(psi))
  have h_density_future : [] ⊢ (Formula.some_future phi.swap_temporal).imp
      (Formula.some_future (Formula.some_future phi.swap_temporal)) :=
    derive_F_to_FF phi.swap_temporal
  have h_density_past := DerivationTree.temporal_duality _ h_density_future
  -- swap_temporal converts F to P and preserves the structure
  -- After swap_temporal, we get P(phi) → P(P(phi))
  simp only [Formula.imp, Formula.some_future, Formula.neg, Formula.all_future,
    Formula.swap_temporal, Formula.swap_temporal_involution] at h_density_past
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_density_past) h_P

/-- Iterated past: apply some_past n times to a formula. -/
noncomputable def iteratedPast : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.some_past (iteratedPast n phi)

/-- Iterated pasts from a P-formula are all in any MCS containing the P-formula. -/
theorem iterated_past_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) (n : Nat) :
    iteratedPast n (Formula.some_past phi) ∈ M := by
  induction n with
  | zero => exact h_P
  | succ n ih =>
    show Formula.some_past (iteratedPast n (Formula.some_past phi)) ∈ M
    cases n with
    | zero => exact SetMaximalConsistent.density_P_to_PP M h_mcs phi h_P
    | succ n' =>
      exact SetMaximalConsistent.density_P_to_PP M h_mcs
        (iteratedPast n' (Formula.some_past phi)) ih

private theorem iteratedPast_sizeOf_lt (phi : Formula) (n : Nat) :
    sizeOf (iteratedPast n phi) < sizeOf (iteratedPast (n + 1) phi) := by
  simp only [iteratedPast, Formula.some_past, Formula.neg]
  simp only [sizeOf, Formula._sizeOf_1]
  omega

private theorem iteratedPast_sizeOf_lt_of_lt (phi : Formula) (a b : Nat) (h : a < b) :
    sizeOf (iteratedPast a phi) < sizeOf (iteratedPast b phi) := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_lt h
  induction d with
  | zero => exact iteratedPast_sizeOf_lt phi a
  | succ d ih =>
    calc sizeOf (iteratedPast a phi)
        < sizeOf (iteratedPast (a + d + 1) phi) := ih (by omega)
      _ < sizeOf (iteratedPast (a + (d + 1) + 1) phi) :=
          iteratedPast_sizeOf_lt phi (a + d + 1)

private theorem iteratedPast_injective_on (phi : Formula) :
    Function.Injective (fun n => iteratedPast n phi) := by
  intro a b h_eq
  by_contra h_neq
  rcases Nat.lt_or_gt_of_ne h_neq with h_lt | h_gt
  · have := iteratedPast_sizeOf_lt_of_lt phi a b h_lt
    simp [h_eq] at this
  · have := iteratedPast_sizeOf_lt_of_lt phi b a h_gt
    simp [h_eq] at this

theorem encoding_sufficiency_past (N : Nat) :
    ∃ m : Nat,
      @Encodable.encode Formula formulaEncodableStaged
        (iteratedPast m (Formula.some_past (Formula.neg Formula.bot))) ≥ N := by
  by_contra h_all_small
  push_neg at h_all_small
  have h_enc_inj := @Encodable.encode_injective Formula formulaEncodableStaged
  have h_iter_inj := iteratedPast_injective_on (Formula.some_past (Formula.neg Formula.bot))
  let f : Fin (N + 1) → Fin N := fun i =>
    ⟨@Encodable.encode Formula formulaEncodableStaged
      (iteratedPast i.val (Formula.some_past (Formula.neg Formula.bot))),
     h_all_small i.val⟩
  have h_f_inj : Function.Injective f := by
    intro a b hab
    simp only [f, Fin.mk.injEq] at hab
    exact Fin.ext (h_iter_inj (h_enc_inj hab))
  have h_le := Fintype.card_le_of_injective f h_f_inj
  simp [Fintype.card_fin] at h_le
  omega

/-- Every point in the staged timeline has a CanonicalR-predecessor in the timeline. -/
theorem staged_has_past
    (p : StagedPoint) (n : Nat)
    (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint, q ∈ (buildStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR q.mcs p.mcs := by
  have h_serial := stagedPoint_has_seriality_past p
  -- Mirror of staged_has_future using past-versions of each lemma.
  obtain ⟨m, hm⟩ := encoding_sufficiency_past ((n + 1) / 2)
  set phi_m := iteratedPast m (Formula.some_past (Formula.neg Formula.bot)) with phi_m_def
  set k := @Encodable.encode Formula formulaEncodableStaged phi_m with k_def
  have h_2k_ge_n : n ≤ 2 * k := by
    have : 2 * ((n + 1) / 2) ≥ n := by omega
    omega
  have h_P_phi_m : Formula.some_past phi_m ∈ p.mcs :=
    iterated_past_in_mcs p.mcs p.is_mcs (Formula.neg Formula.bot) h_serial (m + 1)
  have h_decode : decodeFormulaStaged k = some phi_m :=
    @Encodable.encodek Formula formulaEncodableStaged phi_m
  obtain ⟨q, hq_mem, hq_R⟩ := backward_witness_at_stage root_mcs root_mcs_proof
    p phi_m k h_decode h_P_phi_m n h_2k_ge_n hp
  exact ⟨q, ⟨2 * k + 1, hq_mem⟩, hq_R⟩

/-!
## Nonemptiness
-/

/-- The staged timeline union is nonempty (it contains the root). -/
theorem staged_timeline_nonempty :
    Set.Nonempty (buildStagedTimeline root_mcs root_mcs_proof).union :=
  (buildStagedTimeline root_mcs root_mcs_proof).union_nonempty

/-!
## NoMaxOrder and NoMinOrder (union-level)

Every point in the union has a strict successor and predecessor.
-/

/-- Every point in the timeline union has a CanonicalR-successor in the union. -/
theorem staged_timeline_has_future
    (p : StagedPoint) (hp : p ∈ (buildStagedTimeline root_mcs root_mcs_proof).union) :
    ∃ q : StagedPoint, q ∈ (buildStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR p.mcs q.mcs := by
  obtain ⟨n, hn⟩ := hp
  exact staged_has_future root_mcs root_mcs_proof p n hn

/-- Every point in the timeline union has a CanonicalR-predecessor in the union. -/
theorem staged_timeline_has_past
    (p : StagedPoint) (hp : p ∈ (buildStagedTimeline root_mcs root_mcs_proof).union) :
    ∃ q : StagedPoint, q ∈ (buildStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR q.mcs p.mcs := by
  obtain ⟨n, hn⟩ := hp
  exact staged_has_past root_mcs root_mcs_proof p n hn

/-!
## Countability

The staged timeline is countable because it is the union of omega-indexed
finite sets (each stagedBuild n is a Finset).
-/

/-- The staged timeline union is countable: it is the countable union
    of finite sets (one per stage). -/
theorem staged_timeline_countable :
    Set.Countable (buildStagedTimeline root_mcs root_mcs_proof).union := by
  -- The union is { p | ∃ n, p ∈ at_stage n } = ⋃ n, ↑(at_stage n)
  apply Set.Countable.mono (s₂ := ⋃ n : Nat, ↑(stagedBuild root_mcs root_mcs_proof n))
  · intro p hp
    obtain ⟨n, hn⟩ := hp
    exact Set.mem_iUnion.mpr ⟨n, hn⟩
  · exact Set.countable_iUnion (fun n => Set.Finite.countable (Finset.finite_toSet _))

/-!
## Discrete Staged Timeline: Has Future/Past (DN-free)

For the discrete staged construction, we need DN-free proofs of has_future
and has_past. Unlike the dense case, we don't need encoding sufficiency via
iterated F/P formulas because the discrete build processes formula k at
stage k+1 (no density stages in between).

The key observation: for any point p at stage n, seriality gives us
F(neg bot) in p.mcs. The encoding of (neg bot) is some fixed k₀. At
stage k₀+1, the discrete build will add a forward witness for p.

This proof does NOT use the density axiom DN.
-/

/-- Forward witness for discrete build at stage k+1 for formula with encoding k.
Unlike the dense case, we don't need n ≤ 2*k because there's no stage doubling. -/
theorem discrete_forward_witness_at_stage
    (p : StagedPoint) (phi : Formula) (k : Nat)
    (h_decode : decodeFormulaStaged k = some phi)
    (h_F : Formula.some_future phi ∈ p.mcs)
    (n : Nat) (h_n_le : n ≤ k)
    (hp : p ∈ discreteStagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint,
      q ∈ discreteStagedBuild root_mcs root_mcs_proof (k + 1) ∧
      CanonicalR p.mcs q.mcs := by
  have hp_k : p ∈ discreteStagedBuild root_mcs root_mcs_proof k :=
    discreteStagedBuild_monotone_le root_mcs root_mcs_proof n k h_n_le hp
  let w := processForwardObligation p phi h_F (k + 1)
  refine ⟨w, ?_, processForwardObligation_canonicalR p phi h_F (k + 1)⟩
  show w ∈ discreteStagedBuild root_mcs root_mcs_proof (k + 1)
  -- discreteStagedBuild (k+1) = evenStage (discreteStagedBuild k) k (k+1)
  have h_eq : discreteStagedBuild root_mcs root_mcs_proof (k + 1) =
    evenStage (discreteStagedBuild root_mcs root_mcs_proof k) k (k + 1) := rfl
  rw [h_eq]
  unfold evenStage
  rw [h_decode]
  unfold processFormula
  rw [Finset.mem_union]
  right
  rw [Finset.mem_biUnion]
  refine ⟨p, hp_k, ?_⟩
  unfold witnessesForPoint
  rw [Finset.mem_union]
  left
  rw [dif_pos h_F, Finset.mem_singleton]

/-- Backward witness for discrete build at stage k+1 for formula with encoding k. -/
theorem discrete_backward_witness_at_stage
    (p : StagedPoint) (phi : Formula) (k : Nat)
    (h_decode : decodeFormulaStaged k = some phi)
    (h_P : Formula.some_past phi ∈ p.mcs)
    (n : Nat) (h_n_le : n ≤ k)
    (hp : p ∈ discreteStagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint,
      q ∈ discreteStagedBuild root_mcs root_mcs_proof (k + 1) ∧
      CanonicalR q.mcs p.mcs := by
  have hp_k : p ∈ discreteStagedBuild root_mcs root_mcs_proof k :=
    discreteStagedBuild_monotone_le root_mcs root_mcs_proof n k h_n_le hp
  let w := processBackwardObligation p phi h_P (k + 1)
  refine ⟨w, ?_, processBackwardObligation_canonicalR p phi h_P (k + 1)⟩
  show w ∈ discreteStagedBuild root_mcs root_mcs_proof (k + 1)
  have h_eq : discreteStagedBuild root_mcs root_mcs_proof (k + 1) =
    evenStage (discreteStagedBuild root_mcs root_mcs_proof k) k (k + 1) := rfl
  rw [h_eq]
  unfold evenStage
  rw [h_decode]
  unfold processFormula
  rw [Finset.mem_union]
  right
  rw [Finset.mem_biUnion]
  refine ⟨p, hp_k, ?_⟩
  unfold witnessesForPoint
  rw [Finset.mem_union]
  right
  rw [dif_pos h_P, Finset.mem_singleton]

/-- Every point in the discrete staged build has a CanonicalR-successor.

**DN-Free Proof**: Uses MCS richness (mcs_has_large_F_formula) instead of density.

The discrete build processes formula k at stage k+1. For any point p at stage n,
we find a formula phi with encoding >= n such that F(phi) in p.mcs (by MCS richness),
and its witness appears at stage encoding(phi)+1 >= n+1.

Key insight: For any atom i, F(neg bot ∨ atom(i)) ∈ p.mcs (by F_or_atom_in).
Since there are infinitely many atoms and encodings are injective, we can always
find a phi with arbitrarily large encoding such that F(phi) ∈ p.mcs.
-/
theorem discrete_staged_has_future
    (p : StagedPoint) (n : Nat)
    (hp : p ∈ discreteStagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint, q ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR p.mcs q.mcs := by
  -- By MCS richness: there exists phi with encoding >= n and F(phi) in p.mcs
  obtain ⟨phi, h_enc_ge, h_F_phi⟩ := SetMaximalConsistent.mcs_has_large_F_formula p.mcs p.is_mcs n
  set k := @Encodable.encode Formula formulaEncodableStaged phi with k_def
  have h_k_ge_n : k ≥ n := h_enc_ge
  have h_decode : decodeFormulaStaged k = some phi :=
    @Encodable.encodek Formula formulaEncodableStaged phi
  have h_n_le_k : n ≤ k := h_k_ge_n
  -- Use discrete_forward_witness_at_stage to get the witness
  obtain ⟨q, hq_mem, hq_R⟩ := discrete_forward_witness_at_stage root_mcs root_mcs_proof
    p phi k h_decode h_F_phi n h_n_le_k hp
  exact ⟨q, ⟨k + 1, hq_mem⟩, hq_R⟩

/-- Every point in the discrete staged build has a CanonicalR-predecessor.

**DN-Free Proof**: Uses MCS richness (mcs_has_large_P_formula) instead of density.

The discrete build processes formula k at stage k+1. For any point p at stage n,
we find a formula phi with encoding >= n such that P(phi) in p.mcs (by MCS richness),
and its witness appears at stage encoding(phi)+1 >= n+1.

Key insight: For any atom i, P(neg bot ∨ atom(i)) ∈ p.mcs (by P_or_atom_in).
Since there are infinitely many atoms and encodings are injective, we can always
find a phi with arbitrarily large encoding such that P(phi) ∈ p.mcs.
-/
theorem discrete_staged_has_past
    (p : StagedPoint) (n : Nat)
    (hp : p ∈ discreteStagedBuild root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint, q ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR q.mcs p.mcs := by
  -- By MCS richness: there exists phi with encoding >= n and P(phi) in p.mcs
  obtain ⟨phi, h_enc_ge, h_P_phi⟩ := SetMaximalConsistent.mcs_has_large_P_formula p.mcs p.is_mcs n
  set k := @Encodable.encode Formula formulaEncodableStaged phi with k_def
  have h_k_ge_n : k ≥ n := h_enc_ge
  have h_decode : decodeFormulaStaged k = some phi :=
    @Encodable.encodek Formula formulaEncodableStaged phi
  have h_n_le_k : n ≤ k := h_k_ge_n
  -- Use discrete_backward_witness_at_stage to get the witness
  obtain ⟨q, hq_mem, hq_R⟩ := discrete_backward_witness_at_stage root_mcs root_mcs_proof
    p phi k h_decode h_P_phi n h_n_le_k hp
  exact ⟨q, ⟨k + 1, hq_mem⟩, hq_R⟩

/-!
## Discrete Timeline Union Properties
-/

/-- The discrete timeline union is nonempty. -/
theorem discrete_staged_timeline_nonempty :
    Set.Nonempty (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union :=
  (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union_nonempty

/-- Every point in the discrete timeline union has a CanonicalR-successor. -/
theorem discrete_staged_timeline_has_future
    (p : StagedPoint) (hp : p ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union) :
    ∃ q : StagedPoint, q ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR p.mcs q.mcs := by
  obtain ⟨n, hn⟩ := hp
  exact discrete_staged_has_future root_mcs root_mcs_proof p n hn

/-- Every point in the discrete timeline union has a CanonicalR-predecessor. -/
theorem discrete_staged_timeline_has_past
    (p : StagedPoint) (hp : p ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union) :
    ∃ q : StagedPoint, q ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union ∧
      CanonicalR q.mcs p.mcs := by
  obtain ⟨n, hn⟩ := hp
  exact discrete_staged_has_past root_mcs root_mcs_proof p n hn

/-- The discrete timeline union is countable. -/
theorem discrete_staged_timeline_countable :
    Set.Countable (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union := by
  apply Set.Countable.mono (s₂ := ⋃ n : Nat, ↑(discreteStagedBuild root_mcs root_mcs_proof n))
  · intro p hp
    obtain ⟨n, hn⟩ := hp
    exact Set.mem_iUnion.mpr ⟨n, hn⟩
  · exact Set.countable_iUnion (fun n => Set.Finite.countable (Finset.finite_toSet _))

end Bimodal.Metalogic.StagedConstruction
