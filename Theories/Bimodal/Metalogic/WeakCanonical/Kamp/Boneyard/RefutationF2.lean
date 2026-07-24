/-
ARCHIVED — off-faithful-path Kamp infrastructure (Boneyard).

Anchor declaration: `Bimodal.Metalogic.WeakCanonical.Kamp.f2_relativized_refutation`.

This module is a dead-but-compiled F2 refutation certificate. Its sole live-facing
declaration, `f2_relativized_refutation`, was formerly reachable only through the
`NfMultiAnchorBridge` aggregator import and was consumed by no on-path declaration
(its only other mention was an aggregator comment). It has been MOVED here — never
deleted — because it is cited evidence feeding the downstream k >= 2 lossiness verdict:
it records the refutation that the unconditional depth-`k` correctness target is FALSE
at `k = 2` for the merged-route carrier. Retained verbatim as readable evidence.

Provenance anchor: extracted from `NfMultiAnchorBridge.lean`; the refutation target is
the depth-`k` bracket-zone correctness biconditional refuted at `k = 2` (see the F1
finding record and the `f2*` probe machinery in the body below). Do not extend; the
body below is retained byte-identical.
-/
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierKv

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

Extracted from NfMultiAnchorBridge.lean lines 4041-4987.
QUARANTINE / NEGATIVE-RESULT RECORD (F1-F4): merged-route refutation machinery; retained
byte-identical, do not extend. Contents: F1 finding record, `f2*` probe machinery
(self-contained), `f2_relativized_refutation`. -/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Phase 13 finding F1: the unconditional depth-`k` correctness target is FALSE
at `k = 2` for the Phase-12 carrier — the gate-strength defect anticipated by the Phase-12
handoff (Key Decision 3) is REAL

**Target refuted** (plan v5 Phase 13 deliverable): under the six bracket-zone order hypotheses
and the `charF` correctness hypothesis alone,
`(bracketEndChar_kv atomMap h_surj charF k qnf).holds M atomMap x t ↔
∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` fails at `k = 2` — the
soundness (LHS→RHS) direction. Defect record (four elements):

1. **Counterexample** (semantic). `sig` = one predicate `P`; `M` = `(ℚ, <)` with
   `P = {q, p, r}` and `q < x < u₂ < p < u₁ < w < t < r`. Then `u₁, u₂` share their complete
   depth-1 1-type `χ` (a `P`-point strictly below each: `p`/`q`; strictly above each: `r`/`p`;
   none at; density realizes the non-`P` depth-0 2-types identically), but the depth-1 arity-4
   types `sub₁ :=` type of `[u₁,w,x,t]` and `sub₂ :=` type of `[u₂,w,x,t]` are DISTINCT — the
   depth-0 5-type "`P z` and `x < z <` fresh" is realized below `u₁` (via `z = p`) and not
   below `u₂` — while sharing all fiber data: zone `zXW`, `nfk_projFresh = χ`,
   atom-restriction `= qnf.1`. Let `qnf := nf_characteristic M 2 3 [w,x,t]` (realized at `w`:
   `nf_characteristic_satisfies`, NormalForm:224) and `qnf' := qnf` with `sub₂` re-marked
   `false`. Then: (a) `bracketEndChar_kv … 2 qnf' = bracketEndChar_kv … 2 qnf` — by
   `bracketEndChar_kv_factors` above (`sub₁` keeps every fiber bit alive; the off-fiber clause
   is unaffected by un-marking an on-fiber sub); (b) the six order hypotheses hold on
   `qnf'.1 = qnf.1`; (c) NO `w'` realizes `qnf'` in `M`: for `w' > p` density supplies
   `v ∈ (x, p)` with `[v,w',x,t]` of type `sub₂` — realized but marked false; for `w' ≤ p`
   there is no `v < w'` with a `P`-point in `(x, v)` — `sub₁` marked true but unrealized
   (`w' = p` is excluded by the atom layer: `P w'` must be false). The target `↔` at `qnf`
   forces the carrier to HOLD at `(x, t)` (mpr at witness `w`); (a) transports that to `qnf'`;
   the target `↔` at `qnf'` then forces `∃ w'` realizing `qnf'` — contradicting (c). NOTE:
   `qnf'` IS realizable in a different chain (a discrete one with no point strictly between
   `x` and `p`), so no qnf-consistency hypothesis rescues the statement either.

2. **Current behavior**: at depth `k + 1` the carrier reads `qnf.2` ONLY through (i) the
   atom-layer off-fiber Prop and (ii) the fiber-existential bits (:3661-3665);
   `bracketEndChar_kv_factors` machine-checks this factorization.

3. **Required behavior**: the quant layer of `nf_eval_nf M (k+1) 3 env qnf`
   (NormalForm:203-207) is a per-sub BICONDITIONAL over depth-`k` arity-4 subs. At
   `k + 1 ≥ 2` a fiber `(zs, χ)` over `qnf.1` contains ≥ 2 subs differing in deeper JOINT
   layers (D7, NfEFold:373 — no pointwise assemble exists), and the biconditional
   distinguishes in-fiber markings the carrier cannot see.

4. **Isolation**: `k = 1` is saved by the depth-0 split-kit BIJECTION (`nf0_split_assemble`,
   NfEFold:235): fibers are singletons, so the fiber-existential read IS the pointwise read
   (the bridge :3710) — which is exactly why `bracketEndChar_k1v_correct` (:3378) is sorry-free
   and why the refutation starts at `k = 2`. In Rabinovich the corresponding step iterates
   Prop 4.3 (PDF p.6) with the `α_j`/`β_j` ENRICHED at every fold round: Def 3.1 (PDF p.4)
   takes quantifier-free formulas over the CURRENT vocabulary, and after a round that
   vocabulary includes the previous round's TL-definable content (the `F_i` of Cor 5.4,
   PDF p.7, are TL formulas, not base-signature types) — so the joint structure of a fresh
   witness relative to the anchors rides the enriched interval/point formulas. The Phase-12
   realization instead projects subs to PLAIN depth-`k` 1-types over the BASE signature
   (`nfk_projFresh`), discarding exactly that joint structure. The repair is a carrier/plan
   revision (inside-out iterated fold with vocabulary enrichment — the Def 4.1 p.6 note read
   at full strength), NOT a gate patch: any syntactic gate strengthening is either violated by
   honest characteristic types (which DO distinguish same-fiber subs — the discrete-chain
   realization of `qnf'`) or is model-dependent. Per Key Decision 3 of the Phase-12 handoff,
   the Phase-12 gate is NOT silently changed here; this record is the mandated Phase-13
   finding.

