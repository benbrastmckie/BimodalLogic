# Research Report: Task #802

**Task**: 802 - Derive every TM-system theorem the paper cites, cite the derivations rather than derivability, and prune the superseded derivability results.
**Started**: 2026-10-15T21:42:00Z
**Completed**: 2026-10-15T21:58:00Z
**Effort**: ~16 min wall clock; one scoped probe build and one full `lake build`
**Dependencies**: None blocking. Builds on the minimal-axiom-set reduction (which created `Metalogic/CompletenessDerived.lean`) and on the BX/TM demotion-wave re-pin recorded in `docs/reference/paper-definitions-of-record.md`.
**Sources/Inputs**:
- Paper (read-only): `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, live working tree, sha256 `b77937bb549bc4b3f42d83b6861f931e8054dfface5a54de46796cb66a57f24b`, last-touching commit `bc010a06`. `scripts/check-paper-definitions.sh` reports case (b) at this revision: file moved since the pin, all 42 recorded definitions unchanged, exit 0.
- `docs/reference/paper-definitions-of-record.md` (the BX/TM demotion-wave table)
- Lean tree at commit `86699e470`, build green
- lean-lsp MCP (`lean_run_code` for `#print axioms`), `lake env lean` probes against existing oleans
- `.claude/context/project/lean4/patterns/dependency-tracing.md` (Shape 1 forward-closure probe)

**Artifacts**:
- `specs/802_derive_cited_tm_theorems_and_cite_derivations/reports/01_derive-cited-tm-theorems.md`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The audit's classification holds, with one addition.** Z1 is the only paper-cited schema routed through a completeness engine. DN carries both a direct derivation and a removable engine cross-check. Every other cited schema is a direct derivation tree. The first pass missed **P5** and **P6**, which the paper presents as derived ("Given P4, we may derive the following") but gives no `\leanfoot`; both already exist in the tree (`Perpetuity.perpetuity5`, `Perpetuity.perpetuity6`), so they need no new derivation — only index rows.
- **Dispatch item (2)'s two acceptance criteria are the same criterion, and neither is reachable in the `DiscreteUnfolding` style.** `#print axioms` showing `propext` at most, and a computable tree for the proof extractor, both fail for the same root cause: `Metalogic.Core.deductionTheorem` is `noncomputable` and carries `[propext, Classical.choice, Quot.sound]`. Every derivation routing through it already does too — including `DiscreteUnfolding.dfSchema`, `succIndicator`, `DedekindDerived.coDerived`, `perpetuity5` and `perpetuity6`, all of which the dispatch treats as model direct derivations.
- **That root cause is a gratuitous classical instance, and the repair is verified feasible.** `FormalSystem/Theorems/DeductionTheorem.lean:68` installs `attribute [local instance] Classical.propDecidable`, with four `haveI : Decidable (_ ∈ _) := Classical.propDecidable _` sites, even though `Formula` derives `DecidableEq`. Replacing all five with `inferInstance` and dropping both `noncomputable` markers **compiles green** and makes `deductionTheorem` computable (measured `isNoncomputable = false`). It does **not** reach `propext`-only: a residual `Classical.choice` survives inside a `theorem` body the closure probe cannot see.
- **`#print axioms` is the wrong discriminator for this audit and the forward-closure probe has its own blind spot.** Imported `theorem` proofs are not serialised into the environment (`value? = none` for `z1Derivable` and for `derivable_of_validZTime`), so the Shape 1 closure traversal stops at every `theorem` boundary. Classification of record here is source-level plus a `def`-closure probe, not either one alone.
- **The prune inventory in the dispatch is incomplete.** It misses a second term-level shape pin (`Independence/ArchimedeanSharpness.lean`), eight further in-tree prose surfaces, four Z1 prose spots in `Metalogic/Independence/README.md`, and a second Typst document (`typst/FormalFoundations.typ`, which still presents Z1 as an axiom of TM_z). The two must-not-prune claims are **verified**: `SoundnessLemmas.z1_valid` and `Metalogic.density_valid` each have independent consumers.
- **`docs/theorem-index.md` is already incomplete for the cited set**, carrying 11 derived-theorem rows and no row for DF, CO, TK, T4, TF, P1–P6 or the discreteness witness. Item (4)'s "add its row" obligation is therefore larger than one row for Z1.

