# Research Report: Auditing `def:frame`'s Four Constraints and the History-Restriction Identification

- **Task**: 657 - audit_frame_constraints_history_restriction
- **Started**: 2026-09-23T09:18:00Z
- **Completed**: 2026-09-23T09:55:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: 656 (general frames + `FrameOver.IsRegular`), 658 (state-topology collection), 659 (Saturation witnesses, R0 without Limit)
- **Sources/Inputs**:
  - Library: `FormalSystem/Semantics/TaskFrame.lean`, `Semantics/Extension/{Constraint,Admissible,Step,Extension,PeriodicExtension}.lean`, `Semantics/{PartialHistory,PartialHistoryOrder,FrameProperty,StateTopology}.lean`, `Semantics/StateTopology/{Counterexamples,ConstraintWitnesses,MetricFrame}.lean`, `Metalogic/Independence/DriftFrame.lean`
  - Manuscript record: `docs/reference/paper-definitions-of-record.md` (the citation source of record), `docs/reference/state-topology-appendix-support.md`
  - Prior task artifacts: reports of tasks 655, 656, 658, 659
  - Five sorry-free probes written for this round (see Appendix)
- **Artifacts**:
  - `specs/657_audit_frame_constraints_history_restriction/reports/01_audit-frame-constraints-restriction.md`
  - `specs/657_audit_frame_constraints_history_restriction/probes/Completion.lean`
  - `specs/657_audit_frame_constraints_history_restriction/probes/Restriction.lean`
  - `specs/657_audit_frame_constraints_history_restriction/probes/Nearest.lean`
  - `specs/657_audit_frame_constraints_history_restriction/probes/MixedSign.lean`
  - `specs/657_audit_frame_constraints_history_restriction/probes/Independence.lean`
- **Standards**: report-format.md, subagent-return.md, status-markers.md

## Executive Summary

- **The four constraints are the right four.** Each is now certified **independent** of the other
  three by a compiled witness; the two that had no witness (*Seriality*, *Compositionality*) get
  one in `probes/Independence.lean`. Nothing should be dropped, and nothing needs adding. This
  audit recommends **no change to the axiom list itself**.
- **Q1 (necessity).** *Saturation* is sufficient, not known to be necessary. The exact condition
  `thm:extension` needs is isolated and named *Completion* — `⋂_{t ∈ X} \Fib(w_t, z - t) \neq
  \emptyset` for every coherent family — and proved **equivalent** to the one-point extension
  property (`completion_iff_onePointExtension`) and **implied by** *Saturation*
  (`completion_of_isRegular`). Under *Completion* the extension theorem needs no
  *Compositionality* at all. The converse `Completion → Saturation` is **proved under mixed-sign
  composition** (`saturation_of_completion`) and **open without it**; the obstruction is located
  exactly, and is refuted as an addable axiom by the drift frame (`not_totalComp_F0`).
- **Q1 (redundancy).** `lem:step`'s own closing remark is formalized: over any discrete temporal
  order — `TaskFrame.IsZTime`, `def:BX-z`'s ℤ-time — *Saturation* is **redundant**,
  `thm:extension` following from the other three alone (`extension_of_isZTime`). *Saturation*
  earns its place only over dense time.
- **Q2 (the identification).** Both directions settled. The easy direction is genuinely free —
  `restrict` needs no constraint and not even `[F.IsRegular]`, axiom profile `[propext]`. The hard
  direction is `thm:extension` exactly. The identification holds **at the level of the order**:
  every instance of the extension relation is realized inside a single possible world
  (`exists_worldHistory_restricting_pair`). **Recommendation: keep the coherence definition
  primitive**; define restriction and state the identification as a corollary.
