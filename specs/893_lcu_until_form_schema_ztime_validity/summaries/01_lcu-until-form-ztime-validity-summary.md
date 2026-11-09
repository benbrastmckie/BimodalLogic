# Implementation Summary: Task #893

- **Task**: 893 - Declare the until-form limit-closure schema LCU and its mirror, with ZTime validity
- **Status**: [COMPLETED]
- **Started**: 2026-11-09T10:34:00Z
- **Completed**: 2026-11-09T11:20:00Z
- **Effort**: ~45 minutes (plan estimated 4.5 hours; the mathematical content was transcribed from a pre-verified probe)
- **Dependencies**: None
- **Artifacts**: plans/01_lcu-until-form-ztime-validity.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`lcU` — the until-form limit-closure schema `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))` — is
now declared in `FormalSystem/PlusLanguage/PlusLCSchema.lean` beside `lcN`, with its validity over
the `ℤ` fibre and at the `.ZTime` frame class proved by instantiating `omega_chain`, and with the
backward schema stated as the `plusValidIn_reflectTime` corollary. One new helper,
`int_marker_bracket`, supplies the consecutive marker pair straddling an arbitrary time, which is
what an until-witness needs and what `int_marker_exists_gt` cannot give. Every prose surface that
asserted `LCU` was undeclared is repaired, the four declarations are indexed and axiom-pinned, and
the complete gate set is green.

No completeness or derivability claim is made anywhere: not that `lcU` is a TM⁺ theorem, not that
TM⁺ extended by it is complete, not that `lcU` follows from `lcN` or `lcN` from `lcU`. `.Base`
validity is recorded as open and unclaimed, with the cofinality obstruction named at every surface
that states it.

## What Changed

- `FormalSystem/PlusLanguage/PlusOmegaChain.lean` — added `theorem int_marker_bracket {c : ℕ → ℤ} (hc : ∀ k, c k < c (k + 1)) {s : ℤ} (h0 : c 0 ≤ s) : ∃ k, c k ≤ s ∧ s < c (k + 1)` in the `ℤ`-discharge section after `int_marker_exists_gt`, with its `## Main Results` entry; repaired `stg_step`'s docstring, which claimed every current consumer instantiates the segment property `P` trivially, and extended its "Why `P` is carried at all" paragraph with the interval-endpoint discipline a consumer must observe (a consumer's content window must sit inside the half-open `(s, s']` agreement window `hP` offers, so an `untl`-sourced guard is open on the right). 404 → 448 lines.
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` — added `def lcU (α β : PlusFormula) : PlusFormula`, and `theorem lcU_plusValidInt`, `lcU_plusValidZTime`, `lcU_reflectTime_plusValidZTime`; extended the module docstring's `## Main Definitions` and `## Main Results`; repaired the `## LCU, and the relation to blc` section and `lcN`'s own docstring. 338 → 490 lines.
- `docs/theorem-index.md` — four new rows (`int_marker_bracket` with its `PlusOmegaChain.lean` siblings, the three `lcU_*` rows after the `lcN` rows), each with `Axioms` cell `pcq pinned:C14`; the `lcN_plusValidZTime` row's undeclared-ness clause removed with the not-an-instance and neither-subsumes-the-other distinctions kept.
- `scripts/check-module-invariants.sh` — four `#print axioms` lines at the tail of the `PlusLanguage` block in the `C14LEAN` heredoc and four matching baseline lines in the same position in `C14BASE`, in the same order.
- `FormalSystem/PlusLanguage/README.md` — `PlusLCSchema.lean` inventory Description cell edited by hand to add `lcU` and the three theorem names; line counts regenerated.
- `README.md`, `typst/generated/status.typ` — regenerated line-count surfaces (`formalsystem-line-count` 394424 → 394620).

## Decisions

- **The segment property is instantiated on the open interval `(s, s')`, not the half-open `(s, s']` the task description named.** The half-open reading is not derivable from the antecedent: the `untl` clause carries `⟐α`, rather than `⟐β`, at the right endpoint. The open content window sits strictly inside `hP`'s half-open agreement window, so `hP` discharges by state-locality of `⟐`, and the open reading is simultaneously what is provable and what the consequent needs. The research report had already established this; it is recorded here because it is the one piece of the construction that is not a transcription, and it is now documented at both `stg_step` and `lcU_plusValidInt`.
- **`int_marker_bracket` is stated at `ℤ`, not at `F.Duration`**, for the reason `int_marker_exists_gt`'s docstring already gives: `omega` reads the syntactic type of a hypothesis and does not see through `↑intOrder = ℤ`. It transports to `c : ℕ → F.Duration` by defeq at the application site.
- **The axiom profile was measured, never inferred.** All four new declarations carry `[propext, Classical.choice, Quot.sound]`, while `int_marker_bracket`'s three siblings in the same `PlusOmegaChain.lean` section carry the shorter `[propext, Quot.sound]` — so the uniform profile is a fact about these four, not a pattern. The literal `#print axioms` output from Phases 1 and 2 is what went into the C14 baseline.
- **Display name versus Lean identifier.** The prose surfaces keep `LCU` as the schema's display name and use `lcU` for the Lean identifier, matching how `LC_n`/`lcN` are already written in the same files.

## Plan Deviations

