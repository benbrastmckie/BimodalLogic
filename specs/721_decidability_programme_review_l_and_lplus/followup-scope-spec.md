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
| 27 | Stale-prose sample (for Section H1) | `grep -n 'sound direction only' FormalSystem/README.md`; `grep -n 'No decidability theorem' typst/FormalFoundations.typ` | `FormalSystem/README.md:408`: "decidability **sound direction only**"; `typst/FormalFoundations.typ:774`: "No decidability theorem is machine-checked."; `FormalSystem/Metalogic/Decidability/BiLasso/README.md:11-12` (`grep -in 'machine-checked'`): "... no decidability theorem is machine-checked at present" (the phrase wraps across the two lines, which is why a single-line grep for it returns nothing). All three are false of the tree as of row 1 (true of the tableau only). The remaining surfaces named in H1 are taken from the research report's Appendix B and are to be re-verified by H1 before editing |

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
- Phase 5 sweep finding: `verifyProof` -- named by the report (§1.2, "`verifyProof` is `fun _ _ => true` (`ProofExtraction.lean`)"), by task 482's description, and by the pre-edit ROADMAP -- does **not** exist anywhere in the tree (`grep -rn verifyProof FormalSystem/ docs/` empty; `ProofExtraction.lean` defines `proofFromAxiom`, `extractFromClosureReason`, `tryAxiomProof`, `buildCompositionalProof`, `enhancedSearch`, `extractProof`, `findProofCombined`, no verifier). `.extractionFailed` is a live `DecisionResult` outcome (`Correctness.lean`) and `Verified/Refutation/` does not exist, so the substance of the "no proof-extraction completeness" claim stands; only the declaration name is stale. The ROADMAP rows were corrected to checkable wording; 482's description is out of this task's scope and should re-verify its anchors at its next `/revise`.
- Not re-verified this round and therefore cited below only via the report: `Verified.ruleSound_of_mem_allRulesForFC` (report Appendix A), the `Decidable (⊨ φ)`-prose hit list beyond row 27 (report Appendix B).

## Section A -- Task 712 (L⁺ sliced finite model property)

**Current record** (Section 0.4): `[BLOCKED]`, dependencies `[703, 711]`, no blocked-reason field.

**What the tree says.** The statement 712 was filed to prove is machine-checked FALSE:
`Probe710.not_sliced_complete` and `Probe710.not_finite_width_fmp`
(`specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`, a
`WIRED_REPO` probe, PASS this round -- Section 0 rows 6 and 24). The refutation is over
`FrameOver.ofSlicedStep R fwd bwd` with `[Finite W] [Nonempty W]` and a time-indexed bi-serial
`R : ℤ → W → W → Prop`, with no hypothesis on the succession relation's shape. Two scope limits
hold, as `FMP/README.md` already states (row 22): the result is over **Z (discrete) frames only**,
and its witness `Φ := θ' ∧ □(⊡Fp → ¬⊡¬Xp)` **uses `⊡`**, so it is specifically an L⁺ result. The
status of record is therefore **REFUTED AS A THEOREM** (probe level), not "open"; 712's own
description already converted itself to a refutation record and deliberately left the status
untouched.

**Scope change required.**

1. Remove dependency `711`. The determinization blocker gated *proving* the statement; the
   statement is refuted, so the edge is now meaningless and its only effect is to make 711 look
   load-bearing for a result that no longer exists.
2. Record in the description that the terminal status is a Phase 0 user ruling with two honest
   options: `[ABANDONED]` (the statement is false), or `[COMPLETED]` as a refutation record once
   the refutation is landed as a library theorem under Section F's Option A (which task 720 as
   filed does **not** do -- it moves probe files into `specs/evidence/`). Research
   recommendation, stated and **not decided here**: hold 712 open only until the library landing
   exists, then close it as a refutation record; do not close it on the probe alone, since the
   programme's own rule -- stated in 709, 712 and 719 -- is that obstructions live as theorems.

**What this task must NOT do**: change 712's status or dependencies, or mark the Phase 0 ruling
decided. The dependency edge is removed by `/revise`, the status by the user.

**Action required**: `/revise 712` (dependency removal; description note on the two terminal
options), by the orchestrator or the user. The terminal-status call itself is the Phase 0 ruling
on 712 in `specs/ROADMAP.md`, user-only.

## Section B -- Task 711 (ω-automata determinization substrate)

**Current record** (Section 0.4): `[BLOCKED]`, dependencies `[]`, no blocked-reason field.

**The tension, verbatim from both records.**

- `specs/ROADMAP.md`, Phase 0 (as of `b5affb6e3`): "Rule on task 711, the ω-automata
  determinization substrate: it was filed only to make the blocker visible, and the route it names
  is now closed, so the honest outcome is ABANDONED rather than completed (Task 711)".
- `specs/718_omega_sequence_decidability_full_lplus/.decisions.json`, cycle 1: "Revive 711 only
  after R1's falsification probes 1-3 land, so determinization is funded on evidence of necessity
  rather than expectation".

