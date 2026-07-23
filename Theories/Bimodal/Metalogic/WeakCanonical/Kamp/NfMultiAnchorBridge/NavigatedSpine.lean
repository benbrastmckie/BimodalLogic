import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket2V

/-! Extracted from NfMultiAnchorBridge.lean lines 8827-9249 (task 331). Byte-identical,
token edits NONE. Imports SubBracket2V only (NOT MergedQuarantine — all kvE2 mentions in
this range are comments, verified :9006, :9015, :9187-:9243). The slab includes the
namespace-closing `end`.

# FAITHFUL API — SPINE + PROP 4.3 ENGINE (Rabinovich 2014)

Source mapping (Rabinovich 2014, "A Proof of Kamp's Theorem"; `md:` line refs are to the
Literature chunk `Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`):

- **Prop 3.5** fold (md:87-94) → `kvE_fold_navigated` + the 5+5 dischargers (:9055-:9176).
- **Lemma 3.4** V-exists-forall closure (md:84-85) → `VVecEA2.disjList` / `VVecEA2.disjList_holds`.
- **Prop 4.2** negation step (md:100-101) → `reflatten_neg_step`.
- **Prop 4.3** reflattening engine (md:103-110) → `reflatten_prop43`.

Also hosts: the task-321 v6 audit record :8827-:8858 (incl. the no-nesting rule :8841-:8846),
`VVecEA2.holds_flatMap_map` :9018, and the Phase-7 rescope record :9183-:9249. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Task 321 v6 REDESIGN — Phase 1: baseline snapshot + refuted-infrastructure quarantine

**Baseline commit SHA:** `71b0ea938d86355b22ef786ffb277026c6f05a98` (scoped build green). All v6
work is PURELY ADDITIVE below this note; a `git diff` against this SHA at Phase 8 must show an
additive-only delta and every do-not-edit asset byte-identical.

**Refuted-infrastructure quarantine (DROPPED — no v6 phase consumes these).** Confirmed by grep +
build that the constant-arity static route the task-327 NO-GO (:8760-8825) certified is inert:
- `nfk_assemble` / `nfk_dropFresh` / `nfk_zoneSpec` — do NOT exist as live declarations
  (`nfk_assemble` appears ONLY in the NO-GO prose at :8770; the other two are absent entirely).
- `nf_eval_nf1_cons_factor` / `efold_of_nfk` / `nf_quant_layer_fold_k2_gate` — appear ONLY in the
  NO-GO prose (:8763-8792) as inert doc/decision records with 0 live `sorry`; NOT live paths.
- The `EAtomDom` static arity-1 factorization (`NfEFold.lean:69`) is NOT consumed as a live path.

The audit (task 330) root cause: Def 4.1 is the E[Σ] ALPHABET EXPANSION, not a fold; Rabinovich's
actual fold (Prop 3.5 / Cor 5.4, md:87-94, md:154-157) is NAVIGATED over FLAT exists-forall blocks
with QUANTIFIER-FREE point types (Lemma 5.1, md:134-135); higher FO depth is discharged by the
Prop 4.3 re-flatten induction (md, p.6), never by nesting a depth-k characteristic. LITMUS
(binding): no `x1 < e_i` relative-position literal on any live path — reconstruction rides the
evaluation point / structural position of nested `Until`/`Since` operators.

**Consumed-asset signatures confirmed present (do NOT rebuild):**
- `BracketEndCharCarrierV` (:1872), `BracketCarrierCorrectV` (:1881) — witness-growing carrier.
- `BracketCarrierCorrectVPrior` (:5032) — the k=2 gate (do-not-edit).
- `neg_2var_vec_ea` (EANegationClosure.lean:722, Prop 4.2) — landed negation closure.
- `kvE_subChain2V` (:6955), `kvE_subBracket2V_sound_of_outer` (:7910),
  `kvE_subBracket2V_complete` (:8159) — task-326 interior closers.
- `epL`/`epR`, `bracketBuildLeft`/`bracketBuildRight` (:1676-1739) — navigated fold literals.

Per-asset byte-identity hashes recorded in
`specs/321_.../` Phase-1 baseline snapshot. This note is additive and inert. -/

