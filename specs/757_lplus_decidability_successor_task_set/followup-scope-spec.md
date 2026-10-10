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
| 4 | `presented_modelOf`, `hitCl_modelOf_eq_hitOf`, `Cons` | `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` (`theorem` 916; `theorem`; `structure` 573) | `Cons` has eleven fields — `serialFwd serialBwd botFalse impEq ucoh ulive scoh slive nowOnce nowUnique boxStabFree` (576-628), `nowUnique` at 626, `boxStabFree` at 628; `anchored_runTrace_of_boxStabFree` (`theorem`, 865) is the step the `BoxStabFree` restriction pays for |
| 5 | `Probe745.hitPresented_modelA` | `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` (`theorem`, 1526; namespace 154; file 1595 lines) | `(t : ℤ) (k : ℕ) (hk : 1 ≤ k)`; explicit window `presentationSize k`, no `∃ L`; the fixture's containment `run_subset_middle` (`theorem`, 686), the count `card_QA_presentationSize` (`theorem`, 900), the presentation `stepOf` (`def`, 914) and `labOf` (`def`, 980) |
| 6 | `Probe735.not_presented` | `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` (`theorem`, 230; namespace 67) | `(t : ℤ) {Q} [Fintype Q] [DecidableEq Q] (lab) (step) : ¬ Presented MA stayA t Fp lab step` |
| 7 | `Probe747.modelOf_incomplete`, `Probe747.stab_iff_of_presented_nowUnique` | `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean` (`theorem` 131, 188; namespace 104) | WIDTH and COLLAPSE |
| 8 | `Probe719Backward.pastStab_iff_allBwdPathsMeet` | `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` (`theorem`, 577; namespace 81); mirror `Probe733Mirror.pastStab_iff_allBwdPathsMeet` in `backward-dual-mirror-fixture.lean` (622; namespace 117) | the only backward results; guardrail (e) stands |
| 9 | `Probe750.ladder_fwd` / `ladder_bwd` / `ladder_slice_infinite` / `ladder_isRegular` / `capped_carrier_finite` | `specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean` (`theorem` 63, 70, 76, 81, 93; namespace 57; file 103 lines) | the ninth wired probe; `capped_carrier_finite` refutes the capped variant |
| 10 | `cellAt`, `cellAt_eq_cellAt`, `box_mem_tpOf_iff`, `stab_mem_tpOf_iff`, `anchorCells`, `anchorCons_anchorCells`, `anchorCells_ncard_le`, `decidableAnchorConsFin` | `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean` (`def` 132; `theorem` 154, 186, 208; `def` 225; `theorem` 276; `theorem`; `instance` 356; file 418 lines) | `cellAt M φ w z := {T \| ∃ σ, σ.state z = w ∧ tpOf M φ σ z = T}`; the count-not-complexity disclaimer sits beside `anchorCells_ncard_le` |
| 11 | `Drift`, `Count`, `Rlad`, `Rlad_fwd`, `Rlad_bwd`, `Rlad_slice_infinite`, `ladderFrame`, `ladderFrame_isRegular`, `ladderFrame_step`, `ofSlicedStepFinBranch`, `ofSlicedStepFinBranch_isRegular`, `ofSlicedStepFinBranch_mem_HF_iff`, `saturation_of_finBranch` | `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` (`def` 254, 261, 268; `theorem` 281, 302, 328; `def` 342; `instance` 358; `theorem` 366; `def` 169; `instance` 180; `theorem` 218, 152; file 373 lines) | `Count px py c n c' := if py then (if px then c' + 1 = c else c' = n) else (c' = 0 ∧ (px = true → c = 0))` — a region starting at the next step takes length `n`: the `n`-dependence of Section A. `ofSlicedStepFinBranch` is `ofSlicedStep`'s body (`FormalSystem/Semantics/SlicedFrame.lean`, `def`, namespace `FormalSystem.Semantics.FrameOver`) with `[Finite W]` replaced by two-sided finite branching |
| 12 | `NoFiniteWidth.Node`, `Step`, `F`, `F_isRegular`, `M`, `Φ`, `D`, `canon`, `path_eq_canon` | `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean` (`inductive` 132, 141; `def` 253; `instance` 282; `def` 292; `def` 126, 123; `def` 297; `theorem` 425) | `M := ⟨fun w _ => ∃ k, w = Node.x k⟩`; `D`, `Φ := (A'.and C').and D`; `Node` constructors `Node.pre`, `Node.x`, `Node.post` (`pre k → pre (k-1) \| x k`, `x k → post k 0`, `post k j → post k (j+1)`; every node has exactly one predecessor) |
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

