import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberConsistencyK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberDeepAnchorK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorAmbientDeepAnchorK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfDepth0Generalized

/-! # Task 368 probe leaf: CM-A / CM-B live-countermodel casts (Phase 1)

Machine-certifies, BEFORE any guard definition exists (the 363/364/367 probe-first
methodology), that the two paper countermodels of the task-358 Phase-4 blocker record
(`specs/358_.../plans/06_deep-anchor-rekey-v06.md`, adjudicated 2026-07-14) are LIVE against
the CURRENT rows-5/6/10-13 consumer interface (`EndIntervalConsumerK.lean:128-210`). Root
cause (the P17 anchor-content gap, one layer over the fiber-side gap task 367 closed):
`igPtW`/`igFoldBit` and every current antecedent read the ambient's deep marking `qnf.2`
ONLY at profile level (`ZoneSpec 3 × NormalForm sig (m+1) 1` buckets) — the deep content
BELOW a bucket is unconstrained, so a fake ambient can carry a deep-incomplete (CM-A) or
doppelgänger-planted (CM-B) marking invisibly to every profile-level check.

Baseline for this leaf: commit `9f4f6302b78ae3b62d8c1a322df8d3d192496fb7`, scoped build of
`ExteriorPinnedProbe358TailK` + `ExteriorFiberDeepAnchorProbe367K` + `EndIntervalConsumerK`
green. This leaf is PURELY ADDITIVE: no production file is touched by Phase 1.

## Gate 1a — CM-A is live (kills row 13, `_hexclDeepFut`)

Homogeneous model `(ℤ, <)` with `R = ∅` (every point shares the one 1-type `χ_z`); anchors
`[w, x, t] = [1, 0, 2]` (x, w = x+1, t = x+2 per the blocker record). The FAKE ambient
`qnfA` carries the honest depth-0 row of `[w, x, t]` and a deep marking of EXACTLY the five
honest depth-2 4-types `{char[x-1], char[x], char[w], char[t], char[t+1]}` =
`{cA (-1), cA 0, cA 1, cA 2, cA 3}`, OMITTING `σ_A := char[t+2, w, x, t] = cA 4` — a
deep-incomplete marking dropping one bucket-mate. `kvE_probe368_cmA_row13_refuted`
certifies the row-13 statement instantiated at `qnfA` is REFUTED by explicit witnesses:
`σ_A` is (i) order-admissible through the SANCTIONED byte-stable route
(`kvE_futRealizer_admissible` on its own realizer `0 < 1 < 2 < 4` — no guard unfolding),
(ii) bit-false (`qnfA.2 σ_A = false`: `σ_A` differs from each marked `cA v` at the
gap-point fiber `gapA := char[3; 4, 1, 0, 2]`, whose rows pin any realizing fresh point to
`t = 2 < r < v ≤ 3` — empty over ℤ; the blocker's order-only depth-1 discrepancy),
(iii) on-row (`nfk_dropFresh σ_A = qnfA.1`, by the depth-0 factorization + uniqueness),
(iv) guard-false (`kvE_deepOnFiber qnfA σ_A = false`: any qnf-marked deep-content mate
would mark `gapA`, and no `cA v` (`v ≤ 3`) does), and (v) realized at the exterior
`x1 = t + 2 = 4 > t` — so the `∀ x1, t < x1 → ¬ eval` conclusion is false.

### Sibling-rows analytical closure (profile-bucket collapse; finite ℤ proxy)

Rows 5, 5a, 6, 10, 11 HOLD at `qnfA` — the countermodel sits INSIDE the antecedent
population (this is what makes it a countermodel and not noise):
- With `R = ∅` every point has the same 1-type, so the `igFoldBit` profile buckets
  (`ZoneSpec 3 × NormalForm sig (m+1) 1`) collapse to zone occupancy alone. The omitted
  `σ_A = cA 4` shares its (exterior-future, `χ_z`) bucket with the MARKED `cA 3` — the
  omission empties no bucket, so `igPtW`, `epL`/`epR`, and `igOffFiber` read `qnfA.2`
  exactly as they read the honest full marking; `segL`/`segR` are vacuous (the marked
  anchors `-1, 0, 1, 2, 3` are consecutive integers — discrete gaps empty).
- Row 5a (`_hfiberCons`): every `qnfA`-marked sub is an HONEST characteristic `cA v`,
  realized at `[v, 1, 0, 2]`, hence fiber-consistent via
  `kvE_fiberConsistent_of_realized`.
- Row 5 (`_hreal`): each marked `cA v` is realized at `x1 = v` over the real tail — the
  realizer exists.
- Row 6 (`_hexcl`): a within-`[x, t] = [0, 2]` realizer of any σ at `[x1, 1, 0, 2]` forces
  `σ = char[x1, 1, 0, 2] ∈ {cA 0, cA 1, cA 2}` (uniqueness of characteristics), all
  bit-TRUE — no bit-false σ is interior-realized.
- Rows 10-11 (`_hexclSlice*`): same uniqueness argument at exterior `x1`: a realized σ is
  `cA x1`; the bit-false ones among these are `cA v` for `v ∉ {-1, 0, 1, 2, 3}`, and for
  such σ the slice-marked antecedent fails against the collapsed buckets (the marked
  slice content is honest). The Z cast is the finite proxy of the blocker's
  homogeneous-family argument; the rows are hypothesis-side binders, so their holding is
  an analytical record, not a mechanized obligation of this leaf.
Consequence (blocker record): `qnfA`'s full gate LHS is satisfiable while `qnfA` is never
realized at `[w, x, t]` (its marking is deep-incomplete — a realized ambient marks ALL
realized fibers, including `σ_A`), so NO discharge of the 13 rows can exist as stated: any
such discharge would prove the gate biconditional, which CM-A falsifies at m = 1.

## Gate 1b — CM-B is live (kills row 5, `_hreal`)

The `ExteriorPinnedProbe358TailK` tail-doppelgänger re-aimed at the AMBIENT: model
`(ℤ, <)` with `R = {10}`, REAL anchors `[w, x, t] = [5, 2, 30]`, FAKE tail
`[w̃, x̃, t̃] = [12, 8, 25]` — depth-0 indistinguishable (same order pattern, all slots
R-free), spacing-discrepant at depth 1 (the R-point `10` lies in `(x̃, w̃) = (8, 12)`
fake-side vs `(w, t) = (5, 30)` real-side). The fake ambient `qnfB` carries the honest
row and the honest deep marking PLUS one planted mark: `sub_g := char[w̃; w̃, x̃, t̃]`
(the AtW-zoned honest 4-type over the fake tail, fresh pinned AT the w-slot).
`kvE_probe368_cmB_row5_refuted` certifies: `sub_g` is (i) `qnfB`-marked (by
construction), (ii) fiber-consistent through the SANCTIONED route
(`kvE_fiberConsistent_of_realized` over its own fake tuple `[12, 12, 8, 25]` — every cast
element is honest), (iii) on-row (`nfk_dropFresh sub_g = qnfB.1`: the fake and real tails
are depth-0 indistinguishable — the verbatim 358TailK funext block), yet (iv)
`[w, x, t]`-UNREALIZABLE: `sub_g.2` marks the R-point fiber
`sG10 := char[10; 12, 12, 8, 25]`, whose (fresh, w-slot) row reads `10 < 12` fake-side —
any realization over the real tail demands an R-point strictly below `w = 5`, and
`R = {10}`. So row 5's conclusion (`∃ x1, eval`) fails at `σ := sub_g` while the
antecedent population contains it.

### igPtW-invisibility record (same-bucket argument)

`sub_g` shares its `igFoldBit` bucket (AtW zone, `χ_w`) with the honest
`sub_w := char[w; w, x, t] = char[5; 5, 2, 30]`: both are AtW-zoned (fresh = w-slot) and
both fresh points (`12`, `5`) are R-free, hence share the 1-type `χ_w`. Every profile
bucket of `qnfB.2` therefore reads identically to the honest marking (`qnfB` differs from
the honest ambient only by the one planted mark inside an already-occupied bucket), so
`igPtW`, the endpoint clauses, and every profile-level sibling antecedent hold at `qnfB`
exactly as at the honest ambient. Only a syntactic DEEP guard on `qnf.2` itself can
separate them — the circularity finding (blocker record) rules out any semantic bridge:
"ambient realized at `[w, x, t]`" IS rows 5+6+10+11+12+13 (+ atom row), so no bridge
built from those rows can presuppose its own conclusion.

## Consumption-site map (Phase 1; the authoritative Phase-5 edit boundary)

Verified this session at baseline `9f4f6302`:

STATEMENT-TOUCHING (rows 5/6/10-13 gain the ambient-guard antecedent; Phase 5):
1. `EndIntervalConsumerK.lean` — `EndIntervalCorrectPrior` binder block (:128-210):
   `_hfiberCons` (:128, row 5a), `_hreal` (:130, row 5), `_hexcl` (:137, row 6),
   `_hexclSlicePast` (:172, row 10), `_hexclSliceFut` (:179, row 11), `_hexclDeepPast`
   (:191, row 12), `_hexclDeepFut` (:198, row 13). Rows 8-9 `_hslicePast`/`_hsliceFut`
   (:160-172) are ambient-REALIZATION-guarded (`nf_eval_nf … qnf` antecedent) and
   BYTE-STABLE — an ambient-side syntactic guard only strengthens their effective
   population. `endInterval_step_correct` threading (:239-255): proof-script-only.
2. `ExteriorGateAssembleK.lean` — `bracketEndChar_kvExt_correct_prior` (:180-280): binder
   mirrors `hreal` (:197), `hexcl`, `hexclSlicePast`/`hexclSliceFut`, `hexclDeepPast`
   (:266), `hexclDeepFut` (:273) — statement-touching; the ⇒-side guard-split dispatch
   (:289-325): proof-script-only.
3. `KampPrior.lean:964-1035` — `kampPrior_site_rungK_gate_match` binder mirror (verbatim
   copies of the same nine binders) — statement-touching. The `:519`/`:522` sorries are
   task-358 territory: UNTOUCHED.
4. Gate-formula strengthening (Phase 2/5 adjudication — candidates, do NOT presuppose):
   the ambient guard is σ-INDEPENDENT (a `Bool` of `qnf` alone), unlike 367's per-σ range
   re-key (`ExteriorBracketAssembleK.lean:96/:110`, `kvE_futAdmissible σ &&
   kvE_deepOnFiber qnf σ`). The natural sites are the gate assembly `bracketEndChar_kvExt`
   (`ExteriorGateAssembleK.lean:119`) and/or the consumer formula `endIntervalPrior`
   (`EndIntervalConsumerK.lean:70`) — a top-level conjunct/guard on `qnf` so the
   ⇒-reconstruction can consume it. Phase 2 designs; probes adjudicate.

PROOF-SCRIPT-ONLY / FROZEN (never edited): the profile readers `igPtW`
(`InteriorGateGeneralK.lean:243`) / `igFoldBit` (:318) — the root-cause profile-level
readers stay as they are; the fix is a NEW antecedent, not a reader change. All files in
the plan's frozen list (363/364 files, 367 files, m = 0 kernels, k ≤ 1 rungs, task-360
supply, `ExteriorDeepSliceSupplyK.lean`, negation/converter families, historical probe
records) are byte-stable; `ExteriorPinnedProbe358TailK.lean` statements stay byte-stable.