- **Phase 2 verification criterion** altered: `grep -c "sorry" FormalSystem/PlusLanguage/PlusLCSchema.lean` returns 0 is unsatisfiable as written and was already false at the pre-task commit — the module docstring's line 32 carries the prose phrase "`sorry`-free". Discharged with the substantive check instead: `bash .claude/scripts/lean-sorry-census.sh` over the resolved source roots reports `sorry_count: 0`, and the full `lake build` emitted zero `declaration uses 'sorry'` warnings. Annotated inline on the plan's own checklist item. No implementation step was skipped, altered or deferred.

## Verification

- Build: **Success**. Full `lake build` through `lake-build-guard.sh`, exit 0, 2966 jobs, zero `error:` and zero `warning:` lines (CI builds with `--wfail`, so warnings were treated as failures). Both touched modules' `.olean` files are newer than their sources.
- Sorry count: **0** (`lean-sorry-census.sh` over `FormalSystem`, `Tests/BimodalTest`, `BimodalTools` and their aggregators).
- Vacuous count: **1**, pre-existing and untouched — `FormalSystem/Examples/TemporalStructures.lean:495`'s `int_domain_universal ... := trivial`, present identically at the pre-task commit and in a file this task does not modify. Zero introduced by this task.
- Axiom count: **14**, unchanged from the pre-task commit. No `axiom` declaration was added.
- Axiom profiles: `int_marker_bracket`, `lcU_plusValidInt`, `lcU_plusValidZTime` and `lcU_reflectTime_plusValidZTime` each print `[propext, Classical.choice, Quot.sound]`, and `check-module-invariants.sh`'s C14 confirms all four against the baseline with no HARD STOP.
- Gates: `check-module-invariants.sh` exit 0 (**ALL CHECKS PASSED**; C14 PASS on both assertions, C15 PASS over 436 rows, C21/C26/C33 PASS, the `FAIL INV` stale-inventory deferral closed); `check-module-invariants.sh --emit-inventory --check` exit 0; `typst-sync-check.sh` full exit 0 (all 4 checks); `check-metalogic-cycles.sh` exit 0; `verify-deploy.sh --findings --skip-slow` exit 0 with one standing WARN-FINDING (`gate16 lean still declares routing_hard/routing_agents_hard`) that names no file this task touched.
- Plan compliance: `lean-plan-compliance-check.sh` reports `COMPLIANCE_CHECK: failed`, driven entirely by two harvested tokens that are not Lean declarations — `C14` (a gate identifier) and `LCU` (the schema's prose display name, whose Lean identifier `lcU` is reported `[OK]`). All four identifiers the plan's `## Lean Challenge Statements` block names are reported `[OK]`. The verdict is recorded as measured; the plan's Goals prose was deliberately not edited to make the harvest pass.
- Tests: N/A — this task adds no test; the library build covers the new declarations.
- Files verified: Yes.
- Batch gate deferral: not used. The dispatch permitted discharging Phase 4's `full` tier against a scoped subset with the complete set deferred to the batch stage; the complete set was instead run independently and in full in this dispatch.

## Impacts

- `lcU` and its three validity theorems are now available to the completeness programme: this is the limit-closure principle the Reynolds ban-preservation lemma consumes for the L⁺ language with `untl` and `snce` primitive, which `lcN` (the `F`-form) cannot supply because it discharges no segment guard.
- `int_marker_bracket` is available to any future consumer needing the marker pair straddling a time rather than a marker beyond it.
- `omega_chain`'s segment-property parameter `P` now has a realised consumer, and the endpoint discipline a consumer must observe is documented at `stg_step` rather than having to be rediscovered.
- `check-module-invariants.sh`'s C14 baseline grew by four pinned declarations; `docs/theorem-index.md` grew by four rows (432 → 436 anchored rows).

## Follow-ups

- `.Base` validity of `lcU` is open. It is blocked on the same single obstruction as `lcN`'s: `omega_chain`'s cofinality hypothesis has exactly one discharge in this tree, `intOrder_omega_cofinal`, available over `ℤ` alone.
- `FormalSystem/PlusLanguage/README.md`'s second, hand-maintained file-purpose table (the one-line description at line 133) names `LC_n` only and does not mention the until-form schema. It asserts no undeclared-ness, so it was not a repair surface and `--emit-inventory --check` reports every hand-maintained block exhaustive; a future editor may wish to widen that one line for accuracy.
- `lean-plan-compliance-check.sh` harvests backticked prose tokens from a plan's Goals block, so a plan whose Goals mention a gate name or a schema's display name reaches a `failed` verdict with every real declaration present. Worth a narrowing of the harvest if this recurs.

## References

- `specs/893_lcu_until_form_schema_ztime_validity/plans/01_lcu-until-form-ztime-validity.md` — the plan executed
- `specs/893_lcu_until_form_schema_ztime_validity/reports/01_lcu-until-form-ztime-validity.md` — the research report, including the eight-slot `omega_chain` instantiation table and the endpoint correction
- `specs/893_lcu_until_form_schema_ztime_validity/probes/01_lcu-ztime-validity.lean` — the pre-verified probe the four declarations were transcribed from
- `specs/893_lcu_until_form_schema_ztime_validity/handoffs/` — per-phase handoffs with each phase's measured verification output