- **Q3/Q4 (audit and gaps).** Three docstring defects found and located (`constraint`'s docstring
  under-reports *Limit*; `FrameOver.reflection`'s over-reports *Seriality*; Step.lean's "one grep
  hit" claim is false as written). No result needs an unlisted constraint. Mixed-sign
  composition, *Triangle* and determinism are each evaluated as candidate fifth constraints and
  each **rejected**, with a compiled reason. The final-topology coincidence question remains open;
  a precise reformulation of its obstruction is recorded.

## Context & Scope

The question is whether *Compositionality*, *Seriality*, *Limit* and *Saturation* are the right
constraints on a task frame — the right number, strength and shape — with the anchor case being
whether partial histories are identifiable as restrictions of complete histories.

The audit was only statable after task 656 made the four constraints `Prop`-valued predicates
(`TaskFrame.Compositional`, `.Serial`, `.Limit`, `.Saturation`) carried by the class
`FrameOver.IsRegular` rather than fields of `FrameOver`. Every "which subset suffices for X"
claim below is stated at that granularity.

Scope limits observed: no file under `FormalSystem/` or `Tests/` was modified. All new results
live as five standalone probes under this task's `probes/` directory, each checked with
`lake env lean`, each containing zero `sorry`, and each headline declaration pinned at
`[propext, Classical.choice, Quot.sound]` or tighter. Manuscript claims cite paper labels or
quotable phrases only, via `docs/reference/paper-definitions-of-record.md`.

## Findings

### 1. Constraint consumption, per link of the extension chain

The chain, at the granularity the 656 refactor makes statable. `C` = *Compositionality* (with
`C→` = interpolation, `C←` = composition), `S` = *Seriality*, `L` = *Limit*, `Sat` =
*Saturation*.

| Declaration | Paper label | Binder | Constraints the proof consumes |
|---|---|---|---|
| `PartialHistory.Constraints`, `IsPaired` | `def:constraints` | none | none |
| `PartialHistory.nonempty_Constraints` | `lem:constraint`, first conjunct | none | none |
| `PartialHistory.nonempty_fib_of_serial` | — | `[F.IsRegular]` | `S`, **and `L`** (via `F.reflection`) |
| `PartialHistory.nonempty_seg_of_interpolates` | — | `[F.IsRegular]` | `C→`, **and `L`** (via `F.reflection`) |
| `PartialHistory.exists_mem_subset_inter` | `lem:nesting` | `[F.IsRegular]` | `C←`, `L` |
| `PartialHistory.constraint` | `lem:constraint` | `[F.IsRegular]` | `C→`, `C←`, `S`, `L`. **Not `Sat`** |
| `PartialHistory.fibers` | `lem:fibers` (DANGLING) | **none** | **none** — the one genuinely constraint-free link |
| `PartialHistory.adjoin`, `adjoin_extends`, `adjoin_domain_self` | — | none | none |
| `PartialHistory.admissible` | `lem:admissible` | `[F.IsRegular]` | `S`, `L` only. **Not `C`, not `Sat`** |
| `PartialHistory.step` | `lem:step` | `[F.IsRegular]` | **all four** — the sole `Sat` elimination site |
| `PartialHistory.chainSup`, `le_chainSup`, `exists_maximal_extension`, `isMax_of_total` | — | **none** | **none** — the Zorn layer is constraint-free |
| `PartialHistory.isTotal_of_isMax` | — | `[F.IsRegular]` | all four, forwarded from `step`; applies nothing itself |
| `PartialHistory.point` | — | `[F.IsRegular]` | `S`, `L` (via `nullity_identity`) |
| `PartialHistory.extension` | `thm:extension` | `[F.IsRegular]` | all four, plus Zorn |
| `PartialHistory.occurrence`, `hF_nonempty` | `cor:occurrence` | `[F.IsRegular]` | all four, plus Zorn |

Structural reading: **`Sat` enters at exactly one node, and that node is the join of the chain,
not a leaf.** `C` enters lowest, at two different leaves and in both of its directions. `S` enters
at two independent leaves. `L` is the most diffuse — present at nearly every level, and almost
always *silently*, through `FrameOver.reflection`.

Independently confirmed: `PartialHistoryOrder.lean` contains **zero** occurrences of `IsRegular`,
and `exists_maximal_extension` is the repository's only `zorn_` call site. The probe
`extension_of_completion` compiles with no `[F.IsRegular]` binder at all, which is a machine-checked
certificate of that orthogonality: Zorn and the four constraints meet only at `extension`.

#### 1a. Three docstring defects, located

- **`constraint`'s docstring under-reports *Limit*.** `FormalSystem/Semantics/Extension/Constraint.lean`'s
  `constraint` docstring states "*Limit* is not consumed either". At the level of the elaborated
  proof term this is **wrong**: `constraint` reaches `FrameOver.reflection` on three paths
  (`fib_subset_fib_of_le_of_le'`, `nonempty_fib_of_serial`, `nonempty_seg_of_interpolates`), and
  `reflection` is a *theorem* whose `d = 0` branch is discharged by `eq_of_taskRel_zero`, i.e. by
  *Limit*. The zero case is genuinely reachable — `nonempty_fib_of_serial` at `t = z` invokes
  `reflection` at duration `0`. The same caveat applies to `nonempty_fib_of_serial`'s own "No
  other axiom is used". A *Limit*-free route exists in principle (the `d ≠ 0` branch is
  definitional, `reflect_reflection_of_ne`; the probe `completion_of_hasNearest` takes exactly
  that route by excluding `z ∈ dom τ` first), but no declaration in the current tree takes it.
- **`FrameOver.reflection`'s own docstring over-reports.** It says the zero case uses
  `eq_of_taskRel_zero` "and `nullity` (*Seriality* plus *Limit*)". The proof body calls
  `eq_of_taskRel_zero` in both directions and never calls `nullity`. **`reflection` costs *Limit*
  alone.** This tightens the previous item rather than loosening it. The probe
  `PartialHistory.reflection_of_limit` (`probes/Completion.lean`) certifies the tighter statement.
- **Step.lean's grep claim is false as written.** Its module docstring says "a `grep` for
  `Saturation` across `FormalSystem/` should therefore find exactly one consuming proof".
  `F.saturation` is in fact *applied* at five sites; the other four are transport or restatement
  (`OpenLanguage/OpenReversal.lean`, `Semantics/IntTransfer.lean`,
  `Semantics/Frames/TranslationProduct.lean`, `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`,
  `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`), each taking *Saturation* in and
  giving *Saturation* out. The accurate claim, which survives the audit, is: **`step` is the sole
  site where *Saturation* is eliminated into a non-*Saturation* conclusion.**

### 2. Q1 — necessity of *Saturation*

#### 2a. The exact condition `thm:extension` needs

`lem:admissible` is a **biconditional**, and `lem:fibers` rewrites membership in every constraint
as a plain family of fiber conditions. Composing them localizes what the extension property needs,
with the segment class dropping out entirely:

> ***Completion***. `⋂_{t ∈ X} \Fib(w_t, z - t) \neq \emptyset` for every nonempty `X ⊆ D`, every
> family `{w_t}_{t ∈ X} ⊆ W` with `w_s ⇒_{t-s} w_t` for all `s, t ∈ X`, and every `z ∈ D`.

Probe: `probes/Completion.lean`. Two interchangeable forms are given — `Completion` over partial
histories and `CoherentCompletion` over a bare coherent family, bridged by
`completion_iff_coherentCompletion` (axioms `[propext]`). The second form mentions no notion of
history and is therefore statable inside `def:frame` itself.

| Result | Statement | Constraints used |
|---|---|---|
| `completion_of_onePointExtension` | the one-point extension property gives *Completion* | **none whatever** |
| `onePointExtension_of_completion` | *Completion* + `S` + `L` gives the one-point extension property | `S`, `L`. **No `Sat`, no `C`** |
| `completion_iff_onePointExtension` | the two are equivalent under `S` + `L` | `S`, `L` |
| `completion_of_isRegular` | *Saturation* gives *Completion* (through the existing `step`) | all four |
| `extension_of_completion` | *Completion* + `S` + `L` gives `thm:extension` in full | `S`, `L` |

**Consequence for the paper's axiom list.** Since `step` is the sole elimination site for
*Saturation*, replacing *Saturation* by *Completion* in `def:frame` loses nothing in the
development, and *Compositionality* then plays no part in `thm:extension` or `cor:occurrence` at
all — its role there is exactly to supply *Saturation* its directed-family hypothesis. It would
still be needed everywhere else it is used.

#### 2b. The converse, and where it breaks

Stating the converse precisely: does `Completion → Saturation` hold, and over which class?

**Answer: it holds over the class satisfying mixed-sign composition, and is open without it.**

`probes/MixedSign.lean` defines

