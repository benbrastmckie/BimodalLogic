import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregateHookDischarge

/-! # Point-channel merge variants (0,1) + (0,2) + R9 genericity probe (task 350 Phases 12a/12b)

Per-qnf k=1 carrier for the `w = x` channel of the population existential
`∃ w, nf_eval_nf M 1 3 [w, x, t] qnf` (the P3-pt dispatcher channel of plan v3, Phase 12a):
at the coincident witness `w = x` the env has DUPLICATED entries at positions 0, 1, and the
evaluation collapses — under a per-`qnf` syntactic gate — to the fixed-anchor arity-2
evaluation `nf_eval_nf M 1 2 [x, t] (collapsed qnf)`.

## Rabinovich anchor

Lemma 3.2(2) (chunk_0009): the coincident-witness collapse to ≤2 free variables — when two
points of a bracket configuration coincide, the merged point takes the CONJOINED point type
and the configuration collapses to one fewer free variable. Here the merge is positions
(0,1) of the arity-3 population env (witness `w` onto anchor `x`), the exact mirror of the
delivered diagonal-seam merge at positions (1,2) (`agg_diag_collapse_k1`,
AggregateHookDischarge.lean:1907).

## R9 genericity probe (FIRST deliverable — risk retirement)

Plan v3 risk R9 flags that the delivered gated-collapse engines were only ever instantiated
at the (1,2) merge (`aggExpand23`/`aggMerge32`). The probe below
(`aggPm01Probe_clause_iff`) encodes the (0,1) merge END-TO-END for ONE concrete qnf (the
all-false probe qnf) and proves its clause iff, machine-confirming that

- `renameNF` (NfDepth0Generalized.lean:373),
- `renameNF_eval_diag0` (NfDepth0Generalized.lean:1646), and
- `agg_rename_fixpoint_of_eval` (AggregateHookDischarge.lean:1853)

are rename-generic at position (0,1): all three are applied at the new rename pair
`aggPmExpand01`/`aggPmMerge01` (row level) and `liftIdx aggPmExpand01`/`liftIdx aggPmMerge01`
(sub level) with the duplicated-head env `[x, x, t]`.

## Structure

1. The (0,1) rename pair + retraction + concrete-typed wrappers.
2. `agg_pm01_collapse_k1` — gated depth-1 (0,1) anchor collapse (mirror of
   `agg_diag_collapse_k1` at the new position).
3. **R9 probe**: `aggPm01ProbeQnf` + `aggPm01Probe_clause_iff` (end-to-end concrete instance).
4. `aggPm01GateK1` / `aggPm01_gate_of_eval` — the syntactic gate and its forcing (any realizer
   of the duplicated-head evaluation forces the gate, via the fixpoint engine).
5. `aggPm01_clause_iff` — the clause iff: duplicated-head evaluation ↔ gate ∧ fixed-anchor
   collapsed evaluation. `aggPm01ClauseK1(_iff)` — the dite carrier gating non-fixpoint qnf
   to `⊥` exactly as `aggPosDiagK1` (AggregateHookDischarge.lean:1999).
6. `aggPm01_fold_iff` / `aggPm01_clause_fold_iff` — the collapsed side characterized via the
   depth-1 fold engine `nf_eval_depth1_fold_iff` at n=2 (CarrierKv.lean:466), handing the
   clause to the delivered agg2 kit downstream (Phase 16 dispatcher).

## Guards

G1 — the population obligation itself stays arity-3; this module handles only the `w = x`
channel where the collapse is Lemma 3.2(2)-lossless under the gate. G2/G4 — anchors exactly
`{x, t}`. G5 — every bridge below is a manual `constructor`/`intro`/`exact` step (no
simp/omega/aesop shortcut of the Lemma 3.2(2) chain). FORBIDDEN `nf_char3_deeper_split` is
not referenced.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 3.2(2) (chunk_0009).
- specs/350_…/plans/03_negfix-refactor-exterior-carriers.md, Phase 12a.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

section AggPointMerge01

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-! ## The (0,1) rename pair

Collapsed arity-2 slots: slot 0 = the merged point (`w = x`), slot 1 = the origin `t`.
Arity-3 positions: 0 = the witness `w`, 1 = the anchor `x`, 2 = the origin `t`. -/

/-- Skip embedding `Fin 2 → Fin 3` (`0 ↦ 0`, `1 ↦ 2`): the section of the (0,1) merge. -/
def aggPmExpand01 : Fin 2 → Fin 3 := fun i => if i.val = 0 then ⟨0, by omega⟩ else ⟨2, by omega⟩

/-- Head merge `Fin 3 → Fin 2` (`0 ↦ 0`, `1 ↦ 0`, `2 ↦ 1`): positions 0, 1 merge. -/
def aggPmMerge01 : Fin 3 → Fin 2 := fun i => if i.val ≤ 1 then ⟨0, by omega⟩ else ⟨1, by omega⟩

/-- `aggPmMerge01 ∘ aggPmExpand01 = id` (the retraction). -/
theorem aggPmMerge01_expand01 : ∀ j : Fin 2, aggPmMerge01 (aggPmExpand01 j) = j := by
  decide

