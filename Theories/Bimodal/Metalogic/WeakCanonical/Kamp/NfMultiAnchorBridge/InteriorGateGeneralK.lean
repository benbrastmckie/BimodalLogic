import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketK
import Batteries.Tactic.OpenPrivate

/-!
# General-`k` INTERIOR gate correctness (task 355)

A NEW **leaf sibling** of `PriorInterface.lean` / `OuterGate.lean` inside `NfMultiAnchorBridge/`.
It is **purely additive**: nothing here re-proves or edits the task-349 frozen carrier
`bracketEndChar_kv` (`CarrierKv.lean:238`), the provider interface `ExistProviders` /
`BracketCarrierCorrectVPrior` (`PriorInterface.lean:38/60`), or the k=2 template family in
`OuterGate.lean`. Those are treated as verified INPUTS; this file only *applies* them.

## What this file delivers (task 355)

The general-`k` interior gate correctness lemma `bracketEndChar_kv_correct_prior`, provider-guarded,
sorry-free, and axiom-clean, so task 349 Phase 5 can fill the `endIntervalStep` body
(`CarrierK1V.lean:2144`) and Phases 6-7 can induct on it.

## CRITICAL — the general-`k` statement is PROVIDER-GUARDED, not unconditional (finding F1)

`bracketEndChar_kv_factors` (`CarrierKv.lean:422`) proves the depth-`k` carrier factors through ONLY
the atom layer + the off-fiber Prop + the fiber-EXISTENTIAL fold bits: two quant layers agreeing on
that data yield EQUAL carriers even when they disagree on the marking of individual depth-`k` arity-4
subs inside a shared `(zoneSpec, projFresh)` fiber. That machine-checks the ISOLATION half of F1 —
the UNCONDITIONAL k ≥ 2 soundness direction is REFUTED (a lossy carrier cannot recover which marked
sub realized a fiber). Therefore the deliverable is the **provider-guarded** shape: the target
predicate is `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) — the UZ/SZ-relativized,
provider-conditional variant — mirroring the k=2 template `bracketEndChar_kvE2_sound_two_prior_frag`
(`OuterGate.lean:268`) / `bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:147`) and the
consumer's `EndIntervalCorrectPrior` (task 349 Phase 5). An unconditional general-`k` statement is a
known dead end (F1) and MUST NOT be pursued.

## Recursion structure

- **Base k = 0 / k = 1** (delivered upstream, CONSUMED not rebuilt): the target predicate is
  discharged by `bracketEndChar_kv_correct_zero_prior` (`PriorInterface.lean:80`) and
  `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`). Phase 1 (this file) validates the
  FREEZE by re-deriving those two base rungs against the frozen `InteriorGateTarget` Prop.
- **Step k → k + 1** (the substantial construction, Phases 2-5): provider/char truth bridges, the
  `holds_iff` destructuring of the successor carrier, the ⇐ completeness half, and the F1-critical ⇒
  soundness half (provider obligations reconstruct the lost fiber content).
- **General-`k` close** (Phase 6): `Nat`-induction assembling the base rungs and the step gate.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula formula_conjList formula_conjList_iff)

/-! ## Phase 1 — frozen general-`k` statement + base-rung reconciliation

`InteriorGateTarget` freezes the provider-guarded deliverable shape: the target predicate is the
UZ/SZ-relativized `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) applied to the depth-`k`
carrier `bracketEndChar_kv`. This is the byte-quotable conclusion the consumer (task 349 Phase 5
`endIntervalStep` / `EndIntervalCorrectPrior`) consumes, and the conclusion the k=2 template
`bracketEndChar_kvE2_correct_two_prior_frag` (`OuterGate.lean:359`) already delivers at `k = 2` under
its fragment/provider binders. Freezing it as a `def` (not a `theorem`) records the target without a
proof obligation; the `∀ k` theorem is assembled in Phase 6.

The base-rung reconciliation lemmas below VALIDATE the freeze (Risk R1 mitigation): the k = 0 and
k = 1 instances of the frozen `InteriorGateTarget` discharge cleanly from the landed base rungs
`bracketEndChar_kv_correct_zero_prior` / `_one_prior`, confirming the frozen predicate is the correct
provider-guarded shape BEFORE any step proof is attempted. -/

/-- **Frozen general-`k` interior-gate target predicate** (task 355 Phase 1). The provider-guarded
    deliverable shape: `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF k)`
    — the UZ/SZ-relativized carrier correctness at the FIXED anchor pair `(x, t)`
    (`PriorInterface.lean:60`). Frozen per finding F1 (see the file header): the UNCONDITIONAL k ≥ 2
    variant is refuted by `bracketEndChar_kv_factors` (`CarrierKv.lean:422`), so the deliverable is
    the provider-conditional predicate, mirroring the k=2 template's `_two_prior` shape and the task
    349 Phase 5 consumer `EndIntervalCorrectPrior`. -/
def InteriorGateTarget {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (k : Nat) : Prop :=
  BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF k)

/-- **Base-rung reconciliation, k = 0** (task 355 Phase 1 — freeze validation). The k = 0 instance
    of the frozen `InteriorGateTarget` is discharged by the landed base rung
    `bracketEndChar_kv_correct_zero_prior` (`PriorInterface.lean:80`) verbatim. This confirms the
    frozen provider-guarded predicate weakens cleanly to the unconditional depth-0 base (the k = 0
    provider obligations are vacuously satisfiable). No chain step is shortcut (G5): pure
    consumption. -/
theorem interiorGateTarget_zero {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    InteriorGateTarget atomMap h_surj charF 0 :=
  bracketEndChar_kv_correct_zero_prior atomMap h_surj charF

/-- **Base-rung reconciliation, k = 1** (task 355 Phase 1 — freeze validation). The k = 1 instance
    of the frozen `InteriorGateTarget`, under the depth-0 provider agreement `h0` (satisfied by the
    Phase-14 instantiation by construction, `KampPrior:397` at depth 0), is discharged by the landed
    base rung `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`) verbatim. This
    confirms the frozen provider-guarded predicate weakens cleanly to the first successor base rung.
    No chain step is shortcut (G5): pure consumption. -/
