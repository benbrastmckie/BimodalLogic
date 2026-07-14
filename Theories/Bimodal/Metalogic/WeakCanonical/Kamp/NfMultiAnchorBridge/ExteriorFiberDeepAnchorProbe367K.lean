import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationK

/-! # Task 367 probe leaf: the hereditary deep-anchor guard vs the tail-doppelgänger

Machine-adjudicates the task-367 candidate deep-anchor guard `kvE_deepOnFiberV0` BEFORE any
production edit (the 363/364 probe-first methodology). The guard anchors the rows-8-9
obligation population (`_hsliceFut`/`_hslicePast`, `EndIntervalConsumerK.lean:154-167`) to the
ambient `qnf` one layer beyond the depth-0 row check `nfk_dropFresh σ = qnf.1` — the ONLY
antecedent the 358 tail-doppelgänger (`ExteriorPinnedProbe358TailK.lean`) needed to defeat.

## Adjudicated candidate (synthesis of handoff candidates (a) and (b))

`kvE_deepOnFiberV0 qnf σ` (fiber depth graded on σ's depth `k`):
- `k = 0` and `k = 1`: `decide (nfk_dropFresh σ = qnf.1)` — the depth-0 row check ONLY.
  The `k = 1` arm is the m = 0 instance of the rows-8-9 binders: the guard is
  DEFINITIONALLY the old antecedent there (`kvE_deepOnFiberV0_zero`, `rfl`), so the frozen
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
carries σ's deep marking, `kvE_deepOnFiberV0 qnf σ = false`, and σ is OUTSIDE the restated
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

/-! ## The candidate guard (Phase 1) -/

/-- **Candidate hereditary deep-anchor guard** (task 367, adjudicated candidate — see module
    docstring). Fiber-depth graded: at σ-depth ≤ 1 it IS the depth-0 row check
    (`nfk_dropFresh σ = qnf.1` — m = 0 inertness, gate 1b); at σ-depth ≥ 2 it additionally
    requires a **qnf-marked deep-content mate**: some `σ'` with `qnf.2 σ' = true` and
    `σ'.2 = σ.2`. Full `.2` equality is hereditary to depth 0 by construction. Pure
    decidable syntax over the NF fintype (no model parameter). -/
noncomputable def kvE_deepOnFiberV0 {sig : MonadicSignature} :
    {k n : Nat} → NormalForm sig (k + 1) n → NormalForm sig k (n + 1) → Bool
  | 0, _, qnf, σ => decide (nfk_dropFresh σ = qnf.1)
  | 1, _, qnf, σ => decide (nfk_dropFresh σ = qnf.1)
  | (j + 2), n, qnf, σ =>
    decide (nfk_dropFresh σ = qnf.1) &&
    ((Finset.univ.toList (α := NormalForm sig (j + 2) (n + 1))).any fun σ' =>
      qnf.2 σ' && decide (σ'.2 = σ.2))

/-- **Gate 1b (m = 0 inertness)**: at fiber depth 1 — the m = 0 instance of the rows-8-9
    binders — the guard is DEFINITIONALLY the depth-0 row check. The frozen m = 0 supply
    (task 360) discharges the restated binders through this adapter, and the m = 0 bracket
    range filter value is unchanged. -/
theorem kvE_deepOnFiberV0_zero {sig : MonadicSignature} {n : Nat}
    (qnf : NormalForm sig 2 n) (σ : NormalForm sig 1 (n + 1)) :
    kvE_deepOnFiberV0 qnf σ = decide (nfk_dropFresh σ = qnf.1) := rfl

/-- Depth-0 arm inertness (recursion base; not a binder instance — rows 8-9 bind σ at depth
    `m + 1 ≥ 1`). -/
theorem kvE_deepOnFiberV0_base {sig : MonadicSignature} {n : Nat}
    (qnf : NormalForm sig 1 n) (σ : NormalForm sig 0 (n + 1)) :
    kvE_deepOnFiberV0 qnf σ = decide (nfk_dropFresh σ = qnf.1) := rfl

/-- Unpack/repack the deep arm (σ-depth ≥ 2). The extraction interface every certificate
    routes through — the guard is never unfolded outside this module. -/
theorem kvE_deepOnFiberV0_iff {sig : MonadicSignature} {j n : Nat}
    (qnf : NormalForm sig (j + 3) n) (σ : NormalForm sig (j + 2) (n + 1)) :
    kvE_deepOnFiberV0 qnf σ = true ↔
      nfk_dropFresh σ = qnf.1 ∧
        ∃ σ' : NormalForm sig (j + 2) (n + 1), qnf.2 σ' = true ∧ σ'.2 = σ.2 := by
  show (decide (nfk_dropFresh σ = qnf.1) &&
      ((Finset.univ.toList (α := NormalForm sig (j + 2) (n + 1))).any fun σ' =>
        qnf.2 σ' && decide (σ'.2 = σ.2))) = true ↔ _
  rw [Bool.and_eq_true, List.any_eq_true, decide_eq_true_eq]
  constructor
  · rintro ⟨hrow, σ', -, hσ'⟩
    rw [Bool.and_eq_true, decide_eq_true_eq] at hσ'
    exact ⟨hrow, σ', hσ'.1, hσ'.2⟩
  · rintro ⟨hrow, σ', hmk, heq⟩
    refine ⟨hrow, σ', kvE_nf_mem_univ_toList σ', ?_⟩
    rw [hmk, decide_eq_true heq]
    rfl

/-- **Row extraction** (all depths): the guard implies the old depth-0 row antecedent — the
    adapter direction the restated rows 8-9 use to consume the frozen m = 0 supply and the
    old off-fiber forcing kernels. -/
theorem kvE_deepOnFiberV0_row {sig : MonadicSignature} :
    ∀ {k n : Nat} (qnf : NormalForm sig (k + 1) n) (σ : NormalForm sig k (n + 1)),
      kvE_deepOnFiberV0 qnf σ = true → nfk_dropFresh σ = qnf.1
  | 0, _, _, _, h => of_decide_eq_true h
  | 1, _, _, _, h => of_decide_eq_true h
  | (_ + 2), _, qnf, σ, h => ((kvE_deepOnFiberV0_iff qnf σ).mp h).1

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
    kvE_deepOnFiberV0 qnf367 m3sigma = false := by
  cases hg : kvE_deepOnFiberV0 qnf367 m3sigma with
  | false => rfl
  | true =>
    exfalso
    obtain ⟨-, σ', hmk, heq⟩ := (kvE_deepOnFiberV0_iff qnf367 m3sigma).mp hg
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

end Bimodal.Metalogic.WeakCanonical.Kamp