> `TotalComp R := ∀ w u v x y, R w x u → R u y v → R w (x + y) v`

— `def:frame`'s *Compositionality* in the composition direction with its `x, y ≥ 0` provisos
dropped — and proves `saturation_of_completion`: under `TotalComp` and *Limit*, *Completion*
implies *Saturation*. The construction is exact: a `⊇`-directed family `S` *demands* the state `w`
at time `t` whenever some member of `S` is contained in `\Fib(w, -t)`; directedness plus
mixed-sign composition make the demanded states a coherent family, *Limit* makes the demand at
each time unique, and *Completion* at `z = 0` produces a state meeting every demand. Both the
fiber and the segment classes are covered, since a segment is contained in each of its two
endpoint fibers.

**The obstruction, and why it cannot be removed by adding an axiom.** `TotalComp` is independent
of the four constraints and refuted by a frame the manuscript needs:
`not_totalComp_F0` exhibits `0 ⇒₁ 2` and `2 ⇒₋₁ 1` with `0 ⇏₀ 1` at the drift frame
`FormalSystem.Metalogic.Independence.F0`, which `fzeroFrame_isRegular` certifies as satisfying all
four of `def:frame`'s constraints. `F°` is the frame `app:drift` supplies for
`cor:no-characterization`. DriftFrame.lean's own module docstring already records the point from
the other side: "`F°` genuinely **fails** mixed-sign composition — … so had the axiom been stated
two-sidedly, `F°` would not be a task frame and this entire independence result would be
unavailable."

So: **`Completion → Saturation` is OPEN, with the obstruction located at mixed-sign composition,
and mixed-sign composition is not addable.** A separating frame — one satisfying `C`, `S`, `L`
and *Completion* but not *Saturation* — must fail `TotalComp`. `F°` is not such a frame (it
satisfies *Saturation*). **The leading candidate is the rational two-origin frame**
(`StateTopology.RationalTwoOrigins.rel`): it satisfies `C`, `S` and `L` and **fails *Saturation***
(`not_rel_saturation`, via nested rational straddle sets whose common point would have to be
irrational), and whether it satisfies *Completion* is not determined here. Two outcomes, both
decisive:

- if it satisfies *Completion*, it **separates** the two conditions and settles the converse
  negatively — *Saturation* is then strictly stronger than `thm:extension` needs;
- if it fails *Completion*, the ℚ carrier is not the separator and the converse stays open.

`extension_of_completion` makes this checkable without Zorn: it suffices to exhibit one coherent
family of rational times whose fiber intersection is empty, or to show none exists. Producing that
verdict is the natural follow-up, and it is a one-probe task.

#### 2c. Where *Saturation* is redundant

`lem:step`'s recorded closing remark (verbatim): "When the family has a `\subseteq`-least member,
that member already contains a candidate and *Saturation* is not needed." `probes/Nearest.lean`
turns that remark into a theorem by identifying when the least member exists:

- `HasNearest D` — a condition on the **temporal order alone**: every nonempty one-sided part of a
  subset of `D` has a nearest member.
- `hasNearest_of_succPred` — every successor/predecessor-Archimedean linear order has it. That is
  exactly the class `TaskFrame.IsZTime` picks out, i.e. `def:BX-z`'s ℤ-time. `hasNearest_int` is
  the concrete `ℤ` instance.
- `completion_of_hasNearest` — `C` + `S` + `HasNearest` gives *Completion*. **No `Sat`, no `L`.**
  The `⊆`-least constraint is the straddling segment cut at the nearest domain time on each side;
  every other constraint contains it by *Compositionality* alone.
- `extension_of_isZTime` — **`thm:extension` over ℤ-time from `C` + `S` + `L` alone.**