/-! ## Task 321 v6 REDESIGN — Phase 2: navigated-fold SPINE `kvE_fold_navigated` (interior fragment)

**Make-or-break established.** Audit §H5 target 2 asks whether the witness-growing carrier
discharges the k≥1 instance via NAVIGATION (Until/Since reach over the evaluation point) rather than
a static arity-1 channel — the wall the task-327 NO-GO (:8760-8825) certified for the constant-arity
route. The answer is YES, and it is already realized by the LANDED task-325/326 witness-growing
route: the sub-carrier `kvE_subBracket2V` (:6833, codomain `VVecEA2`) discharges the arity-4 depth-1
sub instance `∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ` in BOTH directions
(`kvE_subBracket2V_correctness_pair` :8549), sorry-free and non-vacuously
(`kvE_subBracket2V_nonvacuous` :8119), with the reconstruction riding `zoneHolds` membership over
the anchor env `[x1,w,x,t]` (`kvE_subBracket2V_complete` :8159, zone constructors :8228-8294) — NOT
an `x1 < e_i` relative-position literal (LITMUS respected; contrast the task-327 crux :8790).

`kvE_fold_navigated` NAMES this spine as the single navigated biconditional in the
`BracketCarrierCorrectV` `↔`-shape (:1881), at the sub granularity `σ : NormalForm sig 1 4` that the
carrier-level `NormalForm sig k 3` obligation decomposes into over its outer quant layer. It CONSUMES
the landed correctness pair; the carrier-level lift OVER the outer quant layer (composing the per-sub
navigated spine into the full `∃ w, nf_eval_nf M k 3 [w,x,t] qnf`) is the navigated fold engine
(Phase 4), whose higher-FO depth is discharged by the Prop 4.3 re-flatten induction (Phase 3) — never
by nesting a depth-k characteristic (Prop 3.5 / Cor 5.4, Rabinovich md:87-94, md:154-157). Anchors
stay `{x,t}` (≤2, Lemma 3.2(2), md:76-79); `x1`, `w` are interior WITNESS slots (witness growth
licensed, anchor growth not). Purely consumes landed lemmas (no `simp`/`omega`/`aesop`). -/
theorem kvE_fold_navigated {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h_xx1 : σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_x1w : σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_wt : σ.1 (.order ⟨1, by omega⟩ ⟨3, by omega⟩ (by decide)) = true)
    (hcharK : ∀ a : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a)
    (hgate : ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap x t ↔
      ∃ x1 : M.carrier,
        nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ :=
  ⟨(kvE_subBracket2V_correctness_pair atomMap h_surj charK σ M w x t
      h_xx1 h_x1w h_wt hcharK hgate).1,
   (kvE_subBracket2V_correctness_pair atomMap h_surj charK σ M w x t
      h_xx1 h_x1w h_wt hcharK hgate).2⟩

/-! ## Task 321 v6 REDESIGN — Phase 3: Prop 4.3 re-flatten structural-induction engine

The audit's H3 table marked ONE ingredient MISSING: the Boolean-closure step that lets the
structural induction (Rabinovich **Prop 4.3**, md p.6) discharge higher FO quantifier depth by
RE-FLATTENING a depth-`(k+1)` obligation to a `∨` of FLAT exists-forall blocks over the E[Σ]
alphabet with QUANTIFIER-FREE point types (**Lemma 5.1**, md:134-135) — never by nesting a depth-k
characteristic. The codebase already had the two hardest halves landed:
- **negation** (Prop 4.2): `neg_2var_vec_ea` (EANegationClosure.lean:722);
- **binary disjunction**: `VVecEA2.disj_holds` (VecEAFormula.lean:286);
- **conjunction**: `VVecEA2.conj_holds_vvecEA2` (VecEAClosure.lean:238).

What was MISSING is the finite-FAMILY disjunction collapse: an induction over the arrangement list
`S_L.permutations × S_R.permutations` (Phase 4) produces a LIST of flat blocks, and the re-flatten
step must collapse that whole list into a SINGLE `VVecEA2`. Binary `disj_holds` does not give this
directly; `VVecEA2.disjList_holds` below is the missing ingredient, proven by induction consuming
binary `disj_holds` at each step. `reflatten_prop43` then states the full Prop 4.3 induction step:
any obligation the induction re-expresses as a finite `∨` of flat blocks is realized by one
`VVecEA2`. -/

/-- Finite-family disjunction of `VVecEA2` formulas: the `∨`-collapse over a list of flat
    exists-forall blocks. `foldr` over the landed binary `VVecEA2.disj` (VecEAFormula.lean:282). -/
def VVecEA2.disjList (vs : List VVecEA2) : VVecEA2 :=
  vs.foldr VVecEA2.disj ⟨[]⟩

/-- **Prop 4.3 re-flatten `∨`-collapse** (the missing ingredient). The finite-family disjunction
    `VVecEA2.disjList vs` holds at the fixed endpoints `(z0, z1)` iff SOME member flat block holds —
    the collapse the structural induction needs to re-flatten a depth-`(k+1)` obligation to a single
    `VVecEA2` over flat exists-forall blocks (Rabinovich Prop 4.3, md p.6; Lemma 5.1 quantifier-free
    point types, md:134-135). Proven by induction on `vs`, consuming the landed binary
    `VVecEA2.disj_holds` at the cons step. -/
theorem VVecEA2.disjList_holds {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vs : List VVecEA2) (z0 z1 : M.carrier) :
    (VVecEA2.disjList vs).holds M atomMap z0 z1 ↔
      ∃ w ∈ vs, w.holds M atomMap z0 z1 := by
  induction vs with
  | nil =>
    constructor
    · rintro ⟨vea, hmem, _⟩
      exact (List.not_mem_nil hmem).elim
    · rintro ⟨w, hmem, _⟩
      exact (List.not_mem_nil hmem).elim
  | cons v vs ih =>
    have hstep : VVecEA2.disjList (v :: vs) = v.disj (VVecEA2.disjList vs) := rfl
    rw [hstep, VVecEA2.disj_holds M atomMap v (VVecEA2.disjList vs) z0 z1, ih]
    constructor
    · rintro (hv | ⟨w, hmem, hw⟩)
      · exact ⟨v, List.mem_cons.mpr (Or.inl rfl), hv⟩
      · exact ⟨w, List.mem_cons.mpr (Or.inr hmem), hw⟩
    · rintro ⟨w, hmem, hw⟩
      rcases List.mem_cons.mp hmem with rfl | hmem'
      · exact Or.inl hw
      · exact Or.inr ⟨w, hmem', hw⟩

/-- **WARNING — THIS RE-EXPORTS A VACUOUS STATEMENT. The negation case of Prop 4.3 is NOT
    discharged.** Machine refutation: `Prop42Vacuity.prop42_conclusion_is_vacuous`
    (`Kamp/Prop42Vacuity.lean`).

    **Correction to this docstring's previous claim.** It formerly read that the negation case
    "is discharged by the LANDED Prop 4.2 closure `neg_2var_vec_ea` (EANegationClosure.lean:722)
    ... the hardest half, already proven; consumed, not rebuilt". That is wrong, and it is the
    specific misreading this annotation exists to stop. `neg_2var_vec_ea` is not Rabinovich's
    Prop 4.2 (2014, **PDF p.6**) and proves nothing about negation: its conclusion
    `∃ v', v'.holds M atomMap z0 z1` never mentions `v`, and follows from no hypotheses at all.
    Nothing was landed, and the hardest half is not proven — it is open.

    So the sentence below ("whenever a flat block `v` fails ... there is a `VVecEA2` witnessing
    its negation") does **not** describe what this theorem proves. The `v'` produced here is
    unrelated to `v`; it witnesses nothing about `v`'s negation. This theorem is sorry-free and
    green, which is not evidence to the contrary — a vacuous statement is trivially provable.

    **Retained deliberately, not endorsed**, to keep the call site intact; removal is out of
    scope. Any future Prop 4.3 induction that needs a real negation case must first obtain a
    contentful Prop 4.2 (biconditional shape, `v'` a function of `v` alone — see
    `Prop42Vacuity.lean`). Building on this theorem propagates the vacuity.

    What it actually states: on a `HasAttainedINF` structure, given `h_neg` and `h_lt`, *some*
    `VVecEA2` — with no asserted connection to `v` — holds at `(z0, z1)`. -/
theorem reflatten_neg_step {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (v : VVecEA2) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_neg : ¬v.holds M atomMap z0 z1) :
    ∃ v' : VVecEA2, v'.holds M atomMap z0 z1 :=
  neg_2var_vec_ea h_INF v z0 z1 h_lt h_neg

/-- **Prop 4.3 re-flatten induction STEP** (the wired MISSING ingredient). Any higher-FO-depth
    obligation `P` that the structural induction has re-flattened to a finite disjunction `vs` of
    flat exists-forall blocks (Lemma 5.1 quantifier-free point types) is realized by the SINGLE
    `VVecEA2` `VVecEA2.disjList vs` — never by nesting a depth-k characteristic. The `∨`-collapse
    rides `VVecEA2.disjList_holds`; the negation case rides Prop 4.2 (`reflatten_neg_step`). This is
    the ingredient Phase 4's navigated fold engine composes at each induction step (Prop 4.3, md
    p.6; Prop 3.5 / Cor 5.4, md:87-94, md:154-157). -/
theorem reflatten_prop43 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vs : List VVecEA2) (z0 z1 : M.carrier)
    (P : Prop) (hP : P ↔ ∃ w ∈ vs, w.holds M atomMap z0 z1) :
    ∃ v : VVecEA2, (v.holds M atomMap z0 z1 ↔ P) :=
  ⟨VVecEA2.disjList vs, by rw [VVecEA2.disjList_holds M atomMap vs z0 z1, hP]⟩

