/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V

/-! Extracted from NfMultiAnchorBridge.lean lines 3604-4040.
Depth-`k` V-carrier kit: `atomKindCastLE`, `nfkTake`/`nfkProjFresh`, `kv_body`,
`bracketEndCharKv` with `_correct_zero`/`_correct_one`/`_factors`. Plus the sanctioned
relocation of `nf_eval_depth1_fold_iff` (orig. lines 5333-5358) so faithful modules never
import the quarantine. Byte-identical except 1 sanctioned `private ` removal
(`atomKindCastLE`). -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nfDepth0CharFormula nf_depth0_char_formula_correct
   formulaConjList formula_conjList_iff)

/-! ## R3a: depth-`k` V-carrier definition `bracketEndCharKv`

Definitional + typechecking phase (plan v5 Phase 12): generalize the landed k=1 V-carrier
`bracketEndCharK1v` (:1927) to a depth-`k` carrier `bracketEndCharKv : BracketEndCharCarrierV
sig k`. Correctness (`bracketEndChar_kv_correct`) is Phase 13 (R3b) and is NOT attempted here.

**Depth-`k` E[Σ]-atom char provider is a PARAMETER (`charF`).** The concrete depth-`k`
characteristic-formula provider (`char_k1`, KampPrior:307 / `nfCharacterizableTemporalPrior`,
KampPrior:397) lives in `KampPrior.lean`, which IMPORTS this file (KampPrior.lean:4) — consuming
it here by name would re-create the import cycle the aggregator split removed (see the import
note at :13-16). Following the `nfSuccCharFormula`/`exist_tl_fn` parameterization pattern
(KampPrior:67), the carrier takes the provider family `charF : (j : Nat) → NormalForm sig j 1 →
Formula`; Phase 14 (R4) instantiates it at the KampPrior call site with the local `char_k1` /
`nfCharacterizableTemporalPrior`, and Phase 13 states correctness under the corresponding
`TemporalTruth … (charF j χ) ↔ NfEvalNf M j 1 (fun _ => t) χ` hypothesis.

**Fold-bit read at depth `k` (the general fold engine's on-fiber content).** At depth 1 the
carrier reads its fold bits via `efoldOfNf1` (NfEFold:472): `b zs χ = qnf.2 (nf0Assemble zs
χ qnf.1)` — a POINTWISE read, licensed by the depth-0 split kit's bijection (`nf0_split_assemble`,
NfEFold:235). At depth `k ≥ 1` no such pointwise assemble exists (the deeper joint quant layers
of an arity-4 sub are not determined by `(zs, χ, qnf.1)` — deviation D7, NfEFold:373). The
depth-`k` fold bit is therefore read FIBER-EXISTENTIALLY:

  `b zs χ = decide (∃ sub, qnf.2 sub = true ∧ zoneSpec sub = zs ∧ projFresh_k sub = χ)`

i.e. "some realized-marked sub carries ordering channel `zs` and depth-`k` monadic point type
`χ`" — exactly the E[Σ]-atom content of Def 4.1 (PDF p.5, read at depth `k` per the **Def 4.1
p.6 note** on iterated folds; rule N2: Prop 4.3 (p.6) is cited only for "the residual is ∨∃∀
over E[Σ] atoms", realized locally via the fold). Under the gate's off-fiber-falsity conjunct
this AGREES with the `efoldOfNf1` pointwise read at `k = 1` (`nf0_split_assemble` round-trip;
the documented bridge lemma `bracketEndChar_kv_one_eq` below), so the k=1 specialization is
propositionally EQUAL to `bracketEndCharK1v` and Phase 13's step can reuse the k1v proof. -/

/-- Reindex an atom along the prefix inclusion `Fin.castLE : Fin m → Fin n` (`m ≤ n`).
    Injectivity of `Fin.castLE` carries the `order` atom's `i ≠ j` witness. Pure bookkeeping
    for the depth-`k` prefix restriction `nfkTake` below. -/