This gives *Saturation* a sharp job description: **it is needed only over temporal orders in which
a subset of times can approach a time without reaching a nearest one — i.e. only over dense
time.** Two further classes where it is free were already in the tree and should be read alongside:
`TaskFrame.saturation_of_finite` (the paper's `cor:saturation-finite`, choice-free) and
`TaskFrame.saturation_of_deterministic` (a deterministic frame gets *Saturation* for free).

`Semantics/Extension/PeriodicExtension.lean` is the independent confirmation from the other
direction: over ℤ-time with a finite carrier it reaches `WorldHistory F` with `C` + `S` + `L` and
**no `Sat`**, and it is genuinely Zorn-free — `PartialHistoryOrder.lean` is not in its import
closure at all, so routing through Zorn is impossible rather than merely unused. (Zorn-free is
*not* choice-free there: `extend_periodic` opens with `classical` and its successor/predecessor
functions are `Classical.choose` applied to `F.serial`.) `extension_of_isZTime` generalizes the
constraint conclusion — it drops the finiteness of `W` — while remaining Zorn-based.

### 3. Q2 — the identification, at the order as well as pointwise

Probe: `probes/Restriction.lean`.

#### 3a. The easy direction really is easy, and costs nothing

`restrict (h : WorldHistory F) (X) (hX : ∃ t, X t) : PartialHistory F` takes **no frame
constraint and not even `[F.IsRegular]`**. Its four fields are `X`, the hypothesis, the world
history's states, and its `respects_task` — with no glue at all; the coherence condition of a
restriction *is* the world history's own. `restrict_isPartialHistory` states it as a claim rather
than a construction; its axiom profile is `[propext]`, the tightest in this round. The audit's
instruction to "check that it really is easy, and that it needs no constraint" is confirmed in the
strongest available sense.

#### 3b. The hard direction is `thm:extension`, on the nose

- `eq_restrict_of_extends` — a partial history extended by a possible world **is** that world's
  restriction to its own domain, as an equality of `PartialHistory` values (axioms
  `[propext, Quot.sound]`).
- `exists_restrict_eq` / `isRestriction_of_isRegular` — every partial history is literally
  `restrict h` for some `h`. This is `thm:extension` and nothing more.

The asymmetry is the finding: one inclusion is free, the other is the whole theorem.

#### 3c. The order level

- `restrict_mono` — restriction is monotone in the time set.
- `restrict_le_restrict_iff` — two restrictions of the *same* possible world stand in the
  extension order exactly as their time sets stand in inclusion (axioms `[propext]`).
- `restrict_univ` — restricting to all of `D` returns the world history.
- `exists_worldHistory_restricting_pair` — **the surjection carries the order**: whenever
  `τ ≤ σ`, a *single* possible world restricts onto both. So the identification is not merely a
  pointwise surjection onto the set of partial histories; every instance of `def:world-history`'s
  extension relation is realized inside one possible world.

#### 3d. Should the paper define partial histories as restrictions?

**No. Keep the coherence definition primitive and state the identification as a corollary.** Four
reasons, in order of force:

1. **It would make `thm:extension` a tautology while relocating, not removing, its content.**
   Defining a partial history as a restriction of a possible world makes "every partial history
   extends to a possible world" true by definition, and the real theorem becomes "the restriction
   class coincides with the coherence class" — the same mathematics, stated less directly.
2. **`lem:constraint`, `lem:fibers` and `lem:admissible` are all stated *about an arbitrary
   partial history*.** Under the restriction definition each of them presupposes a possible world
   it is being used to build, and the proof becomes circular in presentation even where it is not
   circular in fact.
3. **The Zorn argument needs the coherence class as a poset with chain suprema.** `chainSup` and
   `exists_maximal_extension` are constraint-free constructions on the coherence class; the
   restriction class has no independent handle on its chains — a chain of restrictions of
   *different* possible worlds need not be a chain of restrictions of any one of them until the
   theorem is already proved.
4. **The asymmetry of cost is itself the evidence.** The free direction is the definitional one;
   the expensive direction is the theorem. A definition should be the cheap side.

**What the paper should add instead**: a short corollary immediately after `thm:extension`,
recording the identification in both directions and the order-level form — see Recommendation R2.

### 4. Q3 — the other three constraints, audited

#### 4a. Independence: the matrix, now complete

| Constraint | Witness satisfying the other three and failing it | Declarations |
|---|---|---|
| *Compositionality* | **the bump frame `B`** (new, `probes/Independence.lean`): `Bool` over ℤ-time, identity at `0`, everything at `±1`, identity from `|d| ≥ 2` | `bumpFrame_serial`, `bumpFrame_limit`, `bumpFrame_saturation`, `bumpFrame_not_compositional` |
| *Seriality* | **the void frame `V`** (new, `probes/Independence.lean`): the empty task relation on `Bool` over ℤ-time | `voidFrame_compositional`, `voidFrame_limit`, `voidFrame_saturation`, `voidFrame_not_serial` |
| *Limit* | the four-state funnel (existing) | `StateTopology.funnel_serial`, `...funnel_compositional`, `...funnel_saturation`, `...funnel_not_limit` |
| *Saturation* | the rational two-origin frame (existing) | `StateTopology.RationalTwoOrigins.rel_serial`, `...rel_compositional`, `...rel_limit`, `...not_rel_saturation` |

Both new witnesses are finite, so *Saturation* is free by `TaskFrame.saturation_of_finite`
(`cor:saturation-finite`), and both are over ℤ, so *Limit* is `TaskFrame.limit_of_succOrder`.

**A packaging note, stated precisely.** Three of the four witnesses are frame-level: the funnel is
`funnelFrame : FrameOver D`, with `funnel_serial`, `funnel_compositional`, `funnel_saturation` and
`funnel_not_limit` all stated of `funnelFrame.TaskRel` (and deliberately given **no** `IsRegular`
instance), and the two new witnesses are `FrameOver intOrder` values built by
`FrameOver.ofReflective`, bridged by `voidFrame_taskRel` and `bumpFrame_taskRel`. The *Saturation*
witness is the exception: `RationalTwoOrigins.rel` is certified at the **bare-relation** level only
(`rel_serial`, `rel_compositional`, `rel_limit`, `not_rel_saturation`), with no `FrameOver`
wrapper. That is still the level at which `def:frame`'s constraints are stated, so the independence
is genuine; wrapping it would need a reflection law for its carrier first, which the module does
not prove. Recording the gap rather than overstating the row.
**Every one of `def:frame`'s four constraints is now certified independent of the other three.**
This is the strongest form of "the right number": none is derivable, and none is redundant as an
axiom (though *Saturation* is redundant *for the purposes the development puts it to* over ℤ-time
— §2c).

#### 4b. *Seriality* — both conjuncts are load bearing

`def:frame#Seriality` (verbatim): "$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some
$u, v \in W$", under `def:frame`'s blanket `x, y ≥ 0`. Both conjuncts are used, at genuinely
different sites:

- the **successor** conjunct in `nonempty_fib_of_serial`'s `t ≤ z` branch, and in
  `completion_of_hasNearest`'s "domain entirely at or below `z`" branch;
- the **predecessor** conjunct in the same lemmas' mirror branches.

Neither is derivable from the other in the presence of the rest: the relation is not assumed
symmetric, and `def:task-relation`'s reflection convention turns a predecessor claim into a
successor claim only at the *reflected* duration. **Verdict: keep as stated.** The `0 ≤ x` proviso
is also used at its stated strength — *Seriality* **at `x = 0`** is one of the two inputs to
`lem:nullity` (`nullity_of_serial_limit`), so dropping the `x = 0` instance would cost reflexivity.

#### 4c. *Compositionality* — both halves are load bearing

`def:frame#Compositionality` is a biconditional, and the audit confirms both halves are consumed
at different sites:

- `Interpolates` (the `→` half) at `nonempty_seg_of_interpolates`, and in this round's
  `completion_of_hasNearest` two-sided branch;
- `forward_comp` (the `←` half) at `fib_subset_fib_of_le_of_le` and `fib_subset_fib_of_le_of_le'`,
  hence at `exists_mem_subset_inter` and so at `lem:constraint`'s directedness step.

`constraint`'s own docstring already records this ("*Compositionality* is therefore consumed in
**both** of its directions here"), and the audit confirms it. **Verdict: keep as stated.** Note
the one contingency: if *Saturation* were replaced by *Completion* (§2a), `C` would drop out of
`thm:extension` entirely, retaining only its other uses.

#### 4d. *Limit* — exactly T1, and the silent one

`Limit` is now known to be exactly "the cone-neighbourhood topology is T1"
(`FrameOver.t1Space_iff_limit`; the relation-level sharper form
`TaskFrame.t1Space_nbhdTopology_iff_limit` consumes **no** constraint in either direction). The
user has ratified option (a), so the manuscript will define the topology as the
cone-neighbourhood topology and state `app:topology-t1` as a biconditional; the support table
`docs/reference/state-topology-appendix-support.md` is keyed to that decision.

Within the extension chain, *Limit* is consumed at exactly two kinds of site, and both are
invisible in the prose: **`FrameOver.reflection` at duration `0`** (§1a) and **`lem:nullity`**.
That is the audit's one "hidden" finding, and it is not a hidden *axiom* — it is a listed
constraint entering through a convention the reader takes to be purely notational.

**Verdict: keep as stated**, and add one sentence to the manuscript — see Recommendation R3.

#### 4e. Does any result secretly need an unlisted constraint?

**No.** The two suspects named in the audit brief are both cleared:

- **The reflection convention.** Its *law* form, `w ⇒_d u ↔ u ⇒_{-d} w` at every duration, is
  `FrameOver.reflection`. Off zero it is definitional content of the convention
  (`TaskFrame.reflect_reflection_of_ne`, no constraint at all); at zero it follows from **Limit
  alone**, certified by this round's `PartialHistory.reflection_of_limit`. It is not an extra
  axiom, and it does not need one.
- **Nullity.** `lem:nullity` is `nullity_of_serial_limit` — *Seriality* at `x = 0` plus *Limit*,
  choice-free, exactly as the paper says. Injectivity at zero (`eq_of_taskRel_zero`) is *Limit*
  alone; the conjunction `w ⇒₀ u ↔ w = u` is `nullity_identity`.

Neither is an unlisted constraint. The only correction the audit produces here is bookkeeping, not
mathematics: three docstrings mis-state which listed constraint is consumed (§1a).

### 5. Q4 — what is missing

Three candidate additional constraints were evaluated against the manuscript's aims (task frames
as dynamical systems, possible worlds as continuous paths, world states recurring and reusable
with time outside the state). **All three are rejected, each with a compiled reason.**