## Context & Scope

Four questions were in scope: (1) re-verify which cited schemata are direct derivations and which go through completeness, with the per-schema consumer inventory for the prune; (2) establish what a direct Z1 derivation would cost and what shape it must take; (3) verify the must-not-prune claims; (4) identify what the systematic expansion in item (4) actually amounts to. The paper was read only to fix the target set.

Out of scope and untouched: the completeness engines, soundness, `ZTimeProvability.lean`'s equivalence, the independence and non-compactness results, the axiom set, and the paper itself.

Evidence tier: lean-lsp was registered and reachable; `lean_local_search` was not relied on for any negative finding. All negative findings below rest on `grep` sweeps over the tree plus `lake env lean` probes against the committed oleans, which is the stronger evidence in each case.

## Literature Proof Structure

**Source**: "The Construction of Possible Worlds" (JPL submission), `sub:Logic`, `sub:Extension`, and the Appendix definitions `def:BX`, `def:BX-z`, `def:BX-d`, `def:BX-r`, `def:TMplus`.
**Strategy**: not a proof source for this task. The paper fixes *which* schemata are targets; each derivation is this tree's own.

### Target set, as the paper states it

Extracted from the live text at the checksum pinned above. "System" is the system the paper says the schema is a theorem *of*.

| Schema | Where displayed | System | Paper's own Lean citation |
|---|---|---|---|
| TC | `\aitem{TC}`, `sub:Logic`; marked derived in `def:BX` | BX | `ConnectDerived.connectFuture` |
| TL | `\aitem{TL}`, `sub:Logic`; marked derived in `def:BX` | BX | `LinearityDerived.tempLinearity` |
| NP, NF, NA | `\alabel` in the `NB` footnote, `sub:Logic`; marked derived in `def:TMplus` | TM (not BX) | `ConnectDerived.discreteSymmFwd`, `DerivedAxioms.discretePropagateFwd`, `ConnectDerived.discretePropagateBwd` |
| P1, P2 | `\aitem`, `sub:Logic` | TM | `Perpetuity.perpetuity1`, `Perpetuity.perpetuity2` |
| TF | `\aitem`, `sub:Logic` | TM | `Combinators.temporalFutureDerived` |
| P3, P4 | `\aitem`, `sub:Logic` | TM | `Perpetuity.perpetuity3`, `Perpetuity.perpetuity4` |
| TK, T4 | `\aitem`, `sub:Logic` | BX | `TemporalDerived.temporalKDistDerived`, `TemporalDerived.temporal4Derived` |
| **P5, P6** | `\aitem`, `sub:Logic` — "Given P4, we may derive the following" | TM | **none** |
| DF | `\aitem`, `sub:Extension` | TM_z | `DiscreteUnfolding.dfSchema` |
| DN | `\aitem`, `sub:Extension`; marked derived in `def:BX-d` | BX_d | `LinearityDerived.density` |
| CO | `\aitem`, `sub:Extension`; marked derived in `def:BX-r` | BX_r | `DedekindDerived.coDerived` |
| Z1 | `\aitem`, `sub:Extension`; marked derived in `def:BX-z` | TM_z (not BX_z) | `CompletenessDerived.z1Thm` |
| discreteness witness | `sub:Extension`, the joint-inconsistency sentence | TM_z proves `X⊤` | `DiscreteUnfolding.succIndicator` |

### Not targets, recorded so they are not re-litigated

- **UE, UT** — removed from the paper outright (zero `\aitem`/`\alabel`/`\aref` occurrences). They survive as `DerivedAxioms.untilF` / `DerivedAxioms.fUntilEquiv` with no paper key.
- **`lem:derived-schemata`** — the appendix lemma no longer exists; the four definitions above are the live sources.
- **The `fn:static-frame` claim that DN does not prove NN** — an independence claim, not a theorem of a system, and expressly deferred by the record file. `Independence/StaticFrame.lean` already has the related `static_validates_z1`.
- **The parked `Past`/`Future`-fragment incompleteness footnote** — commented out in the paper source.

