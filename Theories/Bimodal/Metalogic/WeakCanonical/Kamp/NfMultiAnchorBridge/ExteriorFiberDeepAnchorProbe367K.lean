import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorConverterK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberDeepAnchorK

/-! # Task 367 probe leaf: the hereditary deep-anchor guard vs the tail-doppelgänger

Machine-adjudicates the task-367 candidate deep-anchor guard `kvE_deepOnFiber` BEFORE any
production edit (the 363/364 probe-first methodology). The guard anchors the rows-8-9
obligation population (`_hsliceFut`/`_hslicePast`, `EndIntervalConsumerK.lean:154-167`) to the
ambient `qnf` one layer beyond the depth-0 row check `nfk_dropFresh σ = qnf.1` — the ONLY
antecedent the 358 tail-doppelgänger (`ExteriorPinnedProbe358TailK.lean`) needed to defeat.

## Adjudicated candidate (synthesis of handoff candidates (a) and (b))

`kvE_deepOnFiber qnf σ` (fiber depth graded on σ's depth `k`):
- `k = 0` and `k = 1`: `decide (nfk_dropFresh σ = qnf.1)` — the depth-0 row check ONLY.
  The `k = 1` arm is the m = 0 instance of the rows-8-9 binders: the guard is
  DEFINITIONALLY the old antecedent there (`kvE_deepOnFiber_zero`, `rfl`), so the frozen
  m = 0 supply layer (task 360) discharges the restated binders through a proof-script
  adapter and the m = 0 bracket range is byte-value-identical.
- `k = j + 2`: row check `&&` a **qnf-marked deep-content mate**: some `σ'` with
  `qnf.2 σ' = true` carries EXACTLY σ's whole deep marking (`σ'.2 = σ.2`). Full `.2`
  equality compares σ's marked-fiber content at EVERY depth simultaneously — hereditary to
  depth 0 by construction, NOT a single extra level (plan Risk 1). This resolves the
  depth/arity bookkeeping of candidate (a) (plan Risk 2) without any deep slot-drop
  operation: the mate is compared at σ's own type `NormalForm sig (j+2) (n+1)`, the type
  `qnf.2` already marks.

Candidate (a)-literal (recursive one-slot-dropped fiber matching) was REJECTED on paper
before probing: dropping the x1 slot from a fiber `s : NormalForm sig m 5` crosses a
depth+arity offset with no existing operation, and any per-level recursion is subsumed by
full `.2` equality, which is strictly stronger, `rfl`-cheap to state, and directly
falsifiable by the 358 cast. Candidate (b)-literal (a raw semantic condition at the binder)
was rejected because the binders quantify a syntactic `σ` population; the guard must be a
`Bool` over the NF fintype to key the bracket range (`ExteriorBracketAssembleK.lean`).

## Consumption-site map (Phase 1; the authoritative Phase-4 edit boundary)

STATEMENT-TOUCHING (per the rows-8-9 restatement):
1. `EndIntervalConsumerK.lean` — rows 8-9 binders `_hslicePast`/`_hsliceFut` (:154-167):
   antecedent `nfk_dropFresh σ = qnf.1` REPLACED by `kvE_deepOnFiber qnf σ = true` (the
   guard subsumes the row via `kvE_deepOnFiber_row`); rows 10-11 `_hexclSlice*` BYTE-STABLE;
   NEW rows 12-13 `_hexclDeep*` (⇒-side residue for on-row guard-false σ, igPtW-guarded,
   m = 0-VACUOUS since guard ≡ row at fiber depth 1); `endInterval_step_correct` threading.
2. `ExteriorGateAssembleK.lean` — `bracketEndChar_kvExt_correct_prior`: `hslice*` binders
   restated, `hexclSlice*` byte-stable, NEW `hexclDeep*` binders; ⇒-side `hexclExt`
   discharge re-cased (off-row → offForce unchanged; on-row+guard-true → D1/`hexclSlice*`;
   on-row+guard-false → `hexclDeep*`); ⇐-side passes the restated `hslice*` through.
3. `ExteriorBracketAssembleK.lean` — bracket range filters re-keyed
   (`decide (nfk_dropFresh σ = qnf.1)` ↦ `kvE_deepOnFiber qnf σ`), `_iff` lemmas, D1/D2
   soundness (guard antecedent replaces row), D3/D4 completeness `hslice` binders restated.
   PLAN DEVIATION (altered, recorded): this file is added to the plan's Phase-4 list. It is
   FORCED: (i) the rows-8-9 binders are passed whole to D3/D4 (`ExteriorGateAssembleK:328/
   :344`), so the D3/D4 `hslice` binder types must change identically; (ii) D3/D4's
   slice-unmarked branch applies `hslice` to arbitrary range σ, so the RANGE must carry the
   guard; (iii) independently, the un-re-keyed bracket FORMULA is honestly unsatisfiable at
   m ≥ 1 — the tail-doppelgänger σ is in the row-keyed range, slice-UNMARKED (its marked
   deep fiber is never qnf-marked), so its conjunct is `¬ kvE_futPos σ` while `kvE_futPos σ`
   fires at the honest anchor (the 358TailK analytical closure) — no binder reshuffle can
   fix a false conjunct; the fake σ must carry NO clause. The file is NOT in the frozen set
   (frozen = 363/364 files, `ExteriorNegation{,Past}K`, `ExteriorPinnedConverse{,Past}K`
   kernels/slice-defs/m = 0 supply, k ≤ 1 rungs — all byte-stable).
4. `KampPrior.lean` — `kampPrior_site_rungK_gate_match` (:941): mechanical binder mirror +
   pass-through. The `:519`/`:522` sorries are UNTOUCHED (358 territory).

PROOF-SCRIPT-ONLY / FROZEN:
- `ExteriorPinnedConverse{,Past}K.lean` — m = 0 supply (`kvE_hslice*_supply_zero`,
  `kvE_hexclSlice*_supply_zero`, `kvE_{fut,past}SliceId_of_end_zero`), slice defs
  (`kvE_{fut,past}SliceEq/Marked`), kernels: byte-stable. The m = 0 supply is currently
  consumed NOWHERE outside its home files (verified by grep), so no live discharge site
  needs repair; future m = 0 discharge routes through `kvE_deepOnFiber_zero`.
- `ExteriorNegation{,Past}K.lean`, `ExteriorFiberConsistencyK.lean` + probe files: frozen.

## Analytical-family closure ((ℚ, <) homogeneity; Phase 3 record)

The 358TailK binder-level closure family (dense order, one discrepantly-placed R-point,
automorphism homogeneity firing the whole `hsliceFut` antecedent stack for the pure fake
characteristic σ) DISSOLVES under the guard: σ's marked deep fiber (the fake-gap walk type)
carries the fake coupling vector at the discrepancy layer, i.e. it marks an inner witness
demanding an R-point in a zone that is R-empty relative to the REAL tail. Any `σ'` with
`σ'.2 = σ.2` marks that same fiber, so a realization of `σ'` over the real tail would
pin-realize the fiber and its inner witness — contradiction at the discrepancy layer
(exactly the `m3_noPinned` chase below, which is model-generic in shape: it consumes only
the marked witness's atom rows, never density or homogeneity). Hence NO qnf-marked σ'
carries σ's deep marking, `kvE_deepOnFiber qnf σ = false`, and σ is OUTSIDE the restated
rows-8-9 population. Every fake characteristic of the family marks such a fiber (the
discrepancy is what makes it fake), so the whole family is excluded; the mechanized ℤ casts
(gates 1a and 3a) are finite proxies of exactly this argument.

## Prior-family cross-check (Phase 3 record)

The guard is a NEW antecedent conjunct at the rows-8-9 binders and a NEW conjunct in the
bracket range filter: it strictly SHRINKS the obligation population and the clause range.
The 363/364 exclusion mechanisms (`kvE_fiberElemConsistent` inside `kvE_{fut,past}Admissible`
conjunct 2) are untouched — admissibility is unchanged, so `kvE_probe363_*`,
`kvE_probe364_*`, and `kvE_probe358_eP_atomMate_present` retain their exact statements and
proofs (frozen files, re-verified at Phase 5). A previously-excluded σ (inadmissible) stays
excluded: admissibility still gates both the population and the range. The 358 tail records
(`kvE_probe358_tailDG_*`) remain TRUE statements about the OLD depth-0 anchor and keep
compiling byte-stable as the permanent regression record.

Probe conventions: template copies of `ExteriorPinnedProbe358TailK.lean` (model shape,
private cast replication precedent, public certificates). Purely additive NEW leaf; no
production file is touched by Phases 1-3. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## The guard (Phase 4 rewire: certificates below certify the PRODUCTION definition
`kvE_deepOnFiber` from `ExteriorFiberDeepAnchorK.lean`, to which the Phase-1 candidate
`kvE_deepOnFiber` was promoted verbatim — exactly one live definition exists; this leaf
is the permanent regression record, per the 363/364 probe-module precedent). -/

/-! ## Probe cast (template copy of `ExteriorPinnedProbe358TailK.lean`; replication
precedent for `private` originals) -/