| Candidate | What it would buy | Why it is rejected |
|---|---|---|
| **Mixed-sign composition** (`TotalComp`) | the converse of §2b, making *Saturation* necessary as well as sufficient; also makes every cone open | **Excludes the drift frame `F°`**, which `app:drift` needs for `cor:no-characterization`. `not_totalComp_F0` + `fzeroFrame_isRegular` |
| **Triangle** (`TaskFrame.Triangle`) | `𝒯_F = 𝒩_F` (`coneTopology_eq_nbhdTopology_of_triangle`) | Sufficient but **not necessary** — the two-origin frame has the two topologies coinciding while *Triangle* fails (`TwoOrigins.not_triangle` with `...TwoOrigins.coneTopology_eq_nbhdTopology`). An axiom whose sufficiency is not matched by necessity belongs in the appendix as a hypothesis, not in `def:frame`. The exact criterion is already known and already stated: `coneTopology_eq_nbhdTopology_iff` |
| **Determinism** (`def:deterministic`) | *Saturation* for free (`TaskFrame.saturation_of_deterministic`) | It is already a **class**, standalone since the paper's 2026-08 wave, and `F°` — a frame the paper needs — is not deterministic (`fzero_not_deterministic`). Axiomatizing it would collapse the very independence results the appendix rests on |

**A positive recommendation falls out of the third row**: `saturation_of_deterministic` is a
companion to `cor:saturation-finite` and is not in the manuscript. See Recommendation R5.

#### 5a. The final-topology coincidence question — still open, obstruction reformulated

Task 655 left open: *what frame condition is equivalent to the cone-neighbourhood topology
coinciding with the final topology of all histories?* The state of that question is unchanged by
this audit, and the audit does not close it. What is certified today:

- `TaskFrame.finalTopology_le_nbhdTopology` — the containment always holds;
- `StateTopology.Hedgehog.finalTopology_ne_nbhdTopology` — it is **strict** on a genuine task
  frame (all four constraints, `Hedgehog.frame_saturation`);
- `TaskFrame.finalTopology_eq_of_surjective_open_history` — one surjective open history suffices;
- `StateTopology.MetricFrame.finalTopology_eq_nbhdTopology` — the metric frame realizes that.

**What this audit adds is a reformulation of the obstruction, in the vocabulary of §2.** The
recorded obstruction is "the extension theorem yields one history per escape, never one witnessing
all escapes". In the *Completion* vocabulary, that is exactly the difference between:

- *Completion*, which for each coherent family produces **one** state meeting all of its demands,
  hence (through Zorn) one possible world per partial history; and
- what the final topology needs, which is a **single** possible world whose image realizes a whole
  *family* of escapes simultaneously.

That suggests the following candidate, which this report records as a precisely stated conjecture
and explicitly **labels UNVERIFIED** — no probe supports it:

> **UNVERIFIED (candidate).** `𝒩_F` coincides with the final topology of all histories exactly
> when, for every `w ∈ W` and every `x > 0`, there is a *single* possible world `τ` with
> `τ(0) = w` whose restriction to `(-x, x)` has image cofinal in `(w)_x` — i.e. when every cone is
> the image of one history's short window, rather than a union of many.

The metric frame satisfies this by the straight line at full speed
(`MetricFrame.finalTopology_eq_nbhdTopology`); the hedgehog fails it, since no single history
enters more than two rays. **Settling this is the single most interesting remaining gap** and is
recommended as a successor task (R6), not attempted here.

### 6. Q5 — the verdict table

The audit's bottom line, one row per constraint. "What it buys" names the results that die without
it; "what it costs" names the frames it excludes.

