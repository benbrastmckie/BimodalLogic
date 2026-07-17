/-
ARCHIVED — off-faithful-path (Kamp Boneyard). MOVE-not-delete; do NOT delete or empty.

Retired from the live build ahead of the k>=2 E[Sigma] re-architecture. NOT on the
proof-term path from `completeness_discrete` (0 live importers; outside the Bimodal.lean
import closure, so uncompiled). Machine-checked seam-pair refutation certificate.
Do NOT consume or reuse for the faithful re-architecture: it targets the off-paper arity-4
object, which diverges from Rabinovich Def 4.1 (PDF p.5, atoms kept unary by expanding the
signature). Retained as machine-checked evidence only.

Key declarations: seamPair_joint_refutation, seamPair_joint_refutation_int
-/
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK

/-! # Gap B seam-pair refutation probe

Machine-adjudicates the joint refutability of the two abstract char seams that the entire
de-folded `*Fib` certificate stack threads:

- `hcharFib` — the render-gated ↔ over `(σ, u)`: binder mirrored **byte-faithfully** from
  `bracketEndChar_kvExtFib_correct_prior`, `ExteriorGateAssembleK.lean:574-578` (cross-check:
  `kampPrior_site_rungKFib_gate_match`, `KampPrior.lean:1073-1077`);
- `hcharFibSoundP` — the `w`-universal, unguarded, qnf-independent → : binder mirrored
  byte-faithfully from `ExteriorGateAssembleK.lean:579-581` (cross-checks:
  `KampPrior.lean:1080-1082`; `bracketEndChar_kvFib_step_sound`,
  `InteriorGateGeneralK.lean:2115-2117`).

## The refutation (3 steps)

For ANY `charFib` family, ANY model `M`, anchors `x, t`, and ANY two distinct points
`w' ≠ w0` such that some in-scope render `qnf` is realized at `w0`:

1. Let `σ*` be the depth-`(k+1)` characteristic fiber of `(w0, w0, x, t)` — realized at its own
   tuple by `nf_characteristic_satisfies`; its order atoms `(0<1)` and `(1<0)` are both `false`
   (positions 0 and 1 coincide at `w0`).
2. `hcharFib` instantiated at `w := w0` (render realized) and `(σ*, u := w0)`, `.mpr` direction:
   `temporal_truth M atomMap w0 (charFib (k+1) σ*)`.
3. `hcharFibSoundP` instantiated at `w := w'`, `x1 := w0`: `σ*` re-evaluates over
   `[w0, w', x, t]`, whose atom layer forces `¬(w0 < w')` and `¬(w' < w0)` — contradicting
   linearity with `w' ≠ w0`.

The concrete `(ℤ, <)` instance below (`seamPair_joint_refutation_int`) supplies the model with
`x = 0 < w0 = 1 < t = 2`, `qnf* :=` the depth-`(k+2)` characteristic 3-type of `(w0, x, t)`
(realized by `nf_characteristic_satisfies` and satisfying the six bracket order-atom
hypotheses of the gate certificate — `spQnf_order_atoms`), establishing that the refuted
hypothesis pack is exactly the (inhabited, non-vacuous) `:519`-site instance.

Purely additive leaf probe (style precedent: `RefutationF2.lean`,
`ExteriorPinnedProbe358K.lean`); no production file is touched. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- **The Gap B joint seam refutation.** The hypothesis pair {`hcharFib`, `hcharFibSoundP`}
    (binders byte-faithful to `ExteriorGateAssembleK.lean:574-581`) is jointly false at any
    model with two distinct points `w' ≠ w0` and a render realized at `w0`. -/
