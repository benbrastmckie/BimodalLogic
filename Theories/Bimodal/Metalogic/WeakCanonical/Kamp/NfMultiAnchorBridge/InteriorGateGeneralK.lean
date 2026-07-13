import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketK

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
open Bimodal.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula formula_conjList)

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

end

end Bimodal.Metalogic.WeakCanonical.Kamp