/-- One-predicate signature for the probe (the deep marker `R`). -/
private abbrev m3sig : MonadicSignature := { preds := Unit }

/-- The probe model `(ℤ, <)` with `R = {10}`. -/
private abbrev M3M : OrderedMonadicStructure m3sig where
  carrier := ℤ
  interp := fun _ z => z = 10
  carrier_order := inferInstance

/-- REAL ambient anchors `[w, x, t] = [5, 2, 30]`. -/
private def m3realEnv3 : Fin 3 → M3M.carrier := Fin.cons 5 (Fin.cons 2 (fun _ => 30))

/-- REAL pinned anchors `[x1, w, x, t] = [35, 5, 2, 30]` (chain `2 < 5 < 30 < 35`). -/
private def m3realEnv : Fin 4 → M3M.carrier := Fin.cons 35 m3realEnv3

/-- FAKE (doppelgänger) tail `[x̃1, w̃, x̃, t̃] = [40, 12, 8, 25]` — depth-0
    indistinguishable from the real anchors; the R-point `10` lies in `(x̃, w̃) = (8, 12)`
    fake-interiorly vs `(w, t) = (5, 30)` real-interiorly. -/
private def m3fakeEnv : Fin 4 → M3M.carrier :=
  Fin.cons 40 (Fin.cons 12 (Fin.cons 8 (fun _ => 25)))