| Constraint | What it buys (dies without it) | What it costs (excludes) | Used at its stated strength? | **Recommendation** |
|---|---|---|---|---|
| ***Compositionality*** | `lem:constraint` in both directions — `nonempty_seg_of_interpolates` (the `→` half) and `exists_mem_subset_inter` (the `←` half); hence `lem:step`, `thm:extension`, `cor:occurrence`. Also `PeriodicExtension`'s ℤ route and the whole `IntNormalForm` iteration layer | the bump frame `B` and every frame whose tasks do not compose; in particular any frame with a "one-shot" transition | **Yes, both halves.** Neither half is derivable from the other in the presence of the rest | **Keep as stated.** Do not split into two named axioms — the biconditional form is what `comp_of` and the transport lemmas consume |
| ***Seriality*** | `nonempty_fib_of_serial`, hence `lem:constraint`; `lem:nullity` (at `x = 0`), hence `lem:admissible`, `point`, `cor:occurrence`; the successor/predecessor functions of `PeriodicExtension` | the void frame `V` and every partially defined dynamics — a frame with a terminal or initial state | **Yes, both conjuncts and the `x = 0` instance.** The successor and predecessor conjuncts are used at genuinely different sites; the `x = 0` instance is one of `lem:nullity`'s two inputs | **Keep as stated.** In particular do not narrow the `0 ≤ x` proviso to `0 < x`: that would cost reflexivity |
| ***Limit*** | `lem:nullity`; the reflection law at `d = 0` (`FrameOver.reflection`), hence — silently — most of the extension chain; `eq_of_taskRel_zero`; and, exactly, T1 of the state topology (`FrameOver.t1Space_iff_limit`) | the four-state funnel and every frame with a one-way instantaneous pair; the ghost ray, and with it R0 | **Yes**, and it is the **most diffuse** of the four: it is consumed at nearly every level of the chain, almost always through `reflection` rather than by name | **Keep as stated.** Add one sentence recording that the reflection convention's *law* form costs *Limit* (R3), since the convention reads as pure notation |
| ***Saturation*** | `lem:step` **and nothing else** — it is eliminated at exactly one site in the entire development; through it, `thm:extension` and `cor:occurrence` | the rational two-origin frame, and in general any frame over a non-complete dense carrier whose fibers shrink to a gap | **Sufficient, not known to be necessary.** *Redundant* over discrete time (`extension_of_isZTime`), over finite `W` (`cor:saturation-finite`) and over deterministic frames (`saturation_of_deterministic`). The exact condition the one site needs is *Completion*, which *Saturation* implies and which is not known to imply it | **Keep as stated** — but record *Completion* as a lemma (R1) and the determinism companion (R5). The replacement option is fully specified in **R4** and deliberately **not** recommended |

**Nothing is added and nothing is dropped.** Three candidate additions were evaluated and rejected
(§5); all four existing constraints are independent (§4a) and all four are used at their stated
strength (column four). The recommended changes are three additions of *recorded results* — R1,
R2, R3 — plus one optional companion lemma (R5); none of them alters the axiom list.

## Decisions

