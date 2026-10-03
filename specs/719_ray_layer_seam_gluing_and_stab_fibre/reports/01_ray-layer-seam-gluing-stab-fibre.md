# Research Report: Task #719

**Task**: 719 - ray_layer_seam_gluing_and_stab_fibre
**Started**: 2026-10-03T00:00:00Z
**Completed**: 2026-10-03T00:00:00Z
**Effort**: ~2 hours (research); implementation estimated 5 phases
**Dependencies**: 563 (COMPLETED), 564 (COMPLETED — see Finding 1), 718 (COMPLETED)
**Sources/Inputs**:
- Codebase: `FormalSystem/Semantics/Presheaf/`, `FormalSystem/Semantics/{PartialHistory,TaskFrame}.lean`, `FormalSystem/PlusLanguage/{PlusPasting,PlusTruth,Formula}.lean`
- Probe collection: `specs/evidence/seam-gluing-ray-product/` (all five files)
- `specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`
- Scope inputs: `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` §1; `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` §0, §E
- Task 564's completion record: `specs/564_.../summaries/02_sheaf-clause-and-seam-dedup-summary.md`
- Literature source (out of tree, located and read): `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
- Harness: `scripts/check-module-invariants.sh`, `scripts/check-evidence-probes.sh`
- Five compiled Lean probes written for this report (`lake env lean`, all exit 0)
**Artifacts**: - `specs/719_ray_layer_seam_gluing_and_stab_fibre/reports/01_ray-layer-seam-gluing-stab-fibre.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Task 564 completed today**, hours before this dispatch. The dispatch description's "task 564
  (sheaf clause / star-pasting, still upstream and NOT STARTED)" is stale: `state.json` reads
  `564|completed`, and commits `d3f458796`..`d4d7230d3` landed `Sheaf.lean`,
  `PartialHistory.rel_across_seam`, `TaskFrame.reflection_of_ne` and `PlusPasting.pasteAt`.
  **719's last upstream dependency is discharged and the task is fully unblocked** — but 564 also
  changed the correct implementation of three of 719's five deliverables.
- **The dispatch's choice-freedom claim is false as the probe stands, and I verified the repair.**
  Measured: `Probe718.seamFibreEquiv`, `plusStab_iff_rays`, `seamOmegaEquiv`, `plusStab_iff_omega`
  all depend on `[propext, Classical.choice, Quot.sound]`. `Classical.choice` enters at exactly
  one line — `glue_rel`'s mixed-orientation case, which rewrites with `F.reflection`.
  Substituting 564's new `F.reflection_of_ne` clears it: **`glue_rel`, `glue`, `seamFibreEquiv`
  and `plusStab_iff_rays` all become `[propext, Quot.sound]`** (probe P2, compiled). This is the
  identical repair that made `PlusLanguage.paste` choice-free in 564.
- **The ω-branch cannot be made choice-free and the obstruction is upstream, not in this task.**
  `seamOmegaEquiv`/`plusStab_iff_omega` retain `Classical.choice` via the landed library
  declaration `FrameOver.worldHistoryOfStepPath` (`[propext, Classical.choice, Quot.sound]`),
  reached through `pathFibreEquiv`. The honest record is therefore **split**: the ray layer is
  choice-free; the ℤ/ω-sequence presentation is not, for a reason outside 719's file scope.
- **The four keystone declarations cannot all live in one module.** `plusStab_iff_rays` and
  `plusStab_iff_omega` mention `PlusTruthAt`, so their module must import
  `FormalSystem.PlusLanguage.PlusTruth`, which imports `Semantics.Truth`. That breaks the
  Presheaf cluster's documented "strictly below `Semantics/Truth.lean`" layering (and would
  falsify its README's "no `Classical.choice` on any declaration in the cluster"), though *not*
  its mechanical `assert_not_exists` (verified: importing `PlusTruth` alone does not reach
  `ProofSystem.Axiom`/`DerivationTree`). Recommend a **two-module split**, both under the task's
  `categorical-structure` topic.
