/-
ARCHIVED — off-faithful-path (Kamp Boneyard). MOVE-not-delete; do NOT delete or empty.

Retired from the live build as a closed, unwired reference island: the losing arity-4
characteristic-formula branch. Adjudicated **landed, unwired, circular, fiber-refuted**. NOT on
the proof-term path from `completeness_discrete` or `kampPriorExpressiveCompleteness` (zero live
consumers at excision time; outside the Bimodal.lean import closure, so uncompiled).

The competing **zeta route won** and keeps `charF` arity-1 end-to-end. That is the whole reason
this branch is dead: nothing here is a missing piece of a live proof, it is the abandoned
alternative to a wire that already landed. Do NOT wire, repair, complete, or hunt for a consumer
for this stack; do NOT build an arity-4 realization engine from it; do NOT reach for
Feferman-Vaught. Those efforts were each tried and abandoned. Retained as machine-checked
evidence only.

Key declarations: kvFib_body, bracketEndCharKvFib, igAllSubs, igBodyFib,
bracketEndChar_kvFib_step_correct, bracketEndCharKvExtFib, bracketEndChar_kvExtFib_correct_prior,
kampPrior_site_rungKFib_gate_match

## Provenance

Copied verbatim from four contiguous source blocks, at the line ranges they occupied immediately
before excision:

| # | Origin file | Line range | Lines | Contents |
|---|---|---|---|---|
| 1 | `NfMultiAnchorBridge/CarrierKv.lean` | 503-616 | 114 | `kvFib_body`, `bracketEndCharKvFib` |
| 2 | `NfMultiAnchorBridge/InteriorGateGeneralK.lean` | 1424-2550 | 1127 | `igAllSubs`, the `ig*Fib` defs, the `bracketEndChar_kvFib_*` theorems |
| 3 | `NfMultiAnchorBridge/ExteriorGateAssembleK.lean` | 447-790 | 344 | the `*ExtFib` block |
| 4 | `Kamp/KampPrior.lean` | 1082-1232 | 151 | `kampPrior_site_rungKFib_gate_match` |

Total excised: 1,736 lines / 30 declarations. Blocks appear below in dependency order (1 -> 2 ->
3 -> 4), each under a sub-heading naming its origin.

## What is NOT here (and must not be confused with this island)

`igOffFiber` is **LIVE** and was deliberately NOT archived: it sits above this island in
`InteriorGateGeneralK.lean` and has three arity-1 consumers (`bracketEndChar_kv_succ_eq`,
`bracketEndChar_kv_succ_holds_iff`, `bracketEndChar_kv_step_gate`). The `kvEFiber*` and
`kvE_deepOnFiber_*` families are likewise live. They share the `Fib` suffix with this island's
members but are not part of it — which is why this stack was excised by verified line block and
never by a name sweep. Incidental *references* to live symbols inside the copied proof bodies
below are expected and are not archive members.

## Related Boneyard members of this same stack

`InteriorHrealSupplyK.lean` (hosts `kampPrior_hreal_supply`, whose firing route this island's
circularity record refutes), `SeamPairRefutationProbe.lean`, and
`ZoneSeamCrossContextProbe.lean`. Those three already name eight of this island's symbols, which
is the coherence argument for archiving this stack rather than raw-deleting it.
-/
import FormalSystem.Metalogic.WeakCanonical.Kamp.KampPrior
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierKv
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorGateGeneralK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorGateAssembleK

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# The arity-4 characteristic-formula stack (retired)

This leaf hosts the complete de-folded arity-4 branch: the sibling carrier
`bracketEndCharKvFib`, its interior gate replicas (`ig*Fib`), its exterior assembly
(`*ExtFib`), and the `kampPrior` site gate-match that would have consumed them
(`kampPrior_site_rungKFib_gate_match`).

## Why it is retired

The branch was **landed** (it compiled, sorry-free) but **unwired** (no live consumer ever
took it), **circular** (see the circularity record carried in block 2 below: the bridge it
needed requires the deep render as an explicit hypothesis, so the firing route for
`kampPrior_hreal_supply` is machine-confirmed circular), and **fiber-refuted**. The zeta route
resolved the same obligation while keeping `charF` arity-1 end-to-end, which settled the
routing question and left this branch with nothing to attach to.

## The two prose records carried here

Both original records travelled with their enclosing blocks and are preserved VERBATIM below:

- **The M1 fold-information-loss record** — heads block 1 (`CarrierKv.lean:503-516`). Documents
  that the frozen, LIVE `bracketEndCharKv` folds each marked arity-4 fiber down to
  `(nf0ZoneSpec (atomAssgn sub), nfkProjFresh sub)`.
- **The circularity record** — inside block 2 (`InteriorGateGeneralK.lean:1646-1670`). Documents
  that `igFoldBit_realize_iff` (LIVE) requires the deep render as an explicit hypothesis.

Because both records describe declarations that are still LIVE, condensed live-adjacent notes
were also left beside `bracketEndCharKv` and `igFoldBit_realize_iff` respectively, each pointing
back here. This file holds the full original text; those notes hold the pointer.
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation

-- COPIED (not moved) from `InteriorGateGeneralK.lean:679` — the originals remain in the live file.
open private k1v_sorted_insert k1v_zoneHolds_cons_iff k1v_extract_x_nf3 k1v_extract_t_nf3
  k1v_extract_y_nf k1v_bracket_construct from
  FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V

-- COPIED (not moved) from `InteriorGateGeneralK.lean:1100` and `ExteriorGateAssembleK.lean:51`
-- — the originals remain in the live files.
open private k1v_bracket_extract k1v_reconstruct_nf3 from
  FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V

/-! ## Block 1 of 4 — origin `NfMultiAnchorBridge/CarrierKv.lean:503-616` (114 lines)
    `kvFib_body`, `bracketEndCharKvFib`. Heads with the M1 fold-information-loss record. -/

/-! ## M2 (Option B) — the DE-FOLDED sibling carrier

The frozen `bracketEndCharKv` (`:238-249`) FOLDS each marked arity-4 fiber `sub : NormalForm sig k
4`
down to the arity-1 pair `(nf0ZoneSpec (atomAssgn sub), nfkProjFresh sub)` — the F1 information
loss that refutes M1 (the M1 refutation record). The M2 fix (Rabinovich Def 3.1 p.4: the witness
chain carries
the WHOLE ordered fiber, never folding) is the SIBLING carrier `bracketEndCharKvFib` below: it is
byte-parallel to the frozen carrier but keyed on the FULL arity-4 fiber `sub : NormalForm sig k 4`,
so the endpoint eval can rebuild the arity-4 σ-realizer the driver demands (goal
`∃ x1, NfEvalNf M k 4 [x1,w,x,t] σ`, InteriorHrealSupplyK:75).

This is an ADDITIVE parallel def (Option B): `bracketEndCharKv` (`:238-249`) and both frozen `rfl`
bridges stay byte-identical. The parallel-to-frozen bridge is Phase 2+ and need NOT be `rfl`. -/

/-- **Shared successor body of the DE-FOLDED sibling carrier**. Byte-parallel to
    the frozen private `kv_body` (`:152-226`), re-keyed from the arity-1 1-type `χ : NormalForm sig
    k 1`
    onto the FULL arity-4 fiber `σ : NormalForm sig k 4`: the fold-bit function `b` now selects over
    the whole fiber (`ZoneSpec 3 → NormalForm sig k 4 → Bool`, no `nfkProjFresh` collapse), the
    characteristic-formula provider `charFib` characterizes the arity-4 fiber, and every enumeration
    (`allSubs`, `S_L`, `S_R`) ranges over `NormalForm sig k 4`. Structure, zone constants, and
    citations are otherwise VERBATIM from `kv_body`. -/