theorem interiorGateTarget_one {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (h0 : charF 0 = nf_depth0_char_formula atomMap h_surj) :
    InteriorGateTarget atomMap h_surj charF 1 :=
  bracketEndChar_kv_correct_one_prior atomMap h_surj charF h0

/-! ## Phase 2 — depth-`k` provider / char-layer truth bridges

The general-`k` analogs of the k=2 char-formula bridges `bracketEndChar_kvE2_hcb`
(`OuterGate.lean:102`) and `_hck` (`OuterGate.lean:123`). The char-BASE bridge `_hcb` is already
depth-0-general (it is about `nf_depth0_char_formula`, independent of the fold depth), so it is
consumed directly from `OuterGate.lean` — the atom-layer point-type bridge for the endpoint/pivot
`E[Σ]` literals. The provider bridge `_hck` is generalized here from the hard-wired depth-1
`P.existF 0` to an arbitrary-depth `P : ExistProviders sig atomMap k` via the `ExistProviders.correct`
field at `n = 0` and the `insertEnv`/`Fin.elim0` env collapse (`insertEnv` on the empty env is
`fun _ => u`). Manual bridge only — no simp/omega/aesop shortcut of a Rabinovich chain step (G5); the
`insertEnv` collapse is pure `Fin 0` bookkeeping, not a fold step. -/

/-- **Depth-`k` provider-layer truth bridge** (task 355 Phase 2; general-`k` analog of
    `bracketEndChar_kvE2_hck`, `OuterGate.lean:123`). For a depth-`k` provider bundle
    `P : ExistProviders sig atomMap k`, the depth-`k` existential provider formula `P.existF 0 χ` is
    truth-equivalent to the arity-1 depth-`k` evaluation, via `ExistProviders.correct` at `n = 0` and
    the `Fin 0 → M.carrier` env collapse. This is the per-fiber point-type truth equivalence the step
    proof (Phases 4-5) consumes at the endpoint/pivot `charK` literals. -/
theorem interiorGate_hck {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (χ : NormalForm sig k 1) (u : M.carrier) :
    temporal_truth M atomMap u (P.existF 0 χ) ↔ nf_eval_nf M k 1 (fun _ => u) χ := by
  rw [P.correct 0 χ M h_UZ h_SZ u]
  constructor
  · rintro ⟨env, henv⟩
    have heq : insertEnv env u = (fun _ => u) := by
      funext i
      simp only [insertEnv]
      rw [dif_neg (by omega)]
    rwa [heq] at henv
  · intro h
    exact ⟨Fin.elim0, by rw [insertEnv_zero]; exact h⟩

/-- **Depth-0 char-base truth bridge** (task 355 Phase 2; re-export of the depth-0-general
    `bracketEndChar_kvE2_hcb`, `OuterGate.lean:102`). The standard-instantiation depth-0
    characteristic formula is truth-equivalent to the arity-1 depth-0 evaluation. Depth-0 and
    fold-depth-independent, so it is the SAME bridge at every `k` — named here for the step proof's
    endpoint/witness base types (`xType`/`tType`/`ptW`, the depth-0 atom-layer projections). -/
theorem interiorGate_hcb {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
      nf_eval_nf M 0 1 (fun _ => u) χ :=
  bracketEndChar_kvE2_hcb atomMap h_surj M χ u

/-! ## Phase 3 — body-destructuring `holds_iff` at depth `k`

The successor carrier `bracketEndChar_kv … (k+1)` is DEFINITIONALLY `kv_body` at the depth-`k`
providers (`CarrierKv.lean:244-249`), but `kv_body` is a `private noncomputable def` in the FROZEN
`CarrierKv.lean:152` — its `let`-bound internal structure (`gate`, `S_L`/`S_R`, `mkDisjunct`,
`epL`/`epR`/`segL`/`segR`/`ptW`) cannot be referenced by name from this sibling module, and no public
holds-unfold lemma for `bracketEndChar_kv (k+1)` exists. So this section builds a PUBLIC BODY REPLICA
(`igBody`) from named public pieces (`igGate`, `igSL`, `igSR`, `igMkDisjunct`, …), each a verbatim
copy of the corresponding `kv_body` `let`. The replica is proved DEFINITIONALLY EQUAL to the frozen
successor carrier by `rfl` (`bracketEndChar_kv_succ_eq`) — the `@dite _ gate (Classical.dec gate)`
decidability instance is reproduced EXACTLY so the defeq goes through. Once exposed, the carrier's
`.holds` destructures (via the already-available `VVecEA2.holds_flatMap_map`, `NavigatedSpine.lean:220`)
into the off-fiber gate conjunct ∧ the `S_L`/`S_R` permutation-arrangement disjunction
(`bracketEndChar_kv_succ_holds_iff`). The fold-bit read is kept FIBER-EXISTENTIAL (`igFoldBit`,
`decide (∃ sub, …)`) — NOT collapsed pointwise (that collapse is valid only at `k = 1` via
`bracketEndChar_kv_one_eq`, and is exactly the F1 information loss at `k ≥ 2`). -/

noncomputable section

/-- Zone-order bit `<` (verbatim from `kv_body`'s `ltz`, `CarrierKv.lean:160`). -/
def igLtz : Bool × Bool := (true, false)
/-- Zone-order bit `=` (verbatim from `kv_body`'s `eqz`, `CarrierKv.lean:161`). -/
def igEqz : Bool × Bool := (false, false)
/-- Zone-order bit `>` (verbatim from `kv_body`'s `gtz`, `CarrierKv.lean:162`). -/
def igGtz : Bool × Bool := (false, true)
/-- Zone-spec builder for env `[w, x, t]` (verbatim from `kv_body`'s `mk3`, `CarrierKv.lean:163`). -/
def igMk3 (pw px pt : Bool × Bool) : ZoneSpec 3 := Fin.cons pw (Fin.cons px (fun _ => pt))
/-- Zone `x_1 < x` (verbatim from `kv_body`'s `zPastX`, `CarrierKv.lean:165`). -/
def igZPastX : ZoneSpec 3 := igMk3 igLtz igLtz igLtz
/-- Zone `x_1 = x` (verbatim from `kv_body`'s `zAtX`, `CarrierKv.lean:166`). -/
def igZAtX : ZoneSpec 3 := igMk3 igLtz igEqz igLtz
/-- Zone `x < x_1 < w` (verbatim from `kv_body`'s `zXW`, `CarrierKv.lean:167`). -/
def igZXW : ZoneSpec 3 := igMk3 igLtz igGtz igLtz
/-- Zone `x_1 = w` (verbatim from `kv_body`'s `zAtW`, `CarrierKv.lean:168`). -/
def igZAtW : ZoneSpec 3 := igMk3 igEqz igGtz igLtz
/-- Zone `w < x_1 < t` (verbatim from `kv_body`'s `zWT`, `CarrierKv.lean:169`). -/
def igZWT : ZoneSpec 3 := igMk3 igGtz igGtz igLtz
/-- Zone `x_1 = t` (verbatim from `kv_body`'s `zAtT`, `CarrierKv.lean:170`). -/
def igZAtT : ZoneSpec 3 := igMk3 igGtz igGtz igEqz
/-- Zone `t < x_1` (verbatim from `kv_body`'s `zFutT`, `CarrierKv.lean:171`). -/
def igZFutT : ZoneSpec 3 := igMk3 igGtz igGtz igGtz

/-- Enumeration of complete depth-`k` 1-types (verbatim from `kv_body`'s `allTypes`,
    `CarrierKv.lean:172`). -/
def igAllTypes (sig : MonadicSignature) (k : Nat) : List (NormalForm sig k 1) := Finset.univ.toList
/-- Biconditional literal at an anchor (verbatim from `kv_body`'s `lit`, `CarrierKv.lean:174`). -/
def igLit (bit : Bool) (f : Formula) : Formula := if bit then f else f.neg

/-- Left endpoint predicate `epL` at the fixed left endpoint `x` (verbatim from `kv_body`,
    `CarrierKv.lean:178-182`). -/
def igEpL {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : TemporalPred :=
  ⟨formula_conjList
    (charBase (nf_x_proj3 r)
      :: (igAllTypes sig k).map (fun χ => igLit (b igZPastX χ) (Formula.snce (charK χ) Formula.top))
      ++ (igAllTypes sig k).map (fun χ => igLit (b igZAtX χ) (charK χ)))⟩

/-- Right endpoint predicate `epR` at the fixed right endpoint `t` (verbatim from `kv_body`,
    `CarrierKv.lean:183-187`). -/
def igEpR {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : TemporalPred :=
  ⟨formula_conjList
    (charBase (nf_t_proj3 r)
      :: (igAllTypes sig k).map (fun χ => igLit (b igZAtT χ) (charK χ))
      ++ (igAllTypes sig k).map (fun χ => igLit (b igZFutT χ) (Formula.untl (charK χ) Formula.top)))⟩

/-- Left segment exclusion `segL` (verbatim from `kv_body`, `CarrierKv.lean:189-191`). -/
def igSegL {sig : MonadicSignature} {k : Nat}
    (charK : NormalForm sig k 1 → Formula) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) :
    TemporalPred :=
  ⟨formula_conjList ((igAllTypes sig k).map (fun χ =>
    if b igZXW χ then Formula.top else (charK χ).neg))⟩

/-- Right segment exclusion `segR` (verbatim from `kv_body`, `CarrierKv.lean:192-194`). -/
def igSegR {sig : MonadicSignature} {k : Nat}
    (charK : NormalForm sig k 1 → Formula) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) :
    TemporalPred :=
  ⟨formula_conjList ((igAllTypes sig k).map (fun χ =>
    if b igZWT χ then Formula.top else (charK χ).neg))⟩

/-- Witness point type `ptW` at the interior anchor `w` (verbatim from `kv_body`,
    `CarrierKv.lean:197-200`). -/
def igPtW {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : TemporalPred :=
  ⟨formula_conjList
    (charBase (nf_y_proj r)
      :: (igAllTypes sig k).map (fun χ => igLit (b igZAtW χ) (charK χ)))⟩

/-- The gate Prop: off-fiber honesty ∧ order-conflict falsity (verbatim from `kv_body`'s `gate`,
    `CarrierKv.lean:206-208`, with `consistent` inlined, `CarrierKv.lean:202-203`). -/
def igGate {sig : MonadicSignature} {k : Nat}
    (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : Prop :=
  offFiber ∧
  (∀ (zs : ZoneSpec 3) (χ : NormalForm sig k 1),
    ¬ (zs = igZPastX ∨ zs = igZAtX ∨ zs = igZXW ∨ zs = igZAtW ∨ zs = igZWT ∨ zs = igZAtT ∨
        zs = igZFutT) →
      b zs χ = false)

/-- Interior-positive left enumeration `S_L` (verbatim from `kv_body`, `CarrierKv.lean:210`). -/
def igSL {sig : MonadicSignature} {k : Nat}
    (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : List (NormalForm sig k 1) :=
  (igAllTypes sig k).filter (fun χ => b igZXW χ)

/-- Interior-positive right enumeration `S_R` (verbatim from `kv_body`, `CarrierKv.lean:211`). -/
def igSR {sig : MonadicSignature} {k : Nat}
    (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : List (NormalForm sig k 1) :=
  (igAllTypes sig k).filter (fun χ => b igZWT χ)

/-- Per-type witness predicate `charP` (verbatim from `kv_body`, `CarrierKv.lean:212`). -/
def igCharP {sig : MonadicSignature} {k : Nat}
    (charK : NormalForm sig k 1 → Formula) : NormalForm sig k 1 → TemporalPred :=
  fun χ => ⟨charK χ⟩

/-- One arrangement disjunct (verbatim from `kv_body`'s `mkDisjunct`, `CarrierKv.lean:215-220`). -/
def igMkDisjunct {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool)
    (lL lR : List (NormalForm sig k 1)) : Σ n, VecEA2 n :=
  ⟨(lL.map (igCharP charK)).length + 1 + (lR.map (igCharP charK)).length,
    { endpointLeft := igEpL charBase charK r b
      endpointRight := igEpR charBase charK r b
      bracket := bracketFromLists (lL.map (igCharP charK)) (igPtW charBase charK r b)
        (lR.map (igCharP charK)) (igSegL charK b) (igSegR charK b) }⟩

/-- **PUBLIC body replica of `kv_body`'s successor branch** (task 355 Phase 3). Verbatim copy of
    the frozen private `kv_body` (`CarrierKv.lean:221-226`) at the `@dite _ gate (Classical.dec gate)`
    gate, built from the named public pieces above so its internal structure is referenceable. Proved
    definitionally equal to `bracketEndChar_kv … (k+1)` by `rfl` in `bracketEndChar_kv_succ_eq`. -/
def igBody {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) :
    VVecEA2 :=
  @dite _ (igGate offFiber b) (Classical.dec (igGate offFiber b))
    (fun _ =>
      { disjuncts :=
          (igSL b).permutations.flatMap (fun lL =>
            (igSR b).permutations.map (fun lR => igMkDisjunct charBase charK r b lL lR)) })
    (fun _ => { disjuncts := [] })

/-- The off-fiber-honesty conjunct of the successor carrier's gate at `qnf` (verbatim from
    `bracketEndChar_kv`'s `k+1` branch, `CarrierKv.lean:246-247`). -/
def igOffFiber {sig : MonadicSignature} {k : Nat} (qnf : NormalForm sig (k + 1) 3) : Prop :=
  ∀ sub : NormalForm sig k 4, nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1 → qnf.2 sub = false

/-- The FIBER-EXISTENTIAL fold-bit read of the successor carrier at `qnf` (verbatim from
    `bracketEndChar_kv`'s `k+1` branch, `CarrierKv.lean:248-249`). Kept existential (a `decide` of
    `∃ sub, …`), never collapsed pointwise — the F1 information channel at `k ≥ 2`.

    The `Decidable` instance is written EXPLICITLY to match the frozen carrier's fold bit BYTE FOR
    BYTE: the frozen `bracketEndChar_kv` is elaborated under `open Classical in` in a module where
    no `DecidableEq (ZoneSpec 3)` instance is in scope, so its `nf0_zoneSpec … = zs` conjunct is
    decided by `Classical.propDecidable`. This sibling module DOES have `DecidableEq (ZoneSpec 3)`
    in scope, so a plain `decide` would pick the real instance and the carriers would fail to be
    definitionally equal. Reproducing the exact nested instance
    (`Fintype.decidableExistsFintype` over `And` of `instDecidableEqBool` / `Classical.propDecidable`
    (the ZoneSpec eq) / `normalForm_decEq`) makes `bracketEndChar_kv_succ_eq` a `rfl`. -/
noncomputable def igFoldBit {sig : MonadicSignature} {k : Nat} (qnf : NormalForm sig (k + 1) 3) :
    ZoneSpec 3 → NormalForm sig k 1 → Bool :=
  fun zs χ =>
    @decide (∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
        nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ)
      (@Fintype.decidableExistsFintype (NormalForm sig k 4)
        (fun sub => qnf.2 sub = true ∧ nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧
          nfk_projFresh sub = χ)
        (fun a => @instDecidableAnd (qnf.2 a = true)
          (nf0_zoneSpec (NormalForm.atom_assgn a) = zs ∧ nfk_projFresh a = χ)
          (instDecidableEqBool (qnf.2 a) true)
          (@instDecidableAnd (nf0_zoneSpec (NormalForm.atom_assgn a) = zs) (nfk_projFresh a = χ)
            (Classical.propDecidable (nf0_zoneSpec (NormalForm.atom_assgn a) = zs))
            (normalForm_decEq sig k 1 (nfk_projFresh a) χ)))
        (normalForm_fintype sig k 4))

set_option maxHeartbeats 1600000 in
/-- **Defeq bridge: the successor carrier IS the public replica** (task 355 Phase 3). The `k+1`
    branch of `bracketEndChar_kv` (`CarrierKv.lean:244-249`) is `kv_body` at the depth-`k` providers,
    and `igBody` is a verbatim copy of `kv_body`'s body, so the two are DEFINITIONALLY EQUAL — pure
    `rfl`, no semantics. This exposes the frozen private carrier's structure for destructuring. -/
theorem bracketEndChar_kv_succ_eq {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (qnf : NormalForm sig (k + 1) 3) :
    bracketEndChar_kv atomMap h_surj charF (k + 1) qnf =
      igBody (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
        (igOffFiber qnf) (igFoldBit qnf) := by
  -- `bracketEndChar_kv (k+1)` reduces (equation lemma) to the frozen private `kv_body` at these
  -- args; `igBody` is a verbatim public copy at the SAME args (the fold-bit instance is matched
  -- byte-for-byte by `igFoldBit`), so the two are definitionally equal. Pure `rfl`, no semantics.
  simp only [bracketEndChar_kv]
  rfl

/-- **`holds` destructuring of the public replica** (task 355 Phase 3). The replica's `VVecEA2.holds`
    splits into the gate conjunct ∧ the `S_L`/`S_R` permutation-arrangement disjunction. On-gate the
    body is the `flatMap`/`map` disjunct list (destructured by `VVecEA2.holds_flatMap_map`,
    `NavigatedSpine.lean:220`); off-gate it is the empty disjunction `⟨[]⟩` whose `holds` is `False`
    (matching the failed gate on the RHS). No chain step is shortcut (G5): pure list-membership and
    `dite` computation. -/
theorem igBody_holds_iff {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (x t : M.carrier) :
    (igBody charBase charK r offFiber b).holds M atomMap x t ↔
      igGate offFiber b ∧
      ∃ lL ∈ (igSL b).permutations, ∃ lR ∈ (igSR b).permutations,
        (igMkDisjunct charBase charK r b lL lR).2.holds M atomMap x t := by
  unfold igBody
  by_cases hg : igGate offFiber b
  · rw [dif_pos hg,
      VVecEA2.holds_flatMap_map M atomMap (igSL b).permutations (igSR b).permutations
        (igMkDisjunct charBase charK r b) x t]
    exact ⟨fun h => ⟨hg, h⟩, fun h => h.2⟩
  · rw [dif_neg hg]
    constructor
    · intro h
      obtain ⟨vea, hmem, -⟩ := h
      exact (List.not_mem_nil hmem).elim
    · intro h
      exact (hg h.1).elim

/-- **Depth-`k` fold-bit fiber-existential characterization** (task 355 Phase 3). The successor
    carrier's fold bit `igFoldBit qnf zs χ = true` iff there EXISTS a marked depth-`k` arity-4 sub in
    the `(zs, χ)` fiber — the extraction/introduction interface Phases 4-5 consume, kept existential
    (never pointwise-collapsed). Pure `decide_eq_true_iff`. -/
theorem igFoldBit_iff {sig : MonadicSignature} {k : Nat}
    (qnf : NormalForm sig (k + 1) 3) (zs : ZoneSpec 3) (χ : NormalForm sig k 1) :
    igFoldBit qnf zs χ = true ↔
      ∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
        nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ := by
  unfold igFoldBit
  simp only [decide_eq_true_iff]

/-- **Successor carrier `holds` destructuring** (task 355 Phase 3 — the deliverable). Combines the
    defeq bridge `bracketEndChar_kv_succ_eq` with the replica destructuring `igBody_holds_iff`: the
    successor carrier's `.holds` at the fixed anchor pair `(x, t)` is the gate conjunct ∧ the
    `S_L`/`S_R` permutation-arrangement disjunction of realized-marked-sub brackets. The fold-bit read
    is FIBER-EXISTENTIAL (`igFoldBit`); the destructuring composes with the Phase-2 point-type bridges
    (`interiorGate_hck`/`_hcb`) at the endpoint/pivot literals. This is the structural entry point for
    Phase 4 (⇐ completeness) and Phase 5 (⇒ soundness). -/
theorem bracketEndChar_kv_succ_holds_iff {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_kv atomMap h_surj charF (k + 1) qnf).holds M atomMap x t ↔
      igGate (igOffFiber qnf) (igFoldBit qnf) ∧
      ∃ lL ∈ (igSL (igFoldBit qnf)).permutations, ∃ lR ∈ (igSR (igFoldBit qnf)).permutations,
        (igMkDisjunct (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)
          lL lR).2.holds M atomMap x t := by
  rw [bracketEndChar_kv_succ_eq atomMap h_surj charF qnf]
  exact igBody_holds_iff (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
    (igOffFiber qnf) (igFoldBit qnf) M atomMap x t

/-! ## Phase 4a — the honest gate (`igGate` from a genuine realizer)

The completeness half's first milestone: from a genuine depth-`(k+1)` realizer at bracket witness
`w` (`x < w < t`), the successor carrier's gate `igGate (igOffFiber qnf) (igFoldBit qnf)` holds. Both
conjuncts are the general-`k` analogs of the k=2 gate `kvE2_sepGate_holds_of_honest`
(`SharedWitness.lean:2797`, parts i/ii):

- **Off-fiber honesty** (`igOffFiber`) is delivered VERBATIM by the generic whole-evaluation fold
  bridge `nf_eval_nfk_iff_efold` (`NfEFold.lean`): its off-fiber conjunct
  `∀ sub, nfk_dropFresh sub ≠ qnf.1 → qnf.2 sub = false` IS `igOffFiber qnf` (defeq, since
  `nfk_dropFresh sub = nf0_dropFresh sub.atom_assgn`).
- **Order-conflict falsity** (the seven-zone gate) is the depth-`k` analog of part (ii): a marked sub
  is realized at some `x1` over `[x1,w,x,t]`, so its atom-layer zone `nf0_zoneSpec (atom_assgn sub)`
  is one of the seven order-consistent zones (`igZone3_consistent`, the generic trichotomy below,
  modeled on `kvE2_sep_zone3_consistent`). No chain step is shortcut (G5): pure order trichotomy and
  the atom-layer bridge `nf_eval_nf_atom_layer`. -/

/-- **Generic seven-zone order consistency** (task 355 Phase 4a; general-`k` restatement of
    `kvE2_sep_zone3_consistent`, `SharedWitness.lean:2611`). Any zone realized at a point `u` over the
    bracket env `[w,x,t]` with `x < w < t` is one of the seven bracket-order-consistent zones. Pure
    order trichotomy on `u` against `x`, `w`, `t`; `k1v_bool_eq_false` converts each strict-order
    negation to a Bool bit. -/
theorem igZone3_consistent {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (w x t u : M.carrier)
    (hxw : x < w) (hwt : w < t) (zs : ZoneSpec 3)
    (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u) :
    zs = igZPastX ∨ zs = igZAtX ∨ zs = igZXW ∨ zs = igZAtW ∨ zs = igZWT ∨ zs = igZAtT ∨
      zs = igZFutT := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  simp only [Fin.cons] at h0 h1 h2
  have hzs : ∀ (p0 p1 p2 : Bool × Bool),
      zs ⟨0, by omega⟩ = p0 → zs ⟨1, by omega⟩ = p1 → zs ⟨2, by omega⟩ = p2 →
      zs = Fin.cons p0 (Fin.cons p1 (fun _ => p2)) := by
    intro p0 p1 p2 e0 e1 e2
    funext i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using e0
    | ⟨1, _⟩ => simpa only [Fin.cons] using e1
    | ⟨2, _⟩ => simpa only [Fin.cons] using e2
  have hxt : x < t := hxw.trans hwt
  rcases lt_trichotomy u x with hux | rfl | hux
  · -- u < x : zPastX
    have huw : u < w := hux.trans hxw
    have hut : u < t := hux.trans hxt
    exact Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hux, k1v_bool_eq_false h1.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))
  · -- u = x : zAtX
    exact Or.inr (Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hxw, k1v_bool_eq_false h0.2 (lt_asymm hxw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl _),
        k1v_bool_eq_false h1.2 (lt_irrefl _)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hxt, k1v_bool_eq_false h2.2 (lt_asymm hxt)⟩)))
  · -- x < u : split against w
    rcases lt_trichotomy u w with huw | rfl | huw
    · -- x < u < w : zXW
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))
    · -- u = w : zAtW
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl _),
          k1v_bool_eq_false h0.2 (lt_irrefl _)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hwt, k1v_bool_eq_false h2.2 (lt_asymm hwt)⟩)))))
    · -- w < u : split against t
      rcases lt_trichotomy u t with hut | rfl | hut
      · -- w < u < t : zWT
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))))
      · -- u = t : zAtT
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl _),
            k1v_bool_eq_false h2.2 (lt_irrefl _)⟩)))))))
      · -- t < u : zFutT
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hut), h2.2.mp hut⟩)))))))

