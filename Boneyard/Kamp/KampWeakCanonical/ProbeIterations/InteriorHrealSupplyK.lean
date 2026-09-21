/-
ARCHIVED — off-faithful-path (Kamp Boneyard). MOVE-not-delete; do NOT delete or empty.

Retired from the live build ahead of the k>=2 E[Sigma] re-architecture. NOT on the
proof-term path from `completeness_discrete` (0 live importers; outside the Bimodal.lean
import closure, so uncompiled). Off-path arity-4 interior hreal supply (the abandoned engine).
Do NOT consume or reuse for the faithful re-architecture: it targets the off-paper arity-4
object, which diverges from Rabinovich Def 4.1 (PDF p.5, atoms kept unary by expanding the
signature). Retained as machine-checked evidence only.

Key declarations: kampPrior_hreal_supply
-/
import FormalSystem.Metalogic.WeakCanonical.Kamp.KampPrior

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Crux A — the interior `hreal` supply

This leaf hosts `kampPrior_hreal_supply`, the general-`m` discharge of the ROW-5 `hreal`
obligation carried by `kampPrior_site_rungK_gate_match` (`KampPrior.lean:964-970`) and its
`EndIntervalConsumerK` mirror. It is the deep `⇐` direction of the deep ambient render and the
ROOT of the crux-first DAG (v09 plan Phase 5).

## Directional discipline (why the render is NOT a hypothesis here)

`hreal` is UPSTREAM of the render: `ExteriorGateAssembleK.lean:337-338` produces
`∃ w, nf_eval_nf M (k+2) 3 [w,x,t] qnf` via `bracketEndChar_kv_step_sound … (hreal hGuard)
(hexcl hGuard)`. So `hreal` must be produced by the model engine BEFORE the render exists —
it may NOT take `nf_eval_nf M (k+2) 3 [w,x,t] qnf` as a premise (that would be circular). This
distinguishes Crux A from the LANDED slice supplies `kvE_hsliceFut_supply` /
`kvE_hslicePast_supply` (`ExteriorDeepSliceSupplyK.lean:131/161`), which are DOWNSTREAM of the
render and take it as an explicit hypothesis.

## Signature shape (row-5 binder, verbatim conclusion)

The conclusion chain matches the row-5 binder byte-for-byte (leading
`kvE_ambientDeepAnchor qnf = true →`, per-`w` `igPtW`-gated, per-`σ` marked + fiber-consistent).
The ambient premises `P`/`h_UZ`/`h_SZ`/`charF` are the engine seam the drivers
(`kampPrior_{fut,past}Realizer_of_pos`, `KampPrior.lean:1662/1721`) consume; `P` bundles the
depth-`k` realization recursion IH via `kampPrior_existProviders_of_ih`. Rows 5-6 signatures are
NOT changed (they are the PRODUCERS); the consumer-side seam that supplies `P`/`h_UZ`/`h_SZ` at
the row-5 site is the Phase-7 binder retrofit, out of scope here.
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula formula_conjList_iff)

set_option maxHeartbeats 1600000 in
/-- **Crux A — interior `hreal` supply** (Phase 5, the deep `⇐` witness selection).
    Discharges the row-5 `hreal` binder of `kampPrior_site_rungK_gate_match`: under the ambient
    deep-anchor guard, for every `igPtW`-selected interior `w` and every `qnf`-marked
    fiber-consistent `σ`, a within-model realizer `x1` with
    `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` exists.

    **Route (Phase 6′+7′ — DISCHARGED, de-folded / render-free).** The de-folded gate
    exposes the FULL arity-4 fiber content at the bracket endpoints (`igEpRFib`@t / `igEpLFib`@x)
    and the witness (`igPtWFib`@w), plus the two interior bracket seams (`igZXW`/`igZWT`), and the
    render-FREE char-soundness seam `hcharFibSound` (arity-4 analog of `interiorGate_hck`; threaded
    by design like the folded `P`/`hcharK`). A marked `σ` is zone-classified (`hzcons`, from the
    carrier gate's off-zone exclusion) into one of the seven bracket-consistent zones; the arity-4
    realizer is then read off the matching content: exterior `igZFutT`/`igZPastX` via the Phase-3
    render-free extractions `bracketEndChar_kvFib_realize_{futT,pastX}`, boundary
    `igZAtX`/`igZAtW`/`igZAtT` via the char literal at `x`/`w`/`t` + `hcharFibSound`, and the two
    interior zones `igZXW`/`igZWT` via the bracket realizer seams `hIntL`/`hIntR`. NO render is
    consumed anywhere — the M1 circularity (`igFoldBit_realize_iff` needs the render,
    InteriorGateGeneralK.lean:563) is broken by the de-folding: every ingredient originates in the
    carrier being true, upstream of the render produced at `ExteriorGateAssembleK.lean:337-338`.
    The endpoint/interior/zone-consistency seams are supplied at the consumer
    `bracketEndChar_kvFib_step_sound` from the carrier's `.holds` (endpoints, `S_L`/`S_R` bracket,
    gate); `hcharFibSound` is the one carried by-design seam. -/
