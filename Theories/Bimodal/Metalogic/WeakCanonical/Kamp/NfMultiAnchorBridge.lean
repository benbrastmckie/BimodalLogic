import Bimodal.Metalogic.WeakCanonical.Kamp.NfZoneFlattenNavigable
import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold
import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure
import Mathlib.Data.List.Permutation
-- NOTE (task 309 Phase 13.1): `import ...Kamp.EANegationClosure` lands the import edge
-- authorized by plan v6 (report 05 §d, verified on paper; compile-verified this dispatch).
-- Cycle-free: only KampPrior imports this file, and EANegationClosure's transitive closure
-- (EANegation, VecEAClosure, VecEAFormula, PriorINF, ExistsForallNF, PriorDefs, MonadicFO,
-- Table) reaches neither KampPrior nor this file. It transitively supplies PriorINF
-- (`HasAttainedINF`/`prior_hasAttainedINF`, PriorINF:202/:224) and the Lemma 5.1/Cor 5.4/
-- Prop 4.2 negation-stack assets consumed by Phases 13.2-13.4.
-- NOTE (task 309 Phase 13.0): `import ...WeakCanonical.PriorDefs` supplies
-- `semantic_prior_UZ`/`semantic_prior_SZ` (PriorDefs:22/:33) for the F2 decision-probe verdict
-- record at the bottom of this file. Cycle-free: PriorDefs imports only `...WeakCanonical.Table`
-- (already in this file's transitive closure); nothing in PriorDefs' closure imports this file.
-- NOTE (task 311 Phase 4): `import Mathlib.Data.List.Permutation` supplies
-- `List.mem_permutations` (arrangement-disjunct membership ↔ `List.Perm`), consumed by the
-- soundness direction of the V-carrier. Mathlib-only; no project-file import added.
-- NOTE (task 311 Phase 1): `import ...Kamp.NfEFold` is cycle-free — NfEFold imports only
-- `...WeakCanonical.NormalForm` and `...Kamp.NfDepth0Generalized` (NfEFold.lean:1-2), neither of
-- which imports this file. It supplies the task-310 E[Σ]-fold assets (`efold_of_nf1`,
-- `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate`, the depth-0 split kit) consumed by the
-- k=1 fold carrier `bracketEndChar_k1` below.
-- NOTE (task 307 Phase 7): `import ...KampPrior` was REMOVED to break the import cycle that blocked
-- wiring this bridge into `KampPrior.lean:391`. The two symbols this file used from KampPrior
-- (`nf_quant_clause_tl`/`_correct`, `atomKind_arity1_is_pred`) were relocated to
-- `NfDepth0Generalized` and reach here transitively via `NfZoneFlattenNavigable`.
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierKv
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.RefutationF2
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket2
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket2V

/-!
# Multi-Anchor Characteristic Formula Bridge (task 308)

A new **leaf** file (nothing imports it; it imports nothing beyond
`NfZoneFlattenNavigable` — which transitively pulls `VecEATranslation`,
`NfZoneDepthK`, `NfDepth0Generalized` — and `KampPrior`). It hosts the
sorry-free depth-graded two-anchor characteristic-formula bridge deliverables.

## Deliverables (built across the task-308 phases)
1. `nf_char2_formula : NormalForm sig (k+1) 2 → Formula` (Phase 3).
2. `nf_zone_flatten_navigable` at arbitrary depth `k` (Phase 5).

## This file — Phase 1 (bottom-of-recursion bases)
- `nf_char2_atom_layer`: the **diagonal depth-0 atom-layer** iff — the depth-0
  characteristic formula of an arity-1 NF characterizes the arity-2 evaluation of
  its diagonal value-duplication `diagDup` on the constant env `[t,t]`. Built from
  `nf_depth0_char_formula` + `diagDup_eval_zero` (i.e. `renameNF_eval_diag0`).
- `nf_zone_flatten_navigable_zero`: the `k = 0` base of deliverable 2 — the arity-3
  tail-diagonal existential of a duplicated NF `diagDup3` on `[w,t,t]` equals the
  arity-2 existential on `[w,t]`. Endpoints are atom/anchor types via
  `renameNF_eval_diag0`; **no `bracketBuild*` navigation yet**.

## Postmortem forbidden-route list (BINDING — read before writing any construction)

Every future dispatch on this file MUST check each candidate construction against
these three refuted routes (task-305 Phase-11b lineage + task-307 blocker audit):

- **(a) Do NOT** re-attempt a projection-based VecEA2 bridge for the `x=t` diagonal
  case. `liftIdx(totalUnskip)` is non-injective; the coupled quant layer does not
  factor through per-variable projections. Split the coupled `∃w` **directly** on the
  full env `[w,x,t]` (`exists_nested_split3` / `exists_trichotomy_split`) and discharge
  through `nf_char3_eq_succ_iff`'s joint decomposition — never per-variable projection.
- **(b) Do NOT** re-attempt a flat single-interval atomic bracket absorption. A depth-0
  atomic `BracketFormula` is confined to `[x,t]` and cannot capture exterior-`w`
  realizability. Endpoint types MUST be **navigated** recursive `bracketBuild*`
  `TemporalPred`s, not depth-0 atomic brackets.
- **(c) Do NOT** re-attempt an arity-1-collapse repair for the diagonal arm
  (`char_k1 (diagCollapse sub_nf)`). At depth `k+1` this is the documented **non-theorem**
  (`NfDepth0Generalized.lean:1691-1719`; `liftIdx r` non-injective, `←` fails).

**Settled**: the diagonal collapse (`renameNF_eval_diag0`) is used **only at the depth-0
atom layer**, where it is a proven iff. The depth-`(k+1)` quant layer goes through the
honest arity-3 navigated existential — **never** collapsed to arity 1.

## References
- Rabinovich 2014, "A Proof of Kamp's Theorem", Cor 5.4 (`F_i` chain).
- `specs/308_multi_anchor_char_formula_bridge/plans/01_multi-anchor-bridge-plan.md`
- `specs/308_multi_anchor_char_formula_bridge/reports/01_multi-anchor-bridge-research.md`
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Task 309 Phase 13.2: per-sub enriched successor-depth carrier `bracketEndChar_kvE`

The redesigned successor-depth carrier (report 05 Pillar 2 — finding F1 item 3's "required
behavior"), ADDITIVE alongside `bracketEndChar_kv` (:3667, untouched — it stays as the landed
k ≤ 1 instance and F1 exhibit). The defining change is the **information channel**: every read
of `qnf.2` is **per-sub** — `qnf.2 σ` at an individual `σ : NormalForm sig k 4` — never through
`(ZoneSpec 3 × NormalForm sig k 1)` fiber existentials (the refuted F1 channel, factorization
machine-checked at `bracketEndChar_kv_factors` :3851). Two per-sub features defeat that
factorization:

1. **Per-sub witness slots** (rule N4/N5): the interior-positive enumerations `S_L`/`S_R` list
   positive SUBS `σ` (each `qnf.2 σ = true`, zone `zXW`/`zWT`), one bracket witness slot per
   positive sub — distinct positive subs need distinct realizing points (`nf_eval_nf`'s per-sub
   biconditional plus uniqueness, `nf_eval_unique` NormalForm:245), so per-sub slots encode the
   multiplicity the fiber-existential read collapsed ("one witness per positive pair").
2. **Per-sub joint literals at the right endpoint** (Def 3.1 enriched vocabulary, PDF p.4
   md:61-74): each positive sub `σ` contributes the literal `P.existF 3 σ` to `epR`. Since
   `insertEnv env t` places the anchor at the LAST position (NfDepth0Generalized:42) and the
   quant layer of `nf_eval_nf M (k+1) 3 [w,x,t]` evaluates subs at `Fin.cons u [w,x,t]` =
   `[u,w,x,t]` (fresh at 0, `t` at 3), the fixed endpoint `t` IS the position-3 anchor:
   `temporal_truth M t (P.existF 3 σ) ↔ ∃ e : Fin 3 → M.carrier, nf_eval_nf M k 4 [e0,e1,e2,t] σ`
   (`ExistProviders.correct`, :4856), of which the honest per-sub obligation
   `∃ u, nf_eval_nf M k 4 [u,w,x,t] σ` is the `e = (u,w,x)` instance. These are Rabinovich's
   per-round enriched formulas: Def 3.1's α/β at round k+1 range over the CURRENT vocabulary,
   which after round k includes the previous round's TL-definable content (Cor 5.4's `F_i` are
   TL formulas, PDF p.7 md:154-157) — realized here as provider-built formulas in existing
   `TemporalPred` slots (report 05 F-C: enrichment is a read-channel change, NOT a codomain
   change; codomain stays `VVecEA2`, anchors stay `{x, t}`, G2/G4).

**Vocabulary at depth > 0 is provider-built throughout**: point characteristics are
`charK := P.existF 0` (arity-1 instance of the bundle — `insertEnv (elim0) t = fun _ => t`, so
`P.existF 0 χ` is the depth-`k` unary characteristic of `χ`), witness-slot point types are
`⟨charK (nfk_projFresh σ)⟩` (the fresh channel of Def 4.1, PDF p.5, at depth `k` — :3511),
joint literals are `P.existF 3 σ`. Only the atom-layer endpoint/`w` base types use the depth-0
`nf_depth0_char_formula` (the only self-type `qnf.1` carries syntactically), as in `kv_body`.

