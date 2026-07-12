import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracket
import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold

/-! # Depth-`k` exterior-bracket determinacy core (task 349, Phase 2)

Task 349 v7 Phase 2 targets the `k`-generalized per-side exterior brackets
(`kvE_extBracketPast/Fut` + `_sound`/`_complete`) whose determinacy inputs read depth `k`:
the k=2 `habove`/`hbelow` hypothesis type `(χ : NormalForm sig 0 1)` at `nf_eval_nf M 0 1`
(ExteriorBracket.lean:463-466) becomes `NormalForm sig k 1` at `nf_eval_nf M k 1`, with
`nf_eval_unique M k` supplying determinacy and the Phase-1 bridge `nf_eval_nfk_iff_efold`
(NfEFold.lean:627) supplying the fold characterization.

This module lands the **design-invariant determinacy core** of that channel:

1. `nfk_truncD` — one-layer depth truncation `NormalForm sig (k+1) n → NormalForm sig k n`
   (atom layer preserved; quant bits read fiber-existentially at FULL arity — no
   `nfk_projFresh` re-encoding of `qnf.2`, G1), with the ONE-DIRECTIONAL soundness
   `nf_eval_truncD` (realized at depth `k+1` ⟹ truncation realized at depth `k`). The
   converse is FALSE by design — this is the "sound one-directional exclusion, NOT a
   lossless projection of the whole sub" distinction (report 10 C4-C6) that keeps
   carrier 3 F2-immune.
2. `nf_eval_take` — depth-GENERAL prefix-restriction soundness for `nfk_take`
   (CarrierKv.lean:70), generalizing the depth-1-only `kvE2_sepProjFresh_eval`
   (SharedWitness.lean:7297) to symbolic `k` by induction: quant layers transport through
   `nf_characteristic` + `nf_eval_unique M k` — report 10's exact determinacy prescription.
   Specialization `nf_eval_projFresh` at `m = 1`.
3. `kvE_sepPos` / `kvE_projFreshD` / `kvE_futAnyBit` — the depth-`k` zone-fact channel:
   `kvE_futAnyBit qnf zs χ` (for `qnf : NormalForm sig (k+2) 3`, `χ : NormalForm sig k 1`)
   reads whether some positive sub of `qnf` sits in outer zone `zs` with fresh depth-`k`
   arity-1 shadow `χ`. At `k = 0` this is definitionally the frozen `kvE2_futAnyBit`
   (agreement lemma `kvE_futAnyBit_zero`).
4. `kvE_futAnyBit_correct` — the depth-`k` honesty biconditional (the generalization of
   `kvE2_futAnyBit_correct`, ExteriorNegation.lean:148): under realized `qnf`,
   `(∃ v, zoneHolds … zs v ∧ nf_eval_nf M k 1 (fun _ => v) χ) ↔ kvE_futAnyBit qnf zs χ`.
   This IS the depth-`k` `habove`/`hbelow` pin the Phase-2 bracket lemmas consume, in the
   exact `NormalForm sig k 1` / `nf_eval_nf M k 1` shape the plan prescribes.

**Phase-2 residual (recorded, escalated — see the task-349 Phase-2 blocker record).** The
four bracket lemmas themselves additionally require a depth-`k` CLAUSE layer (the Lemma
7.10 navigated positive forms / complement clauses for subs `σ : NormalForm sig (k+1) 4`).
The frozen k=2 clause layer (ExteriorNegation, ExteriorNegationPast) is depth-hardwired through
`nf0_assemble`'s lossless depth-1 coordinatization, and the faithful Rabinovich Def-7.5
bracket at rung `k+1` consumes rung-`k` bracket formulas from the recursion (report 10
adversarial §2: "the exterior bracket's own recursive fold") — not available to this leaf
module. The determinacy core below is what every resolution of that residual consumes.

Purely additive leaf module; no frozen file is touched. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-! ## One-layer depth truncation (full-arity, fiber-existential — G1-compliant) -/

/-- **One-layer depth truncation** of a depth-`(k+1)` normal form: the atom layer is kept;
    a depth-`(k-1)`-side sub `s'` is marked realized iff SOME bit-true depth-one-higher sub
    truncates to it. Reads `nf.2` fiber-existentially at FULL arity (never through an
    arity-1 re-encoding — G1). One-directionally sound (`nf_eval_truncD`); deliberately NOT
    lossless (report 10 C4: losslessness at depth `k ≥ 1` is the F2-refuted collapse). -/
noncomputable def nfk_truncD {sig : MonadicSignature} :
    {k : Nat} → {n : Nat} → NormalForm sig (k + 1) n → NormalForm sig k n
  | 0, _, nf => nf.1
  | _ + 1, _, nf =>
      ⟨nf.1, fun s' => decide (∃ s, nf.2 s = true ∧ nfk_truncD s = s')⟩