## The design half — Sections A-D

Shape of record for each section, from the 721 spec: **Current record** / **What the tree says** /
**Scope decision** / **What the successor must NOT do** / **Action required**. Guardrails are the
ROADMAP Stage 1 list, cited by letter: **(a)** time axis, closure-indexed alphabet, never one bit
per depth; **(b)** gluing does not bound the fibre, no finite-fibre or finite-width assumption;
**(c)** no upper bound anywhere — every quantity is a count; **(d)** zero debt — no external
Büchi/MSO lemma in place of a proof, no cslib `require`; **(e)** forward-only results say so (the
backward side rests on `Probe719Backward.pastStab_iff_allBwdPathsMeet` alone), and `⊡(Fp)`/`⊡(Pp)`
are device-inert on finite fixtures.

**Names introduced by this specification** (none exists in the tree — Section 0.2 rows 15-17 are
the negative evidence for the first three; the rest are the records' proposed first statements):
`ladderModel`, `ladderCell_stabilizes`, `Adm`, `LadderCons`, `ladderCons_localRun`,
`ladderRealized`, `LadderRefutes`, `exists_hitPresented`, `sizeBound`, `objBound`,
`not_plusValidZTime_iff_ladderRefutes`, `preCell_stable`, `preCell_zero_ne`, `postCell_stable`,
`hitPresented_node`, `not_hitPresented_node`, `labN`, `stepN`. Every other backticked declaration
name in Sections A-D resolves to a Section 0.1 or 0.2 row.

## Section A -- Obligation (1): run-layer phase 2, the soundness half

**Current record.** OPEN; no statement in the tree. Section 0.2 row 16: `grep -i stabiliz` over
`RaySummary/*.lean` hits only `Present.lean`'s `iterate_stabilizes`, a bounded-iterate stationarity
lemma unrelated to realized cells. Row 17: the admissibility set `Adm` is named once, in the README
("`c ∈ Adm q` … named here and not costed"), and defined nowhere. Authority: the README's "(W): what
landed and what did not", "Open: obligation (ii)", item 1 — "the stabilization of realized type
sets in `c` past a bound syntactic in `φ` is plausible, unproved, and is phase 2's FIRST statement;
until it is proved phase 2 has no cost figure, and if it fails the honest outcome is `[BLOCKED]`,
never a finite-fibre retreat." The successor paragraph of that section assigns phase 2 "its own
record … never phases appended to this one".

**What the tree says.** The object the lemma speaks about exists: `cellAt M φ w z` (row 10) is the
set of closure types `tpOf M φ σ z` over histories `σ` through world state `w` at `z`, and it is
time-independent (`cellAt_eq_cellAt`). What does not exist is a MODEL on the ladder: `ladderFrame`
(row 11) is a `FrameOver intOrder`, so `cellAt` cannot yet be applied to a ladder state. Histories
of `ladderFrame` are exactly the `Rlad` paths (`ofSlicedStepFinBranch_mem_HF_iff`, since
`ladderFrame` is `ofSlicedStepFinBranch` on `Rlad`; `ladderFrame_step` reads the step relation
off), so the cell at `(q, c, n)` is determined by the `Rlad`-paths through it, and `Count` (row 11,
quoted verbatim there) exposes TWO sources of counter-dependence:

1. **`c`, the current deadline.** While pending (`px = py = true`) the clause is `c' + 1 = c`: the
   region ends in exactly `c` steps. A letter whose truth needs the region to last `d` more steps
   is absent from every type at `c < d`. The `Node` fixture (row 12) exhibits the mechanism at
   bound 1: from `Node.pre 0` the only successor is `Node.x 0`, so `pre 0` and `pre (k+1)` realize
   different cells for a `⊡`-bearing letter looking one step ahead.
2. **`n`, the next deadline.** At an idle state (`px = false`, `c = 0`) a region starting at the
   next step receives `c' = n`, so the next region's length is `n`; a letter looking `d` steps
   into that region depends on `n` whenever `n < d`. The README's "in the deadline counter `c`"
   omits this; its "cells indexed by `(q, deadline class)`" is correct read as the class of the
   PAIR. This is the one sharpening this file makes to the task description's reading (0.5), and
   it is a reading of `Count`'s definition, not a new claim about the mathematics.

No `k` enters: cells are sets of closure types, not `k`-types, so the lemma is stated at no depth
and the run layer's own `k = 1` (0.1 reading (iii)) is untouched by it.

**Scope decision.** The obligation becomes TWO records, split at the costability boundary the
README itself draws ("no cost figure until that lemma is stated"): the lemma record (Section H3)
and the realization record (Section H4) — research-report **Decision D3**, an agent decision
re-openable by `/revise` (the user can fold them back with one revision). Both are preceded by a
fixture probe (Section H1), per 750's own mitigation R-A ("prove or refute it on `Node` first").

*First statement of the lemma record (H3), library, over a general object.* A model first:

```
def ladderModel (step : Q → Q → Bool) (pend : Q → Bool) (fwd) (bwd) (lab : Q → Atom → Bool) :
    TaskModel (ladderFrame step pend fwd bwd).toTaskFrame   -- valuation reads the object component q
theorem ladderCell_stabilizes (φ : PlusFormula) … :
    ∀ (q : Q) (c c' n n' : ℕ) (z : ℤ),
      (plusSubformulaClosure φ).card ≤ c → (plusSubformulaClosure φ).card ≤ c' →
      (plusSubformulaClosure φ).card ≤ n → (plusSubformulaClosure φ).card ≤ n' →
      cellAt (ladderModel …) φ (q, c, n) z = cellAt (ladderModel …) φ (q, c', n') z
```

— the bound `B := (plusSubformulaClosure φ).card` EXHIBITED in the statement (research-report
**Decision D2**, agent decision). Fallback if the exhibited bound fails: the `∃ B : ℕ, ∀ q c c' n n' z,
B ≤ c → … → cellAt … = cellAt …` form. Either form gives finitely many deadline classes
`{0, …, B} ∪ {≥ B}` per counter, hence a finite cell index `Q × Fin (B+1) × Fin (B+1)`, which is
what H4's finite presentation is built on. `B` is a COUNT of closure formulas, under the same
sentence the tree already attaches to `anchorCells_ncard_le` ("a cardinality bound on a SET OF
CELLS, syntactic in `|cl φ|`. It is not a complexity bound of any kind") — guardrail (c).

*Why a fixture probe first (H1).* `Node` is the ladder's one-region special case (the `RunLayer.lean`
header) and a LIBRARY model (`NoFiniteWidth.M`, regular by `F_isRegular`, histories canonical by
`path_eq_canon`), so the probe imports it and re-proves nothing. The probe's statements, for the
fixture's own `⊡`-bearing witness and no general `φ` (the general-`φ` induction IS the lemma's
content):

