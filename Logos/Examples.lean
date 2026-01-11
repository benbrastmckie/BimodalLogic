import Bimodal.Examples

/-!
# Logos Examples Aggregator

Imports examples from all Logos layers.

## Current Examples

- `Bimodal.Examples` - TM Logic (Layer 0) examples
  - Modal proof examples (S5 logic)
  - Temporal proof examples (linear temporal logic)
  - Bimodal proof examples (perpetuity principles)
  - Proof strategy tutorials

## Future Layer Examples

- `Logos.Explanatory.Examples` (Layer 1) - Causal reasoning examples
- `Logos.Epistemic.Examples` (Layer 2) - Knowledge reasoning examples
- `Logos.Normative.Examples` (Layer 3) - Normative reasoning examples

## Usage

Import all examples:
```lean
import Logos.Examples
```

Import specific example categories:
```lean
import Bimodal.Examples.ModalProofs
import Bimodal.Examples.TemporalProofs
import Bimodal.Examples.BimodalProofs
```
-/

namespace Logos.Examples
-- Intentionally empty: importing this module provides the example namespaces.
-- Examples are now provided via Bimodal.Examples.
end Logos.Examples