**Not refuted**: the completeness direction (RHS→LHS) — the honest characteristic type's
carrier holds at all depths on this analysis; a plan-v6 carrier revision can expect to retain
the completeness shape. Landed in this phase: the recursion base `bracketEndChar_kv_correct_zero`
and the first step `bracketEndChar_kv_correct_one` (both above, sorry-free — the 13a seam of the
plan's H8 split note), plus the factorization lemma. Phase 13 is [BLOCKED] pending plan revision. -/

/-! ## Phase 13.0: F2 decision probe — machinery

Probe infrastructure for the F2 verdict record at the bottom of this file (additive; nothing
above this line is edited). The probe machine-checks the report-05 F-B extension of F1 to the
Prior model `M* = (ℤ, <)`, `P = {0, 10, 20}` — a model that (unlike F1's `(ℚ, <)` with finite
`P`, which fails `semantic_prior_UZ`) SATISFIES both Prior hypotheses (PriorDefs:22/:33), so the
UZ/SZ-relativized k=2 statement for the CURRENT carrier `bracketEndChar_kv` is exercised on its
own turf. All declarations are probe-local (`private` where possible); the public verdict
theorem is `f2_relativized_refutation` below. -/

/-- One-predicate signature for the F2 probe (`()` names the single monadic predicate `P`). -/
private abbrev f2sig : MonadicSignature := { preds := Unit }

/-- Trivial atom map into the one-predicate probe signature. -/
private abbrev f2atomMap : Formula → f2sig.preds := fun _ => ()

/-- Surjectivity of the probe atom map (every predicate is hit by an atom). -/
private theorem f2surj : ∀ p : f2sig.preds, ∃ a : Atom, f2atomMap (.atom a) = p :=
  fun _ => ⟨Atom.mk_base "P", rfl⟩

/-- The F2 probe model `M* = (ℤ, <)` with `P = {0, 10, 20}` (report 05 F-B; the discrete
    extension of F1's counterexample pattern `q < x < u₂ < p < u₁ < w < t < r` at the concrete
    points `0 < 2 < 4 < 10 < 12 < 15 < 18 < 20`). -/
private abbrev F2M : OrderedMonadicStructure f2sig where
  carrier := ℤ
  interp := fun _ z => z = 0 ∨ z = 10 ∨ z = 20
  carrier_order := inferInstance

/-- `ℤ` first-occurrence principle: a nonempty subset of `(t, ∞)` has a least element
    (`Nat.find` on the shifted index). Pure integer arithmetic, no model content. -/
private theorem f2_int_first {Q : ℤ → Prop} (t : ℤ) (h : ∃ s, t < s ∧ Q s) :
    ∃ s, t < s ∧ Q s ∧ ∀ r, t < r → r < s → ¬ Q r := by
  classical
  obtain ⟨s, hts, hs⟩ := h
  have hP : ∃ n : ℕ, Q (t + 1 + (n : ℤ)) := by
    refine ⟨(s - t - 1).toNat, ?_⟩
    have hcast : t + 1 + (((s - t - 1).toNat : ℕ) : ℤ) = s := by omega
    rw [hcast]; exact hs
  refine ⟨t + 1 + (Nat.find hP : ℤ), by omega, Nat.find_spec hP, ?_⟩
  intro r htr hrs h_r
  have hm : ∃ m : ℕ, r = t + 1 + (m : ℤ) ∧ m < Nat.find hP :=
    ⟨(r - t - 1).toNat, by omega, by omega⟩
  obtain ⟨m, hmr, hmlt⟩ := hm
  exact Nat.find_min hP hmlt (hmr ▸ h_r)

/-- `ℤ` last-occurrence principle: a nonempty subset of `(-∞, t)` has a greatest element —
    the mirror of `f2_int_first`. -/
private theorem f2_int_last {Q : ℤ → Prop} (t : ℤ) (h : ∃ s, s < t ∧ Q s) :
    ∃ s, s < t ∧ Q s ∧ ∀ r, s < r → r < t → ¬ Q r := by
  classical
  obtain ⟨s, hst, hs⟩ := h
  have hP : ∃ n : ℕ, Q (t - 1 - (n : ℤ)) := by
    refine ⟨(t - s - 1).toNat, ?_⟩
    have hcast : t - 1 - (((t - s - 1).toNat : ℕ) : ℤ) = s := by omega
    rw [hcast]; exact hs
  refine ⟨t - 1 - (Nat.find hP : ℤ), by omega, Nat.find_spec hP, ?_⟩
  intro r hsr hrt h_r
  have hm : ∃ m : ℕ, r = t - 1 - (m : ℤ) ∧ m < Nat.find hP :=
    ⟨(t - r - 1).toNat, by omega, by omega⟩
  obtain ⟨m, hmr, hmlt⟩ := hm
  exact Nat.find_min hP hmlt (hmr ▸ h_r)

/-- `(ℤ, <)` satisfies semantic Prior-UZ (PriorDefs:22): every future occurrence of any
    temporal `ψ` has a FIRST occurrence, with `ψ.neg` on the open gap (`f2_int_first`). -/
private theorem f2_UZ : semantic_prior_UZ F2M f2atomMap := by
  intro t ψ h
  obtain ⟨s, hts, hs, hmin⟩ :=
    f2_int_first (Q := fun z => temporal_truth F2M f2atomMap z ψ) t h
  refine ⟨s, hts, hs, ?_⟩
  intro r htr hrs
  simp only [Formula.neg, temporal_truth]
  exact hmin r htr hrs

/-- `(ℤ, <)` satisfies semantic Prior-SZ (PriorDefs:33): every past occurrence of any
    temporal `ψ` has a LAST occurrence, with `ψ.neg` on the open gap (`f2_int_last`). -/
private theorem f2_SZ : semantic_prior_SZ F2M f2atomMap := by
  intro t ψ h
  obtain ⟨s, hst, hs, hmax⟩ :=
    f2_int_last (Q := fun z => temporal_truth F2M f2atomMap z ψ) t h
  refine ⟨s, hst, hs, ?_⟩
  intro r hsr hrt
  simp only [Formula.neg, temporal_truth]
  exact hmax r hsr hrt

/-- Evaluation is characteristic-equality (`nf_eval_unique` NormalForm:245 packaged with
    `nf_characteristic_satisfies` NormalForm:224): a normal form holds at `env` iff it IS the
    characteristic type of `env`. The probe's per-entry workhorse. -/
private theorem f2_eval_iff_char {k n : Nat} (env : Fin n → F2M.carrier)
    (σ : NormalForm f2sig k n) :
    nf_eval_nf F2M k n env σ ↔ σ = nf_characteristic F2M k n env :=
  ⟨fun h => nf_eval_unique F2M k n env σ _ h (nf_characteristic_satisfies F2M k n env),
   fun h => h ▸ nf_characteristic_satisfies F2M k n env⟩

/-- Depth-0 characteristic congruence: two `ℤ`-environments with the same `P`-pattern and the
    same order pattern have EQUAL depth-0 characteristic types. Pure Def-3.1 channel bookkeeping
    (`P`-bits + order bits are all a depth-0 type holds). -/
private theorem f2_char0_congr {n : Nat} (e₁ e₂ : Fin n → F2M.carrier)
    (hP : ∀ i, (e₁ i = 0 ∨ e₁ i = 10 ∨ e₁ i = 20) ↔ (e₂ i = 0 ∨ e₂ i = 10 ∨ e₂ i = 20))
    (hO : ∀ i j, e₁ i < e₁ j ↔ e₂ i < e₂ j) :
    nf_characteristic F2M 0 n e₁ = nf_characteristic F2M 0 n e₂ := by
  funext a
  simp only [nf_characteristic]
  apply decide_eq_decide.mpr
  cases a with
  | pred p i => exact hP i
  | order i j h => exact hO i j

/-- Prefix restriction of a depth-0 characteristic is the characteristic of the restricted
    environment (the depth-0 instance of `nfk_take` naturality). -/
private theorem f2_take_char0 {m n : Nat} (h : m ≤ n) (env : Fin n → F2M.carrier) :
    nfk_take h (nf_characteristic F2M 0 n env) =
      nf_characteristic F2M 0 m (fun i => env (Fin.castLE h i)) := by
  funext a
  simp only [nfk_take, nf_characteristic]
  cases a with
  | pred p i => rfl
  | order i j h' => rfl

/-- Depth-0 2-type congruence, value form (`Fin.cons` environments `[z, u]`): same `P`-bits and
    same order pattern give the same characteristic 2-type. -/
private theorem f2_char0_congr2 (z₁ u₁ z₂ u₂ : ℤ)
    (hPz : (z₁ = 0 ∨ z₁ = 10 ∨ z₁ = 20) ↔ (z₂ = 0 ∨ z₂ = 10 ∨ z₂ = 20))
    (hPu : (u₁ = 0 ∨ u₁ = 10 ∨ u₁ = 20) ↔ (u₂ = 0 ∨ u₂ = 10 ∨ u₂ = 20))
    (h_zu : z₁ < u₁ ↔ z₂ < u₂) (h_uz : u₁ < z₁ ↔ u₂ < z₂) :
    nf_characteristic F2M 0 2 (Fin.cons z₁ (fun _ => u₁)) =
      nf_characteristic F2M 0 2 (Fin.cons z₂ (fun _ => u₂)) := by
  apply f2_char0_congr
  · intro i
    match i with
    | ⟨0, _⟩ => exact hPz
    | ⟨1, _⟩ => exact hPu
  · intro i j
    match i, j with
    | ⟨0, _⟩, ⟨0, _⟩ => exact iff_of_false (lt_irrefl _) (lt_irrefl _)
    | ⟨0, _⟩, ⟨1, _⟩ => exact h_zu
    | ⟨1, _⟩, ⟨0, _⟩ => exact h_uz
    | ⟨1, _⟩, ⟨1, _⟩ => exact iff_of_false (lt_irrefl _) (lt_irrefl _)

/-- Depth-0 4-type congruence, value form (`Fin.cons` environments `[u, w, x, t]`). -/
private theorem f2_char0_congr4 (u₁ w₁ x₁ t₁ u₂ w₂ x₂ t₂ : ℤ)
    (hPu : (u₁ = 0 ∨ u₁ = 10 ∨ u₁ = 20) ↔ (u₂ = 0 ∨ u₂ = 10 ∨ u₂ = 20))
    (hPw : (w₁ = 0 ∨ w₁ = 10 ∨ w₁ = 20) ↔ (w₂ = 0 ∨ w₂ = 10 ∨ w₂ = 20))
    (hPx : (x₁ = 0 ∨ x₁ = 10 ∨ x₁ = 20) ↔ (x₂ = 0 ∨ x₂ = 10 ∨ x₂ = 20))
    (hPt : (t₁ = 0 ∨ t₁ = 10 ∨ t₁ = 20) ↔ (t₂ = 0 ∨ t₂ = 10 ∨ t₂ = 20))
    (h_uw : u₁ < w₁ ↔ u₂ < w₂) (h_wu : w₁ < u₁ ↔ w₂ < u₂)
    (h_ux : u₁ < x₁ ↔ u₂ < x₂) (h_xu : x₁ < u₁ ↔ x₂ < u₂)
    (h_ut : u₁ < t₁ ↔ u₂ < t₂) (h_tu : t₁ < u₁ ↔ t₂ < u₂)
    (h_wx : w₁ < x₁ ↔ w₂ < x₂) (h_xw : x₁ < w₁ ↔ x₂ < w₂)
    (h_wt : w₁ < t₁ ↔ w₂ < t₂) (h_tw : t₁ < w₁ ↔ t₂ < w₂)
    (h_xt : x₁ < t₁ ↔ x₂ < t₂) (h_tx : t₁ < x₁ ↔ t₂ < x₂) :
    nf_characteristic F2M 0 4 (Fin.cons u₁ (Fin.cons w₁ (Fin.cons x₁ (fun _ => t₁)))) =
      nf_characteristic F2M 0 4 (Fin.cons u₂ (Fin.cons w₂ (Fin.cons x₂ (fun _ => t₂)))) := by
  apply f2_char0_congr
  · intro i
    match i with
    | ⟨0, _⟩ => exact hPu
    | ⟨1, _⟩ => exact hPw
    | ⟨2, _⟩ => exact hPx
    | ⟨3, _⟩ => exact hPt
  · intro i j
    have irr : ∀ a b : ℤ, (a < a ↔ b < b) := fun a b =>
      iff_of_false (lt_irrefl _) (lt_irrefl _)
    match i, j with
    | ⟨0, _⟩, ⟨0, _⟩ => exact irr _ _
    | ⟨0, _⟩, ⟨1, _⟩ => exact h_uw
    | ⟨0, _⟩, ⟨2, _⟩ => exact h_ux
    | ⟨0, _⟩, ⟨3, _⟩ => exact h_ut
    | ⟨1, _⟩, ⟨0, _⟩ => exact h_wu
    | ⟨1, _⟩, ⟨1, _⟩ => exact irr _ _
    | ⟨1, _⟩, ⟨2, _⟩ => exact h_wx
    | ⟨1, _⟩, ⟨3, _⟩ => exact h_wt
    | ⟨2, _⟩, ⟨0, _⟩ => exact h_xu
    | ⟨2, _⟩, ⟨1, _⟩ => exact h_xw
    | ⟨2, _⟩, ⟨2, _⟩ => exact irr _ _
    | ⟨2, _⟩, ⟨3, _⟩ => exact h_xt
    | ⟨3, _⟩, ⟨0, _⟩ => exact h_tu
    | ⟨3, _⟩, ⟨1, _⟩ => exact h_tw
    | ⟨3, _⟩, ⟨2, _⟩ => exact h_tx
    | ⟨3, _⟩, ⟨3, _⟩ => exact irr _ _

/-- Depth-0 5-type congruence, value form (`Fin.cons` environments `[z, u, w, x, t]`) — the
    fresh-witness transfer workhorse for the F2 probe's per-entry checks. -/
private theorem f2_char0_congr5 (z₁ u₁ w₁ x₁ t₁ z₂ u₂ w₂ x₂ t₂ : ℤ)
    (hPz : (z₁ = 0 ∨ z₁ = 10 ∨ z₁ = 20) ↔ (z₂ = 0 ∨ z₂ = 10 ∨ z₂ = 20))
    (hPu : (u₁ = 0 ∨ u₁ = 10 ∨ u₁ = 20) ↔ (u₂ = 0 ∨ u₂ = 10 ∨ u₂ = 20))
    (hPw : (w₁ = 0 ∨ w₁ = 10 ∨ w₁ = 20) ↔ (w₂ = 0 ∨ w₂ = 10 ∨ w₂ = 20))
    (hPx : (x₁ = 0 ∨ x₁ = 10 ∨ x₁ = 20) ↔ (x₂ = 0 ∨ x₂ = 10 ∨ x₂ = 20))
    (hPt : (t₁ = 0 ∨ t₁ = 10 ∨ t₁ = 20) ↔ (t₂ = 0 ∨ t₂ = 10 ∨ t₂ = 20))
    (h_zu : z₁ < u₁ ↔ z₂ < u₂) (h_uz : u₁ < z₁ ↔ u₂ < z₂)
    (h_zw : z₁ < w₁ ↔ z₂ < w₂) (h_wz : w₁ < z₁ ↔ w₂ < z₂)
    (h_zx : z₁ < x₁ ↔ z₂ < x₂) (h_xz : x₁ < z₁ ↔ x₂ < z₂)
    (h_zt : z₁ < t₁ ↔ z₂ < t₂) (h_tz : t₁ < z₁ ↔ t₂ < z₂)
    (h_uw : u₁ < w₁ ↔ u₂ < w₂) (h_wu : w₁ < u₁ ↔ w₂ < u₂)
    (h_ux : u₁ < x₁ ↔ u₂ < x₂) (h_xu : x₁ < u₁ ↔ x₂ < u₂)
    (h_ut : u₁ < t₁ ↔ u₂ < t₂) (h_tu : t₁ < u₁ ↔ t₂ < u₂)
    (h_wx : w₁ < x₁ ↔ w₂ < x₂) (h_xw : x₁ < w₁ ↔ x₂ < w₂)
    (h_wt : w₁ < t₁ ↔ w₂ < t₂) (h_tw : t₁ < w₁ ↔ t₂ < w₂)
    (h_xt : x₁ < t₁ ↔ x₂ < t₂) (h_tx : t₁ < x₁ ↔ t₂ < x₂) :
    nf_characteristic F2M 0 5
        (Fin.cons z₁ (Fin.cons u₁ (Fin.cons w₁ (Fin.cons x₁ (fun _ => t₁))))) =
      nf_characteristic F2M 0 5
        (Fin.cons z₂ (Fin.cons u₂ (Fin.cons w₂ (Fin.cons x₂ (fun _ => t₂))))) := by
  apply f2_char0_congr
  · intro i
    match i with
    | ⟨0, _⟩ => exact hPz
    | ⟨1, _⟩ => exact hPu
    | ⟨2, _⟩ => exact hPw
    | ⟨3, _⟩ => exact hPx
    | ⟨4, _⟩ => exact hPt
  · intro i j
    have irr : ∀ a b : ℤ, (a < a ↔ b < b) := fun a b =>
      iff_of_false (lt_irrefl _) (lt_irrefl _)
    match i, j with
    | ⟨0, _⟩, ⟨0, _⟩ => exact irr _ _
    | ⟨0, _⟩, ⟨1, _⟩ => exact h_zu
    | ⟨0, _⟩, ⟨2, _⟩ => exact h_zw
    | ⟨0, _⟩, ⟨3, _⟩ => exact h_zx
    | ⟨0, _⟩, ⟨4, _⟩ => exact h_zt
    | ⟨1, _⟩, ⟨0, _⟩ => exact h_uz
    | ⟨1, _⟩, ⟨1, _⟩ => exact irr _ _
    | ⟨1, _⟩, ⟨2, _⟩ => exact h_uw
    | ⟨1, _⟩, ⟨3, _⟩ => exact h_ux
    | ⟨1, _⟩, ⟨4, _⟩ => exact h_ut
    | ⟨2, _⟩, ⟨0, _⟩ => exact h_wz
    | ⟨2, _⟩, ⟨1, _⟩ => exact h_wu
    | ⟨2, _⟩, ⟨2, _⟩ => exact irr _ _
    | ⟨2, _⟩, ⟨3, _⟩ => exact h_wx
    | ⟨2, _⟩, ⟨4, _⟩ => exact h_wt
    | ⟨3, _⟩, ⟨0, _⟩ => exact h_xz
    | ⟨3, _⟩, ⟨1, _⟩ => exact h_xu
    | ⟨3, _⟩, ⟨2, _⟩ => exact h_xw
    | ⟨3, _⟩, ⟨3, _⟩ => exact irr _ _
    | ⟨3, _⟩, ⟨4, _⟩ => exact h_xt
    | ⟨4, _⟩, ⟨0, _⟩ => exact h_tz
    | ⟨4, _⟩, ⟨1, _⟩ => exact h_tu
    | ⟨4, _⟩, ⟨2, _⟩ => exact h_tw
    | ⟨4, _⟩, ⟨3, _⟩ => exact h_tx
    | ⟨4, _⟩, ⟨4, _⟩ => exact irr _ _

/-! ### F2 probe: the concrete counterexample pair `(qnf, qnf')` at `k = 2`

Report 05 F-B data, transcribed: anchors `[w, x, t] = [15, 2, 18]`, distinguishing points
`u₁ = 12`, `u₂ = 4` (both in the interior zone `zXW`, both `¬P`, sharing their complete depth-1
monadic point type), separated by the `P`-point `10 ∈ (x, u₁) \ (x, u₂)`. -/

/-- Probe anchor environment `[w, x, t] = [15, 2, 18]`. -/
private def f2env3 : Fin 3 → F2M.carrier := Fin.cons 15 (Fin.cons 2 (fun _ => 18))

/-- `qnf`: the honest depth-2 characteristic 3-type of `[15, 2, 18]` in `M*` (realized at
    `w = 15` by `nf_characteristic_satisfies`). -/
private noncomputable def f2qnf : NormalForm f2sig 2 3 := nf_characteristic F2M 2 3 f2env3

/-- `sub₁`: the depth-1 arity-4 type of `[u₁, w, x, t] = [12, 15, 2, 18]`. -/
private noncomputable def f2sub1 : NormalForm f2sig 1 4 :=
  nf_characteristic F2M 1 4 (Fin.cons 12 f2env3)

/-- `sub₂`: the depth-1 arity-4 type of `[u₂, w, x, t] = [4, 15, 2, 18]`. -/
private noncomputable def f2sub2 : NormalForm f2sig 1 4 :=
  nf_characteristic F2M 1 4 (Fin.cons 4 f2env3)

/-- `qnf'`: `qnf` with the `u₂`-sub un-marked — the F1 information-loss pattern (F1 item 1). -/
private noncomputable def f2qnf' : NormalForm f2sig 2 3 :=
  (f2qnf.1, fun σ => if σ = f2sub2 then false else f2qnf.2 σ)

/-- Unfold: the atom layer of `qnf` is the depth-0 characteristic of the anchors. -/
private theorem f2qnf_fst : f2qnf.1 = nf_characteristic F2M 0 3 f2env3 := rfl

/-- Unfold: the quant layer of `qnf` is the realized-sub `decide` (honest marking). -/
private theorem f2qnf_snd (σ : NormalForm f2sig 1 4) :
    f2qnf.2 σ =
      @decide (∃ u : ℤ, nf_eval_nf F2M 1 4 (Fin.cons u f2env3) σ)
        (Classical.dec _) := rfl

/-- Unfold: the quant layer of a depth-1 arity-4 characteristic is the realized-entry
    `decide` over depth-0 arity-5 types. -/
private theorem f2char14_snd (env : Fin 4 → F2M.carrier) (e : NormalForm f2sig 0 5) :
    (nf_characteristic F2M 1 4 env).2 e =
      @decide (∃ z : ℤ, nf_eval_nf F2M 0 5 (Fin.cons z env) e)
        (Classical.dec _) := rfl

/-- `sub₁` is marked in `qnf` (realized at `u₁ = 12`). -/
private theorem f2_sub1_marked : f2qnf.2 f2sub1 = true := by
  rw [f2qnf_snd]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨12, nf_characteristic_satisfies F2M 1 4 (Fin.cons 12 f2env3)⟩

/-- `sub₁` and `sub₂` share their full atom layer: same order pattern `x < u < w < t`, same
    `P`-bits (both fresh points `¬P`) — the Def-3.1 ordering and env-restriction channels of
    the two subs agree. -/
private theorem f2_sub_atom_eq : f2sub1.1 = f2sub2.1 := by
  show nf_characteristic F2M 0 4 (Fin.cons 12 f2env3) =
    nf_characteristic F2M 0 4 (Fin.cons 4 f2env3)
  exact f2_char0_congr _ _ (by decide) (by decide)

/-- The distinguishing entry `e* :=` the depth-0 5-type of `[10, 12, 15, 2, 18]` — the type
    "`P z` and `x < z < u < w < t`" (F1 item 1's depth-0 5-type, at the F-B points). -/
private noncomputable def f2estar : NormalForm f2sig 0 5 :=
  nf_characteristic F2M 0 5 (Fin.cons 10 (Fin.cons 12 f2env3))

/-- `e*` is marked in `sub₁` (witness `z = 10`: `P 10` and `2 < 10 < 12`). -/
private theorem f2_estar_in_sub1 : f2sub1.2 f2estar = true := by
  rw [show f2sub1.2 f2estar = _ from f2char14_snd _ f2estar]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨10, nf_characteristic_satisfies F2M 0 5 (Fin.cons 10 (Fin.cons 12 f2env3))⟩

/-- `e*` is NOT marked in `sub₂`: a witness would need `P z` with `2 < z < 4` — the gap
    `(x, u₂)` contains no `P`-point. THE information the fiber-existential read discards. -/
private theorem f2_estar_not_in_sub2 : f2sub2.2 f2estar = false := by
  rw [show f2sub2.2 f2estar = _ from f2char14_snd _ f2estar]
  apply @decide_eq_false _ (Classical.dec _)
  rintro ⟨z, hz⟩
  rw [f2_eval_iff_char] at hz
  -- Read the P-bit and the two order bits of `z` off the type equality.
  have hP : ((z : ℤ) = 0 ∨ (z : ℤ) = 10 ∨ (z : ℤ) = 20) := by
    have hb := congrFun hz (.pred () ⟨0, by omega⟩)
    simp only [f2estar, nf_characteristic] at hb
    have h10 : (10 : ℤ) = 0 ∨ (10 : ℤ) = 10 ∨ (10 : ℤ) = 20 := by norm_num
    exact (decide_eq_decide.mp hb).mp h10
  have hgt : (2 : ℤ) < z := by
    have hb := congrFun hz (.order ⟨3, by omega⟩ ⟨0, by omega⟩ (Fin.ne_of_val_ne (by decide)))
    simp only [f2estar, nf_characteristic] at hb
    have h210 : (2 : ℤ) < 10 := by omega
    exact (decide_eq_decide.mp hb).mp h210
  have hlt : (z : ℤ) < 4 := by
    have hb := congrFun hz (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (Fin.ne_of_val_ne Nat.zero_ne_one))
    simp only [f2estar, nf_characteristic] at hb
    have h1012 : (10 : ℤ) < 12 := by omega
    exact (decide_eq_decide.mp hb).mp h1012
  rcases hP with h | h | h <;> omega

/-- `sub₁ ≠ sub₂` — they differ at `e*` (F1 item 1: distinct depth-1 arity-4 types). -/
private theorem f2_sub_ne : f2sub1 ≠ f2sub2 := by
  intro h
  have hb : f2sub1.2 f2estar = f2sub2.2 f2estar := by rw [h]
  rw [f2_estar_in_sub1, f2_estar_not_in_sub2] at hb
  exact Bool.noConfusion hb

/-- The 2-variable prefix of the arity-5 witness environment is the fresh 2-type
    environment `[z, u]` (index bookkeeping for `nfk_take` at the probe points). -/
private theorem f2_cast2_env (h : 2 ≤ 5) (z u : ℤ) :
    (fun i => (Fin.cons z (Fin.cons u f2env3) : Fin 5 → F2M.carrier) (Fin.castLE h i)) =
      (Fin.cons z (fun _ => u) : Fin 2 → F2M.carrier) := by
  funext i
  match i with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl

/-- The realized fresh-variable 2-types at `u₁ = 12` and `u₂ = 4` coincide (report 05 F-B:
    both `¬P`, `P`-points strictly below — `{0, 10}` / `{0}` — and strictly above — `{20}` /
    `{10, 20}` — and every `¬P` cell inhabited on both sides). -/
private theorem f2_proj2_iff (χ' : NormalForm f2sig 0 2) :
    (∃ z : ℤ, nf_characteristic F2M 0 2 (Fin.cons z (fun _ => (12 : ℤ))) = χ') ↔
    (∃ z : ℤ, nf_characteristic F2M 0 2 (Fin.cons z (fun _ => (4 : ℤ))) = χ') := by
  constructor
  · rintro ⟨z, rfl⟩
    by_cases hp : (z = 0 ∨ z = 10 ∨ z = 20)
    · rcases lt_trichotomy z 12 with h | h | h
      · exact ⟨0, f2_char0_congr2 _ _ _ _ (iff_of_true (by decide) hp) (by decide)
          (iff_of_true (by decide) h) (iff_of_false (by decide) (by omega))⟩
      · exfalso; rcases hp with h' | h' | h' <;> omega
      · exact ⟨10, f2_char0_congr2 _ _ _ _ (iff_of_true (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) h)⟩
    · rcases lt_trichotomy z 12 with h | h | h
      · exact ⟨1, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_true (by decide) h) (iff_of_false (by decide) (by omega))⟩
      · exact ⟨4, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_false (by decide) (by omega))⟩
      · exact ⟨5, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) h)⟩
  · rintro ⟨z, rfl⟩
    by_cases hp : (z = 0 ∨ z = 10 ∨ z = 20)
    · rcases lt_trichotomy z 4 with h | h | h
      · exact ⟨0, f2_char0_congr2 _ _ _ _ (iff_of_true (by decide) hp) (by decide)
          (iff_of_true (by decide) h) (iff_of_false (by decide) (by omega))⟩
      · exfalso; rcases hp with h' | h' | h' <;> omega
      · exact ⟨20, f2_char0_congr2 _ _ _ _ (iff_of_true (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) h)⟩
    · rcases lt_trichotomy z 4 with h | h | h
      · exact ⟨1, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_true (by decide) h) (iff_of_false (by decide) (by omega))⟩
      · exact ⟨12, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_false (by decide) (by omega))⟩
      · exact ⟨13, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) h)⟩

