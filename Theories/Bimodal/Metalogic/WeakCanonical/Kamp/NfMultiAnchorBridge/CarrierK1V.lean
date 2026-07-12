import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base

/-! Extracted from NfMultiAnchorBridge.lean lines 1523-3603 (task 331).
k=1 V-carrier kit: `bracketEndChar_k0`/`_k1`, `bracketFromLists`, `bracketEndChar_k1v`
with its helper kit and soundness/completeness/correctness (`_sound`, `_complete`, `_correct`).
Byte-identical relocation except 6 sanctioned `private ` removals. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Phase 9 (task 309, R1): Two-anchor VecEA2 bracket carrier reformulation + interface

Report 03 (the revision authority; full-PDF Rabinovich 2014 read) established that the plan-v2
navigated carrier `EndCharCarrier := NormalForm sig k 3 → TemporalPred` (above, :1029) has **no
counterpart in Rabinovich's proof** and is provably FALSE in free-anchor form
(`endChar0_correct` deviation note, :1058-1069): a closed navigated-`w` `TemporalPred` cannot read
the anchor positions. That is the ≤2 free-variable cap (Lemma 3.2(2), PDF p.4) surfacing.

The v3 carrier (report 03 Path B, ENDORSED) is the **two-anchor bracket characteristic** of
Rabinovich Prop 3.5 (PDF p.5): the interior existential `∃x_i` collapses to an Until/Since **bracket
witness**, with the two anchors `{x,t}` the **fixed** bracket endpoints (`z_0, z_1`) and the interval
content a monadic `E[Σ]`-atom (Def 4.1, PDF p.5). This is a `VecEA2 1` — two endpoint `TemporalPred`s
(`endpointLeft`/`endpointRight` at the fixed anchors) plus one interval `BracketFormula 1`. The
depth-0 instance already exists sorry-free (`nf_3var_bracket_xyt`/`_correct`, VecEADecomp:233/244);
Phases R2/R3 lift it to depth `k` threading the depth-`k` arity-1 point characteristic (`char_k1`,
KampPrior:307, the E[Σ]-atom) as endpoint/interval types.

**G6 (the v3 carrier guard) vs. G2 (do NOT conflate).** G2 bars a *projection-based `VecEA2` tower*
that introduces a **third free anchor** (specs/305 report 40 — a genuine ≤2-cap violation). This
carrier is a *two-anchor* bracket where the `VecEA2` is the Prop-3.5 bracket-**witness** structure:
`{x,t}` are FIXED endpoints (2, not a third free anchor) and `w` is a bracket witness, never a third
anchor (G4). Free-variable count is structurally ≤2 by the carrier type itself (Lemma 3.2(2)). The
`VecEA2` shape alone does not violate G2; a *third free anchor* would.

This phase installs the carrier TYPE (so the arity-4 obstruction cannot re-form) and states the
fixed-endpoint correctness signature, mirroring `nf_3var_bracket_xyt_correct` (VecEADecomp:244). The
retained abandoned-route `EndCharCarrier`/`endChar0`/`seg` defs above are left inert and untouched. -/

/-- **Two-anchor VecEA2 bracket carrier** (task 309 Phase 9, R1; report 03 Path B; Rabinovich Prop 3.5,
PDF p.5). The v3 recursion carrier: a `NormalForm sig k 3` is characterized as a `VecEA2 1` — two
endpoint `TemporalPred`s (the fixed anchor types at `z_0 = x`, `z_1 = t`) plus one interval
`BracketFormula 1` (the Until/Since bracket witness). This REPLACES the abandoned navigated
`EndCharCarrier := NormalForm sig k 3 → TemporalPred` (:1029, retained but off the live path): here
`{x,t}` are the FIXED bracket endpoints (≤2, Lemma 3.2(2)) and `w` is a bracket WITNESS (G4/G6), so no
arity-4 quant layer and no third free anchor (G2-safe: the `VecEA2` is a bracket-witness structure,
not a projection tower) can form. -/
abbrev BracketEndCharCarrier (sig : MonadicSignature) (k : Nat) : Type :=
  NormalForm sig k 3 → VecEA2 1

/-- **Target fixed-endpoint correctness for the two-anchor bracket carrier** (task 309 Phase 9, R1;
Rabinovich Prop 3.5, PDF p.5). The stated interface obligation Phases R2 (`k=1` decision gate) and R3
(depth-`k` lift) discharge: the carrier's `VecEA2.holds` at the fixed anchor pair `(x, t)` is
equivalent to the existence of a **bracket witness** `w` realizing the arity-3 depth-`k` evaluation
`nf_eval_nf M k 3 [w, x, t] qnf`. `{x,t}` are the FIXED endpoints; `w` is the bracket witness (G4/G6).
Mirrors `nf_3var_bracket_xyt_correct` (VecEADecomp:244) with the depth generalized to arbitrary `k`.
Free-variable count is structurally ≤2 (Lemma 3.2(2), PDF p.4) — the two endpoints. -/
def BracketCarrierCorrect {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    {k : Nat} (carrier : BracketEndCharCarrier sig k) : Prop :=
  ∀ (qnf : NormalForm sig k 3) (x t : M.carrier),
    (carrier qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-- **`k = 0` carrier instance** (task 309 Phase 9, R1). The depth-0 two-anchor bracket carrier is the
already-sorry-free `nf_3var_bracket_xyt` (VecEADecomp:233), confirming it inhabits
`BracketEndCharCarrier sig 0` (the recursion base for R3). Prop 3.5 depth-0 collapse (PDF p.5). -/
noncomputable def bracketEndChar_k0 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    BracketEndCharCarrier sig 0 :=
  nf_3var_bracket_xyt atomMap h_surj

/-- **`k = 0` fixed-endpoint correctness** (task 309 Phase 9, R1; sorry-free leaf). The depth-0 instance
of `BracketCarrierCorrect`, restricted to the `x < y < t` bracket zone (the order hypotheses of
`nf_3var_bracket_xyt_correct`, VecEADecomp:244): the depth-0 carrier's `holds` at the fixed anchors
`(x, t)` is equivalent to a bracket witness `w` (the interior `y`) realizing `nf_eval_nf M 0 3 [w,x,t]`.
Discharged directly by the landed sorry-free `nf_3var_bracket_xyt_correct` — no simp/omega/aesop
chain-step shortcut (G5). Confirms the carrier's correctness signature typechecks against the exact
`∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t)))` target at `k = 0`; Phases R2/R3 lift the
order-zone-conditional depth-0 result to the unconditional depth-`k` `BracketCarrierCorrect`. -/
theorem bracketEndChar_k0_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_k0 atomMap h_surj ssn).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) ssn :=
  nf_3var_bracket_xyt_correct atomMap h_surj ssn h_xy h_yt h_xt h_yx h_ty h_tx M x t

/-! ## Phase 10 (task 309, R2): k=1 de-risking probe — DECISION GATE → NO-GO

R2 tested whether the two-anchor `VecEA2 1` bracket carrier (R1) can characterize the depth-1
arity-3 evaluation `∃ w, nf_eval_nf M 1 3 [w,x,t] qnf` — the single experiment deciding Path B
(report 03 §3 OPEN RISK, §4 R2). **Verdict: NO-GO** (this dispatch; commit history / handoff).

`qnf : NormalForm sig 1 3 = (AtomKind sig 3 → Bool) × (NormalForm sig 0 4 → Bool)`, so
`nf_eval_nf M 1 3 [w,x,t] qnf` (k+1 = 1) unfolds to the conjunction of
  (atom layer)  `nf_eval_nf M 0 3 [w,x,t] qnf.1`, and
  (quant layer) `∀ sub : NormalForm sig 0 4, (∃ x_1, nf_eval_nf M 0 4 [x_1,w,x,t] sub) ↔ qnf.2 sub`.

The most faithful k=1 carrier mirrors the sorry-free depth-0 collapse `nf_3var_bracket_xyt` on the
atom part `qnf.1`. Its correctness `↔` was probed: after `nf_3var_bracket_xyt_correct` discharges the
atom layer and `refine ⟨w, h_atom, ?_⟩` splits the goal, the residual is the depth-1 quant layer

  ⊢ ∀ (sub_nf : NormalForm sig 0 4),
      (∃ x_1, atom_eval M (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t))) a ↔ sub_nf a) ↔
        qnf.2 sub_nf = true

with only the atom-layer hypothesis `h_atom : nf_eval_nf M 0 3 [w,x,t] qnf.1` in context. This is an
irreducible **arity-4 residual**: the env `[x_1, w, x, t]` couples the bracket witness `w` to BOTH
fixed endpoints `x, t` (plus a fresh existential `x_1`), and `qnf.2` was discarded by the atom-only
carrier. No `VecEA2 1` monadic component (`endpointLeft`@x / `endpointRight`@t / interval@w, each
reading a single point) can supply it; discharging it requires a NAVIGATED arity-3 characteristic
(reading `w` while `x, t` are navigated in) — exactly what G6 bars and exactly the arity-4 → arity-3
re-bounding obstruction that blocked plan-v2 Phase 8. `exact h_atom` / `exact h_atom sub_nf` fail with
type/arity mismatch; `simp_all [nf_eval_nf]` leaves the two irreducible sub-goals
`(∃ x_1 …arity-4…) ⟷ qnf.2 sub_nf`. Verified via `lean_goal` + `lean_multi_attempt` this dispatch.

Per the DECISION-GATE contract, no probe carrier or `sorry` is committed (a NO-GO lands no partial
carrier). Path B halts at `:351`; the follow-up is a spawned NormalForm E[Σ]-fold encoding task (see
plan Phase 10 [BLOCKED] record). The R1 carrier (`BracketEndCharCarrier` / `BracketCarrierCorrect` /
`bracketEndChar_k0` / `_correct`, above) remains sorry-free and off the live path. -/

/-! ## Task 311 Phase 1: the k=1 fold carrier instance (Path B, fold-backed)

Consumes task 310's E[Σ]-fold assets (`Kamp/NfEFold.lean`): the transport `efold_of_nf1`
(NfEFold:472) reads the depth-1 quant layer `qnf.2` ONLY through the fold's zone-bounded monadic
E-atoms `EAtomDom sig 0 3 = ZoneSpec 3 × NormalForm sig 0 1` (Def 4.1, PDF p.5) — no `qnf.2`
value is evaluated at an arity-4 environment, so the R2 NO-GO residual (:1601-1603 above) never
re-forms. Correctness (`bracketEndChar_k1_correct`, the k=1 instance of `BracketCarrierCorrect`)
is task 311 Phase 2 scope, routed through `nf_eval_nf1_iff_efold` (NfEFold:490) and the gate
corollary `nf_quant_layer_fold_k1_gate` (NfEFold:525). -/

/-- **k=1 two-anchor fold carrier** (task 311 Phase 1; audit-corrected N1 citations).

Encodes a depth-1 arity-3 `qnf : NormalForm sig 1 3` as a `VecEA2 1` at the two FIXED endpoints
`{x, t}` with `w` the single bracket WITNESS (G6 SHAPE, codomain `VecEA2 1` unchanged; anchors
stay `{x, t}`, ≤2). Citation split (audit caveat C1 / rule N1): the two-fixed-endpoint
`(z_0, z_1)` bracket framing is **Lemma 3.2(2) (PDF p.4) + the §5 bracket notation
`[α_0, …, α_n](z_0, z_1)` (PDF p.7)**; **Prop 3.5 (PDF p.5)** is cited ONLY for the
one-free-variable ∃-witness→Until/Since folding *mechanism* (the `Formula.snce`/`Formula.untl`
literals and the `bracketBuildLeft`/`bracketBuildRight` chains below), never for the two-endpoint
framing itself.

Construction — every read of `qnf.2` goes through `efold_of_nf1` / `nf0_assemble` (the Def-4.1
monadic-atom fold, PDF p.5); no arity-4 evaluation occurs:

- **Endpoints** mirror the depth-0 collapse `nf_3var_bracket_xyt` (VecEADecomp:233) on the atom
  layer `qnf.1`: `endpointLeft`/`endpointRight` carry the complete depth-0 point types
  `nf_x_proj3 qnf.1` / `nf_t_proj3 qnf.1`, conjoined with the fold bits of the zones anchored
  there — past-of-`x` and at-`x` on the left, at-`t` and future-of-`t` on the right — as
  positive/negated Since/Until literals (Prop 3.5 folding mechanism, PDF p.5).
- **Bracket** (`BracketFormula.single`, ONE witness `w` between the fixed endpoints, §5 bracket
  notation PDF p.7): the point type carries `w`'s own complete type `nf_y_proj qnf.1`, the
  equality-zone bits at `w`, and the POSITIVE interior-zone bits `(x, w)` / `(w, t)` folded as
  `bracketBuildLeft` / `bracketBuildRight` Since/Until chains anchored at the endpoint types
  (Prop 3.5 folding mechanism, PDF p.5; the interior witness joins the chain, never the anchor
  set — Lemma 3.4, PDF p.5). The segment types carry the NEGATIVE interior-zone bits as
  universal exclusions.
- **Gate** (Risk R2 — mirroring Rabinovich's disjunctions ranging only over consistent order
  types): the construction is the `⊥` carrier unless (i) `qnf.2` is false off the fiber over
  `qnf.1` (the ≤2-cap honesty clause of `nf_eval_nf1_iff_efold`, NfEFold:490,495) and (ii) every
  fold bit on a zone spec inconsistent with the bracket order `x < w < t` is false
  (order-conflict falsity; cf. `nf_depth0_pair_cycle_empty'`, NfDepth0Generalized:93).

The gate Prop is decidable in principle (`normalForm_fintype` / `normalForm_decEq`,
NormalForm.lean:177/181); `Classical.dec` is used since the carrier is noncomputable anyway. -/
noncomputable def bracketEndChar_k1 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    BracketEndCharCarrier sig 1 :=
  fun qnf =>
    -- Fold bits (Def 4.1, PDF p.5): the ONLY channel through which `qnf.2` is read.
    let b : ZoneSpec 3 → NormalForm sig 0 1 → Bool :=
      fun zs χ => (efold_of_nf1 qnf).2 (zs, χ)
    -- Zone-spec constants relative to env `[w, x, t]` under the bracket order `x < w < t`
    -- (Def 3.1 ordering channel, PDF p.4): `ltz`/`eqz`/`gtz` = witness below / at / above the
    -- env point, encoded as `(x_1 < env i, env i < x_1)`.
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
    -- Complete depth-0 monadic point types: the TL side of the fold's E-atoms.
    let char : NormalForm sig 0 1 → Formula := nf_depth0_char_formula atomMap h_surj
    let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
    -- Biconditional literal at an anchor: assert positively or negatively per fold bit
    -- (Prop 3.5 folding mechanism, PDF p.5).
    let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
    -- Endpoint types (the FIXED `z_0 = x`, `z_1 = t`: Lemma 3.2(2) PDF p.4 + §5 bracket PDF p.7).
    let xType : TemporalPred := ⟨char (nf_x_proj3 qnf.1)⟩
    let tType : TemporalPred := ⟨char (nf_t_proj3 qnf.1)⟩
    let epL : TemporalPred :=
      ⟨formula_conjList
        (xType.formula
          :: (allTypes.map fun χ => lit (b zPastX χ) (Formula.snce (char χ) Formula.top))
          ++ (allTypes.map fun χ => lit (b zAtX χ) (char χ)))⟩
    let epR : TemporalPred :=
      ⟨formula_conjList
        (tType.formula
          :: (allTypes.map fun χ => lit (b zAtT χ) (char χ))
          ++ (allTypes.map fun χ => lit (b zFutT χ) (Formula.untl (char χ) Formula.top)))⟩
    -- Segment types: universal exclusion of the interior-zone NEGATIVE bits.
    let segL : TemporalPred :=
      ⟨formula_conjList (allTypes.map fun χ =>
        if b zXW χ then Formula.top else (char χ).neg)⟩
    let segR : TemporalPred :=
      ⟨formula_conjList (allTypes.map fun χ =>
        if b zWT χ then Formula.top else (char χ).neg)⟩
    -- Witness point type at `w`: complete type + equality-zone bits + interior POSITIVE bits
    -- folded as Since/Until chains anchored at the endpoint types (Prop 3.5 mechanism, PDF p.5).
    let ptW : TemporalPred :=
      ⟨formula_conjList
        (char (nf_y_proj qnf.1)
          :: (allTypes.map fun χ => lit (b zAtW χ) (char χ))
          ++ (allTypes.map fun χ =>
               if b zXW χ then
                 bracketBuildLeft (BracketFormula.single ⟨char χ⟩ segL segL) xType
               else Formula.top)
          ++ (allTypes.map fun χ =>
               if b zWT χ then
                 bracketBuildRight (BracketFormula.single ⟨char χ⟩ segR segR) tType
               else Formula.top))⟩
    -- Consistency of a zone spec with the bracket order `x < w < t` (the seven real zones).
    let consistent : ZoneSpec 3 → Prop := fun zs =>
      zs = zPastX ∨ zs = zAtX ∨ zs = zXW ∨ zs = zAtW ∨ zs = zWT ∨ zs = zAtT ∨ zs = zFutT
    -- The gate Prop (Risk R2 off-fiber honesty + order-conflict falsity).
    let gate : Prop :=
      (∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false) ∧
      (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), ¬ consistent zs → b zs χ = false)
    @dite _ gate (Classical.dec gate)
      (fun _ =>
        { endpointLeft := epL
          endpointRight := epR
          bracket := BracketFormula.single ptW segL segR })
      (fun _ =>
        { endpointLeft := TemporalPred.bot
          endpointRight := TemporalPred.bot
          bracket := BracketFormula.single TemporalPred.bot TemporalPred.bot TemporalPred.bot })

