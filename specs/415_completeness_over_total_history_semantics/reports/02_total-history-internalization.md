# Research Report: Completeness over Total-History Semantics — Internalized, Not Bridged

- **Task**: 415 — completeness_over_total_history_semantics (re-issued 2026-08-10, total-history framing)
- **Session**: sess_1786417819_f9ee53
- **Agent**: lean-research-agent (orchestrator dispatch, delegation depth 2)
- **Date**: 2026-08-10
- **Supersedes**: report 01 (`reports/01_completeness-maximal-history-rebase.md`) in full, except
  its explicitly-listed SURVIVES items, which are re-confirmed and strengthened below.
- **Definitions lint**: `bash scripts/check-paper-definitions.sh` run first — outcome **case (b)
  notice** ("possible_worlds.tex changed ... but all 23 recorded definitions are unchanged --
  pass"). Proceeded per contract. All paper citations below are by `\label` / `\aitem` anchor
  against `specs/paper-definitions-of-record.md`, never by line number.

## Executive Summary

1. **The totality reframing SIMPLIFIES the countermodel machinery relative to round 1's
   maximality framing.** The workhorse characterization lemma is no longer an `IsMax`
   characterization needing a `Preorder (WorldHistory F)` instance, Zorn, and a
   `[Nonempty FamIdx]` fence — it is a **totality characterization**: every history of a
   deterministic flow frame with full domain (`∀ t, σ.domain t`) *is* a flow line. That is
   statable and provable **today**, against the current `WorldHistory` structure, with no
   dependency on task 414. No Zorn, no order instance, no empty-history edge case (totality
   excludes it), no nonempty-index side condition (the family index is extracted from σ itself).
2. **The deterministic lead-frame skeleton already exists D-generically.**
   `multiFamTaskFrameGen` / `multiFamHistoryGen` (`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:139-200`)
   is exactly the flow frame (`WorldState := FamIdx × D`, clock TaskRel) over an arbitrary
   ordered abelian group. `bundleFlowFrame` is an **instantiation** of it (index = bundle
   families) plus a valuation — not a from-scratch construction. All four-axiom conformance
   proofs can be done **once, generically**, then transported to the ℤ discrete frame and the
   ℚ/ℝ dense/Dedekind frames.
3. **All four `def:frame` axioms discharge on flow frames via two short patterns**, both now
   corroborated by the paper's own worked verifications (translation-flow frame; off-zero
   universal discrete frame): (a) determinism makes every fiber a singleton and every segment a
   subsingleton, so *Spherical* follows from a new ~10-line helper ("a directed family of
   nonempty subsingleton sets has nonempty ⋂₀"); (b) *Limit* is already dischargeable by the
   on-disk `TaskFrame.limit_of_shift` (`FormalSystem/Semantics/TaskFrame.lean:330`) with
   `pos := Prod.snd`. Biconditional *Compositionality* interpolates through the unique
   intermediate `(f, w.2 + x)`; *Seriality* is the clock's totality. The segment identity
   `w ⇒_{x+y} v ↔ [w,v]_xʸ ≠ ∅` is a 3-line **derived** lemma (comp-iff + `converse` +
   `mem_Seg`), as the re-issued description requires (it may no longer be cited to the paper).
4. **A large tranche of this task is executable NOW, before 414 lands and before 420's phase 10
   lands** — and executing it is what UNBLOCKS 420 phase 10, which is `[BLOCKED]` on exactly
   this task's `bundleFlowFrame` (420 plan v2, Phase 10 gate). The now-executable tranche:
   generic four-axiom conformance theorems + totality characterization for
   `multiFamTaskFrameGen`; `bundleFlowFrame`/History/Model as its bundle-index instantiation;
   the dense truth-lemma re-host off `ParametricCanonicalTaskFrame` (which 420 confirmed
   genuinely violates *Limit* and cannot be repaired in place); and deletion of the dead
   singleton-Omega device (`Transfer.lean:568-687`). Only the final Omega-free statements
   (TruthAt/Valid*/headliners/packaging) phase-wait on 414.
5. **Limit-violating-witness audit (per the 2026-08-10 CAUTION): clean on live paths.** No
   two-state (or any ≥2-carrier) universal-relation frame exists in the non-Boneyard tree; the
   four `TaskRel := fun _ _ _ => True` sites all have `Unit` carriers, where *Limit* is trivial.
   The genuine *Limit* violators are (i) `ParametricCanonicalTaskFrame` (live, being replaced by
   this task) and (ii) the `Nat`-carrier permissive example frames over dense `D`
   (`natFrame`/`genericNatFrame`/`intNatFrame`), which are test/example frames already scheduled
   for discrete-binder restriction in 420's site inventory.
6. **Sorry inventory: exactly one live `sorry`** — `Transfer.lean:1242`
   (`countermodel_discrete`, Base-MCS discrete branch), re-verified by strict token grep. It is
   restated Omega-free under this task but remains open (its closure is the Base-frame-class
   programme of task 169, `not_started`). Tasks 170 and 408, named in the staging order, no
   longer exist in `specs/state.json` (active or archive) — the Dense and Dedekind legs are now
   carried by this task's own phases, with no separate task-level owner.

## 1. Definitions of Record Consumed (anchors + load-bearing verbatim text)

All quoted from `specs/paper-definitions-of-record.md` (lint case (b) pass, checksum
`1256e218...`); text search on the quoted strings will re-locate an anchor even if renamed.

- **`def:frame`** — "A *frame* is any F = ⟨W, D, ⇒⟩ where W is a nonempty set of world states,
  D is a temporal order, and ⇒ is a task relation satisfying the following for x, y ≥ 0" with
  the four axioms: **`def:frame#Compositionality`** "$w \Rightarrow_{x + y} v$ if and only if
  $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$" (a biconditional);
  **`def:frame#Seriality`** "$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$";
  **`def:frame#Limit`** "$\bigcap\limits_{x > 0} (w)_x = \set{w}$"; **`def:frame#Spherical`**
  "$\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of nonempty fibers
  and segments". The only footnote remnant at *Spherical* is a commented-out ball-spaces
  reference; the former calibration footnote is deleted and is not cited here.
- **`def:task-relation`** — *Fiber:* "$\Fib(w, x) \coloneq \set{u \in W : w \Rightarrow_x u}$";
  *Cone:* "$(w)_x \coloneq \bigcup_{|y| < x} \Fib(w, y)$ where $x > 0$"; *Segment:*
  "$[w, v]_x^y \coloneq \Fib(w, x) \cap \Fib(v, -y)$ where $x, y \geq 0$" (bracket form is the
  notation of record; `\Seg` is retired).
- **`def:directed`** — "A nonempty family of sets $\mathcal{S}$ is *directed* just in case
  $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$."
- **`def:world-history`** — layering partial history (nonempty domain, no convexity) → world
  history (convex domain) → "A world history is *total* --- equivalently, a *possible world* ---
  just in case X = D. ... The set of all total world histories over F is denoted H_F."
- **`def:BL-semantics`** — box clause: "$\M,\tau,x \vDash \Box \varphi$ *iff*
  $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$." Atom clause (no dom conjunct):
  "$\M,\tau,x \vDash p_i$ *iff* $\tau(x) \in |p_i|$."
- **`def:logical-consequence`** — "for all models M, possible worlds τ ∈ H_F, and times x ∈ D
  ..."; **`def:frame-validity`** — frame-relative analogue.
- **Extension chain** (the paper's own H_F-nonemptiness argument): `def:constraints` →
  `lem:constraint` (directedness + nonemptiness; consumes Compositionality in BOTH directions
  plus Seriality) → `lem:fibers` → `lem:admissible` → `lem:step` (sole *Spherical* application
  site; closing remark, load-bearing for the discrete case: "When the family has a ⊆-least
  member, that member already contains a candidate and *Spherical* is not needed.") →
  `thm:extension` (Zorn) → `cor:occurrence` ("For any frame F, world state w ∈ W, and time
  x ∈ D, there is a total world history τ ∈ H_F where τ(x) = w, and so H_F ≠ ∅"). The former
  thm:occurrence/app:nonempty anchors are merged into `cor:occurrence`; the former two-sided
  segment lemma no longer exists — `lem:constraint`/`lem:step` are cited instead throughout.

## 2. Dependency Ground Truth (on-disk, re-verified this dispatch)

| Dependency | state.json status | On-disk reality |
|---|---|---|
| 414 (totality-based semantics API) | `not_started` | `TruthAt` (`Semantics/Truth.lean:128-137`) still takes `Omega : Set (WorldHistory F)`; box case quantifies over `σ ∈ Omega`; atom clause still carries the `∃ (ht : τ.domain t)` dom conjunct. `valid`/`SemanticConsequence`/`satisfiable` (`Semantics/Validity.lean:79-133`) all Omega+ShiftClosed-relativized. **No `IsMax`, no `Preorder (WorldHistory F)`, no totality predicate anywhere in `Semantics/`.** |
| 420 (four-axiom TaskFrame + apparatus) | `partial` | Plan v2 phases 1-9 **COMPLETED** (commits `142034939`…`7ada34f20`): fiber/cone/segment/directed apparatus **on disk** (`TaskFrame.Fib/cone/Seg/DirectedFamily/IsFiber/IsSegment`, TaskFrame.lean:445-530), Limit helpers `limit_of_succOrder`/`limit_of_shift`/`exists_uniform_radius_of_finite` (TaskFrame.lean:302-409; note the helpers were RENAMED from the plan's `limit_nullity_of_*` in the phase-9 naming pass), `identityFrame` replaced by the serial `staticFrame` (TaskFrame.lean:563), docstrings corrected. **Phase 10 `[BLOCKED]` on THIS task's `bundleFlowFrame`**: the structure still carries only `nullity_identity`/`forward_comp`/`converse`; Seriality/Limit/Spherical/interpolation are documented gaps (TaskFrame.lean:74-89). |
| 438 (reconcile semantic definitions with JPL paper) | `completed` | Its round-2 audit content is already baked into this task's re-issued description; nothing further to consume. |
| 169 (Base) | `not_started` | Owns closure of the sole live sorry (`Transfer.lean:1242`); 415 restates it, does not close it. |
| 170 (Dense), 408 (Dedekind) | **absent** from state.json (active and archive) | The staging order's per-class task owners for Dense/Dedekind no longer exist; those legs live inside 415's own phases. Flag for the planner: no external coordination partner for `StrongCompleteness.lean`/`CompletenessDedekind.lean` any more (round 1's "task 408 concurrently [IMPLEMENTING] against the same files" warning is obsolete). |

**The 415 ↔ 420 interlock, precisely** (from 420 plan v2 Phase 10, re-read this dispatch):
420's phase 10 gate requires 415 to land a carrier satisfying the Coordination Contract —
`Index × D` (or equivalent) with `pos : W → D`, `R w y u → pos u = pos w + y` — AND to replace
`ParametricCanonicalTaskFrame` at its three live-path exposure sites:
`BXCanonical/Completeness.lean:143` (`countermodel_dense_enriched` witness),
`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:839`, and the ℝ elaborations at
`CompletenessDedekind.lean:78/81/86`. 420's finding B.2 (re-confirmed): the parametric frame's
MCS-pair carrier is duration-blind above zero, so *Limit* genuinely fails over dense D and no
shift projection can exist — **the carrier must change; repair in place is impossible**. This
matches and strengthens round 1's independent junk-histories refutation (§4 there): under
Omega-free semantics the parametric frame is refutable against the truth lemma, and under the
four-axiom frame it is not even a frame. Two independent kill-shots, one conclusion.

## 3. The Totality Reframing: What Changes vs. Round 1 (core finding)

Round 1's architecture routed everything through maximality: a `Preorder (WorldHistory F)`
extension order, Mathlib `IsMax`, Zorn (`exists_maximal_extension`), `isMax_timeShift`, and
characterization lemmas `multiFam_isMax_iff` / `bundleFlow_isMax_iff` carrying `[Nonempty FamIdx]`
fences against the vacuously-maximal empty history. Under the re-issued target — H_F = ALL total
histories — the countermodel side needs none of that:

**Workhorse lemma (new form).** For the generic flow frame:

```lean
/-- Every total history of the deterministic flow frame is a flow line. -/
theorem multiFamGen_total_eq {FamIdx : Type} (σ : WorldHistory (multiFamTaskFrameGen D FamIdx))
    (htot : ∀ t, σ.domain t) :
    ∃ f w₀, σ = multiFamHistoryGen f w₀
```

Proof sketch, checked against the on-disk `WorldHistory` structure
(`Semantics/WorldHistory.lean:94-123`: fields `domain`, `convex`, `states`, `respects_task`):
`σ.states 0 (htot 0) = (f, z₀)`; for any `t`, `respects_task 0 t` gives
`TaskRel (f, z₀) (t - 0) (σ.states t _)`, and the clock relation forces
`σ.states t _ = (f, z₀ + t)`. Equality of structures: `htot` + `funext`/`propext` give
`σ.domain = fun _ => True`; the states field crosses the domain equality by the in-repo
`change WorldHistory.mk _ _ _ _ = WorldHistory.mk _ _ _ _; congr 1` precedent
(`multiFamHistoryGen_shift_eq`, ChronicleMonadicBridge.lean:180-188; also
`multiFamHistory_shift_eq`, ReynoldsBridge.lean:698). **Notable simplifications vs. round 1's
`multiFam_isMax_iff`:** no Preorder instance, no Zorn, no `[Nonempty FamIdx]` (f comes from σ),
no empty-history edge case (a total domain is nonempty since `D` is a group, inhabited by 0),
and — decisively — **no dependency on task 414**: `∀ t, σ.domain t` is statable against the
current structure. The converse direction is definitional (`multiFamHistoryGen` has
`domain := fun _ => True`).

**H_F-nonemptiness is constructive for these frames.** `cor:occurrence` for an arbitrary frame
needs the full `lem:constraint → lem:step → thm:extension` Zorn chain; for flow frames,
`multiFamHistoryGen f (w - x)` puts `(f, w)` at time `x` outright. The Zorn chain is 420 phase
10's acceptance criterion (its `lem:step` must consume the `spherical` field literally) and 414's
territory for arbitrary frames; 415's countermodels never need it. This is the precise sense in
which "the mathematical content of realization is absorbed into the constructions": the
countermodel family = H_F holds **definitionally-plus-one-lemma** for flow frames, with no
transfer statement anywhere.

**Confirmation of the SURVIVES judgment.** The deterministic lead frame is not merely tolerant
of totality — it is strictly better adapted to it than to maximality (fewer prerequisites,
smaller proofs). The paper's own new worked verification of the translation-flow frame (both
Compositionality directions via the unique intermediate, singleton fibers, Spherical via
singletons) is the same discharge pattern §4 below instantiates. The round-1 SURVIVES list
(staging Discrete → Dense → Base → Dedekind; internalize-don't-bridge; deterministic lead frame)
is confirmed in full; the strand-construction footnote at `cor:tm-completeness` (source-tagged
'task 52 total-histories: optional S43 hedge') changes nothing — internalization strictly
dominates, and the footnote's own obligation list (biconditional Compositionality, Seriality,
Spherical for the delivered frames; Occurrence via `cor:occurrence`) is exactly the acceptance
checklist §4 discharges. Note for the flow frames W ≅ FamIdx × D is **infinite**, so the
footnote's "Spherical automatic for finite W" escape does not apply — the subsingleton route in
§4 is the genuine discharge, not a finiteness shortcut.

## 4. Four-Axiom Conformance of the Flow Frames (per-axiom discharge table)

All statable NOW as standalone theorems against the bare relation (phase-7 apparatus is on
disk); they become field-discharges by `exact` when 420 phase 10 adds the fields. Let
`R := (multiFamTaskFrameGen D FamIdx).TaskRel = fun p d q => p.1 = q.1 ∧ q.2 = p.2 + d`.

| Axiom (anchor) | Obligation on R | Discharge | Paper corroboration |
|---|---|---|---|
| `def:frame#Compositionality` (biconditional — NEW obligation, `→` direction) | `0 ≤ x → 0 ≤ y → (R w (x+y) v ↔ ∃ u, R w x u ∧ R u y v)` | `←` is the existing `forward_comp`. `→` (interpolation): witness `u := (w.1, w.2 + x)`; both conjuncts by `abel`-level algebra. Sign hypotheses unused (holds for all x, y) — state the strong form, project the field form. | Translation-flow verification: "both Compositionality directions via the unique intermediate u = w + x" |
| `def:frame#Seriality` | `0 ≤ x → (∃ u, R w x u) ∧ (∃ v, R v x w)` | `u := (w.1, w.2 + x)`, `v := (w.1, w.2 - x)`. Holds for all x. | "Seriality via singleton forward/backward fibers" |
| `def:frame#Limit` | `∀ w u, (∀ x, 0 < x → ∃ y, \|y\| < x ∧ R w y u) → u = w` | **Already dischargeable**: `TaskFrame.limit_of_shift` (TaskFrame.lean:330) with `pos := Prod.snd`, `hshift` by the relation's second conjunct, `hzero` from `nullity_identity`. Requires `[Nontrivial D]` (correctly — the paper mandates nontrivial D). | "Limit via (w)_d = {u : \|u - w\| < d}" |
| `def:frame#Spherical` | `DirectedFamily S → (∀ s ∈ S, s.Nonempty) → (∀ s ∈ S, IsFiber R s ∨ IsSegment R s) → (⋂₀ S).Nonempty` | NEW helper + instantiation, see below | "Spherical because every fiber and every nonempty segment is a singleton" |

**The Spherical helper (new, generic, ~10 lines).** For any `W`:

```lean
/-- A directed family of nonempty subsingleton sets has nonempty intersection. -/
theorem sInter_nonempty_of_directed_subsingleton
    {W : Type} {S : Set (Set W)} (hdir : TaskFrame.DirectedFamily S)
    (hne : ∀ s ∈ S, s.Nonempty) (hsub : ∀ s ∈ S, s.Subsingleton) :
    (⋂₀ S).Nonempty
```

Proof: `S` nonempty gives `s₀ ∈ S`; pick `a ∈ s₀`. For any `s₁ ∈ S`, directedness gives
`s' ∈ S`, `s' ⊆ s₀ ∩ s₁`; `s'` nonempty gives `b ∈ s'`; `b ∈ s₀` and `s₀` subsingleton force
`b = a`; hence `a ∈ s₁`. So `a ∈ ⋂₀ S`. Then for the flow frame: every fiber
`Fib R (f,a) x = {(f, a + x)}` is a singleton, and every segment is an intersection of fibers,
hence a subsingleton — so the hypothesis set of the helper is met and *Spherical* falls out.
This helper is also reusable verbatim for `staticFrame` and every deterministic frame 420's
phase 10 must discharge. (For 420's **finite-carrier** sites — FMP/filtration — the separate
route is the `lem:step` closing remark's ⊆-least-member shape; Mathlib support:
`Set.Finite.wellFoundedOn` + `Set.WellFoundedOn.exists_minimal`
(`Mathlib/Order/WellFoundedSet.lean`, verified present via `lean_local_search`); that is 420's
deliverable, not 415's, but the planner should know both routes exist and differ.)

**The derived segment identity** (required to be DERIVED, not cited — the paper text carrying it
is deleted):

```lean
/-- w ⇒_{x+y} v ↔ [w, v]_x^y ≠ ∅ — derived from Compositionality + def:task-relation. -/
theorem taskRel_add_iff_seg_nonempty {W : Type} {R : W → D → W → Prop}
    (hcomp : ∀ w v x y, R w (x+y) v ↔ ∃ u, R w x u ∧ R u y v)   -- comp biconditional
    (hconv : ∀ w d u, R w d u ↔ R u (-d) w)                       -- converse convention
    (w v : W) (x y : D) :
    R w (x + y) v ↔ (TaskFrame.Seg R w v x y).Nonempty
```

Proof: `u ∈ Seg R w v x y ↔ R w x u ∧ R v (-y) u` (`mem_Seg`) `↔ R w x u ∧ R u y v` (converse),
then `hcomp`. Three lines. This is the workhorse the description predicts for discharging
Spherical-adjacent obligations on concrete constructions (a segment is nonempty exactly when the
composite step exists).

## 5. Limit-Violating Witness Audit (per the 2026-08-10 CAUTION)

The paper replaced its former two-state universal-relation witnesses because they violate
*Limit*. Repo-wide audit for transcriptions (grep over non-Boneyard `FormalSystem/` +
`Tests/`):

- `TaskRel := fun _ _ _ => True` occurs at exactly 4 sites, **all with `Unit` carriers**:
  `trivialFrame` (TaskFrame.lean:538), `intTimeFrame`/`genericTimeFrame`
  (Examples/TemporalStructures.lean:79,158), `zIntervalTaskFrame` (Transfer.lean:568, dead
  code). On a subsingleton carrier `⋂_{x>0}(w)_x = {w}` is trivial — no violation. **No Bool /
  Fin 2 / two-state universal frame exists in the live tree.** The old paper witnesses were
  never transcribed.
- The genuine dense-D *Limit* failures are the `Nat`-carrier permissive frames
  (`natFrame` TaskFrame.lean:591, `genericNatFrame`/`intNatFrame` TemporalStructures.lean): at
  `u ≠ w` the relation holds at every nonzero duration, so over dense D the cone intersection is
  all of `Nat`. These are example/test frames; 420's site inventory already prescribes
  discrete-binder restriction (`limit_of_succOrder`). Not 415 surface.
- The one **live-path** violator is `ParametricCanonicalTaskFrame` — which this task deletes
  from live paths by design (§2). Conclusion: no additional rebase surface found; the audit
  closes clean.

## 6. Per-Class Proof Obligations and the Rebase Map

### 6.1 Discrete (currently green under Omega semantics)

Live path: `completeness_discrete` → `countermodel_discrete_reynolds_v2`
(`ReynoldsBridge.lean:739`) over `multiFamTaskFrame FamIdx` (ℤ; `FamIdx` = box-equivalent
Discrete-MCSes, inhabited by `f₀ := A`, line 754-757). Rebase, per the totality reframing:

- The truth-correspondence induction (line ~804 ff.) changes **only in the box case**
  (~840-940): forward direction instantiates the hypothesis at `multiFamHistory f' (z-t)` using
  its (definitional) totality instead of `∈ multiFamOmega`; reverse direction destructures an
  arbitrary total σ via the ℤ-instance of `multiFamGen_total_eq` instead of Omega-membership.
  Atom case simplifies (dom conjunct gone post-414). Temporal cases untouched.
- Packaging drops `(Omega, ShiftClosed Omega, τ ∈ Omega)` for the totality of the witness
  (spelled per 414's interface — see §8 interface note).
- The entire `TemporalTruth`-side Reynolds cone (mkSigFrom, KEquiv, truth_transfer,
  table_correctness, EF games, Kamp/Prior) is Omega-free — **preserved verbatim** (re-confirmed
  from round 1; unchanged by the totality reframing).
- Four-axiom conformance: instances of the generic §4 theorems at `D := ℤ` (or restated for the
  ℤ original, which `ChronicleMonadicBridge`'s `_int` lemmas certify is the definitional
  specialization of the generic frame).

### 6.2 Dense (rebuild — the 420-unblocking leg)

`bundleFlowFrame` is the bundle-index instantiation of the generic frame:

```lean
-- e.g. FormalSystem/Metalogic/Algebraic/FlowFrame.lean (new; names provisional)
noncomputable def bundleFlowFrame (B : BFMCS (fc := fc) D) : TaskFrame D :=
  multiFamTaskFrameGen D {fam : FMCS (fc := fc) D // fam ∈ B.families}

noncomputable def bundleFlowHistory (fam : {fam // fam ∈ B.families}) (w₀ : D) :
    WorldHistory (bundleFlowFrame B) := multiFamHistoryGen fam w₀

noncomputable def bundleFlowModel (B : BFMCS (fc := fc) D) : TaskModel (bundleFlowFrame B) where
  valuation := fun w p => Formula.atom p ∈ w.1.val.mcs w.2
```

Conformance and totality characterization are inherited from the generic layer for free. The
truth lemma re-hosts `fully_restricted_parametric_shifted_truth_lemma`
(`RestrictedParametricTruthLemma.lean:286`) with `(fam, w₀)` replacing
`timeShift (parametricToHistory fam) delta` (the flow history at offset w₀ IS the shifted
history — the separate "shifted" formulation dissolves): atom case is definitional MCS
membership; imp/bot/untl/snce use only FMCS temporal coherence (`forward_G`, restricted
tc/buc/fuc — frame-independent, preserved verbatim); box case uses `parametric_box_persistent` +
`B.modal_forward`/`B.modal_backward` (`Bundle/BFMCS.lean:91` ff.) with totality-destructuring in
place of Omega-destructuring. Because the carrier now contains ONLY bundle families, the junk
total histories that refuted an internalized truth lemma on the parametric frame (§2) do not
exist: **the frame's full total-history set IS the countermodel family** — internalization holds
by construction. `countermodel_dense_enriched` (`Completeness.lean:133`) re-packages over
`bundleFlowFrame` at `D := ℚ` using the unchanged chronicle suppliers
(`Chronicle.cantorBfmcsDense`, `rootedCantorFmcsDense`, `cantor_bfmcs_dense_restricted_tc/buc/fuc`
— all Bundle/Chronicle-level, Omega-free); `ChronicleToCountermodelBasic.lean:839` re-points
likewise.

**Sequencing option (planner decision, recommendation attached).** The frame re-host is
414-independent, but the truth lemma's statement mentions `TruthAt`, which today carries Omega.
Two options: (A) re-host NOW under the current Omega signature with
`Omega := multiFamOmegaGen ...` (fully replacing `ParametricCanonicalTaskFrame` on live paths,
discharging 420's phase-10 gate immediately; post-414, only the box case and packaging lines
change again — a bounded second pass of ~20-40 lines per site); (B) wait for 414 and do one
pass. **Recommendation: (A).** 420 phase 10 is the critical path for the whole four-axiom
programme; its gate explicitly requires the live-path replacement, and the second pass is small
and mechanical. If the planner learns 414 will land first anyway, (B) collapses into the same
plan with two phases merged.

### 6.3 Base

`completeness` (`Completeness.lean:196` ff.): dense and mixed branches re-point at the re-hosted
dense machinery; the discrete branch's `countermodel_discrete` (`Transfer.lean:1225`) is
restated Omega-free/totality-shaped **and remains sorried** — closure is task 169's programme
(two candidate routes documented in-file at Transfer.lean:1234-1241: Base→Discrete MCS transfer,
or a direct Henkin-style discrete canonical model). The three-way case-split proof-theory
(`neg_consistent_of_not_derivable`, `set_lindenbaum`, `mcs_mixed_case_absurd`, the ten-step
Discrete derivation) is untouched. The dead singleton-Omega device (`Transfer.lean:568-687`:
`zIntervalTaskFrame`/`zIntervalOmega`/`zIntervalBox_transparent`/`z_interval_countermodel`) has
zero live consumers (round-1 grep, re-confirmed by the Omega-mention survey) — delete it in the
same phase.

### 6.4 Dedekind

`StrongCompleteness.lean` (consequence definitions + `completeness_dedekind_of_engine` /
`consequence_completeness_dedekind_of_engine`, lines ~274-308) restates with the same
substitution; `CompletenessDedekind.lean` ℝ probes (78/81/86) re-point at `bundleFlowFrame` at
`D := ℝ`; `real_lub_of_bddAbove` untouched. No task-level coordination partner exists any more
(408 is gone from state.json) — the planner owns these files outright.

## 7. Sorry / Blast-Radius Inventory (for phase sizing)

**Live sorries: exactly 1.** `Transfer.lean:1242` (strict `-w sorry` grep over non-Boneyard
`FormalSystem/`, comment lines excluded; every other hit is docstring prose). No `axiom`
declarations in the live tree. Restated-not-closed under this task.

**Omega/ShiftClosed mention counts by file** (non-Boneyard; a proxy for rebase surface —
includes docstrings):

| Owner | File | Mentions |
|---|---|---|
| 414 | `Metalogic/Soundness.lean` | 257 |
| 414 | `Metalogic/SoundnessLemmas/DenseValidity.lean` | 169 |
| 414 | `Metalogic/SoundnessLemmas/FrameClassVariants.lean` | 112 |
| 414 | `Semantics/Truth.lean` / `Semantics/Validity.lean` | 85 / 73 |
| 414 | `FrameConditions/Soundness.lean` / `Validity.lean` | 29 / 21 |
| 414 | `Automation/PrefilterSoundness.lean` | 22 |
| 414/415 boundary | `Metalogic/Decidability/Verified/Bridge/*` (Omega.lean 26, Valuation 20, IntTruth 16, TruthLemma 13, DenseTruth 7, Decidable 8) | 90 total — mostly 414 propagation; `regionFrame` (Omega.lean:136) is 420 site #15 |
| **415** | `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` | 29 |
| **415** | `Metalogic/WeakCanonical/Transfer.lean` | 22 (mostly the dead device + sorried restatement) |
| **415** | `Metalogic/Algebraic/ParametricHistory.lean` | 18 (superseded by flow module) |
| **415** | `Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` | 17 (OmegaGen wrapper goes; frame/history stay) |
| **415** | `Metalogic/Algebraic/ParametricTruthLemma.lean` / `RestrictedParametricTruthLemma.lean` | 15 / 14 |
| **415** | `Metalogic/BXCanonical/Completeness.lean` / `CompletenessDedekind.lean` | 14 / 11 |
| **415** | `Metalogic/StrongCompleteness.lean` | 13 |
| 414 | `Metalogic/SoundnessLemmas/Core.lean` / `CoValidity.lean` | 12 / 11 |

415's own surface is 9 files, ~150 mentions; the semantics/soundness propagation (~800 mentions)
is 414's. Possible post-re-host deletions (check at plan time): `ParametricCanonicalTaskFrame`
itself, `ParametricHistory.lean`'s Omega definitions, `ParametricTruthLemma.lean` /
`ParametricCompleteness.lean` if nothing else consumes them once the restricted lemma re-hosts.

## 8. Target Lean Signatures (updated from round 1: maximality → totality)

**Interface note (the one genuine 414 coupling).** The paper quantifies over `τ ∈ H_F`. 414 must
choose a spelling: an inline `(∀ t, τ.domain t)` hypothesis, a named predicate
(`WorldHistory.IsTotal`), or a subtype/structure (`TotalHistory F` ≅ the paper's "possible
world"). **Recommendation to coordinate with 414: a named predicate
`def WorldHistory.IsTotal (τ : WorldHistory F) : Prop := ∀ t, τ.domain t`** — minimal diff from
the current structure, keeps every existing history construction compiling, makes the signatures
below readable, and leaves a subtype refactor available later. Everything below uses
`τ.IsTotal`; substitute 414's actual spelling mechanically. WorldHistory.lean's own module
docstring (lines 31-35) already declares the partial/world/total layering "deferred, joint" —
i.e., 414's design surface, not 415's.

```lean
-- 414's semantics (restated as the interface 415 builds against; 414 owns these)
def TruthAt (M : TaskModel F) (τ : WorldHistory F) (t : D) : Formula → Prop
  | .atom p  => M.valuation (τ.states t (h_total ...)) p   -- dom conjunct gone; exact form is 414's
  | .box φ   => ∀ σ : WorldHistory F, σ.IsTotal → TruthAt M σ t φ
  | ...
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [inst…] (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F),
    τ.IsTotal → ∀ t : D, TruthAt M τ t φ

-- 415: generic flow-frame layer (statable and provable NOW)
theorem multiFamGen_comp_iff  (w v : FamIdx × D) (x y : D) :
    R w (x + y) v ↔ ∃ u, R w x u ∧ R u y v
theorem multiFamGen_serial    (w : FamIdx × D) (x : D) :
    (∃ u, R w x u) ∧ (∃ v, R v x w)
theorem multiFamGen_limit     : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w
  -- := TaskFrame.limit_of_shift Prod.snd … ; needs [Nontrivial D]
theorem multiFamGen_spherical (S : Set (Set (FamIdx × D))) (hdir : DirectedFamily S)
    (hne : ∀ s ∈ S, s.Nonempty) (hfs : ∀ s ∈ S, IsFiber R s ∨ IsSegment R s) :
    (⋂₀ S).Nonempty
theorem sInter_nonempty_of_directed_subsingleton …            -- §4 helper (any W)
theorem taskRel_add_iff_seg_nonempty …                        -- §4 derived identity
theorem multiFamGen_total_eq (σ) (htot : ∀ t, σ.domain t) :
    ∃ f w₀, σ = multiFamHistoryGen f w₀                       -- §3 workhorse

-- 415: dense/Dedekind carrier (statable NOW; truth lemma per §6.2 sequencing choice)
noncomputable def bundleFlowFrame (B : BFMCS (fc := fc) D) : TaskFrame D
noncomputable def bundleFlowHistory / bundleFlowModel …
theorem bundleFlow_truth_lemma (h_rtc h_buc h_fuc) (φ) (h_sub : φ ∈ subformulaClosure root)
    (fam hfam) (w₀ t : D) :
    TruthAt (bundleFlowModel B) (bundleFlowHistory ⟨fam, hfam⟩ w₀) t φ ↔ φ ∈ fam.mcs (w₀ + t)

-- 415: restated countermodels + headliners (post-414; statement TEXT of headliners unchanged)
theorem countermodel_discrete_reynolds_v2 … :
    ∃ (D : Type) …discrete instances… (F : TaskFrame D) (TM : TaskModel F)
      (τ : WorldHistory F), τ.IsTotal ∧ ∃ t : D, ¬TruthAt TM τ t φ
theorem countermodel_dense_enriched … :
    ∃ (F : TaskFrame ℚ) (TM : TaskModel F) (τ : WorldHistory F),
      τ.IsTotal ∧ ∃ t : ℚ, ¬TruthAt TM τ t φ
theorem countermodel_discrete …Base-MCS… :  ∃ … τ.IsTotal ∧ …   -- restated, still `sorry`
theorem completeness_discrete : ValidDiscrete φ → Derivable FrameClass.Discrete [] φ
theorem completeness_dense    : ValidDense φ → Derivable FrameClass.Dense [] φ
theorem completeness          : valid φ → Derivable FrameClass.Base [] φ
theorem completeness_dedekind_of_engine / consequence_completeness_dedekind_of_engine …
```

No transfer or realization lemma appears in any final statement.

## 9. What Can Proceed Now vs. What Phase-Waits (the orchestrator's question)

| Work item | Gate | Rationale |
|---|---|---|
| Generic conformance layer (§4: comp_iff/serial/limit/spherical + helper + segment identity) | **NONE — now** | Apparatus on disk (420 phase 7); bare-relation statements; `limit_of_shift` exists |
| Totality characterization `multiFamGen_total_eq` (§3) | **NONE — now** | `∀ t, σ.domain t` statable against current WorldHistory; no IsMax/Preorder/Zorn needed |
| `bundleFlowFrame`/History/Model (§6.2) | **NONE — now** | Instantiation of on-disk generic frame; current 3-field TaskFrame suffices |
| Dense truth-lemma re-host + live-path replacement of ParametricCanonicalTaskFrame | **now under Option A** (Omega-parameterized), else 414 | §6.2 sequencing choice; Option A discharges 420 phase 10's gate immediately |
| Delete dead singleton-Omega device (Transfer.lean:568-687) | **NONE — now** | Zero consumers |
| Box-case rewrites, packaging existentials, headliner/consequence restatements, atom-clause simplifications | **414** | Statements mention the Omega-free `TruthAt`/`Valid*` that 414 defines |
| Stating conformance as TaskFrame **fields** | **420 phase 10** | Mechanical (`exact` the §4 theorems) once fields exist; 420 executes this, gated on 415's frame |
| Closing `countermodel_discrete`'s sorry | **task 169** | Out of 415's scope by explicit prior decision (restate only) |

**Deadlock check**: there is none. 415's now-tranche needs nothing from 414 or 420-phase-10;
420 phase 10 needs 415's now-tranche; 414 is independent of both (its own surface is
`Semantics/` + soundness propagation). The dropped 420→415 dependency edge is correctly
compensated by direct coordination: the planner should mark the dense re-host phase as the
420-unblocking milestone and notify 420 on its completion.

## 10. Recommended Phase Skeleton (not a plan)

1. **Generic flow-frame conformance + totality layer** (no gate): §4 theorems + §3
   characterization, hosted near `ChronicleMonadicBridge`'s generic section or a new
   `Metalogic/Algebraic/FlowFrame.lean`. ~250-400 lines. Verify: `lake build` scoped.
2. **bundleFlowFrame + dense re-host (Option A)** (no gate): definitions + truth lemma re-host
   under the current Omega signature + re-point `Completeness.lean:143`,
   `ChronicleToCountermodelBasic.lean:839`, `CompletenessDedekind.lean:78/81/86`; delete
   `Transfer.lean:568-687`. This is the 420-unblocking milestone — notify 420 on green.
   ~400-600 lines; the planner may split frame-definition from truth-lemma re-host.
3. **[GATE: 414 lands] Discrete rebase**: ReynoldsBridge box case + packaging via the ℤ
   totality characterization; `completeness_discrete` green Omega-free.
4. **[GATE: 414] Dense/Base finalization**: box-case swap in the re-hosted truth lemma;
   `countermodel_dense_enriched`/`completeness_dense`/`completeness` restated; sorried
   `countermodel_discrete` restated (still sorried); `Metalogic.lean` headline docs.
5. **[GATE: 414] Dedekind**: `StrongCompleteness.lean` consequence layer + engine statements;
   `CompletenessDedekind.lean` probes at ℝ over the flow machinery.
6. **Conformance-field handshake with 420** (whenever 420 phase 10 lands, any time after
   phase 1-2 here): confirm the §4 theorems discharge the new fields at 415's frames; adjust
   `bundleFlowFrame` to populate the fields directly.

## Tactic Survey Results

No editable proof sites exist yet for the 414-gated material, and the now-tranche proofs are
elementary, so `lean_multi_attempt`/`lean_hammer_premise` runs are deferred to implementation.
Precedent-based expectations:

| Goal | Expected tactics | Precedent |
|---|---|---|
| comp_iff / serial / segment identity | `rintro`/`exact ⟨…⟩`, `abel`, `Prod.ext` | `multiFamTaskFrameGen`'s own field proofs (ChronicleMonadicBridge.lean:141-158) |
| limit | `exact TaskFrame.limit_of_shift Prod.snd …` | TaskFrame.lean:330 |
| spherical helper | `obtain`/`rcases`, `Set.mem_sInter`, subsingleton elim | none needed beyond core Set API |
| totality characterization equality | `funext`, `propext`, `change WorldHistory.mk …; congr 1` | `multiFamHistoryGen_shift_eq` (ChronicleMonadicBridge.lean:180), `multiFamHistory_shift_eq` (ReynoldsBridge.lean:698) |
| ℤ index arithmetic | `omega` / `abel` | ReynoldsBridge throughout |

Mathlib verification performed: `Set.WellFoundedOn.exists_minimal` / `Set.IsPWO.exists_minimal`
exist (`Mathlib/Order/WellFoundedSet.lean`) for the finite-carrier Spherical route (420's
sites); `Set.Finite.exists_minimal_wrt` does NOT exist under that name in the pinned Mathlib —
do not cite it. No new Mathlib dependencies for 415's own frames.

## Literature Proof Structure

**Source**: JPL paper via `specs/paper-definitions-of-record.md` (anchors §1 above).
**Strategy**: per-class weak completeness by canonical/chronicle countermodel construction, with
frame conformance to the four-axiom `def:frame` and validity per `def:logical-consequence` over
`H_F`.

### Step Map (paper chain → Lean realization under this task)

1. Frame conformance (`def:frame`, all four axioms) — §4 generic discharge theorems; the paper's
   own translation-flow verification is the template.
2. `H_F` nonemptiness: paper route `def:constraints` → `lem:constraint` → `lem:fibers` →
   `lem:admissible` → `lem:step` (*Spherical* consumed here) → `thm:extension` (Zorn) →
   `cor:occurrence`. **415's frames bypass this constructively** (flow lines through any
   prescribed point, §3); the Zorn chain itself is 420 phase 10's acceptance criterion +
   414-adjacent territory for arbitrary frames.
3. Truth lemma per construction — §6.1/6.2 (box case via totality characterization + bundle
   modal transfer; temporal cases via FMCS coherence, preserved).
4. Countermodel packaging: `¬Derivable → MCS ∋ ¬φ → total-history model refuting φ` — §6
   per class; headliners contrapose. Validity is `def:logical-consequence`/`def:frame-validity`
   with box over `H_F` (`def:BL-semantics`).

### Dependencies

Step 3 depends on Steps 1-2's frame; Step 4 on Step 3; Steps 1-2 are 414-independent; Step 3's
final (Omega-free) statement and Step 4 depend on 414's semantics.

### Potential Formalization Challenges

- The `WorldHistory.mk` equality bookkeeping in `multiFamGen_total_eq` (funext/propext across a
  dependent `states` field) — mitigated by two in-repo precedents; risk LOW.
- 414 interface drift: if 414 chooses a subtype rather than a predicate for totality, the
  packaging existentials change shape (∃ over the subtype). Mitigated by the §8 interface note;
  coordinate before Phase 3.
- Option-A double pass on the dense truth lemma box case — bounded, but the planner must budget
  the second pass explicitly so it is not mistaken for churn.

## Appendix: Key Locations (re-verified this dispatch)

- `FormalSystem/Semantics/TaskFrame.lean:177-230` — current 3-field structure; `:302,330,381` —
  `limit_of_succOrder`/`limit_of_shift`/`exists_uniform_radius_of_finite`; `:445-530` — Fib,
  cone, Seg, DirectedFamily, IsFiber, IsSegment; `:563` — staticFrame
- `FormalSystem/Semantics/WorldHistory.lean:94-123` — WorldHistory (domain/convex/states/
  respects_task); `:31-35` — layering deferred to the joint 414 decision
- `FormalSystem/Semantics/Truth.lean:128-137` — Omega-parameterized TruthAt (box at :133);
  `Semantics/Validity.lean:79-133` — valid/SemanticConsequence/satisfiable
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:139-200` —
  multiFamTaskFrameGen/HistoryGen/OmegaGen + shift_eq (generic flow frame, the reuse target)
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:671-757` — ℤ multiFam
  frame/history/Omega/FamIdx/f₀; `:804-940` — truth correspondence (box case rebase site)
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:568-687` — dead singleton-Omega device
  (delete); `:1225-1242` — sorried countermodel_discrete (restate; sole live sorry at :1242)
- `FormalSystem/Metalogic/Algebraic/ParametricCanonical.lean:207` — Limit-violating parametric
  frame (replace on live paths); `RestrictedParametricTruthLemma.lean:286` — re-host source
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean:133,143,196-266` — dense countermodel +
  headliners; `CompletenessDedekind.lean:78/81/86` — ℝ probes;
  `StrongCompleteness.lean:274-308` — Dedekind engine layer
- `specs/420_align_task_frame_with_positive_cone_axioms/plans/02_four-axiom-frame-alignment.md`
  Phase 10 — the blocked phase, its gate, per-axiom target table, and 18-site inventory
