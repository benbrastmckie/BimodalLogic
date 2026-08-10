> **SUPERSEDED** (2026-08-10): written against the maximal-history countermodel family, superseded by the full TOTAL-history set `H_F`; the per-class obligation is now Seriality + Limit + Spherical + biconditional Compositionality, not "Limit Nullity" alone. The Discrete->Dense->Base->Dedekind staging and the `bundleFlowFrame` lead-frame strategy survive. See specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/01_team-research.md (Deliverable 4) for what survives, and specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/02_logical-consequence-discrepancy-audit.md (Findings 1b/4) for what report 01 itself got superseded on.

# Research Report: Completeness over Maximal-History Semantics (Rebase)

- **Task**: 415 — completeness_over_maximal_history_semantics
- **Session**: sess_1785280411_23b0e6_415
- **Agent**: lean-research-hard-agent (H2+H3+H4 active; H5 not activated)
- **Date**: 2026-07-28
- **Reference tier**: Tier 1 (literature-backed: `PossibleWorlds/Comments/fix.md` B1/C2; `possible_worlds.tex`)
- **Status of dependency 414**: NOT LANDED — `valid` at `FormalSystem/Semantics/Validity.lean:79`
  still carries the `Omega : Set (WorldHistory F)` + `ShiftClosed Omega` parameters (verified by
  read, 2026-07-28). Interface coordination with the parallel research-414 agent is COMPLETE:
  414's settled, machine-verified target shapes (their report, Finding 3:
  `specs/414_refactor_semantics_to_maximal_history_validity/reports/01_maximal-history-validity-refactor.md`)
  are: a bespoke `instance : Preorder (WorldHistory F)` (extension order; agreement clause
  quantifies over an arbitrary proof of the larger domain; Preorder only, no antisymmetry);
  maximality is **Mathlib's `IsMax` used directly** (no repo wrapper — write `IsMax τ`, never
  `τ.IsMaximal`); and the helpers `exists_maximal_extension` (via `zorn_le_nonempty_Ici₀`),
  `isMax_timeShift`, and `isMax_of_total : (∀ t, τ.domain t) → IsMax τ`. All signatures below
  use this settled interface.

## Executive Summary

1. **The singleton-Omega device the task targets (`Transfer.lean:603-638`) is DEAD CODE.** Its
   only consumer, `z_interval_countermodel` (`Transfer.lean:661`), has zero references anywhere
   in the live tree (repo-wide grep). The LIVE discrete completeness path is
   `countermodel_discrete_reynolds_v2` (`WeakCanonical/IntegerModel/ReynoldsBridge.lean:739`),
   which uses the multi-family frame `multiFamTaskFrame` — and that frame's Omega
   (`multiFamOmega`) is already, up to a lemma not yet in the tree, **exactly the full
   maximal-history set of its frame**. The discrete rebase is therefore a localized change
   (one new characterization lemma + the box case + existential packaging), not a rebuild.
2. **The Dense/Dedekind path genuinely requires a rebuild of its frame layer.** The parametric
   canonical frame (`ParametricCanonicalTaskFrame`, WorldState = all MCS pairs, TaskRel =
   `ExistsTask`) has junk maximal histories, and box over ALL maximal histories is refutable
   against the truth lemma there (counterexample argument in Findings §4). The fix is a
   deterministic "flow frame" re-host: WorldState = bundle-family × time, deterministic clock
   TaskRel — the exact shape `multiFamTaskFrame` already has on ℤ, generalized to any carrier D.
3. **The fix.md phrase "deterministic frames, whose maximal histories form a single shift
   class" is true only per family/orbit** (adversarially checked, Findings §3). The live
   countermodels need one shift class per box-equivalent family; this is fully compatible with
   the internalized statements, whose requirement is "full maximal-history set = countermodel
   family", not "singleton shift class".
4. **Headline statements survive textually.** `completeness_discrete/dense/…` keep their exact
   statement text (`ValidDiscrete φ → Derivable FrameClass.Discrete [] φ`, etc.); only the
   definitions underneath (`TruthAt`, `Valid*`) change (that is 414). 415's work is entirely in
   the countermodel lemmas that feed them, plus deleting the dead singleton-Omega block.
5. **Sorry inventory: exactly one live `sorry`** in the whole non-Boneyard tree —
   `WeakCanonical/Transfer.lean:1242` (`countermodel_discrete`, the Base-MCS discrete branch),
   reaching only `BXCanonical.completeness` (Base). It predates this task, persists through the
   rebase (restated, still sorried), and is task-169 territory, not 415's to close.

## Findings

### 0. H3 Tier-1 lemma-level mapping table

Note on sources: `fix.md` is the decision authority for B1/C2 (delegation directive). The
`possible_worlds.tex` on disk (2253 lines) is a shorter build than the one fix.md's line
numbers cite (e.g. cor:tm-completeness "line 3289" does not exist in the disk version); the
disk tex confirms the surrounding content (`H^\star_F` complete histories at its line 865, the
Complete/CO constraint at 1094-1116) but fix.md's own text is used as the citation anchor.