/-- **Honest gate at depth `k+1`** (task 355 Phase 4a — the completeness first milestone). From a
    genuine realizer at bracket witness `w` (`x < w < t`), the successor carrier's gate holds. The
    off-fiber conjunct is delivered by the generic fold bridge `nf_eval_nfk_iff_efold`; the seven-zone
    conjunct routes each marked sub through its atom-layer zone via `nf_eval_nf_atom_layer` +
    `igZone3_consistent`. General-`k` analog of `kvE2_sepGate_holds_of_honest` (parts i/ii). No chain
    step is shortcut (G5). -/
theorem bracketEndChar_kv_step_gate {sig : MonadicSignature} {k : Nat}
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    igGate (igOffFiber qnf) (igFoldBit qnf) := by
  refine ⟨((nf_eval_nfk_iff_efold M _ qnf).mp h).2, ?_⟩
  -- Seven-zone order-conflict falsity: an off-consistent zone marks no realized sub.
  intro zs χ hncons
  cases hbit : igFoldBit qnf zs χ with
  | false => rfl
  | true =>
    obtain ⟨sub, hmark, hzone, _hproj⟩ := (igFoldBit_iff qnf zs χ).mp hbit
    -- The marked sub is realized at some `x1` over `[x1,w,x,t]` (fold conjunct of the realizer).
    obtain ⟨x1, hx1⟩ := (h.2 sub).mpr hmark
    have hatom := nf_eval_nf_atom_layer M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub hx1
    -- Read the atom-layer zone of `x1` against `[w,x,t]`.
    have hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
        (nf0_zoneSpec (NormalForm.atom_assgn sub)) x1 := by
      intro i
      refine ⟨?_, ?_⟩
      · have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        exact h1
      · have h1 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        exact h1
    rw [hzone] at hz
    exact absurd (igZone3_consistent M w x t x1 hxw hwt zs hz) hncons