/-- The walk point `r = 32` over the fake tail (in the real gap `(30, 35)` AND the fake gap
    `(25, 40)`). -/
private def m3tup5 : Fin 5 → M3M.carrier := Fin.cons 32 m3fakeEnv

/-- The depth-1 fiber element: the honest complete depth-1 5-type of the walk point `32`
    over the FAKE tail. -/
private noncomputable def m3s : NormalForm m3sig 1 5 := nf_characteristic M3M 1 5 m3tup5

/-- The separating inner witness: the depth-0 6-type of the R-point `10` over `(32; fake)`.
    Its (fresh, w-slot) order row reads `10 < 12` fake-side — pinned over the real tail it
    demands an R-point strictly below `w = 5`, and `R ∩ (-∞, 5) = ∅`. -/
private noncomputable def m3eR : NormalForm m3sig 0 6 :=
  nf_characteristic M3M 0 6 (Fin.cons 10 m3tup5)

/-- The fake-tail slice: the honest complete depth-2 4-type of the FAKE tuple — realized
    in-model, admissible, on the real row (`kvE_probe358_tailDG_sigma_in_population`), and
    the exact σ the restated rows 8-9 must EXCLUDE. -/
private noncomputable def m3sigma : NormalForm m3sig 2 4 := nf_characteristic M3M 2 4 m3fakeEnv

/-- The REAL ambient: the depth-3 3-type of `[w, x, t] = [5, 2, 30]` (the `qnf` shape of the
    rows-8-9 binders at m = 1). -/
private noncomputable def qnf367 : NormalForm m3sig 3 3 := nf_characteristic M3M 3 3 m3realEnv3

/-- `m3sigma` marks the un-pinnable fake walk fiber (replicated cast fact). -/
private theorem m3sigma_marks_s : m3sigma.2 m3s = true :=
  @decide_eq_true _ (Classical.dec _) ⟨32, nf_characteristic_satisfies M3M 1 5 m3tup5⟩

/-- `m3s` marks the separating inner witness `m3eR` (replicated cast fact). -/
private theorem m3s_marks_eR : m3s.2 m3eR = true :=
  @decide_eq_true _ (Classical.dec _)
    ⟨10, nf_characteristic_satisfies M3M 0 6 (Fin.cons 10 m3tup5)⟩

/-! ## Gate 1a: the tail-doppelgänger is deep-rejected -/

