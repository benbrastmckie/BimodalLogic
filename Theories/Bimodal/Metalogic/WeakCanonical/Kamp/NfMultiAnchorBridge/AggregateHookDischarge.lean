import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.EndIntervalConsumerK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA

/-! # Aggregate quantEnd/seg construction + arm-correctness hook discharge at k=0/k=1

Builds the aggregate ∀-qnf population encoding for the `KampPrior.lean:361` `| 1 =>` arm and
discharges the three arm-correctness hooks (past / diagonal / future) as separate green citable
lemmas at match arms k=0 (`sub_nf : NormalForm sig 1 2`) and k=1 (`sub_nf : NormalForm sig 2 2`),
each concluding in the `kampPrior_case1_trichotomy_assemble` skeleton shape
(`KampPrior.lean:1146`; disjunct shapes from `kampPrior_site_trichotomy`, `KampPrior.lean:677`).

## Phase-1 adjudication record (R1/R2/aggregation verdicts — BINDING)

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
sub_nf`), which is the shape downstream assembly consumes. The hooks are thereby discharged in
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
- The aggregate quantEnd/hook-discharge design: the R1/R2/aggregation verdicts are transcribed
  verbatim into the Phase-1 adjudication record above.
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
theorem agg2_zoneHolds_cons_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem agg2_zone_consistent_lt {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem agg2_zone_consistent_gt {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem agg2_zone_consistent_diag {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem aggBracket_extract {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem aggBracket_construct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

/-! ## Phase 2a — the k=0 PAST-arm aggregate carrier (`x < t` ambient)

The "aggregate quantEnd/seg construction" at depth 0, past arm: a single `VVecEA2` whose
Since-direction semantics `holdsRight` at the origin `t` is EXACTLY the past trichotomy
disjunct `∃ x, x < t ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf`. Built by the
`kv_body` device one arity down (`bracketEndChar_k1v`, CarrierK1V.lean:433, is the template):

- fold bits `agg2Bit` read `sub_nf.2` POINTWISE through the depth-0 split kit (`nf0_assemble`
  — lossless at depth 1, `nf0_split_assemble`); every read of `sub_nf.2` goes through them;
- `endpointLeft` (at the laid witness `x`): the off-diagonal endpoint atom locus
  (`nf_char2_atom_offdiag_endpoint`) + the `v<x` Since literals + the `v=x` characteristic
  literals (Prop 3.5 folding mechanism — the anchor IS the laid endpoint);
- `endpointRight` (at the origin `t`): the off-diagonal origin atom locus (with its
  off-diagonal order guard) + the `v=t` characteristic literals + the `t<v` Until literals;
- ONE interior zone `x<v<t`: positive fibers occupy bracket WITNESS slots over all
  arrangements (`aggBracket` over `S.permutations` — §5 bracket, Lemma 3.4); negative fibers
  ride the uniform exclusion segment (G3);
- gate: off-fiber honesty + order-conflict falsity (5 consistent zones,
  `agg2_zone_consistent_lt`); off-gate the carrier is the empty disjunction. -/

section AggPastK0

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-- Pointwise fold-bit read of the depth-1 population (lossless at depth 1 — the depth-0
    split-kit bijection `nf0_split_assemble`; Def 4.1 monadic-atom fold, PDF p.5). -/
noncomputable def agg2Bit (sub_nf : NormalForm sig 1 2) :
    ZoneSpec 2 → NormalForm sig 0 1 → Bool :=
  fun zs χ => sub_nf.2 (nf0_assemble zs χ (sub_nf.1 : NormalForm sig 0 2))

/-- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5). -/
def agg2Lit (bit : Bool) (f : Formula) : Formula := if bit then f else f.neg

/-- Interior-positive enumeration for the past arm (duplicate-free). -/
noncomputable def agg2SPast (sub_nf : NormalForm sig 1 2) : List (NormalForm sig 0 1) :=
  (Finset.univ.toList : List (NormalForm sig 0 1)).filter
    (fun χ => agg2Bit sub_nf agg2ZIntPast χ)

/-- Past-arm left endpoint predicate (at the laid witness `x`): endpoint atom locus +
    `v<x` Since literals + `v=x` characteristic literals. -/
noncomputable def agg2EpPastL (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : TemporalPred :=
  ⟨formula_conjList
    (((nf_char2_atom_offdiag_endpoint atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)).formula
      :: (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
          agg2Lit (agg2Bit sub_nf agg2ZPastPast χ)
            (Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top)))
      ++ (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
          agg2Lit (agg2Bit sub_nf agg2ZAtXPast χ)
            (nf_depth0_char_formula atomMap h_surj χ)))⟩

/-- Past-arm right endpoint predicate (at the origin `t`): origin atom locus (off-diagonal
    order guard) + `v=t` characteristic literals + `t<v` Until literals. -/
noncomputable def agg2EpPastR (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : TemporalPred :=
  ⟨formula_conjList
    ((nf_char2_atom_offdiag_origin atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)
      :: (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
          agg2Lit (agg2Bit sub_nf agg2ZAtTPast χ)
            (nf_depth0_char_formula atomMap h_surj χ)))
      ++ (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
          agg2Lit (agg2Bit sub_nf agg2ZFutFut χ)
            (Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top)))⟩

/-- Past-arm uniform interior exclusion segment (negative fibers; G3 — genuine content,
    never top). -/
noncomputable def agg2SegPast (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : TemporalPred :=
  ⟨formula_conjList ((Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
    if agg2Bit sub_nf agg2ZIntPast χ then Formula.top
    else (nf_depth0_char_formula atomMap h_surj χ).neg))⟩

/-- Past-arm gate: off-fiber honesty + order-conflict falsity over the five consistent
    zones of the `x < t` ambient (Def 3.1: disjunctions range only over consistent order
    types). -/
def agg2GatePast (sub_nf : NormalForm sig 1 2) : Prop :=
  (∀ τ : NormalForm sig 0 3,
      nf0_dropFresh τ ≠ (sub_nf.1 : NormalForm sig 0 2) → sub_nf.2 τ = false) ∧
  (∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
    ¬(zs = agg2ZPastPast ∨ zs = agg2ZAtXPast ∨ zs = agg2ZIntPast ∨
      zs = agg2ZAtTPast ∨ zs = agg2ZFutFut) →
    agg2Bit sub_nf zs χ = false)

/-- **The k=0 past-arm aggregate carrier** (the "aggregate quantEnd/seg construction",
    past arm at depth 0). See the section header for the construction record. -/
noncomputable def agg2Past (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : VVecEA2 :=
  @dite _ (agg2GatePast sub_nf) (Classical.dec _)
    (fun _ =>
      { disjuncts := (agg2SPast sub_nf).permutations.map (fun l =>
          ⟨(l.map (fun χ =>
              (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))).length,
            { endpointLeft := agg2EpPastL atomMap h_surj sub_nf
              endpointRight := agg2EpPastR atomMap h_surj sub_nf
              bracket := aggBracket
                (l.map (fun χ =>
                  (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred)))
                (agg2SegPast atomMap h_surj sub_nf) }⟩) })
    (fun _ => { disjuncts := [] })

/-- **Correctness of the k=0 past-arm aggregate** (`aggPop0` + arm assembly in one): the
    carrier's Since-direction semantics at the origin `t` is exactly the past trichotomy
    disjunct. This is the population-match encoding (Rabinovich Cor 5.4's "for every order
    pattern" clause) fused with the off-diagonal atom layer, quantified through the laid
    witness `x < t`. Every Cor 5.4 chain step is a manual bridge (G5). -/
theorem agg2Past_holdsRight_iff (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (M : OrderedMonadicStructure sig) (t : M.carrier) :
    (agg2Past atomMap h_surj sub_nf).holdsRight M atomMap t ↔
      ∃ x : M.carrier, x < t ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf := by
  -- Complete-type correctness bridge (char χ at u ↔ arity-1 depth-0 evaluation).
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ') ↔
      nf_eval_nf M 0 1 (fun _ => u) χ' :=
    fun χ' u => nfPred_correct M atomMap h_surj χ' u
  constructor
  · -- Soundness (holdsRight → the past disjunct).
    intro h
    obtain ⟨vea, hmem, hveaR⟩ := h
    unfold agg2Past at hmem
    split at hmem
    case isFalse hg => simp at hmem
    case isTrue hg =>
    rw [List.mem_map] at hmem
    obtain ⟨l, hlp, hEq⟩ := hmem
    subst hEq
    obtain ⟨hepR, x, hxt, hepL, hbr⟩ := hveaR
    -- Unfold the two endpoint conjunction lists.
    simp only [agg2EpPastL, agg2EpPastR, TemporalPred.eval_at] at hepL hepR
    rw [formula_conjList_iff] at hepL hepR
    -- Heads: the off-diagonal atom loci.
    have hendp : temporal_truth M atomMap x
        (nf_char2_atom_offdiag_endpoint atomMap h_surj
          (sub_nf.1 : NormalForm sig 0 2)).formula :=
      hepL _ (List.mem_append_left _ List.mem_cons_self)
    have horig : temporal_truth M atomMap t
        (nf_char2_atom_offdiag_origin atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)) :=
      hepR _ (List.mem_append_left _ List.mem_cons_self)
    -- Fold-bit literal facts at the two anchors.
    have hPastLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap x
        (agg2Lit (agg2Bit sub_nf agg2ZPastPast χ)
          (Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top)) :=
      fun χ => hepL _ (List.mem_append_left _
        (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
    have hAtXLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap x
        (agg2Lit (agg2Bit sub_nf agg2ZAtXPast χ)
          (nf_depth0_char_formula atomMap h_surj χ)) :=
      fun χ => hepL _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
    have hAtTLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap t
        (agg2Lit (agg2Bit sub_nf agg2ZAtTPast χ)
          (nf_depth0_char_formula atomMap h_surj χ)) :=
      fun χ => hepR _ (List.mem_append_left _
        (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
    have hFutLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap t
        (agg2Lit (agg2Bit sub_nf agg2ZFutFut χ)
          (Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top)) :=
      fun χ => hepR _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
    -- Bracket structure: witnesses + gap classification.
    obtain ⟨hwit, hgap⟩ := aggBracket_extract M atomMap _ _ x t hbr
    refine ⟨x, hxt, ?_⟩
    rw [nf_eval_depth1_fold_iff]
    refine ⟨?_, ?_, hg.1⟩
    · -- Atom layer at `[x, t]` from the two atom-locus heads (given `x < t`).
      exact (nf_char2_atom_offdiag_correct M atomMap h_surj
        (sub_nf.1 : NormalForm sig 0 2) x t hxt).mp ⟨horig, hendp⟩
    · -- Per-(zone, χ) fiber matching over the five consistent zones + the gate.
      intro zs χ
      show _ ↔ agg2Bit sub_nf zs χ = true
      by_cases hcons : zs = agg2ZPastPast ∨ zs = agg2ZAtXPast ∨ zs = agg2ZIntPast ∨
          zs = agg2ZAtTPast ∨ zs = agg2ZFutFut
      · rcases hcons with rfl | rfl | rfl | rfl | rfl
        · -- Zone `v < x`: the Since literal at `x`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZPastPast, agg2Mk, agg2Ltz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hux : u < x := hzu.1.1.mpr rfl
            cases hbb : agg2Bit sub_nf agg2ZPastPast χ with
            | false =>
              have hlit := hPastLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ⟨u, hux, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
            | true => rfl
          · intro hbit
            have hlit := hPastLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            obtain ⟨s, hsx, hsχ, -⟩ := hlit
            have hst : s < t := hsx.trans hxt
            refine ⟨s, ?_, (hchar χ s).mp hsχ⟩
            simp only [agg2ZPastPast, agg2Mk, agg2Ltz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by simp)⟩,
              ⟨iff_of_true hst rfl, iff_of_false (lt_asymm hst) (by simp)⟩⟩
        · -- Zone `v = x`: the characteristic literal at `x`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZAtXPast, agg2Mk, agg2Eqz, agg2Ltz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hueq : u = x := le_antisymm
              (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
              (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
            subst hueq
            cases hbb : agg2Bit sub_nf agg2ZAtXPast χ with
            | false =>
              have hlit := hAtXLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ((hchar χ u).mpr hev)).elim
            | true => rfl
          · intro hbit
            have hlit := hAtXLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            refine ⟨x, ?_, (hchar χ x).mp hlit⟩
            simp only [agg2ZAtXPast, agg2Mk, agg2Eqz, agg2Ltz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_false (lt_irrefl x) (by simp),
              iff_of_false (lt_irrefl x) (by simp)⟩,
              ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
        · -- Bounded interior `x < v < t`: positive fibers ride the witness slots,
          -- negative fibers the uniform exclusion segment.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZIntPast, agg2Mk, agg2Gtz, agg2Ltz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hxu : x < u := hzu.1.2.mpr rfl
            have hut : u < t := hzu.2.1.mpr rfl
            cases hbb : agg2Bit sub_nf agg2ZIntPast χ with
            | false =>
              exfalso
              rcases hgap u hxu hut with hseg | ⟨p, hpmem, hpe⟩
              · -- Gap point: the exclusion conjunct for χ refutes the evaluation.
                simp only [agg2SegPast, TemporalPred.eval_at] at hseg
                rw [formula_conjList_iff] at hseg
                have hexcl := hseg _ (List.mem_map_of_mem (show χ ∈ _ by simp))
                rw [if_neg (by simp [hbb])] at hexcl
                exact hexcl ((hchar χ u).mpr hev)
              · -- Witness slot: distinct complete 1-types exclude each other.
                obtain ⟨χ', hχ'mem, rfl⟩ := List.mem_map.mp hpmem
                have hev' : nf_eval_nf M 0 1 (fun _ => u) χ' := (hchar χ' u).mp hpe
                have hbb' : agg2Bit sub_nf agg2ZIntPast χ' = true :=
                  (List.mem_filter.mp
                    ((List.mem_permutations.mp hlp).mem_iff.mp hχ'mem)).2
                have hEqχ : χ = χ' := nf_eval_unique M 0 1 _ χ χ' hev hev'
                rw [hEqχ] at hbb
                exact absurd hbb' (by simp [hbb])
            | true => rfl
          · intro hbit
            have hχS : χ ∈ l := (List.mem_permutations.mp hlp).mem_iff.mpr
              (List.mem_filter.mpr ⟨by simp, hbit⟩)
            obtain ⟨u, hxu, hut, hpe⟩ := hwit _ (List.mem_map_of_mem hχS)
            refine ⟨u, ?_, (hchar χ u).mp hpe⟩
            simp only [agg2ZIntPast, agg2Mk, agg2Gtz, agg2Ltz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
              ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
        · -- Zone `v = t`: the characteristic literal at `t`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZAtTPast, agg2Mk, agg2Gtz, agg2Eqz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hueq : u = t := le_antisymm
              (not_lt.mp (k1v_not_of_iff_false hzu.2.2))
              (not_lt.mp (k1v_not_of_iff_false hzu.2.1))
            subst hueq
            cases hbb : agg2Bit sub_nf agg2ZAtTPast χ with
            | false =>
              have hlit := hAtTLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ((hchar χ u).mpr hev)).elim
            | true => rfl
          · intro hbit
            have hlit := hAtTLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            refine ⟨t, ?_, (hchar χ t).mp hlit⟩
            simp only [agg2ZAtTPast, agg2Mk, agg2Gtz, agg2Eqz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
              ⟨iff_of_false (lt_irrefl t) (by simp),
                iff_of_false (lt_irrefl t) (by simp)⟩⟩
        · -- Zone `t < v`: the Until literal at `t`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZFutFut, agg2Mk, agg2Gtz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have htu : t < u := hzu.2.2.mpr rfl
            cases hbb : agg2Bit sub_nf agg2ZFutFut χ with
            | false =>
              have hlit := hFutLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ⟨u, htu, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
            | true => rfl
          · intro hbit
            have hlit := hFutLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            obtain ⟨s, hts, hsχ, -⟩ := hlit
            have hxs : x < s := hxt.trans hts
            refine ⟨s, ?_, (hchar χ s).mp hsχ⟩
            simp only [agg2ZFutFut, agg2Mk, agg2Gtz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_false (lt_asymm hxs) (by simp), iff_of_true hxs rfl⟩,
              ⟨iff_of_false (lt_asymm hts) (by simp), iff_of_true hts rfl⟩⟩
      · -- Inconsistent zone spec: gate conjunct (ii) + the routing lemma.
        constructor
        · rintro ⟨u, hzu, -⟩
          exact absurd (agg2_zone_consistent_lt M x t u hxt zs hzu) hcons
        · intro hbit
          have hfalse := hg.2 zs χ hcons
          rw [hfalse] at hbit
          exact Bool.noConfusion hbit
  · -- Completeness (the past disjunct → holdsRight).
    rintro ⟨x, hxt, heval⟩
    rw [nf_eval_depth1_fold_iff] at heval
    obtain ⟨h_atom_raw, h_fiber, h_off⟩ := heval
    have h_atom : nf_eval_nf M 0 2 (Fin.cons x (fun _ => t))
        (sub_nf.1 : NormalForm sig 0 2) := h_atom_raw
    -- Fiber clauses in fold-bit form.
    have hzone' : ∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
        (∃ u : M.carrier,
          zoneHolds M (Fin.cons x (fun _ => t)) zs u ∧
          nf_eval_nf M 0 1 (fun _ => u) χ) ↔
        agg2Bit sub_nf zs χ = true :=
      fun zs χ => h_fiber zs χ
    -- The two atom loci from the atom layer (given `x < t`).
    obtain ⟨horig, hendp⟩ := (nf_char2_atom_offdiag_correct M atomMap h_surj
      (sub_nf.1 : NormalForm sig 0 2) x t hxt).mpr h_atom
    -- Zone-membership constructors at the five consistent zones.
    have hzPast : ∀ u, u < x → zoneHolds M (Fin.cons x (fun _ => t)) agg2ZPastPast u := by
      intro u hux
      have hut : u < t := hux.trans hxt
      simp only [agg2ZPastPast, agg2Mk, agg2Ltz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (by simp)⟩,
        ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
    have hzAtX : zoneHolds M (Fin.cons x (fun _ => t)) agg2ZAtXPast x := by
      simp only [agg2ZAtXPast, agg2Mk, agg2Eqz, agg2Ltz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
        ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
    have hzInt : ∀ u, x < u → u < t →
        zoneHolds M (Fin.cons x (fun _ => t)) agg2ZIntPast u := by
      intro u hxu hut
      simp only [agg2ZIntPast, agg2Mk, agg2Gtz, agg2Ltz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
        ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
    have hzAtT : zoneHolds M (Fin.cons x (fun _ => t)) agg2ZAtTPast t := by
      simp only [agg2ZAtTPast, agg2Mk, agg2Gtz, agg2Eqz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
        ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
    have hzFut : ∀ u, t < u → zoneHolds M (Fin.cons x (fun _ => t)) agg2ZFutFut u := by
      intro u htu
      have hxu : x < u := hxt.trans htu
      simp only [agg2ZFutFut, agg2Mk, agg2Gtz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
        ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
    -- The gate: off-fiber honesty + order-conflict falsity.
    have hgate : agg2GatePast sub_nf := by
      refine ⟨h_off, fun zs χ hncons => ?_⟩
      cases hb : agg2Bit sub_nf zs χ with
      | false => rfl
      | true =>
        obtain ⟨u, hzu, -⟩ := (hzone' zs χ).mpr hb
        exact absurd (agg2_zone_consistent_lt M x t u hxt zs hzu) hncons
    -- Interior-positive realization: each positive fiber yields an interior point.
    have hSreal : ∀ χ ∈ agg2SPast sub_nf,
        ∃ u, x < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
      intro χ hχ
      have hbit := (List.mem_filter.mp hχ).2
      obtain ⟨u, hzu, hev⟩ := (hzone' agg2ZIntPast χ).mpr hbit
      simp only [agg2ZIntPast, agg2Mk, agg2Gtz, agg2Ltz] at hzu
      rw [agg2_zoneHolds_cons_iff] at hzu
      exact ⟨u, hzu.1.2.mpr rfl, hzu.2.1.mpr rfl, hev⟩
    -- Sorted arrangement of the interior-positive enumeration (insertion induction).
    obtain ⟨ps, hperm, hsort, hprops⟩ :=
      k1v_sorted_realization M x t (agg2SPast sub_nf)
        ((Finset.nodup_toList _).filter _) hSreal
    -- The uniform exclusion segment holds on ALL of `(x, t)`.
    have hseg_all : ∀ u, x < u → u < t →
        (agg2SegPast atomMap h_surj sub_nf).eval_at M atomMap u := by
      intro u hxu hut
      simp only [agg2SegPast, TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : agg2Bit sub_nf agg2ZIntPast χ with
      | true =>
        rw [if_pos rfl]
        exact fun hfa => hfa
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hzone' agg2ZIntPast χ).mp ⟨u, hzInt u hxu hut, (hchar χ u).mp hch⟩
        rw [hb] at hbit
        exact Bool.noConfusion hbit
    -- Left endpoint predicate at the laid witness `x`.
    have hepL : (agg2EpPastL atomMap h_surj sub_nf).eval_at M atomMap x := by
      simp only [agg2EpPastL, TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_append.mp hf with hf | hf
      · rcases List.mem_cons.mp hf with rfl | hf
        · exact hendp
        · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
          simp only [agg2Lit]
          cases hb : agg2Bit sub_nf agg2ZPastPast χ with
          | true =>
            rw [if_pos rfl]
            obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
            simp only [agg2ZPastPast, agg2Mk, agg2Ltz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            exact ⟨u, hzu.1.1.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
          | false =>
            rw [if_neg (by simp)]
            rintro ⟨s, hsx, hsχ, -⟩
            have hbit := (hzone' _ χ).mp ⟨s, hzPast s hsx, (hchar χ s).mp hsχ⟩
            rw [hb] at hbit
            exact Bool.noConfusion hbit
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        simp only [agg2Lit]
        cases hb : agg2Bit sub_nf agg2ZAtXPast χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          simp only [agg2ZAtXPast, agg2Mk, agg2Eqz, agg2Ltz] at hzu
          rw [agg2_zoneHolds_cons_iff] at hzu
          have hueq : u = x := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
          exact (hchar χ x).mpr (hueq ▸ hev)
        | false =>
          rw [if_neg (by simp)]
          intro hch
          have hbit := (hzone' _ χ).mp ⟨x, hzAtX, (hchar χ x).mp hch⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
    -- Right endpoint predicate at the origin `t`.
    have hepR : (agg2EpPastR atomMap h_surj sub_nf).eval_at M atomMap t := by
      simp only [agg2EpPastR, TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_append.mp hf with hf | hf
      · rcases List.mem_cons.mp hf with rfl | hf
        · exact horig
        · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
          simp only [agg2Lit]
          cases hb : agg2Bit sub_nf agg2ZAtTPast χ with
          | true =>
            rw [if_pos rfl]
            obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
            simp only [agg2ZAtTPast, agg2Mk, agg2Gtz, agg2Eqz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hueq : u = t := le_antisymm
              (not_lt.mp (k1v_not_of_iff_false hzu.2.2))
              (not_lt.mp (k1v_not_of_iff_false hzu.2.1))
            exact (hchar χ t).mpr (hueq ▸ hev)
          | false =>
            rw [if_neg (by simp)]
            intro hch
            have hbit := (hzone' _ χ).mp ⟨t, hzAtT, (hchar χ t).mp hch⟩
            rw [hb] at hbit
            exact Bool.noConfusion hbit
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        simp only [agg2Lit]
        cases hb : agg2Bit sub_nf agg2ZFutFut χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          simp only [agg2ZFutFut, agg2Mk, agg2Gtz] at hzu
          rw [agg2_zoneHolds_cons_iff] at hzu
          exact ⟨u, hzu.2.2.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
        | false =>
          rw [if_neg (by simp)]
          rintro ⟨s, hts, hsχ, -⟩
          have hbit := (hzone' _ χ).mp ⟨s, hzFut s hts, (hchar χ s).mp hsχ⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
    -- Enter the carrier: gate branch, then the sorted arrangement disjunct.
    unfold agg2Past
    split
    case isFalse hgf => exact absurd hgate hgf
    case isTrue hg =>
    refine ⟨_, List.mem_map.mpr ⟨ps.map Prod.fst,
      List.mem_permutations.mpr hperm, rfl⟩, ?_⟩
    refine ⟨hepR, x, hxt, hepL, ?_⟩
    -- The bracket: assembled by the construction lemma from the sorted realization.
    refine aggBracket_construct M atomMap _ _ x t (ps.map Prod.snd) (by simp) hsort
      ?_ ?_ hseg_all
    · intro u hu
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
      exact (hprops p hp).1
    · intro i hi
      have hi' : i < ps.length := by simpa using hi
      have h1 : (List.map (fun χ =>
          (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
          (ps.map Prod.fst))[i]'hi =
          ⟨nf_depth0_char_formula atomMap h_surj ((ps[i]'hi').1)⟩ := by
        simp only [List.getElem_map]
      have h2 : (ps.map Prod.snd)[i]'(by simpa using hi') = (ps[i]'hi').2 := by
        simp only [List.getElem_map]
      rw [h1, h2]
      exact (hchar _ _).mpr (hprops _ (List.getElem_mem _)).2

end AggPastK0

/-! ## Phase 2b — the k=0 FUTURE-arm aggregate carrier (`t < x` ambient)

Exact structural dual of Phase 2a: the Until-direction semantics `holdsLeft` at the origin
`t` is the future trichotomy disjunct `∃ x, t < x ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t))
sub_nf`. The env stays `[x, t]` (position 0 = the laid witness `x`, position 1 = the origin
`t`) but the ambient anchor order flips (`t < x`), so the five consistent zones are those of
`agg2_zone_consistent_gt` and the interval is `(t, x)`: `endpointLeft` (at `t`) carries the
FLIPPED off-diagonal origin atom locus + the `v<t` Since literals + the `v=t` characteristic
literals; `endpointRight` (at the laid `x`) carries the (direction-independent) endpoint atom
locus + the `v=x` characteristic literals + the `x<v` Until literals. -/

section AggFutK0

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-- Interior-positive enumeration for the future arm (`t < v < x` zone). -/
noncomputable def agg2SFut (sub_nf : NormalForm sig 1 2) : List (NormalForm sig 0 1) :=
  (Finset.univ.toList : List (NormalForm sig 0 1)).filter
    (fun χ => agg2Bit sub_nf agg2ZIntFut χ)

/-- Future-arm left endpoint predicate (at the origin `t`): flipped origin atom locus +
    `v<t` Since literals + `v=t` characteristic literals. -/
noncomputable def agg2EpFutL (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : TemporalPred :=
  ⟨formula_conjList
    ((nf_char2_atom_offdiag_origin_future atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)
      :: (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
          agg2Lit (agg2Bit sub_nf agg2ZPastPast χ)
            (Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top)))
      ++ (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
          agg2Lit (agg2Bit sub_nf agg2ZAtTFut χ)
            (nf_depth0_char_formula atomMap h_surj χ)))⟩

/-- Future-arm right endpoint predicate (at the laid witness `x`): endpoint atom locus +
    `v=x` characteristic literals + `x<v` Until literals. -/
noncomputable def agg2EpFutR (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : TemporalPred :=
  ⟨formula_conjList
    (((nf_char2_atom_offdiag_endpoint atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)).formula
      :: (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
          agg2Lit (agg2Bit sub_nf agg2ZAtXFut χ)
            (nf_depth0_char_formula atomMap h_surj χ)))
      ++ (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
          agg2Lit (agg2Bit sub_nf agg2ZFutFut χ)
            (Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top)))⟩

/-- Future-arm uniform interior exclusion segment (`t < v < x` negative fibers; G3). -/
noncomputable def agg2SegFut (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : TemporalPred :=
  ⟨formula_conjList ((Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
    if agg2Bit sub_nf agg2ZIntFut χ then Formula.top
    else (nf_depth0_char_formula atomMap h_surj χ).neg))⟩

/-- Future-arm gate: off-fiber honesty + order-conflict falsity over the five consistent
    zones of the `t < x` ambient. -/
def agg2GateFut (sub_nf : NormalForm sig 1 2) : Prop :=
  (∀ τ : NormalForm sig 0 3,
      nf0_dropFresh τ ≠ (sub_nf.1 : NormalForm sig 0 2) → sub_nf.2 τ = false) ∧
  (∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
    ¬(zs = agg2ZPastPast ∨ zs = agg2ZAtTFut ∨ zs = agg2ZIntFut ∨
      zs = agg2ZAtXFut ∨ zs = agg2ZFutFut) →
    agg2Bit sub_nf zs χ = false)

/-- **The k=0 future-arm aggregate carrier** (dual of `agg2Past`). -/
noncomputable def agg2Fut (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : VVecEA2 :=
  @dite _ (agg2GateFut sub_nf) (Classical.dec _)
    (fun _ =>
      { disjuncts := (agg2SFut sub_nf).permutations.map (fun l =>
          ⟨(l.map (fun χ =>
              (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))).length,
            { endpointLeft := agg2EpFutL atomMap h_surj sub_nf
              endpointRight := agg2EpFutR atomMap h_surj sub_nf
              bracket := aggBracket
                (l.map (fun χ =>
                  (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred)))
                (agg2SegFut atomMap h_surj sub_nf) }⟩) })
    (fun _ => { disjuncts := [] })

/-- **Correctness of the k=0 future-arm aggregate**: the carrier's Until-direction
    semantics at the origin `t` is exactly the future trichotomy disjunct. Dual of
    `agg2Past_holdsRight_iff` (every chain step a manual bridge — G5). -/
theorem agg2Fut_holdsLeft_iff (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (M : OrderedMonadicStructure sig) (t : M.carrier) :
    (agg2Fut atomMap h_surj sub_nf).holdsLeft M atomMap t ↔
      ∃ x : M.carrier, t < x ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf := by
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ') ↔
      nf_eval_nf M 0 1 (fun _ => u) χ' :=
    fun χ' u => nfPred_correct M atomMap h_surj χ' u
  constructor
  · -- Soundness (holdsLeft → the future disjunct).
    intro h
    obtain ⟨vea, hmem, hveaL⟩ := h
    unfold agg2Fut at hmem
    split at hmem
    case isFalse hg => simp at hmem
    case isTrue hg =>
    rw [List.mem_map] at hmem
    obtain ⟨l, hlp, hEq⟩ := hmem
    subst hEq
    obtain ⟨hepL, x, htx, hepR, hbr⟩ := hveaL
    simp only [agg2EpFutL, agg2EpFutR, TemporalPred.eval_at] at hepL hepR
    rw [formula_conjList_iff] at hepL hepR
    have horig : temporal_truth M atomMap t
        (nf_char2_atom_offdiag_origin_future atomMap h_surj
          (sub_nf.1 : NormalForm sig 0 2)) :=
      hepL _ (List.mem_append_left _ List.mem_cons_self)
    have hendp : temporal_truth M atomMap x
        (nf_char2_atom_offdiag_endpoint atomMap h_surj
          (sub_nf.1 : NormalForm sig 0 2)).formula :=
      hepR _ (List.mem_append_left _ List.mem_cons_self)
    have hPastLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap t
        (agg2Lit (agg2Bit sub_nf agg2ZPastPast χ)
          (Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top)) :=
      fun χ => hepL _ (List.mem_append_left _
        (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
    have hAtTLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap t
        (agg2Lit (agg2Bit sub_nf agg2ZAtTFut χ)
          (nf_depth0_char_formula atomMap h_surj χ)) :=
      fun χ => hepL _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
    have hAtXLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap x
        (agg2Lit (agg2Bit sub_nf agg2ZAtXFut χ)
          (nf_depth0_char_formula atomMap h_surj χ)) :=
      fun χ => hepR _ (List.mem_append_left _
        (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
    have hFutLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap x
        (agg2Lit (agg2Bit sub_nf agg2ZFutFut χ)
          (Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top)) :=
      fun χ => hepR _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
    obtain ⟨hwit, hgap⟩ := aggBracket_extract M atomMap _ _ t x hbr
    refine ⟨x, htx, ?_⟩
    rw [nf_eval_depth1_fold_iff]
    refine ⟨?_, ?_, hg.1⟩
    · exact (nf_char2_atom_offdiag_correct_future M atomMap h_surj
        (sub_nf.1 : NormalForm sig 0 2) x t htx).mp ⟨horig, hendp⟩
    · intro zs χ
      show _ ↔ agg2Bit sub_nf zs χ = true
      by_cases hcons : zs = agg2ZPastPast ∨ zs = agg2ZAtTFut ∨ zs = agg2ZIntFut ∨
          zs = agg2ZAtXFut ∨ zs = agg2ZFutFut
      · rcases hcons with rfl | rfl | rfl | rfl | rfl
        · -- Zone `v < t`: the Since literal at `t`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZPastPast, agg2Mk, agg2Ltz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hut : u < t := hzu.2.1.mpr rfl
            cases hbb : agg2Bit sub_nf agg2ZPastPast χ with
            | false =>
              have hlit := hPastLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ⟨u, hut, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
            | true => rfl
          · intro hbit
            have hlit := hPastLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            obtain ⟨s, hst, hsχ, -⟩ := hlit
            have hsx : s < x := hst.trans htx
            refine ⟨s, ?_, (hchar χ s).mp hsχ⟩
            simp only [agg2ZPastPast, agg2Mk, agg2Ltz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by simp)⟩,
              ⟨iff_of_true hst rfl, iff_of_false (lt_asymm hst) (by simp)⟩⟩
        · -- Zone `v = t`: the characteristic literal at `t`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZAtTFut, agg2Mk, agg2Ltz, agg2Eqz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hueq : u = t := le_antisymm
              (not_lt.mp (k1v_not_of_iff_false hzu.2.2))
              (not_lt.mp (k1v_not_of_iff_false hzu.2.1))
            subst hueq
            cases hbb : agg2Bit sub_nf agg2ZAtTFut χ with
            | false =>
              have hlit := hAtTLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ((hchar χ u).mpr hev)).elim
            | true => rfl
          · intro hbit
            have hlit := hAtTLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            refine ⟨t, ?_, (hchar χ t).mp hlit⟩
            simp only [agg2ZAtTFut, agg2Mk, agg2Ltz, agg2Eqz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_true htx rfl, iff_of_false (lt_asymm htx) (by simp)⟩,
              ⟨iff_of_false (lt_irrefl t) (by simp),
                iff_of_false (lt_irrefl t) (by simp)⟩⟩
        · -- Bounded interior `t < v < x`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZIntFut, agg2Mk, agg2Ltz, agg2Gtz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have htu : t < u := hzu.2.2.mpr rfl
            have hux : u < x := hzu.1.1.mpr rfl
            cases hbb : agg2Bit sub_nf agg2ZIntFut χ with
            | false =>
              exfalso
              rcases hgap u htu hux with hseg | ⟨p, hpmem, hpe⟩
              · simp only [agg2SegFut, TemporalPred.eval_at] at hseg
                rw [formula_conjList_iff] at hseg
                have hexcl := hseg _ (List.mem_map_of_mem (show χ ∈ _ by simp))
                rw [if_neg (by simp [hbb])] at hexcl
                exact hexcl ((hchar χ u).mpr hev)
              · obtain ⟨χ', hχ'mem, rfl⟩ := List.mem_map.mp hpmem
                have hev' : nf_eval_nf M 0 1 (fun _ => u) χ' := (hchar χ' u).mp hpe
                have hbb' : agg2Bit sub_nf agg2ZIntFut χ' = true :=
                  (List.mem_filter.mp
                    ((List.mem_permutations.mp hlp).mem_iff.mp hχ'mem)).2
                have hEqχ : χ = χ' := nf_eval_unique M 0 1 _ χ χ' hev hev'
                rw [hEqχ] at hbb
                exact absurd hbb' (by simp [hbb])
            | true => rfl
          · intro hbit
            have hχS : χ ∈ l := (List.mem_permutations.mp hlp).mem_iff.mpr
              (List.mem_filter.mpr ⟨by simp, hbit⟩)
            obtain ⟨u, htu, hux, hpe⟩ := hwit _ (List.mem_map_of_mem hχS)
            refine ⟨u, ?_, (hchar χ u).mp hpe⟩
            simp only [agg2ZIntFut, agg2Mk, agg2Ltz, agg2Gtz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (by simp)⟩,
              ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
        · -- Zone `v = x`: the characteristic literal at `x`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZAtXFut, agg2Mk, agg2Eqz, agg2Gtz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hueq : u = x := le_antisymm
              (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
              (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
            subst hueq
            cases hbb : agg2Bit sub_nf agg2ZAtXFut χ with
            | false =>
              have hlit := hAtXLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ((hchar χ u).mpr hev)).elim
            | true => rfl
          · intro hbit
            have hlit := hAtXLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            refine ⟨x, ?_, (hchar χ x).mp hlit⟩
            simp only [agg2ZAtXFut, agg2Mk, agg2Eqz, agg2Gtz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_false (lt_irrefl x) (by simp),
              iff_of_false (lt_irrefl x) (by simp)⟩,
              ⟨iff_of_false (lt_asymm htx) (by simp), iff_of_true htx rfl⟩⟩
        · -- Zone `x < v`: the Until literal at `x`.
          constructor
          · rintro ⟨u, hzu, hev⟩
            simp only [agg2ZFutFut, agg2Mk, agg2Gtz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hxu : x < u := hzu.1.2.mpr rfl
            cases hbb : agg2Bit sub_nf agg2ZFutFut χ with
            | false =>
              have hlit := hFutLit χ
              simp only [agg2Lit] at hlit
              rw [if_neg (by simp [hbb])] at hlit
              exact (hlit ⟨u, hxu, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
            | true => rfl
          · intro hbit
            have hlit := hFutLit χ
            simp only [agg2Lit] at hlit
            rw [if_pos hbit] at hlit
            obtain ⟨s, hxs, hsχ, -⟩ := hlit
            have hts : t < s := htx.trans hxs
            refine ⟨s, ?_, (hchar χ s).mp hsχ⟩
            simp only [agg2ZFutFut, agg2Mk, agg2Gtz]
            rw [agg2_zoneHolds_cons_iff]
            exact ⟨⟨iff_of_false (lt_asymm hxs) (by simp), iff_of_true hxs rfl⟩,
              ⟨iff_of_false (lt_asymm hts) (by simp), iff_of_true hts rfl⟩⟩
      · constructor
        · rintro ⟨u, hzu, -⟩
          exact absurd (agg2_zone_consistent_gt M x t u htx zs hzu) hcons
        · intro hbit
          have hfalse := hg.2 zs χ hcons
          rw [hfalse] at hbit
          exact Bool.noConfusion hbit
  · -- Completeness (the future disjunct → holdsLeft).
    rintro ⟨x, htx, heval⟩
    rw [nf_eval_depth1_fold_iff] at heval
    obtain ⟨h_atom_raw, h_fiber, h_off⟩ := heval
    have h_atom : nf_eval_nf M 0 2 (Fin.cons x (fun _ => t))
        (sub_nf.1 : NormalForm sig 0 2) := h_atom_raw
    have hzone' : ∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
        (∃ u : M.carrier,
          zoneHolds M (Fin.cons x (fun _ => t)) zs u ∧
          nf_eval_nf M 0 1 (fun _ => u) χ) ↔
        agg2Bit sub_nf zs χ = true :=
      fun zs χ => h_fiber zs χ
    obtain ⟨horig, hendp⟩ := (nf_char2_atom_offdiag_correct_future M atomMap h_surj
      (sub_nf.1 : NormalForm sig 0 2) x t htx).mpr h_atom
    have hzPast : ∀ u, u < t → zoneHolds M (Fin.cons x (fun _ => t)) agg2ZPastPast u := by
      intro u hut
      have hux : u < x := hut.trans htx
      simp only [agg2ZPastPast, agg2Mk, agg2Ltz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (by simp)⟩,
        ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
    have hzAtT : zoneHolds M (Fin.cons x (fun _ => t)) agg2ZAtTFut t := by
      simp only [agg2ZAtTFut, agg2Mk, agg2Ltz, agg2Eqz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_true htx rfl, iff_of_false (lt_asymm htx) (by simp)⟩,
        ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
    have hzInt : ∀ u, t < u → u < x →
        zoneHolds M (Fin.cons x (fun _ => t)) agg2ZIntFut u := by
      intro u htu hux
      simp only [agg2ZIntFut, agg2Mk, agg2Ltz, agg2Gtz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (by simp)⟩,
        ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
    have hzAtX : zoneHolds M (Fin.cons x (fun _ => t)) agg2ZAtXFut x := by
      simp only [agg2ZAtXFut, agg2Mk, agg2Eqz, agg2Gtz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
        ⟨iff_of_false (lt_asymm htx) (by simp), iff_of_true htx rfl⟩⟩
    have hzFut : ∀ u, x < u → zoneHolds M (Fin.cons x (fun _ => t)) agg2ZFutFut u := by
      intro u hxu
      have htu : t < u := htx.trans hxu
      simp only [agg2ZFutFut, agg2Mk, agg2Gtz]
      rw [agg2_zoneHolds_cons_iff]
      exact ⟨⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
        ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
    have hgate : agg2GateFut sub_nf := by
      refine ⟨h_off, fun zs χ hncons => ?_⟩
      cases hb : agg2Bit sub_nf zs χ with
      | false => rfl
      | true =>
        obtain ⟨u, hzu, -⟩ := (hzone' zs χ).mpr hb
        exact absurd (agg2_zone_consistent_gt M x t u htx zs hzu) hncons
    have hSreal : ∀ χ ∈ agg2SFut sub_nf,
        ∃ u, t < u ∧ u < x ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
      intro χ hχ
      have hbit := (List.mem_filter.mp hχ).2
      obtain ⟨u, hzu, hev⟩ := (hzone' agg2ZIntFut χ).mpr hbit
      simp only [agg2ZIntFut, agg2Mk, agg2Ltz, agg2Gtz] at hzu
      rw [agg2_zoneHolds_cons_iff] at hzu
      exact ⟨u, hzu.2.2.mpr rfl, hzu.1.1.mpr rfl, hev⟩
    obtain ⟨ps, hperm, hsort, hprops⟩ :=
      k1v_sorted_realization M t x (agg2SFut sub_nf)
        ((Finset.nodup_toList _).filter _) hSreal
    have hseg_all : ∀ u, t < u → u < x →
        (agg2SegFut atomMap h_surj sub_nf).eval_at M atomMap u := by
      intro u htu hux
      simp only [agg2SegFut, TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : agg2Bit sub_nf agg2ZIntFut χ with
      | true =>
        rw [if_pos rfl]
        exact fun hfa => hfa
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hzone' agg2ZIntFut χ).mp ⟨u, hzInt u htu hux, (hchar χ u).mp hch⟩
        rw [hb] at hbit
        exact Bool.noConfusion hbit
    have hepL : (agg2EpFutL atomMap h_surj sub_nf).eval_at M atomMap t := by
      simp only [agg2EpFutL, TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_append.mp hf with hf | hf
      · rcases List.mem_cons.mp hf with rfl | hf
        · exact horig
        · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
          simp only [agg2Lit]
          cases hb : agg2Bit sub_nf agg2ZPastPast χ with
          | true =>
            rw [if_pos rfl]
            obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
            simp only [agg2ZPastPast, agg2Mk, agg2Ltz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            exact ⟨u, hzu.2.1.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
          | false =>
            rw [if_neg (by simp)]
            rintro ⟨s, hst, hsχ, -⟩
            have hbit := (hzone' _ χ).mp ⟨s, hzPast s hst, (hchar χ s).mp hsχ⟩
            rw [hb] at hbit
            exact Bool.noConfusion hbit
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        simp only [agg2Lit]
        cases hb : agg2Bit sub_nf agg2ZAtTFut χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          simp only [agg2ZAtTFut, agg2Mk, agg2Ltz, agg2Eqz] at hzu
          rw [agg2_zoneHolds_cons_iff] at hzu
          have hueq : u = t := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.1))
          exact (hchar χ t).mpr (hueq ▸ hev)
        | false =>
          rw [if_neg (by simp)]
          intro hch
          have hbit := (hzone' _ χ).mp ⟨t, hzAtT, (hchar χ t).mp hch⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
    have hepR : (agg2EpFutR atomMap h_surj sub_nf).eval_at M atomMap x := by
      simp only [agg2EpFutR, TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_append.mp hf with hf | hf
      · rcases List.mem_cons.mp hf with rfl | hf
        · exact hendp
        · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
          simp only [agg2Lit]
          cases hb : agg2Bit sub_nf agg2ZAtXFut χ with
          | true =>
            rw [if_pos rfl]
            obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
            simp only [agg2ZAtXFut, agg2Mk, agg2Eqz, agg2Gtz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hueq : u = x := le_antisymm
              (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
              (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
            exact (hchar χ x).mpr (hueq ▸ hev)
          | false =>
            rw [if_neg (by simp)]
            intro hch
            have hbit := (hzone' _ χ).mp ⟨x, hzAtX, (hchar χ x).mp hch⟩
            rw [hb] at hbit
            exact Bool.noConfusion hbit
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        simp only [agg2Lit]
        cases hb : agg2Bit sub_nf agg2ZFutFut χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          simp only [agg2ZFutFut, agg2Mk, agg2Gtz] at hzu
          rw [agg2_zoneHolds_cons_iff] at hzu
          exact ⟨u, hzu.1.2.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
        | false =>
          rw [if_neg (by simp)]
          rintro ⟨s, hxs, hsχ, -⟩
          have hbit := (hzone' _ χ).mp ⟨s, hzFut s hxs, (hchar χ s).mp hsχ⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
    unfold agg2Fut
    split
    case isFalse hgf => exact absurd hgate hgf
    case isTrue hg =>
    refine ⟨_, List.mem_map.mpr ⟨ps.map Prod.fst,
      List.mem_permutations.mpr hperm, rfl⟩, ?_⟩
    refine ⟨hepL, x, htx, hepR, ?_⟩
    refine aggBracket_construct M atomMap _ _ t x (ps.map Prod.snd) (by simp) hsort
      ?_ ?_ hseg_all
    · intro u hu
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
      exact (hprops p hp).1
    · intro i hi
      have hi' : i < ps.length := by simpa using hi
      have h1 : (List.map (fun χ =>
          (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
          (ps.map Prod.fst))[i]'hi =
          ⟨nf_depth0_char_formula atomMap h_surj ((ps[i]'hi').1)⟩ := by
        simp only [List.getElem_map]
      have h2 : (ps.map Prod.snd)[i]'(by simpa using hi') = (ps[i]'hi').2 := by
        simp only [List.getElem_map]
      rw [h1, h2]
      exact (hchar _ _).mpr (hprops _ (List.getElem_mem _)).2

end AggFutK0

/-! ## Phase 2c — the k=0 DIAGONAL-arm aggregate formula (`x = t` ambient)

The diagonal seam analog: at `x = t` the two anchors coincide, so there is NO bounded
interior and NO laid witness — the whole aggregate is a single closed formula at the origin
`t` (the additive `A_diag_correct` variant of the R2 verdict). Three consistent zones
(`agg2_zone_consistent_diag`): `v<t` Since literals, `v=t` characteristic literals, `t<v`
Until literals, conjoined with the diagonal atom characteristic `nf_char2_atom_part`, all
gated by off-fiber honesty + order-conflict falsity. -/

section AggDiagK0

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-- Diagonal-arm gate: off-fiber honesty + order-conflict falsity over the three
    consistent zones of the `x = t` ambient. -/
def agg2GateDiag (sub_nf : NormalForm sig 1 2) : Prop :=
  (∀ τ : NormalForm sig 0 3,
      nf0_dropFresh τ ≠ (sub_nf.1 : NormalForm sig 0 2) → sub_nf.2 τ = false) ∧
  (∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
    ¬(zs = agg2ZPastPast ∨ zs = agg2ZAtDiag ∨ zs = agg2ZFutFut) →
    agg2Bit sub_nf zs χ = false)

/-- **The k=0 diagonal-arm aggregate formula** (all content at the origin `t`; no bracket,
    no laid witness). Collapses to `⊥` off-gate (Rabinovich's empty disjunction over
    inconsistent order types). -/
noncomputable def agg2Diag (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : Formula :=
  @dite _ (agg2GateDiag sub_nf) (Classical.dec _)
    (fun _ => formula_conjList
      (((nf_char2_atom_part atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)
        :: (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
            agg2Lit (agg2Bit sub_nf agg2ZPastPast χ)
              (Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top)))
        ++ (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
            agg2Lit (agg2Bit sub_nf agg2ZAtDiag χ)
              (nf_depth0_char_formula atomMap h_surj χ)))
        ++ (Finset.univ.toList : List (NormalForm sig 0 1)).map (fun χ =>
            agg2Lit (agg2Bit sub_nf agg2ZFutFut χ)
              (Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top))))
    (fun _ => Formula.bot)

/-- Constant-tail env identity: `Fin.cons t (fun _ => t) = fun _ => t` at arity 2. -/
private theorem agg2_cons_diag_env {α : Type _} (t : α) :
    (Fin.cons t (fun _ => t) : Fin 2 → α) = (fun _ => t) := by
  funext i
  refine Fin.cases rfl (fun j => ?_) i
  simp [Fin.cons_succ]

/-- **Correctness of the k=0 diagonal-arm aggregate**: truth at the origin `t` is exactly
    the diagonal trichotomy disjunct. Every chain step a manual bridge (G5). -/
theorem agg2Diag_iff (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (M : OrderedMonadicStructure sig) (t : M.carrier) :
    temporal_truth M atomMap t (agg2Diag atomMap h_surj sub_nf) ↔
      nf_eval_nf M 1 2 (Fin.cons t (fun _ => t)) sub_nf := by
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ') ↔
      nf_eval_nf M 0 1 (fun _ => u) χ' :=
    fun χ' u => nfPred_correct M atomMap h_surj χ' u
  -- Zone-membership constructors at the three consistent zones of the diagonal.
  have hzPast : ∀ u, u < t →
      zoneHolds M (Fin.cons t (fun _ => t)) agg2ZPastPast u := by
    intro u hut
    simp only [agg2ZPastPast, agg2Mk, agg2Ltz]
    rw [agg2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAt : zoneHolds M (Fin.cons t (fun _ => t)) agg2ZAtDiag t := by
    simp only [agg2ZAtDiag, agg2Mk, agg2Eqz]
    rw [agg2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩,
      ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
  have hzFut : ∀ u, t < u →
      zoneHolds M (Fin.cons t (fun _ => t)) agg2ZFutFut u := by
    intro u htu
    simp only [agg2ZFutFut, agg2Mk, agg2Gtz]
    rw [agg2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩,
      ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
  unfold agg2Diag
  by_cases hg : agg2GateDiag sub_nf
  · rw [dif_pos hg]
    constructor
    · -- Soundness (truth at `t` → the diagonal disjunct).
      intro h
      rw [formula_conjList_iff] at h
      have hatom : temporal_truth M atomMap t
          (nf_char2_atom_part atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)) :=
        h _ (List.mem_append_left _ (List.mem_append_left _ List.mem_cons_self))
      have hPastLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap t
          (agg2Lit (agg2Bit sub_nf agg2ZPastPast χ)
            (Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top)) :=
        fun χ => h _ (List.mem_append_left _ (List.mem_append_left _
          (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp)))))
      have hAtLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap t
          (agg2Lit (agg2Bit sub_nf agg2ZAtDiag χ)
            (nf_depth0_char_formula atomMap h_surj χ)) :=
        fun χ => h _ (List.mem_append_left _
          (List.mem_append_right _ (List.mem_map_of_mem (by simp))))
      have hFutLit : ∀ χ : NormalForm sig 0 1, temporal_truth M atomMap t
          (agg2Lit (agg2Bit sub_nf agg2ZFutFut χ)
            (Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top)) :=
        fun χ => h _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
      rw [nf_eval_depth1_fold_iff]
      refine ⟨?_, ?_, hg.1⟩
      · show nf_eval_nf M 0 2 (Fin.cons t (fun _ => t)) (sub_nf.1 : NormalForm sig 0 2)
        rw [agg2_cons_diag_env]
        exact (nf_char2_atom_part_correct M atomMap h_surj
          (sub_nf.1 : NormalForm sig 0 2) t).mp hatom
      · intro zs χ
        show _ ↔ agg2Bit sub_nf zs χ = true
        by_cases hcons : zs = agg2ZPastPast ∨ zs = agg2ZAtDiag ∨ zs = agg2ZFutFut
        · rcases hcons with rfl | rfl | rfl
          · -- Zone `v < t`: the Since literal at `t`.
            constructor
            · rintro ⟨u, hzu, hev⟩
              simp only [agg2ZPastPast, agg2Mk, agg2Ltz] at hzu
              rw [agg2_zoneHolds_cons_iff] at hzu
              have hut : u < t := hzu.1.1.mpr rfl
              cases hbb : agg2Bit sub_nf agg2ZPastPast χ with
              | false =>
                have hlit := hPastLit χ
                simp only [agg2Lit] at hlit
                rw [if_neg (by simp [hbb])] at hlit
                exact (hlit ⟨u, hut, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
              | true => rfl
            · intro hbit
              have hlit := hPastLit χ
              simp only [agg2Lit] at hlit
              rw [if_pos hbit] at hlit
              obtain ⟨s, hst, hsχ, -⟩ := hlit
              exact ⟨s, hzPast s hst, (hchar χ s).mp hsχ⟩
          · -- Zone `v = t`: the characteristic literal at `t`.
            constructor
            · rintro ⟨u, hzu, hev⟩
              simp only [agg2ZAtDiag, agg2Mk, agg2Eqz] at hzu
              rw [agg2_zoneHolds_cons_iff] at hzu
              have hueq : u = t := le_antisymm
                (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
                (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
              subst hueq
              cases hbb : agg2Bit sub_nf agg2ZAtDiag χ with
              | false =>
                have hlit := hAtLit χ
                simp only [agg2Lit] at hlit
                rw [if_neg (by simp [hbb])] at hlit
                exact (hlit ((hchar χ u).mpr hev)).elim
              | true => rfl
            · intro hbit
              have hlit := hAtLit χ
              simp only [agg2Lit] at hlit
              rw [if_pos hbit] at hlit
              exact ⟨t, hzAt, (hchar χ t).mp hlit⟩
          · -- Zone `t < v`: the Until literal at `t`.
            constructor
            · rintro ⟨u, hzu, hev⟩
              simp only [agg2ZFutFut, agg2Mk, agg2Gtz] at hzu
              rw [agg2_zoneHolds_cons_iff] at hzu
              have htu : t < u := hzu.1.2.mpr rfl
              cases hbb : agg2Bit sub_nf agg2ZFutFut χ with
              | false =>
                have hlit := hFutLit χ
                simp only [agg2Lit] at hlit
                rw [if_neg (by simp [hbb])] at hlit
                exact (hlit ⟨u, htu, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
              | true => rfl
            · intro hbit
              have hlit := hFutLit χ
              simp only [agg2Lit] at hlit
              rw [if_pos hbit] at hlit
              obtain ⟨s, hts, hsχ, -⟩ := hlit
              exact ⟨s, hzFut s hts, (hchar χ s).mp hsχ⟩
        · constructor
          · rintro ⟨u, hzu, -⟩
            exact absurd (agg2_zone_consistent_diag M t u zs hzu) hcons
          · intro hbit
            have hfalse := hg.2 zs χ hcons
            rw [hfalse] at hbit
            exact Bool.noConfusion hbit
    · -- Completeness (the diagonal disjunct → truth at `t`).
      intro heval
      rw [nf_eval_depth1_fold_iff] at heval
      obtain ⟨h_atom_raw, h_fiber, -⟩ := heval
      have h_atom : nf_eval_nf M 0 2 (Fin.cons t (fun _ => t))
          (sub_nf.1 : NormalForm sig 0 2) := h_atom_raw
      have hzone' : ∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
          (∃ u : M.carrier,
            zoneHolds M (Fin.cons t (fun _ => t)) zs u ∧
            nf_eval_nf M 0 1 (fun _ => u) χ) ↔
          agg2Bit sub_nf zs χ = true :=
        fun zs χ => h_fiber zs χ
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_append.mp hf with hf | hf
      · rcases List.mem_append.mp hf with hf | hf
        · rcases List.mem_cons.mp hf with rfl | hf
          · rw [agg2_cons_diag_env] at h_atom
            exact (nf_char2_atom_part_correct M atomMap h_surj
              (sub_nf.1 : NormalForm sig 0 2) t).mpr h_atom
          · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
            simp only [agg2Lit]
            cases hb : agg2Bit sub_nf agg2ZPastPast χ with
            | true =>
              rw [if_pos rfl]
              obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
              simp only [agg2ZPastPast, agg2Mk, agg2Ltz] at hzu
              rw [agg2_zoneHolds_cons_iff] at hzu
              exact ⟨u, hzu.1.1.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
            | false =>
              rw [if_neg (by simp)]
              rintro ⟨s, hst, hsχ, -⟩
              have hbit := (hzone' _ χ).mp ⟨s, hzPast s hst, (hchar χ s).mp hsχ⟩
              rw [hb] at hbit
              exact Bool.noConfusion hbit
        · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
          simp only [agg2Lit]
          cases hb : agg2Bit sub_nf agg2ZAtDiag χ with
          | true =>
            rw [if_pos rfl]
            obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
            simp only [agg2ZAtDiag, agg2Mk, agg2Eqz] at hzu
            rw [agg2_zoneHolds_cons_iff] at hzu
            have hueq : u = t := le_antisymm
              (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
              (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
            exact (hchar χ t).mpr (hueq ▸ hev)
          | false =>
            rw [if_neg (by simp)]
            intro hch
            have hbit := (hzone' _ χ).mp ⟨t, hzAt, (hchar χ t).mp hch⟩
            rw [hb] at hbit
            exact Bool.noConfusion hbit
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        simp only [agg2Lit]
        cases hb : agg2Bit sub_nf agg2ZFutFut χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          simp only [agg2ZFutFut, agg2Mk, agg2Gtz] at hzu
          rw [agg2_zoneHolds_cons_iff] at hzu
          exact ⟨u, hzu.1.2.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
        | false =>
          rw [if_neg (by simp)]
          rintro ⟨s, hts, hsχ, -⟩
          have hbit := (hzone' _ χ).mp ⟨s, hzFut s hts, (hchar χ s).mp hsχ⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
  · -- Off-gate: the formula is `⊥`, and the diagonal disjunct FORCES the gate.
    rw [dif_neg hg]
    constructor
    · intro h
      exact h.elim
    · intro heval
      exfalso
      apply hg
      rw [nf_eval_depth1_fold_iff] at heval
      obtain ⟨-, h_fiber, h_off⟩ := heval
      have hzone' : ∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
          (∃ u : M.carrier,
            zoneHolds M (Fin.cons t (fun _ => t)) zs u ∧
            nf_eval_nf M 0 1 (fun _ => u) χ) ↔
          agg2Bit sub_nf zs χ = true :=
        fun zs χ => h_fiber zs χ
      refine ⟨h_off, fun zs χ hncons => ?_⟩
      cases hb : agg2Bit sub_nf zs χ with
      | false => rfl
      | true =>
        obtain ⟨u, hzu, -⟩ := (hzone' zs χ).mpr hb
        exact absurd (agg2_zone_consistent_diag M t u zs hzu) hncons

end AggDiagK0

/-! ## Phase 3 — k=0 hook discharge: the three arm lemmas (match arm k=0)

The three green citable lemmas in the `kampPrior_case1_trichotomy_assemble` skeleton shape
(KampPrior.lean:1146) at match arm k=0 (`sub_nf : NormalForm sig 1 2`). Each conclusion is the
corresponding `kampPrior_site_trichotomy` disjunct verbatim (KampPrior.lean:677-684).
`h_UZ`/`h_SZ` are carried (unused — the k=0 aggregates need no Prior hypotheses, matching the
k≤1 rungs `bracketEndChar_kv_correct_{zero,one}_prior`) so the statements slot directly under
the Prior-guarded skeleton. These discharge the P4/P5 `h_quant` hooks and the `A_diag_correct`
hooks at k=0 IN THE SENSE THAT BINDS (downstream assembly consumes the conclusion shape, not
the binder — Phase-1 R1/R2 adjudication record). -/

section ArmLemmasK0

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-- **k=0 past arm formula**: the Since-direction translation of the past-arm aggregate. -/
noncomputable def kampArm_past_k0 (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : Formula :=
  (agg2Past atomMap h_surj sub_nf).translateRight

/-- **k=0 past-arm hook discharge** (hook-discharge lemma 1/6): the past-arm formula realizes
    the past disjunct of `kampPrior_site_trichotomy` at match arm k=0. Enters the skeleton
    via `VVecEA2.translateRight_correct` (Route V, Phase-1 R1 verdict). -/
theorem kampArm_past_k0_correct (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) :
    ∀ (M : OrderedMonadicStructure sig),
      semantic_prior_UZ M atomMap → semantic_prior_SZ M atomMap →
      ∀ t : M.carrier,
      temporal_truth M atomMap t (kampArm_past_k0 atomMap h_surj sub_nf) ↔
        ∃ x, x < t ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf := by
  intro M _h_UZ _h_SZ t
  unfold kampArm_past_k0
  rw [VVecEA2.translateRight_correct]
  exact agg2Past_holdsRight_iff atomMap h_surj sub_nf M t

/-- **k=0 diagonal arm formula**: the diagonal-seam aggregate (closed at the origin). -/
noncomputable def kampArm_diag_k0 (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : Formula :=
  agg2Diag atomMap h_surj sub_nf

/-- **k=0 diagonal-arm hook discharge** (hook-discharge lemma 2/6): the diagonal-arm formula
    realizes the diagonal disjunct of `kampPrior_site_trichotomy` at match arm k=0 — the
    additive `A_diag_correct` variant of the Phase-1 R2 verdict (the per-point hooks are
    world-locality-refuted; the conclusion shape is delivered directly). -/
theorem kampArm_diag_k0_correct (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) :
    ∀ (M : OrderedMonadicStructure sig),
      semantic_prior_UZ M atomMap → semantic_prior_SZ M atomMap →
      ∀ t : M.carrier,
      temporal_truth M atomMap t (kampArm_diag_k0 atomMap h_surj sub_nf) ↔
        nf_eval_nf M 1 2 (Fin.cons t (fun _ => t)) sub_nf := by
  intro M _h_UZ _h_SZ t
  exact agg2Diag_iff atomMap h_surj sub_nf M t

/-- **k=0 future arm formula**: the Until-direction translation of the future-arm aggregate. -/
noncomputable def kampArm_future_k0 (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) : Formula :=
  (agg2Fut atomMap h_surj sub_nf).translateLeft

/-- **k=0 future-arm hook discharge** (hook-discharge lemma 3/6): the future-arm formula
    realizes the future disjunct of `kampPrior_site_trichotomy` at match arm k=0. Enters the
    skeleton via `VVecEA2.translateLeft_correct` (Route V, dual). -/
theorem kampArm_future_k0_correct (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) :
    ∀ (M : OrderedMonadicStructure sig),
      semantic_prior_UZ M atomMap → semantic_prior_SZ M atomMap →
      ∀ t : M.carrier,
      temporal_truth M atomMap t (kampArm_future_k0 atomMap h_surj sub_nf) ↔
        ∃ x, t < x ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf := by
  intro M _h_UZ _h_SZ t
  unfold kampArm_future_k0
  rw [VVecEA2.translateLeft_correct]
  exact agg2Fut_holdsLeft_iff atomMap h_surj sub_nf M t

/-! ### Phase-3 shape certificates (drop-in citability without importing KampPrior)

Each `_correct` conclusion instantiated at the generic-site index `0 + 1` — the exact match-arm
shape of the `kampPrior_site_trichotomy` disjuncts (`sub_nf : NormalForm sig (k+1) 2` at
`k := 0`) and of `kampPrior_case1_trichotomy_assemble`'s `h_past`/`h_diag`/`h_future` binders.
KampPrior imports this module's aggregator (not vice versa), so the certificates copy the
disjunct statements verbatim rather than applying the skeleton itself. -/

section ShapeCertificatesK0
variable (atomMap : Formula → sig.preds)
  (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
  (sub_nf : NormalForm sig (0 + 1) 2)
  (M : OrderedMonadicStructure sig)
  (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
  (t : M.carrier)

/-- Past disjunct shape at match arm k=0 (verbatim `kampPrior_site_trichotomy` disjunct 1). -/
example : temporal_truth M atomMap t (kampArm_past_k0 atomMap h_surj sub_nf) ↔
    ∃ x, x < t ∧ nf_eval_nf M (0 + 1) 2 (Fin.cons x (fun _ => t)) sub_nf :=
  kampArm_past_k0_correct atomMap h_surj sub_nf M h_UZ h_SZ t

/-- Diagonal disjunct shape at match arm k=0 (verbatim disjunct 2). -/
example : temporal_truth M atomMap t (kampArm_diag_k0 atomMap h_surj sub_nf) ↔
    nf_eval_nf M (0 + 1) 2 (Fin.cons t (fun _ => t)) sub_nf :=
  kampArm_diag_k0_correct atomMap h_surj sub_nf M h_UZ h_SZ t

/-- Future disjunct shape at match arm k=0 (verbatim disjunct 3). -/
example : temporal_truth M atomMap t (kampArm_future_k0 atomMap h_surj sub_nf) ↔
    ∃ x, t < x ∧ nf_eval_nf M (0 + 1) 2 (Fin.cons x (fun _ => t)) sub_nf :=
  kampArm_future_k0_correct atomMap h_surj sub_nf M h_UZ h_SZ t

end ShapeCertificatesK0

end ArmLemmasK0

/-! ## Phase 4 — k=1 DIAGONAL-seam aggregate via the gated anchor-collapse reduction

At the diagonal seam (`x = t`) the k=1 population clause per `qnf : NormalForm sig 1 3` is
`∃ w, nf_eval_nf M 1 3 [w, t, t] qnf` — the env has DUPLICATED anchors (positions 1, 2 both
`t`). The depth-lift of the diagonal rename congruence is blocked as an UNCONDITIONAL iff
(NfDepth0Generalized.lean:1693-1719: a non-diagonal-invariant sub can have its collapse marked
true), but the missing ingredient is exactly a per-`qnf` SYNTACTIC gate: qnf's atom row is a
duplicate-collapse fixpoint AND every non-fixpoint arity-4 sub is unmarked. Under that gate the
depth-1 evaluation at `[w, t, t]` collapses LOSSLESSLY to the depth-1 arity-2 evaluation of the
collapsed `renameNF aggExpand23 aggMerge32 qnf` at `[w, t]` (`agg_diag_collapse_k1`) — and off-
gate the evaluation is REFUTED (`agg_rename_fixpoint_of_eval`: any realizer forces the
fixpoint). The per-`qnf` positive clause therefore reduces to the k=0 trichotomy arms applied
to the collapsed population member: `∃ w, nf_eval_nf M 1 2 [w, t] (collapse qnf)` =
past ∨ diag ∨ future at k=0 (`exists_trichotomy_split`) — consuming Phase 3 verbatim. -/

section AggDiagK1

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-- Prefix embedding `Fin 2 → Fin 3` (`0 ↦ 0`, `1 ↦ 1`). -/
def aggExpand23 : Fin 2 → Fin 3 := fun i => ⟨i.val, by omega⟩

/-- Tail merge `Fin 3 → Fin 2` (`0 ↦ 0`, `1 ↦ 1`, `2 ↦ 1`). -/
def aggMerge32 : Fin 3 → Fin 2 := fun i => if i.val = 0 then ⟨0, by omega⟩ else ⟨1, by omega⟩

/-- `aggMerge32 ∘ aggExpand23 = id` (the retraction). -/
theorem aggMerge32_expand23 : ∀ j : Fin 2, aggMerge32 (aggExpand23 j) = j := by
  decide

/-- Lifted retraction on `Fin 3`. -/
theorem agg_liftMerge_liftExpand :
    ∀ j : Fin 3, liftIdx aggMerge32 (liftIdx aggExpand23 j) = j := by
  intro j
  refine Fin.cases ?_ ?_ j
  · rw [liftIdx_zero, liftIdx_zero]
  · intro i
    rw [liftIdx_succ, liftIdx_succ, aggMerge32_expand23]

/-- Two bits biconditional to the same proposition are equal. -/
private theorem agg_bit_eq_of_iff {P : Prop} {b1 b2 : Bool}
    (h1 : P ↔ b1 = true) (h2 : P ↔ b2 = true) : b1 = b2 := by
  cases hb1 : b1 <;> cases hb2 : b2 <;> simp_all

/-! Concrete-typed rename wrappers (the bare `renameNF` leaves its depth implicit `{k}` as a
stuck metavariable in expected-type-free positions — the wrappers pin `k` and the arities). -/

/-- Collapse an arity-3 depth-0 row to arity 2 (positions 1, 2 merge). -/
def aggCollapseRow {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 3 → NormalForm sig 0 2 :=
  renameNF aggExpand23 aggMerge32
/-- Duplicate an arity-2 depth-0 row to arity 3 (position 1 duplicated onto 2). -/
def aggDupRow {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 2 → NormalForm sig 0 3 :=
  renameNF aggMerge32 aggExpand23
/-- Collapse an arity-4 depth-0 sub to arity 3 (positions 2, 3 merge; fresh slot fixed). -/
def aggCollapseSub {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 4 → NormalForm sig 0 3 :=
  renameNF (liftIdx aggExpand23) (liftIdx aggMerge32)
/-- Duplicate an arity-3 depth-0 sub to arity 4 (position 2 duplicated onto 3). -/
def aggDupSub {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 3 → NormalForm sig 0 4 :=
  renameNF (liftIdx aggMerge32) (liftIdx aggExpand23)
/-- Collapse a depth-1 arity-3 NF to arity 2 (the diagonal population collapse). -/
def aggCollapseK1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 1 3 → NormalForm sig 1 2 :=
  renameNF aggExpand23 aggMerge32

/-- **Duplicate-collapse fixpoint from a depth-0 realizer** (the gate-refutation engine).
    If a depth-0 arity-`a` NF `σ` is realized on an env that is constant on the merge fibers
    (`E (f (r i)) = E i`), then `σ` IS a duplicate-collapse fixpoint: reassembling its collapse
    recovers `σ` exactly. Contrapositively, a non-fixpoint `σ` has NO realizer on such an env —
    the conditional ingredient that unblocks the depth-1 diagonal rename congruence
    (NfDepth0Generalized.lean:1693-1719). -/
theorem agg_rename_fixpoint_of_eval {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {a b : Nat}
    (f : Fin b → Fin a) (r : Fin a → Fin b)
    (hsec2 : ∀ j : Fin b, r (f j) = j)
    (E : Fin a → M.carrier)
    (hE : ∀ i : Fin a, E (f (r i)) = E i)
    (σ : NormalForm sig 0 a)
    (heval : nf_eval_nf M 0 a E σ) :
    renameNF r f (renameNF f r σ) = σ := by
  funext atom
  match atom with
  | .pred p i =>
    simp only [renameNF]
    have h1 := heval (.pred p (f (r i)))
    have h2 := heval (.pred p i)
    simp only [atom_eval] at h1 h2
    rw [hE i] at h1
    exact agg_bit_eq_of_iff h1 h2
  | .order i j hij =>
    simp only [renameNF]
    by_cases hr : r i = r j
    · rw [dif_pos hr]
      have hEij : E i = E j := by rw [← hE i, ← hE j, hr]
      have h2 := heval (.order i j hij)
      simp only [atom_eval] at h2
      rw [hEij] at h2
      cases hb : σ (.order i j hij) with
      | false => rfl
      | true => exact absurd (h2.mpr hb) (lt_irrefl _)
    · rw [dif_neg hr]
      by_cases hf : f (r i) = f (r j)
      · exact absurd ((hsec2 (r i)).symm.trans
          ((congrArg r hf).trans (hsec2 (r j)))) hr
      · rw [dif_neg hf]
        have h1 := heval (.order (f (r i)) (f (r j)) hf)
        have h2 := heval (.order i j hij)
        simp only [atom_eval] at h1 h2
        rw [hE i, hE j] at h1
        exact agg_bit_eq_of_iff h1 h2

/-- The atom row of the collapsed depth-1 NF is the collapse of the atom row. -/
private theorem agg_dup32_fst (qnf : NormalForm sig 1 3) :
    (aggCollapseK1 qnf).1 = aggCollapseRow qnf.1 := rfl

/-- The quant layer of the collapsed depth-1 NF reads the original through the lifted
    duplication. -/
private theorem agg_dup32_snd (qnf : NormalForm sig 1 3) (τ : NormalForm sig 0 3) :
    (aggCollapseK1 qnf).2 τ = qnf.2 (aggDupSub τ) := rfl

/-- **Gated depth-1 diagonal anchor collapse** (the conditional lift of
    `renameNF_eval_diag0` that the unconditional-blocked note excludes). Under the syntactic
    gate — the atom row is a duplicate-collapse fixpoint and every non-fixpoint arity-4 sub is
    unmarked — the depth-1 evaluation at the duplicated-anchor env `[w, t, t]` is equivalent to
    the depth-1 arity-2 evaluation of the collapsed NF at `[w, t]`. -/
theorem agg_diag_collapse_k1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (w t : M.carrier)
    (hrow : aggDupRow (aggCollapseRow qnf.1) = qnf.1)
    (hquant : ∀ σ : NormalForm sig 0 4, aggDupSub (aggCollapseSub σ) ≠ σ →
      qnf.2 σ = false) :
    nf_eval_nf M 1 3 (Fin.cons w (Fin.cons t (fun _ => t))) qnf ↔
      nf_eval_nf M 1 2 (Fin.cons w (fun _ => t)) (aggCollapseK1 qnf) := by
  set E : Fin 3 → M.carrier := Fin.cons w (Fin.cons t (fun _ => t)) with hEdef
  set e : Fin 2 → M.carrier := Fin.cons w (fun _ => t) with hedef
  -- Env compatibilities for the rename bridges.
  have hcomp : ∀ i : Fin 2, e i = E (aggExpand23 i) := by
    intro i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
  have hcomp2 : ∀ i : Fin 3, E i = e (aggMerge32 i) := by
    intro i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
  -- Row-level rename bridge (under the fixpoint): eval₃ E qnf.1 ↔ eval₂ e (collapse row).
  have hrowbridge : nf_eval_nf M 0 3 E (qnf.1 : NormalForm sig 0 3) ↔
      nf_eval_nf M 0 2 e (aggCollapseRow qnf.1) := by
    conv_lhs => rw [← hrow]
    exact renameNF_eval_diag0 M aggExpand23 aggMerge32 E e hcomp hcomp2
      aggMerge32_expand23 (aggCollapseRow qnf.1)
  -- σ-level rename bridge per inner witness v.
  have hsub : ∀ (v : M.carrier) (τ : NormalForm sig 0 3),
      nf_eval_nf M 0 4 (Fin.cons v E) (aggDupSub τ) ↔
        nf_eval_nf M 0 3 (Fin.cons v e) τ := by
    intro v τ
    exact renameNF_eval_diag0 M (liftIdx aggExpand23) (liftIdx aggMerge32)
      (Fin.cons v E) (Fin.cons v e)
      (cons_comp_liftIdx aggExpand23 E e v hcomp)
      (cons_comp_liftIdx aggMerge32 e E v hcomp2)
      agg_liftMerge_liftExpand τ
  -- Depth-1 defeq unfolds on both sides.
  have hwhole3 : nf_eval_nf M 1 3 E qnf ↔
      (nf_eval_nf M 0 3 E (qnf.1 : NormalForm sig 0 3) ∧
        (∀ σ : NormalForm sig 0 4,
          (∃ v : M.carrier, nf_eval_nf M 0 4 (Fin.cons v E) σ) ↔ qnf.2 σ = true)) :=
    Iff.rfl
  have hwhole2 : nf_eval_nf M 1 2 e (aggCollapseK1 qnf) ↔
      (nf_eval_nf M 0 2 e (aggCollapseRow qnf.1) ∧
        (∀ τ : NormalForm sig 0 3,
          (∃ v : M.carrier, nf_eval_nf M 0 3 (Fin.cons v e) τ) ↔
            qnf.2 (aggDupSub τ) = true)) :=
    Iff.rfl
  rw [hwhole3, hwhole2]
  constructor
  · rintro ⟨hatom, hq⟩
    refine ⟨hrowbridge.mp hatom, fun τ => ?_⟩
    have := hq (aggDupSub τ)
    exact (exists_congr (fun v => (hsub v τ).symm)).trans this
  · rintro ⟨hatom2, hq2⟩
    refine ⟨hrowbridge.mpr hatom2, fun σ => ?_⟩
    by_cases hfix : aggDupSub (aggCollapseSub σ) = σ
    · have hτ := hq2 (aggCollapseSub σ)
      rw [hfix] at hτ
      refine Iff.trans ?_ hτ
      refine exists_congr (fun v => ?_)
      conv_lhs => rw [← hfix]
      exact hsub v (aggCollapseSub σ)
    · constructor
      · rintro ⟨v, hv⟩
        refine absurd ?_ hfix
        show aggDupSub (aggCollapseSub σ) = σ
        refine agg_rename_fixpoint_of_eval M (liftIdx aggExpand23)
          (liftIdx aggMerge32) agg_liftMerge_liftExpand (Fin.cons v E) ?_ σ hv
        intro i
        refine Fin.cases ?_ ?_ i
        · rw [liftIdx_zero, liftIdx_zero]
        · intro j
          rw [liftIdx_succ, liftIdx_succ]
          simp only [Fin.cons_succ]
          rw [← hcomp (aggMerge32 j), hcomp2 j]
      · intro hbit
        rw [hquant σ hfix] at hbit
        exact Bool.noConfusion hbit

/-- **Per-`qnf` diagonal-seam gate** (k=1): qnf's atom row is a duplicate-collapse fixpoint
    AND every non-fixpoint arity-4 sub is unmarked — the syntactic condition under which the
    depth-1 evaluation at `[w, t, t]` collapses losslessly to arity 2, and whose failure
    REFUTES the evaluation (`agg_rename_fixpoint_of_eval`). -/
def aggDiagGateK1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (qnf : NormalForm sig 1 3) : Prop :=
  aggDupRow (aggCollapseRow qnf.1) = qnf.1 ∧
  (∀ σ : NormalForm sig 0 4, aggDupSub (aggCollapseSub σ) ≠ σ → qnf.2 σ = false)

/-- **Per-`qnf` diagonal-seam positive clause** (k=1): the closed formula at the origin `t`
    realizing `∃ w, nf_eval_nf M 1 3 [w, t, t] qnf`. Under the gate, the k=0 trichotomy arms
    applied to the collapsed population member (Phase 3 consumed VERBATIM); off-gate `⊥`. -/
noncomputable def aggPosDiagK1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3) : Formula :=
  @dite _ (aggDiagGateK1 qnf) (Classical.dec _)
    (fun _ => Formula.or (kampArm_past_k0 atomMap h_surj (aggCollapseK1 qnf))
      (Formula.or (kampArm_diag_k0 atomMap h_surj (aggCollapseK1 qnf))
        (kampArm_future_k0 atomMap h_surj (aggCollapseK1 qnf))))
    (fun _ => Formula.bot)

/-- **Correctness of the per-`qnf` diagonal-seam positive clause**: truth at the origin `t`
    is exactly the k=1 population existential at the duplicated-anchor env. On-gate via the
    three k=0 arm lemmas + `exists_trichotomy_split` + the gated collapse; off-gate the
    existential FORCES the gate (fixpoint engine), refuting it. -/
theorem aggPosDiagK1_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (aggPosDiagK1 atomMap h_surj qnf) ↔
      ∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons t (fun _ => t))) qnf := by
  unfold aggPosDiagK1
  by_cases hg : aggDiagGateK1 qnf
  · rw [dif_pos hg]
    have harm : temporal_truth M atomMap t
        (Formula.or (kampArm_past_k0 atomMap h_surj (aggCollapseK1 qnf))
          (Formula.or (kampArm_diag_k0 atomMap h_surj (aggCollapseK1 qnf))
            (kampArm_future_k0 atomMap h_surj (aggCollapseK1 qnf)))) ↔
        ((∃ x, x < t ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggCollapseK1 qnf)) ∨
          nf_eval_nf M 1 2 (Fin.cons t (fun _ => t)) (aggCollapseK1 qnf) ∨
          (∃ x, t < x ∧ nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggCollapseK1 qnf))) := by
      rw [temporal_truth_or, temporal_truth_or,
        kampArm_past_k0_correct atomMap h_surj (aggCollapseK1 qnf) M h_UZ h_SZ t,
        kampArm_diag_k0_correct atomMap h_surj (aggCollapseK1 qnf) M h_UZ h_SZ t,
        kampArm_future_k0_correct atomMap h_surj (aggCollapseK1 qnf) M h_UZ h_SZ t]
    exact harm.trans ((exists_trichotomy_split
      (fun x => nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggCollapseK1 qnf)) t).symm.trans
      (exists_congr fun w => (agg_diag_collapse_k1 M qnf w t hg.1 hg.2).symm))
  · rw [dif_neg hg]
    constructor
    · intro h
      exact h.elim
    · rintro ⟨w, hw⟩
      exfalso
      apply hg
      have hwhole : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons t (fun _ => t))) qnf ↔
          (nf_eval_nf M 0 3 (Fin.cons w (Fin.cons t (fun _ => t)))
              (qnf.1 : NormalForm sig 0 3) ∧
            (∀ σ : NormalForm sig 0 4,
              (∃ v : M.carrier, nf_eval_nf M 0 4
                (Fin.cons v (Fin.cons w (Fin.cons t (fun _ => t)))) σ) ↔
                qnf.2 σ = true)) := Iff.rfl
      rw [hwhole] at hw
      obtain ⟨hatom, hq⟩ := hw
      have hE3 : ∀ i : Fin 3,
          (Fin.cons w (Fin.cons t (fun _ => t)) : Fin 3 → M.carrier)
            (aggExpand23 (aggMerge32 i)) =
          (Fin.cons w (Fin.cons t (fun _ => t)) : Fin 3 → M.carrier) i := by
        intro i
        match i with
        | ⟨0, _⟩ => rfl
        | ⟨1, _⟩ => rfl
        | ⟨2, _⟩ => rfl
      refine ⟨?_, ?_⟩
      · exact agg_rename_fixpoint_of_eval M aggExpand23 aggMerge32 aggMerge32_expand23
          (Fin.cons w (Fin.cons t (fun _ => t))) hE3
          (qnf.1 : NormalForm sig 0 3) hatom
      · intro σ hfix
        cases hb : qnf.2 σ with
        | false => rfl
        | true =>
          obtain ⟨v, hv⟩ := (hq σ).mpr hb
          refine absurd ?_ hfix
          show aggDupSub (aggCollapseSub σ) = σ
          refine agg_rename_fixpoint_of_eval M (liftIdx aggExpand23)
            (liftIdx aggMerge32) agg_liftMerge_liftExpand
            (Fin.cons v (Fin.cons w (Fin.cons t (fun _ => t)))) ?_ σ hv
          intro i
          refine Fin.cases ?_ ?_ i
          · rw [liftIdx_zero, liftIdx_zero]
          · intro j
            rw [liftIdx_succ, liftIdx_succ]
            simp only [Fin.cons_succ]
            exact hE3 j

/-- **k=1 diagonal arm formula** (hook-discharge lemma 4/6, formula side): the diagonal atom
    characteristic conjoined with one biconditional population literal per
    `qnf : NormalForm sig 1 3` (the `nf_char2_formula` house pattern, one depth up). -/
noncomputable def kampArm_diag_k1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 2 2) : Formula :=
  formula_conjList
    (nf_char2_atom_part atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)
      :: (Finset.univ.toList : List (NormalForm sig 1 3)).map (fun qnf =>
          agg2Lit (sub_nf.2 qnf) (aggPosDiagK1 atomMap h_surj qnf)))

/-- **k=1 diagonal-arm hook discharge** (hook-discharge lemma 4/6): the diagonal-arm formula
    realizes the diagonal disjunct of `kampPrior_site_trichotomy` at match arm k=1
    (`sub_nf : NormalForm sig 2 2`) — the additive `A_diag_correct` variant one depth up. -/
theorem kampArm_diag_k1_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 2 2) :
    ∀ (M : OrderedMonadicStructure sig),
      semantic_prior_UZ M atomMap → semantic_prior_SZ M atomMap →
      ∀ t : M.carrier,
      temporal_truth M atomMap t (kampArm_diag_k1 atomMap h_surj sub_nf) ↔
        nf_eval_nf M 2 2 (Fin.cons t (fun _ => t)) sub_nf := by
  intro M h_UZ h_SZ t
  have hwhole : nf_eval_nf M 2 2 (Fin.cons t (fun _ => t)) sub_nf ↔
      (nf_eval_nf M 0 2 (Fin.cons t (fun _ => t)) (sub_nf.1 : NormalForm sig 0 2) ∧
        (∀ qnf : NormalForm sig 1 3,
          (∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons t (fun _ => t))) qnf) ↔
            sub_nf.2 qnf = true)) := Iff.rfl
  rw [hwhole]
  unfold kampArm_diag_k1
  rw [formula_conjList_iff]
  constructor
  · intro h
    constructor
    · have hatom := h _ List.mem_cons_self
      show nf_eval_nf M 0 2 (Fin.cons t (fun _ => t)) (sub_nf.1 : NormalForm sig 0 2)
      rw [agg2_cons_diag_env]
      exact (nf_char2_atom_part_correct M atomMap h_surj
        (sub_nf.1 : NormalForm sig 0 2) t).mp hatom
    · intro qnf
      have hcl := h _ (List.mem_cons_of_mem _ (List.mem_map_of_mem (show qnf ∈ _ by simp)))
      simp only [agg2Lit] at hcl
      cases hb : sub_nf.2 qnf with
      | true =>
        rw [if_pos hb] at hcl
        exact iff_of_true
          ((aggPosDiagK1_correct atomMap h_surj qnf M h_UZ h_SZ t).mp hcl) rfl
      | false =>
        rw [if_neg (by simp [hb])] at hcl
        exact iff_of_false
          (fun hex => hcl
            ((aggPosDiagK1_correct atomMap h_surj qnf M h_UZ h_SZ t).mpr hex))
          (by simp)
  · rintro ⟨hatom, hpop⟩
    intro f hf
    rcases List.mem_cons.mp hf with rfl | hf
    · rw [agg2_cons_diag_env] at hatom
      exact (nf_char2_atom_part_correct M atomMap h_surj
        (sub_nf.1 : NormalForm sig 0 2) t).mpr hatom
    · obtain ⟨qnf, -, rfl⟩ := List.mem_map.mp hf
      simp only [agg2Lit]
      cases hb : sub_nf.2 qnf with
      | true =>
        rw [if_pos rfl]
        exact (aggPosDiagK1_correct atomMap h_surj qnf M h_UZ h_SZ t).mpr
          ((hpop qnf).mpr hb)
      | false =>
        rw [if_neg (by simp)]
        intro hpos
        have hbit := (hpop qnf).mp
          ((aggPosDiagK1_correct atomMap h_surj qnf M h_UZ h_SZ t).mp hpos)
        rw [hb] at hbit
        exact Bool.noConfusion hbit

/-- k=1 diagonal disjunct shape certificate (verbatim `kampPrior_site_trichotomy` disjunct 2
    at the generic-site index `1 + 1`). -/
example (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig (1 + 1) 2)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (kampArm_diag_k1 atomMap h_surj sub_nf) ↔
      nf_eval_nf M (1 + 1) 2 (Fin.cons t (fun _ => t)) sub_nf :=
  kampArm_diag_k1_correct atomMap h_surj sub_nf M h_UZ h_SZ t

end AggDiagK1

end Bimodal.Metalogic.WeakCanonical.Kamp