/-- `u₁` and `u₂` share their complete depth-1 monadic point type `χ`: the fresh projections
    (`nfk_projFresh`, the Def-4.1 E[Σ]-atom channel) of `sub₁` and `sub₂` are EQUAL. Atom
    part: the shared atom layer (`f2_sub_atom_eq`); quant part: the realized fresh-2-type
    transfer (`f2_proj2_iff`) through `nfk_take`/`f2_take_char0`. -/
private theorem f2_sub_proj_eq : nfk_projFresh f2sub1 = nfk_projFresh f2sub2 := by
  have hcomp : ∀ (u : ℤ) (χ' : NormalForm f2sig 0 2),
      (∃ e : NormalForm f2sig 0 5,
        (nf_characteristic F2M 1 4 (Fin.cons u f2env3)).2 e = true ∧
          nfk_take (by omega) e = χ') ↔
      (∃ z : ℤ, nf_characteristic F2M 0 2 (Fin.cons z (fun _ => u)) = χ') := by
    intro u χ'
    constructor
    · rintro ⟨e, he, hproj⟩
      rw [show (nf_characteristic F2M 1 4 (Fin.cons u f2env3)).2 e = _ from
        f2char14_snd _ e] at he
      obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) he
      rw [f2_eval_iff_char] at hz
      subst hz
      rw [f2_take_char0, f2_cast2_env] at hproj
      exact ⟨z, hproj⟩
    · rintro ⟨z, hz⟩
      refine ⟨nf_characteristic F2M 0 5 (Fin.cons z (Fin.cons u f2env3)), ?_, ?_⟩
      · rw [show (nf_characteristic F2M 1 4 (Fin.cons u f2env3)).2 _ = _ from f2char14_snd _ _]
        exact @decide_eq_true _ (Classical.dec _)
          ⟨z, nf_characteristic_satisfies F2M 0 5 (Fin.cons z (Fin.cons u f2env3))⟩
      · rw [f2_take_char0, f2_cast2_env]
        exact hz
  refine Prod.ext ?_ ?_
  · show (fun a => f2sub1.1 (atomKind_castLE _ a)) = fun a => f2sub2.1 (atomKind_castLE _ a)
    rw [f2_sub_atom_eq]
  · funext χ'
    show decide (∃ e, f2sub1.2 e = true ∧ nfk_take (by omega) e = χ') =
      decide (∃ e, f2sub2.2 e = true ∧ nfk_take (by omega) e = χ')
    apply decide_eq_decide.mpr
    exact ((hcomp 12 χ').trans ((f2_proj2_iff χ').trans (hcomp 4 χ').symm))

/-- The env-restriction channel of the probe subs is the anchor 3-type: dropping the fresh
    variable from the arity-4 characteristic recovers `qnf.1` (Def 3.1 env channel). -/
private theorem f2_drop_char (u : ℤ) :
    nf0_dropFresh (nf_characteristic F2M 0 4 (Fin.cons u f2env3)) =
      nf_characteristic F2M 0 3 f2env3 := by
  funext a
  cases a with
  | pred p i =>
    simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
    rfl
  | order i j h =>
    simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
    rfl

/-- Off-fiber clause transfer: `qnf` and `qnf'` have equivalent atom-layer off-fiber falsity
    clauses — un-marking the ON-fiber `sub₂` (whose env restriction IS `qnf.1`,
    `f2_drop_char`) cannot affect any off-fiber sub. -/
private theorem f2_hoff :
    (∀ sub : NormalForm f2sig 1 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ f2qnf.1 → f2qnf.2 sub = false) ↔
    (∀ sub : NormalForm f2sig 1 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ f2qnf'.1 → f2qnf'.2 sub = false) := by
  constructor
  · intro h sub hne
    show (if sub = f2sub2 then false else f2qnf.2 sub) = false
    split
    · rfl
    · exact h sub hne
  · intro h sub hne
    by_cases hs : sub = f2sub2
    · exfalso
      apply hne
      rw [hs]
      show nf0_dropFresh (nf_characteristic F2M 0 4 (Fin.cons 4 f2env3)) =
        nf_characteristic F2M 0 3 f2env3
      exact f2_drop_char 4
    · have hh := h sub hne
      have hunf : f2qnf'.2 sub = (if sub = f2sub2 then false else f2qnf.2 sub) := rfl
      rw [hunf, if_neg hs] at hh
      exact hh

/-- Fiber-existential transfer: every `(zs, χ)` fold bit survives the `sub₂` un-marking —
    the shared-fiber companion `sub₁` (same ordering channel `f2_sub_atom_eq`, same fresh
    projection `f2_sub_proj_eq`, still marked `f2_sub1_marked`) keeps the `(zXW, χ)` bit
    alive; every other fiber is untouched. The machine-checked heart of F2: the carrier's
    fiber-existential read cannot see the un-marking (F1 item 2 at the F-B model). -/
private theorem f2_hb (zs : ZoneSpec 3) (χ : NormalForm f2sig 1 1) :
    (∃ sub : NormalForm f2sig 1 4, f2qnf.2 sub = true ∧
      nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ) ↔
    (∃ sub : NormalForm f2sig 1 4, f2qnf'.2 sub = true ∧
      nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ) := by
  constructor
  · rintro ⟨sub, hm, hz, hp⟩
    by_cases hs : sub = f2sub2
    · subst hs
      refine ⟨f2sub1, ?_, ?_, ?_⟩
      · show (if f2sub1 = f2sub2 then false else f2qnf.2 f2sub1) = true
        rw [if_neg f2_sub_ne]
        exact f2_sub1_marked
      · rw [← hz]
        show nf0_zoneSpec f2sub1.1 = nf0_zoneSpec f2sub2.1
        rw [f2_sub_atom_eq]
      · rw [← hp]
        exact f2_sub_proj_eq
    · refine ⟨sub, ?_, hz, hp⟩
      show (if sub = f2sub2 then false else f2qnf.2 sub) = true
      rw [if_neg hs]
      exact hm
  · rintro ⟨sub, hm, hz, hp⟩
    refine ⟨sub, ?_, hz, hp⟩
    have hunf : f2qnf'.2 sub = (if sub = f2sub2 then false else f2qnf.2 sub) := rfl
    rw [hunf] at hm
    by_cases hs : sub = f2sub2
    · rw [if_pos hs] at hm; exact Bool.noConfusion hm
    · rwa [if_neg hs] at hm

/-- **Carrier equality at the F-B pair**: the current depth-`k` V-carrier cannot distinguish
    `qnf` from `qnf'` — `bracketEndChar_kv_factors` (:3838) instantiated at the machine-checked
    channel agreements above. Holds for EVERY provider family `charF`. -/
private theorem f2_carrier_eq (charF : (j : Nat) → NormalForm f2sig j 1 → Formula) :
    bracketEndChar_kv f2atomMap f2surj charF 2 f2qnf =
      bracketEndChar_kv f2atomMap f2surj charF 2 f2qnf' :=
  bracketEndChar_kv_factors f2atomMap f2surj charF (k := 1) f2qnf f2qnf' rfl f2_hoff f2_hb

/-! ### F2 probe: no `w'` realizes `qnf'` in `M*` — the per-`w'` case analysis -/

/-- Depth-2 evaluation unfold at `qnf'` (definitional). -/
private theorem f2_eval2_qnf' (env : Fin 3 → F2M.carrier) :
    nf_eval_nf F2M 2 3 env f2qnf' ↔
      ((∀ a, atom_eval F2M env a ↔ f2qnf'.1 a = true) ∧
       (∀ sub : NormalForm f2sig 1 4,
         (∃ u : ℤ, nf_eval_nf F2M 1 4 (Fin.cons u env) sub) ↔ f2qnf'.2 sub = true)) :=
  Iff.rfl

/-- Fixed probe atoms, hoisted so their `Fin` proofs are fully elaborated at use sites
    (inline `⟨_, by omega⟩` indices leave metavariables that block `Fin.cons` reduction
    during unification). -/
private abbrev f2a3_xw : AtomKind f2sig 3 := .order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)
private abbrev f2a3_wt : AtomKind f2sig 3 := .order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)
private abbrev f2a3_xt : AtomKind f2sig 3 := .order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)
private abbrev f2a3_wx : AtomKind f2sig 3 := .order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)
private abbrev f2a3_tw : AtomKind f2sig 3 := .order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)
private abbrev f2a3_tx : AtomKind f2sig 3 := .order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)
private abbrev f2a3_P : AtomKind f2sig 3 := .pred () ⟨0, by omega⟩
private abbrev f2a4_xu : AtomKind f2sig 4 := .order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)
private abbrev f2a4_uw : AtomKind f2sig 4 := .order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)
private abbrev f2a4_wu : AtomKind f2sig 4 := .order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)
private abbrev f2a4_ut : AtomKind f2sig 4 := .order ⟨0, by omega⟩ ⟨3, by omega⟩ (by decide)