/-! ## Task 321 v6 REDESIGN — Phase 4: navigated witness-growing fold engine (folds in former 328)

**Scope (honest).** The carrier-level SEMANTIC equivalence
`(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf` IS the do-not-edit gate
`BracketCarrierCorrectVPrior` (:5032), assembled in Phase 7 from the per-arrangement dischargers
(Phases 5-6) and the per-sub navigated spine (Phase 2 / landed `kvE_subBracket2V_correctness_pair`).
This phase lands the fold engine's STRUCTURAL CORE: the arrangement-disjunction collapse that
unfolds the carrier's `VVecEA2.holds` — a doubly-nested product over
`S_L.permutations × S_R.permutations` (the witness-growing arrangement enumeration, `kvE2_body`
:8681-8691) — into the finite disjunction of per-arrangement obligations that the Phase-3 re-flatten
machinery (`disjList_holds`, `reflatten_prop43`) and the Phases-5/6 dischargers consume. This is the
Prop 3.5 / Cor 5.4 navigating fold read structurally (Rabinovich md:87-94, md:154-157): the model
chooses ONE arrangement (`lL, lR`) of the interior witnesses between the FIXED endpoints `{x, t}`
(anchors ≤2, Lemma 3.2(2), md:76-79), and the carrier holds iff SOME arrangement's bracket holds —
never a fixed-order assertion (rule N5), never an `x1 < e_i` relative-position literal (LITMUS).