/-! ## Task 311 Phase 2: k=1 gate re-probe under the E[Σ]-fold — DECISION GATE → R2 = NO-GO at
`VecEA2 1` (Risk R1 materialized; the fold itself is VINDICATED)

**Lead evidence (Def 3.1, PDF p.4 — per plan-v2 rule N3, adapted to the NO-GO outcome).**
Rabinovich's α_j/β_j are ONE-variable quantifier-free formulas: no joint multi-point atom exists,
so the arity-4 residual `[x_1,w,x,t]` that NO-GOed the OLD probe (Phase 10 record above,
:1592-1624, residual :1607-1609) has no Rabinovich counterpart — it was a Lean `nf_eval_nf`
arity-growth artifact, and the E[Σ]-fold RESTORES Def-4.1 fidelity. This re-probe CONFIRMS that:
chain steps 1-2 of the plan-v2 proof chain discharge against the landed sorry-free fold assets —
`nf_eval_nf1_iff_efold` (NfEFold:490) rewrites the k=1 evaluation into the fold form plus the
off-fiber clause, and `nf_quant_layer_fold_k1_gate` (NfEFold:525) reduces the OLD residual
verbatim to zone-bounded MONADIC existentials over `EAtomDom sig 0 3` (the "innermost fold /
iteration" reading is the **Def 4.1 p.6 note**; **Prop 4.3 (p.6)** licenses only
residual-is-∨∃∀ over E[Σ] atoms, realized locally via the fold, NOT literal structural
induction — 305 report 14). **No arity-4 object and no navigated arity-3 characteristic arises
at any step.** The old blocker is dead.

**The NEW blocker (chain step 4, interval zones — the plan-named Risk R1 surface).** The k=1
correctness target `BracketCarrierCorrect` restricted to the bracket zone (the six k0-mirror
order hypotheses on `qnf.1`) is **FALSE for the carrier above**: its LHS→RHS direction fails on
the interior-POSITIVE fold bits. The `ptW` chains (:1725-1732) encode `b zXW χ = true` as
`bracketBuildLeft (BracketFormula.single ⟨char χ⟩ segL segL) xType` at the bracket witness `w`,
but `bracketBuildLeft_correct` (VecEATranslation:503) reads `∃ z0 < w` with `xType`**-typed**
anchor `z0` — an existential over the endpoint TYPE, not the fixed endpoint `x` itself (the
two-fixed-endpoint `(z_0,z_1)` framing is **Lemma 3.2(2) (p.4) + the §5 bracket notation
`[α_0,…,α_n](z_0,z_1)` (p.7)**; **Prop 3.5 (p.5)** supplies only the ∃-witness→Until/Since
folding mechanism). The chain's χ-witness may land in `(z0, x]`, OUTSIDE `(x, w)`. Machine-
captured leaf (this dispatch, `lean_goal` on the extracted obligation): hypotheses
`z0 < w`, `xType z0`, one witness `ws 0 ∈ (z0, w)` with `char χ` — goal
`∃ u, x < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ`; the needed `x < ws 0` is underivable
(`lean_multi_attempt`: every candidate fails exactly there).

**Semantic counterexample** (dense order — this is NOT a proof-search stall): sig = one
predicate `P`; `M` = ℝ with `P ⊨ {1}`; `x = 2`, `t = 10`; `χ_P`/`χ_0` the P-true/P-false
1-types. `qnf.1` = the bracket-zone atom layer with all three point types `χ_0`. `qnf.2` =
fiber-supported bits (off-fiber false): `zPastX`: both types true (P-witness `1 < 2`); `zAtX`,
`zAtW`, `zAtT`: `χ_0` true, `χ_P` false; `zXW`: `χ_0` true, **`χ_P` true — the unrealizable
bit**; `zWT`, `zFutT`: `χ_0` true, `χ_P` false; inconsistent zones false. Both gate conjuncts
hold, so the carrier is the real (non-⊥) branch. LHS holds at `(2, 10)`: bracket witness
`w = 5`; the `zXW`-positive chain for `χ_P` anchors at `z0 = 0` (type `χ_0 = xType`) and
absorbs `u = 1 ∈ (0, 5)` — outside `(x, w) = (2, 5)`; `segL ≡ ⊤` (both `zXW` bits positive),
`segR` = `¬char χ_P`, true on `(5, 10)`; all endpoint literals check. RHS is FALSE for EVERY
`w`: the atom layer forces `2 < w < 10`, and the fold quant-layer biconditional at
`(zXW, χ_P)` demands a P-point in `(2, w)` — but `P ∩ (2, ∞) = ∅`. Hence
`(bracketEndChar_k1 … qnf).holds M atomMap x t` holds while
`∃ w, nf_eval_nf M 1 3 [w,x,t] qnf` fails. (Checked by hand against `IntervalPattern.holds`,
`temporal_truth`, `nf_eval_efold`, `nf_quant_layer_fold_iff` this dispatch.)

**Isolation — why this is a `VecEA2 1` SHAPE limit, not a fixable proof gap.** A
`BracketFormula 1` has exactly ONE interior witness slot (`w`). Each interior-positive
`(zone, χ)` bit is an ADDITIONAL existential strictly inside `(x,w)` / `(w,t)`; per
**Lemma 3.4 (p.5)** its witness must JOIN the bracket's existential prefix — witness-count
growth, which is exactly what `BracketFormula.existsBounded_right` (VecEAClosure:265)
implements: its conclusion is `∃ m, ∃ bf' : BracketFormula m, …` (n → n+2 witnesses). Nothing
with the carrier's FIXED `BracketFormula 1` output can consume it, and no monadic temporal
formula at `w` (or at a type-anchored `z0`) can pin a witness strictly inside `(x, w)`, because
monadic point types cannot separate points `≤ x` from points in `(x, w)` — the counterexample
exploits precisely this. Note the defect is ONE-directional: the RHS→LHS direction of the k=1
instance IS dischargeable for this carrier (take `z0 := x`; interior points all carry
positive-bit types, so the segment exclusions hold) — the carrier is sound but under-
constraining, so the correctness `↔` fails.

**Escalation (Risk R1 fence, plan v2 Rollback #2; audit caveat C3).** Per the fence this is a
G6-SHAPE decision, NOT an implementer call: the carrier codomain is left UNCHANGED, no third
anchor is introduced, `bracketEndChar_k1` above stays intact, sorry-free, and OFF the live path
(nothing imports/wires it). The Rabinovich-faithful fix direction for the orchestrator /
`/revise 311`: anchors stay `{x, t}` (Lemma 3.2(2) caps ANCHORS at ≤2 — audit Red Flag C:
witness-count growth under ∃-closure is licensed, anchor-count growth is not), while the
bracket carries the interior-positive witnesses ALONGSIDE `w` — i.e. a carrier codomain of
`VVecEA2` / `Σ n, VecEA2 n` (the §5 bracket `[α_0,…,α_n](z_0,z_1)`, p.7, has n witnesses),
with `BracketFormula.existsBounded_right` as the assembly vehicle. Chain steps 1-3 and 5
(fold bridge, gate corollary, atom-layer kit, off-fiber gate) are UNAFFECTED by the codomain
change. Per the DECISION-GATE contract no partial correctness theorem and no `sorry` is
landed for the k=1 instance. -/

/-! ## Task 311 Phase 3: witness-growing carrier type + k=1 V-carrier (G6 as amended, plan v3)

**G6 amendment record.** The carrier SHAPE is unchanged: the recursion carrier stays the
two-anchor bracket characteristic with FIXED endpoints `z_0 = x`, `z_1 = t`, interior points as
bracket WITNESSES — never an arity-1 navigated point characteristic, never an
interior-existential-witness evaluation, never a third free anchor (G1/G2/G4 intact). ONLY the
codomain is amended: `VecEA2 1` (one interior witness slot) → witness-growing `VecEA2 n`,
assembled as a `VVecEA2` finite disjunction (VecEAFormula:271). Justification: the R2 = NO-GO
refutation above (:1782-1796) — a `BracketFormula 1` cannot host the interior-positive
`(zone, χ)` witnesses, and no monadic point type separates points `≤ x` from points in `(x, w)`.
Rabinovich licenses for witness growth (anchors capped, witnesses not):

- **Lemma 3.2(2) (PDF p.4)** caps ANCHORS (free variables) at ≤2; it says nothing capping
  bracket witnesses.
- The **§5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7)** carries `n` witnesses between
  the two FIXED endpoints — witness growth is the printed shape of the bracket.
- **Lemma 3.4 (PDF p.5)** (∨∃∀ closed under ∃): each absorbed existential JOINS the existential
  prefix as a witness (`BracketFormula.existsBounded_right`, VecEAClosure:265, is the vehicle).

Citation split (rule N1): the two-fixed-endpoint `(z_0, z_1)` framing is **Lemma 3.2(2) (p.4) +
the §5 bracket notation (p.7)**; **Prop 3.5 (p.5)** is cited ONLY for the one-free-variable
∃-witness→Until/Since folding mechanism. -/

/-- **Witness-growing two-anchor bracket carrier type** (task 311 Phase 3; G6 as amended).
Parallel V-variant of `BracketEndCharCarrier` (:1542, which stays untouched): the codomain is the
finite disjunction `VVecEA2` of `Σ n, VecEA2 n` disjuncts (VecEAFormula:271), so each disjunct
may carry `n` bracket witnesses between the two FIXED endpoints — the §5 bracket
`[α_0, …, α_n](z_0, z_1)` (PDF p.7). Every disjunct's `holds` stays at the two-point signature
(VecEAFormula:276), so Lemma 3.2(2)'s ≤2-anchor cap (PDF p.4) remains a TYPE-level invariant:
witness growth is licensed, anchor growth is not (G2/G4). -/
abbrev BracketEndCharCarrierV (sig : MonadicSignature) (k : Nat) : Type :=
  NormalForm sig k 3 → VVecEA2

/-- **Fixed-endpoint correctness for the witness-growing carrier** (task 311 Phase 3). V-variant
of `BracketCarrierCorrect` (:1552, untouched): the carrier's `VVecEA2.holds` at the fixed anchor
pair `(x, t)` is equivalent to the existence of a **bracket witness** `w` realizing the arity-3
depth-`k` evaluation `nf_eval_nf M k 3 [w, x, t] qnf`. `{x, t}` are the FIXED endpoints
(Lemma 3.2(2), PDF p.4 + §5 bracket notation, PDF p.7 — rule N1 split); `w` is a bracket witness,
now one among the disjunct's `n` witnesses (G4, G6 as amended). -/
def BracketCarrierCorrectV {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    {k : Nat} (carrier : BracketEndCharCarrierV sig k) : Prop :=
  ∀ (qnf : NormalForm sig k 3) (x t : M.carrier),
    (carrier qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-- Assemble a `BracketFormula` from an ordered left witness-type list, the middle `w` point
type, and an ordered right witness-type list (disjunct builder factored into a named `private
def` per Risk R6). Point types are the left list, then the `w` slot at position `lL.length`,
then the right list — the §5 bracket `[α_0, …, α_n](z_0, z_1)` (PDF p.7) with `z_0, z_1` the
FIXED endpoints. Segment types are `segL` on every segment left of the `w` slot (the
sub-segments of `(x, w)`) and `segR` on every segment right of it (the sub-segments of
`(w, t)`) — real exclusion segments, never top (G3). -/
def bracketFromLists (lL : List TemporalPred) (ptW : TemporalPred)
    (lR : List TemporalPred) (segL segR : TemporalPred) :
    BracketFormula (lL.length + 1 + lR.length) where
  pointTypes := fun i =>
    (lL ++ ptW :: lR)[i.val]'(by
      simp only [List.length_append, List.length_cons]; omega)
  segmentTypes := fun i => if i.val ≤ lL.length then segL else segR

/-- **k=1 witness-growing two-anchor fold carrier** (task 311 Phase 3; G6 as amended by the
plan-v3 amendment record above).

Encodes a depth-1 arity-3 `qnf : NormalForm sig 1 3` as a `VVecEA2` at the two FIXED endpoints
`{x, t}`: the interior-positive `(zone, χ)` fold bits become bracket WITNESSES ordered between
the fixed endpoints, alongside `w` (rule N4: interior-positive content as bracket witnesses
anchored between the FIXED endpoints; the type-anchored `bracketBuildLeft`/`bracketBuildRight`
chains of `bracketEndChar_k1` (:1725-1732) were REFUTED at :1782-1796 and are REMOVED here —
they survive only in the `epL`/`epR` exterior-zone literals, where the anchor genuinely IS the
fixed endpoint). Citation split (rule N1): the two-fixed-endpoint framing is **Lemma 3.2(2)
(PDF p.4) + the §5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7)**; **Prop 3.5 (PDF
p.5)** is cited ONLY for the ∃-witness→Until/Since folding mechanism (the Since/Until literals
in `epL`/`epR`).

Construction — every read of `qnf.2` goes through `efold_of_nf1` (NfEFold:472; the Def-4.1
monadic-atom fold, PDF p.5, read at depth 1 per the **Def 4.1 p.6 note** on iterated folds); no
arity-4 evaluation occurs:

- **Building blocks** are the Phase-1 blocks of `bracketEndChar_k1` (:1676-1739) verbatim: fold
  bits `b`, the seven zone specs, `char`, `lit`, endpoint preds `epL`/`epR`, segment exclusions
  `segL`/`segR`, and the two-conjunct gate (off-fiber falsity + order-conflict falsity).
- **Witness point type at `w`**: the complete type `char (nf_y_proj qnf.1)` plus the zAtW
  biconditional literals ONLY — no interior chains (rule N4).