**What the probes actually showed** (Section 0 rows 10-11). The three R1 probes landed (718
Phases 2, 3, 5). `Probe718PathQuantifier.exists_ne_stab` and `exists_ne_universal`
(`specs/evidence/seam-gluing-ray-product/path-quantifier-alternation.lean`) prove on the shared
`Bool` fixture that the existential (nondeterministic) per-path summary is `True` everywhere while
`⊡(Fp)` is `False` everywhere (`Probe718FiniteGraph.decide_will`). So **a universal,
complementation-shaped summary device is NECESSARY** on that fixture; a nondeterministic summary
is unsound. The probes do **not** show that Safra/Piterman determinization specifically is that
device. At least three universal-summary devices are live candidates: (a) Safra/Piterman
determinization; (b) Safraless procedures (Kupferman-Vardi 2005; `~/Projects/Literature/
SOURCES.md` D8, a wanted source, which also records that no formalization of Safra or Piterman
exists in any proof assistant); (c) the MSO-over-`⟨ℤ,<⟩`-plus-Büchi route of
Hodkinson-Wolter-Zakharyaschev 2000 (their route (1); no Safra construction;
`.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` §8); (d) a
Ramsey-coloured summary as in finding F4 (task 709's re-scoped statement). None has been selected
by a probe.

**Both records are partly right.** The route 711 *names* (Emerson-Jutla determinization via
Reynolds 2001, for the FMP of 712) is closed with 712 (Section A) -- the ROADMAP is right about
that route. The *need* 711 was filed to make visible has been re-demonstrated on R1 -- the
decision's evidence condition is **met**. Neither record considered that the probes would answer
a different question (device necessity) from the one 711 was filed on (an FMP route) and the one
the ROADMAP ruled on (the closed route).

**Resolution: REVISE** -- neither abandon as filed nor revive as filed.

**Scope change required.**

1. Re-title and re-describe 711 as "universal-summary substrate for the `⊡` fibre check on the
   seam-gluing route", listing the four candidate devices above and stating that the device is to
   be selected by probe E3 (Section "Ranking ratification"), not assumed.
2. Re-point its consumer from 712 (refuted) to 719 Deliverable 5 (the decidable-check connection).
3. Keep `[BLOCKED]`, with the recorded reason "device not yet selected; probe E3 pending".
4. Keep the prohibition, already in 719's record, that no phase of 719 builds the substrate.

**Phase 0 ruling restated.** The ruling on 711 is **newly answerable** -- the decision's evidence
condition is met and a third option exists -- and is **not decided here**. The ROADMAP's Phase 0
bullet is annotated with the third option and left unchecked.

**What this task must NOT do**: change 711's status, title, or dependencies, or mark the ruling
decided.

**Action required**: `/revise 711` (re-title, re-describe, re-point consumer, record the blocked
reason), by the orchestrator or the user, after the user's Phase 0 ruling selects REVISE over
ABANDON.

## Section C -- Task 713 (CTL⋆ 2EXPTIME reduction)

**Current record** (Section 0.4): `[NOT STARTED]`, dependencies `[]`, filed not scheduled;
nothing depends on it.

**Its actual role.** Three records -- 718's ranked-route analysis, 719's description, and this
review's report §3.1 -- *use* 713's ARGUED (not formalized) 2EXPTIME lower bound as the **sanity
ceiling** on any proposed decision procedure: nothing cheaper than that bound is credible. It is
load-bearing as a check even while unproved. No record lands an upper bound from it, and none may:
this review commits to **no complexity bound** (hard constraint).

**Scope change required.** Revise the description to (i) record that role explicitly, naming the
three citing records; (ii) forbid landing any *upper*-bound claim from it; (iii) leave it
unscheduled.

**Phase 0 ruling restated.** Keep as a write-up note (recommended, because it is load-bearing as a
check) or abandon -- the user's call, **not decided here**.

**What this task must NOT do**: schedule 713, change its status, or assert any complexity bound.

**Action required**: `/revise 713` (description only), by the orchestrator or the user. The
keep-or-abandon call is the Phase 0 ruling on 713, user-only.

## Section D -- Task 709 (F4 periodicity)

**Current record** (Section 0.4): `[NOT STARTED]`, dependencies `[703, 710]`.

**What changed.** 718's ranked-route analysis demoted F4 ("finite width ⇒ eventually periodic")
from a route to a **component of R1** (R3 in both rankings: "a COMPONENT, not a route"). Its
premise, finite width, is refuted for any *complete* class (`Probe710.not_finite_width_fmp`,
Section 0 row 6); as R1's summary step it is either replaced by an automaton acceptance condition
or is exactly the Ramsey-coloured device (candidate (d) in Section B). `specs/ROADMAP.md` Phase 2
("Task 709 is the phase's substance and the only item that is open mathematics"; "`/orchestrate
709 --hard` ... the one real theorem on this front") and 709's own re-scoped headline both predate
that demotion.

**Scope change required.**

1. Re-describe 709 to state that F4 is R1's summary step, sequenced under the gluing route (719),
   not Phase 2's capstone.
2. Add dependency `719`, keeping `[703, 710]`.
3. Record the fallback already in its description -- restrict the fragment to safety/bounded-step
   `⊡` operators, excluding AF-style unbounded eventualities -- as the alternative if R1 selects an
   automaton acceptance condition over a Ramsey colour, in which case F4 is unnecessary and 709
   closes as a reasoned exclusion (`[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions`
   record), not as a failure.

**What this task must NOT do**: change 709's dependencies or status itself; the ROADMAP edit
(Phase 4 of this plan) states "if Section D is adopted" rather than assuming it.

**Action required**: `/revise 709` (description; add dependency 719), by the orchestrator or the
user.

## Section E -- Task 719 (ray layer, seam gluing and stab fibre)

**Current record** (Section 0.4): `[NOT STARTED]`, dependencies `[563, 564, 718]`, `file_scope`
`FormalSystem/Semantics/{PartialHistory,Rays,Gluing}.lean`. Already revised once to consume 718
(`specs/718_.../followup-scope-spec.md` Section 1).

**What the evidence says about its weakest point.** The route 719 promotes has only its
**forward** finite-graph factor proved (`Probe718FiniteGraph.will_iff_allPathsMeet`, `decide_will`,
`decidable_will`, on the `Bool` complete-graph fixture, `⊡(Fp)` only); the backward dual is a
recorded exclusion justified by the fixture's time-reversal symmetry (Section 0 row 11, header
quoted verbatim). But the finite-width obstruction is located in the *backward* factor
(`Probe710`'s contradiction pigeonholes backward post-chains at unboundedly early times), so a
symmetric fixture is exactly the one that cannot see it.

**Scope change required** (two additions; no dependency change).

1. Deliverable 5 (the decidable-check connection) names experiment **E1** -- the backward-dual
   finite-graph probe on a time-asymmetric fixture, reusing `Probe710.Node`/`Probe710.Step`
   (finitely branching, every node with exactly one predecessor, bi-infinite paths canonical by
   `Probe710.path_eq_canon`), deciding `⊡(Pp)` at a seam state by backward reachability, mirroring
   `will_iff_allPathsMeet` -- as its **first** probe. One file under
   `specs/evidence/seam-gluing-ray-product/`, no automata. 719's Deliverables 1-4 are promotion
   work and do not wait on it.
2. Acceptance requires that every promoted keystone declaration -- `seamFibreEquiv`,
   `plusStab_iff_rays`, `seamOmegaEquiv`, `plusStab_iff_omega` -- carry **`[F.IsRegular]`
   verbatim** (Section 0 row 7: every one of the four sits under that instance, discharged through
   `TaskFrame.comp` plus the reflection convention), neither weakened to a bare `TaskFrame` nor
   strengthened. Promotion that restates the keystone as unconditional is a defect.

**What this task must NOT do**: build E1, or touch 719's `file_scope`.

**Action required**: `/revise 719` (Deliverable 5 text; acceptance clause), by the orchestrator or
the user. If 719 is not dispatched within the cycle, E1 is filed separately as Section H4.

## Section F -- Tasks 706, 710, 720 (the refutations' library landing)

**Current records** (Section 0.4): 706 `[RESEARCHED]`, deps `[695, 696, 703]`; 710
`[RESEARCHED]`, deps `[703]`; 720 `[NOT STARTED]`, deps `[706, 710]`, `file_scope`
`specs/evidence/seam-gluing-ray-product/`, `scripts/check-evidence-probes.sh`,
`FormalSystem/Metalogic/Decidability/FMP/README.md`.

**The two readings that cannot both stand.** The ROADMAP's Success Metric reads "Every refutation
the programme has produced lives in `FormalSystem/` as a cited theorem, not only under a task's
`probes/` (Tasks 706, 710)", and its Phase 2 items say "Land the finite-width refutation as library
theorems under `PlusSlicedCertificate/Limits/NoFiniteWidth.lean` (Task 710)" and "Land task 706's
finite-carrier refutations into `FormalSystem/` (Task 706)". Task 720's filed scope (its own
SCOPE NOTE) moves both probe files to `specs/evidence/seam-gluing-ray-product/` and re-points
`FMP/README.md`, stating that "genuine promotion into the `FormalSystem/` library proper would be a
different and larger task". Reading (A), library landing: 706 and 710 land the refutations as
`FormalSystem/` theorems; 720 re-points citations to library names. Reading (B), evidence
collection: the Success Metric is revised to accept the CI-guarded `specs/evidence/` collection as
the home of refutations (`check-evidence-probes.sh`'s own header reading: a probe outlives the
task that produced it by construction).

**Adopted: Option A -- library landing** (this task's `.decisions.json`, cycle 1), **with this
caveat carried verbatim in substance**: the adoption was made autonomously from the research
agent's own recommendation because the `user_decision` was marked `blocking=false` and
`/orchestrate` runs without confirmation gates. It is **NOT a user ruling**; re-open via `/revise`
if the user prefers Option B. The ROADMAP gains an unchecked Phase 0 item asking for confirmation.
The research's reason for (A): `FMP/README.md` (row 22) and the domain note both cite
`Probe706.no_finite_carrier_sat` and `Probe710.not_finite_width_fmp` as closing what the library
called open, and the programme rule "obstructions live as theorems" is stated in 709, 712 and 719.

**Scope change required under Option A.**

1. **Task 710**: its implementation scope is the library landing of `not_finite_width_fmp`,
   `not_sliced_complete` and the core `no_finite_width_sat` (with the `[Finite W] [Nonempty W]`
   hypotheses and the `⊡`-bearing witness `Φ` stated) under
   `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean`, which
   710's declared `file_scope` already names; plus `docs/theorem-index.md` rows for them.
2. **Task 706**: its implementation scope is the library landing of the `no_finite_carrier_sat`
   family (`no_finite_carrier_sat` with `[Finite F.WorldState]`, `no_ofStep_sat` with
   `[Finite W] [Nonempty W]`, `not_finite_carrier_fmp`, `θ_eq_ofFormula`, and the `⊡`-bearing
   fragment twins) into a `FormalSystem/` home chosen by 706's plan -- its declared `file_scope`
   already names `PlusSlicedCertificate/FiniteCarrier.lean` as a natural candidate; plus
   `docs/theorem-index.md` rows. The `⊡`-free status of the main witness
   (`θ_eq_ofFormula : θ = ofFormula ψL`) must be stated in the landed docstring, since it is what
   makes this half a result about TM itself.
3. **Task 720**: revise to re-point the `FMP/README.md` and `scripts/check-evidence-probes.sh`
   citations to the library names once landed, converting or deleting the two `WIRED_REPO` entries
   accordingly -- or close 720 as subsumed if the landing leaves no probe file to move (the
   `Probe476.fmp_false` `WIRED_REPO` entry is an archived task's and is out of 720's scope either
   way).
4. **Named collisions** (Section 0.4): 706 and 710 both declare
   `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` and `docs/theorem-index.md`;
   710 and 720 both declare `scripts/check-evidence-probes.sh`. They cannot be batched; order
   710 → 706 → 720, as the ROADMAP's Phase 2 Run block already sequences the first two.

**Under Option B instead**: revise the Success Metric text (ROADMAP) and leave 706/710/720 as
filed. Not adopted; listed so the user's choice is a one-line reversal.

**What this task must NOT do**: edit 706, 710 or 720's records, or move or edit any probe file.

**Action required**: `/revise 710`, `/revise 706`, `/revise 720` (implementation scope per items
1-3), by the orchestrator or the user, **after** the user confirms Option A in the Phase 0 item
this task adds to `specs/ROADMAP.md`.

## Section G -- Tasks 430 and 412 (tableau spine)

**Current records** (Section 0.4): 430 `[NOT STARTED]`, deps `[428, 429, 411]`; 412
`[NOT STARTED]`, deps `[410, 411, 428, 430]`.

**What changed.** Z-time validity of the base language L is already decided by another route:
`FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime : (φ : Formula) → Decidable
(ValidZTime φ)` (Section 0 row 1; `FrameClass.ZTime`, `φ : Formula` with no `⊡`, empty premises,
a `def`, axioms `[propext, Classical.choice, Quot.sound]`). After Section H3 lands,
`Decidable (Derivable .ZTime [] φ)` will exist by the same route via
`soundness_ztime_valid` and `FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime` (row
14). The spine's deliverable is therefore the **four-class** biconditional
`isValid φ fc = true ↔ ⊨ φ` with `Decidable (⊨ φ)` at Base/Dense/ZTime/RTime, and the spine is the
only route *filed* for Base, Dense and RTime -- not the only route to any decidability result.
Today the spine has the sound direction only (`sound_of_isValid`, `isValid_sound`; the
`validity_decidable`/`validity_has_decision_procedure` forms were retired as vacuous, row 9).

**Scope change required** (descriptions only; no dependency change).

1. **Task 430** (the semantic lift, `valid_iff_allClosed`): record that `Decidable (ValidZTime φ)`
   exists by the witness-family route, that the spine's deliverable is the four-class
   biconditional, and that its ZTime instance has an **independent oracle** it must agree with --
   cross-check L-E3 (Section "Ranking ratification"): `decide` and
   `Compression.decidableValidZTime` run on the negation of the `posFamily` target
   `□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)`; the tableau must not report `.valid` where the certificate route
   refutes.
2. **Task 412** (decidability of provability): record that `Decidable (Derivable .ZTime [] φ)` is
   a few-line corollary of the witness-family route (H3) and that 412's content is the other three
   classes plus the completeness corollaries through the tableau.

**What this task must NOT do**: write `valid_iff_allClosed` or any `isValid`-shaped `iff`, or
reopen the C9 do-not-re-attempt register.

**Action required**: `/revise 430`, `/revise 412` (descriptions only), by the orchestrator or the
user.

## Section H -- New tasks to file

Five tasks. Each is filed with `/task` by the orchestrator or the user; none is filed by this task.
Every entry re-verifies its own anchors before editing, per the hard constraint that no status
claim is written unchecked.

### H1 -- Prose reconciliation of the decidability status

**Proposed title**: Reconcile the programme-level decidability prose with the two-statement
distinction (tableau biconditional open; `Decidable (ValidZTime φ)` proved)

**Proposed `task_type`**: `markdown` (or `general`; the `typst/FormalFoundations.typ` edit may
route the typst sentence through the typst extension)

**Proposed dependencies**: none mathematical. Run in a **separate cycle** from tasks 177 (owns the
documentation territory and depends on 26 tasks) and 543 (declares `README.md`), whose
`file_scope` values collide with this one.

**Proposed `file_scope`**: `README.md`, `FormalSystem/README.md`,
`FormalSystem/Metalogic/Decidability/README.md`, `FormalSystem/Metalogic/Decidability.lean`
(module docstring only), `FormalSystem/Metalogic/Decidability/BiLasso/README.md`,
`docs/architecture/ADR-007-Decidability-One-Directional.md`,
`docs/project-info/known-limitations.md`, `typst/FormalFoundations.typ`.

**Description**: Every programme-level surface describes only the tableau spine and so states or
implies that no decidability theorem is machine-checked (Section 0 row 27: `FormalSystem/README.md`
"decidability **sound direction only**"; `typst/FormalFoundations.typ` "No decidability theorem is
machine-checked"; `BiLasso/README.md` "no decidability theorem is machine-checked at present";
the remaining surfaces per the research report's Appendix B hit list, to be re-verified first).
State the two-statement distinction **once**, in each surface's own register: (i) the tableau
`isValid φ fc = true ↔ ⊨ φ` biconditional, and `Decidable (⊨ φ)` through it, are open at all four
frame classes (sound direction only: `sound_of_isValid`, `isValid_sound`); (ii)
`FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime : (φ : Formula) → Decidable
(ValidZTime φ)` is proved -- `FrameClass.ZTime`, `Formula` (no `⊡`), empty premises, a `def`,
axioms `[propext, Classical.choice, Quot.sound]`, computing but not choice-free. Point every surface
at `docs/theorem-index.md`'s Decidability rows. ADR-007's rule "no surface may say decidability is
fully proven" stays correct and gains the sentence that the Z-time witness-family result is the one
decidability theorem that *is* proven. The typst remark that "neither factor logic is known
decidable" is corrected to: the Discrete factor is; the identity
`Log(all task frames) = Log(Discrete) ∩ Log(Dense)` remains a target, not a theorem (no Lean
declaration states it). **Never** write "TM is decidable" unqualified.

**Action required**: file with `/task`, by the orchestrator or the user.

### H2 -- Pin the three witness-family decidability rows in the C14 baseline

**Proposed title**: Ground the `pinned:C14` claim on the three witness-family decidability rows of
`docs/theorem-index.md`

**Proposed `task_type`**: `general` (shell edit; `lean4` only if the baseline requires a fresh
`#print axioms` capture)

**Proposed dependencies**: none. Collides with task 706's declared `file_scope`
(`scripts/check-module-invariants.sh`) -- run in a different cycle from 706 and 705.

**Proposed `file_scope`**: `scripts/check-module-invariants.sh` (and `docs/theorem-index.md` only
if the outcome is to correct the rows rather than the baseline).

**Description**: `docs/theorem-index.md` rows 147-149 (as of this round) claim `pcq pinned:C14`
for `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime`,
`...validZTime_iff_noCertifiedCandidate` and `...Compression.decidableValidZTime`, but
`grep -n 'Compression\.\|decidableValidZTime\|validZTime_iff_noCertifiedCandidate\|exists_witnessFamily_of_not_validZTime' scripts/check-module-invariants.sh`
hits only lines 3411 and 3415, the C-check shadowing allowlist -- no `#print axioms` line and no
baseline entry (Section 0 rows 25-26, run this round; the research dispatch found the same). The
index's promise that every listed declaration is machine-pinned is false for exactly the three
rows this review headlines. **Re-verify first** by re-running that grep; if the pin lives under a
name both greps missed, close with that finding. Otherwise add the three names to the C14 baseline
pair (`#print axioms` line plus expected-output line) so the `pinned:C14` cell becomes true, and
confirm `bash scripts/check-module-invariants.sh` still passes.

**Action required**: file with `/task`, by the orchestrator or the user.

### H3 -- `Decidable (Derivable .ZTime [] φ)` by the witness-family route (L-E1)

**Proposed title**: Decidability of Z-time provability as a corollary of
`Compression.decidableValidZTime`

**Proposed `task_type`**: `lean4`

**Proposed dependencies**: none (every input is landed; Section 0 rows 1 and 14).

**Proposed `file_scope`**: `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`
(or a sibling module under `WitnessFamily/Compression/`), `docs/theorem-index.md`. If the
corollary needs `FormalSystem.Metalogic.BXCanonical`, check the import graph first -- the
corollary may have to live in a module downstream of both `Compression/Assembly.lean` and
`BXCanonical/Completeness.lean` rather than in `Assembly.lean` itself.

**Description**: `soundness_ztime_valid : (d : ⊢[FrameClass.ZTime] φ) → ValidZTime φ`
(`FormalSystem/Metalogic/Soundness.lean`) and
`FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime (φ : Formula)`
(`FormalSystem/Metalogic/BXCanonical/Completeness.lean`) together give
`Derivable .ZTime [] φ ↔ ValidZTime φ`; `decidable_of_iff` with
`Compression.decidableValidZTime` finishes `Decidable (Derivable FrameClass.ZTime [] φ)`. A few
lines. `grep -rn 'Decidable (Derivable' FormalSystem/` returns nothing today (row 14), so this is
unwritten, not duplicated. Add the `docs/theorem-index.md` row, and (per H2) a C14 baseline
entry. This closes "decidability of provability over Z" -- one of the four classes Phase 6 of the
ROADMAP lists as a spine deliverable -- now, without the spine; record that in the docstring and
leave the other three classes to task 412 (Section G).

**Action required**: file with `/task`, by the orchestrator or the user.

### H4 -- Backward-dual finite-graph probe on a time-asymmetric fixture (E1)

**Proposed title**: Backward-dual `⊡(Pp)` finite-graph summary on the `Probe710` fixture

**Proposed `task_type`**: `lean4`

**Proposed dependencies**: none (the fixture and the forward probe are landed). Collides with
task 720's declared `file_scope` (`specs/evidence/seam-gluing-ray-product/`,
`scripts/check-evidence-probes.sh`) -- run in a different cycle from 720.

**Proposed `file_scope`**: `specs/evidence/seam-gluing-ray-product/` (one new probe file),
`scripts/check-evidence-probes.sh` (one new `WIRED` entry).

**Description**: The forward finite-graph summary is proved
(`Probe718FiniteGraph.will_iff_allPathsMeet`, `decide_will`, `decidable_will`) on a `Bool`
fixture whose relation is symmetric under time reversal, and the backward dual is a recorded
exclusion for that reason (Section 0 row 11). The finite-width obstruction lives in the backward
factor. Build the backward dual on a **time-asymmetric** fixture: reuse `Probe710.Node` and
`Probe710.Step` (`specs/710_.../probes/NoFiniteWidthModel.lean`; finitely branching, exactly one
predecessor per node, bi-infinite paths canonical by `Probe710.path_eq_canon`) and decide
`⊡(Pp)` at a seam state by backward reachability, mirroring `will_iff_allPathsMeet`. Either
outcome is the deliverable: a proof shows the two-factor presentation survives at the factor the
refutation lives in; a counterexample falsifies R1's two-factor presentation and is recorded in
the probe's header as such. No automata; no complexity claim.

**Fold-in rule**: this is Section E's first probe for 719 Deliverable 5. File it separately
**only if 719 is not dispatched within the cycle**; if 719 is dispatched, the probe belongs to 719
and H4 is not filed.

**Action required**: file with `/task` (conditionally, per the fold-in rule), by the orchestrator
or the user.

### H5 -- Make the decidability-programme review re-runnable

**Proposed title**: Re-runnable decidability inventory: regenerate the four-status table from the
tree

**Proposed `task_type`**: `meta` (if implemented as a `/review` step or script under the agent
system) or `general` (if implemented as a standing task with a script under `scripts/`)

**Proposed dependencies**: none.

**Proposed `file_scope`**: `scripts/` (one new script) or the agent-system source store for a
`/review` step; `specs/ROADMAP.md` Maintenance section (name the owner).

**Description**: The task description's complaint -- every review of the decidability programme is
a completed task's artifact that nothing re-runs, and `specs/ROADMAP.md` is a document no task
owns refreshing -- is correct, and this task does not fix it by itself. Build the mechanism:
regenerate the PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED inventory from three machine
sources -- `docs/theorem-index.md`'s Decidability rows (with their `pinned:` cells cross-checked
against `scripts/check-module-invariants.sh`'s baselines, so H2's class of defect is caught
mechanically), `scripts/check-evidence-probes.sh`'s `WIRED` and `WIRED_REPO` arrays (refutations
and their recorded blockers), and `FormalSystem/Metalogic/Decidability/Correctness.lean`'s
"Retired as vacuous" section (the NOT ESTABLISHED anchor) -- and diff it against
`specs/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md`
§1 as the baseline. The ROADMAP's Maintenance section names this task as the owner of the periodic
re-run until it is filed, then the mechanism.