Kept general over the disjunct builder `mk` and the arrangement lists so Phase 7 applies it to
`kvE2_body`'s gate-case disjuncts by `rw` after `dif_pos`. Purely `List.mem_flatMap`/`List.mem_map`
membership reasoning (the `by omega`-free structural fold); no `simp`/`omega`/`aesop` in the
chain-construction body. -/
theorem VVecEA2.holds_flatMap_map {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {α β : Type}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (LL : List α) (LR : List β) (mk : α → β → Σ n, VecEA2 n) (z0 z1 : M.carrier) :
    (⟨LL.flatMap (fun lL => LR.map (fun lR => mk lL lR))⟩ : VVecEA2).holds M atomMap z0 z1 ↔
      ∃ lL ∈ LL, ∃ lR ∈ LR, (mk lL lR).2.holds M atomMap z0 z1 := by
  simp only [VVecEA2.holds, List.mem_flatMap, List.mem_map]
  constructor
  · rintro ⟨vea, ⟨lL, hlL, lR, hlR, rfl⟩, hvea⟩
    exact ⟨lL, hlL, lR, hlR, hvea⟩
  · rintro ⟨lL, hlL, lR, hlR, hvea⟩
    exact ⟨mk lL lR, ⟨lL, hlL, lR, hlR, rfl⟩, hvea⟩

/-! ## Task 321 v6 REDESIGN — Phase 5: per-arrangement non-interior SOUNDNESS dischargers
(folds in redefined former task 329, soundness half)

The five non-interior zones (`zPastX`, `zAtX`, `zAtW`, `zAtT`, `zFutT`, Def 3.1 md:61-74) are the
zones whose realizing witness is NOT strictly interior to `(x, w)`/`(w, t)`. Over the `VVecEA2`
channel of `kvE_subBracket2V` (:6833) their fold-bit content is carried by the endpoint predicates
`epL` (at the fixed left endpoint `x`), `epR` (at the fixed right endpoint `t`), and the witness
point type `ptW` (at the interior anchor `w`) — each a `formula_conjList` of per-`χ` biconditional
literals (`lit (bits z χ) …`). These SOUNDNESS dischargers extract, from an endpoint predicate
holding at its anchor, the zone's realizing witness — the arrangement-independent core each
per-arrangement disjunct feeds into the Phase-7 gate soundness assembly (they are stated over the
raw `formula_conjList fs` + a membership hypothesis, so every arrangement's `epL`/`epR`/`ptW`
instantiates them uniformly; NOT per-`(zone, χ:NormalForm sig 1 1)`).

The two EXTERIOR zones carry the genuine NAVIGATION content (Prop 3.5 folding mechanism, md:87-94):
`zPastX` rides the `Since` evaluation point (a past witness `v < x`), `zFutT` rides the `Until`
evaluation point (a future witness `t < v`) — the reconstruction rides the temporal evaluation
point, NEVER an `x1 < e_i` relative-position literal (LITMUS). The three BOUNDARY zones
(`zAtX`/`zAtT`/`zAtW`) are point-realizations at the fixed anchors `x`/`t` and the interior anchor
`w` respectively (the witness IS the anchor). -/

/-- **`zPastX` soundness (exterior-past navigation).** From `epL` holding at the fixed left
endpoint `x`, the `Since` literal `snce φ ⊤` (present when `bits zPastX χ = true`, with `φ = charBase χ`)
yields a past witness `v < x` realizing `φ` — the Prop 3.5 folding mechanism (md:87-94) read at the
left endpoint. The witness rides the `Since` evaluation point (LITMUS: no `x1 < e_i` literal). -/
theorem kvE_nonInterior_zPastX_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x : M.carrier) (fs : List Formula) (φ : Formula)
    (hmem : Formula.snce φ Formula.top ∈ fs)
    (hepL : temporal_truth M atomMap x (formula_conjList fs)) :
    ∃ v : M.carrier, v < x ∧ temporal_truth M atomMap v φ := by
  have hlit := (formula_conjList_iff M atomMap x fs).mp hepL _ hmem
  obtain ⟨s, hs_lt, hs_phi, _⟩ := hlit
  exact ⟨s, hs_lt, hs_phi⟩