/-- Lifted retraction on `Fin 3`. -/
theorem aggPm_liftMerge_liftExpand01 :
    ∀ j : Fin 3, liftIdx aggPmMerge01 (liftIdx aggPmExpand01 j) = j := by
  intro j
  refine Fin.cases ?_ ?_ j
  · rw [liftIdx_zero, liftIdx_zero]
  · intro i
    rw [liftIdx_succ, liftIdx_succ, aggPmMerge01_expand01]

/-! Concrete-typed rename wrappers (pin `k` and the arities, exactly as the diagonal-seam
wrappers do — the bare `renameNF` leaves its depth implicit `{k}` stuck otherwise). -/

/-- Collapse an arity-3 depth-0 row to arity 2 (positions 0, 1 merge). -/
def aggPm01CollapseRow {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 3 → NormalForm sig 0 2 :=
  renameNF aggPmExpand01 aggPmMerge01
/-- Duplicate an arity-2 depth-0 row to arity 3 (slot 0 duplicated onto positions 0, 1). -/
def aggPm01DupRow {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 2 → NormalForm sig 0 3 :=
  renameNF aggPmMerge01 aggPmExpand01
/-- Collapse an arity-4 depth-0 sub to arity 3 (positions 1, 2 merge; fresh slot fixed). -/
def aggPm01CollapseSub {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 4 → NormalForm sig 0 3 :=
  renameNF (liftIdx aggPmExpand01) (liftIdx aggPmMerge01)
/-- Duplicate an arity-3 depth-0 sub to arity 4 (slot 1 duplicated; fresh slot fixed). -/
def aggPm01DupSub {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 3 → NormalForm sig 0 4 :=
  renameNF (liftIdx aggPmMerge01) (liftIdx aggPmExpand01)
/-- Collapse a depth-1 arity-3 NF to arity 2 (the (0,1) point-channel collapse). -/
def aggPm01CollapseK1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 1 3 → NormalForm sig 1 2 :=
  renameNF aggPmExpand01 aggPmMerge01

/-- **Gated depth-1 (0,1) anchor collapse** (Lemma 3.2(2) coincident-witness collapse at
    `w = x`; the position-(0,1) mirror of `agg_diag_collapse_k1`). Under the syntactic gate —
    the atom row is a (0,1) duplicate-collapse fixpoint and every non-fixpoint arity-4 sub is
    unmarked — the depth-1 evaluation at the duplicated-head env `[x, x, t]` is equivalent to
    the depth-1 arity-2 evaluation of the collapsed NF at the fixed anchors `[x, t]`. -/
theorem agg_pm01_collapse_k1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier)
    (hrow : aggPm01DupRow (aggPm01CollapseRow qnf.1) = qnf.1)
    (hquant : ∀ σ : NormalForm sig 0 4, aggPm01DupSub (aggPm01CollapseSub σ) ≠ σ →
      qnf.2 σ = false) :
    nf_eval_nf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) qnf ↔
      nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggPm01CollapseK1 qnf) := by
  set E : Fin 3 → M.carrier := Fin.cons x (Fin.cons x (fun _ => t))
  set e : Fin 2 → M.carrier := Fin.cons x (fun _ => t)
  -- Env compatibilities for the rename bridges.
  have hcomp : ∀ i : Fin 2, e i = E (aggPmExpand01 i) := by
    intro i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
  have hcomp2 : ∀ i : Fin 3, E i = e (aggPmMerge01 i) := by
    intro i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
  -- Row-level rename bridge (under the fixpoint): eval₃ E qnf.1 ↔ eval₂ e (collapse row).
  have hrowbridge : nf_eval_nf M 0 3 E (qnf.1 : NormalForm sig 0 3) ↔
      nf_eval_nf M 0 2 e (aggPm01CollapseRow qnf.1) := by
    conv_lhs => rw [← hrow]
    exact renameNF_eval_diag0 M aggPmExpand01 aggPmMerge01 E e hcomp hcomp2
      aggPmMerge01_expand01 (aggPm01CollapseRow qnf.1)
  -- σ-level rename bridge per inner witness v.
  have hsub : ∀ (v : M.carrier) (τ : NormalForm sig 0 3),
      nf_eval_nf M 0 4 (Fin.cons v E) (aggPm01DupSub τ) ↔
        nf_eval_nf M 0 3 (Fin.cons v e) τ := by
    intro v τ
    exact renameNF_eval_diag0 M (liftIdx aggPmExpand01) (liftIdx aggPmMerge01)
      (Fin.cons v E) (Fin.cons v e)
      (cons_comp_liftIdx aggPmExpand01 E e v hcomp)
      (cons_comp_liftIdx aggPmMerge01 e E v hcomp2)
      aggPm_liftMerge_liftExpand01 τ
  -- Depth-1 defeq unfolds on both sides.
  have hwhole3 : nf_eval_nf M 1 3 E qnf ↔
      (nf_eval_nf M 0 3 E (qnf.1 : NormalForm sig 0 3) ∧
        (∀ σ : NormalForm sig 0 4,
          (∃ v : M.carrier, nf_eval_nf M 0 4 (Fin.cons v E) σ) ↔ qnf.2 σ = true)) :=
    Iff.rfl
  have hwhole2 : nf_eval_nf M 1 2 e (aggPm01CollapseK1 qnf) ↔
      (nf_eval_nf M 0 2 e (aggPm01CollapseRow qnf.1) ∧
        (∀ τ : NormalForm sig 0 3,
          (∃ v : M.carrier, nf_eval_nf M 0 3 (Fin.cons v e) τ) ↔
            qnf.2 (aggPm01DupSub τ) = true)) :=
    Iff.rfl
  rw [hwhole3, hwhole2]
  constructor
  · rintro ⟨hatom, hq⟩
    refine ⟨hrowbridge.mp hatom, fun τ => ?_⟩
    have := hq (aggPm01DupSub τ)
    exact (exists_congr (fun v => (hsub v τ).symm)).trans this
  · rintro ⟨hatom2, hq2⟩
    refine ⟨hrowbridge.mpr hatom2, fun σ => ?_⟩
    by_cases hfix : aggPm01DupSub (aggPm01CollapseSub σ) = σ
    · have hτ := hq2 (aggPm01CollapseSub σ)
      rw [hfix] at hτ
      refine Iff.trans ?_ hτ
      refine exists_congr (fun v => ?_)
      conv_lhs => rw [← hfix]
      exact hsub v (aggPm01CollapseSub σ)
    · constructor
      · rintro ⟨v, hv⟩
        refine absurd ?_ hfix
        show aggPm01DupSub (aggPm01CollapseSub σ) = σ
        refine agg_rename_fixpoint_of_eval M (liftIdx aggPmExpand01)
          (liftIdx aggPmMerge01) aggPm_liftMerge_liftExpand01 (Fin.cons v E) ?_ σ hv
        intro i
        refine Fin.cases ?_ ?_ i
        · rw [liftIdx_zero, liftIdx_zero]
        · intro j
          rw [liftIdx_succ, liftIdx_succ]
          simp only [Fin.cons_succ]
          rw [← hcomp (aggPmMerge01 j), hcomp2 j]
      · intro hbit
        rw [hquant σ hfix] at hbit
        exact Bool.noConfusion hbit

/-! ## R9 GENERICITY PROBE (plan v3 Phase 12a FIRST task)

The (0,1) merge end-to-end for ONE concrete qnf — the all-false probe qnf — with its clause
iff proved through the full engine chain (`renameNF_eval_diag0` at row + sub level,
`agg_rename_fixpoint_of_eval` at the lifted (0,1) renames inside the backward branch of
`agg_pm01_collapse_k1`). Compiling green, this retires risk R9: the engines are
rename-generic at position (0,1). -/

/-- Any depth-0 rename of the all-false row is the all-false row (both the collision branch
    and the transported branch of `renameNF` read `false`). -/
theorem aggPm01_renameNF_false {a b : Nat} (f : Fin b → Fin a) (r : Fin a → Fin b) :
    renameNF (sig := sig) (k := 0) f r (fun _ => false) = (fun _ => false) := by
  funext atom
  match atom with
  | .pred p i => rfl
  | .order i j hij =>
    show (if hf : f i = f j then false else (false : Bool)) = false
    split <;> rfl

/-- The R9 probe qnf: all-false atom row, all-false quant layer. -/
def aggPm01ProbeQnf : NormalForm sig 1 3 := ((fun _ => false), (fun _ => false))

/-- The probe row is a (0,1) duplicate-collapse fixpoint. -/
theorem aggPm01Probe_row_fix :
    aggPm01DupRow (aggPm01CollapseRow (aggPm01ProbeQnf (sig := sig)).1) =
      (aggPm01ProbeQnf (sig := sig)).1 := by
  show renameNF (sig := sig) (k := 0) aggPmMerge01 aggPmExpand01
      (renameNF (sig := sig) (k := 0) aggPmExpand01 aggPmMerge01 (fun _ => false)) =
    (fun _ => false)
  rw [aggPm01_renameNF_false aggPmExpand01 aggPmMerge01]
  exact aggPm01_renameNF_false aggPmMerge01 aggPmExpand01

/-- The probe quant layer trivially satisfies the off-fixpoint falsity gate. -/
theorem aggPm01Probe_quant_off :
    ∀ σ : NormalForm sig 0 4, aggPm01DupSub (aggPm01CollapseSub σ) ≠ σ →
      (aggPm01ProbeQnf (sig := sig)).2 σ = false :=
  fun _ _ => rfl

/-- **R9 genericity probe — the (0,1) merge end-to-end for one concrete qnf.** The clause
    iff for the all-false probe qnf: the duplicated-head evaluation at `[x, x, t]` is exactly
    the fixed-anchor arity-2 evaluation of the (0,1) collapse at `[x, t]`, proved through the
    full gated-collapse engine chain at the new rename pair. -/
theorem aggPm01Probe_clause_iff (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    nf_eval_nf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) (aggPm01ProbeQnf (sig := sig)) ↔
      nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggPm01CollapseK1 aggPm01ProbeQnf) :=
  agg_pm01_collapse_k1 M aggPm01ProbeQnf x t aggPm01Probe_row_fix aggPm01Probe_quant_off