**Action required**: file with `/task`, by the orchestrator or the user.

## The 711 tension

Resolved in Section B by **REVISE**: the ROADMAP's ABANDONED is right about the route 711 *names*
(closed with the refuted 712); the 718 decision's "revive on evidence of necessity" has its
evidence condition **met** by `Probe718PathQuantifier.exists_ne_stab`/`exists_ne_universal`; but
the evidence shows necessity of *some* universal, complementation-shaped device, not of
Safra/Piterman, so 711 is re-described as the device-selection substrate and kept `[BLOCKED]`
pending probe E3. The Phase 0 ruling is restated as newly answerable and left to the user.

## Ranking ratification

Both languages; each route with its load-bearing hypothesis, what would falsify it, and the
cheapest next experiment. Transcribed from `reports/01_decidability-programme-review.md` §3 against
Section 0's re-verified anchors. **No complexity bound is committed anywhere in this section**: the
CTL⋆ 2EXPTIME lower bound (task 713, ARGUED, Section C) is named only as the sanity ceiling that
any proposed procedure must clear.

### L⁺ -- decidability of `PlusValidZTime` (OPEN by every route)

**R1 -- Seam-gluing ray product with a universal (complementation-shaped) path summary. RANK 1,
unchanged; hypothesis sharpened.**
- *Load-bearing hypothesis*: **`[F.IsRegular]`** on the keystone -- `Probe718.seamFibreEquiv`,
  `plusStab_iff_rays` (general frame), `seamOmegaEquiv`, `plusStab_iff_omega` (over Z) all sit
  under that instance (Section 0 row 7), discharged through `TaskFrame.comp` plus the reflection
  convention and nothing else. **Not unconditional**; not stated at a bare `TaskFrame`. Every
  consumer carries the instance (the Z fixtures do: `FrameOver.ofSlicedStep_isRegular`,
  `Probe710.F_isRegular`).
