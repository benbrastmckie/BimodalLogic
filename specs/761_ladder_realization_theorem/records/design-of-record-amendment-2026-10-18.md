# Design-of-Record Amendment — Durable Copy

`specs/archive/` is gitignored (`.gitignore:94`), so the two `**Amended by**` paragraphs this
round added to the design of record
(`specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`, Sections A and
C) are reproduced here verbatim, inside the tracked task directory, so the amendment survives a
fresh clone. The archived file is NOT read-only by convention — the fallback this plan's Phase 1
named was for a read-only path — and it carries both paragraphs on disk; this copy exists for
durability only, and the archived file remains the amended record.

## Section A amendment (as written into the archived file)

**Amended by** `specs/761_ladder_realization_theorem/plans/01_ladder-realization-presentation-a.md`,
2026-10-18: the statement line of H4's realization theorem is the FIBRE EQUATION over `Dmax`, the
maximum `certAdm`-certified subset of `Q × ClType φ × K` — `cellAt (ladderModel …) φ (t, ⟨(q, c, n),
h⟩) z = {T | ∃ S : ClType φ, typeOfCl S = T ∧ (q, S, κ (c, n)) ∈ Dmax …}`. The `HitCl … = ↑(hitOf
(truncate B …) … (clNow φ) k)` form this section's successor paragraph anticipated is WITHDRAWN:
`truncate` is defined nowhere, its only reading is the index `Q × Fin (B+1) × Fin (B+1)`, and that
index is refuted (`ladder-cell-index-obstructions.lean`: `exhibited_form_refuted`,
`exists_form_refuted`, `cell_succ_ne`). No substitute index replaces it: `K` is a CARRIER
coordinate, the set-valued datum `Dmax` is what factors the cell, and the finiteness the statement
needs is finiteness of `Q × ClType φ × K` — a Finset — not of the ladder carrier, which stays
infinite (`Rlad_slice_infinite`). The forward-only reading this section's guardrail (e) demanded is
machine-checked (`ladder-liveness-forward-only.lean`: `gPast_isPath`, `gPast_pending_past`,
`gPast_count`): a ladder bundle replaces `ulive` only and retains `slive`.

## Section C amendment (as written into the archived file)

**Amended by** `specs/761_ladder_realization_theorem/plans/01_ladder-realization-presentation-a.md`,
2026-10-18: the factorization lemma for the counter quotient `K` — `cellAt_const_of_kappa_eq`, cells
agree on counter-class-equal states — is a COROLLARY of the two obligations (S) `ladderSound` and
(C') `ladderLift`, never a hypothesis of either and never an index claim. Stating it as a
hypothesis is exactly the refuted move: `K` does not factor `cellAt` on its own, `Dmax` does. This
section's assignment of the `box`/`stab`-bearing half of (S) to (W) stands and no standalone (S)
record is filed; the acceptance clause lands instead inside the realization statement, `box` as one
global bit (`box_mem_tpOf_iff`) and `stab` per `(q, κ)` (`stab_mem_tpOf_iff` is per cell, so the
probe's fibre over `q` alone is the wrong granularity — `cell_ne`). The completeness clause must
PUMP: the positionwise shape is refuted for every finite counter quotient and every `κ`
(`counter-lift-gates.lean`: `no_positionwise_lift`), so narrowing to it would be a false statement,
not a weaker one.
