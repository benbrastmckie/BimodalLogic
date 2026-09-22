/-
Probe 03 — the limit-closure schema and the translation product (Q4).

Research probe only (sorry-free, compiled with `lake env lean`); nothing here is proposed for
`FormalSystem/`. Names live in `Probe653`.

The one limit-closure schema in the live tree is `blc p` (`PlusLanguage/PlusLimitClosure.lean`),
valid over every task frame by Zorn plus the Extension Theorem and refuted coarsely on the
paste-closed coarse model `eK` (`Independence/LimitClosureCountermodel.lean`), hence not a Base
theorem of TM⁺ (`plus_incomplete_base`). The product cannot yield it:

* `blc_cRefuted_product` — the lifted coarse model on the product of `EF` still refutes `blc`
  at every lifted history and time (`c_refuted_lift` instantiated);
* `liftK_eK_pasteClosed` — and it is still paste-closed, so all of TM⁺ at Base is sound for it.

Both are one-line instances of landed theorems; the probe records them in the shape the question
asks. What a device that COULD yield `blc` would have to break is stated in the report: it must
not be truth-preserving on paste-closed non-closed bundles, i.e. it must add the limit histories
that the Extension Theorem adds — it must be a completeness construction, not a morphism.
-/

import FormalSystem.Metalogic.Independence.TranslationProductCoarse
import FormalSystem.Metalogic.Independence.LimitClosureCountermodel

namespace Probe653

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Independence

/-- The coarse refutation of `blc` transfers to the recurrence-free, Limit-for-free product of
`EF`: the device preserves the countermodel instead of removing it. -/
theorem blc_cRefuted_product (p : Atom) (τ : WorldHistory EF) (t : ℤ) :
    ¬ CTruthAt (liftK EF.toFibre eK) (liftH EF.toFibre τ 0) t (blc p) :=
  c_refuted_lift EF.toFibre eK τ t (blc p) (blc_cRefuted p τ t)

/-- The lifted coarse model is paste-closed, so TM⁺ at Base is sound for it
(`plus_pcValid_and_reflect_time`): the product keeps every hypothesis the incompleteness
argument needs and removes none. -/
theorem liftK_eK_pasteClosed : (liftK EF.toFibre eK).PasteClosed :=
  pasteClosed_liftK EF.toFibre eK eK_pasteClosed

end Probe653
