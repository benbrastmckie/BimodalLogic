-- Re-export from Boneyard for backwards compatibility during transition
import Bimodal.Boneyard.Metalogic.Soundness.SoundnessLemmas
import Bimodal.Boneyard.Metalogic.Soundness.Soundness
import Bimodal.Boneyard.Metalogic.Completeness
import Bimodal.Boneyard.Metalogic.Completeness.CompletenessTheorem
import Bimodal.Boneyard.Metalogic.Decidability
import Bimodal.Boneyard.Metalogic.Representation.ContextProvability
import Bimodal.Boneyard.Metalogic.Core.Provability
import Bimodal.Boneyard.Metalogic.Applications.Compactness

/-!
# DEPRECATED: Bimodal.Metalogic

This module has been moved to `Bimodal.Boneyard.Metalogic/` as part of the
Metalogic_v2 migration (Task 618).

**Migration Guide**:
- For soundness: Use `Bimodal.Metalogic_v2.Soundness.Soundness`
- For completeness: Use `Bimodal.Metalogic_v2.Completeness.StrongCompleteness`
- For decidability: Use `Bimodal.Metalogic_v2.Decidability.DecisionProcedure`
- For deduction theorem: Use `Bimodal.Metalogic_v2.Core.DeductionTheorem`

The old implementation is preserved in `Bimodal.Boneyard.Metalogic/` for
reference purposes.

## Metalogic_v2 Main Modules

| Old Import | New Import |
|------------|------------|
| `Bimodal.Metalogic.Soundness` | `Bimodal.Metalogic_v2.Soundness.Soundness` |
| `Bimodal.Metalogic.Completeness` | `Bimodal.Metalogic_v2.Completeness.StrongCompleteness` |
| `Bimodal.Metalogic.DeductionTheorem` | `Bimodal.Metalogic_v2.Core.DeductionTheorem` |
| `Bimodal.Metalogic.Decidability` | `Bimodal.Metalogic_v2.Decidability.DecisionProcedure` |
-/
