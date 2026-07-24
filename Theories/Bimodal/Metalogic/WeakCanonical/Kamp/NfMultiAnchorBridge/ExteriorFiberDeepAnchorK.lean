import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberConsistencyK

/-! # Hereditary deep-anchor guard (task 367 — production home)

The rows-8-9 interface repair: a model-independent guard anchoring the exterior fiber
population (`σ : NormalForm sig (m+1) 4`) to the ambient (`qnf : NormalForm sig (m+2) 3`)
one layer beyond the depth-0 row check `nfk_dropFresh σ = qnf.1` — the ONLY antecedent the
358 tail-doppelgänger needed to defeat (`kvE_probe358_tailDG_gapItem_pinned_fails` /
`kvE_probe358_tailDG_sigma_in_population`, `ExteriorPinnedProbe358TailK.lean`).

Promoted verbatim from the Phase-1/2/3 probe leaf (`ExteriorFiberDeepAnchorProbe367K.lean`,
GO verdict: rejects the tail-doppelgänger `m3sigma` AND the depth-2 hereditary doppelgänger,
collapses the content-copying plant, accepts every realized slice over the ambient's own
tail; zero redesign loops consumed).

## The guard

`kvE_deepOnFiber qnf σ` (fiber-depth graded on σ's depth):
- σ-depth ≤ 1 (the m = 0 binder instance): the depth-0 row check ONLY — DEFINITIONALLY the
  old antecedent (`kvE_deepOnFiber_zero`, `rfl`), so the frozen m = 0 supply layer (task
  360) discharges the restated binders through a proof-script adapter, the m = 0 bracket
  range filter value is unchanged, and the new rows-12-13 residue obligations are
  m = 0-VACUOUS (guard-false contradicts on-row).
- σ-depth ≥ 2: row check `&&` a **qnf-marked deep-content mate** — some `σ'` with
  `qnf.2 σ' = true` carrying EXACTLY σ's whole deep marking (`σ'.2 = σ.2`). Full `.2`
  equality compares σ's marked-fiber content at EVERY depth simultaneously: hereditary to
  depth 0 by construction, not a single extra level.

## Why this separates fake from honest

Honest (`kvE_deepOnFiber_of_realized`): if `qnf` is realized at `env` and `σ` at
`Fin.cons x1 env`, the row conjunct follows from the depth-0 factorization
(`nf_eval_nf0_cons_factor`) + depth-0 uniqueness, and the deep mate is `σ` ITSELF
(`qnf.2 σ = true` by `qnf`'s quant layer at witness `x1`; `σ.2 = σ.2` by `rfl`).

Fake: the tail-doppelgänger's marked deep fiber carries the fake coupling vector at the
discrepancy layer (an inner witness demanding an R-point in a zone that is R-empty relative
to the REAL tail), so any `σ'` with `σ'.2 = σ.2` marks that fiber and cannot be realized
over the real tail — no qnf-marked mate exists (`kvE_probe367_tailDG_deep_rejected`,
`kvE_probe367_depth2DG_deep_rejected`). A content-copying plant (manufacturing `σ★.2` as a
copy of an honest slice's marking) collapses to the honest slice itself: admissibility's
on-fiber conjunct (task 363/364, read via `kvE_futAdmissible_onFiber`) pins `σ★.1` to the
copied fibers' dropped row (`kvE_probe367_copyPlant_collapses`).

## Consumption map

* **Rows 8-9** (`_hslicePast`/`_hsliceFut`, `EndIntervalConsumerK.lean`; mirrored in
  `bracketEndChar_kvExt_correct_prior` and `kampPrior_site_rungK_gate_match`): the
  antecedent `nfk_dropFresh σ = qnf.1` is REPLACED by `kvE_deepOnFiber qnf σ = true`
  (strictly stronger — the population shrinks; the old row is recovered via
  `kvE_deepOnFiber_row`).
* **Bracket range** (`kvE_extBracket{Fut,Past}`, `ExteriorBracketAssembleK.lean`): the
  filter conjunct `decide (nfk_dropFresh σ = qnf.1)` is REPLACED by
  `kvE_deepOnFiber qnf σ` — a deep-anchored fake slice carries NO clause, restoring honest
  bracket satisfiability at m ≥ 1 (the fake σ's negative clause used to conjoin against its
  own firing chain).
* **Rows 12-13** (`_hexclDeepPast`/`_hexclDeepFut`, NEW): the ⇒-side residue for on-row
  guard-FALSE bit-false σ (the gate's internal `hexclExt` discharge splits: off-row →
  atom-pin forcing, unchanged; on-row + guard-true → D1/D2 or rows 10-11; on-row +
  guard-false → rows 12-13). m = 0-vacuous; general-m discharge is task-358 scope.
* **m = 0 inertness**: `kvE_deepOnFiber_zero` is `rfl`; the frozen task-360 m = 0 supply
  and the k ≤ 1 rungs are untouched.

## Routing rule (NEVER unfold)

Discharge ONLY via the byte-stable lemmas here (`kvE_deepOnFiber_of_realized`,
`kvE_deepOnFiber_zero`, `kvE_deepOnFiber_row`, `kvE_deepOnFiber_iff`) — never by unfolding
`kvE_deepOnFiber`, `kvE_fiberElemConsistent`, or the admissibility predicates outside their
home modules. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- **Hereditary deep-anchor guard**. Fiber-depth graded: at σ-depth ≤ 1 it IS
    the depth-0 row check (`nfk_dropFresh σ = qnf.1` — m = 0 inertness); at σ-depth ≥ 2 it
    additionally requires a **qnf-marked deep-content mate**: some `σ'` with
    `qnf.2 σ' = true` and `σ'.2 = σ.2`. Full `.2` equality is hereditary to depth 0 by
    construction. Pure decidable syntax over the NF fintype (no model parameter). -/
noncomputable def kvE_deepOnFiber {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    {k n : Nat} → NormalForm sig (k + 1) n → NormalForm sig k (n + 1) → Bool
  | 0, _, qnf, σ => decide (nfk_dropFresh σ = qnf.1)
  | 1, _, qnf, σ => decide (nfk_dropFresh σ = qnf.1)
  | (j + 2), n, qnf, σ =>
    decide (nfk_dropFresh σ = qnf.1) &&
    ((Finset.univ.toList (α := NormalForm sig (j + 2) (n + 1))).any fun σ' =>
      qnf.2 σ' && decide (σ'.2 = σ.2))

/-- **m = 0 inertness**: at fiber depth 1 — the m = 0 instance of the rows-8-9 binders —
    the guard is DEFINITIONALLY the depth-0 row check. The frozen m = 0 supply
    discharges the restated binders through this adapter; the m = 0 bracket range filter
    value is unchanged; rows 12-13 are m = 0-vacuous through it. -/
theorem kvE_deepOnFiber_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (qnf : NormalForm sig 2 n) (σ : NormalForm sig 1 (n + 1)) :
    kvE_deepOnFiber qnf σ = decide (nfk_dropFresh σ = qnf.1) := rfl

/-- Depth-0 arm inertness (recursion base; not a binder instance — rows 8-9 bind σ at
    depth `m + 1 ≥ 1`). -/
theorem kvE_deepOnFiber_base {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (qnf : NormalForm sig 1 n) (σ : NormalForm sig 0 (n + 1)) :
    kvE_deepOnFiber qnf σ = decide (nfk_dropFresh σ = qnf.1) := rfl

/-- Unpack/repack the deep arm (σ-depth ≥ 2). The extraction interface every certificate
    and consumer routes through — the guard is never unfolded outside this module. -/
theorem kvE_deepOnFiber_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {j n : Nat}
    (qnf : NormalForm sig (j + 3) n) (σ : NormalForm sig (j + 2) (n + 1)) :
    kvE_deepOnFiber qnf σ = true ↔
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
theorem kvE_deepOnFiber_row {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    ∀ {k n : Nat} (qnf : NormalForm sig (k + 1) n) (σ : NormalForm sig k (n + 1)),
      kvE_deepOnFiber qnf σ = true → nfk_dropFresh σ = qnf.1
  | 0, _, _, _, h => of_decide_eq_true h
  | 1, _, _, _, h => of_decide_eq_true h
  | (_ + 2), _, qnf, σ, h => ((kvE_deepOnFiber_iff qnf σ).mp h).1

/-- **Realized slices over the ambient's own tail pass the deep anchor** (honest
    preservation — the load-bearing crux; the `kvE_fiberElemConsistent_of_realized` /
    `kvE_fiberConsistent_of_realized` template one layer down). If `qnf` is realized at
    `env` and `σ` at `Fin.cons x1 env` (a pinned tuple sharing the ambient's tail), then
    `σ` passes: the row conjunct by the depth-0 factorization + uniqueness, the deep-mate
    conjunct with `σ` ITSELF as mate. This is the discharge route the re-keyed task-358
    supply uses — `_of_realized` alone, no guard unfolding. -/
theorem kvE_deepOnFiber_of_realized {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) :
    ∀ {k n : Nat} (env : Fin n → M.carrier) (x1 : M.carrier)
      (qnf : NormalForm sig (k + 1) n) (σ : NormalForm sig k (n + 1)),
      nf_eval_nf M (k + 1) n env qnf →
      nf_eval_nf M k (n + 1) (Fin.cons x1 env) σ →
      kvE_deepOnFiber qnf σ = true := by
  have hrow : ∀ {k n : Nat} (env : Fin n → M.carrier) (x1 : M.carrier)
      (qnf : NormalForm sig (k + 1) n) (σ : NormalForm sig k (n + 1)),
      nf_eval_nf M (k + 1) n env qnf →
      nf_eval_nf M k (n + 1) (Fin.cons x1 env) σ →
      nfk_dropFresh σ = qnf.1 := by
    intro k n env x1 qnf σ hqnf hσ
    have hatom := nf_eval_nf_atom_layer M _ σ hσ
    have hfac := (nf_eval_nf0_cons_factor M env x1 σ.atom_assgn).mp hatom
    exact nf_eval_unique M 0 n env _ _ hfac.2.2 (nf_eval_nf_atom_layer M env qnf hqnf)
  intro k
  match k with
  | 0 =>
    intro n env x1 qnf σ hqnf hσ
    exact decide_eq_true (hrow env x1 qnf σ hqnf hσ)
  | 1 =>
    intro n env x1 qnf σ hqnf hσ
    exact decide_eq_true (hrow env x1 qnf σ hqnf hσ)
  | (j + 2) =>
    intro n env x1 qnf σ hqnf hσ
    rw [kvE_deepOnFiber_iff]
    exact ⟨hrow env x1 qnf σ hqnf hσ, σ, (hqnf.2 σ).mp ⟨x1, hσ⟩, rfl⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
