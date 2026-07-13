import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.EndIntervalConsumerK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA

/-! # Aggregate quantEnd/seg construction + arm-correctness hook discharge at k=0/k=1 (task 350)

Builds the aggregate ∀-qnf population encoding for the `KampPrior.lean:361` `| 1 =>` arm and
discharges the three arm-correctness hooks (past / diagonal / future) as separate green citable
lemmas at match arms k=0 (`sub_nf : NormalForm sig 1 2`) and k=1 (`sub_nf : NormalForm sig 2 2`),
each concluding in the `kampPrior_case1_trichotomy_assemble` skeleton shape
(`KampPrior.lean:1146`; disjunct shapes from `kampPrior_site_trichotomy`, `KampPrior.lean:677`).

## Phase-1 adjudication record (task 350, R1/R2/aggregation verdicts — BINDING)

**R1 verdict (Route V confirmed; Route P refuted for interior-positive populations).** The
literal P4/P5 `h_quant` binder pair `(quantEnd : TemporalPred) × (seg : BracketFormula 0)`
(`nf_char2_past_formula_correct`, Base.lean:1262; `nf_char2_future_formula_correct`,
Base.lean:1462) cannot host interior-POSITIVE population clauses: a `BracketFormula 0` has NO
point slots (`IntervalPattern.holds` at `n = 0` is purely the universal segment form,
ExistsForallNF:106-112), so it can carry only universal-over-interval exclusions, and a closed
`quantEnd` evaluated at the bound witness `x` cannot lay a SECOND witness strictly between `x`
and the origin `t` (the interior-zone existential `∃ v, x < v ∧ v < t ∧ …` needs a bracket
POINT slot — §5 bracket notation, Rabinovich 2014 PDF p.7). Any population `sub_nf` with a
positive interior fiber therefore escapes the pair shape. The primary assembly (Route V) builds
the arm at the `VVecEA2` level — interior-positive fibers occupy bracket WITNESS slots over
arrangements, exactly the `bracketEndChar_k1v` device (`CarrierK1V.lean:433`) one arity down —
and enters the skeleton via `VVecEA2.translateRight_correct` (NfToVecEA.lean:451) /
`VVecEA2.translateLeft_correct` (VecEATranslation.lean:549). The DoD binds only the
skeleton-shaped conclusions, which Route V produces directly.

**R2 verdict (A_diag_correct per-point hooks undischargeable; additive diag variant landed).**
`A_diag_correct`'s hooks (Base.lean:765-773) demand, for a FIXED syntactic
`pastEnd : NormalForm sig k 3 → TemporalPred`, the per-point biconditional
`∀ w < t, (pastEnd qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf`.
This is the free-anchor obstruction machine-established by `endChar0_correct`'s counterexample
record (Base.lean:1068-1079) and by the sorry-free refutation pair
`endCharN0_correct_world_local_obstruction` / `endCharN0_correct_infeasible`
(Base.lean:1777/1811): `(pastEnd qnf).eval_at M atomMap w` depends only on the single world `w`,
while the RHS constrains the predicate layer at the anchor position `t` (indices 1, 2 of the
env `[w, t, t]`) — no choice of closed `pastEnd` can bridge this. The diag arms below therefore
do NOT instantiate `A_diag_correct`; they land additive variants with the same skeleton-shaped
conclusion (`temporal_truth M atomMap t … ↔ nf_eval_nf M (k+1) 2 (Fin.cons t (fun _ => t))
sub_nf`), which is the shape task-309 Phase 18b consumes. The hooks are thereby discharged in
the sense that binds (conclusion, not binder).

