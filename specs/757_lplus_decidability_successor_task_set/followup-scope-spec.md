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

**Amendment (2026-10-11).** The lemma above is REFUTED for every bound by the twelfth wired probe
(`specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`: `cell_ne`,
`exhibited_form_refuted`, `exists_form_refuted` — the gap `n − c` between the two counters is
observable through a closure of size 12 while each counter is arbitrarily large), so no finite cell
index `Q × Fin (B+1) × Fin (B+1)` follows from it and the dependent statements H4 and H6 are amended
below. The computable index of WHICH cell a ladder state has is an open sub-problem: recorded, not
solved, and not re-stated over any substitute (the candidate carrying a clipped gap coordinate is
research-level and unproved). The SET of cells stays finite and bounded (`anchorCells_finite`,
`anchorCells_ncard_le`). Separately, `Adm` landed as a CARRIER restriction in
`RaySummary/LadderModel.lean` (`LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}`,
`RladAdm`, `ladderFrameAdm`, `ladderModel`) beside the instance-free `ladderFrame` (`no_fwd`,
`no_bwd_of_idle`: its own seriality hypotheses are unsatisfiable on the full carrier `Q × ℕ × ℕ`),
not as an object condition on `ladderFrame`'s carrier — this amends the "Consistency conditions and
`Adm`" paragraph's "stated over the carrier `ladderFrame` already has". See
`specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md`.

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

**Amendment (2026-10-11).** The step "finitely many deadline classes by the stabilization bound
(H3)" is DELETED: the stabilization lemma is refuted for every bound
(`ladder-cell-refutation.lean`), so no finite index of ladder states per cell is available. How the
finitely many cells (`anchorCells_ncard_le`) and the per-cell presentations (H5) are assembled into
ONE finite ladder object is the open sub-problem recorded in Section A — not solved here and not
re-stated over a substitute. In the (←) half, `ladderFrame_isRegular` reads
`ladderFrameAdm_isRegular`: the realization theorem is stated on the admissible carrier
(`ladderFrameAdm`, `ladderModel`, `RaySummary/LadderModel.lean`), since `ladderFrame` has no
instances. `objBound φ` remains a COUNT whose shape is open; no bound, cost figure or complexity
claim is added.

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

## Section H -- The six records, filed by this task

Six records, T1-T6, **filed by this task's own implementation phase** (Phase 4 of plan 01) through
the sanctioned writer `state-write.sh` with `dependencies`, `file_scope`, `topic: "decidability"`
and `task_type: "lean4"` set in the creation object, then `manage-topics.sh set`, then
`validate-state.sh` — the deliberate departure from the 721/718 precedents, whose Section H said
"file with `/task`, by the orchestrator or the user". The record text below is the EXACT string
each description receives (held in `successor-records.json` beside this file and passed to the
writer unchanged); the numbers received (758-763, filed 2026-10-10) are in the map table, the headings and the
typed edges below. Kahn order: T1 → T2 → T3 → T4 → T5 → T6.