```
theorem preCell_stable (k k' : ℕ) (hk : 1 ≤ k) (hk' : 1 ≤ k') (z : ℤ) :
    cellAt NoFiniteWidth.M NoFiniteWidth.Φ (.pre k) z = cellAt NoFiniteWidth.M NoFiniteWidth.Φ (.pre k') z
theorem preCell_zero_ne (z : ℤ) :
    cellAt NoFiniteWidth.M NoFiniteWidth.Φ (.pre 0) z ≠ cellAt NoFiniteWidth.M NoFiniteWidth.Φ (.pre 1) z
theorem postCell_stable (k k' j j' : ℕ) (hj : 1 ≤ j) (hj' : 1 ≤ j') (z : ℤ) :
    cellAt NoFiniteWidth.M NoFiniteWidth.Φ (.post k j) z = cellAt NoFiniteWidth.M NoFiniteWidth.Φ (.post k' j') z
```

`preCell_zero_ne` shows the deadline index is real; `postCell_stable` shows the thread index is
invisible to cells. Fallback formula if `Φ`'s closure makes the type computations unwieldy: `D`
alone (it keeps the `⊡`-letter that separates `pre 0` from `pre 1`), recorded in the probe header
in that order. Either verdict is the deliverable: stabilization at bound 1 confirms the mechanism
(branch-time saturation); a failure IS the obstruction the README names, recorded in the header as
such, and then H3's `∃ B` fallback is false too and H3 is `[BLOCKED]`.