/-! ## The (0,1) gate, clause iff, and gated carrier -/

/-- **Per-`qnf` (0,1) point-channel gate** (k=1): qnf's atom row is a (0,1) duplicate-collapse
    fixpoint AND every non-fixpoint arity-4 sub is unmarked — the syntactic condition under
    which the depth-1 evaluation at `[x, x, t]` collapses losslessly to arity 2, and whose
    failure REFUTES the evaluation (`agg_rename_fixpoint_of_eval`). -/
def aggPm01GateK1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (qnf : NormalForm sig 1 3) : Prop :=
  aggPm01DupRow (aggPm01CollapseRow qnf.1) = qnf.1 ∧
  (∀ σ : NormalForm sig 0 4, aggPm01DupSub (aggPm01CollapseSub σ) ≠ σ → qnf.2 σ = false)

/-- **Gate forcing** (the off-gate refutation direction): any realizer of the duplicated-head
    evaluation at `[x, x, t]` forces the (0,1) gate — both the row fixpoint (row-level fixpoint
    engine) and the off-fixpoint quant falsity (lifted fixpoint engine per marked sub). -/
theorem aggPm01_gate_of_eval {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier)
    (hw : nf_eval_nf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) qnf) :
    aggPm01GateK1 qnf := by
  have hwhole : nf_eval_nf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) qnf ↔
      (nf_eval_nf M 0 3 (Fin.cons x (Fin.cons x (fun _ => t)))
          (qnf.1 : NormalForm sig 0 3) ∧
        (∀ σ : NormalForm sig 0 4,
          (∃ v : M.carrier, nf_eval_nf M 0 4
            (Fin.cons v (Fin.cons x (Fin.cons x (fun _ => t)))) σ) ↔
            qnf.2 σ = true)) := Iff.rfl
  rw [hwhole] at hw
  obtain ⟨hatom, hq⟩ := hw
  have hE3 : ∀ i : Fin 3,
      (Fin.cons x (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
        (aggPmExpand01 (aggPmMerge01 i)) =
      (Fin.cons x (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
    intro i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
  refine ⟨?_, ?_⟩
  · exact agg_rename_fixpoint_of_eval M aggPmExpand01 aggPmMerge01 aggPmMerge01_expand01
      (Fin.cons x (Fin.cons x (fun _ => t))) hE3
      (qnf.1 : NormalForm sig 0 3) hatom
  · intro σ hfix
    cases hb : qnf.2 σ with
    | false => rfl
    | true =>
      obtain ⟨v, hv⟩ := (hq σ).mpr hb
      refine absurd ?_ hfix
      show aggPm01DupSub (aggPm01CollapseSub σ) = σ
      refine agg_rename_fixpoint_of_eval M (liftIdx aggPmExpand01)
        (liftIdx aggPmMerge01) aggPm_liftMerge_liftExpand01
        (Fin.cons v (Fin.cons x (Fin.cons x (fun _ => t)))) ?_ σ hv
      intro i
      refine Fin.cases ?_ ?_ i
      · rw [liftIdx_zero, liftIdx_zero]
      · intro j
        rw [liftIdx_succ, liftIdx_succ]
        simp only [Fin.cons_succ]
        exact hE3 j

/-- **The (0,1) point-channel clause iff** (k=1): the duplicated-head evaluation at
    `[x, x, t]` is exactly the gate conjoined with the fixed-anchor collapsed evaluation at
    `[x, t]`. Forward: the gate is forced (`aggPm01_gate_of_eval`) and the collapse applies;
    backward: the collapse applies under the given gate. -/
theorem aggPm01_clause_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) :
    nf_eval_nf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) qnf ↔
      (aggPm01GateK1 qnf ∧
        nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggPm01CollapseK1 qnf)) := by
  constructor
  · intro hw
    have hg := aggPm01_gate_of_eval M qnf x t hw
    exact ⟨hg, (agg_pm01_collapse_k1 M qnf x t hg.1 hg.2).mp hw⟩
  · rintro ⟨hg, h2⟩
    exact (agg_pm01_collapse_k1 M qnf x t hg.1 hg.2).mpr h2

/-- **Per-`qnf` (0,1) point-channel carrier** (k=1): on-gate the fixed-anchor collapsed
    evaluation `nf_eval_nf M 1 2 [x, t] (collapsed qnf)`; off-gate `⊥` — non-fixpoint qnf
    gate to bot exactly as `aggPosDiagK1`. -/
noncomputable def aggPm01ClauseK1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) : Prop :=
  @dite _ (aggPm01GateK1 qnf) (Classical.dec _)
    (fun _ => nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggPm01CollapseK1 qnf))
    (fun _ => False)

