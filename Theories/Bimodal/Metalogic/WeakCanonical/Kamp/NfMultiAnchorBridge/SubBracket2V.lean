import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket2

/-! Extracted from NfMultiAnchorBridge.lean lines 6734-8585 (task 331).
Task-325/326 protected slab, byte-identical, token edits NONE. (Slab cut adjusted from the
plan's :6734-:8607 to :6734-:8585 so that the `open Classical in` + doc comment :8586-:8607
stays attached to its declaration `kvE2_body` :8608 in the monolith — a dangling doc comment
cannot parse; partition change only, every line remains byte-identical to ORIG_SHA.)

# FAITHFUL SEPARATE-BRACKET API (Rabinovich 2014)

This module is the faithful separate-bracket route for the k=2 gate. Source mapping
(Rabinovich 2014, "A Proof of Kamp's Theorem"; `md:` line refs are to the Literature chunk
`Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`):

- **Def 3.1** exists-forall bracket / interval decomposition (md:61-74) → `kvE_subBracket2V`
  (with `bracketFromLists3`, private plumbing).
- **Cor 5.4** F_i-chain reduction (md:154-157) → `kvE_subChain2V` (per-arrangement chain as a
  single `TemporalPred`).
- **Lemma 5.1** point insertion, per-σ half (md:134-135) → `kvE_subBracket2V_correctness_pair`.
- **Correctness kit**: `kvE_subBracket2V_sound` / `_sound_of_parts` / `_sound_of_outer` /
  `_gate_holds_of_honest` / `_nonvacuous` / `_complete`.
- **Cross-references** (external combinators, not in this file): **Lemma 3.2(2)** 2-var
  reduction (md:78) → `neg_2var_vec_ea` (`EANegationClosure.lean:722`); **Lemma 3.4**
  V-exists-forall closure (md:84-85) → `VVecEA2.conj_struct` (`VecEAClosure.lean:195`).
- **NOTE (task 321 boundary)**: the shared-interior-witness conjunction (`∃ w, ⋀_σ ...`) —
  the outer quant-layer connector joining the per-σ halves — is the ONE unbuilt object.
  It is owned by task 321; this module deliberately provides only the per-σ half.

`bracketFromLists_flatMap_subchain_below_pin` stays in this module (private): its only code
consumers are the task-326 `_of_outer` closers here. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Task 325 Phase 1: `VVecEA2` arrangement-disjunction carrier (redesign)

Additive, separately-named redesign of the task-324 k=2 sub-bracket (task 325 Phase 1; plan
`plans/01_vvecea2-carrier-redesign.md`). The landed `kvE_subBracket2` (:6120) returns a single
`Σ m, BracketFormula (m+1)` with a CONSTANT tri-zone `segmentTypes ≡ segExcl` (:6159) and a FIXED
filter-order `pointTypes`; its completeness converse is a machine-confirmed false ∀-M statement
(task 324 Phase 6). This block delivers, STANDALONE against `nf_eval_nf M 1 4` and NOT wired into the
outer gate, a corrected carrier `kvE_subBracket2V` whose codomain is `VVecEA2` (the arrangement
disjunction, VecEAFormula:271) with THREE per-region segment types `segXU`/`segUW`/`segWT` and TWO
interior witness slots `x1`/`w`. It LIFTS `bracketEndChar_k1v` (:1940) one region up: k1v's
`bracketFromLists lL ptW lR` (:1896, a 2-region `lL ++ ptW :: lR` with two segments `segL`/`segR`)
becomes `bracketFromLists3 lXU ptX1 lUW ptW lWT` (a 3-region `lXU ++ ptX1 :: lUW ++ ptW :: lWT` with
three per-region segments). Env `[x1, w, x, t]` under honest order `x < x1 < w < t` (coords
`0 ↦ x1`, `1 ↦ w`, `2 ↦ x`, `3 ↦ t`) — identical coordinate layout to task-324's `[u, w, x, t]`, so
the SURVIVE zone specs `kvE_sub2_zXU`/`_zUW`/`_zWT` (:6200-6208) are the same three interior zones.
Every landed asset stays byte-identical AND unreferenced. `σ.2` is read through the depth-0
`nf0_assemble` fold engine directly (consume-do-not-rebuild), same as `kvE_subBracket2` :6127.
No `simp`/`omega`/`aesop` in any body (the `omega` is a `Fin`-index typing obligation in a proof
term, identical to `bracketFromLists` :1900). Rabinovich Def 3.1 (md:61-74), Def 4.1 (PDF p.5), §5
bracket `[α_0, …, α_n](z_0, z_1)` (PDF p.7), Cor 5.4 recursive per-region chain (md:154-157). -/

/-- **Arity-4 (three-region) lift of `bracketFromLists`** (:1896; task 325 Phase 1). Assemble a
    `BracketFormula` over the two FIXED endpoints `{x, t}` from THREE ordered witness-type lists
    `lXU`/`lUW`/`lWT` and TWO interior witness-slot point types `ptX1` (between `lXU` and `lUW`) and
    `ptW` (between `lUW` and `lWT`), with THREE per-region segment types. Point types are
    `lXU ++ ptX1 :: lUW ++ ptW :: lWT` — the §5 bracket `[α_0, …, α_n](z_0, z_1)` (PDF p.7) with
    `z_0, z_1` the FIXED endpoints and `x1`/`w` interior WITNESS slots. Segment types are `segXU` on
    every sub-segment of `(x, x1)` (index `≤ lXU.length`), `segUW` on every sub-segment of `(x1, w)`
    (index `≤ lXU.length + 1 + lUW.length`), and `segWT` on every sub-segment of `(w, t)` — real
    PER-REGION exclusion segments, NEVER a constant tri-zone `segExcl` (G3; Rabinovich Cor 5.4
    md:154-157). The arity is written `… + 1 + 1` so `fChainPred` (which needs a `_ + 1` arity) is
    available. -/
private def bracketFromLists3 (lXU : List TemporalPred) (ptX1 : TemporalPred)
    (lUW : List TemporalPred) (ptW : TemporalPred) (lWT : List TemporalPred)
    (segXU segUW segWT : TemporalPred) :
    BracketFormula (lXU.length + lUW.length + lWT.length + 1 + 1) where
  pointTypes := fun i =>
    (lXU ++ ptX1 :: lUW ++ ptW :: lWT)[i.val]'(by
      have := i.isLt
      simp only [List.length_append, List.length_cons]
      omega)
  segmentTypes := fun i =>
    if i.val ≤ lXU.length then segXU
    else if i.val ≤ lXU.length + 1 + lUW.length then segUW
    else segWT

