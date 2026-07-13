import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK

/-! # Obligation-carrying EndInterval consumer reshape (task 357)

The obligation-carrying reshape of the task-349 interval consumer. It replaces the unconditional
`EndIntervalCorrect` (`CarrierK1V.lean:2179`, on a dead branch — nothing external consumed it) with a
depth-cased, obligation-carrying `EndIntervalCorrectPrior`, and fills the recursion step (the
`⟨[]⟩` empty-disjunction placeholder `endIntervalStep`, `CarrierK1V.lean:2144`) with a depth-cased
body built from the two landed discharge lemmas of tasks 355/356.

**Why a new leaf module (Phase 1 cycle decision).** The reshaped step body uses `bracketEndChar_kv`
(`CarrierKv.lean`) and `bracketEndChar_kvExt` (`ExteriorGateAssembleK.lean`), both of which sit BELOW
`CarrierK1V` in the import order (they transitively import `CarrierK1V`, since `BracketEndCharCarrierV`
is defined at `CarrierK1V.lean:365`). Filling `endIntervalStep` in place would invert the
`CarrierK1V ↔ ExteriorGateAssembleK` import edge (a cycle). The pre-planned contingency (research
§9.1, plan Risk table) relocates the reshaped defs to this new leaf below `ExteriorGateAssembleK`.

**Depth-casing (step maps `k → k+1`).**
- depth 0 (base): `VVecEA2.singleton (bracketEndChar_k0 …)` — the k=0 two-endpoint bracket carrier.
- depth 1 (`k=0` step): interior-only rung `bracketEndChar_kv atomMap h_surj charF 1` — no exterior
  residue (base rung; depth 1 carries only the depth-0 char agreement `h0`).
- depth `m+2` (`k=m+1` step): the exterior-composed gate `bracketEndChar_kvExt atomMap h_surj charF
  (Pfam m)` (task 356), which discharges `hexclExt` internally.

**Obligation discipline (carry, do NOT discharge).** All 11 obligations of the `m+2` arm (7 interior:
`P, hcharK, h_UZ, h_SZ, hreal, hexcl` + the internalized `hexclExt`; 4 exterior task-356 `hbr*`) are
THREADED OUTWARD as hypotheses — exactly as tasks 355 (`InteriorGateAllK`) and 356
(`bracketEndChar_kvExt_correct_prior`) delivered. Actually discharging `hreal`/`hexcl`/`hbr*` requires
the un-landed realization recursion (`KampPrior:361/364` sorries) and is the fenced-out escalation
boundary (task 357 Phase 7 / a task-309 Phase-14 successor). No `sorry`, no vacuous def is introduced
here.

## References
- Rabinovich 2014, "A Proof of Kamp's Theorem", Cor 5.4 + Lemma 7.6.
- `specs/357_reshape_endinterval_consumer_obligation_carrying/plans/01_endinterval-consumer-reshape.md`
- `specs/357_reshape_endinterval_consumer_obligation_carrying/reports/01_endinterval-consumer-reshape-shape-and-path.md`
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-! ## Phase 2 — reshaped recursion carriers (`charF` + provider family threaded) -/

/-- **Reshaped depth-`k → k+1` step** (task 357 Phase 2; fills the `⟨[]⟩` placeholder
    `endIntervalStep`, `CarrierK1V.lean:2144`). Depth-cased on `{k}`: `k = 0` (→ depth 1) is the
    interior-only rung `bracketEndChar_kv atomMap h_surj charF 1`; `k = m+1` (→ depth `m+2`) is the
    exterior-composed gate `bracketEndChar_kvExt atomMap h_surj charF (Pfam m)` (task 356). The
    arity-3 IH `rec` is intentionally NOT threaded (task 355 Phase 7 finding: interior content is
    realized via the provider family, not the IH). The provider family `Pfam` supplies the depth-`m`
    bracket provider `Pbr := Pfam m` the exterior branch needs. -/
noncomputable def endIntervalStepPrior {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pfam : (j : Nat) → ExistProviders sig atomMap j) :
    BracketEndCharCarrierV sig (k + 1) :=
  match k with
  | 0 => bracketEndChar_kv atomMap h_surj charF 1
  | (m + 1) => bracketEndChar_kvExt atomMap h_surj charF (Pfam m)

