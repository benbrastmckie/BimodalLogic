/-
Consumption walk: which expressive-completeness route does the live critical path
actually consume, and what does `no_gaps_discrete_model_surgery` depend on?

Answers, per the sizing brief:
  C1. Does `completeness_discrete` reach `US_expressively_complete_over_prior`?
  C2. Does `no_gaps_discrete_model_surgery` reach `US_expressively_complete_over_prior`?
  C3. (moved) The `US_expressively_complete_over_Z` route is BIT-ROTTED: its dependency
      `Separation.SeparationThm` fails to compile and the subtree is unreachable from the
      `Bimodal` root, so it cannot be imported here at all.
  C4. Which chain members carry `sorryAx`?
-/

import Bimodal.Metalogic.BXCanonical.Completeness
import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery
import Bimodal.Metalogic.WeakCanonical.PriorExpressiveness
import Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior

open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Kamp

namespace Probe379B

open Lean in
partial def tdeps (env : Environment) (start : Name) : NameSet := Id.run do
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
  let roots : List Name :=
    [`Bimodal.Metalogic.BXCanonical.completeness_discrete,
     ``no_gaps_discrete_model_surgery]
  let targets : List Name :=
    [``US_expressively_complete_over_prior,
     ``kamp_prior_expressive_completeness,
     ``nf_characterizable_temporal_prior,
     ``nf_nvar_exist_all_depths,
     ``nf_eval_nf,
     ``NormalForm]
  for r in roots do
    if (env.find? r).isNone then
      logError s!"ROOT NOT FOUND: {r}"
    else
      let d := tdeps env r
      logInfo s!"--- root: {r}  (deps: {d.toList.length}) ---"
      for t in targets do
        logInfo s!"    reaches {t} : {d.contains t}"

end Probe379B

#print axioms Bimodal.Metalogic.WeakCanonical.no_gaps_discrete_model_surgery
#print axioms Bimodal.Metalogic.WeakCanonical.Kamp.nf_characterizable_temporal_prior