**Aggregation verdict (plan deviation, recorded per R7).** The plan's Phase-2 aggregation
combinator `VVecEA2.conj_struct` (VecEAClosure.lean:195) is ONE-directional (its `n1+1, n2+1`
case discards the second bracket's content — `conj_struct_holds` proves only `holds → holds →
holds` of the conjunction, never the converse), and the Prop 4.2 negation closure
(`neg_2var_vec_ea`, EANegationClosure.lean:722) is MODEL-DEPENDENT (existential `∃ v'`, not a
fixed syntactic object) — neither can assemble a fixed formula with a biconditional correctness
statement. The k=0 aggregate is instead built as a SINGLE global object via the depth-1 fold
engine (`nf_eval_depth1_fold_iff`, CarrierKv.lean:466): the whole population
`∀ qnf : NormalForm sig 0 3, ((∃ w, nf_eval_nf M 0 3 (zoneEnv3 w x t) qnf) ↔ sub_nf.2 qnf)`
re-fibers losslessly (depth-0 split-kit bijection, `nf0_split_assemble`, NfEFold:235) into
zone-bounded MONADIC fibers `(zs : ZoneSpec 2) × (χ : NormalForm sig 0 1)`, encoded by the
`kv_body` device one arity down: biconditional `lit` literals at the two fixed anchors
(Since/Until for the exterior zones, plain characteristics for the point zones), one uniform
exclusion segment plus arrangement witness slots for the single interior zone, and the
two-conjunct gate (off-fiber honesty + order-conflict falsity). No `VVecEA2` conjunction and no
negation closure is needed. This realizes the plan's per-qnf 5-zone routing (the five zones ARE
the order-consistent `ZoneSpec 2` values) with strictly fewer moving parts.

## The six target statements (Phase 1 freeze — shapes BINDING for Phases 2-5)

Conclusion shapes copied verbatim from the `kampPrior_site_trichotomy` disjuncts
(KampPrior.lean:677-684); `h_UZ`/`h_SZ` are carried (unused) so the statements slot directly
under the Prior-guarded skeleton. Delivered by Phase 3 (k=0) and Phase 5 (k=1):

```
theorem kampArm_past_k0_correct …  (sub_nf : NormalForm sig 1 2) :
  ∀ M (_h_UZ : semantic_prior_UZ M atomMap) (_h_SZ : semantic_prior_SZ M atomMap) t,
    temporal_truth M atomMap t (kampArm_past_k0 atomMap h_surj sub_nf) ↔
      ∃ x, x < t ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf

theorem kampArm_diag_k0_correct …  (sub_nf : NormalForm sig 1 2) :
  ∀ M _h_UZ _h_SZ t,
    temporal_truth M atomMap t (kampArm_diag_k0 atomMap h_surj sub_nf) ↔
      nf_eval_nf M 1 2 (Fin.cons t (fun _ => t)) sub_nf

theorem kampArm_future_k0_correct …  (sub_nf : NormalForm sig 1 2) :
  ∀ M _h_UZ _h_SZ t,
    temporal_truth M atomMap t (kampArm_future_k0 atomMap h_surj sub_nf) ↔
      ∃ x, t < x ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf
```

and the three `_k1` analogs with `sub_nf : NormalForm sig 2 2` and `nf_eval_nf M 2 2`.

## Guards

G1 — every population obligation stays the honest arity-3 existential (re-fibered losslessly by
the depth-0 split kit, never arity-collapsed). G2/G4 — anchors exactly `{x, t}`; every interior
point is a bracket witness slot. G3 — the interior segment is the genuine per-population
exclusion type, never `TemporalPred.top`. G5 — every Cor 5.4 chain step below is a manual
`constructor`/`intro`/`exact` bridge. FORBIDDEN `nf_char3_deeper_split` is not referenced.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem": Cor 5.4 (the all-order-patterns clause — the
  population match IS its "for every order pattern" clause), Def 3.1 (order-zone channel),
  Lemma 3.2(2) + §5 bracket notation (two-fixed-endpoint framing), Prop 3.5 (∃-witness →
  Until/Since folding mechanism).
- specs/350_…/plans/01_aggregate-quantend-hook-discharge.md
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Phase 1a — arity-2 zone-spec constants (the per-qnf order-bit classifier)

The five order-consistent `ZoneSpec 2` values per ambient anchor order, relative to the env
`[x, t]` (position 0 = the bound witness anchor `x`, position 1 = the origin `t`). These ARE
the plan's per-qnf 5-zone classifier: under the fold re-fibering, a population member's zone
class is exactly the `ZoneSpec 2` channel of its `nf0_zoneSpec` (Def 3.1 ordering channel,
PDF p.4), and the classifier's "inconsistent-given-ambient-order" verdict is the consistency
lemmas `agg2_zone_consistent_lt`/`_gt`/`_diag` below. -/

