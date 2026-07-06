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

/-! ## Phase 2: Depth-0 split kit + round-trip lemmas (Def 3.1 three channels, PDF p.4)

For `sub : NormalForm sig 0 (n+1)` with the fresh variable at index `0` (matching
`Fin.cons x env`), the atoms of `AtomKind sig (n+1)` partition into exactly three
Rabinovich channels (Def 3.1, PDF p.4): the **ordering** channel of the fresh
variable against each env point (`nf0_zoneSpec`), the **monadic point type** of the
fresh variable (`nf0_projFresh`), and the **env restriction** dropping the fresh
variable (`nf0_dropFresh`). `nf0_assemble` reassembles the three channels, and the
four round-trip lemmas prove this is a *bijection of characterizations* — the G2
losslessness defence that distinguishes the fold from the refuted lossy depth-k
projections (deviation D7: these projections are depth-0 ONLY). -/

/-- Ordering channel (Def 3.1, PDF p.4): the order atoms coupling the fresh variable
    (index `0`) to each env point `i` (index `i.succ`). `(zs i).1` records `fresh <
    env i` (atom `.order 0 i.succ`), `(zs i).2` records `env i < fresh` (atom
    `.order i.succ 0`). This is the ONLY channel through which the quantified witness
    meets the fixed environment points. -/
def nf0_zoneSpec {sig : MonadicSignature} {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) : ZoneSpec n :=
  fun i => (sub (.order 0 i.succ (Fin.succ_ne_zero i).symm),
            sub (.order i.succ 0 (Fin.succ_ne_zero i)))

/-- Monadic point-type channel (Def 3.1, PDF p.4): the predicate atoms of the fresh
    variable, read off as a `NormalForm sig 0 1`. `AtomKind sig 1` has no order atoms
    (`i ≠ j` is uninhabited at arity 1, cf. `nf_y_proj` VecEADecomp:33), so the order
    case is discharged by `absurd`. -/