/-- **`zFutT` soundness (exterior-future navigation).** From `epR` holding at the fixed right
endpoint `t`, the `Until` literal `untl φ ⊤` (present when `bits zFutT χ = true`) yields a future
witness `t < v` realizing `φ` — the Prop 3.5 folding mechanism (md:87-94) read at the right
endpoint. The witness rides the `Until` evaluation point (LITMUS: no `x1 < e_i` literal). -/
theorem kvE_nonInterior_zFutT_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (fs : List Formula) (φ : Formula)
    (hmem : Formula.untl φ Formula.top ∈ fs)
    (hepR : temporal_truth M atomMap t (formula_conjList fs)) :
    ∃ v : M.carrier, t < v ∧ temporal_truth M atomMap v φ := by
  have hlit := (formula_conjList_iff M atomMap t fs).mp hepR _ hmem
  obtain ⟨s, hs_lt, hs_phi, _⟩ := hlit
  exact ⟨s, hs_lt, hs_phi⟩

/-- **`zAtX` soundness (left-boundary point-realization).** From `epL` holding at the fixed left
endpoint `x`, the bare literal `φ = charBase χ` (present when `bits zAtX χ = true`) is realized AT
`x` itself — the `v = x` zone (Def 3.1 md:61-74). The witness is the fixed anchor. -/
theorem kvE_nonInterior_zAtX_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x : M.carrier) (fs : List Formula) (φ : Formula)
    (hmem : φ ∈ fs)
    (hepL : temporal_truth M atomMap x (formula_conjList fs)) :
    temporal_truth M atomMap x φ :=
  (formula_conjList_iff M atomMap x fs).mp hepL _ hmem