/-- Witness strictly below the env point (`v < env i`). -/
def agg2Ltz : Bool × Bool := (true, false)
/-- Witness at the env point (`v = env i`). -/
def agg2Eqz : Bool × Bool := (false, false)
/-- Witness strictly above the env point (`env i < v`). -/
def agg2Gtz : Bool × Bool := (false, true)
/-- Zone-spec builder for the arity-2 env `[x, t]`. -/
def agg2Mk (px pt : Bool × Bool) : ZoneSpec 2 := Fin.cons px (fun _ => pt)

/-- `v < x` (past exterior of the witness anchor; under `x < t` also `v < t`;
    under `t < x` this is the `v < t` past-exterior-of-origin zone only when
    combined with `agg2Ltz` at position 1 — see the consistency lemmas). -/
def agg2ZPastPast : ZoneSpec 2 := agg2Mk agg2Ltz agg2Ltz
/-- `v = x ∧ v < t` (at the witness anchor, past-arm ambient `x < t`). -/
def agg2ZAtXPast : ZoneSpec 2 := agg2Mk agg2Eqz agg2Ltz
/-- `x < v < t` (bounded interior, past-arm ambient `x < t`). -/
def agg2ZIntPast : ZoneSpec 2 := agg2Mk agg2Gtz agg2Ltz
/-- `x < v ∧ v = t` (at the origin, past-arm ambient `x < t`). -/
def agg2ZAtTPast : ZoneSpec 2 := agg2Mk agg2Gtz agg2Eqz
/-- `x < v ∧ t < v` (future exterior of both anchors). -/
def agg2ZFutFut : ZoneSpec 2 := agg2Mk agg2Gtz agg2Gtz
/-- `v < x ∧ v = t` (at the origin, future-arm ambient `t < x`). -/
def agg2ZAtTFut : ZoneSpec 2 := agg2Mk agg2Ltz agg2Eqz
/-- `v < x ∧ t < v` (bounded interior, future-arm ambient `t < x`). -/
def agg2ZIntFut : ZoneSpec 2 := agg2Mk agg2Ltz agg2Gtz
/-- `v = x ∧ t < v` (at the witness anchor, future-arm ambient `t < x`). -/
def agg2ZAtXFut : ZoneSpec 2 := agg2Mk agg2Eqz agg2Gtz
/-- `v = x = t` (the point zone of the diagonal ambient `x = t`). -/
def agg2ZAtDiag : ZoneSpec 2 := agg2Mk agg2Eqz agg2Eqz

/-- Pointwise reading of an arity-2 `zoneHolds` over the two-anchor env `[x, t]`
    (the `n = 2` analog of the k1v cons-iff; Def 3.1 ordering channel, PDF p.4). -/
theorem agg2_zoneHolds_cons_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x t u : M.carrier) (px pt : Bool × Bool) :
    zoneHolds M (Fin.cons x (fun _ => t) : Fin 2 → M.carrier)
      (Fin.cons px (fun _ => pt) : ZoneSpec 2) u ↔
    (((u < x) ↔ px.1 = true) ∧ ((x < u) ↔ px.2 = true)) ∧
    (((u < t) ↔ pt.1 = true) ∧ ((t < u) ↔ pt.2 = true)) := by
  constructor
  · intro h
    have h0 := h ⟨0, by omega⟩
    have h1 := h ⟨1, by omega⟩
    simp only [Fin.cons] at h0 h1
    exact ⟨h0, h1⟩
  · rintro ⟨h0, h1⟩ i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using h0
    | ⟨1, _⟩ => simpa only [Fin.cons] using h1

/-- Pointwise equality builder for an arity-2 zone spec from its two coordinates. -/
private theorem agg2_zs_ext {zs : ZoneSpec 2} (px pt : Bool × Bool)
    (e0 : zs ⟨0, by omega⟩ = px) (e1 : zs ⟨1, by omega⟩ = pt) :
    zs = agg2Mk px pt := by
  funext i
  match i with
  | ⟨0, _⟩ => simpa only [agg2Mk, Fin.cons] using e0
  | ⟨1, _⟩ => simpa only [agg2Mk, Fin.cons] using e1

