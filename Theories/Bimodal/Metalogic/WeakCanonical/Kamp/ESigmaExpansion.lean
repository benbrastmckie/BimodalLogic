/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Syntax.Formula

/-!
# E[Σ] Unary-Alphabet Signature Expansion

First-class realization of Rabinovich's E[Σ] expansion (*Proof of Kamp's Theorem*, 2014,
Definition 4.1, PDF p.5) as an operation on `MonadicSignature`, together with the canonical
expansion of an `OrderedMonadicStructure` and the atom-collapse facts of the p.6
collapse-to-atom note.

## What this module provides

- `sigE sig F`: the signature `sig` extended with one fresh **unary** predicate symbol per
  formula. The extension is `sig.preds ⊕ Formula` — the full infinite E[Σ] alphabet of
  Def 4.1 (p.5), indexed by every `Formula`, with no membership proof and no `Fintype`.
  Decidable equality survives (`Formula` derives `DecidableEq`); all load-bearing finiteness
  in the exists-forall chain is `M`-relative (the mentioned-atom `Finset`), never
  alphabet-wide. The `F : Finset Formula` parameter is retained purely as a type-level stage
  index so downstream types (`UnaryType sig F`, `IntervalType sig F`, …) keep their arities.
- `canonExpand sig F M sat`: the canonical expansion of `M`. The carrier and order are inherited
  verbatim, and each fresh atom `A` is interpreted as the semantic set `{a | sat A a}` of the
  fixed, environment-independent satisfaction relation `sat` (Def 4.1, p.5).
- Atom-collapse facts (p.6): the fresh atom for `A` reads back exactly as `sat A` at the anchor
  (`atom_eval_new`), and the inherited old atoms agree verbatim with `M` (`atom_eval_old`). Read
  together these say a temporal-logic formula that has been folded into an E[Σ] atom collapses to
  an atomic proposition in the canonical expansion.
- `esigma_descent`: the arity-**preserving** depth descent. The depth-`(k+1)` obligation over
  `sig` at arity `n` is equivalent to an arity-`n` obligation over the expansion in which the
  arity-`(n+1)` joint environment `Fin.cons x env` (the term whose iteration grows to arity 4 on
  the present completeness spine) is replaced by a fresh E[Σ] atom evaluated at the anchor. The
  existential-capture premise `hcapture` is the scheduled Prop 3.5 / Lemma 3.2(2) deliverable — a
  hypothesis, never a `sorry`; the descent proves the arity claim outright. The raw-vs-target
  arity contrast is recorded by the two `rfl` facts `raw_descent_grows_arity` and
  `esigma_target_is_arity_n`.

## Design notes

The environment-independence of `sat` is what makes the descent arity-preserving: the fresh atom
never smuggles the bound variable into its interpretation, so the joint `Fin.cons x env`
environment is eliminated rather than descended into. This module is deliberately additive — it
introduces no dependence on, and makes no change to, the live completeness spine, and it does
**not** route through the `NfEFold` fold evaluator (`nf_eval_efold`), which stays arity `n+1`.
Only the E[Σ] atom *vocabulary* is shared.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 4.1 (p.5), collapse-to-atom note
  (p.6). Cited by PDF page; the companion markdown transcription is corrupt.
- `NormalForm.lean`: `AtomKind`, `atom_eval`, `NormalForm`, `nf_eval_nf`.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax (Formula)

/-! ## 1. The infinite E[Σ] signature expansion (Def 4.1, p.5) -/

/--
The E[Σ] signature expansion: `sig` extended with one fresh unary predicate name per formula —
the full infinite E[Σ] alphabet of Def 4.1 (p.5). The fresh summand is the whole `Formula`
type; no membership proof gates atom formation, so every readback is an atom of the expansion
by construction. `F : Finset Formula` is retained purely as a type-level stage index for the
downstream per-stage types; it no longer bounds the alphabet. Under the infinite-alphabet
discipline `MonadicSignature` carries no `Fintype`/`DecidableEq` fields; decidable equality of
the expansion's predicate names is the ordinary instance below (from `[DecidableEq sig.preds]`
and `Formula`'s derived `DecidableEq`), and there is deliberately NO `Fintype` instance — all
load-bearing finiteness is `M`-relative, never alphabet-wide.
-/
def sigE (sig : MonadicSignature) (_F : Finset Formula) : MonadicSignature where
  preds := sig.preds ⊕ Formula

/-- The fresh E[Σ] predicate symbol naming the formula `A`. No membership proof: the infinite
E[Σ] alphabet names every formula (Def 4.1, p.5). -/
def esigmaPred {sig : MonadicSignature} {F : Finset Formula} (A : Formula) :
    (sigE sig F).preds :=
  Sum.inr A

/-- The inherited (old-signature) predicate symbol inside the expansion. -/
def oldPred {sig : MonadicSignature} {F : Finset Formula} (q : sig.preds) :
    (sigE sig F).preds :=
  Sum.inl q

/-- The expansion carries `DecidableEq` on its predicate symbols (given base decidability):
`Formula` derives `DecidableEq`, so the sum does too. This is the only instance the infinite
E[Σ] alphabet provides — there is deliberately no `Fintype` (`Formula` is infinite); only
`Fintype`-finiteness is lost by the re-index, and nothing in the exists-forall chain needs it
(all enumeration is `M`-relative). -/
instance sigE_decEqPreds (sig : MonadicSignature) [DecidableEq sig.preds]
    (F : Finset Formula) :
    DecidableEq (sigE sig F).preds := inferInstanceAs (DecidableEq (sig.preds ⊕ Formula))