*Consistency conditions and `Adm`.* H4's realization theorem needs `LadderCons φ lab step pend`,
analogous to `Cons` (row 4) with the liveness fields `ulive`/`slive` replaced by the ladder's
structural liveness (`c` strictly decreases while pending, by `Count`) and with the `box`/`stab`
letters pinned per cell by the anchor layer's equations — where obligation (3)'s first half lands
(Section C). Seriality is the object's own (`ladderFrame` takes `fwd`/`bwd` as hypotheses, as
`ofSlicedStep` does); the admissibility set `Adm` (row 17) — which objects supply them (a pending
state at `c = 0` needs a discharging successor) — is DEFINED in H3, since the stabilization lemma
is stated over the carrier `ladderFrame` already has and H4 quantifies over admissible objects.

Guardrails: (a) the ladder is a time-axis object whose alphabet is the closure (`cellAt` is a set
of subsets of `plusSubformulaClosure φ`) — no per-depth bit; (b) the slice `Q × ℕ × ℕ` is infinite
(`Rlad_slice_infinite`) and the lemma bounds the INDEX of cells, never the fibre; (c) `B` is a
count; (d) nothing external is cited; (e) the lemma is direction-neutral — cells are defined over
all histories — but every landed probe it would be compared with is forward-only, and the header
must say so.

