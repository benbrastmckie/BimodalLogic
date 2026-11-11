# Research Report: Task #896

**Task**: 896 - The extended L-plus proof system (TM-plus + axiom set + naming rules) with its ZTime soundness, and the completeness targets as stated Props
**Started**: 2026-11-11T00:05:00Z
**Completed**: 2026-11-11T00:15:00Z
**Effort**: Small-to-medium — one new ~400-line module; every mathematical ingredient already exists and the whole skeleton is verified green
**Dependencies**: Task 895 (COMPLETED — `FormalSystem/Metalogic/AuxiliaryAtoms.lean` landed); Task 893 (`lcU` landed in `FormalSystem/PlusLanguage/PlusLCSchema.lean`)
**Sources/Inputs**:
  - Codebase: `FormalSystem/Metalogic/AuxiliaryAtoms.lean`, `FormalSystem/Metalogic/NamingRules.lean`, `FormalSystem/PlusLanguage/PlusLCSchema.lean`, `FormalSystem/PlusLanguage/Formula.lean`, `FormalSystem/PlusLanguage/PlusReversal.lean`, `FormalSystem/PlusLanguage/PlusValidity.lean`, `FormalSystem/PlusLanguage/PlusTruth.lean`, `FormalSystem/Metalogic/Conservativity/Plus/PlusSoundness.lean`, `FormalSystem/Metalogic/Independence/PlusIncompleteness.lean`, `docs/theorem-index.md`, `docs/development/TESTING_STANDARDS.md`, `scripts/check-module-invariants.sh`, `lakefile.toml`, `Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean`
  - Archived probe: `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/probes/01_target-statements.lean`
  - lean-lsp MCP (`lean_run_code`, `lean_local_search`) — index state: server reachable; all negative findings below were taken by grep sweep over the source tree, not from an empty LSP result
  - No literature source is referenced by this task's description; the Literature Extraction Protocol does not apply. (Reynolds 2001 is the ancestor of the Auxiliary-Atoms rule, but that transposition was completed and recorded by the dependency task; nothing in this task re-reads a source.)
**Artifacts**:
  - `specs/896_lplus_extended_proof_system_and_target_statement/reports/01_lplus-extended-proof-system.md`
  - `specs/896_lplus_extended_proof_system_and_target_statement/probes/01_lcextension-skeleton.lean` (verified-green module skeleton)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The entire module is already verified.** The whole of `FormalSystem/Metalogic/LCExtension.lean` — `RuleSet`, `IsLCAxiom`/`IsLCUAxiom` with their ZTime-validity lemmas, the ten-constructor `ExtDerivation` inductive, `ext_sound_ztime` proved by induction with all nine non-trivial cases closing, the three target Props, and two acceptance `example`s — elaborated green under `lean_run_code` with `import FormalSystem`. The verified text is saved at `specs/896_lplus_extended_proof_system_and_target_statement/probes/01_lcextension-skeleton.lean`. Implementation is transcription plus documentation, not derivation.
- **A sorry-free, axiom-free path exists and was measured.** All five theorems profile at `[propext, Classical.choice, Quot.sound]` — the standard three, the same ceiling as `aa_sound_int` and `clock_irr_sound`. No new axiom cost, no `sorry`, no vacuous definition.
- **Two divergences from the archived 879 probe must be carried.** (1) `lcU` is now library API in `PlusLCSchema.lean` and must **not** be redefined locally. (2) The landed `aaAnte` takes `(qa : ℕ → Atom) (m k : ℕ) (a) (p : ℕ → ℕ → ℕ) (b₀ : ℕ)` — **not** the probe's `(b₀ : Atom) (Q : List Atom) (k) (a) (p : Atom → ℕ → Atom)` — so both naming-rule constructors must be re-encoded. An implementation that transcribes the archived probe verbatim will not compile.
- **The mirror rule's conclusion is `φ.reflectTime`, not `φ`.** `aa_reflectTime_sound_ztime` concludes `PlusValidZTime φ.reflectTime`. Stating `aaBwd` to match (conclusion `φ.reflectTime`, premise `((aaAnte …).imp φ).reflectTime`) gives zero-glue soundness; the archived probe's arbitrary-conclusion form is then derivable inside the module from `PlusFormula.reflect_time_involution` alone, and that derivation is verified as an `example`.
- **Recommended approach**: land the probe's text with repo documentation conventions, plus a companion evidence module `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` pinning the five axiom profiles — and declare the three extra file-scope paths that needs (see Risks).
- **One narrow soundness hazard is worth recording in the module docstring**: `ExtDerivation fc` is parametric in `fc`, but `aaFwd`/`aaBwd` are sound only at `.ZTime`. An optional second theorem `ext_sound_validIn` (class-generic, for `R.aaFwd = R.aaBwd = false`) closes the honesty gap and is also verified green.