/-- Atom-bit transfer: a true atom bit of a depth-1 type equal to a characteristic type
    semantically holds in the characteristic's environment. -/
private theorem f2_bit_transfer {n : Nat} (σ : NormalForm f2sig 1 n)
    (env : Fin n → F2M.carrier) (h : σ = nf_characteristic F2M 1 n env)
    (a : AtomKind f2sig n) (hbit : σ.1 a = true) : atom_eval F2M env a :=
  @of_decide_eq_true _ (Classical.dec _) ((congrFun (congrArg Prod.fst h) a).symm.trans hbit)

/-- Quant-bit transfer: a true quant bit of a depth-1 arity-4 type equal to a characteristic
    type is realized in the characteristic's environment. -/
private theorem f2_qbit_transfer (σ : NormalForm f2sig 1 4)
    (env : Fin 4 → F2M.carrier) (h : σ = nf_characteristic F2M 1 4 env)
    (e : NormalForm f2sig 0 5) (hbit : σ.2 e = true) :
    ∃ z : ℤ, nf_eval_nf F2M 0 5 (Fin.cons z env) e :=
  @of_decide_eq_true _ (Classical.dec _)
    ((congrFun (congrArg Prod.snd h) e).symm.trans hbit)

/-- Facts about any fresh witness of `e*` over anchors `[u, w', 2, 18]`: it is a `P`-point
    strictly inside `(2, u)` (read off the depth-0 5-type equality entry by entry). -/