- **D1.** The four constraints are kept. This audit recommends **no addition, no deletion, and no
  weakening** of `def:frame`'s axiom list. The dispatch's "a well-argued *the four constraints are
  already right* is a complete outcome" is the outcome reached, and it is reached on evidence
  (§4a's completed independence matrix) rather than by default.
- **D2.** *Completion* is reported as a **result about** `def:frame`, not as a replacement for
  *Saturation*. Replacement is presented as a live, fully specified alternative (R4) with its
  costs named, and is flagged as an author's judgment call rather than a recommendation this
  report makes — see "User decision" below.
- **D3.** Partial histories stay defined by coherence; restriction is defined from them, and the
  identification is stated as a corollary (§3d, R2).
- **D4.** Mixed-sign composition, *Triangle* and determinism are each rejected as fifth
  constraints, on compiled grounds (§5).
- **D5.** No file under `FormalSystem/` or `Tests/` was touched. Everything new is a probe under
  this task's directory. Promotion candidates are named in R7 for the planner to judge.

## Recommendations

Ordered by value to the manuscript. Every proposed statement is given in the paper's house style —
a `\begin{Lthm}`/`\begin{Cthm}` block with a `\label`, quantifying over `\F = \tuple{W, \D,
\Rightarrow}`, in the same register as the recorded anchors.

### R1 — Record *Completion* as a lemma before `lem:step` (highest value, no cost)

Add, immediately before `lem:step`:

```latex
\begin{Lthm} \label{lem:completion}
	For any task frame $\F = \tuple{W, \D, \Rightarrow}$, partial history $\tau : X \to W$, and duration $z \in D$, there is a world state $u \in W$ where $\tau(t) \Rightarrow_{z - t} u$ for every $t \in X$.
\end{Lthm}
```

with a remark recording that this is *equivalent* to `lem:step` and is what `lem:step` actually
consumes, *Saturation* entering only to establish it. Manuscript sites that would change:
`lem:step`'s proof (it would cite `lem:completion` rather than *Saturation* directly), and
`thm:extension`'s footnote (which currently attributes `cor:occurrence` to "*Seriality* and
*Saturation*" — accurate, but `lem:completion` is the sharper attribution).

Certified by `completion_of_isRegular` and `completion_iff_onePointExtension`
(`probes/Completion.lean`).

### R2 — State the identification as a corollary after `thm:extension`

```latex
\begin{Cthm} \label{cor:restriction}
	The partial histories over a task frame $\F = \tuple{W, \D, \Rightarrow}$ are exactly the restrictions of the possible worlds in $H_{\F}$ to nonempty sets of times: every such restriction is a partial history, and every partial history $\tau : X \to W$ is the restriction to $X$ of some $\sigma \in H_{\F}$. Moreover $\sigma$ may be chosen uniformly along the extension order: whenever $\sigma$ extends $\tau$, a single possible world restricts to both.
\end{Cthm}
```

Manuscript sites: `def:world-history` gains a forward reference; `thm:extension` gains the
corollary beneath it; anywhere the prose says "partial histories are pieces of possible worlds"
can cite a label instead. Certified by `restrict`, `restrict_isPartialHistory`,
`exists_restrict_eq` and `exists_worldHistory_restricting_pair` (`probes/Restriction.lean`).

Note explicitly in the corollary's remark that the *first* conjunct costs **no** frame constraint
and the second is `thm:extension` — the asymmetry is the content.

### R3 — One sentence on where *Limit* actually enters

`def:task-relation`'s reflection convention reads as pure notation. It is not: read back as a law
of the extended relation at **every** duration including zero, it consumes *Limit*. Add to
`def:task-relation`'s remark, or to `lem:nullity`'s:

> The reflection convention read back as a law — $w \Rightarrow_d u$ if and only if
> $u \Rightarrow_{-d} w$ for every $d \in D$ — is definitional away from $d = 0$ and follows from
> *Limit* at $d = 0$; it is therefore a consequence of `def:frame` rather than a further
> stipulation.

Certified by `PartialHistory.reflection_of_limit` (`probes/Completion.lean`). This is the finding
most likely to save a reader a wrong inference, and it costs one sentence.

### R4 — The replacement option, specified but **not** recommended

If the author prefers a `def:frame` whose fourth constraint is stated without the directed-family
apparatus, the exact replacement is:

```latex
\item[\it Completion:] $\bigcap\limits_{t \in X} \Fib(w_t, z - t) \neq \emptyset$ for any nonempty $X \subseteq D$, any family $\set{w_t}_{t \in X} \subseteq W$ with $w_s \Rightarrow_{t - s} w_t$ for all $s, t \in X$, and any $z \in D$.
```

**What it buys**: `def:frame`'s opening `\supseteq`-directed clause can be **deleted outright** —
it exists only to state *Saturation*; the segment class of `def:task-relation` survives only in
`def:constraints`; and `lem:step` becomes an immediate consequence of `lem:admissible`.

**What it costs**, and why this report does not recommend it:

- The ball-space footnote (Ćmiel–Kuhlmann–Kuhlmann, `\mathbf{S}_1^d`) would have to go or be
  restated — *Completion* has no place in that hierarchy.
- `cor:saturation-finite` would need restating for the new constraint (it does still hold —
  `saturation_of_finite` gives *Saturation*, which gives *Completion*).
- It is **not known to be a strict weakening**. `Saturation → Completion` is proved; the converse
  is open (§2b). Trading a condition with an established literature anchor for one not known to be
  weaker is a change this report will not manufacture.

Manuscript sites that would change if it is taken: `def:frame`'s opening clause and fourth item
and footnote; `def:frame#Saturation`'s sub-anchor; `lem:step` and its closing remark;
`lem:constraint` (which would become unnecessary for `thm:extension`, retaining other uses);
`thm:extension`'s footnote; `cor:saturation-finite`; and every prose occurrence of "*Saturation*"
paper-wide.

### R5 — Add the determinism companion to `cor:saturation-finite`

```latex
\begin{Lthm} \label{lem:saturation-deterministic}
	Every \textsc{Deterministic} task frame $\F = \tuple{W, \D, \Rightarrow}$ satisfies \textit{Saturation}, choice-free.
\end{Lthm}
```

Certified today by `TaskFrame.saturation_of_deterministic` (via
`TaskFrame.saturation_of_fib_subsingleton`). It sits naturally beside `cor:saturation-finite` and
tells the reader that the least intuitive constraint is automatic in the two most familiar
classes. It also makes `def:deterministic`'s standalone status earn something.

### R6 — Successor task: the final-topology coincidence condition

The single most interesting open question in this neighbourhood (§5a). Recommended shape: settle
the UNVERIFIED candidate in §5a, or produce a frame separating it from coincidence. Inputs
already compiled: `finalTopology_eq_of_surjective_open_history`,
`MetricFrame.finalTopology_eq_nbhdTopology`, `Hedgehog.finalTopology_ne_nbhdTopology`.

### R7 — Promotion candidates, for the planner to judge

Ranked. Nothing here is promoted by this report.

| Rank | Content | Proposed siting | Proposed names |
|---|---|---|---|
| 1 | `Completion` / `CoherentCompletion`, the equivalence with the one-point extension property, and `extension_of_completion` | a new `FormalSystem/Semantics/Extension/Completion.lean`, imported by `Extension.lean` after `Admissible` and before `Step` | `PartialHistory.Completion`, `...CoherentCompletion`, `...completion_iff_onePointExtension`, `...extension_of_completion` |
| 2 | `reflection_of_limit` — the *Limit*-only reflection law | `FormalSystem/Semantics/TaskFrame.lean`, beside `FrameOver.reflection`, with `reflection` re-proved from it | `FrameOver.reflection_of_limit` |
| 3 | `restrict` and the identification, including the order-level form | `FormalSystem/Semantics/PartialHistory.lean` (`restrict`, `eq_restrict_of_extends`) and `Extension/Extension.lean` (the two `[F.IsRegular]` results) | `PartialHistory.restrict`, `...eq_restrict_of_extends`, `...exists_restrict_eq`, `...exists_worldHistory_restricting_pair` |
| 4 | the two new independence witnesses | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` (already the home of constraint-failure witnesses) | `ConstraintWitnesses.VoidFrame.*`, `...BumpFrame.*` |
| 5 | `HasNearest`, `hasNearest_of_succPred`, `completion_of_hasNearest`, `extension_of_isZTime` | with rank 1, in `Extension/Completion.lean` | `PartialHistory.HasNearest`, `...extension_of_isZTime` |
| 6 | `TotalComp`, `saturation_of_completion`, `not_totalComp_F0` | `TotalComp` beside `TaskFrame.Triangle` in `Semantics/StateTopology.lean`; `not_totalComp_F0` in `Metalogic/Independence/DriftFrame.lean` | `TaskFrame.TotalComp`, `Independence.not_totalComp_F0` |

If any of rank 1–3 is promoted, the three docstring corrections in §1a should land in the same
phase — they are in the same files and are the audit's only in-tree defects.

## Risks & Mitigations

- **Risk**: R4 is presented but not recommended, and a reader in a hurry may take the *Completion*
  result as a recommendation to change the axiom. **Mitigation**: D2 and R4's own "not
  recommended" heading; the report's verdict table (§4a, §5) recommends *keep as stated* for all
  four.
- **Risk**: the three docstring corrections (§1a) touch files with heavy docstrings and pinned
  paper quotations; an edit could disturb a `check-paper-definitions.sh` anchor. **Mitigation**:
  all three corrections are to *prose about the Lean proof*, not to any `verbatim:` block or
  recorded quotation; none touches a hashed anchor.
- **Risk**: `saturation_of_completion` (`probes/MixedSign.lean`) is the longest new proof and uses
  `Classical.choose` on a domain predicate. **Mitigation**: it compiles with the standard axiom
  profile and is not on any promotion path above rank 6; if promoted it should carry its own
  regression test.
- **Risk**: the §5a candidate is UNVERIFIED and could be wrong. **Mitigation**: it is labelled
  UNVERIFIED in place, is not used to support any other claim, and is routed to a successor task
  rather than into the manuscript.

## Tactic Survey Results

Tactic selection was not the bottleneck in this round — every probe is a structural argument over
frame predicates rather than a goal for automation — but the survey below records what was tried
and what decided each choice.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `(z - tm) + (tp - z) = tp - tm` and its three siblings over a duration group | `ring` | fail | the duration carrier is `AddCommGroup` + `LinearOrder`, not a ring; `ring` does not apply |
| the same | `abel` | success | the correct tactic for an additive group; used at all four sites in `probes/Nearest.lean` |
| `y = 0` from `\|y\| < 1` over `↑intOrder` | `omega` | fail | `omega` inspects the **syntactic** type and does not see through `↑intOrder`'s reducible coercion to `ℤ`, even under a type ascription — TaskFrame.lean's `intOrder` docstring records exactly this trap |
| the same | `TaskFrame.limit_of_succOrder` | success | with `haveI : SuccOrder intOrder.carrier` / `NoMaxOrder intOrder.carrier` supplied explicitly and `import Mathlib.Data.Int.SuccPred` |
| `2 ≤ x` from `0 ≤ x`, `x ≠ 0`, `x ≠ 1` in a genuinely `ℤ`-typed context | `omega` | success | works once every hypothesis and the goal are stated at `(x : ℤ)` rather than at `↑intOrder` |
| a nonempty bounded-above subset of a `SuccArchimedean` order has a greatest element | Mathlib search | success | `BddAbove.exists_isGreatest_of_nonempty` and its `@[to_dual]`-generated `BddBelow.exists_isLeast_of_nonempty`, `Mathlib.Order.SuccPred.Archimedean` |
| `restrict h τ.domain τ.nonempty_domain = τ` | `congrArg` on a structure literal | fail | the `respects_task` field's type depends on `states`, so a non-dependent congruence does not typecheck |
| the same | `obtain ⟨d, n, s, r⟩ := τ` then `obtain rfl : … = s` then `rfl` | success | substituting the `states` *variable* lets proof irrelevance close the remaining fields |

No use was made of `simp?`/`exact?` search beyond the two Mathlib lookups above; all five probes
compiled on the first or second attempt.

## Context Extension Recommendations

- **Topic**: `omega` and the `↑TemporalOrder` coercion.
  **Gap**: `TaskFrame.lean`'s `intOrder` docstring records that "`omega` inspects the *syntactic*
  type of a hypothesis and does not see through the coercion", but no context file under
  `.claude/context/project/lean4/` carries it, so every new probe rediscovers it. This round lost
  three iterations to it.
  **Recommendation**: add a named pitfall to the lean4 extension's patterns directory — "durations
  are `↑intOrder`, not `ℤ`, as far as `omega` is concerned" — with the two fixes (state the binder
  as `(x : ℤ)`, or route through `TaskFrame.limit_of_succOrder`).
- **Topic**: standalone-probe import preamble.
  **Gap**: probe files are checked with a bare `lake env lean` and cannot import one another, so
  shared apparatus must be duplicated. Task 659's report raised the same point about
  `Mathlib.Tactic.*` imports; this round additionally needed `Mathlib.Data.Int.SuccPred` and
  `Mathlib.Order.SuccPred.Archimedean`, neither of which is in `FormalSystem.Semantics.Extension`'s
  closure.
  **Recommendation**: extend the operations note task 659 recommended into a short "probe preamble"
  file listing the imports a standalone semantics probe typically needs, and stating the
  no-cross-probe-import rule explicitly so the duplication is a documented convention rather than
  an apparent smell.

## Appendix

### Probe inventory

All five files are under
`specs/657_audit_frame_constraints_history_restriction/probes/`. Each compiles with
`lake env lean <path>` with zero errors, contains zero `sorry`, and every headline declaration
reports `[propext, Classical.choice, Quot.sound]` or tighter.

| File | Lines | Settles | Tightest axiom profile in file |
|---|---|---|---|
| `Completion.lean` | 201 | Q1: the exact condition `thm:extension` needs | `[propext]` (`completion_of_onePointExtension`, `completion_iff_coherentCompletion`) |
| `Restriction.lean` | 176 | Q2: the identification, pointwise and at the order | `[propext]` (`restrict`, `restrict_isPartialHistory`, `restrict_le_restrict_iff`) |
| `Nearest.lean` | 263 | Q1: *Saturation* redundant over discrete time | `[propext, Classical.choice, Quot.sound]` |
| `MixedSign.lean` | 205 | Q1: the converse, and its obstruction | `[propext, Classical.choice, Quot.sound]` |
| `Independence.lean` | 167 | Q3: the last two independence witnesses | `[propext, Quot.sound]` (`voidFrame_compositional`, `voidFrame_not_serial`) |

### Verification command

```bash
for f in specs/657_audit_frame_constraints_history_restriction/probes/*.lean; do
  lake env lean "$f"
done
```

Each invocation prints only the `#print axioms` lines of that file's `AxiomCheck` section; any
other output is an error.

### Manuscript anchors cited

`def:frame` and its four sub-anchors `def:frame#Compositionality`, `def:frame#Seriality`,
`def:frame#Limit`, `def:frame#Saturation`; `def:task-relation`; `def:temporal-order`;
`def:world-history`; `def:constraints`; `def:deterministic`; `def:frame-properties`; `def:BX-z`;
`lem:nullity`; `lem:constraint`; `lem:nesting`; `lem:admissible`; `lem:step`; `thm:extension`;
`cor:occurrence`; `cor:saturation-finite`; `app:drift`; `cor:no-characterization`;
`app:topology-t1`; `app:topology-r0`; `def:task-topology`.

Two labels appearing in in-tree docstrings are recorded **DANGLING** and must not be cited as live
anchors: `lem:fibers` (retired 2026-08-17) and `def:directed` (folded into `def:frame`'s opening
clause in the 2026-09 wave).

### Related documentation

- `docs/reference/paper-definitions-of-record.md` — the citation source of record
- `docs/reference/state-topology-appendix-support.md` — the manuscript-facing view of the
  topology collection, keyed by paper label
- `docs/theorem-index.md` — the per-theorem ledger
