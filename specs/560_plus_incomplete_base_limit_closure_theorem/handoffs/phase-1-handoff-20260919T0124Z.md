# Phase 1 handoff (task 560)

- Done: `FormalSystem/Metalogic/Independence/PastedCoarseModels.lean` landed, registered, inventory regenerated; module + `FormalSystem` build green, zero warnings; axioms of `not_plusDerivable_of_pcRefuted` = [propext, Classical.choice, Quot.sound].
- Names (consumed by Phase 4): `CoarseModel.PasteClosed` (dot notation `K.PasteClosed`), `c_truth_congr_from`, `c_truth_congr_upTo`, `c_paste`, `c_paste'`, `c_untl_paste`, `c_snce_paste`, `PCValid`, `plusAxiom_pcValid`, `plus_pcValid_and_reflect_time`, `not_plusDerivable_of_pcRefuted`. Only rename vs probe: `PasteClosed` moved into the `CoarseModel` namespace.
- Note: `--emit-inventory` also rewrites the root `README.md` totals block; stage it each phase.
- Next: Phase 2, `FormalSystem/Semantics/PlusLanguage/PlusLimitClosure.lean` from probe 01.