/-! ## Phase 1b — routing lemmas: zone consistency per ambient anchor order

Any zone spec realized over `[x, t]` is one of the five (three on the diagonal)
order-consistent zones of the ambient anchor order; contrapositively, the fold bit of every
inconsistent spec is forced `false` (the gate's order-conflict conjunct), which is exactly the
plan's "collapses … to `False` for inconsistent patterns" routing. Def 3.1 (PDF pp.4-5):
disjunctions range only over consistent order types. -/

/-- **Past-arm routing lemma** (`x < t`): a realized arity-2 zone spec is one of the five
    consistent zones `v<x` / `v=x` / `x<v<t` / `v=t` / `t<v`. -/
theorem agg2_zone_consistent_lt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x t u : M.carrier) (hxt : x < t)
    (zs : ZoneSpec 2)
    (hz : zoneHolds M (Fin.cons x (fun _ => t)) zs u) :
    zs = agg2ZPastPast ∨ zs = agg2ZAtXPast ∨ zs = agg2ZIntPast ∨
    zs = agg2ZAtTPast ∨ zs = agg2ZFutFut := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  simp only [Fin.cons] at h0 h1
  rcases lt_trichotomy u x with hux | hux | hux
  · -- u < x < t : zone `v < x`.
    have hut : u < t := hux.trans hxt
    exact Or.inl (agg2_zs_ext _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hux, k1v_bool_eq_false h0.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hut, k1v_bool_eq_false h1.2 (lt_asymm hut)⟩))
  · -- u = x : zone `v = x`.
    subst hux
    exact Or.inr (Or.inl (agg2_zs_ext _ _
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
        k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hxt, k1v_bool_eq_false h1.2 (lt_asymm hxt)⟩)))
  · -- x < u : split against t.
    rcases lt_trichotomy u t with hut | hut | hut
    · -- x < u < t : bounded interior.
      exact Or.inr (Or.inr (Or.inl (agg2_zs_ext _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hux), h0.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp hut, k1v_bool_eq_false h1.2 (lt_asymm hut)⟩))))
    · -- u = t : zone `v = t`.
      subst hut
      exact Or.inr (Or.inr (Or.inr (Or.inl (agg2_zs_ext _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hux), h0.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
          k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)))))
    · -- t < u : future exterior.
      exact Or.inr (Or.inr (Or.inr (Or.inr (agg2_zs_ext _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hux), h0.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hut), h1.2.mp hut⟩)))))

/-- **Future-arm routing lemma** (`t < x`): a realized arity-2 zone spec is one of the five
    consistent zones `v<t` / `v=t` / `t<v<x` / `v=x` / `x<v`. -/
theorem agg2_zone_consistent_gt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x t u : M.carrier) (htx : t < x)
    (zs : ZoneSpec 2)
    (hz : zoneHolds M (Fin.cons x (fun _ => t)) zs u) :
    zs = agg2ZPastPast ∨ zs = agg2ZAtTFut ∨ zs = agg2ZIntFut ∨
    zs = agg2ZAtXFut ∨ zs = agg2ZFutFut := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  simp only [Fin.cons] at h0 h1
  rcases lt_trichotomy u t with hut | hut | hut
  · -- u < t < x : zone `v < t`.
    have hux : u < x := hut.trans htx
    exact Or.inl (agg2_zs_ext _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hux, k1v_bool_eq_false h0.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hut, k1v_bool_eq_false h1.2 (lt_asymm hut)⟩))
  · -- u = t : zone `v = t`.
    subst hut
    exact Or.inr (Or.inl (agg2_zs_ext _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp htx, k1v_bool_eq_false h0.2 (lt_asymm htx)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
        k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)))
  · -- t < u : split against x.
    rcases lt_trichotomy u x with hux | hux | hux
    · -- t < u < x : bounded interior.
      exact Or.inr (Or.inr (Or.inl (agg2_zs_ext _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp hux, k1v_bool_eq_false h0.2 (lt_asymm hux)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hut), h1.2.mp hut⟩))))
    · -- u = x : zone `v = x`.
      subst hux
      exact Or.inr (Or.inr (Or.inr (Or.inl (agg2_zs_ext _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
          k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hut), h1.2.mp hut⟩)))))
    · -- x < u : future exterior.
      exact Or.inr (Or.inr (Or.inr (Or.inr (agg2_zs_ext _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hux), h0.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hut), h1.2.mp hut⟩)))))

