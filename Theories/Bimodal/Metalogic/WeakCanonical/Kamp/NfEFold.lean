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
def zoneHolds {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    {n : Nat} (env : Fin n → M.carrier) (zs : ZoneSpec n) (x : M.carrier) : Prop :=
  ∀ i : Fin n, (x < env i ↔ (zs i).1 = true) ∧ (env i < x ↔ (zs i).2 = true)

/-! ## The fold normal-form type (Def 4.1 + Lemma 3.2(2) as a type) -/

/-- Quant-assignment domain of the E[Σ]-fold: order position (`ZoneSpec n`) ×
    monadic depth-`k` point type (the E[Σ]-atom `NormalForm sig k 1`, Def 4.1
    PDF p.5). There is NO slot for a joint `(n+1)`-ary sub-evaluation — Lemma
    3.2(2)'s ≤2-free-variable cap (PDF p.4) is enforced by this type, not by a
    hand-written guard. -/
abbrev EAtomDom (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k n : Nat) : Type :=
  ZoneSpec n × NormalForm sig k 1

/-- E[Σ]-fold normal form: identical to `NormalForm` at depth 0 and in every atom
    layer; the quant layer ranges over `EAtomDom sig k n` (fixed arity `n`) instead
    of `NormalForm sig k (n+1)` (arity `n+1`). This is the type-level encoding of
    Lemma 3.2(2)'s ≤2 cap (PDF p.4): depth lives in the monadic atom `NormalForm
    sig k 1`, never in the arity of the environment. -/
def NormalFormEFold (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] : Nat → Nat → Type
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
noncomputable def nf_eval_efold {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem nf_eval_efold_zero_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
def nf0_zoneSpec {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) : ZoneSpec n :=
  fun i => (sub (.order 0 i.succ (Fin.succ_ne_zero i).symm),
            sub (.order i.succ 0 (Fin.succ_ne_zero i)))

/-- Monadic point-type channel (Def 3.1, PDF p.4): the predicate atoms of the fresh
    variable, read off as a `NormalForm sig 0 1`. `AtomKind sig 1` has no order atoms
    (`i ≠ j` is uninhabited at arity 1, cf. `nf_y_proj` VecEADecomp:33), so the order
    case is discharged by `absurd`. -/
def nf0_projFresh {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => sub (.pred p 0)
  | .order i j h => absurd (Subsingleton.elim i j) h

/-- Env-restriction channel (Def 3.1, PDF p.4): drop the fresh variable at position
    `0`. REUSES `mergeNF` at position `0` (NfDepth0Generalized:169); `skipFin ⟨0⟩`
    maps `Fin n` to indices `1..n` (see `skipFin_zero_succ`). -/
noncomputable def nf0_dropFresh {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) : NormalForm sig 0 n :=
  mergeNF sub ⟨0, Nat.succ_pos n⟩

/-- Reassemble a full `(n+1)`-ary depth-0 NF from the three Def-3.1 channels (PDF
    p.4). Predicate atoms: index `0` reads the monadic type `χ`, index `i.succ` reads
    the env restriction `r`. Order atoms: `(0, j.succ) ↦ (zs j).1`, `(i.succ, 0) ↦
    (zs i).2`, `(i.succ, j.succ) ↦ r`'s order atom; `(0,0)` is impossible by the
    atom's own `i ≠ j`. Pure `Fin.cases` bookkeeping, no semantics. -/
def nf0_assemble {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
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
theorem nf0_zoneSpec_assemble {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (zs : ZoneSpec n) (χ : NormalForm sig 0 1) (r : NormalForm sig 0 n) :
    nf0_zoneSpec (nf0_assemble zs χ r) = zs := by
  funext i
  simp only [nf0_zoneSpec, nf0_assemble, Fin.cases_zero, Fin.cases_succ]

/-- Round-trip 2 (`nf0_projFresh`): reassembling then re-reading the monadic
    point-type channel recovers `χ`. Def 3.1 point-type channel bijectivity (PDF
    p.4). -/
theorem nf0_projFresh_assemble {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
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
theorem nf0_dropFresh_assemble {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
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
theorem nf0_split_assemble {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
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
theorem nf_eval_nf0_cons_factor {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

/-! ## Phase 4: Bridge lemmas + k=1 gate corollary (Prop 4.3 innermost ∃-fold, PDF p.6)

The DONE signal for task 310. `nf_quant_layer_fold_iff` is the load-bearing GENERAL-`n`
one-step fold engine (the only proof consuming `nf_eval_unique`); it is Prop 4.3's innermost
∃-step (PDF p.6) in NF form. `efold_of_nf1` transports a depth-1 NF into the fold encoding;
`nf_eval_nf1_iff_efold` is the k=1 whole-evaluation bridge with the explicit off-fiber falsity
conjunct (the honest bridge); `nf_quant_layer_fold_k1_gate` instantiates the engine at `n = 3`,
env `[w,x,t]`, matching the R2 NO-GO residual (NfMultiAnchorBridge.lean:1601-1603) VERBATIM —
task 311's entry point.

D7 reminder: this bridge is claimed ONLY at depth-0 subs (k=1); NO depth-`k` (`k≥1`) pointwise
equivalence is stated or attempted. The GENERAL-`n` engine's inside-out iteration belongs to
task 309-R3, not here. -/

/-- One step of `nf_eval_nf`'s quant layer over depth-0 subs is equivalent to the E[Σ]-fold form,
    given the env's own depth-0 type `r` (`h_r : nf_eval_nf M 0 n env r`). This is Rabinovich
    Prop 4.3's innermost ∃-fold (PDF p.6) transcribed in NF form.

    - LHS: the R2 NO-GO residual shape — a joint `(n+1)`-ary existential per sub.
    - RHS, first conjunct: zone-bounded MONADIC existentials (Def 3.1 α + ordering channels,
      PDF p.4; the Lemma-3.4/Prop-3.5 objects the bracket machinery evaluates), quantifying only
      over `ZoneSpec n × NormalForm sig 0 1` — no `(n+1)`-ary object remains.
    - RHS, second conjunct: the explicit off-fiber falsity clause — subs whose env-restriction
      is not `r` are forced false (via `nf_eval_unique`, NormalForm.lean:245).

    Stated at GENERAL `n`: the proof is index-structural, and 309-R3's inside-out iteration
    (Prop 4.3, PDF p.6) applies this same lemma at growing env arities. The gate corollary
    instantiates `n = 3`. -/
theorem nf_quant_layer_fold_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (r : NormalForm sig 0 n)
    (h_r : nf_eval_nf M 0 n env r)
    (q : NormalForm sig 0 (n + 1) → Bool) :
    (∀ sub : NormalForm sig 0 (n + 1),
        (∃ x : M.carrier, nf_eval_nf M 0 (n + 1) (Fin.cons x env) sub) ↔ q sub = true)
    ↔
    ((∀ (zs : ZoneSpec n) (χ : NormalForm sig 0 1),
        (∃ x : M.carrier, zoneHolds M env zs x ∧ nf_eval_nf M 0 1 (fun _ => x) χ) ↔
          q (nf0_assemble zs χ r) = true) ∧
     (∀ sub : NormalForm sig 0 (n + 1), nf0_dropFresh sub ≠ r → q sub = false)) := by
  -- Per-witness factorization with the third (env-restriction) factor collapsed by `h_r`.
  have factor : ∀ (sub : NormalForm sig 0 (n + 1)) (x : M.carrier),
      nf0_dropFresh sub = r →
      (nf_eval_nf M 0 (n + 1) (Fin.cons x env) sub ↔
        zoneHolds M env (nf0_zoneSpec sub) x ∧
          nf_eval_nf M 0 1 (fun _ => x) (nf0_projFresh sub)) := by
    intro sub x hsub
    rw [nf_eval_nf0_cons_factor M env x sub, hsub]
    constructor
    · rintro ⟨hz, hp, _⟩; exact ⟨hz, hp⟩
    · rintro ⟨hz, hp⟩; exact ⟨hz, hp, h_r⟩
  -- Existential lift of the factorization.
  have factorE : ∀ (sub : NormalForm sig 0 (n + 1)), nf0_dropFresh sub = r →
      ((∃ x : M.carrier, nf_eval_nf M 0 (n + 1) (Fin.cons x env) sub) ↔
        (∃ x : M.carrier, zoneHolds M env (nf0_zoneSpec sub) x ∧
          nf_eval_nf M 0 1 (fun _ => x) (nf0_projFresh sub))) := by
    intro sub hsub
    exact exists_congr (fun x => factor sub x hsub)
  -- Off-fiber: any joint witness forces the env-restriction to equal `r` (uniqueness).
  have offF : ∀ (sub : NormalForm sig 0 (n + 1)),
      (∃ x : M.carrier, nf_eval_nf M 0 (n + 1) (Fin.cons x env) sub) →
      nf0_dropFresh sub = r := by
    intro sub hex
    obtain ⟨x, hx⟩ := hex
    have hfac := (nf_eval_nf0_cons_factor M env x sub).mp hx
    exact nf_eval_unique M 0 n env (nf0_dropFresh sub) r hfac.2.2 h_r
  constructor
  · -- Forward.
    intro H
    refine ⟨?_, ?_⟩
    · -- First conjunct: rewrite the joint existential to the monadic form via the round-trips.
      intro zs χ
      have hr := factorE (nf0_assemble zs χ r) (nf0_dropFresh_assemble zs χ r)
      rw [nf0_zoneSpec_assemble, nf0_projFresh_assemble] at hr
      exact hr.symm.trans (H (nf0_assemble zs χ r))
    · -- Second conjunct: off-fiber falsity via uniqueness.
      intro sub hne
      by_contra hq
      have hqt : q sub = true := by
        cases hqv : q sub with
        | false => exact absurd hqv hq
        | true => rfl
      exact hne (offF sub ((H sub).mpr hqt))
  · -- Backward.
    rintro ⟨HA, HB⟩ sub
    by_cases heq : nf0_dropFresh sub = r
    · -- Compatible fiber: `sub = nf0_assemble (nf0_zoneSpec sub) (nf0_projFresh sub) r`.
      have hassemble :
          nf0_assemble (nf0_zoneSpec sub) (nf0_projFresh sub) r = sub := by
        have hsp := nf0_split_assemble sub
        rw [heq] at hsp
        exact hsp
      have hA := HA (nf0_zoneSpec sub) (nf0_projFresh sub)
      rw [hassemble] at hA
      exact (factorE sub heq).trans hA
    · -- Off fiber: both sides false.
      constructor
      · intro hex
        exact absurd (offF sub hex) heq
      · intro hqt
        rw [HB sub heq] at hqt
        exact Bool.noConfusion hqt

/-- Transport a depth-1 `NormalForm` into the fold encoding along its own atom layer (the
    compatible fiber over `qnf.1`, Def 4.1 PDF p.5). The atom layer is carried unchanged; the
    quant layer reads `qnf.2` at the reassembled sub `nf0_assemble e.1 e.2 qnf.1` — i.e. the
    unique `(n+1)`-ary sub whose env-restriction is `qnf.1`, order channel `e.1`, point type
    `e.2`. Subs off that fiber are invisible to the fold (that is the ≤2-cap at work); their
    falsity is recorded separately by `nf_eval_nf1_iff_efold`. -/
noncomputable def efold_of_nf1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (qnf : NormalForm sig 1 n) : NormalFormEFold sig 1 n :=
  ⟨qnf.1, fun e => qnf.2 (nf0_assemble e.1 e.2 qnf.1)⟩

/-- The k=1 whole-evaluation bridge (Def 4.1 PDF p.5; Lemma 3.4 PDF p.5): `nf_eval_nf` at depth 1
    is the fold evaluation of the transported form `efold_of_nf1 qnf`, PLUS the explicit off-fiber
    falsity of `qnf.2`. Both directions are used by task 311.

    The atom layers coincide definitionally (`qnf.1 : AtomKind sig n → Bool` IS a
    `NormalForm sig 0 n`, and both atom conjuncts are `∀ a, atom_eval M env a ↔ · a = true`,
    NormalForm.lean:201-204). The quant layers are bridged by `nf_quant_layer_fold_iff` with
    `r := qnf.1` and `h_r :=` the shared atom layer.

    The off-fiber clause `∀ sub, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false` CANNOT be absorbed
    silently: `qnf.2`'s values on subs whose env-restriction contradicts `qnf.1` are unconstrained
    by the fold (it has no slot for them — the point of the ≤2 cap), but `nf_eval_nf M 1 n env qnf`
    FORCES them false. Making it an explicit conjunct is the honest bridge; it is decidable and
    model-independent (§5.4). -/
theorem nf_eval_nf1_iff_efold {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (qnf : NormalForm sig 1 n) :
    nf_eval_nf M 1 n env qnf ↔
      (nf_eval_efold M 1 n env (efold_of_nf1 qnf) ∧
       ∀ sub : NormalForm sig 0 (n + 1), nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false) := by
  -- Unfold both evaluations to their (shared) atom conjunct + quant conjunct (defeq).
  have hnf : nf_eval_nf M 1 n env qnf ↔
      (nf_eval_nf M 0 n env qnf.1 ∧
        (∀ sub : NormalForm sig 0 (n + 1),
          (∃ x : M.carrier, nf_eval_nf M 0 (n + 1) (Fin.cons x env) sub) ↔
            qnf.2 sub = true)) := Iff.rfl
  have hef : nf_eval_efold M 1 n env (efold_of_nf1 qnf) ↔
      (nf_eval_nf M 0 n env qnf.1 ∧
        (∀ e : EAtomDom sig 0 n,
          (∃ x : M.carrier, zoneHolds M env e.1 x ∧ nf_eval_nf M 0 1 (fun _ => x) e.2) ↔
            qnf.2 (nf0_assemble e.1 e.2 qnf.1) = true)) := Iff.rfl
  rw [hnf, hef]
  constructor
  · -- Forward: the atom layer supplies `h_r`; fold the quant layer via the engine.
    rintro ⟨hA, hQ⟩
    have hfold := (nf_quant_layer_fold_iff M env qnf.1 hA qnf.2).mp hQ
    exact ⟨⟨hA, fun e => hfold.1 e.1 e.2⟩, hfold.2⟩
  · -- Backward: reassemble the quant layer from the fold form + off-fiber clause.
    rintro ⟨⟨hA, hEQ⟩, hOFF⟩
    refine ⟨hA, ?_⟩
    exact (nf_quant_layer_fold_iff M env qnf.1 hA qnf.2).mpr
      ⟨fun zs χ => hEQ (zs, χ), hOFF⟩

/-- **The gate corollary — task 310's DONE signal.** The exact R2 NO-GO residual
    (NfMultiAnchorBridge.lean:1601-1603), fold-reduced: under `h_atom` (available at that proof
    point), the arity-4 quant residual is equivalent to zone-bounded MONADIC existentials over
    env `[w,x,t]` (Prop 4.3 innermost fold, PDF p.6; Lemma 3.4, PDF p.5) plus the off-fiber
    falsity of `qnf.2`. No arity-4 object remains on the RHS. A one-line instantiation of
    `nf_quant_layer_fold_iff` at `n = 3`. Task 311 discharges the RHS. -/
theorem nf_quant_layer_fold_k1_gate {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (qnf : NormalForm sig 1 3)
    (h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1) :
    (∀ sub_nf : NormalForm sig 0 4,
        (∃ x_1, nf_eval_nf M 0 4
          (Fin.cons x_1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub_nf) ↔
          qnf.2 sub_nf = true)
    ↔
    ((∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
        (∃ x_1, zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs x_1 ∧
          nf_eval_nf M 0 1 (fun _ => x_1) χ) ↔
          qnf.2 (nf0_assemble zs χ qnf.1) = true) ∧
     (∀ sub_nf, nf0_dropFresh sub_nf ≠ qnf.1 → qnf.2 sub_nf = false)) :=
  nf_quant_layer_fold_iff M _ qnf.1 h_atom qnf.2

/-! ## Task 349 Phase 1: the general-`k` faithful whole-evaluation fold bridge

`nf_eval_nfk_iff_efold` is the depth-general analog of the depth-1 bridge
`nf_eval_nf1_iff_efold` (:490) — the construction gate that every later phase's
`k`-generalization rests on. It characterizes `nf_eval_nf M (k+1) n env qnf` as a
*fold characterization* on the compatible atom-fiber PLUS the explicit off-fiber falsity
of `qnf.2`, exactly mirroring the honest-bridge shape of the k=1 lemma.

**Faithfulness / F2-immunity (sanctioned signature adjustment, report 10 GO probe).**
The k=1 bridge uses the arity-1 `EAtomDom sig 0 n = ZoneSpec n × NormalForm sig 0 1`
re-encoding (`efold_of_nf1`/`nf_eval_efold`) because a depth-0 sub factors **losslessly**
into (order-zone, arity-1 monadic type, env-restriction) — `nf_eval_nf0_cons_factor`. That
lossless factorization does NOT hold at depth `k ≥ 1`: a depth-`≥1` sub couples the fresh
witness jointly to the environment through its own nested quantifier layers, so the arity-1
projection `NormalForm sig k 1` is lossy — this is precisely the collapse the task-327 NO-GO
certified and the F2 refutation (`nfk_projFresh`) exploited. `nf_eval_efold_k` therefore reads
its subs at **FULL arity `n+1`** (`nf_eval_nf M k (n + 1) …`, never `nfk_projFresh`): the
outer existential is characterized on the compatible atom-fiber without any depth-`k` arity-1
collapse. The non-negotiable biconditional shape (whole-eval ↔ fold-characterization ∧
off-fiber falsity) is preserved; a re-encoding transport `efold_of_nfk` is unnecessary because
the faithful fold characterizes `qnf` in place.

**Off-fiber determinacy.** The off-fiber conjunct is discharged by `nf_eval_unique M 0 n env`
on the atom layers (the depth-general uniqueness the GO probe confirmed, specialized to depth 0
here since fibers are compared at the atom level): any joint witness of a sub forces the sub's
atom env-restriction to equal `qnf.1`, so subs off that fiber are unsatisfiable and `qnf.2`
must report them false — the honest bridge's explicit exclusion clause.

D7 reminder: no depth-`k` (`k ≥ 1`) pointwise arity-1 equivalence is stated or attempted; the
characterization is at full arity, and the depth-0-only losslessness of `nf0_*` is used only on
the atom layer. -/

/-- Atom-layer env-restriction of a depth-`k` sub: drop the fresh variable at index `0` from
    the sub's atom layer (`sub.atom_assgn : NormalForm sig 0 (n+1)`), REUSING `nf0_dropFresh`.
    Result is `NormalForm sig 0 n` — the depth-0 env restriction of the atom layer, NOT an
    arity-1 projection of the sub's content (`nfk_projFresh`, which is F2-DEAD and never built).
    This is the depth-`k` analog of `nf0_dropFresh`; it is the fiber label used by the bridge. -/
noncomputable def nfk_dropFresh {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k n : Nat}
    (sub : NormalForm sig k (n + 1)) : NormalForm sig 0 n :=
  nf0_dropFresh sub.atom_assgn

/-- Order (zone) channel of a depth-`k` sub's fresh variable, read from the atom layer via
    `nf0_zoneSpec`. The depth-`k` analog of `nf0_zoneSpec`; the ONLY channel through which the
    quantified witness meets the fixed environment points (Def 3.1, PDF p.4), read losslessly
    off the atom layer (no depth-`k` collapse). Provided for the downstream zone-pinning phases. -/
def nfk_zoneSpec {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k n : Nat}
    (sub : NormalForm sig k (n + 1)) : ZoneSpec n :=
  nf0_zoneSpec sub.atom_assgn

/-- The atom layer of any depth-`k` evaluation holds at depth 0: if `nf_eval_nf M k n env nf`
    then the atom assignment `nf.atom_assgn` is the depth-0 characteristic at `env`. Depth 0 is
    definitional (`nf.atom_assgn = nf`); depth `k+1` is the first conjunct of `nf_eval_nf`. -/
theorem nf_eval_nf_atom_layer {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {k n : Nat}
    (env : Fin n → M.carrier) (nf : NormalForm sig k n)
    (h : nf_eval_nf M k n env nf) :
    nf_eval_nf M 0 n env nf.atom_assgn := by
  cases k with
  | zero => exact h
  | succ k => exact h.1

/-- Faithful (full-arity) depth-`k` fold characterization of `qnf`'s outer quant layer: the atom
    layer `qnf.1` is the depth-0 characteristic at `env`, AND on the compatible atom-fiber (subs
    whose atom env-restriction equals `qnf.1`) the outer existential over the FULL-arity sub matches
    `qnf.2`. NO arity-1 collapse: subs are read at `nf_eval_nf M k (n + 1) …`. This is the
    depth-general analog of the fold conjunct of `nf_eval_nf1_iff_efold`; off-fiber subs are handled
    by the separate off-fiber conjunct of `nf_eval_nfk_iff_efold`. -/
noncomputable def nf_eval_efold_k {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {k n : Nat}
    (env : Fin n → M.carrier) (qnf : NormalForm sig (k + 1) n) : Prop :=
  nf_eval_nf M 0 n env qnf.1 ∧
    ∀ sub : NormalForm sig k (n + 1), nfk_dropFresh sub = qnf.1 →
      ((∃ x : M.carrier, nf_eval_nf M k (n + 1) (Fin.cons x env) sub) ↔ qnf.2 sub = true)

/-- **The general-`k` whole-evaluation fold bridge (task 349 Phase 1 construction gate).**
    `nf_eval_nf` at depth `k+1` is the faithful full-arity fold characterization `nf_eval_efold_k`
    of `qnf`, PLUS the explicit off-fiber falsity of `qnf.2`. The depth-general analog of
    `nf_eval_nf1_iff_efold` (:490).

    Proof: the whole evaluation decomposes (defeq) into its atom layer `nf_eval_nf M 0 n env qnf.1`
    and its full quant layer over all depth-`k` subs. The quant layer splits by the decidable fiber
    label `nfk_dropFresh sub = qnf.1`: on-fiber it is `nf_eval_efold_k`'s second conjunct verbatim;
    off-fiber, any joint witness would force (via `nf_eval_nf0_cons_factor` on the atom layer and
    `nf_eval_unique M 0 n`) the label to equal `qnf.1` — a contradiction — so the existential is
    false and `qnf.2` must report false. Consumes `nf_eval_unique` and `nf_eval_nf0_cons_factor`;
    re-derives neither. -/
theorem nf_eval_nfk_iff_efold {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {k n : Nat}
    (env : Fin n → M.carrier) (qnf : NormalForm sig (k + 1) n) :
    nf_eval_nf M (k + 1) n env qnf ↔
      (nf_eval_efold_k M env qnf ∧
       ∀ sub : NormalForm sig k (n + 1), nfk_dropFresh sub ≠ qnf.1 → qnf.2 sub = false) := by
  -- Off-fiber forcing: a joint witness pins the atom env-restriction to `qnf.1` (uniqueness).
  have offForce : ∀ (sub : NormalForm sig k (n + 1)),
      nf_eval_nf M 0 n env qnf.1 →
      (∃ x, nf_eval_nf M k (n + 1) (Fin.cons x env) sub) → nfk_dropFresh sub = qnf.1 := by
    intro sub hq hex
    obtain ⟨x, hx⟩ := hex
    have hatom := nf_eval_nf_atom_layer M (Fin.cons x env) sub hx
    have hfac := (nf_eval_nf0_cons_factor M env x sub.atom_assgn).mp hatom
    exact nf_eval_unique M 0 n env (nf0_dropFresh sub.atom_assgn) qnf.1 hfac.2.2 hq
  -- The whole evaluation is (defeq) its atom layer and its full quant layer.
  have hnf : nf_eval_nf M (k + 1) n env qnf ↔
      (nf_eval_nf M 0 n env qnf.1 ∧
        ∀ sub : NormalForm sig k (n + 1),
          (∃ x, nf_eval_nf M k (n + 1) (Fin.cons x env) sub) ↔ qnf.2 sub = true) := Iff.rfl
  rw [hnf]
  simp only [nf_eval_efold_k]
  constructor
  · -- Forward: split the full quant layer into compatible fiber + off-fiber falsity.
    rintro ⟨hA, hQ⟩
    refine ⟨⟨hA, fun sub _ => hQ sub⟩, ?_⟩
    intro sub hne
    by_contra hnfalse
    have htrue : qnf.2 sub = true := by
      cases h : qnf.2 sub with
      | false => exact absurd h hnfalse
      | true => rfl
    exact hne (offForce sub hA ((hQ sub).mpr htrue))
  · -- Backward: reassemble the full quant layer from the fiber form + off-fiber clause.
    rintro ⟨⟨hA, hfib⟩, hoff⟩
    refine ⟨hA, ?_⟩
    intro sub
    by_cases hd : nfk_dropFresh sub = qnf.1
    · exact hfib sub hd
    · rw [hoff sub hd]
      constructor
      · intro hex; exact absurd (offForce sub hA hex) hd
      · intro hcontra; exact Bool.noConfusion hcontra

/-- **k=1 sanity recovery.** At `k = 0` (depth 1) the general bridge is interderivable with the
    frozen depth-1 bridge `nf_eval_nf1_iff_efold` (:490): both characterize `nf_eval_nf M 1 n env qnf`
    exactly, so the general fold characterization `nf_eval_efold_k` (with its off-fiber clause) is
    equivalent to the arity-1 `nf_eval_efold`/`efold_of_nf1` form. The general bridge is therefore
    NOT weaker than the green depth-1 lemma. (At depth 0 the arity-1 factorization is lossless, so
    the two fold forms coincide up to `nf_quant_layer_fold_iff`; at depth `k ≥ 1` only the
    full-arity `nf_eval_efold_k` remains faithful — see the section note.) -/
theorem nf_eval_nfk_iff_efold_k1_recovers {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (qnf : NormalForm sig 1 n) :
    (nf_eval_efold_k M env qnf ∧
      ∀ sub : NormalForm sig 0 (n + 1), nfk_dropFresh sub ≠ qnf.1 → qnf.2 sub = false)
    ↔
    (nf_eval_efold M 1 n env (efold_of_nf1 qnf) ∧
      ∀ sub : NormalForm sig 0 (n + 1), nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false) :=
  (nf_eval_nfk_iff_efold M env qnf).symm.trans (nf_eval_nf1_iff_efold M env qnf)

end Bimodal.Metalogic.WeakCanonical.Kamp
