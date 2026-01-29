-- Aggregator for all Bimodal example modules
-- Note: ModalProofs, ModalProofStrategies, TemporalProofs moved to Boneyard/Examples/
-- by Task 760 (2026-01-29) to reduce sorry count in main codebase.
import Bimodal.Examples.TemporalProofStrategies
import Bimodal.Examples.BimodalProofs
import Bimodal.Examples.BimodalProofStrategies
import Bimodal.Examples.TemporalStructures

/-!
# Bimodal Examples

This module aggregates all pedagogical examples demonstrating the Bimodal logic library.

## Modules

Active modules:
- `Bimodal.Examples.TemporalProofStrategies` - Temporal proof strategies
- `Bimodal.Examples.BimodalProofs` - Combined modal-temporal proofs
- `Bimodal.Examples.BimodalProofStrategies` - Bimodal proof strategies
- `Bimodal.Examples.TemporalStructures` - Temporal structure examples

Archived to Boneyard/Examples/ (Task 760):
- `Bimodal.Boneyard.Examples.ModalProofs` - S5 modal logic proof examples (5 sorries)
- `Bimodal.Boneyard.Examples.ModalProofStrategies` - Modal proof strategies (5 sorries)
- `Bimodal.Boneyard.Examples.TemporalProofs` - Temporal logic proof examples (2 sorries)

## Usage

Import the entire examples collection:
```lean
import Bimodal.Examples
```

Or import specific example modules:
```lean
import Bimodal.Examples.BimodalProofs
import Bimodal.Examples.TemporalProofStrategies
```

## Learning Path

1. Start with `BimodalProofs` for combined modal-temporal logic
2. Learn strategies in `BimodalProofStrategies`
3. Explore temporal patterns in `TemporalProofStrategies`
4. See temporal structures in `TemporalStructures`

For basic modal/temporal examples with exercises, see Boneyard/Examples/.

## Origin

These examples were originally in `Archive/` and have been moved to
be co-located with the Bimodal library following Lean 4/Mathlib conventions.

## References

Active:
* [TemporalProofStrategies.lean](Examples/TemporalProofStrategies.lean) - Temporal strategies
* [BimodalProofs.lean](Examples/BimodalProofs.lean) - Combined proofs
* [BimodalProofStrategies.lean](Examples/BimodalProofStrategies.lean) - Bimodal strategies
* [TemporalStructures.lean](Examples/TemporalStructures.lean) - Temporal structure examples

Archived (Boneyard/Examples/):
* [ModalProofs.lean](../Boneyard/Examples/ModalProofs.lean) - S5 modal proofs (exercises)
* [ModalProofStrategies.lean](../Boneyard/Examples/ModalProofStrategies.lean) - Modal strategies (exercises)
* [TemporalProofs.lean](../Boneyard/Examples/TemporalProofs.lean) - Temporal proofs (exercises)
-/