- **Disjuncts** (rule N5 — Rabinovich's ∨ over consistent order types, Def 3.1 pp.4-5): the
  interior-positive enumerations `S_L` (zone `(x, w)`) and `S_R` (zone `(w, t)`) are
  duplicate-free lists of complete 1-types; for each arrangement
  `(lL, lR) ∈ S_L.permutations × S_R.permutations` there is one disjunct with
  `lL.length + 1 + lR.length` witnesses: `epL`/`epR` at the fixed endpoints, point types = the
  `char`s of `lL`, then the `w` point type, then the `char`s of `lR` (each interior-positive
  pair occupies a WITNESS slot — §5 bracket, PDF p.7; its witness JOINS the existential prefix —
  Lemma 3.4, PDF p.5), segment types `segL` left of the `w` slot and `segR` right of it. The
  model-dependent witness ORDER is carried by the finite disjunction over arrangements, never by
  a fixed-order assertion (rule N5); same-type multiplicity is not encoded (fold bits are
  existential — one witness per positive pair).
- **Gate-failure branch**: the empty disjunction `⟨[]⟩` (its `holds` is `False`) — Rabinovich's
  empty disjunction over inconsistent order types. -/
noncomputable def bracketEndChar_k1v {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    BracketEndCharCarrierV sig 1 :=
  fun qnf =>
    -- Fold bits (Def 4.1, PDF p.5): the ONLY channel through which `qnf.2` is read.
    let b : ZoneSpec 3 → NormalForm sig 0 1 → Bool :=
      fun zs χ => (efold_of_nf1 qnf).2 (zs, χ)
    -- Zone-spec constants relative to env `[w, x, t]` under the bracket order `x < w < t`
    -- (Def 3.1 ordering channel, PDF p.4), verbatim from `bracketEndChar_k1` (:1679-1692).
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
    -- Complete depth-0 monadic point types: the TL side of the fold's E-atoms.
    let char : NormalForm sig 0 1 → Formula := nf_depth0_char_formula atomMap h_surj
    let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
    -- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5).
    let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
    -- Endpoint types (the FIXED `z_0 = x`, `z_1 = t`: Lemma 3.2(2) PDF p.4 + §5 bracket PDF p.7).
    let xType : TemporalPred := ⟨char (nf_x_proj3 qnf.1)⟩
    let tType : TemporalPred := ⟨char (nf_t_proj3 qnf.1)⟩
    let epL : TemporalPred :=
      ⟨formula_conjList
        (xType.formula
          :: (allTypes.map fun χ => lit (b zPastX χ) (Formula.snce (char χ) Formula.top))
          ++ (allTypes.map fun χ => lit (b zAtX χ) (char χ)))⟩
    let epR : TemporalPred :=
      ⟨formula_conjList
        (tType.formula
          :: (allTypes.map fun χ => lit (b zAtT χ) (char χ))
          ++ (allTypes.map fun χ => lit (b zFutT χ) (Formula.untl (char χ) Formula.top)))⟩
    -- Segment types: universal exclusion of the interior-zone NEGATIVE bits.
    let segL : TemporalPred :=
      ⟨formula_conjList (allTypes.map fun χ =>
        if b zXW χ then Formula.top else (char χ).neg)⟩
    let segR : TemporalPred :=
      ⟨formula_conjList (allTypes.map fun χ =>
        if b zWT χ then Formula.top else (char χ).neg)⟩
    -- Witness point type at `w`: complete type + equality-zone bits ONLY (rule N4 — the
    -- interior-positive chains of :1725-1732 are the refuted device and are REMOVED; the
    -- interior-positive content rides the witness slots below instead).
    let ptW : TemporalPred :=
      ⟨formula_conjList
        (char (nf_y_proj qnf.1)
          :: (allTypes.map fun χ => lit (b zAtW χ) (char χ)))⟩
    -- Consistency of a zone spec with the bracket order `x < w < t` (the seven real zones).
    let consistent : ZoneSpec 3 → Prop := fun zs =>
      zs = zPastX ∨ zs = zAtX ∨ zs = zXW ∨ zs = zAtW ∨ zs = zWT ∨ zs = zAtT ∨ zs = zFutT
    -- The gate Prop (off-fiber honesty + order-conflict falsity), verbatim from :1737-1739.
    let gate : Prop :=
      (∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false) ∧
      (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), ¬ consistent zs → b zs χ = false)
    -- Interior-positive enumerations (duplicate-free: `Finset.univ.toList`).
    let S_L : List (NormalForm sig 0 1) := allTypes.filter (fun χ => b zXW χ)
    let S_R : List (NormalForm sig 0 1) := allTypes.filter (fun χ => b zWT χ)
    let charP : NormalForm sig 0 1 → TemporalPred := fun χ => ⟨char χ⟩
    -- One disjunct per arrangement (rule N5): interior-positive pairs occupy WITNESS slots
    -- ordered between the fixed endpoints (§5 bracket, PDF p.7; Lemma 3.4, PDF p.5).
    let mkDisjunct : List (NormalForm sig 0 1) → List (NormalForm sig 0 1) → Σ n, VecEA2 n :=
      fun lL lR =>
        ⟨(lL.map charP).length + 1 + (lR.map charP).length,
          { endpointLeft := epL
            endpointRight := epR
            bracket := bracketFromLists (lL.map charP) ptW (lR.map charP) segL segR }⟩
    @dite _ gate (Classical.dec gate)
      (fun _ =>
        { disjuncts :=
            S_L.permutations.flatMap fun lL =>
              S_R.permutations.map fun lR => mkDisjunct lL lR })
      (fun _ => { disjuncts := [] })

/-! ## Task 311 Phase 4: soundness direction (LHS→RHS) for the V-carrier — helper kit

Private helper kit for `bracketEndChar_k1v_sound` (pre-authorized 4.1/4.2 split, plan v3
Phase 4 H8 escape hatch). Chain citations (rule N1 split): the two-fixed-endpoint `(z_0, z_1)`
bracket framing is **Lemma 3.2(2) (PDF p.4) + §5 bracket notation (PDF p.7)**; **Prop 3.5
(PDF p.5)** is cited ONLY for the ∃-witness→Until/Since folding mechanism. Per rule N2, the
gate-corollary rewrite in 4.2 cites the **Def 4.1 p.6 note** (innermost fold) and **Prop 4.3
(p.6)** only for "the residual is ∨∃∀ over E[Σ] atoms" (realized locally via the fold —
305 report 14). -/

/-- Bool helper: a bit is forced `false` through its semantic biconditional when the
    semantic side fails. -/
theorem k1v_bool_eq_false {b : Bool} {p : Prop} (h : p ↔ b = true) (hp : ¬p) :
    b = false := by
  cases hb : b
  · rfl
  · exact absurd (h.mpr hb) hp

/-- `zoneHolds` over the bracket env `[w, x, t]` at a pointwise `Fin.cons` zone spec,
    unfolded to its three coordinate biconditionals (Def 3.1 ordering channel, PDF p.4:
    the only channel through which the quantified witness meets the fixed env points). -/
private theorem k1v_zoneHolds_cons_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (w x t u : M.carrier) (pw px pt : Bool × Bool) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons pw (Fin.cons px (fun _ => pt)) : ZoneSpec 3) u ↔
    (((u < w) ↔ pw.1 = true) ∧ ((w < u) ↔ pw.2 = true)) ∧
    (((u < x) ↔ px.1 = true) ∧ ((x < u) ↔ px.2 = true)) ∧
    (((u < t) ↔ pt.1 = true) ∧ ((t < u) ↔ pt.2 = true)) := by
  constructor
  · intro h
    have h0 := h ⟨0, by omega⟩
    have h1 := h ⟨1, by omega⟩
    have h2 := h ⟨2, by omega⟩
    simp only [Fin.cons] at h0 h1 h2
    exact ⟨h0, h1, h2⟩
  · rintro ⟨h0, h1, h2⟩ i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using h0
    | ⟨1, _⟩ => simpa only [Fin.cons] using h1
    | ⟨2, _⟩ => simpa only [Fin.cons] using h2

/-- Any zone spec realized by a point over the bracket env `[w, x, t]` with `x < w < t` is
    one of the seven order-consistent zones (Def 3.1, PDF pp.4-5: disjunctions range only
    over consistent order types). The contrapositive discharges the inconsistent-zone fold
    bits against gate conjunct (ii) in the soundness direction. -/
private theorem k1v_zone_consistent {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (w x t u : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (zs : ZoneSpec 3)
    (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u) :
    zs = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))) ∨
    zs = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))) ∨
    zs = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
    zs = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))) := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  simp only [Fin.cons] at h0 h1 h2
  -- Build the pointwise equality from the three coordinate pairs.
  have hzs : ∀ (pw px pt : Bool × Bool),
      zs ⟨0, by omega⟩ = pw → zs ⟨1, by omega⟩ = px → zs ⟨2, by omega⟩ = pt →
      zs = Fin.cons pw (Fin.cons px (fun _ => pt)) := by
    intro pw px pt e0 e1 e2
    funext i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using e0
    | ⟨1, _⟩ => simpa only [Fin.cons] using e1
    | ⟨2, _⟩ => simpa only [Fin.cons] using e2
  have hxt : x < t := hxw.trans hwt
  rcases lt_trichotomy u x with hux | hux | hux
  · -- u < x: zone zPastX
    have huw : u < w := hux.trans hxw
    have hut : u < t := huw.trans hwt
    exact Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hux, k1v_bool_eq_false h1.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))
  · -- u = x: zone zAtX
    subst hux
    exact Or.inr (Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hxw, k1v_bool_eq_false h0.2 (lt_asymm hxw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
        k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hxt, k1v_bool_eq_false h2.2 (lt_asymm hxt)⟩)))
  · -- x < u: split against w
    rcases lt_trichotomy u w with huw | huw | huw
    · -- x < u < w: zone zXW
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))
    · -- u = w: zone zAtW
      subst huw
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
          k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hwt, k1v_bool_eq_false h2.2 (lt_asymm hwt)⟩)))))
    · -- w < u: split against t
      rcases lt_trichotomy u t with hut | hut | hut
      · -- w < u < t: zone zWT
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))))
      · -- u = t: zone zAtT
        subst hut
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl u),
            k1v_bool_eq_false h2.2 (lt_irrefl u)⟩)))))))
      · -- t < u: zone zFutT
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hut), h2.2.mp hut⟩)))))))

/-- Extraction for `bracketFromLists` (§5 bracket `[α_0, …, α_n](z_0, z_1)`, PDF p.7): from
    its `holds` at `(x, t)` obtain the middle witness `w` (bracket position `lL.length`),
    the realization of every left/right point type strictly inside `(x, w)` / `(w, t)`, and
    the gap classification: every point of `(x, w)` (resp. `(w, t)`) either carries a left
    (resp. right) point type or satisfies the `segL` (resp. `segR`) exclusion segment. This
    is the counterexample-defect fix of rule N4: witnesses are pinned strictly between the
    FIXED endpoints by `IntervalPattern.holds` monotonicity (never type-anchored — the
    refuted device of :1782-1796). -/
private theorem k1v_bracket_extract {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lL lR : List TemporalPred) (ptW segL segR : TemporalPred)
    (x t : M.carrier)
    (h : (bracketFromLists lL ptW lR segL segR).holds M atomMap x t) :
    ∃ w : M.carrier, x < w ∧ w < t ∧
      ptW.eval_at M atomMap w ∧
      (∀ p ∈ lL, ∃ u, x < u ∧ u < w ∧ p.eval_at M atomMap u) ∧
      (∀ p ∈ lR, ∃ u, w < u ∧ u < t ∧ p.eval_at M atomMap u) ∧
      (∀ u, x < u → u < w →
        segL.eval_at M atomMap u ∨ ∃ p ∈ lL, p.eval_at M atomMap u) ∧
      (∀ u, w < u → u < t →
        segR.eval_at M atomMap u ∨ ∃ p ∈ lR, p.eval_at M atomMap u) := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, bracketFromLists] at h
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show lL.length + 1 + lR.length = (lL.length + lR.length) + 1 by omega)] at h
  obtain ⟨ws, hmono, hrange, hpt, hseg0, hsegmid, hseglast⟩ := h
  -- Nat-indexed views of the point-type and range facts (proof-irrelevant reindexing).
  have hpt' : ∀ (i : Nat) (hi : i < lL.length + lR.length + 1),
      ((lL ++ ptW :: lR)[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
  refine ⟨ws ⟨lL.length, by omega⟩,
    (hrange ⟨lL.length, by omega⟩).1, (hrange ⟨lL.length, by omega⟩).2, ?_, ?_, ?_, ?_, ?_⟩
  · -- The middle point type is `ptW`: index `lL.length` in `lL ++ ptW :: lR`.
    have helem : (lL ++ ptW :: lR)[lL.length]'(by
        simp only [List.length_append, List.length_cons]; omega) = ptW := by
      rw [List.getElem_append_right (Nat.le_refl _)]
      simp
    have := hpt' lL.length (by omega)
    rwa [helem] at this
  · -- Every left point type is realized strictly inside `(x, w)`.
    intro p hp
    obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hp
    refine ⟨ws ⟨j, by omega⟩, (hrange ⟨j, by omega⟩).1,
      hmono ⟨j, by omega⟩ ⟨lL.length, by omega⟩ (Fin.mk_lt_mk.mpr hj), ?_⟩
    have := hpt' j (by omega)
    rwa [List.getElem_append_left hj] at this
  · -- Every right point type is realized strictly inside `(w, t)`.
    intro p hp
    obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hp
    refine ⟨ws ⟨lL.length + 1 + j, by omega⟩,
      hmono ⟨lL.length, by omega⟩ ⟨lL.length + 1 + j, by omega⟩
        (Fin.mk_lt_mk.mpr (by omega)),
      (hrange ⟨lL.length + 1 + j, by omega⟩).2, ?_⟩
    have helem : (lL ++ ptW :: lR)[lL.length + 1 + j]'(by
        simp only [List.length_append, List.length_cons]; omega) = lR[j]'hj := by
      rw [List.getElem_append_right (by omega)]
      simp only [show lL.length + 1 + j - lL.length = j + 1 by omega,
        List.getElem_cons_succ]
    have := hpt' (lL.length + 1 + j) (by omega)
    rwa [helem] at this
  · -- Gap classification on `(x, w)`: witness slot or `segL`.
    intro u hxu huw
    have main : ∀ j (hj : j ≤ lL.length), u < ws ⟨j, by omega⟩ →
        segL.eval_at M atomMap u ∨ ∃ p ∈ lL, p.eval_at M atomMap u := by
      intro j
      induction j with
      | zero =>
        intro _ hu0
        left
        have := hseg0 u hxu hu0
        rwa [if_pos (Nat.zero_le lL.length)] at this
      | succ j ih =>
        intro hj hu
        rcases lt_trichotomy u (ws ⟨j, by omega⟩) with h' | h' | h'
        · exact ih (by omega) h'
        · -- `u` IS witness `j` (with `j < lL.length`): it carries `lL[j]`.
          right
          have hptj := hpt' j (by omega)
          rw [List.getElem_append_left (by omega)] at hptj
          exact ⟨lL[j]'(by omega), List.getElem_mem _, by rw [h']; exact hptj⟩
        · -- `ws j < u < ws (j+1)`: interior segment `j + 1 ≤ lL.length` carries `segL`.
          left
          have := hsegmid ⟨j, by omega⟩ u h' hu
          rwa [if_pos hj] at this
    exact main lL.length (Nat.le_refl _) huw
  · -- Gap classification on `(w, t)`: witness slot or `segR`.
    intro u hwu hut
    have main : ∀ d j (hj : lL.length ≤ j) (hj2 : j + d = lL.length + lR.length),
        ws ⟨j, by omega⟩ < u →
        segR.eval_at M atomMap u ∨ ∃ p ∈ lR, p.eval_at M atomMap u := by
      intro d
      induction d with
      | zero =>
        intro j hj hj2 hju
        have hjeq : j = lL.length + lR.length := by omega
        subst hjeq
        left
        have := hseglast u hju hut
        rwa [if_neg (show ¬(lL.length + lR.length + 1 ≤ lL.length) by omega)] at this
      | succ d ih =>
        intro j hj hj2 hju
        rcases lt_trichotomy u (ws ⟨j + 1, by omega⟩) with h' | h' | h'
        · -- `ws j < u < ws (j+1)` with `j ≥ lL.length`: segment `j+1 > lL.length` is `segR`.
          left
          have := hsegmid ⟨j, by omega⟩ u hju h'
          rwa [if_neg (show ¬(j + 1 ≤ lL.length) by omega)] at this
        · -- `u` IS witness `j + 1` (with `j + 1 > lL.length`): it carries `lR[j - lL.length]`.
          right
          have hptj := hpt' (j + 1) (by omega)
          have helem : (lL ++ ptW :: lR)[j + 1]'(by
              simp only [List.length_append, List.length_cons]; omega) =
              lR[j - lL.length]'(by omega) := by
            rw [List.getElem_append_right (by omega)]
            simp only [show j + 1 - lL.length = (j - lL.length) + 1 by omega,
              List.getElem_cons_succ]
          rw [helem] at hptj
          exact ⟨lR[j - lL.length]'(by omega), List.getElem_mem _, by rw [h']; exact hptj⟩
        · exact ih (j + 1) (by omega) (by omega) h'
    exact main lR.length lL.length (Nat.le_refl _) rfl hwu