def atomKindCastLE {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {m n : Nat} (h : m ≤ n) :
    AtomKind sig m → AtomKind sig n
  | .pred p i => .pred p (Fin.castLE h i)
  | .order i j hne =>
      .order (Fin.castLE h i) (Fin.castLE h j)
        (fun he => hne (Fin.castLE_injective h he))

/-- **Depth-`k` prefix restriction**: restrict a depth-`k` arity-`n` NF to
    its first `m` variables. Atom layer: precompose with `atomKindCastLE` (the depth-0
    restriction). Quant layer: a depth-`(k-1)` arity-`(m+1)` sub is marked realized iff SOME
    realized-marked arity-`(n+1)` sub restricts to it — fresh witnesses always PREPEND
    (`Fin.cons x env`), so the variables of interest stay a prefix at every layer and the
    recursion is uniform in `k`. This is the projection direction of Rabinovich's monadic
    E[Σ]-atom extraction (Def 4.1, PDF p.5): the complete depth-`k` type of a variable prefix,
    read off the complete type of the whole tuple. Decidability of the existential is via the
    `Fintype`/`DecidableEq` instances on `NormalForm` (NormalForm.lean:177/181). -/
noncomputable def nfkTake {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    {k : Nat} → {m n : Nat} → m ≤ n → NormalForm sig k n → NormalForm sig k m
  | 0, _, _, h, nf => fun a => nf (atomKindCastLE h a)
  | _ + 1, _, _, h, nf =>
      ⟨fun a => nf.1 (atomKindCastLE h a),
       fun χ' => decide (∃ sub', nf.2 sub' = true ∧
         nfkTake (Nat.succ_le_succ h) sub' = χ')⟩

/-- **Depth-`k` monadic point type of the fresh variable** (index `0`, matching `Fin.cons x
    env`): the depth-`k` generalization of `nf0ProjFresh` (NfEFold:162) via the prefix
    restriction to the single variable `0`. This is the E[Σ]-atom channel of Def 4.1 (PDF p.5)
    at depth `k`. -/
noncomputable def nfkProjFresh {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k n : Nat}
    (sub : NormalForm sig k (n + 1)) : NormalForm sig k 1 :=
  nfkTake (Nat.succ_le_succ (Nat.zero_le n)) sub

/-- At depth 0 the prefix-restriction fresh projection coincides with the split kit's
    `nf0ProjFresh` (NfEFold:162). Order atoms at arity 1 are uninhabited (`i ≠ j` with
    `i j : Fin 1`), discharged by `Subsingleton.elim` as in `nf0ProjFresh` itself. -/
private theorem nfk_projFresh_zero {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) :
    nfkProjFresh sub = nf0ProjFresh sub := by
  funext a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    rfl
  | .order i j h => exact absurd (Subsingleton.elim i j) h

/-! ### Depth-`k` witness-growing two-anchor fold carrier (R3a; G6 as
amended — see the plan-v3 amendment record at :1829-1850)

Generalizes `bracketEndCharK1v` (:1927) from depth 1 to depth `k`, mirroring it structurally:
a depth-`k` arity-3 `qnf : NormalForm sig k 3` is encoded as a `VVecEA2` at the two FIXED
endpoints `{x, t}`, with the interior-positive `(zone, χ)` fold bits as bracket WITNESSES
ordered between the fixed endpoints alongside `w` (rule N4: interior-positive content rides
bracket witness slots anchored between the FIXED endpoints, NEVER type-anchored
`bracketBuildLeft`/`bracketBuildRight` chains — the refuted device of :1782-1796; those chains
survive only inside the `epL`/`epR` exterior-zone literals, where the anchor genuinely IS the
fixed endpoint). Citation split (rule N1): the two-fixed-endpoint `(z_0, z_1)` framing is
**Lemma 3.2(2) (PDF p.4) + the §5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7)**;
**Prop 3.5 (PDF p.5)** is cited ONLY for the one-free-variable ∃-witness→Until/Since folding
mechanism (the Since/Until literals in `epL`/`epR`). The codomain is the witness-growing
`VVecEA2` (G6 amendment, :1829-1850): anchors stay `{x, t}` (2, FIXED — the `VVecEA2.holds`
two-point signature, VecEAFormula:276, is the TYPE-level ≤2-anchor invariant, G2/G4); witness
count grows per disjunct — NO `VecEA2 1` regression (refuted by the dense-order counterexample
:1782-1796).