### Potential formalization challenges

Only Z1 lacks a direct derivation. Its challenge is recorded under Findings → "What a direct Z1 derivation costs".

## Findings

### Per-schema classification of record

`#print axioms` measured in one `lean_run_code` run against the committed build; "noncomputable" measured via `Lean.isNoncomputable`; "engine-free" is the Shape 1 forward closure over `def` bodies, intersected with `{derivable_of_validZTime, derivable_of_validQTime, derivable_of_validDense, completeness}`.

| Schema | Declaration | Route | `#print axioms` | noncomp. | engine in closure |
|---|---|---|---|---|---|
| TC | `Theorems.ConnectDerived.connectFuture` | direct | `[propext]` | no | no |
| TL | `Theorems.LinearityDerived.tempLinearity` | direct | `[propext]` | no | no |
| NP | `Theorems.ConnectDerived.discreteSymmFwd` | direct | `[propext]` | no | no |
| NF | `ProofSystem.DerivedAxioms.discretePropagateFwd` | direct | `[propext]` | no | no |
| NA | `Theorems.ConnectDerived.discretePropagateBwd` | direct | `[propext]` | no | no |
| P1 | `Theorems.Perpetuity.perpetuity1` | direct | `[propext]` | no | no |
| P2 | `Theorems.Perpetuity.perpetuity2` | direct | `[propext]` | no | no |
| P3 | `Theorems.Perpetuity.perpetuity3` | direct | `[propext]` | no | no |
| P4 | `Theorems.Perpetuity.perpetuity4` | direct | `[propext]` | no | no |
| P5 | `Theorems.Perpetuity.perpetuity5` | direct | `[propext, Classical.choice, Quot.sound]` | yes | no |
| P6 | `Theorems.Perpetuity.perpetuity6` | direct | `[propext, Classical.choice, Quot.sound]` | yes | no |
| TF | `Theorems.Combinators.temporalFutureDerived` | direct | `[propext]` | no | no |
| TK | `Theorems.TemporalDerived.temporalKDistDerived` | direct | `[propext]` | no | no |
| T4 | `Theorems.TemporalDerived.temporal4Derived` | direct | `[propext]` | no | no |
| DF | `Theorems.DiscreteUnfolding.dfSchema` | direct | `[propext, Classical.choice, Quot.sound]` | yes | no |
| witness | `Theorems.DiscreteUnfolding.succIndicator` | direct | `[propext, Classical.choice, Quot.sound]` | yes | no |
| DN | `Theorems.LinearityDerived.density` | direct | `[propext]` | no | no |
| CO | `Theorems.DedekindDerived.coDerived` | direct | `[propext, Classical.choice, Quot.sound]` | yes | no |
| **Z1** | `Metalogic.CompletenessDerived.z1Thm` | **engine** | `[propext, Classical.choice, Quot.sound]` | yes | — (see below) |
| DN (dup) | `Metalogic.CompletenessDerived.densityDerivable` | **engine** | `[propext, Classical.choice, Quot.sound]` | — | — |

Z1's engine route is established at source level, not by the closure probe: `z1Derivable` is literally `BXCanonical.derivable_of_validZTime _ (SoundnessLemmas.z1_valid φ)`, and `z1Thm` is `Classical.choice (z1Derivable φ)`. A tree-wide sweep of `derivable_of_valid*` call sites finds exactly two per-schema consumers, both in `CompletenessDerived.lean`; every other call site is general metatheory (`QTime.lean`, `StrongCompleteness.lean`, `ZTimeProvability.lean`, `Decidability.lean`, `Deterministic/Engines.lean`) and out of scope. `Classical.choice` appears in no `Theorems/` or `ProofSystem/` source at all.

### The axiom-profile criterion does not discriminate, and the closure probe has a blind spot

Two measured facts that between them govern how item (5)'s verification must be written:

1. **`#print axioms` cannot separate a direct derivation from an engine-routed one here.** `dfSchema`, `succIndicator`, `coDerived`, `perpetuity5` and `perpetuity6` are all direct derivation trees and all report `[propext, Classical.choice, Quot.sound]` — the same profile as `z1Thm`. The provenance is `Classical.propDecidable`, reached through `Metalogic.Core.deductionTheorem`; the probe that finds this is the per-node "which declarations in the closure directly mention `Classical.choice`" scan, which returns `[Classical.propDecidable]` and nothing else. This is the same caveat `context/project/lean4/patterns/dependency-tracing.md` opens with, confirmed on this tree.
2. **The Shape 1 forward closure stops at every `theorem` boundary.** Lean does not serialise imported theorem proofs: `env.find?` returns `value? = none` for `CompletenessDerived.z1Derivable` and for `BXCanonical.derivable_of_validZTime` (both `thmInfo`), while `Metalogic.Core.deductionTheorem` (`defnInfo`) has a value and is traversed. Hence `z1Derivable`'s closure measures 17 constants — its type only — and reports no engine hit, which would be a false clean. The probe is sound in the direction that matters for `DerivationTree`-valued declarations, because they are `def`s and a `Prop`-valued theorem can only enter such a term through `Classical.choice`, which the probe does flag.

**Consequence for item (5).** "`#print axioms` showing `propext` at most for the derivations" is not a criterion the tree currently satisfies for DF, CO or the witness, and cannot be imposed on a new Z1 derivation that uses the deduction theorem. The honest replacement is: no `sorryAx`; no completeness engine in the dependency closure, asserted by the `def`-closure probe plus a source reading; and the measured axiom profile recorded as a fact rather than asserted as a bound.

### The root cause, and a verified repair

`FormalSystem/Theorems/DeductionTheorem.lean` makes `Decidable (A ∈ Γ)` classical in five places — line 68's `attribute [local instance] Classical.propDecidable`, plus `haveI` sites at 239, 270, 343 and 382 — and marks `deductionWithMem` and `deductionTheorem` `noncomputable`. `Formula` derives `DecidableEq` (`FormalSystem/Syntax/Formula.lean`, the `deriving Repr, DecidableEq, BEq, Hashable, Countable` clause), so list membership in a `Context` is constructively decidable and none of the five is needed.

**Probe run and reverted in this session** (file copied out, edited, built, restored; `git status` clean outside `specs/` afterwards, and a full `lake build` green on the restored tree):

- Replacing all five with `inferInstance` and dropping both `noncomputable` markers: scoped guarded build of `FormalSystem.Theorems.DeductionTheorem` **exit 0**.
- `Lean.isNoncomputable` on `deductionTheorem` afterwards: **false**. The computability blocker is the classical instance, not the well-founded recursion.
- `#print axioms` afterwards: still `[propext, Classical.choice, Quot.sound]`. The per-node scan finds **no** direct `Classical.choice` user left in the `def`-traversable closure, so the residue sits inside a `theorem` body — reachable, but not by this probe.

So the repair buys computability, which is exactly what the proof extractor needs, and does not buy `propext`-only. `DiscreteUnfolding.lean` additionally wraps its declarations in a `noncomputable section`, which would have to come off for the cascade to reach `dfSchema` and `succIndicator`.

### What a direct Z1 derivation costs

Z1 is `G(Gφ → φ) → (FGφ → Gφ)`; in Lean, `((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture))`. The constructor shapes needed are all present:

- `Axiom.prior_UZ φ : Fφ → U(φ, ¬φ)` — guard-first `Formula.untl φ.neg φ`. Instantiating at `Gφ` gives the *nearest* future `Gφ`-point with `¬Gφ` throughout the intervening interval.
- `Axiom.enrichment_until φ ψ p : (p ∧ U(φ,ψ)) → U(φ, ψ ∧ S(φ,p))` — US, the payload-transport axiom `dfSchema` already uses, which carries a currently-true formula to the witness as a `since`-formula.
- `DiscreteUnfolding.nextAllFuture : X(Gφ ∧ φ) → Gφ` at `.ZTime`, `unfoldForward`, `nextConj`, `untlBotFalse`, `succIndicator`.
- `DerivationTree.time_reflection` as a primitive rule at every frame class, with `prevAllPast` as the worked precedent for taking a past mirror free of charge.