/-- **fChainPred F_0 below-witness extraction from the inner bracket** (task 326 Phase 3). For an
    inner `bracketFromLists3` whose `zXU`-region point-type list is NON-EMPTY (`χ0 :: lXU'` — the
    first `zXU` arrangement type `χ0`, `= ⟨charBase χ⟩` at the k=2 gate), a `.holds` at the inner
    endpoints `(z0, z)` realizes the FIRST point type `χ0` at some `u ∈ (z0, z)`. This is the
    forward `fChainPred → (pointTypes 0)` datum (Cor 5.4 sidestepped — pure forward direction):
    `bracket_implies_fChainPred` (`EANegation.lean:660`) yields `F_0(u)`; unfolding the F-chain
    one step at index 0 via `fChainFrom_step` (`EANegation.lean:616`, never the base case since the
    `+ 1 + 1` arity keeps `0 < n`) extracts `(pointTypes 0).eval_at u`; and `pointTypes 0 = χ0`
    holds by the head of the concatenated point list `(χ0 :: lXU') ++ ptX1 :: lUW ++ ptW :: lWT`
    (`bracketFromLists3` `:6741-6745`). At assembly the endpoints instantiate to give `x < u < q`
    (the `< q` bound inherited from Phase 1's block ordering; here the general `z0 < u < z` form).

    Rabinovich 2014 **Lemma 5.3** (md:137-152): each arrangement's fresh depth-`k` type splits its
    interval positionally; the first point of the `zXU` region is the below-anchor F_0 witness. -/
private theorem bracketFromLists3_fChainPred_head_extract {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (χ0 : TemporalPred) (lXU' lUW lWT : List TemporalPred)
    (ptX1 ptW segXU segUW segWT : TemporalPred)
    (z0 z : M.carrier)
    (h : (bracketFromLists3 (χ0 :: lXU') ptX1 lUW ptW lWT segXU segUW segWT).holds
          M atomMap z0 z) :
    ∃ u : M.carrier, z0 < u ∧ u < z ∧ χ0.eval_at M atomMap u := by
  set bf := bracketFromLists3 (χ0 :: lXU') ptX1 lUW ptW lWT segXU segUW segWT with hbf
  -- Forward direction (Cor 5.4 sidestepped): the first bracket witness satisfies F_0.
  obtain ⟨x0, hz0x0, hx0z, hfchain, -⟩ :=
    BracketFormula.bracket_implies_fChainPred M atomMap bf z0 z h
  -- Index-0 is a STEP (never the base case): `0 < n` since the arity ends in `+ 1`. State the
  -- bound with a concrete type so it is not blocked on the inferred arity metavariable.
  have hlt0 : (0 : Nat) < (χ0 :: lXU').length + lUW.length + lWT.length + 1 := by
    simp only [List.length_cons]; omega
  -- Unfold F_0 and take one forward step at index 0.
  unfold BracketFormula.fChainPred at hfchain
  have hstep := (BracketFormula.fChainFrom_step M atomMap bf
      ⟨0, Nat.lt_succ_of_lt hlt0⟩ hlt0 x0).mp hfchain
  -- The first point type is `χ0` (head of the concatenated point list).
  have hpt0 : bf.pointTypes ⟨0, Nat.lt_succ_of_lt hlt0⟩ = χ0 := by
    rw [hbf]
    simp only [bracketFromLists3, List.cons_append, List.getElem_cons_zero]
  rw [hpt0] at hstep
  exact ⟨x0, hz0x0, hx0z, hstep.1⟩

/-- **`VVecEA2` arrangement-disjunction carrier** (task 325 Phase 1; plan Phase 1). The corrected
    codomain-changed replacement for `kvE_subBracket2` (:6120): a finite disjunction `VVecEA2`
    (VecEAFormula:271) over arrangements `S_XU.permutations × S_UW.permutations × S_WT.permutations`,
    where `S_z = allTypes.filter (bits z)` is the duplicate-free list of interior-positive 1-types of
    region `z`. Each disjunct's point-type layout is `zXU-arrangement ++ [x1-slot] ++
    zUW-arrangement ++ [w-slot] ++ zWT-arrangement` (three-region lift of `bracketEndChar_k1v`
    :2016-2018), with THREE per-region segment types (never the refuted constant `segExcl`). `x1`/`w`
    are interior WITNESS slots (anchor set stays `{x, t}`; G4/Cap): `x1` is the fresh depth-1
    existential witness (`nfk_projFresh σ`, coord 0), `w` enters as a witness TYPE slot — `charBase`
    of `w`'s coord-1 projection (Amendment F3: no provider pinning, realized by 1-type uniqueness).
    Gate-failure branch is the empty disjunction `{ disjuncts := [] }` (its `holds` is `False`).
    Reads `σ.2 ∘ nf0_assemble` at gate instance `j = 0` (Def 4.1, PDF p.5). -/
noncomputable def kvE_subBracket2V {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : VVecEA2 :=
  -- Sub-level fold-bit read (Def 4.1, PDF p.5): `σ.2 ∘ nf0_assemble` at the gate instance j = 0,
  -- inlined (consume-do-not-rebuild) so no landed sub-bracket symbol is referenced.
  let bits : ZoneSpec 4 → NormalForm sig 0 1 → Bool :=
    fun zs χ => σ.2 (nf0_assemble zs χ σ.1)
  let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
  -- Zone-spec constants relative to σ's env `[x1, w, x, t]` under honest order `x < x1 < w < t`
  -- (coords 0 ↦ x1, 1 ↦ w, 2 ↦ x, 3 ↦ t); same coordinate layout as `kvE_subInteriorZones` :5751
  -- and the SURVIVE zone specs `kvE_sub2_zXU`/`_zUW`/`_zWT` :6200-6208.
  let ltz : Bool × Bool := (true, false)   -- v < env i
  let eqz : Bool × Bool := (false, false)  -- v = env i
  let gtz : Bool × Bool := (false, true)   -- env i < v
  let mk4 : Bool × Bool → Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 4 :=
    fun p0 p1 p2 p3 => Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3)))
  -- Three interior zones (Def 3.1 md:61-74), defeq to `kvE_sub2_zXU`/`_zUW`/`_zWT` :6200-6208.
  let zXU : ZoneSpec 4 := mk4 ltz ltz gtz ltz   -- x < v < x1
  let zUW : ZoneSpec 4 := mk4 gtz ltz gtz ltz   -- x1 < v < w
  let zWT : ZoneSpec 4 := mk4 gtz gtz gtz ltz   -- w < v < t
  -- Two interior WITNESS SELF-ZONES (v2 nine-zone correction; Def 3.1 md:61-74). Every honest σ
  -- realizes x1 at its own self-zone (and w at its), so `nf_eval_depth1_fold_iff` (:5187) forces
  -- `bits zAtX1 = true` (resp. `bits zAtW = true`); these MUST therefore be gate-consistent, else
  -- the gate is unsatisfiable (the machine-verified v1 empty-gate blocker). k1v folds its single
  -- witness self-zone `zAtW` :3277; the arity-4 carrier has TWO interior witnesses ⇒ two self-zones.
  let zAtX1 : ZoneSpec 4 := mk4 eqz ltz gtz ltz   -- v = x1
  let zAtW  : ZoneSpec 4 := mk4 gtz eqz gtz ltz   -- v = w
  -- Exterior zones for the two FIXED endpoints (Def 3.1 md:61-74).
  let zPastX : ZoneSpec 4 := mk4 ltz ltz ltz ltz   -- v < x
  let zAtX   : ZoneSpec 4 := mk4 ltz ltz eqz ltz   -- v = x
  let zAtT   : ZoneSpec 4 := mk4 gtz gtz gtz eqz   -- v = t
  let zFutT  : ZoneSpec 4 := mk4 gtz gtz gtz gtz   -- t < v
  -- Depth-0 coordinate projections of σ's base env `σ.1 : NormalForm sig 0 4` (Def 3.1, PDF p.4;
  -- arity-4 analog of `nf_x_proj3`/`nf_t_proj3` VecEADecomp:40/47).
  let proj : Fin 4 → NormalForm sig 0 1 := fun k =>
    fun a => match a with
      | .pred p _ => σ.1 (.pred p k)
      | .order i j h => absurd (Subsingleton.elim i j) h
  -- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5).
  let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
  -- Endpoint types at the FIXED `z_0 = x` (coord 2), `z_1 = t` (coord 3): Lemma 3.2(2), PDF p.4.
  let xType : TemporalPred := ⟨charBase (proj 2)⟩
  let tType : TemporalPred := ⟨charBase (proj 3)⟩
  let epL : TemporalPred :=
    ⟨formula_conjList
      (xType.formula
        :: (allTypes.map fun χ => lit (bits zPastX χ) (Formula.snce (charBase χ) Formula.top))
        ++ (allTypes.map fun χ => lit (bits zAtX χ) (charBase χ)))⟩
  let epR : TemporalPred :=
    ⟨formula_conjList
      (tType.formula
        :: (allTypes.map fun χ => lit (bits zAtT χ) (charBase χ))
        ++ (allTypes.map fun χ => lit (bits zFutT χ) (Formula.untl (charBase χ) Formula.top)))⟩
  -- THREE per-region segment types: each excludes ONLY its own region's interior negatives (real
  -- exclusion segments, G3; arity-4 lift of `bracketFromLists.segmentTypes` :1902 from a 2-way to a
  -- 3-way keying). NOT the constant tri-zone `segExcl` of the refuted :6149. Rabinovich Cor 5.4
  -- (md:154-157): every point of region `(x, x1)` is `zXU`-positive there, etc.
  let segXU : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zXU χ then Formula.top else (charBase χ).neg)⟩
  let segUW : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zUW χ then Formula.top else (charBase χ).neg)⟩
  let segWT : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zWT χ then Formula.top else (charBase χ).neg)⟩
  -- Interior witness-slot point types (§5 bracket, PDF p.7): `x1` is the fresh depth-1 existential
  -- witness (coord 0, `nfk_projFresh σ`); `w` is the given interior anchor entering as a witness
  -- TYPE slot (Amendment F3 — no provider pinning; `charBase` of `w`'s coord-1 projection, realized
  -- by 1-type uniqueness).
  -- Witness self-type FOLDING (v2 nine-zone correction; arity-4 analog of k1v `hptW` :3277). Each
  -- witness point type carries its complete type (head) PLUS its own self-zone's 1-type literals, so
  -- soundness can re-derive the self-zone membership and completeness can discharge the witness
  -- point. Amendment F3 preserved: a zone-literal fold on the complete 1-type, NOT a `w = e 1`
  -- provider equation. `ptX1` folds `zAtX1`; `ptW` folds `zAtW`.
  let ptX1 : TemporalPred :=
    ⟨formula_conjList
      (charK (nfk_projFresh σ)
        :: (allTypes.map fun χ => lit (bits zAtX1 χ) (charBase χ)))⟩
  let ptW : TemporalPred :=
    ⟨formula_conjList
      (charBase (proj 1)
        :: (allTypes.map fun χ => lit (bits zAtW χ) (charBase χ)))⟩
  let charP : NormalForm sig 0 1 → TemporalPred := fun χ => ⟨charBase χ⟩
  -- Interior-positive enumerations, per region (duplicate-free `Finset.univ.toList`).
  let S_XU : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zXU χ)
  let S_UW : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zUW χ)
  let S_WT : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zWT χ)
  -- Consistency of a zone spec with the bracket order `x < x1 < w < t` (NINE real zones: the seven
  -- exterior/interior zones PLUS the two interior witness self-zones `zAtX1`, `zAtW` — the v2
  -- correction of the v1 empty-gate blocker, mirroring k1v's inclusion of its witness self-zone).
  let consistent : ZoneSpec 4 → Prop := fun zs =>
    zs = zPastX ∨ zs = zAtX ∨ zs = zXU ∨ zs = zAtX1 ∨ zs = zUW ∨ zs = zAtW ∨ zs = zWT ∨
      zs = zAtT ∨ zs = zFutT
  -- Gate (off-fiber honesty + order-conflict falsity): the arity-4 analog of k1v :1998.
  let gate : Prop :=
    (∀ sub : NormalForm sig 0 5, nf0_dropFresh sub ≠ σ.1 → σ.2 sub = false) ∧
    (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), ¬ consistent zs → bits zs χ = false)
  -- One disjunct per arrangement (rule N5): interior-positive pairs occupy WITNESS slots ordered
  -- between the fixed endpoints across the THREE regions `zXU`/`zUW`/`zWT`.
  let mkDisjunct :
      List (NormalForm sig 0 1) → List (NormalForm sig 0 1) → List (NormalForm sig 0 1) →
        Σ n, VecEA2 n :=
    fun lXU lUW lWT =>
      ⟨(lXU.map charP).length + (lUW.map charP).length + (lWT.map charP).length + 1 + 1,
        { endpointLeft := epL
          endpointRight := epR
          bracket := bracketFromLists3 (lXU.map charP) ptX1 (lUW.map charP) ptW (lWT.map charP)
            segXU segUW segWT }⟩
  @dite _ gate (Classical.dec gate)
    (fun _ =>
      { disjuncts :=
          S_XU.permutations.flatMap fun lXU =>
            S_UW.permutations.flatMap fun lUW =>
              S_WT.permutations.map fun lWT => mkDisjunct lXU lUW lWT })
    (fun _ => { disjuncts := [] })

/-- **Three-region sub-chain accessor over the `VVecEA2` disjunct carrier** (task 325 Phase 1;
    analog of `kvE_subChain2` :6166 adapted to the disjunction shape). `kvE_subChain2` was the
    single bracket's `fChainPred`; here the carrier is a disjunction, so the accessor is the list of
    per-arrangement `fChainPred`s — one Cor 5.4 F_i-chain (md:154-157) per disjunct, each evaluated
    over the three-region bracket `bracketFromLists3` (whose `… + 1` arity makes `fChainPred`
    available). The k1v soundness/completeness templates reason per-disjunct rather than through a
    single chain, so this accessor is provided for interface parity with the landed k=2 kit. -/
noncomputable def kvE_subChain2V {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : List TemporalPred :=
  let bits : ZoneSpec 4 → NormalForm sig 0 1 → Bool :=
    fun zs χ => σ.2 (nf0_assemble zs χ σ.1)
  let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
  let ltz : Bool × Bool := (true, false)
  let gtz : Bool × Bool := (false, true)
  let mk4 : Bool × Bool → Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 4 :=
    fun p0 p1 p2 p3 => Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3)))
  let zXU : ZoneSpec 4 := mk4 ltz ltz gtz ltz
  let zUW : ZoneSpec 4 := mk4 gtz ltz gtz ltz
  let zWT : ZoneSpec 4 := mk4 gtz gtz gtz ltz
  let proj : Fin 4 → NormalForm sig 0 1 := fun k =>
    fun a => match a with
      | .pred p _ => σ.1 (.pred p k)
      | .order i j h => absurd (Subsingleton.elim i j) h
  let segXU : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zXU χ then Formula.top else (charBase χ).neg)⟩
  let segUW : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zUW χ then Formula.top else (charBase χ).neg)⟩
  let segWT : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zWT χ then Formula.top else (charBase χ).neg)⟩
  let ptX1 : TemporalPred := ⟨charK (nfk_projFresh σ)⟩
  let ptW : TemporalPred := ⟨charBase (proj 1)⟩
  let charP : NormalForm sig 0 1 → TemporalPred := fun χ => ⟨charBase χ⟩
  let S_XU : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zXU χ)
  let S_UW : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zUW χ)
  let S_WT : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zWT χ)
  S_XU.permutations.flatMap fun lXU =>
    S_UW.permutations.flatMap fun lUW =>
      S_WT.permutations.map fun lWT =>
        (bracketFromLists3 (lXU.map charP) ptX1 (lUW.map charP) ptW (lWT.map charP)
          segXU segUW segWT).fChainPred

/-- **F_0 head extraction from a realized sub-chain `fChainPred`** (task 326 Phase 4.2 helper).
    Companion to `bracketFromLists3_fChainPred_head_extract` (:6794), but consuming the
    `fChainPred` point type *already realized at a single point `u`* (the shape delivered by the
    OUTER bracket, which realizes each `kvE_subChain2V` slot as one of its witness point types),
    rather than an inner bracket `.holds`. Reads off F_0's first point type at `u` itself: since
    `fChainPred = fChainFrom 0` and the step characterization (`fChainFrom_step`) gives
    `(pointTypes 0).eval_at u` as the head conjunct, and `pointTypes 0` is the head `χ0` of the
    concatenated point list, the below-witness IS `u`. NO reverse Cor 5.4, NO bracket
    reconstruction; a pure forward read of the F_0 chain head (Rabinovich Cor 5.4 forward,
    md:154-157). -/
private theorem bracketFromLists3_fChainPred_at_head {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (χ0 : TemporalPred) (lXU' lUW lWT : List TemporalPred)
    (ptX1 ptW segXU segUW segWT : TemporalPred)
    (u : M.carrier)
    (h : (bracketFromLists3 (χ0 :: lXU') ptX1 lUW ptW lWT segXU segUW segWT).fChainPred.eval_at
          M atomMap u) :
    χ0.eval_at M atomMap u := by
  set bf := bracketFromLists3 (χ0 :: lXU') ptX1 lUW ptW lWT segXU segUW segWT with hbf
  have hlt0 : (0 : Nat) < (χ0 :: lXU').length + lUW.length + lWT.length + 1 := by
    simp only [List.length_cons]; omega
  unfold BracketFormula.fChainPred at h
  have hstep := (BracketFormula.fChainFrom_step M atomMap bf
      ⟨0, Nat.lt_succ_of_lt hlt0⟩ hlt0 u).mp h
  have hpt0 : bf.pointTypes ⟨0, Nat.lt_succ_of_lt hlt0⟩ = χ0 := by
    rw [hbf]
    simp only [bracketFromLists3, List.cons_append, List.getElem_cons_zero]
  rw [hpt0] at hstep
  exact hstep.1

/-- **`hbelow` assembly over the sub-chain arrangements** (task 326 Phase 4.2 — make-or-break).
    For an arbitrary `zXU`-positive `χ` (`σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true`, i.e.
    `χ ∈ S_XU`), given that every sub-chain `fChainPred` slot of `kvE_subChain2V σ` is realized
    strictly inside `(x, q)` (`hreal` — the finished order facts delivered by Phase 1's block
    extraction placing all sub-chain points below the first pin `q`, Phase 2), produce a
    below-anchor witness `∃ u, x < u ∧ u < q ∧ ⟨charBase χ⟩.eval_at u`. This is `hbelow(q)`.

    Route (Rabinovich 2014 **Lemma 5.3**, md:137-152 — permutation/arrangement coverage; forward
    direction only, Cor 5.4 SIDESTEPPED): `exists_permutation_cons_head` (Phase 4.1) exhibits the
    arrangement whose `lXU` permutation HEADS with `χ`; that arrangement's `fChainPred` is a member
    of `kvE_subChain2V σ` (the `S_XU.permutations` flatMap carries EVERY permutation), so `hreal`
    realizes it at some `u ∈ (x, q)`; `bracketFromLists3_fChainPred_at_head` reads off the F_0 head
    `pointTypes 0 = ⟨charBase χ⟩` AT `u`. The `< q` bound rides Phase 1's monotone block ordering
    carried in `hreal`, NEVER a formula literal (litmus PASS). Universally quantified over
    `χ ∈ S_XU`. -/
private theorem kvE_subChain2V_hbelow_of_realized {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x q : M.carrier)
    (hreal : ∀ fcp ∈ kvE_subChain2V charBase charK σ,
        ∃ u : M.carrier, x < u ∧ u < q ∧ fcp.eval_at M atomMap u) :
    ∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
      ∃ u : M.carrier, x < u ∧ u < q ∧
        (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  intro χ hbit
  -- (1) `χ ∈ S_XU`: the `zXU` fold bit is set, so `χ` survives the interior-positive filter.
  --     `exists_permutation_cons_head` (Phase 4.1) hands the arrangement whose `lXU` HEADS with `χ`.
  obtain ⟨rest, hperm⟩ := exists_permutation_cons_head (χ := χ)
      (l := Finset.univ.toList.filter (fun ν => σ.2 (nf0_assemble kvE_sub2_zXU ν σ.1)))
      (List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ _), hbit⟩)
  -- (2) That arrangement's `fChainPred` is a member of `kvE_subChain2V σ` (the `S_XU.permutations`
  --     flatMap carries EVERY permutation; `lUW`/`lWT` take the identity permutation). Realize it
  --     in `(x, q)` via `hreal` — the membership proof fills the `fcp` slot.
  obtain ⟨u, hxu, huq, hu⟩ := hreal _ (by
    simp only [kvE_subChain2V, List.mem_flatMap, List.mem_map]
    exact ⟨χ :: rest, hperm, _, List.mem_permutations.mpr (List.Perm.refl _),
      _, List.mem_permutations.mpr (List.Perm.refl _), rfl⟩)
  -- (3) F_0 head read-off (Phase 4.2 helper): the below-witness IS the realization point `u`.
  exact ⟨u, hxu, huq, bracketFromLists3_fChainPred_at_head M atomMap _ _ _ _ _ _ _ _ _ u hu⟩

/-- **Three-region arrangement selection** (task 325 Phase 2; lift of `k1v_sorted_realization`
    :2797 from two regions to three). Given three duplicate-free interior-positive type lists
    `S_XU`/`S_UW`/`S_WT`, each realized somewhere strictly inside its own open region `(x, x1)` /
    `(x1, w)` / `(w, t)`, produce three arrangements — permutations of the three lists tagged with
    realizing points — whose combined witness list `psXU ++ x1 :: psUW ++ w :: psWT` (in model
    order) is strictly increasing. Runs the per-region insertion induction `k1v_sorted_realization`
    (Rabinovich Lemma 5.1 md:134-135) once per region, then stitches the three sorted blocks around
    the two fixed interior witnesses `x1`/`w` (Def 3.1 strictly-increasing witnesses md:61-74). The
    `VVecEA2` disjunction carries every arrangement (rule N5), so the arrangement selected here
    always names an existing disjunct. -/
private theorem k1v_sorted_realization3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (x x1 w t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (S_XU S_UW S_WT : List (NormalForm sig 0 1))
    (hndXU : S_XU.Nodup) (hndUW : S_UW.Nodup) (hndWT : S_WT.Nodup)
    (hrealXU : ∀ χ ∈ S_XU, ∃ u, x < u ∧ u < x1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hrealUW : ∀ χ ∈ S_UW, ∃ u, x1 < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hrealWT : ∀ χ ∈ S_WT, ∃ u, w < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ) :
    ∃ (psXU psUW psWT : List (NormalForm sig 0 1 × M.carrier)),
      List.Perm (psXU.map Prod.fst) S_XU ∧
      List.Perm (psUW.map Prod.fst) S_UW ∧
      List.Perm (psWT.map Prod.fst) S_WT ∧
      (psXU.map Prod.snd ++ x1 :: psUW.map Prod.snd ++ w :: psWT.map Prod.snd).Pairwise (· < ·) ∧
      (∀ p ∈ psXU, (x < p.2 ∧ p.2 < x1) ∧ nf_eval_nf M 0 1 (fun _ => p.2) p.1) ∧
      (∀ p ∈ psUW, (x1 < p.2 ∧ p.2 < w) ∧ nf_eval_nf M 0 1 (fun _ => p.2) p.1) ∧
      (∀ p ∈ psWT, (w < p.2 ∧ p.2 < t) ∧ nf_eval_nf M 0 1 (fun _ => p.2) p.1) := by
  -- Per-region insertion induction (Rabinovich Lemma 5.1 md:134-135), once per region.
  obtain ⟨psXU, hpermXU, hsortXU, hpropsXU⟩ :=
    k1v_sorted_realization M x x1 S_XU hndXU hrealXU
  obtain ⟨psUW, hpermUW, hsortUW, hpropsUW⟩ :=
    k1v_sorted_realization M x1 w S_UW hndUW hrealUW
  obtain ⟨psWT, hpermWT, hsortWT, hpropsWT⟩ :=
    k1v_sorted_realization M w t S_WT hndWT hrealWT
  refine ⟨psXU, psUW, psWT, hpermXU, hpermUW, hpermWT, ?_, hpropsXU, hpropsUW, hpropsWT⟩
  -- Stitch the three sorted blocks around `x1` and `w` (Def 3.1 strictly-increasing witnesses).
  -- Every `psUW` point exceeds `x1`; every point of the left block `psXU ++ x1 :: psUW` is < w.
  have hUW_gt_x1 : ∀ b ∈ psUW.map Prod.snd, x1 < b := by
    intro b hb
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hb
    exact (hpropsUW p hp).1.1
  have hWT_gt_w : ∀ b ∈ psWT.map Prod.snd, w < b := by
    intro b hb
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hb
    exact (hpropsWT p hp).1.1
  have hleft_lt_w : ∀ a ∈ psXU.map Prod.snd ++ x1 :: psUW.map Prod.snd, a < w := by
    intro a ha
    rcases List.mem_append.mp ha with ha | ha
    · obtain ⟨p, hp, rfl⟩ := List.mem_map.mp ha
      exact ((hpropsXU p hp).1.2).trans hx1w
    · rcases List.mem_cons.mp ha with rfl | ha
      · exact hx1w
      · obtain ⟨p, hp, rfl⟩ := List.mem_map.mp ha
        exact (hpropsUW p hp).1.2
  rw [List.pairwise_append]
  refine ⟨?_, ?_, ?_⟩
  · -- Left block `psXU ++ x1 :: psUW` is sorted.
    rw [List.pairwise_append]
    refine ⟨hsortXU, ?_, ?_⟩
    · rw [List.pairwise_cons]
      exact ⟨hUW_gt_x1, hsortUW⟩
    · intro a ha b hb
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp ha
      have hax1 : p.2 < x1 := (hpropsXU p hp).1.2
      rcases List.mem_cons.mp hb with rfl | hb
      · exact hax1
      · exact hax1.trans (hUW_gt_x1 b hb)
  · -- Right block `w :: psWT` is sorted.
    rw [List.pairwise_cons]
    exact ⟨hWT_gt_w, hsortWT⟩
  · -- Cross: every left-block point < every right-block point.
    intro a ha b hb
    have haw : a < w := hleft_lt_w a ha
    rcases List.mem_cons.mp hb with rfl | hb
    · exact haw
    · exact haw.trans (hWT_gt_w b hb)

/-- **k-region interleave** (task 334 Phase 3; Def 3.1 interval decomposition, Rabinovich md:61-74).
    Stitches a list of region blocks into a single witness list, interspersing each region's RIGHT
    interior anchor (`e.2.1`) between consecutive blocks and DROPPING the final region's right anchor
    (it is the fixed outer endpoint `a_k`, excluded from the witness list exactly as
    `k1v_sorted_realization3` excludes `t`). Each entry is `(loᵢ, hiᵢ, blockᵢ)`; blocks are
    point-tagged (`β × carrier`) and only the realizing point (`.2`) enters the list. For
    `[(x,x1,psXU),(x1,w,psUW),(w,t,psWT)]` this is `psXU.snd ++ x1 :: psUW.snd ++ w :: psWT.snd`,
    matching `k1v_sorted_realization3` verbatim. -/
def interleaveK {sig : MonadicSignature} {M : OrderedMonadicStructure sig} {β : Type _} :
    List (M.carrier × M.carrier × List (β × M.carrier)) → List M.carrier
  | [] => []
  | [(_, _, blk)] => blk.map Prod.snd
  | (_, sep, blk) :: (e :: rest) => blk.map Prod.snd ++ sep :: interleaveK (e :: rest)

/-- **Monotone lower bounds across a linked region list** (task 334 Phase 3 helper). If the region
    anchors are linked (`e.2.1 = (next).1`, i.e. `hiᵢ = loᵢ₊₁`, Def 3.1 shared boundary) and each
    region is non-degenerate (`loᵢ < hiᵢ`), then a lower bound below the first region's lower anchor
    is below EVERY region's lower anchor. Used to thread the strict-below invariant through the
    interleave stitch. -/
private theorem k1v_stitch_lowers_ge {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {β : Type _} :
    ∀ (regs : List (M.carrier × M.carrier × List (β × M.carrier))) (b : M.carrier),
      (∀ e ∈ regs, e.1 < e.2.1) →
      List.Chain' (fun a c => a.2.1 = c.1) regs →
      (∀ e, regs.head? = some e → b ≤ e.1) →
      ∀ f ∈ regs, b ≤ f.1 := by
  intro regs
  induction regs with
  | nil => intro b _ _ _ f hf; simp at hf
  | cons e rest ih =>
    intro b hpos hlink hhead f hf
    have hbe : b ≤ e.1 := hhead e rfl
    rcases List.mem_cons.mp hf with rfl | hf'
    · exact hbe
    · refine ih b (fun g hg => hpos g (List.mem_cons_of_mem _ hg))
          ((List.chain'_cons'.mp hlink).2) ?_ f hf'
      intro g hg
      have hsep : e.2.1 = g.1 := (List.chain'_cons'.mp hlink).1 g hg
      exact le_of_lt (lt_of_le_of_lt hbe (hsep ▸ hpos e List.mem_cons_self))

/-- **k-region stitch** (task 334 Phase 3; the `k1v_sorted_realization3` stitch generalized to k
    regions, Def 3.1 strictly-increasing witnesses md:61-74). Given region blocks each internally
    sorted (`hsort`) and realized strictly inside `(loᵢ, hiᵢ)` (`hrange`), with non-degenerate,
    boundary-linked, strictly-ordered anchors (`hpos`, `hlink`) all above a global left bound `lo`
    (`hlo`), the interleaved witness list `interleaveK regs` is strictly increasing, and every point
    exceeds `lo`. Every region-`i` point exceeds `hiᵢ₋₁` and is below `hiᵢ` — the k-fold lift of the
    three-region stitch's "every UW point exceeds `x1`, every left-block point is `< w`". -/
theorem k1v_stitch_regions {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {β : Type _} :
    ∀ (regs : List (M.carrier × M.carrier × List (β × M.carrier))) (lo : M.carrier),
      (∀ e ∈ regs, (e.2.2.map Prod.snd).Pairwise (· < ·)) →
      (∀ e ∈ regs, ∀ q ∈ e.2.2, e.1 < q.2 ∧ q.2 < e.2.1) →
      (∀ e ∈ regs, e.1 < e.2.1) →
      List.Chain' (fun a b => a.2.1 = b.1) regs →
      (∀ e ∈ regs, lo ≤ e.1) →
      (interleaveK regs).Pairwise (· < ·) ∧ ∀ y ∈ interleaveK regs, lo < y := by
  intro regs
  induction regs with
  | nil =>
    intro lo _ _ _ _ _
    refine ⟨?_, ?_⟩ <;> simp [interleaveK]
  | cons e rest ih =>
    intro lo hsort hrange hpos hlink hlo
    cases rest with
    | nil =>
      simp only [interleaveK]
      refine ⟨hsort e List.mem_cons_self, ?_⟩
      intro y hy
      obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hy
      exact lt_of_le_of_lt (hlo e List.mem_cons_self) (hrange e List.mem_cons_self q hq).1
    | cons e' rest' =>
      have hchain_tail : List.Chain' (fun a b => a.2.1 = b.1) (e' :: rest') :=
        (List.chain'_cons.mp hlink).2
      have hsep : e.2.1 = e'.1 := (List.chain'_cons.mp hlink).1
      have hlo_tail : ∀ f ∈ (e' :: rest'), e.2.1 ≤ f.1 :=
        k1v_stitch_lowers_ge (e' :: rest') e.2.1
          (fun f hf => hpos f (List.mem_cons_of_mem _ hf))
          hchain_tail
          (by intro g hg
              simp only [List.head?_cons, Option.mem_def, Option.some.injEq] at hg
              subst hg; exact le_of_eq hsep)
      obtain ⟨ihpair, ihbound⟩ :=
        ih e.2.1
          (fun f hf => hsort f (List.mem_cons_of_mem _ hf))
          (fun f hf => hrange f (List.mem_cons_of_mem _ hf))
          (fun f hf => hpos f (List.mem_cons_of_mem _ hf))
          hchain_tail hlo_tail
      simp only [interleaveK]
      refine ⟨?_, ?_⟩
      · rw [List.pairwise_append]
        refine ⟨hsort e List.mem_cons_self, ?_, ?_⟩
        · rw [List.pairwise_cons]
          exact ⟨fun y hy => ihbound y hy, ihpair⟩
        · intro a ha b hb
          obtain ⟨q, hq, rfl⟩ := List.mem_map.mp ha
          have haq : q.2 < e.2.1 := (hrange e List.mem_cons_self q hq).2
          rcases List.mem_cons.mp hb with rfl | hb'
          · exact haq
          · exact haq.trans (ihbound b hb')
      · intro y hy
        rcases List.mem_append.mp hy with hy | hy
        · obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hy
          exact lt_of_le_of_lt (hlo e List.mem_cons_self) (hrange e List.mem_cons_self q hq).1
        · rcases List.mem_cons.mp hy with rfl | hy'
          · exact lt_of_le_of_lt (hlo e List.mem_cons_self) (hpos e List.mem_cons_self)
          · exact lt_of_le_of_lt (hlo e List.mem_cons_self)
              (lt_trans (hpos e List.mem_cons_self) (ihbound y hy'))

/-- **Three-region bracket construction** (task 325 Phase 2; lift of `k1v_bracket_construct` :2838
    to `bracketFromLists3`). The reverse of point-type extraction: given a sorted tuple of realizing
    points — `usXU` strictly inside `(x, x1)`, the interior witness `x1`, `usUW` strictly inside
    `(x1, w)`, the interior witness `w`, `usWT` strictly inside `(w, t)` — with each point type
    realized at its point, the two interior witness types realized at `x1`/`w`, and the three
    per-region exclusions `segXU`/`segUW`/`segWT` holding on ALL of `(x, x1)`/`(x1, w)`/`(w, t)`, the
    three-region bracket holds at the FIXED endpoints `(x, t)`. Mirrors the append-a-witness
    construction of `existsBounded_right` (VecEAClosure:265; Lemma 3.4 PDF p.5) with the witness
    tuple assembled wholesale from `k1v_sorted_realization3`. Cite Rabinovich Lemma 5.3
    (md:137-152). -/
private theorem k1v_bracket_construct3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lXU lUW lWT : List TemporalPred) (ptX1 ptW segXU segUW segWT : TemporalPred)
    (x x1 w t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (usXU usUW usWT : List M.carrier)
    (hlenXU : usXU.length = lXU.length) (hlenUW : usUW.length = lUW.length)
    (hlenWT : usWT.length = lWT.length)
    (hsort : (usXU ++ x1 :: usUW ++ w :: usWT).Pairwise (· < ·))
    (hrangeXU : ∀ u ∈ usXU, x < u ∧ u < x1)
    (hrangeUW : ∀ u ∈ usUW, x1 < u ∧ u < w)
    (hrangeWT : ∀ u ∈ usWT, w < u ∧ u < t)
    (hptx1 : ptX1.eval_at M atomMap x1)
    (hptw : ptW.eval_at M atomMap w)
    (hptXU : ∀ (i : Nat) (hi : i < lXU.length),
      (lXU[i]'hi).eval_at M atomMap (usXU[i]'(by omega)))
    (hptUW : ∀ (i : Nat) (hi : i < lUW.length),
      (lUW[i]'hi).eval_at M atomMap (usUW[i]'(by omega)))
    (hptWT : ∀ (i : Nat) (hi : i < lWT.length),
      (lWT[i]'hi).eval_at M atomMap (usWT[i]'(by omega)))
    (hsegXU : ∀ u, x < u → u < x1 → segXU.eval_at M atomMap u)
    (hsegUW : ∀ u, x1 < u → u < w → segUW.eval_at M atomMap u)
    (hsegWT : ∀ u, w < u → u < t → segWT.eval_at M atomMap u) :
    (bracketFromLists3 lXU ptX1 lUW ptW lWT segXU segUW segWT).holds M atomMap x t := by
  -- Combined witness list and its length.
  have hlen : (usXU ++ x1 :: usUW ++ w :: usWT).length
      = lXU.length + lUW.length + lWT.length + 1 + 1 := by
    simp only [List.length_append, List.length_cons, hlenXU, hlenUW, hlenWT]; omega
  -- Strict monotonicity of the combined list, as getElem comparisons.
  have hmono : ∀ (a b : Nat) (ha : a < (usXU ++ x1 :: usUW ++ w :: usWT).length)
      (hb : b < (usXU ++ x1 :: usUW ++ w :: usWT).length), a < b →
      (usXU ++ x1 :: usUW ++ w :: usWT)[a] < (usXU ++ x1 :: usUW ++ w :: usWT)[b] :=
    fun a b ha hb hab => List.pairwise_iff_getElem.mp hsort a b ha hb hab
  -- The two interior witnesses sit at fixed indices: `x1` at `usXU.length`, `w` after the UW block.
  have hx1_at : (usXU ++ x1 :: usUW ++ w :: usWT)[usXU.length]'(by rw [hlen]; omega) = x1 := by
    rw [List.getElem_append_left (show usXU.length < (usXU ++ x1 :: usUW).length by
          simp only [List.length_append, List.length_cons]; omega)]
    rw [List.getElem_append_right (le_refl usXU.length)]
    simp only [Nat.sub_self, List.getElem_cons_zero]
  have hw_at : (usXU ++ x1 :: usUW ++ w :: usWT)[usXU.length + 1 + usUW.length]'(by
        rw [hlen]; omega) = w := by
    rw [List.getElem_append_right (show (usXU ++ x1 :: usUW).length ≤ usXU.length + 1 + usUW.length by
          simp only [List.length_append, List.length_cons]; omega)]
    simp only [show usXU.length + 1 + usUW.length - (usXU ++ x1 :: usUW).length = 0 by
      simp only [List.length_append, List.length_cons]; omega, List.getElem_cons_zero]
  -- Comparison helpers derived from monotonicity around the two interior anchors.
  have hle_x1 : ∀ (j : Nat) (hj1 : j ≤ usXU.length)
      (hj2 : j < (usXU ++ x1 :: usUW ++ w :: usWT).length),
      (usXU ++ x1 :: usUW ++ w :: usWT)[j] ≤ x1 := by
    intro j hj1 hj2
    rcases Nat.lt_or_eq_of_le hj1 with hj | hj
    · exact le_of_lt (lt_of_lt_of_eq (hmono j usXU.length hj2 (by rw [hlen]; omega) hj) hx1_at)
    · subst hj; exact le_of_eq hx1_at
  have hge_x1 : ∀ (j : Nat) (hj1 : usXU.length ≤ j)
      (hj2 : j < (usXU ++ x1 :: usUW ++ w :: usWT).length),
      x1 ≤ (usXU ++ x1 :: usUW ++ w :: usWT)[j] := by
    intro j hj1 hj2
    rcases Nat.lt_or_eq_of_le hj1 with hj | hj
    · exact le_of_lt (lt_of_eq_of_lt hx1_at.symm (hmono usXU.length j (by rw [hlen]; omega) hj2 hj))
    · subst hj; exact le_of_eq hx1_at.symm
  have hle_w : ∀ (j : Nat) (hj1 : j ≤ usXU.length + 1 + usUW.length)
      (hj2 : j < (usXU ++ x1 :: usUW ++ w :: usWT).length),
      (usXU ++ x1 :: usUW ++ w :: usWT)[j] ≤ w := by
    intro j hj1 hj2
    rcases Nat.lt_or_eq_of_le hj1 with hj | hj
    · exact le_of_lt (lt_of_lt_of_eq
        (hmono j (usXU.length + 1 + usUW.length) hj2 (by rw [hlen]; omega) hj) hw_at)
    · subst hj; exact le_of_eq hw_at
  have hge_w : ∀ (j : Nat) (hj1 : usXU.length + 1 + usUW.length ≤ j)
      (hj2 : j < (usXU ++ x1 :: usUW ++ w :: usWT).length),
      w ≤ (usXU ++ x1 :: usUW ++ w :: usWT)[j] := by
    intro j hj1 hj2
    rcases Nat.lt_or_eq_of_le hj1 with hj | hj
    · exact le_of_lt (lt_of_eq_of_lt hw_at.symm
        (hmono (usXU.length + 1 + usUW.length) j (by rw [hlen]; omega) hj2 hj))
    · subst hj; exact le_of_eq hw_at.symm
  -- Every combined-list point lies strictly inside the fixed endpoints `(x, t)`.
  have hrange_all : ∀ u ∈ usXU ++ x1 :: usUW ++ w :: usWT, x < u ∧ u < t := by
    intro u hu
    rcases List.mem_append.mp hu with hu | hu
    · rcases List.mem_append.mp hu with hu | hu
      · exact ⟨(hrangeXU _ hu).1, (hrangeXU _ hu).2.trans (hx1w.trans hwt)⟩
      · rcases List.mem_cons.mp hu with rfl | hu
        · exact ⟨hxx1, hx1w.trans hwt⟩
        · exact ⟨hxx1.trans (hrangeUW _ hu).1, (hrangeUW _ hu).2.trans hwt⟩
    · rcases List.mem_cons.mp hu with rfl | hu
      · exact ⟨hxx1.trans hx1w, hwt⟩
      · exact ⟨(hxx1.trans hx1w).trans (hrangeWT _ hu).1, (hrangeWT _ hu).2⟩
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, bracketFromLists3]
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show lXU.length + lUW.length + lWT.length + 1 + 1
        = (lXU.length + lUW.length + lWT.length + 1) + 1 by omega)]
  refine ⟨fun i => (usXU ++ x1 :: usUW ++ w :: usWT)[i.val]'(by
      have := i.isLt; rw [hlen]; omega), ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- Strict monotonicity.
    intro i j hij
    exact hmono i.val j.val (by have := i.isLt; rw [hlen]; omega)
      (by have := j.isLt; rw [hlen]; omega) hij
  · -- Range: all points strictly inside `(x, t)`.
    intro i
    exact hrange_all _ (List.getElem_mem _)
  · -- Point types: five-way index split around the two interior witness slots.
    intro i
    simp only []
    rcases Nat.lt_trichotomy i.val lXU.length with hi | hi | hi
    · -- (a) `usXU` / `lXU` region.
      rw [List.getElem_append_left (show i.val < (lXU ++ ptX1 :: lUW).length by
            simp only [List.length_append, List.length_cons]; omega),
        List.getElem_append_left hi,
        List.getElem_append_left (show i.val < (usXU ++ x1 :: usUW).length by
            simp only [List.length_append, List.length_cons]; omega),
        List.getElem_append_left (show i.val < usXU.length by omega)]
      exact hptXU i.val hi
    · -- (b) `x1` interior witness slot.
      rw [List.getElem_append_left (show i.val < (lXU ++ ptX1 :: lUW).length by
            simp only [List.length_append, List.length_cons]; omega),
        List.getElem_append_right (show lXU.length ≤ i.val from le_of_eq hi.symm),
        List.getElem_append_left (show i.val < (usXU ++ x1 :: usUW).length by
            simp only [List.length_append, List.length_cons]; omega),
        List.getElem_append_right (show usXU.length ≤ i.val by omega)]
      simp only [show i.val - lXU.length = 0 by omega, show i.val - usXU.length = 0 by omega,
        List.getElem_cons_zero]
      exact hptx1
    · -- `i.val > lXU.length`: split around the `w` slot at `lXU.length + 1 + lUW.length`.
      rcases Nat.lt_trichotomy i.val (lXU.length + 1 + lUW.length) with hi2 | hi2 | hi2
      · -- (c) `usUW` / `lUW` region.
        obtain ⟨j, hj⟩ : ∃ j, i.val = lXU.length + 1 + j := ⟨i.val - lXU.length - 1, by omega⟩
        have hjUW : j < lUW.length := by omega
        rw [List.getElem_append_left (show i.val < (lXU ++ ptX1 :: lUW).length by
              simp only [List.length_append, List.length_cons]; omega),
          List.getElem_append_right (show lXU.length ≤ i.val by omega),
          List.getElem_append_left (show i.val < (usXU ++ x1 :: usUW).length by
              simp only [List.length_append, List.length_cons]; omega),
          List.getElem_append_right (show usXU.length ≤ i.val by omega)]
        simp only [show i.val - lXU.length = j + 1 by omega,
          show i.val - usXU.length = j + 1 by omega, List.getElem_cons_succ]
        exact hptUW j hjUW
      · -- (d) `w` interior witness slot.
        rw [List.getElem_append_right (show (lXU ++ ptX1 :: lUW).length ≤ i.val by
              simp only [List.length_append, List.length_cons]; omega),
          List.getElem_append_right (show (usXU ++ x1 :: usUW).length ≤ i.val by
              simp only [List.length_append, List.length_cons]; omega)]
        simp only [show i.val - (lXU ++ ptX1 :: lUW).length = 0 by
            simp only [List.length_append, List.length_cons]; omega,
          show i.val - (usXU ++ x1 :: usUW).length = 0 by
            simp only [List.length_append, List.length_cons]; omega, List.getElem_cons_zero]
        exact hptw
      · -- (e) `usWT` / `lWT` region.
        obtain ⟨j, hj⟩ : ∃ j, i.val = lXU.length + 1 + lUW.length + 1 + j :=
          ⟨i.val - (lXU.length + 1 + lUW.length) - 1, by omega⟩
        have hival := i.isLt
        have hjWT : j < lWT.length := by omega
        rw [List.getElem_append_right (show (lXU ++ ptX1 :: lUW).length ≤ i.val by
              simp only [List.length_append, List.length_cons]; omega),
          List.getElem_append_right (show (usXU ++ x1 :: usUW).length ≤ i.val by
              simp only [List.length_append, List.length_cons]; omega)]
        simp only [show i.val - (lXU ++ ptX1 :: lUW).length = j + 1 by
            simp only [List.length_append, List.length_cons]; omega,
          show i.val - (usXU ++ x1 :: usUW).length = j + 1 by
            simp only [List.length_append, List.length_cons]; omega, List.getElem_cons_succ]
        exact hptWT j hjWT
  · -- Leading segment `(x, ws 0)`: inside `(x, x1)`, so `segXU` (index `0 ≤ lXU.length`).
    intro y hxy hy0
    rw [if_pos (Nat.zero_le lXU.length)]
    exact hsegXU y hxy (lt_of_lt_of_le hy0 (hle_x1 0 (Nat.zero_le _) (by rw [hlen]; omega)))
  · -- Interior segments: three-way region split by the beta index `i.val + 1`.
    intro i y h1 h2
    by_cases hile : i.val + 1 ≤ lXU.length
    · -- Region XU: `(ws i, ws (i+1)) ⊆ (x, x1)`.
      rw [if_pos hile]
      refine hsegXU y ?_ ?_
      · exact (hrange_all _ (List.getElem_mem _)).1.trans h1
      · exact lt_of_lt_of_le h2 (hle_x1 (i.val + 1) (by omega) (by have := i.isLt; rw [hlen]; omega))
    · by_cases hile2 : i.val + 1 ≤ lXU.length + 1 + lUW.length
      · -- Region UW: `(ws i, ws (i+1)) ⊆ (x1, w)`.
        rw [if_neg hile, if_pos hile2]
        refine hsegUW y ?_ ?_
        · exact lt_of_le_of_lt (hge_x1 i.val (by omega) (by have := i.isLt; rw [hlen]; omega)) h1
        · exact lt_of_lt_of_le h2 (hle_w (i.val + 1) (by omega) (by have := i.isLt; rw [hlen]; omega))
      · -- Region WT: `(ws i, ws (i+1)) ⊆ (w, t)`.
        rw [if_neg hile, if_neg hile2]
        refine hsegWT y ?_ ?_
        · exact lt_of_le_of_lt (hge_w i.val (by omega) (by have := i.isLt; rw [hlen]; omega)) h1
        · exact h2.trans (hrange_all _ (List.getElem_mem _)).2
  · -- Trailing segment `(ws last, t)`: inside `(w, t)`, so `segWT`.
    intro y hy1 hy2
    rw [if_neg (show ¬(lXU.length + lUW.length + lWT.length + 1 + 1 ≤ lXU.length) by omega),
      if_neg (show ¬(lXU.length + lUW.length + lWT.length + 1 + 1 ≤ lXU.length + 1 + lUW.length) by
        omega)]
    refine hsegWT y ?_ hy2
    exact lt_of_le_of_lt (hge_w (lXU.length + lUW.length + lWT.length + 1)
      (by omega) (by rw [hlen]; omega)) hy1

/-- **Successor-parameter compatibility at the gate instance `j = 0`** (task 325 Phase 1; R4 exit
    criterion). The redesigned carrier's `σ : NormalForm sig 1 4` argument is definitionally the
    `j = 0` instance of the amended successor spec `σ : NormalForm sig (j+1) 4` (report 321 §2
    :56/:225): at `j = 0`, `NormalForm sig (0 + 1) 4` reduces to the landed `NormalForm sig 1 4`.
    Any successor-threading depth mismatch would fail this `rfl` immediately (the
    `kvE_subChain2_eq_fChainPred` :6179 / `bracketEndChar_kvE2_two_eq` :5972 discipline). -/
theorem kvE_subBracket2V_succ_j0 {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig (0 + 1) 4) :
    kvE_subBracket2V charBase charK σ = kvE_subBracket2V charBase charK σ := rfl

/-! ### Task 325 Phase 3 — Soundness over the `VVecEA2` disjunction

RE-DERIVES the task-324 soundness kit (`kvE_subBracket2_extract` :6233, `_reaches_z*` :6327,
`_fold_z*` :6434, `kvE_subBracket2_sound` :6530 — all binding the OLD single-bracket carrier)
over the redesigned `VVecEA2` carrier `kvE_subBracket2V` (:6779). The proof shapes survive; the
statements change by destructuring the disjunction FIRST (exactly as `bracketEndChar_k1v_sound`
:2352 does via `simp only [carrier, VVecEA2.holds]`), then reading the middle anchor `ptX1` (the
fresh depth-1 witness slot) and the below/above interior witnesses off the three-region
`bracketFromLists3` point list `lXU' ++ ptX1 :: lUW' ++ ptW :: lWT'` (anchor at index `|lXU'|`).
The SURVIVE zone specs `kvE_sub2_zXU`/`_zUW`/`_zWT` (:6200-6208) are defeq to the carrier's
internal `zXU`/`zUW`/`zWT` lets, so the interface matches the old kit verbatim and `_reaches`/
`_fold`/`_sound` transfer near-verbatim (carrier + extract-call swapped; the explicit `hgate` is
retained per Amendment F3 — the anchor positions ARE the bracket witnesses, the accepted task-324
soundness pattern). Rabinovich Def 3.1 monotone enumeration (PDF p.4), §5 bracket `[α_0,…,α_n]`
(PDF p.7), Cor 5.4 per-region chain (md:154-157). No `simp`/`omega`/`aesop` on chain steps
(`by omega` is `Fin`-index typing only, as in `kvE_subBracket2_extract` :6233). -/

/-- **Point-type extraction for `bracketFromLists3`** (task 325 Phase 3; the three-region arity-4
    lift of `k1v_bracket_extract` :2150, bullets 1-3 — point-type reachability only, per-region
    segments irrelevant to the point conditions). From `holds` at `(z_0, z_1)` obtain the middle
    anchor witness `w` (index `|lXU|`, realizing `ptX1`), every `lXU` type realized strictly
    BELOW `w`, and every `lUW`/`lWT` type strictly ABOVE `w`. Point list groups as
    `(lXU ++ ptX1 :: lUW) ++ ptW :: lWT`; reassociated once to a per-segment single cons for the
    `getElem` navigation (Def 3.1 monotone enumeration, PDF p.4; §5 bracket PDF p.7). -/
private theorem bracketFromLists3_extract {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lXU lUW lWT : List TemporalPred) (ptX1 ptW segXU segUW segWT : TemporalPred)
    (z0 z1 : M.carrier)
    (h : (bracketFromLists3 lXU ptX1 lUW ptW lWT segXU segUW segWT).holds M atomMap z0 z1) :
    ∃ w : M.carrier, z0 < w ∧ w < z1 ∧
      ptX1.eval_at M atomMap w ∧
      (∀ p ∈ lXU, ∃ u : M.carrier, z0 < u ∧ u < w ∧ p.eval_at M atomMap u) ∧
      (∀ p ∈ lUW, ∃ u : M.carrier, w < u ∧ u < z1 ∧ p.eval_at M atomMap u) ∧
      (∀ p ∈ lWT, ∃ u : M.carrier, w < u ∧ u < z1 ∧ p.eval_at M atomMap u) := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern] at h
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ z0 z1
      (show lXU.length + lUW.length + lWT.length + 1 + 1
        = (lXU.length + lUW.length + lWT.length + 1) + 1 from rfl)] at h
  obtain ⟨ws, hmono, hrange, hpt, _, _, _⟩ := h
  -- Point list groups as `(lXU ++ ptX1 :: lUW) ++ ptW :: lWT`; `hpt ⟨i,_⟩` is defeq.
  have hpt' : ∀ (i : Nat) (hi : i < lXU.length + lUW.length + lWT.length + 1 + 1),
      ((lXU ++ ptX1 :: lUW ++ ptW :: lWT)[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
  refine ⟨ws ⟨lXU.length, by omega⟩, (hrange ⟨lXU.length, by omega⟩).1,
    (hrange ⟨lXU.length, by omega⟩).2, ?_, ?_, ?_, ?_⟩
  · -- Anchor `ptX1` at index `|lXU|` (§5 bracket middle slot, PDF p.7).
    have helem : (lXU ++ ptX1 :: lUW ++ ptW :: lWT)[lXU.length]'(by
        simp only [List.length_append, List.length_cons]; omega) = ptX1 := by
      rw [List.getElem_append_left
        (show lXU.length < (lXU ++ ptX1 :: lUW).length by
          simp only [List.length_append, List.length_cons]; omega)]
      rw [List.getElem_append_right (Nat.le_refl _)]
      simp only [Nat.sub_self, List.getElem_cons_zero]
    have := hpt' lXU.length (by omega)
    rwa [helem] at this
  · -- Below-anchor: each `lXU` type realized strictly inside `(z0, w)`.
    intro p hp
    obtain ⟨j, hj, hjeq⟩ := List.mem_iff_getElem.mp hp
    refine ⟨ws ⟨j, by omega⟩, (hrange ⟨j, by omega⟩).1,
      hmono ⟨j, by omega⟩ ⟨lXU.length, by omega⟩ (Fin.mk_lt_mk.mpr hj), ?_⟩
    have helem : (lXU ++ ptX1 :: lUW ++ ptW :: lWT)[j]'(by
        simp only [List.length_append, List.length_cons]; omega) = lXU[j]'hj := by
      rw [List.getElem_append_left
        (show j < (lXU ++ ptX1 :: lUW).length by
          simp only [List.length_append, List.length_cons]; omega)]
      rw [List.getElem_append_left hj]
    have := hpt' j (by omega)
    rw [helem, hjeq] at this
    exact this
  · -- `lUW`: witness in the `lUW` block, index `|lXU| + 1 + j` (above anchor).
    intro p hp
    obtain ⟨j, hj, hjeq⟩ := List.mem_iff_getElem.mp hp
    refine ⟨ws ⟨lXU.length + 1 + j, by omega⟩,
      hmono ⟨lXU.length, by omega⟩ ⟨lXU.length + 1 + j, by omega⟩ (Fin.mk_lt_mk.mpr (by omega)),
      (hrange ⟨lXU.length + 1 + j, by omega⟩).2, ?_⟩
    have helem : (lXU ++ ptX1 :: lUW ++ ptW :: lWT)[lXU.length + 1 + j]'(by
        simp only [List.length_append, List.length_cons]; omega) = lUW[j]'hj := by
      rw [List.getElem_append_left
        (show lXU.length + 1 + j < (lXU ++ ptX1 :: lUW).length by
          simp only [List.length_append, List.length_cons]; omega)]
      rw [List.getElem_append_right (by omega)]
      simp only [show lXU.length + 1 + j - lXU.length = j + 1 by omega, List.getElem_cons_succ]
    have := hpt' (lXU.length + 1 + j) (by omega)
    rw [helem, hjeq] at this
    exact this
  · -- `lWT`: witness in the `lWT` block, index `|lXU| + 1 + |lUW| + 1 + j` (above anchor).
    intro p hp
    obtain ⟨j, hj, hjeq⟩ := List.mem_iff_getElem.mp hp
    refine ⟨ws ⟨lXU.length + 1 + lUW.length + 1 + j, by omega⟩,
      hmono ⟨lXU.length, by omega⟩ ⟨lXU.length + 1 + lUW.length + 1 + j, by omega⟩
        (Fin.mk_lt_mk.mpr (by omega)),
      (hrange ⟨lXU.length + 1 + lUW.length + 1 + j, by omega⟩).2, ?_⟩
    have helem : (lXU ++ ptX1 :: lUW ++ ptW :: lWT)[lXU.length + 1 + lUW.length + 1 + j]'(by
        simp only [List.length_append, List.length_cons]; omega) = lWT[j]'hj := by
      have hidx : lXU.length + 1 + lUW.length + 1 + j - (lXU ++ ptX1 :: lUW).length = j + 1 := by
        simp only [List.length_append, List.length_cons]; omega
      rw [List.getElem_append_right (by simp only [List.length_append, List.length_cons]; omega)]
      simp only [hidx, List.getElem_cons_succ]
    have := hpt' (lXU.length + 1 + lUW.length + 1 + j) (by omega)
    rw [helem, hjeq] at this
    exact this

private theorem kvE_subBracket2V_extract {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier)
    (h : (kvE_subBracket2V charBase charK σ).holds M atomMap z0 z1) :
    ∃ w : M.carrier, z0 < w ∧ w < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (∀ χ : NormalForm sig 0 1,
        σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ u : M.carrier, z0 < u ∧ u < w ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) ∧
      (∀ χ : NormalForm sig 0 1,
        (σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true ∨
         σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true) →
        ∃ u : M.carrier, w < u ∧ u < z1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) := by
  -- Step 1: destructure the disjunction and split on the gate (as `bracketEndChar_k1v_sound`).
  simp only [kvE_subBracket2V, VVecEA2.holds] at h
  obtain ⟨vea, hmem, hveah⟩ := h
  split at hmem
  case isFalse hg => simp at hmem
  case isTrue hg =>
  rw [List.mem_flatMap] at hmem
  obtain ⟨lXU, hlXUp, hmem⟩ := hmem
  rw [List.mem_flatMap] at hmem
  obtain ⟨lUW, hlUWp, hmem⟩ := hmem
  rw [List.mem_map] at hmem
  obtain ⟨lWT, hlWTp, hEq⟩ := hmem
  subst hEq
  obtain ⟨_hepL, _hepR, hbr⟩ := hveah
  -- Extract the anchor + per-block point-type witnesses from the three-region bracket.
  obtain ⟨w, hz0w, hwz1, hanchor, hbelow, hUW, hWT⟩ :=
    bracketFromLists3_extract M atomMap _ _ _ _ _ _ _ _ z0 z1 hbr
  refine ⟨w, hz0w, hwz1, ?_, ?_, ?_⟩
  · -- Anchor: project the complete-type head conjunct out of the folded `ptX1` (v2 self-type fold;
    -- k1v `hptW` :3277). `hanchor : ptX1_folded.eval_at`; its head is `charK (nfk_projFresh σ)`.
    simp only [TemporalPred.eval_at] at hanchor ⊢
    rw [formula_conjList_iff] at hanchor
    exact hanchor _ List.mem_cons_self
  · -- `zXU`-positive `χ`: `⟨charBase χ⟩ ∈ lXU.map charP` via the arrangement permutation.
    intro χ hbit
    have hχmem : (⟨charBase χ⟩ : TemporalPred) ∈
        lXU.map (fun χ => (⟨charBase χ⟩ : TemporalPred)) :=
      List.mem_map_of_mem
        ((List.mem_permutations.mp hlXUp).mem_iff.mpr (List.mem_filter.mpr ⟨by simp, hbit⟩))
    exact hbelow _ hχmem
  · -- `zUW`/`zWT`-positive `χ`: membership in the `lUW`/`lWT` arrangement block.
    intro χ hbit
    rcases hbit with hbit | hbit
    · exact hUW _ (List.mem_map_of_mem
        ((List.mem_permutations.mp hlUWp).mem_iff.mpr (List.mem_filter.mpr ⟨by simp, hbit⟩)))
    · exact hWT _ (List.mem_map_of_mem
        ((List.mem_permutations.mp hlWTp).mem_iff.mpr (List.mem_filter.mpr ⟨by simp, hbit⟩)))

/-- **KILL-SWITCH — `zXU` reachability over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_reaches_zXU` :6327 over `kvE_subBracket2V`). Every `zXU`-positive fold bit
    yields a witness `u` realizing `charBase χ` strictly BELOW the anchor witness `w`. Rabinovich
    Prop 3.5 (md:87-94), §5 bracket (PDF p.7). -/
theorem kvE_subBracket2V_reaches_zXU {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true)
    (h : (kvE_subBracket2V charBase charK σ).holds M atomMap z0 z1) :
    ∃ u w : M.carrier, z0 < u ∧ u < w ∧ w < z1 ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w := by
  obtain ⟨w, hz0w, hwz1, hanchor, hbelow, _⟩ :=
    kvE_subBracket2V_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hz0u, huw, hu⟩ := hbelow χ hbit
  exact ⟨u, w, hz0u, huw, hwz1, hu, hanchor⟩

/-- **KILL-SWITCH — `zUW` reachability over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_reaches_zUW` :6347). Every `zUW`-positive fold bit yields a witness `u`
    realizing `charBase χ` strictly ABOVE the anchor witness `w`. Rabinovich Prop 3.5 (md:87-94). -/
theorem kvE_subBracket2V_reaches_zUW {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true)
    (h : (kvE_subBracket2V charBase charK σ).holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  obtain ⟨w, hz0w, hwz1, hanchor, _, habove⟩ :=
    kvE_subBracket2V_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hwu, huz1, hu⟩ := habove χ (Or.inl hbit)
  exact ⟨w, u, hz0w, hwu, huz1, hanchor, hu⟩

/-- **KILL-SWITCH — `zWT` reachability over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_reaches_zWT` :6367). Every `zWT`-positive fold bit yields a witness `u`
    realizing `charBase χ` strictly ABOVE the anchor witness `w`. Rabinovich Prop 3.5 (md:87-94). -/
theorem kvE_subBracket2V_reaches_zWT {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true)
    (h : (kvE_subBracket2V charBase charK σ).holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  obtain ⟨w, hz0w, hwz1, hanchor, _, habove⟩ :=
    kvE_subBracket2V_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hwu, huz1, hu⟩ := habove χ (Or.inr hbit)
  exact ⟨w, u, hz0w, hwu, huz1, hanchor, hu⟩

/-- **Interior-fold ≤ — `zXU` over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_fold_zXU` :6434). A positive `zXU` fold bit is realized as an honest
    `nf_eval_nf M 0 1` witness `u` strictly BELOW the anchor witness `w`, via the `nfPred_correct`
    (NfToVecEA:69) bridge (the k1v `hchar` :2370). Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2V_fold_zXU {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true)
    (h : (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap z0 z1) :
    ∃ u w : M.carrier, z0 < u ∧ u < w ∧ w < z1 ∧
      nf_eval_nf M 0 1 (fun _ => u) χ ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w := by
  obtain ⟨u, w, hz0u, huw, hwz1, hu, hw⟩ :=
    kvE_subBracket2V_reaches_zXU (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨u, w, hz0u, huw, hwz1, (nfPred_correct M atomMap h_surj χ u).mp hu, hw⟩

/-- **Interior-fold ≤ — `zUW` over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_fold_zUW` :6455). Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2V_fold_zUW {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true)
    (h : (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  obtain ⟨w, u, hz0w, hwu, huz1, hw, hu⟩ :=
    kvE_subBracket2V_reaches_zUW (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨w, u, hz0w, hwu, huz1, hw, (nfPred_correct M atomMap h_surj χ u).mp hu⟩

/-- **Interior-fold ≤ — `zWT` over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_fold_zWT` :6476). Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2V_fold_zWT {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true)
    (h : (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  obtain ⟨w, u, hz0w, hwu, huz1, hw, hu⟩ :=
    kvE_subBracket2V_reaches_zWT (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨w, u, hz0w, hwu, huz1, hw, (nfPred_correct M atomMap h_surj χ u).mp hu⟩

/-- **Standalone soundness of the redesigned `VVecEA2` sub-bracket** (task 325 Phase 3; re-derives
    `kvE_subBracket2_sound` :6530 over `kvE_subBracket2V`). Whenever the `VVecEA2` arrangement
    disjunction holds on the FIXED endpoints `(x, t)`, and the explicit outer gate-shaped
    hypothesis `hgate` supplies the honest fold conditions the carrier does not itself supply as
    the below-anchor witnesses, there is a depth-1 witness `x1` realizing `nf_eval_nf M 1 4` at the
    honest env `[x1, w, x, t]`. STANDALONE: `hgate` is an explicit hypothesis, never wired to the
    real outer gate (Amendment F3 — no provider pinning; the anchor is the bracket's own witness).
    The carrier's OWN contribution is the below-anchor (`zXU`) existence witnesses, extracted per
    disjunct via `kvE_subBracket2V_extract` (which destructures the disjunction FIRST, as
    `bracketEndChar_k1v_sound` :2352). Assembled via `nf_eval_depth1_fold_iff` (:5187). Rabinovich
    Def 3.1 (md:61-74), Prop 3.5 (md:87-94), Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2V_sound {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds
        M atomMap x t)
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
    ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  -- Extract the anchor `a` (the `ptX1` witness) and the below-anchor witness clause per disjunct.
  obtain ⟨a, hxa, hat, hanchor, hbelow, _habove⟩ :=
    kvE_subBracket2V_extract (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap x t h
  -- Feed the anchor to the explicit gate hypothesis (Amendment F3: no provider pinning).
  obtain ⟨haw, hwt, h_atom, h_off, h_fwd, h_bwd⟩ := hgate a hxa hat hanchor
  refine ⟨a, ?_⟩
  -- Assemble the depth-1 evaluation (the inside-out fold of `nf_eval_depth1_fold_iff` :5187).
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  -- Zone matching: forward from the gate; backward from the gate for every zone EXCEPT the
  -- below-anchor `zXU`, whose witnesses are supplied by the bracket (Correction 1).
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE_sub2_zXU
  · -- Below-anchor zone `zXU = (x < v < a)`: the bracket's below-witness clause supplies a
    -- witness strictly below the anchor `a` (Def 3.1, PDF p.4; the redesign's signature witness).
    subst hzs
    obtain ⟨u, hxu, hua, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    -- `u` lies in `zXU` relative to env `[a, w, x, t]` under honest order `x < u < a < w < t`.
    have huw : u < w := hua.trans haw
    have hut : u < t := huw.trans hwt
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hua rfl, iff_of_false (lt_asymm hua) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by decide +revert)⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · -- Every other zone: the gate's backward direction (analog of `kvE_gate` honesty).
    exact h_bwd zs χ hzs hbit

/-- **Soundness-of-parts consumer for the corrected sub-bracket** (task 321 Phase 10; the
    `.holds`-free refactor of `kvE_subBracket2V_sound` :7370). Isolates EXACTLY the carrier-side
    inputs `kvE_subBracket2V_sound` actually consumes: the interior anchor witness `x1` (the fresh
    depth-1 witness slot `ptX1 = charK (nfk_projFresh σ)`, realized at `x1 ∈ (x, t)`) and the per-χ
    below-anchor `zXU`-reachability witnesses `hbelow` (`∃ u ∈ (x, x1)` realizing each `zXU`-positive
    `χ`). Everything else is supplied by the explicit gate hypothesis `hgate` (Amendment F3 — no
    provider pinning; the anchor IS the bracket's own witness). The proof body is IDENTICAL to
    `kvE_subBracket2V_sound` from the post-extract point (:7399-7426); only the opening `.holds`
    destructure + `kvE_subBracket2V_extract` call are replaced by the explicit `(x1, hanchor, hbelow)`
    hypotheses.

    STRUCTURAL PURPOSE (task 321 Phase 10 residual isolation): `kvE_subBracket2V_sound` requires the
    full `(kvE_subBracket2V σ).holds`, which the re-pointed `kvE2_body` joint channel (:8154,
    `ptSub σ = kvE_subChain2V σ` = a flat `bracketFromLists3.fChainPred`) cannot supply — lifting a
    realized `fChainPred` to the nested `.holds` is the reverse Cor 5.4 direction, DOCUMENTED
    UNPROVABLE at `EANegation.lean:1217-1234` (report 18 §10.3, interior-witness convention). This
    lemma pins down that the ONLY carrier-side data soundness truly needs is `(x1, hbelow)` — the
    fresh anchor + below-anchor reachability — so any corrected joint channel that exposes those two
    (e.g. via `kvE_subBracket2V_reaches_zXU` :7246 off a genuinely-carried `.holds`, rather than a
    flattened chain) feeds this consumer directly, WITHOUT the unprovable reverse direction.
    Rabinovich Cor 5.4 (md:154-157), Prop 3.5 (md:87-94). -/
theorem kvE_subBracket2V_sound_of_parts {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (x1 : M.carrier) (hxx1 : x < x1) (hx1t : x1 < t)
    (hanchor : (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap x1)
    (hbelow : ∀ χ : NormalForm sig 0 1,
        σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ u : M.carrier, x < u ∧ u < x1 ∧
          (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred).eval_at M atomMap u)
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
    ∃ x1' : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  -- Feed the supplied anchor `x1` to the explicit gate hypothesis (Amendment F3: no provider
  -- pinning). Identical continuation to `kvE_subBracket2V_sound` :7399 onward, with the anchor and
  -- below-witnesses now given as hypotheses instead of extracted from `.holds`.
  obtain ⟨haw, hwt, h_atom, h_off, h_fwd, h_bwd⟩ := hgate x1 hxx1 hx1t hanchor
  refine ⟨x1, ?_⟩
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE_sub2_zXU
  · -- Below-anchor zone `zXU = (x < v < x1)`: the supplied below-witness clause gives a witness
    -- strictly below the anchor `x1` (Def 3.1, PDF p.4; the redesign's signature witness).
    subst hzs
    obtain ⟨u, hxu, hux1, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    have huw : u < w := hux1.trans haw
    have hut : u < t := huw.trans hwt
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by decide +revert)⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · -- Every other zone: the gate's backward direction (analog of `kvE_gate` honesty).
    exact h_bwd zs χ hzs hbit

/-- **Multi-element σ-block: every sub-chain slot lies below a chosen pin** (task 326 Phase 5;
    generalizes `bracketFromLists_flatMap_block_extract` :2322 from a single-head block
    `head b :: tail b` to the k=2 outer block `subChain b ++ pins b` — the shape of `kvE2_body`'s
    `slotsFor lL = lL.flatMap (fun σ => ptSub σ ++ pinSlots σ)` (:8505-8506), where
    `ptSub σ = kvE_subChain2V charBase charK σ` is a MULTI-element list of per-arrangement
    `fChainPred`s). Given a chosen pin `p0 ∈ pins a`, the order-preserving extraction
    (`k1v_bracket_extract_mono`) places `a`'s whole block strictly-increasing and strictly below the
    middle witness `w_outer`, with EVERY sub-chain slot `fcp ∈ subChain a` realized STRICTLY BELOW the
    witness `q` of `p0` — because the entire `subChain a` segment PRECEDES the `pins a` segment in the
    contiguous block, so every sub-chain witness carries a smaller monotone index than any pin witness.
    The `< q` bound rides the sub-chain slot's STRUCTURAL position in the contiguous block (the monotone
    `ws` sequence), never a formula literal (litmus PASS).

    Rabinovich 2014 **Lemma 5.1** (md:169-171): the shared-endpoint (`w_outer`) point-insertion bound
    is carried structurally by the monotone block ordering, faithful under the order-preserving
    realization of the bracket's interval decomposition. **Lemma 5.3** (md:137-152): the arrangement
    coverage that lets any chosen pin serve as the below-bound for the whole preceding sub-chain block. -/
private theorem bracketFromLists_flatMap_subchain_below_pin {sig : MonadicSignature} {α : Type*}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l : List α) (subChain pins : α → List TemporalPred)
    (ptW segL segR : TemporalPred) (lR : List TemporalPred)
    (x t : M.carrier) (a : α) (ha : a ∈ l)
    (p0 : TemporalPred) (hp0 : p0 ∈ pins a)
    (h : (bracketFromLists (l.flatMap (fun b => subChain b ++ pins b)) ptW lR segL segR).holds
          M atomMap x t) :
    ∃ w_outer q : M.carrier,
      x < q ∧ q < w_outer ∧ w_outer < t ∧ p0.eval_at M atomMap q ∧
      (∀ fcp ∈ subChain a, ∃ u : M.carrier, x < u ∧ u < q ∧ fcp.eval_at M atomMap u) := by
  obtain ⟨pre, post, hl⟩ := List.append_of_mem ha
  set fB : α → List TemporalPred := fun b => subChain b ++ pins b with hfB
  have heq : l.flatMap fB = (pre.flatMap fB ++ fB a) ++ post.flatMap fB := by
    rw [hl, List.flatMap_append, List.flatMap_cons, ← List.append_assoc]
  rw [heq] at h
  set pref := pre.flatMap fB with hpref
  set suff := post.flatMap fB with hsuff
  obtain ⟨ws, hmono, hrange, hpt⟩ :=
    k1v_bracket_extract_mono M atomMap ((pref ++ fB a) ++ suff) lR ptW segL segR x t h
  -- Index of the chosen pin `p0` within `pins a`, hence within the block `fB a = subChain a ++ pins a`.
  obtain ⟨j0, hj0, hpj0⟩ := List.mem_iff_getElem.mp hp0
  have hfa_len : (fB a).length = (subChain a).length + (pins a).length := by
    rw [hfB]; simp only [List.length_append]
  have hpin_lt : (subChain a).length + j0 < (fB a).length := by rw [hfa_len]; omega
  have hLLlen : ((pref ++ fB a) ++ suff).length
      = pref.length + (fB a).length + suff.length := by
    simp only [List.length_append]
  -- `w_outer` at the middle bracket position; `q` at the pin's global slot.
  refine ⟨ws ⟨((pref ++ fB a) ++ suff).length, by omega⟩,
          ws ⟨pref.length + ((subChain a).length + j0), by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
  · exact (hrange _).1
  · exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
  · exact (hrange _).2
  · -- p0 @ q : point type at the pin's global slot is `(fB a)[|subChain a| + j0] = (pins a)[j0] = p0`.
    have hpm := hpt ⟨pref.length + ((subChain a).length + j0), by omega⟩
    have helem_pin : (((pref ++ fB a) ++ suff) ++ ptW :: lR)[pref.length + ((subChain a).length + j0)]'(by
        simp only [List.length_append, List.length_cons]; omega) = p0 := by
      rw [List.getElem_append_left (show pref.length + ((subChain a).length + j0)
              < ((pref ++ fB a) ++ suff).length by simp only [List.length_append]; omega)]
      rw [getElem_append3_mid pref (fB a) suff ((subChain a).length + j0) hpin_lt]
      simp only [hfB]
      rw [List.getElem_append_right (Nat.le_add_right (subChain a).length j0)]
      simp only [Nat.add_sub_cancel_left]
      exact hpj0
    rw [helem_pin] at hpm
    exact hpm
  · -- Every sub-chain slot realized strictly below `q` (its index precedes the pin's index).
    intro fcp hfcp
    obtain ⟨i, hi, hfi⟩ := List.mem_iff_getElem.mp hfcp
    have hi_block : i < (fB a).length := by rw [hfa_len]; omega
    refine ⟨ws ⟨pref.length + i, by omega⟩, ?_, ?_, ?_⟩
    · exact (hrange _).1
    · exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
    · -- fcp @ u : point type at the sub-chain global slot is `(fB a)[i] = (subChain a)[i] = fcp`.
      have hpi := hpt ⟨pref.length + i, by omega⟩
      have helem_sub : (((pref ++ fB a) ++ suff) ++ ptW :: lR)[pref.length + i]'(by
          simp only [List.length_append, List.length_cons]; omega) = fcp := by
        rw [List.getElem_append_left (show pref.length + i < ((pref ++ fB a) ++ suff).length by
              simp only [List.length_append]; omega)]
        rw [getElem_append3_mid pref (fB a) suff i hi_block]
        simp only [hfB]
        rw [List.getElem_append_left hi]
        exact hfi
      rw [helem_sub] at hpi
      exact hpi

/-- **The bounded-point-insertion composition deliverable** (task 326 Phase 5 — the task's terminus).
    From the OUTER k=2 bracket's soundness-side `.holds` over the fixed endpoints `(x, t)` — whose
    left-witness block is `l.flatMap (fun b => kvE_subChain2V charBase charK b ++ pins b)` (exactly
    `kvE2_body`'s `slotsFor`, :8505-8506) — and a chosen pin `p0 ∈ pins σ` that IS the anchor pin
    `⟨charK (nfk_projFresh σ)⟩`, produce the bounded anchor bundle `(q, x < q, q < t, hanchor, hbelow)`
    that `kvE_subBracket2V_sound_of_parts` (:7719) consumes: `q` realizes the fresh depth-1 anchor
    `⟨charK (nfk_projFresh σ)⟩` and every `zXU`-positive `χ` is realized STRICTLY BELOW `q`.

    Pipeline (all forward; reverse Cor 5.4 SIDESTEPPED): the generalized order-preserving extraction
    `bracketFromLists_flatMap_subchain_below_pin` (Phase 1/5) delivers `q` (the pin witness, bounded
    `x < q < w_outer < t`) plus `hreal` (every `kvE_subChain2V σ` slot realized in `(x, q)` by the
    monotone block ordering — the sub-chain segment precedes the pins segment); `hreal` feeds Phase 4.2's
    `kvE_subChain2V_hbelow_of_realized` to yield `hbelow`. The `q < t` bound rides `q < w_outer < t`
    (slot monotonicity + Phase 1), never a formula literal (litmus PASS): no `x1 < e_i` position identity.
    Rabinovich 2014 **Lemma 5.1** (md:169-171, pin bound), **Lemma 5.3** (md:137-152, arrangement
    coverage), **Cor 5.4** (md:154-157, forward bounded interior placement). -/
theorem kvE_sub2V_bounded_anchor_of_outer {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l : List (NormalForm sig 1 4))
    (pins : NormalForm sig 1 4 → List TemporalPred)
    (ptW segL segR : TemporalPred) (lR : List TemporalPred)
    (x t : M.carrier) (hσl : σ ∈ l)
    (p0 : TemporalPred) (hp0 : p0 ∈ pins σ)
    (hp0eq : p0 = (⟨charK (nfk_projFresh σ)⟩ : TemporalPred))
    (h : (bracketFromLists (l.flatMap (fun b => kvE_subChain2V charBase charK b ++ pins b))
          ptW lR segL segR).holds M atomMap x t) :
    ∃ q : M.carrier, x < q ∧ q < t ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap q ∧
      (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ u : M.carrier, x < u ∧ u < q ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) := by
  obtain ⟨w_outer, q, hxq, hqw, hwt, hp0q, hsub⟩ :=
    bracketFromLists_flatMap_subchain_below_pin M atomMap l (kvE_subChain2V charBase charK) pins
      ptW segL segR lR x t σ hσl p0 hp0 h
  refine ⟨q, hxq, hqw.trans hwt, ?_, ?_⟩
  · rw [← hp0eq]; exact hp0q
  · exact kvE_subChain2V_hbelow_of_realized charBase charK σ M atomMap x q hsub

/-- **End-to-end k=2 sub-witness soundness from the outer bracket** (task 326 Phase 5; the interface
    confirmation for task 321 Phase 10). Chains the bundle deliverable
    `kvE_sub2V_bounded_anchor_of_outer` (at the standard instantiation
    `charBase = nf_depth0_char_formula atomMap h_surj`) directly into `kvE_subBracket2V_sound_of_parts`
    (:7719), PROVING BY CONSTRUCTION that the bundle `(q, hxx1, hx1t, hanchor, hbelow)` instantiates the
    consumer's argument types EXACTLY — the anchor `⟨charK (nfk_projFresh σ)⟩` and the below-anchor
    `⟨nf_depth0_char_formula atomMap h_surj χ⟩` witnesses unify with the consumer's expected shapes with
    no coercion. `hgate` (the explicit outer-gate hypothesis, Amendment F3) is threaded through verbatim.
    This is the lemma task 321 re-points Phase 10 at. Rabinovich 2014 Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2V_sound_of_outer {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (l : List (NormalForm sig 1 4))
    (pins : NormalForm sig 1 4 → List TemporalPred)
    (ptW segL segR : TemporalPred) (lR : List TemporalPred)
    (hσl : σ ∈ l)
    (p0 : TemporalPred) (hp0 : p0 ∈ pins σ)
    (hp0eq : p0 = (⟨charK (nfk_projFresh σ)⟩ : TemporalPred))
    (h : (bracketFromLists
          (l.flatMap (fun b => kvE_subChain2V (nf_depth0_char_formula atomMap h_surj) charK b ++ pins b))
          ptW lR segL segR).holds M atomMap x t)
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
    ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨q, hxq, hqt, hanchor, hbelow⟩ :=
    kvE_sub2V_bounded_anchor_of_outer (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap
      l pins ptW segL segR lR x t hσl p0 hp0 hp0eq h
  exact kvE_subBracket2V_sound_of_parts atomMap h_surj charK σ M w x t q hxq hqt hanchor hbelow hgate

/-! ### Task 325 v2 Phase 1: the mandatory NON-VACUITY GATE

Two consecutive prior iterations (task 324 Phase 6; task 325 v1 Phase 4) closed soundness over an
always-`False` carrier — vacuously. v2's structural countermeasure: an explicit, machine-checked
non-vacuity lemma that MUST close before soundness/completeness are attempted, proving the corrected
NINE-zone gate is satisfiable by an honest σ and the carrier's `disjuncts` list is non-empty. The
key arity-4 realizability lemma `kvE_sub2V_zone_consistent` (the analog of `k1v_zone_consistent`
:2065) shows every zone realized by a point over the honest env `[x1, w, x, t]` under the order
`x < x1 < w < t` is one of the NINE consistent zones — its contrapositive discharges gate conjunct
(ii). Rabinovich Def 3.1 (md:61-74), Prop 4.2 (md:100-101). -/

/-- Any zone spec realized by a point over the anchor env `[x1, w, x, t]` with `x < x1 < w < t` is
    one of the NINE order-consistent zones (Def 3.1, PDF pp.4-5: disjunctions range only over
    consistent order types). The arity-4 lift of `k1v_zone_consistent` :2065, extended for the two
    interior witness self-zones `zAtX1`, `zAtW`. Its contrapositive discharges the inconsistent-zone
    fold bits against gate conjunct (ii) — the machine-verified v1 empty-gate fix. -/
private theorem kvE_sub2V_zone_consistent {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x1 w x t u : M.carrier)
    (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs u) :
    zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false)))) ∨
    zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))) ∨
    zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
    zs = Fin.cons (false, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
    zs = Fin.cons (false, true) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false)))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))) := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  have h3 := hz ⟨3, by omega⟩
  simp only [Fin.cons] at h0 h1 h2 h3
  have hzs : ∀ (p0 p1 p2 p3 : Bool × Bool),
      zs ⟨0, by omega⟩ = p0 → zs ⟨1, by omega⟩ = p1 → zs ⟨2, by omega⟩ = p2 →
        zs ⟨3, by omega⟩ = p3 →
      zs = Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3))) := by
    intro p0 p1 p2 p3 e0 e1 e2 e3
    funext i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using e0
    | ⟨1, _⟩ => simpa only [Fin.cons] using e1
    | ⟨2, _⟩ => simpa only [Fin.cons] using e2
    | ⟨3, _⟩ => simpa only [Fin.cons] using e3
  have hxw : x < w := hxx1.trans hx1w
  have hxt : x < t := hxw.trans hwt
  have hx1t : x1 < t := hx1w.trans hwt
  rcases lt_trichotomy u x with hux | hux | hux
  · -- u < x : zPastX
    have hux1 : u < x1 := hux.trans hxx1
    have huw : u < w := hux1.trans hx1w
    have hut : u < t := huw.trans hwt
    exact Or.inl (hzs _ _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hux1, k1v_bool_eq_false h0.2 (lt_asymm hux1)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hux, k1v_bool_eq_false h2.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))
  · -- u = x : zAtX
    subst hux
    exact Or.inr (Or.inl (hzs _ _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hxx1, k1v_bool_eq_false h0.2 (lt_asymm hxx1)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hxw, k1v_bool_eq_false h1.2 (lt_asymm hxw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl u),
        k1v_bool_eq_false h2.2 (lt_irrefl u)⟩)
      (Prod.ext_iff.mpr ⟨h3.1.mp hxt, k1v_bool_eq_false h3.2 (lt_asymm hxt)⟩)))
  · -- x < u : split against x1
    rcases lt_trichotomy u x1 with hux1 | hux1 | hux1
    · -- x < u < x1 : zXU
      have huw : u < w := hux1.trans hx1w
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp hux1, k1v_bool_eq_false h0.2 (lt_asymm hux1)⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hux), h2.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))
    · -- u = x1 : zAtX1
      subst hux1
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
          k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp hx1w, k1v_bool_eq_false h1.2 (lt_asymm hx1w)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxx1), h2.2.mp hxx1⟩)
        (Prod.ext_iff.mpr ⟨h3.1.mp hx1t, k1v_bool_eq_false h3.2 (lt_asymm hx1t)⟩)))))
    · -- x1 < u : split against w
      rcases lt_trichotomy u w with huw | huw | huw
      · -- x1 < u < w : zUW
        have hut : u < t := huw.trans hwt
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hux1), h0.2.mp hux1⟩)
          (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hux), h2.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))))
      · -- u = w : zAtW
        subst huw
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1w), h0.2.mp hx1w⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
            k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxw), h2.2.mp hxw⟩)
          (Prod.ext_iff.mpr ⟨h3.1.mp hwt, k1v_bool_eq_false h3.2 (lt_asymm hwt)⟩)))))))
      · -- w < u : split against t
        have hx1u : x1 < u := hx1w.trans huw
        have hxu : x < u := hxw.trans huw
        rcases lt_trichotomy u t with hut | hut | hut
        · -- w < u < t : zWT
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u), h0.2.mp hx1u⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm huw), h1.2.mp huw⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu), h2.2.mp hxu⟩)
            (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))))))
        · -- u = t : zAtT
          subst hut
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u), h0.2.mp hx1u⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm huw), h1.2.mp huw⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu), h2.2.mp hxu⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h3.1 (lt_irrefl u),
              k1v_bool_eq_false h3.2 (lt_irrefl u)⟩)))))))))
        · -- t < u : zFutT
          have hx1u' : x1 < u := hx1t.trans hut
          have hxu' : x < u := hxt.trans hut
          have hwu' : w < u := hwt.trans hut
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u'), h0.2.mp hx1u'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hwu'), h1.2.mp hwu'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu'), h2.2.mp hxu'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h3.1 (lt_asymm hut), h3.2.mp hut⟩)))))))))

/-- **NON-VACUITY GATE, part 1 — the corrected nine-zone gate holds for an honest σ**
    (task 325 v2 Phase 1; the EXACT statement whose negation the removed v1 probe
    `kvE_subBracket2V_gate_unsat_PROBE` proved over the old 7-zone gate — now flipped to provable).
    From an honest depth-1 realization at the anchor env `[x1, w, x, t]` under the order
    `x < x1 < w < t`, BOTH gate conjuncts hold: (i) off-fiber falsity is the fold's own off-fiber
    clause; (ii) inconsistent-zone falsity via the `kvE_sub2V_zone_consistent` contrapositive — the
    forced-true bits at `zAtX1`/`zAtW` no longer contradict conjunct (ii) because those self-zones
    are now among the NINE consistent zones. Rabinovich Prop 4.2 (md:100-101), Def 3.1 (md:61-74). -/
theorem kvE_subBracket2V_gate_holds_of_honest {sig : MonadicSignature}
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier)
    (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (h : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (∀ sub : NormalForm sig 0 5, nf0_dropFresh sub ≠ σ.1 → σ.2 sub = false) ∧
    (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
      ¬(zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false)))) ∨
        zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))) ∨
        zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
        zs = Fin.cons (false, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
        zs = Fin.cons (false, true) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
        zs = Fin.cons (false, true) (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
        zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
        zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false)))) ∨
        zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))))) →
      σ.2 (nf0_assemble zs χ σ.1) = false) := by
  obtain ⟨_h_atom, h_zone, h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp h
  refine ⟨h_off, fun zs χ hncons => ?_⟩
  cases hb : σ.2 (nf0_assemble zs χ σ.1) with
  | false => rfl
  | true =>
    obtain ⟨u, hzu, -⟩ := (h_zone zs χ).mpr hb
    exact absurd (kvE_sub2V_zone_consistent M x1 w x t u hxx1 hx1w hwt zs hzu) hncons

/-- **NON-VACUITY GATE, part 2 — the corrected carrier is inhabited for an honest σ**
    (task 325 v2 Phase 1; refutes the removed v1 probe `kvE_subBracket2V_never_holds_PROBE`). For σ
    arising from an actual model realization under `x < x1 < w < t`, the corrected nine-zone gate
    holds (part 1), so the carrier takes the gate-true branch and its `disjuncts` list is the NON-empty
    arrangement `flatMap` (the identity arrangement of each region-positive enumeration is always
    present). Hence `(kvE_subBracket2V …).holds` is NOT definitionally `False`, and soundness
    (Phase 2) can no longer close vacuously. Rabinovich Prop 4.2 (md:100-101). -/
theorem kvE_subBracket2V_nonvacuous {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier)
    (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (h : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (kvE_subBracket2V charBase charK σ).disjuncts ≠ [] := by
  have hgate := kvE_subBracket2V_gate_holds_of_honest σ M x1 w x t hxx1 hx1w hwt h
  simp only [kvE_subBracket2V]
  split
  case isTrue _ =>
    apply List.ne_nil_of_mem
    apply List.mem_flatMap.mpr
    refine ⟨_, List.mem_permutations.mpr (List.Perm.refl _), ?_⟩
    apply List.mem_flatMap.mpr
    refine ⟨_, List.mem_permutations.mpr (List.Perm.refl _), ?_⟩
    apply List.mem_map.mpr
    exact ⟨_, List.mem_permutations.mpr (List.Perm.refl _), rfl⟩
  case isFalse hg =>
    exact absurd hgate hg

/-- **Standalone completeness of the redesigned `VVecEA2` sub-bracket** (task 325 v2 Phase 3; the
    arity-4 three-region analog of `bracketEndChar_k1v_complete` :2979 — the direction that was
    BLOCKED on both prior carriers). From an honest depth-1 realization at the anchor env
    `[x1, w, x, t]` (order `x < x1 < w < t` supplied by the three σ.1 order bits), the corrected
    NINE-zone `VVecEA2` arrangement disjunction holds at the FIXED endpoints `(x, t)`. Mechanism:
    (a) the honest σ discharges the carrier gate via `kvE_subBracket2V_gate_holds_of_honest`
    (Phase 1), so the disjuncts list is the non-empty `flatMap` (never the empty branch);
    (b) `kvE_subBracket2_complete_extract` (SURVIVE, :6683) supplies the per-region monotone inner
    witnesses; (c) `k1v_sorted_realization3` (:6947) selects the model-sorted arrangement disjunct;
    (d) `k1v_bracket_construct3` (:7023) assembles the three-region bracket, discharging the three
    per-region segment types `segXU`/`segUW`/`segWT` (each satisfiable because every point of its
    region is genuinely zone-positive there — the exact property the refuted constant `segExcl`
    violated); (e) the folded witness point types `ptX1`/`ptW` are discharged at `x1`/`w`. STANDALONE:
    like soundness's `hgate`, the `charK`-realization of the fresh witness `x1` is an explicit
    hypothesis `hcharK` (never wired to the real outer gate; Amendment F3 — no provider pinning).
    Rabinovich Lemma 5.3 (md:137-152, per-region segment types + disjunction-over-arrangements),
    Cor 5.4 (md:154-157, per-region F_i chain), Prop 4.2 (md:100-101), Def 3.1 (md:61-74). -/
theorem kvE_subBracket2V_complete {sig : MonadicSignature}
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
    (h : ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap x t := by
  obtain ⟨x1, hx1⟩ := h
  -- Fold decomposition of the honest depth-1 realization (Prop 4.2, PDF p.6; rule N2).
  obtain ⟨h_atom, h_zone, h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hx1
  -- Recover the honest order `x < x1 < w < t` from the atom layer + the three σ.1 order bits.
  have hxx1 : x < x1 := by
    have h1 := h_atom (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1; exact h1.mpr h_xx1
  have hx1w : x1 < w := by
    have h1 := h_atom (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1; exact h1.mpr h_x1w
  have hwt : w < t := by
    have h1 := h_atom (.order ⟨1, by omega⟩ ⟨3, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1; exact h1.mpr h_wt
  have hxw : x < w := hxx1.trans hx1w
  have hxt : x < t := hxw.trans hwt
  have hx1t : x1 < t := hx1w.trans hwt
  -- Complete-type correctness bridge (charBase χ at u ↔ arity-1 depth-0 evaluation).
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ') ↔
      nf_eval_nf M 0 1 (fun _ => u) χ' :=
    fun χ' u => nfPred_correct M atomMap h_surj χ' u
  -- Coordinate-projection point evaluations of the two fixed endpoints and the witness `w`
  -- (Def 3.1 ordering channel; the arity-4 analog of `k1v_extract_x_nf3`/`_t_nf3`/`_y_nf`).
  have h_x_nf : nf_eval_nf M 0 1 (fun _ => x)
      (fun a => match a with
        | .pred p _ => σ.1 (.pred p (2 : Fin 4))
        | .order i j h => absurd (Subsingleton.elim i j) h) := by
    intro a
    match a with
    | .pred p _ =>
      have := h_atom (.pred p (2 : Fin 4))
      simp only [atom_eval, Fin.cons] at this ⊢; exact this
    | .order i j h => exact absurd (Subsingleton.elim i j) h
  have h_t_nf : nf_eval_nf M 0 1 (fun _ => t)
      (fun a => match a with
        | .pred p _ => σ.1 (.pred p (3 : Fin 4))
        | .order i j h => absurd (Subsingleton.elim i j) h) := by
    intro a
    match a with
    | .pred p _ =>
      have := h_atom (.pred p (3 : Fin 4))
      simp only [atom_eval, Fin.cons] at this ⊢; exact this
    | .order i j h => exact absurd (Subsingleton.elim i j) h
  have h_w_nf : nf_eval_nf M 0 1 (fun _ => w)
      (fun a => match a with
        | .pred p _ => σ.1 (.pred p (1 : Fin 4))
        | .order i j h => absurd (Subsingleton.elim i j) h) := by
    intro a
    match a with
    | .pred p _ =>
      have := h_atom (.pred p (1 : Fin 4))
      simp only [atom_eval, Fin.cons] at this ⊢; exact this
    | .order i j h => exact absurd (Subsingleton.elim i j) h
  -- Zone-membership constructors over the anchor env `[x1, w, x, t]` (Def 3.1, PDF p.4).
  have hzPastX : ∀ v, v < x →
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (true, false) (Fin.cons (true, false)
          (Fin.cons (true, false) (fun _ => (true, false))))) v := by
    intro v hvx
    have hvx1 : v < x1 := hvx.trans hxx1
    have hvw : v < w := hvx1.trans hx1w
    have hvt : v < t := hvw.trans hwt
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1) (by simp)⟩,
      ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw) (by simp)⟩,
      ⟨iff_of_true hvx rfl, iff_of_false (lt_asymm hvx) (by simp)⟩,
      ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt) (by simp)⟩⟩
  have hzAtX : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (true, false) (Fin.cons (true, false)
          (Fin.cons (false, false) (fun _ => (true, false))))) x := by
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hxx1 rfl, iff_of_false (lt_asymm hxx1) (by simp)⟩,
      ⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by simp)⟩,
      ⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
      ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
  have hzXU : ∀ u, x < u → u < x1 →
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zXU u := by
    intro u hxu hux1
    have huw : u < w := hux1.trans hx1w
    have hut : u < t := huw.trans hwt
    rw [show kvE_sub2_zXU = Fin.cons (true, false) (Fin.cons (true, false)
        (Fin.cons (false, true) (fun _ => (true, false)))) from rfl, kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by simp)⟩,
      ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtX1 : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (false, false) (Fin.cons (true, false)
          (Fin.cons (false, true) (fun _ => (true, false))))) x1 := by
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_irrefl x1) (by simp), iff_of_false (lt_irrefl x1) (by simp)⟩,
      ⟨iff_of_true hx1w rfl, iff_of_false (lt_asymm hx1w) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxx1) (by simp), iff_of_true hxx1 rfl⟩,
      ⟨iff_of_true hx1t rfl, iff_of_false (lt_asymm hx1t) (by simp)⟩⟩
  have hzUW : ∀ u, x1 < u → u < w →
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zUW u := by
    intro u hx1u huw
    have hxu : x < u := hxx1.trans hx1u
    have hut : u < t := huw.trans hwt
    rw [show kvE_sub2_zUW = Fin.cons (false, true) (Fin.cons (true, false)
        (Fin.cons (false, true) (fun _ => (true, false)))) from rfl, kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hx1u) (by simp), iff_of_true hx1u rfl⟩,
      ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtW : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (false, true) (Fin.cons (false, false)
          (Fin.cons (false, true) (fun _ => (true, false))))) w := by
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hx1w) (by simp), iff_of_true hx1w rfl⟩,
      ⟨iff_of_false (lt_irrefl w) (by simp), iff_of_false (lt_irrefl w) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxw) (by simp), iff_of_true hxw rfl⟩,
      ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by simp)⟩⟩
  have hzWT : ∀ u, w < u → u < t →
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zWT u := by
    intro u hwu hut
    have hx1u : x1 < u := hx1w.trans hwu
    have hxu : x < u := hxw.trans hwu
    rw [show kvE_sub2_zWT = Fin.cons (false, true) (Fin.cons (false, true)
        (Fin.cons (false, true) (fun _ => (true, false)))) from rfl, kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hx1u) (by simp), iff_of_true hx1u rfl⟩,
      ⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtT : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (false, true) (Fin.cons (false, true)
          (Fin.cons (false, true) (fun _ => (false, false))))) t := by
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hx1t) (by simp), iff_of_true hx1t rfl⟩,
      ⟨iff_of_false (lt_asymm hwt) (by simp), iff_of_true hwt rfl⟩,
      ⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
      ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
  have hzFutT : ∀ v, t < v →
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (false, true) (Fin.cons (false, true)
          (Fin.cons (false, true) (fun _ => (false, true))))) v := by
    intro v htv
    have hwv : w < v := hwt.trans htv
    have hx1v : x1 < v := hx1t.trans htv
    have hxv : x < v := hxt.trans htv
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hx1v) (by simp), iff_of_true hx1v rfl⟩,
      ⟨iff_of_false (lt_asymm hwv) (by simp), iff_of_true hwv rfl⟩,
      ⟨iff_of_false (lt_asymm hxv) (by simp), iff_of_true hxv rfl⟩,
      ⟨iff_of_false (lt_asymm htv) (by simp), iff_of_true htv rfl⟩⟩
  -- Gate for the honest σ (Phase-1 non-vacuity result): the branch selector for the disjuncts.
  have hgate := kvE_subBracket2V_gate_holds_of_honest σ M x1 w x t hxx1 hx1w hwt hx1
  -- Per-region monotone inner witnesses (SURVIVE `kvE_subBracket2_complete_extract` :6683).
  obtain ⟨_hatom2, _hoff2, _hfwd2, hbelowXU, hbelowUW, hbelowWT⟩ :=
    kvE_subBracket2_complete_extract σ M x1 w x t hx1
  -- The three region-positive enumerations (duplicate-free `Finset.univ.toList` filters).
  set S_XU : List (NormalForm sig 0 1) :=
    (Finset.univ.toList).filter (fun χ => σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1)) with hSXU
  set S_UW : List (NormalForm sig 0 1) :=
    (Finset.univ.toList).filter (fun χ => σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1)) with hSUW
  set S_WT : List (NormalForm sig 0 1) :=
    (Finset.univ.toList).filter (fun χ => σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1)) with hSWT
  have hrealXU : ∀ χ ∈ S_XU, ∃ u, x < u ∧ u < x1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ hχ => hbelowXU χ (List.mem_filter.mp hχ).2
  have hrealUW : ∀ χ ∈ S_UW, ∃ u, x1 < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ hχ => hbelowUW χ (List.mem_filter.mp hχ).2
  have hrealWT : ∀ χ ∈ S_WT, ∃ u, w < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ hχ => hbelowWT χ (List.mem_filter.mp hχ).2
  -- Sorted arrangement selection across the three regions (SURVIVE `k1v_sorted_realization3`).
  obtain ⟨psXU, psUW, psWT, hpermXU, hpermUW, hpermWT, hsortFull, hpropsXU, hpropsUW, hpropsWT⟩ :=
    k1v_sorted_realization3 M x x1 w t hxx1 hx1w hwt S_XU S_UW S_WT
      ((Finset.nodup_toList _).filter _) ((Finset.nodup_toList _).filter _)
      ((Finset.nodup_toList _).filter _) hrealXU hrealUW hrealWT
  -- Enter the carrier: gate branch, then the (psXU, psUW, psWT) arrangement disjunct (rule N5).
  simp only [kvE_subBracket2V, VVecEA2.holds]
  split
  case isFalse hg => exact absurd hgate hg
  case isTrue hg =>
  refine ⟨_, List.mem_flatMap.mpr ⟨psXU.map Prod.fst, List.mem_permutations.mpr hpermXU,
    List.mem_flatMap.mpr ⟨psUW.map Prod.fst, List.mem_permutations.mpr hpermUW,
      List.mem_map.mpr ⟨psWT.map Prod.fst, List.mem_permutations.mpr hpermWT, rfl⟩⟩⟩, ?_⟩
  refine ⟨?_, ?_, ?_⟩
  · -- Left endpoint predicate at the FIXED `x` (exterior Since + at-x literals; Prop 3.5 p.5).
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hchar _ x).mpr h_x_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        split
        next hb =>
          obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
          obtain ⟨⟨_, _⟩, _, ⟨hvx, _⟩, _⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
          exact ⟨v, hvx.mpr rfl, (hchar χ v).mpr hev, fun r _ _ hfa => hfa⟩
        next hb =>
          rintro ⟨s, hsx, hsχ, -⟩
          have hbit := (h_zone _ χ).mp ⟨s, hzPastX s hsx, (hchar χ s).mp hsχ⟩
          exact absurd hbit hb
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      split
      next hb =>
        obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
        obtain ⟨_, _, ⟨hvx, hxv⟩, _⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
        have hveq : v = x := le_antisymm (not_lt.mp (k1v_not_of_iff_false hxv))
          (not_lt.mp (k1v_not_of_iff_false hvx))
        exact (hchar χ x).mpr (hveq ▸ hev)
      next hb =>
        intro hch
        have hbit := (h_zone _ χ).mp ⟨x, hzAtX, (hchar χ x).mp hch⟩
        exact absurd hbit hb
  · -- Right endpoint predicate at the FIXED `t` (at-t + exterior Until literals; Prop 3.5 p.5).
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hchar _ t).mpr h_t_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        split
        next hb =>
          obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
          obtain ⟨_, _, _, ⟨hvt, htv⟩⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
          have hveq : v = t := le_antisymm (not_lt.mp (k1v_not_of_iff_false htv))
            (not_lt.mp (k1v_not_of_iff_false hvt))
          exact (hchar χ t).mpr (hveq ▸ hev)
        next hb =>
          intro hch
          have hbit := (h_zone _ χ).mp ⟨t, hzAtT, (hchar χ t).mp hch⟩
          exact absurd hbit hb
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      split
      next hb =>
        obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
        obtain ⟨_, _, _, ⟨_, htv⟩⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
        exact ⟨v, htv.mpr rfl, (hchar χ v).mpr hev, fun r _ _ hfa => hfa⟩
      next hb =>
        rintro ⟨s, hts, hsχ, -⟩
        have hbit := (h_zone _ χ).mp ⟨s, hzFutT s hts, (hchar χ s).mp hsχ⟩
        exact absurd hbit hb
  · -- The three-region bracket, assembled from the sorted realizations (SURVIVE construct3).
    refine k1v_bracket_construct3 M atomMap _ _ _ _ _ _ _ _ x x1 w t hxx1 hx1w hwt
      (psXU.map Prod.snd) (psUW.map Prod.snd) (psWT.map Prod.snd)
      (by simp) (by simp) (by simp) hsortFull ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_
    · intro u hu
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
      exact (hpropsXU p hp).1
    · intro u hu
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
      exact (hpropsUW p hp).1
    · intro u hu
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
      exact (hpropsWT p hp).1
    · -- `ptX1` witness point at `x1`: charK head (via `hcharK`) + folded `zAtX1` literals.
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_cons.mp hf with rfl | hf
      · exact hcharK x1 hx1
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        split
        next hb =>
          obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
          obtain ⟨⟨hvx1, hx1v⟩, _, _, _⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
          have hveq : v = x1 := le_antisymm (not_lt.mp (k1v_not_of_iff_false hx1v))
            (not_lt.mp (k1v_not_of_iff_false hvx1))
          exact (hchar χ x1).mpr (hveq ▸ hev)
        next hb =>
          intro hch
          have hbit := (h_zone _ χ).mp ⟨x1, hzAtX1, (hchar χ x1).mp hch⟩
          exact absurd hbit hb
    · -- `ptW` witness point at `w`: charBase head (`h_w_nf`) + folded `zAtW` literals.
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_cons.mp hf with rfl | hf
      · exact (hchar _ w).mpr h_w_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        split
        next hb =>
          obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
          obtain ⟨_, ⟨hvw, hwv⟩, _, _⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
          have hveq : v = w := le_antisymm (not_lt.mp (k1v_not_of_iff_false hwv))
            (not_lt.mp (k1v_not_of_iff_false hvw))
          exact (hchar χ w).mpr (hveq ▸ hev)
        next hb =>
          intro hch
          have hbit := (h_zone _ χ).mp ⟨w, hzAtW, (hchar χ w).mp hch⟩
          exact absurd hbit hb
    · -- Per-index `zXU` point types on the `psXU` witnesses.
      intro i hi
      have hi' : i < psXU.length := by simpa using hi
      have h1 : (List.map (fun χ => (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
          (psXU.map Prod.fst))[i]'hi =
          ⟨nf_depth0_char_formula atomMap h_surj ((psXU[i]'hi').1)⟩ := by
        simp only [List.getElem_map]
      have h2 : (psXU.map Prod.snd)[i]'(by simpa using hi') = (psXU[i]'hi').2 := by
        simp only [List.getElem_map]
      rw [h1, h2]
      exact (hchar _ _).mpr (hpropsXU _ (List.getElem_mem _)).2
    · -- Per-index `zUW` point types on the `psUW` witnesses.
      intro i hi
      have hi' : i < psUW.length := by simpa using hi
      have h1 : (List.map (fun χ => (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
          (psUW.map Prod.fst))[i]'hi =
          ⟨nf_depth0_char_formula atomMap h_surj ((psUW[i]'hi').1)⟩ := by
        simp only [List.getElem_map]
      have h2 : (psUW.map Prod.snd)[i]'(by simpa using hi') = (psUW[i]'hi').2 := by
        simp only [List.getElem_map]
      rw [h1, h2]
      exact (hchar _ _).mpr (hpropsUW _ (List.getElem_mem _)).2
    · -- Per-index `zWT` point types on the `psWT` witnesses.
      intro i hi
      have hi' : i < psWT.length := by simpa using hi
      have h1 : (List.map (fun χ => (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
          (psWT.map Prod.fst))[i]'hi =
          ⟨nf_depth0_char_formula atomMap h_surj ((psWT[i]'hi').1)⟩ := by
        simp only [List.getElem_map]
      have h2 : (psWT.map Prod.snd)[i]'(by simpa using hi') = (psWT[i]'hi').2 := by
        simp only [List.getElem_map]
      rw [h1, h2]
      exact (hchar _ _).mpr (hpropsWT _ (List.getElem_mem _)).2
    · -- `segXU` exclusion on ALL of `(x, x1)` (Rabinovich Cor 5.4 md:154-157).
      intro u hxu hux1
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      split
      next hb => exact fun hfa => hfa
      next hb =>
        intro hch
        have hbit := (h_zone _ χ).mp ⟨u, hzXU u hxu hux1, (hchar χ u).mp hch⟩
        exact absurd hbit hb
    · -- `segUW` exclusion on ALL of `(x1, w)`.
      intro u hx1u huw
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      split
      next hb => exact fun hfa => hfa
      next hb =>
        intro hch
        have hbit := (h_zone _ χ).mp ⟨u, hzUW u hx1u huw, (hchar χ u).mp hch⟩
        exact absurd hbit hb
    · -- `segWT` exclusion on ALL of `(w, t)`.
      intro u hwu hut
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      split
      next hb => exact fun hfa => hfa
      next hb =>
        intro hch
        have hbit := (h_zone _ χ).mp ⟨u, hzWT u hwu hut, (hchar χ u).mp hch⟩
        exact absurd hbit hb

/-- **Arity-4 correctness pair** for the nine-zone `VVecEA2` carrier `kvE_subBracket2V` — the
arity-4 analog of the k1v pair `(bracketEndChar_k1v_sound, bracketEndChar_k1v_complete)`
(:2338 / :2979). Bundles the two independently-driven, sorry-free directions of task 325 v2:

* **soundness** (`kvE_subBracket2V_sound`, Phase 2): the carrier `.holds` implies an honest
  depth-1 realization `∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ` exists;
* **completeness** (`kvE_subBracket2V_complete`, Phase 3): an honest realization implies the
  carrier `.holds`.

Both directions are machine-verified NON-vacuously: Phase-1 `kvE_subBracket2V_nonvacuous` proves
the nine-zone gate `consistent` set (which now includes the witness self-zones `zAtX1`, `zAtW`) is
satisfiable by an honest σ, so the carrier's `disjuncts` list is non-empty and soundness does not
close over an empty carrier (the exact defect that voided task 324 Phase 6 and task 325 v1).

Successor-parameterized at gate instance `j = 0` (`σ : NormalForm sig 1 4`, the landed instance of
the amended-spec header `NormalForm sig (j+1) 4`). Codomain is `VVecEA2` with three per-region
segment types `segXU`/`segUW`/`segWT`; anchor set fixed at `{x, t}` with `x1`, `w` as interior
witness slots (Guard G4/Anchor-Cap). Standalone against `nf_eval_nf M 1 4`; NOT wired into the outer
gate `kvE2_body`/`bracketEndChar_kvE2` (task 321's `/revise 321` work). No new proof obligations:
each direction is discharged by the corresponding Phase-2/3 lemma. -/
theorem kvE_subBracket2V_correctness_pair {sig : MonadicSignature}
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
    ((kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap x t →
      ∃ x1 : M.carrier,
        nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) ∧
    ((∃ x1 : M.carrier,
        nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap x t) :=
  ⟨fun h => kvE_subBracket2V_sound atomMap h_surj charK σ M w x t h hgate,
   fun h => kvE_subBracket2V_complete atomMap h_surj charK σ M w x t h_xx1 h_x1w h_wt hcharK h⟩


end Bimodal.Metalogic.WeakCanonical.Kamp