- **`k = 0`**: no quant layer exists; the carrier is the singleton-disjunct wrapper of the
  landed depth-0 bracket `bracketEndCharK0` (:1567) — Phase 13's recursion base
  (`bracketEndChar_k0_correct`, :1581).
- **`k + 1`**: the k=1 fold-carrier building blocks verbatim (seven zone specs, `lit`,
  endpoint preds `epL`/`epR`, segment exclusions `segL`/`segR`, the two-conjunct gate), with
  the depth-0 E[Σ]-atoms replaced by depth-`k` atoms: fold bits `b` read fiber-existentially
  from `qnf.2` (the depth-`k` E[Σ]-fold channel — see the section header above; every read of
  `qnf.2` goes through `b`, no arity-4 evaluation occurs), point/interval types provided by
  `charF k` (the depth-`k` E[Σ]-atom characteristic, Def 4.1 PDF p.5 — the `char_k1` role,
  KampPrior:307, passed as a parameter to avoid the KampPrior import cycle), interior-positive
  enumerations `S_L`/`S_R` over the depth-`k` fold output, and disjuncts via `bracketFromLists`
  (:1883) over `S_L.permutations × S_R.permutations` (rule N5 — the model-dependent witness
  ORDER is carried by the finite disjunction over linear arrangements, Rabinovich's ∨ over
  consistent order types, Def 3.1 pp.4-5 / §5; distinctness of realizing points for distinct
  complete 1-types is `nf_eval_unique`, NormalForm:245; same-type multiplicity is NOT encoded —
  fold bits are existential, one witness per positive pair). Endpoint literals sit at the FIXED
  endpoints (rule N4); the endpoint/witness BASE types (`xType`/`tType`/`nfYProj`) are the
  depth-0 characteristics of the atom-layer projections — the only self-type `qnf` carries
  syntactically.
- **Gate-failure branch**: the empty disjunction `⟨[]⟩` (its `holds` is `False`) — Rabinovich's
  empty disjunction over inconsistent order types.

Correctness (`BracketCarrierCorrectV`, k0-mirror conditional form) is Phase 13 (R3b). -/

/-- **Shared successor-case body of the depth-`k` V-carrier** (private builder, factored per
    Risk R6 like `bracketFromLists` :1883). Fully parametric in the two characteristic-formula
    providers (`charBase` for the depth-0 atom-layer projections, `charK` for the depth-`k`
    E[Σ]-atoms), the atom layer `r`, the off-fiber-falsity gate conjunct `offFiber`, and the
    fold-bit function `b`. `bracketEndCharK1v` (:1927) is DEFINITIONALLY this body at
    `charBase = charK = nfDepth0CharFormula`, `offFiber` = the depth-0 off-fiber clause, and
    `b` = the `efoldOfNf1` pointwise read (the `rfl` lemma `bracketEndChar_k1v_eq_kv_body`
    below), which is what makes the documented k=1 bridge `bracketEndChar_kv_one_eq` a pure
    split-kit computation. Structure and citations: see `bracketEndCharKv` above. -/