/-- **Correctness of the (0,1) point-channel carrier**: the carrier holds exactly when the
    duplicated-head k=1 evaluation holds. On-gate via the gated collapse; off-gate the
    evaluation FORCES the gate (fixpoint engine), refuting it. -/
theorem aggPm01ClauseK1_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) :
    aggPm01ClauseK1 M qnf x t ↔
      nf_eval_nf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) qnf := by
  unfold aggPm01ClauseK1
  by_cases hg : aggPm01GateK1 qnf
  · rw [dif_pos hg]
    exact (agg_pm01_collapse_k1 M qnf x t hg.1 hg.2).symm
  · rw [dif_neg hg]
    constructor
    · intro h
      exact h.elim
    · intro hw
      exact hg (aggPm01_gate_of_eval M qnf x t hw)

/-! ## Fold characterization of the collapsed side (n=2, delivered fold engine) -/

/-- **Fold characterization at n=2**: the fixed-anchor collapsed evaluation re-fibers via the
    delivered depth-1 fold engine (`nf_eval_depth1_fold_iff`, CarrierKv.lean:466) into its
    atom layer plus zone-bounded monadic `(ZoneSpec 2 × NormalForm sig 0 1)` fibers plus the
    off-fiber falsity clause — the exact shape the delivered agg2 kit consumes. -/