- *Evidence in hand*: keystone proved (general frame and over Z); stratification licenses the
  alphabet (`Probe718Stratification.plusTruthAt_iff_stratum_atomize`); the forward finite-graph
  summary holds on the `Bool` fixture (`Probe718FiniteGraph.will_iff_allPathsMeet`, decidable
  there); the existential summary provably diverges, so *some* universal device is necessary
  (`Probe718PathQuantifier.exists_ne_stab`).
- *Weighed and found light*: (a) **only the forward factor of the finite-graph summary is
  proved; the backward dual is unproved**, a reasoned exclusion justified by the fixture's
  time-reversal symmetry -- and the finite-width obstruction is located in the backward factor, so
  the symmetric fixture is exactly the one that cannot see it. (b) Necessity of **a** universal
  device is demonstrated; necessity of **Safra/Piterman** specifically is not (four candidate
  devices, Section B).
- *Falsifiers*: a `⊡`-depth-2 formula whose `⊡`-value at a class is not a function of the class's
  summary state (kills stratification); the backward-dual summary failing on a time-asymmetric
  fixture (kills the two-factor presentation at the factor the refutation lives in); a fragment
  where every universal summary device needs infinite state (kills decidability of the check).
- *Cheapest next experiments, in order*: **E1** the backward-dual finite-graph probe on a
  time-asymmetric fixture (Sections E and H4); **E2** the depth-2 stratification probe; **E3** a
  device-selection probe comparing the candidate universal devices on the `⊡(Fp)`/`⊡(Pp)`
  shapes, before anything is funded (Section B).