private noncomputable def kv_body {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3)
    (offFiber : Prop)
    (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : VVecEA2 :=
    -- Zone-spec constants relative to env `[w, x, t]` under the bracket order `x < w < t`
    -- (Def 3.1 ordering channel, PDF p.4), verbatim from `bracketEndCharK1v` (:1937-1948).
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
    let allTypes : List (NormalForm sig k 1) := Finset.univ.toList
    -- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5).
    let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
    -- Endpoint types (the FIXED `z_0 = x`, `z_1 = t`: Lemma 3.2(2) PDF p.4 + §5 bracket PDF p.7).
    let xType : TemporalPred := ⟨charBase (nfXProj3 r)⟩
    let tType : TemporalPred := ⟨charBase (nfTProj3 r)⟩
    let epL : TemporalPred :=
      ⟨formulaConjList
        (xType.formula
          :: (allTypes.map fun χ => lit (b zPastX χ) (Formula.snceQ Formula.top (charK χ)))
          ++ (allTypes.map fun χ => lit (b zAtX χ) (charK χ)))⟩
    let epR : TemporalPred :=
      ⟨formulaConjList
        (tType.formula
          :: (allTypes.map fun χ => lit (b zAtT χ) (charK χ))
          ++ (allTypes.map fun χ => lit (b zFutT χ) (Formula.untlQ Formula.top (charK χ))))⟩
    -- Segment types: universal exclusion of the interior-zone NEGATIVE bits.
    let segL : TemporalPred :=
      ⟨formulaConjList (allTypes.map fun χ =>
        if b zXW χ then Formula.top else (charK χ).neg)⟩
    let segR : TemporalPred :=
      ⟨formulaConjList (allTypes.map fun χ =>
        if b zWT χ then Formula.top else (charK χ).neg)⟩
    -- Witness point type at `w`: complete type + equality-zone bits ONLY (rule N4 — no
    -- interior chains; interior-positive content rides the witness slots below).
    let ptW : TemporalPred :=
      ⟨formulaConjList
        (charBase (nfYProj r)
          :: (allTypes.map fun χ => lit (b zAtW χ) (charK χ)))⟩
    -- Consistency of a zone spec with the bracket order `x < w < t` (the seven real zones).
    let consistent : ZoneSpec 3 → Prop := fun zs =>
      zs = zPastX ∨ zs = zAtX ∨ zs = zXW ∨ zs = zAtW ∨ zs = zWT ∨ zs = zAtT ∨ zs = zFutT
    -- The gate Prop (off-fiber honesty + order-conflict falsity), the two conjuncts of
    -- `bracketEndCharK1v`'s gate (:1985-1987) with the off-fiber clause a parameter.
    let gate : Prop :=
      offFiber ∧
      (∀ (zs : ZoneSpec 3) (χ : NormalForm sig k 1), ¬ consistent zs → b zs χ = false)
    -- Interior-positive enumerations (duplicate-free: `Finset.univ.toList`).
    let S_L : List (NormalForm sig k 1) := allTypes.filter (fun χ => b zXW χ)
    let S_R : List (NormalForm sig k 1) := allTypes.filter (fun χ => b zWT χ)
    let charP : NormalForm sig k 1 → TemporalPred := fun χ => ⟨charK χ⟩
    -- One disjunct per arrangement (rule N5): interior-positive pairs occupy WITNESS slots
    -- ordered between the fixed endpoints (§5 bracket, PDF p.7; Lemma 3.4, PDF p.5).
    let mkDisjunct : List (NormalForm sig k 1) → List (NormalForm sig k 1) → Σ n, VecEA2 n :=
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

/-! ## M1 refutation record — the F1 fold-information loss

The frozen `bracketEndCharKv` below FOLDS each marked arity-4 fiber `sub : NormalForm sig k 4`
down to the arity-1 pair `(nf0ZoneSpec (atomAssgn sub), nfkProjFresh sub)`. The fold is lossy —
carriers stay EQUAL across quant layers disagreeing on which marked sub realized a shared fiber
— and that F1 information loss is the M1 refutation record. The de-folded sibling carrier built
to avoid it is retired, unwired, in `Boneyard/Arity4CharStackK.lean`. -/

open Classical in
/-- **The depth-`k` V-carrier**. See the doc-comment block above
    `kv_body` for the full construction record and citations. `k = 0`: singleton-disjunct
    wrapper of `bracketEndCharK0` (:1567). `k + 1`: the shared successor body `kv_body` at the
    depth-`k` E[Σ]-atom provider `charF k`, the atom-layer off-fiber clause, and the
    fiber-existential fold-bit read (every read of `qnf.2` goes through it — no arity-4
    evaluation occurs). `open Classical in` (above this doc-comment): the fold-bit
    existential's `Decidable` instance is
    `Classical.propDecidable` (`ZoneSpec` is a plain `def`, so no `DecidableEq` synthesizes for
    it); the carrier is noncomputable anyway. -/