/-- **Gate 1a — the tail-doppelgänger fails the deep anchor w.r.t. the real ambient.**
    The fake slice `m3sigma` — admissible through the sanctioned byte-stable route, depth-0
    on-row, and qnf-marking-refuting (`kvE_probe358_tailDG_*`) — is OUTSIDE the deep-anchored
    population: any `σ'` with `σ'.2 = m3sigma.2` marks the fake walk fiber `m3s`, whose
    marked inner witness `m3eR` demands an R-point strictly below the w-slot; over the real
    tail `R ∩ (-∞, 5) = ∅`, so no such `σ'` is realizable over `[5, 2, 30]` at any `x1` —
    i.e. no such `σ'` is `qnf367`-marked. Sorry-free; axioms
    `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe367_tailDG_deep_rejected :
    kvE_deepOnFiber qnf367 m3sigma = false := by
  cases hg : kvE_deepOnFiber qnf367 m3sigma with
  | false => rfl
  | true =>
    exfalso
    obtain ⟨-, σ', hmk, heq⟩ := (kvE_deepOnFiber_iff qnf367 m3sigma).mp hg
    -- qnf367-marked ⟹ σ' realized over the real tail at some x1
    obtain ⟨x1, hσ'⟩ : ∃ x1 : M3M.carrier,
        nf_eval_nf M3M 2 4 (Fin.cons x1 m3realEnv3) σ' :=
      @of_decide_eq_true _ (Classical.dec _) hmk
    -- σ' carries the fake deep marking, hence marks the fake walk fiber m3s
    have hs : σ'.2 m3s = true := by rw [heq]; exact m3sigma_marks_s
    obtain ⟨r, hr⟩ := (hσ'.2 m3s).mpr hs
    -- m3s marks the separating inner witness m3eR
    obtain ⟨u, hu⟩ := (hr.2 m3eR).mpr m3s_marks_eR
    -- the inner witness carries R (fresh-slot predicate row of m3eR)
    have hu10 : u = 10 :=
      (hu (.pred () 0)).mpr (@decide_eq_true _ (Classical.dec _) (rfl : (10:ℤ) = 10))
    -- m3eR's (fresh, w-slot) order row: `10 < 12` fake-side — pinned it reads `u < 5`
    have hord := hu (.order 0 ⟨3, by omega⟩ (by decide))
    have hlt : u < (5:ℤ) := hord.mpr
      (@decide_eq_true _ (Classical.dec _) (show (10:ℤ) < 12 by omega))
    have h105 : ¬ ((10:ℤ) < (5:ℤ)) := by omega
    rw [hu10] at hlt
    exact h105 hlt

/-! ## Phase 2: honest-preservation crux — Phase 4 rewire note

The honest-preservation crux `kvE_deepOnFiber_of_realized` (general model, general
signature) was proven HERE at probe level in Phase 2 and promoted verbatim to the
production module (`ExteriorFiberDeepAnchorK.lean`); gate 2a below now derives from the
production lemma directly (exactly one live proof). -/

/-- The honest REAL slice (the depth-2 4-type of the real pinned tuple `[35, 5, 2, 30]`). -/
private noncomputable def m3sigmaReal : NormalForm m3sig 2 4 := nf_characteristic M3M 2 4 m3realEnv

/-- **Gate 2a — honest cast preservation, derived FROM `_of_realized`** (not by concrete
    computation): the real slice passes the deep anchor w.r.t. the real ambient. Together
    with gate 1a this machine-separates fake from honest at the restated rows-8-9 interface.
    Gate 2b (supply-feasibility shape) is witnessed by the derivation itself: the guard for
    a realizer-derived σ is discharged through `kvE_deepOnFiber_of_realized` alone — no
    guard unfolding anywhere outside the guard's home extraction lemmas. Sorry-free; axioms
    `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe367_real_slice_deep_anchored :
    kvE_deepOnFiber qnf367 m3sigmaReal = true :=
  kvE_deepOnFiber_of_realized M3M m3realEnv3 35 qnf367 m3sigmaReal
    (nf_characteristic_satisfies M3M 3 3 m3realEnv3)
    (nf_characteristic_satisfies M3M 2 4 m3realEnv)

/-! ## Phase 3: adversarial re-plant (churn record: ZERO redesign loops consumed)

Two adapted attacks, machine-adjudicated against the candidate BEFORE promotion. The
prior-family cross-check and the (ℚ, <) analytical-family closure are recorded in the
module docstring (the guard strictly shrinks the population; admissibility — the 363/364
exclusion engine — is untouched). -/

