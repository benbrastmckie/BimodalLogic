# Phase 5 handoff — `prop:nomic-tense-free` and the S5 schemata on the fragment

- **Next action**: Phase 6 (`NomicValidity.lean`).
- **State**: `FormalSystem/NomicLanguage/NomicTenseFree.lean` landed: `TenseFree`, `nomicSatSet`
  (total, ignoring-set clause shared by `box` and `nomic`, `∅` at the two temporal clauses), the
  bridge `tenseFree_satSet_iff` for an arbitrary bare `τ`, `nomic_iff_box_tenseFree`, and the five
  S5 schemata. An `example` pins `nomicSatSet V (.nomic φ) = nomicSatSet V (.box φ)` as `rfl`.
  Build exit 0, zero warnings, zero sorry; no `:= True|Unit|trivial` clause anywhere.
- **Decisions**: the five schemata are each proved by reading the bridge at the relevant compound
  rather than by routing through `nomic_iff_box_tenseFree` and a box lemma — the box clause alone
  cannot deliver T at a bare `τ`, since `τ ∈ H_F` is not available at the truth level.
- **Deviations**: none in decomposition; the proof route above is the plan's "one line each from
  the collapse" step taken through the bridge the collapse itself is built from.