- **Name collision**: `FormalSystem.Semantics.Presheaf` already owns `glue`, `glue_unique`,
  `glue_states_le`, `glue_states_not_le` (564's `Sheaf.lean`). The probe's `glue`,
  `glue_state_of_le`, `glue_state_of_not_le` collide or near-collide. The ray operator needs a
  distinct name or sub-namespace.
- **Deliverable 2's paper anchor is stronger than filed, and verified against the source.** The
  paper's `⌢_z` passage (commented out, line 3879) defines it *by applying `app:gluing` to the
  restrictions of ρ and σ to `(−∞, z]` and `[z, ∞)`* — i.e. the paper's own `⌢_z` **is** the
  ray-layer operator, and `PlusPasting.paste` is its two-total-history instance. The ray-layer
  operator is the faithful transcription, not a narrowing.
- **Recommended approach, zero-sorry throughout**: five phases — (1) ray types + PartialHistory/`Beh`
  bridges, (2) the rerouted, choice-free ray gluing with `rel_across_seam` delegation, (3) the
  keystone promotion in two modules + C2 pinning, (4) Deliverable 4's verdict as a README section
  on the `FMP/README.md` model, (5) the E1 probe. No deliverable requires a `sorry`, and no
  deliverable requires a new axiom.

## Context & Scope

Researched: how to land Deliverables 1–5 of task 719 given that four of the five are "promotion
and connection" rather than discovery, what the landed API actually offers after task 564, what
the measured axiom situation really is, where the four acceptance-named keystone declarations can
legally live, and whether the E1 probe is feasible.

Constraints honoured: no determinization substrate was designed or specified (that is 711's,
blocked on device selection by probe E3); no complexity bound is proposed; no width or
tail-period bound is proposed; the `[F.IsRegular]` hypothesis is treated as pinned verbatim; and
`not_finite_width_fmp` is treated as standing untouched.

Evidence tier: **LSP-backed and compile-backed**. Five Lean files were written to the scratchpad
and compiled with `lake env lean` against the live oleans; every axiom claim below is a
`#print axioms` reading, not an inference. The `lean-lsp` search tools were not needed — every
question resolved against the local tree, which is the stronger evidence here.

## Literature Proof Structure

**Source**: Brast-McKie, "The Construction of Possible Worlds",
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` — `app:gluing`
(`\begin{Lthm} \label{app:gluing}`, line 3118, **restored/uncommented**) and the `⌢_z` passage
(line 3879, **still commented out**).
**Strategy**: direct construction by cases, with the cross-seam case discharged by
*Compositionality*.

### Step Map

1. `app:gluing` statement — two **convex** histories `τ₁, τ₂` with domains `X₁, X₂`,
   `X₁ ∩ X₂ ≠ ∅`, agreeing on the overlap, glue to the **unique** convex history on `X₁ ∪ X₂`
   restricting to both. — [Source] `app:gluing`, line 3118
2. Domain `X₁ ∪ X₂` is nonempty and convex, by comparability of any intermediate `b` with a
   fixed `z ∈ X₁ ∩ X₂`. — [Source] `app:gluing` proof, ¶2
3. The task constraint holds at every pair `x ≤ y` in the union: inherited within one `X_i`; in
   the mixed case `x ≤ z ≤ y`, `τ₁(x) ⇒_{z−x} τ(z)` and `τ(z) ⇒_{y−z} τ₂(y)` **compose by
   *Compositionality***. — [Source] `app:gluing` proof, ¶3
4. Negative-difference instances are "covered by the reflection convention". — [Source]
   `app:gluing` proof, ¶3 first sentence
5. Uniqueness: any function on `X₁ ∪ X₂` is determined by its restrictions. — [Source]
   `app:gluing` proof, ¶4
6. `⌢_z` is **defined** as `app:gluing` applied to the restrictions of `ρ` and `σ` to
   `(−∞, z]` and `[z, ∞)`, used to establish the pasting axioms `PS` and `US`. — [Source]
   line 3879 (commented out)
7. Footnote: gluing along an **upward directed** family rests on *Saturation*, with the
   `D = ℚ`, `W = {q : q > 0}`, `r ⇒_x r' ⟺ |r′ − r| ≤ x`, `τ(t) = 1 − t` counterexample. —
   [Source] `app:gluing` footnote

### Dependencies

- Step 3 depends on Step 2 (the fixed `z`) and on *Compositionality*.
- Step 6 depends on Steps 1–5 and is the **only** place the half-line domains appear.
- Step 7 is the recorded reason the colimit route is **out of scope** for this task.

### Potential Formalization Challenges

- **Step 1 at half-line domains**: already discharged. `Probe718.PastRay`/`FutRay` are exactly
  Step 6's two restrictions, and `Probe718.glue_rel` is Steps 2–4 at those domains.
- **Step 4 (reflection convention)**: this is the single line where `Classical.choice` leaks.
  564's `TaskFrame.reflection_of_ne` is the off-zero form that does not leak (verified, probe P2).
- **Step 5 (uniqueness)**: `seamFibreEquiv`'s `left_inv`/`right_inv` already carry it; no separate
  `∃!` is needed, though one may be stated for parity with `Sheaf.lean`'s `glue_unique`.
- **Step 3 is already a shared library asset**: `PartialHistory.rel_across_seam` (564) is exactly
  Step 3, stated once, off totality, with *Compositionality* taken **explicitly**. The ray-layer
  proof should delegate to it (verified, probe P3) rather than re-derive it — that was the entire
  purpose of 564's deduplication.
- **Step 7 must not be attempted here.** The directed case belongs to task 565 by charter.

### Fidelity note for Deliverable 2

The dispatch says `PlusPasting.paste` "is exactly the paper's `⌢_z`". The source text is more
precise: `⌢_z` is *defined through* `app:gluing` applied to **the two half-line restrictions**.
So the paper's primary object is the ray-layer operator, and `paste` is its total-history
instance. Deliverable 2's "narrower" remit is therefore the paper's **primary** case, not a
residue. (`paste_mem_openFutureClass_inter_openPastClass` and `Sheaf.lean`'s `sheaf_clause`
already cite `app:gluing`; the row in `docs/reference/paper-definitions-of-record.md` reads
`app:gluing|LIVE-UNPINNED|...`, "Not pinned: no docstring quotes its text" — so 719 must **not**
quote `app:gluing`'s text unless it intends to pin it, the same decision 564 recorded.)

## Findings

### Codebase Patterns

**Finding 1 — Task 564 is COMPLETED, and it changed three of 719's deliverables.**
`jq` over `specs/state.json`: `564|completed|deps=[563]|type=lean4|topic=categorical-structure`.
Commits today: `d3f458796` (phase 1), `8bcbf51af` (phase 2), `83564b3e1` (phase 3), `be69ca985`
(phase 4), `cbd7fed73`/`d4d7230d3` (completion). 719 itself is `researching`,
`deps=[563,564,718]`, `topic=categorical-structure`. What landed that 719 must consume:

| Declaration | File | Signature / role | Axioms (564's measurement) |
|---|---|---|---|
| `PartialHistory.rel_across_seam` | `Semantics/PartialHistory.lean:209` | `(hcomp : TaskFrame.Compositional F.TaskRel) {σ τ : PartialHistory F} {m m'} (hσm) (hτm') (hmatch) {s s' d} (hs) (hs') (hsm : s ≤ m) (hm's' : m' ≤ s') (hd : d = (m - s) + (s' - m')) : F.TaskRel (σ.states s hs) d (τ.states s' hs')` | `[propext, Quot.sound]` |
| `TaskFrame.reflection_of_ne` | `Semantics/TaskFrame.lean:2686` | `(F) {w u} {d} (hd : d ≠ 0) : F.TaskRel w d u ↔ F.TaskRel u (-d) w` | `[propext]` |
| `PlusLanguage.pasteAt` + 4 lemmas | `PlusLanguage/PlusPasting.lean` | `paste` generalized off totality; `paste_eq_pasteAt` | `[propext, Quot.sound]` |
| `Presheaf.glue`, `glue_states_le`, `glue_states_not_le`, `restrict_glue_left`, `restrict_glue_right`, `glue_unique`, `sheaf_clause`, `sheaf_clause_site`, `compat_iff_match`, `states_eq_of_eq`, `restrictTr_coverLeft`, `restrictTr_coverRight` | `Semantics/Presheaf/Sheaf.lean` (new, 434 lines) | the *Sheaf* clause at the interval site | `[propext, Quot.sound]` |

`PlusLanguage.paste` is now `[propext, Quot.sound]` — `Classical.choice` **cleared** in 564.

**Finding 2 — the measured axiom sets, and the exact leak point.** Compiled against the live
tree (`lake env lean`, probe P1):

| Declaration | Measured axioms |
|---|---|
| `Probe718.PastRay`, `glueFun`, `pastOf` | `[propext]` |
| `Probe718.glue_rel_le_lt` | `[propext, Quot.sound]` |
| **`Probe718.glue_rel`** | **`[propext, Classical.choice, Quot.sound]`** ← leak enters here |
| `Probe718.glue`, `glue_state_of_le` | `[propext, Classical.choice, Quot.sound]` |
| `seamFibreEquiv`, `plusStab_iff_rays`, `seamOmegaEquiv`, `plusStab_iff_omega` | `[propext, Classical.choice, Quot.sound]` |
| `WorldHistory.ofTotal`, `WorldHistory.path`, `IsStepPath`, `PlusTruthAt`, `PlusTruth.stab_iff` | `[propext]` |
| `WorldHistory.ext_state` | `[propext, Quot.sound]` |
| **`FrameOver.worldHistoryOfStepPath`**, `FrameOver.mem_HF_iff_adjacent` | **`[propext, Classical.choice, Quot.sound]`** ← the ω-branch's irreducible leak |
| `PartialHistory.exists_maximal_extension` | `[propext, Classical.choice, Quot.sound]` |

`glue_rel_le_lt` is clean and `glue_rel` is not, so the leak is in `glue_rel`'s own four-case
body — specifically the mixed-orientation case `rw [dif_neg hs, dif_pos hs', F.reflection, neg_sub]`.
`F.reflection` is the unguarded, binder-carrying reflection law; `F.reflection_of_ne` is 564's
off-zero wrapper. **This is the same leak 564 closed in `paste_rel`, and the same fix applies.**

**Finding 3 — the fix is verified, and it clears two of the four acceptance-named declarations.**
Probe P2 replaced the one rewrite with

```lean
· rw [dif_neg hs, dif_pos hs']
  have hne : s' - s ≠ 0 := sub_ne_zero.mpr (by intro h; exact hs (h ▸ hs'))
  rw [F.reflection_of_ne hne, neg_sub]
  exact glue_rel_le_lt b f hseam hs' hs
```

and the whole file still compiles, exit 0, with:

| Declaration | Before | After the reroute |
|---|---|---|
| `glue_rel` | `pcq` | **`[propext, Quot.sound]`** |
| `glue` | `pcq` | **`[propext, Quot.sound]`** |
| `seamFibreEquiv` | `pcq` | **`[propext, Quot.sound]`** |
| `plusStab_iff_rays` | `pcq` | **`[propext, Quot.sound]`** |
| `splice_isStepPath` | — | `[propext, Quot.sound]` |
| `omegaSplitEquiv` | `pcq` | `pcq` (unchanged) |
| `seamOmegaEquiv`, `plusStab_iff_omega` | `pcq` | `pcq` (unchanged) |

(`pcq` = `[propext, Classical.choice, Quot.sound]`, the `docs/theorem-index.md` abbreviation.)

**Finding 4 — the ω-branch's `Classical.choice` is upstream and out of 719's scope.**
`omegaSplitEquiv` is clean in its own `splice` half; the leak arrives through `pathFibreEquiv`'s
use of `FrameOver.worldHistoryOfStepPath`, itself `pcq`. Clearing it would mean rerouting a core
`Semantics/IntNormalForm.lean`-area declaration with many consumers — not a named deliverable
here, and a change whose blast radius crosses several tasks' territory. **Record the split
honestly** (Deliverable 2's explicit instruction) and do not attempt the upstream reroute.

**Finding 5 — module placement: a two-module split is forced.** Constraints measured:
- Every `Semantics/Presheaf/*.lean` ends with
  `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`.
- `FormalSystem/PlusLanguage/PlusTruth.lean` imports `Semantics.Truth`, `PlusLanguage.Formula`,
  `Semantics.TruthClauses`. Probe P5 confirms that importing `PlusTruth` **alone** still
  satisfies that `assert_not_exists` (exit 0) — so the mechanical invariant is not violated.
- But `Semantics/Presheaf/README.md` states the cluster "sits strictly **below**
  `Semantics/Truth.lean`" and that "`#print axioms` reports no `Classical.choice` on any
  declaration in the cluster". Landing `plusStab_iff_omega` (irreducibly `pcq`) and anything
  importing `PlusTruth` into that directory **falsifies both sentences**, which is a C14
  status-claim exposure and a documentation defect even where no gate fires.

Recommended placement, both in `FormalSystem/` under the `categorical-structure` topic (the
acceptance clause names the *topic*, which is the task's `state.json` topic, not a directory):

| Module | Contents | Layer |
|---|---|---|
| `FormalSystem/Semantics/Presheaf/Ray.lean` | `PastRay`, `FutRay`, `.seam`, `pastOf`/`futOf`, the ray gluing operator + its two reading equations + restriction identities + uniqueness, `StabFibre`, `RayPair`, **`seamFibreEquiv`**, and the `PartialHistory`/`Beh` bridges | below `Truth.lean`; keeps `assert_not_exists`; **choice-free** |
| `FormalSystem/PlusLanguage/PlusRayFibre.lean` | **`plusStab_iff_rays`**, `BwdSeq`, `FwdSeq`, `SeqPair`, `ZPathFibre`, `pathFibreEquiv`, `splice`, `omegaSplitEquiv`, **`seamOmegaEquiv`**, **`plusStab_iff_omega`** | above `PlusTruth`; `pcq` in the ω half |

This keeps the Presheaf README's two claims true verbatim and puts each declaration at its
honest layer.

**Finding 6 — name collision in the `Presheaf` namespace.** `Sheaf.lean` already declares
`glue`, `glue_states_le`, `glue_states_not_le`, `glue_unique` in `FormalSystem.Semantics.Presheaf`.
The probe's `glue`, `glue_state_of_le`, `glue_state_of_not_le` would collide / read as near-
duplicates. Also note `check-module-invariants.sh`'s C-check shadowing allowlist exists precisely
for this class of clash. Recommend a sub-namespace (`Presheaf.Ray`) with `Ray.glue`,
`Ray.glue_states_le`, `Ray.glue_states_not_le`, `Ray.glue_unique` — which also makes the parallel
with `Sheaf.lean` legible rather than accidental.

**Finding 7 — the `[F.IsRegular]` acceptance clause collides with C34, and the escape is already
on record.** `check-module-invariants.sh`'s C34b is **enforced**: "a bracketed-binder declaration
whose docstring reads as a constraint claim must carry a marker line". The probe's keystone
docstring says "Nothing beyond *Compositionality* and the reflection convention is used, at any
duration" while carrying `[F.IsRegular]` — promoted verbatim into a docstring, that is a C34b
trigger. And adding a `Constraints consumed: Compositionality` marker over `[F.IsRegular]` (which
also supplies *Saturation*) is a C34a failure unless discharged by **DELEGATION** ("the
declaration's code names a declaration carrying the identical marker list and mentioning no
bundling class") or by field re-export.

Two safe routes, both grounded:
- **(a) 564's route, lowest risk.** Keep the constraint discussion in a module-level `/-! … -/`
  block, whose span C34b does not read, and add no marker. 564 did exactly this ("No
  `Constraints consumed:` marker anywhere. All constraint discussion stays inside `/-!` blocks")
  and passed C34a/C34b.
- **(b) The delegation route, which also pays for itself.** Delegate the seam step to
  `rel_across_seam`, whose `Compositional` hypothesis is explicit and names no bundling class —
  the exact "corollary-with-a-binder-free-twin arrangement" C34a's DELEGATION discharge
  describes. Verified in probe P3 (below).

Either way, **the `[F.IsRegular]` binders on the four statements stay verbatim.** The acceptance
clause constrains *signatures*; C34 constrains *docstrings and markers*. They do not actually
conflict once that distinction is made — this report's recommendation is to make it explicitly in
the plan so no phase "resolves" the tension by weakening a binder.

**Finding 8 — the `rel_across_seam` delegation compiles and is choice-free (probe P3).** With
`PastRay.toPH`/`FutRay.toPH` (the half-line `PartialHistory` wrappers 718's spec described):

```lean
theorem glue_rel_le_lt_deleg [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) {s s' : F.Duration} (hs : s ≤ t) (hs' : ¬ s' ≤ t) :
    F.TaskRel (b.1 ⟨s, hs⟩) (s' - s) (f.1 ⟨s', (not_le.mp hs').le⟩) :=
  PartialHistory.rel_across_seam (F.comp) (σ := b.toPH) (τ := f.toPH)
    (hσm := le_rfl) (hτm' := le_rfl) (hmatch := hseam)
    (hs := hs) (hs' := (not_le.mp hs').le) (hsm := hs) (hm's' := (not_le.mp hs').le)
    (hd := by rw [add_comm]; exact (sub_add_sub_cancel s' t s).symm)
```

`#print axioms` → `[propext, Quot.sound]`. Compiled first try. This closes the deduplication 564
existed to create, at a byte-identical conclusion to the probe's hand proof.

**Finding 9 — Deliverable 1's bridges compile and are choice-free (probe P4).** Two bridges were
needed and both work at `[propext]`:
- `FutRay.toBeh (f : FutRay F 0) (l) (hl : 0 ≤ l) : Beh F l` — the ray-layer-to-`Beh F l`
  restriction Deliverable 1 names. `Beh F l` is
  `{τ : PartialHistory F // ∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l)}`, so the bridge is a direct
  `PartialHistory` construction and the `Iff` is `Iff.rfl`.
- `PastRay.toPH' : PastRayPH F t` where
  `PastRayPH F t := {τ : PartialHistory F // ∀ x, τ.domain x ↔ x ≤ t}` — the `Beh`-mirroring
  presentation. Also `[propext]`.

**Two ray presentations exist and both are needed.** The probe's subtype-of-dependent-function
gives funext equality (load-bearing for `seamFibreEquiv`'s `right_inv`); the
subtype-of-`PartialHistory` gives access to `rel_across_seam`, `restrict_isPartialHistory`,
`eq_restrict_of_extends` and `partialHistory_ext`, and mirrors `Beh`'s own shape exactly. The
recommendation is to **promote the probe's types verbatim** (zero re-proof risk, acceptance-safe)
and **add the `toPH`/`toBeh` bridges as separate declarations** — never to retype the keystone.
Note `partialHistory_ext` currently lives in `Behavior.lean`, with its relocation to
`PartialHistory.lean` an open follow-up from 564; a `Ray.lean` consuming it will consume it from
`Behavior.lean`, adding no new reason to churn that file.

**Finding 10 — E1 is feasible, and will give a *stronger* result than the forward probe, but the
fixture transcription is large.**

The forward probe (`finite-graph-stab-summary.lean`) is 163 lines on a `Bool` complete-graph
fixture built by `FrameOver.ofSlicedStep Rf Rf_fwd Rf_bwd` with `Rf := fun _ _ _ => True`;
`will_iff_allPathsMeet` routes through `PlusTruth.stab_iff` and `FrameOver.worldHistoryOfStepPath`,
and `decide_will` is uniformly **False** at every seam. `decidable_will` is
`Decidable.isFalse (decide_will τ t)`.

Probe710's fixture, which E1 must transcribe:
- `inductive Node | pre : ℕ → Node | x : ℕ → Node | post : ℕ → ℕ → Node`, `deriving DecidableEq`.
- `inductive Step` with `preDown : Step (pre (k+1)) (pre k)`, `preX : Step (pre k) (x k)`,
  `xPost : Step (x k) (post k 0)`, `postNext : Step (post k j) (post k (j+1))`.
- Its own docstring: "**Every state has one or two successors and exactly one predecessor.**"
- Inverses `step_inv_pre`, `step_inv_x`, `step_inv_post` give **backward determinism**.
- `F := FrameOver.ofReflectiveRegular Node (ofStepRel Step) …`, with *Saturation* discharged by
  `TaskFrame.saturation_of_fib_finite fib_finite` — **not** by `ofSlicedStep_isRegular`, which
  requires `[Finite W]` and is therefore unavailable: `Node` is infinite. This is the single
  biggest transcription cost.
- `M : TaskModel F.toTaskFrame := ⟨fun w _ => ∃ k, w = Node.x k⟩` — `p` holds at the `x` states.
- `canon k t s`, `canon_step`, `canon_eq_x_iff`, `path_eq_canon` ("every step path is canonical"),
  `hist_canon` (every `WorldHistory F` is `canon k t`), and the truth lemmas `truth_p`,
  `truth_Fp`, `truth_Pp (s) : PlusTruthAt M σ s Pp ↔ t < s`, plus
  `lt_of_canon_eq_of_lt`/`gt_of_canon_eq_of_gt`/`eq_of_canon_eq_of_eq` (two canon paths agreeing
  at a point — i.e. precisely the "agreeing at the seam" lemmas `⊡` needs).

**The expected E1 result.** The backward operator is
`PlusFormula.stab (PlusFormula.somePast p)`, with
`somePast φ := PlusFormula.snce PlusFormula.top φ` (`Formula.lean:143`), the exact dual of the
forward probe's `someFuture φ := untl top φ` (line 140). Because every node has exactly one
predecessor, the backward root path from a seam node is **unique**, so `⊡(Pp)` at a seam state
collapses to a property of that one chain:

| Seam node | Unique backward chain | Meets the `p`-set (`x` states)? | `⊡(Pp)` |
|---|---|---|---|
| `post k j` | `post k (j−1) … post k 0, x k, pre k, pre (k+1), …` | yes, at `x k` | **True** |
| `x k` | `pre k, pre (k+1), …` | no | **False** |
| `pre k` | `pre (k+1), pre (k+2), …` | no | **False** |

So E1 yields a **state-dependent** decision, strictly more informative than the forward probe's
uniformly-False `decide_will`. Partial corroboration already exists inside Probe710: its
conjunct `C' := □(p → ⊡¬Pp)` is proved true at the fixture by `Φ_true`, which is the `x k` row
above.

**E1's own honest limit, which its header must state.** Section E of 721's spec motivates E1 by
"the finite-width obstruction is located in the *backward* factor". But Probe710's fixture is
**backward-deterministic and forward-branching** — so on this fixture the backward factor is a
singleton and E1 tests the backward dual at its *easiest* instance. The genuinely hard dual test
is a **mirror** fixture (backward-branching, forward-deterministic). E1 on Probe710's fixture is
still exactly what the dispatch specifies and is a real result — it exercises the
unique-predecessor/canonicity machinery the forward probe never touched — but the probe header
must record that the backward factor is degenerate here, or the record over-reads. Recommend
filing the mirror fixture as a follow-up rather than absorbing it.

**A trap to avoid in E1.** `PlusFormula.reflectTime` exists with
`someFuture_reflectTime : (someFuture φ).reflectTime = somePast φ.reflectTime` and
`stab φ.reflectTime = (stab φ).reflectTime` (`Formula.lean:216,245,250`). It is tempting to
"derive" the backward dual by time reflection. **Do not**: (i) there is no semantic transport
theorem for the plus language — `grep -rn 'PlusTruthAt.*reflectTime\|reflectTime.*PlusTruthAt'
FormalSystem/` returns zero hits; and (ii) a time reflection also reverses the *frame*, so any
such transport would prove a statement about the **mirror** fixture, which is the very thing the
time-asymmetry requirement exists to prevent. E1 must argue backward reachability directly.

**Finding 11 — probe wiring is trivial; the WIRED format is a bare path string.**
`scripts/check-evidence-probes.sh` holds `WIRED=( … "seam-gluing-ray-product/stab-fibre-is-ray-product" … )`
— collection-relative paths under `specs/evidence/`, **no `.lean` extension** — plus
`WIRED_REPO=( … )` for full repo-relative paths ("Prefer `WIRED`: reach for `WIRED_REPO` only
with a named blocker recorded beside the entry"). Adding E1 is one line in `WIRED`. The header
also records the constraint the dispatch cites: every probe imports only `FormalSystem`, never
another probe — confirmed, `NoFiniteWidthModel.lean`'s sole import is `import FormalSystem`.

**Finding 12 — the promoted probe should stay wired, unconverted.** The acceptance clause allows
"re-pointed **or** converted as the promotion procedure requires". Leaving
`seam-gluing-ray-product/stab-fibre-is-ray-product` wired as-is is the lowest-risk option and
matches 564's recorded precedent ("All three probes reproduce against the post-task tree at exit
0" — a transcription audit). It breaks no citation, and it leaves a standing independent
reproduction of the keystone outside the build graph. There is, however, a decision to make: if
the promotion applies the reflection reroute, the probe and the library will differ by that one
rewrite. Recommend applying the reroute **in the probe too**, so the two stay byte-comparable and
the probe's own `#print axioms` footer records the choice-free reading.

**Finding 13 — no outside citation of the keystone exists under `FormalSystem/` or `docs/`.**
`germEquiv` and the whole `Presheaf` cluster are absent from `docs/theorem-index.md`, and
`check-module-invariants.sh` names none of the four keystone declarations. The citations that do
exist are in task-directory specs (711's description, 721's §0 row 7, 718's §1) and in the probe
collection's own headers (`finite-graph-stab-summary.lean` explains why it does *not* import the
keystone). So the promotion has a clean citation surface.

**Finding 14 — the gate baseline, measured now, before any edit.**
`bash scripts/check-module-invariants.sh --no-build` → **exit 1, exactly one failure**:

```
FAIL  C15  1 of 240 theorem-index row(s) are not anchored at their declaration
1 CHECK GROUP(S) FAILED
```

Everything else passes, including `C34a` (43 markers honest), `C34b` (no unmarked binder-carrying
declaration reads as a constraint claim), `C33` (646 imports, byte-current root), `C35` (86
seeded declarations resolve at recorded file/keyword/span), `C31`, `C32`, `C9D`, `C36a`, `C37`.
The one failure is the pre-existing `PlusSlicedCertificate.NoFiniteWidth.not_plusValidZTime_neg_Φ`
row that 564 also reported and explicitly declined as another task's territory.

**Finding 15 — the mechanical procedures 719 must follow, read out of the scripts.**

| Obligation | Exact procedure |
|---|---|
| C2 axiom pinning | `scripts/check-module-invariants.sh` holds `AXIOM_BASELINE` (a `read -r -d ''` heredoc of exact `'Name' depends on axioms: [...]` lines) **and** a parallel `AX_SRC` heredoc of `#print axioms <fully-qualified-name>` lines. Both must be extended in the **same order**, and the pass message `"all thirty pinned axiom sets match baseline"` updated. Comparison is exact-string; a single new line in one list without the other is a HARD STOP. |
| C33 root currency | `FormalSystem.lean` is byte-generated, one import per `.lean` under `FormalSystem/`. Regenerate; never hand-edit. |
| C35 citation manifest | `scripts/lean-citation-manifest.json` records declaration **spans**. Inserting a declaration into an existing file shifts spans and fails C35. Fix: `python3 scripts/export-lean-citations.py` (the remedy the gate itself names, and the exact deviation 564's Phase 1 hit). |
| README inventory | `FormalSystem/Semantics/Presheaf/README.md` has a `<!-- BEGIN GENERATED: inventory dir=… -->` table (regenerate) plus hand-maintained `## Key Definitions` / `## Key Results` lists that must gain the new declarations. `readme-lint.sh FormalSystem` is the gate. |
| Other gates 564 ran green | `check-copyright-headers.sh --strict FormalSystem`, `typst-sync-check.sh --counts-only`, `lake build BimodalTest` |
| Known second pre-existing failure | `check-paper-definitions.sh` exits 1 on the `def:BX` drift (paper renamed axiom `SU` to `US`). Measure before editing; do not fix here. |
| Docstring citation style | C20 forbids `file.lean:NNN` citations — cite **declaration names** only. C9 forbids task-number citations under `FormalSystem/`. |

### External Resources

- **Mathlib / Lean**: nothing new is needed. The keystone uses only `Equiv`, `Subtype.ext`,
  `Prod.ext`, `funext`, `sub_ne_zero`, `sub_add_sub_cancel`, `not_le`, `dif_pos`/`dif_neg`,
  `omega`, `push_cast`, `Int.natAbs`. No Mathlib search returned anything the tree does not
  already have; no new import is required beyond `FormalSystem` internals.
- **Paper**: `app:gluing` (restored, line 3118) and the commented `⌢_z` passage (line 3879) in
  `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`. The dispatch cites
  this as `JPL/possible_worlds.tex`; that path does **not** exist in this repository (no `JPL/`
  directory), and the file was located out of tree. Its restoration in the paper remains an author
  decision and is not this task's.
- **Task 711** (`universal_summary_substrate_stab_fibre`, `blocked`): its description confirms it
  now names the universal-summary substrate, with the device to be selected by probe **E3** from
  four live candidates (Safra/Piterman; Safraless à la Kupferman–Vardi FOCS 2005; the
  MSO-over-⟨ℤ,<⟩-plus-Büchi route of Hodkinson–Wolter–Zakharyaschev, APAL 106 (2000); a
  Ramsey-coloured summary), **none asserted**, and that its consumer is re-pointed to 719's
  Deliverable 5. It also records that **no formalization of Safra or Piterman determinization
  exists in any proof assistant**. 719 hands 711 a requirement and must build and select nothing.
- **Task 618** (`path_category_and_conduche_fibration`, `not_started`, `deps=[563,564,616]`):
  load-bearing for Deliverable 5 but unstarted; `grep` finds no `Path(F)`, `FreeCategory` or
  Conduché material under `FormalSystem/`. `docs/reference/paper-definitions-of-record.md` carries
  `def:path-category`, `def:conduche`, `cor:path-fibration` as **DANGLING** rows. So Deliverable 5
  cannot *cite* a landed free-category presentation — it can only state the requirement against
  `def:path-category` as a paper anchor and hand it onward.

### Recommendations

**A sorry-free path exists for every deliverable.** No deliverable needs a `sorry`, and none
needs a new axiom. Four of the five are promotion of already-compiled material; the fifth (E1) is
a transcription plus a case analysis whose mathematical content is largely present in Probe710.
No part of this plan requires the general Extension Theorem, Zorn, or *Saturation*.

**Recommended phase decomposition** (each phase sized to one agent run, ~100–500 lines of
output, each ending at a green `lake build` and a commit):

1. **Phase 1 — `Semantics/Presheaf/Ray.lean`, the ray layer (Deliverable 1).** `PastRay`,
   `FutRay` (probe types verbatim), `PastRay.seam`/`FutRay.seam`, `pastOf`/`futOf`, plus the
   bridges `PastRay.toPH`/`FutRay.toPH` (verified, P3) and `FutRay.toBeh` (verified, P4). Module
   docstring keeps all constraint discussion in `/-! … -/`. Ends with the cluster's
   `assert_not_exists` line. Regenerate `FormalSystem.lean` (C33) and the README inventory.
2. **Phase 2 — the ray-layer gluing operator (Deliverable 2), in `Ray.lean`.** `Ray.glue` and its
   two reading equations under the `Presheaf.Ray` sub-namespace (Finding 6), with the seam step
   **delegated to `PartialHistory.rel_across_seam`** (P3) and the mixed-orientation case routed
   through **`TaskFrame.reflection_of_ne`** (P2). State the two restriction identities, uniqueness
   (`Ray.glue_unique`, parallel to `Sheaf.lean`'s) and totality. Measure and record every
   declaration's axiom set; the target is `[propext, Quot.sound]` throughout.
3. **Phase 3 — the keystone promotion (Deliverable 3), two modules.** `seamFibreEquiv` into
   `Ray.lean`; `plusStab_iff_rays`, `BwdSeq`/`FwdSeq`/`SeqPair`/`ZPathFibre`, `pathFibreEquiv`,
   `splice`, `splice_isStepPath`, `omegaSplitEquiv`, `seamOmegaEquiv`, `plusStab_iff_omega` into
   `FormalSystem/PlusLanguage/PlusRayFibre.lean`. **All four acceptance-named declarations keep
   `[F.IsRegular]` verbatim** — `seamFibreEquiv` at the declaration, the other three under their
   sections' `variable` lines, exactly as the probe has them; the probe's single
   `omit [F.IsRegular] in` covers only `splice_isStepPath` and must stay there. Then extend C2's
   two heredocs with the four fully-qualified names and their **measured** axiom lines
   (`[propext, Quot.sound]` for `seamFibreEquiv` and `plusStab_iff_rays`; `pcq` for
   `seamOmegaEquiv` and `plusStab_iff_omega`) and bump the C2 pass-message count. Regenerate
   `scripts/lean-citation-manifest.json` (C35). Connect to task 566's `H_F ≅ lim Beh(F)(2x)` by a
   docstring pointer only — 566 is `not_started`, so no limit presentation can be cited as landed.
4. **Phase 4 — Deliverable 4's verdict, recorded in the library.** A README section on the
   proven model of `FormalSystem/Metalogic/Decidability/FMP/README.md`'s "### The finite-carrier
   route is refuted, not merely open" — a named claim plus explicitly stated limits. Content: the
   ray gluing **generalises the role** of `BiLasso/Orbit.lean`'s `extend_periodic` /
   `extend_periodic_of_icc` (an effective, choice-free construction standing in for a Zorn
   argument, now for every pair of agreeing half-line rays at a regular frame) **without
   subsuming** the general Extension Theorem, whose input is an arbitrary `PartialHistory` and
   which routes through `PartialHistory.exists_maximal_extension` (measured `pcq`). State the gap
   precisely: a pair of half-line rays covers all of `F.Duration` and meets in exactly one point;
   an arbitrary `PartialHistory`'s `domain` is an arbitrary predicate with neither property, so
   `glue`'s total case split has no analogue there. Also record, as the positive half of the same
   verdict, the measured choice-freedom of the ray path and the measured `Classical.choice` of the
   ω path with its upstream cause (Finding 4). Place in `Semantics/Presheaf/README.md` (and/or a
   `/-! … -/` block in `Ray.lean`), not only in a plan or summary.
5. **Phase 5 — the E1 probe (Deliverable 5).** One new file under
   `specs/evidence/seam-gluing-ray-product/`, one new `WIRED` line. Because the fixture
   transcription (Probe710 lines ~48–390: `Node`, `Step`, the six inverse lemmas, `fwdList`/
   `bwdList`/`fib_finite`, the `ofReflectiveRegular` frame with `saturation_of_fib_finite`, `M`,
   `canon`, `path_eq_canon`, `hist_canon`) is itself ~350 lines, consider splitting this phase in
   two: **5a** fixture transcription to a green `lake env lean`; **5b** the backward summary
   `AllBwdPathsMeet`, `pastStab_iff_allBwdPathsMeet` mirroring `will_iff_allPathsMeet` clause for
   clause, the three-row decision table (Finding 10), `decide_past_stab` and a `Decidable`
   instance. **Qualify every citation of `decide_will`** as `Probe718FiniteGraph.decide_will` or
   `Probe718PathQuantifier.decide_will` — the bare name is ambiguous across the collection.
   **No automata.** The header must record the degenerate-backward-factor limit (Finding 10) and
   the `reflectTime` trap (Finding 10's trap note). Deliverables 1–4 must not wait on this phase.

**Deliverable 5's requirement for task 711, to be stated and handed over, not built.** From
`Probe718PathQuantifier.exists_ne_stab`/`exists_ne_universal` (the existential per-path summary is
True everywhere while the real value of the stability-of-eventually formula is False everywhere,
`Probe718PathQuantifier.decide_will`), plus `plusStab_iff_rays`/`plusStab_iff_omega` presenting
`⊡` as a quantifier over a **product of two path spaces**, the requirement is: a summary device
that is **universal over both factors**, hence complementation-shaped, hence not supplied by any
nondeterministic per-path summary — and, by Finding 10, one whose **backward** factor is
summarised on its own terms rather than by time-reversal of the forward one. State that; assert
nothing about which of 711's four candidates supplies it; land no complexity claim (the CTL*
2EXPTIME lower bound remains the sanity check on any future bound).

**Things the plan must explicitly forbid**, each because this research found a live way to get it
wrong:
- Re-deriving `paste`, `pasteAt`, `Presheaf.glue`, `sheaf_clause` or `rel_across_seam`.
- Weakening any of the four keystone statements to a bare `TaskFrame`, or strengthening them —
  including "fixing" C34 by replacing `[F.IsRegular]` with an explicit `Compositional` hypothesis
  (564's own choice, correct there, a **defect** here).
- Naming the ray operator `glue` in the `Presheaf` namespace.
- Landing `plusStab_iff_omega` inside `Semantics/Presheaf/` without amending that README's two
  claims — or landing it there at all, given the recommended split.
- Deriving E1 by `reflectTime`.
- Beginning any determinization or universal-summary substrate, under any name.
- Attempting the `FrameOver.worldHistoryOfStepPath` choice reroute (out of scope, wide blast
  radius).
- Attempting the colimit-of-bounded-sections route or anything *Saturation*-dependent (565's).

## Decisions

1. **Treat the dispatch's "564 NOT STARTED" as stale and 564 as a consumable dependency.**
   Grounded in `state.json` and six commits from today.
2. **Treat the dispatch's "choice-free as probed" claim as false-as-written and repair it.** The
   measured axiom sets (Finding 2) settle it. The repair is 564's own and is verified (Finding 3).
   This is reported as a correction, not silently patched.
3. **Split the keystone promotion across two modules** rather than violate the Presheaf cluster's
   documented layering and choice-freedom claims (Finding 5). Acceptance's "under the
   categorical-structure topic" is read as the task's `state.json` topic, which both modules
   satisfy.
4. **Promote the probe's types verbatim; add bridges rather than retype.** Keeps `right_inv`'s
   funext argument intact at zero re-proof risk (Finding 9).
5. **Delegate the seam step to `rel_across_seam` and reroute the reflection.** Both verified; the
   delegation additionally buys C34a's DELEGATION discharge should a marker ever be wanted
   (Findings 7, 8).
6. **Keep the promoted probe wired, and apply the reroute to the probe as well**, so the record
   and the library stay byte-comparable (Finding 12).
7. **E1 on Probe710's fixture, with its degenerate-backward-factor limit stated in the header.**
   The dispatch names this fixture; the honest limit is recorded rather than the fixture swapped
   (Finding 10).
8. **Report the two pre-existing gate failures as baseline rather than fix them** (Finding 14),
   following 564's accepted precedent. See the Risks section for the tension with acceptance's
   "ALL CHECKS PASSED".
9. **Deliverable 4 is closed affirmatively with an explicit gap statement, not by reasoned
   exclusion.** The gap is nameable and precise (Phase 4), so the stronger close is available.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| **Acceptance demands `check-module-invariants.sh` "ALL CHECKS PASSED", but the measured baseline is exit 1 on one pre-existing C15 row** (Finding 14). | Measure and record the baseline before the first edit, as 564 did and was accepted on. The row is one unanchored `docs/theorem-index.md` entry for `PlusSlicedCertificate.NoFiniteWidth.not_plusValidZTime_neg_Φ`, explicitly declined as another task's territory. Two options for the plan: report it as pre-existing (recommended, precedent-backed), or anchor that one row incidentally. Either way the task must not be judged red for it. |
| C2's exact-string baseline is a HARD STOP; a half-applied edit bricks the gate. | Extend `AXIOM_BASELINE` and the `AX_SRC` heredoc in the same commit, in the same order, with the **measured** lines (not assumed `pcq`), and update the pass-message count. Verify by running the gate with `--no-build` off. |
| C35 fails on any insertion into a span-recorded file. | Run `python3 scripts/export-lean-citations.py` and commit the regenerated manifest; never hand-edit it. 564 hit exactly this. |
| C34b fires on the keystone docstring (Finding 7). | Keep constraint discussion in `/-! … -/` module blocks (564's verified route). If a marker is nonetheless wanted, the `rel_across_seam` delegation supplies C34a's DELEGATION discharge. |
| Name collision with `Presheaf.glue` (Finding 6). | `Presheaf.Ray` sub-namespace. |
| `plusStab_iff_omega` keeps `Classical.choice`, which could be read as a regression in a cluster documented choice-free. | Place it outside that cluster (Finding 5) and record the cause explicitly: `FrameOver.worldHistoryOfStepPath`, a pre-existing library declaration, measured `pcq` (Finding 4). |
| E1's fixture transcription is ~350 lines, larger than the dispatch's "one file" phrasing suggests. | Split Phase 5 into 5a (fixture, green compile) and 5b (the backward summary). Budget accordingly; `ofSlicedStep_isRegular` is **unavailable** because `Node` is infinite, so the `ofReflectiveRegular` + `saturation_of_fib_finite` construction must be transcribed in full. |
| E1 could be mistaken for the hard backward test. | Header records that Probe710's fixture is backward-deterministic, so the backward factor is a singleton; the mirror fixture is the hard test and is a follow-up, not absorbed here. |
| `scripts/check-evidence-probes.sh` is declared in the `file_scope` of 710 and 720 as well as needed by 719's E1 — a three-way concurrency hazard. | E1 adds exactly one line to `WIRED`. Add it in its own commit, re-read the file immediately before editing, and do not reorder existing entries. |
| Task 566's limit presentation (`H_F ≅ lim Beh(F)(2x)`) is `not_started`, and 618's free-category presentation does not exist. | Connect by docstring pointer only; cite `def:path-category`/`cor:path-fibration` as **DANGLING** paper anchors, and never as landed results. |
| Deliverable 2 could drift into pinning `app:gluing`. | The row's `LIVE-UNPINNED` status rests on "no docstring quotes its text". Cite `app:gluing` as a pointer; do not quote it (564's recorded decision). |

## Tactic Survey Results

Five standalone Lean files were compiled with `lake env lean` against the live oleans. All exited
0. These are the measurements behind Findings 2–4, 8 and 9, and the `#print axioms` readings are
quoted verbatim from the compiler.

| Goal | Tactic / construction | Result | Premises / config |
|---|---|---|---|
| **P1** Localize `Classical.choice` in the keystone chain | `#print axioms` on 11 declarations | **success** — leak isolated to `glue_rel` (clean at `glue_rel_le_lt`) and, independently, to `FrameOver.worldHistoryOfStepPath` | `head -134` of the probe + an `#print axioms` block |
| **P2** Clear `Classical.choice` from `glue_rel` | `rw [F.reflection_of_ne hne, neg_sub]` in place of `rw [F.reflection, neg_sub]`, with `hne : s' - s ≠ 0 := sub_ne_zero.mpr (by intro h; exact hs (h ▸ hs'))` | **success, first try** — `glue_rel`, `glue`, `seamFibreEquiv`, `plusStab_iff_rays` all drop to `[propext, Quot.sound]` | `TaskFrame.reflection_of_ne` (landed by 564) |
| **P2′** Same, whole-file | full probe with the one rewrite substituted, `#print axioms` on 7 declarations | **success** — ω-branch unchanged at `pcq`, confirming the two leaks are independent | — |
| **P3** Delegate the seam step to the landed shared lemma | `PartialHistory.rel_across_seam (F.comp) (σ := b.toPH) (τ := f.toPH) …` with named arguments | **success, first try** — `[propext, Quot.sound]` | needs `PastRay.toPH`/`FutRay.toPH`; `hd := by rw [add_comm]; exact (sub_add_sub_cancel s' t s).symm` |
| **P4** Deliverable 1's bridges | `FutRay.toBeh` by direct `PartialHistory` construction with `fun _ => Iff.rfl`; `PastRay.toPH'` into the `Beh`-mirroring subtype | **success, first try** — both `[propext]` | `Beh F l = {τ // ∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l)}` |
| **P5** Layering legality of importing `PlusTruth` under the Presheaf cluster's invariant | `import FormalSystem.PlusLanguage.PlusTruth` + `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree` | **success** (exit 0) — the mechanical invariant survives; only the README's prose claims do not | — |
| Gate baseline | `bash scripts/check-module-invariants.sh --no-build` | **exit 1**, exactly one pre-existing failure (C15, 1 of 240 rows); C34a/C34b/C33/C35/C31/C32/C36a/C37/C9D all PASS | measured before any edit |

Not attempted, deliberately: `aesop`, `simp`, `omega`, `decide`, `norm_num`, `exact?`,
`lean_hammer_premise`. Every proof obligation surfaced here was discharged by a named landed
lemma or a one-line rewrite; no goal in this task's scope is a search target, and APOLLO-style
decomposition has nothing to decompose — the mathematics is already written and compiled. The
`lean-lsp` rate-limited search tools (`leansearch`, `loogle`, `leanfinder`, `state_search`) were
likewise not needed: no missing Mathlib lemma was identified at any point.

## Context Extension Recommendations

- **Topic**: The reflection-law choice leak as a repeatable repair.
  **Gap**: `F.reflection` silently pulls `Classical.choice`; `TaskFrame.reflection_of_ne` does
  not. This has now bitten twice (564's `paste_rel`, and the keystone probe) and is not
  documented anywhere an agent would look.
  **Recommendation**: add a short section to `.claude/context/project/lean4/` (or
  `FormalSystem/Semantics/TaskFrame.lean`'s module docstring) recording "if a mixed-orientation
  task-relation rewrite leaks `Classical.choice`, use `reflection_of_ne` with a `≠ 0` side
  condition", with the measured before/after axiom sets.
- **Topic**: The C2 axiom-pinning procedure.
  **Gap**: pinning requires synchronized edits to two heredocs plus a count in a pass message,
  and the comparison is exact-string. The procedure is discoverable only by reading ~90 lines of
  `check-module-invariants.sh`.
  **Recommendation**: a short `docs/development/` or `.claude/context/project/lean4/` note giving
  the three-edit recipe and the HARD STOP semantics.
- **Topic**: Probe promotion procedure.
  **Gap**: "re-pointed or converted as the promotion procedure requires" names a procedure that
  is not written down anywhere; this report had to infer it from 564's transcription-audit
  precedent and the `WIRED`/`WIRED_REPO` header.
  **Recommendation**: record the promotion procedure (keep wired, keep byte-comparable, audit
  reproduction at exit 0) beside the `WIRED` arrays in `scripts/check-evidence-probes.sh`.

## Appendix

### Searches and commands of record

- `jq -r '.active_projects[] | select(.project_number==…)' specs/state.json` — statuses for 563,
  564, 565, 566, 618, 711, 719
- `git log --oneline --name-only` over 564's six commits
- `lake env lean <scratchpad>/{keystone,axprobe,reroute,full-reroute,deleg,behbridge,omega-loc,layer}.lean`
  — the seven compiled probes behind the Tactic Survey table
- `bash scripts/check-module-invariants.sh --no-build` — gate baseline
- `awk '/^WIRED=\(/,/^\)/' scripts/check-evidence-probes.sh`, `awk '/^WIRED_REPO=\(/,/^\)/' …`
- `awk '/^# C34 asserts hypothesis honesty/,/^# C35/' scripts/check-module-invariants.sh`
- `sed -n '1053,1200p' scripts/check-module-invariants.sh` — C2's baseline and `AX_SRC` heredocs
- `grep -rn 'PlusTruthAt.*reflectTime\|reflectTime.*PlusTruthAt' FormalSystem/` — zero hits
- `grep -rn 'Path(F)\|freeCategory\|FreeCategory\|Conduche' FormalSystem/ docs/` — paper-record
  rows only, no Lean
- `grep -n 'frown' /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` —
  lines 3879, 3882, 3884, all `%`-commented
- `sed -n '3118,3150p'` of the same file — `app:gluing`'s restored statement, proof and footnote

### References

- `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` §1
- `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` §0 (rows 6, 7, 10,
  11, 13, 19, 20, 23, 24, 26), §E
- `specs/564_sheaf_clause_gluing_and_starpasting_generalization/summaries/02_sheaf-clause-and-seam-dedup-summary.md`
- `FormalSystem/Semantics/Presheaf/README.md`, `FormalSystem/Metalogic/Decidability/FMP/README.md`
- `docs/theorem-index.md` ("How to read a row": `pcq`, `pinned:C2`/`pinned:C14`, no `file:line`)
- `docs/reference/paper-definitions-of-record.md` (`app:gluing` row; `def:path-category`,
  `def:conduche`, `cor:path-fibration` DANGLING rows)
- `specs/evidence/seam-gluing-ray-product/{stab-fibre-is-ray-product,finite-graph-stab-summary,path-quantifier-alternation,mosaic-germ-amalgamation,stab-depth-stratification}.lean`
- `specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`