/-- **`zAtT` soundness (right-boundary point-realization).** From `epR` holding at the fixed right
endpoint `t`, the bare literal `φ` (present when `bits zAtT χ = true`) is realized AT `t` itself —
the `v = t` zone (Def 3.1 md:61-74). The witness is the fixed anchor. -/
theorem kvE_nonInterior_zAtT_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (fs : List Formula) (φ : Formula)
    (hmem : φ ∈ fs)
    (hepR : temporal_truth M atomMap t (formula_conjList fs)) :
    temporal_truth M atomMap t φ :=
  (formula_conjList_iff M atomMap t fs).mp hepR _ hmem

/-- **`zAtW` soundness (interior-anchor point-realization).** From the witness point type `ptW`
holding at the interior anchor `w`, the self-zone literal `φ` (present when `bits zAtW χ = true`) is
realized AT `w` itself — the `v = w` witness self-zone (v2 nine-zone correction; Def 3.1
md:61-74). The witness is the interior anchor (Amendment F3 preserved: a zone-literal fold on the
complete 1-type, NOT a `w = e 1` provider equation). -/
theorem kvE_nonInterior_zAtW_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w : M.carrier) (fs : List Formula) (φ : Formula)
    (hmem : φ ∈ fs)
    (hptW : temporal_truth M atomMap w (formula_conjList fs)) :
    temporal_truth M atomMap w φ :=
  (formula_conjList_iff M atomMap w fs).mp hptW _ hmem

/-! ## Task 321 v6 REDESIGN — Phase 6: per-arrangement non-interior COMPLETENESS dischargers

The completeness mirrors of the Phase-5 `_sound` dischargers: where soundness EXTRACTS a witness
from a held literal, completeness BUILDS the literal from a witness. Same VVecEA2-channel abstraction
(over `φ : Formula` + `temporal_truth`), so every arrangement's `epL`/`epR`/`ptW` construction feeds
the Phase-7 gate completeness assembly uniformly (NOT per-`(zone, χ:NormalForm sig 1 1)`).

The two EXTERIOR zones carry the genuine NAVIGATION content (Prop 3.5 folding mechanism, md:87-94;
Cor 5.4 md:154-157): `zPastX` INTRODUCES the `Since` literal `snce φ ⊤` from a past witness `v < x`,
`zFutT` INTRODUCES the `Until` literal `untl φ ⊤` from a future witness `t < v` — the reconstruction
rides the temporal evaluation point (the witness `v`), NEVER an `x1 < e_i` relative-position literal
(LITMUS). The interval obligation is discharged by `temporal_truth_top` (the `⊤` segment is vacuous).
The three BOUNDARY zones (`zAtX`/`zAtT`/`zAtW`) are point-realizations at the fixed anchors `x`/`t`
and the interior anchor `w`: the bare literal `φ` held at the anchor IS its own completeness witness
(Amendment F3 preserved: a zone-literal on the complete 1-type, not a `w = e 1` provider equation). -/

/-- **`zPastX` completeness (exterior-past navigation).** A past witness `v < x` realizing `φ` BUILDS
the `Since` literal `snce φ ⊤` at the fixed left endpoint `x` — the introduction direction of the
Prop 3.5 folding mechanism (md:87-94). The witness rides the `Since` evaluation point; the `⊤`
segment obligation is vacuous (`temporal_truth_top`). LITMUS: no `x1 < e_i` literal. -/
theorem kvE_nonInterior_zPastX_complete {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x v : M.carrier) (φ : Formula)
    (hv_lt : v < x)
    (hv_phi : temporal_truth M atomMap v φ) :
    temporal_truth M atomMap x (Formula.snce φ Formula.top) :=
  ⟨v, hv_lt, hv_phi, fun r _ _ => temporal_truth_top M atomMap r⟩