**Why six and not fewer** (multi-task-creation Component 0: consolidate unless (a) disjoint scope,
(b) different type or domain, (c) real dependency ordering, (d) size): T1/T2 vs T3-T6 divide by (a)
— evidence territory vs library territory — and by (c); T1 vs T2 by (d) and by being different
statements with different verdict semantics; T3 vs T4 by (c) and by the costability boundary the
README itself draws ("no cost figure until that lemma is stated") — Decision D3; T5 by (c) against
T2 and by being the one open-mathematics item; T6 by (c) against both chains. **Why not more**: no
(S)-extension record (Section C, Decision D1); no record for `Adm` alone (it is T3's definition); no
second-fixture record beyond `Node` until T2 reports.

**Edges are typed.** A *logical* edge means the dependent's statement is fixed by, or false
without, the predecessor; a *serialization* edge records a shared `file_scope` inside the set that
CLAUDE.md's batching rule turns into an edge rather than an exclusion (Decision D5). Every edge
points inside T1-T6; overlaps with 744 (`RaySummary/README.md`, `check-module-invariants.sh`), 734
(`check-evidence-probes.sh`) and 410 (`typst/generated/status.typ`) OUTSIDE the set are named in
each description and left to the admission gate — no cross-set edge is added.

**Costability.** Only T1 and T2 carry a figure, each with its basis measured this round (Section
0.3); T3-T6 are recorded as NOT costable with the reason, and no figure is invented (Decision D6:
they are filed anyway, because filing is in scope by user instruction and each has a statement
shape and a `file_scope`).

### T-label → task number

| Label | Task number | Slug |
|---|---|---|
| T1 | **758** | `node_cell_stabilization_probe` |
| T2 | **759** | `node_hit_presented_probe` |
| T3 | **760** | `ladder_model_cell_stabilization_lemma` |
| T4 | **761** | `ladder_realization_theorem` |
| T5 | **762** | `hit_presented_general_row` |
| T6 | **763** | `ladder_lift_decidability_corollary` |

### H1 (T1 = task 758) -- Node fixture probe: cell stabilization in the deadline index (preCell_stable, preCell_zero_ne, postCell_stable)

**Proposed title**: Node fixture probe: cell stabilization in the deadline index (preCell_stable, preCell_zero_ne, postCell_stable)

**Proposed `task_type`**: `lean4` — **`topic`**: `decidability` — **slug**: `node_cell_stabilization_probe`

**Proposed dependencies** (typed): none

**Proposed `file_scope`** (files only, never a directory root):
  - `specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean` *(new)*
  - `scripts/check-evidence-probes.sh`
  - `FormalSystem/Metalogic/Decidability/RaySummary/README.md`

**Depth**: none (cells are sets of closure types, not k-types)

**Costability**: YES: 400-800 lines, 1-2 implement dispatches. Basis: backward-dual-asymmetric-fixture.lean (619 lines, same fixture, one operator) and deadline-ladder-branching.lean (103 lines), both measured by wc -l this round.

**Description** (the exact string filed):

> STATEMENT. A wired probe on the LIBRARY fixture `NoFiniteWidth.M` (`PlusSlicedCertificate/Limits/NoFiniteWidth.lean`; regular by `F_isRegular`, histories canonical by `path_eq_canon`), the one-region special case of the deadline ladder, for its own ⊡-bearing witness `Φ` (fallback `D`, recorded in the probe header in that order; the chosen formula is written into the statements):
>   `theorem preCell_stable (k k' : ℕ) (hk : 1 ≤ k) (hk' : 1 ≤ k') (z : ℤ) : cellAt M Φ (.pre k) z = cellAt M Φ (.pre k') z`
>   `theorem preCell_zero_ne (z : ℤ) : cellAt M Φ (.pre 0) z ≠ cellAt M Φ (.pre 1) z`  -- the deadline index is real
>   `theorem postCell_stable (k k' j j' : ℕ) (hj : 1 ≤ j) (hj' : 1 ≤ j') (z : ℤ) : cellAt M Φ (.post k j) z = cellAt M Φ (.post k' j') z`  -- the thread index is invisible
> with `cellAt` from `RaySummary/AnchorLayer.lean` (time-independent by `cellAt_eq_cellAt`). Depth: none — cells are sets of closure types, no k occurs.
> 
> WHY. Run-layer phase 2's FIRST statement is the stabilization of realized cells on the ladder (`RaySummary/README.md`, "(W): what landed and what did not", obligation (ii) item 1); the record that states it for a general object (its successor) has no cost figure until this probe reports. 750's mitigation R-A: prove or refute stabilization on `Node` first, where the expected cells are `pre 0`, `pre (≥ 1)`, `x`, `post`. The probe imports the library model and re-proves nothing.
> 
> EITHER VERDICT IS THE DELIVERABLE. Stabilization at bound 1 confirms the mechanism (branch-time saturation). A failure IS the obstruction the README names: record it in the probe header as such and mark the task [BLOCKED] — never a sorry, an axiom, a vacuous definition, or a finite-fibre retreat (the capped ladder is refuted by `Probe750.capped_carrier_finite` + `not_finite_width_fmp`).
> 
> GUARDRAILS (ROADMAP Stage 1): (a) cells are closure-indexed sets over the time axis, never one bit per depth; (b) `Node` has infinite width and the probe adds no finiteness; (c) no bound of any kind is claimed — the probe counts cells; (d) zero debt: no external Büchi/MSO lemma, no cslib require; (e) the fixture's witness is forward-looking and the header must say the result is forward-only — nothing here bears on ⊡(Pp), and no claim that ⊡-letters discriminate between devices.
> 
> FILE SCOPE. The new probe file; one WIRED entry in `scripts/check-evidence-probes.sh`; one sentence in the RaySummary README's evidence paragraph (durable anchors only — no task numbers, no record-versioning language). Cross-set collisions, left to the admission gate (no edge): 734 ([PARTIAL], Stage 0) and 744 (not_started) also declare the script and the README respectively.
> 
> COSTABLE: yes — 400-800 lines, 1-2 implement dispatches (basis: `backward-dual-asymmetric-fixture.lean`, 619 lines, same fixture; `deadline-ladder-branching.lean`, 103 lines). Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Section A and H1.

**Action required**: filed by this task's Phase 4 (`state-write.sh`, then `manage-topics.sh set`),
in Kahn position 1 of 6.

### H2 (T2 = task 759) -- Node fixture probe: HitPresented for a ⊡-bearing formula at an infinite-width seam (hitPresented_node or its negation)

**Proposed title**: Node fixture probe: HitPresented for a ⊡-bearing formula at an infinite-width seam (hitPresented_node or its negation)

**Proposed `task_type`**: `lean4` — **`topic`**: `decidability` — **slug**: `node_hit_presented_probe`

**Proposed dependencies** (typed): **T1 = 758** (serialization: shared file_scope on scripts/check-evidence-probes.sh and RaySummary/README.md; T1's history characterization of pre k is reused as an efficiency, not a logical need)

**Proposed `file_scope`** (files only, never a directory root):
  - `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` *(new)*
  - `scripts/check-evidence-probes.sh`
  - `FormalSystem/Metalogic/Decidability/RaySummary/README.md`

**Depth**: 1 ≤ k, every k

**Costability**: YES, with a wide band: basis hit-presented-model-a.lean (1595 lines, measured this round; two implement dispatches under --hard per 749's summary [CARRIED-UNVERIFIED]); a negative is cheaper than a positive.

**Description** (the exact string filed):

> STATEMENT. A wired probe on the LIBRARY fixture `NoFiniteWidth.M` at a seam `(t, Node.pre k)` with `τ` the canonical history through it (`canon`, `path_eq_canon`), for a ⊡-bearing formula `Φ'` := the fixture witness `Φ`, fallback `D`, then `⊡Xp` (recorded in that order in the header; the chosen formula is written into the statement), at every depth `1 ≤ k`. EITHER headline is the deliverable, and the probe records which:
>   `theorem hitPresented_node (t : ℤ) (k : ℕ) (hk : 1 ≤ k) : HitPresented NoFiniteWidth.M τ t Φ' (labN L) (stepN L) k`  -- positive: a presentation of size L, exhibited as a COUNT in the statement (as `presentationSize k = Nat.card (KType (clSig Fp) k)` is in `Probe745.hitPresented_modelA`), never ∃ L
>   `theorem not_hitPresented_node (t : ℤ) (k : ℕ) (hk : 1 ≤ k) {Q} [Fintype Q] [DecidableEq Q] (lab) (step) : ¬ HitPresented NoFiniteWidth.M τ t Φ' lab step k`  -- negative: (C)'s general row is FALSE
> `HitPresented` is `RaySummary/Trace.lean`'s Hit-level hypothesis (family-triple SETS); the trace-level `Presented` is refuted as a completeness carrier by `Probe735.not_presented` and must not be used.
> 
> WHY THIS IS THE HIGHEST-INFORMATION PROBE ON THE FRONTIER. The only Hit-level positive, `Probe745.hitPresented_modelA`, is box/stab-free (`Fp`) on a finite-width slice (`Fin 3`); the general row ranges over ⊡-bearing φ and infinite-width models — the two axes along which the refutations live — and nothing in the tree tests `HitPresented` on either. `Node` is both at once. A Hit-level negative would be the first in the tree and would block route R1 at (C); Stage 1 proceeds on R1 alone with no fallback. THAT OUTCOME IS A STAGE 0 USER RULING, NEVER AN AGENT TRANSITION: record it in the probe header, leave the general-row and lift successors to the user, and do not abandon or re-scope them yourself. A positive extends the model-A truncation argument (`kTypeOf_listSeg_replicate_eventually_periodic_bounded`, `inFamily_of_shrink_run`; on `Node` the single-segment containment is a fixture fact as `run_subset_middle` was) to infinite width and ⊡-letters.
> 
> GUARDRAILS: (a) the alphabet is `clSig Φ'`, closure-indexed; (b) infinite width, no finiteness added; (c) `L` is a count of states, never a running time or an ∃ L; (d) zero debt — no automata library, no Büchi/MSO citation, no cslib require; (e) forward-only: the header must say nothing here bears on ⊡(Pp), and ⊡-letters are not claimed to discriminate between devices. No sorry, axiom or vacuous definition: if neither headline closes, mark [BLOCKED] with the goal state recorded.
> 
> FILE SCOPE. The new probe file; one WIRED entry in `scripts/check-evidence-probes.sh`; one sentence in the RaySummary README (durable anchors only, no task numbers). Cross-set collisions left to the admission gate: 734 (script), 744 (README). Serialization edge on T1 (shared script and README), not a logical dependency.
> 
> COSTABLE: yes, with a wide band — basis `hit-presented-model-a.lean` (1595 lines; two implement dispatches under --hard per 749's summary, carried-unverified); a negative is cheaper than a positive. Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Section B and H2.

**Action required**: filed by this task's Phase 4 (`state-write.sh`, then `manage-topics.sh set`),
in Kahn position 2 of 6.

### H3 (T3 = task 760) -- Ladder model, admissibility set Adm, and the cell-stabilization lemma ladderCell_stabilizes over both counters (c, n)

**Proposed title**: Ladder model, admissibility set Adm, and the cell-stabilization lemma ladderCell_stabilizes over both counters (c, n)

**Proposed `task_type`**: `lean4` — **`topic`**: `decidability` — **slug**: `ladder_model_cell_stabilization_lemma`

**Proposed dependencies** (typed): **T1 = 758** (logical: the probe's verdict fixes the bound shape (exhibited B vs ∃ B) and whether the lemma is stateable at all); **T2 = 759** (serialization: shared file_scope on RaySummary/README.md)

**Proposed `file_scope`** (files only, never a directory root):
  - `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` *(new)*
  - `FormalSystem/Metalogic/Decidability/RaySummary.lean`
  - `FormalSystem.lean`
  - `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`
  - `scripts/check-module-invariants.sh`
  - `docs/theorem-index.md`
  - `FormalSystem/Metalogic/Decidability/RaySummary/README.md`
  - `typst/generated/status.typ`

**Depth**: none (cells), consumer depth k = 1

**Costability**: NO — the statement's bound shape (exhibited B vs ∃ B) and the admissibility set are fixed by T1's verdict; no comparable in the tree (the anchor layer, 418 lines, is a different kind of statement). No figure is invented.

**Description** (the exact string filed):

> STATEMENT (library, over a general finite object; new module `RaySummary/LadderModel.lean`). First a MODEL on the landed frame, since `ladderFrame` (`RaySummary/RunLayer.lean`) is a `FrameOver intOrder` and `cellAt` needs a `TaskModel`:
>   `def ladderModel (step : Q → Q → Bool) (pend : Q → Bool) (fwd) (bwd) (lab : Q → Atom → Bool) : TaskModel (ladderFrame step pend fwd bwd).toTaskFrame`  -- valuation reads the object component q
> then the admissibility set `Adm` (named in the RaySummary README as "c ∈ Adm q … named here and not costed", defined nowhere — this record defines it: which objects supply `ladderFrame`'s `fwd`/`bwd`; a pending state at `c = 0` needs a discharging successor), and the lemma, over BOTH ladder counters:
>   `theorem ladderCell_stabilizes (φ : PlusFormula) … : ∀ (q : Q) (c c' n n' : ℕ) (z : ℤ), (plusSubformulaClosure φ).card ≤ c → (plusSubformulaClosure φ).card ≤ c' → (plusSubformulaClosure φ).card ≤ n → (plusSubformulaClosure φ).card ≤ n' → cellAt (ladderModel …) φ (q, c, n) z = cellAt (ladderModel …) φ (q, c', n') z`
> with the bound `B := (plusSubformulaClosure φ).card` EXHIBITED in the statement; fallback `∃ B : ℕ, ∀ q c c' n n' z, B ≤ c → … → cellAt … = cellAt …` if the exhibited bound fails. Either form yields finitely many deadline classes per counter and a finite cell index `Q × Fin (B+1) × Fin (B+1)`, which the realization record builds on.
> 
> WHY BOTH COUNTERS. `Count` (`RunLayer.lean`): while pending `c' + 1 = c` (the region ends in exactly c steps — a letter needing d more steps is absent at c < d); at an idle state `c' = n` (the next region's length is n — a letter looking d steps into it depends on n for n < d). The README's "in the deadline counter c" is a shorthand; its "cells indexed by (q, deadline class)" is correct read as the class of the pair. Agent decision (D2/D3 of the design record), re-openable by /revise: this lemma is its own record, split from the realization theorem at the costability boundary the README draws ("no cost figure until that lemma is stated"); fold back with one /revise if preferred.
> 
> B IS A COUNT. The sentence the tree attaches to `anchorCells_ncard_le` applies verbatim: a cardinality bound on cells, syntactic in |cl φ|, not a complexity bound of any kind. Depth: none (cells are closure-type sets); the run layer's consumer depth is k = 1.
> 
> CONTINGENCY. If T1 refuted stabilization at the fixture, the ∃ B form is false too: mark [BLOCKED] with the obstruction in the plan file. Never sorry, axiom, vacuous definition, trace-level (`Presented`) hypothesis, or a capped ladder (`Probe750.capped_carrier_finite` shows that carrier finite — the shape `not_finite_width_fmp` refutes).
> 
> GUARDRAILS: (a) time-axis object over the closure alphabet; (b) the slice `Q × ℕ × ℕ` is infinite (`Rlad_slice_infinite`) — the lemma bounds the INDEX of cells, never the fibre; (c) no upper bound; (d) zero debt, no cslib require; (e) direction-neutral statement, but every probe it is compared with is forward-only — say so.
> 
> FILE SCOPE (shared library set). New `LadderModel.lean`; aggregator `RaySummary.lean` and `FormalSystem.lean`; C14 pins in `KTypeSummaryAxiomTest.lean` and `scripts/check-module-invariants.sh`; `docs/theorem-index.md` rows (count-not-complexity sentence); the RaySummary README; `typst/generated/status.typ` (regenerated by the pre-commit hook). Durable anchors only outside specs/** — no task numbers. Cross-set collisions left to the admission gate: 744 (README, invariants script), 410 (status.typ). Logical edge on T1; serialization edge on T2 (README).
> 
> NOT COSTABLE, and why: the bound shape and `Adm` are fixed by T1's verdict; no comparable statement exists in the tree (the anchor layer, 418 lines, is a different kind of statement). Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Section A and H3.

**Action required**: filed by this task's Phase 4 (`state-write.sh`, then `manage-topics.sh set`),
in Kahn position 3 of 6.

### H4 (T4 = task 761) -- Ladder realization theorem: LadderCons and ladderRealized per ladder cell for all φ including box/stab letters

**Proposed title**: Ladder realization theorem: LadderCons and ladderRealized per ladder cell for all φ including box/stab letters

**Proposed `task_type`**: `lean4` — **`topic`**: `decidability` — **slug**: `ladder_realization_theorem`

**Proposed dependencies** (typed): **T3 = 760** (logical: ladderModel, Adm (a carrier restriction) and LadderState are this theorem's inputs; no finite cell index is provided (refuted, open sub-problem))

**Proposed `file_scope`** (files only, never a directory root):
  - `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` *(new)*
  - `FormalSystem/Metalogic/Decidability/RaySummary.lean`
  - `FormalSystem.lean`
  - `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`
  - `scripts/check-module-invariants.sh`
  - `docs/theorem-index.md`
  - `FormalSystem/Metalogic/Decidability/RaySummary/README.md`
  - `typst/generated/status.typ`

**Depth**: 1 ≤ k stated, consumer depth k = 1

**Costability**: NO — T3 landed no bound (its stabilization lemma is refuted); sized by the open index sub-problem and by how much of Realize.lean's 1004 lines transfers; the RaySummary README records that it has no figure. No figure is invented.

**Description** (as amended 2026-10-11; the string filed 2026-10-10 is in this file's git history):

> AMENDED 2026-10-11 (carrier repair): the frame this record is stated on is the admissible-carrier frame of RaySummary/LadderModel.lean; see specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md.
> 
> STATEMENT (library; new module `RaySummary/LadderRealize.lean`). Run-layer phase 2's soundness half (object → model), the ladder analogue of `Realize.lean`'s `Cons`/`cons_localRun`/`presented_modelOf`, stated at the HIT level per ladder cell:
>   `structure LadderCons (φ : PlusFormula) (lab) (step) (pend) : Prop`  -- `Cons`'s fields with the liveness fields `ulive`/`slive` replaced by the ladder's structural liveness (c strictly decreases while pending, by `Count`), and with the box/stab letters PINNED per cell by the anchor layer's equations: `lab q (box ψ)` is one global bit (`box_mem_tpOf_iff`), the stab letter at `(q, c, n)` is that cell's bit (`stab_mem_tpOf_iff`); `anchorCons_anchorCells` is the completeness side of exactly those equations
>   `theorem ladderCons_localRun …`  -- every ladder run satisfies the run conditions
>   `theorem ladderRealized … (k : ℕ) (hk : 1 ≤ k) : HitCl (ladderModel …) τ t φ k = ↑(hitOf (truncate B …) … (clNow φ) k)`  -- per ladder cell, for ALL φ, box/stab letters INCLUDED, the cell being `cellAt (ladderModel …) φ (t, ⟨(q, c, n), h⟩)` on the world state `ℤ × LadderState Q pend` (the `ℤ` component is invisible to `cellAt`, `cellAt_eq_cellAt`, but must be written). NO finite index of which cell a ladder state has is provided by any predecessor: the index `Q × Fin (B+1) × Fin (B+1)` is refuted (`ladder-cell-refutation.lean`: `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted`) and is DELETED here; which cell a ladder state has is an OPEN SUB-PROBLEM, recorded and not re-stated over any substitute. The SET of cells stays finite and bounded (`anchorCells_finite`, `anchorCells_ncard_le`)
> The box/stab clause is the acceptance criterion: it is where obligation (3)'s first half ("(S) beyond its landed corner": box/stab-bearing φ) lands, by the README's own assignment of that limitation to (W). No standalone (S) record exists for it (agent decision D1, re-openable by /revise).
> 
> WHY HIT-LEVEL, WHY THIS FRAME. Two machine-checked facts (wired probe `w-soundness-shape-refuted.lean`): WIDTH — `Probe747.modelOf_incomplete`: `modelOf` on any `Cons` presentation validates `Φ.neg` while `¬ PlusValidZTime Φ.neg`, whatever clauses are added, because `ofSlicedStep` on a Fintype has finite width; COLLAPSE — `Probe747.stab_iff_of_presented_nowUnique`: at a trace-level `Presented` seam with `nowUnique`, ψ ↔ ⊡ψ for every closure formula, so trace-level realization cannot witness any ⊡-refutation. Hence the hypothesis is `HitPresented`-shaped per cell and the frame is `ladderFrameAdm` on the admissible carrier `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` (`RaySummary/LadderModel.lean`; slice infinite — `(q, 0, n)` is admissible for every `n`, `Rlad_slice_infinite` one level down; regular by `ladderFrameAdm_isRegular`), with the model `ladderModel` reading the object component; `ladderFrame` itself has no instances (`no_fwd`, `no_bwd_of_idle`) and stays beside it, untouched. `presented_modelOf` is untouched and not re-proved.
> 
> DEPTH. `1 ≤ k` stated; the consumer depth is k = 1 (every landed bridge carries `1 ≤ k`; the closure alphabet makes nesting visible through letters).
> 
> CONTINGENCY. If the theorem does not close, mark [BLOCKED] with the goal state recorded; never sorry, axiom, vacuous definition, a trace-level hypothesis, or any finite-fibre/finite-width assumption. T3/T4 keep standalone value whatever T2 reports (the HWZ 2000 Theorem 14 ⇐ direction for this semantics — a literature description that sources no claim).
> 
> GUARDRAILS: (a) closure-indexed letters over the time axis, box/stab bits included; (b) infinite width, no fibre bound; (c) no upper bound — B and the presentation size are counts; (d) zero debt: no Büchi/MSO lemma cited in place of a proof, no cslib require; (e) if the landed form is forward-only, say so; no device-discrimination claim.
> 
> FILE SCOPE: new `LadderRealize.lean` plus the shared library set (`RaySummary.lean`, `FormalSystem.lean`, `KTypeSummaryAxiomTest.lean`, `check-module-invariants.sh`, `docs/theorem-index.md`, RaySummary README, `typst/generated/status.typ`). Durable anchors only outside specs/**. Cross-set collisions left to the admission gate: 744 (README, invariants), 410 (status.typ). Logical edge on T3.
> 
> NOT COSTABLE, and why: T3 landed no bound (its stabilization lemma is refuted); sized by the open index sub-problem and by how much of `Realize.lean` (1004 lines) transfers; the README records it has no figure. Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Sections A, C and H4.

**Action required**: filed by this task's Phase 4 (`state-write.sh`, then `manage-topics.sh set`),
in Kahn position 4 of 6.

### H5 (T5 = task 762) -- (C)'s general row: exists_hitPresented with sizeBound φ k a count, for every regular ℤ-model (run-layer phase 3)

**Proposed title**: (C)'s general row: exists_hitPresented with sizeBound φ k a count, for every regular ℤ-model (run-layer phase 3)

**Proposed `task_type`**: `lean4` — **`topic`**: `decidability` — **slug**: `hit_presented_general_row`

**Proposed dependencies** (typed): **T2 = 759** (logical: a Hit-level negative at T2 makes this statement false (route R1 blocked at (C), a Stage 0 ruling); a positive supplies its second fixture, the first on both untested axes); **T4 = 761** (serialization: shared library set (RaySummary.lean, FormalSystem.lean, pins, index, README, status.typ))

**Proposed `file_scope`** (files only, never a directory root):
  - `FormalSystem/Metalogic/Decidability/RaySummary/HitComplete.lean` *(new)*
  - `FormalSystem/Metalogic/Decidability/RaySummary.lean`
  - `FormalSystem.lean`
  - `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`
  - `scripts/check-module-invariants.sh`
  - `docs/theorem-index.md`
  - `FormalSystem/Metalogic/Decidability/RaySummary/README.md`
  - `typst/generated/status.typ`

**Depth**: 1 ≤ k

**Costability**: NO — open mathematics; one positive fixture, no negative, no general argument in the tree. Research-first; [BLOCKED] is an honest outcome. No figure is invented.

**Description** (the exact string filed):

> STATEMENT (library, research-first; new module `RaySummary/HitComplete.lean`). Requirement (C)'s general row, verbatim from the RaySummary README's verdict table and "(W) … obligation (ii)" item 2 — run-layer phase 3, the completeness half (model → object): for every regular ℤ-model M, seam (τ, t), formula φ and depth 1 ≤ k, a finite labelled presentation with a computable bound in φ:
>   `theorem exists_hitPresented (M : TaskModel F.toTaskFrame) [F.IsRegular] (τ) (t) (φ) (k) (hk : 1 ≤ k) : ∃ (Q : Type) (_ : Fintype Q) (_ : DecidableEq Q) (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool), Fintype.card Q ≤ sizeBound φ k ∧ HitPresented M τ t φ lab step k`
> with `sizeBound φ k` a COUNT exhibited in the statement (the fixture's was `Nat.card (KType (clSig Fp) k) + 6`, `card_QA_presentationSize`), never an ∃ L and never a complexity bound. `HitPresented` is `RaySummary/Trace.lean`'s Hit-level hypothesis; the trace-level `Presented` is refuted as a completeness carrier (`Probe735.not_presented`) and is not the statement.
> 
> STATUS: OPEN MATHEMATICS. One positive fixture (`Probe745.hitPresented_modelA`, box/stab-free, finite-width slice), no Hit-level negative anywhere, no general argument. The research phase of this record comes FIRST and must re-derive the statement against the tree, including T2's verdict: if T2 returned a Hit-level negative this statement is false and the record is a Stage 0 user matter — do not re-scope or abandon it as an agent. Ingredients that exist: `kTypeOf_listSeg_replicate_eventually_periodic_bounded` (Compose.lean), `inFamily_of_shrink_run` (Transport.lean; shrink direction, single segment); the unconditioned transport ↔ (threshold 3·(m₀+p)) is a recorded non-goal of the bound-half record and may be needed here. HWZ 2000 Def. 12/Thm 14 and GKWZ 2003 Thm 13.6 are indexed (`specs/literature-index.json`) as the literature description of the quasimodel-realisation step; they orient the shape and source no claim — dispatch with --lit.
> 
> CONTINGENCY. If the general argument does not close, the honest outcome is [BLOCKED] with the obstruction recorded; never sorry, axiom, vacuous definition, an external Büchi/MSO decidability theorem cited in place of a proof, or a finite-width/finite-fibre hypothesis smuggled into M.
> 
> GUARDRAILS: (a) `HitPresented` is over the closure alphabet `clSig φ`; (b) M ranges over ALL regular ℤ-models — no width or fibre assumption; (c) `sizeBound` is a count, no running-time claim, the held 2EXPTIME ceiling rules proposals out only; (d) zero debt, no cslib require; (e) if the landed form is forward-only (as every (C)/(S) fixture is), say so; nothing bears on ⊡(Pp).
> 
> FILE SCOPE: new `HitComplete.lean` plus the shared library set. Durable anchors only outside specs/**. Cross-set collisions left to the admission gate: 744, 410. Logical edge on T2; serialization edge on T4 (shared set).
> 
> NOT COSTABLE, and why: no argument exists in the tree to size it against. Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Section B and H5.

**Action required**: filed by this task's Phase 4 (`state-write.sh`, then `manage-topics.sh set`),
in Kahn position 5 of 6.

### H6 (T6 = task 763) -- The lift: not_plusValidZTime_iff_ladderRefutes and the Decidable (PlusValidZTime φ) corollary by bounded enumeration

**Proposed title**: The lift: not_plusValidZTime_iff_ladderRefutes and the Decidable (PlusValidZTime φ) corollary by bounded enumeration

**Proposed `task_type`**: `lean4` — **`topic`**: `decidability` — **slug**: `ladder_lift_decidability_corollary`

**Proposed dependencies** (typed): **T4 = 761** (logical: the (←) soundness half is the realization theorem at the refuting cell); **T5 = 762** (logical: the (→) completeness half assembles the anchor layer and (C)'s general row)

**Proposed `file_scope`** (files only, never a directory root):
  - `FormalSystem/Metalogic/Decidability/RaySummary/Lift.lean` *(new)*
  - `FormalSystem/Metalogic/Decidability/RaySummary.lean`
  - `FormalSystem.lean`
  - `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`
  - `scripts/check-module-invariants.sh`
  - `docs/theorem-index.md`
  - `FormalSystem/Metalogic/Decidability/RaySummary/README.md`
  - `typst/generated/status.typ`

**Depth**: k = 1 throughout

**Costability**: NO — the statement is fixed by T4 and T5; its research phase re-derives it from them. No figure is invented.

**Description** (as amended 2026-10-11; the string filed 2026-10-10 is in this file's git history):

> AMENDED 2026-10-11 (index deletion): the finite cell index this record assembled its object from is refuted and deleted below; see specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md.
> 
> STATEMENT (library, research-first; new module `RaySummary/Lift.lean`). The (W) row's lift from one seam to validity — "one presentation-level object witnesses ¬ PlusValidZTime φ for some regular ℤ-model, history and time" — and obligation (3)'s second half ("every seam but the one"):
>   `theorem not_plusValidZTime_iff_ladderRefutes (φ : PlusFormula) : ¬ PlusValidZTime φ ↔ ∃ (Q : Type) (_ : Fintype Q) (_ : DecidableEq Q) (lab) (step) (pend) (fwd : ∀ t x, ∃ y, RladAdm step pend t x y) (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x), Fintype.card Q ≤ objBound φ ∧ LadderCons φ lab step pend ∧ LadderRefutes φ lab step pend` (`Adm` is a CARRIER restriction defined in `RaySummary/LadderModel.lean` — `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` — not an object-side hypothesis; the object ranges over the admissible carrier, with its seriality `fwd`/`bwd` stated over `RladAdm` on that carrier)
> (→), completeness: a refuting regular ℤ-model has cells bounded by `anchorCells_ncard_le`, per-cell presentations by (C)'s general row (`exists_hitPresented`) — and the step from finitely many CELLS to finitely many ladder STATES per cell has NO support: `ladderCell_stabilizes` is REFUTED for every bound (`specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`: `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted`; the gap n − c is observable) and is DELETED from this assembly. How a refuting model's finitely many cells (`anchorCells_finite`, `anchorCells_ncard_le`, untouched) are assembled into ONE finite ladder object — a computable index of WHICH cell a ladder state has — is an OPEN SUB-PROBLEM of this record: recorded here, not solved, and never re-stated over a concrete substitute (the candidate carrying a clipped gap coordinate is research-level and unproved). (←), soundness: `ladderRealized` at the refuting cell gives a regular ℤ-model (`ladderFrameAdm_isRegular`, the frame on the admissible carrier; `ladderFrame` has no instances, `no_fwd`/`no_bwd_of_idle`), a history and a time where φ fails. Depth k = 1 throughout.
> 
> THE COROLLARY — THE AIM — IS STATED HERE AND NOWHERE EARLIER: `Decidable (PlusValidZTime φ)` by bounded enumeration over objects of size ≤ objBound φ (finitely many on `Fin n`; `LadderCons`/`LadderRefutes` decidable on a Fintype, as `decidableAnchorConsFin` already is on a concrete finite object). `Decidable (PlusValidZTime` has zero statement-level occurrences in the tree today (14 hits, all prose denials); no predecessor record may state it.
> 
> STATUS. Not costable until both predecessors have landed shapes and until the open index sub-problem above is resolved; the research phase re-derives the statement from `LadderRealize.lean` and `HitComplete.lean` as landed. Honest outcomes: landed; or [BLOCKED] on whichever predecessor did not close or on the open sub-problem — never sorry, axiom, vacuous definition, or a decidability claim from the semi-decidable ∃-object form without the bound (the README: without the bound the composition theorem is "at best semi-decidable — and NOT Decidable (PlusValidZTime φ)").
> 
> GUARDRAILS: (a) the ladder object is a time-axis object over the closure alphabet; (b) its slice is infinite — the object bounds cells and deadline classes, never the fibre, and no finite-fibre assumption may be introduced to make the enumeration finite (the bound comes from counts); (c) `objBound φ` is a count (its shape is part of the open sub-problem; no figure exists) and the corollary is a `Decidable` instance, not a complexity statement — the held 2EXPTIME ceiling is neither cited nor approached; (d) zero debt: the enumeration is the tree's own, no external decidability theorem, no cslib require; (e) if T4/T5 land forward-only the lift is forward-only and says so — nothing beyond `Probe719Backward.pastStab_iff_allBwdPathsMeet` is claimed about ⊡(Pp). Dispatch with --lit (HWZ 2000 / GKWZ 2003 indexed, orientation only).
> 
> FILE SCOPE: new `Lift.lean` plus the shared library set. Durable anchors only outside specs/**. Cross-set collisions left to the admission gate: 744, 410. Logical edges on T4 and T5.
> 
> NOT COSTABLE, and why: statement fixed by T4/T5. Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Sections C, D and H6.

**Action required**: filed by this task's Phase 4 (`state-write.sh`, then `manage-topics.sh set`),
in Kahn position 6 of 6.

## Stage 0 -- described, not moved

The following are the user's to rule on (`specs/ROADMAP.md` Stage 0: "no agent may transition
these"). This file DESCRIBES each with its `state.json` status as read this round (Section 0.4) and
transitions, edits, or re-scopes none of them; no filed record carries an edge to any of them.

- **712** (`blocked`, deps `[703, 710]`, no `file_scope`) — the `[BLOCKED]` marker correction: the
  only `[BLOCKED]` task with no `blockers` entry; the ROADMAP's ruling is to close it as a
  refutation record after verifying the library theorem is 712's statement. Not moved here.
- **713** (`hold`, deps `[]`) — the CTL-like fragment record, held by ruling (2026-10-03): its
  ARGUED 2EXPTIME lower bound is a citable sanity ceiling with no consumer. The re-ruling on its
  value is the user's. Not moved here, and — guardrail (c) — no record above uses the ceiling as an
  upper-bound source; it rules proposals out only.
- **The held 2EXPTIME ceiling** itself — a ruling, not a task; every count in Sections A-D and H
  (`B`, `L`, `sizeBound`, `objBound`) is a count of cells or states, never a running time, so no
  record approaches it.
- **734** (`partial`, deps `[733]`, `file_scope` `scripts/check-evidence-probes.sh`,
  `mosaic-stab-saturated.lean`, `specs/literature-index.json`) — route R2 (mosaics), `[PARTIAL]` by
  ruling and NOT a fallback route (R2 is a consumer of R1). Its collision with T1/T2 on the probe
  gate script is an admission-gate matter; it is not moved, and no edge is added.
- **709** (`not_started`, deps `[703, 710, 719]`) — the F4 periodicity re-ruling: any surviving
  statement must name its restricted fragment and say why `not_finite_width_fmp` does not refute
  it. Not moved here.
- **716 / 714** (`not_started`, the sliced-certificate sub-front) — untouched: their `file_scope`
  (`PlusSlicedCertificate/{Live,Check,Stable,Examples}.lean`) is disjoint from every record above,
  and no fourth certificate class is proposed (both halves of that obstruction are landed under
  `PlusSlicedCertificate/Limits/`).

Should T2 return a Hit-level negative, the consequent decision on T5 and T6 joins this list as a
Stage 0 ruling (Section B); T2's own record says so in its description.

## State-write disclosure

Finalized in Phase 5. This task's implementation round wrote: this specification; six new `active_projects` rows in
`specs/state.json` (tasks 758-763 = T1-T6, through `state-write.sh` with `--regen-todo`, then
`manage-topics.sh set`, `next_project_number` 758 → 764); `specs/TODO.md` by regeneration only (never hand-edited); the Stage 1 section of
`specs/ROADMAP.md` (hand-authored, since `roadmap-integration.sh --regenerate` is inoperative on the
Stage layout); and, under `specs/757_lplus_decidability_successor_task_set/`, the plan's phase
markers and checkboxes, the phase handoffs, `successor-records.json`, `issues.jsonl`, the summary,
`.return-meta.json` and `.orchestrator-handoff.json`.

It does NOT write: any `FormalSystem/` file, any `docs/` file, any `scripts/` file, any `Tests/`
file, any typst file, any probe file — every such edit is a Section H record's own; and it neither
transitions nor edits tasks 712, 713, 734, 709, 716, 714 or any other existing task.

`validate-state.sh specs/state.json` after the sixth write: **exit 0, `STATE VALIDATION PASSED WITH
WARNINGS`, 0 failed**. `file_scope` WARN lines, all pre-existing in kind: Check 8 — "Coarse
file_scope declaration: project_number 177, entry `FormalSystem/Metalogic/Decidability/` overlaps 17
distinct non-terminal task(s)", the list now including 758-763 (177's whole-directory root is the
coarse declaration 751 remediates, not anything these rows declare); Check 9 — PASS, no duplicate
entries; the standing "file_scope visibility: 22 missing-key" list, none of them a row written here.
No mutex refusal occurred; no retry was needed. The protected rows 712, 713, 734, 709, 716, 714 were
diffed before and after filing and are byte-identical.

The defensive `git-snapshot.sh --no-revert 757` before Phase 4 exited 1 after printing only its mode
line (the working tree carried other sessions' dirty `specs/**` files outside this task's
`file_scope`); the tree was not modified and the filing proceeded without it — recorded in
`issues.jsonl`.

## Trace: ROADMAP changes to specification sections

| ROADMAP change (Stage 1, 2026-10-10) | Specification anchor |
|---|---|
| Header "last edited" date | this file (Phase 5) |
| `## Next batches`: `749` line → `758,759 --hard` | Sections A, B; H1, H2; Section 0.3 (cost bases) |
| `## Next batches`: `750` line → `760,761 --hard --lit` and `762,763 --hard --lit` | Sections A, C, B, D; H3-H6; `--lit` per Section B (HWZ 2000 / GKWZ 2003 indexed, orientation only) |
| Stage 1 lead paragraph: (C)'s bound half on model A, (W)'s frame scheme, pointer to this file | Section 0.1 reading, 0.2 rows 5 and 11 |
| Bullet **758** | Section A (probe statements, verdict semantics); H1 |
| Bullet **759**, "highest-information probe", "Stage 0 ruling, not an agent transition" | Section B; H2; "Stage 0 -- described, not moved" (last paragraph) |
| Bullet **760** (both counters, exhibited `B`, count sentence) | Section A; H3; Section 0.5 (`(c, n)` sharpening) |
| Bullet **761** (`box`/`stab` acceptance clause, no standalone (S) record) | Section C; H4; Decision D1 |
| Bullet **762** | Section B; H5; Decision D6 |
| Bullet **763** (the AIM stated here and nowhere earlier) | Section D; H6 |
| Shared-set / cross-set collision paragraph | Section H preamble ("Edges are typed"); Section 0.4 (744, 734, 410); Decision D5 |
| Named risks: "Hit-level completeness fails" row names **759** | Section B; H2 |
| Untouched: `720`, `716,714`, `712` lines; Stage 0 section; Guardrails; Stages 2-4 | "Stage 0 -- described, not moved"; State-write disclosure |

Every ROADMAP hunk above is confined to the header line and the `## Next batches` / `## Stage 1`
sections; the Stage 0 bullets, the `712`/`713`/`734`/`709` sentences and the `716, 714` bullet are
byte-identical to the pre-edit file.