**What the successor must NOT do.** Retreat to a capped ladder (`Probe750.capped_carrier_finite`
shows the carrier finite, the shape `not_finite_width_fmp` refutes); state the lemma over `c`
alone; state it as a `Presented`-level (trace) hypothesis — the realization hypothesis must be
Hit-level per cell (Section C's COLLAPSE); claim `B` as a running-time bound; paper a failure with
`sorry`, an axiom, or a vacuous definition — the honest outcome is `[BLOCKED]` with the obstruction
in the plan file.

**Action required.** File H1 (probe), H3 (lemma + `ladderModel` + `Adm`), H4 (realization) —
Section H, filed by this task's Phase 4.

## Section B -- Obligation (2): run-layer phase 3, (C)'s general row

**Current record.** OPEN mathematics. Authority: the README's (C) row ("one fixture, so the
general regular `ℤ`-model statement is still the (W) run-layer record's completeness half") and
"Open: obligation (ii)", item 2: "Open mathematics with one positive fixture and no general
argument: `Probe735.not_presented` refutes the trace-level version … `Probe745.hitPresented_modelA`
is the only Hit-level positive, and no Hit-level negative exists anywhere in the tree. No figure."

**What the tree says.** The statement shape is fixed by the README verbatim: for every regular
`ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a finite labelled presentation
`(Q, lab, step)` with `Fintype.card Q` below a computable bound in `φ`, such that
`HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)` — i.e. `HitPresented M τ t φ lab step k` (row
4 of 0.1). The positive fixture `Probe745.hitPresented_modelA` (row 5) is stated at EVERY `k ≥ 1`
with the window `presentationSize k = Nat.card (KType (clSig Fp) k)` written into the statement, so
on the fixture the probe half and the bound half are one theorem (`card_QA_presentationSize`
gives the count). Its ingredients are `kTypeOf_listSeg_replicate_eventually_periodic_bounded`
(eventual periodicity of a constant block's `k`-type, threshold bounded by a count), the cut
surgery `inFamily_of_shrink_run` (shrink direction only, single-segment containment), and the
FIXTURE fact `run_subset_middle` (the containment). The unconditioned transport `↔` (threshold
`3·(m₀ + p)`) is recorded by 749's summary as a non-goal, not started; the general row may need
it, the probe below does not.

*Where the evidence is thin.* Model A is `box`/`stab`-free (`φ := Fp`) with a finite-width slice
(`Fin 3`), and every landed (C)/(S) statement is forward-only. The general row ranges over
`⊡`-bearing `φ` and over infinite-width models — exactly the two axes along which the refutations
live (`not_finite_width_fmp`'s witness `Φ` is `⊡`-bearing; infinite width is forced by it). Nothing
in the tree tests `HitPresented` on either axis. The cheapest falsifier is a probe on `Node`
(`NoFiniteWidth.M`: infinite width, `⊡`-bearing witness, library model) at a seam `(t, Node.pre k)`,
with `τ` the canonical history through it (`canon`, `path_eq_canon`):

```
-- either headline is the deliverable; the probe records which
theorem hitPresented_node (t : ℤ) (k : ℕ) (hk : 1 ≤ k) :
    HitPresented NoFiniteWidth.M τ t Φ' (labN L) (stepN L) k
    -- positive: a presentation of size L exhibited as a COUNT, as presentationSize k is on model A
theorem not_hitPresented_node (t : ℤ) (k : ℕ) (hk : 1 ≤ k) {Q} [Fintype Q] [DecidableEq Q] (lab) (step) :
    ¬ HitPresented NoFiniteWidth.M τ t Φ' lab step k
    -- negative: (C)'s general row is FALSE; route R1 is blocked at (C)
```

with `Φ'` the fixture witness `Φ`, fallback `D`, then `⊡Xp` (the letter that separates `pre 0`
from `pre 1`), recorded in that order in the probe header; the chosen formula is written into the
statement. On `Node` the pre-run is one constant block before the seam and the post-run one after,
so the single-segment containment `inFamily_of_shrink_run` needs is again a fixture fact, as
`run_subset_middle` was on model A.

**Scope decision.** Two records: the probe (Section H2) first, the general row (Section H5) after
it, with a LOGICAL edge H2 → H5 — a Hit-level negative at H2 makes H5's statement false and a
positive gives it a second fixture (its first on both untested axes). H2 carries the highest
information per line of anything on the frontier: a Hit-level negative would be the FIRST in the
tree, and because Stage 1 proceeds on R1 alone with no fallback (ROADMAP), it would block the
route at (C). That outcome is a **Stage 0 user ruling**, never an agent transition: the probe
header records it, H5 and H6 then wait on the user, and H3/H4 keep standalone value (the ladder
realization is the HWZ Theorem 14 (⇐) direction for this semantics — a literature DESCRIPTION of
the obstruction, cited as orientation and sourcing no claim, guardrail (d)). Decision D4 (agent):
`Node` is the fixture for both probes.

Guardrails: (a) `HitPresented` is over the closure alphabet `clSig φ`; (b) `Node` has infinite
width and the probe adds no finiteness; (c) `L` and `sizeBound φ k` are counts — the fixture's was
`Nat.card (KType (clSig Fp) k) + 6` — never `∃ L` and never a running time; (d) no automata
library, no cslib; (e) `Node`'s witness is forward-looking (`⊡Xp`-shaped letters); nothing here
bears on `⊡(Pp)` and the header must say so, and no claim that `⊡`-letters discriminate between
devices is made.