/-! ## Phase 4b — the fold-realization biconditional (fiber bits ↔ model witnesses)

The engine that converts the successor carrier's fiber-existential fold bit into a genuine interval
witness (and back). This is the general-`k` analog of the depth-1 `hzone'` fold biconditional inside
`bracketEndChar_k1v_complete` (`CarrierK1V.lean:1655`), where the pointwise `efold_of_nf1` read is
replaced by the fiber-existential `igFoldBit`:

`igFoldBit qnf zs χ = true ↔ ∃ u, zoneHolds M [w,x,t] zs u ∧ nf_eval_nf M k 1 (fun _ => u) χ`.

- **⇒** (bit → witness): a marked sub in the `(zs, χ)` fiber is realized at some `x1` over
  `[x1,w,x,t]` (realizer fold conjunct); its atom-layer zone is `zs` (`nf0_zoneSpec`) and its fresh
  projection realizes `χ` at `x1` (`nf_eval_projFresh`, `ExteriorBracketK.lean:163`, with
  `nfk_projFresh sub = χ`).
- **⇐** (witness → bit): the characteristic depth-`k` sub at `[u,w,x,t]`
  (`nf_characteristic_satisfies`) is marked (realizer forward), sits in zone `zs` (its atom layer
  reads `u`'s order against `[w,x,t]` = `zoneHolds`), and its fresh projection equals `χ`
  (`nf_eval_unique` against the given realization). No chain step is shortcut (G5); the fold bit is
  read FIBER-EXISTENTIALLY throughout (F1 channel preserved). -/

/-- **Fold-realization biconditional at depth `k+1`** (task 355 Phase 4b — the fiber-bits engine).
    The successor carrier's fiber-existential fold bit is TRUE exactly when the model realizes the
    interior 1-type `χ` at some point in zone `zs` relative to `[w,x,t]`. Consumes `nf_eval_projFresh`
    (⇒) and `nf_characteristic_satisfies` + `nf_eval_unique` (⇐). -/
theorem igFoldBit_realize_iff {sig : MonadicSignature} {k : Nat}
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (zs : ZoneSpec 3) (χ : NormalForm sig k 1) :
    igFoldBit qnf zs χ = true ↔
      ∃ u : M.carrier, zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u ∧
        nf_eval_nf M k 1 (fun _ => u) χ := by
  constructor
  · -- ⇒ : a marked fiber sub is realized; read its zone and fresh projection.
    intro hbit
    obtain ⟨sub, hmark, hzone, hproj⟩ := (igFoldBit_iff qnf zs χ).mp hbit
    obtain ⟨x1, hx1⟩ := (h.2 sub).mpr hmark
    have hatom := nf_eval_nf_atom_layer M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub hx1
    refine ⟨x1, ?_, ?_⟩
    · intro i
      refine ⟨?_, ?_⟩
      · have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        rw [← hzone]; exact h1
      · have h1 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        rw [← hzone]; exact h1
    · rw [← hproj]
      exact nf_eval_projFresh M (Fin.cons w (Fin.cons x (fun _ => t))) x1 sub hx1
  · -- ⇐ : the characteristic sub at `[u,w,x,t]` is a marked fiber witness for `(zs, χ)`.
    rintro ⟨u, hu, hχ⟩
    set env4 : Fin 4 → M.carrier := Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t))) with henv4
    set csub : NormalForm sig k 4 := nf_characteristic M k 4 env4 with hcsub
    have hcsat : nf_eval_nf M k 4 env4 csub := nf_characteristic_satisfies M k 4 env4
    have hcatom := nf_eval_nf_atom_layer M env4 csub hcsat
    apply (igFoldBit_iff qnf zs χ).mpr
    refine ⟨csub, ?_, ?_, ?_⟩
    · -- marked: the realizer's forward direction (csub is realized at `u`).
      exact (h.2 csub).mp ⟨u, hcsat⟩
    · -- zoneSpec = zs: the atom layer reads `u`'s order against `[w,x,t]`, which `hu` pins to `zs`.
      funext i
      have h0 := hcatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
      have h1 := hcatom (.order i.succ 0 (Fin.succ_ne_zero i))
      simp only [atom_eval, henv4, Fin.cons_zero, Fin.cons_succ] at h0 h1
      have hb0 : (NormalForm.atom_assgn csub) (.order 0 i.succ (Fin.succ_ne_zero i).symm)
          = (zs i).1 := by
        rw [Bool.eq_iff_iff]; exact h0.symm.trans (hu i).1
      have hb1 : (NormalForm.atom_assgn csub) (.order i.succ 0 (Fin.succ_ne_zero i))
          = (zs i).2 := by
        rw [Bool.eq_iff_iff]; exact h1.symm.trans (hu i).2
      exact Prod.ext hb0 hb1
    · -- projFresh = χ: both realize the same 1-type at `u`; uniqueness.
      exact nf_eval_unique M k 1 (fun _ => u) (nfk_projFresh csub) χ
        (nf_eval_projFresh M (Fin.cons w (Fin.cons x (fun _ => t))) u csub hcsat) hχ