/-- **Depth-2 doppelgänger cast** (the mandatory hereditary test, plan Risk 1): fake tail
    `[x̃1, w̃, x̃, t̃] = [40, 9, 8, 11]` — same depth-0 row pattern as the real anchors
    (chain, all R-free) and the SAME depth-1 zone-presence pattern (the R-point `10` sits in
    the `(w̃, t̃) = (9, 11)` interior zone exactly as `10 ∈ (w, t) = (5, 30)` real-side; all
    other zones R-empty on both sides). The discrepancy is visible only TWO fiber layers
    down: over ℤ there is NO point strictly between `w̃ = 9` and the R-point `10` (nor
    between `10` and `t̃ = 11`), while real-side `(5, 10)` and `(10, 30)` are inhabited. -/
private def fake2Env : Fin 4 → M3M.carrier :=
  Fin.cons 40 (Fin.cons 9 (Fin.cons 8 (fun _ => 11)))

/-- The m = 2 ambient: the depth-4 3-type of the real anchors `[5, 2, 30]`. -/
private noncomputable def q2nf : NormalForm m3sig 4 3 := nf_characteristic M3M 4 3 m3realEnv3

/-- The depth-2 fake slice: the honest complete depth-3 4-type of the depth-2 fake tuple. -/
private noncomputable def sigma2 : NormalForm m3sig 3 4 := nf_characteristic M3M 3 4 fake2Env

/-- The carrier of the depth-2 discrepancy: the depth-2 5-type of the R-point `10` itself
    over the fake tail. Its OWN marked depth-1 fiber layer records "no point strictly
    between the w-slot and the fresh R-point" — false over the real tail. -/
private noncomputable def s10 : NormalForm m3sig 2 5 :=
  nf_characteristic M3M 2 5 (Fin.cons 10 fake2Env)

/-- `sigma2` marks the discrepancy carrier (cast fact; witness: the R-point `10`). -/
private theorem sigma2_marks_s10 : sigma2.2 s10 = true :=
  @decide_eq_true _ (Classical.dec _)
    ⟨10, nf_characteristic_satisfies M3M 2 5 (Fin.cons 10 fake2Env)⟩