| Source (fix.md/tex location) | Informal statement | Target Lean name | Lean signature | Status |
|---|---|---|---|---|
| fix.md B1 Decision (line 77) | `H_F` restricted to maximal histories; `□` ranges over them | Mathlib `IsMax` over a new `Preorder (WorldHistory F)` instance (414-settled; no repo wrapper) | `IsMax (τ : WorldHistory F) : Prop` | to-define (task-414 scope; prototype verified) |
| fix.md B1 line 69/77 ("Zorn extension … re-verified") | Every history extends to a maximal one | `exists_maximal_extension` | `(τ : WorldHistory F) : ∃ σ, τ ≤ σ ∧ IsMax σ` (via `zorn_le_nonempty_Ici₀`; `IsMax`/Zorn lemmas verified in Mathlib: `Mathlib.Order.Defs.Unbundled`, `Mathlib.Order.Zorn`) | to-prove (task-414 scope; prototype verified) |
| fix.md B1 line 69/77 ("maximality is preserved by time-shift") | Shift-preservation of maximality | `isMax_timeShift` | `(h : IsMax σ) (Δ : D) : IsMax (timeShift σ Δ)` | to-prove (task-414 scope; prototype verified) |
| fix.md line 82 (completeness work item, "definitional, not a bridge") | Per-class weak completeness with maximal-history countermodels outright | `completeness_discrete` | `ValidDiscrete φ → Derivable FrameClass.Discrete [] φ` (text unchanged; `ValidDiscrete` Omega-free) | exists (green) → to-restate |
| fix.md C2 Decision | Dense weak terminus | `completeness_dense` | `ValidDense φ → Derivable FrameClass.Dense [] φ` | exists (green) → to-restate (frame re-host) |
| fix.md C2 Issue ("base `completeness` carries sorryAx") | Base weak terminus | `completeness` | `valid φ → Derivable FrameClass.Base [] φ` | exists (sorryAx) → to-restate (sorry persists) |
| fix.md C2 Issue ("engine-conditional") | Dedekind weak/consequence terminus | `completeness_dedekind_of_engine`, `consequence_completeness_dedekind_of_engine` | `StrongCompleteness.lean:274,308` (engine hypothesis retained) | exists (conditional) → to-restate |
| fix.md line 82 ("deterministic frames, … single shift class, replace the former singleton-Ω device") | Maximal-history characterization of deterministic flow frames | `multiFam_isMax_iff` (new) | `[Nonempty FamIdx] → (IsMax σ ↔ ∃ f w₀, σ = multiFamHistory f w₀)` | to-prove (415 core) — "single shift class" holds per family, see §3; ← direction is 414's `isMax_of_total` (histories are full-domain), only → is new work |
| fix.md C1 Issue (witness `Transfer.lean:603–638`) | Singleton-Ω countermodel device | `zIntervalTaskFrame`/`zIntervalOmega`/`z_interval_countermodel` | `Transfer.lean:568-687` | exists-DEAD → to-delete/archive (415) |
| fix.md B1 Consequences / tex disk line 865 | Segments vs worlds (`H^\star_F`) presentation | (no Lean artifact needed by 415) | — | n/a (paper-side) |

### 1. The singleton-Omega device (`WeakCanonical/Transfer.lean:603-638`) — Q1

What is there (verbatim structure, lines 568-687):

- `zIntervalTaskFrame : TaskFrame ℤ` (line 568) — `WorldState := Unit`, `TaskRel := fun _ _ _ => True`.
- `zIntervalHistory : WorldHistory zIntervalTaskFrame` (line 580) — `domain := fun _ => True`,
  `states := fun _ _ => ()`.
- `zIntervalHistory_shift_eq` (line 591) — every time-shift of it is propositionally equal to it
  (proved by `change WorldHistory.mk … ; congr 1`).
- `zIntervalOmega : Set (WorldHistory zIntervalTaskFrame) := {zIntervalHistory}` (line 599),
  `zIntervalOmega_shiftClosed` (line 602), `zIntervalHistory_mem_omega` (line 608).
- `zIntervalBox_transparent` (line 616):
  `TruthAt TM zIntervalOmega zIntervalHistory t (.box ψ) ↔ TruthAt TM zIntervalOmega zIntervalHistory t ψ`
  — box transparency bought by the singleton Omega.
- Consumer: `z_interval_countermodel` (line 661), which packages
  `∃ D … F TM Omega (_ : ShiftClosed Omega) τ (_ : τ ∈ Omega) t, ¬TruthAt TM Omega τ t φ` with
  `Omega := zIntervalOmega`.