theorem kampPrior_hreal_supply {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3)
    (x t : M.carrier) :
    kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1
        (igFoldBitFib qnf)).eval_at M atomMap w →
      (igEpLFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1
        (igFoldBitFib qnf)).eval_at M atomMap x →
      (igEpRFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1
        (igFoldBitFib qnf)).eval_at M atomMap t →
      -- ZONE-GUARDED render-free char-soundness seam: the marked-fiber
      -- and `zoneHolds` guards block the cross-anchor-context transport refuted for the old
      -- unguarded seam. Consumed by the re-signed `realize_{futT,pastX}` and at the boundary zones.
      (∀ (τ : NormalForm sig (k + 1) 4), qnf.2 τ = true →
        ∀ (x1 : M.carrier),
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
            (nf0_zoneSpec (NormalForm.atom_assgn τ)) x1 →
          temporal_truth M atomMap x1 (charFib (k + 1) τ) →
          nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) →
      -- Interior (`x < x1 < w`) bracket realizer seam for the left-interior zone `igZXW`:
      -- supplied in `bracketEndChar_kvFib_step_sound` from the carrier's `S_L` bracket clause.
      (∀ σ : NormalForm sig (k + 1) 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      -- Interior (`w < x1 < t`) bracket realizer seam for the right-interior zone `igZWT`.
      (∀ σ : NormalForm sig (k + 1) 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      -- Zone-consistency seam: a marked fiber lands in one of the seven bracket-consistent
      -- zones (from the carrier gate's off-zone exclusion, `igGateFib` conjunct 2).
      (∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZPastX ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtX ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZXW ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtW ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZWT ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtT ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZFutT) →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        kvE_fiberConsistent σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro hAmb w hxw hwt hptW hepL hepR hcharFibSound hIntL hIntR hzcons σ hmark hcons
  have hxt : x < t := hxw.trans hwt
  -- Zone-classify the marked fiber σ (marked ⇒ `igFoldBitFib` fires exactly at σ's zone), then
  -- read the arity-4 realizer off the endpoint/witness eval (exterior + boundary) or the bracket
  -- interior seam (`hIntL`/`hIntR`). No render is consumed anywhere.
  -- Helper: for the matched zone `zs`, `igFoldBitFib qnf zs σ = true`.
  rcases hzcons σ hmark with hz | hz | hz | hz | hz | hz | hz
  · -- PastX (`x1 < x`): render-free left-endpoint extraction.
    have hb : igFoldBitFib qnf igZPastX σ = true := by
      simp only [igFoldBitFib, decide_eq_true_eq]; exact ⟨hmark, hz⟩
    obtain ⟨x1, _, hx1⟩ := bracketEndChar_kvFib_realize_pastX
      (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf
      M atomMap w x t hxw hwt hcharFibSound σ hb hepL
    exact ⟨x1, hx1⟩
  · -- AtX (`x1 = x`): the `igZAtX` literal of the left endpoint is `charFib σ` at `x`.
    have hb : igFoldBitFib qnf igZAtX σ = true := by
      simp only [igFoldBitFib, decide_eq_true_eq]; exact ⟨hmark, hz⟩
    have hlit : temporal_truth M atomMap x (charFib (k + 1) σ) := by
      have h := hepL
      simp only [igEpLFib, TemporalPred.eval_at] at h
      rw [formula_conjList_iff] at h
      refine h _ ?_
      apply List.mem_append_right
      exact List.mem_map.mpr ⟨σ, by simp [igAllSubs], by simp only [igLit, hb, if_true]⟩
    have hzh : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
        (nf0_zoneSpec (NormalForm.atom_assgn σ)) x := by
      rw [hz, show igZAtX = Fin.cons (true, false) (Fin.cons (false, false)
          (fun _ => (true, false))) from rfl, ext3_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by simp)⟩,
        ⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
        ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
    exact ⟨x, hcharFibSound σ hmark x hzh hlit⟩
  · -- XW (`x < x1 < w`): left-interior bracket seam.
    have hb : igFoldBitFib qnf igZXW σ = true := by
      simp only [igFoldBitFib, decide_eq_true_eq]; exact ⟨hmark, hz⟩
    obtain ⟨x1, _, _, hx1⟩ := hIntL σ hb
    exact ⟨x1, hx1⟩
  · -- AtW (`x1 = w`): the `igZAtW` literal of the witness type is `charFib σ` at `w`.
    have hb : igFoldBitFib qnf igZAtW σ = true := by
      simp only [igFoldBitFib, decide_eq_true_eq]; exact ⟨hmark, hz⟩
    have hlit : temporal_truth M atomMap w (charFib (k + 1) σ) := by
      have h := hptW
      simp only [igPtWFib, TemporalPred.eval_at] at h
      rw [formula_conjList_iff] at h
      refine h _ ?_
      apply List.mem_cons_of_mem
      exact List.mem_map.mpr ⟨σ, by simp [igAllSubs], by simp only [igLit, hb, if_true]⟩
    have hzh : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
        (nf0_zoneSpec (NormalForm.atom_assgn σ)) w := by
      rw [hz, show igZAtW = Fin.cons (false, false) (Fin.cons (false, true)
          (fun _ => (true, false))) from rfl, ext3_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_irrefl w) (by simp), iff_of_false (lt_irrefl w) (by simp)⟩,
        ⟨iff_of_false (lt_asymm hxw) (by simp), iff_of_true hxw rfl⟩,
        ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by simp)⟩⟩
    exact ⟨w, hcharFibSound σ hmark w hzh hlit⟩
  · -- WT (`w < x1 < t`): right-interior bracket seam.
    have hb : igFoldBitFib qnf igZWT σ = true := by
      simp only [igFoldBitFib, decide_eq_true_eq]; exact ⟨hmark, hz⟩
    obtain ⟨x1, _, _, hx1⟩ := hIntR σ hb
    exact ⟨x1, hx1⟩
  · -- AtT (`x1 = t`): the `igZAtT` literal of the right endpoint is `charFib σ` at `t`.
    have hb : igFoldBitFib qnf igZAtT σ = true := by
      simp only [igFoldBitFib, decide_eq_true_eq]; exact ⟨hmark, hz⟩
    have hlit : temporal_truth M atomMap t (charFib (k + 1) σ) := by
      have h := hepR
      simp only [igEpRFib, TemporalPred.eval_at] at h
      rw [formula_conjList_iff] at h
      refine h _ ?_
      apply List.mem_append_left
      apply List.mem_cons_of_mem
      exact List.mem_map.mpr ⟨σ, by simp [igAllSubs], by simp only [igLit, hb, if_true]⟩
    have hzh : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
        (nf0_zoneSpec (NormalForm.atom_assgn σ)) t := by
      rw [hz, show igZAtT = Fin.cons (false, true) (Fin.cons (false, true)
          (fun _ => (false, false))) from rfl, ext3_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_asymm hwt) (by simp), iff_of_true hwt rfl⟩,
        ⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
        ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
    exact ⟨t, hcharFibSound σ hmark t hzh hlit⟩
  · -- FutT (`t < x1`): render-free right-endpoint extraction.
    have hb : igFoldBitFib qnf igZFutT σ = true := by
      simp only [igFoldBitFib, decide_eq_true_eq]; exact ⟨hmark, hz⟩
    obtain ⟨x1, _, hx1⟩ := bracketEndChar_kvFib_realize_futT
      (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf
      M atomMap w x t hxw hwt hcharFibSound σ hb hepR
    exact ⟨x1, hx1⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