Probe conventions: template copies of `ExteriorPinnedProbe358TailK.lean` /
`ExteriorFiberDeepAnchorProbe367K.lean` (model shape, private cast replication precedent,
public certificates). Guard consumption routes exclusively through byte-stable extraction
lemmas (`kvE_deepOnFiber_iff`, `kvE_futRealizer_admissible`,
`kvE_fiberConsistent_of_realized`) — zero guard unfoldings in this leaf. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## CM-A cast: the deep-incomplete homogeneous ambient (kills row 13) -/

/-- One-predicate signature for the CM-A probe (the marker `R`, kept EMPTY here). -/
private abbrev mAsig : MonadicSignature := { preds := Unit }

/-- The CM-A probe model `(ℤ, <)` with `R = ∅` — fully homogeneous: every point shares
    the one 1-type `χ_z`, so the `igFoldBit` profile buckets collapse. -/
private abbrev MA : OrderedMonadicStructure mAsig where
  carrier := ℤ
  interp := fun _ _ => False
  carrier_order := inferInstance

/-- Ambient anchors `[w, x, t] = [1, 0, 2]` (x, w = x + 1, t = x + 2). -/
private def mAenv3 : Fin 3 → MA.carrier := Fin.cons 1 (Fin.cons 0 (fun _ => 2))

/-- The honest depth-2 4-type `char[v, w, x, t]` (the m = 1 instance of the blocker's
    "(m+1)-depth 4-type over `[v, w, x, t]`"). -/
private noncomputable def cA (v : ℤ) : NormalForm mAsig 2 4 :=
  nf_characteristic MA 2 4 (Fin.cons v mAenv3)

/-- The omitted bucket-mate `σ_A := char[t+2, w, x, t] = char[4, 1, 0, 2]`. -/
private noncomputable def sigmaA : NormalForm mAsig 2 4 := cA 4

/-- The FAKE ambient `qnfA`: honest depth-0 row of `[w, x, t]`; deep marking EXACTLY the
    five honest chars `{char[x-1], char[x], char[w], char[t], char[t+1]}`, OMITTING
    `σ_A` — the blocker's deep-incomplete marking. -/
private noncomputable def qnfA : NormalForm mAsig 3 3 :=
  NormalForm.step (nf_characteristic MA 3 3 mAenv3).1
    (fun τ => @decide (τ = cA (-1) ∨ τ = cA 0 ∨ τ = cA 1 ∨ τ = cA 2 ∨ τ = cA 3)
      (Classical.dec _))

/-- The separating deep element: the gap-point fiber `[t+1; t+2, w, x, t] =
    char[3; 4, 1, 0, 2]` — marked in `σ_A.2`, unmarkable in any `cA v` with `v ≤ 3`. -/
private noncomputable def gapA : NormalForm mAsig 1 5 :=
  nf_characteristic MA 1 5 (Fin.cons 3 (Fin.cons 4 mAenv3))

/-- `σ_A` marks the gap-point fiber (honest witness: the gap point `3 ∈ (t, t+2)`). -/
private theorem sigmaA_marks_gapA : sigmaA.2 gapA = true :=
  @decide_eq_true _ (Classical.dec _)
    ⟨3, nf_characteristic_satisfies MA 1 5 (Fin.cons 3 (Fin.cons 4 mAenv3))⟩

/-- NO `cA v` with `v ≤ 3` marks the gap-point fiber: `gapA`'s (t-slot, fresh) and
    (fresh, v-slot) rows pin any realizing fresh point `r` to `2 < r < v ≤ 3` — empty
    over ℤ. The blocker's order-only depth-1 discrepancy, mechanized. -/
private theorem cA_gap_false (v : ℤ) (hv : v ≤ 3) : (cA v).2 gapA = false := by
  refine @decide_eq_false _ (Classical.dec _) ?_
  rintro ⟨r, hr⟩
  -- gapA's (fresh, v-slot) row: `3 < 4` at the defining tuple — evaluated, `r < v`
  have hord1 := hr.1 (.order 0 ⟨1, by decide⟩ (by decide))
  have h1 : @LT.lt ℤ _ r v := hord1.mpr
    (@decide_eq_true _ (Classical.dec _) (show (3:ℤ) < 4 by omega))
  -- gapA's (t-slot, fresh) row: `2 < 3` at the defining tuple — evaluated, `2 < r`
  have hord2 := hr.1 (.order ⟨4, by decide⟩ 0 (by decide))
  have h2 : (2:ℤ) < r := hord2.mpr
    (@decide_eq_true _ (Classical.dec _) (show (2:ℤ) < 3 by omega))
  omega

/-- `σ_A` is bit-false: it is none of the five marked chars — each marked `cA v`
    (`v ≤ 3`) disagrees with `σ_A` at the gap-point fiber. -/
private theorem qnfA_bit_false : qnfA.2 sigmaA = false := by
  refine @decide_eq_false _ (Classical.dec _) ?_
  have key : ∀ v : ℤ, v ≤ 3 → sigmaA ≠ cA v := by
    intro v hv h
    have h1 : (cA v).2 gapA = true := by rw [← h]; exact sigmaA_marks_gapA
    rw [cA_gap_false v hv] at h1
    exact Bool.noConfusion h1
  rintro (h | h | h | h | h)
  · exact key (-1) (by omega) h
  · exact key 0 (by omega) h
  · exact key 1 (by omega) h
  · exact key 2 (by omega) h
  · exact key 3 (by omega) h

/-- `σ_A` is guard-false: any qnf-marked deep-content mate `σ'` (with `σ'.2 = σ_A.2`)
    would mark the gap-point fiber, and no marked `cA v` does. Routed through the
    byte-stable extraction `kvE_deepOnFiber_iff` — no guard unfolding. -/
private theorem qnfA_guard_false : kvE_deepOnFiber qnfA sigmaA = false := by
  cases hg : kvE_deepOnFiber qnfA sigmaA with
  | false => rfl
  | true =>
    exfalso
    obtain ⟨-, σ', hmk, heq⟩ := (kvE_deepOnFiber_iff qnfA sigmaA).mp hg
    have hd : σ' = cA (-1) ∨ σ' = cA 0 ∨ σ' = cA 1 ∨ σ' = cA 2 ∨ σ' = cA 3 :=
      @of_decide_eq_true _ (Classical.dec _) hmk
    have hσg : σ'.2 gapA = true := by rw [heq]; exact sigmaA_marks_gapA
    have hfalse : ∀ v : ℤ, v ≤ 3 → σ' = cA v → False := by
      intro v hv h
      rw [h, cA_gap_false v hv] at hσg
      exact Bool.noConfusion hσg
    rcases hd with h | h | h | h | h
    · exact hfalse (-1) (by omega) h
    · exact hfalse 0 (by omega) h
    · exact hfalse 1 (by omega) h
    · exact hfalse 2 (by omega) h
    · exact hfalse 3 (by omega) h