**Exclusion-literal design record (this phase's design deliverable, plan v6 Phase 13.2)**:
negative subs contribute NO uniform joint literal. A candidate literal `¬(P.existF 3 σ)` at `t`
for negative `σ` would OVER-exclude: `P.existF 3 σ` existentially rebinds the `w`/`x` positions,
so it can hold at the honest `t` through fake anchors while `σ` is honestly negative — the
uniform-negation gap of report 05 F-D (the EANegationClosure lemmas are model-dependent
existentials and may be consumed only proof-side). Negative-sub content therefore enters the
carrier ONLY through the honest-safe unary exclusions — `hasPos`-guarded segment conjunctions
`segL`/`segR` and the `lit`-biconditional endpoint/`w` families, where `hasPos zs χ` (fiber
occupancy) is COMPUTED from the per-sub positive list (`(posIn zs).any (nfk_projFresh · = χ)`),
not read from `qnf.2` through fibers. The remaining negative-sub obligations are Phase 13.3's
work, discharged proof-side via `prior_hasAttainedINF h_UZ` (PriorINF:224) + the
EANegationClosure stack — exactly the F-D discipline.

**Inner existentials (Lemma 3.4 / G6-as-amended)**: a positive sub's own inner existentials
(its quant layer at depth k-1) ride the provider formula `P.existF 3 σ` — the Phase-14
instantiation of the bundle is precisely the Lemma-3.4 (PDF p.5 md:84-85) flattened TL form in
which each absorbed existential joined the prefix one round earlier. They do not occupy slots
of THIS bracket: the A1 bundle supplies converters at depth `k` only, so slot-level flattening
of depth-(k-1) content is outside the provider scope; witness growth in this bracket is
per-positive-sub (G6-as-amended licenses the growth; the §5 bracket `[α_0,…,α_n](z_0,z_1)`
PDF p.7 md:127-132 is its printed shape).

**A2 discipline (per-sub read + inside-out fold discharge)**: the per-sub correctness
obligations of Phase 13.3/13.4 are discharged INSIDE-OUT — at the k=2 instance each positive
sub's inner layer is depth-0 and unfolds through `nf_eval_depth1_fold_iff` below (which consumes
the general fold engine `nf_quant_layer_fold_iff`, NfEFold:391, itself built on the arity-5
split-kit bijection `nf0_split_assemble`, NfEFold:235); at symbolic k the same layer is
provider-mediated (`P.correct`). NO navigated arity-3/4 characteristic chains, NO third anchor:
`VVecEA2.holds` keeps the two-point signature (VecEAFormula:276), Lemma 3.2(2)'s ≤2-anchor cap
(PDF p.4 md:76-79) remains a TYPE-level invariant.

Citation split (rule N1): the two-fixed-endpoint `(z_0, z_1)` framing is **Lemma 3.2(2) (PDF
p.4) + the §5 bracket notation `[α_0,…,α_n](z_0,z_1)` (PDF p.7)**; **Prop 3.5 (PDF p.5)** is
cited ONLY for the one-free-variable ∃-witness→Until/Since folding mechanism (the Since/Until
literals in `epL`/`epR`). Per rule N2, **Prop 4.3 (PDF p.6)** is cited ONLY for "the residual
is ∨∃∀ over E[Σ] atoms"; the inside-out iteration is the **Def 4.1 p.6 note** read at full
strength (G5 as extended by plan v6: chain steps at k ≥ 2 additionally cite Def 3.1's
enriched-vocabulary reading and Cor 5.4's TL-formula providers). -/

/-- The seven zone specs consistent with the bracket order `x < w < t` over the env
    `[w, x, t]` (Def 3.1 ordering channel, PDF pp.4-5: disjunctions range only over consistent
    order types). Literal list identical to the RHS of `k1v_zone_consistent` (:2065), in the
    order `zPastX, zAtX, zXW, zAtW, zWT, zAtT, zFutT`. Named (rather than a `let`) so the
    Phase-13.2 gate is stateable outside the carrier body. -/
private def kvE_consistent : ZoneSpec 3 → Prop := fun zs =>
  zs = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))) ∨
  zs = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))) ∨
  zs = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
  zs = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))

/-- **Per-sub two-conjunct gate** for the Phase-13.2 carrier: (i) atom-layer off-fiber honesty
    (subs whose atom layer does not restrict to `r` are marked false — the `kv` gate conjunct,
    :3675, unchanged in shape) and (ii) PER-SUB order-conflict falsity (any sub whose own
    atom-layer zone is inconsistent with `x < w < t` is marked false) — the per-sub reading of
    `kv_body`'s fiber-level conjunct (:3637). Both conjuncts read `qnf.2` only at individual
    subs (A2). -/
private def kvE_gate {sig : MonadicSignature} {k : Nat}
    (r : NormalForm sig 0 3) (q : NormalForm sig k 4 → Bool) : Prop :=
  (∀ σ : NormalForm sig k 4,
      nf0_dropFresh (NormalForm.atom_assgn σ) ≠ r → q σ = false) ∧
  (∀ σ : NormalForm sig k 4,
      ¬ kvE_consistent (nf0_zoneSpec (NormalForm.atom_assgn σ)) → q σ = false)

open Classical in
/-- **Per-sub successor body** of the Phase-13.2 enriched carrier (private builder, factored
    per Risk R6 like `bracketFromLists` :1896 / `kv_body` :3581). Fully parametric in the three
    formula providers — `charBase` (depth-0 atom-layer projections), `charK` (depth-`k` unary
    characteristics; instantiated at `P.existF 0`), `exF` (per-sub joint configuration formulas
    anchored at the position-3 point; instantiated at `P.existF 3`) — the atom layer `r`, and
    the quant assignment `q` read PER-SUB. Construction record and citations: see the section
    header above. Structure relative to `kv_body` (:3581): the zone constants, `lit`, endpoint
    base types, `segL`/`segR`/`ptW` shapes and the arrangement disjunction are verbatim; the
    fold-bit parameter `b` is REPLACED by per-sub enumeration (`pos`, `posIn`) with derived
    fiber occupancy `hasPos`, the witness slots are per-SUB (`ptSub`, one slot per positive
    interior sub), and `epR` gains the per-sub joint literals `exF σ`. Gate-failure branch:
    the empty disjunction `⟨[]⟩` (its `holds` is `False`) — Rabinovich's empty disjunction over
    inconsistent order types. -/
private noncomputable def kvE_body {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (exF : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig k 4 → Bool) : VVecEA2 :=
  -- Zone-spec constants relative to env `[w, x, t]` under the bracket order `x < w < t`
  -- (Def 3.1 ordering channel, PDF p.4), verbatim from `kv_body` (:3588-3600).
  let ltz : Bool × Bool := (true, false)
  let eqz : Bool × Bool := (false, false)
  let gtz : Bool × Bool := (false, true)
  let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
    Fin.cons pw (Fin.cons px (fun _ => pt))
  let zPastX := mk3 ltz ltz ltz    -- x_1 < x  (< w < t)
  let zAtX   := mk3 ltz eqz ltz    -- x_1 = x
  let zXW    := mk3 ltz gtz ltz    -- x < x_1 < w
  let zAtW   := mk3 eqz gtz ltz    -- x_1 = w
  let zWT    := mk3 gtz gtz ltz    -- w < x_1 < t
  let zAtT   := mk3 gtz gtz eqz    -- x_1 = t
  let zFutT  := mk3 gtz gtz gtz    -- t < x_1
  -- PER-SUB positive enumeration (A2): the ONLY reads of `q` in the whole body are `q σ`
  -- at individual subs, here and in the gate. No fiber-existential read occurs (F1 item 3).
  let pos : List (NormalForm sig k 4) := Finset.univ.toList.filter (fun σ => q σ)
  let zone : NormalForm sig k 4 → ZoneSpec 3 := fun σ =>
    nf0_zoneSpec (NormalForm.atom_assgn σ)
  let posIn : ZoneSpec 3 → List (NormalForm sig k 4) := fun zs =>
    pos.filter (fun σ => decide (zone σ = zs))
  -- Fiber occupancy DERIVED from the per-sub positive list (honest-safe unary channel for
  -- the exclusion literals — see the exclusion-literal design record in the section header).
  let hasPos : ZoneSpec 3 → NormalForm sig k 1 → Bool := fun zs χ =>
    (posIn zs).any (fun σ => decide (nfk_projFresh σ = χ))
  let allTypes : List (NormalForm sig k 1) := Finset.univ.toList
  -- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5).
  let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
  -- Endpoint base types (the FIXED `z_0 = x`, `z_1 = t`: Lemma 3.2(2) PDF p.4 + §5 bracket
  -- PDF p.7 — rule N1 split).
  let xType : TemporalPred := ⟨charBase (nf_x_proj3 r)⟩
  let tType : TemporalPred := ⟨charBase (nf_t_proj3 r)⟩
  let epL : TemporalPred :=
    ⟨formula_conjList
      (xType.formula
        :: (allTypes.map fun χ => lit (hasPos zPastX χ) (Formula.snce (charK χ) Formula.top))
        ++ (allTypes.map fun χ => lit (hasPos zAtX χ) (charK χ)))⟩
  -- `epR` carries, beyond the `kv_body` unary families, the PER-SUB joint literals `exF σ`
  -- for EVERY positive sub (any zone): `t` is the position-3 `insertEnv` anchor of the
  -- per-sub obligation env `[u, w, x, t]` (Def 3.1 enriched vocabulary, PDF p.4 md:61-74;
  -- Cor 5.4 `F_i`, PDF p.7). Positive subs only — see the exclusion-literal design record.
  let epR : TemporalPred :=
    ⟨formula_conjList
      (tType.formula
        :: (allTypes.map fun χ => lit (hasPos zAtT χ) (charK χ))
        ++ (allTypes.map fun χ => lit (hasPos zFutT χ) (Formula.untl (charK χ) Formula.top))
        ++ (pos.map exF))⟩
  -- Segment types: universal exclusion of the unoccupied interior-zone fibers (honest-safe
  -- unary exclusions; the per-sub negative content is Phase 13.3's proof-side work).
  let segL : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ =>
      if hasPos zXW χ then Formula.top else (charK χ).neg)⟩
  let segR : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ =>
      if hasPos zWT χ then Formula.top else (charK χ).neg)⟩
  -- Witness point type at `w`: depth-0 base type + equality-zone biconditionals ONLY
  -- (rule N4 — no interior chains; interior-positive content rides the witness slots below).
  let ptW : TemporalPred :=
    ⟨formula_conjList
      (charBase (nf_y_proj r)
        :: (allTypes.map fun χ => lit (hasPos zAtW χ) (charK χ)))⟩
  -- PER-SUB witness slot point type: the depth-`k` unary characteristic of the sub's fresh
  -- channel (Def 4.1 E[Σ]-atom at depth `k`, PDF p.5; `nfk_projFresh` :3511). The sub's
  -- JOINT content rides its `epR` literal `exF σ`.
  let ptSub : NormalForm sig k 4 → TemporalPred := fun σ => ⟨charK (nfk_projFresh σ)⟩
  -- Interior-positive enumerations: per-SUB (one witness slot per positive interior sub —
  -- distinct positive subs require distinct realizing points, `nf_eval_unique`).
  let S_L : List (NormalForm sig k 4) := posIn zXW
  let S_R : List (NormalForm sig k 4) := posIn zWT
  -- One disjunct per arrangement (rule N5): positive interior subs occupy WITNESS slots
  -- ordered between the fixed endpoints (§5 bracket, PDF p.7; Lemma 3.4, PDF p.5); the
  -- model-dependent witness ORDER is carried by the finite disjunction over arrangements.
  let mkDisjunct : List (NormalForm sig k 4) → List (NormalForm sig k 4) → Σ n, VecEA2 n :=
    fun lL lR =>
      ⟨(lL.map ptSub).length + 1 + (lR.map ptSub).length,
        { endpointLeft := epL
          endpointRight := epR
          bracket := bracketFromLists (lL.map ptSub) ptW (lR.map ptSub) segL segR }⟩
  @dite _ (kvE_gate r q) (Classical.dec _)
    (fun _ =>
      { disjuncts :=
          S_L.permutations.flatMap fun lL =>
            S_R.permutations.map fun lR => mkDisjunct lL lR })
    (fun _ => { disjuncts := [] })