/-- **Gate 3a — the depth-2 doppelgänger is deep-rejected (candidate survives; the
    hereditary recursion fires two levels down).** Any `σ'` with `σ'.2 = sigma2.2` marks
    `s10`; a realization of `σ'` over the real tail pins `s10` at `(10, x1, 5, 2, 30)`
    (the fresh slot carries `R`, forcing the value `10`), and then `s10`'s realized fiber
    layer must mark the depth-1 6-type of the point `7 ∈ (w, 10) = (5, 10)` — but `s10`'s
    SYNTACTIC fiber layer (decided over the fake tail) rejects every 6-type whose fresh
    point lies strictly between the w-slot and the R-point, since `(w̃, 10) = (9, 10)` is
    empty over ℤ. So no `σ'` carrying the fake deep content is `q2nf`-marked: the depth-2
    fake fails the guard. Depth-0 AND depth-1 row/zone parity make this invisible to both
    the old row check and any single-extra-level anchor — full-`.2` heredity is what fires.
    Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe367_depth2DG_deep_rejected :
    kvE_deepOnFiber q2nf sigma2 = false := by
  cases hg : kvE_deepOnFiber q2nf sigma2 with
  | false => rfl
  | true =>
    exfalso
    obtain ⟨-, σ', hmk, heq⟩ := (kvE_deepOnFiber_iff q2nf sigma2).mp hg
    obtain ⟨x1, hσ'⟩ : ∃ x1 : M3M.carrier,
        nf_eval_nf M3M 3 4 (Fin.cons x1 m3realEnv3) σ' :=
      @of_decide_eq_true _ (Classical.dec _) hmk
    -- σ' carries the fake deep marking, hence marks the discrepancy carrier s10
    have hs : σ'.2 s10 = true := by rw [heq]; exact sigma2_marks_s10
    obtain ⟨r, hr⟩ := (hσ'.2 s10).mpr hs
    -- the fresh slot of s10 carries R: the pinned witness is the R-point 10
    have hr10 : r = 10 :=
      (hr.1 (.pred () 0)).mpr (@decide_eq_true _ (Classical.dec _) (rfl : (10:ℤ) = 10))
    subst hr10
    -- the depth-1 6-type of the interpolant 7 ∈ (5, 10) over the PINNED tuple
    -- is realized there, so s10's fiber layer must mark it …
    have h7 : s10.2 (nf_characteristic M3M 1 6
        (Fin.cons 7 (Fin.cons 10 (Fin.cons x1 m3realEnv3)))) = true :=
      (hr.2 _).mp ⟨7, nf_characteristic_satisfies M3M 1 6 _⟩
    -- … but syntactically s10's fiber layer rejects it: over the fake tail the zone
    -- `(w̃, r) = (9, 10)` is empty in ℤ.
    have h7f : s10.2 (nf_characteristic M3M 1 6
        (Fin.cons 7 (Fin.cons 10 (Fin.cons x1 m3realEnv3)))) = false := by
      refine @decide_eq_false _ (Classical.dec _) ?_
      rintro ⟨z', hz'⟩
      -- pinned row (fresh, R-slot): 7 < 10 — fake-side it reads z' < 10
      have hord1 := hz'.1 (.order 0 ⟨1, by omega⟩ (by decide))
      have h1 : z' < (10:ℤ) := hord1.mpr
        (@decide_eq_true _ (Classical.dec _) (show (7:ℤ) < 10 by omega))
      -- pinned row (w-slot, fresh): 5 < 7 — fake-side it reads 9 < z'
      have hord2 := hz'.1 (.order ⟨3, by omega⟩ 0 (by decide))
      have h2 : (9:ℤ) < z' := hord2.mpr
        (@decide_eq_true _ (Classical.dec _) (show (5:ℤ) < 7 by omega))
      -- the discrete gap: no integer lies strictly between 9 and 10
      have hgap : ∀ y : ℤ, 9 < y → y < 10 → False := by omega
      exact hgap z' h2 h1
    rw [h7] at h7f
    exact Bool.noConfusion h7f

/-! ### The content-copying plant (the strongest adapted attack) -/

/-- A σ-marked honest fiber of the real slice (the walk point `32` over the REAL pinned
    tuple) — the nonempty-marking witness the plant collapse pivots on. -/
private noncomputable def s32 : NormalForm m3sig 1 5 :=
  nf_characteristic M3M 1 5 (Fin.cons 32 m3realEnv)

/-- The real slice marks its own walk fiber (cast fact). -/
private theorem m3sigmaReal_marks_s32 : m3sigmaReal.2 s32 = true :=
  @decide_eq_true _ (Classical.dec _)
    ⟨32, nf_characteristic_satisfies M3M 1 5 (Fin.cons 32 m3realEnv)⟩

/-- **Gate 3 (content-copying plant) — the copy construction is IMPOSSIBLE**: any σ★ that
    copies the real slice's whole deep marking (`σ★.2 = m3sigmaReal.2`, manufacturing
    guard-trueness with mate `m3sigmaReal`) and passes admissibility IS the real slice.
    Self-defeat channel: the copied marking is nonempty (it marks the real walk fiber
    `s32`), and admissibility's on-fiber conjunct (task 363/364, read through the
    byte-stable extraction `kvE_futAdmissible_onFiber` — no unfolding) forces
    `σ★.1 = nfk_dropFresh s32 = m3sigmaReal.1`. A fake-tail realizer therefore cannot host
    the copy: there is no adapted σ★ distinct from the honest slice. Sorry-free; axioms
    `[propext, Classical.choice, Quot.sound]`. -/
theorem kvE_probe367_copyPlant_collapses (σs : NormalForm m3sig 2 4)
    (hcopy : σs.2 = m3sigmaReal.2) (hadm : kvE_futAdmissible σs = true) :
    σs = m3sigmaReal := by
  -- the copied marking marks the real walk fiber
  have hmark : σs.2 s32 = true := by rw [hcopy]; exact m3sigmaReal_marks_s32
  -- admissibility's on-fiber conjunct pins σs's atom layer to the fiber's dropped row
  have hfib : nfk_dropFresh s32 = σs.1 := kvE_futAdmissible_onFiber σs hadm s32 hmark
  -- and that dropped row is the real slice's own atom layer
  have hrow : nfk_dropFresh s32 = m3sigmaReal.1 := by
    have hatom := nf_eval_nf_atom_layer M3M _ s32
      (nf_characteristic_satisfies M3M 1 5 (Fin.cons 32 m3realEnv))
    have hfac := (nf_eval_nf0_cons_factor M3M m3realEnv 32 s32.atom_assgn).mp hatom
    exact nf_eval_unique M3M 0 4 m3realEnv _ _ hfac.2.2
      (nf_eval_nf_atom_layer M3M m3realEnv m3sigmaReal
        (nf_characteristic_satisfies M3M 2 4 m3realEnv))
  exact Prod.ext (hfib.symm.trans hrow) hcopy

end Bimodal.Metalogic.WeakCanonical.Kamp