/-- `σ_A` is on-row: its dropped atom row is the honest depth-0 row of `[w, x, t]` —
    the depth-0 factorization + uniqueness route (`kvE_deepOnFiber_of_realized`'s own
    row argument, replayed at the concrete cast). -/
private theorem sigmaA_on_row : nfk_dropFresh sigmaA = qnfA.1 := by
  have hatom := nf_eval_nf_atom_layer MA _ sigmaA
    (nf_characteristic_satisfies MA 2 4 (Fin.cons 4 mAenv3))
  have hfac := (nf_eval_nf0_cons_factor MA mAenv3 4 sigmaA.atom_assgn).mp hatom
  exact nf_eval_unique MA 0 3 mAenv3 _ _ hfac.2.2
    (nf_eval_nf_atom_layer MA mAenv3 (nf_characteristic MA 3 3 mAenv3)
      (nf_characteristic_satisfies MA 3 3 mAenv3))

/-- `σ_A` is order-admissible through the SANCTIONED byte-stable route: its own honest
    realizer `0 < 1 < 2 < 4` (`x < w < t < x1`) — no guard unfolding. -/
private theorem sigmaA_admissible : kvE_futAdmissible sigmaA = true :=
  kvE_futRealizer_admissible MA sigmaA 4 1 0 2
    (show (0:ℤ) < 1 by omega) (show (1:ℤ) < 2 by omega) (show (2:ℤ) < 4 by omega)
    (nf_characteristic_satisfies MA 2 4 (Fin.cons 4 mAenv3))

/-- **Gate 1a — CM-A is a LIVE countermodel: row 13 (`_hexclDeepFut`,
    `EndIntervalConsumerK.lean:198`) instantiated at the fake ambient `qnfA` is REFUTED
    by explicit witnesses.** `σ_A = char[t+2, w, x, t]` satisfies EVERY σ-side antecedent
    of the row-13 binder at m = 1 — order-admissible (conjunct 1), bit-false (conjunct 2),
    on-row (conjunct 3), deep-anchor-guard-false (conjunct 4) — yet it is realized at the
    exterior `x1 = t + 2 = 4 > t = 2` (conjuncts 5-6), so the binder's conclusion
    `∀ x1, t < x1 → ¬ eval` is FALSE at `qnfA`. The `w`-side profile antecedents
    (`x < w`, `w < t`, `igPtW`) hold by the homogeneous profile-bucket collapse (module
    docstring: sibling-rows analytical closure). Sorry-free; axioms
    `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe368_cmA_row13_refuted :
    kvE_futAdmissible sigmaA = true ∧
    qnfA.2 sigmaA = false ∧
    nfk_dropFresh sigmaA = qnfA.1 ∧
    kvE_deepOnFiber qnfA sigmaA = false ∧
    (2:ℤ) < 4 ∧
    nf_eval_nf MA 2 4 (Fin.cons 4 mAenv3) sigmaA :=
  ⟨sigmaA_admissible, qnfA_bit_false, sigmaA_on_row, qnfA_guard_false,
    by omega, nf_characteristic_satisfies MA 2 4 (Fin.cons 4 mAenv3)⟩

/-! ## CM-B cast: the ambient tail-doppelgänger plant (kills row 5) -/

/-- One-predicate signature for the CM-B probe (the deep marker `R`). -/
private abbrev mBsig : MonadicSignature := { preds := Unit }

/-- The CM-B probe model `(ℤ, <)` with `R = {10}` — the `Probe358TailK` model shape. -/
private abbrev MB : OrderedMonadicStructure mBsig where
  carrier := ℤ
  interp := fun _ z => z = 10
  carrier_order := inferInstance

/-- REAL ambient anchors `[w, x, t] = [5, 2, 30]`. -/
private def mBreal3 : Fin 3 → MB.carrier := Fin.cons 5 (Fin.cons 2 (fun _ => 30))

/-- FAKE (doppelgänger) tail `[w̃, x̃, t̃] = [12, 8, 25]` — depth-0 indistinguishable
    from the real anchors; the R-point `10` lies in `(x̃, w̃) = (8, 12)` fake-side vs
    `(w, t) = (5, 30)` real-side. -/
private def mBfake3 : Fin 3 → MB.carrier := Fin.cons 12 (Fin.cons 8 (fun _ => 25))

/-- The AtW-pinned fake tuple `[w̃; w̃, x̃, t̃] = [12, 12, 8, 25]` (fresh AT the
    w-slot). -/
private def mBsubgTup : Fin 4 → MB.carrier := Fin.cons 12 mBfake3

/-- The planted mark `sub_g := char[w̃; w̃, x̃, t̃]` — the AtW-zoned HONEST 4-type over
    the fake tail (every cast element is realized; nothing here is a fake fiber). -/
private noncomputable def subG : NormalForm mBsig 2 4 := nf_characteristic MB 2 4 mBsubgTup

/-- The FAKE ambient `qnfB`: the honest row and honest deep marking of `[w, x, t]`, PLUS
    the one planted mark `sub_g` (inside the honest `sub_w`'s (AtW, χ_w) bucket —
    igPtW-invisible, module docstring). -/
private noncomputable def qnfB : NormalForm mBsig 3 3 :=
  NormalForm.step (nf_characteristic MB 3 3 mBreal3).1
    (fun τ => (nf_characteristic MB 3 3 mBreal3).2 τ || @decide (τ = subG) (Classical.dec _))

/-- `sub_g` is `qnfB`-marked (the plant, by construction). -/
private theorem qnfB_marks_subG : qnfB.2 subG = true := by
  show ((nf_characteristic MB 3 3 mBreal3).2 subG ||
    @decide (subG = subG) (Classical.dec _)) = true
  rw [@decide_eq_true _ (Classical.dec _) rfl, Bool.or_true]

/-- `sub_g` is fiber-consistent through the SANCTIONED byte-stable route: it is honestly
    realized at its own fake tuple — `kvE_fiberConsistent_of_realized`, no guard
    unfolding. -/
private theorem subG_fiberConsistent : kvE_fiberConsistent subG = true :=
  kvE_fiberConsistent_of_realized MB mBsubgTup subG
    (nf_characteristic_satisfies MB 2 4 mBsubgTup)

/-- `sub_g` is on-row: the fake and real tails are depth-0 indistinguishable (same order
    pattern, all slots R-free) — the verbatim `Probe358TailK` funext block at the dropped
    tail `[12, 8, 25]` vs `[5, 2, 30]`. -/
private theorem subG_on_row : nfk_dropFresh subG = qnfB.1 := by
  funext a
  match a with
  | .pred _ ⟨0, _⟩ =>
    exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((12:ℤ) = 10))).trans
      (@decide_eq_false _ (Classical.dec _) (by omega : ¬((5:ℤ) = 10))).symm
  | .pred _ ⟨1, _⟩ =>
    exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((8:ℤ) = 10))).trans
      (@decide_eq_false _ (Classical.dec _) (by omega : ¬((2:ℤ) = 10))).symm
  | .pred _ ⟨2, _⟩ =>
    exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((25:ℤ) = 10))).trans
      (@decide_eq_false _ (Classical.dec _) (by omega : ¬((30:ℤ) = 10))).symm
  | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
  | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
    exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((12:ℤ) < 8))).trans
      (@decide_eq_false _ (Classical.dec _) (by omega : ¬((5:ℤ) < 2))).symm
  | .order ⟨0, _⟩ ⟨2, _⟩ _ =>
    exact (@decide_eq_true _ (Classical.dec _) (by omega : (12:ℤ) < 25)).trans
      (@decide_eq_true _ (Classical.dec _) (by omega : (5:ℤ) < 30)).symm
  | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
    exact (@decide_eq_true _ (Classical.dec _) (by omega : (8:ℤ) < 12)).trans
      (@decide_eq_true _ (Classical.dec _) (by omega : (2:ℤ) < 5)).symm
  | .order ⟨1, _⟩ ⟨1, _⟩ h => exact absurd rfl h
  | .order ⟨1, _⟩ ⟨2, _⟩ _ =>
    exact (@decide_eq_true _ (Classical.dec _) (by omega : (8:ℤ) < 25)).trans
      (@decide_eq_true _ (Classical.dec _) (by omega : (2:ℤ) < 30)).symm
  | .order ⟨2, _⟩ ⟨0, _⟩ _ =>
    exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((25:ℤ) < 12))).trans
      (@decide_eq_false _ (Classical.dec _) (by omega : ¬((30:ℤ) < 5))).symm
  | .order ⟨2, _⟩ ⟨1, _⟩ _ =>
    exact (@decide_eq_false _ (Classical.dec _) (by omega : ¬((25:ℤ) < 8))).trans
      (@decide_eq_false _ (Classical.dec _) (by omega : ¬((30:ℤ) < 2))).symm
  | .order ⟨2, _⟩ ⟨2, _⟩ h => exact absurd rfl h

/-- The separating deep element: the 5-type of the R-point `10` over the AtW-pinned fake
    tuple. Its (fresh, w-slot) order row reads `10 < 12` fake-side — realized over the
    real tail it demands an R-point strictly below `w = 5`, and `R = {10}`. -/
private noncomputable def sG10 : NormalForm mBsig 1 5 :=
  nf_characteristic MB 1 5 (Fin.cons 10 mBsubgTup)

/-- `sub_g` marks the R-point fiber (honest witness: the R-point `10` itself). -/
private theorem subG_marks_sG10 : subG.2 sG10 = true :=
  @decide_eq_true _ (Classical.dec _)
    ⟨10, nf_characteristic_satisfies MB 1 5 (Fin.cons 10 mBsubgTup)⟩

/-- **The pinned refutation**: `sub_g` is realized over the REAL tail at NO `x1` — its
    marked R-point fiber `sG10` demands an R-point strictly below the w-slot, and
    `R ∩ (-∞, 5) = ∅`. -/
private theorem subG_unrealizable :
    ¬ ∃ x1 : MB.carrier, nf_eval_nf MB 2 4 (Fin.cons x1 mBreal3) subG := by
  rintro ⟨x1, hz⟩
  obtain ⟨u, hu⟩ := (hz.2 sG10).mpr subG_marks_sG10
  -- the fiber witness carries `R` (fresh-slot predicate row of `sG10`)
  have hu10 : u = 10 := (hu.1 (.pred () 0)).mpr
    (@decide_eq_true _ (Classical.dec _) (rfl : (10:ℤ) = 10))
  -- `sG10`'s (fresh, w-slot) order row: `10 < 12` fake-side — over the real tail, `u < 5`
  have hord := hu.1 (.order 0 ⟨2, by decide⟩ (by decide))
  have hlt : u < (5:ℤ) := hord.mpr
    (@decide_eq_true _ (Classical.dec _) (show (10:ℤ) < 12 by omega))
  have h105 : ¬ ((10:ℤ) < (5:ℤ)) := by omega
  rw [hu10] at hlt
  exact h105 hlt

/-- **Gate 1b — CM-B is a LIVE countermodel: row 5 (`_hreal`,
    `EndIntervalConsumerK.lean:130`) instantiated at the fake ambient `qnfB` is REFUTED
    by explicit witnesses.** `sub_g` satisfies every σ-side antecedent of the row-5
    binder at m = 1 — `qnfB`-marked (conjunct 1) and fiber-consistent through the
    sanctioned byte-stable route (conjunct 2), and additionally on-row (conjunct 3, the
    depth-0 indistinguishability that makes the plant invisible) — yet NO `x1` realizes
    it over the real tail (conjunct 4), so the binder's conclusion `∃ x1, eval` is FALSE
    at `qnfB`. The `w`-side profile antecedents hold by the same-bucket igPtW-invisibility
    argument (module docstring). Sorry-free; axioms
    `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe368_cmB_row5_refuted :
    qnfB.2 subG = true ∧
    kvE_fiberConsistent subG = true ∧
    nfk_dropFresh subG = qnfB.1 ∧
    ¬ ∃ x1 : MB.carrier, nf_eval_nf MB 2 4 (Fin.cons x1 mBreal3) subG :=
  ⟨qnfB_marks_subG, subG_fiberConsistent, subG_on_row, subG_unrealizable⟩