/-! ## Phase 4b — reused depth-1 completeness machinery (private helpers + depth-`k` sort)

The depth-1 completeness engine `bracketEndChar_k1v_complete` (`CarrierK1V.lean:1629`) is built from
several PRIVATE helpers that are DEPTH-AGNOSTIC (the arrangement insertion sort `k1v_sorted_insert`,
generic over the point-type `α`; the bracket assembler `k1v_bracket_construct`, over
`List TemporalPred`; the arity-3 endpoint 1-type extractors `k1v_extract_x_nf3`/`_t_nf3`/`_y_nf`,
over `qnf.1 : NormalForm sig 0 3`; and the zone-reader `k1v_zoneHolds_cons_iff`). They are opened here
via `open private` — pure consumption, no re-proof, no edit to the frozen `CarrierK1V.lean`. Only the
arrangement-selection wrapper `k1v_sorted_realization` is depth-0-hardwired (its point types are
`NormalForm sig 0 1`), so its general-`k` analog `igk_sorted_realization` is re-derived below over
`NormalForm sig k 1` (byte-for-byte the same insertion induction, `nf_eval_unique` at depth `k`). -/

open private k1v_sorted_insert k1v_zoneHolds_cons_iff k1v_extract_x_nf3 k1v_extract_t_nf3
  k1v_extract_y_nf k1v_bracket_construct from
  Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V