/-- **Reshaped recursion carrier** (task 357 Phase 2). `Nat.rec` with base = the depth-0 singleton
    bracket carrier (unchanged) and step = the reshaped `endIntervalStepPrior`. Reduces by `rfl`:
    `endIntervalPrior … 0 = fun qnf => VVecEA2.singleton (bracketEndChar_k0 …)`,
    `endIntervalPrior … 1 = bracketEndChar_kv atomMap h_surj charF 1`, and
    `endIntervalPrior … (m+2) = bracketEndChar_kvExt atomMap h_surj charF (Pfam m)`. -/
noncomputable def endIntervalPrior {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pfam : (j : Nat) → ExistProviders sig atomMap j) :
    (k : Nat) → BracketEndCharCarrierV sig k :=
  fun k =>
    Nat.rec (motive := fun k => BracketEndCharCarrierV sig k)
      (fun qnf => VVecEA2.singleton (bracketEndChar_k0 atomMap h_surj qnf))
      (fun m _rec => endIntervalStepPrior (k := m) atomMap h_surj charF Pfam)
      k

/-! ## Phase 3 — the 3-arm depth-cased obligation-carrying motive -/

/-- **Obligation-carrying correctness motive** `EndIntervalCorrectPrior` (task 357 Phase 3). The
    depth-cased `Prop` mirroring `InteriorGateAllK` (`InteriorGateGeneralK.lean:1239`), three arms:
    - `0`: the clean, obligation-free depth-0 biconditional (`BracketCarrierCorrectVPrior` on the
      depth-0 carrier).
    - `1`: the interior-only depth-1 biconditional, carrying only the depth-0 char agreement `h0`
      (base rung; no exterior obligation).
    - `m+2`: the full bundle — the six atom-layer order bits on `qnf.1`, the provider bundle `P` +
      agreement `hcharK`, the UZ/SZ Prior hypotheses, the interior realization/exclusion obligations
      `hreal`/`hexcl`, and the four task-356 exterior bracket obligations `hbr*` (with `Pbr := Pfam m`
      supplied by the family). `hexclExt` is NOT an input binder — `bracketEndChar_kvExt_correct_prior`
      discharges it internally. Binder types copied verbatim from `ExteriorGateAssembleK.lean:106-167`
      at depth-index `k := m`. -/