theorem aggPm01_fold_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) :
    nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggPm01CollapseK1 qnf) ↔
      ((∀ a : AtomKind sig 2, atom_eval M (Fin.cons x (fun _ => t)) a ↔
          (aggPm01CollapseK1 qnf).1 a = true) ∧
       ((∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
           (∃ v : M.carrier, zoneHolds M (Fin.cons x (fun _ => t)) zs v ∧
             nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             (aggPm01CollapseK1 qnf).2
               (nf0_assemble zs χ (aggPm01CollapseK1 qnf).1) = true) ∧
        (∀ τ : NormalForm sig 0 3, nf0_dropFresh τ ≠ (aggPm01CollapseK1 qnf).1 →
          (aggPm01CollapseK1 qnf).2 τ = false))) :=
  nf_eval_depth1_fold_iff M (Fin.cons x (fun _ => t)) (aggPm01CollapseK1 qnf)

/-- **The (0,1) clause, fully characterized**: gate ∧ fold form — the end-to-end shape
    `duplicated-head k=1 evaluation ↔ gate ∧ (atom layer ∧ zone fibers ∧ off-fiber falsity)`
    that the Phase-16 dispatcher consumes for the `w = x` channel. -/
theorem aggPm01_clause_fold_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) :
    nf_eval_nf M 1 3 (Fin.cons x (Fin.cons x (fun _ => t))) qnf ↔
      (aggPm01GateK1 qnf ∧
        ((∀ a : AtomKind sig 2, atom_eval M (Fin.cons x (fun _ => t)) a ↔
            (aggPm01CollapseK1 qnf).1 a = true) ∧
         ((∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
             (∃ v : M.carrier, zoneHolds M (Fin.cons x (fun _ => t)) zs v ∧
               nf_eval_nf M 0 1 (fun _ => v) χ) ↔
               (aggPm01CollapseK1 qnf).2
                 (nf0_assemble zs χ (aggPm01CollapseK1 qnf).1) = true) ∧
          (∀ τ : NormalForm sig 0 3, nf0_dropFresh τ ≠ (aggPm01CollapseK1 qnf).1 →
            (aggPm01CollapseK1 qnf).2 τ = false)))) :=
  (aggPm01_clause_iff M qnf x t).trans
    (and_congr_right fun _ => aggPm01_fold_iff M qnf x t)

end AggPointMerge01

section AggPointMerge02

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-! ## Point-channel merge variant (0,2) — the `w = t` channel (task 350 Phase 12b)

The (0,2) mirror of the (0,1) machinery above: at the coincident witness `w = t` the
population env `[w, x, t]` becomes `[t, x, t]` with DUPLICATED entries at positions 0, 2,
and the evaluation collapses — under the per-`qnf` syntactic gate — to the SAME fixed-anchor
arity-2 evaluation `nf_eval_nf M 1 2 [x, t] (collapsed qnf)` (anchor order preserved).

Rename pair orientation (12a handoff, binding): collapsed slot 0 = the anchor `x`, slot 1 =
the merged point `w = t`. Expand `Fin 2 → Fin 3` is `0 ↦ 1, 1 ↦ 2`; merge `Fin 3 → Fin 2`
is `0 ↦ 1, 1 ↦ 0, 2 ↦ 1`. R9 is retired: `renameNF`, `renameNF_eval_diag0`, and
`agg_rename_fixpoint_of_eval` are machine-confirmed rename-generic, so no new probe is
required at this position — the general lemmas below instantiate the confirmed engines. -/

/-- Skip embedding `Fin 2 → Fin 3` (`0 ↦ 1`, `1 ↦ 2`): the section of the (0,2) merge. -/
def aggPmExpand02 : Fin 2 → Fin 3 := fun i => if i.val = 0 then ⟨1, by omega⟩ else ⟨2, by omega⟩

/-- Tail merge `Fin 3 → Fin 2` (`0 ↦ 1`, `1 ↦ 0`, `2 ↦ 1`): positions 0, 2 merge. -/
def aggPmMerge02 : Fin 3 → Fin 2 := fun i => if i.val = 1 then ⟨0, by omega⟩ else ⟨1, by omega⟩

/-- `aggPmMerge02 ∘ aggPmExpand02 = id` (the retraction). -/
theorem aggPmMerge02_expand02 : ∀ j : Fin 2, aggPmMerge02 (aggPmExpand02 j) = j := by
  decide