A route that uses exactly these, offered as a research sketch for the planner to verify rather than as a checked proof: assume `¬Gφ`, `G(Gφ→φ)` and `FGφ`; get `U(Gφ, ¬Gφ)` from UZ at `Gφ`; enrich with payload `¬Gφ` by US to reach, at the nearest `Gφ`-witness, both `Gφ ∧ φ` and `S(¬Gφ, ¬Gφ)`; unfold the `since`-formula one step backwards to get `Y(¬Gφ)` at the witness; independently get `Y(Gφ)` there, by transporting `Gφ ∧ φ` to the predecessor with the past mirror of `enrichment_until` and closing with `nextAllFuture`; merge the two `Y`-formulas with the past mirror of `nextConj` and refute with the past mirror of `untlBotFalse`. The argument is finite — no induction — and the step that makes it finite is UZ's *nearest*-witness structure.

**The helper derivations it factors through are precisely the missing past mirrors**, which is item (4)'s "name, rather than inline" obligation and which the `prevAllPast` recipe (`DerivationTree.time_reflection` plus one `reflect_time_*_eq` normalization lemma, proved by a single `simp only`) makes cheap:

| Needed | Mirror of | Exists today |
|---|---|---|
| `prevIndicator : Y⊤` at `.ZTime` | `succIndicator` | no |
| `prevConj : Y A ∧ Y B → Y(A ∧ B)` | `nextConj` | no |
| backward `snce` unfolding | `unfoldForward` / `unfoldBackward` | no |
| `snceBotFalse` | `untlBotFalse` | no |

**Gated vs. pinned is a non-problem.** `DerivationTree.lift (h_le : fc₁ ≤ fc₂)` is computable and structural, so a `.ZTime`-pinned derivation yields the gated `(h : FrameClass.ZTime ≤ fc)` form in one line — the shape `Search.lean`'s `tryGatedDerivedMatch`, `AxiomValidity.lean`'s `priorSZ le_rfl` branches and `ProofExtractorMain`'s `mkEntryAt` all consume. `Combinators.baseThm` is the existing instance of exactly this pattern.

**Module placement.** `FormalSystem/Theorems/README.md`'s "Where a derived schema lives" fixes the rule (lowest module whose imports supply the proof) and records that *every* derivation in `ConnectDerived` and `LinearityDerived` is computable "because the runtime proof search and the dataset tooling build and traverse the trees". The ZTime machinery the sketch needs lives in `DiscreteUnfolding.lean`, so that is the placement — which means a computable Z1 requires the `DeductionTheorem` repair to land first, or it does not get an extractor entry.

### Prune inventory for Z1 and DN

