import FormalSystem.Metalogic.WeakCanonical.Kamp.PerFormulaRender
import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop35Chain
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Render MICRO-GATE — `translateProp35Fin` end-to-end on a nontrivial `n = 1` input (OFF-PATH)

**Purpose.** The render micro-gate for the per-formula-finite re-encode: the Prop 3.5
translation assembled ENTIRELY on the per-formula representation — point types
`UnaryTypeFin sig F M`, interval types `IntervalTypeFin sig F M`, rendered by the per-formula
renderer `unaryToFormulaFin` (`PerFormulaRender.lean`) — proved correct end-to-end through
`unaryToFormulaFin_correct`, and instantiated on a nontrivial `n = 1` input with NON-EMPTY
interval clauses (`ψGate` / `gate_translateProp35Fin`). This exercises the exact render
obligation the Phase-1 gate (`InfAlphabetProbe.lean`) did not: the render step and the full
`translateProp35`-style correctness under partial satisfaction, BEFORE any consumer migration.

**No full-alphabet `Finset.univ`, no `Fintype (sigE sig F).preds`, and no
`DecidableEq (sigE sig F).preds` anywhere in this module** — every enumeration is over the
mentioned-atom set `M` (via `M.attach.toList` inside `unaryToFormulaFin`) or over a
per-formula `Finset (UnaryTypeFin sig F M)` (`S.toList`), so every construction survives the
infinite E[Σ] of Def 4.1 (p.5). NO correctness statement is weakened: `efSatFin` is the
literal Def 3.1 satisfaction (ordered witness points, point types realized, interval types
holding on the open segments), stated on the partial relations `partialHolds` /
`intervalHoldsFin`.

Nothing here is imported by `KampPrior.lean` or the completeness spine; it is a pure off-path
probe (same discipline as `InfAlphabetProbe.lean` / `OptionBLocalityProbe.lean`). The
`nf_nvar_exist_all_depths | _k+2` residual is untouched; `#print axioms completeness_discrete`
is unaffected.

## Contents (namespace `RenderGate`, probe-local)

- `efPointTPFin` / `efIntervalSetTPFin`: render a partial 1-type / a per-formula interval type
  as a `TemporalPred` via `unaryToFormulaFin` (the Fin counterparts of `efPointTP` /
  `efIntervalSetTP`, `Prop35Assembly.lean`).
- `efPointTPFin_eval` / `efIntervalSetTPFin_eval`: they read back exactly as `partialHolds` /
  `intervalHoldsFin` — both THROUGH `unaryToFormulaFin_correct`.
- `EFFin` / `efSatFin`: the per-formula ∃∀-object over `M` and its literal Def 3.1
  satisfaction (probe-local; the production object is a later, separate step).
- `translateProp35Fin` / `translateProp35Fin_correct`: the Prop 3.5 translation on the
  per-formula representation and its full correctness
  `efSatFin N env ψ ↔ temporal_truth N atomMap (env 0) (translateProp35Fin … ψ)`.
- `ψGate` / `gate_translateProp35Fin`: the nontrivial `n = 1` instance — two ordered
  existential points, arbitrary point types, and NON-EMPTY (singleton) interval clauses in all
  three slots — with the gate equivalence as a direct instantiation.

## Reference grounding: Rabinovich PDF page → this probe

| Rabinovich (PDF) | Statement | This probe |
|---|---|---|
| Def 3.1, p.4 | ∃∀-formula: ordered points, unary point/interval types, each mentioning finitely many atoms | `EFFin`, `efSatFin` |
| Prop 3.5, p.5 | render a unary type as the conjunction of its (finitely many) atoms | `efPointTPFin` via `unaryToFormulaFin` |
| Prop 3.5, p.5 | an interval clause = finite disjunction of its admissible completions | `efIntervalSetTPFin` |
| Prop 3.5, p.5 | ∃∀ ≡ TL(Until, Since) via the chain formula | `translateProp35Fin_correct` |
| Def 4.1, p.5 | E[Σ] infinite ⇒ no whole-alphabet `Finset.univ` | all enumeration is `M`-relative |

## VERDICT: **GO**