/-! ## 2. The canonical expansion of an ordered monadic structure (Def 4.1, p.5) -/

/--
The canonical expansion of `M` along the infinite E[Σ] alphabet: carrier and order are
inherited verbatim, each fresh atom `A` is interpreted as `{a | sat A a}`, and each old
predicate keeps `M`'s interpretation. `sat` is a fixed, environment-independent satisfaction
relation (Def 4.1, p.5).
-/
def canonExpand (sig : MonadicSignature) (F : Finset Formula)
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop) :
    OrderedMonadicStructure (sigE sig F) where
  carrier := M.carrier
  interp p a := match p with
    | .inl q => M.interp q a
    | .inr A => sat A a
  carrier_order := M.carrier_order

/-- The canonical expansion preserves the carrier: an arity-`n` environment over `M` transfers
verbatim, with no coercion. This is why the descent never changes the carrier or the arity. -/
theorem canonExpand_carrier (sig : MonadicSignature) (F : Finset Formula)
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop) :
    (canonExpand sig F M sat).carrier = M.carrier := rfl

/-! ## 3. Atom-collapse facts (p.6 collapse-to-atom note) -/

/--
**Atom collapse.** The fresh E[Σ] atom for a formula `A`, evaluated at a point `env i`, reads
back exactly as `sat A (env i)`. This is the collapse of an already-processed temporal-logic
formula to an atomic proposition in the canonical expansion — with the infinite alphabet, no
membership premise is needed.
-/
theorem atom_eval_new {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    {n : Nat} (env : Fin n → M.carrier) (A : Formula) (i : Fin n) :
    atom_eval (canonExpand sig F M sat) env (.pred (esigmaPred A) i) ↔ sat A (env i) :=
  Iff.rfl

/--
The canonical expansion is conservative on the old signature: an inherited predicate atom in the
expansion evaluates exactly as it does in `M`.
-/
theorem atom_eval_old {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    {n : Nat} (env : Fin n → M.carrier) (q : sig.preds) (i : Fin n) :
    atom_eval (canonExpand sig F M sat) env (.pred (oldPred q) i) ↔ M.interp q (env i) :=
  Iff.rfl

/-- Order atoms are inherited verbatim by the canonical expansion (the carrier order is `M`'s). -/
theorem atom_eval_order {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    {n : Nat} (env : Fin n → M.carrier) (i j : Fin n) (h : i ≠ j) :
    atom_eval (canonExpand sig F M sat) env (.order i j h) ↔ (env i < env j) :=
  Iff.rfl

/-! ## 4. Arity facts: the raw obstruction vs. the E[Σ] target (both `rfl`) -/

/-- The raw `NormalForm` descent grows arity `n → n+1` — the whole obstruction restated. -/
theorem raw_descent_grows_arity (sig : MonadicSignature) (k n : Nat) :
    NormalForm sig (k + 1) n
      = ((AtomKind sig n → Bool) × (NormalForm sig k (n + 1) → Bool)) := rfl

/-- The E[Σ] arity-capping target: a depth-0 obligation over the expanded signature is at arity
`n` — no `n+1` quantifier layer. Processed depth has become atoms. -/
theorem esigma_target_is_arity_n (sig : MonadicSignature) (F : Finset Formula) (n : Nat) :
    NormalForm (sigE sig F) 0 n = (AtomKind (sigE sig F) n → Bool) := rfl

/-! ## 5. The arity-preserving E[Σ] descent -/

/--
**Arity-preserving E[Σ] descent.** The depth-`(k+1)` obligation over `sig` at arity `n` is
equivalent to an arity-`n` obligation over the expansion in which the folded existential is read
off a fresh E[Σ] atom at the `anchor`, rather than by descending into the arity-`(n+1)` joint
environment `Fin.cons x env` (the term whose iteration reaches arity 4 on the present spine).

`hcapture` — that each folded existential is captured by a fresh E[Σ] atom evaluated at the
anchor — is the scheduled Prop 3.5 (p.5) / Lemma 3.2(2) (p.4) deliverable, supplied here as a
hypothesis (never a `sorry`). The arity claim itself is proved outright: arity `n` on both sides,
the `Fin.cons` environment eliminated on the right.
-/
theorem esigma_descent
    (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (sat : Formula → M.carrier → Prop)
    (k n : Nat) (env : Fin n → M.carrier)
    (Aσ : NormalForm sig k (n + 1) → Formula)
    (anchor : Fin n)
    (hcapture : ∀ σ : NormalForm sig k (n + 1),
        sat (Aσ σ) (env anchor) ↔ (∃ x, nf_eval_nf M k (n + 1) (Fin.cons x env) σ))
    (nf : NormalForm sig (k + 1) n) :
    nf_eval_nf M (k + 1) n env nf
      ↔
    ( (∀ a : AtomKind sig n, atom_eval M env a ↔ (nf.1 a = true)) ∧
      (∀ σ : NormalForm sig k (n + 1), sat (Aσ σ) (env anchor) ↔ (nf.2 σ = true)) ) := by
  constructor
  · rintro ⟨hatom, hquant⟩
    refine ⟨hatom, fun σ => ?_⟩
    rw [hcapture σ]; exact hquant σ
  · rintro ⟨hatom, hquant⟩
    refine ⟨hatom, fun σ => ?_⟩
    rw [← hcapture σ]; exact hquant σ

end Bimodal.Metalogic.WeakCanonical
