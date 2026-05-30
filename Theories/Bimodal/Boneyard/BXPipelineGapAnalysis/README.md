# BXPipelineGapAnalysis -- Archived Dead Code

BX pipeline gap analysis files, archived by task 225 (2026-05-30).

## Why Archived

The BX pipeline attempted to prove `IsSuccArchimedean` for the chronicle limit
domain via gap elimination. The root dependency `no_gaps_faithful`
(ReynoldsModelSurgery.lean) is **provably false**: the Z+Z counterexample (two
copies of Z with constant MCS at every point) satisfies all `PriorModelData`
hypotheses yet has a Dedekind gap.

The entire downstream chain is permanently dead:

    no_gaps_faithful -> prior_model_is_succ_archimedean
      -> succ_cofinal -> limitDomSubtype_isSuccArchimedean
      -> succ_embed_surjective -> dd_countermodel_chronicle_discrete
      -> bx_completeness

The correct path to sorry-free `completeness_discrete` is the **Reynolds
pipeline** via `no_gaps_discrete` (task 202).

## File Inventory

| File | Lines | Original Location | Description |
|------|------:|-------------------|-------------|
| ChronicleNoGaps.lean | 165 | Metalogic/WeakCanonical/ | Chronicle-level gap elimination attempt (Reynolds Thm 14 adapted). Contains `gap_of_not_succ_archimedean_local` (local copy to avoid import cycles) and gap boundary properties. |
| HenkinDiscreteChain.lean | 121 | Metalogic/BXCanonical/Chronicle/ | Analysis of Henkin chain approaches (Plans v1-v3 all failed). Contains sorry-free infrastructure lemmas `g_content_consistent` and `h_content_consistent`. |

## Relationship to Active Code

- `no_gaps_faithful` and `prior_model_is_succ_archimedean` remain in
  ReynoldsModelSurgery.lean with deprecation annotations (interleaved with
  active Reynolds pipeline code).
- `succ_cofinal` and `limitDomSubtype_isSuccArchimedean` remain in
  ChronicleToCountermodel.lean with deprecation annotations.
- `countermodel_discrete` remains in Transfer.lean with deprecation annotation.
- All retained definitions are marked `DEPRECATED: BX Pipeline Dead Code`.

## Recovery

```bash
git log --follow --oneline Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/ChronicleNoGaps.lean
git log --follow --oneline Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/HenkinDiscreteChain.lean
```
