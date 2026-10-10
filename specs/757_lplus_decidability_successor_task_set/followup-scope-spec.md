# Follow-Up Scope Specification: the L⁺ decidability successor set

Written by this task's implementation round (plan `01_lplus-successor-task-set.md`, Phases 1-5),
converting the three OPEN frontier obligations named by
`FormalSystem/Metalogic/Decidability/RaySummary/README.md`'s "The verdict" table into filed task
records. This file **does** file: unlike its precedents (`specs/archive/721_.../followup-scope-spec.md`
and `specs/archive/718_.../followup-scope-spec.md`, both of which "file nothing"), Section H's six
records are created in `specs/state.json` by this task's own Phase 4, through the sanctioned writer
(`state-write.sh`), and the numbers they receive are written back into Section H afterwards. What
this file does **not** do: it proves nothing, edits no Lean file, no `docs/` file, no script and no
test; it transitions no Stage 0 task (712, 713, 734, 709) and edits neither sliced-certificate task
(716, 714); it claims no upper bound and cites no external Büchi/MSO lemma in place of a proof.

Format of record: `specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md`.
Design of record: `reports/01_lplus-successor-task-set.md` in this task directory (Findings 1-6,
Decisions D1-D6). Every status claim below is re-derived in this round (Section 0), never copied
from that report; where the two differ, Section 0.5 says so.

Authority for the three obligations: the RaySummary README's "The verdict" table and its
"(W): what landed and what did not" section, re-read this round. The task description's own
reading of the obligations (2026-10-10) is checked against them in Section 0.5.

## Section 0 -- Verification record (this round)

Every anchor the sections below cite was re-checked against the tree in this implementation round
(2026-10-10, HEAD `84be907f1` at round start), independently of the research dispatch. Line numbers
are "as of this round" and appear in this section only; Sections A-H cite declaration names and
paths, never line numbers. Hypotheses are recorded where a declaration carries one.

### 0.1 Compile record

`timeout 300 lake env lean <scratchpad>/Verify757Impl.lean` (import `FormalSystem`; the `.olean`
frontier was fresh — `find FormalSystem -name '*.lean' -newer .lake/build/lib/lean/FormalSystem.olean`
returned nothing; `lake-build-guard.sh status` exit 0 with no holder — so no rebuild was run).
**74 `#check`/`#print axioms` lines, exit 0, 231 output lines, zero `Unknown identifier`, zero
`error`.** Every `#print axioms` line below reads `[propext, Classical.choice, Quot.sound]`.
Abbreviated types (the full output is in the scratch log; implicit instance arguments elided):