private theorem f2_estar_witness_facts (u w' z : ℤ)
    (hz : f2estar = nf_characteristic F2M 0 5
      (Fin.cons z (Fin.cons u (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ))))))) :
    ((z : ℤ) = 0 ∨ z = 10 ∨ z = 20) ∧ (2 : ℤ) < z ∧ z < u := by
  refine ⟨?_, ?_, ?_⟩
  · have hb := congrFun hz (.pred () ⟨0, by omega⟩)
    simp only [f2estar, nf_characteristic] at hb
    have h10 : (10 : ℤ) = 0 ∨ (10 : ℤ) = 10 ∨ (10 : ℤ) = 20 := by norm_num
    exact (decide_eq_decide.mp hb).mp h10
  · have hb := congrFun hz (.order ⟨3, by omega⟩ ⟨0, by omega⟩ (Fin.ne_of_val_ne (by decide)))
    simp only [f2estar, nf_characteristic] at hb
    have h210 : (2 : ℤ) < 10 := by omega
    exact (decide_eq_decide.mp hb).mp h210
  · have hb := congrFun hz (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (Fin.ne_of_val_ne Nat.zero_ne_one))
    simp only [f2estar, nf_characteristic] at hb
    have h1012 : (10 : ℤ) < 12 := by omega
    exact (decide_eq_decide.mp hb).mp h1012

