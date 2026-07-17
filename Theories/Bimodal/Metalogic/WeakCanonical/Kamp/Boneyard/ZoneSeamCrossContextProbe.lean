import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK

/-! # Cross-anchor-context refutation-or-clearance probe (zone-decomposed char seams)

**VERDICT: CLEARED** — both attacks against the full guarded re-signed pair
{`hcharFibZone`, `hcharFibZoneSound`} are blocked by sorry-free theorems.

Machine-adjudicates the two known attacks against the zone-decomposed re-signed char seam
pair (the guarded substitutes for the jointly-refuted {`hcharFib`, `hcharFibSoundP`} — see
`SeamPairRefutationProbe.lean`):

- **Attack 1 (regression — the old counterexample replay)**: σ* := characteristic of
  `(w0,w0,x,t)`, step-(3) transport to `w := w' ≠ w0` at `x1 := w0`. BLOCKED sorry-free by
  `zoneGuard_blocks_seamPair_counterexample`: σ*'s zone is AtW (both w-bits false), so the
  `zoneHolds` guard demands `w0 = w'`, contradicting `w' ≠ w0`. The old refutation's
  instantiation point is unreachable.

- **Attack 2 (the cross-anchor-context attack)**: model `(ℤ, P = {1})`,
  τ* := characteristic of `(5, 1, 0, 10)` (which declares `P` at the w-slot), certified
  context `w = 1` vs uncertified context `w' = 3`, shared evaluation point `x1 = 5` lying in
  the SAME zone `(w, t)` relative to both anchor contexts. The attack pipeline is fully
  assembled here and is honest about its reach:
  * the marked-fiber guard does NOT block it — `cpQnf_marks_cpTau` proves
    `qnf.2 τ* = true` (τ* is realized at 5 over qnf's own anchors);
  * the zone guard does NOT block it — `cpTau_zoneHolds_A`/`_B` prove the shared-zone
    witness in BOTH contexts;
  * `crossContext_attack_payload` proves that, given the three context-B carrier gates, the
    guarded pair yields `False` (τ*'s w-slot pred bit forces `P(3)` against `P = {1}`);
  * **the attack dies exactly at the carrier gate**: `crossContext_wGate_blocks_attack`
    proves the context-B witness gate `igPtWFib … 3` is UNSATISFIABLE — for EVERY `charFib`
    family, every `atomMap`, and every `qnf` rendered at the certified context — because its
    `charFib`-independent HEAD literal `charBase (nf_y_proj qnf.1)` demands qnf's w-slot
    1-type (which declares `P`, forced by `P(1)` at the render) at the point `3 ∉ P`.

  The blocking theorem is qnf-universal over rendered qnf, so the attack cannot be repaired
  by a smarter render choice within the instance: any qnf usable by the attack (i.e. rendered
  at the certified context, as Block A's firing requires) fails the context-B gate. Combined
  with the payload theorem, this is a positive, compiled demonstration that the carrier-eval
  gating (report §Q2.3 (ii)) is load-bearing and blocks the cross-context transport.

Purely additive leaf probe (style precedent: `SeamPairRefutationProbe.lean`); no production
file is touched. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

set_option maxHeartbeats 1600000

/-! ## Attack 1 — regression replay of the old seam-pair counterexample -/

/-- **Attack 1 is BLOCKED**: the zoneHolds guard blocks the seam-pair counterexample. The old
    refutation's step (3) instantiated `hcharFibSoundP` at `w := w'`, `τ := σ*`, `x1 := w0`;
    the zone-guarded seam additionally demands
    `zoneHolds M [w',x,t] (nf0_zoneSpec σ*.atom_assgn) w0`, which is FALSE whenever `w' ≠ w0`
    (σ*'s zone is AtW: both w-bits false, forcing `w0 = w'`). -/
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

/-! ## Attack 2 — the cross-anchor-context attack (report §Q2.3)

Concrete instance: `(ℤ, P = {1})`, anchors `x = 0`, `t = 10`; certified context `w = 1`,
uncertified context `w' = 3`; τ* := characteristic of `(5, 1, 0, 10)`; shared `x1 = 5`. -/

/-- One-predicate signature for the cross-context probe. -/
private abbrev cpSig : MonadicSignature := { preds := Unit }

/-- The probe model `(ℤ, P = {1})` — predicate content is now LOAD-BEARING (unlike the
    order-only old counterexample): `P` distinguishes the two anchor contexts. -/
private abbrev cpM : OrderedMonadicStructure cpSig where
  carrier := ℤ
  interp := fun _ n => n = 1
  carrier_order := inferInstance

/-- Certified anchor context `[w, x, t] = [1, 0, 10]`. -/
private def cpEnvA : Fin 3 → cpM.carrier := Fin.cons 1 (Fin.cons 0 (fun _ => 10))

/-- Uncertified anchor context `[w', x, t] = [3, 0, 10]` (same `x`, `t`; only the w-slot
    moves). -/
private def cpEnvB : Fin 3 → cpM.carrier := Fin.cons 3 (Fin.cons 0 (fun _ => 10))

/-- The 4-environment `[x1, w, x, t] = [5, 1, 0, 10]` anchoring τ*. -/
private def cpEnv4 : Fin 4 → cpM.carrier := Fin.cons 5 cpEnvA

/-- `qnf*` := the depth-`(k+2)` characteristic 3-type of the certified context. -/
private noncomputable def cpQnf (k : Nat) : NormalForm cpSig (k + 2) 3 :=
  nf_characteristic cpM (k + 2) 3 cpEnvA

/-- `τ*` := the depth-`(k+1)` characteristic 4-type of `(5, 1, 0, 10)`: it declares `P` at
    the w-slot (position 1), the content the attack tries to transport to `w' = 3 ∉ P`. -/
private noncomputable def cpTau (k : Nat) : NormalForm cpSig (k + 1) 4 :=
  nf_characteristic cpM (k + 1) 4 cpEnv4

/-- **Reach lemma (i): the marked-fiber guard does NOT block the attack.**
    `qnf*.2 τ* = true`: τ* is realized (at `x1 = 5`) over qnf*'s own anchors, so it lies in
    the marked fiber. Attack surface (i) of the plan is therefore passable — the gate
    question moves to the carrier-eval gates (surface (ii)). -/
private theorem cpQnf_marks_cpTau (k : Nat) : (cpQnf k).2 (cpTau k) = true :=
  @decide_eq_true _ (Classical.dec _)
    ⟨5, nf_characteristic_satisfies cpM (k + 1) 4 cpEnv4⟩

/-- τ*'s declared zone bits, read off against its own anchors: bit `i` is
    `(5 < cpEnvA i, cpEnvA i < 5)` — i.e. `x1` strictly inside `(w, t)` and above `x`. -/
private theorem cpTau_zone_bits (k : Nat) (i : Fin 3) :
    ((nf0_zoneSpec (NormalForm.atom_assgn (cpTau k)) i).1 = true ↔ (5 : ℤ) < cpEnvA i) ∧
    ((nf0_zoneSpec (NormalForm.atom_assgn (cpTau k)) i).2 = true ↔ cpEnvA i < (5 : ℤ)) := by
  have hatoms : ∀ a : AtomKind cpSig 4,
      atom_eval cpM cpEnv4 a ↔ (cpTau k).atom_assgn a = true :=
    nf_eval_nf_atom_layer cpM _ _ (nf_characteristic_satisfies cpM (k + 1) 4 cpEnv4)
  have h1 := hatoms (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  have h2 := hatoms (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [atom_eval, cpEnv4, Fin.cons_zero, Fin.cons_succ] at h1 h2
  simp only [nf0_zoneSpec]
  exact ⟨h1.symm, h2.symm⟩

/-- **Reach lemma (ii-A): the zone guard does NOT block the attack in the certified
    context** — `x1 = 5` realizes τ*'s zone relative to `[1, 0, 10]`. -/
private theorem cpTau_zoneHolds_A (k : Nat) :
    zoneHolds cpM cpEnvA (nf0_zoneSpec (NormalForm.atom_assgn (cpTau k))) 5 := by
  intro i
  obtain ⟨h1, h2⟩ := cpTau_zone_bits k i
  exact ⟨h1.symm, h2.symm⟩

/-- **Reach lemma (ii-B): the zone guard does NOT block the attack in the uncertified
    context either** — `x1 = 5` realizes the SAME zone relative to `[3, 0, 10]` (the `x`/`t`
    coordinates are shared, and 5 sits on the same side of both 1 and 3). The cross-context
    attack therefore reaches the carrier gates. -/
private theorem cpTau_zoneHolds_B (k : Nat) :
    zoneHolds cpM cpEnvB (nf0_zoneSpec (NormalForm.atom_assgn (cpTau k))) 5 := by
  intro i
  refine Fin.cases ?_ (fun j => ?_) i
  · -- w-coordinate: 5 < 3 ↔ 5 < 1 (both false); 3 < 5 ↔ 1 < 5 (both true).
    obtain ⟨h1, h2⟩ := cpTau_zone_bits k 0
    simp only [cpEnvA, cpEnvB, Fin.cons_zero] at h1 h2 ⊢
    constructor
    · exact ⟨fun h => absurd h (show ¬ ((5 : ℤ) < 3) by decide),
             fun hb => absurd (h1.mp hb) (show ¬ ((5 : ℤ) < 1) by decide)⟩
    · exact ⟨fun _ => h2.mpr (show (1 : ℤ) < 5 by decide),
             fun _ => show (3 : ℤ) < 5 by decide⟩
  · -- x/t-coordinates: cpEnvB and cpEnvA agree on the tail.
    obtain ⟨h1, h2⟩ := cpTau_zone_bits k j.succ
    have he : cpEnvB j.succ = cpEnvA j.succ := by
      simp only [cpEnvA, cpEnvB, Fin.cons_succ]
    rw [he]
    exact ⟨h1.symm, h2.symm⟩

/-- **THE BLOCKING THEOREM (Attack 2 is BLOCKED at the carrier gate).** The context-B
    witness gate `igPtWFib … w' = 3` is unsatisfiable — for EVERY `charFib`, every
    `atomMap`/`h_surj`, and every `qnf` rendered at the certified context `[1, 0, 10]`. The
    gate's `charFib`-INDEPENDENT head literal `charBase (nf_y_proj qnf.1)` asserts qnf's
    w-slot 1-type at the evaluation point; rendering at `[1, 0, 10]` forces that 1-type to
    declare `P` (since `P(1)`), and `P(3)` is false in `(ℤ, P = {1})`.

    qnf-universality means the attack cannot be repaired by a different render: Block A's
    firing requires qnf rendered at the certified context, and every such qnf fails this
    gate at `3`. -/
theorem crossContext_wGate_blocks_attack {k : Nat}
    (atomMap : Formula → cpSig.preds)
    (h_surj : ∀ p : cpSig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : NormalForm cpSig (k + 1) 4 → Formula)
    (qnf : NormalForm cpSig (k + 2) 3)
    (hrender : nf_eval_nf cpM (k + 2) 3 cpEnvA qnf) :
    ¬ (igPtWFib (nf_depth0_char_formula atomMap h_surj) charFib qnf.1
        (igFoldBitFib qnf)).eval_at cpM atomMap 3 := by
  intro hgate
  have hatoms : ∀ a : AtomKind cpSig 3,
      atom_eval cpM cpEnvA a ↔ qnf.atom_assgn a = true :=
    nf_eval_nf_atom_layer cpM _ _ hrender
  -- Rendering forces qnf's w-slot to declare P (P(1) holds at cpEnvA 0 = 1).
  have hbit : qnf.atom_assgn (.pred () ⟨0, by omega⟩) = true := by
    apply (hatoms _).mp
    show cpM.interp () (cpEnvA ⟨0, by omega⟩)
    simp [cpEnvA]
  -- The gate's head literal: charBase (nf_y_proj qnf.1) at 3 — charFib-independent.
  simp only [igPtWFib, TemporalPred.eval_at] at hgate
  rw [formula_conjList_iff] at hgate
  have hhead := hgate _ List.mem_cons_self
  rw [nf_depth0_char_formula_correct] at hhead
  have h31 : cpM.interp () (3 : ℤ) := (hhead ()).mpr hbit
  exact absurd h31 (show ¬ ((3 : ℤ) = 1) by norm_num)

/-- **The attack payload, fully assembled** (honesty artifact): GIVEN the three context-B
    carrier gates, the guarded pair {`hcharFibZone`, `hcharFibZoneSound`} (binders
    byte-mirrored from the re-signed seam, `01_zone-seam-probe.lean` Probe A, specialized to
    the instance) yields `False`: Block A fires at the certified context `w = 1` (render +
    marked fiber + zone all discharged by the reach lemmas), Block B transports `charFib τ*`
    truth at `x1 = 5` to the context `w' = 3`, and τ*'s w-slot pred bit then forces `P(3)`
    against `P = {1}`.

    Together with `crossContext_wGate_blocks_attack` — which proves the `hgateW` premise
    below is unsatisfiable — this locates the attack's death point EXACTLY at the carrier
    gate: every other premise of the cross-context transport is derivable in the instance. -/
theorem crossContext_attack_payload (k : Nat)
    (atomMap : Formula → cpSig.preds)
    (h_surj : ∀ p : cpSig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm cpSig j 4 → Formula)
    (hcharFibZone : ∀ (w : cpM.carrier),
      nf_eval_nf cpM (k + 2) 3 (Fin.cons w (Fin.cons 0 (fun _ => 10))) (cpQnf k) →
      ∀ (σ : NormalForm cpSig (k + 1) 4), (cpQnf k).2 σ = true →
      ∀ (u : cpM.carrier),
        zoneHolds cpM (Fin.cons w (Fin.cons 0 (fun _ => 10)))
          (nf0_zoneSpec (NormalForm.atom_assgn σ)) u →
        (temporal_truth cpM atomMap u (charFib (k + 1) σ) ↔
          nf_eval_nf cpM (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons 0 (fun _ => 10)))) σ))
    (hcharFibZoneSound : ∀ (w : cpM.carrier), (0 : cpM.carrier) < w → w < 10 →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) (cpQnf k).1
        (igFoldBitFib (cpQnf k))).eval_at cpM atomMap w →
      (igEpLFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) (cpQnf k).1
        (igFoldBitFib (cpQnf k))).eval_at cpM atomMap 0 →
      (igEpRFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) (cpQnf k).1
        (igFoldBitFib (cpQnf k))).eval_at cpM atomMap 10 →
      ∀ (τ : NormalForm cpSig (k + 1) 4), (cpQnf k).2 τ = true →
      ∀ (x1 : cpM.carrier),
        zoneHolds cpM (Fin.cons w (Fin.cons 0 (fun _ => 10)))
          (nf0_zoneSpec (NormalForm.atom_assgn τ)) x1 →
        temporal_truth cpM atomMap x1 (charFib (k + 1) τ) →
        nf_eval_nf cpM (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons 0 (fun _ => 10)))) τ)
    (hgateW : (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) (cpQnf k).1
        (igFoldBitFib (cpQnf k))).eval_at cpM atomMap 3)
    (hgateL : (igEpLFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) (cpQnf k).1
        (igFoldBitFib (cpQnf k))).eval_at cpM atomMap 0)
    (hgateR : (igEpRFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) (cpQnf k).1
        (igFoldBitFib (cpQnf k))).eval_at cpM atomMap 10) :
    False := by
  -- (1) Block A at the certified context w = 1, σ := τ*, u := 5, .mpr direction.
  have htruth : temporal_truth cpM atomMap 5 (charFib (k + 1) (cpTau k)) :=
    (hcharFibZone 1 (nf_characteristic_satisfies cpM (k + 2) 3 cpEnvA)
      (cpTau k) (cpQnf_marks_cpTau k) 5 (cpTau_zoneHolds_A k)).mpr
      (nf_characteristic_satisfies cpM (k + 1) 4 cpEnv4)
  -- (2) Block B transported to the uncertified context w' = 3 (gates supplied as premises).
  have heval := hcharFibZoneSound 3 (show (0 : ℤ) < 3 by decide)
    (show (3 : ℤ) < 10 by decide) hgateW hgateL hgateR
    (cpTau k) (cpQnf_marks_cpTau k) 5 (cpTau_zoneHolds_B k) htruth
  -- (3) τ*'s w-slot pred bit clashes: it declares P (from P(1)), but the transported
  --     evaluation forces P(3), false in (ℤ, P = {1}).
  have hatomsB : ∀ a : AtomKind cpSig 4,
      atom_eval cpM (Fin.cons 5 (Fin.cons 3 (Fin.cons 0 (fun _ => 10)))) a ↔
        (cpTau k).atom_assgn a = true :=
    nf_eval_nf_atom_layer cpM _ _ heval
  have hatoms4 : ∀ a : AtomKind cpSig 4,
      atom_eval cpM cpEnv4 a ↔ (cpTau k).atom_assgn a = true :=
    nf_eval_nf_atom_layer cpM _ _ (nf_characteristic_satisfies cpM (k + 1) 4 cpEnv4)
  have hbit : (cpTau k).atom_assgn (.pred () (1 : Fin 4)) = true := by
    apply (hatoms4 _).mp
    show cpM.interp () (cpEnv4 (1 : Fin 4))
    simp [cpEnv4, cpEnvA, Fin.cons_one]
  have h31 := (hatomsB (.pred () (1 : Fin 4))).mpr hbit
  simp only [atom_eval, Fin.cons_one, Fin.cons_zero] at h31
  exact absurd h31 (show ¬ ((3 : ℤ) = 1) by norm_num)

end Bimodal.Metalogic.WeakCanonical.Kamp