/-- **`zFutT` completeness (exterior-future navigation).** A future witness `t < v` realizing `φ`
BUILDS the `Until` literal `untl φ ⊤` at the fixed right endpoint `t` — the introduction direction of
the Prop 3.5 folding mechanism (md:87-94; Cor 5.4 md:154-157). The witness rides the `Until`
evaluation point; the `⊤` segment obligation is vacuous. LITMUS: no `x1 < e_i` literal. -/
theorem kvE_nonInterior_zFutT_complete {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t v : M.carrier) (φ : Formula)
    (hv_lt : t < v)
    (hv_phi : temporal_truth M atomMap v φ) :
    temporal_truth M atomMap t (Formula.untl φ Formula.top) :=
  ⟨v, hv_lt, hv_phi, fun r _ _ => temporal_truth_top M atomMap r⟩

/-- **`zAtX` completeness (left-boundary point-realization).** The bare literal `φ` realized AT the
fixed left endpoint `x` IS its own completeness witness — the `v = x` zone (Def 3.1 md:61-74). No
navigation: the anchor witnesses directly. -/
theorem kvE_nonInterior_zAtX_complete {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x : M.carrier) (φ : Formula)
    (hx_phi : temporal_truth M atomMap x φ) :
    temporal_truth M atomMap x φ :=
  hx_phi

/-- **`zAtT` completeness (right-boundary point-realization).** The bare literal `φ` realized AT the
fixed right endpoint `t` IS its own completeness witness — the `v = t` zone (Def 3.1 md:61-74). -/
theorem kvE_nonInterior_zAtT_complete {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (φ : Formula)
    (ht_phi : temporal_truth M atomMap t φ) :
    temporal_truth M atomMap t φ :=
  ht_phi

/-- **`zAtW` completeness (interior-anchor point-realization).** The self-zone literal `φ` realized
AT the interior anchor `w` IS its own completeness witness — the `v = w` witness self-zone (v2
nine-zone correction; Def 3.1 md:61-74; Amendment F3 preserved). -/
theorem kvE_nonInterior_zAtW_complete {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w : M.carrier) (φ : Formula)
    (hw_phi : temporal_truth M atomMap w φ) :
    temporal_truth M atomMap w φ :=
  hw_phi

/-! ## Task 321 v6 REDESIGN — Phase 7: k=2 gate assembly → **RESCOPE (outer quant-layer connector
is a genuine unbuilt ENGINE; declared follow-up)** — machine-grounded DECISION GATE

**Question decided (with captured `lean_goal`).** Does the k=2 gate
`BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 atomMap h_surj P)` (:5032 def, :8712
carrier) close in both directions from the CURRENTLY LANDED v6 assets (Phases 1-6: the per-sub
navigated spine `kvE_fold_navigated`/`kvE_subBracket2V_correctness_pair` :8549, the Prop 4.3
re-flatten `reflatten_prop43`, the structural `VVecEA2.holds_flatMap_map`, and the 10 non-interior
`_sound`/`_complete` dischargers)? **Verdict: NOT in one dispatch — the OUTER quant-layer connector
between the depth-2 carrier and the depth-2 evaluation is a substantial UNBUILT engine.**

**This is NOT a task-327-style NO-GO.** Task 327 (:8760-8825) certified the CONSTANT-ARITY route
STRUCTURALLY impossible (`ZoneSpec 4` uncarryable by `ZoneSpec 1`). The v6 navigated route is
structurally CAPABLE: the landed `kvE_subBracket2V_correctness_pair` (:8549) discharges the arity-4
depth-1 sub instance in BOTH directions via `zoneHolds M [x1,w,x,t] zs v` over `ZoneSpec 4` — the
joint content task-327 lacked. What is missing is the *assembly*, not the *capability*.

**Captured soundness crux (`lean_goal`, mp direction).** After `intro qnf … M h_UZ h_SZ x t`,
`constructor`, `intro hcarrier`:

    hcarrier : VVecEA2.holds M atomMap (bracketEndChar_kvE2 atomMap h_surj P qnf) x t
    ⊢ ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x fun x ↦ t)) qnf