**R2 -- Mosaics / quasimodels. RANK 2, unchanged.**
- *Hypothesis*: `Probe718Mosaic.StabSaturated` is decidable on finite mosaic sets with mixed germ
  states (under `[F.IsRegular]`, Section 0 row 13), and a saturated-set existence theorem holds for
  L⁺.
- *Evidence*: amalgamation is free (`amalgamate`, via the landed `paste`; `amalgamate_unique`);
  `StabSaturated` proved only in the same-state corner (`stabSaturated_of_sameState`); the
  Hodkinson-Reynolds Handbook §§5.10-5.11 bodies are absent from the corpus, so R2 cannot be
  promoted on textual grounds.
- *Falsifier*: a finite mosaic set, mixed germ states, on which `StabSaturated` is false yet every
  finite coherence condition holds.
- *Cheapest next experiment (**E4**)*: decide `StabSaturated` on the two-state `Bool` fixture's
  mosaic set at `⊡(Fp)`, then acquire the Handbook pages.

**R3 -- Periodicity / Ramsey (F4; task 709). A COMPONENT of R1, not a route** -- unchanged from
718; the ROADMAP has not caught up (Section D). Its premise, finite width, is refuted for any
complete class; as R1's summary step it is either replaced by an automaton acceptance condition or
is exactly right. Sequenced under 719.