```
-- perimeter
Compression.decidableValidZTime : (φ : Formula) → Decidable (ValidZTime φ)            -- L only; a def
PlusValidZTime : PlusFormula → Prop
plusValidZTime_iff_plusValidInt : ∀ φ, PlusValidZTime φ ↔ PlusValidInt φ
PlusSharingWitnessFamily.StabFaithful : {Γ Del : PlusContext} → PlusSharingWitnessFamily Γ Del → Prop
PlusSlicedCertificate.StabFaithful    : {Γ Del : PlusContext} → PlusSlicedCertificate Γ Del → Prop
-- (S)
presented_modelOf : ∀ {Q} [Fintype Q] [DecidableEq Q] [Nonempty Q] {φ}, φ.BoxStabFree →
  ∀ {lab step} (hC : Cons φ lab step) (t : ℤ) (q₀ : Q), lab q₀ (clNow φ) = true →
  ∀ (τ : WorldHistory (frameOf hC).toTaskFrame), τ.state t = (t, q₀) →
  Presented (modelOf φ lab step hC) τ t φ lab (fun q q' => decide (step q q' = true))
hitCl_modelOf_eq_hitOf : … (same hypotheses) → ∀ k, 1 ≤ k →
  HitCl (modelOf φ lab step hC) τ t φ k = ↑(hitOf lab (fun q q' => decide (step q q' = true)) (clNow φ) k)
Cons : {Q} → [Fintype Q] → [DecidableEq Q] → (φ : PlusFormula) → (Q → (clSig φ).preds → Bool) → (Q → Q → Bool) → Prop
-- (C)
HitPresented : {F : FrameOver intOrder} → [F.IsRegular] → {Q} → [Fintype Q] → [DecidableEq Q] →
  TaskModel F.toTaskFrame → WorldHistory F.toTaskFrame → ℤ → (φ : PlusFormula) →
  (Q → (clSig φ).preds → Bool) → (Q → Q → Bool) → ℕ → Prop
Presented : (same, without the Fintype/DecidableEq instances and the ℕ depth)
hitPresented_of_presented : … (k : ℕ), 1 ≤ k → Presented M τ t φ lab step → HitPresented M τ t φ lab step k
hit_eq_hitOf_of_presented : … (k : ℕ), 1 ≤ k → Presented M τ t φ lab step → HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)
mem_hitOf_iff : … (t : ℤ), 1 ≤ k → ∀ x, x ∈ hitOf lab step now k ↔ ∃ ρ, IsRun lab step now t ρ ∧ InFamily sig k x.1 x.2.1 x.2.2 (runTrace lab ρ)
kTypeOf_listSeg_replicate_eventually_periodic_bounded : ∀ sig [Fintype sig.preds] [DecidableEq sig.preds] (k) (ℓ),
  ∃ m₀ p, 0 < p ∧ m₀ + p ≤ Nat.card (KType sig k) ∧ ∀ m, m₀ ≤ m →
  kTypeOf sig k (listSeg (List.replicate (m + p) ℓ)) = kTypeOf sig k (listSeg (List.replicate m ℓ))
inFamily_of_shrink_run : … p < j → m₀ + p ≤ j → F.W z₀ ≤ s ∧ s + ↑j ≤ F.W (z₀ + 1) → (constant run on [s, s+j)) →
  (periodicity from m₀) → InFamily sig k F.τneg F.τzero F.τpos (deleteRun c s p)      -- shrink direction only
segZ_const_of_kTypeOf_eq_replicate : … 1 ≤ k → … → a < b ∧ (constant on [a, b))
kTypeOf_listSeg_append_congr : … kTypeOf (l₁) = kTypeOf (l₁') → kTypeOf (l₂) = kTypeOf (l₂') → kTypeOf (l₁ ++ l₂) = kTypeOf (l₁' ++ l₂')
-- (W) anchor layer
anchorCons_anchorCells : ∀ {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame) (φ), AnchorCons φ (anchorCells M φ)
anchorCells_ncard_le   : ∀ {F} (M) (φ), (anchorCells M φ).ncard ≤ 2 ^ 2 ^ (plusSubformulaClosure φ).card
cellAt : {F : FrameOver intOrder} → TaskModel F.toTaskFrame → PlusFormula → F.WorldState → ℤ → Set (Finset PlusFormula)
cellAt_eq_cellAt : ∀ {F} (M) (φ) (w) (z z' : ℤ), cellAt M φ w z = cellAt M φ w z'
tpOf : {F} → TaskModel F.toTaskFrame → PlusFormula → WorldHistory F.toTaskFrame → ℤ → Finset PlusFormula
AnchorCons : PlusFormula → Set (Set (Finset PlusFormula)) → Prop
decidableAnchorConsFin : (φ) → (𝒞 : Finset (Finset (Finset PlusFormula))) → Decidable (AnchorConsFin φ 𝒞)
box_mem_tpOf_iff  : … ψ.box ∈ plusSubformulaClosure φ → (ψ.box ∈ tpOf M φ σ z ↔ ∀ σ' z', ψ ∈ tpOf M φ σ' z')
stab_mem_tpOf_iff : … ψ.stab ∈ plusSubformulaClosure φ → (ψ.stab ∈ tpOf M φ σ z ↔ ∀ σ', σ.state z = σ'.state z → ψ ∈ tpOf M φ σ' z)
box_time_invariant : ∀ {F : TaskFrame} (M) (τ) (t s) (ψ), PlusTruthAt M τ t ψ.box ↔ PlusTruthAt M τ s ψ.box
plusStateLocal_stab_iff : ∀ {F : TaskFrame} {φ}, φ.StateLocal → ∀ M τ t, PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t φ.stab
-- (W) run layer
ofSlicedStepFinBranch : {W} → [Nonempty W] → (R : ℤ → W → W → Prop) → FwdFinBranch R → BwdFinBranch R → (fwd) → (bwd) → FrameOver intOrder
ofSlicedStepFinBranch_isRegular ; ofSlicedStepFinBranch_mem_HF_iff : … (∃ τ, τ.path = f) ↔ ∃ k g, IsSlicedStepPath R k g ∧ f = fun t => (t + k, g t)
saturation_of_finBranch : ∀ {W} (R), FwdFinBranch R → BwdFinBranch R → TaskFrame.Saturation (ofSlicedStepRel R)
Rlad : {Q} → (Q → Q → Bool) → (Q → Bool) → ℤ → Q × ℕ × ℕ → Q × ℕ × ℕ → Prop
Count : Bool → Bool → ℕ → ℕ → ℕ → Prop ; Drift : ℕ → ℕ → Prop
Rlad_fwd : ∀ {Q} [Finite Q] (step) (pend), FwdFinBranch (Rlad step pend) ; Rlad_bwd : … BwdFinBranch (Rlad step pend)
Rlad_slice_infinite : ∀ {Q} [Nonempty Q], ¬Finite (Q × ℕ × ℕ)
ladderFrame : {Q} → [Finite Q] → [Nonempty Q] → (step) → (pend) → (fwd : ∀ t x, ∃ y, Rlad step pend t x y) → (bwd : …) → FrameOver intOrder
ladderFrame_isRegular : … (ladderFrame step pend fwd bwd).IsRegular
ladderFrame_step : … (ladderFrame step pend fwd bwd).step x y ↔ y.1 = x.1 + 1 ∧ Rlad step pend x.1 x.2 y.2
decidableStabOfPresented : … Presented M τ t φ lab step → Decidable (PlusTruthAt M τ t φ.stab)
-- negatives
no_finite_carrier_sat : ∀ {F} [F.IsRegular] [Finite F.WorldState] (M) (τ) (t), ¬PlusTruthAt M τ t θ
NoFiniteWidth.not_finite_width_fmp : ¬∀ φ, ¬PlusValidZTime φ → ∃ W, ∃ (_ : Finite W) (_ : Nonempty W), ∃ R fwd bwd M τ t, ¬PlusTruthAt M τ t φ
NoFiniteWidth.not_plusValidZTime_neg_Φ : ¬PlusValidZTime NoFiniteWidth.Φ.neg
NoFiniteWidth.no_finite_width_sat : ∀ {W} (R) [Finite W] [Nonempty W] (fwd) (bwd) (M) (τ) (t0), ¬PlusTruthAt M τ t0 NoFiniteWidth.Φ
plusStab_iff_forall_hitCl : … 1 ≤ k → (PlusTruthAt M τ t φ.stab ↔ ∀ x ∈ HitCl M τ t φ k, ∀ c, InFamily … c → stabTargetSig …)
-- fixture (Limits/NoFiniteWidth.lean, a LIBRARY module)
NoFiniteWidth.M : TaskModel NoFiniteWidth.F.toTaskFrame ; NoFiniteWidth.F : FrameOver intOrder ; NoFiniteWidth.F_isRegular : F.IsRegular
NoFiniteWidth.Φ NoFiniteWidth.D : PlusFormula ; NoFiniteWidth.Node : Type ; NoFiniteWidth.Step : Node → Node → Prop
NoFiniteWidth.canon : ℕ → ℤ → ℤ → Node
NoFiniteWidth.path_eq_canon : ∀ {g : ℤ → Node}, (∀ s, Step (g s) (g (s + 1))) → ∃ k t, ∀ s, g s = canon k t s
```