/-! ## Phase 2: candidate ambient EF-closure guard + exclusion gates (probe-only)

The candidate guard `kvE_ambientDeepAnchorV0 (qnf : NormalForm sig (k+2) n) : Bool` is a
σ-INDEPENDENT decidable predicate over the NF fintype (no model parameter), graded on `k`
exactly as `kvE_deepOnFiber` is graded on σ-depth:

* **`k = 0` arm** (the m = 0 binder instance, `qnf : NormalForm sig 2 n`): literally `true`
  — the guard is DEFINITIONALLY inert (`kvE_ambientDeepAnchorV0_zero`, `rfl`), keeping the
  frozen task-360 m = 0 supply, the k ≤ 1 rungs, and any m = 0 residue rows untouched/vacuous
  in Phase 5.
* **`k + 1` arm** (m ≥ 1, exercised by the m = 1 gates at ambient depth 3): the
  **fresh-rotation EF-closure** of `qnf.2`. For every marked sub `τ` (`qnf.2 τ = true`) and
  every deep element `ρ` of `τ` (`τ.2 ρ = true`), there must be a marked sub `σ'`
  (`qnf.2 σ' = true`) that COVERS the top-two-slot swap of `ρ` (`σ'.2 (swapNF01 ρ) = true`).

  Both plan clauses are facets of this one closure: clause (i) **fresh-rotation re-appearance**
  (CM-A's deep-incomplete marking violates it — `char[t+1]`'s inner `[t+2]`-fiber swaps to
  `gapA`, which no marked `cA v` (`v ≤ 3`) covers, so `σ_A = cA 4` is never forced back in) and
  clause (ii) **deep-content-to-row anchoring** (CM-B's `sub_g` violates it — its planted
  R-point fiber `sG10` swaps to a 5-type forcing `R` at the w-mate slot BELOW the w-slot, which
  no marked sub over the real tail — nor `sub_g` itself — can realize).

### Depth/arity bookkeeping (Risk 2; 367 lesson)

The "re-appearance under fresh-rotation" is expressed as a **membership/mate condition at the
type `qnf.2` already marks** (`∃ marked σ', σ'.2 (swapNF01 ρ) = true`), NOT as a slot-drop:
`swapNF01 := renameNF (Equiv.swap 0 1) (Equiv.swap 0 1)` is the sanctioned, DEPTH-preserving,
ARITY-preserving reindex from `NfDepth0Generalized` (`renameNF`/`renameNF_eval_iff`). The
depth-raising slot-drop `nfk_projFresh` stays F2-DEAD and is never built. `swapNF01` on a
characteristic is again a characteristic of the swapped environment (`swapNF01_char`, via
`renameNF_eval_iff` + `nf_eval_unique`) — the only fact the gates need.

### Rejected candidate forms (367 house style)