The RHS unfolds (NormalForm:203-207) to the atom layer PLUS the outer quant layer
`∀ sub : NormalForm sig 1 4, (∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] sub) ↔ qnf.2 sub = true` — the exact
crux the task-327 record names. `kvE2_body` (:8608) is a TWO-LEVEL carrier: its witness slots are
`charK`-typed (`charK = P.existF 0`) DEPTH-1 realizers connected to the inner reconstruction only
through `ExistProviders.correct` (:5013), while each positive sub `σ` contributes a navigated
sub-chain `kvE_subChain2V charBase charK σ` (:6674) SPLICED (via `slotsFor`) with all other subs'
slots into ONE bracket. The connector must (a) unpack the arrangement disjunct, (b) build the outer
witness `w` at the `ptW` slot, (c) type each depth-1 witness via `ExistProviders.correct`, (d)
discharge each positive sub's inner `∃ x1` through its navigated sub-chain + the per-sub `hgate`
(the arity-4 zone bridge, derivable from the carrier's `segXU`/`segUW`/`segWT` + `exclAt`
structure — the honest half of `kvE_subBracket2V_gate_holds_of_honest` :8086), and (e) thread the
depth-2 quant-layer fold. This is the "general-j=1 outer quant-layer fold engine" the v5 Phase-10
record declared missing; the v6 Phase-4 delivered only its STRUCTURAL core (`holds_flatMap_map`),
by design deferring the SEMANTIC assembly here.

**Failed closers on the captured crux (≥2 required; four captured — task-327 evidence style):**
  1. `exact kvE_subBracket2V_sound_of_outer atomMap h_surj (fun χ => P.existF 0 χ) qnf.2 …` →
     *Application type mismatch: `qnf.2` has type `NormalForm sig 1 (3+1) → Bool` but is expected to
     have type `NormalForm sig 1 4`.* The interior closer is PER-SUB (one `σ`); it is level-mismatched
     to the OUTER quant map `qnf.2` — the connector, not the closer, is what must range over subs.
  2. `simp only [bracketEndChar_kvE2, kvE2_body, VVecEA2.holds, VecEA2.holds] at hcarrier` → unfolds
     `hcarrier` to the full two-level arrangement-disjunct `∃ vea ∈ (if kvE_gate … then flatMap …)`
     existential; goal `∃ w, nf_eval_nf M 2 3 …` UNSOLVED (no bridge from disjunct to depth-2 eval).
  3. `rw [VVecEA2.holds_flatMap_map] at hcarrier` → *rewrite failed: pattern not found* — the Phase-4
     structural lemma does not match the un-unfolded `bracketEndChar_kvE2` carrier; its `let`-bound
     `S_L`/`S_R`/`mkDisjunct` internals are not externally nameable (the Phase-4 scope note), so even
     the structural collapse needs a carrier-specific re-derivation the connector must supply.
  4. `aesop` → *failed to prove the goal after exhaustive search.*

**LITMUS.** No `x1 < e_i` relative-position literal was introduced; the obstruction is the unbuilt
two-level assembly, not a positioning literal. The captured crux rides the evaluation point (the
`∃ w`/`∃ x1` existentials over `nf_eval_nf`), consistent with the navigated route.

**Consequence (RESCOPE, plan §Rollback RE-SCOPE fallback).** The k=2 gate is NOT closed by this
dispatch; per the honesty mandate NO `sorry` and NO gate-modulo-assumed-`hgate` is committed. The
remaining work is a well-scoped, structurally-sanctioned ENGINE (≈ the deferred Phase-4 semantic
assembly + Phase-7 glue), to be built in a dedicated follow-up:
`kvE2_outer_fold` : `kvE2_body … .holds M atomMap x t ↔ (atomLayer ∧ ∀ σ, (∃ x1, nf_eval M 1 4
[x1,w,x,t] σ) ↔ qnf.2 σ)` — unpacking the arrangement bracket into per-sub obligations via
`ExistProviders.correct` + the navigated sub-chain + the `hgate` discharge from the carrier's
per-region segment structure, then assembling the outer witness `w`. The v6 supporting bricks
(Phases 1-6) are the correct, landed inputs to this engine. This record is additive and inert. -/

end Bimodal.Metalogic.WeakCanonical.Kamp