Reading. (i) `Compression.decidableValidZTime` takes `φ : Formula` — L only, the perimeter stands.
(ii) Both `StabFaithful` predicates are over `PlusContext`, so (C5) is structurally not stateable
over `Formula`. (iii) Every bridge the run layer consumes carries `1 ≤ k` (`hit_eq_hitOf_of_presented`,
`mem_hitOf_iff`, `hitCl_modelOf_eq_hitOf`, `plusStab_iff_forall_hitCl`, `segZ_const_of_kTypeOf_eq_replicate`),
so depth `k = 1` is the run layer's own and no record below asks for more. (iv) `cellAt` is the
per-state type set the stabilization lemma speaks about and is already time-independent
(`cellAt_eq_cellAt`); `ladderFrame` is a FRAME, so a model on it must be defined before any cell can
be computed (Section A). (v) `inFamily_of_shrink_run` is shrink-direction only and single-segment.
(vi) `NoFiniteWidth.M`, `F`, `F_isRegular`, `canon`, `path_eq_canon` are library declarations, so a
probe on the `Node` fixture imports them and re-proves nothing.

### 0.2 Declaration anchors (grep, this round)

| # | Anchor | Path (declaration kind, line as of this round) | Result |
|---|---|---|---|
| 1 | `Compression.decidableValidZTime` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` (`def`, 147) | `φ : Formula`; a hypothesis-taking `BiLasso.decidableValidZTime` (`BiLasso/Assembly.lean`, `def`, 100) is a different declaration |
| 2 | `PlusValidZTime` | `FormalSystem/PlusLanguage/PlusValidity.lean` (`def`, 111) | `PlusValidIn ProofSystem.FrameClass.ZTime φ`; namespace `FormalSystem.PlusLanguage`; `plusValidZTime_iff_plusValidInt` in `FormalSystem/PlusLanguage/PlusIntTransfer.lean` (`theorem`, 188) |
| 3 | `StabFaithful` (two) | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean` (`def`, 283); `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Check.lean` (`def`, 480) | both over `PlusContext` (0.1) |
| 4 | `presented_modelOf`, `hitCl_modelOf_eq_hitOf`, `Cons` | `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` (`theorem` 916; `theorem`; `structure` 573) | `Cons` fields include `nowUnique` (626) and `boxStabFree` (628); `anchored_runTrace_of_boxStabFree` (`theorem`, 865) is the step the `BoxStabFree` restriction pays for |
| 5 | `Probe745.hitPresented_modelA` | `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` (`theorem`, 1526; namespace 154; file 1595 lines) | `(t : ℤ) (k : ℕ) (hk : 1 ≤ k)`; explicit window `presentationSize k`, no `∃ L` |
| 6 | `Probe735.not_presented` | `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` (`theorem`, 230; namespace 67) | `(t : ℤ) {Q} [Fintype Q] [DecidableEq Q] (lab) (step) : ¬ Presented MA stayA t Fp lab step` |
| 7 | `Probe747.modelOf_incomplete`, `Probe747.stab_iff_of_presented_nowUnique` | `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean` (`theorem` 131, 188; namespace 104) | WIDTH and COLLAPSE |
| 8 | `Probe719Backward.pastStab_iff_allBwdPathsMeet` | `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` (`theorem`, 577; namespace 81); mirror `Probe733Mirror.pastStab_iff_allBwdPathsMeet` in `backward-dual-mirror-fixture.lean` (622; namespace 117) | the only backward results; guardrail (e) stands |
| 9 | `Probe750.ladder_fwd` / `ladder_bwd` / `ladder_slice_infinite` / `ladder_isRegular` / `capped_carrier_finite` | `specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean` (`theorem` 63, 70, 76, 81, 93; namespace 57; file 103 lines) | the ninth wired probe; `capped_carrier_finite` refutes the capped variant |
| 10 | `cellAt`, `cellAt_eq_cellAt`, `box_mem_tpOf_iff`, `stab_mem_tpOf_iff`, `anchorCells`, `anchorCons_anchorCells`, `anchorCells_ncard_le`, `decidableAnchorConsFin` | `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean` (`def` 132; `theorem` 154, 186, 208; `def` 225; `theorem` 276; `theorem`; `instance` 356; file 418 lines) | `cellAt M φ w z := {T \| ∃ σ, σ.state z = w ∧ tpOf M φ σ z = T}`; the count-not-complexity disclaimer sits beside `anchorCells_ncard_le` |
| 11 | `Drift`, `Count`, `Rlad`, `Rlad_fwd`, `Rlad_bwd`, `Rlad_slice_infinite`, `ladderFrame`, `ladderFrame_isRegular`, `ladderFrame_step`, `ofSlicedStepFinBranch`, `ofSlicedStepFinBranch_isRegular`, `ofSlicedStepFinBranch_mem_HF_iff`, `saturation_of_finBranch` | `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` (`def` 254, 261, 268; `theorem` 281, 302, 328; `def` 342; `instance` 358; `theorem` 366; `def` 169; `instance` 180; `theorem` 218, 152; file 373 lines) | `Count px py c n c' := if py then (if px then c' + 1 = c else c' = n) else (c' = 0 ∧ (px = true → c = 0))` — a region starting at the next step takes length `n`: the `n`-dependence of Section A |
| 12 | `NoFiniteWidth.Node`, `Step`, `F`, `F_isRegular`, `M`, `Φ`, `D`, `canon`, `path_eq_canon` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` (`inductive` 132, 141; `def` 253; `instance` 282; `def` 292; `def` 126, 123; `def` 297; `theorem` 425) | `M := ⟨fun w _ => ∃ k, w = Node.x k⟩`; `D`, `Φ := (A'.and C').and D` |
| 13 | `no_finite_carrier_sat`, `not_finite_width_fmp`, `not_plusValidZTime_neg_Φ`, `no_finite_width_sat` | `Limits/FiniteCarrier.lean` (`theorem`, 248; namespace `FiniteCarrier`); `Limits/NoFiniteWidth.lean` (`theorem` 1280, 588, 1200) | library names; R4 closed by the first two |
| 14 | `exists_tailStable_repr` | `PlusSlicedCertificate/FixtureStable.lean` (prose, 14, 87, 291); `Stable.lean` (67, 722); `Fixture.lean` (788, 796) | never declared — a prose-and-fixture refutation record ("no member is tail-stable"), not a theorem of that name |
| 15 | `Decidable (PlusValidZTime` | `FormalSystem/ Tests/ specs/evidence/` (`--include=*.lean`) | **14 hits, 0 at statement level** (`theorem\|def\|instance\|lemma\|#check\|example` prefix); all are denials in docstrings and headers |
| 16 | stabilization lemma | `grep -i stabiliz FormalSystem/Metalogic/Decidability/RaySummary/*.lean` | hits only `Present.lean`'s `iterate_stabilizes` (`theorem`, 128; bounded-iterate stationarity, section `Stabilize`) and its two uses — unrelated to realized cells; **obligation (1)'s first statement exists in no form** |
| 17 | admissibility `Adm` | `grep -n Adm RaySummary/RunLayer.lean RaySummary/README.md` | **no hit in `RunLayer.lean`**; the only occurrence is `README.md` line 392, "`c ∈ Adm q` on the ladder's carrier, named here and not costed" — named in prose, defined nowhere |
| 18 | `docs/theorem-index.md` rows | lines 197-210 | `Presented`-gated Conditional rows (197-201); (S) rows (202-203); (W) anchor rows (205-206); (C) count rows (207-208); the `ladderFrame_isRegular` row (210) |
| 19 | C14 baseline | `scripts/check-module-invariants.sh` (2316-2331 expected output; 2543-2558 `#print axioms`) | `hit_eq_hitOf_of_presented`, `presented_modelOf`, `anchorCells_ncard_le`, `inFamily_of_shrink_run`, `ladderFrame_isRegular` all pinned |

### 0.3 Gate anchors

- `bash scripts/check-evidence-probes.sh`: run detached first (log in the scratchpad, PID-liveness
  waiter), then re-run in the foreground under `timeout 280` to capture the exit code — **exit 0,
  `PASS  all 27 wired probe(s) compile`**, 27 PASS lines, 1 `SKIP (deferred: frame-class uniformity
  work)` on `bi-lasso-decision-layer/spike-untl-unfolding-and-fwd-obstruction`; all twenty
  `seam-gluing-ray-product/*` probes PASS; the one `WIRED_REPO` entry
  (`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`) PASS.
  `WIRED` array: 26 quoted entries, 20 of them `seam-gluing-ray-product/`.
- `specs/evidence/seam-gluing-ray-product/` holds 20 `.lean` files:
  `b2b-frame-constructor-branching`, `backward-dual-asymmetric-fixture` (619 lines),
  `backward-dual-mirror-fixture`, `cslib-ramsey-port-feasibility`, `deadline-ladder-branching`
  (103 lines), `device-selection-probe`, `finite-graph-stab-summary`, `hit-presented-model-a`
  (1595 lines), `ktype-summary-substrate-probe`, `mosaic-germ-amalgamation`, `mosaic-stab-saturated`,
  `path-quantifier-alternation`, `presented-not-complete`, `presents-is-seam-decidedness`,
  `quasistate-does-not-determine-hit`, `stab-depth-stratification`, `stab-depth-two-probe`,
  `stab-depth-two-shared-stratum`, `stab-fibre-is-ray-product`, `w-soundness-shape-refuted`.
  Neither `node-cell-stabilization.lean` nor `hit-presented-node.lean` (Section H's new files) exists.
- `lake-build-guard.sh status`: exit 0, no holder. `.olean` frontier fresh: `FormalSystem.olean`
  2026-10-10 01:56, `RunLayer.olean` 01:48 (local time); no `FormalSystem/**/*.lean` newer.
- Library module sizes this round (`wc -l`): `AnchorLayer.lean` 418, `Realize.lean` 1004,
  `RunLayer.lean` 373.

### 0.4 Task-record anchors (`specs/state.json`, read-only, `jq` this round)

| Task | Status | `task_type` | Deps | Declared `file_scope` (relevant entries) |
|---|---|---|---|---|
| 757 (this) | `implementing` | lean4 | — | `specs/757_.../followup-scope-spec.md`, `specs/ROADMAP.md`, `specs/TODO.md`, `specs/state.json` (declared since the research round; see 0.5) |
| 749 | `completed` | lean4 | — | `RaySummary.lean`, `RaySummary/{Compose,README.md,Trace,Transport}`, `WeakCanonical/KTypeSummary/Saturation.lean`, `KTypeSummaryAxiomTest.lean`, `docs/theorem-index.md`, both scripts, `hit-presented-model-a.lean`, `w-soundness-shape-refuted.lean` |
| 750 | `completed` | lean4 | — | `FormalSystem.lean`, `RaySummary.lean`, `RaySummary/README.md`, `RaySummary/RunLayer.lean`, `KTypeSummaryAxiomTest.lean`, `docs/theorem-index.md`, both scripts, `specs/evidence/seam-gluing-ray-product/` (directory root), `deadline-ladder-branching.lean` |
| 720 | `completed` | lean4 | `[706, 710]` | `ci.yml`, `check-evidence-probes.sh`, `specs/evidence/seam-gluing-ray-product/`, two READMEs |
| 744 | `not_started` | markdown | — | **`RaySummary/README.md`**, `scripts/check-module-invariants.sh`, `scripts/readme-inventory.sh` — collides with every record in Section H |
| 734 | `partial` (Stage 0, R2) | lean4 | `[733]` | **`scripts/check-evidence-probes.sh`**, `mosaic-stab-saturated.lean`, `specs/literature-index.json` — collides with H1/H2 on the script |
| 751 | `not_started` | meta | — | `specs/state.json`, `.claude/scripts/validate-state.sh` — collides with this task's own filing writes |
| 752 | `not_started` | meta | — | `.claude/scripts/roadmap-integration.sh`, **`specs/ROADMAP.md`** — collides with this task's ROADMAP edit |
| 410 | `planned` | lean4 | `[429]` | eleven files including **`typst/generated/status.typ`** — collides with H3-H6 through the generated file |
| 712 / 713 / 709 | `blocked` / `hold` / `not_started` | lean4 | `[703, 710]` / `[]` / `[703, 710, 719]` | none declared — Stage 0, described in this file and never moved |
| 716 / 714 | `not_started` | lean4 | `[]` / `[]` | `PlusSlicedCertificate/{Live,Check,Examples}.lean` + `certificate-witness-inventory.txt` / `PlusSlicedCertificate/{Live,Check,Stable,Examples}.lean` — disjoint from every record in Section H |

Open tasks (status not `completed`/`abandoned`/`expanded`): **52**. Completed-but-unarchived in
`active_projects`: `[750, 749, 731, 720, 754, 755]`. `next_project_number`: **758** at this round's
start (re-read immediately before each creation write in Phase 4; the numbers Section H records are
the ones actually received). `active_topics` contains `decidability`.

### 0.5 Differences from the research report (and from the task description)

- **Row 2 path.** The report placed `PlusValidZTime` at `PlusLanguage/PlusValidity.lean` under
  `Metalogic/Decidability/`; it lives at `FormalSystem/PlusLanguage/PlusValidity.lean` (namespace
  `FormalSystem.PlusLanguage`). Substance unchanged.
- **Row 5 size.** The report's "1526 lines" for `hit-presented-model-a.lean` is the HEADLINE's line
  number; the file is 1595 lines. Section H2's cost basis uses 1595.
- **Row 17.** The report cited `Adm` at `RunLayer.lean:59`; this round finds **no** occurrence of
  `Adm` in `RunLayer.lean` — the only mention is the README's "`c ∈ Adm q` … named here and not
  costed". The finding is strengthened, not contradicted: `Adm` is named in prose only and is H3's
  definition.
- **Row 1 / 0.4.** 757 now carries a declared `file_scope` (four `specs/**` paths); the report's
  "none declared" predates the plan round. HEAD at this round's start is `84be907f1`
  (`task 757: create implementation plan`), not the report's `bb8c1c4fa`.
- **Compile record size.** 74 check/print lines this round (the report's scratch had 55): the
  additional lines are `Presented`, `Cons`, `tpOf`, `AnchorCons`, `decidableAnchorConsFin`,
  `box_mem_tpOf_iff`, `stab_mem_tpOf_iff`, `kTypeOf_listSeg_append_congr`, `saturation_of_finBranch`,
  `Count`, `Drift`, `ladderFrame_step` and the `Node` fixture's `F`, `D`, `Node`, `Step`, `canon`,
  `path_eq_canon`, every one of which Sections A-H cite. No anchor the report checked failed.
- **Gate counts.** 27 PASS + 1 SKIP, exit 0 — identical to the report's run and to no carried
  figure: 749's summary says "28/28" and 750's "27/27" [CARRIED-UNVERIFIED: both summaries]; two
  independent runs now read 27 PASS + 1 SKIP.
- **Statement counts.** `Decidable (PlusValidZTime`: 14 hits, 0 statement-level — unchanged.
  `grep -i stabiliz`: `iterate_stabilizes` only — unchanged.
- **The task description's reading of obligation (1)** — "stabilization of realized type sets in
  the deadline counter `c`" — is the README's shorthand; this file states the lemma over the pair
  `(c, n)` (Section A), because `Count`'s idle clause `c' = n` makes the next region's length,
  and so the cell at an idle state, depend on `n` as well. The README's "cells indexed by
  `(q, deadline class)`" is correct read as the class of the pair. No claim in the description is
  contradicted; `exists_tailStable_repr` "refuted by `FixtureStable.lean`" stands in substance as
  a prose-and-fixture record (row 14).
- **Research-report Decisions D1-D6** are carried into Sections A-H and the filed descriptions as
  AGENT decisions, re-openable by `/revise`; none is a user ruling.