**R4 -- Task-coherence-preserving filtration. CLOSED for Z-time** by
`Probe706.no_finite_carrier_sat` (`[Finite F.WorldState]`; `⊡`-free witness, hence a fact about TM
itself) and `Probe710.not_finite_width_fmp` (`[Finite W]`; `⊡`-bearing witness, L⁺-specific). The
only residue is dense durations, not the programme's target. The ROADMAP's Open Risks row "never
been tried ... UNASSESSED" is stale (Phase 4 of this plan corrects it).

**R5 -- Translation to a decidable first-order fragment. LOW**, unchanged: the monodic fragment's
decidability proof is itself the quasimodel method, routing back to R1/R2.

### L -- the base language

**L-R1 -- The witness-family Z-time route. DONE.** `Compression.decidableValidZTime`
(`FrameClass.ZTime`, `Formula`, empty premises, axioms `[propext, Classical.choice, Quot.sound]`,
Section 0 row 1). *Hypothesis remaining*: none. *Falsifier*: none; it is a theorem. *Unwritten
corollaries, cheapest first*: **L-E1** `Decidable (Derivable .ZTime [] φ)` (H3); **L-E2** the
general-premise residue named in `Compression/Assembly.lean`'s header
(`decidableSemanticConsequenceNil` is `Γ = []` only, row 3); **L-E3** the cross-check fixture --
run `decide` and `Compression.decidableValidZTime` on the negation of the `posFamily` target
`□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)`; the tableau must not report `.valid` where the certificate route
refutes (Section G).