/-- **`sub₁` forces `w' ≥ 12`**: any realization of `sub₁` over anchors `[w', 2, 18]` needs a
    fresh point `u ∈ (2, w')` whose gap `(2, u)` contains a `P`-point — so `u ≥ 11`, so
    `w' ≥ 12` (report 05 F-B, `w' ≤ 11` branch). -/
private theorem f2_sub1_forces (w' u : ℤ)
    (h : nf_eval_nf F2M 1 4
      (Fin.cons u (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ))))) f2sub1) :
    (2 : ℤ) < u ∧ u < w' ∧ (11 : ℤ) ≤ u := by
  rw [f2_eval_iff_char] at h
  have h2u : (2 : ℤ) < u := by
    have h212 : (2 : ℤ) < 12 := by omega
    have hbit : f2sub1.1 f2a4_xu = true := @decide_eq_true _ (Classical.dec _) h212
    exact f2_bit_transfer _ _ h f2a4_xu hbit
  have huw : u < w' := by
    have h1215 : (12 : ℤ) < 15 := by omega
    have hbit : f2sub1.1 f2a4_uw = true := @decide_eq_true _ (Classical.dec _) h1215
    exact f2_bit_transfer _ _ h f2a4_uw hbit
  obtain ⟨z, hze⟩ := f2_qbit_transfer _ _ h f2estar f2_estar_in_sub1
  rw [f2_eval_iff_char] at hze
  obtain ⟨hPz, h2z, hzu⟩ := f2_estar_witness_facts u w' z hze
  refine ⟨h2u, huw, ?_⟩
  rcases hPz with h0 | h0 | h0 <;> omega

/-- `τ`: the depth-1 arity-4 type of `[16, 15, 2, 18]` (fresh point in the `(w, t)` zone with
    an EMPTY `(w, u)` gap — the discreteness-sensitive entry for the `w' = 17` branch). -/
private noncomputable def f2tau : NormalForm f2sig 1 4 :=
  nf_characteristic F2M 1 4 (Fin.cons 16 f2env3)

/-- `τ ≠ sub₂` (they disagree on the order bit `u < w`). -/
private theorem f2_tau_ne : f2tau ≠ f2sub2 := by
  intro h
  have hb := congrFun (congrArg Prod.fst h) f2a4_uw
  have hn : ¬((16 : ℤ) < 15) := by omega
  have h415 : (4 : ℤ) < 15 := by omega
  have hL : f2tau.1 f2a4_uw = false := @decide_eq_false _ (Classical.dec _) hn
  have hR : f2sub2.1 f2a4_uw = true := @decide_eq_true _ (Classical.dec _) h415
  rw [hL, hR] at hb
  exact Bool.noConfusion hb

/-- `τ` is marked in `qnf` (realized at `u = 16`) hence in `qnf'` (`τ ≠ sub₂`). -/
private theorem f2_tau_marked' : f2qnf'.2 f2tau = true := by
  show (if f2tau = f2sub2 then false else f2qnf.2 f2tau) = true
  rw [if_neg f2_tau_ne, f2qnf_snd]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨16, nf_characteristic_satisfies F2M 1 4 (Fin.cons 16 f2env3)⟩

/-- The `w'`-shift congruence for arity-5 types: transfer of a fresh 5-type between the
    `[4, 15, 2, 18]` anchors and the `[4, w', 2, 18]` anchors (`12 ≤ w' ≤ 16`), given the
    fresh points' matching cell data. -/