/-- **Order-preserving outer extraction** (task 326 Phase 1; strengthens `k1v_bracket_extract`
    :2150, which forgets the witness ordering). From `(bracketFromLists lL ptW lR segL segR).holds`
    at the FIXED endpoints `(x, t)`, recover the FULL strictly-increasing witness sequence
    `ws : Fin (lL.length + 1 + lR.length) → M.carrier` realizing the concatenated point-type list
    `lL ++ ptW :: lR` in order, every witness pinned in `(x, t)`. This exposes the monotone `ws`
    that lives inside `IntervalPattern.holds` (surfaced by `bracket_implies_fChainPred`
    `EANegation.lean:670`) but that `k1v_bracket_extract`'s per-element existential discards — the
    ordering later phases need to place pin witnesses strictly ABOVE the interior sub-chain points.

    Rabinovich 2014 **Lemma 5.1** (md:169-171): the shared-endpoint point-insertion bound is carried
    STRUCTURALLY by slot position; the monotone `ws` is the order-preservation that makes the
    structural (slot-position) bound faithful, never a formula literal (litmus PASS). -/
theorem k1v_bracket_extract_mono {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lL lR : List TemporalPred) (ptW segL segR : TemporalPred)
    (x t : M.carrier)
    (h : (bracketFromLists lL ptW lR segL segR).holds M atomMap x t) :
    ∃ ws : Fin (lL.length + 1 + lR.length) → M.carrier,
      (∀ i j : Fin (lL.length + 1 + lR.length), i < j → ws i < ws j) ∧
      (∀ i : Fin (lL.length + 1 + lR.length), x < ws i ∧ ws i < t) ∧
      (∀ i : Fin (lL.length + 1 + lR.length),
        ((lL ++ ptW :: lR)[i.val]'(by
          simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap (ws i)) := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, bracketFromLists] at h
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show lL.length + 1 + lR.length = (lL.length + lR.length) + 1 by omega)] at h
  obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩ := h
  refine ⟨fun i => ws ⟨i.val, by omega⟩, ?_, ?_, ?_⟩
  · intro i j hij
    exact hmono ⟨i.val, by omega⟩ ⟨j.val, by omega⟩ (Fin.mk_lt_mk.mpr (Fin.lt_def.mp hij))
  · intro i
    exact hrange ⟨i.val, by omega⟩
  · intro i
    exact hpt ⟨i.val, by omega⟩

/-- Pure `List.getElem` fact: the middle block `B` of a left-associated triple append
    `(A ++ B) ++ C` occupies the contiguous index range `[A.length, A.length + B.length)`.
    Used (task 326 Phase 1) to thread σ-block contiguity through the outer `flatMap` indexing. -/
theorem getElem_append3_mid {α : Type*} (A B C : List α) (j : Nat) (hj : j < B.length) :
    ((A ++ B) ++ C)[A.length + j]'(by
      simp only [List.length_append]; omega) = B[j]'hj := by
  rw [List.getElem_append_left (show A.length + j < (A ++ B).length by
        simp only [List.length_append]; omega),
      List.getElem_append_right (Nat.le_add_right A.length j)]
  simp only [Nat.add_sub_cancel_left]

/-- **σ-block contiguity through the outer `flatMap`** (task 326 Phase 1). For a bracket whose
    left witness list is `l.flatMap (fun b => head b :: tail b)` — the shape of the `kvE2_body`
    outer carrier `slotsFor lL = lL.flatMap (fun σ => ptSub σ :: pinSlots σ)` (`:5476`) — and an
    element `a ∈ l`, the order-preserving extraction (`k1v_bracket_extract_mono`) places `a`'s
    whole block strictly-increasing and strictly below the middle witness `w_outer`, with the block
    HEAD (`head a` — the interior sub-chain point type `ptSub σ = kvE_subChain2V σ`) realized
    STRICTLY BELOW every block-TAIL witness (`tail a` — the pin slots `pinSlots σ`). This is the
    "pins are above the fChainPred F_0 point, both below `w_outer`" ordering that later phases
    consume for free: the bound `q < w_outer < t` rides the pin's STRUCTURAL slot position in the
    contiguous block, never a formula literal (litmus PASS).

    Rabinovich 2014 **Lemma 5.1** (md:169-171): the shared-endpoint (`w_outer`) point-insertion
    bound is carried structurally; the monotone block ordering is the faithful order-preservation
    that makes the pin's slot-position bound sound. -/
private theorem bracketFromLists_flatMap_block_extract {sig : MonadicSignature} {α : Type*}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l : List α) (head : α → TemporalPred) (tail : α → List TemporalPred)
    (ptW segL segR : TemporalPred) (lR : List TemporalPred)
    (x t : M.carrier) (a : α) (ha : a ∈ l)
    (h : (bracketFromLists (l.flatMap (fun b => head b :: tail b)) ptW lR segL segR).holds
          M atomMap x t) :
    ∃ w_outer u : M.carrier,
      x < w_outer ∧ w_outer < t ∧ ptW.eval_at M atomMap w_outer ∧
      x < u ∧ u < w_outer ∧ (head a).eval_at M atomMap u ∧
      (∀ p ∈ tail a, ∃ q : M.carrier, u < q ∧ q < w_outer ∧ p.eval_at M atomMap q) := by
  obtain ⟨pre, post, hl⟩ := List.append_of_mem ha
  set fB : α → List TemporalPred := fun b => head b :: tail b with hfB
  have heq : l.flatMap fB = (pre.flatMap fB ++ fB a) ++ post.flatMap fB := by
    rw [hl, List.flatMap_append, List.flatMap_cons, ← List.append_assoc]
  rw [heq] at h
  set pref := pre.flatMap fB with hpref
  set suff := post.flatMap fB with hsuff
  obtain ⟨ws, hmono, hrange, hpt⟩ :=
    k1v_bracket_extract_mono M atomMap ((pref ++ fB a) ++ suff) lR ptW segL segR x t h
  have hfa_pos : 0 < (fB a).length := by rw [hfB]; simp
  have hLLlen : ((pref ++ fB a) ++ suff).length
      = pref.length + (fB a).length + suff.length := by
    simp only [List.length_append]
  refine ⟨ws ⟨((pref ++ fB a) ++ suff).length, by omega⟩,
          ws ⟨pref.length, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact (hrange _).1
  · exact (hrange _).2
  · -- ptW @ w_outer : point type at index `lL.length` is `ptW`.
    have hpm := hpt ⟨((pref ++ fB a) ++ suff).length, by omega⟩
    have helem_mid : (((pref ++ fB a) ++ suff) ++ ptW :: lR)[((pref ++ fB a) ++ suff).length]'(by
        simp only [List.length_append, List.length_cons]; omega) = ptW := by
      rw [List.getElem_append_right (Nat.le_refl _)]
      simp
    rw [helem_mid] at hpm
    exact hpm
  · exact (hrange _).1
  · exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
  · -- head a @ u : point type at block base `pref.length` is `(fB a)[0] = head a`.
    have hpb := hpt ⟨pref.length, by omega⟩
    have helem_head : (((pref ++ fB a) ++ suff) ++ ptW :: lR)[pref.length]'(by
        simp only [List.length_append, List.length_cons]; omega) = head a := by
      rw [List.getElem_append_left (show pref.length < ((pref ++ fB a) ++ suff).length by
            simp only [List.length_append]; omega),
          List.getElem_append_left (show pref.length < (pref ++ fB a).length by
            simp only [List.length_append]; omega),
          List.getElem_append_right (Nat.le_refl _)]
      simp [hfB]
    rw [helem_head] at hpb
    exact hpb
  · -- pins: each `p ∈ tail a` sits strictly above `u` and strictly below `w_outer`.
    intro p hp
    obtain ⟨j, hj, hpj⟩ := List.mem_iff_getElem.mp hp
    have hj1 : j + 1 < (fB a).length := by rw [hfB]; simpa using hj
    refine ⟨ws ⟨pref.length + (j + 1), by omega⟩, ?_, ?_, ?_⟩
    · exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
    · exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
    · have hpq := hpt ⟨pref.length + (j + 1), by omega⟩
      have helem_pin : (((pref ++ fB a) ++ suff) ++ ptW :: lR)[pref.length + (j + 1)]'(by
          simp only [List.length_append, List.length_cons]; omega) = p := by
        rw [List.getElem_append_left (show pref.length + (j + 1) < ((pref ++ fB a) ++ suff).length by
              simp only [List.length_append]; omega),
            getElem_append3_mid pref (fB a) suff (j + 1) hj1]
        simp only [hfB, List.getElem_cons_succ]
        exact hpj
      rw [helem_pin] at hpq
      exact hpq

/-- **Bounded anchor from the first pin slot** (task 326 Phase 2). Consuming the σ-block
    contiguity extraction `bracketFromLists_flatMap_block_extract` (Phase 1), select the
    designated pin `p0 ∈ tail a` and produce a witness `q` realizing it, STRUCTURALLY bounded
    `x < q < w_outer < t`. The bound `q < w_outer` rides the pin's slot position within the
    contiguous block (the monotone `ws` sequence), NEVER an `x1 < e_i` relative-position formula
    literal (litmus PASS: `hx1t := q < t` traces to `hqw : q < w_outer` (slot monotonicity) and
    `hwt : w_outer < t` (Phase 1), not a literal). At the k=2 gate this is instantiated with
    `head := ptSub`, `tail := pinSlots`, `a := σ`, and `p0` the head pin `⟨charK (nfk_projFresh σ)⟩`
    of `pinSlots σ` (:5601), giving `hanchor = (⟨charK (nfk_projFresh σ)⟩).eval_at q` and
    `hx1t = q < t` directly (no reverse Cor 5.4, no third anchor: `w_outer` stays a witness).

    Rabinovich 2014 **Lemma 5.1** (md:169-171): the shared-endpoint (`w_outer`) point-insertion
    bound is carried structurally by the pin's slot position, faithful under the order-preserving
    realization of the bracket's own interval decomposition. -/
private theorem bracketFromLists_flatMap_first_pin_anchor {sig : MonadicSignature} {α : Type*}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l : List α) (head : α → TemporalPred) (tail : α → List TemporalPred)
    (ptW segL segR : TemporalPred) (lR : List TemporalPred)
    (x t : M.carrier) (a : α) (ha : a ∈ l)
    (p0 : TemporalPred) (hp0 : p0 ∈ tail a)
    (h : (bracketFromLists (l.flatMap (fun b => head b :: tail b)) ptW lR segL segR).holds
          M atomMap x t) :
    ∃ w_outer q : M.carrier,
      x < q ∧ q < w_outer ∧ w_outer < t ∧ p0.eval_at M atomMap q := by
  obtain ⟨w_outer, u, _hxw, hwt, _hptW, hxu, _huw, _hhead, hpins⟩ :=
    bracketFromLists_flatMap_block_extract M atomMap l head tail ptW segL segR lR x t a ha h
  obtain ⟨q, huq, hqw, hpq⟩ := hpins p0 hp0
  exact ⟨w_outer, q, lt_trans hxu huq, hqw, hwt, hpq⟩

/-- Reconstruct the arity-3 depth-0 atom layer at env `[w, x, t]` from the three arity-1
    point evaluations and the six order biconditionals. Private clone of the VecEADecomp
    reconstruction helper (that lemma is `private` there and not importable). Chain step 3
    of the soundness direction: the endpoint/witness point types plus the k0-mirror order
    hypotheses assemble the atom layer (two-fixed-endpoint framing per **Lemma 3.2(2) PDF
    p.4 + §5 bracket PDF p.7**, rule N1). -/
private theorem k1v_reconstruct_nf3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_y_nf : nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn))
    (h_x_nf : nf_eval_nf M 0 1 (fun _ => x) (nf_x_proj3 ssn))
    (h_t_nf : nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj3 ssn))
    (h_o_yx : (y < x) ↔ (ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true))
    (h_o_yt : (y < t) ↔ (ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true))
    (h_o_xy : (x < y) ↔ (ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true))
    (h_o_xt : (x < t) ↔ (ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true))
    (h_o_ty : (t < y) ↔ (ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true))
    (h_o_tx : (t < x) ↔ (ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)) :
    nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn := by
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    have := h_y_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_y_proj] at this ⊢; exact this
  | .pred p ⟨1, _⟩ =>
    have := h_x_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_x_proj3] at this ⊢
    convert this using 1
  | .pred p ⟨2, _⟩ =>
    have := h_t_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_t_proj3] at this ⊢
    convert this using 1
  | .pred _ ⟨n + 3, h⟩ => exact absurd h (by omega)
  | .order ⟨0, _⟩ ⟨0, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨0, _⟩ ⟨1, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_yx
  | .order ⟨0, _⟩ ⟨2, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_yt
  | .order ⟨1, _⟩ ⟨0, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_xy
  | .order ⟨1, _⟩ ⟨1, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨1, _⟩ ⟨2, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_xt
  | .order ⟨2, _⟩ ⟨0, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_ty
  | .order ⟨2, _⟩ ⟨1, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_tx
  | .order ⟨2, _⟩ ⟨2, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨n + 3, h⟩ _ _ => exact absurd h (by omega)
  | .order _ ⟨n + 3, h⟩ _ => exact absurd h (by omega)

/-- Bool helper: a proposition biconditional with a `false` bit fails. -/
theorem k1v_not_of_iff_false {p : Prop} (h : p ↔ false = true) : ¬ p :=
  fun hp => absurd (h.mp hp) (by simp)