`translateProp35Fin_correct` and its nontrivial `n = 1` instantiation
`gate_translateProp35Fin` (non-empty interval clauses in all three slots,
`ψGate_intervalType_nonempty`) build **sorry-free** and **axiom-clean**
(`#print axioms RenderGate.gate_translateProp35Fin` reports only
`[propext, Classical.choice, Quot.sound]`), off the live import path, with every enumeration
`M`-relative — no full-alphabet `Finset.univ`, no `Fintype (sigE sig F).preds`, and no
weakened correctness statement anywhere. The render obligation closes. **GO** on the
consumer-migration phases.

## References
- Rabinovich, *A Proof of Kamp's Theorem* (2014), Def 3.1 (p.4), Prop 3.5 (p.5), Def 4.1
  (p.5). Cited by PDF page; the companion markdown transcription is corrupt.
- `PerFormulaRender.lean` (`unaryToFormulaFin`, `unaryToFormulaFin_correct`);
  `PerFormulaType.lean` (`UnaryTypeFin`, `partialHolds`, `IntervalTypeFin`,
  `intervalHoldsFin`); `Translation.lean` (`translateEF1`, `translateEF1_correct`);
  `Prop35Chain.lean` (`buildRight_spec_iff_chain`, `buildLeft_spec_iff_chain`);
  `Prop35Assembly.lean` (the total-type assembly this probe mirrors on the per-formula
  representation).
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

namespace RenderGate

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. Rendering per-formula point/interval types as temporal predicates -/

/-- Render a partial 1-type over the mentioned-atom set `M` as a `TemporalPred` via the
per-formula renderer `unaryToFormulaFin`. The Fin counterpart of `efPointTP`. -/
noncomputable def efPointTPFin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (c : UnaryTypeFin sig F M) : TemporalPred :=
  ⟨unaryToFormulaFin nameOf c⟩

/-- `efPointTPFin` reads back exactly as `partialHolds` — this is `unaryToFormulaFin_correct`
verbatim. -/
theorem efPointTPFin_eval
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (c : UnaryTypeFin sig F M) (t : N.carrier) :
    (efPointTPFin atomMap nameOf c).eval_at N atomMap t ↔ partialHolds N c t := by
  unfold efPointTPFin TemporalPred.eval_at
  exact unaryToFormulaFin_correct N atomMap nameOf hName c t

/-- The disjunction of the per-completion `efPointTPFin` translations of a per-formula
interval type `S`, folding `TemporalPred.disj` over `S.toList` with unit `TemporalPred.bot`.
The Fin counterpart of `efIntervalSetTP`; the enumeration is over the per-formula `Finset`
`S`, never over the whole alphabet. -/
noncomputable def efIntervalSetTPFin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (S : IntervalTypeFin sig F M) : TemporalPred :=
  (S.toList.map (efPointTPFin atomMap nameOf)).foldr TemporalPred.disj TemporalPred.bot

/-- A `foldr`-of-`disj` temporal predicate holds at `y` iff some list element does (the empty
fold is `⊥`, which never holds). Instance-free restatement of the corresponding
`Prop35Assembly.lean` helper. -/
private theorem eval_at_foldr_disj
    (N : OrderedMonadicStructure (sigE sig F)) (atomMap : Formula → (sigE sig F).preds)
    (L : List TemporalPred) (y : N.carrier) :
    (L.foldr TemporalPred.disj TemporalPred.bot).eval_at N atomMap y ↔
      ∃ tp ∈ L, tp.eval_at N atomMap y := by
  induction L with
  | nil => simp [TemporalPred.eval_at, TemporalPred.bot, temporal_truth]
  | cons hd tl ih =>
    rw [List.foldr_cons, TemporalPred.eval_at_disj, ih]
    constructor
    · rintro (h | ⟨tp, htp, hev⟩)
      · exact ⟨hd, by simp, h⟩
      · exact ⟨tp, by simp [htp], hev⟩
    · rintro ⟨tp, htp, hev⟩
      rcases List.mem_cons.mp htp with rfl | htl
      · exact Or.inl hev
      · exact Or.inr ⟨tp, htl, hev⟩