**What the successor must NOT do.** Weaken `HitPresented` to `Presented` (refuted as a
completeness carrier by `Probe735.not_presented`); replace the exhibited count by `∃ L`; assume a
finite-width or finite-fibre fixture; treat a negative as an agent-decidable abandonment of H5/H6;
cite an external Büchi/MSO decidability theorem in place of the general argument.

**Action required.** File H2 (probe) and H5 (general row, research-first) — Section H.

## Section C -- Obligation (3): (S) beyond its landed corner

**Current record.** The README's (S) row: "DISCHARGED for `box`/`stab`-free `φ` at one seam …
What remains open: `box`/`stab`-bearing `φ`, and every seam but the one." Its "(S): what landed and
what did not" section assigns the first half away: "The limitation is therefore assigned to (W),
not left as a gap in (S)." `presented_modelOf` and `hitCl_modelOf_eq_hitOf` (row 4) stand, C14-pinned
(row 19).

**What the tree says.** Two machine-checked facts fix the design (row 7, both wired, PASS this
round):

- **WIDTH** — `Probe747.modelOf_incomplete`: for every `Cons` presentation on any `[Fintype Q]`,
  `modelOf` validates `Φ.neg` while `¬ PlusValidZTime Φ.neg` (`not_plusValidZTime_neg_Φ`, row 13)
  — "whatever clauses are added to `Cons`", because the width is a property of `ofSlicedStep` on
  `Q`. Any (S)-extension of `modelOf`/`Cons` to `box`/`stab`-bearing `φ` is therefore a
  finite-width object class that cannot be the soundness half of a complete lift — the shape
  guardrail (b) names.
- **COLLAPSE** — `Probe747.stab_iff_of_presented_nowUnique`: at a trace-level `Presented` seam
  whose presentation marks at most one `now` state (`Cons.nowUnique`, which (S) found necessary),
  `ψ ↔ ⊡ψ` for every closure formula — so (S)'s own realization hypothesis cannot witness any
  `⊡`-refutation; the lift's realization hypothesis must be Hit-level per cell.

The mechanism of the `box`/`stab` restriction is also landed: `box_time_invariant` makes `□ψ` one
global bit per model, `plusStateLocal_stab_iff` collapses `⊡` for state-local formulas, and the
anchor layer already states the two equations the letters must satisfy — `box_mem_tpOf_iff` (one
global bit per `□`-subformula) and `stab_mem_tpOf_iff` (one bit per cell), with
`anchorCons_anchorCells` their completeness side for EVERY model and `AnchorCons` the finite object
they define.

**Scope decision.** **No standalone (S) record is filed** — research-report **Decision D1**, an
agent decision re-openable by `/revise`. Grounds: the README's own assignment plus WIDTH/COLLAPSE.
The obligation's two halves land where the README puts them:

- the `box`/`stab` half is an **acceptance clause of H4's realization theorem**: `LadderCons` pins
  `lab q (box ψ)` to one global bit and the `stab ψ` letter at `(q, c, n)` to that cell's bit —
  the equations of `box_mem_tpOf_iff` / `stab_mem_tpOf_iff` — and `ladderRealized` is stated for
  ALL `φ`, `box`/`stab` letters included, on the ladder's infinite-width frame (so WIDTH does not
  bite) at the Hit level (so COLLAPSE does not bite);
- the "every seam but the one" half **is** the composition theorem of Section D (H6): one
  presentation-level object witnessing `¬ PlusValidZTime φ`, over all seams and times, is exactly
  what (W) names.

`presented_modelOf` is untouched; nothing is retired; a record titled "(S) for `box`-bearing `φ`"
would be filed against the README's own assignment and is not proposed.