/-- Lifted retraction on `Fin 3`. -/
theorem aggPm_liftMerge_liftExpand02 :
    ∀ j : Fin 3, liftIdx aggPmMerge02 (liftIdx aggPmExpand02 j) = j := by
  intro j
  refine Fin.cases ?_ ?_ j
  · rw [liftIdx_zero, liftIdx_zero]
  · intro i
    rw [liftIdx_succ, liftIdx_succ, aggPmMerge02_expand02]

/-! Concrete-typed rename wrappers (pin `k` and the arities). -/

/-- Collapse an arity-3 depth-0 row to arity 2 (positions 0, 2 merge). -/
def aggPm02CollapseRow {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 3 → NormalForm sig 0 2 :=
  renameNF aggPmExpand02 aggPmMerge02
/-- Duplicate an arity-2 depth-0 row to arity 3 (slot 1 duplicated onto positions 0, 2). -/
def aggPm02DupRow {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 2 → NormalForm sig 0 3 :=
  renameNF aggPmMerge02 aggPmExpand02
/-- Collapse an arity-4 depth-0 sub to arity 3 (positions 1, 3 merge; fresh slot fixed). -/
def aggPm02CollapseSub {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 4 → NormalForm sig 0 3 :=
  renameNF (liftIdx aggPmExpand02) (liftIdx aggPmMerge02)
/-- Duplicate an arity-3 depth-0 sub to arity 4 (slot 2 duplicated; fresh slot fixed). -/
def aggPm02DupSub {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 0 3 → NormalForm sig 0 4 :=
  renameNF (liftIdx aggPmMerge02) (liftIdx aggPmExpand02)
/-- Collapse a depth-1 arity-3 NF to arity 2 (the (0,2) point-channel collapse). -/
def aggPm02CollapseK1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] : NormalForm sig 1 3 → NormalForm sig 1 2 :=
  renameNF aggPmExpand02 aggPmMerge02

/-- **Gated depth-1 (0,2) anchor collapse** (Lemma 3.2(2) coincident-witness collapse at
    `w = t`; the position-(0,2) mirror of `agg_pm01_collapse_k1`). Under the syntactic gate —
    the atom row is a (0,2) duplicate-collapse fixpoint and every non-fixpoint arity-4 sub is
    unmarked — the depth-1 evaluation at the duplicated env `[t, x, t]` is equivalent to the
    depth-1 arity-2 evaluation of the collapsed NF at the fixed anchors `[x, t]`. -/
theorem agg_pm02_collapse_k1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier)
    (hrow : aggPm02DupRow (aggPm02CollapseRow qnf.1) = qnf.1)
    (hquant : ∀ σ : NormalForm sig 0 4, aggPm02DupSub (aggPm02CollapseSub σ) ≠ σ →
      qnf.2 σ = false) :
    nf_eval_nf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) qnf ↔
      nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggPm02CollapseK1 qnf) := by
  set E : Fin 3 → M.carrier := Fin.cons t (Fin.cons x (fun _ => t))
  set e : Fin 2 → M.carrier := Fin.cons x (fun _ => t)
  -- Env compatibilities for the rename bridges.
  have hcomp : ∀ i : Fin 2, e i = E (aggPmExpand02 i) := by
    intro i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
  have hcomp2 : ∀ i : Fin 3, E i = e (aggPmMerge02 i) := by
    intro i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
  -- Row-level rename bridge (under the fixpoint): eval₃ E qnf.1 ↔ eval₂ e (collapse row).
  have hrowbridge : nf_eval_nf M 0 3 E (qnf.1 : NormalForm sig 0 3) ↔
      nf_eval_nf M 0 2 e (aggPm02CollapseRow qnf.1) := by
    conv_lhs => rw [← hrow]
    exact renameNF_eval_diag0 M aggPmExpand02 aggPmMerge02 E e hcomp hcomp2
      aggPmMerge02_expand02 (aggPm02CollapseRow qnf.1)
  -- σ-level rename bridge per inner witness v.
  have hsub : ∀ (v : M.carrier) (τ : NormalForm sig 0 3),
      nf_eval_nf M 0 4 (Fin.cons v E) (aggPm02DupSub τ) ↔
        nf_eval_nf M 0 3 (Fin.cons v e) τ := by
    intro v τ
    exact renameNF_eval_diag0 M (liftIdx aggPmExpand02) (liftIdx aggPmMerge02)
      (Fin.cons v E) (Fin.cons v e)
      (cons_comp_liftIdx aggPmExpand02 E e v hcomp)
      (cons_comp_liftIdx aggPmMerge02 e E v hcomp2)
      aggPm_liftMerge_liftExpand02 τ
  -- Depth-1 defeq unfolds on both sides.
  have hwhole3 : nf_eval_nf M 1 3 E qnf ↔
      (nf_eval_nf M 0 3 E (qnf.1 : NormalForm sig 0 3) ∧
        (∀ σ : NormalForm sig 0 4,
          (∃ v : M.carrier, nf_eval_nf M 0 4 (Fin.cons v E) σ) ↔ qnf.2 σ = true)) :=
    Iff.rfl
  have hwhole2 : nf_eval_nf M 1 2 e (aggPm02CollapseK1 qnf) ↔
      (nf_eval_nf M 0 2 e (aggPm02CollapseRow qnf.1) ∧
        (∀ τ : NormalForm sig 0 3,
          (∃ v : M.carrier, nf_eval_nf M 0 3 (Fin.cons v e) τ) ↔
            qnf.2 (aggPm02DupSub τ) = true)) :=
    Iff.rfl
  rw [hwhole3, hwhole2]
  constructor
  · rintro ⟨hatom, hq⟩
    refine ⟨hrowbridge.mp hatom, fun τ => ?_⟩
    have := hq (aggPm02DupSub τ)
    exact (exists_congr (fun v => (hsub v τ).symm)).trans this
  · rintro ⟨hatom2, hq2⟩
    refine ⟨hrowbridge.mpr hatom2, fun σ => ?_⟩
    by_cases hfix : aggPm02DupSub (aggPm02CollapseSub σ) = σ
    · have hτ := hq2 (aggPm02CollapseSub σ)
      rw [hfix] at hτ
      refine Iff.trans ?_ hτ
      refine exists_congr (fun v => ?_)
      conv_lhs => rw [← hfix]
      exact hsub v (aggPm02CollapseSub σ)
    · constructor
      · rintro ⟨v, hv⟩
        refine absurd ?_ hfix
        show aggPm02DupSub (aggPm02CollapseSub σ) = σ
        refine agg_rename_fixpoint_of_eval M (liftIdx aggPmExpand02)
          (liftIdx aggPmMerge02) aggPm_liftMerge_liftExpand02 (Fin.cons v E) ?_ σ hv
        intro i
        refine Fin.cases ?_ ?_ i
        · rw [liftIdx_zero, liftIdx_zero]
        · intro j
          rw [liftIdx_succ, liftIdx_succ]
          simp only [Fin.cons_succ]
          rw [← hcomp (aggPmMerge02 j), hcomp2 j]
      · intro hbit
        rw [hquant σ hfix] at hbit
        exact Bool.noConfusion hbit

