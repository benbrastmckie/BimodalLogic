/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.SubformulaClosure.Closure
import FormalSystem.Syntax.SubformulaClosure.NestingDepth
import FormalSystem.Syntax.SubformulaClosure.TemporalFormulas
import FormalSystem.Syntax.SubformulaClosure.IteratedTemporal

/-!
# `FormalSystem.Syntax.SubformulaClosure` — the subformula closure as a `Finset`

Sibling aggregator for `FormalSystem/Syntax/SubformulaClosure/`. Everything here is pure
syntax: the finite set of subformulas of a formula, the nesting-depth measures on it, the
temporal classification of its members, and the iterated temporal operators that escape it.
Nothing in this component mentions maximal consistent sets, derivability, frame classes, or
the `Succ` relation — those consumers live in `Metalogic/Core/RestrictedMCS/` and
`Metalogic/Decidability/FMP/`.

## Modules

- `SubformulaClosure.Closure` — `subformulaClosure` (the `Finset Formula` of all subformulas),
  `closureWithNeg`, diamond detection and diamond subformulas, and the membership lemmas
- `SubformulaClosure.NestingDepth` — `fNestingDepth`/`pNestingDepth`, the maximum F/P-nesting
  depth within a closure set, and F/P inner-formula extraction
- `SubformulaClosure.TemporalFormulas` — future/past formula extraction, the Until/Since
  deferral infrastructure, seriality formulas, the temporal blocking set, and `deferralClosure`
  with its F/P-depth bounds
- `SubformulaClosure.IteratedTemporal` — `iterF`/`iterP`, their complexity, injectivity and
  nesting-depth lemmas, and the `closureFBound`/`closurePBound` closure-escape results

## Related

- `FormalSystem/Syntax/Subformulas.lean` — the `List`-based `Formula.subformulas` this component
  converts to a `Finset`
-/