private theorem f2_congr5_wshift (w' z z' : ℤ)
    (hw : (12 : ℤ) ≤ w' ∧ w' ≤ 16)
    (hPz : (z = 0 ∨ z = 10 ∨ z = 20) ↔ (z' = 0 ∨ z' = 10 ∨ z' = 20))
    (hz4l : z < 4 ↔ z' < 4) (hz4r : 4 < z ↔ 4 < z')
    (hzw : z < 15 ↔ z' < w') (hwz : 15 < z ↔ w' < z')
    (hz2l : z < 2 ↔ z' < 2) (hz2r : 2 < z ↔ 2 < z')
    (hz18l : z < 18 ↔ z' < 18) (hz18r : 18 < z ↔ 18 < z') :
    nf_characteristic F2M 0 5
        (Fin.cons z (Fin.cons 4 (Fin.cons 15 (Fin.cons 2 (fun _ => (18 : ℤ)))))) =
      nf_characteristic F2M 0 5
        (Fin.cons z' (Fin.cons 4 (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ)))))) :=
  f2_char0_congr5 _ _ _ _ _ _ _ _ _ _
    hPz Iff.rfl (iff_of_false (by decide) (by omega)) Iff.rfl Iff.rfl
    hz4l hz4r hzw hwz hz2l hz2r hz18l hz18r
    (iff_of_true (by decide) (by omega)) (iff_of_false (by decide) (by omega))
    Iff.rfl Iff.rfl Iff.rfl Iff.rfl
    (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) (by omega))
    (iff_of_true (by decide) (by omega)) (iff_of_false (by decide) (by omega))
    Iff.rfl Iff.rfl

/-- **`sub₂` is realized at every `w' ∈ [12, 16]`** (via `u = 4`): the depth-1 arity-4 type of
    `[4, w', 2, 18]` EQUALS `sub₂` — anchor configurations agree, and every realized fresh
    5-type transfers cell-by-cell (`f2_congr5_wshift`; the report's `12 ≤ w' ≤ 15` middle
    branch, extended to 16 where the `(w', 18)` cell is still inhabited). This settles the
    report's honest caveat: the per-entry type-match check SUCCEEDS on this range. -/
private theorem f2_sub2_transfer (w' : ℤ) (h12 : (12 : ℤ) ≤ w') (h16 : w' ≤ 16) :
    f2sub2 = nf_characteristic F2M 1 4
      (Fin.cons 4 (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ))))) := by
  have hw : (12 : ℤ) ≤ w' ∧ w' ≤ 16 := ⟨h12, h16⟩
  refine Prod.ext ?_ ?_
  · show nf_characteristic F2M 0 4 (Fin.cons 4 (Fin.cons 15 (Fin.cons 2 (fun _ => (18 : ℤ))))) =
      nf_characteristic F2M 0 4 (Fin.cons 4 (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ)))))
    exact f2_char0_congr4 _ _ _ _ _ _ _ _
      Iff.rfl (iff_of_false (by decide) (by omega)) Iff.rfl Iff.rfl
      (iff_of_true (by decide) (by omega)) (iff_of_false (by decide) (by omega))
      Iff.rfl Iff.rfl Iff.rfl Iff.rfl
      (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) (by omega))
      (iff_of_true (by decide) (by omega)) (iff_of_false (by decide) (by omega))
      Iff.rfl Iff.rfl
  · funext e
    show (nf_characteristic F2M 1 4 (Fin.cons 4 f2env3)).2 e = _
    simp only [f2char14_snd]
    apply decide_eq_decide.mpr
    constructor
    · rintro ⟨z, hz⟩
      rw [f2_eval_iff_char] at hz
      by_cases hp : (z = 0 ∨ z = 10 ∨ z = 20)
      · -- P-points sit in shift-stable cells: identity witness
        refine ⟨z, ?_⟩
        rw [f2_eval_iff_char, hz]
        rcases hp with h0 | h0 | h0 <;>
          (refine f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega)
      · rcases le_or_gt z 4 with hc | hc
        · refine ⟨z, ?_⟩
          rw [f2_eval_iff_char, hz]
          refine f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega
        · rcases lt_trichotomy z 15 with hc2 | hc2 | hc2
          · refine ⟨5, ?_⟩
            rw [f2_eval_iff_char, hz]
            refine f2_congr5_wshift w' z 5 hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega
          · refine ⟨w', ?_⟩
            rw [f2_eval_iff_char, hz]
            refine f2_congr5_wshift w' z w' hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega
          · rcases lt_or_ge z 18 with hc3 | hc3
            · refine ⟨17, ?_⟩
              rw [f2_eval_iff_char, hz]
              refine f2_congr5_wshift w' z 17 hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega
            · refine ⟨z, ?_⟩
              rw [f2_eval_iff_char, hz]
              refine f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega
    · rintro ⟨z, hz⟩
      rw [f2_eval_iff_char] at hz
      by_cases hp : (z = 0 ∨ z = 10 ∨ z = 20)
      · refine ⟨z, ?_⟩
        rw [f2_eval_iff_char, hz]
        rcases hp with h0 | h0 | h0 <;>
          (refine Eq.symm (f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega)
      · rcases le_or_gt z 4 with hc | hc
        · refine ⟨z, ?_⟩
          rw [f2_eval_iff_char, hz]
          refine Eq.symm (f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega
        · rcases lt_trichotomy z w' with hc2 | hc2 | hc2
          · refine ⟨5, ?_⟩
            rw [f2_eval_iff_char, hz]
            refine Eq.symm (f2_congr5_wshift w' 5 z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega
          · refine ⟨15, ?_⟩
            rw [f2_eval_iff_char, hz]
            refine Eq.symm (f2_congr5_wshift w' 15 z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega
          · rcases lt_or_ge z 18 with hc3 | hc3
            · refine ⟨17, ?_⟩
              rw [f2_eval_iff_char, hz]
              refine Eq.symm (f2_congr5_wshift w' 17 z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega
            · refine ⟨z, ?_⟩
              rw [f2_eval_iff_char, hz]
              refine Eq.symm (f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega

/-- **No `w'` realizes `qnf'` in `M*`** (report 05 F-B case analysis, machine-checked): the
    atom layer pins `w' ∈ (2, 18) \ P`; `sub₁`'s marked bit forces `w' ≥ 12`
    (`f2_sub1_forces`); on `12 ≤ w' ≤ 16` the UN-marked `sub₂` is realized at `u = 4`
    (`f2_sub2_transfer`); at `w' = 17` the marked `τ` needs a fresh point in the EMPTY
    `(17, 18)` gap. -/
private theorem f2_no_witness :
    ¬ ∃ w' : ℤ, nf_eval_nf F2M 2 3
      (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ)))) f2qnf' := by
  rintro ⟨w', hw⟩
  obtain ⟨hA, hQ⟩ := (f2_eval2_qnf' _).mp hw
  -- Step 1: atom-layer constraints on w'
  have h2w : (2 : ℤ) < w' := by
    have h215 : (2 : ℤ) < 15 := by omega
    have hbit : f2qnf'.1 f2a3_xw = true := @decide_eq_true _ (Classical.dec _) h215
    exact (hA f2a3_xw).mpr hbit
  have hw18 : w' < 18 := by
    have h1518 : (15 : ℤ) < 18 := by omega
    have hbit : f2qnf'.1 f2a3_wt = true := @decide_eq_true _ (Classical.dec _) h1518
    exact (hA f2a3_wt).mpr hbit
  have hPw : ¬((w' : ℤ) = 0 ∨ w' = 10 ∨ w' = 20) := by
    intro hcontra
    have hae : atom_eval F2M (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ)))) f2a3_P := hcontra
    have hbit := (hA f2a3_P).mp hae
    have h15P : ¬((15 : ℤ) = 0 ∨ (15 : ℤ) = 10 ∨ (15 : ℤ) = 20) := by omega
    have hfalse : f2qnf'.1 f2a3_P = false :=
      @decide_eq_false _ (Classical.dec _) h15P
    rw [hfalse] at hbit
    exact Bool.noConfusion hbit
  -- Step 2: sub₁'s marked bit forces w' ≥ 12
  have hsub1' : f2qnf'.2 f2sub1 = true := by
    show (if f2sub1 = f2sub2 then false else f2qnf.2 f2sub1) = true
    rw [if_neg f2_sub_ne]
    exact f2_sub1_marked
  obtain ⟨u, hu⟩ := (hQ f2sub1).mpr hsub1'
  obtain ⟨h2u, huw, h11u⟩ := f2_sub1_forces w' u hu
  -- Step 3: split 12 ≤ w' ≤ 16 vs w' = 17
  by_cases h17 : w' = 17
  · -- τ needs a fresh point in the empty (17, 18) gap
    obtain ⟨v, hv⟩ := (hQ f2tau).mpr f2_tau_marked'
    rw [f2_eval_iff_char] at hv
    have hwv : w' < v := by
      have h1516 : (15 : ℤ) < 16 := by omega
      have hbit : f2tau.1 f2a4_wu = true := @decide_eq_true _ (Classical.dec _) h1516
      exact f2_bit_transfer _ _ hv f2a4_wu hbit
    have hv18 : v < 18 := by
      have h1618 : (16 : ℤ) < 18 := by omega
      have hbit : f2tau.1 f2a4_ut = true := @decide_eq_true _ (Classical.dec _) h1618
      exact f2_bit_transfer _ _ hv f2a4_ut hbit
    omega
  · -- 12 ≤ w' ≤ 16: the un-marked sub₂ is realized at u = 4
    have h1216 : (12 : ℤ) ≤ w' ∧ w' ≤ 16 := by omega
    have hreal : ∃ u₀ : ℤ, nf_eval_nf F2M 1 4
        (Fin.cons u₀ (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ))))) f2sub2 := by
      refine ⟨4, ?_⟩
      rw [f2_eval_iff_char]
      exact f2_sub2_transfer w' h1216.1 h1216.2
    have hmarked := (hQ f2sub2).mp hreal
    have hfalse : f2qnf'.2 f2sub2 = false := by
      show (if f2sub2 = f2sub2 then false else f2qnf.2 f2sub2) = false
      rw [if_pos rfl]
    rw [hfalse] at hmarked
    exact Bool.noConfusion hmarked

/-- **Finding F2 verdict theorem (F2 CONFIRMED)**: the UZ/SZ-relativized `k = 2` correctness
    statement for the CURRENT carrier `bracketEndChar_kv` (:3630) is FALSE — for EVERY
    provider family `charF`. See the F2 verdict record below for the four-element defect
    breakdown and routing consequence. -/