/-- **Diagonal routing lemma** (env `[t, t]`): a realized arity-2 zone spec is one of the
    three consistent zones `v<t` / `v=t` / `t<v`. -/
theorem agg2_zone_consistent_diag {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (t u : M.carrier)
    (zs : ZoneSpec 2)
    (hz : zoneHolds M (Fin.cons t (fun _ => t)) zs u) :
    zs = agg2ZPastPast ∨ zs = agg2ZAtDiag ∨ zs = agg2ZFutFut := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  simp only [Fin.cons] at h0 h1
  rcases lt_trichotomy u t with hut | hut | hut
  · exact Or.inl (agg2_zs_ext _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hut, k1v_bool_eq_false h0.2 (lt_asymm hut)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hut, k1v_bool_eq_false h1.2 (lt_asymm hut)⟩))
  · subst hut
    exact Or.inr (Or.inl (agg2_zs_ext _ _
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
        k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
        k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)))
  · exact Or.inr (Or.inr (agg2_zs_ext _ _
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hut), h0.2.mp hut⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hut), h1.2.mp hut⟩)))

/-! ## Phase 1c — the uniform-segment list bracket (interior arrangement carrier)

The single-interior-zone analog of `bracketFromLists` (CarrierK1V.lean:389): point types are
an ordered list `l` of interior-positive complete types (one bracket WITNESS slot per positive
fiber — §5 bracket `[α_0, …, α_n](z_0, z_1)`, PDF p.7), and EVERY segment carries the single
uniform exclusion type `seg` (G3: the genuine per-population exclusion, never top). There is
no distinguished middle point — the aggregate lays no `w` of its own. -/

/-- List bracket with uniform segment type. -/
def aggBracket (l : List TemporalPred) (seg : TemporalPred) : BracketFormula l.length where
  pointTypes := fun i => l[i.val]'(i.isLt)
  segmentTypes := fun _ => seg

/-- **Extraction** for `aggBracket`: from its `holds` on `(z0, z1)`, every listed point type is
    realized strictly inside `(z0, z1)`, and every point of `(z0, z1)` either satisfies the
    uniform segment type or realizes some listed point type (the witness/gap classification). -/