theorem seamPair_joint_refutation {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (M : OrderedMonadicStructure sig)
    (x t w0 w' : M.carrier) (hne : w' ≠ w0)
    (qnf : NormalForm sig (k + 2) 3)
    (hrender : nf_eval_nf M (k + 2) 3 (Fin.cons w0 (Fin.cons x (fun _ => t))) qnf)
    (hcharFib : ∀ (w : M.carrier),
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        temporal_truth M atomMap u (charFib (k + 1) σ) ↔
          nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcharFibSoundP : ∀ (w : M.carrier) (τ : NormalForm sig (k + 1) 4) (x1 : M.carrier),
      temporal_truth M atomMap x1 (charFib (k + 1) τ) →
      nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) :
    False := by
  -- (1) σ* := the characteristic fiber of (w0, w0, x, t), realized at its own tuple.
  have hσsat := nf_characteristic_satisfies M (k + 1) 4
    (Fin.cons w0 (Fin.cons w0 (Fin.cons x (fun _ => t))))
  -- (2) render-gated ↔ at w := w0, u := w0, `.mpr`: charFib (k+1) σ* is true at w0.
  have htruth := (hcharFib w0 hrender
    (nf_characteristic M (k + 1) 4 (Fin.cons w0 (Fin.cons w0 (Fin.cons x (fun _ => t)))))
    w0).mpr hσsat
  -- (3) w-universal unguarded soundness at w': σ* re-evaluates over [w0, w', x, t].
  have heval' := hcharFibSoundP w'
    (nf_characteristic M (k + 1) 4 (Fin.cons w0 (Fin.cons w0 (Fin.cons x (fun _ => t)))))
    w0 htruth
  -- Atom layers of the two evaluations of the SAME σ* over the two environments.
  have hatoms0 : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons w0 (Fin.cons w0 (Fin.cons x (fun _ => t)))) a ↔
        (nf_characteristic M (k + 1) 4
          (Fin.cons w0 (Fin.cons w0 (Fin.cons x (fun _ => t))))).atom_assgn a = true :=
    nf_eval_nf_atom_layer M _ _ hσsat
  have hatoms' : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons w0 (Fin.cons w' (Fin.cons x (fun _ => t)))) a ↔
        (nf_characteristic M (k + 1) 4
          (Fin.cons w0 (Fin.cons w0 (Fin.cons x (fun _ => t))))).atom_assgn a = true :=
    nf_eval_nf_atom_layer M _ _ heval'
  -- Linearity: w' ≠ w0 forces one of the two order atoms σ* declares false.
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · -- w' < w0: atom (1<0) holds over [w0, w', x, t], but σ*'s (1<0) bit is w0 < w0.
    have hae : atom_eval M (Fin.cons w0 (Fin.cons w' (Fin.cons x (fun _ => t))))
        (.order (1 : Fin 4) (0 : Fin 4) (by decide)) := by
      simpa [atom_eval, Fin.cons_zero, Fin.cons_one] using hlt
    have h0 := (hatoms0 _).mpr ((hatoms' _).mp hae)
    simp only [atom_eval, Fin.cons_zero, Fin.cons_one] at h0
    exact lt_irrefl w0 h0
  · -- w0 < w': atom (0<1) holds over [w0, w', x, t], but σ*'s (0<1) bit is w0 < w0.
    have hae : atom_eval M (Fin.cons w0 (Fin.cons w' (Fin.cons x (fun _ => t))))
        (.order (0 : Fin 4) (1 : Fin 4) (by decide)) := by
      simpa [atom_eval, Fin.cons_zero, Fin.cons_one] using hgt
    have h0 := (hatoms0 _).mpr ((hatoms' _).mp hae)
    simp only [atom_eval, Fin.cons_zero, Fin.cons_one] at h0
    exact lt_irrefl w0 h0

/-! ## Concrete non-vacuity instance: `(ℤ, <)`, `x = 0 < w0 = 1 < t = 2`, `w' = 3` -/

/-- One-predicate signature for the probe. -/
private abbrev spSig : MonadicSignature := { preds := Unit }

/-- The probe model `(ℤ, <)` (predicate content is irrelevant to the refutation). -/
private abbrev spM : OrderedMonadicStructure spSig where
  carrier := ℤ
  interp := fun _ _ => True
  carrier_order := inferInstance

/-- Ambient anchors `[w0, x, t] = [1, 0, 2]` (so `x < w0 < t`). -/
private def spEnv3 : Fin 3 → spM.carrier := Fin.cons 1 (Fin.cons 0 (fun _ => 2))

/-- `qnf*` := the depth-`(k+2)` characteristic 3-type of `(w0, x, t) = (1, 0, 2)`. -/
private noncomputable def spQnf (k : Nat) : NormalForm spSig (k + 2) 3 :=
  nf_characteristic spM (k + 2) 3 spEnv3

/-- `qnf*` is realized at the witness `w0 = 1`. -/
private theorem spQnf_render (k : Nat) :
    nf_eval_nf spM (k + 2) 3 spEnv3 (spQnf k) :=
  nf_characteristic_satisfies spM (k + 2) 3 spEnv3

/-- `qnf*` satisfies the six bracket order-atom hypotheses of the gate certificate
    (`ExteriorGateAssembleK.lean:565-570`, `KampPrior.lean:1064-1069`), since `0 < 1 < 2`. -/
private theorem spQnf_order_atoms (k : Nat) :
    (spQnf k).1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    (spQnf k).1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
    (spQnf k).1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
    (spQnf k).1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    (spQnf k).1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
    (spQnf k).1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false :=
  ⟨@decide_eq_true _ (Classical.dec _) (show (0 : ℤ) < 1 by norm_num),
   @decide_eq_true _ (Classical.dec _) (show (1 : ℤ) < 2 by norm_num),
   @decide_eq_true _ (Classical.dec _) (show (0 : ℤ) < 2 by norm_num),
   @decide_eq_false _ (Classical.dec _) (show ¬((1 : ℤ) < 0) by norm_num),
   @decide_eq_false _ (Classical.dec _) (show ¬((2 : ℤ) < 1) by norm_num),
   @decide_eq_false _ (Classical.dec _) (show ¬((2 : ℤ) < 0) by norm_num)⟩

/-- **Non-vacuity witness**: at the concrete `(ℤ, <)` instance — whose `qnf*` is realized at
    `w0` and satisfies the six gate order-atom hypotheses — the seam pair alone yields `False`,
    for EVERY `charFib` family and every `atomMap`. The `:519` gate route's hypothesis pack is
    refuted exactly where the ⇐ direction needs it. -/
theorem seamPair_joint_refutation_int (k : Nat)
    (atomMap : Formula → spSig.preds)
    (charFib : (j : Nat) → NormalForm spSig j 4 → Formula)
    (hcharFib : ∀ (w : spM.carrier),
      nf_eval_nf spM (k + 2) 3 (Fin.cons w (Fin.cons 0 (fun _ => 2))) (spQnf k) →
      ∀ (σ : NormalForm spSig (k + 1) 4) (u : spM.carrier),
        temporal_truth spM atomMap u (charFib (k + 1) σ) ↔
          nf_eval_nf spM (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons 0 (fun _ => 2)))) σ)
    (hcharFibSoundP : ∀ (w : spM.carrier) (τ : NormalForm spSig (k + 1) 4) (x1 : spM.carrier),
      temporal_truth spM atomMap x1 (charFib (k + 1) τ) →
      nf_eval_nf spM (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons 0 (fun _ => 2)))) τ) :
    False :=
  seamPair_joint_refutation atomMap charFib spM 0 2 1 3 (by norm_num) (spQnf k)
    (spQnf_render k) hcharFib hcharFibSoundP

end Bimodal.Metalogic.WeakCanonical.Kamp