Guardrails: (b) is the whole reason — a finite-width (S)-extension reproduces a refuted shape; (a)
the `box`/`stab` bits are closure-indexed letters; (c) no bound is claimed here at all; (d)
nothing external; (e) `presented_modelOf` is forward-only (`Fp`-shaped fixtures) and remains so.

**What the successor must NOT do.** Edit `Realize.lean`'s `Cons` or `modelOf` to admit
`box`/`stab` (WIDTH makes it futile for the lift); state any Hit-level realization at the trace
level; file an (S)-extension record.

**Action required.** None beyond H4 and H6; this section is the written reason no (S) record
appears in Section H.

## Section D -- The lift, named in the tree and filed nowhere

**Current record.** The (W) row's statement shape: "one presentation-level object witnesses
`¬ PlusValidZTime φ` for some regular `ℤ`-model, history and time." The README's "What the lift
would deliver" paragraph: without the bound a landed composition theorem is "at best
semi-decidable — and NOT `Decidable (PlusValidZTime φ)`"; and row 15 of 0.2: `Decidable (PlusValidZTime`
has zero statement-level occurrences anywhere. Nothing names the lift as a record.

**What the tree says.** With the anchor layer (`anchorCons_anchorCells`, `anchorCells_ncard_le`),
both halves of obligation (ii) (Sections A, B) and the admissibility set `Adm` (Section A), the
statement has a shape:

```
theorem not_plusValidZTime_iff_ladderRefutes (φ : PlusFormula) :
    ¬ PlusValidZTime φ ↔
      ∃ (Q : Type) (_ : Fintype Q) (_ : DecidableEq Q) (lab) (step) (pend) (hA : Adm …),
        Fintype.card Q ≤ objBound φ ∧ LadderCons φ lab step pend ∧ LadderRefutes φ lab step pend
```

(→), the completeness half: a refuting regular `ℤ`-model has cells bounded by `anchorCells_ncard_le`,
per-cell presentations by (C)'s general row (H5), and finitely many deadline classes by the
stabilization bound (H3) — assembled into one ladder object of size `objBound φ`. (←), the
soundness half: H4's realization theorem at the refuting cell gives a regular `ℤ`-model
(`ladderFrame_isRegular`), a history and a time at which `φ` fails. `objBound φ` is a COUNT (cells
times deadline classes), never a running time. Depth `k = 1` throughout (0.1 reading (iii)).

**The corollary — the AIM — is stated here and nowhere earlier.** `Decidable (PlusValidZTime φ)`
follows by bounded enumeration over objects of size `≤ objBound φ` (finitely many on `Fin n`, with
`LadderCons` and `LadderRefutes` decidable on a `Fintype`, as `AnchorConsFin`'s
`decidableAnchorConsFin` already is on a concrete finite object). No record before H6 may state it.

**Scope decision.** One record (Section H6), research-first, depending on H4 and H5 (both
logical). Not costable until both predecessors have shapes: H6's research phase re-derives the
statement from them. Honest outcomes: landed; or `[BLOCKED]` on whichever predecessor did not close.

Guardrails: (a) the object is a time-axis ladder over the closure alphabet; (b) its slice is
infinite — the object bounds cells and deadline classes, never the fibre; (c) `objBound` is a
count and the corollary is a `Decidable` instance, not a complexity statement — the held 2EXPTIME
ceiling is neither cited nor approached and rules proposals out only; (d) the enumeration is the
tree's own, no external decidability theorem is cited; (e) if H4/H5 land forward-only, the lift is
forward-only and says so — nothing here is a claim about `⊡(Pp)` beyond what
`Probe719Backward.pastStab_iff_allBwdPathsMeet` fixes.

**What the successor must NOT do.** State the corollary in H3-H5; claim decidability from the
semi-decidable `∃ object` form without the bound; introduce a finite-fibre assumption to make the
enumeration finite (the bound comes from counts, not from the fibre); cite complexity.

**Action required.** File H6 — Section H.