private noncomputable def kvFib_body {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3)
    (offFiber : Prop)
    (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : VVecEA2 :=
    -- Zone-spec constants relative to env `[w, x, t]` under the bracket order `x < w < t`
    -- (Def 3.1 ordering channel, PDF p.4), verbatim from `kv_body` (`:160-171`).
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
    -- De-folded enumeration: the WHOLE arity-4 fiber, never projected to arity-1 (F1 channel kept).
    let allSubs : List (NormalForm sig k 4) := Finset.univ.toList
    let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
    let xType : TemporalPred := ⟨charBase (nfXProj3 r)⟩
    let tType : TemporalPred := ⟨charBase (nfTProj3 r)⟩
    let epL : TemporalPred :=
      ⟨formulaConjList
        (xType.formula
          :: (allSubs.map fun σ => lit (b zPastX σ) (Formula.snce (charFib σ) Formula.top))
          ++ (allSubs.map fun σ => lit (b zAtX σ) (charFib σ)))⟩
    let epR : TemporalPred :=
      ⟨formulaConjList
        (tType.formula
          :: (allSubs.map fun σ => lit (b zAtT σ) (charFib σ))
          ++ (allSubs.map fun σ => lit (b zFutT σ) (Formula.untl (charFib σ) Formula.top)))⟩
    let segL : TemporalPred :=
      ⟨formulaConjList (allSubs.map fun σ =>
        if b zXW σ then Formula.top else (charFib σ).neg)⟩
    let segR : TemporalPred :=
      ⟨formulaConjList (allSubs.map fun σ =>
        if b zWT σ then Formula.top else (charFib σ).neg)⟩
    let ptW : TemporalPred :=
      ⟨formulaConjList
        (charBase (nfYProj r)
          :: (allSubs.map fun σ => lit (b zAtW σ) (charFib σ)))⟩
    let consistent : ZoneSpec 3 → Prop := fun zs =>
      zs = zPastX ∨ zs = zAtX ∨ zs = zXW ∨ zs = zAtW ∨ zs = zWT ∨ zs = zAtT ∨ zs = zFutT
    let gate : Prop :=
      offFiber ∧
      (∀ (zs : ZoneSpec 3) (σ : NormalForm sig k 4), ¬ consistent zs → b zs σ = false)
    let S_L : List (NormalForm sig k 4) := allSubs.filter (fun σ => b zXW σ)
    let S_R : List (NormalForm sig k 4) := allSubs.filter (fun σ => b zWT σ)
    let charP : NormalForm sig k 4 → TemporalPred := fun σ => ⟨charFib σ⟩
    let mkDisjunct : List (NormalForm sig k 4) → List (NormalForm sig k 4) → Σ n, VecEA2 n :=
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

open Classical in
/-- **The DE-FOLDED depth-`k` V-carrier**. Byte-parallel sibling of the frozen
    `bracketEndCharKv` (`:238-249`): at `k + 1` it feeds `kvFib_body` the depth-`k` arity-4
    characteristic provider `charFib k`, the SAME atom-layer off-fiber conjunct, and the
    NON-PROJECTING
    fold bit `fun zs sub => decide (qnf.2 sub = true ∧ nf0ZoneSpec (atomAssgn sub) = zs)` — which
    keeps the full arity-4 fiber `sub` live (no `nfkProjFresh` collapse). The `k = 0` branch
    mirrors
    the frozen carrier (no fiber to carry at depth 0). `open Classical in` matches the fold-bit
    existential's `Decidable` instance to the frozen carrier's. -/
noncomputable def bracketEndCharKvFib {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula) :
    (k : Nat) → BracketEndCharCarrierV sig k
  | 0 => fun qnf => { disjuncts := [⟨1, bracketEndCharK0 atomMap h_surj qnf⟩] }
  | k + 1 => fun qnf =>
    kvFib_body (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
      (∀ sub : NormalForm sig k 4,
        nf0DropFresh (NormalForm.atomAssgn sub) ≠ qnf.1 → qnf.2 sub = false)
      (fun zs sub => decide (qnf.2 sub = true ∧
        nf0ZoneSpec (NormalForm.atomAssgn sub) = zs))


/-! ## Block 2 of 4 — origin `NfMultiAnchorBridge/InteriorGateGeneralK.lean:1424-2550` (1127 lines)
    `igAllSubs`, the `ig*Fib` defs, the `bracketEndChar_kvFib_*` theorems.
    Carries the circularity record (origin `:1646-1670`). -/

/-! ## M2 (Option B) — DE-FOLDED public replicas (sibling of `igBody`)

Byte-parallel siblings of the public replicas above (`igEpL`..`igBody`, `:209-299`, and the fold bit
`igFoldBit`, `:318-332`), re-keyed from the arity-1 1-type `χ : NormalForm sig k 1` onto the FULL
arity-4 fiber `σ : NormalForm sig k 4`. These are the public destructuring surface for the de-folded
carrier `bracketEndCharKvFib` (CarrierKv). The non-projecting fold bit `igFoldBitFib` keeps the
whole
fiber live (NO `nfkProjFresh` collapse — the F1 channel the frozen `igFoldBit` loses). The
`igBodyFib`↔carrier defeq bridge is Phase 2 (and, per the plan, need NOT be `rfl`); Phase 1 only
lands
these type-correct, sorry-free parallel defs. The frozen replicas and both `rfl` bridges are
untouched. -/

/-- De-folded enumeration of complete depth-`k` arity-4 fibers (arity-4 analog of `igAllTypes`,
    `:203`). -/
def igAllSubs (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat) : List
    (NormalForm sig k 4) := Finset.univ.toList

/-- **The NON-PROJECTING fiber fold-bit read** (de-folded analog of `igFoldBit`,
    `:318-332`). Keyed on the FULL arity-4 fiber `sub : NormalForm sig k 4`: TRUE iff `sub` is
    marked
    and its atom-layer zone is `zs`. Unlike `igFoldBit`, there is NO `nfkProjFresh sub = χ`
    collapse
    — the whole fiber `sub` is retained (the F1 channel M2 preserves). The `Decidable` instance is
    `Classical.propDecidable`, matching the sibling carrier `bracketEndCharKvFib`'s `open
    Classical`
    fold bit. -/
def igFoldBitFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (qnf : NormalForm sig (k + 1) 3) :
    ZoneSpec 3 → NormalForm sig k 4 → Bool :=
  fun zs sub =>
    @decide (qnf.2 sub = true ∧ nf0ZoneSpec (NormalForm.atomAssgn sub) = zs)
      (Classical.propDecidable _)

/-- Left endpoint predicate, de-folded (arity-4 analog of `igEpL`, `:209-215`). -/
def igEpLFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : TemporalPred :=
  ⟨formulaConjList
    (charBase (nfXProj3 r)
      :: (igAllSubs sig k).map (fun σ => igLit (b igZPastX σ)
          (Formula.snce (charFib σ) Formula.top))
      ++ (igAllSubs sig k).map (fun σ => igLit (b igZAtX σ) (charFib σ)))⟩

/-- Right endpoint predicate, de-folded (arity-4 analog of `igEpR`, `:219-225`). -/
def igEpRFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : TemporalPred :=
  ⟨formulaConjList
    (charBase (nfTProj3 r)
      :: (igAllSubs sig k).map (fun σ => igLit (b igZAtT σ) (charFib σ))
      ++ (igAllSubs sig k).map (fun σ => igLit (b igZFutT σ)
          (Formula.untl (charFib σ) Formula.top)))⟩

/-- Left segment exclusion, de-folded (arity-4 analog of `igSegL`, `:228-232`). -/
def igSegLFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charFib : NormalForm sig k 4 → Formula) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) :
    TemporalPred :=
  ⟨formulaConjList ((igAllSubs sig k).map (fun σ =>
    if b igZXW σ then Formula.top else (charFib σ).neg))⟩

/-- Right segment exclusion, de-folded (arity-4 analog of `igSegR`, `:235-239`). -/
def igSegRFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charFib : NormalForm sig k 4 → Formula) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) :
    TemporalPred :=
  ⟨formulaConjList ((igAllSubs sig k).map (fun σ =>
    if b igZWT σ then Formula.top else (charFib σ).neg))⟩

/-- Witness point type at `w`, de-folded (arity-4 analog of `igPtW`, `:243-248`). -/
def igPtWFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : TemporalPred :=
  ⟨formulaConjList
    (charBase (nfYProj r)
      :: (igAllSubs sig k).map (fun σ => igLit (b igZAtW σ) (charFib σ)))⟩

/-- The gate Prop, de-folded (arity-4 analog of `igGate`, `:252-258`). -/
def igGateFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : Prop :=
  offFiber ∧
  (∀ (zs : ZoneSpec 3) (σ : NormalForm sig k 4),
    ¬ (zs = igZPastX ∨ zs = igZAtX ∨ zs = igZXW ∨ zs = igZAtW ∨ zs = igZWT ∨ zs = igZAtT ∨
        zs = igZFutT) →
      b zs σ = false)

/-- Interior-positive left enumeration `S_L`, de-folded (arity-4 analog of `igSL`, `:261-263`). -/
def igSLFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : List (NormalForm sig k 4) :=
  (igAllSubs sig k).filter (fun σ => b igZXW σ)

/-- Interior-positive right enumeration `S_R`, de-folded (arity-4 analog of `igSR`, `:266-268`). -/
def igSRFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : List (NormalForm sig k 4) :=
  (igAllSubs sig k).filter (fun σ => b igZWT σ)

/-- Per-fiber witness predicate `charP`, de-folded (arity-4 analog of `igCharP`, `:271-273`). -/
def igCharPFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charFib : NormalForm sig k 4 → Formula) : NormalForm sig k 4 → TemporalPred :=
  fun σ => ⟨charFib σ⟩

/-- One arrangement disjunct, de-folded (arity-4 analog of `igMkDisjunct`, `:276-284`). -/
def igMkDisjunctFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool)
    (lL lR : List (NormalForm sig k 4)) : Σ n, VecEA2 n :=
  ⟨(lL.map (igCharPFib charFib)).length + 1 + (lR.map (igCharPFib charFib)).length,
    { endpointLeft := igEpLFib charBase charFib r b
      endpointRight := igEpRFib charBase charFib r b
      bracket := bracketFromLists (lL.map (igCharPFib charFib)) (igPtWFib charBase charFib r b)
        (lR.map (igCharPFib charFib)) (igSegLFib charFib b) (igSegRFib charFib b) }⟩

/-- **De-folded public body replica** (arity-4 analog of `igBody`, `:290-299`).
    The gate-guarded `S_L`/`S_R` permutation-arrangement disjunction, built from the de-folded
    arity-4 pieces above. This is the public structural surface Phase 2 destructures (`igBodyFib`
    `.holds ↔ …`) and the sibling carrier `bracketEndCharKvFib` mirrors. -/
def igBodyFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) :
    VVecEA2 :=
  @dite _ (igGateFib offFiber b) (Classical.dec (igGateFib offFiber b))
    (fun _ =>
      { disjuncts :=
          (igSLFib b).permutations.flatMap (fun lL =>
            (igSRFib b).permutations.map (fun lR => igMkDisjunctFib charBase charFib r b lL lR)) })
    (fun _ => { disjuncts := [] })

/-- **De-folded `holds` destructuring of the public replica** (arity-4 analog of
    `igBody_holds_iff`, `:359-379`). Byte-parallel clone re-keyed onto the de-folded arity-4 pieces:
    the replica's `VVecEA2.holds` splits into the gate conjunct ∧ the `S_L`/`S_R` permutation
    disjunction; off-gate it is the empty disjunction `⟨[]⟩` whose `holds` is `False`. No chain step
    is shortcut: pure list-membership and `dite` computation. -/
theorem igBodyFib_holds_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (x t : M.carrier) :
    (igBodyFib charBase charFib r offFiber b).holds M atomMap x t ↔
      igGateFib offFiber b ∧
      ∃ lL ∈ (igSLFib b).permutations, ∃ lR ∈ (igSRFib b).permutations,
        (igMkDisjunctFib charBase charFib r b lL lR).2.holds M atomMap x t := by
  unfold igBodyFib
  by_cases hg : igGateFib offFiber b
  · rw [dif_pos hg,
      VVecEA2.holds_flatMap_map M atomMap (igSLFib b).permutations (igSRFib b).permutations
        (igMkDisjunctFib charBase charFib r b) x t]
    exact ⟨fun h => ⟨hg, h⟩, fun h => h.2⟩
  · rw [dif_neg hg]
    constructor
    · intro h
      obtain ⟨vea, hmem, -⟩ := h
      exact (List.not_mem_nil hmem).elim
    · intro h
      exact (hg h.1).elim

/-- **De-folded defeq bridge: the successor de-folded carrier IS the public replica** (the
    Phase 2; arity-4 analog of the FROZEN `bracketEndChar_kv_succ_eq`, `:339-351`). The `k+1` branch
    of the sibling `bracketEndCharKvFib` (`CarrierKv.lean:582-587`) feeds the private `kvFib_body`
    the depth-`k` arity-4 providers, the atom-layer off-fiber conjunct, and the NON-PROJECTING fold
    bit; `igBodyFib` is a verbatim public copy of `kvFib_body`'s body at the SAME args, and the fold
    bit is matched byte-for-byte by `igFoldBitFib` (both `Classical.propDecidable`). Per the plan
    the
    parallel-to-frozen bridge need NOT be `rfl`, but here it IS a pure `rfl` — the sibling carrier
    and
    its replica were built byte-parallel in Phase 1. Frozen `bracketEndCharKv` untouched. -/
theorem bracketEndChar_kvFib_succ_eq {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3) :
    bracketEndCharKvFib atomMap h_surj charFib (k + 1) qnf =
      igBodyFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
        (∀ sub : NormalForm sig k 4,
          nf0DropFresh (NormalForm.atomAssgn sub) ≠ qnf.1 → qnf.2 sub = false)
        (igFoldBitFib qnf) := by
  -- The carrier's fold bit and `igFoldBitFib` compute the SAME Bool but under different `Decidable`
  -- instances (CarrierKv has no `DecidableEq (ZoneSpec 3)` in scope, so its `And` uses
  -- `instDecidableAnd (instDecidableEqBool) (Classical.propDecidable)`; `igFoldBitFib` uses
  -- `Classical.propDecidable` on the whole `And`). They are propositionally equal by
  -- decide-instance
  -- irrelevance (`Subsingleton.elim` on `Decidable`), so the bridge is a proven `Eq`, not `rfl`.
  have hfold : igFoldBitFib qnf =
      (fun (zs : ZoneSpec 3) (sub : NormalForm sig k 4) =>
        @decide (qnf.2 sub = true ∧ nf0ZoneSpec (NormalForm.atomAssgn sub) = zs)
          (@instDecidableAnd (qnf.2 sub = true) (nf0ZoneSpec (NormalForm.atomAssgn sub) = zs)
            (instDecidableEqBool (qnf.2 sub) true)
            (Classical.propDecidable _))) := by
    funext zs sub
    unfold igFoldBitFib
    exact congrArg _ (Subsingleton.elim _ _)
  simp only [bracketEndCharKvFib, hfold]
  rfl

/-- **Successor de-folded carrier `holds` destructuring** (the deliverable;
    arity-4 analog of the FROZEN `bracketEndChar_kv_succ_holds_iff`, `:400-413`). Combines the
    de-folded defeq bridge `bracketEndChar_kvFib_succ_eq` with the replica destructuring
    `igBodyFib_holds_iff`: the successor de-folded carrier's `.holds` at the fixed anchor pair
    `(x, t)` is the gate conjunct ∧ the `S_L`/`S_R` permutation-arrangement disjunction. Unlike the
    frozen version, the fold bit is the NON-PROJECTING `igFoldBitFib` (full arity-4 fiber, no
    `nfkProjFresh` collapse — the F1 channel M2 preserves). This is the de-folded structural entry
    point for Phase 3 (render-free extraction) and Phases 4-5. -/
theorem bracketEndChar_kvFib_succ_holds_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndCharKvFib atomMap h_surj charFib (k + 1) qnf).holds M atomMap x t ↔
      igGateFib (∀ sub : NormalForm sig k 4,
          nf0DropFresh (NormalForm.atomAssgn sub) ≠ qnf.1 → qnf.2 sub = false)
          (igFoldBitFib qnf) ∧
      ∃ lL ∈ (igSLFib (igFoldBitFib qnf)).permutations,
        ∃ lR ∈ (igSRFib (igFoldBitFib qnf)).permutations,
        (igMkDisjunctFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf) lL lR).2.holds M atomMap x t := by
  rw [bracketEndChar_kvFib_succ_eq atomMap h_surj charFib qnf]
  exact igBodyFib_holds_iff (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
    (∀ sub : NormalForm sig k 4,
      nf0DropFresh (NormalForm.atomAssgn sub) ≠ qnf.1 → qnf.2 sub = false)
    (igFoldBitFib qnf) M atomMap x t

/-! ## Phase 3 — render-free endpoint→arity-4 realizer extraction (replaces `igFoldBit_realize_iff`)

THE load-bearing decircularizing move of the M2 redesign. The frozen bridge
`igFoldBit_realize_iff` (`:563`) turns fold content into a model realizer but REQUIRES the deep
render `NfEvalNf M (k+1) 3 [w,x,t] qnf` as an explicit hypothesis — the very render this content
is
upstream of (produced at `ExteriorGateAssembleK.lean:337-338`), making the firing route for
`kampPrior_hreal_supply` (`InteriorHrealSupplyK.lean:53-116`) machine-confirmed CIRCULAR.

The de-folded carrier fixes this at the source: unlike the frozen `igFoldBit` (which lossily
`∃`-projects the arity-4 fiber to `(zone, χ:NF k 1)`), the sibling `igFoldBitFib` keeps the WHOLE
`σ:NF k 4` live, and the de-folded endpoint predicates (`igEpRFib`/`igEpLFib`, `:1365`/`:1356`)
carry
the FULL arity-4 characteristic formula `charFib σ` in their per-σ literals. So the σ-realizer is
readable DIRECTLY off the endpoint eval — no render.

The two extraction lemmas below (future@t via `igEpRFib`'s `untl` literal, past@x via `igEpLFib`'s
`snce` literal) take the de-folded endpoint eval and a render-FREE characteristic-soundness seam
`hcharFib` (the arity-4 analog of `interiorGate_hck`/`P.correct`; supplied by the provider `P` at
the
Phase-7 discharge site — it mentions NO `NfEvalNf M _ 3 [...] qnf` render), and produce the
genuine
arity-4 realizer. NO chain step is shortcut (G5): the `untl`/`snce` firing is native temporal
semantics, the fiber content rides the full-arity `charFib σ` literal (G1/N4). -/

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvFib_realize_futT` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **Render-free FUTURE endpoint→arity-4 realizer extraction** (the deliverable;
    de-folded, render-free analog of `igFoldBit_realize_iff`, `:563`). From the de-folded RIGHT
    endpoint eval at `t` (`igEpRFib`) and a marked σ in the future-of-`t` zone (`b igZFutT σ =
    true`),
    reads the realizer `∃ x1 > t, NfEvalNf M k 4 [x1,w,x,t] σ` DIRECTLY: the endpoint literal
    `Formula.untl (charFib σ) ⊤` fires a future point where the arity-4 characteristic formula
    holds,
    and the render-FREE soundness seam `hcharFib` turns that into the genuine realizer. The
    signature
    contains NO deep render `NfEvalNf M _ 3 [...] qnf` hypothesis — this is the decircularizing
    edit
    (cf. the circular route diagnosed at `InteriorHrealSupplyK.lean:88-107`). -/
theorem bracketEndChar_kvFib_realize_futT {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    -- ZONE-GUARDED render-free soundness seam: the marked-fiber
    -- guard `qnf.2 τ = true` and the `zoneHolds` guard block the cross-anchor-context transport
    -- refuted for the old unguarded `hcharFib`.
    (hcharFibSound : ∀ (τ : NormalForm sig k 4), qnf.2 τ = true →
      ∀ (x1 : M.carrier),
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
          (nf0ZoneSpec (NormalForm.atomAssgn τ)) x1 →
        TemporalTruth M atomMap x1 (charFib τ) →
        NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (σ : NormalForm sig k 4) (hz : igFoldBitFib qnf igZFutT σ = true)
    (hepR : (igEpRFib charBase charFib qnf.1 (igFoldBitFib qnf)).EvalAt M atomMap t) :
    ∃ x1 : M.carrier, t < x1 ∧
      NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  -- Enter the right-endpoint conjunction: every literal holds at `t`.
  simp only [igEpRFib, TemporalPred.EvalAt] at hepR
  rw [formula_conjList_iff] at hepR
  -- The futT literal for our marked σ is `untl (charFib σ) ⊤` (in the RIGHT `++` block).
  have hlit : TemporalTruth M atomMap t (Formula.untl (charFib σ) Formula.top) := by
    apply hepR
    apply List.mem_append_right
    refine List.mem_map.mpr ⟨σ, by simp [igAllSubs], ?_⟩
    simp only [igLit, hz, if_true]
  -- Fire the `until`: a future `x1 > t` where the arity-4 characteristic formula holds.
  simp only [TemporalTruth] at hlit
  obtain ⟨x1, htx1, hgoal, -⟩ := hlit
  -- Decode the fold bit: σ is marked and its declared zone is igZFutT.
  have hdec : qnf.2 σ = true ∧ nf0ZoneSpec (NormalForm.atomAssgn σ) = igZFutT := by
    simpa only [igFoldBitFib, decide_eq_true_eq] using hz
  -- The zone witness: `t < x1` with `x < w < t` realizes igZFutT structurally.
  have hwx1 : w < x1 := hwt.trans htx1
  have hxx1 : x < x1 := hxw.trans hwx1
  have hzh : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
      (nf0ZoneSpec (NormalForm.atomAssgn σ)) x1 := by
    rw [hdec.2, show igZFutT = Fin.cons (false, true) (Fin.cons (false, true)
        (fun _ => (false, true))) from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwx1) (by simp), iff_of_true hwx1 rfl⟩,
      ⟨iff_of_false (lt_asymm hxx1) (by simp), iff_of_true hxx1 rfl⟩,
      ⟨iff_of_false (lt_asymm htx1) (by simp), iff_of_true htx1 rfl⟩⟩
  exact ⟨x1, htx1, hcharFibSound σ hdec.1 x1 hzh hgoal⟩

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvFib_realize_pastX` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **Render-free PAST endpoint→arity-4 realizer extraction**.
    From the de-folded LEFT endpoint eval at `x` (`igEpLFib`) and a marked σ in the past-of-`x` zone
    (`b igZPastX σ = true`), reads the realizer `∃ x1 < x, NfEvalNf M k 4 [x1,w,x,t] σ` off the
    endpoint literal `Formula.snce (charFib σ) ⊤`. Render-free (same `hcharFib` seam). Symmetric to
    `bracketEndChar_kvFib_realize_futT`; supplies the past arm of the Phase-7 discharge. -/
theorem bracketEndChar_kvFib_realize_pastX {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    -- ZONE-GUARDED render-free soundness seam.
    (hcharFibSound : ∀ (τ : NormalForm sig k 4), qnf.2 τ = true →
      ∀ (x1 : M.carrier),
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
          (nf0ZoneSpec (NormalForm.atomAssgn τ)) x1 →
        TemporalTruth M atomMap x1 (charFib τ) →
        NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (σ : NormalForm sig k 4) (hz : igFoldBitFib qnf igZPastX σ = true)
    (hepL : (igEpLFib charBase charFib qnf.1 (igFoldBitFib qnf)).EvalAt M atomMap x) :
    ∃ x1 : M.carrier, x1 < x ∧
      NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  simp only [igEpLFib, TemporalPred.EvalAt] at hepL
  rw [formula_conjList_iff] at hepL
  -- The pastX literal for our marked σ is `snce (charFib σ) ⊤` (in the LEFT `++` block, first map).
  have hlit : TemporalTruth M atomMap x (Formula.snce (charFib σ) Formula.top) := by
    apply hepL
    apply List.mem_append_left
    apply List.mem_cons_of_mem
    refine List.mem_map.mpr ⟨σ, by simp [igAllSubs], ?_⟩
    simp only [igLit, hz, if_true]
  simp only [TemporalTruth] at hlit
  obtain ⟨x1, hx1x, hgoal, -⟩ := hlit
  -- Decode the fold bit: σ is marked and its declared zone is igZPastX.
  have hdec : qnf.2 σ = true ∧ nf0ZoneSpec (NormalForm.atomAssgn σ) = igZPastX := by
    simpa only [igFoldBitFib, decide_eq_true_eq] using hz
  -- The zone witness: `x1 < x` with `x < w < t` realizes igZPastX structurally.
  have hx1w : x1 < w := hx1x.trans hxw
  have hx1t : x1 < t := hx1w.trans hwt
  have hzh : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
      (nf0ZoneSpec (NormalForm.atomAssgn σ)) x1 := by
    rw [hdec.2, show igZPastX = Fin.cons (true, false) (Fin.cons (true, false)
        (fun _ => (true, false))) from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hx1w rfl, iff_of_false (lt_asymm hx1w) (by simp)⟩,
      ⟨iff_of_true hx1x rfl, iff_of_false (lt_asymm hx1x) (by simp)⟩,
      ⟨iff_of_true hx1t rfl, iff_of_false (lt_asymm hx1t) (by simp)⟩⟩
  exact ⟨x1, hx1x, hcharFibSound σ hdec.1 x1 hzh hgoal⟩

/-! ## Phase 4 — de-folded ⇐ completeness (realizer → sibling carrier holds)

The de-folded analog of `bracketEndChar_kv_step_complete` (`:693`), re-keyed from
the arity-1 1-type `χ : NormalForm sig k 1` onto the FULL arity-4 fiber `σ : NormalForm sig k 4`.
Given a genuine depth-`(k+1)` realizer at bracket witness `w`, the SIBLING de-folded carrier
`bracketEndCharKvFib`'s `.holds` at the fixed endpoints `(x, t)`.

Two structural differences from the folded original, both consequences of the non-projecting fold:

1. **Fold biconditional is render-native, not projection-mediated.** The de-folded fold bit
   `igFoldBitFib qnf zs σ = decide (qnf.2 σ = true ∧ nf0ZoneSpec (atomAssgn σ) = zs)` reads the
   WHOLE fiber σ, so the fold-realization biconditional `igFoldBitFib qnf zs σ = true ↔ ∃ u,
   zoneHolds M [w,x,t] zs u ∧ NfEvalNf M k 4 [u,w,x,t] σ` is proved DIRECTLY off the render's
   per-sub conjunct `(hw.2 σ)` — NO `nfkProjFresh`/`nfCharacteristic`/`nf_eval_unique` roundtrip
   (the frozen `igFoldBit_realize_iff`, `:563`, needs all three because it must rebuild the dropped
   fiber). This is the F1 channel M2 preserves, here in completeness form.
2. **Interior point-type seam is arity-4 and w-gated.** The interior char bridge `hcharFib` relates
   `TemporalTruth M atomMap u (charFib k σ) ↔ NfEvalNf M k 4 [u,w,x,t] σ` — an arity-4 seam that,
   unlike the folded arity-1 `interiorGate_hck`, depends on the bracket witness `w`; it is supplied
   as a hypothesis GATED on the render (only asserted at `w`'s that realize `qnf`, where `charFib`
   is meaningful). The base endpoint seam stays the depth-0 `interiorGate_hcb`.

No chain step is shortcut (G5); the fold rides the full arity-4 fiber throughout (F1/N4). -/

set_option maxHeartbeats 1600000 in
-- `igk_sorted_realization_fib` elaborates the general-`k` interior gate composition together
-- with its full provider inventory in a single declaration; the default 200000-heartbeat budget
-- is not enough to typecheck it.
/-- **Depth-`k` arity-4 arrangement selection** (arity-4 analog of
    `igk_sorted_realization`, `:637`). Every list of complete depth-`k` arity-4 fibers each realized
    somewhere strictly inside `(a, b)` over the fixed frame `[·,w,x,t]` admits a simultaneous
    arrangement — a permutation tagged with realizing points in strictly increasing model order.
    Distinctness is automatic: distinct complete arity-4 fibers exclude each other at any single
    frame point (`nf_eval_unique M k 4`). Same insertion induction as the arity-1 original. -/
theorem igk_sorted_realization_fib {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (a b : M.carrier)
    (S : List (NormalForm sig k 4)) (hnd : S.Nodup)
    (hreal : ∀ σ ∈ S, ∃ u, a < u ∧ u < b ∧
      NfEvalNf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∃ ps : List (NormalForm sig k 4 × M.carrier),
      List.Perm (ps.map Prod.fst) S ∧
      (ps.map Prod.snd).Pairwise (· < ·) ∧
      ∀ p ∈ ps, (a < p.2 ∧ p.2 < b) ∧
        NfEvalNf M k 4 (Fin.cons p.2 (Fin.cons w (Fin.cons x (fun _ => t)))) p.1 := by
  induction S with
  | nil => exact ⟨[], by simp, by simp, by simp⟩
  | cons σ S' ih =>
    obtain ⟨u, hau, hub, huσ⟩ := hreal σ List.mem_cons_self
    obtain ⟨ps', hperm', hsort', hprops'⟩ :=
      ih (List.nodup_cons.mp hnd).2 (fun σ' h' => hreal σ' (List.mem_cons_of_mem _ h'))
    have hne : ∀ p ∈ ps', p.2 ≠ u := by
      intro p hp heq
      have hev : NfEvalNf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) p.1 :=
        heq ▸ (hprops' p hp).2
      have hpq : p.1 = σ := nf_eval_unique M k 4 _ p.1 σ hev huσ
      have : σ ∈ S' := hperm'.mem_iff.mp (hpq ▸ List.mem_map_of_mem hp)
      exact (List.nodup_cons.mp hnd).1 this
    obtain ⟨qs, hqperm, hqsort⟩ := k1v_sorted_insert M (σ, u) ps' hsort' hne
    refine ⟨qs, ?_, hqsort, ?_⟩
    · have h1 : List.Perm (qs.map Prod.fst) (((σ, u) :: ps').map Prod.fst) := hqperm.map _
      rw [List.map_cons] at h1
      exact h1.trans (hperm'.cons σ)
    · intro p hp
      rcases List.mem_cons.mp (hqperm.mem_iff.mp hp) with rfl | hp'
      · exact ⟨⟨hau, hub⟩, huσ⟩
      · exact hprops' p hp'

/-- **De-folded gate holder** (arity-4 analog of `bracketEndChar_kv_step_gate`,
    `:510`). From a genuine realizer at bracket witness `w`, the sibling carrier's gate holds: the
    off-fiber conjunct via `nf_eval_nfk_iff_efold`; the seven-zone conjunct routes each marked fiber
    `σ` through its atom-layer zone via `nf_eval_nf_atom_layer` + `igZone3_consistent`. Simpler than
    the folded gate: `igFoldBitFib` carries `nf0ZoneSpec (atomAssgn σ) = zs` directly, so no
    `igFoldBit_iff`/`nfkProjFresh` destructuring. -/
theorem bracketEndChar_kvFib_step_gate {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    igGateFib (∀ sub : NormalForm sig k 4,
        nf0DropFresh (NormalForm.atomAssgn sub) ≠ qnf.1 → qnf.2 sub = false)
      (igFoldBitFib qnf) := by
  refine ⟨((nf_eval_nfk_iff_efold M _ qnf).mp h).2, ?_⟩
  intro zs σ hncons
  cases hbit : igFoldBitFib qnf zs σ with
  | false => rfl
  | true =>
    have hdec : qnf.2 σ = true ∧ nf0ZoneSpec (NormalForm.atomAssgn σ) = zs := by
      simpa only [igFoldBitFib, decide_eq_true_eq] using hbit
    obtain ⟨hmark, hzone⟩ := hdec
    obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hmark
    have hatom := nf_eval_nf_atom_layer M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ hx1
    have hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
        (nf0ZoneSpec (NormalForm.atomAssgn σ)) x1 := by
      intro i
      refine ⟨?_, ?_⟩
      · have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1
        exact h1
      · have h1 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1
        exact h1
    rw [hzone] at hz
    exact absurd (igZone3_consistent M w x t x1 hxw hwt zs hz) hncons

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvFib_step_complete` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **De-folded inductive step ⇐ completeness** (the deliverable; arity-4 analog
    of `bracketEndChar_kv_step_complete`, `:693`). From the arity-3 realizer at bracket witness `w`,
    the SIBLING de-folded carrier `bracketEndCharKvFib`'s `.holds` at `(x, t)`, via
    `bracketEndChar_kvFib_succ_holds_iff`'s RHS: the de-folded gate
    (`bracketEndChar_kvFib_step_gate`)
    plus ONE sorted `S_L`/`S_R` arrangement whose `igMkDisjunctFib` bracket holds. The interior
    fiber
    types realize via the render-gated arity-4 seam `hcharFib`; the fold-realization biconditional
    is
    read DIRECTLY off the render (non-projecting fiber, F1 channel preserved). -/
theorem bracketEndChar_kvFib_step_complete {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (hcharFib : ∀ (w : M.carrier),
      NfEvalNf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig k 4) (u : M.carrier),
        TemporalTruth M atomMap u (charFib k σ) ↔
          NfEvalNf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (∃ w : M.carrier, NfEvalNf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) →
      (bracketEndCharKvFib atomMap h_surj charFib (k + 1) qnf).holds M atomMap x t := by
  rintro ⟨w, hw⟩
  -- Atom layer + bracket order facts.
  have h_atom : NfEvalNf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
    nf_eval_nf_atom_layer M _ qnf hw
  have hxw : x < w := by
    have h1 := h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [AtomEval, Fin.cons] at h1
    exact h1.mpr h_xy
  have hwt : w < t := by
    have h1 := h_atom (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    simp only [AtomEval, Fin.cons] at h1
    exact h1.mpr h_yt
  have hxt : x < t := hxw.trans hwt
  -- Interior arity-4 seam (render-gated) and depth-0 base seam.
  have hchar := hcharFib w hw
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (nfDepth0CharFormula atomMap h_surj χ) ↔
        NfEvalNf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  -- Endpoint/witness arity-1 base evaluations (fixed points, reused arity-3 extractors).
  have h_y_nf := k1v_extract_y_nf M qnf.1 w x t h_atom
  have h_x_nf := k1v_extract_x_nf3 M qnf.1 w x t h_atom
  have h_t_nf := k1v_extract_t_nf3 M qnf.1 w x t h_atom
  -- Fold-realization biconditional (fiber bit ↔ interval witness), read DIRECTLY off the render.
  have hz' : ∀ (zs : ZoneSpec 3) (σ : NormalForm sig k 4),
      igFoldBitFib qnf zs σ = true ↔
        ∃ u : M.carrier, zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u ∧
          NfEvalNf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
    intro zs σ
    constructor
    · intro hbit
      have hdec : qnf.2 σ = true ∧ nf0ZoneSpec (NormalForm.atomAssgn σ) = zs := by
        simpa only [igFoldBitFib, decide_eq_true_eq] using hbit
      obtain ⟨hmark, hzone⟩ := hdec
      obtain ⟨x1, hx1⟩ := (hw.2 σ).mpr hmark
      have hatom := nf_eval_nf_atom_layer M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
          hx1
      refine ⟨x1, ?_, hx1⟩
      intro i
      refine ⟨?_, ?_⟩
      · have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1
        rw [← hzone]; exact h1
      · have h1 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1
        rw [← hzone]; exact h1
    · rintro ⟨u, hu, hev⟩
      have hmark : qnf.2 σ = true := (hw.2 σ).mp ⟨u, hev⟩
      have hatom := nf_eval_nf_atom_layer M (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ
          hev
      have hzone : nf0ZoneSpec (NormalForm.atomAssgn σ) = zs := by
        funext i
        have h0 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        have h1 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h0 h1
        have hb0 : (NormalForm.atomAssgn σ) (.order 0 i.succ (Fin.succ_ne_zero i).symm)
            = (zs i).1 := by
          rw [Bool.eq_iff_iff]; exact h0.symm.trans (hu i).1
        have hb1 : (NormalForm.atomAssgn σ) (.order i.succ 0 (Fin.succ_ne_zero i))
            = (zs i).2 := by
          rw [Bool.eq_iff_iff]; exact h1.symm.trans (hu i).2
        exact Prod.ext hb0 hb1
      simp only [igFoldBitFib, decide_eq_true_eq]
      exact ⟨hmark, hzone⟩
  -- Zone-membership constructors at the seven consistent zones (identical to the folded original).
  have hzPastX : ∀ u, u < x → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      igZPastX u := by
    intro u hux
    have huw : u < w := hux.trans hxw
    have hut : u < t := huw.trans hwt
    rw [show igZPastX = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (by simp)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtX : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZAtX x := by
    rw [show igZAtX = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by simp)⟩,
      ⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
      ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
  have hzXW : ∀ u, x < u → u < w →
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZXW u := by
    intro u hxu huw
    have hut : u < t := huw.trans hwt
    rw [show igZXW = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtW : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZAtW w := by
    rw [show igZAtW = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_irrefl w) (by simp), iff_of_false (lt_irrefl w) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxw) (by simp), iff_of_true hxw rfl⟩,
      ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by simp)⟩⟩
  have hzWT : ∀ u, w < u → u < t →
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZWT u := by
    intro u hwu hut
    have hxu : x < u := hxw.trans hwu
    rw [show igZWT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtT : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZAtT t := by
    rw [show igZAtT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwt) (by simp), iff_of_true hwt rfl⟩,
      ⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
      ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
  have hzFutT : ∀ u, t < u →
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZFutT u := by
    intro u htu
    have hwu : w < u := hwt.trans htu
    have hxu : x < u := hxw.trans hwu
    rw [show igZFutT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
  -- Interior-positive realization: each positive interior fold bit yields an interval witness.
  have hLreal : ∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZXW σ = true →
      ∃ u, x < u ∧ u < w ∧ NfEvalNf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t))))
          σ := by
    intro σ hbit
    obtain ⟨u, hzu, hev⟩ := (hz' igZXW σ).mp hbit
    rw [show igZXW = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.2.1.2.mpr rfl, hzu.1.1.mpr rfl, hev⟩
  have hRreal : ∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZWT σ = true →
      ∃ u, w < u ∧ u < t ∧ NfEvalNf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t))))
          σ := by
    intro σ hbit
    obtain ⟨u, hzu, hev⟩ := (hz' igZWT σ).mp hbit
    rw [show igZWT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.1.2.mpr rfl, hzu.2.2.1.mpr rfl, hev⟩
  -- Segment exclusions on ALL of `(x, w)` / `(w, t)`.
  have hsegL_all : ∀ u, x < u → u < w →
      (igSegLFib (charFib k) (igFoldBitFib qnf)).EvalAt M atomMap u := by
    intro u hxu huw
    simp only [igSegLFib, TemporalPred.EvalAt]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : igFoldBitFib qnf igZXW σ with
    | true => rw [if_pos rfl]; exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp)]
      intro hch
      have hbit := (hz' igZXW σ).mpr ⟨u, hzXW u hxu huw, (hchar σ u).mp hch⟩
      rw [hb] at hbit; exact Bool.noConfusion hbit
  have hsegR_all : ∀ u, w < u → u < t →
      (igSegRFib (charFib k) (igFoldBitFib qnf)).EvalAt M atomMap u := by
    intro u hwu hut
    simp only [igSegRFib, TemporalPred.EvalAt]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : igFoldBitFib qnf igZWT σ with
    | true => rw [if_pos rfl]; exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp)]
      intro hch
      have hbit := (hz' igZWT σ).mpr ⟨u, hzWT u hwu hut, (hchar σ u).mp hch⟩
      rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED left endpoint `x` (exterior Since literals, zPastX/zAtX).
  have hepL : (igEpLFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
      (igFoldBitFib qnf)).EvalAt M atomMap x := by
    simp only [igEpLFib, igLit, TemporalPred.EvalAt]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hcharB _ x).mpr h_x_nf
      · obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : igFoldBitFib qnf igZPastX σ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hz' igZPastX σ).mp hb
          rw [show igZPastX = Fin.cons (true, false)
              (Fin.cons (true, false) (fun _ => (true, false)))
              from rfl, k1v_zoneHolds_cons_iff] at hzu
          exact ⟨u, hzu.2.1.1.mpr rfl, (hchar σ u).mpr hev, fun r _ _ hfa => hfa⟩
        | false =>
          rw [if_neg (by simp)]
          rintro ⟨s, hsx, hsσ, -⟩
          have hbit := (hz' igZPastX σ).mpr ⟨s, hzPastX s hsx, (hchar σ s).mp hsσ⟩
          rw [hb] at hbit; exact Bool.noConfusion hbit
    · obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBitFib qnf igZAtX σ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZAtX σ).mp hb
        rw [show igZAtX = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = x := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.1))
        exact (hchar σ x).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hz' igZAtX σ).mpr ⟨x, hzAtX, (hchar σ x).mp hch⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED right endpoint `t` (exterior Until literals, zAtT/zFutT).
  have hepR : (igEpRFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
      (igFoldBitFib qnf)).EvalAt M atomMap t := by
    simp only [igEpRFib, igLit, TemporalPred.EvalAt]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hcharB _ t).mpr h_t_nf
      · obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : igFoldBitFib qnf igZAtT σ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hz' igZAtT σ).mp hb
          rw [show igZAtT = Fin.cons (false, true)
              (Fin.cons (false, true) (fun _ => (false, false)))
              from rfl, k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = t := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.1))
          exact (hchar σ t).mpr (hueq ▸ hev)
        | false =>
          rw [if_neg (by simp)]
          intro hch
          have hbit := (hz' igZAtT σ).mpr ⟨t, hzAtT, (hchar σ t).mp hch⟩
          rw [hb] at hbit; exact Bool.noConfusion hbit
    · obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBitFib qnf igZFutT σ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZFutT σ).mp hb
        rw [show igZFutT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        exact ⟨u, hzu.2.2.2.mpr rfl, (hchar σ u).mpr hev, fun r _ _ hfa => hfa⟩
      | false =>
        rw [if_neg (by simp)]
        rintro ⟨s, hts, hsσ, -⟩
        have hbit := (hz' igZFutT σ).mpr ⟨s, hzFutT s hts, (hchar σ s).mp hsσ⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Witness point type at `w` (complete type + equality-zone literals ONLY, rule N4).
  have hptW : (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
      (igFoldBitFib qnf)).EvalAt M atomMap w := by
    simp only [igPtWFib, igLit, TemporalPred.EvalAt]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_cons.mp hf with rfl | hf
    · exact (hcharB _ w).mpr h_y_nf
    · obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBitFib qnf igZAtW σ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZAtW σ).mp hb
        rw [show igZAtW = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = w := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
        exact (hchar σ w).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hz' igZAtW σ).mpr ⟨w, hzAtW, (hchar σ w).mp hch⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Sorted arrangements of the interior-positive enumerations.
  obtain ⟨psL, hpermL, hsortL, hpropsL⟩ :=
    igk_sorted_realization_fib M w x t x w (igSLFib (igFoldBitFib qnf))
      ((Finset.nodup_toList _).filter _)
      (fun σ hσ => hLreal σ (by simpa only [igSLFib, igAllSubs, decide_eq_true_eq]
        using (List.mem_filter.mp hσ).2))
  obtain ⟨psR, hpermR, hsortR, hpropsR⟩ :=
    igk_sorted_realization_fib M w x t w t (igSRFib (igFoldBitFib qnf))
      ((Finset.nodup_toList _).filter _)
      (fun σ hσ => hRreal σ (by simpa only [igSRFib, igAllSubs, decide_eq_true_eq]
        using (List.mem_filter.mp hσ).2))
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
  -- Enter the sibling carrier via the Phase-2 destructuring; gate + the (psL, psR) arrangement.
  rw [bracketEndChar_kvFib_succ_holds_iff atomMap h_surj charFib qnf M x t]
  refine ⟨bracketEndChar_kvFib_step_gate qnf M w x t hxw hwt hw,
    psL.map Prod.fst, List.mem_permutations.mpr hpermL,
    psR.map Prod.fst, List.mem_permutations.mpr hpermR, hepL, hepR, ?_⟩
  -- The bracket: assembled by the reused construction lemma from the sorted realizations.
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
    have h1 : (List.map (igCharPFib (charFib k)) (psL.map Prod.fst))[i]'hi =
        igCharPFib (charFib k) ((psL[i]'hi').1) := by simp only [List.getElem_map]
    have h2 : (psL.map Prod.snd)[i]'(by simpa using hi') = (psL[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    simp only [igCharPFib, TemporalPred.EvalAt]
    exact (hchar _ _).mpr (hpropsL _ (List.getElem_mem _)).2
  · intro i hi
    have hi' : i < psR.length := by simpa using hi
    have h1 : (List.map (igCharPFib (charFib k)) (psR.map Prod.fst))[i]'hi =
        igCharPFib (charFib k) ((psR[i]'hi').1) := by simp only [List.getElem_map]
    have h2 : (psR.map Prod.snd)[i]'(by simpa using hi') = (psR[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    simp only [igCharPFib, TemporalPred.EvalAt]
    exact (hchar _ _).mpr (hpropsR _ (List.getElem_mem _)).2

/-! ## Phase 5 — de-folded step_sound analog + re-keyed binders

The de-folded analog of `bracketEndChar_kv_step_sound` (`:1043`), re-keyed from the
arity-1 1-type `χ : NormalForm sig k 1` onto the FULL arity-4 fiber `σ : NormalForm sig k 4`. From
the
SIBLING de-folded carrier `bracketEndCharKvFib`'s `.holds` at the fixed endpoints `(x, t)`, a
genuine
depth-`(k+1)` realizer at bracket witness `w`.

The soundness body is byte-parallel to the folded original — the fiber-realization biconditional it
produces is about the TARGET `qnf` (arity-3), so the `refine ⟨w, h_atom, ?_⟩ / intro sub /
constructor`
core is IDENTICAL. Two things change, both purely the sibling re-key:

1. **Carrier entry.** Destructuring goes through `bracketEndChar_kvFib_succ_holds_iff` (`:1515`)
and the
   `igMkDisjunctFib`/`igEpLFib`/`igEpRFib`/`igPtWFib` de-folded pieces; the generic bracket
   extractor
   `k1v_bracket_extract` is reused verbatim (it is abstract in `lL lR ptW segL segR`).
2. **Re-keyed provider binders.** The `hreal`/`hexcl`/`hexclExt` obligation binders are gated on
   `igPtWFib (…) (charFib k) qnf.1 (igFoldBitFib qnf)` at `w` (the extracted `hptWe`), the arity-4
   analog of the folded `igPtW (…) (charF k) qnf.1 (igFoldBit qnf)` gate. The realizer/exclusion
   payloads (`∃ x1, NfEvalNf M k 4 [x1,w,x,t] σ` and its negation) are the SAME arity-4
   statements the
   folded binders already carried — the fold was never the loss point for the binders; only the gate
   they hang off is re-keyed to the non-projecting fiber. No chain step is shortcut (G5). -/

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvFib_step_sound` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **De-folded inductive step ⇒ soundness** (the deliverable; arity-4 analog of
    `bracketEndChar_kv_step_sound`, `:1043`). From the SIBLING de-folded carrier
    `bracketEndCharKvFib`'s `.holds` at `(x, t)`, a genuine depth-`(k+1)` realizer at a bracket
    witness `w`. The `hreal`/`hexcl`/`hexclExt` provider binders are re-keyed onto the
    non-projecting
    fiber gate `igPtWFib (…) (charFib k) qnf.1 (igFoldBitFib qnf)`; the fiber-realization
    biconditional
    on the target `qnf` is proved identically to the folded original. -/
theorem bracketEndChar_kvFib_step_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    -- Render-free char-soundness seam (by-design, `w`-universal; the arity-4 analog of the folded
    -- `P`/`hcharK`, threaded like `hreal`). Supplies the `hreal` obligation's per-`w` char seam.
    (hcharFibSoundP : ∀ (w : M.carrier) (τ : NormalForm sig k 4) (x1 : M.carrier),
      TemporalTruth M atomMap x1 (charFib k τ) →
      NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      (igEpLFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap x →
      (igEpRFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap t →
      (∀ (τ : NormalForm sig k 4) (x1 : M.carrier),
        TemporalTruth M atomMap x1 (charFib k τ) →
        NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) →
      (∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZPastX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZXW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZWT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZFutT) →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvFib atomMap h_surj charFib (k + 1) qnf).holds M atomMap x t →
      ∃ w : M.carrier, NfEvalNf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  intro h_holds
  -- Enter the sibling carrier via the Phase-2 destructuring: gate + one arrangement disjunct.
  rw [bracketEndChar_kvFib_succ_holds_iff atomMap h_surj charFib qnf M x t] at h_holds
  obtain ⟨hgate, lL, hlL, lR, hlR, hveah⟩ := h_holds
  obtain ⟨hepL, hepR, hbr⟩ := hveah
  -- Extract the bracket witness `w` (`x < w < t`), its `igPtWFib` eval, and the interior
  -- `S_L`/`S_R`
  -- realizers (KEPT, not dropped — they supply the `igZXW`/`igZWT` interior seams `hIntL`/`hIntR`).
  obtain ⟨w, hxw, hwt, hptWe, hlLreal, hlRreal, -, -⟩ :=
    k1v_bracket_extract M atomMap _ _ _ _ _ x t hbr
  have hxt : x < t := hxw.trans hwt
  -- Depth-0 endpoint/witness char bridge (arity-1, reused verbatim from the folded original).
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (nfDepth0CharFormula atomMap h_surj χ) ↔
        NfEvalNf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  -- Endpoint/witness complete types (heads of the de-folded conjunction lists). `hptWe` is kept RAW
  -- for the provider obligations; the witness head is read off a copy.
  have hxT : TemporalTruth M atomMap x
      (nfDepth0CharFormula atomMap h_surj (nfXProj3 qnf.1)) := by
    have h := hepL
    simp only [igMkDisjunctFib, igEpLFib, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have htT : TemporalTruth M atomMap t
      (nfDepth0CharFormula atomMap h_surj (nfTProj3 qnf.1)) := by
    have h := hepR
    simp only [igMkDisjunctFib, igEpRFib, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have hyW : TemporalTruth M atomMap w
      (nfDepth0CharFormula atomMap h_surj (nfYProj qnf.1)) := by
    have h := hptWe
    simp only [igPtWFib, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ List.mem_cons_self
  -- Reconstruct the depth-0 atom layer at `[w, x, t]` (Chain step 2, rule N1 framing).
  have h_atom : NfEvalNf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
    k1v_reconstruct_nf3 M qnf.1 w x t
      ((hcharB _ w).mp hyW) ((hcharB _ x).mp hxT) ((hcharB _ t).mp htT)
      (iff_of_false (lt_asymm hxw) (by simp only [h_yx]; decide))
      (iff_of_true hwt h_yt)
      (iff_of_true hxw h_xy)
      (iff_of_true hxt h_xt)
      (iff_of_false (lt_asymm hwt) (by simp only [h_ty]; decide))
      (iff_of_false (lt_asymm hxt) (by simp only [h_tx]; decide))
  -- Assemble the realizer: atom layer + the per-sub fiber biconditional (about the target `qnf`).
  refine ⟨w, h_atom, ?_⟩
  intro sub
  constructor
  · -- realizable → marked: an unmarked sub is realized at NO point (cone `hexcl` ∪ exterior
    -- `hexclExt` cover every `x1`), contradicting the given realizer.
    rintro ⟨x1, hx1⟩
    by_contra hne
    have hf : qnf.2 sub = false := by
      cases hb : qnf.2 sub with
      | true => exact absurd hb hne
      | false => rfl
    by_cases hcone : x ≤ x1 ∧ x1 ≤ t
    · exact hexcl w hxw hwt hptWe sub hf x1 hcone.1 hcone.2 hx1
    · exact hexclExt w hxw hwt hptWe sub hf x1 hcone hx1
  · -- marked → realizable: the de-folded `hreal` now receives the endpoint evals, the render-free
    -- char seam (`hcharFibSoundP w`), the two interior bracket realizer seams (`hIntL`/`hIntR`,
    -- read
    -- off `S_L`/`S_R`), and the zone-consistency seam (`hzcons`, from the gate) — all in scope here
    -- from the carrier's `.holds`.
    intro hmark
    have hIntL : ∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
      intro σ' hbit
      have hσmem : σ' ∈ igSLFib (igFoldBitFib qnf) := by
        simp only [igSLFib, igAllSubs, List.mem_filter]
        exact ⟨Finset.mem_toList.mpr (Finset.mem_univ σ'), hbit⟩
      have hσlL : σ' ∈ lL := (List.mem_permutations.mp hlL).mem_iff.mpr hσmem
      obtain ⟨u, hxu, huw, hpu⟩ := hlLreal (igCharPFib (charFib k) σ') (List.mem_map_of_mem hσlL)
      have htt : TemporalTruth M atomMap u (charFib k σ') := by
        simpa only [igCharPFib, TemporalPred.EvalAt] using hpu
      exact ⟨u, hxu, huw, hcharFibSoundP w σ' u htt⟩
    have hIntR : ∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
      intro σ' hbit
      have hσmem : σ' ∈ igSRFib (igFoldBitFib qnf) := by
        simp only [igSRFib, igAllSubs, List.mem_filter]
        exact ⟨Finset.mem_toList.mpr (Finset.mem_univ σ'), hbit⟩
      have hσlR : σ' ∈ lR := (List.mem_permutations.mp hlR).mem_iff.mpr hσmem
      obtain ⟨u, hwu, hut, hpu⟩ := hlRreal (igCharPFib (charFib k) σ') (List.mem_map_of_mem hσlR)
      have htt : TemporalTruth M atomMap u (charFib k σ') := by
        simpa only [igCharPFib, TemporalPred.EvalAt] using hpu
      exact ⟨u, hwu, hut, hcharFibSoundP w σ' u htt⟩
    have hzcons : ∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZPastX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZXW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZWT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZFutT := by
      intro σ' hm
      by_contra hcon
      obtain ⟨-, hgate2⟩ := hgate
      have hfalse := hgate2 (nf0ZoneSpec (NormalForm.atomAssgn σ')) σ' hcon
      have htrue : igFoldBitFib qnf (nf0ZoneSpec (NormalForm.atomAssgn σ')) σ' = true := by
        simp only [igFoldBitFib, decide_eq_true_eq]; exact ⟨hm, trivial⟩
      rw [htrue] at hfalse
      exact absurd hfalse (by decide)
    exact hreal w hxw hwt hptWe hepL hepR (hcharFibSoundP w) hIntL hIntR hzcons sub hmark

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvFib_step_correct` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **De-folded k→k+1 step biconditional** (the pairing; arity-4 analog of
    `bracketEndChar_kv_step_correct`, `:1165`). `⟨sound (Phase 5), complete (Phase 4)⟩` at symbolic
    `k+1` for the SIBLING de-folded carrier, carrying the union of both halves' seams: the
    completeness
    half's render-gated arity-4 char seam `hcharFib`, and the soundness half's re-keyed provider
    obligations `hreal`/`hexcl`/`hexclExt` (gated on `igPtWFib`). Unlike the folded
    `bracketEndChar_kv_step_correct`, the completeness half consumes the render-gated `hcharFib`
    seam in
    place of the arity-1 provider bundle `P`/`hcharK` + `h_UZ`/`h_SZ` — there is no arity-4
    `interiorGate_hck`. -/
theorem bracketEndChar_kvFib_step_correct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (hcharFib : ∀ (w : M.carrier),
      NfEvalNf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig k 4) (u : M.carrier),
        TemporalTruth M atomMap u (charFib k σ) ↔
          NfEvalNf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcharFibSoundP : ∀ (w : M.carrier) (τ : NormalForm sig k 4) (x1 : M.carrier),
      TemporalTruth M atomMap x1 (charFib k τ) →
      NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      (igEpLFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap x →
      (igEpRFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap t →
      (∀ (τ : NormalForm sig k 4) (x1 : M.carrier),
        TemporalTruth M atomMap x1 (charFib k τ) →
        NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) →
      (∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZPastX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZXW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZWT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZFutT) →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ NfEvalNf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvFib atomMap h_surj charFib (k + 1) qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  ⟨bracketEndChar_kvFib_step_sound atomMap h_surj charFib qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t hcharFibSoundP hreal hexcl hexclExt,
    bracketEndChar_kvFib_step_complete atomMap h_surj charFib qnf h_xy h_yt M x t hcharFib⟩


/-! ## Block 3 of 4 — origin `NfMultiAnchorBridge/ExteriorGateAssembleK.lean:447-790` (344 lines)
    The `*ExtFib` block. -/

/-! ## De-folded exterior gate (additive siblings)

The frozen exterior carrier `bracketEndCharKvExt` (`:154`) and its correctness
`bracketEndChar_kvExt_correct_prior` (`:229`) are consumed OUT OF SCOPE
(`EndIntervalConsumerK.lean:248`, `kampPrior_site_rungK_gate_match`), so Phase 6 adds SIBLING
`*Fib` analogs routed through the de-folded interior `bracketEndCharKvFib` (Option B; frozen
`bracketEndCharKv` left byte-identical) instead of mutating them. Each analog is a byte-parallel
clone with the four carrier-specific references swapped to their Phase-1..5 de-folded counterparts:
`bracketEndCharKv{,_step_sound,_step_complete,_succ_holds_iff}` → `bracketEndCharKvFib{…}`,
`igPtW`/`igMkDisjunct`/`igEpL`/`igEpR`/`igFoldBit` → `igPtWFib`/`igMkDisjunctFib`/`igEpLFib`/
`igEpRFib`/`igFoldBitFib`, and the arity-1 char provider `charF` → the arity-4 `charFib`. The
arity-1 provider bundle `P`/`hcharK` (+ `h_UZ`/`h_SZ`) that the folded `step_complete` consumed is
replaced by the render-gated arity-4 char seam `hcharFib` (there is no arity-4 `interiorGate_hck`);
it is threaded outward exactly as `hreal`/`hexcl`. The two adjacent exterior brackets
(`kvE_extBracket{Past,Fut}`) are keyed on `σ:NF (k+1) 4` and are carrier-INDEPENDENT, so reused
verbatim. -/

/-- **De-folded enriched composed gate** (additive sibling of
    `bracketEndCharKvExt`, `:154`): the SIBLING de-folded interior carrier
    `bracketEndCharKvFib … (k+2)` enriched with the same two adjacent brackets and the ambient
    guard, via `enrichEndpoints`. -/
noncomputable def bracketEndCharKvExtFib {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (Pbr : ExistProviders sig atomMap k) :
    BracketEndCharCarrierV sig (k + 2) :=
  fun qnf =>
    ((bracketEndCharKvFib atomMap h_surj charFib (k + 2) qnf).enrichEndpoints
      (kvEExtBracketPast Pbr qnf)
      (kvEExtBracketFut Pbr qnf)).enrichEndpoints
      (kvEAmbientGuardForm qnf) Formula.top

/-- **Anchor-semantics bridge for the de-folded enriched gate** (additive sibling of
    `bracketEndChar_kvExt_holds_iff`, `:171`). One-line reuse of `VVecEA2.enrichEndpoints_holds`. -/
theorem bracketEndChar_kvExtFib_holds_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndCharKvExtFib atomMap h_surj charFib Pbr qnf).holds M atomMap x t ↔
      ((bracketEndCharKvFib atomMap h_surj charFib (k + 2) qnf).holds M atomMap x t ∧
       TemporalTruth M atomMap x (kvEExtBracketPast Pbr qnf) ∧
       TemporalTruth M atomMap t (kvEExtBracketFut Pbr qnf) ∧
       kvEAmbientDeepAnchor qnf = true) := by
  change (((bracketEndCharKvFib atomMap h_surj charFib (k + 2) qnf).enrichEndpoints
        (kvEExtBracketPast Pbr qnf) (kvEExtBracketFut Pbr qnf)).enrichEndpoints
        (kvEAmbientGuardForm qnf) Formula.top).holds M atomMap x t ↔ _
  constructor
  · intro h
    obtain ⟨hInner, hg, -⟩ := (VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mp h
    obtain ⟨hbase, hpast, hfut⟩ := (VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mp hInner
    exact ⟨hbase, hpast, hfut, (kvE_ambientGuardForm_truth M atomMap x qnf).mp hg⟩
  · rintro ⟨hbase, hpast, hfut, hguard⟩
    refine (VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mpr
      ⟨(VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t).mpr ⟨hbase, hpast, hfut⟩,
       (kvE_ambientGuardForm_truth M atomMap x qnf).mpr hguard,
       temporal_truth_top M atomMap t⟩

/-- **De-folded gate-level atom-layer pin** (additive sibling of
    `kvExt_gate_henv`, `:61`): derives the depth-0 atom-layer pin `NfEvalNf M 0 3 [w,x,t] qnf.1`
    for the callback's arbitrary interior witness `w` from the SIBLING carrier's `.holds` via
    `bracketEndChar_kvFib_succ_holds_iff` (Phase 2) and the de-folded endpoint/witness predicates.
    Verbatim clone of the Phase-5 `bracketEndChar_kvFib_step_sound` reconstruction block. -/
private theorem kvExtFib_gate_henv {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 2) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (hInt : (bracketEndCharKvFib atomMap h_surj charFib (k + 2) qnf).holds M atomMap x t)
    (w : M.carrier) (hxw : x < w) (hwt : w < t)
    (hptW : (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
      (igFoldBitFib qnf)).EvalAt M atomMap w) :
    NfEvalNf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 := by
  have hxt : x < t := hxw.trans hwt
  rw [bracketEndChar_kvFib_succ_holds_iff atomMap h_surj charFib qnf M x t] at hInt
  obtain ⟨_hgate, lL, _hlL, lR, _hlR, hveah⟩ := hInt
  obtain ⟨hepL, hepR, -⟩ := hveah
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (nfDepth0CharFormula atomMap h_surj χ) ↔
        NfEvalNf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  have hxT : TemporalTruth M atomMap x
      (nfDepth0CharFormula atomMap h_surj (nfXProj3 qnf.1)) := by
    have h := hepL
    simp only [igMkDisjunctFib, igEpLFib, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have htT : TemporalTruth M atomMap t
      (nfDepth0CharFormula atomMap h_surj (nfTProj3 qnf.1)) := by
    have h := hepR
    simp only [igMkDisjunctFib, igEpRFib, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have hyW : TemporalTruth M atomMap w
      (nfDepth0CharFormula atomMap h_surj (nfYProj qnf.1)) := by
    have h := hptW
    simp only [igPtWFib, TemporalPred.EvalAt] at h
    rw [formula_conjList_iff] at h
    exact h _ List.mem_cons_self
  exact k1v_reconstruct_nf3 M qnf.1 w x t
    ((hcharB _ w).mp hyW) ((hcharB _ x).mp hxT) ((hcharB _ t).mp htT)
    (iff_of_false (lt_asymm hxw) (by simp only [h_yx]; decide))
    (iff_of_true hwt h_yt)
    (iff_of_true hxw h_xy)
    (iff_of_true hxt h_xt)
    (iff_of_false (lt_asymm hwt) (by simp only [h_ty]; decide))
    (iff_of_false (lt_asymm hxt) (by simp only [h_tx]; decide))

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvExtFib_correct_prior` is the byte-parallel de-folded clone of the
-- certificate above, routed through the fiber carrier; it needs the same raised budget.
/-- **De-folded enriched gate correctness** (additive sibling of
    `bracketEndChar_kvExt_correct_prior`, `:229`). Byte-parallel clone routed through the SIBLING
    de-folded interior carrier `bracketEndCharKvFib` (via `bracketEndChar_kvFib_step_sound`
    (Phase 5) / `bracketEndChar_kvFib_step_complete` (Phase 4) / `kvExtFib_gate_henv`), with the
    `hreal`/`hexcl`/`hexclSlice*`/`hexclDeep*` provider binders re-keyed onto the non-projecting
    fiber gate `igPtWFib … (charFib (k+1)) qnf.1 (igFoldBitFib qnf)`. The folded arity-1 provider
    bundle `P`/`hcharK` (+ `h_UZ`/`h_SZ`) that the folded `step_complete` consumed is replaced by
    the render-gated arity-4 char seam `hcharFib` threaded outward (there is no arity-4
    `interiorGate_hck`); `h_UZ`/`h_SZ` are retained for the carrier-independent exterior brackets.
    The `hexclExt` residue is discharged internally exactly as the folded original (fiber
    trichotomy + `kvE_extBracket{Past,Fut}_sound`). -/
theorem bracketEndChar_kvExtFib_correct_prior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier)
    (hcharFib : ∀ (w : M.carrier),
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        TemporalTruth M atomMap u (charFib (k + 1) σ) ↔
          NfEvalNf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcharFibSoundP : ∀ (w : M.carrier) (τ : NormalForm sig (k + 1) 4) (x1 : M.carrier),
      TemporalTruth M atomMap x1 (charFib (k + 1) τ) →
      NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (hreal : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      (igEpLFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap x →
      (igEpRFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap t →
      (∀ (τ : NormalForm sig (k + 1) 4) (x1 : M.carrier),
        TemporalTruth M atomMap x1 (charFib (k + 1) τ) →
        NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) →
      (∀ σ : NormalForm sig (k + 1) 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig (k + 1) 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZPastX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZXW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZWT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZFutT) →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- SLICE-KEYED exterior interface: binder types
    -- mirrored verbatim from the folded `bracketEndChar_kvExt_correct_prior`, `igPtW`→`igPtWFib`.
    (hslicePast : ∀ w : M.carrier, x < w → w < t →
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true →
        kvEDeepOnFiber qnf σ = true →
        TemporalTruth M atomMap x (kvEPastPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvEPastAdmissible σ' = true ∧
          kvEPastSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hsliceFut : ∀ w : M.carrier, x < w → w < t →
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true →
        kvEDeepOnFiber qnf σ = true →
        TemporalTruth M atomMap t (kvEFutPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvEFutAdmissible σ' = true ∧
          kvEFutSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hexclSlicePast : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = false →
        kvEPastSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, x1 < x →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclSliceFut : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = false →
        kvEFutSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, t < x1 →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepPast : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = false →
        nfkDropFresh σ = qnf.1 → kvEDeepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, x1 < x →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepFut : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = false →
        nfkDropFresh σ = qnf.1 → kvEDeepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, t < x1 →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvExtFib atomMap h_surj charFib Pbr qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  constructor
  · -- ⇒: destructure the degenerate Lemma 7.6 conjunction, then feed the de-folded soundness half
    -- with `hexclExt` built from the per-side bracket soundness.
    intro hExt
    obtain ⟨hInt, hPastBr, hFutBr, hGuard⟩ :=
      (bracketEndChar_kvExtFib_holds_iff atomMap h_surj charFib Pbr qnf M x t).mp hExt
    refine bracketEndChar_kvFib_step_sound atomMap h_surj charFib qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t hcharFibSoundP (hreal hGuard) (hexcl hGuard) ?_ hInt
    -- The former `hexclExt` obligation, by fiber trichotomy (the fiber re-key, report 04 +
    -- the deep anchor): OFF-fiber σ are unrealizable at the pinned anchors
    -- (fiber-forcing kernel under the gate-derived atom-layer pin `kvExtFib_gate_henv`);
    -- on-fiber GUARD-TRUE slice-UNMARKED σ discharged by the deep-anchored slice-level
    -- D1/D2; on-fiber guard-true bit-false-but-slice-MARKED σ by the carried `hexclSlice*`
    -- residue (VERBATIM Phase-3b binders); on-fiber GUARD-FALSE σ by the carried
    -- `hexclDeep*` residue (deep-anchor rows 12-13 — such σ carry no bracket clause).
    intro w hxw hwt hptW σ hbit x1 hguard hnf
    by_cases hfib : nfkDropFresh σ = qnf.1
    · rcases not_and_or.mp hguard with hx | ht
      · by_cases hdeep : kvEDeepOnFiber qnf σ = true
        · cases hsm : kvEPastSliceMarked qnf σ with
          | false =>
            exact kvE_extBracketPast_sound Pbr M h_UZ h_SZ qnf w x t hxw hwt hPastBr σ hdeep
              hsm x1 (not_le.mp hx) hnf
          | true =>
            have hadm : kvEPastAdmissible σ = true :=
              kvE_pastRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp hx) hnf
            exact hexclSlicePast hGuard w hxw hwt hptW σ hadm hbit hsm x1 (not_le.mp hx) hnf
        · rw [Bool.not_eq_true] at hdeep
          have hadm : kvEPastAdmissible σ = true :=
            kvE_pastRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp hx) hnf
          exact hexclDeepPast hGuard w hxw hwt hptW σ hadm hbit hfib hdeep x1 (not_le.mp hx) hnf
      · by_cases hdeep : kvEDeepOnFiber qnf σ = true
        · cases hsm : kvEFutSliceMarked qnf σ with
          | false =>
            exact kvE_extBracketFut_sound Pbr M h_UZ h_SZ qnf w x t hxw hwt hFutBr σ hdeep
              hsm x1 (not_le.mp ht) hnf
          | true =>
            have hadm : kvEFutAdmissible σ = true :=
              kvE_futRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp ht) hnf
            exact hexclSliceFut hGuard w hxw hwt hptW σ hadm hbit hsm x1 (not_le.mp ht) hnf
        · rw [Bool.not_eq_true] at hdeep
          have hadm : kvEFutAdmissible σ = true :=
            kvE_futRealizer_admissible M σ x1 w x t hxw hwt (not_le.mp ht) hnf
          exact hexclDeepFut hGuard w hxw hwt hptW σ hadm hbit hfib hdeep x1 (not_le.mp ht) hnf
    · -- Off-fiber: a realizer at the pinned anchors would force σ onto the fiber
      -- (`offForce` recipe, NfEFold.lean) — contradiction with `hfib`.
      have henv : NfEvalNf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
        kvExtFib_gate_henv atomMap h_surj charFib qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t hInt
          w hxw hwt hptW
      have hatom := nf_eval_nf_atom_layer M _ σ hnf
      have hfac :=
        (nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) x1
          σ.atomAssgn).mp hatom
      exact hfib (nf_eval_unique M 0 3 _ _ _ hfac.2.2 henv)
  · -- ⇐: an honest realization re-establishes all three conjuncts.
    rintro ⟨w, h⟩
    have hxw : x < w := by
      have := (h.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h_xy
      exact this
    have hwt : w < t := by
      have := (h.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mpr h_yt
      exact this
    refine (bracketEndChar_kvExtFib_holds_iff atomMap h_surj charFib Pbr qnf M x t).mpr
      ⟨bracketEndChar_kvFib_step_complete atomMap h_surj charFib qnf h_xy h_yt M x t hcharFib
        ⟨w, h⟩, ?_, ?_, kvE_ambientDeepAnchor_of_realized M _ qnf h⟩
    · -- Past bracket at `x`.
      refine kvE_extBracketPast_complete Pbr M h_UZ h_SZ qnf w x t hxw hwt ?_ ?_
      · -- hpos: admissible bit-true σ realized exterior `x1 < x`.
        intro σ hadm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        have hzone : nf0ZoneSpec σ.1 = kvE2SepZPastX3 := by
          have hh := hadm
          rw [kvEPastAdmissible] at hh
          simp only [Bool.and_eq_true] at hh
          exact of_decide_eq_true hh.1.1.1
        have hb1 : (nf0ZoneSpec σ.1 ⟨1, by omega⟩).1 = true := by rw [hzone]; rfl
        have h1 := hx1.1 (.order 0 (Fin.succ ⟨1, by omega⟩) (Fin.succ_ne_zero ⟨1, by omega⟩).symm)
        simp only [AtomEval, Fin.cons] at h1
        exact ⟨x1, h1.mpr hb1, hx1⟩
      · -- hslice: the carried Past slice-honesty obligation.
        exact hslicePast w hxw hwt h
    · -- Future bracket at `t`.
      refine kvE_extBracketFut_complete Pbr M h_UZ h_SZ qnf w x t hxw hwt ?_ ?_
      · -- hpos: admissible bit-true σ realized exterior `t < x1`.
        intro σ hadm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        have hzone : nf0ZoneSpec σ.1 = kvE2SepZFutT3 := by
          have hh := hadm
          rw [kvEFutAdmissible] at hh
          simp only [Bool.and_eq_true] at hh
          exact of_decide_eq_true hh.1.1.1
        have hb2 : (nf0ZoneSpec σ.1 ⟨2, by omega⟩).2 = true := by rw [hzone]; rfl
        have h2 := hx1.1 (.order (Fin.succ ⟨2, by omega⟩) 0 (Fin.succ_ne_zero ⟨2, by omega⟩))
        simp only [AtomEval, Fin.cons] at h2
        exact ⟨x1, h2.mpr hb2, hx1⟩
      · -- hslice: the carried Future slice-honesty obligation.
        exact hsliceFut w hxw hwt h


/-! ## Block 4 of 4 — origin `Kamp/KampPrior.lean:1082-1232` (151 lines)
    `kampPrior_site_rungKFib_gate_match`. -/

set_option maxHeartbeats 1600000 in
-- `kampPrior_site_rungKFib_gate_match` is the de-folded sibling of the certificate above,
-- with the same eleven obligations re-keyed onto the non-projecting fiber gate; it needs
-- the same raised budget.
/-- **De-folded general-`k` supply-site certificate** `kampPrior_site_rungKFib_gate_match`
    (additive sibling of `kampPrior_site_rungK_gate_match`, `:941`). The
    per-`qnf` seam restatement of the DE-FOLDED exterior-composed discharge
    `bracketEndChar_kvExtFib_correct_prior` (Option B; routed through the SIBLING de-folded interior
    carrier `bracketEndCharKvFib`). The row-5/6 `hreal`/`hexcl` and the slice/deep exclusion
    binders are re-keyed onto the non-projecting fiber gate
    `igPtWFib … (charFib (k+1)) qnf.1 (igFoldBitFib qnf)`; the folded arity-1 provider bundle
    `P`/`hcharK` is replaced by the render-gated arity-4 char seam `hcharFib` (threaded outward like
    `hreal`/`hexcl`). Obligation discipline (carry, do NOT discharge) is preserved verbatim: `hreal`
    fires by modus ponens with `hfiberCons`; `hexcl` by the inconsistent-σ case split. The frozen
    `kampPrior_site_rungK_gate_match` above is left byte-identical (its out-of-scope consumer
    `EndIntervalConsumerK.lean:248` is unaffected). -/
theorem kampPrior_site_rungKFib_gate_match {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier)
    (hcharFib : ∀ (w : M.carrier),
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        TemporalTruth M atomMap u (charFib (k + 1) σ) ↔
          NfEvalNf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- Render-free char-soundness seam (by-design, `w`-universal; arity-4 analog of `P`/`hcharK`),
    -- threaded to `correct_prior` → `step_sound` where the de-folded `hreal` is discharged.
    (hcharFibSoundP : ∀ (w : M.carrier) (τ : NormalForm sig (k + 1) 4) (x1 : M.carrier),
      TemporalTruth M atomMap x1 (charFib (k + 1) τ) →
      NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    -- Fiber-consistency interior rows-5-6 antecedent (D7 repair), mirroring
    -- `EndIntervalCorrectPrior`: the supply population is restricted to fiber-CONSISTENT
    -- marked slices (`kvEFiberConsistent`); the doppelgänger fake ambient fails it, honest
    -- realized ambients discharge it via `kvE_fiberConsistent_of_realized`.
    (hfiberCons : ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
      kvEFiberConsistent σ = true)
    (hreal : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      (igEpLFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap x →
      (igEpRFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap t →
      (∀ (τ : NormalForm sig (k + 1) 4) (x1 : M.carrier),
        TemporalTruth M atomMap x1 (charFib (k + 1) τ) →
        NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) →
      (∀ σ : NormalForm sig (k + 1) 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig (k + 1) 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZPastX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtX ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZXW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtW ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZWT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZAtT ∨
        nf0ZoneSpec (NormalForm.atomAssgn σ) = igZFutT) →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        kvEFiberConsistent σ = true →
        ∃ x1 : M.carrier,
          NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = false →
        kvEFiberConsistent σ = true →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- SLICE-KEYED exterior interface: binder
    -- types mirrored verbatim from `ExteriorGateAssembleK.lean`, `igPtW`→`igPtWFib`.
    (hslicePast : ∀ w : M.carrier, x < w → w < t →
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true →
        kvEDeepOnFiber qnf σ = true →
        TemporalTruth M atomMap x (kvEPastPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvEPastAdmissible σ' = true ∧
          kvEPastSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hsliceFut : ∀ w : M.carrier, x < w → w < t →
      NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true →
        kvEDeepOnFiber qnf σ = true →
        TemporalTruth M atomMap t (kvEFutPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvEFutAdmissible σ' = true ∧
          kvEFutSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hexclSlicePast : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = false →
        kvEPastSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, x1 < x →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclSliceFut : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = false →
        kvEFutSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, t < x1 →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepPast : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEPastAdmissible σ = true → qnf.2 σ = false →
        nfkDropFresh σ = qnf.1 → kvEDeepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, x1 < x →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepFut : kvEAmbientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nfDepth0CharFormula atomMap h_surj) (charFib (k + 1)) qnf.1
          (igFoldBitFib qnf)).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvEFutAdmissible σ = true → qnf.2 σ = false →
        nfkDropFresh σ = qnf.1 → kvEDeepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, t < x1 →
          ¬ NfEvalNf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvExtFib atomMap h_surj charFib Pbr qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  -- Fiber-consistency: reconstruct the unrestricted interior obligations for the de-folded
  -- discharge
  -- lemma — `hreal` by modus ponens with `hfiberCons`; `hexcl` by
  -- case split (an inconsistent σ has no realization at all).
  bracketEndChar_kvExtFib_correct_prior atomMap h_surj charFib Pbr qnf
    h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t hcharFib hcharFibSoundP
    (fun hAmb w hxw hwt hg hepL hepR hcs hIL hIR hzc σ hσ =>
      hreal hAmb w hxw hwt hg hepL hepR hcs hIL hIR hzc σ hσ (hfiberCons σ hσ))
    (fun hAmb w hxw hwt hg σ hσf x1 hle1 hle2 hnf => by
      by_cases hcons : kvEFiberConsistent σ = true
      · exact hexcl hAmb w hxw hwt hg σ hσf hcons x1 hle1 hle2 hnf
      · exact hcons (kvE_fiberConsistent_of_realized M _ σ hnf))
    hslicePast hsliceFut hexclSlicePast hexclSliceFut hexclDeepPast hexclDeepFut


end FormalSystem.Metalogic.WeakCanonical.Kamp