## Context & Scope

Researched: what `FormalSystem/Metalogic/LCExtension.lean` must contain, which library declarations supply each ingredient at which exact signature, which of the task description's shapes have drifted since they were proposed, and what the repo's invariant checks require of a new `Metalogic/` module and of new `docs/theorem-index.md` rows.

Constraints honoured: `PlusDerivationTree`, `PlusAxiom` and `PlusFormula` are not modified (standing ruling — nothing in the recommended module touches them; `ExtDerivation` sits strictly on top of `PlusDerivable fc []`). Zero-debt: no `sorry`, no new axiom, no vacuous placeholder. Territory: sibling task 910 is in flight this cycle with `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` and `typst/generated/status.typ` in its declared scope — none of those is in this task's scope and none is needed, so there is no collision.

Not in scope and deliberately not attempted: proving any of the three completeness targets. They are stated as `Prop` definitions with no proof.

## Findings

### Codebase Patterns

**Every ingredient exists, at these exact signatures** (all verified by reading the source, and all consumed successfully in the probe):

| Ingredient | Declaration | File |
|---|---|---|
| TM⁺ theoremhood at `fc` | `PlusDerivable (fc) (Γ) (φ) : Prop := Nonempty (PlusDerivationTree fc Γ φ)` | `PlusLanguage/Derivation.lean` |
| TM⁺ soundness at `.ZTime` | `Conservativity.plus_soundness_ztime : PlusDerivable FrameClass.ZTime [] φ → PlusValidZTime φ` | `Metalogic/Conservativity/Plus/PlusSoundness.lean` |
| TM⁺ soundness, class-generic | `Conservativity.plus_soundness_validIn` | same |
| Freshness | `NamingRules.Fresh (q : Atom) : PlusFormula → Prop` | `Metalogic/NamingRules.lean` |
| Clock antecedent | `NamingRules.clockAnte (q : Atom) : PlusFormula` | same |
| Clock-rule soundness, **class-generic** | `NamingRules.clock_irr_sound (fc) (q) (φ) (hq : Fresh q φ) (hprem : PlusValidIn fc ((clockAnte q).imp φ)) : PlusValidIn fc φ` | same |
| Auxiliary-Atoms antecedent | `AuxiliaryAtoms.aaAnte (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ) : PlusFormula` | `Metalogic/AuxiliaryAtoms.lean` |
| AA rule at `.ZTime` | `AuxiliaryAtoms.aa_sound_ztime` (nine side conditions; see below) | same |
| AA mirror at `.ZTime` | `AuxiliaryAtoms.aa_reflectTime_sound_ztime` — concludes `PlusValidZTime φ.reflectTime` | same |
| `LC_n` and its validity | `lcN`, `lcN_plusValidZTime`, `lcN_reflectTime_plusValidZTime` | `PlusLanguage/PlusLCSchema.lean` |
| `LCU` and its validity | `lcU`, `lcU_plusValidZTime`, `lcU_reflectTime_plusValidZTime` | same |
| Finite conjunction | `bigAnd : ℕ → (ℕ → PlusFormula) → PlusFormula` | same |
| Reflection of validity | `plusValidIn_reflectTime`, `plusValidIn_reflectTime_iff` | `PlusLanguage/PlusReversal.lean` |
| Reflection involution | `PlusFormula.reflect_time_involution` | `PlusLanguage/Formula.lean` |
| `□`/`G` truth clauses | `PlusTruth.box_iff` (`Iff.rfl`), `PlusTruth.allFuture_iff` | `PlusLanguage/PlusTruth.lean` |

