# Follow-Up Scope Specification

Written by this task's implementation round (plan `01_decidability-programme-review.md`,
Phases 1-3), recording what the cross-language decidability review found and handing the
consequences to the tasks they belong to. This file is a specification for the orchestrator or
the user to action via `/revise` and `/task`; it files nothing itself, revises no task, and edits
no other task's state. The inventory of record (Deliverables 1-3: the four-status inventory by
declaration name, the L-side account, and the ranked routes for both languages) is
`reports/01_decidability-programme-review.md` in this task directory; this file re-verifies the
anchors that inventory rests on (Section 0) and then specifies the scope changes (Sections A-H).

Format of record: `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md`.

Prior decision applied (from this task's `.decisions.json`, cycle 1): **Option A -- library
landing** for the refutations' Success-Metric reading (Section F). That adoption was made
autonomously from the research agent's own recommendation because the `user_decision` was marked
`blocking=false` and `/orchestrate` runs without confirmation gates. It is **not a user ruling**
and is re-openable via `/revise`; the ROADMAP gains an unchecked Phase 0 item asking the user to
confirm or overturn it.

## Section 0 -- Verification record (this round)

Every anchor the sections below cite was re-checked against the tree in this implementation round
(2026-10-03), independently of the research dispatch. Line numbers are "as of this round"; the
sections below cite declaration names and paths, never line numbers. Hypotheses are recorded
where a declaration carries one.

### 0.1 Compile record

```
lake env lean <scratchpad>/Verify721Impl.lean   (import FormalSystem)
Compression.decidableValidZTime : (φ : Syntax.Formula) → Decidable (Semantics.ValidZTime φ)
'FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
validZTime_iff_noCertifiedCandidate : ∀ (φ : Syntax.Formula),
  Semantics.ValidZTime φ ↔ ∀ W ∈ cands φ, ∀ t ∈ Finset.Icc 0 ↑(compressionBound [] [φ]), ¬W.Certifies t
'FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate' depends on axioms: [propext, Classical.choice, Quot.sound]
PlusSharingWitnessFamily.not_exists_plusCertifies_pumpTarget : ∀ (p : Syntax.Atom), ¬∃ S t, S.PlusCertifies t
'FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_exists_plusCertifies_pumpTarget' depends on axioms: [propext, Classical.choice, Quot.sound]
@WitnessFamily.no_witnessFamily_of_validZTime : ∀ {Γ Del : Syntax.Context} {σ : Syntax.Formula},
  σ ∈ Del → Semantics.ValidZTime σ → ∀ (W : WitnessFamily Γ Del) {t : ℤ},
  W.LocalCoherentLab → W.FulfillingLab → W.BoxFaithful → W.Target t → False
@sound_of_isValid : ∀ {φ : Syntax.Formula} (r : DecisionResult φ), r.isValid = true → ⊨ φ
isValid_sound : ∀ (φ : Syntax.Formula) (fc : ProofSystem.FrameClass), isValid φ fc = true → ⊨ φ
@PlusSharingWitnessFamily.plusTruth_iff_mem : ... S.PlusLocalCoherentShare → S.PlusThreadFulfilling →
  S.PlusBoxFaithful → S.StabFaithful → ∀ ψ ∈ plusClosureOf (Γ ++ Del), ∀ θ s t,
  PlusTruthAt (S.model hat) (S.hist θ s) t ψ ↔ ψ ∈ S.L (θ.idx (s + t)) (s + t)
@PlusSharingWitnessFamily.plusRefutes_of_certifies : ∀ {Γ Del} (S : PlusSharingWitnessFamily Γ Del) {t : ℤ},
  S.PlusCertifies t → PlusWitnessFamily.PlusRefutes Γ Del
@soundness_ztime_valid : ∀ {phi : Syntax.Formula} (d : ⊢[ProofSystem.FrameClass.ZTime] phi), Semantics.ValidZTime phi
FormalSystem.Metalogic.derivable_of_validZTime : Unknown identifier
  -> the declaration lives in namespace FormalSystem.Metalogic.BXCanonical (see row 14 below)
```

### 0.2 Declaration anchors

| # | Anchor | Path | Check run | Result |
|---|---|---|---|---|
| 1 | `Compression.decidableValidZTime` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` | `grep -n 'def decidableValidZTime'`; `#check`/`#print axioms` (0.1) | line 147: `def decidableValidZTime (φ : Formula) : Decidable (ValidZTime φ)`; a `def`, not an `instance`; `φ : Formula` (no `⊡`); empty premises; axioms `[propext, Classical.choice, Quot.sound]` |
| 2 | `validZTime_iff_noCertifiedCandidate` | same | grep; `#check`/`#print axioms` (0.1) | line 113; type as in 0.1; axioms `[propext, Classical.choice, Quot.sound]` |
| 3 | `decidableSemanticConsequenceNil` | same | `grep -n 'def decidableSemanticConsequenceNil'` | line 161: `def decidableSemanticConsequenceNil (σ : Formula)`; `Γ = []` only |
| 4 | `exists_witnessFamily_of_not_validZTime` | `.../WitnessFamily/Compression/Family.lean` | `grep -n 'theorem exists_witnessFamily_of_not_validZTime'` | line 153: `(φ : Formula) (h : ¬ ValidZTime φ)` |
| 5 | `Probe706.no_finite_carrier_sat`, `not_finite_carrier_fmp`, `θ_eq_ofFormula`, `no_ofStep_sat`, `no_finite_carrier_sat'`, `not_finite_carrier_fmp_fragment` | `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean` | `grep -n 'theorem no_finite_carrier_sat\|theorem not_finite_carrier_fmp\|theorem θ_eq_ofFormula\|Finite F.WorldState\|Finite W'` | `no_finite_carrier_sat` line 111 takes **`[Finite F.WorldState]`**; `no_ofStep_sat` line 178 takes **`[Finite W] [Nonempty W]`**; `not_finite_carrier_fmp` line 189 negates `∃ (F : FrameOver intOrder) (_ : F.IsRegular) (_ : Finite F.WorldState) ...`; `θ_eq_ofFormula` line 51 `: θ = ofFormula ψL := by decide` (the `⊡`-free witness); `no_finite_carrier_sat'` line 262, `not_finite_carrier_fmp_fragment` line 331 (the `⊡`-bearing fragment twin) |
| 6 | `Probe710.not_finite_width_fmp`, `not_sliced_complete`, `no_finite_width_sat`, `F_isRegular`, `Node`, `Step`, `path_eq_canon` | `specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean` | `grep -n 'theorem not_finite_width_fmp\|theorem not_sliced_complete\|theorem no_finite_width_sat\|Finite W\|inductive Node\|inductive Step\|theorem path_eq_canon\|F_isRegular'` | `not_finite_width_fmp` line 1164 negates `∃ (W : Type) (_ : Finite W) (_ : Nonempty W) (R : ℤ → W → W → Prop) ...`; `not_sliced_complete` line 1154; `no_finite_width_sat` line 1105 under `variable [Finite W] [Nonempty W] (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)` (line 981); `instance F_isRegular : F.IsRegular` line 218; `inductive Node` line 68, `inductive Step : Node → Node → Prop` line 77, `theorem path_eq_canon` line 361 |
| 7 | `Probe718.seamFibreEquiv`, `plusStab_iff_rays`, `seamOmegaEquiv`, `plusStab_iff_omega`, `glue` | `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` | `grep -n 'IsRegular\|def seamFibreEquiv\|def seamOmegaEquiv\|theorem plusStab_iff_rays\|theorem plusStab_iff_omega\|^variable\|^section\|^end '` | **all four keystone declarations sit under `[F.IsRegular]`**: `seamFibreEquiv` line 143 declaration-level `[F.IsRegular]`; `plusStab_iff_rays` line 189 under `variable {F : TaskFrame} [F.IsRegular]` (line 180, `section Stab`); `seamOmegaEquiv` line 344 under `variable [F.IsRegular]` (line 237, `section Omega`, `F : FrameOver intOrder`); `plusStab_iff_omega` line 364 under `variable {F : FrameOver intOrder} [F.IsRegular]` (line 354, `section StabOmega`); `glue` line 101 `[F.IsRegular]`. The one `omit [F.IsRegular] in` (line 257) covers an intermediate declaration, none of the four |
| 8 | `PlusSharingWitnessFamily.not_exists_plusCertifies_pumpTarget`, `plusCompression_fails_at_pumpTarget` | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/NoCertificate.lean` | grep; `#check`/`#print axioms` (0.1) | lines 425, 436; `∀ (p : Atom), ¬∃ S t, S.PlusCertifies t`, no hypothesis on succession, any lasso count; axioms `[propext, Classical.choice, Quot.sound]` -- the WITHDRAWN anchor |
| 9 | "Retired as vacuous" section | `FormalSystem/Metalogic/Decidability/Correctness.lean` | `grep -n 'Retired as vacuous\|validity_decidable\|validity_has_decision_procedure'` | line 192: `## validity_decidable / validity_has_decision_procedure — Retired as vacuous`; line 198: `validity_decidable (φ : Formula) : (⊨ φ) ∨ ¬(⊨ φ)` was `exact Classical.em (⊨ φ)`; line 203: `validity_has_decision_procedure (φ : Formula) : ∃ decision : Bool, decision = true ↔ ⊨ φ` -- the NOT ESTABLISHED anchor |
| 10 | `Probe718PathQuantifier.exists_ne_stab`, `exists_ne_universal` | `specs/evidence/seam-gluing-ray-product/path-quantifier-alternation.lean` | `grep -n 'theorem exists_ne_stab\|theorem exists_ne_universal'` | lines 159, 167; `exists_ne_universal (w₀ : Bool) : ExistsSummary w₀ ∧ ¬ AllPathsMeet w₀`; namespace `Probe718PathQuantifier` (line 40) |
| 11 | `Probe718FiniteGraph.will_iff_allPathsMeet`, `decide_will`, `decidable_will` | `specs/evidence/seam-gluing-ray-product/finite-graph-stab-summary.lean` | `grep -n 'theorem will_iff_allPathsMeet\|theorem decide_will\|decidable_will\|backward'` | lines 82, 148, 153 (`instance decidable_will`); header line 21 verbatim: "**The backward dual is NOT separately proved.** The fixture's relation is symmetric under time reversal (`Rf` ignores both its time and direction arguments)" |
| 12 | `Probe718Stratification.plusTruthAt_iff_stratum_atomize`, `stab_atomize_valuation` | `specs/evidence/seam-gluing-ray-product/stab-depth-stratification.lean` | grep | lines 106, 114; namespace line 36 |
| 13 | `Probe718Mosaic.amalgamate`, `amalgamate_unique`, `StabSaturated`, `stabSaturated_of_sameState` | `specs/evidence/seam-gluing-ray-product/mosaic-germ-amalgamation.lean` | `grep -n 'def StabSaturated\|def amalgamate\|theorem amalgamate_unique\|theorem stabSaturated_of_sameState\|IsRegular'` | `noncomputable def amalgamate` line 78, `amalgamate_unique` line 107, `def StabSaturated (S : Finset (Mosaic F t)) : Prop` line 127, `stabSaturated_of_sameState` line 138; all under `variable {F : TaskFrame} [F.IsRegular]` (line 49) |
| 14 | `soundness_ztime_valid`; `derivable_of_validZTime`; `Decidable (Derivable ...)` | `FormalSystem/Metalogic/Soundness.lean`; `FormalSystem/Metalogic/BXCanonical/Completeness.lean`; tree-wide | grep; `#check` (0.1); `grep -rn 'Decidable (Derivable' FormalSystem/` | `soundness_ztime_valid` line 1522, `(d : ⊢[FrameClass.ZTime] phi) → ValidZTime phi`; `derivable_of_validZTime (φ : Formula)` line 394 in **namespace `FormalSystem.Metalogic.BXCanonical`** (line 63) -- full name `FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime`; `Decidable (Derivable`: **zero hits** in `FormalSystem/` (the only match is `Verified/README.md:62`'s "not built" row) -- the L-E1 corollary is unwritten |
| 15 | `PlusSharingWitnessFamily.plusTruth_iff_mem`, `plusRefutes_of_certifies`; `PlusSlicedCertificate.plusRefutes_of_certifies` | `.../PlusWitnessFamily/Agreement.lean`; `.../PlusSlicedCertificate/Sound.lean` | grep; `#check` (0.1) | lines 183, 413; 330. Untouched by this task; soundness anchors only |
| 16 | `Probe476.fmp_false` | `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean` | grep | line 177: `theorem fmp_false (cands : Formula → List IntPresentation)`; namespace `Probe476` line 48 |
| 17 | `WitnessFamily.no_witnessFamily_of_validZTime` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Examples.lean` | `#check` (0.1) | hypotheses `σ ∈ Del`, `ValidZTime σ`, `W.LocalCoherentLab`, `W.FulfillingLab`, `W.BoxFaithful`, `W.Target t` |
| 18 | `BiLasso.decidableValidZTime` (the *conditional* one) | `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` | `grep -n decidableValidZTime` | line 100: a hypothesis-taking `def decidableValidZTime` distinct from row 1; its hypothesis is the candidate-list FMP that `Probe476.fmp_false` refutes |
| 19 | `Beh.germEquiv` (Germs clause) | `FormalSystem/Semantics/Presheaf/Behavior.lean` | `ls FormalSystem/Semantics/Presheaf/`; grep | `Site.lean`, `Behavior.lean`, `README.md` exist; line 286: `def germEquiv (F : TaskFrame) [F.IsRegular] : Beh F 0 ≃ F.WorldState` |
| 20 | `FrameOver.ofSlicedStep_isRegular` | `FormalSystem/Semantics/SlicedFrame.lean` | grep | line 293: `instance ofSlicedStep_isRegular {W : Type} [Finite W] [Nonempty W] ...` |
| 21 | `wlem_of_saturation` | `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean` | grep | lines 21, 36 (the "computes but not choice-free" record) |
| 22 | FMP README refutation subsection | `FormalSystem/Metalogic/Decidability/FMP/README.md` | grep | line 79: `### The finite-carrier route is refuted, not merely open`; lines 84-98 cite `Probe706.no_finite_carrier_sat` and `Probe710.not_finite_width_fmp` by name and state both scope limits (Z only; `⊡`-free versus `⊡`-bearing witness) |

### 0.3 Script and index anchors

| # | Anchor | Check run | Result |
|---|---|---|---|
| 23 | `scripts/check-evidence-probes.sh` arrays | `sed -n '/^WIRED=(/,/^)/p' ... \| grep -c '"'`; `awk '/^WIRED_REPO=\(/,/^\)/'` | `WIRED`: 11 entries. `WIRED_REPO`: 3 entries -- `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`, `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`, `specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`. Header line 33: "Prefer `WIRED`: reach for `WIRED_REPO` only with a named blocker recorded beside the entry" |
| 24 | `scripts/check-evidence-probes.sh` run | `timeout 280 bash scripts/check-evidence-probes.sh` | **exit 0**; `PASS  all 14 wired probe(s) compile`; one `SKIP (deferred: frame-class uniformity work)` on `bi-lasso-decision-layer/spike-untl-unfolding-and-fwd-obstruction`; all five `seam-gluing-ray-product/*` probes PASS; all three `WIRED_REPO` entries PASS |
| 25 | `docs/theorem-index.md` `pinned:C14` claims | `grep -n 'pinned:C14' docs/theorem-index.md \| grep -i 'validZTime\|decidableValidZTime\|witnessFamily'` | rows 147, 148, 149: `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime`, `...validZTime_iff_noCertifiedCandidate`, `...Compression.decidableValidZTime`, each `ZTime \| pcq pinned:C14` |
| 26 | `scripts/check-module-invariants.sh` baseline for those three | `grep -n 'Compression\.\|decidableValidZTime\|validZTime_iff_noCertifiedCandidate\|exists_witnessFamily_of_not_validZTime' scripts/check-module-invariants.sh` | **only lines 3411 and 3415** -- a comment and a tuple in the C-check shadowing allowlist (`("decidableValidZTime", "FormalSystem.Metalogic.Decidability", ...)`); no `#print axioms` line and no baseline line names any of the three. The C14 baseline does pin `sound_of_isValid` (lines 1998, 2202). **The `pinned:C14` claim on rows 147-149 is confirmed ungrounded** -- evidence for Section H2 |
| 27 | Stale-prose sample (for Section H1) | `grep -n 'sound direction only' FormalSystem/README.md`; `grep -n 'No decidability theorem' typst/FormalFoundations.typ` | `FormalSystem/README.md:408`: "decidability **sound direction only**"; `typst/FormalFoundations.typ:774`: "No decidability theorem is machine-checked." Both are false of the tree as of row 1 (true of the tableau only). The remaining surfaces named in H1 are taken from the research report's Appendix B and are to be re-verified by H1 before editing |

### 0.4 Task-record anchors (`specs/state.json`, read-only)

`jq` over `.active_projects[]` this round:

| Task | Status | Dependencies | Declared `file_scope` (where relevant) |
|---|---|---|---|
| 706 | `researched` | `[695, 696, 703]` | `PlusSlicedCertificate/FiniteCarrier.lean`, `PlusSlicedCertificate.lean`, `scripts/certificate-witness-inventory.txt`, `scripts/check-module-invariants.sh`, `docs/theorem-index.md` |
| 709 | `not_started` | `[703, 710]` | -- |
| 710 | `researched` | `[703]` | `PlusSlicedCertificate/Limits/NoFiniteWidth.lean`, `PlusSlicedCertificate.lean`, `PlusSlicedCertificate/EmbedComplete.lean`, `Semantics/IntNormalForm.lean`, `docs/theorem-index.md`, `scripts/check-evidence-probes.sh` |
| 711 | `blocked` (no recorded reason field) | `[]` | -- |
| 712 | `blocked` (no recorded reason field) | `[703, 711]` | -- |
| 713 | `not_started` | `[]` | -- |
| 718 | `completed` | `[]` | -- |
| 719 | `not_started` | `[563, 564, 718]` | `FormalSystem/Semantics/PartialHistory.lean`, `Rays.lean`, `Gluing.lean` |
| 720 | `not_started` | `[706, 710]` | `specs/evidence/seam-gluing-ray-product/`, `scripts/check-evidence-probes.sh`, `FormalSystem/Metalogic/Decidability/FMP/README.md` |
| 430 | `not_started` | `[428, 429, 411]` | -- |
| 412 | `not_started` | `[410, 411, 428, 430]` | -- |
| 563 | `completed` | `[]` | -- |
| 564 / 565 / 566 / 616 / 618 | `not_started` | `[563]` / `[563]` / `[563, 565]` / `[563]` / `[563, 564, 616]` | -- |
| 177 | `not_started` | 26 deps incl. 706, 543 | -- |
| 543 | `not_started` | `[500, 652, 656, 683]` | -- |
| 721 | `implementing` | `[]` | -- |

- Open-task count (status not in `completed`/`abandoned`/`expanded`): **51**. Completed-but-unarchived in `active_projects`: `[718, 717, 563]`.
- Completion commits: `58f8afb39` `task 718: complete implementation` (2026-10-03); `4cab01773` `task 563: complete implementation` (2026-10-03).
- `specs/ROADMAP.md` last commit before this round: `b5affb6e3` (2026-10-02, "task 718: write the gluing-route seed report; roadmap: make the gluing route Phase 1").
- File-scope collision relevant to Section F: 706 and 710 both declare `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` and `docs/theorem-index.md`; 710 and 720 both declare `scripts/check-evidence-probes.sh`.

### 0.5 Differences from the research report

- Row 14: the report cited `derivable_of_validZTime` by path and line only; its namespace is `FormalSystem.Metalogic.BXCanonical`, so the H3 specification uses the full name. No claim in the report is contradicted.
- No other anchor differs. Every status the report assigns (PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED) was re-derivable from rows 1-27 this round; the research report is not edited.
- Not re-verified this round and therefore cited below only via the report: `Verified.ruleSound_of_mem_allRulesForFC` (report Appendix A), the `Decidable (⊨ φ)`-prose hit list beyond row 27 (report Appendix B).

## Section A -- Task 712 (L⁺ sliced finite model property)

_(Phase 2 fills this section.)_

## Section B -- Task 711 (ω-automata determinization substrate)

_(Phase 2 fills this section.)_

## Section C -- Task 713 (CTL⋆ 2EXPTIME reduction)

_(Phase 2 fills this section.)_

## Section D -- Task 709 (F4 periodicity)

_(Phase 2 fills this section.)_

## Section E -- Task 719 (ray layer, seam gluing and stab fibre)

_(Phase 2 fills this section.)_

## Section F -- Tasks 706, 710, 720 (the refutations' library landing)

_(Phase 2 fills this section.)_

## Section G -- Tasks 430 and 412 (tableau spine)

_(Phase 2 fills this section.)_

## Section H -- New tasks to file

_(Phase 3 fills this section.)_

## The 711 tension

_(Phase 2 fills this section; see Section B.)_

## Ranking ratification

_(Phase 3 fills this section.)_

## State-write disclosure

_(Phase 3 fills this section.)_