/-! ## The (0,2) gate, clause iff, and gated carrier -/

/-- **Per-`qnf` (0,2) point-channel gate** (k=1): qnf's atom row is a (0,2) duplicate-collapse
    fixpoint AND every non-fixpoint arity-4 sub is unmarked — the syntactic condition under
    which the depth-1 evaluation at `[t, x, t]` collapses losslessly to arity 2, and whose
    failure REFUTES the evaluation (`agg_rename_fixpoint_of_eval`). -/
def aggPm02GateK1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (qnf : NormalForm sig 1 3) : Prop :=
  aggPm02DupRow (aggPm02CollapseRow qnf.1) = qnf.1 ∧
  (∀ σ : NormalForm sig 0 4, aggPm02DupSub (aggPm02CollapseSub σ) ≠ σ → qnf.2 σ = false)

/-- **Gate forcing** (the off-gate refutation direction): any realizer of the duplicated
    evaluation at `[t, x, t]` forces the (0,2) gate — both the row fixpoint (row-level fixpoint
    engine) and the off-fixpoint quant falsity (lifted fixpoint engine per marked sub). -/
theorem aggPm02_gate_of_eval {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier)
    (hw : nf_eval_nf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) qnf) :
    aggPm02GateK1 qnf := by
  have hwhole : nf_eval_nf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) qnf ↔
      (nf_eval_nf M 0 3 (Fin.cons t (Fin.cons x (fun _ => t)))
          (qnf.1 : NormalForm sig 0 3) ∧
        (∀ σ : NormalForm sig 0 4,
          (∃ v : M.carrier, nf_eval_nf M 0 4
            (Fin.cons v (Fin.cons t (Fin.cons x (fun _ => t)))) σ) ↔
            qnf.2 σ = true)) := Iff.rfl
  rw [hwhole] at hw
  obtain ⟨hatom, hq⟩ := hw
  have hE3 : ∀ i : Fin 3,
      (Fin.cons t (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
        (aggPmExpand02 (aggPmMerge02 i)) =
      (Fin.cons t (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
    intro i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
  refine ⟨?_, ?_⟩
  · exact agg_rename_fixpoint_of_eval M aggPmExpand02 aggPmMerge02 aggPmMerge02_expand02
      (Fin.cons t (Fin.cons x (fun _ => t))) hE3
      (qnf.1 : NormalForm sig 0 3) hatom
  · intro σ hfix
    cases hb : qnf.2 σ with
    | false => rfl
    | true =>
      obtain ⟨v, hv⟩ := (hq σ).mpr hb
      refine absurd ?_ hfix
      show aggPm02DupSub (aggPm02CollapseSub σ) = σ
      refine agg_rename_fixpoint_of_eval M (liftIdx aggPmExpand02)
        (liftIdx aggPmMerge02) aggPm_liftMerge_liftExpand02
        (Fin.cons v (Fin.cons t (Fin.cons x (fun _ => t)))) ?_ σ hv
      intro i
      refine Fin.cases ?_ ?_ i
      · rw [liftIdx_zero, liftIdx_zero]
      · intro j
        rw [liftIdx_succ, liftIdx_succ]
        simp only [Fin.cons_succ]
        exact hE3 j

/-- **The (0,2) point-channel clause iff** (k=1): the duplicated evaluation at `[t, x, t]`
    is exactly the gate conjoined with the fixed-anchor collapsed evaluation at `[x, t]`.
    Forward: the gate is forced (`aggPm02_gate_of_eval`) and the collapse applies; backward:
    the collapse applies under the given gate. -/
theorem aggPm02_clause_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) :
    nf_eval_nf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) qnf ↔
      (aggPm02GateK1 qnf ∧
        nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggPm02CollapseK1 qnf)) := by
  constructor
  · intro hw
    have hg := aggPm02_gate_of_eval M qnf x t hw
    exact ⟨hg, (agg_pm02_collapse_k1 M qnf x t hg.1 hg.2).mp hw⟩
  · rintro ⟨hg, h2⟩
    exact (agg_pm02_collapse_k1 M qnf x t hg.1 hg.2).mpr h2

/-- **Per-`qnf` (0,2) point-channel carrier** (k=1): on-gate the fixed-anchor collapsed
    evaluation `nf_eval_nf M 1 2 [x, t] (collapsed qnf)`; off-gate `⊥` — non-fixpoint qnf
    gate to bot exactly as `aggPosDiagK1` / `aggPm01ClauseK1`. -/
noncomputable def aggPm02ClauseK1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) : Prop :=
  @dite _ (aggPm02GateK1 qnf) (Classical.dec _)
    (fun _ => nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggPm02CollapseK1 qnf))
    (fun _ => False)