`aa_sound_ztime`'s nine side conditions, in order: `hb₀ : b₀ < m`, `hinj` (the `qa` indices below `m` are distinct), `hp` (the machine stays below `m`), `ha` (each `aᵢ` is `StateLocal`), `hexh : PlusValidZTime (bigAnd k fun i => (a i).neg).neg`, `hdisj` (pairwise inconsistency, as validity), `hfresh` (each `qa j` fresh in `φ`), `hfreshA` (each `qa j` fresh in each `aᵢ`), `hprem`.

**No semantic helper lemmas are missing.** `nec` and `tnec` need "validity is closed under `□`" and "under `G`", and neither exists as a named library lemma — a grep sweep for `plusValidIn_box` / `plusValidIn_allFuture` and for `PlusValidIn` applied to `box`/`allFuture` returns nothing. Both are nonetheless two-line inline arguments in the soundness proof (`box_iff` is `Iff.rfl`; `allFuture_iff` is one `rw`), and that is how the verified probe discharges them. Introducing them as named lemmas is optional, not required.

**The repo conventions a new `Metalogic/` module must satisfy**, each confirmed against `scripts/check-module-invariants.sh` and `docs/development/TESTING_STANDARDS.md`:

- **C27**: a live `#print axioms` under `FormalSystem/` must be allow-listed. The only allow-listed file is `FormalSystem/MainResults.lean`, so the axiom-profile pins belong in a `Tests/BimodalTest/` module, exactly as `Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean` does for the dependency. `example`s — including non-vacuity witnesses — may and should stay in the library module.
- **C17** (dead-declaration scan, gated): a base identifier with zero occurrences outside its declaring line is reported. `LCComplete`, `LCRulesComplete` and `LCURulesComplete` have no proof and no consumer by construction, so each must be named somewhere outside its own line — the module docstring's `## Main Results` list plus a `docs/theorem-index.md` row satisfies this, which is what every comparable declaration already does.
- **C14 baseline coupling**: a `docs/theorem-index.md` row carrying a `pinned:C14` cell, or a `## Main Results` bullet in `FormalSystem/Metalogic.lean` that calls a declaration **SORRY-FREE**, both force an edit to `scripts/check-module-invariants.sh`'s `C14_BASELINE`/`C14LEAN` heredocs. The dependency task's rows avoid this: they read a bare `pcq` with the prose "Profiles guarded by `Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean`". Following that precedent keeps this task inside its declared file scope.
- **C36** (non-vacuity with coverage-limit guard) is scoped to `def Certifies`/`def PlusCertifies` under `FormalSystem/Metalogic/Decidability/` only, so it does not reach `ExtComplete`. The obligation's spirit is still met by the two inhabitation `example`s for `IsLCAxiom` and `IsLCUAxiom`.
- **Zero warnings**: the project enables `weak.linter.mathlibStandardSet`. The one warning the probe produced was `linter.style.show` — "use `change` instead" — on the single goal-changing `show` inside the mirror-shape acceptance `example`. Write `change` there.
- Module-header convention (copyright block, `/-!` module docstring with a `## Main Results` list, per-declaration docstrings ending in a `Paper: —` line for formalization-native results): follow `FormalSystem/Metalogic/AuxiliaryAtoms.lean`.
- Imports: `FormalSystem/Metalogic.lean` and `FormalSystem.lean` both list `FormalSystem.Metalogic.AuxiliaryAtoms` explicitly; the new module needs the same two entries, and the new test module needs one in `Tests/BimodalTest.lean` (hand-maintained, not generated).

**Nothing in the tree refutes any of the three targets.** `Metalogic/Independence/PlusIncompleteness.lean` proves TM⁺ incomplete at `.Base` via `blc`, and its own docstring states explicitly that nothing is claimed about any *extension* of the axiom set and nothing is claimed at `.ZTime`. The three Props are therefore genuinely open, which is what the task asks them to be.

### External Resources

No Mathlib search was needed: every ingredient is project-local, and the search decision tree bottoms out at `lean_local_search`/grep on the first step for each. No rate-limited search tool was called, so no rate-limit or MCP-abort recovery was exercised.

### Recommendations

**Module contents, in landing order.** Each item below is present in the verified probe at the stated signature.