def nf0_projFresh {sig : MonadicSignature} {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => sub (.pred p 0)
  | .order i j h => absurd (Subsingleton.elim i j) h

/-- Env-restriction channel (Def 3.1, PDF p.4): drop the fresh variable at position
    `0`. REUSES `mergeNF` at position `0` (NfDepth0Generalized:169); `skipFin ⟨0⟩`
    maps `Fin n` to indices `1..n` (see `skipFin_zero_succ`). -/
noncomputable def nf0_dropFresh {sig : MonadicSignature} {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) : NormalForm sig 0 n :=
  mergeNF sub ⟨0, Nat.succ_pos n⟩

/-- Reassemble a full `(n+1)`-ary depth-0 NF from the three Def-3.1 channels (PDF
    p.4). Predicate atoms: index `0` reads the monadic type `χ`, index `i.succ` reads
    the env restriction `r`. Order atoms: `(0, j.succ) ↦ (zs j).1`, `(i.succ, 0) ↦
    (zs i).2`, `(i.succ, j.succ) ↦ r`'s order atom; `(0,0)` is impossible by the
    atom's own `i ≠ j`. Pure `Fin.cases` bookkeeping, no semantics. -/
def nf0_assemble {sig : MonadicSignature} {n : Nat}
    (zs : ZoneSpec n) (χ : NormalForm sig 0 1) (r : NormalForm sig 0 n) :
    NormalForm sig 0 (n + 1) :=
  fun a => match a with
  | .pred p i => Fin.cases (χ (.pred p 0)) (fun i' => r (.pred p i')) i
  | .order i j h =>
      Fin.cases (motive := fun i => i ≠ j → Bool)
        (fun h0 => Fin.cases (motive := fun j => (0 : Fin (n + 1)) ≠ j → Bool)
          (fun h00 => absurd rfl h00)
          (fun j' _ => (zs j').1) j h0)
        (fun i' hs => Fin.cases (motive := fun j => (i'.succ) ≠ j → Bool)
          (fun _ => (zs i').2)
          (fun j' hss => r (.order i' j' (fun he => hss (congrArg Fin.succ he)))) j hs)
        i h

/-- Round-trip 1 (`nf0_zoneSpec`): reassembling then re-reading the ordering channel
    recovers `zs`. Def 3.1 ordering channel bijectivity (PDF p.4). -/
theorem nf0_zoneSpec_assemble {sig : MonadicSignature} {n : Nat}
    (zs : ZoneSpec n) (χ : NormalForm sig 0 1) (r : NormalForm sig 0 n) :
    nf0_zoneSpec (nf0_assemble zs χ r) = zs := by
  funext i
  simp only [nf0_zoneSpec, nf0_assemble, Fin.cases_zero, Fin.cases_succ]

/-- Round-trip 2 (`nf0_projFresh`): reassembling then re-reading the monadic
    point-type channel recovers `χ`. Def 3.1 point-type channel bijectivity (PDF
    p.4). -/
theorem nf0_projFresh_assemble {sig : MonadicSignature} {n : Nat}
    (zs : ZoneSpec n) (χ : NormalForm sig 0 1) (r : NormalForm sig 0 n) :
    nf0_projFresh (nf0_assemble zs χ r) = χ := by
  funext a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    simp only [nf0_projFresh, nf0_assemble, Fin.cases_zero]
  | .order i j h => exact absurd (Subsingleton.elim i j) h

/-- Round-trip 3 (`nf0_dropFresh`): reassembling then re-reading the env-restriction
    channel recovers `r`. Def 3.1 env-restriction channel bijectivity (PDF p.4). -/
theorem nf0_dropFresh_assemble {sig : MonadicSignature} {n : Nat}
    (zs : ZoneSpec n) (χ : NormalForm sig 0 1) (r : NormalForm sig 0 n) :
    nf0_dropFresh (nf0_assemble zs χ r) = r := by
  funext a
  match a with
  | .pred p i =>
    simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
    simp only [nf0_assemble, Fin.cases_succ]
  | .order i j h =>
    simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
    simp only [nf0_assemble, Fin.cases_succ]

/-- Round-trip 4 (`nf0_split_assemble`): splitting `sub` into its three Def-3.1
    channels and reassembling recovers `sub` exactly. With the three projection
    round-trips this makes the depth-0 factorization a BIJECTION, not a projection —
    the G2 losslessness defence (Def 3.1, PDF p.4; deviation D7 rebuttal). -/
theorem nf0_split_assemble {sig : MonadicSignature} {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) :
    nf0_assemble (nf0_zoneSpec sub) (nf0_projFresh sub) (nf0_dropFresh sub) = sub := by
  funext a
  match a with
  | .pred p i =>
    refine Fin.cases ?_ ?_ i
    · simp only [nf0_assemble, nf0_projFresh, Fin.cases_zero]
    · intro i'
      simp only [nf0_assemble, nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.cases_succ]
  | .order i j h =>
    refine Fin.cases (motive := fun i => (h : i ≠ j) →
        nf0_assemble (nf0_zoneSpec sub) (nf0_projFresh sub) (nf0_dropFresh sub)
          (.order i j h) = sub (.order i j h)) ?_ ?_ i h
    · intro h0
      refine Fin.cases (motive := fun j => (h : (0 : Fin (n + 1)) ≠ j) →
          nf0_assemble (nf0_zoneSpec sub) (nf0_projFresh sub) (nf0_dropFresh sub)
            (.order 0 j h) = sub (.order 0 j h)) ?_ ?_ j h0
      · intro h00; exact absurd rfl h00
      · intro j' hj
        simp only [nf0_assemble, nf0_zoneSpec, Fin.cases_zero, Fin.cases_succ]
    · intro i' hi
      refine Fin.cases (motive := fun j => (h : i'.succ ≠ j) →
          nf0_assemble (nf0_zoneSpec sub) (nf0_projFresh sub) (nf0_dropFresh sub)
            (.order i'.succ j h) = sub (.order i'.succ j h)) ?_ ?_ j hi
      · intro h0
        simp only [nf0_assemble, nf0_zoneSpec, Fin.cases_zero, Fin.cases_succ]
      · intro j' hj
        simp only [nf0_assemble, nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.cases_succ]

/-! ## Phase 3: The depth-0 factorization theorem (Def 3.1's three channels, PDF p.4) -/

/-- A depth-0 `(n+1)`-ary evaluation with the fresh witness `x` consed at index `0`
    factors EXACTLY into Rabinovich's Def 3.1 three channels (PDF p.4): the
    **ordering** channel (`zoneHolds` on `nf0_zoneSpec`), the **monadic point type**
    channel (`nf_eval_nf` at arity 1 on `nf0_projFresh`), and the **env restriction**
    channel (`nf_eval_nf` at arity `n` on `nf0_dropFresh`). The factorization is
    LOSSLESS: together with `nf0_split_assemble` (Phase 2) it exhibits a bijection of
    characterizations, not a lossy projection — the G2 losslessness defence, and the
    depth-0-ONLY rebuttal to deviation D7 (no depth-`k`, `k≥1`, pointwise equivalence
    is claimed).

    Proof: depth-0 `nf_eval_nf` on both sides unfolds to `∀ a, atom_eval M · a ↔ · a =
    true`; the atoms of `AtomKind sig (n+1)` partition by index (`Fin.cases`) into the
    fresh-vs-fresh (impossible), fresh-vs-env order (ordering channel), env pred /
    env-vs-env order (env-restriction channel), and fresh pred (monadic channel)
    groups, transported atom-by-atom via `Fin.cons_zero` / `Fin.cons_succ`. This
    generalizes the `extract_y_nf` pattern (VecEADecomp:55-66) to arbitrary `n`. -/
theorem nf_eval_nf0_cons_factor {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (x : M.carrier) (sub : NormalForm sig 0 (n + 1)) :
    nf_eval_nf M 0 (n + 1) (Fin.cons x env) sub ↔
      zoneHolds M env (nf0_zoneSpec sub) x ∧
      nf_eval_nf M 0 1 (fun _ => x) (nf0_projFresh sub) ∧
      nf_eval_nf M 0 n env (nf0_dropFresh sub) := by
  constructor
  · -- Forward: factor out the three channels from the joint evaluation.
    intro h
    refine ⟨?_, ?_, ?_⟩
    · -- Ordering channel (Def 3.1 order conjuncts, PDF p.4).
      intro i
      refine ⟨?_, ?_⟩
      · have hz := h (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ, nf0_zoneSpec] using hz
      · have hz := h (.order i.succ 0 (Fin.succ_ne_zero i))
        simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ, nf0_zoneSpec] using hz
    · -- Monadic point-type channel (Def 3.1 α, PDF p.4).
      intro a
      match a with
      | .pred p i =>
        have hp := h (.pred p 0)
        simpa only [atom_eval, Fin.cons_zero, nf0_projFresh] using hp
      | .order i j hne => exact absurd (Subsingleton.elim i j) hne
    · -- Env-restriction channel (Def 3.1 env drop, PDF p.4).
      intro a
      match a with
      | .pred p k =>
        have hd := h (.pred p k.succ)
        simpa only [atom_eval, Fin.cons_succ, nf0_dropFresh, mergeNF,
          skipFin_zero_succ] using hd
      | .order k₁ k₂ hne =>
        have hd := h (.order k₁.succ k₂.succ
          (fun he => hne (Fin.succ_injective _ he)))
        simpa only [atom_eval, Fin.cons_succ, nf0_dropFresh, mergeNF,
          skipFin_zero_succ] using hd
  · -- Backward: reassemble the joint evaluation from the three channels.
    rintro ⟨hz, hp, hd⟩
    intro a
    match a with
    | .pred p i =>
      refine Fin.cases ?_ ?_ i
      · -- fresh predicate → monadic channel
        have := hp (.pred p 0)
        simpa only [atom_eval, Fin.cons_zero, nf0_projFresh] using this
      · -- env predicate → env-restriction channel
        intro i'
        have := hd (.pred p i')
        simpa only [atom_eval, Fin.cons_succ, nf0_dropFresh, mergeNF,
          skipFin_zero_succ] using this
    | .order i j hne =>
      refine Fin.cases (motive := fun i => (hij : i ≠ j) →
          (atom_eval M (Fin.cons x env) (.order i j hij)
            ↔ sub (.order i j hij) = true)) ?_ ?_ i hne
      · -- fresh is the left endpoint
        intro h0
        refine Fin.cases (motive := fun j => (h0j : (0 : Fin (n + 1)) ≠ j) →
            (atom_eval M (Fin.cons x env) (.order 0 j h0j)
              ↔ sub (.order 0 j h0j) = true)) ?_ ?_ j h0
        · intro h00; exact absurd rfl h00
        · -- (0, j'.succ): fresh < env j' → ordering channel .1
          intro j' _
          have := (hz j').1
          simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ, nf0_zoneSpec] using this
      · -- env is the left endpoint
        intro i' hi'
        refine Fin.cases (motive := fun j => (hsj : i'.succ ≠ j) →
            (atom_eval M (Fin.cons x env) (.order i'.succ j hsj)
              ↔ sub (.order i'.succ j hsj) = true)) ?_ ?_ j hi'
        · -- (i'.succ, 0): env i' < fresh → ordering channel .2
          intro _
          have := (hz i').2
          simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ, nf0_zoneSpec] using this
        · -- (i'.succ, j'.succ): env i' < env j' → env-restriction channel
          intro j' hsj
          have := hd (.order i' j' (fun he => hsj (congrArg Fin.succ he)))
          simpa only [atom_eval, Fin.cons_succ, nf0_dropFresh, mergeNF,
            skipFin_zero_succ] using this

end Bimodal.Metalogic.WeakCanonical.Kamp
