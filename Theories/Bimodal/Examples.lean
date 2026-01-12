-- Aggregator for all Bimodal example modules
import Bimodal.Examples.ModalProofs
import Bimodal.Examples.ModalProofStrategies
import Bimodal.Examples.TemporalProofs
import Bimodal.Examples.TemporalProofStrategies
import Bimodal.Examples.BimodalProofs
import Bimodal.Examples.BimodalProofStrategies
import Bimodal.Examples.TemporalStructures

/-!
# Bimodal Examples

This module aggregates all pedagogical examples demonstrating the Bimodal logic library.

## Modules

- `Bimodal.Examples.ModalProofs` - S5 modal logic proof examples
- `Bimodal.Examples.ModalProofStrategies` - Modal proof strategies and patterns
- `Bimodal.Examples.TemporalProofs` - Temporal logic proof examples
- `Bimodal.Examples.TemporalProofStrategies` - Temporal proof strategies
- `Bimodal.Examples.BimodalProofs` - Combined modal-temporal proofs
- `Bimodal.Examples.BimodalProofStrategies` - Bimodal proof strategies
- `Bimodal.Examples.TemporalStructures` - Temporal structure examples

## Usage

Import the entire examples collection:
```lean
import Bimodal.Examples
```

Or import specific example modules:
```lean
import Bimodal.Examples.ModalProofs
import Bimodal.Examples.TemporalProofs
```

## Learning Path

1. Start with `ModalProofs` for basic S5 modal logic
2. Learn strategies in `ModalProofStrategies`
3. Explore temporal logic in `TemporalProofs`
4. See combined reasoning in `BimodalProofs`

## Origin

These examples were originally in `Archive/` and have been moved to
be co-located with the Bimodal library following Lean 4/Mathlib conventions.

## References

* [ModalProofs.lean](Examples/ModalProofs.lean) - S5 modal proofs
* [ModalProofStrategies.lean](Examples/ModalProofStrategies.lean) - Modal strategies
* [TemporalProofs.lean](Examples/TemporalProofs.lean) - Temporal proofs
* [TemporalProofStrategies.lean](Examples/TemporalProofStrategies.lean) - Temporal strategies
* [BimodalProofs.lean](Examples/BimodalProofs.lean) - Combined proofs
* [BimodalProofStrategies.lean](Examples/BimodalProofStrategies.lean) - Bimodal strategies
* [TemporalStructures.lean](Examples/TemporalStructures.lean) - Temporal structure examples
-/