**`densityDerivable`** — zero consumers anywhere outside its own file (the only other mention is `FormalSystem/Metalogic/README.md`'s module table). Removable immediately, with the module docstring's cross-check paragraph.

**`z1Thm` / `z1Derivable`** — five term-level consumers, seven import sites, and a long prose tail.

*Term-level (must be redirected before deletion):*

| Site | Use |
|---|---|
| `Metalogic/Conservativity/Backward.lean` | `z1_translate` |
| `Metalogic/Conservativity/Plus/AxiomValidity.lean` | two `plusValidIn_of_tm_deriv` / `plusValidIn_reflect_time_of_tm_deriv` branches |
| `Metalogic/Independence/ZTimeSharpness.lean` | `noncomputable example` shape pin |
| `Metalogic/Independence/ArchimedeanSharpness.lean` | `noncomputable example` shape pin — **not in the dispatch's list** |
| `Automation/Tactics/Search.lean` | `tryGatedDerivedMatch`'s lemma-name list |

*Import sites:* `FormalSystem.lean`, `FormalSystem/Metalogic.lean`, `Automation/Tactics/Search.lean`, `Conservativity/Backward.lean`, `Conservativity/Plus/AxiomValidity.lean`, `Independence/ArchimedeanSharpness.lean`, `Independence/ZTimeSharpness.lean`. All three declarations in `CompletenessDerived.lean` go, so the module and all seven imports go with them.

*Prose surfaces the dispatch names:* `ProofSystem/Axioms.lean` (four spots), `MainResults.lean`, `Decidability/Verified/RuleSpec.lean` (two), `BimodalTools/ProofExtractorMain.lean`, `Tests/BimodalTest/Automation/EdgeCaseTest.lean`, `Tests/BimodalTest/Automation/TacticsTest.lean`.

*Prose surfaces the dispatch does **not** name:* `Metalogic/Conservativity.lean`, `Metalogic/Independence/StaticFrame.lean` (two), `Metalogic/Independence/README.md` (four), `MinusLanguage/Axioms.lean`, `ProofSystem.lean`, `Semantics/FrameClassValidity.lean`, `Semantics/FrameProperty.lean`, `BimodalTools/AxiomNames.lean`.

*Doc surfaces:* the nine the dispatch names, plus **`typst/FormalFoundations.typ`**, whose Z1 prose is a second Typst surface. Four of its spots (the `def:BX-z`-style axiom list, the TM_z row, the systems table and the TM_z-algebra definition) present Z1 as an *axiom* of TM_z, which the demotion wave already made stale independently of this task.

### What must not be pruned — both claims verified

- **`SoundnessLemmas.z1_valid` stays.** Independent consumers confirmed: `Independence/ZTimeSharpness.lean`'s `z1_validIn_iff_ztime` (`exact z1_valid (Formula.atom p)`), and `Decidability/Verified/Decidable.lean` via `truthAt_of_validZTime (SoundnessLemmas.z1_valid inner)`.
- **`Metalogic.density_valid` stays.** Independent consumer confirmed: `Independence/DenseRTimeSharpness.lean`'s `density_validIn_iff` (`ValidIn.mono h (density_valid (Formula.atom a))`). A second mention is in `Boneyard/`.

Neither is a pure feeder, and the same consumer check is what any other validity lemma must get.

### Gate surface

- **C35 (`export-lean-citations.py --check`) will go red.** `scripts/lean-citation-manifest.json` seeds two files this task must edit: `Metalogic/Independence/ZTimeSharpness.lean` (4 entries) and `ProofSystem/Axioms.lean` (1). Remedy is regeneration, as the dispatch says.
- **`check-phantom-citations.sh` scans `specs/state.json`'s live task descriptions.** Task 802's own description cites `CompletenessDerived.z1Thm`, `z1Derivable` and `densityDerivable` by name; once those are deleted, the task's own live description becomes a phantom-citation finding. This is a scheduling constraint, not a defect in the deletion.
- **C2 / C14 need no new baseline entry.** C2 pins fifty flagship axiom sets and contains none of these declarations; C14's content half is a stale-literal scan (axiom counts, documented sorry counts), not a per-row verifier. `docs/theorem-index.md`'s Axioms column for the Z1 rows reads plain `pcq`, not `pinned:`, and the table's own prose explains why.
- **Generated inventory blocks move.** `FormalSystem/Theorems/README.md` and `FormalSystem/Metalogic/README.md` both carry `BEGIN GENERATED: inventory` tables with line counts; `Metalogic/README.md`'s `CompletenessDerived.lean` row (76 lines) disappears entirely. Regenerate with `check-module-invariants.sh --emit-inventory`.
- `scripts/check-paper-definitions.sh` is green at the paper revision pinned above (case (b)).

### `docs/theorem-index.md` coverage gap

The derived-theorems table has 11 rows: UE, UT, NF, TR-of-NF, TC, NP, NA, TL, DN, and the two Z1 rows. It carries **no row** for DF, CO, TK, T4, TF, P1–P6, or the discreteness witness — every one of them a paper-cited theorem with a `\leanfoot`. Item (4)'s indexing obligation therefore covers around twelve missing rows, not one. The table's lead-in prose ("The nine Base-polymorphic derivations are computable and carry `propext` only") will need adjusting if `pcq`-and-noncomputable rows join it, or will become simply true if the `DeductionTheorem` repair lands first.

## Decisions

- **Classification of record is source-level plus a `def`-closure probe, not `#print axioms`.** The axiom profile is recorded as a measurement, never as the discriminator.
- **Z1's derivation goes in `FormalSystem/Theorems/DiscreteUnfolding.lean`**, `.ZTime`-pinned, with the gated form via `DerivationTree.lift` — not in a new module, and not in `Metalogic/`.
- **The four missing past mirrors are named declarations, not inlined steps**, built by the `prevAllPast` recipe. They are the item-(4) expansion this task genuinely earns.
- **P5 and P6 are added to the target table and to the index, but need no new derivation.** They already exist and are proved.
- **The `DeductionTheorem` classical-instance repair is reported as a recommendation with its probe evidence, not folded silently into scope.** It is the enabler for the extractor entry and for a `propext`-shaped acceptance criterion, and it touches a file no other part of this task needs to touch.

## Recommendations

Priority order for the planner.

1. **Rewrite item (5)'s acceptance criterion before planning phases against it.** Replace "`#print axioms` showing `propext` at most for the derivations" with: zero `sorryAx`; no completeness engine in the dependency closure (asserted by the Shape 1 `def`-closure probe plus a source reading, with the `theorem`-boundary blind spot stated); and the measured axiom profile recorded per declaration. The current criterion is failed today by `dfSchema`, `succIndicator` and `coDerived`.
2. **Decide the `DeductionTheorem` repair question first, because it gates item (2)'s extractor goal.** Either (a) sequence it as a precursor phase — five one-line edits in `DeductionTheorem.lean`, drop `DiscreteUnfolding.lean`'s `noncomputable section`, re-measure — which makes Z1, DF, CO and the witness computable and unblocks three new `mkEntryAt` entries, not just Z1's; or (b) accept a noncomputable Z1, drop the extractor entry from scope, and say so. Do not plan for a computable Z1 without (a).
3. **Build the four past mirrors as their own phase, before Z1.** `prevIndicator`, `prevConj`, the backward `snce` unfolding, and `snceBotFalse`, each with a docstring, an index row, and the `reflect_time_*_eq` normalization lemma its `▸`-rewrite needs.
4. **Then Z1**, following the sketch above, `.ZTime`-pinned with a `lift`-derived gated companion. Verify the sketch's US/`enrichment_until` instantiation early — it is the step most likely to need a different payload than `¬Gφ`.
5. **Prune in dependency order:** `densityDerivable` first (no consumers); then redirect the five `z1Thm` term consumers; then delete `z1Thm`, `z1Derivable` and the module, and its seven imports; then the prose tail, then the doc surfaces, then regenerate the citation manifest and the inventory blocks.
6. **Close the index coverage gap in the same pass** — rows for DF, CO, TK, T4, TF, P1–P6 and the witness, with their measured axiom cells.
7. **Raise `typst/FormalFoundations.typ`'s "TM_z adds UZ and Z1" prose as a scope question** rather than fixing it silently: it is stale demotion-wave fallout, not a derivability-route citation, so it may belong to a separate task.
8. **Schedule the `check-phantom-citations.sh` run with the task's own description in mind** — rewrite the description's declaration names at completion, or run the check after archival.

## Risks & Mitigations

- **The Z1 derivation sketch is unverified.** It is a research sketch, not a checked proof; the US instantiation and the backward `snce` unfolding are the two steps most likely to need adjustment. *Mitigation*: build the four mirrors first, so the sketch is attempted against named, compiled helpers rather than against four simultaneous unknowns; keep the phase sized for one schema.
- **The `DeductionTheorem` repair is verified for compilation and computability, not for the whole downstream tree.** The probe built one module; `DiscreteUnfolding`, `DedekindDerived`, `Perpetuity` and every `orElim` consumer were not rebuilt against it. *Mitigation*: treat it as its own phase with a full `lake build` as its exit criterion, and revert rather than patch forward if the cascade misbehaves.
- **`propext`-only remains out of reach even after the repair.** A residual `Classical.choice` survives inside a `theorem` body. *Mitigation*: do not promise it; recommendation 1 removes the dependency on it.
- **Nine-plus prose surfaces risk an incomplete rewrite.** *Mitigation*: `check-phantom-citations.sh` is the mechanical backstop for deleted names, but it does not catch prose that still *describes* an engine recovery in correct-but-stale terms. A final `grep -rn "completeness engine"` over the Z1 surfaces is the complementary check.
- **Concurrency.** Siblings 795 and 797 are in `plan` phase this cycle with no declared `file_scope`. The tree was clean outside `specs/` at the start of this dispatch and again at its end, and the one probe edit was restored and re-verified by a full green build. An unexplained Lean failure in the implementation phase should be checked against `git log` before being assumed to be a regression.

## Tactic Survey Results

Not applicable (no tactic survey performed). The work item is a Hilbert-style `DerivationTree` term built from axiom constructors and named combinators, where a `simp`/`omega`/`aesop`/`decide` portfolio has nothing to act on — the object-level proof obligations are not Lean goals a tactic can discharge. The probe effort went instead into dependency tracing and axiom/computability measurement, reported under Findings.

## Context Extension Recommendations

- **Topic**: The `theorem`-boundary blind spot in the Shape 1 forward-closure probe.
  **Gap**: `context/project/lean4/patterns/dependency-tracing.md` warns at length that `#print axioms` is not a dependency tracer, but does not record that its own Shape 1 probe silently stops at every imported `theorem`, because Lean does not serialise theorem proofs (`value? = none`). A `Prop`-valued suspect is therefore invisible to it, and the result looks clean.
  **Recommendation**: add a "Shape 1's own blind spot" subsection to that file, with the `thmInfo` vs. `defnInfo` existence check as the diagnostic (`ci.value?.isSome`), and the rule that a `def`-closure clean result is evidence only when paired with a source reading or a `Classical.choice` flag.

- **Topic**: Computability as a first-class property of this tree's derivations.
  **Gap**: `FormalSystem/Theorems/README.md` states the convention ("Every derivation in `ConnectDerived` and `LinearityDerived` is computable, because the runtime proof search and the dataset tooling build and traverse the trees") but nothing records *what breaks it* — that `Metalogic.Core.deductionTheorem`'s classical `Decidable` instances are the single upstream cause, and that `ProofExtractorMain`'s `mkEntryAt` silently excludes anything noncomputable.
  **Recommendation**: a short `context/project/lean4/patterns/computable-derivations.md` recording the `Lean.isNoncomputable` probe, the `deductionTheorem` root cause, and the `mkEntryAt` consequence.

## Appendix

### Probes run

- `#print axioms` over 21 declarations in one `lean_run_code` call against the committed build.
- `Lean.isNoncomputable` over 14 declarations (`lake env lean`, scratch probe).
- Shape 1 forward transitive closure from 21 targets against a 9-element suspect set (engines, `z1_valid`, `density_valid`, `deductionTheorem`, `sorryAx`, `Classical.choice`); closure sizes 17–586 constants.
- Per-node "direct `Classical.choice` user" scan over `dfSchema`'s closure → `[Classical.propDecidable]`.
- `ConstantInfo` kind/`value?` existence check establishing the `theorem`-boundary blind spot.
- `DeductionTheorem.lean` classical-instance removal: scoped guarded build exit 0, `isNoncomputable` false, axioms unchanged; file restored and full `lake build` green.
- `scripts/check-paper-definitions.sh` → case (b), exit 0.

### Grep sweeps

- `derivable_of_valid` across `FormalSystem/`, `Tests/`, `BimodalTools/` — two per-schema consumers, both in `CompletenessDerived.lean`.
- `Classical.choice` across `FormalSystem/Theorems/`, `FormalSystem/ProofSystem/` — zero occurrences.
- `z1Thm|z1Derivable|CompletenessDerived|densityDerivable` across `*.lean`, `*.md`, `*.typ`, `*.json`, `*.sh`, `*.py` excluding `specs/` and `.lake/` — 20 Lean files, 7 doc files, 2 Typst files.
- `z1_valid`, `density_valid` consumer sweeps for the must-not-prune verification.

### References

- `docs/reference/paper-definitions-of-record.md` — the BX/TM demotion-wave section and its per-schema table
- `.claude/context/project/lean4/patterns/dependency-tracing.md` — Shape 1
- `FormalSystem/Theorems/README.md` — "Where a derived schema lives"; the computability convention
- `docs/theorem-index.md` — the derived-theorems table and its Axioms-column legend
- `scripts/lean-citation-seeds.txt`, `scripts/lean-citation-manifest.json` — C35's input and output