/-- **Depth-`k` arrangement selection** (task 355 Phase 4b; general-`k` analog of
    `k1v_sorted_realization`, `CarrierK1V.lean:1447`). Every list of complete depth-`k` 1-types each
    realized somewhere strictly inside `(a, b)` admits a simultaneous arrangement — a permutation
    tagged with realizing points in strictly increasing model order. Distinctness is automatic:
    distinct complete `k`-types exclude each other at any single point (`nf_eval_unique M k 1`). Same
    insertion induction as the depth-1 original, over the generic insert helper `k1v_sorted_insert`. -/
theorem igk_sorted_realization {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig)
    (a b : M.carrier)
    (S : List (NormalForm sig k 1)) (hnd : S.Nodup)
    (hreal : ∀ χ ∈ S, ∃ u, a < u ∧ u < b ∧ nf_eval_nf M k 1 (fun _ => u) χ) :
    ∃ ps : List (NormalForm sig k 1 × M.carrier),
      List.Perm (ps.map Prod.fst) S ∧
      (ps.map Prod.snd).Pairwise (· < ·) ∧
      ∀ p ∈ ps, (a < p.2 ∧ p.2 < b) ∧ nf_eval_nf M k 1 (fun _ => p.2) p.1 := by
  induction S with
  | nil => exact ⟨[], by simp, by simp, by simp⟩
  | cons χ S' ih =>
    obtain ⟨u, hau, hub, huχ⟩ := hreal χ List.mem_cons_self
    obtain ⟨ps', hperm', hsort', hprops'⟩ :=
      ih (List.nodup_cons.mp hnd).2 (fun χ' h' => hreal χ' (List.mem_cons_of_mem _ h'))
    have hne : ∀ p ∈ ps', p.2 ≠ u := by
      intro p hp heq
      have hev : nf_eval_nf M k 1 (fun _ => u) p.1 := heq ▸ (hprops' p hp).2
      have hpq : p.1 = χ := nf_eval_unique M k 1 _ p.1 χ hev huχ
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

/-! ## Phase 4b — ⇐ completeness (realizer → successor carrier holds)

The completeness half of the k→k+1 step. From a genuine depth-`(k+1)` realizer at bracket witness
`w`, the successor carrier `.holds` at the FIXED endpoints `(x, t)`. This is the general-`k`
transcription of `bracketEndChar_k1v_complete` (`CarrierK1V.lean:1629`) with three substitutions:

1. the pointwise depth-1 fold bit `(efold_of_nf1 qnf).2 (zs, χ)` → the fiber-existential
   `igFoldBit qnf zs χ`, its fold biconditional supplied by `igFoldBit_realize_iff` (Phase 4b);
2. the depth-0 interior point type `char χ` → `charF k χ`, its realization supplied by
   `interiorGate_hck` (Phase 2) under the provider agreement `hcharK : charF k = fun χ => P.existF 0 χ`
   (the general-`k` analog of the k=2 template's `P`-parameterization, `OuterGate.lean:147`);
3. the fixed endpoints' base 1-types stay depth-0 (`interiorGate_hcb`), the arity-3 extractors
   (`k1v_extract_*`) and the bracket assembler (`k1v_bracket_construct`) are reused verbatim.

The gate conjunct is discharged by `bracketEndChar_kv_step_gate` (Phase 4a). This is NOT F1-obstructed:
a genuine realizer supplies the fiber content (Rabinovich Cor 5.4 endpoint characteristic chain, §5
bracket placement PDF p.7). No chain step is shortcut (G5); interior content rides bracket WITNESS
slots at FULL arity (G1/N4). -/

set_option maxHeartbeats 1600000 in
/-- **Inductive step ⇐ completeness** (task 355 Phase 4). From the arity-3 realizer at bracket
    witness `w`, the successor carrier `.holds` at `(x, t)`, via `bracketEndChar_kv_succ_holds_iff`'s
    RHS: the honest gate (Phase 4a) plus ONE sorted `S_L`/`S_R` arrangement whose `igMkDisjunct`
    bracket holds. Provider-guarded (`P`, `hcharK`, UZ/SZ) so the interior point types realize via
    `interiorGate_hck`. -/
theorem bracketEndChar_kv_step_complete {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (P : ExistProviders sig atomMap k)
    (hcharK : charF k = fun χ => P.existF 0 χ)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier) :
    (∃ w : M.carrier, nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) →
      (bracketEndChar_kv atomMap h_surj charF (k + 1) qnf).holds M atomMap x t := by
  rintro ⟨w, hw⟩
  -- Atom layer + bracket order facts.
  have h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
    nf_eval_nf_atom_layer M _ qnf hw
  have hxw : x < w := by
    have h1 := h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr h_xy
  have hwt : w < t := by
    have h1 := h_atom (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr h_yt
  have hxt : x < t := hxw.trans hwt
  -- Point-type realization bridges: interior (depth `k`, provider) and endpoint base (depth 0).
  have hchar : ∀ (χ : NormalForm sig k 1) (u : M.carrier),
      temporal_truth M atomMap u (charF k χ) ↔ nf_eval_nf M k 1 (fun _ => u) χ := by
    intro χ u; simp only [hcharK]; exact interiorGate_hck atomMap P M h_UZ h_SZ χ u
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
        nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  -- Endpoint/witness arity-1 base evaluations (fixed points, reused arity-3 extractors).
  have h_y_nf := k1v_extract_y_nf M qnf.1 w x t h_atom
  have h_x_nf := k1v_extract_x_nf3 M qnf.1 w x t h_atom
  have h_t_nf := k1v_extract_t_nf3 M qnf.1 w x t h_atom
  -- Fold biconditional (fiber bit ↔ interval witness), specialized to this realizer.
  have hz' : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig k 1),
      igFoldBit qnf zs χ = true ↔
        ∃ u : M.carrier, zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u ∧
          nf_eval_nf M k 1 (fun _ => u) χ :=
    fun zs χ => igFoldBit_realize_iff qnf M w x t hw zs χ
  -- Zone-membership constructors at the seven consistent zones (Def 3.1 ordering channel).
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
  have hLreal : ∀ χ : NormalForm sig k 1, igFoldBit qnf igZXW χ = true →
      ∃ u, x < u ∧ u < w ∧ nf_eval_nf M k 1 (fun _ => u) χ := by
    intro χ hbit
    obtain ⟨u, hzu, hev⟩ := (hz' igZXW χ).mp hbit
    rw [show igZXW = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.2.1.2.mpr rfl, hzu.1.1.mpr rfl, hev⟩
  have hRreal : ∀ χ : NormalForm sig k 1, igFoldBit qnf igZWT χ = true →
      ∃ u, w < u ∧ u < t ∧ nf_eval_nf M k 1 (fun _ => u) χ := by
    intro χ hbit
    obtain ⟨u, hzu, hev⟩ := (hz' igZWT χ).mp hbit
    rw [show igZWT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.1.2.mpr rfl, hzu.2.2.1.mpr rfl, hev⟩
  -- Segment exclusions on ALL of `(x, w)` / `(w, t)`.
  have hsegL_all : ∀ u, x < u → u < w → (igSegL (charF k) (igFoldBit qnf)).eval_at M atomMap u := by
    intro u hxu huw
    simp only [igSegL, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : igFoldBit qnf igZXW χ with
    | true => rw [if_pos rfl]; exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp)]
      intro hch
      have hbit := (hz' igZXW χ).mpr ⟨u, hzXW u hxu huw, (hchar χ u).mp hch⟩
      rw [hb] at hbit; exact Bool.noConfusion hbit
  have hsegR_all : ∀ u, w < u → u < t → (igSegR (charF k) (igFoldBit qnf)).eval_at M atomMap u := by
    intro u hwu hut
    simp only [igSegR, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : igFoldBit qnf igZWT χ with
    | true => rw [if_pos rfl]; exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp)]
      intro hch
      have hbit := (hz' igZWT χ).mpr ⟨u, hzWT u hwu hut, (hchar χ u).mp hch⟩
      rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED left endpoint `x` (exterior Since literals, zPastX/zAtX).
  have hepL : (igEpL (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
      (igFoldBit qnf)).eval_at M atomMap x := by
    simp only [igEpL, igLit, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hcharB _ x).mpr h_x_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : igFoldBit qnf igZPastX χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hz' igZPastX χ).mp hb
          rw [show igZPastX = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false)))
              from rfl, k1v_zoneHolds_cons_iff] at hzu
          exact ⟨u, hzu.2.1.1.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
        | false =>
          rw [if_neg (by simp)]
          rintro ⟨s, hsx, hsχ, -⟩
          have hbit := (hz' igZPastX χ).mpr ⟨s, hzPastX s hsx, (hchar χ s).mp hsχ⟩
          rw [hb] at hbit; exact Bool.noConfusion hbit
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBit qnf igZAtX χ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZAtX χ).mp hb
        rw [show igZAtX = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = x := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.1))
        exact (hchar χ x).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hz' igZAtX χ).mpr ⟨x, hzAtX, (hchar χ x).mp hch⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED right endpoint `t` (exterior Until literals, zAtT/zFutT).
  have hepR : (igEpR (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
      (igFoldBit qnf)).eval_at M atomMap t := by
    simp only [igEpR, igLit, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hcharB _ t).mpr h_t_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : igFoldBit qnf igZAtT χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hz' igZAtT χ).mp hb
          rw [show igZAtT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false)))
              from rfl, k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = t := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.1))
          exact (hchar χ t).mpr (hueq ▸ hev)
        | false =>
          rw [if_neg (by simp)]
          intro hch
          have hbit := (hz' igZAtT χ).mpr ⟨t, hzAtT, (hchar χ t).mp hch⟩
          rw [hb] at hbit; exact Bool.noConfusion hbit
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBit qnf igZFutT χ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZFutT χ).mp hb
        rw [show igZFutT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        exact ⟨u, hzu.2.2.2.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
      | false =>
        rw [if_neg (by simp)]
        rintro ⟨s, hts, hsχ, -⟩
        have hbit := (hz' igZFutT χ).mpr ⟨s, hzFutT s hts, (hchar χ s).mp hsχ⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Witness point type at `w` (complete type + equality-zone literals ONLY, rule N4).
  have hptW : (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
      (igFoldBit qnf)).eval_at M atomMap w := by
    simp only [igPtW, igLit, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_cons.mp hf with rfl | hf
    · exact (hcharB _ w).mpr h_y_nf
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBit qnf igZAtW χ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZAtW χ).mp hb
        rw [show igZAtW = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = w := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
        exact (hchar χ w).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hz' igZAtW χ).mpr ⟨w, hzAtW, (hchar χ w).mp hch⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Sorted arrangements of the interior-positive enumerations.
  obtain ⟨psL, hpermL, hsortL, hpropsL⟩ :=
    igk_sorted_realization M x w (igSL (igFoldBit qnf))
      ((Finset.nodup_toList _).filter _)
      (fun χ hχ => hLreal χ (by simpa only [igSL, igAllTypes, decide_eq_true_eq]
        using (List.mem_filter.mp hχ).2))
  obtain ⟨psR, hpermR, hsortR, hpropsR⟩ :=
    igk_sorted_realization M w t (igSR (igFoldBit qnf))
      ((Finset.nodup_toList _).filter _)
      (fun χ hχ => hRreal χ (by simpa only [igSR, igAllTypes, decide_eq_true_eq]
        using (List.mem_filter.mp hχ).2))
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
  -- Enter the carrier via the Phase-3 destructuring; gate + the (psL, psR) arrangement disjunct.
  rw [bracketEndChar_kv_succ_holds_iff atomMap h_surj charF qnf M x t]
  refine ⟨bracketEndChar_kv_step_gate qnf M w x t hxw hwt hw,
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
    have h1 : (List.map (igCharP (charF k)) (psL.map Prod.fst))[i]'hi =
        igCharP (charF k) ((psL[i]'hi').1) := by simp only [List.getElem_map]
    have h2 : (psL.map Prod.snd)[i]'(by simpa using hi') = (psL[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    simp only [igCharP, TemporalPred.eval_at]
    exact (hchar _ _).mpr (hpropsL _ (List.getElem_mem _)).2
  · intro i hi
    have hi' : i < psR.length := by simpa using hi
    have h1 : (List.map (igCharP (charF k)) (psR.map Prod.fst))[i]'hi =
        igCharP (charF k) ((psR[i]'hi').1) := by simp only [List.getElem_map]
    have h2 : (psR.map Prod.snd)[i]'(by simpa using hi') = (psR[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    simp only [igCharP, TemporalPred.eval_at]
    exact (hchar _ _).mpr (hpropsR _ (List.getElem_mem _)).2

/-! ## Phase 5 — ⇒ soundness (successor carrier holds + provider obligations → realizer)

The F1-critical half of the k→k+1 step. From `(bracketEndChar_kv … (k+1) qnf).holds M atomMap x t`,
under the depth-`k` PROVIDER OBLIGATIONS, reconstruct the arity-3 realizer
`∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`. This is the general-`k` analog of the k=2 template
`bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:268`), one fold-layer deeper.

**The F1 information channel (`bracketEndChar_kv_factors`, `CarrierKv.lean:422`).** The successor
carrier's fold data is fiber-EXISTENTIAL (`igFoldBit`): from the carrier's `.holds` one recovers only
*that some* marked depth-`k` arity-4 sub sits in a `(zone, χ)` fiber, never *which* sub — the arity-4
relational content of a fiber is NOT intrinsic to the carrier (two carriers agreeing on all
fiber-existential fold bits are EQUAL yet may disagree on per-sub marking). Reconstructing the
per-sub fold biconditional `∀ σ, (∃ x1, nf_eval_nf M k 4 [x1,w,x,t] σ) ↔ qnf.2 σ = true`
(`nf_eval_nfk_iff_efold`'s internal `Iff.rfl`, `NfEFold.lean:643`) therefore requires the fiber
content the provider obligations supply — exactly the k=2 template's design:

- `hreal` (marked → realizable): the depth-`k` provider realizes each marked sub `σ` (`qnf.2 σ = true`)
  at some `x1` — the arity-`(3+1)` provider `P.existF 3` channel (`PriorInterface.lean:41`), gated on
  the pivot `igPtW` holding at the bracket witness `w`. Mirrors the k=2 `hrealI`/`hrealB`.
- `hexcl` (cone) + `hexclExt` (exterior): an UNMARKED sub (`qnf.2 σ = false`) is realized at NO `x1`
  — split at the fixed cone `x ≤ x1 ≤ t` (`hexcl`, dischargeable by the Phase-14 provider) and the
  strictly-exterior residue (`hexclExt`, the Rabinovich Prop-4.3 re-flatten / Lemma 7.6 adjacency
  hand-off, `OuterGate.lean:312`; the exterior-bracket layer, tasks 351/352/354 — a task-355
  NON-goal, threaded OUTWARD verbatim as the k=2 template does).

Given those obligations, the reconstruction is direct and does NOT read the lossy fold bits: extract
the bracket witness `w` + its `igPtW` eval (`k1v_bracket_extract`, depth-agnostic), reconstruct the
depth-0 atom layer from the endpoint/witness char heads (`k1v_reconstruct_nf3` + `interiorGate_hcb`),
then assemble the per-sub biconditional (`hreal` forward, `hexcl`+`hexclExt` backward). No chain step
is shortcut (G5); the fold stays fiber-existential (F1 channel intact — the obligations, not a
pointwise collapse, supply the fiber content). -/

open private k1v_bracket_extract k1v_reconstruct_nf3 from
  Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V

set_option maxHeartbeats 1600000 in
/-- **Inductive step ⇒ soundness** (task 355 Phase 5 — the F1-critical direction). From the
    successor carrier `.holds` at the FIXED endpoints `(x, t)`, under the depth-`k` provider
    realization/exclusion obligations, the arity-3 realizer `∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`.
    General-`k` analog of `bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:268`), NOT
    fragment-restricted: under the named obligations the arrangement structure is not read for the
    per-sub fold biconditional, so the full `S_L`/`S_R` permutation disjunction is admissible. The
    exterior-marked residue rides `hexclExt` outward (the task-348/351/352/354 exterior-bracket
    hand-off, Rabinovich Lemma 7.6 adjacency composition — a task-355 NON-goal). No `sorry`/`admit`;
    the exterior residue is a NAMED binder, not a hole. -/
theorem bracketEndChar_kv_step_sound {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kv atomMap h_surj charF (k + 1) qnf).holds M atomMap x t →
      ∃ w : M.carrier, nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  intro h_holds
  -- Enter the carrier via the Phase-3 destructuring: gate + one arrangement disjunct.
  rw [bracketEndChar_kv_succ_holds_iff atomMap h_surj charF qnf M x t] at h_holds
  obtain ⟨_hgate, lL, _hlL, lR, _hlR, hveah⟩ := h_holds
  obtain ⟨hepL, hepR, hbr⟩ := hveah
  -- Extract the bracket witness `w` (`x < w < t`) and its `igPtW` eval (the obligation gate).
  obtain ⟨w, hxw, hwt, hptWe, -, -, -, -⟩ :=
    k1v_bracket_extract M atomMap _ _ _ _ _ x t hbr
  have hxt : x < t := hxw.trans hwt
  -- Depth-0 endpoint/witness char bridge.
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
        nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  -- Endpoint/witness complete types (heads of the conjunction lists). `hptWe` is kept RAW for the
  -- provider obligations; the witness head is read off a copy.
  have hxT : temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_x_proj3 qnf.1)) := by
    have h := hepL
    simp only [igMkDisjunct, igEpL, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have htT : temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_t_proj3 qnf.1)) := by
    have h := hepR
    simp only [igMkDisjunct, igEpR, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have hyW : temporal_truth M atomMap w
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj qnf.1)) := by
    have h := hptWe
    simp only [igPtW, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ List.mem_cons_self
  -- Reconstruct the depth-0 atom layer at `[w, x, t]` (Chain step 2, rule N1 framing).
  have h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
    k1v_reconstruct_nf3 M qnf.1 w x t
      ((hcharB _ w).mp hyW) ((hcharB _ x).mp hxT) ((hcharB _ t).mp htT)
      (iff_of_false (lt_asymm hxw) (by simp only [h_yx]; decide))
      (iff_of_true hwt h_yt)
      (iff_of_true hxw h_xy)
      (iff_of_true hxt h_xt)
      (iff_of_false (lt_asymm hwt) (by simp only [h_ty]; decide))
      (iff_of_false (lt_asymm hxt) (by simp only [h_tx]; decide))
  -- Assemble the realizer: atom layer + the per-sub fold biconditional (defeq, `NfEFold.lean:643`).
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
  · -- marked → realizable: the provider realizes each marked sub (`hreal`, gated on `igPtW` at `w`).
    intro hmark
    exact hreal w hxw hwt hptWe sub hmark

/-! ## Phase 6 — step biconditional (assembly of Phases 4 + 5)

The k→k+1 step biconditional `bracketEndChar_kv_step_correct` = ⟨sound (Phase 5), complete (Phase 4)⟩
at symbolic `k+1`. It carries the UNION of the two halves' hypotheses: the completeness half's
provider agreement `hcharK` + `semantic_prior_UZ`/`SZ` (⇐), and the soundness half's provider
realization/exclusion obligations `hreal`/`hexcl`/`hexclExt` (⇒). This mirrors the k=2 assembly
`bracketEndChar_kvE2_correct_two_prior_frag` (`OuterGate.lean:359`), which likewise carries
`P`/`h_UZ`/`h_SZ`/`hrealI`/`hrealB`/`hexcl`/`hexclExt`.

**Shape note (the Phase 6 ∀-`k` open frontier).** This step biconditional is provider-OBLIGATION
carrying. The frozen `InteriorGateTarget` (`BracketCarrierCorrectVPrior`, `PriorInterface.lean:60`) is
the CLEAN, obligation-FREE biconditional. Per finding F1 (`bracketEndChar_kv_factors`,
`CarrierKv.lean:422`) the clean biconditional is REFUTED at `k ≥ 2` (the lossy fold determines
`.holds` but not the realizer), and even at `k = 2` only the obligation-carrying fragment
`_correct_two_prior_frag` exists — never a clean `BracketCarrierCorrectVPrior` instance. Assembling
the ∀-`k` `InteriorGateTarget` deliverable by `Nat.rec` would require DISCHARGING `hreal`/`hexcl`/
`hexclExt` from `.holds` + `P` alone, which the F1 loss forbids (`hexclExt` is the exterior-arrangement
/ Lemma 7.6 adjacency residue, the exterior-bracket layer — a task-355 NON-goal). This step
biconditional is the green terminus of the interior-gate construction; the ∀-`k` clean close is the
documented construction gap. -/

set_option maxHeartbeats 1600000 in
/-- **k→k+1 step biconditional** (task 355 Phase 6). `⟨sound (Phase 5), complete (Phase 4)⟩` at
    symbolic `k+1`, carrying the union of both halves' hypotheses. Mirrors the k=2 assembly
    `bracketEndChar_kvE2_correct_two_prior_frag`. Provider-obligation carrying (`hreal`/`hexcl`/
    `hexclExt`), NOT the clean obligation-free `InteriorGateTarget` shape (F1-refuted at `k ≥ 2`; see
    the section note). -/
theorem bracketEndChar_kv_step_correct {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (P : ExistProviders sig atomMap k)
    (hcharK : charF k = fun χ => P.existF 0 χ)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kv atomMap h_surj charF (k + 1) qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  ⟨bracketEndChar_kv_step_sound atomMap h_surj charF qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t hreal hexcl hexclExt,
    bracketEndChar_kv_step_complete atomMap h_surj charF P hcharK qnf h_xy h_yt M h_UZ h_SZ x t⟩

end

end Bimodal.Metalogic.WeakCanonical.Kamp