1. `structure RuleSet` with `clock aaFwd aaBwd : Bool`, plus `RuleSet.none := ⟨false, false, false⟩` and `RuleSet.all := ⟨true, true, true⟩`.
2. `IsLCAxiom (ψ) : Prop := ∃ n α, 0 < n ∧ (ψ = lcN n α ∨ ψ = (lcN n α).reflectTime)` and `IsLCUAxiom (ψ) : Prop := ∃ α β, ψ = lcU α β ∨ ψ = (lcU α β).reflectTime`. Both reference the library `lcN`/`lcU`; do not redeclare either.
3. `isLCAxiom_plusValidZTime` and `isLCUAxiom_plusValidZTime` — two four-line `obtain`/`▸` proofs off the four existing validity theorems. These are what make the soundness arm concrete rather than only parametric, and they are the discharge of `ext_sound_ztime`'s `hAx` hypothesis.
4. `inductive ExtDerivation (fc : FrameClass) (Ax : PlusFormula → Prop) (R : RuleSet) : PlusFormula → Prop` with ten constructors: `tm` (base: `PlusDerivable fc [] φ`), `ax`, `mp`, `nec`, `tnec`, `refl`, `clock` (gated by `R.clock = true` with `Fresh q φ`), `aaFwd` and `aaBwd` (gated by their flags, in the **landed** `aaAnte` encoding, with `hexh` and `hdisj` carried as recursive `ExtDerivation` premises rather than validity hypotheses).
5. `ext_sound_ztime {Ax R} (hAx : ∀ ψ, Ax ψ → PlusValidZTime ψ) {φ} (d : ExtDerivation FrameClass.ZTime Ax R φ) : PlusValidZTime φ`, by `induction d` — the nine-case proof is in the probe verbatim.
6. `ExtComplete (Ax) (R) : Prop := ∀ φ, PlusValidZTime φ → ExtDerivation FrameClass.ZTime Ax R φ`, then `LCComplete := ExtComplete IsLCAxiom RuleSet.none`, `LCRulesComplete := ExtComplete IsLCAxiom RuleSet.all`, `LCURulesComplete := ExtComplete IsLCUAxiom RuleSet.all`. No proof, no `sorry`.
7. `ext_sound_lc_ztime` and `ext_sound_lcU_ztime` — the two one-line instantiations. These are the declarations that state the soundness half of the three targets outright.
8. Two acceptance `example`s and two non-vacuity `example`s (see the probe): the arbitrary-conclusion mirror shape derived by `reflect_time_involution`, and inhabitation of each axiom predicate.
9. **Optional but recommended**: `ext_sound_validIn {fc} (hFwd : R.aaFwd = false) (hBwd : R.aaBwd = false) (hAx : ∀ ψ, Ax ψ → PlusValidIn fc ψ) : ExtDerivation fc Ax R φ → PlusValidIn fc φ`. Verified green; the two AA cases close by `absurd hR` on the flag equations. It converts the `fc` parameter from a latent trap into a stated fact.

**Sorry-free path**: yes, demonstrated end to end. Nothing in this task needs decomposition, deferral, or an axiom.

**Phase decomposition** (suggested, 2 phases, both independently green):
- Phase 1 — the module: land `FormalSystem/Metalogic/LCExtension.lean` with full docstrings, add the two aggregator imports, build `FormalSystem.Metalogic.LCExtension` scoped through the build guard.
- Phase 2 — the evidence and the ledger: land `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` with the five `#guard_msgs in #print axioms` blocks, wire it into `Tests/BimodalTest.lean`, add the `docs/theorem-index.md` rows, and run the full project plus test library.

## Decisions