/-- Gate-failure computation for the per-sub body: if the gate fails, the body returns the
    empty disjunction (Rabinovich's empty disjunction over inconsistent order types) — the
    `kv_body_gate_fail` (:3697) mirror for Phase 13.3's off-gate branch. -/
private theorem kvE_body_gate_fail {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (exF : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig k 4 → Bool)
    (h : ¬ kvE_gate r q) :
    kvE_body charBase charK exF r q = { disjuncts := [] } := by
  simp only [kvE_body]
  exact dif_neg h

/-- **The per-sub enriched successor-depth V-carrier** (task 309 Phase 13.2; report 05
    Pillar 2). See the section header above for the full construction record, the A2 per-sub
    read discipline, the N1/N2 citation splits, the Def 3.1 enriched-vocabulary reading
    (PDF p.4 md:61-74), and the exclusion-literal design record. Depth alignment (report 05
    Pillar 3 note): the carrier needed at depth `k` is this definition at `k = j + 1` with
    providers at depth `j = k - 1`; depth 0 stays `bracketEndChar_k0` (:1580) and depth 1
    stays the landed k1v instance (:1940) — this definition serves k ≥ 2. Correctness
    (`BracketCarrierCorrectVPrior` applied to it — provider-conditional in exactly the A1
    sense, :4875) is Phase 13.3 (k = 2 GO/NO-GO gate) and Phase 13.4 (symbolic k). -/
noncomputable def bracketEndChar_kvE {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat} (P : ExistProviders sig atomMap k) :
    BracketEndCharCarrierV sig (k + 1) :=
  fun qnf =>
    kvE_body (nf_depth0_char_formula atomMap h_surj)
      (fun χ => P.existF 0 χ) (fun σ => P.existF 3 σ) qnf.1 qnf.2

/-- **Concrete k=2 instance bridge** (task 309 Phase 13.2 deliverable): at depth-1 providers
    (`P : ExistProviders sig atomMap 1` — the k=2 carrier `BracketEndCharCarrierV sig 2`), the
    carrier is DEFINITIONALLY the per-sub body at `charBase = nf_depth0_char_formula`,
    `charK = P.existF 0`, `exF = P.existF 3`, atom layer `qnf.1`, and the per-sub read of
    `qnf.2` over `σ : NormalForm sig 1 4`. Pure `rfl` — no semantics (the
    `bracketEndChar_k1v_eq_kv_body` :3684 house pattern). Phase 13.3 rewrites with this to
    expose the body, then discharges each positive sub's obligation inside-out via
    `nf_eval_depth1_fold_iff` below (A2). -/
theorem bracketEndChar_kvE_two_eq {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3) :
    bracketEndChar_kvE atomMap h_surj P qnf =
      kvE_body (nf_depth0_char_formula atomMap h_surj)
        (fun χ => P.existF 0 χ) (fun σ => P.existF 3 σ) qnf.1 qnf.2 := rfl

/-! ## Task 309 Phase 13.3: k=2 correctness gate for `bracketEndChar_kvE` —
DECISION GATE → **NO-GO (exclusion-content encoding — the F-D gap materializes)**
(verdict-mirror of the R2 GO record :3407-3445 and the F1/F2 defect records)

**Lead evidence (Def 3.1, PDF p.4 md:61-74 — rule N3).** In Rabinovich's exists-forall
formulas, EVERY existentially chosen point is pinned by the bracket's own interval
decomposition: it sits between the two fixed endpoints `(z_0, z_1)` with its point type
`α_j` AND the interval types `β_j`, `β_{j+1}` on BOTH adjacent sub-intervals — the joint
content of each chosen point relative to the anchors is carried by the decomposition
itself. The kvE per-sub joint literal `P.existF 3 σ` (the 13.2 enrichment channel) instead
pins σ's joint claim ONLY at the right endpoint `t`: `insertEnv` places the provider anchor
LAST, and the provider's `∃ env : Fin 3 → M.carrier` existentially REBINDS the u/w/x
positions. Def 3.1 never produces this configuration. In the paper, per-round joint and
negative content at round k+1 is carried by **Prop 4.2 (PDF p.6 md:100-101)** uniform
negation-closure formulas — built by **Lemma 5.1 (md:134-135)** via **Lemma 5.3's INF
splitting (md:137-152)** — which are CARRIER-SIDE finite disjunctions (Cor 5.4's `F_i` are
TL formulas, md:154-157), not per-model facts.

**Machine probe (soundness direction, k=2 instance).** The probe drove
`(bracketEndChar_kvE atomMap h_surj P qnf).holds M atomMap x t` through
`bracketEndChar_kvE_two_eq` (:5167), the arrangement destructuring, and
`k1v_bracket_extract` (:2150) to the per-sub positive obligation, extracted the joint
literal from `epR`, and applied `P.correct 3 σ M h_UZ h_SZ t`. Captured crux goal state:

    e : Fin 3 → M.carrier
    he : nf_eval_nf M 1 (3 + 1) (insertEnv e t) σ
    ⊢ ∃ x_1, nf_eval_nf M 1 (3 + 1) (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t))) σ

Every other hypothesis in context (`hepL`/`hepR`/`hptWe`/`hLwit`/`hRwit`/`hLgap`/`hRgap`)
carries fresh-channel UNARY content only (`P.existF 0` families over `nfk_projFresh`).
Attempted transfers (lean_multi_attempt): `exact ⟨e 0, he⟩` — type mismatch
`insertEnv e t ≠ Fin.cons (e 0) [w,x,t]`; `simpa [insertEnv, Fin.cons]` — same mismatch;
the funext bridge leaves residuals `e 1 = w` and `e 2 = x` with NO hypothesis relating the
provider-chosen `e` to the honest anchors. The proof-side negation stack
(`prior_hasAttainedINF` PriorINF:224 + `neg_interval_formula` EANegationClosure:401,
`neg_bounded_exists` :492, `neg_vecEA2`/`neg_2var_vec_ea` :646/:720,
`neg_orderedPointsExist_is_vbracket` EANegation:347) cannot connect: each concludes a
model-dependent `∃ v : VBracketFormula/VVecEA2, v.holds M atomMap z0 z1` with no link to
the FIXED σ's realization — exactly the report 05 F-D caveat (model-dependent existentials,
carrier fixed before `M`).

**Counterexample (defect bar, four elements — the statement is FALSE, not merely hard).**
Take `M = ℤ` (Prior UZ/SZ: every nonempty subset of ℤ bounded below/above has a
min/max, so ALL first/last occurrences are attained), preds `p = {0}`, `r = {13}`;
`x = 10`, `t = 20`. Write `char e := nf_characteristic M 1 4 e` and let
`c_u := char [u, 15, 10, 20]` (the honest w=15 subs). Set `qnf.1 := ` depth-0 layer of
`[15, 10, 20]`, and `qnf.2 := ` the honest w=15 assignment EXCEPT
`qnf.2 (c 14) := false` and `qnf.2 σ'' := true` where `σ'' := char [14, 16, 11, 20]`
(a fake-anchored tuple sharing only `t`; on-fiber: depth-0 layer of `[16, 11, 20]` =
depth-0 layer of `[15, 10, 20]`; zone `zXW`; fresh depth-1 type = type(14) = type(15)).
LHS HOLDS at `(10, 20)`: middle witness 15; slots for
`S_L = {c 11, c 12, c 13, σ''}` at 11, 12, 13, 14 (fresh types τ_c, τ_c, τ_b, τ_a);
`σ''`'s joint literal holds at 20 via its fake realization `[14, 16, 11, 20]`; every unary
family is honest. RHS FAILS for every `w' ∈ (10, 20)`: `w' ≤ 13` kill the zAtW sub
(`(10, w')` lacks `r`); `w' = 14` kills `c 12` (no τ_c-fresh `u` gives `(u, 14)` both an
`r`-point and a non-`r` point); `w' = 15` kills `σ''` (`(10, u) ∋ r` forces `u = 14`, but
`(14, 15) = ∅` against σ''s nonempty middle interval); `w' ∈ {16, 17, 18}` realize the
`c 14`-form at `u = w' − 1` against `qnf.2 (c 14) = false`; `w' = 19` kills the zAtW sub
(`(19, 20) = ∅`). **Current behavior**: the carrier's only per-sub joint channel is the
`t`-anchored provider literal; a dishonest positive sub is carrier-indistinguishable from
honest content (same depth-0 fiber, zone, fresh type, and `t`-anchored joint truth).
**Required behavior**: per-sub joint claims pinned against the honest anchor pair — in
Rabinovich, by Prop 4.2's uniform negation/exclusion disjunctions at round k+1.
**Isolation**: the gap is confined to the exclusion/joint-pinning channel deliberately
deferred by the 13.2 exclusion-literal design record (:4956-4967); no new obstruction in
the 13.2 body arises (gate, zones, slots, unary families, and arrangement machinery all
behaved exactly as at k=1); the counterexample is provider-independent (only `P.correct`
is consumed), so the failure survives ANY correct depth-1 bundle, including Phase 14's.

**Verdict: 13.3 = NO-GO, exclusion-content encoding.** The named fallback of plan v6
applies: `/revise 309` (v7) inserting **Phase 13.2b — uniformization**: construct the
needed uniform per-sub exclusion/pinning formulas as FINITE DISJUNCTIONS over the
finitely-generated candidate family (subs, arrangements, point-type sets are all finite at
each depth — report 05 §c contingency; the carrier-side realization of Lemma 5.3/5.1 +
Prop 4.2 per the G5 v6 extension), then re-run this gate ONCE. KD3 discipline held: the
13.2 carrier and the 13.1 predicate are UNCHANGED (this record is the phase's only
artifact — no partial theorem, no sorry); escalation fence C3 held: no anchor growth;
the uniform-backward EANegation sorries (:1090/:1249) were NOT touched. -/

