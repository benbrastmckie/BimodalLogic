import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK

/-! # Task-376 research probe: zone-decomposed re-signed char seams

Three probes:
- Probe B (`zoneGuard_blocks_seamPair_counterexample`, sorry-free): the zoneHolds guard
  BLOCKS the exact instantiation step (3) of `seamPair_joint_refutation` — the counterexample
  fiber σ* (characteristic of (w0,w0,x,t), zone AtW) admits NO zone witness at w0 relative to
  anchors [w', x, t] with w' ≠ w0.
- Probe A (`hcharFibZone_reSigned_gate_elaborates`, sorry-bodied): the re-signed seam pair
  {hcharFibZone, hcharFibZoneSound} elaborates in the exact `correct_prior` conclusion context.
- Probe C (`bracketEndChar_kvFibZone_realize_futT`, sorry-free): the render-free FUTURE
  endpoint extraction (the key existing consumer, IGGK:1565) re-threads through the
  zone-guarded soundness seam — proving the guard costs consumers nothing.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

set_option maxHeartbeats 1600000

/-- **Probe B**: the zoneHolds guard blocks the seam-pair counterexample. The refutation's
    step (3) instantiated `hcharFibSoundP` at `w := w'`, `τ := σ*`, `x1 := w0`; the zone-guarded
    seam additionally demands `zoneHolds M [w',x,t] (nf0_zoneSpec σ*.atom_assgn) w0`, which is
    FALSE whenever `w' ≠ w0` (σ*'s zone is AtW: both w-bits false, forcing `w0 = w'`). -/
theorem zoneGuard_blocks_seamPair_counterexample {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (x t w0 w' : M.carrier) (hne : w' ≠ w0) :
    ¬ zoneHolds M (Fin.cons w' (Fin.cons x (fun _ => t)))
        (nf0_zoneSpec (NormalForm.atom_assgn
          (nf_characteristic M (k + 1) 4
            (Fin.cons w0 (Fin.cons w0 (Fin.cons x (fun _ => t))))))) w0 := by
  intro hz
  have hσsat := nf_characteristic_satisfies M (k + 1) 4
    (Fin.cons w0 (Fin.cons w0 (Fin.cons x (fun _ => t))))
  have hatoms : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons w0 (Fin.cons w0 (Fin.cons x (fun _ => t)))) a ↔
        (nf_characteristic M (k + 1) 4
          (Fin.cons w0 (Fin.cons w0 (Fin.cons x (fun _ => t))))).atom_assgn a = true :=
    nf_eval_nf_atom_layer M _ _ hσsat
  obtain ⟨h1, h2⟩ := hz 0
  simp only [nf0_zoneSpec] at h1 h2
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · -- w' < w0: h2's bit is σ*'s (1<0) bit, whose atom_eval is w0 < w0.
    have h0 := (hatoms _).mpr (h2.mp hlt)
    simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h0
    exact lt_irrefl w0 h0
  · -- w0 < w': h1's bit is σ*'s (0<1) bit, whose atom_eval is w0 < w0.
    have h0 := (hatoms _).mpr (h1.mp hgt)
    simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h0
    exact lt_irrefl w0 h0

/-- **Probe A**: the re-signed zone-decomposed seam pair elaborates in the exact
    `bracketEndChar_kvExtFib_correct_prior` conclusion context (EGA:559-660). Binders shown are
    the SUBSTITUTION for `hcharFib` (EGA:574-578) + `hcharFibSoundP` (EGA:579-581); all other
    row obligations of `correct_prior` are unchanged and elided here (the probe conclusion does
    not depend on them for elaboration). Sorry-bodied BY DESIGN — this is a statement-shape
    artifact, not a claim that the gate theorem is already re-proved. -/
theorem hcharFibZone_reSigned_gate_elaborates {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    -- Seam 1 (replaces hcharFib): render-gated, marked-fiber-guarded, zone-guarded ↔.
    (hcharFibZone : ∀ (w : M.carrier),
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig (k + 1) 4), qnf.2 σ = true →
      ∀ (u : M.carrier),
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
          (nf0_zoneSpec (NormalForm.atom_assgn σ)) u →
        (temporal_truth M atomMap u (charFib (k + 1) σ) ↔
          nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ))
    -- Seam 2 (replaces hcharFibSoundP): render-FREE but anchor-order-, carrier-,
    -- marked-fiber-, and zone-guarded soundness.
    (hcharFibZoneSound : ∀ (w : M.carrier), x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1
        (igFoldBitFib qnf)).eval_at M atomMap w →
      (igEpLFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1
        (igFoldBitFib qnf)).eval_at M atomMap x →
      (igEpRFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1
        (igFoldBitFib qnf)).eval_at M atomMap t →
      ∀ (τ : NormalForm sig (k + 1) 4), qnf.2 τ = true →
      ∀ (x1 : M.carrier),
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
          (nf0_zoneSpec (NormalForm.atom_assgn τ)) x1 →
        temporal_truth M atomMap x1 (charFib (k + 1) τ) →
        nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) :
    (bracketEndChar_kvExtFib atomMap h_surj charFib Pbr qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  sorry

/-- **Probe C**: the render-free FUTURE endpoint extraction (`bracketEndChar_kvFib_realize_futT`,
    IGGK:1565) re-threads through the ZONE-GUARDED soundness seam at zero consumer cost: the
    zone witness `zoneHolds … igZFutT x1` is derivable from the native `untl` firing (`t < x1`)
    plus the bracket anchor order `x < w < t` — order content structural, per Rabinovich
    Cor 5.4(1) (chunk_0015 lines 23-29). The marked-fiber guard is supplied by the fold bit. -/
theorem bracketEndChar_kvFibZone_realize_futT {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcharFibZoneSound : ∀ (τ : NormalForm sig k 4), qnf.2 τ = true →
      ∀ (x1 : M.carrier),
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
          (nf0_zoneSpec (NormalForm.atom_assgn τ)) x1 →
        temporal_truth M atomMap x1 (charFib τ) →
        nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (σ : NormalForm sig k 4) (hz : igFoldBitFib qnf igZFutT σ = true)
    (hepR : (igEpRFib charBase charFib qnf.1 (igFoldBitFib qnf)).eval_at M atomMap t) :
    ∃ x1 : M.carrier, t < x1 ∧
      nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  -- Fire the untl endpoint literal exactly as in the landed realize_futT (IGGK:1577-1588).
  simp only [igEpRFib, TemporalPred.eval_at] at hepR
  rw [formula_conjList_iff] at hepR
  have hlit : temporal_truth M atomMap t (Formula.untl (charFib σ) Formula.top) := by
    apply hepR
    apply List.mem_append_right
    refine List.mem_map.mpr ⟨σ, by simp [igAllSubs], ?_⟩
    simp only [igLit, hz, if_true]
  simp only [temporal_truth] at hlit
  obtain ⟨x1, htx1, hgoal, -⟩ := hlit
  -- Decode the fold bit: σ is marked and its declared zone is igZFutT.
  have hdec : qnf.2 σ = true ∧ nf0_zoneSpec (NormalForm.atom_assgn σ) = igZFutT := by
    simpa only [igFoldBitFib, decide_eq_true_eq] using hz
  -- The zone witness: t < x1 with x < w < t realizes igZFutT structurally.
  have hzh : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
      (nf0_zoneSpec (NormalForm.atom_assgn σ)) x1 := by
    rw [hdec.2]
    have hwx1 : w < x1 := hwt.trans htx1
    have hxx1 : x < x1 := hxw.trans hwx1
    have henv : ∀ j : Fin 3,
        (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) j < x1 := by
      intro j
      refine Fin.cases ?_ (fun j' => ?_) j
      · simpa only [Fin.cons_zero] using hwx1
      · refine Fin.cases ?_ (fun j'' => ?_) j'
        · simpa only [Fin.cons_succ, Fin.cons_zero] using hxx1
        · simpa only [Fin.cons_succ] using htx1
    have hzs : ∀ j : Fin 3, igZFutT j = (false, true) := by
      intro j
      refine Fin.cases rfl (fun j' => ?_) j
      exact Fin.cases rfl (fun _ => rfl) j'
    intro i
    rw [hzs i]
    exact ⟨⟨fun h => (asymm (henv i) h).elim, fun h => absurd h (by decide)⟩,
           ⟨fun _ => rfl, fun _ => henv i⟩⟩
  exact ⟨x1, htx1, hcharFibZoneSound σ hdec.1 x1 hzh hgoal⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
