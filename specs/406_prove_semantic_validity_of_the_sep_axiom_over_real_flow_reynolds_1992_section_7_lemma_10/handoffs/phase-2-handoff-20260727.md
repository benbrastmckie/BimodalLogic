# Phase 2 Handoff (task 406)

- **Next action**: Phase 3 — add the `Separability` import to `Soundness.lean`, replace the two
  `sorry` bodies from report §7.4, then the docstring/comment cleanup of §7.5 and the
  `SoundnessLemmas/README.md` row.
- **State**: `Separability.lean` now 346 lines; `nested_core`, `sep_order`, `sep_order_mirror`
  appended verbatim from report §7.3. Scoped build EXIT=0, no warnings, no sorry, no task refs.
- **Key decisions**: `sep_order_mirror` instantiates `sep_order` at `Dᵒᵈ` with explicit
  `OrderDual.toDual`/`ofDual` (bare `exact` and the `toDual_lt_toDual` rewrite fail).
- **Deviations**: plan's Phase 2 verification bullet claiming zero `simp` in the core overstates
  report §7.3 (two `simp_all` in `nested_core`'s induction base cases); annotated inline in the
  plan, text kept verbatim.