/-- **Soundness direction (LHS→RHS) of the k=1 V-carrier** (task 311 Phase 4). Under the six
    k0-mirror bracket-zone order hypotheses on `qnf.1` (exactly `bracketEndChar_k0_correct`
    :1577-1589 at depth 1), the `VVecEA2.holds` of `bracketEndChar_k1v` at the FIXED endpoints
    `(x, t)` yields a bracket witness `w` realizing the depth-1 arity-3 evaluation.

    Chain (rules N1/N2 splits; no simp/omega/aesop shortcut of a documented step — G5):
    1. Destructure the arrangement disjunct `(lL, lR)` from the `VVecEA2` disjunction (∨ over
       consistent order types, Def 3.1 pp.4-5) and extract the strictly ordered witness tuple
       via `k1v_bracket_extract`; `w :=` the middle witness at bracket position `lL.length`
       (§5 bracket `[α_0, …, α_n](z_0, z_1)`, PDF p.7 + Lemma 3.2(2) PDF p.4 for the
       two-fixed-endpoint framing). Each `lL`-witness lies strictly in `(x, w)` and each
       `lR`-witness strictly in `(w, t)` **by construction** — the exact counterexample defect
       removed (rule N4; replaces the refuted type-anchored chain reading of :1782-1796).
    2. Atom layer at `[w, x, t]` from the endpoint/witness complete types + the six order
       hypotheses (`k1v_reconstruct_nf3`; two-fixed-endpoint framing per N1).
    3. Quant layer through **`nf_quant_layer_fold_k1_gate`** (NfEFold:525): per **N2**, the
       **Def 4.1 p.6 note** licenses the innermost-fold reading and **Prop 4.3 (p.6)** only
       the "residual is ∨∃∀ over E[Σ] atoms" reading — realized locally via the fold, not by
       structural induction (305 report 14). The off-fiber conjunct is gate conjunct (i).
    4. Per-(zone, χ) matching: equality zones = biconditional literals in `epL`/`ptW`/`epR`;
       exterior zones = the Since/Until literals in `epL`/`epR` (Prop 3.5 p.5 folding
       mechanism — N4-valid there: the anchor IS the fixed endpoint); interior-positive zones
       = the arrangement witness slots (§5 bracket p.7; the witness joins the existential
       prefix, Lemma 3.4 p.5); interior-negative = `segL`/`segR` exclusions + completeness of
       the witness/gap classification (`nf_eval_unique`, NormalForm:245, for distinct
       complete 1-types at one point); inconsistent zones = gate conjunct (ii) +
       `k1v_zone_consistent` (Def 3.1: disjunctions range only over consistent order types). -/
private theorem bracketEndChar_k1v_sound {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (h : (bracketEndChar_k1v atomMap h_surj qnf).holds M atomMap x t) :
    ∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  -- Step 1: destructure the V-carrier's disjunction and split on the gate.
  simp only [bracketEndChar_k1v, VVecEA2.holds] at h
  obtain ⟨vea, hmem, hveah⟩ := h
  split at hmem
  case isFalse hg =>
    -- Empty disjunction over inconsistent order types: `holds` is False.
    simp at hmem
  case isTrue hg =>
  rw [List.mem_flatMap] at hmem
  obtain ⟨lL, hlLp, hmem⟩ := hmem
  rw [List.mem_map] at hmem
  obtain ⟨lR, hlRp, hEq⟩ := hmem
  subst hEq
  obtain ⟨hepL, hepR, hbr⟩ := hveah
  -- Extract the middle witness `w` and the witness/gap structure (§5 bracket, PDF p.7).
  obtain ⟨w, hxw, hwt, hptWe, hLwit, hRwit, hLgap, hRgap⟩ :=
    k1v_bracket_extract M atomMap _ _ _ _ _ x t hbr
  have hxt : x < t := hxw.trans hwt
  -- Complete-type correctness bridge (char χ at u ↔ arity-1 depth-0 evaluation).
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ') ↔
      nf_eval_nf M 0 1 (fun _ => u) χ' :=
    fun χ' u => nfPred_correct M atomMap h_surj χ' u
  -- Unfold the three anchor conjunction lists.
  simp only [TemporalPred.eval_at] at hepL hepR hptWe
  rw [formula_conjList_iff] at hepL hepR hptWe
  -- Endpoint/witness complete types (heads of the conjunction lists).
  have hxT : temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_x_proj3 qnf.1)) :=
    hepL _ (List.mem_append_left _ List.mem_cons_self)
  have htT : temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_t_proj3 qnf.1)) :=
    hepR _ (List.mem_append_left _ List.mem_cons_self)
  have hyW : temporal_truth M atomMap w
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj qnf.1)) :=
    hptWe _ List.mem_cons_self
  -- Fold-bit literal facts at the anchors (Prop 3.5 folding mechanism, PDF p.5).
  have hPastX : ∀ χ' : NormalForm sig 0 1, temporal_truth M atomMap x
      (if (efold_of_nf1 qnf).2
          (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))), χ') = true
       then Formula.snce (nf_depth0_char_formula atomMap h_surj χ') Formula.top
       else (Formula.snce (nf_depth0_char_formula atomMap h_surj χ') Formula.top).neg) :=
    fun χ' => hepL _ (List.mem_append_left _
      (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
  have hAtX : ∀ χ' : NormalForm sig 0 1, temporal_truth M atomMap x
      (if (efold_of_nf1 qnf).2
          (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))), χ') = true
       then nf_depth0_char_formula atomMap h_surj χ'
       else (nf_depth0_char_formula atomMap h_surj χ').neg) :=
    fun χ' => hepL _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
  have hAtW : ∀ χ' : NormalForm sig 0 1, temporal_truth M atomMap w
      (if (efold_of_nf1 qnf).2
          (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))), χ') = true
       then nf_depth0_char_formula atomMap h_surj χ'
       else (nf_depth0_char_formula atomMap h_surj χ').neg) :=
    fun χ' => hptWe _ (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp)))
  have hAtT : ∀ χ' : NormalForm sig 0 1, temporal_truth M atomMap t
      (if (efold_of_nf1 qnf).2
          (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))), χ') = true
       then nf_depth0_char_formula atomMap h_surj χ'
       else (nf_depth0_char_formula atomMap h_surj χ').neg) :=
    fun χ' => hepR _ (List.mem_append_left _
      (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
  have hFutT : ∀ χ' : NormalForm sig 0 1, temporal_truth M atomMap t
      (if (efold_of_nf1 qnf).2
          (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))), χ') = true
       then Formula.untl (nf_depth0_char_formula atomMap h_surj χ') Formula.top
       else (Formula.untl (nf_depth0_char_formula atomMap h_surj χ') Formula.top).neg) :=
    fun χ' => hepR _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
  -- Chain step 2 (atom layer at `[w, x, t]`, rule N1 framing).
  have h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
    k1v_reconstruct_nf3 M qnf.1 w x t
      ((hchar _ w).mp hyW) ((hchar _ x).mp hxT) ((hchar _ t).mp htT)
      (iff_of_false (lt_asymm hxw) (by simp only [h_yx]; decide))
      (iff_of_true hwt h_yt)
      (iff_of_true hxw h_xy)
      (iff_of_true hxt h_xt)
      (iff_of_false (lt_asymm hwt) (by simp only [h_ty]; decide))
      (iff_of_false (lt_asymm hxt) (by simp only [h_tx]; decide))
  -- Chain step 4 (per-zone matching): each `(zone, χ)` fold bit matches its semantic
  -- existential over env `[w, x, t]`.
  have hzone : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
      (∃ u : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u ∧
        nf_eval_nf M 0 1 (fun _ => u) χ) ↔
      qnf.2 (nf0_assemble zs χ qnf.1) = true := by
    intro zs χ
    rw [show qnf.2 (nf0_assemble zs χ qnf.1) = (efold_of_nf1 qnf).2 (zs, χ) from rfl]
    by_cases hcons :
      zs = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))) ∨
      zs = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))) ∨
      zs = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
      zs = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
      zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))) ∨
      zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))) ∨
      zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))
    · rcases hcons with rfl | rfl | rfl | rfl | rfl | rfl | rfl
      · -- Zone zPastX (`u < x`): the Since literal in `epL` (Prop 3.5 mechanism, PDF p.5;
        -- N4-valid: anchored at the FIXED endpoint `x`).
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hux : u < x := hzu.2.1.1.mpr rfl
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))), χ) with
          | false =>
            have hlit := hPastX χ
            rw [if_neg (by simp [hbb])] at hlit
            exact (hlit ⟨u, hux, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
          | true => rfl
        · intro hbit
          have hlit := hPastX χ
          rw [if_pos hbit] at hlit
          obtain ⟨s, hsx, hsχ, -⟩ := hlit
          have hsw : s < w := hsx.trans hxw
          have hst : s < t := hsw.trans hwt
          refine ⟨s, ?_, (hchar χ s).mp hsχ⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_true hsw rfl, iff_of_false (lt_asymm hsw) (by simp)⟩,
            ⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by simp)⟩,
            ⟨iff_of_true hst rfl, iff_of_false (lt_asymm hst) (by simp)⟩⟩
      · -- Zone zAtX (`u = x`): the biconditional literal in `epL`.
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = x := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.1.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.1.1))
          subst hueq
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))), χ) with
          | false =>
            have hlit := hAtX χ
            rw [if_neg (by simp [hbb])] at hlit
            exact (hlit ((hchar χ u).mpr hev)).elim
          | true => rfl
        · intro hbit
          have hlit := hAtX χ
          rw [if_pos hbit] at hlit
          refine ⟨x, ?_, (hchar χ x).mp hlit⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by simp)⟩,
            ⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
            ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
      · -- Zone zXW (`x < u < w`): interior-positive bits ride the LEFT witness slots
        -- (§5 bracket p.7; Lemma 3.4 p.5); negative bits by the `segL` exclusion + the
        -- witness/gap classification (rule N4/N5).
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hxu : x < u := hzu.2.1.2.mpr rfl
          have huw : u < w := hzu.1.1.mpr rfl
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
          | false =>
            exfalso
            rcases hLgap u hxu huw with hseg | ⟨p, hpmem, hpe⟩
            · -- `u` is a gap point: the `segL` exclusion conjunct for χ refutes `hev`.
              simp only [TemporalPred.eval_at] at hseg
              rw [formula_conjList_iff] at hseg
              have hexcl : temporal_truth M atomMap u
                  (if (efold_of_nf1 qnf).2
                      (Fin.cons (true, false) (Fin.cons (false, true)
                        (fun _ => (true, false))), χ) = true
                   then Formula.top
                   else (nf_depth0_char_formula atomMap h_surj χ).neg) :=
                hseg _ (List.mem_map_of_mem (by simp))
              rw [if_neg (by simp [hbb])] at hexcl
              exact hexcl ((hchar χ u).mpr hev)
            · -- `u` is a witness slot: it carries some positive χ'; distinct complete
              -- 1-types cannot share a point (`nf_eval_unique`, NormalForm:245).
              obtain ⟨χ', hχ'mem, rfl⟩ := List.mem_map.mp hpmem
              have hev' : nf_eval_nf M 0 1 (fun _ => u) χ' := (hchar χ' u).mp hpe
              have hbb' : (efold_of_nf1 qnf).2
                  (Fin.cons (true, false) (Fin.cons (false, true)
                    (fun _ => (true, false))), χ') = true :=
                (List.mem_filter.mp ((List.mem_permutations.mp hlLp).mem_iff.mp hχ'mem)).2
              have hEqχ : χ = χ' := nf_eval_unique M 0 1 _ χ χ' hev hev'
              rw [hEqχ] at hbb
              exact absurd hbb' (by simp [hbb])
          | true => rfl
        · intro hbit
          have hχSL : χ ∈ lL := (List.mem_permutations.mp hlLp).mem_iff.mpr
            (List.mem_filter.mpr ⟨by simp, hbit⟩)
          obtain ⟨u, hxu, huw, hpe⟩ := hLwit _ (List.mem_map_of_mem hχSL)
          have hut : u < t := huw.trans hwt
          refine ⟨u, ?_, (hchar χ u).mp hpe⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
            ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
            ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
      · -- Zone zAtW (`u = w`): the biconditional literal in the witness point type `ptW`.
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = w := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
          subst hueq
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
          | false =>
            have hlit := hAtW χ
            rw [if_neg (by simp [hbb])] at hlit
            exact (hlit ((hchar χ u).mpr hev)).elim
          | true => rfl
        · intro hbit
          have hlit := hAtW χ
          rw [if_pos hbit] at hlit
          refine ⟨w, ?_, (hchar χ w).mp hlit⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_false (lt_irrefl w) (by simp), iff_of_false (lt_irrefl w) (by simp)⟩,
            ⟨iff_of_false (lt_asymm hxw) (by simp), iff_of_true hxw rfl⟩,
            ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by simp)⟩⟩
      · -- Zone zWT (`w < u < t`): interior-positive bits ride the RIGHT witness slots
        -- (§5 bracket p.7; Lemma 3.4 p.5); negative bits by the `segR` exclusion.
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hwu : w < u := hzu.1.2.mpr rfl
          have hut : u < t := hzu.2.2.1.mpr rfl
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
          | false =>
            exfalso
            rcases hRgap u hwu hut with hseg | ⟨p, hpmem, hpe⟩
            · simp only [TemporalPred.eval_at] at hseg
              rw [formula_conjList_iff] at hseg
              have hexcl : temporal_truth M atomMap u
                  (if (efold_of_nf1 qnf).2
                      (Fin.cons (false, true) (Fin.cons (false, true)
                        (fun _ => (true, false))), χ) = true
                   then Formula.top
                   else (nf_depth0_char_formula atomMap h_surj χ).neg) :=
                hseg _ (List.mem_map_of_mem (by simp))
              rw [if_neg (by simp [hbb])] at hexcl
              exact hexcl ((hchar χ u).mpr hev)
            · obtain ⟨χ', hχ'mem, rfl⟩ := List.mem_map.mp hpmem
              have hev' : nf_eval_nf M 0 1 (fun _ => u) χ' := (hchar χ' u).mp hpe
              have hbb' : (efold_of_nf1 qnf).2
                  (Fin.cons (false, true) (Fin.cons (false, true)
                    (fun _ => (true, false))), χ') = true :=
                (List.mem_filter.mp ((List.mem_permutations.mp hlRp).mem_iff.mp hχ'mem)).2
              have hEqχ : χ = χ' := nf_eval_unique M 0 1 _ χ χ' hev hev'
              rw [hEqχ] at hbb
              exact absurd hbb' (by simp [hbb])
          | true => rfl
        · intro hbit
          have hχSR : χ ∈ lR := (List.mem_permutations.mp hlRp).mem_iff.mpr
            (List.mem_filter.mpr ⟨by simp, hbit⟩)
          obtain ⟨u, hwu, hut, hpe⟩ := hRwit _ (List.mem_map_of_mem hχSR)
          have hxu : x < u := hxw.trans hwu
          refine ⟨u, ?_, (hchar χ u).mp hpe⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
            ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
            ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
      · -- Zone zAtT (`u = t`): the biconditional literal in `epR`.
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = t := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.1))
          subst hueq
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))), χ) with
          | false =>
            have hlit := hAtT χ
            rw [if_neg (by simp [hbb])] at hlit
            exact (hlit ((hchar χ u).mpr hev)).elim
          | true => rfl
        · intro hbit
          have hlit := hAtT χ
          rw [if_pos hbit] at hlit
          refine ⟨t, ?_, (hchar χ t).mp hlit⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_false (lt_asymm hwt) (by simp), iff_of_true hwt rfl⟩,
            ⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
            ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
      · -- Zone zFutT (`t < u`): the Until literal in `epR` (Prop 3.5 mechanism, PDF p.5;
        -- N4-valid: anchored at the FIXED endpoint `t`).
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have htu : t < u := hzu.2.2.2.mpr rfl
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))), χ) with
          | false =>
            have hlit := hFutT χ
            rw [if_neg (by simp [hbb])] at hlit
            exact (hlit ⟨u, htu, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
          | true => rfl
        · intro hbit
          have hlit := hFutT χ
          rw [if_pos hbit] at hlit
          obtain ⟨s, hts, hsχ, -⟩ := hlit
          have hws : w < s := hwt.trans hts
          have hxs : x < s := hxw.trans hws
          refine ⟨s, ?_, (hchar χ s).mp hsχ⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_false (lt_asymm hws) (by simp), iff_of_true hws rfl⟩,
            ⟨iff_of_false (lt_asymm hxs) (by simp), iff_of_true hxs rfl⟩,
            ⟨iff_of_false (lt_asymm hts) (by simp), iff_of_true hts rfl⟩⟩
    · -- Inconsistent zone spec: gate conjunct (ii) forces the bit false; no realizing
      -- point exists (`k1v_zone_consistent`, Def 3.1 consistent order types).
      constructor
      · rintro ⟨u, hzu, -⟩
        exact absurd (k1v_zone_consistent M w x t u hxw hwt zs hzu) hcons
      · intro hbit
        have hfalse : (efold_of_nf1 qnf).2 (zs, χ) = false := hg.2 zs χ hcons
        rw [hfalse] at hbit
        exact absurd hbit (by simp)
  -- Chain step 3 (assembly): depth-1 evaluation = atom layer + quant layer; the quant layer
  -- routes through the gate corollary (Def 4.1 p.6 note / Prop 4.3 p.6 — rule N2; the
  -- off-fiber conjunct is gate conjunct (i)).
  refine ⟨w, ?_⟩
  have hwhole : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf ↔
      (nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 ∧
        (∀ sub : NormalForm sig 0 4,
          (∃ x1 : M.carrier, nf_eval_nf M 0 4
            (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub) ↔
            qnf.2 sub = true)) := Iff.rfl
  rw [hwhole]
  refine ⟨h_atom, ?_⟩
  rw [nf_quant_layer_fold_k1_gate M w x t qnf h_atom]
  exact ⟨hzone, hg.1⟩

/-! ## Task 311 Phase 5: completeness direction (RHS→LHS) — helper kit

Private helper kit for `bracketEndChar_k1v_complete` (pre-authorized 5.1/5.2 split, plan v3
Phase 5 H8 escape hatch). The arrangement-selection machinery (Risk R1', rule N5) is the
insertion induction below: by induction on the interior-positive type list, insert one realized
point at a time in model order, building the sorted witness tuple AND the matching arrangement
simultaneously — mirroring the append-a-witness construction of
`BracketFormula.existsBounded_right`'s `n+1` case (VecEAClosure:265, the **Lemma 3.4 (PDF p.5)**
∃-closure vehicle, used as TEMPLATE: the target here is a fixed arrangement disjunct of the
`VVecEA2` finite disjunction, not an `∃ m` conclusion). Citations per rule N1: the
two-fixed-endpoint framing is **Lemma 3.2(2) (PDF p.4) + §5 bracket notation (PDF p.7)**. -/

/-- Extract the arity-1 witness-point evaluation from the arity-3 depth-0 atom layer at env
    `[y, x, t]` (variable 0). Private clone of the VecEADecomp extraction helper (that lemma
    is `private` there and not importable), exactly as `k1v_reconstruct_nf3` clones the
    reverse direction. -/
private theorem k1v_extract_y_nf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_y_proj] at this ⊢
    exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-- Extract the arity-1 left-endpoint evaluation (variable 1, the FIXED `z_0 = x`) from the
    arity-3 depth-0 atom layer. Private VecEADecomp clone (see `k1v_extract_y_nf`). -/
private theorem k1v_extract_x_nf3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    nf_eval_nf M 0 1 (fun _ => x) (nf_x_proj3 ssn) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨1, by omega⟩)
    simp only [atom_eval] at this
    have hfc1 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier)
        ⟨1, by omega⟩ = x := by
      simp [Fin.cons]; rfl
    rw [hfc1] at this
    simp only [nf_x_proj3]; exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-- Extract the arity-1 right-endpoint evaluation (variable 2, the FIXED `z_1 = t`) from the
    arity-3 depth-0 atom layer. Private VecEADecomp clone (see `k1v_extract_y_nf`). -/