/-- Truncation preserves the atom layer. -/
theorem nfk_truncD_atom {sig : MonadicSignature} {k n : Nat}
    (nf : NormalForm sig (k + 1) n) :
    (nfk_truncD nf).atom_assgn = nf.1 := by
  cases k with
  | zero => rfl
  | succ k => rfl

/-- **Truncation soundness** (one-directional): a realized depth-`(k+1)` normal form has a
    realized truncation. Quant layers transport through `nf_characteristic` +
    `nf_eval_unique M k` — the depth-general determinacy (report 10 C2/C3). The converse is
    FALSE at depth `k ≥ 1` (distinct forms share a truncation; only one is realized). -/
theorem nf_eval_truncD {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    ∀ {k n : Nat} (env : Fin n → M.carrier) (nf : NormalForm sig (k + 1) n),
      nf_eval_nf M (k + 1) n env nf → nf_eval_nf M k n env (nfk_truncD nf)
  | 0, n, env, nf, h => h.1
  | k + 1, n, env, nf, h => by
    obtain ⟨hatom, hquant⟩ := h
    refine ⟨hatom, fun s' => ?_⟩
    simp only [nfk_truncD, decide_eq_true_eq]
    constructor
    · rintro ⟨x, hx⟩
      -- the depth-(k+1) characteristic of the witness column is bit-true and truncates
      -- to s' by uniqueness at depth k.
      refine ⟨nf_characteristic M (k + 1) (n + 1) (Fin.cons x env),
        (hquant _).mp ⟨x, nf_characteristic_satisfies M (k + 1) (n + 1) (Fin.cons x env)⟩,
        ?_⟩
      exact nf_eval_unique M k (n + 1) (Fin.cons x env) _ s'
        (nf_eval_truncD M (Fin.cons x env) _
          (nf_characteristic_satisfies M (k + 1) (n + 1) (Fin.cons x env)))
        hx
    · rintro ⟨s, hbit, rfl⟩
      obtain ⟨x, hx⟩ := (hquant s).mpr hbit
      exact ⟨x, nf_eval_truncD M (Fin.cons x env) s hx⟩

/-! ## Depth-general prefix-restriction soundness (`nfk_take` / `nfk_projFresh`) -/

/-- **Depth-general prefix-restriction soundness**: a realized depth-`k` arity-`n` normal
    form restricts (along `Fin.castLE`) to a realized arity-`m` form. Generalizes the
    depth-1-only `kvE2_sepProjFresh_eval` machinery (SharedWitness.lean:7280-7345) to
    symbolic `k`: the quant layer transports through `nf_characteristic` +
    `nf_eval_unique M k` at every layer. -/
theorem nf_eval_take {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    ∀ {k m n : Nat} (hmn : m ≤ n) (env : Fin n → M.carrier)
      (sub : NormalForm sig k n),
      nf_eval_nf M k n env sub →
      nf_eval_nf M k m (fun i => env (Fin.castLE hmn i)) (nfk_take hmn sub)
  | 0, m, n, hmn, env, sub, hs => by
    intro a
    match a with
    | .pred p i => exact hs (.pred p (Fin.castLE hmn i))
    | .order i j hne =>
      exact hs (.order (Fin.castLE hmn i) (Fin.castLE hmn j)
        (fun he => hne (Fin.castLE_injective hmn he)))
  | k + 1, m, n, hmn, env, sub, hs => by
    obtain ⟨hatom, hquant⟩ := hs
    refine ⟨?_, fun s' => ?_⟩
    · -- atom channel: the depth-0 restriction read.
      intro a
      match a with
      | .pred p i => exact hatom (.pred p (Fin.castLE hmn i))
      | .order i j hne =>
        exact hatom (.order (Fin.castLE hmn i) (Fin.castLE hmn j)
          (fun he => hne (Fin.castLE_injective hmn he)))
    · -- quant channel: characteristic + uniqueness transport along the restriction.
      have hcons : ∀ x : M.carrier,
          (fun i => (Fin.cons x env : Fin (n + 1) → M.carrier)
            (Fin.castLE (Nat.succ_le_succ hmn) i))
          = (Fin.cons x (fun i => env (Fin.castLE hmn i)) : Fin (m + 1) → M.carrier) := by
        intro x
        funext i
        match i with
        | ⟨0, _⟩ => rfl
        | ⟨j + 1, hj⟩ => rfl
      simp only [nfk_take, decide_eq_true_eq]
      constructor
      · rintro ⟨x, hx⟩
        refine ⟨nf_characteristic M k (n + 1) (Fin.cons x env),
          (hquant _).mp ⟨x, nf_characteristic_satisfies M k (n + 1) (Fin.cons x env)⟩,
          ?_⟩
        have htake := nf_eval_take M (Nat.succ_le_succ hmn) (Fin.cons x env) _
          (nf_characteristic_satisfies M k (n + 1) (Fin.cons x env))
        rw [hcons x] at htake
        exact nf_eval_unique M k (m + 1) _ _ s' htake hx
      · rintro ⟨s, hbit, rfl⟩
        obtain ⟨x, hx⟩ := (hquant s).mpr hbit
        have htake := nf_eval_take M (Nat.succ_le_succ hmn) (Fin.cons x env) s hx
        rw [hcons x] at htake
        exact ⟨x, htake⟩

/-- **Depth-general fresh-projection soundness**: a realized depth-`k` sub factors through
    its fresh depth-`k` arity-1 projection at the witness point — the symbolic-`k`
    generalization of `kvE2_sepProjFresh_eval` (SharedWitness.lean:7297). -/
theorem nf_eval_projFresh {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {k n : Nat}
    (env : Fin n → M.carrier) (v : M.carrier)
    (sub : NormalForm sig k (n + 1))
    (hsub : nf_eval_nf M k (n + 1) (Fin.cons v env) sub) :
    nf_eval_nf M k 1 (fun _ => v) (nfk_projFresh sub) := by
  have h := nf_eval_take M (Nat.succ_le_succ (Nat.zero_le n)) (Fin.cons v env) sub hsub
  have henv : (fun i => (Fin.cons v env : Fin (n + 1) → M.carrier)
      (Fin.castLE (Nat.succ_le_succ (Nat.zero_le n)) i))
      = (fun _ : Fin 1 => v) := by
    funext i
    match i with
    | ⟨0, _⟩ => rfl
  rw [henv] at h
  exact h

/-! ## The depth-`k` zone-fact channel (`kvE_futAnyBit`) -/

/-- Positive subs of a depth-`(k+2)` arity-3 normal form (the depth-`k` generalization of
    `kvE2_sepPos`, SharedWitness.lean:193). -/
noncomputable def kvE_sepPos {sig : MonadicSignature} {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) : List (NormalForm sig (k + 1) 4) :=
  (Finset.univ.toList (α := NormalForm sig (k + 1) 4)).filter fun σ => qnf.2 σ

/-- Membership unfold for `kvE_sepPos`. -/
theorem kvE_sepPos_mem {sig : MonadicSignature} {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) (σ : NormalForm sig (k + 1) 4) :
    σ ∈ kvE_sepPos qnf ↔ qnf.2 σ = true := by
  simp only [kvE_sepPos, List.mem_filter, Finset.mem_toList, Finset.mem_univ, true_and]

/-- **Depth-`k` fresh shadow** of a depth-`(k+1)` sub: the fresh variable's arity-1
    restriction (`nfk_projFresh`, full-arity prefix read), truncated one depth layer
    (`nfk_truncD`). At `k = 0` this is the frozen `nf0_projFresh ∘ (·.1)` read
    (`kvE_projFreshD_zero`). Used ONLY as a coordinate label on the zone-fact channel —
    never as a re-encoding of any quant assignment (G1). -/
noncomputable def kvE_projFreshD {sig : MonadicSignature} {k n : Nat}
    (σ : NormalForm sig (k + 1) (n + 1)) : NormalForm sig k 1 :=
  nfk_truncD (nfk_projFresh σ)

/-- A realized depth-`(k+1)` sub realizes its depth-`k` fresh shadow at the witness. -/
theorem nf_eval_projFreshD {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {k n : Nat}
    (env : Fin n → M.carrier) (v : M.carrier)
    (σ : NormalForm sig (k + 1) (n + 1))
    (hσ : nf_eval_nf M (k + 1) (n + 1) (Fin.cons v env) σ) :
    nf_eval_nf M k 1 (fun _ => v) (kvE_projFreshD σ) :=
  nf_eval_truncD M (fun _ => v) (nfk_projFresh σ)
    (nf_eval_projFresh M env v σ hσ)

/-- **Depth-`k` zone-fact bit** (the generalization of `kvE2_futAnyBit`,
    ExteriorNegation.lean:102, to `qnf : NormalForm sig (k+2) 3` and depth-`k` profiles
    `χ : NormalForm sig k 1`): whether some positive sub of `qnf` sits in the outer zone
    `zs` of `[w,x,t]` with fresh depth-`k` shadow `χ`. Zone read off the atom layer
    (`nf0_zoneSpec`, lossless — depth-0-only losslessness used ONLY on the atom layer,
    per the D7 discipline); profile read through `kvE_projFreshD`. -/
noncomputable def kvE_futAnyBit {sig : MonadicSignature} {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) (zs : ZoneSpec 3)
    (χ : NormalForm sig k 1) : Bool :=
  (kvE_sepPos qnf).any fun σ' =>
    decide (nf0_zoneSpec σ'.1 = zs) && decide (kvE_projFreshD σ' = χ)

/-- **Depth-`k` zone-fact honesty** (the symbolic-`k` generalization of
    `kvE2_futAnyBit_correct`, ExteriorNegation.lean:148 — Cor 5.4 zone-fact channel, one
    fold-layer deeper): under realized `qnf`, the syntactic bit reads the actual depth-`k`
    zone fact of `[w,x,t]`, for EVERY `zs`. This is the depth-`k` `habove`/`hbelow` pin in
    the exact `NormalForm sig k 1` / `nf_eval_nf M k 1` shape the Phase-2 bracket lemmas
    consume; determinacy is `nf_eval_unique M k` (report 10's exact prescription). -/
theorem kvE_futAnyBit_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (w x t : M.carrier) {k : Nat}
    (qnf : NormalForm sig (k + 2) 3)
    (hq : nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (zs : ZoneSpec 3) (χ : NormalForm sig k 1) :
    (∃ v : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
        nf_eval_nf M k 1 (fun _ => v) χ) ↔
      kvE_futAnyBit qnf zs χ = true := by
  obtain ⟨-, hquant⟩ := hq
  constructor
  · rintro ⟨v, hzone, hprof⟩
    -- v realizes its depth-(k+1) characteristic over [w,x,t]; qnf's quant layer makes it
    -- positive; its channels read back zs (atom layer) and χ (shadow + uniqueness).
    set σv : NormalForm sig (k + 1) 4 :=
      nf_characteristic M (k + 1) 4 (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t))))
      with hσv
    have hsat := nf_characteristic_satisfies M (k + 1) 4
      (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t))))
    have hpos : qnf.2 σv = true := (hquant σv).mp ⟨v, hσv ▸ hsat⟩
    have hatom : ∀ a, atom_eval M
        (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔ σv.1 a = true :=
      (hσv ▸ hsat : nf_eval_nf M (k + 1) 4 _ σv).1
    refine List.any_eq_true.mpr ⟨σv, (kvE_sepPos_mem qnf σv).mpr hpos, ?_⟩
    rw [Bool.and_eq_true]
    refine ⟨decide_eq_true ?_, decide_eq_true ?_⟩
    · -- ordering channel: read the couplings straight from the atom layer.
      funext i
      have hz := hzone i
      have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
      have h2 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
      show (σv.1 (.order 0 i.succ (Fin.succ_ne_zero i).symm),
            σv.1 (.order i.succ 0 (Fin.succ_ne_zero i))) = zs i
      exact Prod.ext (Bool.eq_iff_iff.mpr (h1.symm.trans hz.1))
        (Bool.eq_iff_iff.mpr (h2.symm.trans hz.2))
    · -- point-type channel: σv's fresh depth-k shadow and χ are both realized at v;
      -- `nf_eval_unique M k` supplies determinacy.
      exact nf_eval_unique M k 1 (fun _ => v) _ χ
        (nf_eval_projFreshD M _ v σv (hσv ▸ hsat)) hprof
  · intro hbit
    obtain ⟨σ', hmem, hread⟩ := List.any_eq_true.mp hbit
    rw [Bool.and_eq_true] at hread
    obtain ⟨hzsb, hχb⟩ := hread
    have hzs : nf0_zoneSpec σ'.1 = zs := of_decide_eq_true hzsb
    have hχ : kvE_projFreshD σ' = χ := of_decide_eq_true hχb
    obtain ⟨u, hu⟩ := (hquant σ').mpr ((kvE_sepPos_mem qnf σ').mp hmem)
    have hatom : ∀ a, atom_eval M
        (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔ σ'.1 a = true := hu.1
    refine ⟨u, fun i => ?_, ?_⟩
    · -- zone read-back from the realizer's atom layer.
      have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
      have h2 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
      simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1 h2
      have hzi := congrFun hzs i
      have e1 : σ'.1 (.order 0 i.succ (Fin.succ_ne_zero i).symm) = (zs i).1 :=
        congrArg Prod.fst hzi
      have e2 : σ'.1 (.order i.succ 0 (Fin.succ_ne_zero i)) = (zs i).2 :=
        congrArg Prod.snd hzi
      exact ⟨h1.trans (by rw [e1]), h2.trans (by rw [e2])⟩
    · -- profile read-back: the realizer carries the fresh depth-k shadow.
      rw [← hχ]
      exact nf_eval_projFreshD M _ u σ' hu

end Bimodal.Metalogic.WeakCanonical.Kamp