theorem f2_relativized_refutation
    (charF : (j : Nat) → NormalForm f2sig j 1 → Formula) :
    ¬ (∀ (qnf : NormalForm f2sig 2 3),
        qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true →
        qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true →
        qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true →
        qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false →
        qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false →
        qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false →
        ∀ (M : OrderedMonadicStructure f2sig),
          semantic_prior_UZ M f2atomMap → semantic_prior_SZ M f2atomMap →
          ∀ (x t : M.carrier),
            ((bracketEndChar_kv f2atomMap f2surj charF 2 qnf).holds M f2atomMap x t ↔
              ∃ w : M.carrier,
                nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)) := by
  intro h
  -- the six bracket-zone order bits of the (shared) atom layer
  have h215 : (2 : ℤ) < 15 := by omega
  have h1518 : (15 : ℤ) < 18 := by omega
  have h218 : (2 : ℤ) < 18 := by omega
  have hn152 : ¬((15 : ℤ) < 2) := by omega
  have hn1815 : ¬((18 : ℤ) < 15) := by omega
  have hn182 : ¬((18 : ℤ) < 2) := by omega
  have hxy : f2qnf.1 f2a3_xw = true := @decide_eq_true _ (Classical.dec _) h215
  have hyt : f2qnf.1 f2a3_wt = true := @decide_eq_true _ (Classical.dec _) h1518
  have hxt : f2qnf.1 f2a3_xt = true := @decide_eq_true _ (Classical.dec _) h218
  have hyx : f2qnf.1 f2a3_wx = false := @decide_eq_false _ (Classical.dec _) hn152
  have hty : f2qnf.1 f2a3_tw = false := @decide_eq_false _ (Classical.dec _) hn1815
  have htx : f2qnf.1 f2a3_tx = false := @decide_eq_false _ (Classical.dec _) hn182
  -- instantiate the statement at qnf and at qnf' (same atom layer), in M* at (x, t) = (2, 18)
  have h1 := h f2qnf hxy hyt hxt hyx hty htx F2M f2_UZ f2_SZ 2 18
  have h2 := h f2qnf' hxy hyt hxt hyx hty htx F2M f2_UZ f2_SZ 2 18
  -- qnf is realized at w = 15, so the carrier holds at (2, 18)
  have hholds : (bracketEndChar_kv f2atomMap f2surj charF 2 f2qnf).holds F2M f2atomMap 2 18 :=
    h1.mpr ⟨15, nf_characteristic_satisfies F2M 2 3 f2env3⟩
  -- the carrier cannot see the un-marking; transport and extract a qnf'-witness
  rw [f2_carrier_eq charF] at hholds
  exact f2_no_witness (h2.mp hholds)

/-! ## Phase 13.0 finding F2 (CONFIRMED): UZ/SZ relativization alone does NOT rescue
the Phase-12 carrier at `k = 2` — statement surgery (Phase 13.1) is necessary but NOT
sufficient; the full ladder 13.2 → 13.3 → 13.4 proceeds

**Def 3.1 evidence first (rule N3)**: Rabinovich's α_j/β_j are ONE-VARIABLE quantifier-free
formulas over the current (round-enriched) vocabulary (Def 3.1, PDF p.4), so the arity-4
residual `[x_1, w, x, t]` whose in-fiber markings the F1/F2 counterexamples toggle had no
Rabinovich counterpart — it is a Lean `nf_eval_nf` arity-growth artifact, and the fold restores
Def-4.1 fidelity only if its E[Σ]-atom channel keeps the joint content the enriched vocabulary
carries (Def 4.1, PDF p.5, read at depth `k` per the **p.6 note** — rule N2; Prop 4.3 (p.6) is
cited ONLY for "the residual is ∨∃∀ over E[Σ] atoms", realized locally via the fold, not via
literal structural induction). Relativizing the correctness statement to Prior structures
(`semantic_prior_UZ`/`semantic_prior_SZ`, PriorDefs:22/:33) does not repair that channel: the
checked refutation `f2_relativized_refutation` (above) instantiates the F1 mechanism inside a
Prior model.

**Machine-checked refutation record (mirrors the F1 four-element bar; NO analysis residue —
every step below is a checked lemma in this section)**:

1. **Counterexample**: `M* = (ℤ, <)`, `P = {0, 10, 20}` (report 05 F-B). `f2_UZ`/`f2_SZ`:
   `M*` satisfies BOTH Prior hypotheses (nonempty `ℤ`-subsets bounded below/above have
   least/greatest elements) — the escape route that disqualified F1's `(ℚ, <)` model (finite
   `P` fails UZ) is closed. `qnf :=` the depth-2 characteristic 3-type of `[w, x, t] =
   [15, 2, 18]`, realized at `w = 15`; `qnf' := qnf` with the `u₂ = 4` sub un-marked.
   `f2_carrier_eq`: the carrier CANNOT distinguish them — `bracketEndChar_kv_factors` (:3838)
   at the checked channel agreements `f2_sub_atom_eq` (ordering + env channels), `f2_sub_proj_eq`
   (fresh point-type channel: `u₁ = 12` and `u₂ = 4` share their complete depth-1 1-type),
   `f2_hoff`, `f2_hb` (the marked `sub₁` keeps every fiber bit alive), with `f2sub1 ≠ f2sub2`
   witnessed by the entry `e*` = "`P z` and `x < z < u`" (`f2_estar_in_sub1` /
   `f2_estar_not_in_sub2` — the `(2, 4)` gap has no `P`-point). `f2_no_witness`: NO `w'`
   realizes `qnf'` — the atom layer pins `w' ∈ (2, 18) \ P`; `f2_sub1_forces` pins `w' ≥ 12`
   (the marked `u₁`-sub needs a `P`-point inside `(2, u)`, so `u ≥ 11`); `f2_sub2_transfer`
   realizes the UN-marked `sub₂` at `u = 4` for every `12 ≤ w' ≤ 16` (the report-05 honest
   caveat resolved AFFIRMATIVELY: the per-entry type-match check SUCCEEDS, cell-by-cell via
   `f2_congr5_wshift`); `w' = 17` dies on `τ`'s empty `(w', t) = (17, 18)` gap
   (`f2_tau_marked'`). The two instances of the relativized `↔` at `(qnf, qnf')` are jointly
   contradictory — for EVERY provider family `charF` (no provider hypothesis is even needed:
   the mechanism never evaluates the carrier's formulas, only its factorization).
2. **Current behavior**: unchanged from F1 item 2 — at successor depth the carrier reads
   `qnf.2` ONLY through the atom-layer off-fiber Prop and the fiber-existential fold bits
   (:3661-3665; machine-checked factorization :3838).
3. **Required behavior**: unchanged from F1 item 3 — the quant layer of `nf_eval_nf` is a
   per-sub BICONDITIONAL over depth-`k` arity-4 subs; at `k ≥ 2` a fiber holds ≥ 2 subs
   differing in deeper joint layers (D7, NfEFold:373) that the carrier cannot see.
4. **Isolation**: the discreteness worry (report 05 F-B caveat: gap-emptiness is
   depth-1-visible in `ℤ`) is REAL but only reshapes which witness kills which `w'`-range
   (`sub₂` covers `12-16` — one more point than the report's density sketch — and the
   discrete-gap type `τ` covers `17`); it does not rescue the carrier. UZ/SZ buys attained
   first/last occurrences (PriorINF:224), NOT the joint deeper structure of same-fiber subs.
   The repair remains the v6 per-sub enriched carrier (`bracketEndChar_kvE`, Phases
   13.2-13.4) — NOT a hypothesis patch, and NOT a gate patch (F1 item 4 stands: no kv-gate
   strengthening).

**Bracket framing citation (rule N1)**: nothing here re-frames the bracket — the carrier under
refutation keeps the two-fixed-endpoint `(z_0, z_1)` framing of **Lemma 3.2(2) (PDF p.4) + the
§5 bracket notation (PDF p.7)**, with **Prop 3.5 (PDF p.5)** cited only for the
one-free-variable ∃-witness→Until/Since folding mechanism.

**Verdict and routing (plan v6 Phase 13.0 three-way gate)**: **F2 CONFIRMED** — the
UZ/SZ-relativized `k = 2` correctness statement for `bracketEndChar_kv` is FALSE
(`f2_relativized_refutation`; `lean_verify` axioms exactly
`[propext, Classical.choice, Quot.sound]`). Routing consequence: proceed to Phase 13.1
(statement surgery: `ExistProviders` + `BracketCarrierCorrectVPrior`) AND the FULL ladder
13.2 → 13.3 → 13.4 → 14. Do NOT collapse to surgery-only; do NOT strengthen the kv gate. -/

end Bimodal.Metalogic.WeakCanonical.Kamp