private theorem k1v_extract_t_nf3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj3 ssn) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨2, by omega⟩)
    simp only [atom_eval] at this
    have hfc2 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier)
        ⟨2, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc2] at this
    simp only [nf_t_proj3]; exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-- **Insertion step of the arrangement-selection induction** (Risk R1', rule N5): insert one
    tagged point into a snd-sorted list of tagged points, preserving sortedness, provided the
    new point is distinct from every listed point. The insertion position is found by
    trichotomy in model order — one step of the witness-insertion construction (template:
    `existsBounded_right`'s `n+1` append case, VecEAClosure:265; Lemma 3.4 PDF p.5). -/
private theorem k1v_sorted_insert {α : Type _} {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (q : α × M.carrier) (ps : List (α × M.carrier))
    (hs : (ps.map Prod.snd).Pairwise (· < ·))
    (hne : ∀ p ∈ ps, p.2 ≠ q.2) :
    ∃ qs : List (α × M.carrier),
      List.Perm qs (q :: ps) ∧ (qs.map Prod.snd).Pairwise (· < ·) := by
  induction ps with
  | nil => exact ⟨[q], List.Perm.refl _, List.pairwise_singleton _ _⟩
  | cons p ps ih =>
    rw [List.map_cons, List.pairwise_cons] at hs
    rcases lt_trichotomy q.2 p.2 with hlt | heq | hgt
    · -- `q` precedes the head: `q :: p :: ps` is already sorted.
      refine ⟨q :: p :: ps, List.Perm.refl _, ?_⟩
      rw [List.map_cons, List.pairwise_cons]
      refine ⟨?_, ?_⟩
      · intro b hb
        rw [List.map_cons, List.mem_cons] at hb
        rcases hb with rfl | hb
        · exact hlt
        · exact hlt.trans (hs.1 b hb)
      · rw [List.map_cons, List.pairwise_cons]
        exact hs
    · exact absurd heq.symm (hne p List.mem_cons_self)
    · -- `q` lands strictly after the head: insert into the tail.
      obtain ⟨qs', hperm', hsort'⟩ :=
        ih hs.2 (fun r hr => hne r (List.mem_cons_of_mem _ hr))
      refine ⟨p :: qs', (hperm'.cons p).trans (List.Perm.swap q p ps), ?_⟩
      rw [List.map_cons, List.pairwise_cons]
      refine ⟨?_, hsort'⟩
      intro b hb
      obtain ⟨r, hr, rfl⟩ := List.mem_map.mp hb
      rcases List.mem_cons.mp (hperm'.mem_iff.mp hr) with rfl | hrps
      · exact hgt
      · exact hs.1 r.2 (List.mem_map_of_mem hrps)

/-- **Arrangement selection by insertion induction** (Risk R1', rule N5): every list of
    complete 1-types each realized somewhere strictly inside `(a, b)` admits a simultaneous
    arrangement — a permutation of the type list tagged with realizing points in strictly
    increasing model order. Distinctness of the realizing points is automatic: distinct
    complete 1-types exclude each other at any single point (`nf_eval_unique`,
    NormalForm:245). The `VVecEA2` disjunction carries ALL arrangements (rule N5 — Rabinovich's
    ∨ over consistent order types, Def 3.1 pp.4-5), so the arrangement selected here always
    names an existing disjunct; each realized point occupies a bracket WITNESS slot between the
    FIXED endpoints (§5 bracket `[α_0, …, α_n](z_0, z_1)`, PDF p.7; the witness joins the
    existential prefix, Lemma 3.4 PDF p.5). -/
theorem k1v_sorted_realization {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (a b : M.carrier)
    (S : List (NormalForm sig 0 1)) (hnd : S.Nodup)
    (hreal : ∀ χ ∈ S, ∃ u, a < u ∧ u < b ∧ nf_eval_nf M 0 1 (fun _ => u) χ) :
    ∃ ps : List (NormalForm sig 0 1 × M.carrier),
      List.Perm (ps.map Prod.fst) S ∧
      (ps.map Prod.snd).Pairwise (· < ·) ∧
      ∀ p ∈ ps, (a < p.2 ∧ p.2 < b) ∧ nf_eval_nf M 0 1 (fun _ => p.2) p.1 := by
  induction S with
  | nil => exact ⟨[], by simp, by simp, by simp⟩
  | cons χ S' ih =>
    obtain ⟨u, hau, hub, huχ⟩ := hreal χ List.mem_cons_self
    obtain ⟨ps', hperm', hsort', hprops'⟩ :=
      ih (List.nodup_cons.mp hnd).2 (fun χ' h' => hreal χ' (List.mem_cons_of_mem _ h'))
    -- The new point is distinct from every listed point: distinct complete 1-types
    -- exclude each other at one point (`nf_eval_unique`), and `χ ∉ S'` by Nodup.
    have hne : ∀ p ∈ ps', p.2 ≠ u := by
      intro p hp heq
      have hev : nf_eval_nf M 0 1 (fun _ => u) p.1 := heq ▸ (hprops' p hp).2
      have hpq : p.1 = χ := nf_eval_unique M 0 1 _ p.1 χ hev huχ
      have : χ ∈ S' := hperm'.mem_iff.mp (hpq ▸ List.mem_map_of_mem hp)
      exact (List.nodup_cons.mp hnd).1 this
    obtain ⟨qs, hqperm, hqsort⟩ := k1v_sorted_insert M (χ, u) ps' hsort' hne
    refine ⟨qs, ?_, hqsort, ?_⟩
    · have h1 : List.Perm (qs.map Prod.fst) (((χ, u) :: ps').map Prod.fst) := hqperm.map _
      rw [List.map_cons] at h1
      exact h1.trans (hperm'.cons χ)
    · intro p hp
      rcases List.mem_cons.mp (hqperm.mem_iff.mp hp) with rfl | hp'
      · exact ⟨⟨hau, hub⟩, huχ⟩
      · exact hprops' p hp'

/-- Construction for `bracketFromLists` (the reverse of `k1v_bracket_extract`; §5 bracket
    `[α_0, …, α_n](z_0, z_1)`, PDF p.7): given a sorted tuple of realizing points — left
    points strictly inside `(x, w)`, the middle witness `w`, right points strictly inside
    `(w, t)` — with each point type realized at its point and the `segL`/`segR` exclusions
    holding on ALL of `(x, w)` / `(w, t)`, the bracket holds at the FIXED endpoints `(x, t)`.
    Mirrors the append-a-witness construction of `existsBounded_right`'s `n+1` case
    (VecEAClosure:265; Lemma 3.4 PDF p.5) with the witness tuple assembled wholesale from the
    insertion-induction output of `k1v_sorted_realization`. -/
private theorem k1v_bracket_construct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lL lR : List TemporalPred) (ptW segL segR : TemporalPred)
    (x w t : M.carrier) (hxw : x < w) (hwt : w < t)
    (usL usR : List M.carrier)
    (hlenL : usL.length = lL.length) (hlenR : usR.length = lR.length)
    (hsort : (usL ++ w :: usR).Pairwise (· < ·))
    (hrangeL : ∀ u ∈ usL, x < u ∧ u < w)
    (hrangeR : ∀ u ∈ usR, w < u ∧ u < t)
    (hptw : ptW.eval_at M atomMap w)
    (hptL : ∀ (i : Nat) (hi : i < lL.length),
      (lL[i]'hi).eval_at M atomMap (usL[i]'(by omega)))
    (hptR : ∀ (i : Nat) (hi : i < lR.length),
      (lR[i]'hi).eval_at M atomMap (usR[i]'(by omega)))
    (hsegL : ∀ u, x < u → u < w → segL.eval_at M atomMap u)
    (hsegR : ∀ u, w < u → u < t → segR.eval_at M atomMap u) :
    (bracketFromLists lL ptW lR segL segR).holds M atomMap x t := by
  have hlen : (usL ++ w :: usR).length = lL.length + lR.length + 1 := by
    simp only [List.length_append, List.length_cons, hlenL, hlenR]
    omega
  -- Everything in the combined witness list lies strictly inside the fixed endpoints.
  have hrange_all : ∀ u ∈ usL ++ w :: usR, x < u ∧ u < t := by
    intro u hu
    rcases List.mem_append.mp hu with hu | hu
    · exact ⟨(hrangeL _ hu).1, (hrangeL _ hu).2.trans hwt⟩
    · rcases List.mem_cons.mp hu with rfl | hu
      · exact ⟨hxw, hwt⟩
      · exact ⟨hxw.trans (hrangeR _ hu).1, (hrangeR _ hu).2⟩
  -- Points at index ≤ lL.length sit at or left of the middle witness `w`; ≥ at or right.
  have hle_w : ∀ (j : Nat) (hj1 : j ≤ lL.length) (hj2 : j < (usL ++ w :: usR).length),
      (usL ++ w :: usR)[j] ≤ w := by
    intro j hj1 hj2
    rcases Nat.lt_or_eq_of_le hj1 with hj | hj
    · rw [List.getElem_append_left (by omega)]
      exact le_of_lt (hrangeL _ (List.getElem_mem _)).2
    · rw [List.getElem_append_right (by omega)]
      simp only [show j - usL.length = 0 by omega, List.getElem_cons_zero]
      exact le_refl w
  have hge_w : ∀ (j : Nat) (hj1 : lL.length ≤ j) (hj2 : j < (usL ++ w :: usR).length),
      w ≤ (usL ++ w :: usR)[j] := by
    intro j hj1 hj2
    rw [List.getElem_append_right (by omega)]
    by_cases hj0 : j - usL.length = 0
    · simp only [hj0, List.getElem_cons_zero]
      exact le_refl w
    · obtain ⟨d, hd⟩ : ∃ d, j - usL.length = d + 1 := ⟨j - usL.length - 1, by omega⟩
      simp only [hd, List.getElem_cons_succ]
      exact le_of_lt (hrangeR _ (List.getElem_mem _)).1
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, bracketFromLists]
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show lL.length + 1 + lR.length = (lL.length + lR.length) + 1 by omega)]
  refine ⟨fun i => (usL ++ w :: usR)[i.val]'(by omega), ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- Strict monotonicity from the sorted combined list.
    intro i j hij
    exact List.pairwise_iff_getElem.mp hsort i.val j.val (by omega) (by omega) hij
  · -- Range: all points strictly inside the fixed endpoints.
    intro i
    exact hrange_all _ (List.getElem_mem _)
  · -- Point types: three-way index split around the middle witness slot.
    intro i
    simp only []
    rcases Nat.lt_trichotomy i.val lL.length with hi | hi | hi
    · rw [List.getElem_append_left hi, List.getElem_append_left (show i.val < usL.length by omega)]
      exact hptL i.val hi
    · have h1 : (lL ++ ptW :: lR)[i.val]'(by
          simp only [List.length_append, List.length_cons]; omega) = ptW := by
        rw [List.getElem_append_right (le_of_eq hi.symm)]
        simp only [show i.val - lL.length = 0 by omega, List.getElem_cons_zero]
      have h2 : (usL ++ w :: usR)[i.val]'(by omega) = w := by
        rw [List.getElem_append_right (show usL.length ≤ i.val by omega)]
        simp only [show i.val - usL.length = 0 by omega, List.getElem_cons_zero]
      rw [h1, h2]
      exact hptw
    · have hival := i.isLt
      obtain ⟨j, hj⟩ : ∃ j, i.val = lL.length + 1 + j := ⟨i.val - lL.length - 1, by omega⟩
      have hjR : j < lR.length := by omega
      have h1 : (lL ++ ptW :: lR)[i.val]'(by
          simp only [List.length_append, List.length_cons]; omega) = lR[j]'hjR := by
        rw [List.getElem_append_right (show lL.length ≤ i.val by omega)]
        simp only [show i.val - lL.length = j + 1 by omega, List.getElem_cons_succ]
      have h2 : (usL ++ w :: usR)[i.val]'(by omega) = usR[j]'(by omega) := by
        rw [List.getElem_append_right (show usL.length ≤ i.val by omega)]
        simp only [show i.val - usL.length = j + 1 by omega, List.getElem_cons_succ]
      rw [h1, h2]
      exact hptR j hjR
  · -- Leading segment `(x, ws 0)`: inside `(x, w)`, so `segL` (index 0 ≤ lL.length).
    intro y hxy hy0
    rw [if_pos (Nat.zero_le lL.length)]
    exact hsegL y hxy (lt_of_lt_of_le hy0 (hle_w 0 (Nat.zero_le _) (by omega)))
  · -- Interior segments: left of the `w` slot inside `(x, w)` → `segL`; right → `segR`.
    intro i y h1 h2
    by_cases hile : i.val + 1 ≤ lL.length
    · rw [if_pos hile]
      refine hsegL y ?_ ?_
      · exact ((hrange_all _ (List.getElem_mem _)).1).trans h1
      · exact lt_of_lt_of_le h2 (hle_w (i.val + 1) hile (by have := i.isLt; omega))
    · rw [if_neg hile]
      refine hsegR y ?_ ?_
      · exact lt_of_le_of_lt (hge_w i.val (by omega) (by have := i.isLt; omega)) h1
      · exact h2.trans (hrange_all _ (List.getElem_mem _)).2
  · -- Trailing segment `(ws last, t)`: inside `(w, t)`, so `segR` (index lL+lR+1 > lL).
    intro y hy1 hy2
    rw [if_neg (show ¬(lL.length + lR.length + 1 ≤ lL.length) by omega)]
    refine hsegR y ?_ hy2
    exact lt_of_le_of_lt (hge_w (lL.length + lR.length) (by omega) (by omega)) hy1

/-- **Completeness direction (RHS→LHS) of the k=1 V-carrier** (task 311 Phase 5). A bracket
    witness `w` realizing the depth-1 arity-3 evaluation yields the `VVecEA2.holds` of
    `bracketEndChar_k1v` at the FIXED endpoints `(x, t)`.

    Only the two POSITIVE bracket-zone order bits (`x < w` via `h_xy`, `w < t` via `h_yt`)
    are consumed: the remaining four k0-mirror bits are forced by the witness's atom layer
    and are not needed (the assembled `bracketEndChar_k1v_correct` still carries all six,
    mirroring `bracketEndChar_k0_correct` :1581-1594).

    Chain (rules N1/N2 splits; no simp/omega/aesop shortcut of a documented step — G5):
    1. Split the depth-1 evaluation into atom + quant layers (the same defeq split
       `nf_eval_nf1_iff_efold` uses at NfEFold:497-501) and route the quant layer through
       **`nf_quant_layer_fold_k1_gate`** (NfEFold:525) `.mp`: per **N2**, the **Def 4.1 p.6
       note** licenses the innermost-fold reading and **Prop 4.3 (p.6)** only the "residual
       is ∨∃∀ over E[Σ] atoms" reading (realized locally via the fold — 305 report 14). This
       yields the per-(zone, χ) fold biconditionals and gate conjunct (i); no arity-4 object
       and no navigated arity-3 characteristic arises.
    2. Gate conjunct (ii): a positive fold bit on a zone inconsistent with `x < w < t` would
       yield a realizing point, contradicting `k1v_zone_consistent` (Def 3.1: disjunctions
       range only over consistent order types).
    3. Endpoint/witness literals: the arity-1 projections of the atom layer supply the head
       complete types; each (zone, χ) literal in `epL`/`ptW`/`epR` follows from its fold
       biconditional — positive bits from the realizing point of the matching zone, negative
       bits by contraposition (the realizing point would force the bit true). Exterior zones
       use the Since/Until literals at the FIXED endpoints (Prop 3.5 p.5 folding mechanism —
       N4-valid there: the anchor IS the fixed endpoint).
    4. Interior-positive `(zXW/zWT, χ)` bits: each yields a realizing point strictly inside
       `(x, w)` / `(w, t)`; `k1v_sorted_realization` (Risk R1' insertion induction) arranges
       them in model order, selecting the matching arrangement disjunct of the `VVecEA2`
       disjunction (rule N5 — ALL arrangements are present). Each realized point occupies a
       bracket WITNESS slot between the fixed endpoints (§5 bracket p.7; the witness joins
       the existential prefix, Lemma 3.4 p.5) — assembled by `k1v_bracket_construct`.
    5. Segment exclusions: EVERY point of `(x, w)` (resp. `(w, t)`) satisfies `segL` (resp.
       `segR`) — the handoff RHS→LHS insight: a `(char χ).neg` conjunct has a false fold bit,
       and a point realizing χ inside the interior zone would force it true. -/
private theorem bracketEndChar_k1v_complete {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (h : ∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (bracketEndChar_k1v atomMap h_surj qnf).holds M atomMap x t := by
  obtain ⟨w, hw⟩ := h
  -- Chain step 1: split the depth-1 evaluation into atom + quant layers (defeq split,
  -- NfEFold:497-501; N2 citation: Def 4.1 p.6 note for the innermost-fold reading).
  have hwhole : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf ↔
      (nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 ∧
        (∀ sub : NormalForm sig 0 4,
          (∃ x1 : M.carrier, nf_eval_nf M 0 4
            (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub) ↔
            qnf.2 sub = true)) := Iff.rfl
  rw [hwhole] at hw
  obtain ⟨h_atom, h_quant⟩ := hw
  -- Gate corollary `.mp` (NfEFold:525): fold biconditionals + off-fiber falsity.
  rw [nf_quant_layer_fold_k1_gate M w x t qnf h_atom] at h_quant
  obtain ⟨hzone, hoff⟩ := h_quant
  -- rfl-bridge to the fold-bit form, taken while `zs` is still a variable.
  have hzone' : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
      (∃ u : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u ∧
        nf_eval_nf M 0 1 (fun _ => u) χ) ↔
      (efold_of_nf1 qnf).2 (zs, χ) = true := by
    intro zs χ
    rw [show (efold_of_nf1 qnf).2 (zs, χ) = qnf.2 (nf0_assemble zs χ qnf.1) from rfl]
    exact hzone zs χ
  -- Bracket order facts from the atom layer + the two positive order bits.
  have hxw : x < w := by
    have h1 := h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr h_xy
  have hwt : w < t := by
    have h1 := h_atom (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr h_yt
  have hxt : x < t := hxw.trans hwt
  -- Complete-type correctness bridge (char χ at u ↔ arity-1 depth-0 evaluation).
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ') ↔
      nf_eval_nf M 0 1 (fun _ => u) χ' :=
    fun χ' u => nfPred_correct M atomMap h_surj χ' u
  -- Endpoint/witness arity-1 point evaluations (chain step 3 heads; VecEADecomp clones).
  have h_y_nf := k1v_extract_y_nf M qnf.1 w x t h_atom
  have h_x_nf := k1v_extract_x_nf3 M qnf.1 w x t h_atom
  have h_t_nf := k1v_extract_t_nf3 M qnf.1 w x t h_atom
  -- Zone-membership constructors at the seven consistent zones (Def 3.1 ordering channel).
  have hzPastX : ∀ u, u < x → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))) : ZoneSpec 3) u := by
    intro u hux
    have huw : u < w := hux.trans hxw
    have hut : u < t := huw.trans hwt
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (by simp)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtX : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))) : ZoneSpec 3) x := by
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by simp)⟩,
      ⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
      ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
  have hzXW : ∀ u, x < u → u < w → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))) : ZoneSpec 3) u := by
    intro u hxu huw
    have hut : u < t := huw.trans hwt
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtW : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))) : ZoneSpec 3) w := by
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_irrefl w) (by simp), iff_of_false (lt_irrefl w) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxw) (by simp), iff_of_true hxw rfl⟩,
      ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by simp)⟩⟩
  have hzWT : ∀ u, w < u → u < t → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))) : ZoneSpec 3) u := by
    intro u hwu hut
    have hxu : x < u := hxw.trans hwu
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtT : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))) : ZoneSpec 3) t := by
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwt) (by simp), iff_of_true hwt rfl⟩,
      ⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
      ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
  have hzFutT : ∀ u, t < u → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))) : ZoneSpec 3) u := by
    intro u htu
    have hwu : w < u := hwt.trans htu
    have hxu : x < u := hxw.trans hwu
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
  -- The gate Prop (chain step 2): conjunct (i) is the off-fiber clause from the corollary;
  -- conjunct (ii) is order-conflict falsity via the `k1v_zone_consistent` contrapositive.
  have hgate : (∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false) ∧
      (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
        ¬(zs = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))) ∨
          zs = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))) ∨
          zs = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
          zs = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
          zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))) ∨
          zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))) ∨
          zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))) →
        (efold_of_nf1 qnf).2 (zs, χ) = false) := by
    refine ⟨hoff, fun zs χ hncons => ?_⟩
    cases hb : (efold_of_nf1 qnf).2 (zs, χ) with
    | false => rfl
    | true =>
      obtain ⟨u, hzu, -⟩ := (hzone' zs χ).mpr hb
      exact absurd (k1v_zone_consistent M w x t u hxw hwt zs hzu) hncons
  -- Interior-positive realization (chain step 4): each positive interior fold bit yields a
  -- realizing point strictly inside its zone.
  have hLreal : ∀ χ : NormalForm sig 0 1,
      (efold_of_nf1 qnf).2
        (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))), χ) = true →
      ∃ u, x < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
    intro χ hbit
    obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hbit
    rw [k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.2.1.2.mpr rfl, hzu.1.1.mpr rfl, hev⟩
  have hRreal : ∀ χ : NormalForm sig 0 1,
      (efold_of_nf1 qnf).2
        (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))), χ) = true →
      ∃ u, w < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
    intro χ hbit
    obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hbit
    rw [k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.1.2.mpr rfl, hzu.2.2.1.mpr rfl, hev⟩
  -- Segment exclusions on ALL of `(x, w)` / `(w, t)` (chain step 5, handoff insight).
  have hsegL_all : ∀ u, x < u → u < w →
      TemporalPred.eval_at M atomMap
        ⟨formula_conjList ((Finset.univ.toList).map fun χ =>
          if (efold_of_nf1 qnf).2
              (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))),
                χ) = true
          then Formula.top
          else (nf_depth0_char_formula atomMap h_surj χ).neg)⟩ u := by
    intro u hxu huw
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : (efold_of_nf1 qnf).2
        (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
    | true =>
      rw [if_pos rfl]
      exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp [hb])]
      intro hch
      have hbit := (hzone' _ χ).mp ⟨u, hzXW u hxu huw, (hchar χ u).mp hch⟩
      rw [hb] at hbit
      exact Bool.noConfusion hbit
  have hsegR_all : ∀ u, w < u → u < t →
      TemporalPred.eval_at M atomMap
        ⟨formula_conjList ((Finset.univ.toList).map fun χ =>
          if (efold_of_nf1 qnf).2
              (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))),
                χ) = true
          then Formula.top
          else (nf_depth0_char_formula atomMap h_surj χ).neg)⟩ u := by
    intro u hwu hut
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : (efold_of_nf1 qnf).2
        (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
    | true =>
      rw [if_pos rfl]
      exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp [hb])]
      intro hch
      have hbit := (hzone' _ χ).mp ⟨u, hzWT u hwu hut, (hchar χ u).mp hch⟩
      rw [hb] at hbit
      exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED left endpoint `x` (chain step 3; exterior Since literal
  -- per Prop 3.5 p.5 folding mechanism — N4-valid: the anchor IS the fixed endpoint).
  have hepL : TemporalPred.eval_at M atomMap
      ⟨formula_conjList
        ((nf_depth0_char_formula atomMap h_surj (nf_x_proj3 qnf.1)
          :: (Finset.univ.toList).map fun χ =>
              if (efold_of_nf1 qnf).2
                  (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))),
                    χ) = true
              then Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top
              else (Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top).neg)
          ++ (Finset.univ.toList).map fun χ =>
              if (efold_of_nf1 qnf).2
                  (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))),
                    χ) = true
              then nf_depth0_char_formula atomMap h_surj χ
              else (nf_depth0_char_formula atomMap h_surj χ).neg)⟩ x := by
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hchar _ x).mpr h_x_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : (efold_of_nf1 qnf).2
            (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))), χ) with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          rw [k1v_zoneHolds_cons_iff] at hzu
          exact ⟨u, hzu.2.1.1.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
        | false =>
          rw [if_neg (by simp [hb])]
          rintro ⟨s, hsx, hsχ, -⟩
          have hbit := (hzone' _ χ).mp ⟨s, hzPastX s hsx, (hchar χ s).mp hsχ⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : (efold_of_nf1 qnf).2
          (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))), χ) with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
        rw [k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = x := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.1))
        exact (hchar χ x).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp [hb])]
        intro hch
        have hbit := (hzone' _ χ).mp ⟨x, hzAtX, (hchar χ x).mp hch⟩
        rw [hb] at hbit
        exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED right endpoint `t` (chain step 3; exterior Until
  -- literal per Prop 3.5 p.5 — N4-valid: the anchor IS the fixed endpoint).
  have hepR : TemporalPred.eval_at M atomMap
      ⟨formula_conjList
        ((nf_depth0_char_formula atomMap h_surj (nf_t_proj3 qnf.1)
          :: (Finset.univ.toList).map fun χ =>
              if (efold_of_nf1 qnf).2
                  (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))),
                    χ) = true
              then nf_depth0_char_formula atomMap h_surj χ
              else (nf_depth0_char_formula atomMap h_surj χ).neg)
          ++ (Finset.univ.toList).map fun χ =>
              if (efold_of_nf1 qnf).2
                  (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))),
                    χ) = true
              then Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top
              else (Formula.untl (nf_depth0_char_formula atomMap h_surj χ)
                Formula.top).neg)⟩ t := by
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hchar _ t).mpr h_t_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : (efold_of_nf1 qnf).2
            (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))), χ) with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = t := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.1))
          exact (hchar χ t).mpr (hueq ▸ hev)
        | false =>
          rw [if_neg (by simp [hb])]
          intro hch
          have hbit := (hzone' _ χ).mp ⟨t, hzAtT, (hchar χ t).mp hch⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : (efold_of_nf1 qnf).2
          (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))), χ) with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
        rw [k1v_zoneHolds_cons_iff] at hzu
        exact ⟨u, hzu.2.2.2.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
      | false =>
        rw [if_neg (by simp [hb])]
        rintro ⟨s, hts, hsχ, -⟩
        have hbit := (hzone' _ χ).mp ⟨s, hzFutT s hts, (hchar χ s).mp hsχ⟩
        rw [hb] at hbit
        exact Bool.noConfusion hbit
  -- Witness point type at `w` (complete type + equality-zone literals ONLY, rule N4).
  have hptW : TemporalPred.eval_at M atomMap
      ⟨formula_conjList
        (nf_depth0_char_formula atomMap h_surj (nf_y_proj qnf.1)
          :: (Finset.univ.toList).map fun χ =>
              if (efold_of_nf1 qnf).2
                  (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))),
                    χ) = true
              then nf_depth0_char_formula atomMap h_surj χ
              else (nf_depth0_char_formula atomMap h_surj χ).neg)⟩ w := by
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_cons.mp hf with rfl | hf
    · exact (hchar _ w).mpr h_y_nf
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : (efold_of_nf1 qnf).2
          (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
        rw [k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = w := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
        exact (hchar χ w).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp [hb])]
        intro hch
        have hbit := (hzone' _ χ).mp ⟨w, hzAtW, (hchar χ w).mp hch⟩
        rw [hb] at hbit
        exact Bool.noConfusion hbit
  -- Chain step 4: sorted arrangements of the interior-positive enumerations (R1').
  obtain ⟨psL, hpermL, hsortL, hpropsL⟩ :=
    k1v_sorted_realization M x w
      ((Finset.univ.toList).filter fun χ =>
        (efold_of_nf1 qnf).2
          (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))), χ))
      ((Finset.nodup_toList _).filter _)
      (fun χ hχ => hLreal χ (List.mem_filter.mp hχ).2)
  obtain ⟨psR, hpermR, hsortR, hpropsR⟩ :=
    k1v_sorted_realization M w t
      ((Finset.univ.toList).filter fun χ =>
        (efold_of_nf1 qnf).2
          (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))), χ))
      ((Finset.nodup_toList _).filter _)
      (fun χ hχ => hRreal χ (List.mem_filter.mp hχ).2)
  -- Combined witness list is sorted: left points < w < right points.
  have hsortFull : (psL.map Prod.snd ++ w :: psR.map Prod.snd).Pairwise (· < ·) := by
    rw [List.pairwise_append]
    refine ⟨hsortL, ?_, ?_⟩
    · rw [List.pairwise_cons]
      refine ⟨?_, hsortR⟩
      intro b hb
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hb
      exact (hpropsR p hp).1.1
    · intro a ha b hb
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp ha
      have haw : p.2 < w := (hpropsL p hp).1.2
      rcases List.mem_cons.mp hb with rfl | hb
      · exact haw
      · obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hb
        exact haw.trans (hpropsR q hq).1.1
  -- Enter the carrier: gate branch, then the (psL, psR) arrangement disjunct (rule N5).
  simp only [bracketEndChar_k1v, VVecEA2.holds]
  split
  case isFalse hg => exact absurd hgate hg
  case isTrue hg =>
  refine ⟨_, List.mem_flatMap.mpr ⟨psL.map Prod.fst, List.mem_permutations.mpr hpermL,
    List.mem_map.mpr ⟨psR.map Prod.fst, List.mem_permutations.mpr hpermR, rfl⟩⟩, ?_⟩
  refine ⟨hepL, hepR, ?_⟩
  -- The bracket: assembled by the construction lemma from the sorted realizations.
  refine k1v_bracket_construct M atomMap _ _ _ _ _ x w t hxw hwt
    (psL.map Prod.snd) (psR.map Prod.snd) (by simp) (by simp) hsortFull
    ?_ ?_ hptW ?_ ?_ hsegL_all hsegR_all
  · intro u hu
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
    exact (hpropsL p hp).1
  · intro u hu
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
    exact (hpropsR p hp).1
  · intro i hi
    have hi' : i < psL.length := by simpa using hi
    have h1 : (List.map (fun χ => (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
        (psL.map Prod.fst))[i]'hi =
        ⟨nf_depth0_char_formula atomMap h_surj ((psL[i]'hi').1)⟩ := by
      simp only [List.getElem_map]
    have h2 : (psL.map Prod.snd)[i]'(by simpa using hi') = (psL[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    exact (hchar _ _).mpr (hpropsL _ (List.getElem_mem _)).2
  · intro i hi
    have hi' : i < psR.length := by simpa using hi
    have h1 : (List.map (fun χ => (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
        (psR.map Prod.fst))[i]'hi =
        ⟨nf_depth0_char_formula atomMap h_surj ((psR[i]'hi').1)⟩ := by
      simp only [List.getElem_map]
    have h2 : (psR.map Prod.snd)[i]'(by simpa using hi') = (psR[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    exact (hchar _ _).mpr (hpropsR _ (List.getElem_mem _)).2

/-- **k=1 fixed-endpoint correctness for the witness-growing V-carrier** (task 311 Phase 5 —
the k=1 instance of `BracketCarrierCorrectV` in k0-mirror conditional form, exactly
`bracketEndChar_k0_correct` :1581-1594 at depth 1). Under the six bracket-zone order
hypotheses on `qnf.1`, the `VVecEA2.holds` of `bracketEndChar_k1v` at the FIXED endpoints
`(x, t)` is equivalent to the existence of a bracket witness `w` realizing the depth-1
arity-3 evaluation. Sorry-free assembly of `bracketEndChar_k1v_sound` (LHS→RHS) and
`bracketEndChar_k1v_complete` (RHS→LHS). Citations (rule N1 split): the two-fixed-endpoint
`(z_0, z_1)` framing is **Lemma 3.2(2) (PDF p.4) + the §5 bracket notation
`[α_0, …, α_n](z_0, z_1)` (PDF p.7)**; witness growth per disjunct is the printed §5 bracket
shape (p.7) with **Lemma 3.4 (PDF p.5)** as the ∃-closure license; **Prop 3.5 (PDF p.5)** is
cited ONLY for the ∃-witness→Until/Since folding mechanism in the `epL`/`epR` exterior-zone
literals; the fold channel is **Def 4.1 (PDF p.5, iterated per the p.6 note)**. -/
theorem bracketEndChar_k1v_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_k1v atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  ⟨bracketEndChar_k1v_sound atomMap h_surj qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t,
   bracketEndChar_k1v_complete atomMap h_surj qnf h_xy h_yt M x t⟩

/-! ## Task 311 Phase 5: k=1 gate re-probe under the E[Σ]-fold at the V-carrier —
DECISION GATE → **R2 = GO** (verdict-mirror of the Phase 10 / Phase 2 records above)

**Lead evidence (Def 3.1, PDF p.4 — rule N3).** Rabinovich's α_j/β_j are ONE-variable
quantifier-free formulas: no joint multi-point atom exists, so the arity-4 residual
`[x_1, w, x, t]` that NO-GOed the original probe (Phase 10 record, :1596-1628) has no
Rabinovich counterpart — it was a Lean `nf_eval_nf` arity-growth artifact, and the E[Σ]-fold
RESTORES Def-4.1 fidelity (PDF p.5, iterated per the p.6 note). This re-probe CONFIRMS it
end-to-end: `bracketEndChar_k1v_correct` above is the k=1 instance of
`BracketCarrierCorrectV` in k0-mirror conditional form, proved **sorry-free** with the fold
as the ONLY channel through which `qnf.2` is read. **No arity-4 object, no navigated arity-3
characteristic, and no third free anchor arises at any step** — both directions route the
quant layer through `nf_quant_layer_fold_k1_gate` (NfEFold:525; task 310's gate corollary),
whose per-(zone, χ) obligations are zone-bounded MONADIC existentials.

**The G6 amendment carried the day (the Phase-3 record above, :1829-1850).** The v2 Phase 2
re-probe (:1754-1827) refuted the FIXED codomain `VecEA2 1`: a one-witness bracket cannot
host the interior-positive `(zone, χ)` witnesses (counterexample :1786-1800). The amended
codomain — witness-growing `VecEA2 n` disjuncts assembled as `VVecEA2`, anchors capped at the
FIXED `{x, t}` — is Rabinovich's own printed shape: **Lemma 3.2(2) (p.4)** caps ANCHORS at
≤2 (a TYPE-level invariant of `VVecEA2.holds`, VecEAFormula:276), the **§5 bracket
`[α_0, …, α_n](z_0, z_1)` (p.7)** carries `n` witnesses between the two fixed endpoints, and
**Lemma 3.4 (p.5)** licenses each absorbed existential to JOIN the existential prefix as a
witness. Interior-positive content rides bracket WITNESS slots (rule N4 — the refuted
type-anchored `bracketBuildLeft/Right` interior chains stayed dead; they survive only in the
`epL`/`epR` exterior-zone literals, where the anchor genuinely IS the fixed endpoint), and
the model-dependent witness order rides the finite disjunction over ALL arrangements
(rule N5), selected in the completeness direction by the `k1v_sorted_realization` insertion
induction.

**Verdict: R2 = GO.** The k=1 bracket gate is CLOSED at the V-carrier: the fold encoding
(task 310) composes with the witness-growing codomain (this task) to characterize
`∃ w, nf_eval_nf M 1 3 [w, x, t] qnf` by a two-anchor `VVecEA2` at `(x, t)` under the
bracket-zone order hypotheses. Path B is UN-FALSIFIED at k=1 under the amended carrier.
`bracketEndChar_k1v` / `bracketEndChar_k1v_correct` stay OFF the live path until wired
(nothing imports them); the live Kamp sorry baseline (2: KampPrior:351/354) is untouched.
Downstream: task 309 resumes via `/revise 309` (plan v4) — the depth-`k` lift (R3) can now
target `BracketCarrierCorrectV` with this k=1 instance as the recursion template over the
k=0 base `bracketEndChar_k0_correct` (:1581-1594). -/

/-! ## Task 349 Phase 2 (v6): FAITHFUL two-endpoint carrier — retype + `endInterval_correct`
statement freeze + `k = 0` base

Re-base onto the FAITHFUL two-endpoint carrier (reports 06 §4.5 + 07). The refuted single-point
`NormalForm sig k 3 → TemporalPred` scaffold was archived to `Boneyard/NavigatedEndCharSinglePoint.lean`
(Phase 1). This phase declares the recursion skeleton `endInterval : (k) → BracketEndCharCarrierV sig k`
(base = the `k = 0` bracket carrier `bracketEndChar_k0` embedded as a singleton `VVecEA2` disjunct;
step = the named Phase-3 hole `endIntervalStep`), FREEZES the correctness statement `EndIntervalCorrect`
(the report-06-§4.5 biconditional — `x, t` EXPLICIT on BOTH sides, immune to the parameter-independence
refutation that killed the single-point `.eval_at w` LHS; report 07 §5), and proves the `k = 0` base
`endInterval_zero_correct` by threading `bracketEndChar_k0_correct` (:87) through the singleton unfolding.

**FORBIDDEN single-point pointer** (report 07 §5): the retired navigated carrier's infeasibility is
recorded at `endCharN0_correct_infeasible` (Base.lean:1779). That device asserts a single-point
`(endChar0 qnf).eval_at w ↔ …` characteristic whose LHS cannot read the anchor positions `{x, t}` (the
≤2-free-variable cap, Rabinovich Lemma 3.2(2), PDF p.4) — provably FALSE in free-anchor form. The
two-endpoint carrier here is the discriminator precisely because BOTH sides carry `x` and `t`
EXPLICITLY: the `VVecEA2.holds … x t` LHS is evaluated AT the fixed endpoints, never at a single
navigated `w`. This is why the frozen statement is non-refuted (green at `k = 0` AND `k = 1`, the latter
via `bracketEndChar_k1v_correct` :2041). -/

/-- **Singleton-disjunct embedding** `VecEA2 n → VVecEA2` (task 349 Phase 2). Wraps a single
`VecEA2 n` bracket as a one-element `VVecEA2` disjunction, the recursion-base coercion from the
`k = 0` fixed codomain (`bracketEndChar_k0 : … → VecEA2 1`, :73) into the witness-growing carrier
codomain `VVecEA2` (:365). No anchor growth — the two FIXED endpoints are preserved (Lemma 3.2(2)). -/
def VVecEA2.singleton {n : Nat} (vea : VecEA2 n) : VVecEA2 :=
  ⟨[⟨n, vea⟩]⟩

/-- The singleton embedding's `holds` unfolds to the wrapped `VecEA2`'s `holds` (task 349 Phase 2).
Confirms `VVecEA2.singleton`'s `.holds` at the fixed endpoints is exactly the underlying bracket's
`.holds` — the identity that threads `bracketEndChar_k0_correct` through the `k = 0` base below. -/
theorem VVecEA2.singleton_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (vea : VecEA2 n) (z0 z1 : M.carrier) :
    (VVecEA2.singleton vea).holds M atomMap z0 z1 ↔ vea.holds M atomMap z0 z1 := by
  simp only [VVecEA2.holds, VVecEA2.singleton, List.mem_singleton, exists_eq_left]

/-- **Depth-`k → k+1` step of the recursion carrier — Phase-3 HOLE** (task 349 Phase 2, v6). A
genuine deferred (total, sorry-free, non-vacuous) def whose body Phase 3 REPLACES with the
two-endpoint step construction (generalize `bracketEndChar_k1v` :433 from the concrete `k = 1` to
arbitrary `k`, threading the depth-`k` IH carrier `rec` for the sub-piece characteristics). The
Phase-2 placeholder returns the empty `VVecEA2` disjunction `⟨[]⟩` — Rabinovich's honest empty
disjunction over inconsistent order types (the same `⟨[]⟩` gate-failure object used by
`bracketEndChar_k1v` :431), NOT a `sorry` and NOT a vacuous `True`/`Unit`/`trivial` placeholder. The
frozen signature FIXES the anchors at `{x, t}` (the `atomMap`/`h_surj` params are the Phase-3
construction's fold channel); witness growth rides the disjuncts (G2/G4). Phase 3 discharges the body;
Phase 6 verifies `endInterval` genuinely recurses through it. -/
noncomputable def endIntervalStep {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (rec : BracketEndCharCarrierV sig k) : BracketEndCharCarrierV sig (k + 1) :=
  -- Phase-3 HOLE (deferred; empty disjunction, not sorry/vacuous). `rec`, `atomMap`, `h_surj`
  -- are consumed by the Phase-3 construction generalizing `bracketEndChar_k1v`.
  fun _ => (⟨[]⟩ : VVecEA2)

/-- **Recursion carrier skeleton** `endInterval : (k) → BracketEndCharCarrierV sig k` (task 349
Phase 2, v6). Base = the `k = 0` two-endpoint bracket carrier `bracketEndChar_k0` (:73) embedded as
a singleton `VVecEA2` disjunct; step = the named Phase-3 hole `endIntervalStep`. Defined by `Nat.rec`
so `endInterval atomMap h_surj 0 = fun qnf => VVecEA2.singleton (bracketEndChar_k0 atomMap h_surj qnf)`
and `endInterval atomMap h_surj (k+1) = endIntervalStep atomMap h_surj (endInterval atomMap h_surj k)`
both hold by `rfl` (the literal shape Phase 6 confirms). The codomain is the witness-growing
`VVecEA2` (:365): anchors stay FIXED at `{x, t}` (Lemma 3.2(2)), witnesses grow across disjuncts. -/
noncomputable def endInterval {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) → BracketEndCharCarrierV sig k :=
  fun k =>
    Nat.rec (motive := fun k => BracketEndCharCarrierV sig k)
      (fun qnf => VVecEA2.singleton (bracketEndChar_k0 atomMap h_surj qnf))
      (fun _k rec => endIntervalStep atomMap h_surj rec)
      k

/-- **FROZEN correctness statement** `EndIntervalCorrect` (task 349 Phase 2, v6; report 06 §4.5).
The recursion carrier's `VVecEA2.holds` at the FIXED anchor pair `(x, t)` is equivalent to the
existence of a bracket witness `w` realizing the arity-3 depth-`k` evaluation
`nf_eval_nf M k 3 [w, x, t] qnf`, under the six k0-mirror bracket-zone order bits on `qnf`'s atom
layer (read uniformly at any depth via `NormalForm.atom_assgn` :151 — at `k = 0` it is `qnf` itself,
at `k+1` it is `qnf.1`, matching `bracketEndChar_k0_correct` :87 and `bracketEndChar_k1v_correct`
:2041 respectively). `x, t` are EXPLICIT on BOTH sides (immune to the parameter-independence
refutation; NEVER a single-point `.eval_at w` LHS — see the FORBIDDEN pointer note above). Phase 6
proves this by induction on `k`: base = `endInterval_zero_correct` below; step = Phase 5's
`endInterval_step_correct`. -/
def EndIntervalCorrect {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) : Prop :=
  ∀ (k : Nat) (qnf : NormalForm sig k 3) (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (_h_xy : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (_h_yt : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (_h_xt : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (_h_yx : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (_h_ty : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (_h_tx : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false),
    (endInterval atomMap h_surj k qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-- **`k = 0` base of `EndIntervalCorrect`** (task 349 Phase 2, v6; sorry-free). The `k = 0` slice of
the frozen statement, proved by unfolding `endInterval … 0 qnf` to the singleton embedding of
`bracketEndChar_k0 atomMap h_surj qnf`, rewriting with `VVecEA2.singleton_holds`, and discharging the
resulting `VecEA2.holds ↔ ∃ w, nf_eval_nf M 0 3 [w,x,t] qnf` biconditional directly by the preserved
green `bracketEndChar_k0_correct` (:87). At `k = 0`, `qnf.atom_assgn (.order …)` is definitionally
`qnf (.order …)`, so the six order hypotheses feed `bracketEndChar_k0_correct` unchanged (no
simp/omega/aesop chain-step shortcut — G5). Consumes the depth-0 result; does NOT re-derive it. -/
theorem endInterval_zero_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 0 3)
    (h_xy : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (endInterval atomMap h_surj 0 qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  show (VVecEA2.singleton (bracketEndChar_k0 atomMap h_surj qnf)).holds M atomMap x t ↔ _
  rw [VVecEA2.singleton_holds]
  exact bracketEndChar_k0_correct atomMap h_surj qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t

end Bimodal.Metalogic.WeakCanonical.Kamp
