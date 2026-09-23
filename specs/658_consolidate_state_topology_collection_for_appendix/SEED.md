# Seed Report: The State-Space Topology Collection

**Type**: Seed report — written by the orchestrating session as input to this task's research
round, not by a research agent. It is a starting inventory and a specification of what the
manuscript needs, assembled from the completed topology research, the completed frame refactor,
and a direct reading of the live tree and the manuscript. **Verify it; do not re-derive it.**

**Status of its claims**: every declaration named below was read out of the live tree at the time
of writing (`grep` over the two topology modules). Every manuscript site was read out of
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`. Nothing here is
recalled from memory. Where a claim is inherited from the topology research report rather than
re-checked, it says so.

**Prior artifacts this builds on** (read them; they are not summarized away here):
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/reports/01_topology-characterizing-limit.md`
  — the full research report: the characterization, the four-state funnel, the fineness
  correction, the Q5 recommendation with drafted LaTeX, and the Q6 naming check.
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/` — six sorry-free probe
  files. **`TwoOrigins.lean` is the source for Deliverable (1); it contains compiled results that
  were never promoted.**
- `specs/656_refactor_task_frames_general_with_frame_constraints/reports/01_general-frames-regular-constraints.md`
  — the refactor research, including the `IsRegular` architecture the topology now sits on.

---

## 1. The decision this collection serves

The user has **ratified option (a)** of the topology research. The manuscript will:

- replace the subbasis topology `𝒯_F` by the cone-neighbourhood topology `𝒩_F` in
  `def:task-topology`;
- restate `app:topology-t1` as a **biconditional** (`Limit ⟺ T1`) under *Seriality* alone;
- keep `app:topology-r0` verbatim;
- add a history-continuity lemma;
- record the old subbasis topology in a footnote, with the four-state funnel as the reason it
  was dropped.

This is settled and is not to be reopened. Drafted LaTeX for every item is in §5 of the topology
research report. The decision record is at
`specs/655_topology_characterizing_limit_nbhd_vs_subbasis/.decisions.json` and
`specs/656_refactor_task_frames_general_with_frame_constraints/.decisions.json`.

**What this task supplies**: not the LaTeX, which exists, but the *certified collection the
appendix cites* — every statement the refactored appendix makes should correspond to a named,
compiled, standard-axioms declaration a reader can look up.

## 2. The manuscript sites

Read directly from `possible_worlds.tex`. Line numbers are given only as a convenience and only
because this file lives under `specs/`; **cite by label in any deliverable outside `specs/`.**

| Site | What it is | Fate under option (a) |
|---|---|---|
| `def:task-topology` (`:2881`) | Defines `𝒯_F` by Basic Opens + closure; also carries *Closure*, *T1*, *R0* clauses | Basic Opens and Topology clauses **replaced** by the one-clause Open Sets definition; Closure/T1/R0 kept verbatim |
| `app:topology-t1` (`:2896`) | "`𝒯_F` is T1 for every task frame" | **Restated as a biconditional** under Seriality |
| `app:topology-r0` (`:2914`) | R0 corollary | **Unchanged** — its proof uses only T1 and the definitions |
| Frame-constraints footnote (`:994`) | "The set of *basic opens* … generates a topology … proves in app:topology-t1 that `𝒯_F` is *T1*" | Both sentences rewritten |
| Dynamical-systems sentence (`:1675`) | "the task relation induces a canonical topology … *T1* for every task frame" | True as written; optionally sharpened to "exactly when *Limit* holds" |
| Relocation comment (`:3914`) | Records that the three labels moved into `app:TaskSemantics` | No change |
| Formalization claim (`:1877`) | "The frame correspondence, determinism, and soundness results of `app:TaskSemantics` and `app:Soundness` are formalized in the Lean 4 repository" | **Check this.** The topology now *is* formalized; the sentence enumerates what is formalized and should be re-read once this task lands |

A grep of the manuscript found **no other live citation** of the three topology labels. The
appendix section is `app:TaskSemantics` (`\subsection{Task Semantics}`, `:2811`).

## 3. What the library already carries

Both modules landed in the frame refactor and are green: `lake build --wfail` exit 0, 2,782 jobs,
zero warnings; `check-module-invariants.sh` ALL CHECKS PASSED; sorry count 0.

### 3.1 `FormalSystem/Semantics/StateTopology.lean` (629 lines)

The general-relation layer, stated over bare `R : W → D → W → Prop`, then a frame-level layer.

**Definitions**: `coneTopology`, `nbhdTopology`, `coneFilter`, `IsHistory`, `Triangle`,
`QuickFwd`, `NoOneWay`; frame-level `coneTop`.

**The characterization and its neighbours**:
- `t1Space_nbhdTopology_iff_limit` — **the headline**: `Limit ⟺ 𝒩_F is T1`, no frame condition
  consumed in either direction.
- `limit_eq_iff` — the paper's equality form as `Limit ∧ ∀ w x, 0 < x → w ∈ (w)_x`.
- `mem_cone_self` — the nullity half of that.
- `coneTopology_le_nbhdTopology` — **`𝒯_F` is finer**, given `w ⇒_0 w`. This is the correction to
  the earlier "incomparable" claim.
- `t1Space_coneTopology_of_limit` — the old `app:topology-t1`, now a corollary; **does not consume
  the reflection convention**, unlike the manuscript's current proof.
- `r0Space_nbhdTopology_of_limit`, `r0Space_coneTopology_of_limit`.

**Structure of `𝒩_F`**: `nbhdTopology_isOpen_iff`, `nbhdTopology_isClosed_iff` (closed = closed
under arbitrarily short tasks), `discreteTopology_nbhdTopology_iff` (pointwise dwell time),
`isBasis_cone` (the cones at a point are a filter base), `mem_coneFilter`,
`nbhdTopology_eq_mkOfNhds`, `coneFilter_le_nhds`, `nbhdTopology_le_of_coneFilter_le_nhds`
(`𝒩_F` is the *finest* topology in which every neighbourhood of `w` contains a cone at `w`).

**Histories**: `continuous_nbhdTopology_of_history` — every history is continuous, **no frame
axiom consumed**; `finalTopology_le_nbhdTopology`.

**Cone-openness**: `isOpen_cone_of_triangle`, `coneTopology_eq_nbhdTopology_of_triangle`,
`coneTopology_eq_nbhdTopology_iff` (cone-openness is the necessary and sufficient condition).

**The gap theorem**: `limit_of_t1Space_coneTopology` — under reflection, composition and
`NoOneWay`, `𝒯_F` T1 implies `Limit`. So the entire gap is one-way instantaneous pairs.

**Real frames**: `nbhdTopology_eq_real`, `coneTopology_eq_nbhdTopology_real`,
`not_discreteTopology_real`.

**Frame level**: `instance stateTopology` (the sole `TopologicalSpace` on a state space, `𝒩_F`),
`t1Space_iff_limit`, `instance instT1SpaceOfRegular`, `coneTop` (`𝒯_F` as a plain `def`, no
instance), `coneTop_le_stateTopology`, `t1Space_coneTop`, `r0Space_coneTop`,
`continuous_of_history`.

### 3.2 `FormalSystem/Semantics/StateTopology/Counterexamples.lean` (1,220 lines)

**ℤ layer**: `cone_int_one`, `nbhdTopology_isOpen_iff_int`, `limit_int_iff`,
`discreteTopology_nbhdTopology_int_iff` — over ℤ both topologies are the partition topology of
`⇒_0`, and Limit ⟺ discrete ⟺ T1.

**The four-state funnel** (`funnelRel`, `funnelFrame`) — the acceptance witness. Satisfies
*Seriality*, *Compositionality* and *Saturation* (`funnel_saturation`, via
`saturation_of_finite`), fails *Limit*. Carries `mem_cone_funnelRel`, `funnelRel_not_limit`,
`funnel_not_limit`, `funnelRel_singleton_eq_biInter_cone`,
`funnelRel_discreteTopology_coneTopology`, **`funnel_t1Space_coneTopology`** (the pair
`funnel_not_limit` + `funnel_t1Space_coneTopology` is the statement that was unwritable before the
refactor), `funnelRel_nbhdTopology_eq_top`, `funnel_not_t1Space`,
`funnelRel_not_isOpen_cone`, `funnel_one_way_pair`, the four history lemmas plus
`funnel_sep_of_history` (**`sep` holds while Limit fails**, so `rev_sep` is one-directional), and
`funnel_not_continuous_coneTopology` (a history that is not `𝒯_F`-continuous).

**The two-origin half-line** (`TwoOrigins`, `D = ℝ`) — T1 but not Hausdorff. Carries
`rel_serial`, `rel_compositional`, `rel_limit`, `rel_reflection`, the frame-level
`frame_serial`/`frame_compositional`/`frame_limit`/`frame_t1Space`, `t1Space_nbhdTopology`,
`mem_cone_origin`, `not_t2Space_nbhdTopology`, `frame_not_t2Space`.

**The hedgehog** (`Hedgehog`, `D = ℝ`) — separates `𝒩_F` from the final topology. Carries
`rel_serial`, `rel_compositional`, `rel_limit`, `rel_reflection`, frame-level counterparts,
`hedgehogOpen`, `not_isOpen_nbhdTopology_hedgehogOpen`, the three history lemmas
(`history_single_ray`, `history_centre_past`, `history_reach`),
`isOpen_preimage_hedgehogOpen_of_history`, **`finalTopology_ne_nbhdTopology`**,
`c_mem_cone_p`, `singleton_c_eq_inter_cone`, `isOpen_coneTopology_singleton_c`,
`not_continuous_coneTopology_history`.

## 4. The gaps — verified against the live tree

Each was checked by `grep` over both modules at the time of writing. **Re-verify before acting:
the tree may have moved.**

### Gap A — the two-origin cone-topology side was never promoted *(this task, Deliverable 1)*

`grep` finds **zero** occurrences of `not_triangle`, `isOpen_nbhdTopology_cone`, and
`not_t2Space_coneTopology` in the library. The three occurrences of
`coneTopology_eq_nbhdTopology` are all the *general* theorems in `StateTopology.lean`
(`_of_triangle`, `_iff`, `_real`), none of them the two-origin instance.

This is a **promotion gap, not a mathematical one**. All four results were compiled sorry-free in
`specs/655_.../probes/TwoOrigins.lean`:

- `not_triangle_RTO` — the `Triangle` condition **fails** on this frame (the mixed-sign path
  `o true ⇒₁ p ⟨1⟩ ⇒₋₁ o false` joins the two origins, which no single task does, since
  `RTO (o b) t (o b')` is `b = b'` at every duration). This is what makes **`Triangle` sufficient
  but not necessary** for cone-openness — a result with no home in the library today.
- Four cone-membership lemmas with explicit radii (`min t (x−t)`, `x − |s−t|`, `x − t`) feeding
  `isOpen_nbhdTopology_cone_RTO`.
- `coneTopology_eq_nbhdTopology_RTO`.
- `not_t2Space_coneTopology_RTO`.

**Why the appendix needs this.** With `frame_not_t2Space` alone, the manuscript can say the
neighbourhood topology is not Hausdorff here. With the promoted results it can say the two
topologies *coincide* on this frame and neither is Hausdorff — i.e. **non-Hausdorffness is a
property of the frame, not an artefact of which topology one picks.** That is the strongest and
most quotable thing the witness has to offer, and it is currently unavailable.

### Gap B — the hedgehog inequality is bracketed but unnamed *(this task, Deliverable 2)*

`isOpen_coneTopology_singleton_c` gives `{c}` open in `𝒯_F`; no cone at `c` is contained in `{c}`,
which the cone facts supply. The inequality `coneTopology ≠ nbhdTopology` on the hedgehog is not
itself a declaration. The topology research flagged exactly this (§2.4, "the *named* inequality
was not compiled"). It should be cheap.

### Gap C — Saturation for the two witnesses *(SIBLING TASK, not this one)*

Neither `TwoOrigins` nor `Hedgehog` claims *Saturation*; both docstrings say so deliberately
(`:606`, `:774`, `:850`, `:1010`), and **neither is an `IsRegular` instance**. Consequence for the
appendix: the T1-non-Hausdorff claim is currently a claim about a *structure satisfying three of
the four constraints*, not about a *task frame*. Record this in the support table as a pending
dependency; do not attempt it here.

### Gap D — R0 without Limit *(SIBLING TASK, not this one)*

`grep` finds no `r0Space_of_not_limit`. The topology research recorded it as a paper argument only
(§3.4), labelled UNVERIFIED. Same treatment: record the dependency, do not attempt it.

## 5. The appendix support table — the headline deliverable

Produce a table with one row per element the refactored appendix will contain. Required columns:

| Column | Content |
|---|---|
| Manuscript element | Label, or a quotable phrase for unlabelled prose |
| Statement | What the appendix will assert |
| Certifying declaration | Fully qualified Lean name |
| Axiom profile | From `lean_verify` / `#print axioms` |
| Status | `certified` / `pending-sibling` / `not-certified` |

Rows the table must at minimum cover, with the declarations that look right today (**verify each
— several are the seed's inference, not a checked match**):

| Manuscript element | Likely certifier |
|---|---|
| `def:task-topology` is a topology (three axioms) | the three fields of `nbhdTopology` |
| `app:topology-t1` biconditional | `FrameOver.t1Space_iff_limit`, `t1Space_nbhdTopology_iff_limit` |
| The equality form `⋂_{x>0}(w)_x = {w}` | `limit_eq_iff` + `mem_cone_self` |
| `app:topology-r0` | `r0Space_nbhdTopology_of_limit` / `r0Space_coneTop` |
| New continuity lemma | `continuous_nbhdTopology_of_history`, `continuous_of_history` |
| Footnote: old topology is finer | `coneTopology_le_nbhdTopology` |
| Footnote: old topology's T1 does not characterize Limit | `funnel_not_limit` + `funnel_t1Space_coneTopology` |
| Footnote: the funnel's cone computation | `mem_cone_funnelRel`, `funnelRel_singleton_eq_biInter_cone` |
| T1 but not Hausdorff inside the class | `frame_not_t2Space` (+ Gap A for the stronger form; Gap C for "task frame") |
| Over ℤ both topologies are the partition topology | the four `*_int*` declarations |
| On the named real frames both are Euclidean | `nbhdTopology_eq_real`, `coneTopology_eq_nbhdTopology_real` |
| The gap is exactly one-way pairs | `limit_of_t1Space_coneTopology`, `funnel_one_way_pair` |

**Flag explicitly** any statement the drafted LaTeX in §5 of the topology research report makes
that no declaration certifies. That list is the real output: it tells the user what to hedge.

## 6. Organization questions to answer (Deliverable 3)

Open questions for the research round, not prejudged here:

1. Is the general-relation / frame-level split in `StateTopology.lean` clean enough that an
   appendix citing "the Lean declaration" is citing the right layer? The frame-level names
   (`t1Space_iff_limit`, `coneTop`) are thin wrappers; is that the right shape?
2. `Counterexamples.lean` is 1,220 lines carrying four unrelated witnesses. Should the funnel,
   two-origin and hedgehog namespaces be separate modules? Weigh against import cost and against
   the C-invariant/aggregator wiring each new module requires.
3. Do `docs/theorem-index.md` rows cover the topology at citation granularity? A manuscript
   footnote citing the funnel needs the funnel's declarations findable.
4. Naming: the library uses `nbhdTopology`/`coneTopology` for `𝒩_F`/`𝒯_F`. Once the manuscript
   calls `𝒩_F` simply "the topology `𝒯_F`" (option (a) reuses the symbol), is the Lean naming
   still transparent, or should the docstrings carry an explicit symbol-correspondence note?

## 7. Constraints that bit previous tasks — do not rediscover them

- **Import weight.** A topology-carrying module reachable from `FormalSystem/Semantics.lean`
  routes Mathlib order/topology instances into the whole library. This has caused a `Preorder ℤ`
  diamond **twice**: once in the time-indexed-frames task (fixed by keeping the sharpness module
  out of the aggregator; the generated root imports it directly, since the root is a leaf), and
  once in the countable-ℝ rigidity task (fixed by pinning the instance at `finOrderEmbInt`). The
  frame refactor adopted the import-weight lever as policy: `StateTopology.lean` and
  `Counterexamples.lean` stay out of `Semantics.lean`. **Keep it that way.**
- `warn.classDefReducibility` is **fatal under `--wfail`**. The refactor handles it with a
  module-scoped `set_option` plus a justification comment, deliberately not
  `@[instance_reducible]` (which would change unfolding eagerness). Note that C29/C30 both key on
  the literal `linter.` prefix, so this `set_option` is outside both checks.
- At an ℝ-carrier frame the frame's `stateTopology` instance and Mathlib's coexist on the same
  underlying type. That is an **ambiguity, not a diamond**; the real-frame theorems already
  navigate it.
- The generated root `FormalSystem.lean` is regenerated with `lake exe mk_all --lib FormalSystem`,
  never hand-edited.

## 8. What "done" looks like

`lake build --wfail` green over the library and `Tests/BimodalTest`; zero sorry; axiom count
unchanged; `check-module-invariants.sh` all checks pass; `mk_all --check` exits 0; Gap A and Gap B
closed with standard-axioms declarations; the support table complete, with every uncertified
manuscript statement named; and any renaming carrying deprecation aliases so `docs/theorem-index.md`
and downstream citations keep resolving.