**L-R2 -- The tableau spine (ROADMAP Phase 6). RANK 1 for the four-class statement and the only
route filed for Base/Dense/RTime; RANK 2 overall because Z is already done by L-R1.**
*Hypothesis*: engine totality at a quantified branch budget (428) via the mint-bound route;
`gapPotential` for `densityRule` (464, genuinely open); the truth-lemma redesign (429);
`valid_iff_allClosed` (430). *Falsifier*: the C9 register already holds the refuted forms
(`buildTableau_isSome` unconditional); the next is `gapPotential` having no measure that pays for
`densityRule`. *Cheapest next experiment*: 464 `--hard --lit`, as the ROADMAP already says; plus
the description reconciliation of Section G.

**L-R3 -- A dense-time certificate class. NEW, UNFILED, UNRANKED above L-R2.** The Dense factor
is where `⊨ φ` (Base) and `ValidDense` would be decided if the logic-level dichotomy were a
theorem (it is not: no Lean declaration states `Log(all) = Log(Discrete) ∩ Log(Dense)`).
*Hypothesis*: a compression theorem over a dense order (Burgess 1982/1984 chronicles; Reynolds
1992 for Until/Since over the reals; the mosaic method as the literature's tool for dense flows).
*Falsifier*: a dense-time non-validity with no finitely presented countermodel of any shape.
*Cheapest experiment*: none cheap; file research-first only if Base decidability becomes a
programme goal.

### Where this supersedes `specs/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md`

- **Agrees**: R1 > R2 > R3-as-component > R4-closed > R5-low, unchanged.
- **Supersedes** in three places: (i) R1's hypothesis is stated as `[F.IsRegular]` via
  `TaskFrame.comp` plus the reflection convention, never as unconditional; (ii) the **next
  experiment is the backward dual (E1), not stratification** -- because the refutation lives in the
  backward factor and that is where the evidence is weakest; (iii) R1's remaining content is named
  "a universal-summary device, to be selected" rather than "ω-automata determinization", since the
  probes showed the former and not the latter.
- **Adds**: the L side (L-R1 done, L-R2, L-R3), which the 718 ranking did not cover.

## State-write disclosure

This task's implementation round wrote only files under
`specs/721_decidability_programme_review_l_and_lplus/` (this specification, the progress and
handoff files, the plan's phase markers and checkboxes, the summary, `.return-meta.json`,
`.orchestrator-handoff.json`) and `specs/ROADMAP.md` (Phase 4 of its plan). `specs/state.json` and
`specs/TODO.md` were **read, not written**, by this task; the orchestrator's own status-sync
writes to those two files happen outside this task's commits and are not this task's. No task was
created, revised, or abandoned; every Section above is a specification to be actioned afterwards
via `/revise` and `/task`. No probe file, no `FormalSystem/` file, no `docs/` file, no script and
no typst file was edited; every such fix is a Section H item.

## Trace: ROADMAP changes to specification sections

| Task named in a ROADMAP change | Specification anchor |
|---|---|
| 712 | Section A; Section 0.4 |
| 711 | Section B; "The 711 tension"; Section 0 rows 10-11 |
| 713 | Section C |
| 709 | Section D; Ranking R3 |
| 719 | Section E; Ranking R1 (E1-E3); H4 fold-in rule |
| 706, 710, 720 | Section F; Section 0 rows 5-6, 22-24 |
| 430, 412 | Section G; H3; Ranking L-R1/L-R2 |
| 718 (completed annotations) | Section 0.4 (commit `58f8afb39`); Section 0 rows 7, 10-13 |
| 563, 564 (Phase 3 edges) | Section 0.4; Section 0 row 19 |
| 721 (Fronts row; Maintenance) | this file; H5 |
| New Open Risks rows (surfaces understate L; `pinned:C14`) | H1; H2; Section 0 rows 25-27 |
| Success Metric additions | Section F (Option A caveat); H2; Section G |

Every specification section that changes a ROADMAP-visible fact (A-G, H1, H2, H5) is reflected
in the ROADMAP's Fronts, Phase 0-3/6, Open Risks, Success Metrics or Maintenance text; H3 and H4
are named in the ROADMAP only through Phase 1's E1 item and Phase 6's oracle sentence.
