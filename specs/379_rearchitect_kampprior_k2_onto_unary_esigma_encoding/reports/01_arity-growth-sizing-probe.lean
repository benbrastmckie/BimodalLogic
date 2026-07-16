/-
Sizing probe for the k>=2 residual: does the arity-4 obligation originate in the
ARMS (verdict (a)) or in the STATEMENTS (verdict (b))?

Three independent machine-checked questions, answered by `rfl` / kernel reduction
and by a proof-term walk. Nothing here is asserted; everything is checked.

Q1. Where does arity growth originate -- the evaluator `nf_eval_nf`, or the
    `NormalForm` TYPE itself?
Q2. At which `k` does arity 4 first arise from the live entry `NormalForm sig k 2`?
Q3. Is `NfEFold` proof-term consumed by `completeness_discrete`, or merely imported?

Run: lake env lean specs/379_.../reports/01_arity-growth-sizing-probe.lean
-/

import Bimodal.Metalogic.BXCanonical.Completeness
import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold
import Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorHrealSupplyK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorGateGeneralK

open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Kamp

namespace Probe379

variable (sig : MonadicSignature)

/-! ## Q1: the arity growth is TYPE-LEVEL, not evaluator-level.

`nf_eval_nf`'s `k+1` case recurses at `(k, n+1)`. The question is whether that is a
free choice of the evaluator (fixable in the arms) or forced by the type it
eliminates. It is forced: the quant-assignment component of `NormalForm sig (k+1) n`
has DOMAIN `NormalForm sig k (n+1)`. An evaluator for that component must evaluate
inhabitants of an arity-`(n+1)` type. There is no arity-preserving alternative. -/

example : NormalForm sig (k + 1) n = ((AtomKind sig n → Bool) × (NormalForm sig k (n + 1) → Bool)) :=
  rfl

/-- The quant-assignment domain at arity `n` is literally the arity-`(n+1)` NF type.
    This is the root: `nf_eval_nf` cannot avoid arity `n+1` because that is the
    domain of the very function it must evaluate. -/
example (nf : NormalForm sig (k + 1) n) : NormalForm sig k (n + 1) → Bool :=
  nf.quant_assgn

/-! ## Q2: arity 4 arises EXACTLY at k = 2, from the live entry at arity 2.

The live entry is `nf_nvar_exist_all_depths ... k 1 _ (sub_nf : NormalForm sig k (1+1))`,
i.e. `NormalForm sig k 2`. Unfold the type. -/

-- k = 0: depth 0 has NO quant layer. Max arity reached = 2.
example : NormalForm sig 0 2 = (AtomKind sig 2 → Bool) := rfl

-- k = 1: one descent. Max arity reached = 3. Arity 4 NEVER arises.
example : NormalForm sig 1 2 = ((AtomKind sig 2 → Bool) × (NormalForm sig 0 3 → Bool)) := rfl
example : NormalForm sig 0 3 = (AtomKind sig 3 → Bool) := rfl

-- k = 2: TWO descents. Arity 4 arises. This is the k>=2 arm boundary.
example : NormalForm sig 2 2 = ((AtomKind sig 2 → Bool) × (NormalForm sig 1 3 → Bool)) := rfl
example : NormalForm sig 1 3 = ((AtomKind sig 3 → Bool) × (NormalForm sig 0 4 → Bool)) := rfl
example : NormalForm sig 0 4 = (AtomKind sig 4 → Bool) := rfl

/-- The arity-4 object is reachable from the k=2 live entry by TYPE unfolding alone,
    with no proof, no arm, and no tactic: peel two quant layers. The `NormalForm sig 2 2`
    entry's quant domain is `NormalForm sig 1 3`, whose quant domain is `NormalForm sig 0 4`. -/
example (sub_nf : NormalForm sig 2 2) (q3 : NormalForm sig 1 3) :
    NormalForm sig 0 4 → Bool :=
  q3.quant_assgn

/-! ## Q2b: the same growth in the EVALUATOR's statement.

`nf_eval_nf M 2 2 env sub_nf` unfolds to a proposition that quantifies over
`NormalForm sig 1 3`, whose evaluation quantifies over `NormalForm sig 0 4` under a
`Fin.cons`-extended environment of arity 4. The arity-4 joint environment is thus
part of the MEANING of the k=2 statement, not of any proof of it. -/

example {M : OrderedMonadicStructure sig} (env : Fin 2 → M.carrier)
    (a2 : AtomKind sig 2 → Bool) (q2 : NormalForm sig 1 3 → Bool) :
    nf_eval_nf M 2 2 env (a2, q2) =
      ((∀ (a : AtomKind sig 2), atom_eval M env a ↔ (a2 a = true)) ∧
       (∀ (sub_nf : NormalForm sig 1 3),
         (∃ (x : M.carrier), nf_eval_nf M 1 3 (Fin.cons x env) sub_nf) ↔ (q2 sub_nf = true))) :=
  rfl

/-- One more descent: the arity-3 evaluation quantifies over an arity-4 environment
    `Fin.cons y (Fin.cons x env) : Fin 4 -> M.carrier`. THIS is the arity-4 joint
    type, and it is produced by `rfl` from the statement. -/
