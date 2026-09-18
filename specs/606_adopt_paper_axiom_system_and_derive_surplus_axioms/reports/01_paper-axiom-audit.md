# Research Report: Task #606

**Task**: 606 - Adopt the paper axiom system and derive the surplus axioms
**Started**: 2026-09-18T10:48:38Z
**Completed**: 2026-09-18T11:40:00Z
**Effort**: Large (roughly 330 qualified call sites plus 9 exhaustive dispatchers; 6-8 plan phases)
**Dependencies**: None
**Sources/Inputs**: - Codebase (`FormalSystem/ProofSystem/Axioms.lean`, `Derivation.lean`, `Metalogic/Soundness.lean`, all call sites), the JPL paper `possible_worlds.tex` (`sub:Logic`, `sub:Extension`, `def:S5`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:BX-r`, `def:TMplus`) read through `docs/reference/paper-definitions-of-record.md`, `docs/reference/axiom-reference.md`, lean-lsp MCP (`lean_run_code` prototypes)
**Artifacts**: - specs/606_adopt_paper_axiom_system_and_derive_surplus_axioms/reports/01_paper-axiom-audit.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The paper's primitive system has **29 axiom schemata**, not 45. They are CPL (4, realized by `prop_k`, `prop_s`, `ex_falso` and `peirce`), MK, MT, M5, 11 BX temporal schemata, 4 uniformity schemata, MF, DN, NN, UZ, Z1, PU and SEP. The rules are MP, MN, TN and TR.
- **16 constructors are surplus, and all 16 are derivable.** That covers the 12 BX past mirrors named in the task, plus 4 the task did not name:
  - `modal_4` and `modal_b`: `def:S5` is MK, MT and M5 only.
  - `prior_SZ` and `prior_S_gap`: the paper states only UZ and PU, and gets the past forms by TR (`def:BX-r` says so explicitly).
- **No constructor falls in the "surplus with no known derivation" class.**
- Every derivation was **compiled with `lean_run_code`**, with no errors:
  - Six TR mirror prototypes: `since_P`, `enrichment_since`, `linear_since`, `prior_S_gap` at RTime, `prior_SZ` at ZTime, and `discrete_symm_bwd`.
  - `modal_b` and `modal_4` from K, T and 5.
  - The TR recipe is uniform: apply `time_reflection` to the primary's axiom instance at `reflectTime`d arguments, then `simpa [Formula.reflectTime, <operator defs>, Formula.reflect_time_involution]`.
- TR (`DerivationTree.time_reflection`) is generic in `fc`, so it is available in every frame class. Each mirror has the same `minFrameClass` as its primary (Base; ZTime for `prior_SZ`; RTime for `prior_S_gap`), so **no frame class needs a surplus axiom**.
- Four constructors are paper axioms in a **non-verbatim form**:
  - `temp_linearity` (TL): disjuncts reordered and regrouped.
  - `linear_until` (CN): same disjunct order as the paper, but left-associated.
  - `serial_future` (TS): stated as `⊤ → F⊤`, where the paper has bare `F⊤`.
  - `discrete_propagate_bwd`: this is NA itself, despite a name that suggests a mirror.
  - For the paper's 3-way `∨` the repository already uses right association (`MinusLanguage.Axiom.temp_linearity` transcribes TL "verbatim" that way), so the restatements should use it.
- Recommended approach: a new leaf module `FormalSystem/ProofSystem/DerivedAxioms.lean` holds the 12 TR mirrors plus `prior_SZ`/`prior_S_gap`, with `{fc}`-polymorphic `DerivationTree fc [] φ` defs. `modal_b`/`modal_4` go in a module after `Propositional.Core`. Call sites are then rewritten mechanically from `DerivationTree.axiom Γ _ (Axiom.X args) h` to the derived def. This path is sorry-free and axiom-free.

## Context & Scope

This round covered:
- An audit of all 45 constructors of `inductive Axiom` (`FormalSystem/ProofSystem/Axioms.lean`) and the 7 `DerivationTree` constructors, against the paper's full axiom list:
  - `sub:Logic`: MK, MT, M5, MP, MN, TN, TR, TS, TC, UE, UT, NP, NF, UI, UC, UF, UG, SU, NA, NB, TL, CN and MF.
  - `sub:Extension`: DN, NN, UZ, Z1, PU and SEP. DF and CO are correspondents or derived theorems, not axioms of any system.
- Per-frame-class availability.
- The blast radius the plan must cover.

Constraints:
- The paper is read-only.
- Paper citations go by `\label{}` / `\aitem{}` key.
- Zero new `sorry` or `axiom`.

Out of scope: the separate `PlusAxiom`, `StarAxiom`, `DetAxiom` and `MinusLanguage.Axiom` inductives. They are distinct systems (TM⁺, TM⋆, TM⁺+Determined, TM⁻). None of them embeds into `Axiom`; they only receive embeddings from it.

## Findings

### Classification table (all 45 constructors)

Legend:
- **P**: paper-primitive, verbatim.
- **P\***: paper-primitive, but restated.
- **D**: derivable surplus.
- **N**: surplus with no known derivation. No row is N.

| # | Constructor | minFC | Paper key | Class | Derivation sketch / note |
|---|---|---|---|---|---|
| 1 | `prop_k` | Base | CPL | P | CPL is not given schemata in the paper. K, S, EFQ and Peirce form a minimal complete Hilbert basis for {⊥,→}. Each is independent: EFQ fails when ⊥ is read as true, and Peirce is not intuitionistic. |
| 2 | `prop_s` | Base | CPL | P | as above |
| 3 | `ex_falso` | Base | CPL | P | as above |
| 4 | `peirce` | Base | CPL | P | as above |
| 5 | `modal_t` | Base | MT | P | |
| 6 | `modal_4` | Base | — | **D** | `B(□φ)`: `□φ → □◇□φ`; `MN(M5 φ)` + `MK`: `□◇□φ → □□φ`; `impTrans`. Compiled. |
| 7 | `modal_b` | Base | — | **D** | `MT(¬φ)` contraposed + DNI: `φ → ◇φ`; `M5(¬φ)` contraposed + `doubleNegation`: `◇φ → □◇φ`; `impTrans`. Compiled. |
| 8 | `modal_5_collapse` | Base | M5 | P | `◇□φ → □φ` verbatim |
| 9 | `modal_k_dist` | Base | MK | P | |
| 10 | `serial_future` | Base | TS | P\* | Lean `⊤ → F⊤`; paper `F⊤`. Interderivable by MP with `topThm` and by `prop_s`. |
| 11 | `serial_past` | Base | TR(TS) | **D** | TR of `serial_future` |
| 12 | `left_mono_until_G` | Base | UG | P | |
| 13 | `left_mono_since_H` | Base | TR(UG) | **D** | TR at reflected args, then involution |
| 14 | `right_mono_until` | Base | UC | P | |
| 15 | `right_mono_since` | Base | TR(UC) | **D** | TR |
| 16 | `connect_future` | Base | TC | P | |
| 17 | `connect_past` | Base | TR(TC) | **D** | TR |
| 18 | `enrichment_until` | Base | SU | P | |
| 19 | `enrichment_since` | Base | TR(SU) | **D** | TR (compiled) |
| 20 | `self_accum_until` | Base | UF | P | |
| 21 | `self_accum_since` | Base | TR(UF) | **D** | TR |
| 22 | `absorb_until` | Base | UI | P | |
| 23 | `absorb_since` | Base | TR(UI) | **D** | TR |
| 24 | `linear_until` | Base | CN | P\* | Same disjunct order as the paper; Lean groups `(A∨B)∨C`. Restate as `A∨(B∨C)`. |
| 25 | `linear_since` | Base | TR(CN) | **D** | TR (compiled against the current form; re-derive from the restated CN) |
| 26 | `until_F` | Base | UE | P | |
| 27 | `since_P` | Base | TR(UE) | **D** | TR (compiled) |
| 28 | `temp_linearity` | Base | TL | P\* | Lean `F(φ∧ψ) ∨ (F(φ∧Fψ) ∨ F(Fφ∧ψ))`; paper `F(Fφ∧ψ) ∨ (F(φ∧ψ) ∨ F(φ∧Fψ))`. Same disjuncts, permuted. |
| 29 | `temp_linearity_past` | Base | TR(TL) | **D** | TR of the restated TL, plus a propositional disjunct permutation back to the current past form (or restate the past form too) |
| 30 | `F_until_equiv` | Base | UT | P | |
| 31 | `P_since_equiv` | Base | TR(UT) | **D** | TR |
| 32 | `modal_future` | Base | MF | P | |
| 33 | `discrete_symm_fwd` | Base | NP | P | |
| 34 | `discrete_symm_bwd` | Base | TR(NP) | **D** | `time_reflection _ (axiom discrete_symm_fwd)`. Definitionally the right type, no cast needed (compiled). |
| 35 | `discrete_propagate_fwd` | Base | NF | P | |
| 36 | `discrete_propagate_bwd` | Base | NA | P | This is NA itself (`X⊤ → H X⊤`), **not** a mirror of NF. TR(NF) would be `Y⊤ → H Y⊤`. |
| 37 | `discrete_box_necessity` | Base | NB | P | |
| 38 | `prior_UZ` | ZTime | UZ | P | |
| 39 | `prior_SZ` | ZTime | TR(UZ) | **D** | TR, gated `ZTime ≤ fc` (compiled). Not named in the task. |
| 40 | `z1` | ZTime | Z1 | P | |
| 41 | `density` | Dense | DN | P | |
| 42 | `dense_indicator` | Dense | NN | P | `¬(⊥U⊤)` = `¬X⊤` |
| 43 | `prior_U_gap` | RTime | PU | P | `kPlus φ = ¬(¬φ U ⊤)` matches the paper's K⁺ |
| 44 | `prior_S_gap` | RTime | TR(PU) | **D** | TR, gated `RTime ≤ fc` (compiled; `kPlus` reflects to `kMinus`). Not named in the task. |
| 45 | `sep` | RTime | SEP | P | |

Totals:
- 29 primitive: Base 23, Dense 2, ZTime 2, RTime 2.
- 16 derived: Base 14, ZTime 1, RTime 1.
- 0 underivable.

Rules: `modus_ponens` is MP, `necessitation` is MN, `temporal_necessitation` is TN, and `time_reflection` is TR. `assumption` and `weakening` are the structural rules of `Γ ⊢`, not logical rules, so they are not surplus.

### Per-FrameClass check

- `time_reflection` is a constructor of `DerivationTree fc` for every `fc`, so it is available in Base, Dense, ZTime and RTime.
- A mirror is used only where its primary is admissible, since their `minFrameClass` values are equal. Deriving it costs no frame class anything.
- Soundness of TR at each class is already carried axiom-by-axiom by `axiom_swap_validIn_min` (`Metalogic/Soundness.lean`). It does not need global closure of the class under order reversal. After the change, the `prior_UZ`/`prior_U_gap` swap arms keep using the `prior_SZ_valid`/`prior_S_gap_valid` lemmas.
- No derivation needs a surplus axiom at any class. The only gated derived items are `prior_SZ` (hypothesis `ZTime ≤ fc`) and `prior_S_gap` (hypothesis `RTime ≤ fc`). Existing call sites pass `(Axiom.prior_SZ φ).minFrameClass ≤ fc`, which is definitionally `ZTime ≤ fc`, so the hypotheses are drop-in.

### Codebase Patterns

- **No axiom-set reflection closure exists**: grep found no `Axiom φ → Axiom φ.reflectTime`. Removing the mirrors therefore breaks no TR-elimination machinery. The soundness recursion `derivable_valid_and_swap_validIn` needs only per-axiom validity and swap-validity.
- **Exhaustive `cases`/`match` on `Axiom`**: these lose arms. Mechanical, but each must be edited.
  - `Soundness.lean` (`axiom_validIn_min`)
  - `SoundnessLemmas/FrameClassVariants.lean` (`axiom_swap_valid_general`, ~line 667)
  - `PlusLanguage/Derivation.lean` (`PlusAxiom.ofTM`, line 193)
  - `Automation/DatasetGenerator.lean` (~line 270)
  - `Automation/ProofStepExtractor.lean` (~line 80)
  - `Axiom.minFrameClass` (`prior_SZ`/`prior_S_gap` arms)
- **Sites that pass a TM `Axiom` value as data**, which must switch to validity or derivation arguments:
  - `Conservativity/Plus/Atomization.lean`: `plusValidIn_of_tm` and `plusValidIn_swap_of_tm` take `(ax : Axiom (atomize e φ))`. Add derivation-taking variants via `soundness_validIn` / `derivable_valid_and_swap_validIn`, and use them in the mirror arms of `Plus/AxiomValidity.lean` (32 hits).
  - `Independence/CoarsenedModels.lean`: `cValid_of_tm` / `cValid_swap_of_tm`, same fix (28 hits).
  - `Decidability/Verified/RuleSpec.lean`: `AxiomInstance := Σ φ, Axiom φ`. `ruleAxioms` lists `since_P`, `self_accum_since`, `prior_SZ`, `prior_S_gap` and `serial_past`. Replace each with its TR primary. The gates only read `a.2.minFrameClass`, which is equal, so `by decide` still closes. Document "grounded via TR".
  - `Automation/ProofSearch/Core.lean`: `matchAxiom : Formula → Option (Sigma Axiom)`. Move the mirror patterns into `matchDerived : Formula → Option (⊢ φ)`, which already exists at line 1044.
  - `Automation/Tactics/Search.lean`: the ``Axiom.X`` name list for `modal_search`. Add a parallel list of derived-def names applied with `exact`.
  - `Automation/FormulaEnumerator.lean`: returns `⟨_, Axiom.X⟩`. Drop the mirror seeds, or seed from derived formulas.
  - `Theorems/Perpetuity/Helpers.lean`: `applyAxiomTo (axiom_proof : Axiom (A.imp B))`. Callers passing `modal_4`/`modal_b` switch to the derivation variant.
  - `Decidability/ProofExtraction.lean`: `proofFromAxiom`. Callers are unchanged unless they pass mirrors.
- **Qualified construction sites**: 331 occurrences of `Axiom.<surplus>` outside Boneyard, excluding Plus/Star/Det, plus a few dot-notation `.since_P` sites.
  - Directories: Automation 62+15+15, BXCanonical/Chronicle 51, Conservativity/Plus 32, Theorems 30+4, Independence 28, Tests 48, and the remainder scattered.
  - Almost all have the shape `DerivationTree.axiom (fc := fc)? Γ _ (Axiom.X args) h_fc`, which a regex can rewrite.
- **Import-order constraint for `modal_4`/`modal_b`**:
  - `Theorems/Combinators.lean:664` (`temporalFutureDerived`) uses `Axiom.modal_4`.
  - `doubleNegation` lives in `Propositional/Core.lean`, which imports Combinators.
  - Either move `temporalFutureDerived` out of Combinators, or place the derived `modal_4`/`modal_b` in a new module after `Propositional.Core` that `ModalS4`, `ModalS5`, `Perpetuity`, `FMP/TruthPreservation`, `WeakCanonical/*` and `Algebraic/InteriorOperators` import.
  - `Metalogic/Core/DeductionTheorem.lean` and `Automation/LemmaDB.lean` use no surplus axiom, so there is no cycle.
- **TR mirrors have no import constraint**: they need only `Derivation.lean` and `reflect_time_involution`, so `ProofSystem/DerivedAxioms.lean` can sit directly after `Derivation.lean` and be re-exported by `FormalSystem/ProofSystem.lean`.

### External Resources

- These compiled prototypes (listed in Findings) are the evidence here. No Mathlib lemma is involved; the work is purely inside the repository's own Hilbert system.
- Existing helpers to reuse:
  - `Combinators.impTrans`, `theoremFlip`, `bCombinator`, `notNotIntro`, `topThm`
  - `Propositional.doubleNegation`
  - `orElim`, `orIntroL`, `orIntroR` and `deductionTheorem` (see `MinusLanguage/AxiomDischarge.lean`'s `dischargeTempLinearity`, which already reshuffles TL's disjuncts and becomes simpler once TL is verbatim)

### Recommendations

1. **Phase A: derived module first.**
   - Add `ProofSystem/DerivedAxioms.lean` with the 14 TR-derived defs while the constructors still exist, named e.g. `DerivedAxioms.since_P : ⊢[fc] …`.
   - Initially prove each by TR from the primary, so each can be checked green before any constructor is removed.
   - Add `Theorems/ModalS5Primitive.lean` (or similar) with `modal_4Derived` and `modal_bDerived`.
2. **Phase B: rewrite every construction site** to the derived defs. Add a `weaken`-to-Γ helper for the sites with non-empty `Γ`. The build stays green because the constructors still exist.
3. **Phase C: remove the 16 constructors** and the dead arms: soundness dispatchers, `minFrameClass`, `PlusAxiom.ofTM`, DatasetGenerator/ProofStepExtractor, the Plus/Coarsened arms switched to derivation-based validity, and RuleSpec switched to primaries. Keep every `*_valid` / `*_swap_valid` lemma for the mirrors as a plain lemma; the swap arms need them.
4. **Phase D: restate TL and CN verbatim**, right-associated. Keep the old forms as derived defs `temp_linearity_legacy` / `linear_until_legacy` (propositional permutation or regrouping) for the consumers that depend on the old order:
   - Tableau/RuleSpec "branches ARE the TL disjuncts"
   - `OrderedSeedConsistency`, `PointInsertion:252`, `RRelation:952`, `DiscreteUnfolding:154,241`
   - Re-derive `linear_since` / `temp_linearity_past` by TR from the new forms.
   - Re-prove `temp_linearity_valid` / `linear_until_valid` for the new statements. Only the disjunct permutation changes.
5. **Phase E: machine appendix and docs.**
   - `AxiomNames.allAxiomNames` goes from 45 to 29.
   - Update the `MachineAppendixMain` entries and regenerate `typst/generated/machine-appendix.{jsonl,typ}` and `status.typ` (`scripts/typst-status-counts.sh` derives the counts from source automatically).
   - `typst/chapters/03-proof-theory.typ`, `typst/SYNC-MAP.md`.
   - Rewrite `docs/reference/axiom-reference.md`: 29 primitives, then a "Derived mirrors" table.
   - Update the module docstrings in `Axioms.lean` and `PlusLanguage/Axioms.lean`, whose "the 45 TM schemata re-declared" claim becomes "29 TM schemata plus 16 TM-derivable schemata kept primitive in TM⁺".
6. **Phase F: tests and verification.**
   - Update `Tests/BimodalTest` (48 hits). Most are `modal_search` examples, which stay as theorems.
   - Run `lean_verify` on each derived def (expect only `propext`/`Classical`/`Quot.sound`, or none).
   - `lake build` detached and guarded.
7. `serial_future` (TS): restate as bare `F⊤` for exact fidelity, with `⊤ → F⊤` as a derived `serial_future_imp`. This touches 41 qualified sites, so it can be its own small phase, or be explicitly waived in the plan with the reason "trivially interderivable". The task only mandates TL and CN.

## Decisions

- Surplus set is 16 constructors: the task's 12 plus `modal_4`, `modal_b`, `prior_SZ`, `prior_S_gap`. `def:S5` and `def:BX-r` / `sub:Extension` state only MK/MT/M5 and future-direction UZ/PU.
- The paper's 3-way `∨` is right-associated, following the existing in-tree convention in `MinusLanguage.Axiom.temp_linearity` and `Formula.always`.
- `discrete_propagate_bwd` stays primitive as NA.
  - A rename (e.g. to `discrete_propagate_past`) is optional. It changes the machine-appendix `name` and dataset wire tags, so if done it should come with a `@[deprecated] alias` for term-level uses and a note in the dataset versioning.
  - The recommended default is to keep the name and fix the docstring and the axiom-reference row.
- `PlusAxiom`, `StarAxiom`, `DetAxiom` and `MinusLanguage.Axiom` keep their constructors. They are separate systems, and removing their mirrors is a possible follow-up, not part of this task.

## Risks & Mitigations

- **Mass rewrite churn (~330 sites)**: mitigated by the add-first/remove-last phasing. The build stays green until Phase C, and the rewrite is regex-shaped.
- **Dataset byte-stability**:
  - `data/*.jsonl` is gitignored and hosted on HF (`logos-labs/bmlogic-bench`). Local files contain mirror names; for example `data/proof_first_d2.jsonl` has 595 `since_P` hits.
  - Existing files are not rewritten by a build, so they stay byte-stable. Newly generated datasets would label mirror steps as `time_reflection` over a primary.
  - Mitigation: bump an explicit axiom-system version field in the generator metadata (e.g. `axiom_system: "paper-29"`), and keep `ProofFirstBenchmark` / `BenchmarkAnchorsMain` formula anchors, which are formula-level and still valid theorems. Do not regenerate the HF datasets in this task.
- **Dispatcher exhaustiveness**: a missed arm is a compile error, not a silent gap.
- **Tableau "branches are TL disjuncts" design**: point `RuleSpec`/Tableau commentary at `temp_linearity_legacy`, or reorder the tableau branches to the paper order. Reordering is riskier because the Termination/SubformulaProperty proofs index the branches, so prefer the legacy lemma.
- **`simpa` casts on Type-valued `DerivationTree`**: they compiled. If a def needs to be computable or reducible for `height`-based recursion, use an explicit `▸` with a proved formula equation instead.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| TR mirror `since_P` from `until_F` | `simpa using time_reflection …` | success | `[Formula.reflectTime, someFuture, somePast, top, reflect_time_involution]` |
| TR mirror `enrichment_since` | `simpa` | success | `[reflectTime, and, neg, reflect_time_involution]` |
| TR mirror `linear_since` | `simpa` | success | `[reflectTime, and, or, neg, reflect_time_involution]` |
| TR mirror `prior_S_gap` (RTime-gated) | `simpa` | success | adds `kPlus, kMinus` |
| TR mirror `prior_SZ` (ZTime-gated) | `simpa` | success | `[reflectTime, neg, someFuture, somePast, top, involution]` |
| `discrete_symm_bwd` | term `time_reflection _ (axiom …)` | success | definitional, no cast |
| `modal_b` from MT, M5 | term: contraposition via `theoremFlip`/`bCombinator`, `notNotIntro`, `doubleNegation`, `impTrans` | success | imports `Theorems.Propositional.Core` |
| `modal_4` from B, MN(M5), MK | term | success | as above |

## Context Extension Recommendations

- **Topic**: TR-derived mirror recipe.
- **Gap**: there is no context note on deriving a past mirror from a future primary via `time_reflection` + `reflect_time_involution` `simpa`.
- **Recommendation**: add a short pattern to `.claude/context/project/lean4/patterns/`. The edit goes in the source store `agent-system/extensions/lean/...`, not `.claude/`.

## Appendix

- Paper anchors used: `def:S5`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:BX-r`, `def:TMplus`, and `\aitem` keys MK MT M5 MP MN TN TR TS TC UE UT NP NF UI UC UF UG SU NA NB TL CN MF DN NN UZ Z1 PU SEP (`sub:Logic`, `sub:Extension`).
- Searches:
  - grep census of each surplus name across `FormalSystem/` and `Tests/` (Boneyard excluded).
  - grep for axiom-reflection closure maps (none).
  - grep for exhaustive `Axiom` dispatchers.
  - `lean_run_code` prototypes: two snippets, both clean.
- No Mathlib search tools were needed. The work is internal to the repository's Hilbert system.