/-- `efIntervalSetTPFin` reads back exactly as `intervalHoldsFin`: the disjunction of the
per-completion translations holds at `y` iff some admissible partial completion in `S` is
realized at `y` — each disjunct THROUGH `unaryToFormulaFin_correct` (via
`efPointTPFin_eval`). -/
theorem efIntervalSetTPFin_eval
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (S : IntervalTypeFin sig F M) (y : N.carrier) :
    (efIntervalSetTPFin atomMap nameOf S).eval_at N atomMap y ↔ intervalHoldsFin N S y := by
  rw [efIntervalSetTPFin, eval_at_foldr_disj]
  simp only [List.mem_map, Finset.mem_toList, intervalHoldsFin]
  constructor
  · rintro ⟨tp, ⟨c, hcS, rfl⟩, htp⟩
    exact ⟨c, hcS, (efPointTPFin_eval N atomMap nameOf hName c y).mp htp⟩
  · rintro ⟨c, hcS, hc⟩
    exact ⟨efPointTPFin atomMap nameOf c, ⟨c, hcS, rfl⟩,
      (efPointTPFin_eval N atomMap nameOf hName c y).mpr hc⟩

/-! ## 2. The per-formula ∃∀-object and its literal Def 3.1 satisfaction (probe-local) -/

/-- The per-formula ∃∀-object over the mentioned-atom set `M` (probe-local): `n+1` ordered
existential points, free variables pinned to points, per-formula point types
`UnaryTypeFin sig F M`, and per-formula interval types `IntervalTypeFin sig F M` (slot `0`
before `x₀`, slots `1..n` between consecutive points, slot `n+1` after `xₙ`). The literal
Def 3.1 (p.4) shape with all types partial over `M`. -/
structure EFFin (sig : MonadicSignature) (F : Finset Formula)
    (M : Finset (AtomKind (sigE sig F) 1)) (r : Nat) where
  /-- `n+1` ordered existential points `x₀ < … < xₙ`. -/
  n : Nat
  /-- Free variable `z_k` is pinned to existential point `x_{pin k}`. -/
  pin : Fin r → Fin (n + 1)
  /-- The partial unary point type `αⱼ` asserted at `xⱼ`. -/
  pointType : Fin (n + 1) → UnaryTypeFin sig F M
  /-- The partial interval types: slot `0` before `x₀`, slot `i` on `(x_{i-1}, xᵢ)` for
      `1 ≤ i ≤ n`, slot `n+1` after `xₙ`. -/
  intervalType : Fin (n + 2) → IntervalTypeFin sig F M

/-- Satisfaction of the per-formula ∃∀-object: there exist `n+1` strictly increasing witness
points such that each free variable equals its pinned point, each point type is realized
(`partialHolds`), and the before/between/after interval types hold along their open intervals
(`intervalHoldsFin`). The literal Def 3.1 (p.4) reading — NO correctness weakened. -/
def efSatFin {r : Nat} {M : Finset (AtomKind (sigE sig F) 1)}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : EFFin sig F M r) : Prop :=
  ∃ x : Fin (ψ.n + 1) → N.carrier,
    StrictMono x ∧
    (∀ k : Fin r, env k = x (ψ.pin k)) ∧
    (∀ j : Fin (ψ.n + 1), partialHolds N (ψ.pointType j) (x j)) ∧
    (∀ y : N.carrier, y < x 0 → intervalHoldsFin N (ψ.intervalType 0) y) ∧
    (∀ (i : Fin ψ.n) (y : N.carrier),
        x i.castSucc < y → y < x i.succ →
          intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y) ∧
    (∀ y : N.carrier, x (Fin.last ψ.n) < y →
        intervalHoldsFin N (ψ.intervalType (Fin.last (ψ.n + 1))) y)

/-- `efSatFin` in explicit interval form (the analog of `efSat_interval_iff`; definitional). -/
theorem efSatFin_interval_iff {r : Nat} {M : Finset (AtomKind (sigE sig F) 1)}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : EFFin sig F M r) :
    efSatFin N env ψ ↔
      ∃ x : Fin (ψ.n + 1) → N.carrier,
        StrictMono x ∧
        (∀ k : Fin r, env k = x (ψ.pin k)) ∧
        (∀ j : Fin (ψ.n + 1), partialHolds N (ψ.pointType j) (x j)) ∧
        (∀ y : N.carrier, y < x 0 → intervalHoldsFin N (ψ.intervalType 0) y) ∧
        (∀ (i : Fin ψ.n) (y : N.carrier),
            x i.castSucc < y → y < x i.succ →
              intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y) ∧
        (∀ y : N.carrier, x (Fin.last ψ.n) < y →
            intervalHoldsFin N (ψ.intervalType (Fin.last (ψ.n + 1))) y) := by
  simp only [efSatFin]

