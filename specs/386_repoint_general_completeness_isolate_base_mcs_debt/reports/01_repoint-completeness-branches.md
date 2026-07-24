# Research Report: Re-point General `completeness` (Base) — Isolate Base-MCS Discrete Debt

- **Task**: 386 `repoint_general_completeness_isolate_base_mcs_debt`
- **Session**: sess_1784886673_059c3f_386
- **Agent**: lean-research-hard-agent (H2, H3, H4, H5 contracts active)
- **Date**: 2026-07-24
- **File under study**: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (379 lines, current state verified this session — post-flagship-docs edits)

## Executive Summary

All claims re-verified against TODAY's file state with `lean_verify`. The task premise from
review §3.5 is **partially stale**: the general `completeness` (Base) does carry `sorryAx`,
but its **sole** sorryAx source is already the discrete branch
(`WeakCanonical.countermodel_discrete`, `Transfer.lean:1264`, marked DEPRECATED with an
explicit `sorry` at `:1279`). The dense branch (`Chronicle.countermodel_dense`) and mixed
branch (`Chronicle.dd_countermodel_chronicle_mixed_sorry`) are **already sorryAx-free** —
the `_sorry` suffix on the mixed-branch lemma is a name fossil (its body is `False.elim`
around `mcs_mixed_case_absurd`, `MCSMixedCase.lean:68`).

Consequences for the task:

1. The re-point is still correct and worth doing, but its value is **hygiene and archival
   unlocking, not axiom-profile change**: the expected axiom profile of `completeness` after
   re-pointing is **unchanged** (`sorryAx` remains, from the discrete branch only).
2. The `:129` docstring / `:169` code mismatch is confirmed in current file state (line
   anchors did NOT move under the flagship-docs edits).
3. `countermodel_dense_enriched` is confirmed `private` (`:186`). Crucially, because
   `completeness` (`:135`) is in the **same file** but declared **before** it, the required
   visibility change is a **move above `:113`** (declaration-order fix); de-privatization is
   recommended per the task description but is not what makes the re-point compile — the
   reorder is.

## Reference Grounding (H3)