example {M : OrderedMonadicStructure sig} (env3 : Fin 3 → M.carrier)
    (a3 : AtomKind sig 3 → Bool) (q3 : NormalForm sig 0 4 → Bool) :
    nf_eval_nf M 1 3 env3 (a3, q3) =
      ((∀ (a : AtomKind sig 3), atom_eval M env3 a ↔ (a3 a = true)) ∧
       (∀ (sub_nf : NormalForm sig 0 4),
         (∃ (y : M.carrier), nf_eval_nf M 0 4 (Fin.cons y env3) sub_nf) ↔ (q3 sub_nf = true))) :=
  rfl

/-! ## Q2c: NfEFold does NOT grow arity. The cap is a type-level invariant. -/

example : NormalFormEFold sig (k + 1) n = ((AtomKind sig n → Bool) × (EAtomDom sig k n → Bool)) :=
  rfl

/-- The quant domain at arity `n` is `ZoneSpec n × NormalForm sig k 1`: the env arity
    `n` is UNCHANGED and the depth-carrying component is pinned at arity 1. Contrast
    with `NormalForm sig k (n+1)` above. -/
example : EAtomDom sig k n = (ZoneSpec n × NormalForm sig k 1) := rfl

-- At k = 2, arity 2: the deepest env arity is still 2, and the atom is arity 1.
example : NormalFormEFold sig 2 2 = ((AtomKind sig 2 → Bool) × (EAtomDom sig 1 2 → Bool)) := rfl
example : EAtomDom sig 1 2 = (ZoneSpec 2 × NormalForm sig 1 1) := rfl

/-! ## Q3: proof-term walk.

Walk the transitive constant dependencies of `completeness_discrete` and ask:
  (i)  does it reach ANY declaration from `NfEFold.lean`?
  (ii) does it reach `nf_eval_nf` (i.e. is the arity-growing evaluator on the live path)?
Names are compared against the actual environment, not grepped. -/

open Lean in
/-- Transitive constant dependencies of a declaration's value+type. -/
partial def transitiveDeps (env : Environment) (start : Name) : NameSet := Id.run do
  let mut seen : NameSet := {}
  let mut stack : List Name := [start]
  while !stack.isEmpty do
    let n :: rest := stack | break
    stack := rest
    if seen.contains n then continue
    seen := seen.insert n
    match env.find? n with
    | none => continue
    | some ci =>
      let mut cs : NameSet := {}
      cs := ci.type.getUsedConstants.foldl (·.insert ·) cs
      if let some v := ci.value? then
        cs := v.getUsedConstants.foldl (·.insert ·) cs
      stack := cs.toList ++ stack
  return seen

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let root := `Bimodal.Metalogic.BXCanonical.completeness_discrete
  if (env.find? root).isNone then
    logError s!"ROOT NOT FOUND: {root}"
    return
  let deps := transitiveDeps env root
  -- (i) NfEFold declarations reached?
  let efoldNames : List Name :=
    [``NormalFormEFold, ``nf_eval_efold, ``EAtomDom, ``ZoneSpec, ``zoneHolds,
     ``nf_eval_efold_zero_iff, ``nf_eval_nfk_iff_efold, ``nf_eval_nf1_iff_efold,
     ``nf_quant_layer_fold_iff, ``nf_quant_layer_fold_k1_gate, ``efold_of_nf1,
     ``nf_eval_efold_k, ``nfk_dropFresh, ``nfk_zoneSpec]
  let efoldHits := efoldNames.filter (deps.contains ·)
  logInfo s!"[Q3-i] NfEFold decls reached by completeness_discrete: {efoldHits.length} / {efoldNames.length}"
  logInfo s!"[Q3-i] hits: {efoldHits}"
  -- (ii) nf_eval_nf reached?
  logInfo s!"[Q3-ii] nf_eval_nf on live path: {deps.contains ``nf_eval_nf}"
  logInfo s!"[Q3-ii] NormalForm on live path: {deps.contains ``NormalForm}"
  logInfo s!"[Q3-ii] nf_nvar_exist_all_depths on live path: {deps.contains ``nf_nvar_exist_all_depths}"
  logInfo s!"[Q3-ii] kamp_prior_expressive_completeness on live path: {deps.contains ``kamp_prior_expressive_completeness}"
  -- (iii) quarantine stack reached?
  let quarantine : List Name :=
    [``kampPrior_hreal_supply, ``igPtWFib, ``igEpLFib, ``igEpRFib, ``igFoldBitFib]
  let qHits := quarantine.filter (deps.contains ·)
  logInfo s!"[Q3-iii] quarantine-stack decls reached: {qHits.length} / {quarantine.length}; hits: {qHits}"
  logInfo s!"[Q3] total transitive deps: {deps.toList.length}"

/-! ## Q4: axiom status of the chain. -/

#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete
#print axioms Bimodal.Metalogic.WeakCanonical.Kamp.nf_nvar_exist_all_depths
#print axioms Bimodal.Metalogic.WeakCanonical.Kamp.kamp_prior_expressive_completeness
#print axioms Bimodal.Metalogic.WeakCanonical.US_expressively_complete_over_prior
#print axioms Bimodal.Metalogic.WeakCanonical.Kamp.nf_eval_efold
#print axioms Bimodal.Metalogic.WeakCanonical.Kamp.nf_eval_nfk_iff_efold

end Probe379