/-! ## 3. The Prop 3.5 translation on the per-formula representation -/

/-- **The per-formula Prop 3.5 translation.** `translateEF1` pinned at the free variable's
witness point, with point types rendered via `efPointTPFin` and interval types rendered via
`efIntervalSetTPFin` — every render THROUGH `unaryToFormulaFin`, all enumeration
`M`-relative. -/
noncomputable def translateProp35Fin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (ψ : EFFin sig F M 1) : Formula :=
  translateEF1 ψ.n (ψ.pin 0)
    (fun j => efPointTPFin atomMap nameOf (ψ.pointType j))
    (fun i => efIntervalSetTPFin atomMap nameOf (ψ.intervalType i))

/-- **Render correctness, end-to-end (the MICRO-GATE obligation).** The per-formula Prop 3.5
translation is fully correct: `efSatFin N env ψ ↔ temporal_truth N atomMap (env 0)
(translateProp35Fin … ψ)`. The proof routes every point-type clause through
`efPointTPFin_eval` and every interval clause through `efIntervalSetTPFin_eval` — i.e.
end-to-end THROUGH `unaryToFormulaFin_correct` — and reuses the representation-independent
chain machinery (`translateEF1_correct`, `buildRight_spec_iff_chain`,
`buildLeft_spec_iff_chain`) unchanged. Mirrors `translateProp35_correct`
(`Prop35Assembly.lean`) with the total-type interfaces replaced by the per-formula ones; NO
correctness statement is weakened and no `Fintype`/`DecidableEq` instance on the alphabet is
consumed. -/
theorem translateProp35Fin_correct
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (env : Fin 1 → N.carrier) (ψ : EFFin sig F M 1) :
    efSatFin N env ψ ↔
      temporal_truth N atomMap (env 0) (translateProp35Fin atomMap nameOf ψ) := by
  rw [translateProp35Fin, translateEF1_correct]
  set k : Fin (ψ.n + 1) := ψ.pin 0 with hk_def
  set alphaR : Nat → TemporalPred :=
    fun m => efPointTPFin atomMap nameOf (ψ.pointType ⟨min (k.val + 1 + m) ψ.n, by omega⟩)
    with halphaR_def
  set betaR : Nat → TemporalPred :=
    fun m => efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨min (k.val + 1 + m) ψ.n, by omega⟩)
    with hbetaR_def
  set alphaL : Nat → TemporalPred :=
    fun m => efPointTPFin atomMap nameOf (ψ.pointType ⟨k.val - 1 - m, by omega⟩)
    with halphaL_def
  set betaL : Nat → TemporalPred :=
    fun m => efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨k.val - 1 - m + 1, by omega⟩)
    with hbetaL_def
  have hright_eq :
      (List.finRange (ψ.n - k.val)).map (fun i =>
        let idx := k.val + 1 + i.val
        (efPointTPFin atomMap nameOf (ψ.pointType ⟨idx, by omega⟩),
         efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨idx, by omega⟩))) =
      (List.finRange (ψ.n - k.val)).map (fun i => (alphaR i.val, betaR i.val)) := by
    apply List.map_congr_left
    intro i _
    simp only [halphaR_def, hbetaR_def]
    have e : min (k.val + 1 + i.val) ψ.n = k.val + 1 + i.val := by omega
    simp only [e]
  have hleft_eq :
      (List.finRange k.val).map (fun i =>
        let idx := k.val - 1 - i.val
        (efPointTPFin atomMap nameOf (ψ.pointType ⟨idx, by omega⟩),
         efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨idx + 1, by omega⟩))) =
      (List.finRange k.val).map (fun i => (alphaL i.val, betaL i.val)) := by
    apply List.map_congr_left
    intro i _
    simp only [halphaL_def, hbetaL_def]
  rw [hright_eq, hleft_eq, buildRight_spec_iff_chain, buildLeft_spec_iff_chain]
  constructor
  · intro h
    rw [efSatFin_interval_iff] at h
    obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩ := h
    have hpin0 : env 0 = x k := hpin 0
    refine ⟨?_, ?_, ?_⟩
    · rw [hpin0]
      exact (efPointTPFin_eval N atomMap nameOf hName (ψ.pointType k) (x k)).mpr (hpt k)
    · refine ⟨fun m => x ⟨min (k.val + m) ψ.n, by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
      · show x ⟨min (k.val + 0) ψ.n, by omega⟩ = env 0
        have e0 : min (k.val + 0) ψ.n = k.val := by omega
        simp only [e0]
        exact hpin0.symm
      · intro i j hij hjd
        show x ⟨min (k.val + i) ψ.n, by omega⟩ < x ⟨min (k.val + j) ψ.n, by omega⟩
        have ei : min (k.val + i) ψ.n = k.val + i := by omega
        have ej : min (k.val + j) ψ.n = k.val + j := by omega
        simp only [ei, ej]
        exact hmono (show (⟨k.val + i, by omega⟩ : Fin (ψ.n + 1)) < ⟨k.val + j, by omega⟩ by
          simp only [Fin.lt_def]; omega)
      · intro i hi
        show TemporalPred.eval_at N atomMap (alphaR i) (x ⟨min (k.val + (i + 1)) ψ.n, by omega⟩)
        have e1 : min (k.val + (i + 1)) ψ.n = k.val + 1 + i := by omega
        simp only [halphaR_def, e1]
        have e2 : min (k.val + 1 + i) ψ.n = k.val + 1 + i := by omega
        simp only [e2]
        rw [efPointTPFin_eval (hName := hName)]
        exact hpt ⟨k.val + 1 + i, by omega⟩
      · intro i hi y hy1 hy2
        show TemporalPred.eval_at N atomMap (betaR i) y
        simp only [hbetaR_def]
        have e2 : min (k.val + 1 + i) ψ.n = k.val + 1 + i := by omega
        simp only [e2]
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have eidx : k.val + 1 + i = k.val + i + 1 := by omega
        simp only [eidx]
        have ei : min (k.val + i) ψ.n = k.val + i := by omega
        have ei1 : min (k.val + (i + 1)) ψ.n = k.val + i + 1 := by omega
        have hy1' : x (⟨k.val + i, by omega⟩ : Fin ψ.n).castSucc < y := by
          show x ⟨k.val + i, by omega⟩ < y
          rw [show (⟨k.val + i, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨min (k.val + i) ψ.n, by omega⟩ from by simp only [ei]]
          exact hy1
        have hy2' : y < x (⟨k.val + i, by omega⟩ : Fin ψ.n).succ := by
          show y < x ⟨k.val + i + 1, by omega⟩
          rw [show (⟨k.val + i + 1, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨min (k.val + (i + 1)) ψ.n, by omega⟩ from by simp only [ei1]]
          exact hy2
        exact hbetween ⟨k.val + i, by omega⟩ y hy1' hy2'
      · intro y hy
        show TemporalPred.eval_at N atomMap
          (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨ψ.n + 1, by omega⟩)) y
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have ed : min (k.val + (ψ.n - k.val)) ψ.n = ψ.n := by omega
        have hy' : x (Fin.last ψ.n) < y := by
          rw [show (Fin.last ψ.n) = (⟨min (k.val + (ψ.n - k.val)) ψ.n, by omega⟩ : Fin (ψ.n + 1))
              from by apply Fin.ext; simp only [ed, Fin.val_last]]
          exact hy
        exact hafter y hy'
    · refine ⟨fun m => x ⟨k.val - m, by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
      · show x ⟨k.val - 0, by omega⟩ = env 0
        simp only [Nat.sub_zero]
        exact hpin0.symm
      · intro i j hij hjd
        show x ⟨k.val - j, by omega⟩ < x ⟨k.val - i, by omega⟩
        exact hmono (show (⟨k.val - j, by omega⟩ : Fin (ψ.n + 1)) < ⟨k.val - i, by omega⟩ by
          simp only [Fin.lt_def]; omega)
      · intro i hi
        show TemporalPred.eval_at N atomMap (alphaL i) (x ⟨k.val - (i + 1), by omega⟩)
        simp only [halphaL_def]
        have e : k.val - (i + 1) = k.val - 1 - i := by omega
        simp only [e]
        rw [efPointTPFin_eval (hName := hName)]
        exact hpt ⟨k.val - 1 - i, by omega⟩
      · intro i hi y hy1 hy2
        show TemporalPred.eval_at N atomMap (betaL i) y
        simp only [hbetaL_def]
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have e : k.val - (i + 1) = k.val - 1 - i := by omega
        have e' : k.val - 1 - i + 1 = k.val - i := by omega
        have hy1' : x (⟨k.val - 1 - i, by omega⟩ : Fin ψ.n).castSucc < y := by
          show x ⟨k.val - 1 - i, by omega⟩ < y
          rw [show (⟨k.val - 1 - i, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨k.val - (i + 1), by omega⟩ from by simp only [e]]
          exact hy1
        have hy2' : y < x (⟨k.val - 1 - i, by omega⟩ : Fin ψ.n).succ := by
          show y < x ⟨k.val - 1 - i + 1, by omega⟩
          rw [show (⟨k.val - 1 - i + 1, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨k.val - i, by omega⟩ from by simp only [e']]
          exact hy2
        exact hbetween ⟨k.val - 1 - i, by omega⟩ y hy1' hy2'
      · intro y hy
        show TemporalPred.eval_at N atomMap
          (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨0, by omega⟩)) y
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have h0 : k.val - k.val = 0 := by omega
        have hy' : y < x (⟨0, by omega⟩ : Fin (ψ.n + 1)) := by
          rw [show (⟨0, by omega⟩ : Fin (ψ.n + 1)) = (⟨k.val - k.val, by omega⟩ : Fin (ψ.n + 1))
              from by simp only [h0]]
          exact hy
        exact hbefore y hy'
  · rintro ⟨hpt0, ⟨x', hx'0, hx'mono, hx'alpha, hx'beta, hx'cap⟩,
      ⟨x'', hx''0, hx''mono, hx''alpha, hx''beta, hx''cap⟩⟩
    set x : Fin (ψ.n + 1) → N.carrier :=
      fun j => if j.val ≤ k.val then x'' (k.val - j.val) else x' (j.val - k.val) with hx_def
    have hx_left : ∀ j : Fin (ψ.n + 1), j.val ≤ k.val → x j = x'' (k.val - j.val) := by
      intro j hj; simp only [hx_def, if_pos hj]
    have hx_right : ∀ j : Fin (ψ.n + 1), ¬ j.val ≤ k.val → x j = x' (j.val - k.val) := by
      intro j hj; simp only [hx_def, if_neg hj]
    have hxk : x k = env 0 := by
      rw [hx_left k (le_refl _), Nat.sub_self, hx''0]
    have hx0 : x (0 : Fin (ψ.n + 1)) = x'' k.val := by
      have hj : (0 : Fin (ψ.n + 1)).val ≤ k.val := by
        have e : (0 : Fin (ψ.n + 1)).val = 0 := rfl
        omega
      rw [hx_left 0 hj]
      have e : (0 : Fin (ψ.n + 1)).val = 0 := rfl
      rw [e, Nat.sub_zero]
    have hxlast : x (Fin.last ψ.n) = x' (ψ.n - k.val) := by
      by_cases h : (Fin.last ψ.n).val ≤ k.val
      · have hval : (Fin.last ψ.n).val = ψ.n := Fin.val_last ψ.n
        have hkeq : k.val = ψ.n := by omega
        rw [hx_left (Fin.last ψ.n) h, hval]
        have e1 : k.val - ψ.n = 0 := by omega
        have e2 : ψ.n - k.val = 0 := by omega
        rw [e1, e2, hx''0, hx'0]
      · have hval : (Fin.last ψ.n).val = ψ.n := Fin.val_last ψ.n
        rw [hx_right (Fin.last ψ.n) h, hval]
    rw [efSatFin_interval_iff]
    refine ⟨x, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · -- StrictMono x
      intro a b hab
      have hab' : a.val < b.val := by simp only [Fin.lt_def] at hab; omega
      by_cases ha : a.val ≤ k.val <;> by_cases hb : b.val ≤ k.val
      · rw [hx_left a ha, hx_left b hb]
        exact hx''mono (k.val - b.val) (k.val - a.val) (by omega) (by omega)
      · rw [hx_left a ha, hx_right b hb]
        have h1 : x'' (k.val - a.val) ≤ env 0 := by
          by_cases haeq : a.val = k.val
          · have : x'' (k.val - a.val) = env 0 := by rw [haeq, Nat.sub_self, hx''0]
            exact le_of_eq this
          · have hstep := hx''mono 0 (k.val - a.val) (by omega) (by omega)
            rw [hx''0] at hstep
            exact le_of_lt hstep
        have h2 : env 0 < x' (b.val - k.val) := by
          have hstep := hx'mono 0 (b.val - k.val) (by omega) (by omega)
          rwa [hx'0] at hstep
        exact lt_of_le_of_lt h1 h2
      · exact absurd hab' (by omega)
      · rw [hx_right a ha, hx_right b hb]
        exact hx'mono (a.val - k.val) (b.val - k.val) (by omega) (by omega)
    · -- pin condition
      intro m
      have hm0 : m = 0 := Subsingleton.elim m 0
      rw [hm0, ← hk_def]
      exact hxk.symm
    · -- pointType
      intro j
      by_cases hj : j.val ≤ k.val
      · rw [hx_left j hj]
        by_cases hjk : j.val = k.val
        · have hzero : k.val - j.val = 0 := by omega
          rw [hzero, hx''0]
          have hjeqk : j = k := Fin.ext hjk
          rw [hjeqk]
          exact (efPointTPFin_eval N atomMap nameOf hName (ψ.pointType k) (env 0)).mp hpt0
        · have hmk : k.val - j.val - 1 < k.val := by omega
          have halph := hx''alpha (k.val - j.val - 1) hmk
          have hm1 : k.val - j.val - 1 + 1 = k.val - j.val := by omega
          rw [hm1] at halph
          simp only [halphaL_def] at halph
          have hidx : k.val - 1 - (k.val - j.val - 1) = j.val := by omega
          simp only [hidx] at halph
          rw [efPointTPFin_eval (hName := hName)] at halph
          exact halph
      · rw [hx_right j hj]
        have hjk : k.val < j.val := by omega
        have hmd : j.val - k.val - 1 < ψ.n - k.val := by omega
        have halph := hx'alpha (j.val - k.val - 1) hmd
        have hm1 : j.val - k.val - 1 + 1 = j.val - k.val := by omega
        rw [hm1] at halph
        simp only [halphaR_def] at halph
        have hidx : min (k.val + 1 + (j.val - k.val - 1)) ψ.n = j.val := by omega
        simp only [hidx] at halph
        rw [efPointTPFin_eval (hName := hName)] at halph
        exact halph
    · -- before clause
      intro y hy
      rw [hx0] at hy
      have hb := hx''cap y hy
      exact (efIntervalSetTPFin_eval N atomMap nameOf hName
        (ψ.intervalType (⟨0, by omega⟩ : Fin (ψ.n + 2))) y).mp hb
    · -- between clause
      intro i y hy1 hy2
      show intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y
      have hcs : i.castSucc.val = i.val := rfl
      have hsc : i.succ.val = i.val + 1 := rfl
      rcases lt_trichotomy i.val k.val with hlt | heq | hgt
      · have h1 : i.castSucc.val ≤ k.val := by rw [hcs]; omega
        have h2 : i.succ.val ≤ k.val := by rw [hsc]; omega
        rw [hx_left i.castSucc h1, hcs] at hy1
        rw [hx_left i.succ h2, hsc] at hy2
        have hmk : k.val - i.val - 1 < k.val := by omega
        have hm1 : k.val - i.val - 1 + 1 = k.val - i.val := by omega
        have hbeta := hx''beta (k.val - i.val - 1) hmk y (by rw [hm1]; exact hy1) hy2
        simp only [hbetaL_def] at hbeta
        have hidx : k.val - 1 - (k.val - i.val - 1) + 1 = i.val + 1 := by omega
        simp only [hidx] at hbeta
        rw [efIntervalSetTPFin_eval (hName := hName)] at hbeta
        exact hbeta
      · have h1 : i.castSucc.val ≤ k.val := by rw [hcs]; omega
        have h2 : ¬ i.succ.val ≤ k.val := by rw [hsc]; omega
        rw [hx_left i.castSucc h1, hcs, heq, Nat.sub_self, hx''0] at hy1
        rw [hx_right i.succ h2, hsc] at hy2
        have hd0 : 0 < ψ.n - k.val := by omega
        have hidx0 : i.val + 1 - k.val = 1 := by omega
        have hbeta := hx'beta 0 hd0 y (by rw [hx'0]; exact hy1) (by rw [hidx0] at hy2; exact hy2)
        simp only [hbetaR_def] at hbeta
        have hidx : min (k.val + 1 + 0) ψ.n = i.val + 1 := by omega
        simp only [hidx] at hbeta
        rw [efIntervalSetTPFin_eval (hName := hName)] at hbeta
        exact hbeta
      · have h1 : ¬ i.castSucc.val ≤ k.val := by rw [hcs]; omega
        have h2 : ¬ i.succ.val ≤ k.val := by rw [hsc]; omega
        rw [hx_right i.castSucc h1, hcs] at hy1
        rw [hx_right i.succ h2, hsc] at hy2
        have hmd : i.val - k.val < ψ.n - k.val := by omega
        have hidx1 : i.val + 1 - k.val = i.val - k.val + 1 := by omega
        have hbeta := hx'beta (i.val - k.val) hmd y hy1 (by rw [hidx1] at hy2; exact hy2)
        simp only [hbetaR_def] at hbeta
        have hidx : min (k.val + 1 + (i.val - k.val)) ψ.n = i.val + 1 := by omega
        simp only [hidx] at hbeta
        rw [efIntervalSetTPFin_eval (hName := hName)] at hbeta
        exact hbeta
    · -- after clause
      intro y hy
      rw [hxlast] at hy
      have hb := hx'cap y hy
      exact (efIntervalSetTPFin_eval N atomMap nameOf hName
        (ψ.intervalType (⟨ψ.n + 1, by omega⟩ : Fin (ψ.n + 2))) y).mp hb

/-! ## 4. The nontrivial `n = 1` gate instance (non-empty interval clauses) -/

/-- **The nontrivial `n = 1` gate input**: TWO ordered existential points (`n = 1`), the free
variable pinned to the first, arbitrary per-formula point types `c 0`, `c 1`, and NON-EMPTY
(singleton) interval clauses `{b i}` in all three slots — before, between, and after. This is
a genuine multi-point input with contentful interval constraints, unlike the Phase-1 gate's
`n = 0` / empty-interval `ξConcrete`. -/
def ψGate {M : Finset (AtomKind (sigE sig F) 1)}
    (c : Fin 2 → UnaryTypeFin sig F M) (b : Fin 3 → UnaryTypeFin sig F M) :
    EFFin sig F M 1 where
  n := 1
  pin := fun _ => 0
  pointType := c
  intervalType := fun i => {b i}

/-- The gate input's interval clauses are all NON-EMPTY (nontriviality witness). -/
theorem ψGate_intervalType_nonempty {M : Finset (AtomKind (sigE sig F) 1)}
    (c : Fin 2 → UnaryTypeFin sig F M) (b : Fin 3 → UnaryTypeFin sig F M) (i : Fin 3) :
    ((ψGate c b).intervalType i).Nonempty :=
  ⟨b i, Finset.mem_singleton_self (b i)⟩

/-- **The MICRO-GATE, instantiated.** `translateProp35Fin` is correct end-to-end (through
`unaryToFormulaFin_correct`) on the nontrivial `n = 1` input `ψGate c b` with non-empty
interval clauses — a direct instantiation of `translateProp35Fin_correct`, with no
full-alphabet `Finset.univ` and no weakened correctness statement anywhere in the pipeline. -/
theorem gate_translateProp35Fin
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (env : Fin 1 → N.carrier)
    (c : Fin 2 → UnaryTypeFin sig F M) (b : Fin 3 → UnaryTypeFin sig F M) :
    efSatFin N env (ψGate c b) ↔
      temporal_truth N atomMap (env 0) (translateProp35Fin atomMap nameOf (ψGate c b)) :=
  translateProp35Fin_correct N atomMap nameOf hName env (ψGate c b)

end RenderGate

end Bimodal.Metalogic.WeakCanonical.Kamp