**Tier**: Tier 3 (implementation-backed — "re-point X at existing lemmas"). Sources are the
live codebase (verified with `lean_verify`/reads this session) and
`specs/reviews/review-2026-07-24-metalogic-cleanup.md` §3.5 (treated as a claim source to be
audited, not trusted — per the task's own instruction).

**Literature mode**: The per-repo briefing (12 docs: Kamp, Burgess, Gabbay/Hodkinson/Reynolds,
Rabinovich) was loaded. **It is not load-bearing for this task** — this is code surgery on
branch wiring, not new mathematics. The only tangential connection: the discrete-branch
residue documentation cites the Burgess chronicle tradition already referenced in-file; no
chunk reads were needed.

### Lemma-Level Mapping Table (5-column)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|---------------|-----------------|----------------|--------|
| review §3.5, mixed-branch re-point | `MCSMixedCase.lean:34` | `Bimodal.Metalogic.BXCanonical.Chronicle.mcs_mixed_case_absurd` | `(fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A) (h_not_box_dense : (Formula.box next_top.neg).neg ∈ A) (h_not_box_discrete : (Formula.box next_top).neg ∈ A) : False` | VERIFIED clean: axioms `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`, fc-generic (axiom availability via `trivial` + `liftBase fc`) |
| review §3.5, dense-branch re-point | `Completeness.lean:186` | `countermodel_dense_enriched` (currently `private`) | `{fc : FrameClass} (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A) (φ : Formula) (h_neg_in : φ.neg ∈ A) (h_box_dense : Formula.box Chronicle.next_top.neg ∈ A) : ∃ (F : TaskFrame Rat) (TM : TaskModel F) (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega) (τ : WorldHistory F) (_ : τ ∈ Omega) (t : Rat), ¬truth_at TM Omega τ t φ` | VERIFIED clean by inheritance: it is `completeness_dense`'s only nontrivial dependency and `completeness_dense` verifies to the same clean axiom set (direct `lean_verify` of the private name is blocked by name mangling) |
| review §3.5, genuine residue | `Transfer.lean:1264` | `Bimodal.Metalogic.WeakCanonical.countermodel_discrete` | `(A : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A) (φ : Formula) (h_neg_in : φ.neg ∈ A) (h_box_discrete : Formula.box next_top ∈ A) : ∃ (D : Type) ...` | VERIFIED sorried: axioms `[propext, sorryAx, Classical.choice, Quot.sound]`; DEPRECATED header at `:1256`; body is a direct `sorry` (`:1279`) |
| current mixed-branch dep | `MCSMixedCase.lean:59` | `Chronicle.dd_countermodel_chronicle_mixed_sorry` | fc-generic countermodel existential, proved vacuously | VERIFIED clean (name fossil); only live consumer is `Completeness.lean:169` → archivable after re-point |
| current dense-branch dep | `ChronicleToCountermodelBasic.lean:792` | `Chronicle.countermodel_dense` | `(fc : FrameClass) ... : ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D) (_ : Nontrivial D), ...` (instantiates `Rat` internally) | VERIFIED clean; only live consumers are `Completeness.lean:158` and the `#print axioms` at `:377` → archivable after re-point |

## Findings

### F1. Current axiom profiles (lean_verify, this session — the "before" baseline)

| Declaration | Axioms | sorryAx? |
|---|---|---|
| `BXCanonical.completeness` | `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` | **YES** |
| `BXCanonical.Chronicle.countermodel_dense` | `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` | no |
| `BXCanonical.Chronicle.dd_countermodel_chronicle_mixed_sorry` | `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` | no |
| `WeakCanonical.countermodel_discrete` | `[propext, sorryAx, Classical.choice, Quot.sound]` | **YES** (sole source) |
| `BXCanonical.Chronicle.mcs_mixed_case_absurd` | `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` | no |
| `BXCanonical.completeness_dense` | `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` | no |

**Correction to review §3.5**: the review claimed dense → "sorried chain" and mixed →
sorried. Both are FALSE today. The in-file header Status block (`Completeness.lean:32-40`,
freshly written by the flagship-docs task) is the accurate account: single sorryAx source =
discrete branch. The `Metalogic/Metalogic.lean` aggregator table (`:31`) already says the
same. The re-point therefore does not change `completeness`'s axiom profile; it makes the
dependency graph honest and unlocks archivals.

### F2. The three branches of `completeness` (`Completeness.lean:135-171`, current)

- **Dense** (`:156-159`): `Chronicle.countermodel_dense FrameClass.Base M hM_mcs φ h_neg_in h_box_dense`,
  destructured as `⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩`, closed by
  `h_not_true (h_valid D F TM Omega h_sc τ h_mem t)`.
- **Discrete** (`:163-166`): `WeakCanonical.countermodel_discrete M hM_mcs φ h_neg_in h_box_discrete` — the sorry residue. NOT re-pointable:
  `countermodel_discrete_reynolds_v2` (ReynoldsBridge.lean) requires
  `SetMaximalConsistent (fc := FrameClass.Discrete)`, and a Base-MCS is not automatically
  Discrete-consistent (Discrete has strictly more axioms available, so Discrete-consistency
  of a Base-MCS is not implied).
- **Mixed** (`:167-171`): `Chronicle.dd_countermodel_chronicle_mixed_sorry FrameClass.Base M hM_mcs φ h_neg_in h_not_box_dense h_not_box_discrete` — a vacuous countermodel existential; the direct absurdity lemma should be called instead.

Hypotheses in scope at the branch sites (all verified against `:135-171`):
`M : Set Formula`, `hM_mcs : SetMaximalConsistent (fc := FrameClass.Base) M`,
`h_neg_in : Formula.neg φ ∈ M`, `h_valid : valid φ`,
`h_box_dense / h_not_box_dense : (Formula.box Chronicle.next_top.neg) ∈ M / .neg ∈ M`,
`h_not_box_discrete : (Formula.box Chronicle.next_top).neg ∈ M`. Goal at every branch:
`False` (inside `by_contra`).

### F3. `valid` instantiation at `Rat` typechecks

`Semantics/Validity.lean:73`: `valid φ : Prop := ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] (F : TaskFrame D) (M : TaskModel F) (Omega ...) ...`.
All four instances exist globally for `Rat`; `completeness_dense:245` already does the
analogous `h_valid_dense Rat F TM Omega h_sc τ h_mem t`. So `h_valid Rat F TM Omega h_sc τ h_mem t`
is well-typed at the re-pointed dense branch.

### F4. Visibility/ordering analysis for `countermodel_dense_enriched`

- Declaration order in file: `neg_consistent_of_not_derivable` (`:63`) → `completeness`
  (`:135`) → `completeness'` (`:176`) → **`private countermodel_dense_enriched` (`:186`)** →
  `completeness_dense` (`:233`) → `completeness_discrete` (`:274`).
- `private` does NOT block same-file use — but **declaration order does**. The lemma must be
  moved above the `/-! ## BX Completeness Theorem -/` section header (`:113`).
- Move is safe: its proof body (`:193-212`) references only imported symbols
  (`Chronicle.cantor_bfmcs_dense`, `Chronicle.rooted_cantor_fmcs_dense`,
  `Algebraic.ParametricCanonical.*`, `Algebraic.ParametricHistory.*`,
  `Algebraic.RestrictedParametricTruthLemma.*`, `deferralClosure_subset_extendedDeferralClosure`,
  `self_mem_subformulaClosure`) — nothing declared later in this file.
- De-privatization (dropping `private`) is recommended (task direction; the lemma becomes a
  load-bearing dependency of two flagship theorems and should be citable/verifiable by FQN —
  `lean_verify` cannot check private declarations due to name mangling), but the compile-critical
  change is the reorder.

## Exact Re-Point Specification (executable without re-research)

### Change 1 — Move + de-privatize `countermodel_dense_enriched`

Cut the entire block `:182-212` (docstring `:182-185` + theorem `:186-212`) and paste it
immediately BEFORE the `/-! ## BX Completeness Theorem -/` header (currently `:113`),
changing `private theorem countermodel_dense_enriched` → `theorem countermodel_dense_enriched`.
Leave the `-- countermodel_discrete_enriched archived to ...` comment (`:214-215`) where it is
(or move it adjacent to `completeness_dense`; cosmetic). Optionally update its docstring's
"constructs the same countermodel as `countermodel_dense`" to note it is now the single
canonical dense countermodel used by both `completeness` and `completeness_dense`.

### Change 2 — Dense branch re-point (`:156-159` pre-move numbering)

Current:
```lean
  · -- Dense case: □(F'T) ∈ M — all box-equivalent MCS's are dense
    obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
      Chronicle.countermodel_dense FrameClass.Base M hM_mcs φ h_neg_in h_box_dense
    exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)
```
Replacement:
```lean
  · -- Dense case: □(F'T) ∈ M — countermodel on Rat (countermodel_dense_enriched)
    obtain ⟨F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
      countermodel_dense_enriched M hM_mcs φ h_neg_in h_box_dense
    exact h_not_true (h_valid Rat F TM Omega h_sc τ h_mem t)
```
(`fc` unifies to `FrameClass.Base` from `hM_mcs`; mirrors `completeness_dense:243-245`.)

### Change 3 — Mixed branch re-point (`:167-171`)

Current:
```lean
    · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — some worlds dense, others discrete
      obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
        Chronicle.dd_countermodel_chronicle_mixed_sorry FrameClass.Base M hM_mcs φ h_neg_in
          h_not_box_dense h_not_box_discrete
      exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)
```
Replacement (exact mirror of `completeness_discrete:337-338`):
```lean
    · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — eliminated by structural axiom
      exact False.elim (Chronicle.mcs_mixed_case_absurd FrameClass.Base M hM_mcs
        h_not_box_dense h_not_box_discrete)
```
Hypothesis types match exactly (`h_not_box_dense : (Formula.box Chronicle.next_top.neg).neg ∈ M`,
`h_not_box_discrete : (Formula.box Chronicle.next_top).neg ∈ M`); goal is `False`.

### Change 4 — Discrete branch: KEEP, document as sole residue

No code change at `:163-166`. This is the genuine mathematical residue (see F2 for why the
Reynolds pipeline cannot be reused for a Base-MCS).

### Change 5 — Docstring/doc fixes

1. **`completeness` docstring (`:115-134`)** — the `:129` mismatch fix. After the re-point the
   `:129-130` sentence becomes true as written; but the surrounding Status block must also be
   corrected (`:124`, `:128`, `:131-133` are stale). Suggested replacement for `:120-133`:

   ```
   **Proof Strategy**:
   1. Assume φ is not derivable
   2. By `neg_consistent_of_not_derivable`: {¬φ} is consistent
   3. By Lindenbaum: extend to MCS w₀ with ¬φ ∈ w₀
   4. Three-way case split on w₀'s temporal character:
      - Dense (□(F'T) ∈ w₀): countermodel on ℚ via `countermodel_dense_enriched`
      - Purely discrete (□(U(⊤,⊥)) ∈ w₀): countermodel via the deprecated
        `WeakCanonical.countermodel_discrete` — SOLE remaining sorryAx source
      - Mixed (¬□(F'T) ∧ ¬□(U(⊤,⊥))): eliminated by `mcs_mixed_case_absurd`
        using the structural axiom `discrete_box_necessity`

   **Sorry Status**: carries `sorryAx` with exactly one source: the Base-MCS discrete
   branch (`WeakCanonical.countermodel_discrete`, WeakCanonical/Transfer.lean). This is
   the genuine mathematical residue: a Base-MCS containing □(U(⊤,⊥)) is not automatically
   Discrete-consistent, so the sorry-free Reynolds pipeline
   (`countermodel_discrete_reynolds_v2`, which requires a Discrete-MCS) cannot be reused.
   The dense and mixed branches are sorryAx-free. For the sorry-free frame-class-specific
   results, see `completeness_dense` and `completeness_discrete`.
   ```

2. **File header Status (`:32-40`)**: update the branch-dependency names after re-point —
   dense branch now `countermodel_dense_enriched`, mixed branch now `mcs_mixed_case_absurd`
   (drop mentions of `Chronicle.countermodel_dense` / `dd_countermodel_chronicle_mixed_sorry`).
3. **`:377` `#print axioms ... Chronicle.countermodel_dense`**: after re-point this audits a
   no-longer-consumed lemma; either delete the line or (better) keep the audit but note it is
   retained pending archival.
4. **Stale anchor**: `:124` says `countermodel_dense` lives in
   `Chronicle/ChronicleToCountermodel.lean` — it actually lives in
   `ChronicleToCountermodelBasic.lean:792`. Superseded by the rewrite above (anchor removed).

### Expected axiom profile after re-point

`#print axioms Bimodal.Metalogic.BXCanonical.completeness` (already present at `:375`):
**unchanged** — `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`.
The `sorryAx` now flows through exactly one edge (`completeness → WeakCanonical.countermodel_discrete`);
compiler axioms (`Lean.ofReduceBool`/`Lean.trustCompiler`) still enter via the clean
dense/mixed dependencies (`native_decide` in the Syntax layer). `completeness_dense` and
`completeness_discrete` profiles must be unchanged (regression check).

### Verification protocol for the implementer

1. Before edit: `#print axioms` outputs at `:340-341, :375` already give the baseline (also
   recorded in F1).
2. After edit: `lake build Bimodal.Metalogic.BXCanonical.Completeness` (scoped), then
   `lean_verify` on `completeness`, `completeness_dense`, `completeness_discrete` — expect
   exactly the F1 profiles (completeness unchanged incl. sorryAx; the other two unchanged clean).
3. No new sorries; no new axioms; no changes outside `Completeness.lean` are required for
   the re-point itself.

### Archival unlocks (follow-up scope, NOT this task)

- `Chronicle.dd_countermodel_chronicle_mixed_sorry` (`MCSMixedCase.lean:59`): last live
  consumer removed → Boneyard candidate (also removes the misleading `_sorry` name from the
  live tree).
- `Chronicle.countermodel_dense` (`ChronicleToCountermodelBasic.lean:792`): last live
  consumers removed (`:158` call and `:377` audit print) → archivable; note its supporting
  chain is shared with `countermodel_dense_enriched`, so only the top-level wrapper is dead.

## Base-MCS Discrete Branch Documentation Wording (deliverable)

For use in the `completeness` docstring (integrated above) and wherever the debt is
inventoried (e.g., `Metalogic.lean` table already carries a compatible version at `:31`):

> **Sole remaining completeness debt — the Base-MCS discrete branch.** In the general
> Base-frame `completeness`, the case □(U(⊤,⊥)) ∈ M requires a discrete countermodel built
> from a *Base*-MCS. The sorry-free Reynolds pipeline (`countermodel_discrete_reynolds_v2`)
> requires `SetMaximalConsistent (fc := FrameClass.Discrete)`, and a Base-MCS is not
> automatically Discrete-consistent, so it cannot be reused here. The branch instead calls
> the deprecated `WeakCanonical.countermodel_discrete` (WeakCanonical/Transfer.lean), whose
> BX-pipeline proof is irreparably sorried (`succ_cofinal` is provably unfixable — ℤ+ℤ
> counterexample; see its DEPRECATED header). Discharging this branch is a genuine open
> construction (e.g., a Base-to-Discrete MCS transfer or a Henkin-style discrete model),
> not a re-wiring task. All other branches of `completeness`, and both flagship theorems
> `completeness_dense` and `completeness_discrete`, are sorryAx-free.

## Adversarial Self-Verification

Adversarial pass performed after drafting: every load-bearing claim was re-derived from a
tool observation made THIS session (not from the review doc, which proved stale on two
counts). One material contradiction found and resolved (see log).

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|----------------------|------------|
| `completeness` (Base) carries sorryAx today | F1 row 1 | `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness` → axioms include `sorryAx` | High |
| The ONLY sorryAx source among the three branch dependencies is `WeakCanonical.countermodel_discrete` | F1 rows 2-4; counterexample to review §3.5's "three sorried deps" | `lean_verify` on all three deps: dense and mixed clean, discrete has `sorryAx`; `Transfer.lean:1279` explicit `sorry` read directly | High |
| `Chronicle.countermodel_dense` is sorryAx-free (review §3.5 said "sorried chain" — false) | F1 row 2 | `lean_verify` → `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` | High |
| `dd_countermodel_chronicle_mixed_sorry` is sorryAx-free despite its name | F1 row 3; body read at `MCSMixedCase.lean:59-68` (proved via `False.elim (mcs_mixed_case_absurd ...)`) | `lean_verify` + source read | High |
| `mcs_mixed_case_absurd` exists, is clean, fc-generic, and its signature matches the mixed-branch hypotheses exactly | Mapping table row 1; usage precedent `Completeness.lean:338` (fc := Discrete) | `lean_verify` (clean) + full source read of `MCSMixedCase.lean:34-53` (axiom availability via `trivial`/`liftBase fc`) + hypothesis-type match against `:154-162` rcases output | High |
| `countermodel_dense_enriched` is `private`, at `Completeness.lean:186`, and sorryAx-free | Mapping table row 2 | Direct read of `:186` (`private theorem`); cleanliness by inheritance: it is the only nontrivial dependency of `completeness_dense`, which `lean_verify`s clean this session (direct verify of a private name blocked by mangling) | High (existence/privacy), Medium-High (cleanliness — inheritance argument, not direct axiom print) |
| Its signature is usable at the dense re-point site with `fc := Base` inferred and `h_valid Rat ...` | F3; mirror usage `completeness_dense:243-245` | Read of `valid` def (`Validity.lean:73`: ∀ D [AddCommGroup][LinearOrder][IsOrderedAddMonoid][Nontrivial]); Rat has all instances; identical call shape already compiles in `completeness_dense` | High (not machine-compiled at the new site — implementer confirms via build) |
| De-privatizing alone would NOT make the dense re-point compile; the lemma must move above `:113` (declaration order) | F4; decl inventory: `completeness` `:135` precedes `:186` | grep decl inventory + Lean same-file forward-reference rule | High |
| The move is safe (no same-file forward dependencies in its proof) | F4 | Read of proof body `:193-212`: all referenced symbols come from imports | High |
| `:129` (docstring claims `mcs_mixed_case_absurd`) vs `:169` (code uses `dd_countermodel_chronicle_mixed_sorry`) mismatch exists in CURRENT file state; anchors unmoved by flagship-docs edits | Direct read `:115-134`, `:167-171` this session | bounded `Read` of current file | High |
| Discrete branch is NOT re-pointable at `countermodel_discrete_reynolds_v2` | `Transfer.lean:1256-1262` DEPRECATED header; ReynoldsBridge requirement `SetMaximalConsistent (fc := FrameClass.Discrete)` per review §3.5 and `completeness_discrete:334` usage (Discrete-MCS in scope there, Base-MCS in `completeness`) | Source reads; the fc-mismatch is visible in the verified signatures | High |
| Expected post-re-point axiom profile of `completeness` is unchanged | F1: replacements carry the same clean axiom set as the deps they replace; sorryAx edge (discrete) untouched | Arithmetic over verified axiom sets | High |
| Only live consumers of `countermodel_dense` / `dd_countermodel_chronicle_mixed_sorry` are `completeness:158` / `:169` (→ archival unlocks) | grep over `Theories/Bimodal` excluding Boneyard | `grep -rn` (docstring/comment mentions and `:377` audit print noted separately) | High |

### Contradiction Log

- **RESOLVED**: review §3.5 ("`completeness`'s three branches use: dense → sorried chain; …
  mixed → `dd_countermodel_chronicle_mixed_sorry` [implied sorried]") vs file header
  `Completeness.lean:32-40` ("single source: … `WeakCanonical.countermodel_discrete`; dense
  and mixed branches are sorryAx-free"). Precedence: machine verification beats both prose
  sources — `lean_verify` this session confirms the header and refutes the review. Resolution
  adopted throughout; the re-point's rationale was downgraded from "shrinks sorry surface
  from three deps to one" to "makes the one-source situation structurally explicit, fixes the
  doc/code mismatch, and unlocks two archivals."

### Recommendations modified after verification

1. Reframed the task's expected outcome: the discrete branch is ALREADY the only sorryAx
   debt; the report's documentation wording states this and the plan must not promise an
   axiom-profile improvement.
2. Added the declaration-order finding (move above `:113`) — absent from both the task
   description and the review, which framed the visibility change as de-privatization only;
   de-privatization alone would fail to compile.
3. Flagged `:377` (`#print axioms Chronicle.countermodel_dense`) as a fourth touch point the
   review missed.

## Tactic Survey Results

Not applicable — no new proof obligations arise; both replacement terms are existing verified
lemmas used verbatim at analogous call sites (`:243-245`, `:337-338`). `lean_multi_attempt`
was therefore not exercised (H2 note: the "verified candidate" bar was met by `lean_verify`
confirmations within the first third of tool calls).

## Memory Candidates

1. **Pattern (lean4)**: `lean_verify` cannot check `private` theorems by name (name
   mangling); verify cleanliness via a public consumer whose only nontrivial dependency is
   the private lemma. (Novel, reusable.)
2. **Pattern (lean4)**: "de-privatize" requests for same-file reuse are usually
   declaration-ORDER problems, not visibility problems — `private` never blocks same-file
   use, but forward references always fail. Check decl order before touching visibility.
3. **Fact (repo)**: `_sorry`-suffixed names in the live tree are not reliable sorry
   indicators — `dd_countermodel_chronicle_mixed_sorry` is machine-verified sorryAx-free;
   always `lean_verify`, never trust names or review prose for axiom status.

## Next Steps

Run `/plan 386` — the re-point spec above (Changes 1-5 + verification protocol) is
executable as a single small implementation phase without re-research.