theorem aggBracket_extract {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l : List TemporalPred) (seg : TemporalPred) (z0 z1 : M.carrier)
    (h : (aggBracket l seg).holds M atomMap z0 z1) :
    (∀ p ∈ l, ∃ u, z0 < u ∧ u < z1 ∧ p.eval_at M atomMap u) ∧
    (∀ u, z0 < u → u < z1 →
      seg.eval_at M atomMap u ∨ ∃ p ∈ l, p.eval_at M atomMap u) := by
  match l with
  | [] =>
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, aggBracket,
      IntervalPattern.holds] at h
    refine ⟨fun p hp => absurd hp (List.not_mem_nil), fun u h0 h1 => Or.inl (h u h0 h1)⟩
  | q :: l' =>
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, aggBracket] at h
    rw [IntervalPattern.holds_eq_succ M atomMap _ _ z0 z1
      (show (q :: l').length = l'.length + 1 from rfl)] at h
    obtain ⟨ws, hmono, hrange, hpt, hseg0, hsegmid, hseglast⟩ := h
    have hpt' : ∀ (i : Nat) (hi : i < l'.length + 1),
        ((q :: l')[i]'(by simpa using hi)).eval_at M atomMap (ws ⟨i, hi⟩) :=
      fun i hi => hpt ⟨i, hi⟩
    constructor
    · -- Every listed point type is realized at its witness slot.
      intro p hp
      obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hp
      exact ⟨ws ⟨j, by simpa using hj⟩, (hrange ⟨j, by simpa using hj⟩).1,
        (hrange ⟨j, by simpa using hj⟩).2, hpt' j (by simpa using hj)⟩
    · -- Witness/gap classification via ascent along the witness tuple.
      intro u h0 h1
      have main : ∀ j (hj : j < l'.length + 1), u < ws ⟨j, hj⟩ →
          seg.eval_at M atomMap u ∨ ∃ p ∈ q :: l', p.eval_at M atomMap u := by
        intro j
        induction j with
        | zero =>
          intro hj hu0
          exact Or.inl (hseg0 u h0 hu0)
        | succ j ih =>
          intro hj hu
          rcases lt_trichotomy u (ws ⟨j, by omega⟩) with h' | h' | h'
          · exact ih (by omega) h'
          · -- `u` IS witness `j`.
            refine Or.inr ⟨(q :: l')[j]'(by simpa using (show j < l'.length + 1 by omega)),
              List.getElem_mem _, ?_⟩
            have := hpt' j (by omega)
            rwa [← h'] at this
          · -- `ws j < u < ws (j+1)`: interior gap carries `seg`.
            exact Or.inl (hsegmid ⟨j, by omega⟩ u h' hu)
      rcases lt_trichotomy u (ws ⟨l'.length, by omega⟩) with h' | h' | h'
      · exact main l'.length (by omega) h'
      · refine Or.inr ⟨(q :: l')[l'.length]'(by simp),
          List.getElem_mem _, ?_⟩
        have := hpt' l'.length (by omega)
        rwa [← h'] at this
      · exact Or.inl (hseglast u h' h1)

/-- **Construction** for `aggBracket` (the reverse of `aggBracket_extract`): a sorted tagged
    realization of the point-type list, with the uniform segment type holding on ALL of
    `(z0, z1)`, yields the bracket's `holds`. (The uniform exclusion segment holds at the
    witness points too — a point of a MARKED complete type satisfies every unmarked type's
    negation — so the caller may supply the segment on the whole interval.) -/
theorem aggBracket_construct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l : List TemporalPred) (seg : TemporalPred) (z0 z1 : M.carrier)
    (us : List M.carrier) (hlen : us.length = l.length)
    (hsort : us.Pairwise (· < ·))
    (hrange : ∀ u ∈ us, z0 < u ∧ u < z1)
    (hpt : ∀ (i : Nat) (hi : i < l.length),
      (l[i]'hi).eval_at M atomMap (us[i]'(by omega)))
    (hseg : ∀ u, z0 < u → u < z1 → seg.eval_at M atomMap u) :
    (aggBracket l seg).holds M atomMap z0 z1 := by
  match l, us, hlen with
  | [], [], _ =>
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, aggBracket,
      IntervalPattern.holds]
    exact fun y hy0 hy1 => hseg y hy0 hy1
  | q :: l', us, hlen =>
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, aggBracket]
    rw [IntervalPattern.holds_eq_succ M atomMap _ _ z0 z1
      (show (q :: l').length = l'.length + 1 from rfl)]
    have hlen' : us.length = l'.length + 1 := by simpa using hlen
    refine ⟨fun i => us[i.val]'(by omega), ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro i j hij
      exact List.pairwise_iff_getElem.mp hsort i.val j.val (by omega) (by omega)
        (Fin.lt_def.mp hij)
    · intro i
      exact hrange _ (List.getElem_mem _)
    · intro i
      have := hpt i.val (by simp only [List.length_cons]; exact i.isLt)
      exact this
    · intro y hy0 hy1
      exact hseg y hy0 (hy1.trans (hrange _ (List.getElem_mem _)).2)
    · intro i y hlo hhi
      exact hseg y ((hrange _ (List.getElem_mem _)).1.trans hlo)
        (hhi.trans (hrange _ (List.getElem_mem _)).2)
    · intro y hlo hy1
      exact hseg y ((hrange _ (List.getElem_mem _)).1.trans hlo) hy1

end Bimodal.Metalogic.WeakCanonical.Kamp
