import FormalSystem.Semantics
import FormalSystem.NomicLanguage
import FormalSystem.Semantics.ConeUnravelling
set_option maxRecDepth 100000

open Lean
namespace P4

partial def collect (env : Environment) (visited : Std.HashSet Name) (n : Name) :
    Std.HashSet Name :=
  if visited.contains n then visited
  else
    let visited := visited.insert n
    match env.find? n with
    | none => visited
    | some ci =>
      let deps := (ci.type.getUsedConstants
        ++ (ci.value? (allowOpaque := true) |>.map Expr.getUsedConstants).getD #[])
      deps.foldl (fun acc d => collect env acc d) visited

def fieldSets : List (String × List Name) :=
  [ ("Comp",  [`FormalSystem.Semantics.FrameOver.comp,
               `FormalSystem.Semantics.FrameOver.IsRegular.comp]),
    ("Ser",   [`FormalSystem.Semantics.FrameOver.serial,
               `FormalSystem.Semantics.FrameOver.IsRegular.serial]),
    ("Lim",   [`FormalSystem.Semantics.FrameOver.limit,
               `FormalSystem.Semantics.FrameOver.IsRegular.limit]),
    ("Sat",   [`FormalSystem.Semantics.FrameOver.saturation,
               `FormalSystem.Semantics.FrameOver.IsRegular.saturation]) ]

def manufacturers : List Name :=
  [ `FormalSystem.Semantics.FrameOver.instIsRegularOfReflective,
    `FormalSystem.Semantics.FrameOver.ofReflectiveRegular ]

def targets : List Name :=
[
  `FormalSystem.NomicLanguage.exists_refutation_of_not_uniform,
  `FormalSystem.Semantics.four_validOn_iff_uniform,
  `FormalSystem.Semantics.nomic_iff_box_validOn_iff_uniform,
  `FormalSystem.Semantics.not_four_nomicValid,
  `FormalSystem.NomicLanguage.tenseFree_satSet_iff,
  `FormalSystem.NomicLanguage.nomic_iff_box_tenseFree,
  `FormalSystem.NomicLanguage.nomic_k_tenseFree,
  `FormalSystem.NomicLanguage.nomic_t_tenseFree,
  `FormalSystem.NomicLanguage.nomic_four_tenseFree,
  `FormalSystem.NomicLanguage.nomic_five_tenseFree,
  `FormalSystem.NomicLanguage.nomic_b_tenseFree,
  `FormalSystem.Semantics.nomic_serial,
  `FormalSystem.Semantics.base_taskRel_eq_ofStepRel,
  `FormalSystem.Semantics.coneFrame,
  `FormalSystem.Semantics.coneF_twoWayBounded,
  `FormalSystem.Semantics.exists_coneUnravelling,
  `FormalSystem.Semantics.FrameOver.static_of_countable,
  `FormalSystem.Semantics.PartialHistory.completion_of_isRegular,
  `FormalSystem.Semantics.PartialHistory.isTotal_of_isMax,
  `FormalSystem.Semantics.PartialHistory.extension,
  `FormalSystem.Semantics.PartialHistory.isRestriction_of_isRegular,
  `FormalSystem.Semantics.PartialHistory.step,
  `FormalSystem.Semantics.NomicFrame.occurrence,
  `FormalSystem.Semantics.PartialHistory.exists_worldHistory_two_point,
  `FormalSystem.Semantics.NomicFrame.taskRel_imp_of_lawHist_eq,
  `FormalSystem.Semantics.NomicFrame.lawHist_eq_iff_taskRel_eq,
  `FormalSystem.Semantics.NomicFrame.static_iff_taskRel_eq,
  `FormalSystem.Semantics.NomicFrame.exists_mem_HF_eq,
  `FormalSystem.Semantics.NomicFrame.lawHist_nonempty,
  `FormalSystem.Semantics.NomicFrame.uniform_of_transAt,
  `FormalSystem.Semantics.NomicFrame.uniform_of_symmAt,
  `FormalSystem.Semantics.NomicFrame.uniform_of_euclAt,
  `FormalSystem.Semantics.NomicFrame.uniform_iff_taskRel_indep,
  `FormalSystem.Semantics.NomicFrame.nomic_uniform,
  `FormalSystem.Semantics.NomicFrame.transAtState_iff,
  `FormalSystem.Semantics.NomicFrame.uniform_iff_forall_transAtState,
  `FormalSystem.Semantics.NomicHierarchy.F2.lawful,
  `FormalSystem.Semantics.nomic_hierarchy,
  `FormalSystem.Semantics.NomicFrame.ofStepFamily_isRegular,
  `FormalSystem.Semantics.NomicFrame.mem_lawHist_iff_isStepPath,
  `FormalSystem.Semantics.NomicFrame.mem_lawHist_ofStepFamily_iff,
  `FormalSystem.Semantics.NomicFrame.lawHist_mono_of_le,
  `FormalSystem.Semantics.Presheaf.totality_clause,
  `FormalSystem.Semantics.Presheaf.totality_clause_site,
  `FormalSystem.Semantics.Presheaf.directed_gluing_clause,
  `FormalSystem.Semantics.Presheaf.PathHom.id,
  `FormalSystem.Semantics.Presheaf.PathHom.id_len,
  `FormalSystem.Semantics.Presheaf.PathHom.id_comp,
  `FormalSystem.Semantics.Presheaf.PathHom.comp_id,
  `FormalSystem.Semantics.Presheaf.PathCat.instCategory,
  `FormalSystem.Semantics.Presheaf.PathCat.len,
  `FormalSystem.Semantics.Presheaf.PathCat.len_map,
  `FormalSystem.Semantics.Presheaf.PathCat.len_isDiscreteConduche,
  `FormalSystem.Semantics.Presheaf.Beh.ofAdjacentWindow,
  `FormalSystem.Semantics.Presheaf.Beh.ofAdjacentWindow_states,
  `FormalSystem.Semantics.Presheaf.beh_int_iff_adjacent_window,
  `FormalSystem.Semantics.Presheaf.PathHom.toPathAux,
  `FormalSystem.Semantics.Presheaf.PathHom.toPath,
  `FormalSystem.Semantics.Presheaf.PathHom.toPath_length,
  `FormalSystem.Semantics.Presheaf.PathHom.toPath_id,
  `FormalSystem.Semantics.Presheaf.PathHom.toPath_comp,
  `FormalSystem.Semantics.Presheaf.PathHom.ofStep,
  `FormalSystem.Semantics.Presheaf.PathHom.ofPath,
  `FormalSystem.Semantics.Presheaf.PathHom.ofPath_toPath,
  `FormalSystem.Semantics.Presheaf.PathHom.toPath_ofPath,
  `FormalSystem.Semantics.Presheaf.PathHom.pathEquiv,
  `FormalSystem.Semantics.Presheaf.lim_nonempty,
  `FormalSystem.Semantics.TaskFrame.not_validOn_bot ]

end P4

open P4 in
run_cmd do
  let env ← Lean.getEnv
  for (_, ns) in fieldSets do
    for s in ns do
      if (env.find? s).isNone then logError m!"FIELD CONST NOT FOUND: {s}"
  for s in manufacturers do
    if (env.find? s).isNone then logError m!"MANUFACTURER NOT FOUND: {s}"
  for t in targets do
    match env.find? t with
    | none => logError m!"TARGET NOT FOUND: {t}"
    | some ci =>
      let cl := collect env {} t
      let own := (ci.type.getUsedConstants
        ++ (ci.value? (allowOpaque := true) |>.map Expr.getUsedConstants).getD #[])
      let ownSet := own.foldl (fun (s : Std.HashSet Name) n => s.insert n) {}
      let mut trans : List String := []
      let mut direct : List String := []
      for (lbl, ns) in fieldSets do
        if ns.any (fun n => cl.contains n) then trans := trans ++ [lbl]
        if ns.any (fun n => ownSet.contains n) then direct := direct ++ [lbl]
      let manu := manufacturers.filter (fun n => cl.contains n)
      logInfo m!"R4\t{t}\t{cl.size}\t{String.intercalate "," trans}\t{String.intercalate "," direct}\t{manu.length}"