noncomputable def bracketEndCharKv {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    (k : Nat) → BracketEndCharCarrierV sig k
  | 0 => fun qnf => { disjuncts := [⟨1, bracketEndCharK0 atomMap h_surj qnf⟩] }
  | k + 1 => fun qnf =>
    kv_body (nfDepth0CharFormula atomMap h_surj) (charF k) qnf.1
      (∀ sub : NormalForm sig k 4,
        nf0DropFresh (NormalForm.atomAssgn sub) ≠ qnf.1 → qnf.2 sub = false)
      (fun zs χ => decide (∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
        nf0ZoneSpec (NormalForm.atomAssgn sub) = zs ∧ nfkProjFresh sub = χ))

/-- `bracketEndCharK1v` (:1927) is definitionally the shared successor body `kv_body` at the
    depth-0 providers, the depth-0 off-fiber clause, and the `efoldOfNf1` pointwise fold-bit
    read (`(efoldOfNf1 qnf).2 (zs, χ)` unfolds to `qnf.2 (nf0Assemble zs χ qnf.1)`,
    NfEFold:472). Pure `rfl` — no semantics. -/
private theorem bracketEndChar_k1v_eq_kv_body {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3) :
    bracketEndCharK1v atomMap h_surj qnf =
      kv_body (nfDepth0CharFormula atomMap h_surj) (nfDepth0CharFormula atomMap h_surj)
        qnf.1
        (∀ sub : NormalForm sig 0 4, nf0DropFresh sub ≠ qnf.1 → qnf.2 sub = false)
        (fun zs χ => qnf.2 (nf0Assemble zs χ qnf.1)) := rfl

/-- Gate-failure computation for the shared body: if the off-fiber conjunct fails, the gate
    fails and the body returns the empty disjunction (Rabinovich's empty disjunction over
    inconsistent order types). -/
private theorem kv_body_gate_fail {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3)
    (offFiber : Prop)
    (b : ZoneSpec 3 → NormalForm sig k 1 → Bool)
    (h : ¬ offFiber) :
    kv_body charBase charK r offFiber b = { disjuncts := [] } := by
  simp only [kv_body]
  exact dif_neg (fun hg => h hg.1)

open Classical in
/-- **Documented k=1 bridge lemma**: the `k = 1` specialization
    of `bracketEndCharKv` is pointwise EQUAL to the landed `bracketEndCharK1v` (:1927),
    whenever the provider family agrees with the depth-0 characteristic at depth 0 (which the
    Phase-14 instantiation does by construction, KampPrior:397 at depth 0 =
    `nfDepth0CharFormula`). Phase 13's step can therefore reuse the sorry-free
    `bracketEndChar_k1v_correct` (:3378) verbatim at the `k = 1` instance.

    Proof shape: when the off-fiber-falsity gate conjunct holds, the fiber-existential fold
    bit collapses to the `efoldOfNf1` pointwise read via the depth-0 split-kit round trips
    (`nf0_split_assemble`, NfEFold:235; `nf0_zoneSpec_assemble`/`nf0_projFresh_assemble`,
    NfEFold:197/206) — Def 3.1's three-channel bijection (PDF p.4). When it fails, both gates
    fail and both carriers return the empty disjunction (`kv_body_gate_fail`). No chain step is
    shortcut (G5): the equality is purely the split-kit bijection, no semantic evaluation
    occurs. (`open Classical in` matches the carrier's fold-bit `Decidable` instance.) -/
theorem bracketEndChar_kv_one_eq {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (h0 : charF 0 = nfDepth0CharFormula atomMap h_surj)
    (qnf : NormalForm sig 1 3) :
    bracketEndCharKv atomMap h_surj charF 1 qnf = bracketEndCharK1v atomMap h_surj qnf := by
  by_cases hOFF : ∀ sub : NormalForm sig 0 4, nf0DropFresh sub ≠ qnf.1 → qnf.2 sub = false
  · -- On-gate branch: the fiber-existential bit equals the pointwise `efoldOfNf1` read
    -- (split-kit bijection), so the two `kv_body` instances coincide argument-by-argument.
    have hbit : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
        (decide (∃ sub : NormalForm sig 0 4, qnf.2 sub = true ∧
          nf0ZoneSpec (NormalForm.atomAssgn sub) = zs ∧ nfkProjFresh sub = χ) : Bool) =
        qnf.2 (nf0Assemble zs χ qnf.1) := by
      intro zs χ
      cases hq : qnf.2 (nf0Assemble zs χ qnf.1) with
      | true =>
        -- Forward witness: the assembled sub itself, via the three round trips.
        rw [decide_eq_true_iff]
        refine ⟨nf0Assemble zs χ qnf.1, hq, ?_, ?_⟩
        · exact nf0_zoneSpec_assemble zs χ qnf.1
        · exact (nfk_projFresh_zero _).trans (nf0_projFresh_assemble zs χ qnf.1)
      | false =>
        -- Any fiber witness reassembles to the assembled sub (split-kit bijection),
        -- contradicting `hq` — so the existential is false.
        rw [decide_eq_false_iff_not]
        rintro ⟨sub, hsub, hzs, hproj⟩
        have hdrop : nf0DropFresh sub = qnf.1 := by
          by_contra hne
          rw [hOFF sub hne] at hsub
          exact Bool.noConfusion hsub
        have hassemble : nf0Assemble zs χ qnf.1 = sub := by
          have hsp := nf0_split_assemble sub
          rw [show nf0ZoneSpec sub = zs from hzs,
            show nf0ProjFresh sub = χ from ((nfk_projFresh_zero sub).symm.trans hproj),
            hdrop] at hsp
          exact hsp
        rw [hassemble] at hq
        rw [hq] at hsub
        exact Bool.noConfusion hsub
    have hb : (fun zs χ => (decide (∃ sub : NormalForm sig 0 4, qnf.2 sub = true ∧
          nf0ZoneSpec (NormalForm.atomAssgn sub) = zs ∧ nfkProjFresh sub = χ) : Bool)) =
        (fun zs χ => qnf.2 (nf0Assemble zs χ qnf.1)) :=
      funext fun zs => funext fun χ => hbit zs χ
    calc bracketEndCharKv atomMap h_surj charF 1 qnf
        = kv_body (nfDepth0CharFormula atomMap h_surj) (charF 0) qnf.1
            (∀ sub : NormalForm sig 0 4, nf0DropFresh sub ≠ qnf.1 → qnf.2 sub = false)
            (fun zs χ => decide (∃ sub : NormalForm sig 0 4, qnf.2 sub = true ∧
              nf0ZoneSpec (NormalForm.atomAssgn sub) = zs ∧ nfkProjFresh sub = χ)) := rfl
      _ = kv_body (nfDepth0CharFormula atomMap h_surj)
            (nfDepth0CharFormula atomMap h_surj) qnf.1
            (∀ sub : NormalForm sig 0 4, nf0DropFresh sub ≠ qnf.1 → qnf.2 sub = false)
            (fun zs χ => qnf.2 (nf0Assemble zs χ qnf.1)) := by rw [h0, hb]
      _ = bracketEndCharK1v atomMap h_surj qnf :=
          (bracketEndChar_k1v_eq_kv_body atomMap h_surj qnf).symm
  · -- Off-gate branch: both gates fail on their (shared, defeq) off-fiber conjunct; both
    -- carriers return the empty disjunction `⟨[]⟩` (`kv_body_gate_fail`).
    calc bracketEndCharKv atomMap h_surj charF 1 qnf
        = ({ disjuncts := [] } : VVecEA2) := kv_body_gate_fail _ _ _ _ _ hOFF
      _ = bracketEndCharK1v atomMap h_surj qnf := by
          -- The second step is a term-level `.symm`, not a second `rw`: `kv_body`'s `r`
          -- argument is `qnf.1`, elaborated at the unfolded component type, so the rewrite
          -- motive is not type-correct at `implicit` transparency and `rw` reports the
          -- (visibly present) pattern as absent.
          rw [bracketEndChar_k1v_eq_kv_body atomMap h_surj qnf]
          exact (kv_body_gate_fail _ _ _ _ _ hOFF).symm

/-! ## R3b: depth-`k` V-carrier correctness — landed instances -/

/-- **`k = 0` instance of the depth-`k` V-carrier correctness** (R3b — the
    recursion BASE). The `k = 0` branch of `bracketEndCharKv` (:3659) is the singleton-disjunct
    wrapper of `bracketEndCharK0` (:1567), so its `VVecEA2.holds` reduces to the `VecEA2.holds`
    of the landed depth-0 bracket and the equivalence is exactly `bracketEndChar_k0_correct`
    (:1581) — Prop 3.5 depth-0 collapse (PDF p.5); two-fixed-endpoint framing per Lemma 3.2(2)
    (PDF p.4) + §5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7), rule N1 split. No
    chain step is shortcut (G5): the singleton reduction is pure list computation, the semantic
    content is the consumed k0 lemma. Anchors stay the FIXED `{x, t}` (G4/G6). -/
theorem bracketEndChar_kv_correct_zero {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (qnf : NormalForm sig 0 3)
    (h_xy : qnf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndCharKv atomMap h_surj charF 0 qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  have hsing : (bracketEndCharKv atomMap h_surj charF 0 qnf).holds M atomMap x t ↔
      (bracketEndCharK0 atomMap h_surj qnf).holds M atomMap x t := by
    simp only [bracketEndCharKv, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  exact hsing.trans
    (bracketEndChar_k0_correct atomMap h_surj qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t)

/-- **`k = 1` instance of the depth-`k` V-carrier correctness** (R3b — the
    first successor step). Under the depth-0 provider agreement `h0` (satisfied by the Phase-14
    instantiation by construction, KampPrior:397 at depth 0), the documented k=1 bridge
    `bracketEndChar_kv_one_eq` (:3710, pointwise EQUALITY via the depth-0 split-kit bijection —
    Def 3.1's three-channel bijection, PDF p.4) rewrites the carrier to the landed
    `bracketEndCharK1v` (:1927), and the equivalence is the sorry-free
    `bracketEndChar_k1v_correct` (:3378) verbatim — the R2 = GO record. Citations ride the
    consumed lemma (rule N1 split there); no chain step is shortcut here (G5). -/
theorem bracketEndChar_kv_correct_one {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (h0 : charF 0 = nfDepth0CharFormula atomMap h_surj)
    (qnf : NormalForm sig 1 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndCharKv atomMap h_surj charF 1 qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  rw [bracketEndChar_kv_one_eq atomMap h_surj charF h0 qnf]
  exact bracketEndChar_k1v_correct atomMap h_surj qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t

open Classical in
/-- **Fiber-factorization of the depth-`k` V-carrier** (R3b — the machine-checked
    ISOLATION half of finding F1, recorded in the section comment below). At every successor
    depth the carrier is a function of the atom layer `qnf.1`, the atom-layer off-fiber Prop,
    and the fiber-existential fold bits ONLY: two quant layers that agree on this data yield
    EQUAL carriers, even when they disagree on the marking of individual depth-`k` arity-4 subs
    inside a shared `(zoneSpec, projFresh)` fiber. Pure congruence on `kv_body` (:3568) — no
    semantics. This is the information-loss channel that refutes the unconditional k≥2
    soundness direction of the plan-v5 Phase 13 target (see F1 below). -/
theorem bracketEndChar_kv_factors {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    {k : Nat} (qnf qnf' : NormalForm sig (k + 1) 3)
    (h1 : qnf.1 = qnf'.1)
    (hoff : (∀ sub : NormalForm sig k 4,
        nf0DropFresh (NormalForm.atomAssgn sub) ≠ qnf.1 → qnf.2 sub = false) ↔
      (∀ sub : NormalForm sig k 4,
        nf0DropFresh (NormalForm.atomAssgn sub) ≠ qnf'.1 → qnf'.2 sub = false))
    (hb : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig k 1),
        (∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
          nf0ZoneSpec (NormalForm.atomAssgn sub) = zs ∧ nfkProjFresh sub = χ) ↔
        (∃ sub : NormalForm sig k 4, qnf'.2 sub = true ∧
          nf0ZoneSpec (NormalForm.atomAssgn sub) = zs ∧ nfkProjFresh sub = χ)) :
    bracketEndCharKv atomMap h_surj charF (k + 1) qnf =
      bracketEndCharKv atomMap h_surj charF (k + 1) qnf' := by
  have e2 : (∀ sub : NormalForm sig k 4,
        nf0DropFresh (NormalForm.atomAssgn sub) ≠ qnf.1 → qnf.2 sub = false) =
      (∀ sub : NormalForm sig k 4,
        nf0DropFresh (NormalForm.atomAssgn sub) ≠ qnf'.1 → qnf'.2 sub = false) :=
    propext hoff
  have e3 : (fun (zs : ZoneSpec 3) (χ : NormalForm sig k 1) =>
        (decide (∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
          nf0ZoneSpec (NormalForm.atomAssgn sub) = zs ∧ nfkProjFresh sub = χ) : Bool)) =
      (fun (zs : ZoneSpec 3) (χ : NormalForm sig k 1) =>
        decide (∃ sub : NormalForm sig k 4, qnf'.2 sub = true ∧
          nf0ZoneSpec (NormalForm.atomAssgn sub) = zs ∧ nfkProjFresh sub = χ)) :=
    funext fun zs => funext fun χ => decide_eq_decide.mpr (hb zs χ)
  change kv_body (nfDepth0CharFormula atomMap h_surj) (charF k) qnf.1 _ _ =
    kv_body (nfDepth0CharFormula atomMap h_surj) (charF k) qnf'.1 _ _
  rw [e2, e3, h1]

/-- **Depth-1 per-sub obligation decomposition** (R3b sub-step — the exact literal
    shapes of the k=2 instance, fixed via the fold engine): a depth-1 arity-`n` evaluation
    splits into its atom layer plus the INSIDE-OUT folded quant layer — zone-bounded MONADIC
    depth-0 existentials over `(ZoneSpec n × NormalForm sig 0 1)` against the arity-`(n+1)`
    subs reassembled by `nf0Assemble`, plus the off-fiber falsity clause. Direct wrapper of
    `nf_quant_layer_fold_iff` (NfEFold:391 — Prop 4.3's innermost ∃-fold, PDF p.6, cited per
    rule N2 only for "the residual is ∨∃∀ over E[Σ] atoms"; the split-kit bijection
    `nf0_split_assemble` NfEFold:235 rides inside the engine — at `n = 4` this is the arity-5
    split of the plan's Phase-13.2 acceptance). Phase 13.3 consumes this at `n = 4`, env
    `[u, w, x, t]`, `σ : NormalForm sig 1 4` — each positive sub's inner layer is depth-0 at
    the k=2 instance, so this lemma IS the A2 inside-out discharge shape (Def 4.1 p.6 note). -/
theorem nf_eval_depth1_fold_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (σ : NormalForm sig 1 n) :
    NfEvalNf M 1 n env σ ↔
      ((∀ a : AtomKind sig n, AtomEval M env a ↔ σ.1 a = true) ∧
       ((∀ (zs : ZoneSpec n) (χ : NormalForm sig 0 1),
           (∃ v : M.carrier, zoneHolds M env zs v ∧
             NfEvalNf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0Assemble zs χ σ.1) = true) ∧
        (∀ τ : NormalForm sig 0 (n + 1), nf0DropFresh τ ≠ σ.1 → σ.2 τ = false))) := by
  constructor
  · rintro ⟨h_atom, h_quant⟩
    exact ⟨h_atom, (nf_quant_layer_fold_iff M env σ.1 h_atom σ.2).mp h_quant⟩
  · rintro ⟨h_atom, h_fold⟩
    exact ⟨h_atom, (nf_quant_layer_fold_iff M env σ.1 h_atom σ.2).mpr h_fold⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
