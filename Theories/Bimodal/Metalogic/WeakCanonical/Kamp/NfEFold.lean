import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Kamp.NfDepth0Generalized

/-!
# E[Σ]-Fold Encoding for NormalForm Depth-Recursion (task 310, Phase 1)

A *parallel, additive* fold normal-form encoding transcribing Rabinovich 2014's
E[Σ]-atom mechanism. Nothing in the existing development imports this file, so it
is **off the live path**; `nf_eval_nf` (`NormalForm.lean`) is retained unchanged
and this file only runs alongside it.

## Why a fold

`nf_eval_nf` (`NormalForm.lean:198-207`) grows environment arity `n → n+1` at every
depth descent, coupling a fresh existential witness jointly to *all* fixed endpoints
(the arity-4 residual that NO-GOed task 309's k=1 gate). Rabinovich never grows arity
with depth: a quantified witness `x_j` touches the rest of the formula through exactly
three channels — its **order position** among the other points (Def 3.1 ordering
conjuncts, PDF p.4), its **monadic point type** `α_j(x_j)` (one-variable,
quantifier-free, PDF p.4), and interval types `β_j` on the segments it bounds — and all
already-processed quantifier depth is folded into the *signature* as a unary E[Σ]-atom
(Def 4.1, PDF p.5; Prop 4.3 innermost-first iteration, PDF p.6). The ≤2-free-variable
cap (Lemma 3.2(2), PDF p.4) then holds *by construction*.

This file lands the fold TYPE and EVALUATOR (Phase 1). The quant-assignment domain
`EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1` makes Lemma 3.2(2)'s ≤2-cap a
**type-level invariant**: there is no slot for a joint `(n+1)`-ary sub-evaluation.

## References

- Rabinovich 2014, *A Proof of Kamp's Theorem*: Def 3.1 (p.4, ∃∀-formula / point type),
  Lemma 3.2(2) (p.4, ≤2 free variables), Def 4.1 (p.5, E[Σ]-atom fold),
  Prop 4.3 (p.6, innermost-first iteration).
- `NormalForm.lean` (`nf_eval_nf`, `AtomKind`, `atom_eval`) — the parallel encoding.
- `NfDepth0Generalized.lean` (`skipFin`, `mergeNF`) — reused by the Phase-2 split kit.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Metalogic.WeakCanonical

/-! ## Zone specification (Def 3.1 ordering conjuncts, PDF p.4) -/

/-- Order relationship of a fresh witness to each of the `n` environment points:
    for each `i`, `(zs i).1` encodes "x < env i" and `(zs i).2` encodes "env i < x".
    `(false, false)` encodes `x = env i` (LinearOrder trichotomy on `M.carrier`);
    `(true, true)` is unsatisfiable (harmless — its clauses are vacuously false).

    This is the Lean transcription of Rabinovich Def 3.1's ordering-and-equality
    conjuncts (PDF p.4): the ONLY channel through which a quantified witness meets
    the fixed environment points. -/
def ZoneSpec (n : Nat) : Type := Fin n → Bool × Bool

/-- Semantic reading of a `ZoneSpec`: the witness `x` sits in the order zone that
    `zs` prescribes relative to `env`. Mirrors `atom_eval` on the fresh-variable
    order atoms exactly (`x < env i` and `env i < x`), so the Phase-3 factorization
    is a direct case transport, not a semantic argument (Def 3.1, PDF p.4). -/
def zoneHolds {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    {n : Nat} (env : Fin n → M.carrier) (zs : ZoneSpec n) (x : M.carrier) : Prop :=
  ∀ i : Fin n, (x < env i ↔ (zs i).1 = true) ∧ (env i < x ↔ (zs i).2 = true)

/-! ## The fold normal-form type (Def 4.1 + Lemma 3.2(2) as a type) -/

/-- Quant-assignment domain of the E[Σ]-fold: order position (`ZoneSpec n`) ×
    monadic depth-`k` point type (the E[Σ]-atom `NormalForm sig k 1`, Def 4.1
    PDF p.5). There is NO slot for a joint `(n+1)`-ary sub-evaluation — Lemma
    3.2(2)'s ≤2-free-variable cap (PDF p.4) is enforced by this type, not by a
    hand-written guard. -/
abbrev EAtomDom (sig : MonadicSignature) (k n : Nat) : Type :=
  ZoneSpec n × NormalForm sig k 1

/-- E[Σ]-fold normal form: identical to `NormalForm` at depth 0 and in every atom
    layer; the quant layer ranges over `EAtomDom sig k n` (fixed arity `n`) instead
    of `NormalForm sig k (n+1)` (arity `n+1`). This is the type-level encoding of
    Lemma 3.2(2)'s ≤2 cap (PDF p.4): depth lives in the monadic atom `NormalForm
    sig k 1`, never in the arity of the environment. -/
def NormalFormEFold (sig : MonadicSignature) : Nat → Nat → Type
  | 0, n => AtomKind sig n → Bool
  | k + 1, n => (AtomKind sig n → Bool) × (EAtomDom sig k n → Bool)

/-! ## The fold evaluation (the load-bearing definition, Def 4.1 PDF p.5) -/

/-- Fixed-arity E[Σ]-fold evaluation (Rabinovich Def 4.1, PDF p.5; Def 3.1 shape,
    PDF p.4).

    - Depth 0: identical to `nf_eval_nf` at depth 0 (every atom evaluates as the
      assignment says) — this is what makes `nf_eval_efold_zero_iff` an `Iff.rfl`.
    - Depth `k+1`: the atom layer as usual, PLUS a quant layer that folds each
      processed depth into a monadic E[Σ]-atom `e.2 : NormalForm sig k 1` evaluated
      at the witness ALONE (`nf_eval_nf M k 1 (fun _ => x)`), coupled to the SAME
      arity-`n` env only through `zoneHolds` (pairwise order = ≤2 free variables per
      constraint, Lemma 3.2(2) PDF p.4).

    Arity `n` is CONSTANT across the depth recursion: `env : Fin n → M.carrier`
    appears unchanged in the quant clause and the witness `x` never enters an
    environment. The only depth-indexed object is the monadic atom `e.2`. The atom's
    semantics is `nf_eval_nf M k 1`, NOT a recursive `nf_eval_efold` call (Def 4.1
    fidelity: the E[Σ]-atom is a TL-formula whose truth/NF-semantics tie-in is
    already sorry-free at arity 1; this also keeps the quant clause structurally
    non-recursive). Interval types `β` have no explicit slot — `∀`-content along a
    segment is carried by `quant_assignment e = false` entries, as in `nf_eval_nf`. -/
noncomputable def nf_eval_efold {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    (k n : Nat) → (env : Fin n → M.carrier) → NormalFormEFold sig k n → Prop
  | 0, _, env, assignment =>
    ∀ (a : AtomKind sig _), atom_eval M env a ↔ (assignment a = true)
  | k + 1, _, env, ⟨atom_assignment, quant_assignment⟩ =>
    (∀ (a : AtomKind sig _), atom_eval M env a ↔ (atom_assignment a = true)) ∧
    (∀ (e : EAtomDom sig k _),
      (∃ (x : M.carrier), zoneHolds M env e.1 x ∧
        nf_eval_nf M k 1 (fun _ => x) e.2) ↔ (quant_assignment e = true))

/-- Depth-0 coincidence of the fold and the existing encoding (task deliverable).
    `NormalFormEFold sig 0 n` and `NormalForm sig 0 n` are both definitionally
    `AtomKind sig n → Bool`, and the two depth-0 evaluation clauses are the same
    `∀ a, atom_eval M env a ↔ (assignment a = true)`; hence `Iff.rfl`. Rabinovich
    Def 3.1's α/β base is quantifier-free (PDF p.4), so the fold adds nothing at
    depth 0. -/
theorem nf_eval_efold_zero_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (n : Nat) (env : Fin n → M.carrier)
    (a : NormalFormEFold sig 0 n) :
    nf_eval_efold M 0 n env a ↔ nf_eval_nf M 0 n env a := Iff.rfl

/-! ## Reduction lemma for the Phase-2 split kit -/

/-- Dropping position `0` via `skipFin` is just `Fin.succ`. Proved here as a `simp`
    lemma so that `nf0_dropFresh := mergeNF · ⟨0, _⟩` (Phase 2) computes: the
    env-side restriction sends `Fin n` to indices `1..n`. -/
@[simp] theorem skipFin_zero_succ {n : Nat} (i : Fin n) :
    skipFin ⟨0, Nat.succ_pos n⟩ i = i.succ := by
  have h : ¬ (i.val < (⟨0, Nat.succ_pos n⟩ : Fin (n + 1)).val) := by
    simp
  simp only [skipFin, dif_neg h]
  rfl

end Bimodal.Metalogic.WeakCanonical.Kamp