- **State `aaBwd` with conclusion `φ.reflectTime` and premise `((aaAnte …).imp φ).reflectTime`**, matching `aa_reflectTime_sound_ztime` exactly, rather than the archived probe's arbitrary-conclusion form. Rationale: zero soundness glue, and the two forms are interderivable — the derivation of the probe's form from this one is a three-line `example` using `PlusFormula.reflect_time_involution`, verified. The reverse choice would put that involution rewriting inside the soundness proof instead, where it buys nothing.
- **Carry `hexh`/`hdisj` as recursive `ExtDerivation` premises, not as `PlusValidZTime` hypotheses.** This keeps `ExtDerivation` a purely proof-theoretic closure (no semantic hypothesis anywhere in the inductive) and the soundness proof's induction hypotheses supply the validity `aa_sound_ztime` wants, at no cost. Verified: the inductive elaborates and `induction` generates usable IHs for the binder-typed recursive arguments.
- **Keep the `fc` parameter on `ExtDerivation`** rather than fixing `.ZTime`, because the `tm` base and the `clock` rule are both genuinely class-generic, and record the narrow hazard (the two AA rules are `.ZTime`-only) in the module docstring, optionally backed by `ext_sound_validIn`.
- **Do not redefine `lcU` locally.** The archived 879 probe did, because `lcU` had not yet landed; it now has, with four validity theorems attached. A local copy would be a silent fork of a library definition.
- **Write the `docs/theorem-index.md` rows with a bare `pcq` Axioms cell plus a "Profiles guarded by `Tests/BimodalTest/Metalogic/LCExtensionTest.lean`" note**, following the dependency's precedent, rather than a `pinned:C14` cell. Rationale: a `pinned:C14` cell requires editing `scripts/check-module-invariants.sh`, which is outside this task's declared file scope, for no gain in strength — a `#guard_msgs` block is build-breaking too.

## Risks & Mitigations

- **Risk: the declared `file_scope` is three paths short.** The task declares `FormalSystem/Metalogic/LCExtension.lean`, `FormalSystem/Metalogic.lean`, `FormalSystem.lean`, `docs/theorem-index.md`. The recommended approach additionally writes `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` and `Tests/BimodalTest.lean`, and (if the optional class-generic theorem is included) nothing further. **Mitigation**: declare the two `Tests/` paths in the plan's territory block. Neither is in any concurrent sibling's scope. If the two `Tests/` paths are judged out of bounds, the fallback is to omit the evidence module and write the theorem-index rows with no axiom claim at all — strictly weaker, and not recommended.
- **Risk: a `pinned:C14` cell or a "SORRY-FREE" bullet in `FormalSystem/Metalogic.lean` silently pulls in `scripts/check-module-invariants.sh`.** **Mitigation**: the Decisions entry above — bare `pcq` cells, and phrase the `Metalogic.lean` mention without the words "sorry-free".
- **Risk: transcribing the archived 879 probe verbatim.** Its two naming-rule constructors use an encoding the landed `aaAnte` does not have, and its local `lcU` now shadows library API. **Mitigation**: implement from `probes/01_lcextension-skeleton.lean`, which is the corrected and verified text; the archived probe is superseded and its header now says so.
- **Risk: C17 flags the three target Props as dead.** **Mitigation**: name all three in the module docstring's `## Main Results` list and in `docs/theorem-index.md`.
- **Risk: a style-linter warning breaks the zero-warning expectation.** Exactly one was observed (`linter.style.show`). **Mitigation**: `change`, not `show`, at the one goal-changing site.
- **Observation, not a risk: olean staleness.** `lean_run_code` reported "Imports are out of date" during the last probe. The cause is sibling task 910's commit `f5473c1ac`, which touched only `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` (confirmed by `git show --stat`) — inside its own declared scope and outside this task's entire dependency chain. The working tree carries no uncommitted `.lean` changes. The probe evidence stands; the implementation phase's first build will simply rebuild that one unrelated module.

## Tactic Survey Results

A tactic survey in the LeanHammer-portfolio sense was not the operative question here — there is no hard proof goal in this task; every arm either instantiates an existing theorem or is a two-line unfolding. What was surveyed instead, and verified, is the one tactic-level question with a real failure mode: whether `induction` works on a `Prop`-valued inductive whose constructors carry recursive arguments **under binders** (`hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' → ExtDerivation …`).

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `ext_sound_ztime`, whole | `induction d with` (10 named cases) | success | all nine non-trivial cases close; binder-typed recursive arguments yield usable function-shaped IHs |
| `tm` case | `exact plus_soundness_ztime h` | success | needs `open FormalSystem.Metalogic.Conservativity` — the identifier is **not** in the `PlusLanguage` namespace |
| `mp` / `nec` cases | bare `exact fun F hF M τ x => …` | success | `PlusValidZTime` unfolds definitionally through `PlusValidIn`/`PlusValidOnFrames`/`PlusValidOn`; no `intro`/`unfold` needed, and `box_iff` is `Iff.rfl` |
| `tnec` case | `intro`; `rw [PlusTruth.allFuture_iff]`; `intro`; `exact` | success | `allFuture_iff` is the only clause lemma needed anywhere in the proof |
| `refl` case | `exact plusValidIn_reflectTime ih` | success | class-generic, no `fc` hypothesis |
| `clock` case | `exact clock_irr_sound _ _ _ hq ih` | success | three `_`s; `hR` unused, as expected for a flag guard |
| `aaFwd` / `aaBwd` cases | `exact aa_sound_ztime …` / `exact aa_reflectTime_sound_ztime …` | success | argument order differs from the constructor's: the two theorems take `hexh`/`hdisj` **before** `hfresh`/`hfreshA` |
| AA cases under `R.aaFwd = false` | `exact absurd hR (by rw [hFwd]; simp)` | success | the `ext_sound_validIn` arm |
| mirror-shape acceptance | `change`/`rwa [PlusFormula.reflect_time_involution]` | success | `show` works but trips `linter.style.show`; use `change` |