/-! ## Task 309 Phase 13.25: Uniformization — finite-disjunction pinning/exclusion channels
    + carrier extension `bracketEndChar_kvE'` (the v6-named "Phase 13.2b")

**F3 response (channel-(i)/(ii) plan).** The 13.3 gate returned NO-GO: the per-sub joint literal
`P.existF 3 σ` anchors σ's joint claim ONLY at `t` (the `insertEnv` last position), with the
`u/w/x` positions existentially REBOUND, so the crux residuals `e 1 = w`, `e 2 = x` are
unpinnable; the provider-independent `M = ℤ` counterexample shows the gap hits POSITIVE subs
(joint pinning) as well as negative subs (exclusion). This section realizes plan v6's named
fallback — the CARRIER-SIDE uniformization — as finite disjunctions over the finitely-generated
candidate family (subs, arrangements, point-type sets are all finite at each depth via `Fintype
(NormalForm sig k n)`, NormalForm:167; report 05 §c). Two channels:

  - **(i) Positive-sub joint PINNING** (`kvE_pinArrangements`/`kvE_pinDisjunct`): σ's witness `u`
    appears as EXTRA bracket witness slots pinned by the bracket's own interval decomposition
    (Def 3.1, PDF p.4 md:61-74 — every existentially chosen point carries its point type `α_j`
    and the interval types `β_j`, `β_{j+1}` on both adjacent sub-intervals), disjoined over the
    finite candidate family of consistent order-type placements (`kvE_consistentZones`). Each
    disjunct realizes σ's fresh depth-`k` type positionally within the honest bracket (Lemma 5.3
    INF splitting, md:137-152, per disjunct — N1 split), replacing the refuted single-anchor
    `t`-rebound. Carrier-side, not provider-side (v7 Amendment F3): a single-anchor provider
    literal cannot express the relative-position claims tying σ's realization to the bracket's
    own structural points, and the outer recursion supplies single-anchor converters only (F-A),
    so a strengthened bundle would be circular with the two-anchor characteristic under
    construction. This is Rabinovich's own device (Def 3.1 pins chosen points through the
    interval decomposition; Prop 4.2/Lemma 5.1/5.3 place per-round content carrier-side as finite
    disjunctions, Cor 5.4's `F_i` being TL formulas, md:154-157).

  - **(ii) Negative-sub EXCLUSION** (`kvE_exclConj`): for each interior sub the carrier marks
    false, the negation of the finite disjunction of that sub's realization patterns over the
    same candidate family (Lemma 5.1 bracket negation md:134-135 + Prop 4.2 negation closure
    md:100-101, carrier-side), guarded honest-safe by fiber occupancy (`hasPos`) exactly as the
    13.2 unary segment exclusions (:5089-5096) — an honest realization always has a witnessing
    positive sub in the fiber, so the guard leaves it `⊤`.

**Additivity (KD3).** All 13.2 deliverables are retained BYTE-IDENTICAL: `kvE_consistent`
(:5000), `kvE_gate` (:5015), `kvE_body` (:5036 — the structural template, copied here verbatim
and EXTENDED, never edited), `kvE_body_gate_fail` (:5130), `bracketEndChar_kvE` (:5150),
`bracketEndChar_kvE_two_eq` (:5167). The `ExistProviders`/`BracketCarrierCorrectVPrior` predicate
is UNCHANGED (13.1, KD3). `bracketEndChar_kvE'` is a NEW carrier alongside the landed one.

**Non-consumption statement (blocker criterion).** This construction derives uniformity from the
FINITENESS of the candidate family (report 05 §c), NOT from the uniform-backward negation lemmas:
it consumes NEITHER `EANegation :1090` NOR `:1249`, and no definition below references them. Nor
does it read `qnf.2` fiber-existentially (F1): every read is `q σ` at an individual sub. Anchors
stay the two FIXED endpoints `{x, t}` (`VVecEA2`/two-point `VVecEA2.holds`, G4/G6); the pin
placements are WITNESSES between them, never a third anchor (G2). Guards enforced: G2, G4,
G6-as-amended, A1, A2, v7 Amendment F3, N1, N4, N5.

**Correctness scope.** This is the CONSTRUCTION phase; the soundness/completeness direction of
the extended carrier is Phase 13.35's GO/NO-GO gate. The construction is well-typed, additive,
finite, per-sub, sorry-free; whether the channel content is SUFFICIENT for the k=2 soundness
direction is 13.35's machine determination (the primary 13.35 risk, flagged in the handoff). -/

/-- **Pin arrangement** (channel (i), task 309 Phase 13.25): one pinned placement of a positive
    interior sub against the honest anchor triple `(w, x, t)`. `witnessZone` is the order type of
    the sub's witness `u` relative to `(w, x, t)` (one of the seven consistent Def-3.1 order
    types, `kvE_consistentZones`); `witnessType` is the depth-`k` point type carried by the
    witness slot. Finitely enumerable by construction: both fields range over finite index sets
    (the explicit `kvE_consistentZones` list; `NormalForm sig k 1` is a `Fintype`, NormalForm:167
    — report 05 §c). -/
private structure kvE_PinArrangement (sig : MonadicSignature) (k : Nat) where
  witnessZone : ZoneSpec 3
  witnessType : NormalForm sig k 1

/-- The seven consistent order-type placements of a witness `u` relative to `(w, x, t)` under the
    bracket order `x < w < t` (Def 3.1 ordering channel, PDF pp.4-5; the disjuncts of
    `kvE_consistent` :5000 in list form). Explicit `List` — finite by construction (no `Fintype`
    machinery on the carrier path). -/
private def kvE_consistentZones : List (ZoneSpec 3) :=
  let ltz : Bool × Bool := (true, false)
  let eqz : Bool × Bool := (false, false)
  let gtz : Bool × Bool := (false, true)
  let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
    Fin.cons pw (Fin.cons px (fun _ => pt))
  [mk3 ltz ltz ltz, mk3 ltz eqz ltz, mk3 ltz gtz ltz, mk3 eqz gtz ltz,
   mk3 gtz gtz ltz, mk3 gtz gtz eqz, mk3 gtz gtz gtz]

/-- Computable enumeration of pin arrangements for a sub `σ` (channel (i)): σ's fresh depth-`k`
    type (`nfk_projFresh σ`, :3511 — the honest witness type read parametrically from σ, no
    `σ.2` destructuring) placed at each of the finitely many consistent order-type zones. Explicit
    `List` builder (`map` over `kvE_consistentZones`) — the N5 finite disjunction over
    arrangements; the honest disjunct is the one at `nf0_zoneSpec (NormalForm.atom_assgn σ)`. -/
private noncomputable def kvE_pinArrangements {sig : MonadicSignature} {k : Nat}
    (σ : NormalForm sig k 4) : List (kvE_PinArrangement sig k) :=
  kvE_consistentZones.map (fun z => ⟨z, nfk_projFresh σ⟩)

/-- **Per-arrangement pin content** (channel (i)): the EXTRA bracket witness slot (point type)
    and the interval-type segment conjunct realizing σ's fresh-type claim positionally within the
    honest bracket for pin arrangement `a` (Def 3.1 md:61-74 + Lemma 5.3 md:137-152 per disjunct,
    N1 split). Returns `(pointSlots, segConjuncts)`: `pointSlots` splice into the bracket witness
    list; `segConjuncts` are the adjacent interval-type predicates. Instantiated at the k=2 gate
    with `charBase = nf_depth0_char_formula …`, `charK = P.existF 0` — no new provider. -/
