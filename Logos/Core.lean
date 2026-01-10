-- Backwards compatibility: re-export Bimodal as Logos.Core
import Bimodal

/-!
# Logos Core Layer (Backwards Compatibility)

**Note**: The core TM logic implementation has been moved to the `Bimodal` library.
This module provides backwards compatibility by re-exporting Bimodal.

## Migration Guide

Old imports:
```lean
import Logos.Core
import Bimodal.Syntax.Formula
```

New imports:
```lean
import Bimodal
import Bimodal.Syntax.Formula
```

## See Also

- `Bimodal` - The standalone bimodal TM logic library
-/