/-- **Correctness of the (0,2) point-channel carrier**: the carrier holds exactly when the
    duplicated k=1 evaluation at `[t, x, t]` holds. On-gate via the gated collapse; off-gate
    the evaluation FORCES the gate (fixpoint engine), refuting it. -/
theorem aggPm02ClauseK1_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) :
    aggPm02ClauseK1 M qnf x t ↔
      nf_eval_nf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) qnf := by
  unfold aggPm02ClauseK1
  by_cases hg : aggPm02GateK1 qnf
  · rw [dif_pos hg]
    exact (agg_pm02_collapse_k1 M qnf x t hg.1 hg.2).symm
  · rw [dif_neg hg]
    constructor
    · intro h
      exact h.elim
    · intro hw
      exact hg (aggPm02_gate_of_eval M qnf x t hw)

/-! ## Fold characterization of the collapsed side (n=2, delivered fold engine) -/

/-- **Fold characterization at n=2**: the fixed-anchor collapsed evaluation re-fibers via the
    delivered depth-1 fold engine (`nf_eval_depth1_fold_iff`, CarrierKv.lean:466) into its
    atom layer plus zone-bounded monadic `(ZoneSpec 2 × NormalForm sig 0 1)` fibers plus the
    off-fiber falsity clause — the exact shape the delivered agg2 kit consumes. -/
theorem aggPm02_fold_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) :
    nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) (aggPm02CollapseK1 qnf) ↔
      ((∀ a : AtomKind sig 2, atom_eval M (Fin.cons x (fun _ => t)) a ↔
          (aggPm02CollapseK1 qnf).1 a = true) ∧
       ((∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
           (∃ v : M.carrier, zoneHolds M (Fin.cons x (fun _ => t)) zs v ∧
             nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             (aggPm02CollapseK1 qnf).2
               (nf0_assemble zs χ (aggPm02CollapseK1 qnf).1) = true) ∧
        (∀ τ : NormalForm sig 0 3, nf0_dropFresh τ ≠ (aggPm02CollapseK1 qnf).1 →
          (aggPm02CollapseK1 qnf).2 τ = false))) :=
  nf_eval_depth1_fold_iff M (Fin.cons x (fun _ => t)) (aggPm02CollapseK1 qnf)

/-- **The (0,2) clause, fully characterized**: gate ∧ fold form — the end-to-end shape
    `duplicated k=1 evaluation at [t, x, t] ↔ gate ∧ (atom layer ∧ zone fibers ∧ off-fiber
    falsity)` that the Phase-16 dispatcher consumes for the `w = t` channel. -/
theorem aggPm02_clause_fold_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) :
    nf_eval_nf M 1 3 (Fin.cons t (Fin.cons x (fun _ => t))) qnf ↔
      (aggPm02GateK1 qnf ∧
        ((∀ a : AtomKind sig 2, atom_eval M (Fin.cons x (fun _ => t)) a ↔
            (aggPm02CollapseK1 qnf).1 a = true) ∧
         ((∀ (zs : ZoneSpec 2) (χ : NormalForm sig 0 1),
             (∃ v : M.carrier, zoneHolds M (Fin.cons x (fun _ => t)) zs v ∧
               nf_eval_nf M 0 1 (fun _ => v) χ) ↔
               (aggPm02CollapseK1 qnf).2
                 (nf0_assemble zs χ (aggPm02CollapseK1 qnf).1) = true) ∧
          (∀ τ : NormalForm sig 0 3, nf0_dropFresh τ ≠ (aggPm02CollapseK1 qnf).1 →
            (aggPm02CollapseK1 qnf).2 τ = false)))) :=
  (aggPm02_clause_iff M qnf x t).trans
    (and_congr_right fun _ => aggPm02_fold_iff M qnf x t)

end AggPointMerge02

end Bimodal.Metalogic.WeakCanonical.Kamp