private noncomputable def kvE_pinDisjunct {sig : MonadicSignature} {k : Nat}
    (_charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (_σ : NormalForm sig k 4)
    (a : kvE_PinArrangement sig k) : List TemporalPred × List TemporalPred :=
  ([⟨charK a.witnessType⟩], [⟨charK a.witnessType⟩])

/-- **Uniform exclusion formula** for a sub `σ` the carrier marks false (channel (ii)): the
    negation of the finite disjunction of σ's realization patterns over the candidate family
    `kvE_pinArrangements σ` (Lemma 5.1 md:134-135 + Prop 4.2 md:100-101, carrier-side). Read at
    a bracket segment; conjoined honest-safe (guarded by fiber occupancy on insertion, see
    `kvE'_body`). Consumes neither EANegation :1090 nor :1249 (finiteness, not uniform-backward
    negation). -/
private noncomputable def kvE_exclConj {sig : MonadicSignature} {k : Nat}
    (_charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (σ : NormalForm sig k 4) : Formula :=
  Formula.neg (Bimodal.Metalogic.WeakCanonical.Separation.formula_disjList
    ((kvE_pinArrangements σ).map (fun a => charK a.witnessType)))

open Classical in
/-- **Per-sub enriched successor body with uniformization channels** (task 309 Phase 13.25 —
    the additive extension of `kvE_body` :5036). Structure IS `kvE_body` verbatim (zone constants,
    gate, `pos`/`posIn`/`hasPos`, `epL`, `ptW`, `ptSub`, the arrangement disjunction) with two
    ADDITIONS: (1) channel (i) — per positive interior sub, `kvE_pinDisjunct` point slots spliced
    into the witness lists via `kvE_pinArrangements` (extra bracket witnesses, N5 finite
    disjunction, larger index); (2) channel (ii) — `kvE_exclConj` conjuncts for the marked-false
    interior subs conjoined honest-safe into `segL`/`segR`. ALL 13.2 channels (gate, unary
    families, the `t`-anchored `exF σ`, per-sub `ptSub` slots) are retained verbatim. Parametric
    in `k` (never depth-baked); the gate-failure branch is the empty disjunction. See the section
    header for the full construction record and citations. -/
private noncomputable def kvE'_body {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (exF : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig k 4 → Bool) : VVecEA2 :=
  let ltz : Bool × Bool := (true, false)
  let eqz : Bool × Bool := (false, false)
  let gtz : Bool × Bool := (false, true)
  let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
    Fin.cons pw (Fin.cons px (fun _ => pt))
  let zPastX := mk3 ltz ltz ltz
  let zAtX   := mk3 ltz eqz ltz
  let zXW    := mk3 ltz gtz ltz
  let zAtW   := mk3 eqz gtz ltz
  let zWT    := mk3 gtz gtz ltz
  let zAtT   := mk3 gtz gtz eqz
  let zFutT  := mk3 gtz gtz gtz
  let pos : List (NormalForm sig k 4) := Finset.univ.toList.filter (fun σ => q σ)
  -- Interior subs the carrier marks false (channel (ii) domain): NOT in `pos`, per-sub read.
  let neg : List (NormalForm sig k 4) := Finset.univ.toList.filter (fun σ => !q σ)
  let zone : NormalForm sig k 4 → ZoneSpec 3 := fun σ =>
    nf0_zoneSpec (NormalForm.atom_assgn σ)
  let posIn : ZoneSpec 3 → List (NormalForm sig k 4) := fun zs =>
    pos.filter (fun σ => decide (zone σ = zs))
  let negIn : ZoneSpec 3 → List (NormalForm sig k 4) := fun zs =>
    neg.filter (fun σ => decide (zone σ = zs))
  let hasPos : ZoneSpec 3 → NormalForm sig k 1 → Bool := fun zs χ =>
    (posIn zs).any (fun σ => decide (nfk_projFresh σ = χ))
  let allTypes : List (NormalForm sig k 1) := Finset.univ.toList
  let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
  let xType : TemporalPred := ⟨charBase (nf_x_proj3 r)⟩
  let tType : TemporalPred := ⟨charBase (nf_t_proj3 r)⟩
  let epL : TemporalPred :=
    ⟨formula_conjList
      (xType.formula
        :: (allTypes.map fun χ => lit (hasPos zPastX χ) (Formula.snce (charK χ) Formula.top))
        ++ (allTypes.map fun χ => lit (hasPos zAtX χ) (charK χ)))⟩
  let epR : TemporalPred :=
    ⟨formula_conjList
      (tType.formula
        :: (allTypes.map fun χ => lit (hasPos zAtT χ) (charK χ))
        ++ (allTypes.map fun χ => lit (hasPos zFutT χ) (Formula.untl (charK χ) Formula.top))
        ++ (pos.map exF))⟩
  -- Channel (ii) exclusion conjunct at an interior zone `zs`: negate each marked-false sub's
  -- realization patterns, guarded honest-safe by fiber occupancy (`hasPos`) exactly as the 13.2
  -- unary exclusions — an occupied fiber leaves the conjunct `⊤`, so honest realizations survive.
  let exclAt : ZoneSpec 3 → List Formula := fun zs =>
    (negIn zs).map fun σ =>
      if hasPos zs (nfk_projFresh σ) then Formula.top else kvE_exclConj charBase charK σ
  let segL : TemporalPred :=
    ⟨formula_conjList
      ((allTypes.map fun χ =>
        if hasPos zXW χ then Formula.top else (charK χ).neg) ++ exclAt zXW)⟩
  let segR : TemporalPred :=
    ⟨formula_conjList
      ((allTypes.map fun χ =>
        if hasPos zWT χ then Formula.top else (charK χ).neg) ++ exclAt zWT)⟩
  let ptW : TemporalPred :=
    ⟨formula_conjList
      (charBase (nf_y_proj r)
        :: (allTypes.map fun χ => lit (hasPos zAtW χ) (charK χ)))⟩
  let ptSub : NormalForm sig k 4 → TemporalPred := fun σ => ⟨charK (nfk_projFresh σ)⟩
  -- Channel (i): per positive interior sub, the EXTRA pin witness slots (point types) from the
  -- finite family of arrangements (`kvE_pinArrangements` → `kvE_pinDisjunct` point component),
  -- appended alongside the sub's own `ptSub` slot (§5 bracket witnesses between the fixed
  -- endpoints — Def 3.1 md:61-74). The finite disjunction over arrangements rides the flattened
  -- witness list; the honest arrangement is the one at `zone σ`.
  let pinSlots : NormalForm sig k 4 → List TemporalPred := fun σ =>
    (kvE_pinArrangements σ).flatMap (fun a => (kvE_pinDisjunct charBase charK σ a).1)
  let slotsFor : List (NormalForm sig k 4) → List TemporalPred := fun l =>
    l.flatMap (fun σ => ptSub σ :: pinSlots σ)
  let S_L : List (NormalForm sig k 4) := posIn zXW
  let S_R : List (NormalForm sig k 4) := posIn zWT
  let mkDisjunct : List (NormalForm sig k 4) → List (NormalForm sig k 4) → Σ n, VecEA2 n :=
    fun lL lR =>
      ⟨(slotsFor lL).length + 1 + (slotsFor lR).length,
        { endpointLeft := epL
          endpointRight := epR
          bracket := bracketFromLists (slotsFor lL) ptW (slotsFor lR) segL segR }⟩
  @dite _ (kvE_gate r q) (Classical.dec _)
    (fun _ =>
      { disjuncts :=
          S_L.permutations.flatMap fun lL =>
            S_R.permutations.map fun lR => mkDisjunct lL lR })
    (fun _ => { disjuncts := [] })

/-- Gate-failure computation for the enriched body (the `kvE_body_gate_fail` :5130 mirror): if
    the gate fails, the enriched body is the empty disjunction. -/
private theorem kvE'_body_gate_fail {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (exF : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig k 4 → Bool)
    (h : ¬ kvE_gate r q) :
    kvE'_body charBase charK exF r q = { disjuncts := [] } := by
  simp only [kvE'_body]
  exact dif_neg h

/-- **The uniformized per-sub enriched successor-depth V-carrier** (task 309 Phase 13.25; the
    v6-named "Phase 13.2b"). Additive alongside `bracketEndChar_kvE` (:5150 — UNCHANGED): same
    instantiation pattern (`charBase = nf_depth0_char_formula`, `charK = P.existF 0`,
    `exF = P.existF 3`), with the two uniformization channels folded into `kvE'_body`. Serves
    k ≥ 2; correctness (`BracketCarrierCorrectVPrior` applied to it) is Phase 13.35's gate. -/
noncomputable def bracketEndChar_kvE' {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat} (P : ExistProviders sig atomMap k) :
    BracketEndCharCarrierV sig (k + 1) :=
  fun qnf =>
    kvE'_body (nf_depth0_char_formula atomMap h_surj)
      (fun χ => P.existF 0 χ) (fun σ => P.existF 3 σ) qnf.1 qnf.2

/-- **Concrete k=2 instance bridge** (task 309 Phase 13.25 deliverable; the `bracketEndChar_kvE_two_eq`
    :5167 mirror): at depth-1 providers the uniformized carrier is DEFINITIONALLY the enriched body
    at the standard instantiation. Pure `rfl`. Phase 13.35 rewrites with this to expose the enriched
    body. -/
theorem bracketEndChar_kvE'_two_eq {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3) :
    bracketEndChar_kvE' atomMap h_surj P qnf =
      kvE'_body (nf_depth0_char_formula atomMap h_surj)
        (fun χ => P.existF 0 χ) (fun σ => P.existF 3 σ) qnf.1 qnf.2 := rfl

/-! ## Task 309 Phase 13.35: k=2 correctness gate RE-RUN for `bracketEndChar_kvE'` —
DECISION GATE → **NO-GO (carrier-shape defect — the 13.25 channels do not carry the
discriminating per-sub joint content; finding F4)** (the single, LAST gate re-run; verdict-mirror
of the R2 GO record :3407-3445 and the F1/F2/F3 defect records; no partial theorem, no sorry).

**Lead evidence (Def 3.1, PDF p.4 md:61-74 — rule N3).** In Rabinovich's exists-forall formulas,
EVERY existentially chosen point is pinned by the bracket's own interval decomposition: it carries
its point type `α_j` AND the adjacent interval types `β_j`, `β_{j+1}` on BOTH sub-intervals
relative to the fixed endpoints. The 13.25 channel (i) `kvE_pinDisjunct` (:5374) was designed to
realize this positionally (§ header md:5368-5373: "the EXTRA bracket witness slot … and the
interval-type segment conjunct realizing σ's fresh-type claim positionally within the honest
bracket … per disjunct"). As LANDED it does NOT: it returns `([⟨charK a.witnessType⟩],
[⟨charK a.witnessType⟩])` with `a.witnessType = nfk_projFresh σ` (set in `kvE_pinArrangements`
:5364) and the placement field `a.witnessZone` DISCARDED. The pin content is therefore a function
of `nfk_projFresh σ` (the σ.1-level fresh depth-`k` type) ALONE — positionally vacuous.

**Machine probe A (channel (i) collapse — `rfl`-confirmed).** The identity
`(kvE_pinArrangements σ).map (fun a => kvE_pinDisjunct charBase charK σ a)
  = kvE_consistentZones.map (fun _ => ([⟨charK (nfk_projFresh σ)⟩], [⟨charK (nfk_projFresh σ)⟩]))`
closes by `rfl` (captured reduced state:
`(fun a ↦ ([⟨charK a.witnessType⟩], …)) ∘ (fun z ↦ {witnessZone := z, witnessType := nfk_projFresh σ})`
= `fun _ ↦ ([⟨charK (nfk_projFresh σ)⟩], …)`). Every one of the seven consistent-zone pin disjuncts
for `σ` yields the IDENTICAL formula `charK (nfk_projFresh σ)`. Consequence: two subs with equal
`nfk_projFresh` — e.g. F3's dishonest `σ'' = char [14,16,11,20]` and the honest `char [14,15,10,20]`
(fresh type `type(14) = type(15)`) — get BYTE-IDENTICAL channel-(i) content; the channel cannot
distinguish them.

**Machine probe B (the per-sub positive soundness crux persists — captured type-mismatch states).**
The extended carrier's `epR` retains the `t`-anchored provider literals `pos.map exF`
(`exF = P.existF 3`, :5448 — kept verbatim from 13.2). Driving the soundness direction to the
per-sub positive obligation and applying `P.correct 3 σ M h_UZ h_SZ t` gives
`he : nf_eval_nf M 1 (3+1) (insertEnv e t) σ` (`ExistProviders.correct` :4856:
`insertEnv e t = [e 0, e 1, e 2, t]`, anchor LAST, the `u/w/x` positions existentially REBOUND by
`e : Fin 3 → M.carrier`), while the goal needs the honest env
`Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t)) = [x_1, w, x, t]`. Captured probe states:
`exact ⟨e 0, he⟩` → "he has type `nf_eval_nf M 1 (3+1) (insertEnv e t) σ` but is expected to have
type `nf_eval_nf M 1 (3+1) (Fin.cons (e 0) (Fin.cons w (Fin.cons x fun x ↦ t))) σ`"; the funext
bridge reduces to the residual point equations `w = e 1`, `x = e 2` with NO hypothesis relating the
provider-chosen `e` to the honest anchors. Channel (i)'s actual deliverable after
`k1v_bracket_extract` (:2150) is a fresh-type witness
`hpin : ∃ u, x < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) (nfk_projFresh σ)` (probe A: this is ALL
it carries) — a SEPARATE existential, unconnected to the residual `e 1 = w`, `e 2 = x`. So the F3
crux (:5227-5236) recurs verbatim; the pin channel adds fresh-type witnesses, not anchor pinning.

**Channel (ii) is inert on this counterexample.** `kvE_exclConj` (:5387) is applied ONLY to
NEGATIVE subs (`negIn zs`, :5453) and is guarded honest-safe: `exclAt zs σ = if hasPos zs
(nfk_projFresh σ) then Formula.top else kvE_exclConj …` (:5452-5454). In F3 the dishonest POSITIVE
sub `σ''` occupies zone `zXW` with fresh type `type(14)`, so `hasPos zXW type(14) = true`; every
marked-false sub sharing that fiber (the honest `c 14`, `qnf.2 (c 14) = false`) has its exclusion
conjunct collapsed to `⊤`. The carrier-indistinguishability that defeats channel (i) also
neutralizes the channel-(ii) guard.

**Counterexample (defect bar, four elements — the statement is FALSE, provider-independent).**
Verbatim from the F3 record (:5244-5270), now re-verified carrier-visible for `kvE'`: `M = ℤ`
(Prior UZ/SZ hold), preds `p = {0}`, `r = {13}`, `x = 10`, `t = 20`,
`σ'' := char [14,16,11,20]` (fake anchors sharing only `t`; on-fiber, zone `zXW`, fresh type
`type(14)`), `qnf.2 (char [14,15,10,20]) := false`, `qnf.2 σ'' := true`. **Current behavior**: the
extended carrier's LHS still HOLDS at `(10,20)` — the honest slots plus σ'''s pin slots (fresh type
`type(14)`, realized honestly at `u = 14`) plus σ'''s `t`-anchored provider literal (its own fake
realization `[14,16,11,20]` ends at `t = 20`) are all satisfied, and channel (ii) is guarded off.
**Required behavior**: per-sub joint claims pinned against the honest anchor pair (Prop 4.2 uniform
negation/exclusion at round k+1, md:100-101). **Isolation**: the gap is the per-sub joint/exclusion
channel; gate, zones, unary families, arrangements behaved exactly as at k=1; provider-independent
(only `P.correct` consumed — survives ANY correct depth-1 bundle, including Phase 14's).

**Verdict: 13.35 = NO-GO, carrier-shape defect (finding F4).** The 13.25 uniformization added TWO
channels but neither carries the discriminating per-sub JOINT content (the sub's inner-witness
structure vs the honest anchors, which rides `σ.2`): channel (i) is a function of `nfk_projFresh σ`
(σ.1-level) alone with `witnessZone` discarded (probe A, `rfl`), and channel (ii) is negative-only
and guarded off by the dishonest sub's fiber occupancy. The provider literal still rebinds
`u/w/x` (probe B). This is the PRE-COMMITTED second-and-LAST gate outcome: per the Phase 13.35
routing (plan v7 :925-935; v7 Amendment F3 one-round budget), a second NO-GO is NOT another
uniformization round — it ESCALATES to the orchestrator blocker ladder (defect record F4 →
orchestrator halts the 309 ladder → user decision / `/spawn 309`). KD3 held: the 13.25 carrier and
the 13.1 predicate are UNCHANGED (this record is the phase's only artifact — no partial theorem, no
sorry). Escalation fence C3 held: no anchor growth; EANegation :1090/:1249 untouched. Phases 13.4
and 14 MUST NOT be dispatched. -/

/-! ## Task 320 (F4 follow-up): Joint-Pinning De-Risk Probes — NON-CONSUMED verdict addition

Machine-checked probe deliverable for task 320 (de-risk the joint-pinning route for the k=2
carrier gate). This section is a NON-CONSUMED, ADDITIVE verdict record in the F1-F4 house style:
nothing below is referenced by any landed carrier, predicate, or proof (`bracketEndChar_kv*`,
`kvE'_body`, `ExistProviders`, `BracketCarrierCorrectVPrior` are all untouched and byte-identical).
It records the GO/NO-GO probe evidence discriminating routes b1/b2/b3 (spawn analysis
`specs/309_.../reports/06_spawn-analysis-f4.md`; literature-alignment audit
`specs/320_.../reports/01_literature-alignment.md`). No sorry on any live path; all F_i-chain
content is carried by the LANDED, PROVEN `EANegation` fChain machinery (Rabinovich Cor 5.4,
md:154-157), never re-derived with `simp`/`omega`/`aesop` (G5). Full prose deliverable:
`specs/320_.../reports/02_jointpinning-probe-results.md`.

Route summary (see the report for the design spec):
- **b1** (repair channel (i) to consume `witnessZone`): **NO-GO** — probe P1 re-confirms the
  channel-(i) flattening collapse (`rfl`); Def 3.1 (md:61-74) pins σ's OWN witnesses, with no
  counterpart across the provider/`e` boundary.
- **b2** (structural-identity via `nf_eval_unique`/`nfPred_correct`): **NOT NEEDED** — probe P4
  closes b3 without any type-realization/uniqueness hypothesis (none appears in P4's signature).
- **b3** (nested F_i-chain sub-bracket, Cor 5.4): **GO** — probes P3/P4 show the LANDED fChain
  machinery carries joint multi-anchor position by the nested-Until EVALUATION POINT (litmus
  PASS), recovering honest witness positions from `bf.holds` alone, `e`-free.
-/

/-- **Probe P1 (Phase 1 baseline + Phase 2 b1 NO-GO): channel-(i) flattening collapse — `rfl`.**
    Machine re-verification of the F4 record's probe A (:5548). The landed channel-(i) content
    `kvE_pinDisjunct` mapped over the finite arrangement family `kvE_pinArrangements σ` collapses
    to a CONSTANT function of `nfk_projFresh σ` (the σ.1-level fresh depth-`k` type): the
    `witnessZone` placement field is discarded in `kvE_pinArrangements` (:5364, sets
    `witnessType := nfk_projFresh σ`), so every one of the seven consistent-zone disjuncts yields
    the identical pair `([⟨charK (nfk_projFresh σ)⟩], [⟨charK (nfk_projFresh σ)⟩])`. Two subs with
    equal `nfk_projFresh` (F4's dishonest `char[14,16,11,20]` and honest `char[14,15,10,20]`,
    `type(14)=type(15)`) therefore get byte-identical channel-(i) content: the pin channel is
    positionally vacuous and cannot discriminate them. Def 3.1 (Rabinovich md:61-74) is a real
    pinning discipline, but it pins σ's OWN witnesses inside σ's OWN bracket; it has no mechanism
    for forcing the provider's independently-bound `e` to coincide with the honest anchors (the
    actual F4 gap). Route b1 = NO-GO (an F5-strengthening refutation, not a live design). -/
private theorem probe_P1_channel_i_collapse {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (σ : NormalForm sig k 4) :
    (kvE_pinArrangements σ).map (fun a => kvE_pinDisjunct charBase charK σ a)
      = kvE_consistentZones.map
          (fun _ => (([⟨charK (nfk_projFresh σ)⟩] : List TemporalPred),
                     ([⟨charK (nfk_projFresh σ)⟩] : List TemporalPred))) := by
  rfl

/-- **Probe P3 (Phase 3): Cor 5.4 chain-shape MATCH for `fChainFrom`/`fChainPred`.** The landed,
    PROVEN `BracketFormula.fChainFrom_step` (EANegation:616) IS Rabinovich Cor 5.4's step
    `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` (md:154-157): `F_i` at `x` holds iff `α_i(x)` and there
    is a forward point `s` where `F_{i+1}` holds with `β_{i+1}` along `(x, s)`. The position of the
    NEXT anchor `s` is carried by the strict-Until EVALUATION POINT (md:41), never asserted as a
    relative-position identity. Combined with the base case `F_n := α_n ∧ (β_{n+1} Until ⊤)`
    (`fChainFrom_base`, EANegation:580 — the open-interval adaptation of Cor 5.4's `F_n := α_n`,
    folding the trailing segment), `fChainFrom`/`fChainPred` (EANegation:552/:567) MATCH the Cor 5.4
    shape. This probe type-checks only because the landed def and the Cor 5.4 recursion coincide;
    hence the audit's MEDIUM-confidence claim 6 is machine-CONFIRMED. -/
private theorem probe_P3_cor54_step_shape {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (i : Fin (n + 1)) (h_lt : i.val < n)
    (x : M.carrier) :
    (bf.fChainFrom i).eval_at M atomMap x ↔
    (bf.pointTypes i).eval_at M atomMap x ∧
    ∃ s : M.carrier, x < s ∧
      (bf.fChainFrom ⟨i.val + 1, by omega⟩).eval_at M atomMap s ∧
      (∀ r : M.carrier, x < r → r < s →
        (bf.segmentTypes ⟨i.val + 1, by omega⟩).eval_at M atomMap r) :=
  bf.fChainFrom_step M atomMap i h_lt x

/-- **Probe P4 (Phase 4): route b3 GO evidence — positions by evaluation point, `e`-free.**
    The landed, PROVEN `BracketFormula.bracket_implies_fChainPred` (EANegation:660): whenever the
    nested bracket holds on `(z0, z)`, the F-chain predicate `fChainPred` is satisfied at a witness
    `x0` STRICTLY INSIDE `(z0, z)`, recovered from the bracket's OWN interval pattern. Unfolding
    `fChainPred` through probe P3 (`fChainFrom_step`) exhibits each subsequent anchor at its own
    honest position via the nested Until — WITHOUT any provider environment `e : Fin m → M.carrier`
    and WITHOUT any residual `w = e 1` / `x = e 2`. This is precisely the joint multi-anchor content
    the flattened literal `P.existF 3 σ` fails to carry (F4 probe B, :5559: there the provider's own
    `e` rebinds `u/w/x`). Here the anchor positions ARE the bracket witnesses, quantified by the
    temporal semantics — no environment ever rebinds them. Note the signature: `bf.holds` is the
    SOLE hypothesis — NO structural-identity / `nf_eval_unique` / `nfPred_correct` premise is needed
    (route b2 = NOT NEEDED, Phase 5). GO-gate litmus (position-by-evaluation-point): PASS. -/
private theorem probe_P4_b3_positions_by_eval_point {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (z0 z : M.carrier)
    (h : bf.holds M atomMap z0 z) :
    ∃ x0 : M.carrier, z0 < x0 ∧ x0 < z ∧
      bf.fChainPred.eval_at M atomMap x0 ∧
      (∀ y : M.carrier, z0 < y → y < x0 →
        (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y) :=
  bf.bracket_implies_fChainPred M atomMap z0 z h

open Classical in
/-- **Corrected per-sub enriched body** (task 321 Phase 5; report §3 item 4). Structurally IS
    `kvE'_body` (:5405, same-module `private` reuse of `kvE_pinArrangements`/`kvE_pinDisjunct`/
    `kvE_exclConj`/`bracketFromLists` is legal) with the ONE corrective change F1–F4 demanded: the
    per-sub JOINT literal is replaced by the nested F_i-chain splice.
    - `ptSub σ` is now `kvE_subChain charBase charK σ` (the nested sub-bracket's `fChainPred`, which
      carries `σ`'s inner-witness structure via the nested-Until evaluation point), NOT the flat
      `⟨charK (nfk_projFresh σ)⟩` (:5467) that F4 refuted as positionally vacuous.
    - The `t`-anchored provider literal `pos.map exF` (`exF = P.existF 3`, :5448) is DROPPED
      entirely — the `exF`/`P.existF 3` parameter disappears from the joint path (report §3 note),
      so no `e`-rebinding site exists (the F4 crux `w = e 1` / `x = e 2` cannot arise). `P.existF 0`
      (the unary `charK` channel) is retained.
    ALL other channels (gate, unary `epL`/`epR` non-joint parts, zones, arrangements `pinSlots`,
    `ptW`, `segL`/`segR`, channel-(ii) `exclAt`) are retained VERBATIM — F4 isolated the gap to the
    per-sub joint channel ONLY.

    **Depth note (forced by report §2/Q2).** This body is at the CONCRETE gate instance (subs
    `σ : NormalForm sig 1 4`, `q : NormalForm sig 1 4 → Bool`, `charK : NormalForm sig 1 1 →
    Formula`), because `kvE_subChain` reads `σ.2` through the depth-0 `nf0_assemble` engine, which
    the report fixes at `j = 0` ("the gate instance j = 0 needs only the landed `nf0_assemble`"; the
    general-`j` fold-engine lift is deferred follow-on). This is exactly the `k = 2` carrier the GO
    gate targets; the general-`j` header is not needed for the gate. -/
private noncomputable def kvE2_body {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig 1 4 → Bool) : VVecEA2 :=
  let ltz : Bool × Bool := (true, false)
  let eqz : Bool × Bool := (false, false)
  let gtz : Bool × Bool := (false, true)
  let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
    Fin.cons pw (Fin.cons px (fun _ => pt))
  let zPastX := mk3 ltz ltz ltz
  let zAtX   := mk3 ltz eqz ltz
  let zXW    := mk3 ltz gtz ltz
  let zAtW   := mk3 eqz gtz ltz
  let zWT    := mk3 gtz gtz ltz
  let zAtT   := mk3 gtz gtz eqz
  let zFutT  := mk3 gtz gtz gtz
  let pos : List (NormalForm sig 1 4) := Finset.univ.toList.filter (fun σ => q σ)
  let neg : List (NormalForm sig 1 4) := Finset.univ.toList.filter (fun σ => !q σ)
  let zone : NormalForm sig 1 4 → ZoneSpec 3 := fun σ =>
    nf0_zoneSpec (NormalForm.atom_assgn σ)
  let posIn : ZoneSpec 3 → List (NormalForm sig 1 4) := fun zs =>
    pos.filter (fun σ => decide (zone σ = zs))
  let negIn : ZoneSpec 3 → List (NormalForm sig 1 4) := fun zs =>
    neg.filter (fun σ => decide (zone σ = zs))
  let hasPos : ZoneSpec 3 → NormalForm sig 1 1 → Bool := fun zs χ =>
    (posIn zs).any (fun σ => decide (nfk_projFresh σ = χ))
  let allTypes : List (NormalForm sig 1 1) := Finset.univ.toList
  let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
  let xType : TemporalPred := ⟨charBase (nf_x_proj3 r)⟩
  let tType : TemporalPred := ⟨charBase (nf_t_proj3 r)⟩
  let epL : TemporalPred :=
    ⟨formula_conjList
      (xType.formula
        :: (allTypes.map fun χ => lit (hasPos zPastX χ) (Formula.snce (charK χ) Formula.top))
        ++ (allTypes.map fun χ => lit (hasPos zAtX χ) (charK χ)))⟩
  -- epR: the t-anchored joint literal `pos.map exF` is DROPPED (report §3 note; the joint content
  -- rides `kvE_subChain` on the witness slot instead of any provider literal at `t`).
  let epR : TemporalPred :=
    ⟨formula_conjList
      (tType.formula
        :: (allTypes.map fun χ => lit (hasPos zAtT χ) (charK χ))
        ++ (allTypes.map fun χ => lit (hasPos zFutT χ) (Formula.untl (charK χ) Formula.top)))⟩
  let exclAt : ZoneSpec 3 → List Formula := fun zs =>
    (negIn zs).map fun σ =>
      if hasPos zs (nfk_projFresh σ) then Formula.top else kvE_exclConj charBase charK σ
  let segL : TemporalPred :=
    ⟨formula_conjList
      ((allTypes.map fun χ =>
        if hasPos zXW χ then Formula.top else (charK χ).neg) ++ exclAt zXW)⟩
  let segR : TemporalPred :=
    ⟨formula_conjList
      ((allTypes.map fun χ =>
        if hasPos zWT χ then Formula.top else (charK χ).neg) ++ exclAt zWT)⟩
  let ptW : TemporalPred :=
    ⟨formula_conjList
      (charBase (nf_y_proj r)
        :: (allTypes.map fun χ => lit (hasPos zAtW χ) (charK χ)))⟩
  -- CORRECTED joint channel (task 321 Phase 8 re-point): the per-sub joint slot is now the
  -- three-region sub-chain accessor `kvE_subChain2V` (task 325, :6901) over `bracketFromLists3`
  -- — the list of per-arrangement Cor 5.4 F_i-chains (Rabinovich md:154-157), each reading `σ.2`
  -- through the three interior zones `zXU`/`zUW`/`zWT` (Prop 3.5 md:87-94). This supersedes the
  -- old single `kvE_subChain σ` splice (F4-blocked: its upward-only chain could not reach the
  -- below-anchor zone `zXU`); `kvE_subChain2V` returns a `List TemporalPred` (one chain per
  -- arrangement-disjunct), so the joint slot is spliced with `++` rather than `::`. No `P.existF 3`
  -- on the joint path; `P.existF 0` (the unary `charK` channel) retained verbatim.
  let ptSub : NormalForm sig 1 4 → List TemporalPred := fun σ => kvE_subChain2V charBase charK σ
  let pinSlots : NormalForm sig 1 4 → List TemporalPred := fun σ =>
    (kvE_pinArrangements σ).flatMap (fun a => (kvE_pinDisjunct charBase charK σ a).1)
  let slotsFor : List (NormalForm sig 1 4) → List TemporalPred := fun l =>
    l.flatMap (fun σ => ptSub σ ++ pinSlots σ)
  let S_L : List (NormalForm sig 1 4) := posIn zXW
  let S_R : List (NormalForm sig 1 4) := posIn zWT
  let mkDisjunct : List (NormalForm sig 1 4) → List (NormalForm sig 1 4) → Σ n, VecEA2 n :=
    fun lL lR =>
      ⟨(slotsFor lL).length + 1 + (slotsFor lR).length,
        { endpointLeft := epL
          endpointRight := epR
          bracket := bracketFromLists (slotsFor lL) ptW (slotsFor lR) segL segR }⟩
  @dite _ (kvE_gate r q) (Classical.dec _)
    (fun _ =>
      { disjuncts :=
          S_L.permutations.flatMap fun lL =>
            S_R.permutations.map fun lR => mkDisjunct lL lR })
    (fun _ => { disjuncts := [] })

/-- Gate-failure computation for the corrected body (the `kvE'_body_gate_fail` :5494 mirror). -/
private theorem kvE2_body_gate_fail {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig 1 4 → Bool)
    (h : ¬ kvE_gate r q) :
    kvE2_body charBase charK r q = { disjuncts := [] } := by
  simp only [kvE2_body]
  exact dif_neg h

/-- **The corrected per-sub enriched successor-depth V-carrier** (task 321 Phase 6; report §3
    item 5). Additive alongside `bracketEndChar_kvE` (:5150) and `bracketEndChar_kvE'` (:5510), both
    UNCHANGED. At depth-1 providers (`P : ExistProviders sig atomMap 1`) it produces the k=2 carrier
    `BracketEndCharCarrierV sig 2`, delegating to `kvE2_body` at the standard instantiation
    (`charBase = nf_depth0_char_formula`, `charK = P.existF 0`) — the joint channel now carried by
    `kvE_subChain` (no `exF` / `P.existF 3` on the joint path). This is the carrier whose k=2
    `BracketCarrierCorrectVPrior` gate the task drives to GO (Stages C/D). -/
noncomputable def bracketEndChar_kvE2 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1) :
    BracketEndCharCarrierV sig 2 :=
  fun qnf =>
    kvE2_body (nf_depth0_char_formula atomMap h_surj)
      (fun χ => P.existF 0 χ) qnf.1 qnf.2

/-- **Concrete k=2 instance bridge** (task 321 Phase 6; the `bracketEndChar_kvE'_two_eq` :5523
    mirror). At depth-1 providers the corrected carrier is DEFINITIONALLY the corrected body at the
    standard instantiation. Pure `rfl` — Stages C/D rewrite with this to expose `kvE2_body`. Because
    the carrier is already at the concrete gate instance (report §2/Q2 forces `j = 0`), this bridge
    is the definitional unfolding rather than a `j+1 ⇒ j=0` depth specialization; a depth mismatch
    from any successor threading error would fail this `rfl` immediately. -/
theorem bracketEndChar_kvE2_two_eq {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3) :
    bracketEndChar_kvE2 atomMap h_surj P qnf =
      kvE2_body (nf_depth0_char_formula atomMap h_surj)
        (fun χ => P.existF 0 χ) qnf.1 qnf.2 := rfl

/-- **Phase 8 wiring-boundary non-vacuity consumption** (task 321 Phase 8; binding non-vacuity-gate
    countermeasure). Before any Stage-C/D correctness direction is opened over the re-pointed
    `kvE2_body`/`bracketEndChar_kvE2` joint channel (whose per-sub joint slot is now
    `kvE_subChain2V` :6901 — the list of per-arrangement Cor 5.4 F_i-chains over `bracketFromLists3`,
    Rabinovich md:154-157), we CONSUME task 325's landed `kvE_subBracket2V_nonvacuous` (:7743) as a
    `have` at the wiring boundary: for an honest σ realized at the anchor env `[x1, w, x, t]` under
    `x < x1 < w < t`, the sub-bracket carrier whose arrangement-fChainPreds now feed that joint slot
    has a NON-empty `disjuncts` list. This records, at the re-point site, that the corrected carrier
    is inhabited — foreclosing the three prior gate-class vacuity failures (task 321 P8 `zXU`
    reachability; task 324 P6 false-∀-M converse; task 325 v1 empty-gate vacuity) BEFORE Stages C/D
    open. Purely consumes the landed lemma (no `simp`/`omega`/`aesop`); Rabinovich Prop 4.2
    (md:100-101), Prop 3.5 (md:87-94). -/
theorem kvE2_joint_nonvacuous_at_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier)
    (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (h : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (kvE_subBracket2V charBase charK σ).disjuncts ≠ [] := by
  have hnv := kvE_subBracket2V_nonvacuous charBase charK σ M x1 w x t hxx1 hx1w hwt h
  exact hnv

/-! ## Task 327 P1: depth-2 outer quant-layer fold provability GATE →
**WHOLE-TASK NO-GO** (machine-grounded; DECISION GATE, mirror of the R2 NO-GO :1609-1641)

**Question decided.** Does the depth-2 outer quant-layer fold `nf_quant_layer_fold_k2_gate` (the
arity-4/depth-1 analog of the landed `nf_quant_layer_fold_k1_gate`, NfEFold:525) fold CLEANLY into
per-(zone,χ) monadic obligations at CONSTANT arity, and by which route — (a) naive `nfk`-split-kit
`nf_eval_nf1_cons_factor`, (b) constant-arity E[Σ] `efold_of_nfk`, or (c) a new argument?
For `qnf : NormalForm sig 2 3` the target reduces the outer quant layer
`∀ sub : NormalForm sig 1 4, (∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) sub) ↔ qnf.2 sub = true`
to `∀ (zs : ZoneSpec 3) (χ : NormalForm sig 1 1), (∃ x1, zoneHolds M [w,x,t] zs x1 ∧
nf_eval_nf M 1 1 (fun _ => x1) χ) ↔ qnf.2 (nfk_assemble zs χ qnf.1) = true` (+ off-fiber).

**Verdict: NO-GO for ALL of routes (a), (b), (c) at constant arity-1 χ.** Both the naive factor
and the E[Σ] outer fold bottom out on the SAME depth-1 per-witness factorization
`nf_eval_nf1_cons_factor`, which is FALSE in clean form: the inner quant layer's witness `v`
couples SIMULTANEOUSLY to the outer witness `x1` AND to the three fixed anchors {w,x,t}, and the
constant-arity monadic channel `nfk_projFresh sub : NormalForm sig 1 1` reads `v` at arity 1
(`zoneHolds M (fun _ => x1) …`) — structurally too small to carry the `v`-vs-{w,x,t} coupling.
This is the arity-4 → arity-3 / G6 re-bounding barrier (:1622-1646) resurfacing at the OUTER quant
layer. The E[Σ] constant-arity representation (Rabinovich Def 4.1, Prop 4.3) does NOT dodge it: its
constant arity is arity-1, precisely the arity that cannot hold the joint content.

**Machine evidence — captured crux `lean_goal` state (route-(b) reconstruction probe).** Under
`hz : zoneHolds M [w,x,t] zs x1`, `hmon : nf_eval_nf M 1 1 (fun _ => x1) (nfk_projFresh sub)`
(the constant-arity monadic channel, unfolded via `nf_eval_depth1_fold_iff` at n=1 to
`(∃ v, zoneHolds M (fun _ => x1) zs v ∧ …) ↔ (nfk_projFresh sub).2 (…)`, i.e. `v`-vs-`x1` ONLY),
and `hatom`, the inner-fold crux goal is:

    zs' : ZoneSpec 4
    χ' : NormalForm sig 0 1
    ⊢ (∃ v, zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x fun _ ↦ t))) zs' v ∧
          nf_eval_nf M 0 1 (fun _ ↦ v) χ') ↔
        sub.2 (nf0_assemble zs' χ' sub.1) = true

The goal's `zs' : ZoneSpec 4` demands `v`'s zone against the FULL arity-4 env `[x1,w,x,t]`; the
only witness hypothesis `hmon` supplies `ZoneSpec 1` (`v`-vs-`x1`). The `v`-vs-{w,x,t} coupling is
irrecoverable — matching the irreducible arity-4 residual at :1629-1636.

**Failed `lean_multi_attempt` closers on the crux goal (≥2 required; five captured):**
  1. `exact hmon.2.1 zs' χ'` → *Application type mismatch: argument `zs'` has type `ZoneSpec 4`
     but is expected to have type `ZoneSpec 1`.* (The decisive certification: constant arity = 1.)
  2. `exact hmon.2.1 _ χ'` → *Type mismatch:* `hmon` yields `zoneHolds M (fun _ ↦ x1) ?m v` but the
     goal requires `zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x fun _ ↦ t))) zs' v` — the
     environments (arity 1 vs arity 4) are irreconcilable.
  3. `simp_all [nf_eval_nf, zoneHolds]` → unsolved: goal reduces to `∀ i : Fin 4, …` four-point
     order constraints on `v`; `hmon` gives only the `(v < x1) ∧ (x1 < v)` single-point pair.
  4. `constructor <;> intro <;> tauto` → `tauto` fails BOTH directions; the `mpr` branch leaves the
     unfillable witness obligation `⊢ M.carrier` — no way to position the inner witness relative to
     {w,x,t} from the x1-monadic data.
  5. `aesop` → failed to prove the goal after exhaustive search (both `mp` and `mpr` remain).

**LITMUS.** No `x1 < e_i` relative-position literal was introduced (the obstruction is the inner
witness `v`'s coupling, not `x1`'s positioning); the certification rests on the arity-4 residual
clause of the NO-GO exit criterion, not the LITMUS clause.

**Route (c).** No constant-arity-1 χ argument can characterize `∃ x1, nf_eval_nf M 1 4 (cons x1
[w,x,t]) sub`: models differing only in the inner witness's position relative to `w`, while
agreeing on all arity-1 projections and on `x1`'s zone, are distinguished by the LHS — a semantic
impossibility for any constant-arity-1 encoding. Growing χ's arity abandons the constant-arity
design and re-enters the navigated-characteristic G6 barrier. Hence WHOLE-TASK NO-GO.

**Consequence (recommendation).** The depth-2 carrier route as specified (constant-arity E[Σ]
outer fold) is BLOCKED. **Do NOT start P2 (engine) or P3 (5-zone dischargers).** The whole k=2
carrier route needs fundamental reconsideration: any viable path must carry the inner-witness
joint content, which the ≤2-free-variable / constant-arity design forbids. Per DECISION-GATE
(:1638) no partial carrier and no `sorry` is committed; this record is additive and inert. -/

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
theorem kvE_fold_navigated {sig : MonadicSignature}
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
theorem VVecEA2.disjList_holds {sig : MonadicSignature}
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

/-- **Prop 4.3 re-flatten negation step.** The negation case of the structural induction is
    discharged by the LANDED Prop 4.2 closure `neg_2var_vec_ea` (EANegationClosure.lean:722) —
    re-exported at the re-flatten call site (the hardest half, already proven; consumed, not
    rebuilt). On a `HasAttainedINF` structure, whenever a flat block `v` fails at `(z0, z1)` there
    is a `VVecEA2` witnessing its negation. -/
theorem reflatten_neg_step {sig : MonadicSignature}
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
theorem reflatten_prop43 {sig : MonadicSignature}
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
theorem VVecEA2.holds_flatMap_map {sig : MonadicSignature} {α β : Type}
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
theorem kvE_nonInterior_zPastX_sound {sig : MonadicSignature}
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
theorem kvE_nonInterior_zFutT_sound {sig : MonadicSignature}
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
theorem kvE_nonInterior_zAtX_sound {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x : M.carrier) (fs : List Formula) (φ : Formula)
    (hmem : φ ∈ fs)
    (hepL : temporal_truth M atomMap x (formula_conjList fs)) :
    temporal_truth M atomMap x φ :=
  (formula_conjList_iff M atomMap x fs).mp hepL _ hmem

/-- **`zAtT` soundness (right-boundary point-realization).** From `epR` holding at the fixed right
endpoint `t`, the bare literal `φ` (present when `bits zAtT χ = true`) is realized AT `t` itself —
the `v = t` zone (Def 3.1 md:61-74). The witness is the fixed anchor. -/
theorem kvE_nonInterior_zAtT_sound {sig : MonadicSignature}
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
theorem kvE_nonInterior_zAtW_sound {sig : MonadicSignature}
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
theorem kvE_nonInterior_zPastX_complete {sig : MonadicSignature}
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
theorem kvE_nonInterior_zFutT_complete {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t v : M.carrier) (φ : Formula)
    (hv_lt : t < v)
    (hv_phi : temporal_truth M atomMap v φ) :
    temporal_truth M atomMap t (Formula.untl φ Formula.top) :=
  ⟨v, hv_lt, hv_phi, fun r _ _ => temporal_truth_top M atomMap r⟩

/-- **`zAtX` completeness (left-boundary point-realization).** The bare literal `φ` realized AT the
fixed left endpoint `x` IS its own completeness witness — the `v = x` zone (Def 3.1 md:61-74). No
navigation: the anchor witnesses directly. -/
theorem kvE_nonInterior_zAtX_complete {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x : M.carrier) (φ : Formula)
    (hx_phi : temporal_truth M atomMap x φ) :
    temporal_truth M atomMap x φ :=
  hx_phi

/-- **`zAtT` completeness (right-boundary point-realization).** The bare literal `φ` realized AT the
fixed right endpoint `t` IS its own completeness witness — the `v = t` zone (Def 3.1 md:61-74). -/
theorem kvE_nonInterior_zAtT_complete {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (φ : Formula)
    (ht_phi : temporal_truth M atomMap t φ) :
    temporal_truth M atomMap t φ :=
  ht_phi

/-- **`zAtW` completeness (interior-anchor point-realization).** The self-zone literal `φ` realized
AT the interior anchor `w` IS its own completeness witness — the `v = w` witness self-zone (v2
nine-zone correction; Def 3.1 md:61-74; Amendment F3 preserved). -/
theorem kvE_nonInterior_zAtW_complete {sig : MonadicSignature}
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