**What it currently buys: nothing on any live path.** Repo-wide grep (excluding `Boneyard/`)
finds no reference to `z_interval_countermodel`, `zIntervalTaskFrame`, `zIntervalOmega`, or
`zIntervalBox_transparent` outside `Transfer.lean` itself, and no reference inside
`Transfer.lean` after line 687. `completeness_discrete` routes through
`countermodel_discrete_reynolds_v2` instead (confirmed at `BXCanonical/Completeness.lean:360-363`
and by the `Transfer.lean:1206-1214` docstring). fix.md C1's citation of 603-638 as the concrete
witness that "the Lean completeness proofs rest on" singleton-Ω countermodels is stale as a
description of the live call graph — though its underlying point stands: the live statements are
still Omega-relativized in *form*.

**What breaks when Omega is removed: nothing mathematical — the device becomes redundant, then
deletable.** An instructive fact: the maximal histories of `zIntervalTaskFrame` are themselves a
singleton (WorldState = Unit forces `states = fun _ _ => ()`; the frame is serial in every
duration, so every maximal history is total; total histories are unique up to
funext/propext-equality). So even this frame's countermodel would survive internalization. But
since nothing consumes it, the right move under 415 is deletion (or Boneyard archival) of
`Transfer.lean:568-687`, alongside the restatement of `countermodel_discrete`
(`Transfer.lean:1225`, the sorried Base-branch obligation, which must be restated Omega-free but
remains sorried — see §6).

### 2. The live discrete pipeline is already internalization-shaped — Q1/Q5

`countermodel_discrete_reynolds_v2` (`ReynoldsBridge.lean:739`) constructs:

- `multiFamTaskFrame FamIdx : TaskFrame ℤ` (line 671): `WorldState := FamIdx × ℤ`,
  `TaskRel := fun p d q => p.1 = q.1 ∧ q.2 = p.2 + d` — **deterministic and serial**: from any
  state, exactly one d-successor, for every d.
- `multiFamHistory f w₀` (line 683): total history, `states t _ = (f, w₀ + t)`.
- `multiFamOmega FamIdx := Set.range (fun p => multiFamHistory p.1 p.2)` (line 694).
- `FamIdx := {N // SetMaximalConsistent N ∧ □nextTop ∈ N ∧ (∀ ψ, □ψ ∈ A ↔ □ψ ∈ N)}` (line 754)
  — the box-equivalent MCS witnesses; inhabited by `f₀ := A` (line 757).