* **Atom-row-only re-appearance** (compare dropped atom rows of `τ.2` fibers against marked
  subs' atom rows): REJECTED — CM-B's doppelgänger is depth-0 indistinguishable by
  construction (`subG_on_row`), so an atom-row check cannot separate it. Deep-content rotation
  is mandatory.
* **`.2`-mate without swap** (`∃ marked σ', σ'.2 ρ = true`): REJECTED — the base of `ρ`
  identifies its parent `τ` uniquely, so the only witness is `σ' = τ`; the condition is
  vacuously satisfied and forces nothing (would not reject CM-A).
* **Model-side realizability** (require each marked sub realized at some tail point):
  REJECTED — circular (that IS the gate conclusion, per the blocker record), and not a
  decidable syntactic `Bool` of `qnf` alone.
* **Depth-raising rotation `rotate(ρ)` as a function then `qnf.2 (rotate ρ)`**: REJECTED —
  promotion of the fresh variable to a quantifier layer is NOT determined by `ρ` alone (it
  needs the ambient's realization data), so `rotate` is not a total syntactic function; the
  swap-then-membership formulation sidesteps this. -/

/-! ## Promotion (Phase 5): the guard now lives in production

`swapNF01`, `swapNF01_char`, the guard, `_zero`, `_iff`, and `_of_realized` were promoted
VERBATIM into the production module `ExteriorAmbientDeepAnchorK.lean` (Phase 5). This leaf is
the PERMANENT REGRESSION RECORD and certifies its CM-A / CM-B / depth-2 / copy-plant gates
against the PRODUCTION definitions: `swapNF01` / `swapNF01_char` are consumed directly from
production, and `kvE_ambientDeepAnchorV0` and its `_zero` / `_iff` / `_of_realized` lemmas are
thin compatibility aliases for the production `kvE_ambientDeepAnchor` family, so exactly ONE
live definition exists. -/

/-- Compatibility alias for the promoted production guard `kvE_ambientDeepAnchor`
    (`ExteriorAmbientDeepAnchorK.lean`). -/
noncomputable abbrev kvE_ambientDeepAnchorV0 {sig : MonadicSignature} {k n : Nat}
    (qnf : NormalForm sig (k + 2) n) : Bool := kvE_ambientDeepAnchor qnf

/-- **Gate 2c — m = 0 inertness** (alias for `kvE_ambientDeepAnchor_zero`). -/
theorem kvE_ambientDeepAnchorV0_zero {sig : MonadicSignature} {n : Nat}
    (qnf : NormalForm sig 2 n) : kvE_ambientDeepAnchorV0 qnf = true :=
  kvE_ambientDeepAnchor_zero qnf

/-! ### Gate 2a — CM-A excluded (deep-incomplete marking fails EF-closure) -/

/-- `cA 3 = char[t+1, w, x, t]` is `qnfA`-marked (it is the fifth listed char). -/
private theorem qnfA_marks_cA3 : qnfA.2 (cA 3) = true :=
  @decide_eq_true _ (Classical.dec _) (Or.inr (Or.inr (Or.inr (Or.inr rfl))))

/-- The inner `[t+2]`-fiber of `cA 3`: `char[t+2; t+1, w, x, t] = char[4; 3, 1, 0, 2]`. Its
    top-two-slot swap is `gapA = char[t+1; t+2, w, x, t]`. -/
private noncomputable def fibA34 : NormalForm mAsig 1 5 :=
  nf_characteristic MA 1 5 (Fin.cons 4 (Fin.cons 3 mAenv3))

/-- `cA 3` marks its own inner `[t+2]`-fiber (honest witness: the point `4 = t+2` above
    `3 = t+1`). -/
private theorem cA3_marks_fibA34 : (cA 3).2 fibA34 = true :=
  @decide_eq_true _ (Classical.dec _)
    ⟨4, nf_characteristic_satisfies MA 1 5 (Fin.cons 4 (Fin.cons 3 mAenv3))⟩

/-- The swap of `cA 3`'s inner `[t+2]`-fiber IS `gapA` — the separating deep element no marked
    `cA v` (`v ≤ 3`) covers. Via `swapNF01_char` + the concrete environment swap. -/
private theorem swapNF01_fibA34 : swapNF01 fibA34 = gapA := by
  have hE : (Fin.cons (4 : ℤ) (Fin.cons 3 mAenv3)) ∘ ⇑(Equiv.swap (0 : Fin 5) 1)
      = Fin.cons 3 (Fin.cons 4 mAenv3) := by
    funext i
    fin_cases i <;> rfl
  show swapNF01 (nf_characteristic MA 1 5 (Fin.cons 4 (Fin.cons 3 mAenv3))) = gapA
  rw [swapNF01_char MA, hE]
  rfl

/-- **Gate 2a — CM-A is EXCLUDED by the candidate guard**: `kvE_ambientDeepAnchorV0 qnfA =
    false`. The deep-incomplete marking fails clause (i): the marked `cA 3` carries the inner
    `[t+2]`-fiber `fibA34`, whose swap `gapA` is covered by NO marked sub (the honest completer
    `σ_A = cA 4` was dropped, and no `cA v` with `v ≤ 3` marks `gapA` — Phase-1 `cA_gap_false`).
    Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe368_cmA_ambient_rejected : kvE_ambientDeepAnchorV0 qnfA = false := by
  cases hg : kvE_ambientDeepAnchorV0 qnfA with
  | false => rfl
  | true =>
    exfalso
    -- unfold the k = 0 (ambient-depth-3) arm to the outer `.all`
    rw [show kvE_ambientDeepAnchorV0 qnfA
          = (Finset.univ.toList (α := NormalForm mAsig 2 4)).all (fun τ =>
              !qnfA.2 τ ||
              (Finset.univ.toList (α := NormalForm mAsig 1 5)).all (fun ρ =>
                !τ.2 ρ ||
                (Finset.univ.toList (α := NormalForm mAsig 2 4)).any (fun σ' =>
                  qnfA.2 σ' && σ'.2 (swapNF01 ρ)))) from rfl,
        List.all_eq_true] at hg
    have hτ := hg (cA 3) (kvE_nf_mem_univ_toList _)
    rw [qnfA_marks_cA3, Bool.not_true, Bool.false_or, List.all_eq_true] at hτ
    have hρ := hτ fibA34 (kvE_nf_mem_univ_toList _)
    rw [cA3_marks_fibA34, Bool.not_true, Bool.false_or, List.any_eq_true] at hρ
    obtain ⟨σ', -, hσ'⟩ := hρ
    rw [Bool.and_eq_true, swapNF01_fibA34] at hσ'
    obtain ⟨hmk, hcov⟩ := hσ'
    have hd : σ' = cA (-1) ∨ σ' = cA 0 ∨ σ' = cA 1 ∨ σ' = cA 2 ∨ σ' = cA 3 :=
      @of_decide_eq_true _ (Classical.dec _) hmk
    have hfalse : ∀ v : ℤ, v ≤ 3 → σ' = cA v → False := by
      intro v hv h
      rw [h, cA_gap_false v hv] at hcov
      exact Bool.noConfusion hcov
    rcases hd with h | h | h | h | h
    · exact hfalse (-1) (by omega) h
    · exact hfalse 0 (by omega) h
    · exact hfalse 1 (by omega) h
    · exact hfalse 2 (by omega) h
    · exact hfalse 3 (by omega) h

/-! ### Gate 2b — CM-B excluded (doppelgänger marking fails EF-closure) -/

/-- The swap of `sub_g`'s planted R-point fiber `sG10 = char[R-pt; w̃, w̃, x̃, t̃]`: the 5-type
    `char[w̃; R-pt, w̃, x̃, t̃] = char[12; 10, 12, 8, 25]`. Its atom row forces `R` at the
    w-mate slot 1 AND `slot 1 < slot 2` — jointly unrealizable over any honest `[·, w, x, t]`
    tail (there `slot 1 = w = 5 ≠ R` and, when forced `= R = 10`, `10 < x = 2` fails) and over
    `sub_g`'s own fake tail (there `slot 1 = w̃ = 12 ≠ R`). -/
private noncomputable def swG : NormalForm mBsig 1 5 :=
  nf_characteristic MB 1 5 (Fin.cons 12 (Fin.cons 10 mBfake3))

/-- The swap of `sub_g`'s planted R-point fiber IS `swG`. Via `swapNF01_char`. -/
private theorem swapNF01_sG10 : swapNF01 sG10 = swG := by
  have hE : (Fin.cons (10 : ℤ) mBsubgTup) ∘ ⇑(Equiv.swap (0 : Fin 5) 1)
      = Fin.cons 12 (Fin.cons 10 mBfake3) := by
    funext i
    fin_cases i <;> rfl
  show swapNF01 (nf_characteristic MB 1 5 (Fin.cons 10 mBsubgTup)) = swG
  rw [swapNF01_char MB, hE]
  rfl

/-- If `swG` is realized over a 5-tuple `T`, then `T 1 = 10` (R at slot 1) and `T 1 < T 2`
    (order slot 1 < slot 2) — the joint atom-row obstruction of the swapped R-point fiber. The
    atom rows are read off `swG`'s own characteristic env `[12, 10, 12, 8, 25]` (slot 1 = R-pt
    `10`, and `10 < 12` = slot 2), via the Phase-1 `decide_eq_true` idiom. -/
private theorem swG_forces {T : Fin 5 → MB.carrier} (hT : nf_eval_nf MB 1 5 T swG) :
    T 1 = 10 ∧ T 1 < T 2 :=
  ⟨(hT.1 (.pred () 1)).mpr (@decide_eq_true _ (Classical.dec _) (rfl : (10 : ℤ) = 10)),
   (hT.1 (.order 1 2 (by decide))).mpr
     (@decide_eq_true _ (Classical.dec _) (show (10 : ℤ) < 12 by omega))⟩

/-- **Gate 2b — CM-B is EXCLUDED by the candidate guard**: `kvE_ambientDeepAnchorV0 qnfB =
    false`. The doppelgänger marking fails clause (ii): the marked `sub_g` carries the planted
    R-point fiber `sG10`, whose swap `swG` is covered by NO marked sub — not by any honest sub
    over the real tail `[·, 5, 2, 30]` (forced `R` at slot 1 gives `T 1 = 10`, but the order
    row then needs `10 < 2`), nor by `sub_g` over its fake tail (slot 1 is `w̃ = 12 ≠ R`).
    Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe368_cmB_ambient_rejected : kvE_ambientDeepAnchorV0 qnfB = false := by
  cases hg : kvE_ambientDeepAnchorV0 qnfB with
  | false => rfl
  | true =>
    exfalso
    rw [show kvE_ambientDeepAnchorV0 qnfB
          = (Finset.univ.toList (α := NormalForm mBsig 2 4)).all (fun τ =>
              !qnfB.2 τ ||
              (Finset.univ.toList (α := NormalForm mBsig 1 5)).all (fun ρ =>
                !τ.2 ρ ||
                (Finset.univ.toList (α := NormalForm mBsig 2 4)).any (fun σ' =>
                  qnfB.2 σ' && σ'.2 (swapNF01 ρ)))) from rfl,
        List.all_eq_true] at hg
    have hτ := hg subG (kvE_nf_mem_univ_toList _)
    rw [qnfB_marks_subG, Bool.not_true, Bool.false_or, List.all_eq_true] at hτ
    have hρ := hτ sG10 (kvE_nf_mem_univ_toList _)
    rw [subG_marks_sG10, Bool.not_true, Bool.false_or, List.any_eq_true] at hρ
    obtain ⟨σ', -, hσ'⟩ := hρ
    rw [Bool.and_eq_true, swapNF01_sG10] at hσ'
    obtain ⟨hmk, hcov⟩ := hσ'
    -- `qnfB.2 σ' = true` splits: honest sub over the real tail, or `σ' = subG`
    have hsplit : (nf_characteristic MB 3 3 mBreal3).2 σ' = true ∨ σ' = subG := by
      have : ((nf_characteristic MB 3 3 mBreal3).2 σ' ||
          @decide (σ' = subG) (Classical.dec _)) = true := hmk
      rcases Bool.or_eq_true _ _ |>.mp this with h | h
      · exact Or.inl h
      · exact Or.inr (@of_decide_eq_true _ (Classical.dec _) h)
    rcases hsplit with hhon | hsub
    · -- honest σ' realized at `[x1, 5, 2, 30]`; `swG` realized over it ⇒ `T 1 = 10 ∧ T 1 < T 2`
      obtain ⟨x1, hx1⟩ := @of_decide_eq_true _ (Classical.dec _) hhon
      obtain ⟨x, hx⟩ := (hx1.2 swG).mpr hcov
      obtain ⟨h1, h2⟩ := swG_forces hx
      -- over `[x, x1, 5, 2, 30]`: slot 1 = x1, slot 2 = 5; forced `x1 = 10` yet `x1 < 5`
      rw [show (1 : Fin 5) = Fin.succ 0 from by decide] at h1 h2
      rw [show (2 : Fin 5) = Fin.succ (Fin.succ 0) from by decide] at h2
      simp only [Fin.cons_succ, Fin.cons_zero, mBreal3] at h1 h2
      omega
    · -- σ' = subG realized at the fake tail `[12, 8, 25]`; slot 1 = w̃ = 12 ≠ R = 10
      subst hsub
      obtain ⟨x, hx⟩ := ((nf_characteristic_satisfies MB 2 4 mBsubgTup).2 swG).mpr hcov
      obtain ⟨h1, -⟩ := swG_forces hx
      rw [show (1 : Fin 5) = Fin.succ 0 from by decide] at h1
      simp only [Fin.cons_succ, Fin.cons_zero, mBsubgTup] at h1
      exact absurd h1 (by omega)

/-! ## Phase 3: honest-preservation crux + readback (probe-only, general model)

The anti-vacuity guarantee. `kvE_ambientDeepAnchorV0_of_realized` proves — at a GENERAL
`OrderedMonadicStructure` and general env, one layer up from `kvE_deepOnFiber_of_realized` —
that an honestly REALIZED ambient passes the guard. Without it, task 358's re-keyed supply has
no discharge route and the restated rows-5/6/10-13 would be vacuously unservable.

### `_of_realized` witness pattern (both plan clauses, one closure)

`qnf` realized at `env`. For a marked sub `τ` (`qnf.2 τ = true`), realization supplies a fresh
point `x1` with `τ` realized at `env₁ := cons x1 env`; for a marked deep element `ρ` of `τ`
(`τ.2 ρ = true`), a fresh `x2` with `ρ` realized at `env₂ := cons x2 env₁`. By
`nf_eval_unique`, `ρ = char env₂`, so under the top-two-slot swap
`swapNF01 ρ = char (env₂ ∘ swap01) = char (cons x1 (cons x2 env))` (`swapNF01_char` +
`cons2_comp_swap01`). The **fresh-rotation mate supplied by realization** is
`σ' := char (cons x2 env)`: it is `qnf`-marked (realized at the fresh point `x2` over `env` —
clause (i), the characteristic of the witness point) and its deep marking covers `swapNF01 ρ`
(realized at `cons x1 (cons x2 env)`, a fresh extension of `σ'`'s env at `x1` — clause (ii),
anchoring from the depth-0 factorization implicit in `char`/`nf_eval_unique`). Fully general:
no countermodel obstructs, so the candidate is HONEST-PRESERVING.

### Readback discipline

`kvE_ambientDeepAnchorV0_iff` is the ONLY sanctioned mate/witness-extraction direction
(mirroring `kvE_deepOnFiber_iff`). Every downstream consumer — and gate 3b's supply-route
certificate — routes trueness through `_of_realized` and extraction through `_iff`, never
through unfolding the guard. -/

/-- **Readback for the deep arm** (alias for `kvE_ambientDeepAnchor_iff`). -/
theorem kvE_ambientDeepAnchorV0_iff {sig : MonadicSignature} {k n : Nat}
    (qnf : NormalForm sig (k + 3) n) :
    kvE_ambientDeepAnchorV0 qnf = true ↔
      ∀ τ : NormalForm sig (k + 2) (n + 1), qnf.2 τ = true →
        ∀ ρ : NormalForm sig (k + 1) (n + 2), τ.2 ρ = true →
          ∃ σ' : NormalForm sig (k + 2) (n + 1),
            qnf.2 σ' = true ∧ σ'.2 (swapNF01 ρ) = true :=
  kvE_ambientDeepAnchor_iff qnf

/-- **Honest preservation — the load-bearing crux** (alias for
    `kvE_ambientDeepAnchor_of_realized`). -/
theorem kvE_ambientDeepAnchorV0_of_realized {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    ∀ {k n : Nat} (env : Fin n → M.carrier) (qnf : NormalForm sig (k + 2) n),
      nf_eval_nf M (k + 2) n env qnf →
      kvE_ambientDeepAnchorV0 qnf = true :=
  kvE_ambientDeepAnchor_of_realized M

/-! ### Gate 3a — honest cast preservation (REAL ambient passes, derived FROM `_of_realized`) -/

/-- **Gate 3a — the REAL ambient is anchored**: `kvE_ambientDeepAnchorV0` is `true` at the
    honest ambient `char[w, x, t] = char[5, 2, 30]` (the `qnf367`-style `nf_characteristic` over
    the real anchors). Derived FROM `kvE_ambientDeepAnchorV0_of_realized` — NOT by concrete
    computation — via `nf_characteristic_satisfies`. Certifies the candidate is NOT vacuously
    false (it accepts honest ambients), the anti-vacuity guarantee the restated rows need.
    Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe368_real_ambient_anchored :
    kvE_ambientDeepAnchorV0 (nf_characteristic MB 3 3 mBreal3) = true :=
  kvE_ambientDeepAnchorV0_of_realized MB mBreal3 (nf_characteristic MB 3 3 mBreal3)
    (nf_characteristic_satisfies MB 3 3 mBreal3)

/-! ### Gate 3b — supply-feasibility shape (the discharge route task 358 will use) -/

/-- **Gate 3b — supply route certificate**: guard-trueness for a realized ambient is
    dischargeable through `_of_realized` ALONE, and the mate/witness is extractable through
    `_iff` ALONE — zero guard unfoldings. This is the exact shape task 358's re-keyed supply
    consumes: a realized ambient marks a fresh-rotation mate for every deep element of every
    marked sub. Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe368_ambient_supply_route {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {k n : Nat}
    (env : Fin n → M.carrier) (qnf : NormalForm sig (k + 3) n)
    (hqnf : nf_eval_nf M (k + 3) n env qnf) :
    ∀ τ : NormalForm sig (k + 2) (n + 1), qnf.2 τ = true →
      ∀ ρ : NormalForm sig (k + 1) (n + 2), τ.2 ρ = true →
        ∃ σ' : NormalForm sig (k + 2) (n + 1),
          qnf.2 σ' = true ∧ σ'.2 (swapNF01 ρ) = true :=
  (kvE_ambientDeepAnchorV0_iff qnf).mp
    (kvE_ambientDeepAnchorV0_of_realized M env qnf hqnf)

/-! ## Phase 4: adversarial re-plant probes, ambient side (churn record: ZERO redesign loops)

Two adapted attacks, machine-adjudicated against the candidate `kvE_ambientDeepAnchorV0` BEFORE
promotion — mirroring 367's `kvE_probe367_depth2DG_deep_rejected` (hereditary depth-2 test) and
`kvE_probe367_copyPlant_collapses` (copy-plant self-defeat), re-aimed one layer up at the AMBIENT
marking. Expected adjudication (both realized): **Gate 4a fires** — the candidate SURVIVES both
attacks; no `kvE_probe358_tailDG_*`-style refutation certificate is produced, so no redesign loop
is consumed.

### Deliverable 1 — depth-2 hereditary ambient doppelgänger (Gate 4a)

The CM-A deep-incomplete homogeneous ambient, lifted one m-level (m = 2, ambient depth 4). The
fake ambient `q2A : NormalForm mAsig 4 3` marks EXACTLY the five depth-3 subs
`{c2A (-1), …, c2A 3}` over the homogeneous model `MA` (`(ℤ, <)`, `R = ∅`), OMITTING the
completer `c2A 4` — the ambient analog of `qnfA`'s dropped `σ_A`. Because `MA` is fully
homogeneous, the `igFoldBit` profile buckets collapse at EVERY depth, so `q2A`'s marking is
indistinguishable from the honest (fully-marked) ambient at depth 0 AND depth 1 (a strictly
stronger indistinguishability than 367's `[40, 9, 8, 11]` matched zone-presence, which only
achieves depth-0/depth-1 parity). The discrepancy surfaces only two fiber layers down: the marked
sub `c2A 3` carries its depth-2 deep element `fib2A = char[t+2; t+1, w, x, t] = char[4; 3, 1, 0, 2]`,
whose top-two-slot swap `swapNF01 fib2A = gap2A = char[t+1; t+2, w, x, t] = char[3; 4, 1, 0, 2]`
is covered by NO marked `c2A v` (`v ≤ 3`). The non-coverage is the 367 `[40, 9, 8, 11]`
discrete-gap technique, ℤ-instantiated: any realizing fresh point `r` for `gap2A` over
`[·, v, 1, 0, 2]` is pinned to `2 < r < v ≤ 3` — empty over ℤ (`c2A_gap_false`), now read off a
depth-2 (rather than depth-1) characteristic. Hence `kvE_ambientDeepAnchorV0 q2A = false`
(`kvE_probe368_depth2_ambient_rejected`): the candidate's full fresh-rotation heredity fires two
levels down. Candidate survives.

### Deliverable 2 — copy-plant, ambient side (Gate 4a; self-defeat)

The strongest adapted attack: a fake ambient `qs` whose marking is manufactured to satisfy BOTH
EF-closure clauses syntactically by COPYING the honest ambient's whole marking payload
(`qs.2 = (nf_characteristic MB 3 3 mBreal3).2`). Because `kvE_ambientDeepAnchorV0` reads ONLY the
marking `qnf.2` (never the row `qnf.1`), the copy PASSES the guard outright
(`kvE_probe368_ambient_copyPlant_passes_guard`, reducing to gate 3a) — the guard alone cannot
exclude a marking-copy. The self-defeat comes from the COMPOSITION with the row/anchoring clause:
the copied marking marks the honest anchor sub `subAnchor = char[w; w, x, t] = char[5; 5, 2, 30]`,
and the on-row clause (`nfk_dropFresh subAnchor = qs.1`, the same anchoring the restated rows
impose, read through the byte-stable `nf_eval_nf0_cons_factor`/`nf_eval_unique` factorization —
no guard unfolding) pins `qs.1 = (nf_characteristic MB 3 3 mBreal3).1`. With both components
pinned, `qs = nf_characteristic MB 3 3 mBreal3` (`kvE_probe368_ambient_copyPlant_collapses`): the
construction COLLAPSES to the honest ambient — there is no adapted `qs` distinct from it. This
mirrors `kvE_probe367_copyPlant_collapses` (there admissibility's on-fiber conjunct pins the atom
layer; here the ambient on-row clause does). Candidate survives.

### Deliverable 3 — prior-family cross-check (the guard strictly shrinks the population)

`kvE_ambientDeepAnchorV0` is a NEW antecedent conjunct on the ambient `qnf` — σ-independent, a
`Bool` of `qnf.2` alone. Syntactically it references NEITHER `kvE_futAdmissible`/`kvE_pastAdmissible`
(the 363/364 exclusion engine, whose `kvE_fiberElemConsistent`/`kvE_fiberConsistent` conjuncts are
untouched) NOR `kvE_deepOnFiber` (the 367 fiber-side guard). Adding it as a conjunct at the
rows-5/6/10-13 binders therefore strictly SHRINKS the obligation population and never widens any
clause range: a σ previously excluded (inadmissible, off-row, or fiber-inconsistent) stays
excluded — admissibility and the fiber guard still gate both the population and the range
unchanged. Consequently the 363/364/367/358 exclusion certificates
(`kvE_probe363_*`, `kvE_probe364_*`, `kvE_probe367_*`, `kvE_probe358_*`, and this leaf's own
`kvE_probe368_cmA_row13_refuted`/`kvE_probe368_cmB_row5_refuted` live-countermodel records) retain
their exact statements and proofs; NONE is reopened. The cheap witnesses are the Phase-3 gates
themselves: gate 3a (`kvE_probe368_real_ambient_anchored`) shows the honest ambient is ACCEPTED
(the conjunct is not vacuously false), and gates 2a/2b (`kvE_probe368_cmA_ambient_rejected`,
`kvE_probe368_cmB_ambient_rejected`) show the two fakes are REMOVED — a strict, non-vacuous
population shrink that leaves every prior exclusion intact.

### Deliverable 4 — analytical-family closure (homogeneous / (ℚ, <) dissolution)

Every deep-incomplete or doppelgänger-marked ambient violates the fresh-rotation EF-closure at its
discrepancy layer, so the whole analytical family dissolves under the guard:

* **Deep-incomplete family (CM-A homogeneous / (ℚ, <)):** a fake ambient whose marking omits a
  bucket-mate completer necessarily omits, for some marked sub `τ` and some marked deep element `ρ`
  of `τ`, the fresh-rotation mate covering `swapNF01 ρ`. Over a homogeneous order the omitted
  completer is order-only distinguishable — the swapped element `swapNF01 ρ` pins its realizing
  fresh point into a discrete gap `(t, v)` (over ℤ: `2 < r < v ≤ 3`; over (ℚ, <) the analogous
  bounded-but-completer-specific interval) that no marked sub's env realizes, so no marked mate
  covers it and the guard reads `false`. `kvE_probe368_depth2_ambient_rejected` mechanizes this at
  fiber depth 2; `kvE_probe368_cmA_ambient_rejected` at depth 1. The ℤ casts are FINITE PROXIES of
  the homogeneous-family argument (the discrete gap `2 < r < 3` standing in for the family's
  empty completer-interval).
* **Doppelgänger family (CM-B tail-plant):** a fake ambient planting a mark `sub_g` over a
  spacing-discrepant fake tail carries a deep element (`sG10`, the R-point fiber) whose swap
  (`swG`) demands, at the swapped w-mate slot, an order/predicate configuration realizable ONLY
  over the fake tail — no marked sub over the real tail (nor `sub_g` itself) covers it, so the
  guard reads `false` (`kvE_probe368_cmB_ambient_rejected`). The discrepancy that makes the
  ambient fake IS the clause it violates: an ambient realized at `[w, x, t]` marks all realized
  fibers of all realized subs, and `kvE_ambientDeepAnchorV0_of_realized` proves such an ambient
  ALWAYS passes — so any ambient failing the guard is provably NOT realized at `[w, x, t]`, and
  every fake of the family (whose discrepancy is exactly a missing/misplaced realized mate) fails.

Both families reduce to the one closure the guard enforces, and the honest-preservation crux
`kvE_ambientDeepAnchorV0_of_realized` guarantees no honest ambient is caught in the dissolution. -/

/-! ### Deliverable 1: depth-2 hereditary ambient doppelgänger (homogeneous `MA`, m = 2) -/

/-- The honest depth-3 4-type `char[v, w, x, t]` (the m = 2 sub level: `c2A v` is the depth-lift
    of the Phase-1 `cA v`, carrying a full deep marking one layer richer). -/
private noncomputable def c2A (v : ℤ) : NormalForm mAsig 3 4 :=
  nf_characteristic MA 3 4 (Fin.cons v mAenv3)

/-- The m = 2 FAKE ambient `q2A` (ambient depth 4): honest depth-0 row of `[w, x, t]`; deep marking
    EXACTLY the five depth-3 subs `{c2A (-1), c2A 0, c2A 1, c2A 2, c2A 3}`, OMITTING `c2A 4` — the
    depth-lifted deep-incomplete marking. Homogeneous (`R = ∅`), so the profile buckets collapse
    at every depth: depth-0 AND depth-1 indistinguishable from the honest ambient. -/
private noncomputable def q2A : NormalForm mAsig 4 3 :=
  NormalForm.step (nf_characteristic MA 4 3 mAenv3).1
    (fun τ => @decide (τ = c2A (-1) ∨ τ = c2A 0 ∨ τ = c2A 1 ∨ τ = c2A 2 ∨ τ = c2A 3)
      (Classical.dec _))

/-- The marked sub's inner `[t+2]`-fiber, one layer deeper than `fibA34`:
    `char[t+2; t+1, w, x, t] = char[4; 3, 1, 0, 2]` at depth 2. Its top-two-slot swap is `gap2A`. -/
private noncomputable def fib2A : NormalForm mAsig 2 5 :=
  nf_characteristic MA 2 5 (Fin.cons 4 (Fin.cons 3 mAenv3))

/-- The depth-2 separating deep element (the swap target no marked sub covers):
    `char[t+1; t+2, w, x, t] = char[3; 4, 1, 0, 2]`, one layer deeper than `gapA`. -/
private noncomputable def gap2A : NormalForm mAsig 2 5 :=
  nf_characteristic MA 2 5 (Fin.cons 3 (Fin.cons 4 mAenv3))

/-- `c2A 3` is `q2A`-marked (the fifth listed sub). -/
private theorem q2A_marks_c2A3 : q2A.2 (c2A 3) = true :=
  @decide_eq_true _ (Classical.dec _) (Or.inr (Or.inr (Or.inr (Or.inr rfl))))

/-- `c2A 3` marks its own inner `[t+2]`-fiber `fib2A` (honest witness: the point `4 = t+2` above
    `3 = t+1`), one fiber layer deeper than `cA3_marks_fibA34`. -/
private theorem c2A3_marks_fib2A : (c2A 3).2 fib2A = true :=
  @decide_eq_true _ (Classical.dec _)
    ⟨4, nf_characteristic_satisfies MA 2 5 (Fin.cons 4 (Fin.cons 3 mAenv3))⟩

/-- The swap of `c2A 3`'s inner `[t+2]`-fiber IS `gap2A` — the depth-2 separating deep element no
    marked `c2A v` (`v ≤ 3`) covers. Via `swapNF01_char` + the concrete environment swap (the
    depth-2 analog of `swapNF01_fibA34`). -/
private theorem swapNF01_fib2A : swapNF01 fib2A = gap2A := by
  have hE : (Fin.cons (4 : ℤ) (Fin.cons 3 mAenv3)) ∘ ⇑(Equiv.swap (0 : Fin 5) 1)
      = Fin.cons 3 (Fin.cons 4 mAenv3) := by
    funext i
    fin_cases i <;> rfl
  show swapNF01 (nf_characteristic MA 2 5 (Fin.cons 4 (Fin.cons 3 mAenv3))) = gap2A
  rw [swapNF01_char MA, hE]
  rfl

/-- NO `c2A v` with `v ≤ 3` covers `gap2A`: reading `gap2A`'s (fresh, v-slot) and (t-slot, fresh)
    order rows off the depth-2 characteristic pins any realizing fresh point `r` to `2 < r < v ≤ 3`
    — empty over ℤ. The 367 `[40, 9, 8, 11]` discrete gap, ℤ-instantiated one fiber layer deeper
    than `cA_gap_false`. -/
private theorem c2A_gap_false (v : ℤ) (hv : v ≤ 3) : (c2A v).2 gap2A = false := by
  refine @decide_eq_false _ (Classical.dec _) ?_
  rintro ⟨r, hr⟩
  -- gap2A's (fresh, v-slot) row: `3 < 4` at the defining tuple — evaluated, `r < v`
  have hord1 := hr.1 (.order 0 ⟨1, by decide⟩ (by decide))
  have h1 : @LT.lt ℤ _ r v := hord1.mpr
    (@decide_eq_true _ (Classical.dec _) (show (3:ℤ) < 4 by omega))
  -- gap2A's (t-slot, fresh) row: `2 < 3` at the defining tuple — evaluated, `2 < r`
  have hord2 := hr.1 (.order ⟨4, by decide⟩ 0 (by decide))
  have h2 : (2:ℤ) < r := hord2.mpr
    (@decide_eq_true _ (Classical.dec _) (show (2:ℤ) < 3 by omega))
  omega

/-- **Gate 4a (Deliverable 1) — the depth-2 hereditary ambient doppelgänger is EXCLUDED by the
    candidate guard**: `kvE_ambientDeepAnchorV0 q2A = false`. Depth-0 AND depth-1 indistinguishable
    from the honest ambient (homogeneous bucket collapse), yet the candidate's full fresh-rotation
    heredity fires two fiber layers down: the marked `c2A 3` carries `fib2A`, whose swap `gap2A` is
    covered by NO marked sub (the completer `c2A 4` was dropped, and no `c2A v` with `v ≤ 3` covers
    `gap2A` — `c2A_gap_false`). The candidate SURVIVES the hereditary re-plant; no redesign loop.
    Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe368_depth2_ambient_rejected : kvE_ambientDeepAnchorV0 q2A = false := by
  cases hg : kvE_ambientDeepAnchorV0 q2A with
  | false => rfl
  | true =>
    exfalso
    -- unfold the m = 2 (ambient-depth-4) arm to the outer `.all`
    rw [show kvE_ambientDeepAnchorV0 q2A
          = (Finset.univ.toList (α := NormalForm mAsig 3 4)).all (fun τ =>
              !q2A.2 τ ||
              (Finset.univ.toList (α := NormalForm mAsig 2 5)).all (fun ρ =>
                !τ.2 ρ ||
                (Finset.univ.toList (α := NormalForm mAsig 3 4)).any (fun σ' =>
                  q2A.2 σ' && σ'.2 (swapNF01 ρ)))) from rfl,
        List.all_eq_true] at hg
    have hτ := hg (c2A 3) (kvE_nf_mem_univ_toList _)
    rw [q2A_marks_c2A3, Bool.not_true, Bool.false_or, List.all_eq_true] at hτ
    have hρ := hτ fib2A (kvE_nf_mem_univ_toList _)
    rw [c2A3_marks_fib2A, Bool.not_true, Bool.false_or, List.any_eq_true] at hρ
    obtain ⟨σ', -, hσ'⟩ := hρ
    rw [Bool.and_eq_true, swapNF01_fib2A] at hσ'
    obtain ⟨hmk, hcov⟩ := hσ'
    have hd : σ' = c2A (-1) ∨ σ' = c2A 0 ∨ σ' = c2A 1 ∨ σ' = c2A 2 ∨ σ' = c2A 3 :=
      @of_decide_eq_true _ (Classical.dec _) hmk
    have hfalse : ∀ v : ℤ, v ≤ 3 → σ' = c2A v → False := by
      intro v hv h
      rw [h, c2A_gap_false v hv] at hcov
      exact Bool.noConfusion hcov
    rcases hd with h | h | h | h | h
    · exact hfalse (-1) (by omega) h
    · exact hfalse 0 (by omega) h
    · exact hfalse 1 (by omega) h
    · exact hfalse 2 (by omega) h
    · exact hfalse 3 (by omega) h

/-! ### Deliverable 2: copy-plant, ambient side (marking payload copy) -/

/-- The honest anchor sub `char[w; w, x, t] = char[5; 5, 2, 30]` — a `qnfBreal`-marked sub of the
    honest ambient, realized at its own fresh point `w = 5`. The pivot of the copy collapse. -/
private noncomputable def subAnchor : NormalForm mBsig 2 4 :=
  nf_characteristic MB 2 4 (Fin.cons 5 mBreal3)

/-- The honest ambient marks `subAnchor` (realized at the fresh point `w = 5`). -/
private theorem qnfBreal_marks_subAnchor :
    (nf_characteristic MB 3 3 mBreal3).2 subAnchor = true :=
  @decide_eq_true _ (Classical.dec _)
    ⟨5, nf_characteristic_satisfies MB 2 4 (Fin.cons 5 mBreal3)⟩

/-- `subAnchor` is on the honest ambient's row: its dropped atom row is the honest depth-0 row of
    `[w, x, t]` (the depth-0 factorization + uniqueness route, the ambient analog of
    `sigmaA_on_row`). -/
private theorem subAnchor_on_row :
    nfk_dropFresh subAnchor = (nf_characteristic MB 3 3 mBreal3).1 := by
  have hatom := nf_eval_nf_atom_layer MB _ subAnchor
    (nf_characteristic_satisfies MB 2 4 (Fin.cons 5 mBreal3))
  have hfac := (nf_eval_nf0_cons_factor MB mBreal3 5 subAnchor.atom_assgn).mp hatom
  exact nf_eval_unique MB 0 3 mBreal3 _ _ hfac.2.2
    (nf_eval_nf_atom_layer MB mBreal3 (nf_characteristic MB 3 3 mBreal3)
      (nf_characteristic_satisfies MB 3 3 mBreal3))

/-- **Copy-plant self-defeat, part 1 — the marking copy PASSES the guard**: since
    `kvE_ambientDeepAnchorV0` reads ONLY the marking `qnf.2` (never the row `qnf.1`), any `qs`
    copying the honest ambient's whole marking payload passes the guard, reducing to gate 3a
    (`kvE_probe368_real_ambient_anchored`). The guard ALONE cannot exclude a marking-copy — the
    exclusion must come from the composition with the row/anchoring clause (part 2). Sorry-free;
    axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe368_ambient_copyPlant_passes_guard (qs : NormalForm mBsig 3 3)
    (hcopy : qs.2 = (nf_characteristic MB 3 3 mBreal3).2) :
    kvE_ambientDeepAnchorV0 qs = true := by
  rw [show kvE_ambientDeepAnchorV0 qs
        = (Finset.univ.toList (α := NormalForm mBsig 2 4)).all (fun τ =>
            !qs.2 τ ||
            (Finset.univ.toList (α := NormalForm mBsig 1 5)).all (fun ρ =>
              !τ.2 ρ ||
              (Finset.univ.toList (α := NormalForm mBsig 2 4)).any (fun σ' =>
                qs.2 σ' && σ'.2 (swapNF01 ρ)))) from rfl,
      hcopy]
  exact kvE_probe368_real_ambient_anchored

/-- **Gate 4a (Deliverable 2) — the copy-plant COLLAPSES to the honest ambient**: any `qs` that
    copies the honest ambient's whole marking payload (`qs.2 = qnfBreal.2`, manufacturing
    guard-trueness — part 1) and passes the on-row anchoring clause (`nfk_dropFresh subAnchor =
    qs.1`, the same anchoring the restated rows impose) IS the honest ambient. Self-defeat channel:
    the copied marking marks the honest anchor sub `subAnchor` (`qnfBreal_marks_subAnchor`), whose
    dropped row is the honest ambient's own atom layer (`subAnchor_on_row`, read through the
    byte-stable `nf_eval_nf0_cons_factor`/`nf_eval_unique` factorization — no guard unfolding),
    forcing `qs.1 = qnfBreal.1`. With both components pinned there is no adapted `qs` distinct from
    the honest ambient. The ambient analog of `kvE_probe367_copyPlant_collapses`. Sorry-free;
    axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe368_ambient_copyPlant_collapses (qs : NormalForm mBsig 3 3)
    (hcopy : qs.2 = (nf_characteristic MB 3 3 mBreal3).2)
    (hrow : nfk_dropFresh subAnchor = qs.1) :
    qs = nf_characteristic MB 3 3 mBreal3 :=
  Prod.ext (hrow.symm.trans subAnchor_on_row) hcopy

end Bimodal.Metalogic.WeakCanonical.Kamp