def EndIntervalCorrectPrior {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pfam : (j : Nat) → ExistProviders sig atomMap j) :
    (k : Nat) → Prop
  | 0 => BracketCarrierCorrectVPrior atomMap (endIntervalPrior atomMap h_surj charF Pfam 0)
  | 1 => ∀ (_h0 : charF 0 = nf_depth0_char_formula atomMap h_surj),
           BracketCarrierCorrectVPrior atomMap (endIntervalPrior atomMap h_surj charF Pfam 1)
  | (m + 2) =>
      ∀ (qnf : NormalForm sig (m + 2) 3)
        (_h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
        (_h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
        (_h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
        (_h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
        (_h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
        (_h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
        (P : ExistProviders sig atomMap (m + 1))
        (_hcharK : charF (m + 1) = fun χ => P.existF 0 χ)
        (M : OrderedMonadicStructure sig)
        (_h_UZ : semantic_prior_UZ M atomMap) (_h_SZ : semantic_prior_SZ M atomMap)
        (x t : M.carrier)
        (_hreal : ∀ w : M.carrier, x < w → w < t →
          (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (m + 1)) qnf.1 (igFoldBit qnf)).eval_at
            M atomMap w →
          ∀ σ : NormalForm sig (m + 1) 4, qnf.2 σ = true →
            ∃ x1 : M.carrier,
              nf_eval_nf M (m + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
        (_hexcl : ∀ w : M.carrier, x < w → w < t →
          (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (m + 1)) qnf.1 (igFoldBit qnf)).eval_at
            M atomMap w →
          ∀ σ : NormalForm sig (m + 1) 4, qnf.2 σ = false →
            ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
              ¬ nf_eval_nf M (m + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
        (_hbrPastReal : ∀ w : M.carrier, x < w → w < t →
          ∀ σ : NormalForm sig (m + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
            ∀ x1 : M.carrier, x1 < x → ∀ s : NormalForm sig m 5, σ.2 s = true →
              ∃ v : M.carrier, nf_eval_nf M m 5
                (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
        (_hbrPastSat : ∀ w : M.carrier, x < w → w < t →
          ∀ σ : NormalForm sig (m + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
            ∀ x1 : M.carrier, x1 < x →
              temporal_truth M atomMap x1 (kvE_pastEnd (Pfam m) σ) →
              ∀ s : NormalForm sig m 5, nfk_dropFresh s = σ.1 →
                (∃ v : M.carrier, nf_eval_nf M m 5
                  (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
                σ.2 s = true)
        (_hbrFutReal : ∀ w : M.carrier, x < w → w < t →
          ∀ σ : NormalForm sig (m + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
            ∀ x1 : M.carrier, t < x1 → ∀ s : NormalForm sig m 5, σ.2 s = true →
              ∃ v : M.carrier, nf_eval_nf M m 5
                (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
        (_hbrFutSat : ∀ w : M.carrier, x < w → w < t →
          ∀ σ : NormalForm sig (m + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
            ∀ x1 : M.carrier, t < x1 →
              temporal_truth M atomMap x1 (kvE_futEnd (Pfam m) σ) →
              ∀ s : NormalForm sig m 5, nfk_dropFresh s = σ.1 →
                (∃ v : M.carrier, nf_eval_nf M m 5
                  (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
                σ.2 s = true),
      (endIntervalPrior atomMap h_surj charF Pfam (m + 2) qnf).holds M atomMap x t ↔
        ∃ w : M.carrier, nf_eval_nf M (m + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-! ## Phase 4 — the obligation-carrying consumer (task 349 Phase 5) -/

set_option maxHeartbeats 1600000 in
/-- **`endInterval_step_correct` — the obligation-carrying task-349 Phase-5 consumer** (task 357
    Phase 4). Assembles `EndIntervalCorrectPrior` for every `k` by cases:
    - `k = 0`: the depth-0 singleton base via `bracketEndChar_k0_correct` (reuse of the
      `endInterval_zero_correct` argument, `CarrierK1V.lean:2199`).
    - `k = 1`: the interior-only depth-1 rung `bracketEndChar_kv_correct_one_prior`
      (`PriorInterface.lean:95`), carrying only `h0`.
    - `k = m+2`: consumes the exterior-composed discharge `bracketEndChar_kvExt_correct_prior`
      (`ExteriorGateAssembleK.lean:106`), THREADING the 7 interior + 4 exterior obligations outward
      (not discharging them). `hexclExt` is discharged internally by the consumed lemma.
    Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem endInterval_step_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pfam : (j : Nat) → ExistProviders sig atomMap j) :
    ∀ k : Nat, EndIntervalCorrectPrior atomMap h_surj charF Pfam k
  | 0 => by
      show BracketCarrierCorrectVPrior atomMap (endIntervalPrior atomMap h_surj charF Pfam 0)
      intro qnf h_xy h_yt h_xt h_yx h_ty h_tx M _h_UZ _h_SZ x t
      show (VVecEA2.singleton (bracketEndChar_k0 atomMap h_surj qnf)).holds M atomMap x t ↔ _
      rw [VVecEA2.singleton_holds]
      exact bracketEndChar_k0_correct atomMap h_surj qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t
  | 1 => by
      intro h0
      show BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF 1)
      exact bracketEndChar_kv_correct_one_prior atomMap h_surj charF h0
  | (m + 2) => by
      intro qnf h_xy h_yt h_xt h_yx h_ty h_tx P hcharK M h_UZ h_SZ x t
        hreal hexcl hbrPastReal hbrPastSat hbrFutReal hbrFutSat
      show (bracketEndChar_kvExt atomMap h_surj charF (Pfam m) qnf).holds M atomMap x t ↔ _
      exact bracketEndChar_kvExt_correct_prior atomMap h_surj charF P hcharK (Pfam m) qnf
        h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t hreal hexcl
        hbrPastReal hbrPastSat hbrFutReal hbrFutSat

end Bimodal.Metalogic.WeakCanonical.Kamp