**Claim (415's core new lemma, `multiFam_isMax_iff`): for `Nonempty FamIdx`, the maximal
histories of `multiFamTaskFrame FamIdx` are exactly `multiFamOmega`.** Proof sketch, checked
against the `WorldHistory` structure (`Semantics/WorldHistory.lean:75-104`); note 414 ships
`isMax_of_total`, which discharges the easy (⟸) direction in one line since `multiFamHistory`
has full domain — only the (⟹) direction below is new work:

- Any history σ with `t₀ ∈ σ.domain`, `σ.states t₀ = (f, z₀)`: for `t ∈ σ.domain` with
  `t₀ ≤ t`, `respects_task t₀ t` forces `σ.states t = (f, z₀ + (t - t₀))`; for `t < t₀`,
  `respects_task t t₀` forces the same via the converse equation. So every nonempty history is
  a restriction of `multiFamHistory f (z₀ - t₀)`.
- If `σ.domain` is not all of ℤ, that total history properly extends σ (extension order:
  domain-inclusion + state agreement), so σ is not maximal. If `σ.domain` is full, σ *is*
  `multiFamHistory f (z₀ - t₀)` up to funext/propext (domain Props) + proof-irrelevance
  (states' domain-proof argument) — the exact equality bookkeeping already done by the
  `change WorldHistory.mk …; congr 1` pattern at `multiFamHistory_shift_eq`
  (`ReynoldsBridge.lean:698`).
- Conversely each `multiFamHistory f w₀` is maximal: its domain is full, so any extension has
  the same (full) domain and agreeing states, hence is ≤ it back (preorder maximality), or
  equal (after the same propext bookkeeping).
- **Edge case (adversarial catch)**: the empty-domain history. With `Nonempty FamIdx` it is
  properly extended by any `multiFamHistory`, hence not maximal. With FamIdx empty it would be
  vacuously maximal and the characterization fails — so the lemma must carry
  `[Nonempty FamIdx]` (satisfied on the live path by `f₀`).

Consequences for the rebase of `ReynoldsBridge.lean`:

- The truth-correspondence induction (line 804 ff.) changes **only in the box case**
  (lines 840-940): forward direction currently instantiates `h_all` at
  `multiFamHistory f' (z - t) ∈ multiFamOmega`; post-414 it instantiates at
  `(multiFam_isMax_iff …).mpr ⟨f', z - t, rfl⟩`. Reverse direction currently destructures
  `σ ∈ multiFamOmega` as `⟨⟨f', w₀'⟩, rfl⟩`; post-414 it destructures
  `(multiFam_isMax_iff …).mp h_max`. The atom/bot/imp/untl/snce cases mention Omega only as
  a passed-through parameter that disappears.
- The existential packaging (lines 744-750, 810-815) drops
  `Omega, ShiftClosed Omega, τ ∈ Omega` in favor of `IsMax τ`.
- Everything below the frame layer — `mkSigFrom`, `limitdom_is_good`, `getZ`, `KEquiv`,
  `truth_transfer`, `table_correctness`, the whole Kamp/Reynolds/EF-game cone — is
  `TemporalTruth`-side and Omega-free already. **Preserved unchanged.**

### 3. "Deterministic frames' maximal histories form a single shift class" — Q2, adversarial verdict

**As stated: not unconditionally true. Revised statement: true per orbit.**

- In a deterministic+serial frame, every maximal history is total and is the flow line of its
  state at time 0; time-shifting a flow line moves its base point along the same orbit
  (`multiFamHistory_shift_eq`: shift of `(f, w₀)` is `(f, w₀ + Δ)`). Maximal histories modulo
  shift ≅ orbits of the induced D-action on WorldState.
- Hence: single shift class ⟺ the action is transitive on WorldState. `zIntervalTaskFrame`
  (Unit): trivially transitive — single class (indeed a single history).
  `multiFamTaskFrame FamIdx` with `|FamIdx| ≥ 2`: **one shift class per family** — not a single
  class. And multiple families are *load-bearing*: `¬□ψ` needs a witness family where ψ fails;
  a single shift class cannot supply it unless ψ already fails in the root family's own
  chronicle (this is exactly the "single-Z-interval box semantics mismatch" that
  `countermodel_discrete_reynolds_v2`'s docstring records as the reason the multi-family
  approach exists).
- No seriality side condition is needed for the frames 415 actually builds, because they are
  serial by construction (clock TaskRel total in every duration). For *arbitrary* deterministic
  frames, maximal ≠ total (genuinely terminating frames retain bounded maximal histories — and
  fix.md B1's Decision text embraces this: "maximality ≠ totality").
- **Impact on the task: none negative.** The internalized statements require "the frame's FULL
  maximal-history set is the countermodel family". The flow frames deliver that with the family
  set as the index; the fix.md phrase should be read as describing each family's orbit.

### 4. Dense/Dedekind: the parametric canonical frame cannot survive Omega removal — Q5

Current dense pipeline: `countermodel_dense_enriched` (`BXCanonical/Completeness.lean:133-162`)
builds the countermodel on `ParametricCanonicalTaskFrame Rat`
(`Algebraic/ParametricCanonical.lean:207`: `WorldState := ParametricCanonicalWorldState fc` =
ALL MCS pairs; `TaskRel := ParametricCanonicalTaskRel` via `ExistsTask` — **non-deterministic**),
with `Omega := ShiftClosedParametricCanonicalOmega bfmcs`
(`Algebraic/ParametricHistory.lean:124`: all time-shifts of `parametricToHistory fam` for
`fam ∈ B.families`), and the truth lemma
`fully_restricted_parametric_completeness_from_neg_membership`
(`Algebraic/RestrictedParametricTruthLemma.lean:417`) whose box case (lines 354-376) quantifies
over that Omega using `B.modal_forward` + `parametric_box_persistent`.

**Why "keep the frame, prove its maximal histories = Omega" is impossible** (this kills the
cheapest imaginable rebase): every MCS is a world state of the parametric frame, whether or not
it belongs to any bundle family. Take any MCS `M'` with `p ∈ M'` while `□¬p ∈ fam.mcs t` for
the root family. The singleton history `{t} ↦ M'` extends (Zorn, delivered by 414) to SOME
maximal history σ' of the frame passing through `M'` at `t`. Under Omega-free semantics,
`TruthAt M τ t (□¬p)` quantifies over σ' too, and `¬p` is false there (atom clause + valuation
at `M'`), so `□¬p` would be semantically false while a member of the MCS — the truth lemma is
refuted on this frame, not merely unproven. The frame layer must change.

**The fix — deterministic flow re-host (the "lead construction")**, generalizing
`multiFamTaskFrame` from ℤ to any carrier D:

```lean
-- new, e.g. Algebraic/FlowFrame.lean; names provisional
def bundleFlowFrame (B : BFMCS (fc := fc) D) : TaskFrame D where
  WorldState := {fam : FMCS (fc := fc) D // fam ∈ B.families} × D
  TaskRel := fun p d q => p.1 = q.1 ∧ q.2 = p.2 + d
  -- nullity_identity / forward_comp / converse: same one-line algebra as multiFamTaskFrame

def bundleFlowHistory (fam : {fam // fam ∈ B.families}) (w₀ : D) :
    WorldHistory (bundleFlowFrame B)   -- domain := fun _ => True, states t _ := (fam, w₀ + t)

def bundleFlowModel (B : BFMCS (fc := fc) D) : TaskModel (bundleFlowFrame B) where
  valuation := fun w p => Formula.atom p ∈ w.1.val.mcs w.2

theorem bundleFlow_isMax_iff [Nonempty {fam // fam ∈ B.families}]
    (σ : WorldHistory (bundleFlowFrame B)) :
    IsMax σ ↔ ∃ fam w₀, σ = bundleFlowHistory fam w₀

theorem bundleFlow_truth_lemma (h_rtc : B.RestrictedTemporallyCoherent root)
    (h_buc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_fuc : B.RestrictedForwardUntilSinceCoherent root)
    (φ : Formula) (h_sub : φ ∈ subformulaClosure root) (fam) (hfam) (w₀ t : D) :
    TruthAt (bundleFlowModel B) (bundleFlowHistory ⟨fam, hfam⟩ w₀) t φ ↔ φ ∈ fam.mcs (w₀ + t)
```

The re-hosted truth lemma's proof transcribes `fully_restricted_parametric_shifted_truth_lemma`
(`RestrictedParametricTruthLemma.lean:286`) with `(fam, w₀)` replacing
`timeShift (parametricToHistory fam) delta` (the flow history at offset w₀ IS the shifted
history — the separate "shifted" formulation dissolves):

- atom case: valuation is definitionally MCS membership — same as now.
- imp/bot/untl/snce: use only FMCS temporal coherence (`forward_G`, restricted tc/buc/fuc) —
  frame-independent, **preserved verbatim**.
- box case: `parametric_box_persistent` (box persists across times within a family) +
  `B.modal_forward`/`B.modal_backward` (`Bundle/BFMCS.lean:91` ff.) — with Omega-membership
  destructuring replaced by `bundleFlow_isMax_iff`, exactly as in §2.

Then `countermodel_dense_enriched` re-packages over `bundleFlowFrame` at `D := Rat` using the
**unchanged** chronicle suppliers `Chronicle.cantorBfmcsDense`, `rootedCantorFmcsDense`,
`cantor_bfmcs_dense_restricted_tc/buc/fuc` (all Bundle/Chronicle-level, Omega-free). The
Dedekind carrier probe (`BXCanonical/CompletenessDedekind.lean:55-100`) re-points at the flow
machinery at `D := ℝ`; `real_lub_of_bddAbove` (line 127) is untouched.

### 5. Target signatures for the restated headline theorems — Q3

No transfer or realization lemmas appear anywhere below. Statement TEXT of the headliners is
unchanged; the change is inside `Valid*`/`TruthAt` (414) and inside the countermodel lemmas
(415). Using 414's settled, prototype-verified interface (Mathlib `IsMax` over the new
`Preorder (WorldHistory F)` instance):

```lean
-- Semantics (task-414, restated here as the interface 415 builds against)
def TruthAt (M : TaskModel F) (τ : WorldHistory F) (t : D) : Formula → Prop
  | .box φ => ∀ σ : WorldHistory F, IsMax σ → TruthAt M σ t φ
  | …  -- other clauses unchanged modulo dropped Omega
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F), IsMax τ → ∀ t : D,
    TruthAt M τ t φ
-- ValidDense / ValidDiscrete / ValidDedekind(Dense): same binder lists as today
-- (Validity.lean:169,187,231,255) with (Omega, ShiftClosed, τ ∈ Omega) ↦ (IsMax τ)

-- 415 headliners (statement text unchanged)
theorem completeness_discrete (φ : Formula) :
    ValidDiscrete φ → Derivable FrameClass.Discrete [] φ
theorem completeness_dense (φ : Formula) :
    ValidDense φ → Derivable FrameClass.Dense [] φ
theorem completeness (φ : Formula) :
    valid φ → Derivable FrameClass.Base [] φ            -- discrete branch stays sorried
theorem completeness_dedekind_of_engine
    (engine : ∀ ψ, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ)
    (φ : Formula) : ValidDedekindDense φ → Derivable FrameClass.Dedekind [] φ
theorem consequence_completeness_dedekind_of_engine
    (engine : ∀ ψ, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ)
    (Γ : Context) (φ : Formula) :
    SemanticConsequenceDedekindDense Γ φ → Derivable FrameClass.Dedekind Γ φ

-- 415 countermodel lemmas (internalized existentials)
theorem countermodel_discrete_reynolds_v2 (A) (h_mcs) (φ) (h_neg_in) (h_box_discrete) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (_ : SuccOrder D) (_ : PredOrder D)
      (_ : IsSuccArchimedean D) (_ : IsPredArchimedean D)
      (F : TaskFrame D) (TM : TaskModel F) (τ : WorldHistory F),
      IsMax τ ∧ ∃ t : D, ¬TruthAt TM τ t φ
theorem countermodel_dense_enriched (A) (h_mcs) (φ) (h_neg_in) (h_box_dense) :
    ∃ (F : TaskFrame Rat) (TM : TaskModel F) (τ : WorldHistory F),
      IsMax τ ∧ ∃ t : Rat, ¬TruthAt TM τ t φ
theorem countermodel_discrete (A) (h_mcs : SetMaximalConsistent (fc := .Base) A) (φ) … :
    ∃ (D : Type) …instances… (F : TaskFrame D) (TM : TaskModel F) (τ : WorldHistory F),
      IsMax τ ∧ ∃ t : D, ¬TruthAt TM τ t φ         -- restated, still `sorry`
```

`SemanticConsequenceDedekindDense` and `semantic_deduction_dedekind_dense`
(`StrongCompleteness.lean`) restate with the same substitution; `soundness_dedekind_consequence`
(line 292) then consumes 414's propagated `soundness_dedekind`. The three-way case-split bodies
of `completeness`/`completeness_dense`/`completeness_discrete`
(`BXCanonical/Completeness.lean:196-366`) are proof-theory + MCS reasoning
(`neg_consistent_of_not_derivable`, `set_lindenbaum`, `mcs_mixed_case_absurd`, the ten-step
Discrete derivation of `U(⊤,⊥)`) — **all preserved verbatim**; only the
`obtain ⟨…Omega…⟩ … exact h_not_true (h_valid …)` packaging lines change shape.

### 6. Blast radius, ordering, and sorry inventory — Q4/Q6

**Sorry inventory (strict token grep, non-Boneyard, whole `FormalSystem/`):** exactly one live
`sorry` — `WeakCanonical/Transfer.lean:1242`, terminal sorry of `countermodel_discrete`
(Base-MCS discrete branch). Corroborated by `Transfer.lean:23` ("the repository's sole live
sorry") and by the `#print axioms` audit in `BXCanonical/Completeness.lean:371-409`
(`completeness_dense`/`completeness_discrete`: axioms exactly `propext, Classical.choice,
Quot.sound`; `completeness`: + `sorryAx` from this one source). The Dedekind results are
sorry-free but engine-conditional. 415 restates the sorried lemma Omega-free without closing it
(closure is the 169 programme; two candidate routes documented at `Transfer.lean:1234-1241`).

**Files 415 must touch** (Omega-mention counts, excluding what 414 owns —
`Semantics/*`, `Soundness.lean`, `SoundnessLemmas/`):

| File | Role in rebase |
|---|---|
| `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | box case + packaging + `multiFam_isMax_iff` (Discrete) |
| `Metalogic/Algebraic/ParametricHistory.lean` | superseded by flow-history module (Dense/Dedekind) |
| `Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` | re-hosted onto `bundleFlowFrame` |
| `Metalogic/Algebraic/ParametricTruthLemma.lean`, `ParametricCompleteness.lean` | model/valuation defs re-pointed or superseded |
| `Metalogic/BXCanonical/Completeness.lean` | countermodel packaging in 3 theorems + docstrings |
| `Metalogic/BXCanonical/CompletenessDedekind.lean` | carrier probes re-pointed at flow machinery at ℝ |
| `Metalogic/StrongCompleteness.lean` | consequence definitions + engine statements restated |
| `Metalogic/WeakCanonical/Transfer.lean` | delete dead 568-687; restate sorried 1225-1242 |
| `Metalogic.lean` | headline docstring (30 ff.) |

(28 non-Boneyard files under `Metalogic/`+`Semantics/`+`Theorems/` mention Omega/ShiftClosed in
total; the remainder are 414's semantics/soundness propagation or incidental docstrings.)

**Ordering — Discrete → Dense → Base → Dedekind: valid, but only partially forced.** Forced
dependencies: Dense < Base (Base's dense branch consumes the re-hosted
`countermodel_dense_enriched`) and Dense < Dedekind (the engine target and carrier probes
consume the re-hosted parametric/flow machinery at ℝ; note task 408 is concurrently
`[IMPLEMENTING]` against `StrongCompleteness.lean`/`CompletenessDedekind.lean` — territory
coordination needed). Discrete is logically independent of all three; putting it first is the
right pragmatic call (smallest diff, validates the flow-frame + characterization pattern that
Dense then generalizes), not a logical requirement. Base and Dedekind are mutually independent.
Both Dense and Discrete are green under the old semantics (fix.md C2, re-verified via the axiom
audit); the delegation's "Discrete first (currently green)" parenthetical applies to both.
Task-name note: 169/170's state.json *names* ("complete_frame/complete_dense extension") are
stale repurposed stubs; their *descriptions* confirm 169 = Base weak green, 170 = Dense weak
green, matching fix.md C2.

### 7. What survives vs what is rebuilt — Q5 (preserved-assets ledger)

**Preserved unchanged (the mathematical bulk):**
- All MCS/proof-theory: `set_lindenbaum`, `neg_consistent_of_not_derivable`,
  `SetMaximalConsistent.*`, `theorem_in_mcs`, deduction/exchange machinery, the in-proof
  Discrete/Dense axiom derivations, `Chronicle.mcs_mixed_case_absurd`.
- All Bundle infrastructure: `FMCS`, `BFMCS` (`modal_forward`/`modal_backward`), all
  `TemporalCoherence` properties, `parametric_box_persistent`.
- All chronicle suppliers: `Chronicle.cantorBfmcsDense`, `rootedCantorFmcsDense`,
  `cantor_bfmcs_dense_restricted_tc/buc/fuc` (Dense); the entire `TemporalTruth`-side Reynolds
  cone — `limitdom_is_good`, Z-interval extraction, `KEquiv`, `truth_transfer`,
  `table_correctness`, EF-games, Kamp/Prior expressiveness (Discrete).
- `multiFamTaskFrame`/`multiFamHistory`/`multiFamHistory_shift_eq` themselves (the frame is
  kept; only its Omega wrapper and the box case go).
- Statement text of every headline theorem; `real_lub_of_bddAbove`.

**Rebuilt/new:**
- NEW: maximality characterization lemmas (`multiFam_isMax_iff`, `bundleFlow_isMax_iff`
  — or one generic flow-frame lemma both instantiate), with the `Nonempty` side condition and
  the funext/propext/proof-irrelevance equality bookkeeping (pattern precedent:
  `multiFamHistory_shift_eq`, `zIntervalHistory_shift_eq`).
- NEW: `bundleFlowFrame`/`bundleFlowHistory`/`bundleFlowModel` (D-generic).
- REWRITTEN: `RestrictedParametricTruthLemma` induction re-hosted (box + atom cases change
  substantively; temporal cases re-typed); countermodel packaging in `Completeness.lean`,
  `ReynoldsBridge.lean`; consequence layer in `StrongCompleteness.lean`.
- DELETED: `Transfer.lean:568-687` (dead singleton-Omega device); `ParametricHistory.lean`'s
  Omega definitions; possibly `ParametricCanonicalTaskFrame` itself if nothing else consumes it
  after the re-host (check at plan time).

## Adversarial Self-Verification

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| 414 not landed; `valid` still Omega-relativized | `Validity.lean:79-84` read today | Direct file read (bounded) | High |
| Sole live sorry = `Transfer.lean:1242` | Strict token grep over non-Boneyard `FormalSystem/`; corroborating `#print axioms` audit text at `Completeness.lean:371-409` | grep + in-repo axiom-audit cross-check (not re-run through `lake`) | High |
| Singleton-Omega device (`Transfer.lean:568-687`) is dead code | Repo-wide grep for all four identifiers: zero consumers | grep (declaration + reference scan) | High |
| `multiFamOmega` = full maximal-history set (given `Nonempty FamIdx`) | Proof sketch from `WorldHistory` structure fields (`WorldHistory.lean:75-104`) + `multiFamTaskFrame` TaskRel; empty-history edge case identified and fenced | Mathematical argument against read definitions; NOT yet Lean-checked | Medium-High (risk concentrated in propext/HEq equality bookkeeping, which has in-repo precedent) |
| "Deterministic ⇒ single shift class" needs per-orbit qualification | `multiFamTaskFrame` with ≥2 families is deterministic with ≥2 shift classes; multiplicity is load-bearing for `¬□ψ` witnesses (v2 docstring, `ReynoldsBridge.lean:720-737`) | Counterexample construction + docstring cross-check | High |
| Parametric canonical frame has junk maximal histories refuting an Omega-free truth lemma | WorldState = ALL MCS pairs (`ParametricCanonical.lean:207-210`); singleton history through a `p`-containing MCS + Zorn extension refutes `□¬p` | Counterexample argument against read definitions (uses 414's Zorn lemma as premise) | High |
| Temporal/coherence layers are frame-independent and carry over | Box case is the only Omega-consuming case in `RestrictedParametricTruthLemma` (grep of Omega mentions lines 127-427: all in signatures/box case); reynolds cone is `TemporalTruth`-side | grep + bounded reads of both truth-lemma box cases | High |
| Ordering only partially forced (Dense<Base, Dense<Dedekind; Discrete free) | Call graph: `completeness` dense branch → `countermodel_dense_enriched`; Dedekind probe → parametric machinery at ℝ | Read of `Completeness.lean:219-233`, `CompletenessDedekind.lean:82-98` | High |
| Mathlib support exists: `Maximal` (`Mathlib.Order.Defs.Unbundled`), `zorn_le_nonempty` (`Mathlib.Order.Zorn`) | loogle results with full signatures | `lean_loogle` verified hits | High |
| 169=Base, 170=Dense despite stale names | state.json descriptions read directly | jq read | High |

### Contradiction Log

1. **fix.md C1 ("the Lean completeness proofs rest on countermodels at `Transfer.lean:603-638`")
   vs repo call graph (live discrete path uses `multiFamOmega`, and the 603-638 block is
   unreferenced).** Resolution per precedence (repo state, machine-checkable, wins over prose):
   the citation is stale as a call-graph claim; C1's *conclusion* (statements are
   Omega-relativized, completeness does not transfer to paper validity) remains correct — the
   live Omega is just multi-family rather than singleton. Downstream effect: 415's Discrete leg
   is substantially cheaper than fix.md's framing suggests.
2. **Delegation/fix.md gloss "169 (Base), 170 (Dense)" vs state.json names
   ("complete_frame/complete_dense extension").** Resolved by reading the descriptions: names
   are stale repurposed stubs; descriptions match the gloss. No unresolved contradictions
   remain.
3. **fix.md line 82 "single shift class" vs multi-family necessity.** Resolved as a
   qualification, not a contradiction (Findings §3): single class per family; the internalized
   requirement (full maximal-history set = countermodel family) is met either way.

### Recommendations modified after verification

- Initial working assumption "the Discrete rebase must replace the singleton-Omega device"
  was **revised** to "the singleton-Omega device is dead; delete it; the Discrete rebase
  targets the multiFam box case instead".
- The maximality characterization lemmas acquired an explicit `[Nonempty …]` hypothesis after
  the empty-history attack.
- The claim about deterministic frames was weakened to the per-orbit form before being relied
  on anywhere.

## Tactic Survey Results

Not applicable at research stage beyond precedent identification: the history-equality
obligations in the characterization lemmas should follow the in-repo
`change WorldHistory.mk _ _ _ _ = WorldHistory.mk _ _ _ _; congr 1` pattern
(`ReynoldsBridge.lean:698-705`, `Transfer.lean:591-596`), with `funext`/`propext` for domain
Props and `omega` for the ℤ index arithmetic. No new Mathlib tactic dependencies identified;
`lean_multi_attempt` deferred to implementation (no editable proof site exists pre-414).

## Literature Proof Structure (Tier 1)

Source: fix.md B1 (Decision + Presentation architecture, lines 77-82) and C2 (Decision,
line 143); tex on disk corroborates the `H^\star_F`/segment-vs-world presentation (disk
line 865) and CO/Complete constraint (disk lines 1094-1116).

| Step | fix.md content | Lean realization in 415 |
|---|---|---|
| 1 | Validity = truth at all maximal histories of all frames (B1 Option 1, decided) | 414's `valid`; 415 consumes it |
| 2 | Soundness survives verbatim (Zorn extension + shift-preservation) | 414's propagation; 415 relies on restated `soundness_*` for the guard theorems in `StrongCompleteness.lean` |
| 3 | Completeness re-proved per class with countermodels that are maximal-history models outright; "no realization/transfer lemmas in the final statements" | Headliners restated with unchanged text; countermodel existentials carry `IsMax τ` instead of `(Omega, ShiftClosed, τ ∈ Omega)`; the realization content is absorbed into `*_isMax_iff` characterization lemmas inside the constructions |
| 4 | "Deterministic frames … replace the former singleton-Ω device" | Flow frames (`multiFamTaskFrame` kept; `bundleFlowFrame` new); dead device deleted |
| 5 | Weak-only scoping (strong completeness provably false where non-compact) | Untouched: `StrongCompleteness.lean` module docs and engine architecture keep exactly this scoping |

## Recommended Phase Skeleton for the Planner (not a plan)

1. **Gate**: 414 lands (Preorder extension order, `IsMax` usage, Zorn, shift-preservation,
   `isMax_of_total`, refactored
   `TruthAt`/`Valid*`, Soundness propagated). Blocked until then; every 415 phase type-checks
   only post-414.
2. **Discrete**: generic flow-frame maximality characterization (`multiFam_isMax_iff`);
   `ReynoldsBridge.lean` box case + packaging; `completeness_discrete` green again.
3. **Dense**: `bundleFlowFrame`/history/model + `bundleFlow_isMax_iff`; re-host restricted
   truth lemma; `countermodel_dense_enriched`; `completeness_dense` green again.
4. **Base**: `completeness` restated (dense/mixed branches green, discrete branch restated +
   still sorried); delete `Transfer.lean:568-687`; update `Metalogic.lean` headline docs.
5. **Dedekind**: `StrongCompleteness.lean` consequence layer + engine statements;
   `CompletenessDedekind.lean` probes at ℝ over the flow machinery. Coordinate with in-flight
   task 408 (same files).

## Appendix: Key Locations

- `FormalSystem/Semantics/Validity.lean:79,169,187,231,255` — `valid`, `ValidDense`,
  `ValidDiscrete`, `ValidDedekind`, `ValidDedekindDense` (current, Omega-relativized)
- `FormalSystem/Semantics/Truth.lean:128-137` — `TruthAt` (box clause at 133)
- `FormalSystem/Semantics/WorldHistory.lean:75-104,246` — `WorldHistory`, `timeShift`
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:568-687` — dead singleton-Omega device;
  `:1225-1242` — sorried `countermodel_discrete` (sole live sorry)
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:671-750,840-940` —
  multiFam frame/Omega/countermodel, box case
- `FormalSystem/Metalogic/Algebraic/ParametricCanonical.lean:207` — non-deterministic canonical
  frame; `ParametricHistory.lean:68,110,124` — histories and Omegas;
  `RestrictedParametricTruthLemma.lean:286,417` — truth lemma + completeness-from-membership
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean:133,196,255,296` — dense countermodel +
  three headline theorems; `CompletenessDedekind.lean:88-98,127` — Dedekind probe + ℝ lub
- `FormalSystem/Metalogic/StrongCompleteness.lean:274,292,308` — Dedekind engine layer