`lean_multi_attempt` and `lean_hammer_premise` were not called: `lean_run_code` on the complete module answered every question they would have answered, at one call per iteration and with the axiom profiles measured in the same call.

## Context Extension Recommendations

- **Topic**: The C14-baseline coupling of `docs/theorem-index.md` rows and `FormalSystem/Metalogic.lean` docstring bullets.
- **Gap**: Nothing in `.claude/context/project/lean4/` records that adding a `pinned:C14` cell to a theorem-index row, or a "SORRY-FREE" bullet naming a declaration in `Metalogic.lean`'s docstring, forces an edit to `scripts/check-module-invariants.sh` — i.e. that a documentation-only-looking edit can silently widen a task's file scope. The rule is discoverable only by reading two comment blocks inside a 4,500-line shell script. The complementary fact — that the sanctioned alternative is a bare measured value plus a `#guard_msgs in #print axioms` block in a `Tests/BimodalTest/` evidence module, because C27 forbids live `#print` under `FormalSystem/` — is equally undocumented outside `docs/development/TESTING_STANDARDS.md`.
- **Recommendation**: add a short `context/project/lean4/patterns/axiom-profile-pinning.md` giving the two routes (C14 baseline vs. test-module `#guard_msgs`), the C27 constraint that forces evidence modules out of the library tree, the C17 consequence for declarations with no consumer, and the file-scope implication of each choice.

## Appendix

**Probe runs** (all via `lean_run_code`, `import FormalSystem`):

1. First attempt — 2 errors: `Unknown identifier plus_soundness_ztime` (namespace: `FormalSystem.Metalogic.Conservativity`, not `PlusLanguage`); a failed `rw` in the mirror-shape acceptance `example` (the goal needed `change` to the `reflectTime`-pushed-through form first).
2. Second attempt — **success**, one `linter.style.show` warning only.
3. Third attempt — `#print axioms` on all five theorems: `isLCAxiom_plusValidZTime`, `isLCUAxiom_plusValidZTime`, `ext_sound_ztime`, `ext_sound_lc_ztime`, `ext_sound_lcU_ztime`, each `[propext, Classical.choice, Quot.sound]`.
4. Fourth attempt — `ext_sound_validIn` (the class-generic arm): **success**.

**Search queries / sweeps used**: grep sweeps over `FormalSystem/` for `PlusDerivable|PlusValidZTime|plus_soundness_ztime`, `lcU|lcN|IsLCAxiom|IsLCUAxiom`, `plusValidIn_box|plusValidIn_allFuture` (empty — negative finding by source sweep), `reflectTime` in `Formula.lean`/`PlusReversal.lean`, `bigAnd|gle|StateLocal|next`; declaration-header extraction from `NamingRules.lean` and `AuxiliaryAtoms.lean`; grep over `scripts/check-module-invariants.sh` for `C8|C14|C17|C27|C36` and `Metalogic.lean`; grep over `docs/theorem-index.md` for the dependency's rows.

**Documentation references**: `docs/theorem-index.md` (row format and the Axioms-column convention), `docs/development/TESTING_STANDARDS.md` (library-vs-test split, C27), `lakefile.toml` (`weak.linter.mathlibStandardSet`, the `longFile` baseline at 1500 lines — the recommended module is far below it), `Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean` (the evidence-module pattern and its "when one of these guards fires" discipline).
